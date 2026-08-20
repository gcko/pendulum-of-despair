extends GutTest
## Behavior tests for AudioManager: what a caller hears, not how it is wired.
##
## Each test drives the manager through the API a game script calls, and reads
## the result back through the seams a caller has: the public getters, the
## audible state of the AudioStreamPlayer children (a player that is `playing`
## with a given stream is a sound coming out), and the AudioServer bus levels
## (how loud each channel sits). No test reads a private field, because an
## unsettled private field read one statement too early is what made this file
## flaky (#420).
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

## Real placeholder assets on disk, for the tests that drive the public ID path.
const REAL_MUSIC: String = "overworld_act_i"
const REAL_BATTLE: String = "battle_standard"
const REAL_BOSS: String = "battle_boss"
const REAL_AMBIENT: String = "valdris_highlands"
const MISSING_ID: String = "totally_nonexistent_asset_12345"

## Bus level at or below which a channel is inaudible.
const INAUDIBLE_DB: float = -60.0

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


# --- Harness guard ---


func test_fixture_stream_outlasts_the_test_that_listens_to_it() -> void:
	# Guards the guard: if this fails, the fixture has regressed to zero-length
	# and every "is it sounding" assertion below is racing the clock again.
	var stream: AudioStreamWAV = _fixture_stream()
	assert_gt(stream.get_length(), 1.0, "Fixture stream must be seconds long, not zero-length")


# --- Channels ---


func test_music_ambient_and_sfx_have_independent_volume_channels() -> void:
	for bus_name: String in ["Music", "SFX", "Ambient"]:
		assert_ne(AudioServer.get_bus_index(bus_name), -1, "%s bus should exist" % bus_name)


# --- Sound effects ---


func test_playing_a_sound_effect_makes_it_audible() -> void:
	var hit: AudioStreamWAV = _fixture_stream()
	_start_sfx(hit, "hit_physical", AudioManager.Priority.BATTLE_SFX)
	assert_true(_is_sounding("SFX", hit), "The sound effect should be sounding")


func test_twelve_sound_effects_can_sound_at_once() -> void:
	var sounds: Array[AudioStreamWAV] = []
	for i: int in range(12):
		sounds.append(_fixture_stream())
		_start_sfx(sounds[i], "exp_%d" % i, AudioManager.Priority.EXPLORATION_SFX)
	for i: int in range(12):
		assert_true(_is_sounding("SFX", sounds[i]), "Sound %d should still be audible" % i)


func test_the_same_sound_effect_never_sounds_more_than_twice_at_once() -> void:
	# audio.md 3.4: a repeated hit stacks to two voices, the third is dropped.
	var hit: AudioStreamWAV = _fixture_stream()
	for _i: int in range(3):
		_start_sfx(hit, "hit_physical", AudioManager.Priority.UI_SFX)
	assert_eq(_sounding_count("SFX", hit), 2, "Exactly two voices of the same sound effect")


func test_a_higher_priority_sound_takes_a_slot_when_every_slot_is_busy() -> void:
	var quiet_sounds: Array[AudioStreamWAV] = []
	for i: int in range(12):
		quiet_sounds.append(_fixture_stream())
		_start_sfx(quiet_sounds[i], "amb_%d" % i, AudioManager.Priority.AMBIENT)
	var roar: AudioStreamWAV = _fixture_stream()
	_start_sfx(roar, "boss_roar", AudioManager.Priority.CUTSCENE_SFX)
	assert_true(_is_sounding("SFX", roar), "The higher-priority sound should be audible")
	var survivors: int = 0
	for sound: AudioStreamWAV in quiet_sounds:
		if _is_sounding("SFX", sound):
			survivors += 1
	assert_eq(survivors, 11, "Exactly one low-priority sound should have been dropped")


func test_a_priority_steal_drops_the_oldest_sound_of_the_lowest_rank() -> void:
	var sounds: Array[AudioStreamWAV] = []
	for i: int in range(12):
		sounds.append(_fixture_stream())
		_start_sfx(sounds[i], "exp_%d" % i, AudioManager.Priority.EXPLORATION_SFX)
	_start_sfx(_fixture_stream(), "battle_hit", AudioManager.Priority.BATTLE_SFX)
	assert_false(_is_sounding("SFX", sounds[0]), "The oldest sound should be the one dropped")
	assert_true(_is_sounding("SFX", sounds[1]), "The next-oldest sound should keep sounding")


