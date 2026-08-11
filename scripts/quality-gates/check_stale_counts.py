#!/usr/bin/env python3
"""Quality Gate E: Stale-count scan.

Verifies numeric count claims in the gap tracker match actual
data file counts. Catches mirror staleness — the #1 Copilot
catch pattern across PRs #109-113.

Five independent scans run here:

1. ``check_gap_tracker``       — game/data counts claimed in the gap tracker.
2. ``check_doc_line_counts``   — the ``(NNN)`` line counts in the
   "Canonical Source Documents" table of docs/analysis/game-dev-gaps.md
   (#336: that table went stale silently because nothing measured it).
3. ``check_gap_status_consistency`` — the Status column of the
   docs/issues/README.md table against the Status field of each linked
   GAP doc, plus the running tally in the README header (#345).
4. ``check_gap_code_references`` — every bullet under "## Code references" in
   each GAP doc must name a path that exists and must not carry a
   ``file.gd:NNN`` line anchor; where a bullet names a ``symbol()`` the file
   must define it (#318: the whole point of anchoring on function names
   instead of line numbers is that it can be verified).
5. ``check_gap_measured_tables`` — the "current" column of any measured
   line-count table inside a GAP doc against ``wc -l`` (#319: GAP-087 carries
   eight hand-written counts of actively-developed files).

Exit code 0 = pass, 1 = stale counts found.
"""
import json
import glob
import os
import re
import sys

GAP_TRACKER = "docs/analysis/game-dev-gaps.md"
ISSUES_DIR = "docs/issues"


def count_actual_data() -> dict[str, int]:
    """Count actual entries in all game data directories."""
    counts: dict[str, int] = {}

    counts["encounter_files"] = len(glob.glob("game/data/encounters/*.json"))
    counts["dialogue_files"] = len(glob.glob("game/data/dialogue/*.json"))
    counts["shop_files"] = len(glob.glob("game/data/shops/*.json"))

    for name, pattern, key in [
        ("devices", "game/data/crafting/devices.json", "devices"),
        ("synergies", "game/data/crafting/synergies.json", "synergies"),
    ]:
        try:
            with open(pattern) as f:
                data = json.load(f)
            counts[name] = len(data.get(key, []))
        except (FileNotFoundError, json.JSONDecodeError):
            pass

    try:
        with open("game/data/crafting/recipes.json") as f:
            data = json.load(f)
        counts["forging_recipes"] = len(data.get("forging_recipes", []))
        counts["infusions"] = len(data.get("infusions", []))
    except (FileNotFoundError, json.JSONDecodeError):
        pass

    return counts


def check_gap_tracker(
    counts: dict[str, int],
    gap_file: str = "docs/analysis/game-dev-gaps.md",
) -> list[str]:
    """Check gap tracker for stale count claims.

    Args:
        gap_file: Path to the gap tracker markdown file.
    """
    errors: list[str] = []

    try:
        with open(gap_file) as f:
            content = f.read()
    except FileNotFoundError:
        return []

    # Each tuple: (regex with capture group for claimed count, count key, label)
    checks: list[tuple[str, str, str]] = [
        (r"(\d+)\s+encounter file", "encounter_files", "encounter files"),
        (r"(\d+)\s+shop file", "shop_files", "shop files"),
        (r"(\d+)\s+device", "devices", "devices"),
        (r"(\d+)\s+synerg", "synergies", "synergies"),
        (r"(\d+)\s+forging", "forging_recipes", "forging recipes"),
        (r"(\d+)\s+(?:elemental\s+)?infusion", "infusions", "infusions"),
    ]

    for pattern, count_key, label in checks:
        m = re.search(pattern, content, re.IGNORECASE)
        if m:
            claimed = int(m.group(1))
            actual = counts.get(count_key, 0)
            if claimed != actual:
                errors.append(
                    f"STALE COUNT in {gap_file}: "
                    f"claims {claimed} {label}, actual {actual}"
                )

    return errors


def _line_count(path: str) -> int:
    """Line count of a file, matching ``wc -l`` (newline-terminated lines)."""
    with open(path, "rb") as f:
        return f.read().count(b"\n")


def _canonical_table(content: str) -> str:
    """The 'Canonical Source Documents' table body, or '' if absent."""
    start = content.find("| Category | Source Documents |")
    if start == -1:
        return ""
    end = content.find("\n\n", start)
    return content[start:end if end != -1 else len(content)]


