# Overworld Map Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a walkable overworld map connecting Valdris Crown and Ember Vein, replacing test_room as the game hub and completing the vertical slice loop.

**Architecture:** A single `overworld.tscn` map scene loaded by the existing `exploration.gd` system. Same TileMapLayer + Transitions + Entities pattern as dungeon/town maps. Encounter data from existing `overworld.json`. Tileset extended with 2 new overworld tiles (grass, water).

**Tech Stack:** Godot 4.6, GDScript, TileMapLayer, existing exploration.gd

**Spec:** `docs/superpowers/specs/2026-04-08-overworld-map-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | MODIFY | Extend from 6 to 8 tiles (grass, water) |
| `game/assets/tilesets/placeholder_dungeon.tres` | MODIFY | Register tiles 6-7, water collision |
| `game/scenes/maps/overworld.tscn` | CREATE | Overworld map (60x40 tiles) |
| `game/scenes/maps/towns/valdris_lower_ward.tscn` | MODIFY | SouthGate → overworld |
| `game/scenes/maps/dungeons/ember_vein_f1.tscn` | MODIFY | Exit → overworld |
| `game/scripts/core/exploration.gd` | MODIFY | Default map test_room → overworld |
| `game/tests/test_overworld.gd` | CREATE | Integration + wiring tests |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.3 |

---

## Chunk 1: Tileset + Overworld Scene

### Task 1: Extend tileset with overworld tiles

**Files:**
- Modify: `game/assets/tilesets/placeholder_dungeon.png` (currently 96x16, 6 tiles)
- Modify: `game/assets/tilesets/placeholder_dungeon.tres`

- [ ] **Step 1: Extend tileset image from 6 to 8 tiles**

Add 2 new 16x16 tiles to the right of the existing 96x16 strip,
making it 128x16:
- Tile 6 (px 96-111): Grass `#3A7D2E` — rgb(58, 125, 46)
- Tile 7 (px 112-127): Water `#2244AA` — rgb(34, 68, 170)

Use ImageMagick (Pillow may not be available):
```bash
convert game/assets/tilesets/placeholder_dungeon.png \
  \( -size 16x16 xc:'#3A7D2E' \) \
  \( -size 16x16 xc:'#2244AA' \) \
  +append game/assets/tilesets/placeholder_dungeon.png
```

Or Python with Pillow:
```bash
python3 -c "
from PIL import Image
img = Image.open('game/assets/tilesets/placeholder_dungeon.png')
new_img = Image.new('RGBA', (128, 16))
new_img.paste(img, (0, 0))
colors = [(58,125,46,255), (34,68,170,255)]
for t, c in enumerate(colors):
    for y in range(16):
        for x in range(16):
            new_img.putpixel((96 + t*16 + x, y), c)
new_img.save('game/assets/tilesets/placeholder_dungeon.png')
"
```

- [ ] **Step 2: Verify image dimensions**

```bash
file game/assets/tilesets/placeholder_dungeon.png
# Expected: PNG image data, 128 x 16
```

- [ ] **Step 3: Update .tres to register tiles 6-7**

Read `placeholder_dungeon.tres`. Add tile_data entries for tiles
6:0 and 7:0 in the atlas. Tile 7 (water) needs a physics collision
body (same pattern as tile 1 wall).

- [ ] **Step 4: Commit**

```bash
git add game/assets/tilesets/placeholder_dungeon.png game/assets/tilesets/placeholder_dungeon.tres
git commit -m "feat(assets): extend placeholder tileset with overworld tiles (grass, water)"
```

### Task 2: Create overworld map scene

**Files:**
- Create: `game/scenes/maps/overworld.tscn`

Write the .tscn as a Godot text scene file. 60x40 tiles (960x640 px).

- [ ] **Step 1: Design the layout**

```
Perimeter: water tiles (tile 7) — impassable border
Interior: grass tiles (tile 6) — walkable terrain
Road: town floor tiles (tile 5) running NW to SE — walkable path
NW corner (~tile 5,5): Valdris Crown entry area
SE corner (~tile 55,35): Ember Vein entry area
Scatter some wall tiles (tile 1) as mountain decoration along edges
```

- [ ] **Step 2: Write the .tscn file**

