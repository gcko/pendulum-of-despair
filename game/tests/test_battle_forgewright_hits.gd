extends GutTest
## Lira's Forgewright where a hit resolves (GAP-002, slice 158c of #158):
## Bulkhead's cut to physical damage, Arc Trap and Thornveil Barrier answering
## an enemy's physical attack, and Overcharge on an ally's next strike.
## Deploying, the device limit, Salvage, Shock Coil and Mending Engine are
## test_battle_forgewright.gd.
##
## Design law: abilities.md § Lira — Forgewright, combat-formulas.md § Damage
## Reduction Sources (Bulkhead 40%, physical only, a flat reduction) and
## § Buff-Granted Multipliers (Overcharge multiplies the next attack's final
## damage by 1.5), with the 2026-10-30 ruling that Arc Trap fires on any
## enemy's physical attack, whatever its target, and is then spent.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const EDREN := 0
const CAEL := 1
const LIRA := 2
const MAREN := 3
const ALLY_DEF := 40


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
var _enemy: Enemy


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	PartyState.arcanite_charges = 12
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["edren", "cael", "lira", "maren"][slot]))
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_battle.atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_battle.atb)
	_cmd = AbilityCommand.new(_battle)
	_enemy = _make_enemy({})
	_battle.enemies = [_enemy] as Array[Node]


func after_each() -> void:
	_cmd = null
	randomize()
	PartyState.arcanite_charges = 12
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
			"atk": 50,
			"def": ALLY_DEF,
			"mag": 60,
			"mdef": 20,
			"spd": 1,
			"lck": 0,
		},
	}


