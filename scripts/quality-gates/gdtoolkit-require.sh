# shellcheck shell=bash
# Sourced by .husky/pre-commit for Gates A (gdlint) and C (gdformat).
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
# it. This helper only QUOTES it; it does not compare the installed version.

GDTOOLKIT_VERSION_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/gdtoolkit-version.txt"

# gdtoolkit_require <tool> <gate label>
gdtoolkit_require() {
    local tool="$1" gate="$2" version
    if command -v "$tool" >/dev/null 2>&1; then
        return 0
    fi
    version=$(tr -d '[:space:]' <"$GDTOOLKIT_VERSION_FILE" 2>/dev/null || true)
    [ -n "$version" ] || version="<unreadable: $GDTOOLKIT_VERSION_FILE>"
    echo "ERROR: $tool NOT FOUND, and staged .gd files need it ($gate)." >&2
    echo "  Install the pinned gdtoolkit $version:" >&2
    echo "    pip install \"gdtoolkit==$version\"" >&2
    echo "  Refusing to commit GDScript that was never checked: a missing" >&2
    echo "  tool is not a pass (#472)." >&2
    return 1
}
