# Equipment System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/equipment.md` with ~60 weapons (6 types), ~47 armor (head + body), ~30 accessories, Arcanite Forging system (8 forged items + 7 infusions + 7 synergies), and ATK growth rebalance note.

**Architecture:** Single markdown file organized by equipment category. Each section has stat tables with Name, Stats, Price, Tier, Acquisition. Weapons grouped by character type. Armor split into Head/Body (Light/Heavy/Robe). Accessories evolve from stat-focused to effect-focused.

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-23-equipment-system-design.md`

---

## Chunk 1: Foundation + Weapons

### Task 1: Create equipment.md Skeleton + ATK Rebalance Note

**Files:**
- Create: `docs/story/equipment.md`

**Context:** Create the file structure, equipment slot definitions, ATK growth adjustment note (with rebalance flag), weapon type overview, and placeholder sections for all categories.

- [ ] **Step 1: Write header and equipment slot definitions**

Create `docs/story/equipment.md` with:
1. Title: `# Equipment Catalog — Pendulum of Despair`
2. Blockquote: canonical reference for all weapons, armor, and accessories. Cross-references to combat-formulas.md (damage), progression.md (stat growth), items.md (crafting materials).
3. Table of contents (all sections from spec Section 10.1)
4. Equipment Slots table (spec Section 1)

- [ ] **Step 2: Write ATK Growth Adjustment section**

This is critical — documents the growth rate change with rebalance flag.

Include:
- Current vs proposed ATK growth rates (spec Section 3.1)
- The canonical formula: `ATK_at_level = floor(base + growth × (level - 1) + 0.5)`
- Proposed new growth rates: Edren 1.4, Cael 1.2, Lira 1.0, Sable 1.1, Torren 0.6, Maren 0.4
- New ATK @ Lv 50 values (verified: Edren 87, Cael 74, Lira 63, Sable 67, Torren 39, Maren 26)
- Weapon % of total ATK at Lv 50 with Tier 4 weapon (+48)
- REBALANCE FLAG blockquote: bestiary 198 enemies + 29 bosses were balanced against old growth rates. Gap 3.4 must verify. Until then, bestiary values are provisional.
- Damage verification examples (4 worked examples from spec Section 3.2, using correct formula)

- [ ] **Step 3: Write weapon type overview**

Per-character weapon type table (spec Section 2). ATK modifier table (spec Section 4.1). Weapon stat template (spec Section 2.2).

- [ ] **Step 4: Write weapon ATK progression tier table**

Tier 0-5 + Forged, with ATK ranges, price ranges, and acquisition methods (spec Section 4).

- [ ] **Step 5: Add placeholder sections**

All remaining sections as `*Content pending — see Task N*`:
- Per-character weapon tables (Tasks 2-4)
- Head Armor (Task 5)
- Body Armor (Task 6)
- Accessories (Task 7)
- Arcanite Forging (Task 8)
- Cross-Reference Tables (Task 9)

