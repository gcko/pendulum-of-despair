extends GutTest
## Stat-buff and regeneration ally spells land in battle (#503). Before this the
## Magic command sent every one of them down the heal path with power 0: the
## cast spent MP and changed nothing.
##
## The values are each spell's own magic.md entry: Ironhide and Wardglass +40%
## DEF / MDEF for 5 turns, Bulwark Line and Leyward +25% to the party for 4,
## Rallying Cry +30% ATK and Attunement +30% MAG for 5; Kindle Breath and
## Rekindling restore 5% max HP per turn for 4 turns.
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted,
## the seam the battle menu feeds. A turn is driven through BattleState's
## begin_turn / tick_statuses, the pair the battle loop calls around each
## member's turn, so what each test reads is what the player's stats and HP bar
## would show.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

const PROMPT_TIMEOUT: float = 5.0
## New-game party: Edren in slot 0 casts, Cael in slot 1 is cast on.
const CASTER: int = 0
const TARGET: int = 1
## The stat value each buff test starts from, so +40% reads as 140.
const BASE_STAT: int = 100

## [tradition, spell id, stat, +%, turns, all-allies], from magic.md § 56-64.
const STAT_BUFFS: Array = [
	["spirit", "ironhide", "def", 40, 5, false],
	["ley_line", "wardglass", "mdef", 40, 5, false],
	["ley_line", "rallying_cry", "atk", 30, 5, false],
	["ley_line", "attunement", "mag", 30, 5, false],
	["spirit", "bulwark_line", "def", 25, 4, true],
	["ley_line", "leyward", "mdef", 25, 4, true],
]

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	_free_battle()
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _free_battle() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null


func _boot(encounter: Array = ["ley_vermin"]) -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


func _await_prompt(battle: Node) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge("party_%d" % CASTER, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not "party_%d" % CASTER in prompted:
		fail_test("the battle never asked the caster for a command (asked: %s)" % str(prompted))
		return false
	return true


## A shipped spell, free to cast so the new-game party can afford it.
func _spell(tradition: String, spell_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


## Wait for the caster's prompt, then cast [param spell] on [param target].
func _cast(battle: Node, spell: Dictionary, target: int = TARGET) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": target}
	)
	return true


## One turn of [param slot]'s: its start, then its end.
func _take_turn(state: Node, slot: int) -> void:
	state.begin_turn(slot)
	state.tick_statuses(slot)


func _stat(battle: Node, slot: int, stat: String) -> int:
	return battle.get_battle_state().get_effective_stat(slot, stat)


func _set_base(battle: Node, stat: String) -> void:
	for slot: int in [CASTER, TARGET]:
		battle.get_battle_state().get_member(slot)["effective_stats"][stat] = BASE_STAT


func _buffed(pct: int) -> int:
	return BASE_STAT * (100 + pct) / 100


# ── Stat buffs ───────────────────────────────────────────────────────────


## Cast the STAT_BUFFS row for [param spell_id] and check what the player
## would see: the stat raised by the spell's percentage on its target (and on
## the caster only for a party buff), still up one turn short of its duration,
## and back to normal when that duration runs out. One battle per test, as
## every battle-booting test file here keeps it.
func _check_stat_buff(spell_id: String) -> void:
	var row: Array = STAT_BUFFS.filter(func(r: Array) -> bool: return r[1] == spell_id)[0]
	var stat: String = row[2]
	var battle: Node = _boot()
	_set_base(battle, stat)
	if not await _cast(battle, _spell(row[0], spell_id)):
		return
	assert_eq(_stat(battle, TARGET, stat), _buffed(row[3]), "%s on its target" % spell_id)
	assert_eq(
		_stat(battle, CASTER, stat),
		_buffed(row[3]) if row[5] else BASE_STAT,
		"%s %s the caster" % [spell_id, "reaches" if row[5] else "spares"]
	)
	var state: Node = battle.get_battle_state()
	for turn: int in range(int(row[4]) - 1):
		_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, stat), _buffed(row[3]), "%s still up" % spell_id)
	_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, stat), BASE_STAT, "%s gone after %d turns" % [spell_id, row[4]])


func test_ironhide_raises_def_40_percent_for_5_turns() -> void:
	await _check_stat_buff("ironhide")


func test_wardglass_raises_mdef_40_percent_for_5_turns() -> void:
	await _check_stat_buff("wardglass")


func test_rallying_cry_raises_atk_30_percent_for_5_turns() -> void:
	await _check_stat_buff("rallying_cry")


