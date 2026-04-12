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
	"edren":
	{
		"weapon": "arcanite_sword_proto",
		"head": "",
		"body": "arcanite_mail_proto",
		"accessory": "",
		"crystal": ""
	},
	"cael": {"weapon": "recruits_claymore", "head": "", "body": "", "accessory": "", "crystal": ""},
	"lira": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
	"sable": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
	"torren": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
	"maren": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
}

const STARTING_CONSUMABLES: Dictionary = {
	"potion": 5,
	"antidote": 2,
}
const STARTING_GOLD: int = 200

var members: Array[Dictionary] = []
var formation: Dictionary = {"active": [], "reserve": [], "rows": {}}
var inventory: Dictionary = {"consumables": {}, "materials": {}, "key_items": []}
var owned_equipment: Array[Dictionary] = []
var gold: int = 0
var playtime: int = 0
var location_name: String = ""
var is_at_save_point: bool = false
var ley_crystals: Dictionary = {}
var puzzle_state: Dictionary = {}
var _config: Dictionary = {}
var _config_loaded: bool = false
var _next_inst_id: int = 0


func _ready() -> void:
	_load_config()


func initialize_new_game() -> void:
	members.clear()
	owned_equipment.clear()
	_next_inst_id = 0
	is_at_save_point = false
	EventFlags.clear_all()
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
	ley_crystals.clear()
	puzzle_state.clear()


func add_member(character_id: String, level: int = 1) -> void:
	if character_id.is_empty():
		return
	level = maxi(1, level)
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return
	var prev_size: int = members.size()
	_add_character(character_id, level)
	if members.size() == prev_size:
		return
	var idx: int = members.size() - 1
	if formation["active"].size() < 4:
		formation["active"].append(idx)
	else:
		formation["reserve"].append(idx)
	var char_data: Dictionary = DataManager.load_character(character_id)
	var default_row: String = char_data.get("default_row", "back")
	formation["rows"][character_id] = default_row


func has_member(character_id: String) -> bool:
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return true
	return false


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
	_next_inst_id = Helpers.find_max_inst_id(owned_equipment)
	var world: Dictionary = data.get("world", {})
	gold = world.get("gold", 0)
	location_name = world.get("current_location", "")
	playtime = data.get("meta", {}).get("playtime", 0)
	is_at_save_point = false
	EventFlags.load_from_save(world.get("event_flags", {}))
	var lc_data: Variant = data.get("ley_crystals", {})
	ley_crystals = lc_data as Dictionary if lc_data is Dictionary else {}
	var ps_data: Variant = data.get("puzzle_state", {})
	puzzle_state = ps_data as Dictionary if ps_data is Dictionary else {}


func build_save_data() -> Dictionary:
	return Helpers.build_save_dict(
		members,
		formation,
		inventory,
		owned_equipment,
		location_name,
		gold,
		EventFlags.to_save_data(),
		playtime,
		ley_crystals,
		puzzle_state
	)


func get_active_party() -> Array[Dictionary]:
	return Helpers.get_active_members(members, formation)


## Get reserve (non-active) party members.
func get_reserve_party() -> Array[Dictionary]:
	return Helpers.get_reserve_members(members, formation)


## Add a Ley Crystal to the collection at Lv1 / 0 XP. No-op if already owned.
func add_ley_crystal(crystal_id: String) -> void:
	if crystal_id.is_empty() or ley_crystals.has(crystal_id):
		return
	ley_crystals[crystal_id] = {"xp": 0, "level": 1}


## Get a crystal's runtime state. Returns empty dict if not owned.
func get_crystal_state(crystal_id: String) -> Dictionary:
	return ley_crystals.get(crystal_id, {})


