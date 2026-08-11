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
## Player's pixel position on `location_name`'s map. Only meaningful while
## `has_player_position` is true — see save-system.md § 3.7 (#269).
var player_position: Vector2i = Vector2i.ZERO
## Whether a real player position has been recorded yet. False for a fresh game
## and for saves written before positions were persisted; the loader then uses
## the map's default spawn marker instead.
var has_player_position: bool = false
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
	clear_player_location()
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
	# A save with no recorded position keeps has_player_position false, so a
	# re-save cannot invent an origin the player was never standing on (#269).
	has_player_position = Helpers.has_saved_position(world)
	player_position = Helpers.saved_position(world)
	playtime = data.get("meta", {}).get("playtime", 0)
	is_at_save_point = false
	EventFlags.load_from_save(world.get("event_flags", {}))
	var lc_data: Variant = data.get("ley_crystals", {})
	ley_crystals = lc_data as Dictionary if lc_data is Dictionary else {}
	var ps_data: Variant = data.get("puzzle_state", {})
	puzzle_state = ps_data as Dictionary if ps_data is Dictionary else {}
	# Max HP/MP are derived at load time, not trusted from the file
	# (save-system.md § 1). Runs last because the crystal term needs the
	# ley_crystals block above. A save written before #274 therefore loads with
	# its equipment HP/MP bonus restored instead of a stale maximum.
	for m: Dictionary in members:
		_recalculate_max_hp_mp(m.get("character_id", ""))


func build_save_data() -> Dictionary:
	return Helpers.build_save_dict(
		members,
		formation,
		inventory,
		owned_equipment,
		build_world_state(),
		playtime,
		ley_crystals,
		puzzle_state
	)


## The world block written to a save: which map the party is on, where they
## stand on it, gold and event flags (save-system.md § 3.7). `current_position`
## is omitted while no position has been recorded, which tells the loader to
## use the map's default spawn marker (#269).
func build_world_state() -> Dictionary:
	var world: Dictionary = {
		"current_location": location_name,
		"gold": gold,
		"event_flags": EventFlags.to_save_data(),
	}
	if has_player_position:
		world["current_position"] = {"x": player_position.x, "y": player_position.y}
	return world


## Record where the party currently stands. Exploration calls this as the
## player moves, so a save taken at any moment stores the real position
## instead of a hardcoded origin (#269).
func set_player_location(map_id: String, position: Vector2i) -> void:
	if not map_id.is_empty():
		location_name = map_id
	player_position = position
	has_player_position = true


## Forget the recorded map and position (new game). The next map load records
## a fresh one.
func clear_player_location() -> void:
	location_name = ""
	player_position = Vector2i.ZERO
	has_player_position = false


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
	var old_level: int = state.get("level", 1)
	state["level"] = level
	if level > old_level:
		_recalculate_crystal_holder(crystal_id)


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


## Base stats + permanent Stat Capsule gains + equipment/crystal bonus, clamped.
## Delegates the assembly to Helpers so battle stat baking and the level-up
## recalculation share one formula.
func get_effective_stat(character_id: String, stat: String) -> int:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return 0
	return Helpers.compute_effective_stat(m, stat, get_equipment_bonus(character_id, stat))


## Permanent Stat Capsule gain for one stat (GAP-020). Zero for members saved
## before capsules were persisted.
func get_capsule_gain(character_id: String, stat: String) -> int:
	return Helpers.get_capsule_gain(get_member(character_id), stat)


func get_equipment_bonus(character_id: String, stat: String) -> int:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return 0
	var total: int = Helpers.get_worn_equipment_bonus(m, stat)
	# Crystal bonuses come from this instance's ley_crystals, not owned_equipment
	var crystal_id: String = m.get("equipment", {}).get("crystal", "")
	if not crystal_id.is_empty():
		total += get_crystal_stat_bonus(crystal_id, stat, m.get("level", 1))
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
		equip_item(character_id, slot, best.get("equipment_id", ""))


func get_consumables() -> Dictionary:
	return inventory.get("consumables", {})


