extends GutTest
## Tests for ZoneResolver: pure tile -> encounter zone lookup over the
## ordered rect table. Canon: geography.md § Region Boundaries /
## § Encounter Zones (Thornmere priority in overlap bands).

const ZR = preload("res://scripts/core/zone_resolver.gd")
const TestHelpers = preload("res://tests/test_helpers.gd")

const SIMPLE_MAP: Array = [
	{"zone_id": "thornmere_wilds", "rects": [[8, 28, 100, 62]]},
	{"zone_id": "valdris_highlands", "rects": [[10, 4, 85, 32]]},
]


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


func test_tile_inside_single_rect_resolves() -> void:
	var tile_map: Array = [{"zone_id": "aelhart_valley", "rects": [[24, 10, 36, 22]]}]
	assert_eq(ZR.resolve(Vector2i(30, 14), tile_map), "aelhart_valley")


func test_first_match_wins_in_overlap_band() -> void:
	# geography.md: Thornmere/Valdris overlap y28-32 -> Thornmere priority
	assert_eq(ZR.resolve(Vector2i(30, 30), SIMPLE_MAP), "thornmere_wilds")


func test_non_overlap_region_resolves_normally() -> void:
	assert_eq(ZR.resolve(Vector2i(30, 14), SIMPLE_MAP), "valdris_highlands")


func test_rect_bounds_are_inclusive() -> void:
	var tile_map: Array = [{"zone_id": "roads", "rects": [[31, 14, 46, 15]]}]
	assert_eq(ZR.resolve(Vector2i(31, 14), tile_map), "roads", "top-left corner inclusive")
	assert_eq(ZR.resolve(Vector2i(46, 15), tile_map), "roads", "bottom-right corner inclusive")
	assert_eq(ZR.resolve(Vector2i(47, 15), tile_map), "", "outside right edge excluded")


func test_unclassified_tile_returns_empty() -> void:
	assert_eq(ZR.resolve(Vector2i(0, 0), SIMPLE_MAP), "", "ocean/unmapped tile is unclassified")


func test_flag_gated_entry_skipped_when_flag_unset() -> void:
	var tile_map: Array = [
		{
			"zone_id": "pallor_wastes_approach",
			"flag": "act_iii_started",
			"rects": [[48, 48, 56, 56]]
		},
		{"zone_id": "thornmere_wilds", "rects": [[8, 28, 100, 62]]},
	]
	assert_eq(ZR.resolve(Vector2i(52, 52), tile_map), "thornmere_wilds")


func test_flag_gated_entry_applies_when_flag_set() -> void:
	EventFlags.set_flag("act_iii_started", true)
	var tile_map: Array = [
		{
			"zone_id": "pallor_wastes_approach",
			"flag": "act_iii_started",
			"rects": [[48, 48, 56, 56]]
		},
		{"zone_id": "thornmere_wilds", "rects": [[8, 28, 100, 62]]},
	]
	assert_eq(ZR.resolve(Vector2i(52, 52), tile_map), "pallor_wastes_approach")


func test_malformed_rect_is_skipped() -> void:
	var tile_map: Array = [
		{"zone_id": "broken", "rects": [[1, 2, 3]]},
		{"zone_id": "roads", "rects": [[0, 0, 10, 10]]},
	]
	assert_eq(ZR.resolve(Vector2i(2, 2), tile_map), "roads", "3-element rect must not match")


func test_real_overworld_zone_map_resolves_known_landmarks() -> void:
	var zone_map: Array = DataManager.load_zone_map("overworld")
	assert_false(zone_map.is_empty(), "overworld_zones.json should load")
	# Duskfen marsh outside the settlement 3x3 (geography.md: Duskfen 36,52)
	assert_eq(ZR.resolve(Vector2i(33, 49), zone_map), "duskfen_marshland")
	# Ashgrove sacred clearing (geography.md: Ashgrove 48,48 — encounter-free)
	assert_eq(ZR.resolve(Vector2i(48, 48), zone_map), "sacred_sites")
	# Valdris Crown approach tiles are urban (encounter-free)
	assert_eq(ZR.resolve(Vector2i(48, 18), zone_map), "urban")
	# Deep ocean is unclassified (impassable)
	assert_eq(ZR.resolve(Vector2i(2, 2), zone_map), "")


func test_real_zone_map_ids_all_exist_in_overworld_encounters() -> void:
	var zone_map: Array = DataManager.load_zone_map("overworld")
	var encounters: Dictionary = DataManager.load_encounters("overworld")
	var known_ids: Array[String] = []
	for zone: Variant in encounters.get("zones", []):
		if zone is Dictionary:
			known_ids.append((zone as Dictionary).get("zone_id", ""))
	for entry: Variant in zone_map:
		if entry is Dictionary:
			var zone_id: String = (entry as Dictionary).get("zone_id", "")
			assert_has(known_ids, zone_id, "zone map id %s needs an encounter entry" % zone_id)


func test_real_zone_map_activates_all_thirteen_authored_zones() -> void:
	# GAP-026 acceptance: every authored overworld zone is reachable
	var zone_map: Array = DataManager.load_zone_map("overworld")
	var mapped_ids: Dictionary = {}
	for entry: Variant in zone_map:
		if entry is Dictionary:
			mapped_ids[(entry as Dictionary).get("zone_id", "")] = true
	var encounters: Dictionary = DataManager.load_encounters("overworld")
	for zone: Variant in encounters.get("zones", []):
		if zone is Dictionary:
			var zone_id: String = (zone as Dictionary).get("zone_id", "")
			assert_true(mapped_ids.has(zone_id), "authored zone %s must be mapped" % zone_id)
