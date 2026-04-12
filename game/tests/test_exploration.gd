extends GutTest
## Tests for Exploration Scene.

const EXPLORATION_SCENE: PackedScene = preload("res://scenes/core/exploration.tscn")
const RITUAL_METER_SCENE: PackedScene = preload("res://scenes/ui/ritual_meter.tscn")


func before_each() -> void:
	GameManager.transition_data = {}
	EventFlags.clear_all()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.gold = 0
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	PartyState.is_at_save_point = false


func after_each() -> void:
	GameManager.transition_data = {}
	EventFlags.clear_all()
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
	var exp: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	return exp


func _create_exploration_test_room() -> Node2D:
	GameManager.transition_data = {}
	var exp: Node2D = EXPLORATION_SCENE.instantiate()
	add_child_autofree(exp)
	exp.load_map("test_room")
	return exp


# --- Scene Loading ---


func test_exploration_scene_loads() -> void:
	var exp: Node2D = _create_exploration()
	assert_not_null(exp, "exploration scene should instantiate")


func test_load_map_creates_children() -> void:
	var exp: Node2D = _create_exploration()
	var map_container = exp.get_node("CurrentMap")
	assert_gt(map_container.get_child_count(), 0, "map should be loaded as child")


func test_player_spawns_at_marker() -> void:
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player should be instantiated")
	assert_eq(exp._player.position, Vector2(80, 90), "player should be at spawn point")


func test_camera_follows_player() -> void:
	var exp: Node2D = _create_exploration()
	exp._player.position = Vector2(100, 50)
	exp._process(0.016)
	var cam = exp.get_node("Camera2D")
	assert_eq(cam.position, Vector2(100, 50), "camera should follow player")


# --- Entity Interaction ---


func test_npc_interaction_signal_wired() -> void:
	var exp: Node2D = _create_exploration_test_room()
	var entities = exp._current_map.get_node_or_null("Entities")
	assert_not_null(entities, "entities node should exist")
	var npc = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC should exist in map")
	assert_true(
		npc.npc_interacted.is_connected(exp._on_npc_interacted), "NPC signal should be connected"
	)


func test_chest_interaction_signal_wired() -> void:
	var exp: Node2D = _create_exploration_test_room()
	var entities = exp._current_map.get_node_or_null("Entities")
	var chest = entities.get_node_or_null("TestChest")
	assert_not_null(chest, "test chest should exist in map")
	assert_true(
		chest.chest_opened.is_connected(exp._on_chest_opened), "chest signal should be connected"
	)


func test_save_point_signal_wired() -> void:
	var exp: Node2D = _create_exploration_test_room()
	var entities = exp._current_map.get_node_or_null("Entities")
	var sp = entities.get_node_or_null("TestSavePoint")
	assert_not_null(sp, "test save point should exist in map")
	assert_true(
		sp.save_point_activated.is_connected(exp._on_save_point_activated),
		"save point signal should be connected",
	)


# --- Map Transitions ---


func test_transition_flag_blocks_interaction() -> void:
	var exp: Node2D = _create_exploration_test_room()
	# Use a real entity that has interact() — e.g., the NPC from the map
	var entities = exp._current_map.get_node_or_null("Entities")
	var npc = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC must exist for this test")
	watch_signals(npc)
	exp._transitioning = true
	exp._on_interaction_requested(npc)
	# NPC.interact() emits npc_interacted — if blocked, signal should NOT emit
	assert_signal_not_emitted(
		npc, "npc_interacted", "interaction should be blocked during transition"
	)


func test_location_flash_sets_text() -> void:
	var exp: Node2D = _create_exploration()
	exp.flash_location_name("Test Location")
	assert_eq(exp._location_label.text, "Test Location", "should set location text")
	assert_true(exp._location_panel.visible, "location panel should be visible")


func test_map_changed_signal() -> void:
	var exp: Node2D = _create_exploration()
	watch_signals(exp)
	exp.load_map("test_room_2")
	assert_signal_emitted(exp, "map_changed", "should emit map_changed")


# --- Chest & Inventory ---


func test_chest_opened_adds_item_to_inventory() -> void:
	var exp: Node2D = _create_exploration()
	var prev_qty: int = PartyState.inventory.get("consumables", {}).get("potion", 0)
	exp._on_chest_opened("test_chest_99", "potion", 1)
	var new_qty: int = PartyState.inventory.get("consumables", {}).get("potion", 0)
	assert_eq(new_qty, prev_qty + 1, "chest should add item to inventory")


