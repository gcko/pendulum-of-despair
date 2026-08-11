extends GutTest
## Regression tests for data/doc issues fixed in PR #146 follow-up.
##
## Covers:
## 1. hi_potion must have available_act:2 in ALL shops that carry it
## 2. New items (ley_lantern, pallor_antidote, warp_walker_boots,
##    gravity_shard, composite_shortbow) exist in their data files
## 3. No camelCase keys remain in save-system.md pseudo-schema
## 4. technical-architecture.md section 2.1 keeps documenting the enemy
##    schema the act tables actually ship (issue #235)


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


# ── repo-doc helper (shared by the doc guards below) ────────────────────


## Read a repo doc that lives outside res://. Fails loudly if unreachable,
## so a moved doc cannot silently turn the guards below into no-ops.
func _read_repo_doc(rel_path: String) -> String:
	var repo_root: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var abs_path: String = repo_root.path_join(rel_path)
	if not FileAccess.file_exists(abs_path):
		fail_test("cannot read %s (looked at %s)" % [rel_path, abs_path])
		return ""
	# file_exists() passing does not guarantee open() succeeds — permissions or a
	# transient IO error still return null, and get_as_text() on null crashes the
	# whole runner instead of failing this one test.
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.READ)
	if file == null:
		fail_test(
			(
				"cannot open %s (error %d) — the guard cannot run"
				% [abs_path, FileAccess.get_open_error()]
			)
		)
		return ""
	var content: String = file.get_as_text()
	file.close()
	return content


# ── save-system.md camelCase regression ─────────────────────────────────


func test_no_camelcase_keys_in_save_system_md() -> void:
	# _read_repo_doc() fails the test if the doc moves, so this guard cannot
	# quietly degrade into a scan of an empty string.
	var content: String = _read_repo_doc("docs/story/save-system.md")
	if content.is_empty():
		return

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


# ── technical-architecture.md §2.1 enemy schema sync (issue #235) ────────


## Keys carried by EVERY enemy record across every act table — the fields
## section 2.1 is obliged to document.
func _universal_enemy_keys() -> Array[String]:
	var universal: Dictionary = {}
	var seeded: bool = false
	for act: String in ["act_i", "act_ii", "act_iii", "interlude", "optional"]:
		for entry: Variant in DataManager.load_enemies(act):
			if not entry is Dictionary:
				continue
			var enemy: Dictionary = entry as Dictionary
			if not seeded:
				for key: Variant in enemy.keys():
					universal[key] = true
				seeded = true
				continue
			for key: Variant in universal.keys():
				if not enemy.has(key):
					universal.erase(key)
	var out: Array[String] = []
	for key: Variant in universal.keys():
		out.append(str(key))
	out.sort()
	return out


## Slice a markdown doc between two headings. Fails the test (returns "")
## if either heading is missing, so a renamed section cannot silently
## reduce the guards above to a scan of an empty string.
func _arch_section(from_heading: String, to_heading: String, content: String) -> String:
	var start: int = content.find(from_heading)
	var end: int = content.find(to_heading)
	if start < 0:
		fail_test("technical-architecture.md is missing the '%s' heading" % from_heading)
		return ""
	if end <= start:
		fail_test("'%s' should follow '%s'" % [to_heading, from_heading])
		return ""
	return content.substr(start, end - start)


func test_arch_doc_2_1_documents_every_universal_enemy_field() -> void:
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var section: String = _arch_section("### 2.1 Enemy Data", "### 2.2 Item Data", content)
	if section.is_empty():
		return
	var keys: Array[String] = _universal_enemy_keys()
	# Guard the loop below: an empty key list would make it vacuously pass.
	assert_gte(
		keys.size(), 20, "every act table should share 20+ enemy fields, got %d" % keys.size()
	)
	var undocumented: Array[String] = []
	for key: String in keys:
		if not section.contains('"%s"' % key):
			undocumented.append(key)
	assert_eq(
		undocumented.size(),
		0,
		"technical-architecture.md section 2.1 does not document: %s" % str(undocumented),
	)


func test_arch_doc_2_1_shows_nested_two_tier_steal() -> void:
	# The shipped schema is nested steal:{common,rare}, read by
	# enemy.gd::roll_steal(). The flat steal_common/steal_rare pair was a
	# proposal that never landed (issue #235).
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var section: String = _arch_section("### 2.1 Enemy Data", "### 2.2 Item Data", content)
	if section.is_empty():
		return
	assert_true(section.contains('"steal": {'), "section 2.1 should show steal as an object")
	assert_true(section.contains('"common"'), "section 2.1 steal should carry a common tier")
	assert_true(section.contains('"rare"'), "section 2.1 steal should carry a rare tier")
	assert_false(
		section.contains("steal_common") or section.contains("steal_rare"),
		"section 2.1 should not show the flat steal_common/steal_rare pair",
	)
	# The stale note that survived until #235 claimed the opposite.
	assert_false(
		content.contains("a single `steal` field"),
		"technical-architecture.md still claims the enemy JSON uses a single steal field",
	)
