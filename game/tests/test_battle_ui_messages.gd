extends GutTest
## Tests BattleUI's battle-message window (ui-design.md § 2.5). A line must stay
## legible for a minimum time before the next one may replace it, so an action
## resolving on the following frame — an enemy attacking right after a paralyzed
## member's turn was auto-skipped — cannot flash the earlier line past the player
## unread (#260). Boots the real battle scene: the label, its timer and the queue
## only exist in the assembled UI.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const BattleUIScript = preload("res://scripts/ui/battle_ui.gd")

var _booted: Node = null


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	randomize()


## Boot a battle and hand back its UI with _process off on both nodes, so the
## message timers advance only by the exact amounts a test asks for.
func _boot_ui() -> CanvasLayer:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	await wait_frames(3)
	_booted = battle
	battle.set_process(false)
	var ui: CanvasLayer = battle._ui
	ui.set_process(false)
	return ui


func test_a_new_message_waits_while_the_current_one_is_still_fresh() -> void:
	var ui: CanvasLayer = await _boot_ui()
	ui._on_message("Edren is paralyzed and can't move!")
	ui._process(0.016)  # one rendered frame — nowhere near readable yet

	ui._on_message("Ley Vermin attacks Edren!")

	assert_eq(
		ui._message_label.text,
		"Edren is paralyzed and can't move!",
		"the fresh line keeps the window"
	)
	assert_eq(ui._message_queue.size(), 1, "the newcomer waits its turn")


func test_the_waiting_message_takes_over_once_the_line_has_been_read() -> void:
	var ui: CanvasLayer = await _boot_ui()
	ui._on_message("first")
	ui._process(0.016)
	ui._on_message("second")

	ui._process(BattleUIScript.MESSAGE_MIN_DISPLAY)

	assert_eq(ui._message_label.text, "second", "the queued line takes the window")
	assert_true(ui._message_queue.is_empty(), "and leaves the queue empty")
	assert_true(ui._message_area.visible, "the window stays up for it")


func test_a_message_arriving_after_the_minimum_replaces_immediately() -> void:
	var ui: CanvasLayer = await _boot_ui()
	ui._on_message("first")
	ui._process(BattleUIScript.MESSAGE_MIN_DISPLAY)

	ui._on_message("second")

	assert_eq(ui._message_label.text, "second", "nothing queues once the line has been read")
	assert_true(ui._message_queue.is_empty(), "so nothing is left waiting")


func test_the_queue_drops_the_oldest_line_when_a_burst_overflows_it() -> void:
	var ui: CanvasLayer = await _boot_ui()
	var cap: int = BattleUIScript.MESSAGE_QUEUE_MAX
	ui._on_message("shown")

	for i: int in range(cap + 2):
		ui._on_message("queued %d" % i)

	assert_eq(ui._message_queue.size(), cap, "the queue is capped so it cannot lag the battle")
	assert_eq(ui._message_queue[cap - 1], "queued %d" % (cap + 1), "the newest line survives")
	assert_eq(ui._message_queue[0], "queued 2", "the oldest queued lines are the ones dropped")


func test_the_window_still_fades_after_its_hold() -> void:
	var ui: CanvasLayer = await _boot_ui()
	ui._on_message("only")

	ui._process(BattleUIScript.MESSAGE_HOLD)

	assert_false(ui._message_area.visible, "the window fades when its hold elapses")
