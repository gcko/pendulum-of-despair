#!/usr/bin/env python3
"""Quality Gate F: Scene file reference validation.

Verifies all .tscn scene files reference scripts and textures
that actually exist on disk. Catches broken resource paths
before they reach runtime.

Exit code 0 = pass, 1 = missing references found.
"""
import glob
import os
import re
import sys


def check_scene_references() -> list[str]:
    """Verify all ext_resource paths in .tscn files resolve to real files."""
    errors: list[str] = []

    for tscn in glob.glob("game/scenes/**/*.tscn", recursive=True):
        with open(tscn) as f:
            content = f.read()

        for match in re.finditer(r'path="(res://[^"]+)"', content):
            res_path: str = match.group(1)
            file_path: str = "game/" + res_path.replace("res://", "")
            if not os.path.exists(file_path):
                errors.append(f"{tscn}: missing resource {res_path}")

    return errors


def main() -> int:
    """Run scene reference check. Returns 0 on pass, 1 on failure."""
    errors: list[str] = check_scene_references()

    if errors:
        print("Scene reference validation FAILED:")
        for e in errors:
            print(f"  {e}")
        return 1

    print("Scene reference validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
