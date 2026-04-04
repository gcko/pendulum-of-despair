# Gaps 1.4 + 1.5: Shop Data + Spell & Ability Data — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert shop inventories, spell data, and character ability data from design docs into ~34 runtime JSON files.

**Architecture:** Parallel agents transcribe files from economy.md (shops), magic.md (spells), and abilities.md (abilities). Cross-reference sweep validates all item_ids against gap 1.3 and character IDs against gap 1.1. Mandatory stale-count scan before commit (lesson from PR #109).

**Tech Stack:** JSON data files, no GDScript

**Spec:** `docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md`

---

## File Structure

| Action | File | Gap |
|--------|------|-----|
| Create | `game/data/shops/*.json` (23 shop files) | 1.4 |
| Create | `game/data/spells/ley_line.json` | 1.5 |
| Create | `game/data/spells/forgewright.json` | 1.5 |
| Create | `game/data/spells/spirit.json` | 1.5 |
| Create | `game/data/spells/void.json` | 1.5 |
| Create | `game/data/abilities/edren.json` | 1.5 |
| Create | `game/data/abilities/cael.json` | 1.5 |
| Create | `game/data/abilities/maren.json` | 1.5 |
| Create | `game/data/abilities/sable.json` | 1.5 |
| Create | `game/data/abilities/lira.json` | 1.5 |
| Create | `game/data/abilities/torren.json` | 1.5 |
| Create | `game/data/abilities/combos.json` | 1.5 |
| Modify | `docs/analysis/game-dev-gaps.md` | Both |

---

## Chunk 1: Shop Data (Gap 1.4)

### Task 1: Transcribe all 23 shop files

**Files:**
- Create: 23 files in `game/data/shops/`
- Read: `docs/story/economy.md` (full file — shop inventory sections)
- Read: `docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md`

**Agent instructions:** Read economy.md and create ALL 23 shop JSON files. Each file follows this schema:

```json
{
  "shop": {
    "shop_id": "town_type",
    "town": "town_name",
    "type": "shop_type",
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

RULES:
- `shop_id` = filename without .json extension (e.g., "valdris_crown_general")
- `town` = snake_case town name
- `type` = one of: general, armorer, specialty, provisioner, craftsman, black_market, company_store, company_armorer, quartermaster, scavenger, mixed
- `markup` = 1.0 for all shops EXCEPT Caldera Company Store (1.5) and Caldera Company Armorer (1.5). Caldera Black Market = 1.0.
- `buy_price` = price from economy.md. For Caldera Company shops: multiply standard price × 1.5 and round down (floor). For all others: use economy.md price directly.
- `available_act` = act when item first appears (1, 2, or 3). Read from economy.md availability columns/notes.
- `stock_limit` = null for unlimited. Integer for limited stock items (e.g., Pallor Salve: 3 at Bellhaven, 2 at Ironmark).
- `restock_event` = event flag string for items that appear after specific events. null for always-available items.
- `item_id` = MUST match an ID from gap 1.3 files (consumables.json, materials.json, weapons.json, armor.json, accessories.json)

SHOP LIST (23 files):
1. aelhart_general, 2. highcairn_provisioner, 3. valdris_crown_general, 4. valdris_crown_armorer, 5. valdris_crown_specialty, 6. corrund_general, 7. corrund_armorer, 8. corrund_black_market, 9. caldera_company_store, 10. caldera_company_armorer, 11. caldera_black_market, 12. ashmark_general, 13. ashmark_armorer, 14. bellhaven_general, 15. bellhaven_armorer, 16. bellhaven_specialty, 17. thornmere_provisioner, 18. thornmere_craftsman, 19. ironmark_quartermaster, 20. ironmark_scavenger, 21. oasis_a, 22. oasis_b, 23. oasis_c

- [ ] **Step 1:** Read economy.md shop sections and spec
- [ ] **Step 2:** Create all 23 shop JSON files in `game/data/shops/`
- [ ] **Step 3:** Self-verify: exactly 23 files, all shop_ids unique, Caldera markup correct, all item_ids are snake_case

---

## Chunk 2: Spell Data (Gap 1.5)

### Task 2: Transcribe spell tradition files

**Files:**
- Create: `game/data/spells/ley_line.json`, `forgewright.json`, `spirit.json`, `void.json`
- Read: `docs/story/magic.md` (full file — all spell tables)
- Read: `docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md`

**Agent instructions:** Read magic.md and create ALL 5 spell files (4 traditions + streetwise). Each spell has these fields:

```json
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
  "description": "A focused lance of flame.",
  "learned_by": [{"character": "maren", "level": 1}],
  "cross_trained": false,
  "mp_penalty": null
}
```

RULES:
- Every spell MUST have ALL 14 fields. Use null for inapplicable.
- `id` = snake_case of spell name, unique across ALL 5 files
- `tradition` = ley_line, forgewright, spirit, void, or streetwise
- `element` = flame, frost, storm, earth, ley, spirit, void, non_elemental, or null
- `category` = offensive, healing, status, buff, debuff, utility, special
- `tier` = 1-4
- `power` = from magic.md Effect column. null for non-damage spells.
- `mp_cost` = from magic.md. null for enemy-only void spells.
- `target` = single_enemy, all_enemies, single_ally, all_allies, self, fainted_ally
- `hit_rate` = base % for status spells. null for guaranteed.
- `duration` = turns for buffs/debuffs. null for instant.
- `learned_by` = array of {character, level} or {character, event} objects
- `cross_trained` = false at spell level (always). Cross-training is per-learner: add `cross_trained: true` and `mp_penalty: 1.5` to the learned_by entry for cross-trained characters.
- `mp_penalty` = null at spell level (always). See cross_trained above.
- Cael's party spells go in ley_line.json (he learns Ley Line tradition spells)
- Ley Crystal invocations from items.md are NOT spells — they're item effects (gap 1.7)

FILE ASSIGNMENTS:
- ley_line.json: Maren's base spells + Edren's limited Ley spells + Cael's Ley spells
- forgewright.json: Lira's spells
- spirit.json: Torren's spells
- void.json: Enemy-only void spells + post-game party void spells (Hollow Mend, Pendulum's Echo)

- [ ] **Step 1:** Read magic.md spell tables and spec
- [ ] **Step 2:** Create all 5 spell JSON files
- [ ] **Step 3:** Self-verify: all spell IDs unique across files, all 14 fields present, power/mp_cost match magic.md, learned_by character IDs valid

---

## Chunk 3: Ability Data (Gap 1.5)

### Task 3: Transcribe character ability files

**Files:**
- Create: `game/data/abilities/{edren,cael,maren,sable,lira,torren}.json`
- Read: `docs/story/abilities.md` (full file — all ability tables)
- Read: `docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md`

**Agent instructions:** Read abilities.md and create ALL 6 character ability files. Each ability has these fields:

```json
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
```

RULES:
- Every ability MUST have ALL 14 fields. Use null for inapplicable.
- `id` = snake_case of ability name, unique across ALL 6 files
- `character` = edren, cael, maren, sable, lira, torren
- `command` = bulwark, rally, arcanum, tricks, forgewright, spiritcall
- `cost_type` = ap, mp, wg, ac, mp_cd, none
- `cost_value` = numeric cost (0 for free)
- `cooldown` = turns between uses. null if no cooldown.
- `row_restriction` = "front" for Sable's Filch, Ransack, Wild Card steal component. null for others.
- `story_gated` = true for trial abilities (trial_edren_complete, etc.) and story-event abilities
- `story_event` = event flag string. null for level-learned.
- `effect` = FULL effect description from abilities.md (this is descriptive data — runtime deferred)

CHARACTER ABILITY COUNTS:
- Edren (Bulwark): 7 abilities
- Cael (Rally): 5 abilities
- Maren (Arcanum): 7 abilities (including Ley Surge which costs WG not MP)
- Sable (Tricks): 7 abilities (including passive Unbreakable Thread)
- Lira (Forgewright): 10 abilities (including Salvage, Calibrate, Cael's Edge)
- Torren (Spiritcall): 8 abilities (including Convergence Chorus, Rootsong, Purify)

- [ ] **Step 1:** Read abilities.md and spec
- [ ] **Step 2:** Create all 6 character ability JSON files
- [ ] **Step 3:** Self-verify: all ability IDs unique, all 14 fields present, costs match abilities.md, row_restriction on correct Sable abilities

### Task 4: Transcribe combo file

**Files:**
- Create: `game/data/abilities/combos.json`
- Read: `docs/story/abilities.md` (combo section)

**Agent instructions:** Create the 12 dual-tech combos from abilities.md.

```json
{
  "combos": [
    {
      "id": "shield_oath",
      "name": "Shield Oath",
      "characters": ["edren", "cael"],
      "cost": "Edren: 3 AP, Cael: 10 MP",
      "effect": "Synergized buffs: Edren DEF/MDEF +25%, Cael ATK/SPD +25%, both 4 turns.",
      "availability": "Acts I-II only (lost after Cael's betrayal)",
      "description": "A coordinated defensive-offensive stance."
    }
  ]
}
```

- [ ] **Step 1:** Read abilities.md combo section
- [ ] **Step 2:** Create `game/data/abilities/combos.json` with all 12 combos
- [ ] **Step 3:** Self-verify: exactly 12 combos, all IDs unique, character IDs valid

---

## Chunk 4: Verification & Completion

### Task 5: Cross-reference shop item_ids against gap 1.3

- [ ] **Step 1:** Extract all item_ids from all 23 shop files
- [ ] **Step 2:** Check each against consumables.json, materials.json, key_items.json, weapons.json, armor.json, accessories.json
- [ ] **Step 3:** Report any item_id not found — these are gaps
- [ ] **Step 4:** Fix any missing references

### Task 6: Cross-reference spell learned_by and ability character IDs

- [ ] **Step 1:** Extract all character IDs from spell learned_by arrays and ability character fields
- [ ] **Step 2:** Verify all are valid: edren, cael, maren, sable, lira, torren
- [ ] **Step 3:** Verify all spell IDs unique across 5 spell files
- [ ] **Step 4:** Verify all ability IDs unique across 7 ability files (6 characters + combos)

### Task 7: HARD GATE — Programmatic stale-count scan

- [ ] **Step 1:** Count actual files and entries:
  - Shop files count
  - Spells per tradition file
  - Abilities per character file
  - Combo count
- [ ] **Step 2:** Scan spec for every numeric count claim — verify matches actual
- [ ] **Step 3:** Scan plan for every count — verify matches actual
- [ ] **Step 4:** If ANY stale count found: fix ALL instances before proceeding
- [ ] **Step 5:** Re-scan to confirm zero stale counts

### Task 8: Update gap tracker and commit

- [ ] **Step 1:** Update gap 1.4 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Update gap 1.5 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 3:** Check off all completed items in both "What's Needed" lists
- [ ] **Step 4:** Note which downstream gaps are now unblocked:
  - 1.4 unblocks: town implementations
  - 1.5 unblocks: 3.3 (Battle Scene), magic/ability menus
- [ ] **Step 5:** Stage and commit all files

```bash
git add game/data/shops/ game/data/spells/ game/data/abilities/ docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-04-shops-spells-abilities-design.md docs/superpowers/plans/2026-04-04-shops-spells-abilities.md
git commit -m "feat(engine): add shop, spell, and ability data JSON files (gaps 1.4 + 1.5)"
```

- [ ] **Step 6:** Push and hand off to `/create-pr` → `/godot-review-loop`
