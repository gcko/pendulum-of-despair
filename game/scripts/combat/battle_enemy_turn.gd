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
func execute(enemy_id: String, enemies: Array[Node], is_boss: bool, turn_counter: int) -> int:
	var idx: int = enemy_id.replace("enemy_", "").to_int()
	if idx < 0 or idx >= enemies.size():
		return turn_counter
	var enemy: Node = enemies[idx]
	if not enemy.is_alive:
		return turn_counter
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
	return BattleAI.select_action(enemy.enemy_data, pm, pr)


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
func _tick_enemy_statuses(enemy: Node, idx: int) -> void:
	var max_hp: int = enemy.enemy_data.get("hp", 0)
	var eid: String = "enemy_%d" % idx
	for s: Dictionary in enemy.active_statuses.duplicate():
		var sname: String = s.get("name", "")
		var pct: float = StatusEffects.tick_pct(sname)
		if pct > 0.0 and enemy.is_alive:
			var dmg: int = maxi(1, int(max_hp * pct))
			enemy.take_damage(dmg, false)  # DoT must not wake Sleep/Confusion
			_manager.damage_dealt.emit(eid, dmg, "burn" if sname == "burn" else "poison")
			# A DoT kill must clean up like any other kill, or the dead enemy's
			# gauge keeps filling and re-enters the ready queue.
			if not enemy.is_alive:
				_manager.combatant_died.emit(eid)
				_atb.remove_combatant(eid)
	enemy.tick_statuses()
	enemy.tick_buffs()


## Resolve a self-targeted ability (GAP-024): apply its stat buff. scope "pack"
## buffs every living enemy of the caster's own kind (same enemy id — Pack Howl
## across all Wayward Wolves, palette-families.md:435); "self" buffs only the
## caster.
func _do_self_ability(action: Dictionary, enemy: Node, enemies: Array[Node]) -> void:
	_manager.message.emit("%s uses %s!" % [enemy.get_display_name(), action.get("id", "")])
	var buff: Dictionary = action.get("buff", {})
	if buff.is_empty():
		return
	var stat: String = buff.get("stat", "")
	var mult: float = float(buff.get("mult", 1.0))
	var duration: int = int(buff.get("duration", 5))
	if buff.get("scope", "self") == "pack":
		# "pack" = the caster's own kind (same enemy id), e.g. all Wayward Wolves
		# in the encounter (palette-families.md:435 "all wolves") — NOT every
		# same-type beast, which would buff boars/serpents sharing the fight.
		var pack_id: String = enemy.enemy_data.get("id", "")
		for e: Node in enemies:
			if e.is_alive and e.enemy_data.get("id", "") == pack_id:
				e.apply_buff(stat, mult, duration)
	else:
		enemy.apply_buff(stat, mult, duration)


func _do_spawn(action: Dictionary, enemy: Node, enemies: Array[Node], idx: int) -> void:
	var spawn_ids: Array = action.get("enemies", [])
	var act: String = enemy.enemy_act if not enemy.enemy_act.is_empty() else "act_i"
	for sid: String in spawn_ids:
		var new_enemy: Node = ENEMY_SCENE.instantiate()
		_enemy_area.add_child(new_enemy)
		new_enemy.initialize(sid, act)
		new_enemy.position = Vector2(randi_range(50, 249), randi_range(20, 119))
		enemies.append(new_enemy)
		var eid: String = "enemy_%d" % (enemies.size() - 1)
		_atb.add_combatant(eid, new_enemy.get_stats().get("spd", 10), true)
		new_enemy.died.connect(_manager._on_enemy_died.bind(new_enemy))
	_manager.message.emit("Corrupted Spawns emerge from the depths!")
	_tick_enemy_statuses(enemy, idx)


func _do_attack_or_ability(action: Dictionary, enemy: Node, _idx: int) -> void:
	var atype: String = action.get("type", "")
	var elem: String = action.get("element", "")
	if action.get("target", "") == "all":
		(
			_manager
			. message
			. emit(
				(
					"%s uses %s!"
					% [
						enemy.get_display_name(),
						action.get("id", "ability"),
					]
				)
			)
		)
		var status_name: String = action.get("status", "")
		for i: int in range(4):
			var m: Dictionary = _state.get_member(i)
			if m.is_empty() or not m.get("is_alive", false):
				continue
			var result: Dictionary = _resolve_offensive(action, enemy, i, elem)
			(
				_manager
				. damage_dealt
				. emit(
					"party_%d" % i,
					result.get("damage", 0),
					result.get("type", "miss"),
				)
			)
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
		if action.get("atk_type", "attack") == "magic":
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
				)
			)
		_manager.damage_dealt.emit(
			"party_%d" % tgt, result.get("damage", 0), result.get("type", "miss")
		)
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


## Resolve one offensive AoE hit against a party slot. Magic when atk_type is
## "magic" OR the action carries an element (the latter preserves legacy boss
## AoEs — ember_pulse/frost_wave — which route by element with no atk_type);
## otherwise physical, with ability_mult + multi-hit support. The single-target
## branch deliberately keeps its atk_type-only routing so legacy water_jet stays
## physical (boss AI is GAP-009 scope).
func _resolve_offensive(action: Dictionary, enemy: Node, slot: int, elem: String) -> Dictionary:
	if action.get("atk_type", "") == "magic" or not elem.is_empty():
		return BattleActions.execute_enemy_magic(
			_state, enemy, slot, elem, int(action.get("power", 0))
		)
	return BattleActions.execute_enemy_physical_ability(
		_state, enemy, slot, float(action.get("ability_mult", 1.0)), int(action.get("hits", 1))
	)
