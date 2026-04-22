extends CanvasLayer
## Main menu overlay — command list, character select, sub-screen dispatch.
## Process mode set by GameManager.push_overlay().

enum MenuState { COMMAND, CHARACTER_SELECT, SUB_SCREEN }

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")
const COLOR_HP: Color = Color("#44cc44")
const COLOR_HP_LOW: Color = Color("#ff4444")
const COLOR_MP: Color = Color("#4488ff")
const COLOR_GOLD: Color = Color("#ffcc44")
const COLOR_WINDOW_BG: Color = Color("#000040")

## Command definitions: name, requires_character_select, is_stubbed.
const COMMANDS: Array[Dictionary] = [
	{"name": "Item", "char_select": false, "stubbed": false},
	{"name": "Magic", "char_select": true, "stubbed": false},
	{"name": "Abilities", "char_select": true, "stubbed": false},
	{"name": "Equip", "char_select": true, "stubbed": false},
	{"name": "Crystal", "char_select": true, "stubbed": false},
	{"name": "Status", "char_select": true, "stubbed": false},
	{"name": "Formation", "char_select": false, "stubbed": false},
	{"name": "Config", "char_select": false, "stubbed": false},
	{"name": "Save", "char_select": false, "stubbed": false},
]

var _state: MenuState = MenuState.COMMAND
var _command_index: int = 0
var _char_index: int = 0
var _active_sub_screen: Control = null
var _active_party: Array[Dictionary] = []
var _config_direct: bool = false

@onready var _command_labels: Array[Label] = []
@onready var _party_rows: Array[Control] = []
@onready var _cursor: Sprite2D = $Cursor
@onready var _main_panel: PanelContainer = $MainPanel
@onready var _command_panel: PanelContainer = $CommandPanel
@onready var _info_panel: PanelContainer = $InfoPanel
@onready var _gold_label: Label = $InfoPanel/Margin/Layout/RightCol/GoldLabel
@onready var _time_label: Label = $InfoPanel/Margin/Layout/RightCol/TimeLabel
@onready var _location_label: Label = $InfoPanel/Margin/Layout/LocationLabel
@onready var _magic_screen: Control = $SubScreen/MagicScreen
@onready var _item_screen: Control = $SubScreen/ItemScreen
@onready var _equip_screen: Control = $SubScreen/EquipScreen
@onready var _abilities_screen: Control = $SubScreen/AbilitiesScreen
@onready var _status_screen: Control = $SubScreen/StatusScreen
@onready var _config_screen: Control = $SubScreen/ConfigScreen
@onready var _formation_screen: Control = $SubScreen/FormationScreen
@onready var _crystal_screen: Control = $SubScreen/CrystalScreen
@onready var _stub_label: Label = $SubScreen/StubLabel


func _ready() -> void:
	_command_labels = []
	for i: int in range(COMMANDS.size()):
		var label: Label = get_node_or_null("CommandPanel/Margin/CmdList/Cmd%d" % i)
		if label != null:
			label.text = COMMANDS[i]["name"]
			_command_labels.append(label)
	_party_rows = []
	for i: int in range(4):
		var row: Control = get_node_or_null("MainPanel/Margin/Rows/Row%d" % i)
		_party_rows.append(row)
	_hide_all_sub_screens()
	_refresh_party_data()
	_update_display()
	_update_info_panel()


## Open directly to config screen (used by title screen).
func open_config_direct() -> void:
	_config_direct = true
	_hide_all_sub_screens()
	_open_sub_screen(_config_screen)
	if _config_screen.has_method("open"):
		_config_screen.open()


func _unhandled_input(event: InputEvent) -> void:
	match _state:
		MenuState.COMMAND:
			_handle_command_input(event)
		MenuState.CHARACTER_SELECT:
			_handle_char_select_input(event)
		MenuState.SUB_SCREEN:
			_handle_sub_screen_input(event)


func _handle_command_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_command_index = (_command_index + 1) % COMMANDS.size()
		_update_display()
		_consume_input()
	elif event.is_action_pressed("ui_up"):
		_command_index = (_command_index - 1 + COMMANDS.size()) % COMMANDS.size()
		_update_display()
		_consume_input()
	elif event.is_action_pressed("ui_accept"):
		_consume_input()
		_confirm_command()
	elif event.is_action_pressed("ui_cancel"):
		_consume_input()
		GameManager.pop_overlay()


