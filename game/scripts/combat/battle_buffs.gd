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
##     (Ironhide, Wardglass, Rallying Cry, Attunement, Bulwark Line, Leyward) or
##     REGEN for Kindle Breath and Rekindling's regeneration.
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
## Interaction). Two buffs of one kind do not stack: a new one replaces the old,
## refreshing the duration (progression.md, "Buff stacking"). A buff is counted
## down on its bearer's own turns, as party statuses are.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## The spell_buffs kind for regeneration.
const REGEN: String = "regen"


## Land a spell buff of [param kind] on [param slot]: [param pct] percent for
## [param turns] of the bearer's turns, plus one when the bearer's turn is open
## (a self-cast), since that turn's end would otherwise spend one, as
## BattleRally.start counts it. Returns whether it landed: a fallen member
## carries none.
static func grant(state: Node, slot: int, kind: String, pct: int, turns: int) -> bool:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty() or not m.get("is_alive", false):
		return false
	var buffs: Dictionary = m.get("spell_buffs", {})
	buffs[kind] = {
		"pct": pct,
		"remaining_turns": turns + (1 if m.get("turn_open", false) else 0),
	}
	m["spell_buffs"] = buffs
	state.ability_state_changed.emit(slot)
	return true


## A member fainted: every positive status and spell buff on it ends.
static func on_fainted(state: Node, slot: int) -> void:
	var m: Dictionary = state.get_member(slot)
	for s: Dictionary in (m.get("active_statuses", []) as Array).duplicate():
		if StatusEffects.is_positive(s.get("name", "")):
			state.remove_status(slot, s["name"])
	if not (m.get("spell_buffs", {}) as Dictionary).is_empty():
		m["spell_buffs"] = {}
		state.ability_state_changed.emit(slot)


static func on_damage(_state: Node, _slot: int, amount: int) -> int:
	return amount


static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


## Start of a member's turn: regeneration restores its percentage of max HP
## (magic.md § Status Effect Reference, Regen: "Restore 5% max HP per turn"),
## at least 1 as a Poison tick takes at least 1. Returns heal events in
## BattleState's turn-event shape [{slot, dmg, type}].
static func on_turn_begin(state: Node, slot: int) -> Array:
	var m: Dictionary = state.get_member(slot)
	var pct: int = int(m.get("spell_buffs", {}).get(REGEN, {}).get("pct", 0))
	if pct <= 0:
		return []
	var healed: int = state.heal(slot, maxi(1, int(m.get("max_hp", 0)) * pct / 100))
	if healed <= 0:
		return []
	return [{"slot": slot, "dmg": healed, "type": "heal"}]


## End of a member's turn: count each of its spell buffs down, ending the ones
## that run out.
static func on_turn_end(state: Node, slot: int) -> void:
	var buffs: Dictionary = state.get_member(slot).get("spell_buffs", {})
	var ended: bool = false
	for kind: String in buffs.keys():
		buffs[kind]["remaining_turns"] = int(buffs[kind]["remaining_turns"]) - 1
		if int(buffs[kind]["remaining_turns"]) <= 0:
			buffs.erase(kind)
			ended = true
	if ended:
		state.ability_state_changed.emit(slot)


## The spell buff's +% to [param stat] on member [param m] (0 when none).
static func stat_pct(m: Dictionary, stat: String) -> int:
	if stat == REGEN:
		return 0
	return int(m.get("spell_buffs", {}).get(stat, {}).get("pct", 0))
