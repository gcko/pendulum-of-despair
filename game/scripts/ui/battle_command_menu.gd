extends PanelContainer
## Command panel + sub-menus + target selection for battle.

signal command_selected(command: Dictionary)
signal command_cancelled
signal submenu_opened
signal submenu_closed
signal target_changed(index: int, is_enemy: bool)

enum MenuState { HIDDEN, COMMAND, SUBMENU, TARGET }

const SubmenuItems := preload("res://scripts/ui/battle_submenu_items.gd")

## Third-slot label per character (ui-design.md § 2.4 Command Panel).
const UNIQUE_COMMAND_NAMES: Dictionary = {
	"edren": "Bulwark",
	"cael": "Rally",
	"lira": "Forgewright",
	"torren": "Spiritcall",
	"sable": "Tricks",
	"maren": "Arcanum",
}

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_DISABLED: Color = Color("#666688")

var _state: MenuState = MenuState.HIDDEN
var _cursor: int = 0
var _commands: Array[Dictionary] = []
var _submenu_items: Array[Dictionary] = []
var _submenu_cursor: int = 0
var _is_boss: bool = false
var _target_cursor: int = 0
var _target_is_enemy: bool = true
var _pending_command: Dictionary = {}
## Live range of the cursor in the mode currently being targeted. Derived from
## the per-mode counts below on every entry into TARGET, never carried over from
## the previous mode — an ally-targeted spell must not shrink the enemy row.
var _target_count: int = 0
## Enemies enemy targeting may cycle through. BattleUI pushes the encounter's
## size each turn; the default keeps a caller that never sets it on one target.
var _enemy_target_count: int = 1
## Party slots ally targeting may cycle through. BattleUI pushes the live party
## size; the four-slot default keeps a caller that never sets it working (#276).
var _party_target_count: int = 4
var _character_data: Dictionary = {}
## The acting member's BattleState record: MP for affordability, statuses for
## what a status blocks. {} when the caller has none.
var _member: Dictionary = {}

# get_node_or_null (not $) so unit tests can instantiate the menu via .new()
# without a scene tree; every use of these refs is already null-guarded.
@onready var _command_list: VBoxContainer = get_node_or_null("CommandList")
@onready var _submenu: PanelContainer = get_node_or_null("SubMenu")
@onready var _submenu_list: VBoxContainer = get_node_or_null("SubMenu/SubMenuList")


func _ready() -> void:
	visible = false
	if _submenu != null:
		_submenu.visible = false


## Show command menu for a party member.
## [param member] is the actor's BattleState record; it drives MP affordability
## in the Magic and Ability submenus, and status blocks on Magic (Silence) and
## on the unique command.
func show_commands(character_data: Dictionary, is_boss: bool, member: Dictionary = {}) -> void:
	_is_boss = is_boss
	_character_data = character_data
	_member = member
	_cursor = 0
	_state = MenuState.COMMAND

	var cid: String = character_data.get("character_id", character_data.get("id", ""))
	var ability_name: String = UNIQUE_COMMAND_NAMES.get(cid, "Ability")
	var ability_on: bool = SubmenuItems.ability_command_enabled(character_data, _member)
	var magic_on: bool = SubmenuItems.magic_command_enabled(_member)
	_commands = [
		{"label": "Attack", "type": "attack", "enabled": true},
		{"label": "Magic", "type": "magic", "enabled": magic_on},
		{"label": ability_name, "type": "ability", "enabled": ability_on},
		{"label": "Item", "type": "item", "enabled": true},
		{"label": "Defend", "type": "defend", "enabled": true},
		{"label": "Flee", "type": "flee", "enabled": not _is_boss},
	]

	_update_command_display()
	visible = true


## Hide the command menu.
func hide_menu() -> void:
	_state = MenuState.HIDDEN
	visible = false
	if _submenu != null:
		_submenu.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Fix: only consume input when the menu is both active and visible
	if _state == MenuState.HIDDEN or not visible:
		return

	var handled: bool = false
	match _state:
		MenuState.COMMAND:
			handled = _handle_command_input(event)
		MenuState.SUBMENU:
			handled = _handle_submenu_input(event)
		MenuState.TARGET:
			handled = _handle_target_input(event)

	if handled:
		InputUtil.consume(self)


func _handle_command_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_up"):
		_cursor = (_cursor - 1 + _commands.size()) % _commands.size()
		_update_command_display()
		return true
	if event.is_action_pressed("ui_down"):
		_cursor = (_cursor + 1) % _commands.size()
		_update_command_display()
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_command()
		return true
	if event.is_action_pressed("ui_cancel"):
		command_cancelled.emit()
		return true
	return false


func _handle_submenu_input(event: InputEvent) -> bool:
	if _submenu_items.is_empty():
		if event.is_action_pressed("ui_cancel"):
			_state = MenuState.COMMAND
			if _submenu != null:
				_submenu.visible = false
			submenu_closed.emit()
			return true
		return false
	if event.is_action_pressed("ui_up"):
		_submenu_cursor = (_submenu_cursor - 1 + _submenu_items.size()) % _submenu_items.size()
		_update_submenu_display()
		return true
	if event.is_action_pressed("ui_down"):
		_submenu_cursor = (_submenu_cursor + 1) % _submenu_items.size()
		_update_submenu_display()
		return true
	if event.is_action_pressed("ui_accept"):
		_confirm_submenu()
		return true
	if event.is_action_pressed("ui_cancel"):
		_state = MenuState.COMMAND
		if _submenu != null:
			_submenu.visible = false
		submenu_closed.emit()
		return true
	return false


