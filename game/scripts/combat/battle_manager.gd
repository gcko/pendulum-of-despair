extends Node2D
## Drives one battle: the ATB loop, whose turn it is, and what happens when the
## last enemy or the last party member falls.
##
## The commands a player can pick live in their own modules — BattlePlayerActions
## (attack/defend/flee), BattleMagicCommand, BattleItemCommand and the unique
## commands' BattleAbilityCommand — and battle-start assembly lives in
## BattleSetup (GAP-087). This script dispatches to them and owns what they need.
## A confused or berserk member is not prompted: the loop issues an "auto"
## command for them, which BattleAutoAction resolves (#246).

signal battle_started(party: Array, enemies: Array, enemy_positions: Array)
signal turn_ready(
	cid: String, is_party: bool, slot: int, enemy_count: int, is_boss: bool, char_data: Dictionary
)
signal damage_dealt(target_id: String, amount: int, damage_type: String)
signal combatant_died(combatant_id: String)
signal victory(rewards: Dictionary)
signal defeat
signal flee_result(success: bool)
signal message(text: String)

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

var _return_map_id: String = ""
var _return_position: Vector2 = Vector2.ZERO
var _is_boss: bool = false
var _boss_flag: String = ""
var _formation_type: String = "normal"
var _enemies: Array[Node] = []
var _battle_active: bool = false
var _battle_resolved: bool = false
var _awaiting_input_for: String = ""
var _earned_xp: int = 0
var _earned_gold: int = 0
var _earned_drops: Array[Dictionary] = []
var _turn_counter: int = 0
var _enemy_turn: BattleEnemyTurn
var _wave_num: int = -1
var _cleansing_origin_position: Variant = null
var _encounter_source: String = ""
var _ritual_meter_value: float = 100.0
var _actions: BattlePlayerActions = null
var _magic: BattleMagicCommand = null
var _items: BattleItemCommand = null
var _abilities: BattleAbilityCommand = null
var _auto: BattleAutoAction = null

@onready var _atb: Node = $ATBSystem
@onready var _state: Node = $BattleState
@onready var _enemy_area: Node2D = $EnemyArea
@onready var _ui: CanvasLayer = $BattleUI


func _ready() -> void:
	_enemy_turn = BattleEnemyTurn.new(self, _state, _atb, _enemy_area)
	_auto = BattleAutoAction.new(self, _get_actions())
	if _ui == null:
		push_error("BattleManager: BattleUI not found")
		call_deferred("exit_battle", "flee")
		return
	_ui.initialize(self)
	_ui.command_submitted.connect(_on_ui_command)
	_ui.command_cancelled.connect(_on_ui_cancel)
	_ui.results_dismissed.connect(func() -> void: exit_battle("victory"))
	_ui.submenu_state_changed.connect(func(o: bool) -> void: _atb.set_submenu_open(o))
	_state.member_died.connect(_on_party_member_died)
	_state.member_revived.connect(_on_party_member_revived)
	_state.status_applied.connect(_on_party_status_applied)
	var data: Dictionary = GameManager.transition_data
	if data.is_empty():
		push_error("BattleManager: No transition data")
		call_deferred("exit_battle", "flee")
		return
	_return_map_id = data.get("return_map_id", "")
	_return_position = data.get("return_position", Vector2.ZERO)
	_is_boss = data.get("is_boss", false)
	_boss_flag = data.get("boss_flag", "")
	_formation_type = data.get("formation_type", "normal")
	_wave_num = data.get("wave_num", -1)
	_cleansing_origin_position = data.get("cleansing_origin_position", null)
	_encounter_source = data.get("encounter_source", "")
	_ritual_meter_value = data.get("ritual_meter_value", 100.0)
	if _encounter_source == "cleansing_wave":
		_is_boss = true
	var encounter_group: Array = data.get("encounter_group", [])  # Variant from JSON
	if encounter_group.is_empty():
		push_error("BattleManager: Empty encounter group")
		call_deferred("exit_battle", "flee")
		return
	BattleSetup.setup_party(_state, _atb)
	_turn_counter = 0
	_enemy_turn.reset()
	_enemies = BattleSetup.setup_enemies(
		encounter_group,
		data.get("enemy_act", "act_i"),
		_enemy_area,
		_atb,
		_on_enemy_died,
		_on_enemy_status_applied
	)
	for e: Node in _enemies:
		_enemy_turn.announce_wakes(e)
	BattleSetup.apply_atb_config(_atb)
	_atb.apply_formation(_formation_type)
	if _formation_type == "back_attack":
		for i: int in range(4):
			if not _state.get_member(i).is_empty():
				_state.swap_row(i)
	_battle_active = true
	var ps: Array = []
	for i: int in range(4):
		ps.append(_state.get_member(i))
	var es: Array = []
	var pos: Array[Vector2] = []
	for e: Node in _enemies:
		es.append({"name": e.get_display_name(), "hp": e.current_hp})
		pos.append(e.position)
	battle_started.emit(ps, es, pos)


