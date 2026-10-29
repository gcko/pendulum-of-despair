extends GutTest
## Edren's Bulwark reactions (GAP-002, slice 158b of #158): the heavy-hit AP
## bonus, Riposte, Shatter Guard and Oathkeeper. Stances, absorption, AP decay,
## Aegis Veil and Steadfast Resolve are test_battle_bulwark.gd.
##
## Design law: abilities.md § Edren — Bulwark and game/data/abilities/edren.json,
## read with the rulings recorded on #158: the heavy-hit bonus measures the
## whole incoming hit; Riposte is armed for 2 AP and counters the attacker of
## the next absorbed hit, once, until Edren's next turn, keeping his stance up;
## Shatter Guard needs a stance and deals its absorbed total as fixed damage;
## Oathkeeper makes every absorbed hit counter, with no arming and no cost.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const EDREN := 0
const CAEL := 1
const LIRA := 2
const MAREN := 3
## Edren's ATK in this fixture, and the strike Riposte's 1.5x is measured against.
const EDREN_ATK := 50
const ENEMY_DEF := 10


## The accessors and signals command modules reach on the battle manager.
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


## The signals the enemy turn reaches on the battle manager.
class TurnManager:
	extends Node2D
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)


var _battle: FakeBattle
var _state: Node
var _cmd: RefCounted
var _enemy: Enemy
var _hits: Array = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["edren", "cael", "lira", "maren"][slot]))
	# Edren outpaces a SPD 0 enemy, so his counters land; the enemy still hits
	# the SPD 1 allies nine times in ten.
	_state.get_member(EDREN)["effective_stats"]["spd"] = 255
	_state.get_member(LIRA)["row"] = "back"
	_state.get_member(MAREN)["row"] = "back"
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_battle.atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_battle.atb)
	_hits = []
	_battle.damage_dealt.connect(
		func(t: String, n: int, k: String) -> void: _hits.append([t, n, k])
	)
	_cmd = AbilityCommand.new(_battle)
	_enemy = _make_enemy({})
	_battle.enemies = [_enemy] as Array[Node]


func after_each() -> void:
	_cmd = null
	randomize()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _member(cid: String) -> Dictionary:
	return {
		"character_id": cid,
		"name": cid.capitalize(),
		"base_stats":
		{
			"hp": 5000,
			"mp": 40,
			"atk": EDREN_ATK,
			"def": 40,
			"mag": 20,
			"mdef": 20,
			"spd": 1,
			"lck": 0,
		},
	}


