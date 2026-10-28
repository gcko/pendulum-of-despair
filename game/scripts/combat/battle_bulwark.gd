class_name BattleBulwark
extends RefCounted
## Edren's Bulwark (GAP-002, #158 slice b): stances that absorb damage meant for
## an ally, the Aegis Points (AP) absorbing earns, and the Bulwark abilities
## that spend them. Pure static rules over BattleState's member records, reached
## through BattleState's ability-hook fan-out (on_damage, on_fainted, on_status,
## on_turn_begin, on_turn_end, stat_pct) and, where an enemy hit resolves, from
## BattleActions (guard_for, absorb, reductions).
##
## Design law: abilities.md § Edren — Bulwark; combat-formulas.md § Damage
## Reduction Sources and its "Absorption vs flat reduction" note.
##
## Edren's record carries the stance in member["active_stance"] and his AP in
## member["ap"]. Everything else Bulwark tracks sits in member["bulwark"]:
##   on Edren: guard_slot (Ironwall's ally), stance_fresh (raised this turn),
##             damaged (took damage since his last turn began), absorbed_total
##             (absorbed since he last entered a stance), riposte_armed,
##             oathkeeper_turns;
##   on any ally: veil_turns (Aegis Veil), resolve_turns (Steadfast Resolve).
##
## The rulings recorded on #158 settle what the doc left open: the heavy-hit
## bonus measures the whole incoming hit; Riposte is armed for 2 AP, keeps the
## stance up and counters the attacker of the next absorbed hit once, until
## Edren's next turn; Shatter Guard needs a stance and deals its absorbed total
## as fixed damage; under Oathkeeper every absorbed hit counters, unarmed and
## free.

## Max AP (abilities.md § Edren — Bulwark, "Max 10 AP. Starts each battle at 0").
const AP_MAX: int = 10

## Each stance: the % of a hit it redirects to Edren and the damage it covers —
## "physical" or "all". Ironwall guards one chosen ally, Rampart the back row.
const STANCES: Dictionary = {
	"ironwall": {"pct": 50, "kind": "physical"},
	"rampart": {"pct": 30, "kind": "all"},
}

## Aegis Veil: a flat % cut to magic damage on one ally, for that ally's turns.
const AEGIS_VEIL: Dictionary = {"pct": 40, "turns": 3}

## Steadfast Resolve: statuses cleansed from every ally, then a +% to stats on
## every living ally for their turns. The cleanse fires before the buff.
const STEADFAST_RESOLVE: Dictionary = {
	"cleanse": ["despair", "silence"],
	"stat_pct": {"def": 20, "mdef": 20},
	"turns": 3,
}

## The extra AP an absorbed hit earns when the whole hit, before the split,
## exceeds this % of Edren's max HP ("Bonus +1 AP if the absorbed hit exceeds
## 10% of Edren's max HP").
const HEAVY_HIT_PCT: int = 10

## Riposte's counter: a physical strike at "1.5x normal damage".
const RIPOSTE_ABILITY_MULT: float = 1.5

## Shatter Guard's bounds on its absorbed total: at least Edren's Attack x 1,
## at most 2x his max HP.
const SHATTER_GUARD: Dictionary = {"min_atk_mult": 1, "cap_max_hp_mult": 2}

## Oathkeeper, from edren.json's absorption_bonus_pct, attack_hits and
## duration_turns: +50% on every stance's absorption, the Attack command hits
## twice, for 3 of Edren's turns.
const OATHKEEPER: Dictionary = {"absorption_bonus_pct": 50, "attack_hits": 2, "turns": 3}

## The Bulwark abilities this slice resolves.
const BUILT: Array[String] = [
	"ironwall",
	"rampart",
	"riposte",
	"aegis_veil",
	"shatter_guard",
	"steadfast_resolve",
	"oathkeeper"
]

# ---------- Issuing ----------


