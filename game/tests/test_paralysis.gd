extends GutTest
## Tests for the Paralysis status (#248): registry definition, turn-based
## countdown, and the battle-layer auto-skip of an incapacitated party member's
## ready turn. Paralysis = cannot act for 3 turns, does NOT wake on damage
## (status_effects.gd / magic.md). The filling ATB gauge is the countdown clock.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
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
	# battle.tscn seats the party, spawns the enemies and registers every ATB
	# gauge in _ready, which runs inside add_child — the battle is ready to
	# drive the moment this returns, with no frame to wait for.
	add_child(battle)
	_booted = battle
	return battle


func test_paralyzed_member_is_never_asked_for_a_command_until_it_wears_off() -> void:
	# What the player sees is the prompt: a paralyzed member's full gauge never
	# opens the command menu, and once the status expires the very next full
	# gauge does. turn_ready is the signal that opens it (battle_ui connects to
	# it), so that is what this asserts — not the manager's internal bookkeeping.
	#
	# The battle is driven one frame at a time. Waiting a fixed number of frames
	# cannot say when a turn resolved: the battle advances in _process (idle
	# frames) while GUT's frame waits count physics frames, so under load the
	# wait returns with no turn processed at all (#422).
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(cid: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(cid)
	)
	var state: Node = battle.get_battle_state()
	state.apply_status(0, "paralysis", "turns", 3)

	# Each would-be turn is auto-skipped and counts the status down.
	for _i: int in range(8):
		if not state.has_status(0, "paralysis"):
			break
		battle.get_atb().set_gauge("party_0", ATBSystem.GAUGE_MAX)
		battle._process(0.0)
		assert_false("party_0" in prompted, "a paralyzed member is never asked for a command")
	assert_false(state.has_status(0, "paralysis"), "paralysis wears off after its turns")

	battle.get_atb().set_gauge("party_0", ATBSystem.GAUGE_MAX)
	battle._process(0.0)

	assert_true("party_0" in prompted, "and the recovered member is asked on its next turn")


func test_skip_consumes_the_frame_so_its_message_is_not_clobbered() -> void:
	# combat-formulas.md § Status Effect ATB Interactions: the auto-skip consumes
	# the frame's single action slot, so no other combatant's message can
	# overwrite the skip announcement before the UI renders it (#260).
	seed(31)
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)  # drive _process by hand, one frame exactly
	battle.get_battle_state().apply_status(0, "paralysis", "turns", 3)
	# Make the enemy slower than the party so the ready queue puts party_0 first.
	battle.get_atb().set_spd("enemy_0", 1)
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	battle.get_atb().set_gauge("party_0", 16000)
	battle.get_atb().set_gauge("enemy_0", 16000)

	battle._process(0.0)

	assert_eq(msgs.size(), 1, "exactly one message this frame: %s" % str(msgs))
	assert_true(
		msgs[0].contains("paralyzed") and msgs[0].contains("can't move"),
		"and it names the status that blocked the turn: %s" % str(msgs)
	)
	# The enemy keeps its full gauge and acts on the NEXT frame — which is why
	# winning this frame is not enough on its own; the UI message queue below
	# carries the announcement across that next frame.
	assert_eq(battle.get_atb().get_gauge("enemy_0"), 16000, "the enemy still acts next frame")


func test_skip_message_survives_the_enemys_action_on_the_next_frame() -> void:
	# Consuming the frame only defers the enemy by one frame (~16ms of display).
	# ui-design.md § 2.5: the announcement holds the message window for a readable
	# minimum, so the enemy's line queues behind it instead of replacing it (#260).
	seed(31)
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var ui: CanvasLayer = battle._ui
	ui.set_process(false)
	battle.get_battle_state().apply_status(0, "paralysis", "turns", 3)
	# Landing the status announces it ("Edren is Paralyzed!", #299) and that line
	# claims the window first. Age it out, so what this test measures is the skip
	# line against the enemy's action and not the notice against the skip.
	ui._process(ui.MESSAGE_HOLD)
	battle.get_atb().set_spd("enemy_0", 1)
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	battle.get_atb().set_gauge("party_0", 16000)
	battle.get_atb().set_gauge("enemy_0", 16000)

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
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var st: Node = battle.get_battle_state()
	st.apply_status(0, "sleep", "turns", StatusEffects.default_duration("sleep"))
	st.apply_status(0, "poison", "turns", StatusEffects.default_duration("poison"))
	var hp_before: int = st.get_member(0).get("current_hp", 0)
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	# turn_ready is what opens the command menu (battle_ui connects to it), so it
	# is the observable answer to "was the player prompted".
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(cid: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(cid)
	)
	battle.get_atb().set_gauge("party_0", 16000)

	battle._process(0.0)

	assert_eq(battle.get_atb().get_gauge("party_0"), 16000, "a frozen gauge keeps its value")
	assert_false("party_0" in prompted, "a sleeping member is never prompted")
	assert_eq(msgs.size(), 0, "no skip announcement for a frozen status: %s" % str(msgs))
	assert_eq(st.get_member(0).get("current_hp", 0), hp_before, "no turn means no DoT tick")


