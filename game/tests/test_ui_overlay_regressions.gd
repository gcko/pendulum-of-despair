extends GutTest
## Regression guards for the overlay and UI layer: menu scrolling, the shop
## act filter, the title Config entry, overlay push/pop recovery and swap,
## the save/load re-entry guards, and the guarded input-consume helper.
##
## Split out of the 968-line test_issue_fixes.gd (#374).

const MagicScript: GDScript = preload("res://scripts/ui/menu_magic.gd")
const AbilitiesScript: GDScript = preload("res://scripts/ui/menu_abilities.gd")
const ShopScript: GDScript = preload("res://scripts/ui/shop_overlay.gd")
const CutsceneScript: GDScript = preload("res://scripts/core/cutscene_player.gd")
const TitleScript: GDScript = preload("res://scripts/core/title.gd")
const DialogueScript: GDScript = preload("res://scripts/ui/dialogue_box.gd")
const MenuOverlayScript: GDScript = preload("res://scripts/ui/menu_overlay.gd")
const SaveLoadScript: GDScript = preload("res://scripts/ui/save_load.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


# ==========================================================================
# Issue cc7: menu_magic and menu_abilities scroll
# ==========================================================================


func test_menu_magic_scroll_implemented() -> void:
	var source: String = MagicScript.source_code
	assert_true(
		"_scroll_offset +=" in source or "_scroll_offset -=" in source,
		"menu_magic should modify _scroll_offset for scrolling",
	)


func test_menu_abilities_scroll_implemented() -> void:
	var source: String = AbilitiesScript.source_code
	assert_true(
		"_scroll_offset +=" in source or "_scroll_offset -=" in source,
		"menu_abilities should modify _scroll_offset for scrolling",
	)


# ==========================================================================
# Issue ugq: shop_overlay dynamic act filter
# ==========================================================================


func test_shop_overlay_dynamic_act_filter() -> void:
	var source: String = ShopScript.source_code
	assert_true(
		"_get_current_act()" in source,
		"shop_overlay should use dynamic act filter",
	)


# ==========================================================================
# Issue 58d: title.gd Config not permanently disabled
# ==========================================================================


func test_title_config_not_unconditionally_disabled() -> void:
	var source: String = TitleScript.source_code
	assert_false(
		"CONFIG:\n\t\t\treturn true" in source,
		"Config should not be unconditionally disabled",
	)


# ==========================================================================
# Issue vtj: push_overlay silent pop recovery
# ==========================================================================


func test_push_overlay_silent_pop_recovery_code_exists() -> void:
	# Structural test: verify the recovery code exists in push_overlay.
	# Cannot mutate const OVERLAY_SCENES in Godot 4.6, so we verify
	# the recovery pattern exists in source.
	var source: String = (preload("res://scripts/autoload/game_manager.gd") as GDScript).source_code
	assert_true(
		"did_silent_pop" in source,
		"push_overlay should track silent pop for recovery",
	)
	# Verify the recovery unpauses the tree
	assert_true(
		"get_tree().paused = false" in source,
		"recovery should unpause tree",
	)


func test_game_manager_overlay_enum_has_shop() -> void:
	# Access SHOP directly — will error at parse time if missing
	var shop_val: int = GameManager.OverlayState.SHOP
	assert_gte(shop_val, 0, "OverlayState should include SHOP")


# ==========================================================================
# Viewport null-guard: _consume_input() helper replaces bare calls
# ==========================================================================


func test_no_bare_get_viewport_set_input_as_handled() -> void:
	# Structural test: grep game/scripts/ for unguarded get_viewport().set_input_as_handled()
	# and assert zero matches. All call sites should use a guarded _consume_input() helper
	# or an explicit null-check pattern.
	var scripts_dir: String = "res://scripts/"
	var dir: DirAccess = DirAccess.open(scripts_dir)
	assert_not_null(dir, "scripts directory should exist")
	if dir == null:
		return
	var bare_call_files: Array[String] = []
	_scan_for_bare_viewport_calls(scripts_dir, bare_call_files)
	assert_eq(
		bare_call_files.size(),
		0,
		(
			"No scripts should have bare get_viewport().set_input_as_handled() — found in: %s"
			% str(bare_call_files)
		),
	)


func _scan_for_bare_viewport_calls(path: String, results: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var full_path: String = path.path_join(file_name)
		if dir.current_is_dir():
			_scan_for_bare_viewport_calls(full_path, results)
		elif file_name.ends_with(".gd"):
			var script: GDScript = load(full_path) as GDScript
			if script != null and "get_viewport().set_input_as_handled()" in script.source_code:
				results.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()


func test_consume_input_helper_exists_in_ui_scripts() -> void:
	# Verify each UI script that handles input has the _consume_input helper.
	var scripts_with_helper: Array[GDScript] = [
		CutsceneScript,
		DialogueScript,
		MenuOverlayScript,
		ShopScript,
		SaveLoadScript,
	]
	for script: GDScript in scripts_with_helper:
		assert_true(
			"func _consume_input()" in script.source_code,
			"%s should have _consume_input() helper" % script.resource_path,
		)


# ==========================================================================
# Issue orb: overlay lifecycle test pattern
# ==========================================================================


func test_overlay_state_set_and_clear_pattern() -> void:
	# Documents the test pattern for overlay lifecycle management.
	# Uses TestHelpers to set overlay state, verifies it, tears down, and verifies reset.
	TestHelpers.setup_overlay_state(GameManager.OverlayState.MENU)
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.MENU,
		"overlay should be set to MENU",
	)
	TestHelpers.teardown_overlay()
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"overlay should be reset to NONE",
	)


