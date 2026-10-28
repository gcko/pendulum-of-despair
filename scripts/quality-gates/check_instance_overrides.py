#!/usr/bin/env python3
"""Quality Gate M: Instanced-child edits survive an editor save.

A `.tscn` can edit the inside of a scene it instances: a typeless
`[node name="CollisionShape2D" parent="Entities/Zone" index="1"]` header
overrides properties of the instanced scene's own child, and a typed node
whose parent is such a child adds a node inside the instance. Godot APPLIES
both at load time, so the game looks right. But the editor saves a scene by
packing the nodes the scene owns, and the inside of an instance is owned by
the instance, unless the instance is listed in `[editable path="..."]`.
Without that entry an editor save, or 4.8's "Upgrade All Project Files",
silently deletes the edit. That is #450: twelve Fenmother's Hollow zone
footprints reverted to their 16x16 prefab default on the first resave.

This gate fails when a scene under game/scenes/:

  * overrides a node inside an instance that has no matching [editable];
  * adds a node under an instance's internal child with no [editable];
  * reaches an edit through a nested instance without an [editable] entry
    for EVERY instance the node path enters: an outer instance's entry does
    not open the instance nested inside it (`Entities/Outer` and
    `Entities/Outer/Inner` both need one);
  * overrides, or adds a node under, a node the instanced scene does not
    have (Godot warns that the node "has vanished" and drops it); an
    inherited scene is held to its base the same way. An inherited scene's
    own base nodes need no [editable] entry, but nodes inside an instance
    nested in the base do (`[editable path="Inner"]`);
  * has a typeless node that is inside no instance at all;
  * has a typed node whose parent the scene neither creates nor instances;
  * has a [node], [editable] or [ext_resource] header it cannot parse (an
    unread header is a skipped one), or an [editable] entry with no path.

THE LIMITS, stated so nobody reads more into a pass than it means:

  * It checks that an edit will PERSIST, not that its value is right. The
    zone footprints are pinned by game/tests/test_map_zone_sizes.gd.
  * It cannot see an override a resave has ALREADY deleted: nothing is left
    in the file to flag, so that scene reads as clean. The real-tree self-test
    in test_instance_overrides.py holds a floor on the overrides inspected
    (>= 12, the Fenmother's Hollow zones), and test_map_zone_sizes.gd fails on
    the lost sizes; those two catch it, this gate does not.
  * It scans game/scenes/ only. No .tscn lives anywhere else under game/
    outside addons/ and .godot/ today; a scene added elsewhere is not read.
  * [connection] entries that target a node inside a non-editable instance
    are not checked (none exist today).
  * It runs in .husky/pre-push, scripts/gates.sh and
    .github/workflows/quality-gates.yml.

Exit code 0 = pass, 1 = violations found or too little was scanned.
"""
import os
import re
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCENES_ROOT = os.path.join(REPO_ROOT, "game", "scenes")
RES_ROOT = os.path.join(REPO_ROOT, "game")

# A walk that stopped descending would still enter game/scenes/ and report
# clean: no .tscn sits directly in it, and the maps are two levels down.
MIN_SCENES = 40

SECTION_RE = re.compile(
    r"^\[(gd_scene|gd_resource|ext_resource|sub_resource|node|connection|editable)\b(.*)\]\s*$"
)
ATTR_RE = re.compile(r'(\w+)=("(?:[^"\\]|\\.)*"|\w+\("(?:[^"\\]|\\.)*"\)|[^\s\]]+)')
EXT_ID_RE = re.compile(r'^ExtResource\("([^"]+)"\)$')


