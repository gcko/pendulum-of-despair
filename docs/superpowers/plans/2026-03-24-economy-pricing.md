# Economy & Pricing Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/economy.md` with the complete economic system (shop inventories, gold pacing, treasure chests, boss gold, inn costs, crafting costs, steal economy, quest rewards) and update all cross-referenced docs.

**Architecture:** Single new markdown file (`economy.md`) as canonical economy reference. Updates to 8 existing files for consistency: items.md (rest item rename), bosses.md (gold values per formula), dungeons-world.md + dungeons-city.md + city-carradan.md (Scrip→gold, chest gold amounts), sidequests.md (gold rewards), locations.md (economy.md references), gap analysis (status update).

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-24-economy-pricing-design.md`

---

## Chunk 1: Core Economy File + Rest Item Updates

### Task 1: Create economy.md Skeleton

**Files:**
- Create: `docs/story/economy.md`

**Context:** Create the file structure, header, table of contents, and core philosophy sections. All remaining sections start as placeholders.

- [ ] **Step 1: Write the header and table of contents**

Create `docs/story/economy.md` with:
1. Title: `# Economy & Pricing — Pendulum of Despair`
2. Blockquote: canonical reference for all economic data. Cross-references items.md (consumable prices), equipment.md (weapon/armor/accessory prices, forging costs), bestiary files (enemy gold drops), sidequests.md (quest rewards).
3. Table of contents linking to all sections:
   - Economic Philosophy
   - Currency & Pricing Rules
   - Inn Costs
   - Rest Item Progression
   - Shop Inventories (with sub-sections per town)
   - Event-Triggered Restocking
   - Treasure Chest Gold Formula
   - Boss Gold Drop System
   - Sable's Steal Economy
   - Crafting Economy
   - Quest Reward Guidelines
   - Gold Pacing Targets
   - Wealth Curve & Verification
   - Cross-References (which docs own which data)

- [ ] **Step 2: Write Economic Philosophy section**

From spec Section 1 (first half — philosophy and targets). Include:
- **Affordability target: 70%** — player can afford ~70% of gear at each town through normal play
- **"Means" economy** — splits difference between FF4's tight (60%) and FF6's comfortable (80%)
- **Three gold sinks:** equipment (primary), consumables (ongoing), inns (flavor)
- **Three gold sources:** enemy drops (primary), treasure chests (exploration), boss encounters (paydays)
- **Crafting material tension:** sell for gold now OR save for Forgewright/Arcanite Forging later

- [ ] **Step 3: Write Currency & Pricing Rules section**

From spec Section 1 (second half — rules and exclusions). Include:
- **Gold** is the universal currency
- **Scrip** is a regional name used in Carradan Compact territory — mechanically identical to Gold. No conversion, no separate wallet.
- **Sell price rule:** all items sell at 50% of buy price. Exception: Sea Prince's Signet raises to 57.5%.
- **Crafting material tension:** sell for gold now OR save for Forgewright/Arcanite Forging later. Selling ALL materials through Act II gains ~3,000–5,000g extra.
- **No vendor trash:** crafting materials serve double duty (sell or save). No items exist solely for selling.
- **No special financial services:** no money lender, bank, or interest. Complexity comes from sell-or-save decisions and Caldera inflation.

- [ ] **Step 4: Write Inn Costs section**

From spec Section 2. Create table:

| Town | Act | Inn Cost | Flavor |
|------|-----|----------|--------|
| Aelhart | I | Free | Home village |
| Highcairn | I | 50g | Monastery hospitality |
| Valdris Crown | I–II | 150g | Capital city |
| Corrund | II | 100g | Canal district |
| Caldera | II | 300g (450g company rate) | Inflated |
| Ashmark | II | 100g | Harbor district |
| Bellhaven | II | 150g | Coastal trade city |
| Thornmere | II | 100g | Isolated but welcoming |
| Ironmark | Interlude | 75g | War-torn |
| Act III Oases | III | 50–100g | Refugee camps |

- [ ] **Step 5: Write Rest Item Progression section**

From spec Section 3. Create table:

| Item | Buy | Sell | Effect | Available |
|------|-----|------|--------|-----------|
| Sleeping Bag | 250g | 125g | 25% HP/MP to all (save point) | Act I |
| Tent | 500g | 250g | 50% HP/MP to all (save point) | Act I |
| Pavilion | 1,200g | 600g | 100% HP/MP to all (save point) | Act II |

