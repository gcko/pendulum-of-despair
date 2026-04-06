extends GutTest
## Integration tests for the battle system.
## Tests full pipeline composition and formula verification.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


func before_each() -> void:
	GameManager.transition_data = {}


func after_each() -> void:
	GameManager.transition_data = {}


# --- Full Physical Pipeline ---


func test_physical_pipeline_edren_lv1() -> void:
	seed(42)
	var atk: int = 18
	var def_val: int = 5
	var spd: int = 10
	var target_spd: int = 5
	var lck: int = 8
	var hit: bool = DamageCalc.roll_hit(spd, target_spd)
	if not hit:
		pass_test("miss is valid outcome")
		return
	var evaded: bool = DamageCalc.roll_evasion(target_spd)
	if evaded:
		pass_test("evasion is valid outcome")
		return
	var is_crit: bool = DamageCalc.roll_crit(lck)
	var dmg: int = DamageCalc.calculate_physical(
		atk, 1.0, def_val, is_crit, 1.0, "front", "front", false, [], false, 1.0
	)
	if is_crit:
		assert_between(dmg, 91, 98, "crit range")
	else:
		assert_between(dmg, 45, 49, "normal range")


# --- Full Magic Pipeline ---


func test_magic_pipeline_maren_lv1() -> void:
	seed(42)
	var mag: int = 22
	var power: int = 14
	var mdef: int = 8
	var spd: int = 8
	var target_spd: int = 5
	var hit: bool = DamageCalc.roll_hit(spd, target_spd)
	if not hit:
		pass_test("miss is valid")
		return
	var evaded: bool = DamageCalc.roll_evasion(target_spd)
	if evaded:
		pass_test("evaded is valid")
		return
	var dmg: int = DamageCalc.calculate_magic(mag, power, mdef, 1.0, 1.0, [], [])
	assert_between(dmg, 64, 69, "magic damage range")


# --- Flee Formula ---


func test_flee_equal_speed() -> void:
	assert_eq(DamageCalc.calculate_flee_chance(50.0, 50.0), 50)


func test_flee_fast_party_capped_at_90() -> void:
	assert_eq(DamageCalc.calculate_flee_chance(100.0, 50.0), 90)


func test_flee_slow_party_floored_at_10() -> void:
	assert_eq(DamageCalc.calculate_flee_chance(10.0, 100.0), 10)


# --- Damage Reduction Pipeline ---


func test_pallors_last_plus_deeproot_reduction() -> void:
	# Pallor Last 25% + Deeproot 15% → product = 0.75 * 0.85 = 0.6375
	var no_red: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var with_red: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [0.25, 0.15], false, 1.0
	)
	var ratio: float = float(with_red) / float(no_red)
	assert_between(ratio, 0.60, 0.68, "stacked reduction ratio ~63.75%")


# --- Elemental System ---


func test_weakness_multiplier_1_5x() -> void:
	var neutral: int = DamageCalc.calculate_magic(100, 50, 20, 1.0, 1.0, [], [])
	var weak: int = DamageCalc.calculate_magic(100, 50, 20, 1.5, 1.0, [], [])
	var ratio: float = float(weak) / float(neutral)
	assert_between(ratio, 1.4, 1.6, "1.5x weakness multiplier")


func test_resistance_multiplier_0_5x() -> void:
	var neutral: int = DamageCalc.calculate_magic(100, 50, 20, 1.0, 1.0, [], [])
	var resist: int = DamageCalc.calculate_magic(100, 50, 20, 0.5, 1.0, [], [])
	assert_lt(resist, neutral, "same-element resistance reduces damage")


# --- Healing Cap ---


func test_healing_caps_at_14999() -> void:
	var result: int = DamageCalc.calculate_healing(255, 120)
	assert_eq(result, 14999, "healing capped at 14999")


# --- Status Accuracy Edge Cases ---


func test_status_with_zero_mag_and_mdef() -> void:
	assert_false(DamageCalc.roll_status(75, 0, 0, 0), "guard against div-by-zero")


func test_status_high_mag_vs_low_mdef() -> void:
	seed(500)
	var successes: int = 0
	for i: int in range(100):
		if DamageCalc.roll_status(90, 200, 10, 10):
			successes += 1
	assert_gt(successes, 30, "high MAG lands status frequently")
