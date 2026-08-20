extends GutTest
## Damage magnitudes for game/data/abilities/ — every derived `power`,
## `ability_mult`, component and combo scaling stat in
## docs/story/abilities.md § Damage Magnitudes (numeric balance pass).
##
## Split from test_ability_balance.gd, which keeps the cost invariants, when the
## two together crossed the 600-line ceiling (technical-architecture.md 1.2a).
## The loader below is duplicated from that file on purpose: a shared base class
## would couple two suites that fail for unrelated reasons.

const CHARACTER_FILES: Array[String] = [
	"cael",
	"edren",
	"lira",
	"maren",
	"sable",
	"torren",
]

var _abilities: Array[Dictionary] = []


func before_each() -> void:
	DataManager.clear_cache()
	_abilities = _load_character_abilities()


func after_each() -> void:
	DataManager.clear_cache()
	_abilities = []


# ── helpers ─────────────────────────────────────────────────────────────


func _load_character_abilities() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for character_id: String in CHARACTER_FILES:
		var loaded: Array = DataManager.load_abilities(character_id)
		if loaded.is_empty():
			fail_test("No abilities loaded for character '%s'" % character_id)
			continue
		for entry: Variant in loaded:
			out.append(entry as Dictionary)
	return out


## Return the ability with this id. Fails the test (rather than returning {})
## when it is missing, so a renamed id cannot silently skip a check.
func _find_ability(ability_id: String) -> Dictionary:
	for ability: Dictionary in _abilities:
		if String(ability.get("id", "")) == ability_id:
			return ability
	fail_test("Ability '%s' not found in game/data/abilities/" % ability_id)
	return {}


# ── damage magnitudes ───────────────────────────────────────────────────
#
# Every value below is derived in abilities.md § Damage Magnitudes. The tests
# pin both the value and the rule that produced it, so a future edit that moves
# a number without moving its derivation fails here.


## Load combos.json directly — DataManager.load_abilities() only reads the
## "abilities" key, and this file stores its entries under "combos".
func _load_combos() -> Array:
	var data: Variant = DataManager.load_json("res://data/abilities/combos.json")
	if data is Dictionary and (data as Dictionary).has("combos"):
		return (data as Dictionary)["combos"]
	fail_test("combos.json did not load")
	return []


func _find_combo(combo_id: String) -> Dictionary:
	for combo: Variant in _load_combos():
		var entry: Dictionary = combo as Dictionary
		if String(entry.get("id", "")) == combo_id:
			return entry
	fail_test("Combo '%s' not found in combos.json" % combo_id)
	return {}


## Read an integer field that a derivation depends on. Fails (rather than
## defaulting) when it is missing, so deleting the field cannot quietly turn an
## assertion into 0 == 0.
func _int_field(ability_id: String, key: String) -> int:
	var ability: Dictionary = _find_ability(ability_id)
	if ability.is_empty():
		return -1
	if not ability.has(key):
		fail_test("%s must carry '%s' — abilities.md derives a value from it" % [ability_id, key])
		return -1
	return int(ability.get(key, -1))


func _power_of(ability_id: String) -> int:
	var ability: Dictionary = _find_ability(ability_id)
	if ability.is_empty():
		return -1
	assert_true(ability.has("power"), "%s must carry a derived power" % ability_id)
	return int(ability.get("power", -1))


func test_derived_ability_powers_match_the_documented_values() -> void:
	## abilities.md § Damage Magnitudes > Resolved values.
	var expected: Dictionary = {
		"shock_coil": 10,
		"arc_trap": 30,
		"ember_wing": 10,
		"greyveil": 28,
		"dewfall": 12,
		"rootsong": 12,
	}
	for ability_id: String in expected:
		assert_eq(
			_power_of(ability_id),
			int(expected[ability_id]),
			"%s power disagrees with abilities.md § Damage Magnitudes" % ability_id,
		)


