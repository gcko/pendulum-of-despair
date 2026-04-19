class_name WaterWheel
extends Area2D
## Water wheel interactable — toggles HIGH/LOW state for water level puzzles.

signal wheel_toggled(wheel_id: String, is_high: bool)

var wheel_id: String = ""
var is_high: bool = false

var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D


func initialize(p_wheel_id: String, p_dungeon_id: String) -> void:
	if p_wheel_id.is_empty() or p_dungeon_id.is_empty():
		if p_wheel_id.is_empty():
			push_error("WaterWheel: empty wheel_id")
		if p_dungeon_id.is_empty():
			push_error("WaterWheel: empty dungeon_id")
		return
	wheel_id = p_wheel_id
	_dungeon_id = p_dungeon_id
	var raw_state: Variant = PartyState.get_puzzle_state(_dungeon_id, "%s_high" % wheel_id, false)
	is_high = raw_state as bool if raw_state is bool else false
	_update_visual()


func interact() -> void:
	if wheel_id.is_empty():
		return
	is_high = not is_high
	PartyState.set_puzzle_state(_dungeon_id, "%s_high" % wheel_id, is_high)
	_update_visual()
	wheel_toggled.emit(wheel_id, is_high)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.frame = 1 if is_high else 0
