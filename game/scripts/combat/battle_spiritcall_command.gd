class_name BattleSpiritcallCommand
extends RefCounted
## Resolves Torren's Spiritcalls (GAP-002, #158 slice e) once
## BattleAbilityCommand has checked and paid for one: what each spirit does at
## its Favor, the harmony that earns it Favor, and the battle's damage and heal
## feedback. The rules that outlast the cast — Favor, the wards, flight — are
## BattleSpiritcall's.
##
## Design law: abilities.md § Torren — Spiritcall, for the sub-ability table,
## and § Damage Magnitudes, for the spell powers and the Chorus's rule: 50% of
## each component's one quantity, at that spirit's own Favor, with a component
## whose spirit is not yet learned skipped. Magnitudes are torren.json's, each
## read in the form the spirit's Favor gives it (BattleSpiritcall.field).

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const StatusGuard = preload("res://scripts/combat/battle_status_guard.gd")
const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")

## The four spirits Convergence Chorus calls (abilities.md § Damage Magnitudes,
## "Which four spirits").
const CHORUS_SPIRITS: Array[String] = ["ember_wing", "dewfall", "thornveil", "stoneheart"]

## A heal "below 25% HP" is in harmony: HP x LOW_HP_DIVISOR under max HP.
const LOW_HP_DIVISOR: int = 4

var _battle: Node


## A flight from [param battle] costs the spirits called in it their Favor
## (BattleSpiritcall.on_fled), so this listens for one.
func _init(battle: Node) -> void:
	_battle = battle
	if battle.has_signal("flee_result"):
		battle.flee_result.connect(_on_flee_result)


## Resolve [param ability] from Torren at [param slot], aimed where
## [param command]["target"] says when it takes one target. The spirit's form is
## read here, once (BattleSpiritcall.form), so a harmony on this cast that
## reaches Favor 3 changes only the next one.
func resolve(slot: int, ability: Dictionary, command: Dictionary) -> void:
	var state: Node = _battle.get_battle_state()
	var target: int = int(command.get("target", -1))
	var id: String = ability["id"]
	var shape: Dictionary = BattleSpiritcall.form(ability)
	var cast: Dictionary = BattleSpiritcall.new_cast(
		state, slot, id if id in BattleSpiritcall.SPIRITS else ""
	)
	var called: Array = [id] if id in BattleSpiritcall.SPIRITS else []
	match id:
		"thornveil":
			_barrier(slot, shape, [target], 1, cast)
		"dewfall":
			_heal(slot, shape, _allies(shape, target), 1, cast)
		"ember_wing":
			_flame(slot, shape, 1, cast)
		"stoneheart":
			_immunity(shape, _allies(shape, target), 1, cast)
		"greyveil":
			_greyveil(slot, shape, target, cast)
		"convergence_chorus":
			called = _chorus(slot, shape)
		"rootsong":
			_heal(slot, shape, _allies(shape, target), 1, cast)
			for spirit: String in BattleSpiritcall.SPIRITS:
				BattleSpiritcall.add_favor(spirit, int(ability.get("favor_gain", 0)))
	BattleSpiritcall.mark_used(state, slot, ability, called)


# ---------- Each spirit ----------
#
# Each takes the spirit's [param shape], its form for this cast, and returns
# whether it landed on anything: the Chorus counts a spirit as called only then.


