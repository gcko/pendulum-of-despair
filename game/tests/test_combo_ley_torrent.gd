extends GutTest
## Ley Torrent, the first combo built (#176 slice b), driven through the real
## battle scene the way a player calls it: Maren is prompted, Torren's gauge is
## full beside hers, and the battle UI submits the Combo command.
##
## abilities.md § Combo List, row 7: Maren + Torren, 18 MP (10/8), "(Maren's Magic +
## Torren's Magic) x 4. Ignores Magic Defense. Generates 30 WG for Maren."
## Readings for 176b (#176, abilities.md § 2): a combo uses both characters'
## turns, so both gauges reset and each one's start-of-turn effects and
## end-of-turn ticks run once; MP splits per mp_costs; the blast goes through
## the magic formula with the target's MDEF taken as 0, the standard hit roll
## and variance; Maren's 30 WG replaces the cast gain; and each partner's
## Despair cuts it.
##
## Stats are pinned so the numbers read cleanly. Maren's MAG is 40 and Torren's
## 60, so the blast's nominal damage is (40 + 60) x 4 = 400 before the 240-255
## /256 variance: 375 to 398. The enemy's MDEF is 500, so a blast that kept it
## would floor at 1. Maren is fast and the enemy slow, so the hit roll is 99%
## and evasion 0%; HIT_SEED makes the 99% land.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")

const EDREN := 0
const CAEL := 1
const MAREN := 2
const TORREN := 3
const MAREN_MAG := 40
const TORREN_MAG := 60
const START_MP := 50
const ENEMY_HP := 99999
const HIT_SEED := 12345
const LEY_TORRENT: Dictionary = {"type": "combo", "combo_id": "ley_torrent"}


## A BattleState whose turn-start effects can be told to KO a member or fell
## every enemy, standing in for a turn-start effect (a Shock Coil) that decides
## something before the combo lands.
class TurnStartState:
	extends "res://scripts/combat/battle_state.gd"
	var fells_slot: int = -1
	var fells_enemies: Array[Node] = []

	func begin_turn(slot: int) -> Array:
		if slot == fells_slot:
			take_damage(slot, 999999)
		for e: Node in fells_enemies:
			e.take_damage(999999)
		return super(slot)


## The accessors and signals BattleComboCommand reaches on the battle manager.
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

	func emit_party_events(_events: Array) -> void:
		pass


var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	seed(HIT_SEED)


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


# ── helpers ─────────────────────────────────────────────────────────────


## A battle with Edren, Cael, Maren and Torren against one sturdy, slow,
## MDEF-heavy Ley Vermin, driven frame by frame by hand.
func _boot() -> Node:
	PartyState.initialize_new_game()
	PartyState.add_member("maren")
	PartyState.add_member("torren")
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
	battle.set_process(false)
	_booted = battle
	var state: Node = battle.get_battle_state()
	for slot: int in [MAREN, TORREN]:
		var m: Dictionary = state.get_member(slot)
		m["current_mp"] = START_MP
		m["effective_stats"]["mag"] = MAREN_MAG if slot == MAREN else TORREN_MAG
		m["effective_stats"]["spd"] = 255 if slot == MAREN else 10
	var enemy: Node = battle.get_enemies()[0]
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["mdef"] = 500
	data["spd"] = 0
	data["hp"] = ENEMY_HP
	enemy.enemy_data = data
	enemy.current_hp = ENEMY_HP
	return battle


## Prompt Maren, fill Torren's gauge beside hers, and call Ley Torrent.
func _call_ley_torrent(battle: Node) -> void:
	_prompt_maren(battle)
	battle.get_atb().set_gauge("party_%d" % TORREN, ATBSystem.GAUGE_MAX)
	battle.get_node("BattleUI").command_submitted.emit(LEY_TORRENT)


func _prompt_maren(battle: Node) -> void:
	battle.get_atb().set_gauge("party_%d" % MAREN, ATBSystem.GAUGE_MAX)
	battle._process(0.0)
	assert_eq(battle.get("_awaiting_input_for"), "party_%d" % MAREN, "precondition: Maren's turn")


func _status(member: Dictionary, status_name: String) -> Dictionary:
	for s: Dictionary in member["active_statuses"]:
		if s["name"] == status_name:
			return s
	return {}


func _dealt(battle: Node) -> int:
	return ENEMY_HP - int(battle.get_enemies()[0].current_hp)


