# Gap 1.2: Enemy Data JSON — Design Spec

> **Date:** 2026-04-02
> **Gap:** 1.2 (Tier 1: Data Foundation)
> **Status:** Approved
> **Source docs:** bestiary/ (9 files), economy.md (steal tiers), abilities.md (Filch two-tier steal), technical-architecture.md Section 2.1

## Problem

The game has ~204 regular enemies and ~36 boss entries defined across 9 bestiary markdown files in `docs/story/bestiary/`. These need to be converted to runtime JSON data files in `game/data/enemies/` for DataManager to load. No enemy JSON data currently exists.

## Decision: Two-Tier Steal

**Resolved:** Implement two-tier steal (common + rare) per abilities.md and economy.md.

- abilities.md: "Each enemy has a common and rare steal"
- economy.md: full steal tier table by enemy type (Common 75%, Rare 25%)
- Bestiary tables show only the common steal; rare steals follow economy.md type patterns
- Tech-arch Section 2.1 uses a single steal object; this spec extends it to nested `{ common, rare }`. Tech-arch Section 2.1 should be updated to match in a follow-up.

## Schema

Extends tech-arch Section 2.1 with the following changes:
- `steal` becomes `{ common, rare }` nested object (was single `{ item_id, rate }`)
- Added `threat` field for reward validation and rebalancing
- Added `locations` array (not in original Section 2.1)
- `ko_sound` allows per-enemy override

```json
{
  "enemies": [
    {
      "id": "ley_vermin",
      "name": "Ley Vermin",
      "type": "beast",
      "threat": "trivial",
      "level": 1,
      "hp": 23,
      "mp": 0,
      "atk": 8,
      "def": 6,
      "mag": 7,
      "mdef": 5,
      "spd": 8,
      "gold": 1,
      "exp": 4,
      "weaknesses": [],
      "resistances": [],
      "absorb": [],
      "status_immunities": [],
      "steal": {
        "common": { "item_id": "beast_hide", "rate": 75 },
        "rare": { "item_id": "sharp_fang", "rate": 25 }
      },
      "drop": { "item_id": "sharp_fang", "rate": 25 },
      "locations": ["ember_vein_f1", "ember_vein_f2"],
      "ko_sound": "ko_beast"
    }
  ]
}
```

### Field Definitions

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| `id` | string | Derived from name (snake_case) | Unique across act files; bosses intentionally share IDs between act files and bosses.json (same enemy, separate load paths) |
| `name` | string | Bestiary "Name" column | Exact match |
| `type` | string | Bestiary "Type" column | Lowercase: beast, undead, construct, spirit, humanoid, pallor, elemental, boss |
| `threat` | string | palette-families.md / act summary | trivial, low, standard, dangerous, rare, boss. See README.md Threat Multiplier table |
| `level` | int | Bestiary "Lv" column | |
| `hp`–`spd` | int | Bestiary stat columns | Exact values from tables |
| `gold` | int | Bestiary "Gold" column | Pre-computed with threat multiplier baked in |
| `exp` | int | Bestiary "Exp" column | Pre-computed with threat multiplier baked in |
| `weaknesses` | array | Bestiary "Weak" column | Element strings or `{ "element": "storm", "multiplier": 1.5 }` for explicit multipliers |
| `resistances` | array | Bestiary "Resists" column | Same format as weaknesses; percentage values like "(75%)" become `{ "element": "flame", "multiplier": 0.75 }` |
| `absorb` | array | Bestiary "Absorbs" column | Element strings |
| `status_immunities` | array | Bestiary "Status Immunities" column | Lowercase snake_case |
| `steal` | object/null | Bestiary "Steal" + economy.md rare tier | See steal rules below |
| `drop` | object/null | Bestiary "Drop" column | `{ "item_id", "rate" }` or null |
| `locations` | array | Bestiary "Location(s)" column | Snake_case location IDs (see derivation rules below) |
| `ko_sound` | string | Derived from type, per-enemy override allowed | Default: `ko_{type}`. Bosses use thematic override (e.g., `ko_construct` for a Construct boss) |

