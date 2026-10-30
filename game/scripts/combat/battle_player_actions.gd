class_name BattlePlayerActions
extends RefCounted
## The Attack, Defend and Flee commands — the three that need no submenu.
##
## Extracted from battle_manager.gd (GAP-087) so the manager holds the ATB loop
## and the command dispatch while each command owns its own resolution rules.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")

## Damage multiplier a defending member takes until their next action.
const DEFEND_DAMAGE_MULT: float = 0.5

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Swing at the chosen enemy — twice under Edren's Oathkeeper, each swing a
## plain basic attack with its own rolls (abilities.md § Edren — Bulwark), the
## second only if the first left the target standing. Returns false when the
## target is gone, so the caller re-opens the command menu instead of consuming
## the turn.
func do_attack(actor_id: String, command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var enemies: Array[Node] = _battle.get_enemies()
	var slot: int = actor_id.replace("party_", "").to_int()
	var target_idx: int = BattleActions.resolve_enemy_target(command.get("target", 0), enemies)
	if target_idx < 0:
		_battle.message.emit("No target!")
		return false
	var member: Dictionary = state.get_member(slot)
	_battle.message.emit("%s attacks!" % member.get("character_data", {}).get("name", "???"))
	for _swing: int in range(Bulwark.attack_hits(member)):
		if not enemies[target_idx].is_alive:
			break
		strike(slot, target_idx)
	return true


## One basic attack from [param slot] on enemy [param target_idx], shown and
## counted: its damage number, the threat it earns, and the kill it makes. A
## swing of the Attack command, and a confused or berserk member's auto-attack,
## whose [param damage_mult] (Berserk's 1.5) scales its final damage.
func strike(slot: int, target_idx: int, damage_mult: float = 1.0) -> Dictionary:
	var state: Node = _battle.get_battle_state()
	var eid: String = "enemy_%d" % target_idx
	var result: Dictionary = BattleActions.execute_party_attack(
		state, slot, _battle.get_enemies()[target_idx], target_idx, 1.0, damage_mult
	)
	state.add_threat(slot, int(result.get("damage", 0)))  # GAP-009 highest-threat
	_battle.damage_dealt.emit(eid, result.get("damage", 0), result.get("type", "miss"))
	if result.get("killed", false):
		_battle.combatant_died.emit(eid)
		_battle.get_atb().remove_combatant(eid)
	return result


## Halve incoming damage until this member's next action.
func do_defend(actor_id: String) -> void:
	var state: Node = _battle.get_battle_state()
	var slot: int = actor_id.replace("party_", "").to_int()
	state.set_defending(slot, true)
	state.set_buff(slot, "damage_taken_mult", DEFEND_DAMAGE_MULT)
	var nm: String = state.get_member(slot).get("character_data", {}).get("name", "???")
	_battle.message.emit("%s defends!" % nm)


## Roll to escape against the average speed of the enemies still in the fight:
## alive, and not removed from combat (a petrified one does not give chase).
func do_flee() -> void:
	var state: Node = _battle.get_battle_state()
	var alive_enemies: Array[Node] = []
	for e: Node in _battle.get_enemies():
		if e.is_alive and not e.is_removed_from_combat():
			alive_enemies.append(e)
	var enemy_spd_sum: float = alive_enemies.reduce(
		func(acc: float, e: Node) -> float: return acc + e.get_stats().get("spd", 10), 0.0
	)
	var chance: int = DamageCalc.calculate_flee_chance(
		state.get_avg_party_spd(), enemy_spd_sum / maxf(1.0, alive_enemies.size())
	)
	if randi() % 100 < chance:
		_battle.message.emit("Escaped!")
		_battle.flee_result.emit(true)
		_battle.exit_battle("flee")
	else:
		_battle.message.emit("Can't escape!")
		_battle.flee_result.emit(false)
