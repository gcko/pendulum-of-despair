extends GutTest
## The Magic command's effect on an enemy, driven through the real battle scene:
## what the player is told when a status spell lands (#439).
##
## Like test_combat_playtest.gd, these boot battle.tscn and go in through the
## seam the battle UI uses — wait for turn_ready, then emit
## BattleUI.command_submitted — so what is proven is the path a player drives.
##
## Every target here has its MDEF and SPD zeroed. That pins the rolls the cast
## makes to the spell's own numbers: a 0-SPD target never evades and is hit at
## 90% or better, and a 0-MDEF target meets a status roll at its full base rate
## with no Magic Evasion (combat-formulas.md § Status Effect Accuracy).

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

## Real time allowed for the battle to answer a full ATB gauge with a prompt.
const PROMPT_TIMEOUT: float = 5.0

var _booted: Node = null


func after_each() -> void:
	# A live battle keeps _process-ing, so free it here rather than let it run
	# on into the next test, and leave no seed or party behind (#422).
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	randomize()


func _boot(encounter: Array) -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


## Wait until the battle asks [param cid] for a command (see test_combat_playtest).
func _await_prompt(battle: Node, cid: String) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge(cid, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not cid in prompted:
		fail_test("the battle never asked %s for a command (asked: %s)" % [cid, str(prompted)])
		return false
	return true


func _submit(battle: Node, command: Dictionary) -> void:
	var ui: CanvasLayer = battle.get_node("BattleUI")
	ui.command_submitted.emit(command)


## Zero the enemy's MDEF and SPD (see the file header) and give it [param hp].
## The data is copied first so the cached enemy table is left untouched.
func _pin_target(enemy: Node, hp: int) -> void:
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["mdef"] = 0
	data["spd"] = 0
	data["hp"] = hp
	enemy.enemy_data = data
	enemy.current_hp = hp


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


func _vilethorn() -> Dictionary:
	return {
		"name": "Vilethorn",
		"category": "status",
		"status": "poison",
		"hit_rate": 100,
		"mp_cost": 0,
		"power": null,
		"target": "single_enemy",
		"element": "earth",
	}


# ── #439: status spells announce through the registry ───────────────────


func test_a_status_spell_landing_on_an_enemy_reads_the_canonical_line() -> void:
	# battle-dialogue.md § Status Effect Notifications: "[Character] is Poisoned!"
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_target(vermin, 500)
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle, "party_0"):
		return

	_submit(battle, {"type": "magic", "spell": _vilethorn(), "target": 0})

	assert_true(vermin.has_status("poison"), "precondition: the poison landed")
	var expected: String = "%s is Poisoned!" % vermin.get_display_name()
	assert_has(said, expected, "the player reads the canonical line: %s" % str(said))
	for line: String in said:
		assert_false(
			line.contains("afflicted with poison"), "no raw status id reaches the player: %s" % line
		)
