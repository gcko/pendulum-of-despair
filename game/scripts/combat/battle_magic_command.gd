class_name BattleMagicCommand
extends RefCounted
## The Magic command in battle: validates targets, spends MP, and resolves a
## spell's damage, healing or status against the chosen side, or an ally
## spell's revive, stat buff, regeneration, MP restore, cure or escape (#503).
##
## Extracted from battle_manager.gd (GAP-087) so the manager holds the ATB loop
## and the command dispatch while each command owns its own resolution rules.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const Buffs = preload("res://scripts/combat/battle_buffs.gd")

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

## Targets on the party's own side. A spell aimed there needs a built effect
## to be cast in battle (is_castable_in_battle).
const ALLY_TARGETS: Array[String] = ["single_ally", "all_allies", "fainted_ally", "self"]

## Spell data keys carrying an ally spell's battle effect (#503), each valued
## from the spell's magic.md entry; _land_on_ally and do_magic read them.
const ALLY_EFFECTS: Array[String] = [
	"stat_buff", "regen_pct", "revive_pct", "mp_restore_pct", "cure", "escape"
]

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Cast the spell in [param command]. Returns false, spending nothing, when the
## cast never happened, so the caller re-opens the menu: the caster is Silenced;
## _target_type refuses it; its ally target is not alive (or, for a revive, not
## Fainted); no enemy is left; it is an escape in a boss fight; or the caster
## cannot pay its MP or HP.
func do_magic(actor_id: String, command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var slot: int = actor_id.replace("party_", "").to_int()
	var member: Dictionary = state.get_member(slot)
	if member.is_empty() or not can_cast(member):
		return false
	var spell: Dictionary = command.get("spell", {})
	var target_type: String = _target_type(spell, command)
	if target_type.is_empty():
		_battle.message.emit("No effect!")
		return false
	if target_type in ["single_ally", "fainted_ally"]:
		var tm: Dictionary = state.get_member(command.get("target", 0))
		if tm.is_empty() or tm.get("is_alive", false) == (target_type == "fainted_ally"):
			_battle.message.emit("No effect!")
			return false
	var resolved_enemy_target: int = -1
	if target_type in ["single_enemy", "ally_on_enemy", "revive_on_enemy"]:
		resolved_enemy_target = BattleActions.resolve_enemy_target(
			command.get("target", 0), _battle.get_enemies()
		)
		if resolved_enemy_target < 0:
			_battle.message.emit("No target!")
			return false
		if target_type == "revive_on_enemy":
			# Only an Undead has a revive rule: it dies (bestiary/README.md § Undead).
			if _battle.get_enemies()[resolved_enemy_target].get_type() != "undead":
				_battle.message.emit("No effect!")
				return false
	if spell.get("escape", false) and _battle.is_boss_battle():
		_battle.message.emit("Can't use that here!")
		return false
	var hp_cost: int = int(member.get("max_hp", 0)) * int(spell.get("hp_cost_pct", 0)) / 100
	if hp_cost > 0 and int(member.get("current_hp", 0)) <= hp_cost:
		_battle.message.emit("Not enough HP!")
		return false
	var cost: int = SpellHelpers.get_mp_cost(spell, member.get("character_id", ""))
	if not state.spend_mp(slot, cost):
		_battle.message.emit("Not enough MP!")
		return false
	var caster_name: String = member.get("character_data", {}).get("name", "???")
	_battle.message.emit("%s casts %s!" % [caster_name, spell.get("name", "Spell")])
	if hp_cost > 0:
		# Leydraught's price: the caster's own HP (magic.md § 43 Leydraught).
		_battle.damage_dealt.emit(actor_id, state.take_damage(slot, hp_cost, false), "hp_cost")
	if spell.get("escape", false):
		# Smokeveil: "In combat, immediately ends the battle with no rewards."
		_battle.exit_battle("flee")
		return true
	var had_effect: bool = _resolve(slot, spell, target_type, resolved_enemy_target, command)
	# Only gain Weave Gauge if the spell actually affected at least one target
	if had_effect:
		state.gain_weave_gauge(slot, CASTER_WEAVE_GAIN)
		if member.get("character_id", "") != "maren":
			state.gain_weave_gauge_for_maren(MAREN_WEAVE_GAIN)
	return true


## The target type [param spell] resolves as, or "" when it cannot be cast: no
## battle effect is built, or it was turned on the enemy line (ui-design.md
## § 2.6) with no enemy-side rule. A heal crosses as "ally_on_enemy", a revive
## as "revive_on_enemy" (do_magic holds that to an Undead).
static func _target_type(spell: Dictionary, command: Dictionary) -> String:
	if not is_castable_in_battle(spell):
		return ""
	var target_type: String = spell.get("target", "single_enemy")
	if not command.get("target_enemy", false):
		return target_type
	if target_type == "single_ally":
		return "ally_on_enemy" if restores_hp(spell) else ""
	if target_type == "fainted_ally":
		return "revive_on_enemy"
	return target_type


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
	if target_type == "ally_on_enemy":
		return _heal_on_enemy(slot, DamageCalc.calculate_healing(mag, power), resolved_enemy_target)
	if target_type == "revive_on_enemy":
		var enemy: Node = _battle.get_enemies()[resolved_enemy_target]
		var hp: int = enemy.current_hp
		enemy.take_damage(hp)
		_land_spell_damage(slot, hp, resolved_enemy_target)
		return true
	if target_type in ["single_ally", "all_allies", "fainted_ally"]:
		# One heal roll for the whole cast, as a party heal has always rolled.
		var heal_amt: int = DamageCalc.calculate_healing(mag, power) if restores_hp(spell) else 0
		var had_effect: bool = false
		for i: int in _ally_slots(target_type, command):
			if _land_on_ally(spell, i, heal_amt):
				had_effect = true
		return had_effect
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


## The party slots an ally spell lands on: the chosen one, or all living ones.
func _ally_slots(target_type: String, command: Dictionary) -> Array[int]:
	if target_type != "all_allies":
		return [int(command.get("target", 0))]
	var slots: Array[int] = []
	for i: int in range(4):
		if _battle.get_battle_state().get_member(i).get("is_alive", false):
			slots.append(i)
	return slots


## Land every effect [param spell] carries on party slot [param slot], and
## [param heal_amt] HP. Returns whether any of them changed the target.
func _land_on_ally(spell: Dictionary, slot: int, heal_amt: int) -> bool:
	var state: Node = _battle.get_battle_state()
	var m: Dictionary = state.get_member(slot)
	var landed: bool = false
	if spell.get("revive_pct") != null:
		var revive_hp: int = maxi(1, _pct_of(m, "max_hp", spell, "revive_pct"))
		landed = _show_heal(slot, state.heal(slot, revive_hp, true)) or landed
	if heal_amt > 0:
		landed = _show_heal(slot, state.heal(slot, heal_amt)) or landed
	var turns: int = int(spell.get("duration", 0)) if spell.get("duration") != null else 0
	var buff: Variant = spell.get("stat_buff")
	if buff is Dictionary:
		var pct: int = int(buff.get("pct", 0))
		landed = Buffs.grant(state, slot, str(buff.get("stat", "")), pct, turns) or landed
	if spell.get("regen_pct") != null:
		landed = Buffs.grant(state, slot, Buffs.REGEN, int(spell["regen_pct"]), turns) or landed
	if spell.get("mp_restore_pct") != null:
		var mp_before: int = int(m.get("current_mp", 0))
		state.restore_mp(slot, _pct_of(m, "max_mp", spell, "mp_restore_pct"))
		landed = int(m.get("current_mp", 0)) > mp_before or landed
	if spell.get("cure") is Dictionary:
		landed = _cure(slot, spell["cure"]) or landed
	var status: String = str(spell.get("status", ""))
	if spell.get("category", "") == "buff" and StatusEffects.is_known(status):
		landed = _status_on_ally(slot, status, spell.get("duration")) or landed
	return landed


## [param spell]'s [param pct_key] percent of [param m]'s [param pool], floored.
static func _pct_of(m: Dictionary, pool: String, spell: Dictionary, pct_key: String) -> int:
	return int(m.get(pool, 0)) * int(spell.get(pct_key, 0)) / 100


## Show [param healed] HP restored to [param slot]; returns whether any came back.
func _show_heal(slot: int, healed: int) -> bool:
	if healed > 0:
		_battle.damage_dealt.emit("party_%d" % slot, healed, "heal")
	return healed > 0


## Cure party slot [param slot] by [param rule] {only, except, count}: the
## listed statuses in order, else every negative one but the exceptions (Purge:
## not Stop or Despair), at most count of them (Cleansing Draught: one), 0 = all.
## A positive status is never cured. Returns whether anything was cured.
func _cure(slot: int, rule: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var candidates: Array = (rule.get("only", []) as Array).duplicate()
	if candidates.is_empty():
		for s: Dictionary in state.get_member(slot).get("active_statuses", []):
			candidates.append(s.get("name", ""))
	var limit: int = int(rule.get("count", 0))
	var cured: int = 0
	for status: Variant in candidates:
		var name: String = str(status)
		if limit > 0 and cured >= limit:
			break
		if StatusEffects.is_positive(name) or name in rule.get("except", []):
			continue
		if state.has_status(slot, name):
			state.remove_status(slot, name)
			cured += 1
	return cured > 0


## Land a buff spell's status on party slot [param slot] (Quickstep's Haste,
## #246) for the spell's duration, else the status's own, plus one on a self-cast
## (BattleBuffs.grant counts it the same way); a recast refreshes it. The battle
## announces it from BattleState.status_applied. Returns true.
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


## Whether [param spell] has a battle effect. An ally-side spell needs a heal
## with power, a registry status or one of ALLY_EFFECTS, so one not built yet
## (Leymirror, Last Breath, Drift, Forgeshield, the field-only Waymark, Linewalk,
## Veilstep) is refused before MP is spent, and the Magic menu grays it out.
static func is_castable_in_battle(spell: Dictionary) -> bool:
	if not str(spell.get("target", "single_enemy")) in ALLY_TARGETS:
		return true
	if restores_hp(spell) or StatusEffects.is_known(str(spell.get("status", ""))):
		return true
	for key: String in ALLY_EFFECTS:
		if spell.get(key) != null:
			return true
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
