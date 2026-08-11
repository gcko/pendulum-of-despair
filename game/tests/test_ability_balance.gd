extends GutTest
## Balance invariants for game/data/abilities/ (6 character files, 44 entries).
##
## combos.json (12 entries) is outside the *cost* assertions: its `cost` is a
## free-text per-character split ("Edren: 7 MP, Cael: 7 MP") with no `cost_value`
## field to check it against. Two combos do carry a derived `power`, and those
## are asserted in the magnitude section below.
##
## Assertions map to docs/story/abilities.md:
##   § Bulwark / Forgewright / Arcanum resource blocks — AP/AC/WG caps
##   § Balance Targets > Resource Cost Invariants      — no ability may cost
##                                                       more than its cap
##   § Damage Magnitudes (numeric balance pass)        — the derived power and
##                                                       ability_mult values
##
## The `cost` string is the human-readable form shown in the ability menu and
## `cost_value` / `cooldown` are what the engine reads. They are authored by
## hand in two places, so they are checked against each other here.

const CHARACTER_FILES: Array[String] = [
	"cael",
	"edren",
	"lira",
	"maren",
	"sable",
	"torren",
]
const EXPECTED_CHARACTER_ABILITIES: int = 44

## Resource -> hard cap, per the "Resource: ..." block in each command section.
const RESOURCE_CAP: Dictionary = {"ap": 10, "ac": 12, "wg": 100}

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


# ── loading ─────────────────────────────────────────────────────────────


func test_all_character_ability_files_load() -> void:
	assert_eq(
		_abilities.size(),
		EXPECTED_CHARACTER_ABILITIES,
		"abilities.md documents %d character abilities" % EXPECTED_CHARACTER_ABILITIES,
	)


# ── resource caps ───────────────────────────────────────────────────────


func test_no_ability_costs_more_than_its_resource_cap() -> void:
	var checked: int = 0
	for ability: Dictionary in _abilities:
		var cost_type: String = String(ability.get("cost_type", ""))
		if not RESOURCE_CAP.has(cost_type):
			continue
		var cap: int = int(RESOURCE_CAP[cost_type])
		var value: int = int(ability.get("cost_value", 0))
		assert_between(
			value,
			0,
			cap,
			(
				"%s costs %d %s but the pool caps at %d — it would be uncastable"
				% [String(ability.get("id", "?")), value, cost_type.to_upper(), cap]
			),
		)
		checked += 1
	assert_gt(checked, 0, "no AP/AC/WG abilities were checked against a cap")


func test_annulment_consumes_exactly_a_full_weave_gauge() -> void:
	var annulment: Dictionary = _find_ability("annulment")
	if annulment.is_empty():
		return
	assert_eq(String(annulment.get("cost_type", "")), "wg", "Annulment is paid in Weave Gauge")
	assert_eq(
		int(annulment.get("cost_value", -1)),
		int(RESOURCE_CAP["wg"]),
		"abilities.md describes Annulment as a full-gauge cost",
	)


func test_mp_abilities_are_never_free_by_accident() -> void:
	# Zero-cost abilities exist on purpose (Siphon, Ironwall, Rampart, Salvage,
	# Filch, Shiv, Purify, Calibrate, Cael's Edge). Anything else costing 0 MP
	# is a typo.
	var intentionally_free: Array[String] = [
		"siphon",
		"ironwall",
		"rampart",
		"salvage",
		"filch",
		"shiv",
		"purify",
		"calibrate",
		"caels_edge",
	]
	var checked: int = 0
	for ability: Dictionary in _abilities:
		var cost_type: String = String(ability.get("cost_type", ""))
		if cost_type != "mp" and cost_type != "mp_cd" and cost_type != "ap" and cost_type != "ac":
			continue
		checked += 1
		if int(ability.get("cost_value", 0)) != 0:
			continue
		assert_true(
			intentionally_free.has(String(ability.get("id", ""))),
			(
				"%s costs nothing — add it to the intentional list or give it a cost"
				% ability.get("id")
			),
		)
	assert_gt(checked, 0, "no resource-costing abilities were checked")


# ── cost string / cost_value parity ─────────────────────────────────────


func test_cost_string_matches_cost_value_and_cooldown() -> void:
	var cost_re: RegEx = RegEx.new()
	assert_eq(cost_re.compile("^(\\d+)\\s*(MP|AP|AC|WG)"), OK, "cost regex must compile")
	var cd_re: RegEx = RegEx.new()
	assert_eq(cd_re.compile("/\\s*(\\d+)\\s*turn"), OK, "cooldown regex must compile")
	var checked: int = 0
	for ability: Dictionary in _abilities:
		var ability_id: String = String(ability.get("id", "?"))
		var cost_type: String = String(ability.get("cost_type", ""))
		var cost_text: String = String(ability.get("cost", ""))
		if cost_type == "none":
			assert_eq(
				int(ability.get("cost_value", -1)), 0, "%s is free, so cost_value is 0" % ability_id
			)
			continue
		var m: RegExMatch = cost_re.search(cost_text)
		assert_ne(m, null, "%s has an unparseable cost string '%s'" % [ability_id, cost_text])
		if m == null:
			continue
		assert_eq(
			int(m.get_string(1)),
			int(ability.get("cost_value", -1)),
			"%s: cost '%s' disagrees with cost_value" % [ability_id, cost_text],
		)
		var unit: String = m.get_string(2).to_lower()
		var expected_type: String = "mp_cd" if cost_type == "mp_cd" else unit
		assert_eq(
			cost_type,
			expected_type,
			"%s: cost '%s' disagrees with cost_type" % [ability_id, cost_text]
		)
		if cost_type == "mp_cd":
			var cd_match: RegExMatch = cd_re.search(cost_text)
			var turns: int = 0 if cd_match == null else int(cd_match.get_string(1))
			var declared: int = (
				0 if ability.get("cooldown") == null else int(ability.get("cooldown"))
			)
			assert_eq(
				turns,
				declared,
				"%s: cooldown in '%s' disagrees with the cooldown field" % [ability_id, cost_text]
			)
		checked += 1
	assert_gt(checked, 0, "no ability cost strings were checked")


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
		3 * int(coil.get("power", 0)),
		"Arc Trap's single burst equals Shock Coil's three ticks",
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
		for key: String in ["ability_mult", "ability_mult_max"]:
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
