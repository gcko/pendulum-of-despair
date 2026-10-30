extends GutTest
## A fallen party member's statuses run out without a word (#246).
##
## battle-dialogue.md § Status Effect Notifications gives "Poison wears off."
## and "Silence wears off." for a status running out (#515). An enemy felled by
## its own Poison or Regen tick says neither afterwards (#525); the party
## mirrors it: a member who faints to their own Poison tick, with statuses due
## to run out on that same turn, ends the turn with no wear-off line.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Cael in slot 1 carries the statuses.
const TARGET: int = 1

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


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


func test_a_member_felled_by_their_own_poison_says_no_wears_off_line() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.get_member(TARGET)["current_hp"] = 1
	# Both statuses are one turn from running out when the tick fells Cael.
	state.apply_status(TARGET, "poison", "turns", 1.0)
	state.apply_status(TARGET, "silence", "turns", 1.0)
	var lines: Array[String] = _messages(battle)

	state.tick_statuses(TARGET)

	assert_false(state.get_member(TARGET)["is_alive"], "precondition: the Poison tick felled Cael")
	assert_does_not_have(lines, "Poison wears off.", "a fallen member's Poison ends in silence")
	assert_does_not_have(lines, "Silence wears off.", "and so does their Silence")