func _handle_target_input(event: InputEvent) -> bool:
	var old_cursor: int = _target_cursor
	var handled: bool = false
	if _target_is_enemy:
		if event.is_action_pressed("ui_left"):
			_target_cursor = (_target_cursor - 1 + _target_count) % _target_count
			handled = true
		elif event.is_action_pressed("ui_right"):
			_target_cursor = (_target_cursor + 1) % _target_count
			handled = true
	else:
		if event.is_action_pressed("ui_up"):
			_target_cursor = (_target_cursor - 1 + _target_count) % _target_count
			handled = true
		elif event.is_action_pressed("ui_down"):
			_target_cursor = (_target_cursor + 1) % _target_count
			handled = true

	if _target_cursor != old_cursor:
		target_changed.emit(_target_cursor, _target_is_enemy)

	if event.is_action_pressed("ui_accept"):
		_pending_command["target"] = _target_cursor
		target_changed.emit(-1, _target_is_enemy)  # Hide arrow
		command_selected.emit(_pending_command)
		hide_menu()
		return true
	if event.is_action_pressed("ui_cancel"):
		target_changed.emit(-1, _target_is_enemy)  # Hide arrow
		if _pending_command.get("type", "") == "attack":
			_state = MenuState.COMMAND
			submenu_closed.emit()
		else:
			_state = MenuState.SUBMENU
			if _submenu != null:
				_submenu.visible = true
		return true
	return handled


func _confirm_command() -> void:
	var cmd: Dictionary = _commands[_cursor]
	if not cmd.get("enabled", true):
		return

	match cmd["type"]:
		"attack":
			_pending_command = {"type": "attack"}
			_start_target_selection(true)
		"magic":
			set_submenu_items(SubmenuItems.magic(_character_data, _member))
			_show_submenu()
		"ability":
			set_submenu_items(SubmenuItems.abilities(_character_data, _member))
			_show_submenu()
		"item":
			set_submenu_items(SubmenuItems.items())
			_show_submenu()
		"defend":
			command_selected.emit({"type": "defend"})
			hide_menu()
		"flee":
			command_selected.emit({"type": "flee"})
			hide_menu()


## Enter target selection, sizing the cursor's range from the count belonging to
## the mode being entered. Reading the mode's own field (rather than whatever the
## last selection left behind) is what stops a single_ally spell the player
## backed out of from capping the enemy cursor at the party size (#276).
func _start_target_selection(is_enemy: bool) -> void:
	_target_is_enemy = is_enemy
	_target_cursor = 0
	_target_count = maxi(1, _enemy_target_count if is_enemy else _party_target_count)
	_state = MenuState.TARGET
	submenu_opened.emit()
	target_changed.emit(0, is_enemy)


func _show_submenu() -> void:
	_submenu_cursor = 0
	_state = MenuState.SUBMENU
	submenu_opened.emit()
	if _submenu != null:
		_submenu.visible = true
	_update_submenu_display()


func _confirm_submenu() -> void:
	if _submenu_items.is_empty():
		return
	var item: Dictionary = _submenu_items[_submenu_cursor]
	if not item.get("enabled", true):
		return
	_pending_command = item.get("command", {})
	var target_type: String = item.get("target_type", "single_enemy")
	match target_type:
		"single_enemy":
			_start_target_selection(true)
		"single_ally":
			_start_target_selection(false)
		"all_enemies", "all_allies", "self":
			command_selected.emit(_pending_command)
			hide_menu()
		_:
			_start_target_selection(true)


## Set submenu items (called by battle_ui).
func set_submenu_items(items: Array[Dictionary]) -> void:
	_submenu_items = items
	_update_submenu_display()


## Set how many enemies enemy targeting may address. Minimum 1 for the modulo.
func set_enemy_count(count: int) -> void:
	_enemy_target_count = maxi(1, count)


## Set how many party slots ally targeting may address — the live party size, so
## the cursor never lands on an empty slot (#276). Minimum 1 for the modulo.
func set_party_count(count: int) -> void:
	_party_target_count = maxi(1, count)


func _update_command_display() -> void:
	if _command_list == null:
		return
	for i: int in range(_command_list.get_child_count()):
		if i >= _commands.size():
			break
		var label: Label = _command_list.get_child(i) as Label
		if label == null:
			continue
		label.text = _commands[i].get("label", "")
		if not _commands[i].get("enabled", true):
			label.modulate = COLOR_DISABLED
		elif i == _cursor:
			label.modulate = COLOR_SELECTED
		else:
			label.modulate = COLOR_NORMAL


func _update_submenu_display() -> void:
	if _submenu_list == null:
		return
	for child: Node in _submenu_list.get_children():
		child.queue_free()
	for i: int in range(_submenu_items.size()):
		var label: Label = Label.new()
		label.text = _submenu_items[i].get("label", "")
		if not _submenu_items[i].get("enabled", true):
			label.modulate = COLOR_DISABLED
		elif i == _submenu_cursor:
			label.modulate = COLOR_SELECTED
		else:
			label.modulate = COLOR_NORMAL
		_submenu_list.add_child(label)
