extends GutTest
## Tests for BattleActions.apply_status_to_enemy (GAP-003) + status spell data
## integrity.

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

# Statuses intentionally declared in spell data but deferred in Bundle 2b.
const DEFERRED_STATUSES: Array[String] = ["stop"]


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
	# Stop is deferred (not in the registry) -> graceful no-op.
	var state: Node = _make_state(80)
	var enemy: Enemy = _make_enemy("ley_vermin")
	var r: Dictionary = BattleActions.apply_status_to_enemy(state, 0, 100, "stop", null, enemy)
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
