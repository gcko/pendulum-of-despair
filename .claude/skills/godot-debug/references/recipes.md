# godot-debug recipes (deeper)

Detailed techniques for root-causing GDScript / GUT 9.7.0 bugs in
Pendulum of Despair. The SKILL.md catalog covers the common scars; this is the
long form. `<godot>` = `godot` on PATH, else
`/Applications/Godot.app/Contents/MacOS/Godot`.

## Reproducing in isolation

1. `<godot> --headless --path game/ --import` — warm imports. If this wedges in
   U-state (0% CPU, unkillable), reboot; the suite did not run.
2. Run the one failing file with verbosity:
   `<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
   -gtest=res://tests/test_<name>.gd -gexit -glog=3`
3. Narrow to one test method with `-gselect=<pattern>`.
4. Read the `Scripts` / `Tests` counts every run — a drop means a file failed to
   parse and was silently skipped (baseline ~55 files / ~924 tests).

## Doubles / mocks for the 6 autoloads

Use when a unit needs to be isolated from GameManager, DataManager, etc.

- `double(Obj).new()` — full double (all methods stubbed).
- `partial_double(obj)` — keep real behavior, override specific methods.
- Spies: `assert_called` / `assert_not_called` / `assert_call_count`.
- You **cannot** double engine builtins.
- Examples: PartyState stat math without GameManager; combat formulas without a
  full scene; SaveManager round-trips without touching disk.

## Signal-driven code

```gdscript
watch_signals(obj)
obj.do_thing()
assert_signal_emitted(obj, "thing_done")
assert_signal_emitted_with_parameters(obj, "thing_done", [expected])
assert_signal_emit_count(obj, "thing_done", 1)
```

Forgetting `watch_signals` makes the asserts inert — they will not catch a
missing emission.

## Node lifecycle in tests

- Instantiate testable nodes with `.new()`; reference children with
  `get_node_or_null("Child")` and guard `if ref == null: return`.
- Free spawned nodes in `after_each()` (`queue_free()` / `free()`).
- Assert cleanliness: `assert_no_new_orphans()`.

## Determinism & timing

- Seed randomness: `seed(12345)` — un-seeded `randi()` produces flaky failures.
- Never `sleep`; await GUT helpers: `await wait_seconds(n)`,
  `await wait_idle_frames(n)`, `await wait_physics_frames(n)`.
- Display/input tests under headless: early-out with
  `if DisplayServer.get_name() == "headless": return`.

## Parametrized / data-driven

One test, many input/output rows — ideal for combat formulas, stat scaling, and
item prices. Group related cases with inner test classes that share setup.

## Asserts cheat-sheet (naming traps)

- Less/greater-or-equal: `assert_lte` / `assert_gte` (NOT `assert_le`/`assert_ge`).
- A typo'd assert name is a parse error -> the whole file is silently skipped.

## Engine error vs assertion failure

- "node not found", "nil instance", "Invalid get index" => engine runtime error;
  fix the code path (null-guard, load order, missing resource).
- `assert_*` line in the failure => logic/expectation mismatch; trace data flow.
- GUT surfaces engine errors as failures, so always read the message text to tell
  the two apart before changing anything.
