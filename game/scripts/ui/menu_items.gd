extends Control
## Items sub-screen: USE / ARRANGE / KEY tabs with two-column item list.

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

enum ItemTab { USE, ARRANGE, KEY }
enum ItemState { BROWSING, TARGET_SELECT }

var _tab: ItemTab = ItemTab.USE
var _state: ItemState = ItemState.BROWSING
var _cursor_index: int = 0
var _target_index: int = 0
var _items: Array[Dictionary] = []
var _sort_mode: int = 0  # 0=type, 1=name, 2=quantity

@onready var _tab_labels: Array[Label] = []
@onready var _desc_label: Label = $DescLabel
@onready var _item_container: Control = $ItemContainer
@onready var _item_labels: Array[Label] = []
@onready var _target_panel: Control = $TargetPanel
@onready var _target_labels: Array[Label] = []


func _ready() -> void:
	_tab_labels = []
	for tab_name: String in ["UseTab", "ArrangeTab", "KeyTab"]:
		var label: Label = get_node_or_null("TabBar/" + tab_name)
		if label != null:
			_tab_labels.append(label)
	_item_labels = []
	for i: int in range(12):
		var label: Label = get_node_or_null("ItemContainer/Item%d" % i)
		if label != null:
			_item_labels.append(label)
	_target_labels = []
	for i: int in range(4):
		var label: Label = get_node_or_null("TargetPanel/Target%d" % i)
		if label != null:
			_target_labels.append(label)
	if _target_panel != null:
		_target_panel.visible = false


## Called by menu_overlay when opening.
func open() -> void:
	_tab = ItemTab.USE
	_cursor_index = 0
	_state = ItemState.BROWSING
	_refresh_items()
	_update_display()


## Called by menu_overlay when closing.
func close() -> void:
	if _target_panel != null:
		_target_panel.visible = false


## Handle input, return true if consumed.
func handle_input(event: InputEvent) -> bool:
	match _state:
		ItemState.BROWSING:
			return _handle_browse_input(event)
		ItemState.TARGET_SELECT:
			return _handle_target_input(event)
	return false


func _handle_browse_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_down"):
		if _items.size() > 0:
			_cursor_index = (_cursor_index + 1) % _items.size()
			_update_display()
		return true
	if event.is_action_pressed("ui_up"):
		if _items.size() > 0:
			_cursor_index = (_cursor_index - 1 + _items.size()) % _items.size()
			_update_display()
		return true
	if event.is_action_pressed("ui_page_down") or event.is_action_pressed("ui_right"):
		_switch_tab(1)
		return true
	if event.is_action_pressed("ui_page_up") or event.is_action_pressed("ui_left"):
		_switch_tab(-1)
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_item()
		return true
	return false


func _handle_target_input(event: InputEvent) -> bool:
	var party: Array[Dictionary] = PartyState.get_active_party()
	if party.is_empty():
		return false
	if event.is_action_pressed("ui_down"):
		_target_index = (_target_index + 1) % party.size()
		_update_target_display()
		return true
	if event.is_action_pressed("ui_up"):
		_target_index = (_target_index - 1 + party.size()) % party.size()
		_update_target_display()
		return true
	if event.is_action_pressed("ui_accept"):
		_use_on_target()
		return true
	if event.is_action_pressed("ui_cancel"):
		_target_panel.visible = false
		_state = ItemState.BROWSING
		return true
	return false


func _confirm_item() -> void:
	if _tab == ItemTab.ARRANGE:
		_sort_mode = (_sort_mode + 1) % 3
		_refresh_items()
		_update_display()
		return
	if _tab == ItemTab.KEY:
		return  # Key items are view-only
	if _cursor_index >= _items.size():
		return
	var item: Dictionary = _items[_cursor_index]
	if not item.get("usable_in_field", false):
		return
	# Open target select
	_state = ItemState.TARGET_SELECT
	_target_index = 0
	_target_panel.visible = true
	_update_target_display()


