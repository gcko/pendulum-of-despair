extends RefCounted
## Static helpers for inventory operations — item lookup, effects, equipment checks.
## Extracted from PartyState to keep files under 400 lines.


## Look up a consumable by ID from DataManager.
static func lookup_consumable(item_id: String) -> Dictionary:
	var items: Array = DataManager.load_items("consumables")
	for item: Variant in items:
		if item is Dictionary and (item as Dictionary).get("id", "") == item_id:
			return item as Dictionary
	return {}


## Look up equipment by ID across all equipment types.
static func lookup_equipment(equipment_id: String) -> Dictionary:
	for equip_type: String in ["weapons", "armor", "accessories"]:
		var items: Array = DataManager.load_equipment(equip_type)
		for item: Variant in items:
			if item is Dictionary and (item as Dictionary).get("id", "") == equipment_id:
				return item as Dictionary
	return {}


## Check if a character can equip an item in a specific slot.
static func can_equip(character_id: String, slot: String, item_data: Dictionary) -> bool:
	if slot == "weapon":
		var equippable: Array = item_data.get("equippable_by", [])
		return character_id in equippable
	if slot == "head":
		return true
	if slot == "body":
		var armor_class: String = item_data.get("armor_class", "light")
		if armor_class == "heavy":
			return character_id in ["edren", "lira"]
		if armor_class == "robe":
			return character_id in ["maren", "torren"]
		return true
	if slot == "accessory" or slot == "crystal":
		return true
	return false


## Apply a consumable item's effect to a target member Dictionary.
static func apply_item_effect(item_data: Dictionary, target: Dictionary) -> void:
	var effect: String = item_data.get("effect", "")
	match effect:
		"restore_hp":
			var max_hp: int = target.get("max_hp", 1)
			var value: int = item_data.get("value", 0)
			if item_data.has("restore_percent"):
				var pct: int = item_data.get("restore_percent", 0)
				value = int(float(max_hp) * float(pct) / 100.0)
			target["current_hp"] = mini(target.get("current_hp", 0) + value, max_hp)
		"restore_mp":
			var max_mp: int = target.get("max_mp", 1)
			var value: int = item_data.get("value", 0)
			if item_data.has("restore_percent"):
				var pct: int = item_data.get("restore_percent", 0)
				value = int(float(max_mp) * float(pct) / 100.0)
			target["current_mp"] = mini(target.get("current_mp", 0) + value, max_mp)
		"restore_hp_mp":
			var max_hp: int = target.get("max_hp", 1)
			var max_mp: int = target.get("max_mp", 0)
			if item_data.has("restore_percent"):
				var pct: int = item_data.get("restore_percent", 0)
				var hp_val: int = int(float(max_hp) * float(pct) / 100.0)
				var mp_val: int = int(float(max_mp) * float(pct) / 100.0)
				target["current_hp"] = mini(target.get("current_hp", 0) + hp_val, max_hp)
				target["current_mp"] = mini(target.get("current_mp", 0) + mp_val, max_mp)
			else:
				target["current_hp"] = max_hp
				target["current_mp"] = max_mp
			target["status_effects"] = [] as Array
		"revive":
			if target.get("current_hp", 0) <= 0:
				var max_hp: int = target.get("max_hp", 1)
				var revive_pct: int = item_data.get("value", 25)
				var revived_hp: int = int(ceil(float(max_hp) * float(revive_pct) / 100.0))
				target["current_hp"] = clampi(revived_hp, 1, max_hp)
		"cure_status":
			var cures: Array = item_data.get("cures", [])
			var effects: Array = target.get("status_effects", [])
			var remaining: Array = []
			for s: Variant in effects:
				if s is Dictionary:
					var status_name: String = (s as Dictionary).get("name", "")
					if status_name not in cures:
						remaining.append(s)
			target["status_effects"] = remaining


## Extract top-level stat from equipment (atk for weapons, def/mdef for armor).
static func get_top_level_stat(item_data: Dictionary, slot: String, stat: String) -> int:
	if stat == "atk" and slot == "weapon":
		return item_data.get("atk", 0)
	if stat in ["def", "mdef"] and slot in ["head", "body"]:
		return item_data.get(stat, 0)
	return 0