Stack limit: 99. Design note: inns are cheaper per-rest but town-only; rest items are the dungeon alternative.

- [ ] **Step 6: Write Caldera Inflation section**

From spec Section 2. Include:
- **Markup: 150%** on all Caldera shops
- **Caldera Employee Card:** key item, 25% discount (net 112.5% of standard)
- **Acquisition:** Sable pickpockets from Compact officer in Caldera
- **Tash's Black Market:** uses standard prices (underground ignores inflation)
- **All other towns:** standard pricing, no modifiers

- [ ] **Step 7: Add placeholder sections**

Add empty `## Section Name` headings for all remaining sections (Shop Inventories through Verification). Each placeholder should have a one-line note: `> To be filled in Task N.`

- [ ] **Step 8: Commit**

```bash
git add docs/story/economy.md
```
Message: `docs(shared): create economy.md skeleton with core philosophy and inn costs`

---

### Task 2: Update items.md — Rest Item Changes

**Files:**
- Modify: `docs/story/items.md`

**Context:** Rename Cottage→Pavilion, add Sleeping Bag, update the consumable summary. The rest item section is in the HP Healing table (lines ~71–85). Cottage is on line ~84.

- [ ] **Step 1: Read the HP Healing section**

Read `docs/story/items.md` lines 71–90 to see the exact current table format for Tent and Cottage rows.

- [ ] **Step 2: Add Sleeping Bag row**

Insert a new row BEFORE the Tent row:

`| Sleeping Bag | Restore 25% HP/MP to all party (save point only) | 250 | 125 | Act I shops |`

- [ ] **Step 3: Rename Cottage to Pavilion**

Change the Cottage row from:
`| Cottage | Restore 100% HP/MP to all party (save point only) | 1,200 | 600 | Interlude shops |`

To:
`| Pavilion | Restore 100% HP/MP to all party (save point only) | 1,200 | 600 | Act II shops |`

Note: availability changes from "Interlude shops" to "Act II shops" per spec (Pavilion is available in Bellhaven and Caldera during Act II).

- [ ] **Step 4: Update HP Healing count**

In the Consumable Summary table (line ~154), update the HP Healing count from `8` to `9` (added Sleeping Bag). Update the total from `32` to `33`.

- [ ] **Step 5: Verify cross-references**

Search items.md for any other mentions of "Cottage" and update to "Pavilion". Check the Table of Contents and Inventory Structure section for references.

- [ ] **Step 6: Commit**

```bash
git add docs/story/items.md
```
Message: `docs(shared): add Sleeping Bag, rename Cottage to Pavilion in items.md`

---

## Chunk 2: Shop Inventories

### Task 3: Write Shop Inventories (Towns 1–5)

**Files:**
- Modify: `docs/story/economy.md`

**Context:** Fill in shop inventories for Aelhart, Highcairn, Valdris Crown, Corrund, and Caldera from spec Sections 4.1–4.5. Every item name must match items.md or equipment.md exactly.

- [ ] **Step 1: Write Aelhart shop inventory**

Copy from spec Section 4.1. General Store only (no armorer). Include restock trigger note: "After Ember Vein completion: +Hi-Potion, +Phoenix Feather, +Sleeping Bag, +Tent."

IMPORTANT: Verify each item name exists in items.md:
- Potion ✓ (items.md HP Healing)
- Antidote ✓ (items.md Status Cures)
- Eye Drops ✓ (items.md Status Cures)
- Smoke Bomb ✓ (items.md Battle Utility)

- [ ] **Step 2: Write Highcairn shop inventory**

Copy from spec Section 4.2. Provisioner only. Verify item names.

- [ ] **Step 3: Write Valdris Crown shop inventory**

Copy from spec Section 4.3. Three shops: General Store, Armorer, Specialty Shop.

IMPORTANT: Verify every weapon/armor name against equipment.md:
- Valdris Blade (300g) — equipment.md Swords table ✓
- Knight's Edge (500g) — equipment.md Swords table ✓
- Iron Helm (200g) — equipment.md Head Armor table ✓
- Chain Mail (300g) — equipment.md Light Armor table ✓
- Power Ring (300g) — equipment.md Accessories table ✓
(Check ALL items, not just these examples)

Include the Act II restock trigger note.

- [ ] **Step 4: Write Corrund shop inventory**

