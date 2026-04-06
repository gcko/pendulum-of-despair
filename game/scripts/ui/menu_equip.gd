extends Control
## Equipment sub-screen: EQUIP / OPTIMUM / REMOVE / EMPTY modes.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")
const COLOR_STAT_UP: Color = Color("#44ff44")
const COLOR_STAT_DOWN: Color = Color("#ff4444")
const SLOT_NAMES: Array[String] = ["weapon", "head", "body", "accessory", "crystal"]
const SLOT_DISPLAY: Array[String] = ["Weapon", "Head", "Body", "Access", "Crystal"]
const STAT_NAMES: Array[String] = ["atk", "def", "mag", "mdef", "spd", "lck"]
const STAT_DISPLAY: Array[String] = ["ATK", "DEF", "MAG", "MDEF", "SPD", "LCK"]

enum EquipMode { EQUIP, OPTIMUM, REMOVE, EMPTY }
enum EquipState { MODE_SELECT, SLOT_SELECT, ITEM_SELECT }

var _mode: EquipMode = EquipMode.EQUIP
var _state: EquipState = EquipState.MODE_SELECT
var _slot_index: int = 0
var _item_index: int = 0
var _character_id: String = ""
var _available_items: Array[Dictionary] = []

@onready var _mode_labels: Array[Label] = []
@onready var _slot_labels: Array[Label] = []
@onready var _stat_labels: Array[Label] = []
@onready var _item_list: Control = $ItemList
@onready var _item_labels: Array[Label] = []
@onready var _name_label: Label = $NameLabel
@onready var _info_label: Label = $InfoLabel


func _ready() -> void:
	_mode_labels = []
	for mode_name: String in ["EquipMode", "OptimumMode", "RemoveMode", "EmptyMode"]:
		var label: Label = get_node_or_null("ModeBar/" + mode_name)
		if label != null:
			_mode_labels.append(label)
	_slot_labels = []
	for i: int in range(5):
		var label: Label = get_node_or_null("SlotPanel/Slot%d" % i)
		if label != null:
			_slot_labels.append(label)
	_stat_labels = []
	for i: int in range(6):
		var label: Label = get_node_or_null("StatPanel/Stat%d" % i)
		if label != null:
			_stat_labels.append(label)
	_item_labels = []
	for i: int in range(10):
		var label: Label = get_node_or_null("ItemList/Item%d" % i)
		if label != null:
			_item_labels.append(label)
	if _item_list != null:
		_item_list.visible = false


func open(character_id: String) -> void:
	_character_id = character_id
	_mode = EquipMode.EQUIP
	_state = EquipState.MODE_SELECT
	_slot_index = 0
	_item_index = 0
	if _item_list != null:
		_item_list.visible = false
	_update_display()


func close() -> void:
	if _item_list != null:
		_item_list.visible = false


func handle_input(event: InputEvent) -> bool:
	match _state:
		EquipState.MODE_SELECT:
			return _handle_mode_input(event)
		EquipState.SLOT_SELECT:
			return _handle_slot_input(event)
		EquipState.ITEM_SELECT:
			return _handle_item_input(event)
	return false


func _handle_mode_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_right"):
		_mode = ((_mode + 1) % 4) as EquipMode
		_update_display()
		return true
	if event.is_action_pressed("ui_left"):
		_mode = ((_mode - 1 + 4) % 4) as EquipMode
		_update_display()
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_mode()
		return true
	if event.is_action_pressed("ui_cancel"):
		return false  # Let parent handle closing
	return false


func _handle_slot_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_down"):
		_slot_index = (_slot_index + 1) % 5
		_update_display()
		return true
	if event.is_action_pressed("ui_up"):
		_slot_index = (_slot_index - 1 + 5) % 5
		_update_display()
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_slot()
		return true
	if event.is_action_pressed("ui_cancel"):
		_state = EquipState.MODE_SELECT
		_update_display()
		return true
	return false


func _handle_item_input(event: InputEvent) -> bool:
	var list_size: int = _available_items.size() + 1  # +1 for "Remove" option
	if event.is_action_pressed("ui_down"):
		_item_index = (_item_index + 1) % list_size
		_update_item_display()
		_update_stat_comparison()
		return true
	if event.is_action_pressed("ui_up"):
		_item_index = (_item_index - 1 + list_size) % list_size
		_update_item_display()
		_update_stat_comparison()
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_item()
		return true
	if event.is_action_pressed("ui_cancel"):
		_item_list.visible = false
		_state = EquipState.SLOT_SELECT
		_update_display()
		return true
	return false


func _confirm_mode() -> void:
	match _mode:
		EquipMode.EQUIP:
			_state = EquipState.SLOT_SELECT
			_slot_index = 0
			_update_display()
		EquipMode.OPTIMUM:
			PartyState.optimize_equipment(_character_id)
			_update_display()
		EquipMode.REMOVE:
			_state = EquipState.SLOT_SELECT
			_slot_index = 0
			_update_display()
		EquipMode.EMPTY:
			for slot: String in SLOT_NAMES:
				PartyState.unequip_slot(_character_id, slot)
			_update_display()


func _confirm_slot() -> void:
	if _mode == EquipMode.REMOVE:
		PartyState.unequip_slot(_character_id, SLOT_NAMES[_slot_index])
		_update_display()
		_state = EquipState.MODE_SELECT
		return
	# EQUIP mode — show available items
	_available_items = PartyState.get_equippable_for_slot(_character_id, SLOT_NAMES[_slot_index])
	_item_index = 0
	_item_list.visible = true
	_state = EquipState.ITEM_SELECT
	_update_item_display()
	_update_stat_comparison()


