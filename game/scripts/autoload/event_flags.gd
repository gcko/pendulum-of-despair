## Global event flag state management.
## Autoloaded as EventFlags.
##
## Stores 58+ numbered flags plus parameterized boss_cutscene_seen_*
## flags. Serialized as world.event_flags in save data.
## See docs/plans/technical-architecture.md Section 2.9.
class_name EventFlagsClass
extends Node

## Dictionary of all event flags. Keys are strings, values are
## bool | int | String (most are bool, council_result is int,
## reunion_order_1..4 are strings).
var flags: Dictionary = {}


## Set a flag to a value.
func set_flag(flag_name: String, value: Variant) -> void:
	flags[flag_name] = value


## Get a flag value, returning [param default] if not set.
func get_flag(flag_name: String, default: Variant = false) -> Variant:
	return flags.get(flag_name, default)


## Check if a flag exists (has been set at all).
func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name)


## Clear all flags (used when starting a new game).
func clear_all() -> void:
	flags.clear()


## Load flags from a save data dictionary.
func load_from_save(save_flags: Dictionary) -> void:
	flags = save_flags.duplicate(true)


## Export flags for save data.
func to_save_data() -> Dictionary:
	return flags.duplicate(true)
