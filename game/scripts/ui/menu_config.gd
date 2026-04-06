extends Control
## Config sub-screen: 17+ settings with live adjustment.

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

## Setting definitions: key, display name, type, options/range, default.
const SETTINGS: Array[Dictionary] = [
	{"key": "battle_speed", "name": "Battle Speed", "type": "range", "min": 1, "max": 6},
	{"key": "atb_mode", "name": "ATB Mode", "type": "cycle", "options": ["active", "wait"]},
	{
		"key": "text_speed",
		"name": "Text Speed",
		"type": "cycle",
		"options": ["slow", "normal", "fast", "instant"]
	},
	{
		"key": "battle_cursor",
		"name": "Battle Cursor",
		"type": "cycle",
		"options": ["reset", "memory"]
	},
	{"key": "sound_mode", "name": "Sound", "type": "cycle", "options": ["stereo", "mono"]},
	{"key": "music_volume", "name": "Music Volume", "type": "range", "min": 0, "max": 10},
	{"key": "sfx_volume", "name": "SFX Volume", "type": "range", "min": 0, "max": 10},
	{"key": "screen_shake", "name": "Screen Shake", "type": "toggle"},
	{"key": "mode7_intensity", "name": "Mode 7 Intensity", "type": "range", "min": 1, "max": 6},
	{"key": "window_color_r", "name": "Window R", "type": "range", "min": 0, "max": 31},
	{"key": "window_color_g", "name": "Window G", "type": "range", "min": 0, "max": 31},
	{"key": "window_color_b", "name": "Window B", "type": "range", "min": 0, "max": 31},
	{"key": "patience_mode", "name": "Patience Mode", "type": "toggle"},
	{
		"key": "color_blind_mode",
		"name": "Color-Blind Mode",
		"type": "cycle",
		"options": ["off", "deutan_protan", "tritan"]
	},
	{"key": "high_res_text", "name": "High-Res Text", "type": "toggle"},
	{"key": "reduce_motion", "name": "Reduce Motion", "type": "toggle"},
	{
		"key": "flash_intensity",
		"name": "Flash Intensity",
		"type": "cycle",
		"options": ["off", "reduced", "full"]
	},
	{
		"key": "transition_style",
		"name": "Transition Style",
		"type": "cycle",
		"options": ["classic", "simple"]
	},
	{"key": "sfx_captions", "name": "SFX Captions", "type": "toggle"},
]

var _cursor_index: int = 0
var _config: Dictionary = {}

## Previous values for cascade restore.
var _pre_patience_atb: String = "active"
var _pre_patience_speed: int = 3
var _pre_reduce_shake: bool = true
var _pre_reduce_mode7: int = 6
var _pre_reduce_flash: String = "full"
var _pre_reduce_transition: String = "classic"
var _patience_was_on: bool = false
var _reduce_was_on: bool = false

@onready var _setting_labels: Array[Label] = []
@onready var _value_labels: Array[Label] = []
@onready var _preview_rect: ColorRect = $PreviewRect


func _ready() -> void:
	_setting_labels = []
	_value_labels = []
	for i: int in range(SETTINGS.size()):
		var sl: Label = get_node_or_null("SettingList/Name%d" % i)
		var vl: Label = get_node_or_null("SettingList/Value%d" % i)
		_setting_labels.append(sl)
		_value_labels.append(vl)


func open() -> void:
	_config = PartyState.get_config().duplicate()
	_cursor_index = 0
	_patience_was_on = _config.get("patience_mode", false)
	_reduce_was_on = _config.get("reduce_motion", false)
	_apply_cascades()
	_update_display()


func close() -> void:
	PartyState.save_config()


func handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_down"):
		_cursor_index = (_cursor_index + 1) % SETTINGS.size()
		_update_display()
		return true
	if event.is_action_pressed("ui_up"):
		_cursor_index = (_cursor_index - 1 + SETTINGS.size()) % SETTINGS.size()
		_update_display()
		return true
	if event.is_action_pressed("ui_left"):
		_adjust(-1)
		return true
	if event.is_action_pressed("ui_right"):
		_adjust(1)
		return true
	if event.is_action_pressed("ui_accept"):
		_adjust(1)  # Accept also cycles forward
		return true
	return false


func _adjust(direction: int) -> void:
	var setting: Dictionary = SETTINGS[_cursor_index]
	var key: String = setting.get("key", "")

	# Check if this setting is disabled by cascade
	if _is_setting_disabled(key):
		return

	var setting_type: String = setting.get("type", "")
	match setting_type:
		"range":
			_adjust_range(key, direction, setting)
		"cycle":
			_adjust_cycle(key, direction, setting)
		"toggle":
			_adjust_toggle(key)

	# Apply cascades
	_apply_cascades()
	_update_display()


func _adjust_range(key: String, direction: int, setting: Dictionary) -> void:
	# Window color is stored as nested object
	var actual_key: String = key
	var is_window_color: bool = key.begins_with("window_color_")
	var current: int = 0
	if is_window_color:
		var channel: String = key.replace("window_color_", "")
		var wc: Dictionary = _config.get("window_color", {"r": 0, "g": 0, "b": 8})
		current = wc.get(channel, 0)
	else:
		current = _config.get(actual_key, setting.get("min", 0))

	var new_val: int = clampi(current + direction, setting.get("min", 0), setting.get("max", 10))

	if is_window_color:
		var channel: String = key.replace("window_color_", "")
		var wc: Dictionary = _config.get("window_color", {"r": 0, "g": 0, "b": 8})
		wc[channel] = new_val
		_config["window_color"] = wc
		PartyState.set_config("window_color", wc)
	else:
		_config[actual_key] = new_val
		PartyState.set_config(actual_key, new_val)


