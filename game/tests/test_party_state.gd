extends GutTest
## Tests for PartyState autoload — party management, inventory, equipment, config.

var _state: Node


func before_each() -> void:
	_state = preload("res://scripts/autoload/party_state.gd").new()
	add_child_autofree(_state)


func after_each() -> void:
	_state = null


# --- New Game Initialization ---


func test_initialize_new_game_creates_two_members() -> void:
	_state.initialize_new_game()
	assert_eq(_state.members.size(), 2, "Edren + Cael")


func test_initialize_new_game_edren_stats() -> void:
	_state.initialize_new_game()
	var edren: Dictionary = _state.get_member("edren")
	assert_eq(edren.get("level", 0), 1)
	assert_eq(edren.get("current_hp", 0), edren.get("max_hp", 0))
	assert_gt(edren.get("max_hp", 0), 0, "HP should be positive")


func test_initialize_new_game_starting_inventory() -> void:
	_state.initialize_new_game()
	var consumables: Dictionary = _state.get_consumables()
	assert_eq(consumables.get("potion", 0), 5)
	assert_eq(consumables.get("antidote", 0), 2)


func test_initialize_new_game_starting_gold() -> void:
	_state.initialize_new_game()
	assert_eq(_state.get_gold(), 200)


func test_initialize_new_game_formation() -> void:
	_state.initialize_new_game()
	var active: Array = _state.formation.get("active", [])
	assert_eq(active.size(), 2)
	assert_eq(active[0], 0)
	assert_eq(active[1], 1)


func test_initialize_new_game_starting_equipment() -> void:
	_state.initialize_new_game()
	var edren: Dictionary = _state.get_member("edren")
	var equip: Dictionary = edren.get("equipment", {})
	assert_eq(equip.get("weapon", ""), "arcanite_sword_proto")


# --- Party Access ---


func test_get_member_not_found_returns_empty() -> void:
	_state.initialize_new_game()
	var result: Dictionary = _state.get_member("nonexistent")
	assert_true(result.is_empty())


func test_get_active_party() -> void:
	_state.initialize_new_game()
	var active: Array[Dictionary] = _state.get_active_party()
	assert_eq(active.size(), 2)
	assert_eq(active[0].get("character_id", ""), "edren")
	assert_eq(active[1].get("character_id", ""), "cael")


# --- Stat Calculation ---


func test_effective_stat_base_only() -> void:
	_state.initialize_new_game()
	# Edren base ATK at level 1 = 18
	var atk: int = _state.get_effective_stat("edren", "atk")
	assert_gt(atk, 0, "ATK should be positive")


func test_derived_stats() -> void:
	_state.initialize_new_game()
	var derived: Dictionary = _state.get_derived_stats("edren")
	assert_true(derived.has("eva_pct"))
	assert_true(derived.has("meva_pct"))
	assert_true(derived.has("crit_pct"))
	assert_gte(derived["eva_pct"], 0)
	assert_lte(derived["eva_pct"], 50)


func test_equipment_bonus_calculation() -> void:
	_state.initialize_new_game()
	# Arcanite sword proto has atk 13, arcanite mail proto has def 10
	var bonus: int = _state.get_equipment_bonus("edren", "atk")
	assert_eq(bonus, 13, "arcanite_sword_proto ATK = 13")


# --- Equipment ---


func test_unequip_slot() -> void:
	_state.initialize_new_game()
	var old: String = _state.unequip_slot("edren", "weapon")
	assert_eq(old, "arcanite_sword_proto")
	var edren: Dictionary = _state.get_member("edren")
	assert_eq(edren.get("equipment", {}).get("weapon", ""), "")


func test_unequip_returns_to_owned() -> void:
	_state.initialize_new_game()
	_state.unequip_slot("edren", "weapon")
	assert_eq(_state.owned_equipment.size(), 1)
	assert_eq(_state.owned_equipment[0].get("equipment_id", ""), "arcanite_sword_proto")


func test_equip_item() -> void:
	_state.initialize_new_game()
	# Unequip first so arcanite_sword_proto goes to inventory
	_state.unequip_slot("edren", "weapon")
	# Re-equip
	var result: Dictionary = _state.equip_item("edren", "weapon", "arcanite_sword_proto")
	assert_eq(result.get("old_equipment_id", ""), "")  # Was empty
	var edren: Dictionary = _state.get_member("edren")
	assert_eq(edren.get("equipment", {}).get("weapon", ""), "arcanite_sword_proto")


# --- Inventory ---


func test_add_item() -> void:
	_state.initialize_new_game()
	_state.add_item("ether", 3)
	assert_eq(_state.get_consumables().get("ether", 0), 3)


