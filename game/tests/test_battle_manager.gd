extends GutTest
## Integration tests for the battle system.
## Tests full pipeline composition and formula verification.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

## New-game party: Edren in slot 0, Cael in slot 1.
const EDREN := 0
const CAEL := 1

var _booted: Node = null


## The slice of the battle the Flee command reaches: its party, its enemies,
## and where an escape ends up.
class FleeBattle:
	extends Node
	signal message(text: String)
	signal flee_result(success: bool)
	var state: Node
	var enemies: Array[Node] = []
	var escapes: int = 0

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return enemies

	func exit_battle(_result: String) -> void:
		escapes += 1


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


## Boot a real battle (one Ley Vermin unless [param encounter] says otherwise),
## driven frame by frame by hand.
func _boot(encounter: Array = ["ley_vermin"]) -> Node:
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
	# Hold the Line's +15% DEF on Edren, 6 MP from Cael, and his turn spent.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	var mp_before: int = state.get_member(CAEL)["current_mp"]
	var def_before: int = state.get_effective_stat(EDREN, "def")
	_give_turn(battle, CAEL)
	_submit(battle, {"type": "ability", "ability": _ability("cael", "hold_the_line")})
	assert_eq(state.get_member(CAEL)["current_mp"], mp_before - 6, "Hold the Line costs 6 MP")
	assert_eq(state.get_effective_stat(EDREN, "def"), def_before * 115 / 100, "Edren +15% DEF")
	assert_eq(battle.get_atb().get_gauge("party_%d" % CAEL), 0, "Cael's turn is spent")


func test_second_wind_heals_an_ally_as_its_turn_begins() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.take_damage(EDREN, 40)
	var hp_before: int = state.get_member(EDREN)["current_hp"]
	var regen: int = state.get_member(EDREN)["max_hp"] * 5 / 100
	BattleRally.start(state, CAEL, "second_wind", AbilityCommand.RALLY_EFFECTS["second_wind"])
	watch_signals(battle)
	_give_turn(battle, EDREN)
	assert_eq(state.get_member(EDREN)["current_hp"], hp_before + regen, "5% max HP restored")
	assert_signal_emitted_with_parameters(battle, "damage_dealt", ["party_0", regen, "heal"])


func test_press_forward_s_speed_is_what_the_atb_gauge_fills_at() -> void:
	# One fixed tick fills a gauge by calculate_fill_rate(spd, ...); after Press
	# Forward that spd must be the member's buffed effective SPD.
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	var state: Node = battle.get_battle_state()
	var speed: int = ATBSystem.settings_from_config(PartyState.get_config())["speed"]
	BattleRally.start(state, CAEL, "press_forward", AbilityCommand.RALLY_EFFECTS["press_forward"])
	var buffed_spd: int = state.get_effective_stat(EDREN, "spd")
	atb.set_gauge("party_0", 0)
	battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
	assert_eq(
		atb.get_gauge("party_0"),
		atb.calculate_fill_rate(buffed_spd, speed, []),
		"the gauge filled at Edren's +10% SPD"
	)


func test_cael_s_second_wind_heals_him_on_four_turns_like_every_ally() -> void:
	# abilities.md § Cael — Rally: "for 4 turns". The turn Cael issues it on is
	# not one of the four.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.take_damage(CAEL, 60)
	_give_turn(battle, CAEL)
	_submit(battle, {"type": "ability", "ability": _ability("cael", "second_wind")})
	var heals: int = 0
	for _i: int in range(6):
		var hp: int = state.get_member(CAEL)["current_hp"]
		_give_turn(battle, CAEL)
		if state.get_member(CAEL)["current_hp"] > hp:
			heals += 1
		_submit(battle, {"type": "defend"})
	assert_eq(heals, 4, "four regen turns, then none")


func test_real_time_statuses_run_on_the_seconds_the_gauges_advanced() -> void:
	# A frame stops early at the first gauge to fill, so a Stop timer must
	# lose only the battle time that frame actually ran, not the raw delta.
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	var state: Node = battle.get_battle_state()
	state.apply_status(CAEL, "stop", "realtime", 0.1)
	atb.set_gauge("party_0", ATBSystem.GAUGE_MAX - 1)  # fills on the first tick
	battle._process(0.5)
	assert_true(state.has_status(CAEL, "stop"), "one tick of battle time is not 0.1 s")


