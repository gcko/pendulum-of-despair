# Gaps 1.6 + 1.7: Encounter Tables + Crafting Data — Design Spec

> **Date:** 2026-04-04
> **Gaps:** 1.6 (Encounter Table Data) + 1.7 (Crafting & Device Data)
> **Status:** Approved
> **Source docs:** dungeons-world.md (world dungeon encounters), dungeons-city.md (city dungeon encounters), combat-formulas.md (danger counter, formations, terrain rates), geography.md (overworld zones), crafting.md (device/forge systems), items.md (device entries), equipment.md (forging recipes, infusions, synergies)
> **Architecture ref:** technical-architecture.md Sections 2.6, 2.8

## Tech-Arch Divergences

This spec extends and corrects the skeleton schemas in technical-architecture.md. The following divergences are intentional and tech-arch should be updated to match after implementation:

**Section 2.6 (Encounters):**
- `floor` → `floor_id` (renamed for clarity — floor is a string range like "1-2", not an int)
- `back_attack_rate` + `preemptive_rate` → `formation_rates: {normal, back_attack, preemptive}` object (adds explicit normal rate, groups related fields)
- Added fields: `name`, `act`, `terrain_type`, `danger_tier`, `format` (on groups), `bosses` array
- Tech-arch uses `"act_1"` format; this spec uses `"act_i"` roman numeral format (consistent with all existing game data from gaps 1.1-1.5)

**Section 2.8 (Crafting):**
- `result_item` → `result_id` (renamed to match cross-reference convention used in gaps 1.2-1.5)
- `forge_location` → `forge_locations` (plural array, since recipes can be crafted at multiple locations)
- Added device fields: `element`, `materials`, `gold_cost`, `description` (tech-arch skeleton was minimal)

## Problem

Dungeon encounter tables (~26 dungeons + 1 overworld file), pre-crafted device data (13 devices), forging recipes (9 recipes + 7 infusions), and synergy definitions (7 synergies) need to be converted from design docs to runtime JSON. These are independent gaps combined for efficiency — different source docs, different output directories, no cross-dependencies.

## Scope

**Gap 1.6 — Encounter Table Data:**
- 20 world dungeon encounter files (one per dungeon)
- 6 city dungeon encounter files (one per city dungeon)
- 1 overworld encounter file (12 terrain zones)
- Source: dungeons-world.md, dungeons-city.md, combat-formulas.md, geography.md
- Cross-references gap 1.2 enemy IDs

**Gap 1.7 — Crafting & Device Data:**
- 1 device JSON file (13 pre-crafted field devices)
- 1 recipes JSON file (9 forging recipes + 7 elemental infusions)
- 1 synergies JSON file (7 secret synergies)
- Source: crafting.md, items.md, equipment.md
- Cross-references gap 1.3 material/equipment IDs

**Excluded:**
- Runtime encounter logic (danger counter tick, formation resolution) → gap 3.2 (Exploration Scene)
- Runtime crafting UI (forge menu, device loadout screen) → gap 3.4 (Menu Overlay)
- Runtime device mechanics (malfunction, calibrate) → gap 3.3 (Battle Scene)
- Boss AI scripts → gap 3.3 (Battle Scene)

---

## Gap 1.6: Encounter Table Data

### File Structure

