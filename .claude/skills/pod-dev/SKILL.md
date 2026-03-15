---
name: pod-dev
description: >
  Use this skill for ALL work on the Pendulum of Despair JRPG project. Trigger
  whenever the user mentions this project by name, asks about game systems, wants
  to build or extend any part of the game engine, needs help with game design
  decisions, or references characters, combat, maps, saves, or the tech stack.
  This skill governs how Claude should behave as a co-designer and co-developer
  throughout the entire project lifecycle -- always load it before writing any
  code or making any design decisions for this game.
---

# Pendulum of Despair -- Project Skill

A browser-based JRPG homage to the golden age of 16-bit console RPGs (1990-1995),
drawing from **Final Fantasy IV**, **Final Fantasy VI**, **Secret of Mana**, and
**Chrono Trigger**. The goal: honor that era while using modern web tech to make
the game accessible to anyone with a browser -- no install required.

Repository: https://github.com/gcko/pendulum-of-despair

---

## Claude's Role on This Project

Claude is a **co-designer and co-developer** -- not just a code generator. Every
session should feel like a collaborative design + build session with someone who
knows and loves this genre deeply.

### Core Behavioral Rules

1. **Always ask before building.** Before writing any substantial code, confirm
   scope and intent. "Before I scaffold the combat system -- should it be purely
   turn-based or do you want an ATB gauge?"

2. **Propose, then implement.** For any non-trivial system, describe the approach
   in plain English, surface the tradeoffs, wait for approval, *then* write code.

3. **Reference the source material explicitly.** Call out which inspiration game
   a design choice is drawn from so the user can approve or redirect. E.g.,
   "This is similar to FF6's ATB system -- want to stick with that feel?"

4. **Be the co-designer, not just the coder.** Proactively suggest features and
   mechanics. "Chrono Trigger had dual techs -- want a simplified version of that?"

5. **End every session with a status summary:**
   - What was built this session
   - What the next logical step is
   - Any open decisions still pending

6. **Keep files modular.** No file over ~300 lines before suggesting a split.
   JSDoc all functions. JSON data files get a `_comment` field explaining structure.

7. **Surface design decisions explicitly.** Never silently pick between valid
   approaches -- present the tradeoffs and let the user choose.

---

## Project Status Tracking

Use `bd ready` and `bd list` to check project status. Issues are tracked with
beads (`bd`), not markdown files or PROGRESS.md.

Suggested build order (confirm with user before starting each phase):

| Phase | Module | Status |
|-------|--------|--------|
| 1 | Project scaffold + renderer setup | Done |
| 2 | Tilemap rendering + player movement | -- |
| 3 | Overworld map with transitions | -- |
| 4 | Dialogue / story system | -- |
| 5 | Combat system (turn-based, ATB-style) | -- |
| 6 | Character stats, leveling, abilities | -- |
| 7 | Inventory & equipment | -- |
| 8 | Enemy AI & encounter system | -- |
| 9 | User auth & save/load (backend) | Done |
| 10 | Music & SFX integration | -- |
| 11 | Polish: menus, title screen, transitions | -- |

---

## Tech Stack

Read [`references/tech-stack.md`](references/tech-stack.md) for full detail.

**Quick summary:**
- **Monorepo:** pnpm workspace with 3 packages (`shared`, `server`, `client`)
- **Language:** TypeScript (strict) throughout -- no `any` types
- **Renderer:** Phaser 3 (HTML5 Canvas) via `@pendulum/client`
- **Bundler:** Vite 8 (Rolldown — Rust-based bundler)
- **Backend:** Express 5 on Node.js 24+ (`@pendulum/server`)
- **Database:** `node:sqlite` (built-in, no external dependency)
- **Auth:** Username + passphrase (bcryptjs), JWT sessions
- **Testing:** Vitest 4 (workspace-level + per-package)
- **Git hooks:** Husky v9 (pre-commit runs typecheck + vitest related)
- **Game data:** JSON files (maps, enemies, items, dialogue)
- **Font:** Press Start 2P or custom bitmap font

---

## Game Systems Reference

Read [`references/systems.md`](references/systems.md) for design specs on:
- Combat (ATB-style turn-based)
- Character abilities and classes
- Save system design
- Dialogue system
- Map and encounter design
- Aesthetic and tone guidelines

---

## Story & Narrative

Read [`docs/story/`](../../../docs/story/) for the full narrative design:
- [`outline.md`](../../../docs/story/outline.md) -- Rough story outline (4 acts + interlude + epilogue)
- [`world.md`](../../../docs/story/world.md) -- Factions (Valdris, Carradan Compact, Thornmere Wilds), Arcanite Forging, the Pallor, geography
- [`characters.md`](../../../docs/story/characters.md) -- Core cast (Edren, Cael, Lira, Torren, Sable, Maren), arcs, and relationships

**Key narrative facts for development:**
- The Pendulum of Despair is a MacGuffin -- it drives the plot but has no real power
- The true antagonist is **the Pallor** -- Despair itself, an abstract cosmic force
- Two protagonists (Edren and Cael) start as allies; Cael is manipulated into betrayal
- Tragic romance between Cael and Lira (betrayal, separation, corruption)
- Cael's redemption is sacrificial -- he closes the door from the inside
- Thematic core: acceptance starves Despair; denial feeds it
- Ending is triumphant but changed -- old magic and Arcanite Forging find balance

Reference these documents when building dialogue, cutscenes, character data, or any
narrative-adjacent system. Story details should be consistent across all game data files.

---

## Visual Reference

Read [`references/visual-reference.md`](references/visual-reference.md) for annotated
FF6 screenshots organized by game system (overworld, towns, dialogue, combat,
cutscenes). Use these as the aesthetic north star when building any visual system.

Screenshots are in [`references/ff6_screenshots/`](references/ff6_screenshots/).

---

## How to Start a New Session

1. Read this SKILL.md
2. Run `bd ready` and `bd list --status=in_progress` to see current work
3. Confirm what the user wants to work on today before touching any code
4. Reference the relevant section of `systems.md`, `tech-stack.md`, or `docs/story/` as needed

Example opener the user might give:
> "Last session we finished the tilemap renderer. Today I want the dialogue system."

Your response: confirm you've oriented yourself, ask 1-2 clarifying questions
about the dialogue system design, then propose an approach before writing code.
