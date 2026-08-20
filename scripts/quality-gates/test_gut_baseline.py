#!/usr/bin/env python3
"""Quality Gate I coverage for Gate L (`check_gut_baseline.py`).

Two kinds of test live here and they fail differently, so both are needed:

  * fixture tests, which prove the parsing and the verdicts are right; and
  * WIRING tests, which prove the hook, CI and `scripts/gates.sh` actually call
    the thing. `test_quality_gates.py` once had 36 green tests that no hook ran,
    which is the exact shape of bug a fixture-only suite cannot see.

The wiring tests match an UNCOMMENTED invocation, not the string
`check_gut_baseline.py`. They were substring assertions once, and the name also
appears in prose in all three callers -- the pre-push gate registry, the
gates.sh header, the CI step's rationale -- so both call sites could be
commented out with all 46 tests still green (#430). `gate_run_lines()` below is
the matcher, and it is itself tested against a commented-out call.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
"""
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import check_gut_baseline as gate  # noqa: E402

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

GOOD_BASELINE = "\n".join(
    [
        "# a comment",
        "",
        "scripts=90",
        "tests=1289",
        "gates=7",
        "gate_tests=280",
        "",
    ]
)

# A realistic tail of a green run, ANSI already stripped the way every caller
# strips it before writing the log. Note there is NO "Failing Tests" line: GUT
# 9.7.0 prints that one only when something failed, which is why its absence
# cannot be the check for whether the suite finished.
GREEN_LOG = "\n".join(
    [
        "Totals",
        "------",
        "Warnings             26",
        "",
        "Scripts              90",
        "Tests              1289",
        "Passing Tests      1289",
        "Asserts            6621",
        "Time            67.923s",
        "",
        "---- All tests passed! ----",
        "",
    ]
)

# The same block from a run that failed two tests.
RED_LOG = GREEN_LOG.replace(
    "Passing Tests      1289",
    "Passing Tests      1287\nFailing Tests         2",
).replace("---- All tests passed! ----", "---- 2 failing tests ----")


GATE_SCRIPT = "check_gut_baseline.py"


def uncommented(text):
    """`text` with comment-only lines dropped.

    Every assertion about what a script DOES has to read this rather than the
    raw file. These scripts explain the bugs they fixed in prose, so the string
    a test is asserting is absent from the CODE is routinely still present in a
    comment describing why it was removed.
    """
    return "\n".join(
        line for line in text.splitlines() if not line.strip().startswith("#")
    )


def gate_run_lines(text):
    """Return the UNCOMMENTED lines of `text` that run Gate L against a log.

    Presence of the string `check_gut_baseline.py` is not wiring: it survives in
    comments in every caller, so a commented-out invocation satisfies an
    `assertIn` while running nothing. A line counts here only if it is not
    comment-only, invokes python3, names the gate (directly or through a shell
    variable assigned its path in the same file), and passes `--log` -- the
    argument that makes it judge a run rather than validate the floors' shape.
    """
    names = [re.escape(GATE_SCRIPT)]
    for var in re.findall(
        r'^\s*([A-Za-z_][A-Za-z0-9_]*)="[^"]*%s"' % re.escape(GATE_SCRIPT), text, re.M
    ):
        names.append(r"\$\{?%s\}?" % re.escape(var))
    pattern = re.compile(r"python3\b.*(?:%s)\b.*--log\b" % "|".join(names))
    hits = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if pattern.search(line):
            hits.append(stripped)
    return hits


def _floors(**overrides):
    values = {"scripts": 90, "tests": 1289, "gates": 7, "gate_tests": 280}
    values.update(overrides)
    return values


def _judge(log_text, floors=None):
    """Run the verdict over a log body, returning (passed, printed output)."""
    out = io.StringIO()
    ok = gate.judge_log(
        "/tmp/fixture-gut.log", floors or _floors(), out, log_text=log_text
    )
    return ok, out.getvalue()


