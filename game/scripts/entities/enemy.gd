class_name Enemy
extends Node2D
## Battle enemy entity with runtime state tracking.
##
## Holds mutable HP/MP/status state, exposes elemental profile
## queries, handles damage/healing, and resolves drops/steals.
## AI action selection deferred to gap 3.3 (Battle Scene).
##
## Usage: instance enemy.tscn, call initialize("ley_vermin", "act_i").

## Emitted when the enemy takes damage.
signal damage_taken(amount: int)

## Emitted when the enemy is healed.
signal healed(amount: int)

## Emitted when a status effect is applied.
signal status_applied(status_name: String, duration: int)

## Emitted when a status effect is removed.
signal status_removed(status_name: String)

## Emitted when HP reaches 0.
signal died

## Fixed critical hit rate for all enemies (per combat-formulas.md).
const ENEMY_CRIT_RATE: float = 0.05

## Type-based default status immunities (per bestiary/README.md).
const TYPE_IMMUNITIES: Dictionary = {
	"beast": [],
	"undead": ["poison", "death"],
	"construct": ["poison", "sleep", "confusion", "berserk", "despair"],
	"spirit": ["poison", "petrify"],
	"humanoid": [],
	"pallor": ["despair", "death"],
	"elemental": ["petrify"],
	"boss": ["death", "petrify", "stop", "sleep", "confusion"],
}

## Enemy ID loaded from DataManager.
var enemy_id: String = ""

## Act the enemy was loaded from.
var enemy_act: String = ""

## Loaded enemy data dictionary (immutable base stats).
var enemy_data: Dictionary = {}

## Runtime mutable HP.
var current_hp: int = 0

## Runtime mutable MP.
var current_mp: int = 0

## Active status effects: [{name: String, remaining_turns: int}].
var active_statuses: Array[Dictionary] = []

## Whether the enemy is still alive. Defaults false until initialize().
var is_alive: bool = false

## Reference to child nodes.
@onready var _sprite: Sprite2D = $Sprite2D


## Initialize the enemy with data from DataManager.
## Safe to call multiple times — resets all state before loading.
func initialize(p_enemy_id: String, p_act: String) -> void:
	# Reset all state before loading new data.
	enemy_data = {}
	current_hp = 0
	current_mp = 0
	active_statuses.clear()
	is_alive = false

	enemy_id = p_enemy_id
	enemy_act = p_act
	var enemies: Array = DataManager.load_enemies(p_act)
	for entry: Dictionary in enemies:
		if entry.get("id", "") == enemy_id:
			enemy_data = entry
			break
	if enemy_data.is_empty():
		push_error("Enemy: Failed to load '%s' from act '%s'" % [enemy_id, p_act])
		return
	current_hp = enemy_data.get("hp", 0)
	current_mp = enemy_data.get("mp", 0)
	is_alive = current_hp > 0
	_load_placeholder_sprite()


## Get the enemy's base stats as a dictionary subset. Empty if not initialized.
func get_stats() -> Dictionary:
	if enemy_data.is_empty():
		return {}
	var stat_keys: Array[String] = [
		"hp",
		"mp",
		"atk",
		"def",
		"mag",
		"mdef",
		"spd",
	]
	var stats: Dictionary = {}
	for key: String in stat_keys:
		stats[key] = enemy_data.get(key, 0)
	return stats


## Get the enemy type (beast, undead, construct, etc.).
func get_type() -> String:
	return enemy_data.get("type", "")


## Get the enemy display name.
func get_display_name() -> String:
	return enemy_data.get("name", enemy_id)


## Check if an element appears in an array that may contain plain strings
## or objects with {"element": "...", "multiplier": ...}.
static func _element_in_list(element: String, list: Array) -> bool:
	for entry: Variant in list:
		if entry is String and entry == element:
			return true
		if entry is Dictionary and (entry as Dictionary).get("element", "") == element:
			return true
	return false


## Get the custom multiplier for an element from a mixed-format array.
## Returns the object multiplier if found, otherwise the provided default.
static func _get_list_multiplier(element: String, list: Array, default_mult: float) -> float:
	for entry: Variant in list:
		if entry is String and entry == element:
			return default_mult
		if entry is Dictionary:
			var d: Dictionary = entry as Dictionary
			if d.get("element", "") == element:
				return d.get("multiplier", default_mult)
	return 0.0  # not in list


## Check if the enemy is weak to an element.
func is_weak_to(element: String) -> bool:
	return _element_in_list(element, enemy_data.get("weaknesses", []))


## Check if the enemy is resistant to an element.
func is_resistant_to(element: String) -> bool:
	return _element_in_list(element, enemy_data.get("resistances", []))


## Check if the enemy is immune to an element.
func is_immune_to(element: String) -> bool:
	return _element_in_list(element, enemy_data.get("immunities", []))


## Check if the enemy absorbs an element.
func absorbs(element: String) -> bool:
	return _element_in_list(element, enemy_data.get("absorb", []))


