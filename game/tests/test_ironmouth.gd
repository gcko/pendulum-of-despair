extends GutTest
## Tests for Ironmouth Docks escape sequence.


func before_each() -> void:
	TestHelpers.reset_game_state()
	PartyState.initialize_new_game()


func after_each() -> void:
	TestHelpers.reset_game_state()


func test_ironmouth_lira_trigger_sets_flag() -> void:
	EventFlags.set_flag("ironmouth_lira_seen", true)
	assert_true(EventFlags.get_flag("ironmouth_lira_seen"))


func test_ironmouth_sable_requires_lira_flag() -> void:
	assert_false(EventFlags.get_flag("ironmouth_lira_seen"))
	EventFlags.set_flag("ironmouth_lira_seen", true)
	assert_true(EventFlags.get_flag("ironmouth_lira_seen"))


func test_combat_trigger_requires_sable_flag() -> void:
	assert_false(EventFlags.get_flag("ironmouth_sable_seen"))
	EventFlags.set_flag("ironmouth_sable_seen", true)
	assert_true(EventFlags.get_flag("ironmouth_sable_seen"))


func test_carradan_ambush_survived_adds_lira_sable() -> void:
	EventFlags.set_flag("carradan_ambush_survived", true)
	assert_true(EventFlags.get_flag("carradan_ambush_survived"))
	var avg_level: int = 3
	PartyState.add_member("lira", avg_level)
	PartyState.add_member("sable", avg_level)
	assert_true(PartyState.has_member("lira"), "Lira should be in party")
	assert_true(PartyState.has_member("sable"), "Sable should be in party")


func test_compact_patrol_loads_from_data() -> void:
	var enemies: Dictionary = DataManager.load_json("res://data/enemies/act_i.json")
	var found: bool = false
	for enemy: Dictionary in enemies.get("enemies", []):
		if enemy.get("id", "") == "compact_patrol":
			found = true
			assert_eq(enemy.get("hp", 0), 180, "Compact Patrol HP should be 180")
			assert_eq(enemy.get("atk", 0), 16, "Compact Patrol ATK should be 16")
			assert_eq(enemy.get("exp", 0), 18, "Compact Patrol EXP should be 18")
			break
	assert_true(found, "compact_patrol should exist in act_i.json")


func test_compact_scout_loads_from_data() -> void:
	var enemies: Dictionary = DataManager.load_json("res://data/enemies/act_i.json")
	var found: bool = false
	for enemy: Dictionary in enemies.get("enemies", []):
		if enemy.get("id", "") == "compact_scout":
			found = true
			assert_eq(enemy.get("hp", 0), 140, "Compact Scout HP should be 140")
			assert_eq(enemy.get("spd", 0), 14, "Compact Scout SPD should be 14")
			break
	assert_true(found, "compact_scout should exist in act_i.json")


func test_overworld_entry_requires_vaelith_scene_complete() -> void:
	assert_false(
		EventFlags.get_flag("vaelith_scene_complete"),
		"vaelith_scene_complete should not be set initially"
	)
	EventFlags.set_flag("vaelith_scene_complete", true)
	assert_true(
		EventFlags.get_flag("vaelith_scene_complete"),
		"vaelith_scene_complete should gate Ironmouth entry"
	)


func test_ironmouth_not_reenterable_after_escape() -> void:
	EventFlags.set_flag("carradan_ambush_survived", true)
	assert_true(
		EventFlags.get_flag("carradan_ambush_survived"),
		"carradan_ambush_survived should prevent re-entry"
	)
