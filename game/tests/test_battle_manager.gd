extends GutTest
## Integration tests for the battle system.
## Tests full pipeline composition and formula verification.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Edren in slot 0, Cael in slot 1.
const EDREN := 0
const CAEL := 1

var _booted: Node = null


func before_each() -> void:
	GameManager.transition_data = {}


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


# --- Full Physical Pipeline ---


func test_physical_pipeline_edren_lv1() -> void:
	seed(42)
	var atk: int = 18
	var def_val: int = 5
	var spd: int = 10
	var target_spd: int = 5
	var lck: int = 8
	var hit: bool = DamageCalc.roll_hit(spd, target_spd)
	if not hit:
		pass_test("miss is valid outcome")
		return
	var evaded: bool = DamageCalc.roll_evasion(target_spd)
	if evaded:
		pass_test("evasion is valid outcome")
		return
	var is_crit: bool = DamageCalc.roll_crit(lck)
	var dmg: int = DamageCalc.calculate_physical(
		atk, 1.0, def_val, is_crit, 1.0, "front", "front", false, [], false, 1.0
	)
	if is_crit:
		assert_between(dmg, 91, 98, "crit range")
	else:
		assert_between(dmg, 45, 49, "normal range")


# --- Full Magic Pipeline ---


func test_magic_pipeline_maren_lv1() -> void:
	seed(42)
	var mag: int = 22
	var power: int = 14
	var mdef: int = 8
	var spd: int = 8
	var target_spd: int = 5
	var hit: bool = DamageCalc.roll_hit(spd, target_spd)
	if not hit:
		pass_test("miss is valid")
		return
	var evaded: bool = DamageCalc.roll_evasion(target_spd)
	if evaded:
		pass_test("evaded is valid")
		return
	var dmg: int = DamageCalc.calculate_magic(mag, power, mdef, 1.0, 1.0, [], [])
	assert_between(dmg, 64, 69, "magic damage range")


# --- Flee Formula ---


func test_flee_equal_speed() -> void:
	assert_eq(DamageCalc.calculate_flee_chance(50.0, 50.0), 50)


func test_flee_fast_party_capped_at_90() -> void:
	assert_eq(DamageCalc.calculate_flee_chance(100.0, 50.0), 90)


func test_flee_slow_party_floored_at_10() -> void:
	assert_eq(DamageCalc.calculate_flee_chance(10.0, 100.0), 10)


# --- Damage Reduction Pipeline ---


func test_pallors_last_plus_deeproot_reduction() -> void:
	# Pallor Last 25% + Deeproot 15% → product = 0.75 * 0.85 = 0.6375
	var no_red: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0
	)
	var with_red: int = DamageCalc.calculate_physical(
		100, 1.0, 10, false, 1.0, "front", "front", false, [0.25, 0.15], false, 1.0
	)
	var ratio: float = float(with_red) / float(no_red)
	assert_between(ratio, 0.60, 0.68, "stacked reduction ratio ~63.75%")


# --- Elemental System ---


func test_weakness_multiplier_1_5x() -> void:
	var neutral: int = DamageCalc.calculate_magic(100, 50, 20, 1.0, 1.0, [], [])
	var weak: int = DamageCalc.calculate_magic(100, 50, 20, 1.5, 1.0, [], [])
	var ratio: float = float(weak) / float(neutral)
	assert_between(ratio, 1.4, 1.6, "1.5x weakness multiplier")


func test_resistance_multiplier_0_5x() -> void:
	var neutral: int = DamageCalc.calculate_magic(100, 50, 20, 1.0, 1.0, [], [])
	var resist: int = DamageCalc.calculate_magic(100, 50, 20, 0.5, 1.0, [], [])
	assert_lt(resist, neutral, "same-element resistance reduces damage")


# --- Healing Cap ---


func test_healing_caps_at_14999() -> void:
	var result: int = DamageCalc.calculate_healing(255, 120)
	assert_eq(result, 14999, "healing capped at 14999")