func _handle_char_select_input(event: InputEvent) -> void:
	if _active_party.is_empty():
		if event.is_action_pressed("ui_cancel"):
			_clear_char_highlight()
			_state = MenuState.COMMAND
			_consume_input()
		return
	if event.is_action_pressed("ui_down"):
		_char_index = (_char_index + 1) % _active_party.size()
		_update_char_highlight()
		_consume_input()
	elif event.is_action_pressed("ui_up"):
		_char_index = (_char_index - 1 + _active_party.size()) % _active_party.size()
		_update_char_highlight()
		_consume_input()
	elif event.is_action_pressed("ui_accept"):
		_clear_char_highlight()
		_open_sub_screen_for_character()
		_consume_input()
	elif event.is_action_pressed("ui_cancel"):
		_clear_char_highlight()
		_state = MenuState.COMMAND
		_consume_input()


func _handle_sub_screen_input(event: InputEvent) -> void:
	# Sub-screens handle their own input; cancel returns here
	if _active_sub_screen != null and _active_sub_screen.has_method("handle_input"):
		var handled: bool = _active_sub_screen.handle_input(event)
		if handled:
			_consume_input()
			return
	if event.is_action_pressed("ui_cancel"):
		_consume_input()
		_close_sub_screen()


func _confirm_command() -> void:
	var cmd: Dictionary = COMMANDS[_command_index]
	if cmd.get("stubbed", false):
		_show_stub_message()
		return
	var cmd_name: String = cmd.get("name", "")
	if cmd_name == "Save":
		_open_save()
		return
	if cmd.get("char_select", false):
		_state = MenuState.CHARACTER_SELECT
		_char_index = 0
		_update_char_highlight()
		return
	# Direct sub-screens (no character select)
	match cmd_name:
		"Item":
			_open_sub_screen(_item_screen)
			if _item_screen.has_method("open"):
				_item_screen.open()
		"Formation":
			_open_sub_screen(_formation_screen)
			if _formation_screen.has_method("open"):
				_formation_screen.open()
		"Config":
			_open_sub_screen(_config_screen)
			if _config_screen.has_method("open"):
				_config_screen.open()


func _open_sub_screen_for_character() -> void:
	if _char_index >= _active_party.size():
		return
	var character_id: String = _active_party[_char_index].get("character_id", "")
	var cmd_name: String = COMMANDS[_command_index].get("name", "")
	match cmd_name:
		"Magic":
			_open_sub_screen(_magic_screen)
			if _magic_screen.has_method("open"):
				_magic_screen.open(character_id)
		"Abilities":
			_open_sub_screen(_abilities_screen)
			if _abilities_screen.has_method("open"):
				_abilities_screen.open(character_id)
		"Equip":
			_open_sub_screen(_equip_screen)
			if _equip_screen.has_method("open"):
				_equip_screen.open(character_id)
		"Status":
			_open_sub_screen(_status_screen)
			if _status_screen.has_method("open"):
				_status_screen.open(character_id)
		"Crystal":
			_open_sub_screen(_crystal_screen)
			if _crystal_screen.has_method("open"):
				_crystal_screen.open(character_id)


func _open_sub_screen(screen: Control) -> void:
	_hide_all_sub_screens()
	_main_panel.visible = false
	_command_panel.visible = false
	_info_panel.visible = false
	_cursor.visible = false
	screen.visible = true
	_active_sub_screen = screen
	_state = MenuState.SUB_SCREEN


func _close_sub_screen() -> void:
	if _active_sub_screen != null:
		if _active_sub_screen.has_method("close"):
			_active_sub_screen.close()
		_active_sub_screen.visible = false
		_active_sub_screen = null
	_stub_label.visible = false
	if _config_direct:
		_config_direct = false
		_consume_input()
		GameManager.pop_overlay()
		return
	_main_panel.visible = true
	_command_panel.visible = true
	_info_panel.visible = true
	_cursor.visible = true
	_state = MenuState.COMMAND
	_refresh_party_data()
	_update_display()
	_update_info_panel()


func _hide_all_sub_screens() -> void:
	if _magic_screen != null:
		_magic_screen.visible = false
	if _item_screen != null:
		_item_screen.visible = false
	if _abilities_screen != null:
		_abilities_screen.visible = false
	if _equip_screen != null:
		_equip_screen.visible = false
	if _status_screen != null:
		_status_screen.visible = false
	if _config_screen != null:
		_config_screen.visible = false
	if _formation_screen != null:
		_formation_screen.visible = false
	if _crystal_screen != null:
		_crystal_screen.visible = false
	if _stub_label != null:
		_stub_label.visible = false


func _show_stub_message() -> void:
	_hide_all_sub_screens()
	_stub_label.text = "Not yet available"
	_stub_label.visible = true
	_active_sub_screen = null
	_state = MenuState.SUB_SCREEN


