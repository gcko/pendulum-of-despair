class_name BattleWards
extends RefCounted
## What stands on a party member against an enemy hit, from every source that
## puts something there: the thorns that answer a physical hit and the flat
## reductions that cut it — Lira's devices (BattleForgewright) and Torren's
## spirit barriers (BattleSpiritcall). BattleActions asks here, so a new source
## joins in one place rather than at each seam.


## Every thorn counter answering a physical hit that landed on [param target]
## from [param enemy], in BattleActions' "ripostes" shape: Lira's Thornveil
## Barrier first, then Torren's thorn barrier, which a felled attacker skips.
static func thorns(state: Node, enemy: Node, target: int) -> Array:
	var out: Array = BattleForgewright.thorns(state, enemy, target)
	out.append_array(BattleSpiritcall.thorns(state, enemy, target))
	return out


## Every flat reduction on [param target] against a [param kind] hit, as
## fractions for DamageCalc: Bulkhead's 40% (physical) and Deeproot Veil's 15%.
static func reductions(state: Node, target: int, kind: String) -> Array[float]:
	var out: Array[float] = BattleForgewright.reductions(state, target, kind)
	out.append_array(BattleSpiritcall.reductions(state, target, kind))
	return out
