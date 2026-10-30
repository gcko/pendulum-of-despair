extends GutTest
## What an attacker's own state does to the blows it deals: an elemental weapon
## (#513), Despair's -20% damage dealt and Blind's -50% physical accuracy (#246
## slice 3).
##
## Design law: combat-formulas.md § Physical Elemental Attacks ("Elemental
## weapons"), combat-formulas.md § Attacker Status Modifiers, and
## magic.md § Status Effect Reference (Despair "damage dealt -20%", Blind
## "Physical accuracy -50%"). Rulings of 2026-10-30: Despair
## cuts every kind of damage its bearer deals but no healing; Blind halves the
## hit rate of physical attacks only, before the 20-99 clamp; every physical
## strike through execute_party_attack carries the equipped weapon's element,
## and Overcharge keeps "the more favorable of the two".
##
## Every combatant here is slow (party SPD 1, enemy SPD 0), so a hit rate is 90
## and an evasion rate 0 unless a test says otherwise.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const MagicCommand = preload("res://scripts/combat/battle_magic_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const EDREN := 0
const CAEL := 1
const LIRA := 2
const MAREN := 3

## A seed whose first draw lands every damage roll here: a hit roll under 45, so
## even a halved hit rate lands it.
const LANDING_SEED_MAX_ROLL := 45

## A Flame weapon: Lira's forge_hammer (game/data/equipment/weapons.json).
## The tests set it straight onto Edren's equipment; who may wear what is the
## equip menu's rule, not the strike's, which reads only the weapon's element.
const FLAME_WEAPON := "forge_hammer"


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

	func is_boss_battle() -> bool:
		return false


var _battle: FakeBattle
var _state: Node
var _enemy: Enemy


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	PartyState.initialize_new_game()
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["edren", "cael", "lira", "maren"][slot]))
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_battle.atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_battle.atb)
	_enemy = _make_enemy({})
	_battle.enemies = [_enemy] as Array[Node]


func after_each() -> void:
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
			"atk": 50,
			"def": 40,
			"mag": 60,
			"mdef": 20,
			"spd": 1,
			"lck": 0,
		},
	}


## A slow, sturdy enemy, with [param extra] overriding its data.
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


## A seed whose first draw, the hit roll, is in [lo, hi).
func _seed_rolling(lo: int, hi: int) -> int:
	for s: int in range(1, 500):
		seed(s)
		var roll: int = randi() % 100
		if roll >= lo and roll < hi:
			return s
	fail_test("no seed rolls in [%d, %d)" % [lo, hi])
	return 0


func _landing_seed() -> int:
	return _seed_rolling(0, LANDING_SEED_MAX_ROLL)


func _arm_edren(weapon: String) -> void:
	PartyState.get_member("edren")["equipment"]["weapon"] = weapon


func _attack(slot: int, enemy: Enemy, rng_seed: int) -> Dictionary:
	seed(rng_seed)
	return BattleActions.execute_party_attack(_state, slot, enemy, 0)


func _spell(slot: int, enemy: Enemy, rng_seed: int) -> Dictionary:
	seed(rng_seed)
	var mag: int = _state.get_effective_stat(slot, "mag")
	return BattleActions.apply_magic_to_enemy(_state, slot, mag, 20, "", enemy, 0)


func _afflict(slot: int, status: String) -> void:
	_state.apply_status(slot, status, "turns", 4.0)


func _heal_all() -> void:
	for slot: int in range(4):
		_state.get_member(slot)["current_hp"] = 5000


# --- Elemental weapons: a plain Attack takes the weapon's element (#513) ---


func test_a_flame_weapon_deals_the_weakness_multiple_to_a_flame_weak_enemy() -> void:
	_arm_edren(FLAME_WEAPON)
	var s: int = _landing_seed()
	var plain: int = int(_attack(EDREN, _enemy, s)["damage"])
	assert_gt(plain, 0, "precondition: the seed lands")
	var weak: Enemy = _make_enemy({"weaknesses": ["flame"]})
	var r: Dictionary = _attack(EDREN, weak, s)
	assert_eq(r["type"], "physical")
	assert_almost_eq(float(r["damage"]), plain * 1.5, 2.0, "x1.5 on %d" % plain)


func test_a_flame_weapon_does_nothing_to_a_flame_immune_enemy() -> void:
	_arm_edren(FLAME_WEAPON)
	var immune: Enemy = _make_enemy({"immunities": ["flame"]})
	var r: Dictionary = _attack(EDREN, immune, _landing_seed())
	assert_eq(r["type"], "immune", "shown as Immune")
	assert_eq(int(r["damage"]), 0)
	assert_eq(immune.current_hp, 30000, "no damage")


