class_name BattleForgewright
extends RefCounted
## Lira's Forgewright (GAP-002, #158 slice c): devices she deploys for Arcanite
## Charges (AC), what they do while they stand, and Overcharge. Pure static
## rules over BattleState's member records, reached through BattleState's
## ability-hook fan-out (on_turn_begin's strike requests, which the battle
## answers with shock, on_turn_end's heal events, and the neutral rest); from
## BattleActions where a hit resolves (reductions, thorns, spring_trap,
## take_overcharge, land_strike); and from BattleAbilityCommand, which issues
## the abilities and pays their AC.
##
## Design law: abilities.md § Lira — Forgewright and § Damage Magnitudes;
## combat-formulas.md § Damage Reduction Sources (Bulkhead) and § Buff-Granted
## Multipliers (Overcharge). Rulings of 2026-10-30: a device counts its turns
## on Lira's turns — "persists 3 turns" is three of hers after the one she
## deploys it on, the rule a Rally's copy on its caster follows — so Shock Coil
## fires as each of those turns begins and Mending Engine heals as each ends;
## Arc Trap fires on any enemy's physical attack, whatever its target, and is
## spent; a KO on Lira ends every device she has up, refunding nothing.
## Salvage takes the oldest device; Mending Engine's "most
## injured" is the lowest share of max HP, the lower slot on a tie; Thornveil
## Barrier answers physical hits only. Arcanite Colossus, Cael's Edge and
## Calibrate are a later slice.
##
## Lira's record carries her AC in member["ac"] and her devices, oldest first,
## in member["forgewright"]["devices"], each {id, cost, power, target,
## turns_left, fresh, fused}: turns_left is UNTIL_SPRUNG for Arc Trap; fresh
## marks the turn it was deployed on; fused marks one a combo put straight onto
## its target, which the device limit does not count and which cost no AC. An
## Overcharged ally carries member["forgewright"]["overcharged"]. AC spent or
## refunded here is written through to PartyState.arcanite_charges, the pool
## the next battle starts from (only a rest refills it).

const BattleActions = preload("res://scripts/combat/battle_actions.gd")

## A device's turns when it waits to be sprung rather than counting down.
const UNTIL_SPRUNG: int = -1

## Each device: the Lira turns it persists (UNTIL_SPRUNG for Arc Trap), and its
## magnitudes. Spell powers come from the ability data's `power`; Shock Coil's
## turns are its ticks, one per turn, held to lira.json's `ticks` by its test.
const DEVICES: Dictionary = {
	"shock_coil": {"turns": 3, "element": "storm"},
	"bulkhead": {"turns": 3, "reduction_pct": 40},
	"arc_trap":
	{"turns": UNTIL_SPRUNG, "element": "flame", "spd_debuff_pct": 20, "debuff_turns": 2},
	"mending_engine": {"turns": 4, "heal_pct": 15},
	"thornveil_barrier": {"turns": 3, "counter_pct": 15},
}

## Overcharge: the ally's next attack gains this element and multiplies its
## final damage by 1 + damage_pct / 100.
const OVERCHARGE: Dictionary = {"element": "storm", "damage_pct": 50}

## Devices Lira can have on the field at once; deploying past it destroys the
## oldest, refunding nothing.
const DEVICE_LIMIT: int = 2

## The Forgewright abilities this slice resolves.
const BUILT: Array[String] = [
	"shock_coil",
	"bulkhead",
	"arc_trap",
	"mending_engine",
	"overcharge",
	"salvage",
	"thornveil_barrier",
]

# ---------- Issuing ----------


## Deploy [param ability]'s device from Lira at [param slot], aimed at ally
## [param target] where it has one. A third device on the field destroys the
## oldest; a [param fused] one (a combo's) neither counts nor is destroyed, and
## records no AC cost, since a combo pays MP instead.
static func deploy(
	state: Node, slot: int, ability: Dictionary, target: int, fused: bool = false
) -> void:
	var m: Dictionary = state.get_member(slot)
	var rec: Dictionary = _record(m)
	var list: Array = rec.get("devices", [])
	var field: Array = list.filter(func(d: Dictionary) -> bool: return not d["fused"])
	if not fused and field.size() >= DEVICE_LIMIT:
		_remove(list, field[0])
	var device: Dictionary = {
		"id": ability["id"],
		"cost": 0 if fused else int(ability.get("cost_value", 0)),
		"power": int(ability.get("power", 0)),
		"target": target,
		"turns_left": int(DEVICES[ability["id"]]["turns"]),
		"fresh": m.get("turn_open", false),
		"fused": fused,
	}
	list.append(device)
	rec["devices"] = list
	state.ability_state_changed.emit(slot)


