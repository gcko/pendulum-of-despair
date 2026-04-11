extends Area2D
## Pure spring — fills an empty Spirit Vessel with sacred water.

signal spring_filled
signal interaction_message(text: String)


func interact() -> void:
	var key_items: Array = PartyState.inventory.get("key_items", [])
	if "spirit_vessel_filled" in key_items:
		interaction_message.emit("The vessel is already full.")
		return
	if "spirit_vessel" in key_items:
		key_items.erase("spirit_vessel")
		key_items.append("spirit_vessel_filled")
		PartyState.inventory["key_items"] = key_items
		spring_filled.emit()
		return
	interaction_message.emit("You have nothing to hold the water in.")
