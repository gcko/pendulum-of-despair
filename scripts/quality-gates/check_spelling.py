#!/usr/bin/env python3
"""Quality Gate K: American-English spelling.

`docs/story/README.md` § Writing Conventions has required American spellings
since #301. Until this gate landed the rule was enforced by two grep
commands *written down in that document*, which nothing ran. Five separate
sweeps (#301, #311, #363/#375, #387, #378/#399) each found residue the
previous one missed, and two of them introduced fresh British spellings in
the very commits that were sweeping. This gate is what turns the rule from
prose into a check.

**Detection is by family, not by word list.** A hand-written list of
misspellings has been wrong four times here, because the set of words an
author might get wrong is open-ended, and because a list of *whole words*
cannot see inflections it was not told about: `catalogue|catalogued` was
structurally unable to match *cataloguing* (the stem drops the final `e`),
and that one gap hid three shipped player-facing strings. So every family
below is a **rule over stems and suffixes**, and what is enumerated is a
list of *correct English words the rule over-matches*.

**That enumeration is not closed, and this file used to claim it was.**
#413 disproved the claim: the allow-lists were expanded over suffixes only,
while the patterns match any prefix, so *imprecise, unsurprised,
unpromising, upraised, undisguised* and *overpromise* — six ordinary
American words — were reported as British spellings, under a remediation
line that told the author to "write the American spelling" of a word they
had already spelled correctly. Three live *imprecise* sites sit in
`docs/issues/`, one scope widening away.

The prefix half of that gap is now a rule (`ALLOWED_PREFIXES`), which is
the general fix: an allow-list entry covers its prefixed and inflected
forms together, so *promise* alone answers for *promising*, *unpromising*
and *overpromised*. What remains after the rule is genuinely open, and is
stated here rather than papered over: measured against
`/usr/share/dict/words`, the `-our` rule still over-matches 55 entries and
`-ise`/`-isation` 103, nearly all archaic, dialectal or foreign
(*aportoise*, *calambour*, *ardoise*). The stem family has no prefix
structure to exploit, so its over-matches are enumerated in `ALLOWED_STEM`
— chiefly *cancellation*, which American English spells with both `l`s
even though it spells *canceled* with one — and 20 dictionary entries
still get through.

**So a hit is not proof of a misspelling.** When the flagged word really is
correct American English, the fix is to add its lemma to the family's
allow-list — never to reword the sentence around the gate, and never to pin
it in `KNOWN_VIOLATIONS`. The failure message says both remedies out loud.

**The four families.**

1. `-our` (#375's rule, carried over verbatim): stem + `ou` + an `r`-suffix.
   Catches *colour, behaviour, harbour, flavour, neighbour, rumour, vapour,
   endeavour, splendour, armour, honour* without being told about any of
   them. Requiring the `r`-suffix and a word boundary is what keeps
   *courage*, *journey*, *mourning*, *flourish* and *tournament* out.
2. `-ise` / `-isation` (#400): stem + `is` + a verb/noun suffix. Catches
   *organise, organisation, optimise, normalise, specialise, prioritise,
   summarise, utilise, minimise, maximise, criticise, apologise,
   standardise, visualise, emphasise, realise, recognise, synthesise*.
   § Writing Conventions previously recorded this family as *tried and
   rejected* because *rising*, *sunrise* and *promising* flood it. #400
   overturned that: the flood is real but its common core is small enough
   to write out in `ALLOWED_ISE_LEMMAS` and test, rather than left to a
   stem list that misses fourteen of the sixteen words above. #413 added
   the prefix rule the lemma list needs to cover *unsurprised* and
   *imprecise*; see the note on openness above.
3. `grey` (#400), narrowly. See "The grey carve-out" below.
4. Residual stems with no tractable rule: `defenc`, `catalogu`, `travell`,
   `cancell`, `labell`, `levell`, `mould`. Each is a *stem* with an open
   suffix, so `catalogu` matches *catalogue, catalogued, catalogues* and
   *cataloguing* alike. `realis`, `recognis` and `synthesis(e)` used to
   live here and are now covered by family 2.

**The `\\b` at the front of every pattern is load-bearing and not
decoration.** Drop it and `levell` starts matching `NextLevelLabel`, which
is *Level* + *Label* and correct. The same boundary is why a British
spelling already inside an identifier is not swept: `_` is a word
character, so the `command_cancelled` signal does not match `cancell`. That
omission is deliberate — renaming a signal is an API change with call sites
in other files, not a prose fix.

**The grey carve-out.** `docs/story/README.md` § Writing Conventions
records exactly one exception, and this gate encodes exactly it, no wider
and no narrower: the bare word `grey`, the coined proper nouns built on it
(*Greyveil*, *Greyvale*, *Greywood*, and the world-state *The Grey* itself,
*Grey Remnant*, *Grey Cleaver*, *Grey Keeper*), and the `grey_*` data
identifiers are correct and are not flagged. `grey` in this setting names
the Pallor world-state, and *Grey Remnant* is a shipped Ley Crystal name in
`game/data/ley_crystals.json` — a sweep that "fixed" it would rename an
item the player can read. What *is* flagged is the inflected color word:
`greyed`, `greying`, `greyer`, `greyest`, `greyish`, `greys`, `greyscale`.
The pattern expresses the carve-out structurally — it requires one of those
suffixes, so bare `grey`, `Greyveil` and `grey_residue` cannot match it —
and `test_spelling.py` asserts each carved-out form stays clean.

Two consequences of that narrowness, stated plainly so no one reads a
guarantee into this gate that the code does not deliver:

- A clean run is **not** a claim that the corpus spells the color word
  `gray`. 844 bare `grey` tokens are outside the pattern by design.
- Two families § Writing Conventions calls out as untractable are still
  absent: `paralys` collides with the correct *analysis* / *paralysis*, and
  `centre` with the proper noun *Centre*. Nothing here will tell you when
  they stop being clean.

**Scope: the same six trees § Writing Conventions names** — `docs/story`,
`game/data`, `game/scripts`, `game/tests`, `docs/plans`, `docs/analysis`.
`docs/story/README.md` is excluded from the scan because it necessarily
spells out the very words it forbids; that is the one place in `docs/story`
a British spelling may live. Three trees stay outside on purpose, and all
three are dated records that are never corrected after the fact:
`docs/references/scripts/` (verbatim quotes of other games' published
scripts), `docs/superpowers/` (see its README), and closed-issue titles.
`docs/plans/` and `docs/analysis/` are *in* scope: #375 found the earlier
"dated record" classification wrong for both.

**The ratchet.** 44 violations across 20 files already existed when this
gate landed, all of them doc prose in files owned by other in-flight
branches. A gate that fails on pre-existing hits is a gate nobody can
switch on, so those are pinned in `KNOWN_VIOLATIONS` below with their
counts. The pin fails at *both* ends: an unpinned hit fails, a pinned count
that grows fails, and a pinned count that *shrinks* — because the fix
landed — also fails, so the list can only shrink and no entry outlives its
reason. Pinning is not a way to add a violation; the fix for a new one is
the American spelling.

**Non-vacuity.** A scan that reads nothing reports nothing wrong, which is
indistinguishable from a clean tree (#365). #400 named the specific trap:
`game/scripts/*.gd` matches zero files, because all 89 live one level down,
so a walk that stops descending reports a false clean. This scan therefore
asserts it read a non-trivial corpus — total files, total characters, and a
per-tree floor so a tree cannot silently drop out — and fails if any floor
is breached. Repair the walk when that fires; do not lower a floor.

Exit code 0 = pass, 1 = a new violation, a stale pin, or a degenerate scan.
"""
import os
import re
import sys
from typing import Callable, NamedTuple

