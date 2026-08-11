extends GutTest
## Tests for the vitals half of PartyState (scripts/util/party_vitals.gd):
## inn rest, field rest, and post-defeat revival.
##
## Split out of test_party_state.gd, plus the one autoload-level rest guard
## that had been filed under test_issue_fixes.gd (#374).

var _state: Node


func before_each() -> void:
	# The last test in this file drives the PartyState AUTOLOAD rather than a
	# private instance, so the singleton is reset around every test here.
	TestHelpers.reset_game_state()
	_state = preload("res://scripts/autoload/party_state.gd").new()
	add_child_autofree(_state)


func after_each() -> void:
	_state = null
	TestHelpers.reset_game_state()


# --- Rest at Inn ---


func test_rest_at_inn_heals_all_members() -> void:
	_state.initialize_new_game()
	for member: Dictionary in _state.members:
		member["current_hp"] = 1
		member["current_mp"] = 0
	_state.rest_at_inn()
	for member: Dictionary in _state.members:
		var cid: String = member.get("character_id", "")
		assert_eq(
			member.get("current_hp", 0),
			member.get("max_hp", 0),
			"%s HP should be fully restored" % cid
		)
		assert_eq(
			member.get("current_mp", 0),
			member.get("max_mp", 0),
			"%s MP should be fully restored" % cid
		)


func test_rest_at_inn_clears_status_effects() -> void:
	_state.initialize_new_game()
	for member: Dictionary in _state.members:
		member["status_effects"] = ["poison", "blind"]
	_state.rest_at_inn()
	for member: Dictionary in _state.members:
		var cid: String = member.get("character_id", "")
		var effects: Array = member.get("status_effects", [])
		assert_true(effects.is_empty(), "%s status_effects should be empty after inn rest" % cid)


func test_rest_at_inn_heals_reserve_members() -> void:
	_state.initialize_new_game()
	# Move Cael (index 1) to reserve
	_state.formation["active"] = [0] as Array[int]
	_state.formation["reserve"] = [1] as Array[int]
	# Damage the reserve member
	var cael: Dictionary = _state.get_member("cael")
	cael["current_hp"] = 1
	cael["current_mp"] = 0
	_state.rest_at_inn()
	assert_eq(
		cael.get("current_hp", 0),
		cael.get("max_hp", 0),
		"Reserve member HP should be fully restored"
	)
	assert_eq(
		cael.get("current_mp", 0),
		cael.get("max_mp", 0),
		"Reserve member MP should be fully restored"
	)


# --- revive_active_at_fraction ---


func test_revive_active_at_fraction() -> void:
	_state.initialize_new_game()
	# KO both members
	for m: Dictionary in _state.members:
		m["current_hp"] = 0
	_state.revive_active_at_fraction(0.25)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		var expected: int = maxi(1, floori(float(m.get("max_hp", 1)) * 0.25))
		assert_eq(
			m.get("current_hp", 0),
			expected,
			"%s should be revived at 25%% max HP" % cid,
		)


func test_revive_active_at_fraction_skips_alive() -> void:
	_state.initialize_new_game()
	var edren: Dictionary = _state.get_member("edren")
	var original_hp: int = edren.get("current_hp", 0)
	# edren is alive, cael is KO'd
	var cael: Dictionary = _state.get_member("cael")
	cael["current_hp"] = 0
	_state.revive_active_at_fraction(0.25)
	assert_eq(
		edren.get("current_hp", 0),
		original_hp,
		"alive member HP unchanged",
	)
	assert_gt(cael.get("current_hp", 0), 0, "KO'd member revived")


func test_revive_active_at_fraction_skips_reserve() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	_state.move_member_to_reserve("torren")
	var torren: Dictionary = _state.get_member("torren")
	torren["current_hp"] = 0
	_state.revive_active_at_fraction(0.25)
	assert_eq(
		torren.get("current_hp", 0),
		0,
		"reserve member should not be revived",
	)


# --- rest_party ---


func test_rest_party() -> void:
	_state.initialize_new_game()
	for m: Dictionary in _state.members:
		m["current_hp"] = 1
		m["current_mp"] = 0
	_state.rest_party(0.5, false)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		assert_gt(
			m.get("current_hp", 0),
			1,
			"%s HP should increase" % cid,
		)


func test_rest_party_clears_status() -> void:
	_state.initialize_new_game()
	for m: Dictionary in _state.members:
		m["status_effects"] = ["poison"]
	_state.rest_party(0.25, true)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		assert_true(
			m.get("status_effects", []).is_empty(),
			"%s status should be cleared" % cid,
		)


func test_rest_party_no_clear_status() -> void:
	_state.initialize_new_game()
	for m: Dictionary in _state.members:
		m["status_effects"] = ["poison"]
	_state.rest_party(0.25, false)
	for m: Dictionary in _state.members:
		assert_false(
			m.get("status_effects", []).is_empty(),
			"status should remain when clears_status=false",
		)


func test_rest_party_does_not_exceed_max() -> void:
	_state.initialize_new_game()
	# Members start at full HP/MP
	_state.rest_party(1.0, false)
	for m: Dictionary in _state.members:
		var cid: String = m.get("character_id", "")
		assert_eq(
			m.get("current_hp", 0),
			m.get("max_hp", 0),
			"%s HP should not exceed max" % cid,
		)
		assert_eq(
			m.get("current_mp", 0),
			m.get("max_mp", 0),
			"%s MP should not exceed max" % cid,
		)


# --- rest_party through the autoload (was test_issue_fixes.gd) ---


func test_party_state_rest_party_uses_api() -> void:
	PartyState.initialize_new_game()
	PartyState.members[0]["current_hp"] = 10
	PartyState.members[0]["current_mp"] = 0
	PartyState.rest_party(0.5, true)
	assert_gt(
		PartyState.members[0]["current_hp"],
		10,
		"rest_party should restore HP",
	)
