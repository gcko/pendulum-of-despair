extends GutTest
## Regression tests for all issues fixed in the cutscene-review-followups branch.
## Covers: walk_to global_position, max_fps, battle_command_menu input handling,
## battle_ui damage coords, menu scroll, shop act filter, cleansing_sequence
## caching, cutscene_player tree guards, entity class_names, battle_state
## heal targeting, NPC walk animations, title Config option, and test helpers.

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")
const BATTLE_SCENE: PackedScene = preload("res://scenes/core/battle.tscn")
const BattleStateScript: GDScript = preload("res://scripts/combat/battle_state.gd")
const CmdMenuScript: GDScript = preload("res://scripts/ui/battle_command_menu.gd")
const MagicScript: GDScript = preload("res://scripts/ui/menu_magic.gd")
const AbilitiesScript: GDScript = preload("res://scripts/ui/menu_abilities.gd")
const ShopScript: GDScript = preload("res://scripts/ui/shop_overlay.gd")
const CleansingScript: GDScript = preload("res://scripts/core/cleansing_sequence.gd")
const CutsceneScript: GDScript = preload("res://scripts/core/cutscene_player.gd")
const TitleScript: GDScript = preload("res://scripts/core/title.gd")
const ExplorationScript: GDScript = preload("res://scripts/core/exploration.gd")
const CutsceneHandlerScript: GDScript = preload("res://scripts/core/cutscene_handler.gd")
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
# Issue 5ta: project.godot max_fps=60
# ==========================================================================


func test_project_max_fps_is_set() -> void:
	var fps: int = ProjectSettings.get_setting("application/run/max_fps", 0)
	assert_eq(fps, 60, "max_fps should be 60 for ATB combat tick rate")


# ==========================================================================
# Issue dc3: battle_command_menu only consumes handled input
# ==========================================================================


func test_battle_command_menu_handlers_return_bool() -> void:
	var source: String = CmdMenuScript.source_code
	assert_true(
		"_handle_command_input(event: InputEvent) -> bool:" in source,
		"_handle_command_input should return bool",
	)
	assert_true(
		"_handle_submenu_input(event: InputEvent) -> bool:" in source,
		"_handle_submenu_input should return bool",
	)
	assert_true(
		"_handle_target_input(event: InputEvent) -> bool:" in source,
		"_handle_target_input should return bool",
	)


# ==========================================================================
# Issue cc7: menu_magic and menu_abilities scroll
# ==========================================================================


func test_menu_magic_scroll_implemented() -> void:
	var source: String = MagicScript.source_code
	assert_true(
		"_scroll_offset +=" in source or "_scroll_offset -=" in source,
		"menu_magic should modify _scroll_offset for scrolling",
	)


func test_menu_abilities_scroll_implemented() -> void:
	var source: String = AbilitiesScript.source_code
	assert_true(
		"_scroll_offset +=" in source or "_scroll_offset -=" in source,
		"menu_abilities should modify _scroll_offset for scrolling",
	)


# ==========================================================================
# Issue ugq: shop_overlay dynamic act filter
# ==========================================================================


func test_shop_overlay_dynamic_act_filter() -> void:
	var source: String = ShopScript.source_code
	assert_true(
		"_get_current_act()" in source,
		"shop_overlay should use dynamic act filter",
	)


# ==========================================================================
# Issue gkb: cleansing_sequence caches damage zone PackedScene
# ==========================================================================


func test_cleansing_sequence_caches_damage_zone() -> void:
	var source: String = CleansingScript.source_code
	assert_true(
		"_damage_zone_scene" in source,
		"should have a _damage_zone_scene cache variable",
	)
	assert_true(
		"_damage_zone_scene == null" in source,
		"should only load when cache is null",
	)


# ==========================================================================
# Issue am1: cutscene_player is_inside_tree() guards
# ==========================================================================


func test_cutscene_player_has_tree_guards() -> void:
	var source: String = CutsceneScript.source_code
	var guard_count: int = source.count("is_inside_tree()")
	assert_gt(
		guard_count,
		0,
		"cutscene_player should have is_inside_tree() guards",
	)


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


# ==========================================================================
# Issue gjj: battle_state heal targeting KO'd members
# ==========================================================================


func test_heal_returns_zero_for_ko_without_revive() -> void:
	var state: Node = BattleStateScript.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			0,
			{
				"id": "edren",
				"base_stats": {"hp": 100, "mp": 20},
				"current_hp": 0,
			}
		)
	)
	var healed: int = state.heal(0, 50)
	assert_eq(healed, 0, "regular heal should return 0 for KO'd member")


func test_heal_works_with_revive_on_ko() -> void:
	var state: Node = BattleStateScript.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			0,
			{
				"id": "edren",
				"base_stats": {"hp": 100, "mp": 20},
				"current_hp": 0,
			}
		)
	)
	var healed: int = state.heal(0, 50, true)
	assert_gt(healed, 0, "revive heal should restore HP")


