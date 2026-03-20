# Character Stat System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/progression.md` — the complete stat system
document covering stats, growth curves, Ley Crystals, milestone spikes,
and party join rules. Also add base stat tables to `docs/story/characters.md`.

**Architecture:** Pure documentation pass — two files modified/created.
Content transcribed from the spec with story-doc formatting. Cross-
references added to other story docs where stats interact with existing
systems (abilities.md, magic.md, events.md).

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-19-stat-system-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/progression.md` | Create | Complete stat system, growth curves, Ley Crystals, milestones |
| `docs/story/characters.md` | Modify | Add base stat tables to each character section |
| `docs/analysis/game-design-gaps.md` | Modify | Update gap 1.2 status to COMPLETE |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add progression.md reference |

---

## Chunk 1: Create progression.md and Update References

### Task 1: Create `docs/story/progression.md`

**Files:**
- Create: `docs/story/progression.md`
- Reference: `docs/superpowers/specs/2026-03-19-stat-system-design.md`

- [x] **Step 1: Create the file with all sections**

Create `docs/story/progression.md` by transcribing spec sections 2-7
into story-doc format. The document structure:

```
# Character Progression

> Header note: references to related docs

## Stat Definitions
  ### Core Stats
  ### Derived Stats
  ### Stat Caps
  ### Attack Resolution Order

## Character Growth
  ### Growth Rates Per Level
  ### Base Stats at Level 1
  ### Projected Milestones
  ### Party Join Level Rule
  ### Guest NPC Stats

## Equipment and Buff Rules

## Ley Crystal System
  ### Core Mechanics
  ### Crystal Leveling
  ### Crystal Catalog
    #### Standard Crystals
    #### Crystals with Negative Effects
    #### Special Crystals
  ### Crystal Availability by Act
  ### Crystal Design Notes

## Narrative Milestone Stat Spikes

## Integration Notes
  ### Magic System
  ### Abilities
  ### Damage Formula (Gap 1.1)
```

Transcription rules (same as music.md):
- Copy all tables, descriptions, and formulas from the spec
- Remove spec metadata (date, status, scope, gap reference)
- Remove section numbers from headings
- Add cross-references as relative links:
  - `[characters.md](characters.md)` for character profiles
  - `[abilities.md](abilities.md)` for ability scaling
  - `[magic.md](magic.md)` for spell formulas
  - `[events.md](events.md)` for Faint mechanic reference
  - `[music.md](music.md)` for Cael's Echo crystal music tie-in
  - `[dungeons-world.md](dungeons-world.md)` for crystal dungeon locations
- Add header block:

```markdown
# Character Progression

> This document defines the complete numerical foundation for all
> characters: stats, growth curves, Ley Crystals, and narrative
> milestone spikes. It is the primary reference for implementing
> character progression and balancing combat encounters.
>
> **Related docs:** [characters.md](characters.md) |
> [abilities.md](abilities.md) | [magic.md](magic.md) |
> [events.md](events.md) | [equipment.md](equipment.md) (Gap 1.5) |
> [enemies.md](enemies.md) (Gap 1.3)
```

- Include the open question about magic damage formula scaling
  (Section 10 of spec) as a clearly marked "Integration Note" that
  flags Gap 1.1 as a dependency
- Include the spec's computed milestone projection table with the
  formula used (`stat = base + growth * (level - 1)`)

- [x] **Step 2: Verify cross-references**

After creating the file:
1. Verify all relative links point to existing files (or note "(Gap X)"
   for files that don't exist yet)
2. Verify stat values in the growth rate table can reproduce the
   milestone projections using the formula
3. Verify Ley Crystal dungeon locations match dungeons-world.md and
   dungeons-city.md canonical names
4. Verify milestone spike events match events.md and outline.md
5. Verify ability percentage references match abilities.md

- [x] **Step 3: Commit**

```bash
git add docs/story/progression.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): add character progression system

8-stat system (HP/MP/ATK/DEF/MAG/MDEF/SPD/LCK), level cap 150,
HP cap 14999, MP cap 1499. Three progression layers: differentiated
growth per character, 18 Ley Crystals with 5 XP-based levels, and
12 narrative milestone stat spikes. Party join at average level - 1.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 2: Add base stat tables to characters.md

**Files:**
- Modify: `docs/story/characters.md`

Each of the 6 party member sections in characters.md needs a base stat
table added. Find each character's section and add the table after their
narrative description, before any act-by-act notes.

- [x] **Step 1: Read characters.md to find insertion points**

Read the file. Identify where each character's section starts. The
base stat table should be inserted after the character's personality/
role description paragraph and before any act-specific content.

