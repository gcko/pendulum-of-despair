extends GutTest
## Tests for Fenmother's Hollow Phase A2b puzzle systems.

const WHEEL_SCENE: PackedScene = preload("res://scenes/entities/water_wheel.tscn")
const ZONE_SCENE: PackedScene = preload("res://scenes/entities/water_zone.tscn")
const SPRING_SCENE: PackedScene = preload("res://scenes/entities/pure_spring.tscn")
const PLANT_SCENE: PackedScene = preload("res://scenes/entities/spirit_plant.tscn")
const DAMAGE_ZONE_SCENE: PackedScene = preload("res://scenes/entities/damage_zone.tscn")
const RITUAL_METER_SCRIPT: GDScript = preload("res://scripts/ui/ritual_meter.gd")


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	EventFlags.clear_all()


func after_each() -> void:
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	EventFlags.clear_all()


# --- Puzzle State API ---


func test_set_and_get_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high")
	assert_true(val, "should return true after setting")


func test_get_puzzle_state_default() -> void:
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "nonexistent", false)
	assert_false(val, "should return default when key not set")


func test_get_puzzle_state_default_no_dungeon() -> void:
	var val: Variant = PartyState.get_puzzle_state("unknown_dungeon", "key", 42)
	assert_eq(val, 42, "should return default when dungeon not in puzzle_state")


func test_clear_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("other_dungeon", "valve_open", true)
	PartyState.clear_puzzle_state("fenmothers_hollow")
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_false(val, "cleared dungeon state should return default")
	var other: Variant = PartyState.get_puzzle_state("other_dungeon", "valve_open", false)
	assert_true(other, "other dungeon state should be unaffected")


func test_puzzle_state_save_roundtrip() -> void:
	PartyState.initialize_new_game()
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "spirit_plant_1_restored", false)
	var save_data: Dictionary = PartyState.build_save_data()
	assert_true(save_data.has("puzzle_state"), "save should include puzzle_state")
	PartyState.puzzle_state.clear()
	PartyState.load_from_save(save_data)
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_true(val, "wheel_1_high should survive save/load")


func test_puzzle_state_load_handles_missing_key() -> void:
	PartyState.initialize_new_game()
	var save_data: Dictionary = PartyState.build_save_data()
	save_data.erase("puzzle_state")
	PartyState.load_from_save(save_data)
	assert_true(PartyState.puzzle_state.is_empty(), "should default to empty dict")


func test_puzzle_state_load_handles_wrong_type() -> void:
	PartyState.initialize_new_game()
	var save_data: Dictionary = PartyState.build_save_data()
	save_data["puzzle_state"] = [1, 2, 3]
	PartyState.load_from_save(save_data)
	assert_true(PartyState.puzzle_state.is_empty(), "should default to empty dict for wrong type")


func test_initialize_new_game_clears_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.initialize_new_game()
	assert_true(PartyState.puzzle_state.is_empty(), "new game should clear puzzle_state")


func test_remove_key_item_noop_for_missing_item() -> void:
	PartyState.inventory["key_items"] = ["spirit_vessel"]
	watch_signals(PartyState)
	PartyState.remove_key_item("nonexistent_item")
	var key_items: Array = PartyState.get_key_items()
	assert_eq(key_items.size(), 1, "key_items should be unchanged")
	assert_true("spirit_vessel" in key_items, "original item should remain")
	assert_signal_not_emitted(PartyState, "inventory_changed", "should not emit for no-op")


# --- Water Wheel ---


func test_wheel_initialize() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	assert_eq(wheel.wheel_id, "wheel_1", "wheel_id should be set")
	assert_false(wheel.is_high, "should default to LOW")


func test_wheel_interact_toggles() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	watch_signals(wheel)
	wheel.interact()
	assert_true(wheel.is_high, "should be HIGH after interact")
	assert_signal_emitted(wheel, "wheel_toggled")


func test_wheel_interact_persists_to_puzzle_state() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	wheel.interact()
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_true(val, "puzzle_state should reflect HIGH after toggle")


func test_wheel_initialize_restores_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	assert_true(wheel.is_high, "should restore HIGH from puzzle_state")


func test_wheel_toggle_back_to_low() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	wheel.interact()
	wheel.interact()
	assert_false(wheel.is_high, "should be LOW after two toggles")


