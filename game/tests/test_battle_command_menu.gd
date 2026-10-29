extends GutTest
## Tests for battle command-menu submenu population (GAP-001: Magic submenu).

const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")
const SpellHelpers := preload("res://scripts/ui/spell_helpers.gd")
const SubmenuItems := preload("res://scripts/ui/battle_submenu_items.gd")

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
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, {"current_mp": 99})
	_open_magic_submenu(m)
	assert_eq(m._submenu_items.size(), known.size(), "submenu lists every known spell")


func test_magic_submenu_items_carry_a_magic_command_with_spell() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, {"current_mp": 99})
	_open_magic_submenu(m)
	assert_gt(m._submenu_items.size(), 0, "submenu has items")
	var item: Dictionary = m._submenu_items[0]
	var command: Dictionary = item.get("command", {})
	assert_eq(command.get("type", ""), "magic", "item routes a magic command")
	assert_true(command.has("spell"), "magic command carries the full spell dict")
	assert_true(item.has("target_type"), "item declares a target_type for targeting")


func test_unaffordable_spells_are_disabled_at_zero_mp() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, {"current_mp": 0})
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
	m.show_commands({"id": CASTER_ID, "level": CASTER_LEVEL}, false, {"current_mp": 99})
	_open_magic_submenu(m)
	assert_gt(m._submenu_items.size(), 0, "id-keyed data still populates the submenu")


func test_empty_submenu_for_caster_with_no_spells() -> void:
	# A non-caster id yields no known spells; submenu stays empty (only cancel works).
	var m: Node = _make_menu()
	m.show_commands({"id": "nobody_xyz", "level": 1}, false, {"current_mp": 99})
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
	m.show_commands({"id": "cael", "level": 1}, false, {"current_mp": 99})
	m.set_enemy_count(3)
	_open_attack_target(m)
	assert_eq(m._target_count, 3, "attack cycles the three enemies in the encounter")


func test_backing_out_of_an_ally_spell_leaves_every_enemy_reachable() -> void:
	# Both modes once shared one count field, so a two-member party's ally
	# targeting capped the enemy cursor at 2 and the third enemy became
	# unreachable for the rest of the turn (#276).
	var m: Node = _make_menu()
	m.show_commands({"id": "cael", "level": 1}, false, {"current_mp": 99})
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
	m.show_commands({"id": "cael", "level": 1}, false, {"current_mp": 99})
	m.set_enemy_count(6)
	_open_attack_target(m)
	m._handle_target_input(_press("ui_cancel"))  # TARGET -> COMMAND (attack)
	_open_single_ally_target(m, 2)
	assert_eq(m._target_count, 2, "ally targeting still stops at the occupied party slots")


# --- Ability submenu (GAP-002, #158 slice a) ---


## Ability is index 2 in the command list (Attack, Magic, Ability, Item, ...).
func _open_ability_submenu(m: Node) -> void:
	m._cursor = 2
	m._confirm_command()


## A living, status-free BattleState record with [param mp] MP.
func _member(mp: int) -> Dictionary:
	return {"current_mp": mp, "is_alive": true, "active_statuses": []}


func _labels(m: Node) -> Array[String]:
	var out: Array[String] = []
	for item: Dictionary in m._submenu_items:
		out.append(String(item.get("label", "")))
	return out


func test_the_third_command_names_the_live_character_s_unique_command() -> void:
	# Battle hands the menu PartyState's member shape, keyed "character_id"
	# (ui-design.md § 2.4: Cael -> Rally).
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 1}, false, _member(25))
	assert_eq(m._commands[2].get("label", ""), "Rally", "Cael's third command reads Rally")


func test_ability_submenu_lists_cael_s_known_abilities_with_their_cost() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 5}, false, _member(25))
	_open_ability_submenu(m)
	assert_eq(
		_labels(m),
		["Hold the Line  6 MP", "Press Forward  8 MP"] as Array[String],
		"level 5 knows Hold the Line and Press Forward, not the level 9+ Rallies"
	)


func test_ability_submenu_greys_out_rallies_cael_cannot_afford() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 5}, false, _member(7))
	_open_ability_submenu(m)
	assert_true(m._submenu_items[0].get("enabled", false), "6 MP Hold the Line is affordable at 7")
	assert_false(m._submenu_items[1].get("enabled", true), "8 MP Press Forward is not")


