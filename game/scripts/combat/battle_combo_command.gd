class_name BattleComboCommand
extends RefCounted
## The Combo command in battle: two ready characters act as one (abilities.md
## § 2 Combo Abilities; #176 slice b).
##
## do_combo checks the combo again against the battle as it stands, since a
## partner can be Confused or KO'd after the menu opened. Then it opens the
## partner's turn, so their start-of-turn effects run once as on a turn of their
## own. It splits the MP per combos.json `mp_costs` and resolves the combo. The
## battle manager then closes both turns: both gauges reset and each partner's
## end-of-turn ticks run once. It reads the partner from partner_slot().
##
## Ley Torrent is the one combo built (BattleCombos.BUILT). The others wait for
## slice 176c, each with the sub-ability slice of #158 it draws on.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")
const BattleCombos = preload("res://scripts/combat/battle_combos.gd")
const ModifierAggregator = preload("res://scripts/combat/modifier_aggregator.gd")

## Ley Torrent: "(Maren's Magic + Torren's Magic) x 4. Ignores Magic Defense.
## Generates 30 WG for Maren." The magic formula's base is MAG x power / 4, so
## the partners' combined MAG at power 16 is that MAG x 4, and MDEF is taken as
## 0. The blast is non-elemental and uses the standard hit roll and variance.
const LEY_TORRENT: Dictionary = {"power": 16, "element": "non_elemental", "weave_gain": 30}

var _battle: Node
var _partner: int = -1


func _init(battle: Node) -> void:
	_battle = battle


## The partner's slot in the last combo do_combo performed, whose turn it also
## used; -1 before any.
func partner_slot() -> int:
	return _partner


## Perform the combo in [param command] ({"type": "combo", "combo_id"}) for
## [param actor_id]. Returns false, spending nothing, when it never happened, so
## the caller re-opens the menu: it is not on the actor's list now
## (BattleCombos.combos_for: a partner not ready, Confused, Silenced on a share
## Silence stops), it is not built, its usage condition is unmet, or one
## partner cannot pay their share ("Not enough MP!"). It also stops, spending
## nothing, when the partner's turn start KOs them or ends the battle (a Shock
## Coil felling the last enemy), so a combo never lands from a fallen partner.
func do_combo(actor_id: String, command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var slot: int = actor_id.replace("party_", "").to_int()
	var entry: Dictionary = _entry(state, slot, String(command.get("combo_id", "")))
	if entry.is_empty() or not entry["id"] in BattleCombos.BUILT:
		return false
	if not entry["affordable"]:
		_battle.message.emit("Not enough MP!")
		return false
	if not entry["usable"]:
		return false
	var combo: Dictionary = entry["combo"]
	var slots: Array[int] = entry["slots"]
	_partner = int(entry["partner"])
	_battle.emit_party_events(state.begin_turn(_partner))
	if _battle_over(state) or not _entry(state, slot, entry["id"]).get("usable", false):
		return false
	if not _pay(state, slots, combo):
		_battle.message.emit("Not enough MP!")
		return false
	var names: Array[String] = []
	for i: int in slots:
		names.append(state.get_member(i).get("character_data", {}).get("name", "???"))
	_battle.message.emit("%s and %s use %s!" % [names[0], names[1], combo.get("name", "Combo")])
	match entry["id"]:
		"ley_torrent":
			_ley_torrent(slots)
	return true


## Spend each character at [param slots] their share of [param combo]'s MP.
## Both shares are checked before either is spent, so a refusal spends nothing.
func _pay(state: Node, slots: Array[int], combo: Dictionary) -> bool:
	var characters: Array = combo.get("characters", [])
	var costs: Array[int] = []
	for i: int in range(slots.size()):
		costs.append(int(combo.get("mp_costs", {}).get(characters[i], 0)))
		if int(state.get_member(slots[i]).get("current_mp", 0)) < costs[i]:
			return false
	for i: int in range(slots.size()):
		if not state.spend_mp(slots[i], costs[i]):
			push_error("BattleComboCommand: %s's checked share was refused" % characters[i])
			return false
	return true


## Whether the battle has already been decided: the party wiped, or every enemy
## down or removed from combat, as the battle manager judges it.
func _battle_over(state: Node) -> bool:
	if state.is_party_wiped():
		return true
	return _battle.get_enemies().all(
		func(e: Node) -> bool: return not e.is_alive or e.is_removed_from_combat()
	)


## This turn's combos_for entry for [param combo_id] by [param slot], or {}.
func _entry(state: Node, slot: int, combo_id: String) -> Dictionary:
	for entry: Dictionary in BattleCombos.combos_for(state, _battle.get_atb(), slot):
		if entry["id"] == combo_id:
			return entry
	return {}


## Ley Torrent from Maren and Torren at [param slots] (combos.json order) on
## every targetable enemy. Each partner's Despair cuts the blast: both of them
## deal it, so one Despaired partner takes 20% off and two take 0.8 x 0.8. The
## hit roll is Maren's, who channels it, and so is the threat. Maren's 30 WG
## replaces the cast gain and, like it, needs the blast to land somewhere.
func _ley_torrent(slots: Array[int]) -> void:
	var state: Node = _battle.get_battle_state()
	var maren: int = slots[0]
	var mag: int = (
		state.get_effective_stat(maren, "mag") + state.get_effective_stat(slots[1], "mag")
	)
	var despair: Array = [
		BattleDamageMods.dealt_mult(state.get_member(maren)),
		BattleDamageMods.dealt_mult(state.get_member(slots[1])),
	]
	var landed: bool = false
	var enemies: Array[Node] = _battle.get_enemies()
	for i: int in range(enemies.size()):
		if enemies[i].is_alive and not enemies[i].get_meta("untargetable", false):
			landed = _blast(maren, mag, despair, i) or landed
	if landed:
		state.gain_weave_gauge(maren, int(LEY_TORRENT["weave_gain"]))


## One enemy's share of Ley Torrent: [param mag] through the magic formula at
## Ley Torrent's power with MDEF 0, after the hit roll from [param caster]'s SPD.
## Returns whether it landed (an absorb counts, as it does for a spell).
func _blast(caster: int, mag: int, despair: Array, idx: int) -> bool:
	var enemy: Node = _battle.get_enemies()[idx]
	var spd: int = _battle.get_battle_state().get_effective_stat(caster, "spd")
	var target_spd: int = int(enemy.get_stats().get("spd", 0))
	if not DamageCalc.roll_hit(spd, target_spd) or DamageCalc.roll_evasion(target_spd):
		_battle.damage_dealt.emit("enemy_%d" % idx, 0, "miss")
		return false
	var element: String = LEY_TORRENT["element"]
	var element_mod: float = enemy.get_element_multiplier(element)
	var interaction: float = ModifierAggregator.type_element_multiplier(enemy.get_type(), element)
	var dmg: int = DamageCalc.calculate_magic(
		mag, int(LEY_TORRENT["power"]), 0, element_mod, interaction, despair, []
	)
	if element_mod == 0.0:
		_battle.damage_dealt.emit("enemy_%d" % idx, 0, "immune")
		return false
	if element_mod < 0.0:
		enemy.heal(dmg)
		_battle.damage_dealt.emit("enemy_%d" % idx, dmg, "heal")
		return true
	enemy.take_damage(dmg)
	BattleEnemyHeal.land_spell_damage(_battle, caster, dmg, enemy, idx)
	return true
