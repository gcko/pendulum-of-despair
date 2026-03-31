# GDD Overview Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the Game Design Document overview — a 2-3 page
entry-point document consolidating the game's pitch, systems, scope,
and document index.

**Architecture:** Documentation-only. Single file creation
(`docs/story/gdd-overview.md`) plus gap analysis update. All content
is synthesized from existing docs — no new design work.

**Tech Stack:** Markdown docs only. No code changes.

---

## Chunk 1: Create GDD and Update Gap Analysis

### Task 1: Create docs/story/gdd-overview.md

**Files:**
- Create: `docs/story/gdd-overview.md`

**Reference:** `docs/superpowers/specs/2026-03-31-gdd-overview-design.md`

This is the canonical GDD overview. It should be written in a clean,
scannable style — closer to a project brief than the detailed reference
docs (combat-formulas.md, save-system.md). Tables for data, short
paragraphs, links for deep dives. Dual audience: page 1 for
stakeholders, pages 2-3 for developers.

- [ ] **Step 1: Read the spec and source docs**

Read these files:
- `docs/superpowers/specs/2026-03-31-gdd-overview-design.md` (the spec — contains all content)
- `docs/story/outline.md` (verify act summaries)
- `docs/story/characters.md` (verify party member descriptions)
- `docs/story/bestiary/README.md` (verify enemy/boss counts)
- `docs/story/items.md` (verify item counts: 33 consumables, 72 materials, 26 key items)
- `docs/story/equipment.md` (verify: 56 weapons, 49 armor, 42 accessories)
- `docs/story/script/README.md` (verify script line count ~6,300)

- [ ] **Step 2: Write docs/story/gdd-overview.md**

Use the spec's 3-page structure exactly:

**Page 1 — The Pitch:**
- Elevator pitch (from spec Section 1)
- Genre & Platform (Godot 4.x, desktop, 320x180)
- Design Pillars (4 pillars from spec)
- Target Audience (13+, SNES JRPG fans, comparable titles)
- Thematic Core ("acceptance over victory," Pallor as Despair)

**Page 2 — The Game:**
- Act Structure table (6 rows: Act I through Epilogue)
- Party Members table (6 characters with role + one line)
- Core Gameplay Loop (ASCII diagram from spec)
- Combat Summary (ATB, 4-party, damage formulas, elements)
- Progression Summary (level 150, Ley Crystals, 3-layer growth)
- Key Systems (one line each: Forging, Save/Rest, Encounters, Dialogue)

**Page 3 — Scope & Reference:**
- Content Volume table (verified counts from Step 1)
- Estimated Playtime table (25-35h critical, 45-80h+ completionist)
- Session Structure (15min minimum, 1-2h typical, save-friendly)
- Platform & Accessibility (320x180, Godot, color-blind, Patience Mode)
- Document Index (organized by category, every docs/story/ file)

All internal links should use relative markdown links to sibling files
(e.g., `[combat-formulas.md](combat-formulas.md)`).

- [ ] **Step 3: Verify content counts against source docs**

Cross-check every number in the Content Volume table against the source
doc listed in the "Source" column. If any number doesn't match, fix it.

Key counts to verify:
- 33 consumables (items.md)
- 56 weapons, 49 armor, 42 accessories (equipment.md)
- 72 crafting materials (items.md)
- 26 key items (items.md)
- 204 regular enemies (bestiary/README.md)
- 31 bosses (bestiary/bosses.md)
- 32 palette families (bestiary/palette-families.md)
- 18 Ley Crystals (progression.md)
- ~6,300 script lines (script/README.md)
- 44 narrative scenes (script/README.md)

- [ ] **Step 4: Commit**

```bash
git add docs/story/gdd-overview.md
git commit -m "docs(story): add GDD overview document (gap 4.1)"
```

---

### Task 2: Update Gap Analysis Doc

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (Gap 4.1 status + progress table)

- [ ] **Step 1: Read the current Gap 4.1 section**

Read `docs/analysis/game-design-gaps.md` — find the 4.1 section
(around line 600) and the progress tracking table at the end.

- [ ] **Step 2: Update Gap 4.1 status**

- Change `**Status:** MISSING` to `**Status:** COMPLETE`
- Add `**Completed:** 2026-03-31` after the Depends On line
- Update `**Files:** None yet — target docs/story/gdd-overview.md`
  to `**Files:** docs/story/gdd-overview.md`
- Check off all checklist items (change `- [ ]` to `- [x]`)

- [ ] **Step 3: Add progress tracking row**

Add a new row to the Progress Tracking table:

```
| 2026-03-31 | 4.1 Core GDD Overview | MISSING → COMPLETE. 3-page entry-point document: elevator pitch, design pillars, target audience (13+, SNES JRPG fans), act structure, party members, core loop, combat/progression/systems summaries, content volume metrics (204 enemies, 31 bosses, 33 consumables, 56 weapons, 42 accessories, ~6,300 script lines), playtime estimates (25-35h critical, 45-80h+ completionist), session structure, platform/accessibility summary, complete document index. | — |
```

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(story): mark gap 4.1 GDD Overview as COMPLETE"
```

---

### Task 3: Cross-Reference Verification

**Files:**
- Read only (no edits expected)

- [ ] **Step 1: Verify gdd-overview.md links**

Check that every markdown link in gdd-overview.md points to an
existing file. The document should link to most files in docs/story/.

- [ ] **Step 2: Verify document index completeness**

Compare the Document Index section against the actual files in
`docs/story/`. Every .md file should appear in the index. If any
file is missing from the index, add it.

```bash
ls docs/story/*.md docs/story/bestiary/*.md docs/story/script/*.md | sort
```

Compare this list against the index entries.

- [ ] **Step 3: Verify git log**

```bash
git log --oneline -5
```

Should show: gdd-overview.md commit, gap analysis commit, spec commit.