## A thorn barrier on each of [param slots], at 1/[param divisor] of the
## spirit's counter (the Chorus halves it, and drops Deeproot Veil's reduction).
func _barrier(slot: int, shape: Dictionary, slots: Array, divisor: int, cast: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var pct: int = int(shape.get("counter_pct", 0)) / divisor
	var cut: int = int(shape.get("reduction_pct", 0)) if divisor == 1 else 0
	var landed: bool = false
	for i: Variant in slots:
		var turns: int = int(shape.get("turns", 0))
		landed = (
			BattleSpiritcall.grant_barrier(state, int(i), slot, pct, cut, turns, cast) or landed
		)
	return landed


## One heal roll at 1/[param divisor] of the spirit's power, landed on each of
## [param slots] with the cures its form carries. Healing an ally who was below
## 25% HP is in harmony.
func _heal(slot: int, shape: Dictionary, slots: Array, divisor: int, cast: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var power: int = int(shape.get("power", 0)) / divisor
	var amount: int = DamageCalc.calculate_healing(state.get_effective_stat(slot, "mag"), power)
	var landed: bool = false
	for i: Variant in slots:
		var m: Dictionary = state.get_member(int(i))
		var low: bool = int(m.get("current_hp", 0)) * LOW_HP_DIVISOR < int(m.get("max_hp", 0))
		var healed: int = state.heal(int(i), amount)
		if healed > 0:
			landed = true
			_battle.damage_dealt.emit("party_%d" % int(i), healed, "heal")
			if low:
				BattleSpiritcall.harmony(cast)
		for status: Variant in shape.get("cures", []):
			landed = StatusGuard.cure(state, int(i), String(status)) or landed
	return landed


## Flame at 1/[param divisor] of the spirit's power on every enemy, with its
## Burn rider at full potency only (the Chorus's component carries none).
## Landing on an enemy weak to Flame is in harmony.
func _flame(slot: int, shape: Dictionary, divisor: int, cast: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var power: int = int(shape.get("power", 0)) / divisor
	var element: String = shape.get("element", "flame")
	var rider: Dictionary = shape.get("rider", {}) if divisor == 1 else {}
	var mag: int = state.get_effective_stat(slot, "mag")
	var enemies: Array[Node] = _battle.get_enemies()
	var landed: bool = false
	for idx: int in range(enemies.size()):
		var enemy: Node = enemies[idx]
		if not enemy.is_alive or enemy.get_meta("untargetable", false):
			continue
		var weak: bool = enemy.get_element_multiplier(element) > 1.0
		var r: Dictionary = BattleActions.apply_magic_to_enemy(
			state, slot, mag, power, element, enemy, idx
		)
		if not _show_strike(slot, r, idx):
			continue
		landed = true
		if weak:
			BattleSpiritcall.harmony(cast)
		if enemy.is_alive and not rider.is_empty():
			_burn(slot, rider, enemy)
	return landed


## Status immunity on each of [param slots], for 1/[param divisor] of the
## spirit's turns.
func _immunity(shape: Dictionary, slots: Array, divisor: int, cast: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var turns: int = int(shape.get("immunity_turns", 0)) / divisor
	var landed: bool = false
	for i: Variant in slots:
		landed = BattleSpiritcall.grant_immunity(state, int(i), turns, cast) or landed
	return landed


## Greyveil on the enemy under cursor [param cursor]: non-elemental magic that
## ignores MDEF, so no weakness or resistance moves it; Duskbreaker doubles it
## again on a Pallor-type enemy (abilities.md § Damage Magnitudes, "an effective
## 112"). Landing on a Pallor is in harmony. Duskbreaker's 60% dispel of
## "Pallor buffs" is not built: no document says which buffs those are.
func _greyveil(slot: int, shape: Dictionary, cursor: int, cast: Dictionary) -> void:
	var state: Node = _battle.get_battle_state()
	var enemies: Array[Node] = _battle.get_enemies()
	var idx: int = BattleActions.resolve_enemy_target(maxi(0, cursor), enemies)
	if idx < 0:
		return
	var enemy: Node = enemies[idx]
	var pallor: bool = enemy.get_type() == "pallor"
	var r: Dictionary = {"hit": false, "damage": 0, "type": "miss"}
	var spd: int = state.get_effective_stat(slot, "spd")
	var target_spd: int = int(enemy.get_stats().get("spd", 0))
	if DamageCalc.roll_hit(spd, target_spd) and not DamageCalc.roll_evasion(target_spd):
		var mults: Array = [BattleDamageMods.dealt_mult(state.get_member(slot))]
		if pallor:
			mults.append(float(shape.get("pallor_mult", 1)))
		var mdef: int = 0 if shape.get("ignores_mdef", false) else enemy.get_stats().get("mdef", 0)
		var dmg: int = DamageCalc.calculate_magic(
			state.get_effective_stat(slot, "mag"),
			int(shape.get("power", 0)),
			mdef,
			1.0,
			1.0,
			mults,
			[]
		)
		enemy.take_damage(dmg)
		r = {"hit": true, "damage": dmg, "type": "magic"}
	if _show_strike(slot, r, idx) and pallor:
		BattleSpiritcall.harmony(cast)


## Convergence Chorus ([param shape]): each learned spirit of CHORUS_SPIRITS at
## 50% of its one quantity, at its own Favor, broadened to the whole side. No
## component earns Favor. Returns the spirits whose component landed, which the
## battle counts as called.
func _chorus(slot: int, shape: Dictionary) -> Array:
	var state: Node = _battle.get_battle_state()
	var none: Dictionary = BattleSpiritcall.new_cast(state, slot, "")
	var party: Array = _allies({"target": "all_allies"}, -1)
	var landed: Array = []
	var learned: Array = _learned(state.get_member(slot))
	for spirit: String in CHORUS_SPIRITS:
		if not spirit in learned:
			continue
		var source: Dictionary = BattleSpiritcall.form(_torren_ability(spirit))
		var took: bool = false
		match spirit:
			"ember_wing":
				took = _flame(slot, source, 2, none)
			"dewfall":
				took = _heal(slot, source, party, 2, none)
			"thornveil":
				source["turns"] = int(shape.get("barrier_turns", 0))
				took = _barrier(slot, source, party, 2, none)
			"stoneheart":
				took = _immunity(source, party, 2, none)
		if took:
			landed.append(spirit)
	return landed


# ---------- Internals ----------


## Ember Wing's Burn [param rider] on [param enemy], which its damage has
## already landed on: the base form's 40% roll (BattleActions.roll_status_rider),
## or Inferno Gale's guaranteed Burn, which an immune enemy still refuses.
func _burn(slot: int, rider: Dictionary, enemy: Node) -> void:
	var status: String = String(rider.get("status", ""))
	if not rider.get("guaranteed", false):
		BattleActions.roll_status_rider(_battle.get_battle_state(), slot, rider, enemy)
	elif not enemy.is_immune_to_status(status):
		enemy.apply_status(status, StatusEffects.default_duration(status))


## Show strike [param r] from [param slot] on enemy [param idx], booking threat
## and a kill as a spell's damage is. Returns whether damage landed.
func _show_strike(slot: int, r: Dictionary, idx: int) -> bool:
	var dtype: String = r.get("type", "miss")
	var target: String = "enemy_%d" % idx
	if dtype == "immune" or dtype == "miss":
		_battle.damage_dealt.emit(target, 0, dtype)
		return false
	if dtype == "absorb":
		_battle.damage_dealt.emit(target, int(r.get("damage", 0)), "heal")
		return false
	var dmg: int = int(r.get("damage", 0))
	_battle.get_battle_state().add_threat(slot, dmg)  # GAP-009 highest-threat
	_battle.damage_dealt.emit(target, dmg, "magic")
	if not _battle.get_enemies()[idx].is_alive:
		_battle.combatant_died.emit(target)
		var atb: Node = _battle.get_atb()
		if atb != null:
			atb.remove_combatant(target)
	return true


## The party slots [param ability] lands on in its current form: every living
## ally for an all-allies one, else [param target].
func _allies(ability: Dictionary, target: int) -> Array:
	if BattleSpiritcall.target_of(ability) != "all_allies":
		return [target]
	var slots: Array = []
	for i: int in range(4):
		if _battle.get_battle_state().get_member(i).get("is_alive", false):
			slots.append(i)
	return slots


## The spirits Torren at [param member] has learned, by ability id.
func _learned(member: Dictionary) -> Array:
	var data: Dictionary = member.get("character_data", {})
	var level: int = int(data.get("level", 1))
	return AbilityHelpers.get_known_abilities("torren", level).map(
		func(a: Dictionary) -> String: return String(a.get("id", ""))
	)


## Torren's ability [param id] from torren.json.
static func _torren_ability(id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("torren"):
		if a is Dictionary and (a as Dictionary).get("id", "") == id:
			return a
	return {}


func _on_flee_result(success: bool) -> void:
	if success:
		BattleSpiritcall.on_fled(_battle.get_battle_state())
