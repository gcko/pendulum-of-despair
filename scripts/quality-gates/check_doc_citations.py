#!/usr/bin/env python3
"""Quality Gate G: doc citation integrity.

Line-anchored citations (``magic.md:1537``) rot silently: inserting a
paragraph above the cited line repoints every citation below it, and no
test notices. This gate makes that impossible in live files by

1. **banning** the ``<name>.md:NNN`` / ``<name>.gd:NNN`` form outright, and
2. **resolving** the replacement form ``<name>.md § <Heading>`` against the
   target document, optionally narrowing to a quoted term that must appear
   inside that section: ``magic.md § Status Effect Reference > 'Poison'``.

The filename may be bare, a markdown link — ``[magic.md](../story/magic.md)
§ Spell Balance Guidelines``, which is the house style in ``docs/`` — or a
code span: ``` `items.md` § Key Items ```. Only the bare form was read until
#404, which left 132 of today's citations unread, and a citation nobody
reads is one nobody can catch rotting. Where a link names two paths, the
destination is the one resolved (``cited_path``).

Read is not the same as verified, and the gap between the two is where this
gate's remaining exposure lives. The resolver is deliberately loose — it
accepts any word prefix of the citation that the heading's breadcrumb
contains — so a citation can be read, resolve, and still name a heading
nobody wrote. ``names_the_heading`` closes the loosest case of that, the
one-word match on a word buried inside some other heading, which is what
made ``combat-formulas.md § Act scaling`` land on ``### Regular Enemy HP by
Act`` in #404. Longer partial matches are not closed; #416 tracks those.

Scanned: docs/, game/scripts/, game/tests/, game/data/, scripts/.

Not scanned: docs/issues/ and docs/superpowers/. Those are **dated
records** — a bug report or a design plan describes the tree as it was on
the day it was written, so a citation there is a snapshot, not a live
pointer, and rewriting it would falsify the record.

One region inside them is live and is scanned: the ``## Design references``
section of a GAP doc, which is the reader's route into canon now rather than
a snapshot of it. It gets the same treatment a live file gets, plus a check
that each bullet's path exists — see ``check_gap_design_references`` (#403).

Exit code 0 = pass, 1 = offending citations found.
"""
import glob
import os
import re
import sys

SCAN_ROOTS: list[str] = [
    "docs",
    "game/scripts",
    "game/tests",
    "game/data",
    "scripts",
]

# Dated records — see module docstring.
EXCLUDED_DIRS: tuple[str, ...] = (
    "docs/issues",
    "docs/superpowers",
)

# The one live region inside a dated record: a GAP doc's Design references
# are the reader's route into canon now, not a snapshot of it (#403). They
# are checked by ``check_gap_design_references`` with the same machinery the
# live files get; everything else in ``docs/issues/`` stays unread.
GAP_ISSUES_DIR = "docs/issues"
_DESIGN_REF_SECTION = re.compile(
    r"^## Design references\n(.*?)(?=^## |\Z)", re.M | re.S
)

# Non-vacuity floors for that scan, set well under what the tree holds today
# (91 docs, 159 bullets) and well over what a broken walk would return.
MIN_GAP_DOCS = 50
MIN_GAP_BULLETS = 90

# This gate and its tests quote citations as *data* (the ratchet list below,
# the test fixtures). Scanning them would flag the gate's own examples.
EXCLUDED_FILES: tuple[str, ...] = (
    "scripts/quality-gates/check_doc_citations.py",
    "scripts/quality-gates/test_quality_gates.py",
)

SCANNED_SUFFIXES: tuple[str, ...] = (
    ".md",
    ".gd",
    ".json",
    ".py",
    ".sh",
    ".tscn",
    ".txt",
    ".cfg",
)

# "magic.md:1537", "status_effects.gd:25", "docs/story/magic.md:1537" — the
# banned form. The path prefix is part of the pattern rather than something
# the lookbehind refuses: a bare filename and a full path rot identically,
# and reading only the bare one meant every Design-reference anchor written
# as ``docs/story/progression.md:388`` went unbanned (#403). The lookbehind
# still keeps the match from starting mid-token.
LINE_ANCHOR_RE = re.compile(
    r"(?<![\w/.\-])((?:[A-Za-z0-9_][A-Za-z0-9_.\-]*/)*"
    r"[A-Za-z0-9_][A-Za-z0-9_.\-]*\.(?:md|gd)):(\d+)"
)

# "magic.md § Status Effect Reference"; tolerates a line wrap (with an
# optional comment marker) between the filename and the section sign, which
# is how the citation lands inside wrapped GDScript ``##`` doc comments.
# The match deliberately stops at the section sign rather than capturing the
# heading, so that a line carrying several citations yields several matches.
#
# The filename may be *decorated*, and both decorations were unreadable until
# #404. The house style in ``docs/`` writes a cross-document citation as a
# markdown link — ``[combat-formulas.md](combat-formulas.md) § Act scaling`` —
# so a closing paren sits between the filename and the section sign; prose
# elsewhere writes the filename as a code span — ``` `items.md` § Key Items ```
# — so a backtick does. A pattern that could cross neither read no such
# citation at all, and a citation nobody reads is one nobody can catch rotting:
# 127 link-form and 6 code-span citations were unchecked, among them the fourth
# site of the broken ``§ Act scaling`` citation that #384 repointed at its
# three other sites.
#
# ``target`` is the link's destination when there is one. It matters because
# the two filenames can disagree — ``[magic.md](../story/magic.md)`` in
# ``docs/analysis/`` — and the destination is the real path, so it is the one
# resolved (see ``cited_path``).
HEADING_CITE_RE = re.compile(
    r"(?P<file>[A-Za-z0-9_][A-Za-z0-9_.\-/]*\.md)"
    r"(?:`|\][ \t]*\((?P<target>[^()\s]*)\))?"
    r"[ \t]*(?:\r?\n[ \t]*(?:#+|//|\*|>)?[ \t]*)?"
    r"§[ \t]*"
)

# The optional "> 'Poison'" narrowing term.
TERM_RE = re.compile(r">[ \t]*['\"](?P<term>[^'\"]+)['\"]")

# A "> '" that TERM_RE could not complete. The term is the half of a citation
# that catches a section rewritten under a heading nobody renamed, so a term
# the checker cannot read is the half that silently stops working — which is
# what a quote left open by a line wrap (``> 'Barnacle`` / ``Shield'``) does.
# Ignoring it is worse than the citation having had no term at all, because
# the citation still *looks* narrowed. Say so instead (#366).
OPEN_TERM_RE = re.compile(r">[ \t]*['\"]")

