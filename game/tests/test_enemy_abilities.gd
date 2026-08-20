extends GutTest
## Resolution tests for enemy abilities (GAP-024): enemy->party offensive
## status infliction, party-side DoT ticking, the ability_mult power knob,
## multi-hit, stat buffs, AoE-on-death, and the Act-I ability data those
## paths read. Every numeric constant traces to
## docs/story/bestiary/enemy-ability-conventions.md and the canon it cites
## (magic.md / combat-formulas.md).
##
## Which ability the AI picks is test_enemy_ability_selection.gd; the same
## mechanics driven through battle.tscn are
## test_enemy_abilities_integration.gd (#374).

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
## Poison: 8% max HP/turn, until cured (magic.md § Status Effect Reference > 'Poison').
## UNTIL_CURED sentinel = -1.
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
	# 'stop' is deferred (not in the registry) -> graceful no-op, never inflicted.
	var state: Node = _make_party(0, 0)
	var enemy: Enemy = _make_enemy("marsh_serpent")
	var r: Dictionary = BattleActions.execute_enemy_status(state, enemy, 0, 100, "stop", null)
	assert_eq(r.get("type", ""), "no_effect")
	assert_false(state.has_status(0, "stop"))


# --- Party-side damage-over-time (Poison/Burn) ---


func test_poison_ticks_party_member_hp() -> void:
	# Poison = 8% max HP/turn (magic.md § Status Effect Reference > 'Poison').
	# 100 max HP -> 8 per tick, floor 1.
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


# --- Enemy stat buffs (GAP-024) ---


func test_enemy_buff_scales_get_stats() -> void:
	# Pack Howl = +30% ATK (Rallying Cry analog, magic.md § Rallying Cry).
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


# --- DoT events surfaced to the battle layer (GAP-024) ---


func test_party_dot_tick_returns_poison_event() -> void:
	# tick_statuses surfaces DoT so the battle layer can emit damage feedback.
	var state: Node = _make_party(0, 0, 100)
	state.apply_status(0, "poison", "turns", UNTIL_CURED)
	var events: Array = state.tick_statuses(0)
	assert_eq(events.size(), 1, "one DoT event for the single poison")
	assert_eq(events[0].get("type", ""), "poison", "event carries the status type")
	assert_eq(int(events[0].get("dmg", 0)), 8, "8% of 100 max HP")


# --- Act-I ability data integrity (GAP-024 follow-up #249) ---


func test_act_i_ability_data_is_well_formed() -> void:
	var f: FileAccess = FileAccess.open("res://data/enemies/act_i.json", FileAccess.READ)
	assert_not_null(f, "act_i.json opens")
	var data: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	var valid_types: Array = ["attack", "magic", "buff"]
	var valid_stats: Array = ["atk", "def", "mag", "mdef", "spd"]
	var valid_selectors: Array = ["", "back", "random", "lowest_hp", "highest_threat"]
	var valid_elements: Array = ["", "flame", "frost", "storm", "earth", "ley", "spirit", "void"]
	var checked: int = 0
	for enemy: Dictionary in data.get("enemies", []):
		for ab: Dictionary in enemy.get("abilities", []):
			var eid: String = enemy.get("id", "?")
			var aid: String = ab.get("id", "?")
			assert_true(
				ab.get("type", "attack") in valid_types, "%s/%s has a valid type" % [eid, aid]
			)
			var st: String = ab.get("status", "")
			if not st.is_empty():
				assert_true(
					StatusEffects.is_known(st), "%s/%s status '%s' is known" % [eid, aid, st]
				)
			assert_true(
				ab.get("selector", "") in valid_selectors, "%s/%s selector valid" % [eid, aid]
			)
			# A typo'd element silently degrades to neutral (enemy.get_element_multiplier
			# returns 1.0 for unknown), so validate it explicitly.
			assert_true(
				ab.get("element", "") in valid_elements,
				"%s/%s element '%s' is canonical" % [eid, aid, ab.get("element", "")]
			)
			# Magic abilities must carry real power (spell_power 0 -> ~1 floor damage).
			if ab.get("type", "") == "magic":
				assert_gt(
					int(ab.get("spell_power", 0)), 0, "%s/%s magic has spell_power" % [eid, aid]
				)
			var bf: Dictionary = ab.get("buff", {})
			if not bf.is_empty():
				assert_true(bf.get("stat", "") in valid_stats, "%s/%s buff stat valid" % [eid, aid])
			checked += 1
	assert_gt(checked, 20, "covered the populated Act-I ability set")