func test_spiritcall_powers_sit_in_their_derived_tier_band() -> void:
	## Rule 1: MP-costed Spiritcalls are priced on magic.md's tier ladder.
	## Ember Wing is a Tier 1 AoE (10 MP = 2x a 5 MP Tier 1 single target), so it
	## takes the reduced AoE band; Greyveil is Tier 2 and Dewfall Tier 1, both
	## single target. Rootsong and Convergence Chorus are excluded on purpose:
	## their MP buys the Favor boost and the four-effect composite, and their
	## potency is fixed by the 50%/equality rules instead of by the band.
	var bands: Dictionary = {
		"ember_wing": [7, 14],
		"greyveil": [28, 40],
		"dewfall": [12, 20],
	}
	for ability_id: String in bands:
		var band: Array = bands[ability_id]
		assert_between(
			_power_of(ability_id),
			int(band[0]),
			int(band[1]),
			"%s falls outside the tier band its MP cost buys" % ability_id,
		)


func test_favor3_upgrade_never_reduces_the_per_target_magnitude() -> void:
	## Rule 2, checked across every Spiritcall that declares an upgrade.
	var checked: int = 0
	for ability: Dictionary in _abilities:
		if not ability.has("power_favor3"):
			continue
		var ability_id: String = String(ability.get("id", "?"))
		assert_gte(
			int(ability.get("power_favor3", -1)),
			int(ability.get("power", 0)),
			"%s: a Favor 3 upgrade must never weaken the ability" % ability_id,
		)
		checked += 1
	assert_eq(checked, 3, "Dewfall, Ember Wing and Greyveil declare Favor 3 magnitudes")


func test_favor3_doubles_only_when_the_target_set_is_unchanged() -> void:
	## Rule 2 again, in its sharp form. Ember Wing (AoE -> AoE) and Greyveil
	## (single -> single) keep their target set, so they double. Dewfall widens
	## from one ally to the party, so it holds its per-target power instead.
	for ability_id: String in ["ember_wing", "greyveil"]:
		var ability: Dictionary = _find_ability(ability_id)
		if ability.is_empty():
			continue
		assert_eq(
			int(ability.get("power_favor3", -1)),
			2 * int(ability.get("power", 0)),
			"%s keeps its target set, so Favor 3 must double it" % ability_id,
		)
	var dewfall: Dictionary = _find_ability("dewfall")
	if dewfall.is_empty():
		return
	assert_eq(
		int(dewfall.get("power_favor3", -1)),
		int(dewfall.get("power", 0)),
		"Torrent's Grace broadens Dewfall rather than doubling it",
	)


func test_convergence_chorus_components_are_half_their_spiritcall() -> void:
	## The ability states the rule ("50% normal potency") rather than the
	## numbers; these are the numbers that rule produces.
	var chorus: Dictionary = _find_ability("convergence_chorus")
	if chorus.is_empty():
		return
	var components: Dictionary = chorus.get("component_powers", {}) as Dictionary
	assert_eq(
		int(components.get("damage", -1)),
		_power_of("ember_wing") / 2,
		"Chorus damage is Ember Wing at 50% potency",
	)
	assert_eq(
		int(components.get("heal", -1)),
		_power_of("dewfall") / 2,
		"Chorus heal is Dewfall at 50% potency",
	)
	assert_eq(
		int(components.get("barrier_pct", -1)),
		_int_field("thornveil", "counter_pct") / 2,
		"Chorus barrier counters for half of Thornveil's share of DEF",
	)
	assert_eq(
		int(components.get("immunity_turns", -1)),
		_int_field("stoneheart", "immunity_turns") / 2,
		"Chorus immunity lasts half of Stoneheart's, because a duration is all it has",
	)


