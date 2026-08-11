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
- **The player-facing corpus now matches the rule.** This bullet used to
  read "a rule for new writing, not a description of the corpus"; #301
  swept the `color` / `paralyzed` / `centered` / `behavior` families and
  #311 swept the rest, so for the two corpora a player can actually read —
  `docs/story/script/*.md` and `game/data/dialogue/*.json` — the
  description now holds: **zero** British spellings, verified by the
  regenerating grep below. The design prose in `docs/story/*.md` was
  swept with them. A residual British spelling is therefore a defect to
  be fixed, not a precedent to be matched.
- **Do not scope a sweep from a hand-written word list; regenerate it.**
  A hand-written list has been wrong twice. The second time,
  `catalogue|catalogued` silently missed *cataloguing* — the stem drops
  the final *e* — and that alone hid three player-facing sites
  (`script/act-i.md`, `script/npc-ambient.md`, and the shipped
  `game/data/dialogue/scene_7_the_capital.json`). Match on stems:

  ```
  grep -rnoiE '\b(armou|favou|honou|colou|behaviou|defenc|catalogu|travell|cancell|labell|levell|synthesis(e|es|ed|ing)|realis(e|es|ed|ing)|recognis(e|es|ed|ing)|mould)\w*' \
    docs/story game/data game/scripts game/tests
  ```

  Stems, not whole words — but stems chosen so they do *not* collide
  with `grey` and its proper nouns (`Greyveil`, `Greyvale`, `Greywood`,
  the `grey_*` data identifiers) or with *analysis* / *paralysis*, all of
  which are correct. Widening the pattern past this list is how the
  false positives get in. Two trees are outside the sweep entirely and
  must stay that way: `docs/references/scripts/`, which quotes the
  published scripts of other games verbatim, and the dated records in
  `docs/plans/`, `docs/superpowers/`, `docs/analysis/` and closed-issue
  titles, which record what was written at the time.

  Every hit the pattern still returns is a known defect tracked in
  #363 — two shipped item strings in `game/data/items/` and their paired
  copy in `items.md`, `progression.md`, `bestiary/bosses.md` (where
  `Catalogue` is also The Index's AI *mode name*, so decide whether that
  one is a proper noun before touching it), and non-emitting comments and
  test-assertion messages under `game/scripts/` and `game/tests/`. If the
  grep returns anything not on that list, it is new and it is a defect.
- **Changing a spelling is never local to one file.** Anything quoted as
  canon by a design doc, a test, or `game/data/dialogue/*.json` must
  match the string the engine emits — see
  `docs/story/script/battle-dialogue.md` § Status Effect Notifications.
  Player-facing strings are duplicated between the script markdown and
  the shipped dialogue JSON, so **both copies move in the same commit**.
  Do not reach for `tools/dialogue_parser.py` to do it for you: the
  parser currently crashes, and its output has diverged from the
  committed JSON badly enough that running it deletes shipped files
  (#364). Until that is resolved, edit both copies by hand and prove they
  agree — `items.md` § Key Items and `game/data/items/key_items.json` are
  deliberately still British together for exactly this reason, because
  half a fix is worse than none.
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