func test_remove_item() -> void:
	_state.initialize_new_game()
	_state.remove_item("potion", 2)
	assert_eq(_state.get_consumables().get("potion", 0), 3)


func test_remove_item_to_zero_erases() -> void:
	_state.initialize_new_game()
	_state.remove_item("antidote", 5)
	assert_false(_state.get_consumables().has("antidote"))


func test_use_item_restores_hp() -> void:
	_state.initialize_new_game()
	var edren: Dictionary = _state.get_member("edren")
	edren["current_hp"] = 10  # Damage edren
	var ok: bool = _state.use_item("potion", "edren")
	assert_true(ok, "use should succeed")
	assert_gt(edren.get("current_hp", 0), 10, "HP should increase")
	assert_eq(_state.get_consumables().get("potion", 0), 4, "quantity decremented")


func test_use_item_field_unusable_fails() -> void:
	_state.initialize_new_game()
	_state.add_item("smoke_bomb", 1)
	var ok: bool = _state.use_item("smoke_bomb", "edren")
	assert_false(ok, "smoke_bomb not usable in field")


# --- Gold ---


func test_add_gold() -> void:
	_state.initialize_new_game()
	_state.add_gold(100)
	assert_eq(_state.get_gold(), 300)


func test_spend_gold_success() -> void:
	_state.initialize_new_game()
	assert_true(_state.spend_gold(100))
	assert_eq(_state.get_gold(), 100)


func test_spend_gold_insufficient() -> void:
	_state.initialize_new_game()
	assert_false(_state.spend_gold(999))
	assert_eq(_state.get_gold(), 200, "gold unchanged")


# --- Save/Load Round Trip ---


func test_save_load_round_trip() -> void:
	_state.initialize_new_game()
	_state.add_gold(500)
	_state.add_item("ether", 3)
	var save_data: Dictionary = _state.build_save_data()
	# Reset state
	_state.members.clear()
	_state.gold = 0
	# Load from save
	_state.load_from_save(save_data)
	assert_eq(_state.members.size(), 2)
	assert_eq(_state.gold, 700)


# --- XP Formula ---


func test_xp_to_next_level_1() -> void:
	# Phase 1: floor(24 * 1^1.5) = 24
	_state.initialize_new_game()
	var edren: Dictionary = _state.get_member("edren")
	assert_eq(edren.get("xp_to_next", 0), 24)


# --- Class Titles ---


func test_class_titles() -> void:
	assert_eq(_state.CLASS_TITLES.get("edren", ""), "Knight")
	assert_eq(_state.CLASS_TITLES.get("maren", ""), "Archmage")
	assert_eq(_state.CLASS_TITLES.get("sable", ""), "Thief")


# --- Rest at Inn ---


func test_rest_at_inn_heals_all_members() -> void:
	_state.initialize_new_game()
	for member: Dictionary in _state.members:
		member["current_hp"] = 1
		member["current_mp"] = 0
	_state.rest_at_inn()
	for member: Dictionary in _state.members:
		var cid: String = member.get("character_id", "")
		assert_eq(
			member.get("current_hp", 0),
			member.get("max_hp", 0),
			"%s HP should be fully restored" % cid
		)
		assert_eq(
			member.get("current_mp", 0),
			member.get("max_mp", 0),
			"%s MP should be fully restored" % cid
		)


func test_rest_at_inn_clears_status_effects() -> void:
	_state.initialize_new_game()
	for member: Dictionary in _state.members:
		member["status_effects"] = ["poison", "blind"]
	_state.rest_at_inn()
	for member: Dictionary in _state.members:
		var cid: String = member.get("character_id", "")
		var effects: Array = member.get("status_effects", [])
		assert_true(effects.is_empty(), "%s status_effects should be empty after inn rest" % cid)


func test_rest_at_inn_heals_reserve_members() -> void:
	_state.initialize_new_game()
	# Move Cael (index 1) to reserve
	_state.formation["active"] = [0] as Array[int]
	_state.formation["reserve"] = [1] as Array[int]
	# Damage the reserve member
	var cael: Dictionary = _state.get_member("cael")
	cael["current_hp"] = 1
	cael["current_mp"] = 0
	_state.rest_at_inn()
	assert_eq(
		cael.get("current_hp", 0),
		cael.get("max_hp", 0),
		"Reserve member HP should be fully restored"
	)
	assert_eq(
		cael.get("current_mp", 0),
		cael.get("max_mp", 0),
		"Reserve member MP should be fully restored"
	)


# --- Equipment Instance IDs ---


