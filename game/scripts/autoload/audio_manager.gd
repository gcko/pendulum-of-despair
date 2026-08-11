extends Node
## Audio system: music, SFX, and ambient management.
## Autoloaded as AudioManager.
##
## Audio.md specifies a 24-channel design budget (8 music / 12 SFX / 4 ambient).
## Implementation uses 16 physical AudioStreamPlayers (2 music crossfade pair +
## 2 ambient crossfade pair + 12 SFX pool) with an 8-tier priority stack.
## See docs/story/audio.md for full rules.
## See docs/plans/technical-architecture.md Section 5.3.
##
## The rules behind the players live in `scripts/util/` — AudioCrossfade (fade
## curves and the music/ambient swap), AudioMixContext (duck/restore levels) and
## AudioSfxPolicy (priority and voice stealing), all extracted in GAP-087.

## Audio priority levels (per audio.md Section 3.2).
## Higher number = higher priority.
enum Priority {
	AMBIENT = 0,
	MUSIC = 1,
	EXPLORATION_SFX = 2,
	UI_SFX = 3,
	BATTLE_SFX = 4,
	BOSS_ONSET = 5,
	BATTLE_JINGLE = 6,
	CUTSCENE_SFX = 7,
}

## Audio.md Section 3.1 budget: 8 music + 12 SFX + 4 ambient = 24 channels.
## Implementation uses 16 physical AudioStreamPlayers (2 music crossfade pair +
## 2 ambient crossfade pair + 12 SFX pool). The 24-channel budget is a design
## guideline for sound density, not a 1:1 player count.

## Crossfade durations in seconds (per audio.md Section 3.3).
## Fades run concurrently over the full duration (out + in), so CROSSFADE_BIOME
## produces a 3s transition — matching audio.md §3.3 and the exit_battle convention.
const CROSSFADE_BIOME: float = 3.0
const CROSSFADE_TOWN: float = 1.0
const CROSSFADE_BATTLE_EXIT: float = 1.0
# Pallor transition is a hard cut to silence with a drone fading in on the
# ambient channel (audio.md §3.3). These constants are reserved for the gap 4.5
# enter_pallor() transition; do NOT route them through play_music/play_ambient
# (those crossfade and would not honor the documented Pallor behavior).
const CROSSFADE_PALLOR_MUSIC: float = 5.0
const CROSSFADE_PALLOR_AMBIENT: float = 3.0

## Silence level in decibels (effectively muted). Owned by AudioCrossfade,
## which does the fading; re-exported here because the buses use it too.
const SILENT_DB: float = AudioCrossfade.SILENT_DB

## Number of SFX pool slots (matches audio.md Section 3.1 SFX budget).
const SFX_POOL_SIZE: int = AudioSfxPolicy.POOL_SIZE

# --- State: dedicated music/ambient players ---
var _music_active: AudioStreamPlayer = null
var _music_fade: AudioStreamPlayer = null
var _ambient_active: AudioStreamPlayer = null
var _ambient_fade: AudioStreamPlayer = null

# --- State: SFX pool ---
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_meta: Array[Dictionary] = []

# --- State: track IDs ---
var _current_music: String = ""
var _current_ambient: String = ""
var _current_mix_context: String = AudioMixContext.DEFAULT_CONTEXT

# --- State: pre-battle snapshot for exit_battle restoration ---
# _pre_battle_music/_pre_battle_ambient: stored for the caller to query when
# deciding what to pass to exit_battle(). _pre_battle_music_pos is consumed
# directly by _exit_battle_with_streams to resume playback position.
var _pre_battle_music: String = ""
var _pre_battle_ambient: String = ""
var _pre_battle_music_pos: float = 0.0
var _pre_battle_ambient_pos: float = 0.0
var _pre_battle_mix_context: String = AudioMixContext.DEFAULT_CONTEXT

# --- State: active tween tracking ---
var _music_active_tween: Tween = null
var _music_fade_tween: Tween = null
var _ambient_active_tween: Tween = null
var _ambient_fade_tween: Tween = null


