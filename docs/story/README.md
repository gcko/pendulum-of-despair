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
  description now holds: **zero** British spellings, verified by both
  greps below plus a hand check of the two families they cannot see
  (`paralys`, `centre`). The last survivor was *harbour*, six sites the
  earlier hand-listed pattern was structurally unable to find; the design
  prose in `docs/story/*.md` was swept alongside. A residual British
  spelling is therefore a defect to be fixed, not a precedent to be
  matched.
- **Enumerate the exceptions, never the defects.** A hand-written list of
  *misspellings* has now been wrong three times, because the set of words
  a writer might get wrong is open-ended. The second time,
  `catalogue|catalogued` silently missed *cataloguing* — the stem drops
  the final *e* — and that alone hid three player-facing sites
  (`script/act-i.md`, `script/npc-ambient.md`, and the shipped
  `game/data/dialogue/scene_7_the_capital.json`). The third time, the
  `-our` branch was five hard-coded stems
  (`armou|favou|honou|colou|behaviou`), so it saw nothing wrong with
  *harbour* — six sites, three of them in the shipped dialogue JSON — or
  with *flavour* in `game/scripts/entities/npc.gd`.

  Where a family admits a rule, write the rule and enumerate only the
  correct English words it over-matches. That list is closed and short,
  because it is a fact about English rather than a guess about authors.
  The `-our` family works this way:

  ```
  grep -rnoiE '\b[a-z]+ou(r|rs|red|ring|rful|rless|rable|rite)\b' \
      docs/story game/data game/scripts game/tests docs/plans docs/analysis \
    | grep -v '^docs/story/README.md:' \
    | grep -viE ':(four|hour|your|pour|downpour|outpour|sour|tour|flour|scour|devour|contour|detour|velour|dour|amour|paramour|troubadour|glamour)(s|ed|ing)?$'
  ```

  This file is excluded from both greps because it necessarily spells out
  the very words it forbids. That exclusion is the one place a British
  spelling may live in `docs/story/` — keep it to quoted examples.

  That single rule catches *harbour*, *flavour*, *neighbour*, *rumour*,
  *vapour*, *endeavour*, *splendour*, *armour* and *colour* without being
  told about any of them, and returns no false positives across the six
  trees. Requiring `ou` + an `r`-suffix + a word boundary is what keeps
  *courage*, *journey*, *mourning*, *flourish* and *tournament* out.

  The remaining families have no tractable rule yet, so they are still
  stems, and **this half of the pattern is known to be incomplete** —
  treat a clean run of it as "no *known* family regressed", not as "the
  corpus is clean":

  ```
  grep -rnoiE '\b(defenc|catalogu|travell|cancell|labell|levell|synthesis(e|es|ed|ing)|realis(e|es|ed|ing)|recognis(e|es|ed|ing)|mould)\w*' \
      docs/story game/data game/scripts game/tests docs/plans docs/analysis \
    | grep -v '^docs/story/README.md:'
  ```

  The leading `\b` is load-bearing and not decoration. Drop it — write
  `\b\w*(...)` to catch stems mid-identifier — and `levell` starts
  matching `NextLevelLabel` (`menu_ley_crystal.gd`), which is *Level* +
  *Label* and correct. If you broaden the pattern that way to hunt a
  suspected miss, read the extra hits as identifiers first.

  The same boundary is why the sweep never sees a British spelling that
  is already *inside* an identifier: `_` is a word character, so the
  `command_cancelled` signal in `game/scripts/ui/battle_ui.gd` and
  `game/scripts/ui/battle_command_menu.gd` does not match `cancell`.
  That omission is correct and should stay. Renaming a signal is an API
  change with call sites in other files — `battle_manager.gd` connects
  to it — not a prose fix, so it belongs in its own commit under its own
  review rather than folded into a spelling sweep.

  A general `-ise/-isation` rule was tried and rejected: *rising*,
  *sunrise* and *promising* flood it, and the exception list needed to
  suppress them is longer and less stable than the stems it replaces.
  Two more families are deliberately absent — `paralys` collides with the
  correct *analysis* / *paralysis*, and `centre` with the proper noun
  *Centre*. Both are clean today (checked by hand), but nothing in the
  patterns above will tell you when they stop being clean.

  `grey` and its proper nouns (`Greyveil`, `Greyvale`, `Greywood`, the
  `grey_*` data identifiers) are correct and are excluded on purpose.

  **The sweep covers six trees, and only three things sit outside it.**
  `docs/plans/` and `docs/analysis/` were added by #375, which found the
  earlier classification wrong: it had filed them alongside
  `docs/superpowers/` as dated records, when neither is one.
  `docs/superpowers/README.md` § Where the live answers are names
  `docs/plans/` as the home of architecture decisions still in force,
  `docs/plans/technical-architecture.md` is edited under the current
  milestone, and `docs/analysis/game-dev-gaps.md` is re-measured under
  `scripts/quality-gates/check_stale_counts.py`. Holding no player-facing
  strings was never a reason to leave them unchecked — it only means a
  hit in them is a doc defect rather than a shipped one — and leaving
  them unchecked is precisely how five sites survived two sweeps. So the
  stated scope and the scanned scope now name the same six trees; widen
  both together or neither, because a scope that claims more than it
  checks is worse than a narrow one.

  The three that remain outside are frozen and must stay that way:
  `docs/references/scripts/`, which quotes the published scripts of other
  games verbatim; `docs/superpowers/`, whose dated records are never
  corrected after the fact (see `docs/superpowers/README.md`); and
  closed-issue titles. All three record what was written at the time, so
  a British spelling in them is history, not a defect.

  Within the six trees the two patterns return a residue, and what is
  worth checking about it is its *character*, not its size: every hit is
  doc prose, a code comment, or an assertion message, and none is a
  string the engine emits. **No count is written here on purpose.** One
  used to be, and it was wrong inside a week — the residue moves every
  time a branch in this wave lands a fix or writes a new comment, and a
  number typed into prose cannot notice either event. Run the two
  commands above for the current set, then sort it against the two lists
  below.

  - **#387 owns the `game/scripts/` comment sites**
    (`cutscene_commands.gd`, `cutscene_handler.gd`, `cutscene_player.gd`,
    which holds two, `npc.gd`, `party_state.gd`, `party_crystals.gd`,
    `progression_helpers.gd`) and the one in `docs/story/progression.md`.
  - **#378 owns the `game/tests/` comment and assertion-message text**
    in `test_dialogue_conditions.gd`, which holds three,
    `test_menu_ui_structure.gd`, `test_npc.gd` and
    `test_stat_capsules.gd`. Its list also named `behaviour` in
    `docs/plans/technical-architecture.md`; an earlier branch in this
    wave fixed that one, so the issue now describes one site more than
    the tree holds.

  Both sets sit in files owned by other in-flight branches, which is why
  they are tracked rather than fixed here.

  Anything the greps return that is not in those two lists is new, and by
  the rule above it is a defect rather than residue. Some already exist:
  `behaviour` in the header comment of `game/tests/test_battle_regressions.gd`
  and `behaviours` in a comment in `game/tests/test_script_layout.gd` were
  both written by *this* wave, in the commit that split the oversized test
  files, and neither is tracked by #378 or #387 — one of the two files did
  not exist when those issues were filed. A sweep can introduce the thing
  it is sweeping for, so "residue" is not a synonym for "somebody else's".

  The absence of hits is still not a proof of cleanliness: the stem half
  of the pattern only knows the families it has been told about.

  Two decisions the sweep had to make, recorded so they are not
  re-litigated:

  - **`Catalogue` is not a proper noun.** It was The Index's AI mode name
    in `bestiary/bosses.md`, but every other mode name in that file is an
    ordinary capitalized English word (*Normal*, *Reconstructing*,
    *Shattered*, *Waiting*, *Scholar*), not a coined one like *Greyveil*;
    `game/data/enemies/act_iii.json` does not encode a mode name at all,
    so nothing in the engine pinned the spelling; and the shipped
    `scene_7_the_capital.json` already said *cataloging*. It is now
    *Catalog*, matching the lowercase prose two lines below it.
  - **`dialogue` and `analogue` stay.** The sweep is per-word by dominant
    American usage, not by suffix family. *Catalog* is the dominant
    American form; *dialogue* also is (*dialog* is the UI-widget
    variant), and *analogue* in the sense "counterpart" is standard in
    American prose. A `-logue → -log` family rule would be wrong for two
    of the three, which is why no such rule is written here.
