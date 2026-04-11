extends Control
## Status sub-screen: read-only character stat sheet.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_HP: Color = Color("#44cc44")
const COLOR_HP_LOW: Color = Color("#ff4444")
const COLOR_MP: Color = Color("#4488ff")

const STAT_NAMES: Array[String] = ["atk", "def", "mag", "mdef", "spd", "lck"]
const STAT_DISPLAY: Array[String] = ["ATK", "DEF", "MAG", "MDEF", "SPD", "LCK"]

const SLOT_NAMES: Array[String] = ["weapon", "head", "body", "accessory", "crystal"]
const SLOT_DISPLAY: Array[String] = ["Weapon", "Head", "Body", "Access", "Crystal"]

var _character_id: String = ""

@onready var _name_label: Label = $Layout/IdentityPanel/IdentityRow/NameCol/NameLabel
@onready var _class_label: Label = $Layout/IdentityPanel/IdentityRow/NameCol/ClassLabel
@onready var _lv_label: Label = $Layout/IdentityPanel/IdentityRow/LevelCol/LvLabel
@onready var _xp_label: Label = $Layout/IdentityPanel/IdentityRow/LevelCol/XpLabel
@onready var _next_label: Label = $Layout/IdentityPanel/IdentityRow/LevelCol/NextLabel
@onready var _hp_label: Label = $Layout/IdentityPanel/IdentityRow/VitalCol/HPLabel
@onready var _mp_label: Label = $Layout/IdentityPanel/IdentityRow/VitalCol/MPLabel
@onready var _stat_labels: Array[Label] = []
@onready var _derived_labels: Array[Label] = []
@onready var _cmd_labels: Array[Label] = []
@onready var _equip_labels: Array[Label] = []


func _ready() -> void:
	_stat_labels = []
	for i: int in range(6):
		var label: Label = get_node_or_null(
			"Layout/DetailRow/RightCol/StatPanel/StatList/Stat%d" % i
		)
		if label != null:
			_stat_labels.append(label)
	_derived_labels = []
	for i: int in range(3):
		var label: Label = get_node_or_null(
			"Layout/DetailRow/RightCol/StatPanel/StatList/Derived%d" % i
		)
		if label != null:
			_derived_labels.append(label)
	_cmd_labels = []
	for i: int in range(5):
		var label: Label = get_node_or_null("Layout/DetailRow/LeftCol/CmdPanel/CmdList/Cmd%d" % i)
		if label != null:
			_cmd_labels.append(label)
	_equip_labels = []
	for i: int in range(5):
		var label: Label = get_node_or_null(
			"Layout/DetailRow/RightCol/EquipPanel/EquipList/Equip%d" % i
		)
		if label != null:
			_equip_labels.append(label)


func open(character_id: String) -> void:
	_character_id = character_id
	_update_display()


func close() -> void:
	pass


## Read-only screen — cancel always returns to menu.
func handle_input(_event: InputEvent) -> bool:
	return false


func _update_display() -> void:
	var member: Dictionary = PartyState.get_member(_character_id)
	if member.is_empty():
		return

	# Identity
	if _name_label != null:
		_name_label.text = _character_id.to_upper()
	if _class_label != null:
		_class_label.text = PartyState.CLASS_TITLES.get(_character_id, "")
	if _lv_label != null:
		_lv_label.text = "LV %d" % member.get("level", 1)
	if _xp_label != null:
		_xp_label.text = "Exp %s" % _format_number(member.get("current_xp", 0))
	if _next_label != null:
		_next_label.text = "Next %s" % _format_number(member.get("xp_to_next", 0))

	# HP/MP
	var hp: int = member.get("current_hp", 0)
	var max_hp: int = member.get("max_hp", 1)
	if _hp_label != null:
		_hp_label.text = "HP %d/%d" % [hp, max_hp]
		_hp_label.modulate = COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP
	if _mp_label != null:
		_mp_label.text = "MP %d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]
		_mp_label.modulate = COLOR_MP

	# Core stats
	for i: int in range(_stat_labels.size()):
		if _stat_labels[i] == null:
			continue
		var stat: String = STAT_NAMES[i]
		var effective: int = PartyState.get_effective_stat(_character_id, stat)
		var bonus: int = PartyState.get_equipment_bonus(_character_id, stat)
		var bonus_str: String = "(+%d)" % bonus if bonus > 0 else ""
		_stat_labels[i].text = "%s  %d %s" % [STAT_DISPLAY[i], effective, bonus_str]
		_stat_labels[i].modulate = COLOR_NORMAL

	# Derived stats
	var derived: Dictionary = PartyState.get_derived_stats(_character_id)
	var derived_names: Array[String] = ["EVA%", "MEVA%", "CRIT%"]
	var derived_keys: Array[String] = ["eva_pct", "meva_pct", "crit_pct"]
	for i: int in range(_derived_labels.size()):
		if _derived_labels[i] == null:
			continue
		if i < derived_keys.size():
			_derived_labels[i].text = (
				"%s %d%%" % [derived_names[i], derived.get(derived_keys[i], 0)]
			)
			_derived_labels[i].modulate = COLOR_NORMAL

	# Battle commands
	var ability_name: String = _get_ability_name(_character_id)
	var cmds: Array[String] = ["Attack", "Magic", ability_name, "Item", "Defend"]
	for i: int in range(_cmd_labels.size()):
		if _cmd_labels[i] != null and i < cmds.size():
			_cmd_labels[i].text = cmds[i]
			_cmd_labels[i].modulate = COLOR_NORMAL

	# Equipment summary
	var equip: Dictionary = member.get("equipment", {})
	for i: int in range(_equip_labels.size()):
		if _equip_labels[i] == null:
			continue
		if i < SLOT_NAMES.size():
			var slot_name: String = SLOT_NAMES[i]
			var eid: String = equip.get(slot_name, "")
			var equip_name: String = _get_equipment_name(eid, slot_name)
			_equip_labels[i].text = "%s: %s" % [SLOT_DISPLAY[i], equip_name]
			_equip_labels[i].modulate = COLOR_NORMAL


func _get_ability_name(character_id: String) -> String:
	match character_id:
		"edren":
			return "Bulwark"
		"cael":
			return "Rally"
		"lira":
			return "Forgewright"
		"torren":
			return "Spiritcall"
		"sable":
			return "Tricks"
		"maren":
			return "Arcanum"
	return "Ability"


func _get_equipment_name(equip_id: String, slot: String = "") -> String:
	if equip_id == "":
		return "---"
	if slot == "crystal":
		var crystal_data: Dictionary = DataManager.get_ley_crystal(equip_id)
		return crystal_data.get("name", equip_id)
	var data: Dictionary = Helpers.lookup_equipment(equip_id)
	return data.get("name", equip_id)


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
