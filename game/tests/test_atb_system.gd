extends GutTest
## Tests for ATB gauge system.

const ATBScript := preload("res://scripts/combat/atb_system.gd")

## The seconds-per-turn column of combat-formulas.md § ATB Gauge System >
## Battle Speed Config, for a Lv1 Maren (SPD 8). Each entry is measured by
## ticking the real gauge at 60 fps and counting frames to ready, so the
## SPEED_FACTORS constants, the fill-rate formula and GAUGE_MAX all have to
## agree with the doc for it to pass (#177).
const DOCUMENTED_SECONDS_PER_TURN: Dictionary = {
	1: 1.3,
	2: 1.6,
	3: 2.7,
	4: 4.0,
	5: 5.4,
	6: 8.1,
}

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


func test_each_battle_speed_takes_its_documented_seconds_per_turn() -> void:
	for speed: int in DOCUMENTED_SECONDS_PER_TURN:
		var atb: Node = ATBScript.new()
		add_child_autofree(atb)
		atb.add_combatant("maren", 8, false)
		atb.set_battle_speed(speed)
		var frames: int = 0
		while atb.get_gauge("maren") < ATBScript.GAUGE_MAX and frames < 3600:
			atb.tick(1.0 / 60.0)
			frames += 1
		# Tolerance covers the two roundings between a measured fill and a
		# printed table: the 1/60 s frame the gauge lands on (0.017 s) and the
		# 0.1 s the doc rounds to. Anything further out is a real drift.
		assert_almost_eq(
			float(frames) / 60.0,
			float(DOCUMENTED_SECONDS_PER_TURN[speed]),
			0.06,
			"battle speed %d must fill a Lv1 SPD 8 gauge in its documented time" % speed,
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
