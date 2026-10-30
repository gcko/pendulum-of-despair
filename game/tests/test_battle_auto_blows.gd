extends GutTest
## What a confused or berserk combatant's auto-attack does when it lands
## (GAP-003 slice 5, #246; rulings of 2026-10-30): Oathkeeper doubles it,
## Berserk adds +50% to its final damage, and a blow on an ally meets that
## ally's protection (Bulwark's split, Bulkhead's cut) but draws no counter,
## and Edren's stance never absorbs his own blow. Who acts and whom they pick is
## test_battle_auto_action.gd.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Edren in slot 0, Cael in slot 1.
const EDREN := 0
const CAEL := 1
## Enough HP that no auto-attack in these tests ends the fight.
const STURDY_HP := 5000

var _booted: Node = null


func before_each() -> void:
	seed(12345)
	GameManager.transition_data = {}


func after_each() -> void:
	_free_battle()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


func _free_battle() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null


## Boot a real battle against [param encounter], driven frame by frame by hand,
## with every combatant given enough HP to survive the attacks under test.
func _boot(encounter: Array = ["ley_vermin"]) -> Node:
	_free_battle()
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	battle.set_process(false)
	_booted = battle
	var state: Node = battle.get_battle_state()
	for slot: int in [EDREN, CAEL]:
		state.get_member(slot)["max_hp"] = STURDY_HP
		state.get_member(slot)["current_hp"] = STURDY_HP
	for e: Node in battle.get_enemies():
		e.current_hp = STURDY_HP
	return battle


## Give [param id] (e.g. "party_0", "enemy_1") the only full gauge and run one
## frame, so it and nobody else takes this turn.
func _only_turn(battle: Node, id: String) -> void:
	var atb: Node = battle.get_atb()
	for slot: int in range(4):
		atb.set_gauge("party_%d" % slot, 0)
	for i: int in range(battle.get_enemies().size()):
		atb.set_gauge("enemy_%d" % i, 0)
	atb.set_gauge(id, ATBSystem.GAUGE_MAX)
	battle._process(0.0)


func _afflict(battle: Node, id: String, status: String) -> void:
	var duration: int = StatusEffects.default_duration(status)
	if id.begins_with("party_"):
		battle.get_battle_state().apply_status(
			id.replace("party_", "").to_int(), status, "turns", duration
		)
	else:
		battle.get_enemies()[id.replace("enemy_", "").to_int()].apply_status(status, duration)


# --- Oathkeeper and Bulwark under an auto-attack (rulings of 2026-10-30) ---


## Seat Lira in slot 2 of [param battle], in the front row, with the rest of
## the party's HP, so a third member can strike or be struck.
func _seat_lira(battle: Node) -> void:
	var state: Node = battle.get_battle_state()
	(
		state
		. add_member(
			2,
			{
				"character_id": "lira",
				"name": "Lira",
				"max_hp": STURDY_HP,
				"base_stats":
				{"hp": STURDY_HP, "atk": 40, "def": 20, "mag": 10, "mdef": 10, "spd": 10, "lck": 0},
			}
		)
	)
	state.get_member(2)["row"] = "front"
	battle.get_atb().add_combatant("party_2", 10, false)


## The first seeded turn of [param actor] whose auto-attack lands on
## [param target], as the hits shown that turn; [] if none did in 80 tries.
## [param arrange] sets each fresh battle up before the turn.
func _turn_landing_on(actor: String, target: String, arrange: Callable) -> Array:
	for s: int in range(1, 80):
		var battle: Node = _boot()
		arrange.call(battle)
		var shown: Array = []
		battle.damage_dealt.connect(
			func(t: String, n: int, k: String) -> void: shown.append([t, n, k])
		)
		seed(s)
		_only_turn(battle, actor)
		var landed: bool = shown.any(
			func(h: Array) -> bool: return h[0] == target and h[2] != "miss"
		)
		if landed:
			return [battle, shown]
	fail_test("%s never landed a hit on %s" % [actor, target])
	return []


