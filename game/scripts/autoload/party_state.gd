extends Node
## Runtime party/inventory/equipment state. Autoloaded as PartyState.
##
## This script is the facade every other system calls. The rules behind it are
## grouped into collaborators under `scripts/util/` — PartyCrystals,
## PartyRoster, PartyVitals, PartyInventory, PartyEquipment and
## PartyPersistence (GAP-087). The mutable state itself (members, formation,
## inventory, owned_equipment, gold, ley_crystals, puzzle_state) stays here,
## because saves and tests read it directly and the facets are constructed
## lazily around it.
##
## Budget: the facade sits at 64 public methods against `max-public-methods: 65`
## in `.gdlintrc`. Adding a public forward here costs the last slot, so pair any
## addition with a removal or raise the ceiling deliberately — a facade over six
## facets only grows.

signal inventory_changed
signal equipment_changed(character_id: String)

const Helpers = preload("res://scripts/util/inventory_helpers.gd")
const CLASS_TITLES: Dictionary = {
	"edren": "Knight",
	"cael": "Commander",
	"lira": "Engineer",
	"torren": "Sage",
	"sable": "Thief",
	"maren": "Archmage",
}

const STARTING_EQUIPMENT: Dictionary = {
	"edren":
	{
		"weapon": "arcanite_sword_proto",
		"head": "",
		"body": "arcanite_mail_proto",
		"accessory": "",
		"crystal": ""
	},
	"cael": {"weapon": "recruits_claymore", "head": "", "body": "", "accessory": "", "crystal": ""},
	"lira": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
	"sable": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
	"torren": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
	"maren": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
}

const STARTING_CONSUMABLES: Dictionary = {
	"potion": 5,
	"antidote": 2,
}
const STARTING_GOLD: int = 200

var members: Array[Dictionary] = []
var formation: Dictionary = {"active": [], "reserve": [], "rows": {}}
var inventory: Dictionary = {"consumables": {}, "materials": {}, "key_items": []}
var owned_equipment: Array[Dictionary] = []
var gold: int = 0
var playtime: int = 0
var location_name: String = ""
## Player-facing place name for `location_name`'s map, taken from the map's
## `location_name` metadata. The map id is the load key and is never shown;
## this is what the pause menu and the save slots render (ui-design.md § 3.5).
var location_display: String = ""
## Player's pixel position on `location_name`'s map. Only meaningful while
## `has_player_position` is true — see save-system.md § 3.7 (#269).
var player_position: Vector2i = Vector2i.ZERO
## Whether a real player position has been recorded yet. False for a fresh game
## and for saves written before positions were persisted; the loader then uses
## the map's default spawn marker instead.
var has_player_position: bool = false
var is_at_save_point: bool = false
var ley_crystals: Dictionary = {}
var puzzle_state: Dictionary = {}
var _config: Dictionary = {}
var _config_loaded: bool = false
var _crystals: PartyCrystals = null
var _roster: PartyRoster = null
var _vitals: PartyVitals = null
var _items: PartyInventory = null
var _equipment: PartyEquipment = null
var _persistence: PartyPersistence = null


func _ready() -> void:
	_load_config()


func initialize_new_game() -> void:
	members.clear()
	owned_equipment.clear()
	set_next_inst_id(0)
	is_at_save_point = false
	EventFlags.clear_all()
	_get_roster().add_character("edren", 1)
	_get_roster().add_character("cael", 1)
	formation = {
		"active": [0, 1] as Array[int],
		"reserve": [] as Array[int],
		"rows": {"edren": "front", "cael": "front"} as Dictionary,
	}
	inventory = {
		"consumables": STARTING_CONSUMABLES.duplicate(),
		"materials": {} as Dictionary,
		"key_items": [] as Array[String],
	}
	gold = STARTING_GOLD
	playtime = 0
	clear_player_location()
	ley_crystals.clear()
	puzzle_state.clear()


# ---------- Persistence (PartyPersistence) ----------


## Replace all runtime state with the contents of a save dictionary.
func load_from_save(data: Dictionary) -> void:
	_get_persistence().load_from_save(data)


func build_save_data() -> Dictionary:
	return _get_persistence().build_save_data()


## The world block written to a save (save-system.md § 3.7).
func build_world_state() -> Dictionary:
	return _get_persistence().build_world_state()


## Record where the party currently stands, so the next save writes it (#269).
func set_player_location(map_id: String, position: Vector2i) -> void:
	_get_persistence().set_player_location(map_id, position)


## Forget the recorded map and position (new game).
func clear_player_location() -> void:
	_get_persistence().clear_player_location()


## The place name to show the player. Empty when the current map carries no
## `location_name` metadata — the raw map id is a file path and is never a
## substitute for it (ui-design.md § 3.5).
func get_location_display() -> String:
	return location_display


# ---------- Ley Crystals (PartyCrystals) ----------


## Add a Ley Crystal to the collection at Lv1 / 0 XP. No-op if already owned.
func add_ley_crystal(crystal_id: String) -> void:
	_get_crystals().add(crystal_id)


