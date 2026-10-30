extends GutTest
## Which dual-tech combos the party can call right now (#176 slice a).
##
## abilities.md § Combo Availability, the rulings recorded on #176:
## - Both characters seated, alive, on full ATB gauges, and able to be
##   commanded: no status that stops them acting, no Confusion or Berserk, and
##   no Silence where Silence stops their share (a spell, or Cael's Rally).
## - "After X learns Y" opens when X knows Y, and each partner must also know
##   the sub-ability the combo draws on (Shield Oath needs Cael's Press Forward).
## - Shield Oath and Promise of Dawn close once cael_betrayal_complete is set;
##   Cael's Echo opens only with that flag set and Edren knowing Oathkeeper.
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
## [param levels] and [param mps] are one value for everyone or one per slot.
## Returns [state, atb].
func _battle(character_ids: Array, levels: Variant = 1, mps: Variant = 99) -> Array:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	var atb: Node = ATBSystem.new()
	add_child_autofree(atb)
	for slot: int in range(character_ids.size()):
		var member: Dictionary = {
			"character_id": character_ids[slot],
			"level": _per_slot(levels, slot),
			"base_stats": {"hp": 100, "mp": _per_slot(mps, slot), "spd": 10},
		}
		state.add_member(slot, member)
		atb.add_combatant("party_%d" % slot, 10, false)
		atb.set_gauge("party_%d" % slot, ATBSystem.GAUGE_MAX)
	return [state, atb]


func _per_slot(value: Variant, slot: int) -> int:
	return int(value[slot]) if value is Array else int(value)


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


func test_a_partner_who_cannot_be_commanded_takes_the_combo_off_the_list() -> void:
	for status: String in ["confusion", "berserk"]:
		for slot: int in range(2):
			var battle: Array = _battle(["maren", "torren"])
			battle[0].apply_status(slot, status, "turns", 3)
			assert_does_not_have(_ids(battle), "ley_torrent", "slot %d has %s" % [slot, status])


func test_a_status_that_leaves_a_partner_acting_keeps_the_combo() -> void:
	var battle: Array = _battle(["maren", "torren"])
	battle[0].apply_status(1, "poison", "turns", 3)
	assert_has(_ids(battle), "ley_torrent", "Poison does not stop Torren acting")


# ── Silence ─────────────────────────────────────────────────────────────


func test_silence_on_cael_closes_the_combos_his_rally_supplies() -> void:
	# Edren, Cael and Lira at 5: Shield Oath and Promise of Dawn are both open.
	var battle: Array = _battle(["edren", "cael", "lira"], 5)
	assert_has(_ids(battle), "shield_oath", "open before the Silence")
	assert_has(_ids(battle), "promise_of_dawn", "open before the Silence")
	battle[0].apply_status(1, "silence", "turns", 4)
	assert_does_not_have(_ids(battle), "shield_oath", "Silence ends a Rally")
	assert_does_not_have(_ids(battle), "promise_of_dawn", "Silence ends a Rally")
	# Seated Lira, Edren, Cael: the Silence is read off Cael's own slot, 2.
	battle = _battle(["lira", "edren", "cael"], 5)
	battle[0].apply_status(2, "silence", "turns", 4)
	assert_does_not_have(_ids(battle), "promise_of_dawn", "Cael in slot 2 is Silenced")


func test_silence_leaves_a_share_that_is_not_a_spell_or_a_rally() -> void:
	var knights: Array = _battle(["edren", "cael", "lira"], 5)
	knights[0].apply_status(0, "silence", "turns", 4)
	knights[0].apply_status(2, "silence", "turns", 4)
	assert_has(_ids(knights), "shield_oath", "Edren's Ironwall is a stance")
	assert_has(_ids(knights), "promise_of_dawn", "Lira's share is her devices")
	var torrent: Array = _battle(["maren", "torren"])
	torrent[0].apply_status(0, "silence", "turns", 4)
	torrent[0].apply_status(1, "silence", "turns", 4)
	assert_has(_ids(torrent), "ley_torrent", "an Arcanum weave and a Spiritcall")


