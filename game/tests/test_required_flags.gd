extends GutTest
## Regression tests for required_flags AND-condition gating (issues vuh/25q),
## auto_walk guard behavior (issue 25q), and overlay lifecycle (issue orb).
##
## Flag-checking tests exercise EventFlags.check_required_flags() — the same
## utility that exploration.gd and cutscene_handler.gd call at runtime.

const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")
const ExplorationScript: GDScript = preload("res://scripts/core/exploration.gd")
const CutsceneHandlerScript: GDScript = preload("res://scripts/core/cutscene_handler.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _create_exploration_test_room() -> Node2D:
	GameManager.transition_data = {}
	var exp: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	exp.load_map("test_room")
	return exp


# ==========================================================================
# Issue vuh: required_flags AND-condition in dialogue triggers
# ==========================================================================


func test_required_flags_blocks_when_partial_flags_set() -> void:
	EventFlags.set_flag("flag_a", true)
	assert_false(
		EventFlags.check_required_flags("flag_a,flag_b"),
		"should block when only flag_a is set but flag_b is not",
	)


func test_required_flags_passes_when_all_flags_set() -> void:
	EventFlags.set_flag("flag_a", true)
	EventFlags.set_flag("flag_b", true)
	assert_true(
		EventFlags.check_required_flags("flag_a,flag_b"),
		"should pass when both flag_a and flag_b are set",
	)


func test_required_flags_blocks_when_no_flags_set() -> void:
	assert_false(
		EventFlags.check_required_flags("flag_a,flag_b"),
		"should block when no flags are set",
	)


# ==========================================================================
# Issue vuh: required_flags AND-condition in cutscene triggers
# ==========================================================================


func test_cutscene_required_flags_blocks_partial() -> void:
	EventFlags.set_flag("quest_started", true)
	assert_false(
		EventFlags.check_required_flags("quest_started,boss_defeated"),
		"cutscene should block when boss_defeated is not set",
	)


func test_cutscene_required_flags_passes_all_set() -> void:
	EventFlags.set_flag("quest_started", true)
	EventFlags.set_flag("boss_defeated", true)
	assert_true(
		EventFlags.check_required_flags("quest_started,boss_defeated"),
		"cutscene should pass when all flags are set",
	)


# ==========================================================================
# Issue vuh: empty string handling in comma-separated flags
# ==========================================================================


func test_required_flags_skips_empty_entries() -> void:
	EventFlags.set_flag("flag_a", true)
	EventFlags.set_flag("flag_b", true)
	assert_true(
		EventFlags.check_required_flags("flag_a,,flag_b"),
		"should pass — empty entries between commas are skipped",
	)


func test_required_flags_empty_entry_does_not_block() -> void:
	EventFlags.set_flag("flag_a", true)
	assert_false(
		EventFlags.check_required_flags("flag_a,,flag_b"),
		"should fail due to missing flag_b, not due to empty entry",
	)


func test_required_flags_empty_string_passes() -> void:
	assert_true(
		EventFlags.check_required_flags(""),
		"empty flags_csv means no requirements — should pass",
	)


# ==========================================================================
# Issue vuh: single flag (no comma) behaves like required_flag
# ==========================================================================


func test_required_flags_single_flag_blocks_when_unset() -> void:
	assert_false(
		EventFlags.check_required_flags("flag_a"),
		"single flag should block when unset",
	)


func test_required_flags_single_flag_passes_when_set() -> void:
	EventFlags.set_flag("flag_a", true)
	assert_true(
		EventFlags.check_required_flags("flag_a"),
		"single flag should pass when set",
	)


# ==========================================================================
# Issue vuh: structural verification — handlers delegate to utility
# ==========================================================================


func test_exploration_uses_check_required_flags() -> void:
	var source: String = ExplorationScript.source_code
	assert_true(
		'get_meta("required_flags"' in source,
		"exploration.gd should read required_flags metadata",
	)
	assert_true(
		"check_required_flags" in source,
		"exploration.gd should delegate to EventFlags.check_required_flags()",
	)


func test_cutscene_handler_uses_check_required_flags() -> void:
	var source: String = CutsceneHandlerScript.source_code
	assert_true(
		'get_meta("required_flags"' in source,
		"cutscene_handler.gd should read required_flags metadata",
	)
	assert_true(
		"check_required_flags" in source,
		"cutscene_handler.gd should delegate to EventFlags.check_required_flags()",
	)


# ==========================================================================
# Issue 25q: _start_auto_walk null Transitions guard
# ==========================================================================


func test_start_auto_walk_no_transitions_node() -> void:
	# When _current_map has no "Transitions" node, _start_auto_walk should
	# gracefully exit: set _in_auto_walk back to false and re-enable input.
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player must exist")
	# Ensure there is no Transitions node on the current map.
	var transitions: Node = exp._current_map.get_node_or_null("Transitions")
	if transitions != null:
		exp._current_map.remove_child(transitions)
		transitions.queue_free()
	# Enable player input before calling _start_auto_walk.
	exp._player.set_input_enabled(true)
	exp._start_auto_walk()
	# After the guard, auto_walk should be false and input re-enabled.
	assert_false(exp._in_auto_walk, "auto_walk should be false after guard")
	assert_true(
		exp._player.is_input_enabled(),
		"player input should be re-enabled after guard",
	)


func test_start_auto_walk_guard_structural() -> void:
	# Structural test: verify the Transitions null guard exists in source.
	var source: String = ExplorationScript.source_code
	assert_true(
		'get_node_or_null("Transitions")' in source,
		"_start_auto_walk should check for Transitions node",
	)
	assert_true(
		"transitions == null" in source,
		"_start_auto_walk should guard against null Transitions",
	)


# ==========================================================================
# Issue 25q: _end_auto_walk cutscene input guard
# ==========================================================================


func test_end_auto_walk_does_not_enable_input_during_cutscene() -> void:
	# When _in_cutscene is true, _end_auto_walk should NOT re-enable player input.
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player must exist")
	# Simulate auto_walk in progress during a cutscene.
	exp._in_auto_walk = true
	exp._in_cutscene = true
	exp._player.set_input_enabled(false)
	exp._end_auto_walk()
	assert_false(exp._in_auto_walk, "auto_walk should be cleared")
	assert_false(
		exp._player.is_input_enabled(),
		"input should remain disabled when in cutscene",
	)


func test_end_auto_walk_enables_input_when_not_in_cutscene() -> void:
	# When _in_cutscene is false, _end_auto_walk SHOULD re-enable player input.
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player must exist")
	exp._in_auto_walk = true
	exp._in_cutscene = false
	exp._player.set_input_enabled(false)
	exp._end_auto_walk()
	assert_false(exp._in_auto_walk, "auto_walk should be cleared")
	assert_true(
		exp._player.is_input_enabled(),
		"input should be re-enabled when not in cutscene",
	)


func test_end_auto_walk_cutscene_guard_structural() -> void:
	# Structural test: verify the _in_cutscene guard exists in _end_auto_walk.
	var source: String = ExplorationScript.source_code
	assert_true(
		"not _in_cutscene" in source,
		"_end_auto_walk should check _in_cutscene before enabling input",
	)
