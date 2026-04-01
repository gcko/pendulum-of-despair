extends Node
## Save/load system, auto-save, migration, and Faint-and-Fast-Reload.
## Autoloaded as SaveManager.
##
## Save files are JSON in user://saves/. Global config is separate.
## See docs/plans/technical-architecture.md Section 6.

## Increment this when the save schema changes. Migration chain runs
## automatically on load for older versions.
const CURRENT_SAVE_VERSION: int = 1

## File paths.
const SAVE_DIR: String = "user://saves/"
const CONFIG_PATH: String = "user://config.json"

## Migration functions: version N -> version N+1.
## Add entries as the schema evolves.
var _migration_steps: Dictionary = {
	# Example: when bumping to version 2, add: 1: _migrate_v1_to_v2
}


func _ready() -> void:
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


## Save game state to a slot (1-3 for manual, 0 for auto-save).
func save_game(slot: int) -> bool:
	if slot < 0 or slot > 3:
		push_error("SaveManager: Invalid slot %d (valid: 0-3)" % slot)
		return false
	var data: Dictionary = _build_save_data()
	data["meta"] = {
		"version": CURRENT_SAVE_VERSION,
		"playtime": _get_playtime(),
		"saved_at": Time.get_datetime_string_from_system(),
		"slot_type": "auto" if slot == 0 else "manual",
	}

	var path: String = _slot_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Failed to open %s for writing" % path)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


## Load game state from a slot. Returns the parsed save Dictionary on
## success. On failure, returns either an empty Dictionary (slot doesn't
## exist) or a Dictionary with an "error" key ("cannot_open", "corrupted",
## "invalid", "invalid_slot"). Check with data.is_empty() or data.has("error").
func load_game(slot: int) -> Dictionary:
	if slot < 0 or slot > 3:
		push_error("SaveManager: Invalid slot %d (valid: 0-3)" % slot)
		return {"error": "invalid_slot"}
	var path: String = _slot_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {"error": "cannot_open"}

	var json: JSON = JSON.new()
	var result: Error = json.parse(file.get_as_text())
	file.close()

	if result != OK:
		push_error("SaveManager: Corrupted save at %s" % path)
		return {"error": "corrupted"}

	if not json.data is Dictionary:
		push_error("SaveManager: Save data is not a Dictionary at %s" % path)
		return {"error": "invalid"}
	var data: Dictionary = json.data
	data = _migrate(data)
	if data.has("error"):
		return data

	if not _validate(data):
		push_error("SaveManager: Invalid save data at %s" % path)
		return {"error": "invalid"}

	return data


## Silent auto-save to the dedicated auto-save slot.
## Triggers: dungeon floor entry, boss zone, town entry, quest complete.
func auto_save() -> void:
	if not save_game(0):
		push_warning("SaveManager: Auto-save failed")


## Faint-and-Fast-Reload: party wipe recovery.
## Preserves XP, gold, and boss_cutscene_seen flags across death.
## Levels are derived from accumulated XP. HP/MP set to 100%.
## Merged state is written back to save file for durability.
func faint_and_fast_reload() -> void:
	# 1. Capture death-persistent values from current game state
	var preserved_xp: Dictionary = _capture_party_xp()
	var preserved_gold: int = _capture_gold()
	var preserved_flags: Dictionary = _capture_boss_cutscene_flags()

	# 2. Load most recent save (manual or auto, whichever is newer)
	# TODO: Steps 1-2 from save-system.md Section 7: Faint animation (2s)
	# + fade to black (2s) should be handled by the battle scene before
	# calling this method. Total animation: ~4s.
	var result: Dictionary = _load_most_recent_save()
	if result.is_empty():
		push_error("SaveManager: No save found for Faint-and-Fast-Reload")
		# TODO: Fallback for pre-first-save (Ember Vein): reload dungeon entrance
		return

	var slot: int = result["slot"]
	var data: Dictionary = result["data"]

	# 3. Merge death-persistent values
	_merge_xp(data, preserved_xp)
	if data.get("world") is Dictionary:
		data["world"]["gold"] = preserved_gold
	else:
		push_error("SaveManager: FFR save data missing valid 'world' Dictionary")
		return
	_merge_flags(data, preserved_flags)

	# 4. Process level-ups from accumulated XP
	_process_level_ups(data)

	# 5. Set HP/MP to 100% of max, clear ailments
	_full_restore(data)

	# 6. Write merged state back to the SAME save slot for durability
	_write_data_to_slot(slot, data)

	# 7. Apply and transition
	_apply_save_data(data)
	GameManager.change_core_state(GameManager.CoreState.EXPLORATION)