# A section id as documents actually number them: "2", "2.1", and — the case
# that matters — "1.2a". The letter suffix is part of the id, not decoration.
# technical-architecture.md carries both "### 1.2 Naming Conventions" and
# "### 1.2a Script Size Budget"; a matcher that reads only the digits resolves
# a citation to § 1.2a against § 1.2, which is a green light on the wrong
# section, and passes § 1.2b, which nobody wrote.
SECTION_ID = r"\d+(?:\.\d+)*[A-Za-z]?"

# "2.1", "1.2a", or a list of them: "2.1/2.3", "1.2,1.3".
SECTION_LIST_RE = re.compile(rf"^({SECTION_ID}(?:[/,]{SECTION_ID})*)")

# The id a heading numbers *itself* with, taken off the front of its title:
# "### 1.2a Script Size Budget" -> "1.2a", "## 19. Ley Nexus Hollow" -> "19",
# "### Floor 2: Lower Mine" -> none. The trailing "." or ")" is list
# punctuation and not part of the id, so "§ 19" and "§ 19." name the same
# heading. Matching an id against *this* rather than against the heading's
# breadcrumb words is what keeps "§ 3" off "### 1.3" (#391).
HEADING_ID_RE = re.compile(rf"^({SECTION_ID})[.)]?(?:[ \t]|$)")

# The period closing a *leading* section id, where the numbered-list heading
# style puts it: "## 19. Ley Nexus Hollow" carries the number, the period and
# the title in one heading, so "§ 19. Ley Nexus Hollow" spells that heading
# out and the period belongs to the id, not to a sentence. ``citation_extent``
# read it as a sentence ending and cut the citation down to the bare "19"
# (#390). The capitalized word is what tells the heading form apart from an id
# followed by ordinary prose or code — "§2.4. func apply_buff(...)" — where the
# period really does end the citation and the run-on must still be discarded.
LEADING_ID_DOT_RE = re.compile(rf"[ \t]*{SECTION_ID}\.(?=[ \t]+[A-Z])")

# A section id's period met *after* that leading one. The citation has run on
# from the heading it named into a second id, which is a claim about the
# heading tree rather than prose, so this is where it stops — but the period
# stays on, because "21." is section-shaped to ``SECTION_WORD_RE`` and a bare
# "21" is not, and the resolver's invention check reads that shape (#367).
# Anchored at a word boundary, so it can only ever match a whole token.
ID_DOT_RE = re.compile(rf"(?:^|(?<=[ \t])){SECTION_ID}\.(?=[ \t])")

# A whole word that is *itself* a section id, and so is a claim about the
# document's heading tree rather than prose: "2.3", "1.2a", "21.", "3)".
# Either the id is multi-part ("2.3") or it carries a list terminator ("21."),
# because a bare "30" in "§ Inn Costs 30 gil a night" is a number, not a
# section. Used by ``continues_a_heading``: documents here number their
# headings ("### 2.3 Party Panel", "## 19. Ley Nexus Hollow"), so a citation
# that runs on into a *second* id is naming a section, and the check for a
# capitalised word cannot see that — digits are not upper case (#367).
SECTION_WORD_RE = re.compile(
    r"^(?:\d+(?:\.\d+)+[A-Za-z]?|\d+(?:\.\d+)*[A-Za-z]?[.)])$"
)

# A ``§`` with a section id after it and no filename in front: a document
# referring to one of its own sections, which is how a document refers to
# itself without the redundancy of naming its own filename ("the six
# singletons listed in § 1.3"). The lookahead keeps "§ 3rd" and "§ 2gil"
# out — an id ends the token it starts.
SELF_CITE_RE = re.compile(
    rf"§[ \t]*(?={SECTION_ID}(?:[/,]{SECTION_ID})*(?![\w.]))"
)

# A filename that could own the ``§`` after it. A bare ``§N`` is only read as
# a self-reference when none appears in the wrap window before it, because the
# house style writes cross-document citations as markdown links
# ("[dungeons-world.md](../dungeons-world.md)\n§ 2, recommended level 12-15")
# whose closing paren stops HEADING_CITE_RE from reaching the section sign.
# Reading *that* as a self-reference would resolve it against the wrong
# document — silently, and in the direction this gate exists to prevent.
NEARBY_DOC_RE = re.compile(r"[A-Za-z0-9_][A-Za-z0-9_.\-/]*\.md")

# Where one citation stops and the next begins. A comment often chains them
# ("conventions §2.1; palette-families.md § Serpent Family > 'Marsh Serpent'"),
# and without this cut the first citation would claim the second one's term.
NEXT_CITE_RE = re.compile(r"§|[A-Za-z0-9_][A-Za-z0-9_.\-/]*\.md")

# A ratchet, now at zero (#366). It carried the twelve citations that
# predated this gate and named a heading nobody wrote; every one has since
# been repointed at the section that actually says what it claimed, and its
# entry deleted with the fix.
#
# The mechanism is what remains worth keeping: the gate fails when a pinned
# citation stops appearing, so a pin can only be removed by fixing the
# citation it names, and the list can only shrink. Empty is the state it is
# supposed to be in. Do not add to it — fix the citation instead.
KNOWN_UNRESOLVED: dict[tuple[str, str], str] = {}

FIX_HINT_ANCHOR = (
    "line anchors rot on the next insertion — cite a heading instead, e.g. "
    "`magic.md § Status Effect Reference > 'Poison'`"
)


def normalize(text: str) -> str:
    """Fold a heading or citation to comparable words.

    Lowercases and reduces every non-alphanumeric run to a single space, so
    ``### 1.4 Color Palette`` and ``1.4 Color Palette`` agree, and so does
    ``Act II: Diplomatic Mission`` with ``Act II Diplomatic Mission``.
    """
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


def iter_scanned_files() -> list[str]:
    """Every text file under SCAN_ROOTS that is not a dated record."""
    found: list[str] = []
    for root in SCAN_ROOTS:
        if not os.path.isdir(root):
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            rel = dirpath.replace(os.sep, "/")
            if any(
                rel == ex or rel.startswith(ex + "/") for ex in EXCLUDED_DIRS
            ):
                dirnames[:] = []
                continue
            dirnames[:] = [d for d in dirnames if not d.startswith(".")]
            for name in sorted(filenames):
                if not name.endswith(SCANNED_SUFFIXES):
                    continue
                path = os.path.join(dirpath, name).replace(os.sep, "/")
                if path in EXCLUDED_FILES:
                    continue
                found.append(path)
    return sorted(found)


