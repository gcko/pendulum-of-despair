extends GutTest
## Tests for Phase B2 mechanical tweaks.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


func test_cael_physical_damage_10_percent_higher() -> void:
	seed(42)
	var base: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, ""
	)
	seed(42)
	var cael: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "cael"
	)
	assert_gt(cael, base, "Cael physical damage should exceed base")
	var ratio: float = float(cael) / float(base)
	assert_almost_eq(ratio, 1.1, 0.02, "Cael multiplier should be ~1.1x")


func test_non_cael_no_shimmer() -> void:
	seed(42)
	var edren: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "edren"
	)
	seed(42)
	var generic: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, ""
	)
	assert_eq(edren, generic, "Non-Cael characters should deal standard damage")


func test_cael_magical_damage_unaffected() -> void:
	seed(42)
	var base_mag: int = DamageCalc.calculate_magic(20, 50, 10, 1.0, 1.0, [], [])
	seed(42)
	var cael_mag: int = DamageCalc.calculate_magic(20, 50, 10, 1.0, 1.0, [], [])
	assert_eq(base_mag, cael_mag, "Magical damage should be unaffected by shimmer")
