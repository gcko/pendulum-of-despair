extends Node
## ATB gauge system — owns all combatant gauges, manages fill rates and turn queue.
##
## Gauges fill based on SPD. When a gauge reaches GAUGE_MAX, the combatant
## is added to the ready queue. Supports Active/Wait/Patience modes.

signal combatant_ready(combatant_id: String)

const GAUGE_MAX: int = 16000

## Speed factors per battle speed setting.
## Tuned so average SPD (~20) fills the gauge in ~6-8 seconds at speed 3,
## matching FF6 ATB pacing (SNES: gauge 0-255, ~60fps, increment ~1/tick).
const SPEED_FACTORS: Dictionary = {
	1: 1.5,
	2: 1.0,
	3: 0.7,
	4: 0.5,
	5: 0.35,
	6: 0.25,
}

## Per-combatant data: {id: {gauge, spd, is_enemy, frozen, status_mods}}
var _combatants: Dictionary = {}

## Current battle speed setting (1-6, default 3).
var _battle_speed: int = 3

## ATB mode: "active", "wait", or "patience".
var _atb_mode: String = "active"

## Whether a sub-menu is currently open (for wait/patience pausing).
var _submenu_open: bool = false

## Whether top-level command menu is open (for patience pausing).
var _command_menu_open: bool = false


## Check if real-time status timers should pause (for Wait/Patience modes).
func should_pause_timers() -> bool:
	return _should_pause()


## Add a combatant to the ATB system.
func add_combatant(id: String, spd: int, is_enemy: bool) -> void:
	if id == "":
		push_error("ATBSystem: Cannot add combatant with empty ID")
		return
	_combatants[id] = {
		"gauge": 0,
		"spd": spd,
		"is_enemy": is_enemy,
		"frozen": false,
		"status_mods": [] as Array[float],
	}


## Remove a combatant (e.g., on death).
func remove_combatant(id: String) -> void:
	_combatants.erase(id)


## Get current gauge value.
func get_gauge(id: String) -> int:
	if not _combatants.has(id):
		return 0
	return _combatants[id]["gauge"]


## Set gauge directly (for formation setup or reset after acting).
func set_gauge(id: String, value: int) -> void:
	if _combatants.has(id):
		_combatants[id]["gauge"] = clampi(value, 0, GAUGE_MAX)


## Set frozen state (Stop, Sleep, Petrify).
func set_frozen(id: String, frozen: bool) -> void:
	if _combatants.has(id):
		_combatants[id]["frozen"] = frozen


## Update SPD (for buff changes).
func set_spd(id: String, spd: int) -> void:
	if _combatants.has(id):
		_combatants[id]["spd"] = spd


## Set status modifiers (e.g., [1.5] for Haste, [0.5] for Slow).
func set_status_mods(id: String, mods: Array) -> void:
	if _combatants.has(id):
		_combatants[id]["status_mods"] = mods


func set_battle_speed(speed: int) -> void:
	_battle_speed = clampi(speed, 1, 6)


func set_atb_mode(mode: String) -> void:
	_atb_mode = mode


func set_submenu_open(is_open: bool) -> void:
	_submenu_open = is_open


func set_command_menu_open(is_open: bool) -> void:
	_command_menu_open = is_open


## Calculate fill rate for given SPD, battle speed, and status modifiers.
## Public for testing. Used internally by tick().
func calculate_fill_rate(spd: int, battle_speed: int, status_mods: Array) -> int:
	var factor: float = SPEED_FACTORS.get(battle_speed, 0.7)
	var mod_product: float = 1.0
	for mod: float in status_mods:
		mod_product *= mod
	return int((spd + 25) * factor * mod_product)


## Tick all gauges by one frame. Call from battle_manager._process().
func tick(_delta: float) -> void:
	if _should_pause():
		return

	for id: String in _combatants:
		var data: Dictionary = _combatants[id]
		if data["frozen"]:
			continue
		if data["gauge"] >= GAUGE_MAX:
			continue

		var rate: int = calculate_fill_rate(data["spd"], _battle_speed, data["status_mods"])
		data["gauge"] = mini(data["gauge"] + rate, GAUGE_MAX)

		if data["gauge"] >= GAUGE_MAX:
			combatant_ready.emit(id)


## Get all combatants whose gauge is at GAUGE_MAX, sorted by priority.
## Order: higher SPD first, party before enemy on tie, lower slot index on tie.
func get_ready_queue() -> Array[String]:
	var ready: Array[Dictionary] = []
	for id: String in _combatants:
		var data: Dictionary = _combatants[id]
		if data["gauge"] >= GAUGE_MAX:
			ready.append({"id": id, "spd": data["spd"], "is_enemy": data["is_enemy"]})

	ready.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			if a["spd"] != b["spd"]:
				return a["spd"] > b["spd"]
			if a["is_enemy"] != b["is_enemy"]:
				return not a["is_enemy"]
			return a["id"] < b["id"]
	)

	var result: Array[String] = []
	for entry: Dictionary in ready:
		result.append(entry["id"])
	return result


## Apply formation start state.
func apply_formation(formation_type: String) -> void:
	for id: String in _combatants:
		var data: Dictionary = _combatants[id]
		match formation_type:
			"preemptive":
				data["gauge"] = GAUGE_MAX if not data["is_enemy"] else 0
			"back_attack":
				data["gauge"] = GAUGE_MAX / 2 if data["is_enemy"] else 0
			_:
				data["gauge"] = 0


## Reset a combatant's gauge after they act.
func reset_gauge(id: String) -> void:
	set_gauge(id, 0)


func _should_pause() -> bool:
	match _atb_mode:
		"wait":
			return _submenu_open
		"patience":
			return _submenu_open or _command_menu_open
	return false
