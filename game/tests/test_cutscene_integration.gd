extends GutTest
## Integration tests for cutscene overlay lifecycle.

const CUTSCENE_SCENE: PackedScene = preload("res://scenes/overlay/cutscene.tscn")

## Timeout for cutscene completion. Generous for headless mode.
const TIMEOUT: float = 5.0


func _entry(opts: Dictionary = {}) -> Dictionary:
	return {
		"id": opts.get("id", "t1"),
		"speaker": opts.get("speaker", ""),
		"lines": opts.get("lines", []),
		"condition": null,
		"animations": opts.get("animations", null),
		"choice": null,
		"sfx": opts.get("sfx", null),
		"flag_set": opts.get("flag_set", ""),
		"commands": opts.get("commands", null),
	}


## Helper: start cutscene and wait for it to finish (or timeout).
func _start_and_await(cs: Node, id: String, entries: Array, tier: int = 1) -> void:
	# Connect BEFORE starting to avoid missing synchronous emissions (e.g., skip flag).
	var timer: SceneTreeTimer = get_tree().create_timer(TIMEOUT)
	var finished := false
	cs.cutscene_finished.connect(func(): finished = true, CONNECT_ONE_SHOT)
	cs.start_cutscene(id, entries, tier)
	while not finished:
		await get_tree().process_frame
		if timer.time_left <= 0.0:
			break


func before_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	EventFlags.clear_all()
	GameManager.transition_data = {}
	DataManager.clear_cache()
	PartyState.initialize_new_game()


func after_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	EventFlags.clear_all()
	GameManager.transition_data = {}
	DataManager.clear_cache()
	PartyState.initialize_new_game()


# --- Scene structure tests (no start_cutscene needed) ---


func test_cutscene_scene_loads() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	assert_not_null(cs, "cutscene scene should instantiate")


func test_cutscene_has_process_mode_always() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	assert_eq(cs.process_mode, Node.PROCESS_MODE_ALWAYS)


func test_cutscene_has_required_children() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	assert_not_null(cs.get_node_or_null("LetterboxTop"))
	assert_not_null(cs.get_node_or_null("LetterboxBottom"))
	assert_not_null(cs.get_node_or_null("DialogueBox"))
	assert_not_null(cs.get_node_or_null("FadeRect"))
	assert_not_null(cs.get_node_or_null("TitleLabel"))
	assert_not_null(cs.get_node_or_null("Letterbox"))


func test_dialogue_box_is_embedded() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	var dlg: Node = cs.get_node_or_null("DialogueBox")
	assert_true(dlg.embedded_mode)


# --- Cutscene lifecycle tests ---


func test_cutscene_finished_emitted() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	watch_signals(cs)
	await _start_and_await(cs, "int_test_finish", [])
	assert_signal_emitted(cs, "cutscene_finished")


func test_flag_set_via_cutscene() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	cs.flag_set_requested.connect(func(f: String, v: Variant): EventFlags.set_flag(f, v))
	var entries := [_entry({"flag_set": "test_integration_flag"})]
	await _start_and_await(cs, "int_test_flag", entries)
	assert_true(EventFlags.get_flag("test_integration_flag"))


func test_t1_full_sequence() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	watch_signals(cs)
	var entries := [
		_entry(
			{"commands": [{"type": "fade", "direction": "out", "duration": 0.02, "when": "before"}]}
		),
		_entry(
			{"commands": [{"type": "fade", "direction": "in", "duration": 0.02, "when": "before"}]}
		),
	]
	await _start_and_await(cs, "int_test_t1", entries, 1)
	assert_signal_emitted(cs, "cutscene_finished")


func test_t4_micro_sequence() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	watch_signals(cs)
	var entries := [
		_entry(
			{
				"commands":
				[{"type": "move", "who": "edren", "to": [10, 10], "speed": 80, "when": "before"}]
			}
		)
	]
	await _start_and_await(cs, "int_test_t4", entries, 4)
	assert_signal_emitted(cs, "cutscene_finished")
	var top: ColorRect = cs.get_node_or_null("LetterboxTop")
	assert_eq(top.custom_minimum_size.y, 0.0, "T4 should not show letterbox")


func test_skip_flag_persists() -> void:
	var cs1: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs1)
	await _start_and_await(cs1, "int_persist", [])
	assert_true(EventFlags.get_flag("cutscene_seen_int_persist"))
	var cs2: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs2)
	watch_signals(cs2)
	await _start_and_await(cs2, "int_persist", [_entry({"lines": ["Should skip"]})])
	assert_signal_emitted(cs2, "cutscene_finished")


func test_sequential_cutscenes() -> void:
	var cs1: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs1)
	watch_signals(cs1)
	await _start_and_await(cs1, "int_seq_1", [])
	assert_signal_emitted(cs1, "cutscene_finished")
	var cs2: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs2)
	watch_signals(cs2)
	await _start_and_await(cs2, "int_seq_2", [])
	assert_signal_emitted(cs2, "cutscene_finished")


func test_move_signal_emitted_to_listener() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	watch_signals(cs)
	var entries := [
		_entry(
			{
				"commands":
				[{"type": "move", "who": "edren", "to": [100, 100], "speed": 80, "when": "before"}]
			}
		)
	]
	await _start_and_await(cs, "int_move", entries)
	assert_signal_emitted(cs, "cutscene_move_requested")


func test_unknown_entity_does_not_crash() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	watch_signals(cs)
	var entries := [
		_entry(
			{
				"commands":
				[
					{
						"type": "move",
						"who": "nonexistent_character",
						"to": [10, 10],
						"speed": 80,
						"when": "before"
					}
				]
			}
		)
	]
	await _start_and_await(cs, "int_unknown", entries)
	assert_signal_emitted(cs, "cutscene_finished")


func test_music_signal_not_crash_when_unconnected() -> void:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	watch_signals(cs)
	var entries := [
		_entry(
			{
				"commands":
				[{"type": "music", "track_id": "boss", "action": "play", "when": "before"}]
			}
		)
	]
	await _start_and_await(cs, "int_music", entries)
	assert_signal_emitted(cs, "cutscene_finished")
	assert_signal_emitted(cs, "cutscene_music_requested")