### Threat Level Assignment

The `threat` field comes from palette-families.md tier entries and act summary sections. Values map to the README.md reward multiplier table:

| Threat | Multiplier | Assignment rule |
|--------|-----------|-----------------|
| trivial | x0.15 | Swarm fodder, lowest tier |
| low | x0.35 | Common encounters |
| standard | x0.60 | Typical dungeon enemy (default) |
| dangerous | x1.0 | Elite enemies, mini-boss-tier |
| rare | x1.5 | Rare encounters, Tier 4 palette swaps |
| boss | hand-tuned | Manual Gold/Exp per boss |

Gold and Exp in the bestiary tables already have the threat multiplier baked in. The `threat` field enables runtime validation and future rebalancing. Per the README early deployment rule, threat level is preserved even when enemies are deployed at lower levels.

### Steal Mapping Rules

The `rate` field represents the probability that the item exists in the enemy's steal slot. When Sable uses Filch, the game first rolls against Filch's success rate (SPD-based per abilities.md), then checks whether the item is present using the `rate`. Common is rolled first; if common fails or is null, rare is rolled.

1. **Bestiary "Steal" column** → `steal.common` with its listed rate (typically 75%)
2. **Rare steal** → derived from economy.md type table where bestiary only shows one steal:
   - Beast: tier 2 material from same family (e.g., beast_hide common → sharp_fang rare)
   - Construct: `scrap_metal` common → `elemental_core` rare
   - Humanoid: consumable common → `gold_pouch` rare
   - Spirit: `ether_wisp` common → `ley_crystal_fragment` rare
   - Pallor: `grey_residue` or `pallor_sample` common → `pallor_shard` rare
   - Undead: `bone_fragment` common → `ancient_glyph` rare
   - Elemental: `element_shard` common → `elemental_core` rare (inferred from bestiary patterns — economy.md omits Elemental row)
3. **"—" in bestiary** → `"steal": null`
4. **Bosses with 100% unique steal** → `"steal": { "common": null, "rare": { "item_id": "...", "rate": 100 } }` — Filch always yields the unique item on success (rate 100 means item always present; Filch still requires its SPD-based success roll)
5. **Mini-bosses with 75% steal** (e.g., Ember Drake) → normal two-tier steal like regular enemies
6. Rare steal rate is always 25% for regular enemies

### Element Encoding

- Simple weakness/resistance: `"storm"` (string)
- Explicit multiplier: `{ "element": "storm", "multiplier": 1.5 }` (object)
- Resistances with percentage: `{ "element": "flame", "multiplier": 0.75 }` where `(75%)` → 0.75, `(50%)` → 0.5
- Empty: `[]`
- Rotating (Confluence Elemental): `["cycle"]` (array containing the special string `"cycle"` — runtime handles the rotation logic)

### Location ID Derivation Rules

Location strings from the bestiary are converted to snake_case IDs with these rules:

1. Strip parenthetical annotations: "Ashmark Factory Depths (non-lethal)" → "Ashmark Factory Depths"
2. Convert to snake_case: "Ashmark Factory Depths" → `ashmark_factory_depths`
3. Floor ranges expand: "Ember Vein F1–F2" → `["ember_vein_f1", "ember_vein_f2"]`
4. Single floors: "Ember Vein F3" → `["ember_vein_f3"]`
5. Named sections: "Rail Tunnels (Hub, East)" → `["rail_tunnels_hub", "rail_tunnels_east"]`
6. Generic "all sections": "Rail Tunnels (all sections)" → `["rail_tunnels"]`
7. Overworld areas: "Valdris Plains" → `["valdris_plains"]`
8. Spawned enemies: "spawned by Gyrocopter" → `["valdris_siege"]` (parent encounter location)
9. Apostrophes removed: "Fenmother's Hollow" → `fenmothers_hollow`
10. "The" prefix removed from location IDs: "The Ley Scar" → `ley_scar`

### Boss-Specific Fields

