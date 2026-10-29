extends GutTest
## Edren's Bulwark under the rulings of 2026-10-29 on #158 (recorded in
## abilities.md § Edren — Bulwark): a direct hit on Edren in a stance counts as
## absorbed; Shatter Guard's floor is one basic attack; an incapacitated Edren
## does not counter; Oathkeeper keeps his stance up; a KO clears all Bulwark
## state. Plus the edges review round 1 of PR #497 found unpinned.
##
## The rest of Bulwark is test_battle_bulwark.gd and
## test_battle_bulwark_reactions.gd.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const EDREN := 0
const CAEL := 1
const LIRA := 2
const MAREN := 3
const ATK := 50
const ENEMY_DEF := 10


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
var _hits: Array = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["edren", "cael", "lira", "maren"][slot]))
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
			"atk": ATK,
			"def": 40,
			"mag": 20,
			"mdef": 20,
			"spd": 1,
			"lck": 0,
		},
	}


## A slow enemy: its hits land on SPD 1 allies nine times in ten, and Edren's
## counters land on it nine times in ten.
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


func _hp(slot: int) -> int:
	return int(_state.get_member(slot)["current_hp"])


func _strike(slot: int, rng_seed: int, kind: String = "physical", by: Node = null) -> Dictionary:
	seed(rng_seed)
	var attacker: Node = _enemy if by == null else by
	if kind == "magic":
		return BattleActions.execute_enemy_magic(_state, attacker, slot, "", 20)
	return BattleActions.execute_enemy_attack(_state, attacker, slot)


## A seed whose [param kind] hit on [param slot] lands, found with no stance up.
func _landing_seed(slot: int, kind: String = "physical") -> int:
	for s: int in range(1, 60):
		if _strike(slot, s, kind).get("hit", false):
			return s
	fail_test("no landing seed")
	return 0


## A seed whose hit on [param slot] lands and whose counter (Oathkeeper is up)
## [param counter_lands], or -1. Each try is absorbed, so AP moves.
func _counter_seed(slot: int, counter_lands: bool) -> int:
	for s: int in range(1, 200):
		var r: Dictionary = _strike(slot, s)
		var ripostes: Array = r.get("ripostes", [])
		if not ripostes.is_empty() and bool(ripostes[0]["hit"]) == counter_lands:
			return s
	fail_test("no such seed")
	return -1


## The range one basic attack at ability_mult 1.0 deals, before crits:
## (ATK^2 / 6) x pre_def - DEF, times variance 240..255 / 256.
func _basic_range(def: int, pre_def: float = 1.0) -> Array[int]:
	var raw: float = maxf(1.0, ATK * ATK / 6.0 * pre_def - def)
	return [int(raw * 240 / 256.0), int(raw * 255 / 256.0)]


func _oathkeeper() -> void:
	_set_ap(8)
	assert_true(_use("oathkeeper"), "Oathkeeper resolves")


# --- Ruling 1: a direct hit on Edren in a stance counts as absorbed ---


func test_a_direct_hit_on_edren_in_a_stance_earns_ap_and_lands_in_full() -> void:
	var s: int = _landing_seed(EDREN)
	var full: int = int(_strike(EDREN, s)["damage"])
	_use("ironwall", LIRA)
	var hp: int = _hp(EDREN)
	var r: Dictionary = _strike(EDREN, s)
	assert_eq(hp - _hp(EDREN), full, "Edren takes his own hit in full")
	assert_false(r.has("absorbed"), "no share to show apart")
	assert_eq(_ap(), 1, "but it counts as absorbed: 1 AP")


func test_a_heavy_direct_hit_earns_the_bonus_ap() -> void:
	var s: int = _landing_seed(EDREN)
	var full: int = int(_strike(EDREN, s)["damage"])
	_state.get_member(EDREN)["max_hp"] = full * 10 - 1
	_use("rampart")
	_strike(EDREN, s)
	assert_eq(_ap(), 2, "over 10% of his max HP: 1 + 1")


func test_any_direct_hit_counts_even_one_ironwall_does_not_cover() -> void:
	var s: int = _landing_seed(EDREN, "magic")
	_use("ironwall", LIRA)  # Ironwall covers physical damage only
	_strike(EDREN, s, "magic")
	assert_eq(_ap(), 1, "a magic hit on Edren himself still counts")


func test_a_direct_hit_without_a_stance_earns_nothing() -> void:
	_strike(EDREN, _landing_seed(EDREN))
	assert_eq(_ap(), 0, "no stance, no absorb")


