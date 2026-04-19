extends GutTest
## Tests for the split Valdris Crown shop data.
##
## Verifies the weaponsmith, armorsmith, and jeweler shops load correctly,
## have the right items, and that old armorer is gone.


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


# ── Weaponsmith ──────────────────────────────────────────────────────────


func test_weaponsmith_loads_with_correct_shop_id() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	assert_false(shop.is_empty(), "weaponsmith shop should load")
	var data: Dictionary = shop.get("shop", {})
	assert_eq(data.get("shop_id", ""), "valdris_crown_weaponsmith", "shop_id should match")


func test_weaponsmith_town_and_markup() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	var data: Dictionary = shop.get("shop", {})
	assert_eq(data.get("town", ""), "valdris_crown", "town should be valdris_crown")
	assert_eq(data.get("markup", 0.0), 1.0, "markup should be 1.0")


func test_weaponsmith_has_only_weapon_items() -> void:
	var expected_items: Array[String] = [
		"valdris_blade",
		"knights_edge",
		"ley_wand",
		"stiletto",
		"iron_mallet",
		"iron_lance",
		"commanders_blade",
		"glyph_staff",
		"pickpockets_blade",
		"pipe_hammer",
	]
	var shop: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	var item_ids: Array[String] = []
	for entry: Variant in inventory:
		item_ids.append((entry as Dictionary).get("item_id", ""))
	assert_eq(item_ids.size(), expected_items.size(), "weaponsmith should have exactly 10 items")
	for expected: String in expected_items:
		assert_true(item_ids.has(expected), "weaponsmith should have item: %s" % expected)


func test_weaponsmith_items_exist_in_weapons_json() -> void:
	var weapons_data: Variant = DataManager.load_json("res://data/equipment/weapons.json")
	assert_true(weapons_data is Dictionary, "weapons.json should be a dict")
	var weapons_list: Array = (weapons_data as Dictionary).get("weapons", [])
	var weapon_ids: Array[String] = []
	for w: Variant in weapons_list:
		weapon_ids.append((w as Dictionary).get("id", ""))

	var shop: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	for entry: Variant in inventory:
		var item_id: String = (entry as Dictionary).get("item_id", "")
		assert_true(
			weapon_ids.has(item_id), "weaponsmith item '%s' should exist in weapons.json" % item_id
		)


func test_weaponsmith_no_duplicate_items() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_weaponsmith")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	var seen: Array[String] = []
	for entry: Variant in inventory:
		var item_id: String = (entry as Dictionary).get("item_id", "")
		assert_false(seen.has(item_id), "duplicate item_id in weaponsmith: %s" % item_id)
		seen.append(item_id)


# ── Armorsmith ──────────────────────────────────────────────────────────


func test_armorsmith_loads_with_correct_shop_id() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	assert_false(shop.is_empty(), "armorsmith shop should load")
	var data: Dictionary = shop.get("shop", {})
	assert_eq(data.get("shop_id", ""), "valdris_crown_armorsmith", "shop_id should match")


func test_armorsmith_has_only_armor_items() -> void:
	var expected_items: Array[String] = [
		"iron_helm",
		"travelers_hood",
		"ember_circlet",
		"chain_mail",
		"iron_plate",
		"silk_robe",
		"reinforced_vest",
	]
	var shop: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	var item_ids: Array[String] = []
	for entry: Variant in inventory:
		item_ids.append((entry as Dictionary).get("item_id", ""))
	assert_eq(item_ids.size(), expected_items.size(), "armorsmith should have exactly 7 items")
	for expected: String in expected_items:
		assert_true(item_ids.has(expected), "armorsmith should have item: %s" % expected)


func test_armorsmith_items_exist_in_armor_json() -> void:
	var armor_data: Variant = DataManager.load_json("res://data/equipment/armor.json")
	assert_true(armor_data is Dictionary, "armor.json should be a dict")
	var armor_list: Array = (armor_data as Dictionary).get("armor", [])
	var armor_ids: Array[String] = []
	for a: Variant in armor_list:
		armor_ids.append((a as Dictionary).get("id", ""))

	var shop: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	for entry: Variant in inventory:
		var item_id: String = (entry as Dictionary).get("item_id", "")
		assert_true(
			armor_ids.has(item_id), "armorsmith item '%s' should exist in armor.json" % item_id
		)


func test_armorsmith_no_duplicate_items() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_armorsmith")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	var seen: Array[String] = []
	for entry: Variant in inventory:
		var item_id: String = (entry as Dictionary).get("item_id", "")
		assert_false(seen.has(item_id), "duplicate item_id in armorsmith: %s" % item_id)
		seen.append(item_id)


# ── Jeweler ──────────────────────────────────────────────────────────────


func test_jeweler_loads_with_correct_shop_id() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	assert_false(shop.is_empty(), "jeweler shop should load")
	var data: Dictionary = shop.get("shop", {})
	assert_eq(data.get("shop_id", ""), "valdris_crown_jeweler", "shop_id should match")


func test_jeweler_items_exist_in_accessories_json() -> void:
	var acc_data: Variant = DataManager.load_json("res://data/equipment/accessories.json")
	assert_true(acc_data is Dictionary, "accessories.json should be a dict")
	var acc_list: Array = (acc_data as Dictionary).get("accessories", [])
	var acc_ids: Array[String] = []
	for a: Variant in acc_list:
		acc_ids.append((a as Dictionary).get("id", ""))

	var shop: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	for entry: Variant in inventory:
		var item_id: String = (entry as Dictionary).get("item_id", "")
		assert_true(
			acc_ids.has(item_id), "jeweler item '%s' should exist in accessories.json" % item_id
		)


func test_jeweler_prices_match_expected() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	var price_map: Dictionary = {}
	for entry: Variant in inventory:
		var d: Dictionary = entry as Dictionary
		price_map[d.get("item_id", "")] = d.get("buy_price", -1)

	assert_eq(int(price_map.get("pact_charm_wind", -1)), 600, "pact_charm_wind price should be 600")
	assert_eq(
		int(price_map.get("pact_charm_earth", -1)), 600, "pact_charm_earth price should be 600"
	)
	assert_eq(int(price_map.get("silver_ring", -1)), 200, "silver_ring price should be 200")
	assert_eq(
		int(price_map.get("guardian_pendant", -1)), 400, "guardian_pendant price should be 400"
	)


func test_jeweler_no_duplicate_items() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_jeweler")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	var seen: Array[String] = []
	for entry: Variant in inventory:
		var item_id: String = (entry as Dictionary).get("item_id", "")
		assert_false(seen.has(item_id), "duplicate item_id in jeweler: %s" % item_id)
		seen.append(item_id)


# ── Specialty (regression) ───────────────────────────────────────────────


func test_specialty_shop_still_loads_with_7_items() -> void:
	var shop: Dictionary = DataManager.load_shop("valdris_crown_specialty")
	assert_false(shop.is_empty(), "specialty shop should still load")
	var inventory: Array = shop.get("shop", {}).get("inventory", [])
	assert_eq(inventory.size(), 7, "specialty shop should still have 7 items")


# ── Old armorer no longer exists ─────────────────────────────────────────


func test_old_armorer_shop_no_longer_exists() -> void:
	var path: String = "res://data/shops/valdris_crown_armorer.json"
	assert_false(FileAccess.file_exists(path), "old valdris_crown_armorer.json should not exist")
