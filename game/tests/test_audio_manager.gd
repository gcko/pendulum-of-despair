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
