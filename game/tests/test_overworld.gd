extends GutTest
## Integration tests for the overworld — scene existence, encounter data,
## transition wiring, round-trip validation, and exploration.gd defaults.


func before_each() -> void:
	DataManager.clear_cache()


func test_overworld_scene_exists() -> void:
	assert_true(FileAccess.file_exists("res://scenes/maps/overworld.tscn"))


func test_overworld_encounter_data_exists() -> void:
	var data: Dictionary = DataManager.load_encounters("overworld")
	assert_false(data.is_empty(), "Overworld encounter data should exist")


func test_highland_zone_has_groups() -> void:
	var data: Dictionary = DataManager.load_encounters("overworld")
	var floors: Array = data.get("floors", data.get("zones", []))
	var found: bool = false
	for entry: Variant in floors:
		if entry is Dictionary and (entry as Dictionary).get("floor_id", "") == "valdris_highlands":
			found = true
			var groups: Array = (entry as Dictionary).get("groups", [])
			assert_gt(groups.size(), 0, "Highland zone should have encounter groups")
			break
	assert_true(found, "Should find valdris_highlands floor entry")


func test_overworld_has_valdris_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("towns/valdris_lower_ward"))


func test_overworld_has_ember_vein_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("dungeons/ember_vein_f1"))


func test_overworld_spawn_markers_exist() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("from_valdris"))
	assert_true(text.contains("from_ember_vein"))


func test_valdris_south_gate_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains('target_map = "overworld"'))
	assert_false(text.contains('target_map = "test_room"'))


func test_ember_vein_exit_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/ember_vein_f1.tscn")
	assert_true(text.contains('target_map = "overworld"'))


func test_overworld_to_valdris_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var vl: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(ow.contains("towns/valdris_lower_ward"))
	assert_true(vl.contains('"overworld"'))
	assert_true(ow.contains("from_valdris"))
	assert_true(vl.contains("from_overworld"))


func test_overworld_to_ember_vein_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var ev: String = _read_file("res://scenes/maps/dungeons/ember_vein_f1.tscn")
	assert_true(ow.contains("dungeons/ember_vein_f1"))
	assert_true(ev.contains('"overworld"'))
	assert_true(ow.contains("from_ember_vein"))
	assert_true(ev.contains("from_overworld"))


func test_exploration_defaults_to_overworld() -> void:
	var text: String = _read_file("res://scripts/core/exploration.gd")
	assert_false(text.contains('load_map("test_room")'))
	assert_true(text.contains('load_map("overworld")'))


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
