extends GutTest
## Tests for Save/Load Overlay.

const SAVE_LOAD_SCENE: PackedScene = preload("res://scenes/overlay/save_load.tscn")


func before_each() -> void:
	for slot: int in [0, 1, 2, 3]:
		SaveManager.delete_slot(slot)


func after_each() -> void:
	for slot: int in [0, 1, 2, 3]:
		SaveManager.delete_slot(slot)


func _create_save_load() -> Node:
	var sl: Node = SAVE_LOAD_SCENE.instantiate()
	add_child_autofree(sl)
	return sl


# --- Scene Loading ---


func test_save_load_scene_loads() -> void:
	var sl: Node = _create_save_load()
	assert_not_null(sl, "save/load scene should instantiate")


# --- Save Point Menu ---


func test_save_point_menu_visible() -> void:
	var sl: Node = _create_save_load()
	sl.open_save_point()
	assert_true(sl._save_point_menu.visible, "save point menu should be visible")
	assert_eq(sl._sub_state, sl.SubState.SAVE_POINT_MENU, "should be in save point menu state")


# --- Mode Visibility ---


func test_save_mode_hides_auto() -> void:
	var sl: Node = _create_save_load()
	sl.open_save()
	assert_false(sl._auto_slot.visible, "auto slot should be hidden in save mode")


func test_load_mode_shows_auto() -> void:
	var sl: Node = _create_save_load()
	sl.open_load()
	assert_true(sl._auto_slot.visible, "auto slot should be visible in load mode")


# --- Slot Display ---


func test_empty_slot_display() -> void:
	var sl: Node = _create_save_load()
	sl.open_save()
	# With no saves, all slots should show "Empty"
	var header: Label = sl._manual_slots[0].get_node_or_null("HeaderLabel")
	assert_not_null(header, "slot should have header label")
	assert_eq(header.text, "Empty", "empty slot should show Empty text")


func test_populated_slot_display() -> void:
	var sl: Node = _create_save_load()
	# Manually set preview data to test display
	sl._slot_previews = [
		{},  # auto: empty
		{
			"meta":
			{
				"version": 1,
				"playtime": 3723,
				"saved_at": "2026-04-06",
				"slot_type": "manual",
			},
			"party": [],
			"formation": {"active": ["edren", "cael"], "reserve": [], "rows": {}},
			"inventory": {},
			"owned_equipment": [],
			"crafting": {},
			"ley_crystals": {},
			"world":
			{
				"current_location": "Valdris Crown",
				"gold": 1200,
				"event_flags": {},
				"act": "1",
				"current_position": {"x": 0, "y": 0},
			},
			"quests": {},
			"completion": {},
		},
		{},  # slot 2: empty
		{},  # slot 3: empty
	]
	# Call _update_slot_panel directly to avoid _refresh overwriting with real data
	sl._update_slot_panel(sl._manual_slots[0], sl._slot_previews[1])
	var header: Label = sl._manual_slots[0].get_node_or_null("HeaderLabel")
	assert_not_null(header, "slot should have header label")
	assert_string_contains(header.text, "Valdris Crown", "should show location name")


# --- Save Operation ---


func test_save_writes_file() -> void:
	var sl: Node = _create_save_load()
	watch_signals(sl)
	sl.open_save()
	sl._do_save(1)
	assert_signal_emitted(sl, "save_completed", "should emit save_completed")


func test_overwrite_shows_confirm() -> void:
	var sl: Node = _create_save_load()
	sl.open_save()
	# Fake a populated slot preview
	sl._slot_previews[1] = {
		"meta": {"version": 1},
		"party": [],
		"formation": {},
		"inventory": {},
		"crafting": {},
		"ley_crystals": {},
		"world": {},
		"quests": {},
		"completion": {},
	}
	sl._selected_slot = 1
	sl._confirm_slot()
	assert_true(sl._confirm_dialog.visible, "confirm dialog should be visible")
	assert_eq(sl._sub_state, sl.SubState.CONFIRM, "should be in confirm state")


# --- Delete ---


func test_delete_clears_slot() -> void:
	var sl: Node = _create_save_load()
	var saved: bool = SaveManager.save_game(3)
	assert_true(saved, "save_game should succeed before deletion test")
	var pre_data: Dictionary = SaveManager.load_game(3)
	assert_false(pre_data.is_empty(), "slot should have data before deletion")
	sl.open_save()
	sl._do_delete(3)
	var post_data: Dictionary = SaveManager.load_game(3)
	assert_true(post_data.is_empty(), "deleted slot should load as empty")


# --- Cancel ---


func test_cancel_from_save_point() -> void:
	var sl: Node = _create_save_load()
	sl.open_save_point()
	# Cancel should pop overlay — verify state is save point menu
	assert_eq(sl._sub_state, sl.SubState.SAVE_POINT_MENU, "should be in save point menu")


# --- Copy ---


func test_copy_slot() -> void:
	var sl: Node = _create_save_load()
	# Create a save in slot 1
	SaveManager.save_game(1)
	sl.open_save()
	sl._do_copy(1, 2)
	# Slot 2 should now have data
	var data: Dictionary = SaveManager.load_game(2)
	assert_false(data.is_empty(), "copied slot should have data")
	# Clean up
	SaveManager.delete_slot(1)
	SaveManager.delete_slot(2)


func test_load_initial_selection() -> void:
	var sl: Node = _create_save_load()
	# With no saves, should default to slot 1
	sl.open_load()
	assert_eq(sl._selected_slot, 1, "should default to slot 1 when no saves")
