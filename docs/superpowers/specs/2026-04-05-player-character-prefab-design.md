# Gap 2.1: PlayerCharacter Prefab — Design Spec

> **Date:** 2026-04-05
> **Gap:** 2.1 (PlayerCharacter Prefab)
> **Status:** Approved
> **Source docs:** visual-style.md Section 1.3 (sprite specs), characters.md (default rows, weapon types), overworld.md Section 3.1 (movement), technical-architecture.md Section 4.2 (scene tree)
> **Architecture ref:** technical-architecture.md Section 4.2

## Problem

The game needs a player character entity that can move on maps, load character data from JSON, display a sprite, and interact with NPCs/chests/save points. This is the first .tscn scene + GDScript in the project — it establishes patterns for all future entities.

## Scope

- 1 scene file: `game/scenes/entities/player_character.tscn`
- 1 script file: `game/scripts/entities/player_character.gd`
- 6 placeholder sprite files (16x24 colored rectangles)
- 1 test file: `game/tests/test_player_character.gd`

**Excluded:**
- Party formation/following (multiple characters on screen) → future gap
- Battle sprites (32x32) → gap 3.3
- Overworld miniature sprites (8x12) → gap 4.3
- Equipment visual changes → future gap

---

## Scene Tree

```
PlayerCharacter (CharacterBody2D)
├── Sprite2D                    — 16x24 placeholder sprite
├── CollisionShape2D            — 12x12 RectangleShape2D (movement)
├── InteractionArea (Area2D)
│   └── CollisionShape2D        — 24x24 circle (interaction proximity)
├── AnimationPlayer             — walk + idle animations
└── player_character.gd
```

### Node Configuration

| Node | Property | Value | Notes |
|------|----------|-------|-------|
| PlayerCharacter | process_mode | INHERIT | Pauses when GameManager sets tree paused |
| Sprite2D | texture | placeholder PNG | 16x24 colored rectangle |
| Sprite2D | centered | true | Centered on CharacterBody2D origin |
| CollisionShape2D | shape | RectangleShape2D(6, 6) | Half-extents 6x6 = 12x12 total. Smaller than tile for smooth navigation |
| InteractionArea | collision_layer | 0 | Doesn't collide with anything |
| InteractionArea | collision_mask | 4 | Detects layer 3 (interactables) |
| InteractionArea/CollisionShape2D | shape | CircleShape2D(12) | 24px diameter interaction radius |

### Collision Layers

| Layer | Purpose | Used By |
|-------|---------|---------|
| 1 | World collision (walls, obstacles) | PlayerCharacter collision_mask |
| 2 | Character bodies | PlayerCharacter collision_layer |
| 3 | Interactables (NPC, chest, save point) | InteractionArea collision_mask |

---

## GDScript API

### Properties

```gdscript
## Movement speed in pixels per second.
const MOVE_SPEED: float = 80.0

## Character ID loaded from DataManager.
var character_id: String = ""

## Loaded character data dictionary.
var character_data: Dictionary = {}

## Current facing direction (for animation).
var facing_direction: Vector2 = Vector2.DOWN

## Last interactable that entered the Area2D (not necessarily nearest).
var _current_interactable: Node2D = null
```

### Signals

```gdscript
## Emitted when the player presses interact and an interactable is nearby.
signal interaction_requested(interactable: Node2D)
```

### Public Methods

```gdscript
## Initialize the character with data from DataManager.
## Call after adding to scene tree.
func initialize(p_character_id: String) -> void

## Get the character's current base stats (for display/debug).
func get_stats() -> Dictionary

## Get the character's facing direction as a unit vector.
func get_facing_direction() -> Vector2
```

### Movement Logic (_physics_process)

```
1. If tree is paused → skip (handled by PROCESS_MODE_INHERIT)
2. Read input: ui_up, ui_down, ui_left, ui_right
3. Build direction vector (4-directional only — prioritize vertical if both pressed)
4. If direction != Vector2.ZERO:
   a. Update facing_direction
   b. Set velocity = direction * MOVE_SPEED
   c. Play walk animation matching direction
5. Else:
   a. Set velocity = Vector2.ZERO
   b. Play idle animation
6. Call move_and_slide()
7. Snap position: position = position.round()
```

### Interaction Logic

```
InteractionArea body_entered → store reference as _current_interactable
InteractionArea body_exited  → clear _current_interactable if it matches

On interact input (ui_accept):
  if _current_interactable != null:
    emit signal interaction_requested(_current_interactable)
```

---

## Placeholder Sprites

6 PNG files, each 16x24 pixels, solid color with 1px darker border:

| Character | Color (hex) | File |
|-----------|------------|------|
| Edren | #4488CC (blue) | `placeholder_edren.png` |
| Cael | #CC4444 (red) | `placeholder_cael.png` |
| Maren | #8844CC (purple) | `placeholder_maren.png` |
| Sable | #666666 (dark grey) | `placeholder_sable.png` |
| Lira | #CC8844 (orange) | `placeholder_lira.png` |
| Torren | #44CC66 (green) | `placeholder_torren.png` |

Location: `game/assets/sprites/characters/`

For the prototype, the Sprite2D loads the placeholder PNG matching the character_id. No animation frames yet — AnimationPlayer animations will reference sprite frame indices when real sprites are created.

### AnimationPlayer Setup (Placeholder)

With single-frame placeholder sprites, animations are stubs:
- `idle` — 1 frame, loops
- `walk_north`, `walk_south`, `walk_east`, `walk_west` — 1 frame each, loops

These stubs ensure the animation system is wired correctly. When real 4-frame walk cycle sprites are added, only the animation tracks need updating — no code changes.

---

## Input Actions

The scene uses Godot's built-in input actions:
- `ui_up`, `ui_down`, `ui_left`, `ui_right` — movement
- `ui_accept` — interaction

These are pre-defined in Godot and map to arrow keys + gamepad by default. No custom input map needed for the prototype.

---

## Tests

`game/tests/test_player_character.gd`:

1. **test_initialize_loads_data** — Call `initialize("edren")`, verify `character_data` is populated and `character_id == "edren"`
2. **test_get_stats_returns_base_stats** — After initialize, verify `get_stats()` returns the base_stats dictionary
3. **test_facing_direction_default** — Default facing should be `Vector2.DOWN`
4. **test_pixel_snapping** — Set position to (10.5, 20.7), call `_physics_process(0)`, verify position is rounded to integers

---

## Verification Checklist

- [ ] Scene loads in Godot editor without errors
- [ ] CharacterBody2D scene tree matches spec
- [ ] Sprite2D displays 16x24 placeholder at correct size
- [ ] CollisionShape2D is 12x12 (half-extents 6x6)
- [ ] InteractionArea detects layer 3
- [ ] GDScript loads character data from DataManager
- [ ] 4-directional movement works (no diagonal)
- [ ] Position snaps to integer pixels
- [ ] Interaction signal emits when ui_accept pressed with nearby interactable
- [ ] Process mode INHERIT — stops when tree paused
- [ ] All code passes gdlint
- [ ] Tests pass
