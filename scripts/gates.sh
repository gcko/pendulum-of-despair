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
# parallel worktrees need something that can. It shares the headless-Godot mutex
# in scripts/quality-gates/godot-lock.sh with .husky/pre-push, so a hand-run and
# a push do not start two Godots between them. That is a mkdir lock with an owner
# pid, not a kernel lock; godot-lock.sh names the one window it cannot close.
#
# What it runs: gdformat, gdlint and JSON validation on the changed files
# (pre-commit Gates A-C, refusing a gdtoolkit that is missing or off its pin);
# every scripts/quality-gates/check_*.py, which covers pre-push Gates D-G, J,
# K, M and N plus check_gut_baseline.py's baseline shape
# check, held to the `gates` floor; the gate self-tests (Gate I), held to the
# `gate_tests` floor; then Godot import, the GUT suite and Gate L, unless no
# game/ file, no doc the suite reads and no Gate L input changed (the fast path
# below; GATES_FORCE_GODOT=1 overrides it).
#
# What it checks first: that this worktree's git hooks are installed and
# enabled (core.hooksPath is .husky/_, husky's dispatcher and the pre-commit,
# commit-msg and pre-push shims exist, HUSKY is not 0). If not, it exits 1 and
# names the pnpm install to run, before it judges anything (#474).
#
# What it is NOT: a replacement for the hooks, and nothing runs it for you. It
# skips the branch-protection and commit-message checks, and it may skip Godot
# on a diff the pre-push hook would still run the suite for. The hooks still
# run on every commit and push, once pnpm install has run in this worktree.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
NAME="$(basename "$ROOT")"
GODOT_APP="/Applications/Godot.app/Contents/MacOS/Godot"
GODOT="${GODOT_BIN:-}"
[ -z "$GODOT" ] && command -v godot >/dev/null 2>&1 && GODOT="godot"
[ -z "$GODOT" ] && [ -x "$GODOT_APP" ] && GODOT="$GODOT_APP"
BASE="${GATES_BASE:-main}"
MAX_GODOT="${GATES_MAX_GODOT:-1}"
FAIL=0
say() { echo "[$NAME] $*"; }

# --- Hooks installed? ---------------------------------------------------------
# core.hooksPath is the RELATIVE path .husky/_, which git resolves in each
# worktree, and .husky/_ is gitignored: pnpm install creates it per worktree.
# A fresh `git worktree add` has none, so git commit and git push there run no
# hook at all and say nothing (#474). This runner exists for exactly those
# worktrees, so it refuses to judge one whose hooks would not run rather than
# report green on a tree the hooks will never see. "Would not run" is any of:
#   * HUSKY=0, which makes husky's dispatcher exit 0 before any hook;
#   * core.hooksPath unset or not .husky/_, so git runs some other directory's
#     files (another hook manager's in .git/hooks, or git's *.sample files);
#   * no dispatcher (.husky/_/h) or no pre-commit, commit-msg or pre-push shim.
hooks_refuse() {
  say "GIT HOOKS NOT INSTALLED in this worktree: $1"
  say "  Until they are, git commit and git push here run no hooks and say"
  say "  nothing. pnpm install creates .husky/_ in each worktree and points"
  say "  core.hooksPath at it. Install them, then re-run:"
  say "    cd '$ROOT' && pnpm install --frozen-lockfile"
  exit 1
}
if [ "${HUSKY-}" = "0" ]; then
  say "GIT HOOKS DISABLED: HUSKY=0 is set, so husky's dispatcher exits 0 before"
  say "  any hook runs. Unset it and re-run."
  exit 1
fi
HOOKS_PATH="$(git config --get core.hooksPath || true)"
if [ "$HOOKS_PATH" != ".husky/_" ]; then
  if [ -z "$HOOKS_PATH" ]; then
    hooks_refuse "core.hooksPath is unset, so git runs .git/hooks, not husky"
  fi
  hooks_refuse "core.hooksPath is '$HOOKS_PATH', not husky's .husky/_"
fi
HOOKS_DIR="$(git rev-parse --git-path hooks 2>/dev/null || true)"
for hook in h pre-commit commit-msg pre-push; do
  if [ -z "$HOOKS_DIR" ] || [ ! -f "$HOOKS_DIR/$hook" ]; then
    hooks_refuse "no ${HOOKS_DIR:-.husky/_}/$hook"
  fi
  if [ "$hook" != h ] && [ ! -x "$HOOKS_DIR/$hook" ]; then
    hooks_refuse "$HOOKS_DIR/$hook is not executable, so git skips it"
  fi
done

# --- Floors -----------------------------------------------------------------
# A floor that is absent, duplicated, or non-numeric must stop the run. It used
# not to: `[ "$SCRIPTS" -lt abc ]` prints "integer expression expected" and
# evaluates FALSE, so a corrupted floor reported ALL GATES PASSED with the
# silent-skip guard switched off. Validate the shape before trusting it.
#
# Reading the floors and judging a GUT log against them both live in
# check_gut_baseline.py (pre-push Gate L) rather than here, so this script, the
# hook and CI share ONE implementation and cannot drift apart in their parsing
# or their diagnosis (#430). Its stdout is the value channel; diagnostics go to
# stderr, which is why it is safe to eval.
BASELINE_FILE="scripts/quality-gates/gut-baseline.txt"
GUT_FLOOR_GATE="scripts/quality-gates/check_gut_baseline.py"
if ! FLOORS=$(python3 "$GUT_FLOOR_GATE" --baseline "$BASELINE_FILE" --shell --label "$NAME"); then
  say "cannot read $BASELINE_FILE"; exit 1
fi
eval "$FLOORS"

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

