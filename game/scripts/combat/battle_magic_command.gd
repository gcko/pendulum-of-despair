class_name BattleMagicCommand
extends RefCounted
## The Magic command in battle: validates targets, spends MP, and resolves a
## spell's damage, healing or status against the chosen side, an ally spell's
## revive, stat buff, regeneration, MP restore, cure or escape (#503), an
## enemy debuff's stat penalty or dispel (#514), or a heal or Regen turned on
## an enemy (BattleEnemyHeal).
##
## Extracted from battle_manager.gd (GAP-087) so the manager holds the ATB loop
## and the command dispatch while each command owns its own resolution rules.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const AllySpells = preload("res://scripts/combat/battle_ally_spells.gd")
const EnemyDebuffs = preload("res://scripts/combat/battle_enemy_debuffs.gd")

## Weave Gauge earned by the caster for a spell that landed, and the share
## Maren banks when somebody else casts
## (abilities.md § Resource Cost Invariants > 'Weave Gauge derivation').
const CASTER_WEAVE_GAIN: int = 5
const MAREN_WEAVE_GAIN: int = 10

## Statuses under which a party member cannot cast: Silence, "Cannot cast
## spells" (magic.md § Status Effect Reference).
const CAST_BLOCKING_STATUSES: Array[String] = ["silence"]

## Targets on the party's own side. A spell aimed there needs a built effect
## to be cast in battle (is_castable_in_battle).
const ALLY_TARGETS: Array[String] = ["single_ally", "all_allies", "fainted_ally", "self"]

## Spell data keys carrying an ally spell's battle effect (#503), each valued
## from the spell's magic.md entry; BattleAllySpells and do_magic read them.
const ALLY_EFFECTS: Array[String] = [
	"stat_buff", "regen_pct", "revive_pct", "mp_restore_pct", "cure", "escape"
]

## Effects that last the spell's duration, which must then be 1 turn or more.
const TIMED_EFFECTS: Array[String] = ["stat_buff", "regen_pct", "stat_debuff"]

var _battle: Node
var _allies: AllySpells = null


func _init(battle: Node) -> void:
	_battle = battle


## Cast the spell in [param command]. Returns false, spending nothing, when the
## cast never happened, so the caller re-opens the menu: the caster is Silenced;
## _target_type refuses it; its ally target is not alive (or, for a revive, not
## Fainted); no enemy is left; a revive was turned on anything but an Undead; it
## is an escape in a boss fight; or the caster cannot pay its MP or HP.
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
	var hp_cost: int = hp_cost_of(spell, member)
	if not can_pay_hp(spell, member):
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
		# Smokeveil: "In combat, immediately ends the battle with no rewards",
		# announced as a successful Flee is (battle-dialogue.md § Escape).
		_battle.message.emit("Escaped!")
		_battle.flee_result.emit(true)
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
## § 2.6) with no enemy-side rule. A heal or a Regen crosses as
## "ally_on_enemy", a revive as "revive_on_enemy" (do_magic holds that to an
## Undead).
static func _target_type(spell: Dictionary, command: Dictionary) -> String:
	if not is_castable_in_battle(spell):
		return ""
	var target_type: String = spell.get("target", "single_enemy")
	if not command.get("target_enemy", false):
		return target_type
	if target_type == "single_ally":
		return "ally_on_enemy" if restores_hp(spell) or spell.get("regen_pct") != null else ""
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
	if EnemyDebuffs.has_effect(spell) and target_type in ["single_enemy", "all_enemies"]:
		var took: bool = (
			_debuff_on_enemy(mag, spell, resolved_enemy_target)
			if target_type == "single_enemy"
			else _for_each_targetable_enemy(
				func(i: int) -> bool: return _debuff_on_enemy(mag, spell, i)
			)
		)
		if not took and bool(spell.get("dispel", false)):
			# Nothing to strip on any target: said once per cast, not per enemy.
			_battle.message.emit("No effect!")
		return took
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
	if target_type == "ally_on_enemy" and spell.get("regen_pct") != null:
		return BattleEnemyHeal.grant_regen(_battle, slot, spell, resolved_enemy_target)
	if target_type == "ally_on_enemy":
		return _heal_on_enemy(slot, DamageCalc.calculate_healing(mag, power), resolved_enemy_target)
	if target_type == "revive_on_enemy":
		var enemy: Node = _battle.get_enemies()[resolved_enemy_target]
		var hp: int = enemy.current_hp
		enemy.take_damage(hp)
		BattleEnemyHeal.land_spell_damage(_battle, slot, hp, resolved_enemy_target)
		return true
	if target_type in ALLY_TARGETS:
		# One heal roll for the whole cast, as a party heal has always rolled.
		var heal_amt: int = DamageCalc.calculate_healing(mag, power) if restores_hp(spell) else 0
		if _allies == null:
			_allies = AllySpells.new(_battle)
		return _allies.resolve(slot, spell, target_type, command, heal_amt)
	return false


