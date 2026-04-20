extends GutTest
## Tests for formation screen logic — row toggle, formation list order, swap positions.


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	PartyState.initialize_new_game()


# --- Row tests ---


func test_get_row_edren_default_front() -> void:
	assert_eq(PartyState.get_row("edren"), "front", "Edren should default to front row")


func test_get_row_unknown_defaults_front() -> void:
	assert_eq(
		PartyState.get_row("nonexistent"), "front", "Unknown character should default to front"
	)


func test_toggle_row_front_to_back() -> void:
	PartyState.toggle_row("edren")
	assert_eq(PartyState.get_row("edren"), "back", "Edren should move to back after one toggle")


func test_toggle_row_back_to_front() -> void:
	PartyState.toggle_row("edren")
	PartyState.toggle_row("edren")
	assert_eq(
		PartyState.get_row("edren"), "front", "Edren should return to front after two toggles"
	)


func test_toggle_row_unknown_character() -> void:
	PartyState.toggle_row("nonexistent")
	assert_eq(
		PartyState.get_row("nonexistent"), "back", "Unknown character should be added as back row"
	)


# --- Formation list tests ---


func test_get_formation_list_returns_all() -> void:
	var list: Array = PartyState.get_formation_list()
	assert_eq(list.size(), 2, "Formation list should have 2 members (Edren + Cael)")


func test_get_formation_list_active_first() -> void:
	var list: Array = PartyState.get_formation_list()
	for entry: Dictionary in list:
		assert_true(
			entry.get("_is_active", false), "Both members should be active after new game init"
		)


func test_get_formation_list_has_formation_index() -> void:
	var list: Array = PartyState.get_formation_list()
	assert_eq(list.size(), 2, "Expected 2 entries")
	assert_eq(list[0].get("_formation_index", -1), 0, "First entry should have _formation_index 0")
	assert_eq(list[1].get("_formation_index", -1), 1, "Second entry should have _formation_index 1")


# --- Swap tests ---


func test_swap_within_active() -> void:
	var list_before: Array = PartyState.get_formation_list()
	var first_id: String = list_before[0].get("character_id", "")
	var second_id: String = list_before[1].get("character_id", "")
	PartyState.swap_formation_positions(0, 1)
	var list_after: Array = PartyState.get_formation_list()
	assert_eq(
		list_after[0].get("character_id", ""),
		second_id,
		"After swap, former second member should be first"
	)
	assert_eq(
		list_after[1].get("character_id", ""),
		first_id,
		"After swap, former first member should be second"
	)


func test_swap_same_position() -> void:
	var list_before: Array = PartyState.get_formation_list()
	var first_id_before: String = list_before[0].get("character_id", "")
	PartyState.swap_formation_positions(0, 0)
	var list_after: Array = PartyState.get_formation_list()
	assert_eq(
		list_after[0].get("character_id", ""),
		first_id_before,
		"Swapping same index should leave order unchanged"
	)


func test_swap_out_of_bounds() -> void:
	# Should not crash — bounds are validated inside swap_formation
	PartyState.swap_formation_positions(0, 99)
	PartyState.swap_formation_positions(-1, 1)
	var list: Array = PartyState.get_formation_list()
	assert_eq(list.size(), 2, "Formation list should still have 2 members after out-of-bounds swap")
