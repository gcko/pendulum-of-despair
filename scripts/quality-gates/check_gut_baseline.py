#!/usr/bin/env python3
"""Quality Gate L: the GUT script/test count floor.

`scripts/quality-gates/gut-baseline.txt` holds FLOORS for how many test scripts
and tests GUT collects. They are the only guard against GUT 9.7.0 dropping a
whole test file over a GDScript parse error while still reporting a green suite:
every remaining test passes, `Failing Tests 0` prints, and the only trace is a
count that fell.

Until #430 the floors were read by `scripts/gates.sh` alone, which nothing runs
for you — so a deleted or parse-skipped test file sailed through both
`.husky/pre-push` and `.github/workflows/gut-tests.yml`. This module is now the
single implementation of BOTH halves, reading the floors and judging a GUT log
against them, so the hook, CI and `gates.sh` cannot drift apart in their parsing
or their wording.

Run bare it validates the baseline file's SHAPE, which is not a formality:
`[ "$SCRIPTS" -lt abc ]` in bash prints "integer expression expected" and
evaluates FALSE, so a corrupted floor used to switch the silent-skip guard off
while still reporting success.

Absence is never a pass. A log with no summary in it FAILS rather than
falling through the comparisons, because a run that died before printing its
summary is indistinguishable from a run that had nothing to say.

    python3 scripts/quality-gates/check_gut_baseline.py               # shape only
    python3 scripts/quality-gates/check_gut_baseline.py --shell       # MIN_* for eval
    python3 scripts/quality-gates/check_gut_baseline.py --log /tmp/gut.log
"""
import argparse
import os
import re
import sys

# Order matters only for the printed report.
FLOOR_KEYS = ("scripts", "tests", "gates", "gate_tests")

_HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BASELINE = os.path.join(_HERE, "gut-baseline.txt")

# Repo-relative name, so the error messages read the same whichever absolute
# path the caller happened to pass.
BASELINE_LABEL = "scripts/quality-gates/gut-baseline.txt"

# The GUT Run Summary block, e.g.
#     Scripts              90
#     Tests              1289
#     Passing Tests      1289
#     Asserts            6621
# Anchored at column 0 and read from the LAST match, matching what gates.sh did
# with `grep -E "^Scripts " | awk '{print $NF}' | tail -1`.
SUMMARY_KEYS = {
    "scripts": "Scripts",
    "tests": "Tests",
    "passing": "Passing Tests",
    "failing": "Failing Tests",
}

# GUT 9.7.0 prints "Failing Tests" ONLY when something failed, so its absence
# cannot serve as the proof that the suite finished — which is precisely how the
# old pre-push gate came to pass vacuously on a run that produced no summary at
# all. These two are printed on every completed run, so THEY are the evidence,
# and only once they are present may a missing "Failing Tests" be read as zero.
REQUIRED_SUMMARY = ("scripts", "tests")

# The lines Godot emits when it refuses a script. These are the visible half of
# a silent skip, and printing them is the difference between "the count fell"
# and "here is the file that stopped compiling".
PARSE_ERROR_RE = re.compile(r"Ignoring script|SCRIPT ERROR|Parse Error", re.IGNORECASE)

FAILED_LINE_RE = re.compile(r"^\s+\[Failed\]")


class BaselineError(Exception):
    """The floors could not be trusted, so nothing downstream may be trusted."""


def read_floors(path=DEFAULT_BASELINE):
    """Return {key: int} for every key in FLOOR_KEYS, or raise BaselineError.

    Mirrors `read_floor()` as it stood in scripts/gates.sh, message for message:
    a floor that is absent, duplicated, non-numeric or zero stops the run rather
    than being silently treated as "no floor".
    """
    try:
        with open(path, encoding="utf-8") as handle:
            text = handle.read()
    except OSError as exc:
        raise BaselineError("%s: cannot be read (%s)" % (BASELINE_LABEL, exc.strerror))

    lines = text.splitlines()
    floors = {}
    for key in FLOOR_KEYS:
        prefix = key + "="
        hits = [line for line in lines if line.startswith(prefix)]
        if len(hits) != 1:
            raise BaselineError(
                "%s: expected exactly one '%s=' line, found %d"
                % (BASELINE_LABEL, key, len(hits))
            )
        # `cut -d= -f2` semantics: the field between the first and second '='.
        raw = hits[0].split("=", 2)[1]
        value = re.sub(r"\s", "", raw)
        if not re.fullmatch(r"[0-9]+", value):
            raise BaselineError(
                "%s: %s='%s' is not a number" % (BASELINE_LABEL, key, value)
            )
        number = int(value)
        if number <= 0:
            raise BaselineError(
                "%s: %s=%d — a zero floor guards nothing"
                % (BASELINE_LABEL, key, number)
            )
        floors[key] = number
    return floors