func test_lira_devices_share_an_equal_arcanite_budget() -> void:
	## Shock Coil and Arc Trap both cost 2 AC from the same 12 AC pool, so they
	## are budgeted the same total output: three ticks of 10 against one burst.
	## The quantity compared here is Shock Coil's whole-life total (3 x power),
	## which is NOT the per-tick quantity rule 4 doubles into Thornfire.
	var coil: Dictionary = _find_ability("shock_coil")
	var trap: Dictionary = _find_ability("arc_trap")
	if coil.is_empty() or trap.is_empty():
		return
	assert_eq(
		int(coil.get("cost_value", -1)),
		int(trap.get("cost_value", -2)),
		"the equal-budget derivation only holds while both devices cost the same AC",
	)
	assert_eq(
		int(trap.get("power", -1)),
		_int_field("shock_coil", "ticks") * int(coil.get("power", 0)),
		"Arc Trap's single burst equals Shock Coil's whole life of ticks",
	)
	assert_eq(
		_int_field("shock_coil", "ticks"),
		3,
		"the device lives 3 turns and fires once a turn, so 3 ticks",
	)


func test_combos_double_the_ability_they_fire() -> void:
	## Rule 4 doubles a constituent's *per-application* magnitude, and the two
	## constituents apply differently. Arc Trap is single-shot, so `power` 30 is
	## one application and Ambush Protocol is 2 x 30. Shock Coil is a 3-turn
	## device, so `power` 10 is one tick and Thornfire doubles the tick, not the
	## 30 it delivers over its life. That 30 is a separate quantity, used only by
	## the equal-AC budget check in the test above.
	## Ambush Protocol states the doubling outright; Thornfire states its
	## total instead, and the total is what checks the two constituent values.
	var ambush: Dictionary = _find_combo("ambush_protocol")
	if not ambush.is_empty():
		assert_eq(
			int(ambush.get("power", -1)),
			2 * _power_of("arc_trap"),
			"Ambush Protocol is 2x Arc Trap",
		)
	var thornfire: Dictionary = _find_combo("thornfire")
	if thornfire.is_empty():
		return
	assert_eq(
		int(thornfire.get("power", -1)),
		2 * (_power_of("ember_wing") + _power_of("shock_coil")),
		"Thornfire's stated total is double Ember Wing plus double Shock Coil",
	)


func test_physical_multipliers_stay_on_the_documented_ladder() -> void:
	## combat-formulas.md § Physical Ability Multiplier Tiers defines the ladder
	## 1.0 / 1.5 / 2.0 / 2.5 / 3.0. Nothing may sit above its maximum.
	var ladder: Array[float] = [1.0, 1.5, 2.0, 2.5, 3.0]
	var checked: int = 0
	for ability: Dictionary in _abilities:
		var ability_id: String = String(ability.get("id", "?"))
		var mult_keys: Array[String] = [
			"ability_mult",
			"ability_mult_max",
			"attack_ability_mult",
			"thrown_item_ability_mult",
			"item_branch_ability_mult",
		]
		for key: String in mult_keys:
			if not ability.has(key):
				continue
			assert_true(
				ladder.has(float(ability.get(key, 0.0))),
				"%s.%s is not a rung on the multiplier ladder" % [ability_id, key],
			)
			checked += 1
	assert_gt(checked, 0, "no physical multipliers were checked")


func test_wild_card_escalates_from_ultimate_to_maximum() -> void:
	var shiv: Dictionary = _find_ability("shiv")
	if not shiv.is_empty():
		assert_eq(
			float(shiv.get("ability_mult", 0.0)),
			1.0,
			"Shiv's damage bonus is the DEF ignore, not a multiplier",
		)
	var wild_card: Dictionary = _find_ability("wild_card")
	if wild_card.is_empty():
		return
	assert_eq(
		float(wild_card.get("ability_mult", 0.0)), 2.0, "Wild Card's base branch is 2x Attack"
	)
	assert_eq(
		float(wild_card.get("ability_mult_max", 0.0)),
		3.0,
		"the three-item branch takes the ladder's Maximum tier",
	)


# ── Oathkeeper: a buff that adds a hit, not a multiplier (#346) ──────────


## The § Physical Damage worked example from combat-formulas.md, variance-free:
## `(ATK^2 * mult) / 6 - DEF`, floored. DEF is subtracted per hit, which is what
## separates "hits twice" from "hits twice as hard".
func _documented_hit(atk: int, mult: float, target_def: int) -> int:
	return int((atk * atk * mult) / 6.0) - target_def


