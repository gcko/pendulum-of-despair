extends GutTest
## Cael's Rally (GAP-002, slice 158a of #158): the Ability command's first
## built unique command.
##
## Every magnitude below comes from abilities.md § Cael — Rally and
## game/data/abilities/cael.json, not from this file: the tests read the
## command's own table and then hold that table to the shipped data's effect
## text, so a number that drifts from the design fails here.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")

const EDREN := 0
const CAEL := 1
const LIRA := 2


## The three accessors and two signals a command module reaches on the battle
## manager — the same seam BattleMagicCommand uses.
class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	var state: Node

	func get_battle_state() -> Node:
		return state


var _battle: FakeBattle
var _state: Node
var _cmd: RefCounted
var _messages: Array[String] = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	_state = BattleState.new()
	add_child_autofree(_state)
	_state.add_member(EDREN, _member("edren", "Edren", 40))
	_state.add_member(CAEL, _member("cael", "Cael", 40))
	_state.add_member(LIRA, _member("lira", "Lira", 40))
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_messages = []
	_battle.message.connect(func(t: String) -> void: _messages.append(t))
	_cmd = AbilityCommand.new(_battle)


func after_each() -> void:
	_cmd = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _member(cid: String, nm: String, mp: int) -> Dictionary:
	return {
		"character_id": cid,
		"name": nm,
		"base_stats":
		{"hp": 200, "mp": mp, "atk": 50, "def": 40, "mag": 20, "mdef": 20, "spd": 30, "lck": 8},
	}


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("cael"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("cael.json has no ability '%s'" % ability_id)
	return {}


func _rally(ability_id: String) -> bool:
	return _cmd.do_ability("party_%d" % CAEL, {"type": "ability", "ability": _ability(ability_id)})


func _stats(slot: int) -> Dictionary:
	var out: Dictionary = {}
	for stat: String in ["atk", "def", "mag", "mdef", "spd"]:
		out[stat] = _state.get_effective_stat(slot, stat)
	return out


## What a stat reads under a +pct% buff — the same integer floor every
## effective-stat read uses.
func _buffed(base: int, pct: int) -> int:
	return base * (100 + pct) / 100


# --- The table is the doc ---


func test_every_rally_magnitude_and_duration_matches_the_shipped_effect_text() -> void:
	# The command keeps its numbers in one table. Hold each entry to the
	# sentence the data ships, so neither can move without the other.
	for ability_id: String in AbilityCommand.RALLY_EFFECTS:
		var effect: Dictionary = AbilityCommand.RALLY_EFFECTS[ability_id]
		var text: String = String(_ability(ability_id).get("effect", ""))
		assert_true(text.begins_with("Rally."), "%s is a Rally in the data" % ability_id)
		assert_true(
			text.contains("%d turns" % int(effect["turns"])),
			"%s lasts %d turns: %s" % [ability_id, effect["turns"], text]
		)
		var stat_pct: Dictionary = effect.get("stat_pct", {})
		for stat: String in stat_pct:
			assert_true(
				text.contains("+%d%% %s" % [stat_pct[stat], AbilityCommand.STAT_WORDS[stat]]),
				"%s gives +%d%% %s: %s" % [ability_id, stat_pct[stat], stat, text]
			)
		if effect.has("regen_pct"):
			assert_true(
				text.contains("regenerate %d%% max HP" % int(effect["regen_pct"])),
				"%s regenerates %d%%: %s" % [ability_id, effect["regen_pct"], text]
			)


func test_every_rally_in_the_data_has_an_implementation() -> void:
	# Vanguard Strike is a "Command", not a Rally, so it is the one Cael
	# ability this slice does not build.
	for a: Variant in DataManager.load_abilities("cael"):
		var ad: Dictionary = a
		if String(ad.get("effect", "")).begins_with("Rally."):
			assert_true(AbilityCommand.is_built(ad), "%s is built" % ad.get("id", ""))


# --- Issuing a Rally ---


func test_hold_the_line_spends_its_mp_cost() -> void:
	var cost: int = int(_ability("hold_the_line").get("cost_value", 0))
	assert_true(_rally("hold_the_line"), "the Rally resolves")
	assert_eq(_state.get_member(CAEL)["current_mp"], 40 - cost, "Cael pays %d MP" % cost)


func test_hold_the_line_raises_def_and_mdef_of_every_living_ally() -> void:
	var before: Array = [_stats(EDREN), _stats(CAEL), _stats(LIRA)]
	_rally("hold_the_line")
	for slot: int in [EDREN, CAEL, LIRA]:
		var now: Dictionary = _stats(slot)
		assert_eq(now["def"], _buffed(before[slot]["def"], 15), "slot %d DEF +15%%" % slot)
		assert_eq(now["mdef"], _buffed(before[slot]["mdef"], 15), "slot %d MDEF +15%%" % slot)
		assert_eq(now["atk"], before[slot]["atk"], "slot %d ATK untouched" % slot)


func test_press_forward_raises_atk_and_spd_of_every_living_ally() -> void:
	var before: Array = [_stats(EDREN), _stats(CAEL), _stats(LIRA)]
	_rally("press_forward")
	for slot: int in [EDREN, CAEL, LIRA]:
		var now: Dictionary = _stats(slot)
		assert_eq(now["atk"], _buffed(before[slot]["atk"], 20), "slot %d ATK +20%%" % slot)
		assert_eq(now["spd"], _buffed(before[slot]["spd"], 10), "slot %d SPD +10%%" % slot)
		assert_eq(now["def"], before[slot]["def"], "slot %d DEF untouched" % slot)


func test_a_fallen_ally_is_not_rallied() -> void:
	var before: Dictionary = _stats(LIRA)
	_state.take_damage(LIRA, 9999)
	_rally("hold_the_line")
	assert_eq(_stats(LIRA)["def"], before["def"], "a KO'd ally gains nothing")


func test_rally_announces_the_ability_by_name() -> void:
	# ui-design.md § 2.5: the message window carries the action's name.
	_rally("hold_the_line")
	assert_has(_messages, "Hold the Line", "the Rally's name is announced")


func test_rally_without_enough_mp_is_refused_and_costs_nothing() -> void:
	_state.get_member(CAEL)["current_mp"] = 5
	var before: Dictionary = _stats(EDREN)
	assert_false(_rally("hold_the_line"), "6 MP Rally refused at 5 MP")
	assert_eq(_state.get_member(CAEL)["current_mp"], 5, "no MP spent")
	assert_eq(_stats(EDREN)["def"], before["def"], "no buff landed")


func test_another_characters_ability_is_not_cael_s_to_issue() -> void:
	var bulwark: Dictionary = DataManager.load_abilities("edren")[0]
	assert_false(
		_cmd.do_ability("party_%d" % CAEL, {"type": "ability", "ability": bulwark}),
		"Cael cannot issue Edren's ability"
	)


# --- Duration ---


func test_a_rally_lasts_its_turns_on_each_ally_then_lapses() -> void:
	var base_def: int = _stats(EDREN)["def"]
	_rally("hold_the_line")
	_state.tick_statuses(EDREN)
	_state.tick_statuses(EDREN)
	assert_eq(_stats(EDREN)["def"], _buffed(base_def, 15), "still buffed after 2 of 3 turns")
	_state.tick_statuses(EDREN)
	assert_eq(_stats(EDREN)["def"], base_def, "gone after Edren's 3rd turn")


func test_the_rally_stays_active_while_any_ally_still_carries_it() -> void:
	_rally("hold_the_line")
	for _i: int in range(3):
		_state.tick_statuses(CAEL)
	assert_false(_state.get_active_rally().is_empty(), "allies still under it")
	for slot: int in [EDREN, LIRA]:
		for _i: int in range(3):
			_state.tick_statuses(slot)
	assert_true(_state.get_active_rally().is_empty(), "lapsed once every ally's turns ran out")


# --- One Rally at a time ---


func test_a_second_rally_replaces_the_first() -> void:
	var before: Dictionary = _stats(EDREN)
	_rally("hold_the_line")
	_rally("press_forward")
	var now: Dictionary = _stats(EDREN)
	assert_eq(now["def"], before["def"], "Hold the Line's DEF is gone")
	assert_eq(now["atk"], _buffed(before["atk"], 20), "Press Forward's ATK is in force")
	assert_eq(_state.get_active_rally().get("id", ""), "press_forward", "one active Rally")


func test_reissuing_the_same_rally_restarts_its_clock_without_stacking() -> void:
	var base_def: int = _stats(EDREN)["def"]
	_rally("hold_the_line")
	_state.tick_statuses(EDREN)
	_state.tick_statuses(EDREN)
	_rally("hold_the_line")
	assert_eq(_stats(EDREN)["def"], _buffed(base_def, 15), "+15%, not +15% twice")
	_state.tick_statuses(EDREN)
	_state.tick_statuses(EDREN)
	assert_eq(_stats(EDREN)["def"], _buffed(base_def, 15), "fresh 3 turns")


# --- End conditions: Faint, Silence, Sleep ---


func test_rally_ends_when_cael_faints() -> void:
	var base_def: int = _stats(EDREN)["def"]
	_rally("hold_the_line")
	_state.take_damage(CAEL, 9999)
	assert_eq(_stats(EDREN)["def"], base_def, "Edren's buff ends with Cael")
	assert_true(_state.get_active_rally().is_empty(), "no Rally active")


func test_rally_ends_when_cael_is_silenced() -> void:
	var base_def: int = _stats(EDREN)["def"]
	_rally("hold_the_line")
	_state.apply_status(CAEL, "silence", "turns", 4)
	assert_eq(_stats(EDREN)["def"], base_def, "Silence ends the Rally")
	assert_true(_state.get_active_rally().is_empty(), "no Rally active")


func test_rally_ends_when_cael_falls_asleep() -> void:
	var base_def: int = _stats(EDREN)["def"]
	_rally("hold_the_line")
	_state.apply_status(CAEL, "sleep", "turns", -1)
	assert_eq(_stats(EDREN)["def"], base_def, "Sleep ends the Rally")
	assert_true(_state.get_active_rally().is_empty(), "no Rally active")


func test_an_ally_other_than_cael_being_silenced_does_not_end_it() -> void:
	_rally("hold_the_line")
	_state.apply_status(EDREN, "silence", "turns", 4)
	_state.apply_status(LIRA, "sleep", "turns", -1)
	assert_eq(_state.get_active_rally().get("id", ""), "hold_the_line", "only Cael's state matters")


func test_other_statuses_on_cael_do_not_end_it() -> void:
	_rally("hold_the_line")
	_state.apply_status(CAEL, "poison", "turns", -1)
	assert_eq(_state.get_active_rally().get("id", ""), "hold_the_line", "Poison is not an end")


# --- Second Wind: regen at the start of each ally's turn ---


func test_second_wind_regenerates_five_percent_at_the_start_of_each_turn_for_four_turns() -> void:
	_state.take_damage(EDREN, 150)  # 50 / 200 HP
	_rally("second_wind")
	var healed: Array[int] = []
	for _i: int in range(5):
		healed.append(_state.begin_turn(EDREN))
		_state.tick_statuses(EDREN)
	assert_eq(healed, [10, 10, 10, 10, 0] as Array[int], "5% of 200 on four turns, then none")
	assert_eq(_state.get_member(EDREN)["current_hp"], 90, "50 + 4 x 10")


func test_second_wind_heals_once_per_turn_however_often_the_turn_is_prompted() -> void:
	_state.take_damage(EDREN, 150)
	_rally("second_wind")
	_state.begin_turn(EDREN)
	assert_eq(_state.begin_turn(EDREN), 0, "a re-prompt of the same turn heals nothing")


# --- Unbreakable: survive one lethal blow, then the Rally ends ---


func test_unbreakable_leaves_an_ally_at_1_hp_once_then_ends() -> void:
	_rally("unbreakable")
	_state.take_damage(LIRA, 9999)
	assert_eq(_state.get_member(LIRA)["current_hp"], 1, "survives at 1 HP")
	assert_true(_state.get_member(LIRA)["is_alive"], "not fainted")
	assert_true(_state.get_active_rally().is_empty(), "triggered once, then the Rally ends")
	_state.take_damage(LIRA, 9999)
	assert_false(_state.get_member(LIRA)["is_alive"], "the next lethal blow lands")


func test_unbreakable_does_not_trigger_on_a_non_lethal_hit() -> void:
	_rally("unbreakable")
	_state.take_damage(LIRA, 50)
	assert_eq(_state.get_member(LIRA)["current_hp"], 150, "ordinary damage")
	assert_eq(_state.get_active_rally().get("id", ""), "unbreakable", "still waiting")
