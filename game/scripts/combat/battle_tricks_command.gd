class_name BattleTricksCommand
extends RefCounted
## What each of Sable's Tricks does when BattleAbilityCommand issues it (GAP-002,
## #158 slice d): Filch and Ransack steal, Smokescreen blinds the field, Shiv
## strikes or throws a stolen item, and Wild Card spends the whole Stolen Goods
## pool. The rules they share — the pool, stealing, cooldowns — are BattleTricks.
##
## Design law: abilities.md § Sable — Tricks and § Damage Magnitudes, with the
## readings recorded there from #158 and #447; combat-formulas.md § Special:
## Shiv. Shiv and Wild Card are physical strikes through the same rolls as the
## Attack command (hit, evasion, crit, the physical formula), but a Trick's
## element is its thrown item's alone (BattleDamageMods.trick_mods). Wild Card's
## debuff is drawn once for the whole field and lands on every enemy not immune
## to it, after the strike, at its canonical duration.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Whether [param command] names a target this Trick can take: Shiv's throw
## needs the item held, and a single-enemy Trick a living enemy.
func target_ok(slot: int, ability: Dictionary, command: Dictionary) -> bool:
	var thrown: String = String(command.get("throw_item", ""))
	if not thrown.is_empty() and not thrown in BattleTricks.goods(_state(), slot):
		return false
	if target_type(_state().get_member(slot), ability) != "single_enemy":
		return true
	return BattleActions.resolve_enemy_target(int(command.get("target", 0)), _enemies()) >= 0


## Resolve [param ability] from Sable at [param slot]; its cost is paid.
func resolve(slot: int, ability: Dictionary, command: Dictionary) -> void:
	var target: int = BattleActions.resolve_enemy_target(int(command.get("target", 0)), _enemies())
	match ability["id"]:
		"filch":
			_steal_from(slot, target, 100)
		"ransack":
			for i: int in _living():
				_steal_from(slot, i, BattleTricks.RANSACK_RATE_PCT)
		"smokescreen":
			BattleTricks.smokescreen(_enemies())
		"shiv":
			_shiv(slot, ability, target, String(command.get("throw_item", "")))
		"wild_card":
			_wild_card(slot, ability, target)


## The target a Trick asks for: Wild Card with nothing stolen is the
## single-target exception to its data's all_enemies (abilities.md § Damage
## Magnitudes > 'Wild Card').
static func target_type(member: Dictionary, ability: Dictionary) -> String:
	if ability.get("id", "") == "wild_card" and member.get("stolen_goods", []).is_empty():
		return "single_enemy"
	return String(ability.get("target", "single_enemy"))


# ---------- Tricks ----------


## Steal from enemy [param idx] at [param rate_pct] of Filch's chance. A take
## says "Obtained [Item Name]." (battle-dialogue.md § Battle Results); a miss
## shows as one.
func _steal_from(slot: int, idx: int, rate_pct: int) -> void:
	if idx < 0:
		return
	var item_id: String = BattleTricks.steal(_state(), slot, _enemies()[idx], rate_pct)
	if item_id.is_empty():
		_battle.damage_dealt.emit("enemy_%d" % idx, 0, "miss")
		return
	_battle.message.emit("Obtained %s." % BattleTricks.item_name(item_id))


## Shiv on enemy [param idx], bare or throwing [param thrown]: the same hit at the
## same multiplier and DEF ignore, carrying the item's element; the item is
## consumed either way.
func _shiv(slot: int, ability: Dictionary, idx: int, thrown: String) -> void:
	var element: String = ""
	if not thrown.is_empty():
		element = BattleTricks.thrown_element(thrown)
		BattleTricks.spend_goods(_state(), slot, thrown)
	var mult: float = float(
		ability.get("thrown_item_ability_mult" if not thrown.is_empty() else "ability_mult", 1.0)
	)
	_strike(slot, idx, mult, int(ability.get("def_ignore_pct", 0)), element)