func _use_on_target() -> void:
	if _cursor_index >= _items.size():
		return
	var item: Dictionary = _items[_cursor_index]
	var party: Array[Dictionary] = PartyState.get_active_party()
	if _target_index >= party.size():
		return
	var target_id: String = party[_target_index].get("character_id", "")
	var ok: bool = PartyState.use_item(item.get("id", ""), target_id)
	if ok:
		_refresh_items()
		if _cursor_index >= _items.size() and _items.size() > 0:
			_cursor_index = _items.size() - 1
		_update_display()
		_update_target_display()
	# Stay in target select to allow using more


func _switch_tab(direction: int) -> void:
	var new_tab: int = (_tab + direction + 3) % 3
	_tab = new_tab as ItemTab
	_cursor_index = 0
	_refresh_items()
	_update_display()


func _refresh_items() -> void:
	_items.clear()
	match _tab:
		ItemTab.USE, ItemTab.ARRANGE:
			var consumables: Dictionary = PartyState.get_consumables()
			for item_id: String in consumables:
				var data: Dictionary = _lookup_consumable(item_id)
				if data.is_empty():
					continue
				data["quantity"] = consumables[item_id]
				_items.append(data)
			if _tab == ItemTab.ARRANGE:
				_sort_items()
		ItemTab.KEY:
			var key_items: Array = PartyState.get_key_items()
			for kid: Variant in key_items:
				_items.append({"id": kid, "name": str(kid), "description": "Key item"})


func _sort_items() -> void:
	match _sort_mode:
		0:  # Type (subcategory)
			_items.sort_custom(
				func(a: Dictionary, b: Dictionary) -> bool:
					return a.get("subcategory", "") < b.get("subcategory", "")
			)
		1:  # Name
			_items.sort_custom(
				func(a: Dictionary, b: Dictionary) -> bool:
					return a.get("name", "") < b.get("name", "")
			)
		2:  # Quantity
			_items.sort_custom(
				func(a: Dictionary, b: Dictionary) -> bool:
					return a.get("quantity", 0) > b.get("quantity", 0)
			)


func _update_display() -> void:
	# Tabs
	for i: int in range(_tab_labels.size()):
		if _tab_labels[i] != null:
			_tab_labels[i].modulate = COLOR_SELECTED if i == _tab else COLOR_NORMAL
	# Description
	if _desc_label != null:
		if _cursor_index < _items.size():
			_desc_label.text = _items[_cursor_index].get("description", "")
		else:
			_desc_label.text = ""
	# Item list
	for i: int in range(_item_labels.size()):
		if _item_labels[i] == null:
			continue
		if i < _items.size():
			var item: Dictionary = _items[i]
			var qty: int = item.get("quantity", 0)
			var qty_str: String = ":%d" % qty if qty > 0 else ""
			_item_labels[i].text = "%s %s" % [item.get("name", ""), qty_str]
			_item_labels[i].visible = true
			var is_usable: bool = item.get("usable_in_field", false)
			if i == _cursor_index:
				_item_labels[i].modulate = COLOR_SELECTED
			elif not is_usable and _tab == ItemTab.USE:
				_item_labels[i].modulate = COLOR_DISABLED
			else:
				_item_labels[i].modulate = COLOR_NORMAL
		else:
			_item_labels[i].visible = false


func _update_target_display() -> void:
	var party: Array[Dictionary] = PartyState.get_active_party()
	for i: int in range(_target_labels.size()):
		if _target_labels[i] == null:
			continue
		if i < party.size():
			var m: Dictionary = party[i]
			_target_labels[i].text = (
				"%s  HP %d/%d  MP %d/%d"
				% [
					m.get("character_id", "").to_upper(),
					m.get("current_hp", 0),
					m.get("max_hp", 1),
					m.get("current_mp", 0),
					m.get("max_mp", 0),
				]
			)
			_target_labels[i].visible = true
			_target_labels[i].modulate = COLOR_SELECTED if i == _target_index else COLOR_NORMAL
		else:
			_target_labels[i].visible = false


func _lookup_consumable(item_id: String) -> Dictionary:
	var items: Array = DataManager.load_items("consumables")
	for item: Variant in items:
		if item is Dictionary and (item as Dictionary).get("id", "") == item_id:
			return (item as Dictionary).duplicate()
	return {}
