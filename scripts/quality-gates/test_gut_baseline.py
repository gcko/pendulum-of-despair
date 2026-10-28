#!/usr/bin/env python3
"""Quality Gate I coverage for Gate L (`check_gut_baseline.py`).

Two kinds of test live here and they fail differently, so both are needed:

  * fixture tests, which prove the parsing and the verdicts are right; and
  * WIRING tests, which prove the hook, CI and `scripts/gates.sh` actually call
    the thing. Since #437, TestQualityGatesWorkflow also EXECUTES the step
    bodies of `.github/workflows/quality-gates.yml` against fixture trees and
    requires the job to fail when a gate, a self-test or a floor does.
    `test_quality_gates.py` once had 36 green tests that no hook ran, which is
    the exact shape of bug a fixture-only suite cannot see.

The wiring tests match an UNCOMMENTED invocation, not the string
`check_gut_baseline.py`. They were substring assertions once, and the name also
appears in prose in all three callers -- the pre-push gate registry, the
gates.sh header, the CI step's rationale -- so both call sites could be
commented out with all 46 tests still green (#430). `gate_run_lines()` below is
the matcher, and it is itself tested against a commented-out call.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
"""
import atexit
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

# What the scripts under test read from the environment, and so what a fixture
# must never inherit from whoever runs this suite. Each prefix is a family:
#   GIT_*    git exports GIT_DIR and friends to a hook; left in place they point
#            a scratch repo's git at the real repository.
#   GATES_*  scripts/gates.sh's knobs. GATES_FORCE_GODOT=1 is the documented
#            "prove main green" recipe, and inherited it sent every fixture
#            gates.sh run, which holds no game/, into the Godot stage (#482).
#   GODOT_*  GODOT_BIN picks the binary, GODOT_LOCK* place and time the mutex.
# plus HUSKY (gates.sh refuses HUSKY=0) and MIN_GATES and MIN_GATE_TESTS.
# quality-gates.yml writes those two floors to $GITHUB_ENV, so CI's real Gate I
# step runs this suite with them set; gates.sh only evals them into its own
# shell and never exports them.
_SCRUBBED_PREFIXES = ("GIT_", "GATES_", "GODOT_")
_SCRUBBED_NAMES = ("HUSKY", "MIN_GATES", "MIN_GATE_TESTS")


def _scrubbed_env(path=None, **overrides):
    """os.environ minus the knobs listed above, then `overrides`.

    Every subprocess here that runs a repo script -- gates.sh, a husky hook, a
    workflow step body, godot-lock.sh, or the git that builds their fixture --
    takes its environment from this, so a test sets exactly the knobs it is
    about and inherits none. `path`, if given, replaces PATH. A new kind of
    fixture must also join TestFixturesIgnoreTheCallersEnvironment.REPRESENTATIVE.
    """
    env = {k: v for k, v in os.environ.items()
           if not k.startswith(_SCRUBBED_PREFIXES) and k not in _SCRUBBED_NAMES}
    if path is not None:
        env["PATH"] = path
    env.update(overrides)
    return env


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
# 9.7.1 prints that one only when something failed, which is why its absence
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


# --- Executing quality-gates.yml (#437) -------------------------------------
#
# The CI job that runs Gate I and every check_*.py cannot run here, but its
# step bodies can. These helpers pull each step's `run:` body out of the
# workflow and execute them in order the way the runner does, against a
# fixture tree, so the tests below judge what the job DOES when a gate fails
# rather than how its YAML is spelled. A text match would accept a step that
# had stopped failing: dropping `set -o pipefail`, `|| true` after `tee`, a
# deleted `exit 1` and `continue-on-error: true` all kept six text tests green.

QUALITY_GATES_YML = os.path.join(REPO_ROOT, ".github", "workflows", "quality-gates.yml")

# Keys a step may carry. Anything else raises rather than being ignored, so
# the emulation cannot quietly drift from what the workflow asks the runner for.
_STEP_KEYS = {"name", "uses", "with", "run", "if", "continue-on-error", "shell", "timeout-minutes"}
# `if:` conditions the emulation understands; any other raises.
_ALWAYS_CONDITIONS = {"!cancelled()", "always()"}


def step_condition(step):
    """A step's `if:` as the runner reads it: YAML quotes and `${{ }}` removed.

    `if: ${{ !cancelled() }}` and `if: "!cancelled()"` are one condition, so the
    emulation and the tests that ask "does this step run after a failure?" must
    read them identically.
    """
    raw = step.get("if", "").strip()
    if len(raw) >= 2 and raw[0] == raw[-1] and raw[0] in "'\"":
        raw = raw[1:-1].strip()
    wrapped = re.match(r"^\$\{\{\s*(.*?)\s*\}\}$", raw)
    return wrapped.group(1) if wrapped else raw


def runs_after_a_failure(step):
    """True if the runner would still run `step` once an earlier step failed."""
    condition = step_condition(step)
    if condition and condition not in _ALWAYS_CONDITIONS:
        raise ValueError("unsupported if: %r" % step["if"])
    return bool(condition)


def workflow_steps(text):
    """Return the steps of the only job in `text`, as dicts of their keys.

    Stdlib only, for the one shape these workflows use: a block sequence of
    `- key: value` mappings under `steps:`, with `run: |` literal blocks. A
    nested mapping (`with:`) is skipped; a literal block is dedented.
    """
    lines = text.splitlines()
    starts = [i for i, line in enumerate(lines) if re.match(r"^\s*steps:\s*$", line)]
    if len(starts) != 1:
        raise ValueError("expected exactly one `steps:` block, found %d" % len(starts))
    steps_indent = len(lines[starts[0]]) - len(lines[starts[0]].lstrip())
    steps, step, key_indent = [], None, None
    i = starts[0] + 1
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        if not stripped or stripped.startswith("#"):
            i += 1
            continue
        if indent <= steps_indent:
            break
        item = re.match(r"^(\s*)- (.*)$", line)
        if item and (key_indent is None or len(item.group(1)) < key_indent):
            step = {}
            steps.append(step)
            key_indent = len(item.group(1)) + 2
            line = " " * key_indent + item.group(2)
            indent = key_indent
        if step is None or indent != key_indent:
            raise ValueError("unexpected line %d in steps: %r" % (i + 1, line))
        pair = re.match(r"^\s*([A-Za-z-]+):\s*(.*)$", line)
        if not pair or pair.group(1) not in _STEP_KEYS:
            raise ValueError("unsupported step line %d: %r" % (i + 1, line))
        key, value = pair.group(1), pair.group(2).strip()
        i += 1
        if value in ("|", "") or value.startswith("|"):
            block = []
            while i < len(lines) and (
                not lines[i].strip() or len(lines[i]) - len(lines[i].lstrip()) > key_indent
            ):
                block.append(lines[i])
                i += 1
            if value.startswith("|"):
                body = [b for b in block if b.strip()]
                cut = min(len(b) - len(b.lstrip()) for b in body) if body else 0
                value = "\n".join(b[cut:] for b in block).strip("\n") + "\n"
        step[key] = value
    return steps


def run_workflow_steps(steps, cwd, env_extra=None, expressions=None):
    """Execute `steps` like the runner: returns (job_failed, [(step, outcome)]).

    A step with no `if:` runs only while the job is still green; `!cancelled()`
    and `always()` run regardless. The default shell is `bash -e {0}`, and
    `shell: bash` adds pipefail, as on the runner. A failing step fails the job
    unless it sets `continue-on-error: true`. $GITHUB_ENV assignments carry to
    later steps. Outcome is "success", "failure" or "skipped".

    `${{ expr }}` inside a `run:` body is replaced from `expressions`, as the
    runner substitutes it before bash sees the script; an expression with no
    entry raises rather than reaching bash as a "bad substitution". The
    environment is `_scrubbed_env()`, as a runner has none of the caller's
    GIT_*, GATES_* or GODOT_* variables: inherited from a git hook, GIT_* alone
    would point a fixture's `git` at the real repository. MIN_GATES and
    MIN_GATE_TESTS go too, because this workflow's own first step writes them
    to $GITHUB_ENV: CI's Gate I step therefore runs this suite with both set,
    and a fixture step that inherited them would find a floor it was never
    handed and pass where it must fail.
    """
    scratch = tempfile.mkdtemp(prefix="pod-wf-")
    env_file = os.path.join(scratch, "github_env")
    io.open(env_file, "w").close()
    overrides = dict(GITHUB_ENV=env_file, RUNNER_TEMP=scratch, CI="true")
    overrides.update(env_extra or {})
    env = _scrubbed_env(**overrides)

    def substitute(match):
        if match.group(1) not in (expressions or {}):
            raise ValueError("unsupported expression in run: %r" % match.group(0))
        return expressions[match.group(1)]

    job_failed, results, output = False, [], []
    try:
        for step in steps:
            always = runs_after_a_failure(step)
            if "run" not in step or (job_failed and not always):
                results.append((step, "skipped"))
                continue
            shell = step.get("shell", "")
            if shell not in ("", "bash"):
                raise ValueError("unsupported shell: %r" % shell)
            argv = ["bash", "-e"] if not shell else ["bash", "--noprofile", "--norc", "-eo", "pipefail"]
            with io.open(env_file, encoding="utf-8") as handle:
                for assignment in handle.read().splitlines():
                    if "=" in assignment:
                        name, _, value = assignment.partition("=")
                        env[name] = value
            script = os.path.join(scratch, "step.sh")
            with io.open(script, "w", encoding="utf-8") as handle:
                handle.write(re.sub(r"\$\{\{\s*(.*?)\s*\}\}", substitute, step["run"]))
            proc = subprocess.run(
                argv + [script], cwd=cwd, env=env, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, universal_newlines=True, timeout=120,
            )
            output.append(proc.stdout)
            outcome = "success" if proc.returncode == 0 else "failure"
            results.append((step, outcome))
            if outcome == "failure" and step.get("continue-on-error", "false") != "true":
                job_failed = True
    finally:
        shutil.rmtree(scratch, ignore_errors=True)
    return job_failed, results, "".join(output)


