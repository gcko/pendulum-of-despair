extends GutTest
## Tests for CutsceneLetterbox bar animation.

const CutsceneLetterbox := preload("res://scripts/ui/cutscene_letterbox.gd")


func _create_letterbox() -> Node:
	var root := Control.new()
	add_child_autofree(root)

	var top := ColorRect.new()
	top.name = "LetterboxTop"
	top.color = Color.BLACK
	top.size = Vector2(1280, 0)
	root.add_child(top)

	var bottom := ColorRect.new()
	bottom.name = "LetterboxBottom"
	bottom.color = Color.BLACK
	bottom.size = Vector2(1280, 0)
	bottom.position = Vector2(0, 720)
	root.add_child(bottom)

	var lb: Node = CutsceneLetterbox.new()
	lb.top_bar = top
	lb.bottom_bar = bottom
	root.add_child(lb)
	return lb


func test_animate_in_sets_bar_height() -> void:
	var lb := _create_letterbox()
	watch_signals(lb)
	lb.animate_in(0.01)
	await get_tree().create_timer(0.1).timeout
	assert_eq(
		lb.top_bar.size.y, float(CutsceneLetterbox.BAR_HEIGHT), "top bar should reach BAR_HEIGHT"
	)
	assert_signal_emitted(lb, "letterbox_in_complete")


func test_animate_out_sets_bar_height_zero() -> void:
	var lb := _create_letterbox()
	lb.set_instant(true)
	watch_signals(lb)
	lb.animate_out(0.01)
	await get_tree().create_timer(0.1).timeout
	assert_eq(lb.top_bar.size.y, 0.0, "top bar should return to 0")
	assert_signal_emitted(lb, "letterbox_out_complete")


func test_set_instant_true_snaps_bars() -> void:
	var lb := _create_letterbox()
	lb.set_instant(true)
	assert_eq(
		lb.top_bar.size.y, float(CutsceneLetterbox.BAR_HEIGHT), "top bar should snap to BAR_HEIGHT"
	)


func test_set_instant_false_removes_bars() -> void:
	var lb := _create_letterbox()
	lb.set_instant(true)
	lb.set_instant(false)
	assert_eq(lb.top_bar.size.y, 0.0, "top bar should snap to 0")


func test_bar_height_pixel_grid_aligned() -> void:
	assert_eq(
		CutsceneLetterbox.BAR_HEIGHT, 88, "BAR_HEIGHT should be 88 (22 game-world px at 4x zoom)"
	)
	assert_eq(
		CutsceneLetterbox.BAR_HEIGHT % 4, 0, "BAR_HEIGHT divisible by 4 for pixel-grid alignment"
	)
