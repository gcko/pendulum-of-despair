extends GutTest
## Tests for Title Screen.

const TITLE_SCENE: PackedScene = preload("res://scenes/core/title.tscn")


func after_each() -> void:
	# Clean up any save files that other tests may have created
	for slot: int in [0, 1, 2, 3]:
		SaveManager.delete_slot(slot)


func _create_title():
	var title = TITLE_SCENE.instantiate()
	add_child_autofree(title)
	return title


func test_title_scene_loads() -> void:
	var title = _create_title()
	assert_not_null(title, "title scene should instantiate")


func test_menu_options_exist() -> void:
	var title = _create_title()
	var container = title.get_node("MenuContainer")
	assert_eq(container.get_child_count(), 3, "should have 3 menu options")


func test_initial_selection() -> void:
	var title = _create_title()
	assert_eq(title._selected, 0, "should start on New Game")


func test_cursor_wraps_up() -> void:
	var title = _create_title()
	title._move_cursor(-1)
	assert_eq(title._selected, 2, "should wrap to last option")


func test_cursor_wraps_down() -> void:
	var title = _create_title()
	title._selected = 2
	title._move_cursor(1)
	assert_eq(title._selected, 0, "should wrap to first option")


func test_continue_disabled_no_saves() -> void:
	var title = _create_title()
	assert_true(
		title._is_option_disabled(title.MenuOption.CONTINUE),
		"continue should be disabled when no saves exist",
	)


func test_config_disabled() -> void:
	var title = _create_title()
	assert_true(title._is_option_disabled(title.MenuOption.CONFIG), "config should be disabled")
