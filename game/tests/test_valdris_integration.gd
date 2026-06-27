extends GutTest


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func test_lower_ward_to_citizens_walk_bidirectional() -> void:
	var lw: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(lw.contains("valdris_citizens_walk"), "LW should transition to CW")
	assert_true(lw.contains("from_citizens_walk"), "LW should have from_citizens_walk spawn")
	var cw: String = _read_file("res://scenes/maps/towns/valdris_citizens_walk.tscn")
	assert_true(cw.contains("valdris_lower_ward"), "CW should transition to LW")
	assert_true(cw.contains("from_lower_ward"), "CW should have from_lower_ward spawn")


func test_citizens_walk_to_court_quarter_bidirectional() -> void:
	var cw: String = _read_file("res://scenes/maps/towns/valdris_citizens_walk.tscn")
	assert_true(cw.contains("valdris_court_quarter"), "CW -> CQ transition")
	var cq: String = _read_file("res://scenes/maps/towns/valdris_court_quarter.tscn")
	assert_true(cq.contains("valdris_citizens_walk"), "CQ -> CW transition")


func test_court_quarter_to_throne_hall_bidirectional() -> void:
	var cq: String = _read_file("res://scenes/maps/towns/valdris_court_quarter.tscn")
	assert_true(cq.contains("valdris_throne_hall"), "CQ -> TH transition")
	var th: String = _read_file("res://scenes/maps/towns/valdris_throne_hall.tscn")
	assert_true(th.contains("valdris_court_quarter"), "TH -> CQ transition")


func test_citizens_walk_to_library_bidirectional() -> void:
	var cw: String = _read_file("res://scenes/maps/towns/valdris_citizens_walk.tscn")
	assert_true(cw.contains("valdris_royal_library"), "CW -> Library")
	var lib: String = _read_file("res://scenes/maps/towns/valdris_royal_library.tscn")
	assert_true(lib.contains("valdris_citizens_walk"), "Library -> CW")


func test_lower_ward_to_barracks_bidirectional() -> void:
	var lw: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(lw.contains("valdris_barracks"), "LW -> Barracks")
	var bk: String = _read_file("res://scenes/maps/towns/valdris_barracks.tscn")
	assert_true(bk.contains("valdris_lower_ward"), "Barracks -> LW")


func test_anchor_oar_to_upper_floor_bidirectional() -> void:
	var ao: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar.tscn")
	assert_true(ao.contains("valdris_anchor_oar_upper"), "AO -> Upper")
	var up: String = _read_file("res://scenes/maps/towns/valdris_anchor_oar_upper.tscn")
	assert_true(up.contains("valdris_anchor_oar"), "Upper -> AO")


func test_location_names_correct() -> void:
	var expected: Dictionary = {
		"towns/valdris_citizens_walk": "Citizen's Walk",
		"towns/valdris_court_quarter": "Court Quarter",
		"towns/valdris_throne_hall": "Throne Hall",
		"towns/valdris_royal_library": "Royal Library",
		"towns/valdris_barracks": "Barracks",
		"towns/valdris_anchor_oar_upper": "Upper Floor",
	}
	for map_id: String in expected:
		var path: String = "res://scenes/maps/%s.tscn" % map_id
		var scene: PackedScene = load(path) as PackedScene
		var node: Node2D = scene.instantiate() as Node2D
		add_child_autofree(node)
		var loc: String = node.get_meta("location_name", "")
		assert_true(
			expected[map_id] in loc,
			"'%s' location_name should contain '%s', got '%s'" % [map_id, expected[map_id], loc]
		)
