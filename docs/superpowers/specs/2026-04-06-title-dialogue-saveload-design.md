# Gaps 3.1 + 3.5 + 3.6: Title Screen, Dialogue Overlay, Save/Load Overlay — Design Spec

> **Date:** 2026-04-06
> **Gaps:** 3.1 (Title Screen), 3.5 (Dialogue Overlay), 3.6 (Save/Load Overlay)
> **Status:** Approved
> **Source docs:** ui-design.md (Sections 12, 13, 17), dialogue-system.md (Sections 1-4), save-system.md (Sections 4-6), accessibility.md Section 7, technical-architecture.md Section 3
> **Architecture ref:** technical-architecture.md Section 3 (Game State Machine)

## Problem

The game has no runnable entry point (no main_scene), no way to display dialogue text, and no way to save/load. These three systems are the minimum UI needed before the exploration scene (3.2) can be functional. All three plug into the existing GameManager state machine.

## Scope

- 3 scene files + 3-4 script files
- 1 placeholder sprite (pixel cursor)
- 3 test files
- Set project main_scene to title.tscn

**Excluded (deferred):**
- Title music playback -> gap 3.8 (Audio Integration)
- Config screen -> gap 3.4 (Menu Overlay)
- Rest item consumption -> gap 3.4 (needs inventory system)
- Cutscene camera/movement control -> gap 3.7 (Cutscene Overlay)
- Cael's grey border flicker (Act IV) -> gap 3.7 (Cutscene Overlay)
- Character field abilities from save point -> gap 3.4
- High-Res Text rendering layer -> gap 4.7 (Accessibility)
- Inn rest variant (paid rest instead of item sub-menu) -> gap 3.2 (Exploration Scene, inn-specific save point type)

---

## 3.1 Title Screen

### Scene Tree

```
Title (Control)
├── Background (ColorRect)         — dark navy #000040, full viewport
├── TitleLabel (Label)             — game title text, centered upper third
├── MenuContainer (VBoxContainer)  — centered lower third
│   ├── NewGameOption (Label)
│   ├── ContinueOption (Label)
│   └── ConfigOption (Label)
├── Cursor (Sprite2D)             — pixel-art hand cursor, 2-frame animation
├── AnimationPlayer               — cursor idle animation
└── title.gd
```

### Node Configuration

| Node | Property | Value | Notes |
|------|----------|-------|-------|
| Title | process_mode | INHERIT | Core state, not overlay |
| Background | color | Color(0, 0, 0.25, 1) | #000040 |
| TitleLabel | text | "Pendulum of Despair" | Placeholder until logo art |
| TitleLabel | horizontal_alignment | CENTER | |
| TitleLabel | theme_override font_color | #ffffff | White |
| MenuContainer | alignment | CENTER | |

### GDScript API

```gdscript
## Title screen with 3-option menu and cursor navigation.
## Core state scene — set as project main_scene.

## Menu options enum.
enum MenuOption { NEW_GAME, CONTINUE, CONFIG }

## Currently selected menu option.
var _selected: int = 0

## Label nodes for each option.
var _options: Array[Label] = []

## Whether a save exists (enables Continue option).
var _has_save: bool = false
```

**Public Methods:** None (title screen is self-contained, responds to input).

**Input Handling:**
- Up/Down arrows: move cursor between options
- Confirm (Space/Enter): execute selected option
- Selected option: yellow `#ffff88`, others: pale blue `#ccddff`
- Config: greyed out `#666688` with "(Coming Soon)" — stubbed until gap 3.4

**Menu Actions:**
- **New Game:** `GameManager.change_core_state(CoreState.EXPLORATION, {"new_game": true})`
- **Continue:** Load most recent save via `SaveManager.load_most_recent()` (public wrapper around existing `_load_most_recent_save()`). If no saves exist, option is greyed out. If save is corrupted, show brief error message and return to title. On success: `GameManager.change_core_state(GameManager.CoreState.EXPLORATION, {"save_slot": slot})`
- **Config:** Stubbed — no action, option greyed out

