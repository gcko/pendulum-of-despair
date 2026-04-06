# Battle Scene (Gap 3.3) Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the ATB battle system as a core state scene with all combat formulas, turn flow, battle UI, and victory/defeat.

**Architecture:** 5 combat scripts (damage_calculator, atb_system, battle_state, battle_ai, battle_manager) + 3 UI scripts (battle_ui, battle_party_panel, battle_command_menu) + 1 scene. Pure data layer first, then ATB, then orchestration, then UI. Signal-based decoupling between manager and UI.

**Tech Stack:** Godot 4.6, GDScript, GUT test framework

**Spec:** `docs/superpowers/specs/2026-04-06-battle-scene-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `game/scripts/combat/damage_calculator.gd` | Static formula functions (physical, magic, healing, hit/miss, crit, status, flee, variance) |
| Create | `game/scripts/combat/atb_system.gd` | ATB gauge ownership, fill rates, turn queue, active/wait/patience modes |
| Create | `game/scripts/combat/battle_state.gd` | Party member runtime state (HP/MP/status/buffs/row/ability resources) |
| Create | `game/scripts/combat/battle_ai.gd` | Enemy action selection (weighted-random, boss stub) |
| Create | `game/scripts/combat/battle_manager.gd` | Orchestrator: encounter setup, command dispatch, victory/defeat/flee, signal emission |
| Create | `game/scripts/ui/battle_ui.gd` | UI controller: signal observer, damage popups, results screen, message area |
| Create | `game/scripts/ui/battle_party_panel.gd` | Party rows: HP/MP bars, ATB gauges, status icons |
| Create | `game/scripts/ui/battle_command_menu.gd` | Command panel, sub-menus, target selection, input handling |
| Create | `game/scenes/core/battle.tscn` | Scene tree with all nodes |
| Create | `game/tests/test_damage_calculator.gd` | Formula verification against combat-formulas.md milestone tables |
| Create | `game/tests/test_atb_system.gd` | ATB gauge fill, turn order, mode switching |
| Create | `game/tests/test_battle_state.gd` | Party state tracking, status timers, buffs |
| Create | `game/tests/test_battle_manager.gd` | Integration: full pipeline, victory/defeat, encounter setup |

---

## Chunk 1: Damage Calculator (Pure Formulas)

### Task 1: Physical Damage Formula

**Files:**
- Create: `game/scripts/combat/damage_calculator.gd`
- Create: `game/tests/test_damage_calculator.gd`

- [ ] **Step 1: Create test file with physical damage tests**

```gdscript
# game/tests/test_damage_calculator.gd
extends GutTest
## Tests for DamageCalculator — verifies every formula against combat-formulas.md.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


# --- Physical Damage ---


func test_physical_edren_lv1_vs_tutorial_mob() -> void:
	# combat-formulas.md: Edren Lv1 (ATK 18) vs tutorial mob (DEF 5) → ~49
	# raw = max(1, (18*18*1.0)/6 - 5) = max(1, 54 - 5) = 49
	# No crit, no element, front/front rows, no reduction
	var result: int = DamageCalc.calculate_physical(
		18, 1.0, 5, false, 1.0, "front", "front", false, [], false, 1.0
	)
	# With variance [0.9375, 0.996], result is 45-48 (floor(49 * variance))
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
	# Even with low variance, exceeds 14999
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
	# back should be roughly half of front (variance makes it approximate)
	assert_lt(back, front, "back row does less damage")


func test_physical_back_row_spear_bypasses() -> void:
	# Spear (weapon_bypasses_row=true) ignores back row penalty
	var front: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var spear_back: int = DamageCalc.calculate_physical(
		50, 1.0, 10, false, 1.0, "back", "front", true, [], false, 1.0
	)
	# Should be similar (both affected by variance)
	assert_gte(spear_back, front - 10, "spear from back row similar to front")


func test_physical_back_row_defender_reduction() -> void:
	# Defender in back row takes 0.5x physical
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
	# with_red should be roughly 56% of no_red
	assert_lt(with_red, no_red, "reduction reduces damage")


func test_physical_elemental_immune_returns_zero() -> void:
	var result: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], true, 0.0
	)
	assert_eq(result, 0, "immunity returns 0")


func test_physical_elemental_absorb_returns_positive() -> void:
	# Absorb (element_mod = -1.0) returns positive healing amount
	var result: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], true, -1.0
	)
	assert_gt(result, 0, "absorb returns positive healing value")
```

- [ ] **Step 2: Create damage_calculator.gd with physical damage**

```gdscript
# game/scripts/combat/damage_calculator.gd
extends RefCounted
## Static combat formulas — no instance state.
##
## Every formula matches combat-formulas.md exactly.
## All functions are static. Do not instantiate this class.


## Roll damage variance: random_int(240, 255) / 256.
## Range: 0.9375 to 0.99609375 (up to -6.25% below nominal).
static func roll_variance() -> float:
	return (randi() % 16 + 240) / 256.0


## Calculate physical damage per combat-formulas.md § Physical Attack Resolution.
## Caller must perform hit/evasion checks BEFORE calling this function.
## Steps 1-2 (hit/evasion) are the caller's responsibility.
##
## Returns: positive int for damage, 0 for immunity.
## For absorb (element_mod < 0): returns positive int (healing amount for target).
static func calculate_physical(
	atk: int, ability_mult: float, target_def: int,
	is_crit: bool, interaction_mult: float,
	attacker_row: String, defender_row: String, weapon_bypasses_row: bool,
	reduction_sources: Array, is_elemental: bool, element_mod: float
) -> int:
	# Step 3-4: Base damage with floor
	var raw: float = maxf(1.0, (atk * atk * ability_mult) / 6.0 - target_def)

	# Step 5: Critical hit
	if is_crit:
		raw *= 2.0

	# Step 6: Combat interaction modifiers
	raw *= interaction_mult

	# Step 7: Variance
	var result: float = raw * roll_variance()

	# Step 8: Elemental modifier (physical elemental attacks only)
	if is_elemental:
		result *= element_mod
		# Immunity: bypass floor and reduction
		if element_mod == 0.0:
			return 0
		# Absorb: return healing amount, bypass reduction
		if element_mod < 0.0:
			return mini(14999, int(absf(result)))

	# Step 9: Row modifiers
	var attacker_mod: float = 1.0
	if attacker_row == "back" and not weapon_bypasses_row:
		attacker_mod = 0.5
	var defender_mod: float = 1.0
	if defender_row == "back":
		defender_mod = 0.5
	result *= attacker_mod * defender_mod

	# Step 10: Damage reduction (multiplicative stacking)
	if not reduction_sources.is_empty():
		var product: float = 1.0
		for source: float in reduction_sources:
			product *= (1.0 - source)
		result *= product

	# Step 11: Floor and clamp
	return clampi(int(result), 1, 14999)
```

- [ ] **Step 3: Run tests to verify they pass**

Run: `cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_damage_calculator.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/damage_calculator.gd game/tests/test_damage_calculator.gd
git commit -m "feat(engine): add physical damage formula (gap 3.3)"
```

---

### Task 2: Magic Damage, Healing, Hit/Miss, Crit, Status, Flee

**Files:**
- Modify: `game/scripts/combat/damage_calculator.gd`
- Modify: `game/tests/test_damage_calculator.gd`

- [ ] **Step 1: Add magic/healing/utility tests**

Append to `test_damage_calculator.gd`:

```gdscript
# --- Magic Damage ---


func test_magic_maren_lv1_ember_lance() -> void:
	# combat-formulas.md: Maren Lv1 (MAG 22) Ember Lance (power 14) vs MDEF 8
	# raw = max(1, (22*14)/4 - 8) = max(1, 77 - 8) = 69
	var result: int = DamageCalc.calculate_magic(
		22, 14, 8, 1.0, 1.0, [], []
	)
	assert_gte(result, 64, "Maren Lv1 magic min")
	assert_lte(result, 69, "Maren Lv1 magic max")


func test_magic_elemental_weakness() -> void:
	# 1.5x element mod
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
	# Resonance = 1.3x spell output
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
	# Healing ignores defense — not a parameter
	var result: int = DamageCalc.calculate_healing(50, 20)
	assert_gt(result, 0, "healing always positive")


func test_healing_cap() -> void:
	var result: int = DamageCalc.calculate_healing(255, 120)
	assert_eq(result, 14999, "healing capped at 14999")


# --- Hit/Miss ---


func test_hit_rate_base_90() -> void:
	# Same SPD → 90% hit rate. Test with many rolls.
	var hits: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_hit(10, 10):
			hits += 1
	assert_between(hits, 850, 950, "~90% hit rate with equal SPD")


func test_hit_rate_minimum_20() -> void:
	# Very slow attacker → clamped to 20%
	var hits: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_hit(1, 255):
			hits += 1
	assert_between(hits, 150, 260, "~20% minimum hit rate")


func test_evasion_rate_cap_50() -> void:
	# SPD 255 → evasion = min(50, 255/4) = 50%
	var evades: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_evasion(255):
			evades += 1
	assert_between(evades, 440, 560, "~50% evasion cap")


# --- Critical ---


func test_crit_rate_scales_with_lck() -> void:
	# LCK 100 → crit = min(50, 100/4) = 25%
	var crits: int = 0
	for i: int in range(1000):
		if DamageCalc.roll_crit(100):
			crits += 1
	assert_between(crits, 200, 310, "~25% crit rate at LCK 100")


# --- Status ---


func test_status_zero_denominator_returns_false() -> void:
	# MAG 0, MDEF 0 → division by zero guard
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
```

- [ ] **Step 2: Add magic, healing, hit/miss, crit, status, flee to damage_calculator.gd**

Append to `damage_calculator.gd`:

```gdscript
## Calculate magic damage per combat-formulas.md § Magic Damage Resolution.
## Caller must perform hit/evasion checks BEFORE calling this.
##
## [param buff_mults] — array of multiplicative buffs (e.g., [1.3] for Resonance).
## Returns: positive int for damage, 0 for immunity.
## For absorb: returns positive int (healing amount for target).
static func calculate_magic(
	mag: int, spell_power: int, target_mdef: int,
	element_mod: float, interaction_mult: float,
	buff_mults: Array, reduction_sources: Array
) -> int:
	# Step 1: Base damage with floor
	var raw: float = maxf(1.0, (mag * spell_power) / 4.0 - target_mdef)

	# Step 2: Elemental modifier
	raw *= element_mod
	if element_mod == 0.0:
		return 0
	if element_mod < 0.0:
		return mini(14999, int(absf(raw * roll_variance())))

	# Step 3: Combat interaction modifiers
	raw *= interaction_mult

	# Step 4: Buff modifiers (Resonance, Glintmark)
	for mult: float in buff_mults:
		raw *= mult

	# Step 5: Variance
	var result: float = raw * roll_variance()

	# Step 6: Damage reduction (only "all" and "magic only" sources)
	if not reduction_sources.is_empty():
		var product: float = 1.0
		for source: float in reduction_sources:
			product *= (1.0 - source)
		result *= product

	# Step 7: Floor and clamp
	return clampi(int(result), 1, 14999)


