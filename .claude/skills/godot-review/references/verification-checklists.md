# Godot Review Verification Checklists

Reference for all review agents. Check every applicable item.

---

## 1. GDScript Code Quality

### Static Typing
- [ ] All function parameters have type hints
- [ ] All function return types are declared (including `-> void`)
- [ ] All variable declarations use `: Type` or `:= value` inference
- [ ] No bare `var x = value` without type (use `var x: Type = value`)
- [ ] No use of `Variant` where a concrete type is known

### Naming Conventions (per GDScript style guide)
- [ ] Functions: snake_case (`func open_chest()`)
- [ ] Variables: snake_case (`var current_hp: int`)
- [ ] Constants: UPPER_SNAKE_CASE (`const MAX_HP: int = 14999`)
- [ ] Classes: PascalCase (`class_name PlayerCharacter`)
- [ ] Signals: snake_case, past tense (`signal chest_opened`)
- [ ] Enums: PascalCase name, UPPER_SNAKE_CASE values (`enum State { IDLE, WALKING }`)
- [ ] File names: snake_case matching class (`player_character.gd`)
- [ ] No abbreviations in public API names

### Script Organization (17-item ordering)
- [ ] `@tool` (if applicable)
- [ ] `class_name`
- [ ] `extends`
- [ ] Doc comment (##)
- [ ] Signals
- [ ] Enums
- [ ] Constants
- [ ] `@export` variables
- [ ] Public variables
- [ ] Private variables (prefixed `_`)
- [ ] `@onready` variables
- [ ] Built-in virtual methods (`_ready`, `_process`, etc.)
- [ ] Public methods
- [ ] Private methods (prefixed `_`)
- [ ] Signal callbacks (prefixed `_on_`)
- [ ] Static methods
- [ ] Inner classes

### Common GDScript Antipatterns
- [ ] No `get_parent()` calls (use signals — "call down, signal up")
- [ ] No `get_node("../../sibling")` path traversal (fragile, breaks on restructure)
- [ ] No uncached `$NodePath` in `_process()` (cache in `@onready`)
- [ ] No `find_child()` in hot paths
- [ ] No `null` where a typed default works (use `""`, `0`, `[]`)
- [ ] No monolithic scripts (>300 lines = consider splitting)
- [ ] No direct singleton state mutation from deep children (signal up instead)

### Defensive Coding (from Copilot gap analysis, PR #105)
- [ ] Dictionary key access guarded before write (`data.get()` or `has()` before `data["key"] = value`)
- [ ] `load()` / `preload()` results checked for null before calling `.instantiate()`
- [ ] `ResourceLoader.exists(path)` checked before `change_scene_to_file(path)` or `load(path)`
- [ ] Public API parameters validated for range (e.g., slot 0-3, not arbitrary int)
- [ ] `assert(false)` NOT used as the sole error handler — asserts are disabled in release builds. Use `push_error()` + `get_tree().quit(1)` for truly fatal errors.
- [ ] Stub/placeholder methods that return empty data (`{}`, `[]`, `0`) don't cause downstream failures (e.g., save_game writing empty dict that fails validation on load)
- [ ] Docstrings match actual return behavior (if func returns error dicts AND empty dicts, document both)
- [ ] Docstrings and specs for stubbed methods describe behavior as "when implemented" or "stubbed" — not as if currently functional
- [ ] `print()` debug statements gated behind `OS.is_debug_build()` or use `print_debug()` — never bare `print()` in autoload methods called frequently
- [ ] Migration/upgrade functions fail explicitly on missing steps rather than silently skipping
- [ ] `save_game()` or similar write methods must use the ACTUAL data being written, not rebuild from scratch (FFR merged data bug)
- [ ] JSON parse result (`json.data`) must be type-checked before typed assignment (`is Dictionary`)
- [ ] Migration/upgrade error paths must NOT set the version to current — return error instead
- [ ] State/signal emission must happen AFTER validation, not before (observers see invalid state)
- [ ] Enum parameters must be validated against the lookup table (OverlayState.NONE has no scene)
- [ ] `load()` result must be type-checked (`is PackedScene`) before calling `.instantiate()`
- [ ] Autoload scripts should NOT use `class_name` — access via autoload name, not class name
- [ ] Nested dictionary access validates each level's type (`data["a"]["b"]` requires `data["a"] is Dictionary` check)
- [ ] Scene transition return values checked (`change_scene_to_file()` returns `Error` — verify `OK` before mutating state)
- [ ] When signal-before-validation is deferred as design choice, verify error/revert paths emit compensating signals
- [ ] All functions returning `Error` or `bool` status must have return values checked — not just scene transitions (DirAccess, FileAccess, write helpers)
- [ ] State set before deferred calls (e.g., `change_scene_to_file`) must be REVERTED on failure, not omitted — new scene `_ready()` reads state immediately
- [ ] GDScript falsy checks (`if data`) fail for empty `[]`/`{}`/`0` — use explicit `!= null` when checking for null returns

### Documentation Accuracy
- [ ] CLI commands in AGENTS.md/CLAUDE.md actually work in the current project state
- [ ] If `run/main_scene` is empty, don't claim the game can be "run" — say "open in editor"
- [ ] Spec status fields updated when spec is implemented (e.g., "pending" -> "Implemented (PR #N)")
- [ ] Spec setting descriptions match actual project.godot values and format
- [ ] Review reference doc headings/counts match actual content (e.g., "10 categories" vs actual 12)
- [ ] Code comments in migration/versioning logic match actual constants and scheme
- [ ] Gap tracker "Notes" section claims only match actual implementation (no claiming gold border if using modulate, no claiming copy-from if no UI path)

### Scene Rendering (from Copilot PR #119 gap analysis)
- [ ] NinePatchRect nodes MUST have a texture assigned — otherwise invisible. Prefer PanelContainer + StyleBoxFlat for UI windows without art assets.
- [ ] Sprite2D nodes MUST have a texture assigned — otherwise invisible even when set to visible. Assign a placeholder if no art exists.
- [ ] UI panel colors (bg_color, border_color) must match ui-design.md Section 1.4 palette hex values

### Test Hygiene (from Copilot PR #119 gap analysis)
- [ ] Tests that create persistent state (save files, config files) must have `after_each()` cleanup
- [ ] Tests that inject fake data must not call methods that overwrite it (e.g., `_refresh` calling `SaveManager.get_slot_previews()`)
- [ ] Tests that depend on state absence (no saves) must ensure cleanup runs even across test files
- [ ] Destructive test operations (delete) must assert preconditions (file exists) before testing deletion

---

## 2. Scene Architecture

### Scene Composition
- [ ] Each scene has one clear responsibility
- [ ] Reusable behaviors are separate scenes instanced as children
- [ ] No scene depends on its parent's structure (portable)
- [ ] Scene tree reflects logical relationship, not spatial layout

### Signal Architecture
- [ ] "Call down, signal up" — parents call children, children emit signals
- [ ] No child directly references parent (`get_parent()`)
- [ ] Signal connections documented (either in `_ready()` or editor)
- [ ] Custom signals have typed parameters where possible

### Node Usage
- [ ] Correct node type for purpose (CharacterBody2D for movement, Area2D for triggers, etc.)
- [ ] Unused nodes removed (no leftover test nodes)
- [ ] `process_mode` set correctly (PROCESS_MODE_ALWAYS for overlay scenes)
- [ ] Visibility and collision layers used correctly

---

## 3. Pixel Art Specific (320x180 Viewport)

### Viewport Configuration
- [ ] Viewport size is 320x180
- [ ] Stretch mode is "viewport"
- [ ] Stretch aspect is "keep"
- [ ] Scale mode is `"integer"` (Godot 4.x string format in project.godot)
- [ ] Default texture filter is Nearest (0)

### Snap to Pixel
- [ ] `2d/snap/snap_2d_transforms_to_pixel` is true
- [ ] `2d/snap/snap_2d_vertices_to_pixel` is true
- [ ] Camera2D has smoothing disabled or uses pixel-snapped smoothing
- [ ] Camera zoom is whole numbers only (1x, 2x, 3x — no 1.5x)
- [ ] No sprite positions with decimal values in scene files
- [ ] No tween/animation targets with sub-pixel positions

### Import Settings
- [ ] All sprite/tileset imports use Filter = Nearest
- [ ] No mipmaps enabled on pixel art
- [ ] No compression that could blur pixels
- [ ] Texture atlas packing preserves pixel boundaries

### Sprite Sizes
- [ ] Character sprites: 16x24 (per technical-architecture.md)
- [ ] Battle sprites: 32x32 to 64x64
- [ ] Tiles: 16x16
- [ ] Status icons: 8x8
- [ ] UI elements match ui-design.md specifications

---

## 4. Data & Persistence

### JSON Data Files
- [ ] All keys use snake_case (not camelCase)
- [ ] File in correct `data/` subdirectory per technical-architecture.md
- [ ] Values match canonical source docs (bestiary, items.md, equipment.md, etc.)
- [ ] No trailing commas (invalid JSON)
- [ ] Proper array/object nesting

### JSON Data Gap Work (from Copilot gap analysis, PRs #108 + #109)
- [ ] **HARD GATE: After ANY data count change, run programmatic scan of ALL spec/plan/gap/PR docs for stale counts BEFORE committing.** No commit until scan returns zero stale references. Check: scope totals, file structure tables, section totals, subcategory breakdowns, plan task instructions, plan validation steps, PR description.
- [ ] **Cross-file ID uniqueness:** Run programmatic sweep across ALL item + equipment + enemy data files. IDs must be globally unique (single shared `item_id` namespace). Within-file checks are insufficient.
- [ ] **source_category verification:** Every material's `source_category` must match the items.md section header AND the source type annotation (e.g., "Beast (rare)" means `beast`, not `humanoid`, even if listed in the Humanoid/Flavor section).
- [ ] **Non-standard schema field documentation:** Every field in JSON data that isn't in the base schema (e.g., `auto_sell`, `ac_restorable`, `battle_usable`, `gold_value_by_act`, `boss_group`, `phase_hp_thresholds`) must be documented in the spec's Special Cases section before commit.
- [ ] **Full-doc re-read after fixing drift:** After fixing one instance of documentation drift (stale count, wrong category, etc.), re-read the ENTIRE spec and plan for any other instance of the same error type. Don't just fix the specific line — Copilot will find the others you missed.

### Save System
- [ ] Save files write to `user://saves/` (not `res://`)
- [ ] Global config separate from save slots (`user://config.json`)
- [ ] Save data includes `meta.version` for migration
- [ ] `_validate()` checks all 9 required top-level keys
- [ ] Auto-save triggers match save-system.md Section 6

### Event Flags
- [ ] Flag names match events.md (58 numbered + boss_cutscene_seen_*)
- [ ] Flag types correct (bool for most, int for council_result, string for reunion_order)
- [ ] Boss cutscene flags use parameterized pattern: `boss_cutscene_seen_{boss_id}`

---

## 5. Audio Integration

### Channel Budget
- [ ] Total channels <= 24 (8 music + 12 SFX + 4 ambient)
- [ ] Music never drops below 4 channels under pressure

### Priority Stack
- [ ] Cutscene SFX > Battle jingles > Boss onset > Battle SFX > UI SFX > Exploration SFX > Music > Ambient
- [ ] Same SFX ID limited to 2 simultaneous instances

### Mixing Model
- [ ] Overworld: music 100%, ambient 30-40%
- [ ] Dungeons: music 50-60%, ambient 80-100%
- [ ] Narrative dungeons (Siege, Convergence, Axis Tower): music 100%, ambient 30-40%
- [ ] Pallor Wastes: music 0% (drone on ambient channels), ambient 40%
- [ ] Battle: music 100%, ambient 0%

### Asset Format
- [ ] OGG Vorbis format
- [ ] 44.1 kHz sample rate
- [ ] 16-bit depth
- [ ] Naming: `{category}_{name}.ogg`

---

## 6. Performance

### Budgets
- [ ] Frame rate: 60 fps target
- [ ] Max entities per exploration scene: 64
- [ ] Max enemies per battle: 6
- [ ] Max simultaneous particle emitters: 16
- [ ] Max tilemap layers: 4
- [ ] Scene load time: <1 second
- [ ] Save file size: <256 KB

### Common Performance Issues
- [ ] No `_process()` on nodes that don't need per-frame updates (use `_physics_process()` or timers)
- [ ] No `load()` calls in `_process()` (preload or cache)
- [ ] No `String` concatenation in hot loops (use `StringName`)
- [ ] Particle emitters disabled when off-screen
- [ ] TileMap layers minimized (only what's needed)

---

## 7. Project-Specific (Pendulum of Despair)

### State Machine (GameManager)
- [ ] Core state transitions use `change_core_state()` (not direct `change_scene_to_file()`)
- [ ] Overlay pushes use `push_overlay()` and check return value
- [ ] Only one overlay active at a time
- [ ] Cutscene can override dialogue (the one exception)
- [ ] Transition data passed via `GameManager.transition_data`

### Autoload Usage
- [ ] Game state accessed via `GameManager`, not direct scene tree traversal
- [ ] Data loaded via `DataManager`, not direct `FileAccess` in entity scripts
- [ ] Audio played via `AudioManager`, not direct `AudioStreamPlayer` creation
- [ ] Flags accessed via `EventFlags`, not custom dictionaries
- [ ] Save/load via `SaveManager`, not direct file operations

### Design Doc Compliance
- [ ] Numeric values match canonical docs (bestiary, items.md, equipment.md, etc.)
- [ ] Game mechanics match combat-formulas.md
- [ ] UI layout matches ui-design.md
- [ ] Audio behavior matches audio.md
- [ ] Save behavior matches save-system.md

---

## 8. Defensive Coding (from Copilot gap analyses PRs #105-116)

### Input Validation
- [ ] Damage/heal methods clamp `amount` to >= 0 (prevent negative inputs reversing behavior)
- [ ] Methods that accept indices validate bounds before access
- [ ] Enum parameters validated against known values (not just any string)
- [ ] Resource paths validated with `ResourceLoader.exists()` before `load()`
- [ ] **Every public method guards against uninitialized state** (check if initialize() was called — ID fields empty, data dicts empty)
- [ ] **Every initialize() validates its inputs** (empty strings, null values) with push_error + return
- [ ] **Every interact/action method returns early if entity not ready** (not just checking "is_opened" but also "was I configured?")

### Test Branch Coverage
- [ ] **Every `if` branch in the code has a corresponding test** (not just happy path)
- [ ] **Every signal emission path has a signal-watching test**
- [ ] **Every early-return guard has a test proving it blocks** (uninitialized, already-fired, immune)
- [ ] Tests use constructed data to exercise specific branches (not relying on JSON that may lack the needed values)

### Mirror Staleness Prevention (MANDATORY after every code change)
- [ ] After changing ANY value: `grep -r "old_value" docs/` and fix every hit
- [ ] After adding/removing tests: remove hardcoded test counts from docs (use descriptive text)
- [ ] After changing method behavior: update spec's method description
- [ ] After changing scene config: update spec's collision/config tables

### Default State Safety
- [ ] Boolean state vars (`is_alive`, `is_ready`, etc.) default to the SAFE state (false/inactive), not the active state
- [ ] Uninitialized entities return empty/safe values from getters (not defaults that look valid)
- [ ] `initialize()` methods reset ALL mutable state before loading (safe for re-init)
- [ ] `@onready` vars guarded with null checks when accessed from methods that may run before `_ready()`

### Signal Safety
- [ ] State-transition signals emit only ONCE per transition (guard against double-fire)
- [ ] Signals not emitted on uninitialized or dead entities
- [ ] Signal emission happens AFTER state mutation (not before)

### Node Reference Safety
- [ ] Use `get_node_or_null()` instead of `get_node()` for fallback paths
- [ ] `@onready` fallbacks use `get_node_or_null()` not `get_node()` (prevents crash if node missing)

---

## 9. JSON Data Gap Work (from PRs #108-113)

### HARD GATES (mandatory before every data commit)
- [ ] Programmatic stale-count scan: all count claims in spec/plan/gap docs match actual file/entry counts
- [ ] Cross-file ID uniqueness: no duplicate IDs within namespace (items, enemies, equipment, dialogue)
- [ ] All enemy_ids in encounter files exist in gap 1.2 enemy data
- [ ] All material/equipment IDs in crafting files exist in gap 1.3 data
- [ ] All JSON files use 2-space indent per .editorconfig (no tabs)

### Mirror Staleness Prevention
- [ ] After changing ANY value in data files, grep ALL spec/plan/gap docs for the old value
- [ ] After changing act values, propagate to spec file structure tables AND plan dungeon lists
- [ ] After changing entry counts (adding/removing entries), update ALL docs that reference the count
- [ ] When fixing a pattern-based issue, grep ALL files for the same pattern (not just flagged instances)

### Source Doc Verification
- [ ] Every value traces to a canonical doc in docs/story/
- [ ] Bonus_effect text matches equipment.md/crafting.md VERBATIM (no paraphrasing)
- [ ] Speaker IDs match characters.md or npcs.md
- [ ] Flag names match events.md
- [ ] Animation IDs match dialogue-system.md catalog (14 animations + clear)
- [ ] Accessibility features match accessibility.md
