extends GutTest
## Tests for the shared dialogue condition evaluator (DialogueCondition)
## and its use by the sequence players (cutscene_player, dialogue_box).
## Covers GAP-036: per-entry `condition` must be honoured everywhere.

const CUTSCENE_SCENE: PackedScene = preload("res://scenes/overlay/cutscene.tscn")
const DIALOGUE_SCENE: PackedScene = preload("res://scenes/overlay/dialogue.tscn")


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	PartyState.initialize_new_game()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _entry(id: String, condition: Variant, opts: Dictionary = {}) -> Dictionary:
	return {
		"id": id,
		"speaker": opts.get("speaker", ""),
		"lines": opts.get("lines", []),
		"condition": condition,
		"animations": null,
		"choice": opts.get("choice", null),
		"sfx": null,
		"flag_set": opts.get("flag_set", ""),
		"commands": null,
	}


func _create_cutscene() -> Node:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	await get_tree().process_frame
	return cs


func _create_dialogue() -> Node:
	var dlg: Node = DIALOGUE_SCENE.instantiate()
	add_child_autofree(dlg)
	return dlg


# --- Evaluator: basic forms ---


func test_evaluate_null_and_empty_are_true() -> void:
	assert_true(DialogueCondition.evaluate(null), "null condition should be true")
	assert_true(DialogueCondition.evaluate(""), "empty condition should be true")


func test_evaluate_non_string_is_false() -> void:
	assert_false(DialogueCondition.evaluate(7), "a non-string condition cannot be parsed")


func test_evaluate_binary_flag() -> void:
	assert_false(DialogueCondition.evaluate("cael_betrayal_complete"), "unset flag is false")
	EventFlags.set_flag("cael_betrayal_complete", true)
	assert_true(DialogueCondition.evaluate("cael_betrayal_complete"), "set flag is true")


func test_evaluate_and_combination() -> void:
	EventFlags.set_flag("flag_a", true)
	assert_false(DialogueCondition.evaluate("flag_a AND flag_b"), "one false fails the AND")
	EventFlags.set_flag("flag_b", true)
	assert_true(DialogueCondition.evaluate("flag_a AND flag_b"), "both true passes the AND")


func test_evaluate_party_has() -> void:
	assert_false(DialogueCondition.evaluate("party_has(torren)"), "torren not in party")
	PartyState.add_member("torren")
	assert_true(DialogueCondition.evaluate("party_has(torren)"), "torren in party")


func test_evaluate_party_has_unterminated_is_false() -> void:
	assert_false(DialogueCondition.evaluate("party_has(torren"), "missing ) cannot be parsed")


func test_evaluate_numeric_comparison() -> void:
	EventFlags.set_flag("council_savanh_approval", 2)
	assert_true(DialogueCondition.evaluate("council_savanh_approval >= 2"), "2 >= 2")
	assert_false(DialogueCondition.evaluate("council_savanh_approval >= 5"), "2 >= 5 is false")
	assert_false(DialogueCondition.evaluate("council_savanh_approval < 2"), "2 < 2 is false")
	assert_true(DialogueCondition.evaluate("council_savanh_approval != 3"), "2 != 3")


func test_evaluate_reunion_order_string_comparison() -> void:
	EventFlags.set_flag("reunion_order_1", "edren")
	assert_true(DialogueCondition.evaluate("reunion_order_1 == edren"), "edren found first")
	assert_false(DialogueCondition.evaluate("reunion_order_1 == lira"), "lira was not first")
	assert_true(DialogueCondition.evaluate("reunion_order_1 != lira"), "not-equal comparison")


func test_evaluate_party_has_and_reunion_order_combined() -> void:
	EventFlags.set_flag("reunion_order_1", "edren")
	assert_false(
		DialogueCondition.evaluate("reunion_order_1 == edren AND party_has(maren)"),
		"maren missing should fail the AND",
	)
	PartyState.add_member("maren")
	assert_true(
		DialogueCondition.evaluate("reunion_order_1 == edren AND party_has(maren)"),
		"both halves true should pass",
	)