- [ ] **Step 6: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): create equipment.md skeleton with ATK rebalance note`

---

### Task 2: Swords (Edren) + Greatswords (Cael)

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** Write the first two weapon type tables. ~10 swords for Edren, ~10 greatswords for Cael. Each weapon needs: Name, ATK, Bonus Stat, Element, Special, Price, Tier, Acquired.

**Design guidelines from spec:**
- Swords: ×1.0 ATK modifier (baseline). No secondary stat unless special.
- Greatswords: ×1.15 ATK modifier, SPD -2 to -5 penalty. High damage, slow.
- Tier 0: ATK 3-5 (starting). Tier 5: ATK 65-100 (ultimate).
- Edren's ultimate: sidequest reward. Cael's ultimate: Grey Cleaver (already designed — ATK +55 purified, or Cael's unique greatsword if he's playable pre-betrayal).
- Name each weapon thematically: Edren's swords = knight/duty names, Cael's greatswords = commander/shadow names.

- [ ] **Step 1: Write Swords table (Edren, ~10 weapons)**

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |

Suggested progression:
- Tier 0: Training Sword (ATK 4)
- Tier 1: Valdris Blade (ATK 10), Knight's Edge (ATK 12)
- Tier 2: Mythril Sword (ATK 18), Compact Saber (ATK 22)
- Tier 3: Arcanite Blade (ATK 35, Forged) — already in spec Section 7.1
- Tier 4: Ley-Forged Longsword (ATK 48), Pallor Bane (ATK 52, +Spirit element)
- Tier 5: Edren's Oath (ATK 80, ultimate, sidequest)
- Each weapon needs a 1-line design note explaining its name and acquisition.

- [ ] **Step 2: Write Greatswords table (Cael, ~10 weapons)**

Greatswords have ×1.15 ATK modifier and SPD penalty.

Suggested progression:
- Tier 0: Recruit's Claymore (ATK 5, SPD -2)
- Tier 1: Commander's Blade (ATK 12, SPD -2)
- Tier 2: Ironbound Greatsword (ATK 22, SPD -3)
- Tier 3: Twilight Edge (ATK 40, SPD -3)
- Tier 4: Void Cleaver (ATK 58, SPD -4, Void element)
- Tier 5: Grey Cleaver (ATK 55 purified, already designed in items.md / bosses.md)

Note: Cael leaves the party during the betrayal (Interlude). His Tier 3-4 weapons are only equippable in the brief pre-betrayal window. Grey Cleaver is Torren's weapon post-purification (per bosses.md). Cael's weapons may have limited use — document this.

IMPORTANT: Check bosses.md and items.md for Grey Cleaver details. The Grey Cleaver is a Torren weapon (Spear section, not Greatsword). Cael's greatswords are only relevant pre-betrayal (Acts I-II). His ultimate weapon is narratively impossible (he's an enemy in Act III).

- [ ] **Step 3: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Swords (Edren) and Greatswords (Cael) to equipment.md`

---

### Task 3: Staves (Maren) + Daggers (Sable)

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** ~10 staves for Maren, ~10 daggers for Sable. Staves have ×0.6 ATK, +MAG bonus. Daggers have ×0.85 ATK, +SPD/LCK bonus.

- [ ] **Step 1: Write Staves table (Maren, ~10 weapons)**

Staves: low ATK, high MAG bonus. Maren is the Archmage — her weapon is a spell amplifier, not a physical weapon.

Suggested progression:
- Tier 0: Scholar's Rod (ATK 2, +3 MAG)
- Tier 1: Ley Wand (ATK 6, +5 MAG), Glyph Staff (ATK 8, +7 MAG)
- Tier 2: Mythril Staff (ATK 12, +10 MAG), Runic Focus (ATK 10, +12 MAG)
- Tier 3: Resonance Rod (ATK 15, +15 MAG, Forged — spec Section 7.1)
- Tier 4: Ley Conduit (ATK 25, +18 MAG), Archive Staff (ATK 22, +20 MAG)
- Tier 5: Maren's ultimate staff (ATK 40, +25 MAG, crafted from Pallor Core — per items.md)

- [ ] **Step 2: Write Daggers table (Sable, ~10 weapons)**

Daggers: moderate ATK, +SPD and +LCK bonuses. Sable is the thief — fast, lucky, precise.

Suggested progression:
- Tier 0: Street Knife (ATK 3, +1 SPD)
- Tier 1: Stiletto (ATK 8, +2 SPD), Pickpocket's Blade (ATK 7, +2 LCK)
- Tier 2: Mythril Dagger (ATK 15, +3 SPD), Trick Blade (ATK 14, +3 LCK)
- Tier 3: Shadowsteel Knife (ATK 28, +4 SPD, +3 LCK, Forged — spec Section 7.1)
- Tier 4: Whisper Edge (ATK 38, +5 SPD), Twilight Fang (ATK 42, +4 LCK)
- Tier 5: Sable's ultimate dagger (ATK 65, +8 SPD, +5 LCK, sidequest)

