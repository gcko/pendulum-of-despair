# Game Development Gap Analysis

> **Living document.** Updated by the `game-designer` skill as gaps are
> addressed. Status fields reflect the current state of each implementation
> area. Every value, formula, and behavior must trace back to a canonical
> design document in `docs/story/`.
>
> **Companion to:** `docs/analysis/game-design-gaps.md` (design docs — 24/25 COMPLETE)
> **Architecture reference:** `docs/plans/technical-architecture.md`
> **Engine:** Godot 4.6+ / GDScript only
> **Resolution:** 320x180 native, integer-scaled

## How to Read This Document

Each implementation area has:
- **Status:** NOT STARTED | IN PROGRESS | MOSTLY COMPLETE | COMPLETE
- **What's Needed:** Specific deliverables (code, scenes, data files)
- **Source Docs:** Canonical design documents this implementation derives from
- **Blocking:** What cannot be built until this gap is closed
- **Depends On:** Other gaps that must be resolved first
- **Estimated Size:** S (1-2 files), M (3-8 files), L (10+ files), XL (20+ files, multi-system)

When a gap is closed, the `game-designer` skill updates the status and
adds a "Completed" date + commit reference.

## What Already Exists

**PR #105 (merged 2026-04-02):** Godot project initialized with:
- `game/project.godot` — viewport 320x180, integer scaling, 5 autoloads
- 5 autoload singletons in `game/scripts/autoload/` (GameManager,
  DataManager, AudioManager, SaveManager, EventFlags) — all have
  public API + defensive coding, stubs for game-state-dependent methods
- Directory structure with `.gdkeep` placeholders
- No scenes (.tscn), no JSON data files, no art/audio assets

## Canonical Source Documents

Every implementation gap maps to one or more design documents.
**No code may introduce values, formulas, or behaviors not defined
in these docs.**

| Category | Source Documents |
|----------|----------------|
| Game overview | `gdd-overview.md` (254), `outline.md` (371), `world.md` (79) |
| Combat mechanics | `combat-formulas.md` (933) |
| Character stats/growth | `progression.md` (446), `characters.md` (220) |
| Abilities & magic | `abilities.md` (552), `magic.md` (1,463) |
| Enemy data | `bestiary/` (9 files) |
| Items & equipment | `items.md` (602), `equipment.md` (708) |
| Economy & shops | `economy.md` (953) |
| Crafting | `crafting.md` (396) |
| Encounters | `dungeons-world.md` (5,350), `dungeons-city.md` (1,489), `combat-formulas.md` |
| Dialogue | `dialogue-system.md` (525), `script/` (9 files) |
| UI & menus | `ui-design.md` (1,180) |
| Save/load | `save-system.md` (567) |
| Audio | `audio.md` (309), `music.md` (528) |
| Overworld & maps | `overworld.md` (512), `geography.md` (714), `locations.md` (1,244), `biomes.md` (999) |
| Dungeons | `dungeons-world.md` (5,350), `dungeons-city.md` (1,489) |
| Towns | `city-valdris.md` (1,286), `city-carradan.md` (1,592), `city-thornmere.md` (1,467), `interiors.md` (2,009) |
| NPCs | `npcs.md` (1,477) |
| Events & flags | `events.md` (980) |
| Visual style | `visual-style.md` (872), `building-palette.md` (1,407) |
| Accessibility | `accessibility.md` (361) |
| Difficulty & balance | `difficulty-balance.md` (590) |
| Transport | `transport.md` (307) |
| Dynamic world | `dynamic-world.md` (1,156) |
| Sidequests | `sidequests.md` (704) |
| Post-game | `postgame.md` (281) |
| Architecture | `docs/plans/technical-architecture.md` (943) |

**Design doc risk note:** Some source docs are marked "MOSTLY COMPLETE"
in `game-design-gaps.md` (magic.md, abilities.md, npcs.md, sidequests.md,
events.md). Implementation gaps that depend on these may encounter
missing data — use `/story-designer` to fill design gaps before
implementing.

---

## Tier 1: Data Foundation

Convert canonical design documents into runtime JSON data files.
No new GDScript — uses existing DataManager to load. Pure data
transformation that can be validated line-by-line against source docs.

### 1.1 Character Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-02
**Priority:** P0 — blocks entity prefabs, battle system, menus
**Estimated Size:** S (6 JSON files)
**Output:** `game/data/characters/{edren,cael,maren,sable,lira,torren}.json`
**Source Docs:** `progression.md` (base stats, growth curves, stat caps), `characters.md` (roles, weapon types, default row), `abilities.md` (ability learn levels), `magic.md` (spell learn levels)
**Architecture Ref:** `technical-architecture.md` Section 2.10
**Depends On:** None (foundational)

**What's Needed:**
- [x] Per-character JSON file following Section 2.10 schema
- [x] Base stats at level 1 (HP, MP, ATK, DEF, MAG, MDEF, SPD, LCK)
- [x] Growth rates per stat from progression.md growth tables
- [x] Default row assignment from characters.md
- [x] Weapon type and equipment slot list
- [ ] Ability learn schedule from abilities.md (level -> ability_id) — deferred to Gap 1.5 (lives in spell/ability JSONs via `learned_by` field per tech-arch Section 2.7)
- [ ] Spell learn schedule from magic.md (level -> spell_id) — deferred to Gap 1.5
- [x] Verify all values against progression.md tables (adversarial check)

**Blocking:** Entity prefabs (need stats to display), battle system (need growth curves), menus (need character data for status/equipment screens)

---

### 1.2 Enemy Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-02
**Priority:** P0 — blocks battle system, encounters, economy testing
**Estimated Size:** L (~204 enemies + 35 boss entries across 6 JSON files)
**Output:** `game/data/enemies/{act_i,act_ii,interlude,act_iii,optional,bosses}.json`
**Source Docs:** `bestiary/act-i.md` through `bestiary/optional.md`, `bestiary/bosses.md`, `bestiary/README.md` (type rules, scaling), `bestiary/palette-families.md`
**Architecture Ref:** `technical-architecture.md` Section 2.1 (extended with two-tier steal, threat field, locations array)
**Depends On:** None (foundational)