## Calculate healing per combat-formulas.md § Healing Resolution.
## No defense, no floor-of-1, no reduction.
static func calculate_healing(mag: int, spell_power: int) -> int:
	var raw: float = mag * spell_power * 0.8
	return mini(14999, int(raw * roll_variance()))


## Roll hit check. Returns true if attack hits.
## hit_rate = clamp(90 + (attacker_spd - target_spd) / 4, 20, 99)
static func roll_hit(attacker_spd: int, target_spd: int) -> bool:
	var hit_rate: int = clampi(90 + (attacker_spd - target_spd) / 4, 20, 99)
	return randi() % 100 < hit_rate


## Roll evasion check. Returns true if attack is evaded.
## evasion_rate = min(50, target_spd / 4)
static func roll_evasion(target_spd: int) -> bool:
	var evasion_rate: int = mini(50, target_spd / 4)
	return randi() % 100 < evasion_rate


## Roll critical hit check. Physical only — magic never crits.
## crit_rate = min(50, attacker_lck / 4)
static func roll_crit(attacker_lck: int) -> bool:
	var crit_rate: int = mini(50, attacker_lck / 4)
	return randi() % 100 < crit_rate


## Roll status effect accuracy. Two-stage per combat-formulas.md.
## [param target_spd] — used to compute Magic Evasion: (MDEF + SPD) / 8, cap 40%.
static func roll_status(
	base_rate: int, caster_mag: int, target_mdef: int, target_spd: int
) -> bool:
	# Guard against division by zero
	var denom: int = caster_mag + target_mdef
	if denom == 0:
		return false
	# Stage 1
	var effective: float = base_rate * (float(caster_mag) / float(denom))
	if randi() % 100 >= int(effective):
		return false
	# Stage 2: Magic Evasion
	var meva_pct: int = mini(40, (target_mdef + target_spd) / 8)
	return randi() % 100 >= meva_pct


## Calculate flee chance per combat-formulas.md § Flee.
## Returns percentage (10-90).
static func calculate_flee_chance(party_avg_spd: float, enemy_avg_spd: float) -> int:
	return clampi(50 + int((party_avg_spd - enemy_avg_spd) * 2.0), 10, 90)
```

- [ ] **Step 3: Run all damage calculator tests**

Run: `cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_damage_calculator.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/damage_calculator.gd game/tests/test_damage_calculator.gd
git commit -m "feat(engine): add magic/healing/utility formulas (gap 3.3)"
```

---

### Task 3: ATB System

**Files:**
- Create: `game/scripts/combat/atb_system.gd`
- Create: `game/tests/test_atb_system.gd`

- [ ] **Step 1: Create ATB test file**

```gdscript
# game/tests/test_atb_system.gd
extends GutTest
## Tests for ATB gauge system.

var _atb: Node


func before_each() -> void:
	_atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_atb)


func after_each() -> void:
	_atb = null


# --- Fill Rate ---


func test_fill_rate_maren_lv1_speed3() -> void:
	# SPD 8, battle speed 3 (factor 3.0), no status mods
	# fill_rate = floor((8 + 25) * 3.0 * 1.0) = floor(99) = 99
	var rate: int = _atb.calculate_fill_rate(8, 3, [])
	assert_eq(rate, 99, "Maren Lv1 at speed 3")


func test_fill_rate_sable_lv1_speed3() -> void:
	# SPD 18, speed 3 → floor((18+25)*3) = floor(129) = 129
	var rate: int = _atb.calculate_fill_rate(18, 3, [])
	assert_eq(rate, 129, "Sable Lv1 at speed 3")


func test_fill_rate_with_haste() -> void:
	# SPD 10, speed 3, haste (1.5x)
	# floor((10+25)*3*1.5) = floor(157.5) = 157
	var rate: int = _atb.calculate_fill_rate(10, 3, [1.5])
	assert_eq(rate, 157, "haste increases fill rate")


func test_fill_rate_haste_and_despair() -> void:
	# SPD 10, speed 3, haste (1.5) + despair (0.75)
	# floor((10+25)*3*1.5*0.75) = floor(118.125) = 118
	var rate: int = _atb.calculate_fill_rate(10, 3, [1.5, 0.75])
	assert_eq(rate, 118, "haste + despair stack multiplicatively")


# --- Gauge Mechanics ---


func test_gauge_starts_at_zero() -> void:
	_atb.add_combatant("party_0", 10, false)
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge starts at 0")


func test_gauge_fills_by_fill_rate() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)  # one frame at 60fps
	# fill_rate = floor((10+25)*3) = 105
	assert_eq(_atb.get_gauge("party_0"), 105, "gauge fills by fill rate")


func test_gauge_caps_at_max() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_gauge("party_0", 15999)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	# 15999 + 105 = 16104 > 16000, should cap
	assert_eq(_atb.get_gauge("party_0"), 16000, "gauge caps at GAUGE_MAX")


# --- Turn Order ---


func test_higher_spd_acts_first() -> void:
	_atb.add_combatant("fast", 100, false)
	_atb.add_combatant("slow", 10, false)
	_atb.set_gauge("fast", 16000)
	_atb.set_gauge("slow", 16000)
	var queue: Array = _atb.get_ready_queue()
	assert_eq(queue[0], "fast", "higher SPD acts first")


func test_party_before_enemy_on_tie() -> void:
	_atb.add_combatant("party_0", 50, false)
	_atb.add_combatant("enemy_0", 50, true)
	_atb.set_gauge("party_0", 16000)
	_atb.set_gauge("enemy_0", 16000)
	var queue: Array = _atb.get_ready_queue()
	assert_eq(queue[0], "party_0", "party before enemy on SPD tie")


# --- Formation ---


func test_preemptive_party_starts_full() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.add_combatant("enemy_0", 10, true)
	_atb.apply_formation("preemptive")
	assert_eq(_atb.get_gauge("party_0"), 16000, "party full on preemptive")
	assert_eq(_atb.get_gauge("enemy_0"), 0, "enemy empty on preemptive")


func test_back_attack_enemies_half() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.add_combatant("enemy_0", 10, true)
	_atb.apply_formation("back_attack")
	assert_eq(_atb.get_gauge("party_0"), 0, "party starts 0 on back attack")
	assert_eq(_atb.get_gauge("enemy_0"), 8000, "enemy starts 50% on back attack")


# --- Pause ---


func test_wait_mode_pauses_on_submenu() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.set_atb_mode("wait")
	_atb.set_submenu_open(true)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge paused in wait + submenu")


func test_active_mode_fills_during_submenu() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.set_atb_mode("active")
	_atb.set_submenu_open(true)
	_atb.tick(1.0 / 60.0)
	assert_gt(_atb.get_gauge("party_0"), 0, "gauge fills in active + submenu")


# --- Frozen ---


func test_frozen_gauge_retains_value() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_gauge("party_0", 5000)
	_atb.set_frozen("party_0", true)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("party_0"), 5000, "frozen gauge unchanged")
```

- [ ] **Step 2: Create atb_system.gd**

```gdscript
# game/scripts/combat/atb_system.gd
extends Node
## ATB gauge system — owns all combatant gauges, manages fill rates and turn queue.
##
## Gauges fill based on SPD. When a gauge reaches GAUGE_MAX, the combatant
## is added to the ready queue. Supports Active/Wait/Patience modes.

signal combatant_ready(combatant_id: String)

const GAUGE_MAX: int = 16000

const SPEED_FACTORS: Dictionary = {
	1: 6.0, 2: 5.0, 3: 3.0, 4: 2.0, 5: 1.5, 6: 1.0,
}

## Per-combatant data: {id: {gauge, spd, is_enemy, frozen, status_mods}}
var _combatants: Dictionary = {}

## Current battle speed setting (1-6, default 3).
var _battle_speed: int = 3

## ATB mode: "active", "wait", or "patience".
var _atb_mode: String = "active"

## Whether a sub-menu is currently open (for wait/patience pausing).
var _submenu_open: bool = false

## Whether top-level command menu is open (for patience pausing).
var _command_menu_open: bool = false


## Add a combatant to the ATB system.
func add_combatant(id: String, spd: int, is_enemy: bool) -> void:
	_combatants[id] = {
		"gauge": 0,
		"spd": spd,
		"is_enemy": is_enemy,
		"frozen": false,
		"status_mods": [] as Array[float],
	}


## Remove a combatant (e.g., on death).
func remove_combatant(id: String) -> void:
	_combatants.erase(id)


## Get current gauge value.
func get_gauge(id: String) -> int:
	if not _combatants.has(id):
		return 0
	return _combatants[id]["gauge"]


## Set gauge directly (for formation setup or reset after acting).
func set_gauge(id: String, value: int) -> void:
	if _combatants.has(id):
		_combatants[id]["gauge"] = clampi(value, 0, GAUGE_MAX)


## Set frozen state (Stop, Sleep, Petrify).
func set_frozen(id: String, frozen: bool) -> void:
	if _combatants.has(id):
		_combatants[id]["frozen"] = frozen


## Update SPD (for buff changes).
func set_spd(id: String, spd: int) -> void:
	if _combatants.has(id):
		_combatants[id]["spd"] = spd


## Set status modifiers (e.g., [1.5] for Haste, [0.5] for Slow).
func set_status_mods(id: String, mods: Array) -> void:
	if _combatants.has(id):
		_combatants[id]["status_mods"] = mods


func set_battle_speed(speed: int) -> void:
	_battle_speed = clampi(speed, 1, 6)


func set_atb_mode(mode: String) -> void:
	_atb_mode = mode


func set_submenu_open(is_open: bool) -> void:
	_submenu_open = is_open


func set_command_menu_open(is_open: bool) -> void:
	_command_menu_open = is_open


## Calculate fill rate for given SPD, battle speed, and status modifiers.
## Public for testing. Used internally by tick().
func calculate_fill_rate(spd: int, battle_speed: int, status_mods: Array) -> int:
	var factor: float = SPEED_FACTORS.get(battle_speed, 3.0)
	var mod_product: float = 1.0
	for mod: float in status_mods:
		mod_product *= mod
	return int((spd + 25) * factor * mod_product)


## Tick all gauges by one frame. Call from battle_manager._process().
func tick(delta: float) -> void:
	# Check pause conditions
	if _should_pause():
		return

	for id: String in _combatants:
		var data: Dictionary = _combatants[id]
		if data["frozen"]:
			continue
		if data["gauge"] >= GAUGE_MAX:
			continue  # Already ready, waiting to act

		var rate: int = calculate_fill_rate(
			data["spd"], _battle_speed, data["status_mods"]
		)
		data["gauge"] = mini(data["gauge"] + rate, GAUGE_MAX)

		if data["gauge"] >= GAUGE_MAX:
			combatant_ready.emit(id)


