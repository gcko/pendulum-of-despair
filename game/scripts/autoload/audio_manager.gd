extends Node
## Audio system: music, SFX, and ambient management.
## Autoloaded as AudioManager.
##
## Manages 16-channel pool (2 music / 2 ambient / 12 SFX) with
## 8-tier priority stack. See docs/story/audio.md for full rules.
## See docs/plans/technical-architecture.md Section 5.3.

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

## Max simultaneous instances of the same SFX ID (per audio.md Section 3.4).
const MAX_SAME_SFX: int = 2

## Crossfade durations in seconds (per audio.md Section 3.3).
const CROSSFADE_BIOME: float = 3.0  # 1.5s out + 1.5s in
const CROSSFADE_TOWN: float = 1.0
const CROSSFADE_BATTLE_EXIT: float = 1.0
const CROSSFADE_PALLOR_MUSIC: float = 5.0
const CROSSFADE_PALLOR_AMBIENT: float = 3.0

## Silence level in decibels (effectively muted).
const SILENT_DB: float = -80.0

## Number of SFX pool slots (matches audio.md Section 3.1 SFX budget).
const SFX_POOL_SIZE: int = 12

## Mixing model: music vs ambient volume ratios (per audio.md Section 2.2).
## Values are percentage multipliers applied to the player's config volume.
const MIX_OVERWORLD: Dictionary = {"music": 1.0, "ambient": 0.35}
const MIX_TOWN: Dictionary = {"music": 1.0, "ambient": 0.25}
const MIX_DUNGEON: Dictionary = {"music": 0.55, "ambient": 0.9}
const MIX_NARRATIVE_DUNGEON: Dictionary = {"music": 1.0, "ambient": 0.35}
const MIX_PALLOR: Dictionary = {"music": 0.0, "ambient": 0.4}
const MIX_BATTLE: Dictionary = {"music": 1.0, "ambient": 0.0}

## Maps context string names to their MIX_* constant dictionaries.
const MIX_CONTEXTS: Dictionary = {
	"overworld": MIX_OVERWORLD,
	"town": MIX_TOWN,
	"dungeon": MIX_DUNGEON,
	"narrative_dungeon": MIX_NARRATIVE_DUNGEON,
	"pallor": MIX_PALLOR,
	"battle": MIX_BATTLE,
}

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
var _current_mix_context: String = "overworld"

# --- State: pre-battle snapshot for exit_battle restoration ---
var _pre_battle_music: String = ""
var _pre_battle_ambient: String = ""
var _pre_battle_music_pos: float = 0.0
var _pre_battle_mix_context: String = "overworld"

# --- State: active tween tracking ---
var _music_active_tween: Tween = null
var _music_fade_tween: Tween = null
var _ambient_active_tween: Tween = null
var _ambient_fade_tween: Tween = null


func _ready() -> void:
	_ensure_audio_buses()
	_create_players()


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
		var player: AudioStreamPlayer = _make_player("sfx_%d" % i, "SFX")
		_sfx_pool.append(player)
		_sfx_meta.append({"sfx_id": "", "priority": Priority.AMBIENT, "start_time": 0})


## Helper to create and register an AudioStreamPlayer child.
func _make_player(player_name: String, bus: String) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = player_name
	player.bus = bus
	player.volume_db = SILENT_DB
	add_child(player)
	return player


# ---------------------------------------------------------------------------
# Public API (stubs — full implementation in subsequent tasks)
# ---------------------------------------------------------------------------


## Play a music track with optional crossfade.
func play_music(track_id: String, crossfade_duration: float = CROSSFADE_BIOME) -> void:
	if track_id == _current_music:
		return
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
	if track_id == _current_music:
		return

	# Kill any in-progress tweens on both music players
	_kill_tween(_music_active_tween)
	_kill_tween(_music_fade_tween)

	# If the active player is currently playing, swap roles
	if _music_active.playing:
		# Old active becomes fade, swap the player references
		var old_active: AudioStreamPlayer = _music_active
		_music_active = _music_fade
		_music_fade = old_active

		# Fade out (or cut) the outgoing track in _music_fade
		if crossfade_duration > 0.0:
			_music_fade_tween = create_tween()
			_music_fade_tween.tween_property(
				_music_fade, "volume_db", SILENT_DB, crossfade_duration / 2.0
			)
			_music_fade_tween.tween_callback(_music_fade.stop)
		else:
			_music_fade.stop()
			_music_fade.volume_db = SILENT_DB
	else:
		# Nothing playing — reset fade slot so it's silent and stopped
		_music_fade.stop()
		_music_fade.volume_db = SILENT_DB

	# Start new track on _music_active
	_music_active.stream = stream
	if crossfade_duration > 0.0:
		_music_active.volume_db = SILENT_DB
		_music_active.play()
		_music_active_tween = create_tween()
		_music_active_tween.tween_property(
			_music_active, "volume_db", 0.0, crossfade_duration / 2.0
		)
	else:
		_music_active.volume_db = 0.0
		_music_active.play()

	_current_music = track_id
	if OS.is_debug_build():
		print("AudioManager: playing music '%s' (crossfade=%.2f)" % [track_id, crossfade_duration])


