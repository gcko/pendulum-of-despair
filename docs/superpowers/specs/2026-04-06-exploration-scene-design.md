# Gap 3.2: Exploration Scene (Minimal Viable) — Design Spec

> **Date:** 2026-04-06
> **Gap:** 3.2 (Exploration Scene — Option A: Minimal Viable)
> **Status:** Approved
> **Source docs:** overworld.md (movement, transitions), ui-design.md Section 15 (exploration UI), save-system.md Section 6 (auto-save triggers), technical-architecture.md Sections 3-4
> **Architecture ref:** technical-architecture.md Section 3 (Game State Machine)

## Problem

The game has a launchable title screen but no explorable world. All entity prefabs (player, NPC, chest, trigger zone, save point) and overlays (dialogue, save/load) exist but have no scene to wire them together. The exploration scene is the integration hub that makes the game playable.

## Scope — Minimal Viable Exploration

Core integration only. Gets a player walking in a map, interacting with entities, and transitioning between maps.

**Included:**
- Exploration scene as core state (`CoreState.EXPLORATION`)
- Map loading system (load .tscn map scenes by ID)
- PlayerCharacter instantiation with movement
- Camera2D following player (pixel-snapped, integer zoom)
- Entity signal wiring: NPC → dialogue, save point → save/load, chest → found item
- Map transitions (door/exit → fade to black → load new map)
- Location name flash (center-top text on area entry)
- New Game / Continue initialization from title screen transition_data
- 1 test map scene for verification

**Excluded (deferred):**
- Danger counter + encounter trigger → deferred until gap 3.3 (Battle Scene) exists
- Auto-save triggers → deferred until exploration is stable
- Audio context switching → gap 3.8 (Audio Integration)
- Weather/atmospheric effects → gap 4.x (content)
- Menu button → gap 3.4 (Menu Overlay)
- Mode 7 overworld perspective → gap 4.3 (Overworld Map)

---

## Scene Tree

```
Exploration (Node2D)
├── Camera2D                      — follows player, pixel-snapped
├── CurrentMap (Node2D)           — container for the loaded map scene
├── LocationFlash (CanvasLayer)   — location name overlay
│   └── LocationLabel (PanelContainer)
│       └── NameLabel (Label)
└── exploration.gd
```

The loaded map scene is instanced as a child of `CurrentMap`. Map scenes contain:
```
MapScene (Node2D)
├── Background (ColorRect)        — placeholder colored background (real TileMapLayers in gap 4.1)
├── Entities (Node2D)             — container for placed entities
│   ├── NPC instances             — metadata: npc_id
│   ├── TreasureChest instances   — metadata: chest_id, item_id
│   └── SavePoint instances       — metadata: save_point_id
├── Transitions (Node2D)          — door/exit Area2D zones (repeatable, NOT one-shot TriggerZone)
│   └── Area2D instances (with target_map, target_spawn metadata)
└── PlayerSpawn (Marker2D)        — where player appears on entry
```

**Note:** Map transitions use plain Area2D with `body_entered`, NOT TriggerZone. TriggerZone is one-shot (persists fired state in EventFlags) and unsuitable for doors that must be re-entered.

---

## GDScript API — exploration.gd

```gdscript
extends Node2D
## Exploration core state scene. Loads maps, manages player, wires entity signals.

signal map_changed(map_id: String)

## Currently loaded map ID.
var _current_map_id: String = ""

## Reference to the active map scene node.
var _current_map: Node2D = null

## Player character instance.
var _player: CharacterBody2D = null

## Whether a map transition is in progress (prevents double-trigger).
var _transitioning: bool = false

## Last location flash ID (prevents re-flash on same area).
var _last_flash_id: String = ""

@onready var _camera: Camera2D = $Camera2D
@onready var _map_container: Node2D = $CurrentMap
@onready var _location_flash: CanvasLayer = $LocationFlash
@onready var _location_label: Label = $LocationFlash/LocationLabel/NameLabel
```

### Public Methods

```gdscript
## Load a map by ID and place the player at spawn or a named position.
func load_map(map_id: String, spawn_name: String = "") -> void

## Flash a location name at center-top of screen.
func flash_location_name(location_name: String) -> void
```

### _ready() Initialization

Reads `GameManager.transition_data` to determine startup:
- `{"new_game": true}` → load starting map (e.g., "test_room"), initialize player as Edren
- `{"save_slot": N, "save_data": {...}}` → load map from save data's `current_location`, restore position

### Signal Wiring

When entities are placed in a map, exploration.gd connects their signals:

