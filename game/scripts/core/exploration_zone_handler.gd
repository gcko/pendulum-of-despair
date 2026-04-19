class_name ExplorationZoneHandler
extends RefCounted
## Handles zone-related events, encounter processing, and environmental
## entity signals for exploration maps.
## Extracted from exploration.gd to keep the main script focused on
## map loading and player interaction.

var _exploration: Exploration


func _init(exploration: Exploration) -> void:
	_exploration = exploration


func process_encounter_step() -> void:
	var config: Dictionary = _exploration._encounter_config
	if config.is_empty():
		return
	var result: int = (
		EncounterHandler
		. process_step(
			config,
			_exploration._danger_counter,
			PartyState.get_active_party(),
		)
	)
	if result == -1:
		trigger_random_encounter()
	else:
		_exploration._danger_counter = result


func trigger_random_encounter() -> void:
	if _exploration.is_transitioning():
		return
	var transition: Dictionary = (
		EncounterHandler
		. build_random_encounter(
			_exploration._encounter_config,
			_exploration._current_map_id,
			_exploration.get_player().position,
		)
	)
	if transition.is_empty():
		return
	_exploration._danger_counter = 0
	_exploration.set_transitioning(true)
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)


func trigger_boss_encounter(area: Area2D) -> void:
	var player: Node2D = _exploration.get_player()
	if (
		_exploration.is_transitioning()
		or player == null
		or _exploration.is_in_cutscene()
		or _exploration.is_in_auto_walk()
	):
		return
	if area.get_meta("boss_id", "").is_empty():
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var req_flag: String = area.get_meta("required_flag", "")
	if not req_flag.is_empty() and not EventFlags.get_flag(req_flag):
		return
	var eids: Variant = area.get_meta("enemy_ids", [])
	var enemy_ids: Array = eids if eids is Array else []
	if enemy_ids.is_empty():
		return
	_exploration._danger_counter = 0
	_exploration.set_transitioning(true)
	var transition: Dictionary = {
		"encounter_group": enemy_ids,
		"formation_type": "normal",
		"return_map_id": _exploration._current_map_id,
		"return_position": player.position,
		"enemy_act": area.get_meta("enemy_act", "act_i"),
		"encounter_source": "boss",
		"is_boss": true,
		"boss_flag": flag,
	}
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)


func on_zone_damage_dealt(_zone_id: String, total_damage: int) -> void:
	if total_damage > 0 and _exploration.get_player() != null:
		_exploration.flash_location_name("-%d HP" % total_damage)


func on_wheel_toggled(_wheel_id: String, is_high: bool) -> void:
	var status: String = "HIGH" if is_high else "LOW"
	_exploration.flash_location_name("Wheel set to %s" % status)
	_refresh_map_entities()


func on_plate_pressed(_plate_id: String) -> void:
	_refresh_map_entities()


func on_crystal_cleared(_crystal_id: String) -> void:
	_exploration.flash_location_name("The crystal springs to life!")


func on_pitfall_triggered(target_map_id: String, target_spawn: String) -> void:
	if (
		_exploration.is_transitioning()
		or _exploration.is_in_cutscene()
		or _exploration.is_in_auto_walk()
	):
		return
	_exploration.flash_location_name("The floor gives way!")
	_exploration.transition_to_map(target_map_id, target_spawn)


func on_spring_filled() -> void:
	_exploration.flash_location_name("Filled the Spirit Vessel with pure water.")


func on_plant_restored(_plant_id: String) -> void:
	_exploration.flash_location_name("Passage Opened")
	var scene_data: Dictionary = DataManager.load_dialogue("water_of_life")
	var raw_entries: Array = scene_data.get("entries", [])
	var entries: Array[Dictionary] = []
	for e: Variant in raw_entries:
		if e is Dictionary:
			entries.append(e as Dictionary)
	if not entries.is_empty() and GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(entries)


func _refresh_map_entities() -> void:
	var current_map: Node2D = _exploration.get_current_map()
	if current_map != null:
		var entities: Node = current_map.get_node_or_null("Entities")
		if entities != null:
			for child: Node in entities.get_children():
				if child.has_method("refresh"):
					child.refresh()
