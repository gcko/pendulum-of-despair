extends Control
## Ley Crystal sub-screen: browse, inspect, and equip crystals.

enum CrystalState { BROWSING, DETAIL }

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")
const COLOR_STAT_UP: Color = Color("#88ff88")
const COLOR_STAT_DOWN: Color = Color("#ff8888")
const COLOR_WARNING: Color = Color("#ff8888")
const COLOR_MUTED: Color = Color("#888899")
const COLOR_XP_FILL: Color = Color("#44aacc")

const GRID_ROWS: int = 6
const GRID_COLS: int = 2
const GRID_SIZE: int = GRID_ROWS * GRID_COLS

var _character_id: String = ""
var _crystal_ids: Array[String] = []
var _cursor: int = 0
var _scroll_offset: int = 0
var _state: CrystalState = CrystalState.BROWSING
var _detail_crystal_id: String = ""

@onready var _desc_label: Label = $Layout/DescPanel/DescLabel
@onready var _name_label: Label = $Layout/TopRow/CharPanel/CharInfo/NameLabel
@onready var _lv_label: Label = $Layout/TopRow/CharPanel/CharInfo/LvLabel
@onready var _hp_label: Label = $Layout/TopRow/CharPanel/CharInfo/HPLabel
@onready var _mp_label: Label = $Layout/TopRow/CharPanel/CharInfo/MPLabel
@onready var _left_col: VBoxContainer = $Layout/CrystalPanel/CrystalGrid/LeftCol
@onready var _right_col: VBoxContainer = $Layout/CrystalPanel/CrystalGrid/RightCol
@onready var _detail_view: VBoxContainer = $Layout/CrystalPanel/DetailView
@onready var _header_label: Label = $Layout/CrystalPanel/DetailView/HeaderLabel
@onready var _xp_bar_bg: ColorRect = $Layout/CrystalPanel/DetailView/XPBarBg
@onready var _xp_bar_fill: ColorRect = $Layout/CrystalPanel/DetailView/XPBarBg/XPBarFill
@onready var _xp_label: Label = $Layout/CrystalPanel/DetailView/XPLabel
@onready var _bonus_label: Label = $Layout/CrystalPanel/DetailView/BonusLabel
@onready var _next_level_label: Label = $Layout/CrystalPanel/DetailView/NextLevelLabel
@onready var _level_up_label: Label = $Layout/CrystalPanel/DetailView/LevelUpLabel
@onready var _stat_compare_label: Label = $Layout/CrystalPanel/DetailView/StatCompareLabel
@onready var _warning_label: Label = $Layout/CrystalPanel/DetailView/WarningLabel
@onready var _crystal_labels: Array[Label] = []


func _ready() -> void:
	_crystal_labels = []
	for row: int in range(GRID_ROWS):
		var left: Label = _left_col.get_node_or_null("Crystal%d" % row)
		var right: Label = _right_col.get_node_or_null("Crystal%d" % (row + GRID_ROWS))
		if left != null:
			_crystal_labels.append(left)
		if right != null:
			_crystal_labels.append(right)
	if _detail_view != null:
		_detail_view.visible = false


## Called by menu_overlay when opening.
func open(character_id: String) -> void:
	if character_id.is_empty():
		push_error("menu_ley_crystal: open() called with empty character_id")
		return
	_character_id = character_id
	_cursor = 0
	_scroll_offset = 0
	_state = CrystalState.BROWSING
	_detail_crystal_id = ""
	_crystal_ids = PartyState.get_collected_crystals()
	_update_char_info()
	_update_grid()
	_update_desc()
	if _detail_view != null:
		_detail_view.visible = false


## Called by menu_overlay when closing.
func close() -> void:
	_state = CrystalState.BROWSING
	_detail_crystal_id = ""
	if _detail_view != null:
		_detail_view.visible = false


## Handle input, return true if consumed.
func handle_input(event: InputEvent) -> bool:
	match _state:
		CrystalState.BROWSING:
			return _handle_browse_input(event)
		CrystalState.DETAIL:
			return _handle_detail_input(event)
	return false


