# Bestiary Interlude Implementation Plan (Gap 1.3, Sub-project 2b)

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate interlude.md with 52 Interlude enemies across 6 dungeons,
introduce the Pallor Infection mechanic, add 4 new families, and update
~15 existing families with Tier 3/4 entries.

**Architecture:** Pure documentation pass — rewrite interlude.md from TBD
placeholder to full stat tables with Pallor Infection rules, update
palette-families.md, update CONTINUATION.md and gap tracker.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-22-bestiary-interlude-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/interlude.md` | Rewrite | Full Interlude enemy stat tables (52 entries) + Pallor Infection rules |
| `docs/story/bestiary/palette-families.md` | Modify | Add 4 new families, Tier 3/4 for ~15 existing |
| `docs/story/bestiary/CONTINUATION.md` | Modify | Update Sub-project 2b status |
| `docs/analysis/game-design-gaps.md` | Modify | Check off Interlude items in Gap 1.3 |

---

## Chunk 1: Interlude Stat Tables

### Task 1: Populate interlude.md with all 52 enemies

**Files:**
- Rewrite: `docs/story/bestiary/interlude.md`
- Reference: `docs/story/bestiary/README.md` (formulas, types)
- Reference: `docs/story/dungeons-world.md` (Rail Tunnels, Axis Tower bosses)
- Reference: `docs/story/dungeons-city.md` (Catacombs, Corrund, Caldera, Ironmark)
- Reference: `docs/superpowers/specs/2026-03-22-bestiary-interlude-design.md`

- [ ] **Step 1: Compute base stats for all 52 enemies**

Use the formulas from README.md at each enemy's level, then apply
role adjustments. Same process as act-i.md and act-ii.md.

Stat formulas:
```
HP   = floor(level² × 1.8 + level × 12 + 20)
MP   = floor(level × 3.5)  (0 for physical-only, 0 for ALL Constructs)
ATK  = floor(level × 1.6 + 8)
DEF  = floor(level × 1.2 + 5)
MAG  = floor(level × 1.4 + 6)
MDEF = floor(level × 1.0 + 4)
SPD  = floor(level × 0.8 + 8)
```

Reward formulas:
```
base_gold(level) = floor(10000 / (1 + 824 × e^(-0.0754 × level)))
base_exp(level)  = floor(30000 / (1 + 1188 × e^(-0.0696 × level)))
```
Multiply by threat: Trivial ×0.15, Low ×0.35, Standard ×0.60,
Dangerous ×1.0, Rare ×1.5, Boss = hand-tuned.

Role adjustments:
- Swarm: HP up to -32%, ATK -10%
- Glass cannon: ATK +15%, DEF/HP up to -28%
- Caster: MAG +15%, ATK up to -23%, MDEF +10%
- Tank: DEF +15%, HP +10%, SPD up to -22%
- Balanced: no adjustment

- [ ] **Step 2: Write the file header and Pallor Infection section**

Rewrite `docs/story/bestiary/interlude.md` starting with:

```markdown
# Interlude Bestiary

Enemies encountered during the Interlude: Rail Tunnels, Corrund
Undercity, Valdris Crown Catacombs, Caldera Undercity, Axis Tower,
and Ironmark Citadel Dungeons. See [README.md](README.md) for type
rules, stat formulas, and reward calculations.

**Total:** 52 enemies across 6 dungeons

---

## Pallor Infection Mechanic

