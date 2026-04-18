extends GutTest
## Tests for party member runtime state in battle.

var _state: Node


func before_each() -> void:
	_state = preload("res://scripts/combat/battle_state.gd").new()
	add_child_autofree(_state)
	DataManager.clear_cache()
	PartyState.ley_crystals.clear()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()


func after_each() -> void:
	_state = null
	DataManager.clear_cache()
	PartyState.ley_crystals.clear()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()


func _make_char_data() -> Dictionary:
	return {
		"id": "edren",
		"name": "Edren",
		"base_stats":
		{"hp": 95, "mp": 15, "atk": 18, "def": 16, "mag": 6, "mdef": 8, "spd": 10, "lck": 8},
	}


# --- Initialization ---


func test_add_party_member() -> void:
	_state.add_member(0, _make_char_data())
	var member: Dictionary = _state.get_member(0)
	assert_eq(member["character_id"], "edren")
	assert_eq(member["current_hp"], 95)
	assert_eq(member["max_hp"], 95)
	assert_eq(member["is_alive"], true)


func test_empty_slot_returns_empty() -> void:
	var member: Dictionary = _state.get_member(3)
	assert_true(member.is_empty(), "empty slot returns empty dict")


func test_active_count() -> void:
	assert_eq(_state.get_active_count(), 0)
	_state.add_member(0, _make_char_data())
	assert_eq(_state.get_active_count(), 1)
	_state.add_member(2, _make_char_data())
	assert_eq(_state.get_active_count(), 2)


# --- HP/MP ---


func test_take_damage_reduces_hp() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 30)
	assert_eq(_state.get_member(0)["current_hp"], 65)


func test_take_damage_kills_at_zero() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 200)
	assert_eq(_state.get_member(0)["current_hp"], 0)
	assert_false(_state.get_member(0)["is_alive"])


func test_take_damage_emits_signal() -> void:
	_state.add_member(0, _make_char_data())
	watch_signals(_state)
	_state.take_damage(0, 30)
	assert_signal_emitted(_state, "member_damaged")


func test_take_damage_emits_died() -> void:
	_state.add_member(0, _make_char_data())
	watch_signals(_state)
	_state.take_damage(0, 200)
	assert_signal_emitted(_state, "member_died")


func test_heal_restores_hp() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 50)
	_state.heal(0, 30)
	assert_eq(_state.get_member(0)["current_hp"], 75)


func test_heal_clamps_to_max() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 10)
	_state.heal(0, 100)
	assert_eq(_state.get_member(0)["current_hp"], 95)


func test_heal_does_not_revive_dead_member() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 200)
	assert_false(_state.get_member(0)["is_alive"])
	var actual: int = _state.heal(0, 50)
	assert_eq(actual, 0, "regular heal should not affect KO'd member")
	assert_false(_state.get_member(0)["is_alive"])


func test_heal_with_revive_flag_revives_dead_member() -> void:
	_state.add_member(0, _make_char_data())
	_state.take_damage(0, 200)
	assert_false(_state.get_member(0)["is_alive"])
	var actual: int = _state.heal(0, 50, true)
	assert_true(actual > 0, "revive heal should restore HP")
	assert_true(_state.get_member(0)["is_alive"])


func test_spend_mp() -> void:
	_state.add_member(0, _make_char_data())
	var ok: bool = _state.spend_mp(0, 10)
	assert_true(ok)
	assert_eq(_state.get_member(0)["current_mp"], 5)


func test_spend_mp_insufficient() -> void:
	_state.add_member(0, _make_char_data())
	var ok: bool = _state.spend_mp(0, 100)
	assert_false(ok, "cannot spend more MP than available")
	assert_eq(_state.get_member(0)["current_mp"], 15, "MP unchanged on failure")


func test_restore_mp() -> void:
	_state.add_member(0, _make_char_data())
	_state.spend_mp(0, 10)
	_state.restore_mp(0, 5)
	assert_eq(_state.get_member(0)["current_mp"], 10)


func test_restore_mp_clamps_to_max() -> void:
	_state.add_member(0, _make_char_data())
	_state.restore_mp(0, 100)
	assert_eq(_state.get_member(0)["current_mp"], 15)


# --- Status Effects ---


func test_apply_turn_based_status() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "haste", "turns", 5.0)
	assert_true(_state.has_status(0, "haste"))


