extends GutTest
## Tests for numeric score accumulation and clamping (GAP-038).
## Score choices must add to the running total and clamp to the range
## documented in events.md, not overwrite it. See dialogue-system.md 3.3/3.4.

const CUTSCENE_SCENE: PackedScene = preload("res://scenes/overlay/cutscene.tscn")
const DIALOGUE_SCENE: PackedScene = preload("res://scenes/overlay/dialogue.tscn")
const SAVANH: String = "council_savanh_approval"


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	PartyState.initialize_new_game()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _entry(id: String, opts: Dictionary = {}) -> Dictionary:
	return {
		"id": id,
		"speaker": "",
		"lines": opts.get("lines", []),
		"condition": null,
		"animations": null,
		"choice": opts.get("choice", null),
		"sfx": null,
		"flag_set": opts.get("flag_set", ""),
		"commands": null,
	}


func _create_dialogue() -> Node:
	var dlg: Node = DIALOGUE_SCENE.instantiate()
	add_child_autofree(dlg)
	dlg.embedded_mode = true
	return dlg


func _create_cutscene() -> Node:
	var cs: Node = CUTSCENE_SCENE.instantiate()
	add_child_autofree(cs)
	await get_tree().process_frame
	return cs


## Page through the current entry until its choice prompt appears, then pick
## [param option_index].
func _answer_choice(dlg: Node, option_index: int) -> void:
	for _i: int in range(20):
		if dlg._in_choice:
			break
		dlg._complete_text()
		dlg._advance()
	assert_true(dlg._in_choice, "expected a choice prompt")
	dlg._choice_index = option_index
	dlg._select_choice()


# --- EventFlags.increment_score ---


func test_score_accumulates_instead_of_overwriting() -> void:
	assert_eq(EventFlags.increment_score(SAVANH, 2, 0, 3), 2, "first answer sets 2")
	assert_eq(EventFlags.increment_score(SAVANH, 1, 0, 3), 3, "second answer adds to the total")
	assert_eq(int(EventFlags.get_flag(SAVANH, 0)), 3, "stored value is the running total")


func test_score_clamps_at_maximum() -> void:
	EventFlags.increment_score(SAVANH, 2, 0, 3)
	assert_eq(EventFlags.increment_score(SAVANH, 2, 0, 3), 3, "4 is clamped to the max of 3")
	assert_eq(EventFlags.increment_score(SAVANH, 5, 0, 3), 3, "already at the ceiling")


func test_score_clamps_at_minimum() -> void:
	EventFlags.increment_score(SAVANH, 1, 0, 3)
	assert_eq(EventFlags.increment_score(SAVANH, -5, 0, 3), 0, "-4 is clamped to the min of 0")


func test_unset_score_starts_at_its_minimum() -> void:
	assert_eq(EventFlags.increment_score("fresh_score", 0, 2, 5), 2, "unset starts at the min")


func test_score_increment_emits_flag_changed() -> void:
	watch_signals(EventFlags)
	EventFlags.increment_score(SAVANH, 2, 0, 3)
	assert_signal_emitted_with_parameters(EventFlags, "flag_changed", [SAVANH, 2])


func test_empty_score_name_is_rejected() -> void:
	assert_eq(EventFlags.increment_score("", 2, 0, 3), 0, "an empty name stores nothing")
	assert_false(EventFlags.has_flag(""), "no empty-named flag should appear")


func test_zero_delta_materialises_the_score() -> void:
	# dialogue-system.md 3.4: a score_delta of 0 records that the question was
	# answered, so the score must exist afterwards.
	EventFlags.apply_score_choice(SAVANH, 0)
	assert_true(EventFlags.has_flag(SAVANH), "answering with 0 still records the score")
	assert_eq(int(EventFlags.get_flag(SAVANH, -1)), 0, "and the total is 0")


# --- Documented ranges ---


func test_documented_ranges_match_events_md() -> void:
	# events.md flags 40-43: all four council scores are 0-3.
	for score_name: String in [
		SAVANH, "council_caden_approval", "council_wynne_approval", "council_result"
	]:
		assert_eq(
			EventFlags.get_score_range(score_name),
			Vector2i(0, 3),
			"%s should be documented as 0-3" % score_name,
		)


func test_apply_score_choice_clamps_to_the_documented_range() -> void:
	EventFlags.apply_score_choice(SAVANH, 2)
	EventFlags.apply_score_choice(SAVANH, 2)
	assert_eq(int(EventFlags.get_flag(SAVANH, 0)), 3, "clamped to the events.md maximum of 3")


# --- Signal routing ---


