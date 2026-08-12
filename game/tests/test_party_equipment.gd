extends GutTest
## Tests for the equipment half of PartyState
## (scripts/util/party_equipment.gd): equipping and unequipping slots, the
## stat bonus equipment contributes, and owned-instance identity.
##
## Split out of test_party_state.gd (#374).

var _state: Node


func before_each() -> void:
	_state = preload("res://scripts/autoload/party_state.gd").new()
	add_child_autofree(_state)


func after_each() -> void:
	_state = null


# --- Equipment Stat Bonus ---


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
