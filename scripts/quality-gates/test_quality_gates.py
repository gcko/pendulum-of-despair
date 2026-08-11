#!/usr/bin/env python3
"""Tests for quality gate scripts.

Run: python3 -m pytest scripts/quality-gates/test_quality_gates.py -v
Or:  python3 scripts/quality-gates/test_quality_gates.py
"""
import json
import os
import shutil
import tempfile
import unittest
from unittest.mock import patch

# Import the modules under test
import sys
sys.path.insert(0, os.path.dirname(__file__))
import check_id_uniqueness
import check_stale_counts
import check_scene_refs
import check_doc_citations


class TestCheckIdUniqueness(unittest.TestCase):
    """Tests for Gate D: Cross-file ID uniqueness."""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def _write_json(self, path: str, data: dict) -> str:
        full = os.path.join(self.tmpdir, path)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w") as f:
            json.dump(data, f)
        return full

    def test_no_duplicates(self):
        f = self._write_json("items.json", {
            "items": [{"id": "potion"}, {"id": "ether"}]
        })
        errors = check_id_uniqueness.check_ids(f, ["items"], "item")
        self.assertEqual(errors, [])

    def test_detects_duplicate_within_file(self):
        f = self._write_json("items.json", {
            "items": [{"id": "potion"}, {"id": "potion"}]
        })
        errors = check_id_uniqueness.check_ids(f, ["items"], "item")
        self.assertEqual(len(errors), 1)
        self.assertIn("DUPLICATE", errors[0])
        self.assertIn("potion", errors[0])

    def test_handles_missing_key(self):
        f = self._write_json("items.json", {"other": []})
        errors = check_id_uniqueness.check_ids(f, ["items"], "item")
        self.assertEqual(errors, [])

    def test_handles_invalid_json(self):
        full = os.path.join(self.tmpdir, "bad.json")
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w") as f:
            f.write("{invalid json")
        errors = check_id_uniqueness.check_ids(full, ["items"], "item")
        self.assertEqual(errors, [])

    def test_handles_missing_file(self):
        errors = check_id_uniqueness.check_ids(
            "/nonexistent/path/*.json", ["items"], "item"
        )
        self.assertEqual(errors, [])

    def test_detects_cross_file_duplicates(self):
        """Verify shared existing_ids catches duplicates across files."""
        f1 = self._write_json("a.json", {
            "items": [{"id": "potion"}, {"id": "ether"}]
        })
        f2 = self._write_json("b.json", {
            "items": [{"id": "potion"}]  # duplicate of f1
        })
        shared_ids: dict[str, str] = {}
        errors = check_id_uniqueness.check_ids(f1, ["items"], "item", shared_ids)
        self.assertEqual(errors, [])
        errors = check_id_uniqueness.check_ids(f2, ["items"], "item", shared_ids)
        self.assertEqual(len(errors), 1)
        self.assertIn("DUPLICATE", errors[0])
        self.assertIn("potion", errors[0])

    def test_dialogue_ids_no_duplicates(self):
        """Verify check_dialogue_ids works with actual project data."""
        # This test runs against real data if available
        if not os.path.exists("game/data/dialogue"):
            self.skipTest("No dialogue data available")
        errors = check_id_uniqueness.check_dialogue_ids()
        self.assertEqual(errors, [], f"Found duplicates: {errors}")


