extends GutTest
## The battle Magic menu's side of #503: an ally spell with no battle effect
## built yet is listed grayed, as an unaffordable one is, so it cannot waste a
## turn; a revival spell (target "fainted_ally") targets the party, and may be
## turned on the enemy line like a heal (ui-design.md § 2.6), where an Undead
## dies to it. Also Smokeveil, which ends a non-boss battle (magic.md § 77).

const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")
const BattleMagicCommand := preload("res://scripts/combat/battle_magic_command.gd")
const BattleState := preload("res://scripts/combat/battle_state.gd")


## The slice of the battle Smokeveil reaches: the party, the boss flag, and
## where an escape goes.
class EscapeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal flee_result(success: bool)
	var state: Node
	var boss: bool = false
	var exits: Array[String] = []

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return []

	func is_boss_battle() -> bool:
		return boss

	func exit_battle(result: String) -> void:
		exits.append(result)


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _make_menu() -> Node:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	return m


func _press(action: String) -> InputEventAction:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


## Open the Magic submenu of Maren at [param level] with MP to spare, and
## return its entries by spell id.
func _maren_spells(level: int, member: Dictionary = {"current_mp": 999}) -> Dictionary:
	var m: Node = _make_menu()
	m.show_commands({"character_id": "maren", "level": level}, false, member)
	m._cursor = 1  # Magic (Attack, Magic, Ability, Item, Defend, Flee)
	m._confirm_command()
	var by_id: Dictionary = {}
	for item: Dictionary in m._submenu_items:
		by_id[item.get("command", {}).get("spell", {}).get("id", "")] = item
	return by_id


func test_ally_spells_with_no_battle_effect_are_grayed_in_the_magic_menu() -> void:
	var spells: Dictionary = _maren_spells(40)
	for id: String in ["leymirror", "last_breath", "drift", "waymark", "linewalk"]:
		assert_true(spells.has(id), "precondition: Maren knows %s" % id)
		assert_false(spells.get(id, {}).get("enabled", true), "%s is grayed" % id)


func test_built_ally_spells_stay_selectable_in_the_magic_menu() -> void:
	var spells: Dictionary = _maren_spells(40)
	for id: String in [
		"ironhide", "attunement", "kindle_breath", "purge", "leydraught", "spirit_recall"
	]:
		assert_true(spells.has(id), "precondition: Maren knows %s" % id)
		assert_true(spells.get(id, {}).get("enabled", false), "%s can be cast" % id)


func test_leydraught_is_grayed_when_the_caster_cannot_pay_its_hp() -> void:
	# 15% of 1000 max HP is 150: the cast is refused at 150 HP or less
	# (2026-10-30 ruling), so the menu does not offer it there.
	var short: Dictionary = {"current_mp": 999, "max_hp": 1000, "current_hp": 150}
	assert_false(_maren_spells(40, short)["leydraught"].get("enabled", true), "grayed at 150 HP")
	var enough: Dictionary = {"current_mp": 999, "max_hp": 1000, "current_hp": 151}
	assert_true(_maren_spells(40, enough)["leydraught"].get("enabled", false), "offered at 151")


## Drive the menu to the target cursor for a fainted-ally spell.
func _open_revive_target(m: Node) -> void:
	var items: Array[Dictionary] = [
		{
			"label": "Spirit Recall",
			"command": {"type": "magic", "spell": {"id": "spirit_recall"}},
			"target_type": "fainted_ally",
			"enabled": true,
		}
	]
	m.set_submenu_items(items)
	m._submenu_cursor = 0
	m._confirm_submenu()


func _confirmed(m: Node) -> Dictionary:
	watch_signals(m)
	m._handle_target_input(_press("ui_accept"))
	if get_signal_emit_count(m, "command_selected") == 0:
		return {}
	return get_signal_parameters(m, "command_selected")[0]


func test_a_revival_spell_opens_its_cursor_on_the_party() -> void:
	var m: Node = _make_menu()
	watch_signals(m)
	_open_revive_target(m)
	assert_signal_emitted_with_parameters(m, "target_changed", [0, false])
	var command: Dictionary = _confirmed(m)
	assert_eq(command.get("target", -1), 0, "a party slot is chosen")
	assert_false(command.get("target_enemy", true), "on the party side")


func test_a_revival_spell_can_be_turned_on_the_enemy_line() -> void:
	var m: Node = _make_menu()
	_open_revive_target(m)
	m._handle_target_input(_press("ui_right"))
	assert_true(_confirmed(m).get("target_enemy", false), "the revive goes to an enemy")


# ── Smokeveil ────────────────────────────────────────────────────────────


func _escape_battle(boss: bool) -> EscapeBattle:
	PartyState.initialize_new_game()
	var battle: EscapeBattle = EscapeBattle.new()
	battle.boss = boss
	battle.state = BattleState.new()
	battle.add_child(battle.state)
	add_child_autofree(battle)
	(
		battle
		. state
		. add_member(
			0,
			{
				"character_id": "edren",
				"name": "Edren",
				"base_stats": {"hp": 100, "mp": 20},
				"max_hp": 100,
				"max_mp": 20,
			}
		)
	)
	return battle


func _smokeveil() -> Dictionary:
	for entry: Variant in DataManager.load_spells("streetwise"):
		if String((entry as Dictionary).get("id", "")) == "smokeveil":
			return (entry as Dictionary).duplicate(true)
	fail_test("smokeveil is missing from streetwise.json")
	return {}


func test_smokeveil_ends_a_normal_battle_as_an_escape() -> void:
	var battle: EscapeBattle = _escape_battle(false)
	var said: Array[String] = []
	battle.message.connect(func(text: String) -> void: said.append(text))
	watch_signals(battle)
	var cast: bool = BattleMagicCommand.new(battle).do_magic(
		"party_0", {"type": "magic", "spell": _smokeveil(), "target": 0}
	)
	assert_true(cast, "the cast resolves")
	assert_eq(battle.exits, ["flee"] as Array[String], "the party escapes, with no rewards")
	assert_eq(int(battle.state.get_member(0)["current_mp"]), 16, "for Smokeveil's 4 MP")
	# battle-dialogue.md § Escape, as a successful Flee announces it.
	assert_has(said, "Escaped!", str(said))
	assert_signal_emitted_with_parameters(battle, "flee_result", [true])


func test_smokeveil_is_refused_in_a_boss_fight_before_mp() -> void:
	var battle: EscapeBattle = _escape_battle(true)
	var said: Array[String] = []
	battle.message.connect(func(text: String) -> void: said.append(text))
	var cast: bool = BattleMagicCommand.new(battle).do_magic(
		"party_0", {"type": "magic", "spell": _smokeveil(), "target": 0}
	)
	assert_false(cast, "nothing is cast")
	assert_eq(battle.exits, [] as Array[String], "the battle goes on")
	assert_eq(int(battle.state.get_member(0)["current_mp"]), 20, "no MP spent")
	assert_has(said, "Can't use that here!", str(said))
