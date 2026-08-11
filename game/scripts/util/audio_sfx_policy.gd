class_name AudioSfxPolicy
extends RefCounted
## Which of the 12 SFX slots a new sound may use: a free one, or one it
## outranks (audio.md § 3.2 priority stack, § 3.4 same-ID limit).
##
## Extracted from audio_manager.gd (GAP-087). Pure slot arithmetic over the
## pool the manager owns — no playback happens here.

## Max simultaneous instances of the same SFX ID (per audio.md § 3.4).
const MAX_SAME_SFX: int = 2
## Number of SFX pool slots (matches audio.md § 3.1 SFX budget).
const POOL_SIZE: int = 12


## The meta record for an empty slot.
static func empty_meta(idle_priority: int) -> Dictionary:
	return {"sfx_id": "", "priority": idle_priority, "start_time": 0}


## Whether [param sfx_id] is already playing on as many slots as it may hold.
static func at_same_id_limit(pool: Array, meta: Array, sfx_id: String) -> bool:
	var same_count: int = 0
	for i: int in range(POOL_SIZE):
		if pool[i].playing and meta[i].get("sfx_id") == sfx_id:
			same_count += 1
	return same_count >= MAX_SAME_SFX


## Index of the first idle slot, or -1 when every slot is busy.
static func find_free_slot(pool: Array) -> int:
	for i: int in range(POOL_SIZE):
		if not pool[i].playing:
			return i
	return -1


## Index of the lowest-priority (then oldest) slot [param requested_priority]
## may steal. Returns -1 when no slot ranks below it.
static func find_steal_target(meta: Array, requested_priority: int, idle_priority: int) -> int:
	var lowest_priority: int = requested_priority
	var lowest_idx: int = -1
	for i: int in range(POOL_SIZE):
		var slot_priority: int = int(meta[i].get("priority", idle_priority))
		if slot_priority < lowest_priority:
			lowest_priority = slot_priority
			lowest_idx = i
		elif slot_priority == lowest_priority and lowest_idx != -1:
			if int(meta[i].get("start_time", 0)) < int(meta[lowest_idx].get("start_time", 0)):
				lowest_idx = i
	return lowest_idx
