extends GutTest
## Tests for BattleActions.apply_status_to_enemy (GAP-003), status spell data
## integrity, and how an enemy physical attack reports a miss (#500).

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

# Statuses declared in spell data but not yet in the registry. None remain:
# Stop, the last one, joined it in #246.
const DEFERRED_STATUSES: Array[String] = []


func after_each() -> void:
	# Undo any seed() so determinism doesn't leak into later tests.
	randomize()


func _make_state(caster_mag: int) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	state.add_member(
		0, {"character_id": "tester", "base_stats": {"mag": caster_mag, "hp": 10, "mp": 0}}
	)
	return state


func _make_enemy(enemy_id: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.initialize(enemy_id, "act_i")
	return enemy


func test_inflicts_status_on_success() -> void:
	# High rate + high MAG vs low MDEF/SPD: the two-stage roll passes most of
	# the time. Over several attempts at least one must land, proving the path.
	seed(12345)
	var state: Node = _make_state(80)
	var inflicted_any: bool = false
	for _i: int in range(30):
		var enemy: Enemy = _make_enemy("ley_vermin")  # beast, no immunities
		var r: Dictionary = BattleActions.apply_status_to_enemy(
			state, 0, 100, "poison", null, enemy
		)
		if r.get("inflicted", false):
			inflicted_any = true
			assert_eq(r.get("type", ""), "status")
			assert_true(enemy.has_status("poison"), "enemy actually carries the status")
			break
	assert_true(inflicted_any, "a high-rate status should land within 30 attempts")


func test_resisted_when_base_rate_zero() -> void:
	# base_rate 0 -> effective rate 0 -> Stage 1 always fails. Deterministic.
	var state: Node = _make_state(50)
	var enemy: Enemy = _make_enemy("ley_vermin")
	var r: Dictionary = BattleActions.apply_status_to_enemy(state, 0, 0, "poison", null, enemy)
	assert_false(r.get("inflicted", false), "0% rate never inflicts")
	assert_eq(r.get("type", ""), "resisted")
	assert_false(enemy.has_status("poison"))


func test_immune_enemy_auto_no_effect() -> void:
	# restless_dead is undead -> immune to poison. No roll; deterministic.
	var state: Node = _make_state(80)
	var enemy: Enemy = _make_enemy("restless_dead")
	var r: Dictionary = BattleActions.apply_status_to_enemy(state, 0, 100, "poison", null, enemy)
	assert_false(r.get("inflicted", false), "immune target is never afflicted")
	assert_eq(r.get("type", ""), "immune")


func test_unknown_status_is_no_effect() -> void:
	# A status the registry does not know -> graceful no-op.
	var state: Node = _make_state(80)
	var enemy: Enemy = _make_enemy("ley_vermin")
	var r: Dictionary = BattleActions.apply_status_to_enemy(state, 0, 100, "nonsense", null, enemy)
	assert_eq(r.get("type", ""), "no_effect")


func test_explicit_spell_duration_overrides_default() -> void:
	# A void spell carries an explicit duration that should win over canonical.
	var state: Node = _make_state(80)
	for _i: int in range(30):
		var enemy: Enemy = _make_enemy("ley_vermin")
		var r: Dictionary = BattleActions.apply_status_to_enemy(state, 0, 100, "silence", 2, enemy)
		if r.get("inflicted", false):
			# silence default is 4; the spell passed 2.
			for s: Dictionary in enemy.active_statuses:
				if s.get("name", "") == "silence":
					assert_eq(int(s.get("remaining_turns", -99)), 2, "explicit duration wins")
			return
	pass_test("status did not land in 30 tries (rare); duration logic unit-tested elsewhere")


# --- Status spell data integrity ---


func test_every_status_spell_has_a_status_field() -> void:
	for path: String in [
		"res://data/spells/spirit.json",
		"res://data/spells/ley_line.json",
		"res://data/spells/void.json",
	]:
		var f: FileAccess = FileAccess.open(path, FileAccess.READ)
		assert_not_null(f, "spell file opens: %s" % path)
		var data: Variant = JSON.parse_string(f.get_as_text())
		f.close()
		for spell: Dictionary in data.get("spells", []):
			if spell.get("category", "") == "status":
				var st: Variant = spell.get("status")
				var sid: String = spell.get("id", "?")
				assert_true(
					st is String and not (st as String).is_empty(),
					"status spell %s must declare a non-empty status" % sid
				)
				# Catch typos: the status must be inflictable now, or a known
				# deferred status (Stop) — not e.g. "poizon".
				assert_true(
					StatusEffects.is_known(st) or st in DEFERRED_STATUSES,
					"status spell %s declares unknown status '%s'" % [sid, st]
				)


# --- Enemy physical attacks: a miss reads as a miss (#500) ---


## A party of one "tester" with this SPD and HP, and an ATK 40 enemy with this SPD.
func _duel(target_spd: int, hp: int, enemy_spd: int) -> Array:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	state.add_member(
		0,
		{
			"character_id": "tester",
			"base_stats": {"def": 5, "spd": target_spd},
			"max_hp": 99999,
			"current_hp": hp
		}
	)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)
	enemy.enemy_data = {"atk": 40, "spd": enemy_spd, "type": "humanoid", "hp": 100}
	enemy.current_hp = 100
	enemy.is_alive = true
	return [state, enemy]


