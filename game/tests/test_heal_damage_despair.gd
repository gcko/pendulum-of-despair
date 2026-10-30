extends GutTest
## Despair cuts a heal that lands as damage (#246). A heal spell turned on an
## Undead or a Pallor deals the heal it rolled as damage (test_heal_on_enemy),
## and Despair's -20% damage dealt applies to all damage its bearer deals but
## to no healing (combat-formulas.md § Attacker Status Modifiers, 2026-10-30
## ruling): the heal as rolled, cut to x0.8 and floored. A caster without
## Despair deals it in full. A revival spell's instant kill on an Undead is not
## a rolled amount and still kills under Despair (owner ruling); it is not
## exercised here.
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted,
## the seam the menu feeds.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")

const PROMPT_TIMEOUT: float = 5.0
const CASTER: int = 0
## The variance roll a cast draws; reused to compute the heal it will roll.
const HEAL_SEED: int = 4242
## The caster MAG every cast here uses, so the heal is well clear of 0.
const CASTER_MAG: int = 30
## The enemy's max and current HP, far above any heal here.
const ENEMY_HP: int = 5000

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	randomize()


func _boot(encounter: Array, act: String) -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": act,
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	battle.get_battle_state().get_member(CASTER)["effective_stats"]["mag"] = CASTER_MAG
	var enemy: Node = battle.get_enemies()[0]
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["hp"] = ENEMY_HP
	enemy.enemy_data = data
	enemy.current_hp = ENEMY_HP
	return battle


func _await_prompt(battle: Node) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge("party_%d" % CASTER, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not "party_%d" % CASTER in prompted:
		fail_test("the battle never asked the caster for a command (asked: %s)" % str(prompted))
		return false
	return true


## A shipped spell from [param tradition], free to cast.
func _spell(tradition: String, spell_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


## Cast [param spell] on the first enemy, Despaired or not, and return
## [heal it rolled, HP the enemy lost].
func _heal_damage(encounter: Array, act: String, spell: Dictionary, despaired: bool) -> Array[int]:
	var battle: Node = _boot(encounter, act)
	var state: Node = battle.get_battle_state()
	if despaired:
		assert_true(state.apply_status(CASTER, "despair", "turns", 4), "precondition: Despair")
	if not await _await_prompt(battle):
		return [0, 0]
	seed(HEAL_SEED)
	var heal: int = DamageCalc.calculate_healing(CASTER_MAG, int(spell.get("power", 0)))
	assert_gt(heal, 4, "precondition: a heal big enough for 20% to show")
	seed(HEAL_SEED)
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": 0, "target_enemy": true}
	)
	return [heal, ENEMY_HP - int(battle.get_enemies()[0].current_hp)]


func test_a_despaired_caster_s_heal_on_an_undead_deals_80_percent() -> void:
	var r: Array[int] = await _heal_damage(
		["restless_dead"], "act_i", _spell("spirit", "mend"), true
	)
	assert_eq(r[1], int(floor(r[0] * 0.8)), "Despair cuts the heal-as-damage to x0.8")


func test_a_caster_without_despair_deals_the_heal_in_full_on_an_undead() -> void:
	var r: Array[int] = await _heal_damage(
		["restless_dead"], "act_i", _spell("spirit", "mend"), false
	)
	assert_eq(r[1], r[0], "the whole heal lands as damage")


func test_a_despaired_caster_s_heal_on_a_pallor_deals_80_percent() -> void:
	var r: Array[int] = await _heal_damage(
		["pallor_vermin"], "act_iii", _spell("ley_line", "leybalm"), true
	)
	assert_eq(r[1], int(floor(r[0] * 0.8)), "Pallor Feedback is cut by Despair too")
