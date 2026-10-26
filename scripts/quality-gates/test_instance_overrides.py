#!/usr/bin/env python3
"""Tests for Quality Gate M: instanced-child edits survive an editor save.

Gate M is a scan, and a scan that has stopped detecting reports "nothing
found", which reads exactly like "nothing wrong" (#365). These tests run
under Gate I's discovery, so a gate that has stopped detecting fails at
pre-push rather than passing silently.

The fixture rules mirror what Godot 4.8 actually does on an editor save,
measured on this repo for #450: an override inside a non-[editable] instance
is deleted, a node added under an instance's internal child is deleted, a node
added directly under an instance root survives, and an override of a node the
instanced scene lacks is dropped at load with a "has vanished" warning.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
Or:  python3 scripts/quality-gates/test_instance_overrides.py
"""
import contextlib
import io
import os
import re
import shutil
import sys
import tempfile
import unittest
from unittest import mock

sys.path.insert(0, os.path.dirname(__file__))
import check_instance_overrides as gate  # noqa: E402

REPO_ROOT = gate.REPO_ROOT

PREFAB = """[gd_scene format=3]

[sub_resource type="RectangleShape2D" id="S"]
size = Vector2(16, 16)

[node name="Zone" type="StaticBody2D"]

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("S")
"""

MAP_HEAD = """[gd_scene format=3]

[ext_resource type="PackedScene" path="res://scenes/entities/zone.tscn" id="1_zone"]

[sub_resource type="RectangleShape2D" id="Big"]
size = Vector2(64, 32)

[node name="Map" type="Node2D" groups=["maps"]]

[node name="Entities" type="Node2D" parent="."]

[node name="Barrier" parent="Entities" instance=ExtResource("1_zone")]
position = Vector2(320, 64)
"""

OVERRIDE = """
[node name="CollisionShape2D" parent="Entities/Barrier" index="1"]
shape = SubResource("Big")
"""

EDITABLE = '\n[editable path="Entities/Barrier"]\n'

# A scene inheriting zone.tscn: its root instances the base.
INHERITED = (
    '[gd_scene format=3]\n\n[ext_resource type="PackedScene" '
    'path="res://scenes/entities/zone.tscn" id="1"]\n\n'
    '[node name="ZoneVariant" instance=ExtResource("1")]\n'
)