func test_a_direct_hit_adds_to_shatter_guard_s_total() -> void:
	var tough: Enemy = _make_enemy({"def": 999})  # basic-attack floor of 1
	_battle.enemies = [tough] as Array[Node]
	var s: int = _landing_seed(EDREN)
	_use("rampart")
	var hp: int = _hp(EDREN)
	_strike(EDREN, s)
	var taken: int = hp - _hp(EDREN)
	_set_ap(5)
	var before: int = tough.current_hp
	_use("shatter_guard")
	assert_eq(before - tough.current_hp, taken, "the hit he took is the total")


func test_a_direct_hit_triggers_an_armed_riposte() -> void:
	var s: int = _landing_seed(EDREN)
	_use("rampart")
	_set_ap(2)
	_use("riposte")
	assert_eq(_strike(EDREN, s).get("ripostes", []).size(), 1, "he counters his own attacker")


# --- Ruling 2: Shatter Guard's floor is one basic attack on each enemy ---


func test_shatter_guard_s_floor_is_a_basic_attack_against_each_enemy() -> void:
	var spirit: Enemy = _make_enemy({"type": "spirit"})
	_battle.enemies = [_enemy, spirit] as Array[Node]
	_use("rampart")
	_set_ap(5)
	var before: Array[int] = [_enemy.current_hp, spirit.current_hp]
	seed(3)
	_use("shatter_guard")
	var plain: Array[int] = _basic_range(ENEMY_DEF)
	var halved: Array[int] = _basic_range(ENEMY_DEF, 0.5)
	assert_between(before[0] - _enemy.current_hp, plain[0], plain[1], "a basic attack's damage")
	assert_between(before[1] - spirit.current_hp, halved[0], halved[1], "a Spirit halves it")


func test_a_total_above_the_floor_lands_unchanged() -> void:
	var tough: Enemy = _make_enemy({"def": 999})
	_battle.enemies = [tough] as Array[Node]
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	var total: int = int(_strike(LIRA, s)["absorbed"]["damage"])
	_set_ap(5)
	var before: int = tough.current_hp
	_use("shatter_guard")
	assert_eq(before - tough.current_hp, total, "fixed: DEF 999 does not shrink it")


func test_shatter_guard_is_capped_at_14999() -> void:
	var brute: Enemy = _make_enemy({"atk": 255, "def": 999, "hp": 90000})
	_battle.enemies = [brute] as Array[Node]
	for slot: int in [EDREN, CAEL]:
		_state.get_member(slot)["max_hp"] = 99999
		_state.get_member(slot)["current_hp"] = 99999
	_use("ironwall", CAEL)
	var total: int = 0
	for s: int in range(1, 40):
		total += int(_strike(CAEL, s, "physical", brute).get("absorbed", {}).get("damage", 0))
		if total > 14999:
			break
	assert_gt(total, 14999, "absorbed past the cap")
	_set_ap(5)
	var before: int = brute.current_hp
	_use("shatter_guard")
	assert_eq(before - brute.current_hp, 14999, "the damage cap holds")


func test_shatter_guard_skips_an_untargetable_enemy() -> void:
	var diver: Enemy = _make_enemy({})
	diver.set_meta("untargetable", true)
	_battle.enemies = [_enemy, diver] as Array[Node]
	_use("rampart")
	_set_ap(5)
	var before: int = diver.current_hp
	_use("shatter_guard")
	assert_eq(diver.current_hp, before, "a diving enemy is out of reach")


func test_shatter_guard_counts_as_threat_on_every_enemy_it_hits() -> void:
	var second: Enemy = _make_enemy({})
	_battle.enemies = [_enemy, second] as Array[Node]
	_use("rampart")
	_set_ap(5)
	var before: Array[int] = [_enemy.current_hp, second.current_hp]
	_use("shatter_guard")
	var dealt: int = (before[0] - _enemy.current_hp) + (before[1] - second.current_hp)
	assert_eq(int(_state.get_member(EDREN)["threat_dealt"]), dealt, "threat = damage dealt")


# --- Ruling 3: an incapacitated Edren does not counter, but still absorbs ---


func test_a_paralyzed_or_stopped_edren_absorbs_but_does_not_counter() -> void:
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	_oathkeeper()
	for status: String in ["paralysis", "stop"]:
		_state.apply_status(EDREN, status, "realtime" if status == "stop" else "turns", 3)
		var r: Dictionary = _strike(LIRA, s)
		assert_true(r.has("absorbed"), "%s: the stance still absorbs" % status)
		assert_false(r.has("ripostes"), "%s: no counter" % status)
		_state.remove_status(EDREN, status)
	assert_true(_strike(LIRA, s).has("ripostes"), "and counters again once it clears")


