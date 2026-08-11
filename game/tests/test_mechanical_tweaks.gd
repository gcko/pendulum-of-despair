extends GutTest
## Tests for Phase B2 mechanical tweaks.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


func before_each() -> void:
	# Restore a clean party so these tests are order-independent (they mutate
	# the PartyState autoload via initialize_new_game / add_xp).
	PartyState.initialize_new_game()


func test_cael_hidden_spike_applied_at_join() -> void:
	# GAP-010: Cael's hidden spike (+2 ATK / +2 MAG / +1 SPD) is baked into his
	# base stats data-drivenly when he joins (no in-game notification).
	var cael: Dictionary = PartyState.get_member("cael")
	var char_data: Dictionary = DataManager.load_character("cael")
	var raw: Dictionary = ProgressionHelpers.calculate_stats_at_level(
		char_data.get("base_stats", {}), char_data.get("growth", {}), cael.get("level", 1)
	)
	assert_eq(int(cael["base_stats"]["atk"]), int(raw["atk"]) + 2, "Cael ATK +2")
	assert_eq(int(cael["base_stats"]["mag"]), int(raw["mag"]) + 2, "Cael MAG +2")
	assert_eq(int(cael["base_stats"]["spd"]), int(raw["spd"]) + 1, "Cael SPD +1")


func test_cael_hidden_spike_survives_level_up() -> void:
	# GAP-010 permanence: the spike must NOT be wiped when level-up recomputes
	# base_stats. Grant enough XP to gain at least one level, then re-check.
	var cael: Dictionary = PartyState.get_member("cael")
	var result: Dictionary = ProgressionHelpers.add_xp_to_member(cael, 99999)
	assert_gt(result.get("new_level", 1), 1, "precondition: Cael leveled up")
	var char_data: Dictionary = DataManager.load_character("cael")
	var raw: Dictionary = ProgressionHelpers.calculate_stats_at_level(
		char_data.get("base_stats", {}), char_data.get("growth", {}), cael.get("level", 1)
	)
	assert_eq(int(cael["base_stats"]["atk"]), int(raw["atk"]) + 2, "spike persists: ATK +2")
	assert_eq(int(cael["base_stats"]["mag"]), int(raw["mag"]) + 2, "spike persists: MAG +2")
	assert_eq(int(cael["base_stats"]["spd"]), int(raw["spd"]) + 1, "spike persists: SPD +1")


func test_non_spiked_character_has_no_spike() -> void:
	# Edren carries no hidden_spike data, so his stats are unmodified.
	var edren: Dictionary = PartyState.get_member("edren")
	var char_data: Dictionary = DataManager.load_character("edren")
	var raw: Dictionary = ProgressionHelpers.calculate_stats_at_level(
		char_data.get("base_stats", {}), char_data.get("growth", {}), edren.get("level", 1)
	)
	assert_eq(int(edren["base_stats"]["atk"]), int(raw["atk"]), "no spike for Edren")


func _get_edren_equipment() -> Dictionary:
	for member: Dictionary in PartyState.members:
		if member.get("character_id", "") == "edren":
			return member.get("equipment", {})
	return {}


func test_arcanite_gear_equipped_on_new_game() -> void:
	PartyState.initialize_new_game()
	var edren_equip: Dictionary = _get_edren_equipment()
	assert_eq(
		edren_equip.get("weapon", ""),
		"arcanite_sword_proto",
		"Edren should start with arcanite sword"
	)
	assert_eq(
		edren_equip.get("body", ""), "arcanite_mail_proto", "Edren should start with arcanite mail"
	)


func test_arcanite_gear_stats() -> void:
	var weapons: Array = DataManager.load_json("res://data/equipment/weapons.json").get(
		"weapons", []
	)
	var sword: Dictionary = {}
	for w: Dictionary in weapons:
		if w.get("id", "") == "arcanite_sword_proto":
			sword = w
			break
	assert_eq(sword.get("atk", 0), 13, "Arcanite sword ATK should be 13")

	var armor: Array = DataManager.load_json("res://data/equipment/armor.json").get("armor", [])
	var mail: Dictionary = {}
	for a: Dictionary in armor:
		if a.get("id", "") == "arcanite_mail_proto":
			mail = a
			break
	assert_eq(mail.get("def", 0), 10, "Arcanite mail DEF should be 10")


func test_break_arcanite_gear_removes_equipment() -> void:
	PartyState.initialize_new_game()
	PartyState.break_arcanite_gear()
	var edren_equip: Dictionary = _get_edren_equipment()
	assert_eq(edren_equip.get("weapon", ""), "", "Edren weapon should be empty after break")
	assert_eq(edren_equip.get("body", ""), "", "Edren body should be empty after break")


func test_break_arcanite_gear_emits_signal() -> void:
	PartyState.initialize_new_game()
	watch_signals(PartyState)
	PartyState.break_arcanite_gear()
	assert_signal_emitted(PartyState, "equipment_changed")
