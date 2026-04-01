class_name DataManagerClass
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
		push_error("DataManager: File not found: %s" % path)
		get_tree().quit(1)
		return null

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DataManager: Cannot open: %s" % path)
		get_tree().quit(1)
		return null

	var json: JSON = JSON.new()
	var result: Error = json.parse(file.get_as_text())
	file.close()

	if result != OK:
		push_error("DataManager: Malformed JSON at %s line %d: %s" % [
			path, json.get_error_line(), json.get_error_message()
		])
		get_tree().quit(1)
		return null

	_cache[path] = json.data
	return json.data


## Load enemy data for an act. Returns the "enemies" array.
func load_enemies(act: String) -> Array:
	var data: Variant = load_json("res://data/enemies/%s.json" % act)
	if data is Dictionary and data.has("enemies"):
		return data["enemies"]
	return []


## Load item data by category. Returns the items array.
func load_items(category: String) -> Array:
	var data: Variant = load_json("res://data/items/%s.json" % category)
	if data is Dictionary and data.has("items"):
		return data["items"]
	return []


## Load equipment data by type (weapons, armor, accessories).
func load_equipment(equipment_type: String) -> Array:
	var data: Variant = load_json("res://data/equipment/%s.json" % equipment_type)
	if data is Dictionary and data.has(equipment_type):
		return data[equipment_type]
	return []


## Load character data by ID.
func load_character(character_id: String) -> Dictionary:
	var data: Variant = load_json("res://data/characters/%s.json" % character_id)
	if data is Dictionary:
		return data
	return {}


## Load shop inventory for a town.
func load_shop(town: String) -> Dictionary:
	var data: Variant = load_json("res://data/shops/%s.json" % town)
	if data is Dictionary:
		return data
	return {}


## Load encounter data for a dungeon.
func load_encounters(dungeon: String) -> Dictionary:
	var data: Variant = load_json("res://data/encounters/%s.json" % dungeon)
	if data is Dictionary:
		return data
	return {}


## Load spell data for a tradition.
func load_spells(tradition: String) -> Array:
	var data: Variant = load_json("res://data/spells/%s.json" % tradition)
	if data is Dictionary and data.has("spells"):
		return data["spells"]
	return []


## Load dialogue data for a scene.
func load_dialogue(scene_id: String) -> Dictionary:
	var data: Variant = load_json("res://data/dialogue/%s.json" % scene_id)
	if data is Dictionary:
		return data
	return {}


## Load crafting data (devices or recipes).
func load_crafting(crafting_type: String) -> Variant:
	var data: Variant = load_json("res://data/crafting/%s.json" % crafting_type)
	return data if data else {}


## Clear the cache (useful for testing or hot-reload).
func clear_cache() -> void:
	_cache.clear()
