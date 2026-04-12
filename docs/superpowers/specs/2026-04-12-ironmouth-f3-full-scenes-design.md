# Phase B2: Ironmouth + Ember Vein F3 + Full Scenes

**Date:** 2026-04-12
**Gap:** 4.4 Phase B2
**Status:** Design approved, ready for implementation
**Depends On:** Phase A (Wilds Route), Phase A2/A2b (Fenmother), Phase B1 (Party Assembly)

## Scope

Five implementation chunks (A–E). Chunk F (Dawn March + Credits)
deferred — requires cutscene system (gap 3.7).

| Chunk | Deliverables | Est. Files |
|-------|-------------|-----------|
| E: Mechanical Tweaks | Start location, Arcanite gear, Cael shimmer | 3–4 modified |
| A: Ember Vein F3 | 45x35 map, 3 puzzle entities, encounters, treasures | 8 new, 3 modified |
| C: Scene 1 Dialogue | 1a–1e beats across F1–F4 | 5 new dialogue JSON, 2 maps modified |
| B: Ironmouth Docks | Linear escape map, lootable crates | 2 new, 1 modified |
| D: Scene 3 Combat | Carradan soldier enemies, scripted fight | 1 modified (enemy data), test |

**Build order:** E → A → C → B → D (dependency-driven)

**Deferred (Chunk F):** Dawn March forward-only walk, opening credits
title card, credits overlay. These require gap 3.7 (Cutscene Overlay)
for forward-only movement, camera control, and screen text overlays.
Track in gap doc under Phase B2 deferred items.

---

## Chunk E: Mechanical Tweaks

### E1: Change New Game Start to Ember Vein F1

The tutorial begins immediately in the mine — no overworld wandering.

**Changes:**
- In the code path that sets the initial map after
  `PartyState.initialize_new_game()`, change the start map ID from
  `"overworld"` to `"dungeons/ember_vein_f1"`
- Add a `new_game_spawn` Position2D marker to `ember_vein_f1.tscn` near
  the mine entrance (top-left area of the existing map)
- `GameManager.transition_data` should include
  `{"spawn": "new_game_spawn"}` for the initial load

**Tests:**
- New game loads Ember Vein F1
- Player positioned at `new_game_spawn` marker
- Overworld is NOT loaded at game start

### E2: Arcanite Gear Preview

Edren starts with confiscated Compact prototypes (~30% ATK/DEF boost
above normal Act I baselines). Equipment breaks after the Vein
Guardian fight during the escape from the mine.

**New equipment entries** following the existing JSON schemas:

**Weapon** (add to `equipment/weapons.json`):
```json
{
  "id": "arcanite_sword_proto",
  "name": "Arcanite Sword (Prototype)",
  "type": "sword",
  "tier": 1,
  "equippable_by": ["edren"],
  "atk": 13,
  "bonus_stats": {},
  "element": null,
  "special": null,
  "buy_price": null,
  "sell_price": null,
  "acquired": "Starting equipment (Edren) — breaks after Ember Vein",
  "description": "A confiscated Compact prototype. Arcanite-enhanced but unstable."
}
```

**Armor** (add to `equipment/armor.json`):
```json
{
  "id": "arcanite_mail_proto",
  "name": "Arcanite Mail (Prototype)",
  "slot": "body",
  "armor_class": "heavy",
  "tier": 1,
  "equippable_by": ["edren"],
  "def": 10,
  "mdef": 4,
  "bonus_stats": {},
  "special": null,
  "buy_price": null,
  "sell_price": null,
  "acquired": "Starting equipment (Edren) — breaks after Ember Vein",
  "description": "Prototype Compact body armor. Arcanite-laced plates provide exceptional protection."
}
```

**Stat rationale:** Training Sword ATK 4, Tier 1 swords ATK 8-10.
Arcanite Sword ATK 13 (~30% above Tier 1 top). Leather Cap DEF 2,
Tier 1 body armor DEF ~7-8. Arcanite Mail DEF 10 (~30% above).
These items have `buy_price: null` and `sell_price: null` — they
cannot be bought, sold, or re-acquired. No `is_temporary` schema
field needed; `break_arcanite_gear()` knows the IDs to remove.

**PartyState changes:**
- `initialize_new_game()` equips `arcanite_sword_proto` and
  `arcanite_mail_proto` on Edren (instead of empty slots)