class Scene:
    """The node table of one .tscn, keyed by node path relative to its root."""

    def __init__(self, path):
        self.path = path
        self.rel = os.path.relpath(path, REPO_ROOT)
        self.ext = {}  # ext_resource id -> res:// path
        self.nodes = {}  # node path -> attrs
        self.order = []  # node paths in file order
        self.editable = set()
        self.errors = []
        self._parse()

    def _parse(self):
        with open(self.path, encoding="utf-8") as handle:
            for lineno, line in enumerate(handle, 1):
                if not line.startswith("["):
                    continue
                match = SECTION_RE.match(line.rstrip("\n"))
                if not match:
                    if line.startswith(("[node", "[editable", "[ext_resource")):
                        self.errors.append(f"{self.rel}:{lineno}: cannot parse header {line.strip()!r}")
                    continue
                kind, attrs = match.group(1), _attrs(match.group(2))
                if kind == "ext_resource" and "id" in attrs and "path" in attrs:
                    self.ext[attrs["id"]] = attrs["path"]
                elif kind == "editable":
                    if "path" not in attrs:
                        self.errors.append(f"{self.rel}:{lineno}: [editable] without path")
                    else:
                        self.editable.add(attrs["path"])
                elif kind == "node":
                    if "name" not in attrs:
                        self.errors.append(f"{self.rel}:{lineno}: [node] without name")
                        continue
                    attrs["_line"] = lineno
                    path = node_path(attrs)
                    self.nodes[path] = attrs
                    self.order.append(path)

    def instance_path(self, node):
        """res:// path a node instances, or None."""
        ref = self.nodes[node].get("instance")
        if ref is None:
            return None
        match = EXT_ID_RE.match(ref)
        return self.ext.get(match.group(1)) if match else None

    def owns(self, node):
        """True if this file creates `node` (root, typed, or instance root)."""
        if node == ".":
            return True
        attrs = self.nodes.get(node)
        return attrs is not None and ("type" in attrs or "instance" in attrs)


def _attrs(text):
    out = {}
    for key, value in ATTR_RE.findall(text):
        out[key] = value[1:-1] if value.startswith('"') else value
    return out


def node_path(attrs):
    parent = attrs.get("parent")
    if parent is None:
        return "."
    return attrs["name"] if parent == "." else f"{parent}/{attrs['name']}"


def ancestors(path):
    """Strict ancestors of a node path, nearest first, ending at '.'."""
    while path != ".":
        path = path.rsplit("/", 1)[0] if "/" in path else "."
        yield path


def res_to_fs(res_path):
    return os.path.join(RES_ROOT, res_path[len("res://"):]) if res_path.startswith("res://") else None


def has_node(res_path, rel, cache, depth=0):
    """True if the scene at res_path has a node at relative path `rel`.

    A path that runs through one of that scene's own instanced children is
    followed into the nested scene.
    """
    if rel == ".":
        return True
    fs = res_to_fs(res_path)
    if depth > 16 or fs is None or not os.path.isfile(fs):
        return False
    scene = cache.get(fs) or cache.setdefault(fs, Scene(fs))
    if scene.owns(rel):
        return True
    for anc in ancestors(rel):
        if anc != "." and anc in scene.nodes and scene.instance_path(anc):
            return has_node(scene.instance_path(anc), rel[len(anc) + 1:], cache, depth + 1)
    return False


def entered_instances(res_path, rel, cache, depth=0):
    """Instances inside the scene at res_path that node path `rel` enters.

    Uses has_node()'s lookup. An instance is ENTERED when `rel` runs strictly
    past its root into the nodes it owns; naming the instance node itself, or
    a node added directly under it, enters nothing. Paths are relative to the
    scene at res_path, outermost first.
    """
    if rel == ".":
        return []
    fs = res_to_fs(res_path)
    if depth > 16 or fs is None or not os.path.isfile(fs):
        return []
    scene = cache.get(fs) or cache.setdefault(fs, Scene(fs))
    if scene.owns(rel):
        return []
    for anc in ancestors(rel):
        if anc != "." and anc in scene.nodes and scene.instance_path(anc):
            inner = entered_instances(scene.instance_path(anc), rel[len(anc) + 1:], cache, depth + 1)
            return [anc] + [f"{anc}/{p}" for p in inner]
    return []


def missing_editable(scene, required, path, typeless, line):
    """One error per instance in `required` with no [editable] entry."""
    rel = os.path.relpath(scene.path, REPO_ROOT)
    what = "overrides" if typeless else "adds a node under"
    return [
        f"{rel}:{line}: '{path}' {what} the inside of instance '{inst}', "
        f'which has no [editable path="{inst}"]; an editor save deletes it'
        for inst in required
        if inst not in scene.editable
    ]


