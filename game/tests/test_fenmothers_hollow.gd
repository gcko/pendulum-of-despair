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
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	assert_eq(str(map.get_meta("map_id", "")), "dungeons/fenmothers_hollow_f1")
	assert_eq(str(map.get_meta("dungeon_id", "")), "fenmothers_hollow")
	assert_eq(str(map.get_meta("floor_id", "")), "1-2")
	assert_eq(str(map.get_meta("location_name", "")), "Fenmother's Hollow - Flooded Entry")
	map.queue_free()


func test_f2_metadata() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	assert_eq(str(map.get_meta("map_id", "")), "dungeons/fenmothers_hollow_f2")
	assert_eq(str(map.get_meta("dungeon_id", "")), "fenmothers_hollow")
	assert_eq(str(map.get_meta("floor_id", "")), "1-2")
	assert_eq(str(map.get_meta("location_name", "")), "Fenmother's Hollow - Submerged Temple")
	map.queue_free()


func test_f3_metadata() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	assert_eq(str(map.get_meta("map_id", "")), "dungeons/fenmothers_hollow_f3")
	assert_eq(str(map.get_meta("dungeon_id", "")), "fenmothers_hollow")
	assert_eq(str(map.get_meta("floor_id", "")), "3")
	assert_eq(str(map.get_meta("location_name", "")), "Fenmother's Hollow - Sanctum")
	map.queue_free()


# --- Floor Maps: Tileset Reference ---


func test_f1_uses_placeholder_tileset() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	var tile_layer: TileMapLayer = map.get_node_or_null("TileMapLayer") as TileMapLayer
	assert_not_null(tile_layer, "should have TileMapLayer")
	assert_not_null(tile_layer.tile_set, "TileMapLayer should have tile_set")
	map.queue_free()


func test_f2_uses_placeholder_tileset() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	var tile_layer: TileMapLayer = map.get_node_or_null("TileMapLayer") as TileMapLayer
	assert_not_null(tile_layer, "should have TileMapLayer")
	assert_not_null(tile_layer.tile_set, "TileMapLayer should have tile_set")
	map.queue_free()


func test_f3_uses_placeholder_tileset() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	var tile_layer: TileMapLayer = map.get_node_or_null("TileMapLayer") as TileMapLayer
	assert_not_null(tile_layer, "should have TileMapLayer")
	assert_not_null(tile_layer.tile_set, "TileMapLayer should have tile_set")
	map.queue_free()


# --- Chests ---


func test_f1_chests() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	var chests: Array = _find_chests(map)
	assert_eq(chests.size(), 2, "F1 should have 2 chests")
	var ids: Array = []
	for c: Node in chests:
		ids.append(str(c.get_meta("item_id", "")))
	assert_true("marsh_cloak" in ids, "F1 should have marsh_cloak chest")
	assert_true("spirit_tonic" in ids, "F1 should have spirit_tonic chest")
	map.queue_free()


func test_f2_chests() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	var chests: Array = _find_chests(map)
	assert_eq(chests.size(), 3, "F2 should have 3 chests")
	var ids: Array = []
	for c: Node in chests:
		ids.append(str(c.get_meta("item_id", "")))
	assert_true("fenmothers_scale" in ids, "F2 should have fenmothers_scale chest")
	assert_true("spirit_bound_spear" in ids, "F2 should have spirit_bound_spear chest")
	assert_true("ancient_totem" in ids, "F2 should have ancient_totem chest")
	map.queue_free()


func test_f3_chest_with_required_flag() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	var chests: Array = _find_chests(map)
	assert_eq(chests.size(), 1, "F3 should have 1 chest")
	var chest: Node = chests[0]
	assert_eq(
		str(chest.get_meta("required_flag", "")),
		"fenmother_cleansed",
		"F3 chest should require fenmother_cleansed flag",
	)
	map.queue_free()


# --- Save Points ---


func test_f1_has_save_point() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	var saves: Array = _find_save_points(map)
	assert_gte(saves.size(), 1, "F1 should have at least one save point")
	map.queue_free()


func test_f2_has_save_point() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	var saves: Array = _find_save_points(map)
	assert_gte(saves.size(), 1, "F2 should have at least one save point")
	map.queue_free()


func test_f3_has_save_point() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	var saves: Array = _find_save_points(map)
	assert_gte(saves.size(), 1, "F3 should have at least one save point")
	map.queue_free()


# --- Boss Triggers ---


