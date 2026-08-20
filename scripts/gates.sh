#!/usr/bin/env bash
# Local quality-gate runner: everything .husky/pre-push runs, plus the
# static gates from .husky/pre-commit, without needing a commit or a push.
#
#   bash scripts/gates.sh                      # from any worktree root
#   GATES_BASE=<ref> bash scripts/gates.sh     # judge a stacked branch on ITS commits
#   GATES_FORCE_GODOT=1 bash scripts/gates.sh  # run Godot even for a docs-only diff
#   GATES_MAX_GODOT=<n> bash scripts/gates.sh  # concurrent headless-Godot ceiling
#
# Why this exists as well as the hooks: the hooks judge what you are pushing,
# this judges a working tree, and agents working in parallel worktrees need the
# second. It also serializes Godot, which the hooks do not.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
NAME="$(basename "$ROOT")"
GODOT_APP="/Applications/Godot.app/Contents/MacOS/Godot"
GODOT="${GODOT_BIN:-}"
[ -z "$GODOT" ] && command -v godot >/dev/null 2>&1 && GODOT="godot"
[ -z "$GODOT" ] && [ -x "$GODOT_APP" ] && GODOT="$GODOT_APP"
LOCK="/tmp/pod-godot.lock"
BASE="${GATES_BASE:-main}"
MAX_GODOT="${GATES_MAX_GODOT:-1}"
FAIL=0
say() { echo "[$NAME] $*"; }

BASELINE_FILE="scripts/quality-gates/gut-baseline.txt"
MIN_SCRIPTS=$(grep -E '^scripts=' "$BASELINE_FILE" 2>/dev/null | cut -d= -f2)
MIN_TESTS=$(grep -E '^tests=' "$BASELINE_FILE" 2>/dev/null | cut -d= -f2)
if [ -z "${MIN_SCRIPTS:-}" ] || [ -z "${MIN_TESTS:-}" ]; then
  say "cannot read floors from $BASELINE_FILE — refusing to run rather than pass vacuously"
  exit 1
fi

# --diff-filter=d drops DELETED paths. Without it a branch that removes a .gd
# hands the dead path to gdformat/gdlint, which fail on a file that is gone.
CHANGED=$(git diff --name-only --diff-filter=d "$BASE"...HEAD 2>/dev/null)
CHANGED_GD=$(echo "$CHANGED"   | grep -E '\.gd$'   || true)
CHANGED_JSON=$(echo "$CHANGED" | grep -E '\.json$' || true)
CHANGED_GAME=$(echo "$CHANGED" | grep -E '^game/'  || true)

if [ -n "$CHANGED_GD" ]; then
  say "gdformat --check"; gdformat --check $CHANGED_GD || { say "GDFORMAT FAILED"; FAIL=1; }
  say "gdlint";           gdlint $CHANGED_GD          || { say "GDLINT FAILED"; FAIL=1; }
fi
if [ -n "$CHANGED_JSON" ]; then
  say "json validation"
  for f in $CHANGED_JSON; do [ -f "$f" ] || continue
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" || { say "INVALID JSON: $f"; FAIL=1; }
  done
fi

# Every gate script in the directory, so a new gate is covered the day it lands
# rather than the day someone remembers to add it to a list here.
say "python quality gates"
for G in scripts/quality-gates/check_*.py; do
  [ -f "$G" ] || continue
  python3 "$G" || { say "$(basename "$G") FAILED"; FAIL=1; }
done
say "quality-gate self-tests"
python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py' -q \
  || { say "GATE SELF-TESTS FAILED"; FAIL=1; }

[ $FAIL -ne 0 ] && { say "STATIC GATES FAILED — fix before running Godot"; exit 1; }

# Fast path: no game/ change usually means GUT results cannot move. EXCEPT that
# several suites READ repo docs and assert on their contents, so a docs-only
# diff genuinely can turn the suite red. Discover which docs by grepping the
# tests, so the list cannot rot the way a hardcoded one would.
DOCS_READ=$(grep -rhoE '(docs/[A-Za-z0-9_/-]+\.md)' game/tests/ 2>/dev/null | sort -u)
DOC_TRIGGER=""
for d in $DOCS_READ; do echo "$CHANGED" | grep -qxF "$d" && DOC_TRIGGER="$DOC_TRIGGER $d"; done
[ -z "$CHANGED_GAME" ] && [ -n "$DOC_TRIGGER" ] && say "docs-only diff, but the suite reads:$DOC_TRIGGER — running Godot"
if [ -z "$CHANGED_GAME" ] && [ -z "$DOC_TRIGGER" ] && [ "${GATES_FORCE_GODOT:-0}" != "1" ]; then
  say "STATIC GATES PASSED — no game/ file and no test-read doc changed vs $BASE, skipping Godot"
  say "  (GATES_FORCE_GODOT=1 to override)"
  exit 0
