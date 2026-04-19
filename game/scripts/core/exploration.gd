class_name Exploration
extends Node2D

signal map_changed(map_id: String)

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const MAP_BASE_PATH: String = "res://scenes/maps/"
const FADE_DURATION: float = 0.3
const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")

var _current_map_id: String = ""
var _current_map: Node2D = null
var _player: Node2D = null
var _transitioning: bool = false
var _last_flash_id: String = ""
var _flash_tween: Tween = null
var _transition_tween: Tween = null
var _danger_counter: int = 0
var _last_player_tile: Vector2i = Vector2i(-999, -999)
var _encounter_config: Dictionary = {}
var _current_floor_id: String = ""
var _cleansing: CleansingSequence = null
var _key_item_chest_ids: Dictionary = {}
var _equipment_chest_ids: Dictionary = {}
var _in_auto_walk: bool = false
var _auto_walk_tween: Tween = null
var _arrival_tween: Tween = null
var _in_cutscene: bool = false
var _cutscene_handler: CutsceneHandler = null
var _entity_manager: ExplorationEntityManager = null
var _zone_handler: ExplorationZoneHandler = null
## Maps character_id/npc_id to entity Node for cutscene choreography.
var _entities: Dictionary = {}
## Pending cutscene data (set by trigger, consumed after map load).
var _pending_cutscene: Dictionary = {}
## Return destination after a cutscene map finishes.
var _cutscene_return: Dictionary = {}

@onready var _camera: Camera2D = $Camera2D
@onready var _map_container: Node2D = $CurrentMap
@onready var _fade_rect: ColorRect = $FadeOverlay/FadeRect
@onready var _location_panel: PanelContainer = $LocationFlash/LocationLabel
@onready var _location_label: Label = $LocationFlash/LocationLabel/NameLabel


func _ready() -> void:
	_fade_rect.visible = false
	_location_panel.visible = false
	_spawn_player()
	GameManager.overlay_state_changed.connect(_on_overlay_state_changed)
	_initialize_from_transition_data()


func _process(_delta: float) -> void:
	if _in_cutscene:
		return
	if _player != null and _camera != null:
		_camera.position = _player.position.round()


func _physics_process(_delta: float) -> void:
	if _player == null or _transitioning or _in_auto_walk or _in_cutscene:
		return
	var current_tile: Vector2i = Vector2i(_player.position) / 16
	if current_tile == _last_player_tile:
		return
	_last_player_tile = current_tile
	_process_encounter_step()


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning or _in_auto_walk or _in_cutscene:
		return
	if event.is_action_pressed("ui_menu"):
		if _player != null and not _player.is_input_enabled():
			return
		if GameManager.push_overlay(GameManager.OverlayState.MENU):
			var vp: Viewport = get_viewport()
			if vp != null:
				vp.set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and _player != null:
		if not _player.is_input_enabled():
			return
		var vp: Viewport = get_viewport()
		if vp != null:
			vp.set_input_as_handled()
		_player.try_interact()


func _process_encounter_step() -> void:
	_get_zone_handler().process_encounter_step()


func _trigger_boss_encounter(area: Area2D) -> void:
	_get_zone_handler().trigger_boss_encounter(area)