## A slow enemy that Edren's counters reliably hit, with [param extra]
## overriding its data.
func _make_enemy(extra: Dictionary) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	var data: Dictionary = {
		"name": "Brute",
		"atk": 40,
		"mag": 40,
		"spd": 0,
		"def": ENEMY_DEF,
		"mdef": 10,
		"type": "humanoid",
		"hp": 30000,
	}
	data.merge(extra, true)
	e.enemy_data = data
	e.current_hp = int(data["hp"])
	e.is_alive = true
	return e


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("edren"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("edren.json has no ability '%s'" % ability_id)
	return {}


func _use(ability_id: String, target: int = 0) -> bool:
	return _cmd.do_ability(
		"party_%d" % EDREN, {"type": "ability", "ability": _ability(ability_id), "target": target}
	)


func _ap() -> int:
	return int(_state.get_member(EDREN)["ap"])


func _set_ap(ap: int) -> void:
	_state.get_member(EDREN)["ap"] = ap


func _strike(slot: int, rng_seed: int) -> Dictionary:
	seed(rng_seed)
	return BattleActions.execute_enemy_attack(_state, _enemy, slot)


## A seed whose physical hit on [param slot] lands, found with no stance up.
func _landing_seed(slot: int) -> int:
	for s: int in range(1, 60):
		if _strike(slot, s).get("hit", false):
			return s
	fail_test("no landing seed")
	return 0


# --- Heavy-hit bonus: +1 AP when the whole hit exceeds 10% of Edren's max HP ---


func test_an_absorbed_hit_above_a_tenth_of_edren_s_max_hp_earns_two_ap() -> void:
	# Edren's 50% share is below the line; the whole hit is above it, and the
	# whole hit is what counts.
	var s: int = _landing_seed(LIRA)
	var full: int = int(_strike(LIRA, s)["damage"])
	_state.get_member(EDREN)["max_hp"] = full * 10 - 1
	_use("ironwall", LIRA)
	_strike(LIRA, s)
	assert_eq(_ap(), 2, "1 for the absorbed hit, 1 for its weight")


func test_a_hit_of_exactly_a_tenth_earns_no_bonus() -> void:
	var s: int = _landing_seed(LIRA)
	var full: int = int(_strike(LIRA, s)["damage"])
	_state.get_member(EDREN)["max_hp"] = full * 10
	_use("ironwall", LIRA)
	_strike(LIRA, s)
	assert_eq(_ap(), 1, "it must exceed 10%, not meet it")


# --- Riposte: armed for 2 AP, counters the next absorbed hit once ---


func _arm_riposte() -> void:
	_state.begin_turn(EDREN)
	_use("ironwall", LIRA)
	_state.tick_statuses(EDREN)
	_state.begin_turn(EDREN)
	_set_ap(2)
	assert_true(_use("riposte"), "Riposte is armed")
	_state.tick_statuses(EDREN)


func test_arming_riposte_costs_two_ap_and_keeps_the_stance_up() -> void:
	_arm_riposte()
	assert_eq(_ap(), 0, "2 AP paid when he arms it")
	assert_eq(_state.get_member(EDREN)["active_stance"], "ironwall", "his stance stays up")


func test_riposte_counters_the_attacker_at_one_and_a_half_times_a_basic_strike() -> void:
	var s: int = _landing_seed(LIRA)
	_arm_riposte()
	var hp: int = _enemy.current_hp
	var r: Dictionary = _strike(LIRA, s)
	assert_eq(r.get("ripostes", []).size(), 1, "one counter")
	var counter: Dictionary = r["ripostes"][0]
	assert_true(counter["hit"], "the counter landed")
	assert_eq(hp - _enemy.current_hp, int(counter["damage"]), "the attacker took it")
	# Physical formula at ability_mult 1.5 (combat-formulas.md § Physical
	# Ability Multiplier Tiers): (ATK^2 x 1.5) / 6 - DEF, times variance.
	var raw: float = EDREN_ATK * EDREN_ATK * 1.5 / 6.0 - ENEMY_DEF
	assert_between(int(counter["damage"]), int(raw * 240 / 256.0), int(raw), "1.5x, not 1.0x")


func test_a_landed_counter_earns_one_ap_on_top_of_the_absorbed_hit() -> void:
	var s: int = _landing_seed(LIRA)
	_arm_riposte()
	var r: Dictionary = _strike(LIRA, s)
	assert_true(r["ripostes"][0]["hit"], "the counter landed")
	assert_eq(_ap(), 2, "1 for the absorbed hit, 1 for the counter")


func test_riposte_counters_once() -> void:
	var s: int = _landing_seed(LIRA)
	_arm_riposte()
	_strike(LIRA, s)
	var again: Dictionary = _strike(LIRA, s)
	assert_true(again.has("absorbed"), "the second hit is still absorbed")
	assert_false(again.has("ripostes"), "but not countered")


func test_riposte_waits_for_a_hit_edren_absorbs() -> void:
	var lira: int = _landing_seed(LIRA)
	var maren: int = _landing_seed(MAREN)
	_arm_riposte()
	assert_false(_strike(MAREN, maren).has("ripostes"), "Maren is not guarded: no counter")
	assert_true(_strike(LIRA, lira).has("ripostes"), "still armed for Lira's hit")


func test_riposte_disarms_when_edren_s_next_turn_begins() -> void:
	var s: int = _landing_seed(LIRA)
	_arm_riposte()
	_state.begin_turn(EDREN)
	assert_false(_strike(LIRA, s).has("ripostes"), "armed only until his next turn")


func test_an_enemy_turn_shows_the_counter_and_reports_the_kill() -> void:
	var mgr: TurnManager = TurnManager.new()
	add_child_autofree(mgr)
	var died: Array[String] = []
	mgr.combatant_died.connect(func(id: String) -> void: died.append(id))
	var hits: Array = []
	mgr.damage_dealt.connect(func(t: String, n: int, _k: String) -> void: hits.append([t, n]))
	var area: Node2D = Node2D.new()
	add_child_autofree(area)
	var driver: BattleEnemyTurn = BattleEnemyTurn.new(mgr, _state, _battle.atb, area)
	_state.begin_turn(EDREN)
	_use("rampart")
	_state.tick_statuses(EDREN)
	_state.begin_turn(EDREN)
	_set_ap(2)
	_use("riposte")
	_state.tick_statuses(EDREN)
	_enemy.current_hp = 1
	seed(5)
	for i: int in range(40):  # until the enemy hits the back row and is countered
		if not _enemy.is_alive:
			break
		driver.execute("enemy_0", _battle.enemies, false, i)
	assert_false(_enemy.is_alive, "the counter felled the attacker")
	assert_has(died, "enemy_0", "and the battle heard of it")
	var on_enemy: Array = hits.filter(func(h: Array) -> bool: return h[0] == "enemy_0")
	assert_eq(on_enemy.size(), 1, "with a number over the enemy")


# --- Shatter Guard: the stance's absorbed total, as fixed damage ---


func test_shatter_guard_needs_a_stance_and_costs_nothing_without_one() -> void:
	_set_ap(5)
	assert_false(AbilityCommand.is_available(_state.get_member(EDREN), _ability("shatter_guard")))
	assert_false(_use("shatter_guard"), "refused without a stance")
	assert_eq(_ap(), 5, "nothing spent")


func test_shatter_guard_deals_the_absorbed_total_to_every_enemy_and_ends_the_stance() -> void:
	# Fixed damage: neither DEF nor a Spirit's physical halving touches it. DEF
	# 999 also puts the basic-attack floor at 1, below the total.
	_enemy = _make_enemy({"def": 999})
	var spirit: Enemy = _make_enemy({"type": "spirit", "def": 999})
	_battle.enemies = [_enemy, spirit] as Array[Node]
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	var total: int = 0
	for _i: int in range(2):
		total += int(_strike(LIRA, s)["absorbed"]["damage"])
	assert_gt(total, 1, "the total is above the floor")
	_set_ap(5)
	var before: Array[int] = [_enemy.current_hp, spirit.current_hp]
	assert_true(_use("shatter_guard"), "resolves")
	assert_eq(before[0] - _enemy.current_hp, total, "the humanoid takes the total")
	assert_eq(before[1] - spirit.current_hp, total, "so does a DEF 999 spirit")
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "the stance is broken")
	assert_eq(_ap(), 0, "5 AP spent")
	assert_eq(_hits.filter(func(h: Array) -> bool: return h[1] == total).size(), 2, "two numbers")