func _handle_browse_input(event: InputEvent) -> bool:
	var total_entries: int = _get_total_entries()
	if total_entries == 0:
		return false
	if event.is_action_pressed("ui_down"):
		var new_cursor: int = _cursor + GRID_COLS
		if new_cursor < total_entries:
			_cursor = new_cursor
			_ensure_cursor_visible()
		_update_grid()
		_update_desc()
		return true
	if event.is_action_pressed("ui_up"):
		var new_cursor: int = _cursor - GRID_COLS
		if new_cursor >= 0:
			_cursor = new_cursor
			_ensure_cursor_visible()
		_update_grid()
		_update_desc()
		return true
	if event.is_action_pressed("ui_right"):
		var col: int = _cursor % GRID_COLS
		if col == 0:
			var new_cursor: int = _cursor + 1
			if new_cursor < total_entries:
				_cursor = new_cursor
		_update_grid()
		_update_desc()
		return true
	if event.is_action_pressed("ui_left"):
		var col: int = _cursor % GRID_COLS
		if col == 1:
			_cursor -= 1
		_update_grid()
		_update_desc()
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_selection()
		return true
	return false


## Adjust scroll offset so the cursor row is visible in the grid.
func _ensure_cursor_visible() -> void:
	var cursor_row: int = _cursor / GRID_COLS
	if cursor_row < _scroll_offset:
		_scroll_offset = cursor_row
	elif cursor_row >= _scroll_offset + GRID_ROWS:
		_scroll_offset = cursor_row - GRID_ROWS + 1


func _handle_detail_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_accept"):
		var current_equipped: String = (
			PartyState.get_member(_character_id).get("equipment", {}).get("crystal", "")
		)
		if current_equipped != _detail_crystal_id:
			_equip_crystal(_detail_crystal_id)
			_update_char_info()
		_hide_detail()
		return true
	if event.is_action_pressed("ui_cancel"):
		_hide_detail()
		return true
	return false


func _confirm_selection() -> void:
	var total_crystal: int = _crystal_ids.size()
	if _cursor < total_crystal:
		var crystal_id: String = _crystal_ids[_cursor]
		_show_detail(crystal_id)
	elif _cursor == total_crystal and _has_equipped_crystal():
		PartyState.unequip_crystal(_character_id)
		_crystal_ids = PartyState.get_collected_crystals()
		_cursor = mini(_cursor, _get_total_entries() - 1)
		if _cursor < 0:
			_cursor = 0
		_update_char_info()
		_update_grid()
		_update_desc()


## Show the detail view for a crystal.
func _show_detail(crystal_id: String) -> void:
	_detail_crystal_id = crystal_id
	_state = CrystalState.DETAIL
	var static_data: Dictionary = DataManager.get_ley_crystal(crystal_id)
	if static_data.is_empty():
		push_error("menu_ley_crystal: crystal data not found for '%s'" % crystal_id)
		_hide_detail()
		return
	var runtime: Dictionary = PartyState.get_crystal_state(crystal_id)
	var level: int = runtime.get("level", 1)
	if _header_label != null:
		_header_label.text = "%s  Lv %d" % [static_data.get("name", crystal_id), level]
	_update_xp_bar(runtime, static_data)
	var current_bonus: Dictionary = CrystalDisplay.level_bonus(static_data, level)
	if _bonus_label != null:
		_bonus_label.text = "Bonus: %s" % CrystalDisplay.format_bonus(current_bonus)
	if _next_level_label != null:
		_next_level_label.text = "Next Lv: %s" % _next_level_text(static_data, level)
	if _level_up_label != null:
		_level_up_label.text = "On Lv Up: %s" % CrystalDisplay.format_bonus(current_bonus)
	if _stat_compare_label != null:
		_stat_compare_label.text = CrystalDisplay.stat_comparison(
			_character_id, crystal_id, current_bonus
		)
	var negative_effect: Variant = static_data.get("negative_effect", null)
	if _warning_label != null:
		if negative_effect != null and negative_effect is Dictionary:
			var neg_desc: String = (negative_effect as Dictionary).get("description", "")
			_warning_label.text = "Warning: %s" % neg_desc
			_warning_label.modulate = COLOR_WARNING
			_warning_label.visible = true
		else:
			_warning_label.visible = false
	# Update DescPanel with power at current level (spec: detail adds "Power: N")
	if _desc_label != null:
		_desc_label.text = CrystalDisplay.invocation_text(static_data, level)
		_desc_label.modulate = COLOR_NORMAL
	if _detail_view != null:
		_detail_view.visible = true


## Return to BROWSING state without changes.
func _hide_detail() -> void:
	_detail_crystal_id = ""
	_state = CrystalState.BROWSING
	if _detail_view != null:
		_detail_view.visible = false
	_update_grid()
	_update_desc()


