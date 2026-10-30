extends GutTest
## Torren's Spirit Favor outside one battle (GAP-002, slice 158e of #158): a new
## game starting every spirit at 0, the 0-3 bounds on every write, and Favor
## surviving a save and a load.
##
## Design law: abilities.md § Torren — Spiritcall ("Each spirit starts at Favor
## 0", "Max Favor 3", "Favor is persistent across battles"), save-system.md
## § 3.11 and save-system.md § 10: spirit_favor is an additive optional field,
## so a save without it loads with every spirit at 0 and stays on version 2;
## present, it is type-checked like any field (save-system.md § 11).

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


func test_a_save_whose_favor_block_is_not_an_object_is_refused_as_corrupt() -> void:
	_write_slot_with_favor("three")
	assert_eq(SaveManager.load_game(TEST_SLOT).get("error", ""), "invalid")
	assert_push_error("Invalid save data", "reported, not loaded as no Favor")


func test_a_save_holding_a_non_number_for_a_spirit_is_refused_as_corrupt() -> void:
	_write_slot_with_favor({"thornveil": "lots", "dewfall": 1})
	assert_eq(SaveManager.load_game(TEST_SLOT).get("error", ""), "invalid")
	assert_push_error("Invalid save data")


func test_a_number_past_the_cap_loads_held_to_three() -> void:
	_write_slot_with_favor({"dewfall": 9, "greyveil": -4})
	var loaded: Dictionary = SaveManager.load_game(TEST_SLOT)
	assert_false(loaded.has("error"), "a number is the right shape")
	PartyState.load_from_save(loaded)
	assert_eq(_favor("dewfall"), 3)
	assert_eq(_favor("greyveil"), 0)


## Save to TEST_SLOT, then rewrite the file on disk with [param favor] as its
## spirit_favor block, as a hand-edited or damaged save would carry it.
func _write_slot_with_favor(favor: Variant) -> void:
	assert_true(SaveManager.save_game(TEST_SLOT), "saved")
	var path: String = SaveManager.SAVE_DIR + "slot_%d.json" % TEST_SLOT
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	data["spirit_favor"] = favor
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
