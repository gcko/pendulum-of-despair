extends GutTest
## Tests for the crafting-materials inventory bucket (GAP-019, #164).
##
## add_item used to funnel everything into consumables, so material drops
## landed where nothing could name, list or use them. These cover the routing
## rule, the Materials tab, the battle-item list, and the save migration that
## rescues materials stranded in old saves' consumables bucket.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")
const MENU_SCENE: PackedScene = preload("res://scenes/overlay/menu.tscn")
const BATTLE_SCENE: PackedScene = preload("res://scenes/core/battle.tscn")
const TEST_SLOT: int = 2


func before_each() -> void:
	TestHelpers.reset_game_state()
	SaveManager.delete_slot(TEST_SLOT)


func after_each() -> void:
	SaveManager.delete_slot(TEST_SLOT)
	TestHelpers.reset_game_state()


## The battle-item entry for `item_id`. Fails the calling test when it is
## absent, so a "not present" assertion can never pass against an empty list.
func _battle_entry(item_id: String) -> Dictionary:
	var list: Array[Dictionary] = Helpers.build_battle_item_list()
	assert_false(list.is_empty(), "battle item list should not be empty")
	for entry: Dictionary in list:
		if entry.get("id", "") == item_id:
			return entry
	fail_test("battle item list has no entry for '%s'" % item_id)
	return {}


func _battle_item_ids() -> Array[String]:
	var ids: Array[String] = []
	for entry: Dictionary in Helpers.build_battle_item_list():
		ids.append(entry.get("id", ""))
	return ids


# --- Routing ---


func test_material_add_lands_in_materials_bucket() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("beast_hide", 2)
	assert_eq(PartyState.get_materials().get("beast_hide", 0), 2, "material stacks in materials")
	assert_false(
		PartyState.get_consumables().has("beast_hide"),
		"a material must not sit in the consumables bucket",
	)


func test_consumable_add_still_lands_in_consumables() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("ether", 3)
	assert_eq(PartyState.get_consumables().get("ether", 0), 3, "consumable stacks in consumables")
	assert_false(PartyState.get_materials().has("ether"), "a consumable is not a material")


func test_battle_drop_routes_to_materials() -> void:
	PartyState.initialize_new_game()
	PartyState.distribute_battle_rewards(
		{"xp": 0, "gold": 0, "drops": [{"item_id": "scrap_metal"}]}
	)
	assert_eq(PartyState.get_materials().get("scrap_metal", 0), 1, "dropped material is filed")


func test_remove_item_takes_from_the_material_stack() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("beast_hide", 3)
	PartyState.remove_item("beast_hide", 3)
	assert_false(PartyState.get_materials().has("beast_hide"), "emptied stack is erased")


func test_consume_item_spends_from_the_material_stack() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("drake_fang", 2)
	assert_true(PartyState.consume_item("drake_fang"), "a held material can be consumed")
	assert_eq(PartyState.get_materials().get("drake_fang", 0), 1, "one fang is spent")


func test_consume_item_refuses_a_material_the_party_lacks() -> void:
	PartyState.initialize_new_game()
	assert_false(PartyState.consume_item("drake_fang"), "cannot consume what is not held")


func test_materials_survive_a_save_round_trip() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("beast_hide", 4)
	PartyState.load_from_save(PartyState.build_save_data())
	assert_eq(PartyState.get_materials().get("beast_hide", 0), 4, "materials persist")


# --- Battle item list ---


func test_drake_fang_is_battle_usable_from_the_material_stack() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("drake_fang", 1)
	var fang: Dictionary = _battle_entry("drake_fang")
	assert_eq(fang.get("effect", ""), "fixed_damage", "Drake Fang deals fixed damage")
	assert_eq(int(fang.get("value", 0)), 500, "500 damage per items.md")
	assert_eq(fang.get("target", ""), "single_enemy", "thrown at one enemy")
	assert_eq(int(fang.get("quantity", 0)), 1, "the list carries the held quantity")


func test_plain_materials_are_not_battle_items() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("drake_fang", 1)
	PartyState.add_item("beast_hide", 5)
	var ids: Array[String] = _battle_item_ids()
	assert_true("drake_fang" in ids, "the battle-usable material is listed")
	assert_false("beast_hide" in ids, "a plain crafting material is not")


