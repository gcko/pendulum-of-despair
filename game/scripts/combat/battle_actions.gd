extends RefCounted
## Battle action execution — physical attacks, magic, items, abilities.
##
## Extracted from battle_manager.gd to stay under 400 lines.
## All functions are static. They operate on battle_state and enemies
## via passed references.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Enemy = preload("res://scripts/entities/enemy.gd")


## Resolve a player status spell against a single enemy (GAP-003).
## Runs the two-stage accuracy roll (DamageCalc.roll_status) using the caster's
## MAG vs the enemy's MDEF/SPD, then applies the status (enemy.apply_status
## gates type/boss immunities). Beneficial/ally statuses are NOT handled here.
## Returns {hit, inflicted, type, status} where type is one of
## "status" | "resisted" | "immune" | "no_effect".
static func apply_status_to_enemy(
	state: Node,
	caster_slot: int,
	base_rate: int,
	status_name: String,
	explicit_duration: Variant,
	enemy: Node
) -> Dictionary:
	if not enemy.is_alive or not StatusEffects.is_known(status_name):
		return {"hit": false, "inflicted": false, "type": "no_effect", "status": status_name}
	# Immune targets don't roll — auto no-effect (type/boss/per-enemy immunity).
	# Intentional deviation from combat-formulas.md's step order (immunity is
	# step 4, after the rolls): the applied/not-applied outcome is identical and
	# this skips a pointless roll.
	if enemy.is_immune_to_status(status_name):
		return {"hit": true, "inflicted": false, "type": "immune", "status": status_name}
	var caster_mag: int = state.get_effective_stat(caster_slot, "mag")
	var stats: Dictionary = enemy.get_stats()
	var target_mdef: int = stats.get("mdef", 0)
	var target_spd: int = stats.get("spd", 0)
	if not DamageCalc.roll_status(base_rate, caster_mag, target_mdef, target_spd):
		return {"hit": false, "inflicted": false, "type": "resisted", "status": status_name}
	var duration: int = StatusEffects.resolve_duration(status_name, explicit_duration)
	enemy.apply_status(status_name, duration)
	return {"hit": true, "inflicted": true, "type": "status", "status": status_name}


## Resolve an enemy offensive status against a party member (GAP-024).
## Mirror of apply_status_to_enemy, enemy->party: the enemy's MAG drives the
## two-stage roll's Stage 1, the member's MDEF/SPD drive resistance. Reuses
## DamageCalc.roll_status + StatusEffects.resolve_duration (no duplication).
## Returns {hit, inflicted, type, status}; type is
## "status" | "resisted" | "no_effect".
static func execute_enemy_status(
	state: Node,
	enemy: Node,
	target_slot: int,
	base_rate: int,
	status_name: String,
	explicit_duration: Variant
) -> Dictionary:
	var member: Dictionary = state.get_member(target_slot)
	var alive: bool = not member.is_empty() and member.get("is_alive", false)
	if not alive or not StatusEffects.is_known(status_name):
		return {"hit": false, "inflicted": false, "type": "no_effect", "status": status_name}
	var caster_mag: int = enemy.get_stats().get("mag", 0)
	var target_mdef: int = state.get_effective_stat(target_slot, "mdef")
	var target_spd: int = state.get_effective_stat(target_slot, "spd")
	if not DamageCalc.roll_status(base_rate, caster_mag, target_mdef, target_spd):
		return {"hit": false, "inflicted": false, "type": "resisted", "status": status_name}
	var duration: int = StatusEffects.resolve_duration(status_name, explicit_duration)
	state.apply_status(target_slot, status_name, "turns", float(duration))
	return {"hit": true, "inflicted": true, "type": "status", "status": status_name}


## Return the enemy's aoe_on_death ability dict, or {} if it has none.
## (e.g. Unstable Crystal's Shard Burst, per enemy-ability-conventions.md §2.6).
static func enemy_aoe_on_death_ability(enemy: Node) -> Dictionary:
	for ab: Dictionary in enemy.enemy_data.get("abilities", []):
		if ab.get("aoe_on_death", false):
			return ab
	return {}


## Fire an aoe_on_death ability against the whole living party when its bearer
## dies. Resolves through execute_enemy_magic (non-elemental by default; element
## is cosmetic until party resistances exist). Returns per-slot
## [{slot, damage, type}] so the battle layer can emit damage signals.
static func execute_aoe_on_death(state: Node, enemy: Node, ability: Dictionary) -> Array:
	var results: Array = []
	var element: String = ability.get("element", "")
	var power: int = int(ability.get("spell_power", ability.get("power", 0)))
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		var r: Dictionary = execute_enemy_magic(state, enemy, i, element, power)
		results.append({"slot": i, "damage": r.get("damage", 0), "type": r.get("type", "miss")})
	return results


