extends RefCounted
## Pure lookups over an enemy's data record: its mixed-format element lists
## and its steal and drop rolls. Static and stateless; Enemy forwards here
## (split out of enemy.gd under the script size budget,
## technical-architecture.md § 1.2a).


## Check if an element appears in an array that may contain plain strings
## or objects with {"element": "...", "multiplier": ...}.
static func element_in_list(element: String, list: Array) -> bool:
	for entry: Variant in list:
		if entry is String and entry == element:
			return true
		if entry is Dictionary and (entry as Dictionary).get("element", "") == element:
			return true
	return false


## Get the custom multiplier for an element from a mixed-format array.
## Returns the object multiplier if found, otherwise -1.0 (not in list).
## Uses -1.0 as sentinel because legitimate multipliers are >= 0.0.
static func list_multiplier(element: String, list: Array, default_mult: float) -> float:
	for entry: Variant in list:
		if entry is String and entry == element:
			return default_mult
		if entry is Dictionary:
			var d: Dictionary = entry as Dictionary
			if d.get("element", "") == element:
				return d.get("multiplier", default_mult)
	return -1.0  # not in list


## Roll for a steal attempt. Returns {item_id: String, success: bool}.
##
## Three steal shapes are canon (2026-04-02-enemy-data-json-design.md
## § Steal Mapping Rules): the two-tier object, a whole-record `null` (Rule 3),
## and a `null` tier (Rule 4). Dictionary.get() returns the STORED value when
## the key exists, so a JSON null arrives as Nil rather than the default and
## reading it into a typed Dictionary local aborts the function. Widen through
## Variant; every non-dictionary means "carries nothing here".
static func roll_steal(enemy_data: Dictionary, tier: String) -> Dictionary:
	var raw_steal: Variant = enemy_data.get("steal")
	if not raw_steal is Dictionary:
		return {"item_id": "", "success": false}
	var steal_data: Dictionary = raw_steal
	var raw_tier: Variant = steal_data.get(tier)
	if not raw_tier is Dictionary:
		return {"item_id": "", "success": false}
	var tier_data: Dictionary = raw_tier
	if tier_data.is_empty():
		return {"item_id": "", "success": false}
	var rate: int = tier_data.get("rate", 0)
	var raw_id: Variant = tier_data.get("item_id", "")
	var item_id: String = raw_id as String if raw_id is String else ""
	var success: bool = randi() % 100 < rate and not item_id.is_empty()
	return {
		"item_id": item_id if success else "",
		"success": success,
	}


## Roll for a drop on death. Returns {item_id: String, success: bool}.
## `"drop": null` is canon for the 6 enemies that leave nothing behind — same
## Nil-through-get() trap as roll_steal() above.
static func roll_drop(enemy_data: Dictionary) -> Dictionary:
	var raw_drop: Variant = enemy_data.get("drop")
	if not raw_drop is Dictionary:
		return {"item_id": "", "success": false}
	var drop_data: Dictionary = raw_drop
	if drop_data.is_empty():
		return {"item_id": "", "success": false}
	var rate: int = drop_data.get("rate", 0)
	var success: bool = randi() % 100 < rate
	return {
		"item_id": drop_data.get("item_id", "") if success else "",
		"success": success,
	}
