extends Area2D
## Pitfall zone — triggers map transition when player steps on cracked tile.
## One-shot per visit (runtime only, not persisted).

signal pitfall_triggered(target_map_id: String, target_spawn: String)

var _target_map_id: String = ""
var _target_spawn: String = ""
var _has_triggered: bool = false


func initialize(p_target_map_id: String, p_target_spawn: String) -> void:
	_target_map_id = p_target_map_id
	_target_spawn = p_target_spawn
	_has_triggered = false


func _on_body_entered(_body: Node2D) -> void:
	if _has_triggered or _target_map_id.is_empty():
		return
	_has_triggered = true
	pitfall_triggered.emit(_target_map_id, _target_spawn)
