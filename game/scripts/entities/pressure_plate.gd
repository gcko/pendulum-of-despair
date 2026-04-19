extends Area2D
## Pressure plate — one-shot toggle on body_entered. Opens connected WaterZone doors.

signal plate_pressed(plate_id: String)

var _plate_id: String = ""
var _is_pressed: bool = false

var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D


func initialize(p_plate_id: String, p_dungeon_id: String) -> void:
	if p_plate_id.is_empty() or p_dungeon_id.is_empty():
		if p_plate_id.is_empty():
			push_error("PressurePlate: empty plate_id")
		if p_dungeon_id.is_empty():
			push_error("PressurePlate: empty dungeon_id")
		return
	_plate_id = p_plate_id
	_dungeon_id = p_dungeon_id
	var raw_state: Variant = PartyState.get_puzzle_state(
		_dungeon_id, "%s_pressed" % _plate_id, false
	)
	_is_pressed = raw_state as bool if raw_state is bool else false
	_update_visual()


func _on_body_entered(body: Node2D) -> void:
	if _plate_id.is_empty() or _is_pressed:
		return
	if not body.is_in_group("player"):
		return
	if (
		GameManager.current_overlay == GameManager.OverlayState.CUTSCENE
		or GameManager.cutscene_active
	):
		return
	_is_pressed = true
	PartyState.set_puzzle_state(_dungeon_id, "%s_pressed" % _plate_id, true)
	_update_visual()
	plate_pressed.emit(_plate_id)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.frame = 1 if _is_pressed else 0
		_sprite.modulate = Color("#aaaaaa") if _is_pressed else Color.WHITE