func test_f2_has_drowned_sentinel_boss() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	var boss: Node = map.get_node_or_null("Entities/DrownedSentinel")
	assert_not_null(boss, "F2 should have DrownedSentinel boss trigger")
	assert_eq(str(boss.get_meta("boss_id", "")), "drowned_sentinel")
	assert_eq(str(boss.get_meta("flag", "")), "drowned_sentinel_defeated")
	var eids: Variant = boss.get_meta("enemy_ids", [])
	assert_true(eids is Array, "enemy_ids should be an Array")
	assert_true("drowned_sentinel" in (eids as Array), "enemy_ids should contain drowned_sentinel")
	map.queue_free()


func test_f3_has_corrupted_fenmother_boss() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	var boss: Node = map.get_node_or_null("Entities/CorruptedFenmother")
	assert_not_null(boss, "F3 should have CorruptedFenmother boss trigger")
	assert_eq(str(boss.get_meta("boss_id", "")), "corrupted_fenmother")
	assert_eq(str(boss.get_meta("flag", "")), "fenmother_cleansed")
	var eids: Variant = boss.get_meta("enemy_ids", [])
	assert_true(eids is Array, "enemy_ids should be an Array")
	assert_true(
		"corrupted_fenmother" in (eids as Array),
		"enemy_ids should contain corrupted_fenmother",
	)
	map.queue_free()


# --- Transitions ---


func test_f1_transition_to_f2() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f1.tscn")
	var found: bool = _has_transition_to(map, "dungeons/fenmothers_hollow_f2")
	assert_true(found, "F1 should have a transition to F2")
	map.queue_free()


func test_f2_transition_to_f3_with_flag() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f2.tscn")
	var transitions: Node = map.get_node_or_null("Transitions")
	assert_not_null(transitions, "F2 should have Transitions node")
	var found_gated: bool = false
	if transitions != null:
		for child: Node in transitions.get_children():
			var target: String = str(child.get_meta("target_map", ""))
			var req: String = str(child.get_meta("required_flag", ""))
			if target == "dungeons/fenmothers_hollow_f3" and not req.is_empty():
				found_gated = true
	assert_true(found_gated, "F2 should have a flag-gated transition to F3")
	map.queue_free()


func test_f3_transition_to_overworld() -> void:
	var map: Node = _load_floor("res://scenes/maps/dungeons/fenmothers_hollow_f3.tscn")
	var found: bool = _has_transition_to(map, "overworld")
	assert_true(found, "F3 should have a transition to overworld")
	map.queue_free()


# --- Overworld Wiring ---


func test_overworld_has_fenmothers_hollow_transition() -> void:
	var overworld: Node = _load_floor("res://scenes/maps/overworld.tscn")
	var transition: Node = overworld.get_node_or_null("Transitions/FenmothersHollow")
	assert_not_null(transition, "overworld should have Transitions/FenmothersHollow")
	assert_eq(
		str(transition.get_meta("target_map", "")),
		"dungeons/fenmothers_hollow_f1",
		"FenmothersHollow should target fenmothers_hollow_f1",
	)
	overworld.queue_free()


func test_overworld_has_fenmothers_hollow_spawn() -> void:
	var overworld: Node = _load_floor("res://scenes/maps/overworld.tscn")
	var marker: Node = overworld.get_node_or_null("from_fenmothers_hollow")
	assert_not_null(marker, "overworld should have from_fenmothers_hollow marker")
	overworld.queue_free()


# --- Flag-Gated Transition Logic ---


func test_exploration_handles_required_flag() -> void:
	var text: String = _read_file("res://scripts/core/exploration.gd")
	assert_true(
		text.contains("required_flag"),
		"exploration.gd should check required_flag in transition handling",
	)


# --- Helpers ---


func _load_floor(path: String) -> Node:
	var scene: PackedScene = load(path)
	return scene.instantiate()


func _find_chests(map: Node) -> Array:
	var entities: Node = map.get_node_or_null("Entities")
	if entities == null:
		return []
	var result: Array = []
	for child: Node in entities.get_children():
		if child.has_meta("chest_id"):
			result.append(child)
	return result


func _find_save_points(map: Node) -> Array:
	var entities: Node = map.get_node_or_null("Entities")
	if entities == null:
		return []
	var result: Array = []
	for child: Node in entities.get_children():
		if child.has_meta("save_point_id"):
			result.append(child)
	return result


func _find_enemy(enemy_id: String, act: String) -> Dictionary:
	var enemies: Array = DataManager.load_enemies(act)
	for entry: Variant in enemies:
		if entry is Dictionary and (entry as Dictionary).get("id", "") == enemy_id:
			return entry as Dictionary
	return {}


func _has_transition_to(map: Node, target_map: String) -> bool:
	var transitions: Node = map.get_node_or_null("Transitions")
	if transitions == null:
		return false
	for child: Node in transitions.get_children():
		if str(child.get_meta("target_map", "")) == target_map:
			return true
	return false


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
