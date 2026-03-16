# Boss Deep Pass Follow-Up Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the remaining work from the boss deep pass — ASCII dungeon layouts, bounty boss stat blocks, and Lira's weapon mechanical definition.

**Architecture:** Pure documentation pass. All tasks modify markdown files in `docs/story/` following established conventions in `dungeons-world.md` (ASCII floor maps, stat blocks, encounter tables).

**Tech Stack:** Markdown documentation. Spec at `docs/superpowers/specs/2026-03-16-boss-deep-pass-design.md`.

**Prerequisite:** The main boss deep pass (plan: `docs/superpowers/plans/2026-03-16-boss-deep-pass.md`) must be complete. All 18 tasks from that plan are done.

---

## Chunk 1: Pallor Trial ASCII Dungeon Layouts

Each trial dungeon needs full ASCII floor maps matching the format in `dungeons-world.md`. Reference existing multi-floor dungeons (Ember Vein, Fenmother's Hollow, Frostcap Caverns) for the exact format: floor header with tile dimensions, ASCII art using the map legend, Key Locations bullet list, Encounter Zones, Environmental Hazards.

Each trial's theme, floor count, enemies, and boss are already defined in the Pallor Wastes section of `dungeons-world.md` (added in the main plan). These tasks add the floor maps and detailed Key Locations.

### Task 1: Edren's "Hall of Crowns" ASCII layouts (3-4 floors)

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section, Trial 1 stub)

- [ ] **Step 1: Read the existing Trial 1 stub and 2-3 existing multi-floor dungeon layouts for format reference**

Read the Hall of Crowns stub in the Pallor Wastes section. Then read Ember Vein (4 floors) and Fenmother's Hollow (3 floors) for the exact ASCII layout format.

- [ ] **Step 2: Design Floor 1 — The Outer Throne Room (40x30)**

A decaying version of Valdris Crown's throne room. Ghostly soldiers line the walls. Doors sealed by guilt — dialogue choices required to open them. Encounter zones with Hollow Knights in formation.

Key features:
- Entrance from the Pallor Wastes
- 2-3 dialogue-gated doors (Edren must acknowledge a failure to open each)
- Encounter zones with Hollow Knights
- Save point
- Treasure: item related to leadership/command

- [ ] **Step 3: Design Floor 2 — The War Room (40x30)**

A twisted version of a military planning chamber. Maps on the walls show battles Edren lost. Ghostly advisors replay failed strategies. Puzzle: rearrange battle plans to acknowledge the correct decision was still wrong (no right answer existed).

- [ ] **Step 4: Design Floor 3 — The King's Chamber (35x25)**

Aldren's throne room, but the throne is empty and crumbling. The floor is covered in names — every soldier who died following Edren's orders. The Crowned Hollow boss arena.

Key features:
- Boss arena in the center
- Ghostly soldiers around the perimeter (visual, become part of resolution mechanic)
- Save point before the boss
- No escape — the door seals behind the party

- [ ] **Step 5: Add Key Locations, Encounter Zones, and Environmental Hazards for all floors**

- [ ] **Step 6: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs: add Hall of Crowns ASCII floor layouts (Edren trial)"
```

---

### Task 2: Lira's "The Unfinished Forge" ASCII layouts (3-4 floors)

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section, Trial 2 stub)

- [ ] **Step 1: Read the existing Trial 2 stub**

- [ ] **Step 2: Design Floor 1 — Childhood Workshop (35x25)**

Small, warm, cramped. Half-finished toys and tools on every surface. Puzzles: choose which projects to abandon (leaving a workbench unfinished opens the path forward, repairing one spawns more broken objects and locks progress).

- [ ] **Step 3: Design Floor 2 — The Caldera Forges (45x30)**

Industrial scale. Massive forge-hammers, cooling channels, abandoned assembly lines. Unfinished Constructs patrol in herds. The heat is oppressive. Lira has unique dialogue recognizing specific machines.

- [ ] **Step 4: Design Floor 3 — The Impossible Workshop (40x35)**

Abstract space. Half-finished creations float in the air — unfinished letters to Cael, blueprints for a Pallor cure, a wedding ring. The Perfect Machine boss arena is at the center. Gravity shifts are possible (walking on walls/ceiling areas).

- [ ] **Step 5: Add Key Locations, Encounter Zones, and Environmental Hazards**

- [ ] **Step 6: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs: add Unfinished Forge ASCII floor layouts (Lira trial)"
```

---

### Task 3: Torren's "The Silent Grove" ASCII layouts (2-3 floors)

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section, Trial 3 stub)

- [ ] **Step 1: Read the existing Trial 3 stub**

- [ ] **Step 2: Design Floor 1 — The Outer Grove (40x30)**

