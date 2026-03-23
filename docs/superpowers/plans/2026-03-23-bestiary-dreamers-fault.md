# Bestiary Dreamer's Fault Implementation Plan (Gap 1.3, Sub-project 3b)

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate optional.md with 24 Dreamer's Fault enemies across 5 ages,
including 4 Echo Bosses with unique combat mechanics and the Cael's Echo
non-combat encounter.

**Architecture:** Pure documentation pass — rewrite optional.md from TBD
placeholder to full stat tables with Echo Boss mechanics, age-themed
crafting materials, and Void Pallor callbacks. Update palette-families.md
with Void deployment notes, CONTINUATION.md, and gap tracker.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-23-bestiary-dreamers-fault-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/optional.md` | Rewrite | Full Dreamer's Fault enemy stat tables (24 entries) + Echo Boss mechanics + Cael's Echo |
| `docs/story/bestiary/palette-families.md` | Modify | Add Void deployment notes for Drake, Wolf, Lurker families |
| `docs/story/bestiary/CONTINUATION.md` | Modify | Update Sub-project 3b status |
| `docs/story/bestiary/README.md` | Modify | Update index row for optional.md |
| `docs/analysis/game-design-gaps.md` | Modify | Check off optional items in Gap 1.3 |

---

## Chunk 1: Stat Tables

### Task 1: Populate optional.md — Ages 1–4 (16 regular enemies + 4 Echo Bosses)

**Files:**
- Rewrite: `docs/story/bestiary/optional.md`
- Reference: `docs/story/bestiary/README.md` (formulas, types)
- Reference: `docs/story/dungeons-world.md` (Dreamer's Fault section)
- Reference: `docs/superpowers/specs/2026-03-23-bestiary-dreamers-fault-design.md`

- [ ] **Step 1: Write file header + First Age section (4 regular + 1 boss)**

Replace TBD content with:

```markdown
# Optional Bestiary

Enemies encountered in post-game optional content: Dreamer's Fault
(20-floor super dungeon). See [README.md](README.md) for type rules,
stat formulas, and reward calculations.

**Total:** 24 stat-block enemies across 5 ages + 1 non-combat encounter

> **Level classification:** Floors 1–12 (Lv 42–70) fall within the
> Post-game range (40–80). Floors 13–20 (Lv 74–100) fall within the
> Optional/Superboss range (70–150). Echo Boss HP (40K–100K) exceeds
> the main-story boss range (6K–70K).

---

## The Dreamer's Fault

Post-game super dungeon. 20 floors, 5 ages. A crack between reality
and the Pallor's domain — echoes of every civilization the Grey
consumed. Entry via The Pendulum tavern cellar.

---

## The First Age — Ancient Stone (Floors 1–4, Lv 42–48)