func load_map(map_id: String, spawn_name: String = "") -> void:
	var map_path: String = MAP_BASE_PATH + map_id + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Map not found: %s" % map_path)
		return
	var map_resource: Resource = load(map_path)
	if not map_resource is PackedScene:
		push_error("Exploration: Invalid map resource: %s" % map_path)
		return
	PartyState.is_at_save_point = false
	if _current_map != null:
		_disconnect_entity_signals(_current_map)
		_current_map.queue_free()
		_current_map = null
	_current_map = (map_resource as PackedScene).instantiate()
	_map_container.add_child(_current_map)
	_current_map_id = map_id
	_key_item_chest_ids = {}
	_equipment_chest_ids = {}
	_initialize_entities(_current_map)
	_connect_entity_signals(_current_map)
	_position_player_at_spawn(spawn_name)
	_current_floor_id = _current_map.get_meta("floor_id", "")
	if _player != null:
		_last_player_tile = Vector2i(_player.position) / 16
	_encounter_config = {}
	_danger_counter = 0
	var dungeon_id: String = _current_map.get_meta("dungeon_id", _current_map_id)
	var encounters: Dictionary = DataManager.load_encounters(dungeon_id)
	if not encounters.is_empty():
		var use_zones: bool = encounters.has("zones") and not encounters.has("floors")
		var entries: Array = encounters.get("floors", encounters.get("zones", []))
		var id_key: String = "zone_id" if use_zones else "floor_id"
		var match_id: String = _current_floor_id
		for entry: Variant in entries:
			if entry is Dictionary and (entry as Dictionary).get(id_key, "") == match_id:
				_encounter_config = entry as Dictionary
				break
		if _encounter_config.is_empty() and not match_id.is_empty() and not entries.is_empty():
			if entries[0] is Dictionary:
				_encounter_config = entries[0]
	var location_name: String = _current_map.get_meta("location_name", "")
	if location_name != "" and location_name != _last_flash_id:
		flash_location_name(location_name)
		_last_flash_id = location_name
	map_changed.emit(map_id)
	if _current_map.get_meta("is_auto_walk", false) and _player != null and not _in_cutscene:
		_start_auto_walk()
	var seq_id: String = _current_map.get_meta("auto_sequence", "")
	var seq_flag: String = _current_map.get_meta("auto_sequence_flag", "")
	if not seq_id.is_empty() and not EventFlags.get_flag(seq_flag):
		call_deferred("_run_auto_sequence", seq_id, seq_flag)
	if not _pending_cutscene.is_empty():
		var pc: Dictionary = _pending_cutscene
		_pending_cutscene = {}
		var typed_entries: Array[Dictionary] = []
		for e: Variant in pc.get("entries", []):
			if e is Dictionary:
				typed_entries.append(e as Dictionary)
		call_deferred(
			"_start_pending_cutscene",
			pc.get("id", ""),
			typed_entries,
			pc.get("tier", 1),
		)


func flash_location_name(text: String) -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_location_label.text = text
	_location_panel.visible = true
	_location_panel.modulate = Color(1, 1, 1, 0)
	_flash_tween = create_tween()
	_flash_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_flash_tween.tween_property(_location_panel, "modulate:a", 1.0, 0.5)
	_flash_tween.tween_interval(2.0)
	_flash_tween.tween_property(_location_panel, "modulate:a", 0.0, 0.5)
	_flash_tween.tween_callback(_location_panel.hide)


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	add_child(_player)
	_player.initialize("edren")
	_player.interaction_requested.connect(_on_interaction_requested)


func _initialize_from_transition_data() -> void:
	var data: Dictionary = GameManager.transition_data
	if data.get("new_game", false):
		load_map("dungeons/ember_vein_f1", "from_overworld")
	elif data.has("save_data"):
		var save_data: Dictionary = data.get("save_data", {})
		PartyState.load_from_save(save_data)
		var world: Dictionary = save_data.get("world", {})
		var location: String = world.get("current_location", "overworld")
		load_map(location if location != "" else "overworld")
		var pos: Dictionary = world.get("current_position", {})
		if _player != null and pos.has("x") and pos.has("y"):
			_player.position = Vector2(pos["x"], pos["y"])
	elif data.has("result"):
		var r: String = data.get("result", "")
		if r == "fenmother_cleansing":
			_get_cleansing().start(data)
			return
		if r == "victory":
			var wave_num: int = data.get("wave_num", -1)
			if wave_num >= 0:
				_get_cleansing().continue_sequence(data)
				return
			var rewards: Dictionary = {
				"xp": data.get("earned_xp", 0),
				"gold": data.get("earned_gold", 0),
				"drops": data.get("earned_drops", [])
			}
			PartyState.distribute_battle_rewards(rewards)
			distribute_crystal_xp(rewards.get("xp", 0))
			var boss_flag: String = data.get("boss_flag", "")
			if not boss_flag.is_empty():
				EventFlags.set_flag(boss_flag, true)
		elif r == "faint":
			SaveManager.faint_and_fast_reload()
			return
		_danger_counter = 0
		load_map(data.get("map_id", "overworld"))
		if _player != null:
			var pos: Variant = data.get("position", Vector2(80, 90))
			_player.position = pos.round() if pos is Vector2 else Vector2(80, 90)
	else:
		load_map("overworld")
	# Safety net: if a party-joining flag was set but the member was never
	# added (e.g., crash or force-quit during dialogue), pick them up now.
	_check_party_joining_flags()


