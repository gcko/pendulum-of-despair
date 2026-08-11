class_name CrystalDisplay
extends RefCounted
## Turning Ley Crystal data into the strings and bar fractions the crystal menu
## renders: bonus lists, the stat delta against what the character already
## wears, invocation blurbs and XP progress.
##
## Extracted from menu_ley_crystal.gd (GAP-087) — the menu keeps cursor state
## and node wiring; every pure "what does this read as" question lives here.

const STAT_KEYS: Array[String] = ["atk", "def", "mag", "mdef", "spd", "lck"]
const STAT_LABELS: Array[String] = ["ATK", "DEF", "MAG", "MDEF", "SPD", "LCK"]
## Lv5 XP boundary used when a crystal's own threshold table is shorter than
## the level it has reached.
const MAX_XP_FALLBACK: int = 15000


## Format a bonus dict into a human-readable string, e.g. "ATK +2, DEF +1".
static func format_bonus(bonus: Dictionary) -> String:
	if bonus.is_empty():
		return "none"
	var parts: Array[String] = []
	for i: int in range(STAT_KEYS.size()):
		var key: String = STAT_KEYS[i]
		if bonus.has(key):
			parts.append(_signed(STAT_LABELS[i], int(bonus[key])))
	if bonus.has("hp_per_level"):
		parts.append("HP +%d/Lv" % int(bonus["hp_per_level"]))
	if bonus.has("mp_per_level"):
		parts.append("MP +%d/Lv" % int(bonus["mp_per_level"]))
	if parts.is_empty():
		return "none"
	return ", ".join(parts)


## The stat delta a character would see by swapping to [param crystal_id],
## measured against whatever crystal they currently wear.
static func stat_comparison(character_id: String, crystal_id: String, bonus: Dictionary) -> String:
	var current_bonuses: Dictionary = _worn_bonus(character_id, crystal_id)
	var lines: Array[String] = []
	for i: int in range(STAT_KEYS.size()):
		var key: String = STAT_KEYS[i]
		var delta: int = int(bonus.get(key, 0)) - int(current_bonuses.get(key, 0))
		if delta != 0:
			lines.append(_signed(STAT_LABELS[i], delta))
	# HP/MP per-level bonuses (scaled by character level)
	var char_level: int = PartyState.get_member(character_id).get("level", 1)
	for pair: Array in [["hp_per_level", "HP"], ["mp_per_level", "MP"]]:
		var key: String = pair[0]
		var delta: int = (int(bonus.get(key, 0)) - int(current_bonuses.get(key, 0))) * char_level
		if delta != 0:
			lines.append(_signed(pair[1], delta))
	if lines.is_empty():
		return "No stat change"
	return "\n".join(lines)


## Returns the character_id of whoever has this crystal equipped, or empty string.
static func equipped_by(crystal_id: String) -> String:
	for m: Dictionary in PartyState.members:
		if m.get("equipment", {}).get("crystal", "") == crystal_id:
			return m.get("character_id", "")
	return ""


## The description line for a crystal. [param level] > 0 adds the invocation's
## power at that level, which the detail view shows and the browse list does not.
static func invocation_text(static_data: Dictionary, level: int = 0) -> String:
	var invocation: Dictionary = static_data.get("invocation", {})
	var inv_name: String = invocation.get("name", "")
	if inv_name.is_empty():
		return static_data.get("description", "")
	var inv_desc: String = invocation.get("description", "")
	var uses: int = invocation.get("uses_per_rest", 0)
	var power: int = _invocation_power(invocation, level)
	if power > 0:
		return "%s: %s  Power: %d  [%d/rest]" % [inv_name, inv_desc, power, uses]
	return "%s: %s  [%d/rest]" % [inv_name, inv_desc, uses]


## XP bar state for a crystal, as {"label", "fill_ratio", "has_ratio"}. A maxed
## crystal reports a full bar; a degenerate threshold range reports has_ratio
## false, which leaves the bar as it was rather than dividing by zero.
static func xp_progress(runtime: Dictionary, static_data: Dictionary) -> Dictionary:
	var level: int = runtime.get("level", 1)
	var thresholds: Array = static_data.get("xp_thresholds", PartyCrystals.DEFAULT_XP_THRESHOLDS)
	if level >= PartyCrystals.MAX_LEVEL:
		return {"label": "XP: MAX", "fill_ratio": 1.0, "has_ratio": true}
	var current_threshold: int = thresholds[level - 1] if thresholds.size() >= level else 0
	var next_threshold: int = thresholds[level] if thresholds.size() > level else MAX_XP_FALLBACK
	var progress_xp: int = int(runtime.get("xp", 0)) - current_threshold
	var threshold_range: int = next_threshold - current_threshold
	return {
		"label": "XP: %d / %d" % [progress_xp, threshold_range],
		"fill_ratio":
		(
			clampf(float(progress_xp) / float(threshold_range), 0.0, 1.0)
			if threshold_range > 0
			else 0.0
		),
		"has_ratio": threshold_range > 0,
	}


## The level_bonuses entry a crystal grants at [param level], or {} if its data
## does not reach that far.
static func level_bonus(static_data: Dictionary, level: int) -> Dictionary:
	var level_bonuses: Array = static_data.get("level_bonuses", [])
	if level_bonuses.size() < level or level < 1:
		return {}
	var entry: Variant = level_bonuses[level - 1]
	return entry as Dictionary if entry is Dictionary else {}


## The bonus dict of the crystal [param character_id] wears right now, empty
## when they wear none or already wear [param crystal_id].
static func _worn_bonus(character_id: String, crystal_id: String) -> Dictionary:
	var worn: String = PartyState.get_member(character_id).get("equipment", {}).get("crystal", "")
	if worn.is_empty() or worn == crystal_id:
		return {}
	var runtime: Dictionary = PartyState.get_crystal_state(worn)
	return level_bonus(DataManager.get_ley_crystal(worn), runtime.get("level", 1))


static func _invocation_power(invocation: Dictionary, level: int) -> int:
	if level < 1:
		return 0
	var level_effects: Array = invocation.get("level_effects", [])
	if level_effects.size() < level:
		return 0
	var entry: Variant = level_effects[level - 1]
	return int((entry as Dictionary).get("power", 0)) if entry is Dictionary else 0


## "ATK +2" / "ATK -1" — a signed stat delta with its label.
static func _signed(label: String, value: int) -> String:
	return "%s +%d" % [label, value] if value >= 0 else "%s %d" % [label, value]
