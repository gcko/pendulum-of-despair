class_name ExplorationPartyJoins
extends RefCounted
## Picks up party members whose joining flag is set but who were never added —
## e.g. a crash or force-quit during the dialogue that recruits them.
## Extracted from exploration.gd to keep the main script focused on map loading
## and player interaction.


## Add every member whose story flag has fired, announcing each arrival through
## the exploration scene's location flash.
static func check_join_flags(exploration: Exploration) -> void:
	if EventFlags.get_flag("carradan_ambush_survived"):
		var added_lira: bool = _join_if_missing("lira")
		var added_sable: bool = _join_if_missing("sable")
		if added_lira and added_sable:
			exploration.flash_location_name("Lira and Sable joined the party!")
		elif added_lira:
			exploration.flash_location_name("Lira joined the party!")
		elif added_sable:
			exploration.flash_location_name("Sable joined the party!")
	if EventFlags.get_flag("torren_joined") and _join_if_missing("torren"):
		exploration.flash_location_name("Torren joined the party!")
	if EventFlags.get_flag("maren_warning") and _join_if_missing("maren"):
		exploration.flash_location_name("Maren joined the party!")


## Add a character at the join level unless they are already in the party.
## Returns whether they were added.
static func _join_if_missing(character_id: String) -> bool:
	if PartyState.has_member(character_id):
		return false
	PartyState.add_member(character_id, join_level())
	return true


## Level a newly-joining party member starts at: max(1, floor(party average) - 1)
## per progression.md "Party Join Rules" (joiners arrive slightly under the average).
static func join_level() -> int:
	if PartyState.members.is_empty():
		return 1
	var total: int = 0
	for m: Dictionary in PartyState.members:
		total += int(m.get("level", 1))
	return maxi(1, floori(float(total) / float(PartyState.members.size())) - 1)
