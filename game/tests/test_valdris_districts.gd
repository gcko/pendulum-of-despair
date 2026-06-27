extends GutTest

const DISTRICT_MAPS: Array[String] = [
	"towns/valdris_citizens_walk",
	"towns/valdris_court_quarter",
	"towns/valdris_throne_hall",
	"towns/valdris_royal_library",
	"towns/valdris_barracks",
	"towns/valdris_anchor_oar_upper",
]

const ALL_VALDRIS_MAPS: Array[String] = [
	"towns/valdris_lower_ward",
	"towns/valdris_anchor_oar",
	"towns/valdris_citizens_walk",
	"towns/valdris_court_quarter",
	"towns/valdris_throne_hall",
	"towns/valdris_royal_library",
	"towns/valdris_barracks",
	"towns/valdris_anchor_oar_upper",
]


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


func _load_map_scene(map_id: String) -> Node2D:
	var path: String = "res://scenes/maps/%s.tscn" % map_id
	assert_true(ResourceLoader.exists(path), "Scene '%s' should exist" % path)
	var scene: PackedScene = load(path) as PackedScene
	assert_not_null(scene, "Scene '%s' should load" % path)
	var node: Node2D = scene.instantiate() as Node2D
	add_child_autofree(node)
	return node


# --- Scene structure ---


func test_all_new_maps_load() -> void:
	for map_id: String in DISTRICT_MAPS:
		var path: String = "res://scenes/maps/%s.tscn" % map_id
		assert_true(ResourceLoader.exists(path), "Map '%s' should exist" % map_id)


func test_all_maps_have_required_metadata() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		assert_true(node.has_meta("map_id"), "'%s' missing map_id metadata" % map_id)
		assert_true(node.has_meta("location_name"), "'%s' missing location_name metadata" % map_id)
		assert_eq(node.get_meta("map_id"), map_id, "'%s' map_id mismatch" % map_id)


func test_all_maps_have_entities_node() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var entities: Node = node.get_node_or_null("Entities")
		assert_not_null(entities, "'%s' missing Entities node" % map_id)


func test_all_maps_have_player_spawn() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var spawn: Marker2D = node.get_node_or_null("PlayerSpawn") as Marker2D
		assert_not_null(spawn, "'%s' missing PlayerSpawn" % map_id)


# --- NPC metadata ---


func test_all_npcs_have_valid_dialogue() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var entities: Node = node.get_node_or_null("Entities")
		if entities == null:
			continue
		for child: Node in entities.get_children():
			if not child.has_meta("npc_id"):
				continue
			var npc_id: String = child.get_meta("npc_id")
			var data: Dictionary = DataManager.load_dialogue("npc_%s" % npc_id)
			assert_ne(data, {}, "NPC '%s' in '%s' has no dialogue file" % [npc_id, map_id])


func test_shop_npcs_have_valid_shop_data() -> void:
	for map_id: String in DISTRICT_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var entities: Node = node.get_node_or_null("Entities")
		if entities == null:
			continue
		for child: Node in entities.get_children():
			if not child.has_meta("shop_id"):
				continue
			var shop_id: String = child.get_meta("shop_id")
			var data: Dictionary = DataManager.load_shop(shop_id)
			assert_ne(data, {}, "Shop '%s' in '%s' has no data file" % [shop_id, map_id])


# --- Transitions ---


func test_transition_targets_exist() -> void:
	for map_id: String in ALL_VALDRIS_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var transitions: Node = node.get_node_or_null("Transitions")
		if transitions == null:
			continue
		for child: Node in transitions.get_children():
			if not child.has_meta("target_map"):
				continue
			var target: String = child.get_meta("target_map")
			var path: String = "res://scenes/maps/%s.tscn" % target
			assert_true(
				ResourceLoader.exists(path),
				"Transition in '%s' points to missing '%s'" % [map_id, target]
			)


func test_transition_spawns_exist() -> void:
	for map_id: String in ALL_VALDRIS_MAPS:
		var node: Node2D = _load_map_scene(map_id)
		var transitions: Node = node.get_node_or_null("Transitions")
		if transitions == null:
			continue
		for child: Node in transitions.get_children():
			if not child.has_meta("target_map"):
				continue
			var target_map: String = child.get_meta("target_map")
			var target_spawn: String = child.get_meta("target_spawn", "PlayerSpawn")
			var target_node: Node2D = _load_map_scene(target_map)
			var spawn: Marker2D = target_node.get_node_or_null(target_spawn) as Marker2D
			assert_not_null(
				spawn,
				(
					"'%s' transition to '%s' references missing spawn '%s'"
					% [map_id, target_map, target_spawn]
				)
			)


# --- Specific content ---


func test_throne_hall_has_scene_7b_trigger() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_throne_hall")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("dialogue_scene_id"):
			if child.get_meta("dialogue_scene_id") == "scene_7b_throne_hall":
				found = true
				break
	assert_true(found, "Throne hall should have Scene 7b dialogue trigger")


func test_throne_hall_has_scene_7d_cutscene_trigger() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_throne_hall")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("cutscene_scene_id"):
			if child.get_meta("cutscene_scene_id") == "scene_7d_evening":
				found = true
				assert_true(
					child.has_meta("required_flags"),
					"Scene 7d trigger must use required_flags (plural)"
				)
				break
	assert_true(found, "Throne hall should have Scene 7d cutscene trigger")


func test_library_has_save_point() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_royal_library")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("save_point_id"):
			found = true
			break
	assert_true(found, "Library should have a save point")


func test_citizens_walk_has_three_shops() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_citizens_walk")
	var entities: Node = node.get_node_or_null("Entities")
	var shop_count: int = 0
	for child: Node in entities.get_children():
		if child.has_meta("shop_id"):
			shop_count += 1
	assert_eq(shop_count, 3, "Citizen's Walk should have 3 shops")


func test_lower_ward_has_scene_7a_trigger() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_lower_ward")
	var entities: Node = node.get_node_or_null("Entities")
	var found: bool = false
	for child: Node in entities.get_children():
		if child.has_meta("dialogue_scene_id"):
			if child.get_meta("dialogue_scene_id") == "scene_7a_the_gates":
				found = true
				assert_eq(
					child.get_meta("required_flag", ""),
					"maren_warning",
					"Scene 7a trigger must require maren_warning flag"
				)
				break
	assert_true(found, "Lower Ward should have Scene 7a dialogue trigger")


func test_lower_ward_weaponsmith_renamed() -> void:
	var node: Node2D = _load_map_scene("towns/valdris_lower_ward")
	var entities: Node = node.get_node_or_null("Entities")
	for child: Node in entities.get_children():
		if child.has_meta("shop_id"):
			var sid: String = child.get_meta("shop_id")
			assert_ne(sid, "valdris_crown_armorer", "Old armorer shop_id should be renamed")