- [ ] **Step 3: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Staves (Maren) and Daggers (Sable) to equipment.md`

---

### Task 4: Hammers (Lira) + Spears (Torren)

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** ~10 hammers for Lira, ~10 spears for Torren. Hammers have ×1.1 ATK, no secondary. Spears have ×0.95 ATK.

- [ ] **Step 1: Write Hammers table (Lira, ~10 weapons)**

Hammers: high ATK, no magic bonus. Lira is the engineer — her weapons are tools.

Suggested progression:
- Tier 0: Maintenance Wrench (ATK 4)
- Tier 1: Iron Mallet (ATK 10), Pipe Hammer (ATK 12)
- Tier 2: Compact Sledge (ATK 20), Forge Hammer (ATK 24)
- Tier 3: Forgewright Maul (ATK 40, Forged — spec Section 7.1)
- Tier 4: Arcanite Maul (ATK 55), Architect's Hammer (ATK 52, boss drop — spec Section 6.3)
- Tier 5: Lira's ultimate hammer (crafted from Grey Mist Essence — per items.md)

- [ ] **Step 2: Write Spears table (Torren, ~10 weapons)**

Spears: balanced ATK, reach flavor. Torren is the spiritspeaker/ranger.

Suggested progression:
- Tier 0: Hunting Spear (ATK 3)
- Tier 1: Iron Lance (ATK 8), Spirit-Bound Spear (ATK 12, Spirit element — per bosses.md Fenmother reward)
- Tier 2: Mythril Spear (ATK 17), Thornwood Pike (ATK 20)
- Tier 3: Thornspear (ATK 30, +3 SPD, Forged — spec Section 7.1)
- Tier 4: Ley Lance (ATK 45), Pallor Pike (ATK 50)
- Tier 5: Grey Cleaver (ATK 55, Spirit element when purified — per bosses.md)

IMPORTANT: Grey Cleaver is listed in bosses.md as a Torren-exclusive greatsword, but our spec defines Torren's weapon type as Spears. This is a CONFLICT that needs resolution. Options:
- A) Grey Cleaver is a special exception (greatsword that Torren can equip)
- B) Grey Cleaver is reclassified as a Spear (heavy spear/halberd)
- C) Grey Cleaver remains Torren's weapon but is "typeless" (unique category)

Choose the approach that best fits Torren's identity. Document the decision.

- [ ] **Step 3: Write weapon summary table**

A single table showing all ~60 weapons sorted by tier, with character, ATK, and price. This is the "at a glance" reference.

- [ ] **Step 4: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Hammers (Lira) and Spears (Torren) to equipment.md`

---

## Chunk 2: Armor + Accessories + Forging

### Task 5: Head Armor (~22 pieces)

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** ~22 head armor pieces across 6 tiers. All characters can equip all head armor (no restrictions). Provides DEF and MDEF, with some status immunities at higher tiers.

- [ ] **Step 1: Write Head Armor table**

| Name | DEF | MDEF | Special | Price | Tier | Acquired |

Suggested progression (3-4 per tier):
- Tier 0: Leather Cap (DEF 2, MDEF 1)
- Tier 1: Iron Helm (DEF 6, MDEF 3), Traveler's Hood (DEF 5, MDEF 5)
- Tier 2: Mythril Helm (DEF 12, MDEF 8), Scholar's Cap (DEF 8, MDEF 12)
- Tier 3: Arcanite Helm (DEF 30, MDEF 22, Forged — spec Section 7.1), Crystal Helm (DEF 22, MDEF 16), Pallor Veil (DEF 18, MDEF 24, Despair resist)
- Tier 4: Genji Helm (DEF 32, MDEF 24), Ley Crown (DEF 28, MDEF 30)
- Tier 5: Root Crown (DEF 45, MDEF 38, boss drop — Rootking), Dreamer's Crown (DEF 50, MDEF 45)

Include 2-3 options per tier to allow choice (one DEF-focused, one MDEF-focused).