TREES: tuple[str, ...] = (
    "docs/story",
    "game/data",
    "game/scripts",
    "game/tests",
    "docs/plans",
    "docs/analysis",
)

# This file spells out the words it forbids, so it cannot be scanned.
EXCLUDED_FILES: frozenset[str] = frozenset({"docs/story/README.md"})

SCANNED_SUFFIXES: tuple[str, ...] = (".md", ".json", ".gd")

# Non-vacuity floors — see module docstring. Set well below what the repo
# holds today (474 files / 5.5M characters; the smallest tree,
# docs/analysis, holds 2 files) so ordinary authoring never trips them, and
# high enough that a walk which stops descending cannot pass: the six trees
# hold only 139 files at their top level, which is below MIN_FILES.
MIN_FILES = 300
MIN_CHARS = 3_000_000
MIN_FILES_PER_TREE = 2


def _expand(lemma: str, suffixes: tuple[str, ...]) -> set[str]:
    """Inflect *lemma* over *suffixes*, honoring a silent final ``e``.

    Written as an expansion rather than a literal word list because that is
    the bug this whole gate exists to prevent: a list of whole words cannot
    match an inflection nobody thought to type, which is how
    ``catalogue|catalogued`` missed *cataloguing*.
    """
    forms = {lemma}
    for suffix in suffixes:
        if lemma.endswith("e") and suffix.startswith(("e", "i")):
            forms.add(lemma[:-1] + suffix)
        else:
            forms.add(lemma + suffix)
    return forms


