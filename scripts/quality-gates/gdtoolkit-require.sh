# shellcheck shell=sh
# Sourced by .husky/pre-commit for Gates A (gdlint) and C (gdformat).
#
# POSIX sh, not bash: husky runs every hook as `sh -e <hook>` (.husky/_/h)
# whatever its shebang says, and on Linux that sh is dash.
#
# Until #472 both gates sat inside `if command -v <tool>` with no else, so a
# machine without gdtoolkit committed unlinted, unformatted GDScript and the
# hook exited 0 having checked nothing. A missing tool is not a pass: when .gd
# files are staged and the tool is absent, gdtoolkit_require prints the install
# command for the pinned version and returns 1. The caller only asks when .gd
# files are staged, so a commit touching no GDScript still passes on a machine
# without gdtoolkit.
#
# A tool at another version is not a pass either (#477). CI installs exactly
# the pin and checks with it, and formatter rules move between releases, so a
# change gdformat 4.4 calls clean could fail Static Gates after the push.
# gdtoolkit_require compares `<tool> --version` with "<tool> <pin>", the same
# string comparison .github/workflows/static-gates.yml makes, and returns 1
# with both versions and the install command when they differ.
#
# The pin lives in gdtoolkit-version.txt beside this file. CI installs that
# version and /godot-tooling-updates bumps it. All three read it the same way:
# the file with all whitespace stripped.

GDTOOLKIT_VERSION_FILE="$(git rev-parse --show-toplevel)/scripts/quality-gates/gdtoolkit-version.txt"

# Sets gdtoolkit_pin to the pin, or to a placeholder naming the file when it is
# missing or empty. 2>/dev/null comes first so a missing pin file prints no raw
# shell error.
gdtoolkit_read_pin() {
    gdtoolkit_pin=$(tr -d '[:space:]' 2>/dev/null <"$GDTOOLKIT_VERSION_FILE" || true)
    [ -n "$gdtoolkit_pin" ] || gdtoolkit_pin="<unreadable: $GDTOOLKIT_VERSION_FILE>"
}

# gdtoolkit_require <tool> <gate label>
gdtoolkit_require() {
    gdtoolkit_read_pin
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: $1 NOT FOUND, and staged .gd files need it ($2)." >&2
        echo "  Install the pinned gdtoolkit $gdtoolkit_pin:" >&2
        echo "    pip install \"gdtoolkit==$gdtoolkit_pin\"" >&2
        echo "  Refusing to commit GDScript that was never checked: a missing" >&2
        echo "  tool is not a pass (#472)." >&2
        return 1
    fi
    gdtoolkit_got=$("$1" --version 2>&1 || true)
    if [ "$gdtoolkit_got" = "$1 $gdtoolkit_pin" ]; then
        return 0
    fi
    echo "ERROR: $1 VERSION MISMATCH, and staged .gd files need it ($2)." >&2
    echo "  installed: $gdtoolkit_got" >&2
    echo "  pinned:    $1 $gdtoolkit_pin" >&2
    echo "  Install the pinned gdtoolkit $gdtoolkit_pin:" >&2
    echo "    pip install \"gdtoolkit==$gdtoolkit_pin\"" >&2
    echo "  CI checks with the pin (static-gates.yml), so a commit this version" >&2
    echo "  calls clean can still fail there (#477)." >&2
    return 1
}
