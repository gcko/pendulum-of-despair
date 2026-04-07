# Ember Vein Vertical Slice — Design Spec

> **Gap:** 4.1 (Vertical Slice: Ember Vein Dungeon)
> **Approach:** B — Two-Floor + Boss (3 map files: F1, F2, F4)
> **Goal:** Prove the end-to-end dungeon gameplay loop: enter dungeon →
> explore floors → random encounters → mini-boss → boss with scripted
> AI → rewards → event flags → exit.

---

## 1. Scope

### In Scope

- 3 floor maps: Floor 1 (Upper Mine), Floor 2 (Lower Mine), Floor 4 (Boss Arena)
- Minimal TileMapLayer with 4-color placeholder tileset (16x16)
- 4 random encounter enemy types from existing encounter data
- Ember Drake mini-boss (weighted-random AI, 1,500 HP)
- Vein Guardian boss (hardcoded 2-phase scripted AI, 6,000 HP)
- Boss encounter trigger zones (new exploration method)
- Floor-specific encounter config loading (fix always-first-floor)
- PartyState integration for battle setup (live stats in battle)
- Treasure chests (8 items across 3 floors)
- Save points (1 per floor)
- Floor transitions (stairs triggers with fade-to-black)
- Dialogue stubs for 4 story beats (via existing dialogue overlay)
- Event flags: `pendulum_discovered`, `vaelith_ember_vein`

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Floor 3 (Ancient Ruin) | Puzzle mechanics not built | Future content |
| All puzzle mechanics | Cart routing, switches, pressure plates, pitfalls | Future content |
| Mine Water Vial key item | Key item system not built | Future content |
| Cutscene overlay | Gap 3.7 NOT STARTED | Gap 3.7 |
| Audio integration | Gap 3.8 NOT STARTED | Gap 3.8 |
| Cael's Pallor shimmer | Visual FX polish | Gap 4.8+ |
| Arcanite gear breaking | Equipment system incomplete | Future |
| Lira/Sable party joins | Requires cutscene + party management | Gap 3.7 |
| Status effects (despair debuff) | Status apply path not wired | Gap 3.3 |
| FFR full implementation | SaveManager stubs are `pass` | Gap 3.6 |
| Overworld exit destination | No overworld map (gap 4.3) | Gap 4.3 |

### Tech Debt (track in beads)

1. **Vein Guardian hardcoded AI** — `_get_vein_guardian_action()` in
   battle_manager.gd. Refactor to data-driven `boss_ai.gd` when second
   boss is implemented.
2. **Placeholder tileset** — 4-color squares. Replace with pixel art
   in gap 4.8.
3. **Dialogue stubs for cutscenes** — Replace with cutscene system in
   gap 3.7.
4. **Post-boss exit** — Goes to test_room. Replace when gap 4.3
   (overworld) is built.
5. **Ember Drake AI** — Uses weighted-random. Design specifies Charge
   telegraph + Pounce targeting. Defer to boss AI refactor.
6. **Enemy stat cross-verification** — Values from act-i.md need full
   audit during implementation.

---

## 2. Tilemap Pipeline

### Tileset

Single image: `game/assets/tilesets/placeholder_dungeon.png`
- 64x16 px strip, 4 tiles at 16x16 each
- Tile 0: Floor — brown `#5C3A1E`
- Tile 1: Wall — dark grey `#2A2A2A`
- Tile 2: Crystal — orange-amber `#D4820A`
- Tile 3: Stairs — light grey `#8A8A8A`

### TileSet Resource

`game/assets/tilesets/placeholder_dungeon.tres`
- Tile size: 16x16
- Physics layer 0: Wall collision (tile 1 only)
- Terrain sets not needed for placeholder

### Map Scene Structure

Each floor `.tscn`:

