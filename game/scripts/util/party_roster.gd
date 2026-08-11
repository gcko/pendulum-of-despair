class_name PartyRoster
extends RefCounted
## Party composition facet of PartyState: who is in the active four, who waits
## in reserve, and which row each character fights from.
##
## Extracted from party_state.gd (GAP-087). PartyState keeps the public API and
## forwards here; the `formation` dictionary itself stays on the autoload
## because saves and tests read it directly.

## The active party never exceeds four members (combat-formulas.md § Party).
const MAX_ACTIVE: int = 4

const Helpers = preload("res://scripts/util/inventory_helpers.gd")

var _party: Node


func _init(party: Node) -> void:
	_party = party


## Recruit a character into the party at [param level], slotting them into the
## active four when there is room and into reserve otherwise. No-op when they
## are already present.
func add_member(character_id: String, level: int) -> void:
	if character_id.is_empty():
		return
	level = maxi(1, level)
	if has_member(character_id):
		return
	var prev_size: int = _party.members.size()
	add_character(character_id, level)
	if _party.members.size() == prev_size:
		return
	var idx: int = _party.members.size() - 1
	if _party.formation["active"].size() < MAX_ACTIVE:
		_party.formation["active"].append(idx)
	else:
		_party.formation["reserve"].append(idx)
	var char_data: Dictionary = DataManager.load_character(character_id)
	_party.formation["rows"][character_id] = char_data.get("default_row", "back")


func has_member(character_id: String) -> bool:
	for m: Dictionary in _party.members:
		if m.get("character_id", "") == character_id:
			return true
	return false


## Build a member record from static character data and append it. Used by the
## new-game bootstrap as well as by add_member; never adds a duplicate, which
## keeps the hidden stat spike (GAP-010) applied exactly once.
func add_character(character_id: String, level: int) -> void:
	if has_member(character_id):
		return
	var char_data: Dictionary = DataManager.load_character(character_id)
	if char_data.is_empty():
		push_error("PartyState: Character not found: %s" % character_id)
		return
	# Leveled stats with the permanent hidden spike (GAP-010) baked in — the
	# same helper runs on level-up so the spike is never wiped by a recompute.
	var stats: Dictionary = Helpers.leveled_stats_with_spike(char_data, level)
	var starting_equip: Dictionary = _party.STARTING_EQUIPMENT.get(
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
	_party.members.append(member)
	# Max HP/MP go through the one recalculation so starting-gear bonuses count,
	# then the character joins at full health.
	_party.refresh_max_hp_mp(character_id)
	member["current_hp"] = member["max_hp"]
	member["current_mp"] = member["max_mp"]


## Find the members array index for a character by ID. Returns -1 if not found.
func find_member_index(character_id: String) -> int:
	for i: int in range(_party.members.size()):
		if _party.members[i].get("character_id", "") == character_id:
			return i
	return -1


## Move a character from active formation to reserve by ID.
## Returns true if the character was moved, false otherwise.
func move_to_reserve(character_id: String) -> bool:
	var idx: int = find_member_index(character_id)
	if idx < 0:
		return false
	if not _has_active_and_reserve():
		return false
	var active: Array = _party.formation["active"]
	var found: Variant = _find_index_entry(active, idx)
	if found == null:
		return false
	active.erase(found)
	_party.formation["reserve"].append(idx)
	return true


## Move a character from reserve back to active formation by ID.
## Returns true if the character was moved, false otherwise.
func move_to_active(character_id: String) -> bool:
	var idx: int = find_member_index(character_id)
	if idx < 0:
		return false
	if not _has_active_and_reserve():
		return false
	var active: Array = _party.formation["active"]
	var reserve: Array = _party.formation["reserve"]
	var found: Variant = _find_index_entry(reserve, idx)
	if found == null:
		return false
	reserve.erase(found)
	if active.size() < MAX_ACTIVE:
		active.append(idx)
		return true
	push_warning("PartyState: cannot move to active — party full")
	return false


## The row a character fights from; "front" unless they were toggled back.
func get_row(cid: String) -> String:
	return _party.formation.get("rows", {}).get(cid, "front")


## Flip a character between the front and back row.
func toggle_row(cid: String) -> void:
	var r: Dictionary = _party.formation.get("rows", {})
	r[cid] = "back" if r.get(cid, "front") == "front" else "front"
	_party.formation["rows"] = r


## The formation menu's ordered view of active + reserve slots.
func formation_list() -> Array:
	return Helpers.build_formation_list(_party.members, _party.formation)


## Swap two entries of the formation list by display index.
func swap_positions(a: int, b: int) -> void:
	Helpers.swap_formation(_party.members, _party.formation, a, b)


## Whether the formation dictionary still carries both slot lists. A save
## written with a malformed formation is warned about rather than crashed on.
func _has_active_and_reserve() -> bool:
	if _party.formation.has("active") and _party.formation.has("reserve"):
		return true
	push_warning("PartyState: formation missing active/reserve keys")
	return false


## The entry in [param slots] that refers to member index [param idx]. Saved
## formations may hold floats (JSON numbers), so the comparison is by value and
## the original entry is returned for `erase` to match on.
func _find_index_entry(slots: Array, idx: int) -> Variant:
	for entry: Variant in slots:
		if (entry is int or entry is float) and int(entry) == idx:
			return entry
	return null