_FIXTURE_CHECK = 'print("FIXTURE GATE %s ran")\nraise SystemExit(%d)\n'
_FIXTURE_TEST = "    def test_%d(self):\n        self.assertTrue(%s)\n"


class TestQualityGatesWorkflow(unittest.TestCase):
    """quality-gates.yml must FAIL when a gate fails, and only then (#437).

    Each test builds a fixture repo -- the real check_gut_baseline.py, a
    baseline with gates=3 and gate_tests=3, two fixture check_*.py and a
    fixture self-test file -- runs the workflow's real step bodies against it,
    and judges the job's verdict.
    """

    def setUp(self):
        with io.open(QUALITY_GATES_YML, encoding="utf-8") as handle:
            self.text = handle.read()
        self.steps = workflow_steps(self.text)
        self.root = tempfile.mkdtemp(prefix="pod-qg-fixture-")
        self.addCleanup(shutil.rmtree, self.root, True)
        self.gate_dir = os.path.join(self.root, "scripts", "quality-gates")
        os.makedirs(self.gate_dir)
        shutil.copy(os.path.join(REPO_ROOT, "scripts", "quality-gates", GATE_SCRIPT), self.gate_dir)
        self._write("gut-baseline.txt", "scripts=1\ntests=1\ngates=3\ngate_tests=3\n")

    def _write(self, name, body):
        with io.open(os.path.join(self.gate_dir, name), "w", encoding="utf-8") as handle:
            handle.write(body)

    def _fixture(self, checks=("a", "b"), failing_check=None, tests=3, failing_test=None):
        for name in checks:
            self._write("check_%s.py" % name, _FIXTURE_CHECK % (name, 1 if name == failing_check else 0))
        body = "import unittest\n\n\nclass TestFixture(unittest.TestCase):\n"
        for n in range(tests):
            body += _FIXTURE_TEST % (n, "False" if n == failing_test else "True")
        self._write("test_fixture.py", body)

    def _run(self):
        return run_workflow_steps(self.steps, self.root)

    def test_a_clean_tree_passes_having_run_every_gate_and_self_test(self):
        self._fixture()
        failed, results, out = self._run()
        self.assertFalse(failed, out)
        # Green is only worth something if the work happened: every fixture
        # gate printed, and the self-tests ran in full.
        self.assertIn("FIXTURE GATE a ran", out)
        self.assertIn("FIXTURE GATE b ran", out)
        self.assertRegex(out, r"(?m)^Ran 3 tests\b")
        self.assertEqual({outcome for _, outcome in results}, {"skipped", "success"})
        self.assertEqual([step.get("uses") for step, o in results if o == "skipped"],
                         [s.get("uses") for s in self.steps if "run" not in s])

    def test_a_failing_gate_fails_the_job(self):
        self._fixture(failing_check="a")
        failed, _, out = self._run()
        self.assertTrue(failed, out)
        # ...and the gates after it still ran, so a PR sees every failure.
        self.assertIn("FIXTURE GATE b ran", out)

    def test_a_failing_self_test_fails_the_job_and_the_gates_still_run(self):
        self._fixture(failing_test=1)
        failed, _, out = self._run()
        self.assertTrue(failed, out)
        self.assertIn("FIXTURE GATE a ran", out)

    def test_too_few_self_tests_fails_the_job(self):
        # Two passing tests against a floor of three: a lost test file, not a
        # failing one, so only the count can catch it.
        self._fixture(tests=2)
        failed, _, out = self._run()
        self.assertTrue(failed, out)
        self.assertRegex(out, r"(?m)^Ran 2 tests\b")

    def test_a_self_test_run_that_prints_no_count_fails_the_job(self):
        # A run that exits 0 without printing "Ran N tests" proves nothing ran.
        # os._exit in a test module ends the discovery that way.
        self._fixture()
        self._write("test_fixture.py", "import os\nos._exit(0)\n")
        failed, _, out = self._run()
        self.assertTrue(failed, out)
        self.assertNotRegex(out, r"(?m)^Ran \d+ test")

    def test_a_glob_with_no_gate_scripts_fails_the_job(self):
        # Only the floor reader is left for the glob to match: 1 < 3.
        self._fixture(checks=())
        failed, _, out = self._run()
        self.assertTrue(failed, out)

    def test_an_unreadable_floor_fails_every_step_that_runs_after_it(self):
        self._fixture()
        self._write("gut-baseline.txt", "scripts=1\ntests=1\ngates=abc\ngate_tests=3\n")
        failed, results, out = self._run()
        self.assertTrue(failed, out)
        ran = [outcome for _, outcome in results if outcome != "skipped"]
        self.assertTrue(ran, "no step ran at all")
        # A step that runs after the floor read failed must not pass on an
        # unset floor: `[ 3 -lt "" ]` is an error that reads as false.
        self.assertEqual(set(ran), {"failure"}, out)

    def test_a_step_that_never_received_its_floor_fails_on_a_clean_tree(self):
        # Every step that judges a count reads its floor from $GITHUB_ENV.
        # Run alone, with no floor, each must fail rather than compare against
        # an empty string and pass.
        self._fixture()
        judged = [s for s in self.steps if "run" in s and "$GITHUB_ENV" not in s["run"]]
        self.assertGreaterEqual(len(judged), 2, "expected Gate I and the gate loop")
        for step in judged:
            with self.subTest(step=step.get("name")):
                failed, _, out = run_workflow_steps([step], self.root)
                self.assertTrue(failed, out)

    def test_no_step_or_job_is_allowed_to_fail_quietly(self):
        # continue-on-error on a STEP is executed above; on the JOB it is not,
        # so it is checked here as text.
        self.assertNotIn("continue-on-error", uncommented(self.text))

    def test_it_runs_on_every_pull_request_base(self):
        # A `branches:` filter left stacked PRs with no CI until retargeted.
        on_block = re.search(r"(?ms)^on:\n(.*?)^\S", uncommented(self.text))
        self.assertIsNotNone(on_block, "no `on:` block")
        self.assertIn("pull_request:", on_block.group(1))
        self.assertNotRegex(on_block.group(1), r"\b(branches|branches-ignore|paths|paths-ignore):")


