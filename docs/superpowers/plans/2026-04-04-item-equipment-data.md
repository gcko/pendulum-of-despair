# Gap 1.3: Item & Equipment Data JSON — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert all item and equipment data from design docs into 6 runtime JSON files in `game/data/items/` and `game/data/equipment/`.

**Architecture:** 6 parallel agents transcribe one JSON file each from items.md or equipment.md. A verification pass audits every value against source docs and cross-references enemy steal/drop IDs from gap 1.2. Gap tracker updated on completion.

**Tech Stack:** JSON data files, no GDScript

**Spec:** `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

---

## File Structure

| Action | File |
|--------|------|
| Create | `game/data/items/consumables.json` (33 items) |
| Create | `game/data/items/materials.json` (87 materials) |
| Create | `game/data/items/key_items.json` (26 key items) |
| Create | `game/data/equipment/weapons.json` (58 weapons) |
| Create | `game/data/equipment/armor.json` (49 armor) |
| Create | `game/data/equipment/accessories.json` (47 accessories) |
| Modify | `docs/analysis/game-dev-gaps.md` (update gap 1.3 status) |

---

## Chunk 1: Parallel Transcription (6 agents)

### Task 1: Transcribe Consumables

**Files:**
- Create: `game/data/items/consumables.json`
- Read: `docs/story/items.md` (lines 69–166 for consumable tables)
- Read: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

**Agent instructions:** Create all 33 consumable items from items.md.

For each item:
1. `id`: snake_case of name (e.g., "Hi-Potion" → `hi_potion`, "Alarm Clock" → `alarm_clock`)
2. `name`: exact name from items.md
3. `category`: always `"consumable"`
4. `subcategory`: one of `hp_healing`, `mp_restoration`, `revival`, `status_cure`, `battle_utility`, `stat_capsule`
5. `effect`: effect type string (`restore_hp`, `restore_mp`, `restore_hp_mp`, `revive`, `cure_status`, `flee`, `teleport`, `preemptive`, `stat_boost`)
6. `value`: numeric effect value from items.md (e.g., 100 for Potion). null for percentage-based items
7. `buy_price`: from items.md Buy column. `null` for items with "—"
8. `sell_price`: from items.md Sell column. `null` for items with "—". Verify: `floor(buy_price / 2)` when buy_price exists
9. `stack_limit`: 199 for hp_healing and mp_restoration subcategories, EXCEPT rest items (Sleeping Bag, Tent, Pavilion) which are 99. All others: 99
10. `description`: brief in-game text based on effect
11. `target`: `single_ally` for single-target heals/cures/revives, `all_allies` for party-wide, `single_enemy` for none (consumables don't target enemies), `self` for stat capsules
12. `usable_in_battle`: true for most. false for rest items (Sleeping Bag, Tent, Pavilion), Waystone, stat capsules
13. `usable_in_field`: true for healing, cures, rest items, stat capsules, Waystone. false for Smoke Bomb, Sable's Coin
14. `availability`: from items.md Availability column

**Conditional fields:**
- Status cures: add `"cures": [...]` array per the mapping in the spec
- Rest items: add `"requires_save_point": true`
- Percentage items (X-Potion, X-Ether, Sleeping Bag, Tent, Pavilion, Elixir, Megalixir): add `"restore_percent": N`
- Stat capsules: add `"stat": "atk"` etc.

**Item count by subcategory:**
- hp_healing: 9 (Potion, Hi-Potion, X-Potion, Ley Tonic, Elixir, Megalixir, Sleeping Bag, Tent, Pavilion)
- mp_restoration: 3 (Ether, Hi-Ether, X-Ether)
- revival: 2 (Phoenix Feather, Phoenix Pinion)
- status_cure: 10 (Antidote, Alarm Clock, Echo Drop, Eye Drops, Smelling Salts, Soft Stone, Chronos Dust, Remedy, Pallor Salve, Hope Shard)
- battle_utility: 3 (Smoke Bomb, Waystone, Sable's Coin)
- stat_capsule: 6 (Strength, Guardian, Arcane, Warding, Swiftness, Fortune)

- [ ] **Step 1:** Read items.md consumable sections and spec
- [ ] **Step 2:** Create `game/data/items/consumables.json` with all 33 items
- [ ] **Step 3:** Self-verify: count (must be 33), all IDs unique, all prices match items.md, all sell_price = floor(buy/2)

---

### Task 2: Transcribe Materials

**Files:**
- Create: `game/data/items/materials.json`
- Read: `docs/story/items.md` (lines 298–460 for Complete Material List)
- Read: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

**Agent instructions:** Create all 72 materials from items.md Complete Material List table.

For each material:
1. `id`: snake_case of name
2. `name`: exact name from items.md
3. `category`: always `"material"`
4. `tier`: 1, 2, 3, or 4 from the Tier column in items.md
5. `source_category`: from items.md section headers: `beast`, `construct`, `spirit_elemental`, `pallor`, `undead`, `arcanite`, `humanoid`, `dreamers_fault`, `boss_specific`
6. `sell_price`: exact value from items.md Sell Price column. null for unsellable
7. `sellable`: false ONLY for Pallor Core and Grey Mist Essence. true for all others
8. `stack_limit`: always 99
9. `description`: brief text based on items.md "Primary Crafting Use" column
10. `crafting_use`: exact text from items.md "Primary Crafting Use" column

**Drake Fang special case:** Add additional fields:
```json
"battle_usable": true,
"battle_effect": "fixed_damage",
"battle_value": 500,
"battle_target": "single_enemy"
```

**Material categories (from items.md section headers):**
- Beast Parts: 20
- Construct Salvage: 7
- Spirit/Elemental: 6
- Pallor: 5
- Undead: 2
- Arcanite: 4
- Humanoid/Flavor Drops: 14
- Dreamer's Fault Materials: 8
- Boss-Specific Materials: 6

- [ ] **Step 1:** Read items.md material sections and spec
- [ ] **Step 2:** Create `game/data/items/materials.json` with all 72 materials
- [ ] **Step 3:** Self-verify: count (must be 72), all IDs unique, all sell prices match items.md, Drake Fang has battle fields

---

### Task 3: Transcribe Key Items

**Files:**
- Create: `game/data/items/key_items.json`
- Read: `docs/story/items.md` (lines 462–530 for key items)
- Read: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

**Agent instructions:** Create all 26 key items from items.md.

For each key item:
1. `id`: snake_case of name
2. `name`: exact name from items.md
3. `category`: always `"key_item"`
4. `subcategory`: `dungeon_access`, `boss_memento`, `crafting_schematic`, or `story_item`
5. `description`: flavor text or functional description from items.md
6. `auto_use`: true for dungeon_access items, false for all others
7. `acquired_from`: source from items.md "Acquired From" column

**Subcategory-specific fields:**
- dungeon_access: `"trigger"` (activation condition), `"quest_link"` (area unlocked)
- boss_memento: `"dropped_by"` (boss enemy ID from gap 1.2), `"flavor_text"` (narrative description from items.md)
- crafting_schematic: `"recipe_unlocked"` (what recipe it unlocks)
- story_item: `"plot_effect"` (from items.md "Plot Effect" column)

**Counts:**
- dungeon_access: 9 (Mine Water Vial, Archivist's Codex, Ironmark Tunnel Map, Ironmark Key, Forgewright Master Key, Map to the Convergence, Catacomb Map, Broodchamber Map, Keeper's Index)
- boss_memento: 8 (Vein Guardian's Core, Fenmother's Tear, Operator's Badge, Cael's Pendant, Cael's Sword, Vaelith's Quill, Lost Page, Grey Echo Shard)
- crafting_schematic: 2 (Boring Engine Schematic, Forge Schematic)
- story_item: 7 (Fenmother's Blessing, Compact Battle Standard, Pallor-Laced Iron, Corrupted Tuning Fork, Caldera Employee Card, Valdris Crest, First Tree Seed)

- [ ] **Step 1:** Read items.md key item sections and spec
- [ ] **Step 2:** Create `game/data/items/key_items.json` with all 26 key items
- [ ] **Step 3:** Self-verify: count (must be 26), all IDs unique, subcategory distribution matches (9+8+2+7=26)

---

### Task 4: Transcribe Weapons

**Files:**
- Create: `game/data/equipment/weapons.json`
- Read: `docs/story/equipment.md` (lines 161–322 for all weapon tables)
- Read: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`
- Read: `docs/story/characters.md` (for equippable_by verification)

