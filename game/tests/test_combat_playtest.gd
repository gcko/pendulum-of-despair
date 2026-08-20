extends GutTest
## Player commands resolved through the real battle scene: what happens when a
## damage spell lands, when the target is immune to what was cast at it, and
## when a status takes an enemy's turn away.
##
## These boot battle.tscn and go in through the seam the battle UI uses — wait
## for the battle to ask for a command (turn_ready), then submit one
## (BattleUI.command_submitted) — so what is proven is the path a player drives.
## The formulas underneath are unit-tested in test_damage_calculator.gd and
## test_battle_actions.gd.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

## Real time allowed for the battle to answer a full ATB gauge with a prompt.
const PROMPT_TIMEOUT: float = 5.0

var _booted: Node = null


func after_each() -> void:
	# A live battle keeps _process-ing, so free it here rather than let it run
	# on into the next test. The new-game party and any seed() go with it: no
	# test may hand its global state to the one after it (#422).
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	randomize()


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


## Fill [param cid]'s gauge and wait until the battle actually asks for that
## combatant's command — turn_ready, the signal that opens the command menu.
## Returns false, having failed the test, when the prompt never arrives.
##
## The wait is on the prompt rather than on a frame count because the battle
## advances in _process (idle frames) while GUT's frame waits count physics
## frames: a fixed wait can return with the actor still not ready, and the
## command submitted after it is then dropped in silence (#422).
func _await_prompt(battle: Node, cid: String) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge(cid, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not cid in prompted:
		fail_test("the battle never asked %s for a command (asked: %s)" % [cid, str(prompted)])
		return false
	return true


## Submit a command the way BattleUI does when the player confirms one.
func _submit(battle: Node, command: Dictionary) -> void:
	var ui: CanvasLayer = battle.get_node("BattleUI")
	ui.command_submitted.emit(command)


func _spirit_bolt() -> Dictionary:
	return {
		"name": "Spirit Bolt",
		"category": "damage",
		"power": 40,
		"mp_cost": 0,
		"target": "single_enemy",
		"element": "spirit",
	}


func _vilethorn() -> Dictionary:
	return {
		"name": "Vilethorn",
		"category": "status",
		"status": "poison",
		"hit_rate": 100,
		"mp_cost": 0,
		"power": null,
		"target": "single_enemy",
		"element": "earth",
	}


func test_a_damage_spell_takes_hp_off_the_enemy_it_was_aimed_at() -> void:
	# Spirit magic against the undead is the case the player feels most (a 1.5x
	# type bonus, README:67) — but the point here is the whole command path:
	# prompt -> chosen spell -> that enemy loses HP and a number floats over it.
	var battle: Node = _boot(["ley_vermin", "restless_dead"])
	var undead: Node = battle.get_enemies()[1]
	var hp_before: int = undead.current_hp
	var hits: Array[Dictionary] = []
	battle.damage_dealt.connect(
		func(tid: String, amt: int, _dt: String) -> void: hits.append({"id": tid, "amount": amt})
	)
	if not await _await_prompt(battle, "party_0"):
		return

	# Every attack rolls to hit, and combat-formulas.md caps that roll at 99%,
	# so a lucky miss is always possible. The roll is pinned rather than
	# retried: seed 41 draws 9 for the hit check (below the 20% floor a hit
	# rate can never sink under) and 53 for evasion (above the 50% ceiling an
	# evasion rate can never rise over), so this cast lands whatever the two
	# combatants' speeds are later tuned to.
	seed(41)
	_submit(battle, {"type": "magic", "spell": _spirit_bolt(), "target": 1})

	assert_lt(undead.current_hp, hp_before, "the spell takes HP off the enemy it was aimed at")
	assert_eq(hits.size(), 1, "one damage number is shown: %s" % str(hits))
	assert_eq(str(hits[0].get("id", "")), "enemy_1", "over the enemy that was hit")
	assert_gt(int(hits[0].get("amount", 0)), 0, "reading the damage the spell rolled")
	assert_eq(
		undead.current_hp,
		maxi(0, hp_before - int(hits[0].get("amount", 0))),
		"and the enemy loses exactly that much, down to zero",
	)


func test_an_undead_enemy_shrugs_off_a_poison_spell() -> void:
	# Undead are immune to poison (enemy.gd TYPE_IMMUNITIES), and immunity is
	# decided before any roll — so the cast resolves and nothing sticks.
	#
	# "Nothing stuck" on its own would also be true of a cast that never
	# happened, which is the failure this whole change is about, so the reply
	# the player gets is asserted alongside it.
	var battle: Node = _boot(["restless_dead"])
	var undead: Node = battle.get_enemies()[0]
	var results: Array[String] = []
	battle.damage_dealt.connect(
		func(tid: String, _amt: int, dt: String) -> void: results.append("%s:%s" % [tid, dt])
	)
	if not await _await_prompt(battle, "party_0"):
		return

	_submit(battle, {"type": "magic", "spell": _vilethorn(), "target": 0})

	assert_false(undead.has_status("poison"), "an undead enemy cannot be poisoned")
	assert_eq(results.size(), 1, "the cast did resolve, once: %s" % str(results))
	assert_eq(results[0], "enemy_0:immune", "and it comes back over that enemy reading immune")


func test_a_sleeping_enemy_stops_filling_its_turn_gauge() -> void:
	# Sleep freezes the ATB gauge (combat-formulas.md § Status Effect ATB
	# Interactions), so a sleeping enemy's turn never comes up while the one
	# beside it keeps closing on its own. The battle is driven a frame at a
	# time, so "the gauge did not move" is a statement about frames that
	# definitely ran (#422).
	var battle: Node = _boot(["ley_vermin", "restless_dead"])
	battle.set_process(false)
	var sleeper: Node = battle.get_enemies()[0]
	var atb: Node = battle.get_atb()
	var start: int = ATBSystem.GAUGE_MAX / 4
	atb.set_gauge("enemy_0", start)
	atb.set_gauge("enemy_1", start)
	assert_true(sleeper.apply_status("sleep", 4), "precondition: the beast can be put to sleep")

	for _i: int in range(30):
		battle._process(0.016)

	assert_eq(atb.get_gauge("enemy_0"), start, "a sleeping enemy's gauge stops where it was")
	assert_gt(atb.get_gauge("enemy_1"), start, "while the enemy beside it keeps filling")
