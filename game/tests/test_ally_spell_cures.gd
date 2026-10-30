extends GutTest
## Cure, MP-restore and revival ally spells land in battle, and the ally spells
## with no battle effect built yet are refused rather than spent (#503).
##
## The values are each spell's own magic.md entry:
##   - Purge (§ 42) removes every negative status but Stop and Despair, which
##     leaves Berserk curable by it alone (§ Status Effect Reference);
##   - Cleansing Draught (§ 41) removes one of Poison, Burn, Sleep, Confusion,
##     Silence and Blind;
##   - Hollow Mend (§ 88) heals and removes Despair;
##   - Leydraught (§ 43) costs 15% of the caster's max HP and restores 20% of the
##     target's max MP;
##   - Spirit Recall (§ 39) revives at 25% of max HP, Second Dawn (§ 40) at 75%.
## A revival spell turned on an Undead kills it, as a revival item does
## (bestiary/README.md § Undead), and is refused on anything else (2026-10-30
## ruling). A positive effect is never cured.
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")

const PROMPT_TIMEOUT: float = 5.0
## New-game party: Edren in slot 0 casts, Cael in slot 1 is cast on.
const CASTER: int = 0
const TARGET: int = 1

## The ally spells with no battle effect built yet: Reflect, auto-revive,
## Float and Forgeshield's absorb are later slices of #503, and Waymark,
## Linewalk and Veilstep are field spells (magic.md § 73-75).
const UNBUILT: Array = [
	["ley_line", "leymirror"],
	["spirit", "last_breath"],
	["ley_line", "drift"],
	["forgewright", "forgeshield"],
	["ley_line", "waymark"],
	["ley_line", "linewalk"],
	["spirit", "veilstep"],
]

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func _boot(encounter: Array = ["ley_vermin"], act: String = "act_i") -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": act,
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


## A shipped spell, free to cast unless [param mp] says otherwise.
func _spell(tradition: String, spell_id: String, mp: int = 0) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = mp
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


func _submit(battle: Node, spell: Dictionary, target: int, on_enemy: bool = false) -> void:
	var command: Dictionary = {"type": "magic", "spell": spell, "target": target}
	if on_enemy:
		command["target_enemy"] = true
	battle.get_node("BattleUI").command_submitted.emit(command)


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


func _status_names(battle: Node, slot: int) -> Array[String]:
	var out: Array[String] = []
	for s: Dictionary in battle.get_battle_state().get_member(slot).get("active_statuses", []):
		out.append(String(s.get("name", "")))
	out.sort()
	return out


func _afflict(battle: Node, statuses: Array) -> void:
	var state: Node = battle.get_battle_state()
	for status: String in statuses:
		if status == "stop":
			state.apply_status(TARGET, status, "realtime", 3.0)
		else:
			state.apply_status(TARGET, status, "turns", 3.0)


func _mp(battle: Node, slot: int) -> int:
	return int(battle.get_battle_state().get_member(slot)["current_mp"])


func _hp(battle: Node, slot: int) -> int:
	return int(battle.get_battle_state().get_member(slot)["current_hp"])


# ── Cures ────────────────────────────────────────────────────────────────


func test_purge_cures_every_ailment_but_stop_and_despair() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	var ailments: Array = [
		"poison", "burn", "sleep", "confusion", "silence", "blind", "petrify", "slow", "paralysis"
	]
	_afflict(battle, ailments + ["stop", "despair"])

	_submit(battle, _spell("ley_line", "purge"), TARGET)

	assert_eq(_status_names(battle, TARGET), ["despair", "stop"] as Array[String])


func test_purge_cures_berserk() -> void:
	# Berserk is cured by "Purge only" (magic.md § Status Effect Reference >
	# 'Berserk'). Applied
	# directly, so this holds whether or not the registry has a Berserk row yet.
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_afflict(battle, ["berserk"])
	assert_eq(_status_names(battle, TARGET), ["berserk"] as Array[String], "precondition")

	_submit(battle, _spell("ley_line", "purge"), TARGET)

	assert_eq(_status_names(battle, TARGET), [] as Array[String], "Berserk is cured")