## Write a pre-built data dictionary directly to a slot file.
func _write_data_to_slot(slot: int, data: Dictionary) -> bool:
	var path: String = _slot_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Failed to write to %s" % path)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


## Run migration chain from save version to current version.
func _migrate(data: Dictionary) -> Dictionary:
	if not data.has("meta") or not data["meta"] is Dictionary:
		data["meta"] = {"version": 0}
	var version: int = data["meta"].get("version", 0)
	while version < CURRENT_SAVE_VERSION:
		if not _migration_steps.has(version):
			push_error("SaveManager: Missing migration step for version %d" % version)
			data["error"] = "missing_migration"
			return data
		var migrated: Variant = _migration_steps[version].call(data)
		if not migrated is Dictionary:
			push_error("SaveManager: Migration step %d returned non-Dictionary" % version)
			data["error"] = "migration_failed"
			return data
		data = migrated
		version += 1
	data["meta"]["version"] = CURRENT_SAVE_VERSION
	return data


## Validate that all required top-level keys exist and critical keys
## have correct types (meta and world must be Dictionaries since
## FFR and load logic index into them).
func _validate(data: Dictionary) -> bool:
	var required: Array[String] = [
		"meta", "party", "formation", "inventory",
		"crafting", "ley_crystals", "world", "quests", "completion"
	]
	for key: String in required:
		if not data.has(key):
			return false
	# Type-check keys that downstream code indexes into
	if not data["meta"] is Dictionary:
		return false
	if not data["world"] is Dictionary:
		return false
	return true


## Map slot number to file path.
func _slot_path(slot: int) -> String:
	if slot == 0:
		return SAVE_DIR + "auto.json"
	return SAVE_DIR + "slot_%d.json" % slot


## Load the most recent save file (manual or auto, by timestamp).
## Returns {slot: int, data: Dictionary} or empty dict on failure.
func _load_most_recent_save() -> Dictionary:
	var most_recent_data: Dictionary = {}
	var most_recent_slot: int = -1
	var most_recent_time: String = ""

	for slot: int in [0, 1, 2, 3]:
		var data: Dictionary = load_game(slot)
		if data.is_empty() or data.has("error"):
			continue
		var meta: Variant = data.get("meta", {})
		var saved_at: String = meta.get("saved_at", "") if meta is Dictionary else ""
		if saved_at > most_recent_time:
			most_recent_time = saved_at
			most_recent_data = data
			most_recent_slot = slot
	if most_recent_slot < 0:
		return {}
	return {"slot": most_recent_slot, "data": most_recent_data}


# --- Placeholder methods (implement when game systems exist) ---

func _build_save_data() -> Dictionary:
	# TODO: Gather state from GameManager, EventFlags, party, inventory
	push_warning("SaveManager: _build_save_data() returning stub data")
	return {
		"party": [],
		"formation": {"active": [], "reserve": [], "guests": []},
		"inventory": {"consumables": [], "equipment": [], "materials": [], "key_items": []},
		"crafting": {"arcanite_charges": 12, "device_loadout": [null, null, null, null, null], "discovered_synergies": [], "unlocked_recipes": []},
		"ley_crystals": {"collected": []},
		"world": {"event_flags": {}, "act": "1", "current_location": "", "current_position": {"x": 0, "y": 0}, "gold": 0},
		"quests": {"active": [], "completed": []},
		"completion": {"bestiary": [], "treasures": [], "items_found": []},
	}

func _get_playtime() -> int:
	# TODO: Track cumulative play time
	return 0

func _capture_party_xp() -> Dictionary:
	# TODO: Read XP per character from party state
	return {}

func _capture_gold() -> int:
	# TODO: Read gold from world state
	return 0

func _capture_boss_cutscene_flags() -> Dictionary:
	# TODO: Filter EventFlags for boss_cutscene_seen_* keys
	return {}

func _merge_xp(_data: Dictionary, _preserved_xp: Dictionary) -> void:
	pass  # TODO: Overwrite party XP in save data with preserved values

func _merge_flags(_data: Dictionary, _preserved_flags: Dictionary) -> void:
	pass  # TODO: Merge boss_cutscene_seen flags into save data

func _process_level_ups(_data: Dictionary) -> void:
	pass  # TODO: Check XP thresholds, increment levels, update stats

func _full_restore(_data: Dictionary) -> void:
	pass  # TODO: Set HP/MP to 100% max, clear all status ailments

func _apply_save_data(_data: Dictionary) -> void:
	pass  # TODO: Restore game state from loaded save data