- [ ] **Step 2: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Head Armor (22 pieces) to equipment.md`

---

### Task 6: Body Armor (~25 pieces)

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** ~25 body armor pieces across 3 sub-types: Light (all characters), Heavy (Edren, Lira), Robes (Maren, Torren). Body armor provides primary DEF and sometimes elemental resistance.

- [ ] **Step 1: Write Light Armor table (~12 pieces)**

Equippable by ALL characters. Baseline DEF, moderate MDEF.

Progression: 2 per tier (Tier 0-5).
- Tier 0: Leather Vest (DEF 5, MDEF 2)
- Tier 1: Chain Mail (DEF 10, MDEF 5)
- Tier 2: Mythril Vest (DEF 18, MDEF 10)
- Tier 3: Crystal Vest (DEF 30, MDEF 18), Pallor Ward Vest (DEF 38, MDEF 25, Despair resist 50%, Forged — spec Section 7.1)
- Tier 4: Genji Armor (DEF 45, MDEF 28)
- Tier 5: Spirit Shroud (DEF 60, MDEF 50, halve Spirit + Void — spec Section 9.2)

- [ ] **Step 2: Write Heavy Armor table (~8 pieces)**

Equippable by Edren and Lira only. ×1.3 DEF modifier, lower MDEF.

Progression: 1-2 per tier (Tier 1-5, no Tier 0 heavy armor).
- Tier 1: Iron Plate (DEF 15, MDEF 3)
- Tier 2: Compact Plate (DEF 26, MDEF 8)
- Tier 3: Arcanite Plate (DEF 42, MDEF 12)
- Tier 4: Kole's Epaulettes (body, DEF 48, MDEF 18, boss drop — General Kole)
- Tier 5: Adamant Mail (DEF 75, MDEF 25, ultimate)

- [ ] **Step 3: Write Robes table (~5 pieces)**

Equippable by Maren and Torren. ×0.7 DEF, ×1.5 MDEF.

Progression: 1 per tier (Tier 1-5).
- Tier 1: Silk Robe (DEF 6, MDEF 10)
- Tier 2: Ley Vestment (DEF 10, MDEF 20)
- Tier 3: Ley-Woven Cloak (DEF 20, MDEF 40, MP Regen 3%/turn, Forged — spec Section 7.1)
- Tier 4: Archmage's Robe (DEF 28, MDEF 48)
- Tier 5: Thornmere Raiment (DEF 35, MDEF 65, ultimate)

- [ ] **Step 4: Write elemental body armor table**

From spec Section 9.2: Flameguard Mail (halve Flame), Frostweave Vest (halve Frost), Stormhide Coat (halve Storm), Earthen Plate (halve Earth). All Tier 3, shop or chest.

- [ ] **Step 5: Write body armor summary**

Combined table of all ~25 pieces sorted by tier and category.

- [ ] **Step 6: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Body Armor (25 pieces: light, heavy, robes, elemental) to equipment.md`

---

### Task 7: Accessories (~30 pieces)

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** ~30 accessories following the FF6 Relic progression model: stat-focused early, effect-focused late. This is the "customization engine" per spec Section 6.

- [ ] **Step 1: Write Stat Boost accessories (~8)**

Early-game (Act I-II). Simple +stat effects.

| Name | Effect | Price | Tier | Acquired |

Examples:
- Power Ring (+5 ATK), Iron Bracelet (+5 DEF), Magic Earring (+5 MAG)
- Warding Charm (+5 MDEF), Sprint Shoes (+5 SPD), Lucky Coin (+5 LCK)
- Life Pendant (+200 HP), Mana Bead (+50 MP)

- [ ] **Step 2: Write Status Immunity accessories (~6)**

Mid-game (Act II-Interlude). Prevent specific statuses.

Examples:
- Antidote Charm (Poison immune), Clarity Band (Confusion immune)
- Silence Ward (Silence immune), Stone Guard (Petrify immune)
- Despair Ward (Despair immune — Act III, very rare/expensive)
- Berserk Collar (Berserk immune)

- [ ] **Step 3: Write Elemental Resistance accessories (~4)**

Mid-to-late game. Halve one element's damage.

Examples:
- Flame Ring (halve Flame), Frost Amulet (halve Frost)
- Storm Pendant (halve Storm), Void Ward (halve Void)