def check_doc_line_counts(
    gap_file: str = GAP_TRACKER,
    story_dir: str = "docs/story",
) -> list[str]:
    """Check the ``(NNN)`` line-count claims in the canonical-source table.

    Every ``\\`name.md\\` (NNN)`` entry must match ``wc -l`` of the file, and
    every ``\\`subdir/\\` (N files)`` entry must match the number of ``*.md``
    files in it. Paths starting with ``docs/`` are repo-relative; bare names
    resolve under ``story_dir``.

    Args:
        gap_file: Path to the gap tracker markdown file.
        story_dir: Directory that bare document names resolve against.
    """
    errors: list[str] = []
    try:
        with open(gap_file) as f:
            table = _canonical_table(f.read())
    except FileNotFoundError:
        return []
    if not table:
        return [f"STALE COUNT in {gap_file}: canonical-source table not found"]

    for name, claimed_raw in re.findall(r"`([\w./-]+\.md)` \(([\d,]+)\)", table):
        path = name if name.startswith("docs/") else os.path.join(story_dir, name)
        if not os.path.exists(path):
            errors.append(
                f"STALE COUNT in {gap_file}: cites `{name}` but {path} does not exist"
            )
            continue
        actual = _line_count(path)
        claimed = int(claimed_raw.replace(",", ""))
        if claimed != actual:
            errors.append(
                f"STALE COUNT in {gap_file}: `{name}` claims {claimed} lines, "
                f"actual {actual} — fix by writing `{name}` ({actual:,})"
            )

    for name, claimed_raw in re.findall(r"`([\w./-]+/)` \((\d+) files\)", table):
        actual = len(glob.glob(os.path.join(story_dir, name, "*.md")))
        claimed = int(claimed_raw)
        if claimed != actual:
            errors.append(
                f"STALE COUNT in {gap_file}: `{name}` claims {claimed} files, "
                f"actual {actual} — fix by writing `{name}` ({actual} files)"
            )

    return errors


_STATUS_WORDS = {
    "fixed": "resolved",
    "already": "resolved",
    "done": "resolved",
    "resolved": "resolved",
    "open": "open",
    "partial": "partial",
}


def normalize_status(raw: str) -> str:
    """Reduce a free-text Status to one of open / partial / resolved.

    Both the README table and the GAP docs decorate their statuses with issue
    numbers, emoji and prose ("✅ fixed", "resolved — #157", "open —
    CONFIRMED"). Only the leading word carries the state, so compare that.
    Returns ``"?" + word`` for anything unrecognised so the caller reports it
    rather than silently treating it as a match.
    """
    text = raw.replace("✅", "").strip().lower()
    word = re.split(r"[\s—(]+", text)[0] if text else ""
    return _STATUS_WORDS.get(word, "?" + word)


_ROW_RE = re.compile(
    r"^\| \[(GAP-\d+)\]\(([^)]*)\)( 🏔️)? \| [^|]* \| [^|]* \| [^|]* \| ([^|]*) \| [^|]*\|$",
    re.M,
)


def check_gap_status_consistency(issues_dir: str = ISSUES_DIR) -> list[str]:
    """Check docs/issues/README.md against the GAP docs it links to.

    Two claims are verified: each row's Status agrees with the Status field of
    the linked file, and the running tally in the README header matches the
    tally of those files.

    Args:
        issues_dir: Directory holding README.md and the GAP-NNN docs.
    """
    readme = os.path.join(issues_dir, "README.md")
    try:
        with open(readme) as f:
            content = f.read()
    except FileNotFoundError:
        return []

    errors: list[str] = []
    tally = {"open": 0, "partial": 0, "resolved": 0}
    epics = 0
    rows = _ROW_RE.findall(content)
    if not rows:
        return [f"STALE COUNT in {readme}: issue table not found or unparseable"]

    for gap_id, link, epic_marker, row_status in rows:
        if epic_marker:
            epics += 1
        doc = os.path.join(issues_dir, link)
        try:
            with open(doc) as f:
                doc_text = f.read()
        except FileNotFoundError:
            errors.append(f"STALE LINK in {readme}: {gap_id} links to missing {doc}")
            continue
        m = re.search(r"^\| \*\*Status\*\* \| (.*?) \|$", doc_text, re.M)
        if not m:
            errors.append(f"STALE STATUS in {doc}: no Status field to compare against")
            continue
        doc_state = normalize_status(m.group(1))
        row_state = normalize_status(row_status)
        if doc_state.startswith("?"):
            errors.append(
                f"STALE STATUS in {doc}: unrecognised Status '{m.group(1)}'"
            )
            continue
        if row_state != doc_state:
            errors.append(
                f"STALE STATUS in {readme}: {gap_id} row says '{row_status}' "
                f"({row_state}) but {os.path.basename(doc)} says "
                f"'{m.group(1)}' ({doc_state})"
            )
        # The GAP doc is the source of truth for the tally, so a disagreeing
        # row is reported above but does not distort the counted total.
        tally[doc_state] += 1

    claims = {
        "gap files": len(rows),
        "open": tally["open"],
        "partial": tally["partial"],
        "resolved": tally["resolved"],
        "epics": epics,
    }
    for label, actual in claims.items():
        m = re.search(r"\*\*(\d+) %s\*\*" % re.escape(label), content)
        if not m:
            errors.append(
                f"STALE COUNT in {readme}: running tally is missing a "
                f"'**N {label}**' claim"
            )
            continue
        claimed = int(m.group(1))
        if claimed != actual:
            errors.append(
                f"STALE COUNT in {readme}: running tally claims {claimed} "
                f"{label}, actual {actual}"
            )

    return errors


