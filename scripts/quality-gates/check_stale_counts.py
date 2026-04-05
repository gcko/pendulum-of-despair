#!/usr/bin/env python3
"""Quality Gate E: Stale-count scan.

Verifies numeric count claims in the gap tracker match actual
data file counts. Catches mirror staleness — the #1 Copilot
catch pattern across PRs #109-113.

Exit code 0 = pass, 1 = stale counts found.
"""
import json
import glob
import re
import sys


def count_actual_data() -> dict[str, int]:
    """Count actual entries in all game data directories."""
    counts: dict[str, int] = {}

    counts["encounter_files"] = len(glob.glob("game/data/encounters/*.json"))
    counts["dialogue_files"] = len(glob.glob("game/data/dialogue/*.json"))
    counts["shop_files"] = len(glob.glob("game/data/shops/*.json"))

    for name, pattern, key in [
        ("devices", "game/data/crafting/devices.json", "devices"),
        ("synergies", "game/data/crafting/synergies.json", "synergies"),
    ]:
        try:
            with open(pattern) as f:
                data = json.load(f)
            counts[name] = len(data.get(key, []))
        except (FileNotFoundError, json.JSONDecodeError):
            pass

    try:
        with open("game/data/crafting/recipes.json") as f:
            data = json.load(f)
        counts["forging_recipes"] = len(data.get("forging_recipes", []))
        counts["infusions"] = len(data.get("infusions", []))
    except (FileNotFoundError, json.JSONDecodeError):
        pass

    return counts


def check_gap_tracker(counts: dict[str, int]) -> list[str]:
    """Check gap tracker for stale count claims."""
    errors: list[str] = []
    gap_file: str = "docs/analysis/game-dev-gaps.md"

    try:
        with open(gap_file) as f:
            content = f.read()
    except FileNotFoundError:
        return []

    checks: list[tuple[str, int, int]] = [
        (r"27 encounter file", 27, counts.get("encounter_files", 0)),
        (r"23 shop file", 23, counts.get("shop_files", 0)),
        (r"13 device", 13, counts.get("devices", 0)),
        (r"7 synerg", 7, counts.get("synergies", 0)),
        (r"9 forging", 9, counts.get("forging_recipes", 0)),
        (r"7 infusion", 7, counts.get("infusions", 0)),
    ]

    for pattern, expected, actual in checks:
        if re.search(pattern, content, re.IGNORECASE):
            if expected != actual:
                errors.append(
                    f"STALE COUNT in {gap_file}: "
                    f"claims {expected}, actual {actual} ({pattern})"
                )

    return errors


def main() -> int:
    """Run stale-count scan. Returns 0 on pass, 1 on failure."""
    counts: dict[str, int] = count_actual_data()
    errors: list[str] = check_gap_tracker(counts)

    if errors:
        print("Stale-count scan FAILED:")
        for e in errors:
            print(f"  {e}")
        return 1

    print("Stale-count scan passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
