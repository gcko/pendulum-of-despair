extends GutTest
## Tests for Dialogue Overlay.

const DIALOGUE_SCENE: PackedScene = preload("res://scenes/overlay/dialogue.tscn")


func _create_dialogue():
	var dlg = DIALOGUE_SCENE.instantiate()
	add_child_autofree(dlg)
	return dlg


func _sample_entries() -> Array:
	return [
		{
			"id": "test_001",
			"speaker": "edren",
			"lines": ["Hello there.", "How are you?"],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
		},
		{
			"id": "test_002",
			"speaker": "cael",
			"lines": ["I am fine."],
			"condition": null,
			"animations": null,
			"choice": null,
			"sfx": null,
		},
	]


# --- Scene Loading ---


func test_dialogue_scene_loads() -> void:
	var dlg = _create_dialogue()
	assert_not_null(dlg, "dialogue scene should instantiate")


# --- Show Dialogue ---


func test_show_dialogue_sets_entries() -> void:
	var dlg = _create_dialogue()
	var entries: Array = _sample_entries()
	dlg.show_dialogue(entries)
	assert_eq(dlg._entries.size(), 2, "should store 2 entries")
	assert_eq(dlg._current_index, 0, "should start at index 0")


func test_speaker_name_displayed() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue(_sample_entries())
	assert_true(dlg._speaker_container.visible, "speaker label should be visible")
	assert_eq(dlg._speaker_label.text, "EDREN", "should show speaker name uppercased")


func test_speaker_name_empty() -> void:
	var dlg = _create_dialogue()
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "",
					"lines": ["No speaker."],
					"condition": null,
					"animations": null,
					"choice": null,
					"sfx": null,
				},
			]
		)
	)
	assert_false(dlg._speaker_container.visible, "speaker label should be hidden")


# --- Typewriter ---


func test_typewriter_reveals_chars() -> void:
	var dlg = _create_dialogue()
	dlg._text_speed = 60
	dlg.show_dialogue(_sample_entries())
	# Simulate a frame at 60fps (delta = 1/60)
	dlg._process(1.0 / 60.0)
	assert_gt(int(dlg._chars_revealed), 0, "should have revealed some characters")
	assert_false(dlg._text_complete, "text should not be complete yet")


func test_confirm_completes_text() -> void:
	var dlg = _create_dialogue()
	dlg._text_speed = 30  # Slow speed
	dlg.show_dialogue(_sample_entries())
	# Text should not be complete initially
	assert_false(dlg._text_complete, "text should not be complete initially")
	# Simulate confirm — should complete text
	dlg._complete_text()
	assert_true(dlg._text_complete, "text should be complete after confirm")


func test_confirm_advances_entry() -> void:
	var dlg = _create_dialogue()
	dlg.show_dialogue(_sample_entries())
	dlg._complete_text()
	# Advance past all lines of first entry
	dlg._advance()
	assert_eq(dlg._current_index, 1, "should advance to second entry")


func test_last_entry_emits_finished() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "test",
					"lines": ["Only entry."],
					"condition": null,
					"animations": null,
					"choice": null,
					"sfx": null,
				},
			]
		)
	)
	dlg._complete_text()
	dlg._advance()
	assert_signal_emitted(dlg, "dialogue_finished", "should emit dialogue_finished")


# --- Choices ---


func test_choice_display() -> void:
	var dlg = _create_dialogue()
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "test",
					"lines": ["Pick one."],
					"condition": null,
					"animations": null,
					"choice": [{"label": "Yes"}, {"label": "No"}],
					"sfx": null,
				},
			]
		)
	)
	dlg._complete_text()
	dlg._advance()
	assert_true(dlg._in_choice, "should be in choice mode")
	assert_true(dlg._choice_box.visible, "choice box should be visible")
	assert_eq(dlg._choice_count, 2, "should have 2 choices")


func test_choice_selection() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "test",
					"lines": ["Pick one."],
					"condition": null,
					"animations": null,
					"choice": [{"label": "Yes"}, {"label": "No"}],
					"sfx": null,
				},
			]
		)
	)
	dlg._complete_text()
	dlg._advance()
	# Select first choice
	dlg._select_choice()
	assert_signal_emitted(dlg, "choice_made", "should emit choice_made")


func test_choice_cancel_selects_bottom() -> void:
	var dlg = _create_dialogue()
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "test",
					"lines": ["Pick one."],
					"condition": null,
					"animations": null,
					"choice": [{"label": "Yes"}, {"label": "No"}],
					"sfx": null,
				},
			]
		)
	)
	dlg._complete_text()
	dlg._advance()
	assert_eq(dlg._choice_index, 0, "should start on first choice")
	# Simulate cancel input — _handle_choice_input sets index to bottom and selects
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	dlg._handle_choice_input(cancel_event)
	# After cancel, choice should have been made (bottom option selected)
	assert_false(dlg._in_choice, "should exit choice mode after cancel")


# --- Signals ---


func test_animation_signal() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "test",
					"lines": ["Animated."],
					"condition": null,
					"animations": [{"who": "edren", "anim": "shake", "when": "before_line_0"}],
					"choice": null,
					"sfx": null,
				},
			]
		)
	)
	assert_signal_emitted(dlg, "animation_requested", "should emit animation_requested")


func test_empty_entries() -> void:
	var dlg = _create_dialogue()
	watch_signals(dlg)
	dlg.show_dialogue([])
	assert_signal_emitted(
		dlg, "dialogue_finished", "empty entries should emit finished immediately"
	)


func test_multipage_pagination() -> void:
	var dlg = _create_dialogue()
	(
		dlg
		. show_dialogue(
			[
				{
					"id": "t1",
					"speaker": "test",
					"lines": ["Line 1.", "Line 2.", "Line 3.", "Line 4.", "Line 5."],
					"condition": null,
					"animations": null,
					"choice": null,
					"sfx": null,
				},
			]
		)
	)
	assert_eq(dlg._page_start, 0, "should start at page 0")
	dlg._complete_text()
	dlg._advance()
	assert_eq(dlg._page_start, 3, "should advance to second page at line 3")