| # | File | Dungeon | Act | Floors/Sections |
|---|------|---------|-----|-----------------|
| 1 | `ember_vein.json` | Ember Vein | I | 4 (2 floor-groups) |
| 2 | `fenmothers_hollow.json` | Fenmother's Hollow | I-II | 3 (2 floor-groups) |
| 3 | `carradan_rail_tunnels.json` | Carradan Rail Tunnels | II | 4 sections (2 region-groups) |
| 4 | `axis_tower.json` | Axis Tower Interior | Interlude | 5 (2-3 floor-groups) |
| 5 | `ley_line_depths.json` | Ley Line Depths | II-III | 5 (3 floor-groups) |
| 6 | `pallor_wastes.json` | Pallor Wastes | III | 5 sections (2-3 region-groups) |
| 7 | `convergence.json` | The Convergence | III | 4 phases (3-4 area-groups) |
| 8 | `archive_of_ages.json` | Archive of Ages | II-III | 3 |
| 9 | `dreamers_fault.json` | Dreamer's Fault | Post-game | 20 (4-5 floor-groups) |
| 10 | `dry_well.json` | Dry Well of Aelhart | III+ | 7 (3 floor-groups) |
| 11 | `sunken_rig.json` | Sunken Rig | III+ | 3 |
| 12 | `windshear_peak.json` | Windshear Peak | III+ | 1 |
| 13 | `mountain_passes.json` | Mountain Passes | III+ | Variable |
| 14 | `caves_and_grottos.json` | Caves and Grottos | III+ | Variable |
| 15 | `caldera_forge_depths.json` | Caldera Forge Depths | II+ | 4 (2 floor-groups) |
| 16 | `frostcap_caverns.json` | Frostcap Caverns | III+ | 3 |
| 17 | `thornvein_passage.json` | Thornvein Passage | III+ | 2 |
| 18 | `valdris_siege.json` | Valdris Siege Battlefield | Interlude | 1 (scripted) |
| 19 | `ley_nexus_hollow.json` | Ley Nexus Hollow | Post-game | 1 (boss arena) |
| 20 | `highcairn_monastery.json` | Highcairn Monastery | Interlude-III | 2 |
| 21 | `valdris_catacombs.json` | Valdris Crown Catacombs | Interlude+ | 3 |
| 22 | `corrund_sewers.json` | Corrund Undercity / Sewers | II | 3 |
| 23 | `caldera_undercity.json` | Caldera Undercity | Interlude | 4 |
| 24 | `ashmark_factory.json` | Ashmark Factory Depths | II+ | 2 |
| 25 | `ironmark_citadel.json` | Ironmark Citadel Dungeons | Interlude | 3 |
| 26 | `bellhaven_tunnels.json` | Bellhaven Smuggler Tunnels | II+ | 3 |
| 27 | `overworld.json` | Overworld Terrain Zones | All | 12 zones |

Total: 27 encounter files in `game/data/encounters/`.