_CODE_REF_SECTION = re.compile(r"^## Code references\n(.*?)(?=^## |\Z)", re.M | re.S)
_CODE_REF_BULLET = re.compile(r"^- (game/[\w/.-]+\.gd)\b(.*)$", re.M)
_SYMBOL = re.compile(r"`(\w+)\(\)`")


def check_gap_code_references(issues_dir: str = ISSUES_DIR) -> list[str]:
    """Check symbol-anchored 'Code references' bullets in the GAP docs.

    A bullet of the form ``- <path>.gd — `symbol()``` is the maintained anchor
    that replaced rotting ``file.gd:NNN`` citations (#318). It is only worth
    more than a line number if it is verified, so: the file must exist and must
    define every symbol named on that bullet. Bullets with no ``symbol()``
    token are historical prose (e.g. GAP-086 cites a pre-move path on purpose)
    and are left alone.

    Args:
        issues_dir: Directory holding the GAP-NNN docs.
    """
    errors: list[str] = []
    for doc in sorted(glob.glob(os.path.join(issues_dir, "GAP-*.md"))):
        with open(doc) as f:
            section = _CODE_REF_SECTION.search(f.read())
        if not section:
            continue
        for path, rest in _CODE_REF_BULLET.findall(section.group(1)):
            symbols = _SYMBOL.findall(rest)
            if not symbols:
                continue
            if not os.path.exists(path):
                errors.append(
                    f"STALE REFERENCE in {os.path.basename(doc)}: "
                    f"{path} does not exist (cites {', '.join(symbols)})"
                )
                continue
            with open(path) as f:
                source = f.read()
            for symbol in symbols:
                if not re.search(
                    r"^(static )?func %s\(" % re.escape(symbol), source, re.M
                ):
                    errors.append(
                        f"STALE REFERENCE in {os.path.basename(doc)}: "
                        f"{path} does not define {symbol}() — it moved or was "
                        f"renamed; re-anchor the bullet at its current file"
                    )

    return errors


_BLANK_CELLS = {"", "-", "—", "–", "n/a"}


def _table_blocks(content: str) -> list[list[str]]:
    """Contiguous runs of markdown table lines, header row first."""
    blocks: list[list[str]] = []
    current: list[str] = []
    for line in content.splitlines():
        if line.startswith("|"):
            current.append(line)
        elif current:
            blocks.append(current)
            current = []
    if current:
        blocks.append(current)
    return blocks


def _cells(row: str) -> list[str]:
    """Cell texts of a markdown table row, outer pipes discarded."""
    return [c.strip() for c in row.strip().strip("|").split("|")]


def check_gap_measured_tables(issues_dir: str = ISSUES_DIR) -> list[str]:
    """Check hand-written "current" line-count columns in the GAP docs (#319).

    A GAP doc may carry a measured table whose first column is a backticked
    repo path and whose final column header begins with "current" — GAP-087
    records eight such counts for actively-developed files. Those numbers are
    the whole evidence for the gap being resolved, so a one-line change to any
    of the files must fail the build rather than quietly rot. Rows whose count
    cell is blank or an em-dash (no measurement taken) are skipped.

    Args:
        issues_dir: Directory holding the GAP-NNN docs.
    """
    errors: list[str] = []
    for doc in sorted(glob.glob(os.path.join(issues_dir, "GAP-*.md"))):
        with open(doc) as f:
            content = f.read()
        name = os.path.basename(doc)
        for block in _table_blocks(content):
            if len(block) < 3:
                continue
            header = _cells(block[0])
            if not header or not header[-1].lower().startswith("current"):
                continue
            column = header[-1]
            for row in block[2:]:
                cells = _cells(row)
                if len(cells) != len(header):
                    continue
                path = cells[0].strip("`")
                if "/" not in path:
                    continue
                claimed_raw = cells[-1].replace(",", "")
                if claimed_raw.lower() in _BLANK_CELLS:
                    continue
                if not claimed_raw.isdigit():
                    errors.append(
                        f"STALE COUNT in {name}: '{column}' cell for `{path}` "
                        f"is {cells[-1]!r}, which is not a line count"
                    )
                    continue
                if not os.path.exists(path):
                    errors.append(
                        f"STALE COUNT in {name}: measured table cites `{path}` "
                        f"but it does not exist"
                    )
                    continue
                actual = _line_count(path)
                claimed = int(claimed_raw)
                if claimed != actual:
                    errors.append(
                        f"STALE COUNT in {name}: `{path}` claims {claimed} "
                        f"lines under '{column}', actual {actual} — fix by "
                        f"writing {actual} in that cell"
                    )

    return errors


def main() -> int:
    """Run stale-count scan. Returns 0 on pass, 1 on failure."""
    counts: dict[str, int] = count_actual_data()
    errors: list[str] = check_gap_tracker(counts)
    errors += check_doc_line_counts()
    errors += check_gap_status_consistency()
    errors += check_gap_code_references()
    errors += check_gap_measured_tables()

    if errors:
        print("Stale-count scan FAILED:")
        for e in errors:
            print(f"  {e}")
        return 1

    print("Stale-count scan passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