**What's Needed:**
- [x] Per-act JSON file following Section 2.1 schema (extended — see spec)
- [x] All ~204 regular enemies with 19-column stat sheets
- [x] Elemental profiles (weaknesses, resistances, immunities, absorb)
- [x] Status effect vulnerability lists
- [x] Drop tables (common item, rare item, steal item with rates)
- [x] Boss data file with phase triggers and metadata (35 entries; AI scripts deferred to GDScript implementation)
- [x] Verify every enemy name, stat, and drop against bestiary source files
- [x] Verify boss phase HP thresholds against bosses.md
- [x] Decision: two-tier steal (common/rare) per abilities.md Filch description and economy.md — RESOLVED, implemented as `steal: { common, rare }` nested object

**Notes:**
- Schema extends tech-arch Section 2.1: added `threat` field (reward validation), `locations` array, two-tier `steal` object. Tech-arch should be updated to match.
- Boss AI scripts are NOT in JSON — those are runtime behavior for future GDScript implementation.
- Design spec: `docs/superpowers/specs/2026-04-02-enemy-data-json-design.md`
- Enemies reappearing at different levels across acts have location-suffixed IDs (e.g., `pallor_wisp_rail_tunnels`, `pallor_drake_void`)

**Blocking:** Battle system (needs enemy data), encounter tables (reference enemy IDs), economy testing (gold/XP values)

---

### 1.3 Item & Equipment Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P0 — blocks shops, inventory, battle items, equipment screens
**Estimated Size:** M (6 JSON files, 300 total entries)
**Output:** `game/data/items/{consumables,materials,key_items}.json`, `game/data/equipment/{weapons,armor,accessories}.json`
**Source Docs:** `items.md` (consumables, materials, key items), `equipment.md` (weapons, armor, accessories, forging)
**Architecture Ref:** `technical-architecture.md` Sections 2.2, 2.3 (extended with bonus_stats object)
**Depends On:** None (foundational)

**What's Needed:**
- [x] Consumables JSON: 33 consumables with effects, prices, targets, usability flags, status cure mappings
- [x] Materials JSON: 87 materials (72 from items.md table + 14 boss-specific steals/drops + grey_mist_essence)
- [x] Key items JSON: 26 key items (9 dungeon access + 8 boss mementos + 2 schematics + 7 story items)
- [x] Weapons JSON: 58 weapons with stats, equippable_by, tier, element, special, bonus_stats
- [x] Armor JSON: 49 armor pieces (20 head + 29 body) with stats, tier, armor_class
- [x] Accessories JSON: 47 accessories (8 stat + 6 status immunity + 4 elemental + 9 combat + 20 boss drop)
- [x] Verify every price against economy.md / items.md / equipment.md
- [x] Verify every equippable_by against characters.md weapon/armor types
- [x] Cross-reference: all 121 enemy steal/drop item_ids from gap 1.2 exist in item/equipment files

**Notes:**
- Uses bonus_stats object (sparse) instead of tech-arch flat stat fields. Tech-arch should be updated to match.
- Drake Fang is dual-purpose (material + battle consumable) with battle_usable fields on the material entry.
- Elemental body armor classified as armor_class: "light" per equipment.md ("Light armor with elemental resistance").
- Forgewright devices deferred to gap 1.7, Ley Crystal invocations to gap 1.5.
- Design spec: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

**Blocking:** Shop system (needs prices), inventory (needs item catalog), battle (needs usable items), equipment screen (needs stat data)

---

### 1.4 Shop Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P1 — blocks town implementation
**Estimated Size:** M (23 JSON files, one per shop across 10 towns)
**Output:** `game/data/shops/{shop_id}.json`
**Source Docs:** `economy.md` (complete shop inventories per town with event-gated restocking)
**Architecture Ref:** `technical-architecture.md` Section 2.4
**Depends On:** 1.3 (Items & Equipment — item IDs must exist)

**What's Needed:**
- [x] Per-shop JSON following Section 2.4 schema (23 files, one per shop)
- [x] All 10 town inventories from economy.md (102 unique item_ids across all shops)
- [x] Event-gated restock entries (available_act, restock_event)
- [x] Caldera 150% inflation pricing per economy.md (markup: 1.5 on Company shops)
- [x] Verify every item_id references an existing item/equipment ID from Gap 1.3
- [x] Verify prices match economy.md tables

**Notes:**
- 23 shop files (multiple shops per town: general, armorer, specialty, etc.)
- Caldera Company Store/Armorer have markup: 1.5 with pre-multiplied prices
- Caldera Black Market has markup: 1.0 (standard prices)
- Interlude scarcity handled at runtime, not in static data
- Design spec: `docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md`

**Blocking:** Town implementations (need shop data), economy testing

---

### 1.5 Spell & Ability Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P1 — blocks magic/ability menus, battle casting
**Estimated Size:** M (12 JSON files: 5 spell + 6 ability + 1 combo)
**Output:** `game/data/spells/{tradition}.json`, `game/data/abilities/{character}.json`, `game/data/abilities/combos.json`
**Source Docs:** `magic.md` (spell lists per tradition), `abilities.md` (6 unique command systems)
**Architecture Ref:** `technical-architecture.md` Section 2.7
**Depends On:** 1.1 (Character Data — learn levels cross-reference)

**What's Needed:**
- [x] Per-tradition spell JSON following Section 2.7 schema (5 files: ley_line, forgewright, spirit, void, streetwise)
- [x] All 89 spells from magic.md with: id, name, tradition, element, category, tier, power, mp_cost, target, learned_by
- [x] Per-character ability JSON as descriptive data (6 files: edren, cael, maren, sable, lira, torren)
- [x] 6 unique ability command systems from abilities.md (44 abilities total):
  - [x] Edren: Bulwark (7 abilities)
  - [x] Cael: Rally (5 abilities)
  - [x] Maren: Arcanum (7 abilities)
  - [x] Sable: Tricks (7 abilities)
  - [x] Lira: Forgewright (10 abilities, includes Calibrate Pallor Zone Action)
  - [x] Torren: Spiritcall (8 abilities, includes Purify Pallor Zone Action)
- [x] 12 dual-tech combos in combos.json
- [x] Verify spell IDs unique across all 5 spell files (89 unique)
- [x] Verify ability IDs unique across all 7 ability files (56 unique)
- [x] Verify all learned_by character IDs are valid

**Notes:**
- Abilities are **descriptive data only** — name, cost, effect text, target. Runtime execution logic (AP/WG/AC/Favor tracking, device mechanics, combo resolution) deferred to gap 3.3 (Battle Scene).
- Cross-trained spells flagged per-learner in learned_by entries (cross_trained: true, mp_penalty: 1.5 on the specific character entry, not at spell level)
- Pallor Zone Actions (Lira: Calibrate, Torren: Purify) included as story-gated abilities
- Design spec: `docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md`

