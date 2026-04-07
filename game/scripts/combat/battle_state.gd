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

## Party member data. Index = slot (0-3). Null entries = empty slots.
var _members: Array = [null, null, null, null]


## Add a party member to a slot.
func add_member(slot: int, char_data: Dictionary) -> void:
	if slot < 0 or slot > 3:
		push_error("BattleState: Invalid slot %d" % slot)
		return
	var stats: Dictionary = char_data.get("base_stats", {})
	var max_hp: int = char_data.get("max_hp", stats.get("hp", 1))
	var current_hp: int = char_data.get("current_hp", max_hp)
	var max_mp: int = char_data.get("max_mp", stats.get("mp", 0))
	var current_mp: int = char_data.get("current_mp", max_mp)
	_members[slot] = {
		"character_id": char_data.get("id", ""),
		"character_data": char_data,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_mp": current_mp,
		"max_mp": max_mp,
		"row": char_data.get("default_row", "front"),
		"active_statuses": [] as Array[Dictionary],
		"is_alive": true,
		"is_defending": false,
		# Buffs
		"atk_mult": 1.0,
		"def_mult": 1.0,
		"mag_mult": 1.0,
		"mdef_mult": 1.0,
		"spd_mult": 1.0,
		"damage_taken_mult": 1.0,
		# Ability resources
		"ap": 0,
		"ac": 12,
		"wg": 0,
		"favor": {},
		"stolen_goods": [] as Array[String],
		"active_rally": {},
		"active_stance": "",
	}


## Get member data for a slot. Returns empty dict if slot is empty.
func get_member(slot: int) -> Dictionary:
	if slot < 0 or slot > 3 or _members[slot] == null:
		return {}
	return _members[slot]


## Get count of active (non-null) members.
func get_active_count() -> int:
	var count: int = 0
	for m in _members:
		if m != null:
			count += 1
	return count


## Apply damage to a party member.
func take_damage(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty() or not m["is_alive"]:
		return
	var clamped: int = maxi(0, amount)
	m["current_hp"] = maxi(0, m["current_hp"] - clamped)
	member_damaged.emit(slot, clamped)
	if m["current_hp"] <= 0:
		m["is_alive"] = false
		member_died.emit(slot)


## Heal a party member. Returns actual HP restored (clamped to max).
func heal(slot: int, amount: int) -> int:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
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
	if m.is_empty() or amount < 0:
		return false
	if m["current_mp"] < amount:
		return false
	m["current_mp"] -= amount
	return true


## Restore MP. Clamps amount to >= 0.
func restore_mp(slot: int, amount: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	var clamped: int = maxi(0, amount)
	m["current_mp"] = mini(m["max_mp"], m["current_mp"] + clamped)


## Apply a status effect. Duration is turns (int) or seconds (float).
func apply_status(slot: int, status_name: String, duration_type: String, duration: float) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	# Remove existing instance
	remove_status(slot, status_name)
	var entry: Dictionary = {"name": status_name, "duration_type": duration_type}
	if duration_type == "turns":
		entry["remaining_turns"] = int(duration)
	else:
		entry["remaining_seconds"] = float(duration)
	m["active_statuses"].append(entry)
	status_applied.emit(slot, status_name)


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


## Tick turn-based statuses at END of a combatant's turn.
func tick_statuses(slot: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	for i: int in range(m["active_statuses"].size() - 1, -1, -1):
		var s: Dictionary = m["active_statuses"][i]
		if s.get("duration_type", "") != "turns":
			continue
		s["remaining_turns"] -= 1
		if s["remaining_turns"] <= 0:
			var sname: String = s.get("name", "")
			m["active_statuses"].remove_at(i)
			status_removed.emit(slot, sname)


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


## Get effective stat with buff multiplier applied. No cap in battle.
func get_effective_stat(slot: int, stat_name: String) -> int:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return 0
	var base: int = m["character_data"].get("base_stats", {}).get(stat_name, 0)
	var mult_key: String = stat_name + "_mult"
	var mult: float = m.get(mult_key, 1.0)
	return int(base * mult)


## Set a buff multiplier.
func set_buff(slot: int, buff_key: String, value: float) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m[buff_key] = value


## Swap row (front <-> back). Free action per combat-formulas.md.
func swap_row(slot: int) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m["row"] = "back" if m["row"] == "front" else "front"


## Set defending flag.
func set_defending(slot: int, defending: bool) -> void:
	var m: Dictionary = get_member(slot)
	if m.is_empty():
		return
	m["is_defending"] = defending


## Check if all party members are dead.
func is_party_wiped() -> bool:
	for m: Variant in _members:
		if m != null and m["is_alive"]:
			return false
	return true


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
