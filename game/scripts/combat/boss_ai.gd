extends RefCounted
## Data-driven boss AI interpreter (GAP-009).
##
## Reads `enemy_data.boss_ai` (an ordered `phases` array + a `moves` table) and
## per-Enemy `ai_state` to choose each boss turn's action. It only SELECTS;
## resolution reuses the regular action dict consumed by
## BattleEnemyTurn._apply_action (attack/ability/heal/spawn/skip).
##
## Schema + conventions: docs/story/bestiary/enemy-ability-conventions.md §3.
## Boss scripts: docs/story/bestiary/bosses.md.

const BattleAI = preload("res://scripts/combat/battle_ai.gd")


## True if this enemy carries a data-driven boss script.
static func has_script(enemy_data: Dictionary) -> bool:
	return enemy_data.has("boss_ai")


## Select a boss action. Mutates enemy.ai_state (phase/mode/charge/last_move).
static func select_action(
	enemy: Node, turn_counter: int, state: Node, enemies: Array
) -> Dictionary:
	var data: Dictionary = enemy.enemy_data.get("boss_ai", {})
	var moves: Dictionary = data.get("moves", {})
	var ai: Dictionary = enemy.ai_state

	# A telegraphed move charged last turn — resolve it now (the resolve turn).
	# NOTE: telegraphed moves are only supported in NON-modal phases (no Act-I boss
	# combines `modes` with a `telegraph`). This short-circuit intentionally skips
	# mode re-sync; a future modal+telegraph boss would need that added here.
	var charging: String = ai.get("charging", "")
	if not charging.is_empty():
		ai["charging"] = ""
		ai["last_move"] = charging
		return _build_action(moves.get(charging, {}), charging, state)

	var phase: Dictionary = _current_phase(enemy, data)
	var msg: String = _enter_phase(ai, phase)

	# Pick the active rule set (mode-aware) and keep `untargetable` synced.
	var rules: Array = []
	var mode_def: Dictionary = {}
	if phase.has("modes"):
		var mode_name: String = ai.get("mode", phase.get("start_mode", ""))
		mode_def = phase["modes"].get(mode_name, {})
		rules = mode_def.get("rules", [])
		enemy.set_meta("untargetable", bool(mode_def.get("untargetable", false)))
		if ai.get("announced_mode", "") != mode_name:
			ai["announced_mode"] = mode_name
			if mode_def.has("enter_message"):
				msg = mode_def["enter_message"]
	else:
		rules = phase.get("rules", [])

	var move_id: String = _first_matching_move(rules, turn_counter, ai, state, enemies, enemy)

	# Advance the surface/dive mode cycle after acting.
	if phase.has("modes"):
		ai["turns_in_mode"] = int(ai.get("turns_in_mode", 0)) + 1
		if ai["turns_in_mode"] >= int(mode_def.get("turns", 1)):
			ai["mode"] = mode_def.get("next", ai.get("mode", ""))
			ai["turns_in_mode"] = 0

	if move_id.is_empty():
		ai["last_move"] = "defend"
		return _with_message({"type": "defend", "target_slot": -1, "ability_id": ""}, msg)

	var move: Dictionary = moves.get(move_id, {})

	# Telegraphed move: this turn is the charge (no damage); resolve next turn.
	if move.has("telegraph"):
		ai["charging"] = move_id
		ai["last_move"] = move_id
		return _with_message({"type": "skip", "id": move_id, "message": move["telegraph"]}, msg)

	ai["last_move"] = move_id
	return _with_message(_build_action(move, move_id, state), msg)


## The first phase (ordered high-HP -> low-HP) whose hp_above the ratio exceeds.
## At exactly a threshold the LOWER phase wins (hp_percent <= X enters the next
## phase), matching bosses.md.
static func _current_phase(enemy: Node, data: Dictionary) -> Dictionary:
	var phases: Array = data.get("phases", [])
	var max_hp: int = enemy.enemy_data.get("hp", 1)
	var ratio: float = float(enemy.current_hp) / float(maxi(1, max_hp))
	for phase: Dictionary in phases:
		if ratio > float(phase.get("hp_above", 0.0)):
			return phase
	return phases[phases.size() - 1] if not phases.is_empty() else {}


