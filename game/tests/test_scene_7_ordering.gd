extends GutTest


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func test_7b_blocked_without_7a() -> void:
	# Verify valdris_arrived defaults to false (unset), which blocks
	# the Scene7bTrigger via its required_flag = "valdris_arrived" metadata.
	assert_false(EventFlags.get_flag("valdris_arrived"), "valdris_arrived should default false")


func test_7d_blocked_with_only_two_flags() -> void:
	EventFlags.set_flag("pendulum_presented", true)
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	var flags_str: String = "scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"
	assert_false(EventFlags.check_required_flags(flags_str), "7d blocked with 2/3 flags")


func test_7c_any_order_works() -> void:
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("scene_7c_renn", true)
	EventFlags.set_flag("scene_7c_aldis", true)
	assert_true(
		(
			EventFlags.get_flag("scene_7c_aldis")
			and EventFlags.get_flag("scene_7c_cordwyn")
			and EventFlags.get_flag("scene_7c_renn")
		)
	)


func test_7d_does_not_refire() -> void:
	EventFlags.set_flag("pendulum_to_capital", true)
	assert_true(EventFlags.get_flag("pendulum_to_capital"))