Copy from spec Section 4.4. Three shops: General Store, Armorer, Sable's Black Market (Undercroft).

Note: Sable's Black Market requires Sable in active party.

- [ ] **Step 5: Write Caldera shop inventory**

Copy from spec Section 4.5. Three tables with inflated prices:
- Company Store (General) — 3 columns: Standard, Caldera (×1.5), With Card (×1.125)
- Company Armorer — same 3-column format
- Tash's Black Market — standard prices (underground ignores inflation)

Verify Caldera math: each Caldera price = standard × 1.5. Each Card price = standard × 1.125 (round up to nearest integer).

- [ ] **Step 6: Commit**

```bash
git add docs/story/economy.md
```
Message: `docs(shared): add shop inventories for Aelhart through Caldera`

---

### Task 4: Write Shop Inventories (Towns 6–10) + Restocking

**Files:**
- Modify: `docs/story/economy.md`

**Context:** Fill in shop inventories for Ashmark, Bellhaven, Thornmere, Ironmark, and Act III Oases from spec Sections 4.6–4.10. Then add the Event-Triggered Restocking table from spec Section 5.

- [ ] **Step 1: Write Ashmark shop inventory**

Copy from spec Section 4.6. General Store + Armorer. Include liberation restock trigger.

- [ ] **Step 2: Write Bellhaven shop inventory**

Copy from spec Section 4.7. General Store + Armorer + Specialty (Harbor Traders).

Note Bellhaven's identity: best accessory selection in Act II.

IMPORTANT: Pallor Salve is listed as "limited 3 per visit" — this is the first shop availability.

- [ ] **Step 3: Write Thornmere shop inventory**

Copy from spec Section 4.8. Provisioner + Local Craftsman.

Note Thornmere's identity: only shop selling Despair Ward (5,000g).

- [ ] **Step 4: Write Ironmark shop inventory**

Copy from spec Section 4.9. Refugee Quartermaster + Scavenger Armorer.

Note: No accessories, no specialty items. Limited stock quantities. Phoenix Feather limited 5/visit, Pallor Salve limited 2/visit.

- [ ] **Step 5: Write Act III Oasis inventories**

Copy from spec Section 4.10. Three specific Oases:
- **Oasis A (Valdris Refugees):** Swords, spears, Genji gear
- **Oasis B (Compact Refugees):** Hammers, staves, Compact gear
- **Oasis C (Thornmere Refugees):** Daggers, Pallor-specific gear

Include Post-Convergence restock note: +Elixirs (5,000g first-time purchasable), +full consumable line.

- [ ] **Step 6: Write Event-Triggered Restocking table**

Copy from spec Section 5. Table with columns: Event, Shops Affected, Change. 8 trigger events from "Complete Ember Vein" through "Post-Convergence."

Include Interlude scarcity rule: most Act I–II shops close or reduce to basic consumables only.

- [ ] **Step 7: Commit**

```bash
git add docs/story/economy.md
```
Message: `docs(shared): add shop inventories for Ashmark through Oases, restocking triggers`

---

## Chunk 3: Gold Formulas + Boss Gold + Steal + Crafting

### Task 5: Treasure Chest Gold Formula + Boss Gold Drop System

**Files:**
- Modify: `docs/story/economy.md`

**Context:** Fill in the treasure chest formula (spec Section 6) and boss gold system (spec Section 7). Boss gold uses a 3-part formula: act tier base × boss rank multiplier = total payday, then narrative split determines direct gold vs. lair chests.

- [ ] **Step 1: Write Treasure Chest Gold Formula section**

From spec Section 6. Include:
- Act tier average equipment costs (Act I: ~400g, Act II: ~1,500g, Interlude: ~4,000g, Act III: ~8,000g)
- Placement multiplier table (main path 15%, side room 25%, hidden 40%, boss lair 50–75%)
- Computed gold amounts per act per placement (the full matrix)
- Per-dungeon budget: 2–4 gold chests, total = 30–40% of one equipment piece
- Design rules: no gold in first room, boss lair chests are narrative justification

- [ ] **Step 2: Write Boss Gold Drop System section**