- **Changing a spelling is never local to one file.** Anything quoted as
  canon by a design doc, a test, or `game/data/dialogue/*.json` must
  match the string the engine emits — see
  `docs/story/script/battle-dialogue.md` § Status Effect Notifications.
  Player-facing strings are duplicated between the script markdown and
  the shipped dialogue JSON, so **both copies move in the same commit**.
  **Nothing generates one from the other.** This bullet used to send you
  to `tools/dialogue_parser.py`; that script was deleted in #364, because
  it had not completed a run since 2026-04-05 — `3b2bcc49` introduced a
  `NameError` that fired *after* it had written output, and the two commits
  that touched the script afterwards only hand-edited a hardcoded string
  list — and because it unlinked every `game/data/dialogue/*.json`
  before parsing, so a re-run deleted 31 shipped files. Those 31 are
  exactly the files added to that directory since the crash: every
  Scene 7 beat, the Ember Vein and Fenmother scenes, the Valdris shop
  NPCs. On top of that, 121 shipped `lines[]` strings have no verbatim
  source anywhere in `docs/story/script/*.md` at all (#380), so no
  generator could emit them. The JSON is authored, not derived, and the
  evidence for that is recorded in `tools/README.md`.
  What compares the two corpora is
  `scripts/quality-gates/check_dialogue_sync.py`, quality gate J, which
  runs on pre-push (#379): every string in a `lines[]` array under
  `game/data/dialogue/` must occur verbatim — exact substring, no case
  folding, no whitespace normalization — somewhere in
  `docs/story/script/*.md`, so respelling one copy and not the other turns
  the gate red. It enforces that direction only: script prose with no
  shipped line is fine, a match in any script file counts, and only
  `lines[]` is read, which leaves the `choice.label` and `text` strings in
  that directory unchecked (#398). The 121 shipped strings that already
  had no markdown source are held in the gate's shrink-only
  `KNOWN_ORPHANS` list — 121 strings are pinned today — and the gate fails
  both when a new orphan appears and when a pin stops being an orphan, so
  entries come off only as #380 back-fills them. A pinned line is a line
  the gate cannot see change. The one test that checks a shipped dialogue
  string against the engine — `game/tests/test_status_effects.gd` — pins
  the paralysis notification to the adjective
  `game/scripts/combat/status_effects.gd` emits; it never opens
  `docs/story/script/*.md`, so it catches JSON-versus-engine drift and
  nothing else. #311 predates gate J and had to move each swept spelling
  in both corpora itself, which is also why `items.md` § Key Items and
  `game/data/items/key_items.json` were swept in one commit — half a fix
  is worse than none.
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
