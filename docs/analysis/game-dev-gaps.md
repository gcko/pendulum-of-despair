# Game Development Gap Analysis

> **Living document.** Updated by the `game-designer` skill as gaps are
> addressed. Status fields reflect the current state of each implementation
> area. Every value, formula, and behavior must trace back to a canonical
> design document in `docs/story/`.
>
> **Companion to:** `docs/analysis/game-design-gaps.md` (design docs — 24/25 COMPLETE)
> **Architecture reference:** `docs/plans/technical-architecture.md`
> **Engine:** Godot 4.6+ / GDScript only
> **Resolution:** 1280x720 native (changed from 320x180 on 2026-04-08), 4x camera zoom for game world, integer-scaled window

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
- `game/project.godot` — viewport 1280x720 (was 320x180), integer scaling, 6 autoloads, 4x camera zoom in exploration
- 6 autoload singletons in `game/scripts/autoload/` (GameManager,
  DataManager, AudioManager, SaveManager, EventFlags, PartyState) — all have
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
**Estimated Size:** M (26 JSON files, one per shop across 11 towns)
**Output:** `game/data/shops/{shop_id}.json`
**Source Docs:** `economy.md` (complete shop inventories per town with event-gated restocking)
**Architecture Ref:** `technical-architecture.md` Section 2.4
**Depends On:** 1.3 (Items & Equipment — item IDs must exist)

**What's Needed:**
- [x] Per-shop JSON following Section 2.4 schema (26 files, one per shop; originally 24, +2 from Phase C armorer split + jeweler)
- [x] All 10 town inventories from economy.md (102 unique item_ids across all shops)
- [x] Event-gated restock entries (available_act, restock_event)
- [x] Caldera 150% inflation pricing per economy.md (markup: 1.5 on Company shops)
- [x] Verify every item_id references an existing item/equipment ID from Gap 1.3
- [x] Verify prices match economy.md tables

**Notes:**
- 26 shop files (multiple shops per town; includes Roothollow herbalist from gap 4.4 and Phase C additions: weaponsmith, armorsmith, jeweler replacing single armorer)
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
**Estimated Size:** L (109 JSON files, 1034 entries)
**Output:** `game/data/dialogue/{scene_id}.json`, `game/data/dialogue/npc_{npc_id}.json`, `game/data/dialogue/battle_{context_id}.json`
**Source Docs:** `script/` (6,531 lines across 8 content files), `dialogue-system.md` (7-field entry format), `npcs.md` (NPC dialogue assignments)
**Architecture Ref:** `technical-architecture.md` Section 2.5
**Depends On:** None (foundational, but dialogue overlay in Tier 3 needed to display)

**What's Needed:**
- [x] Per-scene dialogue JSON following Section 2.5 schema (7-field entries)
- [x] 40 narrative scenes from script/ Layer 1 (661 entries)
- [x] NPC ambient dialogue from npc-ambient.md Layer 2 (43 files, 177 entries)
- [x] Battle dialogue from battle-dialogue.md Layer 3 (26 files, 196 entries)
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
- 109 total files (40 narrative + 43 NPC + 26 battle) with 1034 entries
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

**Status:** COMPLETE
**Completed:** 2026-04-05
**Priority:** P0 — blocks exploration, battle display
**Estimated Size:** M (1 .tscn + 1 .gd + 6 placeholder sprites + 1 test)
**Output:** `game/scenes/entities/player_character.tscn`, `game/scripts/entities/player_character.gd`
**Source Docs:** `visual-style.md` (16x24 character sprites), `characters.md` (movement), `overworld.md` (4-dir movement), `technical-architecture.md` Section 4.2
**Depends On:** 1.1 (Character Data — loads stats from JSON)

**What's Needed:**
- [x] CharacterBody2D scene tree per tech-arch Section 4.2
- [x] Sprite2D with placeholder 16x24 sprite (colored rectangle per character)
- [x] CollisionShape2D for movement collision (12x12 RectangleShape2D)
- [x] AnimationPlayer with stub animations (idle, walk_north/south/east/west)
- [x] GDScript: load character data from DataManager
- [x] GDScript: handle 4-direction movement input (no diagonal, pixel snapped)
- [x] GDScript: emit interaction signal via Area2D proximity detection
- [x] Snap to pixel grid (position.round() every frame)
- [x] Process mode INHERIT (pauses when GameManager sets tree paused)

**Notes:**
- 6 placeholder sprites: 16x24 colored rectangles (edren=blue, cael=red, maren=purple, sable=grey, lira=orange, torren=green)
- InteractionArea (Area2D) detects collision layer 3 (interactables)
- Movement: 80 px/sec, vertical priority when both axes pressed
- AnimationPlayer has stub animations — real 4-frame walk cycles added when art assets are created
- All code passes gdlint, GUT tests in test_player_character.gd
- First .tscn scene and GDScript entity in the project
- Design spec: `docs/superpowers/specs/2026-04-05-player-character-prefab-design.md`

**Blocking:** Exploration scene (needs player entity), battle scene (needs party display)

---

### 2.2 NPC Prefab

**Status:** COMPLETE
**Completed:** 2026-04-05
**Priority:** P1 — blocks town interactions
**Estimated Size:** S (1 .tscn + 1 .gd + 1 sprite + 1 test)
**Output:** `game/scenes/entities/npc.tscn`, `game/scripts/entities/npc.gd`
**Source Docs:** `dialogue-system.md` (NPC interaction model, priority stack, 14 emotions), `npcs.md` (NPC list), `technical-architecture.md` Section 4.2
**Depends On:** 1.8 (Dialogue Data — loads dialogue from JSON)

**What's Needed:**
- [x] Area2D scene tree per tech-arch Section 4.2 (layer 3, monitorable)
- [x] Sprite2D with placeholder 16x24 NPC sprite
- [x] CollisionShape2D for interaction zone (12x12 RectangleShape2D)
- [x] AnimationPlayer with idle + 14 sprite emotion animation stubs
- [x] GDScript: load dialogue from DataManager by NPC ID
- [x] ~~GDScript: on interact, call GameManager.push_overlay(DIALOGUE)~~ → signal-only: emits npc_interacted(npc_id, dialogue_data)
- [x] GDScript: flag-gated dialogue (priority stack with condition evaluator)
- [x] ~~GDScript: party-aware dialogue~~ → party_has() stubbed, returns false until GameManager.party exists

**Notes:**
- Signal-only design: NPC emits npc_interacted, exploration scene handles overlay push
- Priority stack: first-match-wins, walks entries top-to-bottom
- Condition evaluator: binary flags, numeric comparisons (>=, <, ==), AND combos, party_has (stubbed)
- 15 stub animations (idle + 14 emotions per dialogue-system.md Section 2.1)
- GUT tests in test_npc.gd, all code passes gdlint + gdformat
- **This completes ALL Tier 2 Entity Prefabs (4/4). Exploration scene (3.2) is fully unblocked.**
- Design spec: `docs/superpowers/specs/2026-04-05-npc-prefab-design.md`

