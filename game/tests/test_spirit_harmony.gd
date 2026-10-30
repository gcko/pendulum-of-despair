extends "res://tests/spiritcall_test_base.gd"
## What earns and loses Spirit Favor in battle (GAP-002, slice 158e of #158):
## each harmony trigger raising its spirit by exactly 1, the cap at 3, and a
## fled battle costing each spirit used in it 1. The Chorus and Rootsong are
## test_spiritcall_chorus.gd.
##
## Design law: abilities.md § Torren — Spiritcall > 'Resource: Spirit Favor', as
## read on #158: a weakness is matched when at least one living target hit is
## weak to the element, and Greyveil is in harmony on a Pallor; protecting an
## ally from death is Thornveil's counter felling its attacker or Stoneheart
## keeping a status off; a heal is in harmony on an ally below 25% HP; on a
## flight each spirit used loses 1, once.

# --- Matching a weakness ---


func test_ember_wing_on_an_enemy_weak_to_flame_raises_its_favor_by_one() -> void:
	_enemies([{"weaknesses": ["flame"]}, {}])
	_call("ember_wing")
	assert_eq(_favor("ember_wing"), 1)
	assert_eq(_favor("dewfall"), 0, "no other spirit moves")


func test_ember_wing_with_no_flame_weakness_in_reach_earns_nothing() -> void:
	_enemies([{}, {"weaknesses": ["frost"]}])
	_call("ember_wing")
	assert_eq(_favor("ember_wing"), 0)


func test_one_cast_on_several_weak_enemies_earns_one_favor() -> void:
	_enemies([{"weaknesses": ["flame"]}, {"weaknesses": ["flame"]}, {"weaknesses": ["flame"]}])
	_call("ember_wing")
	assert_eq(_favor("ember_wing"), 1)


func test_a_weak_enemy_already_down_is_not_a_match() -> void:
	_enemies([{"weaknesses": ["flame"]}, {}])
	_battle.enemies[0].is_alive = false
	_call("ember_wing")
	assert_eq(_favor("ember_wing"), 0)


func test_greyveil_on_a_pallor_enemy_raises_its_favor_by_one() -> void:
	_enemies([{"type": "pallor"}])
	_call("greyveil", 0)
	assert_eq(_favor("greyveil"), 1)


func test_greyveil_on_anything_else_earns_nothing() -> void:
	_enemies([{"type": "undead", "weaknesses": ["spirit"]}])
	_call("greyveil", 0)
	assert_eq(_favor("greyveil"), 0)


# --- Protecting an ally from death ---


func test_a_thornveil_counter_that_fells_its_attacker_raises_favor_by_one() -> void:
	_call("thornveil", EDREN)
	var attacker: Node = _make_enemy({"hp": 5, "atk": 10})
	_enemy_hits(attacker, EDREN)
	assert_false(attacker.is_alive, "the 8-point counter felled it")
	assert_eq(_favor("thornveil"), 1)


func test_a_thornveil_counter_that_does_not_fell_earns_nothing() -> void:
	_call("thornveil", EDREN)
	_enemy_hits(_battle.enemies[0], EDREN)
	assert_eq(_favor("thornveil"), 0)


func test_one_barrier_felling_two_attackers_earns_one_favor() -> void:
	_call("thornveil", EDREN)
	_enemy_hits(_make_enemy({"hp": 5, "atk": 10}), EDREN)
	_enemy_hits(_make_enemy({"hp": 5, "atk": 10}), EDREN)
	assert_eq(_favor("thornveil"), 1, "one use, one point")
	_call("thornveil", EDREN)
	_enemy_hits(_make_enemy({"hp": 5, "atk": 10}), EDREN)
	assert_eq(_favor("thornveil"), 2, "the next use earns its own")


func test_stoneheart_keeping_a_status_off_raises_its_favor_by_one() -> void:
	_call("stoneheart", EDREN)
	_state.apply_status(EDREN, "poison", "turns", -1)
	assert_eq(_favor("stoneheart"), 1)


