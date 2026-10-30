extends GutTest
## A petrified party member is out of the fight (#246).
##
## Petrify is "Removed from combat", until cured, per
## magic.md § Status Effect Reference. The enemy side was built first, per
## combat-formulas.md § Statuses on Enemies (ruling of 2026-10-29): a petrified
## enemy cannot be targeted, and a field of dead and petrified enemies is won.
## The party side mirrors it, as a reading of the same canon (recorded in
## combat-formulas.md § Status Effect ATB Interactions): no enemy move picks a
## petrified member, single or
## party-wide, regular AI or boss script, and a confused or berserk attacker
## leaves them out of its pool; a party of only petrified and fainted members
## has lost.

const BossAI = preload("res://scripts/combat/boss_ai.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

## Enough HP that no attack in these tests fells the one member left standing.
const STURDY_HP: int = 5000
## Enough rolls that a pool still holding a petrified member would show it.
const SEEDS: int = 40


## The signals and hooks BattleEnemyTurn touches on its manager, so an enemy turn
## runs through the real execute() path without booting battle.tscn.
class _FakeManager:
	extends Node2D
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)

	func _on_enemy_died(_enemy: Node) -> void:
		pass

	func _on_enemy_status_applied(_status: String, _duration: int, _enemy: Node) -> void:
		pass


var _booted: Node = null


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


## A sturdy 4-member party, every member in [param rows] (front by default).
func _party(rows: Array = []) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	for i: int in range(4):
		var stats: Dictionary = {"hp": STURDY_HP, "mdef": 8, "spd": 8}
		state.add_member(i, {"character_id": "m%d" % i, "name": "M%d" % i, "base_stats": stats})
		if i < rows.size():
			state.get_member(i)["row"] = rows[i]
	return state


func _petrify(state: Node, slots: Array) -> void:
	for slot: int in slots:
		assert_true(
			state.apply_status(slot, "petrify", "turns", StatusEffects.UNTIL_CURED),
			"precondition: Petrify lands on slot %d" % slot
		)


func _enemy(enemy_id: String) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	e.initialize(enemy_id, "act_i")
	return e


## A real enemy-turn driver over [param state], and the party slots it showed a
## number on and the lines it said, as {driver, hits, lines}.
func _driver(state: Node) -> Dictionary:
	var mgr: _FakeManager = _FakeManager.new()
	add_child_autofree(mgr)
	var atb: Node = ATBSystem.new()
	add_child_autofree(atb)
	var area: Node2D = Node2D.new()
	add_child_autofree(area)
	var hits: Array[String] = []
	var lines: Array[String] = []
	mgr.damage_dealt.connect(
		func(t: String, _n: int, _k: String) -> void:
			if t.begins_with("party_"):
				hits.append(t)
	)
	mgr.message.connect(func(text: String) -> void: lines.append(text))
	return {"driver": BattleEnemyTurn.new(mgr, state, atb, area), "hits": hits, "lines": lines}


## The party slots [param enemy] hit over SEEDS of its turns.
func _hits_over_turns(enemy: Enemy, state: Node) -> Dictionary:
	var h: Dictionary = _driver(state)
	var seen: Dictionary = {}
	for s: int in range(1, SEEDS + 1):
		seed(s)
		(h["driver"] as BattleEnemyTurn).execute("enemy_0", [enemy] as Array[Node], false, s)
	for t: String in h["hits"]:
		seen[t] = true
	seen["_lines"] = h["lines"]
	return seen


## A one-rule boss script whose only move is a single-target strike resolved by
## [param selector] (enemy-ability-conventions.md § 3).
func _scripted_boss(selector: String) -> Enemy:
	var boss: Enemy = _enemy("ley_vermin")
	var data: Dictionary = boss.enemy_data.duplicate(true)
	data["boss_ai"] = {
		"phases": [{"name": "only", "rules": [{"when": {"default": true}, "move": "strike"}]}],
		"moves":
		{
			"strike":
			{"type": "ability", "target": "single", "selector": selector, "atk_type": "physical"}
		},
	}
	boss.enemy_data = data
	return boss


# --- Regular enemy AI ---


func test_a_regular_enemy_never_attacks_a_petrified_member() -> void:
	var state: Node = _party()
	_petrify(state, [0, 1, 2])
	var seen: Dictionary = _hits_over_turns(_enemy("ley_vermin"), state)
	assert_true(seen.has("party_3"), "the one member still on the field is attacked")
	for slot: int in [0, 1, 2]:
		assert_false(seen.has("party_%d" % slot), "petrified slot %d is never attacked" % slot)