## Salvage Lira's oldest device, at [param slot]: destroy it and return half
## its AC cost, rounded down (2026-10-30 ruling). Returns the refund.
static func salvage(state: Node, slot: int) -> int:
	var list: Array = devices(state.get_member(slot))
	if list.is_empty():
		return 0
	var refund: int = int(list[0]["cost"]) / 2
	list.remove_at(0)
	_set_ac(state, slot, int(state.get_member(slot).get("ac", 0)) + refund)
	state.ability_state_changed.emit(slot)
	return refund


## Charge ally [param target]'s next attack. A second Overcharge before it is
## spent changes nothing.
static func overcharge(state: Node, target: int) -> void:
	_record(state.get_member(target))["overcharged"] = true
	state.ability_state_changed.emit(target)


## Lira's devices on the field and fused, oldest first.
static func devices(m: Dictionary) -> Array:
	return m.get("forgewright", {}).get("devices", [])


## Whether [param member] could issue [param ability] now, cost aside:
## Salvage needs a device to take down.
static func can_issue(member: Dictionary, ability: Dictionary) -> bool:
	return ability.get("id", "") != "salvage" or not devices(member).is_empty()


## Whether [param member] holds at least [param cost] AC.
static func can_spend(member: Dictionary, cost: int) -> bool:
	return int(member.get("ac", 0)) >= cost


## Spend [param cost] AC from [param slot]. Returns false, spending nothing,
## when it holds less.
static func spend_ac(state: Node, slot: int, cost: int) -> bool:
	var m: Dictionary = state.get_member(slot)
	if cost < 0 or not can_spend(m, cost):
		return false
	_set_ac(state, slot, int(m.get("ac", 0)) - cost)
	return true


# ---------- Where an enemy hit resolves ----------


## The flat reductions Lira's devices put on [param target] against a
## [param kind] hit, as fractions for DamageCalc: Bulkhead's 40%, physical only.
## Two Bulkheads on one ally still cut 40%.
static func reductions(state: Node, target: int, kind: String) -> Array[float]:
	var out: Array[float] = []
	if kind == "physical" and not _guarding(state, "bulkhead", target).is_empty():
		out.append(int(DEVICES["bulkhead"]["reduction_pct"]) / 100.0)
	return out


## Thornveil Barrier answering a physical hit that landed on [param target]:
## 15% of the target's Defense, as fixed damage, back at [param enemy]. Returns
## the counters in BattleActions' "ripostes" shape.
static func thorns(state: Node, enemy: Node, target: int) -> Array:
	var owner: Dictionary = _guarding(state, "thornveil_barrier", target)
	if owner.is_empty() or not enemy.is_alive:
		return []
	var pct: int = int(DEVICES["thornveil_barrier"]["counter_pct"])
	var dmg: int = maxi(1, state.get_effective_stat(target, "def") * pct / 100)
	enemy.take_damage(dmg)
	return [
		{
			"slot": owner["slot"],
			"hit": true,
			"damage": dmg,
			"type": "physical",
			"killed": not enemy.is_alive
		}
	]


## [param enemy] has used a physical attack: the oldest Arc Trap on the field
## goes off on it, Flame at its spell power from Lira's Magic, and a hit slows it
## for its next turns. The trap is spent. Returns the result in BattleActions'
## "ripostes" shape, or [] when no trap waits.
static func spring_trap(state: Node, enemy: Node) -> Array:
	if not enemy.is_alive:
		return []
	for slot: int in range(4):
		var list: Array = devices(state.get_member(slot))
		for d: Dictionary in list:
			if d["id"] != "arc_trap":
				continue
			_remove(list, d)
			state.ability_state_changed.emit(slot)
			var rule: Dictionary = DEVICES["arc_trap"]
			var r: Dictionary = _magic(state, slot, enemy, -1, int(d["power"]), rule["element"])
			if r.get("hit", false) and enemy.is_alive:
				var mult: float = 1.0 - int(rule["spd_debuff_pct"]) / 100.0
				enemy.apply_buff("spd", mult, int(rule["debuff_turns"]))
			r["slot"] = slot
			return [r]
	return []