func test_a_turn_of_oathkeeper_deals_exactly_two_basic_attacks() -> void:
	## Oathkeeper makes the *Attack command* hit twice (abilities.md
	## § Edren — Bulwark), so each hit is a plain basic attack. The doc gave it
	## 1.0-doubled, 1.5 and 2.0 in three places (#346); this holds it to the
	## first, in the units a player sees — damage on the board in one turn.
	var oathkeeper: Dictionary = _find_ability("oathkeeper")
	if oathkeeper.is_empty():
		return
	var hits: int = _int_field("oathkeeper", "attack_hits")
	var mult: float = float(oathkeeper.get("attack_ability_mult", 0.0))
	var basic: int = _documented_hit(175, 1.0, 60)
	assert_eq(
		hits * _documented_hit(175, mult, 60),
		2 * basic,
		"an Oathkeeper turn at the documented Lv70 milestone is two basic attacks",
	)
	assert_ne(
		hits * _documented_hit(175, mult, 60),
		_documented_hit(175, 2.0, 60),
		"and is not the 2.0 Ultimate-skill rung, which subtracts DEF once instead of twice",
	)


func test_oathkeeper_takes_no_rung_on_the_physical_multiplier_ladder() -> void:
	## The buff itself deals no damage — it modifies the Attack command. If it
	## ever grows an `ability_mult` of its own, the two documents have drifted
	## apart again.
	var oathkeeper: Dictionary = _find_ability("oathkeeper")
	if oathkeeper.is_empty():
		return
	assert_false(
		oathkeeper.has("ability_mult"),
		"Oathkeeper is a buff; its damage is the Attack command's, not its own",
	)
	assert_eq(
		float(oathkeeper.get("attack_ability_mult", 0.0)),
		1.0,
		"each of the two hits is the Attack command, which is the ladder's 1.0 rung",
	)


# ── Thrown stolen items (#359) ──────────────────────────────────────────


func _items_named(file_name: String) -> Array:
	var data: Variant = DataManager.load_json("res://data/items/%s.json" % file_name)
	if data is Dictionary and (data as Dictionary).has("items"):
		return (data as Dictionary)["items"]
	fail_test("%s.json did not load" % file_name)
	return []


func test_throwing_a_stolen_item_changes_the_element_and_nothing_else() -> void:
	## abilities.md § Damage Magnitudes reads the throw as (a): the same hit,
	## re-elemented. The rejected readings (b) and (c) would show up here as a
	## thrown multiplier that differs from the bare one.
	var shiv: Dictionary = _find_ability("shiv")
	if not shiv.is_empty():
		assert_eq(
			float(shiv.get("thrown_item_ability_mult", -1.0)),
			float(shiv.get("ability_mult", 0.0)),
			"a thrown Shiv hits for the same multiplier as a bare one",
		)
	var wild_card: Dictionary = _find_ability("wild_card")
	if wild_card.is_empty():
		return
	assert_eq(
		float(wild_card.get("item_branch_ability_mult", -1.0)),
		float(wild_card.get("ability_mult", 0.0)),
		"Wild Card's item branches keep the 0-item branch's multiplier",
	)
	assert_eq(
		String(wild_card.get("item_branch_element_field", "")),
		String(shiv.get("thrown_item_element_field", "?")),
		"both abilities read the element from the same item field",
	)


