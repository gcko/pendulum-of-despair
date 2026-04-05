extends GutTest
## Smoke tests for JSON data file existence.
##
## Verifies that all Tier 1 data files exist on disk.
## Does NOT validate JSON parsing or individual values — those
## are checked by the adversarial verification pass during gap
## implementation.
##
## Uses FileAccess.file_exists() because JSON files are loaded
## via FileAccess/JSON (DataManager.load_json), not ResourceLoader.


func test_character_files_exist() -> void:
	var characters: Array[String] = ["edren", "cael", "maren", "sable", "lira", "torren"]
	for char_id: String in characters:
		var path: String = "res://data/characters/%s.json" % char_id
		assert_true(FileAccess.file_exists(path), "Character file should exist: %s" % path)


func test_enemy_files_exist() -> void:
	var acts: Array[String] = ["act_i", "act_ii", "interlude", "act_iii", "optional", "bosses"]
	for act: String in acts:
		var path: String = "res://data/enemies/%s.json" % act
		assert_true(FileAccess.file_exists(path), "Enemy file should exist: %s" % path)


func test_config_defaults_exist() -> void:
	var path: String = "res://data/config/defaults.json"
	assert_true(FileAccess.file_exists(path), "Config defaults should exist")


func test_crafting_files_exist() -> void:
	var files: Array[String] = ["devices", "recipes", "synergies"]
	for fname: String in files:
		var path: String = "res://data/crafting/%s.json" % fname
		assert_true(FileAccess.file_exists(path), "Crafting file should exist: %s" % path)


func test_item_files_exist() -> void:
	var files: Array[String] = ["consumables", "materials", "key_items"]
	for fname: String in files:
		var path: String = "res://data/items/%s.json" % fname
		assert_true(FileAccess.file_exists(path), "Item file should exist: %s" % path)


func test_equipment_files_exist() -> void:
	var files: Array[String] = ["weapons", "armor", "accessories"]
	for fname: String in files:
		var path: String = "res://data/equipment/%s.json" % fname
		assert_true(FileAccess.file_exists(path), "Equipment file should exist: %s" % path)
