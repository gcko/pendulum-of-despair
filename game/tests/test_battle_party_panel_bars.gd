extends GutTest
## Tests for battle party-panel stat bars (GAP-057), Maren's Weave
## Gauge (GAP-063), and the two-line row layout and ATB ready flash of
## ui-design.md § 2.1/2.3 (#273). Instantiates the standalone panel scene directly —
## no battle boot, so the seed(7) playtest RNG stream is untouched.

const PANEL_SCENE: PackedScene = preload("res://scenes/ui/battle_party_panel.tscn")
const ATBSystemScript = preload("res://scripts/combat/atb_system.gd")
const HOLD: int = StatBarHelpers.ATB_FLASH_HOLD_MS
const FULL: int = ATBSystemScript.GAUGE_MAX

var _panel: PanelContainer
## Fake millisecond clock for the ATB flash; the tests set it by hand.
var _now_ms: int = 0
## The player's Flash Intensity before this test, put back afterwards: the
## panel reads it from PartyState config, which may hold a saved value.
var _prior_flash: Variant = null


func before_each() -> void:
	_prior_flash = PartyState.get_config().get("flash_intensity")
	PartyState.set_config("flash_intensity", "full")
	_panel = _new_panel()


func after_each() -> void:
	_panel = null
	if _prior_flash == null:
		PartyState.get_config().erase("flash_intensity")
	else:
		PartyState.set_config("flash_intensity", _prior_flash)
	TestHelpers.reset_game_state()


## A panel on the fake clock, built after any config the test set up.
func _new_panel() -> PanelContainer:
	var panel: PanelContainer = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	_now_ms = 100000
	panel.clock_msec = func() -> int: return _now_ms
	return panel


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
	var hp_label: Label = _row_node(0, "HPLine/HPValue")
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
	var label_r: Rect2 = _rect(0, "HPLine/HPLabel")
	var bar_r: Rect2 = _rect(0, "HPLine/HPBarBg")
	var num_r: Rect2 = _rect(0, "HPLine/HPValue")
	assert_lte(name_r.end.x, label_r.position.x, "name, then the HP label")
	assert_lte(label_r.end.x, bar_r.position.x, "HP label, then its bar")
	assert_lte(bar_r.end.x, num_r.position.x, "bar, then the number")


func test_mp_line_lines_up_under_hp_with_the_atb_gauge_far_right() -> void:
	# "        MP ██░░  48/ 80 ▐█" — MP columns under HP's, ATB at the row's end.
	_panel.update_party([_member(680, 800, 48, 80)], {"party_0": 0})
	await wait_process_frames(1)
	var hp_line: Rect2 = _rect(0, "HPLine")
	var mp_line: Rect2 = _rect(0, "MPLine")
	assert_eq(_rect(0, "MPLine/MPLabel").position.x, _rect(0, "HPLine/HPLabel").position.x)
	assert_eq(
		_rect(0, "MPLine/MPCluster/MPBarBg").position.x,
		_rect(0, "HPLine/HPBarBg").position.x,
		"MP bar starts in the HP bar's column"
	)
	assert_eq(_rect(0, "MPLine/MPValue").position.x, _rect(0, "HPLine/HPValue").position.x)
	var atb: Rect2 = _rect(0, "MPLine/ATBBarBg")
	assert_eq(atb.end.x, mp_line.end.x, "the ATB gauge is flush with the row's right edge")
	assert_gt(atb.position.x, _rect(0, "MPLine/MPValue").end.x, "and right of the MP number")
	assert_gte(atb.position.y, hp_line.end.y, "it sits on the MP line, as the ASCII draws it")


