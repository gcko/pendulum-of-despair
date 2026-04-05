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


def check_gap_tracker(
    counts: dict[str, int],
    gap_file: str = "docs/analysis/game-dev-gaps.md",
) -> list[str]:
    """Check gap tracker for stale count claims.

    Args:
        gap_file: Path to the gap tracker markdown file.
    """
    errors: list[str] = []

    try:
        with open(gap_file) as f:
            content = f.read()
    except FileNotFoundError:
        return []

    # Each tuple: (regex with capture group for claimed count, count key, label)
    checks: list[tuple[str, str, str]] = [
        (r"(\d+)\s+encounter file", "encounter_files", "encounter files"),
        (r"(\d+)\s+shop file", "shop_files", "shop files"),
        (r"(\d+)\s+device", "devices", "devices"),
        (r"(\d+)\s+synerg", "synergies", "synergies"),
        (r"(\d+)\s+forging", "forging_recipes", "forging recipes"),
        (r"(\d+)\s+(?:elemental\s+)?infusion", "infusions", "infusions"),
    ]

    for pattern, count_key, label in checks:
        m = re.search(pattern, content, re.IGNORECASE)
        if m:
            claimed = int(m.group(1))
            actual = counts.get(count_key, 0)
            if claimed != actual:
                errors.append(
                    f"STALE COUNT in {gap_file}: "
                    f"claims {claimed} {label}, actual {actual}"
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
