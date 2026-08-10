class_name NPC
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

## Cursor into each NPC's ambient (unconditioned) dialogue set, keyed by
## npc_id. Session-scoped on purpose: it is static so an NPC keeps its place
## in the rotation across map reloads and battles, and it is deliberately NOT
## written to save data — which ambient line comes next is flavour, not
## progression state. Cleared by [method reset_dialogue_cycles].
static var _dialogue_cycle_indices: Dictionary = {}

## NPC identifier used for dialogue lookup.
var npc_id: String = ""

## All dialogue entries loaded from DataManager (ordered by priority).
## Typed as Array (not Array[Dictionary]) because GDScript rejects
## assigning untyped array literals to typed arrays at runtime.
var dialogue_entries: Array = []

## Active walk tween (killed on new walk_to call).
var _walk_tween: Tween = null

## Child node references.
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


## Clear every NPC's ambient dialogue cursor so a fresh playthrough starts on
## the first default line. Called when a new game starts and when a save is
## loaded, since the cursor is session state rather than save state.
static func reset_dialogue_cycles() -> void:
	_dialogue_cycle_indices.clear()


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
	dialogue_entries = []
	for e: Variant in data.get("entries", []):
		if e is Dictionary:
			dialogue_entries.append(e as Dictionary)
	_load_placeholder_sprite()


## Called by exploration scene when player interacts.
## Resolves current dialogue via priority stack, emits npc_interacted.
func interact() -> void:
	if npc_id == "":
		return
	var entry: Dictionary = _take_current_dialogue()
	if entry.is_empty():
		return
	npc_interacted.emit(npc_id, entry)


## Peek at the entry this NPC would serve right now, without advancing the
## ambient cycle. Returns {} when the NPC has nothing to say.
##
## A matched condition wins outright (first-match-wins, dialogue-system.md
## 3.2). Otherwise the NPC serves one of its unconditioned defaults — an NPC
## may have several, and they take turns rather than collapsing to the last
## one. See [method _take_current_dialogue].
func get_current_dialogue() -> Dictionary:
	var candidates: Array = DialogueCondition.resolve_stack(dialogue_entries)
	if candidates.is_empty():
		return {}
	return candidates[_cycle_index() % candidates.size()]


## Serve the current entry and advance the ambient cycle past it, so the next
## interaction surfaces the next default and wraps at the end.
func _take_current_dialogue() -> Dictionary:
	var candidates: Array = DialogueCondition.resolve_stack(dialogue_entries)
	if candidates.is_empty():
		return {}
	var index: int = _cycle_index() % candidates.size()
	# Only the default set rotates. A matched condition always resolves to
	# exactly one candidate, so the cursor stays put while it is active.
	if candidates.size() > 1:
		_dialogue_cycle_indices[npc_id] = (index + 1) % candidates.size()
	return candidates[index]


func _cycle_index() -> int:
	return int(_dialogue_cycle_indices.get(npc_id, 0))


## Lightweight init for cutscene actors — loads sprite but skips dialogue.
func initialize_as_actor() -> void:
	_load_placeholder_sprite()


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
	var distance: float = global_position.distance_to(target)
	if distance < 1.0:
		global_position = target.round()
		if _anim_player != null and _anim_player.has_animation("idle"):
			_anim_player.play("idle")
		walk_complete.emit()
		return
	if speed <= 0.0:
		if OS.is_debug_build():
			push_warning("NPC %s walk_to: non-positive speed %s" % [name, speed])
		global_position = target.round()
		walk_complete.emit()
		return
	var duration: float = distance / speed
	# Play walk animation if available
	var dir: Vector2 = (target - global_position).normalized()
	var anim_name: String = "idle"
	if abs(dir.x) > abs(dir.y):
		anim_name = "walk_east" if dir.x > 0 else "walk_west"
	else:
		anim_name = "walk_south" if dir.y > 0 else "walk_north"
	if _anim_player != null and _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)
	_walk_tween = create_tween()
	_walk_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# Tween with rounding to maintain pixel-perfect movement
	var start_pos: Vector2 = global_position
	_walk_tween.tween_method(
		func(progress: float):
			var interpolated: Vector2 = start_pos.lerp(target, progress)
			global_position = interpolated.round(),
		0.0,
		1.0,
		duration
	)
	_walk_tween.tween_callback(
		func():
			global_position = target.round()
			if _anim_player != null and _anim_player.has_animation("idle"):
				_anim_player.play("idle")
			walk_complete.emit()
	)


## Cancel any in-progress walk tween (e.g., on cutscene end).
## Emits walk_complete to maintain signal contract.
func cancel_walk() -> void:
	var was_walking: bool = _walk_tween != null and _walk_tween.is_valid()
	if _walk_tween != null and _walk_tween.is_valid():
		_walk_tween.kill()
	_walk_tween = null
	position = position.round()
	if _anim_player != null and _anim_player.has_animation("idle"):
		_anim_player.play("idle")
	if was_walking:
		walk_complete.emit()


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
