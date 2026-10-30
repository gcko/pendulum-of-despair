class_name BattleStatusGuard
extends RefCounted
## Equipment status immunity (#512), the cure that says so (#515), and whether a
## status has taken a member out of the fight (on_field, #246).
##
## A worn item's `status_immunity` names the status its wearer cannot be
## afflicted with (equipment.md § Status Immunity Accessories, and the Warding
## Crown, Spiritguard Helm and purified Grey Cleaver rows), or ALL for every
## negative status (Dreamer's Mark). It may also be an Array of names. Each of
## the four equipment slots counts (WORN_SLOTS), so the wards of everything a
## member wears add up. The crystal slot does not: the Null Crystal's Despair
## immunity (progression.md § Special Crystals) is a crystal passive, tracked on
## #181. A positive status (StatusEffects.is_positive) is never kept off, whatever the
## gear says: Dreamer's Mark wards off ailments, not Haste (2026-10-30 ruling).
##
## BattleState.apply_status asks blocks() as the status would land, which on the
## enemy path is after the hit roll (combat-formulas.md § Status Spell
## Resolution, step 4). There is no field status system, so this is battle-only.
## BattleState.apply_status asks ward_against, which adds Torren's Stoneheart: a
## timed immunity on the member's battle record (BattleSpiritcall.wards_off),
## asked after the gear. Both are pure queries.
##
## on_field is the party mirror of Enemy.is_removed_from_combat: Petrify is
## "Removed from combat" (magic.md § Status Effect Reference). BattleAI's and
## BossAI's target picks, BattleEnemyTurn's party-wide loop, a confused or berserk
## attacker's pool (BattleAutoAction.pick_target), BattleState's highest threat,
## flee-average and party-wipe checks, and the Despair that feeds a Pallor's
## regen (BattleEnemyTurn._party_despairs) ask it instead of is_alive.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Helpers = preload("res://scripts/util/inventory_helpers.gd")

## The `status_immunity` value that wards off every negative status.
const ALL: String = "all"
## The worn slots whose item data can carry a `status_immunity`.
const WORN_SLOTS: Array[String] = ["weapon", "head", "body", "accessory"]


## Whether the gear [param character_id] wears keeps [param status] off them.
static func blocks(character_id: String, status: String) -> bool:
	if character_id.is_empty() or StatusEffects.is_positive(status):
		return false
	var wards: Array[String] = immunities(character_id)
	return ALL in wards or status in wards


## What keeps [param status] off party [param slot] of [param state] as it would
## land: "gear" (blocks), else "spirit" (a Stoneheart ward), else "".
static func ward_against(state: Node, slot: int, status: String) -> String:
	if blocks(String(state.get_member(slot).get("character_id", "")), status):
		return "gear"
	return "spirit" if BattleSpiritcall.wards_off(state, slot, status) else ""


## Every `status_immunity` entry on the gear [param character_id] wears.
static func immunities(character_id: String) -> Array[String]:
	var wards: Array[String] = []
	var worn: Dictionary = PartyState.get_member(character_id).get("equipment", {})
	for slot: String in WORN_SLOTS:
		var equipment_id: String = str(worn.get(slot, ""))
		if equipment_id.is_empty():
			continue
		var ward: Variant = Helpers.lookup_equipment(equipment_id).get("status_immunity")
		if ward is String:
			wards.append(ward)
		elif ward is Array:
			for entry: Variant in ward:
				wards.append(str(entry))
	return wards


## Whether party member record [param m] (BattleState.get_member) is still in the
## fight: living, and carrying no status that removes it from combat (Petrify,
## StatusEffects.removes_from_combat). An empty record (an empty slot) is not.
static func on_field(m: Dictionary) -> bool:
	if not m.get("is_alive", false):
		return false
	for s: Dictionary in m.get("active_statuses", []):
		if StatusEffects.removes_from_combat(s.get("name", "")):
			return false
	return true


## Lift [param status] from party slot [param slot] as a cure by a spell, item
## or ability, so the battle can say "[Status] was cured!" (BattleState
## .status_cured). Expiry, a waking hit and a KO remove a status without this.
## Returns whether the status was on.
static func cure(state: Node, slot: int, status: String) -> bool:
	if not state.has_status(slot, status):
		return false
	state.remove_status(slot, status)
	state.status_cured.emit(slot, status)
	return true
