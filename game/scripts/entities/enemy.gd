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

## Whether the enemy is still alive.
var is_alive: bool = true

## Reference to child nodes.
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


## Initialize the enemy with data from DataManager.
func initialize(p_enemy_id: String, p_act: String) -> void:
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


## Get the enemy's base stats as a dictionary subset.
func get_stats() -> Dictionary:
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


## Check if the enemy is weak to an element.
func is_weak_to(element: String) -> bool:
	return element in enemy_data.get("weaknesses", [])


## Check if the enemy is resistant to an element.
func is_resistant_to(element: String) -> bool:
	return element in enemy_data.get("resistances", [])


## Check if the enemy is immune to an element.
func is_immune_to(element: String) -> bool:
	return element in enemy_data.get("immunities", [])


## Check if the enemy absorbs an element.
func absorbs(element: String) -> bool:
	return element in enemy_data.get("absorb", [])


## Get the damage multiplier for an element.
## Returns: -1.0 (absorb), 0.0 (immune), 0.75 (resist), 1.5 (weak), 1.0 (neutral).
func get_element_multiplier(element: String) -> float:
	if absorbs(element):
		return -1.0
	if is_immune_to(element):
		return 0.0
	if is_resistant_to(element):
		return 0.75
	if is_weak_to(element):
		return 1.5
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


## Apply damage. Clamps HP to 0. Emits damage_taken and died signals.
func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	damage_taken.emit(amount)
	if current_hp <= 0:
		is_alive = false
		died.emit()


## Apply healing. Clamps HP to max base HP. Emits healed signal.
func heal(amount: int) -> void:
	var max_hp: int = enemy_data.get("hp", 0)
	var old_hp: int = current_hp
	current_hp = min(max_hp, current_hp + amount)
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
	var success: bool = randi() % 100 < rate
	return {
		"item_id": tier_data.get("item_id", "") if success else "",
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
	var texture: Texture2D = load(sprite_path)
	var sprite: Sprite2D = _sprite if _sprite != null else get_node("Sprite2D")
	if sprite != null:
		sprite.texture = texture
