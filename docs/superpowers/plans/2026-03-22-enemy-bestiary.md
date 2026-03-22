# Enemy Bestiary Implementation Plan (Gap 1.3, Sub-project 1)

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the bestiary foundation (template, formulas, type rules,
palette-swap system) and populate all Act I enemies in `docs/story/bestiary/`.

**Architecture:** Pure documentation pass — create bestiary README with canonical
rules, populate act-i.md with 25 enemy stat tables, define 19 palette-swap
families, and update cross-references across 5 existing files.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-22-enemy-bestiary-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/README.md` | Create | Canonical template, type rules, scaling formulas, index |
| `docs/story/bestiary/act-i.md` | Create | 25 Act I enemy stat tables |
| `docs/story/bestiary/palette-families.md` | Create | 19 Act I family definitions |
| `docs/analysis/game-design-gaps.md` | Modify | Gap 1.3 status MISSING → PARTIAL |
| `AGENTS.md` | Modify | Add bestiary to Repository Layout + Where to Add Code |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add bestiary README reference |
| `.claude/skills/story-designer/SKILL.md` | Modify | Update file naming convention |
| `.claude/skills/story-review-loop/agents/canonical-verifier.md` | Modify | Add enemies canonical source |

---

## Chunk 1: Bestiary README (Foundation)

### Task 1: Create bestiary README with template and type rules

**Files:**
- Create: `docs/story/bestiary/README.md`

- [ ] **Step 1: Create the directory and README**

First, create the bestiary directory:
```bash
mkdir -p docs/story/bestiary
```

Then create `docs/story/bestiary/README.md` with these sections (all
content from the spec):

**Section 1 — Header and index:**
```markdown
# Enemy Bestiary

> **Canonical reference** for all enemy data. Type rules, stat formulas,
> and reward curves defined here govern every enemy in the game.
> Individual enemy stat tables live in the per-act files listed below.

## Index

| File | Contents |
|------|----------|
| [act-i.md](act-i.md) | Ember Vein, Fenmother's Hollow, Overworld Act I (25 enemies) |
| [act-ii.md](act-ii.md) | Valdris Siege, Ley Line Depths, Overworld Act II (TBD) |
| [interlude.md](interlude.md) | Rail Tunnels, Axis Tower, City Dungeons (TBD) |
| [act-iii.md](act-iii.md) | Pallor Wastes, Convergence (TBD) |
| [optional.md](optional.md) | Sidequests, Superbosses, Rare Encounters (TBD) |
| [bosses.md](bosses.md) | All Bosses & Mini-Bosses with AI Scripts (TBD) |
| [palette-families.md](palette-families.md) | Base → Variant Mappings |
```

**Section 2 — Stat template (19 columns):**
Copy the full column definition table from spec Section 4.

**Section 3 — Enemy type rules:**
Copy all 8 type definitions from spec Sections 5.1–5.8, plus the
stacking rule (5.9) and single-type rule (5.10).

**Section 4 — Stat scaling formulas:**
Copy from spec Section 6.2 — the 7 stat formulas and the verification
table. Include the level ranges by act from Section 6.1.

**Section 5 — Boss stat multipliers:**
Copy from spec Section 6.3.

**Section 6 — Reward formulas (bounded growth):**
Copy from spec Sections 7.1–7.3 — both logistic formulas, both value
tables, and the threat multiplier table with worked examples.

**Section 7 — Palette-swap family system:**
Copy from spec Sections 8.1–8.3 — tier definitions, Tier 4 type change
rules, naming conventions. Include the Vermin family example (8.4).

- [ ] **Step 2: Verify the README is self-contained**

Read the README from top to bottom. Verify:
- All 7 stat formulas are present with the verification table
- All 8 type rules have inherent traits, immunities, and interactions
- Both reward formulas have correct parameters (Gold: a=824, b=0.0754;
  Exp: a=1188, b=0.0696)
- The threat multiplier table has all 6 tiers
- Palette-swap tier definitions are complete (4 tiers)

- [ ] **Step 3: Commit**

```bash
git add docs/story/bestiary/README.md
```
Commit message: `docs(shared): create bestiary README with template, types, and formulas`

Do NOT push yet — commit locally only.

---

## Chunk 2: Act I Enemy Stat Tables

### Task 2: Create act-i.md with computed stat blocks

**Files:**
- Create: `docs/story/bestiary/act-i.md`
- Reference: `docs/story/bestiary/README.md` (formulas)
- Reference: `docs/story/dungeons-world.md` (boss HP values, enemy names)
- Reference: `docs/story/combat-formulas.md` (damage verification)

- [ ] **Step 1: Compute base stats for all 25 enemies**

Use the formulas from README.md. For each enemy, compute stats at
its level, then apply role adjustments (±15%) per the spec.

**Role adjustment guidelines:**
- Glass cannon: ATK +15%, DEF -15%, HP -10%
- Tank: DEF +15%, HP +10%, SPD -10%
- Swarm: HP -30%, ATK -10% (appears in groups — total damage per
  encounter balances out)
- Caster: MAG +15%, ATK -15%, MDEF +10%
- Balanced: no adjustment (use formula baseline)

Compute Gold and Exp using the logistic formulas × threat multiplier.
Apply `floor()` to all values. Hard-cap Gold at 10,000 and Exp at
30,000.

- [ ] **Step 2: Write the Ember Vein section**

Create `docs/story/bestiary/act-i.md` starting with:

```markdown
# Act I Bestiary

