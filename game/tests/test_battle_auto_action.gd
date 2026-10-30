extends GutTest
## Confusion and Berserk take the command away (GAP-003 slice 5, #246).
##
## Confusion: "Auto-attack random ally or enemy", 3 turns or until damaged;
## Berserk: "Auto-attack random enemy", until cured, ATB x1.25
## (combat-formulas.md § Status Effect ATB Interactions). Rulings of
## 2026-10-30: a confused combatant picks uniformly among every living combatant
## on both sides but itself; an auto-action is a full turn (begin-turn effects
## and status ticks run); both sides can be confused or berserk. Haste is an
## ATB fill-rate x1.5 and Coil applies it (#506).

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
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
	for slot: int in range(4):
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
	# a commanded one. Second Wind's 5% regen: abilities.md § Cael — Rally.
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
		"Berserk fills x1.25 (combat-formulas.md § Fill Rate Modifiers)"
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
	# Only the confused vermin acts, and it never hits itself, so nothing but its
	# own turns can move the count: one a turn, never two.
	var battle: Node = _boot(["ley_vermin", "ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	vermin.apply_status("confusion", 3)
	var left: Array[int] = []
	for _turn: int in range(3):
		_only_turn(battle, "enemy_0")
		left.append(_turns_left(vermin.active_statuses, "confusion"))
	assert_eq(left, [2, 1, 0] as Array[int], "3 turns, one a turn, then gone")


## Turns [param status] has left in [param statuses], 0 once it is gone.
func _turns_left(statuses: Array, status: String) -> int:
	for s: Dictionary in statuses:
		if s.get("name", "") == status:
			return int(s.get("remaining_turns", 0))
	return 0


func test_constructs_shrug_off_berserk() -> void:
	# bestiary/README.md type immunities, as enemy.gd TYPE_IMMUNITIES gives them.
	var golem: Node = ENEMY_SCENE.instantiate()
	add_child_autofree(golem)
	golem.enemy_data = {"name": "Golem", "type": "construct", "hp": 100}
	golem.current_hp = 100
	golem.is_alive = true
	assert_false(golem.apply_status("berserk", StatusEffects.UNTIL_CURED), "construct: immune")
	assert_false(golem.has_status("berserk"))


# --- Coil applies Haste (#506) ---


func test_a_coiled_serpent_is_hastened_and_its_gauge_fills_half_again_as_fast() -> void:
	# Coil is the Quickstep analog, so the same Haste status
	# (enemy-ability-conventions.md § 2.4 Stat buffs — reuse the player-analog
	# magnitude & duration), which fills x1.5 (combat-formulas.md § Fill Rate Modifiers).
	for s: int in range(1, 80):
		var battle: Node = _boot(["corrupted_spawn"])
		var spawn: Node = battle.get_enemies()[0]
		var messages: Array[String] = []
		battle.message.connect(func(t: String) -> void: messages.append(t))
		seed(s)
		_only_turn(battle, "enemy_0")
		if not messages.has("Corrupted Spawn uses coil!"):
			continue
		assert_true(spawn.has_status("haste"), "Coil leaves the serpent Hastened")
		assert_has(messages, "Corrupted Spawn is Hastened!", "announced like any Haste")
		var atb: Node = battle.get_atb()
		var speed: int = ATBSystem.settings_from_config(PartyState.get_config())["speed"]
		atb.set_gauge("enemy_0", 0)
		battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
		assert_eq(
			atb.get_gauge("enemy_0"),
			atb.calculate_fill_rate(int(spawn.enemy_data.get("spd", 0)), speed, [1.5]),
			"Haste fills the gauge x1.5"
		)
		return
	fail_test("the serpent never chose Coil")


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


# --- A self-targeted enemy ability lands only a buff (Coil) ---


func _self_ability(status: String) -> Dictionary:
	return {"type": "ability", "id": "test_move", "target": "self", "status": status}


func test_a_self_targeted_ability_will_not_land_an_ailment_on_its_caster() -> void:
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	battle._enemy_turn._do_self_ability(_self_ability("poison"), vermin, battle.get_enemies())
	assert_false(vermin.has_status("poison"), "a self ability lands buffs, not ailments")
	assert_push_error("poison", "the bad data is reported")


func test_a_self_targeted_ability_reports_a_status_the_registry_does_not_know() -> void:
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	battle._enemy_turn._do_self_ability(_self_ability("hast"), vermin, battle.get_enemies())
	assert_push_error("hast", "a typo is reported, not passed over in silence")


func test_every_shipped_self_targeted_status_is_a_buff() -> void:
	var checked: int = 0
	for act: String in ["act_i", "act_ii", "act_iii", "interlude", "optional"]:
		var f: FileAccess = FileAccess.open("res://data/enemies/%s.json" % act, FileAccess.READ)
		var data: Dictionary = JSON.parse_string(f.get_as_text())
		f.close()
		for enemy: Dictionary in data.get("enemies", []):
			for ab: Dictionary in enemy.get("abilities", []):
				var st: String = ab.get("status", "")
				if ab.get("target", "") != "self" or st.is_empty():
					continue
				checked += 1
				assert_true(
					StatusEffects.is_positive(st), "%s/%s lands %s" % [enemy["id"], ab["id"], st]
				)
	assert_gt(checked, 0, "Coil at least was read")


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


# --- An auto-attack is a new action, so Defend lapses ---


func test_a_defending_member_s_auto_turn_ends_their_defend() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.set_defending(EDREN, true)
	state.set_buff(EDREN, "damage_taken_mult", 0.5)
	state.apply_status(EDREN, "confusion", "turns", 3)
	_only_turn(battle, "party_0")
	assert_false(state.get_member(EDREN).get("is_defending", false), "Defend lapsed")
	assert_eq(state.get_member(EDREN).get("damage_taken_mult", 1.0), 1.0, "and its halving")
