# Technical Architecture Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the technical architecture document — the developer's
reference for building the Godot 4.6 project from the game design docs.

**Architecture:** Documentation-only. Single file creation
(`docs/plans/technical-architecture.md`) plus gap analysis update and
GDD index update. The spec
(`docs/superpowers/specs/2026-03-31-technical-architecture-design.md`)
contains all content — the implementation adapts it to the docs/plans/
voice and verifies accuracy.

**Tech Stack:** Markdown docs only. No code changes.

---

## Chunk 1: Create Technical Architecture Doc and Update Trackers

### Task 1: Create docs/plans/technical-architecture.md

**Files:**
- Create: `docs/plans/technical-architecture.md`

**Reference:** `docs/superpowers/specs/2026-03-31-technical-architecture-design.md`

This is the developer's implementation reference — Godot-specific,
with code examples and concrete file paths. Written for a developer
who knows Godot but has never seen this project. Different from
docs/story/ files (which are game design references) — this is a
technical blueprint.

- [ ] **Step 1: Read the spec and verify key values against source docs**

Read these files:
- `docs/superpowers/specs/2026-03-31-technical-architecture-design.md` (the spec — all content)
- `docs/story/save-system.md` (save schema — 9 groups, verify field names)
- `docs/story/audio.md` (audio channels — 24, asset format — OGG 44.1kHz)
- `docs/story/accessibility.md` (resolution — 320x180, 17 config settings)
- `docs/story/combat-formulas.md` (ATB tick rate — 60/s)
- `docs/story/bestiary/README.md` (8 enemy types for KO mapping)
- `docs/story/dialogue-system.md` (dialogue data format — 7 fields)
- `docs/story/gdd-overview.md` (content volume numbers for cross-check)

- [ ] **Step 2: Write docs/plans/technical-architecture.md**

Use the spec's 7-section structure. The doc should be self-contained —
a developer reads this one file and knows how to structure the Godot
project. Include all code examples from the spec.

```markdown
# Technical Architecture

> Godot 4.6+ implementation guide for Pendulum of Despair. For game
> design (what to build), see docs/story/. This document defines how
> to build it.

## 1. Project Setup & Conventions
-- Spec Section 1. Directory structure, naming conventions, autoload
-- singletons (5: GameManager, DataManager, AudioManager, SaveManager,
-- EventFlags), viewport settings with integer scaling.
-- Include the full directory tree and project.godot settings.

## 2. Data Format Specifications
-- Spec Section 2. JSON schemas for all 8 data types: enemies, items,
-- equipment, shops, dialogue, encounters, event flags, characters.
-- Include complete JSON examples for each.
-- Note: snake_case keys in JSON (save-system.md pseudo-schema used
-- camelCase for readability, runtime uses snake_case).

## 3. Game State Machine
-- Spec Section 3. Core states (Title, Exploration, Battle — scene
-- swap) and overlay states (Menu, Dialogue, Save/Load, Cutscene —
-- additive layer). Transition rules table. Transition data dict.
-- Overlay stacking rules (one at a time, cutscene can force-close
-- dialogue). GameManager GDScript implementation.

## 4. Entity Architecture
-- Spec Section 4. Godot-native scene composition (.tscn as prefabs).
-- 6 entity types with full scene tree diagrams: PlayerCharacter,
-- NPC, Enemy, TreasureChest, TriggerZone, SavePoint.

## 5. Asset Pipeline
-- Spec Section 5. Tilesets (16x16 PNG), sprite sheets (per-type
-- frame sizes), audio (OGG per audio.md 3.6), pixel art import
-- settings (nearest, no mipmap, no compression).

## 6. Persistence Interface
-- Spec Section 6. Replaces server API. Local file save/load via
-- Godot FileAccess. File location (user://saves/), JSON format,
-- SaveManager GDScript, auto-save triggers, Faint-and-Fast-Reload
-- implementation, global config (17 settings).

## 7. Performance Budgets
-- Spec Section 7. Tables for runtime budgets (60fps, 64 entities,
-- 24 audio channels, etc.) and memory budgets per scene type.
```

Cross-link to: save-system.md, audio.md, accessibility.md,
combat-formulas.md, dialogue-system.md, bestiary/README.md,
visual-style.md, gdd-overview.md.

