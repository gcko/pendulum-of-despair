extends GutTest
## Tests for battle party-panel stat bars (GAP-057) and Maren's Weave
## Gauge (GAP-063). Instantiates the standalone panel scene directly —
## no battle boot, so the seed(7) playtest RNG stream is untouched.

const PANEL_SCENE: PackedScene = preload("res://scenes/ui/battle_party_panel.tscn")
const ATBSystemScript = preload("res://scripts/combat/atb_system.gd")

var _panel: PanelContainer


func before_each() -> void:
	_panel = PANEL_SCENE.instantiate()
	add_child_autofree(_panel)


func after_each() -> void:
	_panel = null


func _member(
	hp: int, max_hp: int, mp: int = 10, max_mp: int = 80, cid: String = "edren"
) -> Dictionary:
	return {
		"character_id": cid,
		"character_data": {"name": cid.capitalize()},
		"current_hp": hp,
		"max_hp": max_hp,
		"current_mp": mp,
		"max_mp": max_mp,
		"wg": 0,
	}


func _row_node(slot: int, path: String) -> Node:
	return _panel.get_node_or_null("Rows/Row%d/%s" % [slot, path])


func test_hp_bar_fill_reflects_ratio() -> void:
	_panel.update_party([_member(400, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPBarBg/HPBarFill")
	var bg: ColorRect = _row_node(0, "HPBarBg")
	assert_eq(fill.size.x, 0.5 * bg.custom_minimum_size.x, "half HP fills half the bar")


func test_hp_bar_turns_red_below_quarter() -> void:
	_panel.update_party([_member(199, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPBarBg/HPBarFill")
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_LOW, "below 25% is red")
	var hp_label: Label = _row_node(0, "HPLabel")
	assert_eq(hp_label.modulate, StatBarHelpers.COLOR_HP_LOW, "numeric text matches")


func test_hp_bar_green_at_exact_quarter() -> void:
	_panel.update_party([_member(200, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPBarBg/HPBarFill")
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_FILL, "exactly 25% stays green")


func test_ko_member_renders_empty_hp_bar() -> void:
	_panel.update_party([_member(0, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPBarBg/HPBarFill")
	assert_eq(fill.size.x, 0.0, "KO renders an honest empty bar")


func test_mp_bar_empty_renders_zero_width_fill() -> void:
	_panel.update_party([_member(800, 800, 0, 80)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "MPCluster/MPBarBg/MPBarFill")
	assert_eq(fill.size.x, 0.0, "0 MP is an empty fill over the visible track")


func test_weave_gauge_visible_only_for_maren() -> void:
	var maren: Dictionary = _member(300, 300, 40, 80, "maren")
	maren["wg"] = 50
	_panel.update_party([maren, _member(400, 800)], {"party_0": 0, "party_1": 0})
	var weave_bg: ColorRect = _row_node(0, "MPCluster/WeaveBarBg")
	var weave_fill: ColorRect = _row_node(0, "MPCluster/WeaveBarBg/WeaveBarFill")
	assert_true(weave_bg.visible, "Maren's row shows the Weave Gauge")
	assert_eq(weave_fill.size.x, 0.5 * weave_bg.custom_minimum_size.x, "WG 50/100 is half")
	var other_weave: ColorRect = _row_node(1, "MPCluster/WeaveBarBg")
	assert_false(other_weave.visible, "non-Maren rows hide the gauge")


func test_atb_fill_uses_gauge_max_constant() -> void:
	_panel.update_party([_member(800, 800)], {"party_0": ATBSystemScript.GAUGE_MAX})
	var fill: ColorRect = _row_node(0, "ATBBarBg/ATBBarFill")
	var bg: ColorRect = _row_node(0, "ATBBarBg")
	assert_eq(fill.size.x, bg.custom_minimum_size.x, "full gauge fills the track")
	_panel.update_party([_member(800, 800)], {"party_0": ATBSystemScript.GAUGE_MAX / 2})
	assert_eq(fill.size.x, 0.5 * bg.custom_minimum_size.x, "half gauge is half")


func test_empty_member_hides_row() -> void:
	_panel.update_party([_member(400, 800), {}], {"party_0": 0})
	var row1: HBoxContainer = _panel.get_node_or_null("Rows/Row1")
	assert_false(row1.visible, "empty member dict hides the whole row")


func test_active_slot_highlights_name() -> void:
	_panel.set_active_slot(0)
	_panel.update_party([_member(400, 800)], {"party_0": 0})
	var name_label: Label = _row_node(0, "NameLabel")
	assert_eq(name_label.modulate, _panel.COLOR_NAME_ACTIVE, "acting member's name lights up")
	_panel.set_active_slot(-1)
	_panel.update_party([_member(400, 800)], {"party_0": 0})
	assert_eq(name_label.modulate, _panel.COLOR_NAME_NORMAL, "cleared slot restores normal")


func test_row_rect_reports_real_row_geometry() -> void:
	_panel.update_party([_member(400, 800), _member(300, 600)], {"party_0": 0, "party_1": 0})
	# Container layout settles on the next process frame — physics frames are
	# the wrong clock for it, several can elapse without one running (#422).
	await wait_process_frames(1)
	var r0: Rect2 = _panel.get_row_global_rect(0)
	var r1: Rect2 = _panel.get_row_global_rect(1)
	assert_gt(r0.size.y, 0.0, "row 0 reports a real height")
	assert_eq(r0.size.y, r1.size.y, "rows share a height")
	assert_gt(r1.position.y, r0.position.y, "row 1 sits below row 0")
	assert_lt(
		r1.position.y - r0.position.y,
		60.0,
		"real pitch is far tighter than the 60px anchors #276 removed"
	)


func test_row_rect_is_empty_for_a_hidden_row() -> void:
	_panel.update_party([_member(400, 800), {}], {"party_0": 0})
	await wait_process_frames(1)
	assert_eq(_panel.get_row_global_rect(1), Rect2(), "an empty party slot has no anchor")


func test_row_rect_is_empty_out_of_range() -> void:
	_panel.update_party([_member(400, 800)], {"party_0": 0})
	assert_eq(_panel.get_row_global_rect(-1), Rect2(), "negative slot has no anchor")
	assert_eq(_panel.get_row_global_rect(4), Rect2(), "slot past the party has no anchor")


func test_missing_name_falls_back_to_placeholder() -> void:
	var member: Dictionary = _member(400, 800)
	member["character_data"] = {}
	_panel.update_party([member], {"party_0": 0})
	var name_label: Label = _row_node(0, "NameLabel")
	assert_eq(name_label.text, "???", "missing name renders the placeholder")
