extends RefCounted
## The Combo submenu's list for the party member whose command menu is open
## (abilities.md § Calling a Combo, #176 slice b).
##
## The list depends on who else is ready, and in Active mode the gauges keep
## filling while a menu is open, so a partner can become ready after the turn
## began. BattleUI asks stale() each frame and hands a rebuilt list to the menu
## when the set of full party gauges has changed since the last build.

const SubmenuItems = preload("res://scripts/ui/battle_submenu_items.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

const PARTY_SLOTS: int = 4

var _state: Node
var _atb: Node
var _slot: int = -1
## Which party gauges were full at the last build, one "1" or "0" per slot.
var _ready: String = ""


func _init(state: Node, atb: Node) -> void:
	_state = state
	_atb = atb


## Begin [param slot]'s turn and return its list.
func open(slot: int) -> Array[Dictionary]:
	_slot = slot
	return build()


## The list for the member whose turn it is, as it stands now.
func build() -> Array[Dictionary]:
	_ready = _ready_gauges()
	if _slot < 0:
		return []
	return SubmenuItems.combos(_state, _atb, _slot)


## Whether a party gauge has filled or emptied since the last build.
func stale() -> bool:
	return _slot >= 0 and _ready_gauges() != _ready


func _ready_gauges() -> String:
	var out: String = ""
	for slot: int in range(PARTY_SLOTS):
		out += "1" if _atb.get_gauge("party_%d" % slot) >= ATBSystem.GAUGE_MAX else "0"
	return out