func test_silence_stops_a_share_that_is_a_spell() -> void:
	# No combo's share is a spell today; this pins the rule the next one meets.
	assert_true(BattleCombos.silence_stops_share("maren", ["rime_shard"]), "a ley-line spell")
	assert_false(BattleCombos.silence_stops_share("torren", ["ember_wing"]), "a Spiritcall")
	assert_false(BattleCombos.silence_stops_share("edren", ["ironwall"]), "a Bulwark stance")
	assert_true(BattleCombos.silence_stops_share("cael", []), "any share of Cael's is a Rally")


# ── slots ───────────────────────────────────────────────────────────────


func test_a_combo_reads_its_characters_wherever_they_are_seated() -> void:
	# Forged Rampart is Edren + Lira; here Lira sits in slot 0 and Edren in 3.
	var battle: Array = _battle(["lira", "maren", "torren", "edren"], [6, 7, 7, 7])
	assert_does_not_have(_ids(battle), "forged_rampart", "Lira is 6; Edren's 7 is no help")
	battle = _battle(["lira", "maren", "torren", "edren"], [7, 1, 1, 1])
	assert_eq(_result(battle, "forged_rampart").get("slots", []), [3, 0], "Edren, then Lira")


func test_affordability_reads_each_characters_own_slot() -> void:
	# Ley Torrent is Maren (10 MP) + Torren (8 MP), seated in slots 3 and 0.
	var cast: Array = ["torren", "lira", "edren", "maren"]
	assert_eq(_result(_battle(cast), "ley_torrent").get("slots", []), [3, 0], "Maren, Torren")
	assert_true(_result(_battle(cast, 1, [8, 0, 0, 10]), "ley_torrent")["affordable"], "exact")
	assert_false(_result(_battle(cast, 1, [99, 99, 99, 9]), "ley_torrent")["affordable"], "Maren")
	assert_false(_result(_battle(cast, 1, [7, 99, 99, 99]), "ley_torrent")["affordable"], "Torren")


# ── MP ──────────────────────────────────────────────────────────────────


func test_short_mp_grays_a_combo_rather_than_hiding_it() -> void:
	# Ley Torrent costs Maren 10 MP and Torren 8 (abilities.md § Combo List).
	var both_short: Array = _battle(["maren", "torren"], 1, 0)
	assert_has(_ids(both_short), "ley_torrent", "short MP still lists it")
	assert_false(_result(both_short, "ley_torrent")["affordable"], "neither can pay")


func test_a_combo_is_affordable_only_when_each_character_can_pay_their_share() -> void:
	assert_true(_result(_battle(["maren", "torren"], 1, [10, 8]), "ley_torrent")["affordable"])
	assert_false(_result(_battle(["maren", "torren"], 1, [9, 8]), "ley_torrent")["affordable"])
	assert_false(_result(_battle(["maren", "torren"], 1, [10, 7]), "ley_torrent")["affordable"])


# ── story gates ─────────────────────────────────────────────────────────