func _initialize_entities(map_node: Node2D) -> void:
	_get_entity_manager().initialize_entities(map_node)


func _connect_entity_signals(map_node: Node2D) -> void:
	_get_entity_manager().connect_entity_signals(map_node)


func _disconnect_entity_signals(map_node: Node2D) -> void:
	_get_entity_manager().disconnect_entity_signals(map_node)


func _position_player_at_spawn(spawn_name: String) -> void:
	if _player == null or _current_map == null:
		return
	var marker_name: String = spawn_name if spawn_name != "" else "PlayerSpawn"
	var spawn: Node2D = _current_map.get_node_or_null(marker_name)
	_player.position = spawn.position.round() if spawn != null else Vector2(80, 90)


func _on_interaction_requested(interactable: Node2D) -> void:
	if _transitioning or _in_cutscene:
		return
	var target: Node2D = interactable
	if not target.has_method("interact"):
		var owner_node: Node = target.owner
		if owner_node is Node2D and owner_node.has_method("interact"):
			target = owner_node as Node2D
	if target.has_method("interact"):
		target.interact()


func _find_entity_npc(npc_id: String) -> Node:
	var entity: Variant = _entities.get(npc_id, null)
	if entity is Node and is_instance_valid(entity) and entity.has_signal("npc_interacted"):
		return entity
	return null


func _handle_inn(node: Node) -> void:
	if not PartyState.spend_gold(node.get_meta("inn_cost", 150)):
		flash_location_name("Not enough gold.")
		return
	PartyState.rest_at_inn()
	flash_location_name("Rested at the inn.")


func _on_npc_interacted(npc_id: String, dialogue_data: Dictionary) -> void:
	var npc_node: Node = _find_entity_npc(npc_id)
	if npc_node != null:
		if npc_node.has_meta("shop_id"):
			GameManager.transition_data = {"shop_id": npc_node.get_meta("shop_id")}
			if GameManager.push_overlay(GameManager.OverlayState.SHOP):
				return
		if npc_node.has_meta("inn_id"):
			_handle_inn(npc_node)
			return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue([dialogue_data])


func _on_chest_opened(chest_id: String, item_id: String, quantity: int) -> void:
	if _key_item_chest_ids.get(chest_id, false):
		PartyState.add_key_item(item_id)
	elif _equipment_chest_ids.get(chest_id, false):
		PartyState.add_equipment(item_id)
	else:
		PartyState.add_item(item_id, quantity)
	flash_location_name("Found %s!" % item_id)


func _on_save_point_activated(_save_point_id: String) -> void:
	if _transitioning or _in_cutscene:
		return
	PartyState.is_at_save_point = true
	if GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		GameManager.overlay_node.open_save_point()


func _on_save_point_entered(_save_point_id: String) -> void:
	if _transitioning or _in_cutscene or _in_auto_walk:
		return
	AudioManager.play_sfx("save_point_proximity")


func _on_save_point_exited(_save_point_id: String) -> void:
	PartyState.is_at_save_point = false


func _on_trigger_fired(_trigger_id: String) -> void:
	# Stub — trigger behavior dispatched per-map in future gaps.
	pass


func _on_wheel_toggled(wheel_id: String, is_high: bool) -> void:
	_get_zone_handler().on_wheel_toggled(wheel_id, is_high)


func _on_plate_pressed(plate_id: String) -> void:
	_get_zone_handler().on_plate_pressed(plate_id)


func _on_crystal_cleared(crystal_id: String) -> void:
	_get_zone_handler().on_crystal_cleared(crystal_id)


func _on_pitfall_triggered(target_map_id: String, target_spawn: String) -> void:
	_get_zone_handler().on_pitfall_triggered(target_map_id, target_spawn)


func _on_spring_filled() -> void:
	_get_zone_handler().on_spring_filled()


func _on_plant_restored(plant_id: String) -> void:
	_get_zone_handler().on_plant_restored(plant_id)


func _on_zone_damage_dealt(zone_id: String, total_damage: int) -> void:
	_get_zone_handler().on_zone_damage_dealt(zone_id, total_damage)


func _on_interaction_message(text: String) -> void:
	flash_location_name(text)


