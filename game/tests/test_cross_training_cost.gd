extends GutTest
## Cross-training's +50% MP cost (#433): a learner whose `learned_by` entry is
## marked cross_trained pays ceil(mp_cost x mp_penalty), and pays it everywhere
## MP is shown, checked or spent — the battle cast, the battle Magic list and
## the field Magic menu (magic.md § Derived Rules, "Cross-training is
## per-learner, not per-spell").
##
## The cross-trained pairs are read from the shipped spell data rather than
## listed here, so a seventh pair is covered the day it is added; a count
## precondition stops the loop from passing over nothing.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const MagicCommand = preload("res://scripts/combat/battle_magic_command.gd")
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")
const SubmenuItems = preload("res://scripts/ui/battle_submenu_items.gd")
const MENU_SCENE: PackedScene = preload("res://scenes/overlay/menu.tscn")

## magic.md's preamble and six "Who learns" lines: six cross-trained learners.
const CROSS_TRAINED_PAIRS: int = 6
const CASTER_SLOT: int = 0


## The seam a command module reaches on the battle manager (see
## test_battle_ability_command.gd's FakeBattle).
class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	var state: Node
	var enemies: Array[Node] = []

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return enemies


## An enemy immune to everything: a status spell lands on it without a roll,
## so what a cast costs is the only thing the test is left to watch.
class ImmuneEnemy:
	extends Node
	var is_alive: bool = true

	func is_immune_to_status(_status: String) -> bool:
		return true

	func get_stats() -> Dictionary:
		return {"mag": 1, "mdef": 255, "spd": 1}


var _battle: FakeBattle
var _messages: Array[String] = []
var _menu: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	_battle = FakeBattle.new()
	add_child_autofree(_battle)
	var enemy: ImmuneEnemy = ImmuneEnemy.new()
	add_child_autofree(enemy)
	_battle.enemies = [enemy] as Array[Node]
	_messages = []
	_battle.message.connect(func(t: String) -> void: _messages.append(t))


func after_each() -> void:
	_menu = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


## Every shipped {spell, learner, entry} whose learned_by entry is cross-trained.
func _cross_trained_pairs() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for tradition: String in SpellHelpers.TRADITIONS:
		for spell: Variant in DataManager.load_spells(tradition):
			for entry: Variant in (spell as Dictionary).get("learned_by", []):
				if (entry as Dictionary).get("cross_trained", false):
					out.append({"spell": spell, "learner": entry["character"], "entry": entry})
	return out


func _penalized(spell: Dictionary, entry: Dictionary) -> int:
	return ceili(int(spell["mp_cost"]) * float(entry["mp_penalty"]))


func _spell(spell_id: String) -> Dictionary:
	for tradition: String in SpellHelpers.TRADITIONS:
		for spell: Variant in DataManager.load_spells(tradition):
			if (spell as Dictionary).get("id", "") == spell_id:
				return spell
	fail_test("no shipped spell '%s'" % spell_id)
	return {}


## A battle with [param cid] alone in the caster slot, holding [param mp] MP.
func _battle_with(cid: String, mp: int) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	(
		state
		. add_member(
			CASTER_SLOT,
			{
				"character_id": cid,
				"base_stats":
				{
					"hp": 200,
					"mp": mp,
					"atk": 20,
					"def": 20,
					"mag": 20,
					"mdef": 20,
					"spd": 20,
					"lck": 8
				},
			}
		)
	)
	_battle.state = state
	return state


func _cast(spell: Dictionary) -> bool:
	var cmd: RefCounted = MagicCommand.new(_battle)
	var command: Dictionary = {"type": "magic", "spell": spell, "target": CASTER_SLOT}
	return cmd.do_magic("party_%d" % CASTER_SLOT, command)


## A cross-trained spell whose base cost is odd, so the +50% lands on a half.
func _odd_cost_spell() -> Dictionary:
	return {
		"id": "odd_fixture",
		"name": "Odd Fixture",
		"category": "healing",
		"target": "single_ally",
		"power": 1,
		"mp_cost": 7,
		"learned_by":
		[
			{"character": "torren", "level": 1},
			{"character": "edren", "level": 1, "cross_trained": true, "mp_penalty": 1.5},
		],
	}