func test_add_equipment_creates_unique_ids() -> void:
	_state.initialize_new_game()
	_state.add_equipment("iron_sword")
	_state.add_equipment("iron_sword")
	assert_eq(_state.owned_equipment.size(), 2, "Should have 2 owned equipment entries")
	var id_a: String = _state.owned_equipment[0].get("id", "")
	var id_b: String = _state.owned_equipment[1].get("id", "")
	assert_ne(id_a, id_b, "Instance IDs should be unique")
	assert_true(id_a.begins_with("iron_sword_inst_"), "First ID should match pattern: %s" % id_a)
	assert_true(id_b.begins_with("iron_sword_inst_"), "Second ID should match pattern: %s" % id_b)


func test_add_equipment_stores_correct_equipment_id() -> void:
	_state.initialize_new_game()
	_state.add_equipment("valdris_blade")
	var entry: Dictionary = _state.owned_equipment[0]
	assert_eq(
		entry.get("equipment_id", ""), "valdris_blade", "equipment_id should match the added item"
	)


# --- add_member / has_member ---


func test_add_member_adds_to_party() -> void:
	_state.initialize_new_game()
	assert_eq(_state.members.size(), 2, "should start with 2 members")
	_state.add_member("torren", 3)
	assert_eq(_state.members.size(), 3, "should have 3 members after add")
	var m: Dictionary = _state.get_member("torren")
	assert_eq(m.get("character_id", ""), "torren", "torren should be in party")
	assert_eq(m.get("level", 0), 3, "torren should be at level 3")


func test_add_member_prevents_duplicates() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 3)
	_state.add_member("torren", 5)
	var count: int = 0
	for m: Dictionary in _state.members:
		if m.get("character_id", "") == "torren":
			count += 1
	assert_eq(count, 1, "should not add duplicate members")


func test_add_member_sets_formation() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	var active: Array = _state.formation.get("active", [])
	assert_true(active.has(2), "torren (idx 2) should be in active party")
	_state.add_member("maren", 1)
	active = _state.formation.get("active", [])
	assert_true(active.has(3), "maren (idx 3) should be in active (4th slot)")


func test_add_member_overflow_to_reserve() -> void:
	_state.initialize_new_game()
	_state.add_member("lira", 1)
	_state.add_member("sable", 1)
	_state.add_member("torren", 1)
	var reserve: Array = _state.formation.get("reserve", [])
	assert_true(reserve.has(4), "torren (idx 4) should go to reserve when active full")


func test_has_member() -> void:
	_state.initialize_new_game()
	assert_true(_state.has_member("edren"), "edren should exist")
	assert_false(_state.has_member("torren"), "torren should not exist yet")
	_state.add_member("torren", 1)
	assert_true(_state.has_member("torren"), "torren should exist after add")


func test_add_member_empty_id_ignored() -> void:
	_state.initialize_new_game()
	_state.add_member("", 1)
	assert_eq(_state.members.size(), 2, "empty id should not add a member")


func test_add_member_negative_level_clamped() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", -5)
	var m: Dictionary = _state.get_member("torren")
	assert_eq(m.get("level", 0), 1, "negative level should be clamped to 1")


# --- find_member_index ---


func test_find_member_index() -> void:
	_state.initialize_new_game()
	assert_eq(_state.find_member_index("edren"), 0, "edren is index 0")
	assert_eq(_state.find_member_index("cael"), 1, "cael is index 1")
	assert_eq(
		_state.find_member_index("nonexistent"),
		-1,
		"missing character returns -1",
	)


# --- move_member_to_reserve ---


func test_move_member_to_reserve() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	var active_before: Array = _state.formation["active"].duplicate()
	assert_true(active_before.has(2), "torren idx in active before move")
	var ok: bool = _state.move_member_to_reserve("torren")
	assert_true(ok, "move should succeed")
	assert_false(
		_state.formation["active"].has(2),
		"torren idx removed from active",
	)
	assert_true(
		_state.formation["reserve"].has(2),
		"torren idx added to reserve",
	)


func test_move_member_to_reserve_not_in_active() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	_state.move_member_to_reserve("torren")
	# Second call should return false — already in reserve
	var ok: bool = _state.move_member_to_reserve("torren")
	assert_false(ok, "cannot move if not in active")


func test_move_member_to_reserve_unknown_character() -> void:
	_state.initialize_new_game()
	var ok: bool = _state.move_member_to_reserve("nobody")
	assert_false(ok, "unknown character returns false")


# --- move_member_to_active ---


func test_move_member_to_active() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	_state.move_member_to_reserve("torren")
	assert_true(
		_state.formation["reserve"].has(2),
		"torren in reserve before restore",
	)
	var ok: bool = _state.move_member_to_active("torren")
	assert_true(ok, "move should succeed")
	assert_true(
		_state.formation["active"].has(2),
		"torren idx back in active",
	)
	assert_false(
		_state.formation["reserve"].has(2),
		"torren idx removed from reserve",
	)