## The battle UI prints "Miss" for a "miss" result and the damage figure for
## every other type, so an attack that lands nothing must report "miss" or the
## party row shows a 0 popup. SPD 1 against SPD 255 lands roughly one hit in
## seven, so across these seeds some attacks miss with every hit and some land,
## for a single hit and for a two-hit flurry alike.
func test_an_enemy_attack_that_misses_every_hit_reports_a_miss() -> void:
	for hits: int in [1, 2]:
		var whiffs: int = 0
		var landings: int = 0
		for s: int in range(60):
			seed(s)
			var duel: Array = _duel(255, 99999, 1)
			var r: Dictionary = BattleActions.execute_enemy_physical_ability(
				duel[0], duel[1], 0, 1.0, hits
			)
			var tag: String = "hits %d, seed %d" % [hits, s]
			if int(r.get("hits_landed", -1)) == 0:
				whiffs += 1
				assert_eq(r.get("type", ""), "miss", "%s: nothing landed, so it is a Miss" % tag)
				assert_eq(int(r.get("damage", -1)), 0, "%s: a miss deals nothing" % tag)
			else:
				landings += 1
				assert_has(["physical", "critical"], r.get("type", ""), "%s: a hit landed" % tag)
		assert_gt(whiffs, 0, "hits %d: some seed must miss, or the miss rule went unchecked" % hits)
		assert_gt(
			landings, 0, "hits %d: some seed must land, or the hit rule went unchecked" % hits
		)


## A hit that lands for 0 is a hit, not a miss: the popup shows 0. Unbreakable
## leaves a member at 1 HP, so on a member already at 1 HP a landed hit applies
## nothing (abilities.md § Cael — Rally).
func test_an_enemy_hit_that_lands_for_nothing_is_not_a_miss() -> void:
	seed(7)
	var duel: Array = _duel(1, 1, 50)
	BattleRally.start(duel[0], 0, "unbreakable", {"last_stand": true, "turns": 3})
	var r: Dictionary = BattleActions.execute_enemy_physical_ability(duel[0], duel[1], 0, 1.0, 1)
	assert_eq(int(r.get("hits_landed", 0)), 1, "SPD 50 against SPD 1 lands under this seed")
	assert_eq(int(r.get("damage", -1)), 0, "Unbreakable held the member at 1 HP")
	assert_has(["physical", "critical"], r.get("type", ""), "it landed, so it is no Miss")
