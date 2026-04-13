extends CanvasLayer
## Dialogue overlay with typewriter text, speaker names, and choice prompts.
## Processes dialogue entries sequentially. Emits dialogue_finished when done.
##
## Usage: GameManager.push_overlay(DIALOGUE), then call show_dialogue(entries)
## on the overlay_node. Entries follow the 7-field format from
## technical-architecture.md Section 2.5.

signal dialogue_finished
signal choice_made(choice_index: int)
signal animation_requested(who: String, anim: String)
signal sfx_requested(sfx_id: String)
## Emitted when a choice option has flag_set data. Exploration scene handles.
signal flag_set_requested(flag_name: String, value: Variant)

## Text speed in characters per second, indexed by config setting name.
const TEXT_SPEEDS: Dictionary = {
	"slow": 30,
	"normal": 60,
	"fast": 120,
	"instant": 99999,
}

## Max visible lines before pagination.
const MAX_VISIBLE_LINES: int = 3

## Colors from ui-design.md Section 1.4.
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")

## When true, dialogue_finished does NOT call GameManager.pop_overlay().
## Used when dialogue_box is embedded inside another overlay (e.g., cutscene).
var embedded_mode: bool = false

## Current dialogue entries being processed.
var _entries: Array[Dictionary] = []

## Current entry index.
var _current_index: int = 0

## Lines for the current entry.
var _current_lines: Array = []

## Current line page start index (for pagination).
var _page_start: int = 0

## Characters revealed so far in current page text.
var _chars_revealed: float = 0.0

## Total characters in the current page.
var _total_chars: int = 0

## Whether text is fully revealed for current page.
var _text_complete: bool = false

## Whether we're in choice mode.
var _in_choice: bool = false

## Selected choice index.
var _choice_index: int = 0

## Number of visible choice options.
var _choice_count: int = 0

## Current text speed (chars per second).
var _text_speed: int = 60

@onready var _dialogue_box: PanelContainer = $DialogueBox
@onready var _speaker_container: PanelContainer = $DialogueBox/SpeakerLabel
@onready var _speaker_label: Label = $DialogueBox/SpeakerLabel/NameLabel
@onready var _text_label: RichTextLabel = $DialogueBox/TextLabel
@onready var _advance_arrow: Sprite2D = $DialogueBox/AdvanceArrow
@onready var _choice_box: PanelContainer = $ChoiceBox
@onready var _choice_labels: Array[Label] = []
@onready var _choice_cursor: Sprite2D = $ChoiceCursor


func _ready() -> void:
	_choice_labels = [
		$ChoiceBox/ChoiceContainer/Choice0,
		$ChoiceBox/ChoiceContainer/Choice1,
		$ChoiceBox/ChoiceContainer/Choice2,
		$ChoiceBox/ChoiceContainer/Choice3,
	]
	_choice_box.visible = false
	_choice_cursor.visible = false
	_advance_arrow.visible = false
	_load_text_speed()


func _process(delta: float) -> void:
	if _in_choice or _text_complete or _entries.is_empty():
		return
	_chars_revealed += _text_speed * delta
	var revealed: int = int(_chars_revealed)
	if revealed >= _total_chars:
		_complete_text()
	else:
		_text_label.visible_characters = revealed


func _unhandled_input(event: InputEvent) -> void:
	if _entries.is_empty():
		return
	if _in_choice:
		_handle_choice_input(event)
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _text_complete:
			_advance()
		else:
			_complete_text()


## Start displaying a sequence of dialogue entries.
func show_dialogue(entries: Array) -> void:
	_entries.assign(entries)
	_current_index = 0
	if _entries.is_empty():
		dialogue_finished.emit()
		if not embedded_mode:
			GameManager.pop_overlay()
		return
	_show_entry(_current_index)


## Force-close dialogue (for cutscene override).
func close() -> void:
	_entries = []
	dialogue_finished.emit()
	if not embedded_mode:
		GameManager.pop_overlay()


func _show_entry(index: int) -> void:
	if index >= _entries.size():
		dialogue_finished.emit()
		if not embedded_mode:
			GameManager.pop_overlay()
		return

	var entry: Dictionary = _entries[index]

	# Fire "before" animations
	_fire_animations(entry, "before_line_0")

	# Fire SFX markers
	_fire_sfx(entry)

	# Set speaker — FF6 inline style: "SPEAKER: text"
	var speaker: String = entry.get("speaker", "")
	_speaker_container.visible = false
	var raw_lines: Array = entry.get("lines", [])
	_current_lines = raw_lines.duplicate()
	if speaker != "" and _current_lines.size() > 0:
		_current_lines[0] = speaker.to_upper() + ": " + _current_lines[0]
	elif speaker != "":
		_current_lines = [speaker.to_upper() + ":"]
	_page_start = 0
	_show_page()


