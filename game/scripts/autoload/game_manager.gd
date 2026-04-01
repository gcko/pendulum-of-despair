class_name GameManagerClass
extends Node
## Game state machine, scene transitions, and pause management.
## Autoloaded as GameManager.
##
## Architecture: 3 core states (full scene swap) + 4 overlay states
## (additive layer). See docs/plans/technical-architecture.md Section 3.

signal core_state_changed(new_state: CoreState)
signal overlay_state_changed(new_state: OverlayState)

enum CoreState { TITLE, EXPLORATION, BATTLE }
enum OverlayState { NONE, MENU, DIALOGUE, SAVE_LOAD, CUTSCENE }

## Scene file paths for core states.
const CORE_SCENES: Dictionary = {
	CoreState.TITLE: "res://scenes/core/title.tscn",
	CoreState.EXPLORATION: "res://scenes/core/exploration.tscn",
	CoreState.BATTLE: "res://scenes/core/battle.tscn",
}

## Scene file paths for overlay states.
const OVERLAY_SCENES: Dictionary = {
	OverlayState.MENU: "res://scenes/overlay/menu.tscn",
	OverlayState.DIALOGUE: "res://scenes/overlay/dialogue.tscn",
	OverlayState.SAVE_LOAD: "res://scenes/overlay/save_load.tscn",
	OverlayState.CUTSCENE: "res://scenes/overlay/cutscene.tscn",
}

## Current active states.
var current_core: CoreState = CoreState.TITLE
var current_overlay: OverlayState = OverlayState.NONE

## Reference to the active overlay scene node (null if no overlay).
var overlay_node: Node = null

## Data passed between state transitions.
## The receiving scene reads this in _ready() then clears it.
## Keys vary by transition — see technical-architecture.md Section 3.3.
var transition_data: Dictionary = {}


## Swap to a new core state (full scene replacement).
## [param data] is stored in [member transition_data] for the new scene.
func change_core_state(new_state: CoreState, data: Dictionary = {}) -> void:
	# Clear any active overlay first
	if current_overlay != OverlayState.NONE:
		pop_overlay()

	transition_data = data
	current_core = new_state
	core_state_changed.emit(new_state)

	var scene_path: String = CORE_SCENES[new_state]
	get_tree().change_scene_to_file(scene_path)


## Push an overlay scene on top of the current core state.
## Returns false if an overlay is already active (rejected).
## Exception: CUTSCENE can force-close DIALOGUE.
func push_overlay(state: OverlayState) -> bool:
	if current_overlay != OverlayState.NONE:
		if state == OverlayState.CUTSCENE and current_overlay == OverlayState.DIALOGUE:
			pop_overlay()  # Cutscene takes priority over dialogue
		else:
			return false

	get_tree().paused = true
	current_overlay = state
	overlay_state_changed.emit(state)

	var scene_path: String = OVERLAY_SCENES[state]
	var scene: Node = load(scene_path).instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(scene)
	overlay_node = scene
	return true


## Remove the active overlay and unpause the core state.
func pop_overlay() -> void:
	if overlay_node:
		overlay_node.queue_free()
		overlay_node = null
	current_overlay = OverlayState.NONE
	overlay_state_changed.emit(OverlayState.NONE)
	get_tree().paused = false
