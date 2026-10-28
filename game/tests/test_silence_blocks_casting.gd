extends GutTest
## Silence blocks a party member's casting (#246 slice 8): magic.md § Status
## Effect Reference gives Silence as "Cannot cast spells". A Silenced member's
## Magic command is grayed out, a cast that reaches the battle anyway is
## refused before any MP is spent, and curing Silence gives Magic back.
##
## The casts go in through BattleMagicCommand.do_magic and the cure through
## BattleItemCommand.do_item — the two seams the battle manager dispatches to —
## against a real BattleState, so the member record the menu reads is the one
## the commands write.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const MagicCommand = preload("res://scripts/combat/battle_magic_command.gd")
const ItemCommand = preload("res://scripts/combat/battle_item_command.gd")
const CommandMenu = preload("res://scripts/ui/battle_command_menu.gd")

const CASTER: int = 0
## Magic is the second command (Attack, Magic, Ability, Item, Defend, Flee).
const MAGIC_INDEX: int = 1
const START_MP: int = 40


## The seam a command module reaches on the battle manager (see
## test_battle_ability_command.gd's FakeBattle).
class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	var state: Node

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return []


var _battle: FakeBattle
var _state: Node
var _messages: Array[String] = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	_state = BattleState.new()
	add_child_autofree(_state)
	(
		_state
		. add_member(
			CASTER,
			{
				"character_id": "torren",
				"base_stats":
				{
					"hp": 200,
					"mp": START_MP,
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
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_messages = []
	_battle.message.connect(func(t: String) -> void: _messages.append(t))


func after_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


## A 5 MP heal on the caster: an ally target, so no enemy is needed.
func _heal() -> Dictionary:
	return {
		"name": "Test Mend",
		"category": "healing",
		"target": "single_ally",
		"power": 5,
		"mp_cost": 5,
	}


func _cast() -> bool:
	var cmd: RefCounted = MagicCommand.new(_battle)
	return cmd.do_magic("party_%d" % CASTER, {"type": "magic", "spell": _heal(), "target": CASTER})


func _silence() -> void:
	_state.apply_status(CASTER, "silence", "turns", 4)


func _mp() -> int:
	return _state.get_member(CASTER)["current_mp"]


## The battle menu as BattleUI opens it for the caster: the live member record.
func _menu() -> Node:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	m.show_commands({"character_id": "torren", "level": 4}, false, _state.get_member(CASTER))
	return m


func _echo_drop() -> Dictionary:
	for item: Variant in DataManager.load_items("consumables"):
		if (item as Dictionary).get("id", "") == "echo_drop":
			return item
	fail_test("consumables.json has no echo_drop")
	return {}


func test_a_silenced_member_cannot_cast_and_spends_no_mp() -> void:
	_silence()
	assert_false(_cast(), "the cast is refused, so the menu re-opens")
	assert_eq(_mp(), START_MP, "no MP is spent")
	assert_eq(_messages.filter(func(t: String) -> bool: return t.contains("casts")), [], "no cast")


func test_an_unsilenced_member_casts_and_pays() -> void:
	assert_true(_cast(), "the cast resolves")
	assert_eq(_mp(), START_MP - 5, "and costs its MP")


func test_a_silenced_member_s_magic_command_is_grayed_out() -> void:
	_silence()
	assert_false(_menu()._commands[MAGIC_INDEX]["enabled"], "Magic grays out under Silence")


func test_an_echo_drop_gives_magic_back() -> void:
	# consumables.json: Echo Drop "Cures Silence on one ally".
	_silence()
	PartyState.add_item("echo_drop", 1)
	var item_cmd: RefCounted = ItemCommand.new(_battle)
	assert_true(item_cmd.do_item({"type": "item", "item": _echo_drop(), "target": CASTER}), "used")
	assert_true(_menu()._commands[MAGIC_INDEX]["enabled"], "Magic is selectable again")
	assert_true(_cast(), "and the cast resolves")
	assert_eq(_mp(), START_MP - 5, "paying its MP")
