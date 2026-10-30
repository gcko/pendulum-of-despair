extends RefCounted
## A BattleState ability hook (see BattleState.ABILITY_HOOKS) for the positive
## effects ally spells land (#503): a KO ends them, as it ends a Rally and
## Bulwark's state (2026-10-29 ruling).
##
## Two kinds live here:
##   - positive statuses in BattleState's active_statuses (Haste, Quickstep's,
##     the one StatusEffects.is_positive names so far);
##   - spell buffs in member["spell_buffs"], {kind: {pct, remaining_turns}},
##     where kind is a stat ("atk", "def", "mag", "mdef") for a stat buff
##     (Ironhide, Wardglass, Rallying Cry, Attunement, Bulwark Line, Leyward),
##     REGEN for Kindle Breath and Rekindling's regeneration, RERAISE for
##     Last Breath's auto-revive, whose remaining_turns is UNTIMED: it lasts
##     "until triggered or battle ends" (magic.md § 62 Last Breath), or
##     FORGESHIELD for Forgeshield's ward, also UNTIMED, whose pct is the HP of
##     magic it absorbs before it shatters (magic.md § 79 Forgeshield).
##
## Spell buffs are kept out of active_statuses because every status there must
## announce a canonical line on landing (test_status_effects.gd), and
## battle-dialogue.md § Status Effect Notifications has none for Regen or the
## stat-ups. Being out of that list is also what keeps an item or spell that
## cures ailments from touching them, as magic.md § Status Effect Reference
## says of every positive status.
##
## Each buff is a percentage term of its own on the stat, so it adds to an item
## boost or a Rally rather than replacing it (combat-formulas.md § Buff & Debuff
## Interaction). Two buffs of one kind do not stack (progression.md, "Buff
## stacking"): the stronger stays (see grant). A buff is counted down on its
## bearer's own turns, as party statuses are.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## The spell_buffs kind for regeneration.
const REGEN: String = "regen"

## The spell_buffs kind for Last Breath's Reraise; its pct is the share of max
## HP the bearer stands again with.
const RERAISE: String = "reraise"

## The spell_buffs kind for Forgeshield; its pct is the HP of the next spell's
## damage it absorbs, 150 + the caster's MAG when cast.
const FORGESHIELD: String = "forgeshield"

## A spell buff's remaining_turns when no turn count ends it.
const UNTIMED: int = -1

## Negative statuses a KO also clears, so a revived member acts normally
## (2026-10-30 ruling).
const KO_CLEARED_STATUSES: Array[String] = ["confusion", "berserk"]


## Land a spell buff of [param kind] on [param slot]: [param pct] percent for
## [param turns] of the bearer's turns, plus one when the bearer's turn is open
## (a self-cast), since that turn's end would otherwise spend one, as
## BattleRally.start counts it. One kind keeps the stronger (2026-10-30
## ruling): a weaker buff leaves a stronger one in force, on its own clock, and
## an equal or stronger one replaces it with a fresh duration. [param turns]
## UNTIMED keeps it until something else ends it. Returns whether it landed: a
## fallen member carries none, and a weaker buff changes nothing.
static func grant(state: Node, slot: int, kind: String, pct: int, turns: int) -> bool:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty() or not m.get("is_alive", false):
		return false
	var buffs: Dictionary = m.get("spell_buffs", {})
	if int(buffs.get(kind, {}).get("pct", 0)) > pct:
		return false
	if turns != UNTIMED and m.get("turn_open", false):
		turns += 1
	buffs[kind] = {"pct": pct, "remaining_turns": turns}
	m["spell_buffs"] = buffs
	state.ability_state_changed.emit(slot)
	return true


