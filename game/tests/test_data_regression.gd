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
## 5. technical-architecture.md sections 2.6 and 2.8 keep documenting the
##    encounter and crafting schemas the shipped JSON actually carries
##    (issue #362)


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


# ── technical-architecture.md §2.6 / §2.8 schema sync (issue #362) ───────


## The contents of every ```json fence inside `text`, concatenated.
##
## Retired-form assertions run against THIS, never against the whole
## section. The field notes under §2.6 and §2.8 deliberately NAME the
## retired forms — "the earlier draft (`floor`, and flat `back_attack_rate`
## / `preemptive_rate`) never landed" — so a whole-section
## `assert_false(contains("back_attack_rate"))` would fail on the very
## sentence that records the decision. What must stay clean is the shape
## the section holds out as current: the example JSON.
func _json_fences(text: String) -> String:
	var out: PackedStringArray = PackedStringArray()
	var inside: bool = false
	for line: String in text.split("\n"):
		if line.begins_with("```"):
			inside = line.begins_with("```json")
			continue
		if inside:
			out.append(line)
	return "\n".join(out)


## Every res://data/encounters/*.json that ships a `floors` array, parsed.
## overworld.json and overworld_zones.json are the documented exceptions
## (§2.6 "Three files depart from this shape deliberately") and are skipped.
func _floor_shaped_encounter_files() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var dir: DirAccess = DirAccess.open("res://data/encounters")
	if dir == null:
		fail_test("cannot open res://data/encounters")
		return out
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".json"):
			continue
		var parsed: Variant = DataManager.load_json("res://data/encounters/".path_join(file_name))
		if not parsed is Dictionary:
			continue
		var record: Dictionary = parsed as Dictionary
		if record.has("floors"):
			out.append(record)
	return out


## Keys carried by EVERY dictionary in `records` — the fields the doc is
## obliged to document. Empty when `records` is empty, which is why each
## caller asserts the record count before using the result.
func _universal_keys(records: Array) -> Array[String]:
	var universal: Dictionary = {}
	var seeded: bool = false
	for entry: Variant in records:
		if not entry is Dictionary:
			continue
		var record: Dictionary = entry as Dictionary
		if not seeded:
			for key: Variant in record.keys():
				universal[key] = true
			seeded = true
			continue
		for key: Variant in universal.keys():
			if not record.has(key):
				universal.erase(key)
	var out: Array[String] = []
	for key: Variant in universal.keys():
		out.append(str(key))
	out.sort()
	return out


## Names every key of `keys` the doc section does not mention at all.
##
## Two spellings count, because the doc uses both: a JSON key inside an
## example fence ("floor_id") and inline code in the field notes
## (`base_weapon_id`). §2.8 documents synergies.json entirely in prose —
## it ships no synergies example — so a quoted-form-only diff would report
## six documented keys as missing.
func _undocumented(section: String, keys: Array[String]) -> Array[String]:
	var missing: Array[String] = []
	for key: String in keys:
		if not (section.contains('"%s"' % key) or section.contains("`%s`" % key)):
			missing.append(key)
	return missing


func test_arch_doc_2_6_documents_every_universal_encounter_field() -> void:
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var section: String = _arch_section("### 2.6 Encounter Data", "### 2.7 Spell Data", content)
	if section.is_empty():
		return
	var dungeons: Array[Dictionary] = _floor_shaped_encounter_files()
	# Guard the diffs below: no files means every key list is empty and every
	# assertion passes vacuously.
	assert_gte(
		dungeons.size(), 20, "20+ encounter files ship a floors array, got %d" % dungeons.size()
	)
	var floors: Array = []
	var groups: Array = []
	var bosses: Array = []
	for dungeon: Dictionary in dungeons:
		for floor_entry: Variant in dungeon.get("floors", []):
			floors.append(floor_entry)
			if floor_entry is Dictionary:
				for group: Variant in (floor_entry as Dictionary).get("groups", []):
					groups.append(group)
		for boss: Variant in dungeon.get("bosses", []):
			bosses.append(boss)
	assert_gt(floors.size(), 0, "the encounter files ship floors")
	assert_gt(groups.size(), 0, "the encounter files ship encounter groups")
	assert_gt(bosses.size(), 0, "the encounter files ship boss records")

	var dungeon_records: Array = []
	dungeon_records.assign(dungeons)
	var levels: Dictionary = {
		"dungeon": _universal_keys(dungeon_records),
		"floor": _universal_keys(floors),
		"group": _universal_keys(groups),
		"boss": _universal_keys(bosses),
	}
	for level: String in levels:
		var keys: Array[String] = levels[level]
		assert_gte(keys.size(), 3, "every %s record should share 3+ keys" % level)
		assert_eq(
			_undocumented(section, keys),
			[] as Array[String],
			"technical-architecture.md §2.6 does not document these %s keys" % level,
		)


