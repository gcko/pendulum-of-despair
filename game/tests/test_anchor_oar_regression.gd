extends GutTest


func before_each() -> void:
	DataManager.clear_cache()
	EventFlags.clear_all()


func after_each() -> void:
	DataManager.clear_cache()
	EventFlags.clear_all()


func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func test_renn_still_present() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("renn"), "Renn should still be in tavern")


func test_front_door_preserved() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("valdris_lower_ward"), "Front door to LW should exist")


func test_save_point_preserved() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("valdris_anchor_oar_save"), "Save point should exist")


func test_staircase_added() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("valdris_anchor_oar_upper"), "Staircase to upper should exist")
	assert_true(text.contains("from_upstairs"), "from_upstairs spawn should exist")


func test_upper_floor_returns() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar_upper.tscn")
	assert_true(text.contains("valdris_anchor_oar"), "Upper should return to tavern")
	assert_true(text.contains("from_downstairs"), "from_downstairs spawn should exist")