## Add XP to a crystal. Auto-levels when thresholds are crossed.
## At Lv5 (max), excess XP is discarded. Multi-level jumps supported.
func add_crystal_xp(crystal_id: String, amount: int) -> void:
	if not ley_crystals.has(crystal_id) or amount <= 0:
		return
	var state: Dictionary = ley_crystals[crystal_id]
	var crystal_data: Dictionary = DataManager.get_ley_crystal(crystal_id)
	var thresholds: Array = crystal_data.get("xp_thresholds", [0, 800, 2500, 6000, 15000])
	var level: int = state.get("level", 1)
	if level >= 5:
		return
	var xp: int = state.get("xp", 0) + amount
	while level < 5 and level < thresholds.size() and xp >= thresholds[level]:
		level += 1
	if level >= 5:
		xp = thresholds[4] if thresholds.size() > 4 else 15000
	state["xp"] = xp
	state["level"] = level


## Equip a crystal on a character. Swaps if another character has it.
## Crystal slot is managed separately from owned_equipment (no instance IDs).
func equip_crystal(character_id: String, crystal_id: String) -> void:
	if character_id.is_empty() or crystal_id.is_empty():
		return
	if not ley_crystals.has(crystal_id):
		return
	var target: Dictionary = get_member(character_id)
	if target.is_empty():
		return
	# Validate target BEFORE clearing old holder (ordering rule)
	for m: Dictionary in members:
		if m.get("equipment", {}).get("crystal", "") == crystal_id:
			if m.get("character_id", "") != character_id:
				m["equipment"]["crystal"] = ""
				_recalculate_max_hp_mp(m.get("character_id", ""))
				equipment_changed.emit(m.get("character_id", ""))
			break
	if not target.has("equipment"):
		target["equipment"] = {}
	target["equipment"]["crystal"] = crystal_id
	_recalculate_max_hp_mp(character_id)
	equipment_changed.emit(character_id)


## Unequip the crystal slot without adding to owned_equipment.
func unequip_crystal(character_id: String) -> String:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return ""
	var old_id: String = m.get("equipment", {}).get("crystal", "")
	if old_id.is_empty():
		return ""
	m["equipment"]["crystal"] = ""
	_recalculate_max_hp_mp(character_id)
	equipment_changed.emit(character_id)
	return old_id


## Get all collected crystal IDs.
func get_collected_crystals() -> Array[String]:
	var result: Array[String] = []
	for key: String in ley_crystals:
		result.append(key)
	result.sort()
	return result


## Set a puzzle state value for a dungeon.
func set_puzzle_state(dungeon_id: String, key: String, value: Variant) -> void:
	if dungeon_id.is_empty() or key.is_empty():
		return
	if not puzzle_state.has(dungeon_id) or not puzzle_state[dungeon_id] is Dictionary:
		puzzle_state[dungeon_id] = {}
	puzzle_state[dungeon_id][key] = value


## Get a puzzle state value. Returns default_value if not set.
func get_puzzle_state(dungeon_id: String, key: String, default_value: Variant = false) -> Variant:
	if not puzzle_state.has(dungeon_id):
		return default_value
	if not puzzle_state[dungeon_id] is Dictionary:
		puzzle_state[dungeon_id] = {}
		return default_value
	return puzzle_state[dungeon_id].get(key, default_value)


## Clear all puzzle state for a dungeon.
func clear_puzzle_state(dungeon_id: String) -> void:
	puzzle_state.erase(dungeon_id)


## Apply battle rewards (XP, gold, drops). Returns Helpers.distribute_rewards() summary.
func distribute_battle_rewards(rewards: Dictionary) -> Dictionary:
	return Helpers.apply_battle_rewards(
		rewards, get_active_party(), get_reserve_party(), add_gold, add_item
	)


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
	var total: int = m.get("base_stats", {}).get(stat, 0) + get_equipment_bonus(character_id, stat)
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
	for slot: String in ["weapon", "head", "body", "accessory"]:
		var equip_id: String = equip.get(slot, "")
		if equip_id == "":
			continue
		var item_data: Dictionary = Helpers.lookup_equipment(equip_id)
		total += Helpers.get_top_level_stat(item_data, slot, stat)
		total += item_data.get("bonus_stats", {}).get(stat, 0)
	# Crystal bonuses come from ley_crystals data, not owned_equipment
	var crystal_id: String = equip.get("crystal", "")
	if not crystal_id.is_empty():
		var char_level: int = m.get("level", 1)
		total += get_crystal_stat_bonus(crystal_id, stat, char_level)
	return total