func _process(delta: float) -> void:
	if not _battle_active or _battle_resolved:
		return
	# Resync living enemies' ATB freeze/mods from their current statuses
	# (GAP-003) so a cured Sleep unfreezes and an expired Slow clears.
	for i: int in range(_enemies.size()):
		if _enemies[i].is_alive:
			resync_enemy_atb(i)
	# Same for the party (#298). Without this the party half of that rule did
	# not exist: Sleep and Petrify never held a party gauge and Slow/Despair
	# never throttled one.
	for i: int in range(4):
		_resync_party_atb(i)
	# Real-time statuses (Stop) run on the battle seconds the gauges actually
	# advanced: tick returns 0 while timers are paused and stops early at the
	# first gauge to fill, so the two share one clock.
	var elapsed: float = _atb.tick(delta)
	for i: int in range(4):
		_state.tick_realtime_statuses(i, elapsed)
	for e: Node in _enemies:
		if e.is_alive:
			e.tick_realtime_statuses(elapsed)
	_check_end_conditions()
	if _battle_resolved:
		return
	# Process one action per frame to respect ATB pacing.
	# Party members get input prompt; only one enemy acts per frame.
	var enemy_acted: bool = false
	for id: String in _atb.get_ready_queue():
		if id.begins_with("party_") and _awaiting_input_for == "":
			var slot: int = id.replace("party_", "").to_int()
			var blocked_by: String = _incapacitating_status(slot)
			# Stop/Sleep/Petrify freeze the gauge, and a gauge-frozen member takes
			# no turn at all (combat-formulas.md § Status Effect ATB
			# Interactions): no announcement, no tick, and above all no reset
			# — the skip never writes to the gauge, so whatever the status is
			# holding survives it. Other combatants act around them.
			if StatusEffects.atb_effect(blocked_by) == "frozen":
				continue
			# The turn begins: Second Wind's regen lands (abilities.md § Cael — Rally).
			_emit_party_events(_state.begin_turn(slot))
			_check_end_conditions()  # a turn-start effect may have won or lost it
			if _battle_resolved or not _battle_active:
				return
			if not _state.get_member(slot).get("is_alive", false):
				continue  # it felled them: their turn ends unprompted
			if blocked_by != "":
				# Paralysis fills the gauge instead, so it does have a turn to
				# consume: the status counts down on this would-be turn (the
				# filling gauge is the clock), then the gauge resets so the next
				# skip is one turn later (#248).
				_skip_incapacitated_turn(slot, id, blocked_by)
				# break, not continue: the skip consumes this frame's single
				# action slot, so nothing else resolves alongside it (#260). The
				# gauge is back at 0, so this member is not ready again next
				# frame. The announcement's readability is the UI's job —
				# battle_ui queues messages (ui-design.md § 2.5).
				break
			_awaiting_input_for = id
			# Confusion/Berserk make this turn's basic attack for them (#246).
			var statuses: Array = _state.get_member(slot).get("active_statuses", [])
			if not BattleAutoAction.driving_status(statuses).is_empty():
				_on_ui_command({"type": "auto"})
				break
			_atb.set_command_menu_open(true)
			var char_data: Dictionary = _state.get_member(slot).get("character_data", {})
			turn_ready.emit(id, true, slot, _targetable_enemy_count(), _is_boss, char_data)
			break
		# Fix: skip enemy processing while a party member is awaiting input
		elif id.begins_with("enemy_") and not enemy_acted and _awaiting_input_for == "":
			# A gauge-frozen enemy (Stop/Sleep/Petrify) is passed over like a
			# frozen member: no turn, and its full gauge is kept.
			if _enemy_frozen(id):
				continue
			_turn_counter = _enemy_turn.execute(id, _enemies, _is_boss, _turn_counter)
			_atb.reset_gauge(id)
			_check_end_conditions()
			if _battle_resolved:
				return
			enemy_acted = true
			break


