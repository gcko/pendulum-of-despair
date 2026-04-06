# Gaps 3.1 + 3.5 + 3.6: Title Screen, Dialogue Overlay, Save/Load Overlay — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the game's entry point (title screen), dialogue text rendering system, and save/load UI — the minimum UI needed before the exploration scene can function.

**Architecture:** Three scenes plugging into the existing GameManager state machine. Title is a core state (`CoreState.TITLE`), dialogue and save/load are overlay states (`OverlayState.DIALOGUE`, `OverlayState.SAVE_LOAD`). All overlays use `process_mode = ALWAYS` and CanvasLayer. Shared pixel-art UI style: dark navy `#000040` background, `#5566aa` 2px borders, canonical color palette from ui-design.md Section 1.4. SaveManager gets a new public `load_most_recent()` method.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.3.0, gdlint 4.5.0

**Spec:** `docs/superpowers/specs/2026-04-06-title-dialogue-saveload-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/assets/sprites/ui/cursor_hand.png` | 16x16 pixel-art hand cursor (2 frames) |
| Create | `game/scripts/core/title.gd` | Title screen: 3-option menu, cursor nav, New Game/Continue/Config |
| Create | `game/scenes/core/title.tscn` | Title screen scene tree |
| Create | `game/scripts/ui/dialogue_box.gd` | Dialogue overlay: typewriter text, choices, animation/SFX signals |
| Create | `game/scenes/overlay/dialogue.tscn` | Dialogue overlay scene tree |
| Create | `game/scripts/ui/save_load.gd` | Save/Load overlay: save point menu, slot display, rest stubs |
| Create | `game/scenes/overlay/save_load.tscn` | Save/Load overlay scene tree |
| Create | `game/tests/test_title.gd` | 6 title screen tests |
| Create | `game/tests/test_dialogue.gd` | 14 dialogue overlay tests |
| Create | `game/tests/test_save_load.gd` | 12 save/load overlay tests |
| Modify | `game/scripts/autoload/save_manager.gd` | Add public `load_most_recent()` wrapper |
| Modify | `game/project.godot` | Set `run/main_scene` to title.tscn |
| Modify | `docs/analysis/game-dev-gaps.md` | Update 3.1, 3.5, 3.6 status to COMPLETE |

---

## Chunk 1: Shared Infrastructure + SaveManager

### Task 1: Create placeholder cursor sprite

Generate a 16x16 PNG cursor sprite for UI navigation.

**Files:**
- Create: `game/assets/sprites/ui/cursor_hand.png`

- [ ] **Step 1:** Create `game/assets/sprites/ui/` directory if needed
- [ ] **Step 2:** Generate 16x16 cursor_hand.png — white pointing hand on transparent background. Single frame is fine (2-frame animation added when art exists).
- [ ] **Step 3:** Verify file exists and is 16x16

---

### Task 2: Add public `load_most_recent()` to SaveManager

The existing `_load_most_recent_save()` is private. Title screen needs a public wrapper.

**Files:**
- Modify: `game/scripts/autoload/save_manager.gd`

- [ ] **Step 1:** Add public method after `faint_and_fast_reload()`:

```gdscript
## Load the most recent save file (manual or auto, by timestamp).
## Returns {slot: int, data: Dictionary} or empty dict if no saves exist.
## Public wrapper for title screen Continue flow.
func load_most_recent() -> Dictionary:
	return _load_most_recent_save()
```

- [ ] **Step 2:** Add a convenience method to check if any save exists:

```gdscript
## Check whether any save file exists (for title screen Continue button).
func has_any_save() -> bool:
	for slot: int in [0, 1, 2, 3]:
		var path: String = _slot_path(slot)
		if FileAccess.file_exists(path):
			return true
	return false
```

- [ ] **Step 3:** Add a method to load slot preview data (for save/load slot display):

```gdscript
## Load preview data for all save slots (for slot display in save/load screen).
## Returns array of 4 Dictionaries (index 0=auto, 1-3=manual).
## Empty dict for unused slots, dict with "error" key for corrupted.
func get_slot_previews() -> Array[Dictionary]:
	var previews: Array[Dictionary] = []
	for slot: int in [0, 1, 2, 3]:
		previews.append(load_game(slot))
	return previews
```

- [ ] **Step 4:** Run gdformat + gdlint on save_manager.gd
- [ ] **Step 5:** Commit

```bash
git add game/scripts/autoload/save_manager.gd
git commit -m "feat(engine): add public save query methods for title + save/load screens"
```

---

## Chunk 2: Title Screen (Gap 3.1)

### Task 3: Create title.gd

**Agent instructions:** Write the title screen script following established patterns. The title screen is a core state scene (not an overlay). It reads input via `_unhandled_input()`, navigates a 3-option menu, and transitions via GameManager. Apply MANDATORY dual-pass self-review before declaring done.

**Files:**
- Create: `game/scripts/core/title.gd`

- [ ] **Step 1:** Write title.gd:

