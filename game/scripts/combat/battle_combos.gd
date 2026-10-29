extends RefCounted
## Dual-tech combo availability (abilities.md § 2 Combo Abilities; #176).
##
## A combo needs both of its characters seated in the battle, alive, with full
## ATB gauges and no status that stops them acting. Its `story_gate` in
## combos.json then decides whether the story has opened it:
##   requires_flags      — EventFlags that must be set
##   forbids_flags       — EventFlags that must not be (Cael's betrayal closes
##                         Shield Oath and Promise of Dawn)
##   requires_abilities  — {character, ability} pairs the character must know,
##                         read from ability data (the "after X learns Y" text)
## MP does not hide a combo: each result says whether both characters can pay
## their `mp_costs` share, so the menu can gray it as it grays a spell.
##
## Pure query: nothing here spends MP, resets a gauge or performs a combo.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")

const PARTY_SLOTS: int = 4


## Every combo the party can call now, each as {id, combo, slots, affordable}:
## [code]slots[/code] are the battle slots of its characters in the order
## combos.json names them, and [code]combo[/code] is the combos.json entry.
static func available_combos(state: Node, atb: Node) -> Array[Dictionary]:
	var ready: Dictionary = _ready_slots(state, atb)
	var out: Array[Dictionary] = []
	for raw: Variant in DataManager.load_combos():
		var combo: Dictionary = raw
		var slots: Array = []
		for cid: Variant in combo.get("characters", []):
			if ready.has(cid):
				slots.append(ready[cid])
		if slots.size() != 2 or not _story_allows(combo, state, slots):
			continue
		var entry: Dictionary = {
			"id": combo.get("id", ""),
			"combo": combo,
			"slots": slots,
			"affordable": _affordable(combo, state, slots),
		}
		out.append(entry)
	return out


## character_id -> slot for every seated member who could act this instant.
static func _ready_slots(state: Node, atb: Node) -> Dictionary:
	var ready: Dictionary = {}
	for slot: int in range(PARTY_SLOTS):
		var m: Dictionary = state.get_member(slot)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		if atb.get_gauge("party_%d" % slot) < ATBSystem.GAUGE_MAX:
			continue
		if StatusEffects.blocking_status(m.get("active_statuses", [])) != "":
			continue
		ready[m.get("character_id", "")] = slot
	return ready


static func _story_allows(combo: Dictionary, state: Node, slots: Array) -> bool:
	var gate: Dictionary = combo.get("story_gate", {})
	for flag: Variant in gate.get("requires_flags", []):
		if not EventFlags.get_flag(flag):
			return false
	for flag: Variant in gate.get("forbids_flags", []):
		if EventFlags.get_flag(flag):
			return false
	var characters: Array = combo.get("characters", [])
	for need: Variant in gate.get("requires_abilities", []):
		var cid: String = (need as Dictionary).get("character", "")
		var at: int = characters.find(cid)
		if at < 0 or not _knows(state.get_member(slots[at]), need.get("ability", "")):
			return false
	return true


static func _knows(member: Dictionary, ability_id: String) -> bool:
	var data: Dictionary = member.get("character_data", {})
	var level: int = int(data.get("level", 1))
	for a: Dictionary in AbilityHelpers.get_known_abilities(member["character_id"], level):
		if a.get("id", "") == ability_id:
			return true
	return false


static func _affordable(combo: Dictionary, state: Node, slots: Array) -> bool:
	var characters: Array = combo.get("characters", [])
	var costs: Dictionary = combo.get("mp_costs", {})
	for i: int in range(characters.size()):
		var m: Dictionary = state.get_member(slots[i])
		if int(m.get("current_mp", 0)) < int(costs.get(characters[i], 0)):
			return false
	return true