func test_a_cure_leaves_positive_effects_alone() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	var state: Node = battle.get_battle_state()
	state.get_member(TARGET)["effective_stats"]["def"] = 100
	_submit(battle, _spell("spirit", "ironhide"), TARGET)
	_afflict(battle, ["haste", "poison"])
	if not await _await_prompt(battle):
		return

	_submit(battle, _spell("ley_line", "purge"), TARGET)

	assert_eq(_status_names(battle, TARGET), ["haste"] as Array[String], "Haste stays")
	assert_eq(state.get_effective_stat(TARGET, "def"), 140, "and so does Ironhide")


func test_cleansing_draught_cures_a_listed_ailment() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_afflict(battle, ["silence"])

	_submit(battle, _spell("spirit", "cleansing_draught"), TARGET)

	assert_eq(_status_names(battle, TARGET), [] as Array[String], "Silence is cured")


func test_cleansing_draught_cures_the_first_listed_ailment_only() -> void:
	# 2026-10-30 ruling: one per cast, the first in magic.md § 41's order
	# (Poison, Burn, Sleep, Confusion, Silence, Blind), whatever order they
	# landed in.
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_afflict(battle, ["blind", "sleep", "burn"])

	_submit(battle, _spell("spirit", "cleansing_draught"), TARGET)

	assert_eq(_status_names(battle, TARGET), ["blind", "sleep"] as Array[String], "Burn goes")


func test_cleansing_draught_leaves_what_it_does_not_list() -> void:
	# Petrify and Slow are "Not cured by Cleansing Draught"
	# (items.md § Status Cure Mapping > 'Not cured by Cleansing Draught').
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_afflict(battle, ["petrify", "slow"])

	_submit(battle, _spell("spirit", "cleansing_draught"), TARGET)

	assert_eq(_status_names(battle, TARGET), ["petrify", "slow"] as Array[String])


func test_hollow_mend_heals_and_lifts_despair() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	var m: Dictionary = battle.get_battle_state().get_member(TARGET)
	m["max_hp"] = 5000
	m["current_hp"] = 10
	_afflict(battle, ["despair"])

	_submit(battle, _spell("void", "hollow_mend"), TARGET)

	assert_eq(_status_names(battle, TARGET), [] as Array[String], "Despair is lifted")
	assert_gt(_hp(battle, TARGET), 10, "and the heal lands")


# ── MP restore ───────────────────────────────────────────────────────────


func _pin_leydraught(battle: Node, caster_hp: int) -> void:
	var state: Node = battle.get_battle_state()
	var caster: Dictionary = state.get_member(CASTER)
	caster["max_hp"] = 1000
	caster["current_hp"] = caster_hp
	var target: Dictionary = state.get_member(TARGET)
	target["max_mp"] = 200
	target["current_mp"] = 0


func test_leydraught_trades_15_percent_caster_hp_for_20_percent_target_mp() -> void:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return
	_pin_leydraught(battle, 1000)

	_submit(battle, _spell("ley_line", "leydraught"), TARGET)

	assert_eq(_mp(battle, TARGET), 40, "20% of the target's 200 max MP")
	assert_eq(_hp(battle, CASTER), 850, "for 15% of the caster's 1000 max HP")


func test_leydraught_is_refused_when_the_caster_cannot_pay_its_hp() -> void:
	var battle: Node = _boot()
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	_pin_leydraught(battle, 150)

	_submit(battle, _spell("ley_line", "leydraught"), TARGET)

	assert_has(said, "Not enough HP!", str(said))
	assert_eq(_hp(battle, CASTER), 150, "the caster keeps its HP")
	assert_eq(_mp(battle, TARGET), 0, "and the target gains nothing")


# ── Revival ──────────────────────────────────────────────────────────────