## A slow, heavy-hitting enemy, with [param extra] overriding its data.
func _make_enemy(extra: Dictionary) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	var data: Dictionary = {
		"name": "Brute",
		"atk": 60,
		"mag": 40,
		"spd": 0,
		"def": 10,
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
	for a: Variant in DataManager.load_abilities("lira"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("lira.json has no ability '%s'" % ability_id)
	return {}


func _use(ability_id: String, target: int = 0) -> bool:
	return _cmd.do_ability(
		"party_%d" % LIRA, {"type": "ability", "ability": _ability(ability_id), "target": target}
	)


## [param enemy]'s physical attack on [param slot] under [param rng_seed], the
## path every enemy attack takes.
func _strike(slot: int, rng_seed: int, enemy: Enemy = null) -> Dictionary:
	seed(rng_seed)
	var e: Enemy = enemy if enemy != null else _enemy
	return BattleActions.execute_enemy_physical_ability(_state, e, slot)


## A seed whose physical hit on [param slot] lands, found with nothing deployed.
func _landing_seed(slot: int) -> int:
	for s: int in range(1, 60):
		var r: Dictionary = _strike(slot, s)
		_heal_all()
		if r.get("hit", false):
			return s
	fail_test("no landing seed")
	return 0


func _heal_all() -> void:
	for slot: int in range(4):
		_state.get_member(slot)["current_hp"] = 5000


func _lira_turn() -> void:
	_state.begin_turn(LIRA)
	_state.tick_statuses(LIRA)


func _device_ids() -> Array[String]:
	var out: Array[String] = []
	for d: Dictionary in Forgewright.devices(_state.get_member(LIRA)):
		out.append(String(d["id"]))
	return out


## The counters an enemy attack drew from Lira's devices.
func _answers(result: Dictionary) -> Array:
	return result.get("ripostes", [])


## Cael's Attack command on [param enemy] under [param rng_seed].
func _cael_attack(enemy: Enemy, rng_seed: int) -> Dictionary:
	seed(rng_seed)
	return BattleActions.execute_party_attack(_state, CAEL, enemy, 0)


# --- Bulkhead: -40% physical damage to one ally, for three of Lira's turns ---


func test_bulkhead_cuts_physical_damage_to_its_ally_by_40_percent() -> void:
	var s: int = _landing_seed(CAEL)
	var plain: int = int(_strike(CAEL, s)["damage"])
	_heal_all()
	_use("bulkhead", CAEL)
	var guarded: int = int(_strike(CAEL, s)["damage"])
	assert_almost_eq(float(guarded), plain * 0.6, 1.0, "40%% off %d" % plain)


func test_bulkhead_guards_only_the_chosen_ally() -> void:
	var s: int = _landing_seed(MAREN)
	var plain: int = int(_strike(MAREN, s)["damage"])
	_heal_all()
	_use("bulkhead", CAEL)
	assert_eq(int(_strike(MAREN, s)["damage"]), plain, "Maren is not behind it")


func test_bulkhead_does_not_touch_magic() -> void:
	var plain: Dictionary = {}
	var s: int = 0
	for candidate: int in range(1, 60):
		seed(candidate)
		plain = BattleActions.execute_enemy_magic(_state, _enemy, CAEL, "", 30)
		_heal_all()
		if plain.get("hit", false):
			s = candidate
			break
	_use("bulkhead", CAEL)
	seed(s)
	var guarded: Dictionary = BattleActions.execute_enemy_magic(_state, _enemy, CAEL, "", 30)
	assert_eq(guarded["damage"], plain["damage"], "physical only")


func test_bulkhead_stacks_with_ironwall_on_the_ally_s_own_share() -> void:
	var s: int = _landing_seed(CAEL)
	Bulwark.enter_stance(_state, EDREN, "ironwall", CAEL)
	var walled: Dictionary = _strike(CAEL, s)
	_heal_all()
	_use("bulkhead", CAEL)
	var both: Dictionary = _strike(CAEL, s)
	assert_almost_eq(float(both["damage"]), walled["damage"] * 0.6, 1.0, "Cael's half, cut 40%")
	assert_eq(both["absorbed"]["damage"], walled["absorbed"]["damage"], "Edren's half is not cut")


func test_bulkhead_lapses_after_three_of_lira_s_turns() -> void:
	var s: int = _landing_seed(CAEL)
	var plain: int = int(_strike(CAEL, s)["damage"])
	_heal_all()
	_state.begin_turn(LIRA)
	_use("bulkhead", CAEL)
	_state.tick_statuses(LIRA)
	for _turn: int in range(2):
		_lira_turn()
	assert_lt(int(_strike(CAEL, s)["damage"]), plain, "still up through her third turn")
	_heal_all()
	_lira_turn()
	assert_eq(int(_strike(CAEL, s)["damage"]), plain, "gone once it ends")
	assert_eq(_device_ids(), [] as Array[String])


func test_bulkhead_stops_guarding_once_lira_faints() -> void:
	var s: int = _landing_seed(CAEL)
	var plain: int = int(_strike(CAEL, s)["damage"])
	_heal_all()
	_use("bulkhead", CAEL)
	_state.take_damage(LIRA, 99999)
	assert_eq(int(_strike(CAEL, s)["damage"]), plain, "the full hit lands")


# --- Arc Trap: any enemy's physical attack sets it off, once ---


func test_arc_trap_answers_a_physical_attack_on_anyone() -> void:
	var s: int = _landing_seed(EDREN)
	_use("arc_trap")
	var result: Dictionary = _strike(EDREN, s)
	var answers: Array = _answers(result)
	assert_eq(answers.size(), 1, "one trap went off")
	assert_eq(answers[0].get("type", ""), "magic", "a spell's damage")
	assert_gt(int(answers[0]["damage"]), 0, "it hurt")
	assert_eq(_enemy.current_hp, 30000 - int(answers[0]["damage"]), "the attacker took it")
	assert_eq(_device_ids(), [] as Array[String], "single use")


func test_arc_trap_slows_the_attacker_by_20_percent_for_two_of_its_turns() -> void:
	var quick: Enemy = _make_enemy({"spd": 50})
	_use("arc_trap")
	_strike(CAEL, 3, quick)
	assert_eq(quick.get_stats()["spd"], 40, "20% off its Speed")
	quick.tick_buffs()
	assert_eq(quick.get_stats()["spd"], 40, "through its first turn")
	quick.tick_buffs()
	assert_eq(quick.get_stats()["spd"], 50, "gone after its second")


func test_arc_trap_burns_as_flame() -> void:
	var fireproof: Enemy = _make_enemy({"immunities": ["flame"]})
	_use("arc_trap")
	var answers: Array = _answers(_strike(CAEL, 3, fireproof))
	assert_eq(answers.size(), 1, "it went off")
	assert_eq(answers[0].get("type", ""), "immune", "Flame does nothing to this one")
	assert_eq(fireproof.current_hp, 30000)


func test_arc_trap_waits_through_a_magic_attack() -> void:
	_use("arc_trap")
	for s: int in range(1, 10):
		seed(s)
		BattleActions.execute_enemy_magic(_state, _enemy, CAEL, "", 30)
	assert_eq(_enemy.current_hp, 30000, "untouched")
	assert_eq(_device_ids(), ["arc_trap"] as Array[String], "still armed")


func test_arc_trap_goes_off_once_only() -> void:
	var s: int = _landing_seed(CAEL)
	_use("arc_trap")
	_strike(CAEL, s)
	_heal_all()
	assert_eq(_answers(_strike(CAEL, s)), [], "the second attack draws nothing")


func test_a_sprung_arc_trap_frees_its_slot() -> void:
	_use("arc_trap")
	_use("shock_coil")
	_strike(CAEL, 3)
	_use("bulkhead", CAEL)
	assert_eq(_device_ids(), ["shock_coil", "bulkhead"] as Array[String], "the coil survives")


# --- Thornveil Barrier: 15% of the shielded ally's Defense back at attackers ---


func test_thornveil_barrier_hurts_whoever_strikes_its_ally() -> void:
	var s: int = _landing_seed(CAEL)
	_use("thornveil_barrier", CAEL)
	var answers: Array = _answers(_strike(CAEL, s))
	var counter: int = ALLY_DEF * 15 / 100
	assert_eq(answers.size(), 1, "one counter")
	assert_eq(int(answers[0]["damage"]), counter, "15% of Cael's 40 Defense")
	assert_eq(_enemy.current_hp, 30000 - counter)


func test_thornveil_barrier_counter_follows_the_ally_s_buffed_defense() -> void:
	var s: int = _landing_seed(CAEL)
	_state.set_buff(CAEL, "def_mult", 2.0)
	_use("thornveil_barrier", CAEL)
	assert_eq(int(_answers(_strike(CAEL, s))[0]["damage"]), ALLY_DEF * 2 * 15 / 100)


func test_thornveil_barrier_ignores_a_hit_on_someone_else() -> void:
	var s: int = _landing_seed(MAREN)
	_use("thornveil_barrier", CAEL)
	assert_eq(_answers(_strike(MAREN, s)), [])


func test_thornveil_barrier_lapses_after_three_of_lira_s_turns() -> void:
	var s: int = _landing_seed(CAEL)
	_use("thornveil_barrier", CAEL)
	for _turn: int in range(3):
		_lira_turn()
	assert_eq(_answers(_strike(CAEL, s)), [], "the barrier is gone")


func test_thornveil_barrier_counts_toward_the_two_device_limit() -> void:
	_use("thornveil_barrier", CAEL)
	_use("bulkhead", CAEL)
	_use("shock_coil")
	assert_eq(_device_ids(), ["bulkhead", "shock_coil"] as Array[String])


# --- Overcharge: the ally's next attack gains Storm and +50% ---


func test_overcharge_adds_half_again_to_the_next_attack() -> void:
	var plain: int = int(_cael_attack(_enemy, 21)["damage"])
	assert_gt(plain, 0, "precondition: seed 21 lands")
	_enemy.current_hp = 30000
	_use("overcharge", CAEL)
	var charged: Dictionary = _cael_attack(_enemy, 21)
	assert_almost_eq(float(charged["damage"]), plain * 1.5, 1.0, "x1.5 on %d" % plain)


func test_overcharge_is_spent_by_that_one_attack() -> void:
	var plain: int = int(_cael_attack(_enemy, 21)["damage"])
	_use("overcharge", CAEL)
	_cael_attack(_enemy, 21)
	assert_eq(int(_cael_attack(_enemy, 21)["damage"]), plain, "the next is plain again")


func test_an_overcharged_attack_is_storm() -> void:
	var weak: Enemy = _make_enemy({"weaknesses": ["storm"]})
	var plain: int = int(_cael_attack(weak, 21)["damage"])
	assert_gt(plain, 0, "precondition: seed 21 lands")
	weak.current_hp = 30000
	_use("overcharge", CAEL)
	var charged: int = int(_cael_attack(weak, 21)["damage"])
	assert_almost_eq(float(charged), plain * 1.5 * 1.5, 2.0, "+50% and the Storm weakness")


func test_an_overcharged_attack_on_a_storm_immune_enemy_does_nothing() -> void:
	var grounded: Enemy = _make_enemy({"immunities": ["storm"]})
	_use("overcharge", CAEL)
	var r: Dictionary = _cael_attack(grounded, 21)
	assert_eq(r["type"], "immune")
	assert_eq(grounded.current_hp, 30000)


func test_an_overcharged_attack_on_a_storm_absorbing_enemy_heals_it() -> void:
	var sponge: Enemy = _make_enemy({"absorb": ["storm"]})
	sponge.current_hp = 20000
	_use("overcharge", CAEL)
	var r: Dictionary = _cael_attack(sponge, 21)
	assert_eq(r["type"], "absorb")
	assert_eq(sponge.current_hp, 20000 + int(r["damage"]), "it drank the charge")


func test_an_elemental_weapon_takes_the_more_favorable_of_its_element_and_storm() -> void:
	PartyState.initialize_new_game()
	PartyState.get_member("edren")["equipment"]["weapon"] = "pallor_bane"  # Spirit
	var grounded: Enemy = _make_enemy({"immunities": ["storm"]})
	_use("overcharge", EDREN)
	seed(21)
	var r: Dictionary = BattleActions.execute_party_attack(_state, EDREN, grounded, 0)
	assert_eq(r["type"], "physical", "Spirit lands where Storm cannot")
	assert_gt(int(r["damage"]), 0)


func test_overcharge_needs_a_living_ally() -> void:
	_state.take_damage(CAEL, 99999)
	assert_false(_use("overcharge", CAEL))
	assert_eq(int(_state.get_member(LIRA)["ac"]), 12, "nothing spent")


# --- A final-damage multiplier, after DEF (combat-formulas.md step 6) ---


func test_a_party_strike_s_damage_mult_scales_its_final_damage_not_its_power() -> void:
	# Against heavy armor a power multiplier would almost triple this hit; a
	# final-damage one is half again, exactly.
	var armored: Enemy = _make_enemy({"def": 300})
	seed(21)
	var plain: int = int(BattleActions.execute_party_attack(_state, CAEL, armored, 0)["damage"])
	assert_gt(plain, 1, "precondition: seed 21 lands above the floor")
	seed(21)
	var scaled: Dictionary = BattleActions.execute_party_attack(_state, CAEL, armored, 0, 1.0, 1.5)
	assert_almost_eq(float(scaled["damage"]), plain * 1.5, 1.0, "x1.5 on %d" % plain)


func test_an_enemy_strike_s_damage_mult_scales_its_final_damage() -> void:
	var s: int = _landing_seed(CAEL)
	seed(s)
	var plain: int = int(BattleActions.execute_enemy_attack(_state, _enemy, CAEL)["damage"])
	_heal_all()
	seed(s)
	var scaled: int = int(
		BattleActions.execute_enemy_attack(_state, _enemy, CAEL, 1.0, 1.5)["damage"]
	)
	assert_almost_eq(float(scaled), plain * 1.5, 1.0, "x1.5 on %d" % plain)
