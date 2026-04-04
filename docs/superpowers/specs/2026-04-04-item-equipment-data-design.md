# Gap 1.3: Item & Equipment Data JSON — Design Spec

> **Date:** 2026-04-04
> **Gap:** 1.3 (Tier 1: Data Foundation)
> **Status:** Approved
> **Source docs:** items.md (consumables, materials, key items), equipment.md (weapons, armor, accessories), economy.md (prices), characters.md (equippable_by)
> **Architecture ref:** technical-architecture.md Sections 2.2, 2.3

## Problem

The game has 300 items and equipment pieces defined across items.md and equipment.md. These need to be converted to 6 runtime JSON files in `game/data/items/` and `game/data/equipment/` for DataManager to load. No item or equipment JSON data currently exists.

## Scope

**Included:** Consumables (33), materials (87), key items (26), weapons (58), armor (49), accessories (47). Total: 300.

**Excluded (deferred):**
- Lira's Forgewright devices → gap 1.7 (Crafting & Device Data)
- Ley Crystal invocations → gap 1.5 (Spell & Ability Data)
- These systems have richer schemas that don't fit the basic item/equipment templates.

## File Structure

| File | Top-Level Key | Source | Count |
|------|---------------|--------|-------|
| `game/data/items/consumables.json` | `"items"` | items.md | 33 |
| `game/data/items/materials.json` | `"items"` | items.md | 87 |
| `game/data/items/key_items.json` | `"items"` | items.md | 26 |
| `game/data/equipment/weapons.json` | `"weapons"` | equipment.md | 58 |
| `game/data/equipment/armor.json` | `"armor"` | equipment.md | 49 |
| `game/data/equipment/accessories.json` | `"accessories"` | equipment.md | 47 |

**Top-level keys match DataManager methods:**
- `load_items(category)` expects `"items"` key
- `load_equipment(equipment_type)` expects the type as key (`"weapons"`, `"armor"`, `"accessories"`)

---

## Consumables Schema

```json
{
  "items": [
    {
      "id": "potion",
      "name": "Potion",
      "category": "consumable",
      "subcategory": "hp_healing",
      "effect": "restore_hp",
      "value": 100,
      "buy_price": 50,
      "sell_price": 25,
      "stack_limit": 199,
      "description": "Restores 100 HP to one ally.",
      "target": "single_ally",
      "usable_in_battle": true,
      "usable_in_field": true
    }
  ]
}
```

### Field Definitions

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all item files |
| `name` | string | Exact match from items.md |
| `category` | string | Always `"consumable"` |
| `subcategory` | string | `hp_healing`, `mp_restoration`, `revival`, `status_cure`, `battle_utility`, `stat_capsule` |
| `effect` | string | Effect type: `restore_hp`, `restore_mp`, `restore_hp_mp`, `revive`, `cure_status`, `flee`, `teleport`, `preemptive`, `stat_boost` |
| `value` | int/null | Numeric effect value (100 for Potion, null for percentage-based like X-Potion) |
| `buy_price` | int/null | Gold cost in shops. null if not sold in shops |
| `sell_price` | int/null | Gold received when selling. null if not sellable |
| `stack_limit` | int | 199 for HP/MP healing (except rest items), 99 for all others |
| `description` | string | In-game description from items.md |
| `target` | string | `single_ally`, `all_allies`, `single_enemy`, `all_enemies`, `self` |
| `usable_in_battle` | bool | Can be used during combat |
| `usable_in_field` | bool | Can be used from the menu outside combat |

### Additional Required Fields

| Field | Type | Notes |
|-------|------|-------|
| `availability` | string | Where/when available, from items.md Availability column. Required on all consumables |

### Additional Conditional Fields

