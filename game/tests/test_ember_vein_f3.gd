extends GutTest
## Tests for Ember Vein F3 puzzle entities and map.

const PLATE_SCENE: PackedScene = preload("res://scenes/entities/pressure_plate.tscn")


func before_each() -> void:
	PartyState.puzzle_state.clear()
	PartyState.initialize_new_game()


func test_pressure_plate_sets_state_on_press() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	assert_false(plate.is_pressed, "Plate should start unpressed")
	plate._on_body_entered(null)
	assert_true(plate.is_pressed, "Plate should be pressed after body entered")
	assert_true(
		PartyState.get_puzzle_state("ember_vein", "test_plate_pressed", false),
		"Puzzle state should persist plate press"
	)


func test_pressure_plate_stays_pressed() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	plate._on_body_entered(null)
	assert_true(plate.is_pressed, "Plate should be pressed")
	plate._on_body_exited(null)
	assert_true(plate.is_pressed, "Plate should remain pressed (one-shot)")


func test_pressure_plate_emits_signal() -> void:
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	watch_signals(plate)
	plate._on_body_entered(null)
	assert_signal_emitted(plate, "plate_pressed")


func test_pressure_plate_restores_state() -> void:
	PartyState.set_puzzle_state("ember_vein", "test_plate_pressed", true)
	var plate: Node = PLATE_SCENE.instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	assert_true(plate.is_pressed, "Plate should restore pressed state from puzzle_state")
