# Combat Formulas Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/combat-formulas.md` — the canonical combat
formula document — and update existing docs (magic.md, progression.md,
dungeons-world.md, game-design-gaps.md) to reflect the new formulas and
boss HP values.

**Architecture:** Pure documentation pass — one new file, four files
modified. Content transcribed from the spec with story-doc formatting.
Cross-references added where formulas interact with existing systems.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-21-combat-formulas-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/combat-formulas.md` | Create | Canonical combat formula reference |
| `docs/story/magic.md` | Modify | Replace placeholder damage/heal formulas (lines 109-110, 1454) |
| `docs/story/progression.md` | Modify | Update Integration Notes section (~lines 306-327) |
| `docs/story/dungeons-world.md` | Modify | Update boss HP values (15+ line edits across file) |
| `docs/analysis/game-design-gaps.md` | Modify | Gap 1.1 status MISSING -> COMPLETE |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add combat-formulas.md reference |

---

## Chunk 1: Create combat-formulas.md

### Task 1: Create `docs/story/combat-formulas.md`

**Files:**
- Create: `docs/story/combat-formulas.md`
- Reference: `docs/superpowers/specs/2026-03-21-combat-formulas-design.md`

- [ ] **Step 1: Create the file with all sections**

Create `docs/story/combat-formulas.md` by transcribing spec sections 3-10
into story-doc format. The document structure:

```
# Combat Formulas

> Header note: references to related docs

## Physical Damage
  - Formula, divisor explanation, worked examples table
  - Damage floor (1), damage cap (14,999)

## Magic Damage
  - Formula, divisor explanation, worked examples table
  - Elemental modifier application point

## Healing
  - Formula, 0.8 multiplier rationale, worked example

## Damage Variance
  - Formula, range description

## Critical Hits
  - 2x multiplier, physical-only, resolution timing

## Ability Multipliers
  ### Physical Ability Multiplier Tiers
  - Tier table (1.0 to 3.0)
  ### Buff-Granted Multipliers
  - Overcharge, Press Forward, Resonance stacking rules
  ### Special: Shiv DEF Ignore
  - DEF halving mechanic
  ### Custom-Formula Abilities
  - Shatter Guard, Annulment, Greyveil

## Buff & Debuff Interaction
  - Stat modification timing (before formula)
  - Interaction table

## Elemental System
  - General modifier table (weakness/resistance/immunity/absorb)
  - Element matchup wheel
  - Physical elemental attacks

## Status Effect Accuracy
  - Two-stage resolution formula
  - Worked examples at key milestones
  - Boss immunity patterns

## Combat Resolution Order
  ### Physical Attack Resolution (8 steps)
  ### Magic Damage Resolution (7 steps)
  ### Status Spell Resolution (5 steps)
  ### Healing Resolution (3 steps)

## Combat Interactions & Hidden Synergies
  ### Tier System Overview
  ### Tier 1: Telegraphed
  ### Tier 2: Experimental
  ### Tier 3: Hidden
  ### Implementation Architecture

## Boss HP Scaling
  ### Revised Boss HP Table
  ### Regular Enemy HP by Act
  ### Multi-Hit Rules
  ### AoE Rules
```

Transcription rules:
- Copy all tables, formulas, and descriptions from the spec
- Remove spec metadata (date, status, scope, gap reference)
- Remove section numbers from headings (e.g., "3.1 Physical Damage"
  becomes "## Physical Damage")
- Add cross-references as relative links:
  - `[progression.md](progression.md)` for stat values
  - `[magic.md](magic.md)` for spell power tiers and elemental chart
  - `[abilities.md](abilities.md)` for ability definitions
  - `[characters.md](characters.md)` for character archetypes
  - `[dungeons-world.md](dungeons-world.md)` for boss encounters
  - `[events.md](events.md)` for faint/wipe mechanics
- Add header block:

```markdown
# Combat Formulas

