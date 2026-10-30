extends GutTest
## Torren's Spirit Favor outside one battle (GAP-002, slice 158e of #158): a new
## game starting every spirit at 0, the 0-3 bounds on every write, and Favor
## surviving a save and a load.
##
## Design law: abilities.md § Torren — Spiritcall ("Each spirit starts at Favor
## 0", "Max Favor 3", "Favor is persistent across battles"), save-system.md
## § 3.11 and save-system.md § 10: spirit_favor is an additive optional field,
## so a save without it loads with every spirit at 0 and stays on version 2.

const TEST_SLOT: int = 2


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	SaveManager.delete_slot(TEST_SLOT)
	PartyState.initialize_new_game()


func after_each() -> void:
	SaveManager.delete_slot(TEST_SLOT)
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _favor(spirit: String) -> int:
	return int(PartyState.spirit_favor.get(spirit, 0))


# --- A new game ---


func test_a_new_game_starts_every_spirit_at_favor_zero() -> void:
	PartyState.spirit_favor = {"thornveil": 2, "greyveil": 3}
	PartyState.initialize_new_game()
	for spirit: String in ["thornveil", "dewfall", "ember_wing", "stoneheart", "greyveil"]:
		assert_eq(_favor(spirit), 0, spirit)


# --- Bounds ---


func test_favor_holds_to_zero_through_three_whoever_writes_it() -> void:
	PartyState.spirit_favor = {"thornveil": 7, "dewfall": -2, "ember_wing": 2}
	assert_eq(_favor("thornveil"), 3, "capped at 3")
	assert_eq(_favor("dewfall"), 0, "never below 0")
	assert_eq(_favor("ember_wing"), 2, "in range is kept")


# --- Save and load ---


func test_favor_is_written_to_the_save() -> void:
	PartyState.spirit_favor = {"dewfall": 2}
	var saved: Dictionary = PartyState.build_save_data()
	assert_eq(int(saved.get("spirit_favor", {}).get("dewfall", -1)), 2)
	assert_eq(int(saved["meta"]["version"]), 2, "still save version 2")


func test_favor_survives_a_save_and_a_load() -> void:
	PartyState.spirit_favor = {"thornveil": 1, "greyveil": 3}
	assert_true(SaveManager.save_game(TEST_SLOT), "saved")
	PartyState.spirit_favor = {}
	var loaded: Dictionary = SaveManager.load_game(TEST_SLOT)
	assert_false(loaded.has("error"), "loads cleanly")
	PartyState.load_from_save(loaded)
	assert_eq(_favor("thornveil"), 1)
	assert_eq(_favor("greyveil"), 3)
	assert_eq(_favor("dewfall"), 0, "a spirit never raised stays at 0")


func test_a_save_from_before_favor_was_saved_loads_every_spirit_at_zero() -> void:
	var data: Dictionary = PartyState.build_save_data()
	data.erase("spirit_favor")
	PartyState.spirit_favor = {"thornveil": 3}
	PartyState.load_from_save(data)
	assert_eq(_favor("thornveil"), 0)


func test_a_save_holding_malformed_favor_loads_it_as_zero() -> void:
	var data: Dictionary = PartyState.build_save_data()
	data["spirit_favor"] = "three"
	PartyState.spirit_favor = {"thornveil": 3}
	PartyState.load_from_save(data)
	assert_eq(_favor("thornveil"), 0, "a non-dictionary block reads as no Favor")
	data["spirit_favor"] = {"thornveil": "lots", "dewfall": 9}
	PartyState.load_from_save(data)
	assert_eq(_favor("thornveil"), 0, "a non-number reads as 0")
	assert_eq(_favor("dewfall"), 3, "a number past the cap is held to 3")