## A heal spell's [param heal_amt], rolled once for the cast, landing on enemy
## [param idx] by the heal-on-enemy rules (BattleEnemyHeal.land: an Undead or
## Pallor takes it as damage). Returns whether the cast earns Weave Gauge.
func _heal_on_enemy(caster_slot: int, heal_amt: int, idx: int) -> bool:
	return BattleEnemyHeal.land(_battle, caster_slot, heal_amt, idx)


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
		BattleEnemyHeal.land_spell_damage(_battle, caster_slot, int(result.get("damage", 0)), idx)
		if enemies[idx].is_alive and not rider.is_empty():
			# The rider rides on landed damage, and only onto a target still alive.
			BattleActions.roll_status_rider(state, caster_slot, rider, enemies[idx])
		return true
	_battle.damage_dealt.emit("enemy_%d" % idx, 0, "miss")
	return false


## Land a debuff spell's stat penalty or dispel on enemy [param idx], cast at
## [param mag]: a missed roll shows as a miss. Neither deals damage. Returns
## whether it took (Weave Gauge); _resolve says when a dispel took nowhere.
func _debuff_on_enemy(mag: int, spell: Dictionary, idx: int) -> bool:
	var outcome: String = EnemyDebuffs.land(mag, spell, _battle.get_enemies()[idx])
	if outcome == "missed":
		_battle.damage_dealt.emit("enemy_%d" % idx, 0, "miss")
	return outcome in ["debuffed", "dispelled"]


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


## Whether [param spell] has a battle effect, a timed one lasting a turn or
## more. Ally-side: a heal with power, a registry status or one of ALLY_EFFECTS.
## Enemy-side: a damage power, a status spell landing a registry status, or a
## stat debuff or dispel (EnemyDebuffs, #514). One not built yet is refused
## before MP is spent, and the Magic menu grays it out: Leymirror, Last Breath,
## Drift, Forgeshield, the field-only Waymark, Linewalk and Veilstep, and on the
## enemy side Crumble, Spiritsight, Glintmark and the enemy-only Drinker of Days.
static func is_castable_in_battle(spell: Dictionary) -> bool:
	var turns: Variant = spell.get("duration")
	for key: String in TIMED_EFFECTS:
		if spell.get(key) != null and (turns == null or int(turns) < 1):
			return false
	var known_status: bool = StatusEffects.is_known(str(spell.get("status", "")))
	if not str(spell.get("target", "single_enemy")) in ALLY_TARGETS:
		var power: Variant = spell.get("power")
		if power != null and int(power) > 0:
			return true
		if spell.get("category", "") == "status":
			return known_status
		return EnemyDebuffs.has_effect(spell)
	if restores_hp(spell) or known_status:
		return true
	for key: String in ALLY_EFFECTS:
		if spell.get(key) != null:
			return true
	return false


## The HP [param member] pays to cast [param spell] (Leydraught: 15% of max
## HP, floored), 0 when it costs none.
static func hp_cost_of(spell: Dictionary, member: Dictionary) -> int:
	return int(member.get("max_hp", 0)) * int(spell.get("hp_cost_pct", 0)) / 100


## Whether [param member] can pay [param spell]'s HP cost: only with HP left
## over, so the cost never KOs the caster (2026-10-30 ruling). The battle Magic
## menu grays the spell out on the same answer.
static func can_pay_hp(spell: Dictionary, member: Dictionary) -> bool:
	var cost: int = hp_cost_of(spell, member)
	return cost <= 0 or int(member.get("current_hp", 0)) > cost


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