# English builds words on the front as well as the back, and #413 found the
# allow-lists expanded only over the back: every lemma was inflected over
# its suffixes, while the patterns matched any prefix, so `surprise` covered
# `surprised` but not `unsurprised`. Enumerating prefixed forms would repeat
# the `cataloguing` mistake at the other end of the word, so this is a rule.
#
# The set is the productive English prefixes, and it is deliberately short:
# every entry widens what the gate accepts, so the bar is "attaches
# generatively to ordinary verbs and adjectives". Archaic ones (`be-` as in
# *beclamour*) are left out, because `beclamour` IS British and flagging it
# is right.
ALLOWED_PREFIXES: tuple[str, ...] = (
    "un", "re", "im", "in", "dis", "mis", "non", "over", "under", "up",
    "out", "pre", "post", "co", "de", "sub", "inter", "intra", "anti",
    "semi", "self", "counter", "fore", "mid", "multi", "trans", "after",
    "ex",
)

# A stripped remainder shorter than this is not a word carrying the meaning,
# it is a coincidence of letters, so `co` + `ise` cannot launder anything.
MIN_STEM_AFTER_PREFIX = 3


def allowed_with_prefixes(word: str, allowed: frozenset[str]) -> bool:
    """True when *word* is an allowed form, possibly behind known prefixes.

    Strips repeatedly, so *reappraised* and *unsurprised* both reduce. This
    cannot launder a British spelling: stripping only ever removes a prefix,
    and the remainder still has to land in *allowed*, which holds no British
    form. `deprioritise` reduces to `prioritise`, which is not allowed, so it
    stays flagged — verified in `test_spelling.py` against every British
    lemma the tests know, under every prefix above.
    """
    if word in allowed:
        return True
    seen = {word}
    frontier = [word]
    while frontier:
        current = frontier.pop()
        for prefix in ALLOWED_PREFIXES:
            if not current.startswith(prefix):
                continue
            rest = current[len(prefix):]
            if len(rest) < MIN_STEM_AFTER_PREFIX:
                continue
            if rest in allowed:
                return True
            if rest not in seen:
                seen.add(rest)
                frontier.append(rest)
    return False


# --- Family 1: -our -----------------------------------------------------
# The rule, from docs/story/README.md § Writing Conventions.
OUR_PATTERN = re.compile(
    r"\b[a-z]+ou(?:r|rs|red|ring|rful|rless|rable|rite)\b", re.IGNORECASE
)

# Correct English words the rule over-matches, as lemmas: ALLOWED_PREFIXES
# and _expand() carry each one to its prefixed and inflected forms. These are
# facts about English rather than observations about this repo, so unlike
# KNOWN_VIOLATIONS they do not go stale — but the list is not closed, and a
# correct word missing from it is a gate defect to fix here, not a sentence
# to reword. See "That enumeration is not closed" in the module docstring.
ALLOWED_OUR_LEMMAS: tuple[str, ...] = (
    "four",
    "hour",
    "your",
    "pour",
    "downpour",
    "outpour",
    "sour",
    "tour",
    "flour",
    "scour",
    "devour",
    "contour",
    "detour",
    "velour",
    "dour",
    "amour",
    "paramour",
    "troubadour",
    "glamour",
)
_OUR_SUFFIXES = ("s", "ed", "ing", "ful", "less", "able", "ite")
ALLOWED_OUR: frozenset[str] = frozenset(
    form
    for lemma in ALLOWED_OUR_LEMMAS
    for form in _expand(lemma, _OUR_SUFFIXES)
)