class TestWorkflowStepRunner(unittest.TestCase):
    """The emulation is what TestQualityGatesWorkflow trusts, so it is tested."""

    def _steps(self, body):
        return workflow_steps("jobs:\n  j:\n    steps:\n" + body)

    def test_a_failing_step_fails_the_job_and_skips_the_next(self):
        steps = self._steps(
            "      - name: one\n        run: |\n          exit 1\n"
            "      - name: two\n        run: |\n          echo TWO\n"
        )
        failed, results, out = run_workflow_steps(steps, tempfile.gettempdir())
        self.assertTrue(failed)
        self.assertEqual([o for _, o in results], ["failure", "skipped"])
        self.assertNotIn("TWO", out)

    def test_not_cancelled_runs_after_a_failure_and_continue_on_error_does_not_fail(self):
        steps = self._steps(
            "      - name: one\n        continue-on-error: true\n        run: |\n          exit 1\n"
            "      - name: two\n        run: |\n          exit 1\n"
            "      - name: three\n        if: ${{ !cancelled() }}\n        run: |\n          echo THREE\n"
        )
        failed, results, out = run_workflow_steps(steps, tempfile.gettempdir())
        self.assertTrue(failed)
        self.assertEqual([o for _, o in results], ["failure", "failure", "success"])
        self.assertIn("THREE", out)

    def test_an_unknown_step_key_raises_rather_than_being_ignored(self):
        with self.assertRaises(ValueError):
            self._steps("      - name: one\n        working-directory: x\n        run: |\n          true\n")

    def test_a_quoted_condition_is_the_same_condition(self):
        # `if: "!cancelled()"` is what the runner reads as `${{ !cancelled() }}`.
        steps = self._steps(
            "      - name: one\n        run: |\n          exit 1\n"
            "      - name: two\n        if: \"!cancelled()\"\n        run: |\n          echo TWO\n"
        )
        failed, results, out = run_workflow_steps(steps, tempfile.gettempdir())
        self.assertTrue(failed)
        self.assertEqual([o for _, o in results], ["failure", "success"])
        self.assertIn("TWO", out)

    def test_expressions_are_substituted_and_an_unknown_one_raises(self):
        steps = self._steps("      - name: one\n        run: |\n          echo \"sha=${{ a.b }}\"\n")
        failed, _, out = run_workflow_steps(steps, tempfile.gettempdir(), expressions={"a.b": "f00"})
        self.assertFalse(failed, out)
        self.assertIn("sha=f00", out)
        with self.assertRaises(ValueError):
            run_workflow_steps(steps, tempfile.gettempdir(), expressions={})


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
        env = _scrubbed_env(
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


# --- gdtoolkit: the pin, the pre-commit hook and static-gates.yml (#472) ----
#
# Gates A and C used to sit inside `if command -v gdlint` / `gdformat` with no
# else, so a machine without gdtoolkit committed GDScript that nothing checked
# and the hook exited 0. No workflow ran Gates A-C or commitlint either, so a
# commit made with hooks uninstalled reached a PR unchecked.
#
# Everything below is judged by what it DOES. The hook tests run the real
# .husky/pre-commit the way husky runs it, `sh -e <hook>`, in a scratch repo
# with gdtoolkit removed from PATH. The workflow tests run every `run:` body of
# static-gates.yml, in order, against a fixture repo with fake pip, gdlint,
# gdformat and pnpm on PATH. The fakes are content-driven: a file holding
# LINT_ERROR fails gdlint, one holding BADFORMAT fails `gdformat --check`, and
# both refuse a path that does not exist, so an argument split wrongly fails
# instead of linting nothing. Only what the runner provides (checkout depth,
# the setup actions, the trigger, permissions) is checked as text.

GDTOOLKIT_PIN = os.path.join(REPO_ROOT, "scripts", "quality-gates", "gdtoolkit-version.txt")
GDTOOLKIT_HELPER = os.path.join(REPO_ROOT, "scripts", "quality-gates", "gdtoolkit-require.sh")
PRE_COMMIT = os.path.join(REPO_ROOT, ".husky", "pre-commit")
STATIC_GATES_YML = os.path.join(REPO_ROOT, ".github", "workflows", "static-gates.yml")
GDTOOLKIT_TOOLS = ("gdlint", "gdformat")

# PEP 440 public version: release segment, optional pre, post and dev parts.
_PEP440 = re.compile(r"^\d+(\.\d+)*((a|b|rc)\d+)?(\.post\d+)?(\.dev\d+)?$")

_FAKES = {
    "gdlint": r'''#!/bin/sh
if [ "${1-}" = "--version" ]; then echo "gdlint $(cat "$FAKE_BIN/.gdtoolkit")"; exit 0; fi
echo "gdlint $*" >> "$FAKE_TOOL_LOG"
for f in "$@"; do
  [ -f "$f" ] || { echo "fake gdlint: no such file: $f"; exit 2; }
  if grep -q LINT_ERROR "$f"; then echo "$f:1: Error: fake lint error"; exit 1; fi
done
exit 0
''',
    "gdformat": r'''#!/bin/sh
if [ "${1-}" = "--version" ]; then echo "gdformat $(cat "$FAKE_BIN/.gdtoolkit")"; exit 0; fi
echo "gdformat $*" >> "$FAKE_TOOL_LOG"
check=0
bad=0
for f in "$@"; do
  if [ "$f" = "--check" ]; then check=1; continue; fi
  [ -f "$f" ] || { echo "fake gdformat: no such file: $f"; exit 2; }
  if grep -q BADFORMAT "$f"; then
    if [ "$check" = 1 ]; then echo "would reformat $f"; bad=1; fi
  fi
done
[ "$bad" = 0 ]
''',
    # Installs the fakes above, reporting FAKE_PIP_RESOLVES as their version
    # when set, so a resolver that hands back the wrong release can be staged.
    "pip": r'''#!/bin/sh
echo "pip $*" >> "$FAKE_TOOL_LOG"
[ "$#" -eq 2 ] && [ "$1" = "install" ] || { echo "fake pip: unexpected: $*"; exit 2; }
case "$2" in gdtoolkit==?*) ;; *) echo "fake pip: not a pinned gdtoolkit: $2"; exit 2;; esac
echo "${FAKE_PIP_RESOLVES:-${2#gdtoolkit==}}" > "$FAKE_BIN/.gdtoolkit"
cp "$FAKE_TEMPLATES/gdlint" "$FAKE_TEMPLATES/gdformat" "$FAKE_BIN/"
''',
    "pnpm": '#!/bin/sh\necho "pnpm $*" >> "$FAKE_TOOL_LOG"\n',
}


def live_lines(text, pattern):
    """The uncommented lines of `text` matching `pattern`, stripped.

    A setting that is commented out still appears in its own rationale, so
    presence is a live line, never a substring (#430).
    """
    rx = re.compile(pattern)
    return [line.strip() for line in uncommented(text).splitlines() if rx.search(line.strip())]


_STRIPPED_PATH = {}


def _path_without_gdtoolkit():
    """PATH with gdlint and gdformat removed, keeping everything else reachable.

    A directory holding either tool is replaced by a shadow directory of
    symlinks to everything else in it, so dropping gdlint does not also drop the
    python3 or git beside it (a pyenv shims directory holds both). Built once.
    """
    if "path" in _STRIPPED_PATH:
        return _STRIPPED_PATH["path"]
    shadow_root = tempfile.mkdtemp(prefix="pod-nogdtk-")
    atexit.register(shutil.rmtree, shadow_root, True)
    out = []
    for index, directory in enumerate(os.environ.get("PATH", "").split(os.pathsep)):
        if not directory or not os.path.isdir(directory):
            continue
        if not any(os.path.exists(os.path.join(directory, t)) for t in GDTOOLKIT_TOOLS):
            out.append(directory)
            continue
        shadow = os.path.join(shadow_root, "path%d" % index)
        os.makedirs(shadow)
        for name in os.listdir(directory):
            source = os.path.join(directory, name)
            if name in GDTOOLKIT_TOOLS or not os.path.isfile(source) or not os.access(source, os.X_OK):
                continue
            os.symlink(source, os.path.join(shadow, name))
        out.append(shadow)
    path = os.pathsep.join(out)
    for tool in GDTOOLKIT_TOOLS:
        if shutil.which(tool, path=path):
            raise AssertionError("could not strip %s from PATH" % tool)
    for tool in ("sh", "bash", "git", "python3", "xargs", "tr"):
        if not shutil.which(tool, path=path):
            raise AssertionError("stripping gdtoolkit also removed %s" % tool)
    _STRIPPED_PATH["path"] = path
    return path


def _write_executable(path, body):
    with io.open(path, "w", encoding="utf-8") as handle:
        handle.write(body)
    os.chmod(path, 0o755)


def _scratch_repo(test, prefix):
    """A git repo on branch feature/x with one empty commit; returns its path."""
    repo = tempfile.mkdtemp(prefix=prefix)
    test.addCleanup(shutil.rmtree, repo, True)
    env = _scrubbed_env(_path_without_gdtoolkit())
    for args in (
        ["init", "-q"],
        ["-c", "core.hooksPath=/dev/null", "-c", "commit.gpgsign=false", "-c", "user.name=t",
         "-c", "user.email=t@example.invalid", "commit", "-q", "--allow-empty", "-m", "init"],
        # The hook refuses commits to main, which is not what is under test.
        ["checkout", "-q", "-b", "feature/x"],
    ):
        subprocess.run(["git"] + args, cwd=repo, env=env, check=True,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return repo


def _stage(repo, relative, body="extends Node\n"):
    target = os.path.join(repo, relative)
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with io.open(target, "w", encoding="utf-8") as handle:
        handle.write(body)
    subprocess.run(["git", "add", "--", relative], cwd=repo, check=True,
                   env=_scrubbed_env(_path_without_gdtoolkit()))


def _hook_shells():
    """The shells husky would run the hook with: `sh`, plus dash when it is a
    different binary (macOS's sh is bash; Debian's is dash). Each verdict is
    asserted under every one, so a bashism fails on the developer's machine
    rather than only on a Linux one."""
    path = _path_without_gdtoolkit()
    shells = [shutil.which("sh", path=path)]
    dash = shutil.which("dash", path=path)
    if dash and os.path.realpath(dash) != os.path.realpath(shells[0]):
        shells.append(dash)
    return shells


class TestPreCommitRequiresGdtoolkit(unittest.TestCase):
    """.husky/pre-commit, run as husky runs it, in a scratch repo with no gdtoolkit."""

    def setUp(self):
        self.repo = _scratch_repo(self, "pod-precommit-")
        for source, relative in (
            (PRE_COMMIT, ".husky/pre-commit"),
            (GDTOOLKIT_HELPER, "scripts/quality-gates/gdtoolkit-require.sh"),
            (GDTOOLKIT_PIN, "scripts/quality-gates/gdtoolkit-version.txt"),
        ):
            target = os.path.join(self.repo, relative)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy(source, target)
        self.fake_bin = os.path.join(self.repo, ".fake-bin")
        os.makedirs(self.fake_bin)
        self.fake_log = os.path.join(self.repo, ".fake-tool.log")

    def _pin(self, body):
        with io.open(os.path.join(self.repo, "scripts/quality-gates/gdtoolkit-version.txt"),
                     "w", encoding="utf-8") as handle:
            handle.write(body)

    def _fake(self, *tools, **versions):
        """Install fake tools. Each answers `--version` from $FAKE_BIN/.gdtoolkit,
        written here as the scratch repo's pin unless `version=` says otherwise;
        `<tool>=<version>` gives one tool its own answer."""
        version = versions.pop("version", None)
        if version is None:
            with io.open(os.path.join(self.repo, "scripts/quality-gates/gdtoolkit-version.txt"),
                         encoding="utf-8") as handle:
                version = "".join(handle.read().split())
        with io.open(os.path.join(self.fake_bin, ".gdtoolkit"), "w", encoding="utf-8") as handle:
            handle.write(version + "\n")
        for tool in tools:
            body = _FAKES[tool]
            if tool in versions:
                body = body.replace('$(cat "$FAKE_BIN/.gdtoolkit")', versions[tool])
            _write_executable(os.path.join(self.fake_bin, tool), body)

    def _hook(self):
        """Run the hook under every husky shell; returns [(shell, code, output)]."""
        env = _scrubbed_env(self.fake_bin + os.pathsep + _path_without_gdtoolkit(),
                            FAKE_TOOL_LOG=self.fake_log, FAKE_BIN=self.fake_bin)
        runs = []
        for shell in _hook_shells():
            proc = subprocess.run(
                [shell, "-e", ".husky/pre-commit"], cwd=self.repo, env=env, timeout=60,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True,
            )
            runs.append((shell, proc.returncode, proc.stdout))
        return runs

    def _ran(self):
        if not os.path.exists(self.fake_log):
            return ""
        with io.open(self.fake_log, encoding="utf-8") as handle:
            return handle.read()

    def test_a_staged_gd_file_without_gdlint_fails_and_quotes_the_pin_file(self):
        # A pin no release has, so a hardcoded version cannot satisfy this.
        self._pin("  9.9.9 \n")
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdlint NOT FOUND", out)
                self.assertIn('pip install "gdtoolkit==9.9.9"', out)

    def test_a_missing_pin_file_still_fails_without_a_raw_shell_error(self):
        os.remove(os.path.join(self.repo, "scripts/quality-gates/gdtoolkit-version.txt"))
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdlint NOT FOUND", out)
                self.assertIn("<unreadable:", out)
                self.assertNotRegex(out, r"(?i)no such file|cannot open")

    def test_a_commit_with_no_staged_gd_passes_without_gdtoolkit(self):
        _stage(self.repo, "game/data/items.json", '{"ok": true}\n')
        _stage(self.repo, "docs/notes.md", "# notes\n")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)
                self.assertNotIn("NOT FOUND", out)

    def test_a_staged_addon_gd_file_alone_passes_without_gdtoolkit(self):
        # addons/ is vendored GUT and was never linted; requiring a linter for a
        # file the hook does not lint would block every GUT bump for nothing.
        _stage(self.repo, "game/addons/gut/gut.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)

    def test_a_directory_merely_named_like_addons_is_still_linted(self):
        # The exclusion is by path component: myaddons/ is ours, not vendored.
        _stage(self.repo, "scripts/myaddons/tool.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdlint NOT FOUND", out)

    def test_invalid_json_under_a_myaddons_directory_fails_gate_b(self):
        _stage(self.repo, "scripts/myaddons/bad.json", "{not json\n")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("INVALID JSON: scripts/myaddons/bad.json", out)

    def test_gdformat_missing_alone_still_fails_gate_c(self):
        self._fake("gdlint")
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdformat NOT FOUND", out)
        self.assertIn("gdlint game/scripts/a.gd", self._ran(), "Gate A should still have run")

    def test_with_both_tools_present_the_hook_runs_them_and_passes(self):
        self._fake("gdlint", "gdformat")
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)
        ran = self._ran()
        self.assertIn("gdlint game/scripts/a.gd", ran)
        self.assertIn("gdformat --check game/scripts/a.gd", ran)

    # --- The installed version must be the pinned one (#477) -------------

    def test_tools_at_the_pinned_version_pass_with_the_pin_read_as_ci_reads_it(self):
        # Whitespace around the pin is stripped, as static-gates.yml strips it,
        # and a pin no release has means a hardcoded version cannot pass.
        self._pin("  9.9.9 \n")
        self._fake("gdlint", "gdformat", version="9.9.9")
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)
                self.assertNotIn("MISMATCH", out)

    def test_a_gdlint_at_another_version_fails_naming_both_versions(self):
        self._pin("9.9.9\n")
        self._fake("gdlint", "gdformat", version="4.4.0")
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdlint VERSION MISMATCH", out)
                self.assertIn("gdlint 4.4.0", out)
                self.assertIn("gdlint 9.9.9", out)
                self.assertIn('pip install "gdtoolkit==9.9.9"', out)
        self.assertNotIn("gdlint game/", self._ran(), "a mismatched gdlint must not judge the commit")

    def test_a_gdformat_alone_at_another_version_fails_gate_c(self):
        # The comparison is per tool: gdlint matching does not excuse gdformat.
        self._pin("9.9.9\n")
        self._fake("gdlint", "gdformat", version="9.9.9", gdformat="4.4.0")
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdformat VERSION MISMATCH", out)
                self.assertIn("gdformat 4.4.0", out)
                self.assertIn("gdformat 9.9.9", out)
                self.assertIn('pip install "gdtoolkit==9.9.9"', out)
                self.assertNotIn("gdlint VERSION MISMATCH", out)
        ran = self._ran()
        self.assertIn("gdlint game/scripts/a.gd", ran, "Gate A should still have run")
        self.assertNotIn("gdformat --check", ran)

    # --- The version is read from stdout, as static-gates.yml reads it ----

    def test_a_tool_whose_version_command_fails_counts_as_not_found(self):
        # A pyenv shim with no gdtoolkit behind it: on PATH, prints to stderr,
        # exits 127. That is a missing tool, not some other version.
        self._fake("gdformat")
        _write_executable(os.path.join(self.fake_bin, "gdlint"),
                          '#!/bin/sh\necho "pyenv: gdlint: command not found" >&2\nexit 127\n')
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("gdlint NOT FOUND", out)
                self.assertNotIn("MISMATCH", out)
                self.assertNotIn("installed: pyenv", out)

    def test_stderr_beside_the_pinned_version_does_not_count_against_it(self):
        self._fake("gdlint", "gdformat")
        body = _FAKES["gdlint"].replace(
            'if [ "${1-}" = "--version" ]; then ',
            'if [ "${1-}" = "--version" ]; then echo "DeprecationWarning: x" >&2; ')
        _write_executable(os.path.join(self.fake_bin, "gdlint"), body)
        _stage(self.repo, "game/scripts/a.gd")
        for shell, code, out in self._hook():
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)
                self.assertNotIn("MISMATCH", out)
        self.assertIn("gdlint game/scripts/a.gd", self._ran())


