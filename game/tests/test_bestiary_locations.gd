extends GutTest
## Guards the bestiary Location(s) vocabulary (#288).
##
## docs/story/bestiary/README.md § Location Vocabulary admits exactly two
## forms — a dungeon floor reference, or an overworld encounter zone named
## verbatim — and requires each Location cell to mirror the enemy's
## `locations` array in game/data/enemies/<act>.json. Before #288 the Act I
## column also carried five invented names ("Valdris Forest", "Valdris
## Plains", "Valdris Road", "Forest Edge", "Duskfen Road") that resolved to
## nothing: no zone, no region, no other file in the repo. Habitat arguments
## built on them could not be checked by anyone.
##
## These tests enforce the overworld half of the rule, which is the half that
## has shippable data behind it. Two deliberate limits:
##
## 1. Dungeon-floor entries are not checked. The enemy files spell them
##    `ember_vein_f1` while the encounter files key them `dungeon_id` +
##    `floor_id` ("1-2"), and no mapping between the two is canon yet.
## 2. Zone coverage is asserted for act_i.json only, which is the file #288
##    names and the one reconciled here. The Act II / Interlude / Act III
##    tables have 22 zone appearances their `locations` arrays do not list —
##    the same defect, an unreconciled follow-up, and not something this test
##    should red-flag before someone fixes it. The retired-name check below
##    does span every act, because those five names must never come back
##    anywhere.

## Names retired by #288. None may reappear in any enemy file's `locations`.
const RETIRED_LOCATION_IDS: Array[String] = [
	"valdris_forest",
	"valdris_plains",
	"valdris_road",
	"forest_edge",
	"duskfen_road",
]

## Enemy stat tables to scan. StoryAct.get_enemy_act() names these files.
const ENEMY_ACTS: Array[String] = ["act_i", "act_ii", "interlude", "act_iii"]


func before_each() -> void:
	DataManager.clear_cache()


## zone_id -> the set of enemy ids that zone can roll, from overworld.json.
func _overworld_zone_rosters() -> Dictionary:
	var encounters: Dictionary = DataManager.load_encounters("overworld")
	var zones: Array = encounters.get("zones", [])
	if zones.is_empty():
		fail_test("game/data/encounters/overworld.json has no zones")
		return {}
	var rosters: Dictionary = {}
	for zone: Variant in zones:
		var zone_dict: Dictionary = zone as Dictionary
		var members: Dictionary = {}
		for group: Variant in zone_dict.get("groups", []):
			for enemy_id: Variant in (group as Dictionary).get("enemies", []):
				members[String(enemy_id)] = true
		rosters[String(zone_dict.get("zone_id", ""))] = members
	return rosters


## enemy_id -> its `locations` Array, for act_i.json alone.
func _act_i_locations() -> Dictionary:
	var enemies: Array = DataManager.load_enemies("act_i")
	if enemies.is_empty():
		fail_test("game/data/enemies/act_i.json loaded no enemies")
		return {}
	var index: Dictionary = {}
	for enemy: Variant in enemies:
		var enemy_dict: Dictionary = enemy as Dictionary
		index[String(enemy_dict.get("id", ""))] = enemy_dict.get("locations", [])
	return index


## enemy_id -> its `locations` Array, across every act stat table.
func _enemy_locations() -> Dictionary:
	var index: Dictionary = {}
	for act: String in ENEMY_ACTS:
		var enemies: Array = DataManager.load_enemies(act)
		if enemies.is_empty():
			fail_test("game/data/enemies/%s.json loaded no enemies" % act)
			return {}
		for enemy: Variant in enemies:
			var enemy_dict: Dictionary = enemy as Dictionary
			index[String(enemy_dict.get("id", ""))] = enemy_dict.get("locations", [])
	return index


func test_every_overworld_zone_is_listed_by_the_act_i_enemies_it_rolls() -> void:
	var rosters: Dictionary = _overworld_zone_rosters()
	var locations: Dictionary = _act_i_locations()
	if rosters.is_empty() or locations.is_empty():
		return  # the helpers already failed the test
	var checked: int = 0
	for zone_id: String in rosters:
		for enemy_id: String in rosters[zone_id] as Dictionary:
			if not locations.has(enemy_id):
				continue  # a later act's enemy — out of scope, see the header
			checked += 1
			assert_true(
				zone_id in (locations[enemy_id] as Array),
				(
					"%s rolls in %s but does not list it (bestiary README § Location Vocabulary)"
					% [enemy_id, zone_id]
				)
			)
	assert_gt(checked, 10, "too few Act I zone/enemy pairs found — the scan did not run")


func test_retired_location_names_appear_nowhere() -> void:
	var locations: Dictionary = _enemy_locations()
	if locations.is_empty():
		return  # the helper already failed the test
	var total_entries: int = 0
	for enemy_id: String in locations:
		total_entries += (locations[enemy_id] as Array).size()
	assert_gt(total_entries, 100, "too few locations entries scanned to trust this check")
	for enemy_id: String in locations:
		for retired: String in RETIRED_LOCATION_IDS:
			assert_false(
				retired in (locations[enemy_id] as Array),
				(
					'%s lists the retired name "%s"; use the zone id instead (#288)'
					% [enemy_id, retired]
				)
			)