func test_dot_death_during_skip_resolves_the_party_wipe_same_frame() -> void:
	# A paralyzed last-standing member killed by its own Poison tick must trip
	# the end-condition check inside the skip, not a frame later (#260).
	seed(31)
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var st: Node = battle.get_battle_state()
	for slot: int in range(1, 4):
		st.take_damage(slot, 999999)
	st.take_damage(0, st.get_member(0).get("current_hp", 1) - 1)
	st.apply_status(0, "paralysis", "turns", 3)
	st.apply_status(0, "poison", "turns", StatusEffects.default_duration("poison"))
	# Array counter, not an int: GDScript lambdas capture locals by value.
	var defeats: Array[int] = []
	battle.defeat.connect(
		func() -> void:
			defeats.append(1)
			# Guard: keep _exit_battle from starting a real scene transition.
			battle._battle_active = false
	)
	battle.get_atb().set_gauge("party_0", 16000)

	battle._process(0.0)

	assert_false(st.get_member(0).get("is_alive", true), "the DoT tick killed them")
	assert_eq(defeats.size(), 1, "party wipe resolves inside the skip, not a frame later")


# --- The gauge under a frozen status (#279, #298, #300) ---


func test_sleep_holds_a_party_gauge_where_it_stands_and_a_cure_resumes_there() -> void:
	# combat-formulas.md § Status Effect ATB Interactions: "Frozen gauge retains
	# value ... Gauge resumes from that point when status ends." Only the enemy
	# gauges were ever told, so a sleeping party member's gauge kept filling to
	# full and they were merely passed over (#298). Stated as "the gauge does not
	# move", never as a frame count, so no ATB fill rate can make it lie.
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var st: Node = battle.get_battle_state()
	var atb: Node = battle.get_atb()
	atb.set_gauge("party_0", 8000)
	st.apply_status(0, "sleep", "turns", StatusEffects.default_duration("sleep"))

	for _i: int in range(5):
		battle._process(0.016)

	assert_eq(atb.get_gauge("party_0"), 8000, "a slept gauge does not fill")

	st.remove_status(0, "sleep")
	battle._process(0.016)

	assert_gte(atb.get_gauge("party_0"), 8000, "and resumes from where it froze, not from 0")


func test_petrify_empties_the_party_gauge_and_recovery_starts_fresh() -> void:
	# The severe one: combat-formulas.md gives Petrify's gauge as "Frozen (0)"
	# and its cure as "recovery starts fresh", where Sleep above keeps its 8000.
	# Curing it left the old value behind, so a cured member resumed a turn early
	# (#279).
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var st: Node = battle.get_battle_state()
	var atb: Node = battle.get_atb()
	atb.set_gauge("party_0", 8000)
	st.apply_status(0, "petrify", "turns", StatusEffects.default_duration("petrify"))

	battle._process(0.016)
	assert_eq(atb.get_gauge("party_0"), 0, "petrify empties the gauge it lands on")
	battle._process(0.016)
	assert_eq(atb.get_gauge("party_0"), 0, "and holds it empty")

	st.remove_status(0, "petrify")

	assert_eq(atb.get_gauge("party_0"), 0, "so a cured member starts from 0, not from 8000")


func test_paralysis_applied_first_never_spends_a_sleeping_gauge() -> void:
	_assert_frozen_gauge_survives_both_statuses("paralysis", "sleep")


func test_paralysis_applied_second_never_spends_a_sleeping_gauge() -> void:
	_assert_frozen_gauge_survives_both_statuses("sleep", "paralysis")


## Apply two incapacitating statuses in the given order to a member whose gauge
## is already full, then run the frame that would resolve their turn. Whichever
## order they landed in, the battle must treat them as gauge-frozen: passed over
## in silence with the gauge untouched. Answering "paralysis" instead ran the
## auto-skip, which resets the gauge — destroying the value the freeze exists to
## keep (#300).
func _assert_frozen_gauge_survives_both_statuses(first: String, second: String) -> void:
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var st: Node = battle.get_battle_state()
	st.apply_status(0, first, "turns", StatusEffects.default_duration(first))
	st.apply_status(0, second, "turns", StatusEffects.default_duration(second))
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))
	battle.get_atb().set_gauge("party_0", ATBSystem.GAUGE_MAX)

	battle._process(0.0)

	assert_eq(
		battle.get_atb().get_gauge("party_0"),
		ATBSystem.GAUGE_MAX,
		"%s then %s: the frozen gauge is not spent" % [first, second]
	)
	for m: String in msgs:
		assert_false(m.contains("can't move"), "a frozen member is passed over in silence: %s" % m)


func test_a_status_landing_on_a_party_member_is_announced() -> void:
	# ley_sting inflicts Paralysis on the party and the player was told nothing
	# at all — the auto-skip line announces the turn it denies, not the moment
	# the status lands (#299). The wording is battle-dialogue.md § Status Effect
	# Notifications, reached through the registry so every infliction path speaks
	# the same line.
	var battle: Node = _boot(["ley_vermin"])
	battle.set_process(false)
	var st: Node = battle.get_battle_state()
	var nm: String = st.get_member(0).get("character_data", {}).get("name", "???")
	var msgs: Array[String] = []
	battle.message.connect(func(t: String) -> void: msgs.append(t))

	st.apply_status(0, "paralysis", "turns", StatusEffects.default_duration("paralysis"))

	assert_true(("%s is Paralyzed!" % nm) in msgs, "the player is told it landed: %s" % str(msgs))