# gdtoolkit must be present AND at the pinned version, the same check
# .husky/pre-commit makes through the same helper (#477). Without it a local
# gdtoolkit at another version passed here, failed pre-commit, and judged the
# formatting by rules CI does not use. Only asked when .gd files changed, so a
# docs-only run still needs no gdtoolkit. A tool that fails the check is not
# run: its verdict would be another release's.
gd_require() {
  local out line
  out=$(gdtoolkit_require "$1" "$2" changed 2>&1) && return 0
  while IFS= read -r line; do say "$line"; done <<<"$out"
  return 1
}
if [ -n "$CHANGED_GD" ]; then
  # shellcheck source=scripts/quality-gates/gdtoolkit-require.sh
  . scripts/quality-gates/gdtoolkit-require.sh
  if gd_require gdformat "Gate C"; then
    say "gdformat --check ($(echo "$CHANGED_GD" | wc -l | tr -d ' ') file(s))"
    gdformat --check $CHANGED_GD || { say "GDFORMAT FAILED"; FAIL=1; }
  else
    say "GDFORMAT FAILED"; FAIL=1
  fi
  if gd_require gdlint "Gate A"; then
    say "gdlint"; gdlint $CHANGED_GD || { say "GDLINT FAILED"; FAIL=1; }
  else
    say "GDLINT FAILED"; FAIL=1
  fi
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

# The self-test log is unique to this run and removed when the run is done. A
# fixed /tmp/gatetests_$NAME.log was shared by every run in this worktree, and
# by any other worktree with the same folder name, and it is written before the
# Godot lock is taken, so two runs could read each other's count (#487).
SELFTEST_LOG=$(mktemp "${TMPDIR:-/tmp}/gatetests_$NAME.XXXXXX") \
  || { say "GATE SELF-TESTS FAILED — could not create a log file with mktemp"; exit 1; }
trap 'rm -f "$SELFTEST_LOG"' EXIT
python3 -m unittest discover -s scripts/quality-gates -p 'test_*.py' > "$SELFTEST_LOG" 2>&1 \
  || { say "GATE SELF-TESTS FAILED"; tail -30 "$SELFTEST_LOG"; FAIL=1; }
GATE_TESTS=$(grep -E '^Ran [0-9]+ test' "$SELFTEST_LOG" | awk '{print $2}' | tail -1)
# Removed here, not only by the trap: godot_lock_acquire below sets its own
# EXIT trap, which replaces this one.
rm -f "$SELFTEST_LOG"
trap - EXIT
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

# Gate L's OWN inputs count too. The floors and the judge decide the GUT
# verdict, so a branch that edits either changes what a run means — yet neither
# is under game/, so this script skipped Godot and the branch that WIRED Gate L
# could not demonstrate Gate L through its own runner. A mistyped floor is also
# shape-valid, so the bare shape check at the top accepts it and ALL GATES
# PASSED prints; the error then surfaces two minutes into someone's pre-push,
# a long way from the one-line diff that caused it (#430).
GATE_L_INPUTS="$BASELINE_FILE
$GUT_FLOOR_GATE
scripts/quality-gates/godot-lock.sh"
GATE_TRIGGER=""
while IFS= read -r g; do
  [ -n "$g" ] && echo "$ALL_PATHS" | grep -qxF "$g" && GATE_TRIGGER="$GATE_TRIGGER $g"
done <<<"$GATE_L_INPUTS"

[ -z "$CHANGED_GAME" ] && [ -n "$DOC_TRIGGER" ] && say "docs-only diff, but the suite reads:$DOC_TRIGGER — running Godot"
[ -z "$CHANGED_GAME" ] && [ -n "$GATE_TRIGGER" ] && say "no game/ change, but Gate L's own inputs moved:$GATE_TRIGGER — running Godot"
if [ -z "$CHANGED_GAME" ] && [ -z "$DOC_TRIGGER" ] && [ -z "$GATE_TRIGGER" ] && [ "${GATES_FORCE_GODOT:-0}" != "1" ]; then
  if [ -z "$ALL_PATHS" ]; then
    say "STATIC GATES PASSED — nothing differs from $BASE and the tree is clean, so this run"
    say "  judged no game code at all. GATES_FORCE_GODOT=1 to actually run the suite."
  else
    say "STATIC GATES PASSED — no game/ file, test-read doc or Gate L input changed vs $BASE, skipping Godot"
    say "  (GATES_FORCE_GODOT=1 to override)"
  fi
  exit 0
fi

if [ -z "$GODOT" ]; then
  say "Godot not found (set GODOT_BIN, or install to $GODOT_APP) — refusing to"
  say "report success on a tree whose GUT suite was never run"
  exit 1
fi

# The mutex lives in scripts/quality-gates/godot-lock.sh, shared with
# .husky/pre-push. It used to live here alone, and the hook ran Godot with no
# lock at all -- so a push contending with a gates.sh run collected fewer
# scripts and Gate L blamed a healthy test file (#430).
GODOT_LOCK_LABEL="$NAME"
# shellcheck source=scripts/quality-gates/godot-lock.sh
. scripts/quality-gates/godot-lock.sh
godot_lock_acquire || exit 1

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

if [ "$GUT_STATUS" -ne 0 ]; then
  say "GODOT EXITED $GUT_STATUS — the suite's own summary is not evidence the process"
  say "  survived. See /tmp/gut_$NAME.log"; tail -30 "/tmp/gut_$NAME.log"; exit 1; fi

# The summary, the failure verdict and the script/test floors: pre-push Gate L.
# A log with no summary in it FAILS here rather than falling through the
# comparisons, because a run that died before printing one is indistinguishable
# from a run with nothing to report.
python3 "$GUT_FLOOR_GATE" --baseline "$BASELINE_FILE" --log "/tmp/gut_$NAME.log" --label "$NAME" || exit 1

say "ALL GATES PASSED"