func test_score_choice_uses_its_own_signal_not_flag_set() -> void:
	var dlg: Node = _create_dialogue()
	watch_signals(dlg)
	var choices: Array = [{"label": "Diplomatic", "score_name": SAVANH, "score_delta": 2}]
	dlg.show_dialogue([_entry("q", {"lines": ["Well?"], "choice": choices})])
	_answer_choice(dlg, 0)
	assert_signal_emitted_with_parameters(dlg, "score_increment_requested", [SAVANH, 2])
	assert_signal_not_emitted(dlg, "flag_set_requested", "scores must not take the overwrite path")


func test_zero_delta_choice_still_emits() -> void:
	var dlg: Node = _create_dialogue()
	watch_signals(dlg)
	var choices: Array = [{"label": "Neutral", "score_name": SAVANH, "score_delta": 0}]
	dlg.show_dialogue([_entry("q", {"lines": ["Well?"], "choice": choices})])
	_answer_choice(dlg, 0)
	assert_signal_emitted_with_parameters(dlg, "score_increment_requested", [SAVANH, 0])


func test_flag_and_score_on_one_option_both_route() -> void:
	var dlg: Node = _create_dialogue()
	watch_signals(dlg)
	var choices: Array = [
		{"label": "Both", "flag_set": "answered_savanh", "score_name": SAVANH, "score_delta": 1}
	]
	dlg.show_dialogue([_entry("q", {"lines": ["Well?"], "choice": choices})])
	_answer_choice(dlg, 0)
	assert_signal_emitted_with_parameters(dlg, "flag_set_requested", ["answered_savanh", true])
	assert_signal_emitted_with_parameters(dlg, "score_increment_requested", [SAVANH, 1])


func test_dialogue_consequences_apply_both_consequence_types() -> void:
	var dlg: Node = _create_dialogue()
	DialogueConsequences.connect_overlay(dlg)
	var choices: Array = [
		{"label": "Both", "flag_set": "answered_savanh", "score_name": SAVANH, "score_delta": 2}
	]
	dlg.show_dialogue([_entry("q", {"lines": ["Well?"], "choice": choices})])
	_answer_choice(dlg, 0)
	assert_true(bool(EventFlags.get_flag("answered_savanh")), "flag consequence applied")
	assert_eq(int(EventFlags.get_flag(SAVANH, 0)), 2, "score consequence applied")


func test_two_questions_accumulate_through_the_overlay() -> void:
	# The regression: an overwrite would leave the score at the last delta (1).
	var dlg: Node = _create_dialogue()
	DialogueConsequences.connect_overlay(dlg)
	var first: Array = [{"label": "A", "score_name": SAVANH, "score_delta": 2}]
	var second: Array = [{"label": "B", "score_name": SAVANH, "score_delta": 1}]
	var entries: Array = [
		_entry("q1", {"lines": ["First?"], "choice": first}),
		_entry("q2", {"lines": ["Second?"], "choice": second}),
	]
	dlg.show_dialogue(entries)
	_answer_choice(dlg, 0)
	_answer_choice(dlg, 0)
	assert_eq(int(EventFlags.get_flag(SAVANH, 0)), 3, "2 then 1 accumulates to 3, not 1")


func test_cutscene_player_forwards_score_requests() -> void:
	var cs: Node = await _create_cutscene()
	var received: Array = []
	cs.score_increment_requested.connect(func(n: String, d: int): received.append([n, d]))
	cs._dialogue_box.score_increment_requested.emit(SAVANH, 2)
	assert_eq(received, [[SAVANH, 2]], "the cutscene player must forward score requests")


# --- Real council data (the case the bug broke) ---


func test_thornmere_savanh_score_reaches_three_via_seyth_bonus() -> void:
	var data: Dictionary = DataManager.load_dialogue("thornmere_council")
	var by_id: Dictionary = {}
	for e: Variant in data.get("entries", []):
		if e is Dictionary:
			by_id[(e as Dictionary).get("id", "")] = e
	var question: Variant = by_id.get("thornmere_council_005", null)
	var bonus: Variant = by_id.get("thornmere_council_011", null)
	assert_not_null(question, "council question 005 should exist")
	assert_not_null(bonus, "Grandmother Seyth bonus 011 should exist")
	if question == null or bonus == null:
		return

	var dlg: Node = _create_dialogue()
	dlg.score_increment_requested.connect(
		func(n: String, d: int) -> void: EventFlags.apply_score_choice(n, d)
	)
	dlg.show_dialogue([question, bonus])
	# Best base answer (+2), then the Seyth bonus option (+1).
	_answer_choice(dlg, 0)
	_answer_choice(dlg, 0)
	assert_eq(
		int(EventFlags.get_flag(SAVANH, 0)),
		3,
		"3 is only reachable when the base answer and the bonus accumulate",
	)