func test_choosing_a_rally_submits_it_with_no_target_step() -> void:
	# Every Rally targets all allies, so it goes straight to the battle.
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 1}, false, _member(25))
	_open_ability_submenu(m)
	watch_signals(m)
	m._handle_submenu_input(_press("ui_accept"))
	assert_signal_emitted(m, "command_selected")
	var cmd: Dictionary = get_signal_parameters(m, "command_selected")[0]
	assert_eq(cmd.get("type", ""), "ability", "routes an ability command")
	assert_eq(cmd.get("ability", {}).get("id", ""), "hold_the_line", "carrying the Rally chosen")


func test_an_unbuilt_cael_ability_is_listed_but_cannot_be_chosen() -> void:
	# Vanguard Strike (Lv 14) is a Command, not a Rally; not built in 158a.
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 14}, false, _member(99))
	_open_ability_submenu(m)
	var labels: Array[String] = _labels(m)
	var idx: int = labels.find("Vanguard Strike  10 MP")
	assert_gt(idx, -1, "Vanguard Strike is listed")
	assert_false(m._submenu_items[idx].get("enabled", true), "but not selectable yet")


func test_a_character_whose_command_is_unbuilt_can_choose_nothing() -> void:
	# Arcanum is slice 158f. Its abilities show, none can be chosen, and the
	# previous submenu's entries (here Magic's) never leak into the list.
	var m: Node = _make_menu()
	m.show_commands({"character_id": "maren", "level": 10}, false, _member(99))
	_open_magic_submenu(m)
	m._handle_submenu_input(_press("ui_cancel"))
	_open_ability_submenu(m)
	assert_gt(m._submenu_items.size(), 0, "Maren's known Arcanum abilities are listed")
	for item: Dictionary in m._submenu_items:
		assert_eq(item.get("command", {}).get("type", ""), "ability", "no leftover Magic entry")
		assert_false(item.get("enabled", true), "%s is not selectable yet" % item.get("label"))


func test_passives_are_not_on_the_ability_list() -> void:
	# Unbreakable Thread is Sable's passive (cost_type "none"); it is never issued.
	EventFlags.set_flag("trial_sable_complete", true)
	var m: Node = _make_menu()
	m.show_commands({"character_id": "sable", "level": 30}, false, _member(99))
	_open_ability_submenu(m)
	assert_gt(m._submenu_items.size(), 0, "Sable's Tricks are listed")
	assert_false(_labels(m).has("Unbreakable Thread  Passive"), "the passive is not")
	EventFlags.clear_all()


func test_a_self_targeted_entry_submits_with_no_target_step() -> void:
	var m: Node = _make_menu()
	var items: Array[Dictionary] = [
		{"label": "Stance", "command": {"type": "ability"}, "target_type": "self", "enabled": true}
	]
	m.set_submenu_items(items)
	m._state = m.MenuState.SUBMENU
	watch_signals(m)
	m._handle_submenu_input(_press("ui_accept"))
	assert_signal_emitted(m, "command_selected")


# --- Rally is unavailable while Cael is Silenced (ui-design.md § 2.7) ---


func _silenced_cael() -> Dictionary:
	return {"current_mp": 99, "is_alive": true, "active_statuses": [{"name": "silence"}]}


func test_a_silenced_cael_s_rally_command_is_grayed_out() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 5}, false, _silenced_cael())
	assert_false(m._commands[2].get("enabled", true), "Rally grays out under Silence")
	watch_signals(m)
	_open_ability_submenu(m)
	assert_signal_not_emitted(m, "submenu_opened", "a grayed command does not open")


func test_a_silenced_cael_s_rallies_are_grayed_in_the_submenu() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 5}, false, _silenced_cael())
	m.set_submenu_items(
		SubmenuItems.abilities({"character_id": "cael", "level": 5}, _silenced_cael())
	)
	for item: Dictionary in m._submenu_items:
		assert_false(item.get("enabled", true), "%s unavailable under Silence" % item.get("label"))


func test_an_unsilenced_cael_s_rally_command_is_open() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": "cael", "level": 5}, false, _member(0))
	assert_true(m._commands[2].get("enabled", false), "no MP still opens the list, as Magic does")


# --- Magic is unavailable while the member is Silenced (#246 slice 8) ---


func _silenced(mp: int) -> Dictionary:
	return {"current_mp": mp, "is_alive": true, "active_statuses": [{"name": "silence"}]}


func test_a_silenced_member_s_magic_command_is_grayed_out() -> void:
	# Silence: "Cannot cast spells" (magic.md § Status Effect Reference).
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, _silenced(99))
	assert_false(m._commands[1].get("enabled", true), "Magic grays out under Silence")
	watch_signals(m)
	_open_magic_submenu(m)
	assert_signal_not_emitted(m, "submenu_opened", "a grayed command does not open")


