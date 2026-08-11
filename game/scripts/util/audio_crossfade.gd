class_name AudioCrossfade
extends RefCounted
## Crossfade mechanics for a pair of AudioStreamPlayers — one active, one
## fading. Music and ambient are the same problem twice, so they share this.
##
## Extracted from audio_manager.gd (GAP-087), which had the whole routine
## written out once per channel. The manager still owns the player and tween
## references; these calls hand back the pair's new state.

## Silence level in decibels (effectively muted).
const SILENT_DB: float = -80.0


## Bring [param stream] in on the pair, fading the outgoing track out on the
## other player. A duration of 0 is a hard cut.
##
## Returns {"active", "fade", "active_tween", "fade_tween"} — the pair's state
## after the swap, for the caller to store back.
static func swap_in(
	owner: Node,
	active: AudioStreamPlayer,
	fade: AudioStreamPlayer,
	active_tween: Tween,
	fade_tween: Tween,
	stream: AudioStream,
	duration: float
) -> Dictionary:
	# Kill any in-progress tweens on both players
	kill(active_tween)
	kill(fade_tween)
	var new_active: AudioStreamPlayer = active
	var new_fade: AudioStreamPlayer = fade
	var new_fade_tween: Tween = null
	if active.playing:
		# Old active becomes fade, swap the player references
		new_active = fade
		new_fade = active
		if duration > 0.0:
			new_fade_tween = owner.create_tween()
			new_fade_tween.tween_property(new_fade, "volume_db", SILENT_DB, duration)
			new_fade_tween.tween_callback(new_fade.stop)
		else:
			silence_player(new_fade)
	else:
		# Nothing playing — reset fade slot so it's silent and stopped
		silence_player(new_fade)
	# Start the new track on the active player. Stop first in case this slot is
	# a still-playing fade left over from an interrupted (3rd+) crossfade —
	# reassigning .stream on a playing player would hard-cut/click.
	new_active.stop()
	new_active.stream = stream
	var new_active_tween: Tween = null
	if duration > 0.0:
		new_active.volume_db = SILENT_DB
		new_active.play()
		new_active_tween = owner.create_tween()
		new_active_tween.tween_property(new_active, "volume_db", 0.0, duration)
	else:
		new_active.volume_db = 0.0
		new_active.play()
	return {
		"active": new_active,
		"fade": new_fade,
		"active_tween": new_active_tween,
		"fade_tween": new_fade_tween,
	}


## Fade the pair out. The fade slot is cut immediately (it is already on its way
## out); the active player fades over [param duration], or stops at once when
## that is 0.
##
## Returns {"active_tween", "fade_tween"} for the caller to store back.
static func fade_out(
	owner: Node,
	active: AudioStreamPlayer,
	fade: AudioStreamPlayer,
	active_tween: Tween,
	fade_tween: Tween,
	duration: float
) -> Dictionary:
	# Kill any in-flight fade tween and stop the fade player (from a prior crossfade)
	kill(fade_tween)
	silence_player(fade)
	if not active.playing:
		return {"active_tween": active_tween, "fade_tween": null}
	kill(active_tween)
	var new_active_tween: Tween = null
	if duration > 0.0:
		new_active_tween = owner.create_tween()
		new_active_tween.tween_property(active, "volume_db", SILENT_DB, duration)
		new_active_tween.tween_callback(active.stop)
	else:
		silence_player(active)
	return {"active_tween": new_active_tween, "fade_tween": null}


## Stop and mute both players of a pair immediately, with no fade.
static func silence_pair(active: AudioStreamPlayer, fade: AudioStreamPlayer) -> void:
	silence_player(active)
	silence_player(fade)


## Stop one player and drop it to silence.
static func silence_player(player: AudioStreamPlayer) -> void:
	player.stop()
	player.volume_db = SILENT_DB


## Kill a tween safely if it is still valid.
static func kill(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()
