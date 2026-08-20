class_name AudioManagerTestBase
extends GutTest
## Shared fixtures and observation helpers for the AudioManager behavior suites.
##
## Two suites extend this class: test_audio_manager.gd, for what each channel
## plays, and test_audio_manager_mix.gd, for how the channels sit against one
## another and how a battle swaps them. Both test what a caller hears, not how
## the manager is wired.
##
## Each test drives the manager through the API a game script calls, and reads
## the result back through the seams a caller has: the public getters, the
## audible state of the AudioStreamPlayer children (a player that is `playing`
## with a given stream is a sound coming out), and the AudioServer bus levels
## (how loud each channel sits). No test reads a private field, because an
## unsettled private field read one statement too early is what made these
## tests flaky (#420).
##
## Two seams the manager does not offer. play_music/play_ambient take a track
## ID and resolve it against the .ogg files in game/assets/, which are
## 0.1-second placeholders, so anything that must still be sounding a few
## statements later is started through the `_play_*_with_stream` calls that
## audio_manager.gd documents as the stream-injection seam. And there is no
## getter for the mix context, so the mix is asserted by its audible
## consequence: the Music and Ambient bus levels.
##
## Fixture length matters. A bare `AudioStreamWAV.new()` has no data, so its
## length is 0.0 and playback ends roughly 5ms after `play()` — narrow enough
## for a loaded CI runner to close the window between two statements, which is
## how #420 failed on CI and never on macOS. These fixtures run FIXTURE_SECONDS
## against a suite that finishes in well under a second.
const FIXTURE_MIX_RATE: int = 22050
const FIXTURE_SECONDS: float = 4.0

## An ID no asset on disk answers to, for the tests that drive the public path.
const MISSING_ID: String = "totally_nonexistent_asset_12345"

var _am: Node
var _saved_music_volume: Variant
var _saved_sfx_volume: Variant


func before_each() -> void:
	var config: Dictionary = PartyState.get_config()
	_saved_music_volume = config.get("music_volume")
	_saved_sfx_volume = config.get("sfx_volume")
	# Pin the sliders so a mix assertion reports the mix rather than whatever
	# another test left in the config dictionary, which is shared suite-wide.
	PartyState.set_config("music_volume", 8.0)
	PartyState.set_config("sfx_volume", 8.0)
	_am = preload("res://scripts/autoload/audio_manager.gd").new()
	add_child_autofree(_am)


func after_each() -> void:
	if _saved_music_volume != null:
		PartyState.set_config("music_volume", _saved_music_volume)
	if _saved_sfx_volume != null:
		PartyState.set_config("sfx_volume", _saved_sfx_volume)
	# Reset AudioServer bus volumes to avoid leaking state across tests
	for bus_name: String in ["Music", "SFX", "Ambient"]:
		var idx: int = AudioServer.get_bus_index(bus_name)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, 0.0)
	_am = null


# --- Fixtures and observation helpers ---


## A silent but genuinely FIXTURE_SECONDS-long stream. Each call returns a
## distinct object, so a test tells its sounds apart by stream identity.
func _fixture_stream() -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = FIXTURE_MIX_RATE
	stream.stereo = false
	var samples: PackedByteArray = PackedByteArray()
	samples.resize(int(FIXTURE_MIX_RATE * FIXTURE_SECONDS))
	stream.data = samples
	return stream


## Start music that outlasts the test. See the header note on placeholder assets.
func _start_music(stream: AudioStream, track_id: String) -> void:
	_am._play_music_with_stream(stream, track_id, 0.0)


func _start_ambient(stream: AudioStream, ambient_id: String) -> void:
	_am._play_ambient_with_stream(stream, ambient_id, 0.0)


func _start_sfx(stream: AudioStream, sfx_id: String, priority: int) -> void:
	_am._play_sfx_with_stream(stream, sfx_id, priority)


func _players_on(bus: String) -> Array[AudioStreamPlayer]:
	var players: Array[AudioStreamPlayer] = []
	for child: Node in _am.get_children():
		var player: AudioStreamPlayer = child as AudioStreamPlayer
		if player != null and String(player.bus) == bus:
			players.append(player)
	return players


func _sounding_on(bus: String) -> Array[AudioStreamPlayer]:
	var sounding: Array[AudioStreamPlayer] = []
	for player: AudioStreamPlayer in _players_on(bus):
		if player.playing:
			sounding.append(player)
	return sounding


func _player_holding(bus: String, stream: AudioStream) -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _players_on(bus):
		if player.stream == stream:
			return player
	return null


func _is_sounding(bus: String, stream: AudioStream) -> bool:
	return _sounding_count(bus, stream) > 0


func _sounding_count(bus: String, stream: AudioStream) -> int:
	var count: int = 0
	for player: AudioStreamPlayer in _sounding_on(bus):
		if player.stream == stream:
			count += 1
	return count


func _bus_db(bus: String) -> float:
	var idx: int = AudioServer.get_bus_index(bus)
	assert_ne(idx, -1, "Bus %s should exist" % bus)
	return AudioServer.get_bus_volume_db(idx)