func _on_boss_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning or _in_cutscene or _in_auto_walk:
		return
	_get_zone_handler().trigger_boss_encounter(area)


func _on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning or _in_cutscene or _in_auto_walk:
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var required: String = area.get_meta("required_flag", "")
	if not required.is_empty() and not EventFlags.get_flag(required):
		return
	var required_multi: String = area.get_meta("required_flags", "")
	if not required_multi.is_empty():
		for rf: String in required_multi.split(","):
			if not EventFlags.get_flag(rf.strip_edges()):
				return
	var dialogue: Variant = area.get_meta("dialogue_data", [])
	var scene_id: String = area.get_meta("dialogue_scene_id", "")
	if scene_id != "":
		var scene_data: Dictionary = DataManager.load_dialogue(scene_id)
		dialogue = scene_data.get("entries", [])
	if not (dialogue is Array) or (dialogue as Array).is_empty():
		return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(dialogue as Array)
		if not flag.is_empty():
			EventFlags.set_flag(flag, true)
			GameManager.overlay_state_changed.connect(
				_on_dialogue_closed_check_party, CONNECT_ONE_SHOT
			)


func _on_dialogue_closed_check_party(state: GameManager.OverlayState) -> void:
	if state != GameManager.OverlayState.NONE:
		GameManager.overlay_state_changed.connect(_on_dialogue_closed_check_party, CONNECT_ONE_SHOT)
		return
	_check_party_joining_flags()
	if (
		EventFlags.get_flag("ember_vein_1e_seen")
		and not EventFlags.get_flag("arcanite_gear_broken")
	):
		PartyState.break_arcanite_gear()
		EventFlags.set_flag("arcanite_gear_broken", true)


func _check_party_joining_flags() -> void:
	if EventFlags.get_flag("carradan_ambush_survived"):
		var added_lira: bool = false
		var added_sable: bool = false
		if not PartyState.has_member("lira"):
			PartyState.add_member("lira", _get_party_avg_level())
			added_lira = true
		if not PartyState.has_member("sable"):
			PartyState.add_member("sable", _get_party_avg_level())
			added_sable = true
		if added_lira and added_sable:
			flash_location_name("Lira and Sable joined the party!")
		elif added_lira:
			flash_location_name("Lira joined the party!")
		elif added_sable:
			flash_location_name("Sable joined the party!")
	if EventFlags.get_flag("torren_joined") and not PartyState.has_member("torren"):
		PartyState.add_member("torren", _get_party_avg_level())
		flash_location_name("Torren joined the party!")
	if EventFlags.get_flag("maren_warning") and not PartyState.has_member("maren"):
		PartyState.add_member("maren", _get_party_avg_level())
		flash_location_name("Maren joined the party!")


func _get_party_avg_level() -> int:
	if PartyState.members.is_empty():
		return 1
	var total: int = 0
	for m: Dictionary in PartyState.members:
		total += int(m.get("level", 1))
	return maxi(1, floori(float(total) / float(PartyState.members.size())))


func _on_transition_body_entered(body: Node2D, area: Area2D) -> void:
	if _transitioning or body != _player or _in_cutscene or _in_auto_walk:
		return
	var req_flag: String = area.get_meta("required_flag", "")
	if not req_flag.is_empty() and not EventFlags.get_flag(req_flag):
		return
	var tgt: String = area.get_meta("target_map", "")
	if tgt != "":
		_transition_to_map(tgt, area.get_meta("target_spawn", ""))


func _transition_to_map(target_map: String, target_spawn: String) -> void:
	_danger_counter = 0
	_transitioning = true
	if _auto_walk_tween != null and _auto_walk_tween.is_valid():
		_auto_walk_tween.kill()
		_auto_walk_tween = null
		_in_auto_walk = false
		if _player != null:
			_player.set_input_enabled(true)
	if _arrival_tween != null and _arrival_tween.is_valid():
		_arrival_tween.kill()
		_arrival_tween = null
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
		_flash_tween = null
		_location_panel.visible = false
	_fade_rect.visible = true
	_fade_rect.color = Color(0, 0, 0, 0)
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_transition_tween.tween_property(_fade_rect, "color:a", 1.0, FADE_DURATION)
	_transition_tween.tween_callback(_do_map_swap.bind(target_map, target_spawn))
	_transition_tween.tween_property(_fade_rect, "color:a", 0.0, FADE_DURATION)
	_transition_tween.tween_callback(_end_transition)


