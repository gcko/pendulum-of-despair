extends GutTest
## Where an enemy's action meets the party (#435, #158 slice b, review round 1
## of PR #497): an AoE stops once its attacker falls; Edren's counters count as
## threat; a hit announces the members and enemies it wakes, with the canonical
## "[Character] woke up!" line (battle-dialogue.md § Status Effect
## Notifications), from a death burst too; and Edren's share of a death burst
## shows its own damage number.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

const EDREN := 0
const LIRA := 2
const QUAKE: Dictionary = {
	"type": "ability",
	"id": "quake",
	"target": "all",
	"atk_type": "attack",
	"ability_mult": 1.0,
	"hits": 1,
	"status": "poison",
	"status_rate": 100,
	"status_duration": null,
}
const SURGE: Dictionary = {
	"type": "ability",
	"id": "surge",
	"target": "all",
	"atk_type": "magic",
	"power": 20,
	"status": "poison",
	"status_rate": 100,
	"status_duration": null,
}


## The signals the enemy turn reaches on the battle manager.
class TurnManager:
	extends Node2D
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)


## One enemy turn's world: a four-member party with Edren in Rampart under
## Oathkeeper (so every absorbed hit counters), a 1 HP attacker, and the
## manager's messages and damage numbers in the order they came.
class Arena:
	var state: Node
	var enemy: Node
	var driver: BattleEnemyTurn
	var messages: Array[String] = []
	var events: Array = []


func after_each() -> void:
	randomize()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _arena(enemy_hp: int = 1) -> Arena:
	var a: Arena = Arena.new()
	a.state = BattleState.new()
	add_child_autofree(a.state)
	for slot: int in range(4):
		(
			a
			. state
			. add_member(
				slot,
				{
					"character_id": ["edren", "cael", "lira", "maren"][slot],
					"name": ["Edren", "Cael", "Lira", "Maren"][slot],
					"base_stats":
					{
						"hp": 5000,
						"atk": 50,
						"def": 40,
						"mag": 20,
						"mdef": 20,
						"spd": 1,
						"lck": 0,
					},
				}
			)
		)
	a.state.get_member(LIRA)["row"] = "back"
	a.state.get_member(3)["row"] = "back"
	Bulwark.enter_stance(a.state, EDREN, "rampart", -1)
	Bulwark.oathkeeper(a.state, EDREN)
	var mgr: TurnManager = TurnManager.new()
	add_child_autofree(mgr)
	mgr.message.connect(func(t: String) -> void: a.messages.append(t))
	mgr.damage_dealt.connect(func(t: String, n: int, _k: String) -> void: a.events.append([t, n]))
	var atb: Node = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(atb)
	var area: Node2D = Node2D.new()
	add_child_autofree(area)
	a.driver = BattleEnemyTurn.new(mgr, a.state, atb, area)
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	e.enemy_data = {
		"name": "Brute",
		"atk": 40,
		"mag": 40,
		"spd": 0,
		"def": 10,
		"mdef": 10,
		"type": "humanoid",
		"hp": enemy_hp
	}
	e.current_hp = enemy_hp
	e.is_alive = true
	a.enemy = e
	return a


## Run an AoE until a counter fells the attacker before the last party slot,
## and return the arena it happened in with the slot it fell at.
func _aoe_felled_early(action: Dictionary) -> Array:
	for s: int in range(1, 80):
		var a: Arena = _arena()
		seed(s)
		a.driver._do_attack_or_ability(action, a.enemy, 0)
		var at: int = -1
		for i: int in range(a.events.size()):
			if a.events[i][0] == "enemy_0":
				at = i
		if a.enemy.is_alive or at < 0:
			continue
		# Slots resolve in order, so the kill came at the highest slot hit so far
		# (Edren's share of a later slot's hit shows as party_0 after it).
		var slot: int = -1
		for i: int in range(at):
			if String(a.events[i][0]).begins_with("party_"):
				slot = maxi(slot, String(a.events[i][0]).replace("party_", "").to_int())
		if slot < 3:
			return [a, slot, at]
	fail_test("no seed fells the attacker early")
	return []


