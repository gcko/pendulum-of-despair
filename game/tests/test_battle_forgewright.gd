extends GutTest
## Lira's Forgewright (GAP-002, slice 158c of #158): deploying devices for
## Arcanite Charges, the two-device limit, Salvage, and the devices that act on
## Lira's own turns — Shock Coil and Mending Engine. What a device does to an
## enemy's hit (Bulkhead, Arc Trap, Thornveil Barrier) and Overcharge are
## test_battle_forgewright_hits.gd; the AC pool outside battle is
## test_arcanite_charges.gd.
##
## Design law: abilities.md § Lira — Forgewright and game/data/abilities/lira.json,
## with the rulings of 2026-10-30: devices count down on Lira's turns ("persists
## 3 turns" is three of her turns), Shock Coil fires at the start of each of them
## and Mending Engine heals at the end of each; Arcanite Colossus, Cael's Edge
## and Calibrate are a later slice.

const BattleState = preload("res://scripts/combat/battle_state.gd")
const AbilityCommand = preload("res://scripts/combat/battle_ability_command.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const Forgewright = preload("res://scripts/combat/battle_forgewright.gd")
const SubmenuItems = preload("res://scripts/ui/battle_submenu_items.gd")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")

const EDREN := 0
const CAEL := 1
const LIRA := 2
const MAREN := 3


## The accessors and signals command modules reach on the battle manager.
class FakeBattle:
	extends Node
	signal message(text: String)
	signal damage_dealt(target_id: String, amount: int, damage_type: String)
	signal combatant_died(combatant_id: String)
	var state: Node
	var enemies: Array[Node] = []
	var atb: Node

	func get_battle_state() -> Node:
		return state

	func get_enemies() -> Array[Node]:
		return enemies

	func get_atb() -> Node:
		return atb


var _battle: FakeBattle
var _state: Node
var _cmd: RefCounted
var _hits: Array = []
var _kills: Array[String] = []


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()
	PartyState.arcanite_charges = 12
	_state = BattleState.new()
	add_child_autofree(_state)
	for slot: int in range(4):
		_state.add_member(slot, _member(["edren", "cael", "lira", "maren"][slot]))
	_battle = FakeBattle.new()
	_battle.state = _state
	add_child_autofree(_battle)
	_battle.atb = preload("res://scripts/combat/atb_system.gd").new()
	add_child_autofree(_battle.atb)
	_hits = []
	_kills = []
	_battle.damage_dealt.connect(
		func(t: String, n: int, k: String) -> void: _hits.append([t, n, k])
	)
	_cmd = AbilityCommand.new(_battle)
	_battle.enemies = [_make_enemy({})] as Array[Node]


func after_each() -> void:
	_cmd = null
	randomize()
	PartyState.arcanite_charges = 12
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _member(cid: String) -> Dictionary:
	return {
		"character_id": cid,
		"name": cid.capitalize(),
		"base_stats":
		{
			"hp": 1000,
			"mp": 40,
			"atk": 50,
			"def": 40,
			"mag": 60,
			"mdef": 20,
			"spd": 255,
			"lck": 0,
		},
	}


## A slow enemy Lira's devices reliably reach, with [param extra] overriding
## its data.
func _make_enemy(extra: Dictionary) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(e)
	var data: Dictionary = {
		"name": "Brute",
		"atk": 40,
		"mag": 40,
		"spd": 0,
		"def": 10,
		"mdef": 10,
		"type": "humanoid",
		"hp": 30000,
	}
	data.merge(extra, true)
	e.enemy_data = data
	e.current_hp = int(data["hp"])
	e.is_alive = true
	return e


func _ability(ability_id: String) -> Dictionary:
	for a: Variant in DataManager.load_abilities("lira"):
		if (a as Dictionary).get("id", "") == ability_id:
			return a
	fail_test("lira.json has no ability '%s'" % ability_id)
	return {}


func _use(ability_id: String, target: int = 0) -> bool:
	return _cmd.do_ability(
		"party_%d" % LIRA, {"type": "ability", "ability": _ability(ability_id), "target": target}
	)


func _ac() -> int:
	return int(_state.get_member(LIRA)["ac"])


func _device_ids() -> Array[String]:
	var out: Array[String] = []
	for d: Dictionary in Forgewright.devices(_state.get_member(LIRA)):
		out.append(String(d["id"]))
	return out


## One full turn of Lira's: its start, then its end.
func _lira_turn() -> void:
	_run(_state.begin_turn(LIRA))
	_run(_state.tick_statuses(LIRA))


## Answer a turn's events as the battle does: a Shock Coil's strike request is
## resolved by Forgewright.shock, and every strike or heal is recorded in _hits
## as [target, amount, type] and every kill in _kills. (BattleManager's own
## handling of them is test_battle_device_seams.gd.)
func _run(events: Array) -> void:
	for ev: Dictionary in events:
		if not ev.has("shock_coil"):
			_hits.append(["party_%d" % int(ev["slot"]), int(ev["dmg"]), ev["type"]])
			continue
		var enemies: Array[Node] = _battle.enemies
		var hit: Dictionary = Forgewright.shock(
			_state, int(ev["slot"]), int(ev["shock_coil"]), enemies
		)
		if hit.is_empty():
			continue
		_hits.append([hit["target"], hit["damage"], hit["type"]])
		if hit["killed"]:
			_kills.append(hit["target"])


## Damage events [amount, type] that landed on enemy [param idx].
func _enemy_hits(idx: int) -> Array:
	return _hits.filter(func(h: Array) -> bool: return h[0] == "enemy_%d" % idx)


# --- The table is the doc ---


func test_every_device_duration_matches_the_shipped_effect_text() -> void:
	for ability_id: String in Forgewright.DEVICES:
		var turns: int = int(Forgewright.DEVICES[ability_id].get("turns", 0))
		var text: String = String(_ability(ability_id).get("effect", ""))
		assert_true(text.begins_with("Device."), "%s is a device in the data" % ability_id)
		if turns > 0:
			assert_true(
				text.contains("Persists %d turns" % turns),
				"%s persists %d turns: %s" % [ability_id, turns, text]
			)
		else:
			assert_true(text.contains("Single use"), "%s waits to be triggered" % ability_id)


func test_every_device_magnitude_matches_the_shipped_effect_text() -> void:
	var d: Dictionary = Forgewright.DEVICES
	var bulkhead: String = _ability("bulkhead")["effect"]
	assert_true(bulkhead.contains("by %d%%" % d["bulkhead"]["reduction_pct"]), bulkhead)
	var engine: String = _ability("mending_engine")["effect"]
	assert_true(engine.contains("%d%% max HP" % d["mending_engine"]["heal_pct"]), engine)
	var thorns: String = _ability("thornveil_barrier")["effect"]
	assert_true(
		thorns.contains(
			"%d%% of the shielded ally's Defense" % d["thornveil_barrier"]["counter_pct"]
		),
		thorns
	)
	var trap: String = _ability("arc_trap")["effect"]
	assert_true(trap.contains("%d%% Speed debuff" % d["arc_trap"]["spd_debuff_pct"]), trap)
	assert_true(trap.contains("for %d turns" % d["arc_trap"]["debuff_turns"]), trap)
	var overcharge: String = _ability("overcharge")["effect"]
	assert_true(
		overcharge.contains("+%d%% damage" % Forgewright.OVERCHARGE["damage_pct"]), overcharge
	)


func test_shock_coil_lasts_one_turn_per_tick_in_the_data() -> void:
	assert_eq(Forgewright.DEVICES["shock_coil"]["turns"], int(_ability("shock_coil")["ticks"]))


func test_the_damage_devices_are_storm_and_flame_as_the_data_says() -> void:
	assert_string_contains(_ability("shock_coil")["effect"], "Storm")
	assert_eq(Forgewright.DEVICES["shock_coil"]["element"], "storm")
	assert_string_contains(_ability("arc_trap")["effect"], "Flame")
	assert_eq(Forgewright.DEVICES["arc_trap"]["element"], "flame")


# --- What is built, and what waits for a later slice ---


func test_every_forgewright_ability_is_built_except_the_deferred_three() -> void:
	var deferred: Array[String] = ["arcanite_colossus", "caels_edge", "calibrate"]
	for a: Variant in DataManager.load_abilities("lira"):
		var ability: Dictionary = a
		assert_eq(
			AbilityCommand.is_built(ability),
			not ability["id"] in deferred,
			"%s built: %s" % [ability["id"], not ability["id"] in deferred]
		)


func test_a_deferred_ability_is_listed_unusable_and_refused_without_cost() -> void:
	var member: Dictionary = _state.get_member(LIRA)
	for ability_id: String in ["arcanite_colossus", "caels_edge", "calibrate"]:
		assert_false(AbilityCommand.is_available(member, _ability(ability_id)), ability_id)
		assert_false(_use(ability_id), "%s is refused" % ability_id)
	assert_eq(_ac(), 12, "nothing spent")
	assert_eq(_device_ids(), [] as Array[String], "nothing deployed")


# --- Deploying spends AC ---


func test_deploying_a_device_spends_its_ac() -> void:
	assert_true(_use("shock_coil"), "deployed")
	assert_eq(_ac(), 10, "Shock Coil costs 2 AC")
	assert_eq(_device_ids(), ["shock_coil"] as Array[String])


func test_deploying_announces_the_device_by_name() -> void:
	var said: Array[String] = []
	_battle.message.connect(func(t: String) -> void: said.append(t))
	_use("bulkhead", EDREN)
	assert_has(said, "Lira uses Bulkhead!")


func test_a_device_lira_cannot_afford_is_refused_and_costs_nothing() -> void:
	_state.get_member(LIRA)["ac"] = 3
	assert_false(_use("mending_engine"), "4 AC with 3 in the pool")
	assert_eq(_ac(), 3, "nothing spent")
	assert_eq(_device_ids(), [] as Array[String], "nothing deployed")
	assert_false(
		AbilityCommand.can_pay(_state.get_member(LIRA), _ability("mending_engine")), "grayed"
	)
	assert_true(AbilityCommand.can_pay(_state.get_member(LIRA), _ability("bulkhead")), "3 AC fits")


func test_a_bulkhead_needs_a_living_ally() -> void:
	_state.take_damage(CAEL, 99999)
	assert_false(_use("bulkhead", CAEL), "no fallen target")
	assert_eq(_ac(), 12, "nothing spent")


# --- Two devices at a time ---


func test_a_third_device_destroys_the_oldest() -> void:
	_use("shock_coil")
	_use("bulkhead", EDREN)
	_use("arc_trap")
	assert_eq(_device_ids(), ["bulkhead", "arc_trap"] as Array[String], "Shock Coil went first")
	assert_eq(_ac(), 12 - 2 - 3 - 2, "the destroyed coil refunds nothing")


func test_overcharge_is_instant_and_takes_no_device_slot() -> void:
	_use("shock_coil")
	_use("bulkhead", EDREN)
	_use("overcharge", CAEL)
	assert_eq(_device_ids(), ["shock_coil", "bulkhead"] as Array[String], "both devices stand")
	assert_eq(_ac(), 12 - 2 - 3 - 3, "Overcharge costs 3 AC")


func test_a_device_fused_by_a_combo_does_not_count_toward_the_limit() -> void:
	_use("shock_coil")
	_use("bulkhead", EDREN)
	Forgewright.deploy(_state, LIRA, _ability("bulkhead"), CAEL, true)
	assert_eq(Forgewright.devices(_state.get_member(LIRA)).size(), 3, "all three stand")
	_use("arc_trap")
	assert_eq(
		_device_ids(),
		["bulkhead", "bulkhead", "arc_trap"] as Array[String],
		"the field's oldest goes, never the fused one"
	)


# --- Salvage ---


func test_salvage_destroys_a_device_and_refunds_half_its_cost_rounded_down() -> void:
	_use("bulkhead", EDREN)
	assert_true(_use("salvage"), "salvaged")
	assert_eq(_ac(), 12 - 3 + 1, "3 AC -> 1 back")
	assert_eq(_device_ids(), [] as Array[String], "the device is gone")
	_use("mending_engine")
	_use("salvage")
	assert_eq(_ac(), 10 - 4 + 2, "4 AC -> 2 back")


func test_with_two_devices_up_salvage_takes_the_older() -> void:
	_use("shock_coil")
	_use("mending_engine")
	assert_true(_use("salvage"), "salvaged")
	assert_eq(_device_ids(), ["mending_engine"] as Array[String], "the coil, deployed first")
	assert_eq(_ac(), 12 - 2 - 4 + 1, "Shock Coil's 2 AC -> 1 back")


func test_salvaging_a_combo_fused_device_refunds_nothing() -> void:
	# A combo pays MP for its device, so taking it down returns no AC.
	Forgewright.deploy(_state, LIRA, _ability("mending_engine"), CAEL, true)
	_state.get_member(LIRA)["ac"] = 5
	assert_true(_use("salvage"), "salvaged")
	assert_eq(_device_ids(), [] as Array[String])
	assert_eq(_ac(), 5, "no AC was spent on it, so none comes back")


func test_salvage_is_unavailable_with_no_device_up() -> void:
	assert_false(AbilityCommand.is_available(_state.get_member(LIRA), _ability("salvage")))
	assert_false(_use("salvage"), "refused")
	assert_eq(_ac(), 12)


func test_salvage_never_refunds_past_the_pool_maximum() -> void:
	_use("mending_engine")
	_state.get_member(LIRA)["ac"] = 11
	_use("salvage")
	assert_eq(_ac(), 12, "capped at 12")


# --- Shock Coil: at the start of each of Lira's turns, for three of them ---


func test_shock_coil_strikes_at_the_start_of_each_of_lira_s_next_three_turns() -> void:
	seed(12345)
	_run(_state.begin_turn(LIRA))
	_use("shock_coil")
	_run(_state.tick_statuses(LIRA))  # the deploying turn ends: no tick yet
	assert_eq(_enemy_hits(0).size(), 0, "nothing on the turn it is deployed")
	for turn: int in range(3):
		_run(_state.begin_turn(LIRA))
		assert_eq(_enemy_hits(0).size(), turn + 1, "a tick as turn %d begins" % (turn + 1))
		_run(_state.tick_statuses(LIRA))
	assert_eq(_device_ids(), [] as Array[String], "spent after the third")
	_lira_turn()
	assert_eq(_enemy_hits(0).size(), 3, "three ticks in all")


func test_shock_coil_does_not_fire_on_an_ally_s_turn() -> void:
	_use("shock_coil")
	_run(_state.begin_turn(EDREN))
	_run(_state.tick_statuses(EDREN))
	assert_eq(_enemy_hits(0).size(), 0)
	assert_eq(_device_ids(), ["shock_coil"] as Array[String], "an ally's turn spends none")


func test_shock_coil_hits_as_a_storm_spell_of_power_10_from_lira_s_magic() -> void:
	var probe: Enemy = _make_enemy({"weaknesses": ["storm"]})
	_battle.enemies = [_make_enemy({"weaknesses": ["storm"]})] as Array[Node]
	var mag: int = _state.get_effective_stat(LIRA, "mag")
	seed(777)
	var expected: Dictionary = BattleActions.apply_magic_to_enemy(
		_state, LIRA, mag, 10, "storm", probe, 0
	)
	assert_true(expected.get("hit", false), "precondition: this seed lands")
	_use("shock_coil")
	seed(777)
	_run(_state.begin_turn(LIRA))
	assert_eq(_enemy_hits(0), [["enemy_0", expected["damage"], "magic"]], "one Storm tick")
	assert_eq(_battle.enemies[0].current_hp, 30000 - int(expected["damage"]), "the enemy took it")


func test_shock_coil_picks_among_living_enemies_only() -> void:
	var fallen: Enemy = _make_enemy({})
	fallen.is_alive = false
	_battle.enemies = [fallen, _make_enemy({})] as Array[Node]
	_use("shock_coil")
	for _turn: int in range(3):
		_lira_turn()
	assert_eq(_enemy_hits(0).size(), 0, "never the fallen enemy")
	assert_eq(_enemy_hits(1).size(), 3, "every tick on the living one")


func test_a_shock_coil_kill_is_reported_once() -> void:
	# The strike reports its kill; the battle cleans it up, announcing it and
	# taking it off the ATB: test_battle_device_seams.gd pins both.
	var dying: Enemy = _make_enemy({"hp": 1})
	_battle.enemies = [dying] as Array[Node]
	_use("shock_coil")
	for _turn: int in range(3):
		_lira_turn()
	assert_false(dying.is_alive, "a tick landed")
	assert_eq(_kills, ["enemy_0"] as Array[String], "its fall is reported once")


func test_shock_coils_stop_once_a_strike_s_aftermath_fells_lira() -> void:
	# Two coils, two 1-HP enemies, and a death burst (Shard Burst) that fells
	# Lira: the first kill ends her volley, so the second coil never fires.
	seed(12345)
	var first: Enemy = _make_enemy({"hp": 1})
	var second: Enemy = _make_enemy({"hp": 1})
	_battle.enemies = [first, second] as Array[Node]
	for e: Enemy in [first, second]:
		e.died.connect(func() -> void: _state.take_damage(LIRA, 99999))
	_use("shock_coil")
	_use("shock_coil")
	_run(_state.begin_turn(LIRA))
	assert_false(_state.get_member(LIRA)["is_alive"], "precondition: a coil killed and Lira fell")
	assert_eq(int(first.is_alive) + int(second.is_alive), 1, "one enemy still stands")
	assert_eq(_hits.size(), 1, "one strike in all")


# --- Mending Engine: at the end of each of Lira's turns, for four of them ---


func test_mending_engine_heals_the_most_injured_ally_as_lira_s_next_four_turns_end() -> void:
	_state.get_member(EDREN)["current_hp"] = 500
	_state.get_member(MAREN)["current_hp"] = 400
	_run(_state.begin_turn(LIRA))
	_use("mending_engine")
	_run(_state.tick_statuses(LIRA))
	assert_eq(_state.get_member(MAREN)["current_hp"], 400, "no heal on the deploying turn")
	_lira_turn()
	assert_eq(_state.get_member(MAREN)["current_hp"], 550, "15% of 1000 to the lowest")
	_lira_turn()
	assert_eq(_state.get_member(EDREN)["current_hp"], 650, "then whoever is lowest now")
	_lira_turn()
	_lira_turn()
	assert_eq(_device_ids(), [] as Array[String], "spent after the fourth")
	var total: int = 0
	for m: int in range(4):
		total += int(_state.get_member(m)["current_hp"])
	_lira_turn()
	var after: int = 0
	for m: int in range(4):
		after += int(_state.get_member(m)["current_hp"])
	assert_eq(after, total, "no fifth heal")


func test_mending_engine_heals_show_as_heal_numbers_on_the_ally() -> void:
	_state.get_member(CAEL)["current_hp"] = 100
	_use("mending_engine")
	_lira_turn()
	assert_has(_hits, ["party_%d" % CAEL, 150, "heal"])


func test_mending_engine_rests_when_nobody_is_hurt() -> void:
	_use("mending_engine")
	_lira_turn()
	assert_eq(_hits, [], "no heal to show")
	assert_eq(_device_ids(), ["mending_engine"] as Array[String], "but the turn still counts")


func test_mending_engine_passes_over_a_fallen_ally() -> void:
	_state.take_damage(CAEL, 99999)
	_state.get_member(MAREN)["current_hp"] = 900
	_use("mending_engine")
	_lira_turn()
	assert_eq(_state.get_member(CAEL)["current_hp"], 0, "the fallen stay down")
	assert_eq(_state.get_member(MAREN)["current_hp"], 1000, "the living hurt one is healed")


func test_mending_engine_breaks_a_tie_toward_the_lower_slot() -> void:
	_state.get_member(CAEL)["current_hp"] = 500
	_state.get_member(MAREN)["current_hp"] = 500
	_use("mending_engine")
	_lira_turn()
	assert_eq(_state.get_member(CAEL)["current_hp"], 650, "Cael, slot 1, is healed")
	assert_eq(_state.get_member(MAREN)["current_hp"], 500, "Maren, slot 3, waits")


# --- A KO on Lira ends her devices (2026-10-30 ruling) ---


func test_lira_fainting_ends_every_device_she_has_up_without_refund() -> void:
	_use("shock_coil")
	_use("bulkhead", EDREN)
	_state.take_damage(LIRA, 99999)
	assert_eq(_device_ids(), [] as Array[String], "both gone")
	assert_eq(_ac(), 12 - 2 - 3, "no AC back")


func test_a_shock_coil_does_not_return_when_lira_is_revived() -> void:
	_use("shock_coil")
	_state.take_damage(LIRA, 99999)
	_state.heal(LIRA, 500, true)
	for _turn: int in range(3):
		_lira_turn()
	assert_eq(_enemy_hits(0).size(), 0, "the coil never fires again")


# --- The battle menu deploys a field device without a target pick ---


func test_shock_coil_and_arc_trap_deploy_without_a_target_pick() -> void:
	# battle_command_menu.gd confirms these target types at once; every other
	# one opens target selection.
	var no_pick: Array[String] = ["all_enemies", "all_allies", "self"]
	var lira: Dictionary = {"character_id": "lira", "level": 99}
	for item: Dictionary in SubmenuItems.abilities(lira, _state.get_member(LIRA)):
		var id: String = item["command"]["ability"]["id"]
		if id in ["shock_coil", "arc_trap"]:
			assert_has(no_pick, item["target_type"], "%s needs no pick" % id)


# --- Listeners hear devices come and go ---


func test_deploying_and_losing_a_device_is_signalled() -> void:
	watch_signals(_state)
	_use("shock_coil")
	assert_signal_emitted_with_parameters(_state, "ability_state_changed", [LIRA])
	var deployed: int = get_signal_emit_count(_state, "ability_state_changed")
	_use("salvage")
	assert_gt(get_signal_emit_count(_state, "ability_state_changed"), deployed, "and salvaged")
