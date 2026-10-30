extends "res://tests/spiritcall_test_base.gd"
## Torren's five spirits at Favor 0 and at Favor 3 (GAP-002, slice 158e of
## #158): what each one does to the battle through the Ability command.
## What earns and loses Favor is test_spirit_harmony.gd; the Chorus, Rootsong
## and the menu are test_spiritcall_chorus.gd; Favor in the save is
## test_spirit_favor.gd.
##
## Design law: abilities.md § Torren — Spiritcall (the sub-ability table) and
## § Damage Magnitudes, game/data/abilities/torren.json.

# --- The data is the doc ---


func test_the_ward_durations_match_the_shipped_effect_text() -> void:
	var thornveil: Dictionary = _ability("thornveil")
	assert_true(
		String(thornveil["effect"]).contains("for %d turns" % int(thornveil["turns"])),
		"Thornveil's barrier lasts its turns"
	)
	var stoneheart: Dictionary = _ability("stoneheart")
	assert_true(
		String(stoneheart["effect"]).contains("for %d turns" % int(stoneheart["immunity_turns"])),
		"Stoneheart's immunity lasts its turns"
	)


func test_every_upgraded_name_is_the_one_the_effect_text_gives() -> void:
	for spirit: String in SPIRITS:
		var ability: Dictionary = _ability(spirit)
		var upgrade: String = "Favor 3 Upgrade (%s)" % ability.get("favor3", {}).get("name", "")
		assert_true(String(ability["effect"]).contains(upgrade), "%s: %s" % [spirit, upgrade])


# --- Thornveil / Deeproot Veil ---


func test_thornveil_counters_a_physical_attacker_for_a_fifth_of_the_bearers_defense() -> void:
	assert_true(_call("thornveil", EDREN), "issued")
	var counters: Array = _torren_counters(_enemy_hits(_battle.enemies[0], EDREN))
	assert_eq(counters.size(), 1, "one counter")
	assert_eq(int(counters[0]["damage"]), 8, "20% of DEF 40")
	assert_eq(_battle.enemies[0].current_hp, 30000 - 8, "the attacker took it")


func test_thornveil_shields_only_its_target() -> void:
	_call("thornveil", EDREN)
	assert_eq(_torren_counters(_enemy_hits(_battle.enemies[0], CAEL)).size(), 0)


func test_thornveil_ends_after_three_of_the_bearers_turns() -> void:
	_call("thornveil", EDREN)
	for i: int in range(3):
		_turn(EDREN)
	assert_eq(_torren_counters(_enemy_hits(_battle.enemies[0], EDREN)).size(), 0)


func test_thornveil_at_favor_zero_takes_nothing_off_the_hit() -> void:
	var bare: int = _seeded_hit(EDREN, false)
	_call("thornveil", EDREN)
	assert_eq(_seeded_hit(EDREN, false), bare, "same blow, same damage")


func test_deeproot_veil_counters_for_two_fifths_of_defense() -> void:
	_set_favor("thornveil", 3)
	_call("thornveil", EDREN)
	var counters: Array = _torren_counters(_enemy_hits(_battle.enemies[0], EDREN))
	assert_eq(int(counters[0]["damage"]), 16, "40% of DEF 40")


func test_deeproot_veil_cuts_physical_and_magic_hits_by_fifteen_percent() -> void:
	_set_favor("thornveil", 3)
	var physical: int = _seeded_hit(EDREN, false)
	var magic: int = _seeded_hit(EDREN, true)
	_call("thornveil", EDREN)
	assert_almost_eq(_seeded_hit(EDREN, false), int(physical * 0.85), 1, "physical")
	assert_almost_eq(_seeded_hit(EDREN, true), int(magic * 0.85), 1, "magic")


# --- Dewfall / Torrent's Grace ---


