extends GutTest
## An enemy's Poison or Silence running out is announced with the line a party
## member's gets (#246): "Poison wears off." and "Silence wears off.", from
## battle-dialogue.md § Status Effect Notifications through
## StatusEffects.wears_off_notice. Every other status runs out silently, as on
## the party side, and a status taken off any other way (a waking hit, a cure) says no
## "wears off" line.
##
## An enemy's turn-based statuses count down at the end of its own turn
## (enemy.tick_statuses, which the enemy turn calls), and a realtime one (Stop)
## on the battle seconds (enemy.tick_realtime_statuses, which the loop calls),
## so those are the clocks driven here. What is read is the battle's message
## line, what the player sees.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


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
	_booted = battle
	return battle


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


## Land [param status] on the enemy for one of its turns, then end that turn.
func _runs_out(status: String) -> Array[String]:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	assert_true(enemy.apply_status(status, 1), "precondition: %s lands" % status)
	var said: Array[String] = _messages(battle)
	enemy.tick_statuses()
	assert_false(enemy.has_status(status), "precondition: %s ran out" % status)
	return said


func test_an_enemy_s_poison_running_out_is_announced() -> void:
	assert_eq(_runs_out("poison"), ["Poison wears off."] as Array[String])


func test_an_enemy_s_silence_running_out_is_announced() -> void:
	assert_eq(_runs_out("silence"), ["Silence wears off."] as Array[String])


func test_an_enemy_s_slow_runs_out_silently() -> void:
	assert_eq(_runs_out("slow"), [] as Array[String], "Slow has no wears-off line")


func test_an_enemy_s_stop_runs_out_silently() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	assert_true(enemy.apply_status("stop", 1), "precondition: Stop lands")
	var said: Array[String] = _messages(battle)
	enemy.tick_realtime_statuses(1.5)
	assert_false(enemy.has_status("stop"), "precondition: Stop ran out")
	assert_eq(said, [] as Array[String], "Stop has no wears-off line")


func test_an_enemy_s_poison_taken_off_early_says_no_wears_off_line() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	enemy.apply_status("poison", 3)
	var said: Array[String] = _messages(battle)
	enemy.remove_status("poison")
	assert_false(enemy.has_status("poison"), "precondition: the Poison is gone")
	assert_does_not_have(said, "Poison wears off.", "it did not run out: %s" % str(said))
