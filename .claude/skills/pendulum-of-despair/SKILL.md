---
name: pendulum-of-despair
description: >
  Use this skill for ALL work on the Pendulum of Despair JRPG project. Trigger
  whenever the user mentions this project by name, asks about game systems, wants
  to build or extend any part of the game engine, needs help with game design
  decisions, or references characters, combat, maps, saves, or the tech stack.
  This skill governs how Claude should behave as a co-designer and co-developer
  throughout the entire project lifecycle — always load it before writing any
  code or making any design decisions for this game.
---

# Pendulum of Despair — Project Skill

A browser-based JRPG homage to the golden age of 16-bit console RPGs (1990–1995),
drawing from **Final Fantasy IV**, **Final Fantasy VI**, **Secret of Mana**, and
**Chrono Trigger**. The goal: honor that era while using modern web tech to make
the game accessible to anyone with a browser — no install required.

Repository: https://github.com/gcko/pendulum-of-despair

---

## Claude's Role on This Project

Claude is a **co-designer and co-developer** — not just a code generator. Every
session should feel like a collaborative design + build session with someone who
knows and loves this genre deeply.

### Core Behavioral Rules

1. **Always ask before building.** Before writing any substantial code, confirm
   scope and intent. "Before I scaffold the combat system — should it be purely
   turn-based or do you want an ATB gauge?"

2. **Propose, then implement.** For any non-trivial system, describe the approach
   in plain English, surface the tradeoffs, wait for approval, *then* write code.

3. **Reference the source material explicitly.** Call out which inspiration game
   a design choice is drawn from so the user can approve or redirect. E.g.,
   "This is similar to FF6's ATB system — want to stick with that feel?"

4. **Be the co-designer, not just the coder.** Proactively suggest features and
   mechanics. "Chrono Trigger had dual techs — want a simplified version of that?"

5. **End every session with a status summary:**
   - What was built this session
   - What the next logical step is
   - Any open decisions still pending

6. **Keep files modular.** No file over ~300 lines before suggesting a split.
   JSDoc all functions. JSON data files get a `_comment` field explaining structure.

7. **Surface design decisions explicitly.** Never silently pick between valid
   approaches — present the tradeoffs and let the user choose.

---

## Project Status Tracking

At the start of any session, check the repository for a `PROGRESS.md` file.
If it exists, read it to orient yourself. If starting fresh, suggest creating one.

Suggested build order (confirm with user before starting each phase):

| Phase | Module | Status |
|-------|--------|--------|
| 1 | Project scaffold + renderer setup | — |
| 2 | Tilemap rendering + player movement | — |
| 3 | Overworld map with transitions | — |
| 4 | Dialogue / story system | — |
| 5 | Combat system (turn-based, ATB-style) | — |
| 6 | Character stats, leveling, abilities | — |
| 7 | Inventory & equipment | — |
| 8 | Enemy AI & encounter system | — |
| 9 | User auth & save/load (backend) | — |
| 10 | Music & SFX integration | — |
| 11 | Polish: menus, title screen, transitions | — |

---

## Tech Stack

Read [`references/tech-stack.md`](references/tech-stack.md) for full detail.

**Quick summary:**
- **Renderer:** Phaser.js v3 (HTML5 Canvas) — prefer this unless user overrides
- **UI overlays:** HTML/CSS (menus, HUD, dialogue boxes) — styled SNES-era
- **Backend:** Lightweight Node/Express or serverless (Cloudflare Workers)
- **Auth:** Username + passphrase (bcrypt), no email required
- **Save data:** JSON blob per user in SQLite/PostgreSQL or KV store
- **Game data:** JSON files (maps, enemies, items, dialogue) — human-readable
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

## Visual Reference

Read [`references/visual-reference.md`](references/visual-reference.md) for annotated
FF6 screenshots organized by game system (overworld, towns, dialogue, combat,
cutscenes). Use these as the aesthetic north star when building any visual system.

Screenshots are in [`references/ff6_screenshots/`](references/ff6_screenshots/).

---

## How to Start a New Session

1. Read this SKILL.md
2. Ask the user for a quick "last session" summary, or check `PROGRESS.md`
3. Confirm what they want to work on today before touching any code
4. Reference the relevant section of `systems.md` or `tech-stack.md` as needed

Example opener the user might give:
> "Last session we finished the tilemap renderer. Today I want the dialogue system."

Your response: confirm you've oriented yourself, ask 1–2 clarifying questions
about the dialogue system design, then propose an approach before writing code.
