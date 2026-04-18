extends GutTest
## Tests for cutscene failure and edge case paths.
## Covers: overlay push failure recovery, missing dialogue data,
## and cutscene double-fire prevention.

const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")


func before_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
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
	DataManager.clear_cache()


func after_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
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
	DataManager.clear_cache()


func _create_exploration_test_room() -> Node2D:
	GameManager.transition_data = {}
	var exp_node: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp_node)
	exp_node.load_map("test_room")
	return exp_node


# --- 1. _start_pending_cutscene overlay push failure clears return data ---
func test_start_pending_cutscene_failure_clears_return() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	# Set up cutscene return data
	exp_node.set_cutscene_return({"map": "test_room", "spawn": "PlayerSpawn"})
	# Push an overlay to block the cutscene overlay push
	GameManager.push_overlay(GameManager.OverlayState.MENU)
	# Try to start a pending cutscene — should fail because overlay is occupied
	var typed_entries: Array[Dictionary] = []
	exp_node._start_pending_cutscene("test_cutscene", typed_entries, 1)
	assert_push_error_count(1, "overlay push failure should log error")
	# Return data should be cleared after failure recovery
	assert_true(
		exp_node.get_cutscene_return().is_empty(),
		"cutscene_return should be cleared after overlay push failure"
	)
	GameManager.pop_overlay()


# --- 2. _start_pending_cutscene failure with return map triggers transition ---
func test_start_pending_cutscene_failure_triggers_return_transition() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	exp_node.set_cutscene_return({"map": "test_room_2", "spawn": "from_cutscene"})
	# Block overlay
	GameManager.push_overlay(GameManager.OverlayState.MENU)
	var typed_entries: Array[Dictionary] = []
	exp_node._start_pending_cutscene("fail_test", typed_entries, 1)
	assert_push_error_count(1, "overlay push failure should log error")
	# After failure, _transitioning should be true (return transition started)
	assert_true(
		exp_node.is_transitioning(),
		"should start return transition after overlay push failure with return map"
	)
	GameManager.pop_overlay()


# --- 3. Cutscene trigger with missing dialogue data does not crash ---
func test_cutscene_trigger_missing_dialogue_no_crash() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	# Create a fake Area2D trigger with a nonexistent scene_id
	var area: Area2D = Area2D.new()
	add_child_autofree(area)
	area.set_meta("cutscene_scene_id", "nonexistent_scene_999")
	area.set_meta("flag", "")
	area.set_meta("required_flag", "")
	area.set_meta("cutscene_map_id", "")
	area.set_meta("cutscene_return_map", "")
	area.set_meta("cutscene_return_spawn", "PlayerSpawn")
	# Should not crash — just logs error and returns
	exp_node._on_cutscene_trigger_entered(exp_node.get_player(), area)
	assert_push_error_count(1, "missing dialogue should log error")
	assert_false(
		exp_node.is_in_cutscene(), "should not enter cutscene state with missing dialogue data"
	)


# --- 4. Cutscene trigger with empty entries does not crash ---
func test_cutscene_trigger_empty_entries_no_crash() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	# Set pending cutscene with empty entries, then load a map to consume it.
	# The deferred _start_pending_cutscene fires with empty entries — verify
	# the pending dict is consumed synchronously during load_map and that
	# the deferred call handles empty entries without crashing.
	exp_node.set_pending_cutscene({"id": "empty_test", "entries": [], "tier": 1})
	exp_node.load_map("test_room")
	# Pending cutscene should be consumed (cleared) even with empty entries
	assert_true(
		exp_node.get_pending_cutscene().is_empty(),
		"pending cutscene should be consumed after load_map"
	)
	# Flush the deferred _start_pending_cutscene call so it doesn't leak
	await get_tree().process_frame


