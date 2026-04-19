extends GutTest


func before_each() -> void:
	EventFlags.clear_all()
	DataManager.clear_cache()


func after_each() -> void:
	EventFlags.clear_all()
	DataManager.clear_cache()


func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func test_scene_7a_trigger_in_lower_ward() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains("scene_7a_the_gates"), "LW should have 7a trigger")
	assert_true(text.contains("maren_warning"), "7a should require maren_warning")


func test_scene_7b_trigger_in_throne_hall() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_throne_hall.tscn")
	assert_true(text.contains("scene_7b_throne_hall"), "TH should have 7b trigger")
	assert_true(text.contains("valdris_arrived"), "7b should require valdris_arrived")


func test_scene_7c_aldis_trigger_in_library() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_royal_library.tscn")
	assert_true(text.contains("scene_7c_aldis"), "Library should have 7c Aldis trigger")
	assert_true(text.contains("pendulum_presented"), "7c Aldis should require pendulum_presented")


func test_scene_7c_cordwyn_trigger_in_barracks() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_barracks.tscn")
	assert_true(text.contains("scene_7c_cordwyn"), "Barracks should have 7c Cordwyn trigger")


func test_scene_7c_renn_trigger_in_tavern() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(text.contains("scene_7c_renn"), "Tavern should have 7c Renn trigger")


func test_scene_7d_trigger_in_throne_hall() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_throne_hall.tscn")
	assert_true(text.contains("scene_7d_evening"), "TH should have 7d cutscene trigger")
	assert_true(text.contains("required_flags"), "7d should use required_flags (plural)")
	assert_true(text.contains("scene_7c_aldis"), "7d flags should include aldis")
	assert_true(text.contains("scene_7c_cordwyn"), "7d flags should include cordwyn")
	assert_true(text.contains("scene_7c_renn"), "7d flags should include renn")


func test_scene_7a_dialogue_valid() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7a_the_gates")
	assert_gt(data.get("entries", []).size(), 0, "7a should have entries")


func test_scene_7b_dialogue_valid() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_7b_throne_hall")
	assert_gt(data.get("entries", []).size(), 0, "7b should have entries")


func test_full_scene_7_flag_flow() -> void:
	EventFlags.set_flag("maren_warning", true)
	EventFlags.set_flag("valdris_arrived", true)
	EventFlags.set_flag("pendulum_presented", true)
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("scene_7c_renn", true)
	var can_fire_7d: bool = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
		and EventFlags.get_flag("pendulum_presented")
	)
	assert_true(can_fire_7d, "7d should be fireable with all flags")
	EventFlags.set_flag("pendulum_to_capital", true)
	assert_true(EventFlags.get_flag("pendulum_to_capital"), "Act I complete")
