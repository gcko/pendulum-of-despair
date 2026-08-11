#!/usr/bin/env python3
"""Quality Gate G: doc citation integrity.

Line-anchored citations (``magic.md:1537``) rot silently: inserting a
paragraph above the cited line repoints every citation below it, and no
test notices. This gate makes that impossible in live files by

1. **banning** the ``<name>.md:NNN`` / ``<name>.gd:NNN`` form outright, and
2. **resolving** the replacement form ``<name>.md § <Heading>`` against the
   target document, optionally narrowing to a quoted term that must appear
   inside that section: ``magic.md § Status Effect Reference > 'Poison'``.

Scanned: docs/, game/scripts/, game/tests/, game/data/, scripts/.

Not scanned: docs/issues/ and docs/superpowers/. Those are **dated
records** — a bug report or a design plan describes the tree as it was on
the day it was written, so a citation there is a snapshot, not a live
pointer, and rewriting it would falsify the record.

Exit code 0 = pass, 1 = offending citations found.
"""
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

# "magic.md:1537", "status_effects.gd:25" — the banned form.
LINE_ANCHOR_RE = re.compile(
    r"(?<![\w/.])([A-Za-z0-9_][A-Za-z0-9_.\-]*\.(?:md|gd)):(\d+)"
)

# "magic.md § Status Effect Reference"; tolerates a line wrap (with an
# optional comment marker) between the filename and the section sign, which
# is how the citation lands inside wrapped GDScript ``##`` doc comments.
# The match deliberately stops at the section sign rather than capturing the
# heading, so that a line carrying several citations yields several matches.
HEADING_CITE_RE = re.compile(
    r"(?P<file>[A-Za-z0-9_][A-Za-z0-9_.\-/]*\.md)"
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


def continues_a_heading(words: list[str], k: int) -> bool:
    """True when the citation keeps naming heading after the prefix ends.

    ``match_heading`` accepts a prefix ``words[:k]``, which means every
    longer prefix — ``words[:k + 1]`` included — matched no heading at all.
    So ``words[k]`` is a word the citation offers as part of the section's
    name and the document does not have. When it is *shaped* like a heading
    word — capitalised, opening no gloss, quote or code — the citation is
    naming a subsection nobody wrote, and resolving it to the shorter
    heading would point the reader at a section that does not say what the
    citation claims (#367).

    The shape test is what keeps the deliberate shortening alive. Citations
    sit mid-sentence, and the prose that follows a heading name continues in
    lower case (``§ Derived Rules binds it only to...``), opens a
    parenthetical gloss (``§ 20. Highcairn Monastery (Pallor encounter)``),
    a quotation (``§ Wolf Family, "all wolves"``) or a code span. None of
    those is a claim about the document's heading tree; a bare capitalised
    word is.
    """
    if k >= len(words):
        return False
    first = words[k][:1]
    return first.isalpha() and first.isupper()


def match_heading(
    index: DocIndex, path: str, candidate: str
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

    Shortening stops where invention starts. A prefix that is followed by a
    capitalised word — a word shaped like more heading, which by
    construction matches nothing — is refused outright rather than resolved
    to the shorter heading, so ``§ Encounter System Nonexistent Subsection``
    now names no heading instead of quietly landing on ``§ Encounter
    System``. See ``continues_a_heading`` for why the refusal reads
    capitalisation and why lower-case prose, glosses, quotations and code
    spans still run on harmlessly.

    The refusal ends the search: a shorter prefix can only reach a vaguer
    heading, so once a citation has been caught naming a subsection nobody
    wrote there is nothing better left to find.

    A citation may list several sections at once — ``ui-design.md § 2.1/2.3``
    or ``npcs.md § Yara/Caden``. Every listed section must resolve.

    A citation that opens with a section id is resolved by that id alone, and
    the id includes any letter suffix: ``§ 1.2a`` reaches
    ``### 1.2a Script Size Budget``, never the adjacent ``### 1.2 Naming
    Conventions``, and ``§ 1.2b`` resolves to nothing and fails.
    """
    words = candidate.split()
    if not words:
        return None

    numeric = SECTION_LIST_RE.match(words[0])
    if numeric:
        # Authoritative: a citation that opens with a section id is resolved by
        # that id alone. Falling through to the word-prefix loop on failure
        # would let a shorter prefix of a nonexistent id match its parent.
        return match_all(index, path, re.split(r"[/,]", numeric.group(1)))

    for k in range(len(words), 0, -1):
        joined = " ".join(words[:k])
        want = normalize(joined).split()
        if not want:
            continue
        hit = match_words(index, path, want)
        if hit is None and "/" in joined:
            hit = match_all(index, path, joined.split("/"))
        if hit is None:
            continue
        if continues_a_heading(words, k):
            return None
        return hit
    return None


def match_all(
    index: DocIndex, path: str, parts: list[str]
) -> tuple[int, int, str] | None:
    """Resolve every part of a slash- or comma-separated section list."""
    first: tuple[int, int, str] | None = None
    for part in parts:
        want = normalize(part).split()
        if not want:
            return None
        hit = match_words(index, path, want)
        if hit is None:
            return None
        first = first or hit
    return first


def citation_signature(cited_file: str, heading_part: str) -> str:
    """Stable printable form of a heading citation, used in messages and keys."""
    return f"{cited_file} § {' '.join(heading_part.split())[:60]}"


def citation_tail(tail: str, markdown: bool) -> str:
    """Citation text after ``§``, following it across one line wrap.

    Prose wraps, and a heading wraps with it: ``combat-formulas.md §
    Physical Attack`` / ``Resolution)``. Reading only the first line would
    hand ``Physical Attack`` to the resolver, which happily matches
    ``### Physical Elemental Attacks`` — a green light on a citation that
    points at the wrong section, which is the rot this gate exists to catch.

    So the continuation line joins the first, with its comment or blockquote
    marker stripped. One line only: a heading that wraps twice is not a
    heading. Nothing is lost by over-reading, because ``match_heading`` walks
    word prefixes from longest to shortest — the extra words can only let a
    *longer*, more specific heading win.
    """
    newline = tail.find("\n")
    if newline < 0:
        return tail
    first = tail[:newline]
    body = tail[newline + 1:].split("\n", 1)[0].strip()
    if not body:
        return first
    if body.startswith("#"):
        # In markdown a leading ``#`` opens a new heading, which ends the
        # citation; in code it is comment furniture (``##`` doc comments).
        if markdown:
            return first
        body = body.lstrip("#").strip()
    else:
        for mark in ("//", ">", "*"):
            if body.startswith(mark):
                body = body[len(mark):].strip()
                break
    return f"{first} {body}" if body else first


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

    Trimming here keeps a citation's identity — the signature the ratchet keys
    on — independent of whatever code or prose happens to follow it.
    """
    depth = 0
    i = 0
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
            return rest[:i]
        i += 1
    return rest


def check_file(
    path: str, index: DocIndex, seen_known: set[tuple[str, str]]
) -> list[str]:
    """Citation errors in one file, formatted ``path:line: message``."""
    errors: list[str] = []
    try:
        with open(path, encoding="utf-8") as f:
            text = f.read()
    except (UnicodeDecodeError, OSError):
        return errors

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
            f"{path}:{line_of(m.start())}: banned line-anchored citation "
            f"`{m.group(0)}` — {FIX_HINT_ANCHOR}"
        )

    for m in HEADING_CITE_RE.finditer(text):
        cited_file: str = m.group("file")
        line_no: int = line_of(m.end())

        if line_no in skip_lines:
            continue

        rest: str = citation_tail(text[m.end():], path.endswith(".md"))
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

        targets = index.resolve(cited_file)
        if not targets:
            if known_key in KNOWN_UNRESOLVED:
                seen_known.add(known_key)
                continue
            errors.append(
                f"{path}:{line_no}: citation names `{cited_file}`, which is "
                f"not a file in this repo — fix the filename"
            )
            continue

        hit: tuple[str, tuple[int, int, str]] | None = None
        for target in targets:
            found = match_heading(index, target, heading_part)
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


def check_citations() -> list[str]:
    """Scan every live file for rotted or rot-prone doc citations."""
    index = DocIndex()
    errors: list[str] = []
    seen_known: set[tuple[str, str]] = set()
    for path in iter_scanned_files():
        errors.extend(check_file(path, index, seen_known))

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
    errors: list[str] = check_citations()

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
    # count by hand is a number nobody can understate.
    print(
        f"Doc citation validation passed. {len(KNOWN_UNRESOLVED)} citation(s) "
        "pinned in KNOWN_UNRESOLVED (#366); the list can only shrink."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
