extends Node
## Party member runtime state for battle.
##
## Tracks mutable HP/MP/status/buffs/row/ability resources for up to 4
## active party members. Enemy state lives in enemy.gd (already built).

signal member_damaged(slot: int, amount: int)
signal member_healed(slot: int, amount: int)
signal member_died(slot: int)
signal member_revived(slot: int)
signal status_applied(slot: int, status_name: String)
signal status_removed(slot: int, status_name: String)
## Cured (BattleStatusGuard.cure) or expired follow a status_removed (#515); blocked
## is a status worn gear kept off, so nothing landed (BattleStatusGuard.blocks, #512).
signal status_cured(slot: int, status_name: String)
signal status_expired(slot: int, status_name: String)
signal status_blocked(slot: int, status_name: String)
## A member's in-force ability or buff state changed: a Rally, Bulwark's stance,
## AP or effects, Forgewright's devices or AC, or a buff landed on or left them.
signal ability_state_changed(slot: int)

const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Helpers = preload("res://scripts/util/inventory_helpers.gd")
const Rally = preload("res://scripts/combat/battle_rally.gd")
const Bulwark = preload("res://scripts/combat/battle_bulwark.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
const Buffs = preload("res://scripts/combat/battle_buffs.gd")
const StatusGuard = preload("res://scripts/combat/battle_status_guard.gd")

## Modules holding in-force ability and buff state (#158), each answering on_damage,
## on_fainted, on_status, on_turn_begin, on_turn_end and stat_pct (no seam names one).
const ABILITY_HOOKS: Array = [Rally, Bulwark, Forgewright, Buffs, preload("battle_tricks.gd")]

## Party member data. Index = slot (0-3). Null entries = empty slots.
var _members: Array = [null, null, null, null]


## Add a party member to a slot. Bakes equipment and Stat Capsule bonuses into
## effective_stats at battle start so combat calculations reflect equipped gear,
## crystals and permanent capsule gains.
func add_member(slot: int, char_data: Dictionary) -> void:
	if slot < 0 or slot > 3:
		push_error("BattleState: Invalid slot %d" % slot)
		return
	var stats: Dictionary = char_data.get("base_stats", {})
	var max_hp: int = char_data.get("max_hp", stats.get("hp", 1))
	var current_hp: int = char_data.get("current_hp", max_hp)
	var max_mp: int = char_data.get("max_mp", stats.get("mp", 0))
	var current_mp: int = char_data.get("current_mp", max_mp)
	var cid: String = char_data.get("character_id", char_data.get("id", ""))
	var enriched_data: Dictionary = char_data.duplicate()
	if not enriched_data.has("name") and cid != "":
		var template: Dictionary = DataManager.load_character(cid)
		enriched_data["name"] = template.get("name", cid.capitalize())
	var effective: Dictionary = _compute_effective_stats(cid, stats)
	_members[slot] = {
		"character_id": cid,
		"character_data": enriched_data,
		"effective_stats": effective,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_mp": current_mp,
		"max_mp": max_mp,
		"row": PartyState.get_row(cid),
		"active_statuses": [] as Array[Dictionary],
		"is_alive": current_hp > 0,
		"is_defending": false,
		# Damage dealt to enemies, for boss highest-threat targeting (GAP-009).
		"threat_dealt": 0,
		# Buffs
		"atk_mult": 1.0,
		"def_mult": 1.0,
		"mag_mult": 1.0,
		"mdef_mult": 1.0,
		"spd_mult": 1.0,
		"damage_taken_mult": 1.0,
		# Ability resources
		"ap": 0,
		"ac": PartyState.arcanite_charges,
		"wg": 0,
		"favor": {},
		"stolen_goods": [] as Array[String],
		# The Rally this member is under; battle_rally.gd owns its shape and rules.
		"active_rally": {},
		"turn_open": false,
		# Edren's stance; battle_bulwark.gd owns it and the "bulwark" record.
		"active_stance": "",
		"bulwark": {},
	}


## Get member data for a slot. Returns empty dict if slot is empty.
func get_member(slot: int) -> Dictionary:
	if slot < 0 or slot > 3 or _members[slot] == null:
		return {}
	return _members[slot]


## Get count of active (non-null) members.
func get_active_count() -> int:
	return _members.size() - _members.count(null)


## Apply damage to a party member. Returns the damage applied after the ability
## hooks (Unbreakable leaves 1 HP) — the number a damage popup should show.
## A hit cures Sleep and Confusion (#435); [param wakes] is false for the
## bearer's own Poison/Burn tick, as enemy.take_damage does.
func take_damage(slot: int, amount: int, wakes: bool = true) -> int:
	var m: Dictionary = get_member(slot)
	if m.is_empty() or not m["is_alive"]:
		return 0
	var applied: int = maxi(0, amount)
	for hook: Variant in ABILITY_HOOKS:
		applied = hook.on_damage(self, slot, applied)
	m["current_hp"] = maxi(0, m["current_hp"] - applied)
	member_damaged.emit(slot, applied)
	if wakes and applied > 0:
		for s: Dictionary in (m["active_statuses"] as Array).duplicate():
			if StatusEffects.wakes_on_damage(s.get("name", "")):
				remove_status(slot, s["name"])
	if m["current_hp"] <= 0:
		m["is_alive"] = false
		m["turn_open"] = false
		for hook: Variant in ABILITY_HOOKS:
			hook.on_fainted(self, slot)
		member_died.emit(slot)
	return applied


## Heal a party member. Returns actual HP restored (clamped to max).
func heal(slot: int, amount: int, can_revive: bool = false) -> int:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return 0
	if not m["is_alive"] and not can_revive:  # only a revive raises the KO'd
		return 0
	var clamped: int = maxi(0, amount)
	var old_hp: int = m["current_hp"]
	m["current_hp"] = mini(m["max_hp"], m["current_hp"] + clamped)
	var actual: int = m["current_hp"] - old_hp
	if m["current_hp"] > 0 and not m["is_alive"]:
		m["is_alive"] = true
		member_revived.emit(slot)
	if actual > 0:
		member_healed.emit(slot, actual)
	return actual


## Spend MP. Returns false if insufficient or negative amount.
func spend_mp(slot: int, amount: int) -> bool:
	var m: Dictionary = get_member(slot)
	if m.is_empty() or amount < 0 or m["current_mp"] < amount:
		return false
	m["current_mp"] -= amount
	return true


## Restore MP. Clamps amount to >= 0.
func restore_mp(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if not m.is_empty():
		m["current_mp"] = mini(m["max_mp"], m["current_mp"] + maxi(0, amount))


## Apply a status effect. Duration is turns (int) or seconds (float). Returns
## false when nothing landed: no member, or worn gear wards it off (#512).
func apply_status(slot: int, status_name: String, duration_type: String, duration: float) -> bool:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return false
	if StatusGuard.blocks(m["character_id"], status_name):
		status_blocked.emit(slot, status_name)
		return false
	remove_status(slot, status_name)  # a recast refreshes it
	var entry: Dictionary = {"name": status_name, "duration_type": duration_type}
	if duration_type == "turns":
		entry["remaining_turns"] = int(duration)
	else:
		entry["remaining_seconds"] = float(duration)
	m["active_statuses"].append(entry)
	for hook: Variant in ABILITY_HOOKS:
		hook.on_status(self, slot, status_name)
	status_applied.emit(slot, status_name)
	return true


## Remove a status effect.
func remove_status(slot: int, status_name: String) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		if m["active_statuses"][i].get("name", "") == status_name:
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, status_name)


## Check if a status is active.
func has_status(slot: int, status_name: String) -> bool:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return false
	for s: Dictionary in m["active_statuses"]:
		if s.get("name", "") == status_name:
			return true
	return false


## Tick turn-based statuses at END of a combatant's turn. Applies Poison/Burn
## HP ticks first, then decrements durations. UNTIL_CURED (negative) durations
## persist — they are cured by remove_status, never by countdown. Closes the turn
## for the ability hooks. Returns its events [{slot, dmg, type}] for feedback —
## DoT ticks, then the hooks' turn-end events (mirrors the enemy-side tick).
func tick_statuses(slot: int) -> Array:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return []
	var dot_events: Array = _apply_dot(slot, m)
	m["turn_open"] = false
	for hook: Variant in ABILITY_HOOKS:
		var ended: Variant = hook.on_turn_end(self, slot)  # Mending Engine's heal
		if ended is Array:
			dot_events.append_array(ended)
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		var s: Dictionary = m["active_statuses"][i]
		if s.get("duration_type", "") != "turns":
			continue
		if int(s.get("remaining_turns", 0)) < 0:  # UNTIL_CURED
			continue
		s["remaining_turns"] -= 1
		if s["remaining_turns"] <= 0:
			var sname: String = s.get("name", "")
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, sname)
			status_expired.emit(slot, sname)
	return dot_events


