extends GutTest
## Tests for EncounterHandler wiring: act scaling, location modifiers,
## enemy_act selection, and formation overrides in random encounters.
## Canon: combat-formulas.md § Danger Counter / § Battle Formations.

const EH = preload("res://scripts/core/encounter_handler.gd")
const TestHelpers = preload("res://tests/test_helpers.gd")

## Deterministic first-step configs: any counter below 256 yields
## floor(counter / 256) = 0, so check_encounter can never trigger and
## no test below depends on the RNG stream.
const OPEN_RATES: Dictionary = {"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5}


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()
	randomize()


func test_process_step_applies_act_scale() -> void:
	# Act II: int(148 * 1.1) = 162 (combat-formulas.md act table x1.1)
	EventFlags.set_flag("act_ii_started", true)
	var party: Array[Dictionary] = []
	var config: Dictionary = {"danger_increment": 148}
	var result: int = EH.process_step(config, 0, party)
	assert_eq(result, 162, "Act II scale should apply to the increment")


func test_process_step_act_i_unscaled() -> void:
	var party: Array[Dictionary] = []
	var config: Dictionary = {"danger_increment": 148}
	var result: int = EH.process_step(config, 0, party)
	assert_eq(result, 148, "Act I increment should be the base value")


func test_process_step_applies_location_mod() -> void:
	# Tunnel Map fixture: increment 120 x0.5 => 60 (dungeons-city.md)
	EventFlags.set_flag("tunnel_map_owned", true)
	var party: Array[Dictionary] = []
	var config: Dictionary = {
		"danger_increment": 120,
		"location_mods": [{"flag": "tunnel_map_owned", "modifier": 0.5}],
	}
	var result: int = EH.process_step(config, 0, party)
	assert_eq(result, 60, "location_mod should halve the increment")


func test_build_random_encounter_enemy_act_follows_story_act() -> void:
	EventFlags.set_flag("act_ii_started", true)
	var config: Dictionary = {
		"groups": [{"format": 1, "enemies": ["iron_beetle"], "weight": 100.0}],
		"formation_rates": OPEN_RATES,
	}
	var transition: Dictionary = EH.build_random_encounter(config, "overworld", Vector2.ZERO)
	assert_eq(transition.get("enemy_act", ""), "act_ii", "enemy_act should follow story act")


func test_build_random_encounter_enemy_act_defaults_act_i() -> void:
	var config: Dictionary = {
		"groups": [{"format": 1, "enemies": ["ley_vermin"], "weight": 100.0}],
		"formation_rates": OPEN_RATES,
	}
	var transition: Dictionary = EH.build_random_encounter(config, "overworld", Vector2.ZERO)
	assert_eq(transition.get("enemy_act", ""), "act_i", "no flags should mean act_i enemies")


func test_build_random_encounter_charm_reaches_the_roll() -> void:
	# Charm shifts back_attack 25 -> preemptive: rates become 100%
	# preemptive, so ANY roll must return preemptive (deterministic).
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "preemptive_charm"}},
	]
	var config: Dictionary = {
		"groups": [{"format": 1, "enemies": ["ley_vermin"], "weight": 100.0}],
		"formation_rates": {"normal": 0.0, "back_attack": 25.0, "preemptive": 75.0},
	}
	var transition: Dictionary = EH.build_random_encounter(config, "overworld", Vector2.ZERO, party)
	assert_eq(transition.get("formation_type", ""), "preemptive", "charm bonus must reach roll")


func test_build_random_encounter_sables_coin_forces_preemptive() -> void:
	EventFlags.set_flag("sables_coin_active", true)
	var config: Dictionary = {
		"groups": [{"format": 1, "enemies": ["ley_vermin"], "weight": 100.0}],
		"formation_rates": {"normal": 100.0, "back_attack": 0.0, "preemptive": 0.0},
	}
	var transition: Dictionary = EH.build_random_encounter(config, "overworld", Vector2.ZERO)
	assert_eq(transition.get("formation_type", ""), "preemptive", "coin overrides the roll")
	assert_false(
		bool(EventFlags.get_flag("sables_coin_active")),
		"coin is consumed when it forces preemptive",
	)


func test_build_random_encounter_without_coin_rolls_normally() -> void:
	var config: Dictionary = {
		"groups": [{"format": 1, "enemies": ["ley_vermin"], "weight": 100.0}],
		"formation_rates": {"normal": 100.0, "back_attack": 0.0, "preemptive": 0.0},
	}
	var transition: Dictionary = EH.build_random_encounter(config, "overworld", Vector2.ZERO)
	assert_eq(transition.get("formation_type", ""), "normal", "no coin means the roll stands")


func test_boss_path_never_touches_sables_coin() -> void:
	# combat-formulas.md: the coin "does not work on bosses". The boss
	# transition hardcodes normal formation and must never read or clear
	# the flag, so a coin popped before a boss door is not wasted.
	var file: FileAccess = FileAccess.open(
		"res://scripts/core/exploration_zone_handler.gd", FileAccess.READ
	)
	var text: String = file.get_as_text()
	file.close()
	assert_true(text.contains('"formation_type": "normal"'), "boss formation stays normal")
	assert_false(text.contains("sables_coin"), "boss path must not consume the coin")


func test_full_trigger_path_builds_zone_transition() -> void:
	# End-to-end over a REAL overworld zone config: danger 65536 makes
	# floor(counter/256) >= 256, so ANY roll triggers (deterministic).
	var encounters: Dictionary = DataManager.load_encounters("overworld")
	var config: Dictionary = ZoneResolver.find_entry(
		"thornmere_wilds", encounters.get("zones", []), "zone_id"
	)
	assert_false(config.is_empty(), "thornmere_wilds config should exist")
	var party: Array[Dictionary] = []
	var step: int = EH.process_step(config, 65536, party)
	assert_eq(step, -1, "saturated counter must always trigger an encounter")
	var transition: Dictionary = EH.build_random_encounter(config, "overworld", Vector2.ZERO)
	assert_false(transition.is_empty(), "transition should be built")
	assert_eq(transition.get("enemy_act", ""), "act_i", "Act I party gets act_i tables")
	assert_eq(transition.get("encounter_source", ""), "random")
	var group: Array = transition.get("encounter_group", [])
	assert_gt(group.size(), 0, "a real enemy group should be selected")