func test_a_regular_enemy_s_party_wide_move_passes_over_a_petrified_member() -> void:
	var state: Node = _party()
	_petrify(state, [0, 1, 2])
	var vermin: Enemy = _enemy("ley_vermin")
	var data: Dictionary = vermin.enemy_data.duplicate(true)
	data["abilities"] = [
		{"id": "tremor", "name": "Tremor", "type": "attack", "target": "all", "ability_mult": 1.0}
	]
	vermin.enemy_data = data
	var seen: Dictionary = _hits_over_turns(vermin, state)
	var lines: Array = seen["_lines"]
	assert_true(
		lines.any(func(l: String) -> bool: return l.contains("uses tremor")),
		"precondition: the party-wide move was used"
	)
	for slot: int in [0, 1, 2]:
		assert_false(seen.has("party_%d" % slot), "petrified slot %d is never hit" % slot)


# --- Boss scripts ---


func test_a_boss_party_wide_move_passes_over_a_petrified_member() -> void:
	seed(7)
	var state: Node = _party()
	_petrify(state, [0])
	var h: Dictionary = _driver(state)
	var boss: Enemy = _enemy("drowned_sentinel")
	(h["driver"] as BattleEnemyTurn).execute("enemy_0", [boss] as Array[Node], true, 3)
	assert_eq(boss.ai_state.get("last_move", ""), "frost_wave", "precondition: Frost Wave")
	assert_does_not_have(h["hits"], "party_0", "Frost Wave passes over the statue")
	assert_has(h["hits"], "party_1", "and lands on the members still in the fight")
	assert_eq(state.get_member(0)["current_hp"], STURDY_HP, "the statue loses no HP")


func test_a_highest_threat_pick_passes_over_a_petrified_member() -> void:
	var state: Node = _party()
	state.add_threat(1, 500)
	_petrify(state, [1])
	var a: Dictionary = BossAI.select_action(_scripted_boss("highest_threat"), 0, state, [])
	assert_gte(int(a.get("target_slot", -1)), 0, "the boss still picks someone")
	assert_ne(int(a.get("target_slot", -1)), 1, "the petrified top threat is not that someone")


func test_a_lowest_hp_pick_passes_over_a_petrified_member() -> void:
	var state: Node = _party()
	state.get_member(2)["current_hp"] = 10
	_petrify(state, [2])
	var a: Dictionary = BossAI.select_action(_scripted_boss("lowest_hp"), 0, state, [])
	assert_gte(int(a.get("target_slot", -1)), 0, "the boss still picks someone")
	assert_ne(int(a.get("target_slot", -1)), 2, "the petrified weakest member is not that someone")


func test_a_back_row_pick_passes_over_a_petrified_member() -> void:
	var state: Node = _party(["front", "front", "front", "back"])
	_petrify(state, [3])
	var a: Dictionary = BossAI.select_action(_scripted_boss("back"), 0, state, [])
	assert_gte(int(a.get("target_slot", -1)), 0, "the boss falls back to someone in front")
	assert_ne(int(a.get("target_slot", -1)), 3, "the petrified back-row member is not picked")


func test_a_random_pick_passes_over_a_petrified_member() -> void:
	var state: Node = _party()
	_petrify(state, [0, 1, 2])
	var boss: Enemy = _scripted_boss("random")
	var picked: Dictionary = {}
	for s: int in range(1, SEEDS + 1):
		seed(s)
		picked[int(BossAI.select_action(boss, s, state, []).get("target_slot", -1))] = true
	assert_eq(picked.keys(), [3], "every pick is the one member still on the field")


func test_a_petrified_back_row_member_does_not_trigger_a_position_rule() -> void:
	# Ember Drake pounces when a back-row target exists (bosses.md); a statue in
	# the back row is no target, so it keeps to Tail Swipe.
	var state: Node = _party(["front", "front", "front", "back"])
	_petrify(state, [3])
	var drake: Enemy = _enemy("ember_drake")
	var a: Dictionary = BossAI.select_action(drake, 1, state, [drake])
	assert_eq(a.get("id", ""), "tail_swipe", "no Pounce with only a statue in the back row")


# --- Confusion and Berserk ---


