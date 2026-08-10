extends GutTest
## Integration tests for the overworld — scene existence, encounter data,
## transition wiring, round-trip validation, and exploration.gd defaults.

## bestiary/act-i.md "Overworld Act I" — the forest members of the roster.
const THORNMERE_ROSTER: Array[String] = [
	"wayward_wolf",
	"wild_boar",
	"forest_sprite",
	"thornback_beetle",
]

## Location-confined to Fenmother's Hollow F1–F3; must not roam the Wilds.
const FENMOTHER_CONFINED: Array[String] = ["marsh_serpent", "drowned_bones"]


func before_each() -> void:
	DataManager.clear_cache()


func test_overworld_scene_exists() -> void:
	assert_true(FileAccess.file_exists("res://scenes/maps/overworld.tscn"))


func test_overworld_encounter_data_exists() -> void:
	var data: Dictionary = DataManager.load_encounters("overworld")
	assert_false(data.is_empty(), "Overworld encounter data should exist")


func test_highland_zone_has_groups() -> void:
	var data: Dictionary = DataManager.load_encounters("overworld")
	var zones: Array = data.get("zones", data.get("floors", []))
	var found: bool = false
	for entry: Variant in zones:
		if entry is Dictionary and (entry as Dictionary).get("zone_id", "") == "valdris_highlands":
			found = true
			var groups: Array = (entry as Dictionary).get("groups", [])
			assert_gt(groups.size(), 0, "Highland zone should have encounter groups")
			break
	assert_true(found, "Should find valdris_highlands zone entry")


func test_overworld_has_valdris_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("towns/valdris_lower_ward"))


func test_overworld_has_ember_vein_transition() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("dungeons/ember_vein_f1"))


func test_overworld_spawn_markers_exist() -> void:
	var text: String = _read_file("res://scenes/maps/overworld.tscn")
	assert_true(text.contains("from_valdris"))
	assert_true(text.contains("from_ember_vein"))


func test_valdris_south_gate_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(text.contains('target_map = "overworld"'))
	assert_false(text.contains('target_map = "test_room"'))


func test_ember_vein_exit_targets_overworld() -> void:
	var text: String = _read_file("res://scenes/maps/dungeons/ember_vein_f1.tscn")
	assert_true(text.contains('target_map = "overworld"'))


func test_overworld_to_valdris_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var vl: String = _read_file("res://scenes/maps/towns/valdris_lower_ward.tscn")
	assert_true(ow.contains("towns/valdris_lower_ward"))
	assert_true(vl.contains('"overworld"'))
	assert_true(ow.contains("from_valdris"))
	assert_true(vl.contains("from_overworld"))


func test_overworld_to_ember_vein_round_trip() -> void:
	var ow: String = _read_file("res://scenes/maps/overworld.tscn")
	var ev: String = _read_file("res://scenes/maps/dungeons/ember_vein_f1.tscn")
	assert_true(ow.contains("dungeons/ember_vein_f1"))
	assert_true(ev.contains('"overworld"'))
	assert_true(ow.contains("from_ember_vein"))
	assert_true(ev.contains("from_overworld"))


func test_exploration_defaults_to_overworld() -> void:
	var text: String = _read_file("res://scripts/core/exploration.gd")
	assert_false(text.contains('load_map("test_room")'))
	assert_true(text.contains('load_map("overworld")'))


# ── Overworld roster integrity (issue #270) ─────────────────────────


func test_every_overworld_group_enemy_id_resolves() -> void:
	# Every id an overworld zone group can roll must exist in an enemy
	# table, or build_random_encounter drops a phantom into the battle.
	var index: Dictionary = _build_enemy_index()
	assert_gt(index.size(), 0, "enemy index should not be empty")
	var checked: int = 0
	var unknown: Array[String] = []
	for zone: Dictionary in _all_zones():
		for group: Variant in zone.get("groups", []):
			if not group is Dictionary:
				continue
			for enemy_id: Variant in (group as Dictionary).get("enemies", []):
				checked += 1
				if not index.has(enemy_id):
					unknown.append("%s -> %s" % [zone.get("zone_id", "?"), str(enemy_id)])
	assert_gt(checked, 0, "should have checked at least one group enemy id")
	assert_eq(unknown.size(), 0, "unknown overworld enemy ids: %s" % str(unknown))


func test_thornmere_wilds_draws_only_documented_overworld_roster() -> void:
	var zone: Dictionary = _find_zone("thornmere_wilds")
	assert_false(zone.is_empty(), "thornmere_wilds zone should exist")
	var used: Dictionary = _zone_enemy_ids(zone)
	for enemy_id: String in used:
		assert_has(
			THORNMERE_ROSTER,
			enemy_id,
			"thornmere_wilds may only use the Overworld Act I forest roster",
		)
	for enemy_id: String in THORNMERE_ROSTER:
		assert_true(used.has(enemy_id), "roster member %s should appear in the Wilds" % enemy_id)


func test_thornmere_wilds_excludes_dungeon_confined_enemies() -> void:
	# Regression for #270: marsh creatures must not roam a dense forest.
	var used: Dictionary = _zone_enemy_ids(_find_zone("thornmere_wilds"))
	for enemy_id: String in FENMOTHER_CONFINED:
		assert_false(used.has(enemy_id), "%s is confined to Fenmother's Hollow" % enemy_id)