func test_oathkeeper_doubles_a_confused_edren_s_swing_at_an_enemy() -> void:
	var out: Array = _turn_landing_on(
		"party_0",
		"enemy_0",
		func(battle: Node) -> void:
			var state: Node = battle.get_battle_state()
			state.apply_status(EDREN, "confusion", "turns", 3)
			Bulwark.oathkeeper(state, EDREN)
	)
	if out.is_empty():
		return
	var at_enemy: Array = out[1].filter(func(h: Array) -> bool: return h[0] == "enemy_0")
	assert_eq(at_enemy.size(), 2, "two swings, as the Attack command makes under Oathkeeper")


func test_oathkeeper_doubles_a_confused_edren_s_swing_at_an_ally() -> void:
	var out: Array = _turn_landing_on(
		"party_0",
		"party_1",
		func(battle: Node) -> void:
			var state: Node = battle.get_battle_state()
			state.apply_status(EDREN, "confusion", "turns", 3)
			Bulwark.oathkeeper(state, EDREN)
	)
	if out.is_empty():
		return
	var at_cael: Array = out[1].filter(func(h: Array) -> bool: return h[0] == "party_1")
	assert_eq(at_cael.size(), 2, "both swings land on the ally too")


func test_ironwall_absorbs_a_confused_ally_s_hit_and_edren_does_not_riposte() -> void:
	# Ruling of 2026-10-30: friendly fire runs through Bulwark's absorb split,
	# like an enemy hit, but Riposte never counters an ally.
	var out: Array = _turn_landing_on(
		"party_2",
		"party_1",
		func(battle: Node) -> void:
			var state: Node = battle.get_battle_state()
			_seat_lira(battle)
			Bulwark.enter_stance(state, EDREN, "ironwall", CAEL)
			Bulwark.oathkeeper(state, EDREN)  # every absorbed enemy hit would counter
			state.apply_status(2, "confusion", "turns", 3)
	)
	if out.is_empty():
		return
	var state: Node = out[0].get_battle_state()
	var to_edren: Array = out[1].filter(func(h: Array) -> bool: return h[0] == "party_0")
	assert_eq(to_edren.size(), 1, "Edren's share of the hit shows as his own number")
	assert_lt(state.get_member(EDREN)["current_hp"], STURDY_HP, "Edren took his share")
	assert_gt(int(state.get_member(EDREN).get("ap", 0)), 0, "the absorbed hit earned AP")
	assert_eq(state.get_member(2)["current_hp"], STURDY_HP, "no Riposte hit Lira")


func test_a_confused_ally_s_direct_hit_on_edren_in_stance_earns_ap_but_no_riposte() -> void:
	var out: Array = _turn_landing_on(
		"party_2",
		"party_0",
		func(battle: Node) -> void:
			var state: Node = battle.get_battle_state()
			_seat_lira(battle)
			Bulwark.enter_stance(state, EDREN, "rampart", -1)
			Bulwark.arm_riposte(state, EDREN)
			state.apply_status(2, "confusion", "turns", 3)
	)
	if out.is_empty():
		return
	var state: Node = out[0].get_battle_state()
	assert_gt(int(state.get_member(EDREN).get("ap", 0)), 0, "a direct hit in stance earns AP")
	assert_eq(state.get_member(2)["current_hp"], STURDY_HP, "no Riposte hit Lira")


# --- Berserk's +50% basic attack damage (combat-formulas.md § Fill Rate Modifiers) ---
# Applied as a final-damage multiplier at step 6, after DEF, so against the same
# target and rolls a berserk blow is floor(base x 1.5), give or take the one
# point flooring after variance can move (combat-formulas.md § Physical Attack
# Resolution).


