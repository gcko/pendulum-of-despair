extends Area2D
## Invisible trigger zone that fires once when the player enters.
##
## Checks a condition flag before firing. Sets a fired flag to
## prevent re-trigger. Emits signal — consumer handles response.
##
## Usage: instance trigger_zone.tscn, call initialize("boss_room", "key_obtained").

## Emitted when the trigger fires.
signal triggered(trigger_id: String)

## Unique identifier for this trigger.
var trigger_id: String = ""

## Flag that must be set for the trigger to fire. Empty = always fires.
var condition_flag: String = ""

## Whether this trigger has already fired.
var has_fired: bool = false


## Initialize the trigger with an ID and optional condition flag.
func initialize(p_trigger_id: String, p_condition_flag: String = "") -> void:
	if p_trigger_id == "":
		push_error("TriggerZone: empty trigger_id")
		return
	trigger_id = p_trigger_id
	condition_flag = p_condition_flag
	var fired_flag: String = "trigger_%s_fired" % trigger_id
	has_fired = EventFlags.get_flag(fired_flag)


func _on_body_entered(_body: Node2D) -> void:
	if trigger_id == "":
		return
	if has_fired:
		return
	if condition_flag != "" and not EventFlags.get_flag(condition_flag):
		return
	has_fired = true
	EventFlags.set_flag("trigger_%s_fired" % trigger_id, true)
	triggered.emit(trigger_id)