## Detect a phase change, reset mode bookkeeping, return any on_enter_message.
## The phase message fires at most ONCE per phase (a persistent announced flag),
## so HP oscillation across a threshold — e.g. Vein Guardian's Reconstruct healing
## back above 50% then re-dropping — does not re-emit the one-time flavor line.
static func _enter_phase(ai: Dictionary, phase: Dictionary) -> String:
	var name: String = phase.get("name", "")
	if ai.get("phase", "") == name:
		return ""
	ai["phase"] = name
	ai["mode"] = phase.get("start_mode", "")
	ai["turns_in_mode"] = 0
	ai["announced_mode"] = phase.get("start_mode", "")  # initial mode is silent
	var msg: String = str(phase.get("on_enter_message", ""))
	if msg.is_empty():
		return ""
	var key: String = "announced_phase_" + name
	if ai.get(key, false):
		return ""
	ai[key] = true
	return msg


## First rule whose `when` conditions all hold (FF6-style first-match). Marks a
## fired `once` gate in ai_state. Returns "" if nothing matched.
static func _first_matching_move(
	rules: Array, turn: int, ai: Dictionary, state: Node, enemies: Array, enemy: Node
) -> String:
	for rule: Dictionary in rules:
		var when: Dictionary = rule.get("when", {})
		if _condition_met(when, turn, ai, state, enemies, enemy):
			if when.has("once"):
				ai[when["once"]] = true
			return rule.get("move", "")
	return ""


## Evaluate the fixed declarative condition keys (all must hold = AND).
static func _condition_met(
	when: Dictionary, turn: int, ai: Dictionary, state: Node, enemies: Array, enemy: Node
) -> bool:
	for key: String in when:
		match key:
			"default":
				pass
			"every_n":
				if turn % maxi(1, int(when[key])) != 0:
					return false
			"last_move":
				if ai.get("last_move", "") != when[key]:
					return false
			"position":
				if not _any_in_row(state, str(when[key])):
					return false
			"adds_below":
				if _count_adds(enemies, enemy) >= int(when[key]):
					return false
			"once":
				if bool(ai.get(when[key], false)):
					return false
			_:
				return false  # unknown key -> condition cannot be satisfied
	return true


## Build the action dict from a move definition.
static func _build_action(move: Dictionary, move_id: String, state: Node) -> Dictionary:
	var mtype: String = move.get("type", "ability")
	if mtype == "heal":
		return {"type": "heal", "id": move_id, "target": "self", "value": int(move.get("value", 0))}
	if mtype == "spawn":
		return {
			"type": "spawn",
			"id": move_id,
			"enemies": move.get("enemies", []),
			"cap": int(move.get("cap", 99)),
		}
	if mtype == "skip":
		return {"type": "skip", "id": move_id}
	var target: String = move.get("target", "single")
	var action: Dictionary = {
		"type": "ability",
		"id": move_id,
		"ability_id": move_id,
		"target": target,
		"atk_type": move.get("atk_type", "attack"),
		"element": move.get("element", ""),
		"power": int(move.get("spell_power", 0)),
		"ability_mult": float(move.get("ability_mult", 1.0)),
		"hits": int(move.get("hits", 1)),
		"status": move.get("status", ""),
		"status_rate": int(move.get("status_rate", 0)),
		"status_duration": move.get("status_duration", null),
		"buff": move.get("buff", {}),
	}
	action["target_slot"] = (
		_select_target(str(move.get("selector", "random")), state) if target == "single" else -1
	)
	return action


## Resolve a single-target selector to a party slot.
static func _select_target(selector: String, state: Node) -> int:
	match selector:
		"highest_threat":
			return state.get_highest_threat_slot()
		"lowest_hp":
			return BattleAI._pick_lowest_hp_target(state)
		"back":
			return _pick_in_row(state, "back")
		_:
			return BattleAI.pick_alive_target(state)


## Pick a living member in the given row, else any living member.
static func _pick_in_row(state: Node, row: String) -> int:
	var matches: Array[int] = []
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.get("is_alive", false) and m.get("row", "front") == row:
			matches.append(i)
	if matches.is_empty():
		return BattleAI.pick_alive_target(state)
	return matches[randi() % matches.size()]


## True if any living member occupies the given row.
static func _any_in_row(state: Node, row: String) -> bool:
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.get("is_alive", false) and m.get("row", "front") == row:
			return true
	return false


## Living adds = living enemies other than the boss itself (its summoned minions).
static func _count_adds(enemies: Array, boss: Node) -> int:
	var count: int = 0
	for e: Node in enemies:
		if e != boss and e.is_alive:
			count += 1
	return count


## Attach a one-time transition message to the action. If the action already
## carries one (a telegraph tell), concatenate rather than clobber.
static func _with_message(action: Dictionary, msg: String) -> Dictionary:
	if msg.is_empty():
		return action
	var existing: String = str(action.get("message", ""))
	action["message"] = (existing + " " + msg) if not existing.is_empty() else msg
	return action
