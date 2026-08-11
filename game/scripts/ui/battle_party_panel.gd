extends PanelContainer
## Renders party member rows in battle: name, HP/MP numerics + solid
## pixel fill bars, Maren's Weave Gauge, and the ATB gauge
## (ui-design.md § 2.1/2.3/2.9). Scene: scenes/ui/battle_party_panel.tscn.
## Updated by BattleUI's per-frame poll — stays pull-based because MP
## changes emit no signals.

const ATBSystemScript = preload("res://scripts/combat/atb_system.gd")

const COLOR_NAME_NORMAL: Color = Color("#ffffff")
const COLOR_NAME_ACTIVE: Color = Color("#ffff88")

## Weave Gauge maximum charge (abilities.md: WG 0-100).
const WEAVE_MAX: int = 100

## Precomputed ATB gauge keys — update_party runs in a per-frame poll,
## so avoid rebuilding "party_%d" strings every frame.
const PARTY_KEYS: Array[String] = ["party_0", "party_1", "party_2", "party_3"]

## Per-row node caches (Dictionary of refs), filled once in _ready so the
## per-frame poll does no get_node_or_null lookups.
var _rows: Array = [{}, {}, {}, {}]
var _active_slot: int = -1


func _ready() -> void:
	for i: int in range(4):
		_rows[i] = _cache_row(get_node_or_null("Rows/Row%d" % i))


## Update all party rows from state data.
func update_party(members: Array, gauges: Dictionary) -> void:
	for i: int in range(4):
		var refs: Dictionary = _rows[i]
		if refs.is_empty():
			continue
		var row: HBoxContainer = refs["row"]
		var m: Dictionary = members[i] if i < members.size() and members[i] is Dictionary else {}
		if m.is_empty():
			row.visible = false
			continue
		row.visible = true
		_update_row(i, m, gauges.get(PARTY_KEYS[i], 0))


## Set which party member is currently acting.
func set_active_slot(slot: int) -> void:
	_active_slot = slot


## Screen-space rect of a party member's row, so BattleUI can anchor the
## target cursor and damage popups to the real layout instead of a guessed
## row pitch (#276, ui-design.md § 2.6). Returns an empty Rect2 when the
## slot has no row — out of range, uncached, or hidden because the party
## slot is empty — and callers must treat that as "no anchor here".
## Shape-agnostic: a taller multi-line row still reports its own rect.
func get_row_global_rect(slot: int) -> Rect2:
	if slot < 0 or slot >= _rows.size():
		return Rect2()
	var refs: Dictionary = _rows[slot]
	if refs.is_empty():
		return Rect2()
	var row: Control = refs["row"]
	if row == null or not row.visible:
		return Rect2()
	return Rect2(row.global_position, row.size)


func _cache_row(row: HBoxContainer) -> Dictionary:
	if row == null:
		return {}
	return {
		"row": row,
		"name_label": row.get_node_or_null("NameLabel"),
		"hp_label": row.get_node_or_null("HPLabel"),
		"hp_bg": row.get_node_or_null("HPBarBg"),
		"hp_fill": row.get_node_or_null("HPBarBg/HPBarFill"),
		"mp_label": row.get_node_or_null("MPLabel"),
		"mp_bg": row.get_node_or_null("MPCluster/MPBarBg"),
		"mp_fill": row.get_node_or_null("MPCluster/MPBarBg/MPBarFill"),
		"weave_bg": row.get_node_or_null("MPCluster/WeaveBarBg"),
		"weave_fill": row.get_node_or_null("MPCluster/WeaveBarBg/WeaveBarFill"),
		"atb_bg": row.get_node_or_null("ATBBarBg"),
		"atb_fill": row.get_node_or_null("ATBBarBg/ATBBarFill"),
	}


func _update_row(slot: int, member: Dictionary, atb_gauge: int) -> void:
	var refs: Dictionary = _rows[slot]

	var name_label: Label = refs["name_label"]
	if name_label != null:
		name_label.text = member.get("character_data", {}).get("name", "???")
		name_label.modulate = COLOR_NAME_ACTIVE if slot == _active_slot else COLOR_NAME_NORMAL

	var hp: int = member.get("current_hp", 0)
	var max_hp: int = member.get("max_hp", 1)
	var hp_color: Color = StatBarHelpers.hp_fill_color(hp, max_hp)
	var hp_label: Label = refs["hp_label"]
	if hp_label != null:
		hp_label.text = "%d/%d" % [hp, max_hp]
		hp_label.modulate = hp_color
	_set_fill(refs["hp_bg"], refs["hp_fill"], hp, max_hp)
	var hp_fill: ColorRect = refs["hp_fill"]
	if hp_fill != null:
		hp_fill.color = hp_color

	var mp: int = member.get("current_mp", 0)
	var max_mp: int = member.get("max_mp", 0)
	var mp_label: Label = refs["mp_label"]
	if mp_label != null:
		mp_label.text = "%d/%d" % [mp, max_mp]
		mp_label.modulate = StatBarHelpers.COLOR_MP_FILL
	_set_fill(refs["mp_bg"], refs["mp_fill"], mp, max_mp)

	_update_weave(refs, member)
	_set_fill(refs["atb_bg"], refs["atb_fill"], atb_gauge, ATBSystemScript.GAUGE_MAX)


## Maren-only Weave Gauge below the MP bar (ui-design.md § 2.9).
func _update_weave(refs: Dictionary, member: Dictionary) -> void:
	var weave_bg: ColorRect = refs["weave_bg"]
	if weave_bg == null:
		return
	var shows: bool = StatBarHelpers.shows_weave_gauge(member.get("character_id", ""))
	weave_bg.visible = shows
	if shows:
		_set_fill(refs["weave_bg"], refs["weave_fill"], member.get("wg", 0), WEAVE_MAX)
		var weave_fill: ColorRect = refs["weave_fill"]
		if weave_fill != null:
			weave_fill.color = StatBarHelpers.COLOR_WEAVE_FILL


## Size a fill rect against its track's authored width — deterministic
## under headless container layout.
func _set_fill(bg: ColorRect, fill: ColorRect, current: int, max_value: int) -> void:
	if bg == null or fill == null:
		return
	fill.size.x = StatBarHelpers.fill_width(current, max_value, bg.custom_minimum_size.x)
