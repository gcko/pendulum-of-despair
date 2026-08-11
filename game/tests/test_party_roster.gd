extends GutTest
## Tests for the roster half of PartyState (scripts/util/party_roster.gd):
## joining characters, membership lookup, and moving members between the
## active party and the reserve.
##
## Split out of test_party_state.gd (#374).

var _state: Node


func before_each() -> void:
	_state = preload("res://scripts/autoload/party_state.gd").new()
	add_child_autofree(_state)


func after_each() -> void:
	_state = null


# --- add_member / has_member ---


func test_add_member_adds_to_party() -> void:
	_state.initialize_new_game()
	assert_eq(_state.members.size(), 2, "should start with 2 members")
	_state.add_member("torren", 3)
	assert_eq(_state.members.size(), 3, "should have 3 members after add")
	var m: Dictionary = _state.get_member("torren")
	assert_eq(m.get("character_id", ""), "torren", "torren should be in party")
	assert_eq(m.get("level", 0), 3, "torren should be at level 3")


func test_add_member_prevents_duplicates() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 3)
	_state.add_member("torren", 5)
	var count: int = 0
	for m: Dictionary in _state.members:
		if m.get("character_id", "") == "torren":
			count += 1
	assert_eq(count, 1, "should not add duplicate members")


func test_add_member_sets_formation() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	var active: Array = _state.formation.get("active", [])
	assert_true(active.has(2), "torren (idx 2) should be in active party")
	_state.add_member("maren", 1)
	active = _state.formation.get("active", [])
	assert_true(active.has(3), "maren (idx 3) should be in active (4th slot)")


func test_add_member_overflow_to_reserve() -> void:
	_state.initialize_new_game()
	_state.add_member("lira", 1)
	_state.add_member("sable", 1)
	_state.add_member("torren", 1)
	var reserve: Array = _state.formation.get("reserve", [])
	assert_true(reserve.has(4), "torren (idx 4) should go to reserve when active full")


func test_has_member() -> void:
	_state.initialize_new_game()
	assert_true(_state.has_member("edren"), "edren should exist")
	assert_false(_state.has_member("torren"), "torren should not exist yet")
	_state.add_member("torren", 1)
	assert_true(_state.has_member("torren"), "torren should exist after add")


func test_add_member_empty_id_ignored() -> void:
	_state.initialize_new_game()
	_state.add_member("", 1)
	assert_eq(_state.members.size(), 2, "empty id should not add a member")


func test_add_member_negative_level_clamped() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", -5)
	var m: Dictionary = _state.get_member("torren")
	assert_eq(m.get("level", 0), 1, "negative level should be clamped to 1")


# --- find_member_index ---


func test_find_member_index() -> void:
	_state.initialize_new_game()
	assert_eq(_state.find_member_index("edren"), 0, "edren is index 0")
	assert_eq(_state.find_member_index("cael"), 1, "cael is index 1")
	assert_eq(
		_state.find_member_index("nonexistent"),
		-1,
		"missing character returns -1",
	)


# --- move_member_to_reserve ---


func test_move_member_to_reserve() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	var active_before: Array = _state.formation["active"].duplicate()
	assert_true(active_before.has(2), "torren idx in active before move")
	var ok: bool = _state.move_member_to_reserve("torren")
	assert_true(ok, "move should succeed")
	assert_false(
		_state.formation["active"].has(2),
		"torren idx removed from active",
	)
	assert_true(
		_state.formation["reserve"].has(2),
		"torren idx added to reserve",
	)


func test_move_member_to_reserve_not_in_active() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	_state.move_member_to_reserve("torren")
	# Second call should return false — already in reserve
	var ok: bool = _state.move_member_to_reserve("torren")
	assert_false(ok, "cannot move if not in active")


func test_move_member_to_reserve_unknown_character() -> void:
	_state.initialize_new_game()
	var ok: bool = _state.move_member_to_reserve("nobody")
	assert_false(ok, "unknown character returns false")


# --- move_member_to_active ---


func test_move_member_to_active() -> void:
	_state.initialize_new_game()
	_state.add_member("torren", 1)
	_state.move_member_to_reserve("torren")
	assert_true(
		_state.formation["reserve"].has(2),
		"torren in reserve before restore",
	)
	var ok: bool = _state.move_member_to_active("torren")
	assert_true(ok, "move should succeed")
	assert_true(
		_state.formation["active"].has(2),
		"torren idx back in active",
	)
	assert_false(
		_state.formation["reserve"].has(2),
		"torren idx removed from reserve",
	)


func test_move_member_to_active_party_full() -> void:
	_state.initialize_new_game()
	_state.add_member("lira", 1)
	_state.add_member("sable", 1)
	_state.add_member("torren", 1)
	# torren overflowed to reserve (active already has 4)
	assert_true(
		_state.formation["reserve"].has(4),
		"torren in reserve",
	)
	var ok: bool = _state.move_member_to_active("torren")
	assert_false(ok, "cannot move to active when full")


func test_move_member_to_active_not_in_reserve() -> void:
	_state.initialize_new_game()
	# edren is in active, not reserve
	var ok: bool = _state.move_member_to_active("edren")
	assert_false(ok, "cannot move if not in reserve")