func test_attunement_raises_mag_30_percent_for_5_turns() -> void:
	await _check_stat_buff("attunement")


func test_bulwark_line_raises_the_party_s_def_25_percent_for_4_turns() -> void:
	await _check_stat_buff("bulwark_line")


func test_leyward_raises_the_party_s_mdef_25_percent_for_4_turns() -> void:
	await _check_stat_buff("leyward")


func test_a_party_buff_lasts_as_long_on_its_caster_as_on_the_party() -> void:
	# The caster's own turn was open at the cast; its end must not spend one.
	var battle: Node = _boot()
	_set_base(battle, "def")
	if not await _cast(battle, _spell("spirit", "bulwark_line")):
		return
	var state: Node = battle.get_battle_state()
	for turn: int in range(3):
		_take_turn(state, CASTER)
	assert_eq(_stat(battle, CASTER, "def"), _buffed(25), "three turns after the cast, still up")
	_take_turn(state, CASTER)
	assert_eq(_stat(battle, CASTER, "def"), BASE_STAT, "the fourth ends it")


func test_a_self_cast_buff_lasts_its_full_duration_after_the_casting_turn() -> void:
	var battle: Node = _boot()
	_set_base(battle, "def")
	if not await _cast(battle, _spell("spirit", "ironhide"), CASTER):
		return
	var state: Node = battle.get_battle_state()
	for turn: int in range(4):
		_take_turn(state, CASTER)
	assert_eq(_stat(battle, CASTER, "def"), _buffed(40), "four turns on, Ironhide holds")
	_take_turn(state, CASTER)
	assert_eq(_stat(battle, CASTER, "def"), BASE_STAT, "the fifth ends it")


func test_recasting_a_buff_refreshes_it_rather_than_stacking() -> void:
	# progression.md, Buff stacking: "Recasting Protect refreshes the duration
	# but does not double the bonus."
	var battle: Node = _boot()
	_set_base(battle, "def")
	var state: Node = battle.get_battle_state()
	if not await _cast(battle, _spell("spirit", "ironhide")):
		return
	for turn: int in range(3):
		_take_turn(state, TARGET)
	if not await _cast(battle, _spell("spirit", "ironhide")):
		return
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "+40%, not +80%")
	for turn: int in range(4):
		_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "the clock restarted at the recast")
	_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, "def"), BASE_STAT, "five turns after the recast, gone")


func test_a_weaker_buff_never_overwrites_a_stronger_one_of_the_same_stat() -> void:
	# 2026-10-30 ruling: same-type stat buffs keep the stronger. Bulwark Line's
	# +25% leaves Ironhide's +40% in place, on its own clock.
	var battle: Node = _boot()
	_set_base(battle, "def")
	var state: Node = battle.get_battle_state()
	if not await _cast(battle, _spell("spirit", "ironhide")):
		return
	for turn: int in range(2):
		_take_turn(state, TARGET)
	if not await _cast(battle, _spell("spirit", "bulwark_line")):
		return
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "Ironhide's +40% holds")
	assert_eq(_stat(battle, CASTER, "def"), _buffed(25), "the unbuffed caster gets +25%")
	for turn: int in range(2):
		_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "four turns in, still Ironhide")
	_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, "def"), BASE_STAT, "Ironhide ends on its own fifth turn")


func test_leyward_never_overwrites_wardglass() -> void:
	var battle: Node = _boot()
	_set_base(battle, "mdef")
	if not await _cast(battle, _spell("ley_line", "wardglass")):
		return
	if not await _cast(battle, _spell("ley_line", "leyward")):
		return
	assert_eq(_stat(battle, TARGET, "mdef"), _buffed(40), "Wardglass's +40% holds")


func test_a_stronger_buff_replaces_a_weaker_one_and_restarts_the_clock() -> void:
	var battle: Node = _boot()
	_set_base(battle, "def")
	var state: Node = battle.get_battle_state()
	if not await _cast(battle, _spell("spirit", "bulwark_line")):
		return
	for turn: int in range(3):
		_take_turn(state, TARGET)
	if not await _cast(battle, _spell("spirit", "ironhide")):
		return
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "Ironhide's +40% replaces +25%")
	for turn: int in range(4):
		_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "on Ironhide's own 5-turn clock")
	_take_turn(state, TARGET)
	assert_eq(_stat(battle, TARGET, "def"), BASE_STAT, "five turns after it landed, gone")