### Schema — Dungeon Encounters

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
        },
        {
          "format": 2,
          "enemies": ["ley_vermin", "ley_vermin", "ley_vermin"],
          "weight": 31.25
        },
        {
          "format": 3,
          "enemies": ["unstable_crystal", "unstable_crystal"],
          "weight": 31.25
        },
        {
          "format": 4,
          "enemies": ["ley_vermin", "ley_vermin", "ley_vermin", "ley_vermin", "unstable_crystal"],
          "weight": 6.25
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
    },
    {
      "enemy_id": "vein_guardian",
      "name": "Vein Guardian",
      "floor": "4",
      "trigger": "zone",
      "is_mini_boss": false
    }
  ]
}
```

### Schema — Overworld Encounters

The overworld file reuses `dungeon_id` as a generic area identifier (consistent with DataManager load pattern) despite not being a dungeon. Uses `zones` array instead of `floors`.

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

### Field Definitions — Dungeon Encounter

| Field | Type | Notes |
|-------|------|-------|
| `dungeon_id` | string | snake_case, matches filename without .json |
| `name` | string | Human-readable dungeon name |
| `act` | string | `act_i`, `act_ii`, `interlude`, `act_iii`, `post_game`. Note: `post_game` (encounter context) and `post_convergence` (crafting unlock phase) are distinct — post_convergence is late Act III/IV, post_game is after main story |
| `floors` | array | One entry per floor-group (floors with same encounter pool) |

### Field Definitions — Floor Entry

| Field | Type | Notes |
|-------|------|-------|
| `floor_id` | string | Floor range: `"1-2"`, `"3"`, section name: `"hub_east"`, etc. |
| `terrain_type` | string | `roads`, `open`, `low_visibility`, `pallor_wastes` — determines formation rates |
| `danger_tier` | int | 0-5 per combat-formulas.md (0=safe, 2=standard, 3=deep, 4=ley_scar, 5=pallor) |
| `danger_increment` | int | Steps-to-encounter increment: 0, 48, 64, 96, 120, 148, 252, 380, 506, 700 |
| `formation_rates` | object | `{normal, back_attack, preemptive}` — must sum to 100 |
| `groups` | array | 4 encounter formations (standard) or 5-6 (Dreamer's Fault) |

### Field Definitions — Encounter Group

| Field | Type | Notes |
|-------|------|-------|
| `format` | int | 1-4 (standard) or 1-6 (extended). Format number for identification |
| `enemies` | array[string] | Enemy IDs. Duplicates = multiple of same enemy. Must exist in gap 1.2 |
| `weight` | float | Selection weight %. Standard: 31.25/31.25/31.25/6.25. Extended varies. Must sum to 100 per floor |

### Field Definitions — Boss Entry

| Field | Type | Notes |
|-------|------|-------|
| `enemy_id` | string | Must exist in gap 1.2 enemy files (bosses.json or act files) |
| `name` | string | Human-readable boss name |
| `floor` | string | Floor or section where boss is encountered |
| `trigger` | string | `zone`, `interact`, `cutscene`, `hp_threshold` |
| `is_mini_boss` | bool | true for mid-dungeon mini-bosses, false for dungeon bosses |

### Formation Rate Reference

Per combat-formulas.md, formation rates are determined by terrain_type:

| terrain_type | Normal | Back Attack | Preemptive |
|-------------|--------|-------------|------------|
| `roads` | 87.5% | 0% | 12.5% |
| `open` | 75% | 12.5% | 12.5% |
| `low_visibility` | 68.75% | 18.75% | 12.5% |
| `pallor_wastes` | 62.5% | 25% | 12.5% |

### Danger Increment Reference

Per combat-formulas.md:

| Zone Type | Increment | Avg Steps | danger_tier |
|-----------|-----------|-----------|-------------|
| Sacred / Urban / Boss corridor | 0 | None | 0 |
| Farmland / Settled | 48 | ~48 | 1 |
| Coastal | 64 | ~40 | 1 |
| Roads | 96 | ~32 | 1 |
| Forest (light) / Quarried plains | 148 | ~24 | 2 |
| Standard dungeons | 120 | ~30 | 2 |
| Mountains / Deep dungeon floors | 252 | ~20 | 3 |
| Forest (dense) / Marshland | 380 | ~16 | 3 |
| Ley Scar / Dreamer's Fault (deep) | 506 | ~14 | 4 |
| Pallor Wastes | 700 | ~10 | 5 |

### Act Scaling Multipliers

Not baked into static data. Applied at runtime:
- Act I: x1.0, Act II: x1.1, Interlude: x1.2, Act III: x1.1

### Encounter Rate Modifiers

Not baked into static data. Applied at runtime by checking equipment/spells:
- Ward Talisman: x0.5, Infiltrator's Cloak: x0.5, Lure Talisman: x2.0
- Veilstep spell: x0.25, Tunnel Map: x0.5, Ley Stag: x0

### 4-Pack Weight System

Standard dungeons use exactly 4 encounter groups per floor:
- Formats 1-3: 31.25% each (0-79, 80-159, 160-239 on d256)
- Format 4: 6.25% (240-255 on d256)

**Extended format** (Dreamer's Fault only):
- 5-pack: 25/25/25/18.75/6.25
- 6-pack: 25/25/18.75/18.75/6.25/6.25

### Boss Rules

- Boss corridors are Tier 0 (safe) — omitted from floors array (no random encounters)
- Boss formation is always Normal (back attack and preemptive disabled)
- Boss trigger types: zone (step into area), interact (examine object), cutscene (story auto-triggers), hp_threshold (environmental/phase)

### DataManager Compatibility

`DataManager.load_encounters(dungeon_id)` — not yet implemented. Will load `res://data/encounters/{dungeon_id}.json`. Returns a Dictionary.