From spec Section 7. Include:
- Three-part formula: `total_payday = act_tier_base × boss_rank`, `direct_gold = floor(total × narrative_split)`, `lair_chest_gold = total - direct`
- Act tier base table (Act I: 500g through Post-game: 6,000g)
- Boss rank multiplier table (Minor 1.0×, Standard 2.0×, Climactic 3.0×)
- Narrative split table (Humanoid 1.0, Construct 0.5, Beast 0.1, Spirit 0.1, Pallor 0.05 with 0.7× total)
- Narrative principle: gold source must match what the boss IS
- Worked examples table (8 bosses from Vein Guardian through Vaelith)

- [ ] **Step 3: Commit**

```bash
git add docs/story/economy.md
```
Message: `docs(shared): add treasure chest formula and boss gold drop system`

---

### Task 6: Steal Economy + Crafting Economy + Quest Rewards

**Files:**
- Modify: `docs/story/economy.md`

**Context:** Fill in Sable's steal economy (spec Section 8), crafting costs (spec Section 9), and quest rewards (spec Section 10).

- [ ] **Step 1: Write Sable's Steal Economy section**

From spec Section 8. Include:
- Steal value principle: ~2–3 battles of gold income per steal
- Steal tiers table by enemy type (Beast, Construct, Humanoid, Spirit, Pallor, Undead)
- Gold Pouch mechanic for humanoids (Act I: 150g through Act III: 800g)
- Boss steals note: every boss has a unique steal in bosses.md
- Fenn's Seal: +25% gold from battle sources (sidequest reward)
- Sea Prince's Signet: +15% sell price on all items (sidequest reward)

- [ ] **Step 2: Write Crafting Economy section**

From spec Section 9. Include:
- Forgewright battle devices: already priced in items.md (100–800g), reference only
- Arcanite Forging: defer to equipment.md as canonical (400–500g fees + materials)
- Elemental Infusions: defer to equipment.md (300–500g + materials)
- Secret Synergies: no extra cost, bonus is the discovery reward
- Economic impact analysis: forging fee is low but material opportunity cost is high
- Note about Cael having no forged greatsword (intentional — he departs during Interlude)

- [ ] **Step 3: Write Quest Reward Guidelines section**

From spec Section 10. Include:
- Quest reward tiers table (Minor 200–500g, Standard 500–1,500g, Major 2,000–5,000g, Epic 5,000–10,000g)
- Reward composition table (what % gold vs equipment vs materials vs consumables per tier)
- Design rule: best quest rewards are non-purchasable items
- NPC tip rewards: 50–100g for minor favors

- [ ] **Step 4: Commit**

```bash
git add docs/story/economy.md
```
Message: `docs(shared): add steal economy, crafting costs, and quest reward guidelines`

---

### Task 7: Gold Pacing Targets + Wealth Curve + Verification

**Files:**
- Modify: `docs/story/economy.md`

**Context:** Fill in the gold pacing tables (spec Section 11) and wealth curve with verification targets (spec Section 12). These are the balance sheets that prove the 70% affordability target holds.

- [ ] **Step 1: Write Gold Pacing Targets section**

From spec Section 11. Four subsections (Act I, Act II, Interlude, Act III) + Post-game note. Each has:
- Income table: enemy drops, treasure chests, boss gold, quest rewards → total income
- Sink table: equipment, consumables, inns → total needed
- Affordability calculation and analysis

- [ ] **Step 2: Write Wealth Curve table**

From spec Section 12. Single table with columns: Milestone, Cumulative Earned, In Wallet, Notes. 10 milestones from "After Ember Vein" through "Post-game."

- [ ] **Step 3: Write Verification Checks section**

From spec Section 12. Seven numbered checks:
1. 70% test per town
2. Consumable drain per dungeon
3. Caldera pinch point
4. Material sell-or-save impact
5. Sable steal value
6. Forging parity
7. Inn vs rest item cost comparison

Also add check #8: quest reward totals per act sum to the pacing table estimates (e.g., Act II quest income ~1,500g).

- [ ] **Step 4: Write Cross-References section**

From spec Section 13. Create a table mapping each document to its economic data ownership:

| Document | Owns | economy.md References |
|----------|------|----------------------|
| items.md | Consumable prices, material sell prices, Forgewright costs | Rest items, consumable sink estimates |
| equipment.md | Weapon/armor/accessory prices, forging fees, infusion costs | Equipment sink estimates, forging parity |
| bestiary/README.md | Enemy gold drop formula (logistic curve) | Gold income estimates |
| bestiary/bosses.md | Boss direct gold drops | Boss payday calculations |
| sidequests.md | Quest gold rewards | Quest income estimates |
| dungeons-world.md | Treasure chest contents + gold amounts | Chest income estimates |
| dungeons-city.md | Treasure chest contents + gold amounts | Chest income estimates |
| locations.md | Town shop references | Shop inventory details |

