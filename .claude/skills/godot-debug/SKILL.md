---
name: godot-debug
description: Use when a GDScript bug, GUT failure, or unexpected Godot behavior needs root-causing. Triggers on GDScript runtime errors, GUT test failures, scenes that won't initialize, 'nullptr'/'node not found' errors, or a green suite that's hiding skipped tests.
---

# Godot Debug

Systematic root-causing for GDScript / GUT (9.7.0) / Godot 4.7 bugs in the
Pendulum of Despair JRPG. GDScript only — no TypeScript, no vitest/jest. Tests
are GUT; lint is gdlint + `gdformat --check`; issues live in GitHub Issues.

## Core discipline: ROOT CAUSE BEFORE FIX

Mirror `superpowers:systematic-debugging`. Do NOT patch the symptom until you
understand the cause. The loop:

1. **Read the error fully.** The full stack/engine message, not the first line.
   Note the script path, line number, and whether it's an *engine* error (e.g.
   "node not found", "nil instance") or a GUT *assertion* failure — they have
   different root causes.
2. **Reproduce.** Run the smallest thing that triggers it (single test file,
   single scene). A bug you cannot reproduce on demand is not yet understood.
3. **Check recent changes.** `git diff`, `git log -p` on the touched script —
   most bugs arrived with the last edit.
4. **Trace data flow.** Follow the value from where it's set to where it breaks.
   For the 6 autoloads (GameManager, DataManager, AudioManager, SaveManager,
   EventFlags, PartyState), confirm load order and that data JSON parsed.
5. **Lock the fix with a FAILING test FIRST.** Before changing engine code,
   reproduce the bug as a failing GUT test — hand off to `/gut-tdd` to write it.
   Then make it pass. A fix without a regression test is not done.

## Godot / GUT gotcha catalog

Symptom -> root cause -> fix.

### Green suite, but a test file silently vanished
- **Symptom:** Suite reports all-green, yet the behavior you wrote a test for
  is clearly broken; `Scripts`/`Tests` counts look low.
- **Root cause:** GUT 9.x **silently skips** any `test_*.gd` file that fails to
  parse. The skipped file contributes zero passes and zero failures, so green
  hides it. (Repo baseline: ~55 test files / ~924 tests.)
- **Fix:** Always read the summary's `Scripts` and `Tests` counts. If they
  dropped, a file was skipped — run that file alone (`-gtest=...`) to surface
  the parse error, fix it, confirm the counts recover.

### Pre-push "passed" but the GUT suite never ran (macOS U-state wedge)
- **Symptom:** Pre-push completes oddly fast, or hangs forever; `Godot`/import
  shows 0% CPU and is unkillable (`kill -9` does nothing).
- **Root cause:** macOS `--import` can deadlock in uninterruptible **U-state**.
  A wedged import means the GUT suite **did not run**, even though earlier gates
  (gdlint, JSON, gdformat) passed.
- **Fix:** A reboot clears the U-state process. Never equate "other gates pass"
  with "tests green" — re-run the full suite after rebooting and confirm a real
  pass count.

### `$Child` -> "node not found -> nullptr" in a `.new()` unit test
- **Symptom:** A unit test that instantiates a node via `.new()` logs a
  "node not found" / nullptr engine error, which GUT counts as a **failure**
  even when the assertion logic is correct.
- **Root cause:** `$Child` (and `get_node("Child")`) hard-fail when the child
  isn't in the tree — which it isn't for a bare `.new()` instance.
- **Fix:** Use `get_node_or_null("Child")` and null-guard every use
  (`if ref == null: return`). Production scenes can keep `$Child`; testable
  nodes should degrade gracefully.

### `assert_signal_emitted` passes/fails silently — never fires
- **Symptom:** Signal assertions don't behave; no clear failure.
- **Root cause:** GUT must be told to watch the object first. Without
  `watch_signals(obj)` the signal asserts are inert.
- **Fix:** `watch_signals(obj)` -> act -> `assert_signal_emitted(obj, "name")`
  (or `assert_signal_emitted_with_parameters` / `assert_signal_emit_count`).

### `assert_le` / `assert_ge` "method not found"
- **Symptom:** Test errors on an unknown assert method.
- **Root cause:** GUT names them `assert_lte` / `assert_gte`.
- **Fix:** Use `assert_lte` / `assert_gte`. (Same trap also silently skips the
  whole file if it's a parse-time error — see the green-suite gotcha.)

## Debug toolkit

Godot binary: `godot` on PATH, else
`/Applications/Godot.app/Contents/MacOS/Godot`. Let `<godot>` stand for it.

```bash
# Import warm-up FIRST — must pass before any test run
<godot> --headless --path game/ --import

# Run ONE test file, exit when done
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
  -gtest=res://tests/test_<name>.gd -gexit

# Max verbosity while root-causing
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
  -gtest=res://tests/test_<name>.gd -gexit -glog=3

# Isolate a single test / pattern within files
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
  -gselect=<pattern> -gexit

# Full suite (what pre-push runs)
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd
```

After any run, read the `Scripts` and `Tests` counts in the summary to rule out
a silent skip. Deeper recipes (doubles/mocks for autoloads, parametrized data,
orphan checks) live in `references/recipes.md`.

## Exit

- **Lock the fix:** hand off to `/gut-tdd` so the reproduction becomes a
  permanent regression test (RED -> GREEN -> REFACTOR).
- **Review:** hand off to `/godot-review` for the engine-code change.
- File any deferred follow-ups as GitHub Issues (`gh issue create`); never
  `--no-verify` to get past a failing hook.
