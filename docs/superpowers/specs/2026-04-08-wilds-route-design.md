# Wilds Route — Design Spec (Gap 4.4 Phase A)

> **Gap:** 4.4 Phase A (Remaining Act I Content — Wilds Route)
> **Goal:** Add Roothollow village and Maren's Refuge to the game,
> connected via overworld transitions. Implement Scenes 5-6 (Torren
> and Maren join the party) using dialogue overlay. Player can travel
> the full Act I Wilds route: Overworld → Roothollow → Overworld →
> Maren's Refuge → Overworld → Valdris.

---

## 1. Scope

### In Scope

- 2 new map scenes: Roothollow village, Maren's Refuge cottage
- Overworld expansion: 2 new transition triggers + spawn markers
- 1 new shop: Roothollow Herbalist (Act I consumables)
- Story Scenes 5-6 via dialogue trigger zones (not cutscene system)
- Party assembly: Torren joins (Scene 5), Maren joins (Scene 6)
- PartyState.add_member() public API
- Thornmere Wilds overworld encounter zone
- Tileset extension: 2 forest tiles (10 total)
- Full integration test suite
- Gap tracker update with explicit remaining work

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Fenmother's Hollow dungeon | Separate dungeon, different biome | 4.4 Phase A2 |
| Deeproot Shrine / Brenn | Optional side content | 4.4 Phase C or 4.5 |
| Cutscene system (3.7) | Dialogue overlay stubs sufficient | Gap 3.7 |
| Scene 5a walk sequence | Needs cutscene camera control | Gap 3.7 |
| Audio/music for Wilds | Needs audio system | Gap 3.8 |
| Ironmouth / Scenes 1-4 | Phase B content | 4.4 Phase B |
| Scene 7 / Valdris completion | Phase C content | 4.4 Phase C |
| Fiara optional NPC | Optional content | 4.5 |
| Party member join animations | Needs cutscene system | Gap 3.7 |
| Thornmere Craftsman shop | Act II availability per economy.md | 4.5 |

### Tech Debt

1. **Dialogue-driven party assembly** — Scenes 5/6 use dialogue
   trigger zones that set flags. Party joining happens via flag
   check in exploration.gd after dialogue closes. This is a
   workaround until cutscene system (3.7) exists.
2. **Overworld scale** — Vertical slice overworld is 60x40 tiles.
   Adding 4 locations (Valdris, Ember Vein, Roothollow, Maren's
   Refuge) to a single small map is cramped. Full continent needs
   200x150+ tiles with proper terrain zones.
3. **Shop NPC separation** — economy.md lists Thornmere Provisioner
   and Craftsman as separate shops. Only Provisioner/Herbalist
   implemented now (Act I). Craftsman has Act II items.

---

## 2. Tileset Extension

Extend `game/assets/tilesets/placeholder_dungeon.png` from 128x16
(8 tiles) to 160x16 (10 tiles):

- Tile 8: Forest floor — `#5A6B3F` (root-matted earth)
- Tile 9: Bioluminescent — `#4A9FBF` (spirit moss, decorative)

Update `placeholder_dungeon.tres` to register tiles 8-9. Both are
walkable (no physics collision). Bioluminescent tile is decorative
accent for Roothollow.

---

## 3. Roothollow Map

`game/scenes/maps/towns/roothollow.tscn` — 30x25 tiles (480x400 px)

```
Root-chamber settlement. Walls are forest floor (tile 8) with wall
(tile 1) borders. Bioluminescent accent tiles (tile 9) along paths.
Town floor (tile 5) for walkable interior areas.

NW area: Entrance from overworld
  - Dialogue trigger zone for Scene 5 (first visit only)
  - Flag-gated: fires only when !torren_joined

Central chamber: Vessa NPC
  - Vessa: flag-gated dialogue (npc_vessa in dialogue data)
  - Torren joins via Scene5Trigger dialogue (not a placed NPC entity)

East alcove: Herbalist shop NPC
  - shop_id: "roothollow_herbalist"

South area: Save point + Heartwood shrine

Exit: Transition back to overworld (from_roothollow marker)
```

