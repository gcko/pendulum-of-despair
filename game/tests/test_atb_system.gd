extends GutTest
## Tests for ATB gauge system.

var _atb: Node


func before_each() -> void:
	_atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_atb)


func after_each() -> void:
	_atb = null


# --- Fill Rate ---


func test_fill_rate_maren_lv1_speed3() -> void:
	# SPD 8, battle speed 3 (factor 0.7), no status mods
	# fill_rate = floor((8 + 25) * 0.7 * 1.0) = floor(23.1) = 23
	var rate: int = _atb.calculate_fill_rate(8, 3, [])
	assert_eq(rate, 23, "Maren Lv1 at speed 3")


func test_fill_rate_sable_lv1_speed3() -> void:
	# SPD 18, speed 3 → floor((18+25)*0.7) = floor(30.1) = 30
	var rate: int = _atb.calculate_fill_rate(18, 3, [])
	assert_eq(rate, 30, "Sable Lv1 at speed 3")


func test_fill_rate_with_haste() -> void:
	# SPD 10, speed 3, haste (1.5x)
	# floor((10+25)*0.7*1.5) = floor(36.75) = 36
	var rate: int = _atb.calculate_fill_rate(10, 3, [1.5])
	assert_eq(rate, 36, "haste increases fill rate")


func test_fill_rate_haste_and_despair() -> void:
	# SPD 10, speed 3, haste (1.5) + despair (0.75)
	# floor((10+25)*0.7*1.5*0.75) = floor(27.5625) = 27
	var rate: int = _atb.calculate_fill_rate(10, 3, [1.5, 0.75])
	assert_eq(rate, 27, "haste + despair stack multiplicatively")


# --- Gauge Mechanics ---


func test_gauge_starts_at_zero() -> void:
	_atb.add_combatant("party_0", 10, false)
	assert_eq(_atb.get_gauge("party_0"), 0, "gauge starts at 0")


func test_gauge_fills_by_fill_rate() -> void:
	_atb.add_combatant("party_0", 10, false)
	_atb.set_battle_speed(3)
	_atb.tick(1.0 / 60.0)
	# fill_rate = floor((10+25)*3) = 105
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