func _assert_aoe_stopped(action: Dictionary, kind: String) -> void:
	var found: Array = _aoe_felled_early(action)
	if found.is_empty():
		return
	var a: Arena = found[0]
	for ev: Array in a.events.slice(int(found[2]) + 1):
		assert_false(String(ev[0]).begins_with("party_"), "%s: no number after the kill" % kind)
	for slot: int in range(int(found[1]) + 1, 4):
		assert_eq(
			int(a.state.get_member(slot)["current_hp"]),
			5000,
			"%s: slot %d untouched" % [kind, slot]
		)
		assert_false(a.state.has_status(slot, "poison"), "%s: slot %d not poisoned" % [kind, slot])


# --- An AoE stops once its attacker falls ---


func test_a_physical_aoe_stops_when_a_counter_fells_its_attacker() -> void:
	_assert_aoe_stopped(QUAKE, "physical")


func test_a_magic_aoe_stops_when_a_counter_fells_its_attacker() -> void:
	_assert_aoe_stopped(SURGE, "magic")


# --- Counters are threat ---


func test_edren_s_counters_count_as_threat() -> void:
	for s: int in range(1, 40):
		var a: Arena = _arena(30000)
		seed(s)
		a.driver._do_attack_or_ability(
			{"type": "attack", "target_slot": LIRA, "atk_type": "attack"}, a.enemy, 0
		)
		var countered: int = 0
		for ev: Array in a.events:
			if ev[0] == "enemy_0":
				countered += int(ev[1])
		if countered > 0:
			assert_eq(int(a.state.get_member(EDREN)["threat_dealt"]), countered, "threat")
			return
	fail_test("no counter landed")


# --- Wake lines ---


func test_no_wake_line_for_a_sleeper_the_hit_felled() -> void:
	for s: int in range(1, 40):
		var a: Arena = _arena(30000)
		a.state.get_member(1)["current_hp"] = 1
		a.state.apply_status(1, "sleep", "turns", -1)
		seed(s)
		a.driver._do_attack_or_ability(
			{"type": "attack", "target_slot": 1, "atk_type": "attack"}, a.enemy, 0
		)
		if not a.state.get_member(1)["is_alive"]:
			assert_false(
				a.messages.has(StatusEffects.wake_notice("Cael")), "the fallen do not wake"
			)
			return
	fail_test("the hit never landed")


func _boot(encounter: Array) -> Node:
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
	add_child_autofree(battle)
	return battle


func test_a_death_burst_wakes_a_sleeper_and_says_so() -> void:
	for s: int in range(1, 30):
		var battle: Node = _boot(["unstable_crystal"])
		var messages: Array[String] = []
		battle.message.connect(func(t: String) -> void: messages.append(t))
		var cael: String = battle._state.get_member(1)["character_data"]["name"]
		battle._state.apply_status(1, "sleep", "turns", -1)
		battle._state.get_member(1)["current_hp"] = 9999
		seed(s)
		battle._enemies[0].take_damage(999999)
		if not battle._state.has_status(1, "sleep"):
			assert_has(messages, StatusEffects.wake_notice(cael), "the burst woke Cael, out loud")
			return
	fail_test("the burst never hit Cael")


func test_edren_s_share_of_a_death_burst_shows_its_number() -> void:
	for s: int in range(1, 30):
		var battle: Node = _boot(["unstable_crystal"])
		var state: Node = battle._state
		state.get_member(1)["row"] = "back"
		Bulwark.enter_stance(state, 0, "rampart", -1)
		var on_edren: Array[int] = []
		battle.damage_dealt.connect(
			func(t: String, n: int, _k: String) -> void:
				if t == "party_0":
					on_edren.append(n)
		)
		state.get_member(0)["current_hp"] = 9999
		state.get_member(1)["current_hp"] = 9999
		var hp: int = 9999
		var cael_hp: int = 9999
		seed(s)
		battle._enemies[0].take_damage(999999)
		if int(state.get_member(1)["current_hp"]) < cael_hp:
			var shown: int = 0
			for n: int in on_edren:
				shown += n
			assert_eq(shown, hp - int(state.get_member(0)["current_hp"]), "every HP he lost shown")
			return
	fail_test("the burst never hit Cael")


func test_an_enemy_woken_by_a_hit_is_announced() -> void:
	var battle: Node = _boot(["marsh_serpent"])
	var messages: Array[String] = []
	battle.message.connect(func(t: String) -> void: messages.append(t))
	var serpent: Node = battle._enemies[0]
	serpent.apply_status("sleep", -1)
	assert_true(serpent.has_status("sleep"), "precondition: the serpent sleeps")
	serpent.take_damage(1)
	assert_has(messages, StatusEffects.wake_notice(serpent.get_display_name()), "announced")