def check_scene(scene, cache):
    errors = list(scene.errors)
    rel = os.path.relpath(scene.path, REPO_ROOT)
    root_instance = scene.instance_path(".") if "." in scene.nodes else None
    instances = {p for p in scene.order if p != "." and scene.instance_path(p)}
    for path in scene.order:
        if path == ".":
            continue
        attrs = scene.nodes[path]
        typeless = "type" not in attrs and "instance" not in attrs
        parent = attrs["parent"]
        # The node itself lives inside an instance when it is typeless; a
        # typed node does when its PARENT is a node this file did not create.
        start = path if typeless else parent
        if not typeless and scene.owns(parent):
            continue
        chain = [a for a in ancestors(start) if a in instances]
        if not chain:
            if root_instance:
                # Inherited scene: the base's own nodes are editable without
                # an [editable] entry, but a node inside an instance nested in
                # the base is not, and the node (or its parent) must still
                # exist in the base, or Godot drops it as vanished.
                errors.extend(
                    missing_editable(
                        scene, entered_instances(root_instance, start, cache), path, typeless, attrs["_line"]
                    )
                )
                if not has_node(root_instance, start, cache):
                    what = "overrides" if typeless else "is added under"
                    errors.append(
                        f"{rel}:{attrs['_line']}: '{path}' {what} '{start}', which "
                        f"{root_instance} does not have; Godot drops it as vanished"
                    )
                continue
            if typeless:
                errors.append(
                    f"{rel}:{attrs['_line']}: '{path}' is a typeless node inside no instance, so it overrides nothing"
                )
            else:
                errors.append(
                    f"{rel}:{attrs['_line']}: '{path}' has parent '{parent}', which this scene does not "
                    f"create and no instance contains; Godot drops it as a vanished parent"
                )
            continue
        # The NEAREST instance this file declares needs [editable], and so
        # does every instance nested in it that the path enters: an outer
        # entry does not open an inner instance. Instances further out are
        # not entered (this file owns the nearest one), and whether that
        # instance node itself survives is judged when the loop reaches it.
        inst = chain[0]
        target = start[len(inst) + 1:]
        nested = entered_instances(scene.instance_path(inst), target, cache)
        required = [inst] + [f"{inst}/{p}" for p in nested]
        errors.extend(missing_editable(scene, required, path, typeless, attrs["_line"]))
        # `start` is the node itself (typeless) or its parent (typed); either
        # way it must exist inside the instanced scene, or Godot drops the node.
        if not has_node(scene.instance_path(inst), target, cache):
            what = "overrides" if typeless else "is added under"
            errors.append(
                f"{rel}:{attrs['_line']}: '{path}' {what} '{target}', which "
                f"{scene.instance_path(inst)} does not have; Godot drops it as vanished"
            )
    return errors, len(instances), sum(
        1 for p in scene.order if p != "." and "type" not in scene.nodes[p] and "instance" not in scene.nodes[p]
    )


def scan(root=SCENES_ROOT):
    """Return (errors, scenes scanned, nodes, instances, overrides)."""
    errors, scenes, nodes, instances, overrides = [], 0, 0, 0, 0
    cache = {}
    if not os.path.isdir(root):
        return [f"scene root {root} is not a directory"], 0, 0, 0, 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            if not name.endswith(".tscn"):
                continue
            fs = os.path.join(dirpath, name)
            scene = cache.get(fs) or cache.setdefault(fs, Scene(fs))
            found, n_inst, n_over = check_scene(scene, cache)
            errors.extend(found)
            scenes += 1
            nodes += len(scene.order)
            instances += n_inst
            overrides += n_over
    return errors, scenes, nodes, instances, overrides


def main(root=SCENES_ROOT, min_scenes=MIN_SCENES):
    errors, scenes, nodes, instances, overrides = scan(root)
    if scenes < min_scenes:
        errors.append(
            f"scanned only {scenes} scenes (floor {min_scenes}): repair the walk, do not lower the floor"
        )
    if errors:
        print("Instanced-child edit persistence FAILED:")
        for err in errors:
            print(f"  {err}")
        return 1
    print(
        f"Instanced-child edit persistence passed: {scenes} scenes, {nodes} nodes, "
        f"{instances} instances, {overrides} typeless overrides."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
