extends AudioManagerTestBase
## Behavior tests for what each AudioManager channel plays: sound effects, the
## music track, and the ambient bed.
##
## The fixtures, the observation helpers, and the reasoning behind both live in
## audio_manager_test_base.gd — read that header before adding a test here. The
## soundscape-level behavior (a narrative silence, the per-place mix, and the
## battle transitions that swap both) lives in test_audio_manager_mix.gd.

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