## Apply damage-over-time (Poison 8%/turn, Burn 5%/turn; magic.md
## § Status Effect Reference > 'Poison') to a member. Mirrors the enemy-side
## tick: floor(max_hp * tick_pct), min 1, and like it never wakes the bearer.
## Returns the per-status events [{slot, dmg, type}] for damage feedback.
func _apply_dot(slot: int, m: Dictionary) -> Array:
	var events: Array = []
	if not m.get("is_alive", false):
		return events
	var max_hp: int = m.get("max_hp", 0)
	for s: Dictionary in (m["active_statuses"] as Array).duplicate():
		var sname: String = s.get("name", "")
		var pct: float = StatusEffects.tick_pct(sname)
		if pct > 0.0 and m.get("is_alive", false):
			var dmg: int = take_damage(slot, maxi(1, int(max_hp * pct)), false)
			events.append(
				{"slot": slot, "dmg": dmg, "type": "burn" if sname == "burn" else "poison"}
			)
	return events


## Tick real-time statuses (Stop). Called from _process with delta.
func tick_realtime_statuses(slot: int, delta: float) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		var s: Dictionary = m["active_statuses"][i]
		if s.get("duration_type", "") != "realtime":
			continue
		s["remaining_seconds"] -= delta
		if s["remaining_seconds"] <= 0.0:
			var sname: String = s.get("name", "")
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, sname)
			status_expired.emit(slot, sname)


