# 4.4 Phase C: Valdris Capital Completion

> **Gap:** 4.4 Phase C (Capital Completion)
> **Priority:** P1
> **Status:** Design spec
> **Date:** 2026-04-19
> **Depends On:** 4.1, 4.2, 4.3 (all MOSTLY COMPLETE)
> **Blocks:** 4.5 (Acts II-IV), Act I finale

## Overview

Complete Valdris Crown as a fully explorable capital city. Build 3 new
outdoor district maps, 4 new interior maps, the Scene 7 narrative
sequence (FF6 Vector banquet-style free-roam with required NPC
conversations), and the Act I finale flag (`pendulum_to_capital`).

Design docs are law. Every NPC name, shop price, flag name, and
dialogue line traces to `docs/story/`.

## Source Documents

| Document | Governs |
|----------|---------|
| `city-valdris.md` | District layouts, buildings, NPCs, shops, save points, treasure |
| `interiors.md` | Throne hall, library, tavern upper floor tile layouts |
| `script/act-i.md` Scene 7 | Gate arrival, throne presentation, court free-roam, evening scene |
| `events.md` | Act I flags, `pendulum_to_capital` (flag 6) |
| `npcs.md` | NPC roles, dialogue, presence per act |
| `economy.md` | Shop inventories, prices |
| `dialogue-system.md` | Dialogue entry format, condition expressions |

---

## 1. New Maps

### 1.1 Outdoor Districts

All outdoor districts use the existing `placeholder_dungeon.tres`
tileset extended with 2-4 new tile indices for capital-specific
surfaces. All tiles are 16x16 placeholder colored squares. Map
dimensions are gameplay-driven (sized to content + ~30% breathing
room), not design-doc literal. Real tilesets will fill the space later.

#### `valdris_citizens_walk.tscn` (~45x40 tiles)

The commercial and intellectual heart of Valdris. Connects south to
Lower Ward via stone ramp, north to Court Quarter, east to Eastern Wall
(transition blocked — deferred to gap 4.5).

**Buildings (exterior shells with door transitions):**
- Armor Shop (AS) — door to: none (NPC outside, shop overlay)
- Jeweler & Accessory Shop (JS) — door to: none (NPC outside)
- Specialty Goods (SG) — door to: none (NPC outside)
- Royal Library (RL) — door to: `valdris_royal_library.tscn`
- Guild of Cartographers (GC) — examinable sign only (flavor)
- Notice Board — examinable ("Local news and court announcements.")

**NPCs:**
- Armorsmith (`npc_valdris_armorsmith`, shop: `valdris_crown_armorsmith`)
- Jeweler (`npc_valdris_jeweler`, shop: `valdris_crown_jeweler`)
- Specialty Merchant (`npc_valdris_specialty`, shop: `valdris_crown_specialty`)
- Jorin Ashvale (`npc_jorin_ashvale`, flavor NPC)
- Scholar Aldis (`npc_scholar_aldis`, exterior position — points player to library)

**Transitions:**
- South ramp → `towns/valdris_lower_ward` (spawn: `from_citizens_walk`)
- North road → `towns/valdris_court_quarter` (spawn: `from_citizens_walk`)
- Library door → `towns/valdris_royal_library` (spawn: `from_exterior`)
- East gate → BLOCKED (placeholder wall, deferred to gap 4.5)

**Spawn points:** `PlayerSpawn`, `from_lower_ward`, `from_court_quarter`,
`from_library`

#### `valdris_court_quarter.tscn` (~35x30 tiles)

The political center. Quieter, more ornate. Connects south to
Citizen's Walk, north to Royal Keep (throne hall entrance).

**Buildings (exterior shells only — interiors deferred):**
- Court Mage Tower (CMT) — exterior with Elara Thane NPC
- Haren's Estate (HE) — exterior, door blocked ("Private residence.")
- Council Chambers (CC) — exterior, door blocked ("Council in session.")
- Walled Garden — decorative area with ley-lamp

**NPCs:**
- Elara Thane (`npc_elara_thane`, flavor — wind pact dialogue)
- Court Guard (`npc_court_guard`, flavor — patrol route area)

**Transitions:**
- South road → `towns/valdris_citizens_walk` (spawn: `from_court_quarter`)
- North entrance → `towns/valdris_throne_hall` (spawn: `from_court_quarter`)

