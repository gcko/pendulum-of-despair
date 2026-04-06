extends RefCounted
## Battle action execution — physical attacks, magic, items, abilities.
##
## Extracted from battle_manager.gd to stay under 400 lines.
## All functions are static. They operate on battle_state and enemies
## via passed references.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


## Execute a physical attack from a party member against an enemy.
## Returns the damage dealt (0 on miss).
static func execute_party_attack(
	state: Node, slot: int, enemy: Node, _target_idx: int
) -> Dictionary:
	var member: Dictionary = state.get_member(slot)
	if member.is_empty():
		return {"hit": false, "damage": 0, "type": "miss"}

	if not enemy.is_alive:
		return {"hit": false, "damage": 0, "type": "miss"}

	var atk: int = state.get_effective_stat(slot, "atk")
	var spd: int = state.get_effective_stat(slot, "spd")
	var lck: int = state.get_effective_stat(slot, "lck")
	var enemy_stats: Dictionary = enemy.get_stats()
	var target_def: int = enemy_stats.get("def", 0)
	var target_spd: int = enemy_stats.get("spd", 0)

	if not DamageCalc.roll_hit(spd, target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	if DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}

	var is_crit: bool = DamageCalc.roll_crit(lck)
	var dmg: int = DamageCalc.calculate_physical(
		atk,
		1.0,
		target_def,
		is_crit,
		1.0,
		member.get("row", "front"),
		"front",
		false,
		[],
		false,
		1.0
	)

	enemy.take_damage(dmg)
	var dtype: String = "critical" if is_crit else "physical"
	return {"hit": true, "damage": dmg, "type": dtype, "killed": not enemy.is_alive}


## Execute a magic spell against a single enemy. Returns result dict.
static func apply_magic_to_enemy(
	state: Node,
	caster_slot: int,
	mag: int,
	power: int,
	element: String,
	enemy: Node,
	_target_idx: int
) -> Dictionary:
	if not enemy.is_alive:
		return {"hit": false, "damage": 0, "type": "miss"}

	var spd: int = state.get_effective_stat(caster_slot, "spd")
	var enemy_stats: Dictionary = enemy.get_stats()
	var target_mdef: int = enemy_stats.get("mdef", 0)
	var target_spd: int = enemy_stats.get("spd", 0)

	if not DamageCalc.roll_hit(spd, target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	if DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}

	var element_mod: float = enemy.get_element_multiplier(element)
	var dmg: int = DamageCalc.calculate_magic(mag, power, target_mdef, element_mod, 1.0, [], [])

	if element_mod == 0.0:
		return {"hit": true, "damage": 0, "type": "immune"}
	if element_mod < 0.0:
		enemy.heal(dmg)
		return {"hit": true, "damage": dmg, "type": "absorb"}

	enemy.take_damage(dmg)
	return {"hit": true, "damage": dmg, "type": "magic", "killed": not enemy.is_alive}


## Execute an enemy physical attack against a party member.
static func execute_enemy_attack(state: Node, enemy: Node, target_slot: int) -> Dictionary:
	var stats: Dictionary = enemy.get_stats()
	var atk: int = stats.get("atk", 10)
	var spd: int = stats.get("spd", 10)
	var member: Dictionary = state.get_member(target_slot)
	if member.is_empty() or not member.get("is_alive", false):
		return {"hit": false, "damage": 0, "type": "miss"}

	var target_def: int = state.get_effective_stat(target_slot, "def")
	var target_spd: int = state.get_effective_stat(target_slot, "spd")

	if not DamageCalc.roll_hit(spd, target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	if DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}

	var is_crit: bool = randi() % 100 < 5  # Enemy fixed 5% crit
	var reduction: Array = []
	var dmg_mult: float = member.get("damage_taken_mult", 1.0)
	if dmg_mult < 1.0:
		reduction.append(1.0 - dmg_mult)  # Convert mult to reduction source
	var dmg: int = (
		DamageCalc
		. calculate_physical(
			atk,
			1.0,
			target_def,
			is_crit,
			1.0,
			"front",
			member.get("row", "front"),
			false,
			reduction,
			false,
			1.0,
		)
	)
	state.take_damage(target_slot, dmg)
	return {"hit": true, "damage": dmg, "type": "physical"}
