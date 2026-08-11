extends GutTest
## Guards the documented GDScript directory layout (GAP-086).
##
## technical-architecture.md § 1.1 Directory Structure > 'Static helpers'
## places utilities under `scripts/util/`, and
## `scripts/autoload/` is reserved for the singletons actually registered in
## the `[autoload]` block of project.godot. `inventory_helpers.gd` is a static
## RefCounted helper that used to sit in `scripts/autoload/` despite never
## being registered; these tests keep it (and any future helper) out.

const AUTOLOAD_DIR := "res://scripts/autoload"
const UTIL_DIR := "res://scripts/util"
const PROJECT_GODOT := "res://project.godot"

## The budget's canonical home, relative to the repo root (outside res://).
const ARCH_DOC := "docs/plans/technical-architecture.md"
const BUDGET_HEADING := "### 1.2a"

## Hard maximum. A file past this fails the suite; see § 1.2a for why 400 is
## the aim and 600 the ceiling.
const MAX_SCRIPT_LINES: int = 600

## The aim. Files between this and MAX_SCRIPT_LINES are acceptable only when
## breaking them down is intrinsically difficult, and § 1.2a names each one.
const TARGET_SCRIPT_LINES: int = 400

## Trees the hard maximum applies to. `res://tests` used to be outside the
## walk entirely, which is how three test files reached 968, 623 and 613
## lines unchecked (#374).
const CEILING_ROOTS: Array[String] = ["res://scripts", "res://tests"]

## Trees the 400-line aim applies to. Deliberately narrower than
## CEILING_ROOTS: § 1.2a exempts test suites from the aim, because a test
## file's length tracks how many behaviours its subject has rather than any
## property of its own design. The exemption is a documented decision, so
## the guard below checks that the doc still states it.
const AIM_ROOTS: Array[String] = ["res://scripts"]

## Files in the 400-600 band that § 1.2a does not name yet.
##
## A hand-kept copy of the doc's list drifts from it silently — which is how
## `battle_manager.gd` came to sit in this file's allowlist while § 1.2a still
## named only three files. So the doc is now the allowlist, and this is the
## ratchet for the gap: shrink-only, and the suite fails at BOTH ends. A band
## file named in neither the doc nor here fails, and an entry here that is no
## longer needed fails too, so the list cannot outlive its reason.
##
## Do not add to it. Write the justification into § 1.2a instead.
const UNDOCUMENTED_BAND_FILES: Dictionary = {}


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


## Every .gd under `roots`, recursively, as "path: line_count".
##
## The vendored res://addons/gut tree is in neither root list: it is
## third-party code and stays outside the budget (#374).
func _script_line_counts(roots: Array[String]) -> Dictionary:
	var counts: Dictionary = {}
	var pending: Array[String] = roots.duplicate()
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


## _script_line_counts, plus the assertions that the walk reached every root.
##
## The walk missing a root — or the root list being emptied — is the failure
## neither budget test can survive: it would report a clean tree while never
## looking at one, and with nothing over the threshold the test would assert
## nothing at all and still be counted as passing. So both tests take their
## counts through here instead of calling _script_line_counts directly, which
## also means neither can be left behind when the other gains a guard.
func _scanned_line_counts(roots: Array[String]) -> Dictionary:
	var counts: Dictionary = _script_line_counts(roots)
	assert_gt(counts.size(), 20, "the scan must actually find the script tree")
	for root: String in roots:
		var seen: bool = false
		for path: String in counts:
			if path.begins_with(root + "/"):
				seen = true
				break
		assert_true(seen, "the scan must reach %s" % root)
	return counts


func test_no_script_exceeds_the_hard_line_maximum() -> void:
	var counts: Dictionary = _scanned_line_counts(CEILING_ROOTS)
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


## Read a repo doc that lives outside res://. Fails loudly if unreachable, so a
## moved doc cannot silently turn the guard below into a no-op.
func _read_repo_doc(rel_path: String) -> String:
	var repo_root: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var abs_path: String = repo_root.path_join(rel_path)
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.READ)
	if file == null:
		fail_test(
			(
				"cannot open %s (error %d) — the budget guard cannot run"
				% [abs_path, FileAccess.get_open_error()]
			)
		)
		return ""
	var content: String = file.get_as_text()
	file.close()
	return content