func _ready() -> void:
	_ensure_audio_buses()
	_create_players()
	# Defer volume application: AudioManager loads before PartyState in the
	# autoload order (project.godot), so PartyState.get_config() is unavailable
	# during _ready(). Deferring runs it after all autoloads enter the tree.
	_apply_bus_volumes.call_deferred()


## Ensure Music, SFX, and Ambient buses exist (adds them if missing).
func _ensure_audio_buses() -> void:
	for bus_name: String in ["Music", "SFX", "Ambient"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx: int = AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")


## Create the 16 AudioStreamPlayer nodes: 2 music, 2 ambient, 12 SFX.
func _create_players() -> void:
	# Music players
	_music_active = _make_player("music_active", "Music")
	_music_fade = _make_player("music_fade", "Music")

	# Ambient players
	_ambient_active = _make_player("ambient_active", "Ambient")
	_ambient_fade = _make_player("ambient_fade", "Ambient")

	# SFX pool
	for i: int in range(SFX_POOL_SIZE):
		_sfx_pool.append(_make_player("sfx_%d" % i, "SFX"))
		_sfx_meta.append(AudioSfxPolicy.empty_meta(Priority.AMBIENT))


## Helper to create and register an AudioStreamPlayer child.
func _make_player(player_name: String, bus: String) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = player_name
	player.bus = bus
	player.volume_db = SILENT_DB
	add_child(player)
	return player


# ---------------------------------------------------------------------------
# Public API — music / SFX / ambient playback and mix-context control
# ---------------------------------------------------------------------------


## Play a music track with optional crossfade.
func play_music(track_id: String, crossfade_duration: float = CROSSFADE_BIOME) -> void:
	if track_id.is_empty():
		return
	if track_id == _current_music:
		return
	crossfade_duration = maxf(0.0, crossfade_duration)
	var path: String = "res://assets/music/%s.ogg" % track_id
	if not ResourceLoader.exists(path):
		if OS.is_debug_build():
			push_warning("AudioManager: Music file not found: %s" % path)
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_play_music_with_stream(stream, track_id, crossfade_duration)


## Internal: play a stream directly into the music players (used by tests and play_music).
func _play_music_with_stream(
	stream: AudioStream, track_id: String, crossfade_duration: float
) -> void:
	if stream == null or track_id == _current_music:
		return
	var pair: Dictionary = AudioCrossfade.swap_in(
		self,
		_music_active,
		_music_fade,
		_music_active_tween,
		_music_fade_tween,
		stream,
		crossfade_duration
	)
	_music_active = pair["active"]
	_music_fade = pair["fade"]
	_music_active_tween = pair["active_tween"]
	_music_fade_tween = pair["fade_tween"]
	_current_music = track_id
	if OS.is_debug_build():
		print("AudioManager: playing music '%s' (crossfade=%.2f)" % [track_id, crossfade_duration])


## Play a sound effect from the SFX pool.
## pan: stereo position (-1.0 left, 0.0 center, 1.0 right) per audio.md Section 3.4.
func play_sfx(sfx_id: String, priority: Priority = Priority.UI_SFX, pan: float = 0.0) -> void:
	if sfx_id.is_empty():
		return
	var path: String = "res://assets/sfx/%s.ogg" % sfx_id
	if not ResourceLoader.exists(path):
		if OS.is_debug_build():
			push_warning("AudioManager: SFX file not found: %s" % path)
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_play_sfx_with_stream(stream, sfx_id, priority, pan)


## Internal: play a stream directly into the SFX pool (used by tests and play_sfx).
func _play_sfx_with_stream(
	stream: AudioStream, sfx_id: String, priority: Priority, _pan: float = 0.0
) -> void:
	if stream == null:
		return
	if AudioSfxPolicy.at_same_id_limit(_sfx_pool, _sfx_meta, sfx_id):
		return
	var slot_idx: int = AudioSfxPolicy.find_free_slot(_sfx_pool)
	if slot_idx != -1:
		_sfx_meta[slot_idx] = AudioSfxPolicy.empty_meta(Priority.AMBIENT)
	else:
		slot_idx = AudioSfxPolicy.find_steal_target(_sfx_meta, int(priority), Priority.AMBIENT)
		if slot_idx == -1:
			return
		# Per audio.md Section 3.2: stolen channel gets 50ms fade-out to avoid clicks.
		# In practice AudioStreamPlayer stop is near-instant; a 50ms tween would delay
		# the new sound. We stop immediately — the 50ms fade is a hardware-era spec
		# that Godot's audio engine handles via its internal de-clicking.
		_sfx_pool[slot_idx].stop()
	# NOTE: pan parameter is accepted for API completeness (audio.md Section 3.4)
	# but AudioStreamPlayer has no built-in pan property. Stereo panning requires
	# migrating the SFX pool to AudioStreamPlayer2D (future gap).
	_sfx_pool[slot_idx].stream = stream
	_sfx_pool[slot_idx].volume_db = 0.0
	_sfx_pool[slot_idx].play()
	_sfx_meta[slot_idx] = {
		"sfx_id": sfx_id,
		"priority": priority,
		"start_time": Time.get_ticks_msec(),
	}


## Play an ambient loop with optional crossfade.
func play_ambient(ambient_id: String, crossfade_duration: float = CROSSFADE_BIOME) -> void:
	if ambient_id.is_empty():
		return
	if ambient_id == _current_ambient:
		return
	crossfade_duration = maxf(0.0, crossfade_duration)
	var path: String = "res://assets/ambient/%s.ogg" % ambient_id
	if not ResourceLoader.exists(path):
		if OS.is_debug_build():
			push_warning("AudioManager: Ambient file not found: %s" % path)
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_play_ambient_with_stream(stream, ambient_id, crossfade_duration)


## Internal: play a stream directly into the ambient players (used by tests and play_ambient).
func _play_ambient_with_stream(
	stream: AudioStream, ambient_id: String, crossfade_duration: float
) -> void:
	if stream == null or ambient_id == _current_ambient:
		return
	var pair: Dictionary = AudioCrossfade.swap_in(
		self,
		_ambient_active,
		_ambient_fade,
		_ambient_active_tween,
		_ambient_fade_tween,
		stream,
		crossfade_duration
	)
	_ambient_active = pair["active"]
	_ambient_fade = pair["fade"]
	_ambient_active_tween = pair["active_tween"]
	_ambient_fade_tween = pair["fade_tween"]
	_current_ambient = ambient_id
	if OS.is_debug_build():
		print(
			"AudioManager: playing ambient '%s' (crossfade=%.2f)" % [ambient_id, crossfade_duration]
		)


## Stop all music with an optional fade out.
func stop_music(fade_duration: float = CROSSFADE_TOWN) -> void:
	var pair: Dictionary = AudioCrossfade.fade_out(
		self,
		_music_active,
		_music_fade,
		_music_active_tween,
		_music_fade_tween,
		maxf(0.0, fade_duration)
	)
	_music_active_tween = pair["active_tween"]
	_music_fade_tween = pair["fade_tween"]
	_current_music = ""


## Stop all ambient with an optional fade out.
func stop_ambient(fade_duration: float = CROSSFADE_TOWN) -> void:
	var pair: Dictionary = AudioCrossfade.fade_out(
		self,
		_ambient_active,
		_ambient_fade,
		_ambient_active_tween,
		_ambient_fade_tween,
		maxf(0.0, fade_duration)
	)
	_ambient_active_tween = pair["active_tween"]
	_ambient_fade_tween = pair["fade_tween"]
	_current_ambient = ""


## Kill every in-flight music/ambient crossfade tween. The references are left
## in place — only silence_all nulls them.
func _kill_all_tweens() -> void:
	for tween: Tween in [
		_music_active_tween, _music_fade_tween, _ambient_active_tween, _ambient_fade_tween
	]:
		AudioCrossfade.kill(tween)


## Silence all audio immediately (for narrative silence moments).
func silence_all() -> void:
	# Kill all crossfade tweens and clear references
	_kill_all_tweens()
	_music_active_tween = null
	_music_fade_tween = null
	_ambient_active_tween = null
	_ambient_fade_tween = null
	AudioCrossfade.silence_pair(_music_active, _music_fade)
	AudioCrossfade.silence_pair(_ambient_active, _ambient_fade)
	# Stop all SFX pool players and reset their meta
	for i: int in range(SFX_POOL_SIZE):
		_sfx_pool[i].stop()
		_sfx_meta[i] = AudioSfxPolicy.empty_meta(Priority.AMBIENT)

	_current_music = ""
	_current_ambient = ""
	if OS.is_debug_build():
		print("AudioManager: silence_all()")


## Set the mixing context (changes music/ambient volume ratio).
func set_mix_context(context: String) -> void:
	if not AudioMixContext.has_context(context):
		push_warning("AudioManager: Unknown mix context: %s" % context)
		return
	_current_mix_context = context
	_apply_bus_volumes()
	if OS.is_debug_build():
		print("AudioManager: mix context set to '%s'" % context)


## Hard cut to battle music (no crossfade, ambient cuts to 0).
func enter_battle(battle_track: String) -> void:
	# Snapshot pre-battle state FIRST, before any failure path can return.
	# All paths (empty track, missing file, null stream, success) need the
	# snapshot stored so exit_battle can restore the exploration audio state.
	if _current_mix_context != "battle":
		_pre_battle_music = _current_music
		_pre_battle_ambient = _current_ambient
		_pre_battle_music_pos = (
			_music_active.get_playback_position() if _music_active.playing else 0.0
		)
		_pre_battle_ambient_pos = (
			_ambient_active.get_playback_position() if _ambient_active.playing else 0.0
		)
		_pre_battle_mix_context = _current_mix_context

	if battle_track.is_empty():
		if OS.is_debug_build():
			push_warning("AudioManager: enter_battle called with empty track ID")
		_silence_music_and_ambient_for_battle()
		set_mix_context("battle")
		return

	var path: String = "res://assets/music/%s.ogg" % battle_track
	if not ResourceLoader.exists(path):
		if OS.is_debug_build():
			push_warning("AudioManager: Battle music file not found: %s" % path)
		_silence_music_and_ambient_for_battle()
		set_mix_context("battle")
		return
	var stream: AudioStream = load(path)
	if stream == null:
		_silence_music_and_ambient_for_battle()
		set_mix_context("battle")
		return
	_enter_battle_with_stream(stream, battle_track)


## Internal: hard cut to battle track (used by tests and enter_battle).
## Pre-battle state must already be stored by the caller before invoking this.
func _enter_battle_with_stream(stream: AudioStream, battle_track: String) -> void:
	_kill_all_tweens()
	# Silence ambient immediately
	_silence_ambient_immediate()
	# Hard cut music: stop both players, load battle track on active at 0 dB
	AudioCrossfade.silence_pair(_music_active, _music_fade)
	_music_active.stream = stream
	_music_active.volume_db = 0.0
	_music_active.play()

	_current_music = battle_track
	set_mix_context("battle")
	if OS.is_debug_build():
		print("AudioManager: enter_battle '%s'" % battle_track)


## Fade back to exploration music + ambient after battle.
func exit_battle(music_track: String, ambient_track: String) -> void:
	var music_stream: AudioStream = null
	var ambient_stream: AudioStream = null
	if not music_track.is_empty():
		var music_path: String = "res://assets/music/%s.ogg" % music_track
		if ResourceLoader.exists(music_path):
			music_stream = load(music_path)
		elif OS.is_debug_build():
			push_warning("AudioManager: Music file not found: %s" % music_path)
	if not ambient_track.is_empty():
		var ambient_path: String = "res://assets/ambient/%s.ogg" % ambient_track
		if ResourceLoader.exists(ambient_path):
			ambient_stream = load(ambient_path)
		elif OS.is_debug_build():
			push_warning("AudioManager: Ambient file not found: %s" % ambient_path)
	_exit_battle_with_streams(music_stream, ambient_stream, music_track, ambient_track)


## Internal: fade out battle music and restore pre-battle state (used by tests and exit_battle).
func _exit_battle_with_streams(
	music_stream: AudioStream, ambient_stream: AudioStream, music_id: String, ambient_id: String
) -> void:
	# Kill all 4 crossfade tweens to prevent orphaned animations
	_kill_all_tweens()

	# If battle music is playing, swap to fade slot and tween out
	if _music_active.playing:
		var old_active: AudioStreamPlayer = _music_active
		_music_active = _music_fade
		_music_fade = old_active
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_fade, "volume_db", SILENT_DB, CROSSFADE_BATTLE_EXIT)
		_music_fade_tween.tween_callback(_music_fade.stop)

	# Fade in restored music track — only update current ID if stream is valid.
	# Resume from the snapshot position only when restoring the SAME track that
	# was playing pre-battle; a different track starts from 0.
	if music_stream != null:
		var music_pos: float = _pre_battle_music_pos if music_id == _pre_battle_music else 0.0
		_music_active.stream = music_stream
		_music_active.volume_db = SILENT_DB
		_music_active.play(music_pos)
		_music_active_tween = create_tween()
		_music_active_tween.tween_property(_music_active, "volume_db", 0.0, CROSSFADE_BATTLE_EXIT)
		_current_music = music_id
	else:
		_current_music = ""

	# Fade in restored ambient track — resume position only for the same track
	# (audio.md §3.3: exploration music + ambient resume from where they left off).
	if ambient_stream != null:
		var ambient_pos: float = (
			_pre_battle_ambient_pos if ambient_id == _pre_battle_ambient else 0.0
		)
		_ambient_active.stream = ambient_stream
		_ambient_active.volume_db = SILENT_DB
		_ambient_active.play(ambient_pos)
		_ambient_active_tween = create_tween()
		_ambient_active_tween.tween_property(
			_ambient_active, "volume_db", 0.0, CROSSFADE_BATTLE_EXIT
		)
		_current_ambient = ambient_id
	else:
		_current_ambient = ""
	set_mix_context(_pre_battle_mix_context)
	# Clear pre-battle snapshot to prevent stale restore on double exit_battle.
	# Reset _pre_battle_mix_context to "overworld" (valid default) rather than
	# empty string, which would fail the MIX_CONTEXTS lookup on double exit.
	_pre_battle_music = ""
	_pre_battle_ambient = ""
	_pre_battle_music_pos = 0.0
	_pre_battle_ambient_pos = 0.0
	_pre_battle_mix_context = AudioMixContext.DEFAULT_CONTEXT
	if OS.is_debug_build():
		print("AudioManager: exit_battle -> music='%s' ambient='%s'" % [music_id, ambient_id])