## Play a sound effect from the SFX pool.
## pan: stereo position (-1.0 left, 0.0 center, 1.0 right) per audio.md Section 3.4.
func play_sfx(sfx_id: String, priority: Priority = Priority.UI_SFX, pan: float = 0.0) -> void:
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
	# Same-ID limit check — only count slots that are still playing
	var same_count: int = 0
	for i: int in range(SFX_POOL_SIZE):
		if _sfx_pool[i].playing and _sfx_meta[i].get("sfx_id") == sfx_id:
			same_count += 1
	if same_count >= MAX_SAME_SFX:
		return

	# Find free slot
	var slot_idx: int = _find_free_sfx_slot()
	if slot_idx == -1:
		slot_idx = _find_steal_target(priority)
		if slot_idx == -1:
			return
		_sfx_pool[slot_idx].stop()

	# Play on the slot
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


## Find the first idle SFX pool slot. Returns -1 if all are busy.
func _find_free_sfx_slot() -> int:
	for i: int in range(SFX_POOL_SIZE):
		if not _sfx_pool[i].playing:
			_sfx_meta[i] = {"sfx_id": "", "priority": Priority.AMBIENT, "start_time": 0}
			return i
	return -1


## Find the lowest-priority (then oldest) slot that can be stolen by requested_priority.
## Returns -1 if no slot has lower priority than requested.
func _find_steal_target(requested_priority: Priority) -> int:
	var lowest_priority: int = int(requested_priority)
	var lowest_idx: int = -1
	for i: int in range(SFX_POOL_SIZE):
		var slot_priority: int = int(_sfx_meta[i].get("priority", Priority.AMBIENT))
		if slot_priority < lowest_priority:
			lowest_priority = slot_priority
			lowest_idx = i
		elif slot_priority == lowest_priority and lowest_idx != -1:
			var slot_time: int = _sfx_meta[i].get("start_time", 0)
			var lowest_time: int = _sfx_meta[lowest_idx].get("start_time", 0)
			if slot_time < lowest_time:
				lowest_idx = i
	return lowest_idx


## Play an ambient loop with optional crossfade.
func play_ambient(ambient_id: String, crossfade_duration: float = CROSSFADE_BIOME) -> void:
	if ambient_id == _current_ambient:
		return
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
	if ambient_id == _current_ambient:
		return

	# Kill any in-progress tweens on both ambient players
	_kill_tween(_ambient_active_tween)
	_kill_tween(_ambient_fade_tween)

	# If the active player is currently playing, swap roles
	if _ambient_active.playing:
		# Old active becomes fade, swap the player references
		var old_active: AudioStreamPlayer = _ambient_active
		_ambient_active = _ambient_fade
		_ambient_fade = old_active

		# Fade out (or cut) the outgoing track in _ambient_fade
		if crossfade_duration > 0.0:
			_ambient_fade_tween = create_tween()
			_ambient_fade_tween.tween_property(
				_ambient_fade, "volume_db", SILENT_DB, crossfade_duration / 2.0
			)
			_ambient_fade_tween.tween_callback(_ambient_fade.stop)
		else:
			_ambient_fade.stop()
			_ambient_fade.volume_db = SILENT_DB
	else:
		# Nothing playing — reset fade slot so it's silent and stopped
		_ambient_fade.stop()
		_ambient_fade.volume_db = SILENT_DB

	# Start new track on _ambient_active
	_ambient_active.stream = stream
	if crossfade_duration > 0.0:
		_ambient_active.volume_db = SILENT_DB
		_ambient_active.play()
		_ambient_active_tween = create_tween()
		_ambient_active_tween.tween_property(
			_ambient_active, "volume_db", 0.0, crossfade_duration / 2.0
		)
	else:
		_ambient_active.volume_db = 0.0
		_ambient_active.play()

	_current_ambient = ambient_id
	if OS.is_debug_build():
		print(
			"AudioManager: playing ambient '%s' (crossfade=%.2f)" % [ambient_id, crossfade_duration]
		)