# --- Family 2: -ise / -isation ------------------------------------------
ISE_PATTERN = re.compile(
    r"\b[a-z]+is(?:e|es|ed|ing|ation|ations|ational)\b", re.IGNORECASE
)

# `-wise` is a live adverb-forming suffix in English (otherwise, likewise,
# clockwise, streetwise, lengthwise...). It is a rule, so it is written as
# one rather than enumerated; no British `-ise` verb ends in `wise`.
WISE_SUFFIX = "wise"

ALLOWED_ISE_LEMMAS: tuple[str, ...] = (
    "advertise",
    "advise",
    "anise",
    "appraise",
    "apprise",
    "arise",
    "braise",
    "bruise",
    "cerise",
    "chaise",
    "chastise",
    "circumcise",
    "comprise",
    "compromise",
    "concise",
    "cruise",
    "demise",
    "despise",
    "devise",
    "disguise",
    "enfranchise",
    "enterprise",
    "excise",
    "exercise",
    "exorcise",
    "expertise",
    "franchise",
    "guise",
    "improvise",
    "incise",
    "iris",
    "malaise",
    "mayonnaise",
    "merchandise",
    "moonrise",
    "mortise",
    "noise",
    "paradise",
    "poise",
    "porpoise",
    "praise",
    "precise",
    "premise",
    "promise",
    "raise",
    "reprise",
    "reraise",
    "revise",
    "rise",
    "sunrise",
    "supervise",
    "surmise",
    "surprise",
    "televise",
    "tortoise",
    "treatise",
    "turquoise",
    "uprise",
    "valise",
    "vise",
)
_ISE_SUFFIXES = ("s", "d", "es", "ed", "ing")
ALLOWED_ISE: frozenset[str] = frozenset(
    form
    for lemma in ALLOWED_ISE_LEMMAS
    for form in _expand(lemma, _ISE_SUFFIXES)
)

# --- Family 3: grey -----------------------------------------------------
# The carve-out is structural: this pattern REQUIRES one of the inflection
# suffixes, so the bare word `grey`, the proper nouns `Greyveil` /
# `Greyvale` / `Greywood` / `Grey Remnant` and the `grey_*` data
# identifiers cannot match it. `_` is a word character, which is what keeps
# `grey_residue` out. See "The grey carve-out" in the module docstring.
GREY_PATTERN = re.compile(
    r"\bgrey(?:s|ed|ing|er|est|ish|scale)\b", re.IGNORECASE
)

# --- Family 4: residual stems -------------------------------------------
# No tractable rule yet, so these stay stems — but they are STEMS with an
# open suffix, not whole words, which is the fix for the `cataloguing` miss.
BRITISH_STEMS: tuple[str, ...] = (
    "defenc",
    "catalogu",
    "travell",
    "cancell",
    "labell",
    "levell",
    "mould",
)
STEM_PATTERN = re.compile(
    r"\b(?:" + "|".join(BRITISH_STEMS) + r")[a-z]*\b", re.IGNORECASE
)

# The stem family over-matches too, and this list is the same kind of thing
# as ALLOWED_OUR_LEMMAS — not closed, just what English is known to spell
# this way. `cancellation` is the one that matters: American English drops
# an `l` in *canceled* and *canceling* but keeps both in *cancellation*, so
# the `cancell` stem flags a word every American style guide requires. That
# is a plausible word for a menu or quest doc, unlike the anatomy and botany
# terms (*cancellous*, *labellum*, *levelly*) that the same stems also
# admit. Prefix-stripping does not help here — these are not prefixed forms
# — so this family is enumerated the old way.
ALLOWED_STEM: frozenset[str] = frozenset(
    {
        "cancellation",
        "cancellations",
        "cancellous",
        "labellum",
        "labella",
        "levelly",
    }
)


class Family(NamedTuple):
    """One detection rule plus the correct English words it over-matches."""

    name: str
    pattern: re.Pattern[str]
    allowed: Callable[[str], bool]