class TestGdtoolkitPin(unittest.TestCase):
    """The real pin file. What reads it is judged by the hook and job tests."""

    def test_the_pin_file_holds_a_single_pep440_version(self):
        with io.open(GDTOOLKIT_PIN, encoding="utf-8") as handle:
            lines = [line.strip() for line in handle.read().splitlines() if line.strip()]
        self.assertEqual(len(lines), 1, "gdtoolkit-version.txt must hold one version: %r" % lines)
        self.assertRegex(lines[0], _PEP440)


# --- pre-push and commit-msg run as husky runs them (#476) ------------------
#
# husky runs every hook as `sh -e <hook>`, and Debian's sh is dash. Both hooks
# used to open with `set -euo pipefail`, which a dash without pipefail rejects,
# and pre-push read `${PIPESTATUS[0]}`, which no POSIX sh has. The test this
# replaces asserted the literal string "PIPESTATUS" in pre-push, so it pinned
# the bashism instead of the behavior. These run the real hooks under every
# shell _hook_shells() finds, with fakes for godot, python3 and pnpm.

PRE_PUSH = os.path.join(REPO_ROOT, ".husky", "pre-push")
COMMIT_MSG = os.path.join(REPO_ROOT, ".husky", "commit-msg")
GODOT_LOCK_SH = os.path.join(REPO_ROOT, "scripts", "quality-gates", "godot-lock.sh")

