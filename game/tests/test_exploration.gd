extends GutTest
## Tests for Exploration Scene.

const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")


func before_each() -> void:
	GameManager.transition_data = {}
	EventFlags.clear_all()


func after_each() -> void:
	GameManager.transition_data = {}
	EventFlags.clear_all()


func _create_exploration():
	GameManager.transition_data = {"new_game": true}
	var exp = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	return exp


# --- Scene Loading ---


func test_exploration_scene_loads() -> void:
	var exp = _create_exploration()
	assert_not_null(exp, "exploration scene should instantiate")


func test_load_map_creates_children() -> void:
	var exp = _create_exploration()
	var map_container = exp.get_node("CurrentMap")
	assert_gt(map_container.get_child_count(), 0, "map should be loaded as child")


func test_player_spawns_at_marker() -> void:
	var exp = _create_exploration()
	assert_not_null(exp._player, "player should be instantiated")
	assert_eq(exp._player.position, Vector2(80, 90), "player should be at spawn point")


func test_camera_follows_player() -> void:
	var exp = _create_exploration()
	exp._player.position = Vector2(100, 50)
	exp._process(0.016)
	var cam = exp.get_node("Camera2D")
	assert_eq(cam.position, Vector2(100, 50), "camera should follow player")


# --- Entity Interaction ---


func test_npc_interaction_signal_wired() -> void:
	var exp = _create_exploration()
	var entities = exp._current_map.get_node_or_null("Entities")
	assert_not_null(entities, "entities node should exist")
	var npc = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC should exist in map")
	assert_true(
		npc.npc_interacted.is_connected(exp._on_npc_interacted), "NPC signal should be connected"
	)


func test_chest_interaction_signal_wired() -> void:
	var exp = _create_exploration()
	var entities = exp._current_map.get_node_or_null("Entities")
	var chest = entities.get_node_or_null("TestChest")
	assert_not_null(chest, "test chest should exist in map")
	assert_true(
		chest.chest_opened.is_connected(exp._on_chest_opened), "chest signal should be connected"
	)


func test_save_point_signal_wired() -> void:
	var exp = _create_exploration()
	var entities = exp._current_map.get_node_or_null("Entities")
	var sp = entities.get_node_or_null("TestSavePoint")
	assert_not_null(sp, "test save point should exist in map")
	assert_true(
		sp.save_point_activated.is_connected(exp._on_save_point_activated),
		"save point signal should be connected",
	)


# --- Map Transitions ---


func test_transition_flag_blocks_interaction() -> void:
	var exp = _create_exploration()
	# Use a real entity that has interact() — e.g., the NPC from the map
	var entities = exp._current_map.get_node_or_null("Entities")
	var npc = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC must exist for this test")
	watch_signals(npc)
	exp._transitioning = true
	exp._on_interaction_requested(npc)
	# NPC.interact() emits npc_interacted — if blocked, signal should NOT emit
	assert_signal_not_emitted(
		npc, "npc_interacted", "interaction should be blocked during transition"
	)


func test_location_flash_sets_text() -> void:
	var exp = _create_exploration()
	exp.flash_location_name("Test Location")
	assert_eq(exp._location_label.text, "Test Location", "should set location text")
	assert_true(exp._location_panel.visible, "location panel should be visible")


func test_map_changed_signal() -> void:
	var exp = _create_exploration()
	watch_signals(exp)
	exp.load_map("test_room_2")
	assert_signal_emitted(exp, "map_changed", "should emit map_changed")