def fenced_lines(text: str) -> set[int]:
    """1-based line numbers that sit inside a ``` fenced code block."""
    inside: set[int] = set()
    fenced = False
    for i, line in enumerate(text.split("\n"), start=1):
        if line.lstrip().startswith("```"):
            inside.add(i)
            fenced = not fenced
            continue
        if fenced:
            inside.add(i)
    return inside


def parse_headings(text: str) -> list[tuple[int, int, str]]:
    """Return (line_number, level, title) for every real ATX heading.

    Headings inside fenced code blocks are shell comments or config lines,
    not headings, so they are skipped — otherwise a ``# project.godot``
    inside a fence would truncate the section above it.
    """
    headings: list[tuple[int, int, str]] = []
    fenced = fenced_lines(text)
    for i, line in enumerate(text.split("\n"), start=1):
        if i in fenced:
            continue
        m = re.match(r"^(#{1,6})[ \t]+(.+?)[ \t]*$", line)
        if m:
            headings.append((i, len(m.group(1)), m.group(2)))
    return headings


def breadcrumb_words(
    headings: list[tuple[int, int, str]], idx: int
) -> list[str]:
    """Words of a heading plus every ancestor heading above it.

    Prose citations often name a heading by its path rather than its exact
    text — ``outline.md § Interlude The World Changes`` for
    ``## The Interlude: The Unraveling`` / ``### The World Changes``.
    Matching against the path accepts that without accepting invention.
    """
    line_no, level, title = headings[idx]
    trail: list[str] = [title]
    want = level - 1
    for j in range(idx - 1, -1, -1):
        if want == 0:
            break
        if headings[j][1] <= want:
            trail.append(headings[j][2])
            want = headings[j][1] - 1
    return normalize(" ".join(reversed(trail))).split()


class DocIndex:
    """Lazily loaded heading index for the markdown files in the repo."""

    def __init__(self) -> None:
        self._paths: dict[str, list[str]] = {}
        self._headings: dict[str, list[tuple[int, int, str]]] = {}
        self._trails: dict[str, list[list[str]]] = {}
        self._lines: dict[str, list[str]] = {}
        for dirpath, dirnames, filenames in os.walk("."):
            dirnames[:] = [d for d in dirnames if not d.startswith(".")]
            for name in filenames:
                if not name.endswith(".md"):
                    continue
                path = os.path.join(dirpath, name).replace(os.sep, "/")
                path = path[2:] if path.startswith("./") else path
                self._paths.setdefault(name, []).append(path)

    def resolve(self, cited: str) -> list[str]:
        """Every repo path whose trailing components match the citation."""
        base = cited.rsplit("/", 1)[-1]
        candidates = self._paths.get(base, [])
        if "/" in cited:
            narrowed = [p for p in candidates if p.endswith(cited)]
            if narrowed:
                return narrowed
        return candidates

    def headings(self, path: str) -> list[tuple[int, int, str]]:
        if path not in self._headings:
            with open(path, encoding="utf-8") as f:
                text = f.read()
            self._lines[path] = text.split("\n")
            self._headings[path] = parse_headings(text)
        return self._headings[path]

    def trails(self, path: str) -> list[list[str]]:
        """Breadcrumb word lists, parallel to ``headings(path)``."""
        if path not in self._trails:
            heads = self.headings(path)
            self._trails[path] = [
                breadcrumb_words(heads, i) for i in range(len(heads))
            ]
        return self._trails[path]

    def section_text(self, path: str, line_no: int, level: int) -> str:
        """Body of the section starting at ``line_no`` (heading excluded)."""
        self.headings(path)
        lines = self._lines[path]
        end = len(lines)
        for h_line, h_level, _ in self.headings(path):
            if h_line > line_no and h_level <= level:
                end = h_line - 1
                break
        return "\n".join(lines[line_no:end])


def stem(word: str) -> str:
    """Crudest possible singular form, so ``Inns`` can reach ``Inn Costs``."""
    return word[:-1] if len(word) > 3 and word.endswith("s") else word


def is_subsequence(needles: list[str], haystack: list[str]) -> bool:
    """True when every needle word appears in ``haystack``, in order."""
    it = iter(haystack)
    return all(any(stem(h) == stem(n) for h in it) for n in needles)


def match_words(
    index: DocIndex, path: str, want: list[str]
) -> tuple[int, int, str] | None:
    """First heading in ``path`` whose breadcrumb path contains ``want``."""
    heads = index.headings(path)
    for i, trail in enumerate(index.trails(path)):
        if is_subsequence(want, trail):
            return heads[i]
    return None


def heading_id(title: str) -> str | None:
    """The section id a heading numbers itself with, or ``None``.

    ``"1.2a Script Size Budget"`` -> ``"1.2a"``; ``"19. Ley Nexus Hollow"`` ->
    ``"19"``; ``"Floor 2: Lower Mine (40x30)"`` -> ``None``, because the number
    there is inside the title rather than in front of it.
    """
    m = HEADING_ID_RE.match(title.strip())
    return m.group(1).lower() if m else None


def heading_subject(title: str) -> list[str]:
    """A heading's own words, with any leading section id dropped.

    ``"56. Ironhide"`` -> ``["ironhide"]``; ``"Regular Enemy HP by Act"`` ->
    ``["regular", "enemy", "hp", "by", "act"]``. The id is dropped because a
    numbered heading's subject is what comes after the number, and
    ``magic.md § Ironhide`` names that subject exactly.
    """
    stripped = title.strip()
    m = HEADING_ID_RE.match(stripped)
    if m:
        stripped = stripped[m.end():]
    return normalize(stripped).split()