func get_derived_stats(character_id: String) -> Dictionary:
	return Helpers.compute_derived_stats(
		get_effective_stat(character_id, "spd"),
		get_effective_stat(character_id, "lck"),
		get_effective_stat(character_id, "mdef")
	)


func equip_item(character_id: String, slot: String, equipment_id: String) -> Dictionary:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return {}
	var equip: Dictionary = m.get("equipment", {})
	var old_id: String = equip.get(slot, "")
	if not _has_owned_equipment(equipment_id):
		push_error("PartyState: Cannot equip '%s' — not in owned_equipment" % equipment_id)
		return {}
	if old_id != "":
		owned_equipment.append({"id": _generate_inst_id(old_id), "equipment_id": old_id})
	_remove_owned_equipment(equipment_id)
	equip[slot] = equipment_id
	m["equipment"] = equip
	_recalculate_max_hp_mp(character_id)
	equipment_changed.emit(character_id)
	return {"old_equipment_id": old_id}


func unequip_slot(character_id: String, slot: String) -> String:
	if slot == "crystal":
		return unequip_crystal(character_id)
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return ""
	var equip: Dictionary = m.get("equipment", {})
	var old_id: String = equip.get(slot, "")
	if old_id == "":
		return ""
	owned_equipment.append({"id": _generate_inst_id(old_id), "equipment_id": old_id})
	equip[slot] = ""
	m["equipment"] = equip
	_recalculate_max_hp_mp(character_id)
	equipment_changed.emit(character_id)
	return old_id


func get_equippable_for_slot(character_id: String, slot: String) -> Array[Dictionary]:
	return Helpers.filter_equippable_for_slot(owned_equipment, character_id, slot)


func optimize_equipment(character_id: String) -> void:
	var priority_stat: String = "mag" if character_id in ["maren", "torren"] else "atk"
	# Crystal slot excluded — uses ley_crystals system, not owned_equipment
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
	if item_data.is_empty() or not item_data.get("usable_in_field", false):
		return false
	if item_data.get("requires_save_point", false) and not is_at_save_point:
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


## Add equipment to owned inventory with a generated instance ID.
func add_equipment(eid: String) -> void:
	owned_equipment.append({"id": _generate_inst_id(eid), "equipment_id": eid})


func add_key_item(item_id: String) -> void:
	var key_items: Variant = inventory.get("key_items", [])
	if not key_items is Array:
		key_items = []
	if item_id not in key_items:
		key_items.append(item_id)
		inventory["key_items"] = key_items
		inventory_changed.emit()


func remove_key_item(item_id: String) -> void:
	var key_items: Variant = inventory.get("key_items", [])
	if not key_items is Array:
		return
	if item_id in key_items:
		key_items.erase(item_id)
		inventory["key_items"] = key_items
		inventory_changed.emit()


func break_arcanite_gear() -> void:
	## Removes Edren's temporary arcanite equipment after Ember Vein escape.
	for i: int in range(members.size()):
		var member: Dictionary = members[i]
		if member.get("character_id", "") != "edren":
			continue
		var equipment: Dictionary = member.get("equipment", {})
		if equipment.get("weapon", "") == "arcanite_sword_proto":
			equipment["weapon"] = ""
		if equipment.get("body", "") == "arcanite_mail_proto":
			equipment["body"] = ""
		members[i]["equipment"] = equipment
		break
	inventory_changed.emit()


func add_item(item_id: String, quantity: int) -> void:
	if quantity <= 0:
		return
	var consumables: Dictionary = inventory.get("consumables", {})
	consumables[item_id] = consumables.get(item_id, 0) + quantity
	inventory["consumables"] = consumables
	inventory_changed.emit()


func remove_item(item_id: String, quantity: int) -> void:
	if quantity <= 0:
		return
	var cons: Dictionary = inventory.get("consumables", {})
	cons[item_id] = maxi(0, cons.get(item_id, 0) - quantity)
	if cons[item_id] <= 0:
		cons.erase(item_id)
	inventory["consumables"] = cons
	inventory_changed.emit()


func get_gold() -> int:
	return gold