A civilization of scholar-builders. Geometric architecture,
glyph-based magic, stone guardians. Floor rotation mechanic.
```

First Age enemies (spec Section 3.1):

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| First Age Sentinel | 42 | Construct | Dangerous | Tank |
| Glyphscribe | 44 | Humanoid | Dangerous | Caster |
| Carved Watcher | 46 | Construct | Dangerous | Balanced |
| Ember Remnant | 48 | Elemental | Dangerous | Glass cannon |

For each enemy, compute ALL stats using README formulas at the
listed level with role adjustments. Apply type rules:
- Construct: MP=0, Immune Poison/Sleep/Confusion/Berserk/Despair
- Humanoid: no inherent immunities
- Elemental: absorbs own element, Immune Petrify

Use age-specific steal/drop (all are **Gap 1.4 placeholders** —
add a note in the section header that item names/effects are TBD
pending Item Catalog design):
- Steal: Ancient Glyph (75%)
- Drop: Carved Stone (25%)

Then write The First Scholar Echo Boss section:
- Stat table row (italicized, Lv 50, 40,000 HP, Boss type)
- Boss notes with Phase 1/2, spell pattern mechanic
- Weakness: Void (150%), Resistance: Spirit (50%)
- Boss immunities: Death+Petrify+Stop+Sleep+Confusion
- Steal: Ancient Manuscript (100%), Drop: Scholar's Codex (100%)

**Cross-reference:** Read dungeons-world.md Dreamer's Fault section
for the First Scholar's description. Use "See dungeons-world.md"
for any details beyond what the spec provides.

- [ ] **Step 2: Write Crystal Age section (4 regular + 1 boss)**

Crystal Age enemies (spec Section 3.2):

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Crystal Refractor | 52 | Elemental | Dangerous | Caster |
| Facet Drone | 54 | Construct | Dangerous | Swarm |
| Prism Stalker | 56 | Beast | Dangerous | Glass cannon |
| Resonance Shade | 58 | Spirit | Dangerous | Caster |

Steal: Crystal Fragment (75%), Drop: Prism Shard (25%)

Crystal Queen Echo Boss: Lv 60, 60,000 HP, reflection mechanic,
Phase 2 shatters into 4 Crystal Aspects (15,000 HP each).
Weakness: Earth (150%), Resistance: Ley (75%).
Steal: Queen's Prism (100%), Drop: Queen's Facet (100%).

- [ ] **Step 3: Write Green Age section (4 regular + 1 boss)**

Green Age enemies (spec Section 3.3):

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Root Weaver | 62 | Elemental | Dangerous | Tank |
| Bough Knight | 64 | Humanoid | Dangerous | Balanced |
| Canopy Lurker | 66 | Beast | Dangerous | Glass cannon |
| Heartwood Spirit | 70 | Spirit | Rare | Caster |

Steal: Living Bark (75%), Drop: Heartwood Splint (25%)

**Note:** Heartwood Spirit uses Rare threat (×1.5) — it is a
surviving nature spirit, deliberately scarce. All other Green Age
enemies use Dangerous.

Rootking Echo Boss: Lv 72, 80,000 HP, regen + summons mechanic,
Root Anchor targetable part.
Weakness: Flame (150%), Resistance: Earth (50%).
Steal: Living Root (100%), Drop: Root Crown (100%).

- [ ] **Step 4: Write Iron Age section (4 regular + 1 boss)**

Iron Age enemies (spec Section 3.4):

| Name | Lv | Type | Threat | Role |
|------|----|------|--------|------|
| Iron Automaton | 74 | Construct | Dangerous | Tank |
| Gear Wraith | 78 | Spirit | Dangerous | Caster |
| Pressure Golem | 80 | Construct | Dangerous | Balanced |
| Scrap Swarm | 84 | Construct | Dangerous | Swarm |

Steal: Iron Cog (75%), Drop: Tempered Plate (25%)

**Note:** Iron Automaton is "Immune to magic. Physical only."
Include this as a design note — it is a per-enemy exception to
the normal Construct rules (Constructs normally have MAG stat
for MDEF derivation, but Iron Automaton's magic immunity is
layered on top).

Iron Warden Echo Boss: Lv 86, 100,000 HP, 3-phase counter
mechanic. The true final boss of the game.
Weakness: Storm (150%), Resistance: Flame (50%), Frost (50%).

- [ ] **Step 5: Verify Ages 1–4**

Run: `pnpm lint && pnpm test`

Manually verify:
1. All Construct enemies: MP=0, 5 immunities
2. All Spirit enemies: Immune Poison+Petrify
3. All Elemental enemies: Immune Petrify
4. All Boss enemies: Death+Petrify+Stop+Sleep+Confusion
5. Echo Boss HP: 40K, 60K, 80K, 100K
6. Boss resistance percentages annotated in stat tables
7. Age-specific steal/drop used consistently
8. Stat formulas correct at these high levels (spot-check 2)

- [ ] **Step 6: Commit**

```bash
git add docs/story/bestiary/optional.md
git commit -s -m "docs(shared): populate Dreamer's Fault Ages 1-4 with 16 regular + 4 Echo Bosses"
```

---

### Task 2: Populate optional.md — The Void + Cael's Echo + Summary

**Files:**
- Modify: `docs/story/bestiary/optional.md`
- Reference: `docs/superpowers/specs/2026-03-23-bestiary-dreamers-fault-design.md` (Section 3.5)

- [ ] **Step 1: Write Void section (4 enemies)**

```markdown
## The Void — Pure Grey (Floors 17–20, Lv 88–100)

The Pallor's domain. No map — navigate by sound. Familiar Pallor
Tier 4 variants at amplified power levels. The Grey kept what it
consumed from every age.
```

Void enemies (spec Section 3.5):

| Name | Family | Tier | Lv | Type | Threat |
|------|--------|------|----|------|--------|
| Pallor Drake | Drake | 4 | 90 | Pallor | Rare |
| Pallor Wolf | Wolf | 4 | 92 | Pallor | Rare |
| Pallor Lurker | Lurker | 4 | 96 | Pallor | Rare |
| Void Walker | — (unique) | — | 100 | Pallor | Dangerous |

**Type rules for Pallor:**
- Weak=Spirit, Immune Despair+Death (type defaults per README)
- Resist Void is a per-enemy column value for Tier 4 Pallor
  family variants (from palette-families Element Shift), NOT a
  type-level default. Add Void to the Resists column for Drake,
  Wolf, and Lurker. Void Walker (unique, non-family) does NOT
  get Void resistance — it IS the Void.
- 2% HP regen while party has Despair
- At Lv 100, Pallor regen = ~384 HP/turn (extremely punishing)

Void enemies use standard Pallor steal/drop:
- Steal: Pallor Sample (75%), Drop: Grey Residue (25%)

Void Walker design note: "The Pallor distilled. Drains HP, MP,
ATK, and DEF simultaneously. The hardest regular enemy in the
game." Pallor regen at Lv 100 should be explicitly noted.

**Threat level preserved per README early deployment rule.**
Pallor Drake and Pallor Wolf are Rare (×1.5). Void Walker uses
Dangerous (×1.0) — it is unique, not a family variant.

- [ ] **Step 2: Write Cael's Echo section**

```markdown
## Cael's Echo (Floor 20 — Non-Combat)

