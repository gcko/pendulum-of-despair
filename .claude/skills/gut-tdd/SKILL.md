---
name: gut-tdd
description: >
  Use when implementing or changing GDScript game logic test-first with
  GUT. Triggers on "write tests first", implementing or refactoring a game
  mechanic (combat formulas, stat scaling, save logic, ATB), or driving any
  GDScript behavior with tests. Enforces RED -> GREEN -> REFACTOR adapted to
  GUT 9.7.0 / Godot 4.7. Hands off to /create-pr when green.
---

# GUT TDD (Test-Driven GDScript)

Drive every piece of GDScript game logic with a failing GUT test first.
This project runs **GUT 9.7.0 on Godot 4.7**, GDScript only. Tests live in
`game/tests/` as `test_*.gd`. The pre-push hook runs the **full GUT suite**,
so code does not leave your machine until the suite is green — never
`--no-verify`, fix the root cause instead.

For the longer reference (full assertion table, parametrized example,
doubling example) see `references/test-patterns.md`. Keep this file as the
loop you actually run.

## The loop: RED -> GREEN -> REFACTOR

### 1. RED — write ONE failing test, RUN it, confirm it fails for the RIGHT reason
- Write the smallest GUT test that describes behavior that does not exist yet.
- **RUN it immediately** (single-file command below). Do not write code first.
- Confirm it fails on a **real assertion** — not a parse error and not a
  missing-file skip. GUT 9.7.0 **silently skips** test files that fail to
  parse, so a "green" run can hide a broken file. Read the summary's
  `Scripts` and `Tests` counts every time: if your new test did not add to
  the `Tests` count, it was skipped (parse error / wrong path), not passing.
- A failing assertion looks like `[Failed]: expected X to equal Y`. A skip /
  parse error does NOT — treat that as "test never ran" and fix the test.

### 2. GREEN — minimal code to pass
- Write the least GDScript that makes the assertion pass. No extra features.
- Re-run the single file. Confirm the test now passes AND the `Tests` count
  is what you expect (your assertion ran).

### 3. REFACTOR — clean up, stay green
- Improve names, extract helpers, remove duplication. Behavior unchanged.
- Re-run the file, then the full suite. Confirm `Scripts`/`Tests` counts are
  unchanged from before the refactor (nothing got silently skipped).

Repeat one behavior at a time. One assertion's worth of progress per loop.

## Run commands

Godot binary: `godot` on PATH, else
`/Applications/Godot.app/Contents/MacOS/Godot`.

```bash
# 0. Import warm-up FIRST — must pass before any test run.
<godot> --headless --path game/ --import

# Single file (the RED/GREEN inner loop):
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
  -gtest=res://tests/test_<thing>.gd -gexit

# Add verbose logging when a failure is unclear:
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
  -gtest=res://tests/test_<thing>.gd -gexit -glog=3

# Full suite (run before handing off; this is what pre-push runs):
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd
```

If `--import` wedges on macOS (0% CPU, uninterruptible) a reboot clears it.
A wedged import/pre-push means the suite **did not run** — never treat "the
other gates passed" as "tests green."

## GUT 9.7.0 patterns (use these, not generic xUnit habits)

- **AAA structure** — Arrange / Act / Assert, one behavior per test. No
  `assert_true(true)` filler.
- **`watch_signals(obj)` BEFORE the act** — required before
  `assert_signal_emitted` / `assert_signal_emitted_with_parameters` /
  `assert_signal_emit_count`. Omit it and the signal assert fails silently.
- **Assert naming is `assert_lte` / `assert_gte`** — NOT `assert_le`/`assert_ge`
  (those don't exist and parse-skip the whole file).
- **Cleanup in `after_each`** — `queue_free`/`free` every node you spawned,
  then `assert_no_new_orphans()` to catch leaks.
- **Determinism** — `seed(12345)` before any code that calls `randi()`/`randf()`.
  Un-seeded randomness causes flaky failures.
- **Timing** — `await wait_seconds()` / `await wait_idle_frames()` /
  `await wait_physics_frames()`. Never `sleep`.
- **Headless guard** — display/input tests need
  `if DisplayServer.get_name() == "headless": return` so they don't false-fail
  under `--headless`.
- **`get_node_or_null("Child")` not `$Child`** in `.new()`-instantiated unit
  tests — `$Child` emits a "node not found -> nullptr" engine error that GUT
  counts as a failure even when the logic is right.
- **Doubles / partial_doubles** to isolate the 6 autoloads (GameManager,
  DataManager, AudioManager, SaveManager, EventFlags, PartyState): test
  PartyState stat math without GameManager, combat formulas without scenes.
  See `references/test-patterns.md`.
- **Parametrized / data-driven tests** for combat formulas, stat scaling, and
  item prices — one test body, many input/output rows. See reference file.

## Copy-paste skeleton

```gdscript
extends GutTest

# System under test. Prefer .new() on a plain script; instantiate scenes only
# when the behavior genuinely needs the tree.
var _sut


func before_each() -> void:
	seed(12345)  # deterministic RNG
	_sut = preload("res://scripts/combat/damage_calculator.gd").new()


func after_each() -> void:
	if _sut != null and _sut is Node:
		_sut.queue_free()
	_sut = null
	assert_no_new_orphans()


func test_physical_damage_uses_attack_minus_defense() -> void:
	# Arrange
	var attacker := {"attack": 30}
	var defender := {"defense": 10}

	# Act
	var dmg: int = _sut.physical_damage(attacker, defender)

	# Assert
	assert_eq(dmg, 20, "30 ATK vs 10 DEF should deal 20")
	assert_gte(dmg, 1, "damage floors at 1")


func test_emits_damage_dealt_signal() -> void:
	# Arrange — watch BEFORE the act, or the assert fails silently.
	var target = preload("res://scripts/entities/battler.gd").new()
	add_child_autofree(target)
	watch_signals(target)

	# Act
	target.take_damage(5)

	# Assert
	assert_signal_emitted(target, "damage_dealt")
	assert_signal_emitted_with_parameters(target, "damage_dealt", [5])
```

## Exit

When the new behavior is green and the **full suite** passes with the expected
`Scripts`/`Tests` counts (nothing skipped):

- Hand off to `/create-pr` to commit, push (runs the pre-push GUT gate), and
  open the PR.
- If this work is part of a larger bundle, return to `/issue-bundle` to pick
  up the next issue before opening the PR.

Never push with a red or silently-skipped suite. Never `--no-verify`.
