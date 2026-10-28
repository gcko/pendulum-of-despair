class_name BattleAbilityCommand
extends RefCounted
## The Ability command in battle: each character's unique command (GAP-002,
## abilities.md § 1. Character Unique Commands).
##
## A dispatcher. do_ability checks the ability can be issued, pays its cost
## (keyed on the data's cost_type), then hands it to the resolver for its
## command (the data's `command` field). Slice 158a of #158 built Cael's
## Rally and 158b Edren's Bulwark. Forgewright, Tricks, Spiritcall and Arcanum
## are slices 158c-f: each adds a resolver here, and pay() learns its cost
## type. Until then their abilities are not built, so the battle menu lists
## them disabled and do_ability refuses them.
##
## The in-force rules live in BattleRally and BattleBulwark, reached through
## BattleState's ability hooks.

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
	if not _target_ok(state, slot, ability, command):
		_battle.message.emit("No target!")
		return false
	if not pay(state, slot, ability):
		_battle.message.emit("Not enough %s!" % String(ability.get("cost_type", "")).to_upper())
		return false
	_battle.message.emit(
		"%s uses %s!" % [member.get("character_data", {}).get("name", "???"), ability["name"]]
	)
	_resolver(ability).call(slot, ability, command)
	return true


## Whether a single-ally ability has a living ally at command["target"]. Ironwall
## also needs that ally to be someone other than Edren: guarding himself would
## redirect his damage to himself (BattleBulwark.guard_for).
static func _target_ok(state: Node, slot: int, ability: Dictionary, command: Dictionary) -> bool:
	if ability.get("target", "") != "single_ally":
		return true
	var target: int = int(command.get("target", -1))
	if not state.get_member(target).get("is_alive", false):
		return false
	return not (ability.get("id", "") == "ironwall" and target == slot)


## The resolver for [param ability]'s command, or an invalid Callable when that
## command is not built yet.
func _resolver(ability: Dictionary) -> Callable:
	match ability.get("command", ""):
		"rally":
			return _resolve_rally
		"bulwark":
			return _resolve_bulwark
	return Callable()


## Cael's Rally: every living ally gains the effect for its turns, replacing
## any Rally already running (BattleRally.start).
func _resolve_rally(slot: int, ability: Dictionary, _command: Dictionary) -> void:
	BattleRally.start(_battle.get_battle_state(), slot, ability["id"], RALLY_EFFECTS[ability["id"]])


## Edren's Bulwark: raise a stance, arm Riposte, veil an ally, break the stance,
## steel the party, or take up Oathkeeper.
func _resolve_bulwark(slot: int, ability: Dictionary, command: Dictionary) -> void:
	var state: Node = _battle.get_battle_state()
	var target: int = int(command.get("target", -1))
	match ability["id"]:
		"ironwall", "rampart":
			BattleBulwark.enter_stance(state, slot, ability["id"], target)
		"riposte":
			BattleBulwark.arm_riposte(state, slot)
		"aegis_veil":
			BattleBulwark.aegis_veil(state, target)
		"shatter_guard":
			_shatter_guard(slot, BattleBulwark.shatter(state, slot))
		"steadfast_resolve":
			BattleBulwark.steadfast_resolve(state)
		"oathkeeper":
			BattleBulwark.oathkeeper(state, slot)


## Shatter Guard lands [param dmg] on every enemy as fixed damage: no hit roll,
## no variance, no DEF, no Spirit halving (the ruling on #158).
func _shatter_guard(slot: int, dmg: int) -> void:
	var enemies: Array[Node] = _battle.get_enemies()
	for i: int in range(enemies.size()):
		var enemy: Node = enemies[i]
		if not enemy.is_alive or enemy.get_meta("untargetable", false):
			continue
		enemy.take_damage(dmg)
		_battle.get_battle_state().add_threat(slot, dmg)  # GAP-009 highest-threat
		_battle.damage_dealt.emit("enemy_%d" % i, dmg, "physical")
		if not enemy.is_alive:
			_battle.combatant_died.emit("enemy_%d" % i)
			_battle.get_atb().remove_combatant("enemy_%d" % i)


## Whether [param ability] can be issued at all in this build: its command has
## a resolver and this ability has its rules. Vanguard Strike's data says
## command "rally", but it is not a Rally and is not built in 158a.
static func is_built(ability: Dictionary) -> bool:
	match ability.get("command", ""):
		"rally":
			return is_rally(ability)
		"bulwark":
			return BattleBulwark.BUILT.has(ability.get("id", ""))
	return false


## Whether [param ability] is one of Cael's Rallies.
static func is_rally(ability: Dictionary) -> bool:
	return RALLY_EFFECTS.has(ability.get("id", ""))


## Whether [param member] could issue [param ability] now, cost aside: it is
## built and no status blocks it. A Rally is unavailable while Cael is
## Silenced, since Silence would end it at once (abilities.md § Cael — Rally).
## Shatter Guard breaks a stance, so it needs one.
static func is_available(member: Dictionary, ability: Dictionary) -> bool:
	if not is_built(ability):
		return false
	if is_rally(ability) and not BattleRally.caster_can_sustain(member):
		return false
	if ability.get("id", "") == "shatter_guard" and not BattleBulwark.in_stance(member):
		return false
	return true


## Whether [param member] has enough of [param ability]'s resource. Keyed on
## the data's cost_type: "mp" (158a) and "ap" (Bulwark's Aegis Points, 158b)
## are built. "ac" (Forgewright, 158c), "mp_cd" (Tricks' MP plus cooldown,
## 158d) and "wg" (Arcanum, 158f) answer false until their slices add them, and
## "none" marks a passive, which is never issued.
static func can_pay(member: Dictionary, ability: Dictionary) -> bool:
	match ability.get("cost_type", ""):
		"mp":
			return int(member.get("current_mp", 0)) >= int(ability.get("cost_value", 0))
		"ap":
			return BattleBulwark.can_spend(member, int(ability.get("cost_value", 0)))
	return false


## Spend [param ability]'s cost from [param slot]. Returns false, spending
## nothing, when it cannot be paid. Same cost types as can_pay.
static func pay(state: Node, slot: int, ability: Dictionary) -> bool:
	if not can_pay(state.get_member(slot), ability):
		return false
	match ability.get("cost_type", ""):
		"mp":
			return state.spend_mp(slot, int(ability.get("cost_value", 0)))
		"ap":
			return BattleBulwark.spend_ap(state, slot, int(ability.get("cost_value", 0)))
	return false