| Entity Signal | Exploration Handler | Action |
|--------------|-------------------|--------|
| `PlayerCharacter.interaction_requested(interactable)` | `_on_interaction_requested` | Call `interactable.interact()` |
| `NPC.npc_interacted(npc_id, dialogue_data)` | `_on_npc_interacted` | Push DIALOGUE overlay, pass `[dialogue_data]` (wrap single dict in array) |
| `TreasureChest.chest_opened(chest_id, item_id)` | `_on_chest_opened` | Show "Found [item]!" flash |
| `SavePoint.save_point_activated(save_point_id)` | `_on_save_point_activated` | Push SAVE_LOAD overlay |
| `TriggerZone.triggered(trigger_id)` | `_on_trigger_zone_triggered` | Check if transition trigger → load_map; else handle event |

### Map Transition Flow

1. Player enters a TriggerZone with `map_target` metadata
2. `_on_trigger_zone_triggered` checks metadata: if has `target_map`, start transition
3. Set `_transitioning = true` (block further triggers)
4. Fade to black (0.3s via Tween on a ColorRect overlay)
5. Unload current map, call `load_map(target_map, target_spawn)`
6. Fade in (0.3s)
7. Set `_transitioning = false`

### Camera2D Configuration

- Follows player position every frame
- `position_smoothing_enabled = false` (pixel-perfect, no interpolation)
- Snaps to pixel grid: `position = player.position.round()`
- No zoom (integer 1x only at 320x180)
- Stops at map edges via camera limits (set from TileMapLayer bounds)

### Location Name Flash

Per ui-design.md Section 15.2:
- Fade in 0.5s → hold 2s → fade out 0.5s
- Dark navy background with border (same StyleBoxFlat as other UI)
- White text, centered at top of screen
- Does not re-flash when re-entering same area without leaving

---

## Test Map

A minimal test map to verify the exploration scene works:

```
test_room (Node2D)
├── TileMapLayer                  — 20x11 grid of passable tiles + walls
├── Entities (Node2D)
│   ├── TestNPC (NPC instance)    — initialized with "bren" dialogue
│   ├── TestChest (TreasureChest) — initialized with test item
│   └── TestSavePoint (SavePoint) — initialized with "test_save"
├── Transitions (Node2D)
│   └── ExitTrigger (TriggerZone) — leads to test_room_2
└── PlayerSpawn (Marker2D)        — position (80, 90)
```

A second test room for map transitions:
```
test_room_2 (Node2D)
├── TileMapLayer
├── Transitions (Node2D)
│   └── ReturnTrigger (TriggerZone) — leads back to test_room
└── PlayerSpawn (Marker2D)
```

Both rooms use simple colored tile placeholder tilesets (16x16).

---

## Files

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/scripts/core/exploration.gd` | Exploration scene logic |
| Create | `game/scenes/core/exploration.tscn` | Exploration scene |
| Create | `game/scenes/maps/test_room.tscn` | Test map with entities |
| Create | `game/scenes/maps/test_room_2.tscn` | Second test map for transitions |
| Create | `game/assets/tilesets/tileset_test.png` | 16x16 placeholder tiles |
| Create | `game/tests/test_exploration.gd` | Integration tests |
| Modify | `docs/analysis/game-dev-gaps.md` | Update 3.2 status |

---

## Tests — test_exploration.gd (10 tests)

1. **test_exploration_scene_loads** — instantiate exploration.tscn
2. **test_load_map_creates_children** — load_map adds map as child of CurrentMap
3. **test_player_spawns_at_marker** — player position matches PlayerSpawn marker
4. **test_camera_follows_player** — camera position matches player position
5. **test_npc_interaction_pushes_dialogue** — interact with NPC triggers dialogue overlay
6. **test_chest_interaction_opens** — interact with chest emits chest_opened
7. **test_save_point_pushes_overlay** — interact with save point triggers save/load overlay
8. **test_map_transition_loads_new_map** — trigger zone with map_target loads new map
9. **test_transition_prevents_double** — _transitioning flag blocks concurrent transitions
10. **test_location_flash_displays** — flash_location_name shows and hides label

---

## Verification Checklist

- [ ] Exploration scene loads in Godot editor without errors
- [ ] Player moves with arrow keys, pixel-snapped
- [ ] Camera follows player, no sub-pixel jitter
- [ ] NPC interaction opens dialogue overlay with correct data
- [ ] Treasure chest interaction works (signal emits)
- [ ] Save point interaction opens save/load overlay
- [ ] Map transition fades to black, loads new map, fades in
- [ ] Double-trigger prevention works during transitions
- [ ] Location name flash appears and auto-hides
- [ ] New Game from title screen spawns player in starting map
- [ ] All code passes gdlint + gdformat
- [ ] Tests cover every signal wiring path