## Spend [param slot]'s Overcharge on its strike against [param enemy]. Returns
## {} when it holds none, else {mult, element_mod}: the final-damage multiplier,
## and the element multiplier — Storm's, or the weapon element's when that is
## more favorable to the attacker.
static func take_overcharge(state: Node, slot: int, enemy: Node) -> Dictionary:
	var m: Dictionary = state.get_member(slot)
	if not m.get("forgewright", {}).get("overcharged", false):
		return {}
	_record(m).erase("overcharged")
	state.ability_state_changed.emit(slot)
	var mod: float = enemy.get_element_multiplier(OVERCHARGE["element"])
	var weapon: String = _weapon_element(String(m.get("character_id", "")))
	if not weapon.is_empty():
		mod = maxf(mod, enemy.get_element_multiplier(weapon))
	return {"mult": 1.0 + int(OVERCHARGE["damage_pct"]) / 100.0, "element_mod": mod}


## Land a party strike of [param dmg] on [param enemy], as [param dtype] unless
## Overcharge's element ([param charge], from take_overcharge) voids it or the
## enemy absorbs it. Returns BattleActions' strike result.
static func land_strike(enemy: Node, dmg: int, dtype: String, charge: Dictionary) -> Dictionary:
	var mod: float = float(charge.get("element_mod", 1.0))
	if mod == 0.0:
		return {"hit": true, "damage": 0, "type": "immune"}
	if mod < 0.0:
		enemy.heal(dmg)
		return {"hit": true, "damage": dmg, "type": "absorb"}
	enemy.take_damage(dmg)
	return {"hit": true, "damage": dmg, "type": dtype, "killed": not enemy.is_alive}


# ---------- BattleState ability hooks ----------


## Start of Lira's turn: each Shock Coil standing since an earlier turn asks to
## strike, as a request {slot, shock_coil: power} on begin_turn's events. The
## battle, which holds the enemies, answers each with shock.
static func on_turn_begin(state: Node, slot: int) -> Array:
	var out: Array = []
	for d: Dictionary in devices(state.get_member(slot)):
		if d["id"] == "shock_coil" and not d["fresh"]:
			out.append({"slot": slot, "shock_coil": int(d["power"])})
	return out


## End of Lira's turn: each device past its deploying turn acts — Mending
## Engine heals — and counts one of its turns down, leaving when none remain.
## Returns the heals as tick_statuses events [{slot, dmg, type: "heal"}].
static func on_turn_end(state: Node, slot: int) -> Array:
	var list: Array = devices(state.get_member(slot))
	var events: Array = []
	for d: Dictionary in list.duplicate():
		if d["fresh"]:
			d["fresh"] = false
			continue
		if d["id"] == "mending_engine":
			events.append_array(_mend(state))
		if int(d["turns_left"]) > 0:
			d["turns_left"] = int(d["turns_left"]) - 1
			if d["turns_left"] == 0:
				_remove(list, d)
				state.ability_state_changed.emit(slot)
	return events


static func on_damage(_state: Node, _slot: int, amount: int) -> int:
	return amount


## A member fainted. If it was Lira, every device she has up ends at once, the
## fused ones too, with no AC back (2026-10-30 ruling: a KO ends her devices as
## it ends a Rally, Bulwark's state and positive statuses).
static func on_fainted(state: Node, slot: int) -> void:
	var list: Array = devices(state.get_member(slot))
	if list.is_empty():
		return
	list.clear()
	state.ability_state_changed.emit(slot)


static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


static func stat_pct(_m: Dictionary, _stat: String) -> int:
	return 0


# ---------- Internals ----------


