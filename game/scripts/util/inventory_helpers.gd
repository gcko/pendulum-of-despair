extends RefCounted
## Static helpers for items and worn equipment: looking one up, deciding which
## inventory bucket it belongs in, applying its effect, and assembling a
## character's stat totals from the gear they wear.
##
## The save format lives in SaveDataHelpers, the XP curve and reward
## distribution in ProgressionHelpers, and the active/reserve ordering in
## FormationHelpers (GAP-087).


## Look up a consumable by ID from DataManager.
static func lookup_consumable(item_id: String) -> Dictionary:
	var items: Array = DataManager.load_items("consumables")
	for item: Variant in items:
		if item is Dictionary and (item as Dictionary).get("id", "") == item_id:
			return item as Dictionary
	return {}


## Look up a crafting material by ID from DataManager (data/items/materials.json).
static func lookup_material(item_id: String) -> Dictionary:
	var items: Array = DataManager.load_items("materials")
	for item: Variant in items:
		if item is Dictionary and (item as Dictionary).get("id", "") == item_id:
			return item as Dictionary
	return {}


## A material's sell value in gold. `sell_price` is present-but-null for
## materials whose worth is act-scaled (Gold Pouch) and for the story materials
## that cannot be sold at all, so a get(..., 0) default never fires and the raw
## null must never reach a format string (items.md § Sell Price Rules).
static func material_sell_value(material: Dictionary) -> int:
	var raw: Variant = material.get("sell_price")
	if raw != null:
		return int(raw)
	var by_act: Variant = material.get("gold_value_by_act")
	if by_act is Dictionary:
		return int((by_act as Dictionary).get(StoryAct.get_period(), 0))
	return 0


## Which inventory bucket an item id belongs in. Crafting materials go to
## `materials`, everything else counted by quantity to `consumables`
## (items.md § Inventory Structure). THE routing rule: every add, remove and
## consume goes through this, so an item can never land in one bucket and be
## looked for in the other (GAP-019).
static func bucket_for_item(item_id: String) -> String:
	return "materials" if not lookup_material(item_id).is_empty() else "consumables"


## Move crafting materials that were filed under consumables into the materials
## bucket, in place. Used by the v1 -> v2 save migration: before GAP-019 every
## drop was routed to consumables, where a material has no name and no use.
static func reroute_materials(inv: Dictionary) -> void:
	var consumables: Variant = inv.get("consumables", null)
	if not consumables is Dictionary:
		return
	var cons: Dictionary = consumables
	var mats: Variant = inv.get("materials", {})
	var materials: Dictionary = mats as Dictionary if mats is Dictionary else {}
	for item_id: String in cons.keys():
		if bucket_for_item(item_id) != "materials":
			continue
		materials[item_id] = int(materials.get(item_id, 0)) + int(cons[item_id])
		cons.erase(item_id)
	inv["consumables"] = cons
	inv["materials"] = materials


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
## and the item must not be silently burned. A Stat Capsule is refused on
## the same principle once its target's permanent total is at the stat cap.
## `target` is optional so callers without a member dictionary keep the old
## item-only behavior.
static func can_apply_item_effect(item_data: Dictionary, target: Dictionary = {}) -> bool:
	var effect: String = item_data.get("effect", "")
	if effect == "preemptive":
		return not EventFlags.check_required_flags("sables_coin_active")
	if effect == "stat_boost":
		return can_gain_capsule(target, item_data.get("stat", ""))
	return true


## Hard cap for one stat (progression.md § Stat Caps). One table so the
## effective-stat clamp and the capsule refusal can never disagree.
static func stat_cap(stat: String) -> int:
	if stat == "hp":
		return 14999
	if stat == "mp":
		return 1499
	return 255


## Whether a Stat Capsule would do anything for this target. Refused once the
## target's own permanent total — leveled base plus already-banked gains — sits
## at the cap, because base stats only ever grow and the extra gain could never
## become visible (items.md § Stat Capsules). Equipment is deliberately excluded
## from the comparison: a stat held at the cap by gear alone still benefits,
## since removing the gear reveals the banked gain.
static func can_gain_capsule(target: Dictionary, stat: String) -> bool:
	if target.is_empty() or stat.is_empty():
		return true
	var base: int = int(target.get("base_stats", {}).get(stat, 0))
	return base + get_capsule_gain(target, stat) < stat_cap(stat)


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


## Translate a crafting material's battle fields into the same shape a battle
## consumable has, so battle code never needs to know which bucket an item came
## from. Drake Fang is the only such material today (items.md § Drake Fang
## Special Case).
static func battle_entry_for_material(material: Dictionary, quantity: int) -> Dictionary:
	return {
		"id": material.get("id", ""),
		"name": material.get("name", ""),
		"effect": material.get("battle_effect", ""),
		"value": material.get("battle_value", 0),
		"target": material.get("battle_target", "single_enemy"),
		"usable_in_battle": true,
		"quantity": quantity,
	}


## Every item the party can use in battle: consumables flagged usable_in_battle
## plus battle-usable crafting materials, each carrying its held "quantity".
static func build_battle_item_list() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var consumables: Dictionary = PartyState.get_consumables()
	for item_id: String in consumables:
		var data: Dictionary = lookup_consumable(item_id)
		if data.is_empty() or not data.get("usable_in_battle", false):
			continue
		var entry: Dictionary = data.duplicate()
		entry["quantity"] = int(consumables[item_id])
		result.append(entry)
	var materials: Dictionary = PartyState.get_materials()
	for item_id: String in materials:
		var material: Dictionary = lookup_material(item_id)
		if material.is_empty() or not material.get("battle_usable", false):
			continue
		result.append(battle_entry_for_material(material, int(materials[item_id])))
	return result


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
	return clampi(total, 0, stat_cap(stat))


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