## Held crafting materials as {item_id: quantity} (items.md § Crafting Materials).
func get_materials() -> Dictionary:
	return inventory.get("materials", {})


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
	if not Helpers.can_apply_item_effect(item_data, target):
		return false
	# Max HP/MP are derived, never authoritative in storage (save-system.md § 1),
	# so re-derive BEFORE the effect too: a full or percentage restore sizes
	# itself off max_hp, and healing against a stale maximum under-heals.
	_recalculate_max_hp_mp(target_character_id)
	Helpers.apply_item_effect(item_data, target)
	# A Stat Capsule can raise HP/MP, so re-derive the maxima through the shared
	# recalculation. Idempotent for every other consumable effect.
	_recalculate_max_hp_mp(target_character_id)
	consume_item(item_id)
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


## Removes Edren's temporary arcanite equipment after Ember Vein escape.
func break_arcanite_gear() -> void:
	var changed: bool = false
	for i: int in range(members.size()):
		var member: Dictionary = members[i]
		if member.get("character_id", "") != "edren":
			continue
		var equipment: Dictionary = member.get("equipment", {})
		if equipment.get("weapon", "") == "arcanite_sword_proto":
			equipment["weapon"] = ""
			changed = true
		if equipment.get("body", "") == "arcanite_mail_proto":
			equipment["body"] = ""
			changed = true
		members[i]["equipment"] = equipment
		break
	# Also purge from owned_equipment in case player unequipped them
	for proto_id: String in ["arcanite_sword_proto", "arcanite_mail_proto"]:
		for i: int in range(owned_equipment.size() - 1, -1, -1):
			if owned_equipment[i].get("equipment_id", "") == proto_id:
				owned_equipment.remove_at(i)
				changed = true
	if changed:
		equipment_changed.emit("edren")


## Add a quantity item to the inventory, routed to its bucket: crafting
## materials to `materials`, everything else to `consumables` (GAP-019).
func add_item(item_id: String, quantity: int) -> void:
	if quantity <= 0 or item_id.is_empty():
		return
	var bucket: String = Helpers.bucket_for_item(item_id)
	var items: Dictionary = inventory.get(bucket, {})
	items[item_id] = items.get(item_id, 0) + quantity
	inventory[bucket] = items
	inventory_changed.emit()


## Remove a quantity item from whichever bucket it belongs to.
func remove_item(item_id: String, quantity: int) -> void:
	if quantity <= 0 or item_id.is_empty():
		return
	var bucket: String = Helpers.bucket_for_item(item_id)
	var items: Dictionary = inventory.get(bucket, {})
	items[item_id] = maxi(0, items.get(item_id, 0) - quantity)
	if items[item_id] <= 0:
		items.erase(item_id)
	inventory[bucket] = items
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


## Find the members array index for a character by ID. Returns -1 if not found.
func find_member_index(character_id: String) -> int:
	for i: int in range(members.size()):
		if members[i].get("character_id", "") == character_id:
			return i
	return -1


## Move a character from active formation to reserve by ID.
## Returns true if the character was moved, false otherwise.
func move_member_to_reserve(character_id: String) -> bool:
	var idx: int = find_member_index(character_id)
	if idx < 0:
		return false
	if not formation.has("active") or not formation.has("reserve"):
		push_warning("PartyState: formation missing active/reserve keys")
		return false
	var active: Array = formation["active"]
	var reserve: Array = formation["reserve"]
	var found: Variant = null
	for a: Variant in active:
		if (a is int or a is float) and int(a) == idx:
			found = a
			break
	if found == null:
		return false
	active.erase(found)
	reserve.append(idx)
	return true


## Move a character from reserve back to active formation by ID.
## Returns true if the character was moved, false otherwise.
func move_member_to_active(character_id: String) -> bool:
	var idx: int = find_member_index(character_id)
	if idx < 0:
		return false
	if not formation.has("active") or not formation.has("reserve"):
		push_warning("PartyState: formation missing active/reserve keys")
		return false
	var active: Array = formation["active"]
	var reserve: Array = formation["reserve"]
	var found: Variant = null
	for r: Variant in reserve:
		if (r is int or r is float) and int(r) == idx:
			found = r
			break
	if found == null:
		return false
	reserve.erase(found)
	if active.size() < 4:
		active.append(idx)
		return true
	push_warning("PartyState: cannot move to active — party full")
	return false


