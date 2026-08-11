extends RefCounted
## Status-effect rules registry (GAP-003). Pure static lookup — no state.
##
## Single source of truth for how each combat status behaves: its ATB effect,
## per-turn HP tick, canonical duration, and whether damage cures it. Every
## value traces to docs/story/magic.md and docs/story/combat-formulas.md.
##
## Scope (Bundle 2b): player-cast offensive debuffs on enemies. Statuses whose
## *behavioral* effect needs an unbuilt system are still inflictable here, but
## their effect is deferred (tracked on #159):
##   - silence (blocks enemy casting), blind (-50% enemy accuracy),
##     confusion (auto-target) — need enemy-AI hooks (GAP-009).
##   - despair's -20% damage-dealt needs an attacker-status param in DamageCalc.
##   - stop (3 realtime sec on an enemy) needs enemy realtime ticking — omitted
##     from the registry here, so a Stop spell is a graceful no-op for now.

## Sentinel duration: status persists until cured (no per-turn countdown).
const UNTIL_CURED: int = -1

## status_name -> rule. Omitted keys fall back to defaults via the accessors
## below: atb "none", atb_mult 1.0, tick_pct 0.0, wake_on_damage false.
## atb is "none" | "frozen" | "mod"; tick_pct is fraction of MAX HP lost at the
## end of the bearer's turn. Sources are cited per status.
const RULES: Dictionary = {
	# Poison: 8% max HP/turn, until cured (magic.md:1477).
	"poison": {"tick_pct": 0.08, "duration": UNTIL_CURED},
	# Burn: 5% max HP/turn for 3 turns (magic.md:1478).
	"burn": {"tick_pct": 0.05, "duration": 3},
	# Sleep: ATB frozen until damaged/cured (magic.md:746, combat-formulas.md:734).
	"sleep": {"atb": "frozen", "duration": UNTIL_CURED, "wake_on_damage": true},
	# Petrify: removed from combat, ATB frozen, until cured (magic.md:779).
	"petrify": {"atb": "frozen", "duration": UNTIL_CURED},
	# Paralysis: cannot act for 3 turns, does NOT wake on damage (#248; differs
	# from Sleep which wakes). Modeled as "incapacitates" (the gauge keeps filling
	# so the turn-based countdown advances on each skipped would-be turn — unlike
	# "frozen", which holds the gauge and has no clock).
	"paralysis": {"incapacitates": true, "duration": 3, "wake_on_damage": false},
	# Slow: ATB fill x0.5 for 5 turns (combat-formulas.md:720,732).
	"slow": {"atb": "mod", "atb_mult": 0.5, "duration": 5},
	# Despair: ATB fill x0.75 for 4 turns (combat-formulas.md:721,737). The
	# -20% damage-dealt half is deferred (needs an attacker-status param).
	"despair": {"atb": "mod", "atb_mult": 0.75, "duration": 4},
	# Silence: cannot cast, 4 turns (magic.md:768). Effect deferred.
	"silence": {"duration": 4},
	# Confusion: 3 turns or until damaged (magic.md:757). Auto-target deferred.
	"confusion": {"duration": 3, "wake_on_damage": true},
	# Blind: -50% physical accuracy, 4 turns (magic.md:812). Effect deferred.
	"blind": {"duration": 4},
}

## Player-facing adjective for an action-denial announcement ("paralysis" ->
## "paralysed"). Only Paralysis reaches an announcement today: a gauge-frozen
## member is passed over in silence (combat-formulas.md § Status Effect ATB
## Interactions), so the sleep/petrify entries are pre-registered wording for a
## future announcement path, not live behaviour. Anything unlisted falls back to
## its raw status name rather than reading as another status.
const ADJECTIVES: Dictionary = {
	"paralysis": "paralysed",
	"sleep": "asleep",
	"petrify": "petrified",
}


## Whether the registry knows this status (and 2b can inflict it).
static func is_known(status: String) -> bool:
	return RULES.has(status)


## ATB effect: "none", "frozen" (Sleep/Petrify), or "mod" (Slow/Despair).
static func atb_effect(status: String) -> String:
	return RULES.get(status, {}).get("atb", "none")


## Whether the bearer cannot take a turn — Paralysis (explicit) or the
## gauge-frozen action-denial statuses (Sleep/Petrify). The battle layer denies
## the turn either way, but only Paralysis consumes one (announce, tick, reset);
## a gauge-frozen bearer is passed over untouched so the frozen value survives.
static func is_incapacitating(status: String) -> bool:
	var rule: Dictionary = RULES.get(status, {})
	return rule.get("incapacitates", false) or rule.get("atb", "none") == "frozen"


## ATB fill multiplier for "mod" statuses (1.0 when none).
static func atb_mult(status: String) -> float:
	return RULES.get(status, {}).get("atb_mult", 1.0)


## End-of-turn HP tick as a fraction of max HP (0.0 when none).
static func tick_pct(status: String) -> float:
	return RULES.get(status, {}).get("tick_pct", 0.0)


## Whether taking damage cures this status (Sleep, Confusion).
static func wakes_on_damage(status: String) -> bool:
	return RULES.get(status, {}).get("wake_on_damage", false)


## Adjective for a battle announcement, e.g. "Edren is paralysed and can't move!"
static func display_adjective(status: String) -> String:
	return ADJECTIVES.get(status, status)


## Canonical turns for a status (UNTIL_CURED for persistent ones).
static func default_duration(status: String) -> int:
	return int(RULES.get(status, {}).get("duration", UNTIL_CURED))


## Resolve the duration to apply: a spell's explicit value wins, else canonical.
static func resolve_duration(status: String, explicit: Variant) -> int:
	if explicit != null:
		return int(explicit)
	return default_duration(status)


## Combined ATB state for a list of active status dicts (each {"name": ...}).
## Returns {"frozen": bool, "mods": Array[float]}. Pure — unit-testable without
## a battle scene; the battle layer pushes the result to ATBSystem.
static func atb_state(active_statuses: Array) -> Dictionary:
	var frozen: bool = false
	var mods: Array[float] = []
	for s: Dictionary in active_statuses:
		var status_name: String = s.get("name", "")
		match atb_effect(status_name):
			"frozen":
				frozen = true
			"mod":
				mods.append(atb_mult(status_name))
	return {"frozen": frozen, "mods": mods}
