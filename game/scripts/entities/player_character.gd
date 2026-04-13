extends CharacterBody2D
## Player character entity for exploration scenes.
##
## Handles 4-directional movement, character data loading,
## and interaction detection with nearby entities.
## Snaps to pixel grid every frame. Respects global pause state
## via PROCESS_MODE_INHERIT.
##
## Usage: instance player_character.tscn, call initialize("edren").

## Emitted when the player presses interact and an interactable is nearby.
signal interaction_requested(interactable: Node2D)
## Emitted when walk_to() completes.
signal walk_complete

## Movement speed in pixels per second.
const MOVE_SPEED: float = 80.0

## Character ID loaded from DataManager.
var character_id: String = ""

## Loaded character data dictionary.
var character_data: Dictionary = {}

## Current facing direction for animation selection.
var facing_direction: Vector2 = Vector2.DOWN

## Whether player input is currently being processed.
var _input_enabled: bool = true

## Last interactable that entered the Area2D (not necessarily nearest).
var _current_interactable: Node2D = null

## Reference to child nodes (cached in _ready).
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


func _physics_process(_delta: float) -> void:
	# Snap to pixel grid every frame — including during auto-walk tweens.
	position = position.round()
	if not _input_enabled:
		return
	var direction: Vector2 = _get_input_direction()

	if direction != Vector2.ZERO:
		facing_direction = direction
		velocity = direction * MOVE_SPEED
		_play_walk_animation(direction)
	else:
		velocity = Vector2.ZERO
		_play_idle_animation()

	move_and_slide()
	position = position.round()


## Whether player input is currently being processed.
func is_input_enabled() -> bool:
	return _input_enabled


## Enable or disable player input processing (for auto-walk scenes).
func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled


## Initialize the character with data from DataManager.
## Call after adding to the scene tree.
func initialize(p_character_id: String) -> void:
	character_id = p_character_id
	character_data = DataManager.load_character(character_id)
	if character_data.is_empty():
		push_error("PlayerCharacter: Failed to load data for '%s'" % character_id)
		return
	_load_placeholder_sprite()


## Get the character's base stats dictionary.
func get_stats() -> Dictionary:
	return character_data.get("base_stats", {})


## Get the current facing direction as a unit vector.
func get_facing_direction() -> Vector2:
	return facing_direction


## Read 4-directional input. No diagonal — vertical takes priority.
func _get_input_direction() -> Vector2:
	if Input.is_action_pressed("ui_up"):
		return Vector2.UP
	if Input.is_action_pressed("ui_down"):
		return Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		return Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		return Vector2.RIGHT
	return Vector2.ZERO


func _play_walk_animation(direction: Vector2) -> void:
	if _anim_player == null:
		return
	var anim_name: String = "idle"
	if direction == Vector2.UP:
		anim_name = "walk_north"
	elif direction == Vector2.DOWN:
		anim_name = "walk_south"
	elif direction == Vector2.LEFT:
		anim_name = "walk_west"
	elif direction == Vector2.RIGHT:
		anim_name = "walk_east"

	if _anim_player.current_animation != anim_name:
		_anim_player.play(anim_name)


func _play_idle_animation() -> void:
	if _anim_player == null:
		return
	if _anim_player.current_animation != "idle":
		_anim_player.play("idle")


func _load_placeholder_sprite() -> void:
	var sprite_path: String = "res://assets/sprites/characters/placeholder_%s.png" % character_id
	if not ResourceLoader.exists(sprite_path):
		push_error("PlayerCharacter: Placeholder sprite not found: %s" % sprite_path)
		return
	var texture: Texture2D = load(sprite_path)
	# @onready vars may not be resolved if initialize() is called before _ready.
	# Fall back to get_node() if _sprite is null.
	var sprite: Sprite2D = _sprite if _sprite != null else get_node("Sprite2D")
	if sprite != null:
		sprite.texture = texture


## Play a named animation if the AnimationPlayer has it.
func play_animation(anim_name: String) -> void:
	if _anim_player != null and _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)


## Attempt to interact with the nearest interactable. Emits interaction_requested
## if an interactable is in range. Called by exploration scene on confirm press.
func try_interact() -> void:
	if _current_interactable != null:
		interaction_requested.emit(_current_interactable)


## Walk to target position at given speed (for cutscene choreography).
## Emits walk_complete when arrived. Uses Tween, not physics movement.
func walk_to(target: Vector2, speed: float) -> void:
	var distance: float = position.distance_to(target)
	if distance < 1.0:
		walk_complete.emit()
		return
	var duration: float = distance / speed
	# Face the walk direction using existing facing_direction var
	var dir: Vector2 = (target - position).normalized()
	if abs(dir.x) > abs(dir.y):
		facing_direction = Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		facing_direction = Vector2.DOWN if dir.y > 0 else Vector2.UP
	# Reuse existing _play_walk_animation (handles anim name mapping)
	_play_walk_animation(facing_direction)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target, duration)
	tween.tween_callback(
		func():
			_play_idle_animation()
			walk_complete.emit()
	)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	_current_interactable = body


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if _current_interactable == body:
		_current_interactable = null


func _on_interaction_area_area_entered(area: Area2D) -> void:
	_current_interactable = area


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if _current_interactable == area:
		_current_interactable = null
