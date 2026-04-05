#!/usr/bin/env python3
"""Tests for quality gate scripts.

Run: python3 -m pytest scripts/quality-gates/test_quality_gates.py -v
Or:  python3 scripts/quality-gates/test_quality_gates.py
"""
import json
import os
import tempfile
import unittest
from unittest.mock import patch

# Import the modules under test
import sys
sys.path.insert(0, os.path.dirname(__file__))
import check_id_uniqueness
import check_stale_counts
import check_scene_refs


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


if __name__ == "__main__":
    unittest.main()
