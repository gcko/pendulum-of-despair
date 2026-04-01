extends Node
## Audio system: music, SFX, and ambient management.
## Autoloaded as AudioManager.
##
## Manages 24-channel budget (8 music / 12 SFX / 4 ambient) with
## 8-tier priority stack. See docs/story/audio.md for full rules.
## See docs/plans/technical-architecture.md Section 5.3.
##
## NOTE: Full implementation requires AudioStreamPlayer nodes which
## need to be set up in a scene. This script provides the interface
## and constants. Wire up AudioStreamPlayers when scenes are built.

## Channel budget constants (per audio.md Section 3.1).
const MUSIC_CHANNELS: int = 8
const SFX_CHANNELS: int = 12
const AMBIENT_CHANNELS: int = 4
const TOTAL_CHANNELS: int = 24

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

## Max simultaneous instances of the same SFX ID (per audio.md Section 3.4).
const MAX_SAME_SFX: int = 2

## Crossfade durations in seconds (per audio.md Section 3.3).
const CROSSFADE_BIOME: float = 3.0       # 1.5s out + 1.5s in
const CROSSFADE_TOWN: float = 1.0
const CROSSFADE_BATTLE_EXIT: float = 1.0
const CROSSFADE_PALLOR_MUSIC: float = 5.0
const CROSSFADE_PALLOR_AMBIENT: float = 3.0

## Mixing model: music vs ambient volume ratios (per audio.md Section 2.2).
## Values are percentage multipliers applied to the player's config volume.
const MIX_OVERWORLD: Dictionary = {"music": 1.0, "ambient": 0.35}
const MIX_TOWN: Dictionary = {"music": 1.0, "ambient": 0.25}
const MIX_DUNGEON: Dictionary = {"music": 0.55, "ambient": 0.9}
const MIX_NARRATIVE_DUNGEON: Dictionary = {"music": 1.0, "ambient": 0.35}
const MIX_PALLOR: Dictionary = {"music": 0.0, "ambient": 0.4}
const MIX_BATTLE: Dictionary = {"music": 1.0, "ambient": 0.0}

## Currently active tracks (for crossfade management).
var _current_music: String = ""
var _current_ambient: String = ""


## Play a music track with crossfade.
func play_music(track_id: String, _crossfade_duration: float = CROSSFADE_BIOME) -> void:
	if track_id == _current_music:
		return
	# TODO: Implement crossfade with AudioStreamPlayer nodes
	_current_music = track_id
	if OS.is_debug_build():
		print("AudioManager: play_music(%s)" % track_id)


## Play a sound effect.
func play_sfx(sfx_id: String, _priority: Priority = Priority.UI_SFX) -> void:
	# TODO: Implement with AudioStreamPlayer pool, priority check, max instances
	if OS.is_debug_build():
		print("AudioManager: play_sfx(%s)" % sfx_id)


## Play an ambient loop with crossfade.
func play_ambient(ambient_id: String, _crossfade_duration: float = CROSSFADE_BIOME) -> void:
	if ambient_id == _current_ambient:
		return
	# TODO: Implement crossfade with AudioStreamPlayer nodes
	_current_ambient = ambient_id
	if OS.is_debug_build():
		print("AudioManager: play_ambient(%s)" % ambient_id)


## Stop all audio (for narrative silence moments).
func silence_all() -> void:
	_current_music = ""
	_current_ambient = ""
	# TODO: Fade all AudioStreamPlayers to 0
	if OS.is_debug_build():
		print("AudioManager: silence_all()")


## Set mixing context (changes music/ambient volume ratio).
func set_mix_context(context: String) -> void:
	# TODO: Apply volume ratios from MIX_* constants
	if OS.is_debug_build():
		print("AudioManager: set_mix_context(%s)" % context)


## Hard cut to battle music (no crossfade, ambient cuts to 0).
func enter_battle(battle_track: String) -> void:
	_current_ambient = ""
	_current_music = battle_track
	# TODO: Hard cut music, silence ambient
	if OS.is_debug_build():
		print("AudioManager: enter_battle(%s)" % battle_track)


## Fade back to exploration music + ambient after battle.
func exit_battle(music_track: String, ambient_track: String) -> void:
	_current_music = music_track
	_current_ambient = ambient_track
	# TODO: Crossfade over CROSSFADE_BATTLE_EXIT duration
	if OS.is_debug_build():
		print("AudioManager: exit_battle(%s, %s)" % [music_track, ambient_track])