## Wild Card by what Sable holds: none, a 2.0 strike on enemy [param idx]; one or
## more, a strike on every enemy at 2.0 (3.0 with three) with the newest
## elemental item's element; two or more add a random debuff on every enemy;
## three heal every ally 10% of max HP. Every stolen item is consumed.
func _wild_card(slot: int, ability: Dictionary, idx: int) -> void:
	var state: Node = _state()
	var held: Array[String] = BattleTricks.goods(state, slot)
	if held.is_empty():
		_strike(slot, idx, float(ability["ability_mult"]), 0, "")
		return
	var element: String = BattleTricks.wild_card_element(held)
	for item_id: String in held:
		BattleTricks.spend_goods(state, slot, item_id)
	var key: String = "ability_mult_max" if held.size() >= 3 else "item_branch_ability_mult"
	for i: int in _living():
		_strike(slot, i, float(ability[key]), 0, element)
	if held.size() >= 2:
		var list: Array = BattleTricks.WILD_CARD["debuffs"]
		var debuff: String = String(list[randi() % list.size()])
		for i: int in _living():
			_enemies()[i].apply_status(debuff, StatusEffects.resolve_duration(debuff, null))
	if held.size() >= 3:
		_heal_party(int(BattleTricks.WILD_CARD["heal_pct"]))


# ---------- Internals ----------


## One physical Trick strike from [param slot] on enemy [param idx] at
## [param mult], skipping [param def_ignore_pct]% of its DEF, carrying
## [param element]: shown, counted for threat, and cleaned up if it kills.
func _strike(slot: int, idx: int, mult: float, def_ignore_pct: int, element: String) -> void:
	if idx < 0 or not _enemies()[idx].is_alive:
		return
	var state: Node = _state()
	var member: Dictionary = state.get_member(slot)
	var enemy: Node = _enemies()[idx]
	var eid: String = "enemy_%d" % idx
	var stats: Dictionary = enemy.get_stats()
	var target_spd: int = int(stats.get("spd", 0))
	var spd: int = state.get_effective_stat(slot, "spd")
	if (
		not DamageCalc.roll_hit(spd, target_spd, BattleDamageMods.accuracy_mult(member))
		or DamageCalc.roll_evasion(target_spd)
	):
		_battle.damage_dealt.emit(eid, 0, "miss")
		return
	var is_crit: bool = DamageCalc.roll_crit(state.get_effective_stat(slot, "lck"))
	var mods: Dictionary = BattleDamageMods.trick_mods(member, enemy, element)
	var dmg: int = DamageCalc.calculate_physical(
		state.get_effective_stat(slot, "atk"),
		mult,
		int(stats.get("def", 0)) * (100 - def_ignore_pct) / 100,
		is_crit,
		float(mods["mult"]),
		member.get("row", "front"),
		"front",
		false,
		[],
		mods.has("element_mod"),
		float(mods.get("element_mod", 1.0)),
		ModifierAggregator.physical_pre_def_mult(enemy.get_type())
	)
	var result: Dictionary = BattleForgewright.land_strike(
		enemy, dmg, "critical" if is_crit else "physical", mods
	)
	if BattlePlayerActions.dealt_damage(result):
		state.add_threat(slot, int(result["damage"]))  # GAP-009 highest-threat
	_battle.damage_dealt.emit(eid, int(result["damage"]), String(result["type"]))
	if result.get("killed", false):
		_battle.combatant_died.emit(eid)
		_battle.get_atb().remove_combatant(eid)


## Heal every living ally [param pct]% of max HP, showing what each gained.
func _heal_party(pct: int) -> void:
	var state: Node = _state()
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.is_empty() or not m.get("is_alive", false):
			continue
		var healed: int = state.heal(i, int(m["max_hp"]) * pct / 100)
		if healed > 0:
			_battle.damage_dealt.emit("party_%d" % i, healed, "heal")


## Indices of the enemies a Trick can reach: living and targetable.
func _living() -> Array[int]:
	var out: Array[int] = []
	var enemies: Array[Node] = _enemies()
	for i: int in range(enemies.size()):
		if enemies[i].is_alive and not enemies[i].get_meta("untargetable", false):
			out.append(i)
	return out


func _state() -> Node:
	return _battle.get_battle_state()


func _enemies() -> Array[Node]:
	return _battle.get_enemies()
