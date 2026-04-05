# Gap 2.1: PlayerCharacter Prefab — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the first game entity — a CharacterBody2D scene with movement, data loading, interaction detection, and placeholder sprites.

**Architecture:** CharacterBody2D with Sprite2D, CollisionShape2D, Area2D (interaction), and AnimationPlayer. GDScript loads character stats from DataManager, handles 4-directional movement with pixel snapping, and emits interaction signals. All code must pass gdlint and have GUT tests.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.3.0 (testing), gdlint 4.5.0 (linting)

**Spec:** `docs/superpowers/specs/2026-04-05-player-character-prefab-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/scripts/entities/player_character.gd` | Movement, data loading, interaction |
| Create | `game/scenes/entities/player_character.tscn` | Scene tree with nodes |
| Create | `game/assets/sprites/characters/placeholder_edren.png` | Blue 16x24 placeholder |
| Create | `game/assets/sprites/characters/placeholder_cael.png` | Red 16x24 placeholder |
| Create | `game/assets/sprites/characters/placeholder_maren.png` | Purple 16x24 placeholder |
| Create | `game/assets/sprites/characters/placeholder_sable.png` | Grey 16x24 placeholder |
| Create | `game/assets/sprites/characters/placeholder_lira.png` | Orange 16x24 placeholder |
| Create | `game/assets/sprites/characters/placeholder_torren.png` | Green 16x24 placeholder |
| Create | `game/tests/test_player_character.gd` | Unit tests |
| Modify | `docs/analysis/game-dev-gaps.md` | Update gap 2.1 status |

---

## Chunk 1: GDScript + Placeholder Sprites

### Task 1: Create placeholder sprites

**Files:**
- Create: `game/assets/sprites/characters/placeholder_{edren,cael,maren,sable,lira,torren}.png`

**Agent instructions:** Generate 6 placeholder PNG images using Python. Each is 16x24 pixels — a solid colored rectangle with a 1px darker border.

```python
from PIL import Image, ImageDraw

sprites = {
    "edren":  ((0x44, 0x88, 0xCC), (0x22, 0x44, 0x66)),  # blue
    "cael":   ((0xCC, 0x44, 0x44), (0x66, 0x22, 0x22)),  # red
    "maren":  ((0x88, 0x44, 0xCC), (0x44, 0x22, 0x66)),  # purple
    "sable":  ((0x66, 0x66, 0x66), (0x33, 0x33, 0x33)),  # grey
    "lira":   ((0xCC, 0x88, 0x44), (0x66, 0x44, 0x22)),  # orange
    "torren": ((0x44, 0xCC, 0x66), (0x22, 0x66, 0x33)),  # green
}

for name, (fill, border) in sprites.items():
    img = Image.new("RGBA", (16, 24), fill)
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, 15, 23], outline=border)
    img.save(f"game/assets/sprites/characters/placeholder_{name}.png")
```

If Pillow is not installed, create them with pure Python using minimal PNG encoding, or create 16x24 solid color PNGs by any available method.

- [ ] **Step 1:** Create the `game/assets/sprites/characters/` directory
- [ ] **Step 2:** Generate all 6 placeholder PNGs
- [ ] **Step 3:** Verify each file exists and is 16x24 pixels

---

### Task 2: Create player_character.gd

**Files:**
- Create: `game/scripts/entities/player_character.gd`
- Read: `docs/superpowers/specs/2026-04-05-player-character-prefab-design.md`
- Read: `game/scripts/autoload/data_manager.gd` (understand load_character API)

**Agent instructions:** Write the full GDScript for the PlayerCharacter entity. Must pass `gdlint`.