- New method `break_arcanite_gear() -> void`:
  - Removes `arcanite_sword_proto` and `arcanite_mail_proto` from
    Edren's equipment by checking equipped item IDs
  - Sets those equipment slots to empty (no fallback — Edren is
    unequipped until the player buys/finds gear)
  - Emits `inventory_changed` signal

**Break trigger:** After `pendulum_discovered` flag is set (post-Vein
Guardian), a dialogue trigger on the F4 exit or Scene 2 overworld
sequence fires the gear break. The narrative beat: equipment shatters
during the escape from the mine. Call
`PartyState.break_arcanite_gear()` from the dialogue trigger's
completion callback.

**Tests:**
- Edren has arcanite gear equipped after `initialize_new_game()`
- `arcanite_sword_proto` ATK 13, `arcanite_mail_proto` DEF 10
- `break_arcanite_gear()` removes both items by ID
- Edren's equipment slots are empty after break
- Arcanite items do not appear in inventory after break
- `inventory_changed` signal emitted

### E3: Cael's Pallor Shimmer (+10% Damage)

Cael's attacks deal 10% above his stat line throughout the game.
No in-game explanation — Pallor's first touch, retroactive
foreshadowing visible only on replay or careful observation.

**Changes:**
- In `damage_calculator.gd`, after computing physical damage, check
  if attacker character_id is `"cael"`. If so, multiply final damage
  by `1.1` (before variance, after DEF subtraction)
- No UI indicator, no buff icon, no status effect
- Visual shimmer on attack sprite deferred to gap 4.8 (Art Assets)

**Scope:** Always active. The `dungeons-world.md` mentions shimmer
"throughout Ember Vein" as where it's first observable, but Pallor's
touch is permanent per the character arc in `characters.md` — Cael
carries it the entire game. The 10% is subtle enough to be
unnoticeable without side-by-side stat comparison, serving as
retroactive foreshadowing on replay. Update `dungeons-world.md` to
clarify that the shimmer persists beyond Ember Vein.

**Tests:**
- Cael's physical damage is exactly 10% higher than formula baseline
  (for same ATK/DEF values)
- Other characters deal standard damage (no multiplier)
- Magical damage is NOT affected (only physical)

---

## Chunk A: Ember Vein F3 — Ancient Ruin

### A1: New Puzzle Entities

Three new entity types following the A2b pattern (dungeon-agnostic,
signal-based, puzzle_state persistence).

#### PressurePlate (`pressure_plate.gd` / `.tscn`)

- Extends `Area2D`, collision layer 3 (interactables)
- **Behavior:** One-shot toggle. On `body_entered`, sets
  `puzzle_state[dungeon_id][plate_id + "_pressed"] = true` permanently.
  Does not revert on `body_exited`.
- **Signal:** `plate_pressed(plate_id: String)`
- **Initialize:** `initialize(p_plate_id: String, p_dungeon_id: String)`
  — restores state from puzzle_state
- **Visual:** 16x16 placeholder sprite, 2 frames (raised = frame 0,
  depressed = frame 1). Modulate shift on press.
- **Scene tree:** Area2D → Sprite2D + CollisionShape2D (12x12 rect)
- Connected WaterZone uses condition `plate_id + "_pressed"` to
  reveal the hidden door

#### EmberCrystal (`ember_crystal.gd` / `.tscn`)

- Extends `StaticBody2D` (blocks passage when active)
- **Behavior:** Key item consumer. On `interact()`:
  - If `mine_water_vial` in `PartyState.get_key_items()`: consume vial,
    set `puzzle_state[dungeon_id][crystal_id + "_cleared"] = true`,
    disable collision, emit `crystal_cleared(crystal_id)`. Modulate
    shift from dim `Color("#664400")` to bright `Color("#ffaa44")`.
  - If absent: emit `interaction_message("It looks parched... maybe
    something from the mine levels could help.")`
- **Signal:** `crystal_cleared(crystal_id: String)`,
  `interaction_message(text: String)`
- **Initialize:** `initialize(p_crystal_id: String, p_dungeon_id: String)`
  — restores state, disables collision if already cleared
- **Visual:** 32x16 placeholder sprite (amber crystal mass blocking
  a corridor). Two visual states: withered (dim) / restored (bright).
- **Scene tree:** StaticBody2D → Sprite2D + CollisionShape2D (main
  blocker) + InteractionArea (Area2D, collision layer 3)

#### PitfallZone (`pitfall_zone.gd` / `.tscn`)

