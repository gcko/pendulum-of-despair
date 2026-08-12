class_name CutscenePlayer

extends CanvasLayer

## Cutscene sequencer overlay. Processes entries in order: run before-commands,
## show dialogue via embedded dialogue_box, run after-commands.
## Attached to the root CanvasLayer of cutscene.tscn.
##
## The commands an entry can carry — fades, flashes, title cards, camera and
## actor moves, shakes, music cues — live in CutsceneCommands
## (`scripts/core/cutscene_commands.gd`, GAP-087). This file keeps the
## sequencer: what order entries run in and which commands block.
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
signal score_increment_requested(score_name: String, delta: int)
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

## Scene-local pseudo-flags (`choice_N_selected`) for the most recent choice.
## Entries are fed to the embedded dialogue box one at a time, so the choice
## made inside it has to be remembered here to gate the reaction entries that
## follow. Reset on every start_cutscene; never saved.
var _choice_context: Dictionary = {}
var _commands: CutsceneCommands = null

@onready var _dialogue_box: DialogueBox = $DialogueBox
@onready var _fade_rect: ColorRect = $FadeRect
@onready var _title_label: Label = $TitleLabel
@onready var _letterbox: CutsceneLetterbox = $Letterbox


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
		if _dialogue_box.has_signal("score_increment_requested"):
			_dialogue_box.score_increment_requested.connect(
				func(s: String, d: int): score_increment_requested.emit(s, d)
			)
		if _dialogue_box.has_signal("choice_made"):
			_dialogue_box.choice_made.connect(_on_dialogue_choice_made)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_playing:
		return
	if event.is_action_pressed("ui_cancel"):
		_consume_input()
		skip_cutscene()
		return


## Start a cutscene sequence. Internally async but does not need to be awaited by caller.
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
	_choice_context = {}

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
		if not is_inside_tree():
			return

	# Process entries
	await _process_entries()
	if not is_inside_tree():
		return

	# If skip_cutscene() already handled cleanup, bail out
	if _skipped:
		return

	# Letterbox out for T1
	if _tier == TIER_FULL and _letterbox != null and _letterbox.top_bar != null:
		_letterbox.animate_out(0.5)
		await _letterbox.letterbox_out_complete
		if not is_inside_tree():
			return

	# Set skip flag
	EventFlags.set_flag(skip_flag, true)

	_is_playing = false
	cutscene_finished.emit()
	GameManager.pop_overlay()


## Skip to end. Sets all remaining flags. For debug/accessibility.
func skip_cutscene() -> void:
	if not _is_playing:
		return

	# Set skipped early so any running coroutines bail out
	_is_playing = false
	_skipped = true

	# Emit remaining flags — entries whose condition is false never would have
	# played, so skipping must not set their flags either.
	for i: int in range(_current_index, _entries.size()):
		var entry: Dictionary = _entries[i]
		if not DialogueCondition.should_play(entry, _choice_context):
			continue
		var flag_val: Variant = entry.get("flag_set", "")
		var flag: String = flag_val if flag_val is String else ""
		if flag != "":
			flag_set_requested.emit(flag, true)

	# Close dialogue if open (emits dialogue_finished to unstick awaits)
	if _dialogue_box != null:
		_dialogue_box.close()

	# Kill all active tweens
	_get_commands().kill_tweens()

	# Reset visual state
	if _fade_rect != null:
		_fade_rect.modulate.a = 0.0
	if _title_label != null:
		_title_label.modulate.a = 0.0
	if _tier == TIER_FULL and _letterbox != null:
		_letterbox.set_instant(false)

	# Mark as seen and clean up
	var skip_flag: String = "cutscene_seen_%s" % _cutscene_id
	EventFlags.set_flag(skip_flag, true)
	_entries.clear()
	cutscene_finished.emit()
	GameManager.pop_overlay()


func _consume_input() -> void:
	InputUtil.consume(self)


func _load_config() -> void:
	# Read the player's live config (defaults merged with saved settings) so
	# accessibility options (text speed, reduce-motion, etc.) apply in cutscenes.
	var data: Variant = PartyState.get_config()
	if data is Dictionary:
		_config = data


## Process all entries in sequence. ASYNC: must be awaited.
func _process_entries() -> void:
	while _current_index < _entries.size() and _is_playing:
		var entry: Dictionary = _entries[_current_index]

		# Honor the per-entry condition (dialogue-system.md 3.2/3.5).
		if not DialogueCondition.should_play(entry, _choice_context):
			_current_index += 1
			continue

		# Run "before" commands
		await _run_commands(entry, "before")
		if _skipped or not _is_playing:
			return

		# Process "before_line" animations from entry
		_fire_entry_animations(entry, "before_line")

		# Show dialogue if entry has lines
		var lines: Array = entry.get("lines", [])
		if lines.size() > 0 and _dialogue_box != null:
			_dialogue_box.visible = true
			# Hand over this cutscene's choice context. The box re-resolves the
			# entry's condition, and against an empty context a reaction gated
			# on `choice_N_selected` would be dropped and the box would finish
			# synchronously — before the await below could attach.
			_dialogue_box.show_dialogue([entry], _choice_context)
			if _dialogue_box.is_showing():
				await _dialogue_box.dialogue_finished
			if _skipped or not _is_playing:
				return

		# Process "after_line" animations from entry
		_fire_entry_animations(entry, "after_line")

		# Run "after" commands
		await _run_commands(entry, "after")
		if _skipped or not _is_playing:
			return

		# Emit flag_set if present (guard against JSON null values)
		var flag_val: Variant = entry.get("flag_set", "")
		var flag: String = flag_val if flag_val is String else ""
		if flag != "":
			flag_set_requested.emit(flag, true)

		_current_index += 1


## Remember which option the player picked so the reaction entries that follow
## (condition: `choice_N_selected`) resolve against this cutscene's own choice.
func _on_dialogue_choice_made(choice_index: int) -> void:
	_choice_context = DialogueCondition.choice_context(choice_index)


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


## Run commands for an entry (before/after). ASYNC: must be awaited.
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
				if _skipped or not _is_playing or not is_inside_tree():
					return
		else:
			var blocking_tasks: Array[Signal] = []
			for cmd: Dictionary in group:
				var result: Variant = _get_commands().execute(cmd)
				if result is Signal:
					blocking_tasks.append(result)
			for sig: Signal in blocking_tasks:
				await sig
				if _skipped or not _is_playing or not is_inside_tree():
					return


# ---------- Accessors for CutsceneCommands ----------


func get_fade_rect() -> ColorRect:
	return _fade_rect


func get_title_label() -> Label:
	return _title_label


func get_dialogue_box() -> DialogueBox:
	return _dialogue_box


## The player's live config, so accessibility options (reduce motion, flash
## intensity) reach the commands that honor them.
func get_config() -> Dictionary:
	return _config


func _get_commands() -> CutsceneCommands:
	if _commands == null:
		_commands = CutsceneCommands.new(self)
	return _commands
