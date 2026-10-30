extends GutTest
## Sable's Tricks that strike or hinder (GAP-002, slice 158d of #158): Shiv and
## its thrown item, Wild Card's four branches, and Smokescreen. Stealing, the
## pool, cooldowns and the front-row gate are test_battle_tricks.gd.
##
## Design law: abilities.md § Sable — Tricks and § Damage Magnitudes, items.md
## § Thrown-Item Elements, combat-formulas.md § Special: Shiv. Reading 1 on #447:
## Wild Card's element comes from the most recently stolen elemental item held,
## and with none the strike is non-elemental.
##
## Sable is fast (SPD 100) and every enemy slow (SPD 0), so her hit rate is 99,
## the enemies' evasion 0, and with LCK 0 nothing crits.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const SABLE := 0
const EDREN := 1
const CAEL := 2
const LIRA := 3

## Sable's ATK. A 1.0 strike is 100^2 / 6 = 1,666 before DEF.
const ATK := 100

## Wild Card's random debuff list, abilities.md § Sable — Tricks.
const DEBUFFS: Array[String] = ["poison", "sleep", "silence", "blind", "slow"]

## Every element an item in items.md § Thrown-Item Elements can throw.
const THROWN_ELEMENTS: Array[String] = ["flame", "spirit", "storm", "void", "ley"]


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
var _hits: Array = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	seed(447)
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["sable", "edren", "cael", "lira"][slot]))
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
	_battle.enemies = [_make_enemy({}), _make_enemy({})] as Array[Node]


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
			"atk": ATK,
			"def": 40,
			"mag": 40,
			"mdef": 20,
			"spd": 100,
			"lck": 0,
		},
	}