- [x] **Step 2: Add stat tables for all 6 characters**

For each character, add a section like:

```markdown
**Base Stats (Level 1):**

| HP | MP | ATK | DEF | MAG | MDEF | SPD | LCK |
|----|----|----|-----|-----|------|-----|-----|
| 95 | 15 | 18 | 16 | 6 | 8 | 10 | 8 |

**Growth archetype:** Knight — highest HP and DEF growth. See
[progression.md](progression.md) for full growth curves and Ley
Crystal system.
```

Base stats per character (from spec section 4.2):

| Character | HP | MP | ATK | DEF | MAG | MDEF | SPD | LCK | Archetype |
|-----------|----|----|-----|-----|-----|------|-----|-----|-----------|
| Edren | 95 | 15 | 18 | 16 | 6 | 8 | 10 | 8 | Knight |
| Cael | 78 | 25 | 15 | 13 | 10 | 10 | 12 | 9 | Commander |
| Lira | 68 | 30 | 14 | 12 | 14 | 12 | 11 | 10 | Engineer |
| Torren | 62 | 40 | 10 | 9 | 16 | 14 | 9 | 7 | Sage |
| Sable | 58 | 20 | 13 | 8 | 8 | 10 | 18 | 16 | Thief |
| Maren | 50 | 55 | 6 | 6 | 22 | 18 | 8 | 5 | Archmage |

- [x] **Step 3: Commit**

```bash
git add docs/story/characters.md
cat > /tmp/commit-msg.txt << 'EOF'
docs(shared): add base stat tables to character profiles

Level 1 stats and growth archetypes for all 6 party members.
Cross-references progression.md for full growth curves.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 3: Update gap tracker and pod-dev skill

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`
- Modify: `.claude/skills/pod-dev/SKILL.md`

- [x] **Step 1: Update gap 1.2 status**

In `docs/analysis/game-design-gaps.md`, find gap 1.2 and:
- Change status from PARTIAL to COMPLETE
- Check off all completed items in the "What's Needed" list
- Add a row to the Progress Tracking table at the bottom:

```markdown
| 2026-03-20 | 1.2 Stat System | PARTIAL -> COMPLETE | <commit-sha> |
```

- [x] **Step 2: Add progression.md to pod-dev skill**

In `.claude/skills/pod-dev/SKILL.md`, find the story docs list and add:

```markdown
- [`progression.md`](../../../docs/story/progression.md) -- Character
  stat system: 8 stats, growth curves, 18 Ley Crystals, milestone spikes
```

Add after the `music.md` entry.

- [x] **Step 3: Note unblocked gaps**

After updating gap 1.2 to COMPLETE, check which downstream gaps are
now unblocked. Update their "Depends On" status if 1.2 was their only
blocker. The following gaps depend on 1.2:

- 1.1 (Damage Formulas) — depends on 1.2 ONLY. Now unblocked.
- 1.5 (Equipment) — depends on 1.2 and 1.6. Still blocked by 1.6.
- 2.1 (XP Curve) — depends on 1.2 and 1.3. Still blocked by 1.3.
- 2.2 (ATB Mechanics) — depends on 1.2 ONLY. Now unblocked.

- [x] **Step 4: Commit**

```bash
git add docs/analysis/game-design-gaps.md .claude/skills/pod-dev/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): update gap tracker and pod-dev for stat system completion

Gap 1.2 (Stat System): PARTIAL -> COMPLETE. Unblocks: 1.1 (Damage
Formulas), 2.2 (ATB Mechanics).
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 4: Final Verification and Push

- [x] **Step 1: Adversarial verification**

Run the story-designer verification checks:

1. **Numeric consistency:** Recompute 3 milestone projections from the
   formula `stat = base + growth * (level - 1)` and verify they match
   the progression.md table. Pick: Edren HP at level 50, Sable LCK at
   level 70, Maren MAG at level 150.

2. **Cross-reference check:** Verify 3 Ley Crystal dungeon locations
   match their canonical names in dungeons-world.md or dungeons-city.md.
   Pick: Ember Shard (Ember Vein Floor 4), Quicksilver (Corrund
   Undercity), Ward Stone (Highcairn Monastery).

3. **Milestone spike check:** Verify 2 narrative milestone events match
   events.md. Pick: Edren's siege survival (flag
   `carradan_assault_begins`), Torren's Fenmother spirit-bond.

4. **Existing doc consistency:** Verify Thornveil counter percentages
   in progression.md match abilities.md (20% base, 40% evolved, 15%
   Lira device).

- [x] **Step 2: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (documentation-only changes).

- [x] **Step 3: Push**

```bash
git push
```