**Spawn points:** `PlayerSpawn`, `from_citizens_walk`, `from_throne_hall`

#### Lower Ward Updates (`valdris_lower_ward.tscn`)

Existing map needs modifications:
- Add north transition → `towns/valdris_citizens_walk` (spawn: `from_lower_ward`)
- Add `from_citizens_walk` spawn Marker2D
- Rename weaponsmith shop_id from `valdris_crown_armorer` to `valdris_crown_weaponsmith`
- Add `from_barracks` spawn Marker2D
- Add barracks door transition → `towns/valdris_barracks` (spawn: `from_exterior`)

### 1.2 Interior Maps

#### `valdris_throne_hall.tscn` (~20x18 tiles)

Per interiors.md Section 1.1. The largest interior in Valdris.

**Layout:**
- Raised platform (2 tiles deep, full width) with throne at center
- Red carpet runner from grand double doors (6 tiles wide) to platform
- Six limestone columns per side forming colonnade
- Ley-lamp brackets between columns
- Stained glass window behind throne (examinable)
- Heraldic banners (examinable)

**NPCs:**
- King Aldren (`npc_king_aldren`, on throne platform)
- Lord Chancellor Haren (`npc_lord_haren`, left of throne)

**Transitions:**
- Grand doors → `towns/valdris_court_quarter` (spawn: `from_throne_hall`)

**Spawn points:** `PlayerSpawn`, `from_court_quarter`

**Scene 7b trigger:** Area2D at throne approach (flag-gated: requires
`valdris_arrived`, blocks if `pendulum_presented` already set).

#### `valdris_royal_library.tscn` (~16x14 tiles)

Per interiors.md Section 1.2. Main hall only — stacks wing and basement
archive deferred to Act II (quest-gated content).

**Layout:**
- Floor-to-ceiling bookshelves lining walls
- Study alcove with save point (left wall)
- Reading table with globe and card catalog
- Interior doorway (east wall) — blocked ("Restricted section.")

**NPCs:**
- Scholar Aldis (`npc_scholar_aldis`, at reading table)
- Mirren (`npc_mirren`, near restricted doorway)

**Save point:** `valdris_library_save` (study alcove)

**Transitions:**
- Front door → `towns/valdris_citizens_walk` (spawn: `from_library`)

**Spawn points:** `PlayerSpawn`, `from_exterior`

#### `valdris_barracks.tscn` (~14x12 tiles)

No Valdris-specific layout in interiors.md. Based on general military
template with Valdris limestone aesthetic.

**Layout:**
- Weapon racks along walls (examinable)
- Training post (examinable — "Cael's name is carved into the wood.")
- Bunk beds (4 sets)
- Map table with border patrol routes

**NPCs:**
- Dame Cordwyn (`npc_dame_cordwyn`, near map table)
- Sgt. Marek (`npc_sergeant_marek`, near training post)

**Transitions:**
- Front door → `towns/valdris_lower_ward` (spawn: `from_barracks`)

**Spawn points:** `PlayerSpawn`, `from_exterior`

#### `valdris_anchor_oar_upper.tscn` (~12x10 tiles)

Per interiors.md Section 3.3 upper floor.

**Layout:**
- Three guest rooms separated by oak panel walls
- Player's room: NW corner (bed + ley-lamp)
- Two other rooms (beds + ley-lamps)
- Staircase down (SS) in SE area

**Transitions:**
- Staircase → `towns/valdris_anchor_oar` (spawn: `from_upstairs`)

**Spawn points:** `PlayerSpawn`, `from_downstairs`

**Note:** `valdris_anchor_oar.tscn` needs a matching staircase
transition and `from_upstairs`/`from_downstairs` spawn points added.

---

## 2. Shop Data Changes

### 2.1 Split armorer shop

Current `valdris_crown_armorer.json` has both weapons and armor. Per
city-valdris.md, weapons are sold in the Lower Ward and armor in
Citizen's Walk.

**`valdris_crown_weaponsmith.json` (rename from armorer):**
Keep only weapon items. Update shop_id to `valdris_crown_weaponsmith`.

**`valdris_crown_armorsmith.json` (new):**
Armor items extracted from the current armorer file. New shop_id.

### 2.2 New shop files

