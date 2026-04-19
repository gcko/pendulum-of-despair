class_name CutsceneHandler
extends RefCounted
## Handles cutscene overlay integration for exploration mode.
## Manages cutscene triggers, choreography signal routing, and return transitions.
## Extracted from exploration.gd to keep the main script focused on map/entity logic.

var _exploration: Exploration
var _cutscene_camera_tween: Tween = null
var _cutscene_shake_tween: Tween = null
var _cutscene_active: bool = false


func _init(exploration: Exploration) -> void:
	_exploration = exploration


## Returns whether a cutscene is currently active in this handler.
func is_cutscene_active() -> bool:
	return _cutscene_active


func on_overlay_state_changed(new_state: GameManager.OverlayState) -> void:
	if new_state == GameManager.OverlayState.CUTSCENE:
		_cutscene_active = true
		_exploration.set_in_cutscene(true)
		var player: Node2D = _exploration.get_player()
		if player != null:
			player.set_input_enabled(false)
		_connect_cutscene_signals()
	elif new_state == GameManager.OverlayState.NONE and _cutscene_active:
		_on_cutscene_finished()


func _connect_cutscene_signals() -> void:
	var cs: Node = GameManager.overlay_node
	if cs == null:
		push_error("CutsceneHandler: overlay_node is null when CUTSCENE state fired")
		return
	_safe_connect(cs, "cutscene_move_requested", _on_cutscene_move)
	_safe_connect(cs, "cutscene_anim_requested", _on_cutscene_anim)
	_safe_connect(cs, "cutscene_camera_requested", _on_cutscene_camera)
	_safe_connect(cs, "cutscene_shake_requested", _on_cutscene_shake)
	_safe_connect(cs, "cutscene_music_requested", _on_cutscene_music)
	_safe_connect(cs, "flag_set_requested", _on_cutscene_flag_set)
	_safe_connect(cs, "sfx_requested", _on_cutscene_sfx)


func _safe_connect(src: Node, sig: StringName, handler: Callable) -> void:
	if src.has_signal(sig) and not src.is_connected(sig, handler):
		src.connect(sig, handler)


func _on_cutscene_move(who: String, target: Vector2, speed: float) -> void:
	var entity: Node = _exploration.get_entities().get(who, null)
	if entity == null:
		if OS.is_debug_build():
			push_warning("Cutscene: entity not found: %s" % who)
		return
	if entity.has_method("walk_to"):
		entity.walk_to(target, speed)


func _on_cutscene_anim(who: String, anim: String) -> void:
	var entity: Node = _exploration.get_entities().get(who, null)
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
	var camera: Camera2D = _exploration.get_camera()
	if camera == null:
		return
	if _cutscene_camera_tween != null and _cutscene_camera_tween.is_valid():
		_cutscene_camera_tween.kill()
	_cutscene_camera_tween = _exploration.create_tween()
	_cutscene_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_cutscene_camera_tween.tween_property(camera, "position", target, duration)


func _on_cutscene_shake(intensity: int, duration: float) -> void:
	var camera: Camera2D = _exploration.get_camera()
	if camera == null:
		return
	if _cutscene_shake_tween != null and _cutscene_shake_tween.is_valid():
		_cutscene_shake_tween.kill()
	_cutscene_shake_tween = _exploration.create_tween()
	_cutscene_shake_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var step_duration: float = 0.05
	var steps: int = maxi(int(duration / step_duration) - 1, 0)
	for i: int in range(steps):
		var offset: Vector2 = Vector2(
			float(randi_range(-intensity, intensity)), float(randi_range(-intensity, intensity))
		)
		_cutscene_shake_tween.tween_property(camera, "offset", offset, step_duration)
	var reset_duration: float = maxf(0.001, duration - (float(steps) * step_duration))
	_cutscene_shake_tween.tween_property(camera, "offset", Vector2.ZERO, reset_duration)


