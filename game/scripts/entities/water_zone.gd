extends StaticBody2D
## Water level zone — blocks or reveals paths based on water wheel state.

signal zone_refreshed

var _dungeon_id: String = ""
var _conditions: Array[Dictionary] = []
var _zone_type: String = "block"

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func initialize(p_dungeon_id: String, p_conditions_str: String, p_zone_type: String) -> void:
	if p_dungeon_id.is_empty():
		push_error("WaterZone: empty dungeon_id")
		return
	_dungeon_id = p_dungeon_id
	_zone_type = p_zone_type
	_conditions = []
	for cond: String in p_conditions_str.split(","):
		var trimmed: String = cond.strip_edges()
		if trimmed.is_empty():
			continue
		var parts: Array = trimmed.rsplit("_", true, 1)
		if parts.size() < 2:
			push_error("WaterZone: invalid condition format '%s'" % trimmed)
			continue
		var suffix: String = parts[1]
		if suffix == "high" or suffix == "low":
			var wheel_key: String = parts[0] + "_high"
			var expected_high: bool = suffix == "high"
			_conditions.append({"key": wheel_key, "expected_high": expected_high})
		elif suffix == "pressed" or suffix == "unpressed":
			var plate_key: String = parts[0] + "_pressed"
			var expected_pressed: bool = suffix == "pressed"
			_conditions.append({"key": plate_key, "expected_high": expected_pressed})
		else:
			push_error("WaterZone: unknown suffix '%s' in condition '%s'" % [suffix, trimmed])
			continue
	refresh()


func refresh() -> void:
	var all_met: bool = true
	for cond: Dictionary in _conditions:
		var raw: Variant = PartyState.get_puzzle_state(_dungeon_id, cond["key"], false)
		var actual: bool = raw as bool if raw is bool else false
		if actual != cond["expected_high"]:
			all_met = false
			break
	if _zone_type == "block":
		visible = all_met
		if _collision != null:
			_collision.disabled = not all_met
	else:  # reveal — cosmetic only, never blocks
		visible = all_met
		if _collision != null:
			_collision.disabled = true
	zone_refreshed.emit()
