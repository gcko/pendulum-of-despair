extends CanvasLayer
## Battle UI controller — observes battle_manager signals, coordinates
## child UI components, manages damage popups and results screen.

const COLOR_DAMAGE: Color = Color("#ffffff")
const COLOR_HEAL: Color = Color("#44ff44")
const COLOR_MISS: Color = Color("#888888")
const COLOR_CRIT: Color = Color("#ffff44")

var _battle_manager: Node = null
var _message_timer: float = 0.0

@onready var _party_panel: PanelContainer = $PartyPanel
@onready var _command_menu: PanelContainer = $CommandMenu
@onready var _message_area: PanelContainer = $MessageArea
@onready var _message_label: Label = $MessageArea/MessageLabel
@onready var _results_panel: PanelContainer = $ResultsPanel


func _ready() -> void:
	_battle_manager = get_parent()
	if _battle_manager == null:
		push_error("BattleUI: No parent battle manager")
		return

	_battle_manager.battle_started.connect(_on_battle_started)
	_battle_manager.turn_ready.connect(_on_turn_ready)
	_battle_manager.damage_dealt.connect(_on_damage_dealt)
	_battle_manager.message.connect(_on_message)
	_battle_manager.victory.connect(_on_victory)
	_battle_manager.defeat.connect(_on_defeat)
	_battle_manager.combatant_died.connect(_on_combatant_died)

	if _command_menu != null:
		_command_menu.command_selected.connect(_on_command_selected)
		_command_menu.command_cancelled.connect(_on_command_cancelled)

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

	_update_party_panel()


func _on_battle_started(_party: Array, _enemies: Array) -> void:
	_update_party_panel()


func _on_turn_ready(combatant_id: String, is_party: bool) -> void:
	if not is_party:
		return
	var slot: int = combatant_id.replace("party_", "").to_int()
	if _party_panel != null:
		_party_panel.set_active_slot(slot)

	var state: Node = _battle_manager.get_node_or_null("BattleState")
	if state != null and _command_menu != null:
		var member: Dictionary = state.get_member(slot)
		var char_data: Dictionary = member.get("character_data", {})
		_command_menu.set_enemy_count(_battle_manager._enemies.size())
		_command_menu.show_commands(char_data, _battle_manager._is_boss)

		var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
		if atb != null:
			atb.set_command_menu_open(true)


func _on_command_selected(command: Dictionary) -> void:
	var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
	if atb != null:
		atb.set_command_menu_open(false)
		atb.set_submenu_open(false)

	if _party_panel != null:
		_party_panel.set_active_slot(-1)

	_battle_manager.submit_command(command)


func _on_command_cancelled() -> void:
	if _command_menu != null:
		_command_menu.hide_menu()
	if _party_panel != null:
		_party_panel.set_active_slot(-1)

	var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
	if atb != null:
		atb.set_command_menu_open(false)


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


func _update_party_panel() -> void:
	if _party_panel == null or _battle_manager == null:
		return
	var state: Node = _battle_manager.get_node_or_null("BattleState")
	var atb: Node = _battle_manager.get_node_or_null("ATBSystem")
	if state == null or atb == null:
		return

	var members: Array = []
	var gauges: Dictionary = {}
	for i: int in range(4):
		members.append(state.get_member(i))
		gauges["party_%d" % i] = atb.get_gauge("party_%d" % i)
	_party_panel.update_party(members, gauges)


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
		if idx < _battle_manager._enemies.size():
			return _battle_manager._enemies[idx].global_position
	elif target_id.begins_with("party_"):
		var slot: int = target_id.replace("party_", "").to_int()
		return Vector2(40, 120 + slot * 15)
	return Vector2(160, 90)


func _show_results(rewards: Dictionary) -> void:
	if _results_panel == null:
		return
	_results_panel.visible = true

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
	if _results_panel != null and _results_panel.visible:
		if event.is_action_pressed("ui_accept"):
			_results_panel.visible = false
			# _exit_battle MUST be the last call — no code after scene swap
			_battle_manager._exit_battle("victory")
