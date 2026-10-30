extends RefCounted
## Lands an ally spell on the party (#503): the revive, heal, stat buff,
## regeneration, MP restore, cure or registry status its data carries, on the
## slots its target type names. Each value is the spell's own data, from its
## magic.md entry (magic.md § Derived Rules > 'Ally spell effects').
##
## Extracted from battle_magic_command.gd, which validates the cast, spends its
## cost and hands the resolution of a party-side spell here.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Buffs = preload("res://scripts/combat/battle_buffs.gd")

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Land [param spell], cast from [param caster_slot], on the slots
## [param target_type] names, with [param heal_amt] HP of healing rolled once
## for the whole cast. Returns whether any target was changed.
func resolve(
	caster_slot: int, spell: Dictionary, target_type: String, command: Dictionary, heal_amt: int
) -> bool:
	var had_effect: bool = false
	for i: int in _ally_slots(target_type, command, caster_slot):
		if _land_on_ally(spell, i, heal_amt):
			had_effect = true
	return had_effect


## The party slots an ally spell lands on: the caster for a "self" spell, every
## living member for an all-allies one, else the chosen one.
func _ally_slots(target_type: String, command: Dictionary, caster_slot: int) -> Array[int]:
	if target_type == "self":
		return [caster_slot]
	if target_type != "all_allies":
		return [int(command.get("target", 0))]
	var slots: Array[int] = []
	for i: int in range(4):
		if _battle.get_battle_state().get_member(i).get("is_alive", false):
			slots.append(i)
	return slots


## Land every effect [param spell] carries on party slot [param slot], and
## [param heal_amt] HP. Returns whether any of them changed the target.
func _land_on_ally(spell: Dictionary, slot: int, heal_amt: int) -> bool:
	var state: Node = _battle.get_battle_state()
	var m: Dictionary = state.get_member(slot)
	var landed: bool = false
	if spell.get("revive_pct") != null:
		var revive_hp: int = maxi(1, _pct_of(m, "max_hp", spell, "revive_pct"))
		landed = _show_heal(slot, state.heal(slot, revive_hp, true)) or landed
	if heal_amt > 0:
		landed = _show_heal(slot, state.heal(slot, heal_amt)) or landed
	var turns: int = int(spell.get("duration", 0)) if spell.get("duration") != null else 0
	var buff: Variant = spell.get("stat_buff")
	if buff is Dictionary:
		var pct: int = int(buff.get("pct", 0))
		landed = Buffs.grant(state, slot, str(buff.get("stat", "")), pct, turns) or landed
	if spell.get("regen_pct") != null:
		landed = Buffs.grant(state, slot, Buffs.REGEN, int(spell["regen_pct"]), turns) or landed
	if spell.get("mp_restore_pct") != null:
		var mp_before: int = int(m.get("current_mp", 0))
		state.restore_mp(slot, _pct_of(m, "max_mp", spell, "mp_restore_pct"))
		landed = int(m.get("current_mp", 0)) > mp_before or landed
	if spell.get("cure") is Dictionary:
		landed = _cure(slot, spell["cure"]) or landed
	var status: String = str(spell.get("status", ""))
	if spell.get("category", "") == "buff" and StatusEffects.is_known(status):
		landed = _status_on_ally(slot, status, spell.get("duration")) or landed
	return landed


## [param spell]'s [param pct_key] percent of [param m]'s [param pool], floored.
static func _pct_of(m: Dictionary, pool: String, spell: Dictionary, pct_key: String) -> int:
	return int(m.get(pool, 0)) * int(spell.get(pct_key, 0)) / 100


## Show [param healed] HP restored to [param slot]; returns whether any came back.
func _show_heal(slot: int, healed: int) -> bool:
	if healed > 0:
		_battle.damage_dealt.emit("party_%d" % slot, healed, "heal")
	return healed > 0


## Cure party slot [param slot] by [param rule] {only, except, count}: the
## listed statuses in order, else every negative one but the exceptions (Purge:
## not Stop or Despair), at most count of them (Cleansing Draught: one), 0 = all.
## A positive status is never cured. Returns whether anything was cured.
func _cure(slot: int, rule: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var candidates: Array[String] = []
	for listed: Variant in rule.get("only", []):
		candidates.append(str(listed))
	if candidates.is_empty():
		for s: Dictionary in state.get_member(slot).get("active_statuses", []):
			candidates.append(str(s.get("name", "")))
	var limit: int = int(rule.get("count", 0))
	var cured: int = 0
	for status: String in candidates:
		if limit > 0 and cured >= limit:
			break
		if StatusEffects.is_positive(status) or status in rule.get("except", []):
			continue
		if state.has_status(slot, status):
			state.remove_status(slot, status)
			cured += 1
	return cured > 0


## Land a buff spell's status on party slot [param slot] (Quickstep's Haste,
## #246) for the spell's duration, else the status's own, plus one on a self-cast
## (BattleBuffs.grant counts it the same way); a recast refreshes it. The battle
## announces it from BattleState.status_applied. Returns true.
func _status_on_ally(slot: int, status: String, duration: Variant) -> bool:
	var state: Node = _battle.get_battle_state()
	var turns: int = StatusEffects.resolve_duration(status, duration)
	if state.get_member(slot).get("turn_open", false):
		turns += 1
	state.apply_status(slot, status, "turns", float(turns))
	return true
