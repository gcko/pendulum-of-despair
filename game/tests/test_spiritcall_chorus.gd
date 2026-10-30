extends "res://tests/spiritcall_test_base.gd"
## Convergence Chorus, Rootsong and the Spiritcall menu (GAP-002, slice 158e of
## #158).
##
## Design law: abilities.md § Torren — Spiritcall, abilities.md § Damage
## Magnitudes > 'Convergence Chorus' (each of Briar, Rain, Flame and Earth at 50% of its one
## quantity, at that spirit's own Favor, party- or enemy-wide; an unlearned
## spirit's component skipped; once per battle), Rootsong (heal at power 12, every
## spirit +1, once per battle), the readings on #158 (the Chorus earns no Favor;
## Rootsong is not a harmony) and ui-design.md § 2.7 (Favor pips, 0-3 filled).

const SubmenuItems = preload("res://scripts/ui/battle_submenu_items.gd")

# --- Convergence Chorus ---


func test_the_chorus_components_are_half_their_spirits() -> void:
	var c: Dictionary = _ability("convergence_chorus")["component_powers"]
	assert_eq(int(c["damage"]) * 2, int(_ability("ember_wing")["power"]), "Flame")
	assert_eq(int(c["heal"]) * 2, int(_ability("dewfall")["power"]), "Rain")
	assert_eq(int(c["barrier_pct"]) * 2, int(_ability("thornveil")["counter_pct"]), "Briar")
	assert_eq(int(c["immunity_turns"]) * 2, int(_ability("stoneheart")["immunity_turns"]), "Earth")


func test_the_chorus_at_favor_zero_lands_all_four_at_half() -> void:
	_enemies([{}, {}])
	_set_hp(EDREN, 300)
	_state.apply_status(EDREN, "poison", "turns", -1)
	assert_true(_call("convergence_chorus"), "issued")
	for idx: int in range(2):
		assert_between(_dealt(idx), 46, 50, "enemy %d at power 5" % idx)
	assert_between(_healed(EDREN), 180, 192, "heal at power 6")
	assert_false(_state.has_status(EDREN, "poison"), "Poison cleansed")
	var counters: Array = _torren_counters(_enemy_hits(_battle.enemies[0], CAEL))
	assert_eq(int(counters[0]["damage"]), 4, "a party barrier at 10% of DEF 40")
	assert_false(_state.apply_status(LIRA, "silence", "turns", 3), "party immunity")
	_turn(LIRA)
	assert_true(_state.apply_status(LIRA, "silence", "turns", 3), "for 1 turn")


func test_the_chorus_barrier_lasts_three_turns() -> void:
	_call("convergence_chorus")
	for i: int in range(2):
		_turn(CAEL)
	assert_eq(_torren_counters(_enemy_hits(_battle.enemies[0], CAEL)).size(), 1, "2 turns in")
	_turn(CAEL)
	assert_eq(_torren_counters(_enemy_hits(_battle.enemies[0], CAEL)).size(), 0, "3 turns in")


func test_the_chorus_cleanses_sleep_only_once_rain_is_at_favor_three() -> void:
	_state.apply_status(EDREN, "sleep", "turns", -1)
	_call("convergence_chorus")
	assert_true(_state.has_status(EDREN, "sleep"), "Favor 0 cleanses Poison only")
	_new_battle(30)
	_set_favor("dewfall", 3)
	_state.apply_status(EDREN, "sleep", "turns", -1)
	_call("convergence_chorus")
	assert_false(_state.has_status(EDREN, "sleep"), "Favor 3 Rain also cleanses Sleep")


func test_the_chorus_takes_each_spirits_own_favor_three_figure() -> void:
	for spirit: String in SPIRITS:
		_set_favor(spirit, 3)
	_set_hp(EDREN, 300)
	_call("convergence_chorus")
	assert_between(_dealt(0), 93, 100, "half of Inferno Gale's 20")
	assert_between(_healed(EDREN), 180, 192, "still power 6")
	var counters: Array = _torren_counters(_enemy_hits(_battle.enemies[0], CAEL))
	assert_eq(int(counters[0]["damage"]), 8, "half of Deeproot Veil's 40%")
	_turn(LIRA)
	assert_true(_state.apply_status(LIRA, "silence", "turns", 3), "immunity still 1 turn")


func test_the_chorus_barrier_carries_no_damage_cut_even_at_favor_three() -> void:
	_set_favor("thornveil", 3)
	var enemy: Node = _make_enemy({"atk": 50, "spd": 255})
	seed(5)
	var bare: Dictionary = BattleActions.execute_enemy_attack(_state, enemy, CAEL)
	_set_hp(CAEL, 1000)
	_call("convergence_chorus")
	_set_hp(CAEL, 1000)
	seed(5)
	var warded: Dictionary = BattleActions.execute_enemy_attack(_state, enemy, CAEL)
	assert_eq(int(warded["damage"]), int(bare["damage"]))


