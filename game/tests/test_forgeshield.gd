extends GutTest
## Forgeshield wards one ally against magic (#503): "Absorbs the next instance
## of magical damage directed at the target (up to a threshold of 150 + caster
## MAG). Then shatters." (magic.md § 79 Forgeshield). The threshold is the
## caster's MAG when it is cast. A spell over the threshold spends the shield
## and the rest of it lands; a physical blow and a missed spell leave it up.
##
## The cast boots battle.tscn and goes in through BattleUI.command_submitted.
## The enemy's spells are read through BattleActions.execute_enemy_magic, the
## seam an enemy's magic ability and a death burst resolve through, from one
## RNG seed, so the hit and variance rolls match with and without the shield.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")

const PROMPT_TIMEOUT: float = 5.0
## New-game party: Edren in slot 0 casts, Cael in slot 1 is cast on.
const CASTER: int = 0
const TARGET: int = 1
## An HP pool no probe here can empty.
const DEEP_HP: int = 99999
const SEED: int = 777

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


## Boot a battle whose target is deep in HP and whose enemy has no SPD, so its
## spells land.
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
	for slot: int in [CASTER, TARGET]:
		var m: Dictionary = battle.get_battle_state().get_member(slot)
		m["max_hp"] = DEEP_HP
		m["current_hp"] = DEEP_HP
	var enemy: Node = battle.get_enemies()[0]
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["spd"] = 0
	enemy.enemy_data = data
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


func _forgeshield() -> Dictionary:
	for entry: Variant in DataManager.load_spells("forgewright"):
		if String((entry as Dictionary).get("id", "")) == "forgeshield":
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("forgeshield is missing from forgewright.json")
	return {}


## Wait for the caster's prompt, then cast Forgeshield on party slot [param target].
func _shield(battle: Node, target: int = TARGET) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": _forgeshield(), "target": target}
	)
	return true


## The HP the enemy's power-[param power] spell takes from the target at
## [param mag] MAG and fixed rolls. The target is topped back up after.
func _spell_hit(battle: Node, mag: int, power: int) -> int:
	var enemy: Node = battle.get_enemies()[0]
	enemy.enemy_data["mag"] = mag
	var m: Dictionary = battle.get_battle_state().get_member(TARGET)
	var before: int = int(m["current_hp"])
	seed(SEED)
	var r: Dictionary = BattleActions.execute_enemy_magic(
		battle.get_battle_state(), enemy, TARGET, "", power
	)
	assert_true(r.get("hit", false), "precondition: the enemy's spell lands")
	var lost: int = before - int(m["current_hp"])
	m["current_hp"] = DEEP_HP
	return lost


## The threshold Forgeshield cast now would hold: 150 + the caster's MAG.
func _threshold(battle: Node) -> int:
	return 150 + battle.get_battle_state().get_effective_stat(CASTER, "mag")


func test_forgeshield_carries_its_magic_md_value() -> void:
	var spell: Dictionary = _forgeshield()
	assert_eq(int(spell.get("magic_absorb_base", 0)), 150, "absorbs up to 150 + caster MAG")
	assert_eq(String(spell.get("target", "")), "single_ally", "on one ally")


func test_a_spell_under_the_threshold_is_absorbed_whole() -> void:
	var battle: Node = _boot()
	var plain: int = _spell_hit(battle, 20, 10)
	assert_between(plain, 1, _threshold(battle), "precondition: under the threshold")
	if not await _shield(battle):
		return
	assert_eq(_spell_hit(battle, 20, 10), 0, "the shield absorbs all %d" % plain)


func test_a_spell_over_the_threshold_spends_it_and_the_rest_lands() -> void:
	var battle: Node = _boot()
	var plain: int = _spell_hit(battle, 200, 20)
	var threshold: int = _threshold(battle)
	assert_gt(plain, threshold, "precondition: over the threshold")
	if not await _shield(battle):
		return
	assert_eq(_spell_hit(battle, 200, 20), plain - threshold, "only the excess lands")


func test_the_shield_shatters_after_one_spell() -> void:
	var battle: Node = _boot()
	var plain: int = _spell_hit(battle, 20, 10)
	if not await _shield(battle):
		return
	assert_eq(_spell_hit(battle, 20, 10), 0, "precondition: the first spell is absorbed")
	assert_eq(_spell_hit(battle, 20, 10), plain, "the second lands in full")


func test_a_weaker_recast_leaves_the_stronger_ward_up() -> void:
	# A reading: two wards on one ally keep the stronger, as two stat buffs do
	# (magic.md § Derived Rules > 'Ally spell effects').
	var battle: Node = _boot()
	var plain: int = _spell_hit(battle, 200, 20)
	var threshold: int = _threshold(battle)
	if not await _shield(battle):
		return
	var caster: Dictionary = battle.get_battle_state().get_member(CASTER)
	caster["effective_stats"]["mag"] = 0
	assert_lt(_threshold(battle), threshold, "precondition: the recast is weaker")
	if not await _shield(battle):
		return
	assert_eq(_spell_hit(battle, 200, 20), plain - threshold, "the first ward still holds")


