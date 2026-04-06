extends CanvasLayer
## Save/Load overlay: save point menu, slot display, rest stubs.
## Modes: SAVE_POINT, SAVE, LOAD. Sub-state machine for navigation.

signal save_completed(slot: int)
signal load_completed(slot: int)

## Colors from ui-design.md Section 1.4.
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

## Operating modes.
enum Mode { SAVE_POINT, SAVE, LOAD }

## Sub-states for navigation.
enum SubState { SAVE_POINT_MENU, REST_MENU, SLOT_SELECT, CONFIRM }

## Save point menu options.
enum SavePointOption { REST, REST_SAVE, SAVE }

## Current mode.
var _mode: Mode = Mode.SAVE

## Current sub-state.
var _sub_state: SubState = SubState.SLOT_SELECT

var _selected_slot: int = 1
var _save_point_selection: int = 0
var _rest_selection: int = 0
var _confirm_selection: int = 1  # Default to "No"
var _pending_operation: String = ""
var _pending_slot: int = -1
var _copy_source_slot: int = -1
var _rest_after_save: bool = false
var _slot_previews: Array[Dictionary] = []

@onready var _save_point_menu: PanelContainer = $SavePointMenu
@onready var _save_point_options: Array[Label] = []
@onready var _slot_container: VBoxContainer = $SlotContainer
@onready var _auto_slot: PanelContainer = $SlotContainer/AutoSlot
@onready var _manual_slots: Array[PanelContainer] = []
@onready var _rest_menu: PanelContainer = $RestMenu
@onready var _rest_options: Array[Label] = []
@onready var _confirm_dialog: PanelContainer = $ConfirmDialog
@onready var _confirm_label: Label = $ConfirmDialog/ConfirmLabel
@onready var _confirm_yes: Label = $ConfirmDialog/YesOption
@onready var _confirm_no: Label = $ConfirmDialog/NoOption
@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	_save_point_options = [
		$SavePointMenu/RestOption,
		$SavePointMenu/RestSaveOption,
		$SavePointMenu/SaveOption,
	]
	_manual_slots = [
		$SlotContainer/Slot1,
		$SlotContainer/Slot2,
		$SlotContainer/Slot3,
	]
	_rest_options = [
		$RestMenu/SleepingBagOption,
		$RestMenu/TentOption,
		$RestMenu/PavilionOption,
	]
	_hide_all()
	_slot_previews = SaveManager.get_slot_previews()


func _unhandled_input(event: InputEvent) -> void:
	match _sub_state:
		SubState.SAVE_POINT_MENU:
			_handle_save_point_input(event)
		SubState.REST_MENU:
			_handle_rest_input(event)
		SubState.SLOT_SELECT:
			_handle_slot_input(event)
		SubState.CONFIRM:
			_handle_confirm_input(event)


func open_save_point() -> void:
	_mode = Mode.SAVE_POINT
	_sub_state = SubState.SAVE_POINT_MENU
	_save_point_selection = 0
	_save_point_menu.visible = true
	_slot_container.visible = false
	_update_save_point_display()


func open_save() -> void:
	_mode = Mode.SAVE
	_sub_state = SubState.SLOT_SELECT
	_selected_slot = 1
	_show_slots(false)


func open_load() -> void:
	_mode = Mode.LOAD
	_sub_state = SubState.SLOT_SELECT
	_slot_previews = SaveManager.get_slot_previews()
	_select_first_populated_slot()
	_show_slots(true)


func _hide_all() -> void:
	_save_point_menu.visible = false
	_slot_container.visible = false
	_rest_menu.visible = false
	_confirm_dialog.visible = false


func _show_slots(show_auto: bool) -> void:
	_slot_container.visible = true
	_auto_slot.visible = show_auto
	_refresh_slot_display()
	_update_slot_selection()


func _refresh_slot_display() -> void:
	_slot_previews = SaveManager.get_slot_previews()
	for i: int in range(3):
		_update_slot_panel(_manual_slots[i], _slot_previews[i + 1])
	if _auto_slot.visible:
		_update_slot_panel(_auto_slot, _slot_previews[0], true)