## Get a crystal's runtime state. Returns empty dict if not owned.
func get_crystal_state(crystal_id: String) -> Dictionary:
	return _get_crystals().get_state(crystal_id)


## Add XP to a crystal, auto-leveling when thresholds are crossed.
func add_crystal_xp(crystal_id: String, amount: int) -> void:
	_get_crystals().add_xp(crystal_id, amount)


## Equip a crystal on a character. Swaps if another character has it.
func equip_crystal(character_id: String, crystal_id: String) -> void:
	_get_crystals().equip(character_id, crystal_id)


## Unequip the crystal slot without adding to owned_equipment.
func unequip_crystal(character_id: String) -> String:
	return _get_crystals().unequip(character_id)


## Get all collected crystal IDs.
func get_collected_crystals() -> Array[String]:
	return _get_crystals().collected()


## A worn crystal's stat bonus at its current level, scaled by character level
## for the per-level hp/mp terms.
func get_crystal_stat_bonus(crystal_id: String, stat: String, char_level: int = 1) -> int:
	return _get_crystals().stat_bonus(crystal_id, stat, char_level)


# ---------- Puzzle state ----------


## Set a puzzle state value for a dungeon.
func set_puzzle_state(dungeon_id: String, key: String, value: Variant) -> void:
	if dungeon_id.is_empty() or key.is_empty():
		return
	if not puzzle_state.has(dungeon_id) or not puzzle_state[dungeon_id] is Dictionary:
		puzzle_state[dungeon_id] = {}
	puzzle_state[dungeon_id][key] = value


## Get a puzzle state value. Returns default_value if not set.
func get_puzzle_state(dungeon_id: String, key: String, default_value: Variant = false) -> Variant:
	if not puzzle_state.has(dungeon_id):
		return default_value
	if not puzzle_state[dungeon_id] is Dictionary:
		puzzle_state[dungeon_id] = {}
		return default_value
	return puzzle_state[dungeon_id].get(key, default_value)


## Clear all puzzle state for a dungeon.
func clear_puzzle_state(dungeon_id: String) -> void:
	puzzle_state.erase(dungeon_id)


# ---------- Progression (ProgressionHelpers) ----------


## Apply battle rewards (XP, gold, drops). Returns ProgressionHelpers.distribute_rewards() summary.
func distribute_battle_rewards(rewards: Dictionary) -> Dictionary:
	return ProgressionHelpers.apply_battle_rewards(
		rewards, get_active_party(), get_reserve_party(), add_gold, add_item
	)


# ---------- Derived stats ----------


## Base stats + permanent Stat Capsule gains + equipment/crystal bonus, clamped.
## Delegates the assembly to Helpers so battle stat baking and the level-up
## recalculation share one formula.
func get_effective_stat(character_id: String, stat: String) -> int:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return 0
	return Helpers.compute_effective_stat(m, stat, get_equipment_bonus(character_id, stat))


## Permanent Stat Capsule gain for one stat (GAP-020). Zero for members saved
## before capsules were persisted.
func get_capsule_gain(character_id: String, stat: String) -> int:
	return Helpers.get_capsule_gain(get_member(character_id), stat)


func get_derived_stats(character_id: String) -> Dictionary:
	return Helpers.compute_derived_stats(
		get_effective_stat(character_id, "spd"),
		get_effective_stat(character_id, "lck"),
		get_effective_stat(character_id, "mdef")
	)


## Re-derive max HP/MP after anything that changes persistent stats. Routes
## through the shared recalculation so this instance's crystal state is used
## while the formula stays identical to the level-up path (#274). Public
## because every facet that changes worn gear has to trigger it.
func refresh_max_hp_mp(character_id: String) -> void:
	var m: Dictionary = get_member(character_id)
	if m.is_empty():
		return
	Helpers.recalculate_max_hp_mp(
		m, func(stat: String) -> int: return get_equipment_bonus(character_id, stat)
	)


# ---------- Equipment (PartyEquipment) ----------


## Seed the equipment instance-ID counter — 0 for a new game, or the highest ID
## already present in a loaded save.
func set_next_inst_id(value: int) -> void:
	_get_equipment().set_next_inst_id(value)


func get_equipment_bonus(character_id: String, stat: String) -> int:
	return _get_equipment().stat_bonus(character_id, stat)


func equip_item(character_id: String, slot: String, equipment_id: String) -> Dictionary:
	return _get_equipment().equip(character_id, slot, equipment_id)


func unequip_slot(character_id: String, slot: String) -> String:
	if slot == "crystal":
		return unequip_crystal(character_id)
	return _get_equipment().unequip(character_id, slot)


func get_equippable_for_slot(character_id: String, slot: String) -> Array[Dictionary]:
	return _get_equipment().equippable_for_slot(character_id, slot)


func optimize_equipment(character_id: String) -> void:
	_get_equipment().optimize(character_id)


## Add equipment to owned inventory with a generated instance ID.
func add_equipment(eid: String) -> void:
	_get_equipment().add(eid)


## Removes Edren's temporary arcanite equipment after Ember Vein escape.
func break_arcanite_gear() -> void:
	_get_equipment().break_arcanite_gear()


# ---------- Inventory and purse (PartyInventory) ----------


