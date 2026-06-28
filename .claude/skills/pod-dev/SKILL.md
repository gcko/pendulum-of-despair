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

A Godot 4.7 desktop JRPG written in GDScript -- an homage to the golden age of
16-bit console RPGs (1990-1995), drawing from **Final Fantasy IV**, **Final
Fantasy VI**, **Secret of Mana**, and **Chrono Trigger**. The goal: honor that
era with a locally-run desktop application built on the Godot Engine.

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

Use `gh issue list` to check project status. Issues are tracked with
GitHub Issues, not beads/bd, markdown files, or PROGRESS.md.

Current build status (Godot project under `game/`, confirm scope with the user
before starting each area):

| Phase | Module | Status |
|-------|--------|--------|
| 1 | Project scaffold (`game/`) + 6 autoloads + viewport | Done |
| 2 | Core scenes (title, exploration, battle) | In progress |
| 3 | Tilemap maps (overworld, towns, dungeons) | In progress |
| 4 | Player movement + entities (NPC, triggers, save points) | In progress |
| 5 | Dialogue / cutscene overlays | In progress |
| 6 | Combat system (ATB-style turn-based) | In progress |
| 7 | Character stats, leveling, abilities, magic | In progress |
| 8 | Inventory & equipment + shop overlays | In progress |
| 9 | Save/load (SaveManager autoload, local JSON) | In progress |
| 10 | Music & SFX integration (AudioManager) | In progress |
| 11 | Polish: menus, transitions, encounter system | -- |

Scenes already live under `game/scenes/{core,overlay,entities,maps,ui}`; the
current focus is the combat command core (see open `gap-analysis` issues). Use
`gh issue list` for the authoritative, up-to-date picture rather than this table.

---

## Tech Stack

Read [`references/tech-stack.md`](references/tech-stack.md) for full detail.

**Quick summary:**
- **Engine:** Godot 4.7, **GL Compatibility** renderer, `config_version=5`
- **Language:** **GDScript only** (no TypeScript, no `.js`/`.ts` source)
- **Project root:** `game/` (open this directory in the Godot editor)
- **Viewport:** 1280x720 at 4x camera zoom -> 320x180 effective game world,
  integer-scaled
- **Game data:** JSON files under `game/data/` (enemies, items, equipment,
  shops, spells, dialogue, etc.), loaded by the DataManager autoload
- **Autoloads (6):** GameManager, DataManager, AudioManager, SaveManager,
  EventFlags, PartyState (`game/scripts/autoload/`)
- **Testing:** GUT 9.7.0 (`game/addons/gut/`), test files in `game/tests/`
- **Save/load:** local, via the SaveManager autoload -- no backend, no database
- **Package tooling:** `pnpm` is used **only** for husky + commitlint. No
  bundler, no backend, no monorepo, no `npm`/`yarn`/`npx`.

**Git hooks (Husky v9, `core.hooksPath=.husky/_` -- never edit `_/`):**
- **pre-commit:** branch protection (no direct commits to main) + gdlint +
  JSON validation + `gdformat --check`
- **pre-push:** data-integrity scans (ID uniqueness, stale counts, scene refs)
  + Godot `--import` + the full GUT suite
- **commit-msg:** commitlint (Conventional Commits 1.0.0)
- Recovery: `pnpm install`. **Never** use `--no-verify` -- fix the root cause.

**Recommended MCP:** the Godot MCP server
([tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp))
gives live editor and scene-tree access. It is being added to the project so
future sessions can inspect and manipulate scenes directly now that `.tscn`
scenes exist.

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
- [`combat-formulas.md`](../../../docs/story/combat-formulas.md) -- Combat formulas: physical/magic damage, healing, crits, elemental system, status accuracy, combat interactions, boss HP scaling
- [`bestiary/README.md`](../../../docs/story/bestiary/README.md) -- Enemy bestiary: 8 types, stat scaling formulas, bounded-growth rewards, palette-swap families. Per-act stat tables in subdirectory.
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
2. Run `gh issue list` (and `gh issue list --label in-progress`) to see current work
3. Confirm what the user wants to work on today before touching any code
4. Reference the relevant section of `systems.md`, `tech-stack.md`, or `docs/story/` as needed

Example opener the user might give:
> "Last session we finished the tilemap renderer. Today I want the dialogue system."

Your response: confirm you've oriented yourself, ask 1-2 clarifying questions
about the dialogue system design, then propose an approach before writing code.

## Development Workflow Chain

The skills in this project form a pipeline. Each skill names the next
step in its exit message.

| Step | Skill | What It Does | Next Step |
|------|-------|-------------|-----------|
| 1 | `/story-designer` | Design a game system (brainstorm, spec, plan, implement) | `/create-pr` |
| 2 | `/create-pr` | Open a PR targeting main (tests, lint, push, create) | `/pr-review-response <PR#>` |
| 3 | `/pr-review-response <PR#>` | Orchestrate review + address feedback | Merge (or re-run) |

**How `/pr-review-response` works as orchestrator:**
- Detects PR type from changed files (Story / Code / Mixed / Tooling / Docs)
- Auto-runs upstream review if not already done:
  - Story PRs → `/story-review-loop <PR#> 3`
  - Code PRs → gdlint + `gdformat --check` + Godot `--import` + the GUT suite
    (via `/godot-review-loop`), not `pnpm lint`/`pnpm test`
  - Mixed → both pipelines
- Fetches and addresses all human and bot review comments
- Proposes review skill improvements when Copilot finds gaps
- Reports "ready to merge" or "re-run needed" at exit
