class_name BattleSpiritcall
extends RefCounted
## Torren's Spiritcall while it is in force (GAP-002, #158 slice e): Spirit
## Favor and what earns or loses it, the Favor 3 forms, and the two wards a
## spirit leaves on an ally — Thornveil's thorn barrier and Stoneheart's status
## immunity. Pure static rules over BattleState's member records, reached
## through BattleState's ability-hook fan-out, from BattleWards where an enemy
## hit resolves, from BattleState.apply_status as a status would land, and from
## BattleSpiritcallCommand, which resolves the casts.
##
## Design law: abilities.md § Torren — Spiritcall and abilities.md § Damage
## Magnitudes, with the readings posted on #158 (2026-10-30), recorded in full
## in abilities.md § Torren — Spiritcall. The ones this file carries:
##   - Harmony is a Flame weakness hit, Greyveil hitting a Pallor, a thorn
##     counter felling its attacker, Stoneheart keeping a status off, and a heal
##     on an ally below 25% HP. The Chorus earns none; Rootsong raises every
##     spirit by 1 directly and is not a harmony.
##   - A spirit earns at most 1 Favor a battle, however many of its uses are in
##     harmony (the 15-20 battles abilities.md § Balance Targets sets).
##   - A spirit's form is read once, as its cast begins (form): the cast that
##     reaches Favor 3 resolves in the old form, and the next one is upgraded.
##   - A flight costs each spirit called that battle 1 Favor, once, unless it is
##     at Favor 3, which is permanent.
##
## Each ward is counted on its bearer's own turns, one more when Torren casts it
## on himself, as a Rally's copy and a spell buff are; one of a kind keeps the
## stronger, and a KO ends both, as it ends every positive effect (2026-10-29
## ruling). Torren's record carries member["spiritcall"]: {summoned, once,
## earned}; a bearer's wards are member["spirit_wards"]: {barrier, immunity}.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## Torren's five spirits, by the id of the ability that calls each. Favor is
## kept per spirit under these ids.
const SPIRITS: Array[String] = ["thornveil", "dewfall", "ember_wing", "stoneheart", "greyveil"]

## The Spiritcall abilities this slice resolves. Purify needs the corrupted
## spirit calls of abilities.md § The Pallor's Effect on Magic, which nothing
## models yet.
const BUILT: Array[String] = [
	"thornveil",
	"dewfall",
	"ember_wing",
	"stoneheart",
	"greyveil",
	"convergence_chorus",
	"rootsong",
]

## The filled and empty Favor pip (ui-design.md § 2.7: "small dots: 0-3
## filled").
const PIP_FILLED: String = "●"
const PIP_EMPTY: String = "○"

# ---------- Favor ----------


## [param spirit]'s Favor, 0-3.
static func favor(spirit: String) -> int:
	return int(PartyState.spirit_favor.get(spirit, 0))


## Move [param spirit]'s Favor by [param delta]; PartyState holds it to 0-3.
static func add_favor(spirit: String, delta: int) -> void:
	var table: Dictionary = PartyState.spirit_favor.duplicate()
	table[spirit] = favor(spirit) + delta
	PartyState.spirit_favor = table


## Whether [param ability] is a spirit's and that spirit is at Favor 3, so the
## upgraded form resolves.
static func upgraded(ability: Dictionary) -> bool:
	var id: String = ability.get("id", "")
	return id in SPIRITS and favor(id) >= PartyVitals.FAVOR_MAX


## [param ability] in the form its spirit's Favor gives it now, as one snapshot:
## at Favor 3 its `favor3` record (the name, target, cures and riders that
## change) and its `<key>_favor3` magnitudes (power, counter) replace the base
## values; an upgrade that leaves a value alone keeps it. A cast reads this
## once, before anything it does can raise the Favor.
static func form(ability: Dictionary) -> Dictionary:
	var out: Dictionary = ability.duplicate(true)
	if not upgraded(ability):
		return out
	for key: String in ability.keys():
		if key.ends_with("_favor3"):
			out[key.trim_suffix("_favor3")] = ability[key]
	out.merge(ability.get("favor3", {}), true)
	return out


## The name [param ability] goes by now: Deeproot Veil for Thornveil at Favor 3
## and so on. Any other ability keeps its own.
static func display_name(ability: Dictionary) -> String:
	return String(form(ability).get("name", ""))


