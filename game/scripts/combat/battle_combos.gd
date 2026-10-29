extends RefCounted
## Dual-tech combo availability (abilities.md § Combo Availability; #176).
##
## A combo needs both of its characters seated in the battle, alive, on full
## ATB gauges and able to be commanded: no status that stops them acting, no
## Confusion or Berserk, and no Silence where it stops their share. Its
## `story_gate` in combos.json then decides whether the story has opened it:
##   requires_flags      — EventFlags that must be set
##   forbids_flags       — EventFlags that must not be (Cael's betrayal closes
##                         Shield Oath and Promise of Dawn)
##   requires_abilities  — {character, ability} pairs the character must know,
##                         read from ability data: the "after X learns Y" text
##                         and the sub-ability each partner supplies
## MP does not hide a combo: each result says whether both characters can pay
## their `mp_costs` share, so the menu can gray it as it grays a spell.
##
## Pure query: nothing here spends MP, resets a gauge or performs a combo.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const MagicCommand = preload("res://scripts/combat/battle_magic_command.gd")
const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")

const PARTY_SLOTS: int = 4

## Statuses under which a member cannot be commanded at all, so cannot be drawn
## into a combo either way round.
const UNCOMMANDABLE_STATUSES: Array[String] = ["confusion", "berserk"]


## Every combo the party can call now, each as {id, combo, slots, affordable}:
## [code]slots[/code] are the battle slots of its characters in the order
## combos.json names them, and [code]combo[/code] is the combos.json entry.
static func available_combos(state: Node, atb: Node) -> Array[Dictionary]:
	var ready: Dictionary = _ready_slots(state, atb)
	var out: Array[Dictionary] = []
	for raw: Variant in DataManager.load_combos():
		var combo: Dictionary = raw
		var slots: Array[int] = []
		for cid: String in combo.get("characters", []):
			if ready.has(cid):
				slots.append(int(ready[cid]))
		if slots.size() != 2 or not _story_allows(combo, state, slots):
			continue
		if _silenced_out(combo, state, slots):
			continue
		var entry: Dictionary = {
			"id": combo.get("id", ""),
			"combo": combo,
			"slots": slots,
			"affordable": _affordable(combo, state, slots),
		}
		out.append(entry)
	return out


## Whether Silence stops [param character_id]'s share of a combo, [param share]
## being the abilities it draws on from that character. It does when the share
## is something Silence already stops: Cael's Rally (Silence ends a Rally,
## abilities.md § Cael — Rally), or a spell in the spell data (Silence: "Cannot
## cast spells", magic.md § Status Effect Reference). A Bulwark stance, a Trick,
## a Spiritcall, a Forgewright device or an Arcanum weave is not stopped.
static func silence_stops_share(character_id: String, share: Array) -> bool:
	var abilities: Array = DataManager.load_abilities(character_id)
	if not abilities.is_empty() and (abilities[0] as Dictionary).get("command", "") == "rally":
		return true
	for ability_id: String in share:
		if _is_spell(ability_id):
			return true
	return false


## character_id -> slot for every seated member who could be commanded now.
static func _ready_slots(state: Node, atb: Node) -> Dictionary:
	var ready: Dictionary = {}
	for slot: int in range(PARTY_SLOTS):
		var m: Dictionary = state.get_member(slot)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		if atb.get_gauge("party_%d" % slot) < ATBSystem.GAUGE_MAX:
			continue
		var statuses: Array = m.get("active_statuses", [])
		if StatusEffects.blocking_status(statuses) != "":
			continue
		if _has_any(statuses, UNCOMMANDABLE_STATUSES):
			continue
		ready[m.get("character_id", "")] = slot
	return ready


static func _story_allows(combo: Dictionary, state: Node, slots: Array[int]) -> bool:
	var gate: Dictionary = combo.get("story_gate", {})
	for flag: String in gate.get("requires_flags", []):
		if not EventFlags.get_flag(flag):
			return false
	for flag: String in gate.get("forbids_flags", []):
		if EventFlags.get_flag(flag):
			return false
	var characters: Array = combo.get("characters", [])
	for raw: Variant in gate.get("requires_abilities", []):
		var need: Dictionary = raw
		var at: int = characters.find(need.get("character", ""))
		if at < 0 or not _knows(state.get_member(slots[at]), need.get("ability", "")):
			return false
	return true


## Whether a Silenced partner keeps this combo from being called.
static func _silenced_out(combo: Dictionary, state: Node, slots: Array[int]) -> bool:
	var characters: Array = combo.get("characters", [])
	for i: int in range(characters.size()):
		var cid: String = characters[i]
		var statuses: Array = state.get_member(slots[i]).get("active_statuses", [])
		if _has_any(statuses, MagicCommand.CAST_BLOCKING_STATUSES):
			if silence_stops_share(cid, _share(combo, cid)):
				return true
	return false


## The abilities [param cid] supplies to [param combo], from its gate.
static func _share(combo: Dictionary, cid: String) -> Array[String]:
	var out: Array[String] = []
	for raw: Variant in combo.get("story_gate", {}).get("requires_abilities", []):
		var need: Dictionary = raw
		if need.get("character", "") == cid:
			out.append(String(need.get("ability", "")))
	return out


static func _knows(member: Dictionary, ability_id: String) -> bool:
	var data: Dictionary = member.get("character_data", {})
	var level: int = int(data.get("level", 1))
	for a: Dictionary in AbilityHelpers.get_known_abilities(member["character_id"], level):
		if a.get("id", "") == ability_id:
			return true
	return false


static func _affordable(combo: Dictionary, state: Node, slots: Array[int]) -> bool:
	var characters: Array = combo.get("characters", [])
	var costs: Dictionary = combo.get("mp_costs", {})
	for i: int in range(characters.size()):
		var m: Dictionary = state.get_member(slots[i])
		if int(m.get("current_mp", 0)) < int(costs.get(characters[i], 0)):
			return false
	return true


static func _has_any(statuses: Array, names: Array[String]) -> bool:
	for s: Variant in statuses:
		if (s as Dictionary).get("name", "") in names:
			return true
	return false


static func _is_spell(ability_id: String) -> bool:
	for tradition: String in SpellHelpers.TRADITIONS:
		for spell: Variant in DataManager.load_spells(tradition):
			if spell is Dictionary and (spell as Dictionary).get("id", "") == ability_id:
				return true
	return false
