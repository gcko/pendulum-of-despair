class_name BattleEnemyHeal
extends RefCounted
## A party heal landing on an enemy, at once or as Regen over its turns (#503).
## The rules are the same for both: a normal enemy is healed, and an Undead or
## a Pallor takes the heal as damage. Pure rules over the battle's public
## seams (its enemies, BattleState, ATB and the damage_dealt / combatant_died
## signals); BattleMagicCommand casts, BattleEnemyTurn ticks.
##
## The damage form is the heal as rolled, with no hit roll and no element or
## type multiplier, cut by the caster's Despair (BattleDamageMods, #246), and
## it counts as spell damage: threat for the caster, the number shown over the
## enemy, and a kill handled like any other.
##
## Regen on an enemy (Kindle Breath turned on the enemy line) ticks the way a
## heal on that enemy lands (owner ruling, #503): `regen_pct` of its max HP,
## at least 1, at the end of each of its own turns for the spell's `duration`.
## It is kept as an enemy buff of kind REGEN (Enemy.apply_buff), so it counts
## down on the enemy's turns with its other buffs, a recast refreshes it, and
## Dispersion strips it, as the Regen row's "Cured By" names
## (magic.md § Status Effect Reference). The entry also records the caster's
## slot, whose Despair is read when each tick lands.

## Enemy types a heal hurts instead of heals, for exactly the HP it would have
## restored: Undead ("Healing spells deal damage", bestiary/README.md § Undead)
## and Pallor (Pallor Feedback, combat-formulas.md § Tier 2).
const HEAL_REVERSING_TYPES: Array[String] = ["undead", "pallor"]

## The Enemy.active_buffs kind for Regen. get_stats never reads it.
const REGEN: String = "regen"


## Land [param heal_amt] of [param caster_slot]'s healing on enemy
## [param idx]. [param wakes] is false for a Regen tick, which like a Poison
## tick does not cure Sleep or Confusion (Enemy.take_damage). Returns whether
## it dealt damage, which is what earns the cast Weave Gauge: healing an enemy
## earns none (2026-10-29 ruling).
static func land(
	battle: Node, caster_slot: int, heal_amt: int, idx: int, wakes: bool = true
) -> bool:
	var enemy: Node = battle.get_enemies()[idx]
	if enemy.get_type() in HEAL_REVERSING_TYPES:
		var member: Dictionary = battle.get_battle_state().get_member(caster_slot)
		heal_amt = BattleDamageMods.cut_dealt(heal_amt, member)
		enemy.take_damage(heal_amt, wakes)
		land_spell_damage(battle, caster_slot, heal_amt, idx)
		return heal_amt > 0
	var before: int = enemy.current_hp
	enemy.heal(heal_amt)
	if enemy.current_hp > before:
		battle.damage_dealt.emit("enemy_%d" % idx, enemy.current_hp - before, "heal")
	return false


## Book [param dmg] of spell damage already dealt to enemy [param idx]: the
## caster's threat (GAP-009 highest-threat), the number shown over the enemy,
## and the kill if it fell.
static func land_spell_damage(battle: Node, caster_slot: int, dmg: int, idx: int) -> void:
	battle.get_battle_state().add_threat(caster_slot, dmg)
	battle.damage_dealt.emit("enemy_%d" % idx, dmg, "magic")
	if not battle.get_enemies()[idx].is_alive:
		battle.combatant_died.emit("enemy_%d" % idx)
		battle.get_atb().remove_combatant("enemy_%d" % idx)


## Land [param spell]'s Regen, cast from [param caster_slot], on enemy
## [param idx]. Returns whether the cast earns Weave Gauge: only where the
## Regen will deal damage, on an Undead or a Pallor.
static func grant_regen(battle: Node, caster_slot: int, spell: Dictionary, idx: int) -> bool:
	var enemy: Node = battle.get_enemies()[idx]
	var pct: int = int(spell.get("regen_pct", 0))
	enemy.apply_buff(REGEN, 1.0 + pct / 100.0, int(spell.get("duration", 0)))
	_regen_entry(enemy)["caster"] = caster_slot
	return enemy.get_type() in HEAL_REVERSING_TYPES


## End of [param enemy]'s turn (enemy [param idx]): its Regen, if any, lands
## one tick. BattleEnemyTurn calls this before Enemy.tick_buffs counts it down.
## An enemy with no Regen asks nothing of [param battle].
static func tick_regen(battle: Node, enemy: Node, idx: int) -> void:
	var entry: Dictionary = _regen_entry(enemy)
	if entry.is_empty() or not enemy.is_alive:
		return
	var pct: int = roundi((float(entry.get("mult", 1.0)) - 1.0) * 100.0)
	var amount: int = maxi(1, int(enemy.enemy_data.get("hp", 0)) * pct / 100)
	land(battle, int(entry.get("caster", 0)), amount, idx, false)


## [param enemy]'s Regen entry in active_buffs, or {} when it has none.
static func _regen_entry(enemy: Node) -> Dictionary:
	for b: Dictionary in enemy.active_buffs:
		if b.get("stat", "") == REGEN:
			return b
	return {}
