extends Control
## Abilities sub-screen: view-only list of character's unique commands.

const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const GRID_ROWS: int = 6
const GRID_COLS: int = 2
const GRID_SIZE: int = GRID_ROWS * GRID_COLS

var _character_id: String = ""
var _abilities: Array = []
var _cursor: int = 0
var _scroll_offset: int = 0

@onready var _desc_label: Label = $DescLabel
@onready var _name_label: Label = $CharInfo/NameLabel
@onready var _lv_label: Label = $CharInfo/LvLabel
@onready var _resource_label: Label = $CharInfo/ResourceLabel
@onready var _left_col: VBoxContainer = $AbilityGrid/LeftCol
@onready var _right_col: VBoxContainer = $AbilityGrid/RightCol
@onready var _ability_labels: Array[Label] = []


func _ready() -> void:
	_ability_labels = []
	for row: int in range(GRID_ROWS):
		var left: Label = _left_col.get_node_or_null("Ability%d" % row)
		var right: Label = _right_col.get_node_or_null("Ability%d" % (row + GRID_ROWS))
		if left != null:
			_ability_labels.append(left)
		if right != null:
			_ability_labels.append(right)


## Called by menu_overlay when opening.
func open(character_id: String) -> void:
	_character_id = character_id
	_cursor = 0
	_scroll_offset = 0
	var member: Dictionary = PartyState.get_member(character_id)
	var level: int = member.get("level", 1)
	_abilities = AbilityHelpers.get_known_abilities(character_id, level)
	_update_char_info()
	_update_grid()
	_update_desc()


## Called by menu_overlay when closing.
func close() -> void:
	pass


## Handle input, return true if consumed.
func handle_input(event: InputEvent) -> bool:
	if _abilities.is_empty():
		return false
	var visible_count: int = mini(_abilities.size() - _scroll_offset, GRID_SIZE)
	if visible_count <= 0:
		return false
	if event.is_action_pressed("ui_down"):
		var new_cursor: int = _cursor + GRID_COLS
		if new_cursor < visible_count:
			_cursor = new_cursor
		_update_grid()
		_update_desc()
		return true
	if event.is_action_pressed("ui_up"):
		var new_cursor: int = _cursor - GRID_COLS
		if new_cursor >= 0:
			_cursor = new_cursor
		_update_grid()
		_update_desc()
		return true
	if event.is_action_pressed("ui_right"):
		var col: int = _cursor % GRID_COLS
		if col == 0:
			var new_cursor: int = _cursor + 1
			if new_cursor < visible_count:
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
		return true
	return false


func _update_char_info() -> void:
	var member: Dictionary = PartyState.get_member(_character_id)
	_name_label.text = _character_id.to_upper()
	_lv_label.text = "LV %d" % member.get("level", 1)
	_resource_label.text = AbilityHelpers.get_resource_label(_character_id, member)


func _update_grid() -> void:
	var visible_count: int = mini(_abilities.size() - _scroll_offset, GRID_SIZE)
	for i: int in range(_ability_labels.size()):
		if i < visible_count:
			var ability: Dictionary = _abilities[_scroll_offset + i]
			var ability_name: String = ability.get("name", "???")
			if ability_name.length() > 12:
				ability_name = ability_name.left(12)
			var cost_str: String = AbilityHelpers.format_cost(ability)
			_ability_labels[i].text = "%-12s %6s" % [ability_name, cost_str]
			_ability_labels[i].visible = true
			if i == _cursor:
				_ability_labels[i].modulate = COLOR_SELECTED
			else:
				_ability_labels[i].modulate = COLOR_NORMAL
		else:
			_ability_labels[i].text = ""
			_ability_labels[i].visible = false


func _update_desc() -> void:
	if _abilities.is_empty():
		_desc_label.text = "No abilities learned."
		return
	var ability_index: int = _scroll_offset + _cursor
	if ability_index < _abilities.size():
		_desc_label.text = _abilities[ability_index].get("description", "")
	else:
		_desc_label.text = ""
