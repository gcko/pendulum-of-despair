class_name BattleItemCommand
extends RefCounted
## The Item command in battle: resolves one consumable against the party or the
## enemy line and spends it from the inventory.
##
## Extracted from battle_manager.gd (GAP-087) so the manager holds the ATB loop
## and the command dispatch while each command owns its own resolution rules.

const BattleActions = preload("res://scripts/combat/battle_actions.gd")

## Effects that need a living single target before anything else happens.
const LIVING_TARGET_EFFECTS: Array[String] = [
	"restore_mp", "restore_hp_mp", "cure_status", "buff_atk", "buff_mag"
]

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Resolve the item in [param command]. Returns false when nothing happened —
## the caller re-opens the command menu rather than consuming the turn.
func do_item(command: Dictionary) -> bool:
	var state: Node = _battle.get_battle_state()
	var item: Dictionary = command.get("item", {})
	var target_slot: int = command.get("target", 0)
	var effect: String = item.get("effect", "")
	var target_type: String = item.get("target", "single_ally")
	# Pre-validate: single-target effects that require a living target
	if target_type != "all_allies" and effect in LIVING_TARGET_EFFECTS:
		var pre_tgt: Dictionary = state.get_member(target_slot)
		if pre_tgt.is_empty() or not pre_tgt.get("is_alive", false):
			_battle.message.emit("No effect!")
			return false
	match effect:
		"restore_hp":
			if not _restore_hp(item, target_type, target_slot):
				return false
		"revive":
			if not _revive(item, target_slot):
				return false
		"restore_mp":
			_battle.message.emit("Used %s!" % item.get("name", "Item"))
			_restore_mp(item, target_slot)
		"restore_hp_mp":
			_battle.message.emit("Used %s!" % item.get("name", "Item"))
			_restore_hp_mp(item, target_type, target_slot)
		"fixed_damage":
			if not _fixed_damage(item, command):
				return false
		"cure_status":
			_battle.message.emit("Used %s!" % item.get("name", "Item"))
			for sname: String in item.get("cures", []):
				state.remove_status(target_slot, sname)
		"buff_atk":
			_battle.message.emit("Used %s!" % item.get("name", "Item"))
			var raw_atk: Variant = item.get("value")
			var atk_boost: int = int(raw_atk) if raw_atk != null else 10
			state.set_buff(target_slot, "atk_mult", 1.0 + float(atk_boost) / 100.0)
		"buff_mag":
			_battle.message.emit("Used %s!" % item.get("name", "Item"))
			var raw_mag: Variant = item.get("value")
			var mag_boost: int = int(raw_mag) if raw_mag != null else 15
			state.set_buff(target_slot, "mag_mult", 1.0 + float(mag_boost) / 100.0)
		"flee":
			return _flee_item(item)
		_:
			_battle.message.emit("No effect!")
			return false
	var item_id: String = item.get("id", "")
	if not item_id.is_empty():
		PartyState.consume_item(item_id)
	return true


## Heal one or all allies, optionally reviving and clearing status. Returns
## false when no slot in range could take the effect.
func _restore_hp(item: Dictionary, target_type: String, target_slot: int) -> bool:
	var state: Node = _battle.get_battle_state()
	var can_revive: bool = item.get("can_revive", false)
	var slots: Array[int] = _target_slots(target_type, target_slot)
	var any_valid: bool = false
	for slot: int in slots:
		if _can_receive(state.get_member(slot), can_revive):
			any_valid = true
	if not any_valid:
		_battle.message.emit("No effect!")
		return false
	_battle.message.emit("Used %s!" % item.get("name", "Item"))
	for slot: int in slots:
		var tgt_m: Dictionary = state.get_member(slot)
		if not _can_receive(tgt_m, can_revive):
			continue
		var actual: int = state.heal(slot, _hp_amount(item, tgt_m), can_revive)
		if actual > 0:
			_battle.damage_dealt.emit("party_%d" % slot, actual, "heal")
		if item.get("clears_status", false):
			_clear_statuses(slot, tgt_m)
	return true


## Raise a KO'd ally at a percentage of max HP. Returns false if the target is
## not KO'd.
func _revive(item: Dictionary, target_slot: int) -> bool:
	var state: Node = _battle.get_battle_state()
	var rev_m: Dictionary = state.get_member(target_slot)
	if rev_m.is_empty() or rev_m.get("is_alive", true):
		_battle.message.emit("No effect!")
		return false
	_battle.message.emit("Used %s!" % item.get("name", "Item"))
	var raw_rev: Variant = item.get("value")
	var revive_pct: int = int(raw_rev) if raw_rev != null else 25
	var revived_hp: int = int(ceil(float(rev_m.get("max_hp", 1)) * float(revive_pct) / 100.0))
	var actual: int = state.heal(target_slot, clampi(revived_hp, 1, rev_m.get("max_hp", 1)), true)
	if actual > 0:
		_battle.damage_dealt.emit("party_%d" % target_slot, actual, "heal")
	return true