## Map a UI cursor index (0..living-1) to an actual _enemies array index.
## Returns -1 if no living enemies.
static func resolve_enemy_target(cursor: int, enemies: Array[Node]) -> int:
	var living: Array[int] = []
	for i: int in range(enemies.size()):
		if enemies[i].is_alive and not enemies[i].get_meta("untargetable", false):
			living.append(i)
	if living.is_empty():
		return -1
	return living[clampi(cursor, 0, living.size() - 1)]


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
	var attacker_row: String = member.get("row", "front")
	# Spirit enemies take 50% physical pre-DEF (GAP-008, bestiary/README.md:80).
	var pre_def: float = ModifierAggregator.physical_pre_def_mult(enemy.get_type())
	var dmg: int = DamageCalc.calculate_physical(
		atk, 1.0, target_def, is_crit, 1.0, attacker_row, "front", false, [], false, 1.0, pre_def
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
	# Enemy type-element bonus stacks multiplicatively with weakness (GAP-008).
	var interaction: float = ModifierAggregator.type_element_multiplier(enemy.get_type(), element)
	var dmg: int = DamageCalc.calculate_magic(
		mag, power, target_mdef, element_mod, interaction, [], []
	)

	if element_mod == 0.0:
		return {"hit": true, "damage": 0, "type": "immune"}
	if element_mod < 0.0:
		enemy.heal(dmg)
		return {"hit": true, "damage": dmg, "type": "absorb"}

	enemy.take_damage(dmg)
	return {"hit": true, "damage": dmg, "type": "magic", "killed": not enemy.is_alive}


## Execute an enemy magic ability against a party member.
## Uses MAG/MDEF formula. element_mod is 1.0 until party resistances exist.
static func execute_enemy_magic(
	state: Node, enemy: Node, target_slot: int, _element: String, power: int
) -> Dictionary:
	var stats: Dictionary = enemy.get_stats()
	var mag: int = stats.get("mag", 10)
	var spd: int = stats.get("spd", 10)
	var member: Dictionary = state.get_member(target_slot)
	if member.is_empty() or not member.get("is_alive", false):
		return {"hit": false, "damage": 0, "type": "miss"}
	var target_mdef: int = state.get_effective_stat(target_slot, "mdef")
	var target_spd: int = state.get_effective_stat(target_slot, "spd")
	if not DamageCalc.roll_hit(spd, target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	if DamageCalc.roll_evasion(target_spd):
		return {"hit": false, "damage": 0, "type": "miss"}
	var dmg_mult: float = member.get("damage_taken_mult", 1.0)
	var reduction: Array[float] = []
	if dmg_mult < 1.0:
		reduction.append(1.0 - dmg_mult)
	# element_mod 1.0 until party resistances are implemented
	var dmg: int = DamageCalc.calculate_magic(mag, power, target_mdef, 1.0, 1.0, [], reduction)
	state.take_damage(target_slot, dmg)
	return {"hit": true, "damage": dmg, "type": "magic"}


## Execute an enemy physical attack against a party member.
## [param ability_mult] scales base power (1.0 = basic attack; ability kits set
## higher per enemy-ability-conventions.md §2.1).
static func execute_enemy_attack(
	state: Node, enemy: Node, target_slot: int, ability_mult: float = 1.0
) -> Dictionary:
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

	var is_crit: bool = randf() < Enemy.ENEMY_CRIT_RATE
	var reduction: Array[float] = []
	var dmg_mult: float = member.get("damage_taken_mult", 1.0)
	if dmg_mult < 1.0:
		reduction.append(1.0 - dmg_mult)  # Convert mult to reduction source
	var defender_row: String = member.get("row", "front")
	var dmg: int = (
		DamageCalc
		. calculate_physical(
			atk,
			ability_mult,
			target_def,
			is_crit,
			1.0,
			"front",
			defender_row,
			false,
			reduction,
			false,
			1.0,
		)
	)
	state.take_damage(target_slot, dmg)
	var dtype: String = "critical" if is_crit else "physical"
	return {"hit": true, "damage": dmg, "type": dtype}


## Resolve a possibly multi-hit enemy physical ability against one member.
## Each hit rolls its own hit/evasion/crit (per enemy-ability-conventions.md
## §2.7). Returns the aggregate {hit, damage, type, hits_landed}. No Act I
## production enemy sets hits > 1 (first is the Act II Cave Vermin); the engine
## supports it and this path is test-covered.
static func execute_enemy_physical_ability(
	state: Node, enemy: Node, target_slot: int, ability_mult: float = 1.0, hits: int = 1
) -> Dictionary:
	var total: int = 0
	var landed: int = 0
	var any_crit: bool = false
	for _h: int in range(maxi(1, hits)):
		var r: Dictionary = execute_enemy_attack(state, enemy, target_slot, ability_mult)
		if r.get("hit", false):
			landed += 1
			total += int(r.get("damage", 0))
			if r.get("type", "") == "critical":
				any_crit = true
	# Report "critical" if ANY sub-hit crit, not just the last (which could miss).
	var dtype: String = "critical" if any_crit else "physical"
	return {"hit": landed > 0, "damage": total, "type": dtype, "hits_landed": landed}
