class_name StatBarHelpers
extends RefCounted
## Pure helpers for solid pixel stat-fill bars (ui-design.md § 1.2 "one
## modern addition", § 2.1/2.3 battle rows, § 3.3 menu rows).
## Bar geometry is set against the track's custom_minimum_size so fills
## stay deterministic under headless container layout.

## HP fill/text green. ui-design.md § 1.4 Color Palette > 'HP text & bar fill'
## lists "#44ff44 / #44cc44" without assigning which is fill — we keep the
## shipped #44cc44 everywhere.
const COLOR_HP_FILL: Color = Color("#44cc44")
## Low-HP warning (< 25% of max), bar fill AND numeric text.
const COLOR_HP_LOW: Color = Color("#ff4444")
const COLOR_MP_FILL: Color = Color("#4488ff")
## Maren's Weave Gauge fill (ui-design.md § 2.9).
const COLOR_WEAVE_FILL: Color = Color("#aa44ff")


## Fill width in pixels for a stat bar. Clamps to [0, bar_width]; a
## non-positive max renders an empty bar instead of dividing by zero.
static func fill_width(current: int, max_value: int, bar_width: float) -> float:
	if max_value <= 0:
		return 0.0
	return clampf(float(current) / float(max_value), 0.0, 1.0) * bar_width


## HP fill color: low-HP red below 25% of max, using the shipped
## integer-division idiom (hp < max_hp / 4) so bar and numeric text
## flip on the same frame.
static func hp_fill_color(hp: int, max_hp: int) -> Color:
	return COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP_FILL


## Only Maren carries the Weave Gauge (ui-design.md § 2.9).
static func shows_weave_gauge(character_id: String) -> bool:
	return character_id == "maren"
