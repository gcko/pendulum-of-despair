extends GutTest
## An absorbed strike heals its target, and the battle screen must show that
## number as a heal, not as damage (#513). A plain Attack can be absorbed once
## a weapon's element reaches it (forge_hammer against a Flame absorber), and
## the strike reports type "absorb" on the manager's damage_dealt signal, the
## seam BattleUI listens on. Boots the real battle scene, as
## test_battle_ui_anchors.gd does, so the UI is wired exactly as in play.

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
	randomize()


func _boot() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	await wait_process_frames(2)
	_booted = battle
	return battle


## The newest damage popup reading [param text]: BattleUI adds each one as a
## Label child of itself.
func _popup(ui: CanvasLayer, text: String) -> Label:
	var found: Label = null
	for child: Node in ui.get_children():
		if child is Label and (child as Label).text == text:
			found = child as Label
	return found


func test_an_absorbed_strike_shows_as_a_heal() -> void:
	seed(31)
	var battle: Node = await _boot()
	battle.damage_dealt.emit("enemy_0", 37, "absorb")
	var popup: Label = _popup(battle._ui, "37")
	assert_not_null(popup, "a number spawned for the absorbed strike")
	assert_eq(popup.modulate, BattleUIScript.COLOR_HEAL, "in the heal color")


func test_a_landed_strike_still_shows_as_damage() -> void:
	seed(31)
	var battle: Node = await _boot()
	battle.damage_dealt.emit("enemy_0", 38, "physical")
	var popup: Label = _popup(battle._ui, "38")
	assert_not_null(popup, "a number spawned for the strike")
	assert_eq(popup.modulate, BattleUIScript.COLOR_DAMAGE, "in the damage color")