func test_wheel_empty_id_guard() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("", "fenmothers_hollow")
	assert_eq(wheel.wheel_id, "", "should remain empty")
	assert_push_error_count(1, "empty wheel_id should trigger push_error")


# --- Water Zone ---


func test_zone_condition_parsing_single() -> void:
	var zone: StaticBody2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_low", "block")
	assert_eq(zone._conditions.size(), 1, "should parse 1 condition")


func test_zone_condition_parsing_multiple() -> void:
	var zone: StaticBody2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_high,wheel_2_high,wheel_3_high", "block")
	assert_eq(zone._conditions.size(), 3, "should parse 3 conditions")


func test_zone_block_active_when_conditions_met() -> void:
	var zone: StaticBody2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_low", "block")
	zone.refresh()
	assert_true(zone.visible, "block zone should be visible when conditions met")


func test_zone_block_inactive_when_conditions_not_met() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var zone: StaticBody2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_low", "block")
	zone.refresh()
	assert_false(zone.visible, "block zone should be hidden when conditions not met")


func test_zone_reveal_active_when_conditions_met() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_2_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_3_high", true)
	var zone: StaticBody2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_high,wheel_2_high,wheel_3_high", "reveal")
	zone.refresh()
	assert_true(zone.visible, "reveal zone should be visible when all conditions met")


# --- Pure Spring ---


func test_spring_fill_with_empty_vessel() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel"]
	var spring: Area2D = SPRING_SCENE.instantiate()
	add_child_autofree(spring)
	watch_signals(spring)
	spring.interact()
	assert_signal_emitted(spring, "spring_filled")
	assert_true(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"should have filled vessel after interaction",
	)
	assert_false(
		"spirit_vessel" in PartyState.inventory["key_items"],
		"empty vessel should be removed",
	)


func test_spring_no_vessel() -> void:
	PartyState.initialize_new_game()
	var spring: Area2D = SPRING_SCENE.instantiate()
	add_child_autofree(spring)
	watch_signals(spring)
	spring.interact()
	assert_signal_not_emitted(spring, "spring_filled")


func test_spring_already_filled() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var spring: Area2D = SPRING_SCENE.instantiate()
	add_child_autofree(spring)
	watch_signals(spring)
	spring.interact()
	assert_signal_not_emitted(spring, "spring_filled")
	assert_true(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"filled vessel should remain",
	)


# --- Spirit Plant ---


func test_plant_initialize_unrestored() -> void:
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	assert_false(plant.is_restored, "should start unrestored")


func test_plant_interact_with_filled_vessel() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	watch_signals(plant)
	plant.interact()
	assert_true(plant.is_restored, "should be restored after pour")
	assert_signal_emitted(plant, "plant_restored")
	assert_true(
		"spirit_vessel" in PartyState.inventory["key_items"],
		"empty vessel should be returned",
	)
	assert_false(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"filled vessel should be consumed",
	)


func test_plant_interact_without_vessel() -> void:
	PartyState.initialize_new_game()
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	watch_signals(plant)
	plant.interact()
	assert_false(plant.is_restored, "should stay unrestored")
	assert_signal_not_emitted(plant, "plant_restored")


func test_plant_persists_restored_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "spirit_plant_1_restored", true)
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	assert_true(plant.is_restored, "should restore from puzzle_state")


func test_plant_interact_already_restored() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	PartyState.set_puzzle_state("fenmothers_hollow", "spirit_plant_1_restored", true)
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	watch_signals(plant)
	plant.interact()
	assert_signal_not_emitted(plant, "plant_restored")
	assert_true(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"vessel should not be consumed when already restored",
	)


func test_plant_collision_disabled_after_restore() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	plant.interact()
	var col: CollisionShape2D = plant.get_node_or_null("CollisionShape2D")
	if col != null:
		assert_true(col.disabled, "collision should be disabled after restore")


func test_plant_visual_changes_on_restore() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	var sprite: Sprite2D = plant.get_node_or_null("Sprite2D")
	var color_before: Color = sprite.modulate if sprite != null else Color.WHITE
	plant.interact()
	if sprite != null:
		assert_ne(sprite.modulate, color_before, "sprite color should change after restore")


func test_plant_puzzle_state_persists_after_restore() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	plant.interact()
	var key: String = "spirit_plant_1_restored"
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", key, false)
	assert_true(val, "spirit_plant_1_restored should be set in puzzle_state")


