extends Node2D
## Battle orchestrator — encounter setup, command dispatch, ATB ticking,
## victory/defeat flow.
##
## Attached to the root Battle node in battle.tscn. Reads
## GameManager.transition_data on _ready() and manages the full
## battle lifecycle. Action execution delegated to battle_actions.gd.

signal battle_started(party: Array, enemies: Array)
signal turn_ready(combatant_id: String, is_party: bool)
signal action_executed(action: Dictionary)
signal damage_dealt(target_id: String, amount: int, damage_type: String)
signal status_changed(target_id: String, status_name: String, applied: bool)
signal combatant_died(combatant_id: String)
signal victory(rewards: Dictionary)
signal defeat
signal flee_result(success: bool)
signal message(text: String)

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleAI = preload("res://scripts/combat/battle_ai.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

var _return_map_id: String = ""
var _return_position: Vector2 = Vector2.ZERO
var _is_boss: bool = false
var _formation_type: String = "normal"
var _enemies: Array[Node] = []
var _battle_active: bool = false
var _awaiting_input_for: String = ""
var _earned_xp: int = 0
var _earned_gold: int = 0

@onready var _atb: Node = $ATBSystem
@onready var _state: Node = $BattleState
@onready var _enemy_area: Node2D = $EnemyArea


func _ready() -> void:
	var data: Dictionary = GameManager.transition_data
	if data.is_empty():
		push_error("BattleManager: No transition data")
		return
	_return_map_id = data.get("return_map_id", "")
	_return_position = data.get("return_position", Vector2.ZERO)
	_is_boss = data.get("is_boss", false)
	_formation_type = data.get("formation_type", "normal")
	var encounter_group: Array = data.get("encounter_group", [])
	if encounter_group.is_empty():
		push_error("BattleManager: Empty encounter group")
		_exit_battle("flee")
		return
	_setup_party()
	_setup_enemies(encounter_group, data.get("enemy_act", "act_i"))
	_atb.apply_formation(_formation_type)
	if _formation_type == "back_attack":
		for i: int in range(4):
			if not _state.get_member(i).is_empty():
				_state.swap_row(i)
	_battle_active = true
	battle_started.emit(_get_party_summary(), _get_enemy_summary())


func _process(delta: float) -> void:
	if not _battle_active or _awaiting_input_for != "":
		return
	_tick_realtime_statuses(delta)
	_atb.tick(delta)
	var queue: Array[String] = _atb.get_ready_queue()
	for id: String in queue:
		if id.begins_with("party_"):
			_awaiting_input_for = id
			_state.set_defending(id.replace("party_", "").to_int(), false)
			turn_ready.emit(id, true)
			return
		if id.begins_with("enemy_"):
			_execute_enemy_turn(id)
			_atb.reset_gauge(id)
			_check_end_conditions()
			if not _battle_active:
				return


## Called by battle UI when player selects a command.
func submit_command(command: Dictionary) -> void:
	if _awaiting_input_for == "":
		return
	var actor_id: String = _awaiting_input_for
	_awaiting_input_for = ""
	match command.get("type", ""):
		"attack":
			_do_attack(actor_id, command)
		"magic":
			_do_magic(actor_id, command)
		"item":
			_do_item(command)
		"defend":
			_do_defend(actor_id)
		"flee":
			_do_flee()
		"ability":
			_do_attack(actor_id, command)
	_atb.reset_gauge(actor_id)
	_state.tick_statuses(actor_id.replace("party_", "").to_int())
	_check_end_conditions()


func _do_attack(actor_id: String, command: Dictionary) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	var target_idx: int = command.get("target", 0)
	if target_idx < 0 or target_idx >= _enemies.size():
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


func _do_magic(actor_id: String, command: Dictionary) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = _state.get_member(slot)
	if member.is_empty():
		return
	var spell: Dictionary = command.get("spell", {})
	if not _state.spend_mp(slot, spell.get("mp_cost", 0)):
		message.emit("Not enough MP!")
		return
	var mag: int = _state.get_effective_stat(slot, "mag")
	var power: int = spell.get("power", 10)
	var element: String = spell.get("element", "non_elemental")
	message.emit(
		(
			"%s casts %s!"
			% [member.get("character_data", {}).get("name", "???"), spell.get("name", "Spell")]
		)
	)
	_gain_weave_gauge(slot, 5)
	if member.get("character_id", "") != "maren":
		_gain_weave_gauge_for_maren(10)
	var target_type: String = spell.get("target", "single_enemy")
	if target_type == "single_enemy":
		_do_magic_on_enemy(slot, mag, power, element, command.get("target", 0))
	elif target_type == "all_enemies":
		for i: int in range(_enemies.size()):
			if _enemies[i].is_alive:
				_do_magic_on_enemy(slot, mag, power, element, i)
	elif target_type == "single_ally":
		var heal_amt: int = DamageCalc.calculate_healing(mag, power)
		_state.heal(command.get("target", 0), heal_amt)
		damage_dealt.emit("party_%d" % command.get("target", 0), heal_amt, "heal")
	elif target_type == "all_allies":
		var heal_amt: int = DamageCalc.calculate_healing(mag, power)
		for i: int in range(4):
			var m: Dictionary = _state.get_member(i)
			if not m.is_empty() and m.get("is_alive", false):
				_state.heal(i, heal_amt)
				damage_dealt.emit("party_%d" % i, heal_amt, "heal")


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


func _do_item(command: Dictionary) -> void:
	var item: Dictionary = command.get("item", {})
	var target_slot: int = command.get("target", 0)
	message.emit("Used %s!" % item.get("name", "Item"))
	match item.get("effect_type", ""):
		"restore_hp":
			_state.heal(target_slot, item.get("restore_amount", 100))
			damage_dealt.emit("party_%d" % target_slot, item.get("restore_amount", 100), "heal")
		"restore_mp":
			_state.restore_mp(target_slot, item.get("restore_amount", 30))
		"cure_status":
			for sname: String in item.get("cures", []):
				_state.remove_status(target_slot, sname)
		"smoke_bomb":
			if not _is_boss:
				_exit_battle("flee")


func _do_defend(actor_id: String) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	_state.set_defending(slot, true)
	_state.set_buff(slot, "def_mult", _state.get_member(slot).get("def_mult", 1.0) + 0.5)
	message.emit(
		"%s defends!" % _state.get_member(slot).get("character_data", {}).get("name", "???")
	)


func _do_flee() -> void:
	if _is_boss:
		message.emit("Can't escape!")
		flee_result.emit(false)
		return
	var chance: int = DamageCalc.calculate_flee_chance(_get_party_avg_spd(), _get_enemy_avg_spd())
	if randi() % 100 < chance:
		message.emit("Escaped!")
		flee_result.emit(true)
		_exit_battle("flee")
	else:
		message.emit("Can't escape!")
		flee_result.emit(false)


func _execute_enemy_turn(enemy_id: String) -> void:
	var idx: int = enemy_id.replace("enemy_", "").to_int()
	if idx < 0 or idx >= _enemies.size():
		return
	var enemy: Node = _enemies[idx]
	if not enemy.is_alive:
		return
	var party_members: Array = []
	var party_rows: Array = []
	for i: int in range(4):
		var m: Dictionary = _state.get_member(i)
		party_members.append(m)
		party_rows.append(m.get("row", "front") if not m.is_empty() else "front")
	var action: Dictionary
	if _is_boss:
		action = BattleAI.select_boss_action(
			enemy.enemy_data, enemy.current_hp, party_members, party_rows
		)
	else:
		action = BattleAI.select_action(enemy.enemy_data, party_members, party_rows)
	if action.get("type", "") == "ability":
		_gain_weave_gauge_for_maren(15)
	if action.get("type", "") in ["attack", "ability"]:
		var target_slot: int = action.get("target_slot", 0)
		var target_name: String = _state.get_member(target_slot).get("character_data", {}).get(
			"name", "???"
		)
		message.emit("%s attacks %s!" % [enemy.get_display_name(), target_name])
		var result: Dictionary = BattleActions.execute_enemy_attack(_state, enemy, target_slot)
		damage_dealt.emit(
			"party_%d" % target_slot, result.get("damage", 0), result.get("type", "miss")
		)
	enemy.tick_statuses()


func _check_end_conditions() -> void:
	var all_dead: bool = true
	for enemy: Node in _enemies:
		if enemy.is_alive:
			all_dead = false
			break
	if all_dead:
		_handle_victory()
		return
	if _state.is_party_wiped():
		_handle_defeat()


func _handle_victory() -> void:
	_battle_active = false
	var drops: Array[Dictionary] = []
	for enemy: Node in _enemies:
		_earned_xp += enemy.enemy_data.get("xp", 0)
		_earned_gold += enemy.enemy_data.get("gold", 0)
		var drop: Dictionary = enemy.roll_drop()
		if drop.get("success", false):
			drops.append({"item_id": drop["item_id"]})
	victory.emit({"xp": _earned_xp, "gold": _earned_gold, "drops": drops})


func _handle_defeat() -> void:
	_battle_active = false
	defeat.emit()
	_exit_battle("faint")


func _exit_battle(result: String) -> void:
	_battle_active = false
	(
		GameManager
		. change_core_state(
			GameManager.CoreState.EXPLORATION,
			{
				"result": result,
				"map_id": _return_map_id,
				"position": _return_position,
				"earned_xp": _earned_xp,
				"earned_gold": _earned_gold,
			}
		)
	)


func _setup_party() -> void:
	for i: int in range(["edren", "cael", "lira", "torren"].size()):
		var cid: String = ["edren", "cael", "lira", "torren"][i]
		var data: Dictionary = DataManager.load_character(cid)
		if not data.is_empty():
			_state.add_member(i, data)
			_atb.add_combatant("party_%d" % i, data.get("base_stats", {}).get("spd", 10), false)


func _setup_enemies(encounter_group: Array, enemy_act: String) -> void:
	for i: int in range(encounter_group.size()):
		if not ResourceLoader.exists("res://scenes/entities/enemy.tscn"):
			push_error("BattleManager: Enemy scene not found")
			continue
		var enemy_node: Node = ENEMY_SCENE.instantiate()
		_enemy_area.add_child(enemy_node)
		enemy_node.initialize(encounter_group[i], enemy_act)
		enemy_node.position = Vector2(160.0 + (i % 3) * 48.0, 40.0 + (i / 3) * 48.0)
		_enemies.append(enemy_node)
		_atb.add_combatant("enemy_%d" % i, enemy_node.get_stats().get("spd", 10), true)


func _tick_realtime_statuses(delta: float) -> void:
	if _atb._atb_mode == "wait" and _atb._submenu_open:
		return
	if _atb._atb_mode == "patience" and (_atb._submenu_open or _atb._command_menu_open):
		return
	for i: int in range(4):
		_state.tick_realtime_statuses(i, delta)


func _gain_weave_gauge(slot: int, amount: int) -> void:
	var m: Dictionary = _state.get_member(slot)
	if m.get("character_id", "") == "maren":
		m["wg"] = mini(100, m.get("wg", 0) + amount)


func _gain_weave_gauge_for_maren(amount: int) -> void:
	for i: int in range(4):
		_gain_weave_gauge(i, amount)


func _get_party_avg_spd() -> float:
	var total: float = 0.0
	var count: int = 0
	for i: int in range(4):
		var m: Dictionary = _state.get_member(i)
		if not m.is_empty() and m.get("is_alive", false):
			total += _state.get_effective_stat(i, "spd")
			count += 1
	return total / maxf(1.0, count)


func _get_enemy_avg_spd() -> float:
	var total: float = 0.0
	var count: int = 0
	for enemy: Node in _enemies:
		if enemy.is_alive:
			total += enemy.get_stats().get("spd", 10)
			count += 1
	return total / maxf(1.0, count)


func _get_party_summary() -> Array:
	var result: Array = []
	for i: int in range(4):
		result.append(_state.get_member(i))
	return result


func _get_enemy_summary() -> Array:
	var result: Array = []
	for enemy: Node in _enemies:
		result.append(
			{
				"name": enemy.get_display_name(),
				"hp": enemy.current_hp,
				"max_hp": enemy.enemy_data.get("hp", 0)
			}
		)
	return result