func get_consumables() -> Dictionary:
	return _get_items().consumables()


## Held crafting materials as {item_id: quantity} (items.md § Crafting Materials).
func get_materials() -> Dictionary:
	return _get_items().materials()


func get_key_items() -> Array:
	return _get_items().key_items()


## Whether the party holds a key item (items.md § Story Items).
func has_key_item(item_id: String) -> bool:
	return _get_items().has_key_item(item_id)


func use_item(item_id: String, target_character_id: String) -> bool:
	return _get_items().use_item(item_id, target_character_id)


func add_key_item(item_id: String) -> void:
	_get_items().add_key_item(item_id)


func remove_key_item(item_id: String) -> void:
	_get_items().remove_key_item(item_id)


## Add a quantity item to the inventory, routed to its bucket (GAP-019).
func add_item(item_id: String, quantity: int) -> void:
	_get_items().add_item(item_id, quantity)


## Remove a quantity item from whichever bucket it belongs to.
func remove_item(item_id: String, quantity: int) -> void:
	_get_items().remove_item(item_id, quantity)


## Consume one unit of an item from its own bucket. Returns true if consumed.
func consume_item(item_id: String) -> bool:
	return _get_items().consume_item(item_id)


func get_gold() -> int:
	return gold


func add_gold(amount: int) -> void:
	_get_items().add_gold(amount)


func spend_gold(amount: int) -> bool:
	return _get_items().spend_gold(amount)


# ---------- Vitals (PartyVitals) ----------


## Restore ALL party members to full HP/MP/AC, clear status. Per economy.md.
func rest_at_inn() -> void:
	_get_vitals().rest_at_inn()


## Deduct MP from a party member. Returns false if insufficient.
func spend_mp(character_id: String, amount: int) -> bool:
	return _get_vitals().spend_mp(character_id, amount)


## Heal a party member's HP. Returns actual amount restored.
func heal_member(character_id: String, amount: int) -> int:
	return _get_vitals().heal(character_id, amount)


## Revive all KO'd active party members at a fraction of max HP.
func revive_active_at_fraction(fraction: float) -> void:
	_get_vitals().revive_active_at_fraction(fraction)


## Apply rest item effects to ALL party members (active + reserve).
func rest_party(restore_pct: float, clears_status: bool) -> void:
	_get_vitals().rest_party(restore_pct, clears_status)


# ---------- Composition (PartyRoster) ----------


## Recruit a character, slotting them into the active four or into reserve.
func add_member(character_id: String, level: int = 1) -> void:
	_get_roster().add_member(character_id, level)


func has_member(character_id: String) -> bool:
	return _get_roster().has_member(character_id)


func get_member(character_id: String) -> Dictionary:
	for m: Dictionary in members:
		if m.get("character_id", "") == character_id:
			return m
	return {}


func get_all_members() -> Array[Dictionary]:
	return members


func get_active_party() -> Array[Dictionary]:
	return FormationHelpers.get_active_members(members, formation)


## Get reserve (non-active) party members.
func get_reserve_party() -> Array[Dictionary]:
	return FormationHelpers.get_reserve_members(members, formation)


## Find the members array index for a character by ID. Returns -1 if not found.
func find_member_index(character_id: String) -> int:
	return _get_roster().find_member_index(character_id)


## Move a character from active formation to reserve by ID.
func move_member_to_reserve(character_id: String) -> bool:
	return _get_roster().move_to_reserve(character_id)


## Move a character from reserve back to active formation by ID.
func move_member_to_active(character_id: String) -> bool:
	return _get_roster().move_to_active(character_id)


func get_row(cid: String) -> String:
	return _get_roster().get_row(cid)


func toggle_row(cid: String) -> void:
	_get_roster().toggle_row(cid)


func get_formation_list() -> Array:
	return _get_roster().formation_list()


func swap_formation_positions(a: int, b: int) -> void:
	_get_roster().swap_positions(a, b)


# ---------- Player config ----------


func get_config() -> Dictionary:
	if not _config_loaded:
		_load_config()
	return _config


func set_config(key: String, value: Variant) -> void:
	_config[key] = value


func save_config() -> void:
	var file: FileAccess = FileAccess.open(SaveManager.CONFIG_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_config, "\t"))
		file.close()


func _load_config() -> void:
	_config = SaveDataHelpers.load_config_from_disk()
	_config_loaded = true


func _get_crystals() -> PartyCrystals:
	if _crystals == null:
		_crystals = PartyCrystals.new(self)
	return _crystals


func _get_roster() -> PartyRoster:
	if _roster == null:
		_roster = PartyRoster.new(self)
	return _roster


func _get_vitals() -> PartyVitals:
	if _vitals == null:
		_vitals = PartyVitals.new(self)
	return _vitals


func _get_items() -> PartyInventory:
	if _items == null:
		_items = PartyInventory.new(self)
	return _items


func _get_equipment() -> PartyEquipment:
	if _equipment == null:
		_equipment = PartyEquipment.new(self)
	return _equipment


func _get_persistence() -> PartyPersistence:
	if _persistence == null:
		_persistence = PartyPersistence.new(self)
	return _persistence
