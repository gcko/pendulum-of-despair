extends RefCounted
## Cael's Rally while it is in force (GAP-002, #158 slice a): who carries it,
## how long it lasts, what it does to a stat, and what ends it. Pure static
## rules over BattleState's member records; BattleState calls in from the
## points where turns end, damage lands and statuses land.
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
static func start(state: Node, caster_slot: int, rally_id: String, effect: Dictionary) -> void:
	end(state)
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		m["active_rally"] = {
			"id": rally_id,
			"caster_slot": caster_slot,
			"stat_pct": (effect.get("stat_pct", {}) as Dictionary).duplicate(),
			"regen_pct": int(effect.get("regen_pct", 0)),
			"last_stand": bool(effect.get("last_stand", false)),
			"remaining_turns": int(effect.get("turns", 0)),
		}


## End the Rally on every ally at once.
static func end(state: Node) -> void:
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if not m.is_empty():
			m["active_rally"] = {}


## The Rally in force as {id, caster_slot}, or {} when none. It is in force
## while any ally still carries it.
static func active(state: Node) -> Dictionary:
	for i: int in range(4):
		var rally: Dictionary = state.get_member(i).get("active_rally", {})
		if not rally.is_empty():
			return {"id": rally["id"], "caster_slot": rally["caster_slot"]}
	return {}


## [param base] with the member's Rally bonus for [param stat] applied, floored
## to an integer like every other effective-stat read.
static func apply_stat(m: Dictionary, stat: String, base: int) -> int:
	var pct: int = int(m.get("active_rally", {}).get("stat_pct", {}).get(stat, 0))
	return base * (100 + pct) / 100


## Start of a member's turn: Second Wind restores regen_pct of max HP. Returns
## the HP restored. A turn begins once — prompting it again before it ends (a
## canceled command menu) restores nothing more.
static func begin_turn(state: Node, slot: int) -> int:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty() or not m.get("is_alive", false) or m.get("turn_open", false):
		return 0
	m["turn_open"] = true
	var regen_pct: int = int(m.get("active_rally", {}).get("regen_pct", 0))
	if regen_pct <= 0:
		return 0
	return state.heal(slot, int(m["max_hp"]) * regen_pct / 100)


## End of a member's turn: close the turn and count its copy of the Rally down.
static func end_turn(m: Dictionary) -> void:
	m["turn_open"] = false
	var rally: Dictionary = m.get("active_rally", {})
	if rally.is_empty():
		return
	rally["remaining_turns"] = int(rally["remaining_turns"]) - 1
	if rally["remaining_turns"] <= 0:
		m["active_rally"] = {}


## Damage about to land on [param m]. Unbreakable turns a lethal blow into one
## that leaves 1 HP, and having triggered once the Rally ends ("Triggers once
## then the Rally ends"). Returns the damage to apply.
static func absorb_lethal(state: Node, m: Dictionary, amount: int) -> int:
	var hp: int = int(m.get("current_hp", 0))
	if amount < hp or not m.get("active_rally", {}).get("last_stand", false):
		return amount
	end(state)
	return hp - 1


## A member fainted. If it was the caster the Rally ends for everyone; a fallen
## ally loses its own copy either way, since a Rally buffs living allies, and
## its turn closes so a revived ally's next turn begins normally.
static func on_fainted(state: Node, slot: int) -> void:
	if active(state).get("caster_slot", -1) == slot:
		end(state)
	var m: Dictionary = state.get_member(slot)
	m["active_rally"] = {}
	m["turn_open"] = false


## A status landed. Silence or Sleep on the caster ends the Rally.
static func on_status_applied(state: Node, slot: int, status: String) -> void:
	if status in BREAKING_STATUSES and active(state).get("caster_slot", -1) == slot:
		end(state)