func _revive(spell_id: String, tradition: String) -> Node:
	var battle: Node = _boot()
	if not await _await_prompt(battle):
		return null
	var state: Node = battle.get_battle_state()
	state.get_member(TARGET)["max_hp"] = 400
	state.take_damage(TARGET, 99999)
	assert_false(state.get_member(TARGET)["is_alive"], "precondition: the target has fainted")
	_submit(battle, _spell(tradition, spell_id), TARGET)
	return battle


func test_spirit_recall_revives_a_fainted_ally_at_25_percent_hp() -> void:
	var battle: Node = await _revive("spirit_recall", "spirit")
	if battle == null:
		return
	assert_true(battle.get_battle_state().get_member(TARGET)["is_alive"], "back on their feet")
	assert_eq(_hp(battle, TARGET), 100, "at 25% of 400")


func test_second_dawn_revives_a_fainted_ally_at_75_percent_hp() -> void:
	var battle: Node = await _revive("second_dawn", "ley_line")
	if battle == null:
		return
	assert_true(battle.get_battle_state().get_member(TARGET)["is_alive"], "back on their feet")
	assert_eq(_hp(battle, TARGET), 300, "at 75% of 400")


func test_a_revive_on_a_living_ally_is_refused_before_mp() -> void:
	var battle: Node = _boot()
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().get_member(CASTER)["current_mp"] = 50

	_submit(battle, _spell("spirit", "spirit_recall", 20), TARGET)

	assert_eq(_mp(battle, CASTER), 50, "no MP spent")
	assert_has(said, "No effect!", str(said))


func test_a_revive_turned_on_an_undead_kills_it() -> void:
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	watch_signals(battle)
	if not await _await_prompt(battle):
		return

	_submit(battle, _spell("spirit", "spirit_recall"), 0, true)

	assert_eq(dead.current_hp, 0, "its HP goes to 0")
	assert_false(dead.is_alive, "the Undead falls")
	assert_signal_emitted_with_parameters(battle, "combatant_died", ["enemy_0"])


func test_a_revive_turned_on_a_pallor_is_refused_before_mp() -> void:
	var battle: Node = _boot(["pallor_vermin"], "act_iii")
	var pallor: Node = battle.get_enemies()[0]
	var hp: int = pallor.current_hp
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().get_member(CASTER)["current_mp"] = 50

	_submit(battle, _spell("spirit", "spirit_recall", 20), 0, true)

	assert_eq(pallor.current_hp, hp, "the Pallor is untouched")
	assert_eq(_mp(battle, CASTER), 50, "no MP spent")
	assert_has(said, "No effect!", str(said))


func test_a_revive_turned_on_a_living_normal_enemy_is_refused_before_mp() -> void:
	var battle: Node = _boot()
	var vermin: Node = battle.get_enemies()[0]
	var hp: int = vermin.current_hp
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().get_member(CASTER)["current_mp"] = 50

	_submit(battle, _spell("spirit", "spirit_recall", 20), 0, true)

	assert_eq(vermin.current_hp, hp, "nothing to revive")
	assert_eq(_mp(battle, CASTER), 50, "no MP spent")
	assert_has(said, "No effect!", str(said))


# ── Not built yet ────────────────────────────────────────────────────────


func test_ally_spells_with_no_battle_effect_are_refused_before_mp() -> void:
	var battle: Node = _boot()
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	battle.get_battle_state().get_member(CASTER)["current_mp"] = 50
	for pair: Array in UNBUILT:
		_submit(battle, _spell(pair[0], pair[1], 1), TARGET)
		assert_eq(_mp(battle, CASTER), 50, "%s spends no MP" % pair[1])
	var refusals: Array[String] = said.filter(func(t: String) -> bool: return t == "No effect!")
	assert_eq(refusals.size(), UNBUILT.size(), "each is refused out loud: %s" % str(said))
	assert_false(said.any(func(t: String) -> bool: return " casts " in t), "none is cast")
