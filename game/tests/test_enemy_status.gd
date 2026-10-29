extends GutTest
## Enemy status behavior (GAP-003): persistent ("until cured") durations and
## wake-on-damage curing.

const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const UNTIL_CURED: int = -1


func _create_enemy() -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.initialize("ley_vermin", "act_i")
	return enemy


func test_persistent_status_is_not_ticked_away() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("poison", UNTIL_CURED), "poison applies (beast not immune)")
	for _i: int in range(5):
		enemy.tick_statuses()
	assert_true(enemy.has_status("poison"), "until-cured status survives turn ticks")


func test_turn_based_status_expires() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("slow", 2))
	enemy.tick_statuses()
	assert_true(enemy.has_status("slow"), "still active after 1 of 2 turns")
	enemy.tick_statuses()
	assert_false(enemy.has_status("slow"), "expires after 2 turns")


func test_taking_damage_cures_sleep() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("sleep", UNTIL_CURED))
	enemy.take_damage(3)
	assert_false(enemy.has_status("sleep"), "damage wakes a sleeping enemy")


func test_taking_damage_does_not_cure_poison() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("poison", UNTIL_CURED))
	enemy.take_damage(3)
	assert_true(enemy.has_status("poison"), "poison is not cured by damage")


func test_zero_damage_does_not_wake() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("sleep", UNTIL_CURED))
	enemy.take_damage(0)
	assert_true(enemy.has_status("sleep"), "0 damage must not wake (no real hit)")


func test_dot_damage_does_not_wake_sleep() -> void:
	# take_damage(amount, wakes=false) is the DoT path — must not cure.
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("sleep", UNTIL_CURED))
	enemy.take_damage(3, false)
	assert_true(enemy.has_status("sleep"), "poison/burn ticks must not wake Sleep")


func test_dot_damage_does_not_cure_confusion() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("confusion", 3))
	enemy.take_damage(3, false)
	assert_true(
		enemy.has_status("confusion"), "a poisoned+confused enemy's own tick keeps Confusion"
	)


# --- Stop runs in real-time seconds (#246 slice 1) ---


func test_stop_wears_off_after_three_seconds_of_battle_time() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("stop", 3), "a beast can be Stopped")
	enemy.tick_realtime_statuses(2.9)
	assert_true(enemy.has_status("stop"), "2.9 s is not 3")
	watch_signals(enemy)
	enemy.tick_realtime_statuses(0.2)
	assert_false(enemy.has_status("stop"), "gone once 3 s have run")
	assert_signal_emitted_with_parameters(enemy, "status_removed", ["stop"])


func test_stop_is_not_counted_down_by_turns() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("stop", 3))
	for _i: int in range(5):
		enemy.tick_statuses()
	assert_true(enemy.has_status("stop"), "turn ends do not wear Stop away")


func test_seconds_do_not_count_down_a_turn_based_status() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("slow", 1))
	enemy.tick_realtime_statuses(60.0)
	assert_true(enemy.has_status("slow"), "a minute of battle time is not a turn")


# --- Petrify takes an enemy off the field (#246 slice 6) ---


func test_a_petrified_enemy_is_untargetable_until_cured() -> void:
	var enemy: Enemy = _create_enemy()
	assert_true(enemy.apply_status("petrify", UNTIL_CURED))
	assert_true(enemy.get_meta("untargetable", false), "a statue cannot be targeted")
	enemy.remove_status("petrify")
	assert_false(enemy.get_meta("untargetable", false), "cured, it can be again")
