extends PanelContainer
## Renders party member rows in battle (ui-design.md § 2.1/2.3/2.9). Each
## row is two lines, as the § 2.1 ASCII draws it:
##   NAME   HP [bar] 680/800
##          MP [bar]  48/80        [ATB]
## with Maren's Weave Gauge under her MP bar and the ATB gauge at the far
## right of the MP line. Scene: scenes/ui/battle_party_panel.tscn.
## Updated by BattleUI's per-frame poll — stays pull-based because MP
## changes emit no signals. That poll is also the ATB ready flash's clock.

const ATBSystemScript = preload("res://scripts/combat/atb_system.gd")

const COLOR_NAME_NORMAL: Color = Color("#ffffff")
const COLOR_NAME_ACTIVE: Color = Color("#ffff88")

## Weave Gauge maximum charge (abilities.md: WG 0-100).
const WEAVE_MAX: int = 100

## Precomputed ATB gauge keys — update_party runs in a per-frame poll,
## so avoid rebuilding "party_%d" strings every frame.
const PARTY_KEYS: Array[String] = ["party_0", "party_1", "party_2", "party_3"]

## The ATB ready flash's cels, one per frame (ui-design.md § 2.3: "2-frame
## flash alternating gold and white"). Gold first, so the frame a gauge fills
## still reads as the gold bar the player watched filling.
const ATB_FLASH_CELS: Array[Color] = [StatBarHelpers.COLOR_ATB_FILL, StatBarHelpers.COLOR_ATB_FLASH]

## What the ATB flash counts frames in: rendered (process) frames. With
## run/max_fps = 60 that is the 60 Hz frame at full speed, and below 60 fps
## every drawn frame still flips the cel, so the flash cannot alias away the
## way a battle-tick count would at 30 fps. It is not battle time: a full gauge
## keeps flashing while Wait mode pauses the gauges, because that member is
## still ready. Swappable so tests can step frames by hand.
var frame_clock: Callable = Callable(Engine, "get_process_frames")

## Per-row node caches (Dictionary of refs), filled once in _ready so the
## per-frame poll does no get_node_or_null lookups.
var _rows: Array = [{}, {}, {}, {}]
var _active_slot: int = -1
## Per-row frame_clock value of the frame its ATB gauge became full, or -1
## while it is filling.
var _atb_full_since: Array[int] = [-1, -1, -1, -1]


func _ready() -> void:
	for i: int in range(4):
		_rows[i] = _cache_row(get_node_or_null("Rows/Row%d" % i))


## Update all party rows from state data.
func update_party(members: Array, gauges: Dictionary) -> void:
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


func _cache_row(row: Control) -> Dictionary:
	if row == null:
		return {}
	# The HP/MP labels are fixed text in the scene; their colors are set
	# once here from the same constants the bars use (§ 2.3: HP label green,
	# MP label blue — the label stays green when the HP bar turns red).
	var hp_prefix: Label = row.get_node_or_null("HPLine/HPPrefix")
	if hp_prefix != null:
		hp_prefix.modulate = StatBarHelpers.COLOR_HP_FILL
	var mp_prefix: Label = row.get_node_or_null("MPLine/MPPrefix")
	if mp_prefix != null:
		mp_prefix.modulate = StatBarHelpers.COLOR_MP_FILL
	return {
		"row": row,
		"name_label": row.get_node_or_null("HPLine/NameLabel"),
		"hp_label": row.get_node_or_null("HPLine/HPLabel"),
		"hp_bg": row.get_node_or_null("HPLine/HPBarBg"),
		"hp_fill": row.get_node_or_null("HPLine/HPBarBg/HPBarFill"),
		"mp_label": row.get_node_or_null("MPLine/MPLabel"),
		"mp_bg": row.get_node_or_null("MPLine/MPCluster/MPBarBg"),
		"mp_fill": row.get_node_or_null("MPLine/MPCluster/MPBarBg/MPBarFill"),
		"weave_bg": row.get_node_or_null("MPLine/MPCluster/WeaveBarBg"),
		"weave_fill": row.get_node_or_null("MPLine/MPCluster/WeaveBarBg/WeaveBarFill"),
		"atb_bg": row.get_node_or_null("MPLine/ATBBarBg"),
		"atb_fill": row.get_node_or_null("MPLine/ATBBarBg/ATBBarFill"),
	}


func _update_row(slot: int, member: Dictionary, atb_gauge: int) -> void:
	var refs: Dictionary = _rows[slot]

	var name_label: Label = refs["name_label"]
	if name_label != null:
		# Uppercase, as § 2.1's layout and § 1.5 ("bold/uppercase") draw names.
		name_label.text = str(member.get("character_data", {}).get("name", "???")).to_upper()
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
	_update_atb_flash(slot, refs["atb_fill"], atb_gauge)


## Full gauge: alternate the fill gold/white one cel per frame, starting on
## gold the frame it fills. Any other value: steady gold, and the next fill
## starts the cycle over (ui-design.md § 2.3).
func _update_atb_flash(slot: int, fill: ColorRect, atb_gauge: int) -> void:
	if atb_gauge < ATBSystemScript.GAUGE_MAX:
		_atb_full_since[slot] = -1
	elif _atb_full_since[slot] < 0:
		_atb_full_since[slot] = int(frame_clock.call())
	if fill == null:
		return
	if _atb_full_since[slot] < 0:
		fill.color = StatBarHelpers.COLOR_ATB_FILL
		return
	var frames_full: int = int(frame_clock.call()) - _atb_full_since[slot]
	fill.color = ATB_FLASH_CELS[frames_full % ATB_FLASH_CELS.size()]


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
