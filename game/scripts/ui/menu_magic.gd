extends Control
## Magic sub-screen: two-column spell grid with field-cast support.

enum MagicState { BROWSING, TARGET_SELECT }

const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")
const GRID_ROWS: int = 6
const GRID_COLS: int = 2
const GRID_SIZE: int = GRID_ROWS * GRID_COLS
const FEEDBACK_DELAY: float = 1.5

var _character_id: String = ""
var _spells: Array = []
var _cursor: int = 0
var _scroll_offset: int = 0
var _target_index: int = 0
var _state: MagicState = MagicState.BROWSING
var _feedback_timer: float = 0.0
var _showing_feedback: bool = false

@onready var _desc_label: Label = $Layout/DescPanel/DescLabel
@onready var _name_label: Label = $Layout/CharPanel/CharInfo/NameLabel
@onready var _lv_label: Label = $Layout/CharPanel/CharInfo/LvLabel
@onready var _hp_label: Label = $Layout/CharPanel/CharInfo/HPLabel
@onready var _mp_label: Label = $Layout/CharPanel/CharInfo/MPLabel
@onready var _left_col: VBoxContainer = $Layout/SpellPanel/SpellGrid/LeftCol
@onready var _right_col: VBoxContainer = $Layout/SpellPanel/SpellGrid/RightCol
@onready var _target_panel: PanelContainer = $Layout/TargetPanel
@onready var _spell_labels: Array[Label] = []
@onready var _target_labels: Array[Label] = []


func _ready() -> void:
	_spell_labels = []
	for row: int in range(GRID_ROWS):
		var left: Label = _left_col.get_node_or_null("Spell%d" % row)
		var right: Label = _right_col.get_node_or_null("Spell%d" % (row + GRID_ROWS))
		if left != null:
			_spell_labels.append(left)
		if right != null:
			_spell_labels.append(right)
	_target_labels = []
	for i: int in range(4):
		var label: Label = _target_panel.get_node_or_null("TargetList/Target%d" % i)
		if label != null:
			_target_labels.append(label)
	_target_panel.visible = false


## Called by menu_overlay when opening.
func open(character_id: String) -> void:
	_character_id = character_id
	_cursor = 0
	_scroll_offset = 0
	_state = MagicState.BROWSING
	_showing_feedback = false
	_feedback_timer = 0.0
	var member: Dictionary = PartyState.get_member(character_id)
	var level: int = member.get("level", 1)
	_spells = SpellHelpers.get_known_spells(character_id, level)
	_update_char_info()
	_update_grid()
	_update_desc()


## Called by menu_overlay when closing.
func close() -> void:
	_target_panel.visible = false
	_state = MagicState.BROWSING
	_showing_feedback = false


## Handle input, return true if consumed.
func handle_input(event: InputEvent) -> bool:
	if _showing_feedback:
		if event.is_action_pressed("ui_cancel"):
			_showing_feedback = false
			return false
		return true
	match _state:
		MagicState.BROWSING:
			return _handle_browse_input(event)
		MagicState.TARGET_SELECT:
			return _handle_target_input(event)
	return false


func _process(delta: float) -> void:
	if not _showing_feedback:
		return
	_feedback_timer -= delta
	if _feedback_timer <= 0.0:
		_showing_feedback = false
		_desc_label.text = ""
		_update_desc()


func _handle_browse_input(event: InputEvent) -> bool:
	if _spells.is_empty():
		return false
	var visible_count: int = mini(_spells.size() - _scroll_offset, GRID_SIZE)
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
		_confirm_spell()
		return true
	return false


func _handle_target_input(event: InputEvent) -> bool:
	var party: Array[Dictionary] = PartyState.get_active_party()
	var living: Array[Dictionary] = _get_living_members(party)
	if living.is_empty():
		return false
	if event.is_action_pressed("ui_down"):
		_target_index = (_target_index + 1) % living.size()
		_update_target_display()
		return true
	if event.is_action_pressed("ui_up"):
		_target_index = (_target_index - 1 + living.size()) % living.size()
		_update_target_display()
		return true
	if event.is_action_pressed("ui_accept"):
		_cast_on_target(living)
		return true
	if event.is_action_pressed("ui_cancel"):
		_target_panel.visible = false
		_state = MagicState.BROWSING
		return true
	return false