func test_arch_doc_2_6_example_shows_no_retired_encounter_forms() -> void:
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var section: String = _arch_section("### 2.6 Encounter Data", "### 2.7 Spell Data", content)
	if section.is_empty():
		return
	var example: String = _json_fences(section)
	assert_gt(example.length(), 0, "§2.6 should carry an example JSON block")
	assert_false(
		example.contains("back_attack_rate") or example.contains("preemptive_rate"),
		"§2.6's example must not show the retired flat back_attack_rate/preemptive_rate pair",
	)
	assert_true(
		example.contains('"formation_rates"'),
		"§2.6's example should show the formation_rates object that replaced them",
	)
	# `floor` is retired at FLOOR level only — a boss still carries one, which
	# is why this narrows to the floors array instead of the whole example.
	var floors_start: int = example.find('"floors"')
	var bosses_start: int = example.find('"bosses"')
	assert_gt(floors_start, -1, "§2.6's example should show a floors array")
	assert_gt(bosses_start, floors_start, "§2.6's example should show bosses after floors")
	var floors_block: String = example.substr(floors_start, bosses_start - floors_start)
	assert_true(floors_block.contains('"floor_id"'), "floors are keyed floor_id")
	assert_false(
		floors_block.contains('"floor":'),
		'§2.6\'s floors must not use the retired bare "floor" key',
	)


func test_arch_doc_2_8_documents_every_universal_crafting_field() -> void:
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var section: String = _arch_section(
		"### 2.8 Crafting Data", "### Data Formats Deferred at Design Time", content
	)
	if section.is_empty():
		return
	var devices: Variant = DataManager.load_json("res://data/crafting/devices.json")
	var recipes: Variant = DataManager.load_json("res://data/crafting/recipes.json")
	var synergies: Variant = DataManager.load_json("res://data/crafting/synergies.json")
	assert_true(devices is Dictionary, "devices.json parses")
	assert_true(recipes is Dictionary, "recipes.json parses")
	assert_true(synergies is Dictionary, "synergies.json parses")
	if not (devices is Dictionary and recipes is Dictionary and synergies is Dictionary):
		return
	var tables: Dictionary = {
		"devices": (devices as Dictionary).get("devices", []),
		"forging_recipes": (recipes as Dictionary).get("forging_recipes", []),
		"infusions": (recipes as Dictionary).get("infusions", []),
		"synergies": (synergies as Dictionary).get("synergies", []),
	}
	for table: String in tables:
		var records: Array = tables[table]
		# Guard the diff: an empty table would document nothing and still pass.
		assert_gt(records.size(), 0, "%s should ship records" % table)
		var keys: Array[String] = _universal_keys(records)
		assert_gte(keys.size(), 5, "every %s record should share 5+ keys" % table)
		assert_eq(
			_undocumented(section, keys),
			[] as Array[String],
			"technical-architecture.md §2.8 does not document these %s keys" % table,
		)


func test_arch_doc_2_8_example_shows_no_retired_crafting_forms() -> void:
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var section: String = _arch_section(
		"### 2.8 Crafting Data", "### Data Formats Deferred at Design Time", content
	)
	if section.is_empty():
		return
	var example: String = _json_fences(section)
	assert_gt(example.length(), 0, "§2.8 should carry example JSON blocks")
	for retired: String in ['"result_item"', '"forge_location"', '"recipes": ['] as Array[String]:
		assert_false(
			example.contains(retired),
			"§2.8's examples must not show the retired %s form" % retired,
		)
	assert_true(example.contains('"result_id"'), "a forging recipe names its result as result_id")
	assert_true(example.contains('"forge_locations"'), "the forge list is the plural form")
	assert_true(example.contains('"forging_recipes": ['), "the top-level array is forging_recipes")


func test_arch_doc_examples_use_roman_numeral_act_ids() -> void:
	# The game data has no act_1 anywhere; the ids are act_i/act_ii/act_iii.
	# Scoped to the JSON fences because the prose deliberately says "never
	# `act_1`" in both §2.6 and §2.8 — banning the string outright would fail
	# on the sentences that state the rule.
	var content: String = _read_repo_doc("docs/plans/technical-architecture.md")
	if content.is_empty():
		return
	var examples: String = _json_fences(content)
	assert_gt(examples.length(), 0, "the doc should carry example JSON blocks")
	assert_false(examples.contains("act_1"), "no example JSON may use the arabic act_1 id")
	assert_false(content.contains('"act_1"'), 'no part of the doc may quote "act_1" as a value')


# ── loot shapes the engine can actually read (issues #309, #342) ─────────