- Extends `Area2D`, collision layer 3
- **Behavior:** On `body_entered`, emit
  `pitfall_triggered(target_map_id, target_spawn)`. One-shot per visit
  (runtime flag `_has_triggered`, NOT persisted — player can fall
  again on return).
- **Signal:** `pitfall_triggered(target_map_id: String,
  target_spawn: String)`
- **Metadata:** `target_map_id`, `target_spawn` (set per instance)
- **Initialize:** `initialize(p_target_map_id: String, p_target_spawn: String)`
  — stores target info. No dungeon_id or puzzle_state needed;
  stateless across saves (runtime `_has_triggered` flag only).
- **Visual:** 16x16 cracked geometric tile placeholder. Subtle but
  visible (slightly different color from surrounding floor).
- **Scene tree:** Area2D → Sprite2D + CollisionShape2D (12x12 rect)
- `exploration.gd` handles the signal by calling `load_map()` with
  the target map and spawn point

### A2: Mine Water Vial (Key Item on F2)

Add a new interactable to `ember_vein_f2.tscn`:
- Position: near the miner's journal location (mid-map)
- Type: TreasureChest (or simple interact area) containing the
  `mine_water_vial` key item
- On interact: `PartyState.add_key_item("mine_water_vial")`, show
  message: "Found Mine Water Vial. A miner's journal reads: 'The
  growths drink deep — even stale water wakes them for a spell.'"
- One-shot via chest_id / EventFlags (standard chest pattern)

The vial is consumed by EmberCrystal on F3. If the player misses it,
Cael provides a hint on F3: "It looks thirsty. Maybe there's
something back in the mine levels that could help."

### A3: F3 Map (`ember_vein_f3.tscn`)

**Size:** 45x35 tiles
**Tileset:** Existing placeholder tileset extended with 1-2 geometric
stone variants (smooth dark tiles, carved channel tiles) at indices
after the current set.

**Map metadata:**
```
metadata/map_id = "dungeons/ember_vein_f3"
metadata/floor_id = "3"
metadata/dungeon_id = "ember_vein"
metadata/location_name = "Ember Vein - Ancient Ruin"
```

**Layout** (from `dungeons-world.md` ASCII map):

| Zone | Entities | Notes |
|------|----------|-------|
| Top (entry) | Stairs from F2, dialogue trigger (1c entry) | "This isn't a mine." |
| Upper passage | TreasureChest (2x Potion) | Standard chest |
| Mid-left | PressurePlate + WaterZone (hidden door) | Secret room access |
| Secret room | TreasureChest (Ember Shard, +5 MAG accessory) | Behind hidden door |
| Mid-right | PitfallZone → F2 `from_pitfall` spawn | Cracked geometric tile |
| Lower-center | Story chamber dialogue trigger (1c murals) | Geometric murals |
| Below story chamber | EmberCrystal blocking passage south | Mine Water Vial puzzle |
| Lower-left | SavePoint (before F4 stairs) | `ember_vein_f3_save` |
| Bottom passage | TreasureChest (Phoenix Down) | Valuable early-game item |
| Bottom | Stairs to F4 | Transition to `dungeons/ember_vein_f4` |

**Spawn points:**
- `from_f2` (top stairs — entry from F2)
- `from_f4` (bottom stairs — if player backtracks from F4)
- `from_pitfall` spawn added to F2 (upper area, for pitfall recovery)

**Encounters:** Floor "3" config already exists in
`game/data/encounters/ember_vein.json` with 4 groups:
- 2x Mine Shade + 1x Ember Wisp (31.25%)
- 1x Unstable Crystal + 2x Ember Wisp (31.25%)
- 2x Unstable Crystal + 1x Mine Shade (31.25%)
- 2x Mine Shade + 2x Ember Wisp (6.25%)

All enemy IDs exist in `act_i.json`. No new enemy data needed.

### A4: Entity Wiring in exploration.gd

Add initialization cases in `_initialize_entities()` for:

```
# PressurePlate — detect via plate_pressed signal
elif child.has_signal("plate_pressed"):
    var pid: String = child.get_meta("plate_id", "")
    var did: String = child.get_meta("dungeon_id", "")
    child.initialize(pid, did)

# EmberCrystal — detect via crystal_cleared signal
elif child.has_signal("crystal_cleared"):
    var cid: String = child.get_meta("crystal_id", "")
    var did: String = child.get_meta("dungeon_id", "")
    child.initialize(cid, did)

# PitfallZone — detect via pitfall_triggered signal
elif child.has_signal("pitfall_triggered"):
    var tmid: String = child.get_meta("target_map_id", "")
    var tsp: String = child.get_meta("target_spawn", "")
    child.initialize(tmid, tsp)
```

