extends Node
## Runtime party/inventory/equipment state. Autoloaded as PartyState.

signal inventory_changed
signal equipment_changed(character_id: String)

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")
const CLASS_TITLES: Dictionary = {
	"edren": "Knight",
	"cael": "Commander",
	"lira": "Engineer",
	"torren": "Sage",
	"sable": "Thief",
	"maren": "Archmage",
}

const STARTING_EQUIPMENT: Dictionary = {
	"edren": {"weapon": "training_sword", "head": "", "body": "", "accessory": "", "crystal": ""},
	"cael": {"weapon": "recruits_claymore", "head": "", "body": "", "accessory": "", "crystal": ""},
}

const STARTING_CONSUMABLES: Dictionary = {
	"potion": 5,
	"antidote": 2,
}
const STARTING_GOLD: int = 200

var members: Array[Dictionary] = []
var formation: Dictionary = {
	"active": [] as Array[int],
	"reserve": [] as Array[int],
	"rows": {} as Dictionary,
}
var inventory: Dictionary = {
	"consumables": {} as Dictionary,
	"materials": {} as Dictionary,
	"key_items": [] as Array[String],
}
var owned_equipment: Array[Dictionary] = []
var gold: int = 0
var playtime: int = 0
var location_name: String = ""
var is_at_save_point: bool = false
var _config: Dictionary = {}
var _config_loaded: bool = false


func _ready() -> void:
	_load_config()


func initialize_new_game() -> void:
	members.clear()
	owned_equipment.clear()
	_add_character("edren", 1)
	_add_character("cael", 1)
	formation = {
		"active": [0, 1] as Array[int],
		"reserve": [] as Array[int],
		"rows": {"edren": "front", "cael": "front"} as Dictionary,
	}
	inventory = {
		"consumables": STARTING_CONSUMABLES.duplicate(),
		"materials": {} as Dictionary,
		"key_items": [] as Array[String],
	}
	gold = STARTING_GOLD
	playtime = 0
	location_name = ""


func load_from_save(data: Dictionary) -> void:
	members.clear()
	owned_equipment.clear()

	var party_data: Array = data.get("party", [])
	for m: Variant in party_data:
		if m is Dictionary:
			members.append(m as Dictionary)

	formation = data.get("formation", {"active": [], "reserve": [], "rows": {}})
	inventory = data.get("inventory", {"consumables": {}, "materials": {}, "key_items": []})

	var equip_data: Array = data.get("owned_equipment", [])
	for e: Variant in equip_data:
		if e is Dictionary:
			owned_equipment.append(e as Dictionary)

	var world: Dictionary = data.get("world", {})
	gold = world.get("gold", 0)
	location_name = world.get("current_location", "")
	playtime = data.get("meta", {}).get("playtime", 0)


func build_save_data() -> Dictionary:
	return {
		"party": members.duplicate(true),
		"formation": formation.duplicate(true),
		"inventory": inventory.duplicate(true),
		"owned_equipment": owned_equipment.duplicate(true),
		"crafting":
		{
			"arcanite_charges": 12,
			"device_loadout": [{}, {}, {}, {}, {}],
			"discovered_synergies": [],
			"unlocked_recipes": [],
		},
		"ley_crystals": {"collected": []},
		"world":
		{
			"event_flags": EventFlags.to_save_data(),
			"act": "1",
			"current_location": location_name,
			"current_position": {"x": 0, "y": 0},
			"gold": gold,
		},
		"quests": {"active": [], "completed": []},
		"completion": {"bestiary": [], "treasures": [], "items_found": []},
	}


func get_active_party() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var active: Array = formation.get("active", [])
	for idx: Variant in active:
		var i: int = idx as int
		if i >= 0 and i < members.size():
			result.append(members[i])
	return result


func get_member(character_id: String) -> Dictionary:
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return m
	return {}


func get_all_members() -> Array[Dictionary]:
	return members


