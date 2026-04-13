extends Area2D
## Poison damage zone — deals periodic damage to party while player stands in it.

signal zone_damage_dealt(zone_id: String, total_damage: int)

var zone_id: String = ""
var damage_per_tick: int = 8
var _tick_interval: float = 1.0
var _status_effect: String = ""
var _status_applied: bool = false
var _player_inside: bool = false
var _timer: Timer = null


func initialize(p_zone_id: String, p_damage: int, p_interval: float, p_status: String) -> void:
	if p_zone_id.is_empty():
		push_error("DamageZone: empty zone_id")
		return
	if p_damage < 0:
		push_error("DamageZone: negative damage %d" % p_damage)
		return
	if p_interval <= 0.0:
		push_error("DamageZone: invalid interval %f" % p_interval)
		return
	zone_id = p_zone_id
	damage_per_tick = p_damage
	_tick_interval = p_interval
	_status_effect = p_status  # Stored for future status system — not yet applied.
	_status_applied = false
	if _timer != null:
		_timer.wait_time = _tick_interval


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = _tick_interval
	_timer.one_shot = false
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if zone_id.is_empty():
		return
	if body.is_in_group("player"):
		if GameManager.current_overlay == GameManager.OverlayState.CUTSCENE:
			return
		_player_inside = true
		_status_applied = false
		_timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_timer.stop()


func _on_tick() -> void:
	if _player_inside:
		_apply_tick()


func _apply_tick() -> void:
	if zone_id.is_empty():
		push_error("DamageZone: _apply_tick called before initialize")
		return
	var active: Array[Dictionary] = PartyState.get_active_party()
	var total: int = 0
	for member: Dictionary in active:
		var hp: int = member.get("current_hp", 0)
		if hp <= 0:
			continue
		var new_hp: int = maxi(1, hp - damage_per_tick)
		var dealt: int = hp - new_hp
		member["current_hp"] = new_hp
		total += dealt
	if not _status_applied and not _status_effect.is_empty():
		_status_applied = true
	zone_damage_dealt.emit(zone_id, total)