```
Node2D (root)
├── TileMapLayer (terrain + collision)
├── Entities (Node2D)
│   ├── Chest_1 (Area2D — existing chest prefab)
│   ├── SavePoint_1 (Area2D — existing save point prefab)
│   └── BossTrigger (Area2D — new trigger for boss encounters)
└── SpawnPoints (Node2D)
    ├── default (Marker2D — entry position)
    ├── from_floor_1 (Marker2D)
    └── from_floor_2 (Marker2D)
```

### Floor Dimensions

| Floor | Tiles | Pixels | Random Encounters |
|-------|-------|--------|-------------------|
| F1: Upper Mine | 40x30 | 640x480 | Yes (floors 1-2 groups) |
| F2: Lower Mine | 40x30 | 640x480 | Yes (floor 3 groups) |
| F4: Boss Arena | 20x15 | 320x240 | No |

---

## 3. Enemy Data

### Regular Enemies (JSON files in `game/data/enemies/`)

Values from `docs/story/bestiary/act-i.md`. Each file contains stats,
elemental profile, drop table, and attack list.

| Enemy | ID | Lv | HP | ATK | DEF | MAG | MDEF | SPD | LCK | XP | Gold |
|-------|----|----|----|-----|-----|-----|------|-----|-----|----|------|
| Ley Vermin | `ley_vermin` | 1 | 23 | 8 | 4 | 2 | 3 | 6 | 3 | 5 | 3 |
| Unstable Crystal | `unstable_crystal` | 3 | 64 | 12 | 10 | 8 | 6 | 4 | 2 | 12 | 8 |
| Mine Shade | `mine_shade` | 4 | 96 | 14 | 8 | 12 | 10 | 8 | 4 | 18 | 12 |
| Ember Wisp | `ember_wisp` | 5 | 125 | 10 | 6 | 16 | 12 | 10 | 5 | 22 | 15 |

**Note:** These values MUST be verified against the bestiary during
implementation. The table above is a transcription checkpoint, not the
source of truth. `docs/story/bestiary/act-i.md` is the source.

### Enemy JSON Schema

```json
{
  "id": "ley_vermin",
  "name": "Ley Vermin",
  "type": "beast",
  "level": 1,
  "base_stats": {
    "hp": 23, "mp": 0,
    "atk": 8, "def": 4, "mag": 2, "mdef": 3, "spd": 6, "lck": 3
  },
  "elemental_profile": {
    "weaknesses": [],
    "resistances": [],
    "immunities": [],
    "absorbs": []
  },
  "status_immunities": [],
  "attacks": [
    {"id": "bite", "name": "Bite", "type": "physical", "power": 10}
  ],
  "drops": {
    "item_id": "potion",
    "rate": 15
  },
  "steal": {
    "item_id": "",
    "rate": 0
  },
  "xp": 5,
  "gold": 3,
  "is_boss": false,
  "is_mini_boss": false
}
```

### Ember Drake (Mini-Boss)

| Field | Value |
|-------|-------|
| ID | `ember_drake` |
| Level | 8 |
| HP | 1,500 |
| ATK / DEF / MAG / MDEF / SPD / LCK | 22 / 15 / 14 / 10 / 12 / 6 |
| Weakness | Frost |
| Resists | — |
| Attacks | Claw (phys, power 18), Flame Breath (mag, fire, power 22), Pounce (phys, power 15) |
| AI | Weighted-random (existing battle_ai.gd) |
| Drop | Drake Fang (100%) |
| XP / Gold | 120 / 80 |
| is_boss | true |
| is_mini_boss | true |

### Vein Guardian (Boss)

| Field | Value |
|-------|-------|
| ID | `vein_guardian` |
| Level | 12 |
| HP | 6,000 |
| ATK / DEF / MAG / MDEF / SPD / LCK | 28 / 20 / 24 / 18 / 8 / 4 |
| Weakness | Storm |
| Resists | Flame |
| Immunities | Death, Petrify, Stop, Sleep, Confusion |
| Attacks | Crystal Slam (phys, power 30, single), Ember Pulse (mag, fire, power 24, AoE), Reconstruct (heal 300 HP, self) |
| AI | Hardcoded scripted (see Section 4) |
| Drop | Vein Guardian's Core (100%) |
| XP / Gold | 800 / 50 |
| is_boss | true |
| is_mini_boss | false |

