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
## What is left here is the Node half — the buses, the 16 AudioStreamPlayer
## children this node parents, and the public entry points game scripts call.
## The rules live beside it in `scripts/util/`: AudioChannel (a crossfading
## player pair and the track on it), AudioCrossfade (the fade curves it runs),
## AudioBattleTransition (the pre-battle snapshot and the swap back),
## AudioMixContext (how loud each channel sits per place), AudioSfxPolicy
## (priority and voice stealing) and AudioAssets (where a track ID lives on
## disk). AudioCrossfade, AudioMixContext and AudioSfxPolicy were split out in
## GAP-087; AudioChannel, AudioBattleTransition and AudioAssets in #425.

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

## The three buses the channels sit on. Created here if the project has none.
const BUSES: Array[String] = ["Music", "SFX", "Ambient"]

## Crossfade durations in seconds (per audio.md Section 3.3).
## Fades run concurrently over the full duration (out + in), so CROSSFADE_BIOME
## produces a 3s transition — matching audio.md §3.3 and the exit_battle convention.
const CROSSFADE_BIOME: float = 3.0
const CROSSFADE_TOWN: float = 1.0
## Owned by AudioBattleTransition, which runs the battle exit; re-exported here
## for callers timing a scene transition against it.
const CROSSFADE_BATTLE_EXIT: float = AudioBattleTransition.EXIT_FADE
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

# --- State: the two crossfading channels, each over a pair of players ---
var _music: AudioChannel = null
var _ambient: AudioChannel = null

# --- State: SFX pool ---
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_meta: Array[Dictionary] = []

# --- State: where the mix sits, and what to put back after a battle ---
var _current_mix_context: String = AudioMixContext.DEFAULT_CONTEXT
var _battle: AudioBattleTransition = AudioBattleTransition.new()


func _ready() -> void:
	_ensure_audio_buses()
	_create_players()
	# Defer volume application: AudioManager loads before PartyState in the
	# autoload order (project.godot), so PartyState.get_config() is unavailable
	# during _ready(). Deferring runs it after all autoloads enter the tree.
	_apply_bus_volumes.call_deferred()


## Ensure Music, SFX, and Ambient buses exist (adds them if missing).
func _ensure_audio_buses() -> void:
	for bus_name: String in BUSES:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx: int = AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")


## Create the 16 AudioStreamPlayer nodes: 2 music, 2 ambient, 12 SFX. The two
## crossfade pairs are handed to an AudioChannel each, which owns them from
## here on; the SFX pool stays flat because AudioSfxPolicy indexes into it.
func _create_players() -> void:
	_music = AudioChannel.new(
		self, _make_player("music_active", "Music"), _make_player("music_fade", "Music")
	)
	_ambient = AudioChannel.new(
		self, _make_player("ambient_active", "Ambient"), _make_player("ambient_fade", "Ambient")
	)
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
	if track_id == _music.get_track_id():
		return
	var stream: AudioStream = AudioAssets.load_music(track_id)
	if stream == null:
		return
	_play_music_with_stream(stream, track_id, maxf(0.0, crossfade_duration))


## Internal: play a stream directly into the music players (used by tests and play_music).
func _play_music_with_stream(
	stream: AudioStream, track_id: String, crossfade_duration: float
) -> void:
	if stream == null or track_id == _music.get_track_id():
		return
	_music.swap_in(stream, track_id, crossfade_duration)
	if OS.is_debug_build():
		print("AudioManager: playing music '%s' (crossfade=%.2f)" % [track_id, crossfade_duration])


## Play a sound effect from the SFX pool.
## pan: stereo position (-1.0 left, 0.0 center, 1.0 right) per audio.md Section 3.4.
func play_sfx(sfx_id: String, priority: Priority = Priority.UI_SFX, pan: float = 0.0) -> void:
	var stream: AudioStream = AudioAssets.load_sfx(sfx_id)
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
	if ambient_id == _ambient.get_track_id():
		return
	var stream: AudioStream = AudioAssets.load_ambient(ambient_id)
	if stream == null:
		return
	_play_ambient_with_stream(stream, ambient_id, maxf(0.0, crossfade_duration))


