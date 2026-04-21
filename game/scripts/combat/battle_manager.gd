extends Node2D

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

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

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

@onready var _atb: Node = $ATBSystem
@onready var _state: Node = $BattleState
@onready var _enemy_area: Node2D = $EnemyArea
@onready var _ui: CanvasLayer = $BattleUI


func _ready() -> void:
	_enemy_turn = BattleEnemyTurn.new(self, _state, _atb, _enemy_area)
	if _ui == null:
		push_error("BattleManager: BattleUI not found")
		call_deferred("_exit_battle", "flee")
		return
	_ui.initialize(self)
	_ui.command_submitted.connect(_on_ui_command)
	_ui.command_cancelled.connect(_on_ui_cancel)
	_ui.results_dismissed.connect(func() -> void: _exit_battle("victory"))
	_ui.submenu_state_changed.connect(func(o: bool) -> void: _atb.set_submenu_open(o))
	_state.member_died.connect(_on_party_member_died)
	var data: Dictionary = GameManager.transition_data
	if data.is_empty():
		push_error("BattleManager: No transition data")
		call_deferred("_exit_battle", "flee")
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
		call_deferred("_exit_battle", "flee")
		return
	_setup_party()
	_setup_enemies(encounter_group, data.get("enemy_act", "act_i"))
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
	if not _atb.should_pause_timers():
		for i: int in range(4):
			_state.tick_realtime_statuses(i, delta)
	_atb.tick(delta)
	_check_end_conditions()
	if _battle_resolved:
		return
	# Process one action per frame to respect ATB pacing.
	# Party members get input prompt; only one enemy acts per frame.
	var enemy_acted: bool = false
	for id: String in _atb.get_ready_queue():
		if id.begins_with("party_") and _awaiting_input_for == "":
			_awaiting_input_for = id
			_atb.set_command_menu_open(true)
			var slot: int = id.replace("party_", "").to_int()
			var member: Dictionary = _state.get_member(slot)
			var char_data: Dictionary = member.get("character_data", {})
			var lc: int = _enemies.filter(func(e: Node) -> bool: return e.is_alive).size()
			turn_ready.emit(id, true, slot, lc, _is_boss, char_data)
			break
		# Fix: skip enemy processing while a party member is awaiting input
		elif id.begins_with("enemy_") and not enemy_acted and _awaiting_input_for == "":
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
	_atb.set_command_menu_open(false)
	_atb.set_submenu_open(false)
	var ok: bool = true
	match command.get("type", ""):
		"attack":
			_do_attack(actor_id, command)
		"magic":
			ok = _do_magic(actor_id, command)
		"item":
			ok = _do_item(command)
		"defend":
			_do_defend(actor_id)
		"flee":
			if _is_boss:
				message.emit("Can't escape!")
				ok = false
			else:
				_do_flee()
		"ability":
			_do_attack(actor_id, command)
	if not ok:
		_atb.set_command_menu_open(true)
		var s: int = actor_id.replace("party_", "").to_int()
		var lc: int = _enemies.filter(func(e: Node) -> bool: return e.is_alive).size()
		turn_ready.emit(
			actor_id, true, s, lc, _is_boss, _state.get_member(s).get("character_data", {})
		)
		return
	if not _battle_active:
		return
	var cmd_slot: int = actor_id.replace("party_", "").to_int()
	if _state.get_member(cmd_slot).get("is_defending", false):
		_state.set_defending(cmd_slot, false)
		_state.set_buff(cmd_slot, "damage_taken_mult", 1.0)
	_awaiting_input_for = ""
	_atb.reset_gauge(actor_id)
	_turn_counter += 1
	_state.tick_statuses(actor_id.replace("party_", "").to_int())
	_check_end_conditions()


func _on_ui_cancel() -> void:
	_atb.set_command_menu_open(false)
	_awaiting_input_for = ""


func _on_party_member_died(slot: int) -> void:
	_atb.remove_combatant("party_%d" % slot)
	if _awaiting_input_for == "party_%d" % slot:
		_awaiting_input_for = ""
		_atb.set_command_menu_open(false)


