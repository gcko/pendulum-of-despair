extends GutTest
## Tests for AudioManager audio system.

var _am: Node


func before_each() -> void:
	_am = preload("res://scripts/autoload/audio_manager.gd").new()
	add_child_autofree(_am)


func after_each() -> void:
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
	_am._play_sfx_with_stream(stream, "test_sfx", AudioManager.Priority.UI_SFX, 0.0)
	var occupied: int = 0
	for player: AudioStreamPlayer in _am._sfx_pool:
		if player.playing:
			occupied += 1
	assert_eq(occupied, 1, "One pool slot should be occupied")


func test_same_id_limit_blocks_third_instance() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "same_sfx", AudioManager.Priority.UI_SFX, 0.0)
	_am._play_sfx_with_stream(stream, "same_sfx", AudioManager.Priority.UI_SFX, 0.0)
	_am._play_sfx_with_stream(stream, "same_sfx", AudioManager.Priority.UI_SFX, 0.0)
	var count: int = 0
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "same_sfx":
			count += 1
	assert_le(count, 2, "Max 2 instances of the same SFX ID")


func test_priority_steal_replaces_lowest() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	for i: int in range(12):
		_am._play_sfx_with_stream(stream, "low_%d" % i, AudioManager.Priority.AMBIENT, 0.0)
	_am._play_sfx_with_stream(stream, "high", AudioManager.Priority.CUTSCENE_SFX, 0.0)
	var found_high: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "high":
			found_high = true
			break
	assert_true(found_high, "High-priority SFX should steal a slot")


func test_priority_steal_rejected_when_all_higher() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	for i: int in range(12):
		_am._play_sfx_with_stream(stream, "top_%d" % i, AudioManager.Priority.CUTSCENE_SFX, 0.0)
	_am._play_sfx_with_stream(stream, "rejected", AudioManager.Priority.AMBIENT, 0.0)
	var found: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "rejected":
			found = true
			break
	assert_false(found, "Low-priority SFX should be rejected when pool is full of higher priority")


func test_missing_sfx_file_no_crash() -> void:
	_am.play_sfx("totally_nonexistent_sfx_id_12345")
	assert_true(true, "No crash on missing SFX file")


func test_pan_stored_in_meta() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "panned", AudioManager.Priority.UI_SFX, -0.75)
	var found_pan: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "panned":
			assert_almost_eq(meta.get("pan", 0.0), -0.75, 0.01, "Pan should be stored")
			found_pan = true
			break
	assert_true(found_pan, "Should find the panned SFX in meta")


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
	_am._play_sfx_with_stream(stream, "sfx", AudioManager.Priority.UI_SFX, 0.0)
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
	_am._enter_battle_with_stream(stream, "battle_standard")
	_am._exit_battle_with_streams(stream, stream, "overworld", "highlands")
	assert_eq(_am._current_music, "overworld", "Music should be restored")
	assert_eq(_am._current_ambient, "highlands", "Ambient should be restored")
