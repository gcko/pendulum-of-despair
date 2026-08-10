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
const COLOR_POISON: Color = Color("#aa66cc")
const COLOR_BURN: Color = Color("#ff8844")

## Offsets applied to the target cursor when it points at an enemy sprite
## (ui-design.md § 2.6 — cursor above the sprite).
const ENEMY_ARROW_OFFSET: Vector2 = Vector2(32, 8)
## Gap between the target cursor and the left edge of the party row it
## points at (ui-design.md § 2.6 — cursor beside the targeted member).
const PARTY_ARROW_GAP: float = 6.0
## Damage popups spawn POPUP_LIFT px above their anchor and float a further
## POPUP_RISE px over 0.5s (ui-design.md § 2.2).
const POPUP_LIFT: float = 64.0
const POPUP_RISE: float = 64.0
## World-space anchor used when a damage event names a combatant this UI
## cannot place (unknown id, or a party slot with no visible row).
const FALLBACK_WORLD_ANCHOR: Vector2 = Vector2(640, 360)

var _manager: Node = null
var _battle_state: Node = null
var _atb_system: Node = null
var _message_timer: float = 0.0
var _enemy_positions: Array[Vector2] = []
var _results_showing: bool = false
var _target_arrow: Label = null

@onready var _party_panel: PanelContainer = $PartyPanel
@onready var _command_menu: PanelContainer = $CommandMenu
@onready var _message_area: PanelContainer = $MessageArea
@onready var _message_label: Label = $MessageArea/MessageLabel
@onready var _results_panel: PanelContainer = $ResultsPanel


## Called by battle_manager to inject itself — "call down" pattern.
func initialize(manager: Node) -> void:
	_manager = manager
	_battle_state = manager.get_node_or_null("BattleState")
	_atb_system = manager.get_node_or_null("ATBSystem")
	manager.battle_started.connect(_on_battle_started)
	manager.turn_ready.connect(_on_turn_ready)
	manager.damage_dealt.connect(_on_damage_dealt)
	manager.message.connect(_on_message)
	manager.victory.connect(_on_victory)
	manager.defeat.connect(_on_defeat)
	manager.combatant_died.connect(_on_combatant_died)


func _ready() -> void:
	# Create target arrow indicator
	_target_arrow = Label.new()
	_target_arrow.text = ">"
	_target_arrow.modulate = Color("#ffff88")
	_target_arrow.visible = false
	add_child(_target_arrow)

	if _command_menu != null:
		_command_menu.command_selected.connect(_on_command_selected)
		_command_menu.command_cancelled.connect(_on_command_cancelled)
		_command_menu.submenu_opened.connect(_on_submenu_opened)
		_command_menu.submenu_closed.connect(_on_submenu_closed)
		_command_menu.target_changed.connect(_on_target_changed)

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


func _on_battle_started(
	_party: Array,
	_enemies: Array,
	enemy_positions: Array,
) -> void:
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
		var current_mp: int = 0
		if _battle_state != null:
			current_mp = int(_battle_state.get_member(slot).get("current_mp", 0))
		_command_menu.show_commands(character_data, is_boss, current_mp)


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


func _on_target_changed(index: int, is_enemy: bool) -> void:
	if _target_arrow == null:
		return
	if index < 0:
		_target_arrow.visible = false
		return
	if is_enemy and index < _enemy_positions.size():
		_target_arrow.visible = true
		_target_arrow.position = _to_screen(_enemy_positions[index]) - ENEMY_ARROW_OFFSET
	elif not is_enemy:
		var row: Rect2 = _party_row_rect(index)
		if row.size == Vector2.ZERO:
			_target_arrow.visible = false
			return
		_target_arrow.visible = true
		var arrow: Vector2 = _target_arrow.get_minimum_size()
		# Sits just left of the row, vertically centred on it. The party panel
		# hugs the viewport's left edge, so clamp at 0 rather than let the
		# cursor slide off-screen.
		_target_arrow.position = Vector2(
			maxf(0.0, row.position.x - arrow.x - PARTY_ARROW_GAP),
			row.position.y + (row.size.y - arrow.y) * 0.5
		)
	else:
		_target_arrow.visible = false


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
		"poison":
			color = COLOR_POISON
		"burn":
			color = COLOR_BURN

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
	if _party_panel == null or _battle_state == null or _atb_system == null:
		return
	var m: Array = []
	var g: Dictionary = {}
	for i: int in range(4):
		m.append(_battle_state.get_member(i))
		g["party_%d" % i] = _atb_system.get_gauge("party_%d" % i)
	_party_panel.update_party(m, g)


func _spawn_damage_number(target_id: String, text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.modulate = color
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	add_child(label)

	var anchor: Vector2 = _get_target_anchor(target_id)
	label.position = anchor - Vector2(label.get_minimum_size().x * 0.5, POPUP_LIFT)

	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(label, "position:y", label.position.y - POPUP_RISE, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.tween_callback(label.queue_free)


## Screen-space anchor for a combatant's floating numbers. Enemies live in
## world space and go through the canvas transform; party rows are already
## screen space (the panel shares this CanvasLayer) and report their own
## rects, so nothing here guesses a row pitch (#276).
func _get_target_anchor(target_id: String) -> Vector2:
	if target_id.begins_with("enemy_"):
		var idx: int = target_id.replace("enemy_", "").to_int()
		if idx < _enemy_positions.size():
			return _to_screen(_enemy_positions[idx])
	elif target_id.begins_with("party_"):
		var slot: int = target_id.replace("party_", "").to_int()
		var row: Rect2 = _party_row_rect(slot)
		if row.size != Vector2.ZERO:
			return row.position + row.size * 0.5
	return _to_screen(FALLBACK_WORLD_ANCHOR)


## Real screen rect of a party row, or an empty Rect2 when the panel is
## absent (battle_manager tolerates a missing UI child) or the slot is empty.
func _party_row_rect(slot: int) -> Rect2:
	if _party_panel == null:
		return Rect2()
	return _party_panel.get_row_global_rect(slot)


func _to_screen(world_pos: Vector2) -> Vector2:
	var vp: Viewport = get_viewport()
	return vp.get_canvas_transform() * world_pos if vp != null else world_pos


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
		var vp: Viewport = get_viewport()
		if vp != null:
			vp.set_input_as_handled()
		_results_panel.visible = false
		_results_showing = false
		results_dismissed.emit()
