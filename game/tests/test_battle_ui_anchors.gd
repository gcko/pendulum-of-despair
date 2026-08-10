extends GutTest
## Tests that BattleUI anchors the target cursor and damage popups to the
## party panel's real row rects instead of a hardcoded row pitch (#276,
## ui-design.md § 2.2/2.6). Boots the real battle scene so the panel is
## laid out exactly as it renders in play.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

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
	await wait_frames(3)
	_booted = battle
	return battle


## Newest damage popup: BattleUI adds each one as a Label child of itself.
## The persistent target cursor is excluded by matching the popup's text.
func _popup(ui: CanvasLayer, text: String) -> Label:
	for child: Node in ui.get_children():
		if child is Label and (child as Label).text == text:
			return child as Label
	return null


func test_target_cursor_lands_on_the_real_party_row() -> void:
	seed(31)
	var battle: Node = await _boot()
	var ui: CanvasLayer = battle._ui
	var panel: PanelContainer = ui._party_panel
	var row: Rect2 = panel.get_row_global_rect(1)
	assert_gt(row.size.y, 0.0, "precondition: slot 1 has a visible row")

	ui._on_target_changed(1, false)
	var arrow: Label = ui._target_arrow
	assert_true(arrow.visible, "targeting a party member shows the cursor")
	var centre_y: float = arrow.position.y + arrow.get_minimum_size().y * 0.5
	assert_between(centre_y, row.position.y, row.position.y + row.size.y, "cursor is on the row")
	assert_lte(
		arrow.position.x + arrow.get_minimum_size().x,
		row.position.x,
		"cursor sits left of the row it points at"
	)


func test_target_cursor_hides_for_an_empty_party_slot() -> void:
	seed(31)
	var battle: Node = await _boot()
	var ui: CanvasLayer = battle._ui
	# Refresh the panel from battle state: the starting party is Edren + Cael,
	# so slots 2 and 3 have no row for a cursor to anchor to.
	ui._update_party_panel()
	assert_eq(ui._party_panel.get_row_global_rect(3), Rect2(), "precondition: slot 3 has no row")
	ui._on_target_changed(3, false)
	assert_false(ui._target_arrow.visible, "no row means no cursor to place")


func test_party_damage_popup_is_centred_over_the_real_row() -> void:
	seed(31)
	var battle: Node = await _boot()
	var ui: CanvasLayer = battle._ui
	var row: Rect2 = ui._party_panel.get_row_global_rect(1)
	assert_gt(row.size.y, 0.0, "precondition: slot 1 has a visible row")

	ui._on_damage_dealt("party_1", 42, "damage")
	var popup: Label = _popup(ui, "42")
	assert_not_null(popup, "a popup label spawned for the party hit")
	var popup_centre_x: float = popup.position.x + popup.get_minimum_size().x * 0.5
	var row_centre_x: float = row.position.x + row.size.x * 0.5
	assert_almost_eq(popup_centre_x, row_centre_x, 1.0, "popup is centred over its row")
	assert_lt(popup.position.y, row.position.y, "popup floats above the row")
