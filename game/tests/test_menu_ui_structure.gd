extends GutTest
## Tests for menu UI structure — verifies that sub-screens use proper
## bordered panels, config uses GridContainer layout, and long lists
## have ScrollContainers for overflow.


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


# --- Sub-screen panels use StyleBox ---


func test_all_subscreens_have_layout_container() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	var screens: Array[String] = [
		"ItemScreen",
		"ConfigScreen",
		"FormationScreen",
		"MagicScreen",
		"AbilitiesScreen",
		"EquipScreen",
		"StatusScreen",
	]
	for screen: String in screens:
		assert_true(
			text.contains('parent="SubScreen/%s/Layout' % screen),
			"%s should have children under Layout container" % screen,
		)


func test_stylebox_ff6_window_exists() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(
		text.contains("StyleBox_ff6_window"),
		"menu.tscn should define StyleBox_ff6_window sub-resource",
	)


# --- Config screen structure ---


func test_config_uses_grid_container() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(
		text.contains('SettingList" type="GridContainer"'),
		"config SettingList should be a GridContainer for 2-column layout",
	)


func test_config_grid_has_two_columns() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(
		text.contains("columns = 2"),
		"config GridContainer should have columns = 2",
	)


func test_config_has_scroll_container() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(
		text.contains('ScrollContainer" type="ScrollContainer" parent="SubScreen/ConfigScreen'),
		"config should have ScrollContainer for overflow",
	)


func test_config_has_title_label() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(
		text.contains('text = "Config"'),
		"config TitlePanel should contain Config label",
	)


# --- Character select uses color highlight ---


func test_char_select_uses_color_highlight() -> void:
	var text: String = _read_file("res://scripts/ui/menu_overlay.gd")
	assert_true(
		text.contains("COLOR_SELECTED if i == _char_index"),
		"char select should highlight selected member name with COLOR_SELECTED",
	)
	assert_true(
		text.contains("_clear_char_highlight"),
		"char select should clear highlight on cancel/accept",
	)


# --- Sub-screens hide main panels ---


func test_open_sub_screen_hides_main_panels() -> void:
	var text: String = _read_file("res://scripts/ui/menu_overlay.gd")
	assert_true(
		text.contains("_main_panel.visible = false"),
		"opening sub-screen should hide main panel",
	)
	assert_true(
		text.contains("_command_panel.visible = false"),
		"opening sub-screen should hide command panel",
	)
	assert_true(
		text.contains("_info_panel.visible = false"),
		"opening sub-screen should hide info panel",
	)


func test_close_sub_screen_restores_main_panels() -> void:
	var text: String = _read_file("res://scripts/ui/menu_overlay.gd")
	assert_true(
		text.contains("_main_panel.visible = true"),
		"closing sub-screen should restore main panel",
	)
	assert_true(
		text.contains("_command_panel.visible = true"),
		"closing sub-screen should restore command panel",
	)


# --- Helper ---


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
