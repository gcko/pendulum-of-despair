# Story Documentation

This directory contains the narrative design for Pendulum of Despair.

## Documents

### Core Narrative
| File | Purpose |
|------|---------|
| `outline.md` | Story outline — 4 acts, interlude, and epilogue |
| `world.md` | Factions, terminology, the Pallor, the Pendulum |
| `characters.md` | Core cast profiles, relationships, and arcs |
| `npcs.md` | 54 named NPCs with backstories and act-by-act dialogue changes |
| `events.md` | 30 story flags, world state transitions, foreshadowing map, critical path |
| `sidequests.md` | 10 major + 15 minor side quests, optional party scenes, post-game content |

### World & Geography
| File | Purpose |
|------|---------|
| `locations.md` | 35+ named locations — cities, dungeons, secret areas, overworld routes |
| `geography.md` | ASCII continental map, ley line network, terrain, overworld grid specs |
| `biomes.md` | 11 biomes with color palettes, tilesets, Pallor corruption overlay system |
| `dynamic-world.md` | How every location transforms across acts — 72 map variants |

### Combat & Magic
| File | Purpose |
|------|---------|
| `abilities.md` | 6 unique character commands, 12 dual techs, magic system framework, progression tables |
| `magic.md` | 89 original spells across 8 elements — offensive, healing, status, buffs, utility, Void/Pallor |

### Visual Design
| File | Purpose |
|------|---------|
| `visual-style.md` | Art direction, 17 location visual profiles, signature scenes, color script |

### City & Settlement Layouts
| File | Purpose |
|------|---------|
| `building-palette.md` | Reusable interior templates — 18 building types, furniture palette, faction variants |
| `city-valdris.md` | Valdris Crown, Aelhart, Highcairn, Thornwatch, Greyvale — ASCII maps, shops, NPCs |
| `city-carradan.md` | Corrund, Caldera, Ashmark, Bellhaven, + 6 more — ASCII maps, shops, districts |
| `city-thornmere.md` | Roothollow, Duskfen, Canopy Reach, + 9 more — organic settlements, cross-faction |
| `interiors.md` | Key interior layouts, faction-specific palette application, act-variant rooms |

### Dungeons & Secrets
| File | Purpose |
|------|---------|
| `dungeons-world.md` | 14 dungeons with floor maps, puzzles, encounters, treasure — Ember Vein to Dreamer's Fault |
| `dungeons-city.md` | 6 city dungeons, 20 secret passages, hidden rooms, escape routes, quest-locked areas |

### Quality Assurance
| File | Purpose |
|------|---------|
| `continuity-audit.md` | First narrative continuity audit (story + NPCs + events) |
| `worldbuilding-audit.md` | Worldbuilding continuity audit (biomes + geography + visual) |
| `layout-audit.md` | Layout continuity audit (cities + dungeons + interiors + economy) |

## Writing Conventions

- **Write American English.** New design prose, new dialogue, and every
  new player-facing string use American spellings: *color*, *behavior*,
  *paralyzed*, *centered*, *-ize/-ization*. This is the direction the
  narrative canon already sets — `outline.md` "paralyzed by guilt"
  (line 210), `characters.md` "paralyzes him" (line 21), `abilities.md`
  "he's paralyzed by guilt" (line 50) — and it is the form the engine
  emits for status notifications.
- **This is a rule for new writing, not a description of the corpus.**
  The `color` / `paralyzed` / `centered` families were swept, but
  British forms survive elsewhere and are *not* to be read as sanctioned:
  *armour*, *favour*, *defence* in
  `docs/story/script/battle-dialogue.md`, `script/act-iii.md`,
  `script/act-ii-part-2.md` and seven shipped
  `game/data/dialogue/*.json` files; *catalogue* /
  *catalogued* in `items.md`, `npcs.md`, `dungeons-world.md`,
  `dialogue-system.md` and `bestiary/bosses.md`; *travelling* in
  `outline.md`, `events.md` and `script/npc-ambient.md`; *cancelled* in
  `overworld.md`; *synthesises* in `dialogue-system.md`. Sweeping those
  is a separate, tracked change (#311) — a residual British spelling is a
  defect to be fixed, not a precedent to be matched.
- **Changing a spelling is never local to one file.** Anything quoted as
  canon by a design doc, a test, or `game/data/dialogue/*.json` must
  match the string the engine emits — see
  `docs/story/script/battle-dialogue.md` § Status Effect Notifications
  and its generator in `tools/dialogue_parser.py`.
- **`grey` is the one deliberate exception, and it is a proper noun.**
  *The Grey* is the game's name for the Pallor's drained world-state;
  *grey* is used throughout for it and for the color it names. Do not
  "correct" it to *gray*.

## Design Principles

- **Homage, not recreation.** Inspired by FF4, FF6, Chrono Trigger, and Secret of Mana — but original names, places, and characters throughout.
- **The Pendulum is a MacGuffin.** It drives the plot but has no real power. The true antagonist is Despair itself.
- **Acceptance over victory.** The thematic core is that Despair feeds on denial and resistance. Characters overcome it through acceptance, not force.
- **Color is hope.** The game's saturation tracks the emotional arc — warm in Act I, grey by Act III, new palette in the Epilogue.
- **The world remembers.** NPCs change dialogue, cities transform, returning to old locations reveals new stories. The World of Ruin moment in the Interlude reshapes everything.
- **Iterative development.** These documents are living drafts. Details will be refined as game systems and scenes are built.
