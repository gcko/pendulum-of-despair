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