func get_effective_stat(character_id: String, stat: String) -> int:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return 0
	var base: int = m.get("base_stats", {}).get(stat, 0)
	var bonus: int = get_equipment_bonus(character_id, stat)
	var total: int = base + bonus
	if stat == "hp":
		return mini(total, 14999)
	if stat == "mp":
		return mini(total, 1499)
	return clampi(total, 0, 255)


func get_equipment_bonus(character_id: String, stat: String) -> int:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return 0
	var equip: Dictionary = m.get("equipment", {})
	var total: int = 0
	for slot: String in ["weapon", "head", "body", "accessory", "crystal"]:
		var equip_id: String = equip.get(slot, "")
		if equip_id == "":
			continue
		var item_data: Dictionary = Helpers.lookup_equipment(equip_id)
		if stat == "atk" and slot == "weapon":
			total += item_data.get("atk", 0)
		var bonus_stats: Dictionary = item_data.get("bonus_stats", {})
		total += bonus_stats.get(stat, 0)
	return total


func get_derived_stats(character_id: String) -> Dictionary:
	var spd: int = get_effective_stat(character_id, "spd")
	var lck: int = get_effective_stat(character_id, "lck")
	var mdef: int = get_effective_stat(character_id, "mdef")
	return {
		"eva_pct": clampi(spd / 4, 0, 50),
		"meva_pct": clampi((mdef + spd) / 8, 0, 40),
		"crit_pct": clampi(lck / 4, 0, 50),
	}


func equip_item(character_id: String, slot: String, equipment_id: String) -> Dictionary:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return {}
	var equip: Dictionary = m.get("equipment", {})
	var old_id: String = equip.get(slot, "")

	# Return old item to inventory
	if old_id != "":
		owned_equipment.append({"id": old_id + "_inst", "equipment_id": old_id})

	# Remove new item from inventory
	_remove_owned_equipment(equipment_id)

	equip[slot] = equipment_id
	m["equipment"] = equip
	_recalculate_max_hp_mp(character_id)
	equipment_changed.emit(character_id)
	return {"old_equipment_id": old_id}


func unequip_slot(character_id: String, slot: String) -> String:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return ""
	var equip: Dictionary = m.get("equipment", {})
	var old_id: String = equip.get(slot, "")
	if old_id == "":
		return ""
	owned_equipment.append({"id": old_id + "_inst", "equipment_id": old_id})
	equip[slot] = ""
	m["equipment"] = equip
	_recalculate_max_hp_mp(character_id)
	equipment_changed.emit(character_id)
	return old_id


func get_equippable_for_slot(character_id: String, slot: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in owned_equipment:
		var equip_id: String = entry.get("equipment_id", "")
		var item_data: Dictionary = Helpers.lookup_equipment(equip_id)
		if item_data.is_empty():
			continue
		if not Helpers.can_equip(character_id, slot, item_data):
			continue
		result.append(item_data)
	return result


func optimize_equipment(character_id: String) -> void:
	var is_caster: bool = character_id in ["maren", "torren"]
	var priority_stat: String = "mag" if is_caster else "atk"
	for slot: String in ["weapon", "head", "body", "accessory"]:
		var options: Array[Dictionary] = get_equippable_for_slot(character_id, slot)
		if options.is_empty():
			continue
		var best: Dictionary = options[0]
		var best_val: int = Helpers.get_equip_sort_value(best, slot, priority_stat)
		for opt: Dictionary in options:
			var val: int = Helpers.get_equip_sort_value(opt, slot, priority_stat)
			if val > best_val:
				best = opt
				best_val = val
		equip_item(character_id, slot, best.get("id", ""))


func get_consumables() -> Dictionary:
	return inventory.get("consumables", {})


func get_key_items() -> Array:
	return inventory.get("key_items", [])


func use_item(item_id: String, target_character_id: String) -> bool:
	var consumables: Dictionary = inventory.get("consumables", {})
	var qty: int = consumables.get(item_id, 0)
	if qty <= 0:
		return false

	var item_data: Dictionary = Helpers.lookup_consumable(item_id)
	if item_data.is_empty():
		return false
	if not item_data.get("usable_in_field", false):
		return false

	var target: Dictionary = get_member(target_character_id)
	if target.is_empty():
		return false

	Helpers.apply_item_effect(item_data, target)
	consumables[item_id] = qty - 1
	if consumables[item_id] <= 0:
		consumables.erase(item_id)
	inventory["consumables"] = consumables
	inventory_changed.emit()
	return true


func add_item(item_id: String, quantity: int) -> void:
	var consumables: Dictionary = inventory.get("consumables", {})
	consumables[item_id] = consumables.get(item_id, 0) + quantity
	inventory["consumables"] = consumables
	inventory_changed.emit()


func remove_item(item_id: String, quantity: int) -> void:
	var consumables: Dictionary = inventory.get("consumables", {})
	var current: int = consumables.get(item_id, 0)
	var remaining: int = maxi(0, current - quantity)
	if remaining <= 0:
		consumables.erase(item_id)
	else:
		consumables[item_id] = remaining
	inventory["consumables"] = consumables
	inventory_changed.emit()


func get_gold() -> int:
	return gold


func add_gold(amount: int) -> void:
	gold += amount


func spend_gold(amount: int) -> bool:
	if amount > gold:
		return false
	gold -= amount
	return true


func get_config() -> Dictionary:
	if not _config_loaded:
		_load_config()
	return _config


func set_config(key: String, value: Variant) -> void:
	_config[key] = value


func save_config() -> void:
	var file: FileAccess = FileAccess.open(SaveManager.CONFIG_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_config, "\t"))
		file.close()