> This document defines every formula the combat engine needs to
> resolve damage, healing, status effects, and special interactions.
> It is the primary reference for implementing combat and balancing
> encounters.
>
> **Related docs:** [progression.md](progression.md) |
> [magic.md](magic.md) | [abilities.md](abilities.md) |
> [characters.md](characters.md) | [dungeons-world.md](dungeons-world.md) |
> [events.md](events.md) | enemies.md (Gap 1.3)
```

- The Boss HP Scaling section should note: "These HP values are initial
  targets. Final tuning happens during the bestiary pass (Gap 1.3)."
- The Combat Interactions section should note: "The examples below
  illustrate the system. The full interaction list will be defined
  during the bestiary and ability passes."
- Include the "Existing Formula Replacements" note from spec Section 11
  as a brief "Integration Notes" section at the bottom, referencing
  what changed in magic.md and progression.md.

- [ ] **Step 2: Verify cross-references and math**

After creating the file:
1. Verify all relative links point to existing files (or note Gap for
   files that don't exist yet)
2. Recompute 3 physical damage examples from the formula:
   - Edren Lv1 (ATK 18, DEF 5): (324/6) - 5 = 49
   - Edren Lv70 (ATK 175, DEF 60): (30625/6) - 60 = 5044
   - Edren Lv150 Oathkeeper (ATK 255, mult 1.5, DEF 80):
     (65025*1.5/6) - 80 = 16176 -> capped 14999
3. Recompute 2 magic damage examples:
   - Maren Lv18 Kindlepyre (MAG 53, power 32, MDEF 20):
     (53*32/4) - 20 = 404
   - Maren Lv150 Ley Ruin (MAG 255, power 100, MDEF 80):
     (255*100/4) - 80 = 6295
4. Verify elemental matchup table matches magic.md (lines 67-76):
   Flame > Frost, Frost > Storm, Storm > Earth, Earth > Flame
5. Verify ability percentages match abilities.md:
   - Shiv: 50% DEF ignore
   - Overcharge: +50% damage + Storm element
   - Riposte: counter at 1.5x
6. Verify status effect base rates match magic.md:
   - Poison 75%, Sleep 70%, Confusion 65%, Silence 70%, Petrify 50%

- [ ] **Step 3: Commit**

```bash
git add docs/story/combat-formulas.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): add combat formulas document (Gap 1.1)

Physical damage (ATK^2/6 - DEF), magic damage (MAG*power/4 - MDEF),
14999 damage cap, FF6-style variance, three-tier combat interactions,
ability multiplier tiers, and boss HP scaling targets.
EOF
git commit -F /tmp/commit-msg.txt
```

---

## Chunk 2: Update Existing Docs

### Task 2: Update magic.md placeholder formulas

**Files:**
- Modify: `docs/story/magic.md` (lines 109-110, 1454)

- [ ] **Step 1: Read magic.md to find all formula locations**

Read the file and search for all instances of:
- `magic_damage = max(1, (caster.mag * spell.power) - target.mdef) + random(-3, 3)`
- `heal_amount = (caster.mag * spell.power * 0.8) + random(0, 5)`

There are 3 known locations: lines 109, 110, and 1454.

- [ ] **Step 2: Replace the formulas**

At each location, replace the old formula with the new one and add a
cross-reference to combat-formulas.md:

**Line 109 replacement:**
Old: `magic_damage = max(1, (caster.mag * spell.power) - target.mdef) + random(-3, 3)`
New: `magic_damage = min(14999, max(1, (caster.mag * spell.power) / 4 - target.mdef) * element_mod * variance)` where `variance = random_int(240, 255) / 256`. See [combat-formulas.md](combat-formulas.md) for full resolution order.

**Line 110 replacement:**
Old: `heal_amount = (caster.mag * spell.power * 0.8) + random(0, 5)`
New: `heal_amount = min(14999, (caster.mag * spell.power * 0.8) * variance)` where `variance = random_int(240, 255) / 256`. See [combat-formulas.md](combat-formulas.md).

**Line 1454 replacement:**
Same as line 109 — replace the formula reference and add the
combat-formulas.md cross-reference.

- [ ] **Step 3: Verify no other formula references remain**

Search magic.md for any remaining `random(-3` or `random(0, 5)` to
ensure all placeholder formulas were caught.

- [ ] **Step 4: Commit**

```bash
git add docs/story/magic.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): update magic.md with canonical combat formulas

Replace placeholder damage formula (MAG*power - MDEF + random) with
canonical formula (MAG*power/4 - MDEF * element * variance). Replace
placeholder healing formula similarly. Add combat-formulas.md cross-refs.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 3: Update progression.md Integration Notes