### project.godot Change

```
run/main_scene = "res://scenes/core/title.tscn"
```

---

## 3.5 Dialogue Overlay

### Scene Tree

```
Dialogue (CanvasLayer)
├── DialogueBox (NinePatchRect)    — full-width bottom, dark navy bg, 2px border
│   ├── SpeakerLabel (Label)       — top-left inset, white text
│   ├── TextLabel (RichTextLabel)  — 3 visible lines, typewriter effect
│   └── AdvanceArrow (Sprite2D)    — bottom-right bouncing arrow
├── ChoiceBox (NinePatchRect)      — above dialogue box, hidden by default
│   └── ChoiceContainer (VBoxContainer)
│       ├── Choice0 (Label)
│       ├── Choice1 (Label)
│       ├── Choice2 (Label)
│       └── Choice3 (Label)
├── ChoiceCursor (Sprite2D)        — same pixel hand cursor
├── AnimationPlayer                — arrow bounce, cursor idle
└── dialogue_box.gd
```

### Node Configuration

| Node | Property | Value | Notes |
|------|----------|-------|-------|
| Dialogue | layer | 10 | Above game world |
| Dialogue | process_mode | ALWAYS | Runs while paused |
| DialogueBox | position | Vector2(0, 140) | Bottom-anchored at 320x180 |
| DialogueBox | size | Vector2(320, 40) | Full width, ~3 lines |
| SpeakerLabel | position | Vector2(4, -10) | Inset tag above box |
| TextLabel | bbcode_enabled | true | For future inline icons |

### GDScript API

```gdscript
## Dialogue overlay with typewriter text, speaker names, and choice prompts.
## Processes dialogue entries sequentially. Emits dialogue_finished when done.

signal dialogue_finished
signal choice_made(choice_index: int)

## Text speed in characters per second, indexed by config setting.
const TEXT_SPEEDS: Dictionary = {
    "slow": 30,
    "normal": 60,
    "fast": 120,
    "instant": 99999,
}

## Current dialogue entries being processed.
var _entries: Array = []

## Current entry index.
var _current_index: int = 0

## Current line index within entry.
var _current_line: int = 0

## Characters revealed so far in current line.
var _chars_revealed: int = 0

## Whether text is fully revealed for current line.
var _text_complete: bool = false

## Whether we're in choice mode.
var _in_choice: bool = false

## Selected choice index.
var _choice_index: int = 0
```

**Public Methods:**

```gdscript
## Start displaying a sequence of dialogue entries.
## Called by exploration scene after receiving npc_interacted signal.
func show_dialogue(entries: Array) -> void

## Force-close dialogue (for cutscene override).
func close() -> void
```

**Dialogue Flow:**

1. `show_dialogue(entries)` stores entries, starts at index 0. If entries is empty, immediately emits `dialogue_finished` and pops overlay.
2. For each entry:
   a. Display speaker name (if present)
   b. Fire any "before" animations (emit signal — exploration scene handles)
   c. Typewriter-render each line (3 lines max visible)
   d. If entry has `choice` field: show choice box, wait for selection
   e. On confirm: if text incomplete -> complete instantly; if complete -> advance
   f. After last line of entry: advance to next entry
3. After all entries: emit `dialogue_finished`, call `GameManager.pop_overlay()`

**Animation/SFX Signals:**

```gdscript
## Emitted when an animation marker is encountered.
signal animation_requested(who: String, anim: String)

## Emitted when an SFX marker is encountered.
signal sfx_requested(sfx_id: String)
```

The dialogue overlay does NOT play animations or SFX directly — it signals up and the parent scene handles playback. This follows "call down, signal up."

**Choice Handling:**
- 2-4 vertical options, cursor navigation. Unused Choice labels (e.g., Choice2/3 when only 2 options) are hidden.
- Selected: yellow `#ffff88`, others: pale blue `#ccddff`
- Cancel selects bottom option (per ui-design.md Section 12.4)
- On selection: emit `choice_made(index)`, advance to next entry

