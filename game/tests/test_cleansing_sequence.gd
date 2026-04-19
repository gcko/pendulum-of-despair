extends GutTest
## Tests for CleansingSequence resource validation ordering.
## Verifies start() and continue_sequence() validate resources
## before mutating game state (EventFlags, PartyState, etc.).

const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")


## Subclass with an invalid ritual meter path to trigger the
## validation-failure early-return path.
class BadPathSequence:
	extends CleansingSequence

	func _init(exploration: Exploration) -> void:
		super._init(exploration)
		_ritual_meter_path = "res://nonexistent/bad_path.tscn"


func before_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	get_tree().paused = false
	GameManager.transition_data = {}
	EventFlags.clear_all()
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.gold = 0
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	PartyState.is_at_save_point = false


func after_each() -> void:
	if GameManager.current_overlay != GameManager.OverlayState.NONE:
		GameManager.pop_overlay()
	get_tree().paused = false
	GameManager.cutscene_active = false
	GameManager.transition_data = {}
	EventFlags.clear_all()
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.gold = 0
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	PartyState.is_at_save_point = false


func _create_exploration() -> Node2D:
	GameManager.transition_data = {}
	var exp_node: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp_node)
	return exp_node


# --- start() validation-before-mutation ---


func test_start_invalid_resource_does_not_set_flags() -> void:
	var exp_node: Node2D = _create_exploration()
	var seq: BadPathSequence = BadPathSequence.new(exp_node)
	EventFlags.set_flag("fenmother_boss_defeated", false)
	var data: Dictionary = {"earned_xp": 100, "earned_gold": 50}
	seq.start(data)
	assert_false(
		EventFlags.get_flag("fenmother_boss_defeated"),
		"flag should not be set when resource validation fails"
	)


func test_start_invalid_resource_does_not_distribute_rewards() -> void:
	var exp_node: Node2D = _create_exploration()
	var seq: BadPathSequence = BadPathSequence.new(exp_node)
	PartyState.gold = 100
	var data: Dictionary = {"earned_gold": 50}
	seq.start(data)
	assert_eq(PartyState.gold, 100, "gold should be unchanged when resource validation fails")


func test_continue_invalid_resource_does_not_distribute_rewards() -> void:
	var exp_node: Node2D = _create_exploration()
	var seq: BadPathSequence = BadPathSequence.new(exp_node)
	PartyState.gold = 200
	var data: Dictionary = {"wave_num": 0, "earned_gold": 75}
	seq.continue_sequence(data)
	assert_eq(PartyState.gold, 200, "gold should be unchanged when resource validation fails")