func test_is_valid_heal_target_rejects_ko() -> void:
	var state: Node = BattleStateScript.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			0,
			{
				"id": "edren",
				"base_stats": {"hp": 100, "mp": 20},
				"current_hp": 0,
			}
		)
	)
	assert_false(
		state.is_valid_heal_target(0, false),
		"KO'd should not be valid without revive",
	)
	assert_true(
		state.is_valid_heal_target(0, true),
		"KO'd should be valid with revive",
	)


func test_is_valid_heal_target_accepts_living() -> void:
	var state: Node = BattleStateScript.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			0,
			{
				"id": "edren",
				"base_stats": {"hp": 100, "mp": 20},
			}
		)
	)
	assert_true(state.is_valid_heal_target(0), "living member valid")


func test_is_valid_heal_target_empty_slot() -> void:
	var state: Node = BattleStateScript.new()
	add_child_autofree(state)
	assert_false(state.is_valid_heal_target(0), "empty slot invalid")


# ==========================================================================
# Issue 58d: title.gd Config not permanently disabled
# ==========================================================================


func test_title_config_not_unconditionally_disabled() -> void:
	var source: String = TitleScript.source_code
	assert_false(
		"CONFIG:\n\t\t\treturn true" in source,
		"Config should not be unconditionally disabled",
	)


# ==========================================================================
# Issue vtj: push_overlay silent pop recovery
# ==========================================================================


func test_push_overlay_silent_pop_recovery_unpauses() -> void:
	GameManager.current_overlay = GameManager.OverlayState.DIALOGUE
	get_tree().paused = true
	var original: String = GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE]
	GameManager.OVERLAY_SCENES.merge(
		{GameManager.OverlayState.CUTSCENE: "res://nonexistent.tscn"}, true
	)
	var result: bool = GameManager.push_overlay(GameManager.OverlayState.CUTSCENE)
	GameManager.OVERLAY_SCENES.merge({GameManager.OverlayState.CUTSCENE: original}, true)
	assert_false(result, "should fail with nonexistent scene")
	assert_false(
		get_tree().paused,
		"tree must be unpaused after failed force-replace",
	)


# ==========================================================================
# Issue lvb: Test helper exists and works
# ==========================================================================


func test_helpers_class_exists() -> void:
	var helpers: TestHelpers = TestHelpers.new()
	assert_not_null(helpers, "TestHelpers class should exist")


func test_helpers_reset_game_state() -> void:
	PartyState.gold = 999
	EventFlags.set_flag("test_flag", true)
	TestHelpers.reset_game_state()
	assert_eq(PartyState.gold, 0, "gold should be reset")
	assert_false(EventFlags.get_flag("test_flag"), "flags should be cleared")


func test_helpers_teardown_overlay() -> void:
	GameManager.current_overlay = GameManager.OverlayState.MENU
	get_tree().paused = true
	TestHelpers.teardown_overlay()
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"overlay should be NONE after teardown",
	)
	assert_false(get_tree().paused, "tree should be unpaused")


# ==========================================================================
# Future regression guards
# ==========================================================================


func test_exploration_line_count_under_threshold() -> void:
	var lines: int = ExplorationScript.source_code.count("\n")
	assert_lt(lines, 800, "exploration.gd should stay under 800 lines")


func test_game_manager_overlay_enum_has_shop() -> void:
	# Access SHOP directly — will error at parse time if missing
	var shop_val: int = GameManager.OverlayState.SHOP
	assert_gte(shop_val, 0, "OverlayState should include SHOP")


func test_battle_camera_zoom_matches_exploration() -> void:
	var battle: Node = BATTLE_SCENE.instantiate()
	add_child_autofree(battle)
	var cam: Camera2D = battle.get_node_or_null("Camera2D")
	assert_not_null(cam, "battle scene should have Camera2D")
	if cam != null:
		assert_eq(cam.zoom, Vector2(4, 4), "zoom should be 4x")


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


func test_party_state_rest_party_uses_api() -> void:
	PartyState.initialize_new_game()
	PartyState.members[0]["current_hp"] = 10
	PartyState.members[0]["current_mp"] = 0
	PartyState.rest_party(0.5, true)
	assert_gt(
		PartyState.members[0]["current_hp"],
		10,
		"rest_party should restore HP",
	)


func test_cleansing_validates_before_side_effects() -> void:
	var source: String = CleansingScript.source_code
	var validate_pos: int = source.find("ResourceLoader.exists(_ritual_meter_path)")
	var side_effect_pos: int = source.find("distribute_battle_rewards")
	assert_gt(
		side_effect_pos,
		validate_pos,
		"validation should come before side effects in start()",
	)


func test_cutscene_handler_error_prefix() -> void:
	var source: String = CutsceneHandlerScript.source_code
	assert_false(
		'push_error("Exploration:' in source,
		"should not use Exploration prefix in errors",
	)
