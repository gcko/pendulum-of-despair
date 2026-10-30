extends GutTest
## Sable's Tricks (GAP-002, slice 158d of #158): stealing, the Stolen Goods
## pool, cooldowns, the front-row gate and Unbreakable Thread. What a Trick
## does when it hits — Shiv, Wild Card, Smokescreen — is
## test_battle_tricks_strikes.gd.
##
## Design law: abilities.md § Sable — Tricks and game/data/abilities/sable.json,
## with the readings recorded there from #158 and #447: Filch's chance on each
## steal tier is that tier's rate times clamp(1 + (Sable SPD - enemy SPD) / 100,
## 0.5, 1.5); Ransack takes 70% of it; cooldowns count on Sable's own turns.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const SubmenuItems = preload("res://scripts/ui/battle_submenu_items.gd")
const Record = preload("res://scripts/entities/enemy_record.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const SABLE := 0
const EDREN := 1
const CAEL := 2
const LIRA := 3

## Sable's SPD in these tests; enemies' SPD is set relative to it.
const SABLE_SPD := 100


class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)
	var state: Node
	var enemies: Array[Node] = []
	var atb: Node

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return enemies

	func get_atb() -> Node:
		return atb


var _battle: FakeBattle
var _state: Node
var _cmd: RefCounted
var _messages: Array[String] = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	seed(158)
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["sable", "edren", "cael", "lira"][slot]))
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_battle.atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_battle.atb)
	_messages = []
	_battle.message.connect(func(t: String) -> void: _messages.append(t))
	_cmd = AbilityCommand.new(_battle)
	_battle.enemies = [_make_enemy({})] as Array[Node]


func after_each() -> void:
	_cmd = null
	randomize()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _member(cid: String) -> Dictionary:
	return {
		"character_id": cid,
		"name": cid.capitalize(),
		"level": 40,
		"base_stats":
		{
			"hp": 1000,
			"mp": 60,
			"atk": 50,
			"def": 40,
			"mag": 40,
			"mdef": 20,
			"spd": SABLE_SPD,
			"lck": 0,
		},
	}


