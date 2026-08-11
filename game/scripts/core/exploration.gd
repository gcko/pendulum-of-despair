class_name Exploration
extends Node2D
## The overworld/dungeon scene: it owns the player, the loaded map and the
## camera, and routes everything else to collaborators in `scripts/core/` —
## ExplorationScreen (fades and map swaps), ExplorationInteractions (NPCs,
## chests, save points, dialogue and transition triggers),
## ExplorationEntityManager (entity init and signal wiring),
## ExplorationZoneHandler (zones, encounters, boss triggers),
## ExplorationAutoSequence (auto-walk and story sequences),
## ExplorationPartyJoins (recovering missed recruits) and CutsceneHandler.
## The split is GAP-087; each collaborator names this file in its own doc.

signal map_changed(map_id: String)

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const MAP_BASE_PATH: String = "res://scenes/maps/"
var _current_map_id: String = ""
var _current_map: Node2D = null
var _player: Node2D = null
var _transitioning: bool = false
var _danger_counter: int = 0
var _last_player_tile: Vector2i = Vector2i(-999, -999)
var _encounter_config: Dictionary = {}
var _encounter_entries: Array = []
var _encounter_id_key: String = "floor_id"
var _zone_map: Array = []
var _current_floor_id: String = ""
var _cleansing: CleansingSequence = null
var _in_cutscene: bool = false
var _cutscene_handler: CutsceneHandler = null
var _screen: ExplorationScreen = null
var _interactions: ExplorationInteractions = null
var _entity_manager: ExplorationEntityManager = null
var _zone_handler: ExplorationZoneHandler = null
var _auto_seq: ExplorationAutoSequence = null
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


func _exit_tree() -> void:
	_disconnect_pending_signals()
	if _cleansing != null:
		_cleansing.cleanup()
	if GameManager.overlay_state_changed.is_connected(_on_overlay_state_changed):
		GameManager.overlay_state_changed.disconnect(_on_overlay_state_changed)


func _disconnect_pending_signals() -> void:
	_get_interactions().disconnect_pending_signals()
	get_auto_sequence().disconnect_pending_signals()


func _process(_delta: float) -> void:
	if _in_cutscene:
		return
	if _player != null and _camera != null:
		_camera.position = _player.position.round()


func _physics_process(_delta: float) -> void:
	if _player == null or _transitioning:
		return
	# Every frame, cutscenes included, so any save stores the real spot (#269).
	_record_player_location()
	if get_auto_sequence().in_auto_walk or _in_cutscene:
		return
	var current_tile: Vector2i = Vector2i(_player.position) / 16
	if current_tile == _last_player_tile:
		return
	_last_player_tile = current_tile
	_process_encounter_step()


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning or get_auto_sequence().in_auto_walk or _in_cutscene:
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
	_get_interactions().clear_chest_registries()
	_initialize_entities(_current_map)
	_connect_entity_signals(_current_map)
	_position_player_at_spawn(spawn_name)
	_current_floor_id = _current_map.get_meta("floor_id", "")
	if _player != null:
		_last_player_tile = Vector2i(_player.position) / 16
	_danger_counter = 0
	var dungeon_id: String = _current_map.get_meta("dungeon_id", _current_map_id)
	var setup: Dictionary = ZoneResolver.build_encounter_setup(
		DataManager.load_encounters(dungeon_id), _current_floor_id
	)
	_encounter_entries = setup.entries
	_encounter_id_key = setup.id_key
	_encounter_config = setup.config
	_zone_map = DataManager.load_zone_map(dungeon_id) if setup.use_zones else []
	var location_name: String = _current_map.get_meta("location_name", "")
	# The place name the pause menu and save slots show; the map id is a path.
	PartyState.location_display = location_name
	_get_screen().flash_location_once(location_name)
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


