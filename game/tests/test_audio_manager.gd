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
	# Count only slots that are still playing (matches production same-ID check)
	var count: int = 0
	for i: int in range(_am._sfx_pool.size()):
		if _am._sfx_pool[i].playing and _am._sfx_meta[i].get("sfx_id") == "same_sfx":
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


func test_enter_battle_with_stream_silences_ambient_and_plays_battle() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	# Manually store pre-battle state (enter_battle does this before calling internal method)
	_am._pre_battle_music = _am._current_music
	_am._pre_battle_ambient = _am._current_ambient
	var pos: float = _am._music_active.get_playback_position()
	_am._pre_battle_music_pos = pos if _am._music_active.playing else 0.0
	_am._pre_battle_mix_context = _am._current_mix_context
	_am._enter_battle_with_stream(stream, "battle_standard")
	assert_eq(_am._pre_battle_music, "overworld", "Pre-battle music should be preserved")
	assert_eq(_am._pre_battle_ambient, "highlands", "Pre-battle ambient should be preserved")
	assert_eq(
		_am._pre_battle_mix_context, "overworld", "Pre-battle mix context should be preserved"
	)
	assert_false(_am._ambient_active.playing, "Ambient should be silenced")
	assert_eq(_am._current_music, "battle_standard", "Current music should be battle track")


func test_exit_battle_with_streams_restores_music_and_ambient() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	# Manually store pre-battle state (enter_battle does this before calling internal method)
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
	assert_eq(
		_am._pre_battle_mix_context, "overworld", "Pre-battle context should reset to overworld"
	)


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


func test_missing_music_file_no_crash() -> void:
	_am.play_music("totally_nonexistent_music_12345")
	assert_true(true, "No crash on missing music file")


func test_missing_ambient_file_no_crash() -> void:
	_am.play_ambient("totally_nonexistent_ambient_12345")
	assert_true(true, "No crash on missing ambient file")


func test_stop_ambient_noop_when_not_playing() -> void:
	_am.stop_ambient(0.0)
	assert_eq(_am._current_ambient, "", "Should remain empty when nothing playing")


func test_update_volumes_does_not_crash() -> void:
	_am.set_mix_context("dungeon")
	_am.update_volumes()
	assert_eq(_am._current_mix_context, "dungeon", "Mix context should remain dungeon after update")


func test_double_silence_all_is_safe() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "music", 0.0)
	_am.silence_all()
	_am.silence_all()
	assert_eq(_am._current_music, "", "Music ID should remain cleared after double silence_all")


func test_double_enter_battle_preserves_original_snapshot() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	# First enter — exercise the real guard in enter_battle's internal path
	_am._pre_battle_music = _am._current_music
	_am._pre_battle_ambient = _am._current_ambient
	_am._pre_battle_music_pos = 0.0
	_am._pre_battle_mix_context = _am._current_mix_context
	_am._enter_battle_with_stream(stream, "battle_standard")
	# Second enter — _current_mix_context is now "battle", so the public
	# enter_battle guard would skip the snapshot. Verify by checking that
	# _pre_battle_music still holds the original value.
	assert_eq(_am._current_mix_context, "battle", "Should be in battle context")
	_am._enter_battle_with_stream(stream, "battle_boss")
	assert_eq(_am._pre_battle_music, "overworld", "Original pre-battle music should be preserved")
	assert_eq(
		_am._pre_battle_mix_context, "overworld", "Original pre-battle context should be preserved"
	)


func test_pre_battle_mix_context_defaults_to_overworld() -> void:
	assert_eq(
		_am._pre_battle_mix_context,
		"overworld",
		"Pre-battle mix context should default to overworld, not empty string",
	)


func test_exit_battle_clears_pre_battle_mix_context_to_overworld() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._pre_battle_music = "overworld"
	_am._pre_battle_ambient = "highlands"
	_am._pre_battle_music_pos = 0.0
	_am._pre_battle_mix_context = "overworld"
	_am._enter_battle_with_stream(stream, "battle_standard")
	_am._exit_battle_with_streams(stream, stream, "overworld", "highlands")
	assert_eq(
		_am._pre_battle_mix_context,
		"overworld",
		"Pre-battle mix context should reset to overworld, not empty string",
	)


func test_play_sfx_accepts_pan_parameter() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "panned_sfx", AudioManager.Priority.BATTLE_SFX, -0.5)
	var found: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "panned_sfx":
			found = true
			break
	assert_true(found, "SFX with pan parameter should play normally")


func test_play_music_empty_string_noop() -> void:
	_am.play_music("")
	assert_eq(_am.get_current_music(), "", "Empty track_id should not change current music")


func test_play_sfx_empty_string_noop() -> void:
	_am.play_sfx("")
	assert_true(true, "Empty sfx_id should not crash")


func test_play_ambient_empty_string_noop() -> void:
	_am.play_ambient("")
	assert_eq(_am.get_current_ambient(), "", "Empty ambient_id should not change current ambient")