func _confirm_spell() -> void:
	var spell_index: int = _scroll_offset + _cursor
	if spell_index >= _spells.size():
		return
	var spell: Dictionary = _spells[spell_index]
	if not SpellHelpers.can_field_cast(spell):
		_show_feedback("Can't use here.")
		return
	var mp_cost: int = spell.get("mp_cost", 0)
	var member: Dictionary = PartyState.get_member(_character_id)
	if member.get("current_mp", 0) < mp_cost:
		_show_feedback("Not enough MP.")
		return
	_state = MagicState.TARGET_SELECT
	_target_index = 0
	_target_panel.visible = true
	_update_target_display()


func _cast_on_target(living: Array[Dictionary]) -> void:
	var spell_index: int = _scroll_offset + _cursor
	if spell_index >= _spells.size():
		return
	if _target_index >= living.size():
		return
	var spell: Dictionary = _spells[spell_index]
	var mp_cost: int = spell.get("mp_cost", 0)
	if mp_cost > 0 and not PartyState.spend_mp(_character_id, mp_cost):
		_show_feedback("Not enough MP.")
		return
	var target_id: String = living[_target_index].get("character_id", "")
	var caster_mag: int = PartyState.get_effective_stat(_character_id, "mag")
	var heal_amount: int = SpellHelpers.get_field_heal_amount(caster_mag, spell)
	var restored: int = 0
	if heal_amount > 0:
		restored = PartyState.heal_member(target_id, heal_amount)
	_target_panel.visible = false
	_state = MagicState.BROWSING
	_show_feedback("Restored %d HP!" % restored if restored > 0 else "No effect.")
	_update_char_info()
	_update_grid()


func _show_feedback(msg: String) -> void:
	_desc_label.text = msg
	_feedback_timer = FEEDBACK_DELAY
	_showing_feedback = true


func _update_char_info() -> void:
	var member: Dictionary = PartyState.get_member(_character_id)
	_name_label.text = _character_id.to_upper()
	_lv_label.text = "LV %d" % member.get("level", 1)
	_hp_label.text = "HP %d/%d" % [member.get("current_hp", 0), member.get("max_hp", 1)]
	_mp_label.text = "MP %d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]


func _update_grid() -> void:
	var visible_count: int = mini(_spells.size() - _scroll_offset, GRID_SIZE)
	for i: int in range(_spell_labels.size()):
		if i < visible_count:
			var spell: Dictionary = _spells[_scroll_offset + i]
			var spell_name: String = spell.get("name", "???")
			var mp_cost: int = spell.get("mp_cost", 0)
			_spell_labels[i].text = "%-14s MP%3d" % [spell_name, mp_cost]
			_spell_labels[i].visible = true
			if i == _cursor:
				_spell_labels[i].modulate = COLOR_SELECTED
			elif not SpellHelpers.can_field_cast(spell):
				_spell_labels[i].modulate = COLOR_DISABLED
			else:
				_spell_labels[i].modulate = COLOR_NORMAL
		else:
			_spell_labels[i].text = ""
			_spell_labels[i].visible = false


func _update_desc() -> void:
	if _showing_feedback:
		return
	if _spells.is_empty():
		_desc_label.text = "No spells learned."
		return
	var spell_index: int = _scroll_offset + _cursor
	if spell_index < _spells.size():
		_desc_label.text = _spells[spell_index].get("description", "")
	else:
		_desc_label.text = ""


func _update_target_display() -> void:
	var party: Array[Dictionary] = PartyState.get_active_party()
	var living: Array[Dictionary] = _get_living_members(party)
	for i: int in range(_target_labels.size()):
		if i < living.size():
			var m: Dictionary = living[i]
			_target_labels[i].text = (
				"%s  HP %d/%d"
				% [
					m.get("character_id", "").to_upper(),
					m.get("current_hp", 0),
					m.get("max_hp", 1),
				]
			)
			_target_labels[i].visible = true
			_target_labels[i].modulate = COLOR_SELECTED if i == _target_index else COLOR_NORMAL
		else:
			_target_labels[i].visible = false


func _get_living_members(party: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for m: Dictionary in party:
		if m.get("current_hp", 0) > 0:
			result.append(m)
	return result