func _add_character(character_id: String, level: int) -> void:
	var char_data: Dictionary = DataManager.load_character(character_id)
	if char_data.is_empty():
		push_error("PartyState: Character not found: %s" % character_id)
		return
	var base: Dictionary = char_data.get("base_stats", {})
	var growth: Dictionary = char_data.get("growth_rates", {})
	var stats: Dictionary = Helpers.calculate_stats_at_level(base, growth, level)
	var starting_equip: Dictionary = STARTING_EQUIPMENT.get(
		character_id, {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""}
	)
	var member: Dictionary = {
		"character_id": character_id,
		"level": level,
		"current_hp": stats.get("hp", 1),
		"max_hp": stats.get("hp", 1),
		"current_mp": stats.get("mp", 0),
		"max_mp": stats.get("mp", 0),
		"current_xp": 0,
		"xp_to_next": Helpers.xp_to_next_level(level),
		"base_stats": stats,
		"equipment": starting_equip.duplicate(),
		"status_effects": [] as Array,
	}
	members.append(member)


func _load_config() -> void:
	var user_config: Dictionary = {}
	if FileAccess.file_exists(SaveManager.CONFIG_PATH):
		var file: FileAccess = FileAccess.open(SaveManager.CONFIG_PATH, FileAccess.READ)
		if file != null:
			var json: JSON = JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				user_config = json.data as Dictionary
			file.close()

	var defaults: Dictionary = DataManager.load_json("res://data/config/defaults.json")
	_config = defaults.duplicate()
	for key: String in user_config:
		_config[key] = user_config[key]
	_config_loaded = true


func _remove_owned_equipment(equipment_id: String) -> void:
	for i: int in range(owned_equipment.size()):
		if owned_equipment[i].get("equipment_id", "") == equipment_id:
			owned_equipment.remove_at(i)
			return


func _recalculate_max_hp_mp(character_id: String) -> void:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return
	var base_hp: int = m.get("base_stats", {}).get("hp", 1)
	var base_mp: int = m.get("base_stats", {}).get("mp", 0)
	var hp_bonus: int = get_equipment_bonus(character_id, "hp")
	var mp_bonus: int = get_equipment_bonus(character_id, "mp")
	m["max_hp"] = mini(base_hp + hp_bonus, 14999)
	m["max_mp"] = mini(base_mp + mp_bonus, 1499)
	m["current_hp"] = mini(m.get("current_hp", 0), m["max_hp"])
	m["current_mp"] = mini(m.get("current_mp", 0), m["max_mp"])
