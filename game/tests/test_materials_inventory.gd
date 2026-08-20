extends GutTest
## Tests for the crafting-materials inventory bucket (GAP-019, #164).
##
## add_item used to funnel everything into consumables, so material drops
## landed where nothing could name, list or use them. These cover the routing
## rule, the Materials tab, the battle-item list, and the save migration that
## rescues materials stranded in old saves' consumables bucket.

const Helpers = preload("res://scripts/util/inventory_helpers.gd")
const MENU_SCENE: PackedScene = preload("res://scenes/overlay/menu.tscn")
const BATTLE_SCENE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const TEST_SLOT: int = 2

## Real time allowed for the battle to answer a full ATB gauge with a prompt.
const PROMPT_TIMEOUT: float = 5.0

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	SaveManager.delete_slot(TEST_SLOT)


func after_each() -> void:
	# A live battle keeps _process-ing, so free it here rather than let it run
	# on into the next test — one test's leftovers must never decide another
	# test's result (#422).
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
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


## Every material row currently painted on screen, in display order. Fails the
## calling test when nothing is visible, so a "contains" assertion can never
## pass against an empty screen.
func _visible_rows(screen: Node) -> Array[String]:
	var rows: Array[String] = []
	for label: Label in screen._item_labels:
		if label != null and label.visible:
			rows.append(label.text)
	if rows.is_empty():
		fail_test("the item list painted no visible rows")
	return rows


