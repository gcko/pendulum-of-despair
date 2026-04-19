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


# --- Missing file graceful fallback tests ---


func test_load_shop_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Dictionary = DataManager.load_shop("nonexistent_shop_id")
	assert_true(result.is_empty(), "Missing shop should return empty dict")


func test_load_encounters_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Dictionary = DataManager.load_encounters("nonexistent_dungeon")
	assert_true(result.is_empty(), "Missing encounters should return empty dict")


func test_load_dialogue_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Dictionary = DataManager.load_dialogue("nonexistent_dialogue")
	assert_true(result.is_empty(), "Missing dialogue should return empty dict")


func test_load_items_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Array = DataManager.load_items("nonexistent_category")
	assert_true(result.is_empty(), "Missing items should return empty array")


func test_load_equipment_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Array = DataManager.load_equipment("nonexistent_type")
	assert_true(result.is_empty(), "Missing equipment should return empty array")


func test_load_enemies_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Array = DataManager.load_enemies("nonexistent_act")
	assert_true(result.is_empty(), "Missing enemies should return empty array")


func test_load_spells_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Array = DataManager.load_spells("nonexistent_tradition")
	assert_true(result.is_empty(), "Missing spells should return empty array")


func test_load_character_missing_file_returns_empty() -> void:
	DataManager.clear_cache()
	var result: Dictionary = DataManager.load_character("nonexistent_char")
	assert_true(result.is_empty(), "Missing character should return empty dict")


# --- Valid JSON structure tests ---


func test_all_shop_files_valid_json() -> void:
	DataManager.clear_cache()
	var shop_ids: Array[String] = [
		"aelhart_general",
		"ashmark_armorer",
		"ashmark_general",
		"bellhaven_armorer",
		"bellhaven_general",
		"bellhaven_specialty",
		"caldera_black_market",
		"caldera_company_armorer",
		"caldera_company_store",
		"corrund_armorer",
		"corrund_black_market",
		"corrund_general",
		"highcairn_provisioner",
		"ironmark_quartermaster",
		"ironmark_scavenger",
		"oasis_a",
		"oasis_b",
		"oasis_c",
		"thornmere_craftsman",
		"thornmere_provisioner",
		"valdris_crown_armorsmith",
		"valdris_crown_general",
		"valdris_crown_jeweler",
		"valdris_crown_specialty",
		"valdris_crown_weaponsmith",
	]
	for shop_id: String in shop_ids:
		var data: Dictionary = DataManager.load_shop(shop_id)
		assert_false(data.is_empty(), "Shop %s should return non-empty dict" % shop_id)
		assert_true(data.has("shop"), "Shop %s should have 'shop' key" % shop_id)


func test_all_dialogue_files_valid_json() -> void:
	DataManager.clear_cache()
	var dir: DirAccess = DirAccess.open("res://data/dialogue/")
	assert_not_null(dir, "Should be able to open dialogue directory")
	if dir == null:
		return
	dir.list_dir_begin()
	var fname: String = dir.get_next()
	var count: int = 0
	while fname != "":
		if fname.ends_with(".json"):
			var scene_id: String = fname.get_basename()
			var data: Dictionary = DataManager.load_dialogue(scene_id)
			assert_false(data.is_empty(), "Dialogue %s should return non-empty dict" % scene_id)
			assert_true(data.has("scene_id"), "Dialogue %s should have 'scene_id' key" % scene_id)
			assert_true(data.has("entries"), "Dialogue %s should have 'entries' key" % scene_id)
			count += 1
		fname = dir.get_next()
	dir.list_dir_end()
	assert_gt(count, 0, "Should have found at least one dialogue file")
