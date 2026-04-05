extends GutTest
## Tests for TreasureChest, TriggerZone, and SavePoint prefabs.

const CHEST_SCENE: PackedScene = preload("res://scenes/entities/treasure_chest.tscn")
const TRIGGER_SCENE: PackedScene = preload("res://scenes/entities/trigger_zone.tscn")
const SAVE_SCENE: PackedScene = preload("res://scenes/entities/save_point.tscn")

# --- TreasureChest tests ---


func test_chest_initialize() -> void:
	var chest = CHEST_SCENE.instantiate()
	add_child_autofree(chest)
	chest.initialize("test_chest_01", "potion")
	assert_eq(chest.chest_id, "test_chest_01", "chest_id should be set")
	assert_eq(chest.item_id, "potion", "item_id should be set")
	assert_false(chest.is_opened, "chest should start closed")


func test_chest_interact_opens() -> void:
	var chest = CHEST_SCENE.instantiate()
	add_child_autofree(chest)
	chest.initialize("test_chest_02", "ether")
	watch_signals(chest)
	chest.interact()
	assert_true(chest.is_opened, "chest should be opened after interact")
	assert_signal_emitted(chest, "chest_opened", "should emit chest_opened")


func test_chest_already_opened_blocks() -> void:
	var chest = CHEST_SCENE.instantiate()
	add_child_autofree(chest)
	chest.initialize("test_chest_03", "potion")
	chest.interact()
	watch_signals(chest)
	chest.interact()
	assert_signal_not_emitted(chest, "chest_opened", "second interact should not emit")


func test_chest_signal_carries_ids() -> void:
	var chest = CHEST_SCENE.instantiate()
	add_child_autofree(chest)
	chest.initialize("my_chest", "rare_item")
	watch_signals(chest)
	chest.interact()
	var params: Array = get_signal_parameters(chest, "chest_opened", 0)
	assert_eq(params[0], "my_chest", "signal should carry chest_id")
	assert_eq(params[1], "rare_item", "signal should carry item_id")


# --- TriggerZone tests ---


func test_trigger_initialize() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("boss_room", "key_obtained")
	assert_eq(trigger.trigger_id, "boss_room", "trigger_id should be set")
	assert_eq(trigger.condition_flag, "key_obtained", "condition_flag should be set")
	assert_false(trigger.has_fired, "should not have fired yet")


func test_trigger_fires_signal() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("test_trigger", "")
	watch_signals(trigger)
	# Simulate body entering by calling the handler directly
	trigger._on_body_entered(Node2D.new())
	assert_signal_emitted(trigger, "triggered", "should emit triggered")
	assert_true(trigger.has_fired, "should be marked as fired")


func test_trigger_one_time_fire() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("test_trigger_once", "")
	trigger._on_body_entered(Node2D.new())
	watch_signals(trigger)
	trigger._on_body_entered(Node2D.new())
	assert_signal_not_emitted(trigger, "triggered", "second entry should not re-fire")


# --- SavePoint tests ---


func test_save_point_initialize() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	sp.initialize("ember_vein_f1")
	assert_eq(sp.save_point_id, "ember_vein_f1", "save_point_id should be set")


func test_save_point_interact_signal() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	sp.initialize("test_sp")
	watch_signals(sp)
	sp.interact()
	assert_signal_emitted(sp, "save_point_activated", "should emit save_point_activated")


func test_save_point_entered_signal() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	sp.initialize("test_sp_prox")
	watch_signals(sp)
	sp._on_body_entered(Node2D.new())
	assert_signal_emitted(sp, "save_point_entered", "should emit save_point_entered")