**Agent instructions:** Create all 58 weapons from equipment.md weapon tables.

For each weapon:
1. `id`: snake_case of name (e.g., "Training Sword" → `training_sword`, "Ley-Forged Longsword" → `ley_forged_longsword`)
2. `name`: exact name from equipment.md
3. `type`: `sword`, `greatsword`, `staff`, `dagger`, `hammer`, `spear`
4. `tier`: 0-5, `"forged"`, or `"cursed"` (Grey Cleaver tainted only)
5. `equippable_by`: single-element array per weapon type: sword→`["edren"]`, greatsword→`["cael"]`, staff→`["maren"]`, dagger→`["sable"]`, hammer→`["lira"]`, spear→`["torren"]`
6. `atk`: from equipment.md ATK column (already includes type modifier)
7. `bonus_stats`: object from Bonus column. Parse "SPD —2" → `{"spd": -2}`, "+3 MAG" → `{"mag": 3}`, "+2 SPD, +3 LCK" → `{"spd": 2, "lck": 3}`. Empty `{}` when "—"
8. `element`: from equipment.md Element column. lowercase or null for "—"
9. `special`: from equipment.md Special column. null for "—"
10. `buy_price`: from Price column. null for "—", "— (Forged)", or unpurchasable
11. `sell_price`: `floor(buy_price / 2)` when buy_price exists, null otherwise
12. `acquired`: from equipment.md Acquired column
13. `description`: brief in-game description based on weapon name and type