# --- The rule itself ---


func test_the_shipped_data_holds_six_cross_trained_learners() -> void:
	assert_eq(_cross_trained_pairs().size(), CROSS_TRAINED_PAIRS, "magic.md names six")
	for pair: Dictionary in _cross_trained_pairs():
		assert_eq(float(pair["entry"]["mp_penalty"]), 1.5, "%s: +50%%" % pair["spell"]["id"])


func test_a_cross_trained_learner_is_charged_half_again_rounded_up() -> void:
	# 7 x 1.5 = 10.5: the half rounds up, so the learner pays 11, never 10.
	assert_eq(SpellHelpers.get_mp_cost(_odd_cost_spell(), "edren"), 11, "ceil(7 x 1.5)")


func test_a_native_learner_is_charged_the_base_cost() -> void:
	assert_eq(SpellHelpers.get_mp_cost(_odd_cost_spell(), "torren"), 7, "Torren learns it natively")


func test_a_cross_trained_spell_is_learned_at_its_story_event() -> void:
	# Edren's Kindle Breath comes from the Act III campfire, not from a level.
	var before: Array = SpellHelpers.get_known_spells("edren", 99).map(
		func(s: Dictionary) -> String: return s["id"]
	)
	EventFlags.set_flag("act_iii_campfire", true)
	var after: Array = SpellHelpers.get_known_spells("edren", 99).map(
		func(s: Dictionary) -> String: return s["id"]
	)
	assert_does_not_have(before, "kindle_breath", "no level teaches it")
	assert_has(after, "kindle_breath", "the campfire does")


# --- The battle cast ---


func test_each_cross_trained_learner_pays_the_penalty_when_casting_in_battle() -> void:
	for pair: Dictionary in _cross_trained_pairs():
		var spell: Dictionary = pair["spell"]
		var expected: int = _penalized(spell, pair["entry"])
		var state: Node = _battle_with(pair["learner"], 99)
		assert_true(_cast(spell), "%s casts %s" % [pair["learner"], spell["id"]])
		assert_eq(
			state.get_member(CASTER_SLOT)["current_mp"],
			99 - expected,
			(
				"%s pays %d for %s, not its base %d"
				% [pair["learner"], expected, spell["id"], spell["mp_cost"]]
			)
		)


func test_a_native_learner_pays_the_base_cost_in_battle() -> void:
	# Torren learns Kindle Breath natively at Lv 4; Edren's 9 is his alone.
	var state: Node = _battle_with("torren", 99)
	assert_true(_cast(_spell("kindle_breath")), "the cast resolves")
	assert_eq(state.get_member(CASTER_SLOT)["current_mp"], 93, "Torren pays the base 6")


func test_a_cross_trained_learner_who_holds_only_the_base_cost_cannot_cast() -> void:
	var state: Node = _battle_with("edren", 6)
	assert_false(_cast(_spell("kindle_breath")), "6 MP does not cover Edren's 9")
	assert_eq(state.get_member(CASTER_SLOT)["current_mp"], 6, "and nothing is spent")
	assert_has(_messages, "Not enough MP!", "the player is told why")


func test_an_odd_cost_rounds_up_in_battle() -> void:
	var state: Node = _battle_with("edren", 20)
	assert_true(_cast(_odd_cost_spell()), "the cast resolves")
	assert_eq(state.get_member(CASTER_SLOT)["current_mp"], 9, "20 - ceil(7 x 1.5) = 9")


# --- The battle Magic list ---


