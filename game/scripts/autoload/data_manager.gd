extends Node
## JSON game data loader and cache.
## Autoloaded as DataManager.
##
## Loads JSON files from res://data/ and caches them in memory.
## Game data is build-time content (not user-editable), so malformed
## JSON triggers a fatal error with file path in the console.
## See docs/plans/technical-architecture.md Section 2.

## Cache of loaded JSON data. Keys are file paths, values are parsed dicts/arrays.
var _cache: Dictionary = {}


## Load a JSON file and return its parsed content.
## Caches the result — subsequent calls return the cached version.
## Fatal error if the file is malformed (game data corruption = broken build).
func load_json(path: String) -> Variant:
	if _cache.has(path):
		return _cache[path]

	if not FileAccess.file_exists(path):
		_fatal("File not found: %s" % path)
		return null

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		_fatal("Cannot open: %s" % path)
		return null

	var json: JSON = JSON.new()
	var result: Error = json.parse(file.get_as_text())
	file.close()

	if result != OK:
		_fatal(
			(
				"Malformed JSON at %s line %d: %s"
				% [path, json.get_error_line(), json.get_error_message()]
			)
		)
		return null

	_cache[path] = json.data
	return json.data


## Fatal error handler. Logs to user://crash.log, prints stack trace,
## then exits. The crash log persists after the game closes so errors
## are never silently lost.
func _fatal(msg: String) -> void:
	var full: String = "FATAL DataManager: %s" % msg
	push_error(full)
	print(full)
	var trace: String = ""
	for frame: Dictionary in get_stack():
		trace += (
			"  %s:%d in %s\n"
			% [frame.get("source", "?"), frame.get("line", 0), frame.get("function", "?")]
		)
	print(trace)
	var log_path: String = "user://crash.log"
	var log_file: FileAccess = FileAccess.open(log_path, FileAccess.WRITE)
	if log_file != null:
		log_file.store_string("%s\n%s" % [full, trace])
		log_file.close()
		print("Crash log written to: %s" % ProjectSettings.globalize_path(log_path))
	get_tree().quit(1)


## Load enemy data for an act. Returns the "enemies" array, or empty if missing.
func load_enemies(act: String) -> Array:
	var path: String = "res://data/enemies/%s.json" % act
	if not FileAccess.file_exists(path):
		push_warning("DataManager: Enemy file not found: %s" % path)
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("enemies"):
		return data["enemies"]
	return []


## Load item data by category. Returns the items array, or empty if file missing.
func load_items(category: String) -> Array:
	var path: String = "res://data/items/%s.json" % category
	if not FileAccess.file_exists(path):
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("items"):
		return data["items"]
	return []


## Load equipment data by type. Returns the array, or empty if file missing.
func load_equipment(equipment_type: String) -> Array:
	var path: String = "res://data/equipment/%s.json" % equipment_type
	if not FileAccess.file_exists(path):
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has(equipment_type):
		return data[equipment_type]
	return []


## Load character data by ID. Returns empty dict if file missing.
func load_character(character_id: String) -> Dictionary:
	var path: String = "res://data/characters/%s.json" % character_id
	if not FileAccess.file_exists(path):
		push_warning("DataManager: Character file not found: %s" % path)
		return {}
	var data: Variant = load_json(path)
	if data is Dictionary:
		return data
	return {}


## Load shop inventory by shop_id. Returns empty dict if file missing.
func load_shop(shop_id: String) -> Dictionary:
	var path: String = "res://data/shops/%s.json" % shop_id
	if not FileAccess.file_exists(path):
		push_warning("DataManager: Shop file not found: %s" % path)
		return {}
	var data: Variant = load_json(path)
	if data is Dictionary:
		return data
	return {}


## Load encounter data for a dungeon. Returns empty dict if no encounter file exists.
func load_encounters(dungeon: String) -> Dictionary:
	var path: String = "res://data/encounters/%s.json" % dungeon
	if not FileAccess.file_exists(path):
		return {}
	var data: Variant = load_json(path)
	if data is Dictionary:
		return data
	return {}


## Load ability data for a character. Returns the abilities array, or empty if missing.
func load_abilities(character_id: String) -> Array:
	var path: String = "res://data/abilities/%s.json" % character_id
	if not FileAccess.file_exists(path):
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("abilities"):
		return data["abilities"]
	return []


## Load spell data for a tradition. Returns empty array if file missing.
func load_spells(tradition: String) -> Array:
	var path: String = "res://data/spells/%s.json" % tradition
	if not FileAccess.file_exists(path):
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("spells"):
		return data["spells"]
	return []


## Load dialogue data for a scene. Returns empty dict if file missing.
func load_dialogue(scene_id: String) -> Dictionary:
	var path: String = "res://data/dialogue/%s.json" % scene_id
	if not FileAccess.file_exists(path):
		push_warning("DataManager: Dialogue file not found: %s" % path)
		return {}
	var data: Variant = load_json(path)
	if data is Dictionary:
		return data
	return {}


## Load all Ley Crystal static data. Returns the "crystals" array.
func load_ley_crystals() -> Array:
	var path: String = "res://data/ley_crystals.json"
	if not FileAccess.file_exists(path):
		push_warning("DataManager: Ley crystal file not found: %s" % path)
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("crystals"):
		return data["crystals"]
	return []


## Get a single Ley Crystal's static data by ID. Returns empty dict if not found.
func get_ley_crystal(crystal_id: String) -> Dictionary:
	var crystals: Array = load_ley_crystals()
	for entry: Variant in crystals:
		if entry is Dictionary and (entry as Dictionary).get("id", "") == crystal_id:
			return entry as Dictionary
	return {}


## Load crafting data (devices or recipes). Returns empty dict if missing.
func load_crafting(crafting_type: String) -> Variant:
	var path: String = "res://data/crafting/%s.json" % crafting_type
	if not FileAccess.file_exists(path):
		return {}
	return load_json(path)


## Clear the cache (useful for testing or hot-reload).
func clear_cache() -> void:
	_cache.clear()
