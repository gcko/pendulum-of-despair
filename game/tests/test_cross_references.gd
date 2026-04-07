extends GutTest
## Cross-reference integrity tests.
##
## Validates that all inter-file references resolve: NPC dialogue,
## shop inventories, chest items, map transitions, and character data.
## Catches broken linkages at build time before they become runtime
## errors.

const MAPS_DIR: String = "res://scenes/maps/"
const PARTY_IDS: Array[String] = ["edren", "cael", "lira", "sable", "torren", "maren"]


func before_each() -> void:
	DataManager.clear_cache()


# ── Helpers ──────────────────────────────────────────────────────────


## Recursively collect all .tscn file paths under a directory.
static func _collect_tscn_files(dir_path: String) -> Array[String]:
	var results: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return results
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and entry != "." and entry != "..":
			results.append_array(_collect_tscn_files(dir_path.path_join(entry)))
		elif entry.ends_with(".tscn"):
			results.append(dir_path.path_join(entry))
		entry = dir.get_next()
	dir.list_dir_end()
	return results


## Read a .tscn file as text lines.
static func _read_tscn_lines(path: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return PackedStringArray()
	var text: String = file.get_as_text()
	file.close()
	return text.split("\n")


## Extract metadata values matching a key from .tscn text lines.
## Returns an array of values (strings without surrounding quotes).
static func _extract_metadata(lines: PackedStringArray, key: String) -> Array[String]:
	var values: Array[String] = []
	var prefix: String = 'metadata/%s = "' % key
	for line: String in lines:
		var trimmed: String = line.strip_edges()
		if trimmed.begins_with(prefix) and trimmed.ends_with('"'):
			var val: String = trimmed.substr(
				prefix.length(), trimmed.length() - prefix.length() - 1
			)
			values.append(val)
	return values


## Build a set of all known item/equipment IDs from data files.
static func _build_item_id_set() -> Dictionary:
	var ids: Dictionary = {}
	var item_files: Array[String] = ["consumables", "materials", "key_items"]
	for fname: String in item_files:
		var path: String = "res://data/items/%s.json" % fname
		if not FileAccess.file_exists(path):
			continue
		var data: Variant = _parse_json_file(path)
		if data is Dictionary and data.has("items"):
			for item: Variant in data["items"]:
				if item is Dictionary and item.has("id"):
					ids[item["id"]] = true
	var equip_map: Dictionary = {
		"weapons": "weapons", "armor": "armor", "accessories": "accessories"
	}
	for fname: String in equip_map:
		var path: String = "res://data/equipment/%s.json" % fname
		if not FileAccess.file_exists(path):
			continue
		var data: Variant = _parse_json_file(path)
		if data is Dictionary and data.has(equip_map[fname]):
			for entry: Variant in data[equip_map[fname]]:
				if entry is Dictionary and entry.has("id"):
					ids[entry["id"]] = true
	return ids


## Minimal JSON parser (avoids DataManager._fatal on missing files).
static func _parse_json_file(path: String) -> Variant:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return null
	return json.data


# ── 1. NPC dialogue files ───────────────────────────────────────────


func test_all_npc_dialogue_files_exist() -> void:
	var scene_files: Array[String] = _collect_tscn_files(MAPS_DIR)
	var checked: int = 0
	for scene_path: String in scene_files:
		var lines: PackedStringArray = _read_tscn_lines(scene_path)
		for npc_id: String in _extract_metadata(lines, "npc_id"):
			var dialogue_path: String = "res://data/dialogue/npc_%s.json" % npc_id
			assert_true(
				FileAccess.file_exists(dialogue_path),
				"Dialogue file missing for npc_id '%s' in %s" % [npc_id, scene_path]
			)
			checked += 1
	assert_gt(checked, 0, "Should have checked at least one NPC dialogue reference")


# ── 2. Shop JSON files ──────────────────────────────────────────────


func test_all_shop_files_exist() -> void:
	var scene_files: Array[String] = _collect_tscn_files(MAPS_DIR)
	var checked: int = 0
	for scene_path: String in scene_files:
		var lines: PackedStringArray = _read_tscn_lines(scene_path)
		for shop_id: String in _extract_metadata(lines, "shop_id"):
			var shop_path: String = "res://data/shops/%s.json" % shop_id
			assert_true(
				FileAccess.file_exists(shop_path),
				"Shop file missing for shop_id '%s' in %s" % [shop_id, scene_path]
			)
			checked += 1
	assert_gt(checked, 0, "Should have checked at least one shop reference")


# ── 3. Shop inventory item IDs ──────────────────────────────────────


func test_all_shop_inventory_items_exist_in_data() -> void:
	var item_ids: Dictionary = _build_item_id_set()
	assert_gt(item_ids.size(), 0, "Item ID set should not be empty")

	var shop_dir: String = "res://data/shops/"
	var dir: DirAccess = DirAccess.open(shop_dir)
	assert_not_null(dir, "Shops directory should be readable")
	var checked: int = 0

	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.ends_with(".json"):
			var data: Variant = _parse_json_file(shop_dir.path_join(entry))
			if data is Dictionary and data.has("shop"):
				var shop: Variant = data["shop"]
				if shop is Dictionary and shop.has("inventory"):
					for slot: Variant in shop["inventory"]:
						if slot is Dictionary and slot.has("item_id"):
							var sid: String = slot["item_id"]
							assert_true(
								item_ids.has(sid),
								"Shop '%s' references unknown item_id '%s'" % [entry, sid]
							)
							checked += 1
		entry = dir.get_next()
	dir.list_dir_end()
	assert_gt(checked, 0, "Should have checked at least one shop inventory item")


# ── 4. Transition targets ───────────────────────────────────────────


func test_all_transition_target_maps_exist() -> void:
	var scene_files: Array[String] = _collect_tscn_files(MAPS_DIR)
	var checked: int = 0
	for scene_path: String in scene_files:
		var lines: PackedStringArray = _read_tscn_lines(scene_path)
		for target_map: String in _extract_metadata(lines, "target_map"):
			var target_path: String = "res://scenes/maps/%s.tscn" % target_map
			assert_true(
				FileAccess.file_exists(target_path),
				"Target map missing: '%s' referenced in %s" % [target_map, scene_path]
			)
			checked += 1
	assert_gt(checked, 0, "Should have checked at least one transition target")


func test_all_transition_spawn_points_exist() -> void:
	var scene_files: Array[String] = _collect_tscn_files(MAPS_DIR)
	var checked: int = 0
	for scene_path: String in scene_files:
		var lines: PackedStringArray = _read_tscn_lines(scene_path)
		var target_maps: Array[String] = _extract_metadata(lines, "target_map")
		var target_spawns: Array[String] = _extract_metadata(lines, "target_spawn")
		for i: int in range(mini(target_maps.size(), target_spawns.size())):
			var target_path: String = "res://scenes/maps/%s.tscn" % target_maps[i]
			if not FileAccess.file_exists(target_path):
				continue  # Covered by target_maps test
			var target_lines: PackedStringArray = _read_tscn_lines(target_path)
			var spawn_name: String = target_spawns[i]
			var found: bool = _scene_has_node_named(target_lines, spawn_name)
			assert_true(
				found,
				(
					"Spawn '%s' not found in '%s' (referenced by %s)"
					% [spawn_name, target_path, scene_path]
				)
			)
			checked += 1
	assert_gt(checked, 0, "Should have checked at least one spawn point")


## Check if a .tscn file (as text lines) declares a node with the given name.
static func _scene_has_node_named(lines: PackedStringArray, node_name: String) -> bool:
	var pattern: String = 'name="%s"' % node_name
	for line: String in lines:
		if line.strip_edges().begins_with("[node") and pattern in line:
			return true
	return false


# ── 5. Character JSON files ─────────────────────────────────────────


func test_all_character_files_exist() -> void:
	for char_id: String in PARTY_IDS:
		var path: String = "res://data/characters/%s.json" % char_id
		assert_true(FileAccess.file_exists(path), "Character file missing: %s" % path)


# ── 6. Chest item IDs ───────────────────────────────────────────────


func test_all_chest_item_ids_exist_in_data() -> void:
	var item_ids: Dictionary = _build_item_id_set()
	var scene_files: Array[String] = _collect_tscn_files(MAPS_DIR)
	var checked: int = 0
	for scene_path: String in scene_files:
		var lines: PackedStringArray = _read_tscn_lines(scene_path)
		for item_id: String in _extract_metadata(lines, "item_id"):
			assert_true(
				item_ids.has(item_id),
				"Chest item_id '%s' not found in item/equipment data (%s)" % [item_id, scene_path]
			)
			checked += 1
	assert_gt(checked, 0, "Should have checked at least one chest item reference")


# ── 7. DataManager graceful degradation ─────────────────────────────


func test_load_shop_returns_empty_for_nonexistent() -> void:
	var result: Dictionary = DataManager.load_shop("nonexistent_shop_999")
	assert_eq(result, {}, "load_shop should return empty dict for missing shop")


func test_load_encounters_returns_empty_for_nonexistent() -> void:
	var result: Dictionary = DataManager.load_encounters("nonexistent_dungeon_999")
	assert_eq(result, {}, "load_encounters should return empty dict for missing dungeon")


func test_load_dialogue_returns_empty_for_nonexistent() -> void:
	var result: Dictionary = DataManager.load_dialogue("nonexistent_dialogue_999")
	assert_eq(result, {}, "load_dialogue should return empty dict for missing dialogue")


func test_load_items_returns_empty_for_nonexistent() -> void:
	var result: Array = DataManager.load_items("nonexistent_category_999")
	assert_eq(result, [], "load_items should return empty array for missing category")


func test_load_equipment_returns_empty_for_nonexistent() -> void:
	var result: Array = DataManager.load_equipment("nonexistent_type_999")
	assert_eq(result, [], "load_equipment should return empty array for missing type")


func test_load_enemies_returns_empty_for_nonexistent() -> void:
	var result: Array = DataManager.load_enemies("nonexistent_act_999")
	assert_eq(result, [], "load_enemies should return empty array for missing act")


func test_load_spells_returns_empty_for_nonexistent() -> void:
	var result: Array = DataManager.load_spells("nonexistent_tradition_999")
	assert_eq(result, [], "load_spells should return empty array for missing tradition")


func test_load_character_returns_empty_for_nonexistent() -> void:
	var result: Dictionary = DataManager.load_character("nonexistent_char_999")
	assert_eq(result, {}, "load_character should return empty dict for missing character")


func test_load_crafting_returns_empty_for_nonexistent() -> void:
	var result: Variant = DataManager.load_crafting("nonexistent_type_999")
	assert_eq(result, {}, "load_crafting should return empty dict for missing type")


# ── 8. Spell learned_by character IDs ───────────────────────────────


func test_all_spell_learned_by_characters_exist() -> void:
	var valid: Array[String] = ["edren", "cael", "maren", "lira", "torren", "sable"]
	var bad: Array[String] = []
	for tradition: String in ["ley_line", "forgewright", "spirit", "streetwise", "void"]:
		var spells: Array = DataManager.load_spells(tradition)
		for spell: Variant in spells:
			if not spell is Dictionary:
				continue
			var s: Dictionary = spell as Dictionary
			for entry: Variant in s.get("learned_by", []):
				if not entry is Dictionary:
					continue
				var cid: String = (entry as Dictionary).get("character", "")
				if cid != "" and cid not in valid:
					bad.append("%s: unknown '%s'" % [s.get("id", "?"), cid])
	assert_eq(bad.size(), 0, "All spell characters valid: %s" % str(bad))