func test_a_flame_weapon_heals_a_flame_absorbing_enemy() -> void:
	_arm_edren(FLAME_WEAPON)
	var sponge: Enemy = _make_enemy({"absorb": ["flame"]})
	sponge.current_hp = 20000
	var r: Dictionary = _attack(EDREN, sponge, _landing_seed())
	assert_eq(r["type"], "absorb")
	assert_gt(int(r["damage"]), 0)
	assert_eq(sponge.current_hp, 20000 + int(r["damage"]), "it drank the blow")


func test_a_flame_weapon_deals_the_resisted_multiple_to_a_flame_resistant_enemy() -> void:
	_arm_edren(FLAME_WEAPON)
	var s: int = _landing_seed()
	var plain: int = int(_attack(EDREN, _enemy, s)["damage"])
	var resistant: Enemy = _make_enemy({"resistances": ["flame"]})
	var r: Dictionary = _attack(EDREN, resistant, s)
	assert_eq(r["type"], "physical")
	assert_almost_eq(float(r["damage"]), plain * 0.75, 1.0, "x0.75 on %d" % plain)


func test_riposte_carries_the_weapon_s_element() -> void:
	_arm_edren(FLAME_WEAPON)
	var weak: Enemy = _make_enemy({"weaknesses": ["flame"]})
	var cmd: RefCounted = AbilityCommand.new(_battle)
	assert_true(cmd.do_ability("party_0", _edren_ability("ironwall", LIRA)), "precondition")
	for s: int in range(1, 80):
		var plain: Dictionary = _riposte(cmd, _enemy, s)
		if not plain.get("hit", false):
			continue
		var r: Dictionary = _riposte(cmd, weak, s)
		assert_almost_eq(
			float(r["damage"]), float(plain["damage"]) * 1.5, 2.0, "x1.5 on %d" % plain["damage"]
		)
		return
	fail_test("no seed lands both the hit and its counter")


## Arm Edren's Riposte, then let [param enemy] strike Lira, whom his Ironwall
## guards, under [param rng_seed]. Returns his counter, or {} when none came.
func _riposte(cmd: RefCounted, enemy: Enemy, rng_seed: int) -> Dictionary:
	_heal_all()
	_state.begin_turn(EDREN)
	_state.get_member(EDREN)["ap"] = 2
	assert_true(cmd.do_ability("party_0", _edren_ability("riposte", 0)), "Riposte is armed")
	_state.tick_statuses(EDREN)
	seed(rng_seed)
	var ripostes: Array = BattleActions.execute_enemy_attack(_state, enemy, LIRA).get(
		"ripostes", []
	)
	return ripostes[0] if not ripostes.is_empty() else {}


func test_an_auto_attack_on_an_enemy_carries_the_weapon_s_element() -> void:
	_arm_edren(FLAME_WEAPON)
	_afflict(EDREN, "berserk")
	var auto := BattleAutoAction.new(_battle, BattlePlayerActions.new(_battle))
	var s: int = _landing_seed()
	seed(s)
	auto.act_for(EDREN)
	var plain: int = 30000 - _enemy.current_hp
	assert_gt(plain, 0, "precondition: the berserk blow lands")
	var weak: Enemy = _make_enemy({"weaknesses": ["flame"]})
	_battle.enemies = [weak] as Array[Node]
	seed(s)
	auto.act_for(EDREN)
	assert_almost_eq(float(30000 - weak.current_hp), plain * 1.5, 2.0, "x1.5 on %d" % plain)


func test_a_plain_weapon_strikes_a_flame_weak_enemy_unmodified() -> void:
	var s: int = _landing_seed()
	var plain: int = int(_attack(EDREN, _enemy, s)["damage"])
	var weak: Enemy = _make_enemy({"weaknesses": ["flame"]})
	assert_eq(int(_attack(EDREN, weak, s)["damage"]), plain, "the starting sword has no element")


func test_an_overcharged_flame_weapon_takes_storm_on_a_storm_weak_enemy() -> void:
	# Flame is resisted, Storm is a weakness: the more favorable is Storm.
	_arm_edren(FLAME_WEAPON)
	var s: int = _landing_seed()
	var plain: int = int(_attack(EDREN, _enemy, s)["damage"])
	var target: Enemy = _make_enemy({"weaknesses": ["storm"], "resistances": ["flame"]})
	Forgewright.overcharge(_state, EDREN)
	var r: Dictionary = _attack(EDREN, target, s)
	assert_almost_eq(float(r["damage"]), plain * 1.5 * 1.5, 3.0, "+50% and the Storm weakness")


