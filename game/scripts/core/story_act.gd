class_name StoryAct
extends RefCounted
## Static helpers mapping EventFlags story progression to the current
## narrative period, encounter danger scaling, and enemy stat tables.
## Source: combat-formulas.md § Act scaling.

## Danger-counter multiplier per period. combat-formulas.md § Act scaling.
## The table's Act IV and Epilogue rows are both x1.1, the same value as
## Act III, so get_period() deliberately has no branch for them: it reports
## "act_iii" for everything past act_iii_started and the carried value is
## already the canonical one (#265).
const DANGER_SCALES: Dictionary = {
	"act_i": 1.0,
	"act_ii": 1.1,
	"interlude": 1.2,
	"act_iii": 1.1,
}


## Current narrative period from EventFlags story progression.
## Precedence mirrors shop_overlay act gating: later flags win.
static func get_period() -> String:
	if EventFlags.get_flag("act_iii_started"):
		return "act_iii"
	if EventFlags.get_flag("interlude_start"):
		return "interlude"
	if EventFlags.get_flag("act_ii_started"):
		return "act_ii"
	return "act_i"


## Encounter danger-increment multiplier for the current period.
static func get_danger_scale() -> float:
	return DANGER_SCALES.get(get_period(), 1.0)


## Enemy stat-table name (game/data/enemies/<name>.json) for the period.
static func get_enemy_act() -> String:
	return get_period()