Enemies encountered during Act I: Ember Vein, Fenmother's Hollow,
and the Overworld between Valdris and the Hollow. See
[README.md](README.md) for type rules, stat formulas, and reward
calculations.

---

## Ember Vein (Floors 1–4)

Recommended party level: 1–8. First dungeon — every enemy teaches a
core mechanic.
```

Then add the enemy table. Use this exact column format:

```markdown
| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
```

Populate all 10 Ember Vein enemies (8 regular + 1 unique + 1
mini-boss). The Vein Guardian boss goes in the Boss Notes subsection
below the table.

**Boss Notes format** (for Vein Guardian and Ember Drake):

```markdown
### Ember Drake (Mini-Boss)

- **Phase:** Single phase
- **Behavior:** Fast, aggressive. Teaches full-party coordination.
- **Abilities:** Flame Breath (cone AoE, 1-turn charge), Tail Swipe
  (single target), Pounce (back-row target)
- **Strategy:** Defend during Flame Breath, focus physical damage.
  Drake Fang consumable deals 500 bonus damage.

### Vein Guardian (Boss)

- **HP:** 6,000 (per dungeons-world.md)
- **Phase 1 (6,000–3,000 HP):** Two arms, slow heavy attacks.
  - Crystal Slam: telegraphed single-target physical
  - Ember Pulse: AoE magic, 1-turn charge
- **Phase 2 (below 3,000 HP):** Arms destroyed, core exposed.
  - Reconstruct: regenerates 300 HP per turn
  - Ember Pulse rate increases
- **Strategy:** Destroy arms first, then burn core before Reconstruct
  outheals your damage. Drake Fang deals 500 bonus damage.
```

- [ ] **Step 3: Write the Fenmother's Hollow section**

Add the Fenmother's Hollow section below Ember Vein. Include the
act boundary note from the spec (Section 9.2). Populate these 9
enemies:

| Name | Family | Tier | Lv | Type | Threat |
|------|--------|------|----|------|--------|
| Marsh Serpent | Serpent | 1 | 6 | Beast | Low |
| Bog Leech | Leech | 1 | 7 | Beast | Low |
| Drowned Bones | Dead | 2 | 7 | Undead | Low |
| Swamp Lurker | Lurker | 1 | 8 | Beast | Standard |
| Ley Jellyfish | Jellyfish | 1 | 8 | Elemental | Standard |
| Polluted Elemental | Elemental | 1 | 9 | Elemental | Standard |
| Corrupted Spawn | Serpent | 2 | 10 | Beast | Standard |
| *Drowned Sentinel* | — | — | 10 | Construct | Dangerous |
| *Corrupted Fenmother* | — | — | 12 | Boss | Boss |

Compute stats using formulas at each enemy's level, with ±15% role
adjustments. Boss Notes for Drowned Sentinel and Corrupted Fenmother.
The Fenmother entry must reference the cleansing mechanic from
dungeons-world.md: non-lethal fight, 4 waves of adds after 0 HP.

- [ ] **Step 4: Write the Overworld Act I section**

Add the Overworld section. Populate these 6 enemies:

| Name | Family | Tier | Lv | Type | Threat |
|------|--------|------|----|------|--------|
| Plains Hare | Hare | 1 | 1 | Beast | Trivial |
| Thornback Beetle | Beetle | 1 | 3 | Beast | Low |
| Road Bandit | Bandit | 1 | 4 | Humanoid | Low |
| Forest Sprite | Sprite | 1 | 4 | Spirit | Low |
| Wild Boar | Boar | 1 | 5 | Beast | Standard |
| Wayward Wolf | Wolf | 1 | 6 | Beast | Standard |

No boss notes needed — all regular encounters.

- [ ] **Step 5: Add the Act I summary section**

```markdown
## Act I Summary

