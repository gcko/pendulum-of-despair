extends PanelContainer
## Renders party member rows in battle: name, HP/MP bars, ATB gauge, status icons.

const COLOR_HP_FILL: Color = Color("#44cc44")
const COLOR_HP_LOW: Color = Color("#ff4444")
const COLOR_MP_FILL: Color = Color("#4488ff")
const COLOR_ATB_FILL: Color = Color("#ffcc00")
const COLOR_NAME_NORMAL: Color = Color("#ffffff")
const COLOR_NAME_ACTIVE: Color = Color("#ffff88")

var _rows: Array = [null, null, null, null]
var _active_slot: int = -1


func _ready() -> void:
	for i: int in range(4):
		var row: HBoxContainer = get_node_or_null("Row%d" % i)
		_rows[i] = row


## Update all party rows from state data.
func update_party(members: Array, gauges: Dictionary) -> void:
	for i: int in range(4):
		if _rows[i] == null:
			continue
		var m: Dictionary = members[i] if i < members.size() and members[i] is Dictionary else {}
		if m.is_empty():
			_rows[i].visible = false
			continue
		_rows[i].visible = true
		_update_row(i, m, gauges.get("party_%d" % i, 0))


func _update_row(slot: int, member: Dictionary, atb_gauge: int) -> void:
	var row: HBoxContainer = _rows[slot]
	if row == null:
		return

	var name_label: Label = row.get_node_or_null("NameLabel")
	if name_label != null:
		name_label.text = member.get("character_data", {}).get("name", "???")
		name_label.modulate = COLOR_NAME_ACTIVE if slot == _active_slot else COLOR_NAME_NORMAL

	var hp_label: Label = row.get_node_or_null("HPLabel")
	if hp_label != null:
		var hp: int = member.get("current_hp", 0)
		var max_hp: int = member.get("max_hp", 1)
		hp_label.text = "%d/%d" % [hp, max_hp]
		hp_label.modulate = COLOR_HP_LOW if hp < max_hp / 4 else COLOR_HP_FILL

	var mp_label: Label = row.get_node_or_null("MPLabel")
	if mp_label != null:
		mp_label.text = "%d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]
		mp_label.modulate = COLOR_MP_FILL

	var atb_bar: ColorRect = row.get_node_or_null("ATBBar")
	if atb_bar != null:
		var fill_ratio: float = float(atb_gauge) / 16000.0
		atb_bar.size.x = fill_ratio * 20.0
		atb_bar.color = COLOR_ATB_FILL


## Set which party member is currently acting.
func set_active_slot(slot: int) -> void:
	_active_slot = slot