## An enemy with Sable's SPD and a steal table of [param common] and
## [param rare] (rates, or -1 for a null tier), [param extra] overriding the rest.
func _make_enemy(extra: Dictionary, common: int = 100, rare: int = -1) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	var steal: Dictionary = {"common": null, "rare": null}
	if common >= 0:
		steal["common"] = {"item_id": "beast_hide", "rate": common}
	if rare >= 0:
		steal["rare"] = {"item_id": "sharp_fang", "rate": rare}
	var data: Dictionary = {
		"name": "Mark",
		"atk": 40,
		"mag": 40,
		"spd": SABLE_SPD,
		"def": 10,
		"mdef": 10,
		"type": "humanoid",
		"hp": 30000,
		"steal": steal,
	}
	data.merge(extra, true)
	e.enemy_data = data
	e.current_hp = int(data["hp"])
	e.is_alive = true
	return e


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("sable"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("sable.json has no ability '%s'" % ability_id)
	return {}


## Issue [param ability_id] from Sable inside one of her turns, as the battle does.
func _use(ability_id: String, target: int = 0) -> bool:
	_state.begin_turn(SABLE)
	var ok: bool = _cmd.do_ability(
		"party_%d" % SABLE, {"type": "ability", "ability": _ability(ability_id), "target": target}
	)
	_state.tick_statuses(SABLE)
	return ok


## One of Sable's turns spent on something other than a Trick.
func _sable_turn() -> void:
	_state.begin_turn(SABLE)
	_state.tick_statuses(SABLE)


func _usable(ability_id: String) -> bool:
	var member: Dictionary = _state.get_member(SABLE)
	var ability: Dictionary = _ability(ability_id)
	return AbilityCommand.is_available(member, ability) and AbilityCommand.can_pay(member, ability)


func _pool() -> Array[String]:
	return BattleTricks.goods(_state, SABLE)


func _stock(item_id: String) -> int:
	return (
		int(PartyState.get_materials().get(item_id, 0))
		+ int(PartyState.get_consumables().get(item_id, 0))
	)


## How many of [param tries] Filches stole something, each on a fresh enemy
## built like enemy 0 (an enemy is robbed once) and on a fresh turn, with the
## pool emptied between them so the cap never decides the count.
func _filch_successes(tries: int) -> int:
	var stolen: int = 0
	var mark: Enemy = _battle.enemies[0]
	for _i: int in range(tries):
		_battle.enemies[0] = _make_enemy(mark.enemy_data.duplicate(true))
		_state.get_member(SABLE)["stolen_goods"] = [] as Array[String]
		_use("filch")
		stolen += _pool().size()
	return stolen


# --- Filch's success curve (reading 2 on #158) ---


func test_the_speed_factor_rises_one_percent_per_point_of_speed_advantage() -> void:
	assert_almost_eq(BattleTricks.steal_mult(100, 100), 1.0, 0.0001, "even speed: the tier's rate")
	assert_almost_eq(BattleTricks.steal_mult(130, 100), 1.3, 0.0001, "+30 SPD: x1.3")
	assert_almost_eq(BattleTricks.steal_mult(70, 100), 0.7, 0.0001, "-30 SPD: x0.7")


func test_the_speed_factor_is_clamped_between_half_and_one_and_a_half() -> void:
	assert_almost_eq(BattleTricks.steal_mult(250, 100), 1.5, 0.0001, "a big lead caps at x1.5")
	assert_almost_eq(BattleTricks.steal_mult(10, 100), 0.5, 0.0001, "a big deficit floors at x0.5")


func test_a_steal_tier_rolls_against_its_rate_times_the_multiplier() -> void:
	var data: Dictionary = {"steal": {"common": {"item_id": "beast_hide", "rate": 70}}}
	var always: int = 0
	var never: int = 0
	for _i: int in range(200):
		always += int(Record.roll_steal(data, "common", 1.5)["success"])  # 105: certain
		never += int(Record.roll_steal(data, "common", 0.0)["success"])
	assert_eq(always, 200, "70% x1.5 is past 100%, so every roll succeeds")
	assert_eq(never, 0, "a zero multiplier never steals")


func test_filch_with_a_speed_lead_turns_a_two_thirds_steal_certain() -> void:
	_battle.enemies[0].enemy_data["steal"]["common"]["rate"] = 67
	_battle.enemies[0].enemy_data["spd"] = SABLE_SPD - 50  # x1.5: 67 -> 100
	assert_eq(_filch_successes(60), 60, "every Filch steals")


func test_filch_at_a_speed_deficit_halves_a_certain_steal() -> void:
	_battle.enemies[0].enemy_data["spd"] = SABLE_SPD + 80  # clamped to x0.5: 100 -> 50
	var stolen: int = _filch_successes(200)
	assert_between(stolen, 60, 140, "about half of 200 Filches steal, not all: %d" % stolen)


func test_filch_tries_the_common_tier_then_the_rare_one() -> void:
	_battle.enemies[0] = _make_enemy({}, -1, 100)
	_battle.enemies[0].enemy_data["spd"] = SABLE_SPD
	assert_true(_use("filch"), "Filch issued")
	assert_eq(_pool(), ["sharp_fang"] as Array[String], "the empty common tier falls to the rare")


func test_a_successful_filch_puts_the_item_in_the_party_inventory() -> void:
	assert_true(_use("filch"), "Filch issued")
	assert_eq(_pool(), ["beast_hide"] as Array[String], "held for Tricks")
	assert_eq(_stock("beast_hide"), 1, "and in the inventory, kept after the battle")
	assert_true(_messages.has("Obtained Beast Hide."), "says what was taken: %s" % [_messages])


func test_a_failed_filch_takes_nothing() -> void:
	_battle.enemies[0] = _make_enemy({}, -1, -1)
	assert_true(_use("filch"), "Filch is still a turn spent")
	assert_eq(_pool(), [] as Array[String], "nothing held")
	assert_eq(_stock("beast_hide"), 0, "nothing gained")


# --- Ransack ---


func test_ransack_takes_seventy_percent_of_filchs_chance() -> void:
	assert_almost_eq(
		BattleTricks.steal_mult(100, 100, BattleTricks.RANSACK_RATE_PCT), 0.7, 0.0001, "70% of x1.0"
	)
	assert_almost_eq(
		BattleTricks.steal_mult(250, 100, BattleTricks.RANSACK_RATE_PCT),
		1.05,
		0.0001,
		"70% of x1.5"
	)


func test_ransack_steals_from_every_enemy_at_once() -> void:
	_battle.enemies = [_make_enemy({"spd": 0}), _make_enemy({"spd": 0})] as Array[Node]
	assert_true(_use("ransack"), "Ransack issued")
	assert_eq(_pool(), ["beast_hide", "beast_hide"] as Array[String], "one item off each")
	assert_eq(_state.get_member(SABLE)["current_mp"], 60 - 8, "8 MP")


# --- The Stolen Goods pool holds three ---


func test_the_pool_holds_three_and_a_fourth_steal_goes_to_the_inventory_only() -> void:
	_battle.enemies = (
		[_make_enemy({}), _make_enemy({}), _make_enemy({}), _make_enemy({})] as Array[Node]
	)
	for i: int in range(4):
		_use("filch", i)
	assert_eq(_pool().size(), BattleTricks.POOL_LIMIT, "Sable holds three")
	assert_eq(BattleTricks.POOL_LIMIT, 3, "abilities.md: up to 3 stolen items at a time")
	assert_eq(_stock("beast_hide"), 4, "the fourth is still stolen, into the inventory")


func test_an_enemy_can_be_robbed_only_once() -> void:
	assert_true(_use("filch"), "first Filch")
	assert_eq(_stock("beast_hide"), 1, "it steals")
	assert_true(_use("filch"), "a second Filch is still a turn spent")
	assert_eq(_stock("beast_hide"), 1, "but the robbed enemy yields nothing more")
	assert_eq(_pool().size(), 1, "and nothing more is held")


func test_ransack_finds_nothing_on_an_enemy_already_filched() -> void:
	_battle.enemies = [_make_enemy({"spd": 0}), _make_enemy({"spd": 0})] as Array[Node]
	assert_true(_use("filch", 0), "Filch robs the first")
	assert_true(_use("ransack"), "Ransack issued")
	assert_eq(_stock("beast_hide"), 2, "only the second enemy still had something")


func test_an_item_used_from_the_inventory_leaves_the_pool() -> void:
	_use("filch")
	PartyState.consume_item("beast_hide")
	assert_eq(_pool(), [] as Array[String], "a stolen item the party used is no longer held")


# --- Cooldowns count Sable's turns ---


func test_a_trick_is_unusable_for_its_cooldown_in_sables_turns() -> void:
	assert_true(_use("smokescreen"), "Smokescreen issued")
	assert_false(_usable("smokescreen"), "cooling down on her next turn")
	_sable_turn()
	assert_false(_usable("smokescreen"), "two turns of cooldown")
	_sable_turn()
	assert_true(_usable("smokescreen"), "ready on the third")


func test_other_combatants_turns_do_not_count_a_cooldown_down() -> void:
	assert_true(_use("shiv"), "Shiv issued")
	for slot: int in [EDREN, CAEL, LIRA]:
		_state.begin_turn(slot)
		_state.tick_statuses(slot)
	_battle.enemies[0].tick_statuses()
	assert_false(_usable("shiv"), "a 1-turn cooldown waits for one of Sable's turns")
	_sable_turn()
	assert_true(_usable("shiv"), "and only hers")


func test_a_trick_on_cooldown_is_refused_without_cost() -> void:
	assert_true(_use("smokescreen"), "issued")
	var mp: int = _state.get_member(SABLE)["current_mp"]
	assert_false(_use("smokescreen"), "refused while cooling down")
	assert_eq(_state.get_member(SABLE)["current_mp"], mp, "nothing spent")


func test_filch_has_no_cooldown() -> void:
	assert_true(_use("filch"), "first")
	assert_true(_use("filch"), "and again the very next turn")


func test_a_trick_costs_its_mp() -> void:
	assert_true(_use("smokescreen"), "issued")
	assert_eq(_state.get_member(SABLE)["current_mp"], 60 - 4, "Smokescreen is 4 MP")
	_state.get_member(SABLE)["current_mp"] = 9
	assert_false(_usable("wild_card"), "Wild Card's 10 MP cannot be paid from 9")
	assert_false(_use("wild_card"), "and is refused")
	assert_true(_messages.has("Not enough MP!"), "named as MP: %s" % [_messages])


func test_wild_cards_cooldown_is_five_turns_and_four_after_sables_trial() -> void:
	assert_eq(BattleTricks.cooldown_of(_ability("wild_card")), 5, "abilities.md: 5 turns")
	EventFlags.set_flag("trial_sable_complete", true)
	assert_eq(BattleTricks.cooldown_of(_ability("wild_card")), 4, "4 once her trial is overcome")
	assert_eq(BattleTricks.cooldown_of(_ability("smokescreen")), 2, "nothing else changes")


# --- Steal abilities need the front row ---


func test_the_steal_tricks_cannot_be_used_from_the_back_row() -> void:
	_state.get_member(SABLE)["row"] = "back"
	for ability_id: String in ["filch", "ransack", "wild_card"]:
		assert_false(_usable(ability_id), "%s needs the front row" % ability_id)
	assert_false(_use("filch"), "Filch is refused from the back row")
	assert_eq(_pool(), [] as Array[String], "and steals nothing")


func test_the_other_tricks_work_from_either_row() -> void:
	_state.get_member(SABLE)["row"] = "back"
	for ability_id: String in ["smokescreen", "shiv"]:
		assert_true(_usable(ability_id), "%s works from the back row" % ability_id)


func test_the_menu_grays_the_steal_tricks_in_the_back_row_and_cooldowns() -> void:
	EventFlags.set_flag("interlude_sable_journey", true)
	_state.get_member(SABLE)["row"] = "back"
	_use("smokescreen")
	var enabled: Dictionary = {}
	var listed: Array[Dictionary] = SubmenuItems.abilities(
		{"character_id": "sable", "level": 40}, _state.get_member(SABLE)
	)
	for item: Dictionary in listed:
		enabled[item["command"]["ability"]["id"]] = item["enabled"]
	assert_false(enabled["filch"], "Filch grays in the back row")
	assert_false(enabled["ransack"], "so does Ransack")
	assert_false(enabled["smokescreen"], "Smokescreen grays while cooling down")
	assert_true(enabled["shiv"], "Shiv stays open")


# --- What is built ---


func test_every_trick_is_built_but_misdirect() -> void:
	for a: Variant in DataManager.load_abilities("sable"):
		var ability: Dictionary = a
		if ability["cost_type"] == "none":
			continue  # Unbreakable Thread is a passive, never issued
		assert_eq(
			AbilityCommand.is_built(ability),
			ability["id"] != "misdirect",
			"%s built" % ability["id"]
		)
	assert_false(_use("misdirect"), "Misdirect is refused")
	assert_eq(_state.get_member(SABLE)["current_mp"], 60, "without cost")


# --- Unbreakable Thread ---


func test_unbreakable_thread_turns_one_fatal_blow_per_battle_into_one_hp() -> void:
	EventFlags.set_flag("trial_sable_complete", true)
	_state.take_damage(EDREN, 5000)
	assert_eq(_state.get_member(EDREN)["current_hp"], 1, "Edren survives at 1 HP")
	assert_true(_state.get_member(EDREN)["is_alive"], "still standing")
	_state.take_damage(CAEL, 5000)
	assert_false(_state.get_member(CAEL)["is_alive"], "once per battle: Cael falls")


func test_unbreakable_thread_needs_sables_trial() -> void:
	_state.take_damage(EDREN, 5000)
	assert_false(_state.get_member(EDREN)["is_alive"], "not learned, no thread")


func test_unbreakable_thread_needs_sable_standing() -> void:
	EventFlags.set_flag("trial_sable_complete", true)
	_state.get_member(SABLE)["current_hp"] = 0
	_state.get_member(SABLE)["is_alive"] = false
	_state.take_damage(EDREN, 5000)
	assert_false(_state.get_member(EDREN)["is_alive"], "a fallen Sable holds no thread")


func test_unbreakable_thread_holds_sable_herself() -> void:
	EventFlags.set_flag("trial_sable_complete", true)
	_state.take_damage(SABLE, 5000)
	assert_eq(_state.get_member(SABLE)["current_hp"], 1, "Sable is an ally too")


func test_unbreakable_thread_does_not_touch_a_blow_that_is_not_fatal() -> void:
	EventFlags.set_flag("trial_sable_complete", true)
	_state.take_damage(EDREN, 300)
	assert_eq(_state.get_member(EDREN)["current_hp"], 700, "an ordinary hit lands in full")
	_state.take_damage(EDREN, 5000)
	assert_eq(_state.get_member(EDREN)["current_hp"], 1, "and the thread is still there")


func test_a_rally_of_unbreakable_is_spent_before_the_thread() -> void:
	EventFlags.set_flag("trial_sable_complete", true)
	BattleRally.start(_state, CAEL, "unbreakable", {"last_stand": true, "turns": 3})
	_state.take_damage(EDREN, 5000)
	assert_eq(_state.get_member(EDREN)["current_hp"], 1, "the Rally holds this one")
	_state.take_damage(LIRA, 5000)
	assert_eq(_state.get_member(LIRA)["current_hp"], 1, "the thread is left for the next")