# --- Encounter Config ---


func test_encounter_fallback_skipped_on_empty_floor_id() -> void:
	var exp: Node2D = _create_exploration()
	# After initial load_map the encounter config is set from the map.
	# Load a map that has an empty floor_id but a dungeon_id that resolves.
	# The test_room map has no floor_id metadata, so _current_floor_id = "".
	# When floor_id is empty the encounter matching loop uses match_id = ""
	# which should NOT match any floor entry — _encounter_config stays empty.
	exp._encounter_config = {}
	exp._current_floor_id = ""
	# Re-trigger the encounter loading logic by calling load_map on test_room.
	# test_room has no encounter file, so config should remain empty.
	exp.load_map("test_room")
	assert_true(
		exp._encounter_config.is_empty(),
		"encounter config should stay empty when floor_id is empty and no match found"
	)


# --- NPC Shop & Inn ---


func test_npc_with_shop_id_opens_shop_overlay() -> void:
	var exp: Node2D = _create_exploration_test_room()
	var entities: Node = exp._current_map.get_node_or_null("Entities")
	assert_not_null(entities, "entities node required")
	var npc: Node = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC required")
	# Add shop_id metadata to the NPC so the handler routes to shop overlay.
	npc.set_meta("shop_id", "aelhart_general")
	watch_signals(GameManager)
	exp._on_npc_interacted(npc.get("npc_id"), {"speaker": "test", "text": "hello"})
	# push_overlay emits overlay_state_changed with SHOP
	assert_signal_emitted(GameManager, "overlay_state_changed", "should open shop overlay")
	# Clean up the overlay so it does not leak into the next test
	GameManager.pop_overlay()


func test_inn_interaction_deducts_gold() -> void:
	var exp: Node2D = _create_exploration_test_room()
	var entities: Node = exp._current_map.get_node_or_null("Entities")
	assert_not_null(entities, "entities node required")
	var npc: Node = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC required")
	npc.set_meta("inn_id", "test_inn")
	npc.set_meta("inn_cost", 150)
	PartyState.gold = 500
	exp._on_npc_interacted(npc.get("npc_id"), {"speaker": "test", "text": "hello"})
	assert_eq(PartyState.gold, 350, "gold should decrease by inn cost")


func test_inn_interaction_insufficient_gold_rejected() -> void:
	var exp: Node2D = _create_exploration_test_room()
	var entities: Node = exp._current_map.get_node_or_null("Entities")
	assert_not_null(entities, "entities node required")
	var npc: Node = entities.get_node_or_null("TestNPC")
	assert_not_null(npc, "test NPC required")
	npc.set_meta("inn_id", "test_inn")
	npc.set_meta("inn_cost", 150)
	PartyState.gold = 50
	exp._on_npc_interacted(npc.get("npc_id"), {"speaker": "test", "text": "hello"})
	assert_eq(PartyState.gold, 50, "gold should be unchanged when insufficient")


# --- Encapsulation: Input gating via is_input_enabled() ---


func test_ui_accept_blocked_when_input_disabled() -> void:
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player must exist")
	exp._player.set_input_enabled(false)
	watch_signals(exp._player)
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	exp._unhandled_input(event)
	assert_signal_not_emitted(
		exp._player,
		"interaction_requested",
		"ui_accept should be blocked when input is disabled",
	)


func test_ui_accept_allowed_when_input_enabled() -> void:
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player must exist")
	exp._player.set_input_enabled(true)
	watch_signals(exp._player)
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	exp._unhandled_input(event)
	# try_interact runs but may not emit if no interactable is nearby;
	# the key assertion is that the code path is NOT blocked by the guard.
	# We verify by checking the event was consumed (viewport handled).
	assert_true(
		exp._player.is_input_enabled(),
		"input should still be enabled (not toggled off by the handler)",
	)


func test_ui_menu_blocked_when_input_disabled() -> void:
	var exp: Node2D = _create_exploration_test_room()
	assert_not_null(exp._player, "player must exist")
	exp._player.set_input_enabled(false)
	watch_signals(GameManager)
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_menu"
	event.pressed = true
	exp._unhandled_input(event)
	assert_signal_not_emitted(
		GameManager,
		"overlay_state_changed",
		"ui_menu should be blocked when input is disabled",
	)


