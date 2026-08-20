extends GutTest
## Enemy abilities (GAP-024) resolved end-to-end through the real battle
## scene. These boot battle.tscn and drive the WIRED turn driver directly
## (bypassing the AI's RNG branch) so each mechanic is proven against the
## assembled scene and deterministically.
##
## The same mechanics at unit level are test_enemy_abilities.gd (#374).

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")


func after_each() -> void:
	# Undo any seed() so determinism doesn't leak into later tests.
	randomize()


func _boot(encounter: Array, is_boss: bool = false) -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": is_boss,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	# _ready builds the enemies and the ATB gauges, and it runs inside
	# add_child — there is no later frame to wait for.
	add_child_autofree(battle)
	return battle


func test_integration_venom_spit_inflicts_poison_on_party() -> void:
	seed(909)
	var battle: Node = _boot(["marsh_serpent"])
	var serpent: Node = battle._enemies[0]
	var landed: bool = false
	for _i: int in range(25):
		battle._state.heal(0, 99999)  # keep the target alive so we can keep rolling
		var action: Dictionary = {
			"type": "ability",
			"id": "venom_spit",
			"target": "single",
			"atk_type": "attack",
			"target_slot": 0,
			"ability_mult": 1.0,
			"hits": 1,
			"status": "poison",
			"status_rate": 100,
			"status_duration": null,
		}
		battle._enemy_turn._do_attack_or_ability(action, serpent, 0)
		if battle._state.has_status(0, "poison"):
			landed = true
			break
	assert_true(landed, "Venom Spit inflicts Poison on a party member via the wired turn driver")


func test_integration_shard_burst_fires_on_crystal_death() -> void:
	seed(11)
	var battle: Node = _boot(["unstable_crystal"])
	var crystal: Node = battle._enemies[0]
	var hp_before: int = 0
	for i: int in range(4):
		hp_before += int(battle._state.get_member(i).get("current_hp", 0))
	# death -> Enemy.died -> _on_enemy_died -> Shard Burst, all on this call.
	crystal.take_damage(999999)
	var hp_after: int = 0
	for i: int in range(4):
		hp_after += int(battle._state.get_member(i).get("current_hp", 0))
	assert_lt(hp_after, hp_before, "Shard Burst damages the party when the crystal dies")


func test_integration_pack_howl_buffs_all_wolves() -> void:
	var battle: Node = _boot(["wayward_wolf", "wayward_wolf"])
	var w0: Node = battle._enemies[0]
	var w1: Node = battle._enemies[1]
	var atk_before: int = int(w1.get_stats().get("atk", 0))
	var action: Dictionary = {
		"type": "ability",
		"id": "pack_howl",
		"target": "self",
		"atk_type": "buff",
		"buff": {"stat": "atk", "mult": 1.30, "duration": 5, "scope": "pack"},
	}
	battle._enemy_turn._do_self_ability(action, w0, battle._enemies)
	assert_gt(
		int(w1.get_stats().get("atk", 0)), atk_before, "Pack Howl buffs the OTHER wolf (pack scope)"
	)
	assert_gt(w0.active_buffs.size(), 0, "the casting wolf is buffed too")


func test_integration_nonelemental_magic_aoe_uses_magic_formula() -> void:
	seed(77)
	var battle: Node = _boot(["unstable_crystal"])
	var crystal: Node = battle._enemies[0]
	# Force the distinction: ATK 0 so a physical AoE deals ~1/member; high MAG so a
	# magic AoE deals real damage. A non-elemental magic AoE must route through the
	# MAG formula (the _resolve_offensive fix), not the physical ATK formula.
	crystal.enemy_data["atk"] = 0
	crystal.enemy_data["mag"] = 60
	var action: Dictionary = {
		"type": "ability",
		"id": "x",
		"target": "all",
		"atk_type": "magic",
		"element": "",
		"power": 20
	}
	var before: int = 0
	for i: int in range(4):
		before += int(battle._state.get_member(i).get("current_hp", 0))
	battle._enemy_turn._do_attack_or_ability(action, crystal, 0)
	var after: int = 0
	for i: int in range(4):
		after += int(battle._state.get_member(i).get("current_hp", 0))
	assert_lt(
		after, before - 50, "non-elemental magic AoE deals MAG-based damage, not ~1/member physical"
	)


func test_integration_pack_howl_does_not_buff_other_species() -> void:
	var battle: Node = _boot(["wayward_wolf", "wild_boar"])
	var wolf: Node = battle._enemies[0]
	var boar: Node = battle._enemies[1]
	var boar_atk_before: int = int(boar.get_stats().get("atk", 0))
	var action: Dictionary = {
		"type": "ability",
		"id": "pack_howl",
		"target": "self",
		"atk_type": "buff",
		"buff": {"stat": "atk", "mult": 1.30, "duration": 5, "scope": "pack"},
	}
	battle._enemy_turn._do_self_ability(action, wolf, battle._enemies)
	assert_eq(
		int(boar.get_stats().get("atk", 0)),
		boar_atk_before,
		"Pack Howl does NOT buff a different species (id mismatch)"
	)
	assert_gt(wolf.active_buffs.size(), 0, "the wolf itself is still buffed")