func test_a_lower_priority_sound_is_dropped_when_every_slot_outranks_it() -> void:
	for i: int in range(12):
		_start_sfx(_fixture_stream(), "cut_%d" % i, AudioManager.Priority.CUTSCENE_SFX)
	var footstep: AudioStreamWAV = _fixture_stream()
	_start_sfx(footstep, "footstep", AudioManager.Priority.AMBIENT)
	assert_false(_is_sounding("SFX", footstep), "The lower-priority sound should never be heard")
	assert_eq(_sounding_on("SFX").size(), 12, "No cutscene sound should have been evicted")


func test_a_missing_sound_effect_asset_makes_no_sound() -> void:
	_am.play_sfx(MISSING_ID)
	assert_eq(_sounding_on("SFX").size(), 0, "Nothing should be audible for a missing asset")


func test_an_empty_sound_effect_id_makes_no_sound() -> void:
	_am.play_sfx("")
	assert_eq(_sounding_on("SFX").size(), 0, "Nothing should be audible for an empty ID")


# --- Music ---


func test_playing_music_sounds_the_track_and_reports_it() -> void:
	var theme: AudioStreamWAV = _fixture_stream()
	_start_music(theme, "town_theme")
	assert_eq(_am.get_current_music(), "town_theme", "The manager should report the new track")
	assert_true(_is_sounding("Music", theme), "The new track should be sounding")


func test_a_hard_cut_leaves_only_the_new_track_sounding() -> void:
	var old_theme: AudioStreamWAV = _fixture_stream()
	var new_theme: AudioStreamWAV = _fixture_stream()
	_start_music(old_theme, "track_a")
	_start_music(new_theme, "track_b")
	assert_eq(_am.get_current_music(), "track_b", "The manager should report the new track")
	assert_true(_is_sounding("Music", new_theme), "The new track should be sounding")
	assert_false(_is_sounding("Music", old_theme), "A zero-length cut stops the old track at once")


func test_a_crossfade_starts_the_new_track_beside_the_outgoing_one() -> void:
	# The behavior #420's assertion was reaching for: a crossfade starts the new
	# track on the OTHER player, so both sound at once instead of clicking.
	var old_theme: AudioStreamWAV = _fixture_stream()
	var new_theme: AudioStreamWAV = _fixture_stream()
	_start_music(old_theme, "track_a")
	var outgoing: AudioStreamPlayer = _player_holding("Music", old_theme)
	_am._play_music_with_stream(new_theme, "track_b", 1.0)
	var incoming: AudioStreamPlayer = _player_holding("Music", new_theme)
	assert_eq(_am.get_current_music(), "track_b", "The manager should report the new track")
	assert_not_null(incoming, "The new track should be loaded on a music player")
	assert_ne(incoming, outgoing, "The new track must not overwrite the outgoing one")
	assert_true(incoming.playing, "The new track should be sounding")
	assert_true(outgoing.playing, "The outgoing track should keep sounding through the fade")


func test_an_interrupted_crossfade_leaves_the_newest_track_sounding() -> void:
	var first: AudioStreamWAV = _fixture_stream()
	var second: AudioStreamWAV = _fixture_stream()
	var third: AudioStreamWAV = _fixture_stream()
	_am._play_music_with_stream(first, "track_a", 1.0)
	_am._play_music_with_stream(second, "track_b", 1.0)
	_am._play_music_with_stream(third, "track_c", 1.0)
	assert_eq(_am.get_current_music(), "track_c", "The newest track should be the current one")
	assert_true(_is_sounding("Music", third), "The newest track should be sounding")
	assert_true(_is_sounding("Music", second), "The track it interrupted should fade out")
	assert_false(_is_sounding("Music", first), "The twice-superseded track should be gone")


