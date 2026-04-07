extends CanvasLayer
## Buy-only shop overlay for town NPCs.
## Opened via GameManager.push_overlay(SHOP) with transition_data {"shop_id": "..."}
##
## Usage: push_overlay sets transition_data["shop_id"] before instantiating.
## Reads shop data from DataManager.load_shop(shop_id), resolves item names
## from consumables/weapons/armor/accessories, and presents a scrollable list.

## Duration to show feedback messages before clearing them.
const FEEDBACK_CLEAR_DELAY: float = 1.5

## Highlight color for selected row.
const COLOR_SELECTED: Color = Color("#ffff88")
## Normal row color.
const COLOR_NORMAL: Color = Color("#ccddff")

## Resolved inventory: array of {item_id, name, buy_price}.
var _inventory: Array = []
## Set of equipment item_ids (buy routes to owned_equipment, not consumables).
var _equipment_ids: Dictionary = {}
## Currently highlighted row index.
var _selected: int = 0
## Timer accumulator for clearing feedback text.
var _feedback_timer: float = 0.0
## Whether a feedback message is showing.
var _showing_feedback: bool = false

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _item_list_container: VBoxContainer = $Panel/VBox/ScrollContainer/ItemList
@onready var _gold_label: Label = $Panel/VBox/GoldLabel
@onready var _desc_label: Label = $Panel/VBox/DescLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shop_id: String = GameManager.transition_data.get("shop_id", "")
	_load_shop(shop_id)
	_build_list()
	_refresh_gold()
	_update_selection()


func _process(delta: float) -> void:
	if not _showing_feedback:
		return
	_feedback_timer -= delta
	if _feedback_timer <= 0.0:
		_showing_feedback = false
		_desc_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if _inventory.is_empty():
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_close()
		return

	if event.is_action_pressed("ui_up"):
		_selected = (_selected - 1 + _inventory.size()) % _inventory.size()
		_update_selection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_selected = (_selected + 1) % _inventory.size()
		_update_selection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_try_buy()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


## Load and resolve shop inventory from DataManager.
func _load_shop(shop_id: String) -> void:
	if shop_id == "":
		_title_label.text = "SHOP"
		return

	var raw: Dictionary = DataManager.load_shop(shop_id)
	var shop: Dictionary = raw.get("shop", {})
	_title_label.text = shop.get("shop_id", shop_id).replace("_", " ").to_upper()

	var name_map: Dictionary = _build_name_map()
	var raw_inventory: Variant = shop.get("inventory", [])
	if not raw_inventory is Array:
		return

	for entry: Variant in raw_inventory:
		if not entry is Dictionary:
			continue
		var item_id: String = entry.get("item_id", "")
		var buy_price: int = entry.get("buy_price", 0)
		if item_id == "":
			continue
		var display_name: String = name_map.get(item_id, item_id)
		_inventory.append({"item_id": item_id, "name": display_name, "buy_price": buy_price})


## Build item_id -> name map from all known data sources.
func _build_name_map() -> Dictionary:
	var result: Dictionary = {}
	for item: Variant in DataManager.load_items("consumables"):
		if item is Dictionary:
			result[item.get("id", "")] = item.get("name", "")
	for item: Variant in DataManager.load_items("key_items"):
		if item is Dictionary:
			result[item.get("id", "")] = item.get("name", "")
	for eq_type: String in ["weapons", "armor", "accessories"]:
		for item: Variant in DataManager.load_equipment(eq_type):
			if item is Dictionary:
				var eid: String = item.get("id", "")
				result[eid] = item.get("name", "")
				_equipment_ids[eid] = true
	return result


## Populate the ItemList VBoxContainer with one Label per entry.
func _build_list() -> void:
	for child: Node in _item_list_container.get_children():
		child.queue_free()

	if _inventory.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No items available."
		_item_list_container.add_child(empty_lbl)
		return

	for entry: Dictionary in _inventory:
		var lbl: Label = Label.new()
		lbl.text = "%s  %dG" % [entry["name"], entry["buy_price"]]
		_item_list_container.add_child(lbl)


## Highlight selected row and clear stale feedback.
func _update_selection() -> void:
	var children: Array = _item_list_container.get_children()
	for i: int in range(children.size()):
		var lbl: Node = children[i]
		if lbl is Label:
			(lbl as Label).modulate = COLOR_SELECTED if i == _selected else COLOR_NORMAL


## Attempt to buy the selected item.
func _try_buy() -> void:
	if _inventory.is_empty():
		return
	var entry: Dictionary = _inventory[_selected]
	var price: int = entry["buy_price"]
	if PartyState.spend_gold(price):
		var iid: String = entry["item_id"]
		if _equipment_ids.has(iid):
			PartyState.add_equipment(iid)
		else:
			PartyState.add_item(iid, 1)
		_refresh_gold()
		_show_feedback("Purchased!")
	else:
		_show_feedback("Not enough gold.")


func _refresh_gold() -> void:
	_gold_label.text = "Gold: %dG" % PartyState.get_gold()


func _show_feedback(msg: String) -> void:
	_desc_label.text = msg
	_feedback_timer = FEEDBACK_CLEAR_DELAY
	_showing_feedback = true


## Close the overlay. MUST be last — scene teardown follows immediately.
func _close() -> void:
	GameManager.pop_overlay()
