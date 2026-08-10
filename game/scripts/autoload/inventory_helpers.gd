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
		var equippable: Array = item_data.get("equippable_by", [])
		return equippable.is_empty() or character_id in equippable
	if slot == "body":
		var armor_class: String = item_data.get("armor_class", "light")
		if armor_class == "heavy":
			return character_id in ["edren", "lira"]
		if armor_class == "robe":
			return character_id in ["maren", "torren"]
		return true
	if slot == "accessory" or slot == "crystal":
		var equippable: Array = item_data.get("equippable_by", [])
		return equippable.is_empty() or character_id in equippable
	return false


## Whether a consumable's effect can currently apply. A second Sable's
## Coin is refused while one is active — a guarantee cannot be improved,
## and the item must not be silently burned.
static func can_apply_item_effect(item_data: Dictionary) -> bool:
	if item_data.get("effect", "") == "preemptive":
		return not EventFlags.check_required_flags("sables_coin_active")
	return true


## Apply a consumable item's effect to a target member Dictionary.
static func apply_item_effect(item_data: Dictionary, target: Dictionary) -> void:
	var effect: String = item_data.get("effect", "")
	match effect:
		"restore_hp":
			var max_hp: int = target.get("max_hp", 1)
			var raw_val: Variant = item_data.get("value")
			var value: int = int(raw_val) if raw_val != null else 0
			if item_data.has("restore_percent"):
				var pct: int = item_data.get("restore_percent", 0)
				value = int(float(max_hp) * float(pct) / 100.0)
			target["current_hp"] = mini(target.get("current_hp", 0) + value, max_hp)
			if item_data.get("clears_status", false):
				target["status_effects"] = [] as Array
		"restore_mp":
			var max_mp: int = target.get("max_mp", 1)
			var raw_mp: Variant = item_data.get("value")
			var value: int = int(raw_mp) if raw_mp != null else 0
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
			if item_data.get("clears_status", false):
				target["status_effects"] = [] as Array
		"revive":
			if target.get("current_hp", 0) <= 0:
				var max_hp: int = target.get("max_hp", 1)
				var raw_rev: Variant = item_data.get("value")
				var revive_pct: int = int(raw_rev) if raw_rev != null else 25
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
		"buff_atk":
			push_warning("InventoryHelpers: buff_atk is battle-only (use BattleManager)")
		"buff_mag":
			push_warning("InventoryHelpers: buff_mag is battle-only (use BattleManager)")
		"light_source":
			EventFlags.set_flag("light_source_active", true)
		"stat_boost":
			# Stat Capsules (items.md § Stat Capsules) are permanent. The gain is
			# banked in its own dictionary so the level-up recompute of base_stats
			# cannot wipe it (GAP-020).
			var stat_key: String = item_data.get("stat", "")
			var boost: int = item_data.get("value", 0)
			if stat_key != "" and boost > 0:
				add_capsule_gain(target, stat_key, boost)
		"teleport":
			push_warning("InventoryHelpers: teleport effect not yet implemented")
		"preemptive":
			EventFlags.set_flag("sables_coin_active", true)


## Permanent Stat Capsule gain banked on a member for one stat. Members saved
## before GAP-020 have no `stat_capsules` key, so the lookup defaults to zero.
static func get_capsule_gain(member: Dictionary, stat: String) -> int:
	var caps: Variant = member.get("stat_capsules", {})
	if not caps is Dictionary:
		return 0
	return int((caps as Dictionary).get(stat, 0))


## Bank a permanent Stat Capsule gain on a member, creating the dictionary on
## first use so legacy members upgrade in place.
static func add_capsule_gain(member: Dictionary, stat: String, amount: int) -> void:
	if stat.is_empty() or amount <= 0:
		return
	var caps: Variant = member.get("stat_capsules", {})
	var gains: Dictionary = caps as Dictionary if caps is Dictionary else {}
	gains[stat] = int(gains.get(stat, 0)) + amount
	member["stat_capsules"] = gains


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


