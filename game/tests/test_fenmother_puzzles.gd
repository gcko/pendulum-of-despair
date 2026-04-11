extends GutTest
## Tests for Fenmother's Hollow Phase A2b puzzle systems.


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	EventFlags.clear_all()


func after_each() -> void:
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	EventFlags.clear_all()


# --- Puzzle State API ---


func test_set_and_get_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high")
	assert_true(val, "should return true after setting")


func test_get_puzzle_state_default() -> void:
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "nonexistent", false)
	assert_false(val, "should return default when key not set")


func test_get_puzzle_state_default_no_dungeon() -> void:
	var val: Variant = PartyState.get_puzzle_state("unknown_dungeon", "key", 42)
	assert_eq(val, 42, "should return default when dungeon not in puzzle_state")


func test_clear_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("other_dungeon", "valve_open", true)
	PartyState.clear_puzzle_state("fenmothers_hollow")
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_false(val, "cleared dungeon state should return default")
	var other: Variant = PartyState.get_puzzle_state("other_dungeon", "valve_open", false)
	assert_true(other, "other dungeon state should be unaffected")


func test_puzzle_state_save_roundtrip() -> void:
	PartyState.initialize_new_game()
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "plant_restored", false)
	var save_data: Dictionary = PartyState.build_save_data()
	assert_true(save_data.has("puzzle_state"), "save should include puzzle_state")
	PartyState.puzzle_state.clear()
	PartyState.load_from_save(save_data)
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_true(val, "wheel_1_high should survive save/load")


func test_puzzle_state_load_handles_missing_key() -> void:
	PartyState.initialize_new_game()
	var save_data: Dictionary = PartyState.build_save_data()
	save_data.erase("puzzle_state")
	PartyState.load_from_save(save_data)
	assert_true(PartyState.puzzle_state.is_empty(), "should default to empty dict")


func test_puzzle_state_load_handles_wrong_type() -> void:
	PartyState.initialize_new_game()
	var save_data: Dictionary = PartyState.build_save_data()
	save_data["puzzle_state"] = [1, 2, 3]
	PartyState.load_from_save(save_data)
	assert_true(PartyState.puzzle_state.is_empty(), "should default to empty dict for wrong type")


func test_initialize_new_game_clears_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.initialize_new_game()
	assert_true(PartyState.puzzle_state.is_empty(), "new game should clear puzzle_state")
