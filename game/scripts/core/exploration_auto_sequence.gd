class_name ExplorationAutoSequence
extends RefCounted
## Handles auto-walk sequences and story auto-sequences (e.g., Caden binding).
## Extracted from Exploration to keep the main script under the size guideline.

const NPC_SCENE: PackedScene = preload("res://scenes/entities/npc.tscn")

var in_auto_walk: bool = false

var _exploration: Exploration
var _auto_walk_tween: Tween = null
var _arrival_tween: Tween = null
var _caden_dialogue_callable: Callable = Callable()


func _init(exploration: Exploration) -> void:
	_exploration = exploration


func start_auto_walk() -> void:
	var player: Node2D = _exploration.get_player()
	var current_map: Node2D = _exploration.get_current_map()
	if player == null or current_map == null:
		return
	in_auto_walk = true
	player.set_input_enabled(false)
	var transitions: Node = current_map.get_node_or_null("Transitions")
	if transitions == null:
		in_auto_walk = false
		player.set_input_enabled(true)
		return
	var target_pos: Vector2 = player.position
	for child: Node in transitions.get_children():
		if child is Area2D:
			target_pos = child.position
			break
	var direction: Vector2 = (target_pos - player.position).normalized()
	if absf(direction.x) > absf(direction.y):
		player.play_animation("walk_east" if direction.x > 0 else "walk_west")
	else:
		player.play_animation("walk_south" if direction.y > 0 else "walk_north")
	var distance: float = player.position.distance_to(target_pos)
	var duration: float = distance / 80.0
	if _auto_walk_tween != null and _auto_walk_tween.is_valid():
		_auto_walk_tween.kill()
	_auto_walk_tween = _exploration.create_tween()
	_auto_walk_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_auto_walk_tween.tween_property(player, "position", target_pos, duration)
	_auto_walk_tween.tween_callback(end_auto_walk)


func end_auto_walk() -> void:
	in_auto_walk = false
	var player: Node2D = _exploration.get_player()
	if player != null:
		player.position = player.position.round()
		if not _exploration.is_in_cutscene():
			player.set_input_enabled(true)


func kill_auto_walk_tween() -> void:
	if _auto_walk_tween != null and _auto_walk_tween.is_valid():
		_auto_walk_tween.kill()
		_auto_walk_tween = null
		in_auto_walk = false
		var player: Node2D = _exploration.get_player()
		if player != null:
			player.set_input_enabled(true)


func kill_arrival_tween() -> void:
	if _arrival_tween != null and _arrival_tween.is_valid():
		_arrival_tween.kill()
		_arrival_tween = null


func run_auto_sequence(sequence_id: String, completion_flag: String) -> void:
	match sequence_id:
		"caden_binding":
			_run_caden_binding(completion_flag)
		_:
			push_warning("ExplorationAutoSequence: Unknown auto_sequence '%s'" % sequence_id)


func _run_caden_binding(completion_flag: String) -> void:
	await _exploration.get_tree().create_timer(0.5).timeout
	if not _exploration.is_inside_tree():
		return
	var current_map: Node2D = _exploration.get_current_map()
	var spawn: Node2D = current_map.get_node_or_null("CadenSpawnPoint")
	var center: Vector2 = Vector2(128, 80)
	var start_pos: Vector2 = spawn.position if spawn != null else Vector2(288, 80)
	var caden: Node2D = NPC_SCENE.instantiate()
	var entities: Node = current_map.get_node_or_null("Entities")
	if entities != null:
		entities.add_child(caden)
	else:
		current_map.add_child(caden)
	caden.position = start_pos
	caden.modulate.a = 0.0
	caden.initialize("caden_duskfen")
	if _arrival_tween != null and _arrival_tween.is_valid():
		_arrival_tween.kill()
	_arrival_tween = _exploration.create_tween()
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
		_caden_dialogue_callable = _on_caden_dialogue_closed.bind(caden, completion_flag)
		GameManager.overlay_state_changed.connect(_caden_dialogue_callable, CONNECT_ONE_SHOT)
	else:
		_caden_complete(caden, completion_flag)


func _on_caden_dialogue_closed(
	state: GameManager.OverlayState, caden: Node2D, completion_flag: String
) -> void:
	if state != GameManager.OverlayState.NONE:
		_caden_dialogue_callable = _on_caden_dialogue_closed.bind(caden, completion_flag)
		GameManager.overlay_state_changed.connect(_caden_dialogue_callable, CONNECT_ONE_SHOT)
		return
	_caden_dialogue_callable = Callable()
	_caden_complete(caden, completion_flag)


func _caden_complete(caden: Node2D, completion_flag: String) -> void:
	PartyState.add_key_item("fenmothers_blessing")
	_exploration.flash_location_name("Received Fenmother's Blessing!")
	EventFlags.set_flag(completion_flag, true)
	EventFlags.set_flag("duskfen_alliance", true)
	caden.queue_free()
	var current_map: Node2D = _exploration.get_current_map()
	var post_npc: Node = current_map.get_node_or_null("Entities/CadenPostEvent")
	if post_npc != null:
		post_npc.visible = true


func disconnect_pending_signals() -> void:
	if _caden_dialogue_callable.is_valid():
		if GameManager.overlay_state_changed.is_connected(_caden_dialogue_callable):
			GameManager.overlay_state_changed.disconnect(_caden_dialogue_callable)
		_caden_dialogue_callable = Callable()
