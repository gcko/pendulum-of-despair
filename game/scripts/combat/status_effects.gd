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
	# Poison: 8% max HP/turn, until cured (magic.md § Status Effect Reference > 'Poison').
	"poison": {"tick_pct": 0.08, "duration": UNTIL_CURED},
	# Burn: 5% max HP/turn for 3 turns (magic.md § Status Effect Reference > 'Burn').
	"burn": {"tick_pct": 0.05, "duration": 3},
	# Sleep: ATB frozen until damaged/cured (magic.md § Status Effect Reference > 'Sleep';
	# combat-formulas.md § Status Effect ATB Interactions).
	"sleep": {"atb": "frozen", "duration": UNTIL_CURED, "wake_on_damage": true},
	# Petrify: removed from combat, ATB gauge held at 0, until cured
	# (magic.md § Status Effect Reference > 'Petrify'; combat-formulas.md
	# § Status Effect ATB Interactions gives the gauge as "Frozen (0)" and
	# "Petrify resets to 0. Most severe status — recovery starts fresh."). The
	# gauge_zero flag is what separates it from Sleep: Sleep keeps the value it
	# froze at, Petrify keeps nothing, so a cure starts from an empty gauge.
	"petrify": {"atb": "frozen", "gauge_zero": true, "duration": UNTIL_CURED},
	# Paralysis: cannot act for 3 turns, does NOT wake on damage (#248; differs
	# from Sleep which wakes). Modeled as "incapacitates" (the gauge keeps filling
	# so the turn-based countdown advances on each skipped would-be turn — unlike
	# "frozen", which holds the gauge and has no clock).
	"paralysis": {"incapacitates": true, "duration": 3, "wake_on_damage": false},
	# Slow: ATB fill x0.5 for 5 turns (combat-formulas.md
	# § Fill Rate Modifiers + § Status Effect ATB Interactions).
	"slow": {"atb": "mod", "atb_mult": 0.5, "duration": 5},
	# Despair: ATB fill x0.75 for 4 turns (combat-formulas.md
	# § Fill Rate Modifiers + § Status Effect ATB Interactions). The
	# -20% damage-dealt half is deferred (needs an attacker-status param).
	"despair": {"atb": "mod", "atb_mult": 0.75, "duration": 4},
	# Silence: cannot cast, 4 turns (magic.md § Status Effect Reference > 'Silence').
	# Effect deferred.
	"silence": {"duration": 4},
	# Confusion: 3 turns or until damaged (magic.md § Status Effect Reference > 'Confusion').
	# Auto-target deferred.
	"confusion": {"duration": 3, "wake_on_damage": true},
	# Blind: -50% physical accuracy, 4 turns (magic.md § Status Effect Reference > 'Blind').
	# Effect deferred.
	"blind": {"duration": 4},
}

## Player-facing adjective for an ACTION-DENIAL announcement ("paralysis" ->
## "paralyzed"), which is a separate path from APPLICATION_NOTICES below: this
## table words the moment a turn is refused, that one words the moment a status
## lands. Only Paralysis denies a turn out loud — a gauge-frozen member is
## passed over in silence (combat-formulas.md § Status Effect ATB Interactions)
## — so the sleep/petrify entries here are pre-registered wording for a future
## denial announcement, even though both statuses do announce on landing.
## Anything unlisted falls back to its raw status name rather than reading as
## another status.
const ADJECTIVES: Dictionary = {
	"paralysis": "paralyzed",
	"sleep": "asleep",
	"petrify": "petrified",
}

## Player-facing line announcing that a status has just landed, as a format
## string taking the bearer's name. Every entry is the canonical wording from
## docs/story/script/battle-dialogue.md § Status Effect Notifications with
## "[Character]" replaced by "%s". test_status_effects walks RULES — not this
## table — and demands each status both HAS a line here and matches the shipped
## game/data/dialogue/battle_status_effect_notifications.json verbatim, so
## neither rewording an entry nor dropping one can slip through: every status
## the game can inflict must keep a canonical line. A name the registry does not
## know lands silently.
const APPLICATION_NOTICES: Dictionary = {
	"poison": "%s is Poisoned!",
	"burn": "%s is Burning!",
	"sleep": "%s fell Asleep!",
	"petrify": "%s is Petrified!",
	"paralysis": "%s is Paralyzed!",
	"slow": "%s is Slowed!",
	"despair": "%s is afflicted with Despair!",
	"silence": "%s is Silenced!",
	"confusion": "%s is Confused!",
	"blind": "%s is Blinded!",
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


## Whether this status holds the bearer's gauge at 0 for as long as it lasts,
## rather than at the value it froze at. True only for Petrify, which is what
## makes recovery start fresh on cure; Sleep and Stop resume from where they
## stopped (combat-formulas.md § Status Effect ATB Interactions).
static func zeroes_gauge(status: String) -> bool:
	return RULES.get(status, {}).get("gauge_zero", false)


## The status denying this combatant its turn, or "" when it can act. A
## gauge-frozen status (Sleep/Petrify) outranks Paralysis whenever a combatant
## carries both: a frozen bearer must be passed over untouched, and answering
## "paralysis" would spend the very gauge value the freeze exists to protect.
## The order the statuses were applied in must not decide it (#300).
static func blocking_status(active_statuses: Array) -> String:
	var acting_denial: String = ""
	for s: Dictionary in active_statuses:
		var status_name: String = s.get("name", "")
		if not is_incapacitating(status_name):
			continue
		if atb_effect(status_name) == "frozen":
			return status_name
		if acting_denial == "":
			acting_denial = status_name
	return acting_denial


## The "Sable is Poisoned!" line for a status landing on `bearer_name`, or ""
## when the status has no canonical announcement to make.
static func application_notice(status: String, bearer_name: String) -> String:
	var template: String = APPLICATION_NOTICES.get(status, "")
	if template.is_empty():
		return ""
	return template % bearer_name


## ATB fill multiplier for "mod" statuses (1.0 when none).
static func atb_mult(status: String) -> float:
	return RULES.get(status, {}).get("atb_mult", 1.0)


## End-of-turn HP tick as a fraction of max HP (0.0 when none).
static func tick_pct(status: String) -> float:
	return RULES.get(status, {}).get("tick_pct", 0.0)


## Whether taking damage cures this status (Sleep, Confusion).
static func wakes_on_damage(status: String) -> bool:
	return RULES.get(status, {}).get("wake_on_damage", false)


## Adjective for a battle announcement, e.g. "Edren is paralyzed and can't move!"
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
## Returns {"frozen": bool, "zeroed": bool, "mods": Array[float]} — freeze the
## gauge, hold it at 0, and the fill multipliers to stack. Pure — unit-testable
## without a battle scene; the battle layer pushes the result to ATBSystem every
## frame, for the party (#298) and the enemies alike.
static func atb_state(active_statuses: Array) -> Dictionary:
	var frozen: bool = false
	var zeroed: bool = false
	var mods: Array[float] = []
	for s: Dictionary in active_statuses:
		var status_name: String = s.get("name", "")
		if zeroes_gauge(status_name):
			zeroed = true
		match atb_effect(status_name):
			"frozen":
				frozen = true
			"mod":
				mods.append(atb_mult(status_name))
	return {"frozen": frozen, "zeroed": zeroed, "mods": mods}