## Get the damage multiplier for an element.
## Supports both string arrays (uses default 0.75/1.5) and object arrays
## with custom multipliers (e.g., {"element": "storm", "multiplier": 1.25}).
## Returns: -1.0 (absorb), 0.0 (immune), <1.0 (resist), >1.0 (weak), 1.0 (neutral).
func get_element_multiplier(element: String) -> float:
	if absorbs(element):
		return -1.0
	if is_immune_to(element):
		return 0.0
	var resist_mult: float = _get_list_multiplier(element, enemy_data.get("resistances", []), 0.75)
	if resist_mult > 0.0:
		return resist_mult
	var weak_mult: float = _get_list_multiplier(element, enemy_data.get("weaknesses", []), 1.5)
	if weak_mult > 0.0:
		return weak_mult
	return 1.0


## Check if the enemy is immune to a status effect.
## Checks both per-enemy immunities and type default immunities.
func is_immune_to_status(status: String) -> bool:
	var per_enemy: Array = enemy_data.get("status_immunities", [])
	if status in per_enemy:
		return true
	var enemy_type: String = get_type()
	var type_defaults: Array = TYPE_IMMUNITIES.get(enemy_type, [])
	return status in type_defaults


## Apply a status effect. Returns true if applied, false if immune.
func apply_status(status_name: String, duration: int) -> bool:
	if is_immune_to_status(status_name):
		return false
	# Remove existing instance of same status before reapplying.
	remove_status(status_name)
	active_statuses.append({"name": status_name, "remaining_turns": duration})
	status_applied.emit(status_name, duration)
	return true


## Remove a status effect by name.
func remove_status(status_name: String) -> void:
	for i: int in range(active_statuses.size() - 1, -1, -1):
		if active_statuses[i].get("name", "") == status_name:
			active_statuses.remove_at(i)
			status_removed.emit(status_name)


## Tick all status durations down by 1. Removes expired statuses.
## Call at END of turn so duration=1 means "lasts 1 full turn."
## Calling at turn start would make duration=1 expire immediately (0 turns).
func tick_statuses() -> void:
	for i: int in range(active_statuses.size() - 1, -1, -1):
		active_statuses[i]["remaining_turns"] -= 1
		if active_statuses[i]["remaining_turns"] <= 0:
			var expired_name: String = active_statuses[i].get("name", "")
			active_statuses.remove_at(i)
			status_removed.emit(expired_name)


## Check if a status is currently active.
func has_status(status_name: String) -> bool:
	for status: Dictionary in active_statuses:
		if status.get("name", "") == status_name:
			return true
	return false


## Apply damage. Clamps amount >= 0 and HP to 0. Emits damage_taken and died (once).
func take_damage(amount: int) -> void:
	if not is_alive:
		return
	var clamped: int = maxi(0, amount)
	current_hp = maxi(0, current_hp - clamped)
	damage_taken.emit(clamped)
	if current_hp <= 0:
		is_alive = false
		died.emit()


## Apply healing. Clamps amount >= 0 and HP to max. Restores is_alive. Emits healed.
func heal(amount: int) -> void:
	var clamped: int = maxi(0, amount)
	var max_hp: int = enemy_data.get("hp", 0)
	var old_hp: int = current_hp
	current_hp = mini(max_hp, current_hp + clamped)
	if current_hp > 0:
		is_alive = true
	var actual_heal: int = current_hp - old_hp
	if actual_heal > 0:
		healed.emit(actual_heal)


## Roll for a steal attempt. Returns {item_id: String, success: bool}.
func roll_steal(tier: String) -> Dictionary:
	var steal_data: Dictionary = enemy_data.get("steal", {})
	var tier_data: Dictionary = steal_data.get(tier, {})
	if tier_data.is_empty():
		return {"item_id": "", "success": false}
	var rate: int = tier_data.get("rate", 0)
	var raw_id: Variant = tier_data.get("item_id", "")
	var item_id: String = raw_id as String if raw_id is String else ""
	var success: bool = randi() % 100 < rate and not item_id.is_empty()
	return {
		"item_id": item_id if success else "",
		"success": success,
	}


## Roll for a drop on death. Returns {item_id: String, success: bool}.
func roll_drop() -> Dictionary:
	var drop_data: Dictionary = enemy_data.get("drop", {})
	if drop_data.is_empty():
		return {"item_id": "", "success": false}
	var rate: int = drop_data.get("rate", 0)
	var success: bool = randi() % 100 < rate
	return {
		"item_id": drop_data.get("item_id", "") if success else "",
		"success": success,
	}


func _load_placeholder_sprite() -> void:
	var sprite_path: String = "res://assets/sprites/enemies/placeholder_enemy.png"
	if not ResourceLoader.exists(sprite_path):
		push_error("Enemy: Placeholder sprite not found: %s" % sprite_path)
		return
	var resource: Resource = load(sprite_path)
	if not resource is Texture2D:
		push_error("Enemy: Loaded resource is not Texture2D: %s" % sprite_path)
		return
	var texture: Texture2D = resource as Texture2D
	var sprite: Sprite2D = _sprite if _sprite != null else get_node_or_null("Sprite2D")
	if sprite != null:
		sprite.texture = texture
