extends GutTest
## Tests for the data-driven boss AI interpreter (GAP-009): phase transitions,
## charge/telegraph (2-turn), highest-threat targeting, fixed-key conditions, and
## each Act-I boss script (Ember Drake, Vein Guardian, Drowned Sentinel,
## Corrupted Fenmother). Drives the static interpreter directly (no scene):
## ai_state lives on the Enemy node and persists across calls. Values trace to
## docs/story/bestiary/bosses.md and enemy-ability-conventions.md § 3.

const BossAI = preload("res://scripts/combat/boss_ai.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")


## Minimal stand-in for BattleManager — just the signals + hook BattleEnemyTurn
## touches. Lets the integration tests drive the real execute() -> BossAI ->
## _apply_action -> resolution path WITHOUT booting battle.tscn (whose _process
## would draw from the shared RNG and perturb other test files' seeded runs).
class _FakeManager:
	extends Node2D
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)

	func _on_enemy_died(_enemy: Node) -> void:
		pass


func after_each() -> void:
	randomize()


func _boss(enemy_id: String) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	e.initialize(enemy_id, "act_i")
	return e


## A 4-member party. `rows` optionally overrides each slot's row.
func _party(rows: Array = []) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	for i: int in range(4):
		state.add_member(
			i, {"character_id": "m%d" % i, "base_stats": {"hp": 200, "mdef": 8, "spd": 8}}
		)
		if i < rows.size():
			state.get_member(i)["row"] = rows[i]
	return state


# --- Phase selection by HP ratio ---


func test_phase_selection_at_threshold_boundaries() -> void:
	var vg: Enemy = _boss("vein_guardian")
	var state: Node = _party()
	var max_hp: int = vg.enemy_data.get("hp", 1)
	# 0.51 -> phase_1
	vg.current_hp = int(max_hp * 0.51)
	BossAI.select_action(vg, 1, state, [vg])
	assert_eq(vg.ai_state.get("phase", ""), "phase_1", "above 50% HP is phase_1")
	# exactly 0.50 -> phase_2 (hp_percent <= 50 enters next phase)
	vg.ai_state.clear()
	vg.current_hp = int(max_hp * 0.50)
	BossAI.select_action(vg, 1, state, [vg])
	assert_eq(vg.ai_state.get("phase", ""), "phase_2", "at exactly 50% HP enters phase_2")


# --- Charge / telegraph (2-turn) ---


func test_telegraph_charges_then_resolves() -> void:
	var vg: Enemy = _boss("vein_guardian")
	var state: Node = _party()
	# turn 0: turn%4==0 -> crystal_slam, which telegraphs -> charge turn (skip).
	var charge: Dictionary = BossAI.select_action(vg, 0, state, [vg])
	assert_eq(charge.get("type", ""), "skip", "charge turn is a no-damage skip")
	assert_eq(vg.ai_state.get("charging", ""), "crystal_slam", "charging state is set")
	assert_true(charge.has("message"), "charge emits the telegraph tell")
	# next turn: resolves the charged move as a real ability.
	var resolve: Dictionary = BossAI.select_action(vg, 1, state, [vg])
	assert_eq(resolve.get("type", ""), "ability", "resolve turn deals the ability")
	assert_eq(resolve.get("id", ""), "crystal_slam", "resolves the charged move")
	assert_eq(vg.ai_state.get("charging", ""), "", "charging cleared after resolve")


# --- Highest-threat targeting ---


func test_crystal_slam_targets_highest_threat() -> void:
	var vg: Enemy = _boss("vein_guardian")
	var state: Node = _party()
	state.add_threat(2, 500)  # slot 2 is the damage dealer
	# Charge then resolve crystal_slam; the resolved action targets slot 2.
	BossAI.select_action(vg, 0, state, [vg])  # charge
	var resolve: Dictionary = BossAI.select_action(vg, 1, state, [vg])
	assert_eq(resolve.get("id", ""), "crystal_slam")
	assert_eq(int(resolve.get("target_slot", -1)), 2, "Crystal Slam hits the highest-threat member")


# --- Vein Guardian: Reconstruct once at phase 2 ---


func test_vein_guardian_reconstructs_once() -> void:
	var vg: Enemy = _boss("vein_guardian")
	var state: Node = _party()
	vg.current_hp = int(vg.enemy_data.get("hp", 1) * 0.4)  # phase_2
	var first: Dictionary = BossAI.select_action(vg, 1, state, [vg])
	assert_eq(first.get("id", ""), "reconstruct", "enters phase_2 with a one-time Reconstruct")
	assert_eq(first.get("type", ""), "heal")
	assert_eq(int(first.get("value", 0)), 300, "Reconstruct heals +300 (bosses.md § Vein Guardian)")
	# Subsequent phase_2 turns never reconstruct again.
	var reconstructed_again: bool = false
	for t: int in range(2, 20):
		var a: Dictionary = BossAI.select_action(vg, t, state, [vg])
		# clear any charge so we see the underlying picks
		if a.get("id", "") == "reconstruct":
			reconstructed_again = true
	assert_false(reconstructed_again, "Reconstruct is one-time only")