## Fade a line of text in over the map, hold it, and fade it out.
func flash_location_name(text: String) -> void:
	_get_screen().flash_location_name(text)


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
		# Title -> Continue applies the save here rather than through
		# SaveManager, so the ambient dialogue cursors have to be reset on this
		# path too — they are session state, not save state.
		NPC.reset_dialogue_cycles()
		PartyState.load_from_save(data.get("save_data", {}))
		# Read before load_map records the spawn; no stored position keeps it (#269).
		# location_name is set by load_from_save from world.current_location, so
		# the save format stays decoded in exactly one place.
		var had_position: bool = PartyState.has_player_position
		var saved_position: Vector2i = PartyState.player_position
		var location: String = PartyState.location_name
		load_map(location if location != "" else "overworld")
		if _current_map == null:
			# The saved map was renamed or dropped between builds; an empty scene
			# has no floor and no exit, so degrade to the overworld instead.
			load_map("overworld")
			had_position = false
		if _player != null and had_position:
			_player.position = Vector2(saved_position)
			_record_player_location()
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
			_record_player_location()
	else:
		load_map("overworld")
	# Safety net: if a party-joining flag was set but the member was never
	# added (e.g., crash or force-quit during dialogue), pick them up now.
	ExplorationPartyJoins.check_join_flags(self)


func _initialize_entities(map_node: Node2D) -> void:
	_get_entity_manager().initialize_entities(map_node)


func _connect_entity_signals(map_node: Node2D) -> void:
	_get_entity_manager().connect_entity_signals(map_node)


func _disconnect_entity_signals(map_node: Node2D) -> void:
	_get_entity_manager().disconnect_entity_signals(map_node)


## Record where the party stands so the next save writes it (#269).
func _record_player_location() -> void:
	if _player != null and not _current_map_id.is_empty():
		PartyState.set_player_location(_current_map_id, Vector2i(_player.position.round()))


func _position_player_at_spawn(spawn_name: String) -> void:
	if _player == null or _current_map == null:
		return
	var marker_name: String = spawn_name if spawn_name != "" else "PlayerSpawn"
	var spawn: Node2D = _current_map.get_node_or_null(marker_name)
	_player.position = spawn.position.round() if spawn != null else Vector2(80, 90)
	_record_player_location()


func _on_interaction_requested(interactable: Node2D) -> void:
	_get_interactions().on_interaction_requested(interactable)


func on_npc_interacted(npc_id: String, dialogue_data: Dictionary) -> void:
	_get_interactions().on_npc_interacted(npc_id, dialogue_data)


func on_chest_opened(chest_id: String, item_id: String, quantity: int) -> void:
	_get_interactions().on_chest_opened(chest_id, item_id, quantity)


func on_save_point_activated(_save_point_id: String) -> void:
	_get_interactions().on_save_point_activated()


func on_save_point_entered(_save_point_id: String) -> void:
	_get_interactions().on_save_point_entered()


func on_save_point_exited(_save_point_id: String) -> void:
	PartyState.is_at_save_point = false


func on_trigger_fired(_trigger_id: String) -> void:
	# Stub — trigger behavior dispatched per-map in future gaps.
	pass


func on_wheel_toggled(wheel_id: String, is_high: bool) -> void:
	_get_zone_handler().on_wheel_toggled(wheel_id, is_high)


func on_plate_pressed(plate_id: String) -> void:
	_get_zone_handler().on_plate_pressed(plate_id)


func on_crystal_cleared(crystal_id: String) -> void:
	_get_zone_handler().on_crystal_cleared(crystal_id)


func on_pitfall_triggered(target_map_id: String, target_spawn: String) -> void:
	_get_zone_handler().on_pitfall_triggered(target_map_id, target_spawn)


func on_spring_filled() -> void:
	_get_zone_handler().on_spring_filled()


func on_plant_restored(plant_id: String) -> void:
	_get_zone_handler().on_plant_restored(plant_id)


func on_zone_damage_dealt(zone_id: String, total_damage: int) -> void:
	_get_zone_handler().on_zone_damage_dealt(zone_id, total_damage)


func on_interaction_message(text: String) -> void:
	flash_location_name(text)