## The canon steal shapes, per the enemy-data spec's Steal Mapping Rules:
## a whole-record `null` (Rule 3), or an object carrying BOTH tier keys, each
## of which is `null` (Rule 4) or a `{item_id, rate}` pair (Rules 1/2/5/6).
## `{}` is none of these — it is what compact_patrol/compact_scout shipped
## until #309, and it reads at runtime as "carries nothing" without ever
## saying so. Anything the shapes below do not cover makes roll_steal()
## silently unstealable, so the shape is guarded rather than trusted.
func _steal_shape_error(record: Dictionary) -> String:
	var eid: String = str(record.get("id", "?"))
	if not record.has("steal"):
		return "%s has no steal field" % eid
	var steal: Variant = record.get("steal")
	if steal == null:
		return ""
	if not steal is Dictionary:
		return "%s steal is %s, not an object or null" % [eid, type_string(typeof(steal))]
	var tiers: Dictionary = steal as Dictionary
	for tier: String in ["common", "rare"]:
		if not tiers.has(tier):
			return "%s steal is missing the %s tier (empty/partial object)" % [eid, tier]
		var entry: Variant = tiers.get(tier)
		if entry == null:
			continue
		if not entry is Dictionary:
			return "%s steal.%s is neither null nor an object" % [eid, tier]
		var pair: Dictionary = entry as Dictionary
		if not pair.has("item_id") or str(pair.get("item_id", "")).is_empty():
			return "%s steal.%s has no item_id" % [eid, tier]
		if not pair.has("rate"):
			return "%s steal.%s has no rate" % [eid, tier]
	return ""


## Drop is `null` (leaves nothing) or a `{item_id, rate}` pair. roll_drop()
## reads it the same way roll_steal() reads a tier.
func _drop_shape_error(record: Dictionary) -> String:
	var eid: String = str(record.get("id", "?"))
	if not record.has("drop"):
		return "%s has no drop field" % eid
	var drop: Variant = record.get("drop")
	if drop == null:
		return ""
	if not drop is Dictionary:
		return "%s drop is %s, not an object or null" % [eid, type_string(typeof(drop))]
	var pair: Dictionary = drop as Dictionary
	if not pair.has("item_id") or str(pair.get("item_id", "")).is_empty():
		return "%s drop has no item_id" % eid
	if not pair.has("rate"):
		return "%s drop has no rate" % eid
	return ""


func test_every_shipped_enemy_ships_a_readable_loot_shape() -> void:
	var problems: Array[String] = []
	var inspected: int = 0
	for act: String in ["act_i", "act_ii", "act_iii", "interlude", "optional"]:
		for entry: Variant in DataManager.load_enemies(act):
			if not entry is Dictionary:
				continue
			inspected += 1
			var record: Dictionary = entry as Dictionary
			var steal_problem: String = _steal_shape_error(record)
			if not steal_problem.is_empty():
				problems.append(steal_problem)
			var drop_problem: String = _drop_shape_error(record)
			if not drop_problem.is_empty():
				problems.append(drop_problem)
	# Floor on what was LOOKED AT, not just on what was found: a scan whose
	# act list rots reports "clean" and "never ran" identically. Repair the
	# act list if this trips — do not lower the floor.
	assert_gte(inspected, 200, "the act tables should carry 200+ enemies, saw %d" % inspected)
	assert_eq(problems, [] as Array[String], "enemy records with unreadable loot shapes")


## The guard above pins the DATA; this pins the ENGINE against the same
## shapes, so the two cannot drift apart. Every shipped record must survive
## a steal and a drop roll and hand back the declared dictionary.
func test_every_shipped_enemy_survives_a_loot_roll() -> void:
	var enemy: Enemy = preload("res://scenes/entities/enemy.tscn").instantiate()
	add_child_autofree(enemy)
	var rolled: int = 0
	for act: String in ["act_i", "act_ii", "act_iii", "interlude", "optional"]:
		for entry: Variant in DataManager.load_enemies(act):
			if not entry is Dictionary:
				continue
			enemy.enemy_data = entry as Dictionary
			rolled += 1
			for tier: String in ["common", "rare"]:
				var steal: Variant = enemy.roll_steal(tier)
				if not steal is Dictionary or not (steal as Dictionary).has("success"):
					fail_test(
						(
							"roll_steal('%s') on %s returned %s"
							% [tier, str(enemy.enemy_data.get("id", "?")), str(steal)]
						)
					)
					return
			var drop: Variant = enemy.roll_drop()
			if not drop is Dictionary or not (drop as Dictionary).has("success"):
				fail_test(
					(
						"roll_drop() on %s returned %s"
						% [str(enemy.enemy_data.get("id", "?")), str(drop)]
					)
				)
				return
	assert_gte(rolled, 200, "the act tables should carry 200+ enemies, rolled %d" % rolled)