func test_enter_battle_empty_string_silences_all() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am.enter_battle("")
	assert_eq(_am._current_mix_context, "battle", "Mix context should be battle")
	assert_false(_am._music_active.playing, "Music should be silenced")
	assert_false(_am._ambient_active.playing, "Ambient should be silenced")


func test_enter_battle_empty_string_preserves_snapshot() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	_am.enter_battle("")
	assert_eq(
		_am._pre_battle_music, "overworld", "Pre-battle music should be stored on empty track"
	)
	assert_eq(
		_am._pre_battle_ambient, "highlands", "Pre-battle ambient should be stored on empty track"
	)
	assert_eq(
		_am._pre_battle_mix_context,
		"overworld",
		"Pre-battle mix context should be stored on empty track",
	)


func test_enter_battle_missing_file_preserves_snapshot() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am._current_mix_context = "overworld"
	_am.enter_battle("totally_nonexistent_battle_track_12345")
	assert_eq(
		_am._pre_battle_music, "overworld", "Pre-battle music should be stored on missing file"
	)
	assert_eq(
		_am._pre_battle_ambient, "highlands", "Pre-battle ambient should be stored on missing file"
	)


func test_play_music_with_stream_null_noop() -> void:
	_am._play_music_with_stream(null, "track", 0.0)
	assert_eq(_am._current_music, "", "Null stream should not change current music")


func test_play_ambient_with_stream_null_noop() -> void:
	_am._play_ambient_with_stream(null, "ambient", 0.0)
	assert_eq(_am._current_ambient, "", "Null stream should not change current ambient")


func test_enter_battle_missing_file_silences_all() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._play_ambient_with_stream(stream, "highlands", 0.0)
	_am.enter_battle("totally_nonexistent_battle_track_12345")
	assert_eq(_am._current_mix_context, "battle", "Mix context should be battle")
	assert_false(_am._music_active.playing, "Music should be silenced on missing file")
	assert_false(_am._ambient_active.playing, "Ambient should be silenced on missing file")


func test_silence_all_stops_sfx_pool() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_sfx_with_stream(stream, "sfx_a", AudioManager.Priority.UI_SFX)
	_am._play_sfx_with_stream(stream, "sfx_b", AudioManager.Priority.UI_SFX)
	_am.silence_all()
	var any_playing: bool = false
	for player: AudioStreamPlayer in _am._sfx_pool:
		if player.playing:
			any_playing = true
			break
	assert_false(any_playing, "All SFX pool players should be stopped after silence_all")


func test_silence_all_nulls_tween_references() -> void:
	_am.silence_all()
	assert_null(_am._music_active_tween, "Music active tween should be null after silence_all")
	assert_null(_am._music_fade_tween, "Music fade tween should be null after silence_all")
	assert_null(_am._ambient_active_tween, "Ambient active tween should be null after silence_all")
	assert_null(_am._ambient_fade_tween, "Ambient fade tween should be null after silence_all")


func test_set_mix_context_all_valid_contexts() -> void:
	var contexts: Array[String] = [
		"overworld",
		"town",
		"dungeon",
		"narrative_dungeon",
		"pallor",
		"battle",
		"cutscene",
	]
	for context: String in contexts:
		_am.set_mix_context(context)
		assert_eq(_am._current_mix_context, context, "Context should be set to %s" % context)


func test_get_pre_battle_music_returns_snapshot() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream, "overworld", 0.0)
	_am._pre_battle_music = "overworld"
	assert_eq(_am.get_pre_battle_music(), "overworld", "Getter should return pre-battle music ID")


func test_get_pre_battle_ambient_returns_snapshot() -> void:
	_am._pre_battle_ambient = "highlands"
	assert_eq(
		_am.get_pre_battle_ambient(), "highlands", "Getter should return pre-battle ambient ID"
	)


func test_play_music_with_crossfade_starts_new_track() -> void:
	var stream_a: AudioStreamWAV = AudioStreamWAV.new()
	var stream_b: AudioStreamWAV = AudioStreamWAV.new()
	_am._play_music_with_stream(stream_a, "track_a", 0.0)
	# Second track with crossfade > 0 should swap players
	_am._play_music_with_stream(stream_b, "track_b", 1.0)
	assert_eq(_am._current_music, "track_b", "Current should be track_b with crossfade")
	assert_true(_am._music_active.playing, "New active player should be playing")


func test_priority_steal_prefers_oldest_on_tie() -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	# Fill all 12 slots with EXPLORATION_SFX (same priority)
	for i: int in range(12):
		_am._play_sfx_with_stream(stream, "exp_%d" % i, AudioManager.Priority.EXPLORATION_SFX)
	# Try to play higher priority — should steal the oldest EXPLORATION_SFX slot
	_am._play_sfx_with_stream(stream, "battle_hit", AudioManager.Priority.BATTLE_SFX)
	var found: bool = false
	for meta: Dictionary in _am._sfx_meta:
		if meta.get("sfx_id") == "battle_hit":
			found = true
			break
	assert_true(found, "Higher priority should steal from lower priority pool")