## Compute leveled stats AND apply the character's permanent hidden stat spike
## (GAP-010) on top. Data-driven from char_data.hidden_spike. Used everywhere
## base_stats is (re)built — at join and on level-up — so the spike is never
## wiped by a recompute (progression.md:388: spikes are permanent).
static func leveled_stats_with_spike(char_data: Dictionary, level: int) -> Dictionary:
	var stats: Dictionary = calculate_stats_at_level(
		char_data.get("base_stats", {}), char_data.get("growth", {}), level
	)
	var spike: Dictionary = char_data.get("hidden_spike", {})
	for stat_key: String in spike:
		stats[stat_key] = int(stats.get(stat_key, 0)) + int(spike[stat_key])
	return stats


## Equipment bonus contributed by the member's worn gear for one stat. Covers the
## item-data slots only; the crystal slot is runtime state and is supplied by the
## caller (PartyState owns crystal levels).
static func get_worn_equipment_bonus(member: Dictionary, stat: String) -> int:
	var equip: Dictionary = member.get("equipment", {})
	var total: int = 0
	for slot: String in ["weapon", "head", "body", "accessory"]:
		var equip_id: String = equip.get(slot, "")
		if equip_id == "":
			continue
		var item_data: Dictionary = lookup_equipment(equip_id)
		total += get_top_level_stat(item_data, slot, stat)
		total += item_data.get("bonus_stats", {}).get(stat, 0)
	return total


## Worn gear plus the equipped Ley Crystal, resolved through the PartyState
## autoload because crystal levels are runtime state rather than item data.
## Used by the static level-up path, which has only the member dictionary.
static func get_full_equipment_bonus(member: Dictionary, stat: String) -> int:
	var total: int = get_worn_equipment_bonus(member, stat)
	var crystal_id: String = member.get("equipment", {}).get("crystal", "")
	if not crystal_id.is_empty():
		total += PartyState.get_crystal_stat_bonus(crystal_id, stat, member.get("level", 1))
	return total


## The ONE place a persistent stat total is assembled: leveled base stats (hidden
## spike included) + permanent Stat Capsule gains + equipment/crystal bonus, then
## clamped to the caps in progression.md § Stat Caps. Every effective-stat reader
## and the max HP/MP recalculation funnel through this, so a level-up can never
## diverge from an equip change (#274) and capsules are never invisible (#165).
static func compute_effective_stat(member: Dictionary, stat: String, equip_bonus: int) -> int:
	var total: int = int(member.get("base_stats", {}).get(stat, 0))
	total += get_capsule_gain(member, stat)
	total += equip_bonus
	if stat == "hp":
		return mini(total, 14999)
	if stat == "mp":
		return mini(total, 1499)
	return clampi(total, 0, 255)


## Re-derive max HP/MP from the effective-stat formula and re-clamp current
## HP/MP. Called after every change to a member's persistent stats — equip,
## unequip, crystal swap, capsule, level-up — so there is a single recalculation.
## `bonus_fn` takes a stat name and returns that stat's equipment bonus; when it
## is omitted the bonus is resolved from the member dictionary itself.
static func recalculate_max_hp_mp(member: Dictionary, bonus_fn: Callable = Callable()) -> void:
	if member.is_empty():
		return
	var resolve: Callable = bonus_fn
	if not resolve.is_valid():
		resolve = func(stat: String) -> int: return get_full_equipment_bonus(member, stat)
	member["max_hp"] = maxi(1, compute_effective_stat(member, "hp", int(resolve.call("hp"))))
	member["max_mp"] = maxi(0, compute_effective_stat(member, "mp", int(resolve.call("mp"))))
	member["current_hp"] = mini(member.get("current_hp", 0), member["max_hp"])
	member["current_mp"] = mini(member.get("current_mp", 0), member["max_mp"])