def names_the_heading(title: str, word: str) -> bool:
    """True when a *one-word* citation names what ``title`` is about.

    ``match_words`` accepts a citation word anywhere in a heading's breadcrumb
    path, in order. Over a single word that is far too weak a claim: ``act``
    appears somewhere in the breadcrumb of ``### Regular Enemy HP by Act``, so
    ``combat-formulas.md § Act scaling`` — a heading nobody wrote, and the
    exemplar defect #404 was filed over — resolved to it and the gate reported
    passed. Widening the regex so the citation was finally *read* did not
    change that; it only meant the wrong resolution now happened in public.

    The test is where in the heading the word landed. A one-word citation that
    names a heading names its **subject** — the first word of its own title,
    after any leading section id: ``§ Weapons`` for ``### Weapons``,
    ``§ Ironhide`` for ``### 56. Ironhide``, ``§ Cael`` for ``### Cael —
    Rally``. A word found buried mid-title is a coincidence of the subsequence
    matcher, not a name.

    Applied only when the citation offered *more* words than the one that
    matched (see ``match_heading``), because a citation that offers exactly one
    word has made no larger claim to check it against: ``npcs.md § Caden`` for
    ``### Spirit-speaker Caden`` is house style and stays legal.

    This closes one shape of false green, not the family. A *two*-word prefix
    buried the same way is still accepted — #416.
    """
    subject = heading_subject(title)
    cited = normalize(word).split()
    if not subject or not cited:
        return True
    return stem(subject[0]) == stem(cited[0])


def match_section_id(
    index: DocIndex, path: str, section_id: str
) -> tuple[int, int, str] | None:
    """The heading that numbers *itself* ``section_id``.

    An id is positional, not a bag of words. Matching it as words against a
    heading's breadcrumb let ``§ 3`` reach ``### 1.3 Autoload Singletons`` —
    whose trail reads ``1 project setup 1 3 autoload singletons``, and so
    contains a ``3`` — and, being the first such heading in the file, win over
    ``## 3. Game State Machine`` further down. Both cited sites of
    ``enemy-ability-conventions.md §3`` resolved that way to ``### 2.3 AoE
    elemental abilities``: the gate reported passed while pointing the reader
    at the wrong section (#391).

    So the citation's id is compared for equality against the id parsed off
    the front of each heading title. ``3`` is ``3`` and is not ``1.3``;
    ``1.2a`` is its own section and not ``1.2``. A document that numbers two
    headings alike is resolved to the first, as everywhere else here.
    """
    want = section_id.lower()
    for head in index.headings(path):
        if heading_id(head[2]) == want:
            return head
    return None


def named_prefix_len(
    index: DocIndex, path: str, hit: tuple[int, int, str], words: list[str]
) -> int:
    """How many leading citation words ``hit`` actually accounts for.

    The word-prefix loop learns this by construction; the section-id branch
    does not — it resolves on ``words[0]`` alone and never looks at the rest.
    Recovering the number here is what lets a numbered citation be held to
    the same invention check as an unnumbered one.

    Never less than one: the id itself is spent resolving the heading, and a
    list of ids (``§ 2.1/2.3``) normalises to words no single heading's
    breadcrumb contains, so counting it as unaccounted-for would refuse every
    list citation.
    """
    heads = index.headings(path)
    trail = index.trails(path)[heads.index(hit)]
    for k in range(len(words), 1, -1):
        want = normalize(" ".join(words[:k])).split()
        if want and is_subsequence(want, trail):
            return k
    return 1


def continues_a_heading(
    words: list[str], k: int, own: int, by_id: bool = False
) -> bool:
    """True when the citation keeps naming heading after the prefix ends.

    ``match_heading`` accepts a prefix ``words[:k]``, which means every
    longer prefix — ``words[:k + 1]`` included — matched no heading at all.
    So ``words[k]`` is a word the citation offers as part of the section's
    name and the document does not have. When it is *shaped* like a heading
    word the citation is naming a subsection nobody wrote, and resolving it
    to the shorter heading would point the reader at a section that does not
    say what the citation claims (#367).

    The shape test is what keeps the deliberate shortening alive. Citations
    sit mid-sentence, and the prose that follows a heading name continues in
    lower case (``§ Derived Rules binds it only to...``), opens a
    parenthetical gloss (``§ 20. Highcairn Monastery (Pallor encounter)``),
    a quotation (``§ Wolf Family, "all wolves"``) or a code span. None of
    those is a claim about the document's heading tree; a bare capitalised
    word is, and so is a bare section id — ``§ 19. Ley Nexus Hollow 21.
    Invented Chamber`` invents just as hard as the capitalised form, and
    ``isupper`` is blind to it because digits have no case.

    ``by_id`` narrows the test to the section-id shape, and is set when the
    heading was settled by a section id rather than by its words. Such a
    citation has already identified its target exactly; whatever follows is
    the author *locating* something inside it, and in the live corpus that
    trailing phrase is routinely capitalised without naming any heading —
    ``audio.md § 3.1 SFX budget`` (§ 3.1 Channel Budget budgets SFX at 12
    channels, which is what the citing line asserts) and ``dungeons-world.md
    § 1 Ember Vein Floor 2`` (§ 1. Ember Vein describes floor 2 in prose).
    Reading capitalisation as invention there fails four correct citations,
    so under an id only a *second id* counts. See ``match_heading`` for what
    that leaves uncovered.

    ``own`` is how many of ``words`` came from the citation's own line; the
    rest were joined on from the wrapped continuation by ``citation_tail``.
    Only the citation's own line can trigger the refusal. A continuation
    line is prose the citation did not choose — the sentence after it may
    open on a proper noun (``... § Danger Counter`` / ``Maren banks
    weave...``) — and refusing on that would fail a correct citation for how
    it happens to wrap. Capping the refusal at ``own`` is what keeps
    over-reading free; see ``citation_tail``.
    """
    if k >= len(words) or k >= own:
        return False
    word = words[k]
    if SECTION_WORD_RE.match(word):
        return True
    if by_id:
        return False
    first = word[:1]
    return first.isalpha() and first.isupper()


