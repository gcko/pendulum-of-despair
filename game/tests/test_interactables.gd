extends GutTest
## Tests for TreasureChest, TriggerZone, and SavePoint prefabs.

const CHEST_SCENE: PackedScene = preload("res://scenes/entities/treasure_chest.tscn")
const TRIGGER_SCENE: PackedScene = preload("res://scenes/entities/trigger_zone.tscn")
const SAVE_SCENE: PackedScene = preload("res://scenes/entities/save_point.tscn")


func before_each() -> void:
	EventFlags.clear_all()
	GameManager.current_overlay = GameManager.OverlayState.NONE
	GameManager.transition_data = {}


func after_each() -> void:
	EventFlags.clear_all()
	GameManager.current_overlay = GameManager.OverlayState.NONE
	GameManager.transition_data = {}


func _make_player_body() -> CharacterBody2D:
	var body: CharacterBody2D = CharacterBody2D.new()
	body.add_to_group("player")
	add_child_autofree(body)
	return body


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


func test_chest_interact_before_init_blocked() -> void:
	var chest = CHEST_SCENE.instantiate()
	add_child_autofree(chest)
	watch_signals(chest)
	chest.interact()
	assert_signal_not_emitted(chest, "chest_opened", "interact before init should not emit")


func test_chest_pre_opened_via_flags() -> void:
	var chest = CHEST_SCENE.instantiate()
	add_child_autofree(chest)
	EventFlags.set_flag("chest_preopen_test_opened", true)
	chest.initialize("preopen_test", "potion")
	assert_true(chest.is_opened, "chest should start opened if flag was set")


# --- TriggerZone tests ---


func test_trigger_initialize() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("boss_room", "key_obtained")
	assert_eq(trigger.trigger_id, "boss_room", "trigger_id should be set")
	assert_eq(trigger.condition_flag, "key_obtained", "condition_flag should be set")
	assert_false(trigger.has_fired, "should not have fired yet")


func test_trigger_body_entered_connected() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	assert_true(
		trigger.is_connected("body_entered", Callable(trigger, "_on_body_entered")),
		"body_entered should be connected in scene",
	)


func test_trigger_fires_signal() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("test_trigger", "")
	watch_signals(trigger)
	trigger._on_body_entered(_make_player_body())
	assert_signal_emitted(trigger, "triggered", "should emit triggered")
	assert_true(trigger.has_fired, "should be marked as fired")


func test_trigger_one_time_fire() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("test_trigger_once", "")
	var player_body: CharacterBody2D = _make_player_body()
	trigger._on_body_entered(player_body)
	watch_signals(trigger)
	trigger._on_body_entered(player_body)
	assert_signal_not_emitted(trigger, "triggered", "second entry should not re-fire")


func test_trigger_condition_blocks() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("cond_trigger", "key_needed")
	watch_signals(trigger)
	trigger._on_body_entered(_make_player_body())
	assert_signal_not_emitted(trigger, "triggered", "unmet condition should block firing")
	assert_false(trigger.has_fired, "should not be marked as fired")


func test_trigger_condition_met_fires() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	EventFlags.set_flag("key_found", true)
	trigger.initialize("cond_met_trigger", "key_found")
	watch_signals(trigger)
	trigger._on_body_entered(_make_player_body())
	assert_signal_emitted(trigger, "triggered", "met condition should allow firing")


func test_trigger_before_init_blocked() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	watch_signals(trigger)
	trigger._on_body_entered(_make_player_body())
	assert_signal_not_emitted(trigger, "triggered", "body enter before init should not fire")


# --- SavePoint tests ---


func test_save_point_body_entered_connected() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	assert_true(
		sp.is_connected("body_entered", Callable(sp, "_on_body_entered")),
		"body_entered should be connected in scene",
	)


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
	sp._on_body_entered(_make_player_body())
	assert_signal_emitted(sp, "save_point_entered", "should emit save_point_entered")


func test_save_point_interact_before_init_blocked() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	watch_signals(sp)
	sp.interact()
	assert_signal_not_emitted(sp, "save_point_activated", "interact before init should not emit")


func test_save_point_body_before_init_blocked() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	watch_signals(sp)
	sp._on_body_entered(_make_player_body())
	assert_signal_not_emitted(sp, "save_point_entered", "body enter before init should not emit")


func test_save_point_blocked_during_cutscene() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	sp.initialize("test_sp_cs")
	GameManager.current_overlay = GameManager.OverlayState.CUTSCENE
	watch_signals(sp)
	sp._on_body_entered(_make_player_body())
	assert_signal_not_emitted(sp, "save_point_entered", "should not emit during cutscene")


func test_trigger_blocked_during_cutscene() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("cs_trigger", "")
	GameManager.current_overlay = GameManager.OverlayState.CUTSCENE
	watch_signals(trigger)
	trigger._on_body_entered(_make_player_body())
	assert_signal_not_emitted(trigger, "triggered", "should not fire during cutscene")
	assert_false(trigger.has_fired, "should not be marked as fired during cutscene")


func test_trigger_ignores_non_player_body() -> void:
	var trigger = TRIGGER_SCENE.instantiate()
	add_child_autofree(trigger)
	trigger.initialize("npc_trigger", "")
	watch_signals(trigger)
	var npc: Node2D = Node2D.new()
	add_child_autofree(npc)
	trigger._on_body_entered(npc)
	assert_signal_not_emitted(trigger, "triggered", "non-player body should not fire trigger")
	assert_false(trigger.has_fired, "should not be marked as fired for non-player")


func test_save_point_ignores_non_player_body() -> void:
	var sp = SAVE_SCENE.instantiate()
	add_child_autofree(sp)
	sp.initialize("test_sp_npc")
	watch_signals(sp)
	var npc: Node2D = Node2D.new()
	add_child_autofree(npc)
	sp._on_body_entered(npc)
	assert_signal_not_emitted(sp, "save_point_entered", "non-player body should not emit")


# --- PitfallZone tests ---


func test_pitfall_blocked_during_cutscene() -> void:
	var pitfall: Area2D = preload("res://scenes/entities/pitfall_zone.tscn").instantiate()
	add_child_autofree(pitfall)
	pitfall.initialize("dungeons/ember_vein_f2", "from_pitfall")
	GameManager.current_overlay = GameManager.OverlayState.CUTSCENE
	watch_signals(pitfall)
	pitfall._on_body_entered(_make_player_body())
	assert_signal_not_emitted(pitfall, "pitfall_triggered", "should not trigger during cutscene")


func test_pop_overlay_silent_skips_signal() -> void:
	GameManager.push_overlay(GameManager.OverlayState.DIALOGUE)
	watch_signals(GameManager)
	GameManager.pop_overlay(true)
	assert_signal_not_emitted(
		GameManager, "overlay_state_changed", "silent pop should not emit NONE"
	)
	assert_eq(
		GameManager.current_overlay,
		GameManager.OverlayState.NONE,
		"overlay should be NONE after silent pop",
	)