# --- The Flickering's Shade-family kit (#257) ---


func _ability(enemy: Enemy, ability_id: String) -> Dictionary:
	for entry: Variant in enemy.enemy_data.get("abilities", []):
		if entry is Dictionary and (entry as Dictionary).get("id", "") == ability_id:
			return entry as Dictionary
	fail_test("%s has no ability %s" % [enemy.enemy_id, ability_id])
	return {}


## Darkness delivers Blind through the same two-stage roll every other enemy
## status uses. Blind's -50% accuracy effect is still deferred (#246), but the
## status must actually land on the party member.
func test_the_flickering_darkness_blinds_a_party_member() -> void:
	seed(2468)
	var enemy: Enemy = _make_enemy("the_flickering")
	var darkness: Dictionary = _ability(enemy, "darkness")
	assert_eq(darkness.get("status", ""), "blind", "Darkness delivers Blind")
	var rate: int = int(darkness.get("status_rate", 0))
	assert_eq(rate, 70, "offensive status rate 70 (conventions §2.5)")
	var landed: bool = false
	for _i: int in range(30):
		var state: Node = _make_party(0, 0)
		var r: Dictionary = BattleActions.execute_enemy_status(
			state, enemy, 0, rate, darkness.get("status", ""), darkness.get("status_duration")
		)
		if r.get("inflicted", false):
			landed = true
			assert_true(state.has_status(0, "blind"), "the member actually carries Blind")
			break
	assert_true(landed, "a rate-70 Blind lands within 30 attempts against MDEF/SPD 0")


## Blind's canonical duration is 4 turns (magic.md § Status Effect Reference),
## resolved by StatusEffects rather than an override in the ability data.
func test_darkness_uses_the_canonical_blind_duration() -> void:
	var enemy: Enemy = _make_enemy("the_flickering")
	var darkness: Dictionary = _ability(enemy, "darkness")
	assert_eq(darkness.get("status_duration"), null, "no duration override in the data")
	var state: Node = _make_party(0, 0)
	state.apply_status(0, "blind", "turns", StatusEffects.resolve_duration("blind", null))
	for _i: int in range(3):
		state.tick_statuses(0)
	assert_true(state.has_status(0, "blind"), "Blind survives 3 of its 4 turns")
	state.tick_statuses(0)
	assert_false(state.has_status(0, "blind"), "Blind expires on its 4th turn")


## Shadow Touch is the Shade family's Tier-1 base move: MAG-based, and The
## Flickering's MAG (14) must make it hurt more than Mine Shade's (12) does.
func test_shadow_touch_scales_with_the_casters_magic() -> void:
	var flickering: Enemy = _make_enemy("the_flickering")
	var shade: Enemy = _make_enemy("mine_shade")
	var power: int = int(_ability(flickering, "shadow_touch").get("spell_power", 0))
	assert_eq(power, 14, "Tier-1 single-target spell power (conventions §2.2)")
	seed(31337)
	var strong: Dictionary = BattleActions.execute_enemy_magic(
		_party_with({"def": 5, "mdef": 5, "spd": 1}, 500), flickering, 0, "", power
	)
	seed(31337)
	var weak: Dictionary = BattleActions.execute_enemy_magic(
		_party_with({"def": 5, "mdef": 5, "spd": 1}, 500), shade, 0, "", power
	)
	assert_gt(int(strong.get("damage", 0)), 0, "Shadow Touch deals damage")
	assert_gt(
		int(strong.get("damage", 0)),
		int(weak.get("damage", 0)),
		"The Flickering's MAG 14 out-damages Mine Shade's MAG 12 on the same move",
	)