Bosses in `bosses.json` get additional fields:

```json
{
  "is_boss": true,
  "is_mini_boss": false,
  "phases": 2,
  "phase_hp_thresholds": [0.5],
  "boss_group": null
}
```

- `phases`: number of phases
- `phase_hp_thresholds`: HP% that triggers phase transitions (e.g., `[0.5]` = Phase 2 at 50% HP)
- `boss_group`: links multi-entry bosses (e.g., Cael Phase 1 and Phase 2 share `"boss_group": "cael_knight_of_despair"`)
- `is_mini_boss`: true for mini-bosses (Ember Drake, Drowned Sentinel, etc.)

### Special Cases

| Enemy | Encoding |
|-------|----------|
| Pallor-Touched Worker (non-lethal) | `"gold": 0, "exp": 0, "non_lethal": true, "steal": { "common": { "item_id": "potion", "rate": 75 }, "rare": null }` (no rare steal — victim, not combatant) |
| Archive Keeper (variable HP) | `"hp": 3000, "hp_max_variable": 12000` |
| Vaelith Siege (scripted loss) | `"scripted_loss": true, "hp": 999999` |
| Confluence Elemental (rotating) | `"weaknesses": ["cycle"], "absorb": ["cycle"]` |
| The Lingering (3 stat rows) | 3 entries in bosses.json with `"boss_group": "the_lingering"` |
| Cael (2 stat rows) | 2 entries with `"boss_group": "cael_knight_of_despair"` |

### Intentional Exclusions

- **Enemy abilities/AI scripts:** Not encoded in JSON. Abilities are runtime behavior implemented in GDScript (future gaps). Boss AI scripts live in bosses.md and will be implemented as GDScript state machines.
- **Palette family metadata:** Family name, tier number, etc. are design-time concepts, not runtime data. The enemy's stats already reflect its tier.

## File Structure

| File | Source | Enemies |
|------|--------|---------|
| `game/data/enemies/act_i.json` | bestiary/act-i.md | 25 |
| `game/data/enemies/act_ii.json` | bestiary/act-ii.md | 33 |
| `game/data/enemies/interlude.json` | bestiary/interlude.md | 52 |
| `game/data/enemies/act_iii.json` | bestiary/act-iii.md | 69 |
| `game/data/enemies/optional.json` | bestiary/optional.md | 25 |
| `game/data/enemies/bosses.json` | bestiary/bosses.md + per-act boss entries | 35 entries (31 unique bosses + 2 extra Cael phases + 3 Lingering phases - 1 Cael single - 1 Lingering single + 1 Vaelith siege) |

Act files include ALL enemies for that act (regular + bosses). `bosses.json` duplicates boss stat data but adds boss-specific metadata (phases, thresholds). This duplication is intentional — act files are loaded for encounter tables, bosses.json is loaded for battle AI.

## Implementation Approach

Parallel agent transcription: 6 agents dispatched simultaneously, one per JSON file. Each agent reads its source bestiary file, the economy.md steal table, and this spec, then produces the JSON. Followed by adversarial verification pass checking every value against source docs.

## Verification Checklist

- [ ] Every enemy name matches bestiary exactly
- [ ] Every stat value matches bestiary table exactly
- [ ] Every element weakness/resistance/absorb matches bestiary
- [ ] Every status immunity matches bestiary
- [ ] Every steal.common matches bestiary "Steal" column
- [ ] Every steal.rare follows economy.md type patterns
- [ ] Every drop matches bestiary "Drop" column
- [ ] Every gold/exp value matches bestiary
- [ ] Every threat level matches palette-families.md / act summaries
- [ ] Boss HP values match bestiary/bosses.md
- [ ] Boss phase counts match bosses.md quick reference
- [ ] All non-boss enemy IDs are unique across act files; boss ID duplication is allowed only between act files and bosses.json for the same boss stat row
- [ ] All item_ids use snake_case
- [ ] All location IDs follow derivation rules consistently
- [ ] No invented values — everything traces to a source doc
