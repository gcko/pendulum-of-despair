extends Area2D
## Save point (ley crystal) that emits signals for proximity and interaction.
##
## Does not directly push overlays or play audio — exploration scene
## handles those via signal listeners ("call down, signal up").
##
## Usage: instance save_point.tscn, call initialize("ember_vein_f1").

## Emitted when the player interacts with the save point.
signal save_point_activated(save_point_id: String)

## Emitted when the player enters proximity (for SFX by exploration scene).
signal save_point_entered(save_point_id: String)

## Emitted when the player leaves proximity.
signal save_point_exited(save_point_id: String)

## Unique identifier for this save point location.
var save_point_id: String = ""

## Child node references.
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


## Initialize the save point with a location ID. Starts shimmer animation.
func initialize(p_save_point_id: String) -> void:
	if p_save_point_id == "":
		push_error("SavePoint: empty save_point_id")
		return
	save_point_id = p_save_point_id
	var anim: AnimationPlayer = (
		_anim_player if _anim_player != null else get_node_or_null("AnimationPlayer")
	)
	if anim != null and anim.has_animation("shimmer"):
		anim.play("shimmer")


## Called by exploration scene when player interacts.
func interact() -> void:
	if save_point_id == "":
		return
	save_point_activated.emit(save_point_id)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if save_point_id == "":
		return
	if (
		GameManager.current_overlay == GameManager.OverlayState.CUTSCENE
		or GameManager.cutscene_active
	):
		return
	save_point_entered.emit(save_point_id)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if save_point_id == "":
		return
	save_point_exited.emit(save_point_id)