class GateFixture(unittest.TestCase):
    """A miniature res:// tree: one prefab and maps two directories down."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.res = os.path.join(self.tmp, "game")
        self.scenes = os.path.join(self.res, "scenes")
        self.write("scenes/entities/zone.tscn", PREFAB)
        patcher = mock.patch.object(gate, "RES_ROOT", self.res)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.addCleanup(shutil.rmtree, self.tmp)

    def write(self, rel, text):
        path = os.path.join(self.res, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(text)
        return path

    def run_gate(self, min_scenes=1):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            code = gate.main(self.scenes, min_scenes=min_scenes)
        return code, out.getvalue()

    def map(self, body):
        return self.write("scenes/maps/dungeons/floor.tscn", MAP_HEAD + body)


class TestEditorSaveRules(GateFixture):
    def test_an_override_inside_a_non_editable_instance_fails(self):
        self.map(OVERRIDE)
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("'Entities/Barrier/CollisionShape2D' overrides", out)
        self.assertIn('[editable path="Entities/Barrier"]', out)

    def test_an_override_inside_an_editable_instance_passes(self):
        self.map(OVERRIDE + EDITABLE)
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)
        self.assertIn("1 typeless overrides", out)

    def test_editable_naming_a_different_instance_does_not_count(self):
        self.map(OVERRIDE + '\n[editable path="Entities/Other"]\n')
        self.assertEqual(self.run_gate()[0], 1)

    def test_a_node_added_under_an_internal_child_fails(self):
        self.map('\n[node name="Glow" type="Node2D" parent="Entities/Barrier/Sprite2D"]\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("adds a node under the inside of instance 'Entities/Barrier'", out)

    def test_a_node_added_under_a_child_the_instance_lacks_fails(self):
        self.map(EDITABLE + '\n[node name="Glow" type="Node2D" parent="Entities/Barrier/NoSuchChild"]\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("is added under 'NoSuchChild', which res://scenes/entities/zone.tscn does not have", out)

    def test_a_node_added_directly_under_an_instance_root_passes(self):
        self.map('\n[node name="Marker" type="Marker2D" parent="Entities/Barrier"]\n')
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_an_override_of_a_node_the_instance_lacks_fails(self):
        self.map(OVERRIDE.replace('name="CollisionShape2D"', 'name="Hitbox"') + EDITABLE)
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("overrides 'Hitbox', which res://scenes/entities/zone.tscn does not have", out)

    def test_a_typeless_node_inside_no_instance_fails(self):
        self.map('\n[node name="Ghost" parent="Entities"]\nposition = Vector2(1, 1)\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("inside no instance", out)

    def test_a_typed_node_under_a_parent_the_scene_lacks_names_the_missing_parent(self):
        self.map('\n[node name="Marker" type="Marker2D" parent="Entitiez"]\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("'Entitiez/Marker' has parent 'Entitiez', which this scene does not create", out)
        self.assertNotIn("typeless", out)

    def test_an_inherited_scene_may_override_its_base(self):
        self.write(
            "scenes/entities/zone_variant.tscn",
            '[gd_scene format=3]\n\n[ext_resource type="PackedScene" '
            'path="res://scenes/entities/zone.tscn" id="1"]\n\n'
            '[node name="ZoneVariant" instance=ExtResource("1")]\n\n'
            '[node name="Sprite2D" parent="." index="0"]\nvisible = false\n',
        )
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_an_inherited_scene_overriding_a_node_its_base_lacks_fails(self):
        self.write("scenes/entities/zone_variant.tscn", INHERITED + '\n[node name="Ghost" parent="."]\nvisible = false\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("overrides 'Ghost', which res://scenes/entities/zone.tscn does not have", out)

    def test_an_inherited_scene_adding_under_a_parent_its_base_lacks_fails(self):
        self.write(
            "scenes/entities/zone_variant.tscn",
            INHERITED + '\n[node name="Kid" type="Node2D" parent="NoSuchParent"]\n',
        )
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("is added under 'NoSuchParent'", out)

    def test_a_header_with_an_array_attribute_is_read(self):
        # The first prototype's header regex could not read groups=["..."]
        # and skipped player_character.tscn's root without a word.
        self.map(OVERRIDE)
        scene = gate.Scene(os.path.join(self.scenes, "maps/dungeons/floor.tscn"))
        self.assertIn(".", scene.nodes)
        self.assertEqual(scene.errors, [])

    def test_an_unreadable_node_header_fails_rather_than_being_skipped(self):
        self.map('\n[node parent="Entities"]\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("[node] without name", out)

    def test_a_node_header_that_does_not_parse_fails_rather_than_being_skipped(self):
        self.map('\n[node name="X" type="Node2D" parent="."\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("cannot parse header", out)

    def test_an_editable_entry_without_a_path_fails(self):
        # EDITABLE makes the override itself legal, so the bare [editable] is the only fault.
        self.map(OVERRIDE + EDITABLE + "\n[editable]\n")
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("[editable] without path", out)

    def test_an_ext_resource_header_that_does_not_parse_fails_rather_than_being_skipped(self):
        # An unread ext_resource leaves its instance unresolved, so every
        # override through it would be judged against nothing.
        self.map('\n[ext_resource type="PackedScene" path="res://scenes/entities/zone.tscn" id="2_zone"\n')
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("cannot parse header '[ext_resource", out)


OUTER = """[gd_scene format=3]

[ext_resource type="PackedScene" path="res://scenes/entities/zone.tscn" id="1_zone"]

[node name="Gate" type="Node2D"]

[node name="Inner" parent="." instance=ExtResource("1_zone")]
"""

NESTED_HEAD = """[gd_scene format=3]

[ext_resource type="PackedScene" path="res://scenes/entities/gate.tscn" id="1_gate"]

[node name="Map" type="Node2D"]

[node name="Entities" type="Node2D" parent="."]

