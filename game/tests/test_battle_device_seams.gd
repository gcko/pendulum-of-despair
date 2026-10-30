extends GutTest
## Where Lira's devices and Overcharge meet the battle loop (#158, #246):
## Shock Coil's strike rides begin_turn's event channel, so its kill is judged
## before any command menu opens; one AoE attack springs one Arc Trap; and a
## strike the enemy absorbed earns no threat.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Edren in slot 0, Cael in slot 1; Lira is seated in slot 2.
const EDREN := 0
const CAEL := 1
const LIRA := 2
const STURDY_HP := 5000

var _booted: Node = null


func before_each() -> void:
	seed(12345)
	GameManager.transition_data = {}


func after_each() -> void:
	_free_battle()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


func _free_battle() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null


## Boot a real battle against [param encounter] with Lira seated in slot 2.
func _boot(encounter: Array = ["ley_vermin"]) -> Node:
	_free_battle()
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
	battle.set_process(false)
	_booted = battle
	var state: Node = battle.get_battle_state()
	(
		state
		. add_member(
			LIRA,
			{
				"character_id": "lira",
				"name": "Lira",
				"max_hp": STURDY_HP,
				"base_stats":
				{"hp": STURDY_HP, "atk": 30, "def": 20, "mag": 60, "mdef": 20, "spd": 10, "lck": 0},
			}
		)
	)
	battle.get_atb().add_combatant("party_%d" % LIRA, 10, false)
	for slot: int in [EDREN, CAEL]:
		state.get_member(slot)["max_hp"] = STURDY_HP
		state.get_member(slot)["current_hp"] = STURDY_HP
	return battle


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("lira"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("lira.json has no ability '%s'" % ability_id)
	return {}


## Give [param id] the only full gauge and run one frame.
func _only_turn(battle: Node, id: String) -> void:
	var atb: Node = battle.get_atb()
	for slot: int in range(4):
		atb.set_gauge("party_%d" % slot, 0)
	for i: int in range(battle.get_enemies().size()):
		atb.set_gauge("enemy_%d" % i, 0)
	atb.set_gauge(id, ATBSystem.GAUGE_MAX)
	battle._process(0.0)


# --- Shock Coil strikes through begin_turn's events ---


func test_a_shock_coil_that_fells_the_last_enemy_wins_before_lira_s_menu() -> void:
	for s: int in range(1, 60):
		var battle: Node = _boot()
		var vermin: Node = battle.get_enemies()[0]
		vermin.current_hp = 1
		Forgewright.deploy(battle.get_battle_state(), LIRA, _ability("shock_coil"), -1)
		watch_signals(battle)
		seed(s)
		_only_turn(battle, "party_%d" % LIRA)
		if vermin.is_alive:
			continue  # the coil missed on this seed
		assert_signal_emitted_with_parameters(battle, "combatant_died", ["enemy_0"])
		assert_signal_emitted(battle, "victory", "the coil's kill wins the battle")
		assert_signal_not_emitted(battle, "turn_ready", "no menu for a won battle")
		return
	fail_test("the coil never landed")


func test_a_coil_kill_whose_death_burst_fells_lira_opens_no_menu_for_her() -> void:
	for s: int in range(1, 60):
		var battle: Node = _boot(["ley_vermin", "ley_vermin"])
		var state: Node = battle.get_battle_state()
		for e: Node in battle.get_enemies():
			e.current_hp = 1
			e.died.connect(func() -> void: state.take_damage(LIRA, 99999))
		Forgewright.deploy(state, LIRA, _ability("shock_coil"), -1)
		watch_signals(battle)
		seed(s)
		_only_turn(battle, "party_%d" % LIRA)
		if state.get_member(LIRA)["is_alive"]:
			continue  # the coil missed on this seed
		assert_signal_not_emitted(battle, "turn_ready", "no menu for a fallen Lira")
		assert_signal_not_emitted(battle, "victory", "one vermin still stands")
		return
	fail_test("the coil never landed")
