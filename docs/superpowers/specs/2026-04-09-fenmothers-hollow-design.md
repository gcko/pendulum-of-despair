# Fenmother's Hollow — Phase A2 Design Spec

> **Gap:** 4.4 Phase A2 (Fenmother's Hollow)
> **Goal:** Build the second Act I dungeon — 3 floors, 9 enemy types,
> mini-boss, 3-phase boss with wave defense cleansing, 7 treasure chests,
> swamp biome tileset. Combat-focused slice (puzzles deferred).

---

## 1. Scope

### In Scope

- 3 floor maps (F1 Flooded Entry, F2 Submerged Temple, F3 Fenmother's Sanctum)
- 9 enemy JSON files (7 regular + 1 mini-boss + 1 boss)
- 3 dialogue JSON files (boss battle, puzzle flavor, cleansing waves)
- Drowned Sentinel mini-boss (F2, scripted AI)
- Corrupted Fenmother boss (F3, 3-phase with dive/surface + wave defense)
- 7 treasure chests (6 normal + 1 secret room)
- 3 save points (one per floor)
- Overworld entry transition
- Swamp tileset extension (4 tiles)
- Integration tests (~25)
- Encounter table verification (fenmothers_hollow.json already exists)

### Not In Scope (Deferred)

| Item | Reason | Deferred To |
|------|--------|-------------|
| Water wheel puzzle mechanics | Needs interactable puzzle entity system | 4.4 Phase A2b |
| Spirit Vessel carry mechanic | Needs inventory-gated progression system | 4.4 Phase A2b |
| Water level state system | Depends on water wheel mechanics | 4.4 Phase A2b |
| Poisoned pool environmental hazards | Needs tile-based damage zones | 4.4 Phase A2b |
| Ritual meter UI during wave defense | Needs custom HUD element | 4.4 Phase A2b |
| Post-boss spirit-path transition scene | Needs custom linear scene | 4.4 Phase A2b |
| Caden arrival cutscene | Needs cutscene system (gap 3.7) | 3.7 + 4.4 Phase A2b |
| Secret passage to Duskfen | Needs Duskfen map (Act II) | 4.5 |

### Simplifications

- Water wheel interactables become flavor dialogue triggers
  ("Ancient mechanism — already activated. The water has drained.")
- Spirit-plant passage is open by default (flavor text on approach)
- Boss Phase 3 wave defense = 4 sequential encounters after boss
  HP reaches 0, triggered by exploration.gd post-battle logic
- Dive phase = boss untargetable for 2 turns (no pool hazards)
- Torren removed from party during waves via PartyState (not a
  custom battle mechanic — just absent from active formation)

---

## 2. Enemy Data

All values from `docs/story/bestiary/act-i.md`. Every stat must match
exactly — no rounding, no approximation.

### Regular Enemies

| Enemy | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | XP | Weak | Resist | Absorb | Status Immun. | Floors |
|-------|------|----|----|-----|-----|-----|-----|------|-----|------|----|------|--------|--------|---------------|--------|
| Marsh Serpent | Beast | 6 | 140 | 0 | 19 | 10 | 14 | 10 | 12 | 6 | 13 | — | — | — | — | F1-F3 |
| Bog Leech | Beast | 7 | 192 | 0 | 19 | 13 | 15 | 11 | 13 | 7 | 14 | — | — | — | — | F1-F2 |
| Drowned Bones | Undead | 7 | 211 | 24 | 19 | 14 | 15 | 11 | 11 | 7 | 14 | Spirit | — | — | Poison, Death | F1-F2 |
| Swamp Lurker | Beast | 8 | 254 | 0 | 20 | 16 | 17 | 12 | 12 | 13 | 26 | — | — | — | — | F1-F3 |
| Ley Jellyfish | Elemental | 8 | 231 | 28 | 17 | 14 | 19 | 13 | 14 | 13 | 26 | Storm | — | Frost | Petrify | F2-F3 |
| Polluted Elemental | Elemental | 9 | 273 | 31 | 18 | 15 | 20 | 14 | 15 | 13 | 28 | Flame | — | Frost | Petrify | F2-F3 |
| Corrupted Spawn | Beast | 10 | 288 | 0 | 27 | 14 | 20 | 14 | 16 | 15 | 30 | — | — | — | — | F3 (waves only) |

**Note:** Bog Leech and Swamp Lurker have floor ranges but do not appear
in the existing encounter table JSON. They are included as enemy data for
future encounter table expansion (Phase A2b may add them to encounter
groups). Corrupted Spawn appears only in cleansing wave battles.

**Note:** Steal data is included in all enemy JSON files for future use.
The steal command is not yet implemented in battle_manager.gd.

### Steal/Drop Tables

| Enemy | Steal (75%) | Steal (25%) | Drop (25%) |
|-------|-------------|-------------|------------|
| Marsh Serpent | Beast Hide | — | Serpent Fang |
| Bog Leech | Beast Hide | — | Leech Ichor |
| Drowned Bones | Bone Fragment | — | Spirit Dust |
| Swamp Lurker | Beast Hide | — | Lurker Shell |
| Ley Jellyfish | Element Shard | — | Elemental Core |
| Polluted Elemental | Element Shard | — | Elemental Core |
| Corrupted Spawn | Beast Hide | — | Dark Scale |

### Mini-Boss: Drowned Sentinel

| Stat | Value |
|------|-------|
| Type | Construct |
| Level | 10 |
| HP | 4,000 |
| MP | 0 |
| ATK | 24 |
| DEF | 19 |
| MAG | 20 |
| MDEF | 14 |
| SPD | 14 |
| Gold | 250 |
| XP | 50 |
| Weak | Storm |
| Immunities | Poison, Sleep, Confusion, Berserk, Despair |
| Steal | Scrap Metal (75%), Crystal Shard (25%) |
| Drop | Crystal Shard (25%) |

**AI Script (turn-counter based):**

```
Priority (evaluated top-to-bottom each turn):
  1. turn_counter % 4 == 0 → Barnacle Shield (self, DEF +100% for 2 turns)
  2. turn_counter % 3 == 0 → Frost Wave (party AoE, frost magic damage)
  3. Default → Stone Slam (single target, highest threat, heavy physical)
```

### Boss: Corrupted Fenmother

| Stat | Value |
|------|-------|
| Type | Boss |
| Level | 12 |
| HP | 18,000 |
| MP | 42 |
| ATK | 40 |
| DEF | 24 |
| MAG | 39 |
| MDEF | 24 |
| SPD | 20 |
| Gold | 150 |
| XP | 2,500 |
| Weak | Flame |
| Resist | Frost |
| Immunities | Death, Petrify, Stop, Sleep, Confusion |
| Steal | Fenmother's Tear (100%) |
| Drop | Fenmother's Blessing (100%) |

---

## 3. Boss Phases

### Corrupted Fenmother AI (per bosses.md)

Uses dive/surface cycle with turn-counter priority list.

**Surface/dive state machine:**
- Surface for 3 turns, then dive for 2 turns, repeating
- During dive: boss is untargetable, skips actions
  (Simplified from bosses.md: canonical dive spawns poisoned pools,
  deferred to Phase A2b)

### Phase 1: Surface Dominance (18,000–9,001 HP)

```
Priority (evaluated top-to-bottom each surface turn):
  1. turn_counter % 4 == 0 → Tail Sweep (party AoE physical)
  2. turn_counter % 3 == 0 → Water Jet (single target, lowest HP, frost magic)
  3. Default → Tail Sweep (party AoE physical)
```

### Phase 2: Desperate (<=9,000 HP)

Triggered at 50% HP. Dialogue entry "fenmother_battle:002" plays.

```
Priority (evaluated top-to-bottom each surface turn):
  1. active_adds < 2 AND turn_counter % 3 == 0 → Spawn 2x corrupted_spawn
  2. turn_counter % 3 == 0 → Water Jet (single target, lowest HP, frost magic)
  3. turn_counter % 2 == 0 → Tail Sweep (party AoE physical)
  4. Default → Water Jet (single target, lowest HP, frost magic)
```

Note: Adds re-spawn when killed (up to 2 alive at once), per bosses.md.

### Phase 3: Cleansing Waves (0 HP trigger)

**Victory interception in battle_manager.gd:**
In `_check_end_conditions`, before emitting the `victory` signal, check
if the current boss_id is `"corrupted_fenmother"`. If so:
1. Skip the rewards UI (do NOT emit `victory` signal)
2. Distribute XP/gold rewards directly (same code, just skip UI display)
3. Call `_exit_battle("fenmother_cleansing")` directly
4. This bypasses the BattleUI results screen entirely

**Exploration handling of "fenmother_cleansing" result:**
In `_initialize_from_transition_data`, add `elif r == "fenmother_cleansing"`:

1. Distribute battle rewards (XP/gold from transition_data, same as victory)
2. Store wave state in `GameManager.transition_data`:
   - `wave_num`: current wave (0-3), incremented after each wave
   - `return_map_id`: "dungeons/fenmothers_hollow_f3"
   - `return_position`: player position before boss fight
3. Play dialogue from fenmother_cleansing.json (entry matching wave_num)
4. Move Torren from active to reserve formation (PartyState.formation)
5. Start next wave battle via `GameManager.change_core_state(BATTLE, wave_data)`
   with `encounter_group` set to the wave's enemy list

**Wave compositions:**

| Wave | Enemies | encounter_group |
|------|---------|-----------------|
| 1 | "The Poison Breaks" | ["marsh_serpent","marsh_serpent","marsh_serpent","marsh_serpent","polluted_elemental","polluted_elemental"] |
| 2 | "She Remembers" | ["ley_jellyfish","ley_jellyfish","ley_jellyfish","drowned_bones","drowned_bones","drowned_bones","polluted_elemental"] |
| 3 | "The Last Resistance" | ["polluted_elemental","polluted_elemental","marsh_serpent","marsh_serpent","marsh_serpent","marsh_serpent","ley_jellyfish","ley_jellyfish"] |
| 4 | "Release" | ["corrupted_spawn","corrupted_spawn","corrupted_spawn"] |

**Wave return handling:**
Each wave battle returns `result: "victory"` (normal battle). Exploration
detects `wave_num` in transition_data and:
- If wave_num < 3: increment wave_num, play next dialogue, start next wave
- If wave_num == 3 (after Wave 4): complete the cleansing sequence

**Between waves:** Party members at 0 HP are revived at 25% max HP
(per bosses.md). Applied in exploration before starting next wave.

**After Wave 4:**
- Torren moved back to active formation
- Flag `fenmother_cleansed` set
- Boss flag set (prevents re-trigger)
- Final dialogue plays: "Light floods the hollow..."
- Load F3 map, player at boss arena position
- Chest 6 (Fenmother's Blessing) becomes accessible

**Torren handling:** Torren is moved from `formation.active` to
`formation.reserve` before waves, and back after. No new PartyState
API needed — just array manipulation on the existing formation dict.

---

## 4. Floor Layouts

### F1: Flooded Entry (45x30 tiles)

```
Metadata:
  map_id: "dungeons/fenmothers_hollow_f1"
  dungeon_id: "fenmothers_hollow"
  floor_id: "1-2"
  location_name: "Fenmother's Hollow - Flooded Entry"

Entities:
  - SavePoint "fenmothers_hollow_f1_save" at (~64, ~48) — spirit-totem, flickering
  - Chest at (~640, ~96):
    - chest_id: "fenmothers_hollow_marsh_cloak"
    - item_id: "marsh_cloak"
  - Chest at (~320, ~400):
    - chest_id: "fenmothers_hollow_spirit_tonic"
    - item_id: "spirit_tonic"
    - Note: gives 1 spirit_tonic (exploration.gd hardcodes qty 1)
  - DialogueTrigger "water_wheel" at (~192, ~256)
    - dialogue_scene_id: "water_of_life"
    - flag: "fenmothers_hollow_wheel_seen"
    - No required_flag (optional flavor)

Transitions:
  - Entry from overworld: PlayerSpawn at (~48, ~48)
  - To F2: stairway at (~352, ~448), target_map "dungeons/fenmothers_hollow_f2"

Encounters:
  - floor_id "1-2" from fenmothers_hollow.json
```

### F2: Submerged Temple (50x35 tiles)

```
Metadata:
  map_id: "dungeons/fenmothers_hollow_f2"
  dungeon_id: "fenmothers_hollow"
  floor_id: "1-2"
  location_name: "Fenmother's Hollow - Submerged Temple"

Entities:
  - SavePoint "fenmothers_hollow_f2_save" at (~400, ~272) — stronger glow
  - Chest at (~96, ~320):
    - chest_id: "fenmothers_hollow_fenmothers_scale"
    - item_id: "fenmothers_scale"
  - Chest at (~640, ~192):
    - chest_id: "fenmothers_hollow_spirit_bound_spear"
    - item_id: "spirit_bound_spear"
    - Note: Equipment item (Torren weapon), given via add_item for now.
      Equipment chests need future add_equipment support.
  - Chest at (~96, ~64):
    - chest_id: "fenmothers_hollow_ancient_totem"
    - item_id: "ancient_totem"
    - Note: Secret room in NW corner
  - DialogueTrigger "spirit_plant" at (~544, ~160)
    - dialogue_scene_id: "water_of_life"
    - flag: "fenmothers_hollow_plant_seen"
    - No required_flag
  - BossTrigger "drowned_sentinel" at (~544, ~320)
    - boss_id: "drowned_sentinel"
    - flag: "drowned_sentinel_defeated"
    - enemy_ids: ["drowned_sentinel"]
    - enemy_act: "act_i"

Transitions:
  - From F1: PlayerSpawn "from_f1" at (~352, ~48)
  - To F1: stairway at (~352, ~48), target_map "dungeons/fenmothers_hollow_f1"
  - To F3: passage at (~544, ~528), target_map "dungeons/fenmothers_hollow_f3"
    - required: drowned_sentinel_defeated (passage blocked until mini-boss cleared)
    Note: This is a transition Area2D with required_flag metadata, checked
    in _on_transition_body_entered. Needs small exploration.gd change to
    support required_flag on transitions (currently only dialogue triggers
    support required_flag).

Encounters:
  - floor_id "1-2" from fenmothers_hollow.json (shared with F1)
```

### F3: Fenmother's Sanctum (35x25 tiles)

```
Metadata:
  map_id: "dungeons/fenmothers_hollow_f3"
  dungeon_id: "fenmothers_hollow"
  floor_id: "3"
  location_name: "Fenmother's Hollow - Sanctum"

Entities:
  - SavePoint "fenmothers_hollow_f3_save" at (~272, ~96) — fierce glow
  - BossTrigger "corrupted_fenmother" at (~272, ~208)
    - boss_id: "corrupted_fenmother"
    - flag: "fenmother_cleansed"
    - enemy_ids: ["corrupted_fenmother"]
    - enemy_act: "act_i"
  - Chest "fenmothers_blessing" at (~272, ~304)
    - item_id: "fenmothers_blessing"
    - chest_id: "fenmothers_hollow_blessing"
    - Note: Only accessible after fenmother_cleansed flag set
    - Needs flag-gated chest support (check flag before allowing open)

Transitions:
  - From F2: PlayerSpawn "from_f2" at (~272, ~48)
  - To F2: passage at (~272, ~48), target_map "dungeons/fenmothers_hollow_f2"
  - Exit to overworld: at (~272, ~368), target_map "overworld", target_spawn "from_fenmothers_hollow"

Encounters:
  - floor_id "3" from fenmothers_hollow.json
```

---

## 5. Overworld Changes

Add to `game/scenes/maps/overworld.tscn`:

- Transition trigger "FenmothersHollow" in Transitions group
  - Position: (~336, ~528) — south of Roothollow, in Thornmere Wilds area
  - target_map: "dungeons/fenmothers_hollow_f1"
  - target_spawn: "from_overworld"
  - Collision shape 48x48 (consistent with other transitions)
- Label "LabelFenmothersHollow" — "Fenmother's Hollow"
  - Position near transition trigger
- Spawn marker "from_fenmothers_hollow" for return

---

## 6. Dialogue Data

### fenmother_battle.json

4 entries for boss battle phases:
1. Phase 1 start: "The water surges..."
2. Mid-battle: "The Fenmother shrieks..."
3. At 50% HP: "The corruption recedes from her eyes..."
4. Phase 3/Victory: "The grey drains from the water..."

Speaker: narrator for all entries (environmental descriptions).

### water_of_life.json

4 entries for puzzle flavor text:
1. Torren: "This is old water. Older than the Compact..."
2. Lira: "The extraction pipes from the Compact's upriver station..."
3. Sable: "That's a nice bowl. We taking it?"
4. Torren: "It's a sacred vessel. We're borrowing it."

### fenmother_cleansing.json

5 entries for wave transitions:
1. Pre-wave: "The Fenmother collapses. Torren steps forward..."
2. After Wave 1: "Dark streaks peel from the Fenmother's flanks..."
3. After Wave 2: "She's fighting it. She's trying to help."
4. After Wave 3: "The corruption recedes nearly completely..."
5. After Wave 4: "Light floods the hollow. The Fenmother opens her eyes..."

---

## 7. Exploration Changes

### Flag-gated transitions

`_on_transition_body_entered` currently does not check `required_flag`.
Add support: if a transition Area2D has `required_flag` metadata and the
flag is not set, block the transition (silent — no error, player just
can't pass).

```gdscript
# In _on_transition_body_entered:
var req_flag: String = area.get_meta("required_flag", "")
if not req_flag.is_empty() and not EventFlags.get_flag(req_flag):
    return
```

### Flag-gated chests

Chest entities currently don't check flags. The Fenmother's Blessing
chest should only be openable after `fenmother_cleansed` is set.
Add optional `required_flag` metadata support to chest interaction:

```gdscript
# In chest interact():
var req: String = get_meta("required_flag", "")
if not req.is_empty() and not EventFlags.get_flag(req):
    return  # chest stays locked
```

### Cleansing wave sequence

After battle returns with `result: "fenmother_cleansing"`:

```gdscript
# In _initialize_from_transition_data, after handling "victory":
elif r == "fenmother_cleansing":
    # Play dialogue, then trigger wave battles sequentially
    var wave_num: int = data.get("wave_num", 0)
    if wave_num < 4:
        _start_cleansing_wave(wave_num, data)
    else:
        _complete_cleansing(data)
```

This reuses the existing battle entry/return loop. Each wave returns
to exploration, which checks wave_num and either starts the next wave
or completes the sequence.

---

## 8. Battle Manager Changes

Add boss AI for both bosses in `battle_manager.gd`, following the
existing Vein Guardian pattern (hardcoded, turn-counter based).

### Drowned Sentinel AI

```
func _drowned_sentinel_action(turn: int) -> Dictionary:
    if turn % 4 == 0:
        return {"action": "ability", "name": "Barnacle Shield",
                "target": "self", "effect": "def_up_100_2turns"}
    if turn % 3 == 0:
        return {"action": "magic", "name": "Frost Wave",
                "target": "party", "element": "frost"}
    return {"action": "attack", "target": "front_highest_atk"}
```

### Corrupted Fenmother AI

Track phase via HP thresholds and surface/dive counter:

```
var _fenmother_surface_count: int = 0
var _fenmother_diving: bool = false
var _fenmother_phase: int = 1
var _fenmother_spawned_adds: bool = false

func _corrupted_fenmother_action(turn: int) -> Dictionary:
    # Phase transition at 50%
    if not _fenmother_spawned_adds and current_hp <= 9000:
        _fenmother_phase = 2
        _fenmother_spawned_adds = true
        return {"action": "spawn", "enemies": ["corrupted_spawn", "corrupted_spawn"],
                "dialogue": "fenmother_battle:002"}

    # Dive/surface cycle
    if _fenmother_diving:
        _fenmother_surface_count += 1
        if _fenmother_surface_count >= 2:
            _fenmother_diving = false
            _fenmother_surface_count = 0
        return {"action": "skip"}  # untargetable during dive

    _fenmother_surface_count += 1
    if _fenmother_surface_count >= 3:
        _fenmother_diving = true
        _fenmother_surface_count = 0
        return {"action": "dive"}  # become untargetable

    # Surface actions
    if _fenmother_phase == 1:
        if turn % 2 == 0:
            return {"action": "ability", "name": "Tail Sweep",
                    "target": "party", "type": "physical_aoe"}
        return {"action": "magic", "name": "Water Jet",
                "target": "single", "element": "frost"}
    else:  # Phase 2 — both attacks
        return {"action": "multi", "actions": [
            {"name": "Tail Sweep", "target": "party", "type": "physical_aoe"},
            {"name": "Water Jet", "target": "single", "element": "frost"}
        ]}
```

Boss reaching 0 HP: battle_manager detects boss_id == "corrupted_fenmother"
and returns `result: "fenmother_cleansing"` instead of `result: "victory"`.

---

## 9. Tileset Extension

Add 4 swamp tiles to the existing placeholder tileset:

| Tile | Color | Purpose |
|------|-------|---------|
| Marsh floor | Dark green (#2d4a2e) | Walkable ground |
| Shallow water | Dark teal (#1a3a3a) | Walkable, encounter area |
| Stone wall | Dark grey-brown (#3a3a2e) | Collision, walls |
| Crystal root | Purple-teal (#4a2a5a) | Decorative, ley-corruption |

Same approach as Ember Vein: 16x16 solid-color tiles in the
placeholder dungeon tileset. No art assets needed.

---

## 10. Encounter Table Verification

`game/data/encounters/fenmothers_hollow.json` already exists.
Verify it matches the design doc:

**Floors 1-2 (Danger Tier 2, increment 120):**

| Group | Enemies | Weight |
|-------|---------|--------|
| 1 | 3x marsh_serpent | 31.25% |
| 2 | 2x marsh_serpent + 1x drowned_bones | 31.25% |
| 3 | 2x drowned_bones | 31.25% |
| 4 | 1x drowned_bones + 3x marsh_serpent | 6.25% |

**Floor 3 (Danger Tier 3, increment 252):**

| Group | Enemies | Weight |
|-------|---------|--------|
| 1 | 2x ley_jellyfish + 1x marsh_serpent | 31.25% |
| 2 | 1x polluted_elemental + 2x marsh_serpent | 31.25% |
| 3 | 2x marsh_serpent + 1x ley_jellyfish | 31.25% |
| 4 | 1x polluted_elemental + 2x ley_jellyfish | 6.25% |

Formation distribution: 68.75% Normal, 18.75% Back Attack, 12.5% Preemptive.

---

## 11. Test Plan

### test_fenmothers_hollow.gd (~25 tests)

**Enemy data (9 tests):**
- Each of the 9 enemy JSON files loads and has correct HP value

**Dialogue data (3 tests):**
- fenmother_battle.json loads with 4 entries
- water_of_life.json loads with 4 entries
- fenmother_cleansing.json loads with 5 entries

**Floor maps (3 tests):**
- Each .tscn has correct metadata (map_id, dungeon_id, floor_id, location_name)

**Overworld (2 tests):**
- FenmothersHollow transition exists with correct target_map
- from_fenmothers_hollow spawn marker exists

**Treasure chests (3 tests):**
- F1 has 2 chests with correct item_ids
- F2 has 3 chests with correct item_ids
- F3 has 1 chest (Fenmother's Blessing) with required_flag

**Boss triggers (2 tests):**
- F2 has Drowned Sentinel trigger with correct metadata
- F3 has Corrupted Fenmother trigger with correct metadata

**Save points (1 test):**
- Each floor has at least one save point entity

**Transitions (2 tests):**
- F1→F2 and F2→F3 transitions exist
- F2→F3 transition has required_flag "drowned_sentinel_defeated"

---

## 12. File Map

| File | Action | Description |
|------|--------|-------------|
| `game/data/enemies/marsh_serpent.json` | CREATE | Regular enemy |
| `game/data/enemies/bog_leech.json` | CREATE | Regular enemy |
| `game/data/enemies/drowned_bones.json` | CREATE | Regular enemy |
| `game/data/enemies/swamp_lurker.json` | CREATE | Regular enemy |
| `game/data/enemies/ley_jellyfish.json` | CREATE | Regular enemy |
| `game/data/enemies/polluted_elemental.json` | CREATE | Regular enemy |
| `game/data/enemies/corrupted_spawn.json` | CREATE | Regular enemy |
| `game/data/enemies/drowned_sentinel.json` | CREATE | Mini-boss |
| `game/data/enemies/corrupted_fenmother.json` | CREATE | Boss |
| `game/data/dialogue/fenmother_battle.json` | CREATE | Boss dialogue |
| `game/data/dialogue/water_of_life.json` | CREATE | Puzzle flavor |
| `game/data/dialogue/fenmother_cleansing.json` | CREATE | Wave dialogue |
| `game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn` | CREATE | Floor 1 |
| `game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn` | CREATE | Floor 2 |
| `game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn` | CREATE | Floor 3 |
| `game/tests/test_fenmothers_hollow.gd` | CREATE | Tests |
| `game/scenes/maps/overworld.tscn` | MODIFY | Add entry transition |
| `game/scripts/core/exploration.gd` | MODIFY | Flag-gated transitions, cleansing waves |
| `game/scripts/combat/battle_manager.gd` | MODIFY | Boss AI for both bosses |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update Phase A2 status |

---

## 13. Deferred Work (Phase A2b)

Explicitly tracked for future implementation:

- [ ] Water wheel puzzle entities (3 wheels, HIGH/LOW state per wheel)
- [ ] Spirit Vessel key item + carry mechanic
- [ ] Pure Spring interactable (fill vessel)
- [ ] Spirit-plant revival interactable (pour vessel)
- [ ] Water level zone visibility toggling
- [ ] Poisoned pool tile damage zones (boss dive phase)
- [ ] Ritual meter HUD element (wave defense progress bar)
- [ ] Post-boss spirit-path linear transition scene
- [ ] Caden NPC arrival cutscene (needs gap 3.7)
- [ ] Secret passage to Duskfen (needs Act II maps)
- [ ] Fenmother's Tear steal item (needs steal system in battle)
- [ ] Torren Spirit-Bound Spear ability unlock (needs ability system extension)