Not a fight. The party reaches the bottom of the Dreamer's Fault
and finds an echo of Cael sitting at a table, drinking tea.

> "It's heavy. But the door is closed. Go home."

The party can examine echoes of every age — brief vignettes of
the civilizations that fell. Then the party leaves.

**Reward:** Dreamer's Crest (accessory — +30 all stats, best in
game). **TODO: finalize stat block in Gap 1.5 (Equipment).**
```

No stat table needed for this section.

- [ ] **Step 3: Write summary section**

```markdown
## Dreamer's Fault Summary

- **Total:** 24 stat-block enemies + 1 non-combat encounter
- **Level range:** 42–100 (Post-game through Optional/Superboss)
- **Type distribution:** Construct (30%), Spirit (17%), Elemental
  (17%), Humanoid (8%), Beast (8%), Pallor (17%)
- **Echo Bosses:** 4 combat (escalating 40K–100K HP) + 1 non-combat
- **Unique age materials:** 5 steal + 5 drop items (TODO Gap 1.4)
- **Best-in-game accessories:** 5 (TODO Gap 1.5)
- **True final boss:** The Iron Warden (100,000 HP, Lv 86)
```

- [ ] **Step 4: Verify and commit**

Run: `pnpm lint && pnpm test`

Verify:
1. All Pallor enemies: Weak=Spirit, Immune Despair+Death, Resist Void
2. Void Walker Pallor regen noted in design notes
3. Cael's Echo has no stat table
4. Count: 4 (Void regular) = 4 entries this task
5. Total across both tasks: 20 regular + 4 bosses = 24

```bash
git add docs/story/bestiary/optional.md
git commit -s -m "docs(shared): populate Dreamer's Fault Void section and summary (4 entries + Cael's Echo)"
```

---

## Chunk 2: Palette Families + Metadata

### Task 3: Update palette-families.md with Void deployment notes

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`

- [ ] **Step 1: Add Void deployment notes to 3 families**

**CRITICAL: Do NOT create new tier rows.** All 3 Tier 4 entries
already exist. Only add deployment notes to the family blockquotes.

| Family | Existing Tier 4 | Projected Lv | Void Deploy Lv |
|--------|----------------|--------------|-----------------|
| Drake | Pallor Drake | 50 | 90 |
| Wolf | Pallor Wolf | 45 | 92 |
| Lurker | Pallor Lurker | 46 | 96 |

**Verify projected levels against palette-families.md before writing
notes.** Read the actual Drake, Wolf, and Lurker family entries to
confirm the projected Lv values match.

For each family, add a note like:

```markdown
> **Dreamer's Fault deployment:** Pallor Drake also appears at
> Lv 90 in the Void (Floors 17–20). The Pallor's domain amplifies
> all entities — stats computed from the Void deployment level.
```

These are the most extreme deployment gaps in the game (40–50
levels above projection). The notes should explain that the Void
amplifies Pallor entities.

- [ ] **Step 2: Verify and commit**

Verify:
1. No new tier rows created
2. All 3 families have Void deployment notes
3. Existing Act III deployment notes still present (not overwritten)

```bash
git add docs/story/bestiary/palette-families.md
git commit -s -m "docs(shared): add Void deployment notes to Drake, Wolf, Lurker families"
```

---

### Task 4: Update metadata files

**Files:**
- Modify: `docs/story/bestiary/CONTINUATION.md`
- Modify: `docs/story/bestiary/README.md`
- Modify: `docs/analysis/game-design-gaps.md`

- [ ] **Step 1: Update CONTINUATION.md**

Update the current state table:
```markdown
| **3b: Optional** | COMPLETE | — (pending PR) | 24 | optional.md, palette-families.md |
```

Update "Gap 1.3 status" and last-updated date.

- [ ] **Step 2: Update README.md index**

Change the optional.md row from "(TBD)" to actual content:
```markdown
| [optional.md](optional.md) | Dreamer's Fault (24 enemies across 5 ages, Lv 42–100) |
```

- [ ] **Step 3: Update game-design-gaps.md**

The gap checklist doesn't have a specific "optional enemies" item,
but the general bestiary status should be updated to reflect that
only the Boss Compendium (Sub-project 4) remains.

