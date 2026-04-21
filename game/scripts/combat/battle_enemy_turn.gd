class_name BattleEnemyTurn
extends RefCounted
## Handles enemy turn execution and boss-specific AI state.
##
## Extracted from BattleManager to reduce file size and isolate
## boss AI tracking variables from the core battle loop.

const BattleAI = preload("res://scripts/combat/battle_ai.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

## Boss AI state — Vein Guardian
var vg_last_action: String = ""
var vg_reconstructed: bool = false

## Boss AI state — Corrupted Fenmother
var fm_surface_count: int = 0
var fm_diving: bool = false
var fm_spawned_adds: bool = false

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


func reset() -> void:
	vg_last_action = ""
	vg_reconstructed = false
	fm_surface_count = 0
	fm_diving = false
	fm_spawned_adds = false


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
	_track_boss_state(enemy, action)
	turn_counter += 1
	_apply_action(action, enemy, enemies, idx)
	return turn_counter


func _select_action(
	enemy: Node, enemies: Array[Node], is_boss: bool, turn_counter: int, pm: Array, pr: Array
) -> Dictionary:
	var eid: String = enemy.enemy_data.get("id", "")
	if is_boss and eid == "vein_guardian":
		var hp_ratio: float = float(enemy.current_hp) / float(enemy.enemy_data.get("hp", 1))
		return (
			BattleAI
			. get_vein_guardian_action(
				_state,
				turn_counter,
				hp_ratio,
				vg_last_action,
				vg_reconstructed,
			)
		)
	if is_boss and eid == "drowned_sentinel":
		return BattleAI.get_drowned_sentinel_action(_state, turn_counter)
	if is_boss and eid == "corrupted_fenmother":
		var hp_ratio: float = float(enemy.current_hp) / float(enemy.enemy_data.get("hp", 1))
		var alive_spawns: Array = enemies.filter(
			func(e: Node) -> bool:
				return e.is_alive and e.enemy_data.get("id", "") == "corrupted_spawn"
		)
		return (
			BattleAI
			. get_corrupted_fenmother_action(
				_state,
				turn_counter,
				hp_ratio,
				fm_surface_count,
				fm_diving,
				fm_spawned_adds,
				alive_spawns.size(),
			)
		)
	if enemy.enemy_data.get("is_mini_boss", false) or not is_boss:
		return BattleAI.select_action(enemy.enemy_data, pm, pr)
	return BattleAI.select_boss_action(enemy.enemy_data, enemy.current_hp, pm, pr)


func _track_boss_state(enemy: Node, action: Dictionary) -> void:
	var eid: String = enemy.enemy_data.get("id", "")
	if eid == "vein_guardian":
		vg_last_action = action.get("id", "")
		if action.get("id", "") == "reconstruct":
			vg_reconstructed = true
	if eid == "corrupted_fenmother":
		var aid: String = action.get("id", "")
		if aid == "spawn_adds":
			fm_spawned_adds = true
			fm_surface_count += 1
		elif aid == "start_dive":
			fm_diving = true
			fm_surface_count = 0
		elif aid == "dive":
			fm_surface_count += 1
		elif aid == "resurface":
			fm_diving = false
			fm_surface_count = 0
		else:
			fm_surface_count += 1


func _apply_action(action: Dictionary, enemy: Node, enemies: Array[Node], idx: int) -> void:
	var atype: String = action.get("type", "")
	if atype == "spawn":
		_do_spawn(action, enemy, enemies)
		return
	if atype == "skip":
		_do_skip(action, enemy)
		return
	if atype == "ability" and action.get("target", "") == "self":
		_manager.message.emit("%s uses %s!" % [enemy.get_display_name(), action.get("id", "")])
		enemy.tick_statuses()
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
	enemy.tick_statuses()


func _do_spawn(action: Dictionary, enemy: Node, enemies: Array[Node]) -> void:
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
	_manager.message.emit("Corrupted Spawns emerge from the depths!")
	enemy.tick_statuses()


func _do_skip(action: Dictionary, enemy: Node) -> void:
	var skip_id: String = action.get("id", "")
	if skip_id == "start_dive":
		_manager.message.emit("The Fenmother dives beneath the surface!")
		enemy.set_meta("untargetable", true)
	elif skip_id == "resurface":
		_manager.message.emit("The Fenmother resurfaces!")
		enemy.set_meta("untargetable", false)
	enemy.tick_statuses()


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
		for i: int in range(4):
			var m: Dictionary = _state.get_member(i)
			if m.is_empty() or not m.get("is_alive", false):
				continue
			var result: Dictionary
			if not elem.is_empty():
				var pwr: int = action.get("power", 10)
				result = BattleActions.execute_enemy_magic(_state, enemy, i, elem, pwr)
			else:
				result = BattleActions.execute_enemy_attack(_state, enemy, i)
			(
				_manager
				. damage_dealt
				. emit(
					"party_%d" % i,
					result.get("damage", 0),
					result.get("type", "miss"),
				)
			)
	else:
		var tgt: int = action.get("target_slot", 0)
		if tgt < 0:
			return
		var tgt_name: String = _state.get_member(tgt).get("character_data", {}).get("name", "???")
		_manager.message.emit("%s attacks %s!" % [enemy.get_display_name(), tgt_name])
		var result: Dictionary = BattleActions.execute_enemy_attack(_state, enemy, tgt)
		(
			_manager
			. damage_dealt
			. emit(
				"party_%d" % tgt,
				result.get("damage", 0),
				result.get("type", "miss"),
			)
		)
	# Gain Weave Gauge for Maren AFTER action resolves (not before target validation)
	if atype == "ability":
		_state.gain_weave_gauge_for_maren(15)