func test_lines_carry_hp_and_mp_labels_in_their_colors() -> void:
	_panel.update_party([_member(680, 800, 48, 80)], {"party_0": 0})
	var hp_label: Label = _row_node(0, "HPLine/HPLabel")
	var mp_label: Label = _row_node(0, "MPLine/MPLabel")
	assert_eq(hp_label.text, "HP")
	assert_eq(mp_label.text, "MP")
	assert_eq(hp_label.modulate, StatBarHelpers.COLOR_HP_TEXT, "HP label is text green #44ff44")
	assert_eq(mp_label.modulate, StatBarHelpers.COLOR_MP_FILL, "MP label is blue")


func test_hp_number_is_text_green_while_the_bar_is_fill_green() -> void:
	_panel.update_party([_member(680, 800)], {"party_0": 0})
	var hp_value: Label = _row_node(0, "HPLine/HPValue")
	var fill: ColorRect = _row_node(0, "HPLine/HPBarBg/HPBarFill")
	assert_eq(hp_value.modulate, StatBarHelpers.COLOR_HP_TEXT, "§ 1.4 HP text #44ff44")
	assert_eq(fill.color, StatBarHelpers.COLOR_HP_FILL, "§ 1.4 HP bar fill #44cc44")


func test_hp_label_stays_green_when_the_bar_turns_red() -> void:
	# § 2.3: the label is green; only the bar fill (and its number) turn red.
	_panel.update_party([_member(100, 800)], {"party_0": 0})
	var hp_label: Label = _row_node(0, "HPLine/HPLabel")
	assert_eq(hp_label.modulate, StatBarHelpers.COLOR_HP_TEXT)


