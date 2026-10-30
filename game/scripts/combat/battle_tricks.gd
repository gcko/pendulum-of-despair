class_name BattleTricks
extends RefCounted
## Sable's Tricks (GAP-002, #158 slice d): the Stolen Goods pool, stealing,
## cooldowns, the front-row gate and Unbreakable Thread. Pure static rules over
## BattleState's member records, reached through BattleState's ability-hook
## fan-out (on_turn_end counts cooldowns, on_damage is Unbreakable Thread, the
## rest neutral) and from BattleAbilityCommand, which issues the Tricks and pays
## their MP and cooldown. BattleTricksCommand resolves what each one does.
##
## Design law: abilities.md § Sable — Tricks and § Damage Magnitudes, with the
## readings recorded there from #158 and #447. Filch tries the common tier, then
## the rare one (2026-04-02-enemy-data-json-design.md § Steal Mapping Rules),
## each at its rate times clamp(1 + (Sable SPD - enemy SPD) / 100, 0.5, 1.5);
## Ransack takes 70% of that, and an enemy can be robbed only once. A cooldown
## counts Sable's own turns: one of N turns keeps the Trick out of the menu for
## her next N turns.
##
## Sable's record carries her Stolen Goods, oldest first, in
## member["stolen_goods"] (BattleState gives every member the list), and her
## cooldowns and spent Thread in member["tricks"]: {cooldowns: {id: turns},
## thread_spent: bool}. A stolen item goes into the party inventory when it is
## taken (PartyState.add_item), so one still held when the battle ends is kept;
## a Trick that uses one consumes it from the inventory too.
##
## Not built here, and why (each needs a value or a seam no document gives):
## Misdirect, which needs the enemy's target choice and which ally it turns to;
## Smokescreen's Speed rider, since nothing names which items are "Forgewright
## components"; the Pallor trial's doubled cooldowns and halved Filch, since no
## battle knows it is that trial.

const InventoryHelpers = preload("res://scripts/util/inventory_helpers.gd")
const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")
const EnemyRecord = preload("res://scripts/entities/enemy_record.gd")

## Stolen items Sable can hold at once (abilities.md § Sable — Tricks).
const POOL_LIMIT: int = 3

## Ransack's steal chance as a percentage of Filch's ("70% of normal").
const RANSACK_RATE_PCT: int = 70

## The meta an enemy carries once something has been stolen from it.
const ROBBED_META: String = "robbed"

## Filch's speed factor: 1 + (Sable SPD - enemy SPD) / SPD_DIVISOR, clamped.
const SPD_DIVISOR: float = 100.0
const STEAL_MULT_MIN: float = 0.5
const STEAL_MULT_MAX: float = 1.5

## Smokescreen: every enemy's physical hit rate times accuracy_mult for turns
## of its own, carried as a debuff on the enemy's ACCURACY_STAT
## (BattleDamageMods.accuracy_mult reads it).
const SMOKESCREEN: Dictionary = {"accuracy_mult": 0.7, "turns": 2}
const ACCURACY_STAT: String = "accuracy"

## Wild Card's random debuff on the 2- and 3-item branches, and the 3-item
## branch's heal as a percentage of each ally's max HP.
const WILD_CARD: Dictionary = {
	"debuffs": ["poison", "sleep", "silence", "blind", "slow"],
	"heal_pct": 10,
}

## The Tricks this slice resolves. Unbreakable Thread is a passive and is never
## issued; it works through on_damage.
const BUILT: Array[String] = ["filch", "smokescreen", "shiv", "ransack", "wild_card"]

## The one rule for which held item supplies Wild Card's element that this
## build knows, as sable.json's item_branch_element_pick names it (#447).
const PICK_MOST_RECENT: String = "most_recent_elemental"

# ---------- The Stolen Goods pool ----------


## Sable's held Stolen Goods, oldest first, from her record [param m]. An item
## the party has since used from the inventory is no longer held, so the list is
## trimmed to the stock, the oldest dropped first. Reads only; goods() also
## writes the trimmed list back.
static func held(m: Dictionary) -> Array[String]:
	var raw: Array[String] = []
	raw.assign(m.get("stolen_goods", []))
	var kept: Array[String] = []
	var counted: Dictionary = {}
	for i: int in range(raw.size() - 1, -1, -1):
		var item_id: String = raw[i]
		counted[item_id] = int(counted.get(item_id, 0)) + 1
		if int(counted[item_id]) <= _stock(item_id):
			kept.push_front(item_id)
	return kept


## Sable's held Stolen Goods at [param slot] (held), with her record trimmed to
## them.
static func goods(state: Node, slot: int) -> Array[String]:
	var m: Dictionary = state.get_member(slot)
	if m.is_empty():
		return [] as Array[String]
	var kept: Array[String] = held(m)
	if kept != Array(m.get("stolen_goods", [])):
		m["stolen_goods"] = kept
	return kept.duplicate()