func test_tick_decrements_turn_status() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "haste", "turns", 1.0)
	_state.tick_statuses(0)
	assert_false(_state.has_status(0, "haste"), "expired after 1 tick")


func test_tick_preserves_multi_turn_status() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "haste", "turns", 3.0)
	_state.tick_statuses(0)
	assert_true(_state.has_status(0, "haste"), "still active after 1 of 3 ticks")


func test_realtime_status_decrements_by_delta() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "stop", "realtime", 3.0)
	_state.tick_realtime_statuses(0, 1.0)
	assert_true(_state.has_status(0, "stop"), "still active after 1s")
	_state.tick_realtime_statuses(0, 2.1)
	assert_false(_state.has_status(0, "stop"), "expired after 3.1s total")


func test_remove_status() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "poison", "turns", 5.0)
	_state.remove_status(0, "poison")
	assert_false(_state.has_status(0, "poison"))


func test_apply_replaces_existing() -> void:
	_state.add_member(0, _make_char_data())
	_state.apply_status(0, "haste", "turns", 2.0)
	_state.apply_status(0, "haste", "turns", 5.0)
	# Should have only one instance with 5 turns
	_state.tick_statuses(0)
	_state.tick_statuses(0)
	assert_true(_state.has_status(0, "haste"), "refreshed duration active")


func test_status_signals() -> void:
	_state.add_member(0, _make_char_data())
	watch_signals(_state)
	_state.apply_status(0, "slow", "turns", 1.0)
	assert_signal_emitted(_state, "status_applied")
	_state.tick_statuses(0)
	assert_signal_emitted(_state, "status_removed")


# --- Buffs ---


func test_buff_multiplier_default() -> void:
	_state.add_member(0, _make_char_data())
	var eff: int = _state.get_effective_stat(0, "atk")
	assert_eq(eff, 18, "default 1.0x multiplier")


func test_buff_increases_stat() -> void:
	_state.add_member(0, _make_char_data())
	_state.set_buff(0, "atk_mult", 1.3)
	var eff: int = _state.get_effective_stat(0, "atk")
	# 18 * 1.3 = 23.4 → 23
	assert_eq(eff, 23, "buff increases effective stat")


func test_buff_can_exceed_255() -> void:
	var data: Dictionary = _make_char_data()
	data["base_stats"]["mag"] = 240
	_state.add_member(0, data)
	_state.set_buff(0, "mag_mult", 1.3)
	var eff: int = _state.get_effective_stat(0, "mag")
	assert_eq(eff, 312, "buffs exceed 255 in battle")


# --- Row ---


func test_default_row_front() -> void:
	_state.add_member(0, _make_char_data())
	assert_eq(_state.get_member(0)["row"], "front")


func test_swap_row() -> void:
	_state.add_member(0, _make_char_data())
	_state.swap_row(0)
	assert_eq(_state.get_member(0)["row"], "back")
	_state.swap_row(0)
	assert_eq(_state.get_member(0)["row"], "front")


# --- Defend ---


func test_defend_sets_flag() -> void:
	_state.add_member(0, _make_char_data())
	_state.set_defending(0, true)
	assert_true(_state.get_member(0)["is_defending"])


func test_defend_clears_flag() -> void:
	_state.add_member(0, _make_char_data())
	_state.set_defending(0, true)
	_state.set_defending(0, false)
	assert_false(_state.get_member(0)["is_defending"])


# --- All Dead ---


func test_all_dead_detection() -> void:
	_state.add_member(0, _make_char_data())
	_state.add_member(1, _make_char_data())
	assert_false(_state.is_party_wiped())
	_state.take_damage(0, 999)
	assert_false(_state.is_party_wiped(), "one alive")
	_state.take_damage(1, 999)
	assert_true(_state.is_party_wiped(), "all dead")


func test_empty_party_is_wiped() -> void:
	assert_true(_state.is_party_wiped(), "empty party counts as wiped")


# --- Avg Party SPD ---


func test_avg_party_spd() -> void:
	assert_eq(_state.get_avg_party_spd(), 0.0, "empty party returns 0")
	_state.add_member(0, _make_char_data())
	_state.add_member(1, _make_char_data())
	assert_eq(_state.get_avg_party_spd(), 10.0, "avg of two SPD 10")
	_state.take_damage(1, 999)
	assert_eq(_state.get_avg_party_spd(), 10.0, "dead excluded")


# --- Weave Gauge ---


