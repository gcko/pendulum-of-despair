extends GutTest
## Tests for enemy abilities (GAP-024): enemy->party offensive status infliction,
## party-side DoT ticking, multi-hit, AoE-on-death, and pack buffs. Every numeric
## constant traces to docs/story/bestiary/enemy-ability-conventions.md and the
## canon it cites (magic.md / combat-formulas.md).

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const BattleAI = preload("res://scripts/combat/battle_ai.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")

## Poison: 8% max HP/turn, until cured (magic.md:1392). UNTIL_CURED sentinel = -1.
const UNTIL_CURED: int = -1


func after_each() -> void:
	# Undo any seed() so determinism doesn't leak into later tests.
	randomize()


## A party state with one member whose defensive stats we control, so the
## two-stage status roll (DamageCalc.roll_status) is exercised against known
## MDEF/SPD. mag is irrelevant to the target side but required by add_member.
func _make_party(mdef: int, spd: int, hp: int = 100) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			0,
			{
				"character_id": "tester",
				"base_stats": {"mag": 10, "mdef": mdef, "spd": spd, "hp": hp, "mp": 0},
				"max_hp": hp,
				"current_hp": hp,
			}
		)
	)
	return state


func _make_enemy(enemy_id: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.initialize(enemy_id, "act_i")
	return enemy


## A synthetic enemy with fully controlled stats (bypasses DataManager) so
## damage math is deterministic and independent of bestiary tuning.
func _make_synthetic_enemy(data: Dictionary) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.enemy_data = data
	enemy.current_hp = data.get("hp", 100)
	enemy.is_alive = enemy.current_hp > 0
	return enemy


## Party state with one member built from an explicit stat dict.
func _party_with(base_stats: Dictionary, hp: int = 100) -> Node:
	return _party_members(1, base_stats, hp)


## Party state with `count` identical members (slots 0..count-1).
func _party_members(count: int, base_stats: Dictionary, hp: int = 100) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	for i: int in range(count):
		state.add_member(
			i, {"character_id": "tester", "base_stats": base_stats, "max_hp": hp, "current_hp": hp}
		)
	return state


# --- Enemy -> party status infliction (GAP-024) ---


func test_enemy_inflicts_status_on_party_member() -> void:
	# High rate + a high-MAG enemy vs a low-MDEF/SPD party member: the two-stage
	# roll lands within a few tries. marsh_serpent's Venom Spit delivers Poison.
	seed(12345)
	var inflicted_any: bool = false
	for _i: int in range(30):
		var state: Node = _make_party(0, 0)
		var enemy: Enemy = _make_enemy("marsh_serpent")
		var r: Dictionary = BattleActions.execute_enemy_status(state, enemy, 0, 100, "poison", null)
		if r.get("inflicted", false):
			inflicted_any = true
			assert_eq(r.get("type", ""), "status", "a landed status reports type 'status'")
			assert_true(state.has_status(0, "poison"), "party member actually carries the status")
			break
	assert_true(inflicted_any, "a 100%-rate status should land within 30 attempts")


func test_enemy_status_resisted_when_rate_zero() -> void:
	# base_rate 0 -> Stage 1 effective rate 0 -> always fails. Deterministic.
	var state: Node = _make_party(10, 10)
	var enemy: Enemy = _make_enemy("marsh_serpent")
	var r: Dictionary = BattleActions.execute_enemy_status(state, enemy, 0, 0, "poison", null)
	assert_false(r.get("inflicted", false), "0% rate never inflicts")
	assert_eq(r.get("type", ""), "resisted")
	assert_false(state.has_status(0, "poison"))


func test_enemy_status_no_effect_on_dead_member() -> void:
	var state: Node = _make_party(0, 0, 0)  # hp 0 -> not alive
	var enemy: Enemy = _make_enemy("marsh_serpent")
	var r: Dictionary = BattleActions.execute_enemy_status(state, enemy, 0, 100, "poison", null)
	assert_false(r.get("inflicted", false), "cannot afflict a downed member")
	assert_eq(r.get("type", ""), "no_effect")


func test_enemy_status_unknown_is_no_effect() -> void:
	# 'paralysis' is undefined (deferred) -> graceful no-op, never inflicted.
	var state: Node = _make_party(0, 0)
	var enemy: Enemy = _make_enemy("marsh_serpent")
	var r: Dictionary = BattleActions.execute_enemy_status(state, enemy, 0, 100, "paralysis", null)
	assert_eq(r.get("type", ""), "no_effect")
	assert_false(state.has_status(0, "paralysis"))


# --- Party-side damage-over-time (Poison/Burn) ---


func test_poison_ticks_party_member_hp() -> void:
	# Poison = 8% max HP/turn (magic.md:1392). 100 max HP -> 8 per tick, floor 1.
	var state: Node = _make_party(0, 0, 100)
	state.apply_status(0, "poison", "turns", UNTIL_CURED)
	state.tick_statuses(0)
	var hp: int = state.get_member(0).get("current_hp", 100)
	assert_eq(hp, 92, "8% of 100 max HP lost to a single poison tick")


func test_until_cured_status_is_not_decremented_away() -> void:
	# A negative (UNTIL_CURED) duration must persist across ticks, like enemy side.
	var state: Node = _make_party(0, 0, 100)
	state.apply_status(0, "poison", "turns", UNTIL_CURED)
	state.tick_statuses(0)
	state.tick_statuses(0)
	assert_true(state.has_status(0, "poison"), "until-cured poison survives multiple ticks")


# --- ability_mult power knob + multi-hit (GAP-024) ---


func test_ability_mult_scales_physical_damage() -> void:
	# Same seed -> identical hit/evasion/crit/variance rolls, so a higher
	# ability_mult must yield strictly more damage (raw scales by mult pre-floor).
	var data: Dictionary = {"atk": 40, "spd": 30, "type": "humanoid", "hp": 100}
	seed(99)
	var weak: Dictionary = BattleActions.execute_enemy_attack(
		_party_with({"def": 5, "spd": 1}), _make_synthetic_enemy(data), 0, 1.0
	)
	seed(99)
	var strong: Dictionary = BattleActions.execute_enemy_attack(
		_party_with({"def": 5, "spd": 1}), _make_synthetic_enemy(data), 0, 3.0
	)
	assert_true(
		weak.get("hit", false) and strong.get("hit", false), "both hits land at SPD 30 vs 1"
	)
	assert_gt(
		int(strong.get("damage", 0)),
		int(weak.get("damage", 0)),
		"ability_mult 3.0 deals more than 1.0 under the same RNG"
	)


func test_multihit_aggregates_damage_and_counts_hits() -> void:
	# hits=3 against a near-guaranteed-hit target lands multiple times and sums
	# more damage than a single hit. Enemy SPD >> target SPD keeps misses rare.
	seed(7)
	var data: Dictionary = {"atk": 40, "spd": 50, "type": "humanoid", "hp": 100}
	# 5000 HP so the member survives all three hits (each ~250) and we can count them.
	var r: Dictionary = BattleActions.execute_enemy_physical_ability(
		_party_with({"def": 5, "spd": 1}, 5000), _make_synthetic_enemy(data), 0, 1.0, 3
	)
	assert_between(int(r.get("hits_landed", 0)), 1, 3, "1-3 of three hits land")
	assert_gt(int(r.get("hits_landed", 0)), 1, "with SPD 50 vs 1, most of 3 hits connect")
	assert_true(r.get("hit", false), "aggregate reports a hit when any sub-hit lands")


func test_single_hit_default_is_one_hit() -> void:
	seed(7)
	var data: Dictionary = {"atk": 40, "spd": 50, "type": "humanoid", "hp": 100}
	var r: Dictionary = BattleActions.execute_enemy_physical_ability(
		_party_with({"def": 5, "spd": 1}, 5000), _make_synthetic_enemy(data), 0
	)
	assert_eq(int(r.get("hits_landed", 0)), 1, "default hits=1 lands exactly once")


# --- AI ability-metadata propagation (GAP-024) ---


func test_ai_ability_action_carries_full_metadata() -> void:
	seed(123)
	var enemy_data: Dictionary = {
		"abilities":
		[
			{
				"id": "venom_spit",
				"name": "Venom Spit",
				"type": "attack",
				"status": "poison",
				"status_rate": 70,
				"target": "single",
				"ability_mult": 1.0,
				"hits": 1,
			}
		]
	}
	var pm: Array = [{"is_alive": true, "row": "front"}, null, null, null]
	var pr: Array = ["front", "front", "front", "front"]
	var found: bool = false
	for _i: int in range(200):
		var a: Dictionary = BattleAI.select_action(enemy_data, pm, pr)
		if a.get("type", "") == "ability":
			found = true
			assert_eq(a.get("ability_id", ""), "venom_spit", "carries the ability id")
			assert_eq(a.get("status", ""), "poison", "carries the inflicted status")
			assert_eq(int(a.get("status_rate", 0)), 70, "carries the status base-rate")
			assert_eq(a.get("atk_type", ""), "attack", "carries the resolution type")
			assert_eq(a.get("target", ""), "single", "carries the target shape")
			assert_gte(int(a.get("target_slot", -1)), 0, "single-target picks a living slot")
			break
	assert_true(found, "the 20% branch yields an ability action within 200 rolls")


func test_ai_without_abilities_never_returns_ability() -> void:
	# The fall-through fix: a chosen-but-empty ability list defends, never
	# returns a malformed 'ability' action.
	seed(1)
	var enemy_data: Dictionary = {"abilities": []}
	var pm: Array = [{"is_alive": true, "row": "front"}, null, null, null]
	var pr: Array = ["front", "front", "front", "front"]
	for _i: int in range(300):
		var a: Dictionary = BattleAI.select_action(enemy_data, pm, pr)
		assert_ne(a.get("type", ""), "ability", "no abilities -> never an ability action")


# --- Enemy stat buffs (GAP-024) ---


func test_enemy_buff_scales_get_stats() -> void:
	# Pack Howl = +30% ATK (Rallying Cry analog, magic.md:834).
	var enemy: Enemy = _make_synthetic_enemy({"atk": 20, "type": "beast", "hp": 100})
	assert_eq(int(enemy.get_stats().get("atk", 0)), 20, "base ATK before buff")
	enemy.apply_buff("atk", 1.30, 5)
	assert_eq(int(enemy.get_stats().get("atk", 0)), 26, "20 x 1.30 = 26 after Pack Howl")


func test_enemy_buff_refreshes_not_stacks() -> void:
	var enemy: Enemy = _make_synthetic_enemy({"atk": 20, "type": "beast", "hp": 100})
	enemy.apply_buff("atk", 1.30, 5)
	enemy.apply_buff("atk", 1.30, 5)
	assert_eq(int(enemy.get_stats().get("atk", 0)), 26, "same-stat buff refreshes, not 1.69x stack")


func test_enemy_buff_expires_after_duration() -> void:
	var enemy: Enemy = _make_synthetic_enemy({"atk": 20, "type": "beast", "hp": 100})
	enemy.apply_buff("atk", 1.30, 1)
	enemy.tick_buffs()
	assert_eq(int(enemy.get_stats().get("atk", 0)), 20, "buff gone after its 1-turn duration")


# --- AoE-on-death / Shard Burst (GAP-024) ---


func test_aoe_on_death_ability_lookup() -> void:
	var enemy: Enemy = _make_synthetic_enemy(
		{
			"mag": 20,
			"type": "elemental",
			"hp": 1,
			"abilities":
			[
				{"id": "fang", "type": "attack"},
				{"id": "shard_burst", "aoe_on_death": true, "type": "magic", "spell_power": 9},
			],
		}
	)
	var ab: Dictionary = BattleActions.enemy_aoe_on_death_ability(enemy)
	assert_eq(ab.get("id", ""), "shard_burst", "finds the aoe_on_death ability among the kit")


func test_aoe_on_death_has_none_returns_empty() -> void:
	var enemy: Enemy = _make_synthetic_enemy(
		{"mag": 20, "type": "beast", "hp": 1, "abilities": [{"id": "bite", "type": "attack"}]}
	)
	assert_true(
		BattleActions.enemy_aoe_on_death_ability(enemy).is_empty(),
		"an enemy without an aoe_on_death ability yields {}"
	)


func test_shard_burst_damages_whole_living_party() -> void:
	seed(31)
	# Two living members; a high-MAG crystal bursting at spell_power 9 hits both.
	var state: Node = _party_members(2, {"mdef": 0, "spd": 1, "mag": 10}, 500)
	var crystal: Enemy = _make_synthetic_enemy(
		{
			"mag": 40,
			"type": "elemental",
			"hp": 1,
			"abilities": [{"id": "shard_burst", "aoe_on_death": true, "spell_power": 9}],
		}
	)
	var ability: Dictionary = BattleActions.enemy_aoe_on_death_ability(crystal)
	var results: Array = BattleActions.execute_aoe_on_death(state, crystal, ability)
	assert_eq(results.size(), 2, "burst resolves against both living members")
	var total_lost: int = 0
	for i: int in range(2):
		total_lost += 500 - int(state.get_member(i).get("current_hp", 500))
	assert_gt(total_lost, 0, "the party loses HP to Shard Burst")


# --- Integration: enemy-ability resolution through the real battle scene ---
# These boot battle.tscn and drive the WIRED turn driver directly (bypassing the
# AI's RNG branch) so each mechanic is proven end-to-end and deterministically.


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
	add_child_autofree(battle)
	await wait_frames(3)  # let _ready build enemies + ATB
	return battle


func test_integration_venom_spit_inflicts_poison_on_party() -> void:
	seed(909)
	var battle: Node = await _boot(["marsh_serpent"])
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
	var battle: Node = await _boot(["unstable_crystal"])
	var crystal: Node = battle._enemies[0]
	var hp_before: int = 0
	for i: int in range(4):
		hp_before += int(battle._state.get_member(i).get("current_hp", 0))
	crystal.take_damage(999999)  # death -> Enemy.died -> _on_enemy_died -> Shard Burst
	await wait_frames(1)
	var hp_after: int = 0
	for i: int in range(4):
		hp_after += int(battle._state.get_member(i).get("current_hp", 0))
	assert_lt(hp_after, hp_before, "Shard Burst damages the party when the crystal dies")


func test_integration_pack_howl_buffs_all_wolves() -> void:
	var battle: Node = await _boot(["wayward_wolf", "wayward_wolf"])
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


# --- Round 1 review fixes (GAP-024) ---


func test_ai_excludes_aoe_on_death_from_selection() -> void:
	# Shard Burst (aoe_on_death) is a death trigger only — never a turn action.
	# An enemy whose ONLY ability is aoe_on_death must fall through to defend.
	seed(5)
	var enemy_data: Dictionary = {
		"abilities":
		[
			{
				"id": "shard_burst",
				"aoe_on_death": true,
				"type": "magic",
				"target": "all",
				"spell_power": 9
			}
		]
	}
	var pm: Array = [{"is_alive": true, "row": "front"}, null, null, null]
	var pr: Array = ["front", "front", "front", "front"]
	for _i: int in range(300):
		var a: Dictionary = BattleAI.select_action(enemy_data, pm, pr)
		assert_ne(
			a.get("type", ""), "ability", "aoe_on_death-only enemy never casts it as a turn action"
		)


func test_party_dot_tick_returns_poison_event() -> void:
	# tick_statuses surfaces DoT so the battle layer can emit damage feedback.
	var state: Node = _make_party(0, 0, 100)
	state.apply_status(0, "poison", "turns", UNTIL_CURED)
	var events: Array = state.tick_statuses(0)
	assert_eq(events.size(), 1, "one DoT event for the single poison")
	assert_eq(events[0].get("type", ""), "poison", "event carries the status type")
	assert_eq(int(events[0].get("dmg", 0)), 8, "8% of 100 max HP")


func test_integration_nonelemental_magic_aoe_uses_magic_formula() -> void:
	seed(77)
	var battle: Node = await _boot(["unstable_crystal"])
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
	var battle: Node = await _boot(["wayward_wolf", "wild_boar"])
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