The Interlude introduces mid-combat Pallor infection. Infection
sources in encounters can convert normal enemies to Pallor-type
during battle.
```

Then add the full Pallor Infection rules from spec Section 3:
- 4 source types table (Nest, Seep, Wisp, Soldier)
- 3-step conversion process
- Immunity rules table (Constructs immune)
- Infection density by dungeon table (30%→75%)
- 3 scripted set-piece descriptions

**IMPORTANT:** Copy the spec's infection mechanic verbatim for the
conversion process and immunity rules. These are gameplay rules that
must be precise.

- [ ] **Step 3: Write Rail Tunnels section (10 enemies)**

Enemies from spec Section 4.1:

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Rail Sentry | Sentry | 1 | 18 | Construct | Low | Balanced |
| Forge Phantom | Shade | 2 | 20 | Spirit | Standard | Caster |
| Pallor Nest | — (source) | — | 20 | Pallor | Standard | Infection source |
| Grey Mite | — (spawned) | — | 18 | Pallor | Trivial | Swarm (spawned) |
| Steam Elemental | Elemental | 3 | 20 | Elemental | Standard | Caster |
| Tunnel Vermin | Vermin | 3 | 22 | Beast | Standard | Balanced |
| Pipe Wraith | Wraith | 1 | 20 | Spirit | Standard | Caster |
| Grey Mite Swarm | — (unique) | — | 20 | Pallor | Standard | Dense swarm |
| *Corrupted Boring Engine* | — | — | 22 | Construct | Dangerous | Mini-boss |
| *The Ironbound* | — | — | 24 | Boss | Boss | Boss |

Elemental profiles:
- Constructs (Rail Sentry, Boring Engine): Weak→Storm
- Spirits (Forge Phantom, Pipe Wraith): Weak→Ley
- Elemental (Steam Elemental): Weak→Frost, Absorbs→Flame
- Pallor (Nest, Mites): Weak→Spirit, Immune→Despair

Boss notes for Ironbound and Boring Engine per spec Section 7.1.
Use Steal/Drop format (separate lines). Reference dungeons-world.md
as authoritative for exact mechanics.

Include the **"The Wave Hits"** scripted set-piece description after
the stat table (spec Section 3.5, set-piece #1).

- [ ] **Step 4: Write Corrund Undercity section (6 enemies)**

Enemies from spec Section 4.2. Include Pallor Seep and Pallor Wisp
as infection sources. Sewer Rat is Hare family Tier 2 (biome variant).

- [ ] **Step 5: Write Valdris Crown Catacombs section (10 enemies)**

Enemies from spec Section 4.3. Include both escape encounters
(minimal, Restless Dead only) and return visit encounters. Note the
Drowned Sentinel reappearance from Fenmother. Tomb Guardian and
Royal Wraith are NEW families.

Boss notes for The Undying Warden per spec Section 7.4. Note HP
as placeholder 8,000 — must be resolved with user before finalizing.

- [ ] **Step 6: Write Caldera Undercity section (8 enemies)**

Enemies from spec Section 4.4. Pallor Mite is a boss spawn only
(NOT a Mite family tier). Include Pallor Nest as infection source
in deeper tunnels.

Boss notes for Pallor Nest Mother per spec Section 7.3. Include
Kerra guest NPC stats.

- [ ] **Step 7: Write Axis Tower section (11 enemies)**

Enemies from spec Section 4.5. This is the "army has fallen"
dungeon — 60% Pallor source encounters. Compact Officer (Soldier
Tier 2), not "Compact Guard." Pallor Soldier is Soldier Tier 4.

Include **"The Garrison Falls"** scripted set-piece (spec Section
3.5, set-piece #2).

Boss notes for General Kole per spec Section 7.2.

- [ ] **Step 8: Write Ironmark Citadel section (7 enemies)**

Enemies from spec Section 4.6. 75% Pallor source encounters —
nearly everything is corrupted. Multiple Tier 4 Pallor variants
(Warden, Shade, Revenant, Wolf).

Include **"The Last Holdout"** scripted set-piece (spec Section
3.5, set-piece #3).

- [ ] **Step 9: Write the Interlude Summary section**

```markdown
## Interlude Summary

- **Total:** 52 enemies across 6 dungeons
- **Type distribution:** Pallor (~40–45%), Beast (15%),
  Construct (15%), Spirit (12%), Undead (8%), Humanoid (8%),
  Elemental (5%)
- **Pallor presence:** 30% → 75% escalating
- **New families:** Guardian, Royal Wraith, Hound, Sentry (4)
- **New mechanic:** Pallor Infection (4 source types,
  3 scripted set-pieces, Construct immunity)
- **Tier 3 debuts:** Vermin, Shade, Elemental, Automata,
  Crawler, Sprite, Soldier, Dead
