extends GutTest
## What the battle says when a party member's status ends, and when Smoke Bomb
## gets the party out (#515).
##
## Each line is battle-dialogue.md's own (§ Status Effect Notifications, § Escape):
##   - a cure by a spell, item or ability says "[Status] was cured!", the status
##     named as magic.md § Status Effect Reference names it;
##   - running out says "Poison wears off." or "Silence wears off.", the only two
##     the doc gives, and any other status ends without a line;
##   - a waking hit and a KO add nothing (waking is announced on its own path);
##   - Smoke Bomb ends the battle as Flee does: "Escaped!" and a flee result.
## Rulings of 2026-10-30.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const BattleItemCommand = preload("res://scripts/combat/battle_item_command.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")

const PROMPT_TIMEOUT: float = 5.0
## New-game party: Edren in slot 0 acts, Cael in slot 1 is acted on.
const ACTOR: int = 0
const TARGET: int = 1
const NOTIFICATIONS: String = "res://data/dialogue/battle_status_effect_notifications.json"


## The slice of the battle Smoke Bomb reaches: the party, the boss flag, and
## where an escape goes.
class EscapeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal flee_result(success: bool)
	var state: Node
	var boss: bool = false
	var exits: Array[String] = []
	## Every line, flee result and exit, in the order they happened.
	var events: Array[String] = []

	func get_battle_state() -> Node:
		return state

	func is_boss_battle() -> bool:
		return boss

	func exit_battle(result: String) -> void:
		exits.append(result)
		events.append("exit %s" % result)


var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _boot() -> Node:
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
	_booted = battle
	return battle


