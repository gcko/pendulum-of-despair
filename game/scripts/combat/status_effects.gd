extends RefCounted
## Status-effect rules registry (GAP-003). Pure static lookup — no state.
##
## Single source of truth for how each combat status behaves: its ATB effect,
## per-turn HP tick, canonical duration, and whether damage cures it. Every
## value traces to docs/story/magic.md and docs/story/combat-formulas.md.
##
## Scope: the ailments spells and enemies inflict (Bundle 2b), plus Haste, the
## one positive status built so far (#246; is_positive), and Berserk, which no
## content inflicts yet. Where part of a status's *behavioral* effect needs an
## unbuilt system, the status is still in the registry but that part is deferred
## (tracked on #246). Despair's -20% damage dealt (damage_dealt_mult) and Blind's -50% physical
## accuracy (physical_accuracy_mult) are applied by BattleDamageMods (#246).
## Silence blocks casting on both sides: BattleMagicCommand for the party, and
## BattleAI / BossAI for enemies, which skip spell moves (#246). Stop is the one
## status counted in real-time seconds rather than turns: see is_realtime().
## Confusion and Berserk take the command away on both sides: BattleAutoAction
## makes the bearer's basic attack for it (#246).

## Sentinel duration: status persists until cured (no per-turn countdown).
const UNTIL_CURED: int = -1

## status_name -> rule. Omitted keys fall back to defaults via the accessors
## below: atb "none", atb_mult 1.0, tick_pct 0.0, wake_on_damage false,
## positive false, item_proof false.
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
	# It also takes the bearer off the field (#246): untargetable, and no longer
	# standing between the party and victory (see removes_from_combat).
	"petrify":
	{
		"atb": "frozen",
		"gauge_zero": true,
		"duration": UNTIL_CURED,
		"removes_from_combat": true,
	},
	# Paralysis: cannot act for 3 turns, does NOT wake on damage (#248; differs
	# from Sleep which wakes). Modeled as "incapacitates" (the gauge keeps filling
	# so the turn-based countdown advances on each skipped would-be turn — unlike
	# "frozen", which holds the gauge and has no clock).
	"paralysis": {"incapacitates": true, "duration": 3, "wake_on_damage": false},
	# Slow: ATB fill x0.5 for 5 turns (combat-formulas.md
	# § Fill Rate Modifiers + § Status Effect ATB Interactions).
	"slow": {"atb": "mod", "atb_mult": 0.5, "duration": 5},
	# Despair: ATB fill x0.75 for 4 turns, and -20% damage dealt (combat-formulas.md
	# § Fill Rate Modifiers + § Status Effect ATB Interactions; magic.md § Status
	# Effect Reference > 'Despair').
	"despair":
	{
		"atb": "mod",
		"atb_mult": 0.75,
		"duration": 4,
		"item_proof": true,
		"damage_dealt_mult": 0.8,
	},
	# Silence: cannot cast, 4 turns (magic.md § Status Effect Reference > 'Silence').
	# Enforced by the caster's side, not here (see the scope note above).
	"silence": {"duration": 4},
	# Confusion: 3 turns or until damaged (magic.md § Status Effect Reference > 'Confusion').
	# Its auto-attack is BattleAutoAction's.
	"confusion": {"duration": 3, "wake_on_damage": true},
	# Blind: -50% physical accuracy, 4 turns (magic.md § Status Effect Reference > 'Blind').
	"blind": {"duration": 4, "physical_accuracy_mult": 0.5},
	# Stop: gauge "Frozen at current value", cannot act, "3 real-time seconds"
	# counted only while battle time runs (combat-formulas.md § Status Effect ATB
	# Interactions; magic.md § Stillwatch). Its duration is SECONDS, not turns.
	"stop": {"atb": "frozen", "duration": 3, "realtime": true, "item_proof": true},
	# Haste (Quickstep): ATB fill x1.5 for 5 turns (combat-formulas.md
	# § Fill Rate Modifiers + § Status Effect ATB Interactions). A positive
	# status (magic.md § Status Effect Reference): a KO ends it, a cure-all keeps it.
	"haste": {"atb": "mod", "atb_mult": 1.5, "duration": 5, "positive": true},
	# Berserk: ATB fill x1.25, until cured, Purge its only cure (combat-formulas.md
	# § Fill Rate Modifiers + § Status Effect ATB Interactions; magic.md § Status
	# Effect Reference > 'Berserk'). Its auto-attack is BattleAutoAction's.
	"berserk": {"atb": "mod", "atb_mult": 1.25, "duration": UNTIL_CURED, "item_proof": true},
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
	"stop": "%s is Stopped!",
	"haste": "%s is Hastened!",
	"berserk": "%s is Berserk!",
}