## Equip a crystal on the current character via PartyState API.
func _equip_crystal(crystal_id: String) -> void:
	PartyState.equip_crystal(_character_id, crystal_id)


func _update_xp_bar(runtime: Dictionary, static_data: Dictionary) -> void:
	var progress: Dictionary = CrystalDisplay.xp_progress(runtime, static_data)
	if _xp_bar_fill != null:
		_xp_bar_fill.color = COLOR_XP_FILL
	if _xp_label != null:
		_xp_label.text = progress["label"]
	if _xp_bar_fill != null and _xp_bar_bg != null and progress["has_ratio"]:
		_xp_bar_fill.size.x = _xp_bar_bg.size.x * float(progress["fill_ratio"])


## The "Next Lv" line: MAX at the cap, and deliberately withheld for a crystal
## whose Lv5 bonus is a secret until it is earned.
func _next_level_text(static_data: Dictionary, level: int) -> String:
	if level >= PartyCrystals.MAX_LEVEL:
		return "MAX"
	if static_data.get("secret_lv5", false) and level == PartyCrystals.MAX_LEVEL - 1:
		return "???"
	return CrystalDisplay.format_bonus(CrystalDisplay.level_bonus(static_data, level + 1))


func _update_char_info() -> void:
	var member: Dictionary = PartyState.get_member(_character_id)
	if _name_label != null:
		_name_label.text = _character_id.to_upper()
	if _lv_label != null:
		_lv_label.text = "LV %d" % member.get("level", 1)
	if _hp_label != null:
		_hp_label.text = "HP %d/%d" % [member.get("current_hp", 0), member.get("max_hp", 1)]
	if _mp_label != null:
		_mp_label.text = "MP %d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]


func _update_grid() -> void:
	var total_entries: int = _get_total_entries()
	var visible_start: int = _scroll_offset * GRID_COLS
	for i: int in range(_crystal_labels.size()):
		var label: Label = _crystal_labels[i]
		if label == null:
			continue
		var data_index: int = visible_start + i
		if data_index >= total_entries:
			label.text = ""
			label.visible = false
			continue
		label.visible = true
		if data_index < _crystal_ids.size():
			var crystal_id: String = _crystal_ids[data_index]
			var static_data: Dictionary = DataManager.get_ley_crystal(crystal_id)
			var runtime: Dictionary = PartyState.get_crystal_state(crystal_id)
			var level: int = runtime.get("level", 1)
			var crystal_name: String = static_data.get("name", crystal_id)
			var equipped_by: String = CrystalDisplay.equipped_by(crystal_id)
			var is_equipped_by_other: bool = (
				not equipped_by.is_empty() and equipped_by != _character_id
			)
			var prefix: String = "E " if is_equipped_by_other else "  "
			label.text = "%s%-14s Lv%d" % [prefix, crystal_name, level]
			if data_index == _cursor:
				label.modulate = COLOR_SELECTED
			elif is_equipped_by_other:
				label.modulate = COLOR_DISABLED
			else:
				label.modulate = COLOR_NORMAL
		else:
			# "Remove" entry
			label.text = "  Remove"
			label.modulate = COLOR_SELECTED if data_index == _cursor else COLOR_MUTED


func _update_desc() -> void:
	if _desc_label == null:
		return
	var total_crystal: int = _crystal_ids.size()
	if total_crystal == 0 and not _has_equipped_crystal():
		_desc_label.text = "No crystals collected."
		return
	if _cursor < total_crystal:
		var crystal_id: String = _crystal_ids[_cursor]
		_desc_label.text = CrystalDisplay.invocation_text(DataManager.get_ley_crystal(crystal_id))
		_desc_label.modulate = COLOR_NORMAL
		var equipped_by: String = CrystalDisplay.equipped_by(crystal_id)
		if not equipped_by.is_empty() and equipped_by != _character_id:
			_desc_label.modulate = COLOR_DISABLED
	elif _cursor == total_crystal and _has_equipped_crystal():
		_desc_label.text = "Remove equipped crystal."
		_desc_label.modulate = COLOR_MUTED
	else:
		_desc_label.text = ""


func _get_total_entries() -> int:
	var count: int = _crystal_ids.size()
	if _has_equipped_crystal():
		count += 1
	return count


func _has_equipped_crystal() -> bool:
	var member: Dictionary = PartyState.get_member(_character_id)
	if member.is_empty():
		return false
	return not member.get("equipment", {}).get("crystal", "").is_empty()
