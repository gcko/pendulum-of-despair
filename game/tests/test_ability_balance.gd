extends GutTest
## Balance invariants for game/data/abilities/ (7 files, 56 entries).
##
## Assertions map to docs/story/abilities.md:
##   § Bulwark / Forgewright / Arcanum resource blocks — AP/AC/WG caps
##   § Balance Targets > Resource Cost Invariants      — no ability may cost
##                                                       more than its cap
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