**Blocking:** Town scenes (need NPCs), story progression (flag-gated dialogue)

---

### 2.3 Enemy Prefab (Battle)

**Status:** COMPLETE
**Completed:** 2026-04-05
**Priority:** P0 — blocks battle system
**Estimated Size:** S (1 .tscn + 1 .gd + 1 placeholder sprite + 1 test)
**Output:** `game/scenes/entities/enemy.tscn`, `game/scripts/entities/enemy.gd`
**Source Docs:** `bestiary/README.md` (type rules, stat template), `combat-formulas.md` (elemental multipliers), `technical-architecture.md` Section 4.2
**Depends On:** 1.2 (Enemy Data — loads stats from JSON)

**What's Needed:**
- [x] Node2D scene tree per tech-arch Section 4.2
- [x] Sprite2D for enemy battle sprite (32x32 placeholder)
- [x] AnimationPlayer with idle, hit_reaction, death stub animations
- [x] GDScript: load enemy data from DataManager by enemy ID
- [x] GDScript: runtime HP/MP/status tracking
- [x] ~~GDScript: weighted-random AI~~ → deferred to gap 3.3 (Battle Scene)
- [x] ~~GDScript: scripted AI for bosses~~ → deferred to gap 3.3 (Battle Scene)
- [x] GDScript: elemental profile checks (weakness/resistance/immune/absorb with correct multipliers)
- [x] GDScript: status effect vulnerability checks (per-enemy + type default immunities)
- [x] GDScript: drop/steal resolution (common, rare rates)

**Notes:**
- AI (weighted-random + boss scripted) deferred to gap 3.3 — requires ATB turn loop
- TYPE_IMMUNITIES const maps 8 enemy types to default status immunities per bestiary/README.md
- Elemental multipliers: -1.0 (absorb), 0.0 (immune), 0.75 (resist), 1.5 (weak), 1.0 (neutral)
- Status system: apply/remove/tick/has_status with duration tracking
- Signals: damage_taken, healed, status_applied, status_removed, died
- GUT tests in test_enemy.gd, all code passes gdlint + gdformat
- Design spec: `docs/superpowers/specs/2026-04-05-enemy-prefab-design.md`

**Blocking:** Battle scene (needs enemies to fight)

---

### 2.4 Interactable Prefabs (Chest, Trigger, SavePoint)

**Status:** COMPLETE
**Completed:** 2026-04-05
**Priority:** P1 — blocks dungeon/town furnishing
**Estimated Size:** M (3 .tscn + 3 .gd + 3 sprites + 1 test)
**Output:** `game/scenes/entities/{treasure_chest,trigger_zone,save_point}.tscn`, matching .gd scripts
**Source Docs:** `save-system.md` (save point), `events.md` (flag triggers), `items.md` (chest contents), `overworld.md` (save points), `technical-architecture.md` Section 4.2
**Depends On:** 1.3 (Items — chest contents reference item IDs)

**What's Needed:**
- [x] TreasureChest: Area2D, closed/open sprites, chest_id tracking, EventFlags persistence, chest_opened signal
- [x] TriggerZone: Area2D, condition flag check, one-time body_entered fire, triggered signal
- [x] SavePoint: Area2D, shimmer animation, save_point_activated + save_point_entered signals
- [x] All three: collision layer 3 (bitmask 4), signal-only responses, process_mode INHERIT
- [x] ~~Verify chest contents~~ → deferred (chest contents are map-placement data, not prefab concern)
- [x] ~~Verify trigger flags~~ → deferred (flag names validated at map-placement time in gap 3.2)

**Notes:**
- Signal-only design: prefabs emit events, exploration scene handles overlays/inventory/audio
- TreasureChest: interact() checks/sets EventFlags, swaps sprite, emits chest_opened(id, item_id)
- TriggerZone: auto-fires on body_entered (not explicit interaction), one-time with EventFlags
- SavePoint: interact() emits save_point_activated, body_entered emits save_point_entered (proximity)
- GUT tests in test_interactables.gd, all code passes gdlint + gdformat
- Design spec: `docs/superpowers/specs/2026-04-05-interactable-prefabs-design.md`

**Blocking:** Dungeon maps (need chests, triggers, save points), story progression (trigger zones drive events)

---

## Tier 3: Core Systems & Scenes

Wire up the game systems. Each builds on Tier 1 data + Tier 2 entities.
These are the core .tscn scenes and their orchestrating GDScript.

### 3.1 Title Screen

**Status:** COMPLETE
**Completed:** 2026-04-06
**Priority:** P1 — blocks game entry point
**Estimated Size:** S (1 .tscn + 1 .gd)
**Output:** `game/scenes/core/title.tscn`, `game/scripts/core/title.gd`
**Source Docs:** `ui-design.md` (title screen layout), `audio.md`/`music.md` (title music)
**Depends On:** None (minimal — just needs GameManager for transitions)

**What's Needed:**
- [x] Title screen scene with game logo placeholder, menu options (New Game, Continue, Config)
- [x] New Game: initialize fresh game state, transition to Exploration
- [x] Continue: ~~show save slot selection~~ loads most recent save via SaveManager.load_most_recent(), transition to Exploration
- [x] ~~Config: push config overlay~~ → Config stubbed (greyed out), deferred to gap 3.4
- [ ] ~~Title music playback via AudioManager~~ → deferred to gap 3.8 (Audio Integration)
- [x] Keyboard/gamepad navigation per accessibility.md input spec
- [x] Set as `run/main_scene` in project.godot (first runnable scene)

**Notes:**
- Bundled with gaps 3.5 (Dialogue) and 3.6 (Save/Load) in one PR
- Continue greyed out when no saves exist, shows error on corrupted save
- Config greyed out with stub — opens nothing until gap 3.4 (Menu Overlay)
- SaveManager gained 5 new public methods: load_most_recent(), has_any_save(), get_slot_previews(), delete_slot(), copy_slot()
- GUT tests in test_title.gd, all code passes gdlint + gdformat
- Design spec: `docs/superpowers/specs/2026-04-06-title-dialogue-saveload-design.md`
- **Game is now launchable in Godot editor** (first runnable scene)

**Blocking:** Game is not runnable without a main scene. This is the entry point.

---

### 3.2 Exploration Scene

