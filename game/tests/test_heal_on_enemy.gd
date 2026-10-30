extends GutTest
## A heal turned on the enemy line (#178a). The battle menu lets a single-ally
## spell or item cross to the enemies (ui-design.md § 2.6); what it then does
## depends on the enemy's type:
##   - a normal enemy is healed by it;
##   - an Undead takes the heal as damage (bestiary/README.md § Undead: "Healing
##     spells deal damage") and a revival item kills it outright ("Revival items
##     deal max damage (instant kill)");
##   - a Pallor takes the heal as damage too (combat-formulas.md § Tier 2:
##     Pallor Feedback, "Deals damage equal to heal amount").
## The damage is the heal the spell rolled — its own variance, its own 14,999
## cap — with no element or type multiplier at all (not Spirit's 1.5x on
## Undead, not the enemy's own Spirit weakness), and it counts as spell damage:
## threat for the caster and Weave Gauge for the cast. Healing a normal enemy
## earns no Weave Gauge, and a revival item is refused on a Pallor
## (2026-10-29 rulings).
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted,
## the seam the menu feeds, as test_battle_magic_command.gd does.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")

const PROMPT_TIMEOUT: float = 5.0
const CASTER: int = 0
## The variance roll a cast draws; reused to compute the heal it will roll.
const HEAL_SEED: int = 4242
## The caster MAG every cast here uses, so the heal is well clear of 0.
const CASTER_MAG: int = 30

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
	randomize()


func _boot(encounter: Array, act: String = "act_i") -> Node:
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
	battle.get_battle_state().get_member(CASTER)["effective_stats"]["mag"] = CASTER_MAG
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


func _submit(battle: Node, command: Dictionary) -> void:
	battle.get_node("BattleUI").command_submitted.emit(command)


## Give the enemy [param max_hp] maximum and [param hp] current HP, on a copy
## of its data so the cached enemy table is untouched.
func _pin_hp(enemy: Node, max_hp: int, hp: int) -> void:
	var data: Dictionary = enemy.enemy_data.duplicate(true)
	data["hp"] = max_hp
	enemy.enemy_data = data
	enemy.current_hp = hp


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


