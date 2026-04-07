extends RefCounted
## Enemy action selection for battle.
##
## Weighted-random for regular enemies. Boss AI is a stub — scripted
## behavior deferred to content gaps (4.1+).


## Select an action for a regular enemy.
## Returns: {type: "attack"|"ability"|"defend", target_slot: int, ability_id: String}
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

	# 20% ability (if enemy has any)
	if roll < 90:
		var abilities: Array = enemy_data.get("abilities", [])
		if not abilities.is_empty():
			var ab: Dictionary = abilities[randi() % abilities.size()]
			var target: int = living[randi() % living.size()]
			return {"type": "ability", "target_slot": target, "ability_id": ab.get("id", "")}

	# 10% defend / do nothing
	return {"type": "defend", "target_slot": -1, "ability_id": ""}


## Select boss action (stub — returns basic attack).
static func select_boss_action(
	enemy_data: Dictionary, current_hp: int, party_members: Array, party_rows: Array
) -> Dictionary:
	var living: Array[int] = []
	for i: int in range(party_members.size()):
		if party_members[i] != null and party_members[i] is Dictionary:
			if party_members[i].get("is_alive", false):
				living.append(i)
	if living.is_empty():
		return {"type": "defend", "target_slot": -1, "ability_id": ""}

	var _phase: int = _get_boss_phase(enemy_data, current_hp)
	var target: int = _pick_physical_target(living, party_rows)
	return {"type": "attack", "target_slot": target, "ability_id": ""}


## Pick a physical attack target. Prefers front row (75/25 split).
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


## Determine boss phase from HP thresholds.
static func _get_boss_phase(enemy_data: Dictionary, current_hp: int) -> int:
	var phases: Array = enemy_data.get("phases", [])
	for i: int in range(phases.size() - 1, -1, -1):
		var threshold: int = phases[i].get("hp_threshold", 0)
		if current_hp <= threshold:
			return i + 1
	return 0


## Pick a random living party member slot from battle state.
static func pick_alive_target(state: Node) -> int:
	var alive: Array[int] = []
	for i: int in range(4):
		if state.get_member(i).get("is_alive", false):
			alive.append(i)
	return alive[randi() % alive.size()] if not alive.is_empty() else 0


## Vein Guardian scripted AI (hardcoded, tech debt).
## Phase 1: alternate Crystal Slam / Ember Pulse, Ember Pulse every 3rd turn.
## Phase 2 (<= 50% HP): Reconstruct once, then resume attacks.
static func get_vein_guardian_action(
	state: Node, turn: int, hp_ratio: float, last_action: String, reconstructed: bool
) -> Dictionary:
	if hp_ratio <= 0.5 and not reconstructed:
		return {"type": "heal", "id": "reconstruct", "target": "self", "value": 300}
	var use_ember: bool = (turn % 3 == 0 and turn % 4 != 0) or last_action == "crystal_slam"
	if not use_ember:
		return {"type": "attack", "id": "crystal_slam", "target_slot": pick_alive_target(state)}
	return {
		"type": "ability", "id": "ember_pulse", "target": "all", "element": "flame", "power": 20
	}
