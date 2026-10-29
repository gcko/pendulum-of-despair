extends GutTest
## Quickstep hastes its target (#246 slice 2): magic.md § 58 Quickstep,
## "Increases ATB fill speed by 50% for 5 turns", and combat-formulas.md
## § Fill Rate Modifiers, "Haste (Quickstep) × 1.5, 5 turns". Before this the
## Magic command sent every single-ally spell down the heal path, so Quickstep
## restored 0 HP and changed nothing else.
##
## The cast boots battle.tscn and goes in through BattleUI.command_submitted,
## the seam the menu feeds, so the announcement is the one the battle makes.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

const PROMPT_TIMEOUT: float = 5.0
const CASTER: int = 0
const TARGET: int = 1

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


func _boot() -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


func _await_prompt(battle: Node) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge("party_%d" % CASTER, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not "party_%d" % CASTER in prompted:
		fail_test("the battle never asked the caster for a command (asked: %s)" % str(prompted))
		return false
	return true


## The shipped Quickstep, free to cast so the new-game party can afford it.
func _quickstep() -> Dictionary:
	for entry: Variant in DataManager.load_spells("ley_line"):
		if String((entry as Dictionary).get("id", "")) == "quickstep":
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("quickstep is missing from ley_line.json")
	return {}


## Cast Quickstep from the caster onto the target and return the battle.
func _cast_quickstep(said: Array[String]) -> Node:
	var battle: Node = _boot()
	battle.message.connect(func(text: String) -> void: said.append(text))
	if not await _await_prompt(battle):
		return null
	var ui: CanvasLayer = battle.get_node("BattleUI")
	ui.command_submitted.emit({"type": "magic", "spell": _quickstep(), "target": TARGET})
	return battle


func _haste_entry(state: Node) -> Dictionary:
	for s: Dictionary in state.get_member(TARGET).get("active_statuses", []):
		if s.get("name", "") == "haste":
			return s
	return {}


func test_quickstep_hastes_its_target_for_five_turns() -> void:
	var said: Array[String] = []
	var battle: Node = await _cast_quickstep(said)
	if battle == null:
		return
	var haste: Dictionary = _haste_entry(battle.get_battle_state())
	assert_false(haste.is_empty(), "the target is Hastened")
	assert_eq(int(haste.get("remaining_turns", 0)), 5, "for Quickstep's 5 turns")


func test_a_hastened_member_is_announced() -> void:
	# battle-dialogue.md § Status Effect Notifications: "[Character] is Hastened!"
	var said: Array[String] = []
	var battle: Node = await _cast_quickstep(said)
	if battle == null:
		return
	var name: String = battle.get_battle_state().get_member(TARGET)["character_data"]["name"]
	assert_has(
		said, "%s is Hastened!" % name, "the player reads the canonical line: %s" % str(said)
	)


func test_a_hastened_member_s_gauge_fills_half_again_as_fast() -> void:
	var said: Array[String] = []
	var battle: Node = await _cast_quickstep(said)
	if battle == null:
		return
	var statuses: Array = battle.get_battle_state().get_member(TARGET)["active_statuses"]
	var mods: Array = StatusEffects.atb_state(statuses)["mods"]
	assert_eq(mods, [1.5], "Haste is a x1.5 fill modifier")
	var atb: Node = battle.get_atb()
	assert_eq(
		atb.calculate_fill_rate(100, 3, mods),
		int(atb.calculate_fill_rate(100, 3, []) * 1.5),
		"so the gauge fills at one and a half times the rate"
	)


func test_haste_wears_off_after_five_of_the_target_s_turns() -> void:
	var said: Array[String] = []
	var battle: Node = await _cast_quickstep(said)
	if battle == null:
		return
	var state: Node = battle.get_battle_state()
	for turn: int in range(4):
		state.tick_statuses(TARGET)
	assert_true(state.has_status(TARGET, "haste"), "still Hastened after four turns")
	state.tick_statuses(TARGET)
	assert_false(state.has_status(TARGET, "haste"), "and gone after the fifth")