FAMILIES: tuple[Family, ...] = (
    Family(
        "-our",
        OUR_PATTERN,
        lambda w: allowed_with_prefixes(w, ALLOWED_OUR),
    ),
    Family(
        "-ise/-isation",
        ISE_PATTERN,
        lambda w: (
            w.endswith(WISE_SUFFIX) or allowed_with_prefixes(w, ALLOWED_ISE)
        ),
    ),
    Family("grey", GREY_PATTERN, lambda w: False),
    Family("stem", STEM_PATTERN, lambda w: w in ALLOWED_STEM),
)

# The ratchet, keyed by repo-relative path, then by the lowercased offending
# word, to the number of times it occurs in that file. Keyed by word-and-
# count rather than by line number on purpose: line numbers churn every time
# a sibling branch edits a doc, and a ratchet that goes stale on unrelated
# edits gets deleted rather than fixed.
#
# Every entry below is doc prose or a code comment in a file owned by
# another in-flight branch of the "Infra & Docs II" milestone. None is a
# string the engine emits: the two `docs/story/script/` entries are stage
# direction and a UI note, not `lines[]` dialogue.
#
# This list may shrink. It may not grow — a new hit is a defect, and the fix
# is the American spelling, not a pin. Drop or decrement an entry in the same
# commit that fixes its sites; the gate fails on a count that no longer
# matches, so a stale pin cannot sit here unnoticed. #411 burns down the 41
# inflected-`grey` pins, #412 the three `-ise` ones.
KNOWN_VIOLATIONS: dict[str, dict[str, int]] = {
    "docs/analysis/game-dev-gaps.md": {"greyed": 3},
    "docs/story/abilities.md": {"generalisation": 1, "greyed": 1},
    "docs/story/accessibility.md": {"greyed": 1},
    "docs/story/audio.md": {"greyed": 1},
    "docs/story/biomes.md": {"greyer": 1, "greys": 1},
    "docs/story/city-carradan.md": {"greyer": 1},
    "docs/story/city-thornmere.md": {"greying": 2},
    "docs/story/city-valdris.md": {"greyed": 1},
    "docs/story/crafting.md": {"greyed": 1},
    "docs/story/dungeons-world.md": {"greyscale": 1},
    "docs/story/dynamic-world.md": {"greyed": 2, "greyer": 2, "greying": 3},
    "docs/story/events.md": {"greyscale": 2},
    "docs/story/interiors.md": {"greyed": 3, "greying": 2, "greys": 1},
    "docs/story/items.md": {"greyed": 1},
    "docs/story/save-system.md": {"greys": 1},
    "docs/story/script/battle-dialogue.md": {"greyed": 1},
    "docs/story/script/interlude.md": {"greying": 1},
    "docs/story/ui-design.md": {"greyed": 7, "greying": 1},
    "game/scripts/autoload/save_manager.gd": {"materialising": 1},
    "game/scripts/ui/dialogue_box.gd": {"materialises": 1},
}


class Hit(NamedTuple):
    """One flagged token: where it is, what it is, which rule found it."""

    path: str
    line: int
    word: str
    family: str


def iter_scanned_files(trees: tuple[str, ...] = TREES) -> list[str]:
    """Return every scannable file under *trees*, recursively, sorted.

    ``os.walk`` rather than a glob: #400 recorded that
    ``game/scripts/*.gd`` matches zero files because all 89 live one level
    down, and a non-recursive walk would report a clean tree it never read.
    """
    found: list[str] = []
    for tree in trees:
        for root, _dirs, files in os.walk(tree):
            for name in files:
                if not name.endswith(SCANNED_SUFFIXES):
                    continue
                path = os.path.join(root, name).replace(os.sep, "/")
                if path in EXCLUDED_FILES:
                    continue
                found.append(path)
    return sorted(found)


def scan_text(text: str, path: str) -> list[Hit]:
    """Return every British-spelling hit in *text*, one per occurrence."""
    hits: list[Hit] = []
    for lineno, line in enumerate(text.splitlines(), start=1):
        for family in FAMILIES:
            for match in family.pattern.finditer(line):
                word = match.group(0).lower()
                if family.allowed(word):
                    continue
                hits.append(Hit(path, lineno, word, family.name))
    return hits


