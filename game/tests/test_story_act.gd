extends GutTest
## Tests for StoryAct static helpers (period, danger scale, enemy act).
## Canon: combat-formulas.md § Danger Counter > 'Act scaling'
## (Act I x1.0, Act II x1.1, Interlude x1.2, Act III x1.1).

const SA = preload("res://scripts/core/story_act.gd")
const TestHelpers = preload("res://tests/test_helpers.gd")


func before_each() -> void:
	TestHelpers.reset_game_state()


func after_each() -> void:
	TestHelpers.reset_game_state()


func test_default_period_is_act_i() -> void:
	assert_eq(SA.get_period(), "act_i", "no flags set should be Act I")


func test_act_ii_started_gives_act_ii() -> void:
	EventFlags.set_flag("act_ii_started", true)
	assert_eq(SA.get_period(), "act_ii")


func test_interlude_takes_precedence_over_act_ii() -> void:
	EventFlags.set_flag("act_ii_started", true)
	EventFlags.set_flag("interlude_start", true)
	assert_eq(SA.get_period(), "interlude")


func test_act_iii_takes_precedence_over_all() -> void:
	EventFlags.set_flag("act_ii_started", true)
	EventFlags.set_flag("interlude_start", true)
	EventFlags.set_flag("act_iii_started", true)
	assert_eq(SA.get_period(), "act_iii")


func test_danger_scale_act_i() -> void:
	# combat-formulas.md act-scaling table: Act I x1.0
	assert_eq(SA.get_danger_scale(), 1.0)


func test_danger_scale_act_ii() -> void:
	# combat-formulas.md act-scaling table: Act II x1.1
	EventFlags.set_flag("act_ii_started", true)
	assert_eq(SA.get_danger_scale(), 1.1)


func test_danger_scale_interlude() -> void:
	# combat-formulas.md act-scaling table: Interlude x1.2
	EventFlags.set_flag("act_ii_started", true)
	EventFlags.set_flag("interlude_start", true)
	assert_eq(SA.get_danger_scale(), 1.2)


func test_danger_scale_act_iii() -> void:
	# combat-formulas.md act-scaling table: Act III x1.1
	EventFlags.set_flag("act_iii_started", true)
	assert_eq(SA.get_danger_scale(), 1.1)


func test_danger_scale_act_iv_and_epilogue_hold_at_act_iii() -> void:
	# combat-formulas.md act-scaling table now carries explicit Act IV and
	# Epilogue rows, both x1.1 (#265). get_period() has no branch for either,
	# so this pins the carried value against the tabled one: if a later change
	# gives Act IV or the Epilogue its own multiplier, the branch has to be
	# added here too rather than silently reading back as Act III.
	EventFlags.set_flag("act_iii_started", true)
	EventFlags.set_flag("pallor_defeated", true)
	assert_eq(SA.get_period(), "act_iii", "Act IV reports as act_iii by design")
	assert_eq(SA.get_danger_scale(), 1.1, "Act IV row: x1.1")
	EventFlags.set_flag("epilogue_complete", true)
	assert_eq(SA.get_period(), "act_iii", "the Epilogue reports as act_iii by design")
	assert_eq(SA.get_danger_scale(), 1.1, "Epilogue / Post-game row: x1.1")


func test_enemy_act_matches_period_for_each_flag_regime() -> void:
	assert_eq(SA.get_enemy_act(), "act_i")
	EventFlags.set_flag("act_ii_started", true)
	assert_eq(SA.get_enemy_act(), "act_ii")
	EventFlags.set_flag("interlude_start", true)
	assert_eq(SA.get_enemy_act(), "interlude")
	EventFlags.set_flag("act_iii_started", true)
	assert_eq(SA.get_enemy_act(), "act_iii")