- **Total:** 25 enemies (20 regular + 1 unique + 2 mini-bosses + 2 bosses)
- **Type coverage:** Beast (11), Undead (3), Construct (1), Spirit (3),
  Elemental (4), Humanoid (1), Boss (2)
- **Threat spread:** Trivial (4), Low (10), Standard (6), Dangerous (3),
  Boss (2)
- **Level range:** 1–12
- **Families started:** 19 (see palette-families.md)
```

- [ ] **Step 6: Verify stat blocks against combat formulas**

Spot-check at least 3 enemies:

1. **Ley Vermin (Lv 1):** Edren (ATK 18) should deal
   floor(18²/6 - Vermin.DEF) damage. With DEF ~6: floor(54-6)=48.
   Vermin HP ~33. One-hit kill from Edren. Correct for tutorial.

2. **Polluted Elemental (Lv 9):** Check Frost weakness — party's
   Frost spell at this level should deal bonus damage. Verify the
   element is listed in the Weak column.

3. **Vein Guardian (Lv 12, Boss):** Verify HP = 6,000 matches
   dungeons-world.md. Verify boss-type immunities (Death, Petrify,
   Stop, Sleep) are in Status Immunities column.

- [ ] **Step 7: Commit**

```bash
git add docs/story/bestiary/act-i.md
```
Commit message: `docs(shared): populate Act I bestiary (25 enemies across 3 areas)`

---

## Chunk 3: Palette-Swap Families

### Task 3: Create palette-families.md with Act I family definitions

**Files:**
- Create: `docs/story/bestiary/palette-families.md`
- Reference: `docs/story/bestiary/README.md` (tier system)
- Reference: `docs/story/bestiary/act-i.md` (base enemy stats)

- [ ] **Step 1: Write the palette-families header**

```markdown
# Palette-Swap Families

Each family is a base creature design with 2–4 variants at increasing
power levels. See [README.md](README.md) Section 7 for tier rules,
stat derivation, and naming conventions.

> **Status:** Act I families defined (Tier 1 only). Higher tiers will
> be populated in Sub-projects 2–4 as those act files are created.

---
```

- [ ] **Step 2: Define all 19 Act I families**

For each family, create an entry like this:

```markdown
## Vermin Family

**Base:** Ley Vermin (Lv 1, Beast, Trivial)
**Planned Tiers:** 4

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Ley Vermin | 1 | Beast | — | Bite | Trivial |
| 2 | Cave Vermin | 10 | Beast | — | +Rabid Frenzy (2-hit) | Low |
| 3 | Blight Vermin | 24 | Beast | Weak→Spirit | +Plague Bite (Poison) | Standard |
| 4 | Pallor Vermin | 38 | Pallor | Weak→Spirit, Resist→Void | +Despair Screech (AoE) | Dangerous |
```

Create all 19 families. For families where only Tier 1 exists in
Act I, include placeholder rows for Tiers 2–4 with "TBD" in the
Name column and the target level range.

The 19 families are: Vermin, Mite, Dead, Crystal, Shade, Warden,
Wisp, Drake, Serpent, Leech, Lurker, Jellyfish, Elemental, Hare,
Beetle, Bandit, Sprite, Boar, Wolf.

**Design each family's higher tiers thoughtfully:**
- Where does Tier 2 appear? (Act II dungeon or overworld?)
- What ability does it gain?
- What element shift makes sense for Tier 3?
- Does Tier 4 become Pallor-type? (Not all families need Tier 4)

- [ ] **Step 3: Commit**

```bash
git add docs/story/bestiary/palette-families.md
```
Commit message: `docs(shared): define 19 Act I palette-swap families with tier projections`

---

## Chunk 4: Cross-Reference Updates

### Task 4: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md` (lines 46–65)

- [ ] **Step 1: Add bestiary to Repository Layout table**

Add a row after the `docs/plans/` entry:

```markdown
| `docs/story/bestiary/` | Enemy bestiary — stat tables, type rules, families |
```

- [ ] **Step 2: Add bestiary to Where to Add Code table**

Add a row after the `Game data (JSON)` entry:

```markdown
| Enemy data | `docs/story/bestiary/` |
```

- [ ] **Step 3: Commit**

```bash
git add AGENTS.md
```
Commit message: `chore(shared): add bestiary to AGENTS.md repository layout`

---

### Task 5: Update pod-dev skill

**Files:**
- Modify: `.claude/skills/pod-dev/SKILL.md` (line ~131, after combat-formulas.md)

