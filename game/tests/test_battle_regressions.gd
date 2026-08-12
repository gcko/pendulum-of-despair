extends GutTest
## Regression guards for the battle layer: the ATB frame budget, command
## menu input handling, heal targeting, the defend flag's lifetime, the
## item command's return contract, and the field behavior of item effects.
##
## Split out of the 968-line test_issue_fixes.gd (#374).

const BATTLE_SCENE: PackedScene = preload("res://scenes/core/battle.tscn")
const BattleStateScript: GDScript = preload("res://scripts/combat/battle_state.gd")
const CmdMenuScript: GDScript = preload("res://scripts/ui/battle_command_menu.gd")
const BattleMgrScript: GDScript = preload("res://scripts/combat/battle_manager.gd")
const BattleItemScript: GDScript = preload("res://scripts/combat/battle_item_command.gd")
const InventoryHelpers: GDScript = preload("res://scripts/util/inventory_helpers.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


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


## The source of one function in BattleItemCommand, from its `func` line to the
## next one. The item command moved out of battle_manager.gd in GAP-087; these
## guards followed it.
func _item_command_body(func_signature: String) -> String:
	var source: String = BattleItemScript.source_code
	var pos: int = source.find(func_signature)
	assert_gt(pos, 0, "%s should exist in battle_item_command.gd" % func_signature)
	if pos < 0:
		return ""
	var next_func: int = source.find("\nfunc ", pos + 1)
	if next_func < 0:
		next_func = source.length()
	return source.substr(pos, next_func - pos)


func test_smoke_bomb_blocked_in_boss_fight() -> void:
	# Structural: the flee item must be refused, not spent, in a boss fight
	var entry_body: String = _item_command_body("func do_item(")
	assert_true(
		"-> bool" in entry_body.substr(0, 60),
		"do_item should return bool",
	)
	var flee_body: String = _item_command_body("func _flee_item(")
	assert_true(
		"is_boss_battle()" in flee_body,
		"the flee item should check is_boss_battle() for smoke_bomb",
	)
	assert_true(
		"Can't use that here!" in flee_body,
		"should emit 'Can't use that here!' for boss smoke_bomb",
	)


func test_item_on_dead_target_returns_false() -> void:
	# Structural: restore_hp on a dead target without can_revive returns false
	var restore_body: String = _item_command_body("func _restore_hp(")
	assert_true(
		"return false" in restore_body,
		"_restore_hp should return false for invalid targets",
	)
	assert_true(
		"No effect!" in restore_body,
		"should emit 'No effect!' for dead target without revive",
	)


func test_valid_item_returns_true() -> void:
	# Structural: do_item should return true at the end for valid items
	var item_body: String = _item_command_body("func do_item(")
	assert_true(
		"return true" in item_body,
		"do_item should return true for valid item usage",
	)
	# Verify the caller uses the return value
	var source: String = BattleMgrScript.source_code
	var cmd_pos: int = source.find("func _on_ui_command(")
	var cmd_next: int = source.find("\nfunc ", cmd_pos + 1)
	var cmd_body: String = source.substr(cmd_pos, cmd_next - cmd_pos)
	assert_true(
		"ok = _get_items().do_item(" in cmd_body,
		"_on_ui_command should capture do_item's return value",
	)


# ==========================================================================
# Bug fix: do_item must consume the item from inventory after use
# ==========================================================================


func test_do_item_consumes_item_after_use() -> void:
	# Structural: do_item should call PartyState.consume_item
	var item_body: String = _item_command_body("func do_item(")
	assert_true(
		"consume_item" in item_body,
		"do_item should call PartyState.consume_item after successful use",
	)
	# Verify consume is after the match block, near return true
	var consume_pos: int = item_body.find("consume_item")
	var return_true_pos: int = item_body.rfind("return true")
	assert_gt(return_true_pos, consume_pos, "consume_item should come before final return true")


# ==========================================================================
# Bug fix: restore_hp effect must honor clears_status field
# ==========================================================================


func test_restore_hp_clears_status_when_flagged() -> void:
	var target: Dictionary = {
		"current_hp": 50,
		"max_hp": 200,
		"status_effects": [{"name": "poison", "duration": 3}],
	}
	var item: Dictionary = {
		"effect": "restore_hp",
		"restore_percent": 100,
		"clears_status": true,
	}
	InventoryHelpers.apply_item_effect(item, target)
	assert_eq(target["current_hp"], 200, "HP should be fully restored")
	assert_eq(target["status_effects"].size(), 0, "status_effects should be cleared")


func test_restore_hp_keeps_status_when_not_flagged() -> void:
	var target: Dictionary = {
		"current_hp": 50,
		"max_hp": 200,
		"status_effects": [{"name": "poison", "duration": 3}],
	}
	var item: Dictionary = {
		"effect": "restore_hp",
		"restore_percent": 100,
	}
	InventoryHelpers.apply_item_effect(item, target)
	assert_eq(target["current_hp"], 200, "HP should be fully restored")
	assert_eq(target["status_effects"].size(), 1, "status_effects should remain when flag absent")


# ==========================================================================
# Bug fix: buff_atk and buff_mag are battle-only (field use is a no-op)
# ==========================================================================


func test_buff_atk_effect_is_noop_in_field() -> void:
	var target: Dictionary = {"atk": 100}
	var item: Dictionary = {"effect": "buff_atk", "value": 10}
	InventoryHelpers.apply_item_effect(item, target)
	assert_eq(target["atk"], 100, "ATK should not change — buff_atk is battle-only")


func test_buff_mag_effect_is_noop_in_field() -> void:
	var target: Dictionary = {"mag": 80}
	var item: Dictionary = {"effect": "buff_mag", "value": 15}
	InventoryHelpers.apply_item_effect(item, target)
	assert_eq(target["mag"], 80, "MAG should not change — buff_mag is battle-only")