func _open_save() -> void:
	if not PartyState.is_at_save_point:
		return  # Save command is disabled (greyed out)
	# Cache tree ref before pop — after pop_overlay this node may be freed.
	var tree: SceneTree = get_tree()
	# Pop menu silently (keeps tree paused, no NONE signal) then immediately
	# push save overlay — no one-frame gap where tree unpauses.
	GameManager.pop_overlay(true)
	if not GameManager.push_overlay(GameManager.OverlayState.SAVE_LOAD):
		# Recovery: re-push the menu overlay so the game doesn't soft-lock
		# with the tree paused and no overlay to accept input.
		if not GameManager.push_overlay(GameManager.OverlayState.MENU):
			if tree != null:
				tree.paused = false
		return
	if GameManager.overlay_node != null and GameManager.overlay_node.has_method("open_save"):
		GameManager.overlay_node.open_save()


func _refresh_party_data() -> void:
	_active_party = PartyState.get_active_party()


func _update_display() -> void:
	# Update command labels
	for i: int in range(_command_labels.size()):
		var label: Label = _command_labels[i]
		var is_disabled: bool = _is_command_disabled(i)
		if i == _command_index:
			label.modulate = COLOR_DISABLED if is_disabled else COLOR_SELECTED
		else:
			label.modulate = COLOR_DISABLED if is_disabled else COLOR_NORMAL
	# Update command cursor
	if _cursor != null and _command_index < _command_labels.size():
		var target: Label = _command_labels[_command_index]
		_cursor.position = Vector2(target.position.x - 48, target.position.y + target.size.y / 2.0)
	# Update party rows
	for i: int in range(4):
		if _party_rows[i] == null:
			continue
		if i >= _active_party.size():
			_party_rows[i].visible = false
			continue
		_party_rows[i].visible = true
		_update_party_row(i, _active_party[i])


func _update_party_row(slot: int, member: Dictionary) -> void:
	var row: Control = _party_rows[slot]
	if row == null:
		return
	var name_label: Label = row.get_node_or_null("NameLabel")
	if name_label != null:
		name_label.text = member.get("character_id", "???").to_upper()
		name_label.modulate = Color.WHITE

	var lv_label: Label = row.get_node_or_null("LvLabel")
	if lv_label != null:
		lv_label.text = "LV %d" % member.get("level", 1)

	var hp_label: Label = row.get_node_or_null("HPLabel")
	if hp_label != null:
		var hp: int = member.get("current_hp", 0)
		var max_hp: int = member.get("max_hp", 1)
		hp_label.text = "HP %d/%d" % [hp, max_hp]
		hp_label.modulate = COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP

	var mp_label: Label = row.get_node_or_null("MPLabel")
	if mp_label != null:
		mp_label.text = "MP %d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]
		mp_label.modulate = COLOR_MP


func _clear_char_highlight() -> void:
	for i: int in range(_party_rows.size()):
		if _party_rows[i] == null:
			continue
		var name_lbl: Label = _party_rows[i].get_node_or_null("NameLabel")
		if name_lbl != null:
			name_lbl.modulate = Color.WHITE


func _update_char_highlight() -> void:
	for i: int in range(_party_rows.size()):
		if _party_rows[i] == null:
			continue
		var name_lbl: Label = _party_rows[i].get_node_or_null("NameLabel")
		if name_lbl != null:
			name_lbl.modulate = COLOR_SELECTED if i == _char_index else Color.WHITE


func _update_info_panel() -> void:
	if _gold_label != null:
		_gold_label.text = "%s Gold" % _format_number(PartyState.get_gold())
		_gold_label.modulate = COLOR_GOLD
	if _time_label != null:
		var total: int = PartyState.playtime
		var hours: int = total / 3600
		var minutes: int = (total % 3600) / 60
		_time_label.text = "%d:%02d" % [hours, minutes]
	if _location_label != null:
		_location_label.text = PartyState.location_name


func _is_command_disabled(index: int) -> bool:
	var cmd: Dictionary = COMMANDS[index]
	if cmd.get("name", "") == "Save":
		return not PartyState.is_at_save_point
	return cmd.get("stubbed", false)


func _consume_input() -> void:
	var vp: Viewport = get_viewport()
	if vp != null:
		vp.set_input_as_handled()


func _format_number(value: int) -> String:
	var s: String = str(value)
	if value < 1000:
		return s
	var parts: Array[String] = []
	while s.length() > 3:
		parts.insert(0, s.right(3))
		s = s.left(s.length() - 3)
	parts.insert(0, s)
	return ",".join(parts)