func test_replaying_the_current_track_does_not_restart_it() -> void:
	# Re-entering a town must not snap its theme back to the first bar.
	var theme: AudioStreamWAV = _fixture_stream()
	_start_music(theme, "town_theme")
	var player: AudioStreamPlayer = _player_holding("Music", theme)
	player.seek(2.0)
	_start_music(theme, "town_theme")
	assert_eq(_player_holding("Music", theme), player, "The track should stay on its player")
	assert_gte(player.get_playback_position(), 1.9, "Playback should carry on, not restart")


func test_a_missing_music_asset_leaves_the_current_track_sounding() -> void:
	var theme: AudioStreamWAV = _fixture_stream()
	_start_music(theme, "town_theme")
	_am.play_music(MISSING_ID)
	assert_eq(_am.get_current_music(), "town_theme", "The current track should be unchanged")
	assert_true(_is_sounding("Music", theme), "The current track should keep sounding")


func test_an_empty_music_id_leaves_the_current_track_sounding() -> void:
	var theme: AudioStreamWAV = _fixture_stream()
	_start_music(theme, "town_theme")
	_am.play_music("")
	assert_eq(_am.get_current_music(), "town_theme", "The current track should be unchanged")
	assert_true(_is_sounding("Music", theme), "The current track should keep sounding")


func test_stopping_music_silences_it_and_clears_the_track() -> void:
	var theme: AudioStreamWAV = _fixture_stream()
	_start_music(theme, "town_theme")
	_am.stop_music(0.0)
	assert_eq(_am.get_current_music(), "", "No track should be reported after a stop")
	assert_eq(_sounding_on("Music").size(), 0, "No music player should be sounding")


func test_stopping_music_when_nothing_plays_is_harmless() -> void:
	_am.stop_music(0.0)
	assert_eq(_am.get_current_music(), "", "No track should be reported")
	assert_eq(_sounding_on("Music").size(), 0, "No music player should be sounding")


# --- Ambient ---


func test_playing_an_ambient_bed_sounds_it_and_reports_it() -> void:
	var forest: AudioStreamWAV = _fixture_stream()
	_start_ambient(forest, "thornmere_forest")
	assert_eq(_am.get_current_ambient(), "thornmere_forest", "The manager should report the bed")
	assert_true(_is_sounding("Ambient", forest), "The ambient bed should be sounding")


func test_an_ambient_crossfade_starts_the_new_bed_beside_the_outgoing_one() -> void:
	var forest: AudioStreamWAV = _fixture_stream()
	var cave: AudioStreamWAV = _fixture_stream()
	_start_ambient(forest, "thornmere_forest")
	var outgoing: AudioStreamPlayer = _player_holding("Ambient", forest)
	_am._play_ambient_with_stream(cave, "underground_cave", 1.0)
	var incoming: AudioStreamPlayer = _player_holding("Ambient", cave)
	assert_eq(_am.get_current_ambient(), "underground_cave", "The new bed should be current")
	assert_not_null(incoming, "The new bed should be loaded on an ambient player")
	assert_ne(incoming, outgoing, "The new bed must not overwrite the outgoing one")
	assert_true(incoming.playing, "The new bed should be sounding")
	assert_true(outgoing.playing, "The outgoing bed should keep sounding through the fade")


func test_a_missing_ambient_asset_leaves_the_current_bed_sounding() -> void:
	var forest: AudioStreamWAV = _fixture_stream()
	_start_ambient(forest, "thornmere_forest")
	_am.play_ambient(MISSING_ID)
	assert_eq(_am.get_current_ambient(), "thornmere_forest", "The current bed should be unchanged")
	assert_true(_is_sounding("Ambient", forest), "The current bed should keep sounding")


func test_an_empty_ambient_id_leaves_the_current_bed_sounding() -> void:
	var forest: AudioStreamWAV = _fixture_stream()
	_start_ambient(forest, "thornmere_forest")
	_am.play_ambient("")
	assert_eq(_am.get_current_ambient(), "thornmere_forest", "The current bed should be unchanged")
	assert_true(_is_sounding("Ambient", forest), "The current bed should keep sounding")


func test_stopping_ambient_silences_it_and_clears_the_bed() -> void:
	var forest: AudioStreamWAV = _fixture_stream()
	_start_ambient(forest, "thornmere_forest")
	_am.stop_ambient(0.0)
	assert_eq(_am.get_current_ambient(), "", "No bed should be reported after a stop")
	assert_eq(_sounding_on("Ambient").size(), 0, "No ambient player should be sounding")


