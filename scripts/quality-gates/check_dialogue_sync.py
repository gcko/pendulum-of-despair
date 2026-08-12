#!/usr/bin/env python3
"""Quality Gate J: dialogue JSON / script markdown sync.

`game/data/dialogue/*.json` and `docs/story/script/*.md` are two
hand-maintained copies of the same player-facing strings. Nothing generates
one from the other — `tools/dialogue_parser.py` claimed to and was deleted
in #364 — so the only thing that had been holding them together was the
"both copies move in the same commit" rule in `docs/story/README.md`
§ Writing Conventions. This gate is what enforces that rule.

**What it checks.** Every player-facing string anywhere under
`game/data/dialogue/` must occur *verbatim* — as an exact substring, no
case folding, no whitespace or punctuation normalization — somewhere in the
concatenated text of `docs/story/script/*.md`. Reword or respell a shipped
string without moving the markdown copy and this gate goes red.

Three keys hold such strings, and all three are read (#398): the entries of
a `lines` array, a `choice` option's `label`, and the `text` of a title-card
command. The last two were unchecked when the gate landed, which left every
choice in the game — the Thornmere council's ten branch options — outside a
gate whose stated rule already covered them.

**What it does not check.** Two things, named here so nobody reads a
guarantee into it that is not in the code:

1. *The reverse direction.* Markdown with no matching JSON line is fine;
   most of the script is stage direction that never ships as a string.
2. *Position.* A match anywhere in any script file counts, so this catches
   a line whose text drifted, not a line filed under the wrong scene.

**The ratchet.** 128 shipped strings across 31 files have no markdown
source: 121 `lines[]` entries that predate the gate (#380 tracks the
back-fill) and the 7 `label`/`text` strings the widening added (#414). A
strict gate could never have been switched on over them, so they are pinned
in `KNOWN_ORPHANS` below, which fails at *both* ends: an unpinned orphan
fails, and a pin that is no longer an orphan — because the back-fill
landed, or because the line was edited or deleted — also fails. The list
can therefore only shrink, and no entry can outlive its reason.

**Non-vacuity.** A scan that reads nothing reports nothing wrong, which is
indistinguishable from a clean tree (#365). So the scan first asserts it
read a non-trivial corpus at both ends — script files, script characters,
dialogue files, dialogue lines, and the choice labels and card text that
#398 added — and fails if any floor is breached. Fix the walk when that
fires; do not lower a floor.

Exit code 0 = pass, 1 = drift, stale pin, or a degenerate scan.
"""
import json
import os
import sys
from collections.abc import Iterator
from typing import Any

SCRIPT_DIR = "docs/story/script"
DIALOGUE_DIR = "game/data/dialogue"

# Non-vacuity floors — see module docstring. Set well below what the repo
# holds today (9 script files / 214,340 chars / 139 dialogue files / 2,066
# lines / 13 choice labels and card texts) so ordinary authoring never trips
# them, and high enough that a walk which silently stops descending cannot
# pass. The last floor is the one #398 leaves behind: that count was zero for
# the gate's whole life, and a floor under it is what stops it going back.
MIN_SCRIPT_FILES = 5
MIN_SCRIPT_CHARS = 100_000
MIN_DIALOGUE_FILES = 100
MIN_DIALOGUE_LINES = 1_500
MIN_DIALOGUE_CHOICES = 8

