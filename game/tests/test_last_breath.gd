extends GutTest
## Last Breath grants Reraise in battle (#503): "If the target is Fainted, they
## automatically revive with 30% HP once. Lasts until triggered or battle
## ends." (magic.md § 62 Last Breath), the Status Effect Reference's
## "Auto-revive at 30% HP on Faint", "Until triggered or battle ends".
##
## The fall still happens: "A member who Faints loses every positive status,
## and Confusion and Berserk as well" (the Status Effect Reference's 2026-10-30
## ruling), Reraise among them, so it is spent by the fall it answers. The
## member then stands again as a revival spell stands them, rejoining the ATB
## with an empty gauge.
##
## The cast boots battle.tscn and goes in through BattleUI.command_submitted;
## the fall is a hit through BattleState.take_damage, the seam every blow on
## the party lands through.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")

const PROMPT_TIMEOUT: float = 5.0
## New-game party: Edren in slot 0 casts, Cael in slot 1 is cast on.
const CASTER: int = 0
const TARGET: int = 1
## A blow no new-game member survives.
const FELLING_HIT: int = 99999

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


## A shipped spell, free to cast so the new-game party can afford it.
func _spell(tradition: String, spell_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


## Wait for the caster's prompt, then cast [param spell] on party slot [param target].
func _cast(battle: Node, spell: Dictionary, target: int = TARGET) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": target}
	)
	return true


func _member(battle: Node, slot: int = TARGET) -> Dictionary:
	return battle.get_battle_state().get_member(slot)


## 30% of [param slot]'s max HP, floored: what Last Breath stands it up with.
func _reraise_hp(battle: Node, slot: int = TARGET) -> int:
	return maxi(1, int(_member(battle, slot)["max_hp"]) * 30 / 100)


func test_last_breath_carries_its_magic_md_value() -> void:
	var spell: Dictionary = _spell("spirit", "last_breath")
	assert_eq(int(spell.get("reraise_pct", 0)), 30, "revives at 30% HP")
	assert_eq(spell.get("duration"), null, "lasts until triggered or battle ends")


func test_a_member_under_last_breath_who_falls_stands_again_at_30_percent() -> void:
	var battle: Node = _boot()
	if not await _cast(battle, _spell("spirit", "last_breath")):
		return
	battle.get_battle_state().take_damage(TARGET, FELLING_HIT)
	var m: Dictionary = _member(battle)
	assert_true(m.get("is_alive", false), "the member stands again")
	assert_eq(int(m.get("current_hp", 0)), _reraise_hp(battle), "at 30% of max HP")


func test_last_breath_lifts_a_member_once() -> void:
	var battle: Node = _boot()
	if not await _cast(battle, _spell("spirit", "last_breath")):
		return
	var state: Node = battle.get_battle_state()
	state.take_damage(TARGET, FELLING_HIT)
	assert_true(_member(battle).get("is_alive", false), "precondition: the first fall is undone")
	state.take_damage(TARGET, FELLING_HIT)
	assert_false(_member(battle).get("is_alive", true), "the second fall stands")


func test_last_breath_outlasts_the_bearer_s_turns() -> void:
	var battle: Node = _boot()
	if not await _cast(battle, _spell("spirit", "last_breath")):
		return
	var state: Node = battle.get_battle_state()
	for _turn: int in range(10):
		state.begin_turn(TARGET)
		state.tick_statuses(TARGET)
	state.take_damage(TARGET, FELLING_HIT)
	assert_true(_member(battle).get("is_alive", false), "ten turns on, it still answers a fall")


func test_the_fall_still_ends_the_member_s_other_positive_effects() -> void:
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	var def_before: int = state.get_effective_stat(TARGET, "def")
	if not await _cast(battle, _spell("spirit", "ironhide")):
		return
	assert_gt(state.get_effective_stat(TARGET, "def"), def_before, "precondition: Ironhide is on")
	if not await _cast(battle, _spell("spirit", "last_breath")):
		return
	state.take_damage(TARGET, FELLING_HIT)
	assert_true(_member(battle).get("is_alive", false), "precondition: Last Breath lifted them")
	assert_eq(state.get_effective_stat(TARGET, "def"), def_before, "Ironhide fell with them")


func test_a_member_lifted_by_last_breath_rejoins_the_atb() -> void:
	var battle: Node = _boot()
	if not await _cast(battle, _spell("spirit", "last_breath")):
		return
	battle.get_battle_state().take_damage(TARGET, FELLING_HIT)
	var atb: Node = battle.get_atb()
	var id: String = "party_%d" % TARGET
	assert_eq(atb.get_gauge(id), 0, "they come back with an empty gauge")
	atb.set_gauge(id, ATBSystem.GAUGE_MAX)
	assert_eq(atb.get_gauge(id), ATBSystem.GAUGE_MAX, "and are on the ATB to fill it")


func test_the_last_member_standing_under_last_breath_does_not_lose_the_battle() -> void:
	var battle: Node = _boot()
	if not await _cast(battle, _spell("spirit", "last_breath")):
		return
	var state: Node = battle.get_battle_state()
	for slot: int in range(4):
		if slot != TARGET:
			state.take_damage(slot, FELLING_HIT)
	state.take_damage(TARGET, FELLING_HIT)
	assert_false(state.is_party_wiped(), "the party is not wiped")


func test_last_breath_can_be_cast_from_the_magic_menu() -> void:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	m.show_commands({"character_id": "torren", "level": 40}, false, {"current_mp": 999})
	m._cursor = 1  # Magic (Attack, Magic, Ability, Item, Defend, Flee)
	m._confirm_command()
	var entry: Dictionary = {}
	for item: Dictionary in m._submenu_items:
		if item.get("command", {}).get("spell", {}).get("id", "") == "last_breath":
			entry = item
	assert_false(entry.is_empty(), "precondition: Torren knows Last Breath")
	assert_true(entry.get("enabled", false), "Last Breath is offered")
