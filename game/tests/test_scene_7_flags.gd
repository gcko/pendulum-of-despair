extends GutTest


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func test_scene_7a_requires_maren_warning() -> void:
	assert_false(EventFlags.get_flag("maren_warning"))
	EventFlags.set_flag("maren_warning", true)
	assert_true(EventFlags.get_flag("maren_warning"))


func test_scene_7b_requires_valdris_arrived() -> void:
	assert_false(EventFlags.get_flag("valdris_arrived"))
	EventFlags.set_flag("valdris_arrived", true)
	assert_true(EventFlags.get_flag("valdris_arrived"))
	assert_false(EventFlags.get_flag("pendulum_presented"))


func test_scene_7c_flags_independent() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	assert_true(EventFlags.get_flag("scene_7c_aldis"))
	assert_false(EventFlags.get_flag("scene_7c_cordwyn"))
	assert_false(EventFlags.get_flag("scene_7c_renn"))


func test_scene_7d_requires_all_three_7c_flags() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	var all_set: bool = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
	)
	assert_false(all_set, "Should not pass with only 2/3 flags")
	EventFlags.set_flag("scene_7c_renn", true)
	all_set = (
		EventFlags.get_flag("scene_7c_aldis")
		and EventFlags.get_flag("scene_7c_cordwyn")
		and EventFlags.get_flag("scene_7c_renn")
	)
	assert_true(all_set, "Should pass with all 3 flags")


func test_pendulum_to_capital_set_after_7d() -> void:
	EventFlags.set_flag("pendulum_to_capital", true)
	assert_true(EventFlags.get_flag("pendulum_to_capital"))


func test_flag_idempotency() -> void:
	EventFlags.set_flag("valdris_arrived", true)
	EventFlags.set_flag("valdris_arrived", true)
	assert_true(EventFlags.get_flag("valdris_arrived"))


func test_flags_survive_save_load() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("pendulum_presented", true)
	var save_data: Dictionary = EventFlags.to_save_data()
	EventFlags.clear_all()
	assert_false(EventFlags.get_flag("scene_7c_aldis"))
	EventFlags.load_from_save(save_data)
	assert_true(EventFlags.get_flag("scene_7c_aldis"))
	assert_true(EventFlags.get_flag("scene_7c_cordwyn"))
	assert_true(EventFlags.get_flag("pendulum_presented"))


func test_check_required_flags_all_set() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("scene_7c_renn", true)
	EventFlags.set_flag("pendulum_presented", true)
	var flags_str: String = "scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"
	assert_true(EventFlags.check_required_flags(flags_str))


func test_check_required_flags_one_missing() -> void:
	EventFlags.set_flag("scene_7c_aldis", true)
	EventFlags.set_flag("scene_7c_cordwyn", true)
	EventFlags.set_flag("pendulum_presented", true)
	var flags_str: String = "scene_7c_aldis,scene_7c_cordwyn,scene_7c_renn,pendulum_presented"
	assert_false(EventFlags.check_required_flags(flags_str))