**Status:** MOSTLY COMPLETE
**Completed:** 2026-04-06 (Minimal Viable — Option A)
**Priority:** P0 — blocks all overworld/town/dungeon gameplay
**Estimated Size:** L (1 .tscn + 1 .gd + test maps)
**Output:** `game/scenes/core/exploration.tscn`, `game/scripts/core/exploration.gd`, test map scenes
**Source Docs:** `overworld.md` (movement, transitions, weather), `combat-formulas.md` (danger counter, encounter trigger), `geography.md` (terrain types), `save-system.md` (auto-save triggers), `technical-architecture.md` Section 3
**Depends On:** 2.1 (PlayerCharacter), 2.2 (NPC), 2.4 (Interactables), 1.6 (Encounter Tables)

**What's Needed:**
- [ ] ~~TileMapLayer-based map rendering~~ → test maps use ColorRect backgrounds; real tilemaps deferred to gap 4.1
- [x] Map loading system (load .tscn map files by ID)
- [x] Player character instantiation and movement
- [x] NPC, chest, trigger, save point placement from map data
- [x] Camera2D following player (pixel-snapped, integer zoom only)
- [x] Danger counter system — EncounterSystem static helper + step detection in exploration
- [x] Random encounter trigger — weighted group selection, formation roll, battle entry
- [x] Map transition (door/exit → fade to black → load new map)
- [x] Menu button — wired in PR #122 (gap 3.4 phase 1)
- [x] NPC/chest/save interaction → appropriate overlay
- [ ] ~~Auto-save triggers~~ → deferred until exploration is stable
- [ ] ~~Audio context switching~~ → deferred to gap 3.8 (Audio Integration)

**Notes:**
- Minimal Viable Exploration (Option A): core integration only, no encounters/audio/menu
- Map scenes loaded dynamically from res://scenes/maps/ by ID
- Entity signals wired on map load, disconnected on unload
- NPC dialogue_data wrapped in array for dialogue_box.show_dialogue() contract
- Fade-to-black transitions via Tween on ColorRect (0.3s each direction)
- Location name flash per ui-design.md 15.2 (fade in 0.5s, hold 2s, fade out 0.5s)
- PlayerCharacter gained try_interact() public method for exploration input handling
- New Game initializes from GameManager.transition_data, Continue restores position from save
- 2 test maps (test_room with entities, test_room_2 for transitions)
- GUT tests in test_exploration.gd (10 tests), all code passes gdlint + gdformat
- Design spec: `docs/superpowers/specs/2026-04-06-exploration-scene-design.md`
- **The game now has a walkable, interactive world** — player can explore, talk to NPCs, open chests, save, and transition between maps
- Encounter loop wired: danger counter increments per step (16px tile), EncounterSystem static helper handles check/roll/select/formation, battle entry/return with rewards. Floor-ID config selection deferred (always uses first floor/zone entry). Act scaling hardcoded 1.0 (deferred to gap 4.1)
- XP distribution: active alive = full, KO'd = 0, reserve = 50%. Level-up recalculates stats from character JSON. XP clamped to 0 at level 150
- Accessory encounter modifiers: Ward Talisman/Infiltrator's Cloak ×0.5, Lure Talisman ×2.0
- Design spec: `docs/superpowers/specs/2026-04-06-encounter-battle-rewards-loop-design.md`

**Blocking:** All overworld, town, and dungeon gameplay

---

### 3.3 Battle Scene

**Status:** MOSTLY COMPLETE
**Completed:** 2026-04-06 (Core Battle System)
**Priority:** P0 — blocks all combat
**Estimated Size:** L (1 .tscn + 8 .gd files for battle subsystems)
**Output:** `game/scenes/core/battle.tscn`, `game/scripts/combat/` (battle_manager.gd, atb_system.gd, damage_calculator.gd, battle_state.gd, battle_ai.gd), `game/scripts/ui/` (battle_ui.gd, battle_party_panel.gd, battle_command_menu.gd)
**Source Docs:** `combat-formulas.md` (ALL formulas), `ui-design.md` (battle screen layout), `abilities.md`, `magic.md`, `items.md` (battle-usable items), `difficulty-balance.md` (pacing targets)
**Depends On:** 2.3 (Enemy Prefab), 1.1 (Character Data), 1.2 (Enemy Data), 1.5 (Spells & Abilities)

**What's Needed:**
- [x] ATB gauge system: `floor((SPD + 25) * battle_speed_factor * status_modifiers)` per combat-formulas.md
- [x] Active vs Wait mode (gauge pauses during menu in Wait mode)
- [x] Battle speed 1-6 scale
- [x] Turn order resolution when multiple gauges fill simultaneously
- [x] Physical damage: `(ATK * ATK) / 6 - DEF` with variance `random_int(240,255)/256`
- [x] Magical damage: `MAG × power / 4 - MDEF` with element multiplier
- [x] Healing: `MAG × power × 0.8`
- [x] Critical hit: `LCK/4` rate (cap 50%), 2× damage
- [x] Hit/miss: 3-stage resolution (accuracy vs evasion) per combat-formulas.md
- [x] Elemental multipliers: 1.5× weak, 0.75× disadvantage, 0.5× same, 0× immune, -1× absorb
- [ ] ~~Status effect application~~ → Formula in damage_calculator.gd, apply path not wired in combat actions yet
- [x] Row system: front/back, 50% physical modifier, back-row spears bypass
- [x] 6 command types: Attack, Magic, Ability, Item, Defend, Flee
- [x] Flee formula per combat-formulas.md (SPD-based)
- [x] Battle UI per ui-design.md: party panel (HP/MP bars, ATB gauge), enemy area, command menu, damage numbers
- [x] Victory: XP/gold/drops distribution — add_xp_to_member with level-up, active/KO/reserve split, drops in transition data
- [ ] ~~Defeat: Faint-and-Fast-Reload~~ → Exploration handles faint result and calls SaveManager.faint_and_fast_reload(). SaveManager load/merge logic deferred
- [ ] ~~Boss battles: scripted AI~~ → Boss AI stubbed (basic attack only). Scripted phase behavior deferred to gap 4.1+
- [x] Formation types: Normal, Back Attack, Preemptive
- [ ] ~~Battle music via AudioManager~~ → deferred to gap 3.8 (Audio Integration)
- [x] Damage cap: 14,999 (mirrors HP cap)
- [ ] ~~Status icons (22 unified icons)~~ → Status text tracked, icon rendering deferred to UI polish
- [ ] ~~Patience Mode~~ → ATB mode flag implemented, full patience pause deferred to gap 3.4 (Config)
- [ ] ~~Combat interactions (Frozen Shatter, etc.)~~ → Hooks in place, not implemented (gap 4.1+)
- [ ] ~~Equipment stat modifiers~~ → Base stats only, equipment bonuses deferred to gap 3.4 (Menu)
- [ ] ~~Maren WG visual bar~~ → Tracked in state, purple bar deferred to UI polish

