class_name BattleAbilityCommand
extends RefCounted
## The Ability command in battle: each character's unique command (GAP-002,
## abilities.md § 1. Character Unique Commands).
##
## A dispatcher. do_ability checks the ability can be issued, pays its cost
## (keyed on the data's cost_type), then hands it to the resolver for its
## command (the data's `command` field). Slice 158a of #158 built Cael's
## Rally, 158b Edren's Bulwark and 158c Lira's Forgewright. Tricks, Spiritcall
## and Arcanum are slices 158d-f: each adds a resolver here, and pay() learns
## its cost type. Until then their abilities are not built, so the battle menu
## lists them disabled and do_ability refuses them, as it does the Forgewright
## abilities left for a later slice (BattleForgewright.BUILT).
##
## The in-force rules live in BattleRally, BattleBulwark and BattleForgewright,
## reached through BattleState's ability hooks.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")

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
## not this character's, not built, not available now (a status, or Bulwark's
## own state), no valid target, or not enough to pay — so the caller re-opens
## the menu. Nothing is spent unless it resolves.
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


## The resolver for [param ability]'s command, or an invalid Callable when that
## command is not built yet.
func _resolver(ability: Dictionary) -> Callable:
	match ability.get("command", ""):
		"rally":
			return _resolve_rally
		"bulwark":
			return _resolve_bulwark
		"forgewright":
			return _resolve_forgewright
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


## Lira's Forgewright: deploy a device (at command["target"] where it takes an
## ally), Overcharge an ally, or Salvage her oldest device.
func _resolve_forgewright(slot: int, ability: Dictionary, command: Dictionary) -> void:
	var state: Node = _battle.get_battle_state()
	var target: int = int(command.get("target", -1))
	match ability["id"]:
		"overcharge":
			BattleForgewright.overcharge(state, target)
		"salvage":
			BattleForgewright.salvage(state, slot)
		_:
			BattleForgewright.deploy(state, slot, ability, target, _battle)


## Shatter Guard lands the [param shattered] total on every targetable enemy as
## fixed damage — no hit roll, no variance, no DEF, no Spirit halving — but never
## less than one basic attack against that enemy (_shatter_damage;
## abilities.md § Edren — Bulwark, rulings).
func _shatter_guard(slot: int, shattered: Dictionary) -> void:
	var enemies: Array[Node] = _battle.get_enemies()
	for i: int in range(enemies.size()):
		var enemy: Node = enemies[i]
		if not enemy.is_alive or enemy.get_meta("untargetable", false):
			continue
		var dmg: int = _shatter_damage(slot, enemy, shattered)
		enemy.take_damage(dmg)
		_battle.get_battle_state().add_threat(slot, dmg)  # GAP-009 highest-threat
		_battle.damage_dealt.emit("enemy_%d" % i, dmg, "physical")
		if not enemy.is_alive:
			_battle.combatant_died.emit("enemy_%d" % i)
			_battle.get_atb().remove_combatant("enemy_%d" % i)


## Shatter Guard's fixed damage on [param enemy] from Edren at [param slot]: the
## [param shattered] total (BattleBulwark.shatter), raised to one basic attack
## against this enemy (the physical formula at ability_mult 1.0, with its DEF, a
## Spirit's halving and the variance roll but no hit roll or crit), then capped
## at the shattered cap and the damage cap.
func _shatter_damage(slot: int, enemy: Node, shattered: Dictionary) -> int:
	var state: Node = _battle.get_battle_state()
	var floor_dmg: int = DamageCalc.calculate_physical(
		state.get_effective_stat(slot, "atk"),
		float(BattleBulwark.SHATTER_GUARD["floor_ability_mult"]),
		int(enemy.get_stats().get("def", 0)),
		false,
		1.0,
		state.get_member(slot).get("row", "front"),
		"front",
		false,
		[],
		false,
		1.0,
		ModifierAggregator.physical_pre_def_mult(enemy.get_type())
	)
	var dmg: int = maxi(floor_dmg, int(shattered["total"]))
	return mini(BattleBulwark.DAMAGE_CAP, mini(int(shattered["cap"]), dmg))


## Whether [param ability] can be issued at all in this build: its command has
## a resolver and this ability has its rules. Vanguard Strike's data says
## command "rally", but it is not a Rally and is not built in 158a.
static func is_built(ability: Dictionary) -> bool:
	match ability.get("command", ""):
		"rally":
			return is_rally(ability)
		"bulwark":
			return BattleBulwark.BUILT.has(ability.get("id", ""))
		"forgewright":
			return BattleForgewright.BUILT.has(ability.get("id", ""))
	return false


## Whether [param ability] is one of Cael's Rallies.
static func is_rally(ability: Dictionary) -> bool:
	return RALLY_EFFECTS.has(ability.get("id", ""))


## Whether [param member] could issue [param ability] now, cost aside: it is
## built and no status blocks it. A Rally is unavailable while Cael is
## Silenced, since Silence would end it at once (abilities.md § Cael — Rally).
## Shatter Guard breaks a stance, so it needs one; Riposte is automatic under
## Oathkeeper, so it cannot be armed then. Salvage needs a device standing.
static func is_available(member: Dictionary, ability: Dictionary) -> bool:
	if not is_built(ability):
		return false
	if ability.get("command", "") == "forgewright":
		return BattleForgewright.can_issue(member, ability)
	if is_rally(ability) and not BattleRally.caster_can_sustain(member):
		return false
	if ability.get("id", "") == "shatter_guard" and not BattleBulwark.in_stance(member):
		return false
	if ability.get("id", "") == "riposte" and BattleBulwark.oathkeeper_on(member):
		return false
	return true


## Whether [param member] has enough of [param ability]'s resource. Keyed on
## the data's cost_type: "mp" (158a), "ap" (Bulwark's Aegis Points, 158b) and
## "ac" (Forgewright's Arcanite Charges, 158c) are built. "mp_cd" (Tricks' MP
## plus cooldown, 158d) and "wg" (Arcanum, 158f) answer false until their
## slices add them, and "none" marks a passive, which is never issued.
static func can_pay(member: Dictionary, ability: Dictionary) -> bool:
	match ability.get("cost_type", ""):
		"mp":
			return int(member.get("current_mp", 0)) >= int(ability.get("cost_value", 0))
		"ap":
			return BattleBulwark.can_spend(member, int(ability.get("cost_value", 0)))
		"ac":
			return BattleForgewright.can_spend(member, int(ability.get("cost_value", 0)))
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
		"ac":
			return BattleForgewright.spend_ac(state, slot, int(ability.get("cost_value", 0)))
	return false


## Whether a single-ally ability has a living ally at command["target"]. Ironwall
## also needs that ally to be someone other than Edren: a hit on him already
## counts as absorbed while he holds any stance (BattleBulwark.guard_for), so
## guarding himself would add nothing.
static func _target_ok(state: Node, slot: int, ability: Dictionary, command: Dictionary) -> bool:
	if ability.get("target", "") != "single_ally":
		return true
	var target: int = int(command.get("target", -1))
	if not state.get_member(target).get("is_alive", false):
		return false
	return not (ability.get("id", "") == "ironwall" and target == slot)
