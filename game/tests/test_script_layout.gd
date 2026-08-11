extends GutTest
## Guards the documented GDScript directory layout (GAP-086).
##
## technical-architecture.md:64 places utilities under `scripts/util/`, and
## `scripts/autoload/` is reserved for the singletons actually registered in
## the `[autoload]` block of project.godot. `inventory_helpers.gd` is a static
## RefCounted helper that used to sit in `scripts/autoload/` despite never
## being registered; these tests keep it (and any future helper) out.

const AUTOLOAD_DIR := "res://scripts/autoload"
const UTIL_DIR := "res://scripts/util"
const PROJECT_GODOT := "res://project.godot"


## Script filenames (no directory) present in a res:// directory.
func _script_names_in(dir_path: String) -> PackedStringArray:
	var names := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		fail_test("cannot open directory %s" % dir_path)
		return names
	for file_name: String in dir.get_files():
		if file_name.ends_with(".gd"):
			names.append(file_name)
	return names


## Script basenames referenced by the [autoload] block of project.godot.
func _registered_autoload_scripts() -> PackedStringArray:
	var names := PackedStringArray()
	var file := FileAccess.open(PROJECT_GODOT, FileAccess.READ)
	if file == null:
		fail_test("cannot open %s" % PROJECT_GODOT)
		return names
	var in_section := false
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("["):
			in_section = line == "[autoload]"
			continue
		if not in_section or line.is_empty() or not line.contains("="):
			continue
		var value := line.split("=", true, 1)[1].strip_edges().trim_prefix('"').trim_suffix('"')
		names.append(value.trim_prefix("*").get_file())
	file.close()
	return names


func test_project_godot_registers_the_six_singletons() -> void:
	var registered := _registered_autoload_scripts()
	assert_eq(registered.size(), 6, "project.godot [autoload] must list exactly 6 singletons")


func test_autoload_dir_holds_only_registered_singletons() -> void:
	var registered := _registered_autoload_scripts()
	var on_disk := _script_names_in(AUTOLOAD_DIR)
	assert_gt(on_disk.size(), 0, "scripts/autoload/ must contain scripts")
	for script_name: String in on_disk:
		var msg := (
			"%s lives in scripts/autoload/ but is not registered in project.godot; " % script_name
			+ "unregistered helpers belong in scripts/util/ (GAP-086)"
		)
		assert_true(registered.has(script_name), msg)


func test_inventory_helpers_lives_in_util() -> void:
	assert_true(
		ResourceLoader.exists("res://scripts/util/inventory_helpers.gd"),
		"inventory_helpers.gd must live in scripts/util/"
	)
	assert_false(
		FileAccess.file_exists("res://scripts/autoload/inventory_helpers.gd"),
		"inventory_helpers.gd must not remain in scripts/autoload/"
	)


func test_util_dir_holds_no_registered_singleton() -> void:
	var registered := _registered_autoload_scripts()
	var on_disk := _script_names_in(UTIL_DIR)
	assert_gt(on_disk.size(), 0, "scripts/util/ must contain scripts")
	for script_name: String in on_disk:
		assert_false(
			registered.has(script_name),
			"%s is a registered autoload and must live in scripts/autoload/" % script_name
		)
