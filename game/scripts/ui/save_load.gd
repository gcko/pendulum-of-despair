extends CanvasLayer
## Save/Load overlay: save point menu, slot display, rest stubs.
## Display rendering delegated to SaveLoadDisplay.

signal save_completed(slot: int)
signal load_completed(slot: int)

enum Mode { SAVE_POINT, SAVE, LOAD }
enum SubState { SAVE_POINT_MENU, REST_MENU, SLOT_SELECT, CONFIRM }
enum SavePointOption { REST, REST_SAVE, SAVE }

const REST_ITEM_IDS: Array[String] = ["sleeping_bag", "tent", "pavilion"]

var _mode: Mode = Mode.SAVE
var _sub_state: SubState = SubState.SLOT_SELECT
var _selected_slot: int = 1
var _save_point_selection: int = 0
var _rest_selection: int = 0
var _confirm_selection: int = 1
var _pending_operation: String = ""
var _pending_slot: int = -1
var _copy_source_slot: int = -1
var _rest_after_save: bool = false
var _slot_previews: Array[Dictionary] = []
var _display: SaveLoadDisplay

@onready var _save_point_menu: PanelContainer = $SavePointMenu
@onready var _save_point_options: Array[Label] = []
@onready var _slot_container: VBoxContainer = $SlotContainer
@onready var _auto_slot: PanelContainer = $SlotContainer/AutoSlot
@onready var _manual_slots: Array[PanelContainer] = []
@onready var _rest_menu: PanelContainer = $RestMenu
@onready var _rest_options: Array[Label] = []
@onready var _confirm_dialog: PanelContainer = $ConfirmDialog
@onready var _confirm_label: Label = $ConfirmDialog/ConfirmLayout/ConfirmLabel
@onready var _confirm_yes: Label = $ConfirmDialog/ConfirmLayout/YesOption
@onready var _confirm_no: Label = $ConfirmDialog/ConfirmLayout/NoOption
@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	_display = SaveLoadDisplay.new(self)
	_save_point_options = [
		$SavePointMenu/OptionList/RestOption,
		$SavePointMenu/OptionList/RestSaveOption,
		$SavePointMenu/OptionList/SaveOption,
	]
	_manual_slots = [
		$SlotContainer/Slot1,
		$SlotContainer/Slot2,
		$SlotContainer/Slot3,
	]
	_rest_options = [
		$RestMenu/Options/SleepingBagOption,
		$RestMenu/Options/TentOption,
		$RestMenu/Options/PavilionOption,
	]
	_save_point_menu.visible = false
	_slot_container.visible = false
	_rest_menu.visible = false
	_confirm_dialog.visible = false
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
	_display.update_save_point(_save_point_options, _save_point_selection)


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


## Delegate so tests can call _update_slot_panel directly.
func _update_slot_panel(panel: PanelContainer, data: Dictionary, is_auto: bool = false) -> void:
	_display.update_slot_panel(panel, data, is_auto)


func _show_slots(show_auto: bool) -> void:
	_slot_container.visible = true
	_auto_slot.visible = show_auto
	_slot_previews = SaveManager.get_slot_previews()
	_display.refresh_slot_display(_manual_slots, _auto_slot, _slot_previews)
	(
		_display
		. update_slot_sel(
			_auto_slot,
			_manual_slots,
			_selected_slot,
			_is_slot_selectable(_selected_slot),
			_cursor,
		)
	)


func _refresh_after_change() -> void:
	_slot_previews = SaveManager.get_slot_previews()
	_display.refresh_slot_display(_manual_slots, _auto_slot, _slot_previews)


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


func _handle_save_point_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_save_point_selection = (_save_point_selection + 1) % 3
		_display.update_save_point(_save_point_options, _save_point_selection)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_save_point_selection = ((_save_point_selection - 1 + 3) % 3)
		_display.update_save_point(_save_point_options, _save_point_selection)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_save_point()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		GameManager.pop_overlay()


