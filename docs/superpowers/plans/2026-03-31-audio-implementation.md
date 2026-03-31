# Audio Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the audio implementation document — SFX catalog, ambient
audio specs, and audio engine rules.

**Architecture:** Documentation-only. Single file creation
(`docs/story/audio.md`) plus gap analysis update. No cross-doc updates
needed — audio.md links to existing docs but doesn't modify them.

**Tech Stack:** Markdown docs only. No code changes.

---

## Chunk 1: Create Audio Doc and Update Gap Analysis

### Task 1: Create docs/story/audio.md

**Files:**
- Create: `docs/story/audio.md`

**Reference:** `docs/superpowers/specs/2026-03-31-audio-implementation-design.md`

This is the canonical audio implementation document — the sound
engineer/programmer's reference. music.md (composer's reference) stays
unchanged. Written in the same docs/story/ style as save-system.md and
accessibility.md.

- [ ] **Step 1: Read the spec and source docs**

Read these files:
- `docs/superpowers/specs/2026-03-31-audio-implementation-design.md` (the spec — contains ALL content)
- `docs/story/music.md` (verify jingle durations, crossfade rules, corruption stages, narrative silence)
- `docs/story/biomes.md` (verify corruption stage names: Early/Mid/Full)
- `docs/story/accessibility.md` (verify 8 SFX caption events match catalog)
- `docs/story/bestiary/README.md` (verify 8 enemy types for KO mapping)

- [ ] **Step 2: Write docs/story/audio.md**

Use the spec's structure:

```markdown
# Audio

> Sound effects, ambient audio, and audio engine rules. For music
> composition (tracks, leitmotifs, faction palettes, corruption
> evolution), see [music.md](music.md).

## 1. Master SFX Catalog
-- Spec Section 1. All ~51 SFX IDs in 4 tables:
-- 1.1 Combat SFX (18): hit, miss, critical, guard, heal, status,
--   5 KO variants (party + 4 enemy types), flee, victory, level-up,
--   2 boss onset. Include enemy type → KO mapping with rationale.
-- 1.2 UI SFX (8): cursor_move, confirm, cancel, menu open/close,
--   equip, error, save_confirm.
-- 1.3 Exploration SFX (9): door, chest, save point, encounter,
--   ley crystal, item pickup, rest complete, quest complete, phase
--   change. Note item_pickup maps to music.md Item Acquisition jingle.
-- 1.4 Environmental/Narrative SFX (~16): all [SFX:] IDs from scripts.
--   Table with ID, context, and script usage.
-- Design philosophy note: SNES-inspired, short, punchy, under 2s.

## 2. Ambient Audio
-- Spec Section 2. Three subsections:
-- 2.1 Biome Loops: table of 12 biomes with ambient character.
--   30-60s seamless loops. "Felt, not heard."
-- 2.2 Mixing Model: table showing music vs ambient balance by
--   context (overworld 100/30, dungeon 50/80, etc.)
-- 2.3 Corruption Effects: 3-stage table per biomes.md (Early,
--   Mid, Full) plus Stage 0 (clean, no modification).

## 3. Implementation Rules
-- Spec Section 3. Six subsections:
-- 3.1 Channel Budget: 24 total (8 music + 12 SFX + 4 ambient).
-- 3.2 Priority Stack: 8-tier table.
-- 3.3 Crossfade Rules: table with 6 transition types + durations.
-- 3.4 SFX Overlap Rules: max 2 same-ID instances, stereo panning.
-- 3.5 Narrative Silence: two sacred moments, exact durations.
-- 3.6 Asset Format: OGG Vorbis, 44.1kHz, 16-bit, naming convention.
```

Cross-link to: music.md, biomes.md, accessibility.md, bestiary/README.md,
combat-formulas.md, overworld.md, save-system.md.

- [ ] **Step 3: Verify SFX catalog completeness**

Cross-check:
- All 8 accessibility.md caption events have matching SFX IDs
- All 16 script [SFX:] IDs appear in the Environmental table
- Enemy KO mapping covers all 8 bestiary types
- Jingle durations match music.md (victory 5-8s, level-up 2-3s,
  save point 3-5s, item acquisition 1-2s)
- Corruption stage names match biomes.md (Early/Mid/Full, not
  Touched/Strained/Corrupted)

- [ ] **Step 4: Commit**

```bash
git add docs/story/audio.md
git commit -m "docs(story): add audio implementation document (gap 4.2)"
```

---

### Task 2: Update Gap Analysis Doc

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (Gap 4.2 status + progress table)

- [ ] **Step 1: Read the current Gap 4.2 section**

Read `docs/analysis/game-design-gaps.md` — find the 4.2 section
(around line 624) and the progress tracking table at the end.

- [ ] **Step 2: Update Gap 4.2 status**

- Change `**Status:** PARTIAL` to `**Status:** COMPLETE`
- Add `**Completed:** 2026-03-31` after the Depends On line
- Update `**Files:**` to include `docs/story/audio.md`
- Check off all checklist items (change `- [ ]` to `- [x]`)

- [ ] **Step 3: Add progress tracking row**

Add a new row to the Progress Tracking table:

```
| 2026-03-31 | 4.2 Sound Effects & Audio | PARTIAL → COMPLETE. Master SFX catalog (~51 IDs: 18 combat with 5 KO variants + 2 boss onset, 8 UI, 9 exploration, ~16 environmental/narrative from scripts). 12 ambient biome loops with context-dependent mixing model (overworld music-dominant, dungeon ambient-dominant, Pallor drone-only). 24-channel budget (8 music/12 SFX/4 ambient), 8-tier priority stack, crossfade rules, SFX overlap limits, narrative silence rules, OGG Vorbis asset format. | — |
```

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(story): mark gap 4.2 Audio Implementation as COMPLETE"
```

---

### Task 3: Cross-Reference Verification

**Files:**
- Read only (no edits expected)

- [ ] **Step 1: Verify audio.md links**

Check that every markdown link in audio.md points to an existing file.

- [ ] **Step 2: Verify SFX catalog vs accessibility captions**

Read accessibility.md Section 6 and confirm all 8 caption events
have a corresponding SFX ID in the audio.md catalog:
- [Save Point] → save_point_chime
- [Encounter] → encounter_trigger
- [Level Up] → level_up
- [Victory] → victory_fanfare
- [Item] → item_pickup
- [Quest Complete] → quest_complete
- [Phase Change] → phase_change
- [Alert] → alarm_bells

- [ ] **Step 3: Verify git log**

```bash
git log --oneline -5
```

Should show: audio.md commit, gap analysis commit, spec commit.