## Stop all music with an optional fade out.
func stop_music(fade_duration: float = CROSSFADE_TOWN) -> void:
	# Kill any in-flight fade tween and stop the fade player (from a prior crossfade)
	_kill_tween(_music_fade_tween)
	_music_fade.stop()
	_music_fade.volume_db = SILENT_DB

	if not _music_active.playing:
		_current_music = ""
		return
	_kill_tween(_music_active_tween)
	if fade_duration > 0.0:
		_music_active_tween = create_tween()
		_music_active_tween.tween_property(_music_active, "volume_db", SILENT_DB, fade_duration)
		_music_active_tween.tween_callback(_music_active.stop)
	else:
		_music_active.stop()
		_music_active.volume_db = SILENT_DB
	_current_music = ""


## Stop all ambient with an optional fade out.
func stop_ambient(fade_duration: float = CROSSFADE_TOWN) -> void:
	# Kill any in-flight fade tween and stop the fade player
	_kill_tween(_ambient_fade_tween)
	_ambient_fade.stop()
	_ambient_fade.volume_db = SILENT_DB

	if not _ambient_active.playing:
		_current_ambient = ""
		return
	_kill_tween(_ambient_active_tween)
	if fade_duration > 0.0:
		_ambient_active_tween = create_tween()
		_ambient_active_tween.tween_property(_ambient_active, "volume_db", SILENT_DB, fade_duration)
		_ambient_active_tween.tween_callback(_ambient_active.stop)
	else:
		_ambient_active.stop()
		_ambient_active.volume_db = SILENT_DB
	_current_ambient = ""


## Kill a tween safely if it is still valid.
func _kill_tween(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()


## Silence all audio immediately (for narrative silence moments).
func silence_all() -> void:
	# Kill all crossfade tweens
	_kill_tween(_music_active_tween)
	_kill_tween(_music_fade_tween)
	_kill_tween(_ambient_active_tween)
	_kill_tween(_ambient_fade_tween)

	# Stop and silence the four music/ambient players
	for player: AudioStreamPlayer in [_music_active, _music_fade, _ambient_active, _ambient_fade]:
		player.stop()
		player.volume_db = SILENT_DB

	# Stop all SFX pool players and reset their meta
	for i: int in range(SFX_POOL_SIZE):
		_sfx_pool[i].stop()
		_sfx_meta[i] = {"sfx_id": "", "priority": Priority.AMBIENT, "start_time": 0}

	_current_music = ""
	_current_ambient = ""
	if OS.is_debug_build():
		print("AudioManager: silence_all()")


## Set the mixing context (changes music/ambient volume ratio).
func set_mix_context(context: String) -> void:
	if not MIX_CONTEXTS.has(context):
		push_warning("AudioManager: Unknown mix context: %s" % context)
		return
	_current_mix_context = context
	_apply_bus_volumes()
	if OS.is_debug_build():
		print("AudioManager: mix context set to '%s'" % context)


## Hard cut to battle music (no crossfade, ambient cuts to 0).
func enter_battle(battle_track: String) -> void:
	# Only snapshot pre-battle state if we are NOT already in battle.
	# A second enter_battle without an exit_battle would otherwise overwrite
	# the original exploration state, losing it permanently.
	if _current_mix_context != "battle":
		_pre_battle_music = _current_music
		_pre_battle_ambient = _current_ambient
		_pre_battle_music_pos = (
			_music_active.get_playback_position() if _music_active.playing else 0.0
		)
		_pre_battle_mix_context = _current_mix_context

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
	# Kill all 4 crossfade tweens
	_kill_tween(_music_active_tween)
	_kill_tween(_music_fade_tween)
	_kill_tween(_ambient_active_tween)
	_kill_tween(_ambient_fade_tween)

	# Silence ambient immediately
	_silence_ambient_immediate()

	# Hard cut music: stop both players, load battle track on active at 0 dB
	_music_active.stop()
	_music_active.volume_db = SILENT_DB
	_music_fade.stop()
	_music_fade.volume_db = SILENT_DB

	_music_active.stream = stream
	_music_active.volume_db = 0.0
	_music_active.play()

	_current_music = battle_track
	set_mix_context("battle")
	if OS.is_debug_build():
		print("AudioManager: enter_battle '%s'" % battle_track)


## Fade back to exploration music + ambient after battle.
func exit_battle(music_track: String, ambient_track: String) -> void:
	var music_path: String = "res://assets/music/%s.ogg" % music_track
	var ambient_path: String = "res://assets/ambient/%s.ogg" % ambient_track
	var music_stream: AudioStream = null
	var ambient_stream: AudioStream = null
	if ResourceLoader.exists(music_path):
		music_stream = load(music_path)
	elif OS.is_debug_build():
		push_warning("AudioManager: Music file not found: %s" % music_path)
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
	_kill_tween(_music_active_tween)
	_kill_tween(_music_fade_tween)
	_kill_tween(_ambient_active_tween)
	_kill_tween(_ambient_fade_tween)

	# If battle music is playing, swap to fade slot and tween out
	if _music_active.playing:
		var old_active: AudioStreamPlayer = _music_active
		_music_active = _music_fade
		_music_fade = old_active
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_fade, "volume_db", SILENT_DB, CROSSFADE_BATTLE_EXIT)
		_music_fade_tween.tween_callback(_music_fade.stop)

	# Fade in restored music track — only update current ID if stream is valid
	if music_stream != null:
		_music_active.stream = music_stream
		_music_active.volume_db = SILENT_DB
		_music_active.play(_pre_battle_music_pos)
		_music_active_tween = create_tween()
		_music_active_tween.tween_property(_music_active, "volume_db", 0.0, CROSSFADE_BATTLE_EXIT)
		_current_music = music_id
	else:
		_current_music = ""

	# Fade in restored ambient track — only update current ID if stream is valid
	if ambient_stream != null:
		_ambient_active.stream = ambient_stream
		_ambient_active.volume_db = SILENT_DB
		_ambient_active.play()
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
	_pre_battle_mix_context = "overworld"
	if OS.is_debug_build():
		print("AudioManager: exit_battle -> music='%s' ambient='%s'" % [music_id, ambient_id])