Scene tree:
```
Node2D "Overworld"
  metadata/map_id = "overworld"
  metadata/dungeon_id = "overworld"
  metadata/floor_id = "valdris_highlands"
  metadata/location_name = "Valdris Highlands"

  TileMapLayer (placeholder_dungeon.tres)
    - Water perimeter (tile 7:0)
    - Grass fill (tile 6:0)
    - Road from NW to SE (tile 5:0)
    - Mountain accents along N and E edges (tile 1:0)

  Entities (Node2D)
    [empty — no NPCs/chests on overworld for vertical slice]

  Transitions (Node2D)
    ValdrisCrown (Area2D)
      position = Vector2(80, 80)
      collision_layer = 0, collision_mask = 2
      monitoring = true, monitorable = false
      metadata/target_map = "towns/valdris_lower_ward"
      metadata/target_spawn = "from_overworld"
      CollisionShape2D (RectangleShape2D size 48x48)

    EmberVeinEntrance (Area2D)
      position = Vector2(880, 560)
      collision_layer = 0, collision_mask = 2
      monitoring = true, monitorable = false
      metadata/target_map = "dungeons/ember_vein_f1"
      metadata/target_spawn = "from_overworld"
      CollisionShape2D (RectangleShape2D size 48x48)

  PlayerSpawn (Marker2D) position = Vector2(480, 320)
  from_valdris (Marker2D) position = Vector2(112, 112)
  from_ember_vein (Marker2D) position = Vector2(848, 528)
```

All positions integer, within 960x640 bounds. Transition triggers
use larger collision shapes (48x48) since the overworld is spacious.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/overworld.tscn
git commit -m "feat(engine): add overworld map connecting Valdris Crown and Ember Vein"
```

---

## Chunk 2: Rewire Transitions + Change Default Map

### Task 3: Rewire valdris_lower_ward to overworld

**Files:**
- Modify: `game/scenes/maps/towns/valdris_lower_ward.tscn`

- [ ] **Step 1: Change SouthGate target**

Find the SouthGate Area2D in the Transitions node (currently
targets `test_room`). Change:
- `metadata/target_map = "test_room"` → `"overworld"`
- `metadata/target_spawn = "from_valdris"` stays the same

- [ ] **Step 2: Add from_overworld spawn marker**

Add a Marker2D named `from_overworld` at the same position as
`PlayerSpawn` (or near the south gate entry):
```
[node name="from_overworld" type="Marker2D" parent="."]
position = Vector2(80, 528)
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/towns/valdris_lower_ward.tscn
git commit -m "feat(engine): rewire Valdris Lower Ward south gate to overworld"
```

### Task 4: Rewire ember_vein_f1 to overworld

**Files:**
- Modify: `game/scenes/maps/dungeons/ember_vein_f1.tscn`

- [ ] **Step 1: Change exit transition target**

Find the `ExitToTestRoom` Area2D in the Transitions node.
- Rename node from `ExitToTestRoom` to `ExitToOverworld`
- Change `metadata/target_map = "test_room"` → `"overworld"`
- Change `metadata/target_spawn = "from_ember_vein"` → `"from_ember_vein"`

- [ ] **Step 2: Add from_overworld spawn marker**

Add a Marker2D named `from_overworld` at the same position as
`PlayerSpawn`:
```
[node name="from_overworld" type="Marker2D" parent="."]
position = Vector2(48, 48)
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f1.tscn
git commit -m "feat(engine): rewire Ember Vein F1 exit to overworld"
```

### Task 5: Change default new_game map to overworld

**Files:**
- Modify: `game/scripts/core/exploration.gd` (400 lines)

- [ ] **Step 1: Replace test_room references with overworld**

In `_initialize_from_transition_data()`:
- Line 184: `load_map("test_room")` → `load_map("overworld")`
- Line 189: `world.get("current_location", "test_room")` → `world.get("current_location", "overworld")`
- Line 190: `load_map(location if location != "" else "test_room")` → `load_map(location if location != "" else "overworld")`

Also check line 213 (the else fallback):
```gdscript
else:
    load_map("overworld")
```

- [ ] **Step 2: Run gdlint + gdformat, verify still 400 lines**

No line count change — just string replacements.

- [ ] **Step 3: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): change default new_game map from test_room to overworld"
```

---

## Chunk 3: Tests + Gap Tracker

### Task 6: Write overworld integration tests

**Files:**
- Create: `game/tests/test_overworld.gd`

- [ ] **Step 1: Write the test file**

