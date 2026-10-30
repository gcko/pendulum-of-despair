extends GutTest
## Confusion and Berserk take the command away (GAP-003 slice 5, #246).
##
## combat-formulas.md § Status Effect ATB Interactions: Confusion "Auto-attack
## random ally or enemy", 3 turns or until damaged; Berserk "Auto-attack random
## enemy", until cured, ATB x1.25. Rulings of 2026-10-30: a confused combatant
## picks uniformly among every living combatant on both sides but itself; an
## auto-action is a full turn (begin-turn effects and status ticks run); both
## sides can be confused or berserk.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

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
	for slot: int in [EDREN, CAEL]:
		atb.set_gauge("party_%d" % slot, 0)
	for i: int in range(battle.get_enemies().size()):
		atb.set_gauge("enemy_%d" % i, 0)
	atb.set_gauge(id, ATBSystem.GAUGE_MAX)
	battle._process(0.0)


## The combatant ids [param battle] showed a damage number for, in order.
func _record_hits(battle: Node) -> Array[String]:
	var hits: Array[String] = []
	battle.damage_dealt.connect(func(t: String, _n: int, _k: String) -> void: hits.append(t))
	return hits


## Over [param seeds] booted battles, the set of combatants [param actor]
## (under [param status]) aimed its auto-attack at. Every turn must name
## exactly one target.
func _targets_over_seeds(
	encounter: Array, actor: String, status: String, seeds: int = 40
) -> Dictionary:
	var seen: Dictionary = {}
	var not_one_target: Array[int] = []
	for s: int in range(1, seeds + 1):
		var battle: Node = _boot(encounter)
		_afflict(battle, actor, status)
		var hits: Array[String] = _record_hits(battle)
		seed(s)
		_only_turn(battle, actor)
		if hits.size() != 1:
			not_one_target.append(s)
		for t: String in hits:
			seen[t] = true
	assert_eq(not_one_target, [] as Array[int], "every turn is one auto-attack on one target")
	return seen


func _afflict(battle: Node, id: String, status: String) -> void:
	var duration: int = StatusEffects.default_duration(status)
	if id.begins_with("party_"):
		battle.get_battle_state().apply_status(
			id.replace("party_", "").to_int(), status, "turns", duration
		)
	else:
		battle.get_enemies()[id.replace("enemy_", "").to_int()].apply_status(status, duration)


# --- Confusion on the party ---


func test_a_confused_member_is_never_prompted_and_its_turn_is_spent() -> void:
	var battle: Node = _boot()
	battle.get_battle_state().apply_status(EDREN, "confusion", "turns", 3)
	watch_signals(battle)
	_only_turn(battle, "party_0")
	assert_signal_not_emitted(battle, "turn_ready", "no command menu for a confused member")
	assert_eq(battle.get_atb().get_gauge("party_0"), 0, "the auto-attack spent the turn")


func test_a_confused_member_strikes_allies_and_enemies_but_never_itself() -> void:
	var seen: Dictionary = _targets_over_seeds(["ley_vermin"], "party_0", "confusion")
	assert_false(seen.has("party_0"), "Edren never attacks himself")
	assert_true(seen.has("party_1"), "over many rolls Edren hits his ally Cael")
	assert_true(seen.has("enemy_0"), "over many rolls Edren hits the enemy")


func test_confusion_wears_off_after_three_of_the_member_s_turns() -> void:
	var battle: Node = _boot()
	battle.get_battle_state().apply_status(EDREN, "confusion", "turns", 3)
	for _turn: int in range(3):
		_only_turn(battle, "party_0")
	assert_false(battle.get_battle_state().has_status(EDREN, "confusion"), "3 turns, then gone")
	watch_signals(battle)
	_only_turn(battle, "party_0")
	assert_signal_emitted(battle, "turn_ready", "Edren is under command again")


func test_a_hit_snaps_a_confused_member_out_of_it() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(EDREN, "confusion", "turns", 3)
	state.take_damage(EDREN, 5)
	watch_signals(battle)
	_only_turn(battle, "party_0")
	assert_signal_emitted(battle, "turn_ready", "a hit ends Confusion and control returns")


func test_an_auto_attack_is_a_full_turn_so_second_wind_still_heals() -> void:
	# Ruling of 2026-10-30: begin-turn effects run on an auto-action turn as on
	# a commanded one (abilities.md § Cael — Rally, Second Wind's 5% regen).
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.take_damage(EDREN, 400)
	BattleRally.start(state, CAEL, "second_wind", AbilityCommand.RALLY_EFFECTS["second_wind"])
	state.apply_status(EDREN, "confusion", "turns", 3)
	var hp_before: int = state.get_member(EDREN)["current_hp"]
	_only_turn(battle, "party_0")
	assert_eq(
		state.get_member(EDREN)["current_hp"],
		hp_before + STURDY_HP * 5 / 100,
		"Second Wind's regen landed as the confused turn began"
	)


# --- Berserk on the party ---


