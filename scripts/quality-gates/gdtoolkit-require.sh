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
# The pin lives in gdtoolkit-version.txt beside this file. CI installs that
# version (.github/workflows/static-gates.yml) and /godot-tooling-updates bumps
# it. Both read it the same way: the file with all whitespace stripped. This
# helper only QUOTES the pin; it does not compare the installed version.

GDTOOLKIT_VERSION_FILE="$(git rev-parse --show-toplevel)/scripts/quality-gates/gdtoolkit-version.txt"

# gdtoolkit_require <tool> <gate label>
gdtoolkit_require() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    fi
    # 2>/dev/null comes first so a missing pin file prints no raw shell error.
    gdtoolkit_pin=$(tr -d '[:space:]' 2>/dev/null <"$GDTOOLKIT_VERSION_FILE" || true)
    [ -n "$gdtoolkit_pin" ] || gdtoolkit_pin="<unreadable: $GDTOOLKIT_VERSION_FILE>"
    echo "ERROR: $1 NOT FOUND, and staged .gd files need it ($2)." >&2
    echo "  Install the pinned gdtoolkit $gdtoolkit_pin:" >&2
    echo "    pip install \"gdtoolkit==$gdtoolkit_pin\"" >&2
    echo "  Refusing to commit GDScript that was never checked: a missing" >&2
    echo "  tool is not a pass (#472)." >&2
    return 1
}