## The line for a combatant a hit has woken, "[Character] woke up!" from
## battle-dialogue.md § Status Effect Notifications, "[Character]" replaced by "%s".
## Used for party members and enemies alike.
const WAKE_NOTICE: String = "%s woke up!"

## The line for a status a spell, item or ability has lifted (#515), "[Status]
## was cured!" from battle-dialogue.md § Status Effect Notifications, "[Status]"
## replaced by "%s". It takes the status's name as magic.md § Status Effect
## Reference writes it: Poison, Sleep, Berserk.
const CURE_NOTICE: String = "%s was cured!"

## The line for a status that ran out on its own (#515), verbatim from the same
## section. Only Poison and Silence have one there; anything else ends in silence.
const WEARS_OFF_NOTICES: Dictionary = {
	"poison": "Poison wears off.",
	"silence": "Silence wears off.",
}


## The "Edren woke up!" line for [param bearer_name].
static func wake_notice(bearer_name: String) -> String:
	return WAKE_NOTICE % bearer_name


## The "Poison was cured!" line for [param status].
static func cure_notice(status: String) -> String:
	return CURE_NOTICE % status.capitalize()


## The "Poison wears off." line for [param status], or "" when it has none.
static func wears_off_notice(status: String) -> String:
	return WEARS_OFF_NOTICES.get(status, "")


## Whether this status takes its bearer out of the fight (Petrify, "removed
## from combat", magic.md § Status Effect Reference): it cannot be targeted, and
## a field of enemies that are all dead or removed is a won battle.
static func removes_from_combat(status: String) -> bool:
	return RULES.get(status, {}).get("removes_from_combat", false)


## Whether this status is a buff rather than an ailment (magic.md § Status
## Effect Reference, "Positive"): Haste. A KO ends it, and an item that clears
## statuses leaves it alone.
static func is_positive(status: String) -> bool:
	return RULES.get(status, {}).get("positive", false)


## Whether a clear-all item (Starbloom Tea) leaves this ailment on (items.md
## § Status Cures): Stop wears off only and Berserk yields only to the Purge
## spell, while Despair yields only to the items that name it in their own
## cures (Pallor Salve, Pallor Antidote, Hope Shard) or to Hollow Mend.
static func is_item_proof(status: String) -> bool:
	return RULES.get(status, {}).get("item_proof", false)


## Whether the registry knows this status, so a spell can land it.
static func is_known(status: String) -> bool:
	return RULES.has(status)


## Whether this status's duration is real-time seconds (Stop) rather than turns.
## A realtime status is counted down by the battle seconds the ATB gauges
## advanced, never by a turn ending (combat-formulas.md § Status Effect ATB
## Interactions: "Not turn-based; pauses in Wait mode").
static func is_realtime(status: String) -> bool:
	return RULES.get(status, {}).get("realtime", false)


## ATB effect: "none", "frozen" (Sleep/Petrify/Stop), or "mod" (Slow/Despair/Haste).
static func atb_effect(status: String) -> String:
	return RULES.get(status, {}).get("atb", "none")


## Whether the bearer cannot take a turn — Paralysis (explicit) or the
## gauge-frozen action-denial statuses (Sleep/Petrify/Stop). The battle layer denies
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
## gauge-frozen status (Sleep/Petrify/Stop) outranks Paralysis whenever a combatant
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


## The multiplier this status puts on all damage its bearer deals (Despair's
## 0.8), 1.0 when none. Healing is not damage, so it never applies there.
static func damage_dealt_mult(status: String) -> float:
	return RULES.get(status, {}).get("damage_dealt_mult", 1.0)


## The multiplier this status puts on its bearer's physical hit rate (Blind's
## 0.5), 1.0 when none. A spell's hit rate is never touched.
static func physical_accuracy_mult(status: String) -> float:
	return RULES.get(status, {}).get("physical_accuracy_mult", 1.0)


## End-of-turn HP tick as a fraction of max HP (0.0 when none).
static func tick_pct(status: String) -> float:
	return RULES.get(status, {}).get("tick_pct", 0.0)


## Whether taking damage cures this status (Sleep, Confusion).
static func wakes_on_damage(status: String) -> bool:
	return RULES.get(status, {}).get("wake_on_damage", false)


## Adjective for a battle announcement, e.g. "Edren is paralyzed and can't move!"
static func display_adjective(status: String) -> String:
	return ADJECTIVES.get(status, status)


## Canonical turns for a status (UNTIL_CURED for persistent ones), or seconds
## for a realtime one (Stop).
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