## A Shock Coil of Lira's at [param slot] strikes one living, targetable enemy
## of [param enemies] at random, a Storm spell at [param power], and earns her
## threat for what it dealt. Answers on_turn_begin's request. Returns
## {target: "enemy_N", damage, type, killed}, or {} when Lira has fallen (an
## earlier strike's death burst can fell her mid-volley) or nobody is left.
static func shock(state: Node, slot: int, power: int, enemies: Array[Node]) -> Dictionary:
	if not state.get_member(slot).get("is_alive", false):
		return {}
	var living: Array[int] = []
	for i: int in range(enemies.size()):
		if enemies[i].is_alive and not enemies[i].get_meta("untargetable", false):
			living.append(i)
	if living.is_empty():
		return {}
	var idx: int = living[0] if living.size() == 1 else living[randi() % living.size()]
	var r: Dictionary = _magic(
		state, slot, enemies[idx], idx, power, DEVICES["shock_coil"]["element"]
	)
	if r.get("type", "") == "magic":
		state.add_threat(slot, int(r["damage"]))  # GAP-009 highest-threat
	return {
		"target": "enemy_%d" % idx,
		"damage": int(r.get("damage", 0)),
		"type": r.get("type", "miss"),
		"killed": r.get("killed", false),
	}


## Mending Engine heals the most injured living ally — the lowest share of max
## HP, the lower slot on a tie — for 15% of that ally's max HP. Returns the heal
## as [{slot, dmg, type: "heal"}], or [] when nobody gained HP.
static func _mend(state: Node) -> Array:
	var best: int = -1
	var best_share: float = 1.0
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		var share: float = float(m["current_hp"]) / float(maxi(1, int(m["max_hp"])))
		if share < best_share:
			best = i
			best_share = share
	if best < 0:
		return []
	var pct: int = int(DEVICES["mending_engine"]["heal_pct"])
	var healed: int = state.heal(best, int(state.get_member(best)["max_hp"]) * pct / 100)
	return [{"slot": best, "dmg": healed, "type": "heal"}] if healed > 0 else []


## A device's spell from Lira at [param slot]: her Magic at [param power] in
## [param element] against [param enemy], through the spell path.
static func _magic(
	state: Node, slot: int, enemy: Node, idx: int, power: int, element: String
) -> Dictionary:
	var mag: int = state.get_effective_stat(slot, "mag")
	return BattleActions.apply_magic_to_enemy(state, slot, mag, power, element, enemy, idx)


## The device of [param id] guarding ally [param target], as {slot} — the slot
## of the Lira who deployed it — or {} when none does.
static func _guarding(state: Node, id: String, target: int) -> Dictionary:
	for slot: int in range(4):
		for d: Dictionary in devices(state.get_member(slot)):
			if d["id"] == id and int(d["target"]) == target:
				return {"slot": slot}
	return {}


## The element of the weapon [param character_id] wears, or "" when it has none.
static func _weapon_element(character_id: String) -> String:
	var weapon: String = PartyState.get_member(character_id).get("equipment", {}).get("weapon", "")
	if weapon.is_empty():
		return ""
	for w: Variant in DataManager.load_equipment("weapons"):
		if w is Dictionary and (w as Dictionary).get("id", "") == weapon:
			var element: Variant = (w as Dictionary).get("element")
			return String(element) if element is String else ""
	return ""


## Remove device [param d] itself from [param list] — not an equal-looking one.
static func _remove(list: Array, d: Dictionary) -> void:
	for i: int in range(list.size()):
		if is_same(list[i], d):
			list.remove_at(i)
			return


## The member's Forgewright record, created on first use.
static func _record(m: Dictionary) -> Dictionary:
	if not m.has("forgewright"):
		m["forgewright"] = {}
	return m["forgewright"]


## Set [param slot]'s AC and write it through to the party's pool, both held to
## the pool's bounds by PartyVitals.clamp_ac.
static func _set_ac(state: Node, slot: int, ac: int) -> void:
	var m: Dictionary = state.get_member(slot)
	var clamped: int = PartyVitals.clamp_ac(ac)
	PartyState.arcanite_charges = clamped
	if clamped == int(m.get("ac", 0)):
		return
	m["ac"] = clamped
	state.ability_state_changed.emit(slot)