func test_at_the_start_only_the_ungated_combos_are_open() -> void:
	# Level 1, no story flags: Shield Oath waits for Cael's Press Forward (5),
	# Thornfire for Torren's Ember Wing (11), the rest for what they learn.
	assert_eq(
		_open_combos(1),
		["arcane_convergence", "ley_torrent", "promise_of_dawn", "weave_theft"],
		"only the combos that name no ability are open"
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


func test_shield_oath_needs_cael_to_know_press_forward() -> void:
	# Cael's share is Press Forward (Level 5); Edren's Ironwall is known from 1.
	assert_does_not_have(_ids(_battle(["edren", "cael"], [1, 4])), "shield_oath", "Cael at 4")
	assert_has(_ids(_battle(["edren", "cael"], [1, 5])), "shield_oath", "Cael at 5")


func test_shattered_vanguard_needs_edren_to_know_shatter_guard() -> void:
	# Sable's Misdirect (Interlude, Level 14) and Edren's Shatter Guard (22).
	_learn_everything()
	var pair: Array = ["edren", "sable"]
	assert_does_not_have(_ids(_battle(pair, [21, 14])), "shattered_vanguard", "Edren at 21")
	assert_has(_ids(_battle(pair, [22, 14])), "shattered_vanguard", "Edren at 22")


func test_ambush_protocol_needs_both_of_its_abilities() -> void:
	# "After Sable learns Misdirect (Interlude) and Lira learns Arc Trap (Level
	# 12)". Misdirect is [S] at Level 14, so it needs that level and the story.
	var pair: Array = ["sable", "lira"]
	assert_does_not_have(_ids(_battle(pair, [14, 12])), "ambush_protocol", "no Interlude yet")
	_learn_everything()
	assert_does_not_have(_ids(_battle(pair, [13, 12])), "ambush_protocol", "Sable under 14")
	assert_does_not_have(_ids(_battle(pair, [14, 11])), "ambush_protocol", "Lira under 12")
	assert_has(_ids(_battle(pair, [14, 12])), "ambush_protocol", "both learned")


func test_an_ability_gate_reads_its_own_characters_abilities() -> void:
	# Thornfire waits on Torren's Ember Wing (Level 11): a level-11 Lira is no help.
	assert_does_not_have(_ids(_battle(["torren", "lira"], [10, 11])), "thornfire", "Torren 10")
	assert_has(_ids(_battle(["torren", "lira"], [11, 10])), "thornfire", "Torren reaches 11")


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
	# Six combos carry seven "learns" clauses; Cael's Echo adds Oathkeeper, and
	# Shield Oath (2), Shattered Vanguard and Thornfire (1 each) add sub-abilities.
	assert_eq(checked, 12, "twelve required abilities across eight combos")


## The gate is read from the combo's own words, so the two cannot drift: every
## ability of either partner that the effect, availability or description
## names is required and nothing else is, each "X learns Y" names Y's owner,
## and the betrayal flag follows the two Act clauses.
func test_every_story_gate_says_what_its_combo_text_says() -> void:
	var learns_re: RegEx = RegEx.new()
	assert_eq(learns_re.compile("(\\w+) learns ([A-Z][\\w']*(?: [A-Z][\\w']*)*)"), OK)
	for raw: Variant in DataManager.load_combos():
		var combo: Dictionary = raw
		var cid_id_by_name: Dictionary = {}
		for cid: String in combo["characters"]:
			for a: Dictionary in DataManager.load_abilities(cid):
				cid_id_by_name[a["name"]] = "%s/%s" % [cid, a["id"]]
		var text: String = " ".join([combo["effect"], combo["availability"], combo["description"]])
		var named: Array = []
		for ability_name: String in cid_id_by_name:
			var word: RegEx = RegEx.new()
			word.compile("\\b%s\\b" % ability_name)
			if word.search(text) != null:
				named.append(cid_id_by_name[ability_name])
		var gate: Dictionary = combo["story_gate"]
		var required: Array = gate["requires_abilities"].map(
			func(g: Dictionary) -> String: return "%s/%s" % [g["character"], g["ability"]]
		)
		named.sort()
		required.sort()
		assert_eq(required, named, "%s requires exactly what its text names" % combo["id"])
		for m: RegExMatch in learns_re.search_all(combo["availability"]):
			var owner_id: String = cid_id_by_name.get(m.get_string(2), "?/?")
			assert_eq(owner_id.get_slice("/", 0), m.get_string(1).to_lower(), m.get_string(0))
		var availability: String = combo["availability"]
		var lost: bool = "lost after Cael's betrayal" in availability
		var after: bool = "after Cael's departure" in availability
		assert_eq(gate["forbids_flags"], [BETRAYAL] if lost else [], "%s forbids" % combo["id"])
		assert_eq(gate["requires_flags"], [BETRAYAL] if after else [], "%s requires" % combo["id"])