**`valdris_crown_jeweler.json`:**
Per city-valdris.md jeweler inventory:

| Item | Price | Notes |
|------|-------|-------|
| Pact-Charm (Storm) | 600 | +5% Storm resist, AGI +2 |
| Pact-Charm (Earth) | 600 | +5% Earth resist, DEF +2 |
| Silver Ring | 200 | MAG +3 |
| Guardian Pendant | 400 | Auto-Protect at <25% HP |

Cross-reference: every item_id must exist in `equipment/accessories.json`.
If any are missing, create them with stats matching city-valdris.md.

**`valdris_crown_specialty.json`:** Already exists with 7 items. Verify
prices match city-valdris.md. Place NPC in Citizen's Walk.

### 2.3 Lower Ward NPC update

The Lower Ward `Weaponsmith` NPC metadata changes:
- `shop_id`: `valdris_crown_armorer` → `valdris_crown_weaponsmith`
- `npc_id`: `valdris_weaponsmith` → `valdris_weaponsmith` (unchanged)

---

## 3. Scene 7: The Capital

### 3.1 Trigger Prerequisites

Scene 7 requires flag `maren_warning` (flag 5) — the party has all 6
members and has examined the Pendulum at Maren's Refuge. The player
arrives at Valdris from the overworld.

### 3.2 Scene 7a: The Gates

**Trigger:** Overworld → Valdris South Gate transition, with
`maren_warning` flag set and `valdris_arrived` NOT set.

**Implementation:** Dialogue trigger Area2D in `valdris_lower_ward.tscn`
near the South Gate spawn, with `metadata/required_flag = "maren_warning"`
and `metadata/dialogue_scene_id = "scene_7a_the_gates"`.

**Dialogue file:** `game/data/dialogue/scene_7a_the_gates.json`
- Gate guard recognizes Edren
- Guard eyes the party (per script/act-i.md)
- Sable: "Of course. I love registering."
- Sets flag: `valdris_arrived`

**After dialogue:** Player has free movement in Lower Ward. Sgt. Marek
(or the gate guard, if a new temporary NPC is too heavy) has a
one-line hint gated by `valdris_arrived` and `!pendulum_presented`:
"The king is expecting you in the Keep. Head north through the
districts." This uses standard NPC priority-stack conditions.

### 3.3 Scene 7b: Throne Hall Presentation

**Trigger:** Player enters throne hall with `valdris_arrived` set and
`pendulum_presented` NOT set. Area2D trigger near the throne approach.

**Dialogue file:** `game/data/dialogue/scene_7b_throne_hall.json`
- King Aldren on stone chair, Haren to his left
- Edren presents the Pendulum
- Maren warns about the conduit
- Haren/Maren tension ("You've been away from court for some time.")
- Aldren's ley line report: "Every morning I ask the court mages..."
- Orders: Maren — assessment by morning. Cael — assigned to work with Maren.
- Sets flag: `pendulum_presented`

**After dialogue:** Player has free movement across all Valdris districts.
Scene 7c NPC dialogues are now active (gated by `pendulum_presented`).

### 3.4 Scene 7c: The Court (Free-Roam)

FF6 Vector banquet model. Player freely explores all Valdris districts.
Three required NPC conversations gate progression to 7d.

**Required conversations:**

1. **Scholar Aldis** (Royal Library interior)
   - `dialogue_scene_id`: `scene_7c_aldis`
   - 12% ley line capacity loss report
   - Conditional: `party_has(lira)` — Aldis recognizes suppressed paper
   - Conditional: `party_has(maren)` — "Maren? You're... back?"
   - Sets flag: `scene_7c_aldis`

2. **Dame Cordwyn** (Barracks interior)
   - `dialogue_scene_id`: `scene_7c_cordwyn`
   - Haren planning to use Pendulum as bargaining chip
   - Warning: "keep an eye on Cael"
   - Conditional: `party_has(torren)` — "Spirit-speaker. You're a long way from the Wilds."
   - Conditional: `party_has(sable)` — "Touch nothing, thief."
   - Sets flag: `scene_7c_cordwyn`

3. **Renn** (Anchor & Oar, existing interior)
   - `dialogue_scene_id`: `scene_7c_renn`
   - Sable peels off, enters with "practiced familiarity"
   - Compact intel: something unexpected in the mine, 3 courier birds
   - "Whatever you've gotten yourself into, Sable -- it's bigger than a mine."
   - Sets flag: `scene_7c_renn`