func _handle_rest_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_rest_selection = (_rest_selection + 1) % 3
		_display.update_rest(_rest_options, REST_ITEM_IDS, _rest_selection)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_rest_selection = (_rest_selection - 1 + 3) % 3
		_display.update_rest(_rest_options, REST_ITEM_IDS, _rest_selection)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_accept_rest_item()
	elif event.is_action_pressed("ui_cancel"):
		_rest_menu.visible = false
		_rest_after_save = false
		_sub_state = SubState.SAVE_POINT_MENU
		_save_point_menu.visible = true
		get_viewport().set_input_as_handled()


func _accept_rest_item() -> void:
	if not _has_rest_item(_rest_selection):
		get_viewport().set_input_as_handled()
		return
	var item_id: String = REST_ITEM_IDS[_rest_selection]
	var item_data: Dictionary = _find_consumable(item_id)
	var pct: float = float(item_data.get("restore_percent", 25)) / 100.0
	PartyState.consume_item(item_id)
	PartyState.rest_party(pct, item_data.get("clears_status", false))
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


func _handle_slot_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_slot_cursor(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_slot_cursor(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_confirm_slot()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel_from_slots()


func _handle_confirm_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		_confirm_selection = 1 - _confirm_selection
		_display.update_confirm(_confirm_yes, _confirm_no, _confirm_selection)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_execute_confirm()
	elif event.is_action_pressed("ui_cancel"):
		_confirm_dialog.visible = false
		_sub_state = SubState.SLOT_SELECT
		get_viewport().set_input_as_handled()


func _confirm_save_point() -> void:
	match _save_point_selection:
		SavePointOption.REST:
			_open_rest_menu(false)
		SavePointOption.REST_SAVE:
			_open_rest_menu(true)
		SavePointOption.SAVE:
			_save_point_menu.visible = false
			_sub_state = SubState.SLOT_SELECT
			_selected_slot = 1
			_show_slots(false)


func _open_rest_menu(rest_after: bool) -> void:
	_save_point_menu.visible = false
	_rest_after_save = rest_after
	_sub_state = SubState.REST_MENU
	_rest_selection = 0
	_rest_menu.visible = true
	_display.update_rest(_rest_options, REST_ITEM_IDS, _rest_selection)


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
			(
				_display
				. update_slot_sel(
					_auto_slot,
					_manual_slots,
					_selected_slot,
					_is_slot_selectable(_selected_slot),
					_cursor,
				)
			)
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
	_display.update_confirm(_confirm_yes, _confirm_no, _confirm_selection)


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
	if SaveManager.save_game(slot):
		save_completed.emit(slot)
		_refresh_after_change()


func _do_load(slot: int) -> void:
	var data: Dictionary = SaveManager.load_game(slot)
	if data.is_empty() or data.has("error"):
		push_warning("SaveLoad: Failed to load slot %d" % slot)
		return
	if not ResourceLoader.exists("res://scenes/core/exploration.tscn"):
		push_warning("SaveLoad: Exploration scene not found")
		return
	load_completed.emit(slot)
	var trans: Dictionary = {"save_slot": slot, "save_data": data}
	var state: int = GameManager.CoreState.EXPLORATION
	GameManager.call_deferred("change_core_state", state, trans)


func _do_delete(slot: int) -> void:
	SaveManager.delete_slot(slot)
	_refresh_after_change()


func _do_copy(source: int, dest: int) -> void:
	SaveManager.copy_slot(source, dest)
	_refresh_after_change()


func _find_consumable(item_id: String) -> Dictionary:
	var items: Array = DataManager.load_items("consumables")
	for item: Variant in items:
		if item is Dictionary and item.get("id", "") == item_id:
			return item as Dictionary
	return {}


func _has_rest_item(index: int) -> bool:
	if index < 0 or index >= REST_ITEM_IDS.size():
		return false
	var consumables: Dictionary = PartyState.get_consumables()
	return consumables.get(REST_ITEM_IDS[index], 0) > 0
