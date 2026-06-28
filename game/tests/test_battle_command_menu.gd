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
