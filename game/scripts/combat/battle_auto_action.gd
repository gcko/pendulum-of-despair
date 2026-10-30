class_name BattleAutoAction
extends RefCounted
## Confusion and Berserk take the command away (GAP-003 slice 5, #246).
##
## combat-formulas.md § Status Effect ATB Interactions: a confused combatant
## "Auto-attack[s] random ally or enemy", and a berserk one "Auto-attack[s]
## random enemy". Rulings of 2026-10-30: Confusion picks uniformly among every
## living combatant on both sides except itself, Berserk among the living
## combatants of the other side; the attack is the plain basic attack; and the
## turn is a full turn, so begin-turn effects and the status tick run exactly as
## on a commanded one and Confusion's 3 turns run out. Both sides are covered:
## BattleManager hands a party member's turn here instead of prompting it, and
## BattleEnemyTurn hands an enemy's here instead of asking its AI.
##
## Not built here: Berserk's "+50% basic attack damage". That is a multiplier on
## the attack's final damage (as Overcharge's "+50% damage" is, combat-formulas.md
## § Physical Ability Multiplier Tiers), not an ability_mult, and neither
## BattleActions.execute_party_attack nor execute_enemy_attack takes one yet.

const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")
const Enemy = preload("res://scripts/entities/enemy.gd")

## The statuses that take the command away, and whom each lets its bearer hit:
## "any" (both sides, never itself) or "foes" (the other side only). Confusion is
## listed first, so it decides the turn of a combatant carrying both.
const AUTO_TARGETS: Dictionary = {"confusion": "any", "berserk": "foes"}

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## The status making this combatant's turn for it ("confusion" or "berserk"),
## or "" when it is under command.
static func driving_status(active_statuses: Array) -> String:
	for status: String in AUTO_TARGETS:
		for s: Dictionary in active_statuses:
			if s.get("name", "") == status:
				return status
	return ""


## The combatant [param own] ("party_N" or "enemy_N") auto-attacks under
## [param status], chosen uniformly from those it may hit: living party members,
## and living enemies the party could target (a petrified or diving one is off
## the field). Returns its id, or "" when nobody is left to hit.
static func pick_target(status: String, own: String, state: Node, enemies: Array[Node]) -> String:
	var both: bool = AUTO_TARGETS.get(status, "foes") == "any"
	var own_party: bool = own.begins_with("party_")
	var pool: Array[String] = []
	if both or not own_party:
		for i: int in range(4):
			if state.get_member(i).get("is_alive", false):
				pool.append("party_%d" % i)
	if both or own_party:
		for i: int in range(enemies.size()):
			if enemies[i].is_alive and not enemies[i].get_meta("untargetable", false):
				pool.append("enemy_%d" % i)
	pool.erase(own)
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]


## Take [param slot]'s turn for it if Confusion or Berserk holds it, and return
## whether it did. The caller has already begun the turn; this ends it the way
## a commanded Attack does: a Defend from a previous turn lapses, then
## BattleManager.end_party_turn empties the gauge and ticks the statuses.
func take_party_turn(slot: int) -> bool:
	var state: Node = _battle.get_battle_state()
	var status: String = driving_status(state.get_member(slot).get("active_statuses", []))
	if status.is_empty():
		return false
	var target: String = pick_target(status, "party_%d" % slot, state, _battle.get_enemies())
	var nm: String = _member_name(state, slot)
	if target.begins_with("enemy_"):
		var idx: int = target.replace("enemy_", "").to_int()
		var enemy: Node = _battle.get_enemies()[idx]
		_battle.message.emit("%s attacks %s!" % [nm, enemy.get_display_name()])
		BattlePlayerActions.new(_battle).strike(slot, idx)
	elif target.begins_with("party_"):
		var ally: int = target.replace("party_", "").to_int()
		_battle.message.emit("%s attacks %s!" % [nm, _member_name(state, ally)])
		var asleep: Array[int] = BattleEnemyTurn.sleeping_slots(state)
		var r: Dictionary = party_strikes_ally(state, slot, ally)
		_battle.damage_dealt.emit(target, int(r["damage"]), r["type"])
		for line: String in BattleEnemyTurn.wake_lines(state, asleep):
			_battle.message.emit(line)
	if state.get_member(slot).get("is_defending", false):
		state.set_defending(slot, false)
		state.set_buff(slot, "damage_taken_mult", 1.0)
	_battle.end_party_turn(slot)
	return true


## A party member's basic attack on an ally: the physical formula with the
## attacker's ATK/SPD/LCK and row against the ally's DEF/SPD, row and Defend.
## Returns {hit, damage, type}.
static func party_strikes_ally(state: Node, slot: int, target: int) -> Dictionary:
	var spd: int = state.get_effective_stat(slot, "spd")
	var target_spd: int = state.get_effective_stat(target, "spd")
	if not DamageCalc.roll_hit(spd, target_spd) or DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	var is_crit: bool = DamageCalc.roll_crit(state.get_effective_stat(slot, "lck"))
	var reduction: Array[float] = []
	var taken_mult: float = state.get_member(target).get("damage_taken_mult", 1.0)
	if taken_mult < 1.0:
		reduction.append(1.0 - taken_mult)
	var dmg: int = DamageCalc.calculate_physical(
		state.get_effective_stat(slot, "atk"),
		1.0,
		state.get_effective_stat(target, "def"),
		is_crit,
		1.0,
		state.get_member(slot).get("row", "front"),
		state.get_member(target).get("row", "front"),
		false,
		reduction,
		false,
		1.0
	)
	dmg = state.take_damage(target, dmg)
	return {"hit": true, "damage": dmg, "type": "critical" if is_crit else "physical"}


## An enemy's basic attack on another enemy: the enemy-side physical formula
## (ATK/SPD, the flat enemy crit rate) against the target's DEF/SPD, halved
## before DEF on a Spirit as every physical hit on one is. Returns
## {hit, damage, type, killed}.
static func enemy_strikes_enemy(attacker: Node, target: Node) -> Dictionary:
	var a: Dictionary = attacker.get_stats()
	var t: Dictionary = target.get_stats()
	var target_spd: int = t.get("spd", 0)
	if not DamageCalc.roll_hit(a.get("spd", 10), target_spd):
		return {"hit": false, "damage": 0, "type": "miss", "killed": false}
	if DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss", "killed": false}
	var is_crit: bool = randf() < Enemy.ENEMY_CRIT_RATE
	var dmg: int = DamageCalc.calculate_physical(
		a.get("atk", 10),
		1.0,
		t.get("def", 0),
		is_crit,
		1.0,
		"front",
		"front",
		false,
		[],
		false,
		1.0,
		ModifierAggregator.physical_pre_def_mult(target.get_type())
	)
	target.take_damage(dmg)
	var dtype: String = "critical" if is_crit else "physical"
	return {"hit": true, "damage": dmg, "type": dtype, "killed": not target.is_alive}


static func _member_name(state: Node, slot: int) -> String:
	return state.get_member(slot).get("character_data", {}).get("name", "???")
