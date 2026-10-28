extends GutTest
## Edren's Bulwark (GAP-002, slice 158b of #158): stances that absorb damage
## meant for allies, the Aegis Points that absorbing earns, and the Bulwark
## abilities that spend them.
##
## Design law: abilities.md § Edren — Bulwark, combat-formulas.md § Damage
## Reduction Sources (with its note on absorption against flat reduction), and
## game/data/abilities/edren.json. Magnitudes are read from BattleBulwark's
## tables and those tables are held to the data's effect text, so neither can
## move without the other.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")

const EDREN := 0
const CAEL := 1
const LIRA := 2
const MAREN := 3


## The accessors and signals a command module reaches on the battle manager.
class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	var state: Node

	func get_battle_state() -> Node:
		return state


## An enemy fast enough that its hits all but always land, and light enough
## that none exceeds a tenth of Edren's max HP (no heavy-hit bonus AP).
class FakeEnemy:
	extends Node
	var is_alive: bool = true

	func get_stats() -> Dictionary:
		return {"atk": 40, "mag": 60, "spd": 255}


var _battle: FakeBattle
var _state: Node
var _cmd: RefCounted
var _enemy: FakeEnemy
var _messages: Array[String] = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	_state = BattleState.new()
	add_child_autofree(_state)
	_state.add_member(EDREN, _member("edren", "Edren"))
	_state.add_member(CAEL, _member("cael", "Cael"))
	_state.add_member(LIRA, _member("lira", "Lira"))
	_state.add_member(MAREN, _member("maren", "Maren"))
	_state.get_member(LIRA)["row"] = "back"
	_state.get_member(MAREN)["row"] = "back"
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_messages = []
	_battle.message.connect(func(t: String) -> void: _messages.append(t))
	_cmd = AbilityCommand.new(_battle)
	_enemy = FakeEnemy.new()
	add_child_autofree(_enemy)


func after_each() -> void:
	_cmd = null
	randomize()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _member(cid: String, nm: String) -> Dictionary:
	return {
		"character_id": cid,
		"name": nm,
		"base_stats":
		{"hp": 5000, "mp": 40, "atk": 50, "def": 40, "mag": 20, "mdef": 20, "spd": 1, "lck": 8},
	}


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("edren"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("edren.json has no ability '%s'" % ability_id)
	return {}


## Edren issues [param ability_id], at the party slot [param target] when it
## takes one.
func _use(ability_id: String, target: int = 0) -> bool:
	return _cmd.do_ability(
		"party_%d" % EDREN, {"type": "ability", "ability": _ability(ability_id), "target": target}
	)


func _hp(slot: int) -> int:
	return int(_state.get_member(slot)["current_hp"])


func _ap() -> int:
	return int(_state.get_member(EDREN)["ap"])


## One enemy hit of [param kind] ("physical" or "magic") on [param slot] under
## [param rng_seed]. The same seed gives the same rolls, so a guarded hit can be
## compared with the unguarded one exactly.
func _strike(slot: int, kind: String, rng_seed: int) -> Dictionary:
	seed(rng_seed)
	if kind == "magic":
		return BattleActions.execute_enemy_magic(_state, _enemy, slot, "", 20)
	return BattleActions.execute_enemy_attack(_state, _enemy, slot)


## A seed under which a [param kind] hit on [param slot] lands, found without
## any stance up (it does land damage on [param slot], whose HP is deep).
func _landing_seed(slot: int, kind: String) -> int:
	for s: int in range(1, 60):
		if _strike(slot, kind, s).get("hit", false):
			return s
	fail_test("no landing seed")
	return 0


## What one [param kind] hit on [param slot] deals with nothing guarding it.
func _unguarded(slot: int, kind: String, rng_seed: int) -> int:
	return int(_strike(slot, kind, rng_seed)["damage"])


# --- The tables are the data ---


func test_every_stance_magnitude_matches_the_shipped_effect_text() -> void:
	var words: Dictionary = {"physical": "of physical damage", "all": "of all damage"}
	for stance: String in Bulwark.STANCES:
		var rule: Dictionary = Bulwark.STANCES[stance]
		var text: String = String(_ability(stance).get("effect", ""))
		assert_true(text.begins_with("Stance."), "%s is a stance in the data" % stance)
		assert_true(
			text.contains("absorbing %d%% %s" % [rule["pct"], words[rule["kind"]]]),
			"%s absorbs %d%% %s: %s" % [stance, rule["pct"], rule["kind"], text]
		)
	assert_eq(Bulwark.STANCES.keys().size(), 2, "Ironwall and Rampart are the stances")


func test_aegis_veil_and_steadfast_resolve_match_the_shipped_effect_text() -> void:
	var veil: String = String(_ability("aegis_veil").get("effect", ""))
	assert_true(
		veil.contains(
			(
				"reducing magic damage by %d%% for %d turns"
				% [Bulwark.AEGIS_VEIL["pct"], Bulwark.AEGIS_VEIL["turns"]]
			)
		),
		veil
	)
	var resolve: String = String(_ability("steadfast_resolve").get("effect", ""))
	var r: Dictionary = Bulwark.STEADFAST_RESOLVE
	assert_true(
		resolve.contains(
			(
				"+%d%% DEF and +%d%% MDEF to all allies for %d turns"
				% [r["stat_pct"]["def"], r["stat_pct"]["mdef"], r["turns"]]
			)
		),
		resolve
	)
	assert_true(resolve.contains("cleanses all Despair and Silence"), resolve)
	assert_eq(r["cleanse"], ["despair", "silence"], "the two statuses it cleanses")


# --- Entering and switching stances ---


func test_ironwall_on_an_ally_is_free_and_raises_the_stance() -> void:
	assert_true(_use("ironwall", LIRA), "Ironwall resolves at 0 AP")
	assert_eq(_state.get_member(EDREN)["active_stance"], "ironwall", "Edren holds Ironwall")
	assert_has(_messages, "Edren uses Ironwall!", "announced by name")


func test_ironwall_needs_a_living_ally_other_than_edren() -> void:
	assert_false(_use("ironwall", EDREN), "Edren cannot guard himself")
	_state.take_damage(LIRA, 99999)
	assert_false(_use("ironwall", LIRA), "nor a fallen ally")
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "no stance raised")
	assert_has(_messages, "No target!", "the menu says why, as Magic does")


