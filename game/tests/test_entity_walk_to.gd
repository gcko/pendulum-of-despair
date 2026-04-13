extends GutTest
## Tests for walk_to() method on player_character and npc.

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")


func _create_player() -> Node2D:
	var player = PLAYER_SCENE.instantiate()
	add_child_autofree(player)
	player.position = Vector2(0, 0)
	return player


func _create_npc() -> Node2D:
	var npc_node = NPC_SCENE.instantiate()
	add_child_autofree(npc_node)
	npc_node.position = Vector2(0, 0)
	return npc_node


func test_player_walk_to_emits_walk_complete() -> void:
	var player := _create_player()
	watch_signals(player)
	player.walk_to(Vector2(16, 0), 800.0)
	await get_tree().create_timer(0.2).timeout
	assert_signal_emitted(player, "walk_complete")


func test_player_walk_to_moves_position() -> void:
	var player := _create_player()
	player.walk_to(Vector2(80, 0), 800.0)
	await get_tree().create_timer(0.3).timeout
	assert_almost_eq(player.position.x, 80.0, 2.0, "player should reach target x")


func test_player_walk_to_zero_distance() -> void:
	var player := _create_player()
	watch_signals(player)
	player.walk_to(Vector2(0, 0), 80.0)
	await get_tree().create_timer(0.1).timeout
	assert_signal_emitted(player, "walk_complete")


func test_npc_walk_to_emits_walk_complete() -> void:
	var npc_node := _create_npc()
	watch_signals(npc_node)
	npc_node.walk_to(Vector2(16, 0), 800.0)
	await get_tree().create_timer(0.2).timeout
	assert_signal_emitted(npc_node, "walk_complete")


func test_npc_walk_to_moves_position() -> void:
	var npc_node := _create_npc()
	npc_node.walk_to(Vector2(80, 0), 800.0)
	await get_tree().create_timer(0.3).timeout
	assert_almost_eq(npc_node.position.x, 80.0, 2.0, "npc should reach target x")


func test_npc_play_animation_exists() -> void:
	var npc_node := _create_npc()
	assert_true(npc_node.has_method("play_animation"), "npc should have play_animation method")
