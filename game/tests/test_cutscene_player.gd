extends GutTest
## Unit tests for cutscene_player.gd sequencer.

const CUTSCENE_SCENE: PackedScene = preload("res://scenes/overlay/cutscene.tscn")


func _create_cutscene() -> Node:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	# Allow _ready and @onready to resolve
	await get_tree().process_frame
	return cs


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


# --- 1. Empty entries emits cutscene_finished ---
func test_empty_entries_emits_finished() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	cs.start_cutscene("empty_test", [], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_finished")


# --- 2. Skip flag skips cutscene ---
func test_skip_flag_skips_cutscene() -> void:
	EventFlags.set_flag("cutscene_seen_skip_test", true)
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	cs.start_cutscene("skip_test", [_entry()], cs.TIER_MICRO)
	await get_tree().process_frame
	assert_signal_emitted(cs, "cutscene_finished")


# --- 3. Skip flag set on completion ---
func test_skip_flag_set_on_completion() -> void:
	var cs: Node = await _create_cutscene()
	cs.start_cutscene("flag_test", [], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_true(
		EventFlags.get_flag("cutscene_seen_flag_test"), "skip flag should be set after completion"
	)


# --- 4. T1 shows letterbox (node exists, no crash) ---
func test_t1_letterbox_exists() -> void:
	var cs: Node = await _create_cutscene()
	var lb: Node = cs.get_node_or_null("Letterbox")
	assert_not_null(lb, "Letterbox node should exist")


# --- 5. T4 no letterbox (LetterboxTop stays at 0) ---
func test_t4_no_letterbox() -> void:
	var cs: Node = await _create_cutscene()
	cs.start_cutscene("t4_test", [], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	var top: ColorRect = cs.get_node_or_null("LetterboxTop")
	assert_not_null(top, "LetterboxTop should exist")
	if top:
		assert_eq(top.custom_minimum_size.y, 0.0, "T4 should not animate letterbox")


# --- 6. Move command emits cutscene_move_requested ---
func test_move_command_emits_signal() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {
		"type": "move",
		"who": "npc_guard",
		"to": [100, 200],
		"speed": 60.0,
		"when": "before",
	}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("move_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_move_requested")


# --- 7. Camera command emits cutscene_camera_requested ---
func test_camera_command_emits_signal() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {"type": "camera", "target": [50, 100], "duration": 1.0, "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("cam_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_camera_requested")


# --- 8. Shake command emits cutscene_shake_requested ---
func test_shake_command_emits_signal() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {"type": "shake", "intensity": 3, "duration": 0.5, "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("shake_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_shake_requested")


# --- 9. Shake skipped with reduce_motion config ---
func test_shake_skipped_with_reduce_motion() -> void:
	var cs: Node = await _create_cutscene()
	cs._config = {"reduce_motion": true}
	watch_signals(cs)
	var cmd: Dictionary = {"type": "shake", "intensity": 3, "duration": 0.5, "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("shake_rm_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_not_emitted(cs, "cutscene_shake_requested")


# --- 10. Music command emits cutscene_music_requested ---
func test_music_command_emits_signal() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {
		"type": "music",
		"track_id": "boss_theme",
		"action": "play",
		"when": "before",
	}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("music_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_music_requested")


# --- 11. Fade out tweens FadeRect alpha to 1 ---
func test_fade_out_tweens_alpha_to_one() -> void:
	var cs: Node = await _create_cutscene()
	var cmd: Dictionary = {"type": "fade", "direction": "out", "duration": 0.05, "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("fade_out_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	var fade: ColorRect = cs.get_node_or_null("FadeRect")
	assert_not_null(fade, "FadeRect should exist")
	if fade:
		assert_almost_eq(fade.modulate.a, 1.0, 0.05, "FadeRect alpha should be ~1.0 after fade out")


# --- 12. Fade in tweens FadeRect alpha to 0 ---
func test_fade_in_tweens_alpha_to_zero() -> void:
	var cs: Node = await _create_cutscene()
	var fade: ColorRect = cs.get_node_or_null("FadeRect")
	if fade:
		fade.modulate.a = 1.0
	var cmd: Dictionary = {"type": "fade", "direction": "in", "duration": 0.05, "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("fade_in_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	if fade:
		assert_almost_eq(fade.modulate.a, 0.0, 0.05, "FadeRect alpha should be ~0.0 after fade in")


# --- 13. Fade sets color (non-black) ---
func test_fade_sets_color() -> void:
	var cs: Node = await _create_cutscene()
	var cmd: Dictionary = {
		"type": "fade",
		"direction": "out",
		"color": "white",
		"duration": 0.05,
		"when": "before",
	}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("fade_color_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	var fade: ColorRect = cs.get_node_or_null("FadeRect")
	if fade:
		assert_eq(fade.color, Color.WHITE, "FadeRect color should be white")


# --- 14. Flash skipped when intensity "off" ---
func test_flash_skipped_when_off() -> void:
	var cs: Node = await _create_cutscene()
	cs._config = {"flash_intensity": "off"}
	var fade: ColorRect = cs.get_node_or_null("FadeRect")
	var initial_alpha: float = 0.0
	if fade:
		initial_alpha = fade.modulate.a
	var cmd: Dictionary = {"type": "flash", "color": "white", "duration": 0.1, "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("flash_off_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	if fade:
		assert_eq(fade.modulate.a, initial_alpha, "FadeRect alpha should not change when flash off")


# --- 15. Title command sets TitleLabel text ---
func test_title_command_sets_text() -> void:
	var cs: Node = await _create_cutscene()
	var cmd: Dictionary = {
		"type": "title",
		"text": "Chapter 1",
		"duration": 0.01,
		"fade_in": 0.01,
		"fade_out": 0.01,
		"when": "before",
	}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("title_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.1).timeout
	var title: Label = cs.get_node_or_null("TitleLabel")
	assert_not_null(title, "TitleLabel should exist")
	if title:
		assert_eq(title.text, "Chapter 1", "TitleLabel text should be set")


# --- 16. Wait command creates delay ---
func test_wait_command_creates_delay() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var wait_cmd: Dictionary = {"type": "wait", "duration": 0.1, "when": "before"}
	var move_cmd: Dictionary = {
		"type": "move",
		"who": "npc",
		"to": [0, 0],
		"speed": 80.0,
		"when": "before",
	}
	var entry: Dictionary = _entry({"commands": [wait_cmd, move_cmd]})
	cs.start_cutscene("wait_test", [entry], cs.TIER_MICRO)
	# Move should not have fired yet right after start
	await get_tree().process_frame
	assert_signal_not_emitted(cs, "cutscene_move_requested")
	# After wait completes, move should fire
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_move_requested")


# --- 17. Hide/show dialogue toggles visibility ---
func test_hide_show_dialogue_toggles() -> void:
	var cs: Node = await _create_cutscene()
	var db: Node = cs.get_node_or_null("DialogueBox")
	assert_not_null(db, "DialogueBox should exist")
	var hide_cmd: Dictionary = {"type": "hide_dialogue", "when": "before"}
	var entry: Dictionary = _entry({"commands": [hide_cmd]})
	cs.start_cutscene("hide_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	if db:
		assert_false(db.visible, "DialogueBox should be hidden")


# --- 18. Command-only entry (no lines) works ---
func test_command_only_entry_no_lines() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {
		"type": "music", "track_id": "ambient", "action": "play", "when": "before"
	}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("cmd_only_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_music_requested")
	assert_signal_emitted(cs, "cutscene_finished")


# --- 19. Entry animations emit cutscene_anim_requested ---
func test_entry_animations_emit_signal() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var anims: Array = [{"when": "before_line", "who": "hero", "anim": "nod"}]
	var entry: Dictionary = _entry({"animations": anims})
	cs.start_cutscene("anim_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_anim_requested")


# --- 20. flag_set emitted for entries with flag_set ---
func test_flag_set_emitted() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var entry: Dictionary = _entry({"flag_set": "met_elder"})
	cs.start_cutscene("flag_test2", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "flag_set_requested")


# --- 21. Entries processed in order ---
func test_entries_processed_in_order() -> void:
	var cs: Node = await _create_cutscene()
	var order: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): order.append(f))
	var e1: Dictionary = _entry({"flag_set": "first"})
	var e2: Dictionary = _entry({"flag_set": "second"})
	var e3: Dictionary = _entry({"flag_set": "third"})
	cs.start_cutscene("order_test", [e1, e2, e3], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_eq(order, ["first", "second", "third"], "flags should fire in order")


# --- 22. skip_cutscene sets remaining flags ---
func test_skip_cutscene_sets_remaining_flags() -> void:
	var cs: Node = await _create_cutscene()
	var flags_emitted: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): flags_emitted.append(f))
	var skip_entries: Array[Dictionary] = [
		_entry({"flag_set": "a"}),
		_entry({"flag_set": "b"}),
		_entry({"flag_set": "c"}),
	]
	cs._entries.assign(skip_entries)
	cs._current_index = 1
	cs._is_playing = true
	cs._cutscene_id = "skip_flags_test"
	cs._tier = cs.TIER_MICRO
	cs.skip_cutscene()
	assert_true(flags_emitted.has("b"), "should emit remaining flag b")
	assert_true(flags_emitted.has("c"), "should emit remaining flag c")


# --- 23. Before commands run before dialogue ---
func test_before_commands_run_before_dialogue() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {"type": "music", "track_id": "intro", "action": "play", "when": "before"}
	# Entry with command but no lines — command fires, no dialogue await
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("before_cmd_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_music_requested")
	assert_signal_emitted(cs, "cutscene_finished")


# --- 24. Embedded dialogue_box mode is true ---
func test_embedded_mode_is_true() -> void:
	var cs: Node = await _create_cutscene()
	var db: Node = cs.get_node_or_null("DialogueBox")
	assert_not_null(db, "DialogueBox should exist")
	if db:
		assert_true(db.embedded_mode, "dialogue_box embedded_mode should be true")


# --- 25. dialogue_finished advances sequencer ---
func test_dialogue_finished_advances() -> void:
	var cs: Node = await _create_cutscene()
	var flags_emitted: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): flags_emitted.append(f))
	var entry1: Dictionary = _entry({"lines": ["Hello"], "flag_set": "line1"})
	var entry2: Dictionary = _entry({"flag_set": "line2"})
	cs.start_cutscene("advance_test", [entry1, entry2], cs.TIER_MICRO)
	# Let it start processing — entry1 will be waiting on dialogue_finished
	await get_tree().create_timer(0.1).timeout
	# Manually close the dialogue_box to simulate user advancing
	var db: Node = cs.get_node_or_null("DialogueBox")
	if db and db.has_method("close"):
		db.close()
	await get_tree().create_timer(0.5).timeout
	assert_true(flags_emitted.has("line1"), "line1 flag should fire")
	assert_true(flags_emitted.has("line2"), "line2 flag should fire after advance")


# --- 26. pop_overlay called on completion ---
func test_pop_overlay_on_completion() -> void:
	var cs: Node = await _create_cutscene()
	# We test indirectly: after cutscene finishes with empty entries, it should call pop_overlay
	# Since we are not going through GameManager.push_overlay, the call may error —
	# but cutscene_finished should still emit
	watch_signals(cs)
	cs.start_cutscene("pop_test", [], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_finished")


# --- 27. Unknown command does not crash ---
func test_unknown_command_no_crash() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var cmd: Dictionary = {"type": "nonexistent_cmd", "when": "before"}
	var entry: Dictionary = _entry({"commands": [cmd]})
	cs.start_cutscene("unknown_test", [entry], cs.TIER_MICRO)
	await get_tree().create_timer(0.3).timeout
	assert_signal_emitted(cs, "cutscene_finished")


# --- 28. skip_cutscene resets visual state ---
func test_skip_cutscene_resets_visual_state() -> void:
	var cs: Node = await _create_cutscene()
	var fade: ColorRect = cs.get_node_or_null("FadeRect")
	var title: Label = cs.get_node_or_null("TitleLabel")
	# Simulate mid-fade state
	if fade:
		fade.modulate.a = 0.8
	if title:
		title.modulate.a = 0.6
	cs._entries.assign([_entry({"flag_set": "a"})])
	cs._current_index = 0
	cs._is_playing = true
	cs._cutscene_id = "visual_reset_test"
	cs._tier = cs.TIER_MICRO
	cs.skip_cutscene()
	if fade:
		assert_eq(fade.modulate.a, 0.0, "FadeRect alpha should reset to 0 on skip")
	if title:
		assert_eq(title.modulate.a, 0.0, "TitleLabel alpha should reset to 0 on skip")


# --- 29. dialogue_box flag_set_requested is forwarded ---
func test_dialogue_box_flag_set_forwarded() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	var db: Node = cs.get_node_or_null("DialogueBox")
	assert_not_null(db, "DialogueBox should exist")
	if db and db.has_signal("flag_set_requested"):
		db.flag_set_requested.emit("test_flag", true)
		assert_signal_emitted(cs, "flag_set_requested")


# --- 30. _unhandled_input ui_cancel triggers skip ---
func test_ui_cancel_input_triggers_skip() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	cs._entries.assign([_entry({"flag_set": "input_skip"})])
	cs._current_index = 0
	cs._is_playing = true
	cs._cutscene_id = "input_skip_test"
	cs._tier = cs.TIER_MICRO
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	cs._unhandled_input(event)
	assert_false(cs._is_playing, "_is_playing should be false after ui_cancel skip")
	assert_signal_emitted(cs, "cutscene_finished")


# --- 31. _unhandled_input ignored when not playing ---
func test_ui_cancel_ignored_when_not_playing() -> void:
	var cs: Node = await _create_cutscene()
	watch_signals(cs)
	cs._is_playing = false
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	cs._unhandled_input(event)
	assert_signal_not_emitted(cs, "cutscene_finished")
