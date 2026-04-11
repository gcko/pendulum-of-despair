extends GutTest
## Integration tests for the Ley Crystal system — static data, PartyState
## methods, collection tracking, save/load round-trip, and menu wiring.


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.ley_crystals.clear()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	EventFlags.clear_all()


func after_each() -> void:
	DataManager.clear_cache()
	PartyState.ley_crystals.clear()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	EventFlags.clear_all()


# --- Crystal Data ---


func test_all_18_crystals_load() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	assert_eq(crystals.size(), 18, "should load exactly 18 crystals")


func test_xp_thresholds_have_5_entries() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	for entry: Variant in crystals:
		if entry is Dictionary:
			var c: Dictionary = entry as Dictionary
			assert_eq(
				c.get("xp_thresholds", []).size(),
				5,
				"crystal %s should have 5 xp_thresholds" % c.get("id", "?")
			)


func test_level_bonuses_have_5_entries() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	for entry: Variant in crystals:
		if entry is Dictionary:
			var c: Dictionary = entry as Dictionary
			assert_eq(
				c.get("level_bonuses", []).size(),
				5,
				"crystal %s should have 5 level_bonuses" % c.get("id", "?")
			)


func test_invocations_have_5_level_effects() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	for entry: Variant in crystals:
		if entry is Dictionary:
			var c: Dictionary = entry as Dictionary
			var inv: Dictionary = c.get("invocation", {})
			assert_eq(
				inv.get("level_effects", []).size(),
				5,
				"crystal %s invocation should have 5 level_effects" % c.get("id", "?")
			)


func test_convergence_shard_has_secret_lv5() -> void:
	var c: Dictionary = DataManager.get_ley_crystal("convergence_shard")
	assert_false(c.is_empty(), "convergence_shard should exist")
	assert_true(c.get("secret_lv5", false), "convergence_shard should have secret_lv5 = true")


# --- PartyState Methods ---


func test_add_ley_crystal() -> void:
	PartyState.add_ley_crystal("ember_shard")
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_false(state.is_empty(), "ember_shard should be in ley_crystals after add")
	assert_eq(state.get("level", 0), 1, "newly added crystal should be Lv1")
	assert_eq(state.get("xp", -1), 0, "newly added crystal should have 0 XP")


func test_add_ley_crystal_duplicate_is_noop() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 400)
	var xp_before: int = PartyState.get_crystal_state("ember_shard").get("xp", -1)
	PartyState.add_ley_crystal("ember_shard")
	var xp_after: int = PartyState.get_crystal_state("ember_shard").get("xp", -1)
	assert_eq(xp_after, xp_before, "adding duplicate crystal should not reset XP")


func test_get_crystal_state_unknown() -> void:
	var state: Dictionary = PartyState.get_crystal_state("nonexistent_crystal")
	assert_true(state.is_empty(), "unknown crystal should return empty dict")


func test_add_crystal_xp_increments() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 400)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("xp", 0), 400, "400 XP should be stored")
	assert_eq(state.get("level", 0), 1, "400 XP should stay at Lv1 (threshold is 800)")


func test_add_crystal_xp_auto_levels() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 800)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("level", 0), 2, "800 XP should trigger auto-level to Lv2")


func test_add_crystal_xp_caps_at_lv5() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 99999)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("level", 0), 5, "99999 XP should cap at Lv5")
	assert_eq(state.get("xp", 0), 15000, "XP should be capped at the Lv5 threshold (15000)")


# --- Collection ---


func test_get_collected_crystals() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_ley_crystal("iron_core")
	PartyState.add_ley_crystal("ley_prism")
	var collected: Array[String] = PartyState.get_collected_crystals()
	assert_eq(collected.size(), 3, "should return 3 collected crystal IDs")
	assert_true("ember_shard" in collected, "ember_shard should be in collected list")
	assert_true("iron_core" in collected, "iron_core should be in collected list")
	assert_true("ley_prism" in collected, "ley_prism should be in collected list")


