extends Node2D
## Exploration core state scene. Loads maps, manages player, wires entity signals.
## Reads GameManager.transition_data on _ready() for New Game vs Continue.

signal map_changed(map_id: String)

const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_character.tscn")
const MAP_BASE_PATH: String = "res://scenes/maps/"
const FADE_DURATION: float = 0.3

var _current_map_id: String = ""
var _current_map: Node2D = null
var _player: Node2D = null
var _transitioning: bool = false
var _last_flash_id: String = ""
var _flash_tween: Tween = null

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


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_accept") and _player != null:
		if _player.has_method("try_interact"):
			_player.try_interact()


func load_map(map_id: String, spawn_name: String = "") -> void:
	if _current_map != null:
		_disconnect_entity_signals(_current_map)
		_current_map.queue_free()
		_current_map = null

	var map_path: String = MAP_BASE_PATH + map_id + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Map not found: %s" % map_path)
		return

	var map_resource: Resource = load(map_path)
	if not map_resource is PackedScene:
		push_error("Exploration: Invalid map resource: %s" % map_path)
		return

	_current_map = (map_resource as PackedScene).instantiate()
	_map_container.add_child(_current_map)
	_current_map_id = map_id

	_initialize_entities(_current_map)
	_connect_entity_signals(_current_map)
	_position_player_at_spawn(spawn_name)

	var location_name: String = _current_map.get_meta("location_name", "")
	if location_name != "" and location_name != _last_flash_id:
		flash_location_name(location_name)
		_last_flash_id = location_name

	map_changed.emit(map_id)


func flash_location_name(location_name: String) -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_location_label.text = location_name
	_location_panel.visible = true
	_location_panel.modulate = Color(1, 1, 1, 0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_location_panel, "modulate:a", 1.0, 0.5)
	_flash_tween.tween_interval(2.0)
	_flash_tween.tween_property(_location_panel, "modulate:a", 0.0, 0.5)
	_flash_tween.tween_callback(_hide_location_panel)


func _hide_location_panel() -> void:
	_location_panel.visible = false


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	add_child(_player)
	if _player.has_method("initialize"):
		_player.initialize("edren")
	if _player.has_signal("interaction_requested"):
		_player.interaction_requested.connect(_on_interaction_requested)


func _initialize_from_transition_data() -> void:
	var data: Dictionary = GameManager.transition_data
	if data.get("new_game", false):
		load_map("test_room")
	elif data.has("save_data"):
		var save_data: Dictionary = data.get("save_data", {})
		var world: Dictionary = save_data.get("world", {})
		var location: String = world.get("current_location", "")
		if location == "":
			location = "test_room"
		load_map(location)
		var pos: Dictionary = world.get("current_position", {})
		if _player != null and pos.has("x") and pos.has("y"):
			_player.position = Vector2(pos["x"], pos["y"])
	else:
		load_map("test_room")


func _initialize_entities(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities == null:
		return
	for child: Node in entities.get_children():
		if not child.has_method("initialize"):
			continue
		if child.has_signal("npc_interacted"):
			var npc_id: String = child.get_meta("npc_id", "")
			if npc_id != "":
				child.initialize(npc_id)
			else:
				push_error("Exploration: NPC '%s' missing npc_id metadata" % child.name)
		elif child.has_signal("chest_opened"):
			var chest_id: String = child.get_meta("chest_id", "")
			var item_id: String = child.get_meta("item_id", "")
			if chest_id != "" and item_id != "":
				child.initialize(chest_id, item_id)
			else:
				push_error("Exploration: Chest '%s' missing metadata" % child.name)
		elif child.has_signal("save_point_activated"):
			var sp_id: String = child.get_meta("save_point_id", "")
			if sp_id != "":
				child.initialize(sp_id)
			else:
				push_error("Exploration: SavePoint '%s' missing metadata" % child.name)


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

	# Transitions use plain Area2D with body_entered (repeatable, not one-shot TriggerZone)
	var transitions: Node = map_node.get_node_or_null("Transitions")
	if transitions != null:
		for child: Node in transitions.get_children():
			if child is Area2D and child.has_meta("target_map"):
				child.body_entered.connect(_on_transition_body_entered.bind(child))


func _disconnect_entity_signals(map_node: Node2D) -> void:
	var entities: Node = map_node.get_node_or_null("Entities")
	if entities != null:
		for child: Node in entities.get_children():
			for sig_name: String in ["npc_interacted", "chest_opened", "save_point_activated"]:
				if child.has_signal(sig_name):
					var callable_ref: Callable = _get_handler_for_signal(sig_name)
					if child.is_connected(sig_name, callable_ref):
						child.disconnect(sig_name, callable_ref)

	var transitions: Node = map_node.get_node_or_null("Transitions")
	if transitions != null:
		for child: Node in transitions.get_children():
			if child is Area2D:
				for conn: Dictionary in child.body_entered.get_connections():
					if conn["callable"].get_object() == self:
						child.body_entered.disconnect(conn["callable"])


func _get_handler_for_signal(sig_name: String) -> Callable:
	match sig_name:
		"npc_interacted":
			return _on_npc_interacted
		"chest_opened":
			return _on_chest_opened
		"save_point_activated":
			return _on_save_point_activated
	return Callable()


func _position_player_at_spawn(spawn_name: String) -> void:
	if _player == null or _current_map == null:
		return
	var marker_name: String = spawn_name if spawn_name != "" else "PlayerSpawn"
	var spawn: Node2D = _current_map.get_node_or_null(marker_name)
	if spawn != null:
		_player.position = spawn.position.round()
	else:
		_player.position = Vector2(80, 90)


# --- Signal handlers ---


func _on_interaction_requested(interactable: Node2D) -> void:
	if _transitioning:
		return
	if interactable.has_method("interact"):
		interactable.interact()


func _on_npc_interacted(_npc_id: String, dialogue_data: Dictionary) -> void:
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		var overlay: Node = GameManager.overlay_node
		if overlay != null and overlay.has_method("show_dialogue"):
			overlay.show_dialogue([dialogue_data])


func _on_chest_opened(chest_id: String, item_id: String) -> void:
	flash_location_name("Found %s!" % item_id)
	if OS.is_debug_build():
		print_debug("Chest %s opened: %s" % [chest_id, item_id])


func _on_save_point_activated(_save_point_id: String) -> void:
	if GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		var overlay: Node = GameManager.overlay_node
		if overlay != null and overlay.has_method("open_save_point"):
			overlay.open_save_point()


func _on_transition_body_entered(_body: Node2D, area: Area2D) -> void:
	if _transitioning:
		return
	var target_map: String = area.get_meta("target_map", "")
	var target_spawn: String = area.get_meta("target_spawn", "")
	if target_map != "":
		_transition_to_map(target_map, target_spawn)


func _transition_to_map(target_map: String, target_spawn: String) -> void:
	_transitioning = true
	_fade_rect.visible = true
	_fade_rect.color = Color(0, 0, 0, 0)
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, FADE_DURATION)
	tween.tween_callback(_do_map_swap.bind(target_map, target_spawn))
	tween.tween_property(_fade_rect, "color:a", 0.0, FADE_DURATION)
	tween.tween_callback(_end_transition)


func _do_map_swap(target_map: String, target_spawn: String) -> void:
	var map_path: String = MAP_BASE_PATH + target_map + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Transition target not found: %s" % map_path)
		_end_transition()
		return
	load_map(target_map, target_spawn)


func _end_transition() -> void:
	_fade_rect.visible = false
	_transitioning = false
