#!/usr/bin/env python3
"""Re-encode legacy TileMap tile data as TileMapLayer byte arrays (#449).

Every map scene used to store its `tile_map_data` in one of two legacy
TileMap int layouts, which TileMapLayer rejects, so every layer loaded with
zero cells. Both layouts are 3 ints per cell, with int0 = x | (y << 16):

  dict : {"format": 3, "tile_data": PackedInt32Array(pos, 0, idx, ...)}
  pia  : PackedInt32Array(pos, idx, 0, ...)

In both, `idx` is the column of the one-row placeholder atlas, i.e. source 0,
atlas (idx, 0), alternative 0. Neither is valid legacy TileMap FORMAT_3 either,
so the meaning comes from how the scenes were authored, not from the engine.

The output is what TileMapLayer.set_tile_map_data_from_array() reads: a u16 LE
format header (0), then 12-byte LE cells (i16 x, i16 y, u16 source_id,
u16 atlas_x, u16 atlas_y, u16 alternative), written as
`PackedByteArray("<base64>")`. That is the form Godot's own saver writes for
a byte array over 64 bytes, and it bumps the scene header from format=3 to
format=4 when it does, so this script does the same. Nothing else in the file
changes: only the value after `tile_map_data = ` and the header's format=.

It refuses anything it cannot read unambiguously: an unknown layout, an int
count not divisible by 3, a negative or out-of-range position, the "other"
int of a cell not being 0, an index the TileSet does not define, a duplicate
cell, or a layer whose own [node] section lacks a tile_set ExtResource to the
placeholder TileSet (a SubResource or missing tile_set is refused). A value that
is already a PackedByteArray is left alone, so a second run converts nothing.

Usage, from the repo root:
  python3 tools/convert_tile_map_data.py           # report only
  python3 tools/convert_tile_map_data.py --write   # rewrite the scenes

Nothing runs this for you; pre-push Gate N (check_tile_map_data.py) is what
rejects a legacy layout if one is ever written again.
"""
import argparse
import base64
import os
import re
import struct
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GAME_ROOT = os.path.join(REPO_ROOT, "game")
TILESET_RES = "res://assets/tilesets/placeholder_dungeon.tres"

LINE_RE = re.compile(r"^tile_map_data = (.*)$", re.M)
PIA_RE = re.compile(r"^PackedInt32Array\(([-0-9, ]*)\)$")
DICT_RE = re.compile(r'^\{"format": 3, "tile_data": PackedInt32Array\(([-0-9, ]*)\)\}$')
HEADER_RE = re.compile(r"\A(\[gd_scene [^\]\n]*?)format=3\b")
EXT_RE = re.compile(r'^\[ext_resource [^\]]*path="([^"]+)"[^\]]*id="([^"]+)"', re.M)
TILE_SET_RE = re.compile(r'^tile_set = ExtResource\("([^"]+)"\)$', re.M)


def tileset_columns(game_root):
    """Atlas columns (atlas_x, row 0, alternative 0) the placeholder TileSet defines."""
    path = os.path.join(game_root, TILESET_RES[len("res://"):])
    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    return {int(m.group(1)) for m in re.finditer(r"^(\d+):0/0 = 0$", text, re.M)}


def decode(value, columns):
    """Return (layout name, [cells]) for a legacy value, or raise ValueError."""
    match = DICT_RE.match(value)
    layout = "dict"
    if not match:
        match = PIA_RE.match(value)
        layout = "pia"
    if not match:
        raise ValueError("unrecognized tile_map_data layout: %r" % value[:60])
    body = match.group(1)
    ints = [int(v) for v in body.split(",")] if body.strip() else []
    if not ints or len(ints) % 3:
        raise ValueError("%d ints is not a whole number of cells" % len(ints))
    cells, seen = [], set()
    for i in range(0, len(ints), 3):
        pos, a, b = ints[i:i + 3]
        if pos < 0:
            raise ValueError("negative packed position %d" % pos)
        x, y = pos & 0xFFFF, (pos >> 16) & 0xFFFF
        if x >= 0x8000 or y >= 0x8000:
            raise ValueError("position %d is outside int16 range" % pos)
        idx, other = (b, a) if layout == "dict" else (a, b)
        if other != 0:
            raise ValueError("%s layout expects a 0 beside the index, got %d" % (layout, other))
        if idx not in columns:
            raise ValueError("tile index %d is not defined in %s" % (idx, TILESET_RES))
        if (x, y) in seen:
            raise ValueError("cell %s is painted twice" % ((x, y),))
        seen.add((x, y))
        cells.append((x, y, 0, idx, 0, 0))
    return layout, cells


def encode(cells):
    """TileMapLayer FORMAT_0 bytes for `cells`, and the .tscn value text."""
    raw = struct.pack("<H", 0) + b"".join(struct.pack("<hhHHHH", *c) for c in cells)
    return raw, 'PackedByteArray("%s")' % base64.b64encode(raw).decode("ascii")


def convert_text(src, columns, rel):
    """Return (new text, [(layout, cells, bytes)]) for one scene's text."""
    hits = [m for m in LINE_RE.finditer(src) if not m.group(1).startswith("PackedByteArray(")]
    if not hits:
        return src, []
    ext = {ident: path for path, ident in EXT_RE.findall(src)}
    out, last, report = [], 0, []
    for match in hits:
        # Judge each layer by its own [node] section, so a SubResource or
        # missing tile_set is refused even when another layer is fine.
        start = src.rfind("\n[", 0, match.start()) + 1
        end = src.find("\n[", match.end())
        section = src[start:] if end < 0 else src[start:end]
        sets = TILE_SET_RE.findall(section)
        if len(sets) != 1 or ext.get(sets[0]) != TILESET_RES:
            raise ValueError(
                "%s: the layer at %r has no tile_set = ExtResource(...) to %s"
                % (rel, src[start:src.find("\n", start)], TILESET_RES)
            )
        layout, cells = decode(match.group(1), columns)
        raw, text = encode(cells)
        out.extend([src[last:match.start(1)], text])
        last = match.end(1)
        report.append((layout, len(cells), len(raw)))
    out.append(src[last:])
    new = HEADER_RE.sub(r"\1format=4", "".join(out), count=1)
    if not re.match(r"\[gd_scene [^\]\n]*\bformat=4\b", new):
        raise ValueError("%s: scene header carries neither format=3 nor format=4" % rel)
    return new, report


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("--write", action="store_true", help="rewrite the scenes in place")
    args = parser.parse_args(argv)
    columns = tileset_columns(GAME_ROOT)
    converted = 0
    for dirpath, dirnames, filenames in os.walk(os.path.join(GAME_ROOT, "scenes")):
        dirnames.sort()
        for name in sorted(filenames):
            if not name.endswith(".tscn"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, REPO_ROOT)
            with open(path, encoding="utf-8", newline="") as handle:
                src = handle.read()
            new, report = convert_text(src, columns, rel)
            for layout, cells, size in report:
                print("%-58s %-4s cells=%-5d bytes=%d" % (rel, layout, cells, size))
                converted += 1
            if args.write and new != src:
                with open(path, "w", encoding="utf-8", newline="") as handle:
                    handle.write(new)
    print("%s %d layer(s)" % ("converted" if args.write else "would convert", converted))
    return 0


if __name__ == "__main__":
    sys.exit(main())
