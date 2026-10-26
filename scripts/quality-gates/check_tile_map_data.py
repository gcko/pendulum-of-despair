#!/usr/bin/env python3
"""Quality Gate N: TileMapLayer tile data integrity.

Every TileMapLayer node in a scene under game/scenes/ must carry a
`tile_map_data` value TileMapLayer can actually load (#449):

  * written as a PackedByteArray, base64 (`PackedByteArray("...")`, the form
    Godot's saver emits for arrays over 64 bytes) or a decimal byte list;
  * a 2-byte little-endian format header equal to 0
    (TILE_MAP_LAYER_DATA_FORMAT_0), then whole 12-byte cells
    (i16 x, i16 y, u16 source_id, u16 atlas_x, u16 atlas_y, u16 alternative);
  * at least one cell, no cell painted twice;
  * every cell naming a source, atlas tile and alternative its TileSet defines.

Why: all 22 map layers once stored the legacy TileMap int layout
(`PackedInt32Array(...)` or `{"format": 3, "tile_data": ...}`). TileMapLayer
rejects both, so every map loaded with zero cells, and an editor resave then
deletes the line for good. A layer with NO tile_map_data line is reported too,
because that is exactly what such a resave leaves behind.

tools/convert_tile_map_data.py rewrote the 22 legacy layers and is the way to
re-encode one if it ever comes back.

THE LIMITS: this reads text. It does not run Godot, so it cannot see cells set
by a script at runtime, and it parses only TileSets referenced through an
ext_resource `.tres` or an inline sub_resource. It reads game/scenes/ only.
Whether the loaded walls leave the map playable is
game/tests/test_map_tile_layers.gd's job, not this one's. It runs in
.husky/pre-push and scripts/gates.sh; CI does not run the static Python gates.

Exit code 0 = pass, 1 = violations found (or the scan inspected too little).
"""
import base64
import binascii
import os
import re
import struct
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCENES_ROOT = os.path.join(REPO_ROOT, "game", "scenes")
GAME_ROOT = os.path.join(REPO_ROOT, "game")
# Floor on TileMapLayer nodes inspected. 22 map layers exist today, every one
# at least one directory below game/scenes/, so a walk that stops descending
# finds 0. If that happens, repair the walk. Lower this only in the commit
# that deliberately removes a map.
MIN_LAYERS = 22
CELL_SIZE = 12
HEADER = struct.Struct("<H")
CELL = struct.Struct("<hhHHHH")

NODE_RE = re.compile(r"^\[node (.*)\]\s*$")
SECTION_RE = re.compile(r"^\[")
ATTR_RE = re.compile(r'(\w+)=("(?:[^"\\]|\\.)*"|\S+)')
B64_RE = re.compile(r'^PackedByteArray\("([A-Za-z0-9+/=]*)"\)$')
DEC_RE = re.compile(r"^PackedByteArray\(([0-9,\s]*)\)$")
EXT_RE = re.compile(r'^\[ext_resource ([^\]]*)\]$')
SUB_RE = re.compile(r'^\[sub_resource ([^\]]*)\]$')
TILE_RE = re.compile(r"^(\d+):(\d+)/(\d+) = ")
SOURCE_RE = re.compile(r'^sources/(\d+) = SubResource\("([^"]+)"\)$')


def _attrs(text):
    return {k: v.strip('"') for k, v in ATTR_RE.findall(text)}


def _sections(lines):
    """Yield (header, [property lines]) for every [section] in a text resource."""
    header, body = None, []
    for line in lines:
        if SECTION_RE.match(line):
            if header is not None:
                yield header, body
            header, body = line, []
        elif header is not None:
            body.append(line)
    if header is not None:
        yield header, body


def parse_tileset(lines):
    """Return {source_id: {(atlas_x, atlas_y): {alternatives}}} from .tres/.tscn lines."""
    subs, sources, current = {}, {}, None
    for header, body in _sections(lines):
        m = SUB_RE.match(header)
        if m:
            current = _attrs(m.group(1)).get("id")
            tiles = subs.setdefault(current, {})
            for line in body:
                t = TILE_RE.match(line)
                if t:
                    key = (int(t.group(1)), int(t.group(2)))
                    tiles.setdefault(key, set()).add(int(t.group(3)))
        if header.startswith("[resource]") or header.startswith("[sub_resource"):
            for line in body:
                s = SOURCE_RE.match(line)
                if s:
                    sources[int(s.group(1))] = s.group(2)
    return {sid: subs.get(ref, {}) for sid, ref in sources.items()}


def decode_value(value):
    """Return (bytes, None) for a loadable PackedByteArray, or (None, reason)."""
    m = B64_RE.match(value)
    if m:
        try:
            return base64.b64decode(m.group(1), validate=True), None
        except binascii.Error as exc:
            return None, "base64 does not decode (%s)" % exc
    m = DEC_RE.match(value)
    if m:
        parts = [p for p in m.group(1).replace(" ", "").split(",") if p]
        nums = [int(p) for p in parts]
        if any(n > 255 for n in nums):
            return None, "decimal PackedByteArray holds a value above 255"
        return bytes(nums), None
    if value.startswith("PackedInt32Array(") or value.startswith("{"):
        return None, (
            "legacy TileMap int layout (%s...) - TileMapLayer rejects it and the "
            "layer loads EMPTY (#449); re-encode it as a PackedByteArray" % value[:24]
        )
    return None, "tile_map_data is not a PackedByteArray (%s...)" % value[:24]