func _on_ui_command(command: Dictionary) -> void:
	if not _battle_active or _awaiting_input_for == "":
		return
	var actor_id: String = _awaiting_input_for
	var cmd_slot: int = actor_id.replace("party_", "").to_int()
	_atb.set_command_menu_open(false)
	_atb.set_submenu_open(false)
	var ok: bool = true
	match command.get("type", ""):
		"attack":
			ok = _get_actions().do_attack(actor_id, command)
		"magic":
			ok = _get_magic().do_magic(actor_id, command)
		"item":
			ok = _get_items().do_item(command)
		"defend":
			_get_actions().do_defend(actor_id)
		"flee":
			if _is_boss:
				message.emit("Can't escape!")
				ok = false
			else:
				_get_actions().do_flee()
		"ability":
			ok = _get_abilities().do_ability(actor_id, command)
		"auto":  # issued by _process, never by the menu
			_auto.act_for(cmd_slot)
	if not ok:
		_atb.set_command_menu_open(true)
		var char_data: Dictionary = _state.get_member(cmd_slot).get("character_data", {})
		turn_ready.emit(actor_id, true, cmd_slot, _targetable_enemy_count(), _is_boss, char_data)
		return
	if not _battle_active:
		return
	# Clear defending from a PREVIOUS turn — skip if this action IS defend
	if (
		command.get("type", "") != "defend"
		and _state.get_member(cmd_slot).get("is_defending", false)
	):
		_state.set_defending(cmd_slot, false)
		_state.set_buff(cmd_slot, "damage_taken_mult", 1.0)
	_awaiting_input_for = ""
	_atb.reset_gauge(actor_id)
	_turn_counter += 1
	# Surface party-side DoT (Poison/Burn) through damage_dealt so it shows a
	# floating number, mirroring the enemy-side tick.
	_emit_party_events(_state.tick_statuses(cmd_slot))
	_check_end_conditions()


func _on_ui_cancel() -> void:
	_atb.set_command_menu_open(false)
	_awaiting_input_for = ""


## Count enemies the player can actually target — alive AND not untargetable —
## matching BattleActions.resolve_enemy_target, so the target cursor range never
## addresses a diving/untargetable boss (GAP-009).
func _targetable_enemy_count() -> int:
	return (
		_enemies
		. filter(func(e: Node) -> bool: return e.is_alive and not e.get_meta("untargetable", false))
		. size()
	)


## Whether the enemy behind [param id] holds a gauge-freezing status.
func _enemy_frozen(id: String) -> bool:
	var idx: int = id.replace("enemy_", "").to_int()
	if idx < 0 or idx >= _enemies.size():
		return false
	return StatusEffects.atb_state(_enemies[idx].active_statuses)["frozen"]


## Name of the status stopping this member from acting — Paralysis, Sleep or
## Petrify — or "" when it can act (#248). The name matters: the caller treats a
## gauge-freezing status differently from Paralysis, and the announcement reads
## it back to the player. Which name wins when a member carries several is the
## registry's call, not this loop's iteration order (#300).
func _incapacitating_status(slot: int) -> String:
	var m: Dictionary = _state.get_member(slot)
	if m.is_empty() or not m.get("is_alive", false):
		return ""
	return StatusEffects.blocking_status(m.get("active_statuses", []))


## Auto-skip a paralyzed member's ready turn: announce, tick statuses (so the
## turn-based countdown advances + DoT still applies), and reset the gauge so the
## next skip is a turn away (#248). Ends with an end-condition check, mirroring
## _on_ui_command, so a DoT that kills the last standing member resolves the
## party wipe on this frame instead of one frame later (#260).
func _skip_incapacitated_turn(slot: int, id: String, status_name: String) -> void:
	var nm: String = _state.get_member(slot).get("character_data", {}).get("name", "???")
	message.emit("%s is %s and can't move!" % [nm, StatusEffects.display_adjective(status_name)])
	_emit_party_events(_state.tick_statuses(slot))
	_atb.reset_gauge(id)
	_check_end_conditions()


## Surface BattleState's turn events [{slot, dmg, type}] as floating numbers:
## a turn's start (Second Wind's heal) and its end (Poison/Burn damage, Regen
## and Mending Engine heals, each event carrying its own type). A Shock Coil's
## request ({slot, shock_coil}) is answered here, where the enemies are.
func _emit_party_events(events: Array) -> void:
	for ev: Dictionary in events:
		if ev.has("shock_coil"):
			_shock_coil(int(ev["slot"]), int(ev["shock_coil"]))
			continue
		damage_dealt.emit(
			"party_%d" % int(ev.get("slot", 0)), int(ev.get("dmg", 0)), ev.get("type", "poison")
		)