```gdscript
extends GutTest
## Integration tests for the overworld map and its transition wiring.


func before_each() -> void:
    DataManager.clear_cache()


# --- Scene existence ---


func test_overworld_scene_exists() -> void:
    assert_true(
        FileAccess.file_exists("res://scenes/maps/overworld.tscn"),
        "Overworld scene file should exist"
    )


# --- Encounter integration ---


func test_overworld_encounter_data_exists() -> void:
    var data: Dictionary = DataManager.load_encounters("overworld")
    assert_false(data.is_empty(), "Overworld encounter data should exist")


func test_highland_zone_has_groups() -> void:
    var data: Dictionary = DataManager.load_encounters("overworld")
    var floors: Array = data.get("floors", data.get("zones", []))
    var found: bool = false
    for entry: Variant in floors:
        if entry is Dictionary and (entry as Dictionary).get("floor_id", "") == "valdris_highlands":
            found = true
            var groups: Array = (entry as Dictionary).get("groups", [])
            assert_gt(groups.size(), 0, "Highland zone should have encounter groups")
            var di: int = (entry as Dictionary).get("danger_increment", 0)
            assert_gt(di, 0, "Highland zone should have positive danger increment")
            break
    assert_true(found, "Should find valdris_highlands floor entry")


# --- Transition wiring (parse .tscn text) ---


func test_overworld_has_valdris_transition() -> void:
    var text: String = _read_scene("res://scenes/maps/overworld.tscn")
    assert_true(
        text.contains("towns/valdris_lower_ward"),
        "Overworld should have transition to Valdris"
    )


func test_overworld_has_ember_vein_transition() -> void:
    var text: String = _read_scene("res://scenes/maps/overworld.tscn")
    assert_true(
        text.contains("dungeons/ember_vein_f1"),
        "Overworld should have transition to Ember Vein"
    )


func test_overworld_spawn_markers_exist() -> void:
    var text: String = _read_scene("res://scenes/maps/overworld.tscn")
    assert_true(text.contains("from_valdris"), "Should have from_valdris marker")
    assert_true(text.contains("from_ember_vein"), "Should have from_ember_vein marker")


func test_valdris_south_gate_targets_overworld() -> void:
    var text: String = _read_scene("res://scenes/maps/towns/valdris_lower_ward.tscn")
    # SouthGate should target overworld, not test_room
    assert_true(
        text.contains('target_map = "overworld"'),
        "Valdris SouthGate should target overworld"
    )
    assert_false(
        text.contains('target_map = "test_room"'),
        "Valdris should NOT target test_room anymore"
    )


func test_ember_vein_exit_targets_overworld() -> void:
    var text: String = _read_scene("res://scenes/maps/dungeons/ember_vein_f1.tscn")
    assert_true(
        text.contains('target_map = "overworld"'),
        "Ember Vein exit should target overworld"
    )


func test_overworld_to_valdris_round_trip() -> void:
    var ow: String = _read_scene("res://scenes/maps/overworld.tscn")
    var vl: String = _read_scene("res://scenes/maps/towns/valdris_lower_ward.tscn")
    # Overworld -> Valdris
    assert_true(ow.contains("towns/valdris_lower_ward"), "OW targets Valdris")
    # Valdris -> Overworld
    assert_true(vl.contains('"overworld"'), "Valdris targets overworld")
    # Spawn markers
    assert_true(ow.contains("from_valdris"), "OW has from_valdris spawn")
    assert_true(vl.contains("from_overworld"), "Valdris has from_overworld spawn")


func test_overworld_to_ember_vein_round_trip() -> void:
    var ow: String = _read_scene("res://scenes/maps/overworld.tscn")
    var ev: String = _read_scene("res://scenes/maps/dungeons/ember_vein_f1.tscn")
    assert_true(ow.contains("dungeons/ember_vein_f1"), "OW targets Ember Vein")
    assert_true(ev.contains('"overworld"'), "Ember Vein targets overworld")
    assert_true(ow.contains("from_ember_vein"), "OW has from_ember_vein spawn")
    assert_true(ev.contains("from_overworld"), "Ember Vein has from_overworld spawn")


func test_exploration_defaults_to_overworld() -> void:
    var text: String = _read_scene("res://scripts/core/exploration.gd")
    assert_false(
        text.contains('load_map("test_room")'),
        "exploration.gd should not default to test_room"
    )
    assert_true(
        text.contains('load_map("overworld")'),
        "exploration.gd should default to overworld"
    )


# --- Helper ---


func _read_scene(path: String) -> String:
    if not FileAccess.file_exists(path):
        return ""
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return ""
    var text: String = file.get_as_text()
    file.close()
    return text
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_overworld.gd
git commit -m "test(engine): add overworld integration tests — transitions, encounters, round trips"
```

### Task 7: Verify and update gap tracker

- [ ] **Step 1: Run all tests**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ -s addons/gut/gut_cmdln.gd
```

All tests must pass (355 existing + ~12 new = ~367).

- [ ] **Step 2: Update gap 4.3**

Mark as MOSTLY COMPLETE. Note what's done and what remains (Mode 7,
full continent, transport, etc.).

- [ ] **Step 3: Commit and push**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap 4.3 — Overworld Map MOSTLY COMPLETE"
git push
```

**Next steps:**
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening
3. Address Copilot comments + gap analysis (autonomous)