## Whether [param berserk] is within flooring of 1.5x [param base].
func _is_half_again(base: int, berserk: int) -> bool:
	return berserk >= base * 3 / 2 and berserk <= base * 3 / 2 + 1


## The damage [param actor]'s auto-attack showed on [param target] under
## [param statuses], seeded with [param s]. [param arrange] narrows each fresh
## battle to that one target before the turn.
func _auto_damage(
	actor: String, target: String, statuses: Array, s: int, arrange: Callable
) -> Array:
	var battle: Node = _boot()
	arrange.call(battle)
	for status: String in statuses:
		_afflict(battle, actor, status)
	var shown: Array = []
	battle.damage_dealt.connect(func(t: String, n: int, k: String) -> void: shown.append([t, n, k]))
	seed(s)
	_only_turn(battle, actor)
	return shown.filter(func(h: Array) -> bool: return h[0] == target)


## A seed on which [param actor] lands a plain hit of 4 or more on [param target] with
## [param baseline] statuses, and that hit and the berserk one, as [base, berserk].
func _berserk_pair(
	actor: String, target: String, baseline: Array, berserk: Array, arrange: Callable
) -> Array:
	for s: int in range(1, 80):
		var base: Array = _auto_damage(actor, target, baseline, s, arrange)
		if base.size() != 1 or base[0][2] != "physical" or int(base[0][1]) < 4:
			continue  # a miss, a crit, or a hit too small for half again to show
		var raged: Array = _auto_damage(actor, target, berserk, s, arrange)
		return [int(base[0][1]), int(raged[0][1]) if raged.size() == 1 else -1]
	fail_test("%s never landed a plain hit on %s" % [actor, target])
	return [0, 0]


## Cael is KO'd, so a confused Edren's only target is the vermin, as a berserk
## one's is: both turns draw the same rolls.
func _only_the_vermin_left(battle: Node) -> void:
	battle.get_battle_state().take_damage(CAEL, 99999)


func test_a_berserk_member_s_blow_on_an_enemy_deals_half_again() -> void:
	var pair: Array = _berserk_pair(
		"party_0", "enemy_0", ["confusion"], ["berserk"], _only_the_vermin_left
	)
	assert_true(_is_half_again(pair[0], pair[1]), "%d then %d" % [pair[0], pair[1]])


func test_a_berserk_enemy_s_blow_on_the_party_deals_half_again() -> void:
	var pair: Array = _berserk_pair(
		"enemy_0",
		"party_0",
		["confusion"],
		["berserk"],
		func(battle: Node) -> void:
			_only_the_vermin_left(battle)
			battle.get_battle_state().get_member(EDREN)["effective_stats"]["def"] = 0
	)
	assert_true(_is_half_again(pair[0], pair[1]), "%d then %d" % [pair[0], pair[1]])


func test_a_confused_and_berserk_member_s_blow_on_an_ally_deals_half_again() -> void:
	# Confusion drives the turn, and the Berserk it also carries still adds +50%.
	var pair: Array = _berserk_pair(
		"party_0",
		"party_1",
		["confusion"],
		["confusion", "berserk"],
		func(battle: Node) -> void: battle.get_enemies()[0].set_meta("untargetable", true)
	)
	assert_true(_is_half_again(pair[0], pair[1]), "%d then %d" % [pair[0], pair[1]])


func test_a_confused_and_berserk_enemy_s_blow_on_another_enemy_deals_half_again() -> void:
	for s: int in range(1, 80):
		var dealt: Array[int] = []
		for raging: bool in [false, true]:
			var battle: Node = _boot(["ley_vermin", "ley_vermin"])
			var enemies: Array[Node] = battle.get_enemies()
			enemies[0].apply_status("confusion", 3)
			if raging:
				enemies[0].apply_status("berserk", StatusEffects.UNTIL_CURED)
			var shown: Array = []
			battle.damage_dealt.connect(
				func(t: String, n: int, k: String) -> void: shown.append([t, n, k])
			)
			seed(s)
			BattleAutoAction.enemy_hits_enemy(
				battle, battle.get_atb(), enemies[0], enemies, "enemy_1"
			)
			dealt.append(int(shown[0][1]) if shown[0][2] == "physical" else -1)
		if dealt[0] >= 4:
			assert_true(_is_half_again(dealt[0], dealt[1]), "%d then %d" % [dealt[0], dealt[1]])
			return
	fail_test("the vermin never landed a plain hit on the other")