func test_shatter_guard_is_capped_at_twice_edren_s_max_hp() -> void:
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	for _i: int in range(3):
		_strike(LIRA, s)
	_state.get_member(EDREN)["max_hp"] = 40
	_set_ap(5)
	var hp: int = _enemy.current_hp
	_use("shatter_guard")
	assert_eq(hp - _enemy.current_hp, 80, "2 x max HP 40")


func test_re_raising_a_stance_resets_the_absorbed_total() -> void:
	var s: int = _landing_seed(LIRA)
	var tough: Enemy = _make_enemy({"def": 999})  # basic-attack floor of 1
	_battle.enemies = [tough] as Array[Node]
	_use("ironwall", LIRA)
	_strike(LIRA, s)
	_use("ironwall", LIRA)
	_set_ap(5)
	var hp: int = tough.current_hp
	_use("shatter_guard")
	assert_eq(hp - tough.current_hp, 1, "the earlier absorb no longer counts: the floor")


# --- Oathkeeper: stronger stances, automatic Riposte, a second Attack ---


func test_oathkeeper_s_numbers_match_the_shipped_data() -> void:
	var data: Dictionary = _ability("oathkeeper")
	var o: Dictionary = Bulwark.OATHKEEPER
	assert_eq(o["absorption_bonus_pct"], int(data["absorption_bonus_pct"]), "+50% absorption")
	assert_eq(o["attack_hits"], int(data["attack_hits"]), "two hits")
	assert_eq(o["turns"], int(data["duration_turns"]), "3 turns")
	assert_eq(float(data["attack_ability_mult"]), 1.0, "each a plain basic attack")


