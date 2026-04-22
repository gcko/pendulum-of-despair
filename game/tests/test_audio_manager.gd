extends GutTest
## Tests for AudioManager audio system.

var _am: Node


func before_each() -> void:
	_am = preload("res://scripts/autoload/audio_manager.gd").new()
	add_child_autofree(_am)


func after_each() -> void:
	# Reset AudioServer bus volumes to avoid leaking state across tests
	for bus_name: String in ["Music", "SFX", "Ambient"]:
		var idx: int = AudioServer.get_bus_index(bus_name)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, 0.0)
	_am = null


func test_creates_16_audio_stream_players() -> void:
	var count: int = 0
	for child: Node in _am.get_children():
		if child is AudioStreamPlayer:
			count += 1
	assert_eq(count, 16, "Should create 16 AudioStreamPlayer children")


func test_music_bus_exists() -> void:
	var idx: int = AudioServer.get_bus_index("Music")
	assert_ne(idx, -1, "Music bus should exist")


func test_sfx_bus_exists() -> void:
	var idx: int = AudioServer.get_bus_index("SFX")
	assert_ne(idx, -1, "SFX bus should exist")


func test_ambient_bus_exists() -> void:
	var idx: int = AudioServer.get_bus_index("Ambient")
	assert_ne(idx, -1, "Ambient bus should exist")


func test_play_sfx_occupies_pool_slot() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "test_sfx", AudioManager.Priority.UI_SFX)
	var occupied: int = 0
	for player: AudioStreamPlayer in _am._sfx_pool:
		if player.playing:
			occupied += 1
	assert_eq(occupied, 1, "One pool slot should be occupied")


func test_same_id_limit_blocks_third_instance() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "same_sfx", AudioManager.Priority.UI_SFX)
	_am._play_sfx_with_stream(stream, "same_sfx", AudioManager.Priority.UI_SFX)
	_am._play_sfx_with_stream(stream, "same_sfx", AudioManager.Priority.UI_SFX)
	var count: int = 0
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "same_sfx":
			count += 1
	assert_le(count, 2, "Max 2 instances of the same SFX ID")


func test_priority_steal_replaces_lowest() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	for i: int in range(12):
		_am._play_sfx_with_stream(stream, "low_%d" % i, AudioManager.Priority.AMBIENT)
	_am._play_sfx_with_stream(stream, "high", AudioManager.Priority.CUTSCENE_SFX)
	var found_high: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "high":
			found_high = true
			break
	assert_true(found_high, "High-priority SFX should steal a slot")


func test_priority_steal_rejected_when_all_higher() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	for i: int in range(12):
		_am._play_sfx_with_stream(stream, "top_%d" % i, AudioManager.Priority.CUTSCENE_SFX)
	_am._play_sfx_with_stream(stream, "rejected", AudioManager.Priority.AMBIENT)
	var found: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "rejected":
			found = true
			break
	assert_false(found, "Low-priority SFX should be rejected when pool is full of higher priority")


func test_missing_sfx_file_no_crash() -> void:
	_am.play_sfx("totally_nonexistent_sfx_id_12345")
	assert_true(true, "No crash on missing SFX file")


func test_play_music_sets_current_track() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "track_a", 0.0)
	assert_eq(_am._current_music, "track_a", "Current music should be track_a")


func test_play_music_same_track_no_restart() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "track_a", 0.0)
	_am._music_active.volume_db = -10.0
	_am._play_music_with_stream(stream, "track_a", 0.0)
	assert_almost_eq(_am._music_active.volume_db, -10.0, 0.01, "Same track should not restart")


func test_play_music_crossfade_swaps_to_fade() -> void:
	var stream_a: AudioStreamWAV = AudioStreamWAV.new()
	var stream_b: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream_a, "track_a", 0.0)
	_am._play_music_with_stream(stream_b, "track_b", 0.0)
	assert_eq(_am._current_music, "track_b", "Current should be track_b")
	assert_eq(_am._music_fade.stream, stream_a, "Fade slot should hold track_a's stream")


func test_play_ambient_sets_current_track() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_ambient_with_stream(stream, "forest", 0.0)
	assert_eq(_am._current_ambient, "forest", "Current ambient should be forest")


func test_play_ambient_crossfade_swaps() -> void:
	var stream_a: AudioStreamWAV = AudioStreamWAV.new()
	var stream_b: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_ambient_with_stream(stream_a, "forest", 0.0)
	_am._play_ambient_with_stream(stream_b, "cave", 0.0)
	assert_eq(_am._current_ambient, "cave", "Current should be cave")
	assert_eq(_am._ambient_fade.stream, stream_a, "Fade slot should hold forest stream")


func test_set_mix_context_battle() -> void:
	_am.set_mix_context("battle")
	var ambient_idx: int = AudioServer.get_bus_index("Ambient")
	var ambient_db: float = AudioServer.get_bus_volume_db(ambient_idx)
	assert_le(ambient_db, -60.0, "Ambient bus should be near-silent in battle context")
	assert_eq(_am._current_mix_context, "battle", "Mix context should be stored")


