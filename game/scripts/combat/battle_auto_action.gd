class_name BattleAutoAction
extends RefCounted
## Confusion and Berserk take the command away (GAP-003 slice 5, #246).
##
## combat-formulas.md § Status Effect ATB Interactions: a confused combatant
## "Auto-attack[s] random ally or enemy", and a berserk one "Auto-attack[s]
## random enemy". Rulings of 2026-10-30: Confusion picks uniformly among every
## living combatant on both sides except itself, Berserk among the living
## combatants of the other side; the attack is the plain basic attack, twice
## under Oathkeeper; friendly fire meets Bulwark but draws no Riposte; and the
## turn is a full turn, so begin-turn effects and the status tick run exactly as
## on a commanded one and Confusion's 3 turns run out. Both sides are covered:
## BattleManager issues a party member's turn here as an "auto" command instead
## of prompting it, and BattleEnemyTurn hands an enemy's here instead of asking
## its AI.
##
## Berserk's "+50% basic attack damage" multiplies the blow's final damage at
## step 6, after DEF (as Overcharge's "+50% damage" does, combat-formulas.md
## § Physical Ability Multiplier Tiers), on every blow a berserk unit lands —
## one Confusion is driving included: BattleActions' damage_mult on its attack
## calls, and the same step on the two blows built here.

const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")
const Enemy = preload("res://scripts/entities/enemy.gd")

## The statuses that take the command away, and whom each lets its bearer hit:
## "any" (both sides, never itself) or "foes" (the other side only). Confusion is
## listed first, so it decides the turn of a combatant carrying both.
const AUTO_TARGETS: Dictionary = {"confusion": "any", "berserk": "foes"}

## Berserk's final-damage multiplier on its bearer's basic attack.
const BERSERK_DAMAGE_MULT: float = 1.5

var _battle: Node
var _actions: BattlePlayerActions


## [param actions] is the battle's own BattlePlayerActions, whose strike is
## the Attack command's swing.
func _init(battle: Node, actions: BattlePlayerActions) -> void:
	_battle = battle
	_actions = actions


## The status making this combatant's turn for it ("confusion" or "berserk"),
## or "" when it is under command.
static func driving_status(active_statuses: Array) -> String:
	for status: String in AUTO_TARGETS:
		for s: Dictionary in active_statuses:
			if s.get("name", "") == status:
				return status
	return ""


## The final-damage multiplier on a basic attack by a bearer of
## [param active_statuses]: BERSERK_DAMAGE_MULT under Berserk, else 1.0.
static func damage_mult(active_statuses: Array) -> float:
	for s: Dictionary in active_statuses:
		if s.get("name", "") == "berserk":
			return BERSERK_DAMAGE_MULT
	return 1.0


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


## Make [param slot]'s basic attack for it under Confusion or Berserk: twice
## under Edren's Oathkeeper, as the Attack command swings, the second only if
## the first left the target standing. Resolves the attack only; the manager
## opens and closes the turn around it, as it does around any command.
func act_for(slot: int) -> void:
	var state: Node = _battle.get_battle_state()
	var member: Dictionary = state.get_member(slot)
	var status: String = driving_status(member.get("active_statuses", []))
	var target: String = pick_target(status, "party_%d" % slot, state, _battle.get_enemies())
	var nm: String = _member_name(state, slot)
	var mult: float = damage_mult(member.get("active_statuses", []))
	if target.begins_with("enemy_"):
		var idx: int = target.replace("enemy_", "").to_int()
		var enemy: Node = _battle.get_enemies()[idx]
		_battle.message.emit("%s attacks %s!" % [nm, enemy.get_display_name()])
		for _swing: int in range(Bulwark.attack_hits(member)):
			if not enemy.is_alive:
				break
			_actions.strike(slot, idx, mult)
	elif target.begins_with("party_"):
		var ally: int = target.replace("party_", "").to_int()
		_battle.message.emit("%s attacks %s!" % [nm, _member_name(state, ally)])
		var asleep: Array[int] = BattleEnemyTurn.sleeping_slots(state)
		for _swing: int in range(Bulwark.attack_hits(member)):
			if not state.get_member(ally).get("is_alive", false):
				break
			_show_ally_hit(target, party_strikes_ally(state, slot, ally, mult))
		for line: String in BattleEnemyTurn.wake_lines(state, asleep):
			_battle.message.emit(line)


## Show a blow on an ally ([param target], "party_N"), and the share Edren's
## stance took from it as his own number.
func _show_ally_hit(target: String, r: Dictionary) -> void:
	_battle.damage_dealt.emit(target, int(r["damage"]), r["type"])
	var share: Dictionary = r.get("absorbed", {})
	if not share.is_empty():
		_battle.damage_dealt.emit("party_%d" % int(share["slot"]), int(share["damage"]), r["type"])