func _update_slot_panel(panel: PanelContainer, data: Dictionary, is_auto: bool = false) -> void:
	var header: Label = panel.get_node("HeaderLabel")
	var party: Label = panel.get_node("PartyLabel")
	var prefix: String = "AUTO - " if is_auto else ""
	if data.is_empty():
		header.text = prefix + "Empty"
		header.modulate = COLOR_DISABLED
		party.text = ""
	elif data.has("error"):
		header.text = prefix + "Corrupted"
		header.modulate = Color("#ff4444")
		party.text = ""
	else:
		var world: Dictionary = data.get("world", {})
		var raw_loc: String = world.get("current_location", "")
		var loc: String = raw_loc if raw_loc != "" else "Unknown"
		var pt: int = data.get("meta", {}).get("playtime", 0)
		header.text = (
			"%s%s  %d:%02d  %dg" % [prefix, loc, pt / 3600, (pt % 3600) / 60, world.get("gold", 0)]
		)
		header.modulate = COLOR_NORMAL
		var active: Array = data.get("formation", {}).get("active", [])
		party.text = "  ".join(active.map(func(c: Variant) -> String: return str(c)))


func _select_first_populated_slot() -> void:
	if _mode == Mode.LOAD:
		for slot: int in [0, 1, 2, 3]:
			var preview: Dictionary = _slot_previews[slot]
			if not preview.is_empty() and not preview.has("error"):
				_selected_slot = slot
				return
	_selected_slot = 1


func _is_slot_selectable(slot: int) -> bool:
	if _mode == Mode.LOAD:
		var preview: Dictionary = _slot_previews[slot]
		return not preview.is_empty() and not preview.has("error")
	return true


# --- Input handlers ---


func _handle_save_point_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_save_point_selection = (_save_point_selection + 1) % 3
		_update_save_point_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_save_point_selection = (_save_point_selection - 1 + 3) % 3
		_update_save_point_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_save_point()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		GameManager.pop_overlay()
		get_viewport().set_input_as_handled()


func _handle_rest_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_rest_selection = (_rest_selection + 1) % 3
		_update_rest_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_rest_selection = (_rest_selection - 1 + 3) % 3
		_update_rest_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		push_warning("SaveLoad: Rest item consumption not yet implemented")
		_rest_menu.visible = false
		if _rest_after_save:
			_rest_after_save = false
			_save_point_menu.visible = false
			_sub_state = SubState.SLOT_SELECT
			_selected_slot = 1
			_show_slots(false)
		else:
			_sub_state = SubState.SAVE_POINT_MENU
			_save_point_menu.visible = true
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_rest_menu.visible = false
		_rest_after_save = false
		_sub_state = SubState.SAVE_POINT_MENU
		_save_point_menu.visible = true
		get_viewport().set_input_as_handled()


