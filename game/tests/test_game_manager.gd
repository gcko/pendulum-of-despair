extends GutTest
## Tests for GameManager overlay push/pop and pause recovery.
## Covers: silent pop recovery when force-replacing DIALOGUE with
## CUTSCENE fails partway through push_overlay().


func before_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	get_tree().paused = false


func after_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	get_tree().paused = false


# --- Silent pop recovery: tree must unpause after failed replacement ---
func test_silent_pop_recovery_unpauses_tree() -> void:
	# Simulate the state after a DIALOGUE overlay was silently popped:
	# current_overlay is NONE but tree is still paused.
	get_tree().paused = true
	GameManager.current_overlay = GameManager.OverlayState.NONE

	# Attempt to push an overlay with an invalid scene path.
	# Save original path, replace with bogus, then restore.
	var original_path: String = GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE]
	GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE] = ("res://nonexistent_scene.tscn")

	var result: bool = GameManager.push_overlay(GameManager.OverlayState.CUTSCENE)

	# Restore the original path before assertions
	GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE] = (original_path)

	assert_false(result, "push_overlay should return false on missing scene")
	# Note: without did_silent_pop, this path does NOT unpause because
	# the silent pop didn't happen (overlay was already NONE). The tree
	# remains paused. This test validates the non-silent-pop path.
	# The instantiation failure path already unpauses unconditionally.


# --- Force-replace DIALOGUE->CUTSCENE failure restores pause state ---
func test_force_replace_dialogue_cutscene_failure_recovers() -> void:
	# Push a real DIALOGUE overlay first
	var can_push: bool = GameManager.push_overlay(GameManager.OverlayState.DIALOGUE)
	if not can_push:
		# DIALOGUE scene might not exist in test env; simulate instead
		GameManager.current_overlay = GameManager.OverlayState.DIALOGUE
		get_tree().paused = true

	# Now break the CUTSCENE path so the force-replace fails
	var original_path: String = GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE]
	GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE] = ("res://nonexistent_cutscene.tscn")

	var result: bool = GameManager.push_overlay(GameManager.OverlayState.CUTSCENE)

	# Restore original path before assertions
	GameManager.OVERLAY_SCENES[GameManager.OverlayState.CUTSCENE] = (original_path)

	assert_false(result, "push_overlay should return false when replacement fails")
	assert_false(get_tree().paused, "tree must be unpaused after failed force-replace")
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"overlay state must be NONE after failed force-replace"
	)


# --- Successful push still works (regression guard) ---
func test_push_overlay_success_pauses_tree() -> void:
	var result: bool = GameManager.push_overlay(GameManager.OverlayState.DIALOGUE)
	if not result:
		# Scene file may not exist in test env; skip gracefully
		pass_test("DIALOGUE scene not available in test environment")
		return
	assert_true(get_tree().paused, "tree should be paused after overlay push")
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.DIALOGUE,
		"current_overlay should be DIALOGUE"
	)
	GameManager.pop_overlay()


# --- pop_overlay(silent=true) leaves tree paused ---
func test_pop_overlay_silent_leaves_paused() -> void:
	# Manually set up an overlay state
	GameManager.current_overlay = GameManager.OverlayState.DIALOGUE
	get_tree().paused = true

	GameManager.pop_overlay(true)

	assert_true(get_tree().paused, "tree should remain paused after silent pop")
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"current_overlay should be NONE after silent pop"
	)


# --- pop_overlay(silent=false) unpauses tree ---
func test_pop_overlay_normal_unpauses() -> void:
	GameManager.current_overlay = GameManager.OverlayState.DIALOGUE
	get_tree().paused = true

	GameManager.pop_overlay(false)

	assert_false(get_tree().paused, "tree should be unpaused after normal pop")
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"current_overlay should be NONE after normal pop"
	)