- [ ] **Step 4: Write Combat Mechanic accessories (~6)**

Late-game (Interlude-Act III). Unique effects.

Examples:
- Haste Bangle (auto-Haste 2 turns at battle start)
- Counter Ring (+15% counter-attack rate)
- Ley Amplifier (+20% spell damage)
- Pallor Bane (+25% damage vs Pallor-type)
- MP Regen Ring (restore 3% max MP per turn)
- Preemptive Charm (+25% preemptive strike rate)

- [ ] **Step 5: Write Character-Specific and Quest accessories (~6)**

Boss drops and unique rewards (spec Section 6.3 mapping):

- Colossus Shard (Ley Colossus drop)
- Drayce's Failsafe Core (Forge Warden drop)
- Warden's Binding (Undying Warden drop)
- Cael's Knight Crest (+20 all stats, Edren only — Cael Phase 1 drop)
- Titan's Core (+25 MAG, +25 MDEF, Ley affinity — Ley Titan drop)
- Dreamer's Crest (+30 all stats — Cael's Echo, post-game)

And additional boss accessories:
- Crown Shard, Unfinished Ring, Ashen Scholar's Tome, Nexus Crest, Cael's Memory, Scholar's Codex, Queen's Facet, Warden's Core

Each needs: Name, Effect (specific stat bonuses or mechanics), Source Boss, Act.

- [ ] **Step 6: Write accessory summary table**

All ~30 sorted by act/tier.

- [ ] **Step 7: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Accessories (30 pieces) to equipment.md`

---

### Task 8: Arcanite Forging System

**Files:**
- Modify: `docs/story/equipment.md`

**Context:** Lira's equipment crafting: 8 forgeable items, 7 elemental infusions, 7 secret synergies. The "Forged" attribute and infusion system.

- [ ] **Step 1: Write Forgeable Equipment section**

Copy the 8 items from spec Section 7.1 (5 weapons + 3 armor). Table with: Name, Slot, Type, Stats, Materials, Gold Cost, Unlock Condition.

Include the "Forged" attribute description:
- Forged items have a visible "Forged" tag in the equipment menu
- Cannot be bought — only crafted by Lira at save points/camps
- Forged weapons can receive elemental infusions like any other weapon

- [ ] **Step 2: Write Elemental Infusion section**

Copy the 7 infusions from spec Section 7.2. Table with: Infusion Name, Element Added, Materials, Gold Cost.

Include rules:
- Any weapon can be infused (including Forged and Ultimate)
- Permanent but replaceable (new infusion overwrites old)
- Free removal at any save point
- Infused weapons show "(Infused: Element)" suffix
- Element damage multipliers per combat-formulas.md apply

- [ ] **Step 3: Write Secret Synergies section**

Copy the 7 combos from spec Section 7.3. Table with: Base Weapon, Required Infusion, Synergy Name, Bonus Effect.

Include:
- Discovery mechanic (no in-game hints until synergy activates)
- Discovery notification text template
- Each synergy's narrative justification (why this weapon + this element)

The 7 synergies:
1. Grey Cleaver (tainted) + Spirit → Penitent's Edge (accelerated purification)
2. Architect's Hammer + Storm → Stormforge Hammer (+25% vs Constructs)
3. Any Torren Spear + Earth → Rootbound Lance (20% Slow chance)
4. Any Maren Staff + Ley → Resonance Staff (MP cost -15%)
5. Any Sable Dagger + Void → Shadowfang (steal +25%, Despair chance)
6. Any Lira Hammer + Flame → Crucible Maul (device cost -50%)
7. Any Edren Sword + Spirit → Oathkeeper (+15% dmg when ally Fainted)

- [ ] **Step 4: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Arcanite Forging (8 items, 7 infusions, 7 synergies) to equipment.md`

---

### Task 9: Cross-References + Verification + Gap Update

**Files:**
- Modify: `docs/story/equipment.md`
- Modify: `docs/story/progression.md` (add rebalance note to ATK growth section)
- Modify: `docs/story/items.md` (fix boss equipment drop names in cross-reference)
- Modify: `docs/analysis/game-design-gaps.md`