func test_is_unconditioned_accepts_only_null_and_empty() -> void:
	assert_true(DialogueCondition.is_unconditioned(null), "JSON null means always plays")
	assert_true(DialogueCondition.is_unconditioned(""), "empty string means always plays")
	assert_false(DialogueCondition.is_unconditioned("some_flag"), "a real expression is gated")
	assert_false(DialogueCondition.is_unconditioned(0), "a non-string is not unconditioned")


# --- Priority stack resolution (GAP-042) ---


func test_resolve_stack_returns_every_default_when_nothing_matches() -> void:
	var entries: Array = [
		_entry("d1", null),
		_entry("d2", null),
		_entry("d3", null),
		_entry("c1", "late_game_flag"),
	]
	var resolved: Array = DialogueCondition.resolve_stack(entries)
	assert_eq(resolved.size(), 3, "all three defaults should be candidates")
	assert_eq(resolved[0].get("id"), "d1", "defaults keep authored order")
	assert_eq(resolved[2].get("id"), "d3", "no default is dropped")


func test_resolve_stack_first_match_wins() -> void:
	var entries: Array = [
		_entry("d1", null),
		_entry("c1", "cael_betrayal_complete"),
		_entry("c2", "cael_betrayal_complete"),
	]
	EventFlags.set_flag("cael_betrayal_complete", true)
	var resolved: Array = DialogueCondition.resolve_stack(entries)
	assert_eq(resolved.size(), 1, "a matched condition resolves to exactly one entry")
	assert_eq(resolved[0].get("id"), "c1", "the topmost matching entry wins")


func test_resolve_stack_ignores_non_dictionary_entries() -> void:
	var resolved: Array = DialogueCondition.resolve_stack(["junk", _entry("d1", null)])
	assert_eq(resolved.size(), 1, "malformed entries are skipped")
	assert_eq(resolved[0].get("id"), "d1", "the real entry survives")


func test_resolve_stack_empty_when_nothing_is_playable() -> void:
	var resolved: Array = DialogueCondition.resolve_stack([_entry("c1", "missing_flag")])
	assert_true(resolved.is_empty(), "a stack with no default and no match says nothing")


func test_should_play_reflects_condition() -> void:
	assert_false(DialogueCondition.should_play(_entry("x", "missing_flag")), "false condition")
	assert_true(DialogueCondition.should_play(_entry("x", null)), "no condition")


# --- Evaluator: scene-local context ---


func test_context_shadows_event_flags() -> void:
	var context: Dictionary = DialogueCondition.choice_context(0)
	assert_true(DialogueCondition.evaluate("choice_1_selected", context), "selected option")
	assert_false(DialogueCondition.evaluate("choice_2_selected", context), "unselected option")


func test_context_beats_a_stale_event_flag() -> void:
	EventFlags.set_flag("choice_2_selected", true)
	var context: Dictionary = DialogueCondition.choice_context(0)
	assert_false(
		DialogueCondition.evaluate("choice_2_selected", context),
		"scene-local context must shadow a leftover EventFlag",
	)


func test_choice_context_marks_only_the_selected_option() -> void:
	var context: Dictionary = DialogueCondition.choice_context(2)
	assert_eq(context.size(), DialogueCondition.MAX_CHOICES, "one entry per option slot")
	assert_true(bool(context["choice_3_selected"]), "third option selected")
	assert_false(bool(context["choice_1_selected"]), "first option not selected")


# --- Cutscene player honours conditions (GAP-036) ---


func test_cutscene_skips_false_condition_entry() -> void:
	var cs: Node = await _create_cutscene()
	var fired: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): fired.append(f))
	var entries: Array[Dictionary] = [
		_entry("a", null, {"flag_set": "played_a"}),
		_entry("b", "party_has(sable)", {"flag_set": "played_b"}),
		_entry("c", null, {"flag_set": "played_c"}),
	]
	cs.start_cutscene("cond_skip_test", entries, cs.TIER_MICRO)
	await get_tree().create_timer(0.4).timeout
	assert_true(fired.has("played_a"), "unconditioned entry should play")
	assert_false(fired.has("played_b"), "false-condition entry should be skipped")
	assert_true(fired.has("played_c"), "sequence should continue past a skipped entry")


