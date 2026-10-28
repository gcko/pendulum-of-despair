extends GutTest
## A status landing on an enemy, driven through the real battle scene: what the
## player is told whatever path inflicted it (#439), and the status rider an
## offensive spell rolls on top of its damage (#434).
##
## Like test_combat_playtest.gd, the casts boot battle.tscn and go in through the
## seam the battle UI uses — wait for turn_ready, then emit
## BattleUI.command_submitted — so what is proven is the path a player drives.
##
## Every target has its MDEF zeroed, so a status roll's Stage 1 meets its full
## base rate (combat-formulas.md § Status Effect Accuracy), and the rider casts
## swap the shipped 40% for a chance of 100 or 0: whether the rider lands is then
## the test's choice, not the RNG's. The shipped 40 is pinned by the data checks.
## The one roll left to chance is whether the damage itself hits, which HIT_SEED
## settles (see there).
##
## The rider data checks (band, registry status, description match) live here
## rather than in test_spell_balance.gd, which sits at the 600-line ceiling
## (technical-architecture.md 1.2a).

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

const SPELL_DIR: String = "res://data/spells"

## Real time allowed for the battle to answer a full ATB gauge with a prompt.
const PROMPT_TIMEOUT: float = 5.0

## A damage spell draws its hit roll, its evasion roll and its variance before
## the rider draws. Seed 80 draws 12 / 92 / 78 / 42 / 8: a hit roll under the 20%
## floor no hit rate sinks below and an evasion roll over the 50% ceiling, so the
## damage lands whatever the two combatants' SPD. Its fifth draw, 8, is under the
## 40% Magic Evasion ceiling: a rider that wrongly rolled Magic Evasion after its
## Stage 1 would be resisted on this seed, which is what the MEVA test relies on.
const HIT_SEED: int = 80

## SPD that puts a 0-MDEF target at the 40% Magic Evasion cap ((MDEF + SPD) / 8).
const MEVA_CAP_SPD: int = 320

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


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


## Zero the enemy's MDEF, set its SPD and give it [param hp]. The data is copied
## first so the cached enemy table is left untouched.
func _pin_target(enemy: Node, hp: int, spd: int = 0) -> void:
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["mdef"] = 0
	data["spd"] = spd
	data["hp"] = hp
	enemy.enemy_data = data
	enemy.current_hp = hp


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


func _markers(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.damage_dealt.connect(
		func(tid: String, _amt: int, dt: String) -> void: out.append("%s:%s" % [tid, dt])
	)
	return out


## The line that proves the cast resolved, so a "nothing claims Despair" check
## cannot pass on a cast that never happened.
func _cast_line(battle: Node) -> String:
	var caster: Dictionary = battle.get_battle_state().get_member(0)
	return "%s casts Pendulum's Echo!" % caster.get("character_data", {}).get("name", "???")


func _all_spells() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var dir: DirAccess = DirAccess.open(SPELL_DIR)
	if dir == null:
		fail_test("cannot open %s" % SPELL_DIR)
		return out
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".json"):
			continue
		var loaded: Array = DataManager.load_spells(file_name.get_basename())
		if loaded.is_empty():
			fail_test("No spells loaded from %s" % file_name)
		for entry: Variant in loaded:
			out.append(entry as Dictionary)
	return out


## The shipped Pendulum's Echo with its rider chance set to [param chance], and
## free to cast so the new-game party can afford it.
func _pendulums_echo(chance: int) -> Dictionary:
	for spell: Dictionary in _all_spells():
		if String(spell.get("id", "")) == "pendulums_echo":
			var echo: Dictionary = spell.duplicate(true)
			echo["mp_cost"] = 0
			echo["rider"]["chance"] = chance
			return echo
	fail_test("pendulums_echo is missing from %s" % SPELL_DIR)
	return {}


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


func _assert_no_despair_claim(said: Array[String], battle: Node) -> void:
	assert_has(said, _cast_line(battle), "precondition: the cast resolved: %s" % str(said))
	for line: String in said:
		assert_false(line.contains("Despair"), "and nothing claims Despair landed: %s" % line)


# ── #439: every enemy status reads the registry line ────────────────────


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


func test_a_status_landing_on_an_enemy_by_any_path_is_announced() -> void:
	# Not the Magic command: the battle's own rules land the status directly,
	# as an ability or an item will. The enemy's status_applied is what speaks.
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 500)
	var said: Array[String] = _messages(battle)
	var markers: Array[String] = _markers(battle)

	var result: Dictionary = BattleActions.apply_status_to_enemy(
		battle.get_battle_state(), 0, 100, "poison", null, vermin
	)

	assert_true(result.get("inflicted", false), "precondition: the poison landed")
	assert_has(said, "%s is Poisoned!" % vermin.get_display_name(), "announced: %s" % str(said))
	assert_has(markers, "enemy_0:status", "and marked over that enemy: %s" % str(markers))