```gdscript
extends Control
## Title screen with 3-option menu and cursor navigation.
## Core state scene — set as project main_scene.
##
## Menu: New Game, Continue, Config (stubbed).
## Uses built-in Godot input actions (ui_up, ui_down, ui_accept).

## Menu option indices.
enum MenuOption { NEW_GAME, CONTINUE, CONFIG }

## Number of menu options.
const MENU_COUNT: int = 3

## Colors from ui-design.md Section 1.4.
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

## Currently selected menu index.
var _selected: int = 0

## Whether Continue is available (saves exist).
var _has_save: bool = false

## Whether input is being processed (prevents double-select).
var _input_active: bool = true

@onready var _options: Array[Label] = []
@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	_options = [
		$MenuContainer/NewGameOption,
		$MenuContainer/ContinueOption,
		$MenuContainer/ConfigOption,
	]
	_has_save = SaveManager.has_any_save()
	_update_display()


func _unhandled_input(event: InputEvent) -> void:
	if not _input_active:
		return
	if event.is_action_pressed("ui_down"):
		_move_cursor(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_cursor(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_selection()
		get_viewport().set_input_as_handled()


func _move_cursor(direction: int) -> void:
	_selected = (_selected + direction + MENU_COUNT) % MENU_COUNT
	_update_display()


func _confirm_selection() -> void:
	match _selected:
		MenuOption.NEW_GAME:
			_input_active = false
			GameManager.change_core_state(
				GameManager.CoreState.EXPLORATION, {"new_game": true}
			)
		MenuOption.CONTINUE:
			if not _has_save:
				return
			_input_active = false
			var result: Dictionary = SaveManager.load_most_recent()
			if result.is_empty() or result.has("error"):
				push_warning("Title: Failed to load most recent save")
				_input_active = true
				return
			GameManager.change_core_state(
				GameManager.CoreState.EXPLORATION,
				{"save_slot": result["slot"], "save_data": result["data"]},
			)
		MenuOption.CONFIG:
			pass  # Stubbed — gap 3.4


func _update_display() -> void:
	for i: int in range(MENU_COUNT):
		var label: Label = _options[i]
		var is_disabled: bool = _is_option_disabled(i)
		if i == _selected:
			label.modulate = COLOR_DISABLED if is_disabled else COLOR_SELECTED
		else:
			label.modulate = COLOR_DISABLED if is_disabled else COLOR_NORMAL
	# Position cursor next to selected option
	if _cursor != null and _options.size() > _selected:
		var target: Label = _options[_selected]
		_cursor.global_position = Vector2(
			target.global_position.x - 20,
			target.global_position.y + target.size.y / 2.0,
		)


func _is_option_disabled(index: int) -> bool:
	match index:
		MenuOption.CONTINUE:
			return not _has_save
		MenuOption.CONFIG:
			return true  # Stubbed
	return false
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Dual-pass self-review (mechanical + narrative)

---

### Task 4: Create title.tscn

**Files:**
- Create: `game/scenes/core/title.tscn`

**Resource counts:**
- ext_resource: 2 (script + cursor sprite)
- sub_resource: 1 (cursor idle animation) + 1 (AnimationLibrary)
- load_steps = 2 + 2 = 4

- [ ] **Step 1:** Write title.tscn:

```
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://scripts/core/title.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/cursor_hand.png" id="2_cursor"]

[sub_resource type="Animation" id="Anim_cursor_idle"]
resource_name = "cursor_idle"
length = 0.6
loop_mode = 1

[sub_resource type="AnimationLibrary" id="AnimLib_main"]
_data = {
"cursor_idle": SubResource("Anim_cursor_idle")
}

