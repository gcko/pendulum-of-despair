extends GutTest
## Tests for ATB gauge system.

const ATBScript := preload("res://scripts/combat/atb_system.gd")

## Both seconds-per-turn columns of combat-formulas.md § ATB Gauge System >
## Battle Speed Config — Maren Lv1 (SPD 8) and Sable Lv1 (SPD 18) — keyed
## {battle speed: {SPD: printed seconds}}. Covering one column was not enough:
## the SPD 18 cell at speed 5 shipped as 4.1s when the floor in the fill-rate
## formula makes it 4.2s, and a guard that ticked only Maren could not see it
## (#177).
const DOCUMENTED_BATTLE_SPEED_SECONDS: Dictionary = {
	1: {8: 1.3, 18: 1.0},
	2: {8: 1.6, 18: 1.2},
	3: {8: 2.7, 18: 2.1},
	4: {8: 4.0, 18: 3.1},
	5: {8: 5.4, 18: 4.2},
	6: {8: 8.1, 18: 6.2},
}

## combat-formulas.md § ATB Pacing at Key Milestones, every row, all at battle
## speed 3. `step` is the precision the row is printed to, which is what the
## rounding assertion below compares against.
const DOCUMENTED_PACING_MILESTONES: Array = [
	{"who": "Maren Lv1", "spd": 8, "mods": [], "rate": 99, "seconds": 2.7, "step": 0.1},
	{"who": "Sable Lv1", "spd": 18, "mods": [], "rate": 129, "seconds": 2.1, "step": 0.1},
	{"who": "Maren Lv70", "spd": 49, "mods": [], "rate": 222, "seconds": 1.20, "step": 0.01},
	{"who": "Edren Lv70", "spd": 65, "mods": [], "rate": 270, "seconds": 0.99, "step": 0.01},
	{"who": "Sable Lv70", "spd": 128, "mods": [], "rate": 459, "seconds": 0.58, "step": 0.01},
	{
		"who": "Sable Lv70 + Haste",
		"spd": 128,
		"mods": [1.5],
		"rate": 688,
		"seconds": 0.39,
		"step": 0.01,
	},
	{"who": "Lv70 enemy", "spd": 60, "mods": [], "rate": 255, "seconds": 1.0, "step": 0.1},
]

var _atb: Node


func before_each() -> void:
	_atb = ATBScript.new()
	add_child_autofree(_atb)


func after_each() -> void:
	_atb = null


# --- Fill Rate ---


func test_fill_rate_maren_lv1_speed3() -> void:
	# SPD 8, battle speed 3 (factor 3.0), no status mods
	# fill_rate = floor((8 + 25) * 3.0 * 1.0) = 99
	# combat-formulas.md § ATB Gauge System > ATB Pacing at Key Milestones.
	var rate: int = _atb.calculate_fill_rate(8, 3, [])
	assert_eq(rate, 99, "Maren Lv1 at speed 3")


func test_fill_rate_sable_lv1_speed3() -> void:
	# SPD 18, speed 3 → floor((18+25)*3.0) = 129
	var rate: int = _atb.calculate_fill_rate(18, 3, [])
	assert_eq(rate, 129, "Sable Lv1 at speed 3")


func test_fill_rate_with_haste() -> void:
	# SPD 10, speed 3, haste (1.5x)
	# floor((10+25)*3.0*1.5) = floor(157.5) = 157
	var rate: int = _atb.calculate_fill_rate(10, 3, [1.5])
	assert_eq(rate, 157, "haste increases fill rate")


func test_fill_rate_haste_and_despair() -> void:
	# SPD 10, speed 3, haste (1.5) + despair (0.75)
	# floor((10+25)*3.0*1.5*0.75) = floor(118.125) = 118
	var rate: int = _atb.calculate_fill_rate(10, 3, [1.5, 0.75])
	assert_eq(rate, 118, "haste + despair stack multiplicatively")


## The tick rate the documented seconds are printed at. `atb_system.tick()`
## advances every gauge by exactly one fill_rate per call and ignores its delta
## (battle_manager drives it from `_process`), so a "second" in the tables above
## is a count of calls — and that is a second only while the project runs at
## this frame rate. Reading it from the project setting rather than hard-coding
## 60 joins the two halves: raise `run/max_fps` and the measured seconds stop
## matching the canon tables here, on top of test_battle_regressions.gd failing
## on the setting itself.
func _ticks_per_second() -> float:
	var fps: int = int(ProjectSettings.get_setting("application/run/max_fps", 0))
	assert_gt(fps, 0, "the seconds tables assume a capped frame rate; run/max_fps sets it")
	return float(maxi(fps, 1))


