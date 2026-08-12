class_name PartyEquipment
extends RefCounted
## Worn-gear facet of PartyState: equipping and unequipping the four gear
## slots, the pool of owned-but-unworn instances, and the stat bonus the worn
## set contributes.
##
## Extracted from party_state.gd (GAP-087). PartyState keeps the public API and
## owns `owned_equipment`; the instance-ID counter lives here because nothing
## outside this facet mints one.

## Slots backed by owned_equipment instances. The crystal slot is deliberately
## absent — it is held by ley_crystals, not by an instance (see PartyCrystals).
const INSTANCED_SLOTS: Array[String] = ["weapon", "head", "body", "accessory"]
## Characters whose auto-equip optimizes for MAG rather than ATK.
const MAGIC_USERS: Array[String] = ["maren", "torren"]

const Helpers = preload("res://scripts/util/inventory_helpers.gd")

var _party: Node
var _next_inst_id: int = 0


func _init(party: Node) -> void:
	_party = party


## Reset the instance-ID counter — 0 for a new game, or the highest ID already
## present in a loaded save so a re-equip cannot mint a duplicate.
func set_next_inst_id(value: int) -> void:
	_next_inst_id = value


## Equip an owned instance into a slot, returning the id it displaced (if any).
## Returns {} when the character or the instance is unknown.
func equip(character_id: String, slot: String, equipment_id: String) -> Dictionary:
	var m: Dictionary = _party.get_member(character_id)
	if m.is_empty():
		return {}
	var equip_dict: Dictionary = m.get("equipment", {})
	var old_id: String = equip_dict.get(slot, "")
	if not _owns(equipment_id):
		push_error("PartyState: Cannot equip '%s' — not in owned_equipment" % equipment_id)
		return {}
	if old_id != "":
		_party.owned_equipment.append({"id": _mint_inst_id(old_id), "equipment_id": old_id})
	_remove_owned(equipment_id)
	equip_dict[slot] = equipment_id
	m["equipment"] = equip_dict
	_party.refresh_max_hp_mp(character_id)
	_party.equipment_changed.emit(character_id)
	return {"old_equipment_id": old_id}


## Empty a slot, returning the equipment id that was in it back to the pool.
func unequip(character_id: String, slot: String) -> String:
	var m: Dictionary = _party.get_member(character_id)
	if m.is_empty():
		return ""
	var equip_dict: Dictionary = m.get("equipment", {})
	var old_id: String = equip_dict.get(slot, "")
	if old_id == "":
		return ""
	_party.owned_equipment.append({"id": _mint_inst_id(old_id), "equipment_id": old_id})
	equip_dict[slot] = ""
	m["equipment"] = equip_dict
	_party.refresh_max_hp_mp(character_id)
	_party.equipment_changed.emit(character_id)
	return old_id


func equippable_for_slot(character_id: String, slot: String) -> Array[Dictionary]:
	return Helpers.filter_equippable_for_slot(_party.owned_equipment, character_id, slot)


## Auto-equip the best owned instance in every instanced slot, ranked by the
## character's priority stat.
func optimize(character_id: String) -> void:
	var priority_stat: String = "mag" if character_id in MAGIC_USERS else "atk"
	for slot: String in INSTANCED_SLOTS:
		var options: Array[Dictionary] = equippable_for_slot(character_id, slot)
		if options.is_empty():
			continue
		var best: Dictionary = options[0]
		var best_val: int = Helpers.get_equip_sort_value(best, slot, priority_stat)
		for opt: Dictionary in options:
			var val: int = Helpers.get_equip_sort_value(opt, slot, priority_stat)
			if val > best_val:
				best = opt
				best_val = val
		equip(character_id, slot, best.get("equipment_id", ""))


## Add equipment to owned inventory with a generated instance ID.
func add(equipment_id: String) -> void:
	_party.owned_equipment.append({"id": _mint_inst_id(equipment_id), "equipment_id": equipment_id})


## Worn-gear plus crystal stat bonus for one character.
func stat_bonus(character_id: String, stat: String) -> int:
	var m: Dictionary = _party.get_member(character_id)
	if m.is_empty():
		return 0
	var total: int = Helpers.get_worn_equipment_bonus(m, stat)
	# Crystal bonuses come from this instance's ley_crystals, not owned_equipment
	var crystal_id: String = m.get("equipment", {}).get("crystal", "")
	if not crystal_id.is_empty():
		total += _party.get_crystal_stat_bonus(crystal_id, stat, m.get("level", 1))
	return total


## Removes Edren's temporary arcanite equipment after Ember Vein escape.
func break_arcanite_gear() -> void:
	var changed: bool = false
	for i: int in range(_party.members.size()):
		var member: Dictionary = _party.members[i]
		if member.get("character_id", "") != "edren":
			continue
		var equipment: Dictionary = member.get("equipment", {})
		if equipment.get("weapon", "") == "arcanite_sword_proto":
			equipment["weapon"] = ""
			changed = true
		if equipment.get("body", "") == "arcanite_mail_proto":
			equipment["body"] = ""
			changed = true
		_party.members[i]["equipment"] = equipment
		break
	# Also purge from owned_equipment in case player unequipped them
	for proto_id: String in ["arcanite_sword_proto", "arcanite_mail_proto"]:
		for i: int in range(_party.owned_equipment.size() - 1, -1, -1):
			if _party.owned_equipment[i].get("equipment_id", "") == proto_id:
				_party.owned_equipment.remove_at(i)
				changed = true
	if changed:
		_party.equipment_changed.emit("edren")


## Drop the first owned instance of an equipment id from the pool.
func _remove_owned(equipment_id: String) -> void:
	for i: int in range(_party.owned_equipment.size()):
		if _party.owned_equipment[i].get("equipment_id", "") == equipment_id:
			_party.owned_equipment.remove_at(i)
			return


func _owns(equipment_id: String) -> bool:
	return _party.owned_equipment.any(
		func(e: Dictionary) -> bool: return e.get("equipment_id", "") == equipment_id
	)


func _mint_inst_id(equipment_id: String) -> String:
	_next_inst_id += 1
	return "%s_inst_%d" % [equipment_id, _next_inst_id]
