extends CanvasLayer
## Ritual meter HUD — tracks cleansing ritual progress between waves.

const COLOR_GREEN: Color = Color("#44cc44")
const COLOR_YELLOW: Color = Color("#cccc44")
const COLOR_ORANGE: Color = Color("#cc8844")
const COLOR_RED: Color = Color("#cc4444")

const STATUS_TEXT: Dictionary = {
	"high": "The Fenmother's light holds steady...",
	"mid": "The ritual strains against the corruption...",
	"low": "The ritual weakens... hold the line!",
	"critical": "The Fenmother's light flickers dangerously!",
	"failed": "The corruption surges back!",
}

var meter_value: float = 100.0

@onready var _fill_bar: ColorRect = $Panel/Layout/BarContainer/BarBg/BarFill
@onready var _bar_bg: ColorRect = $Panel/Layout/BarContainer/BarBg
@onready var _status_label: Label = $Panel/Layout/StatusLabel


func show_meter() -> void:
	visible = true
	_update_display()


func hide_meter() -> void:
	visible = false


func set_value(new_value: float) -> void:
	meter_value = clampf(new_value, 0.0, 100.0)
	_update_display()


func drain(amount: float) -> void:
	set_value(meter_value - amount)


func recover(amount: float) -> void:
	set_value(meter_value + amount)


func is_failed() -> bool:
	return meter_value <= 0.0


func reset_for_retry() -> void:
	set_value(25.0)


func calculate_drain(
	_wave_num: int, ko_count: int, turn_count: int, turn_threshold: int, has_recovery: bool
) -> float:
	var base_drain: float = 15.0
	var ko_penalty: float = 10.0 * ko_count
	var turn_penalty: float = 2.0 * maxf(0.0, turn_count - turn_threshold)
	var recovery: float = 10.0 if has_recovery else 0.0
	return base_drain + ko_penalty + turn_penalty - recovery


func _update_display() -> void:
	if _fill_bar != null and _bar_bg != null:
		_fill_bar.size.x = _bar_bg.size.x * (meter_value / 100.0)
		_fill_bar.color = _get_color()
	if _status_label != null:
		_status_label.text = _get_status_text()


func _get_color() -> Color:
	if meter_value >= 75.0:
		return COLOR_GREEN
	if meter_value >= 50.0:
		return COLOR_YELLOW
	if meter_value >= 25.0:
		return COLOR_ORANGE
	return COLOR_RED


func _get_status_text() -> String:
	if meter_value <= 0.0:
		return STATUS_TEXT["failed"]
	if meter_value < 25.0:
		return STATUS_TEXT["critical"]
	if meter_value < 50.0:
		return STATUS_TEXT["low"]
	if meter_value < 75.0:
		return STATUS_TEXT["mid"]
	return STATUS_TEXT["high"]
