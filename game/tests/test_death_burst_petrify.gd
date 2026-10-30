extends GutTest
## A death burst passes over a petrified party member (#246). Petrify is
## "Removed from combat" (magic.md § Status Effect Reference), so the statue is
## not on the field (BattleStatusGuard.on_field) when an enemy with an
## aoe_on_death ability bursts against the party. The burst is resolved by the
## death handler whatever fells the enemy, so the crystal here is felled by a
## plain take_damage, as test_enemy_abilities_integration.gd fells it.
##
## The burst's rolls are pinned: the crystal's SPD is far above the party's,
## and the party's SPD is 0, so every hit roll sits at the 99% cap and no
## member evades. The seed then fixes the one roll left.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## New-game party: Edren in slot 0 stands, Cael in slot 1 is the statue.
const STANDING: int = 0
const STATUE: int = 1
const DEEP_HP: int = 99999

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


func _boot() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["unstable_crystal"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	var state: Node = battle.get_battle_state()
	for slot: int in [STANDING, STATUE]:
		var m: Dictionary = state.get_member(slot)
		m["max_hp"] = DEEP_HP
		m["current_hp"] = DEEP_HP
		m["effective_stats"]["spd"] = 0
	var crystal: Node = battle.get_enemies()[0]
	var data: Dictionary = crystal.enemy_data.duplicate(true)
	data["spd"] = 999
	crystal.enemy_data = data
	return battle


func _hp(battle: Node, slot: int) -> int:
	return int(battle.get_battle_state().get_member(slot)["current_hp"])


func test_a_crystal_s_death_burst_leaves_a_petrified_member_untouched() -> void:
	seed(11)
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	assert_true(state.apply_status(STATUE, "petrify", "turns", -1), "precondition: petrified")
	battle.get_enemies()[0].take_damage(999999)
	assert_lt(_hp(battle, STANDING), DEEP_HP, "precondition: the burst hit the member standing")
	assert_eq(_hp(battle, STATUE), DEEP_HP, "and passed over the statue")
