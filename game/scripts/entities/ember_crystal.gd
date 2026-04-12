extends StaticBody2D
## Dying ember crystal — blocks passage until revived with Mine Water Vial.

signal crystal_cleared(crystal_id: String)
signal interaction_message(text: String)

var crystal_id: String = ""
var is_cleared: bool = false
var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func initialize(p_crystal_id: String, p_dungeon_id: String) -> void:
	if p_crystal_id.is_empty() or p_dungeon_id.is_empty():
		push_error("EmberCrystal: empty crystal_id or dungeon_id")
		return
	crystal_id = p_crystal_id
	_dungeon_id = p_dungeon_id
	is_cleared = PartyState.get_puzzle_state(_dungeon_id, "%s_cleared" % crystal_id, false)
	_update_visual()


func interact() -> void:
	if crystal_id.is_empty():
		return
	if is_cleared:
		interaction_message.emit("The crystal glows warmly, its fronds unfurled.")
		return
	var key_items: Array = PartyState.get_key_items()
	if "mine_water_vial" not in key_items:
		interaction_message.emit(
			"It looks parched... maybe something from the mine levels could help."
		)
		return
	PartyState.remove_key_item("mine_water_vial")
	is_cleared = true
	PartyState.set_puzzle_state(_dungeon_id, "%s_cleared" % crystal_id, true)
	_update_visual()
	crystal_cleared.emit(crystal_id)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.modulate = Color("#ffaa44") if is_cleared else Color("#664400")
	if _collision != null:
		_collision.disabled = is_cleared