**Text Speed Config Source:**
- Reads current text speed setting from `DataManager.load_json("res://data/config/defaults.json")` field `text_speed`. Default: `"normal"` (60 cps). Config system (gap 3.4) will later provide runtime overrides.

**Text Rendering Details:**
- Typewriter: `_chars_revealed` increments per frame based on text speed
- `visible_characters` property on RichTextLabel controls reveal
- Confirm press while typing: instantly set `visible_characters = -1` (show all)
- When text complete: show bouncing advance arrow
- Multi-page: if entry lines > 3, paginate (advance arrow between pages)

### Condition Evaluation

The dialogue overlay does NOT evaluate conditions. That's already done by the NPC prefab's `get_current_dialogue()` which resolves the priority stack before emitting. The overlay receives pre-resolved entries.

However, for flag-setting after dialogue completion, the overlay emits:

```gdscript
## Emitted when dialogue entry has a flag to set on completion.
signal flag_set_requested(flag_name: String, value: Variant)
```

---

## 3.6 Save/Load Overlay

### Scene Tree

```
SaveLoad (CanvasLayer)
├── Background (ColorRect)             — semi-transparent dark overlay
├── SavePointMenu (NinePatchRect)      — 3-option save point menu (hidden if direct save/load)
│   ├── RestOption (Label)
│   ├── RestSaveOption (Label)
│   └── SaveOption (Label)
├── SlotContainer (VBoxContainer)      — save slot display
│   ├── AutoSlot (PanelContainer)      — blue accent, "AUTO" label (load screen only)
│   ├── Slot1 (PanelContainer)
│   ├── Slot2 (PanelContainer)
│   └── Slot3 (PanelContainer)
├── RestMenu (NinePatchRect)           — rest item sub-menu (hidden by default)
│   ├── SleepingBagOption (Label)
│   ├── TentOption (Label)
│   └── PavilionOption (Label)
├── ConfirmDialog (NinePatchRect)      — "Overwrite?" / "Delete?" prompts
│   ├── ConfirmLabel (Label)
│   ├── YesOption (Label)
│   └── NoOption (Label)
├── Cursor (Sprite2D)
├── AnimationPlayer
└── save_load.gd
```

### Node Configuration

| Node | Property | Value | Notes |
|------|----------|-------|-------|
| SaveLoad | layer | 10 | Above game world |
| SaveLoad | process_mode | ALWAYS | Runs while paused |
| AutoSlot | visible | false | Only shown in load mode |
| AutoSlot border | color | #88aaff | Blue accent per ui-design.md 13.6 |
| SavePointMenu | visible | false | Shown only when opened from save point |

### GDScript API

```gdscript
## Save/Load overlay with save point 3-option menu, slot display, and rest stubs.

signal save_completed(slot: int)
signal load_completed(slot: int)

## Operating modes.
enum Mode { SAVE_POINT, SAVE, LOAD }

## Sub-states for navigation.
enum SubState { SAVE_POINT_MENU, REST_MENU, SLOT_SELECT, CONFIRM, OPERATION_SELECT }

## Current operating mode.
var _mode: Mode = Mode.SAVE

## Current sub-state.
var _sub_state: SubState = SubState.SLOT_SELECT

## Currently selected slot (0=auto, 1-3=manual).
var _selected_slot: int = 1

## Currently selected save point menu option.
var _save_point_selection: int = 0

## Loaded slot preview data (for display).
var _slot_previews: Array[Dictionary] = []
```

**Public Methods:**

```gdscript
## Initialize as save point interaction (shows 3-option menu first).
func open_save_point() -> void

## Initialize as direct save screen (from menu).
func open_save() -> void

## Initialize as load screen (from title or menu).
func open_load() -> void
```

**Save Point 3-Option Menu Flow:**

1. Rest -> open rest sub-menu (stubbed: shows items, consumption is push_warning no-op)
2. Rest & Save -> rest first (stubbed), then open save screen
3. Save -> open save screen directly
4. Cancel -> `GameManager.pop_overlay()`

