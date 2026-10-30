extends GutTest
## Lira's Arcanite Charges outside one battle (GAP-002, slice 158c of #158):
## the pool a battle starts from, AC spent in battle staying spent, the pool
## surviving a save and load, and rests refilling it.
##
## Design law: abilities.md § Lira — Forgewright ("Max 12 AC. Starts each battle
## at current AC pool"; "Restored when resting at save points via rest items
## (Sleeping Bag 25%, Tent 50%, Pavilion 100%), fully at inns"), crafting.md
## § AC Restoration ("AC is not auto-refilled between battles") and
## save-system.md § 3.5 (crafting.arcanite_charges), with the 2026-10-28
## decision that AC persists in PartyState and the save until a rest.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")

const TEST_SLOT: int = 2
const LIRA := 0


class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)
	var state: Node

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return []

	func get_atb() -> Node:
		return null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	SaveManager.delete_slot(TEST_SLOT)
	PartyState.initialize_new_game()


func after_each() -> void:
	SaveManager.delete_slot(TEST_SLOT)
	PartyState.arcanite_charges = 12
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


## A battle with Lira in slot 0, seated from the party's current state.
func _battle_state() -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	var lira: Dictionary = {
		"character_id": "lira",
		"name": "Lira",
		"base_stats": {"hp": 300, "mp": 20, "atk": 20, "def": 20, "mag": 30, "spd": 20},
	}
	state.add_member(LIRA, lira)
	return state


func _deploy(state: Node, ability_id: String) -> bool:
	var battle: FakeBattle = FakeBattle.new()
	battle.state = state
	add_child_autofree(battle)
	var ability: Dictionary = {}
	for a: Variant in DataManager.load_abilities("lira"):
		if (a as Dictionary).get("id", "") == ability_id:
			ability = a
	return AbilityCommand.new(battle).do_ability(
		"party_%d" % LIRA, {"type": "ability", "ability": ability, "target": LIRA}
	)


func _rest_item(item_id: String) -> float:
	for c: Variant in DataManager.load_items("consumables"):
		if (c as Dictionary).get("id", "") == item_id:
			return float(c.get("restore_percent", 0)) / 100.0
	fail_test("no rest item '%s'" % item_id)
	return 0.0


# --- A new game, and the battle that starts from the pool ---


func test_a_new_game_starts_with_a_full_pool() -> void:
	PartyState.arcanite_charges = 3
	PartyState.initialize_new_game()
	assert_eq(PartyState.arcanite_charges, 12)


func test_a_battle_starts_from_the_current_pool_not_a_full_one() -> void:
	PartyState.arcanite_charges = 7
	assert_eq(int(_battle_state().get_member(LIRA)["ac"]), 7)


func test_ac_spent_in_battle_stays_spent_after_it() -> void:
	var state: Node = _battle_state()
	assert_true(_deploy(state, "mending_engine"), "deployed")
	assert_eq(PartyState.arcanite_charges, 8, "4 AC gone from the pool")
	assert_eq(int(_battle_state().get_member(LIRA)["ac"]), 8, "the next battle starts at 8")


func test_salvage_returns_its_refund_to_the_pool() -> void:
	var state: Node = _battle_state()
	_deploy(state, "mending_engine")
	_deploy(state, "salvage")
	assert_eq(PartyState.arcanite_charges, 10)


# --- Save and load ---


func test_the_pool_is_written_to_the_save() -> void:
	PartyState.arcanite_charges = 5
	assert_eq(int(PartyState.build_save_data()["crafting"]["arcanite_charges"]), 5)


func test_the_pool_survives_a_save_and_a_load() -> void:
	PartyState.arcanite_charges = 5
	assert_true(SaveManager.save_game(TEST_SLOT), "saved")
	PartyState.arcanite_charges = 12
	var loaded: Dictionary = SaveManager.load_game(TEST_SLOT)
	assert_false(loaded.has("error"), "loads cleanly")
	PartyState.load_from_save(loaded)
	assert_eq(PartyState.arcanite_charges, 5)


func test_a_save_from_before_ac_was_spendable_loads_with_a_full_pool() -> void:
	# Every save until now wrote a constant 12, so a missing or malformed field
	# reads as what it always meant.
	var data: Dictionary = PartyState.build_save_data()
	(data["crafting"] as Dictionary).erase("arcanite_charges")
	PartyState.arcanite_charges = 2
	PartyState.load_from_save(data)
	assert_eq(PartyState.arcanite_charges, 12)


func test_a_loaded_pool_is_held_to_zero_through_twelve() -> void:
	var data: Dictionary = PartyState.build_save_data()
	data["crafting"]["arcanite_charges"] = 40
	PartyState.load_from_save(data)
	assert_eq(PartyState.arcanite_charges, 12)
	data["crafting"]["arcanite_charges"] = -3
	PartyState.load_from_save(data)
	assert_eq(PartyState.arcanite_charges, 0)


# --- Rest restores it ---


func test_an_inn_refills_the_pool() -> void:
	PartyState.arcanite_charges = 1
	PartyState.rest_at_inn()
	assert_eq(PartyState.arcanite_charges, 12)


func test_rest_items_restore_their_share_of_the_pool() -> void:
	var expected: Dictionary = {"sleeping_bag": 3, "tent": 6, "pavilion": 12}
	for item_id: String in expected:
		PartyState.arcanite_charges = 0
		PartyState.rest_party(_rest_item(item_id), true)
		assert_eq(PartyState.arcanite_charges, expected[item_id], item_id)


func test_a_rest_never_fills_past_twelve() -> void:
	PartyState.arcanite_charges = 11
	PartyState.rest_party(_rest_item("tent"), true)
	assert_eq(PartyState.arcanite_charges, 12)
