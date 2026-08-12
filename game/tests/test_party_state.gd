extends GutTest
## Tests for the PartyState facade itself: new-game initialization, member
## lookup, the stat pipeline, save/load round-tripping, and the level tables.
##
## The rules behind the facade live in scripts/util/party_*.gd, and their
## tests live beside them: test_party_roster.gd, test_party_inventory.gd,
## test_party_equipment.gd and test_party_vitals.gd (#374).

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
