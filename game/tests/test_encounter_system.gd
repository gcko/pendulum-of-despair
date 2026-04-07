extends GutTest
## Tests for EncounterSystem static helpers.

const ES = preload("res://scripts/combat/encounter_system.gd")


func test_check_encounter_zero_counter_never_triggers() -> void:
	# With counter 0, floor(0/256) = 0, roll is 0-255, never < 0
	var triggered: bool = false
	for i: int in range(100):
		if ES.check_encounter(0):
			triggered = true
	assert_false(triggered, "zero counter should never trigger")


func test_check_encounter_high_counter_always_triggers() -> void:
	# With counter 65536, floor(65536/256) = 256, roll 0-255 always < 256
	var triggered: bool = true
	for i: int in range(100):
		if not ES.check_encounter(65536):
			triggered = false
	assert_true(triggered, "very high counter should always trigger")


func test_check_encounter_returns_bool() -> void:
	var result: bool = ES.check_encounter(1000)
	assert_typeof(result, TYPE_BOOL, "should return bool")


func test_roll_increment_basic() -> void:
	# floor(120 * 1.0 * 1.0) = 120
	var result: int = ES.roll_increment(120, 1.0, 1.0)
	assert_eq(result, 120, "basic increment should be base value")


func test_roll_increment_with_modifiers() -> void:
	# floor(120 * 1.1 * 0.5) = floor(66.0) = 66
	var result: int = ES.roll_increment(120, 1.1, 0.5)
	assert_eq(result, 66, "modifiers should scale increment")


func test_roll_increment_zero_base() -> void:
	var result: int = ES.roll_increment(0, 1.0, 1.0)
	assert_eq(result, 0, "zero base should produce zero")


func test_select_encounter_group_returns_dict() -> void:
	var groups: Array = [
		{"enemies": ["ley_vermin"], "weight": 50.0},
		{"enemies": ["unstable_crystal"], "weight": 50.0},
	]
	var result: Dictionary = ES.select_encounter_group(groups)
	assert_has(result, "enemies", "result should have enemies key")


func test_select_encounter_group_empty_returns_empty() -> void:
	var result: Dictionary = ES.select_encounter_group([])
	assert_true(result.is_empty(), "empty groups should return empty dict")


func test_select_encounter_group_single_always_returns_it() -> void:
	var groups: Array = [{"enemies": ["ley_vermin"], "weight": 100.0}]
	for i: int in range(20):
		var result: Dictionary = ES.select_encounter_group(groups)
		assert_eq(result.get("enemies", []), ["ley_vermin"], "single group always selected")


func test_roll_formation_returns_valid_string() -> void:
	var rates: Dictionary = {"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5}
	var result: String = ES.roll_formation(rates)
	assert_true(
		result in ["normal", "back_attack", "preemptive"],
		"should return valid formation type",
	)


func test_roll_formation_all_normal() -> void:
	var rates: Dictionary = {"normal": 100.0, "back_attack": 0.0, "preemptive": 0.0}
	for i: int in range(20):
		assert_eq(ES.roll_formation(rates), "normal", "100% normal should always be normal")


func test_roll_formation_empty_defaults_normal() -> void:
	assert_eq(ES.roll_formation({}), "normal", "empty rates should default to normal")


func test_get_accessory_modifier_no_equipment() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {}},
	]
	assert_eq(ES.get_accessory_modifier(party), 1.0, "no modifier items = 1.0")


func test_get_accessory_modifier_ward_talisman() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "ward_talisman"}},
	]
	assert_almost_eq(ES.get_accessory_modifier(party), 0.5, 0.01, "ward talisman = 0.5")


func test_get_accessory_modifier_lure_talisman() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "lure_talisman"}},
	]
	assert_almost_eq(ES.get_accessory_modifier(party), 2.0, 0.01, "lure talisman = 2.0")


func test_get_accessory_modifier_ward_and_lure_stack() -> void:
	# Two members: one with ward, one with lure => 0.5 * 2.0 = 1.0
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "ward_talisman"}},
		{"character_id": "cael", "equipment": {"accessory": "lure_talisman"}},
	]
	assert_almost_eq(ES.get_accessory_modifier(party), 1.0, 0.01, "ward + lure = 1.0")


func test_get_accessory_modifier_ward_and_cloak_dont_stack() -> void:
	# Ward and Infiltrator's Cloak don't stack (same effect)
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "ward_talisman"}},
		{"character_id": "cael", "equipment": {"accessory": "infiltrators_cloak"}},
	]
	assert_almost_eq(
		ES.get_accessory_modifier(party),
		0.5,
		0.01,
		"ward + cloak should not stack below 0.5",
	)