func test_cutscene_plays_true_condition_entry() -> void:
	var cs: Node = await _create_cutscene()
	var fired: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): fired.append(f))
	PartyState.add_member("torren")
	EventFlags.set_flag("reunion_order_1", "edren")
	var entries: Array[Dictionary] = [
		_entry("a", "party_has(torren)", {"flag_set": "played_a"}),
		_entry("b", "council_result >= 2", {"flag_set": "played_b"}),
		_entry("c", "reunion_order_1 == edren", {"flag_set": "played_c"}),
	]
	EventFlags.set_flag("council_result", 3)
	cs.start_cutscene("cond_play_test", entries, cs.TIER_MICRO)
	await get_tree().create_timer(0.4).timeout
	assert_true(fired.has("played_a"), "party_has entry should play")
	assert_true(fired.has("played_b"), "numeric comparison entry should play")
	assert_true(fired.has("played_c"), "reunion_order comparison entry should play")


func test_cutscene_skip_ignores_false_condition_entries() -> void:
	var cs: Node = await _create_cutscene()
	var fired: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): fired.append(f))
	var entries: Array[Dictionary] = [
		_entry("a", null, {"flag_set": "a"}),
		_entry("b", "never_set_flag", {"flag_set": "b"}),
		_entry("c", null, {"flag_set": "c"}),
	]
	cs._entries.assign(entries)
	cs._current_index = 0
	cs._is_playing = true
	cs._cutscene_id = "cond_skip_flags"
	cs._tier = cs.TIER_MICRO
	cs.skip_cutscene()
	assert_true(fired.has("a"), "playable entry flag should still fire on skip")
	assert_false(fired.has("b"), "skipped entry should not set its flag")
	assert_true(fired.has("c"), "later playable entry flag should fire on skip")


# --- Dialogue box honours conditions (GAP-036) ---


func test_dialogue_box_skips_false_condition_entry() -> void:
	var dlg: Node = _create_dialogue()
	var entries: Array = [
		_entry("first", null, {"lines": ["one"]}),
		_entry("hidden", "party_has(sable)", {"lines": ["two"]}),
		_entry("third", null, {"lines": ["three"]}),
	]
	dlg.show_dialogue(entries)
	assert_eq(dlg._entries[dlg._current_index].get("id"), "first", "starts on first entry")
	dlg._complete_text()
	dlg._advance()
	assert_eq(
		dlg._entries[dlg._current_index].get("id"),
		"third",
		"false-condition entry should be skipped",
	)


func test_dialogue_box_starts_past_leading_false_condition() -> void:
	var dlg: Node = _create_dialogue()
	var entries: Array = [
		_entry("hidden", "party_has(sable)", {"lines": ["one"]}),
		_entry("shown", null, {"lines": ["two"]}),
	]
	dlg.show_dialogue(entries)
	assert_eq(
		dlg._entries[dlg._current_index].get("id"),
		"shown",
		"leading false-condition entry should be skipped",
	)


func test_dialogue_box_finishes_when_every_entry_is_gated_out() -> void:
	var dlg: Node = _create_dialogue()
	watch_signals(dlg)
	dlg.embedded_mode = true
	dlg.show_dialogue([_entry("hidden", "party_has(sable)", {"lines": ["one"]})])
	assert_signal_emitted(dlg, "dialogue_finished", "an all-gated sequence should end cleanly")


func test_dialogue_box_choice_gates_reaction_entries() -> void:
	var dlg: Node = _create_dialogue()
	var choices: Array = [{"label": "Diplomatic"}, {"label": "Blunt"}]
	var entries: Array = [
		_entry("question", null, {"lines": ["Well?"], "choice": choices}),
		_entry("reaction_1", "choice_1_selected", {"lines": ["Wise."]}),
		_entry("reaction_2", "choice_2_selected", {"lines": ["Blunt."]}),
	]
	dlg.show_dialogue(entries)
	dlg._complete_text()
	dlg._advance()
	assert_true(dlg._in_choice, "choice prompt should be shown")
	dlg._choice_index = 1
	dlg._select_choice()
	assert_eq(
		dlg._entries[dlg._current_index].get("id"),
		"reaction_2",
		"only the reaction for the chosen option should play",
	)