# The ratchet, keyed by path relative to DIALOGUE_DIR. Every entry is a
# shipped string that has no verbatim source in the script markdown: 121
# `lines[]` strings that predate the gate (#379), inherited from the parser
# retirement (#364) and tracked for back-fill by #380, plus the 7
# `choice.label` and `text` strings that #398 brought into view.
#
# The 7 are not all the same kind of miss, and the difference is what the
# back-fill needs to know. Five of the council labels *are* in
# `act-ii-part-1.md` — wrapped across two blockquote lines, which a verbatim
# substring test cannot see through. The two `dawn_march.json` credit rows
# are not in the markdown at any wrapping, and their double-spaced
# separators are exactly the drift this gate exists to catch.
#
# This list may shrink. It may not grow: a new orphan is drift, and the fix
# is to write the line into `docs/story/script/*.md`, not to pin it. Remove
# an entry in the same commit that gives its line a markdown source — the
# gate fails on a pin that is no longer an orphan, so a stale pin cannot sit
# here unnoticed.
KNOWN_ORPHANS: dict[str, tuple[str, ...]] = {
    "battle_sfx_captions.json": (
        'briefly in the lower corner of the screen.',
    ),
    "caden_binding.json": (
        'I felt it through the water. The old channels are open',
        "She's free. Weakened, but free. The binding I'll place",
        'will protect her while she heals.',
        'You came all the way from the Duskfen?',
        'The spirits carried me. They remember the paths even',
        'when the water forgets.',
        'Caden kneels beside the shrine and traces a pattern in',
        'the water. Light follows his fingertips.',
        "It's done. Take this -- the Fenmother's Blessing. Her",
        'domain is yours to pass through freely.',
        'Thank you, Caden.',
        "Don't thank me. Thank her. She chose to trust you.",
    ),
    # #398: the two title-card credit rows. No wrapping of the markdown
    # produces these — the rows are not in act-i.md § Scene 4: The Dawn
    # March at all — and the doubled spaces are the drift itself.
    "dawn_march.json": (
        'Edren  -  Cael  -  Maren',
        'Sable  -  Lira  -  Torren',
    ),
    "ember_vein_1a_bodies.json": (
        'More of them. Same as before — no wounds, no struggle.',
        "Their lanterns still have oil. They didn't run out of light.",
        'Something down here stopped them. Not the dark — something worse.',
        'We press on. Answers are deeper.',
    ),
    "fenmother_battle.json": (
        'surface — tendrils of grey-green light reaching for the walls.',
        'chamber. The water rises.',
        'the spirit underneath is visible — ancient, tired, asking',
        'settles, translucent and calm. She sinks beneath the',
        'surface. The hollow goes quiet.',
    ),
    "fenmother_cleansing.json": (
        "I can feel her — she's still in there. Hold them off",
        'while I work.',
        "Dark streaks peel from the Fenmother's flanks. Beneath",
        'the poison, hints of blue-white luminescence appear.',
        "She's fighting it. She's trying to help.",
        'The corruption recedes nearly completely. Grey',
        "coloration fades from the Fenmother's translucent body.",
        'Light floods the hollow. The corruption lifts. The',
        'Fenmother opens her eyes — clear, golden, grateful.',
    ),
    "ironmouth_escape.json": (
        "We made it. But they'll send patrols.",
        'The Wilds are dense enough to lose them. If we',
        'keep moving, we can find shelter before nightfall.',
        "Assuming the Wilds don't eat us first.",
        'What we found in that mine — the bodies, the',
        "pendulum — it's all connected to the Compact.",
    ),
    "npc_caden_duskfen.json": (
        'The Fenmother grows stronger each day.',
        'The water remembers.',
    ),
    "npc_court_guard.json": (
        'The Court Quarter is open to visitors. Keep your business respectful.',
    ),
    "npc_dame_cordwyn.json": (
        "Edren. It's good to see you.",
        'Haren is already planning to use the Pendulum as a bargaining chip with the Compact.',
        "Keep an eye on Cael. He's brilliant, but he carries more than he lets on.",
        "Cael was the best of us. I don't mean the strongest -- I mean the kindest.",
    ),
    "npc_elara_thane.json": (
        'My grandmother could call a storm that lasted three days.',
    ),
    "npc_jorin_ashvale.json": (
        'The crown sends me letters of concern.',
        'I could paper my walls with royal concern.',
    ),
    "npc_king_aldren.json": (
        'Every morning I ask the court mages for a report on the ley lines.',
        'There is nothing safe left in Valdris.',
    ),
    "npc_maren_refuge.json": (
        "Maybe now they'll have to.",
    ),
    "npc_mirren.json": (
        "Maren took my document. Didn't ask. Didn't sign for it.",
        'Just took it and vanished.',
    ),
    "npc_roothollow_herbalist.json": (
        'The forest provides what we need. Remedies, salves,',
        'wards against the things that creep in the dark.',
    ),
    "npc_scholar_aldis.json": (
        'The ley lines beneath the capital have lost twelve percent capacity in the last year alone.',
        "I'd like to compare readings with the Pendulum's resonance. I'll work with Cael on it.",
        'The ley lines are the lifeblood of this kingdom. And they are failing.',
    ),
    "npc_valdris_armorsmith.json": (
        'Valdris steel. Best protection this side of the Wilds.',
    ),
    "npc_valdris_jeweler.json": (
        'Pact-charms, rings, and pendants. Each one carries a piece of the old magic.',
    ),
    "npc_valdris_shopkeeper.json": (
        'Welcome! Take a look around.',
    ),
    "npc_valdris_specialty.json": (
        "Rare goods for the discerning adventurer. You won't find these at the general store.",
    ),
    "npc_valdris_weaponsmith.json": (
        'Good steel keeps you alive. Browse my stock.',
    ),
    "npc_vessa.json": (
        'That thing you carry -- the totems know it.',
        "They're shaking. Take it from my home before dawn,",
        'or I will put it in the river myself.',
        'The great stags once carried the spirit-speakers',
        'between the groves. Few bond with them now.',
    ),
    "scene_7a_the_gates.json": (
        'The king received word from Thornwatch. Commander Halda sent a rider two days ahead.',
        "A Forgewright, a Wilds ranger, a woman who looks like she hasn't left a library in years...",
        '...and a young woman who is very carefully not making eye contact.',
        "You'll need to register at the inner gate. All of you.",
        'We have business with the king. The Pendulum --',
        'I know. The whole court knows.',
        'Straight through the Lower Ward, up through the districts. The throne hall is at the top.',
        "It's been a long time since I walked these streets.",
        "Let's not keep the king waiting.",
    ),
    "scene_7b_throne_hall.json": (
        'The throne hall is smaller than expected -- built for function, not grandeur.',
        'King Aldren sits on a plain stone chair. He is older than he should be.',
        'Lord Chancellor Haren stands to his left.',
        'Your Majesty. We recovered this from the Ember Vein.',
        'Edren places the Pendulum on the table.',
        "It doesn't look like much.",
        "It's a conduit -- a focal point for something beyond it.",
        'The miners who found it are dead. Not from violence. From despair.',
        "You've been away from court for some time, Maren.",
        'Every morning I ask the court mages for a report on the ley lines.',
        'There is nothing safe left in Valdris.',
        'Maren -- I want an assessment in writing by morning.',
        "Cael -- you'll work with Maren on the Pendulum. Whatever this thing is, I need to understand it.",
        'This is the moment the trap closes.',
        "The Pallor's mark answers the king's request before Cael can think twice.",
    ),
    "scene_7c_aldis.json": (
        'The ley lines beneath the capital have lost twelve percent capacity in the last year alone.',
        "I've been mapping the decline. The pattern is... unsettling.",
        "I'd like to compare my readings with the Pendulum's resonance.",
        'If it truly is a focal point, the interference pattern could tell us where the energy is going.',
        "Wait -- you. I've read your paper on suppressed conduit efficiency.",
        "It was classified, but I'm a researcher. Finding classified documents is half the job.",
        "Don't rearrange my study while I'm here, Aldis.",
    ),
    "scene_7c_cordwyn.json": (
        "She clasps Edren's arm.",
        'Haren is already planning to use the Pendulum as a bargaining chip.',
        'He wants to offer it to the Compact in exchange for a border ceasefire.',
        "He's brilliant, but he carries more than he lets on.",
    ),
    "scene_7c_renn.json": (
        'Sable peels off toward the Lower Ward. She enters the tavern with practiced familiarity.',
        'The Compact found something unexpected in the mine.',
        "Three courier birds to Corrund in one day. That's not a report -- that's a panic.",
        'Forgewright steel price dropped last week. The generals are spending on something other than weapons.',
        "Whatever you've gotten yourself into, Sable -- it's bigger than a mine.",
    ),
    "scene_7d_evening.json": (
        'Night falls over Valdris Crown.',
        'The Pendulum sits in a sealed chamber in the lower Keep.',
        'Containment wards glow blue around the glass case.',
        'Cael stands alone before it.',
        'His hand hovers near the glass.',
        "For a single frame -- his reflection's eyes are grey.",
        "The Pendulum's needle shifts one degree, then stops.",
    ),
    # #398: five of the ten Thornmere council choice labels. Each one is in
    # `docs/story/script/act-ii-part-1.md`, wrapped across two `>` lines
    # ("...Neutrality requires a" / "stable world."), so the verbatim test
    # cannot reach it. The back-fill is to unwrap the markdown copy, not to
    # reword the shipped label.
    "thornmere_council.json": (
        'The ley lines affect everyone. Neutrality requires a stable world.',
        'Valdris and the Wilds share a border. If we fall, the Compact '
        'comes for you next.',
        'The spirits can scream all they want. We need soldiers.',
        'Contain the Pendulum, reinforce the ley wards, prepare for a siege.',
        "We don't have a full plan yet. But we have people willing to fight.",
    ),
    "water_of_life.json": (
        'This is old water. Older than the Compact. Older than',
        'the Duskfen. It remembers what this place was.',
        "The extraction pipes from the Compact's upriver station",
        "bypass this aquifer entirely. They didn't know it was",
        'here. Lucky for us.',
        "That's a nice bowl. We taking it?",
        "It's a sacred vessel. We're borrowing it.",
    ),
}


