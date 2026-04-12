extends GutTest
## Integration tests for Fenmother's Hollow dungeon — tileset, enemy data,
## encounters, dialogue, floor maps, chests, save points, bosses, transitions,
## and overworld wiring.


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


# --- Tileset / Assets ---


func test_placeholder_tileset_png_exists() -> void:
	assert_true(FileAccess.file_exists("res://assets/tilesets/placeholder_dungeon.png"))


func test_placeholder_tileset_tres_exists() -> void:
	assert_true(ResourceLoader.exists("res://assets/tilesets/placeholder_dungeon.tres"))


func test_tileset_has_swamp_tiles() -> void:
	var ts: TileSet = load("res://assets/tilesets/placeholder_dungeon.tres")
	assert_not_null(ts, "tileset should load")
	var src: TileSetAtlasSource = ts.get_source(0) as TileSetAtlasSource
	assert_not_null(src, "atlas source should exist")
	for x: int in [10, 11, 12, 13]:
		assert_true(src.has_tile(Vector2i(x, 0)), "tile %d should exist" % x)


# --- Enemy Data ---


func test_marsh_serpent_data() -> void:
	var e: Dictionary = _find_enemy("marsh_serpent", "act_i")
	assert_false(e.is_empty(), "marsh_serpent should load")
	assert_eq(e.get("hp", 0), 140, "marsh_serpent HP should be 140")


func test_bog_leech_data() -> void:
	var e: Dictionary = _find_enemy("bog_leech", "act_i")
	assert_false(e.is_empty(), "bog_leech should load")
	assert_eq(e.get("hp", 0), 192, "bog_leech HP should be 192")


func test_drowned_bones_data() -> void:
	var e: Dictionary = _find_enemy("drowned_bones", "act_i")
	assert_false(e.is_empty(), "drowned_bones should load")
	assert_eq(e.get("hp", 0), 211, "drowned_bones HP should be 211")


func test_swamp_lurker_data() -> void:
	var e: Dictionary = _find_enemy("swamp_lurker", "act_i")
	assert_false(e.is_empty(), "swamp_lurker should load")
	assert_eq(e.get("hp", 0), 254, "swamp_lurker HP should be 254")


func test_ley_jellyfish_data() -> void:
	var e: Dictionary = _find_enemy("ley_jellyfish", "act_i")
	assert_false(e.is_empty(), "ley_jellyfish should load")
	assert_eq(e.get("hp", 0), 231, "ley_jellyfish HP should be 231")


func test_polluted_elemental_data() -> void:
	var e: Dictionary = _find_enemy("polluted_elemental", "act_i")
	assert_false(e.is_empty(), "polluted_elemental should load")
	assert_eq(e.get("hp", 0), 273, "polluted_elemental HP should be 273")


func test_corrupted_spawn_data() -> void:
	var e: Dictionary = _find_enemy("corrupted_spawn", "act_i")
	assert_false(e.is_empty(), "corrupted_spawn should load")
	assert_eq(e.get("hp", 0), 288, "corrupted_spawn HP should be 288")


func test_drowned_sentinel_data() -> void:
	var e: Dictionary = _find_enemy("drowned_sentinel", "act_i")
	assert_false(e.is_empty(), "drowned_sentinel should load")
	assert_eq(e.get("hp", 0), 4000, "drowned_sentinel HP should be 4000")


func test_corrupted_fenmother_data() -> void:
	var e: Dictionary = _find_enemy("corrupted_fenmother", "act_i")
	assert_false(e.is_empty(), "corrupted_fenmother should load")
	assert_eq(e.get("hp", 0), 18000, "corrupted_fenmother HP should be 18000")


# --- Encounter Data ---


func test_encounter_data_exists() -> void:
	var d: Dictionary = DataManager.load_encounters("fenmothers_hollow")
	assert_false(d.is_empty())


func test_encounter_floor_ids() -> void:
	var d: Dictionary = DataManager.load_encounters("fenmothers_hollow")
	var key: String = "floors" if d.has("floors") else "zones"
	var entries: Array = d.get(key, [])
	var ids: Array = []
	for entry: Variant in entries:
		if entry is Dictionary:
			ids.append(
				(entry as Dictionary).get("floor_id", (entry as Dictionary).get("zone_id", ""))
			)
	assert_true("1-2" in ids, "should have floor_id 1-2")
	assert_true("3" in ids, "should have floor_id 3")


# --- Dialogue Data ---


func test_fenmother_battle_dialogue() -> void:
	var d: Dictionary = DataManager.load_dialogue("fenmother_battle")
	assert_false(d.is_empty())
	assert_eq(d.get("entries", []).size(), 4)


