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
	assert_eq(equip.get("weapon", ""), "training_sword")


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
	# Training sword has atk 4
	var bonus: int = _state.get_equipment_bonus("edren", "atk")
	assert_eq(bonus, 4, "training_sword ATK = 4")


# --- Equipment ---


func test_unequip_slot() -> void:
	_state.initialize_new_game()
	var old: String = _state.unequip_slot("edren", "weapon")
	assert_eq(old, "training_sword")
	var edren: Dictionary = _state.get_member("edren")
	assert_eq(edren.get("equipment", {}).get("weapon", ""), "")


func test_unequip_returns_to_owned() -> void:
	_state.initialize_new_game()
	_state.unequip_slot("edren", "weapon")
	assert_eq(_state.owned_equipment.size(), 1)
	assert_eq(_state.owned_equipment[0].get("equipment_id", ""), "training_sword")


func test_equip_item() -> void:
	_state.initialize_new_game()
	# Unequip first so training_sword goes to inventory
	_state.unequip_slot("edren", "weapon")
	# Re-equip
	var result: Dictionary = _state.equip_item("edren", "weapon", "training_sword")
	assert_eq(result.get("old_equipment_id", ""), "")  # Was empty
	var edren: Dictionary = _state.get_member("edren")
	assert_eq(edren.get("equipment", {}).get("weapon", ""), "training_sword")


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
