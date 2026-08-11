class_name PartyCrystals
extends RefCounted
## Ley Crystal facet of PartyState: the owned collection, per-crystal XP and
## level, which character wears which crystal, and the stat bonus a worn
## crystal grants.
##
## Extracted from party_state.gd (GAP-087). PartyState keeps the public API and
## forwards to this collaborator, so the crystal rules live in one place.

## Crystals cap at Lv5; XP earned past the cap is discarded.
const MAX_LEVEL: int = 5
## Fallback thresholds when a crystal's data carries no `xp_thresholds`.
const DEFAULT_XP_THRESHOLDS: Array = [0, 800, 2500, 6000, 15000]

var _party: Node


func _init(party: Node) -> void:
	_party = party


## Add a Ley Crystal to the collection at Lv1 / 0 XP. No-op if already owned.
func add(crystal_id: String) -> void:
	if crystal_id.is_empty() or _party.ley_crystals.has(crystal_id):
		return
	_party.ley_crystals[crystal_id] = {"xp": 0, "level": 1}


## Get a crystal's runtime state. Returns empty dict if not owned.
func get_state(crystal_id: String) -> Dictionary:
	return _party.ley_crystals.get(crystal_id, {})


## Add XP to a crystal. Auto-levels when thresholds are crossed.
## At Lv5 (max), excess XP is discarded. Multi-level jumps supported.
func add_xp(crystal_id: String, amount: int) -> void:
	if not _party.ley_crystals.has(crystal_id) or amount <= 0:
		return
	var state: Dictionary = _party.ley_crystals[crystal_id]
	var crystal_data: Dictionary = DataManager.get_ley_crystal(crystal_id)
	var thresholds: Array = crystal_data.get("xp_thresholds", DEFAULT_XP_THRESHOLDS)
	var level: int = state.get("level", 1)
	if level >= MAX_LEVEL:
		return
	var xp: int = state.get("xp", 0) + amount
	while level < MAX_LEVEL and level < thresholds.size() and xp >= thresholds[level]:
		level += 1
	if level >= MAX_LEVEL:
		xp = thresholds[4] if thresholds.size() > 4 else 15000
	state["xp"] = xp
	var old_level: int = state.get("level", 1)
	state["level"] = level
	if level > old_level:
		recalculate_holder(crystal_id)


## Equip a crystal on a character. Swaps if another character has it.
## Crystal slot is managed separately from owned_equipment (no instance IDs).
func equip(character_id: String, crystal_id: String) -> void:
	if character_id.is_empty() or crystal_id.is_empty():
		return
	if not _party.ley_crystals.has(crystal_id):
		return
	var target: Dictionary = _party.get_member(character_id)
	if target.is_empty():
		return
	# Validate target BEFORE clearing old holder (ordering rule)
	for m: Dictionary in _party.members:
		if m.get("equipment", {}).get("crystal", "") == crystal_id:
			if m.get("character_id", "") != character_id:
				m["equipment"]["crystal"] = ""
				_party.refresh_max_hp_mp(m.get("character_id", ""))
				_party.equipment_changed.emit(m.get("character_id", ""))
			break
	if not target.has("equipment"):
		target["equipment"] = {}
	target["equipment"]["crystal"] = crystal_id
	_party.refresh_max_hp_mp(character_id)
	_party.equipment_changed.emit(character_id)


## Unequip the crystal slot without adding to owned_equipment.
func unequip(character_id: String) -> String:
	var m: Dictionary = _party.get_member(character_id)
	if m.is_empty():
		return ""
	var old_id: String = m.get("equipment", {}).get("crystal", "")
	if old_id.is_empty():
		return ""
	m["equipment"]["crystal"] = ""
	_party.refresh_max_hp_mp(character_id)
	_party.equipment_changed.emit(character_id)
	return old_id


## Get all collected crystal IDs, sorted.
func collected() -> Array[String]:
	var result: Array[String] = []
	for key: String in _party.ley_crystals:
		result.append(key)
	result.sort()
	return result


## Get a crystal's stat bonus at its current level. Reads level_bonuses from static data.
## For hp/mp, also includes hp_per_level/mp_per_level scaled by character level.
func stat_bonus(crystal_id: String, stat: String, char_level: int = 1) -> int:
	var runtime: Dictionary = get_state(crystal_id)
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
func recalculate_holder(crystal_id: String) -> void:
	for m: Dictionary in _party.members:
		if m.get("equipment", {}).get("crystal", "") != crystal_id:
			continue
		var holder_id: String = m.get("character_id", "")
		_party.refresh_max_hp_mp(holder_id)
		_party.equipment_changed.emit(holder_id)