**Slot Display (per ui-design.md Section 13.2-13.4):**

Each populated slot shows (per ui-design.md Section 13.3):
- Header: location name (left) + playtime HH:MM + gold (right)
- Party row: up to 4 active members — 16x20 walking sprite (placeholder colored rect) + name + level + tiny HP bar (pixel fill, no numeric)
- Selected slot: gold border `#ffcc44` + hand cursor
- All text in canonical palette colors

Empty slots: centered "Empty" in muted grey `#666688`.

**All slots empty on load screen:** If no saves exist (including auto), all slots show "Empty" and none are selectable. Only cancel (back to title) works.

**Save Flow:**
1. Show 3 manual slots (no auto slot on save screen per save-system.md Section 5)
2. Cursor selects slot -> confirm
3. If populated: "Overwrite?" confirmation
4. On confirm: `SaveManager.save_game(slot)` -> sparkle animation -> "Saved." -> return

**Load Flow:**
1. Show auto slot (top, blue accent `#88aaff`, labeled "AUTO") + horizontal divider + 3 manual slots
2. Empty slots not selectable (cursor skips). Corrupted slots show "Corrupted" in red, not selectable.
3. Auto slot can be loaded or copied-from to a manual slot (promotion per save-system.md Section 5)
4. Confirm on populated slot -> fade transition -> load
5. `_selected_slot` initialized to first populated slot (auto=0 if populated, else first manual)

**Rest Sub-Menu (Stubbed):**
- Shows 3 options: Sleeping Bag, Tent, Pavilion
- Each shows restore amounts per save-system.md Section 4
- Selection triggers `push_warning("Rest item consumption not yet implemented")`
- Free fallback (no items): restores 25% MP only (also stubbed)

**Operations Menu:**
- Save screen has Save / Copy / Delete operations per ui-design.md Section 13.5
- Copy: source slot -> destination slot -> "Overwrite?" if populated
- Delete: select slot -> "Delete this save?" -> clear

---

## Shared UI Components

### Pixel Cursor

Shared 16x16 pixel-art hand cursor sprite used by all three scenes.

| File | Size | Description |
|------|------|-------------|
| `cursor_hand.png` | 16x16 | 2 frames: pointing + slight bounce |

Location: `game/assets/sprites/ui/`

### Window Style

All UI windows follow ui-design.md Section 1.3:
- Background: dark navy `#000040`
- Border: 2px blue-grey `#5566aa`
- Implemented as NinePatchRect with a 3x3 pixel-art texture or ColorRect + StyleBoxFlat

### Input Actions

Per ui-design.md Section 17, these Godot input actions are needed:

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| ui_up | Up Arrow | D-pad Up |
| ui_down | Down Arrow | D-pad Down |
| ui_accept | Space, Enter | A / Cross |
| ui_cancel | Escape | B / Circle |

Godot provides `ui_up`, `ui_down`, `ui_accept`, `ui_cancel` as built-in actions. We use these directly — no custom input map needed.

---

## Tests

### test_title.gd (6 tests)

1. **test_title_scene_loads** — instantiate title.tscn, verify root node exists
2. **test_menu_options_exist** — verify 3 menu option labels present
3. **test_initial_selection** — verify cursor starts on New Game (index 0)
4. **test_cursor_wraps** — move up from index 0 wraps to last option
5. **test_continue_disabled_no_saves** — Continue option greyed out when no saves
6. **test_config_disabled** — Config option greyed out (stubbed)

### test_dialogue.gd (14 tests)

