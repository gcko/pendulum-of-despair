extends RefCounted
## Debuff spells turned on an enemy (#514): a stat penalty that rolls to hit,
## the dispel that strips an enemy's positive effects and always lands, and
## Glintmark's mark. Pure rules over one enemy; BattleMagicCommand owns the
## cast and what the player is shown.
##
## The keys are each spell's own data, valued from its magic.md entry:
##   - `stat_debuff: {stat, pct}` lowers one stat by `pct`% for the spell's
##     `duration` turns (Sunder DEF, Fray MDEF, Dampening Field MAG: 30 for 5).
##     Drag Tide's stat is "atb_fill", the gauge's fill speed (30 for 5), which
##     get_stats never reads, so no hit or evasion roll sees it; the battle's
##     enemy gauge resync reads it as a fill multiplier.
##     It rolls the spell's `hit_rate` through the two-stage status roll, as
##     "debuff spells ... also roll to hit and use the standard band"
##     (magic.md § Derived Rules), and lands as an enemy stat buff of the
##     other direction (Enemy.apply_buff), so it counts down on the enemy's
##     own turns and adds to a buff on the same stat.
##   - `dispel: true` (Dispersion, Mass Dispersion) removes "all positive
##     status effects (buffs)": every stat buff above 1x and every positive
##     status (Haste). A debuff the party laid stays, as "Player-side
##     Dispersion removes enemy buffs, not friendly ones" (magic.md § Status
##     Effect Reference).
##   - `damage_taken_pct` (Glintmark, 10 for 3) marks the enemy: it takes that
##     much more damage from every blow for the spell's `duration` turns of its
##     own (BattleDamageMods.taken_mult). The mark has no hit rate and always
##     lands. It is kept as a debuff on BattleDamageMods.RESIST_STAT, so it
##     counts down on the enemy's turns, a recast refreshes it, and Dispersion
##     leaves it on: it is the party's, and "wears off" only.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")


## Whether [param spell] carries a stat_debuff, a dispel or a mark.
static func has_effect(spell: Dictionary) -> bool:
	if spell.get("damage_taken_pct") != null:
		return true
	return spell.get("stat_debuff") is Dictionary or bool(spell.get("dispel", false))


## Land [param spell]'s effect on [param enemy], cast by [param caster_mag].
## Returns "debuffed", "dispelled", "missed" (the hit roll failed) or
## "no_effect" (a dispel found nothing to remove).
static func land(caster_mag: int, spell: Dictionary, enemy: Node) -> String:
	if bool(spell.get("dispel", false)):
		return "dispelled" if dispel(enemy) > 0 else "no_effect"
	var turns: int = int(spell.get("duration", 0))
	if spell.get("damage_taken_pct") != null:
		var mark: float = 1.0 - int(spell["damage_taken_pct"]) / 100.0
		enemy.apply_buff(BattleDamageMods.RESIST_STAT, mark, turns)
		return "debuffed"
	var debuff: Dictionary = spell.get("stat_debuff", {})
	var stats: Dictionary = enemy.get_stats()
	var rate: int = int(spell.get("hit_rate", 0))
	if not DamageCalc.roll_status(rate, caster_mag, stats.get("mdef", 0), stats.get("spd", 0)):
		return "missed"
	var mult: float = 1.0 - int(debuff.get("pct", 0)) / 100.0
	enemy.apply_buff(str(debuff.get("stat", "")), mult, turns)
	return "debuffed"


## Strip [param enemy]'s positive effects: its stat buffs above 1x
## (Enemy.strip_buffs) and its positive statuses (Haste), each status through
## remove_status so the battle hears it end. Returns how many effects went.
static func dispel(enemy: Node) -> int:
	var removed: int = enemy.strip_buffs()
	var positive: Array[String] = []
	for s: Dictionary in enemy.active_statuses:
		if StatusEffects.is_positive(s.get("name", "")):
			positive.append(s.get("name", ""))
	for status_name: String in positive:
		enemy.remove_status(status_name)
		removed += 1
	return removed
