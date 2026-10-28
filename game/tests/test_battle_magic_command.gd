extends GutTest
## The Magic command's effect on an enemy, driven through the real battle scene:
## what the player is told when a status spell lands (#439), and the status
## rider an offensive spell rolls on top of its damage (#434).
##
## Like test_combat_playtest.gd, these boot battle.tscn and go in through the
## seam the battle UI uses — wait for turn_ready, then emit
## BattleUI.command_submitted — so what is proven is the path a player drives.
##
## Every target here has its MDEF and SPD zeroed. That pins the rolls the cast
## makes to the spell's own numbers: a 0-SPD target never evades and is hit at
## 90% or better, and a 0-MDEF target meets a status roll at its full base rate
## with no Magic Evasion (combat-formulas.md § Status Effect Accuracy). The
## seeds below are chosen against those floors and ceilings, not against the
## current stat values, so retuning a stat cannot flip them.
##
## The rider data checks (band, registry status, description match) also live
## here rather than in test_spell_balance.gd, which sits at the 600-line
## ceiling (technical-architecture.md 1.2a).

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## Every tradition's spell file, for the rider data checks.
const TRADITIONS: Array[String] = ["ley_line", "spirit", "forgewright", "streetwise", "void"]

## Real time allowed for the battle to answer a full ATB gauge with a prompt.
const PROMPT_TIMEOUT: float = 5.0

## Seeds for a Pendulum's Echo cast. The cast draws, in order: the hit roll, the
## evasion roll, the damage variance, then the rider's two status stages.
## RIDER_LANDS draws 7 / 66 / 42 / 5 / 59: a hit under the 20% floor no hit rate
## sinks below, an evasion roll over the 50% ceiling, then a rider roll of 5
## (under the 40% chance) and 59 for Magic Evasion (over its 40% ceiling).
## RIDER_MISSES draws 3 / 50 / 90 / 88 / 75: the same landed damage, then a rider
## roll of 88, which no 30-50% rider can reach.
const RIDER_LANDS_SEED: int = 113
const RIDER_MISSES_SEED: int = 112

var _booted: Node = null


func after_each() -> void:
	# A live battle keeps _process-ing, so free it here rather than let it run
	# on into the next test, and leave no seed or party behind (#422).
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
	add_child(battle)
	_booted = battle
	return battle


## Wait until the battle asks [param cid] for a command (see test_combat_playtest).
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


func _submit(battle: Node, command: Dictionary) -> void:
	var ui: CanvasLayer = battle.get_node("BattleUI")
	ui.command_submitted.emit(command)


## Zero the enemy's MDEF and SPD (see the file header) and give it [param hp].
## The data is copied first so the cached enemy table is left untouched.
func _pin_target(enemy: Node, hp: int) -> void:
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["mdef"] = 0
	data["spd"] = 0
	data["hp"] = hp
	enemy.enemy_data = data
	enemy.current_hp = hp


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


## The shipped Pendulum's Echo, free to cast so the new-game party can afford it.
func _pendulums_echo() -> Dictionary:
	for entry: Variant in DataManager.load_spells("void"):
		var spell: Dictionary = entry as Dictionary
		if String(spell.get("id", "")) == "pendulums_echo":
			var free: Dictionary = spell.duplicate(true)
			free["mp_cost"] = 0
			return free
	fail_test("pendulums_echo is missing from game/data/spells/void.json")
	return {}


func _all_spells() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for tradition: String in TRADITIONS:
		var loaded: Array = DataManager.load_spells(tradition)
		if loaded.is_empty():
			fail_test("No spells loaded for tradition '%s'" % tradition)
		for entry: Variant in loaded:
			out.append(entry as Dictionary)
	return out


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


# ── #439: status spells announce through the registry ───────────────────


func test_a_status_spell_landing_on_an_enemy_reads_the_canonical_line() -> void:
	# battle-dialogue.md § Status Effect Notifications: "[Character] is Poisoned!"
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 500)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	_submit(battle, {"type": "magic", "spell": _vilethorn(), "target": 0})

	assert_true(vermin.has_status("poison"), "precondition: the poison landed")
	var expected: String = "%s is Poisoned!" % vermin.get_display_name()
	assert_has(said, expected, "the player reads the canonical line: %s" % str(said))
	for line: String in said:
		assert_false(
			line.contains("afflicted with poison"), "no raw status id reaches the player: %s" % line
		)


# ── #434: rider data ─────────────────────────────────────────────────────