func add_gold(amount: int) -> void:
	if amount > 0:
		gold += amount


func spend_gold(amount: int) -> bool:
	if amount <= 0 or amount > gold:
		return false
	gold -= amount
	return true


## Restore ALL party members to full HP/MP/AC, clear status. Per economy.md.
func rest_at_inn() -> void:
	for member: Dictionary in members:
		if member.is_empty():
			continue
		member["current_hp"] = member.get("max_hp", 1)
		member["current_mp"] = member.get("max_mp", 0)
		member["current_ac"] = 12
		member["status_effects"] = []


## Deduct MP from a party member. Returns false if insufficient.
func spend_mp(character_id: String, amount: int) -> bool:
	var m: Dictionary = get_member(character_id)
	if m.is_empty() or amount <= 0 or m.get("current_mp", 0) < amount:
		return false
	m["current_mp"] -= amount
	return true


## Heal a party member's HP. Returns actual amount restored.
func heal_member(character_id: String, amount: int) -> int:
	var m: Dictionary = get_member(character_id)
	if m.is_empty() or amount <= 0:
		return 0
	var old: int = m.get("current_hp", 0)
	m["current_hp"] = mini(m.get("max_hp", old), old + amount)
	return m["current_hp"] - old


func get_row(cid: String) -> String:
	return formation.get("rows", {}).get(cid, "front")


func toggle_row(cid: String) -> void:
	var r: Dictionary = formation.get("rows", {})
	r[cid] = "back" if r.get(cid, "front") == "front" else "front"
	formation["rows"] = r


func get_formation_list() -> Array:
	return Helpers.build_formation_list(members, formation)


func swap_formation_positions(a: int, b: int) -> void:
	Helpers.swap_formation(members, formation, a, b)


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
	var stats: Dictionary = Helpers.calculate_stats_at_level(
		char_data.get("base_stats", {}), char_data.get("growth", {}), level
	)
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
	_config = Helpers.load_config_from_disk()
	_config_loaded = true


func _remove_owned_equipment(equipment_id: String) -> void:
	for i: int in range(owned_equipment.size()):
		if owned_equipment[i].get("equipment_id", "") == equipment_id:
			owned_equipment.remove_at(i)
			return


## Get a crystal's stat bonus at its current level. Reads level_bonuses from static data.
## For hp/mp, also includes hp_per_level/mp_per_level scaled by character level.
func get_crystal_stat_bonus(crystal_id: String, stat: String, char_level: int = 1) -> int:
	var runtime: Dictionary = get_crystal_state(crystal_id)
	if runtime.is_empty():
		return 0
	var level: int = runtime.get("level", 1)
	var static_data: Dictionary = DataManager.get_ley_crystal(crystal_id)
	var level_bonuses: Array = static_data.get("level_bonuses", [])
	if level_bonuses.size() < level:
		return 0
	var bonus: Dictionary = (
		level_bonuses[level - 1] if level_bonuses[level - 1] is Dictionary else {}
	)
	var total: int = int(bonus.get(stat, 0))
	if stat == "hp":
		total += int(bonus.get("hp_per_level", 0)) * char_level
	elif stat == "mp":
		total += int(bonus.get("mp_per_level", 0)) * char_level
	return total


func _recalculate_max_hp_mp(character_id: String) -> void:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return
	var bs: Dictionary = m.get("base_stats", {})
	m["max_hp"] = mini(bs.get("hp", 1) + get_equipment_bonus(character_id, "hp"), 14999)
	m["max_mp"] = mini(bs.get("mp", 0) + get_equipment_bonus(character_id, "mp"), 1499)
	m["current_hp"] = mini(m.get("current_hp", 0), m["max_hp"])
	m["current_mp"] = mini(m.get("current_mp", 0), m["max_mp"])


func _generate_inst_id(equipment_id: String) -> String:
	_next_inst_id += 1
	return "%s_inst_%d" % [equipment_id, _next_inst_id]


func _has_owned_equipment(equipment_id: String) -> bool:
	return owned_equipment.any(
		func(e: Dictionary) -> bool: return e.get("equipment_id", "") == equipment_id
	)