func test_a_new_stance_replaces_the_old_one() -> void:
	_use("ironwall", LIRA)
	_use("rampart")
	assert_eq(_state.get_member(EDREN)["active_stance"], "rampart", "one stance at a time")
	var s: int = _landing_seed(CAEL, "physical")
	var edren_hp: int = _hp(EDREN)
	_strike(CAEL, "physical", s)
	assert_eq(_hp(EDREN), edren_hp, "Ironwall's guard on Cael is gone")


func test_a_stance_lasts_until_edren_s_next_turn_is_over() -> void:
	# abilities.md: the stance "persists until his next turn"; ui-design.md
	# § 7.3 highlights the active stance in that turn's Bulwark menu, and
	# choosing a stance there replaces it.
	_state.begin_turn(EDREN)
	_use("rampart")
	_state.tick_statuses(EDREN)  # the turn he raised it closes
	assert_eq(_state.get_member(EDREN)["active_stance"], "rampart", "held through enemy turns")
	_state.begin_turn(EDREN)
	assert_eq(_state.get_member(EDREN)["active_stance"], "rampart", "still up on his next turn")
	_state.tick_statuses(EDREN)  # that turn closes with no new stance
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "then it drops")


func test_re_entering_a_stance_on_the_next_turn_keeps_it_up() -> void:
	_state.begin_turn(EDREN)
	_use("rampart")
	_state.tick_statuses(EDREN)
	_state.begin_turn(EDREN)
	_use("rampart")
	_state.tick_statuses(EDREN)
	assert_eq(_state.get_member(EDREN)["active_stance"], "rampart", "chosen again, held again")


func test_fainting_drops_the_stance() -> void:
	_use("rampart")
	_state.take_damage(EDREN, 99999)
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "a fallen Edren guards no one")


# --- Absorption: the guarded ally takes the rest, Edren takes the share ---


func test_ironwall_redirects_half_a_physical_hit_to_edren() -> void:
	var s: int = _landing_seed(LIRA, "physical")
	var full: int = _unguarded(LIRA, "physical", s)
	_use("ironwall", LIRA)
	var lira_hp: int = _hp(LIRA)
	var edren_hp: int = _hp(EDREN)
	var r: Dictionary = _strike(LIRA, "physical", s)
	assert_eq(lira_hp - _hp(LIRA), int(full * 0.5), "Lira takes the other half")
	assert_eq(edren_hp - _hp(EDREN), int(full * 0.5), "Edren takes half")
	assert_eq(r["damage"], int(full * 0.5), "the popup on Lira shows what she took")
	assert_eq(r["absorbed"], {"slot": EDREN, "damage": int(full * 0.5)}, "and names Edren's share")


