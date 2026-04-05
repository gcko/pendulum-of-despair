#!/usr/bin/env python3
"""Quality Gate D: Cross-file ID uniqueness scan.

Verifies no duplicate IDs exist across game data JSON files.
Each namespace (items, equipment, enemies, crafting, dialogue)
is checked independently.

Exit code 0 = pass, 1 = duplicates found.
"""
import json
import glob
import sys


def check_ids(
    pattern: str,
    key_path: list[str],
    namespace: str,
    existing_ids: dict[str, str] | None = None,
) -> list[str]:
    """Check ID uniqueness across files matching pattern.

    Args:
        existing_ids: Shared dict of already-seen IDs to their source file.
            Enables cross-file duplicate detection across multiple calls.
    """
    errors: list[str] = []
    all_ids: dict[str, str] = existing_ids if existing_ids is not None else {}

    for f in sorted(glob.glob(pattern)):
        try:
            with open(f) as fh:
                data = json.load(fh)
        except (json.JSONDecodeError, FileNotFoundError):
            continue

        items = data
        for k in key_path:
            if isinstance(items, dict) and k in items:
                items = items[k]
            else:
                items = []
                break

        if not isinstance(items, list):
            continue

        for item in items:
            if isinstance(item, dict) and "id" in item:
                item_id: str = item["id"]
                if item_id in all_ids:
                    errors.append(
                        f"DUPLICATE {namespace} ID '{item_id}': "
                        f"{all_ids[item_id]} and {f}"
                    )
                else:
                    all_ids[item_id] = f

    return errors


def check_enemy_ids() -> list[str]:
    """Check enemy ID uniqueness. Bosses intentionally duplicated."""
    errors: list[str] = []
    enemy_ids: dict[str, str] = {}

    for f in sorted(glob.glob("game/data/enemies/*.json")):
        try:
            with open(f) as fh:
                data = json.load(fh)
        except (json.JSONDecodeError, FileNotFoundError):
            continue

        if not data:
            continue
        key = list(data.keys())[0]
        for entry in data.get(key, []):
            eid: str = entry.get("id", "")
            # Bosses intentionally duplicated across act files and bosses.json
            if "bosses" in f:
                continue
            if eid in enemy_ids and "bosses" not in enemy_ids[eid]:
                errors.append(
                    f"DUPLICATE enemy ID '{eid}': "
                    f"{enemy_ids[eid]} and {f}"
                )
            else:
                enemy_ids[eid] = f

    return errors


def check_dialogue_ids() -> list[str]:
    """Check dialogue entry ID uniqueness across all files."""
    errors: list[str] = []
    dialogue_ids: dict[str, str] = {}

    for f in sorted(glob.glob("game/data/dialogue/*.json")):
        try:
            with open(f) as fh:
                data = json.load(fh)
        except (json.JSONDecodeError, FileNotFoundError):
            continue

        for entry in data.get("entries", []):
            did: str = entry.get("id", "")
            if did in dialogue_ids:
                errors.append(
                    f"DUPLICATE dialogue ID '{did}': "
                    f"{dialogue_ids[did]} and {f}"
                )
            else:
                dialogue_ids[did] = f

    return errors


def main() -> int:
    """Run all ID uniqueness checks. Returns 0 on pass, 1 on failure."""
    all_errors: list[str] = []

    # Item namespaces — shared dict catches cross-file duplicates
    item_ids: dict[str, str] = {}
    all_errors.extend(check_ids(
        "game/data/items/consumables.json", ["items"], "item", item_ids
    ))
    all_errors.extend(check_ids(
        "game/data/items/materials.json", ["items"], "item", item_ids
    ))
    all_errors.extend(check_ids(
        "game/data/items/key_items.json", ["items"], "item", item_ids
    ))

    # Equipment namespaces — shared dict catches cross-file duplicates
    equip_ids: dict[str, str] = {}
    all_errors.extend(check_ids(
        "game/data/equipment/weapons.json", ["weapons"], "equipment", equip_ids
    ))
    all_errors.extend(check_ids(
        "game/data/equipment/armor.json", ["armor"], "equipment", equip_ids
    ))
    all_errors.extend(check_ids(
        "game/data/equipment/accessories.json", ["accessories"], "equipment",
        equip_ids
    ))

    # Crafting — shared dict catches cross-file duplicates
    craft_ids: dict[str, str] = {}
    all_errors.extend(check_ids(
        "game/data/crafting/devices.json", ["devices"], "crafting", craft_ids
    ))
    all_errors.extend(check_ids(
        "game/data/crafting/synergies.json", ["synergies"], "crafting", craft_ids
    ))

    # Enemies and dialogue
    all_errors.extend(check_enemy_ids())
    all_errors.extend(check_dialogue_ids())

    if all_errors:
        print("Cross-file ID uniqueness FAILED:")
        for e in all_errors:
            print(f"  {e}")
        return 1

    print("Cross-file ID uniqueness passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
