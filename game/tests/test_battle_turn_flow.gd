extends GutTest
## Two seams of the battle loop (#246, cross-bundle notes from bundle B):
## an enemy's SPD buff or debuff is what its ATB gauge fills at, and a party
## member's turn-start effects can end the battle before any command menu opens.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Edren in slot 0, Cael in slot 1.
const EDREN := 0
const CAEL := 1

var _booted: Node = null


func before_each() -> void:
	seed(12345)
	GameManager.transition_data = {}


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	GameManager.transition_data = {}
	randomize()


## Boot a real battle against one Ley Vermin, driven frame by frame by hand.
func _boot() -> Node:
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
	return battle


## The vermin's gauge after one tick from empty, at the battle's speed setting.
func _one_tick_of_enemy_fill(battle: Node) -> int:
	var atb: Node = battle.get_atb()
	for id: String in ["party_0", "party_1", "enemy_0"]:
		atb.set_gauge(id, 0)
	battle._process(1.0 / ATBSystem.TICKS_PER_SECOND)
	return atb.get_gauge("enemy_0")


func _speed() -> int:
	return ATBSystem.settings_from_config(PartyState.get_config())["speed"]


func test_an_enemy_s_spd_debuff_slows_its_gauge() -> void:
	# Arc Trap's -20% SPD (enemy.apply_buff("spd", 0.8, 2)) must reach the fill
	# rate, not only the hit and evasion rolls: fill_rate = (SPD + 25) x factor.
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	var base_spd: int = int(vermin.enemy_data.get("spd", 0))
	vermin.apply_buff("spd", 0.8, 2)
	var slowed_spd: int = int(vermin.get_stats()["spd"])
	assert_lt(slowed_spd, base_spd, "precondition: the debuff lowers SPD")
	assert_eq(
		_one_tick_of_enemy_fill(battle),
		battle.get_atb().calculate_fill_rate(slowed_spd, _speed(), []),
		"the gauge fills at the debuffed SPD"
	)


func test_an_enemy_s_gauge_returns_to_its_base_rate_when_the_buff_ends() -> void:
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	vermin.apply_buff("spd", 1.5, 1)
	_one_tick_of_enemy_fill(battle)
	vermin.tick_buffs()  # the buff's one turn is over
	assert_eq(
		_one_tick_of_enemy_fill(battle),
		battle.get_atb().calculate_fill_rate(int(vermin.enemy_data.get("spd", 0)), _speed(), []),
		"back to the base fill rate"
	)


func test_a_turn_start_effect_that_fells_the_last_enemy_wins_before_any_menu() -> void:
	# Second Wind's regen lands as Edren's turn begins (abilities.md § Cael —
	# Rally). Here that heal is what fells the vermin, standing in for any
	# turn-start effect that hits the enemy line: the battle is won on that turn,
	# so no command menu opens.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	var vermin: Node = battle.get_enemies()[0]
	state.take_damage(EDREN, 40)
	BattleRally.start(state, CAEL, "second_wind", AbilityCommand.RALLY_EFFECTS["second_wind"])
	state.member_healed.connect(
		func(slot: int, _amount: int) -> void:
			if slot == EDREN:
				vermin.take_damage(vermin.current_hp)
	)
	watch_signals(battle)
	var atb: Node = battle.get_atb()
	for id: String in ["party_1", "enemy_0"]:
		atb.set_gauge(id, 0)
	atb.set_gauge("party_0", ATBSystem.GAUGE_MAX)
	battle._process(0.0)
	assert_false(vermin.is_alive, "precondition: the turn-start heal felled the vermin")
	assert_signal_emitted(battle, "victory", "the battle is won on this frame")
	assert_signal_not_emitted(battle, "turn_ready", "no command menu for a won battle")


func test_a_member_felled_by_their_own_turn_start_is_never_prompted() -> void:
	# A turn-start effect, or a death burst it sets off, can KO the member whose
	# turn it is. Here Second Wind's regen on Edren is hooked to fell him.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	state.take_damage(EDREN, 40)
	BattleRally.start(state, CAEL, "second_wind", AbilityCommand.RALLY_EFFECTS["second_wind"])
	state.member_healed.connect(
		func(slot: int, _amount: int) -> void:
			if slot == EDREN:
				state.take_damage(EDREN, 99999)
	)
	watch_signals(battle)
	var atb: Node = battle.get_atb()
	for id: String in ["party_1", "enemy_0"]:
		atb.set_gauge(id, 0)
	atb.set_gauge("party_0", ATBSystem.GAUGE_MAX)
	battle._process(0.0)
	assert_false(state.get_member(EDREN)["is_alive"], "precondition: the turn start felled Edren")
	assert_signal_not_emitted(battle, "turn_ready", "no command menu for a fallen member")