def unknown_capitalized_word(
    index: DocIndex,
    path: str,
    hit: tuple[int, int, str],
    extra: list[str],
) -> str | None:
    """First capitalized word in ``extra`` the cited section never says.

    This is the signal #389 asked for. Under a section id the id alone settles
    which heading, so the words after it are optional — and in the live corpus
    they are as often a *locator inside* the section (``audio.md § 3.1 SFX
    budget``, ``dungeons-world.md § 1 Ember Vein Floor 2``) as a continuation
    of its title. Capitalization cannot tell those from an invented subsection
    name, which is why ``continues_a_heading`` refuses to read it under an id.

    The document itself can tell them apart. A locator names something the
    section contains: ``SFX`` is a row of § 3.1 Channel Budget's table,
    ``Floor`` is a word of § 1. Ember Vein's prose. An invented subsection
    names something that is nowhere in it — ``§ 2.3 Nonexistent Subsection``,
    ``§ 19. Invented Chamber``. So a capitalized word that the id did not
    account for must appear in the section's own vocabulary: its breadcrumb
    (the heading and its ancestors) or its body text.

    What this does **not** claim: it does not verify that the trailing words
    name a real subsection, and it does not look at lower-case words at all.
    ``§ 3.3 and the exit_battle convention`` and ``§ 2.5: the announcement
    holds the message window`` are ordinary prose running on from a citation,
    which is house style, and demanding that the section contain *those* words
    would fail most numbered citations in the tree. The guarantee is narrower
    and exact: under a section id, a capitalized word offered as part of the
    section's name must be a word that section actually uses.
    """
    if not extra:
        return None
    heads = index.headings(path)
    trail = index.trails(path)[heads.index(hit)]
    body = normalize(index.section_text(path, hit[0], hit[1])).split()
    vocabulary = {stem(w) for w in trail} | {stem(w) for w in body}
    for word in extra:
        if not (word[:1].isalpha() and word[:1].isupper()):
            continue
        folded = normalize(word).split()
        if folded and any(stem(w) not in vocabulary for w in folded):
            return word
    return None


def match_heading(
    index: DocIndex, path: str, candidate: str, own: int | None = None
) -> tuple[int, int, str] | None:
    """Resolve the text after ``§`` to a heading in ``path``.

    Citations sit inside prose, so the text after ``§`` runs on past the
    heading (``... § Tier 4 AoE Exemption; §2.3 only ever applies ...``).
    Trying successively shorter *word* prefixes finds where the heading ends
    without needing a terminator character.

    A prefix is accepted when its words appear, in order, in the heading's
    breadcrumb path (the heading plus its ancestors). That is loose enough
    for the house style — ``§ Derived Rules`` for
    ``### Derived Rules (numeric balance pass)``, ``§ Caden`` for
    ``### Spirit-speaker Caden``.

    Shortening stops where invention starts — *in this loop*; a citation
    resolved by section id is held to a weaker rule, spelled out at the
    bottom of this docstring. A prefix that is followed by a word shaped like
    more heading — capitalised, or a section id of its own, either way a word
    that by construction matches nothing — is refused outright rather than
    resolved to the shorter heading, so ``§ Encounter System Nonexistent
    Subsection`` names no heading instead of quietly landing on ``§ Encounter
    System``. See ``continues_a_heading`` for the shapes the refusal reads
    and why lower-case prose, glosses, quotations and code spans still run on
    harmlessly.

    The refusal ends the search: a shorter prefix can only reach a vaguer
    heading, so once a citation has been caught naming a subsection nobody
    wrote there is nothing better left to find.

    Shortening also has a floor. A prefix of *one* word, offered by a citation
    that named more than one, is the weakest claim this loop can accept, and
    ``match_words`` will take that word from anywhere in the breadcrumb — which
    is how ``combat-formulas.md § Act scaling`` reached ``### Regular Enemy HP
    by Act`` (#404). So at ``k == 1`` the word must be the heading's own
    subject; see ``names_the_heading`` for what that means and for the longer
    partial matches it does not cover (#416).

    ``own`` is how many words of ``candidate`` came from the citation's own
    line rather than from the wrapped continuation ``citation_tail`` joined
    on; it bounds the refusal and defaults to all of them.

    A citation may list several sections at once — ``ui-design.md § 2.1/2.3``
    or ``npcs.md § Yara/Caden``. Every listed section must resolve.

    A citation that opens with a section id is resolved by that id alone,
    compared for equality against the id each heading numbers itself with
    rather than matched as words against its breadcrumb. ``§ 3`` therefore
    reaches ``## 3. Game State Machine`` and never ``### 1.3 Autoload
    Singletons``, whose breadcrumb merely contains a ``3`` (#391). The id
    includes any letter suffix: ``§ 1.2a`` reaches
    ``### 1.2a Script Size Budget``, never the adjacent ``### 1.2 Naming
    Conventions``, and ``§ 1.2b`` resolves to nothing and fails. The id
    settles *which* heading, not whether the citation stops there: the
    invention check then runs over the words the id did not account for, so
    ``§ 19. Ley Nexus Hollow 21. Invented Chamber`` is refused — and it is
    refused *through the gate*, not only when this function is called
    directly. That distinction is the whole of #390: while ``citation_extent``
    read the period in ``19.`` as a sentence ending, this example never
    reached the resolver at all, and the guarantee written here was one the
    gate did not keep. Numbered headings are the common shape in ui-design.md,
    technical-architecture.md and dungeons-world.md, so running no check here
    at all would have left #367 standing over most of the corpus.

    Under a section id the shape check reads ids only, because
    capitalization there cannot tell an invented subsection from a locator
    (``audio.md § 3.1 SFX budget``). The document supplies what the shape
    cannot: a capitalized word the id did not account for must be a word the
    cited section itself uses, or the citation is naming something that is
    not in there. ``§ 2.3 Nonexistent Subsection`` is refused on
    ``Nonexistent``; ``§ 3.1 SFX budget`` resolves because § 3.1 Channel
    Budget's table has an ``SFX`` row. See ``unknown_capitalized_word`` for
    exactly how much that checks and how much it does not (#389).
    """
    words = candidate.split()
    if not words:
        return None
    if own is None:
        own = len(words)

    numeric = SECTION_LIST_RE.match(words[0])
    if numeric:
        # Authoritative: a citation that opens with a section id is resolved by
        # that id alone. Falling through to the word-prefix loop on failure
        # would let a shorter prefix of a nonexistent id match its parent.
        hit = match_all(index, path, re.split(r"[/,]", numeric.group(1)))
        if hit is None:
            return None
        k = named_prefix_len(index, path, hit, words)
        if continues_a_heading(words, k, own, by_id=True):
            return None
        if unknown_capitalized_word(index, path, hit, words[k:own]):
            return None
        return hit

    for k in range(len(words), 0, -1):
        joined = " ".join(words[:k])
        want = normalize(joined).split()
        if not want:
            continue
        listed = False
        hit = match_words(index, path, want)
        if hit is None and "/" in joined:
            hit = match_all(index, path, joined.split("/"))
            listed = hit is not None
        if hit is None:
            continue
        if continues_a_heading(words, k, own):
            return None
        # The shortening has run all the way down to one word while the
        # citation named more. That is the weakest match this loop can make,
        # and it is the one that green-lit `§ Act scaling` — so the word has
        # to be the heading's subject, not a word buried inside it. A list
        # citation is exempt: ``hit`` is then only its first part's heading,
        # so there is nothing meaningful to compare the whole token against.
        if k == 1 and own > 1 and not listed:
            if not names_the_heading(hit[2], words[0]):
                return None
        return hit
    return None