def check_cells(raw, tileset):
    """Return (cell_count, [problems]) for decoded tile_map_data bytes."""
    problems = []
    if len(raw) < HEADER.size + CELL_SIZE:
        return 0, ["holds no cells (%d bytes)" % len(raw)]
    (fmt,) = HEADER.unpack_from(raw, 0)
    if fmt != 0:
        problems.append("format header %d, TileMapLayer only loads 0" % fmt)
        return 0, problems
    if (len(raw) - HEADER.size) % CELL_SIZE:
        problems.append("%d bytes after the header is not whole 12-byte cells" % (len(raw) - HEADER.size))
        return 0, problems
    seen = set()
    count = 0
    for off in range(HEADER.size, len(raw), CELL_SIZE):
        x, y, sid, ax, ay, alt = CELL.unpack_from(raw, off)
        count += 1
        if (x, y) in seen:
            problems.append("cell (%d, %d) painted twice" % (x, y))
        seen.add((x, y))
        if tileset is None:
            continue
        tiles = tileset.get(sid)
        if tiles is None:
            problems.append("cell (%d, %d) uses source %d the TileSet lacks" % (x, y, sid))
        elif (ax, ay) not in tiles:
            problems.append("cell (%d, %d) uses atlas (%d, %d) source %d lacks" % (x, y, ax, ay, sid))
        elif alt not in tiles[(ax, ay)]:
            problems.append("cell (%d, %d) uses alternative %d atlas (%d, %d) lacks" % (x, y, alt, ax, ay))
        if len(problems) > 20:
            problems.append("... (truncated)")
            break
    return count, problems


def _resolve_tileset(lines, tile_set_value, game_root):
    """Return (tileset dict or None, error or None) for a node's tile_set value."""
    m = re.match(r'^ExtResource\("([^"]+)"\)$', tile_set_value or "")
    if m:
        for header, _ in _sections(lines):
            e = EXT_RE.match(header)
            if e and _attrs(e.group(1)).get("id") == m.group(1):
                path = _attrs(e.group(1)).get("path", "")
                disk = os.path.join(game_root, path.replace("res://", "", 1))
                try:
                    with open(disk, encoding="utf-8") as handle:
                        return parse_tileset(handle.read().splitlines()), None
                except OSError as exc:
                    return None, "tile_set %s cannot be read (%s)" % (path, exc.strerror)
        return None, "tile_set ExtResource %s is not declared" % m.group(1)
    m = re.match(r'^SubResource\("([^"]+)"\)$', tile_set_value or "")
    if m:
        return parse_tileset(lines), None
    return None, "TileMapLayer has no tile_set"


def _rel(path):
    """`path` relative to the repo root when it is inside it, else as given."""
    rel = os.path.relpath(os.path.abspath(path), REPO_ROOT)
    return path if rel.startswith("..") else rel


def check_scene(path, game_root=GAME_ROOT):
    """Return (layers, cells, [errors]) for one .tscn file."""
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().splitlines()
    layers, cells, errors = 0, 0, []
    for header, body in _sections(lines):
        m = NODE_RE.match(header)
        if not m or _attrs(m.group(1)).get("type") != "TileMapLayer":
            continue
        layers += 1
        name = _attrs(m.group(1)).get("name", "?")
        props = {}
        for line in body:
            k, sep, v = line.partition(" = ")
            if sep:
                props.setdefault(k, []).append(v)
        where = "%s:%s" % (_rel(path), name)
        data = props.get("tile_map_data", [])
        if len(data) != 1:
            errors.append(
                "%s: %s tile_map_data lines - a layer with none loads empty, which is "
                "what an editor resave of a rejected value leaves behind (#449)" % (where, len(data))
            )
            continue
        raw, reason = decode_value(data[0])
        if raw is None:
            errors.append("%s: %s" % (where, reason))
            continue
        tileset, ts_err = _resolve_tileset(lines, (props.get("tile_set") or [None])[0], game_root)
        if ts_err:
            errors.append("%s: %s" % (where, ts_err))
        n, problems = check_cells(raw, tileset)
        cells += n
        errors.extend("%s: %s" % (where, p) for p in problems)
    return layers, cells, errors


def check_tree(scenes_root=SCENES_ROOT, game_root=GAME_ROOT, min_layers=MIN_LAYERS):
    """Walk scenes_root; return (scenes, layers, cells, [errors])."""
    scenes = layers = cells = 0
    errors = []
    if not os.path.isdir(scenes_root):
        return 0, 0, 0, ["%s is not a directory - nothing was inspected" % _rel(scenes_root)]
    for dirpath, dirnames, filenames in os.walk(scenes_root):
        dirnames.sort()
        for fn in sorted(filenames):
            if not fn.endswith(".tscn"):
                continue
            n_layers, n_cells, errs = check_scene(os.path.join(dirpath, fn), game_root)
            scenes += 1 if n_layers else 0
            layers += n_layers
            cells += n_cells
            errors.extend(errs)
    if layers < min_layers:
        errors.append(
            "inspected %d TileMapLayer nodes, floor is %d - the walk stopped "
            "descending or scenes vanished. Repair the walk; lower the floor only "
            "in the commit that deliberately removes a map." % (layers, min_layers)
        )
    return scenes, layers, cells, errors


def main():
    """Run Gate N. Returns 0 on pass, 1 on failure."""
    scenes, layers, cells, errors = check_tree()
    if errors:
        print("TileMapLayer tile data check FAILED:")
        for e in errors:
            print("  " + e)
        return 1
    print(
        "TileMapLayer tile data check passed: %d layers, %d cells across %d scenes."
        % (layers, cells, scenes)
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
