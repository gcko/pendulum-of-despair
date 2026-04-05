extends GutTest
## Tests for PlayerCharacter entity.
##
## Verifies data loading, stat access, facing direction defaults,
## and pixel snapping behavior.


const PLAYER_SCENE: PackedScene = preload(
	"res://scenes/entities/player_character.tscn"
)


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = PLAYER_SCENE.instantiate()
	add_child_autofree(player)
	return player


func test_initialize_loads_character_data() -> void:
	var player: CharacterBody2D = _create_player()
	player.initialize("edren")
	assert_eq(player.character_id, "edren", "character_id should be set")
	assert_false(
		player.character_data.is_empty(),
		"character_data should be loaded"
	)


func test_initialize_sets_character_id() -> void:
	var player: CharacterBody2D = _create_player()
	player.initialize("maren")
	assert_eq(player.character_id, "maren", "character_id should be maren")


func test_get_stats_returns_base_stats() -> void:
	var player: CharacterBody2D = _create_player()
	player.initialize("edren")
	var stats: Dictionary = player.get_stats()
	assert_has(stats, "hp", "stats should have hp")
	assert_has(stats, "atk", "stats should have atk")
	assert_has(stats, "def", "stats should have def")
	assert_has(stats, "mag", "stats should have mag")
	assert_has(stats, "spd", "stats should have spd")


func test_get_stats_empty_before_init() -> void:
	var player: CharacterBody2D = _create_player()
	var stats: Dictionary = player.get_stats()
	assert_true(stats.is_empty(), "stats should be empty before init")


func test_default_facing_direction() -> void:
	var player: CharacterBody2D = _create_player()
	assert_eq(
		player.facing_direction, Vector2.DOWN,
		"Default facing should be DOWN"
	)


func test_pixel_snapping() -> void:
	var player: CharacterBody2D = _create_player()
	player.position = Vector2(10.5, 20.7)
	# Simulate one physics frame
	player._physics_process(0.016)
	assert_eq(
		player.position, Vector2(11, 21),
		"Position should snap to nearest integer"
	)


func test_get_facing_direction_returns_vector() -> void:
	var player: CharacterBody2D = _create_player()
	var dir: Vector2 = player.get_facing_direction()
	assert_eq(dir, Vector2.DOWN, "Should return facing direction")
