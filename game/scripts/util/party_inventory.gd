class_name PartyInventory
extends RefCounted
## Carried-goods facet of PartyState: the consumable and material stacks, key
## items, the purse, and field use of a consumable.
##
## Extracted from party_state.gd (GAP-087). PartyState keeps the public API,
## owns the `inventory` dictionary and the `inventory_changed` signal, and
## forwards here.

const Helpers = preload("res://scripts/util/inventory_helpers.gd")

var _party: Node


func _init(party: Node) -> void:
	_party = party


func consumables() -> Dictionary:
	return _party.inventory.get("consumables", {})


## Held crafting materials as {item_id: quantity} (items.md § Crafting Materials).
func materials() -> Dictionary:
	return _party.inventory.get("materials", {})


func key_items() -> Array:
	return _party.inventory.get("key_items", [])


## Whether the party holds a key item (items.md § Story Items). Key items are
## unique, so this is the only ownership question they answer.
func has_key_item(item_id: String) -> bool:
	return item_id in key_items()


func add_key_item(item_id: String) -> void:
	var items: Variant = _party.inventory.get("key_items", [])
	if not items is Array:
		items = []
	if item_id not in items:
		items.append(item_id)
		_party.inventory["key_items"] = items
		_party.inventory_changed.emit()


func remove_key_item(item_id: String) -> void:
	var items: Variant = _party.inventory.get("key_items", [])
	if not items is Array:
		return
	if item_id in items:
		items.erase(item_id)
		_party.inventory["key_items"] = items
		_party.inventory_changed.emit()


## Add a quantity item to the inventory, routed to its bucket: crafting
## materials to `materials`, everything else to `consumables` (GAP-019).
func add_item(item_id: String, quantity: int) -> void:
	if quantity <= 0 or item_id.is_empty():
		return
	var bucket: String = Helpers.bucket_for_item(item_id)
	var items: Dictionary = _party.inventory.get(bucket, {})
	items[item_id] = items.get(item_id, 0) + quantity
	_party.inventory[bucket] = items
	_party.inventory_changed.emit()


## Remove a quantity item from whichever bucket it belongs to.
func remove_item(item_id: String, quantity: int) -> void:
	if quantity <= 0 or item_id.is_empty():
		return
	var bucket: String = Helpers.bucket_for_item(item_id)
	var items: Dictionary = _party.inventory.get(bucket, {})
	items[item_id] = maxi(0, items.get(item_id, 0) - quantity)
	if items[item_id] <= 0:
		items.erase(item_id)
	_party.inventory[bucket] = items
	_party.inventory_changed.emit()


## Consume one unit of an item from its own bucket. Returns true if consumed.
## Battle use of a Drake Fang spends it from the material stack (items.md
## § Drake Fang Special Case), which is the same routing rule adds use.
func consume_item(item_id: String) -> bool:
	var bucket: String = Helpers.bucket_for_item(item_id)
	var items: Dictionary = _party.inventory.get(bucket, {})
	var qty: int = items.get(item_id, 0)
	if qty <= 0:
		return false
	items[item_id] = qty - 1
	if items[item_id] <= 0:
		items.erase(item_id)
	_party.inventory[bucket] = items
	_party.inventory_changed.emit()
	return true


## Use a field consumable on one character. Returns false when the item cannot
## be used here — unknown, not field-usable, save-point-only away from a save
## point, no such target, or the effect would do nothing.
func use_item(item_id: String, target_character_id: String) -> bool:
	var stock: Dictionary = _party.inventory.get("consumables", {})
	if stock.get(item_id, 0) <= 0:
		return false
	var item_data: Dictionary = Helpers.lookup_consumable(item_id)
	if item_data.is_empty() or not item_data.get("usable_in_field", false):
		return false
	if item_data.get("requires_save_point", false) and not _party.is_at_save_point:
		return false
	var target: Dictionary = _party.get_member(target_character_id)
	if target.is_empty():
		return false
	if not Helpers.can_apply_item_effect(item_data, target):
		return false
	# Max HP/MP are derived, never authoritative in storage (save-system.md § 1),
	# so re-derive BEFORE the effect too: a full or percentage restore sizes
	# itself off max_hp, and healing against a stale maximum under-heals.
	_party.refresh_max_hp_mp(target_character_id)
	Helpers.apply_item_effect(item_data, target)
	# A Stat Capsule can raise HP/MP, so re-derive the maxima through the shared
	# recalculation. Idempotent for every other consumable effect.
	_party.refresh_max_hp_mp(target_character_id)
	consume_item(item_id)
	return true


func add_gold(amount: int) -> void:
	if amount > 0:
		_party.gold += amount


func spend_gold(amount: int) -> bool:
	if amount <= 0 or amount > _party.gold:
		return false
	_party.gold -= amount
	return true
