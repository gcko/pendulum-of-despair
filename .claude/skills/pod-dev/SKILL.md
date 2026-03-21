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

Also see the detailed combat design docs:
- [`docs/story/abilities.md`](../../../docs/story/abilities.md) -- 6 unique character commands (Bulwark, Rally, Forgewright, Spiritcall, Tricks, Arcanum), 12 dual techs, magic framework
- [`docs/story/magic.md`](../../../docs/story/magic.md) -- 89 original spells across 8 elements, full spell progression per character
- Aesthetic and tone guidelines

---

## Story & Narrative

Read [`docs/story/`](../../../docs/story/) for the full narrative design:
- [`outline.md`](../../../docs/story/outline.md) -- Rough story outline (4 acts + interlude + epilogue)
- [`world.md`](../../../docs/story/world.md) -- Factions (Valdris, Carradan Compact, Thornmere Wilds), Arcanite Forging, the Pallor, geography
- [`characters.md`](../../../docs/story/characters.md) -- Core cast (Edren, Cael, Lira, Torren, Sable, Maren), arcs, and relationships
- [`locations.md`](../../../docs/story/locations.md) -- 35 named locations (cities, dungeons, secret areas), overworld routes, act-by-act progression
- [`npcs.md`](../../../docs/story/npcs.md) -- 54 named NPCs with backstories, dialogue hints, and act-by-act state changes
- [`events.md`](../../../docs/story/events.md) -- 30 story flags, world state transitions, NPC threads, foreshadowing/payoff map, critical path
- [`sidequests.md`](../../../docs/story/sidequests.md) -- 10 major + 15 minor side quests, optional party scenes, post-game content
- [`biomes.md`](../../../docs/story/biomes.md) -- Biome system, visual palettes, tileset direction, environmental storytelling
- [`geography.md`](../../../docs/story/geography.md) -- Detailed continental map, regional geography, terrain features, travel implications
- [`dynamic-world.md`](../../../docs/story/dynamic-world.md) -- How locations transform across acts (destruction, corruption, rebuilding, spatial shifts)
- [`visual-style.md`](../../../docs/story/visual-style.md) -- Art direction, location visual profiles, signature scenes, color script
- [`progression.md`](../../../docs/story/progression.md) -- Character stat system: 8 stats, growth curves, 18 Ley Crystals with 5 levels, narrative milestone spikes, party join rules
- [`music.md`](../../../docs/story/music.md) -- Music score overview: faction palettes, character leitmotifs, ~70-80 tracks, corruption evolution, composable framework for new content
- [`building-palette.md`](../../../docs/story/building-palette.md) -- Reusable interior templates (18 building types, furniture, faction variants)

**Gap Analysis & Design Tracker:**
- [`docs/analysis/game-design-gaps.md`](../../../docs/analysis/game-design-gaps.md) -- Living gap analysis tracking what's designed vs. what's missing. Use `/story-designer` skill to iterate on gaps.

**Cities, interiors, and dungeons:**
- [`city-valdris.md`](../../../docs/story/city-valdris.md) -- Valdris faction city layouts with ASCII maps, shops, NPCs
- [`city-carradan.md`](../../../docs/story/city-carradan.md) -- Carradan Compact city layouts with ASCII maps, districts, shops
- [`city-thornmere.md`](../../../docs/story/city-thornmere.md) -- Thornmere settlements and cross-faction locations
- [`interiors.md`](../../../docs/story/interiors.md) -- Key interior layouts, faction palette application, act-variant rooms
- [`dungeons-world.md`](../../../docs/story/dungeons-world.md) -- 14 world dungeons with floor maps, puzzles, encounters
- [`dungeons-city.md`](../../../docs/story/dungeons-city.md) -- City dungeons, 20 secret passages, hidden rooms, escape routes

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