func _do_attack(actor_id: String, command: Dictionary) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	var target_idx: int = BattleActions.resolve_enemy_target(command.get("target", 0), _enemies)
	if target_idx < 0:
		return
	var member: Dictionary = _state.get_member(slot)
	message.emit("%s attacks!" % member.get("character_data", {}).get("name", "???"))
	var result: Dictionary = BattleActions.execute_party_attack(
		_state, slot, _enemies[target_idx], target_idx
	)
	damage_dealt.emit("enemy_%d" % target_idx, result.get("damage", 0), result.get("type", "miss"))
	if result.get("killed", false):
		combatant_died.emit("enemy_%d" % target_idx)
		_atb.remove_combatant("enemy_%d" % target_idx)


func _do_magic(actor_id: String, command: Dictionary) -> bool:
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = _state.get_member(slot)
	if member.is_empty():
		return false
	var spell: Dictionary = command.get("spell", {})
	var target_type: String = spell.get("target", "single_enemy")
	# Validate single_ally target before spending MP or gaining gauge
	if target_type == "single_ally":
		var tgt: int = command.get("target", 0)
		var tm: Dictionary = _state.get_member(tgt)
		if tm.is_empty() or not tm.get("is_alive", false):
			message.emit("No effect!")
			return false
	if not _state.spend_mp(slot, spell.get("mp_cost", 0)):
		message.emit("Not enough MP!")
		return false
	var mag: int = _state.get_effective_stat(slot, "mag")
	var power: int = spell.get("power", 10)
	var element: String = spell.get("element", "non_elemental")
	var caster_name: String = member.get("character_data", {}).get("name", "???")
	message.emit("%s casts %s!" % [caster_name, spell.get("name", "Spell")])
	if target_type == "single_enemy":
		var etgt: int = BattleActions.resolve_enemy_target(command.get("target", 0), _enemies)
		if etgt < 0:
			message.emit("No target!")
			return false
		_do_magic_on_enemy(slot, mag, power, element, etgt)
	elif target_type == "all_enemies":
		for i: int in range(_enemies.size()):
			if _enemies[i].is_alive and not _enemies[i].get_meta("untargetable", false):
				_do_magic_on_enemy(slot, mag, power, element, i)
	elif target_type in ["single_ally", "all_allies"]:
		var heal_amt: int = DamageCalc.calculate_healing(mag, power)
		if target_type == "single_ally":
			var tgt: int = command.get("target", 0)
			var healed: int = _state.heal(tgt, heal_amt)
			if healed > 0:
				damage_dealt.emit("party_%d" % tgt, healed, "heal")
		else:
			for i: int in range(4):
				var m: Dictionary = _state.get_member(i)
				if not m.is_empty() and m.get("is_alive", false):
					# Fix: only show heal popup if healed > 0 (skip full-HP members)
					var healed_amt: int = _state.heal(i, heal_amt)
					if healed_amt > 0:
						damage_dealt.emit("party_%d" % i, healed_amt, "heal")
	# Gain Weave Gauge AFTER target validation to prevent gauge farming
	_state.gain_weave_gauge(slot, 5)
	if member.get("character_id", "") != "maren":
		_state.gain_weave_gauge_for_maren(10)
	return true


func _do_magic_on_enemy(caster_slot: int, mag: int, power: int, element: String, idx: int) -> void:
	if idx < 0 or idx >= _enemies.size():
		return
	var result: Dictionary = BattleActions.apply_magic_to_enemy(
		_state, caster_slot, mag, power, element, _enemies[idx], idx
	)
	var dtype: String = result.get("type", "miss")
	if dtype == "immune":
		damage_dealt.emit("enemy_%d" % idx, 0, "immune")
	elif dtype == "absorb":
		damage_dealt.emit("enemy_%d" % idx, result.get("damage", 0), "heal")
	elif result.get("hit", false):
		damage_dealt.emit("enemy_%d" % idx, result.get("damage", 0), "magic")
		if result.get("killed", false):
			combatant_died.emit("enemy_%d" % idx)
			_atb.remove_combatant("enemy_%d" % idx)
	else:
		damage_dealt.emit("enemy_%d" % idx, 0, "miss")