```gdscript
extends CharacterBody2D
## Player character entity for exploration scenes.
##
## Handles 4-directional movement, character data loading,
## and interaction detection with nearby entities.
## Snap to pixel grid every frame. Respects global pause state.
##
## Usage: instance player_character.tscn, call initialize("edren").

## Emitted when the player presses interact and an interactable is nearby.
signal interaction_requested(interactable: Node2D)

## Movement speed in pixels per second.
const MOVE_SPEED: float = 80.0

## Character ID loaded from DataManager.
var character_id: String = ""

## Loaded character data dictionary.
var character_data: Dictionary = {}

## Current facing direction for animation selection.
var facing_direction: Vector2 = Vector2.DOWN

## Tracked interactable in proximity (set by Area2D signals).
var _nearest_interactable: Node2D = null

## Reference to child nodes (cached in _ready).
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


## Initialize the character with data from DataManager.
## Call after adding to the scene tree.
func initialize(p_character_id: String) -> void:
	character_id = p_character_id
	character_data = DataManager.load_character(character_id)
	if character_data.is_empty():
		if OS.is_debug_build():
			push_error("PlayerCharacter: Failed to load data for '%s'" % character_id)
		return
	_load_placeholder_sprite()


## Get the character's base stats dictionary.
func get_stats() -> Dictionary:
	return character_data.get("base_stats", {})


## Get the current facing direction as a unit vector.
func get_facing_direction() -> Vector2:
	return facing_direction


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = _get_input_direction()

	if direction != Vector2.ZERO:
		facing_direction = direction
		velocity = direction * MOVE_SPEED
		_play_walk_animation(direction)
	else:
		velocity = Vector2.ZERO
		_play_idle_animation()

	move_and_slide()
	# Snap to pixel grid — no sub-pixel positions.
	position = position.round()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _nearest_interactable != null:
		interaction_requested.emit(_nearest_interactable)
		get_viewport().set_input_as_handled()


## Read 4-directional input. No diagonal — vertical takes priority.
func _get_input_direction() -> Vector2:
	if Input.is_action_pressed("ui_up"):
		return Vector2.UP
	if Input.is_action_pressed("ui_down"):
		return Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		return Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		return Vector2.RIGHT
	return Vector2.ZERO


func _play_walk_animation(direction: Vector2) -> void:
	var anim_name: String = "idle"
	if direction == Vector2.UP:
		anim_name = "walk_north"
	elif direction == Vector2.DOWN:
		anim_name = "walk_south"
	elif direction == Vector2.LEFT:
		anim_name = "walk_west"
	elif direction == Vector2.RIGHT:
		anim_name = "walk_east"

	if _anim_player.current_animation != anim_name:
		_anim_player.play(anim_name)


func _play_idle_animation() -> void:
	if _anim_player.current_animation != "idle":
		_anim_player.play("idle")


func _load_placeholder_sprite() -> void:
	var sprite_path: String = "res://assets/sprites/characters/placeholder_%s.png" % character_id
	if ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path)
	elif OS.is_debug_build():
		push_error("PlayerCharacter: Placeholder sprite not found: %s" % sprite_path)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	_nearest_interactable = body


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if _nearest_interactable == body:
		_nearest_interactable = null
```

RULES:
- Must pass `gdlint game/scripts/entities/player_character.gd`
- All parameters and return types must have type hints
- No `class_name` (this is not an autoload, but keeping convention simple)
- `print()` gated behind `OS.is_debug_build()` — use `push_error()` instead
- Signal parameters typed
- `@onready` vars for child node references
- Private methods prefixed with `_`

- [ ] **Step 1:** Create `game/scripts/entities/` directory if needed
- [ ] **Step 2:** Write `player_character.gd` with all methods
- [ ] **Step 3:** Run `gdlint game/scripts/entities/player_character.gd` — must pass clean
- [ ] **Step 4:** Fix any lint issues

---

### Task 3: Create player_character.tscn

**Files:**
- Create: `game/scenes/entities/player_character.tscn`

**Agent instructions:** Create the .tscn scene file. Godot scene files are text-based resource format.

The scene must have:
- Root: CharacterBody2D named "PlayerCharacter"
- Child: Sprite2D (texture: placeholder_edren.png as default, centered)
- Child: CollisionShape2D with RectangleShape2D (half-extents 6x6 = 12x12 area)
- Child: Area2D named "InteractionArea"
  - Grandchild: CollisionShape2D with CircleShape2D (radius 12)
  - InteractionArea collision_layer = 0, collision_mask = 4 (layer 3)
  - Connect body_entered/body_exited signals to script methods