fi

if [ -z "$GODOT" ]; then
  say "Godot not found (set GODOT_BIN, or install to $GODOT_APP) — refusing to"
  say "report success on a tree whose GUT suite was never run"
  exit 1
fi

# A killed agent used to leave the lock held and wedge every sibling for the
# full timeout. The owner PID makes a dead holder's lock reclaimable.
reap_stale_lock() {
  [ -d "$LOCK" ] || return 0
  local owner; owner=$(cat "$LOCK/owner.pid" 2>/dev/null || echo "")
  if [ -z "$owner" ] || ! kill -0 "$owner" 2>/dev/null; then
    say "reaping stale lock (owner ${owner:-unknown} is gone)"; rm -rf "$LOCK"
  fi
}
say "waiting for godot lock..."; WAITED=0; reap_stale_lock
until mkdir "$LOCK" 2>/dev/null; do
  sleep 10; WAITED=$((WAITED+10)); reap_stale_lock
  [ $WAITED -gt 1800 ] && { say "LOCK TIMEOUT after 30m"; exit 1; }
done
echo "$$" > "$LOCK/owner.pid"; trap 'rm -rf "$LOCK" 2>/dev/null' EXIT
say "lock acquired (waited ${WAITED}s)"

# We hold the mutex, so any live headless Godot belongs to a dead agent. Two
# headless Godots importing one project is how .import sidecars get written
# valid=false, which is sticky and survives deleting .godot.
ORPHANS=$(pgrep -f "Godot.*--headless" 2>/dev/null | grep -v "^$$\$" || true)
if [ -n "$ORPHANS" ]; then
  say "WARNING: orphaned headless Godot: $(echo "$ORPHANS" | tr '\n' ' ')"
  for P in $ORPHANS; do
    [ "$(ps -o ppid= -p "$P" 2>/dev/null | tr -d ' ')" = "1" ] && { say "  killing orphan $P"; kill -TERM "$P" 2>/dev/null; }
  done
  sleep 3
  STILL=$(pgrep -cf "Godot.*--headless" 2>/dev/null || echo 0)
  [ "${STILL:-0}" -ge "$MAX_GODOT" ] && { say "ABORT: $STILL headless Godot running, ceiling $MAX_GODOT"; exit 1; }
fi

say "godot import"
"$GODOT" --headless --path game/ --import > "/tmp/import_$NAME.log" 2>&1 || {
  say "GODOT IMPORT FAILED — see /tmp/import_$NAME.log"; tail -30 "/tmp/import_$NAME.log"; exit 1; }

say "GUT suite"
"$GODOT" --headless --path game/ -s addons/gut/gut_cmdln.gd 2>&1 | sed 's/\x1b\[[0-9;]*m//g' > "/tmp/gut_$NAME.log"
SCRIPTS=$(grep -E "^Scripts " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1)
TESTS=$(grep -E "^Tests " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1)
PASSING=$(grep -E "^Passing Tests " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1)
FAILING=$(grep -E "^Failing Tests " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1); FAILING=${FAILING:-0}
say "RESULT scripts=$SCRIPTS tests=$TESTS passing=$PASSING failing=$FAILING (floors $MIN_SCRIPTS/$MIN_TESTS)"

if [ "${FAILING:-0}" != "0" ]; then
  say "GUT FAILURES:"; grep -nE "^\s+\[Failed\]" "/tmp/gut_$NAME.log" | head -30; exit 1; fi
if [ -z "$SCRIPTS" ] || [ "$SCRIPTS" -lt "$MIN_SCRIPTS" ]; then
  say "SCRIPT COUNT REGRESSION: $SCRIPTS < $MIN_SCRIPTS — a test file is being SILENTLY SKIPPED (parse error),"
  say "  or you removed one on purpose and owe $BASELINE_FILE an update."
  grep -iE "Ignoring script|SCRIPT ERROR|Parse Error" "/tmp/gut_$NAME.log" | head -20; exit 1; fi
if [ -z "$TESTS" ] || [ "$TESTS" -lt "$MIN_TESTS" ]; then
  say "TEST COUNT REGRESSION: $TESTS < $MIN_TESTS — tests disappeared,"
  say "  or you removed some on purpose and owe $BASELINE_FILE an update."; exit 1; fi

say "ALL GATES PASSED"