**Notes:**
- 6 combat scripts + 3 UI scripts + 1 .tscn scene + 4 test files
- Architecture: damage_calculator.gd (pure static formulas), atb_system.gd (gauge ownership), battle_state.gd (party runtime), battle_ai.gd (weighted-random), battle_manager.gd (orchestrator)
- Signal-based decoupling: battle_manager emits signals, battle_ui observes
- All formulas verified against combat-formulas.md milestone tables in test_damage_calculator.gd
- GUT tests exist but GUT framework has compatibility issues with Godot 4.6 (.uid regeneration)
- Design spec: `docs/superpowers/specs/2026-04-06-battle-scene-design.md`
- **This unblocks gap 4.1 (Ember Vein vertical slice)** — the critical path to first playable dungeon

**Blocking:** All combat gameplay. This is the most complex single system.

---

### 3.4 Menu Overlay

**Status:** COMPLETE
**Completed:** 2026-04-11 (Ley Crystal screen — all 9 screens done)
**Priority:** P1 — blocks inventory management, equipment, party setup
**Estimated Size:** L (1 .tscn + 10+ .gd files for sub-screens)
**Output:** `game/scenes/overlay/menu.tscn`, `game/scripts/ui/` (menu screens), `game/scripts/autoload/party_state.gd`
**Source Docs:** `ui-design.md` (all 14 screen designs — 1,180 lines)
**Depends On:** 1.1 (Character Data), 1.3 (Items & Equipment), 1.4 (Shop Data — for buy/sell screens), 1.5 (Spells & Abilities)

**What's Needed:**
- [x] 9-command main menu: Items, Equipment, Magic, Abilities, Status, Formation, Ley Crystals, Config, Save (only at save points)
- [x] Items screen: categorized list, use/discard, stack counts
- [x] Equipment screen: 5 slots per character, stat comparison display
- [x] Magic screen: two-column spell grid, field-cast healing only, MP deduction — Phase 2 (2026-04-07)
- [x] Abilities screen: view-only, all 6 characters, cost_type-adaptive display — Phase 2 (2026-04-08)
- [x] Status screen: full stat display, equipment summary, elemental profile
- [x] Formation screen: swap reorder, row toggle (F/B), active+reserve list — Phase 2 (2026-04-08)
- [x] Ley Crystal screen: browse/detail/equip, XP bar, stat comparison, negative effects — 2026-04-11
- [x] Config screen: all 17 settings from accessibility.md (with cascade logic)
- [x] All screens: keyboard/gamepad navigation, cursor memory, per ui-design.md specs
- [x] Process mode: PROCESS_MODE_ALWAYS (runs while game paused)
- [x] PartyState autoload: runtime party/inventory/equipment state
- [x] SaveManager wired to PartyState (build/apply save data)
- [x] Title screen: New Game initializes PartyState, Config opens menu overlay
- [x] Exploration: Escape key opens menu overlay
- [x] Shop buy/sell interface — buy-only via shop_overlay.gd (2026-04-07)

**Phase 3: FF6-Style UI Polish (COMPLETE — 2026-04-08)**
- [x] All 7 sub-screens use FF6-style bordered panels (StyleBoxFlat with flat dark blue + border + shadow glow)
- [x] Sub-screens fully replace MainPanel/CommandPanel/InfoPanel (hidden on open, restored on close)
- [x] Item screen: TabPanel + DescPanel + ListPanel + TargetPanel
- [x] Config screen: HeaderRow + SettingsPanel + FooterRow with desc/hints
- [x] Equipment screen: ModePanel + SlotPanel + StatPanel + ItemListPanel
- [x] Magic screen: DescPanel + CharPanel + SpellPanel (2-col grid)
- [x] Formation screen: TitlePanel + MemberPanel + HintPanel
- [x] Status screen: IdentityPanel + DetailRow (Stats + Equipment side-by-side)
- [x] Abilities screen: DescPanel + CharPanel + AbilityPanel (2-col grid)
- [x] Viewport: 1280x720 with 4x camera zoom, all UI at native resolution
- [x] Design spec: docs/superpowers/specs/2026-04-08-menu-ui-polish-design.md

**Notes:**
- Phase 1: 5 screens (Items, Equipment, Status, Config, Save) + framework
- Phase 2 progress: Magic, Abilities, Formation, Shop buy-only — all complete
- Ley Crystal screen complete (2026-04-11): browse/detail drill-down, XP bar, stat comparison, equip/unequip, save/load, crystal XP from battle rewards (30%)
- All 9 core menu screens implemented. PartyState.ley_crystals dict tracks crystal XP/level runtime state.
- PartyState: spend_mp(), heal_member() added for Magic field-cast
- Config screen implements Patience Mode and Reduce Motion cascade logic per accessibility.md
- Equipment screen has live stat comparison with green/red delta indicators
- Viewport changed to 1280x720 with 4x camera zoom (2026-04-08). Main menu frame, dialogue (FF6 inline speaker), and save screen layouts fixed. Sub-screen polish deferred to Phase 3.
- Beads issue: pendulum-of-despair-afs (P1)
- Design spec: `docs/superpowers/specs/2026-04-06-menu-overlay-phase1-design.md`

**Blocking:** Player inventory management, equipment optimization, party configuration

---

### 3.5 Dialogue Overlay

**Status:** COMPLETE
**Completed:** 2026-04-06
**Priority:** P1 — blocks all NPC interaction and story scenes
**Estimated Size:** M (1 .tscn + 1 .gd)
**Output:** `game/scenes/overlay/dialogue.tscn`, `game/scripts/ui/dialogue_box.gd`
**Source Docs:** `ui-design.md` Section 12 (text box specs), `dialogue-system.md` (rendering rules, typewriter effect, choice prompts)
**Depends On:** 1.8 (Dialogue Data)

**What's Needed:**
- [x] Full-width text box at screen bottom per ui-design.md
- [x] Typewriter text effect with configurable speed (instant, fast, normal, slow)
- [x] Speaker name display (top-left of text box)
- [x] 3-line text box limit per ui-design.md (pagination for entries with >3 lines)
- [x] Button press to advance (with "waiting" indicator — bouncing advance arrow)
- [x] Choice prompt display with cursor navigation (2-4 options, cancel selects bottom)
- [x] Animation trigger system (animation_requested signal with who + anim)
- [x] SFX trigger system (sfx_requested signal with sfx_id)
- [x] ~~Flag condition evaluation~~ → not needed here; NPC prefab resolves priority stack before emitting
- [x] Flag setting on dialogue completion (flag_set_requested signal)
- [x] Process mode: PROCESS_MODE_ALWAYS

**Notes:**
- Bundled with gaps 3.1 (Title) and 3.6 (Save/Load) in one PR
- Signal-only design: dialogue overlay emits animation_requested/sfx_requested, parent scene handles playback
- Text speed reads from config defaults.json (default: "normal" = 60 cps)
- Empty entries array immediately emits dialogue_finished and pops overlay
- Cael's grey border flicker (Act IV) deferred to gap 3.7 (Cutscene)
- GUT tests in test_dialogue.gd (14 tests), all code passes gdlint + gdformat
- Design spec: `docs/superpowers/specs/2026-04-06-title-dialogue-saveload-design.md`
- **This unblocks gap 3.7 (Cutscene Overlay)** which depends on 3.5

