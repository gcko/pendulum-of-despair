extends RefCounted
## Static helpers for resolving known spells and field-cast effects.

const TRADITIONS: Array[String] = ["ley_line", "forgewright", "spirit", "streetwise", "void"]
const FIELD_CATEGORIES: Array[String] = ["healing", "buff", "utility"]


## Get all spells a character knows at their current level.
static func get_known_spells(character_id: String, level: int) -> Array:
	var result: Array = []
	for tradition: String in TRADITIONS:
		var spells: Array = DataManager.load_spells(tradition)
		for spell: Variant in spells:
			if not spell is Dictionary:
				continue
			var s: Dictionary = spell as Dictionary
			for entry: Variant in s.get("learned_by", []):
				if not entry is Dictionary:
					continue
				var e: Dictionary = entry as Dictionary
				if e.get("character", "") == character_id and e.get("level", 999) <= level:
					result.append(s)
					break
	result.sort_custom(_sort_by_tier_then_cost)
	return result


## Whether a spell can be cast from the field menu.
static func can_field_cast(spell: Dictionary) -> bool:
	return spell.get("category", "") in FIELD_CATEGORIES


## Calculate field-cast healing amount.
static func get_field_heal_amount(caster_mag: int, spell: Dictionary) -> int:
	var power: int = spell.get("power", 0)
	if power <= 0:
		return 0
	return int(caster_mag * power * 0.8)


static func _sort_by_tier_then_cost(a: Dictionary, b: Dictionary) -> bool:
	var ta: int = a.get("tier", 0)
	var tb: int = b.get("tier", 0)
	if ta != tb:
		return ta < tb
	return a.get("mp_cost", 0) < b.get("mp_cost", 0)
