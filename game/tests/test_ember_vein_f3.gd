extends GutTest
## Tests for Ember Vein F3 puzzle entities and map.

const PLATE_SCENE: PackedScene = preload("res://scenes/entities/pressure_plate.tscn")


func before_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	GameManager.transition_data = {}
	EventFlags.clear_all()
	DataManager.clear_cache()
	PartyState.puzzle_state.clear()
	PartyState.initialize_new_game()


func after_each() -> void:
	while GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	get_tree().paused = false
	GameManager.transition_data = {}
	EventFlags.clear_all()
	DataManager.clear_cache()
	PartyState.puzzle_state.clear()


func _make_mock_body() -> CharacterBody2D:
	var body: CharacterBody2D = CharacterBody2D.new()
	body.add_to_group("player")
	add_child_autofree(body)
	return body


func _simulate_cutscene_state() -> void:
	GameManager.current_overlay = GameManager.OverlayState.CUTSCENE
	get_tree().paused = true


func test_pressure_plate_sets_state_on_press() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autofree(plate)
	plate.initialize("test_plate", "ember_vein")
	assert_false(plate._is_pressed, "Plate should start unpressed")
	plate._on_body_entered(_make_mock_body())
	assert_true(plate._is_pressed, "Plate should be pressed after body entered")
	assert_true(
		PartyState.get_puzzle_state("ember_vein", "test_plate_pressed", false),
		"Puzzle state should persist plate press"
	)


func test_pressure_plate_stays_pressed() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autofree(plate)
	plate.initialize("test_plate", "ember_vein")
	plate._on_body_entered(_make_mock_body())
	assert_true(plate._is_pressed, "Plate should be pressed")


func test_pressure_plate_emits_signal() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autofree(plate)
	plate.initialize("test_plate", "ember_vein")
	watch_signals(plate)
	plate._on_body_entered(_make_mock_body())
	assert_signal_emitted(plate, "plate_pressed")


func test_pressure_plate_restores_state() -> void:
	PartyState.set_puzzle_state("ember_vein", "test_plate_pressed", true)
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autofree(plate)
	plate.initialize("test_plate", "ember_vein")
	assert_true(plate._is_pressed, "Plate should restore pressed state from puzzle_state")


func test_pressure_plate_blocked_during_cutscene() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autofree(plate)
	plate.initialize("test_plate", "ember_vein")
	_simulate_cutscene_state()
	watch_signals(plate)
	plate._on_body_entered(_make_mock_body())
	assert_false(plate._is_pressed, "Plate should not press during cutscene")
	assert_signal_not_emitted(plate, "plate_pressed", "Signal should not emit during cutscene")


func test_mine_water_vial_pickup_adds_key_item() -> void:
	PartyState.initialize_new_game()
	assert_false(
		"mine_water_vial" in PartyState.get_key_items(), "Vial should not be in inventory at start"
	)
	PartyState.add_key_item("mine_water_vial")
	assert_true(
		"mine_water_vial" in PartyState.get_key_items(), "Vial should be in key_items after pickup"
	)


func test_mine_water_vial_consumed_by_crystal() -> void:
	PartyState.initialize_new_game()
	PartyState.add_key_item("mine_water_vial")
	var crystal: Node = preload("res://scenes/entities/ember_crystal.tscn").instantiate()
	add_child_autofree(crystal)
	crystal.initialize("test_crystal", "ember_vein")
	crystal.interact()
	assert_false(
		"mine_water_vial" in PartyState.get_key_items(), "Vial should be consumed after crystal use"
	)
	assert_true(crystal._is_cleared, "Crystal should be cleared")
