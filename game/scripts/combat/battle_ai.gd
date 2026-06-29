extends RefCounted
## Enemy action selection for battle.
##
## Weighted-random for regular enemies. Scripted boss AI for
## Vein Guardian, Drowned Sentinel, and Corrupted Fenmother.


## Select an action for a regular enemy.
## Returns: {type: "attack"|"ability"|"defend", target_slot: int, ability_id: String}
## @param party_members Array[Dictionary] — party member data dicts (may be null for empty slots).
## @param party_rows Array[String] — "front" or "back" per slot.
static func select_action(
	enemy_data: Dictionary, party_members: Array, party_rows: Array
) -> Dictionary:
	var living: Array[int] = []
	for i: int in range(party_members.size()):
		if party_members[i] != null and party_members[i] is Dictionary:
			if party_members[i].get("is_alive", false):
				living.append(i)
	if living.is_empty():
		return {"type": "defend", "target_slot": -1, "ability_id": ""}

	var roll: int = randi() % 100

	# 70% basic attack
	if roll < 70:
		var target: int = _pick_physical_target(living, party_rows)
		return {"type": "attack", "target_slot": target, "ability_id": ""}

	# 20% ability (if enemy has any). aoe_on_death abilities (Shard Burst) are
	# death triggers only — they fire via _on_enemy_died, never as a turn action,
	# so exclude them from the selectable pool. A chosen-but-empty list falls
	# through to defend (the pre-GAP-024 behavior when no enemy had abilities).
	if roll < 90:
		var abilities: Array = enemy_data.get("abilities", []).filter(
			func(a: Dictionary) -> bool: return not a.get("aoe_on_death", false)
		)
		if not abilities.is_empty():
			var ab: Dictionary = abilities[randi() % abilities.size()]
			return _build_ability_action(ab, living, party_rows)

	# 10% defend / do nothing
	return {"type": "defend", "target_slot": -1, "ability_id": ""}


## Build a turn action from an enemy ability dict (GAP-024). Propagates the full
## ability metadata (target shape, element/power, status, multi-hit, buff) so the
## turn driver can resolve it — not just the id. See
## docs/story/bestiary/enemy-ability-conventions.md for the schema.
static func _build_ability_action(ab: Dictionary, living: Array, party_rows: Array) -> Dictionary:
	var shape: String = ab.get("target", "single")
	var action: Dictionary = {
		"type": "ability",
		"id": ab.get("id", ""),
		"ability_id": ab.get("id", ""),
		"target": shape,
		"atk_type": ab.get("type", "attack"),
		"element": ab.get("element", ""),
		"power": int(ab.get("spell_power", 0)),
		"ability_mult": float(ab.get("ability_mult", 1.0)),
		"status": ab.get("status", ""),
		"status_rate": int(ab.get("status_rate", 0)),
		"status_duration": ab.get("status_duration", null),
		"hits": int(ab.get("hits", 1)),
		"buff": ab.get("buff", {}),
		"aoe_on_death": bool(ab.get("aoe_on_death", false)),
	}
	# Only single-target abilities resolve a concrete slot; all/self do not.
	action["target_slot"] = _pick_physical_target(living, party_rows) if shape == "single" else -1
	return action


## Pick a physical attack target. Prefers front row (75/25 split).
## @param living_slots Array[int] — indices of living party members.
## @param party_rows Array[String] — "front" or "back" per slot.
static func _pick_physical_target(living_slots: Array, party_rows: Array) -> int:
	var front: Array[int] = []
	var back: Array[int] = []
	for slot: int in living_slots:
		if slot < party_rows.size() and party_rows[slot] == "back":
			back.append(slot)
		else:
			front.append(slot)

	if not front.is_empty() and (back.is_empty() or randi() % 100 < 75):
		return front[randi() % front.size()]
	if not back.is_empty():
		return back[randi() % back.size()]
	return living_slots[randi() % living_slots.size()]


## Pick a random living party member slot from battle state.
static func pick_alive_target(state: Node) -> int:
	var alive: Array[int] = []
	for i: int in range(4):
		if state.get_member(i).get("is_alive", false):
			alive.append(i)
	return alive[randi() % alive.size()] if not alive.is_empty() else -1


## Pick the living party member with the lowest current HP.
static func _pick_lowest_hp_target(state: Node) -> int:
	var best_slot: int = -1
	var best_hp: int = 999999
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.get("is_alive", false):
			var hp: int = m.get("current_hp", 999999)
			if hp < best_hp:
				best_hp = hp
				best_slot = i
	return best_slot