**Blocking:** All NPC dialogue, story scenes, tutorials, quest interactions

---

### 3.6 Save/Load Overlay

**Status:** COMPLETE
**Completed:** 2026-04-06
**Priority:** P1 — blocks manual saving
**Estimated Size:** M (1 .tscn + 1 .gd)
**Output:** `game/scenes/overlay/save_load.tscn`, `game/scripts/ui/save_load.gd`
**Source Docs:** `save-system.md` (save point 3-option menu, slot display), `ui-design.md` (save/load screen layout), `overworld.md` (save point specification)
**Depends On:** SaveManager autoload (already exists)

**What's Needed:**
- [x] Save point 3-option menu: Rest, Rest & Save, Save per save-system.md Section 5
- [x] ~~Rest: consume tiered rest item (Sleeping Bag/Tent/Pavilion), restore HP/MP per save-system.md~~ → Rest sub-menu UI shown but consumption stubbed (push_warning), deferred to gap 3.4
- [x] Save/Load slot display: 3 manual + 1 auto, party member display, playtime, location, level per ui-design.md
- [x] Save: write via SaveManager.save_game(slot)
- [x] Load: read via SaveManager.load_game(slot), apply state, transition
- [x] Copy/delete save slot functionality (methods exist; UI flow for Copy/Delete deferred to gap 3.4 operations menu)
- [x] Confirmation dialogs for overwrite/delete (overwrite works; delete UI path deferred to gap 3.4)
- [x] Process mode: PROCESS_MODE_ALWAYS

**Notes:**
- Bundled with gaps 3.1 (Title) and 3.5 (Dialogue) in one PR
- Sub-state machine: SAVE_POINT_MENU → REST_MENU / SLOT_SELECT → CONFIRM
- Rest item consumption stubbed with push_warning — full implementation needs inventory system (gap 3.4)
- Inn rest variant (paid rest) deferred to gap 3.2 (Exploration Scene)
- Load screen: auto slot (blue accent) + divider + 3 manual slots, corrupted slots shown in red
- Auto-save slot can be loaded; copy-from promotion deferred to gap 3.4 operations menu
- Selected slot highlighted with gold modulate; cursor repositions on navigation
- GUT tests in test_save_load.gd (12 tests), all code passes gdlint + gdformat
- Design spec: `docs/superpowers/specs/2026-04-06-title-dialogue-saveload-design.md`

**Blocking:** Manual save/load, save point gameplay loop

---

### 3.7 Cutscene Overlay

**Status:** COMPLETE
**Completed:** 2026-04-13
**Priority:** P2 — blocks scripted story sequences
**Estimated Size:** M (1 .tscn + 3 .gd files + 5 test files)
**Output:** `game/scenes/overlay/cutscene.tscn`, `game/scripts/core/cutscene_player.gd`, `game/scripts/ui/cutscene_letterbox.gd`
**Source Docs:** `dialogue-system.md` (cutscene vs dialogue distinction), `script/` (animation markers, timing cues), `events.md` (cutscene triggers)
**Depends On:** 3.5 (Dialogue Overlay — reuses text box), 1.8 (Dialogue Data)

**What's Needed:**
- [x] Cutscene sequencer: play entries in order with 10 command types (fade, move, camera, wait, shake, flash, title, music, hide/show_dialogue)
- [x] Camera movement and framing control (signal-based via cutscene_camera_requested)
- [x] Character movement scripting (walk_to on PlayerCharacter + NPC)
- [x] Sprite emotion animations (14 types, forwarded from embedded dialogue_box)
- [x] Fade to black / screen effects (fade, flash, title card)
- [x] Music and SFX cue triggers (signals emitted, AudioManager wiring deferred to 3.8)
- [x] Flag setting at cutscene completion (per-entry flag_set + cutscene_seen skip flags)
- [x] Can force-close dialogue overlay (cutscene takes priority per GameManager)
- [x] Process mode: PROCESS_MODE_ALWAYS
- [x] T1 letterbox bars (animate in/out) + T4 micro-cutscene (no letterbox)
- [x] Embedded dialogue_box mode (embedded_mode suppresses pop_overlay)
- [x] Skip flag system (supports faint-and-reload persistence)
- [x] ~57 tests across 5 test files (620/620 full suite)

**Notes:**
- T2 (Walk-and-Talk) and T3 (Playable Scene) deferred — they are exploration-mode behaviors, not overlays
- Ley Line Rupture montage (Interlude Scene 20) deferred to gap 4.5
- Boss-integrated cutscenes (dialogue at HP thresholds) handled by battle_manager.gd, not this overlay
- cutscene_player.gd is root script on CanvasLayer — GameManager.overlay_node IS the cutscene player
- Headless-safe: fade/flash/title skip tweening in headless mode (avoids rp_target null errors); letterbox currently still uses tweening
- Design spec: `docs/superpowers/specs/2026-04-13-cutscene-overlay-design.md`

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

**Status:** MOSTLY COMPLETE
**Completed:** 2026-04-07 (Approach B — Two-Floor + Boss vertical slice)
**Priority:** P0 — first proof that all systems work together
**Estimated Size:** L (tilemap, entity placements, encounter hookup, boss)
**Output:** `game/scenes/maps/dungeons/ember_vein_f1.tscn`, `ember_vein_f2.tscn`, `ember_vein_f4.tscn`
**Source Docs:** `dungeons-world.md` (Ember Vein layout, encounters, boss), `bestiary/act-i.md` (enemies), `script/act-i.md` (intro scenes), `events.md` (Ember Vein flags)
**Depends On:** 3.2 (Exploration), 3.3 (Battle), 3.5 (Dialogue), 2.1-2.4 (all entity prefabs), 1.1-1.2 (character + enemy data)

**What's Needed:**
- [x] 3-floor dungeon tilemap (F1, F2, F4 with placeholder 4-color TileMapLayer)
- [x] Placeholder 16x16 tilesets (4-tile colored squares: floor, wall, crystal, stairs)
- [x] Enemy encounters wired to encounter tables (4 types via floor-specific config)
- [x] Treasure chests placed (9 items across 3 floors)
- [x] Save point placement (F1, F2)
- [x] Vein Guardian boss fight (hardcoded 2-phase scripted AI)
- [x] Ember Drake mini-boss fight (weighted-random AI)
- [ ] ~~Intro cutscene~~ → stub via dialogue overlay (4 story beats)
- [x] Event flags set on completion (pendulum_discovered, vaelith_ember_vein)
- [x] Full loop test possible: test_room → F1 → F2 → F4 → boss → test_room
- [x] PartyState live data wired into battle (level-ups carry between fights)
- [x] Boss encounter trigger zones (flag-gated, one-shot)
- [x] Dialogue trigger zones with canonical script/act-i.md lines