## Lira's Shock Coil at [param slot] strikes for [param power]: show the hit,
## and clean up the kill it makes as any kill is cleaned up.
func _shock_coil(slot: int, power: int) -> void:
	var hit: Dictionary = BattleForgewright.shock(_state, slot, power, _enemies)
	if hit.is_empty():
		return
	damage_dealt.emit(hit["target"], int(hit["damage"]), hit["type"])
	if hit["killed"]:
		combatant_died.emit(hit["target"])
		_atb.remove_combatant(hit["target"])


func _on_party_member_died(slot: int) -> void:
	_atb.remove_combatant("party_%d" % slot)
	if _awaiting_input_for == "party_%d" % slot:
		_awaiting_input_for = ""
		_atb.set_command_menu_open(false)


## A revived member rejoins the ATB, which their fall removed them from, with an
## empty gauge (the design docs give a revive no head start).
func _on_party_member_revived(slot: int) -> void:
	_atb.add_combatant("party_%d" % slot, _state.get_effective_stat(slot, "spd"), false)


## AoE-on-death hook (GAP-024). When an enemy with an aoe_on_death ability dies
## — by player attack, spell, or DoT — it bursts against the whole party. Edren's
## share of a hit his stance met shows its own number, and every member the
## burst woke is announced (#435).
func _on_enemy_died(enemy: Node) -> void:
	var ability: Dictionary = BattleActions.enemy_aoe_on_death_ability(enemy)
	if ability.is_empty():
		return
	message.emit("%s bursts apart!" % enemy.get_display_name())
	var asleep: Array[int] = BattleEnemyTurn.sleeping_slots(_state)
	for r: Dictionary in BattleActions.execute_aoe_on_death(_state, enemy, ability):
		var dtype: String = r.get("type", "miss")
		damage_dealt.emit("party_%d" % int(r.get("slot", 0)), int(r.get("damage", 0)), dtype)
		var share: Dictionary = r.get("absorbed", {})
		if not share.is_empty():
			damage_dealt.emit("party_%d" % int(share["slot"]), int(share["damage"]), dtype)
	for line: String in BattleEnemyTurn.wake_lines(_state, asleep):
		message.emit(line)


## Recompute an enemy's ATB freeze/mods from its current statuses, and its SPD
## from its buffs, so a SPD buff or debuff changes how fast the gauge fills.
## Idempotent; called for living enemies each frame and after status changes so
## cured or expired statuses clear (StatusEffects.atb_state is the pure core).
func resync_enemy_atb(idx: int) -> void:
	if idx < 0 or idx >= _enemies.size():
		return
	var eid: String = "enemy_%d" % idx
	var st: Dictionary = StatusEffects.atb_state(_enemies[idx].active_statuses)
	_atb.set_frozen(eid, st["frozen"])
	_atb.set_status_mods(eid, st["mods"])
	var e: Node = _enemies[idx]
	_atb.set_spd(eid, int(e.enemy_data.get("spd", 0) * e.buff_mult("spd")))  # Arc Trap
	if st["zeroed"]:
		_atb.set_gauge(eid, 0)


## Party-side mirror of resync_enemy_atb (#298): push a member's freeze, fill
## mods and held-at-zero state from their current statuses to the ATB system,
## every frame, so a landed Sleep holds the gauge where it stands and a cured
## one resumes from that same value (combat-formulas.md § Status Effect ATB
## Interactions). Petrify additionally pins the gauge to 0 while it lasts, which
## is what makes recovery start fresh when it is cured (#279).
func _resync_party_atb(slot: int) -> void:
	var m: Dictionary = _state.get_member(slot)
	if m.is_empty() or not m.get("is_alive", false):
		return
	var pid: String = "party_%d" % slot
	var st: Dictionary = StatusEffects.atb_state(m.get("active_statuses", []))
	_atb.set_frozen(pid, st["frozen"])
	_atb.set_status_mods(pid, st["mods"])
	_atb.set_spd(pid, _state.get_effective_stat(slot, "spd"))  # Press Forward's +SPD
	if st["zeroed"]:
		_atb.set_gauge(pid, 0)


## Tell the player a status just landed on a party member (#299). Routed through
## the one registry table so the wording is battle-dialogue.md
## § Status Effect Notifications rather than a per-caller invention, and so
## every path that lands a status on the PARTY announces it the same way,
## whatever inflicted it. A status with no canonical line lands silently.
func _on_party_status_applied(slot: int, status_name: String) -> void:
	var nm: String = _state.get_member(slot).get("character_data", {}).get("name", "???")
	var line: String = StatusEffects.application_notice(status_name, nm)
	if not line.is_empty():
		message.emit(line)


