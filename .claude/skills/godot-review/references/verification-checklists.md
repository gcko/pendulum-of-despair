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
- [ ] Scale mode is integer (1)
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
- [ ] Accessibility features match accessibility.md
