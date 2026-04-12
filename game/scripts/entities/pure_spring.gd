extends Area2D
## Pure spring — fills an empty Spirit Vessel with sacred water.

signal spring_filled
signal interaction_message(text: String)


func interact() -> void:
	var key_items: Variant = PartyState.inventory.get("key_items", [])
	if not key_items is Array:
		return
	if "spirit_vessel_filled" in key_items:
		interaction_message.emit("The vessel is already full.")
		return
	if "spirit_vessel" in key_items:
		PartyState.remove_key_item("spirit_vessel")
		PartyState.add_key_item("spirit_vessel_filled")
		spring_filled.emit()
		return
	interaction_message.emit("You have nothing to hold the water in.")
