extends Node2D

signal map_changed(map_id: String)

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const MAP_BASE_PATH: String = "res://scenes/maps/"
const FADE_DURATION: float = 0.3
const EncounterHandler = preload("res://scripts/core/encounter_handler.gd")
const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")
const CleansingSequence = preload("res://scripts/core/cleansing_sequence.gd")

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
var _cleansing: RefCounted = null
var _key_item_chest_ids: Dictionary = {}
var _equipment_chest_ids: Dictionary = {}
var _in_auto_walk: bool = false
var _auto_walk_tween: Tween = null
var _arrival_tween: Tween = null
var _cutscene_camera_tween: Tween = null
var _cutscene_shake_tween: Tween = null
var _in_cutscene: bool = false
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
	_camera.zoom = Vector2(4, 4)
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
	if _encounter_config.is_empty():
		return
	var result: int = EncounterHandler.process_step(
		_encounter_config, _danger_counter, PartyState.get_active_party()
	)
	if result == -1:
		_trigger_random_encounter()
	else:
		_danger_counter = result


func _trigger_random_encounter() -> void:
	if _transitioning:
		return
	var transition: Dictionary = EncounterHandler.build_random_encounter(
		_encounter_config, _current_map_id, _player.position
	)
	if transition.is_empty():
		return
	_danger_counter = 0
	_transitioning = true
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)


