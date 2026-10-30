class_name BattleDamageMods
extends RefCounted
## What an attacker's own state does to the blows it deals: Despair's -20%
## damage dealt and Blind's -50% physical accuracy (#246 slice 3), and the
## element of a party member's equipped weapon (#513), and Smokescreen's cut to
## an enemy's hit rate (#158 slice d). And what a target's own state does to
## the blows it takes: Glintmark's mark on an enemy (#514), "+10% damage taken
## from all sources" (magic.md § 78 Glintmark).
##
## Rulings of 2026-10-30 (combat-formulas.md § Attacker Status Modifiers and
## § Physical Elemental Attacks): Despair cuts all damage its bearer deals —
## physical, magic, abilities, Shock Coil's ticks and Arc Trap's blast,
## counters — but no healing. Blind halves the bearer's physical hit rate, before the 20-99 clamp;
## spells keep theirs. Every physical strike through
## BattleActions.execute_party_attack (Attack, an auto-attack on an enemy,
## Riposte) carries the equipped weapon's element; when Overcharge also applies,
## the more favorable of the two decides. A confused member's blow on an ally,
## and Shatter Guard's fixed damage, carry no element.
##
## A combatant is passed as its BattleState member record (a Dictionary) or as
## its Enemy node: both hold "active_statuses" entries of {name, ...}.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## The Enemy.active_buffs stat Glintmark lowers: the enemy's resistance to
## damage, so a mark of 10% is a 0.9 entry and the blow lands at 1.1x. Being a
## debuff is what keeps Dispersion off it (Enemy.strip_buffs), as the party's
## mark on the enemy "wears off" only (magic.md § Status Effect Reference).
## get_stats never reads it.
const RESIST_STAT: String = "damage_resist"


## [param who]'s active statuses, whether a party member's record or an enemy.
static func statuses_of(who: Variant) -> Array:
	if who is Dictionary:
		return (who as Dictionary).get("active_statuses", [])
	if who is Object and is_instance_valid(who):
		var list: Variant = (who as Object).get("active_statuses")
		return list if list is Array else []
	return []


## The multiplier on all damage [param who] deals: 0.8 under Despair, else 1.0.
## It never touches healing.
static func dealt_mult(who: Variant) -> float:
	var mult: float = 1.0
	for s: Dictionary in statuses_of(who):
		mult *= StatusEffects.damage_dealt_mult(String(s.get("name", "")))
	return mult


## [param dmg], damage [param who] has already rolled outside the damage
## formulas (a fixed amount, or a heal turned to damage on an Undead), cut by
## its Despair, raised by a mark on [param target] (taken_mult), and floored.
static func cut_dealt(dmg: int, who: Variant, target: Variant = null) -> int:
	return int(floor(dmg * dealt_mult(who) * taken_mult(target)))


## The multiplier on all damage [param target] takes: 1.1 under Glintmark's
## mark (a RESIST_STAT debuff of 10%), else 1.0. Only an enemy carries one.
## It is a final-damage multiplier: step 6 of a physical blow and step 5 of a
## spell (combat-formulas.md § Combat Resolution Order).
static func taken_mult(target: Variant) -> float:
	if not (target is Object and is_instance_valid(target)):
		return 1.0
	if not (target as Object).has_method("buff_mult"):
		return 1.0
	# Whole percentages, so a 10% mark is exactly 110 / 100 and floors cleanly.
	var resist: float = float((target as Object).call("buff_mult", RESIST_STAT))
	return (200 - roundi(resist * 100.0)) / 100.0


## The step-5 buff modifiers on a spell [param caster] lands on [param target],
## for DamageCalc.calculate_magic: the caster's Despair and the target's mark.
static func spell_mults(caster: Variant, target: Variant) -> Array:
	return [dealt_mult(caster), taken_mult(target)]


## The multiplier on [param who]'s physical hit rate: 0.5 under Blind, times
## Smokescreen's 0.7 on an enemy under it (BattleTricks.SMOKESCREEN, carried as
## a debuff on the enemy's "accuracy"), else 1.0. Pass it to DamageCalc.roll_hit
## for a physical attack only.
static func accuracy_mult(who: Variant) -> float:
	var mult: float = 1.0
	for s: Dictionary in statuses_of(who):
		mult *= StatusEffects.physical_accuracy_mult(String(s.get("name", "")))
	if who is Object and is_instance_valid(who) and (who as Object).has_method("buff_mult"):
		mult *= float((who as Object).call("buff_mult", BattleTricks.ACCURACY_STAT))
	return mult


## The modifiers on [param slot]'s physical strike at [param enemy], as
## {mult, element_mod}: mult is the final-damage multiplier (step 6), an
## Overcharge's +50% times the striker's Despair and the enemy's mark
## (taken_mult); element_mod is there only when the strike is elemental — the
## Overcharge's (BattleForgewright.take_overcharge, spent here, hit or miss),
## else the equipped weapon's.
static func strike_mods(state: Node, slot: int, enemy: Node) -> Dictionary:
	var member: Dictionary = state.get_member(slot)
	var out: Dictionary = BattleForgewright.take_overcharge(state, slot, enemy)
	if out.is_empty():
		var element: String = weapon_element(String(member.get("character_id", "")))
		if not element.is_empty():
			out["element_mod"] = enemy.get_element_multiplier(element)
	out["mult"] = float(out.get("mult", 1.0)) * dealt_mult(member) * taken_mult(enemy)
	return out


## The modifiers on a Trick's strike by [param member] at [param enemy] carrying
## [param element] ("" for none), as strike_mods returns them: mult is the
## striker's Despair times the enemy's mark; element_mod is there only when the
## strike is elemental.
## A Trick's element is its thrown item's and never the weapon's, and it does
## not spend an Overcharge (abilities.md § Damage Magnitudes > 'Shiv', built in
## 158d).
static func trick_mods(member: Dictionary, enemy: Node, element: String) -> Dictionary:
	var out: Dictionary = {"mult": dealt_mult(member) * taken_mult(enemy)}
	if not element.is_empty():
		out["element_mod"] = enemy.get_element_multiplier(element)
	return out


## The element of the weapon [param character_id] wears, or "" when it has none.
static func weapon_element(character_id: String) -> String:
	var weapon: String = PartyState.get_member(character_id).get("equipment", {}).get("weapon", "")
	if weapon.is_empty():
		return ""
	for w: Variant in DataManager.load_equipment("weapons"):
		if w is Dictionary and (w as Dictionary).get("id", "") == weapon:
			var element: Variant = (w as Dictionary).get("element")
			return String(element) if element is String else ""
	return ""
