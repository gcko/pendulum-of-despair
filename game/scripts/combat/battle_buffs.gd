extends RefCounted
## A BattleState ability hook (see BattleState.ABILITY_HOOKS) for positive
## statuses: a KO ends them, as it ends a Rally and Bulwark's state (2026-10-29
## ruling). Haste is the one built so far (StatusEffects.is_positive). Every
## other hook answer is neutral.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")


## A member fainted: every positive status on it ends.
static func on_fainted(state: Node, slot: int) -> void:
	for s: Dictionary in (state.get_member(slot).get("active_statuses", []) as Array).duplicate():
		if StatusEffects.is_positive(s.get("name", "")):
			state.remove_status(slot, s["name"])


static func on_damage(_state: Node, _slot: int, amount: int) -> int:
	return amount


static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


static func on_turn_begin(_state: Node, _slot: int) -> Array:
	return []


static func on_turn_end(_state: Node, _slot: int) -> void:
	pass


static func stat_pct(_m: Dictionary, _stat: String) -> int:
	return 0
