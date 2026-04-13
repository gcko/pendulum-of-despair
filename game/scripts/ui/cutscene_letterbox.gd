extends Node
## Controls letterbox bar animation for cutscene overlay.
## Tweens top/bottom ColorRects to create cinematic letterbox effect.

signal letterbox_in_complete
signal letterbox_out_complete

## Bar height in pixels (~12.5% of 720px viewport).
const BAR_HEIGHT: int = 90

## Reference to the top letterbox bar (ColorRect).
## Set via @export in editor or manually in tests.
@export var top_bar: ColorRect
## Reference to the bottom letterbox bar (ColorRect).
@export var bottom_bar: ColorRect

var _tween: Tween = null


func _ready() -> void:
	# Resolve @export NodePaths that Godot may not auto-resolve in headless.
	if top_bar == null:
		top_bar = get_node_or_null("../LetterboxTop")
	if bottom_bar == null:
		bottom_bar = get_node_or_null("../LetterboxBottom")


func animate_in(duration: float = 0.5) -> void:
	if top_bar == null or bottom_bar == null:
		letterbox_in_complete.emit()
		return
	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(top_bar, "custom_minimum_size:y", float(BAR_HEIGHT), duration)
	_tween.tween_property(bottom_bar, "custom_minimum_size:y", float(BAR_HEIGHT), duration)
	_tween.tween_property(bottom_bar, "position:y", 720.0 - float(BAR_HEIGHT), duration)
	_tween.chain().tween_callback(_on_in_complete)


func animate_out(duration: float = 0.5) -> void:
	if top_bar == null or bottom_bar == null:
		letterbox_out_complete.emit()
		return
	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(top_bar, "custom_minimum_size:y", 0.0, duration)
	_tween.tween_property(bottom_bar, "custom_minimum_size:y", 0.0, duration)
	_tween.tween_property(bottom_bar, "position:y", 720.0, duration)
	_tween.chain().tween_callback(_on_out_complete)


func set_instant(visible: bool) -> void:
	_kill_tween()
	if top_bar == null or bottom_bar == null:
		return
	var height: float = float(BAR_HEIGHT) if visible else 0.0
	top_bar.custom_minimum_size.y = height
	bottom_bar.custom_minimum_size.y = height
	if visible:
		bottom_bar.position.y = 720.0 - height
	else:
		bottom_bar.position.y = 720.0


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


func _on_in_complete() -> void:
	letterbox_in_complete.emit()


func _on_out_complete() -> void:
	letterbox_out_complete.emit()
