extends GutTest
## Glintmark marks one enemy (#514): "Marked targets take 10% more damage from
## all sources for 3 turns" (magic.md § 78 Glintmark), the Status Effect
## Reference's "Takes 10% more damage from all sources", "Wears off". Its 10%
## is a final-damage multiplier: step 6 of a physical attack and step 5 of a
## spell (combat-formulas.md § Combat Resolution Order; the Glintmark row of
## its Buff & Debuff Interaction table). It is the party's mark on the enemy,
## so Dispersion, which removes an enemy's buffs and leaves the party's
## debuffs, leaves it on.
##
## The cast boots battle.tscn and goes in through BattleUI.command_submitted.
## The damage it adds is read through the seams the battle's own commands
## call: BattleActions for a spell and an Attack, BattleEnemyHeal for a heal
## turned on an Undead. A spell and an Attack are read twice from one RNG seed,
## so the variance, hit and crit rolls are the same with and without the mark.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")

const PROMPT_TIMEOUT: float = 5.0
const CASTER: int = 0
## An HP pool no probe here can empty.
const DEEP_HP: int = 99999
## The fixed rolls every spell and Attack probe is read at.
const SEED: int = 4242

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


## Boot a battle against [param encounter], every enemy deep in HP with no
## DEF, MDEF or SPD, so each probe lands and reads the whole formula.
func _boot(encounter: Array = ["ley_vermin"]) -> Node:
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
	for enemy: Node in battle.get_enemies():
		var data: Dictionary = enemy.enemy_data.duplicate(true)
		for stat: String in ["def", "mdef", "spd"]:
			data[stat] = 0
		data["hp"] = DEEP_HP
		enemy.enemy_data = data
		enemy.current_hp = DEEP_HP
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


## Wait for the caster's prompt, then cast [param spell] on enemy [param target].
func _cast(battle: Node, spell: Dictionary, target: int = 0) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": target, "target_enemy": true}
	)
	return true


## The damage a power-50 non-elemental spell from the caster lands on
## [param enemy], at MAG 100 and fixed rolls.
func _spell_damage(battle: Node, enemy: Node) -> int:
	seed(SEED)
	var r: Dictionary = BattleActions.apply_magic_to_enemy(
		battle.get_battle_state(), CASTER, 100, 50, "non_elemental", enemy, 0
	)
	assert_true(r.get("hit", false), "precondition: the probe spell lands")
	return int(r.get("damage", 0))


## The damage the caster's Attack lands on [param enemy], at fixed rolls.
func _attack_damage(battle: Node, enemy: Node) -> int:
	seed(SEED)
	var r: Dictionary = BattleActions.execute_party_attack(
		battle.get_battle_state(), CASTER, enemy, 0
	)
	assert_true(r.get("hit", false), "precondition: the probe Attack lands")
	return int(r.get("damage", 0))


## The HP 100 HP of the caster's healing takes from [param enemy] made an
## Undead: no roll stands between the heal and the damage it becomes.
func _undead_hit(battle: Node, enemy: Node) -> int:
	enemy.enemy_data["type"] = "undead"
	var before: int = enemy.current_hp
	BattleEnemyHeal.land(battle, CASTER, 100, enemy, 0)
	return before - enemy.current_hp


## Assert [param marked] is [param plain] raised 10%, as two floors of one
## variance roll allow.
func _assert_raised_10_percent(marked: int, plain: int, what: String) -> void:
	var raised: int = int(plain * 1.1)
	assert_gt(plain, 100, "precondition: %s is big enough to show 10%%" % what)
	assert_between(marked, raised, raised + 2, "%s: %d unmarked, %d marked" % [what, plain, marked])


func test_glintmark_carries_its_magic_md_values() -> void:
	var spell: Dictionary = _spell("streetwise", "glintmark")
	assert_eq(int(spell.get("damage_taken_pct", 0)), 10, "10% more damage taken")
	assert_eq(int(spell.get("duration", 0)), 3, "for 3 turns")
	assert_eq(String(spell.get("target", "")), "single_enemy", "on one enemy")