func test_ironwall_does_not_absorb_magic() -> void:
	var s: int = _landing_seed(LIRA, "magic")
	var full: int = _unguarded(LIRA, "magic", s)
	_use("ironwall", LIRA)
	var edren_hp: int = _hp(EDREN)
	var r: Dictionary = _strike(LIRA, "magic", s)
	assert_eq(r["damage"], full, "magic lands in full on Lira")
	assert_eq(_hp(EDREN), edren_hp, "and none of it on Edren")


func test_ironwall_guards_only_the_ally_it_was_raised_on() -> void:
	_use("ironwall", LIRA)
	var s: int = _landing_seed(MAREN, "physical")
	var edren_hp: int = _hp(EDREN)
	_strike(MAREN, "physical", s)
	assert_eq(_hp(EDREN), edren_hp, "Maren is not guarded")


func test_rampart_redirects_thirty_percent_of_any_hit_on_the_back_row() -> void:
	for kind: String in ["physical", "magic"]:
		for slot: int in [LIRA, MAREN]:
			_state.get_member(EDREN)["active_stance"] = ""
			var s: int = _landing_seed(slot, kind)
			var full: int = _unguarded(slot, kind, s)
			_use("rampart")
			var edren_hp: int = _hp(EDREN)
			var r: Dictionary = _strike(slot, kind, s)
			assert_eq(
				r["damage"], int(full * (1.0 - 0.3)), "%s on slot %d: 70%% lands" % [kind, slot]
			)
			assert_eq(edren_hp - _hp(EDREN), int(full * 30 / 100.0), "and Edren takes 30%%")


func test_rampart_does_not_guard_the_front_row() -> void:
	_use("rampart")
	var s: int = _landing_seed(CAEL, "physical")
	var edren_hp: int = _hp(EDREN)
	_strike(CAEL, "physical", s)
	assert_eq(_hp(EDREN), edren_hp, "Cael is in the front row")


func test_rampart_does_not_redirect_edren_s_own_hits_to_himself() -> void:
	_state.get_member(EDREN)["row"] = "back"
	var s: int = _landing_seed(EDREN, "physical")
	var full: int = _unguarded(EDREN, "physical", s)
	_use("rampart")
	var r: Dictionary = _strike(EDREN, "physical", s)
	assert_eq(r["damage"], full, "Edren takes his own hit in full")
	assert_false(r.has("absorbed"), "nothing was absorbed")
	assert_eq(_ap(), 0, "and absorbing nothing earns nothing")


func test_absorption_is_taken_before_the_ally_s_own_reductions() -> void:
	# combat-formulas.md § Stacking Examples: the ally's reductions shrink what
	# the ally takes, not Edren's share of the hit.
	var s: int = _landing_seed(LIRA, "physical")
	var full: int = _unguarded(LIRA, "physical", s)
	_state.set_buff(LIRA, "damage_taken_mult", 0.5)
	_use("ironwall", LIRA)
	var edren_hp: int = _hp(EDREN)
	var r: Dictionary = _strike(LIRA, "physical", s)
	assert_eq(r["damage"], int(full * (1.0 - 0.5) * (1.0 - 0.5)), "Lira: halved twice")
	assert_eq(edren_hp - _hp(EDREN), int(full * 0.5), "Edren: half of the whole hit")


# --- Aegis Points ---


func test_each_absorbed_hit_earns_one_ap() -> void:
	_use("ironwall", LIRA)
	watch_signals(_state)
	var landed: int = 0
	for s: int in range(1, 6):
		if _strike(LIRA, "physical", s).has("absorbed"):
			landed += 1
	assert_gt(landed, 0, "hits landed")
	assert_eq(_ap(), landed, "1 AP per absorbed hit")
	assert_signal_emitted_with_parameters(_state, "ability_state_changed", [EDREN])


func test_every_hit_of_a_multi_hit_attack_is_absorbed_on_its_own() -> void:
	_use("ironwall", LIRA)
	seed(4)
	var r: Dictionary = BattleActions.execute_enemy_physical_ability(_state, _enemy, LIRA, 1.0, 3)
	assert_eq(_ap(), int(r["hits_landed"]), "one AP for each hit that landed")
	assert_gt(int(r["absorbed"]["damage"]), 0, "the shares add up in the result")


func test_ap_never_rises_past_ten() -> void:
	var s: int = _landing_seed(LIRA, "physical")
	_state.get_member(EDREN)["ap"] = 10
	_use("ironwall", LIRA)
	_strike(LIRA, "physical", s)
	assert_eq(_ap(), 10, "Max 10 AP")


