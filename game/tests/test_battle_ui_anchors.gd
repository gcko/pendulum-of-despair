extends GutTest
## Tests that BattleUI anchors the target cursor and damage popups to the
## party panel's real row rects instead of a hardcoded row pitch (#276,
## ui-design.md § 2.3/2.6). Boots the real battle scene so the panel is
## laid out exactly as it renders in play.

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


func test_party_damage_popup_sits_on_the_row_it_belongs_to() -> void:
	seed(31)
	var battle: Node = await _boot()
	var ui: CanvasLayer = battle._ui
	var row: Rect2 = ui._party_panel.get_row_global_rect(1)
	assert_gt(row.size.y, 0.0, "precondition: slot 1 has a visible row")

	ui._on_damage_dealt("party_1", 42, "damage")
	var popup: Label = _popup(ui, "42")
	assert_not_null(popup, "a popup label spawned for the party hit")
	var size: Vector2 = popup.get_minimum_size()
	assert_almost_eq(
		popup.position.x + size.x * 0.5,
		row.position.x + row.size.x * 0.5,
		1.0,
		"popup is centered over its row"
	)
	assert_almost_eq(
		popup.position.y + size.y * 0.5,
		row.position.y + row.size.y * 0.5,
		1.0,
		"and vertically centered on it, so it cannot be read as another member's"
	)


func test_party_damage_popup_never_climbs_into_the_row_above() -> void:
	# The party rows are packed far tighter than the enemy lift (POPUP_LIFT), so
	# the popup rises only into the gap between rows (#276, ui-design.md § 2.3).
	seed(31)
	var battle: Node = await _boot()
	var ui: CanvasLayer = battle._ui
	var above: Rect2 = ui._party_panel.get_row_global_rect(0)
	var row: Rect2 = ui._party_panel.get_row_global_rect(1)
	assert_gt(above.size.y, 0.0, "precondition: slot 0 has a visible row")
	assert_lt(row.position.y - above.position.y, 60.0, "precondition: rows are tightly packed")

	ui._on_damage_dealt("party_1", 45, "damage")
	var popup: Label = _popup(ui, "45")
	assert_not_null(popup, "a popup label spawned for the party hit")
	var highest_y: float = popup.position.y - BattleUIScript.PARTY_POPUP_RISE
	assert_gte(
		highest_y, above.position.y + above.size.y, "the whole rise stays clear of the row above"
	)


func test_ally_targeting_is_limited_to_the_occupied_party_slots() -> void:
	# The Act I party is two members, so the ally cursor must never be able to
	# walk onto slots 2 and 3 — which have no row to point at (#276).
	seed(31)
	var battle: Node = await _boot()
	var ui: CanvasLayer = battle._ui
	assert_eq(ui._occupied_party_slot_count(), 2, "precondition: Act I starts with two members")

	ui._on_turn_ready("party_0", true, 0, 1, false, {"character_id": "edren", "level": 1})

	assert_eq(ui._command_menu._party_target_count, 2, "the menu targets only the occupied slots")