func test_the_chorus_skips_a_spirit_torren_has_not_learned() -> void:
	_new_battle(15)  # Stoneheart is Lv 16+; the Chorus has only its story trigger
	_call("convergence_chorus")
	assert_true(_state.apply_status(EDREN, "poison", "turns", -1), "no Earth component")
	assert_eq(_torren_counters(_enemy_hits(_battle.enemies[0], CAEL)).size(), 1, "Briar still")


func test_the_chorus_earns_no_favor() -> void:
	_enemies([{"weaknesses": ["flame"], "hp": 3}])
	_set_hp(EDREN, 50)
	_call("convergence_chorus")
	_state.apply_status(CAEL, "poison", "turns", -1)
	_enemy_hits(_make_enemy({"hp": 3, "atk": 10}), LIRA)
	for spirit: String in SPIRITS:
		assert_eq(_favor(spirit), 0, spirit)


func test_the_chorus_is_once_per_battle() -> void:
	assert_true(_call("convergence_chorus"), "first")
	var mp: int = int(_state.get_member(TORREN)["current_mp"])
	assert_false(_call("convergence_chorus"), "second refused")
	assert_eq(int(_state.get_member(TORREN)["current_mp"]), mp, "and costs nothing")
	_new_battle(30)
	assert_true(_call("convergence_chorus"), "a new battle allows it again")


func test_a_flight_after_the_chorus_costs_the_spirits_it_called() -> void:
	for spirit: String in SPIRITS:
		_set_favor(spirit, 2)
	_call("convergence_chorus")
	_battle.flee_result.emit(true)
	for spirit: String in ["thornveil", "dewfall", "ember_wing", "stoneheart"]:
		assert_eq(_favor(spirit), 1, spirit)
	assert_eq(_favor("greyveil"), 2, "Twilight is not in the Chorus")


# --- Rootsong ---


func test_rootsong_raises_every_spirit_by_one() -> void:
	_set_favor("greyveil", 2)
	_call("rootsong")
	for spirit: String in SPIRITS:
		assert_eq(_favor(spirit), 3 if spirit == "greyveil" else 1, spirit)


func test_rootsong_never_takes_a_spirit_past_three() -> void:
	_set_favor("thornveil", 3)
	_call("rootsong")
	assert_eq(_favor("thornveil"), 3)


func test_rootsong_heals_every_ally_at_spell_power_twelve() -> void:
	for slot: int in range(4):
		_set_hp(slot, 300)
	_call("rootsong")
	for slot: int in range(4):
		assert_between(_healed(slot), 360, 384, "slot %d" % slot)


func test_rootsong_is_not_itself_a_harmony() -> void:
	_set_hp(EDREN, 50)
	_call("rootsong")
	assert_eq(_favor("dewfall"), 1, "the +1 every spirit gets, and no more")


func test_rootsong_is_once_per_battle() -> void:
	assert_true(_call("rootsong"), "first")
	assert_false(_call("rootsong"), "second refused")
	assert_eq(_favor("thornveil"), 1, "the refused one raised nothing")


# --- The menu ---


func test_each_spirit_is_listed_with_its_favor_pips() -> void:
	_set_favor("dewfall", 2)
	var labels: Array = _labels()
	assert_has(labels, "Thornveil ○○○  5 MP")
	assert_has(labels, "Dewfall ●●○  8 MP")


func test_a_spirit_at_favor_three_is_listed_and_announced_by_its_upgraded_name() -> void:
	_set_favor("thornveil", 3)
	_set_favor("dewfall", 3)
	var items: Array[Dictionary] = _items()
	var labels: Array = _labels()
	assert_has(labels, "Deeproot Veil ●●●  5 MP")
	assert_has(labels, "Torrent's Grace ●●●  8 MP")
	var grace: Dictionary = items[labels.find("Torrent's Grace ●●●  8 MP")]
	assert_eq(grace["target_type"], "all_allies", "it takes no target")
	_call("thornveil", EDREN)
	assert_has(_messages, "Torren uses Deeproot Veil!")


func test_the_chorus_and_rootsong_carry_no_pips() -> void:
	var labels: Array = _labels()
	assert_has(labels, "Convergence Chorus  20 MP")
	assert_has(labels, "Rootsong  14 MP")


func test_every_built_spirit_can_be_chosen_and_the_chorus_greys_out_once_used() -> void:
	for item: Dictionary in _items():
		assert_true(item["enabled"], "%s" % item["label"])
	_call("convergence_chorus")
	var chorus: Dictionary = _items()[_labels().find("Convergence Chorus  20 MP")]
	assert_false(chorus["enabled"], "used this battle")


func test_purify_is_listed_but_cannot_be_chosen() -> void:
	EventFlags.set_flag("pallor_zone_active", true)
	var purify: Array = _items().filter(
		func(i: Dictionary) -> bool: return String(i["label"]).begins_with("Purify")
	)
	assert_eq(purify.size(), 1, "listed in a Pallor zone")
	assert_false(purify[0]["enabled"], "the corruption it answers is not built")


func _items() -> Array[Dictionary]:
	var data: Dictionary = _state.get_member(TORREN)["character_data"]
	return SubmenuItems.abilities(data, _state.get_member(TORREN))


func _labels() -> Array:
	return _items().map(func(i: Dictionary) -> String: return String(i["label"]))
