# Gaps 1.4 + 1.5: Shop Data + Spell & Ability Data — Design Spec

> **Date:** 2026-04-04
> **Gaps:** 1.4 (Shop Data) + 1.5 (Spell & Ability Data)
> **Status:** Approved
> **Source docs:** economy.md (shop inventories), magic.md (spells), abilities.md (character abilities)
> **Architecture ref:** technical-architecture.md Sections 2.4, 2.7

## Problem

Shop inventories (~23 shops across 10 towns), spell data (~89 spells across 3 traditions + void), and character ability data (~44 abilities + 12 combos) need to be converted from design docs to runtime JSON. These are independent gaps combined for efficiency — different source docs, different output directories, no cross-dependencies.

## Scope

**Gap 1.4 — Shop Data:**
- ~23 shop JSON files (one per shop, multiple shops per town)
- Source: economy.md complete shop inventory tables
- Cross-references gap 1.3 item/equipment IDs

**Gap 1.5 — Spell & Ability Data:**
- 5 spell JSON files (one per tradition + streetwise)
- 7 ability JSON files (one per character + combos)
- Source: magic.md (spells), abilities.md (abilities)
- **Descriptive data only** — ability entries capture name, cost, effect text, target. Runtime execution logic (AP tracking, WG accumulation, Spirit Favor, device mechanics) deferred to gap 3.3 (Battle Scene). Same pattern as boss AI scripts in gap 1.2.

**Excluded:**
- Forgewright device recipes → gap 1.7 (Crafting & Device Data)
- Ley Crystal invocations → deferred to gap 1.7 (they are item-based active abilities tied to equipped crystals, not tradition spells; documented in items.md not magic.md spell tables)
- Runtime ability execution schemas → gap 3.3 (Battle Scene)

---

## Gap 1.4: Shop Data

### File Structure

| File | Town | Shop Type |
|------|------|-----------|
| `aelhart_general.json` | Aelhart | General Store |
| `highcairn_provisioner.json` | Highcairn | Provisioner |
| `valdris_crown_general.json` | Valdris Crown | General Store |
| `valdris_crown_armorer.json` | Valdris Crown | Armorer |
| `valdris_crown_specialty.json` | Valdris Crown | Specialty |
| `corrund_general.json` | Corrund | General Store |
| `corrund_armorer.json` | Corrund | Armorer |
| `corrund_black_market.json` | Corrund | Black Market |
| `caldera_company_store.json` | Caldera | Company Store |
| `caldera_company_armorer.json` | Caldera | Company Armorer |
| `caldera_black_market.json` | Caldera | Black Market |
| `ashmark_general.json` | Ashmark | General Store |
| `ashmark_armorer.json` | Ashmark | Armorer |
| `bellhaven_general.json` | Bellhaven | General Store |
| `bellhaven_armorer.json` | Bellhaven | Armorer |
| `bellhaven_specialty.json` | Bellhaven | Specialty |
| `thornmere_provisioner.json` | Thornmere | Provisioner |
| `thornmere_craftsman.json` | Thornmere | Local Craftsman |
| `ironmark_quartermaster.json` | Ironmark | Refugee Quartermaster |
| `ironmark_scavenger.json` | Ironmark | Scavenger Armorer |
| `oasis_a.json` | Oasis A | Mixed |
| `oasis_b.json` | Oasis B | Mixed |
| `oasis_c.json` | Oasis C | Mixed |

Total: 23 shop files in `game/data/shops/`.

### Schema

```json
{
  "shop": {
    "shop_id": "valdris_crown_general",
    "town": "valdris_crown",
    "type": "general",
    "markup": 1.0,
    "inventory": [
      {
        "item_id": "potion",
        "buy_price": 50,
        "available_act": 1,
        "stock_limit": null,
        "restock_event": null
      }
    ]
  }
}
```

### Field Definitions — Shop