func on_boss_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning or _in_cutscene or get_auto_sequence().in_auto_walk:
		return
	_get_zone_handler().trigger_boss_encounter(area)


func on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	_get_interactions().on_dialogue_trigger_entered(body, area)


func on_transition_body_entered(body: Node2D, area: Area2D) -> void:
	_get_interactions().on_transition_body_entered(body, area)


## Fade out, swap the map, fade back in.
func transition_to_map(target_map: String, target_spawn: String) -> void:
	_get_screen().transition_to_map(target_map, target_spawn)


# ---------- Auto-walk and auto-sequences (delegated to ExplorationAutoSequence) ----------


func _start_auto_walk() -> void:
	get_auto_sequence().start_auto_walk()


func _end_auto_walk() -> void:
	get_auto_sequence().end_auto_walk()


func _run_auto_sequence(sequence_id: String, completion_flag: String) -> void:
	get_auto_sequence().run_auto_sequence(sequence_id, completion_flag)


# ---------- Cutscene overlay integration (delegated to CutsceneHandler) ----------


func _on_overlay_state_changed(new_state: GameManager.OverlayState) -> void:
	_get_cutscene_handler().on_overlay_state_changed(new_state)


func _start_pending_cutscene(cutscene_id: String, entries: Array[Dictionary], tier: int) -> void:
	_get_cutscene_handler().start_pending_cutscene(cutscene_id, entries, tier)


func on_cutscene_trigger_entered(body: Node2D, area: Area2D) -> void:
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


## The auto-walk / scripted-sequence collaborator.
func get_auto_sequence() -> ExplorationAutoSequence:
	if _auto_seq == null:
		_auto_seq = ExplorationAutoSequence.new(self)
	return _auto_seq


func _get_screen() -> ExplorationScreen:
	if _screen == null:
		_screen = ExplorationScreen.new(self)
	return _screen


func _get_interactions() -> ExplorationInteractions:
	if _interactions == null:
		_interactions = ExplorationInteractions.new(self)
	return _interactions


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
	return on_zone_damage_dealt


func get_entities() -> Dictionary:
	return _entities


func get_camera() -> Camera2D:
	return _camera


func get_fade_rect() -> ColorRect:
	return _fade_rect


## The panel the location flash fades in and out.
func get_location_panel() -> PanelContainer:
	return _location_panel


func get_location_label() -> Label:
	return _location_label


func is_in_auto_walk() -> bool:
	return get_auto_sequence().in_auto_walk


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


func get_current_map_id() -> String:
	return _current_map_id


func get_encounter_config() -> Dictionary:
	return _encounter_config


func get_zone_map() -> Array:
	return _zone_map


func get_player_tile() -> Vector2i:
	return _last_player_tile


## Swap the active encounter config to the entry matching [param zone_id]
## (per-tile zone selection, GAP-026). The danger counter is deliberately
## untouched — it resets only after battle or on map transition
## (combat-formulas.md § Danger Counter). An unmatched id clears the
## config; there is no silent fallback to the first entry.
func set_encounter_zone(zone_id: String) -> void:
	_encounter_config = ZoneResolver.find_entry(zone_id, _encounter_entries, _encounter_id_key)
	if _encounter_config.is_empty() and not zone_id.is_empty():
		push_warning("Exploration: no encounter entry for zone '%s'" % zone_id)


func get_danger_counter() -> int:
	return _danger_counter


func set_danger_counter(value: int) -> void:
	_danger_counter = maxi(0, value)


func clear_entities() -> void:
	_entities.clear()


func set_entity(entity_id: String, entity: Node) -> void:
	_entities[entity_id] = entity


func has_entity(entity_id: String) -> bool:
	return _entities.has(entity_id)


func register_key_item_chest(chest_id: String) -> void:
	_get_interactions().register_key_item_chest(chest_id)


func register_equipment_chest(chest_id: String) -> void:
	_get_interactions().register_equipment_chest(chest_id)


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