func test_thornmere_wilds_encounter_math_unchanged() -> void:
	# #270 changes WHICH enemies appear, never the encounter math.
	var zone: Dictionary = _find_zone("thornmere_wilds")
	assert_eq(zone.get("terrain_type", ""), "low_visibility", "terrain unchanged")
	assert_eq(zone.get("act", ""), "act_i", "act unchanged")
	assert_eq(int(zone.get("danger_tier", 0)), 2, "danger tier unchanged")
	assert_eq(int(zone.get("danger_increment", 0)), 148, "danger increment unchanged")
	var rates: Dictionary = zone.get("formation_rates", {})
	assert_almost_eq(float(rates.get("normal", 0.0)), 68.75, 0.01, "normal rate unchanged")
	assert_almost_eq(float(rates.get("back_attack", 0.0)), 18.75, 0.01, "back attack unchanged")
	assert_almost_eq(float(rates.get("preemptive", 0.0)), 12.5, 0.01, "preemptive unchanged")
	var groups: Array = zone.get("groups", [])
	assert_eq(groups.size(), 4, "four groups")
	var expected_weights: Array[float] = [31.25, 31.25, 31.25, 6.25]
	for i: int in range(groups.size()):
		var group: Dictionary = groups[i]
		assert_eq(int(group.get("format", 0)), i + 1, "format numbering is 1..4 in order")
		assert_almost_eq(
			float(group.get("weight", 0.0)), expected_weights[i], 0.01, "weight %d preserved" % i
		)
		var size: int = (group.get("enemies", []) as Array).size()
		assert_gte(size, 2, "group %d has at least 2 enemies" % i)
		assert_lte(size, 4, "group %d fits the 4-slot enemy formation" % i)


func test_thornmere_wilds_stays_a_tier_two_step_up() -> void:
	# The Wilds are the first zone after the Ironmouth opening: harder
	# than tier-1 Aelhart Valley, still beatable by a low-level party.
	var index: Dictionary = _build_enemy_index()
	var thornmere: float = _expected_group_hp(_find_zone("thornmere_wilds"), index)
	var valley: float = _expected_group_hp(_find_zone("aelhart_valley"), index)
	assert_gt(valley, 0.0, "tier-1 baseline should be computable")
	assert_gt(thornmere, valley * 2.0, "tier 2 must be a clear step up from tier 1")
	assert_lt(thornmere, valley * 3.5, "tier 2 must not spike into a wall")
	# Comparable to the pre-#270 marsh roster (expected group HP ~360).
	assert_gte(thornmere, 280.0, "zone must not become a pushover")
	assert_lte(thornmere, 420.0, "zone must stay in its old difficulty band")
	var levels: Array[int] = _zone_level_band(_find_zone("thornmere_wilds"), index)
	assert_gte(levels[0], 3, "no trivial filler below the Overworld Act I floor")
	assert_lte(levels[1], 6, "roster caps at Wayward Wolf (Lv 6)")
	var valley_levels: Array[int] = _zone_level_band(_find_zone("aelhart_valley"), index)
	assert_gt(levels[1], valley_levels[1], "Wilds top out above the Valley")


## Build enemy_id -> enemy Dictionary across every act enemy table.
func _build_enemy_index() -> Dictionary:
	var index: Dictionary = {}
	var dir: DirAccess = DirAccess.open("res://data/enemies/")
	if dir == null:
		return index
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.ends_with(".json"):
			for enemy: Variant in DataManager.load_enemies(entry.get_basename()):
				if enemy is Dictionary and (enemy as Dictionary).has("id"):
					index[(enemy as Dictionary)["id"]] = enemy
		entry = dir.get_next()
	dir.list_dir_end()
	return index


func _all_zones() -> Array[Dictionary]:
	var zones: Array[Dictionary] = []
	for entry: Variant in DataManager.load_encounters("overworld").get("zones", []):
		if entry is Dictionary:
			zones.append(entry as Dictionary)
	return zones


func _find_zone(zone_id: String) -> Dictionary:
	for zone: Dictionary in _all_zones():
		if zone.get("zone_id", "") == zone_id:
			return zone
	return {}


## Set of distinct enemy ids a zone can roll, as a Dictionary used as a set.
func _zone_enemy_ids(zone: Dictionary) -> Dictionary:
	var ids: Dictionary = {}
	for group: Variant in zone.get("groups", []):
		if not group is Dictionary:
			continue
		for enemy_id: Variant in (group as Dictionary).get("enemies", []):
			ids[str(enemy_id)] = true
	return ids


## Weight-averaged total HP of a zone's encounter groups.
func _expected_group_hp(zone: Dictionary, index: Dictionary) -> float:
	var total: float = 0.0
	for group: Variant in zone.get("groups", []):
		if not group is Dictionary:
			continue
		var group_hp: int = 0
		for enemy_id: Variant in (group as Dictionary).get("enemies", []):
			var enemy: Dictionary = index.get(enemy_id, {})
			group_hp += int(enemy.get("hp", 0))
		total += float(group_hp) * float((group as Dictionary).get("weight", 0.0)) / 100.0
	return total


## [min_level, max_level] across every enemy a zone can roll.
func _zone_level_band(zone: Dictionary, index: Dictionary) -> Array[int]:
	var lowest: int = 9999
	var highest: int = 0
	for enemy_id: String in _zone_enemy_ids(zone):
		var enemy: Dictionary = index.get(enemy_id, {})
		var level: int = int(enemy.get("level", 0))
		lowest = mini(lowest, level)
		highest = maxi(highest, level)
	return [lowest, highest]


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