func test_phase_enter_message_fires_once_across_oscillation() -> void:
	var vg: Enemy = _boss("vein_guardian")
	var state: Node = _party()
	var max_hp: int = vg.enemy_data.get("hp", 1)
	# Enter phase_2 -> the "crystal core fractures" line fires.
	vg.current_hp = int(max_hp * 0.4)
	var a1: Dictionary = BossAI.select_action(vg, 1, state, [vg])
	assert_true(
		str(a1.get("message", "")).contains("crystal core"), "phase_2 message on first entry"
	)
	# Reconstruct pushes HP back above 50% -> phase_1 (no message).
	vg.current_hp = int(max_hp * 0.6)
	BossAI.select_action(vg, 2, state, [vg])
	# Re-drop below 50% -> phase_2 again; the one-time flavor line must NOT repeat.
	vg.current_hp = int(max_hp * 0.4)
	var a3: Dictionary = BossAI.select_action(vg, 3, state, [vg])
	assert_false(
		str(a3.get("message", "")).contains("crystal core"), "phase enter message does not repeat"
	)


# --- Drowned Sentinel: self-buff + AoE + default ---


func test_drowned_sentinel_script() -> void:
	var ds: Enemy = _boss("drowned_sentinel")
	var state: Node = _party()
	# turn 4 (%4==0) -> barnacle_shield (self DEF buff)
	var t4: Dictionary = BossAI.select_action(ds, 4, state, [ds])
	assert_eq(t4.get("id", ""), "barnacle_shield")
	assert_eq(t4.get("target", ""), "self")
	assert_eq(float(t4.get("buff", {}).get("mult", 0.0)), 2.0, "Barnacle = DEF x2 (+100%)")
	# turn 3 (%3==0, not %4) -> frost_wave (AoE)
	var t3: Dictionary = BossAI.select_action(ds, 3, state, [ds])
	assert_eq(t3.get("id", ""), "frost_wave")
	assert_eq(t3.get("target", ""), "all", "Frost Wave is party-wide")
	# turn 5 -> default stone_slam (highest threat single)
	var t5: Dictionary = BossAI.select_action(ds, 5, state, [ds])
	assert_eq(t5.get("id", ""), "stone_slam")
	assert_eq(t5.get("target", ""), "single")


# --- Ember Drake: back-row Pounce vs default Tail Swipe ---


func test_ember_drake_pounce_when_back_row_present() -> void:
	var drake: Enemy = _boss("ember_drake")
	# A party member in the back row -> turn 1 (not %3) hits the position rule.
	var state: Node = _party(["front", "front", "front", "back"])
	var a: Dictionary = BossAI.select_action(drake, 1, state, [drake])
	assert_eq(a.get("id", ""), "pounce", "Pounce fires when a back-row target exists")
	assert_eq(int(a.get("target_slot", -1)), 3, "Pounce targets the back-row member")


func test_ember_drake_tail_swipe_default() -> void:
	var drake: Enemy = _boss("ember_drake")
	var state: Node = _party(["front", "front", "front", "front"])  # no back row
	var a: Dictionary = BossAI.select_action(drake, 1, state, [drake])
	assert_eq(a.get("id", ""), "tail_swipe", "default to Tail Swipe with no back-row target")


# --- Corrupted Fenmother: surface/dive mode cycle + untargetable ---


func test_fenmother_dive_surface_cycle() -> void:
	var fm: Enemy = _boss("corrupted_fenmother")
	var state: Node = _party()
	# Phase 1: surface 3 turns (0,1,2), then dive 2 turns (3,4); resurface at 5.
	var types: Array[String] = []
	for t: int in range(5):
		var a: Dictionary = BossAI.select_action(fm, t, state, [fm])
		types.append(str(a.get("id", "")))
	# First 3 are surface attacks (tail_sweep/water_jet), next 2 are dive skips.
	assert_ne(types[0], "dive", "turn 0 is on the surface")
	assert_eq(types[3], "dive", "after 3 surface turns the Fenmother dives")
	assert_eq(types[4], "dive", "dive lasts 2 turns")
	assert_true(fm.get_meta("untargetable", false), "boss is untargetable mid-dive (turn 4)")
	# Turn 5 resurfaces -> targetable again.
	BossAI.select_action(fm, 5, state, [fm])
	assert_false(fm.get_meta("untargetable", true), "Fenmother is targetable after resurfacing")


