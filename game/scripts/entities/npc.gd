extends Area2D
## NPC entity with flag-gated dialogue priority stack.
##
## Loads dialogue entries from DataManager, resolves the priority
## stack on interact (first-match-wins), and emits the resolved
## dialogue data as a signal. Does not push overlays directly —
## exploration scene handles that ("call down, signal up").
##
## Usage: instance npc.tscn, call initialize("bren").

## Emitted when the player interacts. Carries resolved dialogue.
signal npc_interacted(npc_id: String, dialogue_data: Dictionary)
## Emitted when walk_to() completes.
signal walk_complete

## NPC identifier used for dialogue lookup.
var npc_id: String = ""

## All dialogue entries loaded from DataManager (ordered by priority).
var dialogue_entries: Array = []

## Active walk tween (killed on new walk_to call).
var _walk_tween: Tween = null

## Child node references.
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


## Initialize the NPC with an ID. Loads dialogue from DataManager.
func initialize(p_npc_id: String) -> void:
	if p_npc_id == "":
		push_error("NPC: empty npc_id")
		return
	npc_id = p_npc_id
	var dialogue_key: String = "npc_%s" % npc_id
	var data: Dictionary = DataManager.load_dialogue(dialogue_key)
	if data.is_empty():
		push_error("NPC: Failed to load dialogue for '%s'" % dialogue_key)
		return
	dialogue_entries = data.get("entries", [])
	_load_placeholder_sprite()


## Called by exploration scene when player interacts.
## Resolves current dialogue via priority stack, emits npc_interacted.
func interact() -> void:
	if npc_id == "":
		return
	var entry: Dictionary = get_current_dialogue()
	if entry.is_empty():
		return
	npc_interacted.emit(npc_id, entry)


## Get the current dialogue entry based on priority stack resolution.
## First pass: check conditioned entries (skip null/empty conditions).
## Second pass: return last null-condition entry as fallback.
## This handles data where default entries appear before conditioned ones.
func get_current_dialogue() -> Dictionary:
	var fallback: Dictionary = {}
	for entry: Dictionary in dialogue_entries:
		var condition: Variant = entry.get("condition")
		if condition == null or condition == "":
			fallback = entry
			continue
		if _evaluate_condition(condition):
			return entry
	return fallback


## Evaluate a condition expression against current game state.
## Supports: null (always true), binary flags, numeric comparisons,
## party_has() (stubbed), and AND combinations.
func _evaluate_condition(condition: Variant) -> bool:
	# Null or empty = always true (default/fallback entry).
	if condition == null or condition == "":
		return true

	# Must be a string to parse further.
	if not condition is String:
		return false

	var cond_str: String = condition

	# AND combinations: split and evaluate each part.
	if " AND " in cond_str:
		var parts: PackedStringArray = cond_str.split(" AND ")
		for part: String in parts:
			if not _evaluate_condition(part.strip_edges()):
				return false
		return true

	# party_has(character) — stubbed until GameManager.party exists.
	if cond_str.begins_with("party_has("):
		return false

	# Numeric/string comparison operators.
	var operators: Array[String] = [">=", "<=", "==", "!=", ">", "<"]
	for op: String in operators:
		var op_idx: int = cond_str.find(op)
		if op_idx > 0:
			var flag_name: String = cond_str.substr(0, op_idx).strip_edges()
			var value_str: String = cond_str.substr(op_idx + op.length()).strip_edges()
			return _compare_flag(flag_name, op, value_str)

	# Binary flag (simplest case).
	return bool(EventFlags.get_flag(cond_str))


## Compare a flag value against an expected value using an operator.
func _compare_flag(flag_name: String, op: String, value_str: String) -> bool:
	var flag_val: Variant = EventFlags.get_flag(flag_name)
	var result: bool = false
	if value_str.is_valid_int():
		var expected: int = value_str.to_int()
		var actual: int = int(flag_val) if flag_val != null else 0
		match op:
			">=":
				result = actual >= expected
			"<=":
				result = actual <= expected
			"==":
				result = actual == expected
			"!=":
				result = actual != expected
			">":
				result = actual > expected
			"<":
				result = actual < expected
	else:
		var actual_str: String = str(flag_val) if flag_val != null else ""
		match op:
			"==":
				result = actual_str == value_str
			"!=":
				result = actual_str != value_str
	return result


func _load_placeholder_sprite() -> void:
	var sprite_path: String = "res://assets/sprites/npcs/placeholder_npc.png"
	if not ResourceLoader.exists(sprite_path):
		push_error("NPC: Placeholder sprite not found: %s" % sprite_path)
		return
	var loaded: Resource = load(sprite_path)
	if not (loaded is Texture2D):
		push_error("NPC: loaded resource is not Texture2D: %s" % sprite_path)
		return
	var texture: Texture2D = loaded as Texture2D
	var sprite: Sprite2D = _sprite if _sprite != null else get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.texture = texture


## Walk to target position at given speed (for cutscene choreography).
func walk_to(target: Vector2, speed: float) -> void:
	if _walk_tween != null and _walk_tween.is_valid():
		_walk_tween.kill()
	_walk_tween = null
	var distance: float = position.distance_to(target)
	if distance < 1.0:
		position = target
		if _anim_player != null and _anim_player.has_animation("idle"):
			_anim_player.play("idle")
		walk_complete.emit()
		return
	if speed <= 0.0:
		if OS.is_debug_build():
			push_warning("NPC %s walk_to: non-positive speed %s" % [name, speed])
		position = target
		walk_complete.emit()
		return
	var duration: float = distance / speed
	# Play walk animation if available
	var dir: Vector2 = (target - position).normalized()
	var anim_name: String = "idle"
	if abs(dir.x) > abs(dir.y):
		anim_name = "walk_east" if dir.x > 0 else "walk_west"
	else:
		anim_name = "walk_south" if dir.y > 0 else "walk_north"
	if _anim_player != null and _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)
	_walk_tween = create_tween()
	_walk_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_walk_tween.tween_property(self, "position", target, duration)
	_walk_tween.tween_callback(
		func():
			if _anim_player != null and _anim_player.has_animation("idle"):
				_anim_player.play("idle")
			walk_complete.emit()
	)


## Play a named animation on the NPC's AnimationPlayer.
## Uses existing _anim_player @onready var (line 22).
func play_animation(anim: String) -> void:
	if _anim_player == null:
		if OS.is_debug_build():
			push_warning("NPC %s has no AnimationPlayer" % name)
		return
	if not _anim_player.has_animation(anim):
		if OS.is_debug_build():
			push_warning("NPC %s missing animation: %s" % [name, anim])
		return
	_anim_player.play(anim)