func _do_item(command: Dictionary) -> bool:
	var item: Dictionary = command.get("item", {})
	var target_slot: int = command.get("target", 0)
	match item.get("effect_type", ""):
		"restore_hp":
			var can_revive: bool = item.get("can_revive", false)
			var tgt_m: Dictionary = _state.get_member(target_slot)
			if not tgt_m.get("is_alive", true) and not can_revive:
				message.emit("No effect!")
				return false
			message.emit("Used %s!" % item.get("name", "Item"))
			var actual: int = _state.heal(target_slot, item.get("restore_amount", 100), can_revive)
			if actual > 0:
				damage_dealt.emit("party_%d" % target_slot, actual, "heal")
		"revive":
			var rev_m: Dictionary = _state.get_member(target_slot)
			if rev_m.get("is_alive", true):
				message.emit("No effect!")
				return false
			message.emit("Used %s!" % item.get("name", "Item"))
			var actual: int = _state.heal(target_slot, item.get("restore_amount", 1), true)
			if actual > 0:
				damage_dealt.emit("party_%d" % target_slot, actual, "heal")
		"restore_mp":
			message.emit("Used %s!" % item.get("name", "Item"))
			_state.restore_mp(target_slot, item.get("restore_amount", 30))
		"cure_status":
			message.emit("Used %s!" % item.get("name", "Item"))
			for sname: String in item.get("cures", []):
				_state.remove_status(target_slot, sname)
		"smoke_bomb":
			if _is_boss:
				message.emit("Can't use that here!")
				return false
			message.emit("Used %s!" % item.get("name", "Item"))
			_exit_battle("flee")
		_:
			message.emit("No effect!")
			return false
	return true


func _do_defend(actor_id: String) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	_state.set_defending(slot, true)
	_state.set_buff(slot, "damage_taken_mult", 0.5)
	var nm: String = _state.get_member(slot).get("character_data", {}).get("name", "???")
	message.emit("%s defends!" % nm)


func _do_flee() -> void:
	var alive_enemies: Array[Node] = []
	for e: Node in _enemies:
		if e.is_alive:
			alive_enemies.append(e)
	var enemy_spd_sum: float = alive_enemies.reduce(
		func(acc: float, e: Node) -> float: return acc + e.get_stats().get("spd", 10), 0.0
	)
	var chance: int = DamageCalc.calculate_flee_chance(
		_state.get_avg_party_spd(), enemy_spd_sum / maxf(1.0, alive_enemies.size())
	)
	if randi() % 100 < chance:
		message.emit("Escaped!")
		flee_result.emit(true)
		_exit_battle("flee")
	else:
		message.emit("Can't escape!")
		flee_result.emit(false)


func _check_end_conditions() -> void:
	if _enemies.all(func(e: Node) -> bool: return not e.is_alive):
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
			_exit_battle("fenmother_cleansing")
			return
		victory.emit(r)
	elif _state.is_party_wiped():
		defeat.emit()
		_exit_battle("faint")


func _count_ko_party_members() -> int:
	var count: int = 0
	for i: int in range(4):
		var m: Dictionary = _state.get_member(i)
		if not m.is_empty() and not m.get("is_alive", true):
			count += 1
	return count


func _exit_battle(result: String) -> void:
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


func _setup_party() -> void:
	var active: Array[Dictionary] = PartyState.get_active_party()
	for i: int in range(active.size()):
		if not active[i].is_empty():
			_state.add_member(i, active[i])
			var effective_spd: int = _state.get_effective_stat(i, "spd")
			_atb.add_combatant("party_%d" % i, effective_spd, false)


## @param encounter_group Array[String] — enemy IDs from JSON encounter data.
func _setup_enemies(encounter_group: Array, enemy_act: String) -> void:
	_turn_counter = 0
	_enemy_turn.reset()
	for i: int in range(mini(6, encounter_group.size())):
		var e: Node = ENEMY_SCENE.instantiate()
		_enemy_area.add_child(e)
		e.initialize(encounter_group[i], enemy_act)
		e.position = Vector2(160.0 + (i % 3) * 48.0, 40.0 + floorf(i / 3.0) * 48.0)
		_enemies.append(e)
		_atb.add_combatant("enemy_%d" % i, e.get_stats().get("spd", 10), true)
