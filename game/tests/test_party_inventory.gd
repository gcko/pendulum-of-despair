extends GutTest
## Tests for the inventory half of PartyState
## (scripts/util/party_inventory.gd): consumables, gold, item use, and the
## single-use guarantee behind Sable's Coin.
##
## Split out of test_party_state.gd (#374).

var _state: Node


func before_each() -> void:
	_state = preload("res://scripts/autoload/party_state.gd").new()
	add_child_autofree(_state)


func after_each() -> void:
	_state = null


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


func test_use_sables_coin_sets_flag_and_consumes() -> void:
	_state.initialize_new_game()
	_state.add_item("sables_coin", 2)
	var ok: bool = _state.use_item("sables_coin", "edren")
	assert_true(ok, "coin use should succeed")
	assert_true(bool(EventFlags.get_flag("sables_coin_active")), "coin flag set")
	assert_eq(_state.get_consumables().get("sables_coin", 0), 1, "one coin consumed")


func test_use_sables_coin_while_active_is_blocked() -> void:
	# A guarantee cannot be improved: re-use is refused, not silently burned
	_state.initialize_new_game()
	_state.add_item("sables_coin", 2)
	_state.use_item("sables_coin", "edren")
	var ok: bool = _state.use_item("sables_coin", "edren")
	assert_false(ok, "second coin should be refused while one is active")
	assert_eq(_state.get_consumables().get("sables_coin", 0), 1, "second coin not consumed")
	assert_true(bool(EventFlags.get_flag("sables_coin_active")), "flag stays set")
