extends GutTest
## What the Item command does with a cure in battle (items.md § Status Cures,
## § Battle Utility): a clear-all item leaves the ailments no item can cure,
## and an item that would do nothing is refused and kept, not spent.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Edren in slot 0, Cael in slot 1.
const EDREN := 0
const CAEL := 1

var _booted: Node = null


func before_each() -> void:
	seed(12345)
	GameManager.transition_data = {}


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


## Boot a real battle against one Ley Vermin and give Cael the only turn, so
## his command menu is open.
func _boot_on_cael_s_turn() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	battle.set_process(false)
	_booted = battle
	var atb: Node = battle.get_atb()
	for id: String in ["party_0", "enemy_0"]:
		atb.set_gauge(id, 0)
	atb.set_gauge("party_1", ATBSystem.GAUGE_MAX)
	battle._process(0.0)
	return battle


func _item(item_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_items("consumables"):
		if (entry as Dictionary).get("id", "") == item_id:
			return entry
	fail_test("consumables.json has no %s" % item_id)
	return {}


func _use(battle: Node, item_id: String, target: int) -> void:
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "item", "item": _item(item_id), "target": target}
	)


func _held(item_id: String) -> int:
	return int(PartyState.get_consumables().get(item_id, 0))


func test_starbloom_tea_clears_ailments_but_not_berserk_stop_or_despair() -> void:
	# items.md § Status Cures: "Items cannot cure" Stop or Berserk ("Purge spell
	# only"), and Despair yields only to its own cures (Pallor Salve, Pallor
	# Antidote, Hope Shard) or Hollow Mend.
	var battle: Node = _boot_on_cael_s_turn()
	var state: Node = battle.get_battle_state()
	state.apply_status(EDREN, "poison", "turns", StatusEffects.UNTIL_CURED)
	state.apply_status(EDREN, "berserk", "turns", StatusEffects.UNTIL_CURED)
	state.apply_status(EDREN, "despair", "turns", 4)
	state.apply_status(EDREN, "stop", "realtime", 3.0)
	PartyState.add_item("starbloom_tea", 1)
	_use(battle, "starbloom_tea", EDREN)
	assert_false(state.has_status(EDREN, "poison"), "the tea clears an ordinary ailment")
	assert_true(state.has_status(EDREN, "berserk"), "Berserk: Purge spell only")
	assert_true(state.has_status(EDREN, "stop"), "Stop: wears off only")
	assert_true(state.has_status(EDREN, "despair"), "Despair: only its own cures")


func test_an_antidote_on_a_member_with_nothing_to_cure_is_refused_and_kept() -> void:
	# items.md § Battle Utility: "An item whose effect would be a no-op is
	# refused, not consumed."
	var battle: Node = _boot_on_cael_s_turn()
	var held: int = _held("antidote")
	watch_signals(battle)
	_use(battle, "antidote", EDREN)
	assert_eq(_held("antidote"), held, "the Antidote is not spent")
	assert_signal_emitted(battle, "turn_ready", "Cael's menu reopens: the turn is not spent")
	assert_eq(battle.get_atb().get_gauge("party_1"), ATBSystem.GAUGE_MAX, "gauge still full")


func test_an_antidote_on_a_poisoned_member_is_spent_and_cures() -> void:
	var battle: Node = _boot_on_cael_s_turn()
	var state: Node = battle.get_battle_state()
	state.apply_status(EDREN, "poison", "turns", StatusEffects.UNTIL_CURED)
	var held: int = _held("antidote")
	_use(battle, "antidote", EDREN)
	assert_false(state.has_status(EDREN, "poison"), "cured")
	assert_eq(_held("antidote"), held - 1, "and spent")


func test_an_ether_on_a_member_at_full_mp_is_refused_and_kept() -> void:
	var battle: Node = _boot_on_cael_s_turn()
	var state: Node = battle.get_battle_state()
	var m: Dictionary = state.get_member(CAEL)
	m["current_mp"] = m["max_mp"]
	PartyState.add_item("ether", 1)
	_use(battle, "ether", CAEL)
	assert_eq(_held("ether"), 1, "an Ether at full MP is not spent")


func test_an_ether_on_a_member_short_of_mp_is_spent() -> void:
	var battle: Node = _boot_on_cael_s_turn()
	var state: Node = battle.get_battle_state()
	var m: Dictionary = state.get_member(CAEL)
	m["current_mp"] = 0
	PartyState.add_item("ether", 1)
	_use(battle, "ether", CAEL)
	assert_eq(_held("ether"), 0, "spent")
	assert_gt(int(state.get_member(CAEL)["current_mp"]), 0, "and MP restored")
