#!/usr/bin/env python3
"""Tests for Quality Gate N: TileMapLayer tile data integrity.

Gate N is a scan, and a scan that has stopped detecting reports "nothing
found", which reads exactly like "nothing wrong" (#365). These run under
Gate I's discovery, so a Gate N that has stopped detecting fails at pre-push.

The two legacy layouts are pinned verbatim from the pre-#449 scenes, the walk
is tested two directories deep (every real map layer lives at least one level
below game/scenes/), and the hook wiring test rejects a commented-out call.
A layer with no tile_map_data line and one with a duplicated line are each
pinned by their own test.
Each tile_set resolution branch (missing, undeclared ExtResource or SubResource,
unreadable, inline, two inline TileSets) and
each unloadable encoding (bad base64, a byte above 255, not a byte array) is
pinned by its own test.

Run: python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py'
"""
import base64
import os
import re
import shutil
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import check_tile_map_data as gate  # noqa: E402

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
GATE_SCRIPT = "check_tile_map_data.py"

TILESET = """[gd_resource type="TileSet" load_steps=2 format=3]

[sub_resource type="TileSetAtlasSource" id="Src0"]
texture_region_size = Vector2i(16, 16)
0:0/0 = 0
1:0/0 = 0
1:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)

[resource]
tile_size = Vector2i(16, 16)
sources/0 = SubResource("Src0")
"""

SCENE = """[gd_scene load_steps=2 format=3]

[ext_resource type="TileSet" path="res://ts.tres" id="1_ts"]

[node name="Map" type="Node2D"]

[node name="TileMapLayer" type="TileMapLayer" parent="."]
tile_set = ExtResource("1_ts")
%s
[node name="PlayerSpawn" type="Marker2D" parent="."]
position = Vector2(24, 24)
"""


def encode(cells, header=0):
    raw = struct.pack("<H", header) + b"".join(struct.pack("<hhHHHH", *c) for c in cells)
    return 'tile_map_data = PackedByteArray("%s")\n' % base64.b64encode(raw).decode()


GOOD = [(0, 0, 0, 1, 0, 0), (1, 0, 0, 0, 0, 0)]


def uncommented(text):
    """`text` with comment-only lines dropped (see test_gut_baseline.py)."""
    return "\n".join(line for line in text.splitlines() if not line.strip().startswith("#"))


def gate_run_lines(text):
    """Uncommented lines that run Gate N through python3, directly or via a variable."""
    names = [re.escape(GATE_SCRIPT)]
    for var in re.findall(r'^\s*([A-Za-z_]\w*)="[^"]*%s"' % re.escape(GATE_SCRIPT), text, re.M):
        names.append(r"\$\{?%s\}?" % re.escape(var))
    pattern = re.compile(r"python3\b.*(?:%s)" % "|".join(names))
    return [line for line in uncommented(text).splitlines() if pattern.search(line)]


class GateFixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.game = os.path.join(self.tmp, "game")
        os.makedirs(os.path.join(self.game, "scenes", "maps", "towns"))
        with open(os.path.join(self.game, "ts.tres"), "w", encoding="utf-8") as f:
            f.write(TILESET)

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def scene(self, data_line, rel="scenes/maps/towns/a.tscn"):
        path = os.path.join(self.game, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(SCENE % data_line)
        return path

    def errors(self, min_layers=1):
        return gate.check_tree(os.path.join(self.game, "scenes"), self.game, min_layers)[3]


class TestLegacyLayoutsAreRejected(GateFixture):
    def test_packed_int32_layout_from_the_dungeon_scenes_is_rejected(self):
        self.scene("tile_map_data = PackedInt32Array(0, 1, 0, 1, 1, 0)\n")
        errs = self.errors()
        self.assertEqual(len(errs), 1, errs)
        self.assertIn("legacy TileMap int layout", errs[0])

    def test_format3_dictionary_layout_from_the_town_scenes_is_rejected(self):
        self.scene('tile_map_data = {"format": 3, "tile_data": PackedInt32Array(0, 0, 1)}\n')
        self.assertIn("legacy TileMap int layout", self.errors()[0])

    def test_a_layer_whose_data_line_a_resave_deleted_is_reported(self):
        self.scene("")
        self.assertIn("0 tile_map_data lines", self.errors()[0])

    def test_a_layer_with_a_duplicated_data_line_is_reported(self):
        # A bad merge resolution can leave two values; Godot silently keeps the last.
        line = encode(GOOD)
        self.scene(line + line)
        errs = self.errors()
        self.assertEqual(len(errs), 1, errs)
        self.assertIn("2 tile_map_data lines", errs[0])
        self.assertIn("keeps only the last", errs[0])


class TestOverridesOfInstancedLayers(GateFixture):
    def test_a_legacy_value_on_a_typeless_override_is_rejected(self):
        path = os.path.join(self.game, "scenes", "maps", "towns", "chunk.tscn")
        with open(path, "w", encoding="utf-8") as f:
            f.write(
                '[gd_scene format=3]\n\n'
                '[ext_resource type="PackedScene" path="res://base.tscn" id="1"]\n\n'
                '[node name="Root" type="Node2D"]\n\n'
                '[node name="Base" parent="." instance=ExtResource("1")]\n\n'
                '[node name="TileMapLayer" parent="Base"]\n'
                "tile_map_data = PackedInt32Array(0, 1, 0)\n"
            )
        errs = self.errors(min_layers=0)
        self.assertEqual(len(errs), 1, errs)
        self.assertIn("chunk.tscn:TileMapLayer", errs[0])
        self.assertIn("legacy TileMap int layout", errs[0])

    def test_a_valid_value_on_a_typeless_override_passes_and_is_not_a_layer(self):
        path = os.path.join(self.game, "scenes", "maps", "towns", "chunk.tscn")
        with open(path, "w", encoding="utf-8") as f:
            f.write(
                '[gd_scene format=3]\n\n'
                '[node name="Root" type="Node2D"]\n\n'
                '[node name="TileMapLayer" parent="Base"]\n' + encode(GOOD)
            )
        scenes, layers, cells, errs = gate.check_tree(os.path.join(self.game, "scenes"), self.game, 0)
        self.assertEqual((layers, cells, errs), (0, 2, []))


class TestByteLayout(GateFixture):
    def test_valid_base64_layer_passes_and_counts_its_cells(self):
        self.scene(encode(GOOD))
        scenes, layers, cells, errs = gate.check_tree(os.path.join(self.game, "scenes"), self.game, 1)
        self.assertEqual((scenes, layers, cells, errs), (1, 1, 2, []))

    def test_decimal_byte_list_is_accepted(self):
        raw = struct.pack("<H", 0) + struct.pack("<hhHHHH", *GOOD[0])
        self.scene("tile_map_data = PackedByteArray(%s)\n" % ", ".join(str(b) for b in raw))
        self.assertEqual(self.errors(), [])

    def test_nonzero_format_header_is_rejected(self):
        self.scene(encode(GOOD, header=1))
        self.assertIn("format header 1", self.errors()[0])

    def test_a_partial_cell_is_rejected(self):
        line = encode(GOOD)
        raw = base64.b64decode(re.search(r'"(.*)"', line).group(1))[:-1]
        self.scene('tile_map_data = PackedByteArray("%s")\n' % base64.b64encode(raw).decode())
        self.assertIn("not whole 12-byte cells", self.errors()[0])

    def test_an_empty_byte_array_is_rejected(self):
        self.scene("tile_map_data = PackedByteArray()\n")
        self.assertIn("holds no cells", self.errors()[0])

    def test_a_layer_header_holding_an_array_attribute_is_still_read(self):
        # `[node ... groups=["walls"]]` holds a "]" before the closing one; a
        # header pattern that stopped at the first "]" skipped the layer.
        path = self.scene("tile_map_data = PackedInt32Array(0, 1, 0)\n")
        with open(path, encoding="utf-8") as f:
            text = f.read()
        text = text.replace('type="TileMapLayer" parent="."]', 'type="TileMapLayer" parent="." groups=["walls"]]')
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        errs = self.errors()
        self.assertEqual(len(errs), 1, errs)
        self.assertIn("legacy TileMap int layout", errs[0])

    def test_a_cell_painted_twice_is_rejected(self):
        self.scene(encode([GOOD[0], GOOD[0]]))
        self.assertIn("painted twice", self.errors()[0])


class TestCellsResolveAgainstTheTileSet(GateFixture):
    def test_undefined_atlas_tile_is_rejected(self):
        self.scene(encode([(0, 0, 0, 7, 0, 0)]))
        self.assertIn("atlas (7, 0)", self.errors()[0])

    def test_undefined_source_is_rejected(self):
        self.scene(encode([(0, 0, 3, 0, 0, 0)]))
        self.assertIn("source 3", self.errors()[0])

    def test_undefined_alternative_is_rejected(self):
        self.scene(encode([(0, 0, 0, 1, 0, 2)]))
        self.assertIn("alternative 2", self.errors()[0])


INLINE_SCENE = """[gd_scene load_steps=3 format=3]

[sub_resource type="TileSetAtlasSource" id="Src0"]
0:0/0 = 0

[sub_resource type="TileSet" id="TS"]
sources/0 = SubResource("Src0")

[node name="Map" type="Node2D"]

[node name="TileMapLayer" type="TileMapLayer" parent="."]
tile_set = SubResource("TS")
%s"""


class TestTheTileSetResolves(GateFixture):
    def rewrite(self, old, new, data_line=None):
        path = self.scene(data_line or encode(GOOD))
        with open(path, encoding="utf-8") as f:
            text = f.read()
        self.assertIn(old, text)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text.replace(old, new))

    def test_a_layer_with_no_tile_set_is_rejected(self):
        self.rewrite('tile_set = ExtResource("1_ts")\n', "")
        self.assertIn("has no tile_set", self.errors()[0])

    def test_an_undeclared_ext_resource_is_rejected(self):
        self.rewrite('ExtResource("1_ts")', 'ExtResource("9_missing")')
        self.assertIn("is not declared", self.errors()[0])

    def test_a_tile_set_file_that_cannot_be_read_is_rejected(self):
        self.rewrite("res://ts.tres", "res://gone.tres")
        self.assertIn("cannot be read", self.errors()[0])

    def inline(self, cells):
        path = os.path.join(self.game, "scenes", "maps", "towns", "a.tscn")
        with open(path, "w", encoding="utf-8") as f:
            f.write(INLINE_SCENE % encode(cells))

    def test_an_inline_tile_set_is_read(self):
        self.inline([(0, 0, 0, 0, 0, 0)])
        self.assertEqual(self.errors(), [])

    def test_a_cell_the_inline_tile_set_lacks_is_rejected(self):
        self.inline([(0, 0, 0, 5, 0, 0)])
        self.assertIn("atlas (5, 0)", self.errors()[0])

    def test_an_undeclared_sub_resource_is_rejected(self):
        path = os.path.join(self.game, "scenes", "maps", "towns", "a.tscn")
        with open(path, "w", encoding="utf-8") as f:
            f.write((INLINE_SCENE % encode([(0, 0, 0, 0, 0, 0)])).replace('SubResource("TS")', 'SubResource("Nope")'))
        self.assertIn("SubResource Nope is not declared", self.errors()[0])

    def test_a_cell_is_judged_against_the_inline_tile_set_its_layer_names(self):
        # TS_B, declared after TS_A, defines atlas (5, 0); TS, the one the
        # layer names, does not. The cell must be judged against TS.
        path = os.path.join(self.game, "scenes", "maps", "towns", "a.tscn")
        second = (
            '[sub_resource type="TileSetAtlasSource" id="SrcB"]\n5:0/0 = 0\n\n'
            '[sub_resource type="TileSet" id="TS_B"]\nsources/0 = SubResource("SrcB")\n\n'
            '[node name="Map"'
        )
        with open(path, "w", encoding="utf-8") as f:
            f.write((INLINE_SCENE % encode([(0, 0, 0, 5, 0, 0)])).replace('[node name="Map"', second))
        self.assertIn("atlas (5, 0)", self.errors()[0])