func test_stopping_ambient_when_nothing_plays_is_harmless() -> void:
	_am.stop_ambient(0.0)
	assert_eq(_am.get_current_ambient(), "", "No bed should be reported")
	assert_eq(_sounding_on("Ambient").size(), 0, "No ambient player should be sounding")


# --- Narrative silence ---


func test_silence_all_stops_the_music_and_the_ambient_bed() -> void:
	var theme: AudioStreamWAV = _fixture_stream()
	var forest: AudioStreamWAV = _fixture_stream()
	_start_music(theme, "town_theme")
	_start_ambient(forest, "thornmere_forest")
	_am.silence_all()
	assert_eq(_sounding_on("Music").size(), 0, "No music player should be sounding")
	assert_eq(_sounding_on("Ambient").size(), 0, "No ambient player should be sounding")
	assert_eq(_am.get_current_music(), "", "No track should be reported")
	assert_eq(_am.get_current_ambient(), "", "No bed should be reported")


func test_silence_all_stops_every_sound_effect() -> void:
	_start_sfx(_fixture_stream(), "sfx_a", AudioManager.Priority.UI_SFX)
	_start_sfx(_fixture_stream(), "sfx_b", AudioManager.Priority.UI_SFX)
	_am.silence_all()
	assert_eq(_sounding_on("SFX").size(), 0, "No sound effect should survive silence_all")


func test_silence_all_cancels_a_crossfade_so_it_cannot_fade_audio_back_up() -> void:
	# Without the cancel, the in-flight fade lifts the music back out of a
	# narrative silence a fraction of a second later.
	var old_theme: AudioStreamWAV = _fixture_stream()
	var new_theme: AudioStreamWAV = _fixture_stream()
	_start_music(old_theme, "track_a")
	var pre_existing: Array = get_tree().get_processed_tweens()
	_am._play_music_with_stream(new_theme, "track_b", 3.0)
	var crossfade_tweens: Array[Tween] = []
	for tween: Tween in get_tree().get_processed_tweens():
		if not pre_existing.has(tween):
			crossfade_tweens.append(tween)
	assert_gt(crossfade_tweens.size(), 0, "A crossfade should start at least one fade")
	_am.silence_all()
	for tween: Tween in crossfade_tweens:
		assert_false(tween.is_valid(), "Every crossfade must be canceled by silence_all")
	assert_eq(_sounding_on("Music").size(), 0, "No music player should be sounding")


func test_silence_all_twice_stays_silent() -> void:
	_start_music(_fixture_stream(), "town_theme")
	_am.silence_all()
	_am.silence_all()
	assert_eq(_am.get_current_music(), "", "No track should be reported")
	assert_eq(_sounding_on("Music").size(), 0, "No music player should be sounding")


func test_sound_effects_play_again_after_a_narrative_silence() -> void:
	_start_sfx(_fixture_stream(), "first", AudioManager.Priority.UI_SFX)
	_am.silence_all()
	var second: AudioStreamWAV = _fixture_stream()
	_start_sfx(second, "second", AudioManager.Priority.UI_SFX)
	assert_true(_is_sounding("SFX", second), "A new sound effect should be audible again")


# --- The mix: how loud each channel sits in each place (audio.md 2.2) ---


func test_a_fresh_manager_mixes_music_over_ambient() -> void:
	_am.update_volumes()
	assert_lt(_bus_db("Ambient"), _bus_db("Music") - 5.0, "Ambient should sit under the music")
	assert_gt(_bus_db("Ambient"), INAUDIBLE_DB, "Ambient should still be audible")


func test_battle_ducks_the_ambient_bed_to_silence() -> void:
	_am.set_mix_context("battle")
	assert_lte(_bus_db("Ambient"), INAUDIBLE_DB, "Ambient should be silent in battle")
	assert_gt(_bus_db("Music"), INAUDIBLE_DB, "Battle music should be audible")


func test_the_pallor_mutes_the_music_and_keeps_the_ambient_bed() -> void:
	_am.set_mix_context("pallor")
	assert_lte(_bus_db("Music"), INAUDIBLE_DB, "Music should be silent in the Pallor")
	assert_gt(_bus_db("Ambient"), INAUDIBLE_DB, "The ambient drone should be audible")


