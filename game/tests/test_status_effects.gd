extends GutTest
## Tests for StatusEffects registry (GAP-003). Values trace to magic.md /
## combat-formulas.md.

const SE := preload("res://scripts/combat/status_effects.gd")


func test_known_statuses() -> void:
	for s: String in [
		"poison", "sleep", "petrify", "slow", "despair", "silence", "confusion", "blind"
	]:
		assert_true(SE.is_known(s), "%s should be a known status" % s)
	assert_false(SE.is_known("nonexistent_status"), "unknown status rejected")
	# Stop is deliberately deferred (realtime on enemies not supported in 2b).
	assert_false(SE.is_known("stop"), "stop is deferred in Bundle 2b")


func test_atb_frozen_statuses() -> void:
	assert_eq(SE.atb_effect("sleep"), "frozen")
	assert_eq(SE.atb_effect("petrify"), "frozen")
	assert_eq(SE.atb_effect("poison"), "none")


func test_atb_mod_statuses() -> void:
	assert_eq(SE.atb_effect("slow"), "mod")
	assert_almost_eq(SE.atb_mult("slow"), 0.5, 0.001)  # combat-formulas.md:720
	assert_eq(SE.atb_effect("despair"), "mod")
	assert_almost_eq(SE.atb_mult("despair"), 0.75, 0.001)  # combat-formulas.md:721
	assert_almost_eq(SE.atb_mult("poison"), 1.0, 0.001, "non-mod statuses default 1.0")


func test_tick_percentages() -> void:
	assert_almost_eq(SE.tick_pct("poison"), 0.08, 0.001)  # magic.md:1392
	assert_almost_eq(SE.tick_pct("burn"), 0.05, 0.001)  # magic.md:1393
	assert_almost_eq(SE.tick_pct("sleep"), 0.0, 0.001)


func test_wake_on_damage() -> void:
	assert_true(SE.wakes_on_damage("sleep"))
	assert_true(SE.wakes_on_damage("confusion"))
	assert_false(SE.wakes_on_damage("poison"))
	assert_false(SE.wakes_on_damage("slow"))


func test_durations() -> void:
	assert_eq(SE.default_duration("poison"), SE.UNTIL_CURED, "poison until cured")
	assert_eq(SE.default_duration("sleep"), SE.UNTIL_CURED, "sleep until cured")
	assert_eq(SE.default_duration("petrify"), SE.UNTIL_CURED)
	assert_eq(SE.default_duration("slow"), 5)  # combat-formulas.md:732
	assert_eq(SE.default_duration("despair"), 4)
	assert_eq(SE.default_duration("silence"), 4)
	assert_eq(SE.default_duration("confusion"), 3)
	assert_eq(SE.default_duration("blind"), 4)


func test_resolve_duration_prefers_explicit() -> void:
	# A spell's explicit duration overrides the canonical default.
	assert_eq(SE.resolve_duration("despair", 3), 3, "explicit wins")
	assert_eq(SE.resolve_duration("silence", 2), 2)
	# Null falls back to the canonical default.
	assert_eq(SE.resolve_duration("slow", null), 5)
	assert_eq(SE.resolve_duration("poison", null), SE.UNTIL_CURED)
