class_name PartyVitals
extends RefCounted
## Out-of-battle HP/MP/status facet of PartyState: inn rests, rest items,
## field healing and post-defeat revival.
##
## Extracted from party_state.gd (GAP-087). PartyState keeps the public API and
## forwards here.

## AC every member is restored to by a full rest (economy.md § Inns).
const FULL_REST_AC: int = 12

var _party: Node


func _init(party: Node) -> void:
	_party = party


## Restore ALL party members to full HP/MP/AC, clear status. Per economy.md.
func rest_at_inn() -> void:
	for member: Dictionary in _party.members:
		if member.is_empty():
			continue
		member["current_hp"] = member.get("max_hp", 1)
		member["current_mp"] = member.get("max_mp", 0)
		member["current_ac"] = FULL_REST_AC
		member["status_effects"] = []


## Deduct MP from a party member. Returns false if insufficient.
func spend_mp(character_id: String, amount: int) -> bool:
	var m: Dictionary = _party.get_member(character_id)
	if m.is_empty() or amount <= 0 or m.get("current_mp", 0) < amount:
		return false
	m["current_mp"] -= amount
	return true


## Heal a party member's HP. Returns actual amount restored.
func heal(character_id: String, amount: int) -> int:
	var m: Dictionary = _party.get_member(character_id)
	if m.is_empty() or amount <= 0:
		return 0
	var old: int = m.get("current_hp", 0)
	m["current_hp"] = mini(m.get("max_hp", old), old + amount)
	return m["current_hp"] - old


## Revive all KO'd active party members at a fraction of max HP.
func revive_active_at_fraction(fraction: float) -> void:
	var active_list: Array = []
	if _party.formation.has("active"):
		active_list = _party.formation["active"]
	for idx: Variant in active_list:
		if not (idx is int or idx is float):
			continue
		var mi: int = int(idx)
		if mi < 0 or mi >= _party.members.size():
			continue
		var m: Dictionary = _party.members[mi]
		if m.get("current_hp", 0) <= 0:
			m["current_hp"] = maxi(1, floori(float(m.get("max_hp", 1)) * fraction))


## Apply rest item effects: restore HP/MP by percentage, optionally
## clear status. Applies to ALL party members (active + reserve).
func rest_party(restore_pct: float, clears_status: bool) -> void:
	for m: Dictionary in _party.members:
		if m.is_empty():
			continue
		var max_hp: int = int(m.get("max_hp", m.get("base_stats", {}).get("hp", 1)))
		var max_mp: int = int(m.get("max_mp", m.get("base_stats", {}).get("mp", 0)))
		m["current_hp"] = mini(
			int(m.get("current_hp", max_hp)) + int(max_hp * restore_pct),
			max_hp,
		)
		m["current_mp"] = mini(
			int(m.get("current_mp", max_mp)) + int(max_mp * restore_pct),
			max_mp,
		)
		if clears_status:
			m["status_effects"] = []