Petrified forest. Stone trees, grey ash, diminishing ambient sound. Puzzle: follow the one remaining sound (a faint heartbeat) through branching stone corridors. Stone Spirits animate when approached.

- [ ] **Step 3: Design Floor 2 — The Deep Silence (35x25)**

Complete silence. No ambient sound at all. Visual-only navigation cues. The puzzle is finding a single trickle of water by watching for pixel-level animation cues. The Last Voice boss arena is a clearing where a single massive petrified tree stands — the Great Spirit.

- [ ] **Step 4: Add Key Locations, Encounter Zones, and Environmental Hazards**

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs: add Silent Grove ASCII floor layouts (Torren trial)"
```

---

### Task 4: Sable's "The Crooked Mile" ASCII layouts (1-2 floors)

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section, Trial 4 stub)

- [ ] **Step 1: Read the existing Trial 4 stub**

- [ ] **Step 2: Design Floor 1 — The Alleyways (30x25)**

A looping maze of narrow alleyways. The layout wraps — exiting the right side enters the left. Doors along the alleys lead to trap rooms (party members in danger). Shadows of Sable patrol the alleys. The Open Door is at the "end" — but the real exit is turning around.

Key design challenge: the map must make the Open Door feel like the obvious goal while the turn-around path feels counterintuitive. The alley behind the player should subtly change when they turn around (warmer lighting, familiar objects from party scenes).

- [ ] **Step 3: Add Key Locations and Encounter Zones**

- [ ] **Step 4: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs: add Crooked Mile ASCII floor layouts (Sable trial)"
```

---

### Task 5: Maren's "The Restricted Stacks" ASCII layouts (2-3 floors)

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section, Trial 5 stub)

- [ ] **Step 1: Read the existing Trial 5 stub**

- [ ] **Step 2: Design Floor 1 — The Reading Room (35x25)**

An orderly library with shelves stretching to an impossibly high ceiling. Grey light pools on the floor, slowly rising. Interactable bookshelves grant tactical information but debuff Maren. Archived enemies emerge from between shelves.

- [ ] **Step 3: Design Floor 2 — The Flooded Stacks (40x30)**

Grey light has risen to waist height. Movement is slowed in flooded areas. Shelves topple as the "flood" rises, creating new paths and blocking old ones. The Index boss arena is a central reading table surrounded by the rising grey light — a shrinking island of clarity.

- [ ] **Step 4: Add Key Locations, Encounter Zones, and Environmental Hazards**

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs: add Restricted Stacks ASCII floor layouts (Maren trial)"
```

---

## Chunk 2: Highcairn Monastery Layout

### Task 6: Highcairn Monastery ASCII layouts (2 floors)

**Files:**
- Modify: `docs/story/dungeons-world.md` (Section 20: Highcairn Monastery)

**Context:** The Highcairn Monastery section was created in the main plan with a dungeon overview and the Pallor Hollow boss stat block, but no floor layouts. This task adds the full ASCII maps. Resolves the remainder of IMPORTANT-03 from layout-audit.md.

- [ ] **Step 1: Read the existing Highcairn Monastery section and the Monastery of the Vigil description in locations.md or city docs**

Understand the monastery's geography, its mountain setting, and any existing descriptions of its layout.

- [ ] **Step 2: Design Floor 1 — Monastery Grounds (40x30)**

The outer monastery. Grey-tinged stone buildings, a courtyard, dormitories. The Pallor has seeped into everything — grey frost on surfaces, hollow-eyed monk statues (or actual petrified monks). The monastery prior is found here, alive but grey-touched.

Key features:
- Entrance from the mountain path
- Courtyard with Pallor-corrupted encounters
- The prior's cell (dialogue scene)
- Dormitories with lore items (journals from Edren's stay)
- Path to the Inner Sanctum

- [ ] **Step 3: Design Floor 2 — Inner Sanctum (35x25)**

The monastery's chapel/meditation hall. This is where the Pallor Hollow manifests. A vaulted chamber with grey light pouring through stained glass. The boss arena.

Key features:
- Save point before the boss
- Stained glass windows depicting previous Pallor cycles (environmental lore)
- The boss arena — open space with Edren visible on the upper balcony (Phase 3 trigger)
- No escape once the fight begins

- [ ] **Step 4: Add Key Locations, Encounter Zones, Environmental Hazards, and Treasure**

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs: add Highcairn Monastery ASCII floor layouts"
```

---

## Chunk 3: Grey Bounty Boss Stat Blocks

### Task 7: Define all 12 Grey Bounty boss stat blocks

**Files:**
- Modify: `docs/story/sidequests.md` (Grey Bounties section)
- Modify: `docs/story/dungeons-world.md` (if bounty encounters have specific dungeon locations)