func test_a_confused_or_berserk_enemy_never_attacks_a_petrified_member() -> void:
	var state: Node = _party()
	_petrify(state, [0])
	var enemies: Array[Node] = [_enemy("ley_vermin"), _enemy("ley_vermin")]
	for status: String in ["confusion", "berserk"]:
		var seen: Dictionary = {}
		for s: int in range(1, SEEDS + 1):
			seed(s)
			seen[BattleAutoAction.pick_target(status, "enemy_0", state, enemies)] = true
		assert_false(seen.has("party_0"), "a %s enemy never attacks the statue" % status)
		assert_true(seen.has("party_1"), "a %s enemy still attacks the party" % status)


func test_a_confused_member_never_attacks_a_petrified_ally() -> void:
	var state: Node = _party()
	_petrify(state, [0])
	var enemies: Array[Node] = [_enemy("ley_vermin")]
	var seen: Dictionary = {}
	for s: int in range(1, SEEDS + 1):
		seed(s)
		seen[BattleAutoAction.pick_target("confusion", "party_1", state, enemies)] = true
	assert_false(seen.has("party_0"), "a confused member never attacks a petrified ally")
	assert_true(seen.has("party_2"), "but still attacks the allies in the fight")


# --- Loss ---


func test_a_party_of_only_petrified_and_fainted_members_is_wiped() -> void:
	var state: Node = _party()
	state.take_damage(0, STURDY_HP)
	_petrify(state, [1, 2])
	assert_false(state.is_party_wiped(), "precondition: one member still stands")
	_petrify(state, [3])
	assert_true(state.is_party_wiped(), "fainted and petrified leaves no one in the fight")


func test_a_fully_petrified_party_loses_the_battle() -> void:
	seed(11)
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
	var state: Node = battle.get_battle_state()
	var members: Array = []
	for slot: int in range(4):
		if not state.get_member(slot).is_empty():
			members.append(slot)
	_petrify(state, members)
	var defeats: Array[int] = []  # an Array: lambdas capture locals by value
	battle.defeat.connect(
		func() -> void:
			defeats.append(1)
			battle.set("_battle_active", false)  # no real scene transition
	)
	# Nobody's gauge is full, so the frame's end-condition check is all that runs.
	var atb: Node = battle.get_atb()
	for slot: int in members:
		atb.set_gauge("party_%d" % slot, 0)
	atb.set_gauge("enemy_0", 0)

	battle._process(0.0)

	assert_eq(defeats.size(), 1, "a party of statues has lost")


# --- Flee and Pallor regen (mirrors of the enemy-side rulings of 2026-10-29) ---


func test_a_petrified_member_s_speed_is_left_out_of_the_flee_average() -> void:
	# A petrified enemy is left out of the enemies' average SPD when the party
	# flees (combat-formulas.md § Statuses on Enemies); a statue in the party
	# does not run either.
	var state: Node = _party()
	state.get_member(0)["effective_stats"]["spd"] = 40
	assert_eq(state.get_avg_party_spd(), 16.0, "precondition: (40 + 8 + 8 + 8) / 4")
	_petrify(state, [0])
	assert_eq(state.get_avg_party_spd(), 8.0, "the petrified sprinter is not in the average")


## A Pallor enemy at 500 of 1000 HP whose every turn is a wait, so its HP moves
## only by its end-of-turn regen.
func _waiting_pallor() -> Enemy:
	var pallor: Enemy = _scripted_boss("random")
	pallor.enemy_data["type"] = "pallor"
	pallor.enemy_data["hp"] = 1000
	pallor.enemy_data["boss_ai"]["moves"] = {"strike": {"type": "skip"}}
	pallor.current_hp = 500
	return pallor


func test_a_petrified_member_s_despair_feeds_no_pallor_regen() -> void:
	# Only a living member's Despair feeds a Pallor's 2% regen (ruling of
	# 2026-10-29); a statue is no more in the fight than a fallen member.
	var state: Node = _party()
	state.apply_status(1, "despair", "turns", 4)
	var h: Dictionary = _driver(state)
	var control: Enemy = _waiting_pallor()
	(h["driver"] as BattleEnemyTurn).execute("enemy_0", [control] as Array[Node], false, 0)
	assert_eq(control.current_hp, 520, "precondition: Cael's Despair feeds 2% of 1000")
	_petrify(state, [1])
	var pallor: Enemy = _waiting_pallor()
	(h["driver"] as BattleEnemyTurn).execute("enemy_0", [pallor] as Array[Node], false, 0)
	assert_eq(pallor.current_hp, 500, "petrified Cael's Despair feeds nothing")