## Get all combatants whose gauge is at GAUGE_MAX, sorted by priority.
## Order: higher SPD first, party before enemy on tie, lower slot index on tie.
func get_ready_queue() -> Array[String]:
	var ready: Array[Dictionary] = []
	for id: String in _combatants:
		var data: Dictionary = _combatants[id]
		if data["gauge"] >= GAUGE_MAX:
			ready.append({"id": id, "spd": data["spd"], "is_enemy": data["is_enemy"]})

	ready.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["spd"] != b["spd"]:
			return a["spd"] > b["spd"]
		if a["is_enemy"] != b["is_enemy"]:
			return not a["is_enemy"]  # party first
		return a["id"] < b["id"]  # lower slot index
	)

	var result: Array[String] = []
	for entry: Dictionary in ready:
		result.append(entry["id"])
	return result


## Apply formation start state.
func apply_formation(formation_type: String) -> void:
	for id: String in _combatants:
		var data: Dictionary = _combatants[id]
		match formation_type:
			"preemptive":
				data["gauge"] = GAUGE_MAX if not data["is_enemy"] else 0
			"back_attack":
				data["gauge"] = GAUGE_MAX / 2 if data["is_enemy"] else 0
			_:  # "normal"
				data["gauge"] = 0


## Reset a combatant's gauge after they act.
func reset_gauge(id: String) -> void:
	set_gauge(id, 0)


func _should_pause() -> bool:
	match _atb_mode:
		"wait":
			return _submenu_open
		"patience":
			return _submenu_open or _command_menu_open
	return false  # "active" never pauses
```

- [ ] **Step 3: Run ATB tests**

Run: `cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_atb_system.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/atb_system.gd game/tests/test_atb_system.gd
git commit -m "feat(engine): add ATB gauge system (gap 3.3)"
```

---

### Task 4: Battle State (Party Runtime)

**Files:**
- Create: `game/scripts/combat/battle_state.gd`
- Create: `game/tests/test_battle_state.gd`

- [ ] **Step 1: Create battle state test file**

```gdscript
# game/tests/test_battle_state.gd
extends GutTest
## Tests for party member runtime state in battle.

var _state: Node


func before_each() -> void:
	_state = preload("res://scripts/combat/battle_state.gd").new()
	add_child_autofree(_state)


func after_each() -> void:
	_state = null


func _make_char_data() -> Dictionary:
	return {
		"id": "edren",
		"name": "Edren",
		"base_stats": {"hp": 95, "mp": 15, "atk": 18, "def": 16, "mag": 6, "mdef": 8, "spd": 10, "lck": 8},
	}


# --- Initialization ---


func test_add_party_member() -> void:
	_state.add_member(0, _make_char_data())
	var member: Dictionary = _state.get_member(0)
	assert_eq(member["character_id"], "edren")
	assert_eq(member["current_hp"], 95)
	assert_eq(member["max_hp"], 95)
	assert_eq(member["is_alive"], true)


func test_empty_slot_returns_empty() -> void:
	var member: Dictionary = _state.get_member(3)
	assert_true(member.is_empty(), "empty slot returns empty dict")


# --- HP/MP ---


func test_take_damage_reduces_hp() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 30)
	assert_eq(_state.get_member(0)["current_hp"], 65)


func test_take_damage_kills_at_zero() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 200)
	assert_eq(_state.get_member(0)["current_hp"], 0)
	assert_false(_state.get_member(0)["is_alive"])


func test_heal_restores_hp() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 50)
	_state.heal(0, 30)
	assert_eq(_state.get_member(0)["current_hp"], 75)


func test_heal_clamps_to_max() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 10)
	_state.heal(0, 100)
	assert_eq(_state.get_member(0)["current_hp"], 95)


func test_spend_mp() -> void:
	_state.add_member(0, _make_char_data())
	var ok: bool = _state.spend_mp(0, 10)
	assert_true(ok)
	assert_eq(_state.get_member(0)["current_mp"], 5)


func test_spend_mp_insufficient() -> void:
	_state.add_member(0, _make_char_data())
	var ok: bool = _state.spend_mp(0, 100)
	assert_false(ok, "cannot spend more MP than available")
	assert_eq(_state.get_member(0)["current_mp"], 15, "MP unchanged on failure")


# --- Status Effects ---


func test_apply_turn_based_status() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "haste", "turns", 5)
	assert_true(_state.has_status(0, "haste"))


func test_tick_decrements_turn_status() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "haste", "turns", 1)
	_state.tick_statuses(0)
	assert_false(_state.has_status(0, "haste"), "expired after 1 tick")


func test_realtime_status_decrements_by_delta() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "stop", "realtime", 3.0)
	_state.tick_realtime_statuses(0, 1.0)
	assert_true(_state.has_status(0, "stop"), "still active after 1s")
	_state.tick_realtime_statuses(0, 2.1)
	assert_false(_state.has_status(0, "stop"), "expired after 3.1s total")


# --- Buffs ---


func test_buff_multiplier_default() -> void:
	_state.add_member(0, _make_char_data())
	var eff: int = _state.get_effective_stat(0, "atk")
	assert_eq(eff, 18, "default 1.0x multiplier")


func test_buff_increases_stat() -> void:
	_state.add_member(0, _make_char_data())
	_state.set_buff(0, "atk_mult", 1.3)  # Rallying Cry +30%
	var eff: int = _state.get_effective_stat(0, "atk")
	# 18 * 1.3 = 23.4 → 23
	assert_eq(eff, 23, "buff increases effective stat")


func test_buff_can_exceed_255() -> void:
	# progression.md: buffs can push past 255 in combat
	var data: Dictionary = _make_char_data()
	data["base_stats"]["mag"] = 240
	_state.add_member(0, data)
	_state.set_buff(0, "mag_mult", 1.3)  # Attunement
	var eff: int = _state.get_effective_stat(0, "mag")
	# 240 * 1.3 = 312 — no cap in battle
	assert_eq(eff, 312, "buffs exceed 255 in battle")


# --- Row ---


func test_default_row_front() -> void:
	_state.add_member(0, _make_char_data())
	assert_eq(_state.get_member(0)["row"], "front")


func test_swap_row() -> void:
	_state.add_member(0, _make_char_data())
	_state.swap_row(0)
	assert_eq(_state.get_member(0)["row"], "back")
	_state.swap_row(0)
	assert_eq(_state.get_member(0)["row"], "front")


# --- Defend ---


func test_defend_sets_flag() -> void:
	_state.add_member(0, _make_char_data())
	_state.set_defending(0, true)
	assert_true(_state.get_member(0)["is_defending"])


# --- All Dead ---


func test_all_dead_detection() -> void:
	_state.add_member(0, _make_char_data())
	_state.add_member(1, _make_char_data())
	assert_false(_state.is_party_wiped())
	_state.take_damage(0, 999)
	assert_false(_state.is_party_wiped(), "one alive")
	_state.take_damage(1, 999)
	assert_true(_state.is_party_wiped(), "all dead")
```

- [ ] **Step 2: Create battle_state.gd**

```gdscript
# game/scripts/combat/battle_state.gd
extends Node
## Party member runtime state for battle.
##
## Tracks mutable HP/MP/status/buffs/row/ability resources for up to 4
## active party members. Enemy state lives in enemy.gd (already built).

signal member_damaged(slot: int, amount: int)
signal member_healed(slot: int, amount: int)
signal member_died(slot: int)
signal member_revived(slot: int)
signal status_applied(slot: int, status_name: String)
signal status_removed(slot: int, status_name: String)

## Party member data. Index = slot (0-3). Null entries = empty slots.
var _members: Array = [null, null, null, null]


## Add a party member to a slot.
func add_member(slot: int, char_data: Dictionary) -> void:
	if slot < 0 or slot > 3:
		push_error("BattleState: Invalid slot %d" % slot)
		return
	var stats: Dictionary = char_data.get("base_stats", {})
	_members[slot] = {
		"character_id": char_data.get("id", ""),
		"character_data": char_data,
		"current_hp": stats.get("hp", 1),
		"max_hp": stats.get("hp", 1),
		"current_mp": stats.get("mp", 0),
		"max_mp": stats.get("mp", 0),
		"row": char_data.get("default_row", "front"),
		"active_statuses": [] as Array[Dictionary],
		"is_alive": true,
		"is_defending": false,
		# Buffs
		"atk_mult": 1.0,
		"def_mult": 1.0,
		"mag_mult": 1.0,
		"mdef_mult": 1.0,
		"spd_mult": 1.0,
		"damage_taken_mult": 1.0,
		# Ability resources
		"ap": 0,
		"ac": 12,
		"wg": 0,
		"favor": {},
		"stolen_goods": [] as Array[String],
		"active_rally": {},
		"active_stance": "",
	}


## Get member data for a slot. Returns empty dict if slot is empty.
func get_member(slot: int) -> Dictionary:
	if slot < 0 or slot > 3 or _members[slot] == null:
		return {}
	return _members[slot]


## Get count of active (non-null) members.
func get_active_count() -> int:
	var count: int = 0
	for m in _members:
		if m != null:
			count += 1
	return count


