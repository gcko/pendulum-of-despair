extends GutTest
## Selection tests for enemy abilities (GAP-024): what BattleAI.select_action
## returns — the metadata an ability action must carry, the abilities it must
## never choose (an empty kit, a death-trigger), and where each `selector`
## points its target.
##
## Split out of test_enemy_abilities.gd, which mixed selection with
## resolution (#374).

const BattleAI = preload("res://scripts/combat/battle_ai.gd")


func after_each() -> void:
	# Undo any seed() so determinism doesn't leak into later tests.
	randomize()


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


# --- Death triggers are not turn actions (GAP-024 round 1 review) ---


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


# --- Regular-enemy ability selector (GAP-024 follow-up #249) ---


func test_ability_selector_back_targets_back_row() -> void:
	seed(123)
	var enemy_data: Dictionary = {
		"abilities":
		[
			{
				"id": "lunge",
				"name": "Lunge",
				"type": "attack",
				"target": "single",
				"selector": "back",
				"ability_mult": 1.0,
			}
		]
	}
	var pm: Array = [
		{"is_alive": true, "row": "front"}, {"is_alive": true, "row": "back"}, null, null
	]
	var pr: Array = ["front", "back", "front", "front"]
	var found: bool = false
	for _i: int in range(200):
		var a: Dictionary = BattleAI.select_action(enemy_data, pm, pr)
		if a.get("type", "") == "ability":
			found = true
			assert_eq(int(a.get("target_slot", -1)), 1, "back selector targets the back-row member")
			break
	assert_true(found, "the 20% ability branch fired within 200 rolls")


func test_ability_selector_random_targets_a_living_member() -> void:
	seed(99)
	var enemy_data: Dictionary = {
		"abilities":
		[
			{
				"id": "drift",
				"name": "Drift",
				"type": "attack",
				"target": "single",
				"selector": "random"
			}
		]
	}
	var pm: Array = [
		{"is_alive": true, "row": "front"}, null, {"is_alive": true, "row": "back"}, null
	]
	var pr: Array = ["front", "front", "back", "front"]
	var living: Array = [0, 2]
	for _i: int in range(200):
		var a: Dictionary = BattleAI.select_action(enemy_data, pm, pr)
		if a.get("type", "") == "ability":
			assert_true(
				int(a.get("target_slot", -1)) in living, "random selector picks a living slot"
			)
			break


func test_ability_selector_back_falls_back_when_no_back_row() -> void:
	seed(5)
	var enemy_data: Dictionary = {
		"abilities":
		[{"id": "lunge", "name": "Lunge", "type": "attack", "target": "single", "selector": "back"}]
	}
	# No back-row member -> "back" selector falls back to a valid front slot, never -1.
	var pm: Array = [
		{"is_alive": true, "row": "front"}, {"is_alive": true, "row": "front"}, null, null
	]
	var pr: Array = ["front", "front", "front", "front"]
	for _i: int in range(200):
		var a: Dictionary = BattleAI.select_action(enemy_data, pm, pr)
		if a.get("type", "") == "ability":
			assert_true(
				int(a.get("target_slot", -1)) in [0, 1], "back fallback picks a living front slot"
			)
			break
