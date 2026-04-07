extends GutTest
## Tests for spell resolution, field casting, and PartyState MP/heal integration.

const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.initialize_new_game()


# --- Spell resolution ---


func test_known_spells_cael_level_1() -> void:
	var spells: Array = SpellHelpers.get_known_spells("cael", 1)
	assert_eq(spells.size(), 3, "Cael Lv1 knows exactly 3 spells")
	var names: Array = []
	for s: Dictionary in spells:
		names.append(s.get("name", ""))
	assert_has(names, "Linebolt")
	assert_has(names, "Leybalm")
	assert_has(names, "Ember Lance")


func test_known_spells_edren_level_1() -> void:
	var spells: Array = SpellHelpers.get_known_spells("edren", 1)
	assert_eq(spells.size(), 0, "Edren Lv1 knows 0 spells")


func test_known_spells_edren_level_5() -> void:
	var spells: Array = SpellHelpers.get_known_spells("edren", 5)
	assert_eq(spells.size(), 3, "Edren Lv5 knows 3 spells")
	var names: Array = []
	for s: Dictionary in spells:
		names.append(s.get("name", ""))
	assert_has(names, "Leybalm")
	assert_has(names, "Mend")
	assert_has(names, "Ironhide")


func test_higher_level_spells_excluded() -> void:
	# Cael Lv1 should not include any spell with a learn level > 1.
	var spells: Array = SpellHelpers.get_known_spells("cael", 1)
	for s: Dictionary in spells:
		for entry: Dictionary in s.get("learned_by", []):
			if entry.get("character", "") == "cael":
				assert_lte(
					entry.get("level", 0),
					1,
					(
						"Cael Lv1 should not know spell '%s' (requires Lv%d)"
						% [s.get("name", ""), entry.get("level", 0)]
					)
				)


func test_unknown_character_returns_empty() -> void:
	var spells: Array = SpellHelpers.get_known_spells("nonexistent", 99)
	assert_eq(spells.size(), 0, "Unknown character should have no known spells")


func test_spells_sorted_by_tier_then_cost() -> void:
	# Cael Lv20 has many spells across tiers — verify ascending tier then mp_cost.
	var spells: Array = SpellHelpers.get_known_spells("cael", 20)
	assert_gt(spells.size(), 1, "Cael Lv20 should know more than one spell")
	for i: int in range(spells.size() - 1):
		var a: Dictionary = spells[i]
		var b: Dictionary = spells[i + 1]
		var ta: int = a.get("tier", 0)
		var tb: int = b.get("tier", 0)
		if ta == tb:
			assert_lte(
				a.get("mp_cost", 0),
				b.get("mp_cost", 0),
				(
					"Within same tier, '%s' (mp%d) should come before '%s' (mp%d)"
					% [
						a.get("name", ""),
						a.get("mp_cost", 0),
						b.get("name", ""),
						b.get("mp_cost", 0)
					]
				)
			)
		else:
			assert_lt(
				ta,
				tb,
				(
					"Tier of '%s' (%d) should be <= tier of '%s' (%d)"
					% [a.get("name", ""), ta, b.get("name", ""), tb]
				)
			)


# --- Field cast tests ---


func test_can_field_cast_healing() -> void:
	# Leybalm is category "healing"
	var spell: Dictionary = {"category": "healing"}
	assert_true(SpellHelpers.can_field_cast(spell), "Healing spells should be field-castable")


func test_can_field_cast_offensive_blocked() -> void:
	# Linebolt is category "offensive"
	var spell: Dictionary = {"category": "offensive"}
	assert_false(
		SpellHelpers.can_field_cast(spell), "Offensive spells should not be field-castable"
	)


func test_can_field_cast_buff_blocked() -> void:
	# Buff field-cast deferred until effect application exists
	var spell: Dictionary = {"category": "buff"}
	assert_false(SpellHelpers.can_field_cast(spell), "Buff spells not field-castable yet")


func test_can_field_cast_debuff_blocked() -> void:
	# Sunder is category "debuff"
	var spell: Dictionary = {"category": "debuff"}
	assert_false(SpellHelpers.can_field_cast(spell), "Debuff spells should not be field-castable")


func test_field_heal_amount_formula() -> void:
	# int(20 * 10 * 0.8) = 160
	var spell: Dictionary = {"power": 10}
	var result: int = SpellHelpers.get_field_heal_amount(20, spell)
	assert_eq(result, 160, "Field heal: 20 MAG * 10 power * 0.8 = 160")


func test_field_heal_zero_power() -> void:
	var spell: Dictionary = {"power": 0}
	var result: int = SpellHelpers.get_field_heal_amount(20, spell)
	assert_eq(result, 0, "Spell with 0 power should heal 0")


# --- PartyState integration ---


func test_spend_mp_deducts() -> void:
	var cael: Dictionary = PartyState.get_member("cael")
	var mp_before: int = cael.get("current_mp", 0)
	assert_gt(mp_before, 0, "Cael should have MP after new game init")
	var ok: bool = PartyState.spend_mp("cael", 3)
	assert_true(ok, "spend_mp should succeed when MP is sufficient")
	assert_eq(cael.get("current_mp", 0), mp_before - 3, "MP should be reduced by 3")


func test_spend_mp_insufficient_rejected() -> void:
	var cael: Dictionary = PartyState.get_member("cael")
	var mp_before: int = cael.get("current_mp", 0)
	var large_amount: int = mp_before + 100
	var ok: bool = PartyState.spend_mp("cael", large_amount)
	assert_false(ok, "spend_mp should fail when amount exceeds current MP")
	assert_eq(cael.get("current_mp", 0), mp_before, "MP should be unchanged after failed spend")


func test_spend_mp_zero_rejected() -> void:
	var ok: bool = PartyState.spend_mp("cael", 0)
	assert_false(ok, "spend_mp with amount 0 should return false")


func test_heal_member_restores_hp() -> void:
	var edren: Dictionary = PartyState.get_member("edren")
	edren["current_hp"] = edren.get("max_hp", 100) - 50
	var restored: int = PartyState.heal_member("edren", 30)
	assert_eq(restored, 30, "Should restore exactly 30 HP")
	assert_eq(edren.get("current_hp", 0), edren.get("max_hp", 100) - 20)


func test_heal_member_clamps_to_max() -> void:
	var edren: Dictionary = PartyState.get_member("edren")
	var max_hp: int = edren.get("max_hp", 100)
	edren["current_hp"] = max_hp - 10
	var restored: int = PartyState.heal_member("edren", 100)
	assert_eq(restored, 10, "Should only restore up to max HP")
	assert_eq(edren.get("current_hp", 0), max_hp, "HP should be clamped to max")


func test_heal_member_unknown_character() -> void:
	var restored: int = PartyState.heal_member("nonexistent", 50)
	assert_eq(restored, 0, "Healing unknown character should return 0")
