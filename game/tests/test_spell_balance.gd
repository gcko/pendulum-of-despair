extends GutTest
## Balance invariants for game/data/spells/ (89 spells, 5 traditions).
##
## Every assertion here maps to a rule written in docs/story/magic.md:
##   § Spell Balance Guidelines  — tier MP band, tier spell power band
##   § Balance Rules             — healing discount, AoE MP multiplier,
##                                 status hit rate, buff/debuff duration
##   § Tier 4 AoE Exemption      — ultimates keep the full power band
##   § Derived Rules             — severe status band, named same-tier AoE pairs,
##                                 revival pricing, substitute costs,
##                                 enemy-only spells, null durations (including
##                                 status durations owned by § Status Effect
##                                 Reference), cross-training penalty
##
## If a spell value changes and a test here fails, either the value is wrong
## or the rule in magic.md is wrong. Fix one of them — do not weaken the test.

const TRADITIONS: Array[String] = ["ley_line", "spirit", "forgewright", "streetwise", "void"]
const EXPECTED_SPELL_COUNT: int = 89

## Tier -> [min, max] MP, per § Spell Balance Guidelines.
const MP_BAND: Dictionary = {1: [3, 8], 2: [12, 20], 3: [25, 45], 4: [50, 99]}

## Tier -> [min, max] single-target spell power, per § Spell Balance Guidelines.
const POWER_BAND: Dictionary = {1: [12, 20], 2: [28, 40], 3: [50, 70], 4: [85, 120]}

## Tier -> [min, max] AoE spell power (60-70% of the single-target band, rounded
## outward). Tier 4 is absent on purpose — see § Tier 4 AoE Exemption.
const AOE_POWER_BAND: Dictionary = {1: [7, 14], 2: [16, 28], 3: [30, 49]}

## Tier -> [min, max] turns for a turn-counted buff/debuff, per § Balance Rules.
## Tier 3 is absent: those last until end of battle and encode duration as null.
const DURATION_BAND: Dictionary = {1: [4, 6], 2: [4, 8]}

## Status id -> canonical turn count from magic.md § Status Effect Reference.
## 0 marks an open-ended status (until cured, until damaged, or measured in real
## time), which no spell may restate as a turn count. Per § Derived Rules a
## status spell either declares `duration: null` — the duration belongs to the
## status, not the spell — or restates this number exactly.
const STATUS_CANONICAL_TURNS: Dictionary = {
	"blind": 4,
	"confusion": 3,
	"despair": 4,
	"petrify": 0,
	"poison": 0,
	"silence": 4,
	"sleep": 0,
	"slow": 5,
	"stop": 0,
}

## [single_target_id, aoe_id] — the only same-tier pairs the 1.5-2x AoE MP rule
## binds on. Cross-tier escalations (Murk Veil -> Flashblind, Kindle Breath ->
## Rekindling, Dispersion -> Mass Dispersion, ...) are deliberately absent: per
## § Derived Rules they are new spells at a new tier, priced inside their own
## plain tier MP band rather than off a counterpart.
const AOE_PAIRS: Array = [
	["kindlepyre", "scorch_sweep"],
	["hoarfall", "whiteout"],
	["galeforce", "squall_line"],
	["ley_cascade", "ley_storm"],
	["rootgrip", "quake_stride"],
	["spiritfang", "wilds_chorus"],
	["mend", "breath_of_the_wilds"],
	["deepmend", "sanctuary"],
	["resurgence", "lifetide"],
]

## Statuses in the severe 45-59% band rather than the standard 60-80% band.
const SEVERE_STATUS: Array[String] = [
	"grey_gaze",
	"stillwatch",
	"eventide",
	"silence_of_ages",
	"grey_horizon",
]

## Revival spells: priced at the top of the full tier band, no healing discount.
const REVIVAL_SPELLS: Array[String] = ["spirit_recall", "second_dawn"]

## Spells that pay in a resource other than MP and are outside the MP band.
const SUBSTITUTE_COST_SPELLS: Array[String] = ["leydraught"]

var _spells: Array[Dictionary] = []


func before_each() -> void:
	DataManager.clear_cache()
	_spells = _load_all_spells()


func after_each() -> void:
	DataManager.clear_cache()
	_spells = []


# ── helpers ─────────────────────────────────────────────────────────────


func _load_all_spells() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for tradition: String in TRADITIONS:
		var loaded: Array = DataManager.load_spells(tradition)
		if loaded.is_empty():
			fail_test("No spells loaded for tradition '%s'" % tradition)
			continue
		for entry: Variant in loaded:
			out.append(entry as Dictionary)
	return out