func test_berserk_lands_on_a_member_with_its_canonical_line() -> void:
	var battle: Node = _boot()
	var messages: Array[String] = []
	battle.message.connect(func(t: String) -> void: messages.append(t))
	battle.get_battle_state().apply_status(EDREN, "berserk", "turns", StatusEffects.UNTIL_CURED)
	assert_has(messages, "Edren is Berserk!", "battle-dialogue.md § Status Effect Notifications")


func test_a_berserk_member_is_never_prompted() -> void:
	var battle: Node = _boot()
	battle.get_battle_state().apply_status(EDREN, "berserk", "turns", StatusEffects.UNTIL_CURED)
	watch_signals(battle)
	_only_turn(battle, "party_0")
	assert_signal_not_emitted(battle, "turn_ready", "no command menu for a berserk member")
	assert_eq(battle.get_atb().get_gauge("party_0"), 0, "the auto-attack spent the turn")


func test_a_berserk_member_only_attacks_enemies() -> void:
	var seen: Dictionary = _targets_over_seeds(["ley_vermin", "ley_vermin"], "party_0", "berserk")
	assert_eq(seen.keys().filter(func(t: String) -> bool: return t.begins_with("party_")), [])
	assert_true(seen.has("enemy_0") and seen.has("enemy_1"), "any enemy, at random")


func test_berserk_lasts_until_cured() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.apply_status(EDREN, "berserk", "turns", StatusEffects.UNTIL_CURED)
	for _turn: int in range(6):
		_only_turn(battle, "party_0")
	state.take_damage(EDREN, 5)
	assert_true(state.has_status(EDREN, "berserk"), "no countdown, and a hit does not end it")


func test_a_berserk_member_s_gauge_fills_a_quarter_faster() -> void:
	var battle: Node = _boot()
	var atb: Node = battle.get_atb()
	var state: Node = battle.get_battle_state()
	var speed: int = ATBSystem.settings_from_config(PartyState.get_config())["speed"]
	state.apply_status(EDREN, "berserk", "turns", StatusEffects.UNTIL_CURED)
	atb.set_gauge("party_0", 0)
	battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
	assert_eq(
		atb.get_gauge("party_0"),
		atb.calculate_fill_rate(state.get_effective_stat(EDREN, "spd"), speed, [1.25]),
		"combat-formulas.md § Fill Rate Modifiers: Berserk x1.25"
	)


# --- Confusion and Berserk on enemies ---


func test_a_confused_enemy_strikes_both_sides_but_never_itself() -> void:
	var seen: Dictionary = _targets_over_seeds(
		["ley_vermin", "ley_vermin"], "enemy_0", "confusion", 60
	)
	assert_false(seen.has("enemy_0"), "the vermin never attacks itself")
	assert_true(seen.has("enemy_1"), "over many rolls it hits the other vermin")
	assert_true(seen.has("party_0") or seen.has("party_1"), "over many rolls it hits the party too")


func test_a_confused_enemy_s_hit_on_another_enemy_snaps_that_one_out_of_it() -> void:
	for s: int in range(1, 60):
		var battle: Node = _boot(["ley_vermin", "ley_vermin"])
		var enemies: Array[Node] = battle.get_enemies()
		enemies[0].apply_status("confusion", 3)
		enemies[1].apply_status("confusion", 3)
		seed(s)
		_only_turn(battle, "enemy_0")
		if enemies[1].current_hp < STURDY_HP:
			assert_false(enemies[1].has_status("confusion"), "the hit ended its Confusion")
			return
	fail_test("the confused vermin never landed a hit on the other")


func test_a_berserk_enemy_only_attacks_the_party() -> void:
	var seen: Dictionary = _targets_over_seeds(["ley_vermin", "ley_vermin"], "enemy_0", "berserk")
	assert_eq(seen.keys().filter(func(t: String) -> bool: return t.begins_with("enemy_")), [])
	assert_true(seen.has("party_0") and seen.has("party_1"), "any party member, at random")


func test_a_confused_enemy_s_turn_counts_down_its_confusion() -> void:
	var battle: Node = _boot(["ley_vermin", "ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	vermin.apply_status("confusion", 3)
	for _turn: int in range(3):
		if not vermin.has_status("confusion"):
			break  # the other vermin is not acting, so only a party hit could end it
		_only_turn(battle, "enemy_0")
	assert_false(vermin.has_status("confusion"), "3 turns, then gone")


func test_constructs_shrug_off_berserk() -> void:
	# bestiary/README.md type immunities, as enemy.gd TYPE_IMMUNITIES gives them.
	var golem: Node = ENEMY_SCENE.instantiate()
	add_child_autofree(golem)
	golem.enemy_data = {"name": "Golem", "type": "construct", "hp": 100}
	golem.current_hp = 100
	golem.is_alive = true
	assert_false(golem.apply_status("berserk", StatusEffects.UNTIL_CURED), "construct: immune")
	assert_false(golem.has_status("berserk"))