# --- Friendly fire meets the ally's own protection (rulings of 2026-10-30) ---


## Over seeds, the first on which [param actor]'s auto-attack lands a plain hit
## of 4 or more on [param target] in a battle set up by [param arrange_a], and
## what the same seed's hit does in one set up by [param arrange_b]: [a, b].
func _same_roll_pair(
	actor: String, target: String, arrange_a: Callable, arrange_b: Callable
) -> Array:
	for s: int in range(1, 80):
		var a: Array = _auto_damage(actor, target, [], s, arrange_a)
		if a.size() != 1 or a[0][2] != "physical" or int(a[0][1]) < 4:
			continue
		var b: Array = _auto_damage(actor, target, [], s, arrange_b)
		return [int(a[0][1]), int(b[0][1]) if b.size() == 1 else -1]
	fail_test("%s never landed a plain hit on %s" % [actor, target])
	return [0, 0]


## A confused Edren whose only targets are his allies (the vermin is off the
## field), with Lira seated.
func _edren_confused_among_allies(battle: Node) -> void:
	_seat_lira(battle)
	battle.get_enemies()[0].set_meta("untargetable", true)
	battle.get_battle_state().apply_status(EDREN, "confusion", "turns", 3)


func _lira_ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("lira"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("lira.json has no ability '%s'" % ability_id)
	return {}


func test_bulkhead_cuts_a_confused_ally_s_hit_by_40_percent() -> void:
	var pair: Array = _same_roll_pair(
		"party_0",
		"party_1",
		_edren_confused_among_allies,
		func(battle: Node) -> void:
			_edren_confused_among_allies(battle)
			var state: Node = battle.get_battle_state()
			Forgewright.deploy(state, 2, _lira_ability("bulkhead"), CAEL)
	)
	var cut: int = pair[0] * 6 / 10
	assert_between(pair[1], cut, cut + 1, "%d then %d: Bulkhead's 40%%" % [pair[0], pair[1]])


func test_thornveil_never_counters_a_confused_ally() -> void:
	var out: Array = _turn_landing_on(
		"party_0",
		"party_1",
		func(battle: Node) -> void:
			_edren_confused_among_allies(battle)
			var state: Node = battle.get_battle_state()
			Forgewright.deploy(state, 2, _lira_ability("thornveil_barrier"), CAEL)
	)
	if out.is_empty():
		return
	var state: Node = out[0].get_battle_state()
	assert_lt(state.get_member(CAEL)["current_hp"], STURDY_HP, "the hit landed")
	assert_eq(state.get_member(EDREN)["current_hp"], STURDY_HP, "no thorns came back")


func test_edren_s_stance_never_absorbs_his_own_confused_blow() -> void:
	var out: Array = _turn_landing_on(
		"party_0",
		"party_1",
		func(battle: Node) -> void:
			_edren_confused_among_allies(battle)
			Bulwark.enter_stance(battle.get_battle_state(), EDREN, "ironwall", CAEL)
	)
	if out.is_empty():
		return
	var state: Node = out[0].get_battle_state()
	var to_edren: Array = out[1].filter(func(h: Array) -> bool: return h[0] == "party_0")
	assert_eq(to_edren, [], "no share split off to Edren")
	assert_eq(state.get_member(EDREN)["current_hp"], STURDY_HP, "the whole blow is Cael's")
	assert_eq(int(state.get_member(EDREN).get("ap", 0)), 0, "and Edren earns no AP for it")