# --- Stop on enemies (#246 slice 1) ---


func _spell(tradition: String, spell_id: String) -> Dictionary:
	for s: Variant in DataManager.load_spells(tradition):
		if (s as Dictionary).get("id", "") == spell_id:
			return s
	fail_test("%s has no spell '%s'" % [tradition, spell_id])
	return {}


func test_stillwatch_stops_an_enemy_and_says_so() -> void:
	# magic.md § Stillwatch: 55% to inflict Stop, "frozen for 3 seconds".
	var stillwatch: Dictionary = _spell("ley_line", "stillwatch")
	for s: int in range(1, 40):
		var battle: Node = _boot()
		var vermin: Node = battle.get_enemies()[0]
		battle.get_battle_state().get_member(CAEL)["current_mp"] = 99
		var messages: Array[String] = []
		battle.message.connect(func(t: String) -> void: messages.append(t))
		seed(s)
		_give_turn(battle, CAEL)
		_submit(battle, {"type": "magic", "spell": stillwatch, "target": 0})
		if vermin.has_status("stop"):
			assert_does_not_have(messages, "No effect!", "Stop is a real status now")
			assert_has(messages, "%s is Stopped!" % vermin.get_display_name(), "announced")
			return
		_booted.set("_battle_active", false)
		_booted.free()
		_booted = null
	fail_test("Stillwatch never landed")


func test_a_stopped_enemy_s_gauge_holds_and_resumes_after_three_seconds() -> void:
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	var vermin: Node = battle.get_enemies()[0]
	for i: int in range(2):  # keep the party out of the way
		battle.get_battle_state().apply_status(i, "sleep", "turns", -1)
	atb.set_gauge("enemy_0", 100)
	vermin.apply_status("stop", 3)
	for _i: int in range(170):  # 2.83 s of battle time, one tick a frame
		battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
	assert_eq(atb.get_gauge("enemy_0"), 100, "frozen at the value Stop found it at")
	assert_true(vermin.has_status("stop"), "under 3 s: still Stopped")
	for _i: int in range(20):
		battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
	assert_false(vermin.has_status("stop"), "3 s of battle time wore it off")
	assert_gt(atb.get_gauge("enemy_0"), 100, "the gauge resumed from where it froze")


func test_a_stopped_enemy_with_a_full_gauge_takes_no_turn() -> void:
	# combat-formulas.md § Status Effect ATB Interactions: a gauge-frozen
	# combatant takes no turn at all, and its full gauge is never spent.
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	var vermin: Node = battle.get_enemies()[0]
	atb.set_gauge("enemy_0", ATBSystem.GAUGE_MAX)
	vermin.apply_status("stop", 3)
	watch_signals(battle)
	battle._process(0.0)
	assert_eq(atb.get_gauge("enemy_0"), ATBSystem.GAUGE_MAX, "the full gauge is kept")
	assert_signal_not_emitted(battle, "damage_dealt", "the vermin did not act")


# --- Petrify removes an enemy from combat (#246 slice 6) ---
# magic.md § Status Effect Reference > 'Petrify': removed from combat. Ruling
# (2026-10-29): a petrified enemy pays full rewards at victory.


func test_petrifying_the_last_enemy_wins_the_battle_with_full_rewards() -> void:
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	watch_signals(battle)
	vermin.apply_status("petrify", -1)
	battle._process(0.0)
	assert_signal_emitted(battle, "victory", "a petrified field is a won field")
	var rewards: Dictionary = get_signal_parameters(battle, "victory")[0]
	assert_eq(rewards["xp"], int(vermin.enemy_data["exp"]), "full XP for the statue")
	assert_eq(rewards["gold"], int(vermin.enemy_data["gold"]), "full gold for the statue")


