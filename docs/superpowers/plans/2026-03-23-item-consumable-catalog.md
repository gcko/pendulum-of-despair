# Item & Consumable Catalog Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/items.md` with the complete item catalog: 32 consumables, 12 Forgewright devices, 67 crafting materials, 18 Ley Crystal invocations, and 24 key items.

**Architecture:** Single markdown file organized by item category. Each section has tables with effects, prices, availability, and cross-references to source docs.

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-23-item-consumable-catalog-design.md`

---

## Chunk 1: Consumables + Forgewright Devices

### Task 1: Create items.md Skeleton

**Files:**
- Create: `docs/story/items.md`

**Context:** Create the file structure, header, table of contents, and inventory rules section. All item sections start as placeholders to be filled by subsequent tasks.

- [ ] **Step 1: Write the header and table of contents**

Create `docs/story/items.md` with:
1. Title: `# Item Catalog — Pendulum of Despair`
2. Blockquote: canonical reference for all items, cross-references to magic.md (status cures), progression.md (Ley Crystals), and bestiary files (drop tables)
3. Table of contents linking to all sections
4. Inventory Structure section (spec Section 6): tab layout table, stack limits, sell price rules

- [ ] **Step 2: Add placeholder sections**

Add empty sections for each category:
- Consumables (HP Healing, MP Restoration, Revival, Status Cures, Battle Utility, Stat Capsules)
- Lira's Forgewright Devices (Core Mechanic, Recipe Table, Recipe Unlocking)
- Ley Crystal Invocations (Core Mechanic, Invocation Catalog, Axis Tower Suppression)
- Crafting Materials (Dual-Purpose Economy, Material Tiers, Complete Material List)
- Key Items (Dungeon Access, Boss Mementos, Crafting Schematics, Story Items)
- Cross-Reference Tables

- [ ] **Step 3: Commit**

```bash
git add docs/story/items.md
```
Message: `docs(shared): create items.md skeleton with inventory structure`

---

### Task 2: Consumable Items (32 types)

**Files:**
- Modify: `docs/story/items.md`

**Context:** Fill in all 6 consumable sub-sections from spec Sections 1.1–1.6. Every table row must include item name, effect description, buy price, sell price (50% of buy), and availability (which act/shop).

- [ ] **Step 1: Write HP Healing section (8 items)**

Copy the table from spec Section 1.1. Add sell price column (50% of buy price, or "—" for non-sellable). Add a design note explaining the 199 stack limit for HP/MP items.

Items: Potion, Hi-Potion, X-Potion, Ley Tonic, Elixir, Megalixir, Tent, Cottage.

- [ ] **Step 2: Write MP Restoration section (3 items)**

Copy from spec Section 1.2. Same format.

Items: Ether, Hi-Ether, X-Ether.

- [ ] **Step 3: Write Revival section (2 items)**

Copy from spec Section 1.3.

Items: Phoenix Feather, Phoenix Pinion.

- [ ] **Step 4: Write Status Cure section (10 items)**

Copy from spec Section 1.4. Include the design note blockquote about Despair curing. Cross-reference magic.md Status Effect Reference for each cure mapping.

Items: Antidote, Alarm Clock, Echo Drop, Eye Drops, Smelling Salts, Soft Stone, Chronos Dust, Remedy, Pallor Salve, Hope Shard.

IMPORTANT: The "Cured By" column in magic.md references these exact item names. Verify each name matches magic.md exactly:
- magic.md line 1392: "Antidote item" ✓
- magic.md line 1394: "Alarm Clock item" ✓
- magic.md line 1396: "Echo Drop item" ✓
- magic.md line 1397: "Eye Drops item" ✓
- magic.md line 1398: "Soft Stone item" ✓
- magic.md line 1399: "Chronos Dust item" ✓
- magic.md line 1403: "Hope Shard item" ✓
- magic.md line 1395: "Remedy item" ✓ (for Confusion — but we now also have Smelling Salts as dedicated cure)

NOTE: Smelling Salts is NEW — not yet in magic.md's "Cured By" column for Confusion (line 1395 currently says "Cleansing Draught, Purge, Remedy item"). This will need a magic.md update in a later task.