# --- 5. Cutscene double-fire prevention via flag ---
func test_cutscene_double_fire_prevented_by_flag() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	var area: Area2D = Area2D.new()
	add_child_autofree(area)
	area.set_meta("cutscene_scene_id", "dawn_march")
	area.set_meta("flag", "dawn_march_seen")
	area.set_meta("required_flag", "")
	area.set_meta("cutscene_map_id", "")
	area.set_meta("cutscene_return_map", "")
	area.set_meta("cutscene_return_spawn", "PlayerSpawn")
	# Pre-set the flag to simulate having already seen the cutscene
	EventFlags.set_flag("dawn_march_seen", true)
	# Trigger should be blocked by the flag — returns early without any errors
	exp_node._on_cutscene_trigger_entered(exp_node.get_player(), area)
	assert_false(exp_node.is_in_cutscene(), "trigger should be blocked by one-shot flag")


# --- 6. Cutscene trigger blocked during transition ---
func test_cutscene_trigger_blocked_during_transition() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	exp_node.set_transitioning(true)
	var area: Area2D = Area2D.new()
	add_child_autofree(area)
	area.set_meta("cutscene_scene_id", "dawn_march")
	area.set_meta("flag", "")
	area.set_meta("required_flag", "")
	area.set_meta("cutscene_map_id", "")
	area.set_meta("cutscene_return_map", "")
	area.set_meta("cutscene_return_spawn", "PlayerSpawn")
	exp_node._on_cutscene_trigger_entered(exp_node.get_player(), area)
	assert_false(exp_node.is_in_cutscene(), "cutscene trigger should be blocked during transition")


# --- 7. Cutscene trigger blocked while already in cutscene ---
func test_cutscene_trigger_blocked_while_in_cutscene() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	exp_node.set_in_cutscene(true)
	var area: Area2D = Area2D.new()
	add_child_autofree(area)
	area.set_meta("cutscene_scene_id", "dawn_march")
	area.set_meta("flag", "")
	area.set_meta("required_flag", "")
	area.set_meta("cutscene_map_id", "")
	area.set_meta("cutscene_return_map", "")
	area.set_meta("cutscene_return_spawn", "PlayerSpawn")
	exp_node._on_cutscene_trigger_entered(exp_node.get_player(), area)
	# Should remain in the existing cutscene state, not start another
	assert_true(exp_node.is_in_cutscene(), "should stay in existing cutscene")


# --- 8. Cutscene trigger with required_flag not set is blocked ---
func test_cutscene_trigger_blocked_by_required_flag() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	var area: Area2D = Area2D.new()
	add_child_autofree(area)
	area.set_meta("cutscene_scene_id", "dawn_march")
	area.set_meta("flag", "")
	area.set_meta("required_flag", "some_prerequisite")
	area.set_meta("cutscene_map_id", "")
	area.set_meta("cutscene_return_map", "")
	area.set_meta("cutscene_return_spawn", "PlayerSpawn")
	# required_flag not set — should block
	exp_node._on_cutscene_trigger_entered(exp_node.get_player(), area)
	assert_false(
		exp_node.is_in_cutscene(), "cutscene should be blocked when required_flag is not set"
	)


# --- 9. Empty flag_name in flag_set_requested is rejected ---
func test_empty_flag_name_rejected() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	# Directly invoke the cutscene handler's flag_set callback with empty name
	var handler: CutsceneHandler = exp_node._get_cutscene_handler()
	handler._on_cutscene_flag_set("", true)
	# EventFlags should NOT contain an empty-string key
	assert_false(
		EventFlags.has_flag(""), "empty flag_name should be rejected and not stored in EventFlags"
	)


# --- 10. _in_cutscene stays true for one frame after cutscene finished (race guard) ---
func test_in_cutscene_deferred_clear_blocks_transitions() -> void:
	var exp_node: Node2D = _create_exploration_test_room()
	# Simulate being in a cutscene
	exp_node.set_in_cutscene(true)
	# Call _on_cutscene_finished via the handler — this defers set_in_cutscene(false)
	var handler: CutsceneHandler = exp_node._get_cutscene_handler()
	handler._on_cutscene_finished()
	# BEFORE the deferred call fires, _in_cutscene should still be true
	# This blocks any pending Area2D overlaps from triggering transitions
	assert_true(
		exp_node.is_in_cutscene(),
		"_in_cutscene should stay true until deferred clear fires (race guard)"
	)
	# After processing one frame, the deferred call fires and clears the flag
	await get_tree().process_frame
	assert_false(exp_node.is_in_cutscene(), "_in_cutscene should be false after deferred clear")