### Overworld Zone List

The overworld.json file contains 12 terrain zones. Not all zones have random encounters — sacred sites and urban interiors are Tier 0 (safe) and will have empty groups arrays.

| Zone | terrain_type | danger_increment | Act |
|------|-------------|------------------|-----|
| Valdris Highlands | open | 148 | act_i |
| Aelhart Valley | open | 48 | act_i |
| Compact Industrial | open | 148 | act_ii |
| Ley-Scarred Plains | open | 148 | act_i |
| Bellhaven Coast | open | 64 | act_ii |
| Ashport Coast | open | 64 | act_ii |
| Deep Thornmere | low_visibility | 380 | act_ii |
| Wilds Edge | low_visibility | 148 | act_ii |
| Duskfen Marshland | low_visibility | 380 | act_ii |
| Frostcap Foothills | open | 252 | act_iii |
| Pallor Wastes Approach | pallor_wastes | 700 | act_iii |
| Roads (various) | roads | 96 | all |

---

## Gap 1.7: Crafting & Device Data

### File Structure

| File | Content | Entries |
|------|---------|---------|
| `devices.json` | Pre-crafted field devices | 13 |
| `recipes.json` | Forging recipes + elemental infusions | 9 + 7 = 16 |
| `synergies.json` | Secret weapon synergies | 7 |

Total: 3 crafting files in `game/data/crafting/`.

### Schema — Devices

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

### Field Definitions — Device

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all devices |
| `name` | string | Exact name from items.md |
| `tier` | string | `basic`, `advanced`, `expert`, `anti_pallor`, `ultimate` |
| `ac_cost` | int | AC to craft: basic=1, advanced=2, expert=2, anti_pallor=3, ultimate=4 |
| `category` | string | `offensive`, `defensive`, `utility`, `advanced`, `consumable_craft` |
| `element` | string/null | `flame`, `frost`, `storm`, `spirit`, `non_elemental`, or null for non-damage |
| `effect` | string | Effect description from items.md |
| `charges` | int | Always 3 per items.md loadout rules |
| `materials` | array | `[{item_id, quantity}]`. All item_ids must exist in gap 1.3 materials.json |
| `gold_cost` | int | Gold to craft |
| `unlock_phase` | string | `act_i`, `act_ii`, `interlude`, `act_iii`, `post_convergence` |
| `schematic_required` | string/null | Key item ID required to unlock. null for most devices. `forge_schematic` for Arcanite Lance |
| `description` | string | Brief in-game description |

### Device List (13 devices)