func test_an_overcharged_flame_weapon_takes_flame_on_a_flame_weak_enemy() -> void:
	_arm_edren(FLAME_WEAPON)
	var s: int = _landing_seed()
	var plain: int = int(_attack(EDREN, _enemy, s)["damage"])
	var target: Enemy = _make_enemy({"weaknesses": ["flame"], "resistances": ["storm"]})
	Forgewright.overcharge(_state, EDREN)
	var r: Dictionary = _attack(EDREN, target, s)
	assert_almost_eq(float(r["damage"]), plain * 1.5 * 1.5, 3.0, "+50% and the Flame weakness")


# --- Despair: the bearer deals 20% less damage, heals untouched ---


func test_a_despaired_member_s_attack_deals_four_fifths() -> void:
	var s: int = _landing_seed()
	var plain: int = int(_attack(CAEL, _enemy, s)["damage"])
	_afflict(CAEL, "despair")
	var r: Dictionary = _attack(CAEL, _enemy, s)
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


func test_a_despaired_member_s_spell_deals_four_fifths() -> void:
	var s: int = _landing_seed()
	var plain: int = int(_spell(MAREN, _enemy, s)["damage"])
	assert_gt(plain, 0, "precondition: the spell lands")
	_afflict(MAREN, "despair")
	var r: Dictionary = _spell(MAREN, _enemy, s)
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


func test_a_despaired_lira_s_shock_coil_deals_four_fifths() -> void:
	var s: int = _landing_seed()
	seed(s)
	var plain: int = int(Forgewright.shock(_state, LIRA, 10, _battle.enemies)["damage"])
	assert_gt(plain, 0, "precondition: the tick lands")
	_afflict(LIRA, "despair")
	seed(s)
	var r: Dictionary = Forgewright.shock(_state, LIRA, 10, _battle.enemies)
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


func test_a_despaired_member_s_absorbed_attack_heals_four_fifths() -> void:
	_arm_edren(FLAME_WEAPON)
	var s: int = _landing_seed()
	var sponge: Enemy = _make_enemy({"absorb": ["flame"]})
	sponge.current_hp = 20000
	var plain: int = int(_attack(EDREN, sponge, s)["damage"])
	_afflict(EDREN, "despair")
	var r: Dictionary = _attack(EDREN, sponge, s)
	assert_eq(r["type"], "absorb")
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


func test_a_despaired_member_s_absorbed_spell_heals_four_fifths() -> void:
	var s: int = _landing_seed()
	var sponge: Enemy = _make_enemy({"absorb": ["flame"]})
	sponge.current_hp = 20000
	seed(s)
	var mag: int = _state.get_effective_stat(MAREN, "mag")
	var plain: Dictionary = BattleActions.apply_magic_to_enemy(
		_state, MAREN, mag, 20, "flame", sponge, 0
	)
	assert_eq(plain["type"], "absorb", "precondition: the enemy drinks Flame")
	_afflict(MAREN, "despair")
	seed(s)
	var r: Dictionary = BattleActions.apply_magic_to_enemy(
		_state, MAREN, mag, 20, "flame", sponge, 0
	)
	assert_almost_eq(float(r["damage"]), plain["damage"] * 0.8, 1.0, "x0.8 on %d" % plain["damage"])


func test_a_despaired_member_s_heal_restores_in_full() -> void:
	var cmd: RefCounted = MagicCommand.new(_battle)
	var mend: Dictionary = {}
	for sp: Variant in DataManager.load_spells("spirit"):
		if (sp as Dictionary).get("id", "") == "mend":
			mend = sp
	assert_false(mend.is_empty(), "precondition: spirit.json has Mend")
	var command: Dictionary = {"type": "magic", "spell": mend, "target": CAEL}
	_state.get_member(CAEL)["current_hp"] = 100
	seed(7)
	cmd.do_magic("party_%d" % MAREN, command)
	var plain: int = int(_state.get_member(CAEL)["current_hp"]) - 100
	assert_gt(plain, 0, "precondition: Mend healed")
	_state.get_member(CAEL)["current_hp"] = 100
	_afflict(MAREN, "despair")
	seed(7)
	cmd.do_magic("party_%d" % MAREN, command)
	assert_eq(int(_state.get_member(CAEL)["current_hp"]) - 100, plain, "a heal is not damage")


