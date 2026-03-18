# Music Score Overview Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/music.md` — the complete music score sheet for
the game, defining every track, motif, and audio rule.

**Architecture:** Pure documentation pass — one new file. Content is
transcribed from the spec with light reformatting for the story doc
audience (music sourcers, not engineers). Cross-references to other story
docs are added where music interacts with narrative, locations, or mechanics.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-18-music-score-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/music.md` | Create | Complete music score sheet |

This is a single-file creation. The spec (Sections 2-14) maps directly to
the story doc sections. The implementer should transcribe the spec content
with these adjustments:

1. **Remove spec-specific language** — no "Design Principles" header, no
   "Out of Scope" section, no section numbering. Use story-doc style headings.
2. **Add cross-references** — link to `locations.md`, `dungeons-world.md`,
   `dungeons-city.md`, `events.md`, `characters.md`, `dynamic-world.md`,
   and `biomes.md` where relevant.
3. **Add a header note** — state that all music is instrumental and that
   this document is intended for music sourcing.

---

## Chunk 1: Create the Music Score Document

### Task 1: Create `docs/story/music.md` with all sections

**Files:**
- Create: `docs/story/music.md`
- Reference: `docs/superpowers/specs/2026-03-18-music-score-design.md`

- [ ] **Step 1: Create the file with header and musical rules**

Create `docs/story/music.md` with the document header and condensed musical
rules. Open with a note about the document's purpose:

```markdown
# Music Score Overview

> **All music is instrumental** — no singing, no vocals, no chanting.
> Choir-like textures use sustained string instruments, not voices.
>
> This document defines every track, motif, and audio rule in the game.
> It is the primary reference for sourcing music from free libraries.
> Each entry specifies instruments, mood, tempo, and narrative context
> so that a music sourcer can find appropriate tracks without playing
> the game.
>
> **Related docs:** [locations.md](locations.md) |
> [dungeons-world.md](dungeons-world.md) |
> [dungeons-city.md](dungeons-city.md) | [events.md](events.md) |
> [characters.md](characters.md) | [dynamic-world.md](dynamic-world.md) |
> [biomes.md](biomes.md)
```

Then transcribe spec Sections 2-14 with these section mappings:

| Spec Section | music.md Section |
|-------------|-----------------|
| 2. Design Principles | 1. Musical Rules |
| 3. Faction Palettes | 2. Faction Palettes |
| 4. Character Leitmotifs | 3. Character Leitmotifs |
| 5. Overworld Themes | 4. Overworld Themes |
| 6. Town Themes | 5. Town Themes |
| 7. Dungeon Themes | 6. Dungeon Themes |
| 8. Battle Themes | 7. Battle Themes |
| 9. Corruption Evolution System | 8. Corruption Evolution System |
| 10. Narrative Moment Themes | 9. Narrative Moment Themes |
| 11. System & UI Music | 10. System & UI Music |
| 12. Composable Framework | 11. Composable Framework for New Content |
| 13. Track Count Summary | 12. Track Count Summary |
| 14. Out of Scope | (omit — not relevant for story doc audience) |

Content transcription rules:
- Copy all tables, descriptions, and music notes verbatim from the spec
- Remove spec metadata (date, status, scope header)
- Remove section numbering from headings (use `##` and `###` naturally)
- Keep the "Terminology note" about corruption stages aligning with
  `dynamic-world.md` — add a cross-reference link
- In Town Themes, add parenthetical cross-references to city docs
  (e.g., "See [city-valdris.md](city-valdris.md) for settlement details")
- In Dungeon Themes, add cross-references to dungeon docs
- In Narrative Moment Themes, add cross-references to events.md and outline.md
- In the Corruption Evolution section, link to `dynamic-world.md`

- [ ] **Step 2: Verify cross-references**

Read the created file and verify:
1. All location names match `locations.md` exactly
2. All dungeon names match `dungeons-world.md` and `dungeons-city.md`
3. All character names match `characters.md`
4. All corruption stage references match `dynamic-world.md`
5. All narrative moment names match `events.md` and `outline.md`
6. Relative links to other docs are correct (all in same directory)

- [ ] **Step 3: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (documentation-only change).

- [ ] **Step 4: Commit**

```bash
git add docs/story/music.md
git commit -m "docs(shared): add comprehensive music score overview

Defines faction palettes, character leitmotifs, overworld/town/dungeon
themes, battle music, narrative moment themes, corruption evolution
system, system/UI cues, and composable framework for new content.
~70-80 unique tracks cataloged. All instrumental, no vocals."
```

---

### Task 2: Update the pod-dev skill reference

**Files:**
- Modify: `.claude/skills/pod-dev/SKILL.md`

The pod-dev skill lists all story docs. `music.md` needs to be added.

- [ ] **Step 1: Add music.md to the Story & Narrative section**

In the pod-dev skill file, find the list of story docs under
"## Story & Narrative" and add:

```markdown
- [`docs/story/music.md`](../../../docs/story/music.md) -- Music score
  overview: faction palettes, character leitmotifs, ~70-80 tracks, corruption
  evolution, composable framework for new content
```

Add it after the `visual-style.md` entry (music is a presentation-layer
doc like visual style).

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/pod-dev/SKILL.md
git commit -m "chore(shared): add music.md to pod-dev skill reference"
```

---

### Task 3: Final Verification and Push

- [ ] **Step 1: Verify the document renders correctly**

Read `docs/story/music.md` end-to-end. Check:
- All markdown tables render (no broken pipe characters)
- All relative links point to existing files
- No spec-specific language leaked through (no "Design Principle",
  "Out of Scope", date/status headers)
- Section flow is logical for a music sourcer reading top to bottom

- [ ] **Step 2: Run final lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 3: Push to remote**

```bash
git push
```
