extends GutTest
## Tests for the Opening Sequence (Phase B1) — party assembly flow,
## dialogue data existence, and overworld trigger wiring.


func before_each() -> void:
	PartyState.initialize_new_game()
	DataManager.clear_cache()
	EventFlags.clear_all()


func after_each() -> void:
	DataManager.clear_cache()
	EventFlags.clear_all()


# --- Party Assembly ---


func test_new_game_starts_with_two_members() -> void:
	PartyState.initialize_new_game()
	assert_eq(PartyState.members.size(), 2, "new game should start with 2 members")
	assert_true(PartyState.has_member("edren"), "edren should be in starting party")
	assert_true(PartyState.has_member("cael"), "cael should be in starting party")
	assert_false(PartyState.has_member("lira"), "lira should NOT be in starting party")
	assert_false(PartyState.has_member("sable"), "sable should NOT be in starting party")
	assert_false(PartyState.has_member("torren"), "torren should NOT be in starting party")
	assert_false(PartyState.has_member("maren"), "maren should NOT be in starting party")


func test_lira_can_be_added_to_party() -> void:
	PartyState.add_member("lira", 1)
	assert_true(PartyState.has_member("lira"), "lira should be present after add_member")


func test_sable_can_be_added_to_party() -> void:
	PartyState.add_member("sable", 1)
	assert_true(PartyState.has_member("sable"), "sable should be present after add_member")


func test_lira_sable_join_together_no_duplicates() -> void:
	PartyState.initialize_new_game()
	PartyState.add_member("lira", 1)
	PartyState.add_member("sable", 1)
	PartyState.add_member("lira", 1)
	PartyState.add_member("sable", 1)
	var lira_count: int = 0
	var sable_count: int = 0
	for m: Dictionary in PartyState.members:
		if m.get("character_id", "") == "lira":
			lira_count += 1
		elif m.get("character_id", "") == "sable":
			sable_count += 1
	assert_eq(lira_count, 1, "lira should appear exactly once")
	assert_eq(sable_count, 1, "sable should appear exactly once")


func test_full_party_assembly_order() -> void:
	PartyState.initialize_new_game()
	assert_eq(PartyState.members.size(), 2, "start with 2")
	PartyState.add_member("lira", 1)
	PartyState.add_member("sable", 1)
	assert_eq(PartyState.members.size(), 4, "4 after lira+sable")
	PartyState.add_member("torren", 1)
	assert_eq(PartyState.members.size(), 5, "5 after torren")
	PartyState.add_member("maren", 1)
	assert_eq(PartyState.members.size(), 6, "6 after maren — full party")


func test_lira_sable_go_to_active_party() -> void:
	PartyState.initialize_new_game()
	PartyState.add_member("lira", 1)
	PartyState.add_member("sable", 1)
	var active: Array = PartyState.formation.get("active", [])
	assert_eq(active.size(), 4, "all 4 should be active (Edren, Cael, Lira, Sable)")


func test_fifth_member_goes_to_reserve() -> void:
	PartyState.initialize_new_game()
	PartyState.add_member("lira", 1)
	PartyState.add_member("sable", 1)
	PartyState.add_member("torren", 1)
	var reserve: Array = PartyState.formation.get("reserve", [])
	assert_eq(reserve.size(), 1, "5th member should go to reserve")


# --- Starting Equipment ---


func test_lira_has_starting_equipment_entry() -> void:
	assert_true(
		PartyState.STARTING_EQUIPMENT.has("lira"),
		"lira should be in STARTING_EQUIPMENT",
	)


func test_sable_has_starting_equipment_entry() -> void:
	assert_true(
		PartyState.STARTING_EQUIPMENT.has("sable"),
		"sable should be in STARTING_EQUIPMENT",
	)


# --- Dialogue Data ---


