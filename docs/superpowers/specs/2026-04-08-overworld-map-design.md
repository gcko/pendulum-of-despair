# Overworld Map — Design Spec (Vertical Slice)

> **Gap:** 4.3 (Overworld Map)
> **Goal:** Replace test_room with a walkable overworld connecting
> Valdris Crown and Ember Vein, completing the vertical slice loop.

---

## 1. Scope

### In Scope

- 1 overworld map: `overworld.tscn` (~60x40 tiles, top-down, placeholder tileset)
- 2 location entry triggers: Valdris Crown (NW) and Ember Vein (SE)
- Random encounters via existing `overworld.json` data (highland zone)
- Rewire valdris_lower_ward and ember_vein_f1 to point to overworld
- Change new_game default map from test_room to overworld
- Extend placeholder tileset with grass + water tiles (8 total)
- Spawn markers for bidirectional transitions
- Full test suite (integration + cross-reference)

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Mode 7 perspective rendering | Shader/camera work, visual polish | 4.8 or rendering pass |
| Miniaturized 8x12 player sprites | Needs sprite assets | 4.8 |
| Region boundary banners | Visual polish | 4.4 |
| Weather/atmospheric effects | Visual + audio polish | 3.8 + 4.8 |
| Menu parchment map | Separate UI system | 4.4 |
| Transport (Ley Stag, rail, ferry, Linewalk) | Act II content | 4.4 |
| Conditional passability (story-gated routes) | Needs more locations | 4.4 |
| Structural tilemap changes (fissures, crater) | Act progression | 4.4+ |
| Full continent tilemap (20+ locations) | Only 2 for slice | 4.4 |
| Locations beyond Valdris + Ember Vein | Not built yet | 4.4 |
| Ironmouth outpost intermediary scene | Could add later | 4.4 |
| 4-directional movement restriction on overworld | Minor behavior | 4.4 |
| HDMA-style horizon gradient per biome | Visual rendering | 4.8 |
| Per-biome atmospheric particles + palette tints | Visual rendering | 4.8 |
| 6 story-triggered atmospheric overrides | Act progression | 4.4+ |

### Tech Debt (track in beads)

1. **Mode 7 rendering** — Full overworld design spec calls for
   FF6-style Mode 7 perspective with curved horizon, HDMA gradient,
   and miniaturized sprites. Current vertical slice uses flat top-down.
   Requires shader + camera work in gap 4.8 or a dedicated rendering
   pass.
2. **test_room orphaned** — test_room.tscn is no longer in the main
   game flow. Keep as dev/debug scene but may need cleanup.
3. **Overworld tile count** — Vertical slice uses ~60x40 tiles. Full
   continent needs ~200x150+ tiles with 12 terrain types. Current
   placeholder tileset insufficient.

---

## 2. Tileset Extension

Extend `game/assets/tilesets/placeholder_dungeon.png` from 96x16
(6 tiles) to 128x16 (8 tiles):

- Tile 0: Dungeon floor — `#5C3A1E` (existing)
- Tile 1: Wall — `#2A2A2A` (existing)
- Tile 2: Crystal — `#D4820A` (existing)
- Tile 3: Stairs/door — `#8A8A8A` (existing)
- Tile 4: Building wall — `#666666` (existing)
- Tile 5: Town floor — `#C4A46E` (existing)
- Tile 6: Grass — `#3A7D2E` (NEW)
- Tile 7: Water — `#2244AA` (NEW, impassable)

Update `placeholder_dungeon.tres` to register tiles 6-7. Water tile
gets a physics collision body (impassable, like wall tile 1).

---

## 3. Overworld Map Layout

`game/scenes/maps/overworld.tscn` — 60x40 tiles (960x640 pixels)

```
Water/mountain borders around entire perimeter.

NW quadrant: Valdris Crown entry trigger
  - Area2D at ~(80, 80) targeting towns/valdris_lower_ward
  - Marker2D "from_valdris" nearby for spawning when arriving from town
  - Location name flash: "Valdris Crown"

Road runs diagonally from NW to SE through grass terrain.

SE quadrant: Ember Vein entry trigger
  - Area2D at ~(880, 560) targeting dungeons/ember_vein_f1
  - Marker2D "from_ember_vein" nearby
  - Location name flash: "Ember Vein Entrance"

Central area: Open grassland with encounter zone.

Map metadata:
  metadata/map_id = "overworld"
  metadata/dungeon_id = "overworld"
  metadata/floor_id = "highland"
  metadata/location_name = "Valdris Highlands"
```

