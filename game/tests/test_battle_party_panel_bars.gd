extends GutTest
## Tests for battle party-panel stat bars (GAP-057), Maren's Weave
## Gauge (GAP-063), and the two-line row layout and ATB ready flash of
## ui-design.md § 2.1/2.3 (#273). Instantiates the standalone panel scene directly —
## no battle boot, so the seed(7) playtest RNG stream is untouched.

const PANEL_SCENE: PackedScene = preload("res://scenes/ui/battle_party_panel.tscn")
const ATBSystemScript = preload("res://scripts/combat/atb_system.gd")

var _panel: PanelContainer
## Fake render-frame clock for the ATB flash; the tests step it by hand.
var _frame: int = 0


func before_each() -> void:
	_panel = PANEL_SCENE.instantiate()
	add_child_autofree(_panel)
	_frame = 1000
	_panel.frame_clock = func() -> int: return _frame


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
	var fill: ColorRect = _row_node(0, "HPLine/HPBarBg/HPBarFill")
	var bg: ColorRect = _row_node(0, "HPLine/HPBarBg")
	assert_eq(fill.size.x, 0.5 * bg.custom_minimum_size.x, "half HP fills half the bar")


func test_hp_bar_turns_red_below_quarter() -> void:
	_panel.update_party([_member(199, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPLine/HPBarBg/HPBarFill")
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_LOW, "below 25% is red")
	var hp_label: Label = _row_node(0, "HPLine/HPLabel")
	assert_eq(hp_label.modulate, StatBarHelpers.COLOR_HP_LOW, "numeric text matches")


func test_hp_bar_green_at_exact_quarter() -> void:
	_panel.update_party([_member(200, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPLine/HPBarBg/HPBarFill")
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_FILL, "exactly 25% stays green")


func test_ko_member_renders_empty_hp_bar() -> void:
	_panel.update_party([_member(0, 800)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "HPLine/HPBarBg/HPBarFill")
	assert_eq(fill.size.x, 0.0, "KO renders an honest empty bar")


func test_mp_bar_empty_renders_zero_width_fill() -> void:
	_panel.update_party([_member(800, 800, 0, 80)], {"party_0": 0})
	var fill: ColorRect = _row_node(0, "MPLine/MPCluster/MPBarBg/MPBarFill")
	assert_eq(fill.size.x, 0.0, "0 MP is an empty fill over the visible track")


func test_weave_gauge_visible_only_for_maren() -> void:
	var maren: Dictionary = _member(300, 300, 40, 80, "maren")
	maren["wg"] = 50
	_panel.update_party([maren, _member(400, 800)], {"party_0": 0, "party_1": 0})
	var weave_bg: ColorRect = _row_node(0, "MPLine/MPCluster/WeaveBarBg")
	var weave_fill: ColorRect = _row_node(0, "MPLine/MPCluster/WeaveBarBg/WeaveBarFill")
	assert_true(weave_bg.visible, "Maren's row shows the Weave Gauge")
	assert_eq(weave_fill.size.x, 0.5 * weave_bg.custom_minimum_size.x, "WG 50/100 is half")
	var other_weave: ColorRect = _row_node(1, "MPLine/MPCluster/WeaveBarBg")
	assert_false(other_weave.visible, "non-Maren rows hide the gauge")


func test_atb_fill_uses_gauge_max_constant() -> void:
	_panel.update_party([_member(800, 800)], {"party_0": ATBSystemScript.GAUGE_MAX})
	var fill: ColorRect = _row_node(0, "MPLine/ATBBarBg/ATBBarFill")
	var bg: ColorRect = _row_node(0, "MPLine/ATBBarBg")
	assert_eq(fill.size.x, bg.custom_minimum_size.x, "full gauge fills the track")
	_panel.update_party([_member(800, 800)], {"party_0": ATBSystemScript.GAUGE_MAX / 2})
	assert_eq(fill.size.x, 0.5 * bg.custom_minimum_size.x, "half gauge is half")


func test_empty_member_hides_row() -> void:
	_panel.update_party([_member(400, 800), {}], {"party_0": 0})
	var row1: Control = _panel.get_node_or_null("Rows/Row1")
	assert_false(row1.visible, "empty member dict hides the whole row")


func test_active_slot_highlights_name() -> void:
	_panel.set_active_slot(0)
	_panel.update_party([_member(400, 800)], {"party_0": 0})
	var name_label: Label = _row_node(0, "HPLine/NameLabel")
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
	var name_label: Label = _row_node(0, "HPLine/NameLabel")
	assert_eq(name_label.text, "???", "missing name renders the placeholder")


# --- Two-line row layout (ui-design.md § 2.1 Layout, #273) ---


func _rect(slot: int, path: String) -> Rect2:
	return (_row_node(slot, path) as Control).get_global_rect()


func test_row_is_two_lines_with_hp_above_mp() -> void:
	_panel.update_party([_member(680, 800, 48, 80)], {"party_0": 0})
	await wait_process_frames(1)
	var row: Rect2 = _panel.get_row_global_rect(0)
	var hp_line: Rect2 = _rect(0, "HPLine")
	var mp_line: Rect2 = _rect(0, "MPLine")
	assert_gt(hp_line.size.y, 0.0, "the HP line has a real height")
	assert_gte(mp_line.position.y, hp_line.end.y, "the MP line sits below the HP line")
	assert_true(row.encloses(hp_line), "the HP line belongs to the member's row")
	assert_true(row.encloses(mp_line), "the MP line belongs to the member's row")


func test_hp_line_reads_name_label_bar_then_number() -> void:
	# "EDREN   HP ███░ 680/800"
	_panel.update_party([_member(680, 800, 48, 80)], {"party_0": 0})
	await wait_process_frames(1)
	var name_r: Rect2 = _rect(0, "HPLine/NameLabel")
	var prefix_r: Rect2 = _rect(0, "HPLine/HPPrefix")
	var bar_r: Rect2 = _rect(0, "HPLine/HPBarBg")
	var num_r: Rect2 = _rect(0, "HPLine/HPLabel")
	assert_lte(name_r.end.x, prefix_r.position.x, "name, then the HP label")
	assert_lte(prefix_r.end.x, bar_r.position.x, "HP label, then its bar")
	assert_lte(bar_r.end.x, num_r.position.x, "bar, then the number")


func test_mp_line_lines_up_under_hp_with_the_atb_gauge_far_right() -> void:
	# "        MP ██░░  48/ 80 ▐█" — MP columns under HP's, ATB at the row's end.
	_panel.update_party([_member(680, 800, 48, 80)], {"party_0": 0})
	await wait_process_frames(1)
	var hp_line: Rect2 = _rect(0, "HPLine")
	var mp_line: Rect2 = _rect(0, "MPLine")
	assert_eq(_rect(0, "MPLine/MPPrefix").position.x, _rect(0, "HPLine/HPPrefix").position.x)
	assert_eq(
		_rect(0, "MPLine/MPCluster/MPBarBg").position.x,
		_rect(0, "HPLine/HPBarBg").position.x,
		"MP bar starts in the HP bar's column"
	)
	assert_eq(_rect(0, "MPLine/MPLabel").end.x, _rect(0, "HPLine/HPLabel").end.x)
	var atb: Rect2 = _rect(0, "MPLine/ATBBarBg")
	assert_eq(atb.end.x, mp_line.end.x, "the ATB gauge is flush with the row's right edge")
	assert_gt(atb.position.x, _rect(0, "MPLine/MPLabel").end.x, "and right of the MP number")
	assert_gte(atb.position.y, hp_line.end.y, "it sits on the MP line, as the ASCII draws it")


func test_lines_carry_hp_and_mp_labels_in_their_colors() -> void:
	_panel.update_party([_member(680, 800, 48, 80)], {"party_0": 0})
	var hp_prefix: Label = _row_node(0, "HPLine/HPPrefix")
	var mp_prefix: Label = _row_node(0, "MPLine/MPPrefix")
	assert_eq(hp_prefix.text, "HP")
	assert_eq(mp_prefix.text, "MP")
	assert_eq(hp_prefix.modulate, StatBarHelpers.COLOR_HP_FILL, "HP label is green")
	assert_eq(mp_prefix.modulate, StatBarHelpers.COLOR_MP_FILL, "MP label is blue")
	assert_eq((_row_node(0, "HPLine/HPLabel") as Label).text, "680/800")
	assert_eq((_row_node(0, "MPLine/MPLabel") as Label).text, "48/80")


func test_hp_label_stays_green_when_the_bar_turns_red() -> void:
	# § 2.3: the label is green; only the bar fill (and its number) turn red.
	_panel.update_party([_member(100, 800)], {"party_0": 0})
	var hp_prefix: Label = _row_node(0, "HPLine/HPPrefix")
	assert_eq(hp_prefix.modulate, StatBarHelpers.COLOR_HP_FILL)


func test_name_is_uppercase_like_the_layout() -> void:
	_panel.update_party([_member(680, 800)], {"party_0": 0})
	assert_eq((_row_node(0, "HPLine/NameLabel") as Label).text, "EDREN")


# --- ATB ready flash (ui-design.md § 2.3, #273) ---


func _atb_color(slot: int) -> Color:
	return (_row_node(slot, "MPLine/ATBBarBg/ATBBarFill") as ColorRect).color


## Render one frame of the poll BattleUI runs: the clock moves, then the panel
## is refreshed with the same gauge.
func _next_frame(gauge: int) -> Color:
	_frame += 1
	_panel.update_party([_member(800, 800)], {"party_0": gauge})
	return _atb_color(0)


func test_filling_gauge_is_steady_gold() -> void:
	var gauge: int = ATBSystemScript.GAUGE_MAX - 1
	_panel.update_party([_member(800, 800)], {"party_0": gauge})
	var seen: Array = [_atb_color(0)]
	for i: int in range(4):
		seen.append(_next_frame(gauge))
	for c: Color in seen:
		assert_eq(c, StatBarHelpers.COLOR_ATB_FILL, "a gauge that is not full never flashes")


func test_full_gauge_alternates_gold_and_white_every_frame() -> void:
	var full: int = ATBSystemScript.GAUGE_MAX
	_panel.update_party([_member(800, 800)], {"party_0": full})
	var seen: Array = [_atb_color(0)]
	for i: int in range(5):
		seen.append(_next_frame(full))
	var gold: Color = StatBarHelpers.COLOR_ATB_FILL
	var white: Color = StatBarHelpers.COLOR_ATB_FLASH
	assert_eq(seen, [gold, white, gold, white, gold, white], "2-frame gold/white cycle")


func test_flash_stops_the_frame_the_gauge_is_spent() -> void:
	var full: int = ATBSystemScript.GAUGE_MAX
	_panel.update_party([_member(800, 800)], {"party_0": full})
	assert_eq(_next_frame(full), StatBarHelpers.COLOR_ATB_FLASH, "precondition: mid-flash")
	assert_eq(_next_frame(0), StatBarHelpers.COLOR_ATB_FILL, "spent gauge drops back to gold")
	for i: int in range(3):
		assert_eq(_next_frame(i * 100), StatBarHelpers.COLOR_ATB_FILL, "and stays gold")


func test_refilled_gauge_restarts_the_flash_on_gold() -> void:
	var full: int = ATBSystemScript.GAUGE_MAX
	_panel.update_party([_member(800, 800)], {"party_0": full})
	_next_frame(full)
	_next_frame(full)
	_next_frame(0)
	assert_eq(_next_frame(full), StatBarHelpers.COLOR_ATB_FILL, "first frame full is gold")
	assert_eq(_next_frame(full), StatBarHelpers.COLOR_ATB_FLASH, "then white")


func test_each_row_flashes_on_its_own_clock() -> void:
	var full: int = ATBSystemScript.GAUGE_MAX
	var party: Array = [_member(800, 800), _member(800, 800)]
	_panel.update_party(party, {"party_0": full, "party_1": 0})
	_frame += 1
	_panel.update_party(party, {"party_0": full, "party_1": full})
	assert_eq(_atb_color(0), StatBarHelpers.COLOR_ATB_FLASH, "row 0 is a frame into its flash")
	assert_eq(_atb_color(1), StatBarHelpers.COLOR_ATB_FILL, "row 1 just filled: gold first")
