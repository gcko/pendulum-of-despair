extends GutTest
## Tests for Phase B2 mechanical tweaks.

const DamageCalc = preload("res://scripts/combat/damage_calculator.gd")


func test_cael_physical_damage_10_percent_higher() -> void:
	seed(42)
	var base: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, ""
	)
	seed(42)
	var cael: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "cael"
	)
	assert_gt(cael, base, "Cael physical damage should exceed base")
	var ratio: float = float(cael) / float(base)
	assert_almost_eq(ratio, 1.1, 0.02, "Cael multiplier should be ~1.1x")


func test_non_cael_no_shimmer() -> void:
	seed(42)
	var edren: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "edren"
	)
	seed(42)
	var generic: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, ""
	)
	assert_eq(edren, generic, "Non-Cael characters should deal standard damage")


func test_cael_physical_shimmer_does_not_affect_magic() -> void:
	# calculate_magic has no attacker_id parameter by design — Pallor Shimmer
	# is physical-only. This test documents that architectural decision.
	seed(42)
	var cael_phys: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "cael"
	)
	seed(42)
	var generic_phys: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "edren"
	)
	assert_gt(cael_phys, generic_phys, "Cael physical should be boosted by shimmer")
	seed(42)
	var cael_mag: int = DamageCalc.calculate_magic(20, 50, 10, 1.0, 1.0, [], [])
	seed(42)
	var generic_mag: int = DamageCalc.calculate_magic(20, 50, 10, 1.0, 1.0, [], [])
	assert_eq(cael_mag, generic_mag, "Magic has no attacker_id — shimmer cannot apply")


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
