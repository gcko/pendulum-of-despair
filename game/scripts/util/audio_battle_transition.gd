class_name AudioBattleTransition
extends RefCounted
## The battle swap: what the exploration soundscape was before the fight, and
## putting it back when the fight ends (audio.md § 3.3).
##
## Owns the pre-battle snapshot — track IDs, playback positions and the mix
## context — because that state exists for no other reason and nothing else
## reads it. Extracted from audio_manager.gd, where the two transitions and
## their five snapshot fields were 28% of the file (#425).

## Seconds the battle track takes to fade out while the exploration audio fades
## back in. The two run concurrently, so this is the length of the transition.
const EXIT_FADE: float = 1.0

var _music_id: String = ""
var _ambient_id: String = ""
var _music_position: float = 0.0
var _ambient_position: float = 0.0
var _mix_context: String = AudioMixContext.DEFAULT_CONTEXT


## The exploration track remembered for the caller to hand back to exit().
func get_music() -> String:
	return _music_id


## The exploration ambient bed remembered for the caller to hand to exit().
func get_ambient() -> String:
	return _ambient_id


## Remember what is sounding, so exit() can put it back where it left off.
## Callers take the snapshot before any failure path can return: a battle whose
## music file is missing still has to restore the exploration audio afterwards.
func snapshot(music: AudioChannel, ambient: AudioChannel, mix_context: String) -> void:
	_music_id = music.get_track_id()
	_ambient_id = ambient.get_track_id()
	_music_position = music.get_playback_position()
	_ambient_position = ambient.get_playback_position()
	_mix_context = mix_context


## Hard cut to the battle track: the ambient bed stops dead and the music cuts
## with no fade, per audio.md § 3.3.
func enter(
	music: AudioChannel, ambient: AudioChannel, stream: AudioStream, track_id: String
) -> void:
	music.kill_tweens()
	ambient.kill_tweens()
	ambient.silence()
	music.hard_cut(stream, track_id)


## Silence both channels for a battle with no track to play. Without this, an
## empty or missing battle track would leave exploration music running under
## the fight instead of cutting to it.
func silence_for_battle(music: AudioChannel, ambient: AudioChannel) -> void:
	music.kill_tweens()
	ambient.kill_tweens()
	music.silence()
	ambient.silence()


## Fade the battle track out and the given exploration streams back in, then
## forget the snapshot so a second exit cannot restore a stale one. A track
## that matches the snapshot resumes where it left off; anything else starts
## from the top. Returns the mix context the caller should restore.
func exit(
	music: AudioChannel,
	ambient: AudioChannel,
	music_stream: AudioStream,
	ambient_stream: AudioStream,
	music_id: String,
	ambient_id: String
) -> String:
	music.kill_tweens()
	ambient.kill_tweens()
	music.retire_active(EXIT_FADE)
	var music_at: float = _resume_at(music_id, _music_id, _music_position)
	var ambient_at: float = _resume_at(ambient_id, _ambient_id, _ambient_position)
	music.fade_in(music_stream, music_id, music_at, EXIT_FADE)
	ambient.fade_in(ambient_stream, ambient_id, ambient_at, EXIT_FADE)
	var restore_to: String = _mix_context
	_forget()
	return restore_to


## The position [param requested] resumes from: the remembered one when it is
## the track that was interrupted, and the start of the track otherwise.
static func _resume_at(requested: String, remembered: String, position: float) -> float:
	return position if requested == remembered else 0.0


## Clear the snapshot. The mix context falls back to the default rather than to
## an empty string, which would fail the context lookup on a second exit.
func _forget() -> void:
	_music_id = ""
	_ambient_id = ""
	_music_position = 0.0
	_ambient_position = 0.0
	_mix_context = AudioMixContext.DEFAULT_CONTEXT