func test_plant_reinitialize_after_restore_stays_open() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "spirit_plant_1_restored", true)
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	assert_true(plant.is_restored, "should be restored from puzzle_state")
	var col: CollisionShape2D = plant.get_node_or_null("CollisionShape2D")
	if col != null:
		assert_true(col.disabled, "collision should remain disabled")


# --- Damage Zone ---


func test_damage_zone_initialize() -> void:
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 8, 1.0, "poison")
	assert_eq(zone.zone_id, "test_pool")
	assert_eq(zone.damage_per_tick, 8)


func test_damage_zone_deals_damage() -> void:
	PartyState.initialize_new_game()
	var edren: Dictionary = PartyState.get_member("edren")
	var hp_before: int = edren.get("current_hp", 0)
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	zone._apply_tick()
	var hp_after: int = PartyState.get_member("edren").get("current_hp", 0)
	assert_lt(hp_after, hp_before, "HP should decrease after damage tick")


func test_damage_zone_clamps_to_min_1() -> void:
	PartyState.initialize_new_game()
	var edren: Dictionary = PartyState.get_member("edren")
	edren["current_hp"] = 5
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 100, 1.0, "")
	zone._apply_tick()
	var hp_after: int = PartyState.get_member("edren").get("current_hp", 0)
	assert_eq(hp_after, 1, "HP should clamp to 1, not kill")


func test_damage_zone_applies_status_first_tick_only() -> void:
	PartyState.initialize_new_game()
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 5, 1.0, "poison")
	zone._apply_tick()
	assert_true(zone._status_applied, "status should be applied on first tick")
	zone._apply_tick()
	assert_true(zone._status_applied, "flag should remain true")


func test_damage_zone_signal_emitted() -> void:
	PartyState.initialize_new_game()
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	watch_signals(zone)
	zone._apply_tick()
	assert_signal_emitted(zone, "zone_damage_dealt")


func test_damage_zone_blocked_during_cutscene() -> void:
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	GameManager.current_overlay = GameManager.OverlayState.CUTSCENE
	var body: CharacterBody2D = CharacterBody2D.new()
	body.add_to_group("player")
	add_child_autofree(body)
	zone._on_body_entered(body)
	assert_false(zone._player_inside, "Player should not register inside during cutscene")
	GameManager.current_overlay = GameManager.OverlayState.NONE


func test_damage_zone_no_damage_after_exit() -> void:
	PartyState.initialize_new_game()
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	zone._player_inside = true
	zone._apply_tick()
	var hp_after_tick: int = PartyState.get_member("edren").get("current_hp", 0)
	zone._player_inside = false
	zone._on_tick()
	var hp_after_exit: int = PartyState.get_member("edren").get("current_hp", 0)
	assert_eq(hp_after_exit, hp_after_tick, "no further damage after player exits")


# --- Ritual Meter ---


func test_ritual_meter_initial_value() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	assert_eq(meter.meter_value, 100.0, "should start at 100")


func test_ritual_meter_drain() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	meter.drain(25.0)
	assert_eq(meter.meter_value, 75.0, "should be 75 after draining 25")


func test_ritual_meter_recover() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	meter.drain(50.0)
	meter.recover(20.0)
	assert_eq(meter.meter_value, 70.0, "should be 70 after drain 50 + recover 20")


func test_ritual_meter_clamp_min() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	meter.drain(200.0)
	assert_eq(meter.meter_value, 0.0, "should clamp to 0")
	assert_true(meter.is_failed(), "should be failed at 0")


func test_ritual_meter_clamp_max() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	meter.recover(50.0)
	assert_eq(meter.meter_value, 100.0, "should clamp to 100")


func test_ritual_meter_not_failed_at_1() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	meter.drain(99.0)
	assert_false(meter.is_failed(), "should not be failed at 1")


func test_ritual_meter_calculate_drain() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	var drain: float = meter.calculate_drain(0, 0, 6, 6, false)
	assert_eq(drain, 15.0, "base drain only when at threshold with 0 KOs")


func test_ritual_meter_calculate_drain_with_penalties() -> void:
	var meter: Node = RITUAL_METER_SCRIPT.new()
	add_child_autofree(meter)
	var drain: float = meter.calculate_drain(1, 2, 12, 8, true)
	assert_eq(drain, 33.0, "should sum penalties and subtract recovery")
