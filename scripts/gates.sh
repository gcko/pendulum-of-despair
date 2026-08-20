#!/usr/bin/env bash
# Local quality-gate runner: the static gates from .husky/pre-commit, the
# Python gates and GUT suite from .husky/pre-push, without needing a commit or
# a push.
#
#   bash scripts/gates.sh                      # from any worktree root
#   GATES_BASE=<ref> bash scripts/gates.sh     # judge a stacked branch on ITS commits
#   GATES_FORCE_GODOT=1 bash scripts/gates.sh  # run Godot even for a docs-only diff
#   GATES_MAX_GODOT=<n> bash scripts/gates.sh  # concurrent headless-Godot ceiling
#
# What it judges: everything in `$BASE...HEAD`, PLUS everything uncommitted —
# staged, unstaged and untracked. The hooks cannot see either of those (pre-commit
# sees only the index, pre-push only what you are pushing), and agents working in
# parallel worktrees need something that can. It also serializes Godot, which the
# hooks do not.
#
# What it is NOT: a replacement for the hooks. It does not run the pre-push
# data-integrity scans that live inside the hook itself, and nothing runs it for
# you. Both hooks still run on every commit and push.
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

# --- Floors -----------------------------------------------------------------
# A floor that is absent, duplicated, or non-numeric must stop the run. It used
# not to: `[ "$SCRIPTS" -lt abc ]` prints "integer expression expected" and
# evaluates FALSE, so a corrupted floor reported ALL GATES PASSED with the
# silent-skip guard switched off. Validate the shape before trusting it.
BASELINE_FILE="scripts/quality-gates/gut-baseline.txt"
# Diagnostics go to stderr: stdout is the return channel for the value.
read_floor() {
  local key="$1" hits value
  hits=$(grep -cE "^$key=" "$BASELINE_FILE" 2>/dev/null); hits=${hits:-0}
  if [ "$hits" -ne 1 ]; then
    say "$BASELINE_FILE: expected exactly one '$key=' line, found $hits" >&2; return 1
  fi
  value=$(grep -E "^$key=" "$BASELINE_FILE" | cut -d= -f2 | tr -d '[:space:]')
  case "$value" in
    ''|*[!0-9]*) say "$BASELINE_FILE: $key='$value' is not a number" >&2; return 1 ;;
  esac
  [ "$value" -gt 0 ] || { say "$BASELINE_FILE: $key=$value — a zero floor guards nothing" >&2; return 1; }
  echo "$value"
}
MIN_SCRIPTS=$(read_floor scripts) || { say "refusing to run rather than pass vacuously"; exit 1; }
MIN_TESTS=$(read_floor tests)     || { say "refusing to run rather than pass vacuously"; exit 1; }
MIN_GATES=$(read_floor gates)     || { say "refusing to run rather than pass vacuously"; exit 1; }
MIN_GATE_TESTS=$(read_floor gate_tests) || { say "refusing to run rather than pass vacuously"; exit 1; }

# --- What changed -----------------------------------------------------------
# An unresolvable BASE used to produce an empty CHANGED with its error swallowed
# by 2>/dev/null, which made every diff-derived gate vacuous while the script
# still exited 0 — and GATES_BASE is the hand-typed knob most likely to be wrong.
if ! git rev-parse --verify --quiet "$BASE^{commit}" >/dev/null; then
  say "GATES_BASE='$BASE' does not resolve to a commit — refusing to run rather than"
  say "judge an empty diff and call it green"
  exit 1
fi
if ! git merge-base "$BASE" HEAD >/dev/null 2>&1; then
  say "no merge base between '$BASE' and HEAD — refusing to judge an empty diff"
  exit 1
fi

# ALL_PATHS keeps DELETED paths, because deleting a test file is exactly the case
# that must still run Godot (the GUT floor is the only thing that notices it).
# LINT_PATHS is the subset that exists on disk, because gdformat/gdlint fail on a
# path that is gone. addons/ is excluded to match .husky/pre-commit, which skips
# vendored code — without that, any branch bumping game/addons/gut/ (i.e. every
# /godot-tooling-updates run) turns red on third-party formatting.
ALL_PATHS=$( { git diff --name-only "$BASE"...HEAD
               git diff --name-only HEAD
               git ls-files --others --exclude-standard; } | sort -u )
LINT_PATHS=$(while IFS= read -r f; do [ -n "$f" ] && [ -f "$f" ] && echo "$f"; done <<<"$ALL_PATHS" \
             | grep -v 'addons/' || true)
CHANGED_GD=$(echo "$LINT_PATHS"  | grep -E '\.gd$'   || true)
CHANGED_JSON=$(echo "$LINT_PATHS" | grep -E '\.json$' || true)
CHANGED_GAME=$(echo "$ALL_PATHS"  | grep -E '^game/'  || true)

if [ -n "$CHANGED_GD" ]; then
  say "gdformat --check ($(echo "$CHANGED_GD" | wc -l | tr -d ' ') file(s))"
  gdformat --check $CHANGED_GD || { say "GDFORMAT FAILED"; FAIL=1; }
  say "gdlint"; gdlint $CHANGED_GD || { say "GDLINT FAILED"; FAIL=1; }