## Stop both ambient players immediately and clear current ambient ID.
func _silence_ambient_immediate() -> void:
	AudioCrossfade.silence_pair(_ambient_active, _ambient_fade)
	_current_ambient = ""


## Silence both music and ambient immediately for battle failure paths
## (missing audio file). Without this, exploration music would continue
## playing during battle.
func _silence_music_and_ambient_for_battle() -> void:
	_kill_all_tweens()
	AudioCrossfade.silence_pair(_music_active, _music_fade)
	_silence_ambient_immediate()
	_current_music = ""


## Apply current mix context volumes to all players.
func update_volumes() -> void:
	_apply_bus_volumes()


## Internal: apply bus volumes from current mix context and player config.
func _apply_bus_volumes() -> void:
	var levels: Dictionary = AudioMixContext.bus_volumes(
		_current_mix_context, PartyState.get_config()
	)
	for bus_name: String in ["Music", "Ambient", "SFX"]:
		var idx: int = AudioServer.get_bus_index(bus_name)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, _safe_linear_to_db(levels[bus_name.to_lower()]))


## Convert a linear volume value to dB, returning SILENT_DB for near-zero values.
func _safe_linear_to_db(linear: float) -> float:
	if linear <= 0.001:
		return SILENT_DB
	return linear_to_db(linear)


# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------


## Return the currently playing music track ID.
func get_current_music() -> String:
	return _current_music


## Return the currently playing ambient track ID.
func get_current_ambient() -> String:
	return _current_ambient


## Return the pre-battle music track ID (for callers to pass to exit_battle).
func get_pre_battle_music() -> String:
	return _pre_battle_music


## Return the pre-battle ambient track ID (for callers to pass to exit_battle).
func get_pre_battle_ambient() -> String:
	return _pre_battle_ambient