## Revive all KO'd active party members at a fraction of max HP.
func revive_active_at_fraction(fraction: float) -> void:
	var active_list: Array = []
	if formation.has("active"):
		active_list = formation["active"]
	for idx: Variant in active_list:
		if not (idx is int or idx is float):
			continue
		var mi: int = int(idx)
		if mi < 0 or mi >= members.size():
			continue
		var m: Dictionary = members[mi]
		if m.get("current_hp", 0) <= 0:
			m["current_hp"] = maxi(1, floori(float(m.get("max_hp", 1)) * fraction))


## Apply rest item effects: restore HP/MP by percentage, optionally
## clear status. Applies to ALL party members (active + reserve).
func rest_party(restore_pct: float, clears_status: bool) -> void:
	for m: Dictionary in members:
		if m.is_empty():
			continue
		var max_hp: int = int(m.get("max_hp", m.get("base_stats", {}).get("hp", 1)))
		var max_mp: int = int(m.get("max_mp", m.get("base_stats", {}).get("mp", 0)))
		m["current_hp"] = mini(
			int(m.get("current_hp", max_hp)) + int(max_hp * restore_pct),
			max_hp,
		)
		m["current_mp"] = mini(
			int(m.get("current_mp", max_mp)) + int(max_mp * restore_pct),
			max_mp,
		)
		if clears_status:
			m["status_effects"] = []


## Consume one unit of an item from its own bucket. Returns true if consumed.
## Battle use of a Drake Fang spends it from the material stack (items.md
## § Drake Fang Special Case), which is the same routing rule adds use.
func consume_item(item_id: String) -> bool:
	var bucket: String = Helpers.bucket_for_item(item_id)
	var items: Dictionary = inventory.get(bucket, {})
	var qty: int = items.get(item_id, 0)
	if qty <= 0:
		return false
	items[item_id] = qty - 1
	if items[item_id] <= 0:
		items.erase(item_id)
	inventory[bucket] = items
	inventory_changed.emit()
	return true


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
	# Never add the same character twice — keeps the hidden spike applied once.
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return
	var char_data: Dictionary = DataManager.load_character(character_id)
	if char_data.is_empty():
		push_error("PartyState: Character not found: %s" % character_id)
		return
	# Leveled stats with the permanent hidden spike (GAP-010) baked in — the
	# same helper runs on level-up so the spike is never wiped by a recompute.
	var stats: Dictionary = Helpers.leveled_stats_with_spike(char_data, level)
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
		# Permanent Stat Capsule gains, kept apart from base_stats so a level-up
		# recompute cannot wipe them (items.md § Stat Capsules).
		"stat_capsules": {} as Dictionary,
		"equipment": starting_equip.duplicate(),
		"status_effects": [] as Array,
	}
	members.append(member)
	# Max HP/MP go through the one recalculation so starting-gear bonuses count,
	# then the character joins at full health.
	_recalculate_max_hp_mp(character_id)
	member["current_hp"] = member["max_hp"]
	member["current_mp"] = member["max_mp"]


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


## Re-derive the wearer's max HP/MP after a crystal's own level changed. A
## crystal level carries hp_per_level / mp_per_level (ley_crystals.json), so
## levelling one is a change to its holder's persistent stats and must go
## through the same recalculation an equip change does (#274 family).
func _recalculate_crystal_holder(crystal_id: String) -> void:
	for m: Dictionary in members:
		if m.get("equipment", {}).get("crystal", "") != crystal_id:
			continue
		var holder_id: String = m.get("character_id", "")
		_recalculate_max_hp_mp(holder_id)
		equipment_changed.emit(holder_id)


## Re-derive max HP/MP after anything that changes persistent stats. Routes
## through the shared recalculation so this instance's crystal state is used
## while the formula stays identical to the level-up path (#274).
func _recalculate_max_hp_mp(character_id: String) -> void:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return
	Helpers.recalculate_max_hp_mp(
		m, func(stat: String) -> int: return get_equipment_bonus(character_id, stat)
	)


func _generate_inst_id(equipment_id: String) -> String:
	_next_inst_id += 1
	return "%s_inst_%d" % [equipment_id, _next_inst_id]


func _has_owned_equipment(equipment_id: String) -> bool:
	return owned_equipment.any(
		func(e: Dictionary) -> bool: return e.get("equipment_id", "") == equipment_id
	)