func test_an_armed_riposte_waits_out_an_incapacitated_edren() -> void:
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	_set_ap(2)
	_use("riposte")
	_state.apply_status(EDREN, "paralysis", "turns", 3)
	assert_false(_strike(LIRA, s).has("ripostes"), "no counter while Paralyzed")
	_state.remove_status(EDREN, "paralysis")
	assert_true(_strike(LIRA, s).has("ripostes"), "the armed Riposte was not spent")


func test_a_sleep_the_absorbed_hit_cures_does_not_block_the_counter() -> void:
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	_oathkeeper()
	_state.apply_status(EDREN, "sleep", "turns", -1)
	var r: Dictionary = _strike(LIRA, s)
	assert_false(_state.has_status(EDREN, "sleep"), "his share woke him")
	assert_true(r.has("ripostes"), "so he counters")


func test_petrify_ends_the_stance() -> void:
	_use("rampart")
	_state.apply_status(EDREN, "petrify", "turns", -1)
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "a petrified Edren holds nothing")


# --- Ruling 4: Oathkeeper keeps the stance up; Attack still drops it ---


func test_taking_up_oathkeeper_keeps_the_stance_and_an_attack_drops_it() -> void:
	_state.begin_turn(EDREN)
	_use("rampart")
	_state.tick_statuses(EDREN)
	_state.begin_turn(EDREN)
	_oathkeeper()
	_state.tick_statuses(EDREN)
	assert_eq(_state.get_member(EDREN)["active_stance"], "rampart", "held through Oathkeeper")
	_state.begin_turn(EDREN)
	BattlePlayerActions.new(_battle).do_attack("party_%d" % EDREN, {"type": "attack", "target": 0})
	_state.tick_statuses(EDREN)
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "dropped after an Attack")


# --- Ruling 5: a KO clears all Bulwark state ---


func test_a_ko_clears_every_bulwark_effect_on_edren() -> void:
	var s: int = _landing_seed(LIRA)
	var base_def: int = _state.get_effective_stat(EDREN, "def")
	_set_ap(10)
	_use("steadfast_resolve")  # -6: 4 AP left
	_use("aegis_veil", EDREN)  # -3: 1 AP left
	_use("ironwall", LIRA)
	_set_ap(2)
	assert_true(_use("riposte"), "armed before Oathkeeper, which would refuse it")
	_set_ap(10)
	_use("oathkeeper")  # -8
	_set_ap(7)
	_state.take_damage(EDREN, 99999)
	_state.heal(EDREN, 5000, true)
	assert_eq(_ap(), 0, "AP back to 0")
	assert_eq(_state.get_member(EDREN)["active_stance"], "", "stance dropped")
	assert_eq(_state.get_effective_stat(EDREN, "def"), base_def, "Steadfast Resolve ended")
	assert_eq(Bulwark.reductions(_state, EDREN, "magic"), [] as Array[float], "Aegis Veil ended")
	_use("ironwall", LIRA)
	assert_eq(Bulwark.guard_for(_state, LIRA, "physical")["pct"], 50, "Oathkeeper ended")
	assert_false(_strike(LIRA, s).has("ripostes"), "Riposte disarmed")


# --- Readings: Riposte under Oathkeeper, and against magic ---


func test_riposte_is_grayed_and_refused_while_oathkeeper_is_up() -> void:
	_oathkeeper()
	_set_ap(2)
	var riposte: Dictionary = _ability("riposte")
	assert_false(AbilityCommand.is_available(_state.get_member(EDREN), riposte), "grayed out")
	assert_false(_use("riposte"), "refused: it is already automatic")
	assert_eq(_ap(), 2, "nothing spent")


func test_riposte_counters_a_magic_hit_rampart_absorbs() -> void:
	var s: int = _landing_seed(LIRA, "magic")
	_use("rampart")
	_set_ap(2)
	_use("riposte")
	assert_eq(_strike(LIRA, s, "magic").get("ripostes", []).size(), 1, "magic is countered too")


# --- Edges review round 1 found unpinned ---


func test_a_counter_that_misses_earns_no_ap() -> void:
	_use("ironwall", LIRA)
	_oathkeeper()
	var s: int = _counter_seed(LIRA, false)
	_set_ap(0)
	var r: Dictionary = _strike(LIRA, s)
	assert_false(r["ripostes"][0]["hit"], "the counter missed")
	assert_eq(_ap(), 1, "only the absorbed hit's AP")


