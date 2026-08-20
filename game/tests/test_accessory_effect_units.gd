extends GutTest
## Unit agreement between an accessory's written effect and the engine that
## implements it (issue #350).
##
## The Preemptive Charm was priced "+25%" in equipment.md and in
## accessories.json while combat-formulas.md and EncounterSystem both meant
## +25 PERCENTAGE POINTS. At the 12.5% base rate the two readings are 15.6%
## and 37.5% — the same words, materially different accessories, and nothing
## compared them. These guards compare them.

const EncounterSystem = preload("res://scripts/combat/encounter_system.gd")

## Terrain split every non-Pallor open zone uses
## (combat-formulas.md § Battle Formations).
const OPEN_RATES: Dictionary = {"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5}


func _read_repo_doc(rel_path: String) -> String:
	var repo_root: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var abs_path: String = repo_root.path_join(rel_path)
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.READ)
	if file == null:
		fail_test("cannot read %s (looked at %s) — the guard cannot run" % [rel_path, abs_path])
		return ""
	var content: String = file.get_as_text()
	file.close()
	return content


## Pull one row out of a markdown table by its leading cell.
func _table_row(doc: String, row_name: String) -> String:
	for line: String in doc.split("\n"):
		if line.begins_with("| %s |" % row_name):
			return line
	fail_test("no '%s' row found in the doc" % row_name)
	return ""


## The behavioral half: equipping the charm on open terrain must move
## preemptive from 12.5% to 37.5%. The multiplicative "+25%" reading would
## give 15.625%, so this fails loudly if anyone ever implements the words the
## doc used to use.
func test_charm_adds_percentage_points_not_a_percentage() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "preemptive_charm"}},
	]
	var bonus: float = EncounterSystem.get_preemptive_bonus(party)
	var boosted: Dictionary = EncounterSystem.apply_preemptive_bonus(OPEN_RATES, bonus)
	assert_almost_eq(
		float(boosted.get("preemptive", 0.0)),
		37.5,
		0.01,
		"12.5 + 25pp = 37.5; the +25% reading would give 15.625",
	)
	assert_almost_eq(
		float(boosted.get("back_attack", 99.0)),
		0.0,
		0.01,
		"the charm eats back attack first (combat-formulas.md § Battle Formations)",
	)
	assert_almost_eq(
		float(boosted.get("normal", 0.0)),
		62.5,
		0.01,
		"the 12.5pp remainder comes out of normal",
	)


## The documentation half: the row a player reads must not describe a
## percentage-point bonus as a percentage. equipment.md is the odd one out
## that #350 found; accessories.json carried the same words twice.
func test_equipment_doc_states_the_charm_bonus_in_percentage_points() -> void:
	var doc: String = _read_repo_doc("docs/story/equipment.md")
	if doc.is_empty():
		return
	var row: String = _table_row(doc, "Preemptive Charm")
	if row.is_empty():
		return
	assert_true(
		row.contains("+25pp"),
		"equipment.md's Preemptive Charm row should read +25pp, got: %s" % row,
	)
	assert_false(
		row.contains("+25%"),
		"equipment.md still prices the charm as a percentage: %s" % row,
	)


func test_accessory_data_states_the_charm_bonus_in_percentage_points() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/accessories.json")
	assert_true(data is Dictionary, "accessories.json parses")
	var records: Array = (data as Dictionary).get("accessories", [])
	assert_gt(records.size(), 10, "accessories.json should carry the full table")
	for entry: Variant in records:
		if not entry is Dictionary:
			continue
		var record: Dictionary = entry as Dictionary
		if record.get("id", "") != "preemptive_charm":
			continue
		for field: String in ["effect", "special"]:
			var text: String = str(record.get(field, ""))
			assert_false(
				text.contains("+25%"),
				"preemptive_charm.%s prices the charm as a percentage: %s" % [field, text],
			)
			assert_true(
				text.contains("+25pp"),
				"preemptive_charm.%s should read +25pp, got: %s" % [field, text],
			)
		return
	fail_test("preemptive_charm not found in accessories.json")
