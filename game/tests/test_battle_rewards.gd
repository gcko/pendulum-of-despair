extends GutTest
## Tests for XP distribution and level-up logic.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")


func _make_member(id: String, level: int, xp: int, hp: int) -> Dictionary:
	return {
		"character_id": id,
		"level": level,
		"current_xp": xp,
		"xp_to_next": 24,
		"current_hp": hp,
		"max_hp": 95,
		"max_mp": 15,
		"atk": 18,
		"def": 16,
		"mag": 6,
		"mdef": 8,
		"spd": 10,
		"lck": 8,
	}


func test_add_xp_no_level_up() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	var result: Dictionary = Helpers.add_xp_to_member(member, 10)
	assert_false(result.get("leveled_up", true), "10 XP should not level up from 1")
	assert_eq(member.get("current_xp", 0), 10, "XP should be stored")
	assert_eq(member.get("level", 0), 1, "level should stay 1")


func test_add_xp_level_up() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	# XP to next level at 1 = floor(24 * 1^1.5) = 24
	var result: Dictionary = Helpers.add_xp_to_member(member, 30)
	assert_true(result.get("leveled_up", false), "30 XP should level up from 1")
	assert_eq(result.get("new_level", 0), 2, "should be level 2")
	assert_eq(member.get("level", 0), 2, "member dict should be updated")
	assert_eq(member.get("current_xp", -1), 6, "leftover XP should be 30 - 24 = 6")


func test_add_xp_multiple_levels() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	# Level 1->2: 24 XP, Level 2->3: floor(24 * 2^1.5) = floor(67.88) = 67
	# Total for 2 levels: 24 + 67 = 91
	var result: Dictionary = Helpers.add_xp_to_member(member, 100)
	assert_eq(result.get("new_level", 0), 3, "should reach level 3")
	assert_eq(member.get("current_xp", -1), 9, "leftover XP should be 100 - 91 = 9")


func test_add_xp_at_cap() -> void:
	var member: Dictionary = _make_member("edren", 150, 0, 95)
	var result: Dictionary = Helpers.add_xp_to_member(member, 9999)
	assert_false(result.get("leveled_up", true), "should not level past 150")
	assert_eq(member.get("level", 0), 150, "level should stay 150")


func test_add_xp_recalculates_stats() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	var old_max_hp: int = member.get("max_hp", 0)
	Helpers.add_xp_to_member(member, 30)  # Level 1->2
	assert_gt(member.get("max_hp", 0), old_max_hp, "max_hp should increase on level up")


func test_distribute_rewards_alive_get_full_xp() -> void:
	var active: Array[Dictionary] = [
		_make_member("edren", 1, 0, 50),
		_make_member("cael", 1, 0, 40),
	]
	var reserve: Array[Dictionary] = []
	var rewards: Dictionary = {"xp": 24, "gold": 100, "drops": []}
	var result: Dictionary = Helpers.distribute_rewards(rewards, active, reserve)
	# Both alive, both get full 24 XP => both level up
	assert_eq(result.get("level_ups", []).size(), 2, "both should level up")


func test_distribute_rewards_ko_gets_zero() -> void:
	var active: Array[Dictionary] = [
		_make_member("edren", 1, 0, 50),  # alive
		_make_member("cael", 1, 0, 0),  # KO'd
	]
	var reserve: Array[Dictionary] = []
	var rewards: Dictionary = {"xp": 24, "gold": 100, "drops": []}
	Helpers.distribute_rewards(rewards, active, reserve)
	assert_eq(active[0].get("level", 0), 2, "alive member should level up")
	assert_eq(active[1].get("level", 0), 1, "KO'd member should stay level 1")


func test_distribute_rewards_reserve_gets_half() -> void:
	var active: Array[Dictionary] = [_make_member("edren", 1, 0, 50)]
	var reserve: Array[Dictionary] = [_make_member("cael", 1, 0, 40)]
	# 24 XP: active gets 24 (levels up), reserve gets 12 (no level up)
	var rewards: Dictionary = {"xp": 24, "gold": 100, "drops": []}
	Helpers.distribute_rewards(rewards, active, reserve)
	assert_eq(active[0].get("level", 0), 2, "active should level up with 24 XP")
	assert_eq(reserve[0].get("level", 0), 1, "reserve should not level up with 12 XP")
	assert_eq(reserve[0].get("current_xp", 0), 12, "reserve should have 12 XP stored")