func _do_map_swap(target_map: String, target_spawn: String) -> void:
	var map_path: String = MAP_BASE_PATH + target_map + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Transition target not found: %s" % map_path)
		_abort_transition()
		return
	load_map(target_map, target_spawn)


func _abort_transition() -> void:
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_pending_cutscene = {}
	_cutscene_return = {}
	_end_transition()


func _end_transition() -> void:
	_fade_rect.visible = false
	_transitioning = false
	if _player != null and not _in_cutscene and not _in_auto_walk:
		_player.set_input_enabled(true)


# ---------- Auto-walk and auto-sequences ----------


func _start_auto_walk() -> void:
	if _player == null or _current_map == null:
		return
	_in_auto_walk = true
	_player.set_input_enabled(false)
	var transitions: Node = _current_map.get_node_or_null("Transitions")
	if transitions == null:
		_player.set_input_enabled(true)
		return
	var target_pos: Vector2 = _player.position
	for child: Node in transitions.get_children():
		if child is Area2D:
			target_pos = child.position
			break
	var direction: Vector2 = (target_pos - _player.position).normalized()
	if absf(direction.x) > absf(direction.y):
		_player.play_animation("walk_east" if direction.x > 0 else "walk_west")
	else:
		_player.play_animation("walk_south" if direction.y > 0 else "walk_north")
	var distance: float = _player.position.distance_to(target_pos)
	var duration: float = distance / 80.0
	if _auto_walk_tween != null and _auto_walk_tween.is_valid():
		_auto_walk_tween.kill()
	_auto_walk_tween = create_tween()
	_auto_walk_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_auto_walk_tween.tween_property(_player, "position", target_pos, duration)
	_auto_walk_tween.tween_callback(_end_auto_walk)


func _end_auto_walk() -> void:
	_in_auto_walk = false
	if _player != null:
		_player.position = _player.position.round()
		_player.set_input_enabled(true)


func _run_auto_sequence(sequence_id: String, completion_flag: String) -> void:
	match sequence_id:
		"caden_binding":
			_run_caden_binding(completion_flag)
		_:
			push_warning("Exploration: Unknown auto_sequence '%s'" % sequence_id)


func _run_caden_binding(completion_flag: String) -> void:
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return
	var spawn: Node2D = _current_map.get_node_or_null("CadenSpawnPoint")
	var center: Vector2 = Vector2(128, 80)
	var start_pos: Vector2 = spawn.position if spawn != null else Vector2(288, 80)
	var caden: Node2D = NPC_SCENE.instantiate()
	var entities: Node = _current_map.get_node_or_null("Entities")
	if entities != null:
		entities.add_child(caden)
	else:
		_current_map.add_child(caden)
	caden.position = start_pos
	caden.modulate.a = 0.0
	caden.initialize("caden_duskfen")
	if _arrival_tween != null and _arrival_tween.is_valid():
		_arrival_tween.kill()
	_arrival_tween = create_tween()
	_arrival_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_arrival_tween.set_parallel(true)
	_arrival_tween.tween_property(caden, "modulate:a", 1.0, 0.5)
	_arrival_tween.tween_property(caden, "position", center, 1.5)
	_arrival_tween.chain().tween_callback(_caden_start_dialogue.bind(caden, completion_flag))


func _caden_start_dialogue(caden: Node2D, completion_flag: String) -> void:
	var scene_data: Dictionary = DataManager.load_dialogue("caden_binding")
	var raw_entries: Array = scene_data.get("entries", [])
	var entries: Array[Dictionary] = []
	for e: Variant in raw_entries:
		if e is Dictionary:
			entries.append(e as Dictionary)
	if entries.is_empty():
		_caden_complete(caden, completion_flag)
		return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(entries)
		GameManager.overlay_state_changed.connect(
			_on_caden_dialogue_closed.bind(caden, completion_flag), CONNECT_ONE_SHOT
		)
	else:
		_caden_complete(caden, completion_flag)