class TestCheckStaleCounts(unittest.TestCase):
    """Tests for Gate E: Stale-count scan."""

    def test_count_actual_data_returns_dict(self):
        """Verify count function returns expected keys."""
        counts = check_stale_counts.count_actual_data()
        self.assertIsInstance(counts, dict)
        # These keys should always exist (directories exist)
        self.assertIn("encounter_files", counts)
        self.assertIn("shop_files", counts)

    def test_count_matches_filesystem(self):
        """Verify encounter file count matches glob."""
        import glob
        counts = check_stale_counts.count_actual_data()
        actual = len(glob.glob("game/data/encounters/*.json"))
        self.assertEqual(counts.get("encounter_files", 0), actual)

    def test_check_gap_tracker_no_stale(self):
        """Run against real gap tracker — should pass if data is current."""
        if not os.path.exists("docs/analysis/game-dev-gaps.md"):
            self.skipTest("No gap tracker available")
        counts = check_stale_counts.count_actual_data()
        errors = check_stale_counts.check_gap_tracker(counts)
        self.assertEqual(errors, [], f"Stale counts: {errors}")

    def test_detects_stale_count(self):
        """Verify detection of mismatched counts."""
        counts = {"encounter_files": 99}  # wrong count
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".md", delete=False
        ) as f:
            f.write("There are 27 encounter files in the project.\n")
            f.flush()
            errors = check_stale_counts.check_gap_tracker(counts, f.name)
        os.unlink(f.name)
        self.assertEqual(len(errors), 1)
        self.assertIn("STALE COUNT", errors[0])
        self.assertIn("27", errors[0])
        self.assertIn("99", errors[0])


class TestCheckSceneRefs(unittest.TestCase):
    """Tests for Gate F: Scene reference validation."""

    def test_valid_scene_passes(self):
        """Run against real scene files — should pass."""
        if not os.path.exists("game/scenes"):
            self.skipTest("No scene files available")
        errors = check_scene_refs.check_scene_references()
        self.assertEqual(errors, [], f"Missing refs: {errors}")

    def test_detects_missing_reference(self):
        """Verify detection of broken resource path."""
        tmpdir = tempfile.mkdtemp()
        scenes_dir = os.path.join(tmpdir, "game", "scenes", "test")
        os.makedirs(scenes_dir)

        tscn = os.path.join(scenes_dir, "test.tscn")
        with open(tscn, "w") as f:
            f.write('[ext_resource path="res://nonexistent.gd" id="1"]\n')

        # Patch glob to find our test scene
        with patch("check_scene_refs.glob.glob", return_value=[tscn]):
            errors = check_scene_refs.check_scene_references()
            self.assertEqual(len(errors), 1)
            self.assertIn("missing resource", errors[0])


MAGIC_FIXTURE = """# Magic System

## Status Effect Reference

| Status | Effect |
|--------|--------|
| Poison | Lose 8% max HP per turn |
| Burn | Lose 5% max HP per turn |

## Spell Count Summary

Eighty-nine spells, and nothing else worth saying.
"""


