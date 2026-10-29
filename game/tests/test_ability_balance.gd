extends GutTest
## Cost invariants for game/data/abilities/ (6 character files, 44 entries).
##
## What abilities *deal* is asserted next door in test_ability_magnitudes.gd;
## this file is only what they *cost*. The two were one 415-line file until the
## magnitude assertions were written: keeping them together would have carried it
## past the 600-line ceiling (technical-architecture.md 1.2a), so the split was
## made before that happened rather than after.
##
## combos.json (12 entries) is priced per character: `mp_costs` is what the engine
## reads, and both it and the free-text `cost` ("Edren: 7 MP, Cael: 7 MP") are
## checked against the Combo List's "Total MP" column (abilities.md § 2 Combo
## Abilities), where each split must also add up to its total.
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


# ── combo MP split (abilities.md § 2 Combo Abilities) ───────────────────


## The Combo List rows, keyed by combo name: the two characters in the order the
## doc names them, the stated total and the two shares of "14 MP (7/7)".
func _combo_doc_rows() -> Dictionary:
	var repo_root: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var doc: String = FileAccess.get_file_as_string(repo_root + "/docs/story/abilities.md")
	var mp_re: RegEx = RegEx.new()
	mp_re.compile("^(\\d+) MP \\((\\d+)/(\\d+)\\)$")
	var rows: Dictionary = {}
	var in_list: bool = false
	for line: String in doc.split("\n"):
		if line.begins_with("###"):
			in_list = line == "### Combo List"
			continue
		if not in_list or not line.begins_with("| ") or "**" not in line:
			continue
		var cells: PackedStringArray = line.split("|")
		var m: RegExMatch = mp_re.search(cells[4].strip_edges())
		if m == null:
			fail_test("Combo List row has an unreadable Total MP: %s" % cells[4])
			continue
		var pair: PackedStringArray = cells[3].strip_edges().to_lower().split(" + ")
		rows[cells[2].strip_edges().trim_prefix("**").trim_suffix("**")] = {
			"characters": [pair[0], pair[1]],
			"total": int(m.get_string(1)),
			"shares": [int(m.get_string(2)), int(m.get_string(3))],
		}
	return rows


func test_every_combo_mp_split_matches_the_combo_list() -> void:
	var rows: Dictionary = _combo_doc_rows()
	var combos: Array = DataManager.load_combos()
	assert_eq(rows.size(), 12, "abilities.md lists 12 combos")
	assert_eq(combos.size(), rows.size(), "combos.json has one entry per Combo List row")
	for raw: Variant in combos:
		var combo: Dictionary = raw as Dictionary
		var combo_name: String = String(combo.get("name", "?"))
		if not rows.has(combo_name):
			fail_test("%s is not in the Combo List" % combo_name)
			continue
		var row: Dictionary = rows[combo_name]
		var shares: Array = row["shares"]
		assert_eq(shares[0] + shares[1], row["total"], "%s: the doc's split adds up" % combo_name)
		assert_eq(
			combo.get("characters", []), row["characters"], "%s: same two characters" % combo_name
		)
		var mp_costs: Dictionary = combo.get("mp_costs", {})
		assert_eq(mp_costs.size(), 2, "%s: one MP share per character" % combo_name)
		for i: int in range(2):
			var cid: String = row["characters"][i]
			assert_eq(
				int(mp_costs.get(cid, -1)),
				shares[i],
				"%s: %s pays the doc's share" % [combo_name, cid]
			)


func test_every_combo_cost_string_matches_its_mp_costs() -> void:
	var share_re: RegEx = RegEx.new()
	assert_eq(share_re.compile("(\\w+): (\\d+) MP"), OK, "share regex must compile")
	var checked: int = 0
	for raw: Variant in DataManager.load_combos():
		var combo: Dictionary = raw as Dictionary
		var cost_text: String = String(combo.get("cost", ""))
		var stated: Dictionary = {}
		for m: RegExMatch in share_re.search_all(cost_text):
			stated[m.get_string(1).to_lower()] = int(m.get_string(2))
		var mp_costs: Dictionary = {}
		var raw_costs: Dictionary = combo.get("mp_costs", {})
		for cid: String in raw_costs:
			mp_costs[cid] = int(raw_costs[cid])
		assert_eq(
			stated,
			mp_costs,
			"%s: cost '%s' disagrees with mp_costs" % [combo.get("id", "?"), cost_text]
		)
		checked += 1
	assert_gt(checked, 0, "no combo cost strings were checked")