func test_move_member_to_active_party_full() -> void:
	_state.initialize_new_game()
	_state.add_member("lira", 1)
	_state.add_member("sable", 1)
	_state.add_member("torren", 1)
	# torren overflowed to reserve (active already has 4)
	assert_true(
		_state.formation["reserve"].has(4),
		"torren in reserve",
	)
	var ok: bool = _state.move_member_to_active("torren")
	assert_false(ok, "cannot move to active when full")


func test_move_member_to_active_not_in_reserve() -> void:
	_state.initialize_new_game()
	# edren is in active, not reserve
	var ok: bool = _state.move_member_to_active("edren")
	assert_false(ok, "cannot move if not in reserve")


# --- revive_active_at_fraction ---


func test_revive_active_at_fraction() -> void:
	_state.initialize_new_game()
	# KO both members
	for m: Dictionary in _state.members:
		m["current_hp"] = 0
	_state.revive_active_at_fraction(0.25)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		var expected: int = maxi(1, floori(float(m.get("max_hp", 1)) * 0.25))
		assert_eq(
			m.get("current_hp", 0),
			expected,
			"%s should be revived at 25%% max HP" % cid,
		)


func test_revive_active_at_fraction_skips_alive() -> void:
	_state.initialize_new_game()
	var edren: Dictionary = _state.get_member("edren")
	var original_hp: int = edren.get("current_hp", 0)
	# edren is alive, cael is KO'd
	var cael: Dictionary = _state.get_member("cael")
	cael["current_hp"] = 0
	_state.revive_active_at_fraction(0.25)
	assert_eq(
		edren.get("current_hp", 0),
		original_hp,
		"alive member HP unchanged",
	)
	assert_gt(cael.get("current_hp", 0), 0, "KO'd member revived")


func test_revive_active_at_fraction_skips_reserve() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	_state.move_member_to_reserve("torren")
	var torren: Dictionary = _state.get_member("torren")
	torren["current_hp"] = 0
	_state.revive_active_at_fraction(0.25)
	assert_eq(
		torren.get("current_hp", 0),
		0,
		"reserve member should not be revived",
	)


# --- rest_party ---


func test_rest_party() -> void:
	_state.initialize_new_game()
	for m: Dictionary in _state.members:
		m["current_hp"] = 1
		m["current_mp"] = 0
	_state.rest_party(0.5, false)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		assert_gt(
			m.get("current_hp", 0),
			1,
			"%s HP should increase" % cid,
		)


func test_rest_party_clears_status() -> void:
	_state.initialize_new_game()
	for m: Dictionary in _state.members:
		m["status_effects"] = ["poison"]
	_state.rest_party(0.25, true)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		assert_true(
			m.get("status_effects", []).is_empty(),
			"%s status should be cleared" % cid,
		)


func test_rest_party_no_clear_status() -> void:
	_state.initialize_new_game()
	for m: Dictionary in _state.members:
		m["status_effects"] = ["poison"]
	_state.rest_party(0.25, false)
	for m: Dictionary in _state.members:
		assert_false(
			m.get("status_effects", []).is_empty(),
			"status should remain when clears_status=false",
		)


func test_rest_party_does_not_exceed_max() -> void:
	_state.initialize_new_game()
	# Members start at full HP/MP
	_state.rest_party(1.0, false)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		assert_eq(
			m.get("current_hp", 0),
			m.get("max_hp", 0),
			"%s HP should not exceed max" % cid,
		)
		assert_eq(
			m.get("current_mp", 0),
			m.get("max_mp", 0),
			"%s MP should not exceed max" % cid,
		)


# --- consume_item ---


func test_consume_item() -> void:
	_state.initialize_new_game()
	assert_eq(_state.get_consumables().get("potion", 0), 5)
	var ok: bool = _state.consume_item("potion")
	assert_true(ok, "consume should succeed")
	assert_eq(
		_state.get_consumables().get("potion", 0),
		4,
		"quantity decremented",
	)


func test_consume_item_last_one_erases() -> void:
	_state.initialize_new_game()
	_state.add_item("ether", 1)
	var ok: bool = _state.consume_item("ether")
	assert_true(ok, "consume should succeed")
	assert_false(
		_state.get_consumables().has("ether"),
		"item erased at zero",
	)


func test_consume_item_not_owned() -> void:
	_state.initialize_new_game()
	var ok: bool = _state.consume_item("nonexistent_item")
	assert_false(ok, "cannot consume item not in inventory")