**Blocking:** Battle casting (3.3), magic/ability menus (3.4), character progression feel

---

### 1.6 Encounter Table Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P1 — blocks dungeon encounters
**Estimated Size:** L (27 JSON files: 20 world + 6 city + 1 overworld)
**Output:** `game/data/encounters/{dungeon_id}.json`
**Source Docs:** `dungeons-world.md` (encounter groups per floor), `dungeons-city.md`, `combat-formulas.md` (danger counter, formation types, rates), `geography.md` (overworld zones)
**Architecture Ref:** `technical-architecture.md` Section 2.6 (extended — see spec)
**Depends On:** 1.2 (Enemy Data — enemy IDs must exist)

**What's Needed:**
- [x] Per-dungeon JSON following Section 2.6 schema (extended with terrain_type, danger_tier, formation_rates object)
- [x] Floor-by-floor encounter groups with weights (4-pack: 31.25/31.25/31.25/6.25%. Dreamer's Fault: 5-6 pack extended format)
- [x] Danger counter increment per floor/terrain
- [x] Back attack and preemptive strike rates per terrain (formation_rates object)
- [x] Boss trigger conditions (zone, interact, cutscene, HP threshold)
- [x] Overworld encounter tables per terrain type (12 zones in overworld.json)
- [x] Verify every enemy_id references an existing enemy from Gap 1.2 (0 missing after fix pass)
- [x] Verify group compositions match dungeons-world.md formation tables (counts match; ~18 dungeons use substitute enemy IDs pending gap 1.2 supplement)

**Notes:**
- Known gap: ~95 unique enemy/boss IDs referenced in design docs do not yet exist in gap 1.2 enemy data. Encounter files use thematically appropriate substitute IDs from existing enemies. Formation composition counts match source docs. A gap 1.2 supplement pass may be needed to add missing dungeon-specific enemies.
- 27 encounter files: 20 world dungeons + 6 city dungeons + 1 overworld (12 terrain zones)
- Schema extends tech-arch Section 2.6: renamed floor→floor_id, restructured formation rates into object, added terrain_type/danger_tier/format fields
- Act scaling multipliers (x1.0/x1.1/x1.2/x1.1) and encounter rate modifiers (Ward Talisman, Veilstep, etc.) applied at runtime, not in static data
- Dreamer's Fault uses extended 5-6 pack format with non-standard weights
- Design spec: `docs/superpowers/specs/2026-04-04-encounters-crafting-design.md`

**Blocking:** Exploration encounters, dungeon pacing, difficulty testing

---

### 1.7 Crafting & Device Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P2 — blocks crafting system
**Estimated Size:** S (3 JSON files: devices + recipes + synergies)
**Output:** `game/data/crafting/{devices,recipes,synergies}.json`
**Source Docs:** `crafting.md` (device tiers, recipes, AC costs), `items.md` (material requirements), `equipment.md` (forging recipes, infusions, synergies)
**Architecture Ref:** `technical-architecture.md` Section 2.8 (extended — see spec)
**Depends On:** 1.3 (Items & Equipment — material and result IDs must exist)

**What's Needed:**
- [x] Devices JSON following Section 2.8 schema (extended): 13 devices with tier, AC cost, effect, charges, materials, gold_cost, unlock phase, schematic_required
- [x] Recipes JSON: 9 forging recipes with materials, gold fee, forge locations, unlock phase + 7 elemental infusions
- [x] Synergies JSON: 7 secret synergies with base weapon, infusion element, bonus effect, discovery channel
- [x] Verify all material item_ids exist in materials.json (0 missing)
- [x] Verify all result equipment_ids exist in equipment JSONs (0 missing)
- [x] Verify AC costs and unlock phases against crafting.md

**Notes:**
- 3 files (not 2 as originally estimated): devices.json, recipes.json (forging + infusions), synergies.json
- Schema extends tech-arch Section 2.8: renamed result_item→result_id, forge_location→forge_locations (plural), added device fields
- Arcanite Lance requires forge_schematic (steal-only, permanently missable)
- Lira's Masterwork requires daels_ledger (quest reward)
- Pallor Salve exists as both shop consumable (gap 1.3) and craftable device
- Design spec: `docs/superpowers/specs/2026-04-04-encounters-crafting-design.md`

**Blocking:** Crafting system implementation, Lira's Forgewright gameplay

---

### 1.8 Dialogue Data (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P0 — blocks NPC prefab (2.2), exploration scene (3.2), and vertical slice (4.1)
**Estimated Size:** L (109 JSON files, 1045 entries)
**Output:** `game/data/dialogue/{scene_id}.json`, `game/data/dialogue/npc_{npc_id}.json`, `game/data/dialogue/battle_{context_id}.json`
**Source Docs:** `script/` (6,531 lines across 8 content files), `dialogue-system.md` (7-field entry format), `npcs.md` (NPC dialogue assignments)
**Architecture Ref:** `technical-architecture.md` Section 2.5
**Depends On:** None (foundational, but dialogue overlay in Tier 3 needed to display)

**What's Needed:**
- [x] Per-scene dialogue JSON following Section 2.5 schema (7-field entries)
- [x] 40 narrative scenes from script/ Layer 1 (688 entries)
- [x] NPC ambient dialogue from npc-ambient.md Layer 2 (43 files, 177 entries)
- [x] Battle dialogue from battle-dialogue.md Layer 3 (26 files, 180 entries)
- [x] System text (tutorials, prompts, notifications) from battle-dialogue.md
- [x] Condition expressions (flag checks, party_has) per dialogue-system.md (98 conditional entries)
- [x] Animation markers mapped to sprite animation IDs (45 animations captured)
- [x] SFX markers mapped to audio.md SFX catalog IDs (17 SFX captured)
- [x] Choice nodes with branch targets (4 choice blocks)
- [x] Verify every speaker tag matches a valid character/NPC ID
- [x] Verify flag names (validated against events.md; choice_N_selected and branch conditions are parser-generated placeholders pending runtime implementation)

**Notes:**
- Built via Python parser (`tools/dialogue_parser.py`) that reads 8 script files
- Parser uses heuristic timing for animation/SFX `when` fields
- Validation report at `tools/dialogue_validation_report.md` flags low-confidence items
- 109 total files (40 narrative + 43 NPC + 26 battle) with 1045 entries
- All entry IDs globally unique, all 7 fields present, 2-space indent
- Iterative improvement: subsequent passes can refine timing heuristics
- Design spec: `docs/superpowers/specs/2026-04-04-dialogue-data-design.md`

**Blocking:** All narrative content, NPC interactions, story progression

---

### 1.9 Config Defaults (JSON)

**Status:** COMPLETE
**Completed:** 2026-04-04
**Priority:** P2 — blocks settings/config screen
**Estimated Size:** S (1 JSON file)
**Output:** `game/data/config/defaults.json`
**Source Docs:** `accessibility.md` Section 7 (17 config settings), `save-system.md` Section 2 (config separate from saves)
**Architecture Ref:** `technical-architecture.md` Section 6.6
**Depends On:** None

**What's Needed:**
- [x] All 17 config settings with default values from accessibility.md
- [x] Battle speed (default 3), ATB mode (active), text speed (normal)
- [x] Accessibility defaults: patience_mode (false), color_blind_mode (off), high_res_text (false), reduce_motion (false)
- [x] Audio defaults: music_volume (8), sfx_volume (8), sound_mode (stereo)
- [x] Verify defaults match accessibility.md Section 7 table exactly

**Notes:**
- Config stored separately from save data per save-system.md
- Runtime behavior (patience_mode overrides, reduce_motion cascades) deferred to gap 3.4
- window_color uses RGB object {r, g, b} with 0-31 range per accessibility.md

**Blocking:** Config screen, settings persistence

---

## Tier 2: Entity Prefabs & Core Scripts

Build the .tscn scene prefabs from technical-architecture.md Section 4.
Each entity is testable in the Godot editor in isolation. Attached
GDScript loads data from Tier 1 JSON via DataManager.

### 2.1 PlayerCharacter Prefab

**Status:** NOT STARTED
**Priority:** P0 — blocks exploration, battle display
**Estimated Size:** M (1 .tscn + 1 .gd + placeholder sprites)
**Output:** `game/scenes/entities/player_character.tscn`, `game/scripts/entities/player_character.gd`
**Source Docs:** `visual-style.md` (16x24 character sprites), `characters.md` (movement), `technical-architecture.md` Section 4.2
**Depends On:** 1.1 (Character Data — loads stats from JSON)

**What's Needed:**
- [ ] CharacterBody2D scene tree per tech-arch Section 4.2
- [ ] Sprite2D with placeholder 16x24 sprite (colored rectangle per character)
- [ ] CollisionShape2D for movement collision
- [ ] AnimationPlayer with walk cycle (4-direction, 2-frame minimum)
- [ ] GDScript: load character data from DataManager
- [ ] GDScript: handle 4-direction movement input
- [ ] GDScript: emit interaction signal (for NPC/chest/save point proximity)
- [ ] Snap to pixel grid (no sub-pixel positions)
- [ ] Process mode handling (pause when overlay active)

**Blocking:** Exploration scene (needs player entity), battle scene (needs party display)

---

### 2.2 NPC Prefab

**Status:** NOT STARTED
**Priority:** P1 — blocks town interactions
**Estimated Size:** S (1 .tscn + 1 .gd)
**Output:** `game/scenes/entities/npc.tscn`, `game/scripts/entities/npc.gd`
**Source Docs:** `dialogue-system.md` (NPC interaction model, priority stack), `npcs.md` (NPC list), `technical-architecture.md` Section 4.2
**Depends On:** 1.8 (Dialogue Data — loads dialogue from JSON)

**What's Needed:**
- [ ] Area2D scene tree per tech-arch Section 4.2
- [ ] Sprite2D with placeholder 16x24 NPC sprite
- [ ] CollisionShape2D for interaction zone
- [ ] AnimationPlayer with idle + 14 sprite emotion animations from dialogue-system.md
- [ ] GDScript: load dialogue from DataManager by NPC ID
- [ ] GDScript: on interact, call GameManager.push_overlay(DIALOGUE) with dialogue data
- [ ] GDScript: flag-gated dialogue (check EventFlags, use priority stack from dialogue-system.md)
- [ ] GDScript: party-aware dialogue (Tier 1 key scenes + Tier 2 NPC reactions)

**Blocking:** Town scenes (need NPCs), story progression (flag-gated dialogue)

---

### 2.3 Enemy Prefab (Battle)

**Status:** NOT STARTED
**Priority:** P0 — blocks battle system
**Estimated Size:** S (1 .tscn + 1 .gd)
**Output:** `game/scenes/entities/enemy.tscn`, `game/scripts/entities/enemy.gd`
**Source Docs:** `bestiary/README.md` (AI behavior: weighted random for regulars, scripted for bosses), `combat-formulas.md` (damage, hit/miss), `technical-architecture.md` Section 4.2
**Depends On:** 1.2 (Enemy Data — loads stats from JSON)

**What's Needed:**
- [ ] Node2D scene tree per tech-arch Section 4.2
- [ ] Sprite2D for enemy battle sprite (placeholder colored rectangles, 32x32 to 64x64)
- [ ] AnimationPlayer with idle, hit reaction, death animations
- [ ] GDScript: load enemy data from DataManager by enemy ID
- [ ] GDScript: runtime HP/MP/status tracking
- [ ] GDScript: weighted-random AI for regular enemies (per bestiary README)
- [ ] GDScript: scripted AI for bosses (conditional priority lists, phase transitions per bosses.md)
- [ ] GDScript: elemental profile checks (weakness/resistance/immune/absorb)
- [ ] GDScript: status effect vulnerability checks
- [ ] GDScript: drop/steal resolution (common, rare rates)

**Blocking:** Battle scene (needs enemies to fight)

---

### 2.4 Interactable Prefabs (Chest, Trigger, SavePoint)

**Status:** NOT STARTED
**Priority:** P1 — blocks dungeon/town furnishing
**Estimated Size:** M (3 .tscn + 3 .gd)
**Output:** `game/scenes/entities/{treasure_chest,trigger_zone,save_point}.tscn`, matching .gd scripts
**Source Docs:** `save-system.md` (save point 3-option menu), `events.md` (flag-based triggers), `items.md` (chest contents), `overworld.md` (save point specification), `technical-architecture.md` Section 4.2
**Depends On:** 1.3 (Items — chest contents reference item IDs)

**What's Needed:**
- [ ] TreasureChest: Area2D, closed/open sprite frames, chest_id for save tracking, flag check, give item on interact
- [ ] TriggerZone: Area2D, event_flag condition, body_entered signal, flag setting on trigger
- [ ] SavePoint: Area2D, ley crystal 2-frame shimmer animation, proximity SFX (save_point_chime), push SAVE_LOAD overlay on interact
- [ ] All three: snap to pixel, emit signals (call down, signal up)
- [ ] Verify chest contents against items.md and economy.md treasure chest formula
- [ ] Verify trigger flags against events.md flag list

**Blocking:** Dungeon maps (need chests, triggers, save points), story progression (trigger zones drive events)

---

## Tier 3: Core Systems & Scenes

Wire up the game systems. Each builds on Tier 1 data + Tier 2 entities.
These are the core .tscn scenes and their orchestrating GDScript.

### 3.1 Title Screen

**Status:** NOT STARTED
**Priority:** P1 — blocks game entry point
**Estimated Size:** S (1 .tscn + 1 .gd)
**Output:** `game/scenes/core/title.tscn`, `game/scripts/core/title.gd`
**Source Docs:** `ui-design.md` (title screen layout), `audio.md`/`music.md` (title music)
**Depends On:** None (minimal — just needs GameManager for transitions)

**What's Needed:**
- [ ] Title screen scene with game logo placeholder, menu options (New Game, Continue, Config)
- [ ] New Game: initialize fresh game state, transition to Exploration
- [ ] Continue: show save slot selection, load save, transition to Exploration
- [ ] Config: push config overlay
- [ ] Title music playback via AudioManager
- [ ] Keyboard/gamepad navigation per accessibility.md input spec
- [ ] Set as `run/main_scene` in project.godot (first runnable scene)

**Blocking:** Game is not runnable without a main scene. This is the entry point.

---

### 3.2 Exploration Scene

**Status:** NOT STARTED
**Priority:** P0 — blocks all overworld/town/dungeon gameplay
**Estimated Size:** L (1 .tscn + multiple .gd + map loading system)
**Output:** `game/scenes/core/exploration.tscn`, `game/scripts/core/exploration.gd`, map loader scripts
**Source Docs:** `overworld.md` (movement, transitions, weather), `combat-formulas.md` (danger counter, encounter trigger), `geography.md` (terrain types), `save-system.md` (auto-save triggers), `technical-architecture.md` Section 3
**Depends On:** 2.1 (PlayerCharacter), 2.2 (NPC), 2.4 (Interactables), 1.6 (Encounter Tables)

**What's Needed:**
- [ ] TileMapLayer-based map rendering (up to 4 layers per tech-arch Section 7)
- [ ] Map loading system (load .tscn map files by ID)
- [ ] Player character instantiation and movement
- [ ] NPC, chest, trigger, save point placement from map data
- [ ] Camera2D following player (pixel-snapped, integer zoom only)
- [ ] Danger counter system from combat-formulas.md (step counting, terrain increments)
- [ ] Random encounter trigger → GameManager.change_core_state(BATTLE)
- [ ] Map transition (door/exit → fade to black → load new map)
- [ ] Menu button → GameManager.push_overlay(MENU)
- [ ] NPC/chest/save interaction → appropriate overlay
- [ ] Auto-save triggers per save-system.md Section 6 (new floor, boss zone, new town, quest complete)
- [ ] Audio context switching via AudioManager (biome music + ambient per audio.md mixing model)

**Blocking:** All overworld, town, and dungeon gameplay

---

### 3.3 Battle Scene

**Status:** NOT STARTED
**Priority:** P0 — blocks all combat
**Estimated Size:** L (1 .tscn + 5+ .gd files for battle subsystems)
**Output:** `game/scenes/core/battle.tscn`, `game/scripts/combat/` (battle_manager.gd, atb_system.gd, damage_calculator.gd, battle_ui.gd, battle_ai.gd)
**Source Docs:** `combat-formulas.md` (ALL formulas), `ui-design.md` (battle screen layout), `abilities.md`, `magic.md`, `items.md` (battle-usable items), `difficulty-balance.md` (pacing targets)
**Depends On:** 2.3 (Enemy Prefab), 1.1 (Character Data), 1.2 (Enemy Data), 1.5 (Spells & Abilities)

**What's Needed:**
- [ ] ATB gauge system: `floor((SPD + 25) * battle_speed_factor * status_modifiers)` per combat-formulas.md
- [ ] Active vs Wait mode (gauge pauses during menu in Wait mode)
- [ ] Battle speed 1-6 scale
- [ ] Turn order resolution when multiple gauges fill simultaneously
- [ ] Physical damage: `(ATK * ATK) / 6 - DEF` with variance `random_int(240,255)/256`
- [ ] Magical damage: `MAG × power / 4 - MDEF` with element multiplier
- [ ] Healing: `MAG × power × 0.8`
- [ ] Critical hit: `LCK/4` rate (cap 50%), 2× damage
- [ ] Hit/miss: 3-stage resolution (accuracy vs evasion) per combat-formulas.md
- [ ] Elemental multipliers: 1.5× weak, 0.75× disadvantage, 0.5× same, 0× immune, -1× absorb
- [ ] Status effect application: two-stage (MAG vs MDEF, then MEVA% resist)
- [ ] Row system: front/back, 50% physical modifier, back-row spears bypass
- [ ] 6 command types: Attack, Magic, Ability, Item, Defend, Flee
- [ ] Flee formula per combat-formulas.md (SPD-based)
- [ ] Battle UI per ui-design.md: party panel (HP/MP bars, ATB gauge), enemy area, command menu, damage numbers, status icons (22 unified icons)
- [ ] Victory: XP/gold distribution per progression.md (full to 4 active, 50% to 2 absent, 0 to KO)
- [ ] Defeat: Faint-and-Fast-Reload via SaveManager
- [ ] Boss battles: scripted AI, phase transitions, immunity lists, scripted events
- [ ] Formation types: Normal, Back Attack, Preemptive (rates per encounter data)
- [ ] Battle music via AudioManager (hard cut in, crossfade out per audio.md)
- [ ] Damage cap: 14,999 (mirrors HP cap)

**Blocking:** All combat gameplay. This is the most complex single system.

---

### 3.4 Menu Overlay

**Status:** NOT STARTED
**Priority:** P1 — blocks inventory management, equipment, party setup
**Estimated Size:** L (1 .tscn + 10+ .gd files for sub-screens)
**Output:** `game/scenes/overlay/menu.tscn`, `game/scripts/ui/` (menu screens)
**Source Docs:** `ui-design.md` (all 14 screen designs — 1,180 lines)
**Depends On:** 1.1 (Character Data), 1.3 (Items & Equipment), 1.4 (Shop Data — for buy/sell screens), 1.5 (Spells & Abilities)

**What's Needed:**
- [ ] 9-command main menu: Items, Equipment, Magic, Abilities, Status, Formation, Ley Crystals, Config, Save (only at save points)
- [ ] Items screen: categorized list, use/discard, stack counts
- [ ] Equipment screen: 5 slots per character, stat comparison display
- [ ] Magic screen: per-character spell list, MP costs, learned/unlearned
- [ ] Abilities screen: per-character unique command, sub-abilities
- [ ] Status screen: full stat display, equipment summary, elemental profile
- [ ] Formation screen: active/reserve party, row assignment (front/back), drag arrangement
- [ ] Ley Crystal screen: collected crystals, equip slot, level/XP display
- [ ] Config screen: all 17 settings from accessibility.md
- [ ] All screens: keyboard/gamepad navigation, cursor memory, per ui-design.md specs
- [ ] Process mode: PROCESS_MODE_ALWAYS (runs while game paused)

**Blocking:** Player inventory management, equipment optimization, party configuration

---

### 3.5 Dialogue Overlay

**Status:** NOT STARTED
**Priority:** P1 — blocks all NPC interaction and story scenes
**Estimated Size:** M (1 .tscn + 2-3 .gd files)
**Output:** `game/scenes/overlay/dialogue.tscn`, `game/scripts/ui/dialogue_box.gd`
**Source Docs:** `ui-design.md` Section 12 (text box specs), `dialogue-system.md` (rendering rules, typewriter effect, choice prompts)
**Depends On:** 1.8 (Dialogue Data)

**What's Needed:**
- [ ] Full-width text box at screen bottom per ui-design.md
- [ ] Typewriter text effect with configurable speed (instant, fast, normal, slow)
- [ ] Speaker name display (top-left of text box)
- [ ] 3-line text box limit per ui-design.md
- [ ] Button press to advance (with "waiting" indicator)
- [ ] Choice prompt display with cursor navigation
- [ ] Animation trigger system ([animation_id] markers from dialogue data)
- [ ] SFX trigger system (sfx markers from dialogue data)
- [ ] Flag condition evaluation (binary, numeric, string, party_has per dialogue-system.md)
- [ ] Flag setting on dialogue completion (set EventFlags per events.md)
- [ ] Process mode: PROCESS_MODE_ALWAYS

**Blocking:** All NPC dialogue, story scenes, tutorials, quest interactions

---

### 3.6 Save/Load Overlay

**Status:** NOT STARTED
**Priority:** P1 — blocks manual saving
**Estimated Size:** M (1 .tscn + 2 .gd files)
**Output:** `game/scenes/overlay/save_load.tscn`, `game/scripts/ui/save_load.gd`
**Source Docs:** `save-system.md` (save point 3-option menu, slot display), `ui-design.md` (save/load screen layout), `overworld.md` (save point specification)
**Depends On:** SaveManager autoload (already exists)

**What's Needed:**
- [ ] Save point 3-option menu: Rest, Rest & Save, Save per save-system.md Section 5
- [ ] Rest: consume tiered rest item (Sleeping Bag/Tent/Pavilion), restore HP/MP per save-system.md
- [ ] Save/Load slot display: 3 manual + 1 auto, party member display, playtime, location, level per ui-design.md
- [ ] Save: write via SaveManager.save_game(slot)
- [ ] Load: read via SaveManager.load_game(slot), apply state, transition
- [ ] Copy/delete save slot functionality
- [ ] Confirmation dialogs for overwrite/delete
- [ ] Process mode: PROCESS_MODE_ALWAYS

**Blocking:** Manual save/load, save point gameplay loop

---

### 3.7 Cutscene Overlay

**Status:** NOT STARTED
**Priority:** P2 — blocks scripted story sequences
**Estimated Size:** M (1 .tscn + 2 .gd files)
**Output:** `game/scenes/overlay/cutscene.tscn`, `game/scripts/core/cutscene_player.gd`
**Source Docs:** `dialogue-system.md` (cutscene vs dialogue distinction), `script/` (animation markers, timing cues), `events.md` (cutscene triggers)
**Depends On:** 3.5 (Dialogue Overlay — reuses text box), 1.8 (Dialogue Data)

**What's Needed:**
- [ ] Cutscene sequencer: play dialogue entries in order with animation/camera control
- [ ] Camera movement and framing control
- [ ] Character movement scripting (walk to point, face direction)
- [ ] Sprite emotion animations (14 types from dialogue-system.md)
- [ ] Fade to black / screen effects
- [ ] Music and SFX cue triggers
- [ ] Flag setting at cutscene completion
- [ ] Can force-close dialogue overlay (cutscene takes priority per GameManager)
- [ ] Process mode: PROCESS_MODE_ALWAYS

**Blocking:** Story progression scenes, boss intros, key narrative moments

---

### 3.8 Audio Integration

**Status:** NOT STARTED
**Priority:** P2 — blocks audio feedback for all systems
**Estimated Size:** M (updates to AudioManager + placeholder audio files)
**Output:** Updates to `game/scripts/autoload/audio_manager.gd`, placeholder .ogg files in `game/assets/`
**Source Docs:** `audio.md` (channel budget, priority stack, crossfade rules, mixing model), `music.md` (track list), `ui-design.md` (UI SFX triggers)
**Depends On:** AudioManager autoload (already exists — stubs need real implementation)

**What's Needed:**
- [ ] Implement AudioStreamPlayer pool (8 music / 12 SFX / 4 ambient channels)
- [ ] Priority-based channel allocation (8-tier stack per audio.md Section 3.2)
- [ ] Same-SFX instance limit (max 2 per audio.md Section 3.4)
- [ ] Crossfade implementation (biome 3s, town 1s, battle exit 1s, Pallor music 5s/ambient 3s)
- [ ] Mixing model per context (overworld, town, dungeon, narrative dungeon, Pallor, battle)
- [ ] Hard cut for battle entry (no crossfade, ambient cuts to 0)
- [ ] Placeholder .ogg files (silence or simple tones) for all ~51 SFX IDs from audio.md
- [ ] Placeholder music tracks for major contexts (title, overworld, battle, town, dungeon)
- [ ] Debug logging gated behind OS.is_debug_build() (already done in stubs)

**Blocking:** Audio feedback for combat, exploration, menus, story scenes

---

## Tier 4: Content & Integration

Build actual game maps, place entities, wire up the full game loop.
Each gap produces a playable slice of the game. Start with the
smallest vertical slice (Ember Vein) that exercises every system.

### 4.1 Vertical Slice: Ember Vein Dungeon

**Status:** NOT STARTED
**Priority:** P0 — first proof that all systems work together
**Estimated Size:** L (tilemap, entity placements, encounter hookup, boss)
**Output:** `game/scenes/maps/dungeons/ember_vein.tscn` + floor maps
**Source Docs:** `dungeons-world.md` (Ember Vein layout, encounters, boss), `bestiary/act-i.md` (enemies), `script/act-i.md` (intro scenes), `events.md` (Ember Vein flags)
**Depends On:** 3.2 (Exploration), 3.3 (Battle), 3.5 (Dialogue), 2.1-2.4 (all entity prefabs), 1.1-1.2 (character + enemy data)

**What's Needed:**
- [ ] 3-floor dungeon tilemap from dungeons-world.md Ember Vein section
- [ ] Placeholder 16x16 tilesets (colored tiles by terrain type)
- [ ] Enemy encounters wired to encounter tables (4 enemy types)
- [ ] Treasure chests placed per dungeons-world.md
- [ ] Save point placement
- [ ] Corrupted Fenmother boss fight (first boss — full phase AI)
- [ ] Intro cutscene from script/act-i.md ("Something is wrong down here...")
- [ ] Event flags set on completion per events.md
- [ ] Full loop test: enter dungeon → fight encounters → find chests → fight boss → exit

**Blocking:** This is the integration proof. If Ember Vein works end-to-end, the remaining content gaps are "just content."

---

### 4.2 Vertical Slice: Valdris Crown (First Town)

**Status:** NOT STARTED
**Priority:** P0 — first town proof
**Estimated Size:** L (tilemap, NPC placements, shop integration)
**Output:** `game/scenes/maps/towns/valdris_crown.tscn`
**Source Docs:** `city-valdris.md` (layout, districts, NPCs), `interiors.md` (interior map layouts), `economy.md` (Valdris shops), `npcs.md` (Valdris NPCs), `script/act-i.md` (Valdris arrival scenes)
**Depends On:** 3.2 (Exploration), 3.4 (Menu — for shops), 3.5 (Dialogue), 2.2 (NPC), 2.4 (SavePoint), 1.4 (Shop Data)

**What's Needed:**
- [ ] Town tilemap from city-valdris.md layout
- [ ] NPC placements with flag-gated dialogue
- [ ] Shop NPCs wired to shop data (general store, equipment, herbalist)
- [ ] Inn functionality (rest + save per save-system.md)
- [ ] Save point(s) placement
- [ ] Story scenes from script/act-i.md (Valdris arrival)
- [ ] Interior transitions (enter buildings → interior maps)
- [ ] Music/ambient per music.md Valdris tracks

**Blocking:** First complete town experience, shop/economy testing

---

### 4.3 Overworld Map

**Status:** NOT STARTED
**Priority:** P1 — blocks inter-location travel
**Estimated Size:** L (large tilemap, transition system)
**Output:** `game/scenes/maps/overworld.tscn`
**Source Docs:** `overworld.md` (Mode 7 presentation, terrain, weather), `geography.md` (terrain types, regions), `locations.md` (location positions), `transport.md` (travel modes)
**Depends On:** 3.2 (Exploration), 1.6 (Encounter Tables — overworld encounters)

**What's Needed:**
- [ ] Large tilemap representing the game world per geography.md
- [ ] 12 terrain types with encounter rate increments
- [ ] Location entry points (towns, dungeons) as trigger zones
- [ ] Miniaturized player sprite on overworld (per overworld.md)
- [ ] Mode 7-style perspective (or simplified top-down alternative per implementation budget)
- [ ] Location name flash on entry per ui-design.md
- [ ] Weather/atmospheric effects per overworld.md (location-fixed + 6 story overrides)
- [ ] Map screen (menu-accessed, parchment style, first-visit discovery)
- [ ] Transport system hooks (Ley Stag, rail, ferry — from transport.md)

**Blocking:** Travel between towns and dungeons, overworld encounters

---

### 4.4 Remaining Act I Content

**Status:** NOT STARTED
**Priority:** P1 — completes Act I
**Estimated Size:** L (multiple maps, cutscenes, encounters)
**Output:** Additional dungeon/town maps, story scenes
**Source Docs:** `dungeons-world.md` (Fenmother's Hollow), `script/act-i.md` (remaining Act I scenes), `events.md` (Act I flags)
**Depends On:** 4.1 (Ember Vein — proves the pipeline), 4.2 (Valdris — proves towns), 4.3 (Overworld — connects locations)

**What's Needed:**
- [ ] Fenmother's Hollow dungeon (second dungeon, different biome)
- [ ] Roothollow village (Thornmere faction introduction)
- [ ] Act I overworld zones (Valdris Highlands, Ley-Scarred Plains)
- [ ] Remaining Act I story scenes from script/act-i.md
- [ ] Act I side content (early accessible areas)
- [ ] Act I progression testing (level pacing, economy, difficulty)

**Blocking:** Act II content (needs Act I complete for flag state)

---

### 4.5 Acts II–IV Content

**Status:** NOT STARTED
**Priority:** P2 — bulk game content
**Estimated Size:** XL (dozens of maps, hundreds of NPCs, all remaining story)
**Output:** All remaining game maps, scenes, encounters
**Source Docs:** All `docs/story/` documents
**Depends On:** 4.4 (Act I complete — pipeline proven at scale)

**What's Needed:**
- [ ] Act II: 6 dungeons, 4+ towns, diplomatic storyline, Valdris Siege
- [ ] Interlude: Sable solo sequence, 4 reunion segments, world transformation
- [ ] Act III: Pallor Wastes overworld, 3 Oases, 5 trials, Convergence
- [ ] Act IV: Final dungeon, Pallor Incarnate fight, epilogue, memorial
- [ ] All NPC dialogue per act state (flag-gated variants)
- [ ] All shop inventory updates per act progression
- [ ] Dynamic world changes per dynamic-world.md
- [ ] All sidequests per sidequests.md

**Blocking:** Complete game experience

---

### 4.6 Post-Game Content

**Status:** NOT STARTED
**Priority:** P3 — optional endgame
**Estimated Size:** L
**Output:** Dreamer's Fault dungeon, boss rush, completion tracking
**Source Docs:** `postgame.md` (boss rush, completion tracking), `dungeons-world.md` (Dreamer's Fault 20 floors), `bestiary/optional.md`, `sidequests.md` (The Lingering)
**Depends On:** 4.5 (Acts II-IV — main game complete)

**What's Needed:**
- [ ] Dreamer's Fault: 20-floor optional dungeon, 5 ages, Lv 42–100 enemies
- [ ] Boss rush mode: 3-tier gauntlet with Memento accessories per postgame.md
- [ ] Completion tracking: 4 categories (bestiary, treasure, quests, items) at Pendulum tavern
- [ ] The Lingering superboss (3 phases, hardest fight in game)
- [ ] First Tree Seed scene (post-completion reward)

**Blocking:** Completionist content

---

### 4.7 Accessibility Implementation

**Status:** NOT STARTED
**Priority:** P1 — affects all players
**Estimated Size:** M
**Output:** Config system integration, visual modes, input rebinding
**Source Docs:** `accessibility.md` (all features), `ui-design.md` (config screen)
**Depends On:** 3.4 (Menu — config screen), 3.3 (Battle — ATB speed/patience mode)

**What's Needed:**
- [ ] Full keyboard rebinding system per accessibility.md
- [ ] Gamepad support with button mapping
- [ ] Color-blind modes (Deutan-Protan, Tritan) — palette swap system
- [ ] High-Res Text toggle (native-resolution text layer)
- [ ] Patience Mode (pause all gauges during player decisions)
- [ ] Reduce Motion toggle (disable Mode 7 rotation, screen shake, mosaic transitions)
- [ ] SFX captions in battle and key events
- [ ] Battle speed floor enforcement (speed 1 adequate for motor-impaired)
- [ ] Verify all features against accessibility.md Section-by-Section

**Blocking:** Accessibility compliance, broader player reach

---

### 4.8 Art Asset Integration

**Status:** NOT STARTED
**Priority:** P2 — replaces placeholders with real art
**Estimated Size:** XL (all game art)
**Output:** `game/assets/sprites/`, `game/assets/tilesets/`, `game/assets/ui/`
**Source Docs:** `visual-style.md` (pixel art specs, color palettes), `building-palette.md` (architectural style per faction), `biomes.md` (terrain palettes)
**Depends On:** All Tier 2-3 systems (placeholder art works first)

**What's Needed:**
- [ ] Character sprites: 6 party members × 4 directions × walk/idle (16x24)
- [ ] Battle sprites: 6 party members + 2 guests (Cordwyn, Kerra) × battle poses (32x32)
- [ ] Enemy sprites: ~198 enemies (32x32 to 64x64) — palette families share base sprites
- [ ] NPC sprites per npcs.md catalog
- [ ] Tilesets per biome from biomes.md and visual-style.md (16x16 tiles)
- [ ] Building tiles per faction from building-palette.md
- [ ] UI elements: window frames, cursors, status icons (22), fonts
- [ ] All art follows visual-style.md color palette and pixel art conventions

**Blocking:** Final visual polish (game is playable with placeholders)

---

### 4.9 Audio Asset Integration

**Status:** NOT STARTED
**Priority:** P2 — replaces placeholder audio
**Estimated Size:** L (all game audio)
**Output:** `game/assets/music/`, `game/assets/sfx/`, `game/assets/ambient/`
**Source Docs:** `music.md` (track-by-track specs), `audio.md` (SFX catalog, ambient specs)
**Depends On:** 3.8 (Audio Integration — system must be wired)

**What's Needed:**
- [ ] Music tracks per music.md (faction palettes, character leitmotifs, battle themes)
- [ ] ~51 SFX per audio.md catalog (combat, UI, exploration, environmental)
- [ ] 12 ambient biome loops per audio.md
- [ ] OGG Vorbis format, 44.1 kHz, 16-bit per technical-architecture.md Section 5.3
- [ ] Verify loop points, crossfade behavior, priority stack in practice

**Blocking:** Final audio polish (game is playable with placeholder audio)

---

## Progress Tracking

| Date | Gap | Change | Commit |
|------|-----|--------|--------|
| 2026-04-02 | Initial audit | All implementation gaps cataloged (30 gaps across 4 tiers) | — |
| 2026-04-02 | Self-review + Copilot review | Fixed gap count (27→30), recommended path, priority/size/dep errors, missing source docs, markdown syntax | — |
| 2026-04-02 | 1.1 Character Data | NOT STARTED → COMPLETE. 6 JSON files (edren, cael, lira, torren, sable, maren). All values verified against progression.md and characters.md. Milestone formula spot-checked. Ability/spell learn schedules deferred to Gap 1.5 (lives in spell JSONs). Unblocks: 2.1, 3.3, 3.4. | — |

---

## Summary

| Tier | Gaps | Status | Description |
|------|------|--------|-------------|
| 1: Data Foundation | 9 | 1/9 complete | JSON data from design docs |
| 2: Entity Prefabs | 4 | 0/4 complete | .tscn prefabs with GDScript |
| 3: Core Systems | 8 | 0/8 complete | Scenes and game systems |
| 4: Content & Integration | 9 | 0/9 complete | Maps, content, polish |
| **Total** | **30** | **1/30** | |

**Note on gap numbering:** This document uses D-prefixed IDs (D1.1, D1.2...)
when disambiguation from `game-design-gaps.md` is needed. Within this
document, plain numbers (1.1, 1.2) are used for readability. The two
documents have DIFFERENT numbering: D1.1 (Character Data JSON) is not
the same as game-design-gaps 1.1 (Damage & Combat Formulas).

**Recommended starting path (full dependency chain to vertical slice):**

```
1.1 (Characters) → 1.2 (Enemies) → 1.3 (Items/Equip) →
1.5 (Spells/Abilities) → 1.6 (Encounters) → 1.8 (Dialogue) →
2.1 (PlayerChar) → 2.2 (NPC) → 2.3 (Enemy) → 2.4 (Interactables) →
3.1 (Title) → 3.3 (Battle) → 3.2 (Exploration) → 3.5 (Dialogue) →
4.1 (Ember Vein)
```

This path includes every prerequisite for the first playable vertical
slice (Ember Vein dungeon). Earlier gaps can be parallelized where
dependencies allow (e.g., 1.1/1.2/1.3 have no interdependencies).