- [ ] **Step 5: Commit**

```bash
git add docs/story/economy.md
```
Message: `docs(shared): add gold pacing targets, wealth curve, verification, and cross-references`

---

## Chunk 4: Cross-Reference Updates

### Task 8: Scrip→Gold Rename + Treasure Chest Gold Assignment

**Files:**
- Modify: `docs/story/dungeons-city.md`
- Modify: `docs/story/dungeons-world.md`
- Modify: `docs/story/city-carradan.md`

**Context:** Two changes: (1) Replace all "scrip" with "gold" in Compact territory docs. (2) Assign gold amounts to any treasure chests that don't already have specific values, using the formula from economy.md Section 6.

- [ ] **Step 1: Grep ALL docs for Scrip references**

Use grep (case-insensitive) across the entire `docs/` directory to find every "scrip" reference. This is the PRIMARY discovery method — the line numbers below are sanity checks only.

```bash
grep -rni "scrip" docs/
```

Known locations in dungeons-city.md (~12 instances):
- `800 scrip`, `1200 scrip`, `3000 scrip`, `1500 scrip`, `500 scrip`, `200 scrip`, `600 scrip`, `5000 scrip`, `2000 scrip`, `3000 scrip`, `500 scrip`

Known locations in city-carradan.md (~5 instances):
- `2000 scrip`, `1500 scrip`, `1200 scrip`, `1000 scrip`, `300 scrip`

- [ ] **Step 2: Replace all Scrip→gold**

For each match found by grep:
1. Read the surrounding context (±5 lines)
2. Replace "scrip" with "gold"
3. Add comma formatting to 4+ digit numbers if missing (e.g., `1200` → `1,200`)

- [ ] **Step 3: Read dungeons-world.md treasure chests**

Search `docs/story/dungeons-world.md` for all treasure chest entries. Identify:
- Chests with existing gold amounts (verify they match the formula)
- Chests with only item/equipment rewards (no gold to add — these are fine)
- Any remaining "scrip" references

Also check for Scrip references in `docs/story/dungeons-world.md` (unlikely but verify).

- [ ] **Step 4: Assign gold amounts to dungeon chests**

For any gold chests that lack specific amounts, use the treasure chest formula from economy.md:

| Placement | Act I (15-75% of 400g) | Act II (15-75% of 1,500g) | Interlude (15-75% of 4,000g) | Act III (15-75% of 8,000g) |
|-----------|------------------------|---------------------------|------------------------------|----------------------------|
| Main path | 60g | 225g | 600g | 1,200g |
| Side room | 100g | 375g | 1,000g | 2,000g |
| Hidden | 160g | 600g | 1,600g | 3,200g |
| Boss lair | 200–300g | 750–1,125g | 2,000–3,000g | 4,000–6,000g |

For each dungeon, assess chest placement difficulty and assign the appropriate amount. Boss lair chests should match the lair_chest_gold from the boss gold formula (total_payday - direct_gold).