## Per magic.md § Derived Rules, a rider binds on `category: offensive` only, is
## priced below the 60% standard-band floor at 30-50%, and must name a status the
## battle layer can actually inflict, or the roll it promises can never land.
func test_status_riders_sit_in_the_rider_band_and_name_a_known_status() -> void:
	var checked: int = 0
	for spell: Dictionary in _all_spells():
		if spell.get("rider") == null:
			continue
		var rider: Dictionary = spell.get("rider")
		assert_eq(
			String(spell.get("category", "")),
			"offensive",
			"%s: only an offensive spell carries a rider" % String(spell.get("id", "?")),
		)
		assert_between(
			int(rider.get("chance", 0)),
			30,
			50,
			"%s: rider band is 30-50" % String(spell.get("id", "?"))
		)
		var status: String = String(rider.get("status", ""))
		assert_true(
			StatusEffects.is_known(status),
			(
				"%s: rider status '%s' is not in the status registry"
				% [String(spell.get("id", "?")), status]
			),
		)
		checked += 1
	assert_gt(checked, 0, "no status riders were checked")


## A rider promised in an offensive spell's description must be one the battle
## layer rolls (#434): Pendulum's Echo's 40% Despair lived in its text alone, so
## in play it was a plain Void nuke.
func test_an_offensive_spell_promising_a_status_chance_carries_it_as_a_rider() -> void:
	var promise := RegEx.new()
	promise.compile("(\\d+)% chance to inflict (\\w+)")
	var checked: int = 0
	for spell: Dictionary in _all_spells():
		if String(spell.get("category", "")) != "offensive":
			continue
		var found: RegExMatch = promise.search(String(spell.get("description", "")))
		if found == null:
			continue
		var rider: Variant = spell.get("rider")
		assert_true(
			rider is Dictionary,
			"%s promises a status chance but has no rider" % String(spell.get("id", "?"))
		)
		if not rider is Dictionary:
			continue
		assert_eq(
			String((rider as Dictionary).get("status", "")),
			found.get_string(2).to_lower(),
			"%s: rider status matches its description" % String(spell.get("id", "?")),
		)
		assert_eq(
			int((rider as Dictionary).get("chance", 0)),
			found.get_string(1).to_int(),
			"%s: rider chance matches its description" % String(spell.get("id", "?")),
		)
		checked += 1
	assert_gt(checked, 0, "no offensive spell promising a status chance was checked")


# ── #434: an offensive spell's status rider ─────────────────────────────


func test_pendulums_echo_afflicts_its_target_with_despair_when_the_rider_lands() -> void:
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 9999)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(RIDER_LANDS_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(), "target": 0})

	assert_lt(vermin.current_hp, 9999, "the Void damage lands first")
	assert_true(vermin.has_status("despair"), "and the 40% rider leaves the target in Despair")
	assert_has(
		said,
		"%s is afflicted with Despair!" % vermin.get_display_name(),
		"announced with the canonical Despair line: %s" % str(said),
	)


func test_pendulums_echo_deals_only_damage_when_the_rider_misses() -> void:
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 9999)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(RIDER_MISSES_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(), "target": 0})

	assert_lt(vermin.current_hp, 9999, "the Void damage still lands")
	assert_false(vermin.has_status("despair"), "but a missed rider inflicts nothing")
	for line: String in said:
		assert_false(line.contains("Despair"), "and nothing claims it did: %s" % line)


func test_pendulums_echo_rider_cannot_afflict_an_enemy_immune_to_despair() -> void:
	# Pallor-type enemies are immune to Despair (enemy.gd TYPE_IMMUNITIES). The
	# seed is the one that lands the rider, so immunity is what stops it.
	var battle: Node = _boot(["pallor_vermin"])
	var pallor: Node = battle.get_enemies()[0]
	assert_true(pallor.is_immune_to_status("despair"), "precondition: Pallor shrug off Despair")
	_pin_target(pallor, 9999)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(RIDER_LANDS_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(), "target": 0})

	assert_lt(pallor.current_hp, 9999, "the Void damage lands")
	assert_false(pallor.has_status("despair"), "an immune enemy is never afflicted")
	for line: String in said:
		assert_false(line.contains("Despair"), "and nothing claims it was: %s" % line)


func test_pendulums_echo_rider_is_not_rolled_on_an_enemy_the_damage_killed() -> void:
	var battle: Node = _boot(["ley_vermin", "ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 1)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(RIDER_LANDS_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(), "target": 0})

	assert_false(vermin.is_alive, "precondition: the damage killed it")
	assert_false(vermin.has_status("despair"), "a dead enemy takes no rider")
	for line: String in said:
		assert_false(line.contains("Despair"), "and nothing claims it did: %s" % line)
