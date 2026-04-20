extends CanvasLayer
## Save/Load overlay. Display rendering delegated to SaveLoadDisplay.

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
var _save_in_progress: bool = false
var _load_in_progress: bool = false
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
	_selected_slot = 1
	for slot: int in [0, 1, 2, 3]:
		if _is_slot_selectable(slot):
			_selected_slot = slot
			break
	_show_slots(true)


func _update_slot_panel(panel: PanelContainer, data: Dictionary, is_auto: bool = false) -> void:
	_display.update_slot_panel(panel, data, is_auto)


func _show_slots(show_auto: bool) -> void:
	_slot_container.visible = true
	_auto_slot.visible = show_auto
	_reload_previews()
	_update_slot_sel()


func _is_slot_selectable(slot: int) -> bool:
	if _mode == Mode.LOAD:
		var preview: Dictionary = _slot_previews[slot]
		return not preview.is_empty() and not preview.has("error")
	return true


func _update_slot_sel() -> void:
	var ok: bool = _is_slot_selectable(_selected_slot)
	var d: SaveLoadDisplay = _display
	d.update_slot_sel(_auto_slot, _manual_slots, _selected_slot, ok, _cursor)


func _handle_save_point_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_save_point_selection = (_save_point_selection + 1) % 3
		_display.update_save_point(_save_point_options, _save_point_selection)
		_consume_input()
	elif event.is_action_pressed("ui_up"):
		_save_point_selection = ((_save_point_selection - 1 + 3) % 3)
		_display.update_save_point(_save_point_options, _save_point_selection)
		_consume_input()
	elif event.is_action_pressed("ui_accept"):
		_confirm_save_point()
		_consume_input()
	elif event.is_action_pressed("ui_cancel"):
		_consume_input()
		GameManager.pop_overlay()


func _handle_rest_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_rest_selection = (_rest_selection + 1) % 3
		_display.update_rest(_rest_options, REST_ITEM_IDS, _rest_selection)
		_consume_input()
	elif event.is_action_pressed("ui_up"):
		_rest_selection = (_rest_selection - 1 + 3) % 3
		_display.update_rest(_rest_options, REST_ITEM_IDS, _rest_selection)
		_consume_input()
	elif event.is_action_pressed("ui_accept"):
		_accept_rest_item()
	elif event.is_action_pressed("ui_cancel"):
		_rest_menu.visible = false
		_rest_after_save = false
		_sub_state = SubState.SAVE_POINT_MENU
		_save_point_menu.visible = true
		_consume_input()


func _accept_rest_item() -> void:
	if not _display.has_rest_item(_rest_selection, REST_ITEM_IDS):
		_consume_input()
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
	_consume_input()


func _handle_slot_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_slot_cursor(1)
		_consume_input()
	elif event.is_action_pressed("ui_up"):
		_move_slot_cursor(-1)
		_consume_input()
	elif event.is_action_pressed("ui_accept"):
		_consume_input()
		_confirm_slot()
	elif event.is_action_pressed("ui_cancel"):
		_consume_input()
		_cursor.visible = false
		if _mode == Mode.SAVE_POINT:
			_slot_container.visible = false
			_sub_state = SubState.SAVE_POINT_MENU
			_save_point_menu.visible = true
		else:
			GameManager.pop_overlay()


func _handle_confirm_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		_confirm_selection = 1 - _confirm_selection
		_display.update_confirm(_confirm_yes, _confirm_no, _confirm_selection)
		_consume_input()
	elif event.is_action_pressed("ui_accept"):
		_consume_input()
		_execute_confirm()
	elif event.is_action_pressed("ui_cancel"):
		_confirm_dialog.visible = false
		_sub_state = SubState.SLOT_SELECT
		_consume_input()


func _confirm_save_point() -> void:
	_save_point_menu.visible = false
	match _save_point_selection:
		SavePointOption.REST, SavePointOption.REST_SAVE:
			_rest_after_save = _save_point_selection == SavePointOption.REST_SAVE
			_sub_state = SubState.REST_MENU
			_rest_selection = 0
			_rest_menu.visible = true
			_display.update_rest(_rest_options, REST_ITEM_IDS, _rest_selection)
		SavePointOption.SAVE:
			_sub_state = SubState.SLOT_SELECT
			_selected_slot = 1
			_show_slots(false)


func _move_slot_cursor(dir: int) -> void:
	var lo: int = 0 if _mode == Mode.LOAD else 1
	var cnt: int = 4 - lo
	var pos: int = _selected_slot
	for _i: int in range(cnt):
		pos = lo + wrapi(pos - lo + dir, 0, cnt)
		if _mode != Mode.LOAD or _is_slot_selectable(pos):
			_selected_slot = pos
			_update_slot_sel()
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
	if _save_in_progress:
		return
	_save_in_progress = true
	if not SaveManager.save_game(slot):
		_save_in_progress = false
		return
	save_completed.emit(slot)
	_reload_previews()
	_save_in_progress = false


func _do_load(slot: int) -> void:
	if _load_in_progress:
		return
	_load_in_progress = true
	var data: Dictionary = SaveManager.load_game(slot)
	var bad: bool = data.is_empty() or data.has("error")
	if bad or not ResourceLoader.exists("res://scenes/core/exploration.tscn"):
		push_warning("SaveLoad: cannot load slot %d" % slot)
		_load_in_progress = false
		return
	load_completed.emit(slot)
	var state: int = GameManager.CoreState.EXPLORATION
	GameManager.call_deferred("change_core_state", state, {"save_slot": slot, "save_data": data})


func _do_delete(slot: int) -> void:
	SaveManager.delete_slot(slot)
	_reload_previews()


func _do_copy(source: int, dest: int) -> void:
	SaveManager.copy_slot(source, dest)
	_reload_previews()


func _reload_previews() -> void:
	_slot_previews = SaveManager.get_slot_previews()
	_display.refresh_slot_display(_manual_slots, _auto_slot, _slot_previews)


func _consume_input() -> void:
	var vp: Viewport = get_viewport()
	if vp != null:
		vp.set_input_as_handled()


func _find_consumable(item_id: String) -> Dictionary:
	return _display.find_consumable(item_id)
