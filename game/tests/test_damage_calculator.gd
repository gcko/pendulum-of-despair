extends GutTest
## Tests for DamageCalculator — verifies every formula against combat-formulas.md.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")

# --- Physical Damage ---


func test_physical_edren_lv1_vs_tutorial_mob() -> void:
	# combat-formulas.md: Edren Lv1 (ATK 18) vs tutorial mob (DEF 5) → ~49
	# raw = max(1, (18*18*1.0)/6 - 5) = max(1, 54 - 5) = 49
	var result: int = DamageCalc.calculate_physical(
		18, 1.0, 5, false, 1.0, "front", "front", false, [], false, 1.0
	)
	assert_gte(result, 45, "Edren Lv1 min damage")
	assert_lte(result, 49, "Edren Lv1 max damage")


func test_physical_damage_floor_of_1() -> void:
	# ATK 1 vs DEF 999 → raw = max(1, (1/6) - 999) = 1
	var result: int = DamageCalc.calculate_physical(
		1, 1.0, 999, false, 1.0, "front", "front", false, [], false, 1.0
	)
	assert_eq(result, 1, "minimum damage is always 1")


func test_physical_damage_cap_14999() -> void:
	# ATK 255, mult 3.0 vs DEF 0 → raw = (255*255*3.0)/6 = 32512.5
	var result: int = DamageCalc.calculate_physical(
		255, 3.0, 0, false, 1.0, "front", "front", false, [], false, 1.0
	)
	assert_eq(result, 14999, "damage capped at 14999")


func test_physical_critical_doubles() -> void:
	# ATK 18, DEF 5, crit → raw 49 * 2 = 98, with variance ~91-97
	var result: int = DamageCalc.calculate_physical(
		18, 1.0, 5, true, 1.0, "front", "front", false, [], false, 1.0
	)
	assert_gte(result, 91, "crit min")
	assert_lte(result, 98, "crit max")


func test_physical_back_row_attacker_penalty() -> void:
	# Back row melee attacker gets 0.5x
	var front: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var back: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "back", "front", false, [], false, 1.0
	)
	assert_lt(back, front, "back row does less damage")


func test_physical_back_row_spear_bypasses() -> void:
	# Spear (weapon_bypasses_row=true) ignores back row penalty
	var front: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var spear_back: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "back", "front", true, [], false, 1.0
	)
	assert_gte(spear_back, front - 10, "spear from back row similar to front")


func test_physical_back_row_defender_reduction() -> void:
	var front_def: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var back_def: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "front", "back", false, [], false, 1.0
	)
	assert_lt(back_def, front_def, "back row defender takes less")


func test_physical_damage_reduction_stacks() -> void:
	# Two 25% reductions → product = 0.75 * 0.75 = 0.5625
	var no_red: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var with_red: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [0.25, 0.25], false, 1.0
	)
	assert_lt(with_red, no_red, "reduction reduces damage")


func test_physical_elemental_immune_returns_zero() -> void:
	var result: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], true, 0.0
	)
	assert_eq(result, 0, "immunity returns 0")


func test_physical_elemental_absorb_returns_positive() -> void:
	var result: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], true, -1.0
	)
	assert_gt(result, 0, "absorb returns positive healing value")


# --- Magic Damage ---


func test_magic_maren_lv1_ember_lance() -> void:
	# combat-formulas.md: Maren Lv1 (MAG 22) Ember Lance (power 14) vs MDEF 8
	# raw = max(1, (22*14)/4 - 8) = max(1, 77 - 8) = 69
	var result: int = DamageCalc.calculate_magic(22, 14, 8, 1.0, 1.0, [], [])
	assert_gte(result, 64, "Maren Lv1 magic min")
	assert_lte(result, 69, "Maren Lv1 magic max")


func test_magic_elemental_weakness() -> void:
	var neutral: int = DamageCalc.calculate_magic(50, 20, 10, 1.0, 1.0, [], [])
	var weak: int = DamageCalc.calculate_magic(50, 20, 10, 1.5, 1.0, [], [])
	assert_gt(weak, neutral, "weakness does more damage")


func test_magic_immune_returns_zero() -> void:
	var result: int = DamageCalc.calculate_magic(50, 20, 10, 0.0, 1.0, [], [])
	assert_eq(result, 0, "magic immunity returns 0")


func test_magic_absorb_returns_positive() -> void:
	var result: int = DamageCalc.calculate_magic(50, 20, 10, -1.0, 1.0, [], [])
	assert_gt(result, 0, "absorb returns positive healing value")


func test_magic_damage_cap() -> void:
	var result: int = DamageCalc.calculate_magic(255, 120, 0, 1.5, 1.0, [], [])
	assert_eq(result, 14999, "magic capped at 14999")


func test_magic_with_resonance_buff() -> void:
	var base: int = DamageCalc.calculate_magic(100, 50, 20, 1.0, 1.0, [], [])
	var buffed: int = DamageCalc.calculate_magic(100, 50, 20, 1.0, 1.0, [1.3], [])
	assert_gt(buffed, base, "resonance increases damage")


# --- Healing ---


func test_healing_basic() -> void:
	# MAG 146, power 30 → 146 * 30 * 0.8 = 3504
	var result: int = DamageCalc.calculate_healing(146, 30)
	assert_gte(result, 3285, "healing min (with variance)")
	assert_lte(result, 3504, "healing max")


func test_healing_no_defense() -> void:
	var result: int = DamageCalc.calculate_healing(50, 20)
	assert_gt(result, 0, "healing always positive")


func test_healing_cap() -> void:
	var result: int = DamageCalc.calculate_healing(255, 120)
	assert_eq(result, 14999, "healing capped at 14999")


# --- Hit/Miss ---


func test_hit_rate_base_90() -> void:
	var hits: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_hit(10, 10):
			hits += 1
	assert_between(hits, 850, 950, "~90% hit rate with equal SPD")


func test_hit_rate_minimum_20() -> void:
	var hits: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_hit(1, 255):
			hits += 1
	assert_between(hits, 150, 260, "~20% minimum hit rate")


func test_evasion_rate_cap_50() -> void:
	var evades: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_evasion(255):
			evades += 1
	assert_between(evades, 440, 560, "~50% evasion cap")


# --- Critical ---


func test_crit_rate_scales_with_lck() -> void:
	var crits: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_crit(100):
			crits += 1
	assert_between(crits, 200, 310, "~25% crit rate at LCK 100")


# --- Status ---


func test_status_zero_denominator_returns_false() -> void:
	var result: bool = DamageCalc.roll_status(75, 0, 0, 0)
	assert_false(result, "zero MAG and MDEF returns false")


# --- Flee ---


func test_flee_equal_speed() -> void:
	var chance: int = DamageCalc.calculate_flee_chance(50.0, 50.0)
	assert_eq(chance, 50, "equal speed → 50%")


func test_flee_faster_party() -> void:
	var chance: int = DamageCalc.calculate_flee_chance(100.0, 50.0)
	assert_eq(chance, 90, "fast party capped at 90")


func test_flee_slower_party() -> void:
	var chance: int = DamageCalc.calculate_flee_chance(10.0, 100.0)
	assert_eq(chance, 10, "slow party floored at 10")


# --- Variance ---


func test_variance_range() -> void:
	var min_v: float = 1.0
	var max_v: float = 0.0
	for i: int in range(1000):
		var v: float = DamageCalc.roll_variance()
		min_v = minf(min_v, v)
		max_v = maxf(max_v, v)
	assert_gte(min_v, 0.9375, "variance min >= 0.9375")
	assert_lte(max_v, 1.0, "variance max < 1.0")
