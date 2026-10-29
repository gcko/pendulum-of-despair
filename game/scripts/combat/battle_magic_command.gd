class_name BattleMagicCommand
extends RefCounted
## The Magic command in battle: validates targets, spends MP, and resolves a
## spell's damage, healing or status against the chosen side.
##
## Extracted from battle_manager.gd (GAP-087) so the manager holds the ATB loop
## and the command dispatch while each command owns its own resolution rules.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## Weave Gauge earned by the caster for a spell that landed, and the share
## Maren banks when somebody else casts
## (abilities.md § Resource Cost Invariants > 'Weave Gauge derivation').
const CASTER_WEAVE_GAIN: int = 5
const MAREN_WEAVE_GAIN: int = 10

## Statuses under which a party member cannot cast: Silence, "Cannot cast
## spells" (magic.md § Status Effect Reference).
const CAST_BLOCKING_STATUSES: Array[String] = ["silence"]

## Enemy types a heal spell hurts instead of heals, for exactly the HP it
## would have restored: Undead ("Healing spells deal damage", bestiary/README.md
## § Undead) and Pallor (Pallor Feedback, combat-formulas.md § Tier 2).
const HEAL_REVERSING_TYPES: Array[String] = ["undead", "pallor"]

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Cast the spell in [param command]. Returns false when the cast never
## happened — the caster is Silenced; the spell was turned on an enemy
## ([code]target_enemy[/code]) but restores no HP; the ally is KO'd; no enemy is
## left to target; or there is not enough MP — so the caller re-opens the menu.
## Nothing is spent unless the cast resolves.
func do_magic(actor_id: String, command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = state.get_member(slot)
	if member.is_empty() or not can_cast(member):
		return false
	var spell: Dictionary = command.get("spell", {})
	var target_type: String = spell.get("target", "single_enemy")
	# A single-ally spell the player turned on the enemy line (ui-design.md § 2.6).
	if target_type == "single_ally" and command.get("target_enemy", false):
		if not restores_hp(spell):
			_battle.message.emit("No effect!")
			return false
		target_type = "ally_on_enemy"
	# Validate targets before spending MP or gaining gauge
	if target_type == "single_ally":
		var tm: Dictionary = state.get_member(command.get("target", 0))
		if tm.is_empty() or not tm.get("is_alive", false):
			_battle.message.emit("No effect!")
			return false
	var resolved_enemy_target: int = -1
	if target_type in ["single_enemy", "ally_on_enemy"]:
		resolved_enemy_target = BattleActions.resolve_enemy_target(
			command.get("target", 0), _battle.get_enemies()
		)
		if resolved_enemy_target < 0:
			_battle.message.emit("No target!")
			return false
	var cost: int = SpellHelpers.get_mp_cost(spell, member.get("character_id", ""))
	if not state.spend_mp(slot, cost):
		_battle.message.emit("Not enough MP!")
		return false
	var caster_name: String = member.get("character_data", {}).get("name", "???")
	_battle.message.emit("%s casts %s!" % [caster_name, spell.get("name", "Spell")])
	var had_effect: bool = _resolve(slot, spell, target_type, resolved_enemy_target, command)
	# Only gain Weave Gauge if the spell actually affected at least one target
	if had_effect:
		state.gain_weave_gauge(slot, CASTER_WEAVE_GAIN)
		if member.get("character_id", "") != "maren":
			state.gain_weave_gauge_for_maren(MAREN_WEAVE_GAIN)
	return true


## Apply the spell to its target side. Returns whether at least one target was
## affected, which is what drives the Weave Gauge gain.
func _resolve(
	slot: int,
	spell: Dictionary,
	target_type: String,
	resolved_enemy_target: int,
	command: Dictionary
) -> bool:
	var state: Node = _battle.get_battle_state()
	# Status spells carry power: null — guard before the int conversion.
	var power: int = 0
	if spell.get("power") != null:
		power = int(spell.get("power"))
	var mag: int = state.get_effective_stat(slot, "mag")
	var element: String = spell.get("element", "non_elemental")
	var is_status: bool = spell.get("category", "") == "status"
	if is_status and target_type == "single_enemy":
		return _status_on_enemy(slot, spell, resolved_enemy_target)
	if is_status and target_type == "all_enemies":
		return _for_each_targetable_enemy(
			func(i: int) -> bool: return _status_on_enemy(slot, spell, i)
		)
	if target_type == "single_enemy" or target_type == "all_enemies":
		# An offensive spell's status rider (magic.md § Derived Rules); null when none.
		var rider: Dictionary = {}
		if spell.get("rider") != null:
			rider = spell.get("rider")
		if target_type == "single_enemy":
			return _magic_on_enemy(slot, mag, power, element, rider, resolved_enemy_target)
		return _for_each_targetable_enemy(
			func(i: int) -> bool: return _magic_on_enemy(slot, mag, power, element, rider, i)
		)
	if spell.get("category", "") == "buff" and target_type == "single_ally":
		var buff_status: String = str(spell.get("status", ""))
		if StatusEffects.is_known(buff_status):
			return _status_on_ally(command.get("target", 0), buff_status, spell.get("duration"))
	if target_type == "ally_on_enemy":
		return _heal_on_enemy(slot, DamageCalc.calculate_healing(mag, power), resolved_enemy_target)
	if target_type in ["single_ally", "all_allies"]:
		return _heal_allies(target_type, command, DamageCalc.calculate_healing(mag, power))
	return false


## Run [param apply] against every alive, targetable enemy. Returns whether any
## call reported an effect; every enemy is visited regardless.
func _for_each_targetable_enemy(apply: Callable) -> bool:
	var had_effect: bool = false
	var enemies: Array[Node] = _battle.get_enemies()
	for i: int in range(enemies.size()):
		if enemies[i].is_alive and not enemies[i].get_meta("untargetable", false):
			if apply.call(i):
				had_effect = true
	return had_effect


## Restore HP to one ally or the whole party. Returns whether anyone gained HP.
func _heal_allies(target_type: String, command: Dictionary, heal_amt: int) -> bool:
	var state: Node = _battle.get_battle_state()
	var had_effect: bool = false
	if target_type == "single_ally":
		var tgt: int = command.get("target", 0)
		var healed: int = state.heal(tgt, heal_amt)
		if healed > 0:
			_battle.damage_dealt.emit("party_%d" % tgt, healed, "heal")
			had_effect = true
		return had_effect
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if not m.is_empty() and m.get("is_alive", false):
			var healed_amt: int = state.heal(i, heal_amt)
			if healed_amt > 0:
				_battle.damage_dealt.emit("party_%d" % i, healed_amt, "heal")
				had_effect = true
	return had_effect


## Land a buff spell's status on party slot [param slot] (Quickstep's Haste,
## #246) for the spell's own duration, else the status's canonical one, plus
## one when the target's turn is open (a self-cast): that turn's end would
## otherwise spend one, as BattleRally.start and BattleBulwark count it. A
## recast replaces the old one, refreshing the duration. The battle announces
## it from BattleState.status_applied. Returns true: the target was validated
## alive before any MP was spent.
func _status_on_ally(slot: int, status: String, duration: Variant) -> bool:
	var state: Node = _battle.get_battle_state()
	var turns: int = StatusEffects.resolve_duration(status, duration)
	if state.get_member(slot).get("turn_open", false):
		turns += 1
	state.apply_status(slot, status, "turns", float(turns))
	return true


## A heal spell landing on enemy [param idx]. An Undead or Pallor enemy takes
## [param heal_amt] as damage — the heal as rolled, with its own variance and
## 14,999 cap, no hit roll and no element or type multiplier — and that damage
## counts as spell damage: threat for the caster, Weave Gauge for the cast, and
## a kill handled like any other. A normal enemy is healed by it. Returns
## whether the cast earns Weave Gauge, which only heal damage does: healing an
## enemy earns none (2026-10-29 ruling).
func _heal_on_enemy(caster_slot: int, heal_amt: int, idx: int) -> bool:
	var enemy: Node = _battle.get_enemies()[idx]
	if enemy.get_type() in HEAL_REVERSING_TYPES:
		enemy.take_damage(heal_amt)
		_land_spell_damage(caster_slot, heal_amt, idx)
		return heal_amt > 0
	var before: int = enemy.current_hp
	enemy.heal(heal_amt)
	var healed: int = enemy.current_hp - before
	if healed > 0:
		_battle.damage_dealt.emit("enemy_%d" % idx, healed, "heal")
	return false


## Book [param dmg] of spell damage already dealt to enemy [param idx]: the
## caster's threat (GAP-009 highest-threat), the number shown over the enemy,
## and the kill if it fell.
func _land_spell_damage(caster_slot: int, dmg: int, idx: int) -> void:
	_battle.get_battle_state().add_threat(caster_slot, dmg)
	_battle.damage_dealt.emit("enemy_%d" % idx, dmg, "magic")
	if not _battle.get_enemies()[idx].is_alive:
		_battle.combatant_died.emit("enemy_%d" % idx)
		_battle.get_atb().remove_combatant("enemy_%d" % idx)


## Resolve a damage spell against one enemy, then roll its status [param rider]
## (`{status, chance}`, or empty) if the damage landed and the enemy survived.
## Returns true if it landed (an absorb counts — the spell affected the target).
func _magic_on_enemy(
	caster_slot: int, mag: int, power: int, element: String, rider: Dictionary, idx: int
) -> bool:
	var enemies: Array[Node] = _battle.get_enemies()
	if idx < 0 or idx >= enemies.size():
		return false
	var state: Node = _battle.get_battle_state()
	var result: Dictionary = BattleActions.apply_magic_to_enemy(
		state, caster_slot, mag, power, element, enemies[idx], idx
	)
	var dtype: String = result.get("type", "miss")
	if dtype == "immune":
		_battle.damage_dealt.emit("enemy_%d" % idx, 0, "immune")
		return false
	if dtype == "absorb":
		_battle.damage_dealt.emit("enemy_%d" % idx, result.get("damage", 0), "heal")
		return true
	if result.get("hit", false):
		_land_spell_damage(caster_slot, int(result.get("damage", 0)), idx)
		if enemies[idx].is_alive and not rider.is_empty():
			# The rider rides on landed damage, and only onto a target still alive.
			BattleActions.roll_status_rider(state, caster_slot, rider, enemies[idx])
		return true
	_battle.damage_dealt.emit("enemy_%d" % idx, 0, "miss")
	return false


## Resolve a status spell against a single enemy (GAP-003). Returns true if a
## status was inflicted (drives Weave Gauge gain in do_magic).
func _status_on_enemy(caster_slot: int, spell: Dictionary, idx: int) -> bool:
	var enemies: Array[Node] = _battle.get_enemies()
	if idx < 0 or idx >= enemies.size():
		return false
	var result: Dictionary = BattleActions.apply_status_to_enemy(
		_battle.get_battle_state(),
		caster_slot,
		int(spell.get("hit_rate", 0)),
		str(spell.get("status", "")),
		spell.get("duration"),
		enemies[idx]
	)
	if result.get("inflicted", false):
		# The battle announces it from the enemy's own status_applied (#439).
		return true
	match result.get("type", ""):
		"immune":
			_battle.damage_dealt.emit("enemy_%d" % idx, 0, "immune")
		"no_effect":
			# Unknown/deferred status (e.g. Stop) — surface honestly, not "miss".
			_battle.message.emit("No effect!")
		_:
			_battle.damage_dealt.emit("enemy_%d" % idx, 0, "miss")
	return false


## Whether [param spell] restores HP — a healing spell with a power — which is
## what lets a single-ally spell be turned on an enemy.
static func restores_hp(spell: Dictionary) -> bool:
	var power: Variant = spell.get("power")
	return spell.get("category", "") == "healing" and power != null and int(power) > 0


## Whether [param member] (a BattleState record) can cast at all: no status
## that blocks casting. The battle Magic menu grays out on the same answer.
static func can_cast(member: Dictionary) -> bool:
	for s: Dictionary in member.get("active_statuses", []):
		if s.get("name", "") in CAST_BLOCKING_STATUSES:
			return false
	return true
