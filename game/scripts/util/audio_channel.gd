class_name AudioChannel
extends RefCounted
## One crossfading channel: a pair of AudioStreamPlayers — one carrying the
## track you hear, one carrying whatever is on its way out — plus the ID of
## what is sounding on it.
##
## Music and the ambient bed are the same channel twice. Before this split,
## audio_manager.gd carried five fields per channel (active player, fade
## player, two tweens, track ID) and open-coded the handling of them once per
## channel, which is most of what held the file over the § 1.2a aim (#425).
## AudioCrossfade still owns the fade curves; this owns the state they act on.

var _owner: Node
var _active: AudioStreamPlayer
var _fade: AudioStreamPlayer
var _active_tween: Tween = null
var _fade_tween: Tween = null
var _track_id: String = ""


## [param owner] creates the tweens, so it must be in the scene tree —
## AudioManager passes itself, and it parents both players.
func _init(owner: Node, active: AudioStreamPlayer, fade: AudioStreamPlayer) -> void:
	_owner = owner
	_active = active
	_fade = fade


## The ID of the track sounding on this channel, or "" for silence.
func get_track_id() -> String:
	return _track_id


## How far into the current track playback has reached, or 0.0 when the channel
## is silent — the position a battle exit resumes from.
func get_playback_position() -> float:
	return _active.get_playback_position() if _active.playing else 0.0


## Bring [param stream] in as [param track_id], fading the outgoing track out
## over [param duration]. A duration of 0 is a hard cut.
func swap_in(stream: AudioStream, track_id: String, duration: float) -> void:
	var pair: Dictionary = AudioCrossfade.swap_in(
		_owner, _active, _fade, _active_tween, _fade_tween, stream, duration
	)
	_active = pair["active"]
	_fade = pair["fade"]
	_active_tween = pair["active_tween"]
	_fade_tween = pair["fade_tween"]
	_track_id = track_id


## Fade the channel out over [param duration] and report silence.
func fade_out(duration: float) -> void:
	var pair: Dictionary = AudioCrossfade.fade_out(
		_owner, _active, _fade, _active_tween, _fade_tween, duration
	)
	_active_tween = pair["active_tween"]
	_fade_tween = pair["fade_tween"]
	_track_id = ""


## Cut to [param stream] at full volume with no fade, stopping both players
## first. This is the battle entry, which audio.md § 3.3 specifies as a cut.
func hard_cut(stream: AudioStream, track_id: String) -> void:
	AudioCrossfade.silence_pair(_active, _fade)
	_active.stream = stream
	_active.volume_db = 0.0
	_active.play()
	_track_id = track_id


## Push whatever is sounding into the fade slot and tween it out, leaving the
## active slot free for a track that fades in over the same window. Does
## nothing when the channel is already silent.
func retire_active(duration: float) -> void:
	if not _active.playing:
		return
	var outgoing: AudioStreamPlayer = _active
	_active = _fade
	_fade = outgoing
	_fade_tween = _owner.create_tween()
	_fade_tween.tween_property(_fade, "volume_db", AudioCrossfade.SILENT_DB, duration)
	_fade_tween.tween_callback(_fade.stop)


## Fade [param stream] in on the active slot from [param position]. A null
## stream means there is nothing to bring back, so the channel reports silence
## and leaves the players alone — whatever retire_active started keeps fading.
func fade_in(stream: AudioStream, track_id: String, position: float, duration: float) -> void:
	if stream == null:
		_track_id = ""
		return
	_active.stream = stream
	_active.volume_db = AudioCrossfade.SILENT_DB
	_active.play(position)
	_active_tween = _owner.create_tween()
	_active_tween.tween_property(_active, "volume_db", 0.0, duration)
	_track_id = track_id


## Stop both players at once, with no fade, and report silence.
func silence() -> void:
	AudioCrossfade.silence_pair(_active, _fade)
	_track_id = ""


## Cancel any fade in flight and drop the references. Without this, a crossfade
## started a moment ago goes on lifting the volume back up after a silence.
func kill_tweens() -> void:
	AudioCrossfade.kill(_active_tween)
	AudioCrossfade.kill(_fade_tween)
	_active_tween = null
	_fade_tween = null
