extends GutTest
## Tests for player position persistence (#269).
##
## Saves used to write a hardcoded current_position of (0,0), so loading always
## dropped the party at the map origin. These cover the round trip, the
## "no position recorded" fallback, and the v1 -> v2 migration that strips the
## fabricated origin from old saves.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")
const TEST_SLOT: int = 1


func before_each() -> void:
	TestHelpers.reset_game_state()
	SaveManager.delete_slot(TEST_SLOT)


func after_each() -> void:
	SaveManager.delete_slot(TEST_SLOT)
	TestHelpers.reset_game_state()


## World block of a save dict. Fails the calling test when the save has none,
## so an assertion can never pass by inspecting an empty dictionary.
func _world_of(save_data: Dictionary) -> Dictionary:
	var world: Variant = save_data.get("world", null)
	if not world is Dictionary or (world as Dictionary).is_empty():
		fail_test("save data has no world block")
		return {}
	return world as Dictionary


## Position stored in a save dict. Fails the calling test when the save stores
## none — "absent" is a separate outcome that its own tests assert directly.
func _position_of(save_data: Dictionary) -> Vector2i:
	var world: Dictionary = _world_of(save_data)
	if not Helpers.has_saved_position(world):
		fail_test("save data has no stored position")
		return Vector2i(-1, -1)
	return Helpers.saved_position(world)


# --- Round trip ---


func test_position_round_trips_through_save_and_load() -> void:
	PartyState.initialize_new_game()
	PartyState.set_player_location("dungeons/ember_vein_f1", Vector2i(144, 72))
	var save_data: Dictionary = PartyState.build_save_data()
	assert_eq(_position_of(save_data), Vector2i(144, 72), "save stores the recorded position")
	assert_eq(
		_world_of(save_data).get("current_location", ""),
		"dungeons/ember_vein_f1",
		"save stores the map the position belongs to",
	)

	PartyState.clear_player_location()
	PartyState.load_from_save(save_data)
	assert_true(PartyState.has_player_position, "load should restore a recorded position")
	assert_eq(PartyState.player_position, Vector2i(144, 72), "position should survive the trip")
	assert_eq(PartyState.location_name, "dungeons/ember_vein_f1", "map survives the trip")


func test_position_survives_two_save_load_cycles() -> void:
	PartyState.initialize_new_game()
	PartyState.set_player_location("test_room", Vector2i(48, 96))
	PartyState.load_from_save(PartyState.build_save_data())
	assert_eq(
		_position_of(PartyState.build_save_data()),
		Vector2i(48, 96),
		"re-saving a loaded save must not lose the position",
	)


# --- No recorded position ---


func test_save_omits_position_when_none_recorded() -> void:
	PartyState.initialize_new_game()
	assert_false(
		_world_of(PartyState.build_save_data()).has("current_position"),
		"a save with no recorded position must not invent one",
	)


func test_load_without_position_records_none() -> void:
	PartyState.initialize_new_game()
	PartyState.set_player_location("test_room", Vector2i(64, 64))
	var save_data: Dictionary = PartyState.build_save_data()
	_world_of(save_data).erase("current_position")
	PartyState.load_from_save(save_data)
	assert_false(
		PartyState.has_player_position,
		"a save without a position must not be read as being at the origin",
	)


func test_new_game_clears_recorded_position() -> void:
	PartyState.set_player_location("test_room", Vector2i(32, 32))
	PartyState.initialize_new_game()
	assert_false(PartyState.has_player_position, "a new game starts with no position")


func test_origin_is_a_real_position_when_recorded() -> void:
	PartyState.initialize_new_game()
	PartyState.set_player_location("test_room", Vector2i.ZERO)
	assert_eq(
		_position_of(PartyState.build_save_data()),
		Vector2i.ZERO,
		"a genuinely recorded origin must still be written",
	)


# --- Helpers ---


func test_has_saved_position_rejects_missing_and_partial() -> void:
	assert_false(Helpers.has_saved_position({}), "no key means no position")
	assert_false(Helpers.has_saved_position({"current_position": null}), "null means none")
	assert_false(
		Helpers.has_saved_position({"current_position": {"x": 10}}),
		"a half-written position is not a position",
	)
	assert_true(
		Helpers.has_saved_position({"current_position": {"x": 10, "y": 20}}),
		"x and y together are a position",
	)


func test_saved_position_reads_coordinates() -> void:
	assert_eq(Helpers.saved_position({"current_position": {"x": 10, "y": 20}}), Vector2i(10, 20))


# --- v1 -> v2 migration ---


func _write_v1_save() -> void:
	PartyState.initialize_new_game()
	var data: Dictionary = PartyState.build_save_data()
	data["meta"]["version"] = 1
	data["world"]["current_position"] = {"x": 0, "y": 0}
	assert_true(SaveManager._write_data_to_slot(TEST_SLOT, data), "v1 fixture written")


func test_v1_save_loses_its_hardcoded_origin() -> void:
	_write_v1_save()
	var loaded: Dictionary = SaveManager.load_game(TEST_SLOT)
	assert_false(loaded.has("error"), "v1 save should load: %s" % loaded.get("error", ""))
	assert_false(
		_world_of(loaded).has("current_position"),
		"v1's fabricated origin must be stripped, not restored as a real position",
	)
	assert_eq(
		int(loaded.get("meta", {}).get("version", 0)),
		SaveManager.CURRENT_SAVE_VERSION,
		"migrated save should report the current version",
	)


func test_migrated_v1_save_loads_with_no_position_recorded() -> void:
	_write_v1_save()
	PartyState.load_from_save(SaveManager.load_game(TEST_SLOT))
	assert_false(
		PartyState.has_player_position,
		"a migrated v1 save must fall back to the map spawn, not the origin",
	)


func test_v2_save_keeps_its_position_through_load_game() -> void:
	PartyState.initialize_new_game()
	PartyState.set_player_location("test_room", Vector2i(96, 112))
	assert_true(SaveManager.save_game(TEST_SLOT), "save should succeed")
	var loaded: Dictionary = SaveManager.load_game(TEST_SLOT)
	assert_false(loaded.has("error"), "save should reload cleanly")
	assert_eq(
		_position_of(loaded),
		Vector2i(96, 112),
		"a v2 save is not migrated and keeps its real position",
	)
