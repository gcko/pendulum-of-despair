extends GutTest
## Tests for NPC entity with priority stack dialogue resolution.

const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")


func after_each() -> void:
	EventFlags.clear_all()


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


# --- Condition Evaluation ---


func test_evaluate_condition_null() -> void:
	var npc = _create_npc()
	assert_true(npc._evaluate_condition(null), "null should return true")


func test_evaluate_condition_empty() -> void:
	var npc = _create_npc()
	assert_true(npc._evaluate_condition(""), "empty should return true")


func test_evaluate_condition_flag_set() -> void:
	var npc = _create_npc()
	EventFlags.set_flag("test_flag", true)
	assert_true(npc._evaluate_condition("test_flag"), "set flag should return true")


func test_evaluate_condition_flag_unset() -> void:
	var npc = _create_npc()
	assert_false(npc._evaluate_condition("unset_flag"), "unset flag should return false")


func test_evaluate_condition_and_both_true() -> void:
	var npc = _create_npc()
	EventFlags.set_flag("flag_a", true)
	EventFlags.set_flag("flag_b", true)
	assert_true(npc._evaluate_condition("flag_a AND flag_b"), "both true should return true")


func test_evaluate_condition_and_one_false() -> void:
	var npc = _create_npc()
	EventFlags.set_flag("flag_a", true)
	assert_false(
		npc._evaluate_condition("flag_a AND flag_missing"),
		"one false should return false",
	)


func test_evaluate_condition_party_has_stubbed() -> void:
	var npc = _create_npc()
	assert_false(
		npc._evaluate_condition("party_has(torren)"),
		"party_has should return false (stubbed)",
	)


func test_evaluate_condition_numeric_comparison() -> void:
	var npc = _create_npc()
	EventFlags.set_flag("score", 3)
	assert_true(npc._evaluate_condition("score >= 2"), "3 >= 2 should be true")
	assert_false(npc._evaluate_condition("score >= 5"), "3 >= 5 should be false")
