extends RefCounted
## Static helpers for resolving known spells and field-cast effects.

const TRADITIONS: Array[String] = ["ley_line", "forgewright", "spirit", "streetwise", "void"]
## Only healing for now. Buff/utility field-cast deferred until effect application exists.
const FIELD_CATEGORIES: Array[String] = ["healing"]


## Get all spells a character knows at their current level. A spell taught by
## a story event (a cross-training scene) is known once that event's flag is
## set, as a story-gated ability is (ability_helpers.gd); see knows_spell.
static func get_known_spells(character_id: String, level: int) -> Array:
	var result: Array = []
	for tradition: String in TRADITIONS:
		var spells: Array = DataManager.load_spells(tradition)
		for spell: Variant in spells:
			if not spell is Dictionary:
				continue
			var s: Dictionary = spell as Dictionary
			if knows_spell(s, character_id, level):
				result.append(s)
	result.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return _sort_by_tier_then_cost(a, b, character_id)
	)
	return result


## Whether [param character_id] at [param level] has learned [param spell]
## through their learned_by entry. Each gate the entry names must be met: an
## event by its story flag, a level by level, and an entry naming both
## ("Lv 32, after Act III spirit communion") needs both.
static func knows_spell(spell: Dictionary, character_id: String, level: int) -> bool:
	var entry: Dictionary = _learner_entry(spell, character_id)
	if not (entry.has("event") or entry.has("level")):
		return false
	if entry.has("event") and not EventFlags.get_flag(String(entry["event"])):
		return false
	if entry.has("level") and int(entry["level"]) > level:
		return false
	return true


## The MP [param character_id] pays to cast [param spell]: its base mp_cost,
## or for a cross-trained learner that cost times their entry's mp_penalty,
## rounded up (magic.md § Derived Rules, "Cross-training is per-learner").
## Everything that shows, checks or spends MP reads this, so the cost on the
## menu is the cost that is charged.
static func get_mp_cost(spell: Dictionary, character_id: String) -> int:
	var raw: Variant = spell.get("mp_cost", 0)
	var base: int = int(raw) if raw != null else 0
	var entry: Dictionary = _learner_entry(spell, character_id)
	if not entry.get("cross_trained", false):
		return base
	var raw_penalty: Variant = entry.get("mp_penalty", 1.0)
	var penalty: float = float(raw_penalty) if raw_penalty != null else 1.0
	return ceili(base * penalty)


## Whether a spell can be cast from the field menu.
static func can_field_cast(spell: Dictionary) -> bool:
	return spell.get("category", "") in FIELD_CATEGORIES


## Calculate field-cast healing. Deterministic (no variance) for field UX. Capped at 14999.
## Returns 0 if spell has no power or power is null.
static func get_field_heal_amount(caster_mag: int, spell: Dictionary) -> int:
	var power_raw: Variant = spell.get("power", 0)
	var power: int = power_raw as int if power_raw is int else 0
	if power <= 0:
		return 0
	return mini(14999, int(caster_mag * power * 0.8))


## [param character_id]'s learned_by entry on [param spell], or {} when they
## do not learn it.
static func _learner_entry(spell: Dictionary, character_id: String) -> Dictionary:
	for entry: Variant in spell.get("learned_by", []):
		if entry is Dictionary and (entry as Dictionary).get("character", "") == character_id:
			return entry
	return {}


static func _sort_by_tier_then_cost(a: Dictionary, b: Dictionary, character_id: String) -> bool:
	var ta: int = a.get("tier", 0)
	var tb: int = b.get("tier", 0)
	if ta != tb:
		return ta < tb
	return get_mp_cost(a, character_id) < get_mp_cost(b, character_id)