def match_all(
    index: DocIndex, path: str, parts: list[str]
) -> tuple[int, int, str] | None:
    """Resolve every part of a slash- or comma-separated section list.

    A part that is itself a section id (``2.1``, ``1.2a``) is resolved
    positionally by ``match_section_id``; a part that is words
    (``npcs.md § Yara/Caden``) by its breadcrumb.
    """
    first: tuple[int, int, str] | None = None
    for part in parts:
        if re.fullmatch(SECTION_ID, part.strip()):
            hit = match_section_id(index, path, part.strip())
        else:
            want = normalize(part).split()
            if not want:
                return None
            hit = match_words(index, path, want)
        if hit is None:
            return None
        first = first or hit
    return first


def cited_path(citing: str, match: re.Match[str]) -> str:
    """Which document a heading citation names.

    A markdown link carries two filenames and they need not agree: in
    ``docs/analysis/game-design-gaps.md`` the citation reads
    ``[magic.md](../story/magic.md)``, where the link text is a bare basename
    and the destination is the real path. Resolving the destination — made
    repo-relative against the citing file's own directory — pins the citation
    to one document; resolving the basename hands ``DocIndex.resolve`` every
    file of that name in the tree and lets the citation pass if *any* of them
    happens to carry the heading. ``README.md`` alone has 9 such files.

    Falls back to the link text when there is no destination, or when the
    destination does not name a file in this repo — a broken link is worth
    reporting as the citation it was trying to be, not as a path lookup that
    silently found nothing.
    """
    target = match.groupdict().get("target")
    if target:
        target = target.split("#", 1)[0]
        if target:
            joined = os.path.join(os.path.dirname(citing), target)
            resolved = os.path.normpath(joined).replace(os.sep, "/")
            if os.path.isfile(resolved):
                return resolved
    return match.group("file")


def citation_signature(cited_file: str, heading_part: str) -> str:
    """Stable printable form of a heading citation, used in messages and keys."""
    return f"{cited_file} § {' '.join(heading_part.split())[:60]}"


def citation_tail(tail: str, markdown: bool) -> tuple[str, int]:
    """Citation text after ``§``, following it across one line wrap.

    Returns the text and the length of the part of it that came from the
    citation's own line, so a caller can tell the two apart after trimming.

    Prose wraps, and a heading wraps with it: ``combat-formulas.md §
    Physical Attack`` / ``Resolution)``. Reading only the first line would
    hand ``Physical Attack`` to the resolver, which happily matches
    ``### Physical Elemental Attacks`` — a green light on a citation that
    points at the wrong section, which is the rot this gate exists to catch.

    So the continuation line joins the first, with its comment or blockquote
    marker stripped. One line only: a heading that wraps twice is not a
    heading.

    Nothing is lost by over-reading, and the second return value is what
    keeps that true. ``match_heading`` walks word prefixes from longest to
    shortest, so extra words can only let a *longer*, more specific heading
    win — but its invention check (#367) refuses a prefix followed by a
    heading-shaped word, and a continuation line is ordinary prose that may
    well open on one (``§ Danger Counter`` / ``Maren banks weave...``).
    Refusing on a word the citation never offered would fail a correct
    citation for how it happens to wrap, so the check is bounded to the
    citation's own line and the joined words can only ever widen the search.
    """
    newline = tail.find("\n")
    if newline < 0:
        return tail, len(tail)
    first = tail[:newline]
    body = tail[newline + 1:].split("\n", 1)[0].strip()
    if not body:
        return first, len(first)
    if body.startswith("#"):
        # In markdown a leading ``#`` opens a new heading, which ends the
        # citation; in code it is comment furniture (``##`` doc comments).
        if markdown:
            return first, len(first)
        body = body.lstrip("#").strip()
    else:
        for mark in ("//", ">", "*"):
            if body.startswith(mark):
                body = body[len(mark):].strip()
                break
    if not body:
        return first, len(first)
    return f"{first} {body}", len(first)


def citation_extent(rest: str) -> str:
    """Trim the trailing prose that cannot belong to the cited heading.

    The house style parenthesises citations — ``(combat-formulas.md § Physical
    Attack Resolution)`` — so a ``)`` with no opener of its own ends the
    citation, as does the ``-->`` of an HTML comment and a sentence-ending
    ``. ``. Headings *do* contain balanced parentheses (``### Derived Rules
    (numeric balance pass)``) and dotted numbers (``### 2.1 Foo``), so neither
    is treated as a terminator. A narrowing term is stepped over whole, because
    ``> 'Shard Burst (AoE on death)'`` may contain any of these — but only a
    quote that follows ``>`` opens one, so the apostrophe in ``§ Cael's Edge``
    stays an apostrophe.

    The one period that is *not* a sentence ending is the one closing a
    *leading* section id. dungeons-world.md numbers its headings as a list —
    ``## 19. Ley Nexus Hollow`` — so a citation spelling that heading out
    reads ``§ 19. Ley Nexus Hollow``, and treating that period as a terminator
    handed the resolver the bare string ``19``. Everything past it was
    discarded before anything read it: not the title words, and not the
    narrowing term — so ``§ 19. <chamber nobody wrote> > '<term nobody
    wrote>'`` passed the gate silently, and so did the run-on second id
    ``§ 19. Ley Nexus Hollow 21. Invented Chamber`` that the resolver's own
    invention check was written to refuse (#390).

    Two rules keep that narrow. The leading period is stepped over only when a
    capitalized word follows it, which is the numbered-list heading shape and
    not the shape of an id followed by prose or code (``§2.4. func
    apply_buff(...)``). A *later* id period ends the citation as any sentence
    would, except that the period stays on the last word: ``21.`` is
    section-shaped where ``21`` is a plain number, and that shape is what the
    resolver's invention check reads.

    Trimming here keeps a citation's identity — the signature the ratchet keys
    on — independent of whatever code or prose happens to follow it.
    """
    depth = 0
    i = 0
    lead = LEADING_ID_DOT_RE.match(rest)
    if lead:
        i = lead.end()
    while i < len(rest):
        ch = rest[i]
        if ch in "'\"" and rest[:i].rstrip().endswith(">"):
            close = rest.find(ch, i + 1)
            if close < 0:
                return rest
            i = close + 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            if depth == 0:
                return rest[:i]
            depth -= 1
        elif rest.startswith("-->", i):
            return rest[:i]
        elif ch == "." and rest[i + 1: i + 2] in (" ", "\t"):
            start = max(rest.rfind(" ", 0, i), rest.rfind("\t", 0, i)) + 1
            if ID_DOT_RE.match(rest, start):
                return rest[: i + 1]
            return rest[:i]
        i += 1
    return rest


