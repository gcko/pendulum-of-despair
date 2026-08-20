extends AudioManagerTestBase
## Behavior tests for the whole soundscape at once: a narrative silence that
## stops everything, the per-place mix that decides how loud each channel sits,
## and the battle transitions that swap both and put them back.
##
## The fixtures, the observation helpers, and the reasoning behind both live in
## audio_manager_test_base.gd — read that header before adding a test here. What
## an individual channel plays is tested in test_audio_manager.gd.

## Real placeholder assets on disk, for the tests that drive the public ID path.
const REAL_MUSIC: String = "overworld_act_i"
const REAL_BATTLE: String = "battle_standard"
const REAL_BOSS: String = "battle_boss"
const REAL_AMBIENT: String = "valdris_highlands"

## Bus level at or below which a channel is inaudible.
const INAUDIBLE_DB: float = -60.0

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
