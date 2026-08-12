#!/usr/bin/env python3
"""Tests for Quality Gate J: dialogue JSON / script markdown sync.

Gate J is a scan, and a scan that has stopped detecting reports "nothing
found", which reads exactly like "nothing wrong" (#365). These tests run
under Gate I's discovery, so a gate that has stopped detecting fails at
pre-push rather than passing silently.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
Or:  python3 scripts/quality-gates/test_dialogue_sync.py
"""
import json
import os
import re
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import check_dialogue_sync  # noqa: E402

REPO_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..")
)

# The phrase the gate prints on success and both READMEs repeat. Kept in one
# place so the doc-claim test and the gate cannot drift apart.
PINNED_CLAIM_RE = re.compile(r"(\d+) strings are pinned")


class DialogueSyncFixture(unittest.TestCase):
    """A miniature two-corpus tree, with floors low enough to scan it."""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.script_dir = os.path.join(self.tmpdir, "script")
        self.dialogue_dir = os.path.join(self.tmpdir, "dialogue")
        os.makedirs(self.script_dir)
        os.makedirs(self.dialogue_dir)

    def tearDown(self):
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def write_script(self, name: str, text: str) -> None:
        with open(
            os.path.join(self.script_dir, name), "w", encoding="utf-8"
        ) as handle:
            handle.write(text)

    def write_dialogue(self, name: str, doc: dict) -> None:
        path = os.path.join(self.dialogue_dir, name)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as handle:
            json.dump(doc, handle)

    def scene(self, *lines: str) -> dict:
        return {"scene_id": "fixture", "entries": [{"lines": list(lines)}]}

    def run_check(self, pins=None) -> list[str]:
        """Run the gate over the fixture with the floors turned down."""
        return check_dialogue_sync.check_dialogue_sync(
            script_dir=self.script_dir,
            dialogue_dir=self.dialogue_dir,
            known_orphans={} if pins is None else pins,
            min_script_files=1,
            min_script_chars=1,
            min_dialogue_files=1,
            min_dialogue_lines=1,
        )