func _on_caden_dialogue_closed(
	state: GameManager.OverlayState, caden: Node2D, completion_flag: String
) -> void:
	if state != GameManager.OverlayState.NONE:
		GameManager.overlay_state_changed.connect(
			_on_caden_dialogue_closed.bind(caden, completion_flag), CONNECT_ONE_SHOT
		)
		return
	_caden_complete(caden, completion_flag)


func _caden_complete(caden: Node2D, completion_flag: String) -> void:
	PartyState.add_key_item("fenmothers_blessing")
	flash_location_name("Received Fenmother's Blessing!")
	EventFlags.set_flag(completion_flag, true)
	EventFlags.set_flag("duskfen_alliance", true)
	caden.queue_free()
	var post_npc: Node = _current_map.get_node_or_null("Entities/CadenPostEvent")
	if post_npc != null:
		post_npc.visible = true


# ---------- Cutscene overlay integration (delegated to CutsceneHandler) ----------


func _on_overlay_state_changed(new_state: GameManager.OverlayState) -> void:
	_get_cutscene_handler().on_overlay_state_changed(new_state)


func _start_pending_cutscene(cutscene_id: String, entries: Array[Dictionary], tier: int) -> void:
	_get_cutscene_handler().start_pending_cutscene(cutscene_id, entries, tier)


func _on_cutscene_trigger_entered(body: Node2D, area: Area2D) -> void:
	_get_cutscene_handler().on_cutscene_trigger_entered(body, area)


func _get_cutscene_handler() -> CutsceneHandler:
	if _cutscene_handler == null:
		_cutscene_handler = CutsceneHandler.new(self)
	return _cutscene_handler


func _get_entity_manager() -> ExplorationEntityManager:
	if _entity_manager == null:
		_entity_manager = ExplorationEntityManager.new(self)
	return _entity_manager


func _get_zone_handler() -> ExplorationZoneHandler:
	if _zone_handler == null:
		_zone_handler = ExplorationZoneHandler.new(self)
	return _zone_handler


# ---------- Public accessors for delegated handlers ----------


func get_player() -> Node2D:
	return _player


func get_current_map() -> Node2D:
	return _current_map


func reset_danger_counter() -> void:
	_danger_counter = 0


func set_transitioning(value: bool) -> void:
	_transitioning = value


func get_zone_damage_callback() -> Callable:
	return _on_zone_damage_dealt


func get_entities() -> Dictionary:
	return _entities


func get_camera() -> Camera2D:
	return _camera


func get_fade_rect() -> ColorRect:
	return _fade_rect


func is_in_auto_walk() -> bool:
	return _in_auto_walk


func is_in_cutscene() -> bool:
	return _in_cutscene


func set_in_cutscene(value: bool) -> void:
	_in_cutscene = value
	GameManager.cutscene_active = value


## Deferred callback for cutscene handler — only clears _in_cutscene if
## the handler that requested the clear is still inactive (no back-to-back
## cutscene has started since the deferred call was scheduled).
func _deferred_clear_cutscene_flag(handler: CutsceneHandler) -> void:
	if handler != null and handler.is_cutscene_active():
		return
	_in_cutscene = false
	GameManager.cutscene_active = false


func get_cutscene_return() -> Dictionary:
	return _cutscene_return


func set_cutscene_return(value: Dictionary) -> void:
	_cutscene_return = value


func is_transitioning() -> bool:
	return _transitioning


func get_pending_cutscene() -> Dictionary:
	return _pending_cutscene


func set_pending_cutscene(value: Dictionary) -> void:
	_pending_cutscene = value


func transition_to_map(target_map: String, target_spawn: String) -> void:
	_transition_to_map(target_map, target_spawn)


# ---------- Crystal XP distribution ----------


func distribute_crystal_xp(xp_per_member: int) -> void:
	if xp_per_member <= 0:
		return
	var active: Array = PartyState.formation.get("active", [])
	for idx: Variant in active:
		if not (idx is int or idx is float):
			continue
		var member_index: int = int(idx)
		if member_index < 0 or member_index >= PartyState.members.size():
			continue
		var m: Dictionary = PartyState.members[member_index]
		var cid: String = m.get("equipment", {}).get("crystal", "")
		if not cid.is_empty():
			PartyState.add_crystal_xp(cid, int(xp_per_member * 0.3))


func _get_cleansing() -> CleansingSequence:
	if _cleansing == null:
		_cleansing = CleansingSequence.new(self)
	return _cleansing
