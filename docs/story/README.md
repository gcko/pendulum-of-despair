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
- **The player-facing corpus nearly matches the rule, and the gap is
  named.** This bullet used to read "a rule for new writing, not a
  description of the corpus"; #301 swept the `color` / `paralyzed` /
  `centered` / `behavior` families and #311 swept the rest. It then read
  "**zero** British spellings" for both corpora a player can actually
  read. That was true of the families anyone was checking and false as
  soon as #400 widened them, which is the failure mode this whole section
  keeps repeating: a claim measured by a narrower instrument than the
  claim. Stated at the width Gate K actually checks:
  `game/data/dialogue/*.json` holds **zero** hits in all four families;
  `docs/story/script/*.md` holds **two**, *greyed* in
  `battle-dialogue.md` and *greying* in `interlude.md`, both stage
  direction rather than shipped `lines[]` strings, both pinned and
  tracked by #411. Two families remain outside any instrument
  (`paralys`, `centre`) and are clean by hand check only. The last
  survivor of the `-our` sweep was *harbour*, six sites the earlier
  hand-listed pattern was structurally unable to find; the design prose
  in `docs/story/*.md` was swept alongside. A residual British spelling
  is a defect to be fixed, not a precedent to be matched.
- **Enumerate the exceptions, never the defects.** A hand-written list of
  *misspellings* has now been wrong four times, because the set of words
  a writer might get wrong is open-ended. The fourth time is why this
  section ends in a gate rather than a grep — see **These patterns are a
  gate now, not a note** below, and read the rest of this bullet as the
  reasoning behind `scripts/quality-gates/check_spelling.py` rather than
  as instructions to run anything by hand. The second time,
  `catalogue|catalogued` silently missed *cataloguing* — the stem drops
  the final *e* — and that alone hid three player-facing sites
  (`script/act-i.md`, `script/npc-ambient.md`, and the shipped
  `game/data/dialogue/scene_7_the_capital.json`). The third time, the
  `-our` branch was five hard-coded stems
  (`armou|favou|honou|colou|behaviou`), so it saw nothing wrong with
  *harbour* — six sites, three of them in the shipped dialogue JSON — or
  with *flavour* in `game/scripts/entities/npc.gd`.

  Where a family admits a rule, write the rule and enumerate only the
  correct English words it over-matches. That list is short, because it
  is a fact about English rather than a guess about authors — but it is
  **not closed**, and this section claimed twice that it was. See "What
  the over-match lists do not cover" below before you trust a hit.
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
  trees *as they stand today* — which is a measurement, not a property of
  the rule. Requiring `ou` + an `r`-suffix + a word boundary is what keeps
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

  **These patterns are a gate now, not a note.**
  `scripts/quality-gates/check_spelling.py` — Quality Gate K, run from
  `.husky/pre-push` — applies every family in this section to the six
  trees on every push. It exists because nothing ran the two commands
  above: five sweeps each found residue the previous one missed, and two
  of them introduced fresh British spellings in the very commit that was
  sweeping (#400). Stop hand-auditing against the greps; run the gate.
  Where the gate and this prose disagree, the gate is the one that ships,
  and the prose is the defect.

  A general `-ise`/`-isation` rule was tried and rejected once, on the
  grounds that *rising*, *sunrise* and *promising* flood it. #400
  overturned that. The flood is real, and its common core is small enough
  to enumerate, which makes it the same shape as the `-our` over-match
  list above — though neither list is closed, as #413 showed.
  The cost of leaving it out was concrete: the stem half held `realis`
  and `recognis` and nothing else, so it could not see *optimise*,
  *organisation*, *summarise*, *visualise* or a dozen other members of
  the family, and *optimises* sat in
  `game/scripts/util/party_equipment.gd` until #387 found it by hand.
  The rule and its exception list now live in `ALLOWED_ISE_LEMMAS` in
  `scripts/quality-gates/check_spelling.py`, where they are tested rather
  than argued about.

  **What the over-match lists do not cover.** #413 found this section and
  the gate both calling the over-match lists a "closed set" that could not
  go stale. They are not closed. The lists were expanded over *suffixes*
  while the patterns match any *prefix*, so *imprecise*, *unsurprised*,
  *unpromising*, *upraised*, *undisguised* and *overpromise* — six
  ordinary American words — were reported as British spellings, and the
  failure line told the author to write the American spelling of a word
  already spelled correctly.

  The prefix half is now a rule (`ALLOWED_PREFIXES`), so one lemma covers
  its prefixed and inflected forms together. What is left is genuinely
  open. Measured against `/usr/share/dict/words`, the `-our` rule still
  over-matches 55 correct entries and `-ise`/`-isation` 103 — nearly all
  archaic, dialectal or foreign — and the stem family, which has no prefix
  structure to exploit, still over-matches 20 after `ALLOWED_STEM`. The
  entry that mattered there was *cancellation*: American English drops an
  `l` in *canceled* but keeps both in *cancellation*, so the `cancell`
  stem was flagging a word American style guides require.

  **So a hit is not proof of a misspelling.** If the flagged word really
  is correct American English, add its lemma to the family's allow-list in
  `scripts/quality-gates/check_spelling.py`. Do not reword the sentence to
  dodge the gate, and do not pin it in `KNOWN_VIOLATIONS` — that list is
  for British spellings awaiting a sweep, not for the gate's own misses.

  Two families are still deliberately absent — `paralys` collides with
  the correct *analysis* / *paralysis*, and `centre` with the proper noun
  *Centre*. Both are clean today (checked by hand), but neither the
  patterns above nor the gate will tell you when they stop being clean.

  **The `grey` carve-out, exactly.** The bare word `grey`, the coined
  proper nouns built on it (*Greyveil*, *Greyvale*, *Greywood*, the
  world-state *The Grey*, *Grey Remnant*, *Grey Cleaver*, *Grey Keeper*)
  and the `grey_*` data identifiers are correct and are never flagged.
  `grey` in this setting names the Pallor world-state, and *Grey Remnant*
  is a shipped Ley Crystal name in `game/data/ley_crystals.json`, so a
  sweep that "fixed" it would rename an item the player can read. What
  *is* swept is the inflected color word — *greyed*, *greying*, *greyer*,
  *greyest*, *greyish*, *greys*, *greyscale* — which is what #400 found
  in `menu_overlay.gd` and `battle_command_menu.gd` and which neither
  grep above could see. The gate encodes the carve-out structurally: its
  pattern requires one of those suffixes, so bare `grey`, `Greyveil` and
  `grey_residue` cannot match it. Read the consequence plainly — a clean
  gate run is **not** a claim that this corpus spells the color word
  *gray*. The 844 bare `grey` tokens are outside the pattern by design.

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

  **The residue the two greps tracked is gone.** #387 fixed the
  `game/scripts/` comment sites and the one in
  `docs/story/progression.md`; #399 and #378 fixed the six `game/tests/`
  comment and assertion-message sites (`test_dialogue_conditions.gd`,
  which held three, `test_menu_ui_structure.gd`, `test_npc.gd`,
  `test_stat_capsules.gd`); and the `behaviour` sites this wave wrote
  into `test_battle_regressions.gd` and `test_script_layout.gd` — a sweep
  can introduce the thing it is sweeping for — went with an earlier
  branch. Both greps return nothing today. Nothing about that is
  self-sustaining, which is the whole reason Gate K exists: the previous
  four times this paragraph said the tree was clean, it was a hand check
  that nothing re-ran.

  **What the gate carries instead is a ratchet.** The two families #400
  added — `-ise`/`-isation` and the inflected `grey` — landed on a corpus
  that had never been checked for either, so **44 occurrences are pinned**
  in `KNOWN_VIOLATIONS` in `scripts/quality-gates/check_spelling.py`,
  across 20 files. What is worth knowing about them is their *character*,
  not their size: every one is doc prose or a code comment in a file
  owned by another in-flight branch, and none is a string the engine
  emits — the two `docs/story/script/` pins are stage direction and a UI
  note, not `lines[]` dialogue. The pin fails at both ends: a new hit
  fails, and a pin whose count no longer matches its file — because the
  fix landed — also fails. So the list can only shrink, and no entry
  outlives its reason. Pinning is not how a new violation gets in; the
  fix for one is the American spelling. #411 burns down the 41
  inflected-`grey` pins and #412 the three `-ise` ones; the authoritative
  list is the code, not this paragraph, which is the point.

  The absence of hits is still not a proof of cleanliness. The gate knows
  four families; `paralys` and `centre` are not among them, and it does
  not look at the bare word `grey` at all.

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