fi
if [ -n "$CHANGED_JSON" ]; then
  say "json validation ($(echo "$CHANGED_JSON" | wc -l | tr -d ' ') file(s))"
  for f in $CHANGED_JSON; do
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" || { say "INVALID JSON: $f"; FAIL=1; }
  done
fi

# Every gate script in the directory, so a new gate is covered the day it lands
# rather than the day someone remembers to add it to a list here. The count is a
# floor and gets printed: a glob that matched nothing used to announce the stage
# and inspect zero files, which is the vacuous pass this script exists against.
GATE_COUNT=0
for G in scripts/quality-gates/check_*.py; do
  [ -f "$G" ] || continue
  GATE_COUNT=$((GATE_COUNT+1))
  python3 "$G" || { say "$(basename "$G") FAILED"; FAIL=1; }
done
say "python quality gates: $GATE_COUNT ran (floor $MIN_GATES)"
if [ "$GATE_COUNT" -lt "$MIN_GATES" ]; then
  say "GATE COUNT REGRESSION: $GATE_COUNT < $MIN_GATES — a gate script vanished or the"
  say "  glob stopped matching. Repair it; do not lower the floor to match."
  FAIL=1
fi

SELFTEST_LOG="/tmp/gatetests_$NAME.log"
python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py' > "$SELFTEST_LOG" 2>&1 \
  || { say "GATE SELF-TESTS FAILED"; tail -30 "$SELFTEST_LOG"; FAIL=1; }
GATE_TESTS=$(grep -E '^Ran [0-9]+ test' "$SELFTEST_LOG" | awk '{print $2}' | tail -1)
say "quality-gate self-tests: ${GATE_TESTS:-0} ran (floor $MIN_GATE_TESTS)"
if [ -z "$GATE_TESTS" ] || [ "$GATE_TESTS" -lt "$MIN_GATE_TESTS" ]; then
  say "GATE SELF-TEST COUNT REGRESSION: ${GATE_TESTS:-0} < $MIN_GATE_TESTS — tests are not"
  say "  being collected. Repair discovery; do not lower the floor to match."
  FAIL=1
fi

[ $FAIL -ne 0 ] && { say "STATIC GATES FAILED — fix before running Godot"; exit 1; }

# Fast path: no game/ change usually means GUT results cannot move. EXCEPT that
# several suites READ repo docs and assert on their contents, so a docs-only
# diff genuinely can turn the suite red. Discover which docs by grepping the
# tests, so the list cannot rot the way a hardcoded one would.
DOCS_READ=$(grep -rhoE '(docs/[A-Za-z0-9_/-]+\.md)' game/tests/ 2>/dev/null | sort -u)
DOC_TRIGGER=""
for d in $DOCS_READ; do echo "$ALL_PATHS" | grep -qxF "$d" && DOC_TRIGGER="$DOC_TRIGGER $d"; done
[ -z "$CHANGED_GAME" ] && [ -n "$DOC_TRIGGER" ] && say "docs-only diff, but the suite reads:$DOC_TRIGGER — running Godot"
if [ -z "$CHANGED_GAME" ] && [ -z "$DOC_TRIGGER" ] && [ "${GATES_FORCE_GODOT:-0}" != "1" ]; then
  if [ -z "$ALL_PATHS" ]; then
    say "STATIC GATES PASSED — nothing differs from $BASE and the tree is clean, so this run"
    say "  judged no game code at all. GATES_FORCE_GODOT=1 to actually run the suite."
  else
    say "STATIC GATES PASSED — no game/ file and no test-read doc changed vs $BASE, skipping Godot"
    say "  (GATES_FORCE_GODOT=1 to override)"
  fi
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

# Godot's own exit status is checked as well as the log. Grepping a summary is
# not the same as the process succeeding: a run that printed a clean summary and
# then died at shutdown used to be reported as ALL GATES PASSED.
say "GUT suite"
"$GODOT" --headless --path game/ -s addons/gut/gut_cmdln.gd 2>&1 \
  | sed 's/\x1b\[[0-9;]*m//g' > "/tmp/gut_$NAME.log"
GUT_STATUS=${PIPESTATUS[0]}
SCRIPTS=$(grep -E "^Scripts " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1)
TESTS=$(grep -E "^Tests " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1)
PASSING=$(grep -E "^Passing Tests " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1)
FAILING=$(grep -E "^Failing Tests " "/tmp/gut_$NAME.log" | awk '{print $NF}' | tail -1); FAILING=${FAILING:-0}
say "RESULT scripts=$SCRIPTS tests=$TESTS passing=$PASSING failing=$FAILING (floors $MIN_SCRIPTS/$MIN_TESTS)"

if [ "$GUT_STATUS" -ne 0 ]; then
  say "GODOT EXITED $GUT_STATUS — the suite's own summary is not evidence the process"
  say "  survived. See /tmp/gut_$NAME.log"; tail -30 "/tmp/gut_$NAME.log"; exit 1; fi
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
