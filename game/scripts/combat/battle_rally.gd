class_name BattleRally
extends RefCounted
## Cael's Rally while it is in force (GAP-002, #158 slice a): who carries it,
## how long it lasts, what it does to a stat, and what ends it. Pure static
## rules over BattleState's member records, reached through BattleState's
## ability-hook fan-out (on_damage, on_fainted, on_status, on_turn_begin,
## on_turn_end, stat_pct) rather than by name from each seam.
##
## Design law: abilities.md § Cael — Rally. "Rally commands cost MP and last a
## set number of turns. Only one Rally can be active at a time (issuing a new
## one replaces the old one). Cael must be conscious for the Rally to persist —
## if he's Fainted or afflicted with Silence/Sleep, the active Rally ends."
##
## Each rallied ally carries its own copy in member["active_rally"]:
## {id, caster_slot, stat_pct, regen_pct, last_stand, remaining_turns}. Copies,
## not one shared record, because each ally counts the Rally down on its own
## turns — the rule every turn-counted effect in battle already follows
## (party statuses in battle_state.tick_statuses, enemy buffs in
## enemy.tick_buffs, including Pack Howl, the enemy-side party-wide buff).
## Second Wind says it outright: "at the start of each of their turns".

## Statuses that end the Rally when they land on its caster.
const BREAKING_STATUSES: Array[String] = ["silence", "sleep"]


## Give every living ally a fresh copy of the Rally. Any Rally already running
## ends first, so a second Rally replaces the first rather than stacking, and
## re-issuing the same one restarts its clock. [param effect] is
## {stat_pct, regen_pct, last_stand, turns}.
##
## Every ally gets the full [code]turns[/code], the caster included: a copy
## handed to a member whose turn is still open (Cael, issuing it) gets one more,
## because that turn's end would otherwise spend one of them.
##
## A caster who is already down, Silenced or Asleep cannot keep a Rally going,
## so it ends as it starts. The command refuses that case before MP is spent;
## this is the rule that holds whoever calls in.
static func start(state: Node, caster_slot: int, rally_id: String, effect: Dictionary) -> void:
	end(state)
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		var turns: int = int(effect.get("turns", 0)) + (1 if m.get("turn_open", false) else 0)
		m["active_rally"] = {
			"id": rally_id,
			"caster_slot": caster_slot,
			"stat_pct": (effect.get("stat_pct", {}) as Dictionary).duplicate(),
			"regen_pct": int(effect.get("regen_pct", 0)),
			"last_stand": bool(effect.get("last_stand", false)),
			"remaining_turns": turns,
		}
		state.ability_state_changed.emit(i)
	if not caster_can_sustain(state.get_member(caster_slot)):
		end(state)


## Whether [param caster] can keep a Rally going: conscious, and neither
## Silenced nor Asleep.
static func caster_can_sustain(caster: Dictionary) -> bool:
	if not caster.get("is_alive", false):
		return false
	for s: Dictionary in caster.get("active_statuses", []):
		if s.get("name", "") in BREAKING_STATUSES:
			return false
	return true


## End the Rally on every ally at once.
static func end(state: Node) -> void:
	for i: int in range(4):
		_clear(state, i)


## The Rally in force as {id, caster_slot}, or {} when none. It is in force
## while any ally still carries it.
static func active(state: Node) -> Dictionary:
	for i: int in range(4):
		var rally: Dictionary = state.get_member(i).get("active_rally", {})
		if not rally.is_empty():
			return {"id": rally["id"], "caster_slot": rally["caster_slot"]}
	return {}


## The Rally's +% to [param stat] on member [param m] (0 when none).
static func stat_pct(m: Dictionary, stat: String) -> int:
	return int(m.get("active_rally", {}).get("stat_pct", {}).get(stat, 0))


# ---------- BattleState ability hooks ----------


## Damage about to land on [param slot]. Unbreakable turns a lethal blow into
## one that leaves 1 HP, and having triggered once the Rally ends ("Triggers
## once then the Rally ends"). Returns the damage to apply.
static func on_damage(state: Node, slot: int, amount: int) -> int:
	var m: Dictionary = state.get_member(slot)
	var hp: int = int(m.get("current_hp", 0))
	if amount < hp or not m.get("active_rally", {}).get("last_stand", false):
		return amount
	end(state)
	return hp - 1


## A member fainted. If it was the caster the Rally ends for everyone; a fallen
## ally loses its own copy either way, since a Rally buffs living allies.
static func on_fainted(state: Node, slot: int) -> void:
	if active(state).get("caster_slot", -1) == slot:
		end(state)
	_clear(state, slot)


## A status landed. Silence or Sleep on the caster ends the Rally.
static func on_status(state: Node, slot: int, status: String) -> void:
	if status in BREAKING_STATUSES and active(state).get("caster_slot", -1) == slot:
		end(state)


## Start of a member's turn: Second Wind restores regen_pct of max HP. Returns
## heal events in BattleState's turn-event shape [{slot, dmg, type}], dmg
## being the HP figure shown.
static func on_turn_begin(state: Node, slot: int) -> Array:
	var m: Dictionary = state.get_member(slot)
	var regen_pct: int = int(m.get("active_rally", {}).get("regen_pct", 0))
	if regen_pct <= 0:
		return []
	var healed: int = state.heal(slot, int(m["max_hp"]) * regen_pct / 100)
	if healed <= 0:
		return []
	return [{"slot": slot, "dmg": healed, "type": "heal"}]


## End of a member's turn: count its copy of the Rally down.
static func on_turn_end(state: Node, slot: int) -> void:
	var rally: Dictionary = state.get_member(slot).get("active_rally", {})
	if rally.is_empty():
		return
	rally["remaining_turns"] = int(rally["remaining_turns"]) - 1
	if rally["remaining_turns"] <= 0:
		_clear(state, slot)


## Remove [param slot]'s copy, announcing the change if it had one.
static func _clear(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty() or (m.get("active_rally", {}) as Dictionary).is_empty():
		return
	m["active_rally"] = {}
	state.ability_state_changed.emit(slot)
