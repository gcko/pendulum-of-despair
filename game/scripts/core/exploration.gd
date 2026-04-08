extends Node2D

signal map_changed(map_id: String)

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const MAP_BASE_PATH: String = "res://scenes/maps/"
const FADE_DURATION: float = 0.3
const EncounterHandler = preload("res://scripts/core/encounter_handler.gd")

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

@onready var _camera: Camera2D = $Camera2D
@onready var _map_container: Node2D = $CurrentMap
@onready var _fade_rect: ColorRect = $FadeOverlay/FadeRect
@onready var _location_panel: PanelContainer = $LocationFlash/LocationLabel
@onready var _location_label: Label = $LocationFlash/LocationLabel/NameLabel


func _ready() -> void:
	_fade_rect.visible = false
	_location_panel.visible = false
	_spawn_player()
	_initialize_from_transition_data()


func _process(_delta: float) -> void:
	if _player != null and _camera != null:
		_camera.position = _player.position.round()


func _physics_process(_delta: float) -> void:
	if _player == null or _transitioning:
		return
	var current_tile: Vector2i = Vector2i(_player.position) / 16
	if current_tile == _last_player_tile:
		return
	_last_player_tile = current_tile
	_process_encounter_step()


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_menu"):
		if GameManager.push_overlay(GameManager.OverlayState.MENU):
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and _player != null:
		get_viewport().set_input_as_handled()
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
	if _transitioning or _player == null:
		return
	if area.get_meta("boss_id", "").is_empty():
		return
	var flag: String = area.get_meta("flag", "")
	if not flag.is_empty() and EventFlags.get_flag(flag):
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
	PartyState.is_at_save_point = false
	var map_path: String = MAP_BASE_PATH + map_id + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Map not found: %s" % map_path)
		return
	var map_resource: Resource = load(map_path)
	if not map_resource is PackedScene:
		push_error("Exploration: Invalid map resource: %s" % map_path)
		return
	if _current_map != null:
		_disconnect_entity_signals(_current_map)
		_current_map.queue_free()
		_current_map = null
	_current_map = (map_resource as PackedScene).instantiate()
	_map_container.add_child(_current_map)
	_current_map_id = map_id
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


func flash_location_name(text: String) -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_location_label.text = text
	_location_panel.visible = true
	_location_panel.modulate = Color(1, 1, 1, 0)
	_flash_tween = create_tween()
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
		load_map("overworld")
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
		if r == "victory":
			var rewards: Dictionary = {
				"xp": data.get("earned_xp", 0),
				"gold": data.get("earned_gold", 0),
				"drops": data.get("earned_drops", [])
			}
			PartyState.distribute_battle_rewards(rewards)
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


func _initialize_entities(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities == null:
		return
	for child: Node in entities.get_children():
		if not child.has_method("initialize"):
			continue
		if child.has_signal("npc_interacted"):
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
			child.initialize(chest_id, item_id)
		elif child.has_signal("save_point_activated"):
			var sp_id: String = child.get_meta("save_point_id", "")
			if sp_id.is_empty():
				push_error("Exploration: SavePoint '%s' missing metadata" % child.name)
				continue
			child.initialize(sp_id)


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
			if child is Area2D and child.has_meta("boss_id"):
				child.body_entered.connect(_on_boss_trigger_entered.bind(child))
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
		"save_point_activated": _on_save_point_activated
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
	if not _transitioning and interactable.has_method("interact"):
		interactable.interact()


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


func _on_chest_opened(_chest_id: String, item_id: String) -> void:
	PartyState.add_item(item_id, 1)
	flash_location_name("Found %s!" % item_id)


func _on_save_point_activated(_save_point_id: String) -> void:
	PartyState.is_at_save_point = true
	if GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		GameManager.overlay_node.open_save_point()


func _on_boss_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player:
		return
	_trigger_boss_encounter(area)


func _on_dialogue_trigger_entered(body: Node2D, area: Area2D) -> void:
	if body != _player or _transitioning:
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
			_check_party_joining_flags()


func _check_party_joining_flags() -> void:
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
	return maxi(1, total / PartyState.members.size())


func _on_transition_body_entered(body: Node2D, area: Area2D) -> void:
	if _transitioning or body != _player:
		return
	var tgt: String = area.get_meta("target_map", "")
	if tgt != "":
		_transition_to_map(tgt, area.get_meta("target_spawn", ""))


func _transition_to_map(target_map: String, target_spawn: String) -> void:
	_danger_counter = 0
	_transitioning = true
	_fade_rect.visible = true
	_fade_rect.color = Color(0, 0, 0, 0)
	_transition_tween = create_tween()
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
