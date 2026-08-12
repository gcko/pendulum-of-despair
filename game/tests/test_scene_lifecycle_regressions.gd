extends GutTest
## Regression guards for scene lifetime in exploration and cutscenes: the
## cleansing sequence's cached scene, validate-before-side-effects order and
## cleanup(), the cutscene player's tree guards, and exploration's _exit_tree
## teardown of one-shot signal connections.
##
## Split out of the 968-line test_issue_fixes.gd (#374).

const CleansingScript: GDScript = preload("res://scripts/core/cleansing_sequence.gd")
const CutsceneScript: GDScript = preload("res://scripts/core/cutscene_player.gd")
const ExplorationScript: GDScript = preload("res://scripts/core/exploration.gd")
const CutsceneHandlerScript: GDScript = preload("res://scripts/core/cutscene_handler.gd")
const ExplorationInteractionsScript: GDScript = preload(
	"res://scripts/core/exploration_interactions.gd"
)


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


# ==========================================================================
# Issue gkb: cleansing_sequence caches damage zone PackedScene
# ==========================================================================


func test_cleansing_sequence_caches_damage_zone() -> void:
	var source: String = CleansingScript.source_code
	assert_true(
		"_damage_zone_scene" in source,
		"should have a _damage_zone_scene cache variable",
	)
	assert_true(
		"_damage_zone_scene == null" in source,
		"should only load when cache is null",
	)


# ==========================================================================
# Issue am1: cutscene_player is_inside_tree() guards
# ==========================================================================


func test_cutscene_player_has_tree_guards() -> void:
	var source: String = CutsceneScript.source_code
	var guard_count: int = source.count("is_inside_tree()")
	assert_gt(
		guard_count,
		0,
		"cutscene_player should have is_inside_tree() guards",
	)


func test_exploration_line_count_under_threshold() -> void:
	# The repo-wide budget lives in test_script_layout.gd (600 hard maximum,
	# 400 aim — technical-architecture.md § 1.2a). This keeps a tighter local
	# ratchet on exploration.gd specifically, because it is the file most prone
	# to accreting logic that belongs in one of its six collaborators.
	# Ratchet it DOWN as extractions land, never up.
	var lines: int = ExplorationScript.source_code.count("\n")
	assert_lt(lines, 600, "exploration.gd should stay under 600 lines")


func test_cleansing_validates_before_side_effects() -> void:
	var source: String = CleansingScript.source_code
	var validate_pos: int = source.find("ResourceLoader.exists(_ritual_meter_path)")
	var side_effect_pos: int = source.find("distribute_battle_rewards")
	assert_gt(
		side_effect_pos,
		validate_pos,
		"validation should come before side effects in start()",
	)


func test_cutscene_handler_error_prefix() -> void:
	var source: String = CutsceneHandlerScript.source_code
	assert_false(
		'push_error("Exploration:' in source,
		"should not use Exploration prefix in errors",
	)


# ==========================================================================
# Bug fix: exploration.gd _exit_tree disconnects one-shot signals
# ==========================================================================


func test_exploration_exit_tree_disconnects_signals() -> void:
	# Structural: exploration.gd should have _exit_tree that disconnects
	# pending one-shot callbacks from GameManager.overlay_state_changed.
	# The dialogue one-shot itself moved to ExplorationInteractions in GAP-087,
	# so _exit_tree now reaches it through _disconnect_pending_signals.
	var source: String = ExplorationScript.source_code
	var exit_pos: int = source.find("func _exit_tree()")
	assert_gt(exit_pos, 0, "exploration.gd should have _exit_tree")
	# Slice to the NEXT func, so the guard reads the body of _exit_tree and not
	# the definition of _disconnect_pending_signals further down the file.
	var exit_next: int = source.find("\nfunc ", exit_pos + 1)
	if exit_next < 0:
		exit_next = source.length()
	var exit_body: String = source.substr(exit_pos, exit_next - exit_pos)
	assert_true(
		"_disconnect_pending_signals()" in exit_body,
		"_exit_tree should call _disconnect_pending_signals",
	)
	var interactions: String = ExplorationInteractionsScript.source_code
	var teardown_pos: int = interactions.find("func disconnect_pending_signals()")
	assert_gt(teardown_pos, 0, "ExplorationInteractions should have disconnect_pending_signals")
	var teardown_body: String = interactions.substr(teardown_pos)
	assert_true(
		"on_dialogue_closed_check_party" in teardown_body,
		"disconnect_pending_signals should drop on_dialogue_closed_check_party",
	)


func test_cleansing_sequence_has_cleanup() -> void:
	# Structural: CleansingSequence should have a cleanup() method that
	# disconnects any pending one-shot signal from GameManager.
	var source: String = CleansingScript.source_code
	assert_true(
		"func cleanup()" in source,
		"CleansingSequence should have cleanup() method",
	)
	assert_true(
		"_pending_callable" in source,
		"CleansingSequence should track pending callable for cleanup",
	)


func test_exploration_exit_tree_calls_cleansing_cleanup() -> void:
	# Structural: _exit_tree should call _cleansing.cleanup() if present
	var source: String = ExplorationScript.source_code
	var exit_tree_pos: int = source.find("func _exit_tree()")
	assert_gt(exit_tree_pos, 0, "_exit_tree should exist")
	var next_func: int = source.find("\nfunc ", exit_tree_pos + 1)
	var exit_tree_body: String = source.substr(exit_tree_pos, next_func - exit_tree_pos)
	assert_true(
		"_cleansing.cleanup()" in exit_tree_body,
		"_exit_tree should call _cleansing.cleanup()",
	)
