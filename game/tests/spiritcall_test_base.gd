extends GutTest
## Shared setup for the Spiritcall suites (GAP-002, slice 158e of #158): a
## battle with Torren in slot 0 and three allies, slow enemies his spirits
## reliably reach, and the seams a real battle drives — the Ability command,
## the bearer's turns, an enemy's physical and magic hit, and a flight.
##
## Torren is fast and every enemy slow, so his spirits all but always land.
## Stats are chosen so the magnitudes read cleanly: Torren's MAG is 40 and
## every ally's DEF is 40, so a spell power P lands for 10P (less 0-6%
## variance) on an MDEF 0 enemy, a heal of power P restores 32P (same
## variance), and a thorn barrier counters for 2/5 of its percentage.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const TORREN := 0
const EDREN := 1
const CAEL := 2
const LIRA := 3
const SPIRITS: Array[String] = ["thornveil", "dewfall", "ember_wing", "stoneheart", "greyveil"]


## The accessors and signals command modules reach on the battle manager.
class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)
	signal flee_result(success: bool)
	var state: Node
	var enemies: Array[Node] = []
	var atb: Node

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return enemies

	func get_atb() -> Node:
		return atb


var _battle: FakeBattle
var _state: Node
var _cmd: RefCounted
## Every damage_dealt as [target, amount, type].
var _hits: Array = []
var _messages: Array[String] = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	seed(12345)
	EventFlags.set_flag("interlude_ley_line_nexus", true)
	EventFlags.set_flag("trial_torren_complete", true)
	_new_battle(30)


func after_each() -> void:
	_cmd = null
	randomize()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


## A fresh battle with Torren at [param level]; Favor is PartyState's, so it
## carries over from the last one as it does in play.
func _new_battle(level: int) -> void:
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		var cid: String = ["torren", "edren", "cael", "lira"][slot]
		_state.add_member(slot, _member(cid, level))
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_battle.atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_battle.atb)
	_hits = []
	_messages = []
	_battle.damage_dealt.connect(
		func(t: String, n: int, k: String) -> void: _hits.append([t, n, k])
	)
	_battle.message.connect(func(text: String) -> void: _messages.append(text))
	_cmd = AbilityCommand.new(_battle)
	_battle.enemies = [_make_enemy({})] as Array[Node]


func _member(cid: String, level: int) -> Dictionary:
	return {
		"character_id": cid,
		"name": cid.capitalize(),
		"level": level,
		"base_stats":
		{
			"hp": 1000,
			"mp": 500,
			"atk": 50,
			"def": 40,
			"mag": 40,
			"mdef": 0,
			"spd": 255 if cid == "torren" else 0,
			"lck": 0,
		},
	}


## A slow enemy, with [param extra] overriding its data.
func _make_enemy(extra: Dictionary) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	var data: Dictionary = {
		"name": "Brute",
		"atk": 60,
		"mag": 60,
		"spd": 0,
		"def": 10,
		"mdef": 0,
		"type": "humanoid",
		"hp": 30000,
	}
	data.merge(extra, true)
	e.enemy_data = data
	e.current_hp = int(data["hp"])
	e.is_alive = true
	return e


func _enemies(list: Array) -> void:
	var out: Array[Node] = []
	for extra: Variant in list:
		out.append(_make_enemy(extra))
	_battle.enemies = out


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("torren"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("torren.json has no ability '%s'" % ability_id)
	return {}


## Torren issues [param ability_id] at [param target] through the Ability
## command, as the battle menu does.
func _call(ability_id: String, target: int = -1) -> bool:
	return _cmd.do_ability(
		"party_%d" % TORREN, {"type": "ability", "ability": _ability(ability_id), "target": target}
	)


func _favor(spirit: String) -> int:
	return int(PartyState.spirit_favor.get(spirit, 0))


func _set_favor(spirit: String, value: int) -> void:
	var table: Dictionary = PartyState.spirit_favor.duplicate()
	table[spirit] = value
	PartyState.spirit_favor = table


## One full turn of [param slot]'s: its start, then its end.
func _turn(slot: int) -> void:
	_state.begin_turn(slot)
	_state.tick_statuses(slot)


## [param enemy] lands a physical attack on [param slot]; returns the result.
## The attacker is made fast for it, so the blow all but always lands on an ally
## (every ally but Torren has SPD 0).
func _enemy_hits(enemy: Node, slot: int) -> Dictionary:
	enemy.enemy_data["spd"] = 255
	return BattleActions.execute_enemy_physical_ability(_state, enemy, slot, 1.0, 1, 1.0, false)


## The counters Torren's thorns dealt in [param result].
func _torren_counters(result: Dictionary) -> Array:
	return result.get("ripostes", []).filter(
		func(r: Dictionary) -> bool: return int(r.get("slot", -1)) == TORREN
	)


## HP restored to party [param slot] in this battle's heal events.
func _healed(slot: int) -> int:
	var total: int = 0
	for h: Array in _hits:
		if h[0] == "party_%d" % slot and h[2] == "heal":
			total += int(h[1])
	return total


## Damage dealt to enemy [param idx] by magic in this battle.
func _dealt(idx: int) -> int:
	var total: int = 0
	for h: Array in _hits:
		if h[0] == "enemy_%d" % idx and h[2] == "magic":
			total += int(h[1])
	return total


## Knock party [param slot] down to [param hp] HP.
func _set_hp(slot: int, hp: int) -> void:
	_state.get_member(slot)["current_hp"] = hp
