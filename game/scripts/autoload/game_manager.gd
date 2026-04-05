extends Node
## Game state machine, scene transitions, and pause management.
## Autoloaded as GameManager.
##
## Architecture: 3 core states (full scene swap) + 4 overlay states
## (additive layer). See docs/plans/technical-architecture.md Section 3.

signal core_state_changed(new_state: CoreState)
signal overlay_state_changed(new_state: OverlayState)

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

enum CoreState { TITLE, EXPLORATION, BATTLE }
enum OverlayState { NONE, MENU, DIALOGUE, SAVE_LOAD, CUTSCENE }

## Current active states.
var current_core: CoreState = CoreState.TITLE
var current_overlay: OverlayState = OverlayState.NONE

## Reference to the active overlay scene node (null if no overlay).
var overlay_node: Node = null

## Data passed between state transitions.
## Overwritten on each change_core_state call. Receiving scene reads in _ready().
## Keys vary by transition — see technical-architecture.md Section 3.3.
var transition_data: Dictionary = {}


## Swap to a new core state (full scene replacement).
## [param data] is stored in [member transition_data] for the new scene.
func change_core_state(new_state: CoreState, data: Dictionary = {}) -> void:
	# Clear any active overlay first
	if current_overlay != OverlayState.NONE:
		pop_overlay()

	if not CORE_SCENES.has(new_state):
		push_error("GameManager: Unknown core state: %s" % new_state)
		return
	var scene_path: String = CORE_SCENES[new_state]
	if not ResourceLoader.exists(scene_path):
		push_error("GameManager: Scene not found: %s" % scene_path)
		return

	var old_data: Dictionary = transition_data
	transition_data = data
	var err: Error = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("GameManager: Failed to change scene to %s (error %d)" % [scene_path, err])
		transition_data = old_data
		return
	current_core = new_state
	core_state_changed.emit(new_state)


## Push an overlay scene on top of the current core state.
## Returns false if an overlay is already active (rejected).
## Exception: CUTSCENE can force-close DIALOGUE.
func push_overlay(state: OverlayState) -> bool:
	if not OVERLAY_SCENES.has(state):
		push_error("GameManager: Invalid overlay state: %s" % state)
		return false

	if current_overlay != OverlayState.NONE:
		if state == OverlayState.CUTSCENE and current_overlay == OverlayState.DIALOGUE:
			pop_overlay()  # Cutscene takes priority over dialogue
		else:
			return false

	var scene_path: String = OVERLAY_SCENES[state]
	if not ResourceLoader.exists(scene_path):
		push_error("GameManager: Overlay scene not found: %s" % scene_path)
		return false
	var resource: Resource = load(scene_path)
	if not resource is PackedScene:
		push_error("GameManager: Failed to load overlay: %s" % scene_path)
		return false

	get_tree().paused = true
	current_overlay = state
	var scene: Node = (resource as PackedScene).instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(scene)
	overlay_node = scene
	overlay_state_changed.emit(state)
	return true


## Remove the active overlay and unpause the core state.
func pop_overlay() -> void:
	if overlay_node:
		overlay_node.queue_free()
		overlay_node = null
	current_overlay = OverlayState.NONE
	overlay_state_changed.emit(OverlayState.NONE)
	get_tree().paused = false