func _make_enemy(extra: Dictionary) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	var data: Dictionary = {
		"name": "Mark",
		"atk": 40,
		"mag": 40,
		"spd": 0,
		"def": 0,
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
	for a: Variant in DataManager.load_abilities("sable"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("sable.json has no ability '%s'" % ability_id)
	return {}


## Put [param items] in Sable's Stolen Goods, oldest first, as stealing them would.
func _hold(items: Array[String]) -> void:
	for item_id: String in items:
		BattleTricks.add_goods(_state, SABLE, item_id)


func _use(ability_id: String, command: Dictionary = {}) -> bool:
	var cmd: Dictionary = {"type": "ability", "ability": _ability(ability_id), "target": 0}
	cmd.merge(command, true)
	_state.begin_turn(SABLE)
	var ok: bool = _cmd.do_ability("party_%d" % SABLE, cmd)
	_state.tick_statuses(SABLE)
	return ok


## Sable's Tricks menu as the battle lists it.
func _menu() -> Array[Dictionary]:
	return preload("res://scripts/ui/battle_submenu_items.gd").abilities(
		{"character_id": "sable", "level": 40}, _state.get_member(SABLE)
	)


## The [amount, type] events that landed on enemy [param idx].
func _on_enemy(idx: int) -> Array:
	var out: Array = []
	for h: Array in _hits:
		if h[0] == "enemy_%d" % idx:
			out.append([h[1], h[2]])
	return out


func _damage_to(idx: int) -> int:
	return 30000 - int(_battle.enemies[idx].current_hp)


func _stock(item_id: String) -> int:
	return (
		int(PartyState.get_materials().get(item_id, 0))
		+ int(PartyState.get_consumables().get(item_id, 0))
	)


## The one status of DEBUFFS on [param enemy], or "" when it has none.
func _debuff_on(enemy: Enemy) -> String:
	var found: String = ""
	for status: String in DEBUFFS:
		if enemy.has_status(status):
			assert_eq(found, "", "one debuff, not two")
			found = status
	return found


# --- Shiv ---


func test_shiv_ignores_half_the_targets_defense() -> void:
	_battle.enemies = [_make_enemy({"def": 1000})] as Array[Node]
	assert_true(_use("shiv"), "Shiv issued")
	# 1,666 - 500 = 1,166 before variance; a basic attack would be 1,666 - 1,000 = 666.
	assert_between(_damage_to(0), 1093, 1166, "DEF 1000 counts as 500")


func test_a_bare_shiv_carries_no_element_even_with_an_elemental_weapon() -> void:
	PartyState.add_member("sable", 40)
	PartyState.get_member("sable")["equipment"]["weapon"] = "shade_razor"  # Void
	_battle.enemies = [_make_enemy({"absorb": ["void"]})] as Array[Node]
	assert_true(_use("shiv"), "Shiv issued")
	assert_eq(_on_enemy(0)[0][1], "physical", "the weapon's Void is not Shiv's")


func test_a_thrown_item_re_elements_the_shiv_and_is_consumed() -> void:
	_hold(["emberstone"])
	_battle.enemies = [_make_enemy({"absorb": ["flame"]})] as Array[Node]
	assert_true(_use("shiv", {"throw_item": "emberstone"}), "Shiv throws the Emberstone")
	assert_eq(_on_enemy(0)[0][1], "absorb", "a Flame throw is absorbed by a Flame sponge")
	assert_eq(BattleTricks.goods(_state, SABLE), [] as Array[String], "the item is gone")
	assert_eq(_stock("emberstone"), 0, "from the inventory too")


func test_a_non_elemental_throw_is_a_bare_shiv() -> void:
	_hold(["potion"])
	_battle.enemies = [_make_enemy({"def": 1000, "absorb": THROWN_ELEMENTS})] as Array[Node]
	assert_true(_use("shiv", {"throw_item": "potion"}), "Shiv throws the Potion")
	assert_eq(_on_enemy(0)[0][1], "physical", "a Potion carries no element")
	assert_between(_damage_to(0), 1093, 1166, "the same hit, DEF still halved")
	assert_eq(_stock("potion"), 0, "consumed either way")


func test_shiv_cannot_throw_an_item_sable_does_not_hold() -> void:
	assert_false(_use("shiv", {"throw_item": "emberstone"}), "nothing to throw")
	assert_eq(_damage_to(0), 0, "no hit")


func test_the_menu_offers_each_held_item_as_a_throw() -> void:
	_hold(["emberstone", "potion", "emberstone"])
	var throws: Array[String] = []
	for item: Dictionary in _menu():
		var thrown: String = item["command"].get("throw_item", "")
		if not thrown.is_empty():
			throws.append(thrown)
			assert_true(item["enabled"], "%s can be thrown" % thrown)
	assert_eq(throws, ["emberstone", "potion"] as Array[String], "one entry per item held")


func test_the_menu_drops_a_throw_for_an_item_the_party_used() -> void:
	_hold(["potion"])
	PartyState.consume_item("potion")  # an ally drank the stolen Potion
	for item: Dictionary in _menu():
		assert_eq(
			item["command"].get("throw_item", ""), "", "no throw is offered: %s" % item["label"]
		)


func test_wild_card_asks_for_one_enemy_once_the_held_item_is_used() -> void:
	EventFlags.set_flag("interlude_party_reassembled", true)  # Wild Card is learned
	_hold(["potion"])
	PartyState.consume_item("potion")
	var target: String = ""
	for item: Dictionary in _menu():
		if item["command"]["ability"]["id"] == "wild_card":
			target = item["target_type"]
	assert_ne(target, "", "Wild Card is listed")
	assert_eq(target, "single_enemy", "nothing is held, so the 0-item strike picks a target")


func test_a_throw_reads_its_element_from_the_field_shivs_data_names() -> void:
	_hold(["emberstone"])
	_battle.enemies = [_make_enemy({"absorb": ["flame"]})] as Array[Node]
	var shiv: Dictionary = _ability("shiv").duplicate(true)
	shiv["thrown_item_element_field"] = "no_such_field"
	_state.begin_turn(SABLE)
	_cmd.do_ability(
		"party_%d" % SABLE,
		{"type": "ability", "ability": shiv, "target": 0, "throw_item": "emberstone"}
	)
	assert_eq(_on_enemy(0)[0][1], "physical", "a field no item carries throws non-elemental")


func test_wild_card_reads_its_element_field_from_the_data() -> void:
	_hold(["emberstone"])
	_battle.enemies = [_make_enemy({"absorb": ["flame"]})] as Array[Node]
	var wild: Dictionary = _ability("wild_card").duplicate(true)
	wild["item_branch_element_field"] = "no_such_field"
	_state.begin_turn(SABLE)
	_cmd.do_ability("party_%d" % SABLE, {"type": "ability", "ability": wild, "target": 0})
	assert_eq(_on_enemy(0)[0][1], "physical", "a field no item carries is non-elemental")


# --- Wild Card: four branches by Stolen Goods ---


func test_wild_card_with_no_items_strikes_one_enemy_at_double_attack() -> void:
	assert_true(_use("wild_card", {"target": 1}), "Wild Card issued")
	assert_eq(_damage_to(0), 0, "the other enemy is untouched")
	# 100^2 x 2.0 / 6 = 3,333 before variance.
	assert_between(_damage_to(1), 3124, 3333, "ability_mult 2.0")


func test_wild_card_with_one_item_strikes_every_enemy_with_its_element() -> void:
	_hold(["emberstone"])
	_battle.enemies = [_make_enemy({}), _make_enemy({"absorb": ["flame"]})] as Array[Node]
	assert_true(_use("wild_card"), "Wild Card issued")
	assert_between(_damage_to(0), 3124, 3333, "every enemy, still at 2.0")
	assert_eq(_on_enemy(1)[0][1], "absorb", "carrying the Emberstone's Flame")
	assert_eq(_debuff_on(_battle.enemies[0]), "", "one item adds no debuff")
	assert_eq(BattleTricks.goods(_state, SABLE), [] as Array[String], "the item is consumed")


func test_wild_card_with_two_items_takes_the_newest_elemental_and_a_shared_debuff() -> void:
	_hold(["emberstone", "spirit_dust"])  # Flame, then Spirit
	_battle.enemies = (
		[_make_enemy({"absorb": ["spirit"]}), _make_enemy({"absorb": ["flame"]})] as Array[Node]
	)
	assert_true(_use("wild_card"), "Wild Card issued")
	assert_eq(_on_enemy(0)[0][1], "absorb", "Spirit, the last stolen, is the element")
	assert_eq(_on_enemy(1)[0][1], "physical", "the older Flame is not")
	var debuff: String = _debuff_on(_battle.enemies[0])
	assert_true(debuff in DEBUFFS, "a debuff from the list landed: %s" % debuff)
	assert_eq(_debuff_on(_battle.enemies[1]), debuff, "the same one on every enemy")


func test_wild_card_skips_a_newer_non_elemental_item_for_the_element() -> void:
	_hold(["emberstone", "potion"])
	_battle.enemies = [_make_enemy({"absorb": ["flame"]})] as Array[Node]
	assert_true(_use("wild_card"), "Wild Card issued")
	assert_eq(_on_enemy(0)[0][1], "absorb", "the Potion confers nothing; the Emberstone does")


func test_wild_card_with_no_elemental_item_is_non_elemental() -> void:
	_hold(["potion", "beast_hide"])
	_battle.enemies = [_make_enemy({"absorb": THROWN_ELEMENTS})] as Array[Node]
	assert_true(_use("wild_card"), "Wild Card issued")
	assert_eq(_on_enemy(0)[0][1], "physical", "nothing to absorb")


func test_wild_card_with_three_items_is_heavy_and_heals_the_party() -> void:
	_hold(["spirit_dust", "emberstone", "potion"])
	_battle.enemies = (
		[_make_enemy({"absorb": ["flame"]}), _make_enemy({"absorb": ["spirit"]})] as Array[Node]
	)
	for slot: int in range(4):
		_state.take_damage(slot, 500)
	assert_true(_use("wild_card"), "Wild Card issued")
	assert_eq(_on_enemy(0)[0][1], "absorb", "Emberstone is the newest elemental")
	# 100^2 x 3.0 / 6 = 5,000 before variance.
	assert_between(_damage_to(1), 4687, 5000, "ability_mult 3.0")
	assert_true(_debuff_on(_battle.enemies[1]) in DEBUFFS, "and a debuff")
	for slot: int in range(4):
		assert_eq(_state.get_member(slot)["current_hp"], 600, "10%% of max HP back: slot %d" % slot)
	assert_eq(BattleTricks.goods(_state, SABLE), [] as Array[String], "all three consumed")
	for item_id: String in ["spirit_dust", "emberstone", "potion"]:
		assert_eq(_stock(item_id), 0, "%s left the inventory" % item_id)


# --- Smokescreen ---


func test_smokescreen_cuts_every_enemys_accuracy_by_thirty_percent_for_two_turns() -> void:
	assert_true(_use("smokescreen"), "Smokescreen issued")
	for enemy: Node in _battle.enemies:
		assert_almost_eq(BattleDamageMods.accuracy_mult(enemy), 0.7, 0.0001, "-30% to hit")
	var e: Enemy = _battle.enemies[0]
	e.tick_buffs()
	assert_almost_eq(BattleDamageMods.accuracy_mult(e), 0.7, 0.0001, "after one of its turns")
	e.tick_buffs()
	assert_almost_eq(BattleDamageMods.accuracy_mult(e), 1.0, 0.0001, "gone after two")


func test_smokescreen_stacks_with_blind_on_the_enemy() -> void:
	_use("smokescreen")
	var e: Enemy = _battle.enemies[0]
	e.apply_status("blind", 4)
	assert_almost_eq(BattleDamageMods.accuracy_mult(e), 0.35, 0.0001, "0.5 x 0.7")


# --- The table is the doc ---


func test_wild_card_names_its_element_rule_in_the_data() -> void:
	## Reading 1 on #447: the most recently stolen item that has an element.
	assert_eq(
		String(_ability("wild_card").get("item_branch_element_pick", "")), "most_recent_elemental"
	)


func test_the_trick_magnitudes_match_the_shipped_effect_text() -> void:
	var smoke: String = _ability("smokescreen")["effect"]
	var pct: int = roundi((1.0 - float(BattleTricks.SMOKESCREEN["accuracy_mult"])) * 100.0)
	assert_string_contains(smoke, "accuracy by %d%%" % pct)
	assert_string_contains(smoke, "for %d turns" % int(BattleTricks.SMOKESCREEN["turns"]))
	var wild: String = _ability("wild_card")["effect"]
	assert_string_contains(wild, "restores %d%% HP" % int(BattleTricks.WILD_CARD["heal_pct"]))
	for status: String in BattleTricks.WILD_CARD["debuffs"]:
		assert_string_contains(wild, status.capitalize())
	assert_eq(Array(BattleTricks.WILD_CARD["debuffs"]), Array(DEBUFFS), "the five, no more")
	assert_string_contains(_ability("ransack")["effect"], "%d%%" % BattleTricks.RANSACK_RATE_PCT)