**Special cases:**
- Grey Cleaver (tainted): `"tier": "cursed"`, `"bonus_stats": {"def": -10, "mdef": -10, "spd": -10}`, `"special": "Despair at battle start. Cursed weapon — purify through 100 Pallor encounters."`
- Grey Cleaver (purified): separate entry, `"id": "grey_cleaver_purified"`, `"tier": 5`, `"element": "spirit"`, `"special": "+50% vs Pallor, Despair immunity"`
- Forged weapons (Arcanite Blade, Resonance Rod, Shadowsteel Knife, Forgewright Maul, Thornspear): `"tier": "forged"`
- Cael's Edge: in Hammers section, `"equippable_by": ["lira"]`, `"element": "spirit"`

**Weapon counts by type:**
- Swords (Edren): 10
- Greatswords (Cael): 6
- Staves (Maren): 10
- Daggers (Sable): 10
- Hammers (Lira): 11
- Spears (Torren): 11 (includes both Grey Cleaver entries)

- [ ] **Step 1:** Read equipment.md weapon tables and spec
- [ ] **Step 2:** Create `game/data/equipment/weapons.json` with all 58 weapons
- [ ] **Step 3:** Self-verify: count (must be 58), all IDs unique, all prices match, all sell = floor(buy/2), all bonus_stats parsed correctly

---

### Task 5: Transcribe Armor

**Files:**
- Create: `game/data/equipment/armor.json`
- Read: `docs/story/equipment.md` (lines 325–436 for head armor, light armor, elemental, heavy, robes)
- Read: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

**Agent instructions:** Create all 49 armor pieces from equipment.md.

For each armor piece:
1. `id`: snake_case of name
2. `name`: exact name from equipment.md
3. `slot`: `"head"` or `"body"`
4. `armor_class`: null for head armor. `"light"` for light armor AND elemental body armor. `"heavy"` for heavy armor. `"robe"` for robes.
5. `tier`: 0-5 or `"forged"`
6. `equippable_by`:
   - Head: `["edren", "cael", "maren", "sable", "lira", "torren"]`
   - Light/elemental body: `["edren", "cael", "maren", "sable", "lira", "torren"]`
   - Heavy body: `["edren", "lira"]`
   - Robes: `["maren", "torren"]`
7. `def`: from DEF column
8. `mdef`: from MDEF column
9. `bonus_stats`: from Special column when stat bonuses present. e.g., "+5 MAG" → `{"mag": 5}`, "+10 all stats" → `{"atk": 10, "def": 10, "mag": 10, "mdef": 10, "spd": 10, "lck": 10}`. Empty `{}` for non-stat specials
10. `special`: special effect text. null when "—". Note: stat bonuses like "+5 MAG" go in BOTH bonus_stats AND special (special has the human-readable text, bonus_stats has the machine-readable values)
11. `buy_price`: from Price column. null for "—", "— (Forged)", or unpurchasable
12. `sell_price`: `floor(buy_price / 2)` or null
13. `acquired`: from Acquired column
14. `description`: brief in-game description

**Armor counts by category:**
- Head: 20 (2 starting Tier 0, 3 Tier 1, 4 Tier 2, 4 Tier 3 incl. 1 Forged, 4 Tier 4, 3 Tier 5)
- Light body: 12
- Elemental body: 4 (Flameguard Mail, Frostweave Vest, Stormhide Coat, Earthen Plate — all use armor_class "light")
- Heavy body: 8
- Robes: 5