class TestUnloadableEncodingsAreRejected(GateFixture):
    def test_base64_that_does_not_decode_is_rejected(self):
        self.scene('tile_map_data = PackedByteArray("AAA")\n')
        self.assertIn("base64 does not decode", self.errors()[0])

    def test_a_decimal_byte_above_255_is_rejected(self):
        self.scene("tile_map_data = PackedByteArray(0, 0, 256)\n")
        self.assertIn("above 255", self.errors()[0])

    def test_a_value_that_is_not_a_byte_array_is_rejected(self):
        self.scene("tile_map_data = 42\n")
        self.assertIn("is not a PackedByteArray", self.errors()[0])


class TestTheWalk(GateFixture):
    def test_a_violation_two_directories_deep_is_found(self):
        self.scene(encode(GOOD))
        self.scene("tile_map_data = PackedInt32Array(0, 1, 0)\n", rel="scenes/maps/dungeons/deep/b.tscn")
        self.assertTrue(any("deep/b.tscn" in e for e in self.errors(min_layers=2)))

    def test_too_few_layers_fails_the_floor(self):
        self.scene(encode(GOOD))
        self.assertIn("Repair the walk", self.errors(min_layers=2)[0])

    def test_a_missing_scenes_root_fails_rather_than_passing_empty(self):
        errs = gate.check_tree(os.path.join(self.tmp, "nope"), self.game, 0)[3]
        self.assertIn("nothing was inspected", errs[0])


class TestRealTree(unittest.TestCase):
    def setUp(self):
        self._cwd = os.getcwd()
        os.chdir(REPO_ROOT)

    def tearDown(self):
        os.chdir(self._cwd)

    def test_every_real_map_layer_passes_and_the_scan_meets_its_floor(self):
        scenes, layers, cells, errs = gate.check_tree()
        self.assertEqual(errs, [])
        self.assertGreaterEqual(layers, gate.MIN_LAYERS)
        self.assertGreater(cells, 0)

    def test_pre_push_runs_gate_n_on_an_uncommented_line(self):
        with open(".husky/pre-push", encoding="utf-8") as f:
            hook = f.read()
        self.assertTrue(gate_run_lines(hook), "no uncommented Gate N invocation in .husky/pre-push")
        self.assertIn("#   N  TileMapLayer tile data     pre-push   check_tile_map_data.py", hook)
        self.assertIn("QUALITY GATE N: TileMapLayer tile data", hook)
        self.assertTrue(gate.__doc__.startswith("Quality Gate N: TileMapLayer tile data integrity."))

    def test_the_wiring_matcher_rejects_a_commented_out_call(self):
        hook = '# python3 "$GATE_DIR/check_tile_map_data.py"\necho done\n'
        self.assertEqual(gate_run_lines(hook), [])
        self.assertEqual(len(gate_run_lines('python3 "$GATE_DIR/check_tile_map_data.py"\n')), 1)


if __name__ == "__main__":
    unittest.main()
