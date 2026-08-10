extends Node
## Global event flag state management.
## Autoloaded as EventFlags.
##
## Stores 58+ numbered flags plus parameterized boss_cutscene_seen_*
## flags. Serialized as world.event_flags in save data.
## See docs/plans/technical-architecture.md Section 2.9.

signal flag_changed(flag_name: String, value: Variant)

## Documented ranges for the hidden approval scores, as (min, max).
## Sourced from docs/story/events.md flags 40–43; dialogue-system.md 3.3
## requires clamp(score, min, max) after each increment.
const SCORE_RANGES: Dictionary = {
	"council_savanh_approval": Vector2i(0, 3),
	"council_caden_approval": Vector2i(0, 3),
	"council_wynne_approval": Vector2i(0, 3),
	"council_result": Vector2i(0, 3),
}

## Bounds used for a score events.md does not document yet.
const SCORE_RANGE_DEFAULT: Vector2i = Vector2i(0, 3)

## Dictionary of all event flags. Keys are strings, values are
## bool | int | String (most are bool, council_result is int,
## reunion_order_1..4 are strings).
var _flags: Dictionary = {}


## Set a flag to a value. Emits flag_changed.
func set_flag(flag_name: String, value: Variant) -> void:
	if flag_name.is_empty():
		if OS.is_debug_build():
			push_warning("EventFlags: attempted to set empty flag_name")
		return
	_flags[flag_name] = value
	flag_changed.emit(flag_name, value)


## Get a flag value, returning [param default] if not set.
func get_flag(flag_name: String, default: Variant = false) -> Variant:
	return _flags.get(flag_name, default)


## Bounds for a named score, as (min, max). Unknown names fall back to
## [constant SCORE_RANGE_DEFAULT] and warn in debug builds — dialogue-system.md
## 3.4 requires every score to be documented in events.md.
func get_score_range(score_name: String) -> Vector2i:
	if SCORE_RANGES.has(score_name):
		return SCORE_RANGES[score_name]
	if OS.is_debug_build():
		push_warning(
			(
				"EventFlags: score '%s' is not documented in events.md — clamping to %s"
				% [score_name, SCORE_RANGE_DEFAULT]
			)
		)
	return SCORE_RANGE_DEFAULT


## Add [param delta] to a named score and clamp the total to
## [param min_value]..[param max_value]. Scores accumulate across the several
## questions that feed them, so this adds rather than overwrites — see
## dialogue-system.md 3.3/3.4. An unset score starts at its minimum.
## Returns the stored total.
func increment_score(score_name: String, delta: int, min_value: int, max_value: int) -> int:
	if score_name.is_empty():
		if OS.is_debug_build():
			push_warning("EventFlags: attempted to increment an empty score name")
		return 0
	var lower: int = mini(min_value, max_value)
	var upper: int = maxi(min_value, max_value)
	var current: Variant = _flags.get(score_name, lower)
	var base: int = int(current) if (current is int or current is float) else lower
	var total: int = clampi(base + delta, lower, upper)
	_flags[score_name] = total
	flag_changed.emit(score_name, total)
	return total


## Apply a dialogue choice's score delta using the range documented for that
## score. This is the path score choices take; callers with an explicit range
## can use [method increment_score] directly. Returns the stored total.
func apply_score_choice(score_name: String, delta: int) -> int:
	var bounds: Vector2i = get_score_range(score_name)
	return increment_score(score_name, delta, bounds.x, bounds.y)


## Check if a flag exists (has been set at all).
func has_flag(flag_name: String) -> bool:
	return _flags.has(flag_name)


## Clear all flags (used when starting a new game).
func clear_all() -> void:
	_flags.clear()


## Load flags from a save data dictionary.
func load_from_save(save_flags: Dictionary) -> void:
	_flags = save_flags.duplicate(true)


## Check a comma-separated list of required flags. Returns true only when
## every non-empty flag in [param flags_csv] is satisfied.  An empty string
## is treated as "no requirements" and returns true.
## Boolean flags must be truthy (set_flag("x", false) does NOT satisfy).
## Non-boolean flags (int, String) satisfy if the key exists, so
## council_result=0 and reunion_order_1="edren" both pass.
func check_required_flags(flags_csv: String) -> bool:
	if flags_csv.is_empty():
		return true
	for rf: String in flags_csv.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not has_flag(trimmed):
			return false
		var val: Variant = get_flag(trimmed)
		if val is bool and not val:
			return false
	return true


## Export flags for save data.
func to_save_data() -> Dictionary:
	return _flags.duplicate(true)
