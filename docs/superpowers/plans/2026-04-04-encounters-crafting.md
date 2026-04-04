# Gaps 1.6 + 1.7: Encounter Tables + Crafting Data — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert dungeon encounter tables, overworld encounter zones, and crafting system data from design docs into 30 runtime JSON files.

**Architecture:** Parallel agents transcribe files from dungeons-world.md (world encounters), dungeons-city.md (city encounters), combat-formulas.md + geography.md (overworld encounters), and crafting.md + items.md + equipment.md (crafting data). Cross-reference sweep validates all enemy_ids against gap 1.2 and material/equipment_ids against gap 1.3. Mandatory stale-count scan before commit (lesson from PR #109).

**Tech Stack:** JSON data files, no GDScript

**Spec:** `docs/superpowers/specs/2026-04-04-encounters-crafting-design.md`

---

## File Structure

| Action | File | Gap |
|--------|------|-----|
| Create | `game/data/encounters/ember_vein.json` | 1.6 |
| Create | `game/data/encounters/fenmothers_hollow.json` | 1.6 |
| Create | `game/data/encounters/carradan_rail_tunnels.json` | 1.6 |
| Create | `game/data/encounters/axis_tower.json` | 1.6 |
| Create | `game/data/encounters/ley_line_depths.json` | 1.6 |
| Create | `game/data/encounters/pallor_wastes.json` | 1.6 |
| Create | `game/data/encounters/convergence.json` | 1.6 |
| Create | `game/data/encounters/archive_of_ages.json` | 1.6 |
| Create | `game/data/encounters/dreamers_fault.json` | 1.6 |
| Create | `game/data/encounters/dry_well.json` | 1.6 |
| Create | `game/data/encounters/sunken_rig.json` | 1.6 |
| Create | `game/data/encounters/windshear_peak.json` | 1.6 |
| Create | `game/data/encounters/mountain_passes.json` | 1.6 |
| Create | `game/data/encounters/caves_and_grottos.json` | 1.6 |
| Create | `game/data/encounters/caldera_forge_depths.json` | 1.6 |
| Create | `game/data/encounters/frostcap_caverns.json` | 1.6 |
| Create | `game/data/encounters/thornvein_passage.json` | 1.6 |
| Create | `game/data/encounters/valdris_siege.json` | 1.6 |
| Create | `game/data/encounters/ley_nexus_hollow.json` | 1.6 |
| Create | `game/data/encounters/highcairn_monastery.json` | 1.6 |
| Create | `game/data/encounters/valdris_catacombs.json` | 1.6 |
| Create | `game/data/encounters/corrund_sewers.json` | 1.6 |
| Create | `game/data/encounters/caldera_undercity.json` | 1.6 |
| Create | `game/data/encounters/ashmark_factory.json` | 1.6 |
| Create | `game/data/encounters/ironmark_citadel.json` | 1.6 |
| Create | `game/data/encounters/bellhaven_tunnels.json` | 1.6 |
| Create | `game/data/encounters/overworld.json` | 1.6 |
| Create | `game/data/crafting/devices.json` | 1.7 |
| Create | `game/data/crafting/recipes.json` | 1.7 |
| Create | `game/data/crafting/synergies.json` | 1.7 |
| Modify | `docs/analysis/game-dev-gaps.md` | Both |

---

## Chunk 1: World Dungeon Encounters — Act I + Act II (Gap 1.6)

### Task 1: Transcribe Act I world dungeon encounter files

**Files:**
- Create: `game/data/encounters/ember_vein.json`, `fenmothers_hollow.json`
- Read: `docs/story/dungeons-world.md` (Sections 1, 2)
- Read: `docs/superpowers/specs/2026-04-04-encounters-crafting-design.md`

**Agent instructions:** Read dungeons-world.md and create the 2 Act I world dungeon encounter files. Each file follows this schema:

```json
{
  "dungeon_id": "ember_vein",
  "name": "Ember Vein",
  "act": "act_i",
  "floors": [
    {
      "floor_id": "1-2",
      "terrain_type": "low_visibility",
      "danger_tier": 2,
      "danger_increment": 120,
      "formation_rates": {
        "normal": 68.75,
        "back_attack": 18.75,
        "preemptive": 12.5
      },
      "groups": [
        {
          "format": 1,
          "enemies": ["ley_vermin", "ley_vermin", "unstable_crystal"],
          "weight": 31.25
        }
      ]
    }
  ],
  "bosses": [
    {
      "enemy_id": "ember_drake",
      "name": "Ember Drake",
      "floor": "2",
      "trigger": "zone",
      "is_mini_boss": true
    }
  ]
}
```

RULES:
- `dungeon_id` = filename without .json extension
- `act` = `act_i`, `act_ii`, `interlude`, `act_iii`, `post_game`. For dungeons spanning multiple acts, use the EARLIEST act the dungeon is first available in. The `act` field represents first-available, not exclusivity.
- `terrain_type` = `roads`, `open`, `low_visibility`, `pallor_wastes` — determines formation rates per combat-formulas.md
- `danger_tier` = 0-5 (0=safe, 2=standard dungeon, 3=deep, 4=ley_scar, 5=pallor)
- `danger_increment` = exact value from combat-formulas.md terrain table (120 for standard, 252 for deep, etc.)
- `formation_rates` = MUST match terrain_type per combat-formulas.md: roads(87.5/0/12.5), open(75/12.5/12.5), low_visibility(68.75/18.75/12.5), pallor_wastes(62.5/25/12.5)
- `groups` = exactly 4 per floor (31.25/31.25/31.25/6.25 weights). Extended format for Dreamer's Fault only.
- `enemies` array = enemy IDs from gap 1.2 enemy data. Duplicates = multiple of same enemy.
- `bosses` array = mini-bosses and dungeon bosses. `trigger` = zone/interact/cutscene/hp_threshold
- Boss corridors (Tier 0) are NOT in the floors array — no random encounters there
- Weights per floor MUST sum to exactly 100
- All enemy_ids MUST be snake_case and MUST exist in `game/data/enemies/{act_i,act_ii,interlude,act_iii,optional,bosses}.json` (6 files total)

ACT I DUNGEONS (2 files) — with explicit act values:
1. ember_vein — act: act_i, 4 floors, 2 floor-groups, Tier 2 standard
2. fenmothers_hollow — act: act_i, 3 floors, 2 floor-groups, Tier 2 + Tier 3 (spans Acts I-II but first available in Act I)

- [ ] **Step 1:** Read dungeons-world.md encounter sections for Ember Vein, Fenmother's Hollow
- [ ] **Step 2:** Create all 2 Act I encounter JSON files
- [ ] **Step 3:** Self-verify: formation rates match terrain_type, weights sum to 100, all enemy_ids are snake_case

---

### Task 2: Transcribe Act II world dungeon encounter files

**Files:**
- Create: `game/data/encounters/carradan_rail_tunnels.json`, `axis_tower.json`, `ley_line_depths.json`, `archive_of_ages.json`, `caldera_forge_depths.json`
- Read: `docs/story/dungeons-world.md` (Sections 3, 4, 5, 8, 15)

**Agent instructions:** Same schema and rules as Task 1. Create 5 Act II world dungeon files.

ACT II / INTERLUDE DUNGEONS (5 files) — with explicit act values:
1. carradan_rail_tunnels — act: act_ii, 4 sections, 2 region-groups
2. axis_tower — act: interlude, 5 floors, 2-3 floor-groups
3. ley_line_depths — act: act_ii, 5 floors, 3 floor-groups, Tier 2→3→4 escalation (spans Acts II-III)
4. archive_of_ages — act: act_ii, 3 floors (spans Acts II-III)
5. caldera_forge_depths — act: act_ii, 4 floors, 2 floor-groups

- [ ] **Step 1:** Read dungeons-world.md encounter sections for all 5 dungeons
- [ ] **Step 2:** Create all 5 Act II encounter JSON files
- [ ] **Step 3:** Self-verify: formation rates match terrain_type, weights sum to 100, all enemy_ids are snake_case

---

## Chunk 2: World Dungeon Encounters — Act III + Interlude + Optional + Post-Game (Gap 1.6)

### Task 3: Transcribe remaining world dungeon encounter files

**Files:**
- Create: `game/data/encounters/dry_well.json`, `pallor_wastes.json`, `convergence.json`, `sunken_rig.json`, `windshear_peak.json`, `mountain_passes.json`, `caves_and_grottos.json`, `frostcap_caverns.json`, `thornvein_passage.json`, `valdris_siege.json`, `ley_nexus_hollow.json`, `highcairn_monastery.json`, `dreamers_fault.json`
- Read: `docs/story/dungeons-world.md` (Sections 6, 7, 9, 10, 11-20)

**Agent instructions:** Same schema and rules as Task 1. Create 13 remaining world dungeon files.

SPECIAL CASES:
- `pallor_wastes` — terrain_type: pallor_wastes (62.5/25/12.5), danger_increment: 700
- `convergence` — multi-phase with area-groups (Outer Ring, Anchor Stations, Central Platform). Tier 3 → Tier 4
- `dreamers_fault` — 20 floors with EXTENDED format (5-6 packs per floor-group, non-standard weights: 25/25/25/18.75/6.25 or 25/25/18.75/18.75/6.25/6.25)
- `valdris_siege` — scripted battle sequence. May have minimal/no random encounter groups. Include bosses array.
- `ley_nexus_hollow` — post-game boss arena. May be Tier 0 with only bosses array.

ACT III + OPTIONAL + POST-GAME DUNGEONS (13 files) — with explicit act values:
1. dry_well — act: act_iii, 7 floors, 3 floor-groups, Tier 2→3→4 escalation
2. pallor_wastes — act: act_iii, terrain_type: pallor_wastes
3. convergence — act: act_iii, multi-phase, Tier 3→4
4. sunken_rig — act: interlude, Tier 3
5. windshear_peak — act: act_iii
6. mountain_passes — act: act_iii
7. caves_and_grottos — act: act_iii
8. frostcap_caverns — act: act_iii
9. thornvein_passage — act: act_iii
10. valdris_siege — act: act_ii, scripted battles
11. ley_nexus_hollow — act: post_game, boss arena
12. highcairn_monastery — act: interlude (spans Interlude-III)
13. dreamers_fault — act: post_game, 20 floors, EXTENDED format (5-6 packs)

- [ ] **Step 1:** Read dungeons-world.md encounter sections for all 13 dungeons
- [ ] **Step 2:** Create all 13 encounter JSON files
- [ ] **Step 3:** Self-verify: Dreamer's Fault uses extended format, Pallor Wastes uses pallor_wastes formation rates, all weights sum to 100, act values correct per list above

---

## Chunk 3: City Dungeon Encounters + Overworld (Gap 1.6)

### Task 4: Transcribe city dungeon encounter files

**Files:**
- Create: `game/data/encounters/valdris_catacombs.json`, `corrund_sewers.json`, `caldera_undercity.json`, `ashmark_factory.json`, `ironmark_citadel.json`, `bellhaven_tunnels.json`
- Read: `docs/story/dungeons-city.md`

**Agent instructions:** Same schema and rules as Task 1. Create 6 city dungeon encounter files.

CITY DUNGEONS (6 files):
1. valdris_catacombs — 3 floors, Tier 2, low_visibility
2. corrund_sewers — 3 screens, Tier 2, low_visibility (Tunnel Map modifier is runtime, not in static data)
3. caldera_undercity — 4 screens, Tier 2, low_visibility. Note Interlude variant formations if present.
4. ashmark_factory — 2 floors, Tier 2→3 escalation, mixed terrain (open for Maintenance, low_visibility for Pipeline)
5. ironmark_citadel — 3 screens, Interlude only, Tier 2, low_visibility
6. bellhaven_tunnels — 3 screens, Tier 2, low_visibility

- [ ] **Step 1:** Read dungeons-city.md encounter sections for all 6 city dungeons
- [ ] **Step 2:** Create all 6 city dungeon encounter JSON files
- [ ] **Step 3:** Self-verify: formation rates match terrain_type, weights sum to 100

---

### Task 5: Transcribe overworld encounter file

**Files:**
- Create: `game/data/encounters/overworld.json`
- Read: `docs/story/geography.md`, `docs/story/combat-formulas.md`, `docs/story/dungeons-world.md` (for enemy references)

**Agent instructions:** Create the overworld encounter file with 12 terrain zones. Uses a different top-level structure:

```json
{
  "dungeon_id": "overworld",
  "name": "Overworld",
  "zones": [
    {
      "zone_id": "valdris_highlands",
      "name": "Valdris Highlands",
      "terrain_type": "open",
      "act": "act_i",
      "danger_tier": 2,
      "danger_increment": 148,
      "formation_rates": {
        "normal": 75.0,
        "back_attack": 12.5,
        "preemptive": 12.5
      },
      "groups": [
        {
          "format": 1,
          "enemies": ["ley_vermin", "ley_vermin"],
          "weight": 31.25
        }
      ]
    }
  ]
}
```

OVERWORLD ZONES (12 entries):
1. valdris_highlands (open, 148, act_i)
2. aelhart_valley (open, 48, act_i)
3. compact_industrial (open, 148, act_ii)
4. ley_scarred_plains (open, 148, act_i)
5. bellhaven_coast (open, 64, act_ii)
6. ashport_coast (open, 64, act_ii)
7. deep_thornmere (low_visibility, 380, act_ii)
8. wilds_edge (low_visibility, 148, act_ii)
9. duskfen_marshland (low_visibility, 380, act_ii)
10. frostcap_foothills (open, 252, act_iii)
11. pallor_wastes_approach (pallor_wastes, 700, act_iii)
12. roads (roads, 96, act: "all" — special overworld-only value indicating encounters available in every act)

Enemy compositions for overworld zones: use enemies from the relevant act's enemy data files. Overworld encounters feature the same enemies as nearby dungeons but in different compositions. Read dungeons-world.md and bestiary files to determine appropriate enemy selections.

- [ ] **Step 1:** Read geography.md and combat-formulas.md for terrain data
- [ ] **Step 2:** Read relevant bestiary and dungeon docs for enemy assignments
- [ ] **Step 3:** Create `game/data/encounters/overworld.json` with all 12 zones
- [ ] **Step 4:** Self-verify: formation rates match terrain_type, all zones present, weights sum to 100

---

## Chunk 4: Crafting Data (Gap 1.7)

### Task 6: Create devices.json

**Files:**
- Create: `game/data/crafting/devices.json`
- Read: `docs/story/items.md` (device section), `docs/story/crafting.md`
- Read: `docs/superpowers/specs/2026-04-04-encounters-crafting-design.md`

**Agent instructions:** Create devices.json with all 13 pre-crafted field devices. Schema:

```json
{
  "devices": [
    {
      "id": "thermal_charge",
      "name": "Thermal Charge",
      "tier": "basic",
      "ac_cost": 1,
      "category": "offensive",
      "element": "flame",
      "effect": "Flame AoE: 400 dmg",
      "charges": 3,
      "materials": [
        {"item_id": "element_shard", "quantity": 2},
        {"item_id": "scrap_metal", "quantity": 1}
      ],
      "gold_cost": 100,
      "unlock_phase": "act_i",
      "schematic_required": null,
      "description": "A volatile charge that detonates in a burst of flame."
    }
  ]
}
```

RULES:
- ALL 13 fields required on every entry. Use null for inapplicable.
- `tier` = basic, advanced, expert, anti_pallor, ultimate
- `category` = offensive, defensive, utility, advanced, consumable_craft
- `element` = flame, frost, storm, spirit, non_elemental, or null
- `charges` = always 3
- All material `item_id` MUST exist in `game/data/items/materials.json`
- `schematic_required` = null for all except arcanite_lance which requires "forge_schematic"
- `unlock_phase` = act_i, act_ii, interlude, act_iii, post_convergence

DEVICE LIST (13): thermal_charge, mending_engine, flashbang, frost_bomb, shock_coil, barrier_node, ward_emitter, gravity_anchor, disruption_pulse, pallor_grenade, pallor_salve, arcanite_lance, emergency_beacon

- [ ] **Step 1:** Read items.md device section and crafting.md
- [ ] **Step 2:** Create `game/data/crafting/devices.json` with all 13 devices
- [ ] **Step 3:** Self-verify: exactly 13 entries, all 13 fields present, all material item_ids valid

---

### Task 7: Create recipes.json

**Files:**
- Create: `game/data/crafting/recipes.json`
- Read: `docs/story/equipment.md` (forging recipes + infusions sections)
- Read: `docs/superpowers/specs/2026-04-04-encounters-crafting-design.md`

**Agent instructions:** Create recipes.json with 9 forging recipes and 7 elemental infusions in two top-level arrays.

```json
{
  "forging_recipes": [...],
  "infusions": [...]
}
```

FORGING RECIPE SCHEMA (10 fields):
- `id`, `name`, `result_id`, `result_type` (weapon/armor), `materials`, `gold_fee`, `forge_locations`, `unlock_phase`, `schematic_required`, `description`
- All `result_id` MUST exist in `game/data/equipment/weapons.json` or `armor.json`
- All material `item_id` MUST exist in `game/data/items/materials.json`

INFUSION SCHEMA (7 fields):
- `id`, `name`, `element`, `tier` (basic/advanced), `materials`, `gold_fee`, `description`
- Basic infusions: 300g. Advanced infusions: 500g.

VALID FORGE LOCATION IDS: ashmark, caldera, forgotten_forge, inn_workbench, lira_workshop_corrund, lira_workshop_caldera, oasis_b

FORGING RECIPES (9): arcanite_blade, forgewright_maul, arcanite_helm, thornspear, shadowsteel_knife, resonance_rod, pallor_ward_vest, ley_woven_cloak, liras_masterwork

INFUSIONS (7): flame_infusion, frost_infusion, storm_infusion, earth_infusion, ley_infusion, spirit_infusion, void_infusion

- [ ] **Step 1:** Read equipment.md forging and infusion sections
- [ ] **Step 2:** Create `game/data/crafting/recipes.json` with 9 recipes + 7 infusions
- [ ] **Step 3:** Self-verify: all result_ids exist in equipment files, all material item_ids valid, gold fees match spec

---

### Task 8: Create synergies.json

**Files:**
- Create: `game/data/crafting/synergies.json`
- Read: `docs/story/equipment.md` (synergies section), `docs/story/crafting.md` (Section 3)

**Agent instructions:** Create synergies.json with all 7 secret weapon synergies.

```json
{
  "synergies": [
    {
      "id": "penitents_edge",
      "name": "Penitent's Edge",
      "base_weapon_id": "grey_cleaver_tainted",
      "base_weapon_class": null,
      "infusion_element": "spirit",
      "result_element": "spirit",
      "bonus_effect": "Purification counter: 50 Pallor encounters (reduced from 100)",
      "discovery_channel": "both",
      "description": "The Grey Cleaver awakens to its true nature through spirit infusion."
    }
  ]
}
```

RULES:
- ALL 9 fields required on every entry.
- `base_weapon_id` = specific weapon ID if synergy targets one weapon (e.g., `grey_cleaver_tainted`, `architects_hammer`). null if class-based.
- `base_weapon_class` = weapon class for "any X" synergies (e.g., `torren_spear`, `maren_staff`, `sable_dagger`, `lira_hammer`, `edren_sword`). null if specific ID.
- Exactly one of `base_weapon_id` or `base_weapon_class` must be non-null.
- `discovery_channel` = `both`, `npc_only`, `lira_only`
- Verify base_weapon_id values exist in `game/data/equipment/weapons.json`

SYNERGIES (7): penitents_edge, stormforge_hammer, rootbound_lance, resonance_staff, shadowfang, crucible_maul, oathkeeper

- [ ] **Step 1:** Read equipment.md synergy section and crafting.md Section 3
- [ ] **Step 2:** Create `game/data/crafting/synergies.json` with all 7 synergies
- [ ] **Step 3:** Self-verify: exactly 7 entries, all 9 fields present, base_weapon_id values valid, exactly one of id/class non-null per entry

---

## Chunk 5: Verification & Completion

### Task 9: Cross-reference encounter enemy_ids against gap 1.2

- [ ] **Step 1:** Extract all enemy_ids from all 27 encounter files (groups + bosses)
- [ ] **Step 2:** Load all enemy IDs from `game/data/enemies/{act_i,act_ii,interlude,act_iii,optional,bosses}.json`
- [ ] **Step 3:** Report any enemy_id not found — these are gaps
- [ ] **Step 4:** Fix any missing references (either correct the ID or flag as a design doc gap)

### Task 10: Cross-reference crafting material/equipment IDs against gap 1.3

- [ ] **Step 1:** Extract all item_ids from devices.json materials arrays
- [ ] **Step 2:** Extract all item_ids from recipes.json materials arrays
- [ ] **Step 3:** Extract all result_ids from recipes.json forging_recipes
- [ ] **Step 4:** Extract all base_weapon_id values from synergies.json
- [ ] **Step 5:** Verify all against `game/data/items/materials.json` and `game/data/equipment/{weapons,armor}.json`
- [ ] **Step 6:** Report and fix any missing references

### Task 11: Verify encounter weights and formation rates

- [ ] **Step 1:** For every floor in every encounter file, verify groups weights sum to 100
- [ ] **Step 2:** For every floor, verify formation_rates values sum to 100
- [ ] **Step 3:** For every floor, verify formation_rates match the terrain_type per combat-formulas.md
- [ ] **Step 4:** Report and fix any mismatches

### Task 12: HARD GATE — Programmatic stale-count scan

- [ ] **Step 1:** Count actual files and entries:
  - Encounter files count (should be 27)
  - Device entries count (should be 13)
  - Forging recipe count (should be 9)
  - Infusion count (should be 7)
  - Synergy count (should be 7)
- [ ] **Step 2:** Scan spec for every numeric count claim — verify matches actual
- [ ] **Step 3:** Scan plan for every count — verify matches actual
- [ ] **Step 4:** If ANY stale count found: fix ALL instances before proceeding
- [ ] **Step 5:** Re-scan to confirm zero stale counts

### Task 13: Update gap tracker and commit

- [ ] **Step 1:** Update gap 1.6 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Update gap 1.7 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 3:** Check off all completed items in both "What's Needed" lists
- [ ] **Step 4:** Note which downstream gaps are now unblocked:
  - 1.6 unblocks: 3.2 (Exploration Scene — overworld encounters)
  - 1.7 unblocks: 3.4 (Menu Overlay — crafting screens)
- [ ] **Step 5:** Stage and commit all files

```bash
git add game/data/encounters/ game/data/crafting/ docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-04-encounters-crafting-design.md docs/superpowers/plans/2026-04-04-encounters-crafting.md
git commit -m "feat(engine): add encounter table and crafting data JSON files (gaps 1.6 + 1.7)"
```

- [ ] **Step 6:** Push and hand off to `/create-pr` → `/godot-review-loop`
