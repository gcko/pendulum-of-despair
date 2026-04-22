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

## Channel budget constants (per audio.md Section 3.1).
const MUSIC_CHANNELS: int = 8
const SFX_CHANNELS: int = 12
const AMBIENT_CHANNELS: int = 4
const TOTAL_CHANNELS: int = 24

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

## Number of SFX pool slots.
const SFX_POOL_SIZE: int = 12

## Fast fade duration used when stealing an SFX slot.
const STEAL_FADE_DURATION: float = 0.05

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
var _current_mix_context: String = ""

# --- State: pre-battle snapshot for exit_battle restoration ---
var _pre_battle_music: String = ""
var _pre_battle_ambient: String = ""
var _pre_battle_mix_context: String = ""

# --- State: active tween tracking ---
var _music_tween: Tween = null
var _ambient_tween: Tween = null


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
		_sfx_meta.append({})


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
func play_music(_track_id: String, _crossfade_duration: float = CROSSFADE_BIOME) -> void:
	pass


## Play a sound effect from the SFX pool.
func play_sfx(_sfx_id: String, _priority: Priority = Priority.UI_SFX, _pan: float = 0.0) -> void:
	pass


## Play an ambient loop with optional crossfade.
func play_ambient(_ambient_id: String, _crossfade_duration: float = CROSSFADE_BIOME) -> void:
	pass


## Stop all music with an optional fade out.
func stop_music(_fade_duration: float = CROSSFADE_BIOME) -> void:
	pass


## Silence all audio immediately (for narrative silence moments).
func silence_all() -> void:
	pass


## Set the mixing context (changes music/ambient volume ratio).
func set_mix_context(_context: String) -> void:
	pass


## Hard cut to battle music (no crossfade, ambient cuts to 0).
func enter_battle(_battle_track: String) -> void:
	pass


## Fade back to exploration music + ambient after battle.
func exit_battle(_music_track: String, _ambient_track: String) -> void:
	pass


## Apply current mix context volumes to all players.
func update_volumes() -> void:
	pass


# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------


## Return the currently playing music track ID.
func get_current_music() -> String:
	return _current_music


## Return the currently playing ambient track ID.
func get_current_ambient() -> String:
	return _current_ambient