## The variance band around [param nominal] (DamageCalc.roll_variance).
func _assert_band(dmg: int, nominal: float, why: String) -> void:
	assert_between(dmg, int(nominal * 240.0 / 256.0), int(nominal * 255.0 / 256.0), why)


# ── cost and turns ──────────────────────────────────────────────────────


func test_ley_torrent_spends_each_partner_s_own_share_of_mp() -> void:
	var battle: Node = _boot()
	_call_ley_torrent(battle)
	var state: Node = battle.get_battle_state()
	assert_eq(state.get_member(MAREN)["current_mp"], START_MP - 10, "Maren pays 10")
	assert_eq(state.get_member(TORREN)["current_mp"], START_MP - 8, "Torren pays 8")


func test_ley_torrent_uses_both_turns() -> void:
	var battle: Node = _boot()
	_call_ley_torrent(battle)
	assert_eq(battle.get_atb().get_gauge("party_%d" % MAREN), 0, "Maren's gauge resets")
	assert_eq(battle.get_atb().get_gauge("party_%d" % TORREN), 0, "and so does Torren's")
	assert_eq(battle.get("_awaiting_input_for"), "", "nobody is left waiting on a command")


func test_each_partner_s_end_of_turn_ticks_run_once() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	for slot: int in [MAREN, TORREN]:
		state.apply_status(slot, "poison", "turns", 3)
	var hp: Array[int] = [
		state.get_member(MAREN)["current_hp"], state.get_member(TORREN)["current_hp"]
	]
	_call_ley_torrent(battle)
	var i: int = 0
	for slot: int in [MAREN, TORREN]:
		var m: Dictionary = state.get_member(slot)
		var tick: int = maxi(1, int(m["max_hp"] * 0.08))
		assert_eq(m["current_hp"], hp[i] - tick, "slot %d takes one Poison tick" % slot)
		var poison: Dictionary = _status(m, "poison")
		assert_eq(poison["remaining_turns"], 2, "slot %d's Poison counts down once" % slot)
		i += 1


func test_the_partner_s_start_of_turn_effects_run_once() -> void:
	# Second Wind restores 5% of max HP as each ally's turn begins.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.take_damage(TORREN, 40)
	var before: int = state.get_member(TORREN)["current_hp"]
	var regen: int = state.get_member(TORREN)["max_hp"] * 5 / 100
	BattleRally.start(state, CAEL, "second_wind", AbilityCommand.RALLY_EFFECTS["second_wind"])
	_call_ley_torrent(battle)
	assert_eq(state.get_member(TORREN)["current_hp"], before + regen, "Torren's turn began")


# ── the blast ───────────────────────────────────────────────────────────


func test_ley_torrent_deals_both_partners_magic_times_four_ignoring_mdef() -> void:
	var battle: Node = _boot()
	_call_ley_torrent(battle)
	_assert_band(_dealt(battle), (MAREN_MAG + TORREN_MAG) * 4.0, "(40 + 60) x 4 through MDEF 500")


func test_despair_on_either_partner_cuts_the_blast_and_on_both_cuts_it_twice() -> void:
	var nominal: float = (MAREN_MAG + TORREN_MAG) * 4.0
	var battle: Node = _boot()
	battle.get_battle_state().apply_status(TORREN, "despair", "turns", 5)
	_call_ley_torrent(battle)
	_assert_band(_dealt(battle), nominal * 0.8, "Torren's Despair: -20%")
	_booted.set("_battle_active", false)
	_booted.free()
	seed(HIT_SEED)
	battle = _boot()
	for slot: int in [MAREN, TORREN]:
		battle.get_battle_state().apply_status(slot, "despair", "turns", 5)
	_call_ley_torrent(battle)
	_assert_band(_dealt(battle), nominal * 0.8 * 0.8, "both Despaired: 0.8 x 0.8")


func test_maren_gains_thirty_weave_gauge_in_place_of_the_cast_gain() -> void:
	var battle: Node = _boot()
	_call_ley_torrent(battle)
	assert_gt(_dealt(battle), 0, "precondition: the blast landed")
	assert_eq(battle.get_battle_state().get_member(MAREN)["wg"], 30, "30, not 30 + 5 + 10")


# ── refusals ────────────────────────────────────────────────────────────