def check_file(
    path: str,
    index: DocIndex,
    seen_known: set[tuple[str, str]],
    tally: dict[str, int] | None = None,
) -> list[str]:
    """Citation errors in one file, formatted ``path:line: message``.

    ``tally`` accumulates how much was actually read — see ``check_citations``
    for why a scan that reports nothing has to say how much it looked at.
    """
    try:
        with open(path, encoding="utf-8") as f:
            text = f.read()
    except (UnicodeDecodeError, OSError):
        return []
    return check_text(path, text, index, seen_known, tally)


def check_text(
    path: str,
    text: str,
    index: DocIndex,
    seen_known: set[tuple[str, str]],
    tally: dict[str, int] | None = None,
    line_offset: int = 0,
) -> list[str]:
    """Citation errors in ``text``, reported as if it started in ``path``.

    Split out from ``check_file`` so that a *region* of a file can be checked
    with the same machinery: ``check_gap_design_references`` hands it the
    ``## Design references`` section of a GAP doc, whose surrounding prose is
    a dated record and must stay unchecked (#403). ``line_offset`` is how far
    down the file that region starts, so reported line numbers point at the
    real file rather than at the excerpt.
    """
    errors: list[str] = []

    # In markdown, a fenced block is a template or a transcript, not a
    # citation — docs/story/script/README.md shows the house citation style
    # with a `relevant_doc.md` placeholder.
    skip_lines: set[int] = fenced_lines(text) if path.endswith(".md") else set()

    starts = [0]
    for line in text.split("\n"):
        starts.append(starts[-1] + len(line) + 1)

    def line_of(offset: int) -> int:
        lo, hi = 0, len(starts) - 1
        while lo < hi - 1:
            mid = (lo + hi) // 2
            if starts[mid] <= offset:
                lo = mid
            else:
                hi = mid
        return lo + 1

    for m in LINE_ANCHOR_RE.finditer(text):
        errors.append(
            f"{path}:{line_of(m.start()) + line_offset}: banned "
            f"line-anchored citation "
            f"`{m.group(0)}` — {FIX_HINT_ANCHOR}"
        )

    # (cited filename, offset just past the section sign, forced targets,
    # decorated). A cross-document citation names its file and is resolved
    # through the index; a self-reference has no filename to name and resolves
    # against the document it sits in (#386). *Decorated* means the filename
    # was written as a markdown link or a code span rather than bare — the
    # forms nothing read before #404, counted so the coverage they add is a
    # number on every run rather than a claim in a docstring.
    sites: list[tuple[str, int, list[str] | None, bool]] = [
        (
            cited_path(path, m),
            m.end(),
            None,
            bool(m.group("target")) or m.group(0)[len(m.group("file"))] == "`",
        )
        for m in HEADING_CITE_RE.finditer(text)
    ]
    if path.endswith(".md"):
        named = {
            text.rfind("§", m.start(), m.end())
            for m in HEADING_CITE_RE.finditer(text)
        }
        for m in SELF_CITE_RE.finditer(text):
            if m.start() in named:
                continue
            here = line_of(m.start())
            window_start = starts[here - 2] if here >= 2 else 0
            if NEARBY_DOC_RE.search(text[window_start:m.start()]):
                continue
            sites.append((os.path.basename(path), m.end(), [path], False))
        sites.sort(key=lambda site: site[1])

    for cited_file, cite_end, forced, decorated in sites:
        found_at: int = line_of(cite_end)

        if found_at in skip_lines:
            continue
        line_no: int = found_at + line_offset

        if tally is not None:
            tally["citations"] = tally.get("citations", 0) + 1
            if forced is not None:
                tally["self_references"] = tally.get("self_references", 0) + 1
            if decorated:
                tally["decorated"] = tally.get("decorated", 0) + 1

        # ``own_len`` marks where the citation's own line stops and the
        # wrapped continuation begins. Every trim below returns a *prefix* of
        # ``rest``, so the offset stays meaningful all the way to the
        # resolver, which uses it to bound the invention check (#367).
        rest, own_len = citation_tail(text[cite_end:], path.endswith(".md"))
        boundary = NEXT_CITE_RE.search(rest)
        if boundary:
            rest = rest[: boundary.start()]
        rest = citation_extent(rest)

        term_match = TERM_RE.search(rest)
        term: str | None = None
        heading_part: str = rest
        if term_match:
            term = term_match.group("term")
            heading_part = rest[: term_match.start()]
        else:
            open_term = OPEN_TERM_RE.search(rest)
            if open_term:
                errors.append(
                    f"{path}:{line_no}: narrowing term after `>` never closes "
                    f"its quote — the term check is being skipped, not passed; "
                    f"keep `> 'term'` whole on one line"
                )
                heading_part = rest[: open_term.start()]

        signature = citation_signature(cited_file, heading_part)
        known_key = (path, signature)

        targets = forced if forced is not None else index.resolve(cited_file)
        if not targets:
            if known_key in KNOWN_UNRESOLVED:
                seen_known.add(known_key)
                continue
            errors.append(
                f"{path}:{line_no}: citation names `{cited_file}`, which is "
                f"not a file in this repo — fix the filename"
            )
            continue

        own_words = len(heading_part[:own_len].split())
        hit: tuple[str, tuple[int, int, str]] | None = None
        for target in targets:
            found = match_heading(index, target, heading_part, own_words)
            if found:
                hit = (target, found)
                break
        if hit is None:
            if known_key in KNOWN_UNRESOLVED:
                seen_known.add(known_key)
                continue
            errors.append(
                f"{path}:{line_no}: `{signature}` names no "
                f"heading in {targets[0]} — check the heading text against "
                f"`grep -n '^#' {targets[0]}`"
            )
            continue

        if term is None:
            continue
        target, (h_line, h_level, h_title) = hit
        body = index.section_text(target, h_line, h_level)
        if normalize(term) not in normalize(body):
            errors.append(
                f"{path}:{line_no}: `{term}` does not appear under "
                f"§ {h_title} in {target}:{h_line} — the section moved on "
                f"without the citation; re-read it and cite what it now says"
            )

    return errors