**NPC dialogue gating:** These three NPCs show their Scene 7c dialogue
ONLY when `pendulum_presented` is set AND their respective `scene_7c_*`
flag is NOT set. After their flag is set, they revert to ambient
dialogue. This uses the existing priority-stack condition system in
`npc.gd`.

**All other NPCs** in Valdris show their standard ambient Act I
dialogue during this phase. No special gating needed.

### 3.5 Scene 7d: Evening

**Trigger:** Player enters the throne hall with ALL THREE flags set:
`scene_7c_aldis`, `scene_7c_cordwyn`, `scene_7c_renn`, AND
`pendulum_presented`. The throne hall is the natural return point —
the player reports back to the king. Area2D trigger near the entrance
with multi-flag AND condition.

**Implementation:** This uses the cutscene overlay (gap 3.7, COMPLETE).
T1 cutscene with letterbox bars.

**Cutscene file:** `game/data/dialogue/scene_7d_evening.json`
- Night. Pendulum in sealed chamber, containment wards glowing blue.
- Cael stands alone, hand hovering near glass case.
- Single-frame grey eyes flicker on Cael's reflection.
- Cael leaves. Pendulum needle shifts one degree.
- Sets flag: `pendulum_to_capital` (flag 6)

**After cutscene:** Act I is complete. Game state transitions to Act II
(handled by GameManager when `pendulum_to_capital` is set). For now,
the player returns to free-roam in Valdris with Act I ambient dialogue.
Act II content is deferred to gap 4.5.

### 3.6 New Event Flags

| Flag | Set By | Purpose |
|------|--------|---------|
| `valdris_arrived` | Scene 7a dialogue completion | Gates 7b trigger |
| `pendulum_presented` | Scene 7b dialogue completion | Gates 7c NPC dialogues |
| `scene_7c_aldis` | Aldis conversation | Tracks 7c progress |
| `scene_7c_cordwyn` | Cordwyn conversation | Tracks 7c progress |
| `scene_7c_renn` | Renn conversation | Tracks 7c progress |
| `pendulum_to_capital` | Scene 7d cutscene | Act I complete (flag 6) |

---

## 4. Dialogue Data

### 4.1 Scene Dialogue Files (new)

| File | Entries (est.) | Source |
|------|---------------|--------|
| `scene_7a_the_gates.json` | 8-10 | script/act-i.md Scene 7a |
| `scene_7b_throne_hall.json` | 12-15 | script/act-i.md Scene 7b |
| `scene_7c_aldis.json` | 8-12 | script/act-i.md Scene 7c (Aldis) |
| `scene_7c_cordwyn.json` | 8-12 | script/act-i.md Scene 7c (Cordwyn) |
| `scene_7c_renn.json` | 8-12 | script/act-i.md Scene 7c (Renn) |
| `scene_7d_evening.json` | 6-8 | script/act-i.md Scene 7d (cutscene) |

### 4.2 NPC Ambient Dialogue Files (new)

| File | Entries (est.) | Source |
|------|---------------|--------|
| `npc_king_aldren.json` | 2-3 | npcs.md |
| `npc_lord_haren.json` | 2-3 | npcs.md |
| `npc_dame_cordwyn.json` | 3-4 | npcs.md (ambient + conditional) |
| `npc_scholar_aldis.json` | 3-4 | npcs.md (ambient + conditional) |
| `npc_mirren.json` | 2-3 | npcs.md |
| `npc_elara_thane.json` | 2-3 | npcs.md |
| `npc_jorin_ashvale.json` | 2-3 | npcs.md |
| `npc_valdris_armorsmith.json` | 1 | shop greeting |
| `npc_valdris_jeweler.json` | 1 | shop greeting |
| `npc_valdris_specialty.json` | 1 | shop greeting |
| `npc_court_guard.json` | 1-2 | flavor |

### 4.3 Dialogue Conditions

Scene 7c dialogues use the existing NPC priority-stack condition system:
- `pendulum_presented == true` AND `scene_7c_aldis == false` → show
  Scene 7c Aldis dialogue
- Otherwise → show ambient dialogue