def check_spelling(
    trees: tuple[str, ...] = TREES,
    known_violations: dict[str, dict[str, int]] | None = None,
    min_files: int = MIN_FILES,
    min_chars: int = MIN_CHARS,
    min_files_per_tree: int = MIN_FILES_PER_TREE,
) -> list[str]:
    """Verify the six trees hold no unpinned British spellings."""
    pins = KNOWN_VIOLATIONS if known_violations is None else known_violations

    paths = iter_scanned_files(trees)
    total_chars = 0
    per_tree: dict[str, int] = {tree: 0 for tree in trees}
    observed: dict[str, dict[str, int]] = {}
    hits: list[Hit] = []

    for path in paths:
        for tree in trees:
            if path == tree or path.startswith(tree.rstrip("/") + "/"):
                per_tree[tree] += 1
                break
        with open(path, encoding="utf-8", errors="replace") as handle:
            text = handle.read()
        total_chars += len(text)
        for hit in scan_text(text, path):
            hits.append(hit)
            counts = observed.setdefault(hit.path, {})
            counts[hit.word] = counts.get(hit.word, 0) + 1

    # Non-vacuity first: on a degenerate scan every pin looks stale and no
    # file looks dirty, so reporting spelling findings on top would be noise
    # layered over a result that means nothing.
    floors: list[tuple[int, int, str]] = [
        (len(paths), min_files, f"files under {', '.join(trees)}"),
        (total_chars, min_chars, "characters of scanned text"),
    ]
    floors += [
        (count, min_files_per_tree, f"files under {tree}")
        for tree, count in per_tree.items()
    ]
    vacuity = [
        f"scan read only {actual} {label} (floor {floor}) — it is not "
        f"reading the corpus it reports on, so a clean result would mean "
        f"nothing; repair the walk rather than lowering the floor"
        for actual, floor, label in floors
        if actual < floor
    ]
    if vacuity:
        return vacuity

    errors: list[str] = []

    # Report only the occurrences beyond what is pinned, and name every line
    # the word sits on so the reader has somewhere to go.
    for path in sorted(observed):
        for word in sorted(observed[path]):
            seen = observed[path][word]
            pinned = pins.get(path, {}).get(word, 0)
            if seen <= pinned:
                continue
            lines = [h.line for h in hits if h.path == path and h.word == word]
            family = next(
                h.family for h in hits if h.path == path and h.word == word
            )
            where = ", ".join(str(line) for line in lines)
            errors.append(
                f"{path}: {seen} occurrence(s) of {word!r} ({family} family) "
                f"but only {pinned} pinned in KNOWN_VIOLATIONS — line(s) "
                f"{where}. If {word!r} is a British spelling, write the "
                f"American one. If it is already correct American English "
                f"the rule over-matched, add its lemma to the {family} "
                f"allow-list in scripts/quality-gates/check_spelling.py. "
                f"Pinning it in KNOWN_VIOLATIONS is not the fix for either."
            )

    for path in sorted(pins):
        if not os.path.isfile(path):
            errors.append(
                f"{path}: KNOWN_VIOLATIONS pins {len(pins[path])} word(s) in "
                f"this file, but the file no longer exists; drop its entry "
                f"from scripts/quality-gates/check_spelling.py"
            )
            continue
        for word in sorted(pins[path]):
            pinned = pins[path][word]
            seen = observed.get(path, {}).get(word, 0)
            if seen < pinned:
                errors.append(
                    f"{path}: KNOWN_VIOLATIONS pins {pinned} occurrence(s) of "
                    f"{word!r} but the file now holds {seen} — the pin "
                    f"outlived its reason; lower it to {seen} or drop the "
                    f"entry in scripts/quality-gates/check_spelling.py"
                )

    return errors


def main() -> int:
    """Run the American-English check. Returns 0 on pass, 1 on failure."""
    errors = check_spelling()

    if errors:
        print("American-English spelling FAILED:")
        for e in errors:
            print(f"  {e}")
        return 1

    pinned = sum(sum(v.values()) for v in KNOWN_VIOLATIONS.values())
    print(
        "American-English spelling passed "
        f"({pinned} occurrence(s) across {len(KNOWN_VIOLATIONS)} file(s) "
        "are pinned in KNOWN_VIOLATIONS)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
