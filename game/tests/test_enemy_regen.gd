extends GutTest
## Kindle Breath turned on an enemy (#503). Owner ruling: Regen cast on an
## enemy ticks the way a heal on that enemy lands. Each of the enemy's turns
## restores 5% of its max HP, at least 1, for the spell's 4 turns ("restores 5%
## max HP per turn for 4 turns", magic.md § 37 Kindle Breath), and on an Undead
## or a Pallor each tick is damage instead (bestiary/README.md § Undead; for a
## Pallor, combat-formulas.md § Tier 2), with the heal-on-enemy rules: no
## element or type multiplier, cut by the caster's Despair
## (BattleDamageMods.cut_dealt), shown as damage, threat for the caster and a
## kill cleaned up like any other. Healing a normal enemy earns no Weave Gauge
## (2026-10-29 ruling).
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted.
## An enemy's turn is run by BattleEnemyTurn.execute, the call the battle loop
## makes when its gauge fills; the enemy's abilities are cleared so its own
## action never touches its HP.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")

const PROMPT_TIMEOUT: float = 5.0
const CASTER: int = 0
## Maren's slot when a test recruits her, for the Weave Gauge she banks.
const MAREN: int = 2
const MAX_HP: int = 1000

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	seed(12345)


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	randomize()


## Boot against [param enemy_id] at [param hp] of MAX_HP, its abilities cleared
## on a copy of its data so the cached table is untouched.
func _boot(enemy_id: String, hp: int, act: String = "act_i") -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": [enemy_id],
		"enemy_act": act,
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	var enemy: Node = battle.get_enemies()[0]
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["hp"] = MAX_HP
	data["abilities"] = []
	enemy.enemy_data = data
	enemy.current_hp = hp
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


func _kindle_breath() -> Dictionary:
	for entry: Variant in DataManager.load_spells("spirit"):
		if String((entry as Dictionary).get("id", "")) == "kindle_breath":
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("kindle_breath is missing from spirit.json")
	return {}


## Wait for the caster's prompt, then turn Kindle Breath on enemy 0.
func _cast(battle: Node) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": _kindle_breath(), "target": 0, "target_enemy": true}
	)
	return true


## Run one turn of enemy 0's, as the battle loop does when its gauge fills.
func _enemy_turn(battle: Node) -> void:
	var turn := BattleEnemyTurn.new(
		battle, battle.get_battle_state(), battle.get_atb(), battle.get_node("EnemyArea")
	)
	turn.execute("enemy_0", battle.get_enemies(), false, 0)


## Enemy 0's HP after each of [param turns] of its turns.
func _hp_over_turns(battle: Node, turns: int) -> Array[int]:
	var seen: Array[int] = []
	for _turn: int in range(turns):
		_enemy_turn(battle)
		seen.append(int(battle.get_enemies()[0].current_hp))
	return seen


func _markers(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.damage_dealt.connect(
		func(tid: String, amt: int, dt: String) -> void:
			if tid.begins_with("enemy_"):
				out.append("%s:%s:%d" % [tid, dt, amt])
	)
	return out


func test_kindle_breath_heals_a_normal_enemy_5_percent_a_turn_for_4_turns() -> void:
	var battle: Node = _boot("ley_vermin", 100)
	var said: Array[String] = []
	battle.message.connect(func(text: String) -> void: said.append(text))
	if not await _cast(battle):
		return
	assert_true(said.any(func(t: String) -> bool: return " casts Kindle Breath!" in t), str(said))
	assert_eq(battle.get_enemies()[0].current_hp, 100, "the cast itself heals nothing")
	var seen: Array[int] = _hp_over_turns(battle, 5)
	assert_eq(seen, [150, 200, 250, 300, 300] as Array[int], "50 HP a turn, four turns")


func test_a_regen_tick_on_a_normal_enemy_is_shown_as_a_heal() -> void:
	var battle: Node = _boot("ley_vermin", 100)
	if not await _cast(battle):
		return
	var markers: Array[String] = _markers(battle)
	_enemy_turn(battle)
	assert_has(markers, "enemy_0:heal:50", "shown as a heal: %s" % str(markers))


func test_kindle_breath_on_a_normal_enemy_earns_no_weave_gauge() -> void:
	var battle: Node = _boot("ley_vermin", 100)
	var state: Node = battle.get_battle_state()
	state.add_member(MAREN, {"character_id": "maren", "base_stats": {"hp": 100, "mp": 10}})
	if not await _cast(battle):
		return
	_enemy_turn(battle)
	assert_gt(battle.get_enemies()[0].current_hp, 100, "precondition: the regen healed it")
	assert_eq(int(state.get_member(MAREN).get("wg", 0)), 0, "Maren banks nothing for it")


func test_kindle_breath_damages_an_undead_5_percent_a_turn_for_4_turns() -> void:
	var battle: Node = _boot("restless_dead", MAX_HP)
	if not await _cast(battle):
		return
	var markers: Array[String] = _markers(battle)
	var seen: Array[int] = _hp_over_turns(battle, 5)
	assert_eq(seen, [950, 900, 850, 800, 800] as Array[int], "50 damage a turn, four turns")
	assert_has(markers, "enemy_0:magic:50", "shown as damage: %s" % str(markers))


func test_kindle_breath_damages_a_pallor_enemy() -> void:
	var battle: Node = _boot("pallor_vermin", MAX_HP, "act_iii")
	if not await _cast(battle):
		return
	_enemy_turn(battle)
	assert_eq(battle.get_enemies()[0].current_hp, 950, "Pallor Feedback: the tick is damage")


func test_a_despaired_caster_s_kindle_breath_on_an_undead_deals_80_percent() -> void:
	var battle: Node = _boot("restless_dead", MAX_HP)
	var state: Node = battle.get_battle_state()
	if not await _await_prompt(battle):
		return
	assert_true(state.apply_status(CASTER, "despair", "turns", 4.0), "precondition: Despair")
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": _kindle_breath(), "target": 0, "target_enemy": true}
	)
	_enemy_turn(battle)
	assert_eq(battle.get_enemies()[0].current_hp, MAX_HP - 40, "50 cut to 40")