func _confirm_item() -> void:
	if _item_index == 0:
		# "Remove" option
		PartyState.unequip_slot(_character_id, SLOT_NAMES[_slot_index])
	else:
		var equip_idx: int = _item_index - 1
		if equip_idx < _available_items.size():
			var equip_id: String = _available_items[equip_idx].get("id", "")
			PartyState.equip_item(_character_id, SLOT_NAMES[_slot_index], equip_id)
	_item_list.visible = false
	_state = EquipState.SLOT_SELECT
	_update_display()


func _update_display() -> void:
	# Mode bar
	for i: int in range(_mode_labels.size()):
		if _mode_labels[i] != null:
			_mode_labels[i].modulate = COLOR_SELECTED if i == _mode else COLOR_NORMAL

	# Character name
	if _name_label != null:
		_name_label.text = _character_id.to_upper()

	# Slot labels
	var member: Dictionary = PartyState.get_member(_character_id)
	var equip: Dictionary = member.get("equipment", {})
	for i: int in range(_slot_labels.size()):
		if _slot_labels[i] == null:
			continue
		var slot_name: String = SLOT_NAMES[i]
		var equip_id: String = equip.get(slot_name, "")
		var item_name: String = _get_equipment_name(equip_id)
		_slot_labels[i].text = "%s: %s" % [SLOT_DISPLAY[i], item_name]
		if _state == EquipState.SLOT_SELECT and i == _slot_index:
			_slot_labels[i].modulate = COLOR_SELECTED
		else:
			_slot_labels[i].modulate = COLOR_NORMAL

	# Stat panel (current values)
	_update_stat_panel()

	# Info line
	if _info_label != null:
		_info_label.text = ""


func _update_stat_panel() -> void:
	for i: int in range(_stat_labels.size()):
		if _stat_labels[i] == null:
			continue
		var stat: String = STAT_NAMES[i]
		var current: int = PartyState.get_effective_stat(_character_id, stat)
		var bonus: int = PartyState.get_equipment_bonus(_character_id, stat)
		var bonus_str: String = "(+%d)" % bonus if bonus > 0 else ""
		_stat_labels[i].text = "%s %d %s" % [STAT_DISPLAY[i], current, bonus_str]
		_stat_labels[i].modulate = COLOR_NORMAL


func _update_item_display() -> void:
	for i: int in range(_item_labels.size()):
		if _item_labels[i] == null:
			continue
		if i == 0:
			_item_labels[i].text = "Remove"
			_item_labels[i].visible = true
			_item_labels[i].modulate = COLOR_SELECTED if _item_index == 0 else COLOR_NORMAL
		elif i - 1 < _available_items.size():
			var item: Dictionary = _available_items[i - 1]
			var equipped_by: String = _get_equipped_by(item.get("id", ""))
			var suffix: String = " E" if equipped_by != "" else ""
			_item_labels[i].text = "%s%s" % [item.get("name", "???"), suffix]
			_item_labels[i].visible = true
			_item_labels[i].modulate = COLOR_SELECTED if _item_index == i else COLOR_NORMAL
		else:
			_item_labels[i].visible = false


func _update_stat_comparison() -> void:
	if _state != EquipState.ITEM_SELECT:
		return
	var member: Dictionary = PartyState.get_member(_character_id)
	if member.is_empty():
		return

	# Calculate what stats would be with the highlighted item
	var slot: String = SLOT_NAMES[_slot_index]
	var new_equip_id: String = ""
	if _item_index > 0 and _item_index - 1 < _available_items.size():
		new_equip_id = _available_items[_item_index - 1].get("id", "")

	for i: int in range(_stat_labels.size()):
		if _stat_labels[i] == null:
			continue
		var stat: String = STAT_NAMES[i]
		var current: int = PartyState.get_effective_stat(_character_id, stat)
		var projected: int = _project_stat(member, stat, slot, new_equip_id)
		var delta: int = projected - current
		if delta > 0:
			_stat_labels[i].text = "%s %d ▲%d" % [STAT_DISPLAY[i], current, delta]
			_stat_labels[i].modulate = COLOR_STAT_UP
		elif delta < 0:
			_stat_labels[i].text = "%s %d ▼%d" % [STAT_DISPLAY[i], current, -delta]
			_stat_labels[i].modulate = COLOR_STAT_DOWN
		else:
			_stat_labels[i].text = "%s %d ──" % [STAT_DISPLAY[i], current]
			_stat_labels[i].modulate = COLOR_NORMAL


func _project_stat(member: Dictionary, stat: String, slot: String, new_equip_id: String) -> int:
	var base: int = member.get("base_stats", {}).get(stat, 0)
	var equip: Dictionary = member.get("equipment", {})
	var total: int = base
	for s: String in SLOT_NAMES:
		var eid: String = equip.get(s, "")
		if s == slot:
			eid = new_equip_id
		if eid == "":
			continue
		var item_data: Dictionary = _lookup_equipment(eid)
		total += Helpers.get_top_level_stat(item_data, s, stat)
		total += item_data.get("bonus_stats", {}).get(stat, 0)
	if stat == "hp":
		return clampi(total, 0, 14999)
	if stat == "mp":
		return clampi(total, 0, 1499)
	return clampi(total, 0, 255)


func _get_equipment_name(equip_id: String) -> String:
	if equip_id == "":
		return "---"
	var data: Dictionary = _lookup_equipment(equip_id)
	return data.get("name", equip_id)


func _get_equipped_by(equip_id: String) -> String:
	for m: Dictionary in PartyState.get_all_members():
		var equip: Dictionary = m.get("equipment", {})
		for slot: String in SLOT_NAMES:
			if equip.get(slot, "") == equip_id:
				return m.get("character_id", "")
	return ""


func _lookup_equipment(equipment_id: String) -> Dictionary:
	return Helpers.lookup_equipment(equipment_id)