## Return the spell with this id. Fails the test (rather than returning {})
## when the spell is missing, so a renamed id cannot silently skip a check.
func _find_spell(spell_id: String) -> Dictionary:
	for spell: Dictionary in _spells:
		if String(spell.get("id", "")) == spell_id:
			return spell
	fail_test("Spell '%s' not found in game/data/spells/" % spell_id)
	return {}


func _paired_aoe_ids() -> Array[String]:
	var ids: Array[String] = []
	for pair: Array in AOE_PAIRS:
		ids.append(String(pair[1]))
	return ids


func _is_aoe(spell: Dictionary) -> bool:
	var target: String = String(spell.get("target", ""))
	return target == "all_enemies" or target == "all_allies"


func _label(spell: Dictionary) -> String:
	return (
		"%s (T%d %s %s)"
		% [
			String(spell.get("id", "?")),
			int(spell.get("tier", 0)),
			String(spell.get("category", "?")),
			String(spell.get("target", "?")),
		]
	)


# ── loading ─────────────────────────────────────────────────────────────


func test_all_traditions_load_expected_spell_count() -> void:
	assert_eq(
		_spells.size(),
		EXPECTED_SPELL_COUNT,
		"magic.md documents %d spells; update both if a spell is added" % EXPECTED_SPELL_COUNT,
	)


func test_every_spell_has_a_known_tier() -> void:
	assert_false(_spells.is_empty(), "spell list must not be empty")
	for spell: Dictionary in _spells:
		var tier: int = int(spell.get("tier", 0))
		assert_true(MP_BAND.has(tier), "%s has tier outside 1-4" % _label(spell))


# ── MP cost ─────────────────────────────────────────────────────────────


func test_mp_cost_within_tier_band() -> void:
	var paired: Array[String] = _paired_aoe_ids()
	var checked: int = 0
	for spell: Dictionary in _spells:
		var spell_id: String = String(spell.get("id", ""))
		if spell.get("mp_cost") == null:
			continue  # enemy-only, covered by its own test
		if SUBSTITUTE_COST_SPELLS.has(spell_id):
			continue  # pays in HP, outside the MP band by rule
		if paired.has(spell_id):
			# Priced off its same-tier counterpart via the 1.5-2x rule, which
			# deliberately overshoots the plain tier band and the healing band
			# (Ley Storm 25, Sanctuary 18, Lifetide 42) — see § Derived Rules
			# "AoE MP pricing". Covered by the ratio test instead.
			continue
		var tier: int = int(spell.get("tier", 0))
		var band: Array = MP_BAND[tier]
		var low: int = int(band[0])
		var high: int = int(band[1])
		var is_heal: bool = String(spell.get("category", "")) == "healing"
		if is_heal and not REVIVAL_SPELLS.has(spell_id):
			low = int(ceil(float(low) * 0.8))
			high = int(floor(float(high) * 0.8))
		var mp: int = int(spell.get("mp_cost"))
		assert_between(
			mp, low, high, "%s costs %d MP, band is %d-%d" % [_label(spell), mp, low, high]
		)
		checked += 1
	assert_gt(checked, 0, "no spells were checked against the MP band")


func test_null_mp_cost_only_on_enemy_only_void_spells() -> void:
	var found: int = 0
	for spell: Dictionary in _spells:
		if spell.get("mp_cost") != null:
			continue
		found += 1
		assert_eq(
			String(spell.get("tradition", "")),
			"void",
			"%s has no MP cost but is not a Void (enemy-only) spell" % _label(spell),
		)
	assert_gt(found, 0, "expected at least one enemy-only spell with a null mp_cost")


func test_revival_spells_sit_inside_the_full_tier_band() -> void:
	assert_false(REVIVAL_SPELLS.is_empty(), "revival spell list must not be empty")
	for spell_id: String in REVIVAL_SPELLS:
		var spell: Dictionary = _find_spell(spell_id)
		if spell.is_empty():
			continue
		var band: Array = MP_BAND[int(spell.get("tier", 0))]
		var mp: int = int(spell.get("mp_cost"))
		# Full band, not the 80% healing band: restoring a fainted ally restores
		# their whole remaining action economy.
		assert_between(mp, int(band[0]), int(band[1]), "%s costs %d MP" % [spell_id, mp])
		assert_gt(
			mp,
			int(floor(float(int(band[1])) * 0.8)),
			"%s must be priced above the 80%% healing band" % spell_id,
		)


func test_substitute_cost_spells_declare_zero_mp() -> void:
	assert_false(SUBSTITUTE_COST_SPELLS.is_empty(), "substitute-cost list must not be empty")
	for spell_id: String in SUBSTITUTE_COST_SPELLS:
		var spell: Dictionary = _find_spell(spell_id)
		if spell.is_empty():
			continue
		assert_eq(
			int(spell.get("mp_cost", -1)), 0, "%s pays in HP, so mp_cost must be 0" % spell_id
		)


