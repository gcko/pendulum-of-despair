class_name BattleEnemyTurn
extends RefCounted
## Handles enemy turn execution. Bosses with a data-driven `boss_ai` script
## (GAP-009) route through BossAI, which keeps its own per-Enemy ai_state;
## everything else uses the weighted BattleAI. Action resolution is shared.

const BattleAI = preload("res://scripts/combat/battle_ai.gd")
const BossAI = preload("res://scripts/combat/boss_ai.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

## A Pallor enemy's regen per turn while any party member has Despair, as a
## fraction of its max HP (bestiary/README.md § Pallor).
const PALLOR_REGEN_PCT: float = 0.02

## References injected by BattleManager
var _manager: Node2D
var _state: Node
var _atb: Node
var _enemy_area: Node2D


func _init(manager: Node2D, state: Node, atb: Node, enemy_area: Node2D) -> void:
	_manager = manager
	_state = state
	_atb = atb
	_enemy_area = enemy_area


## Per-Enemy boss state lives on the Enemy node (ai_state), cleared by
## Enemy.initialize(), so the turn driver holds no boss state to reset.
func reset() -> void:
	pass


## Run one enemy turn.  Returns the new turn_counter value.
## `is_boss` (the battle-level flag) is retained for call-site interface symmetry
## only — action routing is now decided by BossAI.has_script(enemy_data), not this.
func execute(enemy_id: String, enemies: Array[Node], is_boss: bool, turn_counter: int) -> int:
	var idx: int = enemy_id.replace("enemy_", "").to_int()
	if idx < 0 or idx >= enemies.size():
		return turn_counter
	var enemy: Node = enemies[idx]
	if not enemy.is_alive:
		return turn_counter
	var blocked_by: String = StatusEffects.blocking_status(enemy.active_statuses)
	if blocked_by != "":
		# Paralysis auto-skips the turn, out loud, and its statuses tick
		# (combat-formulas.md § Status Effect ATB Interactions). A gauge-frozen
		# enemy (Stop/Sleep/Petrify) is passed over before it gets here.
		if StatusEffects.atb_effect(blocked_by) != "frozen":
			var adj: String = StatusEffects.display_adjective(blocked_by)
			_manager.message.emit("%s is %s and can't move!" % [enemy.get_display_name(), adj])
			_tick_enemy_statuses(enemy, idx)
		return turn_counter
	var auto: String = BattleAutoAction.driving_status(enemy.active_statuses)
	if not auto.is_empty():
		_auto_turn(auto, enemy, enemies, idx)
		return turn_counter + 1
	var pm: Array = range(4).map(func(i: int) -> Dictionary: return _state.get_member(i))
	var pr: Array = pm.map(
		func(m: Dictionary) -> String:
			if not m.is_empty():
				return m.get("row", "front")
			return "front"
	)
	var action: Dictionary = _select_action(enemy, enemies, is_boss, turn_counter, pm, pr)
	turn_counter += 1
	_apply_action(action, enemy, enemies, idx)
	return turn_counter


## Bosses with a data-driven script (GAP-009) route through BossAI (which manages
## their own enemy.ai_state); every other enemy uses the weighted BattleAI.
func _select_action(
	enemy: Node, enemies: Array[Node], _is_boss: bool, turn_counter: int, pm: Array, pr: Array
) -> Dictionary:
	if BossAI.has_script(enemy.enemy_data):
		return BossAI.select_action(enemy, turn_counter, _state, enemies)
	return BattleAI.select_action(enemy.enemy_data, pm, pr, enemy.has_status("silence"))


## Confusion or Berserk makes the enemy's basic attack for it, at the target
## BattleAutoAction picks (#246): on a party member, the very attack its AI
## would make; on another enemy, BattleAutoAction's enemy-on-enemy blow. A full
## turn either way, so its statuses tick and Confusion's 3 turns run out.
func _auto_turn(status: String, enemy: Node, enemies: Array[Node], idx: int) -> void:
	var target: String = BattleAutoAction.pick_target(status, "enemy_%d" % idx, _state, enemies)
	if target.begins_with("party_"):
		var slot: int = target.replace("party_", "").to_int()
		var mult: float = BattleAutoAction.damage_mult(enemy.active_statuses)  # Berserk
		_apply_action(
			{"type": "attack", "target_slot": slot, "damage_mult": mult}, enemy, enemies, idx
		)
		return
	if target.begins_with("enemy_"):
		BattleAutoAction.enemy_hits_enemy(_manager, _atb, enemy, enemies, target)
	_tick_enemy_statuses(enemy, idx)


func _apply_action(action: Dictionary, enemy: Node, enemies: Array[Node], idx: int) -> void:
	# One-time transition tells (phase change, dive/resurface) ride on the action.
	var pre_message: String = str(action.get("message", ""))
	if not pre_message.is_empty():
		_manager.message.emit(pre_message)
	var atype: String = action.get("type", "")
	if atype == "skip":
		# Untargetability is already synced by BossAI; the skip just passes a turn.
		_tick_enemy_statuses(enemy, idx)
		return
	if atype == "spawn":
		_do_spawn(action, enemy, enemies, idx)
		return
	if atype == "ability" and action.get("target", "") == "self":
		_do_self_ability(action, enemy, enemies)
		_tick_enemy_statuses(enemy, idx)
		return
	if atype == "heal" and action.get("target", "") == "self":
		var heal_amount: int = action.get("value", 0)
		enemy.current_hp = mini(
			enemy.current_hp + heal_amount,
			enemy.enemy_data.get("hp", 1),
		)
		_manager.damage_dealt.emit("enemy_%d" % idx, heal_amount, "heal")
	elif atype in ["attack", "ability"]:
		_do_attack_or_ability(action, enemy, idx)
	_tick_enemy_statuses(enemy, idx)


## End-of-turn status processing for an enemy: apply HP ticks (Poison/Burn)
## then decrement durations. Poison/Burn = floor(max_hp * tick_pct), min 1.
## Burn is fire: it scales by the enemy's Flame multiplier, so a weakness or
## resistance scales it, immunity voids it and absorption heals (ruling of
## 2026-10-29, #246). A Pallor enemy then regenerates while the party despairs.
func _tick_enemy_statuses(enemy: Node, idx: int) -> void:
	var max_hp: int = enemy.enemy_data.get("hp", 0)
	var eid: String = "enemy_%d" % idx
	for s: Dictionary in enemy.active_statuses.duplicate():
		var sname: String = s.get("name", "")
		var pct: float = StatusEffects.tick_pct(sname)
		if pct > 0.0 and enemy.is_alive:
			var dmg: int = maxi(1, int(max_hp * pct))
			if sname == "burn":
				var mult: float = enemy.get_element_multiplier("flame")
				if mult < 0.0:
					_heal_enemy(enemy, eid, int(dmg * -mult))
					continue
				if mult == 0.0:
					continue  # immune to fire: the burn does nothing
				dmg = maxi(1, int(dmg * mult))
			enemy.take_damage(dmg, false)  # DoT must not wake Sleep/Confusion
			_manager.damage_dealt.emit(eid, dmg, "burn" if sname == "burn" else "poison")
			# A DoT kill must clean up like any other kill, or the dead enemy's
			# gauge keeps filling and re-enters the ready queue.
			if not enemy.is_alive:
				_manager.combatant_died.emit(eid)
				_atb.remove_combatant(eid)
	if enemy.is_alive and enemy.get_type() == "pallor" and _party_despairs():
		_heal_enemy(enemy, eid, int(max_hp * PALLOR_REGEN_PCT))
	BattleEnemyHeal.tick_regen(_manager, enemy, idx)  # a Kindle Breath turned on it (#503)
	enemy.tick_statuses()
	enemy.tick_buffs()


## Heal [param enemy] by up to [param amount], showing the HP it actually
## gained, and nothing when it gained none (already at full).
func _heal_enemy(enemy: Node, eid: String, amount: int) -> void:
	var before: int = enemy.current_hp
	enemy.heal(amount)
	if enemy.current_hp > before:
		_manager.damage_dealt.emit(eid, enemy.current_hp - before, "heal")


## Whether a living party member has Despair, which feeds a Pallor enemy's
## regen (a fallen member's does not: ruling of 2026-10-29).
func _party_despairs() -> bool:
	for i: int in range(4):
		if _state.get_member(i).get("is_alive", false) and _state.has_status(i, "despair"):
			return true
	return false


## Resolve a self-targeted ability (GAP-024): land its status on the caster,
## without a roll (Coil's Haste, #506), or apply its stat buff. Only a positive
## status may land this way; an ailment or an unknown name is a data error,
## reported and not applied. scope "pack" buffs every living enemy of the
## caster's own kind (same enemy id — Pack Howl across all Wayward Wolves,
## palette-families.md § Wolf Family); "self" buffs only the caster.
func _do_self_ability(action: Dictionary, enemy: Node, enemies: Array[Node]) -> void:
	_manager.message.emit("%s uses %s!" % [enemy.get_display_name(), action.get("id", "")])
	var status_name: String = action.get("status", "")
	if StatusEffects.is_positive(status_name):
		var explicit: Variant = action.get("status_duration")
		enemy.apply_status(status_name, StatusEffects.resolve_duration(status_name, explicit))
	elif not status_name.is_empty():
		push_error("BattleEnemyTurn: self ability lands '%s', not a buff" % status_name)
	var buff: Dictionary = action.get("buff", {})
	if buff.is_empty():
		return
	var stat: String = buff.get("stat", "")
	var mult: float = float(buff.get("mult", 1.0))
	var duration: int = int(buff.get("duration", 5))
	if buff.get("scope", "self") == "pack":
		# "pack" = the caster's own kind (same enemy id), e.g. all Wayward Wolves
		# in the encounter (palette-families.md § Wolf Family, "all wolves") —
		# NOT every same-type beast, which would buff boars/serpents in the fight.
		var pack_id: String = enemy.enemy_data.get("id", "")
		for e: Node in enemies:
			if e.is_alive and e.enemy_data.get("id", "") == pack_id:
				e.apply_buff(stat, mult, duration)
	else:
		enemy.apply_buff(stat, mult, duration)


func _do_spawn(action: Dictionary, enemy: Node, enemies: Array[Node], idx: int) -> void:
	var spawn_ids: Array = action.get("enemies", [])
	# Enforce the move's add cap (bosses.md "max N active"): spawn at most
	# cap - current living adds, so a "< cap" trigger can never overshoot.
	var cap: int = int(action.get("cap", 99))
	var living_adds: int = BossAI.count_adds(enemies, enemy)  # a petrified add is not one
	var slots: int = maxi(0, cap - living_adds)
	var act: String = enemy.enemy_act if not enemy.enemy_act.is_empty() else "act_i"
	var spawned: int = 0
	for sid: String in spawn_ids:
		if spawned >= slots:
			break
		var new_enemy: Node = ENEMY_SCENE.instantiate()
		_enemy_area.add_child(new_enemy)
		new_enemy.initialize(sid, act)
		new_enemy.position = Vector2(randi_range(50, 249), randi_range(20, 119))
		enemies.append(new_enemy)
		var eid: String = "enemy_%d" % (enemies.size() - 1)
		_atb.add_combatant(eid, new_enemy.get_stats().get("spd", 10), true)
		new_enemy.died.connect(_manager._on_enemy_died.bind(new_enemy))
		new_enemy.status_applied.connect(_manager._on_enemy_status_applied.bind(new_enemy))
		announce_status_ends(new_enemy)
		spawned += 1
	if spawned > 0:
		_manager.message.emit("Corrupted Spawns emerge from the depths!")
	_tick_enemy_statuses(enemy, idx)


func _do_attack_or_ability(action: Dictionary, enemy: Node, idx: int) -> void:
	var asleep: Array[int] = sleeping_slots(_state)
	_resolve_attack_or_ability(action, enemy, idx)
	# A hit cures Sleep (#435); say so for each member this action woke.
	for line: String in wake_lines(_state, asleep):
		_manager.message.emit(line)


## The party slots asleep right now, for wake_lines after a hit lands.
static func sleeping_slots(state: Node) -> Array[int]:
	var out: Array[int] = []
	for i: int in range(4):
		if state.has_status(i, "sleep"):
			out.append(i)
	return out


## The "[Character] woke up!" line for each member of [param before] (from
## sleeping_slots) that a hit has since woken and left standing.
static func wake_lines(state: Node, before: Array[int]) -> Array[String]:
	var out: Array[String] = []
	for i: int in before:
		var m: Dictionary = state.get_member(i)
		if not state.has_status(i, "sleep") and m.get("is_alive", false):
			out.append(StatusEffects.wake_notice(m.get("character_data", {}).get("name", "???")))
	return out


## Announce [param enemy] waking (a hit cured its Sleep, as enemy.take_damage
## does) and its Poison or Silence running out (#246), with the lines the party
## gets; any other status runs out silently. Wired by BattleManager and _do_spawn.
func announce_status_ends(enemy: Node) -> void:
	enemy.status_removed.connect(
		func(status_name: String) -> void:
			if status_name == "sleep" and enemy.is_alive:
				_manager.message.emit(StatusEffects.wake_notice(enemy.get_display_name()))
	)
	enemy.status_expired.connect(
		func(status_name: String) -> void:
			if not StatusEffects.wears_off_notice(status_name).is_empty():
				_manager.message.emit(StatusEffects.wears_off_notice(status_name))
	)


func _resolve_attack_or_ability(action: Dictionary, enemy: Node, idx: int) -> void:
	var atype: String = action.get("type", "")
	var elem: String = action.get("element", "")
	if action.get("target", "") == "all":
		var move: String = action.get("id", "ability")
		_manager.message.emit("%s uses %s!" % [enemy.get_display_name(), move])
		var status_name: String = action.get("status", "")
		var first: bool = true  # one Arc Trap per attack, on its first target
		for i: int in range(4):
			if not enemy.is_alive:  # a Riposte felled it: the rest of the AoE never lands
				break
			var m: Dictionary = _state.get_member(i)
			if m.is_empty() or not m.get("is_alive", false):
				continue
			var result: Dictionary = _resolve_offensive(action, enemy, i, elem, first)
			first = false
			_emit_hit(i, result, idx)
			if not status_name.is_empty() and result.get("hit", false):
				(
					BattleActions
					. execute_enemy_status(
						_state,
						enemy,
						i,
						int(action.get("status_rate", 0)),
						status_name,
						action.get("status_duration"),
					)
				)
	else:
		var tgt: int = action.get("target_slot", 0)
		if tgt < 0:
			return
		var tgt_name: String = _state.get_member(tgt).get("character_data", {}).get("name", "???")
		_manager.message.emit("%s attacks %s!" % [enemy.get_display_name(), tgt_name])
		var result: Dictionary
		# Magic abilities (atk_type "magic") use the MAG formula; everything else
		# (basic attacks, physical abilities, legacy boss abilities) is physical.
		# A plain attack is execute_enemy_physical_ability(mult 1.0, hits 1).
		if BattleAI.resolves_as_magic(str(action.get("atk_type", "attack")), "single", elem):
			result = BattleActions.execute_enemy_magic(
				_state, enemy, tgt, elem, int(action.get("power", 0))
			)
		else:
			result = (
				BattleActions
				. execute_enemy_physical_ability(
					_state,
					enemy,
					tgt,
					float(action.get("ability_mult", 1.0)),
					int(action.get("hits", 1)),
					float(action.get("damage_mult", 1.0)),
				)
			)
		_emit_hit(tgt, result, idx)
		# Offensive status infliction on a landed hit (GAP-024, Venom Spit -> Poison).
		var status_name: String = action.get("status", "")
		if not status_name.is_empty() and result.get("hit", false):
			(
				BattleActions
				. execute_enemy_status(
					_state,
					enemy,
					tgt,
					int(action.get("status_rate", 0)),
					status_name,
					action.get("status_duration"),
				)
			)
	# Gain Weave Gauge for Maren AFTER action resolves (not before target validation)
	if atype == "ability":
		_state.gain_weave_gauge_for_maren(15)


## Show the damage [param result] dealt to [param slot], the share Edren
## absorbed from it under a Bulwark stance on Edren's own slot, and any Riposte
## he answered with on the attacker, enemy [param idx] — whose fall it reports.
func _emit_hit(slot: int, result: Dictionary, idx: int) -> void:
	_manager.damage_dealt.emit(
		"party_%d" % slot, result.get("damage", 0), result.get("type", "miss")
	)
	var absorbed: Dictionary = result.get("absorbed", {})
	if not absorbed.is_empty():
		_manager.damage_dealt.emit(
			"party_%d" % int(absorbed["slot"]), int(absorbed["damage"]), result.get("type", "miss")
		)
	var eid: String = "enemy_%d" % idx
	for counter: Dictionary in result.get("ripostes", []):
		if BattlePlayerActions.dealt_damage(counter):  # healing it earns no threat
			_state.add_threat(int(counter["slot"]), int(counter.get("damage", 0)))  # GAP-009
		_manager.damage_dealt.emit(eid, int(counter.get("damage", 0)), counter.get("type", "miss"))
		if counter.get("killed", false):
			_manager.combatant_died.emit(eid)
			_atb.remove_combatant(eid)


## Resolve one offensive AoE hit against a party slot. Magic when
## BattleAI.resolves_as_magic says so: atk_type "magic" OR the action carries an
## element (the legacy boss AoE shape, which routes by element with no
## atk_type); otherwise physical, with ability_mult + multi-hit support, and an
## Arc Trap sprung only where [param first].
func _resolve_offensive(
	action: Dictionary, enemy: Node, slot: int, elem: String, first: bool
) -> Dictionary:
	if BattleAI.resolves_as_magic(str(action.get("atk_type", "")), "all", elem):
		return BattleActions.execute_enemy_magic(
			_state, enemy, slot, elem, int(action.get("power", 0))
		)
	var mult: float = float(action.get("ability_mult", 1.0))
	var hits: int = int(action.get("hits", 1))
	return BattleActions.execute_enemy_physical_ability(_state, enemy, slot, mult, hits, 1.0, first)