**Notes:**
- Vertical slice: 3 floors (F1 Upper Mine, F2 Lower Mine, F4 Boss Arena). Floor 3 (Ancient Ruin) deferred — puzzles and key items not in scope
- TileMapLayer pipeline validated with placeholder tileset + physics collision
- Vein Guardian AI is hardcoded in battle_manager.gd — **tech debt: refactor to data-driven boss_ai.gd when second boss exists**
- Ember Drake uses weighted-random AI — canonical AI is conditional priority-list (deferred)
- Post-boss exit goes to test_room — replace when overworld (gap 4.3) exists
- Dialogue stubs use existing dialogue overlay, not cutscene system (gap 3.7)
- Floor-specific encounter config: F1 uses floor_id "1-2", F2 uses floor_id "3" from encounter JSON
- Design spec: `docs/superpowers/specs/2026-04-07-ember-vein-vertical-slice-design.md`
- **The game now has a playable 3-floor dungeon** with random encounters, mini-boss, scripted boss, treasure, save points, dialogue, and event flags

**Blocking:** This is the integration proof. If Ember Vein works end-to-end, the remaining content gaps are "just content."

---

### 4.2 Vertical Slice: Valdris Crown (First Town)

**Status:** MOSTLY COMPLETE
**Priority:** P0 — first town proof
**Estimated Size:** L (tilemap, NPC placements, shop integration)
**Completed:** 2026-04-07
**Output:** `game/scenes/maps/towns/valdris_lower_ward.tscn`, `game/scenes/maps/towns/valdris_anchor_oar.tscn`, `game/scenes/overlay/shop_overlay.tscn`
**Source Docs:** `city-valdris.md` (layout, districts, NPCs), `interiors.md` (interior map layouts), `economy.md` (Valdris shops), `npcs.md` (Valdris NPCs), `script/act-i.md` (Valdris arrival scenes)
**Depends On:** 3.2 (Exploration), 3.4 (Menu — for shops), 3.5 (Dialogue), 2.2 (NPC), 2.4 (SavePoint), 1.4 (Shop Data)

**What's Done (Lower Ward vertical slice):**
- [x] Lower Ward exterior tilemap (40x35 tiles, placeholder)
- [x] Anchor & Oar tavern interior (16x14 tiles)
- [x] 7 NPCs with flag-gated dialogue (Bren, Wynn, Old Harren, Renn, Thessa, Sgt. Marek, Nella)
- [x] 2 shop NPCs wired to existing shop JSON (general store, armorer)
- [x] Buy-only shop overlay (new SHOP overlay state + scene)
- [x] Inn functionality (rest via Renn, 150g, restores HP/MP/AC)
- [x] 2 save points (Chapel exterior, tavern interior)
- [x] Transitions: South Gate ↔ test_room, exterior ↔ tavern
- [x] Encounter logic extracted to encounter_handler.gd

