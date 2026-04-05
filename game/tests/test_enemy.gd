extends GutTest
## Tests for Enemy battle entity.
##
## Verifies data loading, HP/MP tracking, elemental queries,
## status immunity, damage/healing, and drop/steal resolution.

const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")


func _create_enemy():
	var enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	return enemy


func test_initialize_loads_data() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	assert_eq(enemy.enemy_id, "ley_vermin", "enemy_id should be set")
	assert_false(enemy.enemy_data.is_empty(), "enemy_data should be loaded")


func test_current_hp_matches_base() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var base_hp: int = enemy.enemy_data.get("hp", 0)
	assert_eq(enemy.current_hp, base_hp, "current_hp should match base")
	assert_true(enemy.is_alive, "enemy should be alive")


func test_get_stats_returns_expected_keys() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var stats: Dictionary = enemy.get_stats()
	assert_has(stats, "hp", "stats should have hp")
	assert_has(stats, "atk", "stats should have atk")
	assert_has(stats, "def", "stats should have def")
	assert_has(stats, "spd", "stats should have spd")


func test_get_type_returns_string() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var enemy_type: String = enemy.get_type()
	assert_ne(enemy_type, "", "type should not be empty")


func test_take_damage_reduces_hp() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var hp_before: int = enemy.current_hp
	enemy.take_damage(10)
	assert_eq(enemy.current_hp, hp_before - 10, "HP should decrease")


func test_take_damage_clamps_to_zero() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	enemy.take_damage(99999)
	assert_eq(enemy.current_hp, 0, "HP should clamp to 0")
	assert_false(enemy.is_alive, "enemy should be dead")


func test_died_signal_emitted() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	watch_signals(enemy)
	enemy.take_damage(99999)
	assert_signal_emitted(enemy, "died", "died signal should fire")


func test_heal_clamps_to_max() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var max_hp: int = enemy.enemy_data.get("hp", 0)
	enemy.take_damage(10)
	enemy.heal(99999)
	assert_eq(enemy.current_hp, max_hp, "HP should clamp to max")


func test_element_weakness() -> void:
	var enemy = _create_enemy()
	# unstable_crystal has weaknesses: ["frost"]
	enemy.initialize("unstable_crystal", "act_i")
	assert_eq(
		enemy.get_element_multiplier("frost"),
		1.5,
		"Weakness to frost should return 1.5x",
	)


func test_element_neutral() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	assert_eq(
		enemy.get_element_multiplier("nonexistent_element"),
		1.0,
		"Unknown element should return 1.0x",
	)


func test_status_immunity_by_type() -> void:
	var enemy = _create_enemy()
	# Construct type should be immune to poison
	enemy.enemy_data = {"type": "construct", "status_immunities": []}
	assert_true(
		enemy.is_immune_to_status("poison"),
		"Construct should be immune to poison",
	)


func test_apply_status_success() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var result: bool = enemy.apply_status("slow", 3)
	assert_true(result, "Status should apply")
	assert_true(enemy.has_status("slow"), "slow should be active")


func test_apply_status_immune() -> void:
	var enemy = _create_enemy()
	enemy.enemy_data = {"type": "undead", "status_immunities": []}
	var result: bool = enemy.apply_status("poison", 3)
	assert_false(result, "Undead should be immune to poison")


func test_tick_statuses_removes_expired() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	enemy.apply_status("slow", 2)
	assert_true(enemy.has_status("slow"), "slow should be active")
	enemy.tick_statuses()
	assert_true(enemy.has_status("slow"), "slow should survive first tick")
	enemy.tick_statuses()
	assert_false(enemy.has_status("slow"), "slow should expire after second tick")


func test_damage_taken_signal_emitted() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	watch_signals(enemy)
	enemy.take_damage(10)
	assert_signal_emitted(enemy, "damage_taken", "damage_taken signal should fire")


func test_roll_steal_returns_dict() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var result: Dictionary = enemy.roll_steal("common")
	assert_has(result, "item_id", "result should have item_id")
	assert_has(result, "success", "result should have success")


func test_roll_drop_returns_dict() -> void:
	var enemy = _create_enemy()
	enemy.initialize("ley_vermin", "act_i")
	var result: Dictionary = enemy.roll_drop()
	assert_has(result, "item_id", "result should have item_id")
	assert_has(result, "success", "result should have success")
