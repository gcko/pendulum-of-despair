class_name PartyPersistence
extends RefCounted
## Save/load facet of PartyState: decoding a save file into runtime state,
## encoding runtime state back out, and tracking where on which map the party
## is standing (save-system.md § 3.7).
##
## Extracted from party_state.gd (GAP-087). The save format is decoded in this
## one place; PartyState keeps the public API and forwards here.

const Helpers = preload("res://scripts/util/inventory_helpers.gd")

var _party: Node


func _init(party: Node) -> void:
	_party = party


## Replace all runtime state with the contents of a save dictionary.
func load_from_save(data: Dictionary) -> void:
	_party.members.clear()
	_party.owned_equipment.clear()
	for m: Variant in data.get("party", []):
		if m is Dictionary:
			_party.members.append(m as Dictionary)
	_party.formation = data.get("formation", {"active": [], "reserve": [], "rows": {}})
	_party.inventory = data.get("inventory", {"consumables": {}, "materials": {}, "key_items": []})
	for e: Variant in data.get("owned_equipment", []):
		if e is Dictionary:
			_party.owned_equipment.append(e as Dictionary)
	_party.set_next_inst_id(Helpers.find_max_inst_id(_party.owned_equipment))
	var world: Dictionary = data.get("world", {})
	_party.gold = world.get("gold", 0)
	_party.location_name = world.get("current_location", "")
	_party.location_display = world.get("location_display", "")
	# A save with no recorded position keeps has_player_position false, so a
	# re-save cannot invent an origin the player was never standing on (#269).
	_party.has_player_position = Helpers.has_saved_position(world)
	_party.player_position = Helpers.saved_position(world)
	_party.playtime = data.get("meta", {}).get("playtime", 0)
	_party.is_at_save_point = false
	EventFlags.load_from_save(world.get("event_flags", {}))
	var lc_data: Variant = data.get("ley_crystals", {})
	_party.ley_crystals = lc_data as Dictionary if lc_data is Dictionary else {}
	var ps_data: Variant = data.get("puzzle_state", {})
	_party.puzzle_state = ps_data as Dictionary if ps_data is Dictionary else {}
	# Max HP/MP are derived at load time, not trusted from the file
	# (save-system.md § 1). Runs last because the crystal term needs the
	# ley_crystals block above. A save written before #274 therefore loads with
	# its equipment HP/MP bonus restored instead of a stale maximum.
	for m: Dictionary in _party.members:
		_party.refresh_max_hp_mp(m.get("character_id", ""))


## The full save dictionary for the current runtime state.
func build_save_data() -> Dictionary:
	return Helpers.build_save_dict(
		_party.members,
		_party.formation,
		_party.inventory,
		_party.owned_equipment,
		build_world_state(),
		_party.playtime,
		_party.ley_crystals,
		_party.puzzle_state
	)


## The world block written to a save: which map the party is on, where they
## stand on it, gold and event flags (save-system.md § 3.7). `current_position`
## is omitted while no position has been recorded, which tells the loader to
## use the map's default spawn marker (#269).
func build_world_state() -> Dictionary:
	var world: Dictionary = {
		"current_location": _party.location_name,
		"location_display": _party.location_display,
		"gold": _party.gold,
		"event_flags": EventFlags.to_save_data(),
	}
	if _party.has_player_position:
		world["current_position"] = {"x": _party.player_position.x, "y": _party.player_position.y}
	return world


## Record where the party currently stands. Exploration calls this as the
## player moves, so a save taken at any moment stores the real position
## instead of a hardcoded origin (#269).
func set_player_location(map_id: String, position: Vector2i) -> void:
	if not map_id.is_empty():
		_party.location_name = map_id
	_party.player_position = position
	_party.has_player_position = true


## Forget the recorded map and position (new game). The next map load records
## a fresh one.
func clear_player_location() -> void:
	_party.location_name = ""
	_party.location_display = ""
	_party.player_position = Vector2i.ZERO
	_party.has_player_position = false