func _press(screen: Node, action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	screen.handle_input(event)


func test_materials_tab_prices_an_act_scaled_material_instead_of_erroring() -> void:
	# gold_pouch ships with "sell_price": null — the key is present, so a
	# get(..., 0) default never fires and the raw null reaches the format string.
	PartyState.initialize_new_game()
	PartyState.add_item("gold_pouch", 1)
	PartyState.add_item("beast_hide", 2)
	var screen: Node = _open_materials_tab()
	assert_eq(screen._items.size(), 2, "both held materials are listed")
	var rows: Array[String] = _visible_rows(screen)
	assert_eq(rows.size(), 2, "a null sell price must not abort the row loop")
	assert_string_contains(rows[0], "Gold Pouch", "the pouch renders")
	assert_string_contains(rows[0], "150g", "Act I gold value stands in for the null price")
	assert_string_contains(rows[1], "Beast Hide", "the row after it still renders")


func test_materials_tab_prices_an_unsellable_material_at_zero() -> void:
	PartyState.initialize_new_game()
	PartyState.add_item("pallor_core", 1)
	var screen: Node = _open_materials_tab()
	var rows: Array[String] = _visible_rows(screen)
	assert_string_contains(rows[0], "Pallor Core", "the unsellable material renders")
	assert_string_contains(rows[0], "0g", "an unsellable material is worth nothing")


func test_material_sell_value_resolves_a_null_price() -> void:
	assert_eq(Helpers.material_sell_value({"sell_price": 25}), 25, "a plain price is used as is")
	assert_eq(
		Helpers.material_sell_value({"sell_price": null, "gold_value_by_act": {"act_i": 150}}),
		150,
		"act-scaled worth stands in for a null price",
	)
	assert_eq(
		Helpers.material_sell_value({"sell_price": null}), 0, "an unsellable material is worth 0"
	)


func test_materials_tab_scrolls_to_materials_past_the_last_row() -> void:
	# 87 materials exist, nothing sells or spends them yet, and the list panel
	# holds 12 rows — everything past row 12 has to scroll into view (#164).
	PartyState.initialize_new_game()
	var held: Array[String] = [
		"beast_hide",
		"sharp_fang",
		"drake_scale",
		"serpent_fang",
		"leech_ichor",
		"lurker_shell",
		"wolf_pelt",
		"boar_tusk",
		"hawk_feather",
		"hare_pelt",
		"beetle_carapace",
		"crab_claw",
		"viper_fang",
		"mite_husk",
		"roach_wing",
	]
	for item_id: String in held:
		PartyState.add_item(item_id, 1)
	var screen: Node = _open_materials_tab()
	assert_eq(screen._items.size(), held.size(), "every held material is in the list")
	assert_gt(screen._items.size(), screen._item_labels.size(), "more materials than list rows")
	assert_string_contains(
		_visible_rows(screen)[0], "Beast Hide", "the first row starts at the top"
	)

	for _i: int in range(held.size() - 1):
		_press(screen, "ui_down")
	assert_eq(screen._cursor_index, held.size() - 1, "the cursor reaches the last material")
	assert_string_contains(
		"\n".join(_visible_rows(screen)), "Roach Wing", "the last material scrolls into view"
	)


func test_materials_tab_scrolls_back_to_the_top() -> void:
	PartyState.initialize_new_game()
	for item_id: String in ["beast_hide", "sharp_fang", "drake_scale", "serpent_fang"]:
		PartyState.add_item(item_id, 1)
	var screen: Node = _open_materials_tab()
	_press(screen, "ui_up")  # wraps to the last entry
	assert_eq(screen._cursor_index, 3, "up from the first entry wraps to the last")
	assert_string_contains(
		"\n".join(_visible_rows(screen)), "Beast Hide", "a short list never scrolls off the top"
	)


func test_switching_tabs_resets_the_scroll_window() -> void:
	PartyState.initialize_new_game()
	for item_id: String in [
		"beast_hide",
		"sharp_fang",
		"drake_scale",
		"serpent_fang",
		"leech_ichor",
		"lurker_shell",
		"wolf_pelt",
		"boar_tusk",
		"hawk_feather",
		"hare_pelt",
		"beetle_carapace",
		"crab_claw",
		"viper_fang",
	]:
		PartyState.add_item(item_id, 1)
	var screen: Node = _open_materials_tab()
	for _i: int in range(12):
		_press(screen, "ui_down")
	screen._switch_tab(1)  # MAT -> ARRANGE
	screen._switch_tab(-1)  # back to MAT
	assert_eq(screen._cursor_index, 0, "the cursor returns to the top of the tab")
	assert_string_contains(
		"\n".join(_visible_rows(screen)), "Beast Hide", "and the window follows it back"
	)


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


## Boot the real battle scene against [param encounter]. battle.tscn seats the
## party, spawns the enemies and registers every ATB gauge in _ready, which runs
## inside add_child — the battle is ready to drive when this returns.
func _boot_battle(encounter: Array) -> Node:
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE_SCENE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


## Fill [param cid]'s gauge and wait until the battle actually asks for that
## combatant's command — turn_ready, the signal that opens the command menu.
## Returns false, having failed the test, when the prompt never arrives.
##
## The wait is on the prompt rather than on a frame count because the battle
## advances in _process (idle frames) while GUT's frame waits count physics
## frames: a fixed wait can return with the actor still not ready, and the
## command submitted after it is then dropped in silence (#422).
func _await_prompt(battle: Node, cid: String) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge(cid, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not cid in prompted:
		fail_test("the battle never asked %s for a command (asked: %s)" % [cid, str(prompted)])
		return false
	return true


func test_drake_fang_hits_for_500_and_spends_a_fang() -> void:
	# The whole path a player drives: hold two fangs, wait to be asked for a
	# command, throw one at an enemy. It takes the flat 500 damage items.md
	# promises, the player sees that number, and the stack drops to one.
	PartyState.initialize_new_game()
	PartyState.add_item("drake_fang", 2)
	var fang: Dictionary = _battle_entry("drake_fang")
	var battle: Node = _boot_battle(["ley_vermin"])
	assert_false(battle.get_enemies().is_empty(), "the battle should have an enemy")
	var enemy: Node = battle.get_enemies()[0]
	var hp_before: int = enemy.current_hp
	var hits: Array[Dictionary] = []
	battle.damage_dealt.connect(
		func(tid: String, amt: int, _dt: String) -> void: hits.append({"id": tid, "amount": amt})
	)
	if not await _await_prompt(battle, "party_0"):
		return

	# Submitted the way BattleUI submits it when the player confirms.
	var ui: CanvasLayer = battle.get_node("BattleUI")
	ui.command_submitted.emit({"type": "item", "item": fang, "target": 0})

	assert_eq(enemy.current_hp, maxi(0, hp_before - 500), "Drake Fang deals a flat 500 damage")
	assert_eq(PartyState.get_materials().get("drake_fang", 0), 1, "one fang is spent")
	assert_eq(hits.size(), 1, "one damage number is shown: %s" % str(hits))
	assert_eq(int(hits[0].get("amount", 0)), 500, "and it reads 500")