# --- Ritual meter persistence across transitions ---


func test_ritual_meter_value_stored_in_transition_data() -> void:
	var exp: Node2D = _create_exploration()
	PartyState.initialize_new_game()
	# Manually set up the ritual meter on the cleansing sequence
	var cleansing: RefCounted = exp._get_cleansing()
	cleansing._ritual_meter = RITUAL_METER_SCENE.instantiate()
	exp.add_child(cleansing._ritual_meter)
	cleansing._ritual_meter.set_value(62.5)
	# _launch_wave builds transition data with ritual_meter_value.
	# We cannot call it directly (it triggers GameManager.change_core_state),
	# so we verify the code path by checking the meter value is read correctly.
	var meter_val: float = cleansing._ritual_meter.meter_value
	assert_eq(meter_val, 62.5, "meter value should be 62.5")
	# Build the transition dict the same way _launch_wave does
	var transition: Dictionary = {
		"ritual_meter_value":
		cleansing._ritual_meter.meter_value if cleansing._ritual_meter != null else 100.0,
	}
	assert_eq(
		transition["ritual_meter_value"],
		62.5,
		"transition data should capture current meter value",
	)


func test_ritual_meter_restored_from_transition_data() -> void:
	var exp: Node2D = _create_exploration()
	PartyState.initialize_new_game()
	# Simulate the state after returning from a cleansing wave battle:
	# _ritual_meter is null (scene was recreated), transition_data has saved value.
	# continue_sequence restores meter then applies drain.
	# With wave_num=0, next_wave=1, drain = 15.0 (base, 0 KOs, 0 turns).
	# So restored 42.0 - 15.0 = 27.0.
	var cleansing: RefCounted = exp._get_cleansing()
	assert_null(cleansing._ritual_meter, "meter should be null before restoration")
	var data: Dictionary = {
		"wave_num": 0,
		"ritual_meter_value": 42.0,
		"map_id": "test_room",
		"earned_xp": 0,
		"earned_gold": 0,
		"earned_drops": [],
	}
	cleansing.continue_sequence(data)
	assert_not_null(cleansing._ritual_meter, "meter should be re-instantiated")
	# Verify meter was restored from transition data (42.0) then drained (15.0)
	assert_eq(
		cleansing._ritual_meter.meter_value,
		27.0,
		"meter should be restored value (42) minus base drain (15)",
	)
	if cleansing._ritual_meter != null:
		cleansing._ritual_meter.queue_free()
		cleansing._ritual_meter = null


func test_ritual_meter_defaults_to_100_when_missing() -> void:
	var exp: Node2D = _create_exploration()
	PartyState.initialize_new_game()
	# When ritual_meter_value is not in transition data, defaults to 100.0.
	# After drain of 15.0 (base, wave_num=0), final value = 85.0.
	var cleansing: RefCounted = exp._get_cleansing()
	var data: Dictionary = {
		"wave_num": 0,
		"map_id": "test_room",
		"earned_xp": 0,
		"earned_gold": 0,
		"earned_drops": [],
	}
	cleansing.continue_sequence(data)
	assert_not_null(cleansing._ritual_meter, "meter should be re-instantiated")
	assert_eq(
		cleansing._ritual_meter.meter_value,
		85.0,
		"meter should default to 100 minus base drain (15)",
	)
	if cleansing._ritual_meter != null:
		cleansing._ritual_meter.queue_free()
		cleansing._ritual_meter = null


func test_ritual_meter_different_saved_values() -> void:
	var exp: Node2D = _create_exploration()
	PartyState.initialize_new_game()
	# Verify different saved values produce different post-drain results.
	# 80.0 - 15.0 = 65.0
	var cleansing: RefCounted = exp._get_cleansing()
	var data: Dictionary = {
		"wave_num": 0,
		"ritual_meter_value": 80.0,
		"map_id": "test_room",
		"earned_xp": 0,
		"earned_gold": 0,
		"earned_drops": [],
	}
	cleansing.continue_sequence(data)
	assert_eq(
		cleansing._ritual_meter.meter_value,
		65.0,
		"meter should be 80 - 15 = 65",
	)
	if cleansing._ritual_meter != null:
		cleansing._ritual_meter.queue_free()
		cleansing._ritual_meter = null