## Body of § 1.2a Script Size Budget, or "" after failing the test.
func _budget_section() -> String:
	var doc: String = _read_repo_doc(ARCH_DOC)
	if doc.is_empty():
		return ""
	var collecting := false
	var body := PackedStringArray()
	for line: String in doc.split("\n"):
		if collecting:
			# Any heading at all ends the section; the next one is § 1.3.
			if line.begins_with("#"):
				break
			body.append(line)
		elif line.begins_with(BUDGET_HEADING):
			collecting = true
	if not collecting:
		fail_test(
			"%s has no `%s` heading — the budget guard cannot run" % [ARCH_DOC, BUDGET_HEADING]
		)
		return ""
	return "\n".join(body)


## True when `text` names `base_name` as a whole filename, not as the tail of a
## longer one — `exploration.gd` must not be found inside
## `exploration_interactions.gd`.
func _names_file(text: String, base_name: String) -> bool:
	var pattern := "(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % base_name.replace(".", "\\.")
	var re: RegEx = RegEx.create_from_string(pattern)
	assert_not_null(re, "regex for %s must compile" % base_name)
	return re != null and re.search(text) != null


func test_files_between_the_aim_and_the_maximum_are_justified_in_the_doc() -> void:
	# 400-600 is allowed, so this is not a size assertion. It asserts that the
	# doc and the tree agree about WHICH files are there: every band file must
	# carry a written justification in § 1.2a. Restating the list here instead
	# is what let the two drift apart in the first place.
	var section: String = _budget_section()
	if section.is_empty():
		return  # _budget_section already failed the test
	var counts: Dictionary = _scanned_line_counts(AIM_ROOTS)
	var still_undocumented: Dictionary = {}
	for path: String in counts:
		if int(counts[path]) <= TARGET_SCRIPT_LINES:
			continue
		var base: String = path.get_file()
		if _names_file(section, base):
			continue
		still_undocumented[base] = true
		assert_true(
			UNDOCUMENTED_BAND_FILES.has(base),
			(
				(
					"%s is over the %d-line aim but %s § 1.2a does not name it; "
					+ "either extract from it, or write the justification into § 1.2a"
				)
				% [path, TARGET_SCRIPT_LINES, ARCH_DOC]
			)
		)
	# Shrink-only: an entry that is no longer needed must go, or the list turns
	# back into the stale hand-kept copy this test replaced.
	for base: String in UNDOCUMENTED_BAND_FILES:
		assert_true(
			still_undocumented.has(base),
			(
				(
					"stale UNDOCUMENTED_BAND_FILES entry for %s — § 1.2a now names it "
					+ "(or it dropped under %d lines); delete the entry"
				)
				% [base, TARGET_SCRIPT_LINES]
			)
		)


func test_the_doc_states_which_trees_the_budget_covers() -> void:
	# The scan's seed paths ARE the budget's scope, so leaving them
	# undocumented makes the scope an accident rather than a decision — which
	# is exactly how game/tests/ stayed unscanned while three files there ran
	# past the hard maximum (#374). Every tree the ceiling walks must be named
	# in § 1.2a, and so must the narrower scope of the 400-line aim.
	var section: String = _budget_section()
	if section.is_empty():
		return  # _budget_section already failed the test
	for root: String in CEILING_ROOTS:
		var tree: String = "%s/" % root.trim_prefix("res://")
		assert_true(
			section.contains(tree),
			(
				"§ 1.2a must say how the %d-line maximum applies to `%s`, because the guard walks it"
				% [MAX_SCRIPT_LINES, tree]
			)
		)


# ── Formation shape robustness (Copilot review, PR #357) ───────────────


func test_add_member_repairs_a_malformed_formation() -> void:
	# load_from_save assigns a saved formation verbatim, so a save missing a key
	# used to crash the next party join on a direct index. RED without
	# _ensure_formation_shape().
	var roster: PartyRoster = PartyRoster.new(PartyState)
	var saved: Dictionary = PartyState.formation.duplicate(true)
	var saved_members: Array = PartyState.members.duplicate(true)
	PartyState.formation = {"active": []}  # no "reserve", no "rows"
	roster.add_member("lira", 1)
	assert_true(PartyState.formation.has("reserve"), "reserve is repaired, not crashed on")
	assert_true(PartyState.formation.has("rows"), "rows is repaired, not crashed on")
	PartyState.formation = saved
	PartyState.members = saved_members
