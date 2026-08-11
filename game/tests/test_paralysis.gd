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


func test_integration_paralyzed_member_is_skipped_and_recovers() -> void:
	seed(31)
	var battle: Node = await _boot(["ley_vermin"])
	battle._state.apply_status(0, "paralysis", "turns", 3)
	# Drive party_0's would-be turns: while paralyzed it is auto-skipped (never
	# prompted) and the status counts down; eventually it wears off.
	for _i: int in range(8):
		if not battle._state.has_status(0, "paralysis"):
			break
		battle._atb.set_gauge("party_0", 16000)
		await wait_frames(2)
		assert_ne(battle._awaiting_input_for, "party_0", "a paralyzed member is never prompted")
	assert_false(battle._state.has_status(0, "paralysis"), "paralysis wears off after its turns")
	# Recovered: a now-free member fills and IS prompted.
	battle._atb.set_gauge("party_0", 16000)
	await wait_frames(2)
	assert_eq(battle._awaiting_input_for, "party_0", "recovered member is prompted normally")


func test_skip_consumes_the_frame_so_its_message_is_not_clobbered() -> void:
	# combat-formulas.md § Status Effect ATB Interactions: the auto-skip consumes
	# the frame's single action slot, so no other combatant's message can
	# overwrite the skip announcement before the UI renders it (#260).
	seed(31)
	var battle: Node = await _boot(["ley_vermin"])
	battle.set_process(false)  # drive _process by hand, one frame exactly
	battle._state.apply_status(0, "paralysis", "turns", 3)
	# Make the enemy slower than the party so the ready queue puts party_0 first.
	battle._atb._combatants["enemy_0"]["spd"] = 1
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	battle._atb.set_gauge("party_0", 16000)
	battle._atb.set_gauge("enemy_0", 16000)

	battle._process(0.0)

	assert_eq(msgs.size(), 1, "exactly one message this frame: %s" % str(msgs))
	assert_true(
		msgs[0].contains("paralyzed") and msgs[0].contains("can't move"),
		"and it names the status that blocked the turn: %s" % str(msgs)
	)
	# The enemy keeps its full gauge and acts on the NEXT frame — which is why
	# winning this frame is not enough on its own; the UI message queue below
	# carries the announcement across that next frame.
	assert_eq(battle._atb.get_gauge("enemy_0"), 16000, "the enemy still acts next frame")


func test_skip_message_survives_the_enemys_action_on_the_next_frame() -> void:
	# Consuming the frame only defers the enemy by one frame (~16ms of display).
	# ui-design.md § 2.5: the announcement holds the message window for a readable
	# minimum, so the enemy's line queues behind it instead of replacing it (#260).
	seed(31)
	var battle: Node = await _boot(["ley_vermin"])
	battle.set_process(false)
	var ui: CanvasLayer = battle._ui
	ui.set_process(false)
	battle._state.apply_status(0, "paralysis", "turns", 3)
	battle._atb._combatants["enemy_0"]["spd"] = 1
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	battle._atb.set_gauge("party_0", 16000)
	battle._atb.set_gauge("enemy_0", 16000)

	battle._process(0.0)  # frame N: the skip announces
	var skip_line: String = ui._message_label.text
	ui._process(0.016)  # the player gets one rendered frame of it
	battle._process(0.0)  # frame N+1: the enemy takes its turn

	assert_true(skip_line.contains("can't move"), "frame N showed the skip: %s" % skip_line)
	assert_gte(msgs.size(), 2, "the enemy did announce its own action: %s" % str(msgs))
	assert_eq(ui._message_label.text, skip_line, "and it waited rather than clobbering the skip")


func test_frozen_status_takes_no_turn_and_keeps_its_gauge() -> void:
	# Sleep and Petrify freeze the gauge, and combat-formulas.md § Status Effect
	# ATB Interactions says the skip never writes to it — Sleep in particular
	# retains its frozen value. A member already at full gauge is therefore
	# passed over in silence: no announcement, no status tick, no reset (#260).
	seed(31)
	var battle: Node = await _boot(["ley_vermin"])
	battle.set_process(false)
	battle._state.apply_status(0, "sleep", "turns", StatusEffects.default_duration("sleep"))
	battle._state.apply_status(0, "poison", "turns", StatusEffects.default_duration("poison"))
	var hp_before: int = battle._state.get_member(0).get("current_hp", 0)
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	battle._atb.set_gauge("party_0", 16000)

	battle._process(0.0)

	assert_eq(battle._atb.get_gauge("party_0"), 16000, "a frozen gauge keeps its value")
	assert_ne(battle._awaiting_input_for, "party_0", "a sleeping member is never prompted")
	assert_eq(msgs.size(), 0, "no skip announcement for a frozen status: %s" % str(msgs))
	assert_eq(
		battle._state.get_member(0).get("current_hp", 0), hp_before, "no turn means no DoT tick"
	)


func test_dot_death_during_skip_resolves_the_party_wipe_same_frame() -> void:
	# A paralyzed last-standing member killed by its own Poison tick must trip
	# the end-condition check inside the skip, not a frame later (#260).
	seed(31)
	var battle: Node = await _boot(["ley_vermin"])
	battle.set_process(false)
	for slot: int in range(1, 4):
		battle._state.take_damage(slot, 999999)
	battle._state.take_damage(0, battle._state.get_member(0).get("current_hp", 1) - 1)
	battle._state.apply_status(0, "paralysis", "turns", 3)
	battle._state.apply_status(0, "poison", "turns", StatusEffects.default_duration("poison"))
	# Array counter, not an int: GDScript lambdas capture locals by value.
	var defeats: Array[int] = []
	battle.defeat.connect(
		func() -> void:
			defeats.append(1)
			# Guard: keep _exit_battle from starting a real scene transition.
			battle._battle_active = false
	)
	battle._atb.set_gauge("party_0", 16000)

	battle._process(0.0)

	assert_false(battle._state.get_member(0).get("is_alive", true), "the DoT tick killed them")
	assert_eq(defeats.size(), 1, "party wipe resolves inside the skip, not a frame later")