## Sable at [param slot] takes [param item_id], into the party's own bag for it
## (receive). An item, as opposed to a key item or equipment, also joins her
## Stolen Goods while she holds fewer than POOL_LIMIT.
static func add_goods(state: Node, slot: int, item_id: String) -> void:
	if not receive(item_id):
		return
	var list: Array[String] = goods(state, slot)
	if list.size() >= POOL_LIMIT:
		return
	list.append(item_id)
	state.get_member(slot)["stolen_goods"] = list
	state.ability_state_changed.emit(slot)


## Put a stolen [param item_id] where the party keeps its kind: a key item with
## the key items, equipment with the owned equipment, anything else in the item
## inventory. Returns true for an item, which Sable can also hold and use; a key
## item or equipment never enters the Stolen Goods (orchestrator reading on
## #158), so it cannot be thrown or spent by Wild Card.
static func receive(item_id: String) -> bool:
	if not _key_item(item_id).is_empty():
		PartyState.add_key_item(item_id)
		return false
	if not InventoryHelpers.lookup_equipment(item_id).is_empty():
		PartyState.add_equipment(item_id)
		return false
	PartyState.add_item(item_id, 1)
	return true


## Use up [param item_id] from Sable's Stolen Goods and the inventory. Returns
## false, using nothing, when she does not hold it.
static func spend_goods(state: Node, slot: int, item_id: String) -> bool:
	var list: Array[String] = goods(state, slot)
	var at: int = list.rfind(item_id)
	if at < 0 or not PartyState.consume_item(item_id):
		return false
	list.remove_at(at)
	state.get_member(slot)["stolen_goods"] = list
	state.ability_state_changed.emit(slot)
	return true


## The element a thrown [param item_id] carries, read from its [param field]
## (sable.json's thrown_item_element_field or item_branch_element_field), or ""
## (items.md § Thrown-Item Elements: an item without the field is non-elemental).
static func thrown_element(item_id: String, field: String) -> String:
	var raw: Variant = InventoryHelpers.lookup_material(item_id).get(field)
	return String(raw) if raw is String else ""


## Wild Card's element for the Stolen Goods [param list], oldest first, by
## [param ability]'s item_branch_element_pick and item_branch_element_field:
## the most recently stolen item that has one, or "" when none does (#447).
static func wild_card_element(list: Array[String], ability: Dictionary) -> String:
	var pick: String = String(ability.get("item_branch_element_pick", ""))
	if pick != PICK_MOST_RECENT:
		push_error("BattleTricks: unknown item_branch_element_pick '%s'" % pick)
		return ""
	var field: String = String(ability.get("item_branch_element_field", ""))
	for i: int in range(list.size() - 1, -1, -1):
		var element: String = thrown_element(list[i], field)
		if not element.is_empty():
			return element
	return ""


## A stolen item's display name, from whichever catalog holds it: items, key
## items or equipment.
static func item_name(item_id: String) -> String:
	for item: Dictionary in [
		InventoryHelpers.lookup_material(item_id),
		InventoryHelpers.lookup_consumable(item_id),
		_key_item(item_id),
		InventoryHelpers.lookup_equipment(item_id),
	]:
		if item.has("name"):
			return String(item["name"])
	return item_id.capitalize()


# ---------- Stealing ----------


## Filch's multiplier on a steal tier's rate for Sable's [param sable_spd]
## against [param enemy_spd], scaled to [param rate_pct] of it (Ransack's 70).
static func steal_mult(sable_spd: int, enemy_spd: int, rate_pct: int = 100) -> float:
	var spd: float = clampf(
		1.0 + (sable_spd - enemy_spd) / SPD_DIVISOR, STEAL_MULT_MIN, STEAL_MULT_MAX
	)
	return spd * rate_pct / 100.0


## Sable at [param slot] tries to steal from [param enemy] at [param rate_pct]
## of Filch's chance: the common tier, then the rare one. Returns the item taken,
## which is now hers (add_goods), or "" when she took nothing. An enemy is robbed
## once: after any successful steal from it, every later attempt misses
## (abilities.md § Sable — Tricks, rulings).
static func steal(state: Node, slot: int, enemy: Node, rate_pct: int = 100) -> String:
	if enemy.get_meta(ROBBED_META, false):
		return ""
	var mult: float = steal_mult(
		state.get_effective_stat(slot, "spd"), int(enemy.get_stats().get("spd", 0)), rate_pct
	)
	for tier: String in ["common", "rare"]:
		var roll: Dictionary = EnemyRecord.roll_steal(enemy.enemy_data, tier, mult)
		if roll["success"]:
			enemy.set_meta(ROBBED_META, true)
			add_goods(state, slot, roll["item_id"])
			return roll["item_id"]
	return ""


# ---------- Issuing ----------