## Internal: play a stream directly into the ambient players (used by tests and play_ambient).
func _play_ambient_with_stream(
	stream: AudioStream, ambient_id: String, crossfade_duration: float
) -> void:
	if stream == null or ambient_id == _ambient.get_track_id():
		return
	_ambient.swap_in(stream, ambient_id, crossfade_duration)
	if OS.is_debug_build():
		print(
			"AudioManager: playing ambient '%s' (crossfade=%.2f)" % [ambient_id, crossfade_duration]
		)


## Stop all music with an optional fade out.
func stop_music(fade_duration: float = CROSSFADE_TOWN) -> void:
	_music.fade_out(maxf(0.0, fade_duration))


## Stop all ambient with an optional fade out.
func stop_ambient(fade_duration: float = CROSSFADE_TOWN) -> void:
	_ambient.fade_out(maxf(0.0, fade_duration))


## Silence all audio immediately (for narrative silence moments).
func silence_all() -> void:
	# Cancel the crossfades first: an in-flight fade would otherwise lift the
	# music back out of the silence a fraction of a second later.
	for channel: AudioChannel in [_music, _ambient]:
		channel.kill_tweens()
		channel.silence()
	for i: int in range(SFX_POOL_SIZE):
		_sfx_pool[i].stop()
		_sfx_meta[i] = AudioSfxPolicy.empty_meta(Priority.AMBIENT)
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
	# Snapshot pre-battle state FIRST, before any failure path can return. All
	# four paths (empty track, missing file, null stream, success) need it
	# stored so exit_battle can restore the exploration audio. A second
	# enter_battle from inside a battle — a boss phase change — must not
	# overwrite the snapshot with the battle track it is replacing.
	if _current_mix_context != AudioMixContext.BATTLE_CONTEXT:
		_battle.snapshot(_music, _ambient, _current_mix_context)
	if battle_track.is_empty() and OS.is_debug_build():
		push_warning("AudioManager: enter_battle called with empty track ID")
	var stream: AudioStream = AudioAssets.load_music(battle_track, "Battle music")
	if stream == null:
		_battle.silence_for_battle(_music, _ambient)
		set_mix_context(AudioMixContext.BATTLE_CONTEXT)
		return
	_enter_battle_with_stream(stream, battle_track)


## Internal: hard cut to battle track (used by tests and enter_battle).
## Pre-battle state must already be stored by the caller before invoking this.
func _enter_battle_with_stream(stream: AudioStream, battle_track: String) -> void:
	_battle.enter(_music, _ambient, stream, battle_track)
	set_mix_context(AudioMixContext.BATTLE_CONTEXT)
	if OS.is_debug_build():
		print("AudioManager: enter_battle '%s'" % battle_track)


## Fade back to exploration music + ambient after battle.
func exit_battle(music_track: String, ambient_track: String) -> void:
	_exit_battle_with_streams(
		AudioAssets.load_music(music_track),
		AudioAssets.load_ambient(ambient_track),
		music_track,
		ambient_track
	)


## Internal: fade out battle music and restore pre-battle state (used by tests and exit_battle).
func _exit_battle_with_streams(
	music_stream: AudioStream, ambient_stream: AudioStream, music_id: String, ambient_id: String
) -> void:
	set_mix_context(
		_battle.exit(_music, _ambient, music_stream, ambient_stream, music_id, ambient_id)
	)
	if OS.is_debug_build():
		print("AudioManager: exit_battle -> music='%s' ambient='%s'" % [music_id, ambient_id])


## Apply current mix context volumes to all players.
func update_volumes() -> void:
	_apply_bus_volumes()


## Internal: apply bus volumes from current mix context and player config.
func _apply_bus_volumes() -> void:
	var levels: Dictionary = AudioMixContext.bus_volumes(
		_current_mix_context, PartyState.get_config()
	)
	for bus_name: String in BUSES:
		var idx: int = AudioServer.get_bus_index(bus_name)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, AudioMixContext.to_db(levels[bus_name.to_lower()]))


# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------


## Return the currently playing music track ID.
func get_current_music() -> String:
	return _music.get_track_id()


## Return the currently playing ambient track ID.
func get_current_ambient() -> String:
	return _ambient.get_track_id()


## Return the pre-battle music track ID (for callers to pass to exit_battle).
func get_pre_battle_music() -> String:
	return _battle.get_music()


## Return the pre-battle ambient track ID (for callers to pass to exit_battle).
func get_pre_battle_ambient() -> String:
	return _battle.get_ambient()