class TestCheckDocCitations(unittest.TestCase):
    """Tests for Gate G: doc citation integrity."""

    def setUp(self):
        self.cwd = os.getcwd()
        self.tmpdir = tempfile.mkdtemp()
        self._write("docs/story/magic.md", MAGIC_FIXTURE)
        os.chdir(self.tmpdir)

    def tearDown(self):
        os.chdir(self.cwd)
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def _write(self, rel: str, text: str) -> None:
        full = os.path.join(self.tmpdir, rel)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w") as f:
            f.write(text)

    def _errors(self, known: dict | None = None) -> list[str]:
        """Run the whole scan against the fixture repo."""
        with patch.dict(
            check_doc_citations.KNOWN_UNRESOLVED, known or {}, clear=True
        ):
            return check_doc_citations.check_citations()

    def test_bans_line_anchored_citation(self):
        self._write("game/scripts/a.gd", "# Poison 8%/turn (magic.md:1537).\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("banned line-anchored citation", errors[0])
        self.assertIn("magic.md:1537", errors[0])

    def test_bans_line_anchored_gd_citation(self):
        self._write("docs/story/note.md", "See `status_effects.gd:25`.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("status_effects.gd:25", errors[0])

    def test_accepts_heading_citation_with_term(self):
        self._write(
            "game/scripts/a.gd",
            "# Poison (magic.md § Status Effect Reference > 'Poison').\n",
        )
        self.assertEqual(self._errors(), [])

    def test_rejects_unknown_heading(self):
        self._write(
            "game/scripts/a.gd", "# See magic.md § Nonexistent Heading.\n"
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("names no heading", errors[0])

    def test_rejects_term_absent_from_the_cited_section(self):
        """The term must sit under the cited heading, not merely in the file."""
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Spell Count Summary > 'Poison'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_rejects_term_that_lives_in_a_later_section(self):
        """The search stops at the next heading, so a term below it fails."""
        self._write(
            "game/scripts/a.gd",
            "# See magic.md § Status Effect Reference > 'Eighty-nine'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("does not appear under", errors[0])

    def test_a_citation_does_not_steal_the_next_ones_term(self):
        """`a.md § X; a.md § Y > 'z'` must not read 'z' as X's term."""
        self._write(
            "game/scripts/a.gd",
            "# magic.md § Spell Count Summary; "
            "magic.md § Status Effect Reference > 'Poison'.\n",
        )
        self.assertEqual(self._errors(), [])

    def test_rejects_unknown_target_file(self):
        self._write("game/scripts/a.gd", "# See nosuchdoc.md § Whatever.\n")
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("not a file in this repo", errors[0])

    def test_checks_every_citation_on_a_line(self):
        """A second citation on the same line is checked, not swallowed."""
        self._write(
            "game/scripts/a.gd",
            "# magic.md § Status Effect Reference > 'Poison'; "
            "magic.md § Spell Count Summary > 'Eighty-nine'.\n",
        )
        self.assertEqual(self._errors(), [])
        self._write(
            "game/scripts/a.gd",
            "# magic.md § Status Effect Reference > 'Poison'; "
            "magic.md § Spell Count Summary > 'Ninety-one'.\n",
        )
        errors = self._errors()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("Ninety-one", errors[0])

    def test_ignores_dated_records(self):
        """docs/issues and docs/superpowers describe the tree as it was."""
        self._write("docs/issues/rot.md", "Broke at magic.md:1537.\n")
        self._write("docs/superpowers/plan.md", "Broke at magic.md:1537.\n")
        self.assertEqual(self._errors(), [])

    def test_ignores_fenced_examples_in_markdown(self):
        self._write(
            "docs/story/guide.md",
            "How to cite:\n\n```markdown\nrelevant_doc.md § Section Name\n```\n",
        )
        self.assertEqual(self._errors(), [])

    def test_known_unresolved_entry_suppresses_its_own_citation(self):
        self._write("game/scripts/a.gd", "# See magic.md § Ghost Section.\n")
        known = {
            ("game/scripts/a.gd", "magic.md § Ghost Section."): "#0 — pinned",
        }
        self.assertEqual(self._errors(known), [])

    def test_stale_known_unresolved_entry_fails(self):
        """The ratchet cannot rot either: a pin with nothing to pin fails."""
        known = {
            ("game/scripts/gone.gd", "magic.md § Ghost Section."): "#0 — pinned",
        }
        errors = self._errors(known)
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("stale entry in KNOWN_UNRESOLVED", errors[0])


class TestIntegration(unittest.TestCase):
    """Integration tests — run all gates against real project data."""

    def test_full_id_scan_passes(self):
        """Full ID uniqueness scan should pass on current data."""
        if not os.path.exists("game/data"):
            self.skipTest("No game data available")
        result = check_id_uniqueness.main()
        self.assertEqual(result, 0)

    def test_full_stale_scan_passes(self):
        """Full stale-count scan should pass on current data."""
        if not os.path.exists("docs/analysis/game-dev-gaps.md"):
            self.skipTest("No gap tracker available")
        result = check_stale_counts.main()
        self.assertEqual(result, 0)

    def test_full_scene_scan_passes(self):
        """Full scene reference scan should pass on current data."""
        if not os.path.exists("game/scenes"):
            self.skipTest("No scene files available")
        result = check_scene_refs.main()
        self.assertEqual(result, 0)

    def test_full_citation_scan_passes(self):
        """Full doc citation scan should pass on current data."""
        if not os.path.exists("docs/story"):
            self.skipTest("No design docs available")
        result = check_doc_citations.main()
        self.assertEqual(result, 0)


if __name__ == "__main__":
    unittest.main()