- [ ] **Step 5: Write Battle Utility section (3 items)**

Copy from spec Section 1.5.

Items: Smoke Bomb, Waystone, Sable's Coin.

- [ ] **Step 6: Write Stat Capsules section (6 types)**

Copy from spec Section 1.6. Include the distribution note (20% Act II/Interlude, 30% Act III, 50% Dreamer's Fault) and the total stat gain calculation.

Items: Strength Capsule, Guardian Capsule, Arcane Capsule, Warding Capsule, Swiftness Capsule, Fortune Capsule.

- [ ] **Step 7: Write Consumable Summary table**

Copy from spec Section 1.7. Include totals by category and the note about Forgewright devices bringing the total to ~44.

- [ ] **Step 8: Verify and commit**

Cross-check every item name against magic.md and the spec. Verify price progression makes sense (Act I items 50–200g, Act II 200–800g, Act III 1,500–3,000g).

```bash
git add docs/story/items.md
```
Message: `docs(shared): add consumable items (32 types) to items.md`

---

### Task 3: Lira's Forgewright Battle Devices (12 recipes)

**Files:**
- Modify: `docs/story/items.md`

**Context:** Fill in the Forgewright Devices section from spec Section 4. This is the crafting system — Lira forges single-use combat devices from materials.

- [ ] **Step 1: Write Core Mechanic section**

Copy from spec Section 4.1. Include:
- Crafting location rules (save points, camps, inns)
- Inventory limits (5 types, stack to 3, max 15)
- Party split persistence rule
- "Anyone can USE, only Lira can CRAFT" rule

- [ ] **Step 2: Write Recipe Table (12 devices)**

Copy from spec Section 4.2. Format as a full table with columns: Device Name, Category (Offensive/Defensive/Utility/Advanced), Effect, Materials Required, Gold Cost, Unlocked When.

For each recipe, verify the material names match Section 2 (crafting materials). Specifically check:
- Element Shard, Scrap Metal, Crystal Shard — Tier 1 materials ✓
- Elemental Core — Tier 2 material ✓
- Arcanite Shard, Arcanite Core — Tier 3 materials ✓
- Pallor Sample, Spirit Essence — Tier 3/2 materials ✓
- Beast Hide, Bone Fragment, Ether Wisp — Tier 1 materials ✓

- [ ] **Step 3: Write Recipe Unlocking table**

Copy from spec Section 4.4. Map each recipe to the story event that unlocks it.

- [ ] **Step 4: Write Design Philosophy section**

Copy from spec Section 4.3. Explain why devices exist instead of shop-bought battle items (Lira's identity, material economy, loadout strategy, progression).

- [ ] **Step 5: Add Pallor Salve crafting recipe**

Pallor Salve is BOTH a shop item (Section 1.4) and craftable via Forgewright. Add it to the recipe table: 2 Pallor Sample + 1 Spirit Essence, unlocked Act III (Pallor Wastes). Note this in the consumables section as well.

- [ ] **Step 6: Commit**

```bash
git add docs/story/items.md
```
Message: `docs(shared): add Forgewright battle devices (12 recipes) to items.md`

---

### Task 4: Ley Crystal Invocations (18 crystals)

**Files:**
- Modify: `docs/story/items.md`

**Context:** Fill in the Ley Crystal Invocations section from spec Section 3. Cross-reference progression.md for crystal names and leveling.

- [ ] **Step 1: Read progression.md Ley Crystal section**

Read `docs/story/progression.md` lines 184–265 to verify all 18 crystal names match. The invocation catalog must use the exact crystal names from progression.md.

- [ ] **Step 2: Write Core Mechanic section**

Copy from spec Section 3.1. Include:
- 1 invocation per equipped crystal
- Uses limited per rest cycle
- Power scales with crystal level (Lv 1–5)
- Accessed via Magic menu
- Recharge at rest (inn/tent/save point)

- [ ] **Step 3: Write Invocation Catalog table (18 entries)**

Copy from spec Section 3.2. Format as a full table with columns: Crystal Name, Invocation Name, Element/Type, Effect at Lv 1, Effect at Lv 5, Uses per Rest, Category (Standard/Negative/Special).

Special attention to:
- Dawn Fragment diminishing curve (500/400/300/250/200 damage, 8/6/4/3/2 uses)
- Convergence Shard sleeper (100 damage Lv 1–4, 2,000 at Lv 5)
- Cael's Echo (most powerful, 1 use)

- [ ] **Step 4: Write Axis Tower Suppression section**

Copy from spec Section 3.3. Describe the mechanic, what's suppressed (invocations), what's NOT suppressed (stat bonuses), and the restoration condition (defeating Kole).

- [ ] **Step 5: Add design notes**

Add notes explaining:
- The FF6 Esper summon inspiration
- Why uses vary by crystal (power/use trade-off)
- The Dawn Fragment "invest vs exploit" dilemma
- How invocations interact with the crystal's passive stat bonuses (independent systems)

- [ ] **Step 6: Cross-reference with progression.md**

Verify all 18 crystal names match progression.md exactly:
Standard (10): Ember Shard, Iron Core, Ley Prism, Ward Stone, Quicksilver, Fortune Stone, Lifestone, Wellspring, Spirit Tear, Forgewright Core
Negative (4): Flame Heart, Frost Veil, Storm Eye, Grey Remnant
Special (4): Dawn Fragment, Convergence Shard, Null Crystal, Cael's Echo

- [ ] **Step 7: Commit**

```bash
git add docs/story/items.md
```
Message: `docs(shared): add Ley Crystal invocations (18 crystals) to items.md`

---

## Chunk 2: Materials + Key Items + Verification

### Task 5: Crafting Materials (~67 items)

**Files:**
- Modify: `docs/story/items.md`

**Context:** Fill in the Crafting Materials section from spec Section 2. Every material from every bestiary drop table must appear here with its sell price, tier, and crafting use.

- [ ] **Step 1: Write Dual-Purpose Economy explanation**

Copy from spec Section 2.1. Explain the sell-or-save decision and how sell price is the "floor value."

- [ ] **Step 2: Write Material Tier tables (Tiers 1–4)**

Copy from spec Section 2.2. Four tables with columns: Material Name, Source Enemy Type, Tier, Sell Price, Crafting Use.

- [ ] **Step 3: Write Complete Material List**

Create a SINGLE comprehensive table listing ALL ~67 materials. Columns: Name, Source Category (Beast/Construct/Spirit/Pallor/Undead/Arcanite/Humanoid/Post-game/Boss), Sell Price, Tier, Primary Crafting Use, Bestiary Source (which act file).

This is the canonical reference. Cross-check against the bestiary files:
- `docs/story/bestiary/act-i.md` (Steal/Drop columns)
- `docs/story/bestiary/act-ii.md`
- `docs/story/bestiary/interlude.md`
- `docs/story/bestiary/act-iii.md`
- `docs/story/bestiary/optional.md`

Every unique item name in a Steal or Drop column that is NOT an equipment piece or key item must appear in this table.

- [ ] **Step 4: Write Sell Price Formula**

Copy from spec Section 2.4. Include the tier multiplier table.

- [ ] **Step 5: Assign sell prices to ALL materials**

For each of the ~67 materials, compute and assign a specific sell price using the tier formula. This is the most labor-intensive step — every material needs an exact gold value.

Guidelines:
- Tier 1 (75% steal): 25–40g
- Tier 2 (25% drop): 50–100g
- Tier 3 (rare): 150–500g
- Tier 4 (epic): 1,000g+ or unsellable
- Humanoid drops: 30–80g (vendor trash)
- Post-game placeholders: 300–800g

- [ ] **Step 6: Commit**

```bash
git add docs/story/items.md
```
Message: `docs(shared): add crafting materials (67 items) with sell prices to items.md`

---

### Task 6: Key Items (~24 items)

**Files:**
- Modify: `docs/story/items.md`

**Context:** Fill in the Key Items section from spec Section 5. Every key item already referenced in dungeons-world.md, dungeons-city.md, and bestiary boss notes must appear here.

- [ ] **Step 1: Write Key Item inventory rules**

Copy from spec Section 5.1. Separate tab, cannot sell/discard, auto-use for functional items.

- [ ] **Step 2: Write Dungeon Access Items table (10 items)**

For each item: Name, Acquired From, Auto-Use Trigger, Location/Dungeon Affected.

Cross-reference dungeons-world.md and dungeons-city.md for exact acquisition locations and usage conditions.

- [ ] **Step 3: Write Boss Mementos table (8 items)**

For each: Name, Dropped By, Description (1-line flavor text).

These have no gameplay effect — narrative weight only.

- [ ] **Step 4: Write Crafting Schematics table (2 items)**

For each: Name, Acquired From, Recipe Unlocked.

Cross-reference with Forgewright device recipes (Task 3).

- [ ] **Step 5: Write Story Items table (4 items)**

For each: Name, Acquired From, Plot Effect.

- [ ] **Step 6: Write Equipment Cross-Reference list**

List the ~18 boss drops that are equipment pieces (not items). Note that these are documented in Gap 1.5 (Equipment). This prevents confusion when someone sees "Titan's Core (100% drop)" in the bestiary and can't find it in items.md.

- [ ] **Step 7: Write Drake Fang special case note**

Copy from spec Section 7. Document the dual-purpose nature (consumable + crafting material).

- [ ] **Step 8: Commit**

```bash
git add docs/story/items.md
```
Message: `docs(shared): add key items (24) and equipment cross-reference to items.md`

---

### Task 7: Cross-Reference Verification + Updates

**Files:**
- Modify: `docs/story/items.md`
- Modify: `docs/story/magic.md` (add Smelling Salts to Confusion cure)
- Modify: `docs/analysis/game-design-gaps.md`
- Modify: `docs/story/bestiary/CONTINUATION.md` (if needed)

**Context:** Final verification pass. Update magic.md for the new Smelling Salts item. Update gap tracker.

- [ ] **Step 1: Write Cross-Reference tables**

Copy from spec Section 8. Include:
- Status cure mapping table (spec Section 8.1)
- Bestiary drop consistency note (spec Section 8.2)
- Existing item name verification (spec Section 8.3)

- [ ] **Step 2: Update magic.md — add Smelling Salts**

In magic.md's Status Effect Reference table (line ~1395), update the Confusion row's "Cured By" column to include "Smelling Salts item":

Current: `| Confusion | Negative | Attack random targets | 3 turns or until damaged | Cleansing Draught, Purge, Remedy item |`
New: `| Confusion | Negative | Attack random targets | 3 turns or until damaged | Cleansing Draught, Purge, Smelling Salts item, Remedy item |`

Also add Pallor Salve to the Despair row if not already there.

- [ ] **Step 3: Run adversarial verification**

For each consumable:
- Does the price make sense relative to the act it's available in?
- Does the HP/MP restoration amount make sense at the recommended party level? (Potion 100 HP: Lv 1 party has ~33 HP base, so Potion fully heals 3x over — correct for early game)
- Are there dead zones where no new items become available?

For each material:
- Does the sell price match the tier formula?
- Is every bestiary drop accounted for?

For each key item:
- Does the source match dungeons-world.md / dungeons-city.md?
- Does the auto-use trigger make sense?

For each invocation:
- Does the damage scale reasonably from Lv 1 to Lv 5?
- Are the use counts balanced (more uses = weaker effect)?

- [ ] **Step 4: Update gap analysis**

In `docs/analysis/game-design-gaps.md`, Gap 1.4:
- Check off all completed items
- Update status from MISSING to COMPLETE
- Add completion date
- Update "Files" field to include `docs/story/items.md`
- Note that this unblocks: 1.6 (Economy), 3.5 (Crafting)

- [ ] **Step 5: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 6: Commit**

```bash
git add docs/story/items.md docs/story/magic.md docs/analysis/game-design-gaps.md
```
Message: `docs(shared): complete cross-reference verification, update Gap 1.4 to COMPLETE`
