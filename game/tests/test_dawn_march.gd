extends GutTest
## Tests for Dawn March cutscene trigger system and data validation.


func before_each() -> void:
	EventFlags.clear_all()
	GameManager.transition_data = {}
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()
	EventFlags.clear_all()


# --- 1. dawn_march.json loads with cutscene metadata ---
func test_dawn_march_json_has_cutscene_id() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	assert_eq(data.get("cutscene_id", ""), "dawn_march", "cutscene_id should be dawn_march")


func test_dawn_march_json_has_cutscene_tier() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	assert_eq(data.get("cutscene_tier", 0), 1, "cutscene_tier should be 1 (T1 Full)")


# --- 2. dawn_march.json has 16 entries ---
func test_dawn_march_has_16_entries() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	assert_eq(entries.size(), 16, "Should have 16 entries (12 dialogue + 4 credits)")


# --- 3. Entry 012 has flag_set ---
func test_entry_012_has_flag_set() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 11, "Should have at least 12 entries for entry 012")
	var entry_12: Dictionary = entries[11]
	assert_eq(
		entry_12.get("flag_set", ""),
		"opening_credits_seen",
		"Entry 012 should set opening_credits_seen flag"
	)


# --- 4. Entry 013 has title command ---
func test_entry_013_has_title_command() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 12, "Should have at least 13 entries for entry 013")
	var entry_13: Dictionary = entries[12]
	var commands: Array = entry_13.get("commands", [])
	assert_gt(commands.size(), 0, "Entry 013 should have commands")
	var title_cmd: Dictionary = commands[0]
	assert_eq(title_cmd.get("type", ""), "title", "First command should be title")
	assert_eq(
		title_cmd.get("text", ""), "PENDULUM OF DESPAIR", "Title text should be PENDULUM OF DESPAIR"
	)


# --- 5. Entry 001 has move commands with correct field name ---
func test_entry_001_move_commands_use_to_field() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	var entry_1: Dictionary = entries[0]
	var commands: Array = entry_1.get("commands", [])
	var move_cmds: Array = []
	for cmd: Variant in commands:
		if cmd is Dictionary and (cmd as Dictionary).get("type", "") == "move":
			move_cmds.append(cmd)
	assert_gt(move_cmds.size(), 0, "Entry 001 should have move commands")
	for cmd: Variant in move_cmds:
		var d: Dictionary = cmd as Dictionary
		assert_true(d.has("to"), "Move command must use 'to' field (not 'target')")
		assert_false(d.has("target"), "Move command must NOT have 'target' field")


# --- 6. All entries have required fields ---
func test_all_entries_have_required_fields() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	for i: int in range(entries.size()):
		var entry: Dictionary = entries[i]
		assert_true(entry.has("id"), "Entry %d missing 'id'" % i)
		assert_true(entry.has("speaker"), "Entry %d missing 'speaker'" % i)
		assert_true(entry.has("lines"), "Entry %d missing 'lines'" % i)


# --- 7. Trail map scene file exists ---
func test_trail_map_scene_exists() -> void:
	assert_true(
		ResourceLoader.exists("res://scenes/maps/cutscenes/dawn_march_trail.tscn"),
		"dawn_march_trail.tscn should exist"
	)


# --- 8. Entry 012 has fade-out command ---
func test_entry_012_has_fade_out_command() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 11, "Should have at least 12 entries for entry 012")
	var entry_12: Dictionary = entries[11]
	var commands: Array = entry_12.get("commands", [])
	var has_fade_out: bool = false
	for cmd: Variant in commands:
		if cmd is Dictionary:
			var d: Dictionary = cmd as Dictionary
			if d.get("type", "") == "fade" and d.get("direction", "") == "out":
				has_fade_out = true
	assert_true(has_fade_out, "Entry 012 should have fade-out command")


# --- 9. Entry 016 has fade-in command (return from black) ---
func test_entry_016_has_fade_in_command() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 15, "Should have at least 16 entries for entry 016")
	var entry_16: Dictionary = entries[15]
	var commands: Array = entry_16.get("commands", [])
	var has_fade_in: bool = false
	for cmd: Variant in commands:
		if cmd is Dictionary:
			var d: Dictionary = cmd as Dictionary
			if d.get("type", "") == "fade" and d.get("direction", "") == "in":
				has_fade_in = true
	assert_true(has_fade_in, "Entry 016 should have fade-in command")
