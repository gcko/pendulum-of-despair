class_name DisplaySettings
extends RefCounted
## Maps the player's Fullscreen config setting onto a window mode (#453).
## The window is passed in, never looked up, so tests can drive a stand-in:
## headless Godot reports every in-tree window as minimized, so the real root
## window cannot show whether a mode change happened.

## Config key, shared by defaults.json, the Config menu and the boot apply.
const KEY: String = "fullscreen"


## Whether the config asks for fullscreen. True only for a JSON boolean true:
## a missing key, or a value that is not a JSON boolean (a hand-edited null,
## string or number), means the shipped default, Off.
static func is_fullscreen(config: Dictionary) -> bool:
	return is_on(config.get(KEY, false))


## The rule for any On/Off setting: only a real boolean true is On. The Config
## menu reads every toggle row through this, so a row never shows On for a
## value the window treats as Off.
static func is_on(value: Variant) -> bool:
	return value is bool and value


## The window mode the config asks for. MODE_FULLSCREEN, never
## EXCLUSIVE_FULLSCREEN: borderless at the display's native resolution, the
## mode Godot's own ui_toggle_fullscreen uses, and it leaves the display's
## video mode alone.
static func window_mode_for(config: Dictionary) -> Window.Mode:
	return Window.MODE_FULLSCREEN if is_fullscreen(config) else Window.MODE_WINDOWED


## Put `window` in the mode the config asks for. A window already in the
## requested state is left alone, so applying an unchanged config does not
## un-maximize a windowed window or re-enter fullscreen.
static func apply(config: Dictionary, window: Window) -> void:
	var want: Window.Mode = window_mode_for(config)
	var is_full: bool = window.mode == Window.MODE_FULLSCREEN
	if (want == Window.MODE_FULLSCREEN) == is_full:
		return
	window.mode = want