## Every damage_dealt as "target:type:amount".
func _markers(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.damage_dealt.connect(
		func(tid: String, amt: int, dt: String) -> void: out.append("%s:%s:%d" % [tid, dt, amt])
	)
	return out


## A shipped spell from [param tradition], free to cast.
func _spell(tradition: String, spell_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


func _item(item_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_items("consumables"):
		if (entry as Dictionary).get("id", "") == item_id:
			return entry
	fail_test("consumables.json has no %s" % item_id)
	return {}


func _count(item_id: String) -> int:
	return int(PartyState.get_consumables().get(item_id, 0))


## The heal [param spell] rolls at CASTER_MAG on HEAL_SEED — what the cast will
## roll once the seed is set again.
func _rolled_heal(spell: Dictionary) -> int:
	seed(HEAL_SEED)
	return DamageCalc.calculate_healing(CASTER_MAG, int(spell.get("power", 0)))


func _cast_on_enemy(battle: Node, spell: Dictionary) -> void:
	seed(HEAL_SEED)
	_submit(battle, {"type": "magic", "spell": spell, "target": 0, "target_enemy": true})


# ── A normal enemy is healed ─────────────────────────────────────────────


func test_a_heal_spell_on_a_normal_enemy_heals_it() -> void:
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_hp(vermin, 5000, 100)
	var mend: Dictionary = _spell("spirit", "mend")
	var markers: Array[String] = _markers(battle)
	if not await _await_prompt(battle):
		return
	var heal: int = _rolled_heal(mend)

	_cast_on_enemy(battle, mend)

	assert_eq(vermin.current_hp, 100 + heal, "the vermin gains the rolled heal")
	assert_has(markers, "enemy_0:heal:%d" % heal, "shown as a heal: %s" % str(markers))


func test_healing_a_normal_enemy_earns_no_weave_gauge() -> void:
	var battle: Node = _boot(["ley_vermin"])
	_pin_hp(battle.get_enemies()[0], 5000, 100)
	var state: Node = battle.get_battle_state()
	state.add_member(2, {"character_id": "maren", "base_stats": {"hp": 100, "mp": 10}})
	if not await _await_prompt(battle):
		return

	_cast_on_enemy(battle, _spell("spirit", "mend"))

	assert_gt(battle.get_enemies()[0].current_hp, 100, "precondition: the vermin was healed")
	assert_eq(int(state.get_member(2).get("wg", 0)), 0, "Maren banks nothing for it")


func test_a_heal_lands_on_the_enemy_the_cursor_chose() -> void:
	var battle: Node = _boot(["restless_dead", "restless_dead"])
	var first: Node = battle.get_enemies()[0]
	var second: Node = battle.get_enemies()[1]
	_pin_hp(first, 5000, 5000)
	_pin_hp(second, 5000, 5000)
	var mend: Dictionary = _spell("spirit", "mend")
	if not await _await_prompt(battle):
		return
	var heal: int = _rolled_heal(mend)

	seed(HEAL_SEED)
	_submit(battle, {"type": "magic", "spell": mend, "target": 1, "target_enemy": true})

	assert_eq(first.current_hp, 5000, "the first Undead is untouched")
	assert_eq(second.current_hp, 5000 - heal, "the second takes the heal")


# ── An Undead takes the heal as damage ───────────────────────────────────


func test_a_heal_spell_on_an_undead_deals_the_rolled_heal_as_damage() -> void:
	# Mend is Spirit: Spirit deals 1.5x to Undead, and the Restless Dead is
	# itself weak to Spirit. Neither applies — the damage is the heal amount.
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 5000, 5000)
	var mend: Dictionary = _spell("spirit", "mend")
	var markers: Array[String] = _markers(battle)
	if not await _await_prompt(battle):
		return
	var heal: int = _rolled_heal(mend)
	assert_gt(heal, 0, "precondition: the heal is not empty")

	_cast_on_enemy(battle, mend)

	assert_eq(dead.current_hp, 5000 - heal, "loses exactly the heal, no Spirit bonus")
	assert_has(markers, "enemy_0:magic:%d" % heal, "shown as damage: %s" % str(markers))


func test_heal_damage_on_an_undead_is_capped_at_14999() -> void:
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 99999, 99999)
	battle.get_battle_state().get_member(CASTER)["effective_stats"]["mag"] = 9999
	if not await _await_prompt(battle):
		return

	seed(HEAL_SEED)
	_submit(
		battle,
		{
			"type": "magic",
			"spell": _spell("spirit", "resurgence"),
			"target": 0,
			"target_enemy": true
		}
	)

	assert_eq(dead.current_hp, 99999 - 14999, "the heal's own cap bounds the damage")


func test_heal_damage_counts_as_spell_damage_for_threat_and_weave_gauge() -> void:
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 5000, 5000)
	var state: Node = battle.get_battle_state()
	state.add_member(2, {"character_id": "maren", "base_stats": {"hp": 100, "mp": 10}})
	var mend: Dictionary = _spell("spirit", "mend")
	if not await _await_prompt(battle):
		return
	var heal: int = _rolled_heal(mend)
	var threat_before: int = int(state.get_member(CASTER).get("threat_dealt", 0))

	_cast_on_enemy(battle, mend)

	assert_eq(
		int(state.get_member(CASTER).get("threat_dealt", 0)) - threat_before,
		heal,
		"the caster draws threat for the damage"
	)
	assert_eq(int(state.get_member(2).get("wg", 0)), 10, "and Maren banks Weave Gauge for it")


func test_a_heal_that_drops_an_undead_to_zero_kills_it() -> void:
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 5000, 1)
	watch_signals(battle)
	if not await _await_prompt(battle):
		return
	battle.get_atb().set_gauge("enemy_0", 5000)

	_cast_on_enemy(battle, _spell("spirit", "mend"))

	assert_false(dead.is_alive, "the Undead falls")
	assert_signal_emitted_with_parameters(battle, "combatant_died", ["enemy_0"])
	assert_eq(battle.get_atb().get_gauge("enemy_0"), 0, "and leaves the ATB")
	assert_signal_emitted(battle, "victory", "and its fall ends the battle")


# ── Pallor Feedback ──────────────────────────────────────────────────────


func test_a_heal_spell_on_a_pallor_enemy_deals_the_heal_as_damage() -> void:
	var battle: Node = _boot(["pallor_vermin"], "act_iii")
	var pallor: Node = battle.get_enemies()[0]
	_pin_hp(pallor, 5000, 5000)
	var leybalm: Dictionary = _spell("ley_line", "leybalm")
	var markers: Array[String] = _markers(battle)
	if not await _await_prompt(battle):
		return
	var heal: int = _rolled_heal(leybalm)

	_cast_on_enemy(battle, leybalm)

	assert_eq(pallor.current_hp, 5000 - heal, "Pallor Feedback: damage equal to the heal")
	assert_has(markers, "enemy_0:magic:%d" % heal, "shown as damage: %s" % str(markers))