- **Tier 4 debuts:** Soldier, Shade, Warden, Dead, Bandit, Wolf
```

- [ ] **Step 10: Verify stat blocks**

Spot-check at least 5 enemies:

1. **Rail Sentry (Lv 18, Construct, Low):** Verify MP=0, 5 immunities,
   Gold/Exp match logistic × 0.35.

2. **Pallor Soldier (Lv 26, Pallor, Dangerous):** Verify Weak→Spirit,
   Immune→Despair+Death, Gold/Exp match × 1.0.

3. **The Ironbound (Lv 24, Boss):** Verify HP=22,000 matches
   dungeons-world.md. Boss immunities present.

4. **General Kole (Lv 28, Boss):** Verify HP=30,000 matches
   dungeons-world.md. Boss immunities present.

5. **Pallor Nest Mother (Lv 25, Boss):** Verify HP=6,000 matches
   dungeons-city.md. Immune to Despair (per-boss extension).

6. **Tomb Guardian (Lv 23, Construct):** Verify MP=0, 5 Construct
   immunities.

- [ ] **Step 11: Commit**

```bash
git add docs/story/bestiary/interlude.md
```
Commit message: `docs(shared): populate Interlude bestiary (52 enemies, Pallor Infection mechanic)`

---

## Chunk 2: Palette Family Updates

### Task 2: Add 4 new families to palette-families.md

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`
- Reference: spec Sections 5.1–5.3

- [ ] **Step 1: Add Guardian, Royal Wraith, Hound, and Sentry families**

Append after the existing Treant family (last Act II family). Use
the exact tier tables from spec Sections 5.1–5.3.

Key points:
- Guardian: 3 tiers, Construct throughout. Grey Guardian (Tier 3)
  is a DESIGNED Pallor Construct (not infected). Include the design
  note about "weapons of despair" concept.
- Royal Wraith: 3 tiers, Spirit→Spirit→Pallor. Commands other spirits.
- Hound: 3 tiers, Construct throughout. Grey Hound (Tier 3) is
  another designed Pallor Construct. Include foreshadowing note.

Tier 1 Element Shift = — (em dash) for all three.

- [ ] **Step 2: Commit**

```bash
git add docs/story/bestiary/palette-families.md
```
Commit message: `docs(shared): add 4 new Interlude families (Guardian, Royal Wraith, Hound, Sentry)`

---

### Task 3: Update existing families with Tier 3/4 entries

**Files:**
- Modify: `docs/story/bestiary/palette-families.md`
- Reference: spec Section 6

- [ ] **Step 1: Update ~15 existing families**

For each family in the spec's Section 6 table, add or update Tier 3
and/or Tier 4 entries in palette-families.md. Key updates:

**Level revisions (spec overrides projections):**
- Warden Tier 2: Lv 17 → Lv 22 (Catacombs placement)
- Wailing Dead (Dead Tier 3): Lv 26 → Lv 24 (Catacombs placement)

**New Tier entries to add:**
- Vermin Tier 3: Tunnel Vermin (Lv 22) — already projected as
  "Blight Vermin (Lv 24)" — rename and relevel
- Shade: add Forge Phantom as second Tier 2 variant (Lv 20, biome:
  Rail Tunnels). Add note like Bandit/Serpent/Wraith dual-variant.
- Elemental Tier 3: Steam Elemental (Lv 20)
- Automata Tier 2 (biome variants): Service Automata (Lv 20) and Corrupted Forge
  Construct (Lv 23) — two Tier 2 biome variants
- Crawler Tier 3: Grey Crawler (Lv 24)
- Sprite Tier 3: Heat Sprite (Lv 22) — renamed from Elder Sprite
- Soldier Tier 3: Elite Guard (Lv 26), Tier 4: Pallor Soldier (Lv 26)
- Sentry Tier 2: Forgewright Sentry (Lv 24)
- Bandit Tier 4: Pallor Brigand (Lv 26)
- Wolf Tier 4: Pallor Wolf (Lv 26)
- Dead Tier 4: Pallor Revenant (Lv 26)
- Warden Tier 4: Pallor Warden (Lv 26)
- Shade Tier 4: Pallor Shade (Lv 26)
- Leech Tier 2: Sewer Leech (Lv 20) in Corrund — check if already
  correct from Act II update