## The target [param ability] takes now: Torrent's Grace and Mountain's Resolve
## reach every ally.
static func target_of(ability: Dictionary) -> String:
	return String(form(ability).get("target", "single_enemy"))


## What the battle menu lists [param ability] as: a spirit's current name and its
## Favor pips; anything else, its name.
static func menu_name(ability: Dictionary) -> String:
	var id: String = ability.get("id", "")
	if not id in SPIRITS:
		return display_name(ability)
	var filled: int = favor(id)
	var pips: String = PIP_FILLED.repeat(filled) + PIP_EMPTY.repeat(PartyVitals.FAVOR_MAX - filled)
	return "%s %s" % [display_name(ability), pips]


## A use of [param spirit] by Torren at [param slot] in [param state]: the
## record its wards carry, so harmony long after the cast (a counter, a block)
## credits the battle it was cast in. "" for a use that earns none (the Chorus).
static func new_cast(state: Node, slot: int, spirit: String) -> Dictionary:
	return {"spirit": spirit, "battle": _record(state.get_member(slot))}


## [param cast] was in harmony: its spirit gains 1 Favor, unless it has already
## gained one this battle.
static func harmony(cast: Dictionary) -> void:
	var spirit: String = String(cast.get("spirit", ""))
	var battle: Dictionary = cast.get("battle", {})
	var earned: Array = battle.get("earned", [])
	if spirit.is_empty() or spirit in earned:
		return
	earned.append(spirit)
	battle["earned"] = earned
	add_favor(spirit, 1)


# ---------- One battle ----------


## Whether [param member] could issue [param ability] now, cost aside: built,
## and a once-per-battle one not yet used this battle.
static func can_issue(member: Dictionary, ability: Dictionary) -> bool:
	var id: String = ability.get("id", "")
	if not id in BUILT:
		return false
	return not (ability.get("once_per_battle", false) and id in _record(member).get("once", []))


## Torren at [param slot] has issued [param ability], calling [param spirits]:
## the battle remembers both, for once-per-battle and for a flight.
static func mark_used(state: Node, slot: int, ability: Dictionary, spirits: Array) -> void:
	var rec: Dictionary = _record(state.get_member(slot))
	var once: Array = rec.get("once", [])
	if ability.get("once_per_battle", false):
		once.append(ability["id"])
	rec["once"] = once
	var summoned: Array = rec.get("summoned", [])
	for spirit: Variant in spirits:
		if not spirit in summoned:
			summoned.append(spirit)
	rec["summoned"] = summoned


## The party fled the battle in [param state]: every spirit called in it below
## Favor 3 loses 1 Favor, once ("spirits don't appreciate being abandoned"; a
## Favor 3 upgrade is permanent). The record is spent, so a second report of the
## same flight costs nothing.
static func on_fled(state: Node) -> void:
	for i: int in range(4):
		var rec: Dictionary = state.get_member(i).get("spiritcall", {})
		for spirit: Variant in rec.get("summoned", []):
			if favor(String(spirit)) < PartyVitals.FAVOR_MAX:
				add_favor(String(spirit), -1)
		rec["summoned"] = []


# ---------- Wards ----------


## Give [param slot] a thorn barrier from Torren at [param caster]:
## [param counter_pct] of the bearer's DEF back at each physical attacker, and
## [param reduction_pct] off every enemy hit, for [param turns]. A weaker
## barrier leaves a stronger one standing. Returns whether it landed.
static func grant_barrier(
	state: Node,
	slot: int,
	caster: int,
	counter_pct: int,
	reduction_pct: int,
	turns: int,
	cast: Dictionary
) -> bool:
	var ward: Dictionary = {
		"counter_pct": counter_pct,
		"reduction_pct": reduction_pct,
		"caster": caster,
		"cast": cast,
	}
	return _grant(state, slot, "barrier", ward, turns, counter_pct)


## Give [param slot] immunity to negative statuses for [param turns]. A shorter
## one leaves a longer one standing. Returns whether it landed.
static func grant_immunity(state: Node, slot: int, turns: int, cast: Dictionary) -> bool:
	return _grant(state, slot, "immunity", {"cast": cast}, turns, 0)


## [param slot]'s ward of [param kind], or {} when none stands.
static func ward(state: Node, slot: int, kind: String) -> Dictionary:
	return state.get_member(slot).get("spirit_wards", {}).get(kind, {})