# --- Save / Load ---


func test_save_includes_ley_crystals() -> void:
	PartyState.add_ley_crystal("ember_shard")
	var save_data: Dictionary = PartyState.build_save_data()
	assert_true(save_data.has("ley_crystals"), "build_save_data should include ley_crystals key")
	var lc: Dictionary = save_data.get("ley_crystals", {})
	assert_true(lc.has("ember_shard"), "saved ley_crystals should contain ember_shard")


func test_load_restores_ley_crystals() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 800)
	var save_data: Dictionary = PartyState.build_save_data()
	PartyState.ley_crystals.clear()
	assert_true(
		PartyState.get_crystal_state("ember_shard").is_empty(),
		"crystals should be cleared before load"
	)
	PartyState.load_from_save(save_data)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_false(state.is_empty(), "ember_shard should be restored after load_from_save")
	assert_eq(state.get("level", 0), 2, "restored crystal should have level 2")
	assert_eq(state.get("xp", 0), 800, "restored crystal should have 800 XP")


# --- Equip / Unequip ---


func test_equip_crystal_sets_slot() -> void:
	PartyState.initialize_new_game()
	PartyState.add_ley_crystal("ember_shard")
	PartyState.equip_crystal("edren", "ember_shard")
	var m: Dictionary = PartyState.get_member("edren")
	assert_eq(
		m.get("equipment", {}).get("crystal", ""),
		"ember_shard",
		"equip_crystal should set equipment.crystal on the character"
	)


func test_equip_crystal_swaps_from_other() -> void:
	PartyState.initialize_new_game()
	PartyState.add_ley_crystal("ember_shard")
	PartyState.equip_crystal("edren", "ember_shard")
	PartyState.equip_crystal("cael", "ember_shard")
	var edren: Dictionary = PartyState.get_member("edren")
	var cael: Dictionary = PartyState.get_member("cael")
	assert_eq(
		edren.get("equipment", {}).get("crystal", ""),
		"",
		"edren's crystal should be cleared after swap"
	)
	assert_eq(
		cael.get("equipment", {}).get("crystal", ""),
		"ember_shard",
		"cael should now have ember_shard equipped"
	)


func test_unequip_crystal_clears_slot() -> void:
	PartyState.initialize_new_game()
	PartyState.add_ley_crystal("ember_shard")
	PartyState.equip_crystal("edren", "ember_shard")
	var old: String = PartyState.unequip_crystal("edren")
	assert_eq(old, "ember_shard", "unequip_crystal should return the removed crystal ID")
	var m: Dictionary = PartyState.get_member("edren")
	assert_eq(
		m.get("equipment", {}).get("crystal", ""), "", "crystal slot should be empty after unequip"
	)


func test_unequip_crystal_does_not_add_to_owned_equipment() -> void:
	PartyState.initialize_new_game()
	var equip_before: int = PartyState.owned_equipment.size()
	PartyState.add_ley_crystal("ember_shard")
	PartyState.equip_crystal("edren", "ember_shard")
	PartyState.unequip_crystal("edren")
	assert_eq(
		PartyState.owned_equipment.size(),
		equip_before,
		"unequip_crystal should NOT add crystal to owned_equipment"
	)


func test_equip_crystal_emits_signal() -> void:
	PartyState.initialize_new_game()
	PartyState.add_ley_crystal("ember_shard")
	watch_signals(PartyState)
	PartyState.equip_crystal("edren", "ember_shard")
	assert_signal_emitted(PartyState, "equipment_changed")


# --- Scene Structure ---


func test_menu_scene_has_crystal_screen() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(text.contains("CrystalScreen"), "menu.tscn should contain a CrystalScreen node")


func test_crystal_command_not_stubbed() -> void:
	var text: String = _read_file("res://scripts/ui/menu_overlay.gd")
	assert_false(
		text.contains('"Crystal", "char_select": true, "stubbed": true'),
		"Crystal command should not be stubbed in menu_overlay.gd"
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