---

## 4. Vein Guardian Scripted AI

### Location

New method in `game/scripts/combat/battle_manager.gd`:

```
_get_vein_guardian_action(turn: int, hp_ratio: float) -> Dictionary
```

### State Variables

Added to battle_manager.gd instance scope:

```gdscript
var _vg_phase: int = 1
var _vg_last_action: String = ""
var _vg_reconstructed: bool = false
```

Reset in `_setup_enemies()` when `is_boss` is true.

### Phase Logic

```
Phase 1 (hp_ratio > 0.5 OR already reconstructed):
  if turn % 4 == 0 → Crystal Slam
  elif turn % 3 == 0 → Ember Pulse
  elif _vg_last_action == "crystal_slam" → Ember Pulse
  else → Crystal Slam

Phase 2 trigger (hp_ratio <= 0.5 AND NOT _vg_reconstructed):
  → Reconstruct (heal 300 HP, skip attack)
  → Set _vg_reconstructed = true
  → Next turn returns to Phase 1 logic
```

### Integration Point

In `_execute_enemy_turn()`, when the current enemy's data has
`is_boss == true` and `id == "vein_guardian"`:

```gdscript
if enemy_data.get("id", "") == "vein_guardian":
    action = _get_vein_guardian_action(_turn_counter, hp_ratio)
else:
    action = BattleAI.select_action(enemy_data, party_state)
```

**Tech debt:** This `if` chain does not scale. When a second boss
exists, refactor to a `boss_ai.gd` that reads phase/pattern tables
from enemy JSON `"ai_script"` field.

---

## 5. Boss Encounter Triggers

### New Method in exploration.gd

```gdscript
func _trigger_boss_encounter(
    boss_id: String, enemy_ids: Array[String], act: String
) -> void
```

Similar to `_trigger_random_encounter()` but:
- Takes specific enemy IDs (not random group selection)
- Sets `is_boss: true` in transition data
- Sets `encounter_source: "boss"` (vs `"random"`)
- No danger counter involvement

### Trigger Zone in Map Scenes

Boss encounters use Area2D trigger zones placed in the map `.tscn`:
- `BossTrigger` node with metadata: `boss_id`, `enemy_ids`, `act`
- Connected to `body_entered` signal
- Actor-filtered: `if body != _player: return`
- One-shot: sets EventFlags to prevent re-trigger after defeat

### Mini-Boss vs Boss

| | Mini-Boss (Ember Drake) | Boss (Vein Guardian) |
|---|---|---|
| Trigger | Area2D zone on F2 | Area2D zone on F4 |
| Flee | Disabled (`is_boss: true`) | Disabled |
| Event flag | `ember_drake_defeated` | `vaelith_ember_vein` |
| Re-trigger | No (flag-gated) | No (flag-gated) |
| AI | Weighted-random | Hardcoded scripted |

---

## 6. Floor-Specific Encounter Config

### Current Problem

`exploration.gd:130` always loads `floors[0]` from encounter data.
Floor 2 needs different encounter groups than Floor 1.

### Fix

Store `_current_floor_id: String` on exploration. Set it from map
metadata when loading a map:

```gdscript
_current_floor_id = _current_map.get_meta("floor_id", "")
```

Then match against encounter data:

```gdscript
for floor_entry: Variant in floors:
    if floor_entry is Dictionary:
        if (floor_entry as Dictionary).get("floor_id", "") == _current_floor_id:
            _encounter_config = floor_entry as Dictionary
            break
```

Falls back to `floors[0]` if no match (preserves existing behavior).