def check_gap_design_references(
    issues_dir: str = GAP_ISSUES_DIR,
    index: DocIndex | None = None,
    tally: dict[str, int] | None = None,
) -> list[str]:
    """Check the ``## Design references`` bullets in the GAP docs (#403).

    ``docs/issues/`` is excluded from the main scan because a GAP doc's
    Summary, Evidence and Notes are a dated record — the tree as it was on
    2026-06-27 — and rewriting a citation there would falsify it. The doc's
    own footer says as much. The Design references section is the exception:
    it is the reader's route into canon *now*, which is why #382/#383 hold
    the Code references section beside it to live paths and ``symbol()``
    anchors. Design references were held to nothing, and still carried the
    line anchors this milestone banned everywhere else — 37 of them across 28
    docs, of which GAP-013's was 65 lines out from the table it named.

    So the section, and only the section, is checked exactly as a live file
    is: no line anchors, every ``§`` citation resolved against a real heading,
    every narrowing term found under it. Each bullet's leading path must also
    exist, which is the one rule ``check_text`` cannot supply — a bullet may
    name a document without naming a section in it.

    Args:
        issues_dir: Directory holding the GAP-NNN docs.
        index: Shared heading index; built here when not supplied.
        tally: Filled with ``gap_docs`` and ``gap_bullets`` — how many docs
            carried a Design references section and how many bullets were
            read out of them. A scan that stopped finding sections reports
            exactly what a clean tree reports without them.
    """
    index = DocIndex() if index is None else index
    seen_known: set[tuple[str, str]] = set()
    errors: list[str] = []
    docs = 0
    bullets = 0
    for doc in sorted(glob.glob(os.path.join(issues_dir, "GAP-*.md"))):
        with open(doc, encoding="utf-8") as handle:
            text = handle.read()
        section = _DESIGN_REF_SECTION.search(text)
        if not section:
            continue
        docs += 1
        offset = text[: section.start(1)].count("\n")
        errors.extend(
            check_text(doc, section.group(1), index, seen_known, None, offset)
        )
        for i, line in enumerate(section.group(1).splitlines(), start=1):
            if not line.startswith("- "):
                continue
            bullets += 1
            token = line[2:].split()[0].rstrip(",") if line[2:].split() else ""
            if "/" not in token or not token.endswith(".md"):
                continue
            if not os.path.isfile(token):
                errors.append(
                    f"{doc}:{offset + i}: Design reference names `{token}`, "
                    f"which is not a file in this repo — the document moved "
                    f"or was renamed; re-point the bullet"
                )
    if tally is not None:
        tally["gap_docs"] = docs
        tally["gap_bullets"] = bullets
    floors = [
        (docs, MIN_GAP_DOCS, "GAP docs with a Design references section"),
        (bullets, MIN_GAP_BULLETS, "Design reference bullets"),
    ]
    errors += [
        f"the Design-reference scan read only {actual} {label} (floor "
        f"{floor}) — it is not reading what it reports on, so a clean result "
        f"would mean nothing; repair the walk rather than lowering the floor"
        for actual, floor, label in floors
        if actual < floor
    ]
    return errors


def check_citations(
    tally: dict[str, int] | None = None, index: DocIndex | None = None
) -> list[str]:
    """Scan every live file for rotted or rot-prone doc citations.

    The GAP docs' Design references are a separate scan —
    ``check_gap_design_references`` — because they are a live region inside a
    directory this one deliberately excludes. ``main`` runs both; a caller
    that wants the whole gate must do the same.

    ``tally``, when given, is filled with ``files``, ``citations``,
    ``self_references`` and ``decorated``: how many files were walked, how
    many citations were resolved in them, how many of those were a document
    referring to its own section (#386), and how many were written as a
    markdown link or a code span (#404). A scan reports its findings by
    returning nothing, and nothing is also what a scan that stopped looking
    returns; the counts are what tells those apart, and ``main`` prints them
    on every run.
    """
    index = DocIndex() if index is None else index
    errors: list[str] = []
    seen_known: set[tuple[str, str]] = set()
    scanned = iter_scanned_files()
    if tally is not None:
        tally.setdefault("citations", 0)
        tally.setdefault("self_references", 0)
        tally.setdefault("decorated", 0)
        tally["files"] = len(scanned)
    for path in scanned:
        errors.extend(check_file(path, index, seen_known, tally))

    for key in sorted(KNOWN_UNRESOLVED):
        if key not in seen_known:
            path, signature = key
            errors.append(
                f"{path}: stale entry in KNOWN_UNRESOLVED for `{signature}` — "
                f"that citation is gone or now resolves; delete the entry from "
                f"scripts/quality-gates/check_doc_citations.py"
            )
    return errors


def main() -> int:
    """Run the citation check. Returns 0 on pass, 1 on failure."""
    tally: dict[str, int] = {}
    index = DocIndex()
    errors: list[str] = check_citations(tally, index)
    errors += check_gap_design_references(index=index, tally=tally)

    if errors:
        print("Doc citation validation FAILED:")
        for e in errors:
            print(f"  {e}")
        print(
            f"\n{len(errors)} bad citation(s). Live files must cite a stable "
            "heading, not a line number."
        )
        return 1

    # State the size of the escape hatch on every run. A number nobody has to
    # count by hand is a number nobody can understate. Same for the size of
    # what was read: "no bad citations" and "no citations read" print the
    # same word otherwise.
    print(
        f"Doc citation validation passed. {tally['citations']} citation(s) "
        f"resolved across {tally['files']} file(s), "
        f"{tally['self_references']} of them same-document (#386) and "
        f"{tally['decorated']} written as a markdown link or code span "
        f"(#404). {tally['gap_bullets']} Design-reference bullet(s) read in "
        f"{tally['gap_docs']} GAP doc(s) (#403). "
        f"{len(KNOWN_UNRESOLVED)} citation(s) pinned in "
        "KNOWN_UNRESOLVED (#366); the list can only shrink."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
