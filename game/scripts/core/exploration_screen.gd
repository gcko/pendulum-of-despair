class_name ExplorationScreen
extends RefCounted
## Screen presentation for the exploration scene: the fade-to-black map
## transition and the location-name flash panel.
##
## Extracted from exploration.gd (GAP-087). It owns the two tweens and the
## last-flashed name so nothing else has to reason about their lifetimes.

const FADE_DURATION: float = 0.3
## Location flash timing: fade in, hold, fade out (ui-design.md § 3.5).
const FLASH_FADE: float = 0.5
const FLASH_HOLD: float = 2.0

var _exploration: Exploration
var _flash_tween: Tween = null
var _transition_tween: Tween = null
var _last_flash_id: String = ""


func _init(exploration: Exploration) -> void:
	_exploration = exploration


## Flash a place name the first time the party arrives on it. Re-entering the
## same location without visiting another one does not re-announce it.
func flash_location_once(location_name: String) -> void:
	if location_name == "" or location_name == _last_flash_id:
		return
	flash_location_name(location_name)
	_last_flash_id = location_name


## Fade a line of text in over the map, hold it, and fade it out.
func flash_location_name(text: String) -> void:
	_kill_flash_tween()
	var panel: PanelContainer = _exploration.get_location_panel()
	_exploration.get_location_label().text = text
	panel.visible = true
	panel.modulate = Color(1, 1, 1, 0)
	_flash_tween = _exploration.create_tween()
	_flash_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_flash_tween.tween_property(panel, "modulate:a", 1.0, FLASH_FADE)
	_flash_tween.tween_interval(FLASH_HOLD)
	_flash_tween.tween_property(panel, "modulate:a", 0.0, FLASH_FADE)
	_flash_tween.tween_callback(panel.hide)


## Fade out, swap the map, fade back in. The danger counter resets on every
## transition (combat-formulas.md § Danger Counter).
func transition_to_map(target_map: String, target_spawn: String) -> void:
	_exploration.reset_danger_counter()
	_exploration.set_transitioning(true)
	var auto_seq: ExplorationAutoSequence = _exploration.get_auto_sequence()
	auto_seq.kill_auto_walk_tween()
	auto_seq.kill_arrival_tween()
	if _flash_tween != null and _flash_tween.is_valid():
		_kill_flash_tween()
		_exploration.get_location_panel().visible = false
	var fade_rect: ColorRect = _exploration.get_fade_rect()
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = _exploration.create_tween()
	_transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_transition_tween.tween_property(fade_rect, "color:a", 1.0, FADE_DURATION)
	_transition_tween.tween_callback(_do_map_swap.bind(target_map, target_spawn))
	_transition_tween.tween_property(fade_rect, "color:a", 0.0, FADE_DURATION)
	_transition_tween.tween_callback(end_transition)


## Give the player control back once the screen is clear again.
func end_transition() -> void:
	_exploration.get_fade_rect().visible = false
	_exploration.set_transitioning(false)
	var player: Node2D = _exploration.get_player()
	if player != null and not _exploration.is_in_cutscene() and not _exploration.is_in_auto_walk():
		player.set_input_enabled(true)


## Mid-fade map swap. A target that no longer exists aborts the transition
## rather than leaving the screen black.
func _do_map_swap(target_map: String, target_spawn: String) -> void:
	var map_path: String = Exploration.MAP_BASE_PATH + target_map + ".tscn"
	if not ResourceLoader.exists(map_path):
		push_error("Exploration: Transition target not found: %s" % map_path)
		_abort_transition()
		return
	_exploration.load_map(target_map, target_spawn)


## Drop the half-finished transition and anything it was going to hand to the
## next map.
func _abort_transition() -> void:
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_exploration.set_pending_cutscene({})
	_exploration.set_cutscene_return({})
	end_transition()


func _kill_flash_tween() -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = null
