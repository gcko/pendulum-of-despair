extends GutTest
## Guards on the test suite itself: TestHelpers exists and does what the
## rest of the suite assumes, and no test file hand-rolls singleton cleanup
## that reset_game_state() already covers.
##
## Split out of the 968-line test_issue_fixes.gd (#374).


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


# ==========================================================================
# Issue lvb: Test helper exists and works
# ==========================================================================


func test_helpers_class_exists() -> void:
	var helpers: TestHelpers = TestHelpers.new()
	assert_not_null(helpers, "TestHelpers class should exist")


func test_helpers_reset_game_state() -> void:
	PartyState.gold = 999
	EventFlags.set_flag("test_flag", true)
	TestHelpers.reset_game_state()
	assert_eq(PartyState.gold, 0, "gold should be reset")
	assert_false(EventFlags.get_flag("test_flag"), "flags should be cleared")


func test_helpers_teardown_overlay() -> void:
	TestHelpers.setup_overlay_state(GameManager.OverlayState.MENU)
	TestHelpers.teardown_overlay()
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"overlay should be NONE after teardown",
	)


# ==========================================================================
# Structural: all test files use TestHelpers.reset_game_state()
# ==========================================================================


func test_all_test_files_use_reset_game_state() -> void:
	# Verify test files that manually clear singletons use TestHelpers.reset_game_state()
	# instead of partial cleanup (EventFlags.clear_all, PartyState.members.clear, etc.).
	var test_dir: String = "res://tests/"
	var dir: DirAccess = DirAccess.open(test_dir)
	assert_not_null(dir, "tests directory should exist")
	if dir == null:
		return
	var missing: Array[String] = []
	var manual_patterns: Array[String] = [
		"EventFlags.clear_all()",
		"PartyState.members.clear()",
		"PartyState.gold = 0",
	]
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			var file: FileAccess = FileAccess.open(test_dir + file_name, FileAccess.READ)
			if file != null:
				var content: String = file.get_as_text()
				file.close()
				if "before_each" in content:
					var has_manual: bool = false
					for pattern: String in manual_patterns:
						if pattern in content:
							has_manual = true
							break
					if has_manual and "reset_game_state" not in content:
						missing.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	assert_eq(
		missing.size(),
		0,
		(
			"Test files with manual singleton cleanup should use reset_game_state — found in: %s"
			% str(missing)
		),
	)