- Hare Tier 2: Sewer Rat (Lv 18) — verify or add

**Dual-variant notes needed for:**
- Shade family: Crypt Shade + Forge Phantom (two Tier 2 biome variants)
- Automata family: Service Automata + Corrupted Forge Construct
  (two Tier 2 biome variants)

**Important:** palette-families.md Mite family note says "they never
become Pallor-corrupted." Do NOT add Pallor Mite as a family tier.
The Pallor Mite in interlude.md is a boss-fight spawn only.

- [ ] **Step 2: Verify all updates**

Read palette-families.md and verify:
- No family has conflicting tier entries
- All dual-variant entries have explanatory notes
- Level revisions are applied
- Mite family remains un-Pallored

- [ ] **Step 3: Commit**

```bash
git add docs/story/bestiary/palette-families.md
```
Commit message: `docs(shared): update ~15 families with Interlude Tier 3/4 entries`

---

## Chunk 3: Cross-References and Tracking

### Task 4: Update CONTINUATION.md

**Files:**
- Modify: `docs/story/bestiary/CONTINUATION.md`

- [ ] **Step 1: Update status table**

Change Sub-project 2b row to:
```markdown
| **2b: Interlude** | COMPLETE | — (pending PR) | 52 | interlude.md, palette-families.md |
```

Update family count from 28 to 32 (28 + 4 new).

- [ ] **Step 2: Commit**

```bash
git add docs/story/bestiary/CONTINUATION.md
```
Commit message: `docs(shared): update CONTINUATION.md with Interlude progress`

---

### Task 5: Update gap analysis

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`

- [ ] **Step 1: Check off Interlude items**

In Gap 1.3 "What's Needed" checklist, check off:
- [x] Interlude enemies (Rail Tunnels, Axis Tower, city dungeons)

- [ ] **Step 2: Add progress tracking row**

```markdown
| 2026-03-22 | 1.3 Enemy Bestiary | PARTIAL update. Interlude enemies (52): Rail Tunnels, Corrund, Catacombs, Caldera, Axis Tower, Ironmark. Pallor Infection mechanic. 4 new families, ~15 Tier 3/4 updates. | <commit-sha> |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
Commit message: `docs(shared): update Gap 1.3 with Interlude bestiary progress`

---

## Chunk 4: Verification and Push

### Task 6: Final verification

- [ ] **Step 1: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 2: Cross-reference verification**

1. Ironbound HP = 22,000 (dungeons-world.md)
2. Kole HP = 30,000 (dungeons-world.md)
3. Nest Mother HP = 6,000 (dungeons-city.md)
4. All Construct enemies: MP=0, 5 status immunities
5. All Spirit enemies: Poison+Petrify immunities
6. All Pallor enemies: Weak→Spirit, Immune→Despair
7. All Boss enemies: Death+Petrify+Stop+Sleep+Confusion immunities
8. Gold/Exp match logistic formulas × threat (spot-check 3)
9. All 4 new families present in palette-families.md
10. All ~15 existing family updates applied
11. Pallor Infection rules complete and unambiguous
12. 3 scripted set-pieces documented
13. Infection density table present (30%→75%)
14. Formatting: em dash (—), en dash (–) consistent
15. Boss notes use Steal/Drop (not combined Drops)
16. Compact Officer (not Compact Guard) in Axis Tower
17. Pallor Mite is boss spawn only (not Mite family tier)
18. Undying Warden HP marked as placeholder

- [ ] **Step 3: Push**

Branch `feature/bestiary-interlude` should already be checked out.

```bash
git push -u origin feature/bestiary-interlude
```

- [ ] **Step 4: Handoff**

Print: "Interlude bestiary complete. Next step: run `/create-pr` to
open a PR targeting main, then `/pr-review-response <PR#>` to
orchestrate review."
