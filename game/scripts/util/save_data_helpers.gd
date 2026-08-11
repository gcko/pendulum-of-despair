class_name SaveDataHelpers
extends RefCounted
## The save-file format: assembling the dictionary that gets written, reading
## the fields back out of one, and loading the player's config from disk.
##
## Extracted from inventory_helpers.gd (GAP-087). Everything that knows the
## shape of a save slot is here.


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


## Whether a save's world block carries a real recorded player position.
## Saves written before #269 do not — v1 only ever wrote a hardcoded origin,
## and the v1 -> v2 migration strips it. Callers must then fall back to the
## destination map's default spawn marker (save-system.md § 3.7).
static func has_saved_position(world: Dictionary) -> bool:
	var pos: Variant = world.get("current_position", null)
	if not pos is Dictionary:
		return false
	return (pos as Dictionary).has("x") and (pos as Dictionary).has("y")


## The player position recorded in a save's world block. Check
## has_saved_position() first: with no record this returns the origin, which is
## also a legitimate map coordinate and must never be read as "unknown".
static func saved_position(world: Dictionary) -> Vector2i:
	if not has_saved_position(world):
		return Vector2i.ZERO
	var pos: Dictionary = world.get("current_position", {})
	return Vector2i(int(pos.get("x", 0)), int(pos.get("y", 0)))


## The place name a save slot shows the player. `current_location` is the map
## id used to reload the scene and is never rendered — a save that carries no
## recorded place name reads "Unknown" rather than leaking a file path
## (ui-design.md § 3.5, save-system.md § 3.7).
static func location_display_name(world: Dictionary) -> String:
	var display: String = str(world.get("location_display", ""))
	return display if not display.is_empty() else "Unknown"


## Build the save data template with stub sections for systems not yet implemented.
## `world_state` carries the caller-owned world block (location, position, gold,
## event flags); everything else in `world` is filled in here.
static func build_save_dict(
	party: Array,
	form: Dictionary,
	inv: Dictionary,
	equips: Array,
	world_state: Dictionary,
	play_time: int = 0,
	lc: Dictionary = {},
	ps: Dictionary = {}
) -> Dictionary:
	var world: Dictionary = {
		"event_flags": world_state.get("event_flags", {}),
		"act": world_state.get("act", "1"),
		"current_location": world_state.get("current_location", ""),
		"location_display": world_state.get("location_display", ""),
		"gold": world_state.get("gold", 0),
	}
	# The position is written only once one has actually been recorded (#269).
	# An absent key means "no stored position" and sends the loader to the map's
	# default spawn marker — never to a fabricated origin.
	if world_state.has("current_position"):
		world["current_position"] = world_state["current_position"]
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
			"version": SaveManager.CURRENT_SAVE_VERSION,
			"playtime": play_time,
			"saved_at": Time.get_datetime_string_from_system(),
			"slot_type": "manual",
		},
		"world": world,
		"quests": {"active": [], "completed": []},
		"completion": {"bestiary": [], "treasures": [], "items_found": []},
	}


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
