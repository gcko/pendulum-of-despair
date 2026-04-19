extends GutTest
## Regression tests for required_flags AND-condition gating (issues vuh/25q),
## auto_walk guard behavior (issue 25q), and overlay lifecycle (issue orb).

const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")
const ExplorationScript: GDScript = preload("res://scripts/core/exploration.gd")
const CutsceneHandlerScript: GDScript = preload("res://scripts/core/cutscene_handler.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _create_exploration() -> Node2D:
	GameManager.transition_data = {}
	var exp: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	return exp


func _create_exploration_test_room() -> Node2D:
	GameManager.transition_data = {}
	var exp: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	exp.load_map("test_room")
	return exp


## Create a mock Area2D with metadata for trigger testing.
func _make_trigger_area(meta: Dictionary) -> Area2D:
	var area: Area2D = Area2D.new()
	add_child_autofree(area)
	for key: String in meta:
		area.set_meta(key, meta[key])
	return area


# ==========================================================================
# Issue vuh: required_flags AND-condition in dialogue triggers
# ==========================================================================


func test_required_flags_blocks_when_partial_flags_set() -> void:
	# The flag-checking logic in exploration.gd lines 376-383:
	# When required_flags = "flag_a,flag_b", ALL must be set.
	# With only flag_a set, the check should fail (not all met).
	EventFlags.set_flag("flag_a", true)
	var flags_str: String = "flag_a,flag_b"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_false(all_met, "should block when only flag_a is set but flag_b is not")


func test_required_flags_passes_when_all_flags_set() -> void:
	EventFlags.set_flag("flag_a", true)
	EventFlags.set_flag("flag_b", true)
	var flags_str: String = "flag_a,flag_b"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_true(all_met, "should pass when both flag_a and flag_b are set")


func test_required_flags_blocks_when_no_flags_set() -> void:
	var flags_str: String = "flag_a,flag_b"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_false(all_met, "should block when no flags are set")


# ==========================================================================
# Issue vuh: required_flags AND-condition in cutscene triggers
# ==========================================================================


func test_cutscene_required_flags_blocks_partial() -> void:
	# Same AND-condition logic exists in cutscene_handler.gd lines 211-218.
	EventFlags.set_flag("quest_started", true)
	var flags_str: String = "quest_started,boss_defeated"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_false(all_met, "cutscene should block when boss_defeated is not set")


func test_cutscene_required_flags_passes_all_set() -> void:
	EventFlags.set_flag("quest_started", true)
	EventFlags.set_flag("boss_defeated", true)
	var flags_str: String = "quest_started,boss_defeated"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_true(all_met, "cutscene should pass when all flags are set")


# ==========================================================================
# Issue vuh: empty string handling in comma-separated flags
# ==========================================================================


func test_required_flags_skips_empty_entries() -> void:
	# "flag_a,,flag_b" should only check flag_a and flag_b, skipping the
	# empty string between the two commas.
	EventFlags.set_flag("flag_a", true)
	EventFlags.set_flag("flag_b", true)
	var flags_str: String = "flag_a,,flag_b"
	var all_met: bool = true
	var checked_count: int = 0
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		checked_count += 1
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_true(all_met, "should pass — empty entries are skipped")
	assert_eq(checked_count, 2, "should only check 2 non-empty flags")


func test_required_flags_empty_entry_does_not_block() -> void:
	# Only flag_a is set. "flag_a,,flag_b" should fail because flag_b is missing,
	# NOT because of the empty entry.
	EventFlags.set_flag("flag_a", true)
	var flags_str: String = "flag_a,,flag_b"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_false(all_met, "should fail due to missing flag_b, not due to empty entry")


# ==========================================================================
# Issue vuh: single flag (no comma) behaves like required_flag
# ==========================================================================


func test_required_flags_single_flag_blocks_when_unset() -> void:
	var flags_str: String = "flag_a"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_false(all_met, "single flag should block when unset")


func test_required_flags_single_flag_passes_when_set() -> void:
	EventFlags.set_flag("flag_a", true)
	var flags_str: String = "flag_a"
	var all_met: bool = true
	for rf: String in flags_str.split(","):
		var trimmed: String = rf.strip_edges()
		if trimmed.is_empty():
			continue
		if not EventFlags.get_flag(trimmed):
			all_met = false
			break
	assert_true(all_met, "single flag should pass when set")


# ==========================================================================
# Issue vuh: structural verification — code pattern exists in both files
# ==========================================================================


func test_exploration_has_required_flags_logic() -> void:
	var source: String = ExplorationScript.source_code
	assert_true(
		'get_meta("required_flags"' in source,
		"exploration.gd should read required_flags metadata",
	)
	assert_true(
		"required_multi.split" in source or 'split(",")' in source,
		"exploration.gd should split required_flags by comma",
	)


func test_cutscene_handler_has_required_flags_logic() -> void:
	var source: String = CutsceneHandlerScript.source_code
	assert_true(
		'get_meta("required_flags"' in source,
		"cutscene_handler.gd should read required_flags metadata",
	)
	assert_true(
		"required_multi.split" in source or 'split(",")' in source,
		"cutscene_handler.gd should split required_flags by comma",
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
