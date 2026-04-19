extends GutTest


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func test_existing_npcs_still_present() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	for npc_id: String in ["bren", "wynn", "thessa", "sergeant_marek", "nella"]:
		assert_true(text.contains(npc_id), "NPC '%s' should still be in LW" % npc_id)


func test_weaponsmith_shop_renamed() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("valdris_crown_weaponsmith"), "Should have new weaponsmith ID")
	assert_false(text.contains("valdris_crown_armorer"), "Old armorer ID should be gone")


func test_weaponsmith_shop_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	assert_ne(data, {}, "Weaponsmith shop should load")


func test_general_store_still_loads() -> void:
	var data: Dictionary = DataManager.load_shop("valdris_crown_general")
	assert_ne(data, {}, "General store should still load")


func test_existing_transitions_preserved() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("overworld"), "South Gate to overworld should exist")
	assert_true(text.contains("valdris_anchor_oar"), "Tavern door should exist")


func test_chapel_save_point() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("valdris_chapel_save"), "Chapel save point should exist")


func test_existing_npc_dialogues_load() -> void:
	for npc_id: String in ["bren", "wynn", "nella", "sergeant_marek", "thessa"]:
		var data: Dictionary = DataManager.load_dialogue("npc_%s" % npc_id)
		assert_ne(data, {}, "Dialogue for '%s' should load" % npc_id)