func test_oathkeeper_costs_eight_ap_and_raises_ironwall_to_75_and_rampart_to_45() -> void:
	# combat-formulas.md § Damage Reduction Sources: 75% and 45% with Oathkeeper.
	_set_ap(8)
	assert_true(_use("oathkeeper"), "resolves")
	assert_eq(_ap(), 0, "8 AP spent")
	_use("ironwall", LIRA)
	assert_eq(Bulwark.guard_for(_state, LIRA, "physical")["pct"], 75, "Ironwall 75%")
	_use("rampart")
	assert_eq(Bulwark.guard_for(_state, LIRA, "magic")["pct"], 45, "Rampart 45%")


func test_under_oathkeeper_every_absorbed_hit_counters_for_free() -> void:
	var s: int = _landing_seed(LIRA)
	_set_ap(8)
	_use("oathkeeper")
	_use("ironwall", LIRA)
	for i: int in range(3):
		var r: Dictionary = _strike(LIRA, s)
		assert_eq(r.get("ripostes", []).size(), 1, "hit %d is countered, unarmed" % i)
	assert_eq(_ap(), 6, "no AP spent on counters: 1 per absorb and 1 per landed counter")


func test_oathkeeper_lasts_three_of_edren_s_turns_after_the_one_he_uses_it_on() -> void:
	_state.begin_turn(EDREN)
	_set_ap(8)
	_use("oathkeeper")
	for _i: int in range(3):
		_state.tick_statuses(EDREN)
		_state.begin_turn(EDREN)
	_use("ironwall", LIRA)
	assert_eq(Bulwark.guard_for(_state, LIRA, "physical")["pct"], 75, "still in force")
	_state.tick_statuses(EDREN)
	_use("ironwall", LIRA)
	assert_eq(Bulwark.guard_for(_state, LIRA, "physical")["pct"], 50, "lapsed")


func test_under_oathkeeper_the_attack_command_hits_twice() -> void:
	var actions: BattlePlayerActions = BattlePlayerActions.new(_battle)
	seed(9)
	actions.do_attack("party_%d" % EDREN, {"type": "attack", "target": 0})
	assert_eq(_hits.size(), 1, "one swing without Oathkeeper")
	_hits.clear()
	_set_ap(8)
	_use("oathkeeper")
	_hits.clear()
	actions.do_attack("party_%d" % EDREN, {"type": "attack", "target": 0})
	assert_eq(_hits.size(), 2, "two Attack-command hits under it")
	assert_true(_hits.all(func(h: Array) -> bool: return h[0] == "enemy_0"), "on the target")


func test_choosing_riposte_arms_it_without_an_enemy_target_cursor() -> void:
	# Riposte is a reaction that counters whoever hits Edren next
	# (abilities.md § Edren — Bulwark), so the menu asks for no target.
	var menu: Node = preload("res://scripts/ui/battle_command_menu.gd").new()
	add_child_autofree(menu)
	menu.show_commands(
		{"character_id": "edren", "level": 10},
		false,
		{"ap": 2, "is_alive": true, "active_statuses": []}
	)
	menu._cursor = 2  # Attack, Magic, Ability, ...
	menu._confirm_command()
	var idx: int = (menu._submenu_items as Array).find_custom(
		func(item: Dictionary) -> bool:
			return item.get("command", {}).get("ability", {}).get("id", "") == "riposte"
	)
	assert_gt(idx, -1, "Riposte is on Edren's list at level 10")
	menu._submenu_cursor = idx
	watch_signals(menu)
	var accept: InputEventAction = InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	menu._handle_submenu_input(accept)
	assert_signal_not_emitted(menu, "target_changed", "no target cursor opened")
	assert_signal_emitted(menu, "command_selected", "chosen straight from the list")
	_set_ap(2)
	var cmd: Dictionary = get_signal_parameters(menu, "command_selected")[0]
	assert_true(_cmd.do_ability("party_%d" % EDREN, cmd), "and the command arms Riposte")
	assert_eq(_ap(), 0, "2 AP paid on arming")
