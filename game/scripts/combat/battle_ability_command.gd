class_name BattleAbilityCommand
extends RefCounted
## The Ability command in battle: each character's unique command (GAP-002,
## abilities.md § 1. Character Unique Commands).
##
## Slice 158a of #158 builds the dispatcher and Cael's Rally. The other five
## commands — Edren's Bulwark, Lira's Forgewright, Sable's Tricks, Torren's
## Spiritcall and Maren's Arcanum — are slices 158b-f; until each lands,
## handles() answers false for that character and do_ability keeps the
## placeholder attack the manager used to make for every character.
##
## Mirrors BattleMagicCommand: the manager dispatches here, this module pays the
## cost and resolves the effect, and the Rally's in-force rules (duration, end
## conditions) live in battle_rally.gd behind BattleState.

## Rally magnitudes, from abilities.md § Cael — Rally and the matching
## `effect` text in game/data/abilities/cael.json. stat_pct is the +% to each
## stat; regen_pct is % of max HP restored at the start of each of the ally's
## turns; last_stand is Unbreakable's survive-at-1-HP; turns is the duration.
## test_battle_ability_command holds every entry to the data's effect text.
const RALLY_EFFECTS: Dictionary = {
	"hold_the_line": {"stat_pct": {"def": 15, "mdef": 15}, "turns": 3},
	"press_forward": {"stat_pct": {"atk": 20, "spd": 10}, "turns": 3},
	"second_wind": {"regen_pct": 5, "turns": 4},
	"unbreakable": {"last_stand": true, "turns": 3},
}

## How the design text names each stat, for the data cross-check.
const STAT_WORDS: Dictionary = {
	"atk": "Attack",
	"def": "Defense",
	"mdef": "Magic Defense",
	"spd": "Speed",
}

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Whether this character's unique command is built. Characters it is not built
## for keep the placeholder attack until their slice lands.
static func handles(character_id: String) -> bool:
	return character_id == "cael"


## Whether this particular ability can be issued yet. Vanguard Strike is a
## Cael ability but a "Command", not a Rally, and is not built in 158a.
static func is_built(ability: Dictionary) -> bool:
	return handles(str(ability.get("character", ""))) and RALLY_EFFECTS.has(ability.get("id", ""))


## Issue the ability in [param command]. Returns false when it never happened —
## not this character's, not built, or not enough MP — so the caller re-opens
## the menu.
func do_ability(actor_id: String, command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = state.get_member(slot)
	# Hook for #158 slices b-f: a character whose unique command is not built
	# yet keeps the placeholder it has always had, a basic attack on the target.
	if not handles(str(member.get("character_id", ""))):
		return BattlePlayerActions.new(_battle).do_attack(actor_id, command)
	var ability: Dictionary = command.get("ability", {})
	if ability.get("character", "") != member.get("character_id", ""):
		return false
	if not is_built(ability):
		return false
	if not state.spend_mp(slot, int(ability.get("cost_value", 0))):
		_battle.message.emit("Not enough MP!")
		return false
	# ui-design.md § 2.5: the message window carries the action's name.
	# battle-dialogue.md has no Rally line, so the name is all it says.
	_battle.message.emit(str(ability.get("name", "")))
	state.start_rally(slot, ability["id"], RALLY_EFFECTS[ability["id"]])
	return true