# ── AoE MP multiplier ───────────────────────────────────────────────────


func test_paired_aoe_spells_cost_1_5x_to_2x_their_single_target_version() -> void:
	assert_false(AOE_PAIRS.is_empty(), "AoE pair list must not be empty")
	for pair: Array in AOE_PAIRS:
		var single: Dictionary = _find_spell(String(pair[0]))
		var aoe: Dictionary = _find_spell(String(pair[1]))
		if single.is_empty() or aoe.is_empty():
			continue
		assert_eq(
			int(single.get("tier", -1)),
			int(aoe.get("tier", -2)),
			"%s and %s must share a tier" % [pair[0], pair[1]],
		)
		var single_mp: float = float(int(single.get("mp_cost", 0)))
		assert_gt(single_mp, 0.0, "%s must have a positive MP cost" % pair[0])
		var ratio: float = float(int(aoe.get("mp_cost", 0))) / single_mp
		assert_between(
			ratio,
			1.5,
			2.0,
			"%s costs %.2fx %s (rule: 1.5-2x)" % [pair[1], ratio, pair[0]],
		)


# ── spell power ─────────────────────────────────────────────────────────


func test_spell_power_within_tier_band() -> void:
	var checked: int = 0
	for spell: Dictionary in _spells:
		if spell.get("power") == null:
			continue
		var tier: int = int(spell.get("tier", 0))
		var band: Array = POWER_BAND[tier]
		# Tier 4 ultimates keep the full band even when AoE — see magic.md
		# § Tier 4 AoE Exemption.
		if tier != 4 and _is_aoe(spell):
			band = AOE_POWER_BAND[tier]
		var power: int = int(spell.get("power"))
		assert_between(
			power,
			int(band[0]),
			int(band[1]),
			"%s has power %d, band is %d-%d" % [_label(spell), power, int(band[0]), int(band[1])],
		)
		checked += 1
	assert_gt(checked, 0, "no spells were checked against the power band")


func test_tier4_aoe_power_still_reaches_the_damage_cap() -> void:
	# magic.md § Tier 4 AoE Exemption derives the exemption from this chain:
	# (332 MAG x power / 4 - 80 MDEF) x 1.5 element x 1.3 Resonance >= 14999.
	# If the strongest ultimate drops below power 94 the documented "perfect
	# setup" moment in combat-formulas.md becomes unreachable.
	var strongest: int = 0
	for spell: Dictionary in _spells:
		if int(spell.get("tier", 0)) != 4 or spell.get("power") == null:
			continue
		strongest = maxi(strongest, int(spell.get("power")))
	assert_gt(strongest, 0, "expected at least one Tier 4 spell with a power value")
	var chain: float = (332.0 * float(strongest) / 4.0 - 80.0) * 1.5 * 1.3
	assert_gte(
		chain,
		14999.0,
		"strongest Tier 4 power %d yields %.0f, below the 14999 cap" % [strongest, chain],
	)


# ── status hit rate ─────────────────────────────────────────────────────


func test_status_spells_use_the_standard_or_severe_hit_rate_band() -> void:
	var standard: int = 0
	var severe: int = 0
	for spell: Dictionary in _spells:
		if String(spell.get("category", "")) != "status":
			continue
		var spell_id: String = String(spell.get("id", ""))
		assert_ne(spell.get("hit_rate"), null, "%s must declare a hit_rate" % spell_id)
		if spell.get("hit_rate") == null:
			continue
		var rate: int = int(spell.get("hit_rate"))
		if SEVERE_STATUS.has(spell_id):
			assert_between(rate, 45, 59, "%s is severe, band is 45-59" % _label(spell))
			severe += 1
		else:
			assert_between(rate, 60, 80, "%s is standard, band is 60-80" % _label(spell))
			standard += 1
	assert_gt(standard, 0, "no standard-band status spells were checked")
	assert_gt(severe, 0, "no severe-band status spells were checked")


func test_stat_penalty_debuffs_use_the_standard_hit_rate_band() -> void:
	var checked: int = 0
	for spell: Dictionary in _spells:
		if String(spell.get("category", "")) != "debuff":
			continue
		if spell.get("hit_rate") == null:
			continue  # dispel-type debuff, always lands
		var rate: int = int(spell.get("hit_rate"))
		assert_between(rate, 60, 80, "%s is a stat-penalty debuff, band is 60-80" % _label(spell))
		checked += 1
	assert_gt(checked, 0, "no stat-penalty debuffs were checked")