func test_a_dungeon_lifts_the_ambient_bed_above_the_music() -> void:
	_am.set_mix_context("dungeon")
	assert_gt(_bus_db("Ambient"), _bus_db("Music"), "A dungeon should be led by its ambience")


func test_a_town_ducks_the_ambient_bed_further_than_the_overworld() -> void:
	_am.set_mix_context("overworld")
	var overworld_ambient: float = _bus_db("Ambient")
	_am.set_mix_context("town")
	assert_lt(_bus_db("Ambient"), overworld_ambient, "A town should sit quieter under its music")
	assert_gt(_bus_db("Ambient"), INAUDIBLE_DB, "Town ambience should still be audible")


func test_narrative_dungeons_and_cutscenes_mix_like_the_overworld() -> void:
	_am.set_mix_context("overworld")
	var overworld_music: float = _bus_db("Music")
	var overworld_ambient: float = _bus_db("Ambient")
	for context: String in ["narrative_dungeon", "cutscene"]:
		_am.set_mix_context(context)
		assert_almost_eq(_bus_db("Music"), overworld_music, 0.01, "%s music level" % context)
		assert_almost_eq(_bus_db("Ambient"), overworld_ambient, 0.01, "%s ambient level" % context)


func test_an_unknown_mix_context_leaves_the_mix_alone() -> void:
	_am.set_mix_context("battle")
	var music_level: float = _bus_db("Music")
	var ambient_level: float = _bus_db("Ambient")
	_am.set_mix_context("nonexistent")
	assert_almost_eq(_bus_db("Music"), music_level, 0.01, "Music level should be untouched")
	assert_almost_eq(_bus_db("Ambient"), ambient_level, 0.01, "Ambient level should be untouched")


func test_lowering_the_music_slider_quiets_the_music_channel() -> void:
	PartyState.set_config("music_volume", 8.0)
	_am.update_volumes()
	var loud: float = _bus_db("Music")
	PartyState.set_config("music_volume", 2.0)
	_am.update_volumes()
	assert_lt(_bus_db("Music"), loud - 5.0, "The music channel should follow the player's slider")


# --- Battle transitions ---


