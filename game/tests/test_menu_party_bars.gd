extends GutTest
## Tests for main-menu party-row HP/MP fill bars (GAP-057).
## Calls _update_party_row directly with fabricated member dicts so no
## PartyState seeding is needed.

const MENU_SCENE: PackedScene = preload("res://scenes/overlay/menu.tscn")
const TestHelpers = preload("res://tests/test_helpers.gd")

var _menu: Node


func before_each() -> void:
	TestHelpers.reset_game_state()
	_menu = MENU_SCENE.instantiate()
	add_child_autofree(_menu)


func after_each() -> void:
	_menu = null
	TestHelpers.reset_game_state()


func _fake_member(hp: int, max_hp: int, mp: int, max_mp: int) -> Dictionary:
	return {
		"character_id": "edren",
		"level": 5,
		"current_hp": hp,
		"max_hp": max_hp,
		"current_mp": mp,
		"max_mp": max_mp,
	}


func _row0_node(path: String) -> Node:
	return _menu.get_node_or_null("MainPanel/Margin/Rows/Row0/%s" % path)


func test_menu_hp_bar_fill_and_low_color() -> void:
	_menu._update_party_row(0, _fake_member(99, 400, 10, 80))
	var bg: ColorRect = _row0_node("HPCluster/HPBarBg")
	var fill: ColorRect = _row0_node("HPCluster/HPBarBg/HPBarFill")
	assert_not_null(bg, "menu row should have an HP bar track")
	assert_not_null(fill, "menu row should have an HP bar fill")
	assert_almost_eq(fill.size.x, 0.2475 * bg.custom_minimum_size.x, 0.001, "99/400 fills 24.75%")
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_LOW, "below 25% is low, bar turns red")


func test_menu_hp_bar_green_when_healthy() -> void:
	_menu._update_party_row(0, _fake_member(400, 400, 10, 80))
	var fill: ColorRect = _row0_node("HPCluster/HPBarBg/HPBarFill")
	assert_not_null(fill)
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_FILL, "healthy HP stays green")


func test_menu_mp_bar_fill() -> void:
	_menu._update_party_row(0, _fake_member(400, 400, 10, 80))
	var bg: ColorRect = _row0_node("MPCluster/MPBarBg")
	var fill: ColorRect = _row0_node("MPCluster/MPBarBg/MPBarFill")
	assert_not_null(fill, "menu row should have an MP bar fill")
	assert_eq(fill.size.x, 0.125 * bg.custom_minimum_size.x, "10/80 MP fills an eighth")


func test_menu_numeric_labels_remain() -> void:
	_menu._update_party_row(0, _fake_member(100, 400, 10, 80))
	var hp_label: Label = _row0_node("HPCluster/HPLabel")
	assert_not_null(hp_label, "numeric HP label stays alongside the bar")
	assert_eq(hp_label.text, "HP 100/400", "numeric value keeps rendering")
	assert_true(hp_label.visible, "label is not hidden by the bar layout")