def parse_counts(log_text):
    """Return {scripts,tests,passing,failing} from a GUT log; None where absent.

    None is a distinct outcome from 0 on purpose. `FAILING=${FAILING:-0}` is how
    a crashed run used to be scored as a clean one.
    """
    counts = dict.fromkeys(SUMMARY_KEYS, None)
    for line in log_text.splitlines():
        for key, label in SUMMARY_KEYS.items():
            if not re.match(r"^%s\s" % re.escape(label), line):
                continue
            fields = line.split()
            if re.fullmatch(r"[0-9]+", fields[-1]):
                counts[key] = int(fields[-1])
    return counts


def _say(out, label, message):
    out.write(("[%s] %s\n" % (label, message)) if label else (message + "\n"))


def judge_log(log_path, floors, out, label="", log_text=None):
    """Score one GUT log against the floors. Returns True when it passes."""
    if log_text is None:
        try:
            with open(log_path, encoding="utf-8", errors="replace") as handle:
                log_text = handle.read()
        except OSError as exc:
            _say(out, label, "GUT LOG UNREADABLE: %s (%s)" % (log_path, exc.strerror))
            return False

    counts = parse_counts(log_text)
    shown = {k: ("?" if v is None else v) for k, v in counts.items()}
    _say(
        out,
        label,
        "RESULT scripts=%s tests=%s passing=%s failing=%s (floors %d/%d)"
        % (
            shown["scripts"],
            shown["tests"],
            shown["passing"],
            0 if counts["failing"] is None and counts["tests"] is not None else shown["failing"],
            floors["scripts"],
            floors["tests"],
        ),
    )

    # --- Absence of the summary FAILS -------------------------------------
    # It does not fall through to the comparisons. A run that never reached its
    # summary looks exactly like a run with nothing wrong, and telling those two
    # apart is the whole job.
    missing = [SUMMARY_KEYS[k] for k in REQUIRED_SUMMARY if counts[k] is None]
    if missing:
        _say(
            out,
            label,
            "GUT SUMMARY MISSING from %s: no %s line. The suite never reached its Run"
            % (log_path, " or ".join("'%s'" % m for m in missing)),
        )
        _say(
            out,
            label,
            "  Summary, so there is nothing to judge — and a test file being SILENTLY",
        )
        _say(
            out,
            label,
            "  SKIPPED looks like this when the run dies early. Absence FAILS, it does",
        )
        _say(out, label, "  not pass.")
        return False

    ok = True
    # Only now, with the Run Summary confirmed present, may an absent
    # "Failing Tests" line be read as zero failures.
    if counts["failing"] is not None and counts["failing"] != 0:
        _say(out, label, "GUT FAILURES:")
        shown_failures = 0
        for number, line in enumerate(log_text.splitlines(), 1):
            if FAILED_LINE_RE.match(line):
                _say(out, label, "%d:%s" % (number, line))
                shown_failures += 1
                if shown_failures >= 30:
                    break
        ok = False

    if counts["scripts"] < floors["scripts"]:
        _say(
            out,
            label,
            "SCRIPT COUNT REGRESSION: %d < %d — a test file is being SILENTLY SKIPPED (parse error),"
            % (counts["scripts"], floors["scripts"]),
        )
        _say(out, label, "  or you removed one on purpose and owe %s an update." % BASELINE_LABEL)
        shown_errors = 0
        for line in log_text.splitlines():
            if PARSE_ERROR_RE.search(line):
                _say(out, label, line)
                shown_errors += 1
                if shown_errors >= 20:
                    break
        ok = False

    if counts["tests"] < floors["tests"]:
        _say(
            out,
            label,
            "TEST COUNT REGRESSION: %d < %d — tests disappeared,"
            % (counts["tests"], floors["tests"]),
        )
        _say(out, label, "  or you removed some on purpose and owe %s an update." % BASELINE_LABEL)
        ok = False

    return ok


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", default=DEFAULT_BASELINE)
    parser.add_argument("--log", default=None, help="GUT log to judge against the floors")
    parser.add_argument("--shell", action="store_true", help="emit MIN_* assignments for eval")
    parser.add_argument("--label", default="", help="prefix diagnostics with [LABEL]")
    args = parser.parse_args(argv)

    # In --shell mode stdout is the return channel for the values, so every
    # diagnostic goes to stderr.
    out = sys.stderr if args.shell else sys.stdout

    try:
        floors = read_floors(args.baseline)
    except BaselineError as exc:
        _say(out, args.label, str(exc))
        _say(out, args.label, "refusing to run rather than pass vacuously")
        return 1

    if args.shell:
        for key in FLOOR_KEYS:
            sys.stdout.write("MIN_%s=%d\n" % (key.upper(), floors[key]))
        return 0

    if args.log is None:
        _say(
            out,
            args.label,
            "%s: floors %s (%d read)"
            % (
                BASELINE_LABEL,
                " ".join("%s=%d" % (k, floors[k]) for k in FLOOR_KEYS),
                len(floors),
            ),
        )
        return 0

    return 0 if judge_log(args.log, floors, out, args.label) else 1


if __name__ == "__main__":
    sys.exit(main())