func test_dewfall_heals_one_ally_at_spell_power_twelve_and_cures_poison() -> void:
	_set_hp(EDREN, 300)
	_state.apply_status(EDREN, "poison", "turns", -1)
	_state.apply_status(CAEL, "poison", "turns", -1)
	_set_hp(CAEL, 300)
	assert_true(_call("dewfall", EDREN), "issued")
	assert_between(_healed(EDREN), 360, 384, "40 MAG x 12 x 0.8, less variance")
	assert_false(_state.has_status(EDREN, "poison"), "Poison removed")
	assert_eq(_healed(CAEL), 0, "nobody else healed")
	assert_true(_state.has_status(CAEL, "poison"), "nobody else cured")


func test_dewfall_at_favor_zero_leaves_sleep() -> void:
	_state.apply_status(EDREN, "sleep", "turns", -1)
	_call("dewfall", EDREN)
	assert_true(_state.has_status(EDREN, "sleep"))


func test_torrents_grace_heals_and_cures_every_ally_with_no_target() -> void:
	_set_favor("dewfall", 3)
	for slot: int in [EDREN, CAEL, LIRA]:
		_set_hp(slot, 300)
		_state.apply_status(slot, "poison", "turns", -1)
		_state.apply_status(slot, "sleep", "turns", -1)
	assert_true(_call("dewfall"), "issued without a target")
	for slot: int in [EDREN, CAEL, LIRA]:
		assert_between(_healed(slot), 360, 384, "slot %d at power 12" % slot)
		assert_false(_state.has_status(slot, "poison"), "slot %d Poison" % slot)
		assert_false(_state.has_status(slot, "sleep"), "slot %d Sleep" % slot)


# --- Ember Wing / Inferno Gale ---


func test_ember_wing_burns_every_enemy_at_spell_power_ten() -> void:
	_enemies([{}, {}, {}])
	assert_true(_call("ember_wing"), "issued")
	for idx: int in range(3):
		assert_between(_dealt(idx), 93, 100, "enemy %d at power 10" % idx)


func test_ember_wing_is_flame() -> void:
	_enemies([{"weaknesses": ["flame"]}, {"resistances": ["flame"]}])
	_call("ember_wing")
	assert_gt(_dealt(0), 100, "a Flame weakness takes more")
	assert_lt(_dealt(1), 93, "a Flame resistance takes less")


func test_ember_wing_inflicts_burn_on_roughly_two_in_five() -> void:
	var list: Array = []
	for i: int in range(40):
		list.append({})
	_enemies(list)
	_call("ember_wing")
	var burned: int = (
		_battle.enemies.filter(func(e: Node) -> bool: return e.has_status("burn")).size()
	)
	assert_between(burned, 6, 26, "40%% of 40 is 16; got %d" % burned)


func test_ember_wing_at_favor_zero_seldom_burns_a_warded_enemy() -> void:
	_enemies([{"mdef": 5000}, {"mdef": 5000}, {"mdef": 5000}])
	_call("ember_wing")
	for e: Node in _battle.enemies:
		assert_false(e.has_status("burn"), "the 40% rider scales with MAG / (MAG + MDEF)")


func test_inferno_gale_hits_at_spell_power_twenty_and_always_burns() -> void:
	_set_favor("ember_wing", 3)
	_enemies([{}, {"mdef": 5000}, {}])
	_call("ember_wing")
	assert_between(_dealt(0), 187, 200, "power 20")
	for e: Node in _battle.enemies:
		assert_true(e.has_status("burn"), "Burn is guaranteed, whatever the MDEF")


func test_inferno_gale_does_not_burn_an_enemy_immune_to_it() -> void:
	_set_favor("ember_wing", 3)
	_enemies([{"status_immunities": ["burn"]}])
	_call("ember_wing")
	if not _battle.enemies[0].is_immune_to_status("burn"):
		fail_test("enemy data shape for a Burn immunity has changed")
		return
	assert_false(_battle.enemies[0].has_status("burn"))


# --- Stoneheart / Mountain's Resolve ---


