class_name BattleSetup
extends RefCounted
## Battle-start assembly: reading the encounter parameters GameManager handed
## in, seating the active party and the enemy line, and applying the player's
## ATB configuration.
##
## Extracted from battle_manager.gd (GAP-087). Nothing here runs after the
## first frame of a battle.

const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

## Enemy line capacity: two rows of three (ui-design.md § 2.5).
const MAX_ENEMIES: int = 6
## Enemy placement grid, in pixels from the battlefield origin.
const ENEMY_ORIGIN: Vector2 = Vector2(160.0, 40.0)
const ENEMY_SPACING: Vector2 = Vector2(48.0, 48.0)
const ENEMY_COLUMNS: int = 3


## Seat the active party in the battle state and give each member an ATB gauge.
static func setup_party(state: Node, atb: Node) -> void:
	var active: Array[Dictionary] = PartyState.get_active_party()
	for i: int in range(active.size()):
		if not active[i].is_empty():
			state.add_member(i, active[i])
			atb.add_combatant("party_%d" % i, state.get_effective_stat(i, "spd"), false)


## Instantiate the encounter group into [param enemy_area], laid out on the
## enemy grid, and give each one an ATB gauge. Returns the spawned nodes.
## @param encounter_group Array[String] — enemy IDs from JSON encounter data.
static func setup_enemies(
	encounter_group: Array, enemy_act: String, enemy_area: Node2D, atb: Node, on_died: Callable
) -> Array[Node]:
	var enemies: Array[Node] = []
	for i: int in range(mini(MAX_ENEMIES, encounter_group.size())):
		var e: Node = ENEMY_SCENE.instantiate()
		enemy_area.add_child(e)
		e.initialize(encounter_group[i], enemy_act)
		e.position = Vector2(
			ENEMY_ORIGIN.x + (i % ENEMY_COLUMNS) * ENEMY_SPACING.x,
			ENEMY_ORIGIN.y + floorf(float(i) / float(ENEMY_COLUMNS)) * ENEMY_SPACING.y
		)
		enemies.append(e)
		atb.add_combatant("enemy_%d" % i, e.get_stats().get("spd", 10), true)
		# AoE-on-death (Shard Burst): fire when this enemy dies, by any cause.
		e.died.connect(on_died.bind(e))
	return enemies


## Apply the player's ATB Mode / Battle Speed / Patience Mode config to the ATB
## system at battle start (GAP-007). Without this the player's settings never
## reached combat and the gauges always ran in "active" mode at speed 3.
static func apply_atb_config(atb: Node) -> void:
	var settings: Dictionary = ATBSystem.settings_from_config(PartyState.get_config())
	atb.set_atb_mode(str(settings.get("mode", "active")))
	atb.set_battle_speed(int(settings.get("speed", 3)))