func _restore_mp(item: Dictionary, target_slot: int) -> void:
	var state: Node = _battle.get_battle_state()
	var mp_tgt: Dictionary = state.get_member(target_slot)
	var raw_mp: Variant = item.get("value")
	var mp_amt: int = int(raw_mp) if raw_mp != null else 0
	if item.has("restore_percent"):
		var pct: int = item.get("restore_percent", 100)
		mp_amt = int(float(mp_tgt.get("max_mp", 1)) * float(pct) / 100.0)
	state.restore_mp(target_slot, mp_amt)


func _restore_hp_mp(item: Dictionary, target_type: String, target_slot: int) -> void:
	var state: Node = _battle.get_battle_state()
	for slot: int in _target_slots(target_type, target_slot):
		var tgt_m: Dictionary = state.get_member(slot)
		if tgt_m.is_empty() or not tgt_m.get("is_alive", false):
			continue
		var raw_hpmp: Variant = item.get("value")
		var hp_amt: int = int(raw_hpmp) if raw_hpmp != null else 9999
		var mp_amt: int = hp_amt
		if item.has("restore_percent"):
			var pct: int = item.get("restore_percent", 100)
			hp_amt = int(float(tgt_m.get("max_hp", 1)) * float(pct) / 100.0)
			mp_amt = int(float(tgt_m.get("max_mp", 1)) * float(pct) / 100.0)
		var healed: int = state.heal(slot, hp_amt)
		if healed > 0:
			_battle.damage_dealt.emit("party_%d" % slot, healed, "heal")
		state.restore_mp(slot, mp_amt)
		if item.get("clears_status", false):
			_clear_statuses(slot, tgt_m)


## Drake Fang: a flat hit that ignores DEF and cannot miss
## (items.md § Drake Fang Special Case).
func _fixed_damage(item: Dictionary, command: Dictionary) -> bool:
	var enemies: Array[Node] = _battle.get_enemies()
	var fd_idx: int = BattleActions.resolve_enemy_target(command.get("target", 0), enemies)
	if fd_idx < 0:
		_battle.message.emit("No target!")
		return false
	_battle.message.emit("Used %s!" % item.get("name", "Item"))
	var fd_dmg: int = maxi(0, int(item.get("value", 0)))
	enemies[fd_idx].take_damage(fd_dmg)
	_battle.damage_dealt.emit("enemy_%d" % fd_idx, fd_dmg, "physical")
	if not enemies[fd_idx].is_alive:
		_battle.combatant_died.emit("enemy_%d" % fd_idx)
		_battle.get_atb().remove_combatant("enemy_%d" % fd_idx)
	return true


## Smoke Bomb and friends. Bosses cannot be escaped, so the item is refused
## instead of wasted; otherwise it is spent before the scene transition starts.
func _flee_item(item: Dictionary) -> bool:
	if _battle.is_boss_battle():
		_battle.message.emit("Can't use that here!")
		return false
	_battle.message.emit("Used %s!" % item.get("name", "Item"))
	# Consume before exit — exit_battle triggers scene transition
	var flee_item_id: String = item.get("id", "")
	if not flee_item_id.is_empty():
		PartyState.consume_item(flee_item_id)
	_battle.exit_battle("flee")
	return true


## Whether a slot can take a healing effect: it must exist, and be alive unless
## the item revives.
func _can_receive(member: Dictionary, can_revive: bool) -> bool:
	if member.is_empty():
		return false
	return member.get("is_alive", true) or can_revive


## The HP an item restores to one target — a flat value, or a percentage of
## that target's own maximum.
func _hp_amount(item: Dictionary, target: Dictionary) -> int:
	if item.has("restore_percent"):
		var pct: int = item.get("restore_percent", 100)
		return int(float(target.get("max_hp", 1)) * float(pct) / 100.0)
	var raw_val: Variant = item.get("value")
	return int(raw_val) if raw_val != null else 0


## Strip every status from a slot, walking backwards so removal cannot skip one.
func _clear_statuses(slot: int, member: Dictionary) -> void:
	var statuses: Array = member.get("active_statuses", [])
	for i: int in range(statuses.size() - 1, -1, -1):
		_battle.get_battle_state().remove_status(slot, statuses[i].get("name", ""))


func _target_slots(target_type: String, single_slot: int) -> Array[int]:
	if target_type == "all_allies":
		return [0, 1, 2, 3]
	return [single_slot]