func test_a_despaired_enemy_s_attack_deals_four_fifths() -> void:
	var s: int = _landing_seed()
	seed(s)
	var plain: int = int(BattleActions.execute_enemy_attack(_state, _enemy, CAEL)["damage"])
	assert_gt(plain, 0, "precondition: the seed lands")
	_heal_all()
	_enemy.apply_status("despair", 4)
	seed(s)
	var r: Dictionary = BattleActions.execute_enemy_attack(_state, _enemy, CAEL)
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


func test_a_despaired_enemy_s_spell_deals_four_fifths() -> void:
	var s: int = _landing_seed()
	seed(s)
	var plain: int = int(BattleActions.execute_enemy_magic(_state, _enemy, CAEL, "", 30)["damage"])
	assert_gt(plain, 0, "precondition: the seed lands")
	_heal_all()
	_enemy.apply_status("despair", 4)
	seed(s)
	var r: Dictionary = BattleActions.execute_enemy_magic(_state, _enemy, CAEL, "", 30)
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


func test_a_despaired_confused_member_s_blow_on_an_ally_deals_four_fifths() -> void:
	var s: int = _landing_seed()
	seed(s)
	var plain: int = int(BattleAutoAction.party_strikes_ally(_state, CAEL, MAREN)["damage"])
	assert_gt(plain, 0, "precondition: the seed lands")
	_heal_all()
	_afflict(CAEL, "despair")
	seed(s)
	var r: Dictionary = BattleAutoAction.party_strikes_ally(_state, CAEL, MAREN)
	assert_almost_eq(float(r["damage"]), plain * 0.8, 1.0, "x0.8 on %d" % plain)


## Lira deploys Thornveil Barrier on [param ally]; returns the counter an
## enemy's landing hit on that ally draws.
func _thornveil_counter(ally: int) -> int:
	var cmd: RefCounted = AbilityCommand.new(_battle)
	var barrier: Dictionary = {}
	for a: Variant in DataManager.load_abilities("lira"):
		if (a as Dictionary).get("id", "") == "thornveil_barrier":
			barrier = a
	_state.get_member(LIRA)["ac"] = 12
	var command: Dictionary = {"type": "ability", "ability": barrier, "target": ally}
	assert_true(cmd.do_ability("party_%d" % LIRA, command), "precondition: deployed")
	seed(_landing_seed())
	var r: Dictionary = BattleActions.execute_enemy_physical_ability(_state, _enemy, ally)
	assert_true(r["hit"], "precondition: the hit lands")
	return int(r["ripostes"][0]["damage"])


func test_a_despaired_lira_s_thornveil_barrier_counters_for_four_fifths() -> void:
	# 15% of Cael's 40 Defense is 6; cut by a fifth and floored, 4.
	_afflict(LIRA, "despair")
	assert_eq(_thornveil_counter(CAEL), 4)


func test_the_shielded_ally_s_despair_leaves_thornveil_barrier_s_counter_whole() -> void:
	_afflict(CAEL, "despair")
	assert_eq(_thornveil_counter(CAEL), 6, "15% of Cael's 40 Defense")


func test_a_despaired_edren_s_shatter_guard_deals_four_fifths_of_its_total() -> void:
	# DEF 999 puts the basic-attack floor at 1, below the total.
	_enemy = _make_enemy({"def": 999})
	_battle.enemies = [_enemy] as Array[Node]
	var cmd: RefCounted = AbilityCommand.new(_battle)
	var s: int = _landing_seed()
	assert_true(cmd.do_ability("party_0", _edren_ability("ironwall", LIRA)), "precondition")
	var total: int = 0
	for _i: int in range(2):
		seed(s)
		total += int(BattleActions.execute_enemy_attack(_state, _enemy, LIRA)["absorbed"]["damage"])
	assert_gt(total, 10, "precondition: a total well above the floor")
	_afflict(EDREN, "despair")
	_state.get_member(EDREN)["ap"] = 5
	var hp: int = _enemy.current_hp
	assert_true(cmd.do_ability("party_0", _edren_ability("shatter_guard", 0)), "resolves")
	assert_eq(hp - _enemy.current_hp, int(total * 0.8), "x0.8 on %d" % total)


func _edren_ability(ability_id: String, target: int) -> Dictionary:
	for a: Variant in DataManager.load_abilities("edren"):
		if (a as Dictionary).get("id", "") == ability_id:
			return {"type": "ability", "ability": a, "target": target}
	fail_test("edren.json has no ability '%s'" % ability_id)
	return {}