func test_the_battle_magic_list_shows_and_checks_the_penalized_cost() -> void:
	EventFlags.set_flag("act_iii_campfire", true)
	var data: Dictionary = {"character_id": "edren", "level": 1}
	var at_nine: Array[Dictionary] = SubmenuItems.magic(data, {"current_mp": 9})
	var at_eight: Array[Dictionary] = SubmenuItems.magic(data, {"current_mp": 8})
	var idx: int = -1
	for i: int in range(at_nine.size()):
		if at_nine[i]["command"]["spell"]["id"] == "kindle_breath":
			idx = i
	assert_gt(idx, -1, "precondition: Edren knows Kindle Breath after the campfire")
	if idx < 0:
		return
	assert_eq(at_nine[idx]["label"], "Kindle Breath  9 MP", "the list shows what Edren pays")
	assert_true(at_nine[idx]["enabled"], "9 MP affords it")
	assert_false(at_eight[idx]["enabled"], "8 MP does not, though the base cost is 6")


# --- The field Magic menu ---


## The field Magic screen opened on [param cid]. Every learner is at Lv 1, so
## the grid holds only a handful of spells and none scrolls out of view.
func _open_field_magic(cid: String) -> Node:
	if not PartyState.has_member(cid):
		PartyState.add_member(cid, 1)
	if _menu == null:
		_menu = MENU_SCENE.instantiate()
		add_child_autofree(_menu)
	var screen: Node = _menu.get_node("SubScreen/MagicScreen")
	screen.open(cid)
	return screen


func _field_label(screen: Node, spell_name: String) -> String:
	for row: Node in screen.find_children("Spell*", "Label", true, false):
		var text: String = (row as Label).text
		if text.begins_with(spell_name):
			return text
	return ""


func _press(action: String) -> InputEventAction:
	var ev: InputEventAction = InputEventAction.new()
	ev.action = action
	ev.pressed = true
	return ev


## Walk the grid cursor onto [param spell_id] the way a player does, then pick
## it and pick the first target.
func _field_cast(screen: Node, cid: String, spell_id: String) -> void:
	var idx: int = -1
	var known: Array = SpellHelpers.get_known_spells(cid, 1)
	for i: int in range(known.size()):
		if known[i].get("id", "") == spell_id:
			idx = i
	assert_gt(idx, -1, "precondition: %s knows %s" % [cid, spell_id])
	if idx < 0:
		return
	for _row: int in range(idx / 2):
		screen.handle_input(_press("ui_down"))
	if idx % 2 == 1:
		screen.handle_input(_press("ui_right"))
	screen.handle_input(_press("ui_accept"))
	screen.handle_input(_press("ui_accept"))


func test_each_cross_trained_learner_sees_the_penalty_in_the_field_menu() -> void:
	PartyState.initialize_new_game()
	for pair: Dictionary in _cross_trained_pairs():
		EventFlags.set_flag(String(pair["entry"]["event"]), true)
	for pair: Dictionary in _cross_trained_pairs():
		var spell: Dictionary = pair["spell"]
		var screen: Node = _open_field_magic(pair["learner"])
		var label: String = _field_label(screen, String(spell["name"]))
		assert_ne(label, "", "%s lists %s" % [pair["learner"], spell["name"]])
		assert_true(
			label.ends_with("MP%3d" % _penalized(spell, pair["entry"])),
			"%s's %s shows its penalized cost: '%s'" % [pair["learner"], spell["id"], label]
		)


func test_a_field_cast_spends_the_penalized_cost() -> void:
	# Breath of the Wilds: healing, so Edren can cast it from the field.
	PartyState.initialize_new_game()
	EventFlags.set_flag("act_iii_campfire", true)
	var edren: Dictionary = PartyState.get_member("edren")
	edren["current_mp"] = 20
	_field_cast(_open_field_magic("edren"), "edren", "breath_of_the_wilds")
	assert_eq(edren["current_mp"], 11, "Edren spends 9, not the base 6")


func test_the_field_menu_refuses_a_learner_holding_only_the_base_cost() -> void:
	PartyState.initialize_new_game()
	EventFlags.set_flag("act_iii_campfire", true)
	var edren: Dictionary = PartyState.get_member("edren")
	edren["current_mp"] = 6
	_field_cast(_open_field_magic("edren"), "edren", "breath_of_the_wilds")
	assert_eq(edren["current_mp"], 6, "6 MP does not cover Edren's 9, so nothing is spent")
