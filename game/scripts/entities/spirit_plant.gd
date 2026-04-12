extends StaticBody2D
## Spirit-plant — blocks passage until restored with filled Spirit Vessel.

signal plant_restored(plant_id: String)
signal interaction_message(text: String)

var plant_id: String = ""
var is_restored: bool = false
var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func initialize(p_plant_id: String, p_dungeon_id: String) -> void:
	if p_plant_id.is_empty() or p_dungeon_id.is_empty():
		push_error("SpiritPlant: empty plant_id or dungeon_id")
		return
	plant_id = p_plant_id
	_dungeon_id = p_dungeon_id
	is_restored = PartyState.get_puzzle_state(_dungeon_id, "%s_restored" % plant_id, false)
	_update_visual()


func interact() -> void:
	if plant_id.is_empty():
		return
	if is_restored:
		interaction_message.emit("The spirit-plant glows with restored luminescence.")
		return
	var key_items: Variant = PartyState.inventory.get("key_items", [])
	if not key_items is Array:
		return
	if "spirit_vessel_filled" not in key_items:
		interaction_message.emit("The spirit-plant's tendrils block the passage. It is withering.")
		return
	key_items.erase("spirit_vessel_filled")
	key_items.append("spirit_vessel")
	PartyState.inventory["key_items"] = key_items
	is_restored = true
	PartyState.set_puzzle_state(_dungeon_id, "%s_restored" % plant_id, true)
	_update_visual()
	plant_restored.emit(plant_id)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.modulate = Color("#88ccff") if is_restored else Color("#666666")
	if _collision != null:
		_collision.disabled = is_restored