**Context:** The 12 Grey Bounties are listed in sidequests.md with names and brief descriptions but no stat blocks, detailed movesets, or phase descriptions. Each is a boss-level encounter given by Riven. They should have Pattern B stat blocks with 1-2 phases, unique mechanics, and drops. HP range should scale from ~4,000 (early bounties) to ~12,000 (late bounties).

The 12 bounties are:
1. The Hollow Stag
2. The Forgespawn
3. The Weeping Fenmother
4. The Ashen Knight
5. The Stillborn
6. The Grey Tide
7. The Canopy Shade
8. The Ironbreather
9. The Petrified Rootwalker
10. The Echoed King
11. The Tidebreaker
12. The Memory of Fire

- [ ] **Step 1: Read the existing Grey Bounties section in sidequests.md**

Understand the current descriptions, quest structure, availability, and any existing lore for each bounty.

- [ ] **Step 2: Design stat blocks for bounties 1-4 (early game, 4,000-6,000 HP)**

Each needs: physical description, 1-2 phase combat, weakness/resistance, drop. Connect to world lore where possible (Riven's dialogue, Vaelith's disturbances).

- [ ] **Step 3: Design stat blocks for bounties 5-8 (mid game, 6,000-9,000 HP)**

More complex mechanics. Some should have unique gimmicks (environmental interaction, time limits, special conditions).

- [ ] **Step 4: Design stat blocks for bounties 9-12 (late game, 9,000-12,000 HP)**

Most complex. Multi-phase fights. The Memory of Fire should be the hardest bounty and have a Vaelith connection (it was disturbed by Vaelith's passage).

- [ ] **Step 5: Update the Grey Bounties quest entry in sidequests.md with stat block references**

- [ ] **Step 6: Commit**

```bash
git add docs/story/sidequests.md docs/story/dungeons-world.md
git commit -m "docs: add all 12 Grey Bounty boss stat blocks"
```

---

## Chunk 4: Lira's Weapon Mechanical Definition

### Task 8: Define Lira's weapon mechanics

**Files:**
- Modify: `docs/story/abilities.md` (or create a new section if appropriate)
- Modify: `docs/story/dungeons-world.md` (Vaelith boss entry, to ensure combat mechanics reference the weapon definition)

**Context:** Lira's weapon — forged from Cael's lingering connection and the ley network — manifests during the Vaelith fight. The narrative is defined, but the full mechanical definition is not. This task defines:

- How the weapon functions in-battle (passive buff? active ability? equipment?)
- The re-forge timed input mechanic during Reality Warp
- How it interacts with Lira's existing Forgewright abilities
- Whether it persists after the Vaelith fight (into the Convergence/Pallor Incarnate fight)
- Its stats, effects, and any upgrade path

- [ ] **Step 1: Read abilities.md to understand the existing ability/weapon format**

Read the Forgewright command section and any weapon-related content.

- [ ] **Step 2: Define the weapon — "Cael's Echo" (working name)**

Design the weapon as a unique equipment piece that:
- Appears during the Vaelith fight via cutscene (cannot be obtained earlier)
- Grants the entire party the ability to damage Pallor-immune entities
- Has a re-forge mechanic (timed input during Reality Warp — success maintains full power, failure reduces effectiveness temporarily)
- Interacts with Lira's Forgewright command (can be "tempered" mid-battle for temporary buffs)
- Persists through the Convergence and Pallor Incarnate fights
- Has unique visual properties (ley-line blue threaded with grey)

- [ ] **Step 3: Define the re-forge timed input mechanic**

Specify the timing window, success/failure effects, and how the Boring Engine Schematic extends the window. Define what button/input the player presses and the visual feedback.

- [ ] **Step 4: Add the weapon definition to abilities.md**

- [ ] **Step 5: Cross-reference the Vaelith boss entry in dungeons-world.md to ensure Reality Warp references the weapon definition**

- [ ] **Step 6: Commit**

```bash
git add docs/story/abilities.md docs/story/dungeons-world.md
git commit -m "docs: define Lira's weapon (Cael's Echo) mechanics"
```

---

## Task Dependency Map

```
Chunk 1 (Trial Layouts):
  Task 1 (Hall of Crowns) ──┐
  Task 2 (Unfinished Forge) ┤
  Task 3 (Silent Grove) ────┤── All independent, can run sequentially
  Task 4 (Crooked Mile) ────┤   (all modify dungeons-world.md, same section)
  Task 5 (Restricted Stacks)┘

Chunk 2 (Highcairn):
  Task 6 ── independent of Chunk 1 (different section of dungeons-world.md)

Chunk 3 (Grey Bounties):
  Task 7 ── independent of all other chunks

Chunk 4 (Lira's Weapon):
  Task 8 ── independent of all other chunks
```

**Parallelization:** Tasks 1-5 must run sequentially (same file section). Tasks 6, 7, and 8 can each run in parallel with each other and with Chunk 1, since they modify different files or different sections.
