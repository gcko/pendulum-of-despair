extends GutTest
## Drag Tide turned on an enemy slows its ATB gauge (#514): "Reduces ATB fill
## speed by 30% for 5 turns. 75% hit rate." (magic.md § 69 Drag Tide). It is a
## stat debuff like Sunder (`stat_debuff: {stat: atb_fill, pct: 30}`), so it
## rolls to hit, counts down on the enemy's own turns and is read every frame by
## the battle's enemy gauge resync. It lowers no stat the hit and evasion rolls
## read: SPD is untouched.
##
## An enemy's SPD buff or debuff reaches its gauge through the same exact
## arithmetic as its stats, "add, then floor once" (combat-formulas.md § Buff &
## Debuff Interaction): SPD 90 at -30% fills as SPD 63.
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted.
## The target's MDEF and SPD are zeroed for the roll, so a cast at hit rate 100
## always lands and one at 0 always misses. A gauge's fill is read as what one
## ATB tick adds to it from empty, after the battle's own resync.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

const PROMPT_TIMEOUT: float = 5.0
const CASTER: int = 0
## The battle speed every fill here is read at.
const SPEED: int = 3
## The SPD the target's gauge is read at once the roll is behind it.
const FILL_SPD: int = 90

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
	var enemy: Node = battle.get_enemies()[0]
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["mdef"] = 0
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


func _drag_tide(hit_rate: int) -> Dictionary:
	for entry: Variant in DataManager.load_spells("ley_line"):
		if String((entry as Dictionary).get("id", "")) == "drag_tide":
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			if hit_rate >= 0:
				spell["hit_rate"] = hit_rate
			return spell
	fail_test("drag_tide is missing from ley_line.json")
	return {}


func _cast(battle: Node, spell: Dictionary) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": 0, "target_enemy": true}
	)
	return true


## What one ATB tick adds to enemy 0's empty gauge, with the battle's resync
## having read the enemy first, as it does every frame.
func _fill(battle: Node) -> int:
	var atb: Node = battle.get_atb()
	atb.set_atb_mode("active")
	atb.set_battle_speed(SPEED)
	battle.resync_enemy_atb(0)
	atb.set_gauge("enemy_0", 0)
	atb.tick(1.0 / ATBSystem.TICKS_PER_SECOND)
	return atb.get_gauge("enemy_0")


func _rate(battle: Node, spd: int, mods: Array) -> int:
	return battle.get_atb().calculate_fill_rate(spd, SPEED, mods)


func test_drag_tide_carries_its_magic_md_values() -> void:
	var spell: Dictionary = _drag_tide(-1)
	var debuff: Variant = spell.get("stat_debuff")
	assert_true(debuff is Dictionary, "Drag Tide carries a stat_debuff")
	if not debuff is Dictionary:
		return
	assert_eq(String(debuff.get("stat", "")), "atb_fill", "it lowers ATB fill speed")
	assert_eq(int(debuff.get("pct", 0)), 30, "by 30%")
	assert_eq(int(spell.get("duration", 0)), 5, "for 5 turns")
	assert_eq(int(spell.get("hit_rate", 0)), 75, "at a 75% hit rate")


func test_drag_tide_slows_an_enemy_gauge_30_percent_for_5_of_its_turns() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	var said: Array[String] = []
	battle.message.connect(func(text: String) -> void: said.append(text))
	if not await _cast(battle, _drag_tide(100)):
		return
	assert_true(said.any(func(t: String) -> bool: return " casts Drag Tide!" in t), str(said))
	enemy.enemy_data["spd"] = FILL_SPD
	var slowed: int = _rate(battle, FILL_SPD, [0.7])
	assert_eq(_fill(battle), slowed, "the gauge fills at 70%")
	for _turn: int in range(4):
		enemy.tick_buffs()
	assert_eq(_fill(battle), slowed, "still slowed on its fifth turn")
	enemy.tick_buffs()
	assert_eq(_fill(battle), _rate(battle, FILL_SPD, []), "and back to full speed after it")


func test_a_missed_drag_tide_leaves_the_gauge_alone() -> void:
	var battle: Node = _boot()
	var markers: Array[String] = []
	battle.damage_dealt.connect(
		func(tid: String, _amt: int, dt: String) -> void: markers.append("%s:%s" % [tid, dt])
	)
	if not await _cast(battle, _drag_tide(0)):
		return
	battle.get_enemies()[0].enemy_data["spd"] = FILL_SPD
	assert_eq(_fill(battle), _rate(battle, FILL_SPD, []), "the gauge fills at full speed")
	assert_has(markers, "enemy_0:miss", "and the player sees a miss: %s" % str(markers))


func test_drag_tide_lowers_no_stat_the_hit_rolls_read() -> void:
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	enemy.enemy_data["spd"] = FILL_SPD
	var before: Dictionary = enemy.get_stats()
	# SPD 90 would dodge a hit-100 cast now and then; the roll is pinned instead.
	enemy.enemy_data["spd"] = 0
	if not await _cast(battle, _drag_tide(100)):
		return
	enemy.enemy_data["spd"] = FILL_SPD
	assert_lt(_fill(battle), _rate(battle, FILL_SPD, []), "precondition: Drag Tide landed")
	assert_eq(enemy.get_stats(), before, "SPD, MDEF and the rest read as before")


func test_an_enemy_spd_debuff_fills_its_gauge_at_the_floored_stat() -> void:
	# 90 at -30% is 63 (90 * 70 / 100), not the 62 that 90 * 0.7 truncates to.
	var battle: Node = _boot()
	var enemy: Node = battle.get_enemies()[0]
	enemy.enemy_data["spd"] = FILL_SPD
	enemy.apply_buff("spd", 0.7, 5)
	assert_eq(int(enemy.get_stats()["spd"]), 63, "precondition: the stat reads 63")
	assert_eq(_fill(battle), _rate(battle, 63, []), "the gauge fills as SPD 63")