func _on_cutscene_finished() -> void:
	# Clear handler-level flag immediately to prevent double-fire if another
	# overlay pops before the deferred set_in_cutscene(false) runs.
	_cutscene_active = false
	if not is_instance_valid(_exploration):
		return
	# Defer clearing _in_cutscene so it stays true for one frame after unpause.
	# pop_overlay emits overlay_state_changed(NONE) then unpauses the tree.
	# Without deferral, pending Area2D overlaps from cutscene move commands
	# would fire immediately on unpause and pass the _in_cutscene guard.
	# Use a lambda to re-check _cutscene_active — a back-to-back cutscene
	# may have set it to true again before this deferred call runs.
	_exploration.call_deferred("_deferred_clear_cutscene_flag", self)
	if _cutscene_camera_tween != null and _cutscene_camera_tween.is_valid():
		_cutscene_camera_tween.kill()
	_cutscene_camera_tween = null
	if _cutscene_shake_tween != null and _cutscene_shake_tween.is_valid():
		_cutscene_shake_tween.kill()
	_cutscene_shake_tween = null
	# Kill any in-flight entity walk tweens from cutscene move commands
	# Snap positions to pixel after cancelling to prevent sub-pixel drift
	for entity: Node in _exploration.get_entities().values():
		if is_instance_valid(entity) and entity.has_method("cancel_walk"):
			entity.cancel_walk()
			if entity is Node2D:
				(entity as Node2D).position = (entity as Node2D).position.round()
	var player: Node2D = _exploration.get_player()
	if player != null and is_instance_valid(player) and player.has_method("cancel_walk"):
		player.cancel_walk()
		player.position = player.position.round()
	var camera: Camera2D = _exploration.get_camera()
	if camera != null and player != null:
		camera.position = player.position.round()
		camera.offset = Vector2.ZERO
	var ret: Dictionary = _exploration.get_cutscene_return()
	if not ret.is_empty():
		_exploration.set_cutscene_return({})
		var ret_map: String = ret.get("map", "")
		var ret_spawn: String = ret.get("spawn", "PlayerSpawn")
		if ret_map != "":
			# Cover screen before transition to prevent void flash from
			# cutscene map player position
			var fade: ColorRect = _exploration.get_fade_rect()
			if fade != null:
				fade.visible = true
				fade.color = Color(0, 0, 0, 1)
			_exploration.transition_to_map(ret_map, ret_spawn)
			return
	if (
		player != null
		and not _exploration.is_in_auto_walk()
		and not _exploration.is_transitioning()
		and GameManager.current_overlay == GameManager.OverlayState.NONE
	):
		player.set_input_enabled(true)


func _on_cutscene_flag_set(flag_name: String, value: Variant) -> void:
	if flag_name.is_empty():
		if OS.is_debug_build():
			push_warning("Cutscene: flag_set_requested with empty flag_name")
		return
	EventFlags.set_flag(flag_name, value)


func _on_cutscene_music(_track_id: String, _action: String) -> void:
	# Stub — AudioManager integration in gap 3.8
	pass


func _on_cutscene_sfx(_sfx_id: String) -> void:
	# Stub — AudioManager integration in gap 3.8
	pass


func start_pending_cutscene(cutscene_id: String, entries: Array[Dictionary], tier: int) -> void:
	if not GameManager.push_overlay(GameManager.OverlayState.CUTSCENE):
		push_error("CutsceneHandler: Failed to push CUTSCENE overlay for '%s'" % cutscene_id)
		var ret: Dictionary = _exploration.get_cutscene_return()
		_exploration.set_cutscene_return({})
		var ret_map: String = ret.get("map", "")
		if ret_map != "":
			_exploration.transition_to_map(ret_map, ret.get("spawn", "PlayerSpawn"))
			return
		return
	GameManager.overlay_node.start_cutscene(cutscene_id, entries, tier)


func on_cutscene_trigger_entered(body: Node2D, area: Area2D) -> void:
	var player: Node2D = _exploration.get_player()
	var blocked: bool = (
		body != player
		or _exploration.is_transitioning()
		or _exploration.is_in_auto_walk()
		or _exploration.is_in_cutscene()
	)
	if blocked:
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
	var return_spawn: String = area.get_meta("cutscene_return_spawn", "PlayerSpawn")
	# Load cutscene data from dialogue JSON
	var scene_data: Dictionary = DataManager.load_dialogue(scene_id)
	if scene_data.is_empty():
		push_error("CutsceneHandler: Failed to load cutscene dialogue '%s'" % scene_id)
		return
	var entries: Array[Dictionary] = []
	for e: Variant in scene_data.get("entries", []):
		if e is Dictionary:
			entries.append(e as Dictionary)
	var cutscene_id: String = scene_data.get("cutscene_id", scene_id)
	var tier: int = scene_data.get("cutscene_tier", 1)
	if entries.is_empty():
		push_error("CutsceneHandler: Cutscene '%s' has no entries" % scene_id)
		return
	# Store return info only when a return map is specified
	if return_map != "":
		_exploration.set_cutscene_return({"map": return_map, "spawn": return_spawn})
	# Set one-shot flag now so re-entry is blocked even during transition
	if not flag.is_empty():
		EventFlags.set_flag(flag, true)
	if map_id != "":
		# Transition to cutscene map, then start cutscene after load
		_exploration.set_pending_cutscene({"id": cutscene_id, "entries": entries, "tier": tier})
		_exploration.transition_to_map(map_id, "PlayerSpawn")
	else:
		# Start cutscene on current map
		start_pending_cutscene(cutscene_id, entries, tier)
