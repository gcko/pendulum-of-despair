extends Control
## Title screen with 3-option menu and cursor navigation.
## Core state scene — set as project main_scene.
##
## Menu: New Game, Continue, Config (stubbed).
## Uses built-in Godot input actions (ui_up, ui_down, ui_accept).

## Number of menu options.
const MENU_COUNT: int = 3

## Colors from ui-design.md Section 1.4.
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

## Menu option indices.
enum MenuOption { NEW_GAME, CONTINUE, CONFIG }

## Currently selected menu index.
var _selected: int = 0

## Whether Continue is available (saves exist).
var _has_save: bool = false

## Whether input is being processed (prevents double-select).
var _input_active: bool = true

@onready var _options: Array[Label] = []
@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	_options = [
		$MenuContainer/NewGameOption,
		$MenuContainer/ContinueOption,
		$MenuContainer/ConfigOption,
	]
	_has_save = SaveManager.has_any_save()
	_update_display()


func _unhandled_input(event: InputEvent) -> void:
	if not _input_active:
		return
	if event.is_action_pressed("ui_down"):
		_move_cursor(1)
	elif event.is_action_pressed("ui_up"):
		_move_cursor(-1)
	elif event.is_action_pressed("ui_accept"):
		_confirm_selection()


func _move_cursor(direction: int) -> void:
	_selected = (_selected + direction + MENU_COUNT) % MENU_COUNT
	_update_display()


func _confirm_selection() -> void:
	match _selected:
		MenuOption.NEW_GAME:
			_input_active = false
			var scene_path: String = "res://scenes/core/exploration.tscn"
			if not ResourceLoader.exists(scene_path):
				push_warning("Title: Exploration scene not found")
				_input_active = true
				return
			PartyState.initialize_new_game()
			GameManager.change_core_state(GameManager.CoreState.EXPLORATION, {"new_game": true})
		MenuOption.CONTINUE:
			if not _has_save:
				return
			_input_active = false
			var result: Dictionary = SaveManager.load_most_recent()
			if result.is_empty() or result.has("error"):
				push_warning("Title: Failed to load most recent save")
				_input_active = true
				return
			var save_data: Dictionary = {"save_slot": result["slot"], "save_data": result["data"]}
			GameManager.change_core_state(GameManager.CoreState.EXPLORATION, save_data)
		MenuOption.CONFIG:
			if GameManager.push_overlay(GameManager.OverlayState.MENU):
				var overlay: Node = GameManager.overlay_node
				if overlay != null and overlay.has_method("open_config_direct"):
					overlay.open_config_direct()


func _update_display() -> void:
	for i: int in range(MENU_COUNT):
		var label: Label = _options[i]
		var is_disabled: bool = _is_option_disabled(i)
		if i == _selected:
			label.modulate = COLOR_DISABLED if is_disabled else COLOR_SELECTED
		else:
			label.modulate = COLOR_DISABLED if is_disabled else COLOR_NORMAL
	# Position cursor next to selected option
	if _cursor != null and _options.size() > _selected:
		var target: Label = _options[_selected]
		_cursor.global_position = Vector2(
			target.global_position.x - 20,
			target.global_position.y + target.size.y / 2.0,
		)


func _is_option_disabled(index: int) -> bool:
	match index:
		MenuOption.CONTINUE:
			return not _has_save
		MenuOption.CONFIG:
			return true
	return false