| # | ID | Name | Tier | AC | Category | Element | Materials | Gold | Phase |
|---|---|------|------|----|----------|---------|-----------|------|-------|
| 1 | `thermal_charge` | Thermal Charge | basic | 1 | offensive | flame | 2 element_shard + 1 scrap_metal | 100 | act_i |
| 2 | `mending_engine` | Mending Engine | basic | 1 | defensive | null | 2 beast_hide + 1 spirit_essence | 150 | act_i |
| 3 | `flashbang` | Flashbang | basic | 1 | utility | null | 1 element_shard + 1 bone_fragment | 100 | act_i |
| 4 | `frost_bomb` | Frost Bomb | advanced | 2 | offensive | frost | 2 element_shard + 1 crystal_shard | 100 | act_ii |
| 5 | `shock_coil` | Shock Coil | advanced | 2 | offensive | storm | 1 elemental_core + 1 scrap_metal | 200 | act_ii |
| 6 | `barrier_node` | Barrier Node | advanced | 2 | defensive | null | 2 scrap_metal + 1 crystal_shard | 150 | act_ii |
| 7 | `ward_emitter` | Ward Emitter | advanced | 2 | defensive | null | 2 crystal_shard + 1 ether_wisp | 150 | act_ii |
| 8 | `gravity_anchor` | Gravity Anchor | expert | 2 | utility | null | 1 scrap_metal + 1 arcanite_shard | 300 | interlude |
| 9 | `disruption_pulse` | Disruption Pulse | expert | 2 | utility | null | 1 arcanite_shard + 1 pallor_sample | 350 | interlude |
| 10 | `pallor_grenade` | Pallor Grenade | anti_pallor | 3 | offensive | spirit | 2 pallor_sample + 1 spirit_essence | 250 | act_iii |
| 11 | `pallor_salve` | Pallor Salve | anti_pallor | 3 | consumable_craft | null | 2 pallor_sample + 1 spirit_essence | 200 | act_iii |
| 12 | `arcanite_lance` | Arcanite Lance | anti_pallor | 3 | advanced | non_elemental | 1 arcanite_core + 1 elemental_core | 500 | act_iii |
| 13 | `emergency_beacon` | Emergency Beacon | ultimate | 4 | advanced | null | 1 arcanite_core + 2 spirit_essence | 800 | post_convergence |

### Schema — Forging Recipes

```json
{
  "forging_recipes": [
    {
      "id": "arcanite_blade",
      "name": "Arcanite Blade",
      "result_id": "arcanite_blade",
      "result_type": "weapon",
      "materials": [
        {"item_id": "arcanite_ingot", "quantity": 1},
        {"item_id": "crystal_shard", "quantity": 3}
      ],
      "gold_fee": 500,
      "forge_locations": ["ashmark", "caldera", "lira_workshop_corrund", "lira_workshop_caldera"],
      "unlock_phase": "interlude",
      "schematic_required": null,
      "description": "An Arcanite-infused blade forged for Edren."
    }
  ],
  "infusions": [
    {
      "id": "flame_infusion",
      "name": "Flame Infusion",
      "element": "flame",
      "tier": "basic",
      "materials": [
        {"item_id": "element_shard", "quantity": 2},
        {"item_id": "molten_gear", "quantity": 1}
      ],
      "gold_fee": 300,
      "description": "Permanently imbue a weapon with flame element."
    }
  ]
}
```

### Field Definitions — Forging Recipe

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, matches result equipment ID |
| `name` | string | Exact name from equipment.md |
| `result_id` | string | Equipment ID in gap 1.3 weapons.json or armor.json. Must exist. |
| `result_type` | string | `weapon` or `armor` |
| `materials` | array | `[{item_id, quantity}]`. All must exist in gap 1.3 materials.json |
| `gold_fee` | int | Gold cost at forge (400-500g per equipment.md) |
| `forge_locations` | array[string] | Location IDs where recipe can be crafted |
| `unlock_phase` | string | `interlude`, `act_iii`, `post_convergence` |
| `schematic_required` | string/null | Key item ID required to unlock. null for non-schematic recipes |
| `description` | string | Brief description |

### Forging Recipe List (9 recipes)

| # | ID | Name | Type | Materials | Gold | Phase | Schematic |
|---|---|------|------|-----------|------|-------|-----------|
| 1 | `arcanite_blade` | Arcanite Blade | weapon | 1 arcanite_ingot + 3 crystal_shard | 500 | interlude | null |
| 2 | `forgewright_maul` | Forgewright Maul | weapon | 1 arcanite_ingot + 2 scrap_metal + 1 drill_fragment | 500 | interlude | null |
| 3 | `arcanite_helm` | Arcanite Helm | armor | 1 arcanite_ingot + 2 drill_fragment | 400 | interlude | null |
| 4 | `thornspear` | Thornspear | weapon | 3 spirit_essence + 2 petrified_bark | 400 | act_iii | null |
| 5 | `shadowsteel_knife` | Shadowsteel Knife | weapon | 2 pallor_sample + 1 arcanite_shard | 400 | act_iii | null |
| 6 | `resonance_rod` | Resonance Rod | weapon | 2 elemental_core + 2 ley_crystal_fragment | 500 | act_iii | null |
| 7 | `pallor_ward_vest` | Pallor Ward Vest | armor | 3 pallor_sample + 2 grey_residue + 1 spirit_essence | 500 | act_iii | null |
| 8 | `ley_woven_cloak` | Ley-Woven Cloak | armor | 2 ether_wisp + 2 elemental_core + 1 ley_crystal_fragment | 500 | act_iii | null |
| 9 | `liras_masterwork` | Lira's Masterwork | weapon | 1 grey_mist_essence + 1 arcanite_ingot | 500 | act_iii | `daels_ledger` |

