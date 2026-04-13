extends CanvasLayer
## Cutscene sequencer overlay. Processes entries in order: run before-commands,
## show dialogue via embedded dialogue_box, run after-commands.
## Attached to the root CanvasLayer of cutscene.tscn.
##
## Usage: GameManager.push_overlay(CUTSCENE), then call
## start_cutscene(id, entries, tier) on GameManager.overlay_node.

# --- Choreography signals (exploration.gd connects to these) ---
signal cutscene_move_requested(who: String, target: Vector2, speed: float)
signal cutscene_anim_requested(who: String, anim: String)
signal cutscene_camera_requested(target: Vector2, duration: float)
signal cutscene_shake_requested(intensity: int, duration: float)
signal cutscene_music_requested(track_id: String, action: String)
signal cutscene_finished
signal flag_set_requested(flag_name: String, value: Variant)
signal sfx_requested(sfx_id: String)

## Tier constants.
const TIER_FULL: int = 1
const TIER_MICRO: int = 4

var _cutscene_id: String = ""
var _entries: Array[Dictionary] = []
var _current_index: int = 0
var _tier: int = TIER_FULL
var _is_playing: bool = false
var _config: Dictionary = {}
var _skipped: bool = false
var _fade_tween: Tween = null
var _flash_tween: Tween = null
var _title_tween: Tween = null

@onready var _dialogue_box: Node = $DialogueBox
@onready var _fade_rect: ColorRect = $FadeRect
@onready var _title_label: Label = $TitleLabel
@onready var _letterbox: Node = $Letterbox


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_config()
	# Forward dialogue_box signals through cutscene_player
	if _dialogue_box != null:
		_dialogue_box.embedded_mode = true
		if _dialogue_box.has_signal("animation_requested"):
			_dialogue_box.animation_requested.connect(
				func(who: String, anim: String): cutscene_anim_requested.emit(who, anim)
			)
		if _dialogue_box.has_signal("sfx_requested"):
			_dialogue_box.sfx_requested.connect(func(sfx_id: String): sfx_requested.emit(sfx_id))
		if _dialogue_box.has_signal("flag_set_requested"):
			_dialogue_box.flag_set_requested.connect(
				func(f: String, v: Variant): flag_set_requested.emit(f, v)
			)


## Start a cutscene sequence.
func start_cutscene(cutscene_id: String, entries: Array, tier: int = TIER_FULL) -> void:
	if _is_playing:
		if OS.is_debug_build():
			push_warning("Cutscene already playing: %s" % _cutscene_id)
		return
	if cutscene_id == "":
		push_error("CutscenePlayer: empty cutscene_id")
		cutscene_finished.emit()
		GameManager.pop_overlay()
		return
	_cutscene_id = cutscene_id
	_entries.assign(entries)
	_tier = tier
	_current_index = 0
	_is_playing = true
	_skipped = false

	# Check skip flag
	var skip_flag: String = "cutscene_seen_%s" % cutscene_id
	if EventFlags.get_flag(skip_flag):
		_is_playing = false
		cutscene_finished.emit()
		GameManager.pop_overlay()
		return

	# Letterbox in for T1 (skip if the letterbox node or its bar references are unavailable)
	if _tier == TIER_FULL and _letterbox != null and _letterbox.top_bar != null:
		_letterbox.animate_in(0.5)
		await _letterbox.letterbox_in_complete

	# Process entries
	await _process_entries()

	# If skip_cutscene() already handled cleanup, bail out
	if _skipped:
		return

	# Letterbox out for T1
	if _tier == TIER_FULL and _letterbox != null and _letterbox.top_bar != null:
		_letterbox.animate_out(0.5)
		await _letterbox.letterbox_out_complete

	# Set skip flag
	EventFlags.set_flag(skip_flag, true)

	_is_playing = false
	cutscene_finished.emit()
	GameManager.pop_overlay()


