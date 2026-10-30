extends GutTest
## A party wipe ends the battle once.
##
## When the party is already wiped as a frame starts, the frame's end-condition
## check reports the defeat. Victory marked the battle resolved there, which is
## what stops the frame from going on; defeat did not, so an enemy that was ready
## in the same frame still acted and the battle reported the defeat a second time.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

var _booted: Node = null


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}


func _boot() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	battle.set_process(false)
	_booted = battle
	return battle


func test_a_wiped_party_with_an_enemy_ready_is_defeated_exactly_once() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	for slot: int in range(4):
		if not state.get_member(slot).is_empty():
			state.take_damage(slot, 999999)
	# Array counter, not an int: GDScript lambdas capture locals by value.
	var defeats: Array[int] = []
	battle.defeat.connect(
		func() -> void:
			defeats.append(1)
			# Guard: keep exit_battle from starting a real scene transition.
			battle.set("_battle_active", false)
	)
	battle.get_atb().set_gauge("enemy_0", ATBSystem.GAUGE_MAX)

	battle._process(0.0)

	assert_eq(defeats.size(), 1, "one wipe, one defeat")
