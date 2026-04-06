extends RefCounted
## Static helpers for random encounter logic.
## Danger counter, encounter checks, group selection, formation rolls.
## Source: combat-formulas.md § Danger Counter, § Battle Formations.

## Item IDs that reduce encounter rate (x0.5 each, don't stack with each other).
const REDUCE_ITEMS: Array[String] = ["ward_talisman", "infiltrators_cloak"]
## Item ID that increases encounter rate (x2.0).
const LURE_ITEM: String = "lure_talisman"


## Check if an encounter triggers this step.
## Returns true if random roll < floor(danger_counter / 256).
static func check_encounter(danger_counter: int) -> bool:
	if danger_counter <= 0:
		return false
	var threshold: int = danger_counter / 256
	return randi_range(0, 255) < threshold


## Calculate danger increment for one step.
## final = floor(base_increment * act_scale * accessory_mod).
static func roll_increment(base_increment: int, act_scale: float, accessory_mod: float) -> int:
	return int(float(base_increment) * act_scale * accessory_mod)


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
