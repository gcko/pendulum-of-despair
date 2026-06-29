extends GutTest
## Integration "playtest" of the combat slice (Bundle 2): boots a real battle
## scene and drives player casts through battle_manager — status infliction,
## type/boss immunity, ATB freeze, and enemy type-trait magic.

const BATTLE := preload("res://scenes/core/battle.tscn")

var _log: Array[String] = []


func _cast(battle: Node, spell: Dictionary, target: int) -> void:
	battle._atb.set_gauge("party_0", 16000)
	await wait_frames(2)  # _process emits turn_ready -> _awaiting_input_for
	battle._on_ui_command({"type": "magic", "spell": spell, "target": target})
	await wait_frames(2)


func test_combat_slice_playtest() -> void:
	seed(7)
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin", "restless_dead"],  # beast, undead
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child_autofree(battle)
	await wait_frames(3)

	battle.message.connect(func(t: String) -> void: _log.append("MSG: " + t))
	battle.damage_dealt.connect(
		func(tid: String, amt: int, dt: String) -> void:
			_log.append("HIT: %s %d (%s)" % [tid, amt, dt])
	)

	var e0: Node = battle._enemies[0]  # ley_vermin (beast)
	var e1: Node = battle._enemies[1]  # restless_dead (undead)
	gut.p("\n=== Combat slice playtest ===")
	gut.p("enemies: 0=%s(%s) 1=%s(%s)" % [e0.enemy_id, e0.get_type(), e1.enemy_id, e1.get_type()])

	var poison := {
		"name": "Vilethorn",
		"category": "status",
		"status": "poison",
		"hit_rate": 100,
		"mp_cost": 0,
		"power": null,
		"target": "single_enemy",
		"element": "earth",
	}
	# 1) Poison the beast. Observation only: success is a two-stage roll scaled
	# by caster MAG (Edren MAG 6 vs MDEF 5 ~= 54%), so this legitimately may miss
	# — that the roll CAN fail with a low-MAG caster is the intended design.
	await _cast(battle, poison, 0)
	gut.p(
		(
			"Vilethorn -> ley_vermin: has_poison=%s (two-stage roll, low-MAG caster)"
			% e0.has_status("poison")
		)
	)

	# 2) Poison the undead — type immunity, no effect.
	await _cast(battle, poison, 1)
	gut.p("Vilethorn -> restless_dead(undead): has_poison=%s" % e1.has_status("poison"))
	assert_false(e1.has_status("poison"), "undead is immune to poison")

	# 3) Sleep the beast — inflict + freeze its ATB (per-frame resync).
	# The two-stage roll with a low-MAG caster (Edren MAG 6 vs MDEF 5 ~= 54%) can
	# miss any single attempt, and the exact RNG draw count through the live battle
	# varies by environment — so retry until it lands (mirrors test_battle_actions'
	# "lands within N attempts" pattern). Cure poison first so DoT ticks can't kill
	# the beast mid-retry; sleep is the only thing under test here.
	e0.remove_status("poison")
	e0.current_hp = e0.enemy_data.get("hp", 1)
	var sleep := poison.duplicate()
	sleep["name"] = "Slumber Mote"
	sleep["status"] = "sleep"
	for _i: int in range(12):
		if e0.has_status("sleep"):
			break
		await _cast(battle, sleep, 0)
	await wait_frames(2)
	var frozen: bool = battle._atb._combatants["enemy_0"]["frozen"]
	gut.p(
		"Slumber Mote -> ley_vermin: has_sleep=%s atb_frozen=%s" % [e0.has_status("sleep"), frozen]
	)
	assert_true(e0.has_status("sleep"), "sleep inflicted within retries")
	assert_true(frozen, "sleep freezes the enemy ATB gauge")

	# 4) Spirit-element magic on the undead — type bonus 1.5x stacks (README:67).
	var hp_before: int = e1.current_hp
	var bolt := {
		"name": "Spirit Bolt",
		"category": "damage",
		"power": 40,
		"mp_cost": 0,
		"target": "single_enemy",
		"element": "spirit",
	}
	await _cast(battle, bolt, 1)
	var dealt: int = hp_before - e1.current_hp
	gut.p("Spirit Bolt -> restless_dead: dealt %d (hp %d->%d)" % [dealt, hp_before, e1.current_hp])
	assert_gt(dealt, 0, "spirit-element magic damages the undead")

	gut.p("--- battle log ---")
	for line: String in _log:
		gut.p("  " + line)
	gut.p("=== end playtest ===")