func test_field_only_consumables_are_not_battle_items() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("tent", 1)
	var ids: Array[String] = _battle_item_ids()
	assert_true("potion" in ids, "starting potions are battle items")
	assert_false("tent" in ids, "a tent is field-only")


# --- Materials tab ---


func _open_materials_tab() -> Node:
	var menu: Node = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var screen: Node = menu.get_node_or_null("SubScreen/ItemScreen")
	if screen == null:
		fail_test("menu.tscn has no ItemScreen")
		return null
	screen.open()
	screen._switch_tab(1)  # USE -> MAT
	assert_eq(screen._tab_labels[1].text, "MAT", "the second tab is the Materials tab")
	return screen


func test_materials_tab_lists_name_quantity_and_sell_value() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("beast_hide", 7)
	var screen: Node = _open_materials_tab()
	assert_eq(screen._items.size(), 1, "the tab lists the one held material")
	var label: Label = screen._item_labels[0]
	assert_string_contains(label.text, "Beast Hide", "materials resolve a display name")
	assert_string_contains(label.text, ":7", "quantity is shown")
	assert_string_contains(label.text, "25g", "sell value is shown")


func test_materials_tab_ignores_consumables() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("beast_hide", 1)
	var screen: Node = _open_materials_tab()
	var ids: Array[String] = []
	for item: Dictionary in screen._items:
		ids.append(item.get("id", ""))
	assert_true("beast_hide" in ids, "the held material is listed")
	assert_false("potion" in ids, "starting potions belong to the USE tab")


func test_item_screen_has_four_tabs() -> void:
	PartyState.initialize_new_game()
	var menu: Node = MENU_SCENE.instantiate()
	add_child_autofree(menu)
	var screen: Node = menu.get_node_or_null("SubScreen/ItemScreen")
	assert_eq(screen._tab_labels.size(), 4, "USE / MAT / ARRANGE / KEY all exist in the scene")


# --- v1 -> v2 migration ---


func test_v1_save_moves_materials_out_of_consumables() -> void:
	PartyState.initialize_new_game()
	var data: Dictionary = PartyState.build_save_data()
	data["meta"]["version"] = 1
	data["inventory"]["consumables"]["beast_hide"] = 3
	data["inventory"]["materials"] = {"drake_fang": 1}
	assert_true(SaveManager._write_data_to_slot(TEST_SLOT, data), "v1 fixture written")

	var loaded: Dictionary = SaveManager.load_game(TEST_SLOT)
	assert_false(loaded.has("error"), "v1 save should load: %s" % loaded.get("error", ""))
	var inv: Dictionary = loaded.get("inventory", {})
	assert_false(inv.is_empty(), "migrated save should still have an inventory")
	assert_eq(
		int(inv.get("materials", {}).get("beast_hide", 0)),
		3,
		"stranded materials move to their own bucket",
	)
	assert_false(
		inv.get("consumables", {}).has("beast_hide"),
		"and are no longer filed as consumables",
	)
	assert_eq(int(inv.get("materials", {}).get("drake_fang", 0)), 1, "existing materials are kept")
	assert_eq(int(inv.get("consumables", {}).get("potion", 0)), 5, "real consumables are untouched")


func test_migration_merges_into_an_existing_material_stack() -> void:
	var inv: Dictionary = {"consumables": {"beast_hide": 2}, "materials": {"beast_hide": 1}}
	Helpers.reroute_materials(inv)
	assert_eq(int(inv["materials"]["beast_hide"]), 3, "counts are added, not overwritten")
	assert_false(inv["consumables"].has("beast_hide"), "the misfiled stack is removed")


# --- Drake Fang in battle ---


func test_drake_fang_hits_for_500_and_spends_a_fang() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("drake_fang", 2)
	var fang: Dictionary = _battle_entry("drake_fang")
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE_SCENE.instantiate()
	add_child_autofree(battle)
	await wait_frames(3)
	assert_false(battle._enemies.is_empty(), "the battle should have an enemy")
	var enemy: Node = battle._enemies[0]
	var hp_before: int = enemy.current_hp

	battle._atb.set_gauge("party_0", 16000)
	await wait_frames(2)
	battle._on_ui_command({"type": "item", "item": fang, "target": 0})
	await wait_frames(2)

	assert_eq(enemy.current_hp, maxi(0, hp_before - 500), "Drake Fang deals a flat 500 damage")
	assert_eq(PartyState.get_materials().get("drake_fang", 0), 1, "one fang is spent")