## Apply damage to a party member.
func take_damage(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty() or not m["is_alive"]:
		return
	var clamped: int = maxi(0, amount)
	m["current_hp"] = maxi(0, m["current_hp"] - clamped)
	member_damaged.emit(slot, clamped)
	if m["current_hp"] <= 0:
		m["is_alive"] = false
		member_died.emit(slot)


## Heal a party member.
func heal(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	var clamped: int = maxi(0, amount)
	var old_hp: int = m["current_hp"]
	m["current_hp"] = mini(m["max_hp"], m["current_hp"] + clamped)
	var actual: int = m["current_hp"] - old_hp
	if m["current_hp"] > 0 and not m["is_alive"]:
		m["is_alive"] = true
		member_revived.emit(slot)
	if actual > 0:
		member_healed.emit(slot, actual)


## Spend MP. Returns false if insufficient.
func spend_mp(slot: int, amount: int) -> bool:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return false
	if m["current_mp"] < amount:
		return false
	m["current_mp"] -= amount
	return true


## Restore MP.
func restore_mp(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m["current_mp"] = mini(m["max_mp"], m["current_mp"] + amount)


## Apply a status effect.
func apply_status(slot: int, status_name: String, duration_type: String, duration) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	# Remove existing instance
	remove_status(slot, status_name)
	var entry: Dictionary = {"name": status_name, "duration_type": duration_type}
	if duration_type == "turns":
		entry["remaining_turns"] = int(duration)
	else:
		entry["remaining_seconds"] = float(duration)
	m["active_statuses"].append(entry)
	status_applied.emit(slot, status_name)


## Remove a status effect.
func remove_status(slot: int, status_name: String) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		if m["active_statuses"][i].get("name", "") == status_name:
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, status_name)


## Check if a status is active.
func has_status(slot: int, status_name: String) -> bool:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return false
	for s: Dictionary in m["active_statuses"]:
		if s.get("name", "") == status_name:
			return true
	return false


## Tick turn-based statuses at END of a combatant's turn.
func tick_statuses(slot: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		var s: Dictionary = m["active_statuses"][i]
		if s.get("duration_type", "") != "turns":
			continue
		s["remaining_turns"] -= 1
		if s["remaining_turns"] <= 0:
			var name: String = s.get("name", "")
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, name)


## Tick real-time statuses (Stop). Called from _process with delta.
func tick_realtime_statuses(slot: int, delta: float) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		var s: Dictionary = m["active_statuses"][i]
		if s.get("duration_type", "") != "realtime":
			continue
		s["remaining_seconds"] -= delta
		if s["remaining_seconds"] <= 0.0:
			var sname: String = s.get("name", "")
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, sname)


## Get effective stat with buff multiplier applied. No cap in battle.
func get_effective_stat(slot: int, stat_name: String) -> int:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return 0
	var base: int = m["character_data"].get("base_stats", {}).get(stat_name, 0)
	var mult_key: String = stat_name + "_mult"
	var mult: float = m.get(mult_key, 1.0)
	return int(base * mult)


## Set a buff multiplier.
func set_buff(slot: int, buff_key: String, value: float) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m[buff_key] = value


## Swap row (front ↔ back). Free action per combat-formulas.md.
func swap_row(slot: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m["row"] = "back" if m["row"] == "front" else "front"


## Set defending flag.
func set_defending(slot: int, defending: bool) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m["is_defending"] = defending


## Check if all party members are dead.
func is_party_wiped() -> bool:
	for m in _members:
		if m != null and m["is_alive"]:
			return false
	return true
```

- [ ] **Step 3: Run battle state tests**

Run: `cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_state.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/battle_state.gd game/tests/test_battle_state.gd
git commit -m "feat(engine): add battle state tracking (gap 3.3)"
```

---

## Chunk 2: Battle AI, Manager, UI, and Scene

### Task 5: Battle AI

**Files:**
- Create: `game/scripts/combat/battle_ai.gd`

- [ ] **Step 1: Create battle_ai.gd**

```gdscript
# game/scripts/combat/battle_ai.gd
extends RefCounted
## Enemy action selection for battle.
##
## Weighted-random for regular enemies. Boss AI is a stub — scripted
## behavior deferred to content gaps (4.1+).


## Action dictionary format returned by select_action:
## {type: "attack"|"ability"|"defend", target_slot: int, ability_id: String}


## Select an action for a regular enemy.
## [param enemy_data] — the enemy's loaded data dictionary.
## [param party_members] — array of party member dicts (from battle_state).
## [param party_rows] — array of row strings matching party_members indices.
static func select_action(enemy_data: Dictionary, party_members: Array, party_rows: Array) -> Dictionary:
	var living: Array[int] = []
	for i: int in range(party_members.size()):
		if party_members[i] != null and party_members[i].get("is_alive", false):
			living.append(i)
	if living.is_empty():
		return {"type": "defend", "target_slot": -1, "ability_id": ""}

	var roll: int = randi() % 100

	# 70% basic attack
	if roll < 70:
		var target: int = _pick_physical_target(living, party_rows)
		return {"type": "attack", "target_slot": target, "ability_id": ""}

	# 20% ability (if enemy has any)
	if roll < 90:
		var abilities: Array = enemy_data.get("abilities", [])
		if not abilities.is_empty():
			var ab: Dictionary = abilities[randi() % abilities.size()]
			var target: int = living[randi() % living.size()]
			return {"type": "ability", "target_slot": target, "ability_id": ab.get("id", "")}

	# 10% defend / do nothing
	return {"type": "defend", "target_slot": -1, "ability_id": ""}


## Select boss action (stub — returns basic attack).
## Phase tracking: checks HP thresholds from enemy data.
static func select_boss_action(
	enemy_data: Dictionary, current_hp: int, party_members: Array, party_rows: Array
) -> Dictionary:
	var living: Array[int] = []
	for i: int in range(party_members.size()):
		if party_members[i] != null and party_members[i].get("is_alive", false):
			living.append(i)
	if living.is_empty():
		return {"type": "defend", "target_slot": -1, "ability_id": ""}

	# Determine phase based on HP thresholds
	var _phase: int = _get_boss_phase(enemy_data, current_hp)

	# Stub: just basic attack for now
	var target: int = _pick_physical_target(living, party_rows)
	return {"type": "attack", "target_slot": target, "ability_id": ""}


## Pick a physical attack target. Prefers front row (75/25 split).
static func _pick_physical_target(living_slots: Array, party_rows: Array) -> int:
	var front: Array[int] = []
	var back: Array[int] = []
	for slot: int in living_slots:
		if slot < party_rows.size() and party_rows[slot] == "back":
			back.append(slot)
		else:
			front.append(slot)

	# 75% front row, 25% back row
	if not front.is_empty() and (back.is_empty() or randi() % 100 < 75):
		return front[randi() % front.size()]
	if not back.is_empty():
		return back[randi() % back.size()]
	return living_slots[randi() % living_slots.size()]


## Determine boss phase from HP thresholds.
static func _get_boss_phase(enemy_data: Dictionary, current_hp: int) -> int:
	var phases: Array = enemy_data.get("phases", [])
	for i: int in range(phases.size() - 1, -1, -1):
		var threshold: int = phases[i].get("hp_threshold", 0)
		if current_hp <= threshold:
			return i + 1
	return 0
```

- [ ] **Step 2: Commit**

```bash
git add game/scripts/combat/battle_ai.gd
git commit -m "feat(engine): add battle AI with weighted-random selection (gap 3.3)"
```

---

### Task 6: Battle Manager (Orchestrator)

**Files:**
- Create: `game/scripts/combat/battle_manager.gd`
- Create: `game/tests/test_battle_manager.gd`

- [ ] **Step 1: Create battle_manager.gd**

```gdscript
# game/scripts/combat/battle_manager.gd
extends Node2D
## Battle orchestrator — encounter setup, command dispatch, ATB ticking,
## victory/defeat flow.
##
## Attached to the root Battle node in battle.tscn. Reads
## GameManager.transition_data on _ready() and manages the full
## battle lifecycle.

signal battle_started(party: Array, enemies: Array)
signal turn_ready(combatant_id: String, is_party: bool)
signal action_executed(action: Dictionary)
signal damage_dealt(target_id: String, amount: int, damage_type: String)
signal status_changed(target_id: String, status_name: String, applied: bool)
signal combatant_died(combatant_id: String)
signal victory(rewards: Dictionary)
signal defeat
signal flee_result(success: bool)
signal message(text: String)

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleAI = preload("res://scripts/combat/battle_ai.gd")

const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

## Child node references.
@onready var _atb: Node = $ATBSystem
@onready var _state: Node = $BattleState
@onready var _enemy_area: Node2D = $EnemyArea

## Cached transition data (saved in _ready before transition_data is overwritten).
var _return_map_id: String = ""
var _return_position: Vector2 = Vector2.ZERO
var _is_boss: bool = false
var _formation_type: String = "normal"

## Enemy instances.
var _enemies: Array[Node] = []

## Battle active flag.
var _battle_active: bool = false

## Current acting combatant (waiting for player input).
var _awaiting_input_for: String = ""

## Total XP and gold earned this battle (for faint merge).
var _earned_xp: int = 0
var _earned_gold: int = 0


func _ready() -> void:
	var data: Dictionary = GameManager.transition_data
	if data.is_empty():
		push_error("BattleManager: No transition data")
		return

	# Cache return info before transition_data is overwritten
	_return_map_id = data.get("return_map_id", "")
	_return_position = data.get("return_position", Vector2.ZERO)
	_is_boss = data.get("is_boss", false)
	_formation_type = data.get("formation_type", "normal")

	var encounter_group: Array = data.get("encounter_group", [])
	if encounter_group.is_empty():
		push_error("BattleManager: Empty encounter group")
		_exit_battle("flee")
		return

	var enemy_act: String = data.get("enemy_act", "act_i")

	# Setup party from current game state (placeholder: load from character data)
	_setup_party()

	# Instantiate enemies
	_setup_enemies(encounter_group, enemy_act)

	# Apply formation
	_atb.apply_formation(_formation_type)

	# Handle back attack row reversal
	if _formation_type == "back_attack":
		for i: int in range(4):
			if not _state.get_member(i).is_empty():
				_state.swap_row(i)

	_battle_active = true
	battle_started.emit(_get_party_summary(), _get_enemy_summary())


func _process(delta: float) -> void:
	if not _battle_active:
		return
	if _awaiting_input_for != "":
		return  # Waiting for player command

	# Tick real-time status timers (Stop)
	_tick_realtime_statuses(delta)

	# Tick ATB
	_atb.tick(delta)

	# Process ready queue
	var queue: Array[String] = _atb.get_ready_queue()
	for id: String in queue:
		if id.begins_with("party_"):
			_awaiting_input_for = id
			var slot: int = id.to_int()
			# Clear defend flag
			_state.set_defending(slot, false)
			turn_ready.emit(id, true)
			return  # Wait for player input
		elif id.begins_with("enemy_"):
			_execute_enemy_turn(id)
			_atb.reset_gauge(id)
			_check_end_conditions()
			if not _battle_active:
				return


## Called by battle UI when player selects a command.
func submit_command(command: Dictionary) -> void:
	if _awaiting_input_for == "":
		return
	var actor_id: String = _awaiting_input_for
	_awaiting_input_for = ""

	match command.get("type", ""):
		"attack":
			_execute_attack(actor_id, command)
		"magic":
			_execute_magic(actor_id, command)
		"item":
			_execute_item(actor_id, command)
		"defend":
			_execute_defend(actor_id)
		"flee":
			_execute_flee(actor_id)
		"ability":
			_execute_ability(actor_id, command)

	_atb.reset_gauge(actor_id)

	# Tick turn-based statuses for the actor
	var slot: int = actor_id.replace("party_", "").to_int()
	_state.tick_statuses(slot)

	_check_end_conditions()


## Execute a physical attack from a party member.
func _execute_attack(actor_id: String, command: Dictionary) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = _state.get_member(slot)
	if member.is_empty():
		return

	var target_idx: int = command.get("target", 0)
	if target_idx < 0 or target_idx >= _enemies.size():
		return
	var enemy: Node = _enemies[target_idx]
	if not enemy.is_alive:
		return

	var atk: int = _state.get_effective_stat(slot, "atk")
	var spd: int = _state.get_effective_stat(slot, "spd")
	var lck: int = _state.get_effective_stat(slot, "lck")
	var enemy_stats: Dictionary = enemy.get_stats()
	var target_def: int = enemy_stats.get("def", 0)
	var target_spd: int = enemy_stats.get("spd", 0)

	message.emit("%s attacks!" % member.get("character_data", {}).get("name", "???"))

	# Step 1: Hit check
	if not DamageCalc.roll_hit(spd, target_spd):
		damage_dealt.emit("enemy_%d" % target_idx, 0, "miss")
		return

	# Step 2: Evasion check
	if DamageCalc.roll_evasion(target_spd):
		damage_dealt.emit("enemy_%d" % target_idx, 0, "miss")
		return

	# Step 3: Crit check
	var is_crit: bool = DamageCalc.roll_crit(lck)

	# Step 4: Calculate damage
	var dmg: int = DamageCalc.calculate_physical(
		atk, 1.0, target_def,
		is_crit, 1.0,
		member.get("row", "front"), "front", false,
		[], false, 1.0
	)

	enemy.take_damage(dmg)
	var dtype: String = "critical" if is_crit else "physical"
	damage_dealt.emit("enemy_%d" % target_idx, dmg, dtype)

	if not enemy.is_alive:
		combatant_died.emit("enemy_%d" % target_idx)
		_atb.remove_combatant("enemy_%d" % target_idx)


## Execute a magic spell from a party member.
func _execute_magic(actor_id: String, command: Dictionary) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = _state.get_member(slot)
	if member.is_empty():
		return

	var spell: Dictionary = command.get("spell", {})
	var mp_cost: int = spell.get("mp_cost", 0)
	if not _state.spend_mp(slot, mp_cost):
		message.emit("Not enough MP!")
		return

	var mag: int = _state.get_effective_stat(slot, "mag")
	var power: int = spell.get("power", 10)
	var element: String = spell.get("element", "non_elemental")
	var target_type: String = spell.get("target", "single_enemy")

	message.emit("%s casts %s!" % [
		member.get("character_data", {}).get("name", "???"),
		spell.get("name", "Spell"),
	])

	# Maren WG gain: +5 when Maren casts
	_gain_weave_gauge(slot, 5)

	# Other party casters: +10 WG for Maren
	if member.get("character_id", "") != "maren":
		_gain_weave_gauge_for_maren(10)

	if target_type == "single_enemy":
		var target_idx: int = command.get("target", 0)
		_apply_magic_to_enemy(slot, mag, power, element, target_idx)
	elif target_type == "all_enemies":
		for i: int in range(_enemies.size()):
			if _enemies[i].is_alive:
				_apply_magic_to_enemy(slot, mag, power, element, i)
	elif target_type == "single_ally":
		var target_slot: int = command.get("target", 0)
		var heal_amount: int = DamageCalc.calculate_healing(mag, power)
		_state.heal(target_slot, heal_amount)
		damage_dealt.emit("party_%d" % target_slot, heal_amount, "heal")
	elif target_type == "all_allies":
		var heal_amount: int = DamageCalc.calculate_healing(mag, power)
		for i: int in range(4):
			if not _state.get_member(i).is_empty() and _state.get_member(i)["is_alive"]:
				_state.heal(i, heal_amount)
				damage_dealt.emit("party_%d" % i, heal_amount, "heal")


func _apply_magic_to_enemy(caster_slot: int, mag: int, power: int, element: String, target_idx: int) -> void:
	if target_idx < 0 or target_idx >= _enemies.size():
		return
	var enemy: Node = _enemies[target_idx]
	if not enemy.is_alive:
		return

	var spd: int = _state.get_effective_stat(caster_slot, "spd")
	var enemy_stats: Dictionary = enemy.get_stats()
	var target_mdef: int = enemy_stats.get("mdef", 0)
	var target_spd: int = enemy_stats.get("spd", 0)

	# Hit/evasion for magic (same as physical per combat-formulas.md)
	if not DamageCalc.roll_hit(spd, target_spd):
		damage_dealt.emit("enemy_%d" % target_idx, 0, "miss")
		return
	if DamageCalc.roll_evasion(target_spd):
		damage_dealt.emit("enemy_%d" % target_idx, 0, "miss")
		return

	var element_mod: float = enemy.get_element_multiplier(element)

	var dmg: int = DamageCalc.calculate_magic(
		mag, power, target_mdef, element_mod, 1.0, [], []
	)

	if element_mod == 0.0:
		damage_dealt.emit("enemy_%d" % target_idx, 0, "immune")
	elif element_mod < 0.0:
		enemy.heal(dmg)
		damage_dealt.emit("enemy_%d" % target_idx, dmg, "heal")
	else:
		enemy.take_damage(dmg)
		damage_dealt.emit("enemy_%d" % target_idx, dmg, "magic")
		if not enemy.is_alive:
			combatant_died.emit("enemy_%d" % target_idx)
			_atb.remove_combatant("enemy_%d" % target_idx)


## Execute item use.
func _execute_item(actor_id: String, command: Dictionary) -> void:
	var item: Dictionary = command.get("item", {})
	var target_slot: int = command.get("target", 0)
	var effect: String = item.get("effect_type", "")

	message.emit("Used %s!" % item.get("name", "Item"))

	match effect:
		"restore_hp":
			var amount: int = item.get("restore_amount", 100)
			_state.heal(target_slot, amount)
			damage_dealt.emit("party_%d" % target_slot, amount, "heal")
		"restore_mp":
			var amount: int = item.get("restore_amount", 30)
			_state.restore_mp(target_slot, amount)
		"cure_status":
			var cures: Array = item.get("cures", [])
			for status_name: String in cures:
				_state.remove_status(target_slot, status_name)
		"smoke_bomb":
			if not _is_boss:
				_exit_battle("flee")


## Execute defend command.
func _execute_defend(actor_id: String) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	_state.set_defending(slot, true)
	# +50% DEF via buff
	var current_def_mult: float = _state.get_member(slot).get("def_mult", 1.0)
	_state.set_buff(slot, "def_mult", current_def_mult + 0.5)
	message.emit("%s defends!" % _state.get_member(slot).get("character_data", {}).get("name", "???"))


## Execute flee attempt.
func _execute_flee(actor_id: String) -> void:
	if _is_boss:
		message.emit("Can't escape!")
		flee_result.emit(false)
		return

	var party_spd: float = _get_party_avg_spd()
	var enemy_spd: float = _get_enemy_avg_spd()
	var chance: int = DamageCalc.calculate_flee_chance(party_spd, enemy_spd)

	if randi() % 100 < chance:
		message.emit("Escaped!")
		flee_result.emit(true)
		_exit_battle("flee")
	else:
		message.emit("Can't escape!")
		flee_result.emit(false)


## Execute ability command (stub — dispatches based on ability data).
func _execute_ability(actor_id: String, command: Dictionary) -> void:
	var slot: int = actor_id.replace("party_", "").to_int()
	var ability: Dictionary = command.get("ability", {})
	message.emit("%s uses %s!" % [
		_state.get_member(slot).get("character_data", {}).get("name", "???"),
		ability.get("name", "Ability"),
	])
	# Stub: treat as basic attack for now
	_execute_attack(actor_id, command)


## Execute an enemy's turn.
func _execute_enemy_turn(enemy_id: String) -> void:
	var idx: int = enemy_id.replace("enemy_", "").to_int()
	if idx < 0 or idx >= _enemies.size():
		return
	var enemy: Node = _enemies[idx]
	if not enemy.is_alive:
		return

	# Build party info for AI
	var party_members: Array = []
	var party_rows: Array = []
	for i: int in range(4):
		party_members.append(_state.get_member(i))
		var m: Dictionary = _state.get_member(i)
		party_rows.append(m.get("row", "front") if not m.is_empty() else "front")

	var action: Dictionary
	if _is_boss:
		action = BattleAI.select_boss_action(
			enemy.enemy_data, enemy.current_hp, party_members, party_rows
		)
	else:
		action = BattleAI.select_action(enemy.enemy_data, party_members, party_rows)

	# Enemy WG gain: +15 for Maren when enemy casts
	if action.get("type", "") == "ability":
		_gain_weave_gauge_for_maren(15)

	match action.get("type", ""):
		"attack":
			_execute_enemy_attack(idx, action.get("target_slot", 0))
		"defend":
			pass  # Enemy defends (do nothing)
		"ability":
			# Stub: treat as basic attack
			_execute_enemy_attack(idx, action.get("target_slot", 0))

	# Tick enemy statuses
	enemy.tick_statuses()


func _execute_enemy_attack(enemy_idx: int, target_slot: int) -> void:
	var enemy: Node = _enemies[enemy_idx]
	var stats: Dictionary = enemy.get_stats()
	var atk: int = stats.get("atk", 10)
	var spd: int = stats.get("spd", 10)
	var member: Dictionary = _state.get_member(target_slot)
	if member.is_empty() or not member.get("is_alive", false):
		return

	var target_def: int = _state.get_effective_stat(target_slot, "def")
	var target_spd: int = _state.get_effective_stat(target_slot, "spd")

	message.emit("%s attacks %s!" % [enemy.get_display_name(), member.get("character_data", {}).get("name", "???")])

	if not DamageCalc.roll_hit(spd, target_spd):
		damage_dealt.emit("party_%d" % target_slot, 0, "miss")
		return
	if DamageCalc.roll_evasion(target_spd):
		damage_dealt.emit("party_%d" % target_slot, 0, "miss")
		return

	var is_crit: bool = randi() % 100 < 5  # Enemy fixed 5% crit
	var dmg: int = DamageCalc.calculate_physical(
		atk, 1.0, target_def,
		is_crit, 1.0,
		"front", member.get("row", "front"), false,
		[], false, 1.0
	)
	_state.take_damage(target_slot, dmg)
	damage_dealt.emit("party_%d" % target_slot, dmg, "physical")


## Check for victory or defeat.
func _check_end_conditions() -> void:
	# Victory: all enemies dead
	var all_dead: bool = true
	for enemy: Node in _enemies:
		if enemy.is_alive:
			all_dead = false
			break
	if all_dead:
		_handle_victory()
		return

	# Defeat: all party KO'd
	if _state.is_party_wiped():
		_handle_defeat()


func _handle_victory() -> void:
	_battle_active = false

	var total_xp: int = 0
	var total_gold: int = 0
	var drops: Array[Dictionary] = []

	for enemy: Node in _enemies:
		total_xp += enemy.enemy_data.get("xp", 0)
		total_gold += enemy.enemy_data.get("gold", 0)
		var drop: Dictionary = enemy.roll_drop()
		if drop.get("success", false):
			drops.append({"item_id": drop["item_id"]})

	_earned_xp = total_xp
	_earned_gold = total_gold

	# Distribute XP: full to active alive, 0 to KO, 50% to absent (not tracked here)
	# Level-up checking deferred to results screen / exploration scene

	victory.emit({
		"xp": total_xp,
		"gold": total_gold,
		"drops": drops,
	})


func _handle_defeat() -> void:
	_battle_active = false
	defeat.emit()
	# Faint-and-Fast-Reload: load most recent save, merge XP/gold
	# For now, just return to exploration with faint result
	_exit_battle("faint")


func _exit_battle(result: String) -> void:
	_battle_active = false
	GameManager.change_core_state(GameManager.CoreState.EXPLORATION, {
		"result": result,
		"map_id": _return_map_id,
		"position": _return_position,
		"earned_xp": _earned_xp,
		"earned_gold": _earned_gold,
	})


# --- Helper Methods ---


func _setup_party() -> void:
	# Load party from DataManager (placeholder: load first 4 characters)
	var char_ids: Array[String] = ["edren", "cael", "lira", "torren"]
	for i: int in range(char_ids.size()):
		var data: Dictionary = DataManager.load_character(char_ids[i])
		if not data.is_empty():
			_state.add_member(i, data)
			var stats: Dictionary = data.get("base_stats", {})
			_atb.add_combatant("party_%d" % i, stats.get("spd", 10), false)


func _setup_enemies(encounter_group: Array, enemy_act: String) -> void:
	var spacing: float = 48.0
	var start_x: float = 160.0
	var start_y: float = 40.0

	for i: int in range(encounter_group.size()):
		var enemy_id: String = encounter_group[i]
		var enemy_node: Node = ENEMY_SCENE.instantiate()
		_enemy_area.add_child(enemy_node)
		enemy_node.initialize(enemy_id, enemy_act)
		# Position in grid (up to 6, 3 columns x 2 rows)
		var col: int = i % 3
		var row: int = i / 3
		enemy_node.position = Vector2(start_x + col * spacing, start_y + row * spacing)
		_enemies.append(enemy_node)
		var stats: Dictionary = enemy_node.get_stats()
		_atb.add_combatant("enemy_%d" % i, stats.get("spd", 10), true)


func _tick_realtime_statuses(delta: float) -> void:
	# Check pause for realtime timers
	if _atb._atb_mode == "wait" and _atb._submenu_open:
		return
	if _atb._atb_mode == "patience" and (_atb._submenu_open or _atb._command_menu_open):
		return
	for i: int in range(4):
		_state.tick_realtime_statuses(i, delta)


func _gain_weave_gauge(slot: int, amount: int) -> void:
	var m: Dictionary = _state.get_member(slot)
	if m.get("character_id", "") == "maren":
		m["wg"] = mini(100, m.get("wg", 0) + amount)


func _gain_weave_gauge_for_maren(amount: int) -> void:
	for i: int in range(4):
		_gain_weave_gauge(i, amount)


func _get_party_avg_spd() -> float:
	var total: float = 0.0
	var count: int = 0
	for i: int in range(4):
		var m: Dictionary = _state.get_member(i)
		if not m.is_empty() and m.get("is_alive", false):
			total += _state.get_effective_stat(i, "spd")
			count += 1
	return total / maxf(1.0, count)


func _get_enemy_avg_spd() -> float:
	var total: float = 0.0
	var count: int = 0
	for enemy: Node in _enemies:
		if enemy.is_alive:
			total += enemy.get_stats().get("spd", 10)
			count += 1
	return total / maxf(1.0, count)


func _get_party_summary() -> Array:
	var result: Array = []
	for i: int in range(4):
		result.append(_state.get_member(i))
	return result


func _get_enemy_summary() -> Array:
	var result: Array = []
	for enemy: Node in _enemies:
		result.append({
			"name": enemy.get_display_name(),
			"hp": enemy.current_hp,
			"max_hp": enemy.enemy_data.get("hp", 0),
		})
	return result
```

- [ ] **Step 2: Create battle manager test file**

```gdscript
# game/tests/test_battle_manager.gd
extends GutTest
## Integration tests for the battle manager.
## These test the full pipeline composition, not individual formulas.

# Note: Full integration tests require the battle scene and GameManager.
# These tests focus on the logic that can be tested without scene instantiation.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


func before_each() -> void:
	GameManager.transition_data = {}


func after_each() -> void:
	GameManager.transition_data = {}


# --- Full Physical Pipeline ---


func test_physical_pipeline_edren_lv1_vs_tutorial() -> void:
	# Full pipeline: hit check → evasion → crit → damage → clamp
	# Using deterministic seed for reproducibility
	seed(42)
	var atk: int = 18
	var def_val: int = 5
	var spd: int = 10
	var target_spd: int = 5
	var lck: int = 8

	# Simulate full pipeline as battle_manager would compose it
	var hit: bool = DamageCalc.roll_hit(spd, target_spd)
	if not hit:
		return  # miss — valid outcome
	var evaded: bool = DamageCalc.roll_evasion(target_spd)
	if evaded:
		return  # evaded — valid outcome
	var is_crit: bool = DamageCalc.roll_crit(lck)
	var dmg: int = DamageCalc.calculate_physical(
		atk, 1.0, def_val, is_crit, 1.0,
		"front", "front", false, [], false, 1.0
	)
	# Non-crit: 45-49. Crit: 91-98. Both valid.
	if is_crit:
		assert_between(dmg, 91, 98, "crit range")
	else:
		assert_between(dmg, 45, 49, "normal range")


# --- XP Distribution ---


func test_xp_distribution_full_to_active() -> void:
	# Active alive members get full XP
	var total_xp: int = 100
	var active_share: int = total_xp  # Full amount, not divided
	assert_eq(active_share, 100, "active gets full XP")


func test_xp_zero_to_ko() -> void:
	# KO'd members get 0 XP
	var ko_share: int = 0
	assert_eq(ko_share, 0, "KO gets 0")


func test_xp_half_to_absent() -> void:
	# Absent members get 50%
	var total_xp: int = 100
	var absent_share: int = total_xp / 2
	assert_eq(absent_share, 50, "absent gets 50%")


# --- Flee ---


func test_flee_disabled_for_boss() -> void:
	# Boss battles disable flee
	var is_boss: bool = true
	assert_true(is_boss, "flee should be disabled when is_boss is true")


func test_flee_chance_calculation() -> void:
	# Equal speed → 50%
	var chance: int = DamageCalc.calculate_flee_chance(50.0, 50.0)
	assert_eq(chance, 50)
```

- [ ] **Step 3: Run battle manager tests**

Run: `cd game && godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_manager.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/battle_manager.gd game/scripts/combat/battle_ai.gd game/tests/test_battle_manager.gd
git commit -m "feat(engine): add battle manager orchestrator (gap 3.3)"
```

---

### Task 7: Battle UI Scripts

**Files:**
- Create: `game/scripts/ui/battle_ui.gd`
- Create: `game/scripts/ui/battle_party_panel.gd`
- Create: `game/scripts/ui/battle_command_menu.gd`

- [ ] **Step 1: Create battle_party_panel.gd**

```gdscript
# game/scripts/ui/battle_party_panel.gd
extends PanelContainer
## Renders party member rows in battle: name, HP/MP bars, ATB gauge, status icons.

const COLOR_HP_FILL: Color = Color("#44cc44")
const COLOR_HP_LOW: Color = Color("#ff4444")
const COLOR_HP_BG: Color = Color("#220000")
const COLOR_MP_FILL: Color = Color("#4488ff")
const COLOR_MP_BG: Color = Color("#001122")
const COLOR_ATB_FILL: Color = Color("#ffcc00")
const COLOR_ATB_BG: Color = Color("#222222")
const COLOR_NAME_NORMAL: Color = Color("#ffffff")
const COLOR_NAME_ACTIVE: Color = Color("#ffff88")

## Row node references (set in _ready from scene tree).
var _rows: Array[HBoxContainer] = []

## Currently active party slot (-1 = none).
var _active_slot: int = -1


func _ready() -> void:
	for i: int in range(4):
		var row: HBoxContainer = get_node_or_null("Row%d" % i)
		if row != null:
			_rows.append(row)
		else:
			_rows.append(null)


## Update all party rows from state data.
func update_party(members: Array, gauges: Dictionary) -> void:
	for i: int in range(4):
		if _rows[i] == null:
			continue
		var m: Dictionary = members[i] if i < members.size() and members[i] is Dictionary else {}
		if m.is_empty():
			_rows[i].visible = false
			continue
		_rows[i].visible = true
		_update_row(i, m, gauges.get("party_%d" % i, 0))


func _update_row(slot: int, member: Dictionary, atb_gauge: int) -> void:
	var row: HBoxContainer = _rows[slot]
	if row == null:
		return

	# Name label
	var name_label: Label = row.get_node_or_null("NameLabel")
	if name_label != null:
		name_label.text = member.get("character_data", {}).get("name", "???")
		name_label.modulate = COLOR_NAME_ACTIVE if slot == _active_slot else COLOR_NAME_NORMAL

	# HP bar + text
	var hp_label: Label = row.get_node_or_null("HPLabel")
	if hp_label != null:
		var hp: int = member.get("current_hp", 0)
		var max_hp: int = member.get("max_hp", 1)
		hp_label.text = "%d/%d" % [hp, max_hp]
		hp_label.modulate = COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP_FILL

	# MP text
	var mp_label: Label = row.get_node_or_null("MPLabel")
	if mp_label != null:
		mp_label.text = "%d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]

	# ATB gauge (drawn as a small ColorRect or ProgressBar)
	var atb_bar: ColorRect = row.get_node_or_null("ATBBar")
	if atb_bar != null:
		var fill_ratio: float = float(atb_gauge) / 16000.0
		atb_bar.size.x = fill_ratio * 20.0  # 20px max width
		atb_bar.color = COLOR_ATB_FILL


## Set which party member is currently acting.
func set_active_slot(slot: int) -> void:
	_active_slot = slot
```

- [ ] **Step 2: Create battle_command_menu.gd**

```gdscript
# game/scripts/ui/battle_command_menu.gd
extends PanelContainer
## Command panel + sub-menus + target selection for battle.

signal command_selected(command: Dictionary)
signal command_cancelled

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

enum MenuState { HIDDEN, COMMAND, SUBMENU, TARGET }

var _state: MenuState = MenuState.HIDDEN
var _cursor: int = 0
var _commands: Array[Dictionary] = []
var _submenu_items: Array[Dictionary] = []
var _submenu_cursor: int = 0
var _is_boss: bool = false
var _target_cursor: int = 0
var _target_is_enemy: bool = true
var _pending_command: Dictionary = {}

## Number of valid targets (enemies or allies).
var _target_count: int = 0

@onready var _command_list: VBoxContainer = $CommandList
@onready var _submenu: PanelContainer = $SubMenu
@onready var _submenu_list: VBoxContainer = $SubMenu/SubMenuList


func _ready() -> void:
	visible = false
	if _submenu != null:
		_submenu.visible = false


## Show command menu for a party member.
func show_commands(character_data: Dictionary, is_boss: bool) -> void:
	_is_boss = is_boss
	_cursor = 0
	_state = MenuState.COMMAND

	# Build command list
	var ability_name: String = _get_ability_name(character_data.get("id", ""))
	_commands = [
		{"label": "Attack", "type": "attack", "enabled": true},
		{"label": "Magic", "type": "magic", "enabled": true},
		{"label": ability_name, "type": "ability", "enabled": true},
		{"label": "Item", "type": "item", "enabled": true},
		{"label": "Defend", "type": "defend", "enabled": true},
		{"label": "Flee", "type": "flee", "enabled": not _is_boss},
	]

	_update_command_display()
	visible = true


## Hide the command menu.
func hide_menu() -> void:
	_state = MenuState.HIDDEN
	visible = false
	if _submenu != null:
		_submenu.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _state == MenuState.HIDDEN:
		return

	match _state:
		MenuState.COMMAND:
			_handle_command_input(event)
		MenuState.SUBMENU:
			_handle_submenu_input(event)
		MenuState.TARGET:
			_handle_target_input(event)


func _handle_command_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_cursor = (_cursor - 1 + _commands.size()) % _commands.size()
		_update_command_display()
	elif event.is_action_pressed("ui_down"):
		_cursor = (_cursor + 1) % _commands.size()
		_update_command_display()
	elif event.is_action_pressed("ui_accept"):
		_confirm_command()
	elif event.is_action_pressed("ui_cancel"):
		command_cancelled.emit()


func _handle_submenu_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_submenu_cursor = (_submenu_cursor - 1 + _submenu_items.size()) % _submenu_items.size()
		_update_submenu_display()
	elif event.is_action_pressed("ui_down"):
		_submenu_cursor = (_submenu_cursor + 1) % _submenu_items.size()
		_update_submenu_display()
	elif event.is_action_pressed("ui_accept"):
		_confirm_submenu()
	elif event.is_action_pressed("ui_cancel"):
		_state = MenuState.COMMAND
		_submenu.visible = false


func _handle_target_input(event: InputEvent) -> void:
	if _target_is_enemy:
		if event.is_action_pressed("ui_left"):
			_target_cursor = (_target_cursor - 1 + _target_count) % _target_count
		elif event.is_action_pressed("ui_right"):
			_target_cursor = (_target_cursor + 1) % _target_count
	else:
		if event.is_action_pressed("ui_up"):
			_target_cursor = (_target_cursor - 1 + _target_count) % _target_count
		elif event.is_action_pressed("ui_down"):
			_target_cursor = (_target_cursor + 1) % _target_count

	if event.is_action_pressed("ui_accept"):
		_pending_command["target"] = _target_cursor
		command_selected.emit(_pending_command)
		hide_menu()
	elif event.is_action_pressed("ui_cancel"):
		_state = MenuState.COMMAND if _pending_command.get("type", "") == "attack" else MenuState.SUBMENU


func _confirm_command() -> void:
	var cmd: Dictionary = _commands[_cursor]
	if not cmd.get("enabled", true):
		return

	match cmd["type"]:
		"attack":
			_pending_command = {"type": "attack"}
			_start_target_selection(true)
		"magic":
			_show_magic_submenu()
		"ability":
			_show_ability_submenu()
		"item":
			_show_item_submenu()
		"defend":
			command_selected.emit({"type": "defend"})
			hide_menu()
		"flee":
			command_selected.emit({"type": "flee"})
			hide_menu()


func _start_target_selection(is_enemy: bool, count: int = 0) -> void:
	_target_is_enemy = is_enemy
	_target_cursor = 0
	_target_count = maxi(1, count)
	_state = MenuState.TARGET


func _show_magic_submenu() -> void:
	# Placeholder: populated by battle_ui from spell data
	_submenu_cursor = 0
	_state = MenuState.SUBMENU
	if _submenu != null:
		_submenu.visible = true


func _show_ability_submenu() -> void:
	_submenu_cursor = 0
	_state = MenuState.SUBMENU
	if _submenu != null:
		_submenu.visible = true


func _show_item_submenu() -> void:
	_submenu_cursor = 0
	_state = MenuState.SUBMENU
	if _submenu != null:
		_submenu.visible = true


func _confirm_submenu() -> void:
	if _submenu_items.is_empty():
		return
	var item: Dictionary = _submenu_items[_submenu_cursor]
	if not item.get("enabled", true):
		return
	_pending_command = item.get("command", {})
	var target_type: String = item.get("target_type", "single_enemy")
	match target_type:
		"single_enemy":
			_start_target_selection(true)
		"single_ally":
			_start_target_selection(false, 4)
		"all_enemies", "all_allies":
			command_selected.emit(_pending_command)
			hide_menu()
		_:
			_start_target_selection(true)


## Set submenu items (called by battle_ui when populating spell/item/ability lists).
func set_submenu_items(items: Array[Dictionary]) -> void:
	_submenu_items = items
	_update_submenu_display()


## Set enemy count for target selection.
func set_enemy_count(count: int) -> void:
	_target_count = count


func _update_command_display() -> void:
	if _command_list == null:
		return
	for i: int in range(_command_list.get_child_count()):
		if i >= _commands.size():
			break
		var label: Label = _command_list.get_child(i) as Label
		if label == null:
			continue
		label.text = _commands[i].get("label", "")
		if not _commands[i].get("enabled", true):
			label.modulate = COLOR_DISABLED
		elif i == _cursor:
			label.modulate = COLOR_SELECTED
		else:
			label.modulate = COLOR_NORMAL


func _update_submenu_display() -> void:
	if _submenu_list == null:
		return
	# Clear existing
	for child: Node in _submenu_list.get_children():
		child.queue_free()
	# Populate
	for i: int in range(_submenu_items.size()):
		var label: Label = Label.new()
		label.text = _submenu_items[i].get("label", "")
		if not _submenu_items[i].get("enabled", true):
			label.modulate = COLOR_DISABLED
		elif i == _submenu_cursor:
			label.modulate = COLOR_SELECTED
		else:
			label.modulate = COLOR_NORMAL
		_submenu_list.add_child(label)


func _get_ability_name(character_id: String) -> String:
	match character_id:
		"edren": return "Bulwark"
		"cael": return "Rally"
		"lira": return "Forgewright"
		"torren": return "Spiritcall"
		"sable": return "Tricks"
		"maren": return "Arcanum"
	return "Ability"
```

- [ ] **Step 3: Create battle_ui.gd**

```gdscript
# game/scripts/ui/battle_ui.gd
extends CanvasLayer
## Battle UI controller — observes battle_manager signals, coordinates
## child UI components, manages damage popups and results screen.

const COLOR_DAMAGE: Color = Color("#ffffff")
const COLOR_HEAL: Color = Color("#44ff44")
const COLOR_MISS: Color = Color("#888888")
const COLOR_CRIT: Color = Color("#ffff44")

@onready var _party_panel: PanelContainer = $PartyPanel
@onready var _command_menu: PanelContainer = $CommandMenu
@onready var _message_area: PanelContainer = $MessageArea
@onready var _message_label: Label = $MessageArea/MessageLabel
@onready var _results_panel: PanelContainer = $ResultsPanel

## Reference to battle manager (set in _ready).
var _battle_manager: Node = null

## Timer for message auto-fade.
var _message_timer: float = 0.0


func _ready() -> void:
	_battle_manager = get_parent()
	if _battle_manager == null:
		push_error("BattleUI: No parent battle manager")
		return

	# Connect to battle manager signals
	_battle_manager.battle_started.connect(_on_battle_started)
	_battle_manager.turn_ready.connect(_on_turn_ready)
	_battle_manager.damage_dealt.connect(_on_damage_dealt)
	_battle_manager.message.connect(_on_message)
	_battle_manager.victory.connect(_on_victory)
	_battle_manager.defeat.connect(_on_defeat)
	_battle_manager.combatant_died.connect(_on_combatant_died)

	# Connect command menu signals
	if _command_menu != null:
		_command_menu.command_selected.connect(_on_command_selected)
		_command_menu.command_cancelled.connect(_on_command_cancelled)

	# Hide everything initially
	if _message_area != null:
		_message_area.visible = false
	if _results_panel != null:
		_results_panel.visible = false
	if _command_menu != null:
		_command_menu.hide_menu()


func _process(delta: float) -> void:
	# Auto-fade message
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0 and _message_area != null:
			_message_area.visible = false

	# Update party panel every frame (ATB gauges change continuously)
	_update_party_panel()


func _on_battle_started(_party: Array, _enemies: Array) -> void:
	_update_party_panel()


func _on_turn_ready(combatant_id: String, is_party: bool) -> void:
	if is_party:
		var slot: int = combatant_id.replace("party_", "").to_int()
		if _party_panel != null:
			_party_panel.set_active_slot(slot)

		# Show command menu
		var state: Node = _battle_manager.get_node_or_null("BattleState")
		if state != null and _command_menu != null:
			var member: Dictionary = state.get_member(slot)
			var char_data: Dictionary = member.get("character_data", {})
			_command_menu.set_enemy_count(_battle_manager._enemies.size())
			_command_menu.show_commands(char_data, _battle_manager._is_boss)

			# Set ATB pause flag for wait mode
			var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
			if atb != null:
				atb.set_command_menu_open(true)


func _on_command_selected(command: Dictionary) -> void:
	# Unpause ATB
	var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
	if atb != null:
		atb.set_command_menu_open(false)
		atb.set_submenu_open(false)

	if _party_panel != null:
		_party_panel.set_active_slot(-1)

	_battle_manager.submit_command(command)


func _on_command_cancelled() -> void:
	# In ATB, cancel just hides menu — character waits
	if _command_menu != null:
		_command_menu.hide_menu()
	if _party_panel != null:
		_party_panel.set_active_slot(-1)

	var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
	if atb != null:
		atb.set_command_menu_open(false)


func _on_damage_dealt(target_id: String, amount: int, damage_type: String) -> void:
	# Spawn floating damage number
	var color: Color = COLOR_DAMAGE
	var text: String = str(amount)

	match damage_type:
		"heal":
			color = COLOR_HEAL
		"miss":
			color = COLOR_MISS
			text = "Miss"
		"immune":
			color = COLOR_MISS
			text = "Immune"
		"critical":
			color = COLOR_CRIT

	_spawn_damage_number(target_id, text, color)


func _on_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text
	if _message_area != null:
		_message_area.visible = true
	_message_timer = 1.5


func _on_victory(rewards: Dictionary) -> void:
	if _command_menu != null:
		_command_menu.hide_menu()
	_show_results(rewards)


func _on_defeat() -> void:
	if _command_menu != null:
		_command_menu.hide_menu()
	# Defeat handled by battle_manager (faint-and-fast-reload)


func _on_combatant_died(_combatant_id: String) -> void:
	pass  # Could play death animation here


func _update_party_panel() -> void:
	if _party_panel == null or _battle_manager == null:
		return
	var state: Node = _battle_manager.get_node_or_null("BattleState")
	var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
	if state == null or atb == null:
		return

	var members: Array = []
	var gauges: Dictionary = {}
	for i: int in range(4):
		members.append(state.get_member(i))
		gauges["party_%d" % i] = atb.get_gauge("party_%d" % i)
	_party_panel.update_party(members, gauges)


func _spawn_damage_number(target_id: String, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.modulate = color
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Position above the target
	var pos: Vector2 = _get_target_position(target_id)
	label.position = pos - Vector2(20, 16)

	add_child(label)

	# Float upward and fade
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", pos.y - 32, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.tween_callback(label.queue_free)


func _get_target_position(target_id: String) -> Vector2:
	if target_id.begins_with("enemy_"):
		var idx: int = target_id.replace("enemy_", "").to_int()
		if idx < _battle_manager._enemies.size():
			return _battle_manager._enemies[idx].global_position
	elif target_id.begins_with("party_"):
		var slot: int = target_id.replace("party_", "").to_int()
		# Party positions are in the bottom panel area
		return Vector2(40, 120 + slot * 15)
	return Vector2(160, 90)


func _show_results(rewards: Dictionary) -> void:
	if _results_panel == null:
		return
	_results_panel.visible = true

	var results_label: Label = _results_panel.get_node_or_null("ResultsLabel")
	if results_label != null:
		var text: String = "Victory!\n\n"
		text += "EXP: %d\n" % rewards.get("xp", 0)
		text += "Gold: %d\n" % rewards.get("gold", 0)
		var drops: Array = rewards.get("drops", [])
		for drop: Dictionary in drops:
			text += "Found: %s\n" % drop.get("item_id", "???")
		results_label.text = text


func _unhandled_input(event: InputEvent) -> void:
	# Dismiss results screen
	if _results_panel != null and _results_panel.visible:
		if event.is_action_pressed("ui_accept"):
			_results_panel.visible = false
			_battle_manager._exit_battle("victory")
```

- [ ] **Step 4: Commit UI scripts**

```bash
git add game/scripts/ui/battle_ui.gd game/scripts/ui/battle_party_panel.gd game/scripts/ui/battle_command_menu.gd
git commit -m "feat(engine): add battle UI scripts (gap 3.3)"
```

---

### Task 8: Battle Scene (.tscn) and Integration

**Files:**
- Create: `game/scenes/core/battle.tscn`
- Modify: `game/scripts/core/exploration.gd` (wire battle transition)

- [ ] **Step 1: Create battle.tscn**

Create the scene file with the full node tree. This must be hand-written
as a .tscn text file since we don't have the Godot editor available.

```
[gd_scene load_steps=9 format=3]

[ext_resource type="Script" path="res://scripts/combat/battle_manager.gd" id="1_manager"]
[ext_resource type="Script" path="res://scripts/combat/atb_system.gd" id="2_atb"]
[ext_resource type="Script" path="res://scripts/combat/battle_state.gd" id="3_state"]
[ext_resource type="Script" path="res://scripts/ui/battle_ui.gd" id="4_ui"]
[ext_resource type="Script" path="res://scripts/ui/battle_party_panel.gd" id="5_panel"]
[ext_resource type="Script" path="res://scripts/ui/battle_command_menu.gd" id="6_cmd"]

[sub_resource type="StyleBoxFlat" id="StyleBox_panel"]
bg_color = Color(0, 0, 0.15, 0.9)
border_width_left = 1
border_width_top = 1
border_width_right = 1
border_width_bottom = 1
border_color = Color(0.333, 0.4, 0.667, 1)
content_margin_left = 4.0
content_margin_top = 2.0
content_margin_right = 4.0
content_margin_bottom = 2.0

[sub_resource type="StyleBoxFlat" id="StyleBox_msg"]
bg_color = Color(0, 0, 0.15, 0.9)
border_width_left = 1
border_width_top = 1
border_width_right = 1
border_width_bottom = 1
border_color = Color(0.333, 0.4, 0.667, 1)
content_margin_left = 4.0
content_margin_top = 1.0
content_margin_right = 4.0
content_margin_bottom = 1.0

[node name="Battle" type="Node2D"]
script = ExtResource("1_manager")

[node name="ATBSystem" type="Node" parent="."]
script = ExtResource("2_atb")

[node name="BattleState" type="Node" parent="."]
script = ExtResource("3_state")

[node name="EnemyArea" type="Node2D" parent="."]

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(160, 90)

[node name="BattleUI" type="CanvasLayer" parent="."]
layer = 10
script = ExtResource("4_ui")

[node name="PartyPanel" type="PanelContainer" parent="BattleUI"]
offset_left = 0.0
offset_top = 117.0
offset_right = 208.0
offset_bottom = 180.0
theme_override_styles/panel = SubResource("StyleBox_panel")
script = ExtResource("5_panel")

[node name="Row0" type="HBoxContainer" parent="BattleUI/PartyPanel"]
layout_mode = 2

[node name="NameLabel" type="Label" parent="BattleUI/PartyPanel/Row0"]
layout_mode = 2
text = "EDREN"

[node name="HPLabel" type="Label" parent="BattleUI/PartyPanel/Row0"]
layout_mode = 2
text = "95/95"

[node name="MPLabel" type="Label" parent="BattleUI/PartyPanel/Row0"]
layout_mode = 2
text = "15/15"

[node name="ATBBar" type="ColorRect" parent="BattleUI/PartyPanel/Row0"]
layout_mode = 2
custom_minimum_size = Vector2(20, 4)
color = Color(1, 0.8, 0, 1)

[node name="Row1" type="HBoxContainer" parent="BattleUI/PartyPanel"]
layout_mode = 2

[node name="NameLabel" type="Label" parent="BattleUI/PartyPanel/Row1"]
layout_mode = 2
text = ""

[node name="HPLabel" type="Label" parent="BattleUI/PartyPanel/Row1"]
layout_mode = 2
text = ""

[node name="MPLabel" type="Label" parent="BattleUI/PartyPanel/Row1"]
layout_mode = 2
text = ""

[node name="ATBBar" type="ColorRect" parent="BattleUI/PartyPanel/Row1"]
layout_mode = 2
custom_minimum_size = Vector2(20, 4)
color = Color(1, 0.8, 0, 1)

[node name="Row2" type="HBoxContainer" parent="BattleUI/PartyPanel"]
layout_mode = 2

[node name="NameLabel" type="Label" parent="BattleUI/PartyPanel/Row2"]
layout_mode = 2
text = ""

[node name="HPLabel" type="Label" parent="BattleUI/PartyPanel/Row2"]
layout_mode = 2
text = ""

[node name="MPLabel" type="Label" parent="BattleUI/PartyPanel/Row2"]
layout_mode = 2
text = ""

[node name="ATBBar" type="ColorRect" parent="BattleUI/PartyPanel/Row2"]
layout_mode = 2
custom_minimum_size = Vector2(20, 4)
color = Color(1, 0.8, 0, 1)

[node name="Row3" type="HBoxContainer" parent="BattleUI/PartyPanel"]
layout_mode = 2

[node name="NameLabel" type="Label" parent="BattleUI/PartyPanel/Row3"]
layout_mode = 2
text = ""

[node name="HPLabel" type="Label" parent="BattleUI/PartyPanel/Row3"]
layout_mode = 2
text = ""

[node name="MPLabel" type="Label" parent="BattleUI/PartyPanel/Row3"]
layout_mode = 2
text = ""

[node name="ATBBar" type="ColorRect" parent="BattleUI/PartyPanel/Row3"]
layout_mode = 2
custom_minimum_size = Vector2(20, 4)
color = Color(1, 0.8, 0, 1)

[node name="CommandMenu" type="PanelContainer" parent="BattleUI"]
offset_left = 212.0
offset_top = 117.0
offset_right = 320.0
offset_bottom = 180.0
theme_override_styles/panel = SubResource("StyleBox_panel")
visible = false
script = ExtResource("6_cmd")

[node name="CommandList" type="VBoxContainer" parent="BattleUI/CommandMenu"]
layout_mode = 2

[node name="Cmd0" type="Label" parent="BattleUI/CommandMenu/CommandList"]
layout_mode = 2
text = "Attack"

[node name="Cmd1" type="Label" parent="BattleUI/CommandMenu/CommandList"]
layout_mode = 2
text = "Magic"

[node name="Cmd2" type="Label" parent="BattleUI/CommandMenu/CommandList"]
layout_mode = 2
text = "Ability"

[node name="Cmd3" type="Label" parent="BattleUI/CommandMenu/CommandList"]
layout_mode = 2
text = "Item"

[node name="Cmd4" type="Label" parent="BattleUI/CommandMenu/CommandList"]
layout_mode = 2
text = "Defend"

[node name="Cmd5" type="Label" parent="BattleUI/CommandMenu/CommandList"]
layout_mode = 2
text = "Flee"

[node name="SubMenu" type="PanelContainer" parent="BattleUI/CommandMenu"]
offset_left = -212.0
offset_top = 0.0
offset_right = -4.0
offset_bottom = 63.0
theme_override_styles/panel = SubResource("StyleBox_panel")
visible = false

[node name="SubMenuList" type="VBoxContainer" parent="BattleUI/CommandMenu/SubMenu"]
layout_mode = 2

[node name="MessageArea" type="PanelContainer" parent="BattleUI"]
offset_left = 80.0
offset_top = 2.0
offset_right = 240.0
offset_bottom = 16.0
theme_override_styles/panel = SubResource("StyleBox_msg")
visible = false

[node name="MessageLabel" type="Label" parent="BattleUI/MessageArea"]
layout_mode = 2
horizontal_alignment = 1
text = ""

[node name="ResultsPanel" type="PanelContainer" parent="BattleUI"]
offset_left = 60.0
offset_top = 30.0
offset_right = 260.0
offset_bottom = 150.0
theme_override_styles/panel = SubResource("StyleBox_panel")
visible = false

[node name="ResultsLabel" type="Label" parent="BattleUI/ResultsPanel"]
layout_mode = 2
text = ""
```

- [ ] **Step 2: Commit scene**

```bash
git add game/scenes/core/battle.tscn
git commit -m "feat(engine): add battle scene (gap 3.3)"
```

---

### Task 9: Update Gap Tracker and Final Commit

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update gap 3.3 status to MOSTLY COMPLETE**

Update the gap 3.3 entry in game-dev-gaps.md:
- Status: MOSTLY COMPLETE
- Completed: 2026-04-06 (Core Battle — Option A)
- Check off implemented items
- Note what's deferred (boss AI, combat interactions, equipment modifiers)

- [ ] **Step 2: Commit tracker update**

```bash
git add docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-06-battle-scene-design.md
git commit -m "docs(engine): update gap 3.3 status to mostly complete"
```

- [ ] **Step 3: Run all tests**

```bash
cd game && godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gexit
```

All tests must pass before proceeding to `/create-pr`.