- [ ] **Step 3: Verify all code examples compile conceptually**

Read through every GDScript code block. Verify:
- `FileAccess` API calls are correct for Godot 4.6
- `get_tree().change_scene_to_file()` not old `change_scene()`
- `Node.PROCESS_MODE_ALWAYS` not old `pause_mode`
- `JSON.new()` and `json.parse()` not old `JSON.parse()`
- Enum syntax is valid GDScript 2.0
- `scale_mode = 1` (integer enum, not string)

- [ ] **Step 4: Commit**

```bash
git add docs/plans/technical-architecture.md
git commit -m "docs(story): add technical architecture document (gap 4.6)"
```

---

### Task 2: Update Gap Analysis Doc

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (Gap 4.6 status + progress table)

- [ ] **Step 1: Read the current Gap 4.6 section**

Read `docs/analysis/game-design-gaps.md` — find the 4.6 section
(around line 751) and the progress tracking table at the end.

- [ ] **Step 2: Update Gap 4.6 status**

- Change `**Status:** MISSING` to `**Status:** COMPLETE`
- Add `**Completed:** 2026-03-31` after the Depends On line
- Update `**Files:**` to `docs/plans/technical-architecture.md`
- Check off all checklist items
- Update the "Server API contract" checklist item text to
  "Persistence interface (local file save/load via Godot FileAccess,
  replaces server API)" before checking it off
- Update the two engine-specific items that were already made
  agnostic in PR #99 — they should now reference Godot specifically:
  - "Engine scene mapping" → "Godot scene mapping"
  - "Relationship to engine scene tree / game objects" → "Godot
    scene tree and Node2D hierarchy"

- [ ] **Step 3: Add progress tracking row**

```
| 2026-03-31 | 4.6 Technical Implementation Guide | MISSING → COMPLETE. Godot 4.6+ / GDScript architecture: project setup (directory structure, 5 autoload singletons, 320x180 viewport), JSON data schemas (8 types: enemies, items, equipment, shops, dialogue, encounters, flags, characters), state machine (3 core + 4 overlay states, transition rules, data passing), entity architecture (6 Godot-native .tscn prefabs), asset pipeline (16x16 tiles, sprite sheets, OGG audio, pixel art import), persistence interface (user:// local saves, SaveManager, auto-save, Faint-and-Fast-Reload, 17 config settings), performance budgets (60fps, 64 entities, 24 audio channels, memory per scene type). **All 25 Tier 1-4 gaps now COMPLETE.** | — |
```

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(story): mark gap 4.6 Technical Architecture as COMPLETE — all 25 gaps closed"
```

---

### Task 3: Update GDD Document Index

**Files:**
- Modify: `docs/story/gdd-overview.md` (Document Index)

- [ ] **Step 1: Read the Document Index**

Read `docs/story/gdd-overview.md` — find the Document Index section
near the end.

- [ ] **Step 2: Add technical-architecture.md**

The Document Index has an "Analysis" section at the bottom. Add the
technical architecture doc either in a new "Technical" category or
alongside the analysis entry:

```markdown
**Technical:**
- `docs/plans/technical-architecture.md` -- Godot 4.6 project setup, data formats, state machine, entities, assets, persistence, performance
```

Note: the link format differs from other entries because
technical-architecture.md is in `docs/plans/`, not `docs/story/`. Use
the full relative path: `[technical-architecture.md](../plans/technical-architecture.md)`.

- [ ] **Step 3: Commit**

```bash
git add docs/story/gdd-overview.md
git commit -m "docs(story): add technical architecture to GDD document index"
```

---

### Task 4: Cross-Reference Verification

**Files:**
- Read only (no edits expected)

- [ ] **Step 1: Verify technical-architecture.md links**

Check that every markdown link points to an existing file.

- [ ] **Step 2: Verify JSON schema examples match source docs**

Spot-check:
- Enemy JSON fields match bestiary column headers
- Save schema 9 groups match save-system.md Section 3
- Config 17 settings match accessibility.md Section 7
- Audio format matches audio.md Section 3.6

- [ ] **Step 3: Verify git log**

```bash
git log --oneline -6
```

Should show: technical-architecture.md, gap analysis, GDD index, spec,
plan, audio references commits.