| Field | When Present | Notes |
|-------|-------------|-------|
| `cures` | subcategory = `status_cure` | Array of status effect IDs cured, e.g., `["poison", "burn"]` |
| `requires_save_point` | rest items only | `true` for Sleeping Bag, Tent, Pavilion |
| `restore_percent` | percentage-based items | e.g., `100` for X-Potion (100% HP), `25` for Sleeping Bag |
| `stat` | subcategory = `stat_capsule` | Which stat is boosted: `"atk"`, `"def"`, `"mag"`, `"mdef"`, `"spd"`, `"lck"` |

### Sell Price Rules

- Consumables with a buy_price: `sell_price = floor(buy_price / 2)` per items.md
- Items not sold in shops (Elixir, Megalixir, Hope Shard, Sable's Coin, stat capsules): `buy_price: null, sell_price: null`

### Stack Limit Rules

- HP/MP healing items (subcategory `hp_healing` or `mp_restoration`): 199
- **Exception:** Rest items (Sleeping Bag, Tent, Pavilion): 99
- All other consumables: 99

### Status Cure Mappings (from items.md)

| Item | Cures |
|------|-------|
| Antidote | `["poison", "burn"]` |
| Alarm Clock | `["sleep"]` |
| Echo Drop | `["silence"]` |
| Eye Drops | `["blind"]` |
| Smelling Salts | `["confusion"]` |
| Soft Stone | `["petrify"]` |
| Chronos Dust | `["slow"]` |
| Remedy | `["poison", "burn", "sleep", "silence", "blind", "confusion", "slow", "petrify"]` |
| Pallor Salve | `["despair"]` |
| Hope Shard | `["despair"]` |

### Total: 33 items

9 HP healing + 3 MP restoration + 2 revival + 10 status cure + 3 battle utility + 6 stat capsules = 33

---

## Materials Schema

```json
{
  "items": [
    {
      "id": "beast_hide",
      "name": "Beast Hide",
      "category": "material",
      "tier": 1,
      "source_category": "beast",
      "sell_price": 25,
      "sellable": true,
      "stack_limit": 99,
      "description": "Common leather from beasts. Used in basic crafting.",
      "crafting_use": "Basic leather goods, Mending Engine"
    }
  ]
}
```

### Field Definitions

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all item files |
| `name` | string | Exact match from items.md Complete Material List |
| `category` | string | Always `"material"` |
| `tier` | int | 1 (Common), 2 (Uncommon), 3 (Rare), 4 (Epic) |
| `source_category` | string | `beast`, `construct`, `spirit_elemental`, `pallor`, `undead`, `arcanite`, `humanoid`, `dreamers_fault`, `boss_specific` |
| `sell_price` | int/null | Listed sell price from items.md. null for unsellable items |
| `sellable` | bool | false for Pallor Core, Grey Mist Essence. true for all others |
| `stack_limit` | int | Always 99 |
| `description` | string | Brief description |
| `crafting_use` | string | Primary crafting use from items.md |

**No buy_price field** — materials are never purchased from shops.

### Special Cases

- Pallor Core: `"sellable": false, "sell_price": null` (unsellable story-critical)
- Grey Mist Essence: `"sellable": false, "sell_price": null` (unsellable story-critical)
- Drake Fang: `"battle_usable": true, "battle_effect": "fixed_damage", "battle_value": 500, "battle_target": "single_enemy"` — dual-purpose material with direct battle-use fields (material + battle consumable per items.md). Stacks in Materials tab; using in battle consumes one from material stack.
- Arcanite Shard: `"ac_restorable": true` — dual-purpose material (crafting + consumable AC restoration per crafting.md). Consumed from material stack when used for AC restoration at save points.
- Gold Pouch: `"auto_sell": true, "sell_price": null, "gold_value_by_act": {"act_i": 150, "act_ii": 350, "interlude": 500, "act_iii": 800}` — special humanoid rare steal that awards gold directly on acquisition. `sell_price` is null because the value is determined by `gold_value_by_act` at runtime; `auto_sell` indicates the item is converted to gold immediately, never entering the player's inventory.

### Total: 87 materials

72 from items.md Complete Material List (20 beast + 7 construct + 6 spirit/elemental + 5 pallor + 2 undead + 4 arcanite + 14 humanoid + 8 Dreamer's Fault + 6 boss-specific) + 15 additional (14 boss steal/drop cross-references from gap 1.2 + grey_mist_essence)

---

## Key Items Schema

```json
{
  "items": [
    {
      "id": "mine_water_vial",
      "name": "Mine Water Vial",
      "category": "key_item",
      "subcategory": "dungeon_access",
      "description": "A vial of water from Ember Vein's depths.",
      "auto_use": true,
      "trigger": "approach_dying_ember_crystal",
      "acquired_from": "Ember Vein F2 chest",
      "quest_link": "ember_vein_f3_access"
    }
  ]
}
```

### Field Definitions (all key items)

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all item files |
| `name` | string | Exact match from items.md |
| `category` | string | Always `"key_item"` |
| `subcategory` | string | `dungeon_access`, `boss_memento`, `crafting_schematic`, `story_item` |
| `description` | string | In-game description or flavor text |
| `auto_use` | bool | true for dungeon access items, false for others |
| `acquired_from` | string | Source (boss name, location, quest) |

### Additional Fields by Subcategory

| Subcategory | Extra Fields |
|-------------|-------------|
| `dungeon_access` | `trigger` (activation condition), `quest_link` (area unlocked) |
| `boss_memento` | `dropped_by` (boss ID), `flavor_text` (narrative description) |
| `crafting_schematic` | `recipe_unlocked` (what it unlocks) |
| `story_item` | `plot_effect` (what it does narratively) |

Key items cannot be bought, sold, discarded, or stacked.

### Total: 26 key items

9 dungeon access + 8 boss mementos + 2 crafting schematics + 7 story items (Fenmother's Blessing, Compact Battle Standard, Pallor-Laced Iron, Corrupted Tuning Fork, Caldera Employee Card, Valdris Crest, First Tree Seed)

---

## Weapons Schema

```json
{
  "weapons": [
    {
      "id": "training_sword",
      "name": "Training Sword",
      "type": "sword",
      "tier": 0,
      "equippable_by": ["edren"],
      "atk": 4,
      "bonus_stats": {},
      "element": null,
      "special": null,
      "buy_price": null,
      "sell_price": null,
      "acquired": "Starting equipment",
      "description": "A standard-issue Compact training blade."
    }
  ]
}
```

### Field Definitions

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all equipment files |
| `name` | string | Exact match from equipment.md |
| `type` | string | `sword`, `greatsword`, `staff`, `dagger`, `hammer`, `spear` |
| `tier` | int/string | 0-5, `"forged"`, or `"cursed"` (Grey Cleaver tainted) |
| `equippable_by` | array | Character IDs. Single-element array per weapon type |
| `atk` | int | ATK bonus (type modifier already applied per equipment.md) |
| `bonus_stats` | object | Additional stat bonuses. e.g., `{"mag": 3}`, `{"spd": -2}`. Empty `{}` when none |
| `element` | string/null | Element: `flame`, `frost`, `storm`, `earth`, `ley`, `spirit`, `void`, or `null` |
| `special` | string/null | Passive effect text, or null |
| `buy_price` | int/null | Gold cost. null for starting, boss drops, forged, quest rewards |
| `sell_price` | int/null | `floor(buy_price / 2)` or null when buy_price is null |
| `acquired` | string | Where/how obtained from equipment.md "Acquired" column |
| `description` | string | Brief in-game description |

### equippable_by Mapping

| Weapon Type | Character |
|-------------|-----------|
| sword | `["edren"]` |
| greatsword | `["cael"]` |
| staff | `["maren"]` |
| dagger | `["sable"]` |
| hammer | `["lira"]` |
| spear | `["torren"]` |

### Special Cases

- Grey Cleaver (tainted): `"tier": "cursed"`, `"bonus_stats": {"def": -10, "mdef": -10, "spd": -10}`, `"special": "Despair at battle start. Cursed weapon — purify through 100 Pallor encounters."`
- Grey Cleaver (purified): separate entry, `"tier": 5`, `"element": "spirit"`, `"special": "+50% vs Pallor, Despair immunity"`
- Forged weapons: `"tier": "forged"`, `"buy_price": null, "sell_price": null`
- Cael's Edge: `"equippable_by": ["lira"]`, `"special": "Sever Bond: 1-use 3.0x physical attack ignoring DEF (Vaelith fight only)"`

### Sell Price Rule

`sell_price = floor(buy_price / 2)` per items.md. Weapons with `buy_price: null` have `sell_price: null`.

### Stat Representation: `bonus_stats` Object vs Flat Fields

Tech-arch Section 2.3 uses flat stat fields (`"def": 0, "mag": 0, "mdef": 0, "spd": 0`). This spec uses a `bonus_stats` object (`"bonus_stats": {"mag": 3}`) which is sparse and self-documenting — zero-value stats are omitted rather than padded. The `bonus_stats` approach is preferred for items/equipment because most pieces only modify 1-2 stats. Tech-arch Section 2.3 should be updated to match this convention in a follow-up.

The same `bonus_stats` pattern applies to armor and accessories.

### Total: 58 weapons

10 swords + 6 greatswords + 10 staves + 10 daggers + 11 hammers + 11 spears = 58
(Grey Cleaver tainted + purified are counted within the 11 spears)

---

## Armor Schema

```json
{
  "armor": [
    {
      "id": "leather_cap",
      "name": "Leather Cap",
      "slot": "head",
      "armor_class": null,
      "tier": 0,
      "equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
      "def": 2,
      "mdef": 1,
      "bonus_stats": {},
      "special": null,
      "buy_price": null,
      "sell_price": null,
      "acquired": "Starting (Edren)",
      "description": "A simple leather cap."
    }
  ]
}
```

### Field Definitions

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all equipment files |
| `name` | string | Exact match from equipment.md |
| `slot` | string | `head` or `body` |
| `armor_class` | string/null | `light`, `heavy`, `robe` for body armor. `null` for head armor. Elemental body armor uses `"light"` (per equipment.md: "Light armor with elemental resistance") — elemental property is in `special` field |
| `tier` | int/string | 0-5 or `"forged"` |
| `equippable_by` | array | Character IDs (see rules below) |
| `def` | int | DEF bonus |
| `mdef` | int | MDEF bonus |
| `bonus_stats` | object | Additional stat bonuses. e.g., `{"mag": 5}`. Empty `{}` when none |
| `special` | string/null | Passive effect text, or null |
| `buy_price` | int/null | Gold cost. null for starting, boss drops, forged, quest rewards |
| `sell_price` | int/null | `floor(buy_price / 2)` or null |
| `acquired` | string | Where/how obtained |
| `description` | string | Brief in-game description |

### equippable_by Rules

| Slot + Class | Characters |
|-------------|------------|
| Head (all) | `["edren", "cael", "maren", "sable", "lira", "torren"]` |
| Body — light (including elemental) | `["edren", "cael", "maren", "sable", "lira", "torren"]` |
| Body — heavy | `["edren", "lira"]` |
| Body — robe | `["maren", "torren"]` |

### Total: 49 armor

20 head + 12 light body + 4 elemental body + 8 heavy body + 5 robes = 49

---

## Accessories Schema

```json
{
  "accessories": [
    {
      "id": "power_ring",
      "name": "Power Ring",
      "subcategory": "stat_boost",
      "equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
      "effect": "+5 ATK",
      "bonus_stats": {"atk": 5},
      "special": null,
      "buy_price": 300,
      "sell_price": 150,
      "acquired": "Act I shops",
      "description": "A ring that boosts physical attack power."
    }
  ]
}
```

### Field Definitions

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | snake_case, unique across all equipment files |
| `name` | string | Exact match from equipment.md |
| `subcategory` | string | `stat_boost`, `status_immunity`, `elemental_resistance`, `combat_mechanic`, `boss_drop` |
| `equippable_by` | array | All 6 characters for most. Exceptions: Cael's Knight Crest (`["edren"]`), Unfinished Ring (`["lira"]`) |
| `effect` | string | Human-readable effect description |
| `bonus_stats` | object | Stat modifications. e.g., `{"atk": 5}`, `{"hp": 300}`. Empty `{}` for effect-only accessories |
| `special` | string/null | Passive combat effect text, or null |
| `buy_price` | int/null | Gold cost. null for boss drops, quest rewards |
| `sell_price` | int/null | `floor(buy_price / 2)` or null |
| `acquired` | string | Where/how obtained |
| `description` | string | Brief in-game description |

### Additional Fields (conditional)

| Field | When Present | Notes |
|-------|-------------|-------|
| `source` | subcategory = `boss_drop` | Boss name that drops this accessory |
| `status_immunity` | subcategory = `status_immunity` | Status effect ID made immune, e.g., `"poison"` |
| `element_resist` | subcategory = `elemental_resistance` | Element halved, e.g., `"flame"` |

### Total: 47 accessories

8 stat boost + 6 status immunity + 4 elemental resistance + 9 combat mechanic + 20 boss drop/unique = 47

---

## Cross-File Consistency Rules

1. **Item IDs unique across all 3 item files** (consumables, materials, key_items)
2. **Equipment IDs unique across all 3 equipment files** (weapons, armor, accessories)
3. **Enemy steal/drop IDs from gap 1.2 must exist** in any of the 6 item/equipment files (consumables, materials, key_items, weapons, armor, accessories) — enemy drops can reference equipment IDs too (e.g., grey_cleaver_tainted, architects_hammer)
4. **buy_price values match economy.md** where listed
5. **sell_price = floor(buy_price / 2)** for consumables and equipment; materials use their listed sell_price from items.md
6. **equippable_by matches characters.md** weapon/armor type assignments
7. **All IDs use snake_case** — consistent with gap 1.2 convention
8. **Every entry has ALL schema fields** — no missing fields, use explicit null for inapplicable values
9. **Top-level keys match DataManager** — `"items"` for item files, type name for equipment files

## Lessons Learned from Gap 1.2 (Mandatory)

1. Every entry must have ALL schema fields — no omissions, use explicit null
2. Cross-file data consistency — same entity in multiple files must match
3. Cross-file ID uniqueness — run programmatic sweep, not just within-file checks
4. Document counts in spec must match actual data counts
5. Top-level JSON keys must match DataManager expected format
6. Resistance/element format: bare strings for simple values, objects only when explicit multipliers exist

## Verification Checklist

- [ ] Every item name matches source doc exactly
- [ ] Every price matches economy.md / items.md / equipment.md
- [ ] Every sell_price follows the correct formula (50% buy for consumables/equipment, listed for materials)
- [ ] Every equippable_by matches characters.md weapon/armor types
- [ ] Every status cure mapping matches items.md
- [ ] Every elemental weapon matches equipment.md
- [ ] All item IDs unique across consumables + materials + key_items
- [ ] All equipment IDs unique across weapons + armor + accessories
- [ ] Enemy steal/drop item_ids from gap 1.2 exist in one of this gap's 6 datasets (consumables, materials, key_items, weapons, armor, or accessories)
- [ ] All entries have ALL required schema fields (no missing fields)
- [ ] Top-level keys match DataManager (items, weapons, armor, accessories)
- [ ] No invented values — everything traces to a source doc
- [ ] Actual item/equipment counts match spec totals
