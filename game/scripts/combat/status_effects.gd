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
	# Poison: 8% max HP/turn, until cured (magic.md:1392).
	"poison": {"tick_pct": 0.08, "duration": UNTIL_CURED},
	# Burn: 5% max HP/turn for 3 turns (magic.md:1393).
	"burn": {"tick_pct": 0.05, "duration": 3},
	# Sleep: ATB frozen until damaged/cured (magic.md:661, combat-formulas.md:734).
	"sleep": {"atb": "frozen", "duration": UNTIL_CURED, "wake_on_damage": true},
	# Petrify: removed from combat, ATB frozen, until cured (magic.md:694).
	"petrify": {"atb": "frozen", "duration": UNTIL_CURED},
	# Slow: ATB fill x0.5 for 5 turns (combat-formulas.md:720,732).
	"slow": {"atb": "mod", "atb_mult": 0.5, "duration": 5},
	# Despair: ATB fill x0.75 for 4 turns (combat-formulas.md:721,737). The
	# -20% damage-dealt half is deferred (needs an attacker-status param).
	"despair": {"atb": "mod", "atb_mult": 0.75, "duration": 4},
	# Silence: cannot cast, 4 turns (magic.md:683). Effect deferred.
	"silence": {"duration": 4},
	# Confusion: 3 turns or until damaged (magic.md:672). Auto-target deferred.
	"confusion": {"duration": 3, "wake_on_damage": true},
	# Blind: -50% physical accuracy, 4 turns (magic.md:727). Effect deferred.
	"blind": {"duration": 4},
}


## Whether the registry knows this status (and 2b can inflict it).
static func is_known(status: String) -> bool:
	return RULES.has(status)


## ATB effect: "none", "frozen" (Sleep/Petrify), or "mod" (Slow/Despair).
static func atb_effect(status: String) -> String:
	return RULES.get(status, {}).get("atb", "none")


## ATB fill multiplier for "mod" statuses (1.0 when none).
static func atb_mult(status: String) -> float:
	return RULES.get(status, {}).get("atb_mult", 1.0)


## End-of-turn HP tick as a fraction of max HP (0.0 when none).
static func tick_pct(status: String) -> float:
	return RULES.get(status, {}).get("tick_pct", 0.0)


## Whether taking damage cures this status (Sleep, Confusion).
static func wakes_on_damage(status: String) -> bool:
	return RULES.get(status, {}).get("wake_on_damage", false)


## Canonical turns for a status (UNTIL_CURED for persistent ones).
static func default_duration(status: String) -> int:
	return int(RULES.get(status, {}).get("duration", UNTIL_CURED))


## Resolve the duration to apply: a spell's explicit value wins, else canonical.
static func resolve_duration(status: String, explicit: Variant) -> int:
	if explicit != null:
		return int(explicit)
	return default_duration(status)