# --- Blind: physical hit rate halved before the clamp; spells untouched ---


func test_a_blinded_member_misses_an_attack_its_unhalved_hit_rate_lands() -> void:
	# A hit roll in [45, 90) lands at 90% and misses at 45%.
	var s: int = _seed_rolling(45, 90)
	assert_true(_attack(CAEL, _enemy, s)["hit"], "precondition: lands unblinded")
	_afflict(CAEL, "blind")
	var hp: int = _enemy.current_hp
	var r: Dictionary = _attack(CAEL, _enemy, s)
	assert_false(r["hit"], "a 90% hit rate halved is 45%")
	assert_eq(_enemy.current_hp, hp, "the miss dealt nothing")


func test_a_blinded_member_s_spell_keeps_its_full_hit_rate() -> void:
	var s: int = _seed_rolling(45, 90)
	_afflict(MAREN, "blind")
	var r: Dictionary = _spell(MAREN, _enemy, s)
	assert_true(r["hit"], "Blind is physical accuracy only")
	assert_gt(int(r["damage"]), 0)


func test_a_blinded_enemy_misses_an_attack_its_unhalved_hit_rate_lands() -> void:
	var s: int = _seed_rolling(45, 90)
	seed(s)
	assert_true(BattleActions.execute_enemy_attack(_state, _enemy, CAEL)["hit"], "precondition")
	_heal_all()
	_enemy.apply_status("blind", 4)
	seed(s)
	assert_false(BattleActions.execute_enemy_attack(_state, _enemy, CAEL)["hit"])


func test_a_blinded_enemy_s_spell_keeps_its_full_hit_rate() -> void:
	var s: int = _seed_rolling(45, 90)
	_enemy.apply_status("blind", 4)
	seed(s)
	assert_true(BattleActions.execute_enemy_magic(_state, _enemy, CAEL, "", 30)["hit"])


func test_a_blinded_confused_member_misses_an_ally_its_unhalved_hit_rate_lands() -> void:
	var s: int = _seed_rolling(45, 90)
	seed(s)
	assert_true(BattleAutoAction.party_strikes_ally(_state, CAEL, MAREN)["hit"], "precondition")
	_heal_all()
	_afflict(CAEL, "blind")
	seed(s)
	assert_false(BattleAutoAction.party_strikes_ally(_state, CAEL, MAREN)["hit"])


func test_a_blinded_enemy_misses_another_enemy_its_unhalved_hit_rate_lands() -> void:
	var other: Enemy = _make_enemy({})
	var s: int = _seed_rolling(45, 90)
	seed(s)
	assert_true(BattleAutoAction.enemy_strikes_enemy(_enemy, other)["hit"], "precondition")
	_enemy.apply_status("blind", 4)
	seed(s)
	assert_false(BattleAutoAction.enemy_strikes_enemy(_enemy, other)["hit"])


# --- An enemy's status meets the target's worn gear (#512) ---


## The enemy's Poison on Cael, at a base rate its MAG cannot dilute below 100,
## wearing an Antidote Charm, under the first seed whose rolls land it on him
## unguarded: only the charm stands between the status and him.
func _poison_cael() -> Dictionary:
	for s: int in range(1, 60):
		seed(s)
		var r: Dictionary = BattleActions.execute_enemy_status(
			_state, _enemy, CAEL, 150, "poison", null
		)
		if r["inflicted"]:
			_state.remove_status(CAEL, "poison")
			PartyState.get_member("cael")["equipment"]["accessory"] = "antidote_charm"
			seed(s)
			return BattleActions.execute_enemy_status(_state, _enemy, CAEL, 150, "poison", null)
	fail_test("no seed lands the Poison")
	return {}


func test_an_unguarded_member_takes_an_enemy_s_status() -> void:
	var r: Dictionary = {}
	for s: int in range(1, 60):
		seed(s)
		r = BattleActions.execute_enemy_status(_state, _enemy, CAEL, 150, "poison", null)
		if r["inflicted"]:
			break
	assert_eq(r["type"], "status")
	assert_true(_state.has_status(CAEL, "poison"))


func test_worn_gear_that_wards_off_a_status_reads_as_immune() -> void:
	var r: Dictionary = _poison_cael()
	assert_true(r["hit"])
	assert_false(r["inflicted"], "the Antidote Charm wards off Poison")
	assert_eq(r["type"], "immune")
	assert_false(_state.has_status(CAEL, "poison"))
