class_name EncounterHandler
extends RefCounted

const EncounterSystem = preload("res://scripts/combat/encounter_system.gd")


## Returns the updated danger counter after processing one tile step.
## Returns -1 if a random encounter should trigger.
static func process_step(config: Dictionary, danger: int, party: Array[Dictionary]) -> int:
	var base: int = config.get("danger_increment", 0)
	if base <= 0:
		return danger
	var acc_mod: float = EncounterSystem.get_accessory_modifier(party)
	var loc_mod: float = EncounterSystem.get_location_modifier(config)
	var new_danger: int = (
		danger + EncounterSystem.roll_increment(base, StoryAct.get_danger_scale(), acc_mod, loc_mod)
	)
	if EncounterSystem.check_encounter(new_danger):
		return -1
	return new_danger


## Builds and returns a transition Dictionary for a random encounter.
## Returns an empty Dictionary if no groups are configured.
static func build_random_encounter(
	config: Dictionary, map_id: String, player_pos: Vector2, party: Array[Dictionary] = []
) -> Dictionary:
	var groups: Array = config.get("groups", [])
	if groups.is_empty():
		return {}
	var group: Dictionary = EncounterSystem.select_encounter_group(groups)
	var rates: Dictionary = config.get("formation_rates", {})
	rates = EncounterSystem.apply_preemptive_bonus(
		rates, EncounterSystem.get_preemptive_bonus(party)
	)
	var formation: String = EncounterSystem.roll_formation(rates)
	# Sable's Coin: consume AFTER the roll so the RNG stream length is
	# identical with or without the coin; random encounters only — the
	# boss path never reads the flag (combat-formulas.md: no bosses).
	if EventFlags.check_required_flags("sables_coin_active"):
		formation = "preemptive"
		EventFlags.set_flag("sables_coin_active", false)
	return {
		"encounter_group": group.get("enemies", []),
		"formation_type": formation,
		"return_map_id": map_id,
		"return_position": player_pos,
		"enemy_act": StoryAct.get_enemy_act(),
		"encounter_source": "random",
	}