Signal connections:
- `plate_pressed` → `_on_plate_pressed(plate_id)` — refresh all
  WaterZones on the map (same pattern as `_on_wheel_toggled`)
- `crystal_cleared` → `_on_crystal_cleared(crystal_id)` — optional
  SFX/flash effect
- `pitfall_triggered` → `_on_pitfall_triggered(map_id, spawn)` —
  call `load_map(map_id, spawn)` with fade transition
- `interaction_message` → show message via dialogue overlay or
  notification (same pattern as spirit_plant)

### A5: Tests (`test_ember_vein_f3.gd`)

- **PressurePlate:** press sets puzzle_state, stays pressed after
  body_exited, persists across map reload, connected WaterZone
  becomes passable
- **EmberCrystal:** blocks passage without vial, clears with vial,
  vial consumed from key_items, collision disabled after clear,
  persists across map reload
- **PitfallZone:** emits signal with correct target_map_id and
  target_spawn, resets per visit (can trigger again)
- **Mine Water Vial:** pickup on F2 adds to key_items, consumption
  on F3 removes from key_items
- **Encounter config:** floor "3" loads from ember_vein.json, enemy
  IDs resolve in DataManager
- **Treasure chests:** all 3 accessible (2x Potion, Ember Shard,
  Phoenix Down), correct items granted
- **Navigation:** F2→F3 transition, F3→F4 transition, F3→F2 pitfall
  transition all load correct maps
- **Save point:** `ember_vein_f3_save` activates correctly

---

## Chunk B: Ironmouth Docks (Linear Escape Map)

### B1: Map Layout (`ironmouth_docks.tscn`)

**Size:** ~20x12 tiles (linear corridor)
**Tileset:** Reuse existing town tiles (stone floor, wood wall) plus
1-2 dock tiles (wood planks, water edge) appended to the placeholder
tileset.

**Design principle:** Ironmouth is a pass-through location. The
Compact locks it down permanently after Act I (`carradan_ambush_survived`
flag). No free-roam, no return visits. Linear layout matches the
script's urgency.

**Map metadata:**
```
metadata/map_id = "towns/ironmouth_docks"
metadata/location_name = "Ironmouth Docks"
metadata/encounter_enabled = false
```

No random encounters — this is a scripted narrative sequence.

**Layout flow (left → right):**
1. Entry spawn (left) — party arrives from mine exit / overworld
2. Lira dialogue trigger — behind Forgewright crates
3. Forgewright supply crates (3 lootable, TreasureChest entities)
4. Sable dialogue trigger — mid-map pillar area
5. Patrol combat trigger — near exit, forced encounter
6. Exit transition (right) — to overworld at Wilds entry point

**Spawn points:**
- `from_overworld` (left side entry)

### B2: Lootable Crates

Three TreasureChest entities with crate-style placeholder sprites:

| Crate | Contents | Verify ID Exists |
|-------|----------|-----------------|
| 1 | Potion x2 | `potion` in consumables.json |
| 2 | Antidote x1 | `antidote` in consumables.json |
| 3 | Iron Bracelet | `iron_bracelet` confirmed in accessories.json |

If `iron_bracelet` doesn't exist, substitute another basic Act I
accessory that does.

### B3: Sequence Gating

Dialogue triggers enforce linear progression:
- Lira trigger: no `required_flag` (fires on entry)
- Crates: accessible any time after Lira trigger
- Sable trigger: `required_flag = "ironmouth_lira_seen"`
- Combat trigger: `required_flag = "ironmouth_sable_seen"`
- Exit: `required_flag = "carradan_ambush_survived"`

Use persisted EventFlags (`ironmouth_lira_seen`,
`ironmouth_sable_seen`) for crash safety. If the game crashes
mid-sequence and the player reloads, persisted flags preserve
progress through the scripted sequence.

### B4: Overworld Integration

- Add Ironmouth entry point on overworld map (near Ember Vein exit
  area)
