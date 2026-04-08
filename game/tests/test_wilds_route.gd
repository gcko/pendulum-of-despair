extends GutTest
## Integration tests for the Wilds Route — Roothollow, Maren's Refuge,
## overworld transitions, shop data, encounter zones, and party assembly.


func before_each() -> void:
	DataManager.clear_cache()
	EventFlags.clear_all()


# --- Scene Existence ---


func test_roothollow_scene_exists() -> void:
	assert_true(FileAccess.file_exists("res://scenes/maps/towns/roothollow.tscn"))


func test_marens_refuge_scene_exists() -> void:
	assert_true(FileAccess.file_exists("res://scenes/maps/towns/marens_refuge.tscn"))


# --- Overworld Transitions ---


func test_overworld_has_roothollow_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("towns/roothollow"), "overworld should target roothollow")


func test_overworld_has_marens_refuge_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("towns/marens_refuge"), "overworld should target marens_refuge")


func test_overworld_wilds_spawn_markers() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("from_roothollow"), "should have from_roothollow marker")
	assert_true(text.contains("from_marens_refuge"), "should have from_marens_refuge marker")


func test_roothollow_exit_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(
		text.contains('target_map = "overworld"'),
		"roothollow exit should target overworld",
	)


func test_marens_refuge_exit_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(
		text.contains('target_map = "overworld"'),
		"marens_refuge exit should target overworld",
	)


# --- Round-Trip Validation ---


func test_overworld_to_roothollow_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var rh: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(ow.contains("towns/roothollow"), "overworld targets roothollow")
	assert_true(rh.contains('"overworld"'), "roothollow targets overworld")
	assert_true(ow.contains("from_roothollow"), "overworld has from_roothollow spawn")
	assert_true(rh.contains("from_overworld"), "roothollow has from_overworld spawn")


func test_overworld_to_marens_refuge_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var mr: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(ow.contains("towns/marens_refuge"), "overworld targets marens_refuge")
	assert_true(mr.contains('"overworld"'), "marens_refuge targets overworld")
	assert_true(ow.contains("from_marens_refuge"), "overworld has from_marens_refuge spawn")
	assert_true(mr.contains("from_overworld"), "marens_refuge has from_overworld spawn")


# --- Shop Data ---


func test_roothollow_herbalist_shop_exists() -> void:
	var data: Dictionary = DataManager.load_shop("roothollow_herbalist")
	assert_false(data.is_empty(), "roothollow herbalist shop should load")
	var shop: Dictionary = data.get("shop", {})
	assert_false(shop.is_empty(), "shop wrapper should contain shop object")


func test_roothollow_herbalist_has_despair_ward() -> void:
	var data: Dictionary = DataManager.load_shop("roothollow_herbalist")
	var shop: Dictionary = data.get("shop", data)
	var inv: Array = shop.get("inventory", [])
	var found: bool = false
	for item: Variant in inv:
		if item is Dictionary and (item as Dictionary).get("item_id", "") == "despair_ward":
			found = true
			break
	assert_true(found, "roothollow herbalist should stock despair_ward")


# --- Dialogue Data ---


func test_torren_encounter_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("torren_encounter")
	assert_false(data.is_empty(), "torren_encounter dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "torren_encounter should have entries")


func test_marens_warning_dialogue_exists() -> void:
	var data: Dictionary = DataManager.load_dialogue("scene_6_marens_warning")
	assert_false(data.is_empty(), "scene_6_marens_warning dialogue should load")
	var entries: Array = data.get("entries", [])
	assert_gt(entries.size(), 0, "scene_6_marens_warning should have entries")


# --- Encounter Zone ---


func test_thornmere_wilds_zone_exists() -> void:
	var data: Dictionary = DataManager.load_encounters("overworld")
	var zones: Array = data.get("zones", [])
	var found: bool = false
	for z: Variant in zones:
		if z is Dictionary and (z as Dictionary).get("zone_id", "") == "thornmere_wilds":
			found = true
			var groups: Array = (z as Dictionary).get("groups", [])
			assert_gt(groups.size(), 0, "thornmere_wilds should have encounter groups")
			break
	assert_true(found, "overworld should have thornmere_wilds zone")


# --- Scene 5/6 Trigger Wiring ---


func test_roothollow_has_scene5_trigger() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(text.contains("torren_joined"), "roothollow should have torren_joined flag trigger")
	assert_true(
		text.contains("torren_encounter"),
		"roothollow should reference torren_encounter dialogue",
	)


func test_marens_refuge_has_scene6_trigger() -> void:
	var text: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(text.contains("maren_warning"), "marens_refuge should have maren_warning flag")
	assert_true(
		text.contains("scene_6_marens_warning"),
		"marens_refuge should reference scene_6 dialogue",
	)


func test_marens_refuge_requires_torren_joined() -> void:
	var text: String = _read_file("res://scenes/maps/towns/marens_refuge.tscn")
	assert_true(
		text.contains("required_flag") and text.contains("torren_joined"),
		"scene 6 trigger should require torren_joined flag",
	)


# --- NPC Metadata ---


func test_roothollow_has_shop_npc() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(
		text.contains("roothollow_herbalist"),
		"roothollow should have herbalist shop NPC",
	)


func test_roothollow_has_vessa_npc() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(text.contains('"vessa"'), "roothollow should have Vessa NPC")


func test_roothollow_has_save_point() -> void:
	var text: String = _read_file("res://scenes/maps/towns/roothollow.tscn")
	assert_true(
		text.contains("roothollow_shrine"),
		"roothollow should have save point",
	)


# --- Helper ---


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