func test_silence_all_stops_everything() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "music", 0.0)
	_am._play_ambient_with_stream(stream, "ambient", 0.0)
	_am._play_sfx_with_stream(stream, "sfx", AudioManager.Priority.UI_SFX)
	_am.silence_all()
	assert_false(_am._music_active.playing, "Music should be stopped")
	assert_false(_am._ambient_active.playing, "Ambient should be stopped")
	assert_eq(_am._current_music, "", "Music ID should be cleared")
	assert_eq(_am._current_ambient, "", "Ambient ID should be cleared")


func test_enter_battle_stores_pre_battle_state() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	# Store pre-battle state as enter_battle() would before calling internal method
	_am._pre_battle_music = _am._current_music
	_am._pre_battle_ambient = _am._current_ambient
	var pos: float = _am._music_active.get_playback_position()
	_am._pre_battle_music_pos = pos if _am._music_active.playing else 0.0
	_am._pre_battle_mix_context = _am._current_mix_context
	_am._enter_battle_with_stream(stream, "battle_standard")
	assert_eq(_am._pre_battle_music, "overworld", "Should store pre-battle music")
	assert_eq(_am._pre_battle_ambient, "highlands", "Should store pre-battle ambient")
	assert_eq(_am._pre_battle_mix_context, "overworld", "Should store pre-battle mix context")
	assert_false(_am._ambient_active.playing, "Ambient should be silenced")
	assert_eq(_am._current_music, "battle_standard", "Current music should be battle track")


func test_exit_battle_restores_state() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	# Store pre-battle state as enter_battle() would
	_am._pre_battle_music = _am._current_music
	_am._pre_battle_ambient = _am._current_ambient
	var pos: float = _am._music_active.get_playback_position()
	_am._pre_battle_music_pos = pos if _am._music_active.playing else 0.0
	_am._pre_battle_mix_context = _am._current_mix_context
	_am._enter_battle_with_stream(stream, "battle_standard")
	_am._exit_battle_with_streams(stream, stream, "overworld", "highlands")
	assert_eq(_am._current_music, "overworld", "Music should be restored")
	assert_eq(_am._current_ambient, "highlands", "Ambient should be restored")


func test_stop_music_clears_current_track() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "track_a", 0.0)
	assert_eq(_am._current_music, "track_a")
	_am.stop_music(0.0)
	assert_eq(_am._current_music, "", "Current music should be cleared after stop")
	assert_false(_am._music_active.playing, "Music player should be stopped")


func test_stop_music_noop_when_not_playing() -> void:
	_am.stop_music(0.0)
	assert_eq(_am._current_music, "", "Should remain empty when nothing playing")


func test_stop_ambient_clears_current_track() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_ambient_with_stream(stream, "forest", 0.0)
	assert_eq(_am._current_ambient, "forest")
	_am.stop_ambient(0.0)
	assert_eq(_am._current_ambient, "", "Current ambient should be cleared after stop")
	assert_false(_am._ambient_active.playing, "Ambient player should be stopped")


func test_silence_all_then_play_sfx_works() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "first", AudioManager.Priority.UI_SFX)
	_am.silence_all()
	_am._play_sfx_with_stream(stream, "second", AudioManager.Priority.UI_SFX)
	var found: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "second":
			found = true
			break
	assert_true(found, "SFX should play after silence_all")


func test_exit_battle_with_null_streams_clears_ids() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._pre_battle_music = _am._current_music
	_am._pre_battle_ambient = _am._current_ambient
	_am._pre_battle_music_pos = 0.0
	_am._pre_battle_mix_context = "overworld"
	_am._enter_battle_with_stream(stream, "battle_standard")
	_am._exit_battle_with_streams(null, null, "overworld", "highlands")
	assert_eq(_am._current_music, "", "Music ID should be empty when stream is null")
	assert_eq(_am._current_ambient, "", "Ambient ID should be empty when stream is null")


func test_exit_battle_clears_pre_battle_state() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._pre_battle_music = "overworld"
	_am._pre_battle_ambient = "highlands"
	_am._pre_battle_music_pos = 5.0
	_am._pre_battle_mix_context = "overworld"
	_am._enter_battle_with_stream(stream, "battle_standard")
	_am._exit_battle_with_streams(stream, stream, "overworld", "highlands")
	assert_eq(_am._pre_battle_music, "", "Pre-battle music should be cleared")
	assert_eq(_am._pre_battle_ambient, "", "Pre-battle ambient should be cleared")
	assert_almost_eq(_am._pre_battle_music_pos, 0.0, 0.01, "Pre-battle pos should be cleared")
	assert_eq(_am._pre_battle_mix_context, "", "Pre-battle context should be cleared")


func test_get_current_music_returns_track_id() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "my_track", 0.0)
	assert_eq(_am.get_current_music(), "my_track", "Getter should return current music ID")


func test_get_current_ambient_returns_track_id() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_ambient_with_stream(stream, "my_ambient", 0.0)
	assert_eq(_am.get_current_ambient(), "my_ambient", "Getter should return current ambient ID")


func test_set_mix_context_unknown_rejected() -> void:
	_am.set_mix_context("nonexistent")
	assert_eq(
		_am._current_mix_context, "overworld", "Unknown context should not change stored value"
	)


func test_default_mix_context_is_overworld() -> void:
	assert_eq(_am._current_mix_context, "overworld", "Default mix context should be overworld")