func test_fenmother_phase2_spawns_adds() -> void:
	var fm: Enemy = _boss("corrupted_fenmother")
	var state: Node = _party()
	fm.current_hp = int(fm.enemy_data.get("hp", 1) * 0.4)  # phase_2
	# turn 3 (%3==0), adds_below 2 (no adds) -> summon_spawn
	var a: Dictionary = BossAI.select_action(fm, 3, state, [fm])
	assert_eq(a.get("id", ""), "summon_spawn", "phase 2 summons adds when below cap")
	assert_eq(a.get("type", ""), "spawn")


# --- Fixed-key condition: adds_below suppresses summon when at cap ---


func test_adds_below_blocks_summon_at_cap() -> void:
	var fm: Enemy = _boss("corrupted_fenmother")
	var add1: Enemy = _boss("corrupted_fenmother")  # stand-ins for living adds
	var add2: Enemy = _boss("corrupted_fenmother")
	var state: Node = _party()
	fm.current_hp = int(fm.enemy_data.get("hp", 1) * 0.4)  # phase_2
	# 2 living adds present -> adds_below:2 is false -> NOT summon_spawn.
	var a: Dictionary = BossAI.select_action(fm, 3, state, [fm, add1, add2])
	assert_ne(a.get("id", ""), "summon_spawn", "no summon when adds are at cap")


# --- Integration: the wired execute() -> BossAI -> _apply_action path ---


## Wire a real BattleEnemyTurn driver with a fake manager (no scene boot).
## Returns {driver, state}.
func _harness() -> Dictionary:
	var mgr: Node2D = _FakeManager.new()
	add_child_autofree(mgr)
	var state: Node = _party()
	var atb: Node = ATBSystem.new()
	add_child_autofree(atb)
	var area: Node2D = Node2D.new()
	add_child_autofree(area)
	var driver: BattleEnemyTurn = BattleEnemyTurn.new(mgr, state, atb, area)
	return {"driver": driver, "state": state}


func _total_hp(state: Node) -> int:
	var total: int = 0
	for i: int in range(4):
		total += int(state.get_member(i).get("current_hp", 0))
	return total


func test_integration_boss_telegraph_then_damage() -> void:
	seed(7)  # deterministic hit/evasion rolls so the resolve reliably lands
	var boss: Enemy = _boss("vein_guardian")
	var h: Dictionary = _harness()
	var driver: BattleEnemyTurn = h["driver"]
	var state: Node = h["state"]
	var hp0: int = _total_hp(state)
	# Turn 0: Crystal Slam telegraphs -> charge turn deals no damage.
	driver.execute("enemy_0", [boss], true, 0)
	assert_eq(_total_hp(state), hp0, "charge turn deals no damage")
	assert_eq(boss.ai_state.get("charging", ""), "crystal_slam", "boss is charging Crystal Slam")
	# Turn 1: resolves the charged Crystal Slam -> the party takes damage.
	driver.execute("enemy_0", [boss], true, 1)
	assert_lt(_total_hp(state), hp0, "resolved Crystal Slam damages the party via the wired path")
	assert_eq(boss.ai_state.get("charging", ""), "", "charge cleared after resolving")


func test_integration_summon_respects_add_cap() -> void:
	# With 1 add already alive, the {adds_below:2} rule fires but _do_spawn must
	# top up to exactly the cap of 2 (spawn 1), never overshoot to 3 (bosses.md § Corrupted Fenmother).
	var fm: Enemy = _boss("corrupted_fenmother")
	var add1: Enemy = _boss("corrupted_spawn")
	var h: Dictionary = _harness()
	var driver: BattleEnemyTurn = h["driver"]
	fm.current_hp = int(fm.enemy_data.get("hp", 1) * 0.4)  # phase_2
	var enemies: Array[Node] = [fm, add1]
	driver.execute("enemy_0", enemies, true, 3)  # turn%3==0, 1 add alive -> summon
	var living_adds: int = 0
	for e: Node in enemies:
		if e != fm and e.is_alive:
			living_adds += 1
	assert_eq(
		living_adds, 2, "summon tops up to exactly the cap of 2 active adds (1 existing + 1 new)"
	)


func test_integration_vein_guardian_reconstruct_heals() -> void:
	var boss: Enemy = _boss("vein_guardian")
	var h: Dictionary = _harness()
	var driver: BattleEnemyTurn = h["driver"]
	boss.current_hp = int(boss.enemy_data.get("hp", 1) * 0.4)  # phase_2
	var before: int = boss.current_hp
	driver.execute("enemy_0", [boss], true, 1)
	assert_gt(boss.current_hp, before, "entering phase_2 triggers a one-time Reconstruct heal")
