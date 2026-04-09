extends Control
## Formation sub-screen: party reorder and row toggle.

enum FormationState { BROWSING, SWAP_SELECT }

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_SWAP: Color = Color("#88ffff")
const COLOR_RESERVE: Color = Color("#999999")
const MAX_SLOTS: int = 6

var _members: Array = []
var _cursor: int = 0
var _swap_source: int = -1
var _state: FormationState = FormationState.BROWSING

@onready var _member_labels: Array[Label] = []
@onready var _swap_label: Label = $Layout/HintPanel/SwapLabel


func _ready() -> void:
	_member_labels = []
	for i: int in range(MAX_SLOTS):
		var label: Label = get_node_or_null("Layout/MemberPanel/MemberList/Member%d" % i)
		if label != null:
			_member_labels.append(label)


func open() -> void:
	_members = PartyState.get_formation_list()
	_cursor = 0
	_swap_source = -1
	_state = FormationState.BROWSING
	_swap_label.visible = false
	_refresh_labels()


func close() -> void:
	_state = FormationState.BROWSING
	_swap_source = -1


func handle_input(event: InputEvent) -> bool:
	if _members.is_empty():
		return false
	match _state:
		FormationState.BROWSING:
			return _handle_browse(event)
		FormationState.SWAP_SELECT:
			return _handle_swap(event)
	return false


func _handle_browse(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_down"):
		_cursor = (_cursor + 1) % _members.size()
		_refresh_labels()
		return true
	if event.is_action_pressed("ui_up"):
		_cursor = (_cursor - 1 + _members.size()) % _members.size()
		_refresh_labels()
		return true
	if event.is_action_pressed("ui_accept"):
		_swap_source = _cursor
		_state = FormationState.SWAP_SELECT
		_swap_label.text = "Swap with?"
		_swap_label.visible = true
		_refresh_labels()
		return true
	if event.is_action_pressed("ui_page_up") or event.is_action_pressed("ui_page_down"):
		_toggle_row_at_cursor()
		return true
	return false


func _handle_swap(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_down"):
		_cursor = (_cursor + 1) % _members.size()
		_refresh_labels()
		return true
	if event.is_action_pressed("ui_up"):
		_cursor = (_cursor - 1 + _members.size()) % _members.size()
		_refresh_labels()
		return true
	if event.is_action_pressed("ui_accept"):
		var src_idx: int = _members[_swap_source].get("_formation_index", _swap_source)
		var dst_idx: int = _members[_cursor].get("_formation_index", _cursor)
		PartyState.swap_formation_positions(src_idx, dst_idx)
		_members = PartyState.get_formation_list()
		_swap_source = -1
		_state = FormationState.BROWSING
		_swap_label.visible = false
		_refresh_labels()
		return true
	if event.is_action_pressed("ui_cancel"):
		_swap_source = -1
		_state = FormationState.BROWSING
		_swap_label.visible = false
		_refresh_labels()
		return true
	return false


func _toggle_row_at_cursor() -> void:
	if _cursor >= _members.size():
		return
	var member: Dictionary = _members[_cursor]
	if not member.get("_is_active", false):
		return
	var cid: String = member.get("character_id", "")
	if cid.is_empty():
		return
	PartyState.toggle_row(cid)
	_members = PartyState.get_formation_list()
	_refresh_labels()


func _refresh_labels() -> void:
	for i: int in range(_member_labels.size()):
		var label: Label = _member_labels[i]
		if i >= _members.size():
			label.text = ""
			label.modulate = COLOR_NORMAL
			continue
		var m: Dictionary = _members[i]
		var cid: String = m.get("character_id", "???")
		var lv: int = m.get("level", 1)
		var hp: int = m.get("current_hp", 0)
		var max_hp: int = m.get("max_hp", 1)
		var is_active: bool = m.get("_is_active", false)
		if is_active:
			var row: String = "F" if PartyState.get_row(cid) == "front" else "B"
			label.text = "%-8s %s  LV%2d  HP %d/%d" % [cid.to_upper(), row, lv, hp, max_hp]
		else:
			label.text = "%-8s     LV%2d  HP %d/%d" % [cid.to_upper(), lv, hp, max_hp]
		label.modulate = _get_label_color(i, is_active)


func _get_label_color(index: int, is_active: bool) -> Color:
	if _swap_source == index:
		return COLOR_SWAP
	if index == _cursor:
		return COLOR_SELECTED
	if not is_active:
		return COLOR_RESERVE
	return COLOR_NORMAL