func test_scene_2_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("vaelith_ember_vein")
	assert_false(data.is_empty(), "vaelith_ember_vein dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "scene 2 should have entries")


func test_scene_3_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("ironmouth_escape")
	assert_false(data.is_empty(), "ironmouth_escape dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "scene 3 should have entries")


func test_scene_4_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("dawn_march")
	assert_false(data.is_empty(), "dawn_march dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "scene 4 should have entries")


# --- Overworld Trigger Wiring ---


func test_overworld_has_scene2_trigger() -> void:
	var overworld: Node = _load_overworld()
	var trigger: Node = overworld.get_node_or_null("Entities/Scene2Trigger")
	assert_not_null(trigger, "overworld should have Entities/Scene2Trigger")
	assert_eq(
		str(trigger.get_meta("dialogue_scene_id", "")),
		"vaelith_ember_vein",
		"Scene2Trigger should reference vaelith_ember_vein dialogue",
	)
	assert_eq(
		str(trigger.get_meta("required_flag", "")),
		"vaelith_ember_vein",
		"Scene2Trigger should require vaelith_ember_vein flag",
	)
	overworld.queue_free()


func test_overworld_has_scene3_trigger() -> void:
	var overworld: Node = _load_overworld()
	var trigger: Node = overworld.get_node_or_null("Entities/Scene3Trigger")
	assert_not_null(trigger, "overworld should have Entities/Scene3Trigger")
	assert_eq(
		str(trigger.get_meta("flag", "")),
		"ironmouth_escape_seen",
		"Scene3Trigger should set ironmouth_escape_seen flag",
	)
	assert_eq(
		str(trigger.get_meta("required_flag", "")),
		"carradan_ambush_survived",
		"Scene3Trigger should require carradan_ambush_survived",
	)
	assert_eq(
		str(trigger.get_meta("dialogue_scene_id", "")),
		"ironmouth_escape",
		"Scene3Trigger should reference ironmouth_escape dialogue",
	)
	overworld.queue_free()


func test_overworld_has_scene4_trigger() -> void:
	var overworld: Node = _load_overworld()
	var trigger: Node = overworld.get_node_or_null("Entities/Scene4Trigger")
	assert_not_null(trigger, "overworld should have Entities/Scene4Trigger")
	assert_eq(
		str(trigger.get_meta("flag", "")),
		"opening_credits_seen",
		"Scene4Trigger should set opening_credits_seen flag",
	)
	assert_eq(
		str(trigger.get_meta("cutscene_scene_id", "")),
		"dawn_march",
		"Scene4Trigger should reference dawn_march cutscene",
	)
	overworld.queue_free()


func test_scene_triggers_in_story_order() -> void:
	var overworld: Node = _load_overworld()
	var s2: Node2D = overworld.get_node_or_null("Entities/Scene2Trigger") as Node2D
	var s3: Node2D = overworld.get_node_or_null("Entities/Scene3Trigger") as Node2D
	var s4: Node2D = overworld.get_node_or_null("Entities/Scene4Trigger") as Node2D
	assert_not_null(s2, "scene 2 trigger should exist")
	assert_not_null(s3, "scene 3 trigger should exist")
	assert_not_null(s4, "scene 4 trigger should exist")
	# Triggers should progress from east (Ember Vein) to west (Roothollow)
	assert_gt(s2.position.x, s3.position.x, "scene 2 should be east of scene 3")
	assert_gt(s3.position.x, s4.position.x, "scene 3 should be east of scene 4")
	overworld.queue_free()


# --- Party Join Flag Wiring ---


func test_exploration_checks_carradan_flag() -> void:
	var text: String = _read_file("res://scripts/core/exploration.gd")
	assert_true(
		text.contains("carradan_ambush_survived"),
		"exploration should check carradan_ambush_survived flag for party joins",
	)
	assert_true(
		text.contains('add_member("lira"'),
		"exploration should add lira on carradan flag",
	)
	assert_true(
		text.contains('add_member("sable"'),
		"exploration should add sable on carradan flag",
	)


# --- Helpers ---


func _load_overworld() -> Node:
	var scene: PackedScene = load("res://scenes/maps/overworld.tscn")
	return scene.instantiate()


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
