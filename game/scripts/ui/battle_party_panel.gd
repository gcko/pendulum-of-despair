extends PanelContainer
## Renders party member rows in battle (ui-design.md § 2.1/2.3/2.9). Each
## row is two lines, as the § 2.1 ASCII draws it:
##   NAME   HP [bar] 680/800
##          MP [bar]  48/ 80       [ATB]
## with Maren's Weave Gauge under her MP bar and the ATB gauge at the far
## right of the MP line. Scene: scenes/ui/battle_party_panel.tscn.
## Updated by BattleUI's per-frame poll — stays pull-based because MP
## changes emit no signals.

const ATBSystemScript = preload("res://scripts/combat/atb_system.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

const COLOR_NAME_NORMAL: Color = Color("#ffffff")
const COLOR_NAME_ACTIVE: Color = Color("#ffff88")

## Weave Gauge maximum charge (abilities.md: WG 0-100).
const WEAVE_MAX: int = 100

## Precomputed ATB gauge keys — update_party runs in a per-frame poll,
## so avoid rebuilding "party_%d" strings every frame.
const PARTY_KEYS: Array[String] = ["party_0", "party_1", "party_2", "party_3"]

## What the ATB ready flash is timed by: wall-clock milliseconds, so each
## cel holds ATB_FLASH_HOLD_MS whatever the frame rate. It is not battle time:
## a full gauge keeps flashing while Wait mode pauses the gauges, because
## that member is still ready. Swappable so tests can step time by hand.
var clock_msec: Callable = Callable(Time, "get_ticks_msec")

## Per-row node caches (Dictionary of refs), filled once in _ready so the
## per-frame poll does no get_node_or_null lookups.
var _rows: Array = [{}, {}, {}, {}]
var _active_slot: int = -1
## The ready flash's cels for the player's Flash Intensity, read once in
## _ready (Reduce Motion forces that setting to "off" in the Config menu).
var _atb_cels: Array[Color] = []
## Per-row clock_msec value when its ATB gauge became full, or -1 while it
## is filling, frozen, or the row is hidden.
var _atb_full_since: Array[int] = [-1, -1, -1, -1]
## Per-row source name last written to the name label, so the uppercase copy
## is built only when the member in the slot changes, not every frame.
var _name_source: Array = [null, null, null, null]


func _ready() -> void:
	_atb_cels = StatBarHelpers.atb_flash_cels(
		str(PartyState.get_config().get("flash_intensity", "full"))
	)
	for i: int in range(4):
		_rows[i] = _cache_row(get_node_or_null("Rows/Row%d" % i))


## Update all party rows from state data.
func update_party(members: Array, gauges: Dictionary) -> void:
	var now_msec: int = int(clock_msec.call())
	for i: int in range(4):
		var refs: Dictionary = _rows[i]
		if refs.is_empty():
			continue
		var row: Control = refs["row"]
		var m: Dictionary = members[i] if i < members.size() and members[i] is Dictionary else {}
		if m.is_empty():
			row.visible = false
			_atb_full_since[i] = -1
			continue
		row.visible = true
		_update_row(i, m, gauges.get(PARTY_KEYS[i], 0), now_msec)


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


func _cache_row(row: Control) -> Dictionary:
	if row == null:
		return {}
	# The "HP"/"MP" labels are fixed text in the scene; their colors are set
	# once here (§ 2.3: HP label green, MP label blue; § 1.4: HP text is
	# #44ff44). The label stays green when the HP bar and number turn red.
	var hp_label: Label = row.get_node_or_null("HPLine/HPLabel")
	if hp_label != null:
		hp_label.modulate = StatBarHelpers.COLOR_HP_TEXT
	var mp_label: Label = row.get_node_or_null("MPLine/MPLabel")
	if mp_label != null:
		mp_label.modulate = StatBarHelpers.COLOR_MP_FILL
	return {
		"row": row,
		"name_label": row.get_node_or_null("HPLine/NameLabel"),
		"hp_value": row.get_node_or_null("HPLine/HPValue"),
		"hp_bg": row.get_node_or_null("HPLine/HPBarBg"),
		"hp_fill": row.get_node_or_null("HPLine/HPBarBg/HPBarFill"),
		"mp_value": row.get_node_or_null("MPLine/MPValue"),
		"mp_bg": row.get_node_or_null("MPLine/MPCluster/MPBarBg"),
		"mp_fill": row.get_node_or_null("MPLine/MPCluster/MPBarBg/MPBarFill"),
		"weave_bg": row.get_node_or_null("MPLine/MPCluster/WeaveBarBg"),
		"weave_fill": row.get_node_or_null("MPLine/MPCluster/WeaveBarBg/WeaveBarFill"),
		"atb_bg": row.get_node_or_null("MPLine/ATBBarBg"),
		"atb_fill": row.get_node_or_null("MPLine/ATBBarBg/ATBBarFill"),
	}


func _update_row(slot: int, member: Dictionary, atb_gauge: int, now_msec: int) -> void:
	var refs: Dictionary = _rows[slot]

	var name_label: Label = refs["name_label"]
	if name_label != null:
		_update_name(slot, name_label, member)
		name_label.modulate = COLOR_NAME_ACTIVE if slot == _active_slot else COLOR_NAME_NORMAL

	var hp: int = member.get("current_hp", 0)
	var max_hp: int = member.get("max_hp", 1)
	var hp_color: Color = StatBarHelpers.hp_fill_color(hp, max_hp)
	var hp_value: Label = refs["hp_value"]
	if hp_value != null:
		hp_value.text = StatBarHelpers.format_stat_pair(hp, max_hp)
		hp_value.modulate = StatBarHelpers.hp_text_color(hp, max_hp)
	_set_fill(refs["hp_bg"], refs["hp_fill"], hp, max_hp)
	var hp_fill: ColorRect = refs["hp_fill"]
	if hp_fill != null:
		hp_fill.color = hp_color

	var mp: int = member.get("current_mp", 0)
	var max_mp: int = member.get("max_mp", 0)
	var mp_value: Label = refs["mp_value"]
	if mp_value != null:
		mp_value.text = StatBarHelpers.format_stat_pair(mp, max_mp)
		mp_value.modulate = StatBarHelpers.COLOR_MP_FILL
	_set_fill(refs["mp_bg"], refs["mp_fill"], mp, max_mp)

	_update_weave(refs, member)
	_set_fill(refs["atb_bg"], refs["atb_fill"], atb_gauge, ATBSystemScript.GAUGE_MAX)
	_update_atb_flash(slot, refs["atb_fill"], atb_gauge, member, now_msec)


## Uppercase, as § 2.1's layout and § 1.5 ("bold/uppercase") draw names. The
## label is rewritten only when the slot's source name changes.
func _update_name(slot: int, name_label: Label, member: Dictionary) -> void:
	var source: Variant = null
	var data: Variant = member.get("character_data")
	if data is Dictionary:
		source = (data as Dictionary).get("name")
	if source == null:
		source = "???"
	if typeof(source) == typeof(_name_source[slot]) and source == _name_source[slot]:
		return
	_name_source[slot] = source
	name_label.text = str(source).to_upper()


## Full gauge: alternate the fill through _atb_cels, each held
## ATB_FLASH_HOLD_MS, starting on gold when it fills (ui-design.md § 2.3).
## Any other value — or a full gauge held by a gauge-freezing status such as
## Sleep, which cannot act on it — is steady gold, and the next ready gauge
## starts the cycle over.
func _update_atb_flash(
	slot: int, fill: ColorRect, atb_gauge: int, member: Dictionary, now_msec: int
) -> void:
	if atb_gauge < ATBSystemScript.GAUGE_MAX or _has_frozen_gauge(member):
		_atb_full_since[slot] = -1
	elif _atb_full_since[slot] < 0:
		_atb_full_since[slot] = now_msec
	if fill == null:
		return
	if _atb_full_since[slot] < 0 or _atb_cels.is_empty():
		fill.color = StatBarHelpers.COLOR_ATB_FILL
		return
	var cel: int = (now_msec - _atb_full_since[slot]) / StatBarHelpers.ATB_FLASH_HOLD_MS
	fill.color = _atb_cels[cel % _atb_cels.size()]


## Whether any active status freezes this member's gauge (Sleep, Petrify —
## StatusEffects.atb_effect "frozen"). Reads the list in place, no copy.
func _has_frozen_gauge(member: Dictionary) -> bool:
	var statuses: Variant = member.get("active_statuses")
	if not statuses is Array:
		return false
	for entry: Variant in statuses:
		if entry is Dictionary:
			if StatusEffects.atb_effect(str((entry as Dictionary).get("name", ""))) == "frozen":
				return true
	return false


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