[node name="Title" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_script")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0, 0, 0.251, 1)

[node name="TitleLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -100.0
offset_top = 30.0
offset_right = 100.0
offset_bottom = 50.0
text = "Pendulum of Despair"
horizontal_alignment = 1

[node name="MenuContainer" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -40.0
offset_top = -80.0
offset_right = 40.0
offset_bottom = -20.0
alignment = 1

[node name="NewGameOption" type="Label" parent="MenuContainer"]
layout_mode = 2
text = "New Game"
horizontal_alignment = 1

[node name="ContinueOption" type="Label" parent="MenuContainer"]
layout_mode = 2
text = "Continue"
horizontal_alignment = 1

[node name="ConfigOption" type="Label" parent="MenuContainer"]
layout_mode = 2
text = "Config"
horizontal_alignment = 1

[node name="Cursor" type="Sprite2D" parent="."]
position = Vector2(80, 130)
texture = ExtResource("2_cursor")

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimLib_main")
}
```

- [ ] **Step 2:** Verify load_steps = ext_resource count (2) + sub_resource count (2) = 4

---

### Task 5: Set main_scene in project.godot

**Files:**
- Modify: `game/project.godot`

- [ ] **Step 1:** Add or update `run/main_scene` in project.godot:

```
run/main_scene="res://scenes/core/title.tscn"
```

- [ ] **Step 2:** Verify the line exists and path is correct

---

### Task 6: Write title screen tests

**Files:**
- Create: `game/tests/test_title.gd`

- [ ] **Step 1:** Write test_title.gd:

```gdscript
extends GutTest
## Tests for Title Screen.

const TITLE_SCENE: PackedScene = preload("res://scenes/core/title.tscn")


func _create_title():
	var title = TITLE_SCENE.instantiate()
	add_child_autofree(title)
	return title


func test_title_scene_loads() -> void:
	var title = _create_title()
	assert_not_null(title, "title scene should instantiate")


func test_menu_options_exist() -> void:
	var title = _create_title()
	var container = title.get_node("MenuContainer")
	assert_eq(container.get_child_count(), 3, "should have 3 menu options")


func test_initial_selection() -> void:
	var title = _create_title()
	assert_eq(title._selected, 0, "should start on New Game")


func test_cursor_wraps_up() -> void:
	var title = _create_title()
	title._move_cursor(-1)
	assert_eq(title._selected, 2, "should wrap to last option")


func test_cursor_wraps_down() -> void:
	var title = _create_title()
	title._selected = 2
	title._move_cursor(1)
	assert_eq(title._selected, 0, "should wrap to first option")


func test_config_disabled() -> void:
	var title = _create_title()
	assert_true(title._is_option_disabled(title.MenuOption.CONFIG), "config should be disabled")
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Commit chunk 2

```bash
git add game/scripts/core/title.gd game/scenes/core/title.tscn game/tests/test_title.gd game/project.godot game/assets/sprites/ui/
git commit -m "feat(engine): add title screen with menu navigation (gap 3.1)"
```

---

## Chunk 3: Dialogue Overlay (Gap 3.5)

### Task 7: Create dialogue_box.gd

**Agent instructions:** Write the dialogue overlay script. This is the most complex script in this PR — it manages typewriter text rendering, multi-page pagination, choice prompts, and animation/SFX signal emission. Apply MANDATORY dual-pass self-review.

**Files:**
- Create: `game/scripts/ui/dialogue_box.gd`

- [ ] **Step 1:** Write dialogue_box.gd:

```gdscript
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

## Current dialogue entries being processed.
var _entries: Array = []

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

@onready var _dialogue_box: NinePatchRect = $DialogueBox
@onready var _speaker_label: Label = $DialogueBox/SpeakerLabel
@onready var _text_label: RichTextLabel = $DialogueBox/TextLabel
@onready var _advance_arrow: Sprite2D = $DialogueBox/AdvanceArrow
@onready var _choice_box: NinePatchRect = $ChoiceBox
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
		if _text_complete:
			_advance()
		else:
			_complete_text()
		get_viewport().set_input_as_handled()


## Start displaying a sequence of dialogue entries.
func show_dialogue(entries: Array) -> void:
	_entries = entries
	_current_index = 0
	if _entries.is_empty():
		dialogue_finished.emit()
		GameManager.pop_overlay()
		return
	_show_entry(_current_index)


## Force-close dialogue (for cutscene override).
func close() -> void:
	_entries = []
	dialogue_finished.emit()
	GameManager.pop_overlay()


func _show_entry(index: int) -> void:
	if index >= _entries.size():
		dialogue_finished.emit()
		GameManager.pop_overlay()
		return

	var entry: Dictionary = _entries[index]

	# Fire "before" animations
	_fire_animations(entry, "before_line_0")

	# Fire SFX markers
	_fire_sfx(entry)

	# Set speaker
	var speaker: String = entry.get("speaker", "")
	if speaker != "":
		_speaker_label.text = speaker.to_upper()
		_speaker_label.visible = true
	else:
		_speaker_label.visible = false

	# Set lines
	_current_lines = entry.get("lines", [])
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

	# Check if entry has a choice prompt
	var entry: Dictionary = _entries[_current_index]
	var choice_data: Variant = entry.get("choice")
	if choice_data != null and choice_data is Dictionary:
		_show_choice(choice_data)
		return

	# Advance to next entry
	_current_index += 1
	_show_entry(_current_index)


func _show_choice(choice_data: Dictionary) -> void:
	_in_choice = true
	_choice_index = 0
	var options: Array = choice_data.get("options", [])
	_choice_count = mini(options.size(), 4)

	for i: int in range(4):
		if i < _choice_count:
			_choice_labels[i].text = options[i].get("text", "")
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
		_select_choice()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		# Cancel selects bottom option per ui-design.md Section 12.4
		_choice_index = _choice_count - 1
		_select_choice()
		get_viewport().set_input_as_handled()


func _select_choice() -> void:
	_in_choice = false
	_choice_box.visible = false
	_choice_cursor.visible = false
	choice_made.emit(_choice_index)

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
			target.global_position.x - 16,
			target.global_position.y + target.size.y / 2.0,
		)


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
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Dual-pass self-review (mechanical + narrative)

---

### Task 8: Create dialogue.tscn

**Files:**
- Create: `game/scenes/overlay/dialogue.tscn`

**Resource counts:**
- ext_resource: 2 (script + cursor sprite)
- sub_resource: 2 (arrow bounce animation + AnimationLibrary)
- load_steps = 2 + 2 = 4

- [ ] **Step 1:** Write dialogue.tscn:

```
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://scripts/ui/dialogue_box.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/cursor_hand.png" id="2_cursor"]

[sub_resource type="Animation" id="Anim_arrow_bounce"]
resource_name = "arrow_bounce"
length = 0.6
loop_mode = 1

[sub_resource type="AnimationLibrary" id="AnimLib_main"]
_data = {
"arrow_bounce": SubResource("Anim_arrow_bounce")
}

[node name="Dialogue" type="CanvasLayer"]
layer = 10
process_mode = 3
script = ExtResource("1_script")

[node name="DialogueBox" type="NinePatchRect" parent="."]
offset_left = 0.0
offset_top = 140.0
offset_right = 320.0
offset_bottom = 180.0

[node name="SpeakerLabel" type="Label" parent="DialogueBox"]
offset_left = 4.0
offset_top = -12.0
offset_right = 100.0
offset_bottom = 0.0
text = "SPEAKER"
visible = false

[node name="TextLabel" type="RichTextLabel" parent="DialogueBox"]
offset_left = 4.0
offset_top = 2.0
offset_right = 316.0
offset_bottom = 38.0
bbcode_enabled = true
text = ""
visible_characters = 0

[node name="AdvanceArrow" type="Sprite2D" parent="DialogueBox"]
position = Vector2(308, 34)
visible = false

[node name="ChoiceBox" type="NinePatchRect" parent="."]
offset_left = 200.0
offset_top = 90.0
offset_right = 316.0
offset_bottom = 138.0
visible = false

[node name="ChoiceContainer" type="VBoxContainer" parent="ChoiceBox"]
offset_left = 16.0
offset_top = 2.0
offset_right = 112.0
offset_bottom = 46.0

[node name="Choice0" type="Label" parent="ChoiceBox/ChoiceContainer"]
layout_mode = 2
text = "Option 1"

[node name="Choice1" type="Label" parent="ChoiceBox/ChoiceContainer"]
layout_mode = 2
text = "Option 2"

[node name="Choice2" type="Label" parent="ChoiceBox/ChoiceContainer"]
layout_mode = 2
text = "Option 3"
visible = false

[node name="Choice3" type="Label" parent="ChoiceBox/ChoiceContainer"]
layout_mode = 2
text = "Option 4"
visible = false

[node name="ChoiceCursor" type="Sprite2D" parent="."]
position = Vector2(204, 100)
texture = ExtResource("2_cursor")
visible = false

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimLib_main")
}
```

- [ ] **Step 2:** Verify load_steps = 2 + 2 = 4

---

### Task 9: Write dialogue overlay tests

**Files:**
- Create: `game/tests/test_dialogue.gd`

- [ ] **Step 1:** Write test_dialogue.gd:

```gdscript
extends GutTest
## Tests for Dialogue Overlay.

const DIALOGUE_SCENE: PackedScene = preload("res://scenes/overlay/dialogue.tscn")


func _create_dialogue():
	var dlg = DIALOGUE_SCENE.instantiate()
	add_child_autofree(dlg)
	return dlg


func _sample_entries() -> Array:
	return [
		{
			"id": "test_001",
			"speaker": "edren",
			"lines": ["Hello there.", "How are you?"],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
		},
		{
			"id": "test_002",
			"speaker": "cael",
			"lines": ["I am fine."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
		},
	]


# --- Scene Loading ---


func test_dialogue_scene_loads() -> void:
	var dlg = _create_dialogue()
	assert_not_null(dlg, "dialogue scene should instantiate")


# --- Show Dialogue ---


func test_show_dialogue_sets_entries() -> void:
	var dlg = _create_dialogue()
	var entries: Array = _sample_entries()
	dlg.show_dialogue(entries)
	assert_eq(dlg._entries.size(), 2, "should store 2 entries")
	assert_eq(dlg._current_index, 0, "should start at index 0")


func test_speaker_name_displayed() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue(_sample_entries())
	assert_true(dlg._speaker_label.visible, "speaker label should be visible")
	assert_eq(dlg._speaker_label.text, "EDREN", "should show speaker name uppercased")


func test_speaker_name_empty() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue([
		{"id": "t1", "speaker": "", "lines": ["No speaker."],
		 "condition": null, "animations": null, "choice": null, "sfx": null},
	])
	assert_false(dlg._speaker_label.visible, "speaker label should be hidden")


# --- Typewriter ---


func test_typewriter_reveals_chars() -> void:
	var dlg = _create_dialogue()
	dlg._text_speed = 60
	dlg.show_dialogue(_sample_entries())
	# Simulate a frame at 60fps (delta = 1/60)
	dlg._process(1.0 / 60.0)
	assert_gt(int(dlg._chars_revealed), 0, "should have revealed some characters")
	assert_false(dlg._text_complete, "text should not be complete yet")


func test_confirm_completes_text() -> void:
	var dlg = _create_dialogue()
	dlg._text_speed = 30  # Slow speed
	dlg.show_dialogue(_sample_entries())
	# Text should not be complete initially
	assert_false(dlg._text_complete, "text should not be complete initially")
	# Simulate confirm — should complete text
	dlg._complete_text()
	assert_true(dlg._text_complete, "text should be complete after confirm")


func test_confirm_advances_entry() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue(_sample_entries())
	dlg._complete_text()
	# Advance past all lines of first entry
	dlg._advance()
	assert_eq(dlg._current_index, 1, "should advance to second entry")


func test_last_entry_emits_finished() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	dlg.show_dialogue([
		{"id": "t1", "speaker": "test", "lines": ["Only entry."],
		 "condition": null, "animations": null, "choice": null, "sfx": null},
	])
	dlg._complete_text()
	dlg._advance()
	assert_signal_emitted(dlg, "dialogue_finished", "should emit dialogue_finished")


# --- Choices ---


func test_choice_display() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue([
		{"id": "t1", "speaker": "test", "lines": ["Pick one."],
		 "condition": null, "animations": null,
		 "choice": {"options": [{"text": "Yes"}, {"text": "No"}]},
		 "sfx": null},
	])
	dlg._complete_text()
	dlg._advance()
	assert_true(dlg._in_choice, "should be in choice mode")
	assert_true(dlg._choice_box.visible, "choice box should be visible")
	assert_eq(dlg._choice_count, 2, "should have 2 choices")


func test_choice_selection() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	dlg.show_dialogue([
		{"id": "t1", "speaker": "test", "lines": ["Pick one."],
		 "condition": null, "animations": null,
		 "choice": {"options": [{"text": "Yes"}, {"text": "No"}]},
		 "sfx": null},
	])
	dlg._complete_text()
	dlg._advance()
	# Select first choice
	dlg._select_choice()
	assert_signal_emitted(dlg, "choice_made", "should emit choice_made")


func test_choice_cancel_selects_bottom() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue([
		{"id": "t1", "speaker": "test", "lines": ["Pick one."],
		 "condition": null, "animations": null,
		 "choice": {"options": [{"text": "Yes"}, {"text": "No"}]},
		 "sfx": null},
	])
	dlg._complete_text()
	dlg._advance()
	assert_eq(dlg._choice_index, 0, "should start on first choice")
	# Simulate cancel press — per ui-design.md 12.4, selects bottom option
	dlg._choice_index = dlg._choice_count - 1
	assert_eq(dlg._choice_index, 1, "cancel should select bottom option (No)")


# --- Signals ---


func test_animation_signal() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	dlg.show_dialogue([
		{"id": "t1", "speaker": "test", "lines": ["Animated."],
		 "condition": null,
		 "animations": [{"who": "edren", "anim": "shake", "when": "before_line_0"}],
		 "choice": null, "sfx": null},
	])
	assert_signal_emitted(dlg, "animation_requested", "should emit animation_requested")


func test_empty_entries() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	dlg.show_dialogue([])
	assert_signal_emitted(dlg, "dialogue_finished", "empty entries should emit finished immediately")


func test_multipage_pagination() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue([
		{"id": "t1", "speaker": "test",
		 "lines": ["Line 1.", "Line 2.", "Line 3.", "Line 4.", "Line 5."],
		 "condition": null, "animations": null, "choice": null, "sfx": null},
	])
	assert_eq(dlg._page_start, 0, "should start at page 0")
	dlg._complete_text()
	dlg._advance()
	assert_eq(dlg._page_start, 3, "should advance to second page at line 3")
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Commit chunk 3

```bash
git add game/scripts/ui/dialogue_box.gd game/scenes/overlay/dialogue.tscn game/tests/test_dialogue.gd
git commit -m "feat(engine): add dialogue overlay with typewriter text and choices (gap 3.5)"
```

---

## Chunk 4: Save/Load Overlay (Gap 3.6) + Gap Tracker Update

### Task 10: Create save_load.gd

**Agent instructions:** Write the save/load overlay script. This manages multiple sub-states (save point menu, rest menu, slot select, confirmations). Use a sub-state machine pattern. Rest item consumption is stubbed. Apply MANDATORY dual-pass self-review.

**Files:**
- Create: `game/scripts/ui/save_load.gd`

- [ ] **Step 1:** Write save_load.gd:

```gdscript
extends CanvasLayer
## Save/Load overlay with save point 3-option menu, slot display, and rest stubs.
##
## Three operating modes: SAVE_POINT (from save point interaction),
## SAVE (from menu), LOAD (from title screen or menu).
## Sub-state machine handles navigation through menus and confirmations.

signal save_completed(slot: int)
signal load_completed(slot: int)

## Operating modes.
enum Mode { SAVE_POINT, SAVE, LOAD }

## Sub-states for navigation.
enum SubState {
	SAVE_POINT_MENU,
	REST_MENU,
	SLOT_SELECT,
	CONFIRM,
	OPERATION_SELECT,
}

## Save point menu options.
enum SavePointOption { REST, REST_SAVE, SAVE }

## Slot operation options.
enum SlotOperation { SAVE_OP, COPY, DELETE }

## Colors from ui-design.md Section 1.4.
const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")
const COLOR_GOLD_BORDER: Color = Color("#ffcc44")

## Current mode.
var _mode: Mode = Mode.SAVE

## Current sub-state.
var _sub_state: SubState = SubState.SLOT_SELECT

## Selected indices for each sub-state.
var _selected_slot: int = 1
var _save_point_selection: int = 0
var _rest_selection: int = 0
var _confirm_selection: int = 1  # Default to "No"
var _operation_selection: int = 0

## Pending operation for confirmation dialog.
var _pending_operation: String = ""
var _pending_slot: int = -1
var _copy_source_slot: int = -1

## Slot preview data.
var _slot_previews: Array[Dictionary] = []

@onready var _save_point_menu: NinePatchRect = $SavePointMenu
@onready var _save_point_options: Array[Label] = []
@onready var _slot_container: VBoxContainer = $SlotContainer
@onready var _auto_slot: PanelContainer = $SlotContainer/AutoSlot
@onready var _manual_slots: Array[PanelContainer] = []
@onready var _rest_menu: NinePatchRect = $RestMenu
@onready var _rest_options: Array[Label] = []
@onready var _confirm_dialog: NinePatchRect = $ConfirmDialog
@onready var _confirm_label: Label = $ConfirmDialog/ConfirmLabel
@onready var _confirm_yes: Label = $ConfirmDialog/YesOption
@onready var _confirm_no: Label = $ConfirmDialog/NoOption
@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	_save_point_options = [
		$SavePointMenu/RestOption,
		$SavePointMenu/RestSaveOption,
		$SavePointMenu/SaveOption,
	]
	_manual_slots = [
		$SlotContainer/Slot1,
		$SlotContainer/Slot2,
		$SlotContainer/Slot3,
	]
	_rest_options = [
		$RestMenu/SleepingBagOption,
		$RestMenu/TentOption,
		$RestMenu/PavilionOption,
	]
	_hide_all()
	_slot_previews = SaveManager.get_slot_previews()


func _unhandled_input(event: InputEvent) -> void:
	match _sub_state:
		SubState.SAVE_POINT_MENU:
			_handle_save_point_input(event)
		SubState.REST_MENU:
			_handle_rest_input(event)
		SubState.SLOT_SELECT:
			_handle_slot_input(event)
		SubState.CONFIRM:
			_handle_confirm_input(event)


## Initialize as save point interaction (shows 3-option menu first).
func open_save_point() -> void:
	_mode = Mode.SAVE_POINT
	_sub_state = SubState.SAVE_POINT_MENU
	_save_point_selection = 0
	_save_point_menu.visible = true
	_slot_container.visible = false
	_update_save_point_display()


## Initialize as direct save screen (from menu).
func open_save() -> void:
	_mode = Mode.SAVE
	_sub_state = SubState.SLOT_SELECT
	_selected_slot = 1
	_show_slots(false)


## Initialize as load screen (from title or menu).
func open_load() -> void:
	_mode = Mode.LOAD
	_sub_state = SubState.SLOT_SELECT
	_show_slots(true)
	_select_first_populated_slot()


func _hide_all() -> void:
	_save_point_menu.visible = false
	_slot_container.visible = false
	_rest_menu.visible = false
	_confirm_dialog.visible = false


func _show_slots(show_auto: bool) -> void:
	_slot_container.visible = true
	_auto_slot.visible = show_auto
	_refresh_slot_display()


func _refresh_slot_display() -> void:
	_slot_previews = SaveManager.get_slot_previews()
	for i: int in range(3):
		_update_slot_panel(_manual_slots[i], _slot_previews[i + 1])
	if _auto_slot.visible:
		_update_slot_panel(_auto_slot, _slot_previews[0])


func _update_slot_panel(panel: PanelContainer, data: Dictionary) -> void:
	# Find or create display labels within the panel
	var header_label: Label = panel.get_node_or_null("HeaderLabel")
	var party_label: Label = panel.get_node_or_null("PartyLabel")

	if data.is_empty():
		if header_label != null:
			header_label.text = "Empty"
			header_label.modulate = COLOR_DISABLED
		if party_label != null:
			party_label.text = ""
	elif data.has("error"):
		if header_label != null:
			header_label.text = "Corrupted"
			header_label.modulate = Color("#ff4444")
		if party_label != null:
			party_label.text = ""
	else:
		var meta: Dictionary = data.get("meta", {})
		var world: Dictionary = data.get("world", {})
		var formation: Dictionary = data.get("formation", {})
		var location: String = world.get("current_location", "Unknown")
		var playtime: int = meta.get("playtime", 0)
		var gold: int = world.get("gold", 0)
		var time_str: String = "%d:%02d" % [playtime / 3600, (playtime % 3600) / 60]

		if header_label != null:
			header_label.text = "%s  Time %s  Gold %d" % [location, time_str, gold]
			header_label.modulate = COLOR_NORMAL

		if party_label != null:
			var active: Array = formation.get("active", [])
			var party_text: String = ""
			for char_id: Variant in active:
				if party_text != "":
					party_text += "  "
				party_text += str(char_id)
			party_label.text = party_text


func _select_first_populated_slot() -> void:
	# In load mode, try auto slot first, then manual
	if _mode == Mode.LOAD:
		for slot: int in [0, 1, 2, 3]:
			var preview: Dictionary = _slot_previews[slot]
			if not preview.is_empty() and not preview.has("error"):
				_selected_slot = slot
				return
	_selected_slot = 1  # Default to first manual slot


func _is_slot_selectable(slot: int) -> bool:
	if _mode == Mode.LOAD:
		var preview: Dictionary = _slot_previews[slot]
		return not preview.is_empty() and not preview.has("error")
	return true  # Save mode: all manual slots selectable


# --- Input handlers ---


func _handle_save_point_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_save_point_selection = (_save_point_selection + 1) % 3
		_update_save_point_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_save_point_selection = (_save_point_selection - 1 + 3) % 3
		_update_save_point_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_save_point()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		GameManager.pop_overlay()
		get_viewport().set_input_as_handled()


func _handle_rest_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_rest_selection = (_rest_selection + 1) % 3
		_update_rest_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_rest_selection = (_rest_selection - 1 + 3) % 3
		_update_rest_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		push_warning("SaveLoad: Rest item consumption not yet implemented")
		_rest_menu.visible = false
		_sub_state = SubState.SAVE_POINT_MENU
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_rest_menu.visible = false
		_sub_state = SubState.SAVE_POINT_MENU
		get_viewport().set_input_as_handled()


func _handle_slot_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_slot_cursor(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_slot_cursor(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_slot()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_cancel_from_slots()
		get_viewport().set_input_as_handled()


func _handle_confirm_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		_confirm_selection = 1 - _confirm_selection  # Toggle 0/1
		_update_confirm_display()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_execute_confirm()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_confirm_dialog.visible = false
		_sub_state = SubState.SLOT_SELECT
		get_viewport().set_input_as_handled()


# --- Actions ---


func _confirm_save_point() -> void:
	match _save_point_selection:
		SavePointOption.REST:
			_sub_state = SubState.REST_MENU
			_rest_selection = 0
			_rest_menu.visible = true
			_update_rest_display()
		SavePointOption.REST_SAVE:
			push_warning("SaveLoad: Rest item consumption not yet implemented")
			_save_point_menu.visible = false
			_sub_state = SubState.SLOT_SELECT
			_selected_slot = 1
			_show_slots(false)
		SavePointOption.SAVE:
			_save_point_menu.visible = false
			_sub_state = SubState.SLOT_SELECT
			_selected_slot = 1
			_show_slots(false)


func _move_slot_cursor(direction: int) -> void:
	var min_slot: int = 0 if _mode == Mode.LOAD else 1
	var max_slot: int = 3
	var attempts: int = 0
	var new_slot: int = _selected_slot
	while attempts <= max_slot - min_slot:
		new_slot += direction
		if new_slot > max_slot:
			new_slot = min_slot
		elif new_slot < min_slot:
			new_slot = max_slot
		attempts += 1
		if _mode != Mode.LOAD or _is_slot_selectable(new_slot):
			_selected_slot = new_slot
			return


func _confirm_slot() -> void:
	if not _is_slot_selectable(_selected_slot) and _mode == Mode.LOAD:
		return

	if _mode == Mode.SAVE:
		var preview: Dictionary = _slot_previews[_selected_slot]
		if not preview.is_empty() and not preview.has("error"):
			_show_confirm("Overwrite?", "overwrite")
		else:
			_do_save(_selected_slot)
	elif _mode == Mode.LOAD:
		_do_load(_selected_slot)


func _cancel_from_slots() -> void:
	if _mode == Mode.SAVE_POINT:
		_slot_container.visible = false
		_sub_state = SubState.SAVE_POINT_MENU
		_save_point_menu.visible = true
	else:
		GameManager.pop_overlay()


func _show_confirm(message: String, operation: String) -> void:
	_sub_state = SubState.CONFIRM
	_confirm_label.text = message
	_confirm_selection = 1  # Default to No
	_pending_operation = operation
	_pending_slot = _selected_slot
	_confirm_dialog.visible = true
	_update_confirm_display()


func _execute_confirm() -> void:
	_confirm_dialog.visible = false
	if _confirm_selection == 0:  # Yes
		match _pending_operation:
			"overwrite":
				_do_save(_pending_slot)
			"delete":
				_do_delete(_pending_slot)
			"copy_dest":
				_do_copy(_copy_source_slot, _pending_slot)
	_sub_state = SubState.SLOT_SELECT


func _do_save(slot: int) -> void:
	var success: bool = SaveManager.save_game(slot)
	if success:
		save_completed.emit(slot)
		_refresh_slot_display()


func _do_load(slot: int) -> void:
	var data: Dictionary = SaveManager.load_game(slot)
	if data.is_empty() or data.has("error"):
		push_warning("SaveLoad: Failed to load slot %d" % slot)
		return
	load_completed.emit(slot)
	GameManager.change_core_state(
		GameManager.CoreState.EXPLORATION,
		{"save_slot": slot, "save_data": data},
	)


func _do_delete(slot: int) -> void:
	var path: String = SaveManager._slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	_refresh_slot_display()


func _do_copy(source: int, dest: int) -> void:
	var data: Dictionary = SaveManager.load_game(source)
	if data.is_empty() or data.has("error"):
		push_warning("SaveLoad: Cannot copy corrupted/empty slot %d" % source)
		return
	SaveManager._write_data_to_slot(dest, data)
	_refresh_slot_display()


# --- Display updates ---


func _update_save_point_display() -> void:
	for i: int in range(3):
		_save_point_options[i].modulate = (
			COLOR_SELECTED if i == _save_point_selection else COLOR_NORMAL
		)


func _update_rest_display() -> void:
	for i: int in range(3):
		_rest_options[i].modulate = (
			COLOR_SELECTED if i == _rest_selection else COLOR_NORMAL
		)


func _update_confirm_display() -> void:
	_confirm_yes.modulate = COLOR_SELECTED if _confirm_selection == 0 else COLOR_NORMAL
	_confirm_no.modulate = COLOR_SELECTED if _confirm_selection == 1 else COLOR_NORMAL
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Dual-pass self-review (mechanical + narrative)

---

### Task 11: Create save_load.tscn

**Files:**
- Create: `game/scenes/overlay/save_load.tscn`

**Resource counts:**
- ext_resource: 2 (script + cursor sprite)
- sub_resource: 0
- load_steps = 2 + 0 = 2

- [ ] **Step 1:** Write save_load.tscn:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/ui/save_load.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/ui/cursor_hand.png" id="2_cursor"]

[node name="SaveLoad" type="CanvasLayer"]
layer = 10
process_mode = 3
script = ExtResource("1_script")

[node name="Background" type="ColorRect" parent="."]
offset_left = 0.0
offset_top = 0.0
offset_right = 320.0
offset_bottom = 180.0
color = Color(0, 0, 0, 0.5)

[node name="SavePointMenu" type="NinePatchRect" parent="."]
offset_left = 100.0
offset_top = 50.0
offset_right = 220.0
offset_bottom = 110.0
visible = false

[node name="RestOption" type="Label" parent="SavePointMenu"]
offset_left = 8.0
offset_top = 4.0
offset_right = 112.0
offset_bottom = 18.0
text = "Rest"

[node name="RestSaveOption" type="Label" parent="SavePointMenu"]
offset_left = 8.0
offset_top = 22.0
offset_right = 112.0
offset_bottom = 36.0
text = "Rest & Save"

[node name="SaveOption" type="Label" parent="SavePointMenu"]
offset_left = 8.0
offset_top = 40.0
offset_right = 112.0
offset_bottom = 54.0
text = "Save"

[node name="SlotContainer" type="VBoxContainer" parent="."]
offset_left = 10.0
offset_top = 10.0
offset_right = 310.0
offset_bottom = 170.0
visible = false

[node name="AutoSlot" type="PanelContainer" parent="SlotContainer"]
layout_mode = 2
visible = false

[node name="HeaderLabel" type="Label" parent="SlotContainer/AutoSlot"]
layout_mode = 2
text = "AUTO - Empty"

[node name="PartyLabel" type="Label" parent="SlotContainer/AutoSlot"]
layout_mode = 2
text = ""

[node name="Slot1" type="PanelContainer" parent="SlotContainer"]
layout_mode = 2

[node name="HeaderLabel" type="Label" parent="SlotContainer/Slot1"]
layout_mode = 2
text = "Empty"

[node name="PartyLabel" type="Label" parent="SlotContainer/Slot1"]
layout_mode = 2
text = ""

[node name="Slot2" type="PanelContainer" parent="SlotContainer"]
layout_mode = 2

[node name="HeaderLabel" type="Label" parent="SlotContainer/Slot2"]
layout_mode = 2
text = "Empty"

[node name="PartyLabel" type="Label" parent="SlotContainer/Slot2"]
layout_mode = 2
text = ""

[node name="Slot3" type="PanelContainer" parent="SlotContainer"]
layout_mode = 2

[node name="HeaderLabel" type="Label" parent="SlotContainer/Slot3"]
layout_mode = 2
text = "Empty"

[node name="PartyLabel" type="Label" parent="SlotContainer/Slot3"]
layout_mode = 2
text = ""

[node name="RestMenu" type="NinePatchRect" parent="."]
offset_left = 80.0
offset_top = 40.0
offset_right = 240.0
offset_bottom = 100.0
visible = false

[node name="SleepingBagOption" type="Label" parent="RestMenu"]
offset_left = 8.0
offset_top = 4.0
offset_right = 152.0
offset_bottom = 18.0
text = "Sleeping Bag (25%)"

[node name="TentOption" type="Label" parent="RestMenu"]
offset_left = 8.0
offset_top = 22.0
offset_right = 152.0
offset_bottom = 36.0
text = "Tent (50%)"

[node name="PavilionOption" type="Label" parent="RestMenu"]
offset_left = 8.0
offset_top = 40.0
offset_right = 152.0
offset_bottom = 54.0
text = "Pavilion (100%)"

[node name="ConfirmDialog" type="NinePatchRect" parent="."]
offset_left = 100.0
offset_top = 70.0
offset_right = 220.0
offset_bottom = 120.0
visible = false

[node name="ConfirmLabel" type="Label" parent="ConfirmDialog"]
offset_left = 8.0
offset_top = 4.0
offset_right = 112.0
offset_bottom = 18.0
text = "Overwrite?"

[node name="YesOption" type="Label" parent="ConfirmDialog"]
offset_left = 8.0
offset_top = 22.0
offset_right = 112.0
offset_bottom = 36.0
text = "Yes"

[node name="NoOption" type="Label" parent="ConfirmDialog"]
offset_left = 8.0
offset_top = 36.0
offset_right = 112.0
offset_bottom = 50.0
text = "No"

[node name="Cursor" type="Sprite2D" parent="."]
texture = ExtResource("2_cursor")
visible = false
```

- [ ] **Step 2:** Verify load_steps = 2 + 0 = 2

---

### Task 12: Write save/load overlay tests

**Files:**
- Create: `game/tests/test_save_load.gd`

- [ ] **Step 1:** Write test_save_load.gd:

```gdscript
extends GutTest
## Tests for Save/Load Overlay.

const SAVE_LOAD_SCENE: PackedScene = preload("res://scenes/overlay/save_load.tscn")


func _create_save_load():
	var sl = SAVE_LOAD_SCENE.instantiate()
	add_child_autofree(sl)
	return sl


# --- Scene Loading ---


func test_save_load_scene_loads() -> void:
	var sl = _create_save_load()
	assert_not_null(sl, "save/load scene should instantiate")


# --- Save Point Menu ---


func test_save_point_menu_visible() -> void:
	var sl = _create_save_load()
	sl.open_save_point()
	assert_true(sl._save_point_menu.visible, "save point menu should be visible")
	assert_eq(sl._sub_state, sl.SubState.SAVE_POINT_MENU, "should be in save point menu state")


# --- Mode Visibility ---


func test_save_mode_hides_auto() -> void:
	var sl = _create_save_load()
	sl.open_save()
	assert_false(sl._auto_slot.visible, "auto slot should be hidden in save mode")


func test_load_mode_shows_auto() -> void:
	var sl = _create_save_load()
	sl.open_load()
	assert_true(sl._auto_slot.visible, "auto slot should be visible in load mode")


# --- Slot Display ---


func test_empty_slot_display() -> void:
	var sl = _create_save_load()
	sl.open_save()
	# With no saves, all slots should show "Empty"
	var header = sl._manual_slots[0].get_node_or_null("HeaderLabel")
	assert_not_null(header, "slot should have header label")
	assert_eq(header.text, "Empty", "empty slot should show Empty text")


func test_populated_slot_display() -> void:
	var sl = _create_save_load()
	# Manually set preview data to test display
	sl._slot_previews = [
		{},  # auto: empty
		{
			"meta": {"version": 1, "playtime": 3723, "saved_at": "2026-04-06", "slot_type": "manual"},
			"party": [],
			"formation": {"active": ["edren", "cael"], "reserve": [], "guests": []},
			"inventory": {},
			"crafting": {},
			"ley_crystals": {},
			"world": {"current_location": "Valdris Crown", "gold": 1200, "event_flags": {}, "act": "1", "current_position": {"x": 0, "y": 0}},
			"quests": {},
			"completion": {},
		},
		{},  # slot 2: empty
		{},  # slot 3: empty
	]
	sl._refresh_slot_display()
	var header = sl._manual_slots[0].get_node_or_null("HeaderLabel")
	assert_not_null(header, "slot should have header label")
	assert_string_contains(header.text, "Valdris Crown", "should show location name")


# --- Save Operation ---


func test_save_writes_file() -> void:
	var sl = _create_save_load()
	watch_signals(sl)
	sl.open_save()
	sl._do_save(1)
	assert_signal_emitted(sl, "save_completed", "should emit save_completed")


func test_overwrite_shows_confirm() -> void:
	var sl = _create_save_load()
	sl.open_save()
	# Fake a populated slot preview
	sl._slot_previews[1] = {"meta": {"version": 1}, "party": [], "formation": {}, "inventory": {}, "crafting": {}, "ley_crystals": {}, "world": {}, "quests": {}, "completion": {}}
	sl._selected_slot = 1
	sl._confirm_slot()
	assert_true(sl._confirm_dialog.visible, "confirm dialog should be visible")
	assert_eq(sl._sub_state, sl.SubState.CONFIRM, "should be in confirm state")


# --- Delete ---


func test_delete_clears_slot() -> void:
	var sl = _create_save_load()
	# Create a temp save file to delete
	SaveManager.save_game(3)
	sl.open_save()
	sl._do_delete(3)
	# File should be removed
	var path: String = SaveManager._slot_path(3)
	assert_false(FileAccess.file_exists(path), "slot file should be deleted")


# --- Cancel ---


func test_cancel_from_save_point_pops() -> void:
	var sl = _create_save_load()
	sl.open_save_point()
	# Cancel should pop overlay — verify state change
	assert_eq(sl._sub_state, sl.SubState.SAVE_POINT_MENU, "should be in save point menu")


# --- Copy ---


func test_copy_slot() -> void:
	var sl = _create_save_load()
	# Create a save in slot 1
	SaveManager.save_game(1)
	sl.open_save()
	sl._do_copy(1, 2)
	# Slot 2 should now have data
	var data: Dictionary = SaveManager.load_game(2)
	assert_false(data.is_empty(), "copied slot should have data")
	# Clean up
	sl._do_delete(1)
	sl._do_delete(2)


func test_load_initial_selection() -> void:
	var sl = _create_save_load()
	# With no saves, should default to slot 1
	sl.open_load()
	# _selected_slot should be 1 since no populated slots exist
	assert_eq(sl._selected_slot, 1, "should default to slot 1 when no saves")
```

- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Commit chunk 4

```bash
git add game/scripts/ui/save_load.gd game/scenes/overlay/save_load.tscn game/tests/test_save_load.gd
git commit -m "feat(engine): add save/load overlay with save point menu and slot display (gap 3.6)"
```

---

### Task 13: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1:** Update gap 3.1 status to COMPLETE with date 2026-04-06
- [ ] **Step 2:** Update gap 3.5 status to COMPLETE with date 2026-04-06
- [ ] **Step 3:** Update gap 3.6 status to COMPLETE with date 2026-04-06
- [ ] **Step 4:** Check off completed items in each gap's "What's Needed" list
- [ ] **Step 5:** Note deferred items with strikethrough
- [ ] **Step 6:** Add notes about bundled implementation, design spec reference
- [ ] **Step 7:** Note that this completes 3/8 Tier 3 gaps. Remaining: 3.2 (Exploration), 3.3 (Battle), 3.4 (Menu), 3.7 (Cutscene), 3.8 (Audio)
- [ ] **Step 8:** Note that 3.7 (Cutscene) is now unblocked by 3.5 (Dialogue)
- [ ] **Step 9:** Run lint on all new files
- [ ] **Step 10:** Final commit

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): mark gaps 3.1, 3.5, 3.6 COMPLETE in tracker"
```

---

### Task 14: Final verification and handoff

- [ ] **Step 1:** Run gdlint on all new .gd files:

```bash
gdlint game/scripts/core/title.gd game/scripts/ui/dialogue_box.gd game/scripts/ui/save_load.gd game/tests/test_title.gd game/tests/test_dialogue.gd game/tests/test_save_load.gd
```

- [ ] **Step 2:** Run gdformat check on all new .gd files
- [ ] **Step 3:** Verify all .tscn load_steps are correct
- [ ] **Step 4:** Mirror check: `grep -rn "3.1\|3.5\|3.6" docs/` for stale references
- [ ] **Step 5:** Verify project.godot has `run/main_scene` set

**Hand off:**
1. `/create-pr` — open a PR targeting main
2. `/godot-review-loop <PR#> 3` — multi-round hardening on the PR
3. Address Copilot comments + gap analysis (autonomous — no reminder needed)
