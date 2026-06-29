extends GutTest
## Tests for the Paralysis status (#248): registry definition, turn-based
## countdown, and the battle-layer auto-skip of an incapacitated party member's
## ready turn. Paralysis = cannot act for 3 turns, does NOT wake on damage
## (status_effects.gd / magic.md). The filling ATB gauge is the countdown clock.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

var _booted: Node = null


func after_each() -> void:
	# Free any booted battle immediately so it cannot keep _process-ing into a
	# later test file's seeded run.
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	randomize()


func _make_state() -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	state.add_member(0, {"character_id": "tester", "base_stats": {"hp": 100, "mp": 0}})
	return state


# --- Registry definition ---


func test_paralysis_is_defined() -> void:
	assert_true(StatusEffects.is_known("paralysis"), "paralysis is in the registry")
	assert_eq(StatusEffects.default_duration("paralysis"), 3, "3-turn duration")
	assert_false(StatusEffects.wakes_on_damage("paralysis"), "does NOT wake on damage")


func test_paralysis_is_incapacitating() -> void:
	assert_true(StatusEffects.is_incapacitating("paralysis"), "paralysis prevents acting")
	assert_true(StatusEffects.is_incapacitating("sleep"), "frozen statuses also incapacitate")
	assert_true(StatusEffects.is_incapacitating("petrify"), "petrify incapacitates")
	assert_false(StatusEffects.is_incapacitating("poison"), "poison does not prevent acting")
	assert_false(StatusEffects.is_incapacitating("slow"), "slow throttles but allows acting")


func test_paralysis_does_not_freeze_the_gauge() -> void:
	# Unlike Sleep/Petrify (atb "frozen"), paralysis must let the gauge fill so the
	# turn-based countdown advances on each skipped would-be turn.
	assert_eq(StatusEffects.atb_effect("paralysis"), "none", "paralysis is not a gauge freeze")


# --- Turn-based countdown ---


func test_paralysis_counts_down_and_expires() -> void:
	var state: Node = _make_state()
	state.apply_status(0, "paralysis", "turns", StatusEffects.default_duration("paralysis"))
	assert_true(state.has_status(0, "paralysis"), "applied")
	state.tick_statuses(0)
	state.tick_statuses(0)
	assert_true(state.has_status(0, "paralysis"), "still active after 2 of 3 ticks")
	state.tick_statuses(0)
	assert_false(state.has_status(0, "paralysis"), "expires after its 3rd turn")


# --- Integration: incapacitated member auto-skips its ready turn ---


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
	add_child(battle)
	await wait_frames(3)
	_booted = battle
	return battle


func test_integration_paralysed_member_is_skipped_and_recovers() -> void:
	seed(31)
	var battle: Node = await _boot(["ley_vermin"])
	battle._state.apply_status(0, "paralysis", "turns", 3)
	# Drive party_0's would-be turns: while paralysed it is auto-skipped (never
	# prompted) and the status counts down; eventually it wears off.
	for _i: int in range(8):
		if not battle._state.has_status(0, "paralysis"):
			break
		battle._atb.set_gauge("party_0", 16000)
		await wait_frames(2)
		assert_ne(battle._awaiting_input_for, "party_0", "a paralysed member is never prompted")
	assert_false(battle._state.has_status(0, "paralysis"), "paralysis wears off after its turns")
	# Recovered: a now-free member fills and IS prompted.
	battle._atb.set_gauge("party_0", 16000)
	await wait_frames(2)
	assert_eq(battle._awaiting_input_for, "party_0", "recovered member is prompted normally")
