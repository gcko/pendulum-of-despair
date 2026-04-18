extends Node
## Controls letterbox bar animation for cutscene overlay.
## Tweens top/bottom ColorRects to create cinematic letterbox effect.

signal letterbox_in_complete
signal letterbox_out_complete

## Bar height in viewport pixels (88px = 22 game-world pixels at 4x zoom).
const BAR_HEIGHT: int = 88

## Reference to the top letterbox bar (ColorRect).
## Set via @export in editor or manually in tests.
@export var top_bar: ColorRect
## Reference to the bottom letterbox bar (ColorRect).
@export var bottom_bar: ColorRect

var _tween: Tween = null


func _ready() -> void:
	# @export NodePath vars are resolved by the scene loader.
	# If null after _ready, animate_in/animate_out emit signals immediately.
	pass


func animate_in(duration: float = 0.5) -> void:
	if top_bar == null or bottom_bar == null:
		letterbox_in_complete.emit()
		return
	_kill_tween()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(top_bar, "size:y", float(BAR_HEIGHT), duration)
	_tween.tween_property(bottom_bar, "size:y", float(BAR_HEIGHT), duration)
	_tween.tween_property(bottom_bar, "position:y", 720.0 - float(BAR_HEIGHT), duration)
	_tween.chain().tween_callback(_on_in_complete)


func animate_out(duration: float = 0.5) -> void:
	if top_bar == null or bottom_bar == null:
		letterbox_out_complete.emit()
		return
	_kill_tween()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(top_bar, "size:y", 0.0, duration)
	_tween.tween_property(bottom_bar, "size:y", 0.0, duration)
	_tween.tween_property(bottom_bar, "position:y", 720.0, duration)
	_tween.chain().tween_callback(_on_out_complete)


func set_instant(visible: bool) -> void:
	_kill_tween()
	if top_bar == null or bottom_bar == null:
		if visible:
			letterbox_in_complete.emit()
		else:
			letterbox_out_complete.emit()
		return
	var height: float = float(BAR_HEIGHT) if visible else 0.0
	top_bar.size.y = height
	bottom_bar.size.y = height
	if visible:
		bottom_bar.position.y = 720.0 - height
		letterbox_in_complete.emit()
	else:
		bottom_bar.position.y = 720.0
		letterbox_out_complete.emit()


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


func _on_in_complete() -> void:
	letterbox_in_complete.emit()


func _on_out_complete() -> void:
	letterbox_out_complete.emit()