class TestReadFloors(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def _write(self, text):
        path = os.path.join(self.tmpdir, "gut-baseline.txt")
        with io.open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        return path

    def test_reads_every_floor(self):
        floors = gate.read_floors(self._write(GOOD_BASELINE))
        self.assertEqual(floors, {"scripts": 90, "tests": 1289, "gates": 7, "gate_tests": 280})

    def test_tolerates_surrounding_whitespace(self):
        path = self._write(GOOD_BASELINE.replace("tests=1289", "tests= 1289 "))
        self.assertEqual(gate.read_floors(path)["tests"], 1289)

    def test_missing_key_raises(self):
        path = self._write(GOOD_BASELINE.replace("tests=1289\n", ""))
        with self.assertRaises(gate.BaselineError) as caught:
            gate.read_floors(path)
        self.assertIn("expected exactly one 'tests=' line, found 0", str(caught.exception))

    def test_commented_out_key_does_not_count(self):
        path = self._write(GOOD_BASELINE.replace("tests=1289", "#tests=1289"))
        with self.assertRaises(gate.BaselineError):
            gate.read_floors(path)

    def test_duplicate_key_raises(self):
        path = self._write(GOOD_BASELINE + "tests=99\n")
        with self.assertRaises(gate.BaselineError) as caught:
            gate.read_floors(path)
        self.assertIn("found 2", str(caught.exception))

    def test_non_numeric_raises(self):
        path = self._write(GOOD_BASELINE.replace("scripts=90", "scripts=abc"))
        with self.assertRaises(gate.BaselineError) as caught:
            gate.read_floors(path)
        self.assertIn("is not a number", str(caught.exception))

    def test_negative_raises(self):
        path = self._write(GOOD_BASELINE.replace("scripts=90", "scripts=-5"))
        with self.assertRaises(gate.BaselineError):
            gate.read_floors(path)

    def test_zero_floor_raises(self):
        path = self._write(GOOD_BASELINE.replace("scripts=90", "scripts=0"))
        with self.assertRaises(gate.BaselineError) as caught:
            gate.read_floors(path)
        self.assertIn("a zero floor guards nothing", str(caught.exception))

    def test_missing_file_raises(self):
        with self.assertRaises(gate.BaselineError):
            gate.read_floors(os.path.join(self.tmpdir, "absent.txt"))

    def test_gate_tests_key_is_not_confused_with_tests(self):
        # `tests=` and `gate_tests=` share a suffix; an unanchored match would
        # read the wrong number and the floor would guard the wrong thing.
        floors = gate.read_floors(self._write(GOOD_BASELINE))
        self.assertNotEqual(floors["tests"], floors["gate_tests"])


class TestParseCounts(unittest.TestCase):
    def test_parses_a_green_summary(self):
        counts = gate.parse_counts(GREEN_LOG)
        self.assertEqual(counts["scripts"], 90)
        self.assertEqual(counts["tests"], 1289)
        self.assertEqual(counts["passing"], 1289)
        # Absent, not zero: GUT omits the line entirely when nothing failed.
        self.assertIsNone(counts["failing"])

    def test_parses_the_risky_pending_total(self):
        # GUT prints this one only when it is non-zero (`_log_non_zero_total`).
        counts = gate.parse_counts("Risky/Pending         7\n")
        self.assertEqual(counts["risky"], 7)

    def test_absent_risky_line_is_none(self):
        self.assertIsNone(gate.parse_counts(GREEN_LOG)["risky"])

    def test_parses_a_red_summary(self):
        counts = gate.parse_counts(RED_LOG)
        self.assertEqual(counts["failing"], 2)
        self.assertEqual(counts["passing"], 1287)

    def test_absent_lines_are_none_not_zero(self):
        counts = gate.parse_counts("Godot Engine v4.7\nsome output\n")
        self.assertIsNone(counts["scripts"])
        self.assertIsNone(counts["tests"])
        self.assertIsNone(counts["failing"])

    def test_last_summary_wins(self):
        counts = gate.parse_counts(GREEN_LOG + GREEN_LOG.replace("Tests              1289", "Tests              1300"))
        self.assertEqual(counts["tests"], 1300)

    def test_tests_line_is_not_matched_by_passing_tests(self):
        counts = gate.parse_counts("Passing Tests      1289\nFailing Tests         0\nScripts              90\n")
        self.assertIsNone(counts["tests"])


class TestJudgeLog(unittest.TestCase):
    def test_green_log_at_the_floor_passes(self):
        ok, output = _judge(GREEN_LOG)
        self.assertTrue(ok, output)
        self.assertIn("RESULT scripts=90 tests=1289", output)
        self.assertIn("(floors 90/1289)", output)

    def test_empty_log_fails_rather_than_passing_vacuously(self):
        # The whole point of #430: a run that died before its summary must not
        # be scored as a clean run.
        ok, output = _judge("")
        self.assertFalse(ok)
        self.assertIn("GUT SUMMARY MISSING", output)

    def test_crashed_run_with_partial_summary_fails(self):
        ok, output = _judge("Scripts              90\nGodot crashed\n")
        self.assertFalse(ok)
        self.assertIn("GUT SUMMARY MISSING", output)
        self.assertIn("'Tests'", output)

    def test_all_tests_passed_banner_alone_is_not_enough(self):
        # CI used to accept this string appearing anywhere in the output.
        ok, output = _judge("---- All tests passed! ----\n")
        self.assertFalse(ok)
        self.assertIn("GUT SUMMARY MISSING", output)

    def test_absent_failing_line_means_zero_once_the_summary_is_present(self):
        # GUT prints "Failing Tests" only when something failed. Reading its
        # absence as zero is correct HERE, and only here, because the Run
        # Summary totals have already proved the suite reached the end.
        self.assertNotIn("Failing Tests", GREEN_LOG)
        ok, output = _judge(GREEN_LOG)
        self.assertTrue(ok, output)
        self.assertIn("failing=0", output)

    def test_absent_failing_line_without_a_summary_still_fails(self):
        # The same absence, with no totals behind it, is the vacuous pass.
        ok, output = _judge("Godot Engine v4.7\nsome output\n")
        self.assertFalse(ok)
        self.assertIn("GUT SUMMARY MISSING", output)

    def test_dropped_script_fails_with_the_silent_skip_diagnosis(self):
        log = GREEN_LOG.replace("Scripts              90", "Scripts              89")
        ok, output = _judge(log)
        self.assertFalse(ok)
        self.assertIn("SCRIPT COUNT REGRESSION: 89 < 90", output)
        self.assertIn("SILENTLY SKIPPED", output)
        self.assertIn("gut-baseline.txt an update", output)

    def test_script_regression_prints_the_parse_errors(self):
        log = (
            "SCRIPT ERROR: Parse Error: Identifier \"foo\" not declared\n"
            "  at: GDScript::reload (res://tests/test_thing.gd:12)\n"
            + GREEN_LOG.replace("Scripts              90", "Scripts              89")
        )
        ok, output = _judge(log)
        self.assertFalse(ok)
        self.assertIn("SCRIPT ERROR", output)

    def test_dropped_tests_fail(self):
        log = GREEN_LOG.replace("Tests              1289", "Tests              1288")
        ok, output = _judge(log)
        self.assertFalse(ok)
        self.assertIn("TEST COUNT REGRESSION: 1288 < 1289", output)

    def test_counts_above_the_floor_pass(self):
        log = GREEN_LOG.replace("Scripts              90", "Scripts              95")
        ok, output = _judge(log)
        self.assertTrue(ok, output)

    def test_failing_tests_fail_and_are_listed(self):
        log = "    [Failed]: expected 1 to equal 2\n" + RED_LOG
        ok, output = _judge(log)
        self.assertFalse(ok)
        self.assertIn("GUT FAILURES:", output)
        self.assertIn("[Failed]", output)

    def test_tests_that_never_passed_fail_even_with_no_failures(self):
        # `passing` used to be parsed, printed and never judged: Tests 1289 with
        # Passing Tests 0 cleared both floors and the gate reported success.
        log = GREEN_LOG.replace("Passing Tests      1289", "Passing Tests         0")
        ok, output = _judge(log)
        self.assertFalse(ok, output)
        self.assertIn("TESTS RAN WITHOUT PASSING: 1289 of 1289", output)

    def test_a_whole_suite_gone_pending_fails(self):
        # Pending and risky tests still count toward `Tests`, so every floor
        # holds while nothing is being tested at all.
        log = GREEN_LOG.replace(
            "Passing Tests      1289", "Passing Tests         0\nRisky/Pending      1289"
        )
        ok, output = _judge(log)
        self.assertFalse(ok, output)
        self.assertIn("Risky/Pending 1289", output)

    def test_a_single_test_that_stopped_asserting_fails(self):
        # One risky test among 1289 is the realistic case, and the one a floor
        # on counts alone can never see.
        log = GREEN_LOG.replace(
            "Passing Tests      1289", "Passing Tests      1288\nRisky/Pending         1"
        )
        ok, output = _judge(log)
        self.assertFalse(ok, output)
        self.assertIn("1 of 1289", output)

    def test_failures_are_not_double_counted_as_unaccounted(self):
        # RED_LOG: 1289 tests, 1287 passing, 2 failing. The failures are already
        # reported; nothing is unaccounted for, so only one diagnosis prints.
        ok, output = _judge(RED_LOG)
        self.assertFalse(ok)
        self.assertNotIn("TESTS RAN WITHOUT PASSING", output)

    def test_a_missing_passing_line_is_absence_not_zero(self):
        # GUT prints `Passing Tests` unconditionally on every completed run, so
        # a log without one did not finish.
        log = GREEN_LOG.replace("Passing Tests      1289\n", "")
        ok, output = _judge(log)
        self.assertFalse(ok)
        self.assertIn("GUT SUMMARY MISSING", output)
        self.assertIn("Passing Tests", output)

    def test_risky_is_reported_in_the_result_line(self):
        ok, output = _judge(GREEN_LOG)
        self.assertTrue(ok, output)
        self.assertIn("risky=0", output)

    def test_unreadable_log_fails(self):
        out = io.StringIO()
        ok = gate.judge_log("/nonexistent/path/gut.log", _floors(), out)
        self.assertFalse(ok)
        self.assertIn("GUT LOG UNREADABLE", out.getvalue())

    def test_label_prefixes_every_line(self):
        out = io.StringIO()
        gate.judge_log("/tmp/x.log", _floors(), out, label="pod-wt-ia", log_text=GREEN_LOG)
        for line in out.getvalue().splitlines():
            self.assertTrue(line.startswith("[pod-wt-ia] "), line)


class TestCli(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def _run(self, argv):
        out, err = io.StringIO(), io.StringIO()
        real_out, real_err = sys.stdout, sys.stderr
        sys.stdout, sys.stderr = out, err
        try:
            code = gate.main(argv)
        finally:
            sys.stdout, sys.stderr = real_out, real_err
        return code, out.getvalue(), err.getvalue()

    def _baseline(self, text=GOOD_BASELINE):
        path = os.path.join(self.tmpdir, "gut-baseline.txt")
        with io.open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        return path

    def _log(self, text=GREEN_LOG):
        path = os.path.join(self.tmpdir, "gut.log")
        with io.open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        return path

    def test_bare_run_reports_the_floors(self):
        code, out, _ = self._run(["--baseline", self._baseline()])
        self.assertEqual(code, 0)
        self.assertIn("scripts=90", out)
        self.assertIn("(4 read)", out)

    def test_bare_run_fails_on_a_malformed_baseline(self):
        code, out, _ = self._run(["--baseline", self._baseline(GOOD_BASELINE.replace("gates=7", "gates=x"))])
        self.assertEqual(code, 1)
        self.assertIn("refusing to run rather than pass vacuously", out)

    def test_bare_run_fails_on_a_missing_baseline(self):
        code, out, _ = self._run(["--baseline", os.path.join(self.tmpdir, "gone.txt")])
        self.assertEqual(code, 1)
        self.assertIn("refusing to run rather than pass vacuously", out)

    def test_shell_mode_emits_assignments_on_stdout_only(self):
        code, out, err = self._run(["--shell", "--baseline", self._baseline()])
        self.assertEqual(code, 0)
        self.assertEqual(err, "")
        self.assertEqual(
            sorted(out.split()),
            sorted(["MIN_SCRIPTS=90", "MIN_TESTS=1289", "MIN_GATES=7", "MIN_GATE_TESTS=280"]),
        )

    def test_shell_mode_keeps_diagnostics_off_stdout(self):
        # stdout is eval'd by gates.sh; a diagnostic landing there would be
        # executed as shell.
        code, out, err = self._run(["--shell", "--baseline", os.path.join(self.tmpdir, "gone.txt")])
        self.assertEqual(code, 1)
        self.assertEqual(out, "")
        self.assertIn("refusing to run rather than pass vacuously", err)

    def test_log_mode_passes_on_a_green_log(self):
        code, out, _ = self._run(["--baseline", self._baseline(), "--log", self._log()])
        self.assertEqual(code, 0)
        self.assertIn("RESULT", out)

    def test_log_mode_exits_nonzero_on_a_dropped_script(self):
        log = self._log(GREEN_LOG.replace("Scripts              90", "Scripts              88"))
        code, out, _ = self._run(["--baseline", self._baseline(), "--log", log])
        self.assertEqual(code, 1)
        self.assertIn("SILENTLY SKIPPED", out)

    def test_log_mode_exits_nonzero_on_an_empty_log(self):
        code, out, _ = self._run(["--baseline", self._baseline(), "--log", self._log("")])
        self.assertEqual(code, 1)
        self.assertIn("GUT SUMMARY MISSING", out)

    def test_log_mode_fails_before_judging_when_the_baseline_is_broken(self):
        bad = self._baseline(GOOD_BASELINE.replace("scripts=90", "scripts=0"))
        code, out, _ = self._run(["--baseline", bad, "--log", self._log()])
        self.assertEqual(code, 1)
        self.assertIn("a zero floor guards nothing", out)
        self.assertNotIn("RESULT", out)


class TestGateRunLineMatcher(unittest.TestCase):
    """The wiring tests are only as good as this matcher, so it is tested too."""

    LIVE = 'python3 "$GATE_DIR/check_gut_baseline.py" --log "$TEMP_LOG"'

    def test_a_live_invocation_counts(self):
        self.assertEqual(gate_run_lines(self.LIVE), [self.LIVE])

    def test_a_commented_out_invocation_does_not_count(self):
        # The mutation that 46 green tests missed.
        self.assertEqual(gate_run_lines("    # " + self.LIVE), [])

    def test_a_prose_mention_does_not_count(self):
        registry = "#   L  GUT summary/failures/floor pre-push   check_gut_baseline.py"
        self.assertEqual(gate_run_lines(registry), [])

    def test_a_deleted_invocation_does_not_count(self):
        self.assertEqual(gate_run_lines('GATE_DIR="scripts/quality-gates"\n: # DISABLED\n'), [])

    def test_an_invocation_through_a_shell_variable_counts(self):
        # scripts/gates.sh calls the gate through $GUT_FLOOR_GATE, so a matcher
        # that only knows the literal filename would report it as unwired.
        text = (
            'GUT_FLOOR_GATE="scripts/quality-gates/check_gut_baseline.py"\n'
            'python3 "$GUT_FLOOR_GATE" --baseline "$B" --log "/tmp/gut.log" || exit 1\n'
        )
        self.assertEqual(len(gate_run_lines(text)), 1)

    def test_uncommented_drops_prose_but_keeps_code(self):
        text = "# echo SKIPPED\n    echo live\n  # trailing note\n"
        self.assertNotIn("SKIPPED", uncommented(text))
        self.assertIn("echo live", uncommented(text))

    def test_the_shape_check_alone_is_not_a_run(self):
        # `--shell` reads the floors; it judges no log, so it is not wiring.
        text = (
            'GUT_FLOOR_GATE="scripts/quality-gates/check_gut_baseline.py"\n'
            'FLOORS=$(python3 "$GUT_FLOOR_GATE" --baseline "$B" --shell)\n'
        )
        self.assertEqual(gate_run_lines(text), [])


class TestWiredIntoTheGates(unittest.TestCase):
    """A gate nothing calls is not a gate. These are the tests that notice."""

    def _read(self, relative):
        with io.open(os.path.join(REPO_ROOT, relative), encoding="utf-8") as handle:
            return handle.read()

    def test_real_baseline_file_parses(self):
        floors = gate.read_floors(os.path.join(REPO_ROOT, "scripts/quality-gates/gut-baseline.txt"))
        self.assertEqual(sorted(floors), sorted(gate.FLOOR_KEYS))

    def test_pre_push_runs_the_gate(self):
        hits = gate_run_lines(self._read(".husky/pre-push"))
        self.assertTrue(hits, "no uncommented Gate L invocation in .husky/pre-push")

    def test_gates_sh_runs_the_gate(self):
        hits = gate_run_lines(self._read("scripts/gates.sh"))
        self.assertTrue(hits, "no uncommented Gate L invocation in scripts/gates.sh")

    def test_ci_workflow_runs_the_gate(self):
        hits = gate_run_lines(self._read(".github/workflows/gut-tests.yml"))
        self.assertTrue(hits, "no uncommented Gate L invocation in the GUT workflow")

    def test_pre_push_registry_documents_letter_l(self):
        hook = self._read(".husky/pre-push")
        self.assertRegex(hook, r"#\s+L\s+.*check_gut_baseline\.py")

    def test_pre_push_checks_godot_exit_status(self):
        self.assertIn("PIPESTATUS", self._read(".husky/pre-push"))

    # --- Absence of Godot must not be reported as success -------------------

    def test_pre_push_refuses_to_pass_when_godot_is_absent(self):
        # Gate L used to sit inside `if [ -n "$GODOT_BIN" ]`, whose else branch
        # printed "GUT tests SKIPPED (Godot not found)" and fell through to the
        # success banner: no Gate H, no Gate L, exit 0. The guard against
        # silently-skipped tests must not itself be silently skipped.
        hook = uncommented(self._read(".husky/pre-push"))
        self.assertNotIn("SKIPPED (Godot not found)", hook)
        self.assertNotIn("GUT tests SKIPPED", hook)
        self.assertIn("Godot NOT FOUND", hook)
        self.assertIn("refusing to report success", hook)

    def test_pre_push_refuses_to_pass_when_gut_itself_is_missing(self):
        hook = self._read(".husky/pre-push")
        self.assertIn("gut_cmdln.gd is MISSING", hook)

    def test_the_hook_and_the_runner_agree_about_a_missing_godot(self):
        # One posture, two callers. gates.sh refused it first; see #430.
        for path in (".husky/pre-push", "scripts/gates.sh"):
            self.assertIn("refusing to", self._read(path), path)

    # --- One headless Godot per machine -------------------------------------

    def test_both_runners_share_one_godot_mutex(self):
        lock = self._read("scripts/quality-gates/godot-lock.sh")
        self.assertIn("/tmp/pod-godot.lock", lock)
        self.assertIn("godot_lock_acquire()", lock)
        for path in (".husky/pre-push", "scripts/gates.sh"):
            body = self._read(path)
            self.assertIn("godot-lock.sh", body, path)
            self.assertIn("godot_lock_acquire", body, path)

    def test_neither_runner_reimplements_the_mutex(self):
        # Two implementations of one lock is how the hook came to hold no lock
        # at all while gates.sh held one.
        for path in (".husky/pre-push", "scripts/gates.sh"):
            body = uncommented(self._read(path))
            self.assertNotIn('until mkdir "$LOCK"', body, path)
            self.assertNotIn("reap_stale_lock()", body, path)

    def test_the_pre_push_log_is_not_shared_between_worktrees(self):
        # A fixed /tmp/gut_prepush.log is truncated by a sibling push's `tee`
        # mid-read, and parse_counts takes the LAST summary in the file -- so
        # one worktree's Gate L could pass on another worktree's totals.
        hook = self._read(".husky/pre-push")
        self.assertNotIn("TEMP_LOG=/tmp/gut_prepush.log", hook)
        self.assertRegex(hook, r'TEMP_LOG="/tmp/gut_prepush_\$\(basename')

    # --- One implementation of the verdict, not five ------------------------

    def test_pre_push_no_longer_hardcodes_its_own_summary_parsing(self):
        # judge_log() already checks summary presence and the failing count, so
        # a bash copy in the hook and a YAML copy in CI made three. The comment
        # claiming one implementation was true of the floor alone.
        hook = uncommented(self._read(".husky/pre-push"))
        self.assertNotIn("GUT Run Summary MISSING", hook)
        self.assertNotIn('grep -qE "^Scripts[[:space:]]+[0-9]+"', hook)
        self.assertNotIn('grep -qE "^Failing Tests', hook)

    def test_ci_no_longer_hardcodes_its_own_summary_parsing(self):
        workflow = uncommented(self._read(".github/workflows/gut-tests.yml"))
        self.assertNotIn("GUT Run Summary MISSING", workflow)
        self.assertNotIn('grep -qE "^Scripts[[:space:]]+[0-9]+"', workflow)
        self.assertNotIn('grep -qE "^Failing Tests', workflow)
        # The bare "All tests passed" substring check is what all this replaced.
        self.assertNotIn('if grep -q "All tests passed" /tmp/gut.log', workflow)

    def test_gates_sh_no_longer_hardcodes_its_own_floor_parsing(self):
        # Two implementations of one floor is how the wordings drift apart, and
        # the SILENTLY SKIPPED diagnosis is the one that must not.
        gates_sh = uncommented(self._read("scripts/gates.sh"))
        self.assertNotIn("SILENTLY SKIPPED", gates_sh)
        self.assertNotIn("SCRIPT COUNT REGRESSION", gates_sh)
        self.assertNotIn("read_floor()", gates_sh)

    def test_ci_still_checks_godots_own_exit_status(self):
        # Delegating the LOG verdict must not delete the PROCESS verdict: a run
        # that printed a clean summary and then died is not a clean run.
        workflow = self._read(".github/workflows/gut-tests.yml")
        self.assertIn("set -o pipefail", workflow)
        self.assertIn("Godot exited non-zero", workflow)

    # --- The runner must exercise the gate its own branch changes -----------

    def test_gates_sh_runs_godot_when_gate_l_inputs_change(self):
        # Neither the floors nor the judge live under game/, so the Godot skip
        # heuristic used to skip them -- and the branch that wired Gate L could
        # not demonstrate Gate L through its own runner.
        gates_sh = self._read("scripts/gates.sh")
        self.assertIn("GATE_L_INPUTS", gates_sh)
        self.assertIn('$BASELINE_FILE', gates_sh)
        self.assertIn('$GUT_FLOOR_GATE', gates_sh)
        # Defined is not consulted: the skip condition has to read it.
        self.assertIn('[ -z "$GATE_TRIGGER" ]', gates_sh)


class TestGodotLockMutex(unittest.TestCase):
    """Behavioural coverage for scripts/quality-gates/godot-lock.sh.

    These drive the real shell functions in real separate processes. A mutex is
    exactly the kind of thing a string assertion cannot check: the previous
    version of this file proved both runners SOURCED the lock, while the lock
    itself would hand the same mutex to two of them.
    """

    LOCK_SH = os.path.join(REPO_ROOT, "scripts", "quality-gates", "godot-lock.sh")

    def setUp(self):
        self.dir = tempfile.mkdtemp(prefix="godotlock")
        self.lock = os.path.join(self.dir, "pod-godot.lock")

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

    def _run(self, script, timeout="3", grace="30"):
        """Run `script` in a bash that has sourced the lock, return CompletedProcess."""
        env = dict(os.environ)
        env.update(
            GODOT_LOCK=self.lock,
            GODOT_LOCK_POLL="1",
            GODOT_LOCK_TIMEOUT=timeout,
            GODOT_LOCK_CLAIM_GRACE=grace,
        )
        return subprocess.run(
            ["bash", "-c", '. "$1"; shift; ' + script, "_", self.LOCK_SH],
            capture_output=True, text=True, env=env, timeout=120,
        )

    def _owner(self):
        try:
            with open(os.path.join(self.lock, "owner.pid")) as fh:
                return fh.read().strip()
        except OSError:
            return ""

    def test_an_acquirer_names_itself_and_release_removes_the_lock(self):
        got = self._run('godot_lock_acquire && echo "OWNER=$(cat $GODOT_LOCK/owner.pid) ME=$$"; '
                        'godot_lock_release; [ -d "$GODOT_LOCK" ] && echo LEAKED || echo RELEASED')
        self.assertEqual(got.returncode, 0, got.stderr)
        owner, me = re.search(r"OWNER=(\d+) ME=(\d+)", got.stdout).groups()
        self.assertEqual(owner, me, "the lock must name the process that took it")
        self.assertIn("RELEASED", got.stdout)

    def test_a_lock_taken_but_not_yet_claimed_is_not_stolen(self):
        # THE RACE. `mkdir` and the owner.pid write are two statements. The
        # reaper used to read owner.pid in the gap, find nothing, call a live
        # lock stale, rm -rf it and take it -- so two runners both believed
        # they held one mutex and two headless Godots started. A directory with
        # no owner named yet is mid-acquisition, not abandoned.
        os.mkdir(self.lock)
        got = self._run("godot_lock_acquire && echo STOLE")
        self.assertNotEqual(got.returncode, 0, "acquired a lock another runner was taking")
        self.assertNotIn("STOLE", got.stdout)
        self.assertIn("GODOT LOCK TIMEOUT", got.stdout)

    def test_a_second_claim_cannot_overwrite_an_owner_already_named(self):
        # The `set -C` half of the same defence: even if a runner does end up
        # inside a directory someone else claimed, it must not be able to
        # rewrite the owner and make release delete the wrong lock.
        os.mkdir(self.lock)
        with open(os.path.join(self.lock, "owner.pid"), "w") as fh:
            fh.write("424242\n")
        got = self._run("godot_lock_claim && echo CLAIMED || echo REFUSED")
        self.assertIn("REFUSED", got.stdout)
        self.assertEqual(self._owner(), "424242")

    def test_a_live_owner_blocks_every_other_runner(self):
        os.mkdir(self.lock)
        with open(os.path.join(self.lock, "owner.pid"), "w") as fh:
            fh.write("%d\n" % os.getpid())  # this test process is alive
        got = self._run("godot_lock_acquire && echo STOLE")
        self.assertNotEqual(got.returncode, 0)
        self.assertNotIn("STOLE", got.stdout)

    def test_a_dead_owners_lock_is_reclaimed(self):
        # Without this a killed agent wedges every sibling worktree for the
        # full 1800s timeout, which is why owner.pid exists at all.
        dead = subprocess.Popen(["true"])
        dead.wait()
        os.mkdir(self.lock)
        with open(os.path.join(self.lock, "owner.pid"), "w") as fh:
            fh.write("%d\n" % dead.pid)
        got = self._run("godot_lock_acquire && echo ACQUIRED")
        self.assertIn("ACQUIRED", got.stdout, got.stdout + got.stderr)
        self.assertIn("reaping stale lock", got.stdout)

    def test_a_lock_abandoned_before_it_was_claimed_is_reclaimed_after_the_grace(self):
        # The cost of refusing to reap an unclaimed lock: an acquirer killed
        # between the two statements leaves one behind. Bounded by the grace
        # window rather than the full timeout, and never permanent.
        os.mkdir(self.lock)
        old = time.time() - 3600
        os.utime(self.lock, (old, old))
        got = self._run("godot_lock_acquire && echo ACQUIRED")
        self.assertIn("ACQUIRED", got.stdout, got.stdout + got.stderr)
        self.assertIn("reaping unclaimed lock", got.stdout)

    def test_release_leaves_a_lock_owned_by_someone_else_alone(self):
        os.mkdir(self.lock)
        with open(os.path.join(self.lock, "owner.pid"), "w") as fh:
            fh.write("424242\n")
        got = self._run('godot_lock_release; [ -d "$GODOT_LOCK" ] && echo KEPT || echo DELETED')
        self.assertIn("KEPT", got.stdout)

    def test_the_lock_stays_a_directory_at_the_shared_path(self):
        # Worktrees on older commits take /tmp/pod-godot.lock with `mkdir` from
        # their own copy of gates.sh. A symlink or an flock'd regular file
        # would be atomic in isolation and would stop serialising against them.
        with open(self.LOCK_SH) as fh:
            lock = fh.read()
        self.assertIn('GODOT_LOCK="${GODOT_LOCK:-/tmp/pod-godot.lock}"', lock)
        self.assertIn('mkdir "$GODOT_LOCK"', uncommented(lock))

    def test_the_docs_do_not_claim_a_guarantee_the_lock_does_not_give(self):
        # The mutex is best-effort at one boundary (a holder frozen mid-
        # acquisition for longer than the grace window). Prose that says two
        # Godots CANNOT start overclaims; § 5 of quality-gate-authoring
        # requires the limit in the same breath as the guarantee.
        for path in ("scripts/gates.sh", ".claude/skills/create-pr/SKILL.md"):
            flat = re.sub(r"\s+", " ", self._read_repo(path))
            if "cannot start two Godots" in flat:
                self.fail(
                    "%s claims two Godots CANNOT start. godot-lock.sh is a mkdir "
                    "lock, not a kernel lock: state the limit in the same breath."
                    % path
                )

    def _read_repo(self, relative):
        with open(os.path.join(REPO_ROOT, relative)) as fh:
            return fh.read()


if __name__ == "__main__":
    unittest.main()