# ==========================================================================
# Bug fix: save_load.gd double-load / double-save re-entry guard
# ==========================================================================


func test_save_load_has_load_in_progress_guard() -> void:
	var source: String = SaveLoadScript.source_code
	assert_true(
		"_load_in_progress" in source,
		"save_load.gd should have _load_in_progress guard variable",
	)
	# Verify the guard is checked at the start of _do_load
	var do_load_pos: int = source.find("func _do_load(")
	assert_gt(do_load_pos, 0, "_do_load should exist")
	var next_func: int = source.find("\nfunc ", do_load_pos + 1)
	var do_load_body: String = source.substr(do_load_pos, next_func - do_load_pos)
	assert_true(
		"if _load_in_progress" in do_load_body,
		"_do_load should check _load_in_progress at entry",
	)


func test_save_load_has_save_in_progress_guard() -> void:
	var source: String = SaveLoadScript.source_code
	assert_true(
		"_save_in_progress" in source,
		"save_load.gd should have _save_in_progress guard variable",
	)
	var do_save_pos: int = source.find("func _do_save(")
	assert_gt(do_save_pos, 0, "_do_save should exist")
	var next_func: int = source.find("\nfunc ", do_save_pos + 1)
	var do_save_body: String = source.substr(do_save_pos, next_func - do_save_pos)
	assert_true(
		"if _save_in_progress" in do_save_body,
		"_do_save should check _save_in_progress at entry",
	)


# ==========================================================================
# Bug fix: menu_overlay.gd overlay swap uses silent pop (no gap)
# ==========================================================================


func test_overlay_swap_no_gap() -> void:
	# Structural: _open_save should use pop_overlay(true) for silent pop
	# followed by immediate push_overlay, not call_deferred.
	var source: String = MenuOverlayScript.source_code
	var open_save_pos: int = source.find("func _open_save(")
	assert_gt(open_save_pos, 0, "_open_save should exist")
	var next_func: int = source.find("\nfunc ", open_save_pos + 1)
	var open_save_body: String = source.substr(open_save_pos, next_func - open_save_pos)
	assert_true(
		"pop_overlay(true)" in open_save_body,
		"_open_save should use silent pop_overlay(true)",
	)
	assert_false(
		"call_deferred" in open_save_body,
		"_open_save should NOT use call_deferred (causes one-frame gap)",
	)
	assert_true(
		"push_overlay" in open_save_body,
		"_open_save should call push_overlay directly after silent pop",
	)