func test_stoneheart_keeps_statuses_off_one_ally_for_two_of_its_turns() -> void:
	assert_true(_call("stoneheart", EDREN), "issued")
	assert_false(_state.apply_status(EDREN, "poison", "turns", -1), "warded")
	assert_true(_state.apply_status(CAEL, "poison", "turns", -1), "only the target")
	_turn(EDREN)
	assert_false(_state.apply_status(EDREN, "silence", "turns", 3), "still warded")
	_turn(EDREN)
	assert_true(_state.apply_status(EDREN, "poison", "turns", -1), "two turns later it lands")


func test_stoneheart_does_not_keep_a_positive_status_off() -> void:
	_call("stoneheart", EDREN)
	assert_true(_state.apply_status(EDREN, "haste", "turns", 3))


func test_a_ward_cast_on_torren_himself_lasts_past_the_casting_turn() -> void:
	_state.begin_turn(TORREN)
	_call("stoneheart", TORREN)
	_state.tick_statuses(TORREN)
	assert_false(_state.apply_status(TORREN, "poison", "turns", -1), "the casting turn is free")


func test_mountains_resolve_wards_every_ally() -> void:
	_set_favor("stoneheart", 3)
	assert_true(_call("stoneheart"), "issued without a target")
	for slot: int in range(4):
		assert_false(_state.apply_status(slot, "poison", "turns", -1), "slot %d" % slot)


func test_a_knocked_out_ally_loses_its_wards() -> void:
	_call("stoneheart", EDREN)
	_call("thornveil", EDREN)
	_state.take_damage(EDREN, 5000)
	_state.heal(EDREN, 500, true)
	assert_true(_state.apply_status(EDREN, "poison", "turns", -1), "immunity gone")
	assert_eq(_torren_counters(_enemy_hits(_battle.enemies[0], EDREN)).size(), 0, "barrier gone")


# --- Greyveil / Duskbreaker ---


func test_greyveil_ignores_magic_defense() -> void:
	_enemies([{"mdef": 200}])
	assert_true(_call("greyveil", 0), "issued")
	assert_between(_dealt(0), 262, 280, "power 28 with MDEF 200 ignored")


func test_greyveil_is_untouched_by_elements() -> void:
	_enemies([{"weaknesses": ["flame", "frost", "storm", "earth", "ley", "spirit", "void"]}])
	_call("greyveil", 0)
	assert_between(_dealt(0), 262, 280, "non-elemental: no weakness applies")


func test_greyveil_at_favor_zero_does_not_double_on_a_pallor() -> void:
	_enemies([{"type": "pallor"}])
	_call("greyveil", 0)
	assert_between(_dealt(0), 262, 280)


func test_duskbreaker_hits_at_spell_power_fifty_six() -> void:
	_set_favor("greyveil", 3)
	_call("greyveil", 0)
	assert_between(_dealt(0), 525, 560)


func test_duskbreaker_deals_double_to_a_pallor() -> void:
	_set_favor("greyveil", 3)
	_enemies([{"type": "pallor"}])
	_call("greyveil", 0)
	assert_between(_dealt(0), 1050, 1120, "56 doubled: an effective 112")


# --- Helpers ---


## The damage one fixed enemy blow deals [param slot], with the RNG reset so
## repeated calls roll the same blow: a physical attack, or a power-20 spell
## when [param magic].
func _seeded_hit(slot: int, magic: bool) -> int:
	var enemy: Node = _make_enemy({"atk": 50, "mag": 60, "spd": 255})
	var before: int = int(_state.get_member(slot)["current_hp"])
	seed(99)
	if magic:
		BattleActions.execute_enemy_magic(_state, enemy, slot, "", 20)
	else:
		BattleActions.execute_enemy_attack(_state, enemy, slot)
	var taken: int = before - int(_state.get_member(slot)["current_hp"])
	_state.get_member(slot)["current_hp"] = before
	return taken
