extends GutTest
## Tests for NPC entity with priority stack dialogue resolution.

const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")


func after_each() -> void:
	EventFlags.clear_all()
	PartyState.members.clear()


func _create_npc():
	var npc = NPC_SCENE.instantiate()
	add_child_autofree(npc)
	return npc


# --- Initialization ---


func test_initialize_loads_dialogue() -> void:
	var npc = _create_npc()
	npc.initialize("bren")
	assert_eq(npc.npc_id, "bren", "npc_id should be set")
	assert_false(npc.dialogue_entries.is_empty(), "dialogue entries should be loaded")


func test_initialize_empty_id_blocked() -> void:
	var npc = _create_npc()
	npc.initialize("")
	assert_eq(npc.npc_id, "", "npc_id should remain empty")
	assert_true(npc.dialogue_entries.is_empty(), "no dialogue should load")
	assert_push_error_count(1, "empty npc_id should trigger push_error")


# --- Interaction ---


func test_interact_emits_signal() -> void:
	var npc = _create_npc()
	npc.initialize("bren")
	watch_signals(npc)
	npc.interact()
	assert_signal_emitted(npc, "npc_interacted", "should emit npc_interacted")


func test_interact_before_init_blocked() -> void:
	var npc = _create_npc()
	watch_signals(npc)
	npc.interact()
	assert_signal_not_emitted(npc, "npc_interacted", "should not emit before init")


func test_interact_signal_carries_data() -> void:
	var npc = _create_npc()
	npc.initialize("bren")
	watch_signals(npc)
	npc.interact()
	var params: Array = get_signal_parameters(npc, "npc_interacted", 0)
	assert_eq(params[0], "bren", "signal should carry npc_id")
	assert_true(params[1] is Dictionary, "signal should carry dialogue dict")
	assert_true(params[1].has("id"), "dialogue should have id field")


# --- Priority Stack ---


func test_get_current_dialogue_default() -> void:
	var npc = _create_npc()
	# Construct dialogue with a conditioned entry + null-condition default
	npc.npc_id = "test_npc"
	npc.dialogue_entries = [
		{"id": "test_001", "condition": "some_flag", "lines": ["conditioned"]},
		{"id": "test_002", "condition": null, "lines": ["default"]},
	]
	var result: Dictionary = npc.get_current_dialogue()
	assert_eq(result.get("id"), "test_002", "should return default entry")


func test_get_current_dialogue_with_flag() -> void:
	var npc = _create_npc()
	npc.npc_id = "test_npc"
	npc.dialogue_entries = [
		{"id": "test_001", "condition": "quest_complete", "lines": ["done!"]},
		{"id": "test_002", "condition": null, "lines": ["default"]},
	]
	EventFlags.set_flag("quest_complete", true)
	var result: Dictionary = npc.get_current_dialogue()
	assert_eq(result.get("id"), "test_001", "should return flagged entry")


func test_get_current_dialogue_null_before_conditioned() -> void:
	# Regression: real NPC data has null-condition entries BEFORE conditioned ones.
	# The priority stack must still check conditioned entries when their flags are set.
	var npc = _create_npc()
	npc.npc_id = "test_npc"
	npc.dialogue_entries = [
		{"id": "default_001", "condition": null, "lines": ["default first"]},
		{"id": "default_002", "condition": null, "lines": ["default second"]},
		{"id": "flagged_001", "condition": "late_game_flag", "lines": ["late game"]},
	]
	# Without flag: should return last null-condition entry (fallback)
	var result_no_flag: Dictionary = npc.get_current_dialogue()
	assert_eq(
		result_no_flag.get("id"),
		"default_002",
		"without flag should return last default",
	)
	# With flag: should return conditioned entry
	EventFlags.set_flag("late_game_flag", true)
	var result_with_flag: Dictionary = npc.get_current_dialogue()
	assert_eq(
		result_with_flag.get("id"),
		"flagged_001",
		"with flag should return conditioned entry",
	)


# --- Condition Evaluation ---
# The expression evaluator itself now lives in DialogueCondition and is
# covered by test_dialogue_conditions.gd. What matters here is that the NPC
# resolver actually consults it.


func test_resolver_uses_shared_condition_evaluator() -> void:
	var npc = _create_npc()
	npc.npc_id = "test_npc"
	npc.dialogue_entries = [
		{"id": "party_line", "condition": "party_has(torren)", "lines": ["Torren!"]},
		{"id": "default_line", "condition": null, "lines": ["default"]},
	]
	assert_eq(
		npc.get_current_dialogue().get("id"),
		"default_line",
		"party_has should be false with an empty party",
	)
	PartyState.add_member("torren")
	assert_eq(
		npc.get_current_dialogue().get("id"),
		"party_line",
		"party_has should be honoured through DialogueCondition",
	)
	PartyState.members.clear()