## Enemy-side mirror of _on_party_status_applied (#439), wired to each enemy's
## own status_applied, so a status spell, a spell's rider or any later path
## shows the same marker and reads the same registry line.
func _on_enemy_status_applied(status_name: String, _duration: int, enemy: Node) -> void:
	var idx: int = _enemies.find(enemy)
	if idx < 0:
		return
	resync_enemy_atb(idx)
	damage_dealt.emit("enemy_%d" % idx, 0, "status")
	var line: String = StatusEffects.application_notice(status_name, enemy.get_display_name())
	if not line.is_empty():
		message.emit(line)


func _check_end_conditions() -> void:
	if _battle_resolved:
		return
	# Petrify removes an enemy from combat, so a field of the dead and the
	# petrified is won; the loop below pays every enemy's rewards in full,
	# statues included (ruling of 2026-10-29, #246).
	if _enemies.all(func(e: Node) -> bool: return not e.is_alive or e.is_removed_from_combat()):
		_battle_resolved = true
		_awaiting_input_for = ""
		_earned_drops = []
		for e: Node in _enemies:
			_earned_xp += e.enemy_data.get("exp", e.enemy_data.get("xp", 0))
			_earned_gold += e.enemy_data.get("gold", 0)
			var d: Dictionary = e.roll_drop()
			if d.get("success", false):
				_earned_drops.append({"item_id": d.get("item_id", "")})
		var r: Dictionary = {"xp": _earned_xp, "gold": _earned_gold, "drops": _earned_drops}
		# Intercept: Fenmother boss triggers cleansing instead of victory
		if _boss_flag == "fenmother_boss_defeated":
			exit_battle("fenmother_cleansing")
			return
		victory.emit(r)
	elif _state.is_party_wiped():
		defeat.emit()
		exit_battle("faint")


func _count_ko_party_members() -> int:
	var count: int = 0
	for i: int in range(4):
		var m: Dictionary = _state.get_member(i)
		if not m.is_empty() and not m.get("is_alive", true):
			count += 1
	return count


func exit_battle(result: String) -> void:
	if not _battle_active:
		return
	_battle_active = false
	_awaiting_input_for = ""
	# Sync battle damage/healing back to PartyState
	_sync_party_hp_mp()
	var t: Dictionary = {
		"result": result,
		"map_id": _return_map_id,
		"position": _return_position,
		"earned_xp": _earned_xp,
		"earned_gold": _earned_gold,
		"earned_drops": _earned_drops,
		"boss_flag": _boss_flag,
		"turn_count": _turn_counter,
		"ko_count": _count_ko_party_members(),
	}
	if _wave_num >= 0:
		t["wave_num"] = _wave_num
	if _cleansing_origin_position != null:
		t["cleansing_origin_position"] = _cleansing_origin_position
	if not _encounter_source.is_empty():
		t["encounter_source"] = _encounter_source
	if _encounter_source == "cleansing_wave":
		t["ritual_meter_value"] = _ritual_meter_value
	_earned_drops = []
	_earned_xp = 0
	_earned_gold = 0
	GameManager.change_core_state(GameManager.CoreState.EXPLORATION, t)


func _sync_party_hp_mp() -> void:
	var active: Array[Dictionary] = PartyState.get_active_party()
	for i: int in range(mini(active.size(), 4)):
		var battle_member: Dictionary = _state.get_member(i)
		if battle_member.is_empty() or active[i].is_empty():
			continue
		active[i]["current_hp"] = battle_member.get("current_hp", active[i].get("current_hp", 0))
		active[i]["current_mp"] = battle_member.get("current_mp", active[i].get("current_mp", 0))


# ---------- Accessors for the command modules ----------


## The BattleState node holding the party's in-battle records.
func get_battle_state() -> Node:
	return _state


## The enemy nodes on the field, in slot order.
func get_enemies() -> Array[Node]:
	return _enemies


## The ATB system driving the turn gauges.
func get_atb() -> Node:
	return _atb


## Whether this is a boss fight — bosses cannot be fled or smoke-bombed.
func is_boss_battle() -> bool:
	return _is_boss


func _get_actions() -> BattlePlayerActions:
	if _actions == null:
		_actions = BattlePlayerActions.new(self)
	return _actions


func _get_magic() -> BattleMagicCommand:
	if _magic == null:
		_magic = BattleMagicCommand.new(self)
	return _magic


func _get_items() -> BattleItemCommand:
	if _items == null:
		_items = BattleItemCommand.new(self)
	return _items


func _get_abilities() -> BattleAbilityCommand:
	if _abilities == null:
		_abilities = BattleAbilityCommand.new(self)
	return _abilities