## Raise [param stance] on Edren at [param slot], replacing any stance he holds.
## [param guard_slot] is Ironwall's ally (ignored by Rampart). The stance holds
## through his next turn: it drops when that turn closes, unless he raised a
## stance in it (on_turn_end).
static func enter_stance(state: Node, slot: int, stance: String, guard_slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	m["active_stance"] = stance
	var b: Dictionary = _record(m)
	b["guard_slot"] = guard_slot
	b["stance_fresh"] = true
	b["absorbed_total"] = 0
	state.ability_state_changed.emit(slot)


## Arm Riposte on Edren at [param slot] until his next turn begins. Arming it
## holds his stance through this turn, as raising one would.
static func arm_riposte(state: Node, slot: int) -> void:
	var b: Dictionary = _record(state.get_member(slot))
	b["riposte_armed"] = true
	b["stance_fresh"] = true
	state.ability_state_changed.emit(slot)


## Start Oathkeeper on Edren at [param slot] for OATHKEEPER's turns.
static func oathkeeper(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	_record(m)["oathkeeper_turns"] = _turns(m, int(OATHKEEPER["turns"]))
	state.ability_state_changed.emit(slot)


## Break Edren's stance: returns Shatter Guard's damage — what he absorbed since
## entering it, at least his Attack x 1, at most 2x his max HP and the 14,999
## damage cap — and drops the stance.
static func shatter(state: Node, slot: int) -> int:
	var m: Dictionary = state.get_member(slot)
	var total: int = int(_record(m).get("absorbed_total", 0))
	var floor_dmg: int = state.get_effective_stat(slot, "atk") * int(SHATTER_GUARD["min_atk_mult"])
	var cap: int = int(m.get("max_hp", 0)) * int(SHATTER_GUARD["cap_max_hp_mult"])
	_drop_stance(state, slot)
	return mini(14999, mini(cap, maxi(floor_dmg, total)))


## Whether [param m] holds a stance, which Shatter Guard needs.
static func in_stance(m: Dictionary) -> bool:
	return not String(m.get("active_stance", "")).is_empty()


## How many times [param m]'s Attack command swings: twice under Oathkeeper.
static func attack_hits(m: Dictionary) -> int:
	return int(OATHKEEPER["attack_hits"]) if _oathkeeper_on(m) else 1


## Veil [param target] against magic for AEGIS_VEIL's turns, refreshing any veil
## already on it.
static func aegis_veil(state: Node, target: int) -> void:
	var m: Dictionary = state.get_member(target)
	_record(m)["veil_turns"] = _turns(m, int(AEGIS_VEIL["turns"]))
	state.ability_state_changed.emit(target)


## Cleanse Despair and Silence from every ally, then give every living ally
## Steadfast Resolve's buff, refreshing one already running.
static func steadfast_resolve(state: Node) -> void:
	for i: int in range(4):
		for status: String in STEADFAST_RESOLVE["cleanse"]:
			state.remove_status(i, status)
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		_record(m)["resolve_turns"] = _turns(m, int(STEADFAST_RESOLVE["turns"]))
		state.ability_state_changed.emit(i)


## Whether [param member] holds at least [param cost] AP.
static func can_spend(member: Dictionary, cost: int) -> bool:
	return int(member.get("ap", 0)) >= cost


## Spend [param cost] AP from [param slot]. Returns false, spending nothing,
## when it holds less.
static func spend_ap(state: Node, slot: int, cost: int) -> bool:
	var m: Dictionary = state.get_member(slot)
	if not can_spend(m, cost):
		return false
	_set_ap(state, slot, int(m.get("ap", 0)) - cost)
	return true


# ---------- Where an enemy hit resolves ----------


## The stance guarding [param target] against a [param kind] ("physical" or
## "magic") hit, as {slot, pct} — Edren's slot and the % he takes — or {} when
## none does. Edren never guards himself: redirecting his own damage to himself
## would absorb nothing.
static func guard_for(state: Node, target: int, kind: String) -> Dictionary:
	var t: Dictionary = state.get_member(target)
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		var stance: String = m.get("active_stance", "")
		if stance.is_empty() or i == target or not m.get("is_alive", false):
			continue
		var rule: Dictionary = STANCES[stance]
		if rule["kind"] != "all" and rule["kind"] != kind:
			continue
		var bonus: int = int(OATHKEEPER["absorption_bonus_pct"]) if _oathkeeper_on(m) else 0
		var covered: bool = (
			t.get("row", "front") == "back"
			if stance == "rampart"
			else int(m.get("bulwark", {}).get("guard_slot", -1)) == target
		)
		if covered:
			return {"slot": i, "pct": int(rule["pct"]) * (100 + bonus) / 100}
	return {}


## Split [param pre] — the hit before any damage reduction — between the guarded
## ally and Edren. The ally takes pre x (1 - pct) x their own [param reductions];
## Edren takes pre x pct, which the ally's reductions do not shrink
## (combat-formulas.md § Stacking Examples). Each share floors at 1, as all
## damage does. Returns {damage, absorbed}.
static func split(pre: int, reductions: Array, guard: Dictionary) -> Dictionary:
	var pct: int = int(guard["pct"])
	var product: float = 1.0 - pct / 100.0
	for r: float in reductions:
		product *= 1.0 - r
	return {
		"damage": clampi(int(pre * product), 1, 14999),
		"absorbed": clampi(int(pre * pct / 100.0), 1, 14999),
	}


## Edren absorbs [param amount] of a hit that was [param pre] whole: +1 AP for
## the hit, +1 more when the whole hit exceeds HEAVY_HIT_PCT of his max HP, the
## share adds to his stance's absorbed total, then he takes it. Returns the
## damage he took.
static func absorb(state: Node, guard: Dictionary, amount: int, pre: int) -> int:
	var slot: int = int(guard["slot"])
	var m: Dictionary = state.get_member(slot)
	var heavy: bool = pre * 100 > int(m.get("max_hp", 0)) * HEAVY_HIT_PCT
	gain_ap(state, slot, 2 if heavy else 1)
	var b: Dictionary = _record(m)
	b["absorbed_total"] = int(b.get("absorbed_total", 0)) + amount
	return state.take_damage(slot, amount)


## Whether Edren at [param slot] counters the hit he just absorbed — always
## under Oathkeeper, else once if Riposte is armed — spending the armed Riposte.
static func take_riposte(state: Node, slot: int) -> bool:
	var m: Dictionary = state.get_member(slot)
	if not m.get("is_alive", false):
		return false
	if _oathkeeper_on(m):
		return true
	var b: Dictionary = _record(m)
	if not b.get("riposte_armed", false):
		return false
	b["riposte_armed"] = false
	state.ability_state_changed.emit(slot)
	return true


## Give Edren at [param slot] [param amount] AP, up to AP_MAX.
static func gain_ap(state: Node, slot: int, amount: int) -> void:
	_set_ap(state, slot, int(state.get_member(slot).get("ap", 0)) + amount)


## The flat damage reductions Bulwark puts on [param target] against a
## [param kind] hit, as fractions for DamageCalc's reduction_sources.
static func reductions(state: Node, target: int, kind: String) -> Array[float]:
	var out: Array[float] = []
	var b: Dictionary = state.get_member(target).get("bulwark", {})
	if kind == "magic" and int(b.get("veil_turns", 0)) > 0:
		out.append(int(AEGIS_VEIL["pct"]) / 100.0)
	return out


# ---------- BattleState ability hooks ----------


## The +% Steadfast Resolve gives [param stat] on member [param m] (0 when none).
static func stat_pct(m: Dictionary, stat: String) -> int:
	if int(m.get("bulwark", {}).get("resolve_turns", 0)) <= 0:
		return 0
	return int(STEADFAST_RESOLVE["stat_pct"].get(stat, 0))


## Damage is about to land on [param slot]: note it for AP decay. Returns the
## damage unchanged.
static func on_damage(state: Node, slot: int, amount: int) -> int:
	if amount > 0:
		_record(state.get_member(slot))["damaged"] = true
	return amount


## A fallen Edren guards no one: his stance drops.
static func on_fainted(state: Node, slot: int) -> void:
	_drop_stance(state, slot)


## No status ends a stance or a Bulwark effect.
static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


## Start of a member's turn: an armed Riposte lapses, and the member loses 1 AP
## if no damage landed since the last one.
static func on_turn_begin(state: Node, slot: int) -> Array:
	var m: Dictionary = state.get_member(slot)
	var b: Dictionary = _record(m)
	if b.get("riposte_armed", false):
		b["riposte_armed"] = false
		state.ability_state_changed.emit(slot)
	if not b.get("damaged", false) and int(m.get("ap", 0)) > 0:
		_set_ap(state, slot, int(m["ap"]) - 1)
	b["damaged"] = false
	return []


## End of a member's turn: count its Aegis Veil, Steadfast Resolve and
## Oathkeeper down, and drop Edren's stance unless he raised it (or armed
## Riposte) this turn.
static func on_turn_end(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	var b: Dictionary = _record(m)
	var changed: bool = false
	for key: String in ["veil_turns", "resolve_turns", "oathkeeper_turns"]:
		if int(b.get(key, 0)) > 0:
			b[key] = int(b[key]) - 1
			changed = changed or b[key] == 0
	if changed:
		state.ability_state_changed.emit(slot)
	if b.get("stance_fresh", false):
		b["stance_fresh"] = false
	else:
		_drop_stance(state, slot)


# ---------- Internals ----------


## The member's Bulwark record, created on first use.
static func _record(m: Dictionary) -> Dictionary:
	if not m.has("bulwark"):
		m["bulwark"] = {}
	return m["bulwark"]


## [param turns], plus one when [param m]'s turn is open: that turn's end would
## otherwise spend one (BattleRally.start follows the same rule).
static func _turns(m: Dictionary, turns: int) -> int:
	return turns + (1 if m.get("turn_open", false) else 0)


static func _oathkeeper_on(m: Dictionary) -> bool:
	return int(m.get("bulwark", {}).get("oathkeeper_turns", 0)) > 0


static func _set_ap(state: Node, slot: int, ap: int) -> void:
	var m: Dictionary = state.get_member(slot)
	var clamped: int = clampi(ap, 0, AP_MAX)
	if clamped == int(m.get("ap", 0)):
		return
	m["ap"] = clamped
	state.ability_state_changed.emit(slot)


static func _drop_stance(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty() or String(m.get("active_stance", "")).is_empty():
		return
	m["active_stance"] = ""
	state.ability_state_changed.emit(slot)