func test_a_thrown_item_confers_only_an_element_a_document_names() -> void:
	## items.md § Thrown-Item Elements: eleven items carry a thrown element and
	## every other item is thrown non-elemental. The absence of the field is the
	## non-elemental case, so this checks both the roster and the values.
	var legal: Array[String] = ["flame", "frost", "storm", "earth", "ley", "spirit", "void"]
	var documented: Array[String] = [
		"emberstone",
		"spirit_essence",
		"spirit_dust",
		"arcanite_shard",
		"arcanite_core",
		"arcanite_ingot",
		"grey_residue",
		"pallor_blade",
		"pallor_sample",
		"pallor_shard",
		"nest_fragment",
	]
	var found: Array[String] = []
	for file_name: String in ["materials", "consumables"]:
		for raw: Variant in _items_named(file_name):
			var item: Dictionary = raw as Dictionary
			if not item.has("throw_element"):
				continue
			var item_id: String = String(item.get("id", "?"))
			found.append(item_id)
			assert_true(
				legal.has(String(item.get("throw_element", ""))),
				"%s throws as '%s', which is not an element" % [item_id, item.get("throw_element")],
			)
			assert_true(
				documented.has(item_id),
				"%s carries a thrown element that items.md does not derive" % item_id,
			)
	found.sort()
	documented.sort()
	assert_eq(found, documented, "every item items.md gives a thrown element must have one")


# ── Combo scaling stats (#360) ──────────────────────────────────────────


func test_every_combo_that_deals_a_power_names_whose_stat_it_reads() -> void:
	## A two-character combo has two stat lines, and a spell power that does not
	## say which one it reads cannot be executed (#360). abilities.md § Damage
	## Magnitudes rule 5: each constituent scales off the character who supplies
	## it, so every declared power carries a caster who is in the combo.
	var checked: int = 0
	for raw: Variant in _load_combos():
		var combo: Dictionary = raw as Dictionary
		if not combo.has("power"):
			continue
		var combo_id: String = String(combo.get("id", "?"))
		var characters: Array = combo.get("characters", []) as Array
		var halves: Array = combo.get("power_split", []) as Array
		var sources: Array = [combo] if halves.is_empty() else halves
		var split_total: int = 0
		for source_raw: Variant in sources:
			var source: Dictionary = source_raw as Dictionary
			var caster: String = String(source.get("caster", ""))
			assert_true(
				characters.has(caster),
				(
					"%s deals power %s but names no caster inside the combo (got '%s')"
					% [combo_id, str(combo.get("power")), caster]
				),
			)
			assert_ne(String(source.get("scaling_stat", "")), "", "%s names no stat" % combo_id)
			split_total += int(source.get("power", 0))
		if not halves.is_empty():
			assert_eq(
				split_total,
				int(combo.get("power", -1)),
				"%s: the halves must add up to the stated total" % combo_id,
			)
		checked += 1
	assert_eq(checked, 2, "Thornfire and Ambush Protocol are the combos carrying a power")


func test_each_thornfire_half_doubles_its_own_casters_ability() -> void:
	## Rule 4 doubles a constituent, rule 5 says whose stat carries it. Thornfire
	## fires one ability from each character, so the two rules meet here: the
	## Flame half is Torren's Ember Wing doubled and the Storm half is Lira's
	## Shock Coil tick doubled.
	var thornfire: Dictionary = _find_combo("thornfire")
	if thornfire.is_empty():
		return
	var expected: Dictionary = {
		"flame": {"caster": "torren", "power": 2 * _power_of("ember_wing")},
		"storm": {"caster": "lira", "power": 2 * _power_of("shock_coil")},
	}
	var seen: Array[String] = []
	for raw: Variant in thornfire.get("power_split", []) as Array:
		var half: Dictionary = raw as Dictionary
		var element: String = String(half.get("element", "?"))
		assert_true(expected.has(element), "Thornfire has no %s half in abilities.md" % element)
		if not expected.has(element):
			continue
		seen.append(element)
		var want: Dictionary = expected[element]
		assert_eq(
			int(half.get("power", -1)),
			int(want["power"]),
			"Thornfire's %s half is double the ability that supplies it" % element,
		)
		assert_eq(
			String(half.get("caster", "")),
			String(want["caster"]),
			"Thornfire's %s half scales off the character whose ability it is" % element,
		)
	seen.sort()
	assert_eq(seen, ["flame", "storm"] as Array[String], "Thornfire splits Flame and Storm")