- [ ] **Step 4: Verify and commit**

Run: `pnpm lint && pnpm test`

```bash
git add docs/story/bestiary/CONTINUATION.md docs/story/bestiary/README.md docs/analysis/game-design-gaps.md
git commit -s -m "docs(shared): update metadata for Dreamer's Fault bestiary completion"
```

---

### Task 5: Cross-reference verification

**Files:**
- Read: All files modified in Tasks 1–4
- Reference: `docs/story/dungeons-world.md`
- Reference: `docs/story/bestiary/README.md`

- [ ] **Step 1: Echo Boss HP verification**

| Boss | Expected HP | Source |
|------|------------|--------|
| First Scholar | 40,000 | Spec (new content) |
| Crystal Queen | 60,000 | Spec (new content) |
| Rootking | 80,000 | Spec (new content) |
| Iron Warden | 100,000 | Spec (new content) |

Verify all 4 are present with correct HP.

- [ ] **Step 2: Type rule verification**

Check ALL enemies:
1. All Construct (6 total): MP=0, 5 immunities
2. All Spirit (4 total): Immune Poison+Petrify
3. All Elemental (3 total): Immune Petrify
4. All Pallor (4 total): Weak=Spirit, Immune Despair+Death, Resist Void
5. All Boss (4 total): Immune Death+Petrify+Stop+Sleep+Confusion
6. All Beast (2 total): no inherent immunities
7. All Humanoid (2 total): no inherent immunities

- [ ] **Step 3: Stat formula spot-checks (5 enemies)**

Pick one from each age + Void:
- First Age Sentinel (Lv 42, Construct Tank)
- Crystal Refractor (Lv 52, Elemental Caster)
- Root Weaver (Lv 62, Elemental Tank)
- Iron Automaton (Lv 74, Construct Tank)
- Void Walker (Lv 100, Pallor Balanced)

For each: compute HP, ATK, DEF, MAG, MDEF, SPD from formulas.
Apply role adjustment (Balanced = no adjustment, use baseline
stats). Verify Gold/Exp match logistic formula × threat multiplier.

- [ ] **Step 4: Age steal/drop consistency**

Verify each age uses its own materials:
- First Age: Ancient Glyph / Carved Stone
- Crystal Age: Crystal Fragment / Prism Shard
- Green Age: Living Bark / Heartwood Splint
- Iron Age: Iron Cog / Tempered Plate
- Void: Pallor Sample / Grey Residue

No cross-contamination (e.g., no Crystal Fragment in the Iron Age).

- [ ] **Step 5: Boss resistance percentages annotated**

All 4 Echo Bosses must have explicit percentages in stat tables:
- First Scholar: Void (150%), Spirit (50%)
- Crystal Queen: Earth (150%), Ley (75%)
- Rootking: Flame (150%), Earth (50%)
- Iron Warden: Storm (150%), Flame (50%), Frost (50%)

- [ ] **Step 6: Enemy count**

Count every stat table row. Must equal 24 (20 regular + 4 bosses).
Cael's Echo should NOT have a stat table row.

- [ ] **Step 7: Commit if fixes needed**

```bash
git add docs/story/bestiary/optional.md docs/story/bestiary/palette-families.md
git commit -s -m "docs(shared): fix cross-reference issues found during verification"
```

---

## Verification Checklist (Post-Implementation)

Before running `/create-pr`:

```markdown
- [ ] `pnpm test` passes
- [ ] `pnpm lint` passes
- [ ] 4 Echo Boss HP verified (40K, 60K, 80K, 100K)
- [ ] All 6 Construct enemies: MP=0, 5 immunities
- [ ] All 4 Spirit enemies: Immune Poison+Petrify
- [ ] All 3 Elemental enemies: Immune Petrify
- [ ] All 4 Pallor enemies: Weak=Spirit, Immune Despair+Death
- [ ] Pallor Drake/Wolf/Lurker: Resist=Void (per-enemy, from palette-families)
- [ ] Void Walker: Resist=— (unique, no Void resistance)
- [ ] All 4 Boss immunities: Death+Petrify+Stop+Sleep+Confusion
- [ ] Boss resistance percentages annotated in stat tables
- [ ] Age-specific steal/drop materials used consistently
- [ ] Void Walker Pallor regen explicitly noted
- [ ] Cael's Echo: no stat table, reward documented
- [ ] palette-families.md: Void deployment notes for 3 families
- [ ] No new palette-family tier rows created
- [ ] CONTINUATION.md updated (Sub-project 3b complete)
- [ ] README.md index updated (optional.md no longer TBD)
- [ ] Enemy count = 24 stat-block entries
- [ ] Stat formula spot-checks pass (5 enemies, one per age)
- [ ] All TODO cross-references to Gap 1.4/1.5 present
```