func test_ap_decays_by_one_at_the_start_of_a_turn_after_no_damage() -> void:
	_state.get_member(EDREN)["ap"] = 3
	_state.begin_turn(EDREN)
	assert_eq(_ap(), 2, "untouched since his last turn: lose 1 AP")
	_state.tick_statuses(EDREN)
	_state.take_damage(EDREN, 10)
	_state.begin_turn(EDREN)
	assert_eq(_ap(), 2, "hit since his last turn: no decay")
	_state.tick_statuses(EDREN)
	_state.begin_turn(EDREN)
	assert_eq(_ap(), 1, "the damage counted once; the next quiet turn decays again")


func test_ap_does_not_decay_below_zero() -> void:
	_state.begin_turn(EDREN)
	assert_eq(_ap(), 0, "starts each battle at 0 and stays there")


func test_an_absorbed_share_counts_as_damage_edren_took() -> void:
	var s: int = _landing_seed(LIRA, "physical")
	_state.get_member(EDREN)["ap"] = 3
	_use("ironwall", LIRA)
	_state.tick_statuses(EDREN)
	_strike(LIRA, "physical", s)
	_state.begin_turn(EDREN)
	assert_eq(_ap(), 4, "gained 1 for the absorb, lost none to decay")


# --- AP costs ---


func test_ap_costs_are_payable_from_the_pool() -> void:
	var member: Dictionary = {"ap": 3}
	assert_true(AbilityCommand.can_pay(member, _ability("aegis_veil")), "3 AP covers 3 AP")
	member["ap"] = 2
	assert_false(AbilityCommand.can_pay(member, _ability("aegis_veil")), "2 AP does not")


func test_aegis_veil_spends_its_ap() -> void:
	_state.get_member(EDREN)["ap"] = 5
	assert_true(_use("aegis_veil", LIRA), "resolves")
	assert_eq(_ap(), 2, "5 - 3 AP")


func test_an_unaffordable_bulwark_ability_is_refused_and_costs_nothing() -> void:
	_state.get_member(EDREN)["ap"] = 2
	assert_false(_use("aegis_veil", LIRA), "3 AP refused at 2")
	assert_eq(_ap(), 2, "nothing spent")
	assert_has(_messages, "Not enough AP!", "and the shortfall is named")


# --- Aegis Veil: 40% less magic damage on one ally for 3 turns ---


func test_aegis_veil_cuts_magic_damage_by_forty_percent() -> void:
	var s: int = _landing_seed(LIRA, "magic")
	var full: int = _unguarded(LIRA, "magic", s)
	_state.get_member(EDREN)["ap"] = 3
	_use("aegis_veil", LIRA)
	var r: Dictionary = _strike(LIRA, "magic", s)
	assert_almost_eq(float(r["damage"]), full * 0.6, 1.0, "60% of the hit lands")
	assert_false(r.has("absorbed"), "a flat reduction, not an absorption")


func test_aegis_veil_does_not_touch_physical_damage() -> void:
	var s: int = _landing_seed(LIRA, "physical")
	var full: int = _unguarded(LIRA, "physical", s)
	_state.get_member(EDREN)["ap"] = 3
	_use("aegis_veil", LIRA)
	assert_eq(_strike(LIRA, "physical", s)["damage"], full, "physical lands in full")


func test_aegis_veil_lasts_three_of_the_ally_s_turns() -> void:
	var s: int = _landing_seed(LIRA, "magic")
	var full: int = _unguarded(LIRA, "magic", s)
	_state.get_member(EDREN)["ap"] = 3
	_use("aegis_veil", LIRA)
	for _i: int in range(2):
		_state.tick_statuses(LIRA)
	assert_lt(int(_strike(LIRA, "magic", s)["damage"]), full, "still veiled after 2 turns")
	_state.tick_statuses(LIRA)
	assert_eq(_strike(LIRA, "magic", s)["damage"], full, "gone after Lira's 3rd turn")


# --- Steadfast Resolve: cleanse Despair and Silence, then +20% DEF/MDEF ---


func test_steadfast_resolve_cleanses_despair_and_silence_from_every_ally() -> void:
	_state.get_member(EDREN)["ap"] = 6
	_state.apply_status(CAEL, "despair", "turns", 4)
	_state.apply_status(LIRA, "silence", "turns", 4)
	_state.apply_status(MAREN, "poison", "turns", -1)
	assert_true(_use("steadfast_resolve"), "resolves")
	assert_false(_state.has_status(CAEL, "despair"), "Cael freed from Despair")
	assert_false(_state.has_status(LIRA, "silence"), "Lira's Silence lifted")
	assert_true(_state.has_status(MAREN, "poison"), "other statuses stay")
	assert_eq(_ap(), 0, "6 AP spent")