func test_a_spell_lands_10_percent_more_on_a_marked_enemy() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	var plain: int = _spell_damage(battle, enemy)
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	_assert_raised_10_percent(_spell_damage(battle, enemy), plain, "a spell")


func test_an_attack_lands_10_percent_more_on_a_marked_enemy() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	var plain: int = _attack_damage(battle, enemy)
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	_assert_raised_10_percent(_attack_damage(battle, enemy), plain, "an Attack")


func test_a_trick_s_strike_on_a_marked_enemy_carries_the_10_percent() -> void:
	# BattleTricksCommand hands trick_mods' mult to the physical formula's
	# step 6, as an Attack's strike_mods is.
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	var member: Dictionary = battle.get_battle_state().get_member(CASTER)
	assert_eq(BattleDamageMods.trick_mods(member, enemy, "")["mult"], 1.0, "precondition")
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	assert_almost_eq(BattleDamageMods.trick_mods(member, enemy, "")["mult"], 1.1, 0.0001)


func test_a_heal_turned_on_a_marked_undead_hurts_it_10_percent_more() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	assert_eq(_undead_hit(battle, enemy), 100, "precondition: unmarked, 100 HP of heal is 100")
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	assert_eq(_undead_hit(battle, enemy), 110, "marked, it is 110")


func test_the_mark_lasts_three_of_the_enemy_s_turns() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	for _turn: int in range(2):
		enemy.tick_buffs()
	assert_eq(_undead_hit(battle, enemy), 110, "still marked on its third turn")
	enemy.tick_buffs()
	assert_eq(_undead_hit(battle, enemy), 100, "and unmarked once three turns are up")


func test_the_mark_needs_no_hit_roll() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	enemy.enemy_data["mdef"] = 255
	enemy.enemy_data["spd"] = 320
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	assert_eq(_undead_hit(battle, enemy), 110, "the most evasive target is still marked")


func test_the_mark_falls_only_on_its_target() -> void:
	var battle: Node = _boot(["ley_vermin", "ley_vermin"])
	var enemies: Array[Node] = battle.get_enemies()
	assert_eq(enemies.size(), 2, "precondition: two enemies")
	if not await _cast(battle, _spell("streetwise", "glintmark"), 0):
		return
	assert_eq(_undead_hit(battle, enemies[0]), 110, "the target is marked")
	assert_eq(_undead_hit(battle, enemies[1]), 100, "the other enemy is not")


func test_dispersion_leaves_the_mark_on() -> void:
	# Glintmark is "Positive (on enemy)", "Wears off" only (magic.md § Status
	# Effect Reference); "Player-side Dispersion removes enemy buffs, not
	# friendly ones".
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	enemy.apply_buff("atk", 1.3, 5)
	if not await _cast(battle, _spell("streetwise", "glintmark")):
		return
	if not await _cast(battle, _spell("ley_line", "dispersion")):
		return
	assert_eq(enemy.buff_mult("atk"), 1.0, "precondition: Dispersion stripped the ATK buff")
	assert_eq(_undead_hit(battle, enemy), 110, "and left the mark")


func test_glintmark_can_be_cast_from_sable_s_magic_menu() -> void:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	m.show_commands({"character_id": "sable", "level": 40}, false, {"current_mp": 999})
	m._cursor = 1  # Magic (Attack, Magic, Ability, Item, Defend, Flee)
	m._confirm_command()
	var entry: Dictionary = {}
	for item: Dictionary in m._submenu_items:
		if item.get("command", {}).get("spell", {}).get("id", "") == "glintmark":
			entry = item
	assert_false(entry.is_empty(), "precondition: Sable knows Glintmark")
	assert_true(entry.get("enabled", false), "Glintmark is offered")
