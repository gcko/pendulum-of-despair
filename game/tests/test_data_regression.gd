extends GutTest
## Regression tests for data/doc issues fixed in PR #146 follow-up.
##
## Covers:
## 1. hi_potion must have available_act:2 in ALL shops that carry it
## 2. New items (ley_lantern, pallor_antidote, warp_walker_boots,
##    gravity_shard, composite_shortbow) exist in their data files
## 3. No camelCase keys remain in save-system.md pseudo-schema


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


# ── hi_potion available_act regression ──────────────────────────────────


func test_hi_potion_available_act_is_2_in_all_shops() -> void:
	var shop_files: Array[String] = [
		"roothollow_herbalist",
		"aelhart_general",
		"valdris_crown_general",
		"bellhaven_general",
		"corrund_general",
		"ashmark_general",
		"caldera_company_store",
		"ironmark_quartermaster",
		"thornmere_provisioner",
	]
	for shop_name: String in shop_files:
		var shop: Dictionary = DataManager.load_shop(shop_name)
		if shop.is_empty():
			continue
		var inventory: Array = shop.get("shop", {}).get("inventory", [])
		for entry: Variant in inventory:
			var d: Dictionary = entry as Dictionary
			if d.get("item_id", "") == "hi_potion":
				assert_eq(
					int(d.get("available_act", -1)),
					2,
					"hi_potion available_act should be 2 in %s" % shop_name,
				)


# ── New item existence checks ───────────────────────────────────────────


func test_ley_lantern_exists_in_consumables() -> void:
	var data: Variant = DataManager.load_json("res://data/items/consumables.json")
	assert_true(data is Dictionary, "consumables.json should be a dict")
	var items: Array = (data as Dictionary).get("items", [])
	var ids: Array[String] = []
	for item: Variant in items:
		ids.append((item as Dictionary).get("id", ""))
	assert_true(ids.has("ley_lantern"), "ley_lantern should exist in consumables.json")


func test_pallor_antidote_exists_in_consumables() -> void:
	var data: Variant = DataManager.load_json("res://data/items/consumables.json")
	assert_true(data is Dictionary, "consumables.json should be a dict")
	var items: Array = (data as Dictionary).get("items", [])
	var ids: Array[String] = []
	for item: Variant in items:
		ids.append((item as Dictionary).get("id", ""))
	assert_true(ids.has("pallor_antidote"), "pallor_antidote should exist in consumables.json")


func test_pallor_antidote_cures_despair() -> void:
	var data: Variant = DataManager.load_json("res://data/items/consumables.json")
	var items: Array = (data as Dictionary).get("items", [])
	for item: Variant in items:
		var d: Dictionary = item as Dictionary
		if d.get("id", "") == "pallor_antidote":
			var cures: Array = d.get("cures", [])
			assert_true(
				cures.has("despair"),
				"pallor_antidote should cure despair",
			)
			return
	fail_test("pallor_antidote not found in consumables.json")


func test_warp_walker_boots_exists_in_accessories() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/accessories.json")
	assert_true(data is Dictionary, "accessories.json should be a dict")
	var items: Array = (data as Dictionary).get("accessories", [])
	var ids: Array[String] = []
	for item: Variant in items:
		ids.append((item as Dictionary).get("id", ""))
	assert_true(
		ids.has("warp_walker_boots"),
		"warp_walker_boots should exist in accessories.json",
	)


func test_warp_walker_boots_has_spd_20() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/accessories.json")
	var items: Array = (data as Dictionary).get("accessories", [])
	for item: Variant in items:
		var d: Dictionary = item as Dictionary
		if d.get("id", "") == "warp_walker_boots":
			var stats: Dictionary = d.get("bonus_stats", {})
			assert_eq(
				int(stats.get("spd", 0)),
				20,
				"warp_walker_boots should have +20 SPD",
			)
			return
	fail_test("warp_walker_boots not found in accessories.json")


func test_gravity_shard_exists_in_accessories() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/accessories.json")
	assert_true(data is Dictionary, "accessories.json should be a dict")
	var items: Array = (data as Dictionary).get("accessories", [])
	var ids: Array[String] = []
	for item: Variant in items:
		ids.append((item as Dictionary).get("id", ""))
	assert_true(
		ids.has("gravity_shard"),
		"gravity_shard should exist in accessories.json",
	)


func test_gravity_shard_has_12_all_stats() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/accessories.json")
	var items: Array = (data as Dictionary).get("accessories", [])
	for item: Variant in items:
		var d: Dictionary = item as Dictionary
		if d.get("id", "") == "gravity_shard":
			var stats: Dictionary = d.get("bonus_stats", {})
			for stat: String in ["atk", "def", "mag", "mdef", "spd", "lck"]:
				assert_eq(
					int(stats.get(stat, 0)),
					12,
					"gravity_shard should have +12 %s" % stat,
				)
			return
	fail_test("gravity_shard not found in accessories.json")


func test_composite_shortbow_exists_in_weapons() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/weapons.json")
	assert_true(data is Dictionary, "weapons.json should be a dict")
	var items: Array = (data as Dictionary).get("weapons", [])
	var ids: Array[String] = []
	for item: Variant in items:
		ids.append((item as Dictionary).get("id", ""))
	assert_true(
		ids.has("composite_shortbow"),
		"composite_shortbow should exist in weapons.json",
	)


func test_composite_shortbow_stats() -> void:
	var data: Variant = DataManager.load_json("res://data/equipment/weapons.json")
	var items: Array = (data as Dictionary).get("weapons", [])
	for item: Variant in items:
		var d: Dictionary = item as Dictionary
		if d.get("id", "") == "composite_shortbow":
			assert_eq(int(d.get("atk", 0)), 12, "composite_shortbow ATK should be 12")
			var stats: Dictionary = d.get("bonus_stats", {})
			assert_eq(int(stats.get("spd", 0)), 3, "composite_shortbow SPD bonus should be 3")
			assert_eq(int(d.get("buy_price", 0)), 450, "composite_shortbow buy_price should be 450")
			assert_eq(
				int(d.get("sell_price", 0)), 225, "composite_shortbow sell_price should be 225"
			)
			return
	fail_test("composite_shortbow not found in weapons.json")


# ── save-system.md camelCase regression ─────────────────────────────────


func test_no_camelcase_keys_in_save_system_md() -> void:
	var path: String = "res://../../docs/story/save-system.md"
	# Use absolute project path since res:// may not reach docs/
	var abs_path: String = ProjectSettings.globalize_path("res://").path_join(
		"../../docs/story/save-system.md"
	)
	if not FileAccess.file_exists(abs_path):
		# Fallback: try relative from project root
		abs_path = "res://../docs/story/save-system.md"
	if not FileAccess.file_exists(abs_path):
		pending("save-system.md not accessible from Godot project path")
		return

	var file: FileAccess = FileAccess.open(abs_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()

	# These specific camelCase keys were the bugs we fixed
	var banned_keys: Array[String] = [
		"leyCrystals",
		"arcaniteCharges",
		"deviceLoadout",
		"discoveredSynergies",
		"unlockedRecipes",
		"itemId",
		"savedAt",
		"slotType",
		"playTime",
		"currentLocation",
	]
	for key: String in banned_keys:
		assert_false(
			content.contains(key),
			"save-system.md should not contain camelCase key: %s" % key,
		)
