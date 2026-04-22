#!/usr/bin/env python3
"""
Generate minimal silent .ogg placeholder files for all required audio assets.

Usage: python3 tools/generate_placeholder_audio.py [--force]

Pass --force to overwrite existing .ogg files. Without it, only missing
files are created (safe to re-run after real assets are added).

Requires ffmpeg (brew install ffmpeg) or sox (brew install sox).
Removes .gdkeep files from directories that receive real .ogg files.
"""

import os
import shutil
import subprocess
import sys
import tempfile

# Repo root is one level above this script (tools/)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)

GAME_ASSETS = os.path.join(REPO_ROOT, "game", "assets")

SFX_DIR = os.path.join(GAME_ASSETS, "sfx")
AMBIENT_DIR = os.path.join(GAME_ASSETS, "ambient")
MUSIC_DIR = os.path.join(GAME_ASSETS, "music")

# fmt: off
SFX_IDS = [
    # Combat (19)
    "hit_physical", "hit_magic", "miss", "critical", "guard",
    "heal", "status_apply", "status_remove", "ko_party", "ko_beast",
    "ko_undead", "ko_construct", "ko_spirit", "flee", "victory_fanfare",
    "level_up", "battle_onset_boss", "battle_onset_superboss", "phase_change",
    # UI (8)
    "cursor_move", "confirm", "cancel", "menu_open", "menu_close",
    "equip_change", "error_buzz", "save_confirm",
    # Exploration (8)
    "door_open", "chest_open", "save_point_chime", "encounter_trigger",
    "ley_crystal_obtain", "item_pickup", "rest_complete", "quest_complete",
    # Environmental (16)
    "ley_surge", "ley_rupture", "pallor_surge", "pallor_surge_final",
    "pallor_transform", "pallor_ambience", "alarm_bells", "wall_breach",
    "door_breach", "sword_draw", "weapon_forge", "machine_activate",
    "wind_quiet", "pendulum_shatter", "title_reveal", "drums_war",
]

AMBIENT_IDS = [
    "valdris_highlands", "carradan_industrial", "thornmere_forest",
    "thornmere_marsh", "mountain_windshear", "coastal", "underground_cave",
    "ley_line_depths", "factory_interior", "pallor_wastes",
    "town_generic", "sacred_sites",
]

MUSIC_IDS = [
    "title_theme", "overworld_act_i", "battle_standard",
    "battle_boss", "ember_vein",
]
# fmt: on

TARGETS = [
    (SFX_DIR, SFX_IDS),
    (AMBIENT_DIR, AMBIENT_IDS),
    (MUSIC_DIR, MUSIC_IDS),
]


def find_tool():
    """Return ('ffmpeg', path) or ('sox', path) or raise."""
    for name in ("ffmpeg", "sox"):
        path = shutil.which(name)
        if path:
            return name, path
    raise RuntimeError(
        "Neither ffmpeg nor sox found. Install one:\n"
        "  brew install ffmpeg\n"
        "  brew install sox"
    )


def make_silence_ogg(tool_name: str, tool_path: str, dest_path: str) -> None:
    """Generate a 0.1-second silent mono .ogg file at dest_path."""
    if tool_name == "ffmpeg":
        cmd = [
            tool_path,
            "-y",                          # overwrite without asking
            "-f", "lavfi",
            "-i", "anullsrc=r=44100:cl=mono",
            "-t", "0.1",
            "-c:a", "vorbis",
            "-strict", "-2",
            "-q:a", "0",
            dest_path,
        ]
    else:  # sox
        cmd = [
            tool_path,
            "-n",                          # null input
            "-r", "44100",
            "-c", "1",
            dest_path,
            "trim", "0.0", "0.1",
        ]
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(
            f"Failed to generate {dest_path}:\n"
            f"  stdout: {result.stdout.decode()}\n"
            f"  stderr: {result.stderr.decode()}"
        )


def main() -> int:
    force = "--force" in sys.argv
    tool_name, tool_path = find_tool()
    print(f"Using {tool_name} at {tool_path}")

    # Generate one master silence file then copy it
    silence_path: str = ""
    with tempfile.NamedTemporaryFile(suffix=".ogg", delete=False) as tmp:
        silence_path = tmp.name

    try:
        print("Generating master silence template...")
        make_silence_ogg(tool_name, tool_path, silence_path)

        total = 0
        for directory, ids in TARGETS:
            os.makedirs(directory, exist_ok=True)

            for asset_id in ids:
                dest = os.path.join(directory, f"{asset_id}.ogg")
                if os.path.exists(dest):
                    if not force:
                        continue
                    # Guard: warn when overwriting files larger than a placeholder
                    # (likely real audio assets, not 0.1s silence stubs)
                    existing_size = os.path.getsize(dest)
                    placeholder_size = os.path.getsize(silence_path)
                    if existing_size > placeholder_size * 2:
                        print(
                            f"  WARNING: Overwriting {dest} "
                            f"({existing_size} bytes > placeholder {placeholder_size} bytes)"
                        )
                shutil.copy2(silence_path, dest)
                total += 1

            # Remove .gdkeep now that real files exist
            gdkeep = os.path.join(directory, ".gdkeep")
            if os.path.exists(gdkeep):
                os.remove(gdkeep)
                print(f"  Removed {gdkeep}")

            ogg_count = len([f for f in os.listdir(directory) if f.endswith(".ogg")])
            print(f"  {directory}: {ogg_count} .ogg files")

        print(f"\nDone. Generated {total} placeholder .ogg files.")

    finally:
        if silence_path and os.path.exists(silence_path):
            os.unlink(silence_path)

    # Verify all required IDs exist (extras are OK — real assets may coexist)
    missing = []
    for directory, ids in TARGETS:
        for asset_id in ids:
            dest = os.path.join(directory, f"{asset_id}.ogg")
            if not os.path.exists(dest):
                missing.append(f"  MISSING: {dest}")
    if missing:
        print("\nERROR: Required audio files missing:")
        for m in missing:
            print(m)
        return 1

    print("\nVerification passed (all required IDs present):")
    for directory, ids in TARGETS:
        ogg_count = len([f for f in os.listdir(directory) if f.endswith(".ogg")])
        extra = ogg_count - len(ids)
        suffix = f" (+{extra} extra)" if extra > 0 else ""
        print(f"  {os.path.relpath(directory, REPO_ROOT)}: {len(ids)} required OK{suffix}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