func test_steadfast_resolve_raises_def_and_mdef_of_every_living_ally() -> void:
	_state.get_member(EDREN)["ap"] = 6
	var base_def: int = _state.get_effective_stat(LIRA, "def")
	var base_mdef: int = _state.get_effective_stat(LIRA, "mdef")
	var base_atk: int = _state.get_effective_stat(LIRA, "atk")
	_use("steadfast_resolve")
	for slot: int in [EDREN, CAEL, LIRA, MAREN]:
		assert_eq(_state.get_effective_stat(slot, "def"), base_def * 120 / 100, "slot %d" % slot)
		assert_eq(_state.get_effective_stat(slot, "mdef"), base_mdef * 120 / 100, "slot %d" % slot)
	assert_eq(_state.get_effective_stat(LIRA, "atk"), base_atk, "ATK untouched")


func test_steadfast_resolve_lasts_three_turns_on_each_ally() -> void:
	_state.get_member(EDREN)["ap"] = 6
	var base_def: int = _state.get_effective_stat(LIRA, "def")
	_use("steadfast_resolve")
	_state.tick_statuses(LIRA)
	_state.tick_statuses(LIRA)
	assert_eq(_state.get_effective_stat(LIRA, "def"), base_def * 120 / 100, "2 of 3 turns")
	_state.tick_statuses(LIRA)
	assert_eq(_state.get_effective_stat(LIRA, "def"), base_def, "gone after the 3rd")


func test_steadfast_resolve_and_hold_the_line_add_then_floor_once() -> void:
	# combat-formulas.md § Buff & Debuff Interaction: buffs on the same stat
	# add, then floor once — +20% and +15% read as +35%.
	_state.get_member(EDREN)["ap"] = 6
	var base_def: int = _state.get_effective_stat(LIRA, "def")
	BattleRally.start(_state, CAEL, "hold_the_line", AbilityCommand.RALLY_EFFECTS["hold_the_line"])
	_use("steadfast_resolve")
	assert_eq(_state.get_effective_stat(LIRA, "def"), base_def * 135 / 100, "+35%, one floor")
	BattleRally.end(_state)
	assert_eq(_state.get_effective_stat(LIRA, "def"), base_def * 120 / 100, "Resolve outlives it")


# --- Listeners hear stance and AP changes ---


func test_raising_and_dropping_a_stance_is_signalled_for_edren() -> void:
	watch_signals(_state)
	_use("rampart")
	assert_signal_emitted_with_parameters(_state, "ability_state_changed", [EDREN])
	_state.take_damage(EDREN, 99999)
	assert_signal_emit_count(_state, "ability_state_changed", 2, "raised, then dropped")


# --- The enemy turn shows Edren's share ---


class _TurnManager:
	extends Node2D
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)


func test_an_enemy_turn_shows_a_damage_number_on_edren_for_his_share() -> void:
	var mgr: _TurnManager = _TurnManager.new()
	add_child_autofree(mgr)
	var hits: Array = []
	mgr.damage_dealt.connect(func(t: String, n: int, _k: String) -> void: hits.append([t, n]))
	var atb: Node = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(atb)
	var area: Node2D = Node2D.new()
	add_child_autofree(area)
	var driver: BattleEnemyTurn = BattleEnemyTurn.new(mgr, _state, atb, area)
	var enemy: Enemy = preload("res://scenes/entities/enemy.tscn").instantiate()
	add_child_autofree(enemy)
	enemy.enemy_data = {"atk": 40, "spd": 255, "type": "humanoid", "hp": 100}
	enemy.current_hp = 100
	enemy.is_alive = true
	_use("rampart")
	var before: int = 0
	seed(2)
	for i: int in range(30):  # until a turn's hit on the back row is absorbed
		hits.clear()
		before = _hp(EDREN)
		driver.execute("enemy_0", [enemy] as Array[Node], false, i)
		if _ap() > 0:
			break
	assert_eq(_ap(), 1, "one enemy hit on the back row was absorbed")
	var on_edren: Array = hits.filter(func(h: Array) -> bool: return h[0] == "party_0")
	assert_eq(on_edren.size(), 1, "a number rose over Edren")
	assert_eq(int(on_edren[0][1]), before - _hp(EDREN), "showing the share he took")