class TestVerbatimMatching(DialogueSyncFixture):
    """A shipped line must appear, character for character, in the script."""

    def test_line_with_markdown_source_passes(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("scene.json", self.scene("The gate is sealed."))
        self.assertEqual(self.run_check(), [])

    def test_line_with_no_markdown_source_fails(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("scene.json", self.scene("The gate is open."))
        errors = self.run_check()
        self.assertEqual(len(errors), 1)
        self.assertIn("The gate is open.", errors[0])
        self.assertIn("no verbatim source", errors[0])

    def test_reworded_line_fails(self):
        """The drift this gate exists for: one copy edited, not the other."""
        self.write_script("act.md", "EDREN: She waits at the bridge.\n")
        self.write_dialogue(
            "scene.json", self.scene("She waited at the bridge.")
        )
        self.assertEqual(len(self.run_check()), 1)

    def test_match_is_case_sensitive(self):
        self.write_script("act.md", "Critical!\n")
        self.write_dialogue("scene.json", self.scene("critical!"))
        self.assertEqual(len(self.run_check()), 1)

    def test_whitespace_is_not_normalized(self):
        self.write_script("act.md", "Edren - Cael - Maren\n")
        self.write_dialogue("scene.json", self.scene("Edren  -  Cael  -  Maren"))
        self.assertEqual(len(self.run_check()), 1)

    def test_source_may_live_in_any_script_file(self):
        self.write_script("act-i.md", "Nothing relevant here.\n")
        self.write_script("act-ii.md", "MAREN: Hold the line.\n")
        self.write_dialogue("scene.json", self.scene("Hold the line."))
        self.assertEqual(self.run_check(), [])

    def test_markdown_without_a_shipped_line_is_not_an_error(self):
        """The reverse direction is out of scope — most script is direction."""
        self.write_script(
            "act.md", "The hall darkens.\nEDREN: The gate is sealed.\n"
        )
        self.write_dialogue("scene.json", self.scene("The gate is sealed."))
        self.assertEqual(self.run_check(), [])


class TestRatchet(DialogueSyncFixture):
    """The pin list fails at both ends, so it can only shrink."""

    def test_pinned_orphan_passes(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("scene.json", self.scene("Unsourced line."))
        pins = {"scene.json": ("Unsourced line.",)}
        self.assertEqual(self.run_check(pins), [])

    def test_unpinned_orphan_fails_even_when_others_are_pinned(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue(
            "scene.json", self.scene("Unsourced line.", "Also unsourced.")
        )
        pins = {"scene.json": ("Unsourced line.",)}
        errors = self.run_check(pins)
        self.assertEqual(len(errors), 1)
        self.assertIn("Also unsourced.", errors[0])

    def test_pin_for_a_line_that_now_resolves_fails(self):
        """The back-fill landed; the pin outlived its reason."""
        self.write_script("act.md", "EDREN: Unsourced line.\n")
        self.write_dialogue("scene.json", self.scene("Unsourced line."))
        errors = self.run_check({"scene.json": ("Unsourced line.",)})
        self.assertEqual(len(errors), 1)
        self.assertIn("no longer an unsourced line", errors[0])

    def test_pin_for_a_line_that_was_deleted_fails(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("scene.json", self.scene("The gate is sealed."))
        errors = self.run_check({"scene.json": ("Line that left.",)})
        self.assertEqual(len(errors), 1)
        self.assertIn("Line that left.", errors[0])

    def test_pin_for_a_file_that_was_deleted_fails(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("scene.json", self.scene("The gate is sealed."))
        errors = self.run_check({"gone.json": ("Anything.",)})
        self.assertEqual(len(errors), 1)
        self.assertIn("gone.json", errors[0])

    def test_a_pin_does_not_cover_the_same_string_in_another_file(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("a.json", self.scene("Unsourced line."))
        self.write_dialogue("b.json", self.scene("Unsourced line."))
        errors = self.run_check({"a.json": ("Unsourced line.",)})
        self.assertEqual(len(errors), 1)
        self.assertIn("b.json", errors[0])


class TestRecursion(DialogueSyncFixture):
    """The walk reaches `lines` wherever it is nested, not just at depth 2."""

    def test_finds_lines_nested_under_a_choice_branch(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue(
            "scene.json",
            {
                "scene_id": "fixture",
                "entries": [
                    {
                        "lines": ["The gate is sealed."],
                        "choice": {
                            "options": [
                                {"branch": {"lines": ["Deeply unsourced."]}}
                            ]
                        },
                    }
                ],
            },
        )
        errors = self.run_check()
        self.assertEqual(len(errors), 1)
        self.assertIn("Deeply unsourced.", errors[0])

    def test_walker_reaches_every_nesting_level(self):
        doc = {
            "entries": [{"lines": ["depth two"]}],
            "wrapper": {"inner": {"lines": ["depth three"]}},
            "listed": [[{"lines": ["through nested lists"]}]],
        }
        found = list(check_dialogue_sync.iter_line_strings(doc))
        self.assertEqual(
            sorted(found),
            ["depth three", "depth two", "through nested lists"],
        )

    def test_non_string_members_of_lines_are_skipped(self):
        doc = {"entries": [{"lines": ["real", None, 7, {"lines": ["deep"]}]}]}
        self.assertEqual(
            sorted(check_dialogue_sync.iter_line_strings(doc)),
            ["deep", "real"],
        )

    def test_files_in_subdirectories_are_scanned(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue(
            os.path.join("act-iii", "scene.json"), self.scene("Unsourced.")
        )
        errors = self.run_check()
        self.assertEqual(len(errors), 1)
        self.assertIn("act-iii/scene.json", errors[0])


class TestNonVacuity(DialogueSyncFixture):
    """A scan that read nothing must fail, not report clean."""

    def test_empty_corpus_fails_rather_than_passing(self):
        errors = check_dialogue_sync.check_dialogue_sync(
            script_dir=self.script_dir, dialogue_dir=self.dialogue_dir
        )
        self.assertTrue(errors)
        self.assertTrue(all("floor" in e for e in errors))

    def test_missing_directories_fail_rather_than_passing(self):
        errors = check_dialogue_sync.check_dialogue_sync(
            script_dir=os.path.join(self.tmpdir, "nope"),
            dialogue_dir=os.path.join(self.tmpdir, "also-nope"),
        )
        self.assertEqual(len(errors), 4)

    def test_a_walker_that_stops_descending_trips_the_floor(self):
        """Break the recursion, not the entry point: the floor still fires.

        Substitutes a walker that reads `lines` off the top-level document
        only — the shape a refactor produces when it stops recursing — and
        confirms the scan reports a degenerate read instead of a clean tree.
        """
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        for i in range(3):
            self.write_dialogue(f"s{i}.json", self.scene("Unsourced line."))

        def shallow(node):
            if isinstance(node, dict):
                for item in node.get("lines", []):
                    if isinstance(item, str):
                        yield item

        real = check_dialogue_sync.iter_line_strings
        check_dialogue_sync.iter_line_strings = shallow
        try:
            errors = check_dialogue_sync.check_dialogue_sync(
                script_dir=self.script_dir,
                dialogue_dir=self.dialogue_dir,
                known_orphans={},
                min_script_files=1,
                min_script_chars=1,
                min_dialogue_files=1,
                min_dialogue_lines=3,
            )
        finally:
            check_dialogue_sync.iter_line_strings = real

        self.assertEqual(len(errors), 1)
        self.assertIn("dialogue lines[] strings", errors[0])
        self.assertIn("floor 3", errors[0])

    def test_unreadable_json_is_reported_not_skipped(self):
        self.write_script("act.md", "EDREN: The gate is sealed.\n")
        self.write_dialogue("good.json", self.scene("The gate is sealed."))
        with open(
            os.path.join(self.dialogue_dir, "bad.json"), "w", encoding="utf-8"
        ) as handle:
            handle.write("{not json")
        errors = self.run_check()
        self.assertEqual(len(errors), 1)
        self.assertIn("not valid JSON", errors[0])


class TestAgainstTheRepo(unittest.TestCase):
    """The gate's real subject: this repository, as it stands."""

    def setUp(self):
        self.cwd = os.getcwd()
        os.chdir(REPO_ROOT)

    def tearDown(self):
        os.chdir(self.cwd)

    def test_repo_is_clean_under_the_shipped_pins(self):
        self.assertEqual(check_dialogue_sync.check_dialogue_sync(), [])

    def test_the_scan_reads_a_real_corpus(self):
        """The floors have headroom, so a clean result means something."""
        corpus, script_files = check_dialogue_sync.load_script_corpus()
        dialogue_files = check_dialogue_sync.iter_dialogue_files()
        lines = 0
        for rel in dialogue_files:
            path = os.path.join(check_dialogue_sync.DIALOGUE_DIR, rel)
            with open(path, encoding="utf-8") as handle:
                doc = json.load(handle)
            lines += len(list(check_dialogue_sync.iter_line_strings(doc)))

        self.assertGreater(script_files, check_dialogue_sync.MIN_SCRIPT_FILES)
        self.assertGreater(len(corpus), check_dialogue_sync.MIN_SCRIPT_CHARS)
        self.assertGreater(
            len(dialogue_files), check_dialogue_sync.MIN_DIALOGUE_FILES
        )
        self.assertGreater(lines, check_dialogue_sync.MIN_DIALOGUE_LINES)

    def test_every_pinned_file_and_string_is_real(self):
        """A pin names a shipped file and a string that file still holds."""
        for rel, pinned in check_dialogue_sync.KNOWN_ORPHANS.items():
            path = os.path.join(check_dialogue_sync.DIALOGUE_DIR, rel)
            self.assertTrue(os.path.isfile(path), f"{rel} is not a file")
            with open(path, encoding="utf-8") as handle:
                doc = json.load(handle)
            shipped = set(check_dialogue_sync.iter_line_strings(doc))
            for line in pinned:
                self.assertIn(line, shipped, f"{rel}: {line!r}")

    def test_both_readmes_state_the_current_pin_count(self):
        """Prose that counts the pins must move when the ratchet moves."""
        pinned = sum(
            len(v) for v in check_dialogue_sync.KNOWN_ORPHANS.values()
        )
        for doc in ("docs/story/README.md", "tools/README.md"):
            with open(doc, encoding="utf-8") as handle:
                text = handle.read()
            claims = PINNED_CLAIM_RE.findall(text)
            self.assertEqual(
                len(claims), 1, f"{doc} should state the pin count once"
            )
            self.assertEqual(
                int(claims[0]),
                pinned,
                f"{doc} claims {claims[0]} pinned strings; the gate pins "
                f"{pinned} — update the sentence",
            )


if __name__ == "__main__":
    unittest.main()