func test_a_status_landing_on_a_summoned_add_is_announced() -> void:
	# An add the Corrupted Fenmother summons mid-battle was not there when the
	# battle wired its enemies, so the summon must wire it too. Phase 2 (40% HP)
	# on turn 3 with one add alive fires the summon (see test_boss_ai.gd).
	var battle: Node = _boot(["corrupted_fenmother", "corrupted_spawn"])
	var fenmother: Node = battle.get_enemies()[0]
	fenmother.current_hp = int(fenmother.enemy_data.get("hp", 1) * 0.4)
	battle.get("_enemy_turn").execute("enemy_0", battle.get_enemies(), true, 3)
	assert_eq(battle.get_enemies().size(), 3, "precondition: the Fenmother summoned an add")
	var add: Node = battle.get_enemies()[2]
	var said: Array[String] = _messages(battle)
	var markers: Array[String] = _markers(battle)

	assert_true(add.apply_status("slow", 5), "precondition: the add can be slowed")

	assert_has(said, "%s is Slowed!" % add.get_display_name(), "announced: %s" % str(said))
	assert_has(markers, "enemy_2:status", "and marked over the add: %s" % str(markers))


# ── #434: rider data ─────────────────────────────────────────────────────


## Per magic.md § Derived Rules, a rider binds on `category: offensive` only, is
## priced below the 60% standard-band floor at 30-50%, and must name a status the
## battle layer can actually inflict, or the roll it promises can never land.
func test_status_riders_sit_in_the_rider_band_and_name_a_known_status() -> void:
	var checked: int = 0
	for spell: Dictionary in _all_spells():
		if spell.get("rider") == null:
			continue
		var spell_id: String = String(spell.get("id", "?"))
		var rider: Dictionary = spell.get("rider")
		assert_eq(
			String(spell.get("category", "")),
			"offensive",
			"%s: only an offensive spell carries a rider" % spell_id,
		)
		assert_between(int(rider.get("chance", 0)), 30, 50, "%s: rider band is 30-50" % spell_id)
		var status: String = String(rider.get("status", ""))
		assert_true(
			StatusEffects.is_known(status),
			"%s: rider status '%s' is not in the status registry" % [spell_id, status],
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
		var spell_id: String = String(spell.get("id", "?"))
		var rider: Variant = spell.get("rider")
		assert_true(rider is Dictionary, "%s promises a status chance but has no rider" % spell_id)
		if not rider is Dictionary:
			continue
		assert_eq(
			String((rider as Dictionary).get("status", "")),
			found.get_string(2).to_lower(),
			"%s: rider status matches its description" % spell_id,
		)
		assert_eq(
			int((rider as Dictionary).get("chance", 0)),
			found.get_string(1).to_int(),
			"%s: rider chance matches its description" % spell_id,
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

	seed(HIT_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(100), "target": 0})

	assert_lt(vermin.current_hp, 9999, "the Void damage lands first")
	assert_true(vermin.has_status("despair"), "and the rider leaves the target in Despair")
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

	seed(HIT_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(0), "target": 0})

	assert_lt(vermin.current_hp, 9999, "the Void damage still lands")
	assert_false(vermin.has_status("despair"), "but a missed rider inflicts nothing")
	_assert_no_despair_claim(said, battle)


func test_pendulums_echo_rider_ignores_magic_evasion() -> void:
	# Damage spells skip the Magic Evasion check (progression.md § Derived
	# Stats), and a rider rides on one: a target at the 40% MEVA cap is no
	# harder to afflict than any other.
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 9999, MEVA_CAP_SPD)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(HIT_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(100), "target": 0})

	assert_lt(vermin.current_hp, 9999, "precondition: the Void damage lands")
	assert_true(vermin.has_status("despair"), "a high-MEVA target is afflicted all the same")


func test_pendulums_echo_rider_cannot_afflict_an_enemy_immune_to_despair() -> void:
	# Pallor-type enemies are immune to Despair (enemy.gd TYPE_IMMUNITIES). The
	# rider is certain to land otherwise, so immunity is what stops it.
	var battle: Node = _boot(["pallor_vermin"])
	var pallor: Node = battle.get_enemies()[0]
	assert_true(pallor.is_immune_to_status("despair"), "precondition: Pallor shrug off Despair")
	_pin_target(pallor, 9999)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(HIT_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(100), "target": 0})

	assert_lt(pallor.current_hp, 9999, "the Void damage lands")
	assert_false(pallor.has_status("despair"), "an immune enemy is never afflicted")
	_assert_no_despair_claim(said, battle)


func test_pendulums_echo_rider_is_never_afflicted_on_an_enemy_the_damage_killed() -> void:
	var battle: Node = _boot(["ley_vermin", "ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 1)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	seed(HIT_SEED)
	_submit(battle, {"type": "magic", "spell": _pendulums_echo(100), "target": 0})

	assert_false(vermin.is_alive, "precondition: the damage killed it")
	assert_false(vermin.has_status("despair"), "a dead enemy takes no rider")
	_assert_no_despair_claim(said, battle)
