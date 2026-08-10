class_name DialogueConsequences
extends RefCounted
## Wires a dialogue overlay's choice consequences to global state.
##
## dialogue-system.md 3.4 defines exactly two consequence types: a binary flag
## set and a numeric score increment. They travel on separate signals because
## flags overwrite while scores accumulate and clamp (3.3).
##
## Every site that pushes a DIALOGUE overlay must call [method connect_overlay]
## on it, or choices made there are silently discarded. The CUTSCENE overlay
## re-emits the same two signals and is wired by CutsceneHandler instead.


## Connect [param overlay]'s consequence signals to EventFlags. Safe to call
## more than once on the same overlay.
static func connect_overlay(overlay: Node) -> void:
	if overlay == null:
		return
	_connect(overlay, "flag_set_requested", EventFlags.set_flag)
	_connect(overlay, "score_increment_requested", EventFlags.apply_score_choice)


static func _connect(overlay: Node, sig: StringName, handler: Callable) -> void:
	if overlay.has_signal(sig) and not overlay.is_connected(sig, handler):
		overlay.connect(sig, handler)