# --- Status Accuracy Edge Cases ---


func test_status_with_zero_mag_and_mdef() -> void:
	assert_false(DamageCalc.roll_status(75, 0, 0, 0), "guard against div-by-zero")


func test_status_high_mag_vs_low_mdef() -> void:
	seed(500)
	var successes: int = 0
	for i: int in range(100):
		if DamageCalc.roll_status(90, 200, 10, 10):
			successes += 1
	assert_gt(successes, 30, "high MAG lands status frequently")


# --- The Ability command (GAP-002, #158 slice a) ---


## Boot a real battle against one Ley Vermin, driven frame by frame by hand.
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
	battle.set_process(false)
	_booted = battle
	return battle


## Give [param slot] the turn: fill its gauge and run one frame, which prompts it.
func _give_turn(battle: Node, slot: int) -> void:
	battle.get_atb().set_gauge("party_%d" % slot, ATBSystem.GAUGE_MAX)
	battle._process(0.0)


## Submit a command the way the battle UI does.
func _submit(battle: Node, command: Dictionary) -> void:
	battle.get_node("BattleUI").command_submitted.emit(command)


func _ability(character_id: String, ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities(character_id):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("%s has no ability '%s'" % [character_id, ability_id])
	return {}


func test_cael_s_ability_issues_the_rally_and_ends_his_turn() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	var mp_before: int = state.get_member(CAEL)["current_mp"]
	var def_before: int = state.get_effective_stat(EDREN, "def")
	_give_turn(battle, CAEL)
	_submit(battle, {"type": "ability", "ability": _ability("cael", "hold_the_line")})
	assert_eq(state.get_member(CAEL)["current_mp"], mp_before - 6, "Hold the Line costs 6 MP")
	assert_eq(state.get_effective_stat(EDREN, "def"), def_before * 115 / 100, "Edren +15% DEF")
	assert_eq(battle.get_atb().get_gauge("party_%d" % CAEL), 0, "Cael's turn is spent")


func test_ability_for_a_character_whose_command_is_unbuilt_still_attacks() -> void:
	# Bulwark is #158 slice b. Until then Edren's Ability keeps the placeholder
	# it has always had: a basic attack on the chosen enemy, costing nothing.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	watch_signals(battle)
	var mp_before: int = state.get_member(EDREN)["current_mp"]
	_give_turn(battle, EDREN)
	_submit(battle, {"type": "ability", "ability": _ability("edren", "ironwall"), "target": 0})
	assert_signal_emitted_with_parameters(battle, "message", ["Edren attacks!"])
	assert_eq(state.get_member(EDREN)["current_mp"], mp_before, "no MP spent")
	assert_eq(battle.get_atb().get_gauge("party_%d" % EDREN), 0, "the turn is spent")


func test_second_wind_heals_an_ally_as_its_turn_begins() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.take_damage(EDREN, 40)
	var hp_before: int = state.get_member(EDREN)["current_hp"]
	var regen: int = state.get_member(EDREN)["max_hp"] * 5 / 100
	state.start_rally(CAEL, "second_wind", AbilityCommand.RALLY_EFFECTS["second_wind"])
	watch_signals(battle)
	_give_turn(battle, EDREN)
	assert_eq(state.get_member(EDREN)["current_hp"], hp_before + regen, "5% max HP restored")
	assert_signal_emitted_with_parameters(battle, "damage_dealt", ["party_0", regen, "heal"])


func test_press_forward_speeds_up_the_atb_gauge() -> void:
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	atb.set_gauge("party_0", 0)
	battle._process(0.0)
	var unbuffed_fill: int = atb.get_gauge("party_0")
	battle.get_battle_state().start_rally(
		CAEL, "press_forward", AbilityCommand.RALLY_EFFECTS["press_forward"]
	)
	atb.set_gauge("party_0", 0)
	battle._process(0.0)
	assert_gt(atb.get_gauge("party_0"), unbuffed_fill, "+10% SPD fills the gauge faster")
