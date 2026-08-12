class_name CutsceneCommands
extends RefCounted
## The visual and choreography commands a cutscene entry can carry: fades,
## flashes, title cards, camera moves, actor moves, shakes and music cues.
##
## Extracted from cutscene_player.gd (GAP-087), which keeps the sequencer — the
## order entries run in and when a command blocks. Commands that animate return
## the Tween's `finished` signal for the sequencer to await; the rest return
## null and resolve immediately.

var _player: CutscenePlayer
var _fade_tween: Tween = null
var _flash_tween: Tween = null
var _title_tween: Tween = null


func _init(player: CutscenePlayer) -> void:
	_player = player


## Run one command. Returns a Signal when the caller must wait for it to
## finish, or null when it resolves immediately.
func execute(cmd: Dictionary) -> Variant:
	var cmd_type: String = cmd.get("type", "")
	match cmd_type:
		"fade":
			return _fade(cmd)
		"move":
			_move(cmd)
			return null
		"camera":
			_camera(cmd)
			return null
		"shake":
			_shake(cmd)
			return null
		"flash":
			return _flash(cmd)
		"title":
			return _title(cmd)
		"music":
			_music(cmd)
			return null
		"hide_dialogue":
			_set_dialogue_visible(false)
			return null
		"show_dialogue":
			_set_dialogue_visible(true)
			return null
		_:
			if OS.is_debug_build():
				push_warning("Unknown cutscene command: %s" % cmd_type)
			return null


## Stop every animation this module started and forget the tweens.
func kill_tweens() -> void:
	for tween: Tween in [_fade_tween, _flash_tween, _title_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
	_fade_tween = null
	_flash_tween = null
	_title_tween = null


func _fade(cmd: Dictionary) -> Variant:
	var fade_rect: ColorRect = _player.get_fade_rect()
	if fade_rect == null:
		return null
	var direction: String = cmd.get("direction", "out")
	var duration: float = cmd.get("duration", 0.5)
	fade_rect.color = _fade_color(str(cmd.get("color", "black")))
	var target_alpha: float = 1.0 if direction == "out" else 0.0
	# Headless mode: set directly, no tween (avoids rp_target null error).
	if _is_headless():
		fade_rect.modulate.a = target_alpha
		return null
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = _new_tween()
	_fade_tween.tween_property(fade_rect, "modulate:a", target_alpha, duration)
	return _fade_tween.finished


func _flash(cmd: Dictionary) -> Variant:
	var flash_intensity: String = str(_player.get_config().get("flash_intensity", "full"))
	if flash_intensity == "off":
		return null
	var fade_rect: ColorRect = _player.get_fade_rect()
	if fade_rect == null:
		return null
	var duration: float = cmd.get("duration", 0.3)
	if flash_intensity == "reduced":
		duration = duration * 0.5
	# Only "red" is special here; anything else flashes white.
	fade_rect.color = Color.RED if str(cmd.get("color", "white")) == "red" else Color.WHITE
	if _is_headless():
		fade_rect.modulate.a = 0.0
		return null
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = _new_tween()
	_flash_tween.tween_property(fade_rect, "modulate:a", 0.8, duration * 0.3)
	_flash_tween.tween_property(fade_rect, "modulate:a", 0.0, duration * 0.7)
	return _flash_tween.finished


func _title(cmd: Dictionary) -> Variant:
	var title_label: Label = _player.get_title_label()
	if title_label == null:
		return null
	title_label.text = cmd.get("text", "")
	if _is_headless():
		title_label.modulate.a = 0.0
		return null
	var duration: float = cmd.get("duration", 2.0)
	var fade_in: float = cmd.get("fade_in", 0.5)
	var fade_out: float = cmd.get("fade_out", 0.5)
	if _title_tween != null and _title_tween.is_valid():
		_title_tween.kill()
	_title_tween = _new_tween()
	_title_tween.tween_property(title_label, "modulate:a", 1.0, fade_in)
	_title_tween.tween_interval(duration)
	_title_tween.tween_property(title_label, "modulate:a", 0.0, fade_out)
	return _title_tween.finished


func _move(cmd: Dictionary) -> void:
	var who: String = cmd.get("who", "")
	var to: Array = cmd.get("to", [0, 0])
	var speed: float = cmd.get("speed", 80.0)
	if who != "" and to.size() >= 2:
		_player.cutscene_move_requested.emit(who, Vector2(to[0], to[1]), speed)


func _camera(cmd: Dictionary) -> void:
	var target: Array = cmd.get("target", [0, 0])
	var duration: float = cmd.get("duration", 1.0)
	if target.size() >= 2:
		_player.cutscene_camera_requested.emit(Vector2(target[0], target[1]), duration)


func _shake(cmd: Dictionary) -> void:
	if bool(_player.get_config().get("reduce_motion", false)):
		return
	var intensity: int = cmd.get("intensity", 2)
	var duration: float = cmd.get("duration", 0.3)
	_player.cutscene_shake_requested.emit(intensity, duration)


func _music(cmd: Dictionary) -> void:
	var track_id: String = cmd.get("track_id", "")
	var action: String = cmd.get("action", "play")
	_player.cutscene_music_requested.emit(track_id, action)


func _set_dialogue_visible(value: bool) -> void:
	var box: DialogueBox = _player.get_dialogue_box()
	if box != null:
		box.visible = value


## A tween that keeps running while the tree is paused — cutscenes play over a
## paused game.
func _new_tween() -> Tween:
	var tween: Tween = _player.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween


## Fade colors: white and red are named, everything else fades to black.
func _fade_color(name: String) -> Color:
	match name:
		"white":
			return Color.WHITE
		"red":
			return Color.RED
		_:
			return Color.BLACK


func _is_headless() -> bool:
	return DisplayServer.window_get_size() == Vector2i.ZERO