func test_a_physical_blow_leaves_the_shield_up() -> void:
	var battle: Node = _boot()
	if not await _shield(battle):
		return
	var state: Node = battle.get_battle_state()
	var enemy: Node = battle.get_enemies()[0]
	var before: int = int(state.get_member(TARGET)["current_hp"])
	var landed: bool = false
	for _try: int in range(20):  # some blow among twenty lands
		if BattleActions.execute_enemy_attack(state, enemy, TARGET).get("hit", false):
			landed = true
			break
	assert_true(landed, "precondition: a blow landed")
	assert_lt(int(state.get_member(TARGET)["current_hp"]), before, "the blow hurt")
	assert_eq(_spell_hit(battle, 20, 10), 0, "and the shield still took the next spell")


func test_forgeshield_can_be_cast_from_lira_s_magic_menu() -> void:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	m.show_commands({"character_id": "lira", "level": 40}, false, {"current_mp": 999})
	m._cursor = 1  # Magic (Attack, Magic, Ability, Item, Defend, Flee)
	m._confirm_command()
	var entry: Dictionary = {}
	for item: Dictionary in m._submenu_items:
		if item.get("command", {}).get("spell", {}).get("id", "") == "forgeshield":
			entry = item
	assert_false(entry.is_empty(), "precondition: Lira knows Forgeshield")
	assert_true(entry.get("enabled", false), "Forgeshield is offered")


func test_a_missed_spell_leaves_the_shield_up() -> void:
	var battle: Node = _boot()
	if not await _shield(battle):
		return
	var state: Node = battle.get_battle_state()
	var enemy: Node = battle.get_enemies()[0]
	var target: Dictionary = state.get_member(TARGET)
	var spd: int = int(target["effective_stats"].get("spd", 0))
	target["effective_stats"]["spd"] = 999  # a 20% hit roll, then a 50% dodge
	var missed: bool = false
	for rng: int in range(1, 60):
		seed(rng)
		if not BattleActions.execute_enemy_magic(state, enemy, TARGET, "", 10).get("hit", true):
			missed = true
			break
	target["effective_stats"]["spd"] = spd
	assert_true(missed, "precondition: a spell missed")
	assert_eq(_spell_hit(battle, 20, 10), 0, "and the shield still took the next spell")


func test_a_poison_tick_leaves_the_shield_up() -> void:
	var battle: Node = _boot()
	if not await _shield(battle):
		return
	var state: Node = battle.get_battle_state()
	assert_true(state.apply_status(TARGET, "poison", "turns", -1), "precondition: poisoned")
	state.tick_statuses(TARGET)
	assert_lt(int(state.get_member(TARGET)["current_hp"]), DEEP_HP, "the tick hurt")
	state.get_member(TARGET)["current_hp"] = DEEP_HP
	assert_eq(_spell_hit(battle, 20, 10), 0, "and the shield still took the next spell")


## The HP the enemy's power-20 spell at MAG 200 takes from Cael in the back
## row and from Edren in Rampart over him, at fixed rolls: [Cael's, Edren's].
func _rampart_hit(battle: Node) -> Array[int]:
	var state: Node = battle.get_battle_state()
	BattleBulwark.enter_stance(state, CASTER, "rampart", -1)
	state.get_member(TARGET)["row"] = "back"
	var enemy: Node = battle.get_enemies()[0]
	enemy.enemy_data["mag"] = 200
	seed(SEED)
	var r: Dictionary = BattleActions.execute_enemy_magic(state, enemy, TARGET, "", 20)
	assert_true(r.get("hit", false), "precondition: the enemy's spell lands")
	var lost: Array[int] = []
	for slot: int in [TARGET, CASTER]:
		lost.append(DEEP_HP - int(state.get_member(slot)["current_hp"]))
		state.get_member(slot)["current_hp"] = DEEP_HP
	return lost


func test_under_a_stance_the_ward_meets_only_the_bearer_s_share() -> void:
	var battle: Node = _boot()
	var plain: Array[int] = _rampart_hit(battle)
	var threshold: int = _threshold(battle)
	assert_gt(plain[0], threshold, "precondition: Cael's share is over the threshold")
	assert_gt(plain[1], 0, "precondition: Edren's Rampart took a share")
	if not await _shield(battle):
		return
	var warded: Array[int] = _rampart_hit(battle)
	assert_eq(warded[0], plain[0] - threshold, "the ward takes its threshold off Cael's share")
	assert_eq(warded[1], plain[1], "and Edren's share lands in full")


func test_an_area_spell_meets_each_target_s_own_ward() -> void:
	var battle: Node = _boot()
	if not await _shield(battle, TARGET):
		return
	if not await _shield(battle, CASTER):
		return
	var enemy: Node = battle.get_enemies()[0]
	enemy.enemy_data["mag"] = 20
	var action: Dictionary = {
		"type": "ability",
		"id": "x",
		"target": "all",
		"atk_type": "magic",
		"element": "",
		"power": 10,
	}
	var state: Node = battle.get_battle_state()
	for slot: int in [CASTER, TARGET]:
		state.get_member(slot)["effective_stats"]["spd"] = 0  # every member is hit
	seed(SEED)
	battle._enemy_turn._do_attack_or_ability(action, enemy, 0)
	for slot: int in [CASTER, TARGET]:
		assert_eq(int(state.get_member(slot)["current_hp"]), DEEP_HP, "slot %d's ward held" % slot)
	seed(SEED)
	battle._enemy_turn._do_attack_or_ability(action, enemy, 0)
	for slot: int in [CASTER, TARGET]:
		assert_lt(
			int(state.get_member(slot)["current_hp"]), DEEP_HP, "slot %d's ward is spent" % slot
		)