_HOOK_FAKES = {
    # Import succeeds; the GUT run prints a green, ANSI-coloured summary and
    # then exits $FAKE_GUT_EXIT, so a clean summary from a dying process can
    # be staged. FAKE_GUT_KILL_PARENT kills the pipeline stage that would
    # record Godot's status, so a run that records none can be staged too.
    "godot": r'''#!/bin/sh
echo "godot $*" >> "$FAKE_TOOL_LOG"
case " $* " in
  *" --import "*) exit 0 ;;
  *gut_cmdln.gd*)
    printf '\033[32mScripts              90\033[0m\nTests              1289\n'
    printf 'Passing Tests      1289\n---- All tests passed! ----\n'
    [ -n "${FAKE_GUT_KILL_PARENT:-}" ] && kill -9 "$PPID"
    exit "${FAKE_GUT_EXIT:-0}" ;;
esac
echo "fake godot: unexpected: $*"
exit 2
''',
    # Every Python gate passes; Gate L exits $FAKE_GATE_L_EXIT.
    "python3": r'''#!/bin/sh
echo "python3 $*" >> "$FAKE_TOOL_LOG"
case " $* " in
  *check_gut_baseline.py*--log*) exit "${FAKE_GATE_L_EXIT:-0}" ;;
esac
exit 0
''',
    # commitlint's verdict, reduced to the header shape, on the file it is given.
    "pnpm": r'''#!/bin/sh
echo "pnpm $*" >> "$FAKE_TOOL_LOG"
[ "$1 $2 $3" = "exec commitlint --edit" ] || { echo "fake pnpm: unexpected: $*"; exit 2; }
head -n 1 "$4" | grep -Eq '^[a-z]+(\([a-z]+\))?: .+' || { echo "fake commitlint: bad header"; exit 1; }
''',
}


class TestHooksRunUnderPosixSh(unittest.TestCase):
    """.husky/pre-push and .husky/commit-msg under `sh -e` and dash."""

    def setUp(self):
        self.dir = tempfile.mkdtemp(prefix="pod-hooksh-")
        self.addCleanup(shutil.rmtree, self.dir, True)
        name = os.path.basename(self.dir)
        # pre-push writes its log and status beside other worktrees' in /tmp.
        self.log = "/tmp/gut_prepush_%s.log" % name
        for leftover in (self.log, "/tmp/gut_prepush_%s.status" % name):
            self.addCleanup(lambda path=leftover: os.path.exists(path) and os.remove(path))
        for source, relative in (
            (PRE_PUSH, ".husky/pre-push"),
            (COMMIT_MSG, ".husky/commit-msg"),
            (GODOT_LOCK_SH, "scripts/quality-gates/godot-lock.sh"),
        ):
            target = os.path.join(self.dir, relative)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy(source, target)
        gut = os.path.join(self.dir, "game", "addons", "gut", "gut_cmdln.gd")
        os.makedirs(os.path.dirname(gut))
        io.open(gut, "w").close()
        self.fake_bin = os.path.join(self.dir, ".fake-bin")
        os.makedirs(self.fake_bin)
        for tool, body in _HOOK_FAKES.items():
            _write_executable(os.path.join(self.fake_bin, tool), body)
        self.fake_log = os.path.join(self.dir, ".fake-tool.log")

    def _hook(self, hook, *args, before=None, **env_extra):
        """Run `hook` under every husky shell; returns [(shell, code, output, calls)].

        `before`, if given, is called before each shell's run."""
        overrides = dict(
            FAKE_TOOL_LOG=self.fake_log,
            GODOT_BIN=os.path.join(self.fake_bin, "godot"),
            GODOT_LOCK=os.path.join(self.dir, "godot.lock"),
            GODOT_LOCK_POLL="1",
            GODOT_LOCK_TIMEOUT="5",
        )
        overrides.update(env_extra)
        env = _scrubbed_env(self.fake_bin + os.pathsep + _path_without_gdtoolkit(), **overrides)
        runs = []
        for shell in _hook_shells():
            if os.path.exists(self.fake_log):
                os.remove(self.fake_log)
            if before:
                before()
            proc = subprocess.run(
                [shell, "-e", hook] + list(args), cwd=self.dir, env=env, timeout=60,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True,
            )
            calls = ""
            if os.path.exists(self.fake_log):
                with io.open(self.fake_log, encoding="utf-8") as handle:
                    calls = handle.read()
            runs.append((shell, proc.returncode, proc.stdout, calls))
        return runs

    # --- pre-push ---------------------------------------------------------

    def test_pre_push_fails_when_godot_exits_nonzero_in_the_gut_run(self):
        # The summary is green; only the process status says the run died.
        for shell, code, out, calls in self._hook(".husky/pre-push", FAKE_GUT_EXIT="3"):
            with self.subTest(shell=shell):
                self.assertEqual(code, 1, out)
                self.assertIn("Godot EXITED 3 during the GUT run", out)
                self.assertNotIn("check_gut_baseline.py --log", calls)
                self.assertNotIn("All pre-push quality gates passed", out)

    def test_pre_push_fails_when_godot_records_no_status_over_a_stale_zero(self):
        # A previous run's "0" must not stand in for this run's status.
        status = "/tmp/gut_prepush_%s.status" % os.path.basename(self.dir)

        def stale_zero():
            with io.open(status, "w", encoding="utf-8") as handle:
                handle.write("0\n")

        for shell, code, out, calls in self._hook(
                ".husky/pre-push", before=stale_zero, FAKE_GUT_KILL_PARENT="1"):
            with self.subTest(shell=shell):
                self.assertEqual(code, 1, out)
                self.assertIn("Godot EXITED <no status recorded> during the GUT run", out)
                self.assertNotIn("check_gut_baseline.py --log", calls)
                self.assertNotIn("All pre-push quality gates passed", out)

    def test_pre_push_passes_and_hands_gate_l_the_stripped_log(self):
        for shell, code, out, calls in self._hook(".husky/pre-push"):
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)
                self.assertIn("All pre-push quality gates passed", out)
                self.assertNotIn("EXITED", out)
                self.assertIn("check_gut_baseline.py --log %s" % self.log, calls)
                with io.open(self.log, encoding="utf-8") as handle:
                    logged = handle.read()
                self.assertIn("Scripts              90", logged)
                self.assertNotIn("\x1b", logged)

    def test_pre_push_fails_with_gate_ls_status_when_gate_l_fails(self):
        for shell, code, out, calls in self._hook(".husky/pre-push", FAKE_GATE_L_EXIT="4"):
            with self.subTest(shell=shell):
                self.assertEqual(code, 4, out)
                self.assertIn("check_gut_baseline.py --log", calls)
                self.assertNotIn("All pre-push quality gates passed", out)

    # --- commit-msg -------------------------------------------------------

    def _message(self, text):
        path = os.path.join(self.dir, "COMMIT_EDITMSG")
        with io.open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        return path

    def test_commit_msg_rejects_a_message_commitlint_rejects(self):
        path = self._message("Fixed some stuff\n")
        for shell, code, out, calls in self._hook(".husky/commit-msg", path):
            with self.subTest(shell=shell):
                self.assertNotEqual(code, 0, out)
                self.assertIn("fake commitlint: bad header", out)

    def test_commit_msg_accepts_a_conventional_message_and_lints_that_file(self):
        path = self._message("fix(ci): run hooks under dash\n")
        for shell, code, out, calls in self._hook(".husky/commit-msg", path):
            with self.subTest(shell=shell):
                self.assertEqual(code, 0, out)
                self.assertIn("pnpm exec commitlint --edit %s" % path, calls)


# --- scripts/gates.sh in a scratch repo (#474, #477) ------------------------
#
# core.hooksPath is the relative `.husky/_`, which is gitignored, so a fresh
# `git worktree add` has no hooks and its commits and pushes run none, without
# a word. gates.sh is the runner for exactly those worktrees, so it must refuse
# one, and it must hold gdtoolkit to the pin as pre-commit does. Both classes
# below run the real gates.sh, gdtoolkit helper and gate judge in a scratch
# repo whose floors fit a fixture of two gates and one self-test. One of the
# gates is a probe that records it ran, so "the guard stopped the run" is
# observed as no gate running, not read off a message. Changes go outside
# game/, so a passing run ends at STATIC GATES PASSED without Godot.

GATES_SH = os.path.join(REPO_ROOT, "scripts", "gates.sh")
# What pnpm install puts in .husky/_: husky's dispatcher and one shim per hook.
_HUSKY_FILES = ("h", "pre-commit", "commit-msg", "pre-push")
_PROBE_GATE = 'import os\nwith open(os.environ["GATES_PROBE"], "a") as fh:\n    fh.write("ran\\n")\n'