## Skip to end. Sets all remaining flags. For debug/accessibility.
func skip_cutscene() -> void:
	if not _is_playing:
		return
	for i in range(_current_index, _entries.size()):
		var entry: Dictionary = _entries[i]
		var flag: String = entry.get("flag_set", "")
		if flag != "":
			EventFlags.set_flag(flag, true)
			flag_set_requested.emit(flag, true)
	_kill_visual_tweens()
	if _fade_rect != null:
		_fade_rect.modulate.a = 0.0
	if _title_label != null:
		_title_label.modulate.a = 0.0
	if _tier == TIER_FULL and _letterbox != null:
		_letterbox.set_instant(false)
	var skip_flag: String = "cutscene_seen_%s" % _cutscene_id
	EventFlags.set_flag(skip_flag, true)
	_entries.clear()
	_is_playing = false
	_skipped = true
	cutscene_finished.emit()
	GameManager.pop_overlay()


func _load_config() -> void:
	var data: Variant = DataManager.load_json("res://data/config/defaults.json")
	if data is Dictionary:
		_config = data


func _process_entries() -> void:
	while _current_index < _entries.size() and _is_playing:
		var entry: Dictionary = _entries[_current_index]

		# Run "before" commands
		await _run_commands(entry, "before")

		# Process "before_line" animations from entry
		_fire_entry_animations(entry, "before_line")

		# Show dialogue if entry has lines
		var lines: Array = entry.get("lines", [])
		if lines.size() > 0 and _dialogue_box != null:
			_dialogue_box.visible = true
			_dialogue_box.show_dialogue([entry])
			await _dialogue_box.dialogue_finished

		# Process "after_line" animations from entry
		_fire_entry_animations(entry, "after_line")

		# Run "after" commands
		await _run_commands(entry, "after")

		# Emit flag_set if present
		var flag: String = entry.get("flag_set", "")
		if flag != "":
			flag_set_requested.emit(flag, true)

		_current_index += 1


func _fire_entry_animations(entry: Dictionary, prefix: String) -> void:
	var anims: Variant = entry.get("animations", null)
	if anims == null or not (anims is Array):
		return
	for anim_data: Variant in anims:
		if not (anim_data is Dictionary):
			continue
		var when: String = anim_data.get("when", "")
		if when.begins_with(prefix):
			var who: String = anim_data.get("who", "")
			var anim: String = anim_data.get("anim", "")
			if who != "" and anim != "":
				cutscene_anim_requested.emit(who, anim)


func _run_commands(entry: Dictionary, when_filter: String) -> void:
	var commands: Variant = entry.get("commands", null)
	if commands == null or not (commands is Array):
		return

	var parallel_cmds: Array[Dictionary] = []
	var ordered_groups: Array[Array] = []

	for cmd: Variant in commands:
		if not (cmd is Dictionary):
			continue
		var when: String = cmd.get("when", "")
		if when != when_filter:
			continue
		var cmd_type: String = cmd.get("type", "")
		if cmd_type == "wait":
			if parallel_cmds.size() > 0:
				ordered_groups.append(parallel_cmds)
				parallel_cmds = []
			ordered_groups.append([cmd])
		else:
			parallel_cmds.append(cmd)

	if parallel_cmds.size() > 0:
		ordered_groups.append(parallel_cmds)

	for group: Array in ordered_groups:
		if group.size() == 1 and group[0].get("type", "") == "wait":
			var duration: float = group[0].get("duration", 0.0)
			if duration > 0.0:
				await get_tree().create_timer(duration).timeout
		else:
			var blocking_tasks: Array[Signal] = []
			for cmd: Dictionary in group:
				var result: Variant = _execute_command(cmd)
				if result is Signal:
					blocking_tasks.append(result)
			for sig: Signal in blocking_tasks:
				await sig


func _execute_command(cmd: Dictionary) -> Variant:
	var cmd_type: String = cmd.get("type", "")
	match cmd_type:
		"fade":
			return _cmd_fade(cmd)
		"move":
			_cmd_move(cmd)
			return null
		"camera":
			_cmd_camera(cmd)
			return null
		"shake":
			_cmd_shake(cmd)
			return null
		"flash":
			return _cmd_flash(cmd)
		"title":
			return _cmd_title(cmd)
		"music":
			_cmd_music(cmd)
			return null
		"hide_dialogue":
			if _dialogue_box != null:
				_dialogue_box.visible = false
			return null
		"show_dialogue":
			if _dialogue_box != null:
				_dialogue_box.visible = true
			return null
		_:
			if OS.is_debug_build():
				push_warning("Unknown cutscene command: %s" % cmd_type)
			return null


