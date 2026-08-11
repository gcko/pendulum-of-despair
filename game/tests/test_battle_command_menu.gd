extends GutTest
## Tests for battle command-menu submenu population (GAP-001: Magic submenu).

const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")
const SpellHelpers := preload("res://scripts/ui/spell_helpers.gd")

const CASTER_ID := "sable"
const CASTER_LEVEL := 5


func _make_menu() -> Node:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	return m


func _open_magic_submenu(m: Node) -> void:
	# Magic is index 1 in the command list (Attack, Magic, Ability, Item, Defend, Flee).
	m._cursor = 1
	m._confirm_command()


func test_magic_submenu_is_populated_from_known_spells() -> void:
	var known: Array = SpellHelpers.get_known_spells(CASTER_ID, CASTER_LEVEL)
	assert_gt(known.size(), 0, "precondition: caster knows at least one spell")
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, 99)
	_open_magic_submenu(m)
	assert_eq(m._submenu_items.size(), known.size(), "submenu lists every known spell")


func test_magic_submenu_items_carry_a_magic_command_with_spell() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, 99)
	_open_magic_submenu(m)
	assert_gt(m._submenu_items.size(), 0, "submenu has items")
	var item: Dictionary = m._submenu_items[0]
	var command: Dictionary = item.get("command", {})
	assert_eq(command.get("type", ""), "magic", "item routes a magic command")
	assert_true(command.has("spell"), "magic command carries the full spell dict")
	assert_true(item.has("target_type"), "item declares a target_type for targeting")


func test_unaffordable_spells_are_disabled_at_zero_mp() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, 0)
	_open_magic_submenu(m)
	var checked_any: bool = false
	for item: Dictionary in m._submenu_items:
		var cost: int = int(item.get("command", {}).get("spell", {}).get("mp_cost", 0))
		if cost > 0:
			checked_any = true
			assert_false(item.get("enabled", true), "spell costing %d MP disabled at 0 MP" % cost)
	assert_true(checked_any, "precondition: at least one spell has an MP cost")


func test_id_key_is_accepted_as_a_fallback() -> void:
	# Raw character JSON uses "id"; the menu should still populate from it.
	var m: Node = _make_menu()
	m.show_commands({"id": CASTER_ID, "level": CASTER_LEVEL}, false, 99)
	_open_magic_submenu(m)
	assert_gt(m._submenu_items.size(), 0, "id-keyed data still populates the submenu")


func test_empty_submenu_for_caster_with_no_spells() -> void:
	# A non-caster id yields no known spells; submenu stays empty (only cancel works).
	var m: Node = _make_menu()
	m.show_commands({"id": "nobody_xyz", "level": 1}, false, 99)
	_open_magic_submenu(m)
	assert_eq(m._submenu_items.size(), 0, "no spells -> empty submenu")


# --- Ally targeting is bounded by the live party size (#276) ---


func _press(action: String) -> InputEventAction:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


## Drive the menu to ally-target selection. A party_count of 0 means "the caller
## never pushed one", exercising the default.
func _open_single_ally_target(m: Node, party_count: int) -> void:
	if party_count > 0:
		m.set_party_count(party_count)
	var items: Array[Dictionary] = [
		{
			"label": "Mend",
			"command": {"type": "magic"},
			"target_type": "single_ally",
			"enabled": true,
		}
	]
	m.set_submenu_items(items)
	m._submenu_cursor = 0
	m._confirm_submenu()


func test_ally_targeting_uses_the_live_party_count() -> void:
	# Before #276 this was hardcoded to 4, letting the cursor walk onto empty
	# party slots that have no row to point at.
	var m: Node = _make_menu()
	_open_single_ally_target(m, 2)
	assert_eq(m._target_count, 2, "a two-member party offers exactly two ally targets")


func test_ally_target_cursor_wraps_within_the_live_party() -> void:
	var m: Node = _make_menu()
	_open_single_ally_target(m, 2)

	m._handle_target_input(_press("ui_down"))
	assert_eq(m._target_cursor, 1, "down moves to the second member")
	m._handle_target_input(_press("ui_down"))
	assert_eq(m._target_cursor, 0, "and wraps back rather than reaching an empty slot")


func test_ally_targeting_defaults_to_a_full_party() -> void:
	# A caller that never pushes a count keeps the pre-#276 four-slot behavior.
	var m: Node = _make_menu()
	_open_single_ally_target(m, 0)
	assert_eq(m._target_count, 4, "an unset party count still addresses four slots")


# --- Enemy and ally target ranges are independent (#276) ---


## Drive the menu to enemy target selection via the Attack command.
func _open_attack_target(m: Node) -> void:
	m._cursor = 0  # Attack is index 0 in the command list.
	m._confirm_command()


func test_enemy_targeting_uses_the_pushed_enemy_count() -> void:
	var m: Node = _make_menu()
	m.show_commands({"id": "cael", "level": 1}, false, 99)
	m.set_enemy_count(3)
	_open_attack_target(m)
	assert_eq(m._target_count, 3, "attack cycles the three enemies in the encounter")


func test_backing_out_of_an_ally_spell_leaves_every_enemy_reachable() -> void:
	# Both modes once shared one count field, so a two-member party's ally
	# targeting capped the enemy cursor at 2 and the third enemy became
	# unreachable for the rest of the turn (#276).
	var m: Node = _make_menu()
	m.show_commands({"id": "cael", "level": 1}, false, 99)
	m.set_enemy_count(3)
	_open_single_ally_target(m, 2)
	assert_eq(m._target_count, 2, "precondition: ally targeting is bounded by the party")

	m._handle_target_input(_press("ui_cancel"))  # TARGET -> SUBMENU
	m._handle_submenu_input(_press("ui_cancel"))  # SUBMENU -> COMMAND
	_open_attack_target(m)

	assert_eq(m._target_count, 3, "the enemy count is restored, not the party's leftover")
	m._handle_target_input(_press("ui_right"))
	m._handle_target_input(_press("ui_right"))
	assert_eq(m._target_cursor, 2, "the third enemy is still reachable")


func test_ally_targeting_is_not_widened_by_a_larger_enemy_count() -> void:
	var m: Node = _make_menu()
	m.show_commands({"id": "cael", "level": 1}, false, 99)
	m.set_enemy_count(6)
	_open_attack_target(m)
	m._handle_target_input(_press("ui_cancel"))  # TARGET -> COMMAND (attack)
	_open_single_ally_target(m, 2)
	assert_eq(m._target_count, 2, "ally targeting still stops at the occupied party slots")