func test_entering_battle_cuts_to_the_battle_track_and_kills_the_ambient_bed() -> void:
	var theme: AudioStreamWAV = _fixture_stream()
	var highlands: AudioStreamWAV = _fixture_stream()
	_start_music(theme, REAL_MUSIC)
	_start_ambient(highlands, REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	assert_eq(_am.get_current_music(), REAL_BATTLE, "The battle track should be current")
	assert_false(_is_sounding("Music", theme), "The exploration track should be cut, not faded")
	# The reported track is only a label; what the player hears is the battle
	# stream loaded onto a music player at full volume. Asserted through the
	# stream rather than `playing` because battle_standard.ogg is a 0.1-second
	# placeholder that would end before the next statement runs.
	var battle_stream: AudioStream = load("res://assets/music/%s.ogg" % REAL_BATTLE)
	var battle_player: AudioStreamPlayer = _player_holding("Music", battle_stream)
	assert_not_null(battle_player, "The battle track should be on a music player")
	if battle_player != null:
		assert_gt(
			battle_player.volume_db, INAUDIBLE_DB, "The battle track should be at full volume"
		)
	assert_gt(_bus_db("Music"), INAUDIBLE_DB, "The music channel should carry the battle track")
	assert_eq(_sounding_on("Ambient").size(), 0, "The ambient bed should be silenced")
	assert_lte(_bus_db("Ambient"), INAUDIBLE_DB, "The battle mix should duck ambient to silence")


func test_entering_battle_remembers_the_exploration_audio_to_resume() -> void:
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	assert_eq(_am.get_pre_battle_music(), REAL_MUSIC, "The exploration track should be remembered")
	assert_eq(_am.get_pre_battle_ambient(), REAL_AMBIENT, "The ambient bed should be remembered")


func test_entering_battle_with_no_track_still_silences_and_remembers() -> void:
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle("")
	assert_eq(_sounding_on("Music").size(), 0, "Exploration music should not play into a battle")
	assert_eq(_sounding_on("Ambient").size(), 0, "The ambient bed should not play into a battle")
	assert_lte(_bus_db("Ambient"), INAUDIBLE_DB, "The battle mix should still be applied")
	assert_eq(_am.get_pre_battle_music(), REAL_MUSIC, "The exploration track should be remembered")
	assert_eq(_am.get_pre_battle_ambient(), REAL_AMBIENT, "The ambient bed should be remembered")


func test_entering_battle_with_a_missing_track_still_silences_and_remembers() -> void:
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(MISSING_ID)
	assert_eq(_sounding_on("Music").size(), 0, "Exploration music should not play into a battle")
	assert_eq(_sounding_on("Ambient").size(), 0, "The ambient bed should not play into a battle")
	assert_lte(_bus_db("Ambient"), INAUDIBLE_DB, "The battle mix should still be applied")
	assert_eq(_am.get_pre_battle_music(), REAL_MUSIC, "The exploration track should be remembered")
	assert_eq(_am.get_pre_battle_ambient(), REAL_AMBIENT, "The ambient bed should be remembered")


func test_a_second_battle_keeps_the_original_exploration_audio_to_resume() -> void:
	# A boss phase change enters battle again; what resumes afterwards is still
	# the exploration track, not the battle track it replaced.
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	_am.enter_battle(REAL_BOSS)
	assert_eq(_am.get_current_music(), REAL_BOSS, "The boss track should be current")
	assert_eq(_am.get_pre_battle_music(), REAL_MUSIC, "The exploration track should survive")
	assert_eq(_am.get_pre_battle_ambient(), REAL_AMBIENT, "The ambient bed should survive")


func test_leaving_battle_restores_the_exploration_tracks() -> void:
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	_am.exit_battle(_am.get_pre_battle_music(), _am.get_pre_battle_ambient())
	assert_eq(_am.get_current_music(), REAL_MUSIC, "The exploration track should be current again")
	assert_eq(_am.get_current_ambient(), REAL_AMBIENT, "The ambient bed should be current again")
	var restored: AudioStream = load("res://assets/music/%s.ogg" % REAL_MUSIC)
	assert_not_null(_player_holding("Music", restored), "The track should be back on a player")


func test_leaving_battle_restores_the_mix_of_the_place_you_were_in() -> void:
	_am.set_mix_context("dungeon")
	var dungeon_ambient: float = _bus_db("Ambient")
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	assert_lte(_bus_db("Ambient"), INAUDIBLE_DB, "The battle mix should duck ambient")
	_am.exit_battle(REAL_MUSIC, REAL_AMBIENT)
	assert_almost_eq(_bus_db("Ambient"), dungeon_ambient, 0.01, "The dungeon mix should be back")


func test_leaving_battle_with_no_tracks_reports_no_music_or_ambient() -> void:
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	_am.exit_battle("", "")
	assert_eq(_am.get_current_music(), "", "No track should be reported")
	assert_eq(_am.get_current_ambient(), "", "No bed should be reported")


func test_leaving_battle_forgets_the_audio_it_resumed() -> void:
	_start_music(_fixture_stream(), REAL_MUSIC)
	_start_ambient(_fixture_stream(), REAL_AMBIENT)
	_am.enter_battle(REAL_BATTLE)
	_am.exit_battle(REAL_MUSIC, REAL_AMBIENT)
	assert_eq(_am.get_pre_battle_music(), "", "The snapshot should not survive the restore")
	assert_eq(_am.get_pre_battle_ambient(), "", "The snapshot should not survive the restore")


func test_leaving_battle_twice_still_lands_in_the_overworld_mix() -> void:
	_am.set_mix_context("overworld")
	var overworld_ambient: float = _bus_db("Ambient")
	_am.set_mix_context("dungeon")
	_start_music(_fixture_stream(), REAL_MUSIC)
	_am.enter_battle(REAL_BATTLE)
	_am.exit_battle(REAL_MUSIC, REAL_AMBIENT)
	_am.exit_battle(REAL_MUSIC, REAL_AMBIENT)
	assert_almost_eq(
		_bus_db("Ambient"), overworld_ambient, 0.01, "A stale snapshot must not break the mix"
	)
