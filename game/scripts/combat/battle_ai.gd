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
## @param party_members Array[Dictionary] — party member data dicts (may be null for empty slots).
## @param party_rows Array[String] — "front" or "back" per slot.
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

	@warning_ignore("return_value_discarded")
	_get_boss_phase(enemy_data, current_hp)  # TODO: use for scripted AI
	var target: int = _pick_physical_target(living, party_rows)
	return {"type": "attack", "target_slot": target, "ability_id": ""}


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
	return alive[randi() % alive.size()] if not alive.is_empty() else -1


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


## Drowned Sentinel scripted AI (hardcoded).
## Every 4th turn: Barnacle Shield (DEF buff). Every 3rd: Frost Wave (AoE).
## Default: Stone Slam (physical, alive target).
static func get_drowned_sentinel_action(state: Node, turn: int) -> Dictionary:
	if turn % 4 == 0:
		return {"type": "ability", "id": "barnacle_shield", "target": "self", "element": ""}
	if turn % 3 == 0:
		return {
			"type": "ability", "id": "frost_wave", "target": "all", "element": "frost", "power": 20
		}
	return {"type": "attack", "id": "stone_slam", "target_slot": pick_alive_target(state)}


## Corrupted Fenmother scripted AI (hardcoded).
## Dive/surface state machine with phase transitions at 50% HP.
## Phase 1: turn-counter priority (Tail Sweep, Water Jet).
## Phase 2: spawn adds when low, more aggressive attacks.
static func get_corrupted_fenmother_action(
	state: Node,
	turn: int,
	hp_ratio: float,
	surface_count: int,
	is_diving: bool,
	spawned_adds: bool,
	active_adds: int
) -> Dictionary:
	# Dive/surface cycle: surface 3 turns, dive 2 turns
	if is_diving:
		if surface_count >= 2:
			return {"type": "skip", "id": "resurface"}
		return {"type": "skip", "id": "dive"}

	if surface_count >= 3:
		return {"type": "skip", "id": "start_dive"}

	# Phase 2: <= 50% HP
	if hp_ratio <= 0.5:
		if active_adds < 2 and (turn % 3 == 0 or not spawned_adds):
			return {
				"type": "spawn",
				"id": "spawn_adds",
				"enemies": ["corrupted_spawn", "corrupted_spawn"]
			}
		if turn % 3 == 0:
			return {
				"type": "ability",
				"id": "water_jet",
				"target_slot": _pick_lowest_hp_target(state),
				"element": "frost",
				"power": 25
			}
		if turn % 2 == 0:
			return {"type": "ability", "id": "tail_sweep", "target": "all", "element": ""}
		return {
			"type": "ability",
			"id": "water_jet",
			"target_slot": _pick_lowest_hp_target(state),
			"element": "frost",
			"power": 25
		}

	# Phase 1: > 50% HP
	if turn % 4 == 0:
		return {"type": "ability", "id": "tail_sweep", "target": "all", "element": ""}
	if turn % 3 == 0:
		return {
			"type": "ability",
			"id": "water_jet",
			"target_slot": _pick_lowest_hp_target(state),
			"element": "frost",
			"power": 25
		}
	return {"type": "ability", "id": "tail_sweep", "target": "all", "element": ""}


## Pick the living party member with the lowest current HP.
static func _pick_lowest_hp_target(state: Node) -> int:
	var best_slot: int = 0
	var best_hp: int = 999999
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.get("is_alive", false):
			var hp: int = m.get("current_hp", 999999)
			if hp < best_hp:
				best_hp = hp
				best_slot = i
	return best_slot
