class_name TestHelpers
extends RefCounted
## Shared test helpers for overlay state management and common setup.


## Set up overlay state for testing. Uses push_overlay when possible,
## falls back to direct assignment when overlay scenes are unavailable.
static func setup_overlay_state(state: GameManager.OverlayState) -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	if state == GameManager.OverlayState.NONE:
		return
	if not GameManager.push_overlay(state):
		# Scene not available in test env — simulate directly
		GameManager.current_overlay = state
		GameManager.get_tree().paused = true


## Clean up overlay state after a test.
static func teardown_overlay() -> void:
	if GameManager.overlay_node != null:
		GameManager.overlay_node.queue_free()
		GameManager.overlay_node = null
	GameManager.current_overlay = GameManager.OverlayState.NONE
	GameManager.get_tree().paused = false


## Reset common game state for test isolation.
static func reset_game_state() -> void:
	teardown_overlay()
	GameManager.cutscene_active = false
	GameManager.transition_data = {}
	EventFlags.clear_all()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.gold = 0
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	PartyState.is_at_save_point = false
