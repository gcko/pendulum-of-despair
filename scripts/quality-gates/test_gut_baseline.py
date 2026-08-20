#!/usr/bin/env python3
"""Quality Gate I coverage for Gate L (`check_gut_baseline.py`).

Two kinds of test live here and they fail differently, so both are needed:

  * fixture tests, which prove the parsing and the verdicts are right; and
  * WIRING tests, which prove the hook, CI and `scripts/gates.sh` actually call
    the thing. `test_quality_gates.py` once had 36 green tests that no hook ran,
    which is the exact shape of bug a fixture-only suite cannot see.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
"""
import io
import os
import sys
import tempfile
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


class TestWiredIntoTheGates(unittest.TestCase):
    """A gate nothing calls is not a gate. These are the tests that notice."""

    def _read(self, relative):
        with io.open(os.path.join(REPO_ROOT, relative), encoding="utf-8") as handle:
            return handle.read()

    def test_real_baseline_file_parses(self):
        floors = gate.read_floors(os.path.join(REPO_ROOT, "scripts/quality-gates/gut-baseline.txt"))
        self.assertEqual(sorted(floors), sorted(gate.FLOOR_KEYS))

    def test_pre_push_runs_the_gate(self):
        hook = self._read(".husky/pre-push")
        self.assertIn("check_gut_baseline.py", hook)
        self.assertIn("--log", hook)

    def test_pre_push_registry_documents_letter_l(self):
        hook = self._read(".husky/pre-push")
        self.assertRegex(hook, r"#\s+L\s+.*check_gut_baseline\.py")

    def test_pre_push_fails_when_the_summary_is_absent(self):
        # The old Gate H read `grep -q "Failing Tests" && ! grep -qE "...0"`,
        # which passed when the suite crashed before printing any summary.
        hook = self._read(".husky/pre-push")
        self.assertNotIn('if grep -q "Failing Tests" "$TEMP_LOG" && !', hook)
        self.assertIn("GUT Run Summary MISSING", hook)
        self.assertIn('grep -qE "^Scripts[[:space:]]+[0-9]+" "$TEMP_LOG"', hook)

    def test_ci_fails_when_the_summary_is_absent(self):
        workflow = self._read(".github/workflows/gut-tests.yml")
        self.assertIn("GUT Run Summary MISSING", workflow)
        # The bare "All tests passed" substring check is what it replaced.
        self.assertNotIn('if grep -q "All tests passed" /tmp/gut.log', workflow)

    def test_pre_push_checks_godot_exit_status(self):
        self.assertIn("PIPESTATUS", self._read(".husky/pre-push"))

    def test_ci_workflow_runs_the_gate(self):
        self.assertIn("check_gut_baseline.py", self._read(".github/workflows/gut-tests.yml"))

    def test_gates_sh_runs_the_gate(self):
        self.assertIn("check_gut_baseline.py", self._read("scripts/gates.sh"))

    def test_gates_sh_no_longer_hardcodes_its_own_floor_parsing(self):
        # Two implementations of one floor is how the wordings drift apart, and
        # the SILENTLY SKIPPED diagnosis is the one that must not.
        gates_sh = self._read("scripts/gates.sh")
        self.assertNotIn("SILENTLY SKIPPED", gates_sh)
        self.assertNotIn("SCRIPT COUNT REGRESSION", gates_sh)
        self.assertNotIn("read_floor()", gates_sh)


if __name__ == "__main__":
    unittest.main()