## Tick a real gauge until it is ready and return the frame count. This is what
## makes the assertions below measurements rather than restatements of the
## formula: it proves `tick()` actually applies `calculate_fill_rate`.
func _frames_to_ready(spd: int, battle_speed: int, mods: Array) -> int:
	var atb: Node = ATBScript.new()
	add_child_autofree(atb)
	atb.add_combatant("x", spd, false)
	atb.set_battle_speed(battle_speed)
	atb.set_status_mods("x", mods)
	var frames: int = 0
	while atb.get_gauge("x") < ATBScript.GAUGE_MAX and frames < 100000:
		atb.tick(1.0 / _ticks_per_second())
		frames += 1
	return frames


## Assert one printed cell three ways, with no tolerance anywhere.
##
## An earlier version compared the measured seconds to the printed figure under
## a +/- 0.06 tolerance, which is wider than the gap between the wrong 4.1s and
## the right 4.2s — the guard would have straddled the very defect it was
## written for. So the two roundings are separated instead: the gauge must land
## on the exact tick the rate implies, and the doc must print the exact seconds
## rounded to its own precision.
func _assert_documented_cell(
	label: String, spd: int, battle_speed: int, mods: Array, printed: float, step: float
) -> void:
	var ticks: float = _ticks_per_second()
	var rate: int = _atb.calculate_fill_rate(spd, battle_speed, mods)
	assert_gt(rate, 0, "%s: a zero fill rate never becomes ready" % label)
	if rate <= 0:
		return
	var expected_frames: int = int(ceil(float(ATBScript.GAUGE_MAX) / float(rate)))
	assert_eq(
		_frames_to_ready(spd, battle_speed, mods),
		expected_frames,
		"%s: the gauge must fill at exactly its fill rate" % label,
	)
	assert_almost_eq(
		snappedf(float(ATBScript.GAUGE_MAX) / float(rate) / ticks, step),
		printed,
		0.0001,
		"%s: combat-formulas.md prints %s s for this cell" % [label, str(printed)],
	)


func test_each_battle_speed_takes_its_documented_seconds_per_turn() -> void:
	for speed: int in DOCUMENTED_BATTLE_SPEED_SECONDS:
		var column: Dictionary = DOCUMENTED_BATTLE_SPEED_SECONDS[speed]
		for spd: int in column:
			_assert_documented_cell(
				"battle speed %d, SPD %d" % [speed, spd], spd, speed, [], float(column[spd]), 0.1
			)


func test_the_pacing_milestones_match_the_gauge_they_describe() -> void:
	for row: Dictionary in DOCUMENTED_PACING_MILESTONES:
		var spd: int = int(row["spd"])
		var mods: Array = row["mods"] as Array
		assert_eq(
			_atb.calculate_fill_rate(spd, 3, mods),
			int(row["rate"]),
			"%s: § ATB Pacing prints fill rate %s" % [row["who"], str(row["rate"])],
		)
		_assert_documented_cell(
			String(row["who"]), spd, 3, mods, float(row["seconds"]), float(row["step"])
		)


# --- Gauge Mechanics ---


func test_gauge_starts_at_zero() -> void:
	_atb.add_combatant("party_0", 10, false)
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge starts at 0")


func test_gauge_fills_by_fill_rate() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	# fill_rate = floor((10+25)*3.0) = 105
	assert_eq(_atb.get_gauge("party_0"), 105, "gauge fills by fill rate")


func test_gauge_caps_at_max() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_gauge("party_0", 15999)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("party_0"), 16000, "gauge caps at GAUGE_MAX")


# --- Turn Order ---


func test_higher_spd_acts_first() -> void:
	_atb.add_combatant("fast", 100, false)
	_atb.add_combatant("slow", 10, false)
	_atb.set_gauge("fast", 16000)
	_atb.set_gauge("slow", 16000)
	var queue: Array = _atb.get_ready_queue()
	assert_eq(queue[0], "fast", "higher SPD acts first")


func test_party_before_enemy_on_tie() -> void:
	_atb.add_combatant("party_0", 50, false)
	_atb.add_combatant("enemy_0", 50, true)
	_atb.set_gauge("party_0", 16000)
	_atb.set_gauge("enemy_0", 16000)
	var queue: Array = _atb.get_ready_queue()
	assert_eq(queue[0], "party_0", "party before enemy on SPD tie")