1. **test_dialogue_scene_loads** — instantiate dialogue.tscn, verify nodes
2. **test_show_dialogue_sets_entries** — call show_dialogue(), verify state
3. **test_speaker_name_displayed** — entry with speaker shows name label
4. **test_speaker_name_empty** — entry without speaker hides name label
5. **test_typewriter_reveals_chars** — after N frames, visible_characters incremented
6. **test_confirm_completes_text** — confirm press while typing completes instantly
7. **test_confirm_advances_entry** — confirm press when complete moves to next entry
8. **test_last_entry_emits_finished** — after last entry, dialogue_finished emitted
9. **test_choice_display** — entry with choice field shows choice box
10. **test_choice_selection** — cursor moves between choices, confirm emits choice_made
11. **test_choice_cancel_selects_bottom** — cancel press selects last choice option
12. **test_animation_signal** — entry with animation marker emits animation_requested
13. **test_empty_entries** — show_dialogue([]) immediately emits dialogue_finished
14. **test_multipage_pagination** — entry with >3 lines paginates correctly

### test_save_load.gd (12 tests)

1. **test_save_load_scene_loads** — instantiate save_load.tscn, verify nodes
2. **test_save_point_menu_visible** — open_save_point() shows 3-option menu
3. **test_save_mode_hides_auto** — open_save() hides auto slot
4. **test_load_mode_shows_auto** — open_load() shows auto slot
5. **test_empty_slot_display** — empty slots show "Empty" text
6. **test_populated_slot_display** — populated slot shows location + party + time
7. **test_save_writes_file** — save to slot calls SaveManager.save_game()
8. **test_overwrite_shows_confirm** — saving to populated slot shows confirmation
9. **test_delete_clears_slot** — delete operation clears slot file
10. **test_cancel_pops_overlay** — cancel from top-level calls GameManager.pop_overlay()
11. **test_copy_slot** — copy from slot 1 to slot 2 duplicates save data
12. **test_load_initial_selection** — open_load() selects first populated slot

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/scripts/core/title.gd` | Title screen logic |
| Create | `game/scenes/core/title.tscn` | Title screen scene |
| Create | `game/scripts/ui/dialogue_box.gd` | Dialogue overlay logic |
| Create | `game/scenes/overlay/dialogue.tscn` | Dialogue overlay scene |
| Create | `game/scripts/ui/save_load.gd` | Save/Load overlay logic |
| Create | `game/scenes/overlay/save_load.tscn` | Save/Load overlay scene |
| Create | `game/assets/sprites/ui/cursor_hand.png` | Shared pixel cursor |
| Create | `game/tests/test_title.gd` | Title screen tests |
| Create | `game/tests/test_dialogue.gd` | Dialogue overlay tests |
| Create | `game/tests/test_save_load.gd` | Save/Load overlay tests |
| Modify | `game/scripts/autoload/save_manager.gd` | Add public `load_most_recent()` wrapper |
| Modify | `game/project.godot` | Set run/main_scene |
| Modify | `docs/analysis/game-dev-gaps.md` | Update 3.1, 3.5, 3.6 status |

---

## Verification Checklist

- [ ] Title scene loads in Godot editor without errors
- [ ] Title scene set as main_scene in project.godot
- [ ] Menu cursor navigation works (up/down/wrap)
- [ ] New Game transitions to Exploration (will fail until 3.2 exists — expected)
- [ ] Continue greyed out when no saves exist
- [ ] Config greyed out with stub indicator
- [ ] Dialogue overlay shows speaker name correctly
- [ ] Typewriter effect at correct speed per text speed setting
- [ ] Confirm instantly completes text, then advances
- [ ] Choice prompts display and navigate correctly
- [ ] Cancel selects bottom choice option
- [ ] dialogue_finished emits after last entry
- [ ] animation_requested and sfx_requested signals emit correctly
- [ ] Save point 3-option menu displays
- [ ] Save screen shows 3 manual slots only (no auto)
- [ ] Load screen shows auto + 3 manual slots
- [ ] Empty slots display "Empty" in muted grey
- [ ] Overwrite confirmation appears for populated slots
- [ ] Rest sub-menu displays but consumption is stubbed
- [ ] All scenes use canonical color palette from ui-design.md Section 1.4
- [ ] All overlays have process_mode ALWAYS
- [ ] All code passes gdlint + gdformat
- [ ] Tests cover every if-branch (dual-pass verified)