func _adjust_cycle(key: String, direction: int, setting: Dictionary) -> void:
	var options: Array = setting.get("options", [])
	if options.is_empty():
		return
	var current: String = str(_config.get(key, options[0]))
	var idx: int = 0
	for i: int in range(options.size()):
		if str(options[i]) == current:
			idx = i
			break
	idx = (idx + direction + options.size()) % options.size()
	_config[key] = options[idx]
	PartyState.set_config(key, options[idx])


func _adjust_toggle(key: String) -> void:
	var current: bool = _config.get(key, false)
	_config[key] = not current
	PartyState.set_config(key, not current)


func _apply_cascades() -> void:
	# Patience Mode cascade
	var patience: bool = _config.get("patience_mode", false)
	if patience and not _patience_was_on:
		# Capture current values before forcing cascade
		_pre_patience_atb = _config.get("atb_mode", "active")
		_pre_patience_speed = _config.get("battle_speed", 3)
	if patience:
		_config["atb_mode"] = "wait"
		_config["battle_speed"] = 6
		PartyState.set_config("atb_mode", "wait")
		PartyState.set_config("battle_speed", 6)
	elif _patience_was_on:
		# Restore previous values
		_config["atb_mode"] = _pre_patience_atb
		_config["battle_speed"] = _pre_patience_speed
		PartyState.set_config("atb_mode", _pre_patience_atb)
		PartyState.set_config("battle_speed", _pre_patience_speed)
	_patience_was_on = patience

	# Reduce Motion cascade
	var reduce: bool = _config.get("reduce_motion", false)
	if reduce and not _reduce_was_on:
		_pre_reduce_shake = _config.get("screen_shake", true)
		_pre_reduce_mode7 = _config.get("mode7_intensity", 6)
		_pre_reduce_flash = _config.get("flash_intensity", "full")
		_pre_reduce_transition = _config.get("transition_style", "classic")
	if reduce:
		_config["screen_shake"] = false
		_config["mode7_intensity"] = 1
		_config["flash_intensity"] = "off"
		_config["transition_style"] = "simple"
		PartyState.set_config("screen_shake", false)
		PartyState.set_config("mode7_intensity", 1)
		PartyState.set_config("flash_intensity", "off")
		PartyState.set_config("transition_style", "simple")
	elif _reduce_was_on:
		_config["screen_shake"] = _pre_reduce_shake
		_config["mode7_intensity"] = _pre_reduce_mode7
		_config["flash_intensity"] = _pre_reduce_flash
		_config["transition_style"] = _pre_reduce_transition
		PartyState.set_config("screen_shake", _pre_reduce_shake)
		PartyState.set_config("mode7_intensity", _pre_reduce_mode7)
		PartyState.set_config("flash_intensity", _pre_reduce_flash)
		PartyState.set_config("transition_style", _pre_reduce_transition)
	_reduce_was_on = reduce


func _is_setting_disabled(key: String) -> bool:
	var patience: bool = _config.get("patience_mode", false)
	if patience and key in ["atb_mode", "battle_speed"]:
		return true
	var reduce: bool = _config.get("reduce_motion", false)
	if reduce and key in ["screen_shake", "mode7_intensity", "flash_intensity", "transition_style"]:
		return true
	return false


func _update_display() -> void:
	for i: int in range(SETTINGS.size()):
		var setting: Dictionary = SETTINGS[i]
		var key: String = setting.get("key", "")
		var is_disabled: bool = _is_setting_disabled(key)

		if i < _setting_labels.size() and _setting_labels[i] != null:
			_setting_labels[i].text = setting.get("name", "")
			if i == _cursor_index:
				_setting_labels[i].modulate = COLOR_DISABLED if is_disabled else COLOR_SELECTED
			else:
				_setting_labels[i].modulate = COLOR_DISABLED if is_disabled else COLOR_NORMAL

		if i < _value_labels.size() and _value_labels[i] != null:
			_value_labels[i].text = _format_value(setting, key)
			if i == _cursor_index:
				_value_labels[i].modulate = COLOR_DISABLED if is_disabled else COLOR_SELECTED
			else:
				_value_labels[i].modulate = COLOR_DISABLED if is_disabled else COLOR_NORMAL

	# Window color preview
	if _preview_rect != null:
		var wc: Dictionary = _config.get("window_color", {"r": 0, "g": 0, "b": 8})
		var r: float = float(wc.get("r", 0)) / 31.0
		var g: float = float(wc.get("g", 0)) / 31.0
		var b: float = float(wc.get("b", 8)) / 31.0
		_preview_rect.color = Color(r, g, b)


func _format_value(setting: Dictionary, key: String) -> String:
	var setting_type: String = setting.get("type", "")
	match setting_type:
		"range":
			if key.begins_with("window_color_"):
				var channel: String = key.replace("window_color_", "")
				var wc: Dictionary = _config.get("window_color", {"r": 0, "g": 0, "b": 8})
				return str(wc.get(channel, 0))
			return str(_config.get(key, 0))
		"cycle":
			var val: String = str(_config.get(key, ""))
			return val.replace("_", "-").capitalize()
		"toggle":
			var val: bool = _config.get(key, false)
			return "On" if val else "Off"
	return ""