func test_cutscene_reaction_entry_with_lines_plays_instead_of_deadlocking() -> void:
	# The cutscene gates each entry, then hands it to the embedded dialogue box,
	# which gates it again. If the box resolves the second gate against its own
	# empty context, the reaction is dropped and the box finishes synchronously —
	# before the cutscene's await can attach — and the scene hangs forever.
	var cs: Node = await _create_cutscene()
	var fired: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): fired.append(f))
	var choices: Array = [{"label": "Diplomatic"}, {"label": "Blunt"}]
	var entries: Array[Dictionary] = [
		_entry("question", null, {"lines": ["Well?"], "choice": choices}),
		_entry("reaction_1", "choice_1_selected", {"lines": ["Wise."], "flag_set": "reacted_1"}),
		_entry("reaction_2", "choice_2_selected", {"lines": ["Blunt."], "flag_set": "reacted_2"}),
	]
	cs.start_cutscene("cond_choice_lines", entries, cs.TIER_MICRO)
	await get_tree().process_frame

	var box: Node = cs._dialogue_box
	assert_true(box.is_showing(), "the question should be on screen")
	box._complete_text()
	box._advance()
	assert_true(box._in_choice, "the question should offer its choice")
	box._choice_index = 0
	box._select_choice()

	assert_true(box.is_showing(), "the reaction must reach the box, not be gated out")
	assert_eq(
		box._entries[box._current_index].get("id"),
		"reaction_1",
		"the reaction for the chosen option should be the one displayed",
	)
	box._complete_text()
	box._advance()
	await get_tree().create_timer(0.2).timeout
	assert_true(fired.has("reacted_1"), "the played reaction should set its flag")
	assert_false(fired.has("reacted_2"), "the unchosen reaction should stay skipped")
	assert_false(cs._is_playing, "the cutscene should finish rather than hang on the await")


func test_embedded_box_releases_entries_when_the_sequence_ends() -> void:
	# Embedded mode keeps the box alive and listening after it finishes, so a
	# confirm press mashed during the cutscene's after-commands must not index
	# past the last entry.
	var dlg: Node = _create_dialogue()
	dlg.embedded_mode = true
	dlg.show_dialogue([_entry("only", null, {"lines": ["one"]})])
	dlg._complete_text()
	dlg._advance()
	assert_true(dlg._entries.is_empty(), "a finished box should hold no out-of-range cursor")
	assert_false(dlg.is_showing(), "and should report that nothing is on screen")
	watch_signals(dlg)
	dlg._advance()
	assert_signal_not_emitted(dlg, "dialogue_finished", "advancing an exhausted box is a no-op")


func test_cutscene_choice_gates_following_entries() -> void:
	var cs: Node = await _create_cutscene()
	var fired: Array = []
	cs.flag_set_requested.connect(func(f: String, _v: Variant): fired.append(f))
	# The cutscene feeds entries to the dialogue box one at a time, so the
	# choice context has to survive across entries.
	cs._choice_context = {}
	cs._on_dialogue_choice_made(0)
	var entries: Array[Dictionary] = [
		_entry("reaction_1", "choice_1_selected", {"flag_set": "reacted_1"}),
		_entry("reaction_2", "choice_2_selected", {"flag_set": "reacted_2"}),
	]
	cs._entries.assign(entries)
	cs._current_index = 0
	cs._is_playing = true
	cs._cutscene_id = "cond_choice_flags"
	cs._tier = cs.TIER_MICRO
	cs.skip_cutscene()
	assert_true(fired.has("reacted_1"), "reaction for the chosen option should play")
	assert_false(fired.has("reacted_2"), "reaction for an unchosen option should not play")
