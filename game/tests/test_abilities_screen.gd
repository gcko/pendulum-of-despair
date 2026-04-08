extends GutTest
## Tests for ability resolution, cost formatting, and integration via AbilityHelpers.

const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.initialize_new_game()
	EventFlags.clear_all()


# --- Ability resolution ---


func test_edren_abilities_level_1() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 1)
	assert_eq(abilities.size(), 1, "Edren Lv1 should know exactly 1 ability")
	assert_eq(abilities[0].get("name", ""), "Ironwall", "Edren Lv1 ability should be Ironwall")


func test_cael_abilities_level_1() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("cael", 1)
	assert_eq(abilities.size(), 1, "Cael Lv1 should know exactly 1 ability")
	assert_eq(
		abilities[0].get("name", ""), "Hold the Line", "Cael Lv1 ability should be Hold the Line"
	)


func test_edren_abilities_level_10() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 10)
	assert_eq(abilities.size(), 3, "Edren Lv10 should know exactly 3 abilities")
	var names: Array = []
	for a: Dictionary in abilities:
		names.append(a.get("name", ""))
	assert_has(names, "Ironwall")
	assert_has(names, "Riposte")
	assert_has(names, "Rampart")


func test_lira_abilities_level_1() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("lira", 1)
	assert_eq(abilities.size(), 2, "Lira Lv1 should know exactly 2 abilities")
	var names: Array = []
	for a: Dictionary in abilities:
		names.append(a.get("name", ""))
	assert_has(names, "Shock Coil")
	assert_has(names, "Salvage")


func test_all_6_characters_have_ability_data() -> void:
	var characters: Array = ["edren", "cael", "lira", "maren", "sable", "torren"]
	for char_id: String in characters:
		var abilities: Array = DataManager.load_abilities(char_id)
		assert_gt(
			abilities.size(),
			0,
			"Character '%s' should have at least one ability in their JSON file" % char_id
		)


func test_story_gated_excluded_without_flag() -> void:
	# Edren has story_gated abilities: steadfast_resolve (trial_edren_complete)
	# and oathkeeper (act_iv_caels_sword). With EventFlags cleared, neither should appear.
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 99)
	var names: Array = []
	for a: Dictionary in abilities:
		names.append(a.get("name", ""))
	assert_does_not_have(
		names, "Steadfast Resolve", "story-gated ability should be excluded without flag"
	)
	assert_does_not_have(names, "Oathkeeper", "story-gated ability should be excluded without flag")


func test_unknown_character_returns_empty() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("nonexistent", 99)
	assert_eq(abilities.size(), 0, "Unknown character should return an empty ability list")


func test_abilities_sorted_by_level() -> void:
	# Edren Lv22 knows all non-gated abilities — verify ascending level_learned order.
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 22)
	assert_gt(abilities.size(), 1, "Edren Lv22 should know more than one ability")
	for i: int in range(abilities.size() - 1):
		var a: Dictionary = abilities[i]
		var b: Dictionary = abilities[i + 1]
		var la: int = a.get("level_learned", 0) if a.get("level_learned") is int else 0
		var lb: int = b.get("level_learned", 0) if b.get("level_learned") is int else 0
		assert_lte(
			la,
			lb,
			(
				"Ability '%s' (Lv%d) should come before '%s' (Lv%d)"
				% [a.get("name", ""), la, b.get("name", ""), lb]
			)
		)


# --- Cost formatting ---


func test_format_cost_ap() -> void:
	var ability: Dictionary = {"cost_type": "ap", "cost_value": 2}
	assert_eq(AbilityHelpers.format_cost(ability), "2 AP", "AP cost should format as '2 AP'")


func test_format_cost_mp() -> void:
	var ability: Dictionary = {"cost_type": "mp", "cost_value": 6}
	assert_eq(AbilityHelpers.format_cost(ability), "6 MP", "MP cost should format as '6 MP'")


func test_format_cost_ac() -> void:
	var ability: Dictionary = {"cost_type": "ac", "cost_value": 3}
	assert_eq(AbilityHelpers.format_cost(ability), "3 AC", "AC cost should format as '3 AC'")


func test_format_cost_wg() -> void:
	var ability: Dictionary = {"cost_type": "wg", "cost_value": 50}
	assert_eq(AbilityHelpers.format_cost(ability), "50 WG", "WG cost should format as '50 WG'")


func test_format_cost_mp_cd() -> void:
	var ability: Dictionary = {"cost_type": "mp_cd", "cost_value": 4, "cooldown": 2}
	assert_eq(
		AbilityHelpers.format_cost(ability),
		"4 MP/2t",
		"MP+cooldown cost should format as '4 MP/2t'"
	)


func test_format_cost_none() -> void:
	var ability: Dictionary = {"cost_type": "none"}
	assert_eq(
		AbilityHelpers.format_cost(ability), "Passive", "No-cost ability should format as 'Passive'"
	)


func test_format_cost_fallback() -> void:
	var ability: Dictionary = {"cost_type": "unknown", "cost": "Special"}
	assert_eq(
		AbilityHelpers.format_cost(ability),
		"Special",
		"Unknown cost_type should fall back to the 'cost' string field"
	)


# --- Integration ---


func test_load_abilities_missing_returns_empty() -> void:
	var abilities: Array = DataManager.load_abilities("nonexistent")
	assert_eq(
		abilities.size(), 0, "Loading abilities for a missing character JSON should return []"
	)


func test_all_ability_ids_unique_per_character() -> void:
	var characters: Array = ["edren", "cael", "lira", "maren", "sable", "torren"]
	for char_id: String in characters:
		var abilities: Array = DataManager.load_abilities(char_id)
		var seen_ids: Dictionary = {}
		for entry: Variant in abilities:
			if not entry is Dictionary:
				continue
			var ability: Dictionary = entry as Dictionary
			var aid: String = ability.get("id", "")
			assert_false(
				seen_ids.has(aid),
				"Duplicate ability id '%s' found for character '%s'" % [aid, char_id]
			)
			seen_ids[aid] = true