## A member fainted: every positive status and spell buff on it ends, and so do
## Confusion and Berserk (KO_CLEARED_STATUSES). A Reraise ends with them, spent
## on this fall: once BattleState has announced it (member_died), the member
## stands again at its share of max HP, at least 1, as a revival spell stands
## them, so the battle hears the fall and then the revive, and puts them back
## on the ATB with an empty gauge.
static func on_fainted(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	var reraise: int = int(m.get("spell_buffs", {}).get(RERAISE, {}).get("pct", 0))
	if reraise > 0:
		var hp: int = maxi(1, int(m.get("max_hp", 0)) * reraise / 100)
		state.member_died.connect(
			func(_fallen: int) -> void: state.heal(slot, hp, true), CONNECT_ONE_SHOT
		)
	for s: Dictionary in (m.get("active_statuses", []) as Array).duplicate():
		var status: String = s.get("name", "")
		if StatusEffects.is_positive(status) or status in KO_CLEARED_STATUSES:
			state.remove_status(slot, status)
	if not (m.get("spell_buffs", {}) as Dictionary).is_empty():
		m["spell_buffs"] = {}
		state.ability_state_changed.emit(slot)


static func on_damage(_state: Node, _slot: int, amount: int) -> int:
	return amount


static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


## Start of a member's turn: regeneration restores its percentage of max HP
## ("Restore 5% max HP per turn", magic.md § Status Effect Reference > 'Regen'),
## at least 1 as a Poison tick takes at least 1. Returns heal events in
## BattleState's turn-event shape [{slot, dmg, type}].
##
## Cael's Second Wind (the Rally's regen_pct in member["active_rally"]) and a
## spell's Regen are one regen effect, and the stronger applies (2026-10-30
## ruling). BattleRally comes before this hook in BattleState.ABILITY_HOOKS, so
## its heal has already landed: an equal or stronger Second Wind leaves the
## spell's tick nothing to add, and a weaker one leaves it only the rest.
static func on_turn_begin(state: Node, slot: int) -> Array:
	var m: Dictionary = state.get_member(slot)
	var pct: int = int(m.get("spell_buffs", {}).get(REGEN, {}).get("pct", 0))
	var rally_pct: int = int(m.get("active_rally", {}).get("regen_pct", 0))
	if pct <= rally_pct:
		return []
	var max_hp: int = int(m.get("max_hp", 0))
	var share: int = maxi(1, max_hp * pct / 100) - max_hp * rally_pct / 100
	var healed: int = state.heal(slot, share)
	if healed <= 0:
		return []
	return [{"slot": slot, "dmg": healed, "type": "heal"}]


## End of a member's turn: count each of its timed spell buffs down, ending the
## ones that run out.
static func on_turn_end(state: Node, slot: int) -> void:
	var buffs: Dictionary = state.get_member(slot).get("spell_buffs", {})
	var ended: bool = false
	for kind: String in buffs.keys():
		if int(buffs[kind]["remaining_turns"]) == UNTIMED:
			continue
		buffs[kind]["remaining_turns"] = int(buffs[kind]["remaining_turns"]) - 1
		if int(buffs[kind]["remaining_turns"]) <= 0:
			buffs.erase(kind)
			ended = true
	if ended:
		state.ability_state_changed.emit(slot)


## The spell buff's +% to [param stat] on member [param m] (0 when none).
static func stat_pct(m: Dictionary, stat: String) -> int:
	if stat in [REGEN, RERAISE, FORGESHIELD]:
		return 0
	return int(m.get("spell_buffs", {}).get(stat, {}).get("pct", 0))


## [param dmg] of magic damage about to land on [param slot], less what its
## Forgeshield absorbs: up to the shield's pct, after which the shield is
## spent, whether the spell was under that or over it ("Absorbs the next
## instance of magical damage ... Then shatters"). Returns the damage left to
## land, all of it when no shield stands.
static func absorb_magic(state: Node, slot: int, dmg: int) -> int:
	var m: Dictionary = state.get_member(slot)
	var buffs: Dictionary = m.get("spell_buffs", {})
	if not buffs.has(FORGESHIELD) or dmg <= 0:
		return dmg
	var held: int = int(buffs[FORGESHIELD]["pct"])
	buffs.erase(FORGESHIELD)
	state.ability_state_changed.emit(slot)
	return maxi(0, dmg - held)