## Get sort value for equipment optimization.
static func get_equip_sort_value(item_data: Dictionary, slot: String, priority_stat: String) -> int:
	if slot == "weapon":
		return item_data.get("atk", 0)
	var bonus: Dictionary = item_data.get("bonus_stats", {})
	var top_def: int = get_top_level_stat(item_data, slot, "def")
	var top_mdef: int = get_top_level_stat(item_data, slot, "mdef")
	return (
		bonus.get(priority_stat, 0)
		+ top_def
		+ bonus.get("def", 0)
		+ top_mdef
		+ bonus.get("mdef", 0)
	)


static func calculate_stats_at_level(
	base: Dictionary, growth: Dictionary, level: int
) -> Dictionary:
	var stats: Dictionary = {}
	for key: String in base:
		var b: float = float(base[key])
		var g: float = float(growth.get(key, 0))
		var raw: float = b + g * (level - 1)
		var cap: int = 255
		if key == "hp":
			cap = 14999
		elif key == "mp":
			cap = 1499
		stats[key] = mini(int(raw + 0.5), cap)
	return stats


## Compute derived stats (evasion, magic evasion, crit) from effective stat values.
static func compute_derived_stats(spd: int, lck: int, mdef: int) -> Dictionary:
	return {
		"eva_pct": clampi(spd / 4, 0, 50),
		"meva_pct": clampi((mdef + spd) / 8, 0, 40),
		"crit_pct": clampi(lck / 4, 0, 50),
	}


## Scan owned equipment entries for the highest _inst_ suffix number.
static func find_max_inst_id(owned_equipment: Array) -> int:
	var max_id: int = 0
	for e: Variant in owned_equipment:
		if not e is Dictionary:
			continue
		var inst: String = (e as Dictionary).get("id", "")
		var idx: int = inst.rfind("_inst_")
		if idx >= 0:
			max_id = maxi(max_id, inst.substr(idx + 6).to_int())
	return max_id


static func xp_to_next_level(level: int) -> int:
	if level >= 150:
		return 0
	if level <= 70:
		return int(24.0 * pow(float(level), 1.5))
	return int(10.0 * pow(float(level), 1.8))


## Load config from disk, merging user overrides onto defaults.
static func load_config_from_disk() -> Dictionary:
	var user_config: Dictionary = {}
	if FileAccess.file_exists(SaveManager.CONFIG_PATH):
		var file: FileAccess = FileAccess.open(SaveManager.CONFIG_PATH, FileAccess.READ)
		if file != null:
			var json: JSON = JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				user_config = json.data as Dictionary
			file.close()
	var defaults: Dictionary = DataManager.load_json("res://data/config/defaults.json")
	var config: Dictionary = defaults.duplicate()
	for key: String in user_config:
		config[key] = user_config[key]
	return config


## Build the save data template with stub sections for systems not yet implemented.
static func build_save_dict(
	party: Array,
	form: Dictionary,
	inv: Dictionary,
	equips: Array,
	loc: String,
	g: int,
	flags: Dictionary,
	play_time: int = 0
) -> Dictionary:
	return {
		"party": party.duplicate(true),
		"formation": form.duplicate(true),
		"inventory": inv.duplicate(true),
		"owned_equipment": equips.duplicate(true),
		"crafting":
		{
			"arcanite_charges": 12,
			"device_loadout": [{}, {}, {}, {}, {}],
			"discovered_synergies": [],
			"unlocked_recipes": [],
		},
		"ley_crystals": {"collected": []},
		"meta":
		{
			"version": 1,
			"playtime": play_time,
			"saved_at": Time.get_datetime_string_from_system(),
			"slot_type": "manual",
		},
		"world":
		{
			"event_flags": flags,
			"act": "1",
			"current_location": loc,
			"current_position": {"x": 0, "y": 0},
			"gold": g,
		},
		"quests": {"active": [], "completed": []},
		"completion": {"bestiary": [], "treasures": [], "items_found": []},
	}