- Entry trigger: `required_flag = "vaelith_scene_complete"` (must
  see Scene 2 Vaelith dialogue first, per `events.md` flag 2b).
  Note: `script/act-i.md` Scene 3 header lists `pendulum_discovered`
  as the trigger, but `events.md` defines the correct ordering chain:
  `pendulum_discovered` → `vaelith_ember_vein` → `vaelith_scene_complete`
  → Scene 3. The script header is stale.
- After `carradan_ambush_survived`, the entry trigger is disabled
  (flag-gated, one-shot)
- Exit from Ironmouth transitions to overworld at Wilds entry
  (existing Wilds area near Roothollow)

### B5: Tests (`test_ironmouth.gd`)

- Dialogue triggers fire in correct order (Lira → Sable → combat)
- Cannot skip ahead (required_flag gating enforced)
- All 3 crates lootable with correct items
- Combat encounter triggers with correct enemies (2 Patrol + 1 Scout)
- Flee is disabled (forced encounter)
- `carradan_ambush_survived` flag set after victory
- `_check_party_joining_flags()` adds Lira+Sable after flag
- Lira+Sable join at party average level
- Exit transition loads overworld at correct spawn
- Ironmouth not re-enterable after escape
- Overworld entry requires `vaelith_scene_complete` flag (gate test)

---

## Chunk C: Scene 1 Full Dialogue (1a–1e)

### C1: Dialogue Data Files

All dialogue sourced verbatim from `docs/story/script/act-i.md`.
No invented lines.

| File | Floor | Beat | Content Summary |
|------|-------|------|-----------------|
| `ember_vein_tutorial.json` (expand existing) | F1 | 1a | 3 dead miners, "They just stopped", Cael's despair observation |
| `ember_vein_1a_bodies.json` (new) | F1 | 1a cont. | Additional miner discoveries mid-map |
| `ember_vein_1b_letter.json` (new) | F2 | 1b | 6 more dead, unfinished letter, hand clawed at stone, journal + vial |
| `ember_vein_1c_ruins.json` (new) | F3 | 1c | Entry: "This isn't a mine. This is something else." Architecture shift |
| `ember_vein_1c_murals.json` (new) | F3 | 1c cont. | Story chamber: murals, kneeling figures interpretation |
| `ember_vein_1d_pendulum.json` (expand or new) | F4 | 1d | 7 dead miners in circle, Pendulum pickup, room shudder, soldiers above |
| `ember_vein_1e_escape.json` (new) | F4 | 1e | Post-boss: seal crumbles, hidden passage, climb out |

### C2: Trigger Placement

Each trigger is an Area2D in the map's Entities node:

| Map | Trigger | Metadata |
|-----|---------|----------|
| F1 | Entry (existing, expand) | `dialogue_scene_id = "ember_vein_tutorial"`, `flag = "ember_vein_1a_seen"` |
| F1 | Mid-map bodies | `dialogue_scene_id = "ember_vein_1a_bodies"`, `flag = "ember_vein_1a_bodies_seen"`, `required_flag = "ember_vein_1a_seen"` |
| F2 | Near journal | `dialogue_scene_id = "ember_vein_1b_letter"`, `flag = "ember_vein_1b_seen"` |
| F3 | Top stairs | `dialogue_scene_id = "ember_vein_1c_ruins"`, `flag = "ember_vein_1c_seen"` |
| F3 | Story chamber | `dialogue_scene_id = "ember_vein_1c_murals"`, `flag = "ember_vein_1c_murals_seen"`, `required_flag = "ember_vein_1c_seen"` |
| F4 | Entry area | `dialogue_scene_id = "ember_vein_1d_pendulum"`, `flag = "pendulum_discovered"` |
| F4 | Post-boss | `dialogue_scene_id = "ember_vein_1e_escape"`, `flag = "ember_vein_1e_seen"`, `required_flag = "vaelith_ember_vein"` |

### C3: Pendulum Discovery + Arcanite Break Integration

The 1d trigger on F4 sets `pendulum_discovered` — the master flag for
Act I progression. The 1e trigger (post-boss escape) is where the
Arcanite gear break fires:
- After 1e dialogue completes, call `PartyState.break_arcanite_gear()`
- Show additional message: "Edren's arcanite equipment shatters as
  crystalline energy surges through the passage."
- This happens BEFORE the Scene 2 Vaelith encounter on the overworld

### C4: Tests

- All 7 dialogue triggers fire on correct floors
- Dialogue content loads from JSON (no inline data)
- One-shot flags prevent replay
- Required_flag ordering enforced
- `pendulum_discovered` set during 1d
- Arcanite gear break fires during 1e
- Mine Water Vial pickup available during/after 1b