func test_only_status_and_debuff_spells_declare_a_hit_rate() -> void:
	assert_false(_spells.is_empty(), "spell list must not be empty")
	for spell: Dictionary in _spells:
		var category: String = String(spell.get("category", ""))
		if category == "status" or category == "debuff":
			continue
		assert_eq(spell.get("hit_rate"), null, "%s should not roll to hit" % _label(spell))


# ── buff / debuff duration ──────────────────────────────────────────────


func test_turn_counted_buff_durations_match_their_tier() -> void:
	var checked: int = 0
	for spell: Dictionary in _spells:
		var category: String = String(spell.get("category", ""))
		if category != "buff" and category != "debuff":
			continue
		var tier: int = int(spell.get("tier", 0))
		if not DURATION_BAND.has(tier):
			continue
		if spell.get("duration") == null:
			continue  # instantaneous or charge-limited, per § Derived Rules
		var band: Array = DURATION_BAND[tier]
		var turns: int = int(spell.get("duration"))
		assert_between(
			turns,
			int(band[0]),
			int(band[1]),
			"%s lasts %d turns, band is %d-%d" % [_label(spell), turns, int(band[0]), int(band[1])],
		)
		checked += 1
	assert_gt(checked, 0, "no turn-counted buffs or debuffs were checked")


func test_status_spell_durations_come_from_the_status_effect_reference() -> void:
	var checked: int = 0
	var restated: int = 0
	for spell: Dictionary in _spells:
		if String(spell.get("category", "")) != "status":
			continue
		var status: String = String(spell.get("status", ""))
		assert_true(
			STATUS_CANONICAL_TURNS.has(status),
			(
				"%s inflicts '%s', which has no row in magic.md § Status Effect Reference"
				% [_label(spell), status]
			),
		)
		if not STATUS_CANONICAL_TURNS.has(status):
			continue
		checked += 1
		if spell.get("duration") == null:
			continue  # duration owned by the status, per § Derived Rules
		var canonical: int = int(STATUS_CANONICAL_TURNS[status])
		assert_gt(
			canonical,
			0,
			(
				"%s declares a turn count, but '%s' is open-ended in § Status Effect Reference"
				% [_label(spell), status]
			),
		)
		assert_eq(
			int(spell.get("duration")),
			canonical,
			(
				"%s declares %d turns; § Status Effect Reference gives '%s' as %d"
				% [_label(spell), int(spell.get("duration")), status, canonical]
			),
		)
		restated += 1
	assert_gt(checked, 0, "no status spells were checked")
	assert_gt(restated, 0, "expected at least one status spell to restate its status duration")


func test_tier1_buffs_and_debuffs_are_all_turn_counted() -> void:
	var checked: int = 0
	for spell: Dictionary in _spells:
		var category: String = String(spell.get("category", ""))
		if category != "buff" and category != "debuff":
			continue
		if int(spell.get("tier", 0)) != 1:
			continue
		assert_ne(spell.get("duration"), null, "%s must declare a turn count" % _label(spell))
		checked += 1
	assert_gt(checked, 0, "no Tier 1 buffs or debuffs were checked")


func test_tier3_buffs_and_debuffs_last_until_end_of_battle() -> void:
	var checked: int = 0
	for spell: Dictionary in _spells:
		var category: String = String(spell.get("category", ""))
		if category != "buff" and category != "debuff":
			continue
		if int(spell.get("tier", 0)) != 3:
			continue
		assert_eq(
			spell.get("duration"),
			null,
			"%s is Tier 3, so it lasts until end of battle (null)" % _label(spell),
		)
		checked += 1
	assert_gt(checked, 0, "no Tier 3 buffs or debuffs were checked")


# ── cross-training ──────────────────────────────────────────────────────


func test_cross_trained_learners_pay_a_50_percent_mp_penalty() -> void:
	var checked: int = 0
	for spell: Dictionary in _spells:
		for entry: Variant in spell.get("learned_by", []):
			var learner: Dictionary = entry as Dictionary
			var penalty: Variant = learner.get("mp_penalty")
			if not bool(learner.get("cross_trained", false)):
				assert_eq(
					penalty,
					null,
					(
						"%s / %s is not cross-trained but declares an mp_penalty"
						% [_label(spell), String(learner.get("character", "?"))]
					),
				)
				continue
			assert_eq(
				float(penalty if penalty != null else 0.0),
				1.5,
				(
					"%s / %s must carry mp_penalty 1.5 (+50%% MP)"
					% [_label(spell), String(learner.get("character", "?"))]
				),
			)
			checked += 1
	assert_gt(checked, 0, "no cross-trained learners were checked")
