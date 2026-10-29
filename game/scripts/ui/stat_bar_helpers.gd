class_name StatBarHelpers
extends RefCounted
## Pure helpers for solid pixel stat-fill bars (ui-design.md § 1.2 "one
## modern addition", § 2.1/2.3 battle rows, § 3.3 menu rows).
## Bar geometry is set against the track's custom_minimum_size so fills
## stay deterministic under headless container layout.

## HP bar fill green. ui-design.md § 1.4 Color Palette > 'HP text & bar fill'
## lists "#44ff44 / #44cc44" in that order: text first, bar fill second.
const COLOR_HP_FILL: Color = Color("#44cc44")
## HP text green — the battle row's "HP" label and its number.
const COLOR_HP_TEXT: Color = Color("#44ff44")
## Low-HP warning (< 25% of max), bar fill AND numeric text.
const COLOR_HP_LOW: Color = Color("#ff4444")
const COLOR_MP_FILL: Color = Color("#4488ff")
## Maren's Weave Gauge fill (ui-design.md § 2.9).
const COLOR_WEAVE_FILL: Color = Color("#aa44ff")
## ATB gauge fill (ui-design.md § 1.4 'ATB gauge fill').
const COLOR_ATB_FILL: Color = Color("#ffcc00")
## The second cel of the full-gauge ready flash (ui-design.md § 2.3).
const COLOR_ATB_FLASH: Color = Color("#ffffff")
## How long each cel of the ready flash holds: 15 frames at 60 fps, so two
## flashes a second (ui-design.md § 2.3).
const ATB_FLASH_HOLD_MS: int = 250
## Pads a battle-row number to three digits at digit width, so the slashes
## line up down the rows as in ui-design.md § 2.1 (" 48/ 80"). The shipped
## font has tabular digits and carries U+2007 FIGURE SPACE at the same width;
## an ASCII space is half a digit and would not align.
const FIGURE_SPACE: String = "\u2007"


## Fill width in pixels for a stat bar. Clamps to [0, bar_width]; a
## non-positive max renders an empty bar instead of dividing by zero.
static func fill_width(current: int, max_value: int, bar_width: float) -> float:
	if max_value <= 0:
		return 0.0
	if current <= 0:
		return 0.0
	# Floored so a fill always ends on a whole pixel (no sub-pixel edge), but
	# never below 1 px while the value is above 0: a member with 1 HP left must
	# not read as KO'd.
	var width: float = floorf(clampf(float(current) / float(max_value), 0.0, 1.0) * bar_width)
	return maxf(width, minf(1.0, bar_width))


## HP fill color: low-HP red below 25% of max, using the shipped
## integer-division idiom (hp < max_hp / 4) so bar and numeric text
## flip on the same frame.
static func hp_fill_color(hp: int, max_hp: int) -> Color:
	return COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP_FILL


## HP number and label color: the same low-HP threshold as the bar, but
## the text green (#44ff44) rather than the bar's #44cc44.
static func hp_text_color(hp: int, max_hp: int) -> Color:
	return COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP_TEXT


## "current/max" with both numbers padded to three digits by figure spaces
## (ui-design.md § 2.1: "680/800", " 48/ 80"). Four-digit values print in full.
static func format_stat_pair(current: int, max_value: int) -> String:
	return ("%3d/%3d" % [current, max_value]).replace(" ", FIGURE_SPACE)


## The ATB ready flash's cels for a Flash Intensity setting (ui-design.md
## § 10.3a, accessibility.md § Granular Controls). "full" alternates gold and
## white; "reduced" dims the white cel to 50% ("dims flashes to 50% opacity"),
## i.e. halfway from gold to white; "off" is steady gold ("disables screen
## flashes entirely"). Anything unrecognized is treated as the "full" default.
static func atb_flash_cels(flash_intensity: String) -> Array[Color]:
	match flash_intensity:
		"off":
			return [COLOR_ATB_FILL]
		"reduced":
			return [COLOR_ATB_FILL, COLOR_ATB_FILL.lerp(COLOR_ATB_FLASH, 0.5)]
	return [COLOR_ATB_FILL, COLOR_ATB_FLASH]


## Only Maren carries the Weave Gauge (ui-design.md § 2.9).
static func shows_weave_gauge(character_id: String) -> bool:
	return character_id == "maren"
