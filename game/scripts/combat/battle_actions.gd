extends RefCounted
## Battle action execution — physical attacks, magic, items, abilities.
##
## Extracted from battle_manager.gd under the script size budget
## (technical-architecture.md § 1.2a: aim 400 lines, hard maximum 600).
## All functions are static. They operate on battle_state and enemies
## via passed references.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Enemy = preload("res://scripts/entities/enemy.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")


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


## Roll an offensive spell's status [param rider] (`{status, chance}`) against
## [param enemy], whose damage the caller has already landed (#434). A rider is
## not the spell's hit_rate: magic.md § Derived Rules prices it at 30-50% and
## names it separately. It rolls Stage 1 only — `chance x MAG / (MAG + MDEF)` —
## because "damage spells skip the MEVA% check entirely" (progression.md
## § Derived Stats). Immunity is checked after the roll, the order given in
## combat-formulas.md § Status Spell Resolution. The status lands at its
## canonical duration. The caller owns the "landed and survived" check;
## an ability that inflicts a status on hit reuses this with the same shape.
## Returns {inflicted, type, status}; type is
## "status" | "resisted" | "immune" | "no_effect".
static func roll_status_rider(
	state: Node, caster_slot: int, rider: Dictionary, enemy: Node
) -> Dictionary:
	var status_name: String = str(rider.get("status", ""))
	if not StatusEffects.is_known(status_name):
		return {"inflicted": false, "type": "no_effect", "status": status_name}
	var caster_mag: int = state.get_effective_stat(caster_slot, "mag")
	var denom: int = caster_mag + int(enemy.get_stats().get("mdef", 0))
	var effective: int = 0
	if denom > 0:
		effective = int(int(rider.get("chance", 0)) * (float(caster_mag) / float(denom)))
	if randi() % 100 >= effective:
		return {"inflicted": false, "type": "resisted", "status": status_name}
	if enemy.is_immune_to_status(status_name):
		return {"inflicted": false, "type": "immune", "status": status_name}
	enemy.apply_status(status_name, StatusEffects.default_duration(status_name))
	return {"inflicted": true, "type": "status", "status": status_name}


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
	var kind: String = "realtime" if StatusEffects.is_realtime(status_name) else "turns"  # Stop
	state.apply_status(target_slot, status_name, kind, float(duration))
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
## [{slot, damage, type}], plus Edren's "absorbed" share where a stance took
## one, so the battle layer can emit damage signals.
static func execute_aoe_on_death(state: Node, enemy: Node, ability: Dictionary) -> Array:
	var results: Array = []
	var element: String = ability.get("element", "")
	var power: int = int(ability.get("spell_power", ability.get("power", 0)))
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		var r: Dictionary = execute_enemy_magic(state, enemy, i, element, power)
		var entry: Dictionary = {
			"slot": i, "damage": r.get("damage", 0), "type": r.get("type", "miss")
		}
		if r.has("absorbed"):
			entry["absorbed"] = r["absorbed"]
		results.append(entry)
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


## Execute a physical attack from a party member against an enemy, at
## [param ability_mult] (1.0 for the Attack command, 1.5 for Riposte's counter),
## which scales power before DEF; [param damage_mult] multiplies final damage
## (combat-formulas.md step 6), as does an Overcharge on the member, spent on
## it hit or miss (BattleForgewright.take_overcharge). Returns the damage dealt.
static func execute_party_attack(
	state: Node,
	slot: int,
	enemy: Node,
	_target_idx: int,
	ability_mult: float = 1.0,
	damage_mult: float = 1.0
) -> Dictionary:
	var member: Dictionary = state.get_member(slot)
	if member.is_empty() or not enemy.is_alive:
		return {"hit": false, "damage": 0, "type": "miss"}
	var charge: Dictionary = Forgewright.take_overcharge(state, slot, enemy)
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
	# Spirit enemies take 50% physical pre-DEF (GAP-008, bestiary/README.md § Spirit).
	var pre_def: float = ModifierAggregator.physical_pre_def_mult(enemy.get_type())
	var dmg: int = DamageCalc.calculate_physical(
		atk,
		ability_mult,
		target_def,
		is_crit,
		damage_mult * float(charge.get("mult", 1.0)),
		attacker_row,
		"front",
		false,
		[],
		not charge.is_empty(),
		float(charge.get("element_mod", 1.0)),
		pre_def
	)
	return Forgewright.land_strike(enemy, dmg, "critical" if is_crit else "physical", charge)


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
	var reduction: Array[float] = Bulwark.reductions(state, target_slot, "magic")
	if dmg_mult < 1.0:
		reduction.append(1.0 - dmg_mult)
	var guard: Dictionary = Bulwark.guard_for(state, target_slot, "magic")
	# element_mod 1.0 until party resistances are implemented
	var dmg: int = DamageCalc.calculate_magic(
		mag, power, target_mdef, 1.0, 1.0, [], reduction if guard.is_empty() else []
	)
	return _land_on_party(state, target_slot, dmg, reduction, guard, "magic", enemy)