## Stop both ambient players immediately and clear current ambient ID.
func _silence_ambient_immediate() -> void:
	_ambient_active.stop()
	_ambient_active.volume_db = SILENT_DB
	_ambient_fade.stop()
	_ambient_fade.volume_db = SILENT_DB
	_current_ambient = ""


## Silence both music and ambient immediately for battle failure paths
## (missing audio file). Without this, exploration music would continue
## playing during battle.
func _silence_music_and_ambient_for_battle() -> void:
	_kill_tween(_music_active_tween)
	_kill_tween(_music_fade_tween)
	_kill_tween(_ambient_active_tween)
	_kill_tween(_ambient_fade_tween)
	_music_active.stop()
	_music_active.volume_db = SILENT_DB
	_music_fade.stop()
	_music_fade.volume_db = SILENT_DB
	_silence_ambient_immediate()
	_current_music = ""


## Apply current mix context volumes to all players.
func update_volumes() -> void:
	_apply_bus_volumes()


## Internal: apply bus volumes from current mix context and player config.
func _apply_bus_volumes() -> void:
	var config: Dictionary = PartyState.get_config()
	var music_vol: int = config.get("music_volume", 8)
	var sfx_vol: int = config.get("sfx_volume", 8)

	var mix: Dictionary = MIX_CONTEXTS.get(_current_mix_context, MIX_OVERWORLD)
	var music_ratio: float = mix.get("music", 1.0)
	var ambient_ratio: float = mix.get("ambient", 0.35)

	var music_linear: float = (music_vol / 10.0) * music_ratio
	var ambient_linear: float = (sfx_vol / 10.0) * ambient_ratio
	var sfx_linear: float = sfx_vol / 10.0

	var music_idx: int = AudioServer.get_bus_index("Music")
	if music_idx != -1:
		AudioServer.set_bus_volume_db(music_idx, _safe_linear_to_db(music_linear))

	var ambient_idx: int = AudioServer.get_bus_index("Ambient")
	if ambient_idx != -1:
		AudioServer.set_bus_volume_db(ambient_idx, _safe_linear_to_db(ambient_linear))

	var sfx_idx: int = AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		AudioServer.set_bus_volume_db(sfx_idx, _safe_linear_to_db(sfx_linear))


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
