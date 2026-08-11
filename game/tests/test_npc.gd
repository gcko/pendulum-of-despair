extends GutTest
## Tests for NPC entity with priority stack dialogue resolution.

const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")
const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


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
	# Without flag: should start on the FIRST default (GAP-042 — the defaults
	# take turns instead of collapsing to the last one).
	var result_no_flag: Dictionary = npc.get_current_dialogue()
	assert_eq(
		result_no_flag.get("id"),
		"default_001",
		"without flag should start on the first default",
	)
	# With flag: should return conditioned entry
	EventFlags.set_flag("late_game_flag", true)
	var result_with_flag: Dictionary = npc.get_current_dialogue()
	assert_eq(
		result_with_flag.get("id"),
		"flagged_001",
		"with flag should return conditioned entry",
	)


# --- Multi-default cycling (GAP-042) ---


func _served_ids(npc, times: int) -> Array:
	var ids: Array = []
	npc.npc_interacted.connect(func(_id: String, data: Dictionary): ids.append(data.get("id")))
	for _i: int in range(times):
		npc.interact()
	return ids


func test_all_defaults_are_reachable_across_interactions() -> void:
	var npc = _create_npc()
	npc.npc_id = "test_cycle_npc"
	npc.dialogue_entries = [
		{"id": "default_001", "condition": null, "lines": ["one"]},
		{"id": "default_002", "condition": null, "lines": ["two"]},
		{"id": "default_003", "condition": null, "lines": ["three"]},
	]
	var ids: Array = _served_ids(npc, 4)
	assert_eq(
		ids,
		["default_001", "default_002", "default_003", "default_001"],
		"every default should be reachable, wrapping after the last",
	)


func test_real_multi_default_npc_reaches_every_line() -> void:
	# npc_bren.json ships three distinct unconditioned topics; before GAP-042
	# only npc_bren_003 was ever reachable in Act I.
	var npc = _create_npc()
	npc.initialize("bren")
	var defaults: Array = DialogueCondition.resolve_stack(npc.dialogue_entries)
	assert_gt(defaults.size(), 1, "bren should have more than one default line")
	var ids: Array = _served_ids(npc, defaults.size())
	assert_eq(ids.size(), defaults.size(), "one line served per interaction")
	var unique: Dictionary = {}
	for id: Variant in ids:
		unique[id] = true
	assert_eq(unique.size(), defaults.size(), "each default should be served exactly once")


func test_cycle_survives_a_map_reload() -> void:
	var first = _create_npc()
	first.npc_id = "persistent_npc"
	first.dialogue_entries = [
		{"id": "default_001", "condition": null, "lines": ["one"]},
		{"id": "default_002", "condition": null, "lines": ["two"]},
	]
	assert_eq(_served_ids(first, 1), ["default_001"], "first interaction serves the first line")
	# A new node with the same npc_id stands in for re-entering the map.
	var second = _create_npc()
	second.npc_id = "persistent_npc"
	second.dialogue_entries = first.dialogue_entries
	assert_eq(
		_served_ids(second, 1), ["default_002"], "the cursor is session state, not node state"
	)


func test_conditioned_entry_does_not_advance_the_cycle() -> void:
	var npc = _create_npc()
	npc.npc_id = "test_gated_npc"
	npc.dialogue_entries = [
		{"id": "gated", "condition": "late_game_flag", "lines": ["late"]},
		{"id": "default_001", "condition": null, "lines": ["one"]},
		{"id": "default_002", "condition": null, "lines": ["two"]},
	]
	EventFlags.set_flag("late_game_flag", true)
	assert_eq(_served_ids(npc, 2), ["gated", "gated"], "a matched condition repeats, per 3.2")
	EventFlags.set_flag("late_game_flag", false)
	assert_eq(
		npc.get_current_dialogue().get("id"),
		"default_001",
		"the ambient cursor should not have moved while the condition held",
	)


func test_reset_dialogue_cycles_returns_to_the_first_default() -> void:
	var npc = _create_npc()
	npc.npc_id = "test_reset_npc"
	npc.dialogue_entries = [
		{"id": "default_001", "condition": null, "lines": ["one"]},
		{"id": "default_002", "condition": null, "lines": ["two"]},
	]
	npc.interact()
	assert_eq(npc.get_current_dialogue().get("id"), "default_002", "cursor advanced")
	NPC.reset_dialogue_cycles()
	assert_eq(
		npc.get_current_dialogue().get("id"),
		"default_001",
		"a new game or load should restart the rotation",
	)


func test_continue_from_title_resets_the_ambient_cursor() -> void:
	# Title -> Continue applies the save inside exploration rather than through
	# SaveManager, so that path has to reset the cursors too.
	var npc = _create_npc()
	npc.npc_id = "test_continue_npc"
	npc.dialogue_entries = [
		{"id": "default_001", "condition": null, "lines": ["one"]},
		{"id": "default_002", "condition": null, "lines": ["two"]},
	]
	npc.interact()
	assert_eq(npc.get_current_dialogue().get("id"), "default_002", "cursor advanced")
	GameManager.transition_data = {
		"save_slot": 1,
		"save_data": {"world": {"current_location": "test_room"}},
	}
	var exp: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	assert_eq(
		npc.get_current_dialogue().get("id"),
		"default_001",
		"loading a save should restart every NPC's rotation",
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