# --- Formation ---


func test_preemptive_party_starts_full() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.add_combatant("enemy_0", 10, true)
	_atb.apply_formation("preemptive")
	assert_eq(_atb.get_gauge("party_0"), 16000, "party full on preemptive")
	assert_eq(_atb.get_gauge("enemy_0"), 0, "enemy empty on preemptive")


func test_back_attack_enemies_half() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.add_combatant("enemy_0", 10, true)
	_atb.apply_formation("back_attack")
	assert_eq(_atb.get_gauge("party_0"), 0, "party starts 0 on back attack")
	assert_eq(_atb.get_gauge("enemy_0"), 8000, "enemy starts 50% on back attack")


# --- Pause ---


func test_wait_mode_pauses_on_submenu() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.set_atb_mode("wait")
	_atb.set_submenu_open(true)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge paused in wait + submenu")


func test_active_mode_fills_during_submenu() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.set_atb_mode("active")
	_atb.set_submenu_open(true)
	_atb.tick(1.0 / 60.0)
	assert_gt(_atb.get_gauge("party_0"), 0, "gauge fills in active + submenu")


func test_patience_mode_pauses_on_command_menu() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.set_atb_mode("patience")
	_atb.set_command_menu_open(true)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge paused in patience + command menu")


# --- Frozen ---


func test_frozen_gauge_retains_value() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_gauge("party_0", 5000)
	_atb.set_frozen("party_0", true)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("party_0"), 5000, "frozen gauge unchanged")


func test_reset_gauge_after_acting() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_gauge("party_0", 16000)
	_atb.reset_gauge("party_0")
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge reset to 0 after acting")


# --- Remove Combatant ---


func test_remove_combatant_from_queue() -> void:
	_atb.add_combatant("enemy_0", 10, true)
	_atb.set_gauge("enemy_0", 16000)
	_atb.remove_combatant("enemy_0")
	var queue: Array = _atb.get_ready_queue()
	assert_eq(queue.size(), 0, "removed combatant not in queue")


func test_remove_combatant_not_ticked() -> void:
	_atb.add_combatant("enemy_0", 10, true)
	_atb.remove_combatant("enemy_0")
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	assert_eq(_atb.get_gauge("enemy_0"), 0, "removed combatant returns 0")


# --- Combatant Ready Signal ---


func test_combatant_ready_signal_emitted() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_gauge("party_0", 15999)
	_atb.set_battle_speed(3)
	watch_signals(_atb)
	_atb.tick(1.0 / 60.0)
	assert_signal_emitted(_atb, "combatant_ready")


# --- Normal Formation ---


func test_normal_formation_all_zero() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.add_combatant("enemy_0", 10, true)
	_atb.apply_formation("normal")
	assert_eq(_atb.get_gauge("party_0"), 0, "party 0 on normal")
	assert_eq(_atb.get_gauge("enemy_0"), 0, "enemy 0 on normal")


# --- Should Pause Timers ---


func test_should_pause_timers_active_mode() -> void:
	_atb.set_atb_mode("active")
	assert_false(_atb.should_pause_timers(), "active never pauses")


func test_should_pause_timers_wait_submenu() -> void:
	_atb.set_atb_mode("wait")
	_atb.set_submenu_open(true)
	assert_true(_atb.should_pause_timers(), "wait pauses on submenu")


# --- Config -> ATB settings mapping (GAP-007) ---


func test_settings_from_config_defaults() -> void:
	var s: Dictionary = ATBScript.settings_from_config({})
	assert_eq(s.get("mode"), "active", "defaults to active mode")
	assert_eq(s.get("speed"), 3, "defaults to speed 3")


func test_settings_from_config_reads_player_values() -> void:
	var s: Dictionary = ATBScript.settings_from_config({"atb_mode": "wait", "battle_speed": 5})
	assert_eq(s.get("mode"), "wait", "uses player's ATB mode")
	assert_eq(s.get("speed"), 5, "uses player's battle speed")


func test_settings_from_config_patience_mode_overrides() -> void:
	var s: Dictionary = ATBScript.settings_from_config(
		{"atb_mode": "active", "patience_mode": true}
	)
	assert_eq(s.get("mode"), "patience", "patience mode overrides the ATB mode")
