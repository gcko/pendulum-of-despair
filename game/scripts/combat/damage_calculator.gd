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
	atk: int,
	ability_mult: float,
	target_def: int,
	is_crit: bool,
	interaction_mult: float,
	attacker_row: String,
	defender_row: String,
	weapon_bypasses_row: bool,
	reduction_sources: Array,
	is_elemental: bool,
	element_mod: float,
	attacker_id: String = ""
) -> int:
	# Step 3-4: Base damage with floor
	var raw: float = maxf(1.0, (atk * atk * ability_mult) / 6.0 - target_def)

	# Step 5: Critical hit
	if is_crit:
		raw *= 2.0

	# Step 6: Combat interaction modifiers
	raw *= interaction_mult

	# Cael's Pallor Shimmer: +10% physical damage (permanent, hidden)
	if attacker_id == "cael":
		raw *= 1.1

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


## Calculate magic damage per combat-formulas.md § Magic Damage Resolution.
## Caller must perform hit/evasion checks BEFORE calling this.
##
## [param buff_mults] — array of multiplicative buffs (e.g., [1.3] for Resonance).
## Returns: positive int for damage, 0 for immunity.
## For absorb: returns positive int (healing amount for target).
static func calculate_magic(
	mag: int,
	spell_power: int,
	target_mdef: int,
	element_mod: float,
	interaction_mult: float,
	buff_mults: Array,
	reduction_sources: Array
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
	var raw: float = maxi(0, mag) * maxi(0, spell_power) * 0.8
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
static func roll_status(base_rate: int, caster_mag: int, target_mdef: int, target_spd: int) -> bool:
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