- Child: AnimationPlayer with stub animations (idle, walk_north/south/east/west)
- Script: res://scripts/entities/player_character.gd
- PlayerCharacter collision_layer = 2, collision_mask = 1

Write the .tscn file directly in Godot's text scene format. The format uses `[gd_scene]` header, `[ext_resource]` for external resources, `[sub_resource]` for inline resources, and `[node]` for the tree.

- [ ] **Step 1:** Create `game/scenes/entities/` directory if needed
- [ ] **Step 2:** Write `player_character.tscn` in Godot text scene format
- [ ] **Step 3:** Verify the file is valid Godot scene format (check syntax)

---

## Chunk 2: Tests + Verification

### Task 4: Write GUT tests

**Files:**
- Create: `game/tests/test_player_character.gd`

**Agent instructions:** Write unit tests using GUT framework.

```gdscript
extends GutTest
## Tests for PlayerCharacter entity.


func test_initialize_loads_character_data() -> void:
	# Verify initialize() populates character_data from DataManager
	var player: CharacterBody2D = preload(
		"res://scenes/entities/player_character.tscn"
	).instantiate()
	add_child_autofree(player)
	player.initialize("edren")
	assert_eq(player.character_id, "edren", "character_id should be set")
	assert_false(player.character_data.is_empty(), "character_data should be loaded")


func test_get_stats_returns_base_stats() -> void:
	var player: CharacterBody2D = preload(
		"res://scenes/entities/player_character.tscn"
	).instantiate()
	add_child_autofree(player)
	player.initialize("edren")
	var stats: Dictionary = player.get_stats()
	assert_has(stats, "hp", "stats should have hp")
	assert_has(stats, "atk", "stats should have atk")
	assert_typeof(stats.get("hp"), TYPE_INT, "hp should be int")


func test_default_facing_direction() -> void:
	var player: CharacterBody2D = preload(
		"res://scenes/entities/player_character.tscn"
	).instantiate()
	add_child_autofree(player)
	assert_eq(
		player.facing_direction, Vector2.DOWN,
		"Default facing should be DOWN"
	)


func test_pixel_snapping() -> void:
	var player: CharacterBody2D = preload(
		"res://scenes/entities/player_character.tscn"
	).instantiate()
	add_child_autofree(player)
	player.position = Vector2(10.5, 20.7)
	# Simulate one physics frame
	player._physics_process(0.016)
	assert_eq(
		player.position, Vector2(11, 21),
		"Position should snap to nearest integer"
	)
```

RULES:
- Extend `GutTest` (GUT's base test class)
- Use `add_child_autofree()` to auto-cleanup instantiated scenes
- Use `preload()` for the scene
- All test methods start with `test_`
- Must pass `gdlint`

- [ ] **Step 1:** Write `test_player_character.gd`
- [ ] **Step 2:** Run `gdlint game/tests/test_player_character.gd` — must pass

---

### Task 5: Update gap tracker and commit

- [ ] **Step 1:** Update gap 2.1 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Check off all "What's Needed" items
- [ ] **Step 3:** Note downstream gaps unblocked:
  - 2.1 unblocks: 3.2 (Exploration Scene), 3.3 (Battle Scene — needs player display)
- [ ] **Step 4:** Run `gdlint` on ALL new .gd files:
  ```bash
  gdlint game/scripts/entities/player_character.gd game/tests/test_player_character.gd
  ```
- [ ] **Step 5:** Stage and commit:
  ```bash
  git add game/scenes/entities/ game/scripts/entities/ game/assets/sprites/characters/ game/tests/test_player_character.gd docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-05-player-character-prefab-design.md docs/superpowers/plans/2026-04-05-player-character-prefab.md
  git commit -m "feat(engine): add PlayerCharacter prefab with movement and interaction (gap 2.1)"
  ```
- [ ] **Step 6:** Push and hand off to `/create-pr` → `/godot-review-loop`
