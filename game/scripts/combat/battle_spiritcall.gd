class_name BattleSpiritcall
extends RefCounted
## Torren's Spiritcall while it is in force (GAP-002, #158 slice e): Spirit
## Favor and what earns or loses it, the Favor 3 forms, and the two wards a
## spirit leaves on an ally — Thornveil's thorn barrier and Stoneheart's status
## immunity. Pure static rules over BattleState's member records, reached
## through BattleState's ability-hook fan-out, from BattleWards where an enemy
## hit resolves, from BattleStatusGuard as a status would land, and from
## BattleSpiritcallCommand, which resolves the casts.
##
## Design law: abilities.md § Torren — Spiritcall and § Damage Magnitudes, with
## the orchestrator readings on #158 (2026-10-30):
##   1. Only the three listed conditions are harmony. Convergence Chorus earns
##      no Favor; Rootsong raises every spirit by 1 directly, once per battle,
##      and is not itself a harmony.
##   2. "Matching a weakness" is at least one living target hit being weak to
##      the element. Greyveil, which has none, is in harmony when it hits a
##      Pallor enemy.
##   3. "Protecting an ally from death" is Thornveil's counter felling its
##      attacker, or Stoneheart keeping a status off.
##   4. Favor persists per spirit in PartyState.spirit_favor and the save.
##   5. A fled battle costs each spirit used in it 1 Favor, once.
##   6. At Favor 3 a spirit's ability is its upgraded form, by that name.
## A use of a spirit's ability earns at most 1 Favor ("increases by 1 when the
## spirit's ability is used in harmony"), however many of its targets or blocks
## are in harmony. Favor is read as the cast begins, so the Favor 3 form starts
## with the next cast after the third point.
##
## Each ward is counted on its bearer's own turns, one more when the bearer's
## turn is open (a self-cast), as a Rally's copy and a spell buff are; one of a
## kind keeps the stronger, and a KO ends both, as it ends every positive effect
## (2026-10-29 ruling). Torren's record carries member["spiritcall"]: {summoned,
## once}; a bearer's wards are member["spirit_wards"]: {barrier, immunity}.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## Torren's five spirits, by the id of the ability that calls each. Favor is
## kept per spirit under these ids.
const SPIRITS: Array[String] = ["thornveil", "dewfall", "ember_wing", "stoneheart", "greyveil"]

## The Spiritcall abilities this slice resolves. Purify needs the Pallor-zone
## corruption of abilities.md § Spirit Communion, which nothing models yet.
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

## Party-side BattleStates by the id of each character seated in them, held
## weakly so a battle that has ended blocks nothing. BattleStatusGuard.blocks
## is asked with a character id alone, and this is how it finds the record that
## carries a Stoneheart ward. One battle runs at a time, so one entry each.
static var _seated: Dictionary = {}

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


## [param key] of [param ability] in its current form. At Favor 3 that is the
## upgraded form's: its `favor3` record (the name, target, cures and riders that
## change), else the `<key>_favor3` magnitude (power, counter), else the base
## value, which an upgrade that leaves it alone keeps.
static func field(ability: Dictionary, key: String, default: Variant = null) -> Variant:
	if upgraded(ability):
		var form: Dictionary = ability.get("favor3", {})
		if form.has(key):
			return form[key]
		if ability.has(key + "_favor3"):
			return ability[key + "_favor3"]
	return ability.get(key, default)


## The name [param ability] goes by now: Deeproot Veil for Thornveil at Favor 3
## and so on. Any other ability keeps its own.
static func display_name(ability: Dictionary) -> String:
	return String(field(ability, "name", ""))


## The target [param ability] takes now: Torrent's Grace and Mountain's Resolve
## reach every ally.
static func target_of(ability: Dictionary) -> String:
	return String(field(ability, "target", "single_enemy"))


## What the battle menu lists [param ability] as: a spirit's current name and its
## Favor pips; anything else, its name.
static func menu_name(ability: Dictionary) -> String:
	var id: String = ability.get("id", "")
	if not id in SPIRITS:
		return display_name(ability)
	var filled: int = favor(id)
	var pips: String = PIP_FILLED.repeat(filled) + PIP_EMPTY.repeat(PartyVitals.FAVOR_MAX - filled)
	return "%s %s" % [display_name(ability), pips]


## A new use of [param spirit] in harmony or not: the record its wards share, so
## the use earns at most 1 Favor. "" for a use that earns none (the Chorus).
static func new_cast(spirit: String) -> Dictionary:
	return {"spirit": spirit, "earned": false}


## [param cast] was in harmony: its spirit gains 1 Favor, the first time only.
static func harmony(cast: Dictionary) -> void:
	if String(cast.get("spirit", "")).is_empty() or cast.get("earned", false):
		return
	cast["earned"] = true
	add_favor(String(cast["spirit"]), 1)


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


## The party fled the battle in [param state]: every spirit called in it loses
## 1 Favor, once ("spirits don't appreciate being abandoned").
static func on_fled(state: Node) -> void:
	for i: int in range(4):
		for spirit: Variant in state.get_member(i).get("spiritcall", {}).get("summoned", []):
			add_favor(String(spirit), -1)


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
	if not _grant(state, slot, "immunity", {"cast": cast}, turns, 0):
		return false
	_seated[String(state.get_member(slot).get("character_id", ""))] = weakref(state)
	return true


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


## Whether a Stoneheart ward keeps [param status] off [param character_id] in
## the battle running now. A ward that does is in harmony. BattleStatusGuard
## asks this as the status would land, after the gear check.
static func wards_off(character_id: String, status: String) -> bool:
	var ref: WeakRef = _seated.get(character_id)
	var state: Node = ref.get_ref() if ref != null else null
	if state == null or StatusEffects.is_positive(status):
		return false
	for i: int in range(4):
		if state.get_member(i).get("character_id", "") != character_id:
			continue
		var immunity: Dictionary = ward(state, i, "immunity")
		if immunity.is_empty():
			return false
		harmony(immunity["cast"])
		return true
	return false


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
