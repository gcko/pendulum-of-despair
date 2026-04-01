# Godot Project Initialization Design

> **Status:** Implemented (PR #105)
> **Date:** 2026-04-01

## Overview

Initialize the Godot 4.6 project in a `game/` subdirectory with the
directory structure, viewport settings, and autoload scripts defined
in `docs/plans/technical-architecture.md`.

**Location:** `game/` subdirectory. `res://` maps to `game/`.
**Engine:** Godot 4.6+, GDScript only.
**Resolution:** 320x180, integer scaling.

---

## 1. Project File

`game/project.godot` with:
- Viewport: 320x180, window override 1920x1080
- Stretch mode: viewport, aspect: keep, scale_mode: "integer"
- Rendering: nearest-neighbor filter, snap 2D to pixel
- 5 autoload singletons registered
- Application name: "Pendulum of Despair"

## 2. Directory Structure

All folders from technical-architecture.md Section 1.1, under `game/`.
Empty directories get `.gdkeep` placeholder files (git doesn't track
empty dirs).

## 3. Autoload Scripts (Full Implementation)

### game_manager.gd
From technical-architecture.md Section 3.5:
- CoreState enum (TITLE, EXPLORATION, BATTLE)
- OverlayState enum (NONE, MENU, DIALOGUE, SAVE_LOAD, CUTSCENE)
- change_core_state() with scene swap
- push_overlay() returning bool with guard clause + cutscene exception
- pop_overlay()
- Transition data dictionary

### save_manager.gd
From technical-architecture.md Section 6.3:
- CURRENT_SAVE_VERSION, SAVE_DIR, CONFIG_PATH constants
- save_game(slot) with JSON write
- load_game(slot) with JSON parse, migration, validation
- auto_save()
- faint_and_fast_reload() control flow wired; XP/gold merge and level-up processing stubbed for later implementation
- _migrate(), _validate(), _slot_path() helpers

### event_flags.gd
From technical-architecture.md Section 2.9:
- flags Dictionary
- set_flag(), get_flag(), has_flag()

### data_manager.gd
- JSON file loading with caching
- Fatal error on malformed JSON (game data is build-time, not user-editable)
- Typed accessor pattern

### audio_manager.gd
- Channel budget constants (8 music, 12 SFX, 4 ambient = 24 total)
- Priority enum matching audio.md Section 3.2
- Stub methods for play_music(), play_sfx(), play_ambient()
- Full implementation deferred until AudioStreamPlayer scenes exist

## 4. Context File Updates

- `.gitignore` — verify Godot patterns present
- `CLAUDE.md` — add Godot project location and commands
- `AGENTS.md` — update essential commands and repository layout

## 5. What This Does NOT Include

- No .tscn scene files (scenes require visual layout in the Godot editor)
- No asset files (sprites, music, SFX — deferred to art/audio production)
- No JSON data files (deferred to data entry phase)
- No gameplay implementation beyond the autoload managers