def load_script_corpus(script_dir: str = SCRIPT_DIR) -> tuple[str, int]:
    """Concatenate every ``.md`` under *script_dir*; return (text, files)."""
    texts: list[str] = []
    count = 0
    for dirpath, dirnames, filenames in os.walk(script_dir):
        dirnames[:] = sorted(d for d in dirnames if not d.startswith("."))
        for name in sorted(filenames):
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            with open(path, encoding="utf-8") as handle:
                texts.append(handle.read())
            count += 1
    return "\n".join(texts), count


def iter_dialogue_files(dialogue_dir: str = DIALOGUE_DIR) -> list[str]:
    """Every ``.json`` under *dialogue_dir*, as paths relative to it."""
    found: list[str] = []
    for dirpath, dirnames, filenames in os.walk(dialogue_dir):
        dirnames[:] = sorted(d for d in dirnames if not d.startswith("."))
        for name in sorted(filenames):
            if not name.endswith(".json"):
                continue
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, dialogue_dir).replace(os.sep, "/")
            found.append(rel)
    return sorted(found)


PLAYER_FACING_KEYS = ("label", "text")


def iter_player_strings(node: Any) -> Iterator[tuple[str, str]]:
    """Yield ``(key, string)`` for every player-facing string in *node*.

    Three keys carry one: an entry of a ``lines`` array, a choice option's
    ``label``, and a title-card command's ``text``. The key comes back with
    the string because the two are floored separately — a walk that keeps
    reading ``lines`` while silently dropping the other two would clear a
    single combined floor on the strength of the 2,066 lines alone.

    Recursive rather than a fixed ``doc["entries"][i]["lines"]`` reach,
    because a `lines` array nested under a choice branch is just as shipped
    as a top-level one, and a reach that only knows today's shape would skip
    it while still reporting clean. The same holds for ``label``, which lives
    two levels further down than any ``lines`` array does — under
    ``entries[].choice[]`` — and for ``text``, which hangs off
    ``entries[].commands[]``.
    """
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "lines" and isinstance(value, list):
                for item in value:
                    if isinstance(item, str):
                        yield "lines", item
            elif key in PLAYER_FACING_KEYS and isinstance(value, str):
                yield key, value
            yield from iter_player_strings(value)
    elif isinstance(node, list):
        for item in node:
            yield from iter_player_strings(item)