## Thorn barriers answering a physical hit that landed on [param target]: the
## barrier's share of the target's Defense, as fixed damage, back at
## [param enemy], cut by Torren's Despair, never below 1 — as Lira's Thornveil
## Barrier, which "functions identically" (abilities.md § Cross-Training). A
## counter that fells the attacker is Thornveil in harmony. Returns the counter
## in BattleActions' "ripostes" shape.
static func thorns(state: Node, enemy: Node, target: int) -> Array:
	var barrier: Dictionary = ward(state, target, "barrier")
	if barrier.is_empty() or not enemy.is_alive:
		return []
	var raw: int = state.get_effective_stat(target, "def") * int(barrier["counter_pct"]) / 100
	var caster: int = int(barrier["caster"])
	var dmg: int = maxi(1, BattleDamageMods.cut_dealt(raw, state.get_member(caster)))
	enemy.take_damage(dmg)
	if not enemy.is_alive:
		harmony(barrier["cast"])
	return [
		{
			"slot": caster,
			"hit": true,
			"damage": dmg,
			"type": "physical",
			"killed": not enemy.is_alive
		}
	]


## The flat reductions a barrier puts on [param target] against any enemy hit,
## as fractions for DamageCalc: Deeproot Veil's 15%. [param _kind] is the hit's
## kind; "incoming damage" names none.
static func reductions(state: Node, target: int, _kind: String) -> Array[float]:
	var out: Array[float] = []
	var pct: int = int(ward(state, target, "barrier").get("reduction_pct", 0))
	if pct > 0:
		out.append(pct / 100.0)
	return out


## Whether a Stoneheart ward keeps [param status] off party [param slot] of
## [param state]. A pure query: BattleStatusGuard.ward_against asks it after the
## gear, and BattleState.apply_status credits the block (credit_block).
static func wards_off(state: Node, slot: int, status: String) -> bool:
	return not StatusEffects.is_positive(status) and not ward(state, slot, "immunity").is_empty()


## A Stoneheart ward on [param slot] has just kept a status off: Stoneheart in
## harmony.
static func credit_block(state: Node, slot: int) -> void:
	var immunity: Dictionary = ward(state, slot, "immunity")
	if not immunity.is_empty():
		harmony(immunity["cast"])


# ---------- BattleState ability hooks ----------


static func on_damage(_state: Node, _slot: int, amount: int) -> int:
	return amount


## A member fainted: its wards end.
static func on_fainted(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	if (m.get("spirit_wards", {}) as Dictionary).is_empty():
		return
	m["spirit_wards"] = {}
	state.ability_state_changed.emit(slot)


static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


static func on_turn_begin(_state: Node, _slot: int) -> Array:
	return []


## End of a member's turn: count each of its wards down, ending the ones that
## run out.
static func on_turn_end(state: Node, slot: int) -> void:
	var wards: Dictionary = state.get_member(slot).get("spirit_wards", {})
	var ended: bool = false
	for kind: String in wards.keys():
		wards[kind]["turns"] = int(wards[kind]["turns"]) - 1
		if int(wards[kind]["turns"]) <= 0:
			wards.erase(kind)
			ended = true
	if ended:
		state.ability_state_changed.emit(slot)


static func stat_pct(_m: Dictionary, _stat: String) -> int:
	return 0


# ---------- Internals ----------


## Land [param ward] of [param kind] on [param slot] for [param turns], unless a
## standing one has a greater [param strength]. A fallen member takes none.
static func _grant(
	state: Node, slot: int, kind: String, ward: Dictionary, turns: int, strength: int
) -> bool:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty() or not m.get("is_alive", false):
		return false
	var wards: Dictionary = m.get("spirit_wards", {})
	var held: Dictionary = wards.get(kind, {})
	turns += 1 if m.get("turn_open", false) else 0
	if kind == "immunity":
		strength = turns  # the longer immunity is the stronger: compare what is left
	var held_strength: int = int(held.get("turns" if kind == "immunity" else "strength", 0))
	if not held.is_empty() and held_strength > strength:
		return false
	ward["strength"] = strength
	ward["turns"] = turns
	wards[kind] = ward
	m["spirit_wards"] = wards
	state.ability_state_changed.emit(slot)
	return true


## The member's Spiritcall record, created on first use.
static func _record(m: Dictionary) -> Dictionary:
	if not m.has("spiritcall"):
		m["spiritcall"] = {}
	return m["spiritcall"]
