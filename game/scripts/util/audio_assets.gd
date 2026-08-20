class_name AudioAssets
extends RefCounted
## Where a track ID lives on disk, and loading it without bringing the game
## down when the file is not there.
##
## Every playback entry point in audio_manager.gd used to open-code the same
## four steps — build the path, ask ResourceLoader, warn in a debug build,
## load — once per entry point, five times over (#425).

const MUSIC_DIR: String = "res://assets/music/"
const AMBIENT_DIR: String = "res://assets/ambient/"
const SFX_DIR: String = "res://assets/sfx/"
const EXTENSION: String = ".ogg"


## The music [param track_id] resolves to, or null when no such file ships.
## [param label] names the kind of audio in the warning, so a battle track that
## is missing says so rather than reporting as ordinary music.
static func load_music(track_id: String, label: String = "Music") -> AudioStream:
	return _load(MUSIC_DIR, track_id, label)


## The ambient bed [param ambient_id] resolves to, or null when it is absent.
static func load_ambient(ambient_id: String) -> AudioStream:
	return _load(AMBIENT_DIR, ambient_id, "Ambient")


## The sound effect [param sfx_id] resolves to, or null when it is absent.
static func load_sfx(sfx_id: String) -> AudioStream:
	return _load(SFX_DIR, sfx_id, "SFX")


## An empty ID is a caller saying "nothing here" rather than naming an asset
## that has gone missing, so it returns null in silence; a named file that is
## absent warns, but only in a debug build.
static func _load(dir: String, asset_id: String, label: String) -> AudioStream:
	if asset_id.is_empty():
		return null
	var path: String = "%s%s%s" % [dir, asset_id, EXTENSION]
	if not ResourceLoader.exists(path):
		if OS.is_debug_build():
			push_warning("AudioManager: %s file not found: %s" % [label, path])
		return null
	return load(path)