func test_regen_damage_on_an_undead_draws_threat_for_the_caster() -> void:
	var battle: Node = _boot("restless_dead", MAX_HP)
	var state: Node = battle.get_battle_state()
	if not await _cast(battle):
		return
	var before: int = int(state.get_member(CASTER).get("threat_dealt", 0))
	_enemy_turn(battle)
	assert_eq(int(state.get_member(CASTER).get("threat_dealt", 0)) - before, 50, "50 threat")


func test_a_regen_tick_that_drops_an_undead_to_zero_kills_it() -> void:
	var battle: Node = _boot("restless_dead", 30)
	if not await _cast(battle):
		return
	watch_signals(battle)
	battle.get_atb().set_gauge("enemy_0", 5000)
	_enemy_turn(battle)
	var dead: Node = battle.get_enemies()[0]
	assert_false(dead.is_alive, "the Undead falls")
	assert_signal_emitted_with_parameters(battle, "combatant_died", ["enemy_0"])
	assert_eq(battle.get_atb().get_gauge("enemy_0"), 0, "and leaves the ATB")


func test_kindle_breath_on_an_enemy_spends_its_mp() -> void:
	var battle: Node = _boot("restless_dead", MAX_HP)
	var state: Node = battle.get_battle_state()
	if not await _await_prompt(battle):
		return
	state.get_member(CASTER)["current_mp"] = 50
	var spell: Dictionary = _kindle_breath()
	spell["mp_cost"] = 6
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": 0, "target_enemy": true}
	)
	var cost: int = SpellHelpers.get_mp_cost(spell, state.get_member(CASTER)["character_id"])
	assert_gt(cost, 0, "precondition: the cast costs MP")
	assert_eq(int(state.get_member(CASTER)["current_mp"]), 50 - cost, "the cast is not refused")


func test_kindle_breath_on_an_undead_banks_weave_gauge() -> void:
	# The cast lands an effect that will deal damage, as a heal on an Undead does.
	var battle: Node = _boot("restless_dead", MAX_HP)
	var state: Node = battle.get_battle_state()
	state.add_member(MAREN, {"character_id": "maren", "base_stats": {"hp": 100, "mp": 10}})
	if not await _cast(battle):
		return
	assert_eq(int(state.get_member(MAREN).get("wg", 0)), 10, "Maren banks 10 for Edren's cast")


func test_dispersion_strips_a_regen_off_an_enemy() -> void:
	# The Regen row's "Cured By" is Dispersion / Mass Dispersion
	# (magic.md § Status Effect Reference).
	var battle: Node = _boot("ley_vermin", 100)
	if not await _cast(battle):
		return
	if not await _await_prompt(battle):
		return
	var dispersion: Dictionary = {}
	for entry: Variant in DataManager.load_spells("ley_line"):
		if String((entry as Dictionary).get("id", "")) == "dispersion":
			dispersion = (entry as Dictionary).duplicate(true)
	dispersion["mp_cost"] = 0
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": dispersion, "target": 0, "target_enemy": true}
	)
	_enemy_turn(battle)
	assert_eq(battle.get_enemies()[0].current_hp, 100, "no tick lands after the dispel")