[node name="Outer" parent="Entities" instance=ExtResource("1_gate")]
"""


class TestNestedInstances(GateFixture):
    def nested_map(self, child):
        self.write("scenes/entities/gate.tscn", OUTER)
        self.write(
            "scenes/maps/dungeons/floor.tscn",
            NESTED_HEAD
            + f'\n[node name="{child}" parent="Entities/Outer/Inner" index="1"]\n'
            + 'visible = false\n\n[editable path="Entities/Outer"]\n',
        )

    def test_an_override_reached_through_a_nested_instance_passes_when_the_inner_scene_has_it(self):
        self.nested_map("CollisionShape2D")
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_an_override_reached_through_a_nested_instance_fails_when_the_inner_scene_lacks_it(self):
        self.nested_map("Hitbox")
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn(
            "overrides 'Inner/Hitbox', which res://scenes/entities/gate.tscn does not have", out
        )

    def test_editable_is_required_on_the_nearest_instance_not_an_outer_one(self):
        self.map(
            '\n[node name="Inner" parent="Entities/Barrier" instance=ExtResource("1_zone")]\n'
            '\n[node name="CollisionShape2D" parent="Entities/Barrier/Inner" index="1"]\n'
            'visible = false\n' + EDITABLE
        )
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn(
            "overrides the inside of instance 'Entities/Barrier/Inner', which has no "
            '[editable path="Entities/Barrier/Inner"]',
            out,
        )


class TestTheWalk(GateFixture):
    def test_a_violation_two_directories_down_is_found(self):
        self.map(OVERRIDE)  # scenes/maps/dungeons/floor.tscn
        # min_scenes=0 so the floor cannot fail it: only the walk reaching
        # floor.tscn can produce this message.
        code, out = self.run_gate(min_scenes=0)
        self.assertEqual(code, 1)
        self.assertIn("maps/dungeons/floor.tscn", out)
        self.assertIn("'Entities/Barrier/CollisionShape2D' overrides", out)

    def test_too_few_scenes_fails_and_says_repair_the_walk(self):
        code, out = self.run_gate(min_scenes=5)
        self.assertEqual(code, 1)
        self.assertIn("repair the walk", out)

    def test_a_missing_scene_root_fails(self):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            code = gate.main(os.path.join(self.tmp, "nope"), min_scenes=0)
        self.assertEqual(code, 1)
        self.assertIn("is not a directory", out.getvalue())


class TestRealTree(unittest.TestCase):
    def test_the_real_scene_tree_passes_and_clears_the_floor(self):
        errors, scenes, _, instances, _ = gate.scan()
        self.assertEqual(errors, [])
        self.assertGreaterEqual(scenes, gate.MIN_SCENES)
        self.assertGreater(instances, 0)

    def test_the_fenmothers_hollow_zone_overrides_are_inspected(self):
        # #450's twelve overrides must be SEEN as overrides, not just absent
        # from the error list: a parser that stopped reading them would pass,
        # and so would a tree where a resave had already deleted them, which
        # the gate itself reads as clean. A floor, not an exact count, so a
        # legitimate new override does not break it.
        _, _, _, _, overrides = gate.scan()
        self.assertGreaterEqual(overrides, 12)


def gate_run_lines(text):
    """Uncommented lines that run Gate M (directly or through $GATE_DIR)."""
    pattern = re.compile(r"python3\b.*check_instance_overrides\.py")
    return [
        line.strip()
        for line in text.splitlines()
        if line.strip() and not line.strip().startswith("#") and pattern.search(line)
    ]


class TestWiring(unittest.TestCase):
    LIVE = 'python3 "$GATE_DIR/check_instance_overrides.py"'

    def _hook(self):
        with open(os.path.join(REPO_ROOT, ".husky", "pre-push"), encoding="utf-8") as handle:
            return handle.read()

    def test_the_matcher_counts_a_live_call(self):
        self.assertEqual(gate_run_lines(self.LIVE), [self.LIVE])

    def test_the_matcher_rejects_a_commented_out_call(self):
        self.assertEqual(gate_run_lines("# " + self.LIVE), [])

    def test_the_matcher_rejects_a_registry_mention(self):
        self.assertEqual(gate_run_lines("#   M  instanced-child edits    pre-push   check_instance_overrides.py"), [])

    def test_pre_push_runs_the_gate(self):
        self.assertTrue(gate_run_lines(self._hook()), "no uncommented Gate M call in .husky/pre-push")

    def test_the_gate_letter_registry_and_the_hook_agree(self):
        hook = self._hook()
        self.assertRegex(hook, r"#   M  .*check_instance_overrides\.py")
        self.assertIn("QUALITY GATE M", hook)
        self.assertTrue(gate.__doc__.startswith("Quality Gate M: "))


if __name__ == "__main__":
    unittest.main()