func test_stoneheart_that_blocks_nothing_earns_nothing() -> void:
	_call("stoneheart", EDREN)
	_state.apply_status(CAEL, "poison", "turns", -1)
	_state.apply_status(EDREN, "haste", "turns", 3)
	assert_eq(_favor("stoneheart"), 0)


func test_mountains_resolve_blocking_on_two_allies_earns_one_favor() -> void:
	_set_favor("stoneheart", 2)
	_call("stoneheart", EDREN)
	_state.apply_status(EDREN, "poison", "turns", -1)
	assert_eq(_favor("stoneheart"), 3, "Stoneheart reaches 3")
	_call("stoneheart")
	_state.apply_status(EDREN, "poison", "turns", -1)
	_state.apply_status(CAEL, "silence", "turns", 3)
	assert_eq(_favor("stoneheart"), 3, "and stays there")


# --- Healing someone below 25% HP ---


func test_dewfall_on_an_ally_below_a_quarter_raises_its_favor_by_one() -> void:
	_set_hp(EDREN, 249)
	_call("dewfall", EDREN)
	assert_eq(_favor("dewfall"), 1)


func test_dewfall_on_an_ally_at_a_quarter_or_more_earns_nothing() -> void:
	_set_hp(EDREN, 250)
	_call("dewfall", EDREN)
	assert_eq(_favor("dewfall"), 0)


func test_dewfall_reaching_three_stays_there_as_torrents_grace() -> void:
	_set_favor("dewfall", 2)
	_set_hp(EDREN, 100)
	_call("dewfall", EDREN)
	assert_eq(_favor("dewfall"), 3, "Dewfall reaches 3")
	_set_hp(EDREN, 100)
	_call("dewfall")
	assert_eq(_favor("dewfall"), 3, "Torrent's Grace keeps it at the cap")


# --- The cap ---


func test_favor_never_passes_three() -> void:
	_set_favor("ember_wing", 3)
	_enemies([{"weaknesses": ["flame"]}])
	_call("ember_wing")
	assert_eq(_favor("ember_wing"), 3)


func test_favor_earned_carries_into_the_next_battle() -> void:
	_enemies([{"weaknesses": ["flame"]}])
	_call("ember_wing")
	_new_battle(30)
	_enemies([{"weaknesses": ["flame"]}])
	_call("ember_wing")
	assert_eq(_favor("ember_wing"), 2)


# --- Fleeing ---


func test_a_flight_costs_each_spirit_used_one_favor_once() -> void:
	for spirit: String in SPIRITS:
		_set_favor(spirit, 2)
	_call("thornveil", EDREN)
	_call("thornveil", CAEL)
	_call("ember_wing")
	_battle.flee_result.emit(true)
	assert_eq(_favor("thornveil"), 1, "used twice, still -1")
	assert_eq(_favor("ember_wing"), 1)
	assert_eq(_favor("dewfall"), 2, "not summoned, untouched")
	assert_eq(_favor("stoneheart"), 2)
	assert_eq(_favor("greyveil"), 2)


func test_a_failed_flight_costs_nothing() -> void:
	_set_favor("thornveil", 2)
	_call("thornveil", EDREN)
	_battle.flee_result.emit(false)
	assert_eq(_favor("thornveil"), 2)


func test_a_flight_never_takes_favor_below_zero() -> void:
	_call("dewfall", EDREN)
	_battle.flee_result.emit(true)
	assert_eq(_favor("dewfall"), 0)


func test_a_flight_with_no_spirit_called_costs_nothing() -> void:
	_set_favor("thornveil", 2)
	_call("rootsong")
	_set_favor("thornveil", 2)
	_battle.flee_result.emit(true)
	assert_eq(_favor("thornveil"), 2, "Rootsong sings to the spirits; it calls none")


func test_a_flight_from_the_next_battle_forgets_the_last_ones_spirits() -> void:
	_set_favor("thornveil", 2)
	_call("thornveil", EDREN)
	_new_battle(30)
	_set_favor("dewfall", 2)
	_call("dewfall", EDREN)
	_battle.flee_result.emit(true)
	assert_eq(_favor("thornveil"), 2, "called in another battle")
	assert_eq(_favor("dewfall"), 1)
