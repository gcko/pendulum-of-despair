class_name ExplorationEntityManager
extends RefCounted
## Manages entity initialization and signal wiring for exploration maps.
## Extracted from exploration.gd to keep the main script focused on gameplay.

var _exploration: Exploration


func _init(exploration: Exploration) -> void:
	_exploration = exploration


func initialize_entities(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities == null:
		return
	for child: Node in entities.get_children():
		if not child.has_method("initialize"):
			continue
		if child.has_signal("npc_interacted"):
			if child.get_meta("cutscene_actor", false):
				if child.has_method("initialize_as_actor"):
					child.initialize_as_actor()
				continue
			var npc_id: String = child.get_meta("npc_id", "")
			if npc_id.is_empty():
				push_error("Exploration: NPC '%s' missing npc_id metadata" % child.name)
				continue
			child.initialize(npc_id)
		elif child.has_signal("chest_opened"):
			_initialize_chest(child)
		elif child.has_signal("save_point_activated"):
			_initialize_save_point(child)
		elif child.has_signal("wheel_toggled"):
			_initialize_water_wheel(child)
		elif child.has_signal("zone_refreshed"):
			_initialize_zone_refresh(child)
		elif child.has_signal("plant_restored"):
			_initialize_spirit_plant(child)
		elif child.has_signal("zone_damage_dealt"):
			_initialize_damage_zone(child)
		elif child.has_signal("plate_pressed"):
			_initialize_pressure_plate(child)
		elif child.has_signal("crystal_cleared"):
			_initialize_ember_crystal(child)
		elif child.has_signal("pitfall_triggered"):
			_initialize_pitfall(child)
		elif child.has_signal("triggered"):
			_initialize_trigger(child)
	# Apply flag-driven visibility
	if entities != null:
		for child: Node in entities.get_children():
			var vis_flag: String = child.get_meta("visible_when_flag", "")
			if not vis_flag.is_empty():
				child.visible = EventFlags.get_flag(vis_flag)
	# Refresh water zones after all entities are initialized
	if entities != null:
		for child: Node in entities.get_children():
			if child.has_method("refresh"):
				child.refresh()
	# Populate entity lookup for cutscene choreography
	_exploration.clear_entities()
	var entities_node: Node2D = map_node.get_node_or_null("Entities")
	if entities_node != null:
		for child: Node in entities_node.get_children():
			var nid: String = child.get_meta("npc_id", "")
			if nid != "":
				_exploration.set_entity(nid, child)
			else:
				var cid: Variant = child.get("character_id")
				if cid is String and not cid.is_empty():
					_exploration.set_entity(cid, child)
	# Register player only if no cutscene actor already owns the ID
	var player: Node2D = _exploration.get_player()
	if player != null:
		var pid: Variant = player.get("character_id")
		if pid is String and not pid.is_empty():
			if not _exploration.has_entity(pid):
				_exploration.set_entity(pid, player)


func _initialize_chest(child: Node) -> void:
	var chest_id: String = child.get_meta("chest_id", "")
	var item_id: String = child.get_meta("item_id", "")
	if chest_id.is_empty() or item_id.is_empty():
		push_error("Exploration: Chest '%s' missing chest_id/item_id" % child.name)
		return
	if child.get_meta("is_key_item", false):
		_exploration.register_key_item_chest(chest_id)
	if child.get_meta("is_equipment", false):
		_exploration.register_equipment_chest(chest_id)
	var qty: int = child.get_meta("quantity", 1)
	child.initialize(chest_id, item_id, qty)


func _initialize_save_point(child: Node) -> void:
	var sp_id: String = child.get_meta("save_point_id", "")
	if sp_id.is_empty():
		push_error("Exploration: SavePoint '%s' missing metadata" % child.name)
		return
	child.initialize(sp_id)


func _initialize_water_wheel(child: Node) -> void:
	var wid: String = child.get_meta("wheel_id", "")
	var did: String = child.get_meta("dungeon_id", "")
	if wid.is_empty():
		push_error("Exploration: WaterWheel '%s' missing wheel_id" % child.name)
		return
	if did.is_empty():
		push_error("Exploration: WaterWheel '%s' missing dungeon_id" % child.name)
		return
	child.initialize(wid, did)


func _initialize_zone_refresh(child: Node) -> void:
	var did: String = child.get_meta("dungeon_id", "")
	var conds: String = child.get_meta("active_when", "")
	var zt: String = child.get_meta("zone_type", "block")
	child.initialize(did, conds, zt)


func _initialize_spirit_plant(child: Node) -> void:
	var pid: String = child.get_meta("plant_id", "")
	var did: String = child.get_meta("dungeon_id", "")
	if pid.is_empty():
		push_error("Exploration: SpiritPlant '%s' missing plant_id" % child.name)
		return
	if did.is_empty():
		push_error("Exploration: SpiritPlant '%s' missing dungeon_id" % child.name)
		return
	child.initialize(pid, did)


func _initialize_damage_zone(child: Node) -> void:
	var zid: String = child.get_meta("zone_id", "")
	var dpt: int = child.get_meta("damage_per_tick", 8)
	var ti: float = child.get_meta("tick_interval", 1.0)
	var se: String = child.get_meta("status_effect", "poison")
	child.initialize(zid, dpt, ti, se)


func _initialize_pressure_plate(child: Node) -> void:
	var pid: String = child.get_meta("plate_id", "")
	var did: String = child.get_meta("dungeon_id", "")
	if pid.is_empty():
		push_error("Exploration: PressurePlate '%s' missing plate_id" % child.name)
		return
	if did.is_empty():
		push_error("Exploration: PressurePlate '%s' missing dungeon_id" % child.name)
		return
	child.initialize(pid, did)


func _initialize_ember_crystal(child: Node) -> void:
	var cid: String = child.get_meta("crystal_id", "")
	var did: String = child.get_meta("dungeon_id", "")
	if cid.is_empty():
		push_error("Exploration: EmberCrystal '%s' missing crystal_id" % child.name)
		return
	if did.is_empty():
		push_error("Exploration: EmberCrystal '%s' missing dungeon_id" % child.name)
		return
	child.initialize(cid, did)


func _initialize_pitfall(child: Node) -> void:
	var tmid: String = child.get_meta("target_map_id", "")
	var tsp: String = child.get_meta("target_spawn", "")
	if tmid.is_empty():
		push_error("Exploration: PitfallZone '%s' missing target_map_id" % child.name)
		return
	child.initialize(tmid, tsp)


func _initialize_trigger(child: Node) -> void:
	var tid: String = child.get_meta("trigger_id", "")
	var cond: String = child.get_meta("condition_flag", "")
	if tid.is_empty():
		push_error("Exploration: TriggerZone '%s' missing trigger_id" % child.name)
		return
	child.initialize(tid, cond)


func connect_entity_signals(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities != null:
		for child: Node in entities.get_children():
			if child.has_signal("npc_interacted"):
				if child.get_meta("cutscene_actor", false):
					continue
				child.npc_interacted.connect(_exploration.on_npc_interacted)
			if child.has_signal("chest_opened"):
				child.chest_opened.connect(_exploration.on_chest_opened)
			if child.has_signal("save_point_activated"):
				child.save_point_activated.connect(_exploration.on_save_point_activated)
			if child.has_signal("save_point_entered"):
				child.save_point_entered.connect(_exploration.on_save_point_entered)
			if child.has_signal("save_point_exited"):
				child.save_point_exited.connect(_exploration.on_save_point_exited)
			if child.has_signal("wheel_toggled"):
				child.wheel_toggled.connect(_exploration.on_wheel_toggled)
			if child.has_signal("spring_filled"):
				child.spring_filled.connect(_exploration.on_spring_filled)
			if child.has_signal("plant_restored"):
				child.plant_restored.connect(_exploration.on_plant_restored)
			if child.has_signal("zone_damage_dealt"):
				child.zone_damage_dealt.connect(_exploration.on_zone_damage_dealt)
			if child.has_signal("plate_pressed"):
				child.plate_pressed.connect(_exploration.on_plate_pressed)
			if child.has_signal("crystal_cleared"):
				child.crystal_cleared.connect(_exploration.on_crystal_cleared)
			if child.has_signal("pitfall_triggered"):
				child.pitfall_triggered.connect(_exploration.on_pitfall_triggered)
			if child.has_signal("triggered"):
				child.triggered.connect(_exploration.on_trigger_fired)
			if child.has_signal("interaction_message"):
				child.interaction_message.connect(_exploration.on_interaction_message)
			if child is Area2D and child.has_meta("boss_id"):
				child.body_entered.connect(_exploration.on_boss_trigger_entered.bind(child))
			elif child is Area2D and child.has_meta("cutscene_scene_id"):
				child.body_entered.connect(_exploration.on_cutscene_trigger_entered.bind(child))
			elif (
				child is Area2D
				and (child.has_meta("dialogue_data") or child.has_meta("dialogue_scene_id"))
			):
				child.body_entered.connect(_exploration.on_dialogue_trigger_entered.bind(child))
	var transitions: Node = map_node.get_node_or_null("Transitions")
	if transitions != null:
		for child: Node in transitions.get_children():
			if child is Area2D and child.has_meta("target_map"):
				child.body_entered.connect(_exploration.on_transition_body_entered.bind(child))


func disconnect_entity_signals(map_node: Node2D) -> void:
	var sigs: Dictionary = {
		"npc_interacted": _exploration.on_npc_interacted,
		"chest_opened": _exploration.on_chest_opened,
		"save_point_activated": _exploration.on_save_point_activated,
		"save_point_entered": _exploration.on_save_point_entered,
		"save_point_exited": _exploration.on_save_point_exited,
		"wheel_toggled": _exploration.on_wheel_toggled,
		"spring_filled": _exploration.on_spring_filled,
		"plant_restored": _exploration.on_plant_restored,
		"zone_damage_dealt": _exploration.on_zone_damage_dealt,
		"interaction_message": _exploration.on_interaction_message,
		"plate_pressed": _exploration.on_plate_pressed,
		"crystal_cleared": _exploration.on_crystal_cleared,
		"pitfall_triggered": _exploration.on_pitfall_triggered,
		"triggered": _exploration.on_trigger_fired,
	}
	for group: String in ["Entities", "Transitions"]:
		var container: Node = map_node.get_node_or_null(group)
		if container == null:
			continue
		for child: Node in container.get_children():
			for sig: String in sigs:
				if child.has_signal(sig) and child.is_connected(sig, sigs[sig]):
					child.disconnect(sig, sigs[sig])
			if child is Area2D:
				for conn: Dictionary in child.body_entered.get_connections():
					if conn["callable"].get_object() == _exploration:
						child.body_entered.disconnect(conn["callable"])
