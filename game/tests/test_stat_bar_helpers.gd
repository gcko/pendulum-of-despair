extends GutTest
## Tests for StatBarHelpers pure bar math (GAP-057/GAP-063).
## Threshold canon: HP bar/text turn red below 25% of max
## (ui-design.md low-HP warning), matching the shipped integer-division
## idiom hp < max_hp / 4.

const SBH = preload("res://scripts/ui/stat_bar_helpers.gd")


func test_fill_width_half() -> void:
	assert_eq(SBH.fill_width(400, 800, 120.0), 60.0, "half HP fills half the bar")


func test_fill_width_full_and_overflow_clamp() -> void:
	assert_eq(SBH.fill_width(800, 800, 120.0), 120.0, "full fills the whole bar")
	assert_eq(SBH.fill_width(900, 800, 120.0), 120.0, "overflow clamps to bar width")


func test_fill_width_zero_and_negative_clamp() -> void:
	assert_eq(SBH.fill_width(0, 800, 120.0), 0.0, "zero HP is an empty bar")
	assert_eq(SBH.fill_width(-5, 800, 120.0), 0.0, "negative clamps to empty")


func test_fill_width_zero_max_no_division_error() -> void:
	assert_eq(SBH.fill_width(10, 0, 120.0), 0.0, "max 0 must not divide by zero")
	assert_eq(SBH.fill_width(10, -1, 120.0), 0.0, "negative max is empty")


func test_hp_fill_color_boundary_matches_shipped_idiom() -> void:
	# Shipped idiom: hp < max_hp / 4 with integer division.
	assert_eq(SBH.hp_fill_color(200, 800), SBH.COLOR_HP_FILL, "exactly 25% is NOT low")
	assert_eq(SBH.hp_fill_color(199, 800), SBH.COLOR_HP_LOW, "below 25% is low")
	assert_eq(SBH.hp_fill_color(800, 800), SBH.COLOR_HP_FILL, "full HP is green")


func test_weave_gauge_only_for_maren() -> void:
	assert_true(SBH.shows_weave_gauge("maren"), "Maren shows the Weave Gauge")
	assert_false(SBH.shows_weave_gauge("edren"), "others do not")
	assert_false(SBH.shows_weave_gauge(""), "empty id does not")