func _show_page() -> void:
	var end: int = mini(_page_start + MAX_VISIBLE_LINES, _current_lines.size())
	var page_lines: Array = _current_lines.slice(_page_start, end)
	var combined: String = "\n".join(page_lines)

	_text_label.text = combined
	_total_chars = combined.length()
	_chars_revealed = 0.0
	_text_complete = false
	_advance_arrow.visible = false

	if _text_speed >= TEXT_SPEEDS["instant"]:
		_complete_text()
	else:
		_text_label.visible_characters = 0


func _complete_text() -> void:
	_text_label.visible_characters = -1
	_text_complete = true
	_chars_revealed = float(_total_chars)
	_advance_arrow.visible = true


func _advance() -> void:
	_advance_arrow.visible = false

	# Check if more pages exist in current entry
	var next_page_start: int = _page_start + MAX_VISIBLE_LINES
	if next_page_start < _current_lines.size():
		_page_start = next_page_start
		_show_page()
		return

	# Check if entry has a choice prompt (array of options per dialogue data format)
	var entry: Dictionary = _entries[_current_index]
	var choice_data: Variant = entry.get("choice")
	if choice_data != null and choice_data is Array:
		_show_choice(choice_data)
		return

	# Advance to next entry
	_current_index += 1
	_show_entry(_current_index)


func _show_choice(options: Array) -> void:
	_choice_count = mini(options.size(), 4)
	if _choice_count == 0:
		_current_index += 1
		_show_entry(_current_index)
		return
	_in_choice = true
	_choice_index = 0

	for i: int in range(4):
		if i < _choice_count:
			var opt: Variant = options[i]
			var label_text: String = opt.get("label", "") if opt is Dictionary else ""
			_choice_labels[i].text = label_text
			_choice_labels[i].visible = true
		else:
			_choice_labels[i].visible = false

	_choice_box.visible = true
	_choice_cursor.visible = true
	_update_choice_display()


func _handle_choice_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_choice_index = (_choice_index + 1) % _choice_count
		_update_choice_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_choice_index = (_choice_index - 1 + _choice_count) % _choice_count
		_update_choice_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_select_choice()
	elif event.is_action_pressed("ui_cancel"):
		# Cancel selects bottom option per ui-design.md Section 12.4
		_choice_index = _choice_count - 1
		get_viewport().set_input_as_handled()
		_select_choice()


func _select_choice() -> void:
	_in_choice = false
	_choice_box.visible = false
	_choice_cursor.visible = false
	choice_made.emit(_choice_index)

	# Emit flag_set if the selected option has flag/score data
	if _current_index >= _entries.size():
		return
	var entry: Dictionary = _entries[_current_index]
	var choices: Variant = entry.get("choice")
	if choices is Array and _choice_index < choices.size():
		var opt: Variant = choices[_choice_index]
		if opt is Dictionary:
			var flag: String = opt.get("flag_set", "")
			if flag != "":
				flag_set_requested.emit(flag, true)
			var score_name: String = opt.get("score_name", "")
			var score_delta: int = opt.get("score_delta", 0)
			if score_name != "" and score_delta != 0:
				flag_set_requested.emit(score_name, score_delta)

	# Advance to next entry
	_current_index += 1
	_show_entry(_current_index)


func _update_choice_display() -> void:
	for i: int in range(_choice_count):
		if i == _choice_index:
			_choice_labels[i].modulate = COLOR_SELECTED
		else:
			_choice_labels[i].modulate = COLOR_NORMAL

	# Position cursor next to selected choice
	if _choice_cursor != null and _choice_count > 0:
		var target: Label = _choice_labels[_choice_index]
		_choice_cursor.global_position = Vector2(
			target.global_position.x - 64,
			target.global_position.y + floori(target.size.y / 2.0),
		)


## Fire animation signals for an entry. Timing filter is stubbed — all animations
## fire at entry start regardless of "when" field. Filter by timing deferred to
## gap 3.7 (Cutscene) when per-line animation scheduling is implemented.
func _fire_animations(entry: Dictionary, _timing_filter: String) -> void:
	var animations: Variant = entry.get("animations")
	if animations == null or not animations is Array:
		return
	for anim_data: Variant in animations:
		if not anim_data is Dictionary:
			continue
		var who: String = anim_data.get("who", "")
		var anim: String = anim_data.get("anim", "")
		if who != "" and anim != "":
			animation_requested.emit(who, anim)


func _fire_sfx(entry: Dictionary) -> void:
	var sfx_data: Variant = entry.get("sfx")
	if sfx_data == null or not sfx_data is Array:
		return
	for sfx: Variant in sfx_data:
		if not sfx is Dictionary:
			continue
		var sfx_id: String = sfx.get("id", "")
		if sfx_id != "":
			sfx_requested.emit(sfx_id)


func _load_text_speed() -> void:
	var config: Variant = DataManager.load_json("res://data/config/defaults.json")
	var speed_name: String = "normal"
	if config is Dictionary:
		speed_name = config.get("text_speed", "normal")
	_text_speed = TEXT_SPEEDS.get(speed_name, 60)
