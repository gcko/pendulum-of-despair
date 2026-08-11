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

## Hard maximum. A file past this fails the suite; see § 1.2a for why 400 is
## the aim and 600 the ceiling.
const MAX_SCRIPT_LINES: int = 600

## The aim. Files between this and MAX_SCRIPT_LINES are acceptable only when
## breaking them down is intrinsically difficult, and § 1.2a names each one.
const TARGET_SCRIPT_LINES: int = 400


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


# ── Script size budget (technical-architecture.md § 1.2a) ───────────────


## Every .gd under res://scripts, recursively, as "path: line_count".
func _script_line_counts() -> Dictionary:
	var counts: Dictionary = {}
	var pending: Array[String] = ["res://scripts"]
	while not pending.is_empty():
		var dir_path: String = pending.pop_back()
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir == null:
			fail_test("cannot open directory %s" % dir_path)
			return counts
		dir.list_dir_begin()
		var entry: String = dir.get_next()
		while entry != "":
			# "." and ".." would recurse forever.
			if entry != "." and entry != "..":
				var full: String = dir_path.path_join(entry)
				if dir.current_is_dir():
					pending.append(full)
				elif entry.ends_with(".gd"):
					var f: FileAccess = FileAccess.open(full, FileAccess.READ)
					if f == null:
						fail_test("cannot open %s (error %d)" % [full, FileAccess.get_open_error()])
						return counts
					counts[full] = f.get_as_text().split("\n").size()
					f.close()
			entry = dir.get_next()
		dir.list_dir_end()
	return counts


func test_no_script_exceeds_the_hard_line_maximum() -> void:
	var counts: Dictionary = _script_line_counts()
	assert_gt(counts.size(), 20, "the scan must actually find the script tree")
	var over: Array[String] = []
	for path: String in counts:
		if int(counts[path]) > MAX_SCRIPT_LINES:
			over.append("%s (%d)" % [path, counts[path]])
	over.sort()
	assert_eq(
		over.size(),
		0,
		(
			"scripts over the %d-line hard maximum (technical-architecture.md 1.2a): %s"
			% [MAX_SCRIPT_LINES, str(over)]
		)
	)


func test_files_between_the_aim_and_the_maximum_are_the_documented_ones() -> void:
	# Not a failure -- 400-600 is allowed. This pins WHICH files are there, so a
	# new arrival is a deliberate decision with a justification in 1.2a rather
	# than something that drifted in unnoticed.
	var allowed: Array[String] = [
		"res://scripts/autoload/audio_manager.gd",
		"res://scripts/autoload/party_state.gd",
		"res://scripts/combat/battle_manager.gd",
		"res://scripts/core/exploration.gd",
	]
	var counts: Dictionary = _script_line_counts()
	var found: Array[String] = []
	for path: String in counts:
		if int(counts[path]) > TARGET_SCRIPT_LINES:
			found.append(path)
	found.sort()
	for path: String in found:
		assert_has(
			allowed,
			path,
			(
				(
					"%s is over the %d-line aim; either extract from it or add it to 1.2a "
					+ "with the reason and list it here"
				)
				% [path, TARGET_SCRIPT_LINES]
			)
		)