func _handle_slot_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_slot_cursor(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_slot_cursor(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_slot()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_cancel_from_slots()
		get_viewport().set_input_as_handled()


func _handle_confirm_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		_confirm_selection = 1 - _confirm_selection
		_update_confirm_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_execute_confirm()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_confirm_dialog.visible = false
		_sub_state = SubState.SLOT_SELECT
		get_viewport().set_input_as_handled()


func _confirm_save_point() -> void:
	match _save_point_selection:
		SavePointOption.REST:
			_save_point_menu.visible = false
			_sub_state = SubState.REST_MENU
			_rest_selection = 0
			_rest_menu.visible = true
			_update_rest_display()
		SavePointOption.REST_SAVE:
			_save_point_menu.visible = false
			_rest_after_save = true
			_sub_state = SubState.REST_MENU
			_rest_selection = 0
			_rest_menu.visible = true
			_update_rest_display()
		SavePointOption.SAVE:
			_save_point_menu.visible = false
			_sub_state = SubState.SLOT_SELECT
			_selected_slot = 1
			_show_slots(false)


func _move_slot_cursor(direction: int) -> void:
	var min_slot: int = 0 if _mode == Mode.LOAD else 1
	var max_slot: int = 3
	var attempts: int = 0
	var new_slot: int = _selected_slot
	while attempts <= max_slot - min_slot:
		new_slot += direction
		if new_slot > max_slot:
			new_slot = min_slot
		elif new_slot < min_slot:
			new_slot = max_slot
		attempts += 1
		if _mode != Mode.LOAD or _is_slot_selectable(new_slot):
			_selected_slot = new_slot
			_update_slot_selection()
			return


func _confirm_slot() -> void:
	if not _is_slot_selectable(_selected_slot) and _mode == Mode.LOAD:
		return

	if _mode == Mode.SAVE or _mode == Mode.SAVE_POINT:
		var preview: Dictionary = _slot_previews[_selected_slot]
		if not preview.is_empty() and not preview.has("error"):
			_show_confirm("Overwrite?", "overwrite")
		else:
			_do_save(_selected_slot)
	elif _mode == Mode.LOAD:
		_do_load(_selected_slot)


func _cancel_from_slots() -> void:
	_cursor.visible = false
	if _mode == Mode.SAVE_POINT:
		_slot_container.visible = false
		_sub_state = SubState.SAVE_POINT_MENU
		_save_point_menu.visible = true
	else:
		GameManager.pop_overlay()


func _show_confirm(message: String, operation: String) -> void:
	_sub_state = SubState.CONFIRM
	_confirm_label.text = message
	_confirm_selection = 1
	_pending_operation = operation
	_pending_slot = _selected_slot
	_confirm_dialog.visible = true
	_update_confirm_display()


func _execute_confirm() -> void:
	_confirm_dialog.visible = false
	if _confirm_selection == 0:
		match _pending_operation:
			"overwrite":
				_do_save(_pending_slot)
			"delete":
				_do_delete(_pending_slot)
			"copy_dest":
				_do_copy(_copy_source_slot, _pending_slot)
	_sub_state = SubState.SLOT_SELECT


func _do_save(slot: int) -> void:
	var success: bool = SaveManager.save_game(slot)
	if success:
		save_completed.emit(slot)
		_refresh_slot_display()


func _do_load(slot: int) -> void:
	var data: Dictionary = SaveManager.load_game(slot)
	if data.is_empty() or data.has("error"):
		push_warning("SaveLoad: Failed to load slot %d" % slot)
		return
	load_completed.emit(slot)
	var transition: Dictionary = {"save_slot": slot, "save_data": data}
	GameManager.change_core_state(GameManager.CoreState.EXPLORATION, transition)


func _do_delete(slot: int) -> void:
	SaveManager.delete_slot(slot)
	_refresh_slot_display()


func _do_copy(source: int, dest: int) -> void:
	SaveManager.copy_slot(source, dest)
	_refresh_slot_display()


# --- Display updates ---


func _update_save_point_display() -> void:
	for i: int in range(3):
		_save_point_options[i].modulate = (
			COLOR_SELECTED if i == _save_point_selection else COLOR_NORMAL
		)


func _update_rest_display() -> void:
	for i: int in range(3):
		_rest_options[i].modulate = (COLOR_SELECTED if i == _rest_selection else COLOR_NORMAL)


func _update_confirm_display() -> void:
	_confirm_yes.modulate = COLOR_SELECTED if _confirm_selection == 0 else COLOR_NORMAL
	_confirm_no.modulate = COLOR_SELECTED if _confirm_selection == 1 else COLOR_NORMAL


func _update_slot_selection() -> void:
	var panels: Array = [_auto_slot] + _manual_slots
	for i: int in range(4):
		var panel: PanelContainer = panels[i]
		if i == _selected_slot:
			panel.modulate = Color("#ffcc44")
		else:
			panel.modulate = Color.WHITE
	_cursor.visible = true
	var target: PanelContainer = panels[_selected_slot]
	_cursor.global_position = Vector2(4, target.global_position.y + target.size.y / 2.0)
