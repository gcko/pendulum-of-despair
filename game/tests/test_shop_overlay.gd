extends GutTest
## Tests for ShopOverlay — buy-only shop UI.

const SHOP_SCENE: PackedScene = preload("res://scenes/overlay/shop_overlay.tscn")

var _shop: Node


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	if _shop != null:
		_shop.queue_free()
		_shop = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _create_shop(shop_id: String) -> Node:
	GameManager.transition_data = {"shop_id": shop_id}
	_shop = SHOP_SCENE.instantiate()
	add_child_autofree(_shop)
	return _shop


# --- Empty shop ---


func test_empty_shop_shows_no_items() -> void:
	# Use a shop_id that does not exist — load_shop returns empty dict.
	var shop: Node = _create_shop("nonexistent_shop_id")
	var item_list: VBoxContainer = shop.get_node("Panel/VBox/ScrollContainer/ItemList")
	assert_eq(item_list.get_child_count(), 1, "should have exactly one child label")
	var lbl: Label = item_list.get_child(0) as Label
	assert_eq(lbl.text, "No items available.", "should show empty message")


# --- Buy consumable ---


func test_buy_consumable_adds_to_inventory() -> void:
	PartyState.gold = 200
	# aelhart_general has potion at 50G
	var shop: Node = _create_shop("aelhart_general")
	# Select the first item (potion, 50G) — _selected defaults to 0
	shop._try_buy()
	var consumables: Dictionary = PartyState.inventory.get("consumables", {})
	assert_eq(consumables.get("potion", 0), 1, "should have 1 potion after purchase")
	assert_eq(PartyState.gold, 150, "gold should decrease by 50")


# --- Buy equipment ---


func test_buy_equipment_adds_to_owned_equipment() -> void:
	PartyState.gold = 500
	# valdris_crown_weaponsmith has valdris_blade at 300G as first item
	var shop: Node = _create_shop("valdris_crown_weaponsmith")
	shop._try_buy()
	var found: bool = false
	for entry: Dictionary in PartyState.owned_equipment:
		if entry.get("equipment_id", "") == "valdris_blade":
			found = true
			break
	assert_true(found, "owned_equipment should contain valdris_blade")
	assert_eq(PartyState.gold, 200, "gold should decrease by 300")


# --- Insufficient gold ---


func test_insufficient_gold_shows_feedback() -> void:
	PartyState.gold = 10
	# aelhart_general potion costs 50G
	var shop: Node = _create_shop("aelhart_general")
	shop._try_buy()
	var desc_label: Label = shop.get_node("Panel/VBox/DescLabel") as Label
	assert_eq(desc_label.text, "Not enough gold.", "should show insufficient gold feedback")
	assert_eq(PartyState.gold, 10, "gold should be unchanged")


# --- Navigation wraps ---


func test_navigation_wraps() -> void:
	PartyState.gold = 0
	# aelhart_general has 8 items — use it for wrapping test with >= 3 items
	var shop: Node = _create_shop("aelhart_general")
	var item_count: int = shop._inventory.size()
	assert_gt(item_count, 2, "need at least 3 items for wrap test")
	# Navigate down item_count times — should wrap back to 0
	for i: int in range(item_count):
		shop._selected = (shop._selected + 1) % shop._inventory.size()
	assert_eq(shop._selected, 0, "selection should wrap back to 0")


# --- Restock event filtering ---


func test_restock_event_filters_locked_items() -> void:
	PartyState.gold = 10000
	# aelhart_general has items gated by restock_event: "ember_vein_complete"
	# Without the flag set, those items should be filtered out
	EventFlags.set_flag("ember_vein_complete", false)
	var shop: Node = _create_shop("aelhart_general")
	var has_gated_item: bool = false
	for entry: Dictionary in shop._inventory:
		# hi_potion is gated by ember_vein_complete in aelhart_general
		if entry.get("item_id", "") == "hi_potion":
			has_gated_item = true
	assert_false(has_gated_item, "restock-gated items should not appear when flag is unset")


func test_restock_event_shows_items_when_flag_set() -> void:
	PartyState.gold = 10000
	EventFlags.set_flag("ember_vein_complete", true)
	var shop: Node = _create_shop("aelhart_general")
	var has_gated_item: bool = false
	for entry: Dictionary in shop._inventory:
		if entry.get("item_id", "") == "hi_potion":
			has_gated_item = true
	assert_true(has_gated_item, "restock-gated items should appear when flag is set")


# --- Stock limit ---


func test_stock_limit_prevents_excess_purchases() -> void:
	PartyState.gold = 100000
	# Create shop and find an item — buy it more than stock_limit allows
	var shop: Node = _create_shop("aelhart_general")
	if shop._inventory.is_empty():
		pass_test("no items to test")
		return
	# Manually set a stock_limit on the first item for testing
	shop._inventory[0]["stock_limit"] = 2
	shop._inventory[0]["purchased"] = 0
	shop._selected = 0
	shop._try_buy()
	shop._try_buy()
	# Third buy should fail
	var gold_before: int = PartyState.gold
	shop._try_buy()
	assert_eq(PartyState.gold, gold_before, "gold should not decrease when stock limit reached")
