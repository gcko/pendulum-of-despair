extends GutTest
## Tests for ModifierAggregator — enemy type-trait combat multipliers (GAP-008).
## Every expected value traces to docs/story/bestiary/README.md.

const Agg := preload("res://scripts/combat/modifier_aggregator.gd")

# --- Type-element bonuses (README §Enemy Type Rules) ---


func test_undead_takes_spirit_element_1_5x() -> void:
	# README:67 — Undead: Spirit element deals 1.5x.
	assert_almost_eq(Agg.type_element_multiplier("undead", "spirit"), 1.5, 0.001)


func test_spirit_takes_ley_element_1_5x() -> void:
	# README:83 — Spirit: Ley element deals 1.5x.
	assert_almost_eq(Agg.type_element_multiplier("spirit", "ley"), 1.5, 0.001)


func test_construct_takes_storm_element_1_25x() -> void:
	# README:75 — Construct: Storm deals 1.25x.
	assert_almost_eq(Agg.type_element_multiplier("construct", "storm"), 1.25, 0.001)


func test_pallor_takes_spirit_element_1_25x() -> void:
	# README:100 — Pallor: Spirit element deals 1.25x.
	assert_almost_eq(Agg.type_element_multiplier("pallor", "spirit"), 1.25, 0.001)


func test_unmatched_type_element_is_neutral() -> void:
	assert_almost_eq(Agg.type_element_multiplier("beast", "fire"), 1.0, 0.001)
	assert_almost_eq(Agg.type_element_multiplier("undead", "fire"), 1.0, 0.001)


func test_empty_element_is_neutral() -> void:
	# A non-elemental basic attack carries no element -> no type bonus.
	assert_almost_eq(Agg.type_element_multiplier("undead", ""), 1.0, 0.001)


# --- Spirit physical pre-DEF reduction (README:80) ---


func test_spirit_physical_pre_def_half() -> void:
	# README:80 — Spirit: physical damage reduced 50%, applied BEFORE DEF.
	assert_almost_eq(Agg.physical_pre_def_mult("spirit"), 0.5, 0.001)


func test_non_spirit_physical_pre_def_neutral() -> void:
	assert_almost_eq(Agg.physical_pre_def_mult("undead"), 1.0, 0.001)
	assert_almost_eq(Agg.physical_pre_def_mult("beast"), 1.0, 0.001)


# --- Undead heal->damage flag (README:63) ---


func test_undead_is_damaged_by_healing() -> void:
	assert_true(Agg.is_damaged_by_healing("undead"))


func test_non_undead_not_damaged_by_healing() -> void:
	assert_false(Agg.is_damaged_by_healing("beast"))
	assert_false(Agg.is_damaged_by_healing("spirit"))