Scene tree:
```
Node2D "Roothollow"
  metadata/map_id = "towns/roothollow"
  metadata/dungeon_id = ""
  metadata/floor_id = ""
  metadata/location_name = "Roothollow"

  TileMapLayer (placeholder_dungeon.tres, 30x25)
  Entities (Node2D)
    Vessa (NPC, npc_id="vessa")
    Herbalist (NPC, npc_id="roothollow_herbalist", shop_id="roothollow_herbalist")
  Transitions (Node2D)
    ExitToOverworld (Area2D, target_map="overworld", target_spawn="from_roothollow")
  Scene5Trigger (Area2D, dialogue_data=[...], flag="torren_joined")
  SavePoint (save_point_id="roothollow_shrine")
  PlayerSpawn (Marker2D)
  from_overworld (Marker2D)
```

### NPCs

**Vessa** — Spirit-speaker elder. Uses existing `npc_vessa` dialogue
data (ambient NPC dialogue). Flag-gated: different lines before/after
`torren_joined`.

**Herbalist** — Shop NPC. `shop_id = "roothollow_herbalist"`.
Standard shop interaction via exploration.gd `_on_npc_interacted`.

### Scene 5 Integration

Scene 5 (Torren encounter + Vessa's Warning) fires via a dialogue
trigger zone at the Roothollow entrance:
- Area2D with `metadata/dialogue_data` pointing to `torren_encounter`
- `metadata/flag = "torren_joined"`
- On body_entered (player), push dialogue overlay with the scene data
- On dialogue completion, flag is set → exploration.gd checks flag
  and calls `PartyState.add_member("torren", 1)`

The trigger zone is one-shot (flag-gated). Subsequent visits skip it.

---

## 4. Maren's Refuge Map

`game/scenes/maps/towns/marens_refuge.tscn` — 16x14 tiles (256x224 px)

```
Small stone cottage interior. Similar size to Anchor & Oar.
Walls: wall tile (1). Floor: town floor (5).
Bookshelves and ley crystals as decoration (crystal tile 2).

Entrance: South side, from overworld
  - Dialogue trigger zone for Scene 6 (first visit only)
  - Flag-gated: fires only when torren_joined AND !maren_warning

Interior: Maren NPC at desk (north center)
  - Maren: flag-gated dialogue (ambient after scene 6)

No shop, no encounters, no save point.
Exit: Transition back to overworld (from_marens_refuge marker)
```

Scene tree:
```
Node2D "MarensRefuge"
  metadata/map_id = "towns/marens_refuge"
  metadata/dungeon_id = ""
  metadata/floor_id = ""
  metadata/location_name = "Maren's Refuge"

  TileMapLayer (placeholder_dungeon.tres, 16x14)
  Entities (Node2D)
    Maren (NPC, npc_id="maren_refuge")
  Transitions (Node2D)
    ExitToOverworld (Area2D, target_map="overworld", target_spawn="from_marens_refuge")
  Scene6Trigger (Area2D, dialogue_data=[...], flag="maren_warning")
  PlayerSpawn (Marker2D)
  from_overworld (Marker2D)
```

### Scene 6 Integration

Scene 6 (Maren's Warning) fires via dialogue trigger zone:
- Condition: `torren_joined` must be set AND `maren_warning` not set
- On dialogue completion, flag `maren_warning` set
- exploration.gd checks flag and calls `PartyState.add_member("maren", 1)`

---

## 5. Overworld Expansion

Modify `game/scenes/maps/overworld.tscn` to add:

### New Transitions
- **Roothollow** (Area2D) at ~(480, 480) — south-central area
  - `target_map = "towns/roothollow"`
  - `target_spawn = "from_overworld"`
  - CollisionShape2D (48x48)

- **MarensRefuge** (Area2D) at ~(200, 500) — SW area
  - `target_map = "towns/marens_refuge"`
  - `target_spawn = "from_overworld"`
  - CollisionShape2D (48x48)

### New Spawn Markers
- `from_roothollow` (Marker2D) at ~(448, 448)
- `from_marens_refuge` (Marker2D) at ~(232, 468)

### Encounter Zone

Add a `thornmere_wilds` zone to `game/data/encounters/overworld.json`
with Act I forest enemies. The overworld map metadata already uses
`floor_id = "valdris_highlands"`. For the Wilds zone, we could add
a second TileMapLayer region, but for the vertical slice the single
`valdris_highlands` zone covers the whole overworld. The `thornmere_wilds`
zone data exists for future use when the overworld is expanded.

Add to overworld.json zones array:
```json
{
  "zone_id": "thornmere_wilds",
  "terrain_type": "low_visibility",
  "danger_tier": 2,
  "danger_increment": 160,
  "format": "standard",
  "formation_rates": {
    "normal": 75,
    "back_attack": 15,
    "preemptive": 10
  },
  "groups": [
    {
      "format": 1,
      "enemies": ["marsh_serpent", "marsh_serpent"],
      "weight": 31.25
    },
    {
      "format": 2,
      "enemies": ["marsh_serpent", "drowned_bones"],
      "weight": 31.25
    },
    {
      "format": 3,
      "enemies": ["drowned_bones", "drowned_bones"],
      "weight": 31.25
    },
    {
      "format": 4,
      "enemies": ["marsh_serpent", "marsh_serpent", "drowned_bones"],
      "weight": 6.25
    }
  ]
}
```

---

## 6. Shop Data

### roothollow_herbalist.json (NEW)

Create `game/data/shops/roothollow_herbalist.json` based on economy.md
Thornmere Provisioner inventory, with `available_act: 1`:

```json
{
  "shop": {
    "shop_id": "roothollow_herbalist",
    "town": "roothollow",
    "type": "provisioner",
    "markup": 1.0,
    "inventory": [
      { "item_id": "potion", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "hi_potion", "buy_price": 300, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "ether", "buy_price": 200, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "antidote", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "alarm_clock", "buy_price": 75, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "echo_drop", "buy_price": 75, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "eye_drops", "buy_price": 50, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "smelling_salts", "buy_price": 75, "available_act": 1, "stock_limit": null, "restock_event": null },
      { "item_id": "tent", "buy_price": 500, "available_act": 1, "stock_limit": null, "restock_event": null }
    ]
  }
}
```

Note: Wyrmbone Lance, Warding Crown, and Despair Ward are Craftsman
shop items (Act II availability per economy.md, thornmere_craftsman.json).

---

## 7. PartyState.add_member()

Expose a public method on PartyState:

```gdscript
func add_member(character_id: String, level: int = 1) -> void:
    # Guard: don't add duplicates
    for m: Dictionary in members:
        if m.get("character_id", "") == character_id:
            return
    _add_character(character_id, level)
    # Add to reserve by default (active party may be full at 4)
    if formation.get("active", []).size() < 4:
        formation["active"].append(members.size() - 1)
    else:
        formation["reserve"].append(members.size() - 1)
    # Set default row from character data
    var char_data: Dictionary = DataManager.load_character(character_id)
    var default_row: String = char_data.get("default_row", "back")
    formation["rows"][character_id] = default_row
```

This is called by exploration.gd when party-joining flags are set.

---

## 8. Exploration Integration

After dialogue overlay closes and a party-joining flag is set,
exploration.gd needs to check and add the new member. Add to
`_on_dialogue_trigger_entered` or create a post-dialogue callback:

```gdscript
# In exploration.gd, after dialogue flag is set:
func _check_party_joining_flags() -> void:
    if EventFlags.get_flag("torren_joined") and not _has_member("torren"):
        PartyState.add_member("torren", _get_party_avg_level())
    if EventFlags.get_flag("maren_warning") and not _has_member("maren"):
        PartyState.add_member("maren", _get_party_avg_level())

func _has_member(character_id: String) -> bool:
    for m: Dictionary in PartyState.members:
        if m.get("character_id", "") == character_id:
            return true
    return false

func _get_party_avg_level() -> int:
    if PartyState.members.is_empty():
        return 1
    var total: int = 0
    for m: Dictionary in PartyState.members:
        total += m.get("level", 1) as int
    return maxi(1, total / PartyState.members.size())
```

Call `_check_party_joining_flags()` after dialogue overlay pops
(when `overlay_state_changed` fires with NONE state).

---

## 9. Test Plan

### test_wilds_route.gd (NEW, ~120 lines)

**Scene existence:**
- `test_roothollow_scene_exists` — file at res://scenes/maps/towns/roothollow.tscn
- `test_marens_refuge_scene_exists` — file at res://scenes/maps/towns/marens_refuge.tscn

**Transition wiring:**
- `test_overworld_has_roothollow_transition` — overworld.tscn contains "towns/roothollow"
- `test_overworld_has_marens_refuge_transition` — overworld.tscn contains "towns/marens_refuge"
- `test_overworld_wilds_spawn_markers` — from_roothollow and from_marens_refuge markers
- `test_roothollow_exit_targets_overworld` — roothollow target_map = "overworld"
- `test_marens_refuge_exit_targets_overworld` — marens_refuge target_map = "overworld"

**Round-trip validation:**
- `test_overworld_to_roothollow_round_trip` — bidirectional transition wiring
- `test_overworld_to_marens_refuge_round_trip` — bidirectional transition wiring

**Shop data integrity:**
- `test_roothollow_herbalist_shop_exists` — DataManager.load_shop("roothollow_herbalist") non-empty
- `test_roothollow_herbalist_items_resolve` — all item_ids exist in consumables/equipment

**Dialogue data:**
- `test_torren_encounter_dialogue_exists` — dialogue file loads
- `test_marens_warning_dialogue_exists` — dialogue file loads

**Party assembly:**
- `test_add_member_prevents_duplicates` — calling add_member twice doesn't double-add
- `test_add_member_sets_formation` — new member goes to active or reserve

**Encounter zone data:**
- `test_thornmere_wilds_zone_exists` — overworld encounters have thornmere_wilds zone
- `test_thornmere_wilds_enemy_ids_valid` — all enemy_ids in zone resolve

### Expand test_cross_references.gd

- Add roothollow_herbalist to shop validation
- Add roothollow/marens_refuge to transition validation
- Add torren_encounter/scene_6 to dialogue validation

---

## 10. File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/assets/tilesets/placeholder_dungeon.png` | MODIFY | Extend from 8 to 10 tiles |
| `game/assets/tilesets/placeholder_dungeon.tres` | MODIFY | Register tiles 8-9 |
| `game/scenes/maps/towns/roothollow.tscn` | CREATE | Roothollow village map |
| `game/scenes/maps/towns/marens_refuge.tscn` | CREATE | Maren's Refuge interior |
| `game/scenes/maps/overworld.tscn` | MODIFY | Add Wilds transitions + markers |
| `game/data/shops/roothollow_herbalist.json` | CREATE | Herbalist shop inventory |
| `game/data/encounters/overworld.json` | MODIFY | Add thornmere_wilds zone |
| `game/scripts/autoload/party_state.gd` | MODIFY | add_member() public API |
| `game/scripts/core/exploration.gd` | MODIFY | Party joining flag checks |
| `game/tests/test_wilds_route.gd` | CREATE | Integration tests |
| `game/tests/test_cross_references.gd` | MODIFY | Expand coverage |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.4 |

---

## 11. Remaining Work After Phase A

Explicitly tracked for future phases:

### Phase A2: Fenmother's Hollow (P1)
- Second Act I dungeon, forest/swamp biome
- 3 floors with Drowned Sentinel mini-boss + Corrupted Fenmother boss
- Encounter data already exists (fenmothers_hollow.json)
- New enemy sprites needed (marsh_serpent, drowned_bones, etc.)

### Phase B: Opening Sequence (P1)
- Ironmouth outpost map
- Ember Vein F3 (Ancient Ruin floor with puzzles)
- Scenes 1-4 (tutorial, Vaelith, Lira+Sable join, Dawn March credits)
- Party starts with just Edren+Cael, others join during Act I

### Phase C: Capital Completion (P1)
- Remaining Valdris districts (Citizen's Walk, Court Quarter, etc.)
- Scene 7 (throne hall, court free-roam, Cael's grey eyes moment)
- Thornwatch garrison (rest stop)
- Act I finale flag: pendulum_to_capital

### Deferred Systems
- Cutscene overlay (3.7) — needed for proper Scene 5a walk, join animations
- Audio integration (3.8) — Wilds biome music, spirit sounds
- Full overworld expansion — 20+ locations, terrain zones, Mode 7
