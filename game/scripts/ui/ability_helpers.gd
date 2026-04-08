extends RefCounted
## Static helpers for resolving known abilities and formatting costs.

const RESOURCE_LABELS: Dictionary = {
	"bulwark": "AP 0/10",
	"rally": "MP",
	"forgewright": "AC 12/12",
	"spiritcall": "MP",
	"tricks": "MP",
	"arcanum": "WG 0/100",
}


static func get_known_abilities(character_id: String, level: int) -> Array:
	var all_abilities: Array = DataManager.load_abilities(character_id)
	var result: Array = []
	for ability: Variant in all_abilities:
		if not ability is Dictionary:
			continue
		var a: Dictionary = ability as Dictionary
		var req_level: Variant = a.get("level_learned", null)
		if a.get("story_gated", false):
			var event: String = a.get("story_event", "")
			if event == "" or not EventFlags.get_flag(event):
				continue
		elif req_level is int and (req_level as int) > level:
			continue
		elif req_level == null:
			continue
		result.append(a)
	result.sort_custom(_sort_by_level)
	return result


static func format_cost(ability: Dictionary) -> String:
	var ctype: String = ability.get("cost_type", "")
	var value: int = ability.get("cost_value", 0)
	match ctype:
		"ap":
			return "%d AP" % value
		"mp":
			return "%d MP" % value
		"ac":
			return "%d AC" % value
		"wg":
			return "%d WG" % value
		"mp_cd":
			var cd: int = ability.get("cooldown", 0)
			return "%d MP/%dt" % [value, cd]
		"none":
			return "Passive"
	return ability.get("cost", "")


static func get_resource_label(character_id: String, member: Dictionary) -> String:
	var abilities: Array = DataManager.load_abilities(character_id)
	if abilities.is_empty():
		return ""
	var first: Dictionary = abilities[0] as Dictionary if abilities[0] is Dictionary else {}
	var cmd: String = first.get("command", "")
	var label: String = RESOURCE_LABELS.get(cmd, "")
	if label == "MP":
		return "MP %d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]
	return label


static func _sort_by_level(a: Dictionary, b: Dictionary) -> bool:
	var la: int = a.get("level_learned", 0) if a.get("level_learned") is int else 0
	var lb: int = b.get("level_learned", 0) if b.get("level_learned") is int else 0
	return la < lb