## Effective stat (base + capsules + equipment) with every buff applied. Buffs are
## percentages of that one stat, so they add before one floor: Rally +20% with an
## item's +10% is +30% (combat-formulas.md § Buff & Debuff Interaction).
func get_effective_stat(slot: int, stat_name: String) -> int:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return 0
	var base: int = m.get("effective_stats", {}).get(stat_name, 0)
	var pct: int = 100 + roundi((float(m.get(stat_name + "_mult", 1.0)) - 1.0) * 100.0)
	for hook: Variant in ABILITY_HOOKS:
		pct += hook.stat_pct(m, stat_name)
	return base * pct / 100


## Set a buff multiplier.
func set_buff(slot: int, buff_key: String, value: float) -> void:
	if not get_member(slot).is_empty():
		get_member(slot)[buff_key] = value


## Start of a member's turn, once until tick_statuses closes it (a canceled menu
## re-prompts). Returns the hooks' events: [{slot, dmg, type}] (Second Wind's
## regen) and Shock Coil's strike requests (BattleForgewright.on_turn_begin).
func begin_turn(slot: int) -> Array:
	var m: Dictionary = get_member(slot)
	if m.is_empty() or not m["is_alive"] or m["turn_open"]:
		return []
	m["turn_open"] = true
	var events: Array = []
	for hook: Variant in ABILITY_HOOKS:
		events.append_array(hook.on_turn_begin(self, slot))
	return events


## Swap row (front <-> back). Free action per combat-formulas.md.
func swap_row(slot: int) -> void:
	var m: Dictionary = get_member(slot)
	if not m.is_empty():
		m["row"] = "back" if m["row"] == "front" else "front"


## Accumulate threat (damage dealt to enemies) for a member (GAP-009).
func add_threat(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if not m.is_empty():
		m["threat_dealt"] = int(m.get("threat_dealt", 0)) + maxi(0, amount)


## The living member with the most cumulative damage dealt = highest threat.
## Ties (including the all-zero start) break to the lowest slot. -1 if none alive.
func get_highest_threat_slot() -> int:
	var best_slot: int = -1
	var best_threat: int = -1
	for i: int in range(4):
		var m: Dictionary = get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		var t: int = int(m.get("threat_dealt", 0))
		if t > best_threat:
			best_threat = t
			best_slot = i
	return best_slot


## Set defending flag.
func set_defending(slot: int, defending: bool) -> void:
	if not get_member(slot).is_empty():
		get_member(slot)["is_defending"] = defending


## Check if all party members are dead.
func is_party_wiped() -> bool:
	return not _members.any(func(m: Variant) -> bool: return m != null and m["is_alive"])


## Check if a member is a valid heal target (alive for normal heal, any for revive).
func is_valid_heal_target(slot: int, can_revive: bool = false) -> bool:
	var m: Dictionary = get_member(slot)
	return not m.is_empty() and (m["is_alive"] or can_revive)


## Get average SPD of living party members.
func get_avg_party_spd() -> float:
	var total: float = 0.0
	var count: int = 0
	for i: int in range(4):
		var m: Dictionary = get_member(i)
		if not m.is_empty() and m.get("is_alive", false):
			total += get_effective_stat(i, "spd")
			count += 1
	return total / maxf(1.0, count)


## Gain Weave Gauge for a specific slot (Maren only).
func gain_weave_gauge(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.get("character_id", "") == "maren":
		m["wg"] = mini(100, m.get("wg", 0) + amount)


## Gain Weave Gauge for Maren from any slot.
func gain_weave_gauge_for_maren(amount: int) -> void:
	for i: int in range(4):
		gain_weave_gauge(i, amount)


## Compute effective stats (base + Stat Capsule gains + equipment bonuses) for a
## character. Called once at battle start to bake them into combat stats.
func _compute_effective_stats(character_id: String, base_stats: Dictionary) -> Dictionary:
	var effective: Dictionary = base_stats.duplicate()
	if character_id.is_empty():
		return effective
	# The one shared formula, so combat, the menus and level-up agree, stat cap
	# included (progression.md § Equipment and Buffs: gear cannot pass 255). The
	# view is this battle's base_stats plus the banked capsule gains (GAP-020).
	var view: Dictionary = {
		"base_stats": base_stats,
		"stat_capsules": PartyState.get_member(character_id).get("stat_capsules", {}),
	}
	for stat: String in ["atk", "def", "mag", "mdef", "spd", "lck"]:
		effective[stat] = Helpers.compute_effective_stat(
			view, stat, PartyState.get_equipment_bonus(character_id, stat)
		)
	return effective