## Land [param enemy]'s hit of [param dmg] on [param slot]. Unguarded,
## [param dmg] already carries the member's reductions. Met by a Bulwark stance
## (BattleBulwark.guard_for) it is the hit before them, and BattleBulwark.split
## divides it: the member takes the rest, Edren absorbs his share, reported as
## "absorbed": {slot, damage}. A hit on Edren himself in a stance counts as
## absorbed but splits nothing off. If he then counters (Riposte), the counter
## is in "ripostes": [{slot, hit, damage, type, killed}], and a landed counter
## earns him 1 AP.
static func _land_on_party(
	state: Node,
	slot: int,
	dmg: int,
	reduction: Array[float],
	guard: Dictionary,
	dtype: String,
	enemy: Node
) -> Dictionary:
	if guard.is_empty():
		dmg = state.take_damage(slot, dmg)  # after Unbreakable, as applied
		return {"hit": true, "damage": dmg, "type": dtype}
	var shares: Dictionary = Bulwark.split(dmg, reduction, guard)
	var edren: int = int(guard["slot"])
	var out: Dictionary = {"hit": true, "type": dtype}
	if edren == slot:  # a direct hit: counted before it lands, as a share is
		Bulwark.count_absorbed(state, edren, int(shares["damage"]), dmg)
		out["damage"] = state.take_damage(slot, int(shares["damage"]))
	else:
		out["damage"] = state.take_damage(slot, int(shares["damage"]))
		var taken: int = Bulwark.absorb(state, guard, int(shares["absorbed"]), dmg)
		out["absorbed"] = {"slot": edren, "damage": taken}
	if enemy.is_alive and Bulwark.take_riposte(state, edren):
		var counter: Dictionary = execute_party_attack(
			state, edren, enemy, -1, Bulwark.RIPOSTE_ABILITY_MULT
		)
		if counter.get("hit", false):
			Bulwark.gain_ap(state, edren, 1)  # "Grants 1 AP on hit"
		counter["slot"] = edren
		out["ripostes"] = [counter]
	return out


## Execute an enemy physical attack against a party member.
## [param ability_mult] scales base power (1.0 = basic attack; ability kits set
## higher per enemy-ability-conventions.md §2.1); [param damage_mult]
## multiplies final damage (combat-formulas.md step 6).
static func execute_enemy_attack(
	state: Node, enemy: Node, target_slot: int, ability_mult: float = 1.0, damage_mult: float = 1.0
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
	reduction.append_array(Forgewright.reductions(state, target_slot, "physical"))  # Bulkhead
	var defender_row: String = member.get("row", "front")
	var guard: Dictionary = Bulwark.guard_for(state, target_slot, "physical")
	var dmg: int = (
		DamageCalc
		. calculate_physical(
			atk,
			ability_mult,
			target_def,
			is_crit,
			damage_mult,
			"front",
			defender_row,
			false,
			reduction if guard.is_empty() else [],
			false,
			1.0,
		)
	)
	var dtype: String = "critical" if is_crit else "physical"
	return _land_on_party(state, target_slot, dmg, reduction, guard, dtype, enemy)


## Resolve a possibly multi-hit enemy physical ability against one member.
## Each hit rolls its own hit/evasion/crit (enemy-ability-conventions.md §2.7),
## and the flurry stops once a counter fells the attacker. Returns the aggregate
## {hit, damage, type, hits_landed}, with "absorbed" (Edren's shares summed) and
## "ripostes": every counter — Riposte, Thornveil Barrier per landed hit, then
## one Arc Trap for the attack (BattleForgewright). No Act I production enemy
## sets hits > 1 (first is the Act II Cave Vermin); this path is test-covered.
static func execute_enemy_physical_ability(
	state: Node, enemy: Node, target_slot: int, ability_mult: float = 1.0, hits: int = 1
) -> Dictionary:
	var total: int = 0
	var landed: int = 0
	var any_crit: bool = false
	var absorbed: Dictionary = {}
	var ripostes: Array = []
	for _h: int in range(maxi(1, hits)):
		if not enemy.is_alive:  # a Riposte felled the attacker mid-flurry
			break
		var r: Dictionary = execute_enemy_attack(state, enemy, target_slot, ability_mult)
		if r.get("hit", false):
			landed += 1
			total += int(r.get("damage", 0))
			any_crit = any_crit or r.get("type", "") == "critical"
			r["ripostes"] = r.get("ripostes", []) + Forgewright.thorns(state, enemy, target_slot)
		if r.has("absorbed"):  # each hit is absorbed on its own; the shares add
			var share: Dictionary = r["absorbed"]
			absorbed = {
				"slot": share["slot"],
				"damage": int(absorbed.get("damage", 0)) + int(share["damage"]),
			}
		ripostes.append_array(r.get("ripostes", []))
	ripostes.append_array(Forgewright.spring_trap(state, enemy))  # any physical attack (Arc Trap)
	# Report "critical" if ANY sub-hit crit, not just the last (which could miss);
	# a flurry that lands nothing is a "miss", shown as Miss rather than 0 (#500).
	var dtype: String = "miss" if landed == 0 else ("critical" if any_crit else "physical")
	var out: Dictionary = {"hit": landed > 0, "damage": total, "type": dtype, "hits_landed": landed}
	if not absorbed.is_empty():
		out["absorbed"] = absorbed
	if not ripostes.is_empty():
		out["ripostes"] = ripostes
	return out