func test_water_of_life_dialogue() -> void:
	var d: Dictionary = DataManager.load_dialogue("water_of_life")
	assert_false(d.is_empty())
	assert_eq(d.get("entries", []).size(), 4)


func test_fenmother_cleansing_dialogue() -> void:
	var d: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
	assert_false(d.is_empty())
	assert_eq(d.get("entries", []).size(), 5)


# --- Floor Maps: Metadata ---


func test_f1_metadata() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	assert_true(text.contains('metadata/map_id = "dungeons/fenmothers_hollow_f1"'))
	assert_true(text.contains('metadata/dungeon_id = "fenmothers_hollow"'))
	assert_true(text.contains('metadata/floor_id = "1-2"'))
	assert_true(text.contains('metadata/location_name = "Fenmother'))


func test_f2_metadata() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_true(text.contains('metadata/map_id = "dungeons/fenmothers_hollow_f2"'))
	assert_true(text.contains('metadata/dungeon_id = "fenmothers_hollow"'))
	assert_true(text.contains('metadata/floor_id = "1-2"'))
	assert_true(text.contains('metadata/location_name = "Fenmother'))


func test_f3_metadata() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_true(text.contains('metadata/map_id = "dungeons/fenmothers_hollow_f3"'))
	assert_true(text.contains('metadata/dungeon_id = "fenmothers_hollow"'))
	assert_true(text.contains('metadata/floor_id = "3"'))
	assert_true(text.contains('metadata/location_name = "Fenmother'))


# --- Floor Maps: Tileset Reference ---


func test_f1_uses_placeholder_tileset() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	assert_true(text.contains("placeholder_dungeon.tres"))


func test_f2_uses_placeholder_tileset() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_true(text.contains("placeholder_dungeon.tres"))


func test_f3_uses_placeholder_tileset() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_true(text.contains("placeholder_dungeon.tres"))


# --- Chests ---


func test_f1_chests() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	assert_true(text.contains('metadata/item_id = "marsh_cloak"'))
	assert_true(text.contains('metadata/item_id = "spirit_tonic"'))


func test_f2_chests() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_true(text.contains('metadata/item_id = "fenmothers_scale"'))
	assert_true(text.contains('metadata/item_id = "spirit_bound_spear"'))
	assert_true(text.contains('metadata/item_id = "ancient_totem"'))


func test_f3_blessing_chest_removed() -> void:
	# Fenmother's Blessing is now given by Caden in Duskfen Spirit Shrine (Phase A2b)
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_false(
		text.contains('metadata/item_id = "fenmothers_blessing"'),
		"blessing chest removed -- Caden gives it in shrine"
	)


# --- Save Points ---


func test_f1_has_save_point() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	assert_true(text.contains("save_point_id"))


func test_f2_has_save_point() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_true(text.contains("save_point_id"))


func test_f3_has_save_point() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_true(text.contains("save_point_id"))


# --- Boss Triggers ---


func test_f2_has_drowned_sentinel_boss() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_true(text.contains('metadata/boss_id = "drowned_sentinel"'))
	assert_true(text.contains('metadata/flag = "drowned_sentinel_defeated"'))


func test_f3_has_corrupted_fenmother_boss() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_true(text.contains('metadata/boss_id = "corrupted_fenmother"'))
	assert_true(text.contains('metadata/flag = "fenmother_boss_defeated"'))


# --- Transitions ---


func test_f1_transition_to_f2() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	assert_true(text.contains('metadata/target_map = "dungeons/fenmothers_hollow_f2"'))


func test_f2_transition_to_f3_with_flag() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_true(text.contains('metadata/target_map = "dungeons/fenmothers_hollow_f3"'))
	assert_true(text.contains('metadata/required_flag = "drowned_sentinel_defeated"'))


func test_f3_transition_to_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_true(text.contains('metadata/target_map = "overworld"'))


# --- Overworld Wiring ---


func test_overworld_has_fenmothers_hollow_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains('metadata/target_map = "dungeons/fenmothers_hollow_f1"'))


func test_overworld_has_fenmothers_hollow_spawn() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains('name="from_fenmothers_hollow"'))


# --- Flag-Gated Transition Logic ---


func test_exploration_handles_required_flag() -> void:
	var text: String = _read_file("res://scripts/core/exploration.gd")
	assert_true(
		text.contains("required_flag"),
		"exploration.gd should check required_flag in transition handling",
	)


# --- Helpers ---


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _find_enemy(enemy_id: String, act: String) -> Dictionary:
	var enemies: Array = DataManager.load_enemies(act)
	for entry: Variant in enemies:
		if entry is Dictionary and (entry as Dictionary).get("id", "") == enemy_id:
			return entry as Dictionary
	return {}
