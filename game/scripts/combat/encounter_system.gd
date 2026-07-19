extends RefCounted
## Static helpers for random encounter logic.
## Danger counter, encounter checks, group selection, formation rolls.
## Source: combat-formulas.md § Danger Counter, § Battle Formations.

## Item IDs that reduce encounter rate (x0.5 each, don't stack with each other).
const REDUCE_ITEMS: Array[String] = ["ward_talisman", "infiltrators_cloak"]
## Item ID that increases encounter rate (x2.0).
const LURE_ITEM: String = "lure_talisman"
## Accessory granting +25pp preemptive odds (non-stacking).
const PREEMPTIVE_CHARM: String = "preemptive_charm"
## Percentage points the Preemptive Charm adds (combat-formulas.md
## § Preemptive Charm interaction).
const PREEMPTIVE_CHARM_BONUS: float = 25.0


## Check if an encounter triggers this step.
## Returns true if random roll < floor(danger_counter / 256).
static func check_encounter(danger_counter: int) -> bool:
	if danger_counter <= 0:
		return false
	var threshold: int = danger_counter / 256
	return randi_range(0, 255) < threshold


## Calculate danger increment for one step.
## final = floor(base_increment * act_scale * accessory_mod * location_mod)
## per combat-formulas.md § Final increment formula. int() truncation
## equals floor for the non-negative operands used here.
static func roll_increment(
	base_increment: int, act_scale: float, accessory_mod: float, location_mod: float = 1.0
) -> int:
	return int(float(base_increment) * act_scale * accessory_mod * location_mod)


## Aggregate flag-gated location modifiers from a zone/floor config.
## Each config.location_mods entry {"flag": ..., "modifier": ...} applies
## while its EventFlags flag is satisfied; entries stack multiplicatively
## (combat-formulas.md § Encounter rate modifiers: Tunnel Map, Kole's
## patrol, Veilstep all land here as data).
static func get_location_modifier(config: Dictionary) -> float:
	var mod: float = 1.0
	for entry: Variant in config.get("location_mods", []):
		if entry is Dictionary:
			var flag: String = (entry as Dictionary).get("flag", "")
			if not flag.is_empty() and EventFlags.check_required_flags(flag):
				mod *= float((entry as Dictionary).get("modifier", 1.0))
	return mod


## Select an encounter group via weighted random from groups array.
## Each group dict has a "weight" field. Returns selected group or {}.
static func select_encounter_group(groups: Array) -> Dictionary:
	if groups.is_empty():
		return {}
	var total_weight: float = 0.0
	for g: Variant in groups:
		if g is Dictionary:
			total_weight += float((g as Dictionary).get("weight", 0.0))
	if total_weight <= 0.0:
		return groups[0] if groups[0] is Dictionary else {}
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for g: Variant in groups:
		if g is Dictionary:
			cumulative += float((g as Dictionary).get("weight", 0.0))
			if roll < cumulative:  # Strict < avoids bias at weight boundaries
				return g as Dictionary
	# Fallback (float rounding)
	return groups[groups.size() - 1] if groups[groups.size() - 1] is Dictionary else {}


## Roll formation type from rates dict.
## Returns "normal", "back_attack", or "preemptive".
static func roll_formation(formation_rates: Dictionary) -> String:
	var preemptive: float = float(formation_rates.get("preemptive", 0.0))
	var back_attack: float = float(formation_rates.get("back_attack", 0.0))
	var roll: float = randf() * 100.0
	if roll < preemptive:
		return "preemptive"
	if roll < preemptive + back_attack:
		return "back_attack"
	return "normal"


## Shift formation rates by [param bonus_pp] percentage points toward
## preemptive, deducting from back_attack first then normal, never below
## zero. Canon: combat-formulas.md § Preemptive Charm interaction
## ("normalizes all terrains to 62.5/0/37.5").
static func apply_preemptive_bonus(rates: Dictionary, bonus_pp: float) -> Dictionary:
	if bonus_pp <= 0.0:
		return rates
	var preemptive: float = float(rates.get("preemptive", 0.0))
	var back_attack: float = float(rates.get("back_attack", 0.0))
	var normal: float = float(rates.get("normal", 0.0))
	var from_back: float = minf(back_attack, bonus_pp)
	var from_normal: float = minf(normal, bonus_pp - from_back)
	return {
		"preemptive": preemptive + from_back + from_normal,
		"back_attack": back_attack - from_back,
		"normal": normal - from_normal,
	}


## Preemptive bonus (pp) from the party's equipped Preemptive Charms.
## Non-stacking: one fixed +25pp regardless of charm count, mirroring the
## Ward Talisman / Infiltrator's Cloak non-stack precedent.
static func get_preemptive_bonus(party: Array[Dictionary]) -> float:
	for member: Dictionary in party:
		var equip: Dictionary = member.get("equipment", {})
		for slot: String in ["accessory", "crystal"]:
			if equip.get(slot, "") == PREEMPTIVE_CHARM:
				return PREEMPTIVE_CHARM_BONUS
	return 0.0


## Calculate encounter rate modifier from active party equipment.
## Ward Talisman/Infiltrator's Cloak: x0.5 (don't stack with each other).
## Lure Talisman: x2.0. All stack multiplicatively.
static func get_accessory_modifier(party: Array[Dictionary]) -> float:
	var has_reduce: bool = false
	var has_lure: bool = false
	for member: Dictionary in party:
		var equip: Dictionary = member.get("equipment", {})
		for slot: String in ["accessory", "crystal"]:
			var item_id: String = equip.get(slot, "")
			if item_id in REDUCE_ITEMS:
				has_reduce = true
			if item_id == LURE_ITEM:
				has_lure = true
	var mod: float = 1.0
	if has_reduce:
		mod *= 0.5
	if has_lure:
		mod *= 2.0
	return mod