func test_numbers_pad_to_three_digits_so_the_slashes_line_up() -> void:
	# § 2.1: "680/800" over " 48/ 80" over " 96/120".
	var party: Array = [_member(680, 800, 48, 80), _member(620, 620, 96, 120)]
	_panel.update_party(party, {"party_0": 0, "party_1": 0})
	await wait_process_frames(1)
	var fs: String = StatBarHelpers.FIGURE_SPACE
	assert_eq((_row_node(0, "HPLine/HPValue") as Label).text, "680/800")
	assert_eq((_row_node(0, "MPLine/MPValue") as Label).text, "%s48/%s80" % [fs, fs])
	assert_eq((_row_node(1, "MPLine/MPValue") as Label).text, "%s96/120" % fs)
	var slash_x: Array = []
	for path: String in ["HPLine/HPValue", "MPLine/MPValue"]:
		for slot: int in range(2):
			var value: Label = _row_node(slot, path)
			var font: Font = value.get_theme_font("font")
			var size: int = value.get_theme_font_size("font_size")
			var before: String = value.text.substr(0, value.text.find("/"))
			var width: float = font.get_string_size(before, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			slash_x.append(value.get_global_rect().position.x + width)
	for x: float in slash_x:
		assert_eq(x, slash_x[0], "every slash sits in one column down the panel")


func test_name_is_uppercase_like_the_layout() -> void:
	_panel.update_party([_member(680, 800)], {"party_0": 0})
	assert_eq((_row_node(0, "HPLine/NameLabel") as Label).text, "EDREN")


func test_name_follows_a_new_member_in_the_slot() -> void:
	_panel.update_party([_member(680, 800)], {"party_0": 0})
	_panel.update_party([_member(620, 620, 35, 78, "lira")], {"party_0": 0})
	assert_eq((_row_node(0, "HPLine/NameLabel") as Label).text, "LIRA")


# --- ATB ready flash (ui-design.md § 2.3, #273) ---


func _atb_color(slot: int) -> Color:
	return (_row_node(slot, "MPLine/ATBBarBg/ATBBarFill") as ColorRect).color


## One poll of the panel at `ms` after the test's start, as BattleUI runs it
## every frame. Returns row 0's ATB fill color.
func _at(ms: int, gauge: int, member: Dictionary = {}) -> Color:
	_now_ms = 100000 + ms
	var m: Dictionary = member if not member.is_empty() else _member(800, 800)
	_panel.update_party([m], {"party_0": gauge})
	return _atb_color(0)


func test_filling_gauge_is_steady_gold() -> void:
	for ms: int in [0, HOLD, HOLD * 2, HOLD * 3]:
		assert_eq(_at(ms, FULL - 1), StatBarHelpers.COLOR_ATB_FILL, "not full never flashes")


func test_full_gauge_holds_each_color_250_ms() -> void:
	var gold: Color = StatBarHelpers.COLOR_ATB_FILL
	var white: Color = StatBarHelpers.COLOR_ATB_FLASH
	assert_eq(_at(0, FULL), gold, "gold the moment it fills")
	assert_eq(_at(HOLD - 1, FULL), gold, "and for the whole first hold")
	assert_eq(_at(HOLD, FULL), white, "white at 250 ms")
	assert_eq(_at(HOLD * 2 - 1, FULL), white, "held through 499 ms")
	assert_eq(_at(HOLD * 2, FULL), gold, "back to gold at 500 ms")
	assert_eq(_at(HOLD * 3, FULL), white, "two flashes a second")


func test_flash_stops_when_the_gauge_is_spent() -> void:
	assert_eq(_at(0, FULL), StatBarHelpers.COLOR_ATB_FILL)
	assert_eq(_at(HOLD, FULL), StatBarHelpers.COLOR_ATB_FLASH, "precondition: mid-flash")
	assert_eq(_at(HOLD + 1, 0), StatBarHelpers.COLOR_ATB_FILL, "spent gauge drops back to gold")
	for ms: int in [HOLD * 2, HOLD * 3]:
		assert_eq(_at(ms, 100), StatBarHelpers.COLOR_ATB_FILL, "and stays gold")


func test_refilled_gauge_restarts_the_flash_on_gold() -> void:
	_at(0, FULL)
	_at(HOLD, FULL)
	_at(HOLD + 10, 0)
	assert_eq(
		_at(HOLD + 20, FULL), StatBarHelpers.COLOR_ATB_FILL, "first hold after refill is gold"
	)
	assert_eq(_at(HOLD * 2 + 20, FULL), StatBarHelpers.COLOR_ATB_FLASH, "then white")


func test_hidden_row_shown_again_with_a_full_gauge_starts_on_gold() -> void:
	_at(0, FULL)
	assert_eq(_at(HOLD, FULL), StatBarHelpers.COLOR_ATB_FLASH, "precondition: mid-flash")
	_now_ms = 100000 + HOLD + 10
	_panel.update_party([{}], {"party_0": FULL})
	assert_false((_panel.get_node("Rows/Row0") as Control).visible, "precondition: row hidden")
	assert_eq(_at(HOLD + 20, FULL), StatBarHelpers.COLOR_ATB_FILL, "shown again: gold first")
	assert_eq(_at(HOLD * 2 + 20, FULL), StatBarHelpers.COLOR_ATB_FLASH, "then its own cycle")


func test_each_row_flashes_on_its_own_clock() -> void:
	var party: Array = [_member(800, 800), _member(800, 800)]
	_panel.update_party(party, {"party_0": FULL, "party_1": 0})
	_now_ms += HOLD
	_panel.update_party(party, {"party_0": FULL, "party_1": FULL})
	assert_eq(_atb_color(0), StatBarHelpers.COLOR_ATB_FLASH, "row 0 is a hold into its flash")
	assert_eq(_atb_color(1), StatBarHelpers.COLOR_ATB_FILL, "row 1 just filled: gold first")


func test_sleeping_member_with_a_full_gauge_does_not_flash() -> void:
	var asleep: Dictionary = _member(800, 800)
	asleep["active_statuses"] = [{"name": "sleep"}]
	for ms: int in [0, HOLD, HOLD * 3]:
		assert_eq(_at(ms, FULL, asleep), StatBarHelpers.COLOR_ATB_FILL, "asleep: not ready")
	asleep["active_statuses"] = [{"name": "poison"}]
	assert_eq(_at(HOLD * 4, FULL, asleep), StatBarHelpers.COLOR_ATB_FILL, "woken: gold first")
	assert_eq(_at(HOLD * 5, FULL, asleep), StatBarHelpers.COLOR_ATB_FLASH, "then it flashes")


func test_flash_intensity_off_keeps_a_full_gauge_steady_gold() -> void:
	PartyState.set_config("flash_intensity", "off")
	_panel = _new_panel()
	for ms: int in [0, HOLD, HOLD * 2, HOLD * 3]:
		assert_eq(_at(ms, FULL), StatBarHelpers.COLOR_ATB_FILL, "flashes off: no white cel")


func test_flash_runs_on_the_real_clock_by_default() -> void:
	# No injected clock: the flash must turn white on its own once real time
	# passes the hold, and never before it.
	var panel: PanelContainer = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	var atb_fill: ColorRect = panel.get_node("Rows/Row0/MPLine/ATBBarBg/ATBBarFill")
	var start: int = Time.get_ticks_msec()
	panel.update_party([_member(800, 800)], {"party_0": FULL})
	assert_eq(atb_fill.color, StatBarHelpers.COLOR_ATB_FILL, "gold when it fills")
	var white_at: int = -1
	while Time.get_ticks_msec() - start < 2000:
		await wait_process_frames(1)
		panel.update_party([_member(800, 800)], {"party_0": FULL})
		if atb_fill.color == StatBarHelpers.COLOR_ATB_FLASH:
			white_at = Time.get_ticks_msec()
			break
	assert_gt(white_at, -1, "real time alone turned the gauge white")
	assert_gte(white_at - start, HOLD, "and not before the 250 ms hold")


# --- StatBarHelpers ---


func test_flash_cels_follow_flash_intensity() -> void:
	var gold: Color = StatBarHelpers.COLOR_ATB_FILL
	var white: Color = StatBarHelpers.COLOR_ATB_FLASH
	assert_eq(StatBarHelpers.atb_flash_cels("full"), [gold, white] as Array[Color])
	assert_eq(
		StatBarHelpers.atb_flash_cels("reduced"),
		[gold, gold.lerp(white, 0.5)] as Array[Color],
		"reduced dims the white cel to 50%"
	)
	assert_eq(StatBarHelpers.atb_flash_cels("off"), [gold] as Array[Color], "off: no flash")
	assert_eq(
		StatBarHelpers.atb_flash_cels("bogus"), [gold, white] as Array[Color], "unknown is full"
	)


func test_fill_width_lands_on_whole_pixels() -> void:
	assert_eq(StatBarHelpers.fill_width(799, 800, 120.0), 119.0, "799/800 of 120 is floored")
	assert_eq(StatBarHelpers.fill_width(1, 3, 80.0), 26.0, "a third of 80 is floored")
	assert_eq(StatBarHelpers.fill_width(800, 800, 120.0), 120.0, "full stays full")
	_panel.update_party([_member(799, 800)], {"party_0": FULL / 3})
	var hp_fill: ColorRect = _row_node(0, "HPLine/HPBarBg/HPBarFill")
	var atb_fill: ColorRect = _row_node(0, "MPLine/ATBBarBg/ATBBarFill")
	assert_eq(hp_fill.size.x, floorf(hp_fill.size.x), "HP fill ends on a whole pixel")
	assert_eq(atb_fill.size.x, floorf(atb_fill.size.x), "ATB fill ends on a whole pixel")


func test_stat_pair_pads_both_numbers_to_three_digits() -> void:
	var fs: String = StatBarHelpers.FIGURE_SPACE
	assert_eq(StatBarHelpers.format_stat_pair(680, 800), "680/800")
	assert_eq(StatBarHelpers.format_stat_pair(48, 80), "%s48/%s80" % [fs, fs])
	assert_eq(StatBarHelpers.format_stat_pair(5, 120), "%s%s5/120" % [fs, fs])
	assert_eq(StatBarHelpers.format_stat_pair(1234, 1500), "1234/1500", "four digits print whole")