### Field Definitions — Infusion

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique |
| `name` | string | Exact name from equipment.md |
| `element` | string | `flame`, `frost`, `storm`, `earth`, `ley`, `spirit`, `void` |
| `tier` | string | `basic` (300g) or `advanced` (500g) |
| `materials` | array | `[{item_id, quantity}]`. All must exist in gap 1.3 materials.json |
| `gold_fee` | int | 300 (basic) or 500 (advanced) |
| `description` | string | Brief description |

### Infusion List (7 infusions)

| # | ID | Name | Element | Tier | Materials | Gold |
|---|---|------|---------|------|-----------|------|
| 1 | `flame_infusion` | Flame Infusion | flame | basic | 2 element_shard + 1 molten_gear | 300 |
| 2 | `frost_infusion` | Frost Infusion | frost | basic | 2 element_shard + 1 crystal_shard | 300 |
| 3 | `storm_infusion` | Storm Infusion | storm | basic | 2 element_shard + 1 scrap_metal | 300 |
| 4 | `earth_infusion` | Earth Infusion | earth | basic | 2 element_shard + 1 stone_fragment | 300 |
| 5 | `ley_infusion` | Ley Infusion | ley | advanced | 2 elemental_core + 1 ley_crystal_fragment | 500 |
| 6 | `spirit_infusion` | Spirit Infusion | spirit | advanced | 2 spirit_essence + 1 ether_wisp | 500 |
| 7 | `void_infusion` | Void Infusion | void | advanced | 2 pallor_sample + 1 grey_residue | 500 |

### Schema — Synergies

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

### Field Definitions — Synergy

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique |
| `name` | string | Exact name from equipment.md |
| `base_weapon_id` | string/null | Specific weapon ID (e.g., `grey_cleaver_tainted`). null if class-based |
| `base_weapon_class` | string/null | Weapon class for "any X" synergies (e.g., `torren_spear`). null if specific ID |
| `infusion_element` | string | Element that triggers synergy |
| `result_element` | string | Element of transformed weapon |
| `bonus_effect` | string | Bonus effect description from equipment.md |
| `discovery_channel` | string | `both`, `npc_only`, `lira_only` |
| `description` | string | Brief description |

### Synergy List (7 synergies)

| # | ID | Name | Base Weapon | Infusion | Bonus | Channel |
|---|---|------|-------------|----------|-------|---------|
| 1 | `penitents_edge` | Penitent's Edge | `grey_cleaver_tainted` (specific) | spirit | Purification counter: 50 encounters | both |
| 2 | `stormforge_hammer` | Stormforge Hammer | `architects_hammer` (specific) | storm | +25% damage vs Construct-type | both |
| 3 | `rootbound_lance` | Rootbound Lance | `torren_spear` (class) | earth | 20% Slow on physical hit | npc_only |
| 4 | `resonance_staff` | Resonance Staff | `maren_staff` (class) | ley | MP cost -15% all spells | lira_only |
| 5 | `shadowfang` | Shadowfang | `sable_dagger` (class) | void | Steal rate +25%, 15% Despair | npc_only |
| 6 | `crucible_maul` | Crucible Maul | `lira_hammer` (class) | flame | Device gold cost -50% | lira_only |
| 7 | `oathkeeper` | Oathkeeper | `edren_sword` (class) | spirit | +15% dmg when ally Fainted | npc_only |

