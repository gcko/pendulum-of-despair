class_name MenuPartyPanel
extends RefCounted
## Rendering for the pause menu's left-hand side: the four party rows with
## their HP/MP numerics and fill bars, the selection highlight, and the
## gold/playtime/location info panel (ui-design.md § 3.3).
##
## Extracted from menu_overlay.gd (GAP-087), which keeps the menu's state
## machine and sub-screen dispatch. This module owns the row nodes it draws
## into and never reads input.

## Party rows are fixed at four slots — the active party's size.
const ROW_COUNT: int = 4

var _rows: Array[Control] = []
var _gold_label: Label = null
var _time_label: Label = null
var _location_label: Label = null
var _selected_color: Color = Color.WHITE
var _gold_color: Color = Color.WHITE


## Bind the panel to its nodes. [param overlay] is the menu root (a
## CanvasLayer) that the row and info-panel paths are resolved against.
func _init(overlay: Node, selected_color: Color, gold_color: Color) -> void:
	_selected_color = selected_color
	_gold_color = gold_color
	for i: int in range(ROW_COUNT):
		_rows.append(overlay.get_node_or_null("MainPanel/Margin/Rows/Row%d" % i))
	_gold_label = overlay.get_node_or_null("InfoPanel/Margin/Layout/RightCol/GoldLabel")
	_time_label = overlay.get_node_or_null("InfoPanel/Margin/Layout/RightCol/TimeLabel")
	_location_label = overlay.get_node_or_null("InfoPanel/Margin/Layout/LocationLabel")


## Draw one row per active member and hide the rest.
func update_rows(active_party: Array[Dictionary]) -> void:
	for i: int in range(ROW_COUNT):
		if _rows[i] == null:
			continue
		if i >= active_party.size():
			_rows[i].visible = false
			continue
		_rows[i].visible = true
		update_row(i, active_party[i])


## Highlight the row at [param char_index]; pass -1 to clear the highlight.
func highlight(char_index: int) -> void:
	for i: int in range(_rows.size()):
		if _rows[i] == null:
			continue
		var name_lbl: Label = _rows[i].get_node_or_null("NameLabel")
		if name_lbl != null:
			name_lbl.modulate = _selected_color if i == char_index else Color.WHITE


## Refresh gold, playtime and the current place name.
func update_info_panel() -> void:
	if _gold_label != null:
		_gold_label.text = "%s Gold" % format_number(PartyState.get_gold())
		_gold_label.modulate = _gold_color
	if _time_label != null:
		var total: int = PartyState.playtime
		_time_label.text = "%d:%02d" % [total / 3600, (total % 3600) / 60]
	if _location_label != null:
		_location_label.text = PartyState.get_location_display()


## Thousands-separated integer, e.g. 12345 -> "12,345".
static func format_number(value: int) -> String:
	var s: String = str(value)
	if value < 1000:
		return s
	var parts: Array[String] = []
	while s.length() > 3:
		parts.insert(0, s.right(3))
		s = s.left(s.length() - 3)
	parts.insert(0, s)
	return ",".join(parts)


## Draw one row from a member dictionary.
func update_row(slot: int, member: Dictionary) -> void:
	var row: Control = _rows[slot]
	if row == null:
		return
	var name_label: Label = row.get_node_or_null("NameLabel")
	if name_label != null:
		name_label.text = member.get("character_id", "???").to_upper()
		name_label.modulate = Color.WHITE
	var lv_label: Label = row.get_node_or_null("LvLabel")
	if lv_label != null:
		lv_label.text = "LV %d" % member.get("level", 1)
	var hp: int = member.get("current_hp", 0)
	var max_hp: int = member.get("max_hp", 1)
	var hp_color: Color = StatBarHelpers.hp_fill_color(hp, max_hp)
	var hp_label: Label = row.get_node_or_null("HPCluster/HPLabel")
	if hp_label != null:
		hp_label.text = "HP %d/%d" % [hp, max_hp]
		hp_label.modulate = hp_color
	_set_bar_fill(row, "HPCluster/HPBarBg", hp, max_hp, hp_color)
	var mp: int = member.get("current_mp", 0)
	var max_mp: int = member.get("max_mp", 0)
	var mp_label: Label = row.get_node_or_null("MPCluster/MPLabel")
	if mp_label != null:
		mp_label.text = "MP %d/%d" % [mp, max_mp]
		mp_label.modulate = StatBarHelpers.COLOR_MP_FILL
	_set_bar_fill(row, "MPCluster/MPBarBg", mp, max_mp, StatBarHelpers.COLOR_MP_FILL)


## Solid pixel fill bars alongside the numerics (ui-design.md § 3.3).
## Fill width is set against the track's authored width — deterministic
## under headless container layout.
func _set_bar_fill(
	row: Control, bg_path: String, current: int, max_value: int, fill_color: Color
) -> void:
	var bg: ColorRect = row.get_node_or_null(bg_path)
	if bg == null:
		return
	var fill: ColorRect = bg.get_node_or_null("%sFill" % bg_path.get_file().trim_suffix("Bg"))
	if fill == null:
		return
	fill.size.x = StatBarHelpers.fill_width(current, max_value, bg.custom_minimum_size.x)
	fill.color = fill_color