---

## Chunk D: Scene 3 Combat (Ironmouth Escape Fight)

### D1: New Enemy Data

Add 2 entries to `game/data/enemies/act_i.json`:

**Compact Patrol** (follows existing `act_i.json` schema):
```json
{
  "id": "compact_patrol",
  "name": "Compact Patrol",
  "type": "humanoid",
  "threat": "low",
  "level": 5,
  "hp": 180,
  "mp": 0,
  "atk": 16,
  "def": 14,
  "mag": 8,
  "mdef": 10,
  "spd": 10,
  "gold": 30,
  "exp": 18,
  "weaknesses": [],
  "resistances": [],
  "absorb": [],
  "status_immunities": [],
  "steal": {
    "common": { "item_id": null, "rate": 0 },
    "rare": { "item_id": null, "rate": 0 }
  },
  "drop": { "item_id": "potion", "rate": 75 },
  "locations": ["ironmouth_docks"],
  "ko_sound": "ko_humanoid"
}
```

**Compact Scout** (follows existing `act_i.json` schema):
```json
{
  "id": "compact_scout",
  "name": "Compact Scout",
  "type": "humanoid",
  "threat": "low",
  "level": 6,
  "hp": 140,
  "mp": 0,
  "atk": 14,
  "def": 10,
  "mag": 8,
  "mdef": 8,
  "spd": 14,
  "gold": 35,
  "exp": 20,
  "weaknesses": [],
  "resistances": [],
  "absorb": [],
  "status_immunities": [],
  "steal": {
    "common": { "item_id": null, "rate": 0 },
    "rare": { "item_id": null, "rate": 0 }
  },
  "drop": { "item_id": "antidote", "rate": 50 },
  "locations": ["ironmouth_docks"],
  "ko_sound": "ko_humanoid"
}
```

**Design rationale:** Stats scaled to Act I baselines (level 3-7
enemies in bestiary range HP 95-350, ATK 10-22). Compact Patrol is
tanky (higher DEF), Scout is fast (higher SPD). No magic, no
elemental weaknesses — plain foot soldiers. Simple weighted-random AI
(Attack 70%, Defend 30%) — no boss AI function needed.

### D2: Scripted Encounter

The combat is forced (flee disabled, `_is_boss = false` but
`_flee_disabled = true`).

**Formation:** 2x Compact Patrol + 1x Compact Scout

**Trigger:** Area2D in Ironmouth map with metadata:
```
metadata/enemy_ids = ["compact_patrol", "compact_patrol", "compact_scout"]
metadata/flag = "carradan_ambush_survived"
metadata/required_flag = "ironmouth_sable_seen"
metadata/is_boss = true
```

**Note on flee disable:** The current battle system uses `_is_boss`
to disable the flee command (see `battle_manager.gd` line 143).
Setting `is_boss = true` on the encounter metadata is the simplest
way to disable flee. This is technically not a boss fight, but the
flag serves double duty as "flee disabled." No new metadata fields
needed. The enemies use standard weighted-random AI, not boss AI
routing — the `_is_boss` flag only affects flee and the boss
victory/defeat flow.

After victory:
1. `carradan_ambush_survived` flag set
2. `_check_party_joining_flags()` fires → Lira+Sable join
3. Post-combat dialogue: quick beat about fleeing into the Wilds
4. Exit transition to overworld

### D3: Tests

- `compact_patrol` and `compact_scout` load from act_i.json
- Enemy stats match spec values (HP, ATK, DEF, SPD, etc.)
- Formation is 2 Patrol + 1 Scout
- Flee is disabled
- Victory sets `carradan_ambush_survived`
- Lira+Sable join party after flag
- XP and gold awarded correctly

---

## Exploration.gd Entity Wiring Summary

New entity types added to `_initialize_entities()`:

| Entity | Detection Signal | Metadata | Initialize Args |
|--------|-----------------|----------|----------------|
| PressurePlate | `plate_pressed` | `plate_id`, `dungeon_id` | `(plate_id, dungeon_id)` |
| EmberCrystal | `crystal_cleared` | `crystal_id`, `dungeon_id` | `(crystal_id, dungeon_id)` |
| PitfallZone | `pitfall_triggered` | `target_map_id`, `target_spawn` | `(target_map_id, target_spawn)` |

