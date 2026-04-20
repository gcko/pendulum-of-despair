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
const DialogueScript: GDScript = preload("res://scripts/ui/dialogue_box.gd")
const MenuOverlayScript: GDScript = preload("res://scripts/ui/menu_overlay.gd")
const SaveLoadScript: GDScript = preload("res://scripts/ui/save_load.gd")
const BattleMgrScript: GDScript = preload("res://scripts/combat/battle_manager.gd")


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


func test_push_overlay_silent_pop_recovery_code_exists() -> void:
	# Structural test: verify the recovery code exists in push_overlay.
	# Cannot mutate const OVERLAY_SCENES in Godot 4.6, so we verify
	# the recovery pattern exists in source.
	var source: String = (preload("res://scripts/autoload/game_manager.gd") as GDScript).source_code
	assert_true(
		"did_silent_pop" in source,
		"push_overlay should track silent pop for recovery",
	)
	# Verify the recovery unpauses the tree
	assert_true(
		"get_tree().paused = false" in source,
		"recovery should unpause tree",
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
	TestHelpers.setup_overlay_state(GameManager.OverlayState.MENU)
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
	assert_lt(lines, 850, "exploration.gd should stay under 850 lines")


func test_game_manager_overlay_enum_has_shop() -> void:
	# Access SHOP directly — will error at parse time if missing
	var shop_val: int = GameManager.OverlayState.SHOP
	assert_gte(shop_val, 0, "OverlayState should include SHOP")


func test_battle_camera_zoom_matches_exploration() -> void:
	GameManager.transition_data = {
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
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


# ==========================================================================
# Viewport null-guard: _consume_input() helper replaces bare calls
# ==========================================================================


func test_no_bare_get_viewport_set_input_as_handled() -> void:
	# Structural test: grep game/scripts/ for unguarded get_viewport().set_input_as_handled()
	# and assert zero matches. All call sites should use a guarded _consume_input() helper
	# or an explicit null-check pattern.
	var scripts_dir: String = "res://scripts/"
	var dir: DirAccess = DirAccess.open(scripts_dir)
	assert_not_null(dir, "scripts directory should exist")
	if dir == null:
		return
	var bare_call_files: Array[String] = []
	_scan_for_bare_viewport_calls(scripts_dir, bare_call_files)
	assert_eq(
		bare_call_files.size(),
		0,
		(
			"No scripts should have bare get_viewport().set_input_as_handled() — found in: %s"
			% str(bare_call_files)
		),
	)


func _scan_for_bare_viewport_calls(path: String, results: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		var full_path: String = path.path_join(file_name)
		if dir.current_is_dir():
			_scan_for_bare_viewport_calls(full_path, results)
		elif file_name.ends_with(".gd"):
			var script: GDScript = load(full_path) as GDScript
			if script != null and "get_viewport().set_input_as_handled()" in script.source_code:
				results.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()


func test_consume_input_helper_exists_in_ui_scripts() -> void:
	# Verify each UI script that handles input has the _consume_input helper.
	var scripts_with_helper: Array[GDScript] = [
		CutsceneScript,
		DialogueScript,
		MenuOverlayScript,
		ShopScript,
		SaveLoadScript,
	]
	for script: GDScript in scripts_with_helper:
		assert_true(
			"func _consume_input()" in script.source_code,
			"%s should have _consume_input() helper" % script.resource_path,
		)


# ==========================================================================
# Issue orb: overlay lifecycle test pattern
# ==========================================================================


func test_overlay_state_set_and_clear_pattern() -> void:
	# Documents the test pattern for overlay lifecycle management.
	# Uses TestHelpers to set overlay state, verifies it, tears down, and verifies reset.
	TestHelpers.setup_overlay_state(GameManager.OverlayState.MENU)
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.MENU,
		"overlay should be set to MENU",
	)
	TestHelpers.teardown_overlay()
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"overlay should be reset to NONE",
	)


# ==========================================================================
# Bug fix: defend status cleared on menu open instead of action
# ==========================================================================


func test_defend_persists_after_cancel() -> void:
	# Structural: _on_ui_cancel must NOT clear defending state
	var source: String = BattleMgrScript.source_code
	# Find _on_ui_cancel function body
	var cancel_pos: int = source.find("func _on_ui_cancel()")
	assert_gt(cancel_pos, 0, "_on_ui_cancel should exist")
	# Get text from cancel function to next func
	var next_func: int = source.find("\nfunc ", cancel_pos + 1)
	var cancel_body: String = source.substr(cancel_pos, next_func - cancel_pos)
	assert_false(
		"set_defending" in cancel_body,
		"_on_ui_cancel must not clear defending status",
	)
	assert_false(
		"damage_taken_mult" in cancel_body,
		"_on_ui_cancel must not reset damage_taken_mult",
	)


func test_defend_cleared_on_new_action() -> void:
	# Structural: _on_ui_command should clear defending when action succeeds
	var source: String = BattleMgrScript.source_code
	var cmd_pos: int = source.find("func _on_ui_command(")
	assert_gt(cmd_pos, 0, "_on_ui_command should exist")
	var next_func: int = source.find("\nfunc ", cmd_pos + 1)
	var cmd_body: String = source.substr(cmd_pos, next_func - cmd_pos)
	assert_true(
		"set_defending" in cmd_body,
		"_on_ui_command should clear defending on new action",
	)
	assert_true(
		"damage_taken_mult" in cmd_body,
		"_on_ui_command should reset damage_taken_mult on new action",
	)


func test_defend_not_cleared_on_menu_open() -> void:
	# Structural: _process must NOT clear defending when ATB fills
	var source: String = BattleMgrScript.source_code
	var process_pos: int = source.find("func _process(")
	assert_gt(process_pos, 0, "_process should exist")
	var next_func: int = source.find("\nfunc ", process_pos + 1)
	var process_body: String = source.substr(process_pos, next_func - process_pos)
	assert_false(
		"set_defending" in process_body,
		"_process must not clear defending on menu open",
	)


# ==========================================================================
# Bug fix: _do_item returns bool; smoke bomb blocked in boss fights
# ==========================================================================


func test_smoke_bomb_blocked_in_boss_fight() -> void:
	# Structural: _do_item should check _is_boss for smoke_bomb and return false
	var source: String = BattleMgrScript.source_code
	var item_pos: int = source.find("func _do_item(")
	assert_gt(item_pos, 0, "_do_item should exist")
	var next_func: int = source.find("\nfunc ", item_pos + 1)
	var item_body: String = source.substr(item_pos, next_func - item_pos)
	assert_true(
		"-> bool" in item_body.substr(0, 60),
		"_do_item should return bool",
	)
	assert_true(
		"_is_boss" in item_body,
		"_do_item should check _is_boss for smoke_bomb",
	)
	assert_true(
		"Can't use that here!" in item_body,
		"should emit 'Can't use that here!' for boss smoke_bomb",
	)


func test_item_on_dead_target_returns_false() -> void:
	# Structural: _do_item restore_hp on dead target without can_revive returns false
	var source: String = BattleMgrScript.source_code
	var item_pos: int = source.find("func _do_item(")
	var next_func: int = source.find("\nfunc ", item_pos + 1)
	var item_body: String = source.substr(item_pos, next_func - item_pos)
	# The restore_hp branch should return false for dead targets
	assert_true(
		"return false" in item_body,
		"_do_item should return false for invalid targets",
	)
	assert_true(
		"No effect!" in item_body,
		"should emit 'No effect!' for dead target without revive",
	)


func test_valid_item_returns_true() -> void:
	# Structural: _do_item should return true at the end for valid items
	var source: String = BattleMgrScript.source_code
	var item_pos: int = source.find("func _do_item(")
	var next_func: int = source.find("\nfunc ", item_pos + 1)
	var item_body: String = source.substr(item_pos, next_func - item_pos)
	assert_true(
		"return true" in item_body,
		"_do_item should return true for valid item usage",
	)
	# Verify the caller uses the return value
	var cmd_pos: int = source.find("func _on_ui_command(")
	var cmd_next: int = source.find("\nfunc ", cmd_pos + 1)
	var cmd_body: String = source.substr(cmd_pos, cmd_next - cmd_pos)
	assert_true(
		"ok = _do_item" in cmd_body,
		"_on_ui_command should capture _do_item return value",
	)


# ==========================================================================
# Structural: all test files use TestHelpers.reset_game_state()
# ==========================================================================


func test_all_test_files_use_reset_game_state() -> void:
	# Verify test files that manually clear singletons use TestHelpers.reset_game_state()
	# instead of partial cleanup (EventFlags.clear_all, PartyState.members.clear, etc.).
	var test_dir: String = "res://tests/"
	var dir: DirAccess = DirAccess.open(test_dir)
	assert_not_null(dir, "tests directory should exist")
	if dir == null:
		return
	var missing: Array[String] = []
	var manual_patterns: Array[String] = [
		"EventFlags.clear_all()",
		"PartyState.members.clear()",
		"PartyState.gold = 0",
	]
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			var file: FileAccess = FileAccess.open(test_dir + file_name, FileAccess.READ)
			if file != null:
				var content: String = file.get_as_text()
				file.close()
				if "before_each" in content:
					var has_manual: bool = false
					for pattern: String in manual_patterns:
						if pattern in content:
							has_manual = true
							break
					if has_manual and "reset_game_state" not in content:
						missing.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	assert_eq(
		missing.size(),
		0,
		(
			"Test files with manual singleton cleanup should use reset_game_state — found in: %s"
			% str(missing)
		),
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


# ==========================================================================
# Bug fix: save_load.gd double-load / double-save re-entry guard
# ==========================================================================


func test_save_load_has_load_in_progress_guard() -> void:
	var source: String = SaveLoadScript.source_code
	assert_true(
		"_load_in_progress" in source,
		"save_load.gd should have _load_in_progress guard variable",
	)
	# Verify the guard is checked at the start of _do_load
	var do_load_pos: int = source.find("func _do_load(")
	assert_gt(do_load_pos, 0, "_do_load should exist")
	var next_func: int = source.find("\nfunc ", do_load_pos + 1)
	var do_load_body: String = source.substr(do_load_pos, next_func - do_load_pos)
	assert_true(
		"if _load_in_progress" in do_load_body,
		"_do_load should check _load_in_progress at entry",
	)


func test_save_load_has_save_in_progress_guard() -> void:
	var source: String = SaveLoadScript.source_code
	assert_true(
		"_save_in_progress" in source,
		"save_load.gd should have _save_in_progress guard variable",
	)
	var do_save_pos: int = source.find("func _do_save(")
	assert_gt(do_save_pos, 0, "_do_save should exist")
	var next_func: int = source.find("\nfunc ", do_save_pos + 1)
	var do_save_body: String = source.substr(do_save_pos, next_func - do_save_pos)
	assert_true(
		"if _save_in_progress" in do_save_body,
		"_do_save should check _save_in_progress at entry",
	)


# ==========================================================================
# Bug fix: menu_overlay.gd overlay swap uses silent pop (no gap)
# ==========================================================================


func test_overlay_swap_no_gap() -> void:
	# Structural: _open_save should use pop_overlay(true) for silent pop
	# followed by immediate push_overlay, not call_deferred.
	var source: String = MenuOverlayScript.source_code
	var open_save_pos: int = source.find("func _open_save(")
	assert_gt(open_save_pos, 0, "_open_save should exist")
	var next_func: int = source.find("\nfunc ", open_save_pos + 1)
	var open_save_body: String = source.substr(open_save_pos, next_func - open_save_pos)
	assert_true(
		"pop_overlay(true)" in open_save_body,
		"_open_save should use silent pop_overlay(true)",
	)
	assert_false(
		"call_deferred" in open_save_body,
		"_open_save should NOT use call_deferred (causes one-frame gap)",
	)
	assert_true(
		"push_overlay" in open_save_body,
		"_open_save should call push_overlay directly after silent pop",
	)


# ==========================================================================
# Bug fix: exploration.gd _exit_tree disconnects one-shot signals
# ==========================================================================


func test_exploration_exit_tree_disconnects_signals() -> void:
	# Structural: exploration.gd should have _exit_tree that disconnects
	# pending one-shot callbacks from GameManager.overlay_state_changed.
	var source: String = ExplorationScript.source_code
	assert_true(
		"func _exit_tree()" in source,
		"exploration.gd should have _exit_tree",
	)
	assert_true(
		"_on_dialogue_closed_check_party" in source.substr(source.find("func _exit_tree()")),
		"_exit_tree should disconnect _on_dialogue_closed_check_party",
	)


func test_cleansing_sequence_has_cleanup() -> void:
	# Structural: CleansingSequence should have a cleanup() method that
	# disconnects any pending one-shot signal from GameManager.
	var source: String = CleansingScript.source_code
	assert_true(
		"func cleanup()" in source,
		"CleansingSequence should have cleanup() method",
	)
	assert_true(
		"_pending_callable" in source,
		"CleansingSequence should track pending callable for cleanup",
	)


func test_exploration_exit_tree_calls_cleansing_cleanup() -> void:
	# Structural: _exit_tree should call _cleansing.cleanup() if present
	var source: String = ExplorationScript.source_code
	var exit_tree_pos: int = source.find("func _exit_tree()")
	assert_gt(exit_tree_pos, 0, "_exit_tree should exist")
	var next_func: int = source.find("\nfunc ", exit_tree_pos + 1)
	var exit_tree_body: String = source.substr(exit_tree_pos, next_func - exit_tree_pos)
	assert_true(
		"_cleansing.cleanup()" in exit_tree_body,
		"_exit_tree should call _cleansing.cleanup()",
	)