Scene tree:
```
Node2D "Overworld"
  TileMapLayer (placeholder tileset, 60x40)
  Entities (Node2D)
    [empty for now — no NPCs/chests on overworld in vertical slice]
  Transitions (Node2D)
    ValdrisCrown (Area2D, target_map="towns/valdris_lower_ward",
      target_spawn="from_overworld")
    EmberVeinEntrance (Area2D, target_map="dungeons/ember_vein_f1",
      target_spawn="from_overworld")
  PlayerSpawn (Marker2D, center of map)
  from_valdris (Marker2D, near Valdris trigger)
  from_ember_vein (Marker2D, near Ember Vein trigger)
```

---

## 4. Rewire Existing Maps

### valdris_lower_ward.tscn
- SouthGate `target_map`: `"test_room"` → `"overworld"`
- SouthGate `target_spawn`: `"from_valdris"` → `"from_valdris"`
- Add `from_overworld` Marker2D (at same position as current PlayerSpawn)

### ember_vein_f1.tscn
- ExitToTestRoom `target_map`: `"test_room"` → `"overworld"`
- ExitToTestRoom `target_spawn`: `"from_ember_vein"` → `"from_ember_vein"`
- Rename `ExitToTestRoom` to `ExitToOverworld` for clarity
- Add `from_overworld` Marker2D

### exploration.gd (~2 lines)
- Change default new_game map from `"test_room"` to `"overworld"` in
  `_initialize_from_transition_data()`

### test_room.tscn
- Keep as-is. Remove transitions to Valdris and Ember Vein (they now
  go through overworld). Or leave them as debug shortcuts — either way,
  test_room is no longer in the main game flow.

---

## 5. Encounter Integration

The overworld encounter data exists at `game/data/encounters/overworld.json`
(created in gap 1.6). It has terrain zones with floor_ids.

The overworld map sets `metadata/floor_id = "highland"` which matches
the highland terrain zone in the encounter data. This gives the player
random encounters while walking between locations.

The encounter system in exploration.gd already handles this via
`load_map()` → `DataManager.load_encounters(dungeon_id)` →
match `floor_id` in the floors array.

---

## 6. Test Plan

### test_overworld.gd (NEW, ~100 lines)

**Scene existence and metadata:**
- `test_overworld_scene_exists` — file at res://scenes/maps/overworld.tscn exists
- `test_overworld_has_dungeon_id` — metadata/dungeon_id = "overworld"
- `test_overworld_has_floor_id` — metadata/floor_id = "highland"
- `test_overworld_has_location_name` — metadata/location_name present

**Encounter integration:**
- `test_overworld_encounter_data_exists` — DataManager.load_encounters("overworld") non-empty
- `test_highland_zone_has_groups` — floor_id "highland" entry has groups + danger_increment

**Transition wiring (parse .tscn files):**
- `test_overworld_has_valdris_transition` — Area2D with target_map containing "valdris"
- `test_overworld_has_ember_vein_transition` — Area2D with target_map containing "ember_vein"
- `test_overworld_spawn_markers_exist` — from_valdris and from_ember_vein Marker2Ds
- `test_valdris_south_gate_targets_overworld` — valdris_lower_ward SouthGate target_map = "overworld"
- `test_ember_vein_exit_targets_overworld` — ember_vein_f1 exit target_map = "overworld"

**Full loop validation:**
- `test_overworld_to_valdris_round_trip` — overworld targets valdris, valdris targets overworld
- `test_overworld_to_ember_vein_round_trip` — overworld targets ember_vein, ember_vein targets overworld

### test_cross_references.gd (EXPAND)
- Existing transition validation tests already cover overworld transitions
  if they scan all .tscn files in scenes/maps/

---

## 7. File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | MODIFY | Extend from 6 to 8 tiles |
| `game/assets/tilesets/placeholder_dungeon.tres` | MODIFY | Register tiles 6-7, water collision |
| `game/scenes/maps/overworld.tscn` | CREATE | Overworld map (60x40 tiles) |
| `game/scenes/maps/towns/valdris_lower_ward.tscn` | MODIFY | SouthGate → overworld |
| `game/scenes/maps/dungeons/ember_vein_f1.tscn` | MODIFY | Exit → overworld |
| `game/scripts/core/exploration.gd` | MODIFY | Default new_game map → overworld |
| `game/tests/test_overworld.gd` | CREATE | Integration + wiring tests |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.3 |