### Map Metadata

Each floor `.tscn` root node sets metadata:
- `map_id`: e.g., `"ember_vein_f1"`
- `floor_id`: e.g., `"1-2"` (matches encounter JSON floor_id)
- `location_name`: `"Ember Vein - Upper Mine"`
- `dungeon_id`: `"ember_vein"` (for encounter table lookup)

The `dungeon_id` metadata tells exploration which encounter file to
load via `DataManager.load_encounters(dungeon_id)`.

---

## 7. PartyState Battle Integration

### Current Problem

`battle_manager.gd:_setup_party()` loads from `DataManager` with
hardcoded character IDs. Level-ups from encounters don't carry into
subsequent battles.

### Fix

Replace `_setup_party()` to read from `PartyState.get_active_party()`:

```gdscript
func _setup_party() -> void:
    var active: Array[Dictionary] = PartyState.get_active_party()
    for i: int in range(active.size()):
        if not active[i].is_empty():
            _state.add_member(i, active[i])
```

This ensures battle uses live HP, MP, XP, level, and stats from
PartyState — including any level-ups earned in prior encounters.

**Note:** `battle_state.gd:add_member()` must handle the PartyState
member dict format (which uses `base_stats.hp` for max HP, `current_hp`
for live HP). Verify this maps correctly during implementation.

---

## 8. Treasure & Items

### Placeholder Item Entries

Items found in chests need entries in JSON data. Most don't exist yet
in `game/data/items/` or `game/data/equipment/`. Create minimal entries
with IDs and names — full stat integration uses existing systems.

| Item | Type | Location | JSON File |
|------|------|----------|-----------|
| Carradan Mining Pick | Weapon | F1 chest | `game/data/equipment/weapons.json` (append) |
| Potion (x3) | Consumable | F1 chest | Already exists in items data |
| Iron Bracelet | Accessory | F1 chest | `game/data/equipment/accessories.json` (append) |
| Antidote (x2) | Consumable | F2 chest | Already exists in items data |
| Ember Ring | Accessory | F2 chest | `game/data/equipment/accessories.json` (append) |
| Potion (x3) | Consumable | F4 chest | Already exists |
| Ember Tonic | Consumable | F4 chest | `game/data/items/consumables.json` (append) |
| Drake Fang | Consumable | Ember Drake drop | `game/data/items/consumables.json` (append) |
| Vein Guardian's Core | Material | Vein Guardian drop | `game/data/items/materials.json` (append) |

**Values from design docs:**
- Potion: `items.md` — restores 50 HP, buy 50g
- Antidote: `items.md` — cures Poison, buy 40g
- Ember Tonic: `items.md` — restores 50 MP, buy 300g
- Iron Bracelet: `equipment.md` — +3 DEF
- Ember Ring: `equipment.md` — +3 ATK, +2 MAG
- Carradan Mining Pick: `equipment.md` — weapon stats TBD from source
- Drake Fang: `items.md` — consumable, 500 bonus damage
- Vein Guardian's Core: crafting material, sell value from `economy.md`

---

## 9. Dialogue Stubs

Story beats delivered via existing dialogue overlay (not cutscene
system). Each is a TriggerZone in the map that calls
`GameManager.push_overlay(DIALOGUE)` with dialogue data.

### Beat 1: Floor 1 Entry

**Trigger:** Area2D near F1 entrance, one-shot (flag-gated)
**Flag:** `ember_vein_entry_seen`

```
Edren: "Stay close. The miners reported strange lights before they
stopped reporting altogether."
Cael: "The air feels heavy. Like something is pressing down."
```

### Beat 2: Floor 2 Dead Miners

**Trigger:** Area2D near miner bodies on F2, one-shot
**Flag:** `ember_vein_miners_seen`

```
Cael: "They didn't die fighting. They died feeling something."
Edren: "No wounds. No signs of struggle. Just... this."
Cael: "Whatever killed them, it wasn't quick. Look at their faces."
```

