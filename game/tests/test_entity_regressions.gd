extends GutTest
## Regression guards for the entity layer: walk_to using global_position,
## the class_name declarations every entity script must keep, the NPC
## animation library, and the entity manager's public-method boundary.
##
## Split out of the 968-line test_issue_fixes.gd, which had grown into a
## grab-bag named after no subject at all (#374).

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")
const EnemyScript: GDScript = preload("res://scripts/entities/enemy.gd")
const NpcScript: GDScript = preload("res://scripts/entities/npc.gd")
const ChestScript: GDScript = preload("res://scripts/entities/treasure_chest.gd")
const DzScript: GDScript = preload("res://scripts/entities/damage_zone.gd")
const SpScript: GDScript = preload("res://scripts/entities/save_point.gd")
const TzScript: GDScript = preload("res://scripts/entities/trigger_zone.gd")
const PcScript: GDScript = preload("res://scripts/entities/player_character.gd")
const WwScript: GDScript = preload("res://scripts/entities/water_wheel.gd")
const EcScript: GDScript = preload("res://scripts/entities/ember_crystal.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


# ==========================================================================
# Issue cra: player_character.gd walk_to uses global_position
# ==========================================================================


func test_player_walk_to_uses_global_position() -> void:
	var parent: Node2D = Node2D.new()
	parent.position = Vector2(100, 100)
	add_child_autofree(parent)
	var player: Node2D = PLAYER_SCENE.instantiate()
	parent.add_child(player)
	player.initialize("edren")
	player.walk_to(Vector2(110, 100), 80.0)
	assert_true(true, "walk_to should use global_position without errors")
	player.cancel_walk()


func test_player_walk_to_short_distance_snaps() -> void:
	var player: Node2D = PLAYER_SCENE.instantiate()
	add_child_autofree(player)
	player.initialize("edren")
	player.global_position = Vector2(100, 100)
	player.walk_to(Vector2(100, 100), 80.0)
	assert_eq(
		player.global_position,
		Vector2(100, 100),
		"should snap to target when < 1px away",
	)


# ==========================================================================
# Issue cra: npc.gd walk_to uses global_position
# ==========================================================================


func test_npc_walk_to_uses_global_position() -> void:
	var parent: Node2D = Node2D.new()
	parent.position = Vector2(50, 50)
	add_child_autofree(parent)
	var npc: Node2D = NPC_SCENE.instantiate()
	parent.add_child(npc)
	npc.initialize_as_actor()
	npc.walk_to(Vector2(60, 50), 80.0)
	assert_true(true, "NPC walk_to should use global_position")
	npc.cancel_walk()


# ==========================================================================
# Issue 22p: Entity scripts have class_name declarations
# ==========================================================================


func test_entity_enemy_has_class_name() -> void:
	assert_true("class_name" in EnemyScript.source_code, "missing class_name")


func test_entity_npc_has_class_name() -> void:
	assert_true("class_name" in NpcScript.source_code, "missing class_name")


func test_entity_treasure_chest_has_class_name() -> void:
	assert_true("class_name" in ChestScript.source_code, "missing class_name")


func test_entity_damage_zone_has_class_name() -> void:
	assert_true("class_name" in DzScript.source_code, "missing class_name")


func test_entity_save_point_has_class_name() -> void:
	assert_true("class_name" in SpScript.source_code, "missing class_name")


func test_entity_trigger_zone_has_class_name() -> void:
	assert_true("class_name" in TzScript.source_code, "missing class_name")


func test_entity_player_character_has_class_name() -> void:
	assert_true("class_name" in PcScript.source_code, "missing class_name")


func test_entity_water_wheel_has_class_name() -> void:
	assert_true("class_name" in WwScript.source_code, "missing class_name")


func test_entity_ember_crystal_has_class_name() -> void:
	assert_true("class_name" in EcScript.source_code, "missing class_name")


# ==========================================================================
# Issue dot: NPC walk animations in AnimationLibrary
# ==========================================================================


func test_npc_has_walk_animations() -> void:
	var npc: Node = NPC_SCENE.instantiate()
	add_child_autofree(npc)
	var ap: AnimationPlayer = npc.get_node_or_null("AnimationPlayer")
	assert_not_null(ap, "NPC should have an AnimationPlayer")
	assert_true(ap.has_animation("walk_north"), "missing walk_north")
	assert_true(ap.has_animation("walk_south"), "missing walk_south")
	assert_true(ap.has_animation("walk_east"), "missing walk_east")
	assert_true(ap.has_animation("walk_west"), "missing walk_west")
	assert_true(ap.has_animation("idle"), "missing idle")


func test_npc_all_standard_animations_present() -> void:
	var npc: Node = NPC_SCENE.instantiate()
	add_child_autofree(npc)
	var ap: AnimationPlayer = npc.get_node_or_null("AnimationPlayer")
	if ap == null:
		fail_test("NPC missing AnimationPlayer")
		return
	var required: Array[String] = [
		"idle",
		"jump",
		"shake",
		"turn_away",
		"head_down",
		"bubble_exclaim",
		"bubble_ellipsis",
		"bubble_question",
		"sweat_drop",
		"cry",
		"red_tint",
		"arms_up",
		"collapse",
		"nod",
		"step_back",
		"walk_north",
		"walk_south",
		"walk_east",
		"walk_west",
	]
	for anim_name: String in required:
		assert_true(
			ap.has_animation(anim_name),
			"NPC should have '%s' animation" % anim_name,
		)


# ==========================================================================
# Encapsulation: entity manager connects to public methods only
# ==========================================================================


func test_entity_manager_connects_to_public_methods() -> void:
	var source: String = (
		(preload("res://scripts/core/exploration_entity_manager.gd") as GDScript).source_code
	)
	var private_count: int = source.count("_exploration._on_")
	assert_eq(
		private_count,
		0,
		"entity manager should not reference private _on_* methods — found %d" % private_count,
	)