The `party_has()` conditional branches within Scene 7c entries use the
existing condition evaluator in `npc.gd` (stubbed — returns false until
GameManager.party exists). Since PartyState tracks party members and
the party is always full by Scene 7, we need to verify `party_has()`
works with PartyState. If it's still stubbed, wire it to
`PartyState.has_member()`.

---

## 5. Treasure Chests

| Location | Item | item_id | Notes |
|----------|------|---------|-------|
| Behind Barracks (Lower Ward) | Phoenix Pinion | `phoenix_pinion` | Hidden by building shadow |
| Royal Library stacks area | Spirit Incense | `spirit_incense` | Near restricted doorway |

Cross-reference: verify both item_ids exist in `items/consumables.json`.

---

## 6. Tileset Extension

Extend `placeholder_dungeon.png` with 2-4 new 16x16 tiles:

| Index | Color | Purpose |
|-------|-------|---------|
| 14 | Light tan | Pale limestone floor (capital) |
| 15 | Dark red | Carpet / throne room runner |
| 16 | Light grey | Raised stone platform |
| 17 | Gold/yellow | Decorative accent (columns, trim) |

Add physics collision to index 17 (columns are impassable). Update
`placeholder_dungeon.tres` atlas to include new tiles.

---

## 7. Deferred Items

The following are explicitly OUT OF SCOPE for Phase C. Each must be
captured as a deferred item in `docs/analysis/game-dev-gaps.md` under
gap 4.5 or a new sub-gap.

### Deferred Districts
- **Eastern Wall & Battlements (District E):** Act II siege breach
  location. 1 treasure chest (Whetstone). No Act I gameplay purpose.
- **Tower Tutorial (District F):** Seven Towers magic tutorial
  mini-dungeon. 3 floors each, ley line puzzles. Separate system gap.

### Deferred Interiors
- Chapel of the Old Pacts interior (exterior save point works)
- Cael's Quarters interior (cutscene-only, Act II)
- Haren's Estate Study interior (Act II political content)
- Council Chambers interior (Act II)
- Court Mage Tower interior (Elara Thane, Act II quest)
- Maren's Old Study / Pendulum Research Room (Act II)
- Servants' Passage (Interlude only)
- Royal Bedchamber (no gameplay purpose)
- Library Stacks Wing + Basement Archive (Act II quest: Mirren's
  hidden archive, "third Door" document)

