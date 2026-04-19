extends GutTest


func before_each() -> void:
	DataManager.clear_cache()


func after_each() -> void:
	DataManager.clear_cache()


func _get_all_item_ids() -> Array[String]:
	var ids: Array[String] = []
	var consumables: Dictionary = DataManager.load_json("res://data/items/consumables.json")
	for item: Dictionary in consumables.get("items", []):
		ids.append(item.get("id", ""))
	var weapons: Dictionary = DataManager.load_json("res://data/equipment/weapons.json")
	for item: Dictionary in weapons.get("weapons", []):
		ids.append(item.get("id", ""))
	var armor: Dictionary = DataManager.load_json("res://data/equipment/armor.json")
	for item: Dictionary in armor.get("armor", []):
		ids.append(item.get("id", ""))
	var accessories: Dictionary = DataManager.load_json("res://data/equipment/accessories.json")
	for item: Dictionary in accessories.get("accessories", []):
		ids.append(item.get("id", ""))
	return ids


func test_all_shop_items_exist() -> void:
	var all_items: Array[String] = _get_all_item_ids()
	var shop_ids: Array[String] = [
		"valdris_crown_weaponsmith",
		"valdris_crown_armorsmith",
		"valdris_crown_jeweler",
		"valdris_crown_specialty",
		"valdris_crown_general",
	]
	for sid: String in shop_ids:
		var data: Dictionary = DataManager.load_shop(sid)
		for entry: Dictionary in data.get("shop", {}).get("inventory", []):
			var item_id: String = entry.get("item_id", "")
			assert_has(all_items, item_id, "'%s' in shop '%s' not in game data" % [item_id, sid])


func test_treasure_items_exist() -> void:
	var all_items: Array[String] = _get_all_item_ids()
	assert_has(all_items, "phoenix_pinion", "phoenix_pinion should exist")
	assert_has(all_items, "spirit_incense", "spirit_incense should exist")


func test_npc_dialogues_exist_for_new_maps() -> void:
	var maps: Array[String] = [
		"towns/valdris_citizens_walk",
		"towns/valdris_court_quarter",
		"towns/valdris_throne_hall",
		"towns/valdris_royal_library",
		"towns/valdris_barracks",
	]
	for map_id: String in maps:
		var path: String = "res://scenes/maps/%s.tscn" % map_id
		var scene: PackedScene = load(path) as PackedScene
		var node: Node2D = scene.instantiate() as Node2D
		add_child_autofree(node)
		var entities: Node = node.get_node_or_null("Entities")
		if entities == null:
			continue
		for child: Node in entities.get_children():
			if not child.has_meta("npc_id"):
				continue
			var npc_id: String = child.get_meta("npc_id")
			var dlg: Dictionary = DataManager.load_dialogue("npc_%s" % npc_id)
			assert_ne(dlg, {}, "NPC '%s' in '%s' missing dialogue" % [npc_id, map_id])
