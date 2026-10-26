extends GutTest
## The Config menu's Fullscreen setting (#453): the last row of the list, an
## On/Off toggle that changes the stored setting and the window mode at once,
## and a stored setting that DisplaySettings.apply puts back on a window.
##
## Headless Godot reports every in-tree window as minimized, so the real root
## window cannot show a mode change. These tests hand the code a stand-in
## Window that is never added to the tree; its `mode` reads back what was set.
##
## The key is written out as "fullscreen" rather than read from DisplaySettings:
## it is the name stored in the player's config.json, so renaming it would
## silently reset every existing player's choice.
##
## Never call the Config screen's close() here: it writes the developer's real
## user://config.json.

const MENU_SCENE: PackedScene = preload("res://scenes/overlay/menu.tscn")
const ConfigScript: GDScript = preload("res://scripts/ui/menu_config.gd")
const KEY: String = "fullscreen"
const ROW_PATH: String = "Layout/SettingsPanel/ScrollContainer/SettingList/%s%d"

var _config_screen: Control
var _window: Window
var _saved_config: Dictionary = {}


func before_each() -> void:
	TestHelpers.reset_game_state()
	# The config dictionary is shared suite-wide and the menu writes into it.
	_saved_config = PartyState.get_config().duplicate(true)
	PartyState.set_config(KEY, false)
	var menu: Node = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	_config_screen = menu.get_node("SubScreen/ConfigScreen")
	_window = Window.new()
	_config_screen.display_window = _window


func after_each() -> void:
	var config: Dictionary = PartyState.get_config()
	config.clear()
	config.merge(_saved_config)
	_window.free()
	TestHelpers.reset_game_state()


func _press(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	_config_screen.handle_input(event)


## Open Config and press up once: the cursor wraps from the top row to the
## last one, which is where Fullscreen lives.
func _open_on_last_row() -> int:
	_config_screen.open()
	_press("ui_up")
	return ConfigScript.SETTINGS.size() - 1


func _label_text(kind: String, row: int) -> String:
	var label: Label = _config_screen.get_node_or_null(ROW_PATH % [kind, row])
	assert_not_null(label, "row %d has a %s label" % [row, kind])
	return label.text if label != null else ""


func test_the_last_config_row_is_fullscreen_and_reads_off() -> void:
	var row: int = _open_on_last_row()
	assert_eq(_label_text("Name", row), "Fullscreen")
	assert_eq(_label_text("Value", row), "Off")


func test_confirming_fullscreen_turns_it_on_and_fills_the_screen() -> void:
	var row: int = _open_on_last_row()
	_press("ui_accept")
	assert_eq(PartyState.get_config().get(KEY), true, "the setting is stored as on")
	assert_eq(_label_text("Value", row), "On")
	assert_eq(_window.mode, Window.MODE_FULLSCREEN, "the window goes fullscreen at once")


func test_confirming_again_returns_to_a_window() -> void:
	var row: int = _open_on_last_row()
	_press("ui_accept")
	_press("ui_accept")
	assert_eq(PartyState.get_config().get(KEY), false, "the setting is stored as off")
	assert_eq(_label_text("Value", row), "Off")
	assert_eq(_window.mode, Window.MODE_WINDOWED, "the window leaves fullscreen at once")


func test_left_and_right_also_toggle_fullscreen() -> void:
	_open_on_last_row()
	_press("ui_right")
	assert_eq(_window.mode, Window.MODE_FULLSCREEN, "right turns it on")
	_press("ui_left")
	assert_eq(_window.mode, Window.MODE_WINDOWED, "left turns it off")


func test_applying_a_stored_fullscreen_setting_fills_the_screen() -> void:
	DisplaySettings.apply({KEY: true}, _window)
	assert_eq(_window.mode, Window.MODE_FULLSCREEN)


func test_applying_a_stored_windowed_setting_leaves_a_maximized_window_maximized() -> void:
	_window.mode = Window.MODE_MAXIMIZED
	DisplaySettings.apply({KEY: false}, _window)
	assert_eq(_window.mode, Window.MODE_MAXIMIZED, "windowed already; do not un-maximize")


func test_applying_a_config_written_before_fullscreen_existed_gives_a_window() -> void:
	_window.mode = Window.MODE_FULLSCREEN
	DisplaySettings.apply({}, _window)
	assert_eq(_window.mode, Window.MODE_WINDOWED, "a missing key means the shipped default, off")


func test_the_game_ships_windowed() -> void:
	var defaults: Dictionary = DataManager.load_json("res://data/config/defaults.json")
	assert_true(defaults.has(KEY), "defaults.json declares the Fullscreen setting")
	assert_eq(defaults.get(KEY), false, "and declares it Off")
