extends GutTest
## The enemy target cursor points at the enemy the command will hit. The
## command menu's cursor counts living, targetable enemies only, and the battle
## resolves it the same way (BattleActions.resolve_enemy_target); the arrow must
## read it the same way too, or with the first enemy down it points at a corpse
## while the command lands on the enemy beside it (ui-design.md § 2.6).

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const BattleUIScript = preload("res://scripts/ui/battle_ui.gd")

var _booted: Node = null


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _boot() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin", "ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


func _arrow_over(ui: CanvasLayer, enemy: Node) -> Vector2:
	return ui._to_screen(enemy.position) - BattleUIScript.ENEMY_ARROW_OFFSET


func test_with_the_first_enemy_down_the_first_target_is_the_survivor() -> void:
	var battle: Node = _boot()
	var ui: CanvasLayer = battle._ui
	var enemies: Array[Node] = battle.get_enemies()
	assert_ne(_arrow_over(ui, enemies[0]), _arrow_over(ui, enemies[1]), "precondition: apart")
	enemies[0].take_damage(enemies[0].current_hp)
	assert_false(enemies[0].is_alive, "precondition: the first enemy is down")

	ui._on_target_changed(0, true)

	assert_true(ui._target_arrow.visible, "the cursor shows")
	assert_eq(ui._target_arrow.position, _arrow_over(ui, enemies[1]), "over the living enemy")


func test_with_every_enemy_standing_the_cursor_points_where_it_counts() -> void:
	var battle: Node = _boot()
	var ui: CanvasLayer = battle._ui
	ui._on_target_changed(1, true)
	assert_eq(ui._target_arrow.position, _arrow_over(ui, battle.get_enemies()[1]))