- [ ] **Step 1: Add bestiary reference**

After the `combat-formulas.md` line (line 131), add:

```markdown
- [`docs/story/bestiary/README.md`](../../../docs/story/bestiary/README.md) -- Enemy bestiary: 8 types, stat scaling formulas, bounded-growth rewards, palette-swap families. Per-act stat tables in subdirectory.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/pod-dev/SKILL.md
```
Commit message: `chore(shared): add bestiary reference to pod-dev skill`

---

### Task 6: Update story-designer skill

**Files:**
- Modify: `.claude/skills/story-designer/SKILL.md` (lines 128–136)

- [ ] **Step 1: Update file naming convention**

Replace the single `enemies.md` line:

```markdown
- `docs/story/enemies.md` — complete bestiary
```

with:

```markdown
- `docs/story/bestiary/README.md` — bestiary index, type rules, scaling formulas
- `docs/story/bestiary/act-i.md` — Act I enemy stat tables
- `docs/story/bestiary/palette-families.md` — base → variant mappings
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/story-designer/SKILL.md
```
Commit message: `chore(shared): update story-designer skill with bestiary directory`

---

### Task 7: Update canonical-verifier agent

**Files:**
- Modify: `.claude/skills/story-review-loop/agents/canonical-verifier.md` (lines 20–28)

- [ ] **Step 1: Add enemy canonical source**

After the `Events/flags: docs/story/events.md` line, add:

```markdown
   - Enemies/bestiary: docs/story/bestiary/README.md (rules),
     docs/story/bestiary/act-i.md (Act I stat tables)
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/story-review-loop/agents/canonical-verifier.md
```
Commit message: `chore(shared): add bestiary to canonical-verifier agent sources`

---

### Task 8: Update gap analysis doc

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (lines 86–115, lines 476–483)

- [ ] **Step 1: Update Gap 1.3 status and files**

Change line 88 from:
```markdown
**Status:** MISSING
```
to:
```markdown
**Status:** PARTIAL
```

Change line 90 from:
```markdown
**Files:** None yet (create `docs/story/enemies.md`)
```
to:
```markdown
**Files:** `docs/story/bestiary/README.md`, `docs/story/bestiary/act-i.md`, `docs/story/bestiary/palette-families.md`
```

Add after the Depends On line:
```markdown
**Completed (partial):** 2026-03-22 — Foundation + Act I (25 enemies)
```

Check off any items in the What's Needed list that are now complete:
- [x] Complete stat sheet template
- Partially check off the per-enemy data items (only Act I filled)

- [ ] **Step 2: Add progress tracking row**

Add to the Progress Tracking table at the bottom:

```markdown
| 2026-03-22 | 1.3 Enemy Bestiary | MISSING → PARTIAL. Template, type rules, scaling formulas, reward system, 25 Act I enemies, 19 palette families. | <commit-sha> |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
Commit message: `docs(shared): update Gap 1.3 status MISSING → PARTIAL`

---

## Chunk 5: Verification and Push

### Task 9: Final verification

**Files:**
- Read: all created/modified files

- [ ] **Step 1: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Both must pass. This is a docs-only change so failures would indicate
a pre-existing issue, but verify anyway.

- [ ] **Step 2: Cross-reference verification**

Verify these consistency points:

1. Vein Guardian HP in act-i.md = 6,000 (matches dungeons-world.md)
2. Corrupted Fenmother HP in act-i.md = 18,000 (matches dungeons-world.md)
3. Drowned Sentinel HP in act-i.md = 4,000 (matches dungeons-world.md)
4. Ember Drake HP in act-i.md = 1,500 (matches dungeons-world.md)
5. All Undead enemies have Poison + Death in Status Immunities
6. All Construct enemies have Poison + Sleep + Confusion + Berserk +
   Despair in Status Immunities
7. All Spirit enemies have Poison + Petrify in Status Immunities
8. All Elemental enemies have Petrify in Status Immunities
9. All Boss-type enemies have Death + Petrify + Stop + Sleep in
   Status Immunities
10. Gold and Exp values match logistic formulas × threat multiplier
    (spot-check 3 enemies)
11. README.md formulas match spec exactly
12. All 5 cross-reference files updated

- [ ] **Step 3: Push**

The branch `feature/next-gap-2` should already be checked out (created
at session start). Verify with `git branch --show-current` before pushing.

```bash
git push -u origin feature/next-gap-2
```

- [ ] **Step 4: Handoff**

Print: "Bestiary foundation complete. Next step: run `/create-pr` to
open a PR targeting main, then `/pr-review-response <PR#>` to
orchestrate review."