Signal handlers:
- `_on_plate_pressed(plate_id)` → refresh all WaterZones
- `_on_crystal_cleared(crystal_id)` → optional SFX/flash
- `_on_pitfall_triggered(map_id, spawn)` → `load_map(map_id, spawn)`
- `interaction_message` → show via dialogue overlay or notification

---

## Deferred Items (Chunk F — Requires Gap 3.7)

These items are explicitly deferred from Phase B2:

- **Dawn March forward-only walk** — Requires camera control and
  movement restriction not in current exploration system
- **Opening credits title card** — "PENDULUM OF DESPAIR" white text
  on black, center screen
- **Credits overlay** — Names overlay the walk sequence
- **`opening_credits_seen` flag (39)** — Set when credits complete

All require the Cutscene Overlay (gap 3.7) for proper implementation.
Track in `game-dev-gaps.md` under Phase B2 deferred items and as
prerequisites for gap 3.7.

---

## File Inventory

### New Files

| Path | Purpose |
|------|---------|
| `game/scripts/entities/pressure_plate.gd` | One-shot toggle puzzle entity |
| `game/scenes/entities/pressure_plate.tscn` | PressurePlate scene |
| `game/scripts/entities/ember_crystal.gd` | Key item consumer obstacle |
| `game/scenes/entities/ember_crystal.tscn` | EmberCrystal scene |
| `game/scripts/entities/pitfall_zone.gd` | Floor-transition trap |
| `game/scenes/entities/pitfall_zone.tscn` | PitfallZone scene |
| `game/scenes/maps/dungeons/ember_vein_f3.tscn` | F3 Ancient Ruin map |
| `game/scenes/maps/towns/ironmouth_docks.tscn` | Linear escape map |
| `game/data/dialogue/ember_vein_1a_bodies.json` | F1 mid-map miner dialogue |
| `game/data/dialogue/ember_vein_1b_letter.json` | F2 journal + vial dialogue |
| `game/data/dialogue/ember_vein_1c_ruins.json` | F3 entry architecture dialogue |
| `game/data/dialogue/ember_vein_1c_murals.json` | F3 story chamber murals |
| `game/data/dialogue/ember_vein_1d_pendulum.json` | F4 Pendulum discovery (or expand existing) |
| `game/data/dialogue/ember_vein_1e_escape.json` | F4 post-boss escape |
| `game/tests/test_ember_vein_f3.gd` | F3 puzzle + navigation tests |
| `game/tests/test_ironmouth.gd` | Ironmouth sequence tests |
| `game/data/dialogue/ironmouth_lira.json` | Lira introduction dialogue (Scene 3) |
| `game/data/dialogue/ironmouth_sable.json` | Sable introduction dialogue (Scene 3) |
| `game/data/dialogue/ironmouth_post_combat.json` | Post-combat flee-into-Wilds dialogue |
| `game/tests/test_mechanical_tweaks.gd` | Arcanite gear + Cael shimmer + start location tests |

### Modified Files

| Path | Changes |
|------|---------|
| `game/scripts/core/exploration.gd` | Add PressurePlate/EmberCrystal/PitfallZone init + signals |
| `game/scripts/combat/damage_calculator.gd` | Cael 1.1× physical damage multiplier |
| `game/scripts/autoload/party_state.gd` | `break_arcanite_gear()`, arcanite starting equipment |
| `game/data/enemies/act_i.json` | Add compact_patrol, compact_scout |
| `game/data/equipment/weapons.json` | Add arcanite_sword_proto |
| `game/data/equipment/armor.json` | Add arcanite_mail_proto |
| `game/scenes/maps/dungeons/ember_vein_f1.tscn` | new_game_spawn marker, expand 1a dialogue triggers |
| `game/scenes/maps/dungeons/ember_vein_f2.tscn` | Mine Water Vial pickup, from_pitfall spawn, 1b trigger |
| `game/scenes/maps/dungeons/ember_vein_f4.tscn` | Expand 1d/1e triggers, arcanite break |
| `game/scenes/maps/overworld.tscn` | Ironmouth entry point |
| `game/data/dialogue/ember_vein_tutorial.json` | Expand with full 1a beats |
| `game/data/dialogue/ironmouth_escape.json` | Expand with full Scene 3 Lira/Sable dialogue |
| `docs/analysis/game-dev-gaps.md` | Update 4.4 status, add Chunk F deferred items |
