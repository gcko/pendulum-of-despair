class_name FormationHelpers
extends RefCounted
## Formation ordering: resolving the active/reserve index lists in a formation
## dictionary against the members array, and reordering them.
##
## Extracted from inventory_helpers.gd (GAP-087).


## Get active party members by resolving formation indices into the members array.
static func get_active_members(
	members: Array[Dictionary],
	formation: Dictionary,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var active: Array = formation.get("active", [])
	for idx: Variant in active:
		var i: int = int(idx) if idx is int or idx is float else -1
		if i >= 0 and i < members.size():
			result.append(members[i])
	return result


## Get reserve (non-active) members from a members array and formation dict.
static func get_reserve_members(
	members: Array[Dictionary],
	formation: Dictionary,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var active_indices: Array = formation.get("active", [])
	var int_active: Array[int] = []
	for idx: Variant in active_indices:
		if idx is int or idx is float:
			int_active.append(int(idx))
	for i: int in range(members.size()):
		if i not in int_active:
			result.append(members[i])
	return result


## Build ordered list: active first, then reserve. _formation_index matches
## the index used by swap_formation — both use the same ordering contract.
static func build_formation_list(members: Array, formation: Dictionary) -> Array:
	var result: Array = []
	var active: Array = formation.get("active", [])
	var int_active: Array[int] = []
	for a: Variant in active:
		if a is int or a is float:
			int_active.append(int(a))
	for idx: int in int_active:
		if idx >= 0 and idx < members.size():
			var m: Dictionary = members[idx].duplicate()
			m["_is_active"] = true
			m["_formation_index"] = result.size()
			result.append(m)
	for i: int in range(members.size()):
		if i not in int_active:
			var m: Dictionary = members[i].duplicate()
			m["_is_active"] = false
			m["_formation_index"] = result.size()
			result.append(m)
	return result


static func swap_formation(members: Array, formation: Dictionary, idx_a: int, idx_b: int) -> void:
	var active: Array = formation.get("active", [])
	var order: Array = []
	for a: Variant in active:
		if a is int or a is float:
			order.append(int(a))
	for i: int in range(members.size()):
		if i not in order:
			order.append(i)
	if idx_a < 0 or idx_b < 0 or idx_a >= order.size() or idx_b >= order.size() or idx_a == idx_b:
		return
	var tmp: int = order[idx_a]
	order[idx_a] = order[idx_b]
	order[idx_b] = tmp
	var new_active: Array[int] = []
	for i: int in range(mini(active.size(), order.size())):
		new_active.append(order[i])
	formation["active"] = new_active