def check_dialogue_sync(
    script_dir: str = SCRIPT_DIR,
    dialogue_dir: str = DIALOGUE_DIR,
    known_orphans: dict[str, tuple[str, ...]] | None = None,
    min_script_files: int = MIN_SCRIPT_FILES,
    min_script_chars: int = MIN_SCRIPT_CHARS,
    min_dialogue_files: int = MIN_DIALOGUE_FILES,
    min_dialogue_lines: int = MIN_DIALOGUE_LINES,
    min_dialogue_choices: int = MIN_DIALOGUE_CHOICES,
    tally: dict[str, int] | None = None,
) -> list[str]:
    """Verify every shipped dialogue string has a verbatim markdown source.

    ``tally``, when given, is filled with ``script_files``,
    ``dialogue_files``, ``lines`` and ``choices`` — what the scan actually
    read. ``main`` prints them, because "no drift found" and "nothing read"
    are otherwise the same sentence.
    """
    pins = KNOWN_ORPHANS if known_orphans is None else known_orphans
    corpus, script_files = load_script_corpus(script_dir)
    dialogue_files = iter_dialogue_files(dialogue_dir)

    orphans: dict[str, set[str]] = {}
    total_lines = 0
    total_choices = 0
    errors: list[str] = []

    for rel in dialogue_files:
        path = os.path.join(dialogue_dir, rel)
        with open(path, encoding="utf-8") as handle:
            try:
                doc = json.load(handle)
            except json.JSONDecodeError as exc:
                errors.append(f"{path}: is not valid JSON ({exc})")
                continue
        for key, line in iter_player_strings(doc):
            if key == "lines":
                total_lines += 1
            else:
                total_choices += 1
            if line not in corpus:
                orphans.setdefault(rel, set()).add(line)

    if tally is not None:
        tally["script_files"] = script_files
        tally["dialogue_files"] = len(dialogue_files)
        tally["lines"] = total_lines
        tally["choices"] = total_choices

    # Non-vacuity first: on a degenerate scan every pin looks stale and no
    # line looks orphaned, so reporting the sync findings would be noise on
    # top of a scan whose result means nothing.
    floors = [
        (script_files, min_script_files, f".md files under {script_dir}"),
        (
            len(corpus),
            min_script_chars,
            f"characters of script text from {script_dir}",
        ),
        (
            len(dialogue_files),
            min_dialogue_files,
            f".json files under {dialogue_dir}",
        ),
        (total_lines, min_dialogue_lines, "dialogue lines[] strings"),
        (
            total_choices,
            min_dialogue_choices,
            "dialogue choice.label / command text strings (#398)",
        ),
    ]
    vacuity = [
        f"scan read only {actual} {label} (floor {floor}) — it is not "
        f"reading the corpus it reports on, so a clean result would mean "
        f"nothing; repair the walk rather than lowering the floor"
        for actual, floor, label in floors
        if actual < floor
    ]
    if vacuity:
        return errors + vacuity

    for rel in sorted(orphans):
        pinned = set(pins.get(rel, ()))
        for line in sorted(orphans[rel] - pinned):
            errors.append(
                f"{dialogue_dir}/{rel}: {line!r} has no verbatim source in "
                f"{script_dir}/*.md — the two copies of this string moved "
                f"apart; edit the markdown to match, or add the line there "
                f"if it is new"
            )

    for rel in sorted(pins):
        # A pinned file that no longer exists is its own failure, and reporting
        # it as "the line now resolves" would send the reader hunting for a
        # markdown source that was never the reason.
        if not os.path.isfile(os.path.join(dialogue_dir, rel)):
            errors.append(
                f"{dialogue_dir}/{rel}: KNOWN_ORPHANS pins "
                f"{len(pins[rel])} line(s) in this file, but the file no "
                f"longer exists; drop its entry from "
                f"scripts/quality-gates/check_dialogue_sync.py"
            )
            continue
        observed = orphans.get(rel, set())
        for line in pins[rel]:
            if line not in observed:
                errors.append(
                    f"{dialogue_dir}/{rel}: KNOWN_ORPHANS pins {line!r}, "
                    f"which is no longer an unsourced line there — it now "
                    f"resolves, or the line was edited or deleted; drop the "
                    f"entry from scripts/quality-gates/check_dialogue_sync.py"
                )

    return errors


def main() -> int:
    """Run the dialogue sync check. Returns 0 on pass, 1 on failure."""
    tally: dict[str, int] = {}
    errors = check_dialogue_sync(tally=tally)

    if errors:
        print("Dialogue script/JSON sync FAILED:")
        for e in errors:
            print(f"  {e}")
        return 1

    pinned = sum(len(v) for v in KNOWN_ORPHANS.values())
    print(
        f"Dialogue script/JSON sync passed. {tally['lines']} lines[] and "
        f"{tally['choices']} choice.label / command text string(s) (#398) "
        f"checked across {tally['dialogue_files']} dialogue file(s) against "
        f"{tally['script_files']} script file(s); "
        f"{pinned} strings are pinned in KNOWN_ORPHANS."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