**What Remains (deferred to gap 4.4):**
- [ ] Districts B-E (Citizen's Walk, Court Quarter, Royal Keep, Eastern Wall)
- [ ] Scene 7 story sequence (needs 6-person party + cutscene system 3.7)
- [ ] Specialty/Accessory shop, Armor Shop (Citizen's Walk district)
- [ ] Tavern upper floor, Barracks interior, Chapel interior, Cael's Quarters
- [ ] Act II shop restocking (diplomatic_mission_start)
- [ ] Music/ambient per music.md (gap 3.8)
- [ ] Story scenes from script/act-i.md Scene 7

**Notes:**
- Shop overlay is buy-only (no sell mode, no quantity picker)
- encounter_handler.gd extracted from exploration.gd for line budget
- PartyState.rest_at_inn() added for inn healing
- Placeholder 6-tile tileset (4 dungeon + 2 town tiles)

**Blocking:** First complete town experience, shop/economy testing

---

### 4.3 Overworld Map

**Status:** MOSTLY COMPLETE
**Priority:** P1 — blocks inter-location travel
**Estimated Size:** L (large tilemap, transition system)
**Completed:** 2026-04-08 (vertical slice)
**Output:** `game/scenes/maps/overworld.tscn`
**Source Docs:** `overworld.md` (Mode 7 presentation, terrain, weather), `geography.md` (terrain types, regions), `locations.md` (location positions), `transport.md` (travel modes)
**Depends On:** 3.2 (Exploration), 1.6 (Encounter Tables — overworld encounters)

**What's Done (vertical slice):**
- [x] Walkable 60x40 tile overworld map (Valdris Highlands)
- [x] 2 location entry triggers (Valdris Crown, Ember Vein)
- [x] Bidirectional transitions: overworld ↔ town, overworld ↔ dungeon
- [x] Random encounters via existing overworld.json (valdris_highlands zone)
- [x] Location name flash on map entry
- [x] Placeholder tileset extended with grass + water tiles (8 total)
- [x] New game starts on overworld (replaced test_room)

**What Remains (deferred):**
- [ ] Mode 7-style perspective rendering (shader + camera work)
- [ ] Miniaturized 8x12 player sprite on overworld
- [ ] Full continent tilemap (20+ locations, 12 terrain types)
- [ ] Weather/atmospheric effects per biome
- [ ] Map screen (parchment style, discovery system)
- [ ] Transport system (Ley Stag, rail, ferry, Linewalk)
- [ ] Region boundary banners
- [ ] Story-triggered atmospheric overrides
- [ ] Structural tilemap changes (fissures, crater, petrification)

**Blocking:** Travel between towns and dungeons, overworld encounters

---

### 4.4 Remaining Act I Content

**Status:** MOSTLY COMPLETE
**Priority:** P1 — completes Act I
**Estimated Size:** XL (multiple phases)
**Output:** Additional dungeon/town maps, story scenes
**Source Docs:** `dungeons-world.md`, `script/act-i.md`, `events.md`, `economy.md`, `npcs.md`, `locations.md`
**Depends On:** 4.1, 4.2, 4.3 (all MOSTLY COMPLETE)

**Phase A: Wilds Route (COMPLETE — 2026-04-08)**
- [x] Roothollow village map (30x25 tiles, Vessa NPC, herbalist shop, save point)
- [x] Maren's Refuge interior map (16x14 tiles, Maren NPC)
- [x] Overworld transitions to both locations (bidirectional)
- [x] Scene 5 dialogue trigger (Torren joins party via torren_encounter.json)
- [x] Scene 6 dialogue trigger (Maren joins party via scene_6_marens_warning.json)
- [x] PartyState.add_member() and has_member() public API
- [x] Roothollow herbalist shop (roothollow_herbalist.json, 9 consumable items)
- [x] Thornmere Wilds overworld encounter zone added to overworld.json
- [x] Tileset extended to 10 tiles (forest floor, bioluminescent)
- [x] dialogue_scene_id + required_flag support in exploration.gd dialogue triggers
- [x] Integration tests (test_wilds_route.gd, ~25 tests)
- [x] Design spec: `docs/superpowers/specs/2026-04-08-wilds-route-design.md`

**Phase A2: Fenmother's Hollow (MOSTLY COMPLETE — 2026-04-09)**
- [x] 3 floor maps: F1 Flooded Entry (45x30), F2 Submerged Temple (50x35), F3 Sanctum (35x25)
- [x] Swamp tileset: 4 new tiles (marsh floor, shallow water, stone wall, crystal root) at indices 10-13
- [x] 7 regular enemy types in act_i.json (marsh_serpent through corrupted_spawn); 2 bosses in bosses.json (drowned_sentinel, corrupted_fenmother)
- [x] Encounter data verified (fenmothers_hollow.json: floors "1-2" and "3")
- [x] 3 dialogue files: fenmother_battle.json, water_of_life.json, fenmother_cleansing.json
- [x] Drowned Sentinel mini-boss AI (Barnacle Shield/Frost Wave/Stone Slam cycle)
- [x] Corrupted Fenmother 3-phase boss AI (dive/surface, add spawning, victory interception)
- [x] Cleansing wave sequence: 4 sequential battles after boss HP reaches 0
- [x] Flag-gated transitions (required_flag on Area2D, blocks F2→F3 until sentinel defeated)
- [x] Flag-gated chests (required_flag on treasure_chest, blocks Fenmother's Blessing)
- [x] 6 treasure chests (2 on F1, 3 on F2 incl. secret room, 1 post-boss on F3)
- [x] 3 save points (one per floor)
- [x] Overworld entry point with label and spawn marker
- [x] Integration tests (test_fenmothers_hollow.gd, ~37 tests)
- [x] Design spec: docs/superpowers/specs/2026-04-09-fenmothers-hollow-design.md

**Phase A2b: Fenmother's Hollow Puzzles (COMPLETE -- 2026-04-11)**
- [x] Water wheel puzzle entities (3 wheels, HIGH/LOW state)
- [x] Spirit Vessel key item + carry mechanic (two items: empty/filled swap)
- [x] Pure Spring interactable (fill vessel)
- [x] Spirit-plant revival interactable (pour vessel, opens passage)
- [x] Water level zone visibility toggling (block/reveal based on wheel state)
- [x] Poisoned pool tile damage zones (static F2/F3 + boss phase spawned)
- [x] Ritual meter HUD element (between-wave performance-based drain)
- [x] Post-boss spirit-path transition scene (auto-walk linear tunnel)
- [x] Caden NPC arrival sequence (auto-triggered tween + dialogue, no gap 3.7 needed)
- [x] PartyState.puzzle_state system for cross-floor persistence
- [x] Duskfen Spirit Shrine hub map with permanent overworld shortcut
- [x] ~53 tests in test_fenmother_puzzles.gd
- [x] Design spec: docs/superpowers/specs/2026-04-11-fenmother-puzzles-a2b-design.md

**Phase B1: Party Assembly + Game Start (COMPLETE — 2026-04-09)**
- [x] Party starts with Edren+Cael only (initialize_new_game unchanged)
- [x] Lira+Sable join via carradan_ambush_survived flag in _check_party_joining_flags
- [x] Lira+Sable added to STARTING_EQUIPMENT (empty — player equips)
- [x] Scene 2 dialogue trigger on overworld (Vaelith encounter, requires vaelith_ember_vein)
- [x] Scene 3 dialogue trigger on overworld (Ironmouth escape stub, sets carradan_ambush_survived)
- [x] Scene 4 dialogue trigger on overworld (Dawn March, requires carradan_ambush_survived)
- [x] Dialogue data uses existing files: vaelith_ember_vein.json, ironmouth_escape.json, dawn_march.json
- [x] Overworld label for Ironmouth area
- [x] Integration tests (test_opening_sequence.gd, ~20 tests)
- [x] Design spec: docs/superpowers/specs/2026-04-09-opening-sequence-b1-design.md

**Phase B2: Ironmouth + F3 + Full Scenes (COMPLETE — 2026-04-13)**
- [x] Ironmouth outpost map (linear escape corridor with 3 lootable crates, dialogue triggers, combat)
- [x] Ember Vein F3 (Ancient Ruin floor: PressurePlate, EmberCrystal, PitfallZone puzzles, WaterZone hidden door, 3 chests, save point, encounters)
- [x] Full Scene 1 tutorial dialogue (all 1a-1e beats across F1-F4, 6 new dialogue JSONs)
- [x] Full Scene 3 Ironmouth escape (2x Compact Patrol + 1x Compact Scout, flee-disabled, Lira+Sable join)
- [x] Arcanite gear preview (arcanite_sword_proto ATK 13, arcanite_mail_proto DEF 10, breaks after 1e escape)
- [x] Change new game start location from overworld to Ember Vein F1
- [x] Cael hidden stat spike (+10% physical damage via Pallor shimmer, permanent, hidden)
- [x] Opening credits visual sequence (title card, character names) — T1 cutscene with title command (2026-04-13)
- [x] Dawn March forward-only walk mechanics — dedicated trail map + cutscene trigger system (2026-04-13)
- [x] `opening_credits_seen` flag (39) — set by cutscene trigger handler on entry (2026-04-13)

**Phase C: Capital Completion (COMPLETE — 2026-04-19)**
- [x] Citizen's Walk outdoor district (45x40, 3 shops, 5 NPCs, library entrance)
- [x] Court Quarter outdoor district (35x30, Elara Thane, court guard, throne hall entrance)
- [x] Throne Hall interior (20x18, King Aldren, Lord Haren, Scene 7b/7d triggers)
- [x] Royal Library interior (16x14, Scholar Aldis, Mirren, save point, Scene 7c trigger, treasure chest)
- [x] Knight's Barracks interior (14x12, Dame Cordwyn, Sgt. Marek, Scene 7c trigger)
- [x] Anchor & Oar Upper Floor interior (12x10, guest rooms, staircase)
- [x] Shop split: armorer → weaponsmith (Lower Ward) + armorsmith (Citizen's Walk)
- [x] Jeweler shop with 4 new accessories (pact charms, silver ring, guardian pendant)
- [x] Specialty shop NPC placed in Citizen's Walk (data already existed)
- [x] 11 NPC ambient dialogue files (king, chancellor, knight, scholar, archivist, mage, noble, 3 shop greetings, guard)
- [x] Scene 7 narrative: FF6 Vector-style free-roam with required NPC conversations
- [x] Scene 7a gate arrival dialogue (8 entries, maren_warning gated)
- [x] Scene 7b throne hall presentation (12 entries, valdris_arrived gated)
- [x] Scene 7c Aldis/Cordwyn/Renn conversations (5+8+4 entries, party_has branches)
- [x] Scene 7d evening cutscene (T1, grey eyes moment, pendulum_to_capital flag)
- [x] required_flags (plural) AND-condition support in cutscene_handler.gd and exploration.gd
- [x] 6 new event flags: valdris_arrived, pendulum_presented, scene_7c_aldis/cordwyn/renn, pendulum_to_capital
- [x] Lower Ward updated: north ramp, barracks door, Scene 7a trigger, Phoenix Pinion chest
- [x] Anchor & Oar updated: staircase to upper floor, Scene 7c Renn trigger
- [x] Tileset extended with 4 capital tiles (limestone, carpet, platform, columns)
- [x] ~120 tests across 9 test files (districts, shops, dialogue, flags, integration, regression, cross-refs)
- [x] Design spec: docs/superpowers/specs/2026-04-19-valdris-capital-phase-c-design.md

**Phase C Deferred (captured for gap 4.5):**
- [ ] Eastern Wall & Battlements district (Act II siege breach — no Act I gameplay)
- [ ] Tower Tutorial district (Seven Towers magic mini-dungeon — separate system)
- [ ] Thornwatch garrison rest stop (separate location per locations.md — new sub-gap)
- [ ] Aelhart starting town (Act I location #1 — new sub-gap)
- [ ] Chapel, Cael's Quarters, Haren's Estate, Council Chambers, Court Mage Tower interiors
- [ ] Maren's Old Study, Pendulum Research Room, Servants' Passage, Royal Bedchamber
- [ ] Library Stacks Wing + Basement Archive (Act II quest: Mirren's hidden archive)
- [ ] Act II shop restocking (diplomatic_mission_start event)
- [ ] Anchor & Oar black market (Interlude, via Renn)
- [ ] Eastern Wall Breach Alcove (Act II, Oathkeeper Buckler)
- [ ] Royal Signet accessory (Act II, requires court favor)

**Notes:**
- Party assembly now works: Edren+Cael at new game, Lira+Sable join via carradan_ambush_survived flag (Phase B1, PR #132), Torren joins at Roothollow (Scene 5), Maren joins at Refuge (Scene 6).
- Dialogue triggers use dialogue_scene_id metadata (loads from DataManager) instead of inline dialogue_data — scalable for large scenes.
- required_flag metadata on triggers enables prerequisite flag checking (e.g., Scene 6 requires torren_joined).

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

**Deferred from Phase C (Valdris capital):**
- [ ] Eastern Wall & Battlements district (Act II siege breach)
- [ ] Tower Tutorial district (Seven Towers magic mini-dungeon)
- [ ] Valdris interiors: Chapel, Cael's Quarters, Haren's Estate, Council Chambers, Court Mage Tower, Maren's Old Study, Pendulum Research Room, Servants' Passage, Royal Bedchamber, Library Stacks + Basement
- [ ] Act II shop restocking, Anchor & Oar black market, Eastern Wall Breach Alcove, Royal Signet

**New sub-gaps (not yet in this document):**
- [ ] Thornwatch garrison rest stop (Act I location #2 — separate map, Commander Halda, armory shop, border patrol quests)
- [ ] Aelhart starting town (Act I location #1 — tutorial town, not yet built)

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
| 2026-04-06 | 3.2 + 3.3 integration | Wired end-to-end encounter→battle→rewards loop. EncounterSystem static helper (5 methods), BattleManager drops in transition data, XP/level-up distribution, exploration danger counter + battle return handling. 1 new file, 4 modified, 2 test files. | — |
| 2026-04-07 | 4.1 Ember Vein vertical slice | 3-floor dungeon (F1, F2, F4) with TileMapLayer pipeline, placeholder tileset, boss trigger zones, Vein Guardian 2-phase scripted AI, Ember Drake mini-boss, floor-specific encounters, PartyState battle integration, dialogue stubs, event flags, 9 treasure items. | — |
| 2026-04-11 | 4.4 Phase A2b | Fenmother puzzles: water wheels (3), spirit vessel fetch, water zones, poison damage zones, ritual meter, spirit-path auto-walk, Duskfen shrine + Caden binding. puzzle_state system on PartyState. 16 new files, 10 modified, ~53 tests. | — |
| 2026-04-12 | 4.4 Phase B2 | Ember Vein F3 (3 new puzzle entities, hidden door, encounters), Ironmouth escape (linear map, combat, Lira+Sable join), Scene 1 full dialogue (1a-1e, 6 new JSONs), Cael shimmer (+10% physical), Arcanite gear (break mechanic), start location → F1. Dawn March deferred to 3.7. ~20 new files, ~13 modified. | — |
| 2026-04-13 | 3.7 Cutscene Overlay | NOT STARTED → COMPLETE. T1/T4 cutscene overlay with letterbox, command sequencer (10 types), embedded dialogue_box, signal-based choreography, skip flags. 1 .tscn, 3 scripts, 5 test files (~57 tests). 620/620 full suite. | — |
| 2026-04-13 | 4.4 Phase B2F | Dawn March T1 cutscene: trail map scene, 16-entry choreographed dialogue with move/camera/fade/title commands, "PENDULUM OF DESPAIR" title card + character credits, cutscene trigger system in exploration.gd (_pending_cutscene + _cutscene_return state machine), opening_credits_seen flag (39). Phase B2 now COMPLETE. 634/634 tests. |
| 2026-04-19 | 4.4 Phase C | Capital Completion: 3 outdoor districts (Citizen's Walk, Court Quarter), 4 interiors (Throne Hall, Library, Barracks, Tavern Upper), Scene 7 FF6 Vector-style free-roam narrative, shop split (weaponsmith/armorsmith/jeweler), 17 dialogue files, required_flags AND-condition system, 6 new event flags, ~120 tests across 9 test files. Phase C COMPLETE. | — |

---

## Summary

| Tier | Gaps | Status | Description |
|------|------|--------|-------------|
| 1: Data Foundation | 9 | 9/9 complete | JSON data from design docs |
| 2: Entity Prefabs | 4 | 4/4 complete | .tscn prefabs with GDScript |
| 3: Core Systems | 8 | 5/8 complete (2 mostly) | Scenes and game systems |
| 4: Content & Integration | 9 | 0/9 complete (4 mostly, 1 mostly*) | Maps, content, polish |
| **Total** | **30** | **18 complete, 7 mostly, 5 not started** | |

*Gap 4.4 is MOSTLY COMPLETE: Phases A, A2, A2b, B1, B2, C all done. Only Phase C deferred items and potential Phase D (Thornwatch, Aelhart) remain.

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