- [ ] **Step 1:** Read equipment.md armor tables and spec
- [ ] **Step 2:** Create `game/data/equipment/armor.json` with all 49 armor
- [ ] **Step 3:** Self-verify: count (must be 49), all IDs unique, equippable_by correct per armor class, all prices match

---

### Task 6: Transcribe Accessories

**Files:**
- Create: `game/data/equipment/accessories.json`
- Read: `docs/story/equipment.md` (lines 439–555 for all accessory tables)
- Read: `docs/superpowers/specs/2026-04-04-item-equipment-data-design.md`

**Agent instructions:** Create all 42 accessories from equipment.md.

For each accessory:
1. `id`: snake_case of name
2. `name`: exact name from equipment.md
3. `subcategory`: `stat_boost`, `status_immunity`, `elemental_resistance`, `combat_mechanic`, `boss_drop`
4. `equippable_by`: `["edren", "cael", "maren", "sable", "lira", "torren"]` for most. Exceptions:
   - Cael's Knight Crest: `["edren"]`
   - Unfinished Ring: `["lira"]`
5. `effect`: human-readable effect text from equipment.md
6. `bonus_stats`: stat modifications as object. e.g., `{"atk": 5}` for Power Ring, `{"hp": 300}` for Life Pendant. Empty `{}` for effect-only accessories
7. `special`: passive combat effect text for combat mechanic / boss drop accessories. null for simple stat/immunity items
8. `buy_price`: from Price column. null for boss drops, quest rewards
9. `sell_price`: `floor(buy_price / 2)` or null
10. `acquired`: from Acquired/Source column
11. `description`: brief in-game description

**Conditional fields:**
- status_immunity: add `"status_immunity": "poison"` (the specific status)
- elemental_resistance: add `"element_resist": "flame"` (the specific element)
- boss_drop: add `"source": "ley_colossus"` (boss enemy ID)

**Accessory counts by subcategory:**
- stat_boost: 8
- status_immunity: 6
- elemental_resistance: 4
- combat_mechanic: 9
- boss_drop: 15

- [ ] **Step 1:** Read equipment.md accessory tables and spec
- [ ] **Step 2:** Create `game/data/equipment/accessories.json` with all 42 accessories
- [ ] **Step 3:** Self-verify: count (must be 42), all IDs unique, equippable_by exceptions correct, all prices match

---

## Chunk 2: Verification & Completion

### Task 7: Cross-reference enemy steal/drop IDs

**Files:**
- Read: All 6 new JSON files
- Read: All 6 enemy JSON files from gap 1.2

**Instructions:** Verify that every `item_id` referenced in enemy steal and drop fields (from gap 1.2 enemy data) exists in the item/material/equipment JSON files created in Tasks 1-6.

- [ ] **Step 1:** Extract all unique item_ids from enemy steal.common, steal.rare, and drop across all 6 enemy files
- [ ] **Step 2:** Check each item_id against consumables.json, materials.json, key_items.json, weapons.json, armor.json, accessories.json
- [ ] **Step 3:** Report any item_id that doesn't exist in any file — these are gaps
- [ ] **Step 4:** Fix any missing items or incorrect IDs

---

### Task 8: Programmatic validation sweep

- [ ] **Step 1:** Verify item counts: consumables=33, materials=72, key_items=26, weapons=58, armor=49, accessories=42
- [ ] **Step 2:** Verify all IDs unique within item files (consumables + materials + key_items)
- [ ] **Step 3:** Verify all IDs unique within equipment files (weapons + armor + accessories)
- [ ] **Step 4:** Verify every entry has ALL required schema fields (no missing fields)
- [ ] **Step 5:** Verify all sell_price values follow the correct formula
- [ ] **Step 6:** Verify all equippable_by arrays match the spec rules
- [ ] **Step 7:** Fix any errors found

---

### Task 9: Update gap tracker and commit

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1:** Update gap 1.3 status to COMPLETE
- [ ] **Step 2:** Check off all completed items in the "What's Needed" list
- [ ] **Step 3:** Note which downstream gaps are now unblocked (1.4 Shops, 1.7 Crafting, 2.4 Interactables)
- [ ] **Step 4:** Stage and commit all files

```bash
git add game/data/items/ game/data/equipment/ docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-04-item-equipment-data-design.md docs/superpowers/plans/2026-04-04-item-equipment-data.md
git commit -m "feat(engine): add item and equipment data JSON files (gap 1.3)"
```

- [ ] **Step 5:** Push and hand off to `/create-pr` → `/godot-review-loop`