func test_an_edren_felled_by_his_own_share_does_not_counter() -> void:
	# The KO clears Oathkeeper (ruling 5) before the counter is asked for.
	var s: int = _landing_seed(LIRA)
	_use("ironwall", LIRA)
	_oathkeeper()
	_state.get_member(EDREN)["current_hp"] = 1
	var r: Dictionary = _strike(LIRA, s)
	assert_false(_state.get_member(EDREN)["is_alive"], "the share felled him")
	assert_false(r.has("ripostes"), "and a fallen Edren does not counter")


func test_an_armed_riposte_is_not_spent_on_a_dead_attacker() -> void:
	# An enemy's death burst strikes after it has fallen (aoe_on_death).
	var s: int = _landing_seed(LIRA, "magic")
	var corpse: Enemy = _make_enemy({})
	corpse.is_alive = false
	_use("rampart")
	_set_ap(2)
	_use("riposte")
	assert_false(_strike(LIRA, s, "magic", corpse).has("ripostes"), "no counter on the dead")
	assert_eq(_strike(LIRA, s, "magic").get("ripostes", []).size(), 1, "still armed")


func test_rampart_and_aegis_veil_on_one_ally_each_apply_once_where_they_belong() -> void:
	var magic: int = _landing_seed(LIRA, "magic")
	var physical: int = _landing_seed(LIRA)
	var full_magic: int = int(_strike(LIRA, magic, "magic")["damage"])
	var full_physical: int = int(_strike(LIRA, physical)["damage"])
	_set_ap(3)
	_use("aegis_veil", LIRA)
	_use("rampart")
	var hp: int = _hp(EDREN)
	var r: Dictionary = _strike(LIRA, magic, "magic")
	assert_eq(r["damage"], int(full_magic * ((1.0 - 0.3) * (1.0 - 0.4))), "Lira: 70% x 60%")
	assert_eq(hp - _hp(EDREN), int(full_magic * 30 / 100.0), "Edren: 30%, unveiled")
	r = _strike(LIRA, physical)
	assert_eq(r["damage"], int(full_physical * (1.0 - 0.3)), "physical: the veil does nothing")


func test_aegis_veil_on_a_fallen_ally_is_refused_without_cost() -> void:
	_state.take_damage(LIRA, 99999)
	_set_ap(3)
	assert_false(_use("aegis_veil", LIRA), "no living target")
	assert_eq(_ap(), 3, "AP not paid")


func test_a_flurry_stops_when_a_counter_fells_the_attacker() -> void:
	_use("ironwall", LIRA)
	_oathkeeper()
	var s: int = _counter_seed(LIRA, true)
	_enemy.current_hp = 1
	seed(s)
	var r: Dictionary = BattleActions.execute_enemy_physical_ability(_state, _enemy, LIRA, 1.0, 3)
	assert_false(_enemy.is_alive, "the first counter felled it")
	assert_eq(int(r["hits_landed"]), 1, "and it struck no more")


func test_oathkeeper_s_second_swing_does_not_hit_a_corpse() -> void:
	_oathkeeper()
	var actions: BattlePlayerActions = BattlePlayerActions.new(_battle)
	for s: int in range(1, 40):
		_enemy.current_hp = 1
		_enemy.is_alive = true
		_hits.clear()
		seed(s)
		actions.do_attack("party_%d" % EDREN, {"type": "attack", "target": 0})
		if _hits[0][2] != "miss":
			assert_false(_enemy.is_alive, "the first swing felled it")
			assert_eq(_hits.size(), 1, "no second swing at the body")
			return
	fail_test("the first swing never landed")


func test_steadfast_resolve_passes_over_a_fallen_ally() -> void:
	var base_def: int = _state.get_effective_stat(LIRA, "def")
	_state.take_damage(LIRA, 99999)
	_set_ap(6)
	_use("steadfast_resolve")
	_state.heal(LIRA, 100, true)
	assert_eq(_state.get_effective_stat(LIRA, "def"), base_def, "she was down when it was cast")


# --- The design text: doc and data agree word for word ---


func _doc_row(ability_name: String) -> String:
	var repo_root: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var doc: String = FileAccess.get_file_as_string(repo_root + "/docs/story/abilities.md")
	for line: String in doc.split("\n"):
		if line.begins_with("| **%s** |" % ability_name):
			var cells: PackedStringArray = line.split("|")
			return cells[cells.size() - 2].strip_edges()
	fail_test("abilities.md has no %s row" % ability_name)
	return ""


func test_riposte_and_shatter_guard_read_the_same_in_the_doc_and_the_data() -> void:
	for pair: Array in [["Riposte", "riposte"], ["Shatter Guard", "shatter_guard"]]:
		assert_eq(_ability(pair[1])["effect"], _doc_row(pair[0]), "%s: doc = data" % pair[0])
