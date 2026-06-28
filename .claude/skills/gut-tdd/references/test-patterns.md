# GUT 9.7.0 Test Patterns (reference)

Companion to `../SKILL.md`. Longer examples kept out of the main loop file.
GUT 9.7.0 on Godot 4.7, GDScript only. Tests live in `game/tests/test_*.gd`.

## Assertion quick table

| Intent | Assert |
|--------|--------|
| Equality | `assert_eq(got, want)` / `assert_ne(a, b)` |
| Truthiness | `assert_true(x)` / `assert_false(x)` |
| Null | `assert_null(x)` / `assert_not_null(x)` |
| Ordering (note the names) | `assert_lte(a, b)` / `assert_gte(a, b)` |
| Strict ordering | `assert_lt(a, b)` / `assert_gt(a, b)` |
| Range | `assert_between(x, lo, hi)` |
| Approx float | `assert_almost_eq(got, want, tol)` |
| Collection membership | `assert_has(coll, item)` / `assert_does_not_have(...)` |
| Type | `assert_is(obj, Type)` |
| Signals (see below) | `assert_signal_emitted`, `assert_signal_emitted_with_parameters`, `assert_signal_emit_count`, `assert_signal_not_emitted` |
| Doubles (see below) | `assert_called`, `assert_not_called`, `assert_call_count` |
| Leaks | `assert_no_new_orphans()` |

**Naming trap:** it is `assert_lte` / `assert_gte`, NOT `assert_le` / `assert_ge`.
Using the wrong name is a parse error, and GUT 9.7.0 **silently skips** the
whole file — the suite stays green while your tests never ran. Always confirm
the summary's `Scripts` and `Tests` counts.

## Signals — watch BEFORE you act

`watch_signals` must run before the action that emits, or the signal assert
fails silently (reports nothing was emitted).

```gdscript
func test_battler_dies_emits_defeated() -> void:
	var battler = preload("res://scripts/entities/battler.gd").new()
	add_child_autofree(battler)
	watch_signals(battler)          # BEFORE the act

	battler.take_damage(9999)        # act

	assert_signal_emitted(battler, "defeated")
	assert_signal_emit_count(battler, "defeated", 1)
	assert_signal_emitted_with_parameters(battler, "defeated", [battler.id])
```

## Parametrized / data-driven (combat formulas, stat scaling, prices)

One test body, many rows. Ideal where a formula must hold across inputs.

```gdscript
# Each row: [level, base_hp, expected_max_hp]
var hp_rows := [
	[1, 30, 30],
	[5, 30, 70],
	[10, 30, 120],
	[99, 30, 1000],
]


func test_max_hp_scales_with_level(p = use_parameters(hp_rows)) -> void:
	var level: int = p[0]
	var base_hp: int = p[1]
	var expected: int = p[2]

	var got: int = StatScaling.max_hp(base_hp, level)

	assert_eq(got, expected, "level %d -> %d HP" % [level, expected])
```

Group related cases with inner classes when they share setup:

```gdscript
class TestPhysicalDamage:
	extends GutTest

	var _calc


	func before_each() -> void:
		seed(12345)
		_calc = preload("res://scripts/combat/damage_calculator.gd").new()


	func test_floors_at_one() -> void:
		assert_eq(_calc.physical_damage({"attack": 1}, {"defense": 99}), 1)
```

## Doubling / partial doubles — isolate the 6 autoloads

Autoloads: GameManager, DataManager, AudioManager, SaveManager, EventFlags,
PartyState. Double them to test logic without the whole game tree. You cannot
double engine builtins.

Full double (every method stubbed, returns null unless stubbed):

```gdscript
func test_combat_queries_party_without_real_partystate() -> void:
	var fake_party = double(PartyStateScript).new()
	stub(fake_party, "get_active_member").to_return({"id": "hero", "attack": 20})

	var engine := preload("res://scripts/combat/combat_engine.gd").new()
	add_child_autofree(engine)
	engine.party = fake_party

	engine.start_turn()

	assert_called(fake_party, "get_active_member")
	assert_call_count(fake_party, "get_active_member", 1)
```

Partial double (real methods run except the ones you stub) — good for
overriding one collaborator call on a mostly-real object:

```gdscript
func test_save_skips_disk_write() -> void:
	var saver = partial_double(SaveManagerScript).new()
	stub(saver, "_write_file").to_do_nothing()

	saver.save_slot(1)

	assert_called(saver, "_write_file")  # spy confirms it was invoked
```

Spies (`assert_called` / `assert_not_called` / `assert_call_count`) track
calls on doubles without changing behavior.

## Cleanup, determinism, timing, headless

```gdscript
func before_each() -> void:
	seed(12345)                       # deterministic randi()/randf()


func after_each() -> void:
	# Free anything you spawned that isn't autofree'd.
	assert_no_new_orphans()           # catches leaked nodes


func test_atb_gauge_fills_over_time() -> void:
	var gauge = preload("res://scripts/combat/atb_gauge.gd").new()
	add_child_autofree(gauge)

	gauge.start()
	await wait_seconds(0.5)            # never `sleep`
	# or: await wait_idle_frames(2) / await wait_physics_frames(2)

	assert_gte(gauge.value, 0.0)


func test_input_mapping() -> void:
	if DisplayServer.get_name() == "headless":
		return                        # skip display/input tests under --headless
	# ... real input assertions ...
```

## Node-in-unit-test trap

A script extending Node that you instantiate with `.new()` (no scene) has no
children in the tree. `$Child` emits a "node not found -> nullptr" engine
error that GUT counts as a failure even when your logic is correct. Use
`get_node_or_null("Child")` in production code and guard:

```gdscript
var child := get_node_or_null("HealthBar")
if child == null:
	return
child.value = hp
```

## Pre-flight checklist before handoff

- [ ] `--import` ran clean (no U-state wedge).
- [ ] New test failed for a REAL assertion in RED (not a skip/parse error).
- [ ] Full suite green AND `Scripts`/`Tests` counts match expectation
      (repo baseline ~55 files / ~924 tests — counts only go UP as you add).
- [ ] No new orphans, no leaked doubles.
- [ ] Then `/create-pr`. Never `--no-verify`.