func test_a_partner_confused_after_the_prompt_stops_the_combo_and_costs_nothing() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	_prompt_maren(battle)
	battle.get_atb().set_gauge("party_%d" % TORREN, ATBSystem.GAUGE_MAX)
	state.apply_status(TORREN, "confusion", "turns", 3)
	battle.get_node("BattleUI").command_submitted.emit(LEY_TORRENT)
	assert_eq(state.get_member(MAREN)["current_mp"], START_MP, "Maren pays nothing")
	assert_eq(state.get_member(TORREN)["current_mp"], START_MP, "nor does Torren")
	assert_eq(_dealt(battle), 0, "no blast")
	assert_eq(battle.get("_awaiting_input_for"), "party_%d" % MAREN, "Maren chooses again")


func test_a_combo_whose_partners_cannot_pay_is_refused() -> void:
	var battle: Node = _boot()
	battle.get_battle_state().get_member(TORREN)["current_mp"] = 7
	var said: Array[String] = []
	battle.message.connect(func(text: String) -> void: said.append(text))
	_call_ley_torrent(battle)
	assert_has(said, "Not enough MP!", "the player is told why")
	assert_eq(battle.get_battle_state().get_member(MAREN)["current_mp"], START_MP, "nothing spent")
	assert_eq(battle.get_atb().get_gauge("party_%d" % TORREN), ATBSystem.GAUGE_MAX, "Torren waits")


# ── turn start and the open menu ────────────────────────────────────────


## Maren (slot 0) and Torren (slot 1) on full gauges with 50 MP each, against
## one enemy, in a battle whose turn starts [param state] decides.
func _fake(state: Node) -> FakeBattle:
	var battle: FakeBattle = FakeBattle.new()
	add_child_autofree(battle)
	add_child_autofree(state)
	battle.state = state
	battle.atb = ATBSystem.new()
	add_child_autofree(battle.atb)
	for slot: int in range(2):
		var cid: String = ["maren", "torren"][slot]
		state.add_member(
			slot, {"character_id": cid, "level": 1, "base_stats": {"hp": 100, "mp": 50}}
		)
		battle.atb.add_combatant("party_%d" % slot, 10, false)
		battle.atb.set_gauge("party_%d" % slot, ATBSystem.GAUGE_MAX)
	var enemy: Node = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.enemy_data = {"name": "Brute", "hp": 500, "spd": 0, "mdef": 0, "type": "humanoid"}
	enemy.current_hp = 500
	enemy.is_alive = true
	battle.enemies = [enemy] as Array[Node]
	return battle


func test_a_partner_felled_by_their_turn_start_stops_the_combo_and_costs_nothing() -> void:
	var state: TurnStartState = TurnStartState.new()
	state.fells_slot = 1
	var battle: FakeBattle = _fake(state)
	var done: bool = BattleComboCommand.new(battle).do_combo("party_0", LEY_TORRENT)
	assert_false(done, "Torren fell as his turn began")
	assert_eq(state.get_member(0)["current_mp"], 50, "Maren pays nothing")
	assert_eq(battle.enemies[0].current_hp, 500, "and no blast lands")


func test_a_turn_start_that_ends_the_battle_stops_the_combo_and_costs_nothing() -> void:
	var state: TurnStartState = TurnStartState.new()
	var battle: FakeBattle = _fake(state)
	state.fells_enemies = battle.enemies
	var done: bool = BattleComboCommand.new(battle).do_combo("party_0", LEY_TORRENT)
	assert_false(done, "the last enemy fell as Torren's turn began")
	assert_eq(state.get_member(0)["current_mp"], 50, "Maren pays nothing")
	assert_eq(state.get_member(1)["current_mp"], 50, "nor does Torren")


func test_a_partner_who_fills_while_the_menu_is_open_joins_the_combo_list() -> void:
	var battle: Node = _boot()
	_prompt_maren(battle)
	var menu: Node = battle.get_node("BattleUI/CommandMenu")
	assert_false(menu._commands[3]["enabled"], "precondition: Torren is still filling")
	battle.get_atb().set_gauge("party_%d" % TORREN, ATBSystem.GAUGE_MAX)
	battle.get_node("BattleUI")._process(0.0)
	assert_true(menu._commands[3]["enabled"], "Combo opens once Torren is ready")
	menu._cursor = 3
	menu._confirm_command()
	var chosen: Dictionary = menu._submenu_items[menu._submenu_cursor]
	assert_eq(chosen["command"]["combo_id"], "ley_torrent", "and lists Ley Torrent")
	assert_true(chosen["enabled"], "selectable")