func _await_prompt(battle: Node) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge("party_%d" % ACTOR, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not "party_%d" % ACTOR in prompted:
		fail_test("the battle never asked Edren for a command (asked: %s)" % str(prompted))
		return false
	return true


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


func _spell(tradition: String, spell_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


func _item(item_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_items("consumables"):
		if String((entry as Dictionary).get("id", "")) == item_id:
			return (entry as Dictionary).duplicate(true)
	fail_test("%s is missing from consumables.json" % item_id)
	return {}


func _submit(battle: Node, command: Dictionary) -> void:
	battle.get_node("BattleUI").command_submitted.emit(command)


## Every line the shipped notification data carries.
func _shipped_lines() -> Array[String]:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NOTIFICATIONS))
	var out: Array[String] = []
	for entry: Dictionary in data.get("entries", []):
		for line: Variant in entry.get("lines", []):
			out.append(str(line))
	return out


# ── Cures ────────────────────────────────────────────────────────────────


func test_purge_shows_poison_was_cured() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().apply_status(TARGET, "poison", "turns", -1.0)
	var lines: Array[String] = _messages(battle)

	_submit(battle, {"type": "magic", "spell": _spell("ley_line", "purge"), "target": TARGET})

	assert_has(lines, "Poison was cured!")


func test_a_cure_names_each_status_it_lifts() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().apply_status(TARGET, "silence", "turns", 4.0)
	battle.get_battle_state().apply_status(TARGET, "berserk", "turns", -1.0)
	var lines: Array[String] = _messages(battle)

	_submit(battle, {"type": "magic", "spell": _spell("ley_line", "purge"), "target": TARGET})

	assert_has(lines, "Silence was cured!")
	assert_has(lines, "Berserk was cured!")


func test_an_antidote_shows_poison_was_cured() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().apply_status(TARGET, "poison", "turns", -1.0)
	var lines: Array[String] = _messages(battle)

	_submit(battle, {"type": "item", "item": _item("antidote"), "target": TARGET})

	assert_has(lines, "Used Antidote!")
	assert_has(lines, "Poison was cured!", "for the one status it lifted")
	assert_does_not_have(lines, "Burn was cured!", "and not for the Burn Cael never had")


func test_starbloom_tea_shows_each_ailment_it_clears() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().apply_status(TARGET, "blind", "turns", 4.0)
	var lines: Array[String] = _messages(battle)

	_submit(battle, {"type": "item", "item": _item("starbloom_tea"), "target": TARGET})

	assert_has(lines, "Blind was cured!")


func test_steadfast_resolve_shows_what_it_cleanses() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(TARGET, "silence", "turns", 4.0)
	var lines: Array[String] = _messages(battle)

	Bulwark.steadfast_resolve(state)

	assert_has(lines, "Silence was cured!")


func test_the_cure_line_is_the_shipped_one() -> void:
	# battle-dialogue.md's "[Status] was cured!" ships as notification 019; the
	# battle's line is that template with the status filled in.
	assert_has(_shipped_lines(), "[Status] was cured!")


# ── Running out ──────────────────────────────────────────────────────────


func test_poison_running_out_shows_its_wears_off_line() -> void:
	# Poison lasts until cured by default; an enemy move with its own duration
	# can make it run out.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(TARGET, "poison", "turns", 1.0)
	var lines: Array[String] = _messages(battle)

	state.tick_statuses(TARGET)

	assert_false(state.has_status(TARGET, "poison"), "precondition: it ran out")
	assert_has(lines, "Poison wears off.")
	assert_does_not_have(lines, "Poison was cured!", "running out is not a cure")


func test_silence_running_out_shows_its_wears_off_line() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(TARGET, "silence", "turns", 1.0)
	var lines: Array[String] = _messages(battle)

	state.tick_statuses(TARGET)

	assert_has(lines, "Silence wears off.")


func test_a_status_with_no_wears_off_line_ends_in_silence() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(TARGET, "slow", "turns", 1.0)
	state.apply_status(TARGET, "stop", "realtime", 0.5)
	var lines: Array[String] = _messages(battle)

	state.tick_statuses(TARGET)
	state.tick_realtime_statuses(TARGET, 1.0)

	assert_false(state.has_status(TARGET, "slow"), "precondition: Slow ran out")
	assert_false(state.has_status(TARGET, "stop"), "precondition: Stop ran out")
	assert_eq(lines, [] as Array[String], "and the battle said nothing")


func test_the_wears_off_lines_are_the_shipped_ones() -> void:
	var shipped: Array[String] = _shipped_lines()
	assert_has(shipped, "Poison wears off.")
	assert_has(shipped, "Silence wears off.")


# ── Neither a cure nor running out ───────────────────────────────────────


func test_a_waking_hit_and_a_ko_add_no_cure_line() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(TARGET, "sleep", "turns", -1.0)
	state.apply_status(TARGET, "confusion", "turns", 3.0)
	var lines: Array[String] = _messages(battle)

	state.take_damage(TARGET, 1)
	state.apply_status(TARGET, "berserk", "turns", -1.0)
	state.take_damage(TARGET, 99999)

	assert_false(state.has_status(TARGET, "sleep"), "precondition: the hit woke Cael")
	assert_false(state.has_status(TARGET, "berserk"), "precondition: the KO cleared Berserk")
	assert_true(lines.size() > 0, "precondition: the battle said something to check")
	for line: String in lines:
		assert_false(line.ends_with("was cured!"), "no cure line, got %s" % line)
		assert_false(line.ends_with("wears off."), "no wears-off line, got %s" % line)


# ── Smoke Bomb ───────────────────────────────────────────────────────────


func test_smoke_bomb_shows_escaped_and_reports_a_successful_flee() -> void:
	var battle: EscapeBattle = EscapeBattle.new()
	add_child_autofree(battle)
	battle.state = BattleState.new()
	battle.add_child(battle.state)
	battle.message.connect(func(text: String) -> void: battle.events.append(text))
	battle.flee_result.connect(
		func(success: bool) -> void: battle.events.append("flee_result %s" % success)
	)

	BattleItemCommand.new(battle).do_item({"item": _item("smoke_bomb"), "target": 0})

	# Flee's own order (BattlePlayerActions.do_flee): the line, the result, then
	# the exit, so whatever hears flee_result hears it while the battle stands.
	assert_eq(
		battle.events,
		["Used Smoke Bomb!", "Escaped!", "flee_result true", "exit flee"] as Array[String]
	)


func test_smoke_bomb_is_still_refused_in_a_boss_fight() -> void:
	var battle: EscapeBattle = EscapeBattle.new()
	add_child_autofree(battle)
	battle.state = BattleState.new()
	battle.add_child(battle.state)
	battle.boss = true
	var lines: Array[String] = []
	battle.message.connect(func(text: String) -> void: lines.append(text))
	watch_signals(battle)

	BattleItemCommand.new(battle).do_item({"item": _item("smoke_bomb"), "target": 0})

	assert_does_not_have(lines, "Escaped!")
	assert_signal_not_emitted(battle, "flee_result")
	assert_eq(battle.exits, [] as Array[String])