func _make_maren_data() -> Dictionary:
	return {
		"id": "maren",
		"name": "Maren",
		"base_stats":
		{"hp": 50, "mp": 55, "atk": 6, "def": 6, "mag": 22, "mdef": 18, "spd": 8, "lck": 5},
	}


func test_weave_gauge_only_maren() -> void:
	_state.add_member(0, _make_maren_data())
	_state.gain_weave_gauge(0, 10)
	assert_eq(_state.get_member(0).get("wg", 0), 10)


func test_weave_gauge_non_maren_noop() -> void:
	_state.add_member(0, _make_char_data())  # edren
	_state.gain_weave_gauge(0, 10)
	assert_eq(_state.get_member(0).get("wg", 0), 0, "non-maren unaffected")


func test_weave_gauge_caps_at_100() -> void:
	_state.add_member(0, _make_maren_data())
	_state.gain_weave_gauge(0, 90)
	_state.gain_weave_gauge(0, 20)
	assert_eq(_state.get_member(0).get("wg", 0), 100, "capped at 100")


func test_weave_gauge_for_maren_iterates() -> void:
	_state.add_member(0, _make_char_data())  # edren
	_state.add_member(1, _make_maren_data())  # maren
	_state.gain_weave_gauge_for_maren(15)
	assert_eq(_state.get_member(0).get("wg", 0), 0, "edren unaffected")
	assert_eq(_state.get_member(1).get("wg", 0), 15, "maren gains WG")


# --- Equipment Bonuses in Battle ---


func test_effective_stat_includes_equipment_bonus() -> void:
	# Set up PartyState with edren + weapon that gives ATK
	PartyState.initialize_new_game()
	var char_data: Dictionary = PartyState.get_member("edren")
	var base_atk: int = char_data.get("base_stats", {}).get("atk", 0)
	var equip_bonus: int = PartyState.get_equipment_bonus("edren", "atk")
	_state.add_member(0, char_data)
	var battle_atk: int = _state.get_effective_stat(0, "atk")
	assert_eq(battle_atk, base_atk + equip_bonus, "battle ATK should equal base + equipment bonus")


func test_effective_stat_includes_crystal_bonus() -> void:
	PartyState.initialize_new_game()
	PartyState.add_ley_crystal("ember_shard")
	PartyState.equip_crystal("edren", "ember_shard")
	var char_data: Dictionary = PartyState.get_member("edren")
	var base_atk: int = char_data.get("base_stats", {}).get("atk", 0)
	var equip_bonus: int = PartyState.get_equipment_bonus("edren", "atk")
	assert_gt(equip_bonus, 0, "ember_shard should add ATK bonus")
	_state.add_member(0, char_data)
	var battle_atk: int = _state.get_effective_stat(0, "atk")
	assert_eq(battle_atk, base_atk + equip_bonus, "battle ATK should include crystal bonus")


func test_effective_stat_without_party_state_member() -> void:
	# When character is not in PartyState (standalone test data), equipment bonus = 0
	_state.add_member(0, _make_char_data())
	var eff: int = _state.get_effective_stat(0, "atk")
	assert_eq(eff, 18, "no PartyState member = base stats only")


func test_effective_stat_stores_in_effective_stats_dict() -> void:
	PartyState.initialize_new_game()
	PartyState.add_ley_crystal("ember_shard")
	PartyState.equip_crystal("edren", "ember_shard")
	var char_data: Dictionary = PartyState.get_member("edren")
	_state.add_member(0, char_data)
	var m: Dictionary = _state.get_member(0)
	assert_true(m.has("effective_stats"), "member should have effective_stats dict")
	var eff_atk: int = m["effective_stats"].get("atk", 0)
	var base_atk: int = char_data.get("base_stats", {}).get("atk", 0)
	assert_gt(eff_atk, base_atk, "effective_stats ATK should exceed base_stats ATK")


# --- Defend Buff Cycle ---


func test_defend_buff_cycle() -> void:
	_state.add_member(0, _make_char_data())
	_state.set_buff(0, "damage_taken_mult", 0.5)
	assert_eq(_state.get_member(0).get("damage_taken_mult", 1.0), 0.5, "set to 0.5")
	_state.set_buff(0, "damage_taken_mult", 1.0)
	assert_eq(_state.get_member(0).get("damage_taken_mult", 1.0), 1.0, "cleared to 1.0")