### Forge Location IDs

| Location ID | Name | Access |
|-------------|------|--------|
| `ashmark` | Ashmark Forge-Masters' Guild | Act II+ |
| `caldera` | Caldera Forgewrights' Academy | Act II+ |
| `forgotten_forge` | Forgotten Forge (Dry Well F7) | Act III |
| `inn_workbench` | Any inn with a hearth | Act I+ (basic only) |
| `lira_workshop_corrund` | Lira's workshop, Corrund | Interlude |
| `lira_workshop_caldera` | Lira's workshop, Caldera undercity | Interlude |
| `oasis_b` | Oasis B jury-rigged forge | Act III |

### Special Cases

**Pallor Salve dual nature:** Exists as both a shop consumable (gap 1.3 consumables.json, 2,500g) AND a craftable device (this file, 3 AC + materials + 200g). Different entries, different systems. The craftable version uses a device loadout slot.

**Arcanite Lance prerequisite:** Requires `forge_schematic` key item (stolen from The Architect boss). This is the only steal-gated craftable in the game. If missed, the device recipe is permanently locked.

**Lira's Masterwork prerequisite:** Requires `daels_ledger` key item (quest reward). Also requires Forgotten Forge access.

**Synergy base_weapon_class:** For class-based synergies (e.g., "any Torren Spear"), the runtime checks if the weapon's `equippable_by` includes the character AND the weapon_type matches. Static data just records the class pattern — runtime resolution deferred to gap 3.4.

---

## Cross-File Consistency Rules

1. **Every encounter enemy_id must exist** in gap 1.2 enemy files (act_i.json through bosses.json)
2. **Every device/recipe material item_id must exist** in gap 1.3 materials.json
3. **Every forging recipe result_id must exist** in gap 1.3 weapons.json or armor.json
4. **Encounter group weights must sum to 100** per floor (within rounding tolerance of 0.01)
5. **Formation rates must sum to 100** per floor
6. **All IDs snake_case**, globally unique within namespace (encounters, devices, recipes, infusions, synergies)
7. **Every entry has ALL required fields** — use null for inapplicable, not omission
8. **HARD GATE: Programmatic stale-count scan** of ALL spec/plan/gap docs before committing

## Counts Summary

| Category | Files | Entries |
|----------|-------|---------|
| World dungeon encounters (1.6) | 20 | ~20 dungeons, variable floor-groups |
| City dungeon encounters (1.6) | 6 | ~6 dungeons, variable floor-groups |
| Overworld encounters (1.6) | 1 | 12 terrain zones |
| Devices (1.7) | 1 | 13 devices |
| Forging recipes (1.7) | — | 9 recipes (in recipes.json) |
| Infusions (1.7) | — | 7 infusions (in recipes.json) |
| Synergies (1.7) | 1 | 7 synergies |
| **Total** | **30** | — |

## Verification Checklist

- [ ] Every encounter enemy_id exists in gap 1.2 enemy files
- [ ] Every encounter group weight sums to 100% per floor
- [ ] Every formation_rates object sums to 100%
- [ ] Formation rates match terrain_type per combat-formulas.md table
- [ ] Danger increments match combat-formulas.md terrain table
- [ ] Every device material item_id exists in gap 1.3 materials.json
- [ ] Every forging recipe result_id exists in gap 1.3 equipment files
- [ ] Every infusion material item_id exists in gap 1.3 materials.json
- [ ] Synergy base_weapon_id values exist in gap 1.3 weapons.json
- [ ] All IDs unique within namespace
- [ ] All entries have ALL required schema fields
- [ ] Actual file/entry counts match this spec exactly
- [ ] HARD GATE: Programmatic stale-count scan passes before commit