class _GatesShFixture(object):
    """Mixin: a scratch repo holding gates.sh, with its hooks installed."""

    PIN = "9.9.9"  # not the real pin, so a hardcoded version is caught

    def _build(self):
        self.repo = _scratch_repo(self, "pod-gates-")
        self.addCleanup(self._remove_if_present,
                        "/tmp/gatetests_%s.log" % os.path.basename(self.repo))
        self.env = _scrubbed_env(_path_without_gdtoolkit())
        self.probe = os.path.join(tempfile.mkdtemp(prefix="pod-gates-probe-"), "ran")
        self.addCleanup(shutil.rmtree, os.path.dirname(self.probe), True)
        for relative, source in (
            ("scripts/gates.sh", GATES_SH),
            ("scripts/quality-gates/gdtoolkit-require.sh", GDTOOLKIT_HELPER),
            ("scripts/quality-gates/check_gut_baseline.py",
             os.path.join(REPO_ROOT, "scripts", "quality-gates", "check_gut_baseline.py")),
        ):
            target = os.path.join(self.repo, relative)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy(source, target)
        for relative, body in (
            ("scripts/quality-gates/gdtoolkit-version.txt", " %s \n" % self.PIN),
            ("scripts/quality-gates/gut-baseline.txt",
             "scripts=1\ntests=1\ngates=2\ngate_tests=1\n"),
            ("scripts/quality-gates/check_probe.py", _PROBE_GATE),
            ("scripts/quality-gates/test_fixture.py",
             "import unittest\n\n\nclass T(unittest.TestCase):\n"
             "    def test_ok(self):\n        self.assertTrue(True)\n"),
            (".gitignore", ".husky/_\n.fake-bin/\n.fake-tool.log\n__pycache__/\n"),
        ):
            self._write(relative, body)
        self._git("add", "-A")
        self._git("commit", "-q", "-m", "fixture")
        self._git("config", "core.hooksPath", ".husky/_")
        self._install_husky(os.path.join(self.repo, ".husky", "_"))
        self.fake_bin = os.path.join(self.repo, ".fake-bin")
        os.makedirs(self.fake_bin)
        self.fake_log = os.path.join(self.repo, ".fake-tool.log")

    @staticmethod
    def _remove_if_present(path):
        if os.path.exists(path):
            os.remove(path)

    @staticmethod
    def _install_husky(directory):
        os.makedirs(directory, exist_ok=True)
        for name in _HUSKY_FILES:
            _write_executable(os.path.join(directory, name), "#!/bin/sh\n")

    def _write(self, relative, body, root=None):
        target = os.path.join(root or self.repo, relative)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with io.open(target, "w", encoding="utf-8") as handle:
            handle.write(body)

    def _git(self, *args):
        subprocess.run(
            ["git", "-c", "commit.gpgsign=false", "-c", "user.name=t",
             "-c", "user.email=t@example.invalid"] + list(args),
            cwd=self.repo, env=self.env, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    def _gates(self, root=None, **env_extra):
        """Run gates.sh from `root` against HEAD: (code, output, tool calls, probe ran)."""
        root = root or self.repo
        self._remove_if_present(self.probe)
        env = dict(self.env, PATH=self.fake_bin + os.pathsep + self.env["PATH"],
                   FAKE_BIN=self.fake_bin, FAKE_TOOL_LOG=self.fake_log,
                   GATES_BASE="HEAD", GATES_PROBE=self.probe)
        env.update(env_extra)
        proc = subprocess.run(
            ["bash", os.path.join(root, "scripts", "gates.sh")], cwd=root, env=env, timeout=120,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        ran = ""
        if os.path.exists(self.fake_log):
            with io.open(self.fake_log, encoding="utf-8") as handle:
                ran = handle.read()
            os.remove(self.fake_log)
        return proc.returncode, proc.stdout, ran, os.path.exists(self.probe)


class TestGatesShRequiresInstalledHooks(_GatesShFixture, unittest.TestCase):

    def setUp(self):
        self._build()

    def _assert_refused(self, code, out, probed, *expected):
        self.assertEqual(code, 1, out)
        for text in expected:
            self.assertIn(text, out)
        self.assertFalse(probed, "a gate ran in a worktree whose hooks would not:\n" + out)

    def test_a_checkout_with_its_hooks_installed_runs_the_gates_and_passes(self):
        code, out, _, probed = self._gates()
        self.assertEqual(code, 0, out)
        self.assertTrue(probed, "the probe gate never ran:\n" + out)

    def test_a_new_worktree_without_hooks_fails_naming_the_install_command(self):
        worktree = os.path.join(tempfile.mkdtemp(prefix="pod-gates-wt-"), "wt")
        self.addCleanup(shutil.rmtree, os.path.dirname(worktree), True)
        self._git("worktree", "add", "-q", "--detach", worktree)
        self.assertFalse(os.path.exists(os.path.join(worktree, ".husky", "_")))
        code, out, _, probed = self._gates(worktree)
        self._assert_refused(code, out, probed, "GIT HOOKS NOT INSTALLED",
                             "cd '%s' && pnpm install --frozen-lockfile" % worktree)

    def test_each_missing_husky_file_fails(self):
        for name in _HUSKY_FILES:
            with self.subTest(missing=name):
                path = os.path.join(self.repo, ".husky", "_", name)
                os.remove(path)
                try:
                    code, out, _, probed = self._gates()
                finally:
                    _write_executable(path, "#!/bin/sh\n")
                self._assert_refused(code, out, probed, "GIT HOOKS NOT INSTALLED",
                                     ".husky/_/%s" % name, "pnpm install --frozen-lockfile")

    def test_an_unset_hooks_path_fails_and_says_it_is_unset(self):
        self._git("config", "--unset", "core.hooksPath")
        code, out, _, probed = self._gates()
        self._assert_refused(code, out, probed, "GIT HOOKS NOT INSTALLED", "core.hooksPath is unset")
        self.assertNotIn("''", out)

    def test_another_hook_managers_files_do_not_count_as_husky(self):
        # Every file husky would install, in .git/hooks, owned by something else.
        self._git("config", "--unset", "core.hooksPath")
        self._install_husky(os.path.join(self.repo, ".git", "hooks"))
        code, out, _, probed = self._gates()
        self._assert_refused(code, out, probed, "GIT HOOKS NOT INSTALLED")
        self._git("config", "core.hooksPath", ".git/hooks")
        code, out, _, probed = self._gates()
        self._assert_refused(code, out, probed, "GIT HOOKS NOT INSTALLED", "'.git/hooks'")

    def test_husky_0_fails_because_the_hooks_would_run_nothing(self):
        code, out, _, probed = self._gates(HUSKY="0")
        self._assert_refused(code, out, probed, "HUSKY=0")


class TestGatesShChecksTheGdtoolkitPin(_GatesShFixture, unittest.TestCase):
    """gates.sh holds gdtoolkit to the pin, as pre-commit does (#477)."""

    def setUp(self):
        self._build()

    def _fake(self, version, **per_tool):
        with io.open(os.path.join(self.fake_bin, ".gdtoolkit"), "w", encoding="utf-8") as handle:
            handle.write(version + "\n")
        for tool in GDTOOLKIT_TOOLS:
            body = _FAKES[tool]
            if tool in per_tool:
                body = body.replace('$(cat "$FAKE_BIN/.gdtoolkit")', per_tool[tool])
            _write_executable(os.path.join(self.fake_bin, tool), body)

    def test_a_changed_gd_with_gdlint_at_another_version_fails_naming_both_versions(self):
        self._write("tools/a.gd", "extends Node\n")
        self._fake(self.PIN, gdlint="4.4.0")
        code, out, ran, _ = self._gates()
        self.assertEqual(code, 1, out)
        self.assertIn("gdlint VERSION MISMATCH", out)
        self.assertIn("gdlint 4.4.0", out)
        self.assertIn("gdlint %s" % self.PIN, out)
        self.assertIn('pip install "gdtoolkit==%s"' % self.PIN, out)
        self.assertIn("gdformat --check tools/a.gd", ran, "gdformat matched the pin and should run")
        self.assertNotIn("gdlint tools/", ran, "a mismatched gdlint must not judge the change")

    def test_a_changed_gd_with_gdformat_at_another_version_fails_naming_both_versions(self):
        self._write("tools/a.gd", "extends Node\n")
        self._fake(self.PIN, gdformat="4.4.0")
        code, out, ran, _ = self._gates()
        self.assertEqual(code, 1, out)
        self.assertIn("gdformat VERSION MISMATCH", out)
        self.assertIn("gdformat 4.4.0", out)
        self.assertIn("gdformat %s" % self.PIN, out)
        self.assertIn('pip install "gdtoolkit==%s"' % self.PIN, out)
        self.assertIn("gdlint tools/a.gd", ran, "gdlint matched the pin and should run")
        self.assertNotIn("gdformat --check", ran, "a mismatched gdformat must not judge the change")

    def test_a_changed_gd_with_both_tools_at_the_pin_gets_past_the_check(self):
        self._write("tools/a.gd", "extends Node\n")
        self._fake(self.PIN)
        code, out, ran, _ = self._gates()
        self.assertEqual(code, 0, out)
        self.assertNotIn("MISMATCH", out)
        self.assertIn("gdformat --check tools/a.gd", ran)
        self.assertIn("gdlint tools/a.gd", ran)

    def test_a_run_with_no_changed_gd_needs_no_gdtoolkit(self):
        self._write("docs/notes.md", "# notes\n")
        code, out, ran, _ = self._gates()
        self.assertEqual(code, 0, out)
        self.assertNotIn("NOT FOUND", out)
        self.assertEqual(ran, "")


class TestFixturesIgnoreTheCallersEnvironment(unittest.TestCase):
    """A fixture's verdict must not depend on who runs the suite (#482).

    `GATES_FORCE_GODOT=1 bash scripts/gates.sh` is the documented way to prove
    main green, and gates.sh runs this suite as Gate I. With the knob inherited,
    every fixture gates.sh run -- a scratch repo with no game/ and no Godot --
    went on to the Godot stage and failed, so the recipe failed on a green tree.
    This runs a representative test of each kind of fixture in a child unittest
    process whose environment carries HOSTILE, and requires them all to pass
    exactly as they do in a bare shell.

    Which HOSTILE entries the guard actually exercises: GATES_FORCE_GODOT,
    HUSKY and GIT_DIR each turn a representative red when inherited, and so
    do MIN_GATES and MIN_GATE_TESTS, which quality-gates.yml exports to CI's
    real Gate I step. GATES_BASE, GATES_MAX_GODOT, GODOT_BIN and GODOT_LOCK
    are preventive: every fixture that reads them either sets its own value
    over the inherited one or stops before the stage that reads it, so letting
    any one of them through the scrub leaves this test green today. It costs a
    child process running ten fixture tests, roughly 5-10s.
    """

    HOSTILE = {
        "GATES_FORCE_GODOT": "1",
        "GATES_BASE": "deadbeef" * 5,  # no such commit in any fixture repo
        "GATES_MAX_GODOT": "0",
        "HUSKY": "0",
        "GODOT_BIN": "/nonexistent/godot",
        "GODOT_LOCK": "/nonexistent/pod-godot.lock",
        "GIT_DIR": "/nonexistent/.git",
        "MIN_GATES": "1",
        "MIN_GATE_TESTS": "1",
    }
    REPRESENTATIVE = (
        "TestGatesShRequiresInstalledHooks.test_a_checkout_with_its_hooks_installed_runs_the_gates_and_passes",
        "TestGatesShChecksTheGdtoolkitPin.test_a_changed_gd_with_both_tools_at_the_pin_gets_past_the_check",
        "TestGatesShChecksTheGdtoolkitPin.test_a_run_with_no_changed_gd_needs_no_gdtoolkit",
        "TestPreCommitRequiresGdtoolkit.test_with_both_tools_present_the_hook_runs_them_and_passes",
        "TestHooksRunUnderPosixSh.test_pre_push_passes_and_hands_gate_l_the_stripped_log",
        "TestHooksRunUnderPosixSh.test_commit_msg_accepts_a_conventional_message_and_lints_that_file",
        "TestQualityGatesWorkflow.test_a_clean_tree_passes_having_run_every_gate_and_self_test",
        "TestQualityGatesWorkflow.test_a_step_that_never_received_its_floor_fails_on_a_clean_tree",
        "TestStaticGatesWorkflow.test_a_clean_tree_passes_having_installed_the_pin_and_checked_every_file",
        "TestGodotLockMutex.test_an_acquirer_names_itself_and_release_removes_the_lock",
    )

    def test_representative_fixtures_pass_with_hostile_knobs_in_the_callers_environment(self):
        module = os.path.splitext(os.path.basename(__file__))[0]
        ids = ["%s.%s" % (module, name) for name in self.REPRESENTATIVE]
        # Deliberately NOT scrubbed: the child inherits the hostile knobs, as
        # a suite run under `GATES_FORCE_GODOT=1 bash scripts/gates.sh` does.
        env = dict(os.environ, **self.HOSTILE)
        proc = subprocess.run(
            [sys.executable, "-m", "unittest"] + ids, cwd=os.path.dirname(os.path.abspath(__file__)),
            env=env, timeout=300, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            universal_newlines=True)
        self.assertEqual(proc.returncode, 0, proc.stdout)
        # Every one ran, and none passed by being skipped.
        self.assertRegex(proc.stdout, r"(?m)^Ran %d tests?\b" % len(ids), proc.stdout)
        self.assertRegex(proc.stdout, r"(?m)^OK$", proc.stdout)


_PR_SHAS = {
    "github.event.pull_request.base.sha": "BASESHA",
    "github.event.pull_request.head.sha": "HEADSHA",
}


class TestStaticGatesWorkflow(unittest.TestCase):
    """static-gates.yml must FAIL when a gate fails, and only then (#472).

    Each test builds a fixture repo, runs every `run:` body of the job in order
    through run_workflow_steps with the fakes on PATH, and judges the verdict.
    """

    PIN = "1.2.3"  # not the real pin, so a hardcoded version is caught

    def setUp(self):
        with io.open(STATIC_GATES_YML, encoding="utf-8") as handle:
            self.text = handle.read()
        self.steps = workflow_steps(self.text)
        self.repo = _scratch_repo(self, "pod-sg-fixture-")
        self.tools = tempfile.mkdtemp(prefix="pod-sg-tools-")
        self.addCleanup(shutil.rmtree, self.tools, True)
        self.fake_bin = os.path.join(self.tools, "bin")
        self.templates = os.path.join(self.tools, "templates")
        os.makedirs(self.fake_bin)
        os.makedirs(self.templates)
        for tool in ("gdlint", "gdformat"):
            _write_executable(os.path.join(self.templates, tool), _FAKES[tool])
        for tool in ("pip", "pnpm"):
            _write_executable(os.path.join(self.fake_bin, tool), _FAKES[tool])
        self.fake_log = os.path.join(self.tools, "calls.log")
        _stage(self.repo, "scripts/quality-gates/gdtoolkit-version.txt", self.PIN + "\n")

    def _tree(self, gd=(), json_files=()):
        for relative, body in gd:
            _stage(self.repo, relative, body)
        for relative, body in json_files:
            _stage(self.repo, relative, body)

    def _clean_tree(self):
        self._tree(
            gd=[("game/scripts/a.gd", "extends Node\n"),
                ("game/tests/deep/b c.gd", "extends Node\n"),  # a space in the path
                ("game/myaddons/d.gd", "extends Node\n"),
                ("game/addons/gut/vendored.gd", "LINT_ERROR BADFORMAT\n"),
                ("tools/elsewhere.gd", "LINT_ERROR\n")],  # outside game/
            json_files=[("package.json", "{}\n"),
                        ("game/data/enemies/deep/x.json", "[]\n"),
                        ("game/addons/gut/versions.json", "{not json\n")],
        )

    def _job(self, **env):
        env_extra = {
            "PATH": self.fake_bin + os.pathsep + _path_without_gdtoolkit(),
            "FAKE_TOOL_LOG": self.fake_log,
            "FAKE_BIN": self.fake_bin,
            "FAKE_TEMPLATES": self.templates,
            # A real pip reached by a refactor must not install anything.
            "PIP_NO_INDEX": "1",
            "PIP_REQUIRE_VIRTUALENV": "1",
        }
        env_extra.update(env)
        failed, results, out = run_workflow_steps(
            self.steps, self.repo, env_extra=env_extra, expressions=_PR_SHAS)
        outcomes = {step.get("name"): outcome for step, outcome in results}
        return failed, outcomes, out

    def _calls(self, tool):
        if not os.path.exists(self.fake_log):
            return []
        with io.open(self.fake_log, encoding="utf-8") as handle:
            return [line for line in handle.read().splitlines() if line.split(" ", 1)[0] == tool]

    def _run_steps(self):
        return [s.get("name") for s in self.steps if "run" in s]

    # --- executed --------------------------------------------------------

    def test_a_clean_tree_passes_having_installed_the_pin_and_checked_every_file(self):
        self._clean_tree()
        failed, outcomes, out = self._job()
        self.assertFalse(failed, out)
        self.assertEqual({outcomes[n] for n in self._run_steps()}, {"success"}, out)
        self.assertEqual(self._calls("pip"), ["pip install gdtoolkit==%s" % self.PIN])
        linted = " ".join(self._calls("gdlint"))
        formatted = self._calls("gdformat")
        expected = ["game/myaddons/d.gd", "game/scripts/a.gd", "game/tests/deep/b c.gd"]
        for path in expected:
            self.assertIn(path, linted)
        self.assertNotIn("addons/gut", linted)
        self.assertNotIn("tools/elsewhere.gd", linted)
        self.assertTrue(formatted and all(c.startswith("gdformat --check ") for c in formatted), formatted)
        self.assertIn("gdscript files: 3 ", out)
        self.assertIn("JSON validation passed: 2 tracked files", out)
        self.assertEqual(self._calls("pnpm"), [
            "pnpm install --frozen-lockfile --ignore-scripts",
            "pnpm exec commitlint --verbose --from BASESHA --to HEADSHA",
        ])

    def test_a_version_mismatch_fails_the_job(self):
        self._clean_tree()
        failed, outcomes, out = self._job(FAKE_PIP_RESOLVES="1.2.4")
        self.assertTrue(failed, out)
        self.assertEqual(outcomes["Install pinned gdtoolkit"], "failure", out)

    def test_a_lint_failure_fails_the_job_and_every_later_step_still_runs(self):
        self._clean_tree()
        _stage(self.repo, "game/scripts/a.gd", "LINT_ERROR\n")
        failed, outcomes, out = self._job()
        self.assertTrue(failed, out)
        self.assertEqual(outcomes["gdlint (Gate A)"], "failure", out)
        names = self._run_steps()
        for name in names[names.index("gdlint (Gate A)") + 1:]:
            with self.subTest(step=name):
                self.assertEqual(outcomes[name], "success", out)

    def test_a_format_mismatch_fails_the_job(self):
        self._clean_tree()
        _stage(self.repo, "game/tests/deep/b c.gd", "BADFORMAT\n")
        failed, outcomes, out = self._job()
        self.assertTrue(failed, out)
        self.assertEqual(outcomes["gdformat check (Gate C)"], "failure", out)
        self.assertIn("would reformat game/tests/deep/b c.gd", out)

    def test_no_gd_files_fails_the_job(self):
        self._tree(gd=[("game/addons/gut/vendored.gd", "extends Node\n")],
                   json_files=[("package.json", "{}\n")])
        failed, outcomes, out = self._job()
        self.assertTrue(failed, out)
        self.assertEqual(outcomes["Collect GDScript files"], "failure", out)
        self.assertIn("NO .gd FILES FOUND", out)

    def test_no_json_files_fails_the_job(self):
        self._tree(gd=[("game/scripts/a.gd", "extends Node\n")],
                   json_files=[("game/addons/gut/versions.json", "{}\n")])
        failed, outcomes, out = self._job()
        self.assertTrue(failed, out)
        self.assertEqual(outcomes["JSON validation (Gate B)"], "failure", out)
        self.assertIn("NO .json FILES FOUND", out)

    def test_invalid_json_anywhere_in_the_tracked_tree_fails_the_job(self):
        # Gate B's scope is every tracked .json outside addons/, as in the hook:
        # not only game/data, and myaddons/ is not addons/.
        self._clean_tree()
        _stage(self.repo, ".claude/settings.json", "{not json\n")
        _stage(self.repo, "scripts/myaddons/urls.json", "[1,\n")
        failed, outcomes, out = self._job()
        self.assertTrue(failed, out)
        self.assertEqual(outcomes["JSON validation (Gate B)"], "failure", out)
        self.assertIn("INVALID JSON: .claude/settings.json", out)
        self.assertIn("INVALID JSON: scripts/myaddons/urls.json", out)

    def test_every_step_after_checkout_runs_after_an_earlier_failure(self):
        # The emulation runs `run:` steps only; the setup actions commitlint
        # needs are judged by the same condition reader the emulation uses.
        for step in self.steps[1:]:
            with self.subTest(step=step.get("name")):
                self.assertTrue(runs_after_a_failure(step), step.get("if"))

    # --- text: only what the runner itself provides ----------------------

    def test_the_wiring_matcher_rejects_a_commented_out_setting(self):
        live = "fetch-depth: 0"
        self.assertEqual(live_lines("    " + live, r"^fetch-depth: 0$"), [live])
        self.assertEqual(live_lines("    # " + live, r"^fetch-depth: 0$"), [])

    def test_commitlint_gets_full_history_node_and_the_pinned_pnpm(self):
        uses = [s.get("uses", "") for s in self.steps]
        self.assertTrue(any(u.startswith("pnpm/action-setup@") for u in uses), uses)
        self.assertTrue(any(u.startswith("actions/setup-node@") for u in uses), uses)
        # A shallow clone holds only the merge commit: commitlint would have no range.
        self.assertTrue(live_lines(self.text, r"^fetch-depth: 0$"))
        self.assertTrue(live_lines(self.text, r'^node-version: "?\d+"?$'))
        # pnpm/action-setup must take pnpm's version from packageManager.
        self.assertEqual(live_lines(self.text, r"^version:"), [])

    def test_no_step_or_job_is_allowed_to_fail_quietly(self):
        self.assertNotIn("continue-on-error", uncommented(self.text))

    def test_it_runs_on_every_pull_request_base(self):
        on_block = re.search(r"(?ms)^on:\n(.*?)^\S", uncommented(self.text))
        self.assertIsNotNone(on_block, "no `on:` block")
        self.assertIn("pull_request:", on_block.group(1))
        self.assertNotRegex(on_block.group(1), r"\b(branches|branches-ignore|paths|paths-ignore):")


# --- Least privilege and a time limit, in every gate workflow (#478) --------
#
# All three gate workflows run PR code. Each must declare a read-only token
# rather than lean on the repo default, keep checkout from persisting its auth
# in the clone, and cap every JOB, not only some steps: gut-tests.yml had step
# timeouts and no job one, so a `timeout-minutes:` substring test passed on it
# while a hung download could run for the 360-minute default.

GATE_WORKFLOWS = ("quality-gates.yml", "static-gates.yml", "gut-tests.yml")


def _indent(line):
    return len(line) - len(line.lstrip())


def _block(lines, start):
    """The non-blank lines indented deeper than lines[start], up to the next shallower one."""
    out = []
    for line in lines[start + 1:]:
        if line.strip() and _indent(line) <= _indent(lines[start]):
            break
        if line.strip():
            out.append(line)
    return out


def top_level_permissions(code):
    """The entries under the top-level `permissions:` key, stripped, or None."""
    lines = code.splitlines()
    starts = [i for i, line in enumerate(lines) if line.rstrip() == "permissions:"]
    if len(starts) != 1:
        return None
    return [line.strip() for line in _block(lines, starts[0])]


def job_keys(code):
    """{job id: {key: value}} for each job's own keys, not its steps' keys."""
    lines = code.splitlines()
    starts = [i for i, line in enumerate(lines) if line.rstrip() == "jobs:"]
    if len(starts) != 1:
        return {}
    body = _block(lines, starts[0])
    if not body:
        return {}
    job_indent = min(_indent(line) for line in body)
    jobs, current = {}, None
    for line in body:
        if _indent(line) == job_indent:
            current = jobs.setdefault(line.strip().rstrip(":"), {})
        elif current is not None and _indent(line) == job_indent + 2:
            key, _, value = line.strip().partition(":")
            current[key] = value.strip()
    return jobs


def checkout_inputs(code):
    """[{input: value}], one per actions/checkout step, from that step's own `with:`."""
    lines = code.splitlines()
    found = []
    for i, line in enumerate(lines):
        if not re.match(r"^\s*(- )?uses: actions/checkout@", line):
            continue
        # The step's keys sit where `uses:` itself starts, after any "- ".
        key_indent = _indent(line) + (2 if line.strip().startswith("- ") else 0)
        inputs = {}
        for j in range(i + 1, len(lines)):
            nxt = lines[j]
            if not nxt.strip():
                continue
            if _indent(nxt) < key_indent or nxt.strip().startswith("- "):
                break
            if _indent(nxt) == key_indent and nxt.strip() == "with:":
                for entry in _block(lines, j):
                    key, _, value = entry.strip().partition(":")
                    inputs[key] = value.strip()
        found.append(inputs)
    return found


class TestGateWorkflowsHoldLeastPrivilege(unittest.TestCase):
    """quality-gates.yml, static-gates.yml and gut-tests.yml, read as text.

    The runner provides these settings, so they cannot be executed. They are
    read per job and per checkout step, never as substrings of the whole file.
    """

    def test_every_gate_workflow_holds_least_privilege_and_a_job_time_limit(self):
        for name in GATE_WORKFLOWS:
            with self.subTest(workflow=name):
                with io.open(os.path.join(REPO_ROOT, ".github", "workflows", name),
                             encoding="utf-8") as handle:
                    code = uncommented(handle.read())
                self.assertEqual(top_level_permissions(code), ["contents: read"])
                jobs = job_keys(code)
                self.assertTrue(jobs, "no jobs found")
                for job, keys in jobs.items():
                    self.assertRegex(keys.get("timeout-minutes", ""), r"^\d+$",
                                     "job %s has no timeout-minutes of its own" % job)
                    self.assertNotIn("permissions", keys, "job %s sets its own permissions" % job)
                checkouts = checkout_inputs(code)
                self.assertTrue(checkouts, "no actions/checkout step found")
                for inputs in checkouts:
                    self.assertEqual(inputs.get("persist-credentials"), "false", inputs)

    def test_a_step_timeout_or_a_commented_setting_does_not_count(self):
        # gut-tests.yml's shape before #478: step timeouts and no job timeout,
        # plus each setting present only as a comment or on the wrong step.
        text = (
            "# permissions:\n#   contents: read\n"
            "jobs:\n"
            "  run:\n"
            "    runs-on: ubuntu-latest\n"
            "    # timeout-minutes: 10\n"
            "    steps:\n"
            "      - name: Checkout\n"
            "        uses: actions/checkout@v6\n"
            "        # with:\n"
            "        #   persist-credentials: false\n"
            "      - name: Test\n"
            "        run: make\n"
            "        timeout-minutes: 5\n"
            "        with:\n"
            "          persist-credentials: false\n"
        )
        code = uncommented(text)
        self.assertIsNone(top_level_permissions(code))
        self.assertEqual(job_keys(code), {"run": {"runs-on": "ubuntu-latest", "steps": ""}})
        self.assertEqual(checkout_inputs(code), [{}])


if __name__ == "__main__":
    unittest.main()