## Compute derived stats (evasion, magic evasion, crit) from effective stat values.
static func compute_derived_stats(spd: int, lck: int, mdef: int) -> Dictionary:
	return {
		"eva_pct": clampi(int(spd / 4), 0, 50),
		"meva_pct": clampi(int((mdef + spd) / 8), 0, 40),
		"crit_pct": clampi(int(lck / 4), 0, 50),
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


## Add XP to a party member, processing any level-ups.
## Recalculates stats on level-up using character JSON data.
## Returns {leveled_up: bool, old_level: int, new_level: int}.
## Source: progression.md § XP Distribution, § Two-Phase XP Curve.
static func add_xp_to_member(member: Dictionary, amount: int) -> Dictionary:
	var level: int = member.get("level", 1)
	if amount <= 0:
		return {"leveled_up": false, "old_level": level, "new_level": level}
	var xp: int = member.get("current_xp", 0) + amount
	var old_level: int = level
	while level < 150:
		var needed: int = xp_to_next_level(level)
		if needed <= 0 or xp < needed:
			break
		xp -= needed
		level += 1
	if level >= 150:
		xp = 0
	member["current_xp"] = xp
	member["level"] = level
	member["xp_to_next"] = xp_to_next_level(level)
	if level > old_level:
		var char_data: Dictionary = DataManager.load_character(member.get("character_id", ""))
		if not char_data.is_empty():
			# Re-apply the permanent hidden spike so level-up recompute keeps it.
			member["base_stats"] = leveled_stats_with_spike(char_data, level)
			# Max HP/MP go through the shared recalculation, which layers the
			# permanent capsule gains and the equipment/crystal bonus back on
			# top of the fresh base stats (#274, GAP-020).
			recalculate_max_hp_mp(member)
		member["current_hp"] = member["max_hp"]
		member["current_mp"] = member["max_mp"]
	return {"leveled_up": level > old_level, "old_level": old_level, "new_level": level}


## Distribute battle rewards across active and reserve party.
## Active alive: full XP. KO'd: 0 XP. Reserve: 50% XP.
## Returns {level_ups: Array, gold_gained: int, items_gained: Array}.
## Source: progression.md § XP Distribution Rules.
static func distribute_rewards(
	rewards: Dictionary,
	active_party: Array[Dictionary],
	reserve_party: Array[Dictionary],
) -> Dictionary:
	var level_ups: Array[Dictionary] = []
	var xp_amount: int = rewards.get("xp", 0)
	var drops: Array = rewards.get("drops", [])
	# Active party: full XP if alive, 0 if KO'd
	for member: Dictionary in active_party:
		if member.get("current_hp", 0) > 0:
			var result: Dictionary = add_xp_to_member(member, xp_amount)
			if result.get("leveled_up", false):
				var lu: Dictionary = {
					"character_id": member.get("character_id", ""),
					"old_level": result.get("old_level", 0),
					"new_level": result.get("new_level", 0),
				}
				level_ups.append(lu)
	# Reserve party: 50% XP (KO'd get 0)
	for member: Dictionary in reserve_party:
		if member.get("current_hp", 0) <= 0:
			continue
		var result: Dictionary = add_xp_to_member(member, xp_amount / 2)
		if result.get("leveled_up", false):
			var lu: Dictionary = {
				"character_id": member.get("character_id", ""),
				"old_level": result.get("old_level", 0),
				"new_level": result.get("new_level", 0),
			}
			level_ups.append(lu)
	return {
		"level_ups": level_ups,
		"gold_gained": rewards.get("gold", 0),
		"items_gained": drops,
	}


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
	play_time: int = 0,
	lc: Dictionary = {},
	ps: Dictionary = {}
) -> Dictionary:
	return {
		"party": party.duplicate(true),
		"formation": form.duplicate(true),
		"inventory": inv.duplicate(true),
		"owned_equipment": equips.duplicate(true),
		"crafting":
		{
			"arcanite_charges": 12,
			"device_loadout": [null, null, null, null, null],
			"discovered_synergies": [],
			"unlocked_recipes": [],
		},
		"ley_crystals": lc.duplicate(true),
		"puzzle_state": ps.duplicate(true),
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


## Filter owned equipment entries by slot and character equip rules.
static func filter_equippable_for_slot(
	owned_equipment: Array[Dictionary],
	character_id: String,
	slot: String,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in owned_equipment:
		var equip_id: String = entry.get("equipment_id", "")
		var item_data: Dictionary = lookup_equipment(equip_id)
		if item_data.is_empty() or not can_equip(character_id, slot, item_data):
			continue
		result.append(item_data)
	return result


## Get active party members by resolving formation indices into the members array.
static func get_active_members(
	members: Array[Dictionary],
	formation: Dictionary,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var active: Array = formation.get("active", [])
	for idx: Variant in active:
		var i: int = int(idx) if idx is int or idx is float else -1
		if i >= 0 and i < members.size():
			result.append(members[i])
	return result


## Get reserve (non-active) members from a members array and formation dict.
static func get_reserve_members(
	members: Array[Dictionary],
	formation: Dictionary,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var active_indices: Array = formation.get("active", [])
	var int_active: Array[int] = []
	for idx: Variant in active_indices:
		if idx is int or idx is float:
			int_active.append(int(idx))
	for i: int in range(members.size()):
		if i not in int_active:
			result.append(members[i])
	return result


## Apply gold and item drops from rewards dict to party state via callbacks.
## Calls add_gold_fn and add_item_fn closures, returns distribute_rewards summary.
static func apply_battle_rewards(
	rewards: Dictionary,
	active: Array[Dictionary],
	reserve: Array[Dictionary],
	add_gold_fn: Callable,
	add_item_fn: Callable,
) -> Dictionary:
	var result: Dictionary = distribute_rewards(rewards, active, reserve)
	add_gold_fn.call(rewards.get("gold", 0))
	for drop: Variant in rewards.get("drops", []):
		if drop is Dictionary:
			var item_id: String = (drop as Dictionary).get("item_id", "")
			if not item_id.is_empty():
				add_item_fn.call(item_id, 1)
	return result


## Resolve formation active indices to uppercase character names for display.
static func format_active_party_names(save_data: Dictionary) -> String:
	var party_arr: Array = save_data.get("party", [])
	var active: Array = save_data.get("formation", {}).get("active", [])
	var names: Array[String] = []
	for idx: Variant in active:
		var i: int = int(idx) if idx is int or idx is float else -1
		if i >= 0 and i < party_arr.size() and party_arr[i] is Dictionary:
			names.append(str(party_arr[i].get("character_id", "???")).to_upper())
		else:
			names.append(str(idx))
	return "  ".join(names)


## Build ordered list: active first, then reserve. _formation_index matches
## the index used by swap_formation — both use the same ordering contract.
static func build_formation_list(members: Array, formation: Dictionary) -> Array:
	var result: Array = []
	var active: Array = formation.get("active", [])
	var int_active: Array[int] = []
	for a: Variant in active:
		if a is int or a is float:
			int_active.append(int(a))
	for idx: int in int_active:
		if idx >= 0 and idx < members.size():
			var m: Dictionary = members[idx].duplicate()
			m["_is_active"] = true
			m["_formation_index"] = result.size()
			result.append(m)
	for i: int in range(members.size()):
		if i not in int_active:
			var m: Dictionary = members[i].duplicate()
			m["_is_active"] = false
			m["_formation_index"] = result.size()
			result.append(m)
	return result


static func swap_formation(members: Array, formation: Dictionary, idx_a: int, idx_b: int) -> void:
	var active: Array = formation.get("active", [])
	var order: Array = []
	for a: Variant in active:
		if a is int or a is float:
			order.append(int(a))
	for i: int in range(members.size()):
		if i not in order:
			order.append(i)
	if idx_a < 0 or idx_b < 0 or idx_a >= order.size() or idx_b >= order.size() or idx_a == idx_b:
		return
	var tmp: int = order[idx_a]
	order[idx_a] = order[idx_b]
	order[idx_b] = tmp
	var new_active: Array[int] = []
	for i: int in range(mini(active.size(), order.size())):
		new_active.append(order[i])
	formation["active"] = new_active