# ── Revival items ────────────────────────────────────────────────────────


func test_a_revival_item_on_an_undead_kills_it_outright() -> void:
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 5000, 5000)
	PartyState.add_item("phoenix_down", 1)
	var held: int = _count("phoenix_down")
	watch_signals(battle)
	if not await _await_prompt(battle):
		return
	battle.get_atb().set_gauge("enemy_0", 5000)

	_submit(
		battle, {"type": "item", "item": _item("phoenix_down"), "target": 0, "target_enemy": true}
	)

	assert_eq(dead.current_hp, 0, "its HP goes to 0")
	assert_false(dead.is_alive, "the Undead falls")
	assert_signal_emitted_with_parameters(battle, "combatant_died", ["enemy_0"])
	assert_eq(battle.get_atb().get_gauge("enemy_0"), 0, "and leaves the ATB")
	assert_signal_emitted(battle, "victory", "and its fall ends the battle")
	assert_eq(_count("phoenix_down"), held - 1, "the Phoenix Down is spent")


func test_a_revival_item_on_a_living_normal_enemy_does_nothing() -> void:
	var battle: Node = _boot(["ley_vermin"])
	var vermin: Node = battle.get_enemies()[0]
	_pin_hp(vermin, 5000, 100)
	PartyState.add_item("phoenix_down", 1)
	var held: int = _count("phoenix_down")
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return

	_submit(
		battle, {"type": "item", "item": _item("phoenix_down"), "target": 0, "target_enemy": true}
	)

	assert_eq(vermin.current_hp, 100, "nothing to revive, so nothing happens")
	assert_has(said, "No effect!", "and the player is told: %s" % str(said))
	assert_eq(_count("phoenix_down"), held, "the Phoenix Down is kept")


func test_a_revival_item_on_a_pallor_enemy_is_refused_and_kept() -> void:
	# Only the Undead are slain by a revival item (2026-10-29 ruling).
	var battle: Node = _boot(["pallor_vermin"], "act_iii")
	var pallor: Node = battle.get_enemies()[0]
	_pin_hp(pallor, 5000, 5000)
	PartyState.add_item("phoenix_down", 1)
	var held: int = _count("phoenix_down")
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return

	_submit(
		battle, {"type": "item", "item": _item("phoenix_down"), "target": 0, "target_enemy": true}
	)

	assert_eq(pallor.current_hp, 5000, "the Pallor is untouched")
	assert_has(said, "No effect!", "and the player is told: %s" % str(said))
	assert_eq(_count("phoenix_down"), held, "the Phoenix Down is kept")


# ── What cannot be turned on an enemy ────────────────────────────────────


func test_a_spell_with_no_heal_turned_on_an_enemy_is_refused_before_mp() -> void:
	# Quickstep is a buff and Purge a status cure: neither restores HP, so
	# neither has an enemy-side rule. Refused before any MP is spent.
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 5000, 5000)
	var state: Node = battle.get_battle_state()
	state.get_member(CASTER)["current_mp"] = 50
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	for pair: Array in [["ley_line", "quickstep"], ["ley_line", "purge"]]:
		var spell: Dictionary = _spell(pair[0], pair[1])
		spell["mp_cost"] = 1
		var mp: int = int(state.get_member(CASTER)["current_mp"])

		_submit(battle, {"type": "magic", "spell": spell, "target": 0, "target_enemy": true})

		assert_eq(int(state.get_member(CASTER)["current_mp"]), mp, "%s spends no MP" % pair[1])
		assert_false(dead.has_status("haste"), "%s lands nothing on the enemy" % pair[1])
	assert_eq(dead.current_hp, 5000, "the Undead is untouched")
	assert_eq(said.filter(func(t: String) -> bool: return t == "No effect!").size(), 2, str(said))


func test_a_potion_turned_on_an_enemy_is_refused_and_kept() -> void:
	# The design gives potions no enemy-side rule (only heal spells and revival
	# items have one), so the item is refused rather than spent on nothing.
	var battle: Node = _boot(["restless_dead"])
	var dead: Node = battle.get_enemies()[0]
	_pin_hp(dead, 5000, 4000)
	var held: int = _count("potion")
	assert_gt(held, 0, "precondition: a new game carries potions")
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return

	_submit(battle, {"type": "item", "item": _item("potion"), "target": 0, "target_enemy": true})

	assert_eq(dead.current_hp, 4000, "the Undead is untouched")
	assert_has(said, "No effect!", "and the player is told: %s" % str(said))
	assert_eq(_count("potion"), held, "the potion is kept")