func test_a_silenced_member_s_spells_are_grayed_in_the_submenu() -> void:
	var data: Dictionary = {"character_id": CASTER_ID, "level": CASTER_LEVEL}
	var spells: Array[Dictionary] = SubmenuItems.magic(data, _silenced(99))
	assert_gt(spells.size(), 0, "precondition: the caster knows spells")
	for item: Dictionary in spells:
		assert_false(item.get("enabled", true), "%s unavailable under Silence" % item.get("label"))


func test_an_unsilenced_member_s_magic_command_is_open() -> void:
	var m: Node = _make_menu()
	m.show_commands({"character_id": CASTER_ID, "level": CASTER_LEVEL}, false, _member(0))
	assert_true(m._commands[1].get("enabled", false), "no MP still opens the list")


# --- A support action can be turned on the enemy line (#178a) ---
# ui-design.md § 2.6: left/right cycles through enemies, up/down through party
# members. Read as an axis per side: while a single-ally action is targeting the
# party, left/right moves the cursor onto the enemy line, and up/down brings it
# back. A heal spell or a revival item can then reach an enemy.


## The command the menu submits when the player confirms, or {} if none.
func _confirmed(m: Node) -> Dictionary:
	watch_signals(m)
	m._handle_target_input(_press("ui_accept"))
	if get_signal_emit_count(m, "command_selected") == 0:
		return {}
	return get_signal_parameters(m, "command_selected")[0]


func test_left_or_right_on_the_party_moves_a_heal_onto_the_enemy_line() -> void:
	for action: String in ["ui_left", "ui_right"]:
		var m: Node = _make_menu()
		m.set_enemy_count(2)
		_open_single_ally_target(m, 2)
		watch_signals(m)

		m._handle_target_input(_press(action))

		assert_signal_emitted_with_parameters(m, "target_changed", [0, true])
		var cmd: Dictionary = _confirmed(m)
		assert_true(cmd.get("target_enemy", false), "%s aims the heal at an enemy" % action)
		assert_eq(cmd.get("target", -1), 0, "at the first enemy")


func test_once_on_the_enemy_line_left_and_right_cycle_the_enemies() -> void:
	var m: Node = _make_menu()
	m.set_enemy_count(3)
	_open_single_ally_target(m, 2)
	m._handle_target_input(_press("ui_right"))  # onto the enemy line

	m._handle_target_input(_press("ui_right"))
	m._handle_target_input(_press("ui_right"))

	var cmd: Dictionary = _confirmed(m)
	assert_true(cmd.get("target_enemy", false), "still on the enemy line")
	assert_eq(cmd.get("target", -1), 2, "the third enemy is reachable, not capped at the party")


func test_up_or_down_on_the_enemy_line_brings_a_heal_back_to_the_party() -> void:
	var m: Node = _make_menu()
	m.set_enemy_count(3)
	_open_single_ally_target(m, 2)
	m._handle_target_input(_press("ui_right"))
	watch_signals(m)

	m._handle_target_input(_press("ui_down"))

	assert_signal_emitted_with_parameters(m, "target_changed", [0, false])
	var cmd: Dictionary = _confirmed(m)
	assert_false(cmd.get("target_enemy", true), "the heal goes to a party member again")
	assert_eq(cmd.get("target", -1), 0, "the first member")


func test_a_heal_confirmed_on_the_party_says_so() -> void:
	# The command dict is reused across turns, so an earlier enemy choice must
	# not linger on it.
	var m: Node = _make_menu()
	_open_single_ally_target(m, 2)
	m._handle_target_input(_press("ui_down"))
	var cmd: Dictionary = _confirmed(m)
	assert_false(cmd.get("target_enemy", true), "an ally heal is marked as one")
	assert_eq(cmd.get("target", -1), 1, "on the member chosen")


func test_an_attack_cannot_be_turned_on_the_party() -> void:
	var m: Node = _make_menu()
	m.show_commands({"id": "cael", "level": 1}, false, {"current_mp": 99})
	m.set_enemy_count(2)
	_open_attack_target(m)
	watch_signals(m)

	m._handle_target_input(_press("ui_down"))

	assert_signal_not_emitted(m, "target_changed", "up/down does nothing on an attack")
	var cmd: Dictionary = _confirmed(m)
	assert_eq(cmd.get("type", ""), "attack", "the attack is submitted as before")
	assert_false(cmd.has("target_enemy"), "with no side to choose, nothing marks one")