## Whether [param member] could issue [param ability] now, cost aside: it is off
## cooldown, a steal Trick needs the front row, and Shiv can throw only what she
## holds (checked by the command, which knows the item).
static func can_issue(member: Dictionary, ability: Dictionary) -> bool:
	if cooldown_left(member, String(ability.get("id", ""))) > 0:
		return false
	return ability.get("row_restriction") != "front" or member.get("row", "front") == "front"


## The Sable turns [param ability_id] still waits before [param member] can use it.
static func cooldown_left(member: Dictionary, ability_id: String) -> int:
	return int(member.get("tricks", {}).get("cooldowns", {}).get(ability_id, 0))


## [param ability]'s cooldown in Sable's turns: its data's, or its
## cooldown_reduced once the cooldown_reduced_event is set (Wild Card's 4 after
## her trial, abilities.md § Sable — Tricks, "Story Integration").
static func cooldown_of(ability: Dictionary) -> int:
	var event: String = String(ability.get("cooldown_reduced_event", ""))
	if not event.is_empty() and EventFlags.get_flag(event):
		return int(ability.get("cooldown_reduced", 0))
	var raw: Variant = ability.get("cooldown")
	return int(raw) if raw != null else 0


## Start [param ability]'s cooldown on [param slot]. Issued inside her turn, it
## gets one more, because that turn's end would otherwise spend one.
static func start_cooldown(state: Node, slot: int, ability: Dictionary) -> void:
	var turns: int = cooldown_of(ability)
	if turns <= 0:
		return
	var m: Dictionary = state.get_member(slot)
	var cooldowns: Dictionary = _record(m).get_or_add("cooldowns", {})
	cooldowns[ability["id"]] = turns + (1 if m.get("turn_open", false) else 0)
	state.ability_state_changed.emit(slot)


## Throw a Smokescreen over [param enemies]: every living one.
static func smokescreen(enemies: Array[Node]) -> void:
	for enemy: Node in enemies:
		if enemy.is_alive:
			enemy.apply_buff(
				ACCURACY_STAT, float(SMOKESCREEN["accuracy_mult"]), int(SMOKESCREEN["turns"])
			)


# ---------- BattleState ability hooks ----------


## Damage about to land on [param slot]. Unbreakable Thread turns the battle's
## first fatal blow on any ally into one that leaves 1 HP, while Sable stands
## and has learned it. Returns the damage to apply.
static func on_damage(state: Node, slot: int, amount: int) -> int:
	var hp: int = int(state.get_member(slot).get("current_hp", 0))
	if amount < hp or hp <= 0:
		return amount
	var sable: int = _thread_holder(state)
	if sable < 0:
		return amount
	_record(state.get_member(sable))["thread_spent"] = true
	state.ability_state_changed.emit(sable)
	return hp - 1


## End of a member's turn: count each of its cooldowns down.
static func on_turn_end(state: Node, slot: int) -> void:
	var cooldowns: Dictionary = state.get_member(slot).get("tricks", {}).get("cooldowns", {})
	for ability_id: String in cooldowns.keys():
		cooldowns[ability_id] = maxi(0, int(cooldowns[ability_id]) - 1)
		if cooldowns[ability_id] == 0:
			cooldowns.erase(ability_id)
			state.ability_state_changed.emit(slot)


static func on_turn_begin(_state: Node, _slot: int) -> Array:
	return []


static func on_fainted(_state: Node, _slot: int) -> void:
	pass


static func on_status(_state: Node, _slot: int, _status: String) -> void:
	pass


static func stat_pct(_m: Dictionary, _stat: String) -> int:
	return 0


# ---------- Internals ----------


## The slot of a standing Sable who has learned Unbreakable Thread and not yet
## spent it this battle, or -1.
static func _thread_holder(state: Node) -> int:
	for i: int in range(4):
		var m: Dictionary = state.get_member(i)
		if m.get("character_id", "") != "sable" or not m.get("is_alive", false):
			continue
		if m.get("tricks", {}).get("thread_spent", false):
			return -1
		var level: int = int(m.get("character_data", {}).get("level", 1))
		for a: Variant in AbilityHelpers.get_known_abilities("sable", level):
			if (a as Dictionary).get("id", "") == "unbreakable_thread":
				return i
	return -1


## Sable's "tricks" record, created on first use.
static func _record(m: Dictionary) -> Dictionary:
	if not m.has("tricks"):
		m["tricks"] = {}
	return m["tricks"]


## The key item [param item_id]'s catalog entry, or {}.
static func _key_item(item_id: String) -> Dictionary:
	for item: Variant in DataManager.load_items("key_items"):
		if item is Dictionary and (item as Dictionary).get("id", "") == item_id:
			return item
	return {}


## How many of [param item_id] the party holds.
static func _stock(item_id: String) -> int:
	return (
		int(PartyState.get_consumables().get(item_id, 0))
		+ int(PartyState.get_materials().get(item_id, 0))
	)