| Field | Type | Notes |
|-------|------|-------|
| `shop_id` | string | snake_case, unique across all shop files |
| `town` | string | Town ID (snake_case) |
| `type` | string | `general`, `armorer`, `specialty`, `provisioner`, `craftsman`, `black_market`, `company_store`, `company_armorer`, `quartermaster`, `scavenger`, `mixed` |
| `markup` | float | Price multiplier. 1.0 for standard. 1.5 for Caldera Company shops |

### Field Definitions — Inventory Entry

| Field | Type | Notes |
|-------|------|-------|
| `item_id` | string | Must exist in gap 1.3 item/equipment files. Uses same IDs |
| `buy_price` | int | Price at THIS shop. Caldera Company shops: standard price × 1.5, pre-computed |
| `available_act` | int | Act when item first appears: 1, 2, or 3 |
| `stock_limit` | int/null | null = unlimited. Integer for limited stock per visit (e.g., Pallor Salve: 3) |
| `restock_event` | string/null | Event flag that triggers this item appearing. null = always available from available_act |

### Caldera Pricing Rule

- Caldera Company Store and Company Armorer: `"markup": 1.5`. All `buy_price` values in inventory are pre-multiplied (already × 1.5 of standard price).
- Caldera Black Market (Tash's): `"markup": 1.0`. Standard prices per economy.md ("does NOT participate in Compact pricing").
- Caldera Employee Card discount (25%): Applied at runtime by checking key_item inventory, not baked into shop data.

### Interlude Scarcity

Not modeled in static shop data. Handled at runtime by GameManager checking act/event state. Shop files contain the FULL inventory across all acts. The game engine filters by `available_act` and `restock_event`.

### DataManager Compatibility

`DataManager.load_shop(town)` at line 80 of data_manager.gd returns a Dictionary. The method signature is `load_shop(town: String) -> Dictionary`. It loads `res://data/shops/{town}.json`. Since we have multiple shops per town, the file naming uses `{town}_{type}` format, and the calling code would use `load_shop("valdris_crown_general")` (the full shop_id as the parameter).

---

## Gap 1.5: Spell Data

### File Structure

| File | Tradition | Content |
|------|-----------|---------|
| `ley_line.json` | Ley Line (Valdris) | Frost, Storm, Ley, Non-elemental spells (primary: Maren, Edren, Cael; also learned by others) |
| `forgewright.json` | Forgewright (Carradan) | Flame spells (primary: Lira; also learned by Maren, Cael via tradition sharing) |
| `spirit.json` | Spirit (Thornmere) | Earth, Spirit spells + healing (primary: Torren; also learned by Maren, Edren via cross-training) |
| `void.json` | Void/Corrupted | Enemy-only + party post-game void spells |
| `streetwise.json` | Streetwise (Sable) | Sable-exclusive non-tradition spells (Smokeveil, Glintmark) |

Total: 5 spell files in `game/data/spells/`. ~89 spells total (39 ley_line + 6 forgewright + 32 spirit + 10 void + 2 streetwise).

### Schema

```json
{
  "spells": [
    {
      "id": "ember_lance",
      "name": "Ember Lance",
      "tradition": "forgewright",
      "element": "flame",
      "category": "offensive",
      "tier": 1,
      "power": 14,
      "mp_cost": 4,
      "target": "single_enemy",
      "hit_rate": null,
      "duration": null,
      "description": "A focused lance of flame. Basic fire attack.",
      "learned_by": [
        { "character": "maren", "level": 1 }
      ],
      "cross_trained": false,
      "mp_penalty": null
    }
  ]
}
```

### Field Definitions — Spell

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all spell files |
| `name` | string | Exact name from magic.md |
| `tradition` | string | `ley_line`, `forgewright`, `spirit`, `void`, `streetwise` (Sable-only spells: Smokeveil, Glintmark) |
| `element` | string/null | `flame`, `frost`, `storm`, `earth`, `ley`, `spirit`, `void`, `non_elemental`, or null for non-elemental buffs/utility |
| `category` | string | `offensive`, `healing`, `status`, `buff`, `debuff`, `utility`, `special` |
| `tier` | int | 1 (Basic), 2 (Mid), 3 (High), 4 (Ultimate) |
| `power` | int/null | Spell power value from magic.md. null for non-damage spells |
| `mp_cost` | int/null | MP cost. null for void enemy-only spells or WG-cost spells |
| `target` | string | `single_enemy`, `all_enemies`, `single_ally`, `all_allies`, `self`, `fainted_ally` |
| `hit_rate` | int/null | Base hit % for status spells (50-80). null for guaranteed-hit |
| `duration` | int/null | Turn duration for buffs/debuffs. null for instant effects |
| `description` | string | Effect description from magic.md |
| `learned_by` | array | `[{"character": "maren", "level": 1}]` or `[{"character": "torren", "event": "spirit_communion"}]` |
| `cross_trained` | bool | false at spell level. Cross-training is per-learner — see learned_by entries |
| `mp_penalty` | float/null | null at spell level. Per-learner cross-training adds `cross_trained: true` and `mp_penalty: 1.5` to the learned_by entry |

**Cross-training note:** The `cross_trained` and `mp_penalty` fields exist at the spell level for schema consistency (always false/null) but the ACTUAL cross-training data lives in the `learned_by` array entries. A learned_by entry with `"cross_trained": true, "mp_penalty": 1.5` means that specific character learns the spell via cross-training with +50% MP cost. Native learners omit these fields.

### Spell Categories

| Category | Description | Examples |
|----------|-------------|---------|
| offensive | Direct damage | Ember Lance, Tempest Reign, Worldfire |
| healing | HP restoration | Mend, Deepmend, Resurgence, Lifetide |
| status | Inflict status effects | Vilethorn (poison), Slumber Mote (sleep) |
| buff | Stat/defense increase | Ironhide, Quickstep, Leymirror |
| debuff | Stat/defense decrease | Sunder, Crumble, Dampening Field |
| utility | Non-combat or special | Spiritsight, Waymark, Linewalk |
| special | Unique mechanics | Leydraught (HP→MP), Revive spells |

---

## Gap 1.5: Ability Data

### File Structure

| File | Character | Command | Abilities |
|------|-----------|---------|-----------|
| `edren.json` | Edren | Bulwark | 7 |
| `cael.json` | Cael | Rally | 5 |
| `maren.json` | Maren | Arcanum | 7 |
| `sable.json` | Sable | Tricks | 7 |
| `lira.json` | Lira | Forgewright | 10 |
| `torren.json` | Torren | Spiritcall | 8 |
| `combos.json` | All | Dual-Tech | 12 |

Total: 7 ability files in `game/data/abilities/`. 44 abilities + 12 combos.

### Schema — Character Abilities

```json
{
  "abilities": [
    {
      "id": "ironwall",
      "name": "Ironwall",
      "character": "edren",
      "command": "bulwark",
      "level_learned": 1,
      "cost": "0 AP",
      "cost_type": "ap",
      "cost_value": 0,
      "cooldown": null,
      "target": "single_ally",
      "effect": "Stance: absorb 50% physical damage to one ally.",
      "row_restriction": null,
      "story_gated": false,
      "story_event": null,
      "description": "Take a defensive stance, absorbing damage for an ally."
    }
  ]
}
```

### Field Definitions — Ability

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all ability files |
| `name` | string | Exact name from abilities.md |
| `character` | string | Character ID |
| `command` | string | `bulwark`, `rally`, `arcanum`, `tricks`, `forgewright`, `spiritcall` |
| `level_learned` | int/null | Level when learned. null for story-gated |
| `cost` | string | Human-readable: "0 AP", "6 MP", "50 WG", "2 AC", "8 MP / 4 turns" |
| `cost_type` | string | `ap`, `mp`, `wg`, `ac`, `mp_cd`, `none` |
| `cost_value` | int | Numeric cost (0 for free) |
| `cooldown` | int/null | Turns between uses. null for no cooldown |
| `target` | string | `single_ally`, `all_allies`, `single_enemy`, `all_enemies`, `self`, `party` |
| `effect` | string | Full effect description from abilities.md |
| `row_restriction` | string/null | `"front"` for Sable's steal abilities. null otherwise |
| `story_gated` | bool | true for trial/story-unlocked abilities |
| `story_event` | string/null | Event flag that unlocks. null if level-learned |
| `description` | string | Brief in-game description |

### Schema — Combos

```json
{
  "combos": [
    {
      "id": "shield_oath",
      "name": "Shield Oath",
      "characters": ["edren", "cael"],
      "cost": "Edren: 7 MP, Cael: 7 MP",
      "effect": "Synergized buffs: Edren enters Ironwall on Cael, Cael activates Press Forward on Edren. Both 4 turns.",
      "availability": "Acts I-II only (lost after Cael's betrayal)",
      "description": "A coordinated defensive-offensive stance between commander and knight."
    }
  ]
}
```

**Combo cost convention:** abilities.md uses MP universally for all combo costs, regardless of each character's unique resource type (AP, AC, WG). This is the canonical representation — combos draw from a shared MP pool that all characters have in addition to their unique resource. The `cost` string matches abilities.md exactly. Runtime combo resolution (how AP/AC/WG interact with combo costs) is deferred to gap 3.3.

### Design Decision: Descriptive Data Only

Ability entries capture WHAT each ability does but NOT how the runtime executes it. This means:
- No Aegis Point accumulation logic
- No Weave Gauge tracking
- No Spirit Favor progression system
- No Arcanite Charge management
- No Stolen Goods inventory
- No device deployment/duration tracking
- No combo ATB synchronization

All of these are runtime systems implemented in GDScript during gap 3.3 (Battle Scene). The JSON data tells the battle system what abilities exist and what they should do; the GDScript implements how.

This matches the gap 1.2 pattern where boss AI scripts were captured as phase metadata but the actual AI state machine was deferred.

---

## Cross-File Consistency Rules

1. **Shop item_ids must exist** in gap 1.3 item/equipment files (all 6)
2. **Shop buy_prices must match** economy.md (with Caldera ×1.5 applied)
3. **Spell IDs unique** across all 5 spell files
4. **Ability IDs unique** across all 7 ability files (6 characters + combos)
5. **Spell learned_by character IDs** must be valid: edren, cael, maren, sable, lira, torren
6. **Ability character IDs** must match gap 1.1 character data
7. **All IDs snake_case**, globally unique within their namespace (shops, spells, abilities)
8. **Every entry has ALL required fields** — use null for inapplicable, not omission
9. **HARD GATE: Programmatic stale-count scan** of ALL spec/plan/gap docs before committing

## Counts Summary

| Category | Files | Entries |
|----------|-------|---------|
| Shops (1.4) | 23 | ~23 shops (variable items per shop) |
| Spells (1.5) | 5 | ~89 spells |
| Abilities (1.5) | 6 | ~44 abilities |
| Combos (1.5) | 1 | 12 combos |
| **Total** | **35** | — |

## Verification Checklist

- [ ] Every shop item_id exists in gap 1.3 item/equipment files
- [ ] Every shop buy_price matches economy.md (Caldera ×1.5 applied)
- [ ] Caldera Company shops have markup: 1.5, Black Market has markup: 1.0
- [ ] Every spell name, power, MP cost, element, target matches magic.md
- [ ] Every spell learned_by character+level matches magic.md
- [ ] Cross-trained spells have cross_trained: true and mp_penalty: 1.5
- [ ] Every ability name, cost, effect matches abilities.md
- [ ] Sable's Filch, Ransack, Wild Card have row_restriction: "front"
- [ ] Story-gated abilities have story_gated: true with correct story_event
- [ ] All IDs unique within namespace (shops / spells / abilities)
- [ ] All entries have ALL required schema fields
- [ ] Actual file/entry counts match this spec exactly
- [ ] HARD GATE: Programmatic stale-count scan passes before commit
