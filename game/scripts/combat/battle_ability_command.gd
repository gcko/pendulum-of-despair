class_name BattleAbilityCommand
extends RefCounted
## The Ability command in battle: each character's unique command (GAP-002,
## abilities.md § 1. Character Unique Commands).
##
## A dispatcher. do_ability checks the ability can be issued, pays its cost
## (keyed on the data's cost_type), then hands it to the resolver for its
## command (the data's `command` field). Slice 158a of #158 builds Cael's
## Rally. Bulwark, Forgewright, Tricks, Spiritcall and Arcanum are slices
## 158b-f: each adds a resolver here, and pay() learns its cost type. Until
## then their abilities are not built, so the battle menu lists them disabled
## and do_ability refuses them.
##
## The Rally's in-force rules (duration, end conditions) live in BattleRally,
## reached through BattleState's ability hooks.

## Rally magnitudes, from abilities.md § Cael — Rally and the matching
## `effect` text in game/data/abilities/cael.json. stat_pct is the +% to each
## stat; regen_pct is % of max HP restored at the start of each of the ally's
## turns; last_stand is Unbreakable's survive-at-1-HP; turns is the duration.
## test_battle_ability_command holds every entry to the data's effect text.
## Vanguard Strike is a Cael ability but a standalone Command, not a Rally, so
## it has no row here and nothing treats it as one.
const RALLY_EFFECTS: Dictionary = {
	"hold_the_line": {"stat_pct": {"def": 15, "mdef": 15}, "turns": 3},
	"press_forward": {"stat_pct": {"atk": 20, "spd": 10}, "turns": 3},
	"second_wind": {"regen_pct": 5, "turns": 4},
	"unbreakable": {"last_stand": true, "turns": 3},
}

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Issue the ability in [param command]. Returns false when it never happened —
## not this character's, not built, blocked by a status, or not enough to pay —
## so the caller re-opens the menu. Nothing is spent unless it resolves.
func do_ability(actor_id: String, command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = state.get_member(slot)
	var ability: Dictionary = command.get("ability", {})
	if member.is_empty() or ability.get("character", "") != member.get("character_id", ""):
		return false
	if not is_available(member, ability):
		return false
	if not pay(state, slot, ability):
		_battle.message.emit("Not enough MP!")
		return false
	_battle.message.emit(
		"%s uses %s!" % [member.get("character_data", {}).get("name", "???"), ability["name"]]
	)
	_resolver(ability).call(slot, ability)
	return true


## The resolver for [param ability]'s command, or an invalid Callable when that
## command is not built yet.
func _resolver(ability: Dictionary) -> Callable:
	match ability.get("command", ""):
		"rally":
			return _resolve_rally
	return Callable()


## Cael's Rally: every living ally gains the effect for its turns, replacing
## any Rally already running (BattleRally.start).
func _resolve_rally(slot: int, ability: Dictionary) -> void:
	BattleRally.start(_battle.get_battle_state(), slot, ability["id"], RALLY_EFFECTS[ability["id"]])


## Whether [param ability] can be issued at all in this build: its command has
## a resolver and this ability has its rules. Vanguard Strike's data says
## command "rally", but it is not a Rally and is not built in 158a.
static func is_built(ability: Dictionary) -> bool:
	match ability.get("command", ""):
		"rally":
			return is_rally(ability)
	return false


## Whether [param ability] is one of Cael's Rallies.
static func is_rally(ability: Dictionary) -> bool:
	return RALLY_EFFECTS.has(ability.get("id", ""))


## Whether [param member] could issue [param ability] now, cost aside: it is
## built and no status blocks it. A Rally is unavailable while Cael is
## Silenced, since Silence would end it at once (abilities.md § Cael — Rally).
static func is_available(member: Dictionary, ability: Dictionary) -> bool:
	if not is_built(ability):
		return false
	if is_rally(ability) and not BattleRally.caster_can_sustain(member):
		return false
	return true


## Whether [param member] has enough of [param ability]'s resource. Keyed on
## the data's cost_type: only "mp" is built (158a). "ap" (Bulwark, 158b), "ac"
## (Forgewright, 158c), "mp_cd" (Tricks' MP plus cooldown, 158d) and "wg"
## (Arcanum, 158f) answer false until their slices add them, and "none" marks a
## passive, which is never issued.
static func can_pay(member: Dictionary, ability: Dictionary) -> bool:
	match ability.get("cost_type", ""):
		"mp":
			return int(member.get("current_mp", 0)) >= int(ability.get("cost_value", 0))
	return false


## Spend [param ability]'s cost from [param slot]. Returns false, spending
## nothing, when it cannot be paid. Same cost types as can_pay.
static func pay(state: Node, slot: int, ability: Dictionary) -> bool:
	if not can_pay(state.get_member(slot), ability):
		return false
	match ability.get("cost_type", ""):
		"mp":
			return state.spend_mp(slot, int(ability.get("cost_value", 0)))
	return false
