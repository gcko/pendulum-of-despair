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
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

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


func test_an_enemy_its_own_poison_kills_announces_no_wear_off() -> void:
	# A 1-HP enemy's Poison tick fells it at the end of its turn; its Silence
	# runs out on that same turn, and a fallen enemy has nothing left to lose.
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	enemy.current_hp = 1
	assert_true(enemy.apply_status("poison", 1), "precondition: Poison lands")
	assert_true(enemy.apply_status("silence", 1), "precondition: Silence lands")
	var said: Array[String] = _messages(battle)
	var turn := BattleEnemyTurn.new(
		battle, battle.get_battle_state(), battle.get_atb(), battle.get_node("EnemyArea")
	)
	enemy.apply_status("paralysis", 2)  # the turn is skipped, so only its ticks run
	turn.execute("enemy_0", battle.get_enemies(), false, 0)
	assert_false(enemy.is_alive, "precondition: the Poison felled it")
	assert_false(
		said.any(func(t: String) -> bool: return t.ends_with("wears off.")),
		"no wears-off line for a fallen enemy: %s" % str(said)
	)


## A Corrupted Fenmother in its second phase, on the turn it summons, as the
## battle loop runs it; returns the battle once an add has joined.
func _with_a_spawned_add() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": true,
		"formation_type": "normal",
		"encounter_group": ["corrupted_fenmother"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	var boss: Node = battle.get_enemies()[0]
	boss.current_hp = int(boss.enemy_data.get("hp", 1) * 0.4)  # phase_2
	var turn := BattleEnemyTurn.new(
		battle, battle.get_battle_state(), battle.get_atb(), battle.get_node("EnemyArea")
	)
	turn.execute("enemy_0", battle.get_enemies(), true, 3)
	assert_gt(battle.get_enemies().size(), 1, "precondition: the boss summoned an add")
	return battle


func test_a_spawned_add_s_poison_running_out_is_announced() -> void:
	var battle: Node = _with_a_spawned_add()
	if battle.get_enemies().size() < 2:
		return
	var add: Node = battle.get_enemies()[1]
	assert_true(add.apply_status("poison", 1), "precondition: Poison lands on the add")
	var said: Array[String] = _messages(battle)
	add.tick_statuses()
	assert_has(said, "Poison wears off.", "the add's line: %s" % str(said))


func test_a_spawned_add_waking_is_announced() -> void:
	var battle: Node = _with_a_spawned_add()
	if battle.get_enemies().size() < 2:
		return
	var add: Node = battle.get_enemies()[1]
	assert_true(add.apply_status("sleep", 3), "precondition: Sleep lands on the add")
	var said: Array[String] = _messages(battle)
	add.take_damage(1)
	assert_has(
		said, StatusEffects.wake_notice(add.get_display_name()), "the add wakes: %s" % str(said)
	)