func _trigger_boss_encounter(area: Area2D) -> void:
	if _transitioning or _player == null or _in_cutscene:
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
	_danger_counter = 0
	_transitioning = true
	var transition: Dictionary = {
		"encounter_group": enemy_ids,
		"formation_type": "normal",
		"return_map_id": _current_map_id,
		"return_position": _player.position,
		"enemy_act": area.get_meta("enemy_act", "act_i"),
		"encounter_source": "boss",
		"is_boss": true,
		"boss_flag": flag,
	}
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)


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
	if _current_map.get_meta("is_auto_walk", false) and _player != null:
		_start_auto_walk()
	var seq_id: String = _current_map.get_meta("auto_sequence", "")
	var seq_flag: String = _current_map.get_meta("auto_sequence_flag", "")
	if not seq_id.is_empty() and not EventFlags.get_flag(seq_flag):
		call_deferred("_run_auto_sequence", seq_id, seq_flag)
	if not _pending_cutscene.is_empty():
		var pc: Dictionary = _pending_cutscene
		_pending_cutscene = {}
		call_deferred(
			"_start_pending_cutscene",
			pc.get("id", ""),
			pc.get("entries", []),
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
			_player.position = data.get("position", Vector2(80, 90))
	else:
		load_map("overworld")
	# Safety net: if a party-joining flag was set but the member was never
	# added (e.g., crash or force-quit during dialogue), pick them up now.
	_check_party_joining_flags()


func _initialize_entities(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities == null:
		return
	for child: Node in entities.get_children():
		if not child.has_method("initialize"):
			continue
		if child.has_signal("npc_interacted"):
			if child.get_meta("cutscene_actor", false):
				continue
			var npc_id: String = child.get_meta("npc_id", "")
			if npc_id.is_empty():
				push_error("Exploration: NPC '%s' missing npc_id metadata" % child.name)
				continue
			child.initialize(npc_id)
		elif child.has_signal("chest_opened"):
			var chest_id: String = child.get_meta("chest_id", "")
			var item_id: String = child.get_meta("item_id", "")
			if chest_id.is_empty() or item_id.is_empty():
				push_error("Exploration: Chest '%s' missing chest_id/item_id" % child.name)
				continue
			if child.get_meta("is_key_item", false):
				_key_item_chest_ids[chest_id] = true
			if child.get_meta("is_equipment", false):
				_equipment_chest_ids[chest_id] = true
			var qty: int = child.get_meta("quantity", 1)
			child.initialize(chest_id, item_id, qty)
		elif child.has_signal("save_point_activated"):
			var sp_id: String = child.get_meta("save_point_id", "")
			if sp_id.is_empty():
				push_error("Exploration: SavePoint '%s' missing metadata" % child.name)
				continue
			child.initialize(sp_id)
		elif child.has_signal("wheel_toggled"):
			var wid: String = child.get_meta("wheel_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if wid.is_empty():
				push_error("Exploration: WaterWheel '%s' missing wheel_id" % child.name)
				continue
			if did.is_empty():
				push_error("Exploration: WaterWheel '%s' missing dungeon_id" % child.name)
				continue
			child.initialize(wid, did)
		elif child.has_signal("zone_refreshed"):
			var did: String = child.get_meta("dungeon_id", "")
			var conds: String = child.get_meta("active_when", "")
			var zt: String = child.get_meta("zone_type", "block")
			child.initialize(did, conds, zt)
		elif child.has_signal("plant_restored"):
			var pid: String = child.get_meta("plant_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if pid.is_empty():
				push_error("Exploration: SpiritPlant '%s' missing plant_id" % child.name)
				continue
			if did.is_empty():
				push_error("Exploration: SpiritPlant '%s' missing dungeon_id" % child.name)
				continue
			child.initialize(pid, did)
		elif child.has_signal("zone_damage_dealt"):
			var zid: String = child.get_meta("zone_id", "")
			var dpt: int = child.get_meta("damage_per_tick", 8)
			var ti: float = child.get_meta("tick_interval", 1.0)
			var se: String = child.get_meta("status_effect", "poison")
			child.initialize(zid, dpt, ti, se)
		elif child.has_signal("plate_pressed"):
			var pid: String = child.get_meta("plate_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if pid.is_empty():
				push_error("Exploration: PressurePlate '%s' missing plate_id" % child.name)
				continue
			if did.is_empty():
				push_error("Exploration: PressurePlate '%s' missing dungeon_id" % child.name)
				continue
			child.initialize(pid, did)
		elif child.has_signal("crystal_cleared"):
			var cid: String = child.get_meta("crystal_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if cid.is_empty():
				push_error("Exploration: EmberCrystal '%s' missing crystal_id" % child.name)
				continue
			if did.is_empty():
				push_error("Exploration: EmberCrystal '%s' missing dungeon_id" % child.name)
				continue
			child.initialize(cid, did)
		elif child.has_signal("pitfall_triggered"):
			var tmid: String = child.get_meta("target_map_id", "")
			var tsp: String = child.get_meta("target_spawn", "")
			if tmid.is_empty():
				push_error("Exploration: PitfallZone '%s' missing target_map_id" % child.name)
				continue
			child.initialize(tmid, tsp)
	# Apply flag-driven visibility (e.g., NPCs visible only after story events)
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
	_entities.clear()
	var entities_node: Node2D = map_node.get_node_or_null("Entities")
	if entities_node != null:
		for child: Node in entities_node.get_children():
			# NPCs store npc_id as metadata (set in editor)
			var nid: String = child.get_meta("npc_id", "")
			if nid != "":
				_entities[nid] = child
			# Characters use script variable character_id
			else:
				var child_character_id: Variant = child.get("character_id")
				if child_character_id is String and not child_character_id.is_empty():
					_entities[child_character_id] = child
	# Player character stores character_id as a script variable
	if _player != null:
		var player_character_id: Variant = _player.get("character_id")
		if player_character_id is String and not player_character_id.is_empty():
			_entities[player_character_id] = _player


func _connect_entity_signals(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities != null:
		for child: Node in entities.get_children():
			if child.has_signal("npc_interacted"):
				child.npc_interacted.connect(_on_npc_interacted)
			if child.has_signal("chest_opened"):
				child.chest_opened.connect(_on_chest_opened)
			if child.has_signal("save_point_activated"):
				child.save_point_activated.connect(_on_save_point_activated)
			if child.has_signal("wheel_toggled"):
				child.wheel_toggled.connect(_on_wheel_toggled)
			if child.has_signal("spring_filled"):
				child.spring_filled.connect(_on_spring_filled)
			if child.has_signal("plant_restored"):
				child.plant_restored.connect(_on_plant_restored)
			if child.has_signal("zone_damage_dealt"):
				child.zone_damage_dealt.connect(_on_zone_damage_dealt)
			if child.has_signal("plate_pressed"):
				child.plate_pressed.connect(_on_plate_pressed)
			if child.has_signal("crystal_cleared"):
				child.crystal_cleared.connect(_on_crystal_cleared)
			if child.has_signal("pitfall_triggered"):
				child.pitfall_triggered.connect(_on_pitfall_triggered)
			if child.has_signal("interaction_message"):
				child.interaction_message.connect(_on_interaction_message)
			if child is Area2D and child.has_meta("boss_id"):
				child.body_entered.connect(_on_boss_trigger_entered.bind(child))
			elif child is Area2D and child.has_meta("cutscene_scene_id"):
				child.body_entered.connect(_on_cutscene_trigger_entered.bind(child))
			elif (
				child is Area2D
				and (child.has_meta("dialogue_data") or child.has_meta("dialogue_scene_id"))
			):
				child.body_entered.connect(_on_dialogue_trigger_entered.bind(child))
	var transitions: Node = map_node.get_node_or_null("Transitions")
	if transitions != null:
		for child: Node in transitions.get_children():
			if child is Area2D and child.has_meta("target_map"):
				child.body_entered.connect(_on_transition_body_entered.bind(child))


func _disconnect_entity_signals(map_node: Node2D) -> void:
	var sigs: Dictionary = {
		"npc_interacted": _on_npc_interacted,
		"chest_opened": _on_chest_opened,
		"save_point_activated": _on_save_point_activated,
		"wheel_toggled": _on_wheel_toggled,
		"spring_filled": _on_spring_filled,
		"plant_restored": _on_plant_restored,
		"zone_damage_dealt": _on_zone_damage_dealt,
		"interaction_message": _on_interaction_message,
		"plate_pressed": _on_plate_pressed,
		"crystal_cleared": _on_crystal_cleared,
		"pitfall_triggered": _on_pitfall_triggered,
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
					if conn["callable"].get_object() == self:
						child.body_entered.disconnect(conn["callable"])


func _position_player_at_spawn(spawn_name: String) -> void:
	if _player == null or _current_map == null:
		return
	var marker_name: String = spawn_name if spawn_name != "" else "PlayerSpawn"
	var spawn: Node2D = _current_map.get_node_or_null(marker_name)
	_player.position = spawn.position.round() if spawn != null else Vector2(80, 90)


func _on_interaction_requested(interactable: Node2D) -> void:
	if _transitioning:
		return
	var target: Node2D = interactable
	if not target.has_method("interact"):
		var p: Node = target.get_parent()
		if p is Node2D and p.has_method("interact"):
			target = p as Node2D
	if target.has_method("interact"):
		target.interact()


func _find_entity_npc(npc_id: String) -> Node:
	var ents: Node = _current_map.get_node_or_null("Entities")
	if ents == null:
		return null
	for c: Node in ents.get_children():
		if c.has_signal("npc_interacted") and c.get("npc_id") == npc_id:
			return c
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
	PartyState.is_at_save_point = true
	if GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		GameManager.overlay_node.open_save_point()


func _on_wheel_toggled(_wheel_id: String, is_high: bool) -> void:
	var status: String = "HIGH" if is_high else "LOW"
	flash_location_name("Wheel set to %s" % status)
	if _current_map != null:
		var entities: Node = _current_map.get_node_or_null("Entities")
		if entities != null:
			for child: Node in entities.get_children():
				if child.has_method("refresh"):
					child.refresh()


func _on_plate_pressed(_plate_id: String) -> void:
	# Refresh water zones — same pattern as wheel_toggled
	if _current_map != null:
		var entities: Node = _current_map.get_node_or_null("Entities")
		if entities != null:
			for child: Node in entities.get_children():
				if child.has_method("refresh"):
					child.refresh()


func _on_crystal_cleared(_crystal_id: String) -> void:
	flash_location_name("The crystal springs to life!")


func _on_pitfall_triggered(target_map_id: String, target_spawn: String) -> void:
	if _transitioning or _in_cutscene:
		return
	flash_location_name("The floor gives way!")
	_transition_to_map(target_map_id, target_spawn)


func _on_spring_filled() -> void:
	flash_location_name("Filled the Spirit Vessel with pure water.")


func _on_plant_restored(_plant_id: String) -> void:
	flash_location_name("Passage Opened")
	var scene_data: Dictionary = DataManager.load_dialogue("water_of_life")
	var entries: Array = scene_data.get("entries", [])
	if not entries.is_empty() and GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(entries)


func _on_zone_damage_dealt(_zone_id: String, total_damage: int) -> void:
	if total_damage > 0 and _player != null:
		flash_location_name("-%d HP" % total_damage)


func _on_interaction_message(text: String) -> void:
	flash_location_name(text)


func _on_boss_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player:
		return
	_trigger_boss_encounter(area)


func _on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning or _in_cutscene:
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var required: String = area.get_meta("required_flag", "")
	if not required.is_empty() and not EventFlags.get_flag(required):
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
		total += m.get("level", 1) as int
	return maxi(1, floori(float(total) / float(PartyState.members.size())))


func _on_transition_body_entered(body: Node2D, area: Area2D) -> void:
	if _transitioning or body != _player or _in_cutscene:
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
	_end_transition()


func _end_transition() -> void:
	_fade_rect.visible = false
	_transitioning = false


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
	var entries: Array = scene_data.get("entries", [])
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


# ---------- Cutscene overlay integration ----------


func _on_overlay_state_changed(new_state: GameManager.OverlayState) -> void:
	if new_state == GameManager.OverlayState.CUTSCENE:
		_in_cutscene = true
		if _player != null:
			_player.set_input_enabled(false)
		_connect_cutscene_signals()
	elif new_state == GameManager.OverlayState.NONE and _in_cutscene:
		_on_cutscene_finished()


func _connect_cutscene_signals() -> void:
	var cs: Node = GameManager.overlay_node
	if cs == null:
		return
	_safe_connect(cs, "cutscene_move_requested", _on_cutscene_move)
	_safe_connect(cs, "cutscene_anim_requested", _on_cutscene_anim)
	_safe_connect(cs, "cutscene_camera_requested", _on_cutscene_camera)
	_safe_connect(cs, "cutscene_shake_requested", _on_cutscene_shake)
	_safe_connect(cs, "cutscene_music_requested", _on_cutscene_music)
	_safe_connect(cs, "flag_set_requested", _on_cutscene_flag_set)
	_safe_connect(cs, "sfx_requested", _on_cutscene_sfx)


func _safe_connect(src: Node, sig: String, handler: Callable) -> void:
	if src.has_signal(sig) and not src.is_connected(sig, handler):
		src.connect(sig, handler)


func _on_cutscene_move(who: String, target: Vector2, speed: float) -> void:
	var entity: Node = _entities.get(who, null)
	if entity == null:
		if OS.is_debug_build():
			push_warning("Cutscene: entity not found: %s" % who)
		return
	if entity.has_method("walk_to"):
		entity.walk_to(target, speed)


func _on_cutscene_anim(who: String, anim: String) -> void:
	var entity: Node = _entities.get(who, null)
	if entity == null:
		if OS.is_debug_build():
			push_warning("Cutscene: entity not found for anim: %s" % who)
		return
	if entity.has_method("play_animation"):
		entity.play_animation(anim)
	elif entity.has_node("AnimationPlayer"):
		var ap: AnimationPlayer = entity.get_node("AnimationPlayer")
		if ap.has_animation(anim):
			ap.play(anim)


func _on_cutscene_camera(target: Vector2, duration: float) -> void:
	if _camera == null:
		return
	if _cutscene_camera_tween != null and _cutscene_camera_tween.is_valid():
		_cutscene_camera_tween.kill()
	_cutscene_camera_tween = create_tween()
	_cutscene_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_cutscene_camera_tween.tween_property(_camera, "position", target, duration)


func _on_cutscene_shake(intensity: int, duration: float) -> void:
	if _camera == null:
		return
	if _cutscene_shake_tween != null and _cutscene_shake_tween.is_valid():
		_cutscene_shake_tween.kill()
	_cutscene_shake_tween = create_tween()
	_cutscene_shake_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var step_duration: float = 0.05
	var steps: int = maxi(int(duration / step_duration) - 1, 0)
	for i in range(steps):
		var offset := Vector2(
			float(randi_range(-intensity, intensity)), float(randi_range(-intensity, intensity))
		)
		_cutscene_shake_tween.tween_property(_camera, "offset", offset, step_duration)
	var reset_duration: float = duration - (float(steps) * step_duration)
	_cutscene_shake_tween.tween_property(_camera, "offset", Vector2.ZERO, reset_duration)


func _on_cutscene_finished() -> void:
	_in_cutscene = false
	if _cutscene_camera_tween != null and _cutscene_camera_tween.is_valid():
		_cutscene_camera_tween.kill()
	_cutscene_camera_tween = null
	if _cutscene_shake_tween != null and _cutscene_shake_tween.is_valid():
		_cutscene_shake_tween.kill()
	_cutscene_shake_tween = null
	# Kill any in-flight entity walk tweens from cutscene move commands
	for entity: Node in _entities.values():
		if is_instance_valid(entity) and entity.has_method("cancel_walk"):
			entity.cancel_walk()
	if _player != null and is_instance_valid(_player) and _player.has_method("cancel_walk"):
		_player.cancel_walk()
	if _camera != null and _player != null:
		_camera.position = _player.position.round()
		_camera.offset = Vector2.ZERO
	if _player != null and not _in_auto_walk:
		_player.set_input_enabled(true)
	if not _cutscene_return.is_empty():
		var ret: Dictionary = _cutscene_return
		_cutscene_return = {}
		var ret_map: String = ret.get("map", "")
		var ret_spawn: String = ret.get("spawn", "PlayerSpawn")
		if ret_map != "":
			_transition_to_map(ret_map, ret_spawn)


func _on_cutscene_flag_set(flag_name: String, value: Variant) -> void:
	EventFlags.set_flag(flag_name, value)


func _on_cutscene_music(_track_id: String, _action: String) -> void:
	# Stub — AudioManager integration in gap 3.8
	pass


func _on_cutscene_sfx(_sfx_id: String) -> void:
	# Stub — AudioManager integration in gap 3.8
	pass


func _start_pending_cutscene(cutscene_id: String, entries: Array, tier: int) -> void:
	if not GameManager.push_overlay(GameManager.OverlayState.CUTSCENE):
		push_error("Exploration: Failed to push CUTSCENE overlay for '%s'" % cutscene_id)
		_cutscene_return = {}
		return
	GameManager.overlay_node.start_cutscene(cutscene_id, entries, tier)


func _on_cutscene_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning or _in_auto_walk or _in_cutscene:
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
		return
	var required: String = area.get_meta("required_flag", "")
	if not required.is_empty() and not EventFlags.get_flag(required):
		return
	var scene_id: String = area.get_meta("cutscene_scene_id", "")
	var map_id: String = area.get_meta("cutscene_map_id", "")
	var return_map: String = area.get_meta("cutscene_return_map", "")
	var return_spawn: String = area.get_meta("cutscene_return_spawn", "")
	# Load cutscene data from dialogue JSON
	var scene_data: Dictionary = DataManager.load_dialogue(scene_id)
	if scene_data.is_empty():
		push_error("Exploration: Failed to load cutscene dialogue '%s'" % scene_id)
		return
	var entries: Array = scene_data.get("entries", [])
	var cutscene_id: String = scene_data.get("cutscene_id", scene_id)
	var tier: int = scene_data.get("cutscene_tier", 1)
	if entries.is_empty():
		push_error("Exploration: Cutscene '%s' has no entries" % scene_id)
		return
	# Set one-shot flag AFTER validation (prevents burning flag on failure)
	if not flag.is_empty():
		EventFlags.set_flag(flag, true)
	# Store return info only when a return map is specified
	if return_map != "":
		_cutscene_return = {"map": return_map, "spawn": return_spawn}
	if map_id != "":
		# Transition to cutscene map, then start cutscene after load
		_pending_cutscene = {"id": cutscene_id, "entries": entries, "tier": tier}
		_transition_to_map(map_id, "PlayerSpawn")
	else:
		# Start cutscene on current map
		_start_pending_cutscene(cutscene_id, entries, tier)


# ---------- Public accessors for CleansingSequence ----------


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
