class_name ProgressionHelpers
extends RefCounted
## Leveling: the two-phase XP curve, what a level-up does to a member's
## stats, and how a battle's XP is shared out across the party
## (progression.md § XP Distribution, § Two-Phase XP Curve).
##
## Extracted from inventory_helpers.gd (GAP-087).
const InventoryHelpers = preload("res://scripts/util/inventory_helpers.gd")


static func calculate_stats_at_level(
	base: Dictionary, growth: Dictionary, level: int
) -> Dictionary:
	var stats: Dictionary = {}
	for key: String in base:
		var b: float = float(base[key])
		var g: float = float(growth.get(key, 0))
		var raw: float = b + g * (level - 1)
		var cap: int = 255
		if key == "hp":
			cap = 14999
		elif key == "mp":
			cap = 1499
		stats[key] = mini(int(raw + 0.5), cap)
	return stats


## Compute leveled stats AND apply the character's permanent hidden stat spike
## (GAP-010) on top. Data-driven from char_data.hidden_spike. Used everywhere
## base_stats is (re)built — at join and on level-up — so the spike is never
## wiped by a recompute (progression.md
## § Narrative Milestone Stat Spikes: spikes are permanent).
static func leveled_stats_with_spike(char_data: Dictionary, level: int) -> Dictionary:
	var stats: Dictionary = calculate_stats_at_level(
		char_data.get("base_stats", {}), char_data.get("growth", {}), level
	)
	var spike: Dictionary = char_data.get("hidden_spike", {})
	for stat_key: String in spike:
		stats[stat_key] = int(stats.get(stat_key, 0)) + int(spike[stat_key])
	return stats


static func xp_to_next_level(level: int) -> int:
	if level >= 150:
		return 0
	if level <= 70:
		return int(24.0 * pow(float(level), 1.5))
	return int(10.0 * pow(float(level), 1.8))


## Add XP to a party member, processing any level-ups.
## Recalculates stats on level-up using character JSON data.
## Returns {leveled_up: bool, old_level: int, new_level: int}.
## Source: progression.md § XP Distribution, § Two-Phase XP Curve.
static func add_xp_to_member(member: Dictionary, amount: int) -> Dictionary:
	var level: int = member.get("level", 1)
	if amount <= 0:
		return {"leveled_up": false, "old_level": level, "new_level": level}
	var xp: int = member.get("current_xp", 0) + amount
	var old_level: int = level
	while level < 150:
		var needed: int = xp_to_next_level(level)
		if needed <= 0 or xp < needed:
			break
		xp -= needed
		level += 1
	if level >= 150:
		xp = 0
	member["current_xp"] = xp
	member["level"] = level
	member["xp_to_next"] = xp_to_next_level(level)
	if level > old_level:
		var char_data: Dictionary = DataManager.load_character(member.get("character_id", ""))
		if not char_data.is_empty():
			# Re-apply the permanent hidden spike so level-up recompute keeps it.
			member["base_stats"] = leveled_stats_with_spike(char_data, level)
			# Max HP/MP go through the shared recalculation, which layers the
			# permanent capsule gains and the equipment/crystal bonus back on
			# top of the fresh base stats (#274, GAP-020).
			InventoryHelpers.recalculate_max_hp_mp(member)
		member["current_hp"] = member["max_hp"]
		member["current_mp"] = member["max_mp"]
	return {"leveled_up": level > old_level, "old_level": old_level, "new_level": level}


## Distribute battle rewards across active and reserve party.
## Active alive: full XP. KO'd: 0 XP. Reserve: 50% XP.
## Returns {level_ups: Array, gold_gained: int, items_gained: Array}.
## Source: progression.md § XP Distribution Rules.
static func distribute_rewards(
	rewards: Dictionary,
	active_party: Array[Dictionary],
	reserve_party: Array[Dictionary],
) -> Dictionary:
	var level_ups: Array[Dictionary] = []
	var xp_amount: int = rewards.get("xp", 0)
	var drops: Array = rewards.get("drops", [])
	# Active party: full XP if alive, 0 if KO'd
	for member: Dictionary in active_party:
		if member.get("current_hp", 0) > 0:
			var result: Dictionary = add_xp_to_member(member, xp_amount)
			if result.get("leveled_up", false):
				var lu: Dictionary = {
					"character_id": member.get("character_id", ""),
					"old_level": result.get("old_level", 0),
					"new_level": result.get("new_level", 0),
				}
				level_ups.append(lu)
	# Reserve party: 50% XP (KO'd get 0)
	for member: Dictionary in reserve_party:
		if member.get("current_hp", 0) <= 0:
			continue
		var result: Dictionary = add_xp_to_member(member, xp_amount / 2)
		if result.get("leveled_up", false):
			var lu: Dictionary = {
				"character_id": member.get("character_id", ""),
				"old_level": result.get("old_level", 0),
				"new_level": result.get("new_level", 0),
			}
			level_ups.append(lu)
	return {
		"level_ups": level_ups,
		"gold_gained": rewards.get("gold", 0),
		"items_gained": drops,
	}


## Apply gold and item drops from rewards dict to party state via callbacks.
## Calls add_gold_fn and add_item_fn closures, returns distribute_rewards summary.
static func apply_battle_rewards(
	rewards: Dictionary,
	active: Array[Dictionary],
	reserve: Array[Dictionary],
	add_gold_fn: Callable,
	add_item_fn: Callable,
) -> Dictionary:
	var result: Dictionary = distribute_rewards(rewards, active, reserve)
	add_gold_fn.call(rewards.get("gold", 0))
	for drop: Variant in rewards.get("drops", []):
		if drop is Dictionary:
			var item_id: String = (drop as Dictionary).get("item_id", "")
			if not item_id.is_empty():
				add_item_fn.call(item_id, 1)
	return result