func test_a_petrified_enemy_cannot_be_targeted_and_the_battle_goes_on() -> void:
	var battle: Node = _boot(["ley_vermin", "ley_vermin"])
	var enemies: Array[Node] = battle.get_enemies()
	watch_signals(battle)
	enemies[0].apply_status("petrify", -1)
	battle._process(0.0)
	assert_signal_not_emitted(battle, "victory", "one enemy still stands")
	assert_eq(BattleActions.resolve_enemy_target(0, enemies), 1, "the cursor skips the statue")
	enemies[1].take_damage(9999)
	battle._process(0.0)
	assert_signal_emitted(battle, "victory", "the last one fell")
	assert_eq(
		get_signal_parameters(battle, "victory")[0]["xp"],
		2 * int(enemies[0].enemy_data["exp"]),
		"the statue's XP is paid alongside the kill's"
	)


func test_a_petrified_enemy_s_drop_is_rolled_at_victory() -> void:
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	vermin.enemy_data = vermin.enemy_data.duplicate(true)
	vermin.enemy_data["drop"] = {"item_id": "sharp_fang", "rate": 100}
	watch_signals(battle)
	vermin.apply_status("petrify", -1)
	battle._process(0.0)
	var drops: Array = get_signal_parameters(battle, "victory")[0]["drops"]
	assert_eq(drops, [{"item_id": "sharp_fang"}], "the statue's 100% drop is paid")


func test_a_lone_diving_boss_is_not_a_victory() -> void:
	# Untargetable is not removed: the Fenmother under water is still fighting.
	var battle: Node = _boot(["corrupted_fenmother"])
	battle.get_enemies()[0].set_meta("untargetable", true)
	watch_signals(battle)
	battle._process(0.0)
	assert_signal_not_emitted(battle, "victory", "it will resurface")


func test_enemy_stop_counts_battle_seconds_not_frame_time() -> void:
	# combat-formulas.md § Status Effect ATB Interactions: in Wait mode the Stop
	# countdown pauses while a sub-menu is open.
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	var vermin: Node = battle.get_enemies()[0]
	vermin.apply_status("stop", 3)
	atb.set_atb_mode("wait")
	atb.set_submenu_open(true)
	battle._process(5.0)
	assert_true(vermin.has_status("stop"), "paused battle time does not run Stop down")


# --- A revived member fights on (#246 review) ---


func test_a_member_revived_mid_battle_takes_turns_again() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	var atb: Node = battle.get_atb()
	state.take_damage(CAEL, 99999)
	assert_false(state.get_member(CAEL)["is_alive"], "precondition: Cael fell")
	state.heal(CAEL, 50, true)
	battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
	assert_gt(atb.get_gauge("party_1"), 0, "his gauge fills again, from empty")
	watch_signals(battle)
	_give_turn(battle, CAEL)
	assert_signal_emitted(battle, "turn_ready", "and it comes round to him")
	assert_eq(get_signal_parameters(battle, "turn_ready")[0], "party_1", "his turn")


# --- Flee reads the enemies still in the fight (#246 review) ---


func _escapes(petrify_the_fast_one: bool) -> int:
	var fake: FleeBattle = FleeBattle.new()
	add_child_autofree(fake)
	fake.state = BattleState.new()
	add_child_autofree(fake.state)
	fake.state.add_member(0, {"character_id": "t", "base_stats": {"hp": 100, "spd": 20}})
	for spd: int in [999, 0]:
		var e: Enemy = ENEMY_SCENE.instantiate()
		add_child_autofree(e)
		e.enemy_data = {"name": "E", "hp": 10, "spd": spd, "type": "beast"}
		e.current_hp = 10
		e.is_alive = true
		fake.enemies.append(e)
	if petrify_the_fast_one:
		fake.enemies[0].apply_status("petrify", -1)
	var actions: BattlePlayerActions = BattlePlayerActions.new(fake)
	for s: int in range(1, 61):
		seed(s)
		actions.do_flee()
	return fake.escapes


func test_flee_ignores_a_petrified_enemy_s_speed() -> void:
	assert_lt(_escapes(false), 15, "a SPD 999 enemy in the fight pins the chance near 10%")
	assert_gt(_escapes(true), 45, "petrified, it no longer counts: about 90%")
