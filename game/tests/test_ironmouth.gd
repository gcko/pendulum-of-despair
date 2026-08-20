extends GutTest
## Tests for Ironmouth Docks escape sequence.

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")


func before_each() -> void:
	TestHelpers.reset_game_state()
	PartyState.initialize_new_game()


func after_each() -> void:
	TestHelpers.reset_game_state()


## Surviving the ambush is what puts Lira and Sable in the party, and
## progression.md's Join Rule fixes the level they arrive at:
## `max(1, floor(party_average_level) - 1)` — one rung *under* the party, never
## level 1. Walking onto a map with the flag set is the real path
## (exploration.gd `_ready` -> ExplorationPartyJoins.check_join_flags), so the
## test drives that rather than calling add_member itself; a hand-written
## add_member would pin PartyState's storage and nothing about the join level.
## The flag gating itself is pinned against ironmouth_docks.tscn's own trigger
## metadata in test_opening_sequence.gd.
func test_ambush_survivors_join_one_level_under_the_party() -> void:
	for member: Dictionary in PartyState.members:
		member["level"] = 8
	EventFlags.set_flag("carradan_ambush_survived", true)
	GameManager.transition_data = {}
	var exploration: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exploration)

	assert_true(PartyState.has_member("lira"), "Lira joins on the ambush flag")
	assert_true(PartyState.has_member("sable"), "Sable joins on the ambush flag")
	# Edren and Cael are both level 8, so Lira is max(1, floor(8) - 1) = 7.
	assert_eq(
		int(PartyState.get_member("lira").get("level", 0)),
		7,
		"Lira joins one under the level-8 party, not at level 1",
	)
	# The average is recomputed for each joiner in turn, so Sable is measured
	# against [8, 8, 7]: max(1, floor(7.66) - 1) = 6. Whether two simultaneous
	# joiners should instead share the pre-ambush average is tracked in #438.
	assert_eq(
		int(PartyState.get_member("sable").get("level", 0)),
		6,
		"Sable joins one under the party Lira just widened, not at level 1",
	)


func test_compact_patrol_loads_from_data() -> void:
	var enemies: Dictionary = DataManager.load_json("res://data/enemies/act_i.json")
	var found: bool = false
	for enemy: Dictionary in enemies.get("enemies", []):
		if enemy.get("id", "") == "compact_patrol":
			found = true
			assert_eq(enemy.get("hp", 0), 180, "Compact Patrol HP should be 180")
			assert_eq(enemy.get("atk", 0), 16, "Compact Patrol ATK should be 16")
			assert_eq(enemy.get("exp", 0), 18, "Compact Patrol EXP should be 18")
			break
	assert_true(found, "compact_patrol should exist in act_i.json")


func test_compact_scout_loads_from_data() -> void:
	var enemies: Dictionary = DataManager.load_json("res://data/enemies/act_i.json")
	var found: bool = false
	for enemy: Dictionary in enemies.get("enemies", []):
		if enemy.get("id", "") == "compact_scout":
			found = true
			assert_eq(enemy.get("hp", 0), 140, "Compact Scout HP should be 140")
			assert_eq(enemy.get("spd", 0), 14, "Compact Scout SPD should be 14")
			break
	assert_true(found, "compact_scout should exist in act_i.json")


func test_overworld_entry_requires_vaelith_scene_complete() -> void:
	assert_false(
		EventFlags.get_flag("vaelith_scene_complete"),
		"vaelith_scene_complete should not be set initially"
	)
	EventFlags.set_flag("vaelith_scene_complete", true)
	assert_true(
		EventFlags.get_flag("vaelith_scene_complete"),
		"vaelith_scene_complete should gate Ironmouth entry"
	)


func test_ironmouth_not_reenterable_after_escape() -> void:
	EventFlags.set_flag("carradan_ambush_survived", true)
	assert_true(
		EventFlags.get_flag("carradan_ambush_survived"),
		"carradan_ambush_survived should prevent re-entry"
	)


# ── Scene-3 ability kits (#257) ─────────────────────────────────────────


## Until #257 both Scene-3 units shipped an empty kit, so the ambush that
## teaches the player to fight had nothing to fight with. Both carry the
## Soldier / Compact family's Tier-1 damaging move.
func test_scene_3_units_can_actually_attack() -> void:
	for enemy_id: String in ["compact_patrol", "compact_scout"]:
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		add_child_autofree(enemy)
		enemy.initialize(enemy_id, "act_i")
		var abilities: Array = enemy.enemy_data.get("abilities", [])
		assert_gt(abilities.size(), 0, "%s must carry a kit" % enemy_id)
		var ids: Array[String] = []
		for ability: Variant in abilities:
			if ability is Dictionary:
				ids.append(str((ability as Dictionary).get("id", "")))
		assert_has(ids, "sword_strike", "%s carries the Soldier family Sword Strike" % enemy_id)


## Sword Strike is a plain physical strike (ability_mult 1.0), so a Compact
## Patrol swinging it must take HP off a party member.
func test_compact_patrol_sword_strike_damages_a_party_member() -> void:
	seed(4242)
	var state: Node = BattleState.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			0,
			{
				"character_id": "edren",
				"base_stats": {"mag": 10, "mdef": 5, "spd": 1, "hp": 200, "mp": 0},
				"max_hp": 200,
				"current_hp": 200,
			}
		)
	)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.initialize("compact_patrol", "act_i")
	var mult: float = _ability_mult(enemy, "sword_strike")
	assert_eq(mult, 1.0, "Sword Strike is a basic physical (conventions §2.1)")
	var result: Dictionary = BattleActions.execute_enemy_attack(state, enemy, 0, mult)
	assert_true(result.get("hit", false), "SPD 10 vs 1 connects under this seed")
	assert_gt(int(result.get("damage", 0)), 0, "Sword Strike takes HP off the target")
	assert_lt(int(state.get_member(0).get("current_hp", 200)), 200, "the member actually lost HP")


func _ability_mult(enemy: Enemy, ability_id: String) -> float:
	for ability: Variant in enemy.enemy_data.get("abilities", []):
		if ability is Dictionary and (ability as Dictionary).get("id", "") == ability_id:
			return float((ability as Dictionary).get("ability_mult", 1.0))
	fail_test("%s has no ability %s" % [enemy.enemy_id, ability_id])
	return 0.0