NOTE: Many chests in dungeon files already have specific items/equipment. These do NOT need gold amounts added — only chests that are described as containing gold/currency or that currently list scrip amounts.

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-city.md docs/story/dungeons-world.md docs/story/city-carradan.md
```
(Add any other files if Step 1 found additional references.)
Message: `docs(shared): rename Scrip to gold, assign chest gold amounts per formula`

---

### Task 9: Update Boss Gold Values in bosses.md

**Files:**
- Modify: `docs/story/bestiary/bosses.md`

**Context:** Boss stat blocks already have a Gold column (column 11). Current values need to be verified against the new boss rank formula from economy.md. Update any that don't match.

The formula: `total_payday = act_tier_base × boss_rank_multiplier`. Direct gold = `floor(total × narrative_split)`. The direct gold goes in the Gold column; lair chest gold is documented in dungeon files.

- [ ] **Step 1: Read the Quick Reference table**

Read `docs/story/bestiary/bosses.md` lines 10–43 to see all boss names, acts, and levels. Note which bosses exist.

- [ ] **Step 2: Classify every boss by rank and type**

For each of the 29 combat bosses, determine:
- **Act** (determines tier_base: I=500, II=1,500, Int=2,500, III=4,000, Post=6,000)
- **Rank** (Minor=1.0×, Standard=2.0×, Climactic=3.0×)
- **Type** (Humanoid=1.0, Construct=0.5, Beast=0.1, Spirit=0.1, Pallor — see below)

Compute direct_gold for each.

**Pallor bosses — two-step calculation:**
1. First reduce total payday: `total = tier_base × rank × 0.7`
2. Then apply narrative split: `direct_gold = floor(total × 0.05)`
Example: Crystal Queen (Act III, Standard, Pallor):
- total = 4,000 × 2.0 × 0.7 = 5,600g
- direct = floor(5,600 × 0.05) = 280g

**Other worked examples:**
- Vein Guardian (Act I, Minor, Beast): total = 500 × 1.0 = 500g, direct = 50g
- Corrupted Fenmother (Act I, Climactic, Beast): total = 500 × 3.0 = 1,500g, direct = 150g
- Commander Drayce (Act II, Standard, Humanoid): total = 1,500 × 2.0 = 3,000g, direct = 3,000g
- Kole (Interlude, Climactic, Humanoid): total = 2,500 × 3.0 = 7,500g, direct = 7,500g

Ranking guidelines:
- **Minor (1.0×):** Tutorial bosses, first encounter in an act, mini-bosses
- **Standard (2.0×):** Most dungeon-end bosses
- **Climactic (3.0×):** Act-ending bosses, narrative climaxes

- [ ] **Step 3: Read each boss's current Gold value and update**

For each boss, read the stat block, compare current Gold value to the computed direct_gold. Update if different.

IMPORTANT: Read the FULL stat row (all 19 columns) before editing to avoid corrupting the table. Use exact string matching for edits.

- [ ] **Step 4: Verify all 29 bosses are updated**

Re-read the Quick Reference table and spot-check 5 bosses across different acts to confirm Gold values match the formula.

- [ ] **Step 5: Commit**

```bash
git add docs/story/bestiary/bosses.md
```
Message: `docs(shared): update boss gold drops to match economy rank formula`

---

### Task 10: Update sidequests.md with Gold Rewards

**Files:**
- Modify: `docs/story/sidequests.md`

**Context:** No quest entries currently have gold reward amounts. Add gold rewards per the quest reward tier guidelines from economy.md (spec Section 10).

- [ ] **Step 1: Read sidequests.md Major Side Quests**

Read lines 7–250 to see all 10 major quests. For each, identify:
- Current reward line (if any)
- Quest complexity (to determine tier: Standard, Major, or Epic)
- Act availability

- [ ] **Step 2: Add gold rewards to Major Side Quests**

For each of the 10 major quests, add a gold reward amount in the reward section. Suggested mapping:

| Quest | Act | Tier | Suggested Gold |
|-------|-----|------|---------------|
| The Fading Shifts | II–III | Major | 2,500g |
| The Gloves She Wore | II | Standard | 1,000g |
| The Third Door | II–III | Major | 3,000g |
| The Spirit That Stopped Singing | II–III | Major | 2,500g |
| The Auditor's Conscience | II | Major | 2,000g |
| Seedgrain | III | Major | 3,500g |
| The Honest Thief | II | Standard | 1,500g |
| What the Stars Said | III | Major | 4,000g |
| The Commissar's Confession | II–III | Major | 3,000g |
| A Letter Never Sent | III | Epic | 5,000g |

Adjust amounts after reading each quest's difficulty and act placement. The above are starting estimates — verify against the quest's actual content.

Also add gold boost descriptions to Fenn's Seal and Sea Prince's Signet if not already specified:
- Fenn's Seal: "+25% gold from all battle sources"
- Sea Prince's Signet: "+15% sell price on all items"

- [ ] **Step 3: Read sidequests.md Minor Side Quests**

Read lines 253–430 to see all minor quests.

- [ ] **Step 4: Add gold rewards to Minor Side Quests**

For each minor quest, add a gold reward: 200–500g (Minor tier). These are fetch quests and small tasks.

- [ ] **Step 5: Add gold to Recurring Optional Content if applicable**

Read lines 518–594. If any recurring content has rewards, add gold amounts per the Minor/Standard tier.

- [ ] **Step 6: Commit**

```bash
git add docs/story/sidequests.md
```
Message: `docs(shared): add gold reward amounts to all side quests`

---

### Task 11: Update locations.md with Economy References

**Files:**
- Modify: `docs/story/locations.md`

**Context:** locations.md lists towns with shop/service mentions but no inventory details. Add a reference to economy.md for each town that has shops.

- [ ] **Step 1: Read locations.md shop references**

Read `docs/story/locations.md` and find all towns with shop mentions. Key locations:
- Aelhart (General Store, line ~567)
- Highcairn (Provisioner, line ~772)
- Valdris Crown (multiple shops, lines ~51, ~293, ~296, ~302)
- Bastion (Provisioner, line ~944)

Also check city-specific files for shop references:
- `docs/story/city-valdris.md`
- `docs/story/city-carradan.md` (Corrund, Caldera, Ashmark)
- `docs/story/city-thornmere.md` (Thornmere, Roothollow, etc.)

- [ ] **Step 2: Add economy.md cross-references**

For each town with shops, add a note: `> See [economy.md](economy.md) for complete shop inventory.`

Place the note after the shop mention, before the NPC details. Keep it minimal — one line per town, not a full inventory duplicate.

- [ ] **Step 3: Commit**

```bash
git add docs/story/locations.md
```
(Add city files if they also needed references.)
Message: `docs(shared): add economy.md references to location shop entries`

---

### Task 12: Cross-Reference Verification + Gap Update

**Files:**
- Modify: `docs/story/economy.md` (if fixes needed)
- Modify: `docs/analysis/game-design-gaps.md`

**Context:** Final verification pass. Cross-check economy.md against all source docs, then update the gap tracker.

- [ ] **Step 1: Verify item names in shop inventories**

For every item listed in economy.md shop inventories:
1. If it's a consumable, verify name exists in items.md
2. If it's equipment, verify name exists in equipment.md
3. If it's an accessory, verify name exists in equipment.md
4. Check that the price matches the source doc

Flag any mismatches.

- [ ] **Step 2: Verify Caldera math**

For every item in the Caldera shop tables:
1. Caldera price = standard price × 1.5
2. Card price = standard price × 1.125 (round up)
3. Verify all three columns are internally consistent

- [ ] **Step 3: Verify boss gold formula**

Spot-check 5 bosses:
1. Read the boss's Gold value in bosses.md
2. Compute expected value: tier_base × rank × narrative_split
3. Verify they match

- [ ] **Step 4: Verify quest reward totals match pacing tables**

Sum all quest gold rewards assigned in Task 10 by act. Compare to the pacing table estimates in economy.md:
- Act I quest income target: ~0g (no quests available yet)
- Act II quest income target: ~1,500g
- Act III quest income target: ~3,000–5,000g

If the sums diverge significantly from the pacing targets, adjust individual quest amounts.

- [ ] **Step 5: Verify wealth curve plausibility**

Walk through the Act I wealth curve:
- ~80 encounters × 15–25g avg = 1,500–2,000g enemy income
- 4–6 gold chests × 200–300g = 800–1,200g chest income
- 2 boss total paydays (500g + 1,500g) = 2,000g boss income
- Total: ~4,300–5,200g
- Tier 1 full equip (4 chars): ~6,000–7,000g
- Ratio: 65–70% ← matches target

- [ ] **Step 6: Run grep for stale references**

Search docs/story/ for:
- "Cottage" (should be "Pavilion" everywhere except historical/flavor text)
- "scrip" / "Scrip" (should be "gold" everywhere)
- Any orphan references to old economy concepts

- [ ] **Step 7: Update gap analysis**

In `docs/analysis/game-design-gaps.md`, Gap 1.6:
- Update status from SKELETAL to COMPLETE
- Check off all completed checklist items
- Update the affordability note from "~75%" to "70%" (design decision)
- Add completion date: 2026-03-24
- Add "Files" field: `docs/story/economy.md`
- Note this unblocks: 2.6 (Pallor Wastes Oases), 3.4 (Difficulty & Balance)
- Add Progress Tracking row

- [ ] **Step 8: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 9: Commit**

```bash
git add docs/story/economy.md docs/analysis/game-design-gaps.md
```
(Add any other files if Steps 1–6 found issues requiring fixes.)
Message: `docs(shared): complete cross-reference verification, update Gap 1.6 to COMPLETE`