**Files:**
- Modify: `docs/story/progression.md` (~lines 306-327)

- [ ] **Step 1: Read the Integration Notes section**

Read progression.md from the "### Magic System" heading through the end
of the WARNING block. This section currently flags the scaling problem
and suggests adding a divisor.

- [ ] **Step 2: Update the WARNING to reference the resolution**

Replace the WARNING block with a resolved note:

Old (approximate):
```
> **WARNING (Gap 1.1):** Gap 1.1 MUST add a divisor...
```

New:
```
> **Resolved (Gap 1.1):** The divisor approach was adopted. The canonical
> magic damage formula is now: `max(1, (MAG * spell_power) / 4 - MDEF)
> * element_mod * variance`. See [combat-formulas.md](combat-formulas.md)
> for the complete formula reference, including the physical damage
> formula, critical hits, ability multipliers, and combat interactions.
```

- [ ] **Step 3: Update the damage projection table**

Replace the existing projection table that shows unscaled numbers
(3,850 / 9,490 / 25,500) with the new `/4` values:

| Level | Maren MAG | Spell Tier | Power | Raw Damage | After 60 MDEF |
|-------|-----------|-----------|-------|------------|---------------|
| 50 | 110 | Tier 2 | 35 | 963 | 903 |
| 70 | 146 | Tier 3 | 65 | 2,373 | 2,313 |
| 150 | 255 | Tier 4 | 100 | 6,375 | 6,315 |

(Computed: 110*35/4=963, 146*65/4=2373, 255*100/4=6375)

- [ ] **Step 4: Remove the "Options to resolve" list**

The three options (add divisor, reduce spell power, increase enemy MDEF)
are no longer open questions — the divisor approach was chosen. Remove
the options list.

- [ ] **Step 5: Commit**

```bash
git add docs/story/progression.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): resolve magic damage scaling warning in progression.md

Replace Gap 1.1 WARNING with resolved note referencing combat-formulas.md.
Update damage projection table with /4 divisor values. Remove open
question options list.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 4: Update boss HP values in dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (15+ line edits)

- [ ] **Step 1: Read and locate all boss HP entries**

Search dungeons-world.md for each boss name from the spec's HP table.
For each boss, find the line with the HP value in the encounter table.

Known locations from grep:
- Vein Guardian: line 334 (3,000 -> 6,000)
- The Forge Heart: line 4165 (10,000 -> 35,000)
- The Frost Warden: line 4407 (11,000 -> 38,000)
- The Ashen Ram: line 4652 (10,000 -> 25,000)
- The Ley Leech: line 4716 (9,000 -> 24,000)
- The Pallor Hollow: line 4780 (11,000 -> 40,000)

Also search for bosses that may be referenced in text (not tables):
- Corrupted Fenmother: search for "8,000" near Fenmother references
- The Ironbound: search for "8,000" near Ironbound/Rail Tunnel
- General Kole: search for "12,000" near Kole/Axis Tower
- Archive Guardian: search for "10,000" near Archive/Wellspring
- The Grey Engine: search for "9,000" near Grey Engine/Corrund (9,000 -> 22,000)
- Vaelith: search for "20,000"
- Cael Phase 1: search for "15,000" near Cael/Convergence (15,000 -> 45,000)
- Cael Phase 2: may need to be added (new, 35,000 HP) where Cael fight is described
- Pallor Incarnate: search for "25,000"

For Cael Phase 2 (new, 35,000 HP) — this likely needs to be added
where the Cael boss fight is described.

- [ ] **Step 2: Update each boss HP value**

For each boss found in Step 1, replace the old HP with the new HP
from the spec table (Section 10.2). Use exact string matching to
avoid accidental edits.

After each edit, re-read the surrounding context (the nearest ##
heading to the next ## heading) to verify the HP change is consistent
with any prose that references the boss's HP or phase thresholds. For
example, if the Vein Guardian "Reconstructs at 50% HP," that threshold
changes from 1,500 to 3,000.

- [ ] **Step 3: Add a note about formula-driven HP values**

At the top of the encounter tables section (or in the document header
if one exists), add a brief note:

```markdown
> **Boss HP values** were calibrated against the combat formulas in
> [combat-formulas.md](combat-formulas.md). These are initial targets;
> final tuning happens during the bestiary pass (Gap 1.3).
```

- [ ] **Step 4: Verify all HP updates match the spec**

Re-grep for the old HP values to confirm none were missed. Then grep
for the new HP values to confirm they were applied correctly.

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): scale boss HP values to combat formula targets

Update boss HP across dungeons-world.md to match combat-formulas.md
scaling. Physical damage at endgame is 5,000-7,000 per hit; bosses
need proportionally larger HP pools for 3-5 minute fights.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 5: Update gap tracker and pod-dev skill

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`
- Modify: `.claude/skills/pod-dev/SKILL.md`

