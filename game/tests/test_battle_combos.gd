extends GutTest
## Which dual-tech combos the party can call right now (#176 slice a).
##
## abilities.md § 2 Combo Abilities: a combo needs its two characters in the
## party with full ATB gauges, and the Combo menu lists the combos open to
## whoever is ready. The story gates are the combos.json `availability` text,
## read as recorded on #176: "after X learns Y" opens when X knows Y; Shield
## Oath and Promise of Dawn close once cael_betrayal_complete is set, and
## Cael's Echo opens only with that flag set and Edren knowing Oathkeeper.
## Short MP does not hide a combo: the result carries `affordable` so the menu
## can gray it, as it does a spell.

const BattleCombos = preload("res://scripts/combat/battle_combos.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

const BETRAYAL: String = "cael_betrayal_complete"
## The story events that teach the story-gated abilities the combos name:
## Misdirect, Stoneheart and Greyveil, and Oathkeeper.
const LEARNING_EVENTS: Array[String] = [
	"interlude_sable_journey", "interlude_ley_line_nexus", "act_iv_caels_sword"
]
const MAX_LEVEL: int = 99


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


# ── helpers ─────────────────────────────────────────────────────────────


## A battle with these characters seated in slots 0.. in order, every gauge full.
## Returns [state, atb].
func _battle(character_ids: Array, level: int = 1, mp: int = 99) -> Array:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	var atb: Node = ATBSystem.new()
	add_child_autofree(atb)
	for slot: int in range(character_ids.size()):
		(
			state
			. add_member(
				slot,
				{
					"character_id": character_ids[slot],
					"level": level,
					"base_stats": {"hp": 100, "mp": mp, "spd": 10},
				}
			)
		)
		atb.add_combatant("party_%d" % slot, 10, false)
		atb.set_gauge("party_%d" % slot, ATBSystem.GAUGE_MAX)
	return [state, atb]


func _ids(battle: Array) -> Array:
	return BattleCombos.available_combos(battle[0], battle[1]).map(
		func(r: Dictionary) -> String: return r["id"]
	)


func _result(battle: Array, combo_id: String) -> Dictionary:
	for r: Dictionary in BattleCombos.available_combos(battle[0], battle[1]):
		if r["id"] == combo_id:
			return r
	return {}


func _learn_everything() -> void:
	for flag: String in LEARNING_EVENTS:
		EventFlags.set_flag(flag, true)


## Which combos are open when each one's own two characters are the party.
func _open_combos(level: int) -> Array:
	var open: Array = []
	for raw: Variant in DataManager.load_combos():
		var combo: Dictionary = raw
		if _ids(_battle(combo["characters"], level)).has(combo["id"]):
			open.append(combo["id"])
	open.sort()
	return open


# ── readiness ───────────────────────────────────────────────────────────


func test_a_combo_is_offered_when_both_its_characters_are_ready() -> void:
	var battle: Array = _battle(["maren", "torren"])
	assert_has(_ids(battle), "ley_torrent", "Maren and Torren are both ready")
	assert_eq(_result(battle, "ley_torrent").get("slots", []), [0, 1], "it names who performs it")


func test_a_combo_waits_for_both_gauges_to_fill() -> void:
	for waiting: int in range(2):
		var battle: Array = _battle(["maren", "torren"])
		battle[1].set_gauge("party_%d" % waiting, ATBSystem.GAUGE_MAX - 1)
		assert_does_not_have(
			_ids(battle), "ley_torrent", "slot %d is one tick short of ready" % waiting
		)


func test_a_combo_needs_both_characters_in_the_party() -> void:
	assert_does_not_have(_ids(_battle(["maren", "lira"])), "ley_torrent", "Torren is not here")


func test_a_fallen_partner_takes_the_combo_off_the_list() -> void:
	var battle: Array = _battle(["maren", "torren"])
	battle[0].take_damage(1, 99999)
	assert_does_not_have(_ids(battle), "ley_torrent", "Torren is down")


func test_a_partner_who_cannot_act_takes_the_combo_off_the_list() -> void:
	for status: String in ["sleep", "paralysis", "petrify"]:
		var battle: Array = _battle(["maren", "torren"])
		battle[0].apply_status(1, status, "turns", 3)
		assert_does_not_have(_ids(battle), "ley_torrent", "Torren has %s" % status)


func test_a_status_that_leaves_a_partner_acting_keeps_the_combo() -> void:
	var battle: Array = _battle(["maren", "torren"])
	battle[0].apply_status(1, "poison", "turns", 3)
	assert_has(_ids(battle), "ley_torrent", "Poison does not stop Torren acting")


# ── MP ──────────────────────────────────────────────────────────────────


func test_short_mp_grays_a_combo_rather_than_hiding_it() -> void:
	# Ley Torrent costs Maren 10 MP and Torren 8 (abilities.md § Combo List).
	var both_short: Array = _battle(["maren", "torren"], 1, 0)
	assert_has(_ids(both_short), "ley_torrent", "short MP still lists it")
	assert_false(_result(both_short, "ley_torrent")["affordable"], "neither can pay")


func test_a_combo_is_affordable_only_when_each_character_can_pay_their_share() -> void:
	var exact: Array = _battle(["maren", "torren"], 1, 10)
	exact[0].spend_mp(1, 2)  # Torren down to exactly his 8
	assert_true(_result(exact, "ley_torrent")["affordable"], "10 and 8 pay 10 and 8")
	var maren_short: Array = _battle(["maren", "torren"], 1, 9)
	assert_false(_result(maren_short, "ley_torrent")["affordable"], "Maren has 9 of her 10")
	var torren_short: Array = _battle(["maren", "torren"], 1, 10)
	torren_short[0].spend_mp(1, 3)  # Torren on 7 of his 8
	assert_false(_result(torren_short, "ley_torrent")["affordable"], "Torren has 7 of his 8")


# ── story gates ─────────────────────────────────────────────────────────


func test_at_the_start_only_the_ungated_combos_are_open() -> void:
	assert_eq(
		_open_combos(1),
		["arcane_convergence", "ley_torrent", "promise_of_dawn", "shield_oath", "weave_theft"],
		"every 'after X learns Y' combo waits for Y, and Cael's Echo for Act IV"
	)


func test_before_the_betrayal_every_combo_but_caels_echo_can_open() -> void:
	_learn_everything()
	var expected: Array = DataManager.load_combos().map(
		func(c: Dictionary) -> String: return c["id"]
	)
	expected.erase("caels_echo")
	expected.sort()
	assert_eq(_open_combos(MAX_LEVEL), expected, "Cael's Echo needs the betrayal")


func test_the_betrayal_trades_shield_oath_and_promise_of_dawn_for_caels_echo() -> void:
	_learn_everything()
	EventFlags.set_flag(BETRAYAL, true)
	var open: Array = _open_combos(MAX_LEVEL)
	assert_does_not_have(open, "shield_oath", "lost after Cael's betrayal")
	assert_does_not_have(open, "promise_of_dawn", "lost after Cael's betrayal")
	assert_has(open, "caels_echo", "born from the betrayal")
	assert_eq(open.size(), 10, "the other nine are untouched")


func test_caels_echo_needs_edren_to_know_oathkeeper() -> void:
	EventFlags.set_flag(BETRAYAL, true)
	assert_does_not_have(
		_ids(_battle(["edren", "lira"], MAX_LEVEL)), "caels_echo", "no Oathkeeper yet"
	)
	EventFlags.set_flag("act_iv_caels_sword", true)
	assert_has(_ids(_battle(["edren", "lira"], MAX_LEVEL)), "caels_echo", "Oathkeeper learned")


func test_a_level_learned_gate_opens_at_that_level() -> void:
	# Forged Rampart: "After Lira learns Bulkhead (Level 7)".
	assert_does_not_have(_ids(_battle(["edren", "lira"], 6)), "forged_rampart", "Lira at 6")
	assert_has(_ids(_battle(["edren", "lira"], 7)), "forged_rampart", "Lira at 7")


func test_ambush_protocol_needs_both_of_its_abilities() -> void:
	# "After Sable learns Misdirect (Interlude) and Lira learns Arc Trap (Level 12)".
	assert_does_not_have(_ids(_battle(["sable", "lira"], 12)), "ambush_protocol", "no Misdirect")
	_learn_everything()
	assert_does_not_have(_ids(_battle(["sable", "lira"], 11)), "ambush_protocol", "no Arc Trap")
	assert_has(_ids(_battle(["sable", "lira"], 12)), "ambush_protocol", "both learned")


func test_an_ability_gate_reads_its_own_characters_abilities() -> void:
	# Thornfire waits on Torren's Ember Wing (Level 11): a level-11 Lira is no help.
	var battle: Array = _battle(["torren", "lira"], 10)
	battle[0].get_member(1)["character_data"]["level"] = 11
	assert_does_not_have(_ids(battle), "thornfire", "Torren is still 10")
	battle[0].get_member(0)["character_data"]["level"] = 11
	assert_has(_ids(battle), "thornfire", "Torren reaches 11")


# ── data ────────────────────────────────────────────────────────────────


func test_every_ability_gate_names_an_ability_its_character_has() -> void:
	# A misspelled id would close its combo forever with nothing failing.
	var checked: int = 0
	for raw: Variant in DataManager.load_combos():
		var combo: Dictionary = raw
		for gate: Dictionary in combo["story_gate"]["requires_abilities"]:
			var cid: String = gate["character"]
			assert_has(combo["characters"], cid, "%s gates on its own character" % combo["id"])
			var ids: Array = DataManager.load_abilities(cid).map(
				func(a: Dictionary) -> String: return a["id"]
			)
			assert_has(ids, gate["ability"], "%s: %s has %s" % [combo["id"], cid, gate["ability"]])
			checked += 1
	assert_eq(checked, 8, "eight 'after X learns Y' clauses across the twelve combos")
