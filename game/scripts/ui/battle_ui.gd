extends CanvasLayer
## Battle UI controller — observes battle_manager signals, coordinates
## child UI components, manages damage popups and results screen.
##
## Initialized by battle_manager via initialize() — no get_parent().
## Emits results_dismissed signal — never calls parent methods directly.

signal results_dismissed
signal command_submitted(command: Dictionary)
signal command_cancelled
signal submenu_state_changed(is_open: bool)

const COLOR_DAMAGE: Color = Color("#ffffff")
const COLOR_HEAL: Color = Color("#44ff44")
const COLOR_MISS: Color = Color("#888888")
const COLOR_CRIT: Color = Color("#ffff44")

var _message_timer: float = 0.0
var _enemy_positions: Array[Vector2] = []
var _results_showing: bool = false

@onready var _party_panel: PanelContainer = $PartyPanel
@onready var _command_menu: PanelContainer = $CommandMenu
@onready var _message_area: PanelContainer = $MessageArea
@onready var _message_label: Label = $MessageArea/MessageLabel
@onready var _results_panel: PanelContainer = $ResultsPanel


## Called by battle_manager to inject itself — "call down" pattern.
func initialize(manager: Node) -> void:
	manager.battle_started.connect(_on_battle_started)
	manager.turn_ready.connect(_on_turn_ready)
	manager.damage_dealt.connect(_on_damage_dealt)
	manager.message.connect(_on_message)
	manager.victory.connect(_on_victory)
	manager.defeat.connect(_on_defeat)
	manager.combatant_died.connect(_on_combatant_died)


func _ready() -> void:
	if _command_menu != null:
		_command_menu.command_selected.connect(_on_command_selected)
		_command_menu.command_cancelled.connect(_on_command_cancelled)
		_command_menu.submenu_opened.connect(_on_submenu_opened)
		_command_menu.submenu_closed.connect(_on_submenu_closed)

	if _message_area != null:
		_message_area.visible = false
	if _results_panel != null:
		_results_panel.visible = false
	if _command_menu != null:
		_command_menu.hide_menu()


func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0 and _message_area != null:
			_message_area.visible = false


func _on_battle_started(_party: Array, _enemies: Array, enemy_positions: Array) -> void:
	_enemy_positions = []
	for pos: Variant in enemy_positions:
		_enemy_positions.append(pos as Vector2)


func _on_turn_ready(
	_combatant_id: String,
	is_party: bool,
	slot: int,
	enemy_count: int,
	is_boss: bool,
	character_data: Dictionary,
) -> void:
	if not is_party:
		return
	if _party_panel != null:
		_party_panel.set_active_slot(slot)
	if _command_menu != null:
		_command_menu.set_enemy_count(enemy_count)
		_command_menu.show_commands(character_data, is_boss)


func _on_command_selected(command: Dictionary) -> void:
	if _party_panel != null:
		_party_panel.set_active_slot(-1)
	command_submitted.emit(command)


func _on_command_cancelled() -> void:
	if _command_menu != null:
		_command_menu.hide_menu()
	if _party_panel != null:
		_party_panel.set_active_slot(-1)
	command_cancelled.emit()


func _on_submenu_opened() -> void:
	submenu_state_changed.emit(true)


func _on_submenu_closed() -> void:
	submenu_state_changed.emit(false)


func _on_damage_dealt(target_id: String, amount: int, damage_type: String) -> void:
	var color: Color = COLOR_DAMAGE
	var text: String = str(amount)

	match damage_type:
		"heal":
			color = COLOR_HEAL
		"miss":
			color = COLOR_MISS
			text = "Miss"
		"immune":
			color = COLOR_MISS
			text = "Immune"
		"critical":
			color = COLOR_CRIT

	_spawn_damage_number(target_id, text, color)


func _on_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text
	if _message_area != null:
		_message_area.visible = true
	_message_timer = 1.5


func _on_victory(rewards: Dictionary) -> void:
	if _command_menu != null:
		_command_menu.hide_menu()
	_show_results(rewards)


func _on_defeat() -> void:
	if _command_menu != null:
		_command_menu.hide_menu()


func _on_combatant_died(_combatant_id: String) -> void:
	pass


func _spawn_damage_number(target_id: String, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.modulate = color
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var pos: Vector2 = _get_target_position(target_id)
	label.position = pos - Vector2(20, 16)
	add_child(label)

	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", pos.y - 32, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.tween_callback(label.queue_free)


func _get_target_position(target_id: String) -> Vector2:
	if target_id.begins_with("enemy_"):
		var idx: int = target_id.replace("enemy_", "").to_int()
		if idx < _enemy_positions.size():
			return _enemy_positions[idx]
	elif target_id.begins_with("party_"):
		var slot: int = target_id.replace("party_", "").to_int()
		return Vector2(40, 120 + slot * 15)
	return Vector2(160, 90)


func _show_results(rewards: Dictionary) -> void:
	if _results_panel == null:
		return
	_results_panel.visible = true
	_results_showing = true

	var results_label: Label = _results_panel.get_node_or_null("ResultsLabel")
	if results_label != null:
		var text: String = "Victory!\n\n"
		text += "EXP: %d\n" % rewards.get("xp", 0)
		text += "Gold: %d\n" % rewards.get("gold", 0)
		var drops: Array = rewards.get("drops", [])
		for drop: Dictionary in drops:
			text += "Found: %s\n" % drop.get("item_id", "???")
		results_label.text = text


func _unhandled_input(event: InputEvent) -> void:
	if _results_showing and event.is_action_pressed("ui_accept"):
		_results_panel.visible = false
		_results_showing = false
		# Signal up — parent handles scene transition
		results_dismissed.emit()
