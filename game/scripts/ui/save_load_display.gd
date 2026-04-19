class_name SaveLoadDisplay
extends RefCounted
## Display/rendering helpers for the Save/Load overlay.
## Extracted from save_load.gd to keep it focused on state and input.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")

## Colors from ui-design.md Section 1.4.
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

## The owning save_load node, used to access child UI nodes.
var _owner: Node


func _init(owner: Node) -> void:
	_owner = owner


func update_slot_panel(
	panel: PanelContainer,
	data: Dictionary,
	is_auto: bool = false,
) -> void:
	var header: Label = panel.get_node_or_null("SlotLayout/HeaderRow/HeaderLabel")
	var playtime_lbl: Label = panel.get_node_or_null("SlotLayout/HeaderRow/PlaytimeLabel")
	var gold_lbl: Label = panel.get_node_or_null("SlotLayout/HeaderRow/GoldLabel")
	var party: Label = panel.get_node_or_null("SlotLayout/PartyLabel")
	if header == null or party == null:
		return
	var prefix: String = "AUTO - " if is_auto else ""
	if data.is_empty():
		_show_empty_slot(header, playtime_lbl, gold_lbl, party, prefix)
	elif data.has("error"):
		_show_corrupted_slot(header, playtime_lbl, gold_lbl, party, prefix)
	else:
		_show_populated_slot(header, playtime_lbl, gold_lbl, party, prefix, data)


func refresh_slot_display(
	manual_slots: Array[PanelContainer],
	auto_slot: PanelContainer,
	slot_previews: Array[Dictionary],
) -> void:
	for i: int in range(3):
		update_slot_panel(manual_slots[i], slot_previews[i + 1])
	if auto_slot.visible:
		update_slot_panel(auto_slot, slot_previews[0], true)


func update_save_point(options: Array[Label], selection: int) -> void:
	for i: int in range(3):
		options[i].modulate = (COLOR_SELECTED if i == selection else COLOR_NORMAL)


func update_rest(
	rest_options: Array[Label],
	rest_item_ids: Array[String],
	selection: int,
) -> void:
	var consumables: Dictionary = PartyState.get_consumables()
	for i: int in range(3):
		var item_id: String = rest_item_ids[i]
		var qty: int = consumables.get(item_id, 0)
		if qty <= 0:
			rest_options[i].modulate = COLOR_DISABLED
		elif i == selection:
			rest_options[i].modulate = COLOR_SELECTED
		else:
			rest_options[i].modulate = COLOR_NORMAL


func update_confirm(confirm_yes: Label, confirm_no: Label, selection: int) -> void:
	confirm_yes.modulate = (COLOR_SELECTED if selection == 0 else COLOR_NORMAL)
	confirm_no.modulate = (COLOR_SELECTED if selection == 1 else COLOR_NORMAL)


func update_slot_sel(
	auto_slot: PanelContainer,
	manual_slots: Array[PanelContainer],
	selected_slot: int,
	is_selectable: bool,
	cursor: Sprite2D,
) -> void:
	var panels: Array = [auto_slot] + manual_slots
	for i: int in range(4):
		var panel: PanelContainer = panels[i]
		var highlight: bool = i == selected_slot and is_selectable
		panel.modulate = (Color("#ffcc44") if highlight else Color.WHITE)
	cursor.visible = is_selectable
	if not is_selectable:
		return
	var target: PanelContainer = panels[selected_slot]
	cursor.global_position = Vector2(16, target.global_position.y + target.size.y / 2.0)


func find_consumable(item_id: String) -> Dictionary:
	var items: Array = DataManager.load_items("consumables")
	for item: Variant in items:
		if item is Dictionary and item.get("id", "") == item_id:
			return item as Dictionary
	return {}


func has_rest_item(index: int, rest_item_ids: Array[String]) -> bool:
	if index < 0 or index >= rest_item_ids.size():
		return false
	var consumables: Dictionary = PartyState.get_consumables()
	return consumables.get(rest_item_ids[index], 0) > 0


# --- Private helpers ---


func _show_empty_slot(
	header: Label,
	playtime_lbl: Label,
	gold_lbl: Label,
	party: Label,
	prefix: String,
) -> void:
	header.text = prefix + "Empty"
	header.modulate = COLOR_DISABLED
	if playtime_lbl:
		playtime_lbl.text = ""
	if gold_lbl:
		gold_lbl.text = ""
	party.text = ""


func _show_corrupted_slot(
	header: Label,
	playtime_lbl: Label,
	gold_lbl: Label,
	party: Label,
	prefix: String,
) -> void:
	header.text = prefix + "Corrupted"
	header.modulate = Color("#ff4444")
	if playtime_lbl:
		playtime_lbl.text = ""
	if gold_lbl:
		gold_lbl.text = ""
	party.text = ""


func _show_populated_slot(
	header: Label,
	playtime_lbl: Label,
	gold_lbl: Label,
	party: Label,
	prefix: String,
	data: Dictionary,
) -> void:
	var world: Dictionary = data.get("world", {})
	var raw_loc: String = world.get("current_location", "")
	var loc: String = raw_loc if raw_loc != "" else "Unknown"
	var pt: int = data.get("meta", {}).get("playtime", 0)
	header.text = "%s%s" % [prefix, loc]
	header.modulate = COLOR_NORMAL
	if playtime_lbl:
		var hrs: int = int(pt / 3600)
		var mins: int = int((pt % 3600) / 60)
		playtime_lbl.text = "%d:%02d" % [hrs, mins]
		playtime_lbl.modulate = COLOR_NORMAL
	if gold_lbl:
		gold_lbl.text = "%dg" % world.get("gold", 0)
		gold_lbl.modulate = COLOR_NORMAL
	party.text = Helpers.format_active_party_names(data)
