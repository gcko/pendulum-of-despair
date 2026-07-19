extends GutTest
## Tests for EncounterSystem static helpers.

const ES = preload("res://scripts/combat/encounter_system.gd")
const TestHelpers = preload("res://tests/test_helpers.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


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


func test_roll_increment_location_mod_scales() -> void:
	# Tunnel Map fixture (dungeons-city.md): increment 120 x0.5 => 60
	var result: int = ES.roll_increment(120, 1.0, 1.0, 0.5)
	assert_eq(result, 60, "location_mod should scale increment")


func test_roll_increment_all_four_factors_floor() -> void:
	# floor(48 * 1.2 * 0.5 * 0.5) = floor(14.4) = 14
	var result: int = ES.roll_increment(48, 1.2, 0.5, 0.5)
	assert_eq(result, 14, "four-factor product should floor to 14")


func test_roll_increment_location_mod_defaults_to_identity() -> void:
	# Omitting location_mod preserves the pre-GAP-025 behavior
	assert_eq(ES.roll_increment(120, 1.1, 0.5), 66, "3-arg call unchanged")


func test_get_location_modifier_no_entries_is_identity() -> void:
	assert_eq(ES.get_location_modifier({}), 1.0, "no location_mods key = 1.0")


func test_get_location_modifier_flag_unset_is_identity() -> void:
	var config: Dictionary = {"location_mods": [{"flag": "tunnel_map_owned", "modifier": 0.5}]}
	assert_eq(ES.get_location_modifier(config), 1.0, "unset flag should not apply")


func test_get_location_modifier_flag_set_applies() -> void:
	EventFlags.set_flag("tunnel_map_owned", true)
	var config: Dictionary = {"location_mods": [{"flag": "tunnel_map_owned", "modifier": 0.5}]}
	assert_almost_eq(ES.get_location_modifier(config), 0.5, 0.01, "set flag applies x0.5")


func test_get_location_modifier_entries_stack_multiplicatively() -> void:
	EventFlags.set_flag("tunnel_map_owned", true)
	EventFlags.set_flag("kole_patrol_timing", true)
	var config: Dictionary = {
		"location_mods":
		[
			{"flag": "tunnel_map_owned", "modifier": 0.5},
			{"flag": "kole_patrol_timing", "modifier": 0.5},
		]
	}
	assert_almost_eq(ES.get_location_modifier(config), 0.25, 0.01, "mods stack x0.25")


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


func test_apply_preemptive_bonus_normalizes_all_terrains() -> void:
	# combat-formulas.md: +25pp normalizes every terrain row to 62.5/0/37.5
	var terrains: Array = [
		{"normal": 87.5, "back_attack": 0.0, "preemptive": 12.5},
		{"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5},
		{"normal": 68.75, "back_attack": 18.75, "preemptive": 12.5},
		{"normal": 62.5, "back_attack": 25.0, "preemptive": 12.5},
	]
	for rates: Dictionary in terrains:
		var result: Dictionary = ES.apply_preemptive_bonus(rates, 25.0)
		assert_almost_eq(float(result.get("preemptive")), 37.5, 0.01, "preemptive -> 37.5")
		assert_almost_eq(float(result.get("back_attack")), 0.0, 0.01, "back attack -> 0")
		assert_almost_eq(float(result.get("normal")), 62.5, 0.01, "normal -> 62.5")


func test_apply_preemptive_bonus_zero_is_identity() -> void:
	var rates: Dictionary = {"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5}
	var result: Dictionary = ES.apply_preemptive_bonus(rates, 0.0)
	assert_almost_eq(float(result.get("preemptive")), 12.5, 0.01, "no bonus, no shift")
	assert_almost_eq(float(result.get("back_attack")), 12.5, 0.01, "back attack unchanged")


func test_apply_preemptive_bonus_never_goes_negative() -> void:
	var rates: Dictionary = {"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5}
	var result: Dictionary = ES.apply_preemptive_bonus(rates, 200.0)
	assert_almost_eq(float(result.get("back_attack")), 0.0, 0.01, "clamped at zero")
	assert_almost_eq(float(result.get("normal")), 0.0, 0.01, "clamped at zero")
	assert_almost_eq(float(result.get("preemptive")), 100.0, 0.01, "everything shifted")


func test_get_preemptive_bonus_accessory_slot() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "preemptive_charm"}},
	]
	assert_almost_eq(ES.get_preemptive_bonus(party), 25.0, 0.01, "charm in accessory = +25pp")


func test_get_preemptive_bonus_crystal_slot() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"crystal": "preemptive_charm"}},
	]
	assert_almost_eq(ES.get_preemptive_bonus(party), 25.0, 0.01, "charm in crystal = +25pp")


func test_get_preemptive_bonus_does_not_stack() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "preemptive_charm"}},
		{"character_id": "cael", "equipment": {"accessory": "preemptive_charm"}},
	]
	assert_almost_eq(ES.get_preemptive_bonus(party), 25.0, 0.01, "two charms still +25pp")


func test_get_preemptive_bonus_none_equipped() -> void:
	var party: Array[Dictionary] = [{"character_id": "edren", "equipment": {}}]
	assert_almost_eq(ES.get_preemptive_bonus(party), 0.0, 0.01, "no charm = no bonus")
