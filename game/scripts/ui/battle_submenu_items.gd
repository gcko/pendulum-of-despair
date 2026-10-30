extends RefCounted
## What each battle sub-menu lists (ui-design.md § 2.7 Battle Sub-Menus): the
## entries for Magic, Item and the character's unique command, each as
## {label, command, target_type, enabled}. Pure static; the command menu owns
## the cursor and the input, this owns the contents.
##
## [param member] is the actor's BattleState record — MP for affordability and
## statuses for what a status blocks; [param character_data] carries the
## character's id and level.

const SpellHelpers := preload("res://scripts/ui/spell_helpers.gd")
const InvHelpers := preload("res://scripts/util/inventory_helpers.gd")
const AbilityHelpers := preload("res://scripts/ui/ability_helpers.gd")
const AbilityCommand := preload("res://scripts/combat/battle_ability_command.gd")
const MagicCommand := preload("res://scripts/combat/battle_magic_command.gd")
const TricksCommand := preload("res://scripts/combat/battle_tricks_command.gd")


## The character's known spells (GAP-001), each routing a
## {"type": "magic", "spell": <spell_dict>} command; spells the character
## cannot afford, and every spell while a status blocks casting, are disabled.
## The cost shown and checked is the one the cast charges
## (SpellHelpers.get_mp_cost). Mirrors menu_magic's data access.
static func magic(character_data: Dictionary, member: Dictionary) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	var can_cast: bool = magic_command_enabled(member)
	for spell_v: Variant in SpellHelpers.get_known_spells(
		_id(character_data), _level(character_data)
	):
		if not spell_v is Dictionary:
			continue
		var spell: Dictionary = spell_v
		var cost: int = SpellHelpers.get_mp_cost(spell, _id(character_data))
		var entry: Dictionary = {
			"label": "%s  %d MP" % [spell.get("name", "Spell"), cost],
			"command": {"type": "magic", "spell": spell},
			"target_type": spell.get("target", "single_enemy"),
			"enabled": can_cast and int(member.get("current_mp", 0)) >= cost,
		}
		items.append(entry)
	return items


## The character's known unique-command abilities (GAP-002), each routing a
## {"type": "ability", "ability": <dict>} command. One is selectable when
## BattleAbilityCommand can issue it now and the member can pay for it, so
## unaffordable costs gray out as Magic's do, and so do abilities whose command
## is not built yet (#158 slices b-f). A Trick also grays while it cools down or,
## for a steal Trick, while Sable stands in the back row (BattleTricks.can_issue).
## Shiv is listed once bare and once per item Sable holds to throw, and Wild
## Card asks for one enemy when she holds nothing (BattleTricksCommand).
static func abilities(character_data: Dictionary, member: Dictionary) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for ability: Dictionary in known_abilities(character_data):
		var usable: bool = (
			AbilityCommand.is_available(member, ability) and AbilityCommand.can_pay(member, ability)
		)
		var entry: Dictionary = {
			"label": "%s  %s" % [ability.get("name", ""), AbilityHelpers.format_cost(ability)],
			"command": {"type": "ability", "ability": ability},
			"target_type": TricksCommand.target_type(member, ability),
			"enabled": usable,
		}
		items.append(entry)
		if ability.get("id", "") == "shiv":
			items.append_array(_throws(member, entry))
	return items


## Shiv's throw entries, one per distinct item in [param member]'s Stolen Goods,
## each the bare [param shiv] entry carrying the item to throw.
static func _throws(member: Dictionary, shiv: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var seen: Array[String] = []
	for item_id: Variant in member.get("stolen_goods", []):
		if String(item_id) in seen:
			continue
		seen.append(String(item_id))
		var entry: Dictionary = shiv.duplicate(true)
		entry["label"] = "Shiv: %s" % BattleTricks.item_name(String(item_id))
		entry["command"]["throw_item"] = String(item_id)
		out.append(entry)
	return out


## The party's battle-usable items (GAP-019). Battle consumables and
## battle-usable crafting materials share one list because InventoryHelpers
## gives them one shape; each entry routes an {"type": "item", "item": <dict>}
## command, as the magic list does.
static func items() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item: Dictionary in InvHelpers.build_battle_item_list():
		var entry: Dictionary = {
			"label": "%s  :%d" % [item.get("name", "Item"), item.get("quantity", 0)],
			"command": {"type": "item", "item": item},
			"target_type": item.get("target", "single_ally"),
			"enabled": true,
		}
		out.append(entry)
	return out


## The character's known abilities that can be issued in battle: passives
## (cost_type "none") are never on the list.
static func known_abilities(character_data: Dictionary) -> Array:
	return AbilityHelpers.get_known_abilities(_id(character_data), _level(character_data)).filter(
		func(a: Dictionary) -> bool: return a.get("cost_type", "") != "none"
	)


## Whether the Magic command itself is selectable. It grays out while a status
## blocks casting — Silence (magic.md § Status Effect Reference) — and the
## battle refuses the cast on the same rule (BattleMagicCommand.can_cast).
static func magic_command_enabled(member: Dictionary) -> bool:
	return MagicCommand.can_cast(member)


## Whether the unique command itself is selectable. It grays out when a status
## blocks every built ability — Cael's Rally while he is Silenced
## (ui-design.md § 2.7). A character with nothing built yet keeps it open,
## listing its abilities disabled.
static func ability_command_enabled(character_data: Dictionary, member: Dictionary) -> bool:
	var built: Array = known_abilities(character_data).filter(
		func(a: Dictionary) -> bool: return AbilityCommand.is_built(a)
	)
	return (
		built.is_empty()
		or built.any(func(a: Dictionary) -> bool: return AbilityCommand.is_available(member, a))
	)


## Live battle character_data is PartyState's member shape, keyed
## "character_id"; raw character JSON uses "id".
static func _id(character_data: Dictionary) -> String:
	return character_data.get("character_id", character_data.get("id", ""))


static func _level(character_data: Dictionary) -> int:
	return int(character_data.get("level", 1))
