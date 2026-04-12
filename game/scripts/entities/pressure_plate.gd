extends Area2D
## Pressure plate — one-shot toggle on body_entered. Opens connected WaterZone doors.

signal plate_pressed(plate_id: String)

var plate_id: String = ""
var is_pressed: bool = false

var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D


func initialize(p_plate_id: String, p_dungeon_id: String) -> void:
	if p_plate_id.is_empty() or p_dungeon_id.is_empty():
		if p_plate_id.is_empty():
			push_error("PressurePlate: empty plate_id")
		if p_dungeon_id.is_empty():
			push_error("PressurePlate: empty dungeon_id")
		return
	plate_id = p_plate_id
	_dungeon_id = p_dungeon_id
	is_pressed = PartyState.get_puzzle_state(_dungeon_id, "%s_pressed" % plate_id, false)
	_update_visual()


func _on_body_entered(body: Node2D) -> void:
	if plate_id.is_empty() or is_pressed:
		return
	if not body.is_in_group("player"):
		return
	is_pressed = true
	PartyState.set_puzzle_state(_dungeon_id, "%s_pressed" % plate_id, true)
	_update_visual()
	plate_pressed.emit(plate_id)


func _on_body_exited(_body: Node2D) -> void:
	pass  # One-shot — stays pressed permanently


func _update_visual() -> void:
	if _sprite != null:
		_sprite.frame = 1 if is_pressed else 0
		_sprite.modulate = Color("#aaaaaa") if is_pressed else Color.WHITE