func test_a_spell_buff_adds_to_an_item_boost_rather_than_replacing_it() -> void:
	# combat-formulas.md § Buff & Debuff Interaction: buffs on one stat add
	# their percentages, then floor once.
	var battle: Node = _boot()
	_set_base(battle, "atk")
	battle.get_battle_state().set_buff(TARGET, "atk_mult", 1.1)
	if not await _cast(battle, _spell("ley_line", "rallying_cry")):
		return
	assert_eq(_stat(battle, TARGET, "atk"), _buffed(40), "+10% item and +30% Rallying Cry")


func test_a_stat_buff_ends_when_its_bearer_faints() -> void:
	var battle: Node = _boot()
	_set_base(battle, "def")
	if not await _cast(battle, _spell("spirit", "ironhide")):
		return
	assert_eq(_stat(battle, TARGET, "def"), _buffed(40), "precondition: Ironhide is up")
	var state: Node = battle.get_battle_state()
	state.take_damage(TARGET, 99999)
	state.heal(TARGET, 10, true)
	assert_eq(_stat(battle, TARGET, "def"), BASE_STAT, "a KO ends a positive effect")


# ── Regeneration ─────────────────────────────────────────────────────────


func _pin_hp(battle: Node, slot: int, max_hp: int, hp: int) -> void:
	var m: Dictionary = battle.get_battle_state().get_member(slot)
	m["max_hp"] = max_hp
	m["current_hp"] = hp


func _hp(battle: Node, slot: int) -> int:
	return int(battle.get_battle_state().get_member(slot)["current_hp"])


func test_kindle_breath_restores_5_percent_max_hp_each_turn_for_4_turns() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_pin_hp(battle, TARGET, 1000, 100)
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": _spell("spirit", "kindle_breath"), "target": TARGET}
	)
	var state: Node = battle.get_battle_state()
	var seen: Array[int] = []
	for turn: int in range(5):
		_take_turn(state, TARGET)
		seen.append(_hp(battle, TARGET))
	assert_eq(seen, [150, 200, 250, 300, 300] as Array[int], "50 HP a turn, four turns")


func test_a_regeneration_tick_is_shown_as_a_heal() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_pin_hp(battle, TARGET, 1000, 100)
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": _spell("spirit", "kindle_breath"), "target": TARGET}
	)
	assert_eq(
		battle.get_battle_state().begin_turn(TARGET),
		[{"slot": TARGET, "dmg": 50, "type": "heal"}],
		"the turn's start hands the battle a heal number to show"
	)


func test_rekindling_regenerates_every_living_ally() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	for slot: int in [CASTER, TARGET]:
		_pin_hp(battle, slot, 1000, 100)
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": _spell("spirit", "rekindling"), "target": 0}
	)
	var state: Node = battle.get_battle_state()
	for slot: int in [CASTER, TARGET]:
		_take_turn(state, slot)
		assert_eq(_hp(battle, slot), 150, "slot %d regenerates 5%%" % slot)


func test_regeneration_ends_when_its_bearer_faints() -> void:
	var battle: Node = _boot()
	if not await _cast(battle, _spell("spirit", "kindle_breath")):
		return
	var state: Node = battle.get_battle_state()
	_pin_hp(battle, TARGET, 1000, 100)
	_take_turn(state, TARGET)
	assert_eq(_hp(battle, TARGET), 150, "precondition: the regeneration is running")
	state.take_damage(TARGET, 99999)
	state.heal(TARGET, 10, true)
	_take_turn(state, TARGET)
	assert_eq(_hp(battle, TARGET), 10, "the KO ended the regeneration")


func test_kindle_breath_turned_on_an_enemy_is_refused_before_mp() -> void:
	# The enemy-side Regen tick is not built (it lives in the enemy's turn), so
	# the cast is refused rather than spent on a status that would never heal.
	var battle: Node = _boot()
	var state: Node = battle.get_battle_state()
	var said: Array[String] = []
	battle.message.connect(func(text: String) -> void: said.append(text))
	if not await _await_prompt(battle):
		return
	state.get_member(CASTER)["current_mp"] = 50
	var spell: Dictionary = _spell("spirit", "kindle_breath")
	spell["mp_cost"] = 6
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": 0, "target_enemy": true}
	)
	assert_eq(int(state.get_member(CASTER)["current_mp"]), 50, "no MP spent")
	assert_has(said, "No effect!", "and the player is told: %s" % str(said))