### Beat 3: Floor 4 Pendulum Discovery

**Trigger:** Area2D at Pendulum pedestal on F4, one-shot
**Flag:** `pendulum_discovered`

```
Cael: "Seven of them. Arranged like a mural I've never seen."
Edren: "They arranged themselves. No drag marks."
Cael: "They walked in, sat down, and gave up."
Edren: "We need to take this to Valdris. If the Compact finds it—"
Cael: "Don't. Something about this place."
[Edren picks up the Pendulum. The needle twitches once.]
[The room shudders. Dust falls. Ley channels flare bright then dim.]
Cael: "Something heard that."
```

### Beat 4: Post-Boss Exit

**Trigger:** After Vein Guardian defeated, before exit
**Flag:** `vaelith_ember_vein`

```
Edren: "This way. The soldiers are above us, not ahead."
Cael: "You hope."
Edren: "I do."
```

---

## 10. Event Flags

| Flag | Set When | Effect |
|------|----------|--------|
| `ember_vein_entry_seen` | F1 dialogue trigger | Prevents re-trigger |
| `ember_vein_miners_seen` | F2 dialogue trigger | Prevents re-trigger |
| `ember_drake_defeated` | Ember Drake battle victory | Prevents re-trigger, opens path |
| `pendulum_discovered` | F4 Pendulum dialogue | Marks Pendulum obtained |
| `vaelith_ember_vein` | Vein Guardian defeated | Marks dungeon complete |

---

## 11. Map Transition Flow

```
Title Screen → New Game → exploration (test_room)
  → [walk to exit] → ember_vein_f1
    → [stairs down] → ember_vein_f2
      → [stairs down] → ember_vein_f4
        → [boss defeated, exit trigger] → test_room (placeholder)
```

Each transition uses existing `load_map()` with fade-to-black.
Stairs are Area2D trigger zones that call:

```gdscript
_transition_to_map("ember_vein_f2", "from_floor_1")
```

The spawn name resolves to a Marker2D in the target map's SpawnPoints
node, placing the player at the correct entry position.

---

## 12. File Map

### New Files

| File | Purpose |
|------|---------|
| `game/assets/tilesets/placeholder_dungeon.png` | 4-tile placeholder tileset image |
| `game/assets/tilesets/placeholder_dungeon.tres` | TileSet resource with physics |
| `game/scenes/maps/dungeons/ember_vein_f1.tscn` | Floor 1 map scene |
| `game/scenes/maps/dungeons/ember_vein_f2.tscn` | Floor 2 map scene |
| `game/scenes/maps/dungeons/ember_vein_f4.tscn` | Floor 4 boss arena scene |
| `game/data/enemies/ley_vermin.json` | Enemy stat data |
| `game/data/enemies/unstable_crystal.json` | Enemy stat data |
| `game/data/enemies/mine_shade.json` | Enemy stat data |
| `game/data/enemies/ember_wisp.json` | Enemy stat data |
| `game/data/enemies/ember_drake.json` | Mini-boss stat data |
| `game/data/enemies/vein_guardian.json` | Boss stat data |

### Modified Files

| File | Changes |
|------|---------|
| `game/scripts/core/exploration.gd` | `_trigger_boss_encounter()`, floor-specific config, `_current_floor_id` |
| `game/scripts/combat/battle_manager.gd` | `_get_vein_guardian_action()`, VG state vars, `_setup_party()` PartyState fix, boss flee disable |
| `game/data/items/consumables.json` | Append Ember Tonic, Drake Fang |
| `game/data/items/materials.json` | Append Vein Guardian's Core |
| `game/data/equipment/weapons.json` | Append Carradan Mining Pick |
| `game/data/equipment/accessories.json` | Append Iron Bracelet, Ember Ring |
| `docs/analysis/game-dev-gaps.md` | Update gap 4.1 status |