- [ ] **Step 1: Write Equipment Tiers by Act summary**

A single table showing what's available per act across all slots:

| Act | Weapon Tier | Head Tier | Body Tier | Accessories Available |
|-----|-----------|---------|---------|---------------------|

- [ ] **Step 2: Write Price Reference table**

Combined equipment price reference sorted by tier.

- [ ] **Step 3: Write Cross-Reference section**

- Boss drops: table mapping each of 18 boss equipment drops to the correct boss name, slot, and act (using the SPEC's boss names, which match the bestiary)
- items.md materials: verify all Forgewright recipe materials exist in items.md
- Grey Cleaver: document the weapon type resolution (Spear? Greatsword? Special?)

- [ ] **Step 4: Fix items.md boss equipment drop names**

The items.md cross-reference table (lines ~524-542) has WRONG boss names from a subagent error. Update to match bestiary:
- "Drayce" → "Forge Warden"
- "Pallor Queen" → "Crystal Queen" (for Queen's Facet), "Crowned Hollow" (for Crown Shard)
- "The Architect" (for Unfinished Ring) → "Perfect Machine"
- "Ashen Scholar" → "Vaelith"
- "Grey Knight" → "Grey Cleaver Unbound", wielder "Drayce" → "Torren"
- "Nexus Guardian" → "Wellspring Guardian"
- "Pallor Incarnate" (for Cael's Memory) → "Pallor Echo"
- "Vaelith" (for Scholar's Codex) → "First Scholar"
- "Elder Treant" → "Rootking"
- "Vein Guardian" (for Warden's Core) → "Iron Warden"
- "Dreamer (final)" → "Cael's Echo (non-combat)"

Also fix slot assignments:
- Ashen Scholar's Tome: "Weapon (Sable)" → "Accessory"
- Queen's Facet: "Weapon (Sable)" → "Accessory"
- Grey Cleaver: "Weapon (Drayce)" → "Weapon (Torren)"

- [ ] **Step 5: Add rebalance note to progression.md**

In progression.md's ATK growth section, add a blockquote note:

> **Equipment rebalance (Gap 1.5):** ATK growth rates below are
> proposed for reduction to make weapon upgrades more impactful.
> See equipment.md ATK Growth Adjustment section for new values
> and damage verification. Bestiary rebalance pending (Gap 3.4).

Do NOT change the actual growth values in progression.md yet — the note flags the proposed change for the balance pass.

- [ ] **Step 6: Run adversarial verification**

For each weapon:
- Does the ATK value match the tier range from spec Section 4?
- Does the per-type modifier produce the correct ATK? (Greatsword ×1.15, Staff ×0.6, etc.)
- Are prices within the tier's price range?

For each armor piece:
- Does DEF match the tier range?
- Do Heavy/Robe modifiers apply correctly?

For accessories:
- Do all boss drops match the bestiary boss names?
- Are effect descriptions internally consistent?

For Forgewright:
- Do all recipe materials exist in items.md's material list?
- Do infusion material costs reference actual materials?
- Are the 7 synergy weapon names consistent with the weapon tables?

- [ ] **Step 7: Update gap analysis**

In `docs/analysis/game-design-gaps.md`, Gap 1.5:
- Check off all completed items
- Update status from SKELETAL to COMPLETE (or MOSTLY COMPLETE if deferred items remain)
- Add completion date
- Update "Files" field to include `docs/story/equipment.md`
- Note: progression.md rebalance flagged for Gap 3.4
- Check what this unblocks: 1.6 (Economy — equipment prices defined), 3.5 (Crafting — Forgewright recipes defined)

Add a row to the Progress Tracking table.

- [ ] **Step 8: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 9: Commit**

```bash
git add docs/story/equipment.md docs/story/progression.md docs/story/items.md docs/analysis/game-design-gaps.md
```
Message: `docs(shared): complete cross-reference verification, fix items.md boss names, update Gap 1.5`