func _cmd_fade(cmd: Dictionary) -> Variant:
	var direction: String = cmd.get("direction", "out")
	var duration: float = cmd.get("duration", 0.5)
	var color_name: String = cmd.get("color", "black")
	if _fade_rect == null:
		return null
	match color_name:
		"white":
			_fade_rect.color = Color.WHITE
		"red":
			_fade_rect.color = Color.RED
		_:
			_fade_rect.color = Color.BLACK
	var target_alpha: float = 1.0 if direction == "out" else 0.0
	# Headless mode: set directly, no tween (avoids rp_target null error).
	if _is_headless():
		_fade_rect.modulate.a = target_alpha
		return null
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(_fade_rect, "modulate:a", target_alpha, duration)
	return _fade_tween.finished


func _cmd_move(cmd: Dictionary) -> void:
	var who: String = cmd.get("who", "")
	var to: Array = cmd.get("to", [0, 0])
	var speed: float = cmd.get("speed", 80.0)
	if who != "" and to.size() >= 2:
		cutscene_move_requested.emit(who, Vector2(to[0], to[1]), speed)


func _cmd_camera(cmd: Dictionary) -> void:
	var target: Array = cmd.get("target", [0, 0])
	var duration: float = cmd.get("duration", 1.0)
	if target.size() >= 2:
		cutscene_camera_requested.emit(Vector2(target[0], target[1]), duration)


func _cmd_shake(cmd: Dictionary) -> void:
	var reduce_motion: bool = bool(_config.get("reduce_motion", false))
	if reduce_motion:
		return
	var intensity: int = cmd.get("intensity", 2)
	var duration: float = cmd.get("duration", 0.3)
	cutscene_shake_requested.emit(intensity, duration)


func _cmd_flash(cmd: Dictionary) -> Variant:
	var flash_intensity: String = str(_config.get("flash_intensity", "full"))
	if flash_intensity == "off":
		return null
	if _fade_rect == null:
		return null
	var color_name: String = cmd.get("color", "white")
	var duration: float = cmd.get("duration", 0.3)
	if flash_intensity == "reduced":
		duration = duration * 0.5
	match color_name:
		"red":
			_fade_rect.color = Color.RED
		_:
			_fade_rect.color = Color.WHITE
	if _is_headless():
		_fade_rect.modulate.a = 0.0
		return null
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_flash_tween.tween_property(_fade_rect, "modulate:a", 0.8, duration * 0.3)
	_flash_tween.tween_property(_fade_rect, "modulate:a", 0.0, duration * 0.7)
	return _flash_tween.finished


func _cmd_title(cmd: Dictionary) -> Variant:
	if _title_label == null:
		return null
	var text: String = cmd.get("text", "")
	var duration: float = cmd.get("duration", 2.0)
	var fade_in: float = cmd.get("fade_in", 0.5)
	var fade_out: float = cmd.get("fade_out", 0.5)
	_title_label.text = text
	if _is_headless():
		_title_label.modulate.a = 0.0
		return null
	if _title_tween != null and _title_tween.is_valid():
		_title_tween.kill()
	_title_tween = create_tween()
	_title_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_title_tween.tween_property(_title_label, "modulate:a", 1.0, fade_in)
	_title_tween.tween_interval(duration)
	_title_tween.tween_property(_title_label, "modulate:a", 0.0, fade_out)
	return _title_tween.finished


func _cmd_music(cmd: Dictionary) -> void:
	var track_id: String = cmd.get("track_id", "")
	var action: String = cmd.get("action", "play")
	cutscene_music_requested.emit(track_id, action)


func _kill_visual_tweens() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = null
	if _title_tween != null and _title_tween.is_valid():
		_title_tween.kill()
	_title_tween = null


func _is_headless() -> bool:
	return DisplayServer.window_get_size() == Vector2i.ZERO