- [ ] **Step 1: Update gap 1.1 status**

In `docs/analysis/game-design-gaps.md`, find gap 1.1 and:
- Change status from MISSING to COMPLETE
- Add `**Completed:** 2026-03-21`
- Check off all completed items in the "What's Needed" list
- Add `**Files:** docs/story/combat-formulas.md`
- Update the "Blocking" line to show what's now unblocked

- [ ] **Step 2: Update downstream gap status**

After marking 1.1 COMPLETE, check downstream gaps:
- 1.3 (Bestiary): depends on 1.1 + 1.2. Both now COMPLETE. **Unblocked.**
- 1.4 (Items): depends on 1.1. **Unblocked.**
- 2.5 (Row/Position): depends on 1.1. **Unblocked.**
- 1.5 (Equipment): depends on 1.2 + 1.6. Still blocked by 1.6.

Update the "Depends On" fields for 1.3, 1.4, and 2.5 to note that
their dependencies are now resolved.

- [ ] **Step 3: Add progress tracking row**

Add to the Progress Tracking table:
```markdown
| 2026-03-21 | 1.1 Damage & Combat Formulas | MISSING -> COMPLETE. Physical (ATK^2/6), magic (MAG*power/4), 14999 cap. Unblocks 1.3, 1.4, 2.5. | <commit-sha> |
```

- [ ] **Step 4: Add combat-formulas.md to pod-dev skill**

In `.claude/skills/pod-dev/SKILL.md`, find the story docs list and add:

```markdown
- [`combat-formulas.md`](../../../docs/story/combat-formulas.md) --
  Combat formulas: physical/magic damage, healing, crits, elemental
  system, status accuracy, combat interactions, boss HP scaling
```

Add before the `progression.md` entry (alphabetical ordering).

- [ ] **Step 5: Commit**

```bash
git add docs/analysis/game-design-gaps.md .claude/skills/pod-dev/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): update gap tracker and pod-dev for combat formulas

Gap 1.1 (Damage & Combat Formulas): MISSING -> COMPLETE.
Unblocks: 1.3 (Bestiary), 1.4 (Items), 2.5 (Row/Position).
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 6: Final Verification and Push

- [ ] **Step 1: Adversarial verification**

Run the story-designer verification checks:

1. **Numeric consistency:** Recompute 3 damage values from the formula
   in combat-formulas.md and verify they match the tables.

2. **Cross-reference check:** Verify 3 cross-references:
   - combat-formulas.md elemental table matches magic.md (lines 67-76)
   - combat-formulas.md ability multipliers match abilities.md
     (Shiv = 50% DEF ignore, Riposte = 1.5x counter, Overcharge = +50%)
   - combat-formulas.md status base rates match magic.md
     (Poison 75%, Sleep 70%, Petrify 50%)

3. **Boss HP check:** Verify 5 boss HP values in dungeons-world.md
   match the combat-formulas.md table (one per act):
   - Vein Guardian (Act I): 6,000
   - General Kole (Act II): 30,000
   - The Grey Engine (Interlude): 22,000
   - The Frost Warden (Act III): 38,000
   - Pallor Incarnate (Final): 70,000

4. **Formula replacement check:** Verify magic.md no longer contains
   `random(-3, 3)` or `random(0, 5)` anywhere in the file.

5. **Gap tracker check:** Verify gap 1.1 status is COMPLETE and
   downstream gaps 1.3, 1.4, 2.5 show their dependencies are met.

- [ ] **Step 2: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (documentation-only changes).

- [ ] **Step 3: Push**

```bash
git push
```