### Deferred Locations
- **Thornwatch garrison rest stop:** Per locations.md, Thornwatch is a
  separate fortified outpost between Valdris Crown and the Wilds (Act I
  location #2). It has Commander Halda (quest-giver), a garrison armory
  (shop), a watchtower (story scene), and southern gate to the Wilds.
  Originally listed in Phase C but it is a distinct map with its own
  NPCs, shop, and side quest — better as its own sub-gap or Phase D.
  The return road from Maren's Refuge to Valdris Crown currently skips
  it (overworld direct). File as a new gap.
- **Aelhart (starting town):** Act I location #1. Tutorial town, not
  yet built. Separate gap.

### Deferred Gameplay
- Act II shop restocking (`diplomatic_mission_start` event gating)
- Anchor & Oar black market (Interlude, via Renn)
- Library Basement secret area (cracked wall, quest-gated)
- Eastern Wall Breach Alcove (Act II, Oathkeeper Buckler)
- Royal Signet accessory (Act II, requires court favor)
- Act-variant environmental storytelling (ley-lamp degradation,
  market emptying, graffiti, Nella's flowers — tracked per-act)

---

## 8. Testing Strategy

**Testing is a first-class deliverable, not an afterthought.** Every
map, every transition, every NPC, every flag, every shop gets tested.
We spend an hour writing code and days fixing bugs — tests catch them
early.

### 8.1 Unit Tests

One test file per major component. Run in GUT framework (headless).

#### `test_valdris_districts.gd` — District Map Integrity

Tests that verify each new map scene loads and has correct structure:

- **Scene loads without error:** `load()` succeeds for every new .tscn
- **Required nodes exist:** TileMapLayer, Entities, Transitions,
  PlayerSpawn present in every map
- **All spawn points exist:** every `target_spawn` referenced by any
  transition has a matching Marker2D in the target scene
- **NPC metadata valid:** every NPC under Entities has `npc_id` set,
  and `DataManager.load_dialogue(npc_id)` returns valid data
- **Shop NPC metadata valid:** every NPC with `shop_id` metadata
  references an existing shop JSON file
- **Save point metadata valid:** every save_point has a unique
  `save_point_id`
- **Transition metadata valid:** every Area2D under Transitions has
  `target_map` and `target_spawn` metadata, and the target scene
  file exists at `res://scenes/maps/{target_map}.tscn`
- **No orphan spawns:** every spawn Marker2D is referenced by at
  least one transition (or is PlayerSpawn)
- **Tile layer not empty:** TileMapLayer has >0 used cells
- **Map dimensions within budget:** used_rect() fits expected
  dimensions (no accidental 1000x1000 maps)

#### `test_valdris_shops.gd` — Shop Data Integrity

- **Shop files load:** every new/modified shop JSON parses without error
- **Item cross-reference:** every `item_id` in every shop inventory
  exists in items/ or equipment/ JSON files
- **Price validation:** spot-check prices against city-valdris.md
  values (exact match, not approximate)
- **Armorer split correct:** `valdris_crown_weaponsmith.json` has ONLY
  weapons, `valdris_crown_armorsmith.json` has ONLY armor
- **No duplicate item_ids** within a single shop
- **Markup values:** all Valdris shops have `markup: 1.0`
- **Specialty shop unchanged:** `valdris_crown_specialty.json` item
  count and prices match pre-existing data (regression)

#### `test_valdris_dialogue.gd` — Dialogue Data Integrity

- **All dialogue files load:** every new JSON file parses without error
- **Entry format valid:** every entry has all 7 required fields per
  dialogue-system.md (id, speaker, lines, condition, animations,
  choice, sfx)
- **Entry IDs globally unique:** no duplicate entry IDs across all
  new dialogue files
- **Speaker tags valid:** every speaker references a known character
  or NPC ID
- **Flag references valid:** every flag name in `condition` fields
  and `flag_set` actions uses a known flag name from events.md
- **Scene 7 dialogue completeness:** each Scene 7 file has the key
  lines from script/act-i.md (spot-check specific strings)
- **Conditional branches present:** Scene 7c Aldis has `party_has(lira)`
  and `party_has(maren)` variants; Cordwyn has `party_has(torren)` and
  `party_has(sable)` variants
- **NPC ambient dialogue has priority stack:** NPCs with both Scene 7c
  and ambient dialogue have correct condition ordering (Scene 7c
  variant first, ambient as fallback)

#### `test_scene_7_flags.gd` — Scene 7 Flag Logic

- **Flag sequence enforced:** `valdris_arrived` cannot be set without
  `maren_warning`
- **Flag 7b gate:** throne hall trigger only fires when `valdris_arrived`
  is set and `pendulum_presented` is NOT set
- **Flag 7c tracking:** each required NPC sets its respective flag
  (`scene_7c_aldis`, `scene_7c_cordwyn`, `scene_7c_renn`)
- **Flag 7d gate:** evening trigger requires ALL THREE 7c flags
- **Flag 7d result:** `pendulum_to_capital` is set after 7d completes
- **Flag idempotency:** triggering a scene twice does not error or
  re-set flags
- **Flag persistence:** flags survive save/load cycle
  (`SaveManager.save_game` + `load_game` round-trip)

### 8.2 Integration Tests

#### `test_valdris_integration.gd` — Full District Navigation

Tests that verify the connected district system works end-to-end:

- **Full traversal:** Load Lower Ward → transition to Citizen's Walk →
  transition to Court Quarter → transition to Throne Hall → transition
  back to Court Quarter → back to Citizen's Walk → back to Lower Ward.
  Verify player position updates correctly at each spawn point.
- **Reverse traversal:** Same path in reverse.
- **Interior round-trips:** Lower Ward → Barracks → Lower Ward. Lower
  Ward → Anchor & Oar → Upper Floor → Anchor & Oar → Lower Ward.
  Citizen's Walk → Library → Citizen's Walk.
- **Spawn point accuracy:** after each transition, player position is
  within 32px of the target Marker2D position
- **No entity leaks:** after leaving a map and returning, entity count
  matches the original (no duplicated NPCs or orphaned nodes)
- **Location name flash:** each district transition shows the correct
  location_name from metadata

#### `test_valdris_npcs_integration.gd` — NPC Interaction

- **Shop NPCs open shop overlay:** interact with armorsmith → shop
  overlay opens with correct shop_id inventory
- **Dialogue NPCs show dialogue:** interact with Elara Thane →
  dialogue box opens with correct npc_id dialogue
- **Inn NPC works:** interact with Renn → rest option available,
  gold deducted, party healed (existing test, verify no regression)
- **Save point works:** interact with library save point → save
  overlay opens (existing behavior, verify no regression)
- **NPC count per district:** Lower Ward has expected NPC count,
  Citizen's Walk has expected count, etc.

#### `test_scene_7_integration.gd` — Scene 7 End-to-End

The critical integration test. Simulates a full Scene 7 playthrough:

- **Setup:** Set `maren_warning` flag, load overworld, transition to
  Valdris
- **7a fires:** entering Valdris triggers gate dialogue. After
  completion, `valdris_arrived` is set.
- **7b fires:** entering throne hall triggers presentation. After
  completion, `pendulum_presented` is set.
- **7c — Aldis:** enter library, interact with Aldis. Scene 7c
  dialogue plays (not ambient). `scene_7c_aldis` set. Re-interact:
  ambient dialogue plays (not Scene 7c repeat).
- **7c — Cordwyn:** enter barracks, interact with Cordwyn. Scene 7c
  dialogue plays. `scene_7c_cordwyn` set.
- **7c — Renn:** enter Anchor & Oar, interact with Renn. Scene 7c
  dialogue plays. `scene_7c_renn` set.
- **7d fires:** enter Court Quarter / Keep entrance area. Evening
  cutscene triggers. `pendulum_to_capital` set.
- **7d does not re-fire:** re-enter the trigger area. No cutscene.
- **Post-7d NPC dialogue:** all three key NPCs show ambient dialogue,
  not Scene 7c dialogue.

#### `test_scene_7_ordering.gd` — Out-of-Order Resilience

- **7b before 7a:** entering throne hall without `valdris_arrived`
  does NOT trigger Scene 7b
- **7d before 7c complete:** entering trigger area with only 2/3 flags
  does NOT trigger Scene 7d
- **Skip to library first:** going directly to library before throne
  hall — Aldis shows ambient dialogue (not Scene 7c), because
  `pendulum_presented` is not set
- **NPC visit order independence:** Aldis → Renn → Cordwyn works.
  Cordwyn → Aldis → Renn works. All 6 permutations produce the same
  end state.

### 8.3 Regression Tests

#### `test_lower_ward_regression.gd` — Existing Functionality

The Lower Ward is being modified (new transitions, shop rename). These
tests verify nothing breaks:

- **Existing NPCs still work:** Bren, Wynn, Old Harren, Thessa, Marek,
  Nella all have valid dialogue
- **Existing shop still works:** weaponsmith (renamed from armorer)
  opens shop overlay with weapon inventory
- **Existing transitions still work:** South Gate → overworld, tavern
  door → Anchor & Oar (both directions)
- **Existing save point still works:** chapel save point activates
- **Existing inn still works:** Renn rest costs 150g, heals party
- **Scene 5/6 triggers still work:** Torren/Maren joining flags still
  function (if applicable from Lower Ward)

#### `test_anchor_oar_regression.gd` — Tavern Modifications

The Anchor & Oar is getting a staircase transition to the upper floor:

- **Existing Renn interaction works:** rest, save point unchanged
- **New staircase transition works:** go up → upper floor → come back down
- **Return spawn correct:** coming downstairs spawns at `from_upstairs`,
  not at `from_exterior`

### 8.4 Cross-Reference Validation Tests

#### `test_valdris_cross_references.gd`

- **All treasure chest item_ids exist:** every chest's `item_id`
  metadata references an item in items/ or equipment/ JSON
- **All shop item_ids exist:** (covered in shop tests, but
  cross-verify here too)
- **All NPC dialogue files exist:** for every NPC node with `npc_id`
  metadata, `game/data/dialogue/npc_{npc_id}.json` exists and loads
- **All transition targets exist:** for every transition Area2D,
  `res://scenes/maps/{target_map}.tscn` exists
- **All transition spawns exist:** for every transition, the target
  scene contains a Marker2D matching `target_spawn`
- **Bidirectional transitions:** if A→B exists, B→A also exists
  (no one-way doors unless intentional)
- **Flag names consistent:** every flag name used in dialogue conditions
  matches a flag name used in a `flag_set` action somewhere

### 8.5 Test Coverage Targets

| Category | Test Files | Est. Tests | Coverage Goal |
|----------|-----------|------------|---------------|
| District integrity | 1 | ~30 | Every map node validated |
| Shop data | 1 | ~15 | Every shop, every item cross-ref |
| Dialogue data | 1 | ~25 | Every file, format, flag ref |
| Scene 7 flags | 1 | ~15 | Every flag gate verified |
| District navigation | 1 | ~20 | Every transition both ways |
| NPC interaction | 1 | ~15 | Every NPC type tested |
| Scene 7 end-to-end | 1 | ~15 | Full playthrough |
| Scene 7 ordering | 1 | ~10 | Edge cases and ordering |
| Lower Ward regression | 1 | ~12 | All existing behavior |
| Anchor & Oar regression | 1 | ~8 | Existing + new staircase |
| Cross-references | 1 | ~20 | Every ID cross-checked |
| **Total** | **11** | **~185** | |

---

## 9. Implementation Order

1. Tileset extension (2-4 new tiles)
2. Shop data changes (split armorer, new jeweler)
3. NPC ambient dialogue JSON files (11 files)
4. Scene 7 dialogue JSON files (6 files)
5. Interior maps: throne hall, library, barracks, tavern upper floor
6. Outdoor maps: Citizen's Walk, Court Quarter
7. Lower Ward modifications (new transitions, shop rename)
8. Anchor & Oar modifications (staircase to upper floor)
9. Scene 7 trigger wiring (flags, conditions, cutscene)
10. `party_has()` wiring to PartyState (if still stubbed)
11. Unit tests (districts, shops, dialogue, flags)
12. Integration tests (navigation, NPCs, Scene 7 e2e)
13. Regression tests (Lower Ward, Anchor & Oar)
14. Cross-reference validation tests
15. Gap tracker update (status + deferred items)

---

## 10. Files Created/Modified

### New Files (~40+)

**Maps (7):**
- `game/scenes/maps/towns/valdris_citizens_walk.tscn`
- `game/scenes/maps/towns/valdris_court_quarter.tscn`
- `game/scenes/maps/towns/valdris_throne_hall.tscn`
- `game/scenes/maps/towns/valdris_royal_library.tscn`
- `game/scenes/maps/towns/valdris_barracks.tscn`
- `game/scenes/maps/towns/valdris_anchor_oar_upper.tscn`
- (Lower Ward and Anchor & Oar modified, not new)

**Shop data (2 new, 1 rename):**
- `game/data/shops/valdris_crown_armorsmith.json` (new)
- `game/data/shops/valdris_crown_jeweler.json` (new)
- `game/data/shops/valdris_crown_weaponsmith.json` (rename from armorer)

**Dialogue (17):**
- 6 Scene 7 files
- 11 NPC ambient files

**Tests (11):**
- 11 test files as described in Section 8

**Tileset:**
- `game/assets/tilesets/placeholder_dungeon.png` (extended)
- `game/assets/tilesets/placeholder_dungeon.tres` (updated)

### Modified Files (~4)

- `game/scenes/maps/towns/valdris_lower_ward.tscn` (new transitions)
- `game/scenes/maps/towns/valdris_anchor_oar.tscn` (staircase)
- `game/scripts/entities/npc.gd` (party_has wiring, if needed)
- `docs/analysis/game-dev-gaps.md` (status update + deferred items)

---

## 11. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `party_has()` still stubbed in npc.gd | Scene 7c conditional branches won't show | Wire to PartyState.has_member() as part of this gap |
| Multi-flag condition for 7d trigger | No existing precedent for AND conditions on Area2D triggers | May need small exploration.gd enhancement for multi-flag triggers |
| Shop split breaks existing saves | Players with save data referencing `valdris_crown_armorer` | SaveManager should handle missing shop_id gracefully (it's overlay state, not persisted) |
| Large number of new dialogue files | Risk of typos, wrong speaker tags, broken conditions | Dialogue unit tests validate every file structurally |
| Scene tree complexity in 7 new maps | Risk of metadata typos, missing spawns | District integrity tests catch all structural issues |