## A party member's basic attack on an ally: the physical formula with the
## attacker's ATK/SPD/LCK and row against the ally's DEF/SPD, row and Defend.
## Bulkhead cuts it as it cuts an enemy's hit, and a Bulwark stance meets it as
## it meets one: Edren absorbs his share, or counts a direct hit on himself. But
## no counter answers an ally, Riposte or Thornveil, and Edren's stance never
## absorbs his own blow (rulings of 2026-10-30). Returns {hit, damage, type},
## plus "absorbed": {slot, damage} when a stance split it. [param mult] scales
## its final damage (Berserk).
static func party_strikes_ally(
	state: Node, slot: int, target: int, mult: float = 1.0
) -> Dictionary:
	var spd: int = state.get_effective_stat(slot, "spd")
	var target_spd: int = state.get_effective_stat(target, "spd")
	if not DamageCalc.roll_hit(spd, target_spd) or DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	var is_crit: bool = DamageCalc.roll_crit(state.get_effective_stat(slot, "lck"))
	var reduction: Array[float] = []
	var taken_mult: float = state.get_member(target).get("damage_taken_mult", 1.0)
	if taken_mult < 1.0:
		reduction.append(1.0 - taken_mult)
	reduction.append_array(BattleForgewright.reductions(state, target, "physical"))  # Bulkhead
	var guard: Dictionary = Bulwark.guard_for(state, target, "physical")
	if int(guard.get("slot", -1)) == slot:
		guard = {}  # Edren's own blow on the ally he guards lands whole
	var dmg: int = DamageCalc.calculate_physical(
		state.get_effective_stat(slot, "atk"),
		1.0,
		state.get_effective_stat(target, "def"),
		is_crit,
		mult,
		state.get_member(slot).get("row", "front"),
		state.get_member(target).get("row", "front"),
		false,
		reduction if guard.is_empty() else [],
		false,
		1.0
	)
	var dtype: String = "critical" if is_crit else "physical"
	if guard.is_empty():
		return {"hit": true, "damage": state.take_damage(target, dmg), "type": dtype}
	var out: Dictionary = _land_guarded(state, target, dmg, reduction, guard)
	out["hit"] = true
	out["type"] = dtype
	return out


## Land [param pre], an ally's hit before any damage reduction, on
## [param target] as a Bulwark stance meets an enemy's: Edren absorbs his share
## (Bulwark.split, Bulwark.absorb), or a direct hit on him in his stance is
## counted (Bulwark.count_absorbed) and splits nothing. Unlike an enemy's hit,
## no Riposte follows. Returns {damage}, plus "absorbed": {slot, damage}.
static func _land_guarded(
	state: Node, target: int, pre: int, reductions: Array[float], guard: Dictionary
) -> Dictionary:
	var shares: Dictionary = Bulwark.split(pre, reductions, guard)
	var edren: int = int(guard["slot"])
	if edren == target:
		Bulwark.count_absorbed(state, edren, int(shares["damage"]), pre)
		return {"damage": state.take_damage(target, int(shares["damage"]))}
	var out: Dictionary = {"damage": state.take_damage(target, int(shares["damage"]))}
	var taken: int = Bulwark.absorb(state, guard, int(shares["absorbed"]), pre)
	out["absorbed"] = {"slot": edren, "damage": taken}
	return out


## Enemy [param attacker]'s basic attack on [param target] ("enemy_N"), another
## enemy, announced and shown on [param manager], its kill cleaned up off
## [param atb] as any kill is. It is a physical attack, so an armed Arc Trap
## then goes off on the attacker, whatever its target (abilities.md § Lira —
## Forgewright, ruling of 2026-10-30), shown and cleaned up the same way.
static func enemy_hits_enemy(
	manager: Node, atb: Node, attacker: Node, enemies: Array[Node], target: String
) -> void:
	var other: Node = enemies[target.replace("enemy_", "").to_int()]
	manager.message.emit("%s attacks %s!" % [attacker.get_display_name(), other.get_display_name()])
	var r: Dictionary = enemy_strikes_enemy(attacker, other, damage_mult(attacker.active_statuses))
	_show_enemy_hit(manager, atb, target, r)
	var state: Node = manager.get_battle_state()
	var aid: String = "enemy_%d" % enemies.find(attacker)
	for trap: Dictionary in BattleForgewright.spring_trap(state, attacker):
		if BattlePlayerActions.dealt_damage(trap):
			state.add_threat(int(trap["slot"]), int(trap["damage"]))  # GAP-009
		_show_enemy_hit(manager, atb, aid, trap)


## Show [param r] on enemy [param eid] and clean up the kill it made.
static func _show_enemy_hit(manager: Node, atb: Node, eid: String, r: Dictionary) -> void:
	manager.damage_dealt.emit(eid, int(r.get("damage", 0)), r.get("type", "miss"))
	if r.get("killed", false):
		manager.combatant_died.emit(eid)
		atb.remove_combatant(eid)


## An enemy's basic attack on another enemy: the enemy-side physical formula
## (ATK/SPD, the flat enemy crit rate) against the target's DEF/SPD, halved
## before DEF on a Spirit as every physical hit on one is, with [param mult] on
## its final damage (Berserk). Returns {hit, damage, type, killed}.
static func enemy_strikes_enemy(attacker: Node, target: Node, mult: float = 1.0) -> Dictionary:
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
		mult,
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
