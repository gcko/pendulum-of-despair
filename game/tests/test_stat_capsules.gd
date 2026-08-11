extends GutTest
## Permanent stat capsules (GAP-020 / #165) and the level-up recalculation that
## must not drop equipment bonuses (#274).
##
## Design source: items.md § Stat Capsules, progression.md § Stat Caps,
## § Equipment and Buffs, § Level-Up Effects.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")
const BattleStateScript = preload("res://scripts/combat/battle_state.gd")
const EquipMenuScript = preload("res://scripts/ui/menu_equip.gd")

# life_pendant grants +300 HP, mana_bead grants +50 MP (accessories.json).
const HP_ACCESSORY: String = "life_pendant"
const HP_ACCESSORY_BONUS: int = 300
const MP_ACCESSORY: String = "mana_bead"
const MP_ACCESSORY_BONUS: int = 50
# Edren swords (weapons.json): training_sword ATK 4, knights_edge ATK 12.
const WEAK_SWORD: String = "training_sword"
const WEAK_SWORD_ATK: int = 4
const STRONG_SWORD: String = "knights_edge"
const STRONG_SWORD_ATK: int = 12
# iron_core reaches Lv3 at 2500 XP, where it starts granting hp_per_level.
const CRYSTAL_HP: String = "iron_core"
const CRYSTAL_HP_XP_TO_LV3: int = 2500
# Enough XP to guarantee at least one level from level 1.
const LEVEL_UP_XP: int = 99999


func before_each() -> void:
	TestHelpers.reset_game_state()
	PartyState.initialize_new_game()


func after_each() -> void:
	TestHelpers.reset_game_state()


func _equip(character_id: String, slot: String, equipment_id: String) -> void:
	PartyState.add_equipment(equipment_id)
	PartyState.equip_item(character_id, slot, equipment_id)


func _level_up(character_id: String) -> void:
	var member: Dictionary = PartyState.get_member(character_id)
	var result: Dictionary = Helpers.add_xp_to_member(member, LEVEL_UP_XP)
	assert_true(result.get("leveled_up", false), "precondition: %s leveled up" % character_id)


func _give_capsule(item_id: String, character_id: String) -> bool:
	PartyState.add_item(item_id, 1)
	return PartyState.use_item(item_id, character_id)


## Equip sub-screen instance for the projection under test. Deliberately not
## added to the tree: _ready() only wires scene labels the projection never
## touches, and the menu has no scene of its own to instantiate.
func _equip_menu() -> Node:
	var menu: Node = EquipMenuScript.new()
	autofree(menu)
	return menu


# --- #274: level-up must keep equipment HP/MP bonuses ---


func test_level_up_keeps_equipment_hp_bonus() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	assert_eq(
		PartyState.get_equipment_bonus("edren", "hp"),
		HP_ACCESSORY_BONUS,
		"precondition: accessory grants HP",
	)
	_level_up("edren")
	var edren: Dictionary = PartyState.get_member("edren")
	var base_hp: int = edren.get("base_stats", {}).get("hp", 0)
	assert_eq(
		int(edren.get("max_hp", 0)),
		base_hp + HP_ACCESSORY_BONUS,
		"level-up must not drop the equipment HP bonus",
	)


func test_level_up_keeps_equipment_mp_bonus() -> void:
	_equip("edren", "accessory", MP_ACCESSORY)
	assert_eq(
		PartyState.get_equipment_bonus("edren", "mp"),
		MP_ACCESSORY_BONUS,
		"precondition: accessory grants MP",
	)
	_level_up("edren")
	var edren: Dictionary = PartyState.get_member("edren")
	var base_mp: int = edren.get("base_stats", {}).get("mp", 0)
	assert_eq(
		int(edren.get("max_mp", 0)),
		base_mp + MP_ACCESSORY_BONUS,
		"level-up must not drop the equipment MP bonus",
	)


func test_level_up_max_hp_matches_effective_hp() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	_level_up("edren")
	assert_eq(
		int(PartyState.get_member("edren").get("max_hp", 0)),
		PartyState.get_effective_stat("edren", "hp"),
		"max_hp after level-up must equal the one effective-HP formula",
	)


func test_level_up_still_refills_hp_and_mp() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	var edren: Dictionary = PartyState.get_member("edren")
	edren["current_hp"] = 1
	edren["current_mp"] = 0
	_level_up("edren")
	assert_eq(int(edren.get("current_hp", 0)), int(edren.get("max_hp", -1)), "level-up refills HP")
	assert_eq(int(edren.get("current_mp", -1)), int(edren.get("max_mp", 0)), "level-up refills MP")


# --- GAP-020: capsules raise the effective stat ---


func test_capsule_raises_effective_stat() -> void:
	var before: int = PartyState.get_effective_stat("edren", "atk")
	assert_true(_give_capsule("strength_capsule", "edren"), "capsule should be consumed")
	assert_eq(
		PartyState.get_effective_stat("edren", "atk"), before + 1, "Strength Capsule = ATK +1"
	)


func test_capsules_stack() -> void:
	var before: int = PartyState.get_effective_stat("edren", "def")
	_give_capsule("guardian_capsule", "edren")
	_give_capsule("guardian_capsule", "edren")
	_give_capsule("guardian_capsule", "edren")
	assert_eq(
		PartyState.get_effective_stat("edren", "def"), before + 3, "capsule gains are additive"
	)


func test_capsule_applies_only_to_its_target() -> void:
	var cael_before: int = PartyState.get_effective_stat("cael", "atk")
	_give_capsule("strength_capsule", "edren")
	assert_eq(
		PartyState.get_effective_stat("cael", "atk"),
		cael_before,
		"a capsule boosts only the character it was used on",
	)


func test_capsule_stored_in_stat_capsules_not_top_level() -> void:
	_give_capsule("arcane_capsule", "edren")
	var edren: Dictionary = PartyState.get_member("edren")
	assert_eq(int(edren.get("stat_capsules", {}).get("mag", 0)), 1, "gain lives in stat_capsules")
	assert_false(edren.has("mag"), "no vestigial top-level stat field is written")


# --- GAP-020: the boost survives a level-up ---


func test_capsule_survives_level_up() -> void:
	_give_capsule("swiftness_capsule", "edren")
	var before: int = PartyState.get_effective_stat("edren", "spd")
	var base_before: int = PartyState.get_member("edren").get("base_stats", {}).get("spd", 0)
	_level_up("edren")
	var edren: Dictionary = PartyState.get_member("edren")
	var base_after: int = edren.get("base_stats", {}).get("spd", 0)
	assert_eq(
		int(edren.get("stat_capsules", {}).get("spd", 0)),
		1,
		"level-up recalculation must not wipe capsule gains",
	)
	assert_eq(
		PartyState.get_effective_stat("edren", "spd"),
		before + (base_after - base_before),
		"effective SPD keeps the capsule on top of the new base",
	)


func test_capsule_and_equipment_both_survive_level_up() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	_give_capsule("fortune_capsule", "edren")
	_level_up("edren")
	var edren: Dictionary = PartyState.get_member("edren")
	assert_eq(
		int(edren.get("max_hp", 0)),
		edren.get("base_stats", {}).get("hp", 0) + HP_ACCESSORY_BONUS,
		"equipment HP bonus survives",
	)
	assert_eq(
		PartyState.get_effective_stat("edren", "lck"),
		edren.get("base_stats", {}).get("lck", 0) + 1,
		"capsule LCK gain survives",
	)


func test_capsule_survives_equipment_change() -> void:
	_give_capsule("warding_capsule", "edren")
	var before: int = PartyState.get_effective_stat("edren", "mdef")
	_equip("edren", "accessory", HP_ACCESSORY)
	PartyState.unequip_slot("edren", "accessory")
	assert_eq(
		PartyState.get_effective_stat("edren", "mdef"),
		before,
		"equip/unequip recalculation must not wipe capsule gains",
	)


# --- GAP-020: capsule gains reach combat ---


func test_capsule_reaches_battle_effective_stats() -> void:
	var battle: Node = BattleStateScript.new()
	add_child_autofree(battle)
	_give_capsule("strength_capsule", "edren")
	var edren: Dictionary = PartyState.get_member("edren")
	battle.add_member(0, edren)
	assert_eq(
		battle.get_effective_stat(0, "atk"),
		PartyState.get_effective_stat("edren", "atk"),
		"battle ATK must include the capsule gain",
	)


func test_battle_effective_stat_clamps_at_the_cap() -> void:
	# progression.md § Equipment and Buffs: equipment cannot push a stat past
	# 255. Combat bakes its own copy of the effective stats, so it must clamp
	# exactly where the status/equip menus do.
	var member: Dictionary = PartyState.get_member("edren")
	member["base_stats"]["atk"] = 255
	_equip("edren", "weapon", STRONG_SWORD)
	assert_eq(PartyState.get_effective_stat("edren", "atk"), 255, "menu ATK must clamp at the cap")
	var battle: Node = BattleStateScript.new()
	add_child_autofree(battle)
	battle.add_member(0, PartyState.get_member("edren"))
	assert_eq(
		battle.get_effective_stat(0, "atk"),
		255,
		"combat ATK must clamp at the same cap the menus use",
	)


# --- GAP-020: capsule gains round-trip through save ---


func test_capsule_round_trips_through_save() -> void:
	_give_capsule("strength_capsule", "edren")
	_give_capsule("strength_capsule", "edren")
	var expected: int = PartyState.get_effective_stat("edren", "atk")
	var save_data: Dictionary = PartyState.build_save_data()
	PartyState.load_from_save(save_data)
	assert_eq(
		int(PartyState.get_member("edren").get("stat_capsules", {}).get("atk", 0)),
		2,
		"capsule gains persist through save/load",
	)
	assert_eq(
		PartyState.get_effective_stat("edren", "atk"), expected, "effective ATK survives reload"
	)


# --- Legacy saves written before stat_capsules existed ---


func test_legacy_save_without_capsules_loads() -> void:
	var save_data: Dictionary = PartyState.build_save_data()
	for entry: Variant in save_data.get("party", []):
		if entry is Dictionary:
			(entry as Dictionary).erase("stat_capsules")
	PartyState.load_from_save(save_data)
	var edren: Dictionary = PartyState.get_member("edren")
	assert_false(edren.is_empty(), "legacy member should still load")
	assert_eq(
		PartyState.get_effective_stat("edren", "atk"),
		edren.get("base_stats", {}).get("atk", 0) + PartyState.get_equipment_bonus("edren", "atk"),
		"missing stat_capsules key defaults to no capsule gain",
	)


func test_legacy_member_can_receive_capsule() -> void:
	var save_data: Dictionary = PartyState.build_save_data()
	for entry: Variant in save_data.get("party", []):
		if entry is Dictionary:
			(entry as Dictionary).erase("stat_capsules")
	PartyState.load_from_save(save_data)
	var before: int = PartyState.get_effective_stat("edren", "atk")
	assert_true(_give_capsule("strength_capsule", "edren"), "capsule should be consumed")
	assert_eq(
		PartyState.get_effective_stat("edren", "atk"),
		before + 1,
		"a legacy member gains the stat_capsules dict on first use",
	)


func test_legacy_member_level_up_keeps_equipment_bonus() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	var save_data: Dictionary = PartyState.build_save_data()
	for entry: Variant in save_data.get("party", []):
		if entry is Dictionary:
			(entry as Dictionary).erase("stat_capsules")
	PartyState.load_from_save(save_data)
	_level_up("edren")
	var edren: Dictionary = PartyState.get_member("edren")
	assert_eq(
		int(edren.get("max_hp", 0)),
		edren.get("base_stats", {}).get("hp", 0) + HP_ACCESSORY_BONUS,
		"legacy member keeps the equipment HP bonus across a level-up",
	)


# --- The equip menu must project the same formula it compares against ---


func test_equip_projection_of_the_worn_weapon_shows_no_change() -> void:
	_equip("edren", "weapon", STRONG_SWORD)
	_give_capsule("strength_capsule", "edren")
	var menu: Node = _equip_menu()
	var member: Dictionary = PartyState.get_member("edren")
	assert_eq(
		menu._project_stat(member, "atk", "weapon", STRONG_SWORD),
		PartyState.get_effective_stat("edren", "atk"),
		"re-equipping the worn weapon must project no change once a capsule is banked",
	)


func test_equip_projection_keeps_the_capsule_when_the_slot_is_emptied() -> void:
	_equip("edren", "weapon", STRONG_SWORD)
	_give_capsule("strength_capsule", "edren")
	var menu: Node = _equip_menu()
	var member: Dictionary = PartyState.get_member("edren")
	assert_eq(
		menu._project_stat(member, "atk", "weapon", ""),
		int(member.get("base_stats", {}).get("atk", 0)) + 1,
		"removing the weapon drops only the weapon term, never the capsule gain",
	)


func test_equip_projection_reports_the_true_swap_delta() -> void:
	_equip("edren", "weapon", STRONG_SWORD)
	_give_capsule("strength_capsule", "edren")
	var menu: Node = _equip_menu()
	var member: Dictionary = PartyState.get_member("edren")
	var current: int = PartyState.get_effective_stat("edren", "atk")
	var projected: int = menu._project_stat(member, "atk", "weapon", WEAK_SWORD)
	assert_eq(
		projected - current,
		WEAK_SWORD_ATK - STRONG_SWORD_ATK,
		"the arrow delta is the weapon difference alone",
	)


func test_equip_projection_matches_the_effective_stat_after_the_swap() -> void:
	_equip("edren", "weapon", STRONG_SWORD)
	_give_capsule("strength_capsule", "edren")
	var menu: Node = _equip_menu()
	var projected: int = menu._project_stat(
		PartyState.get_member("edren"), "atk", "weapon", WEAK_SWORD
	)
	_equip("edren", "weapon", WEAK_SWORD)
	assert_eq(
		projected,
		PartyState.get_effective_stat("edren", "atk"),
		"the projection must equal what the stat actually becomes",
	)


# --- items.md § Stat Capsules: a finite item is refused, never burned ---


func test_capsule_is_refused_once_the_permanent_total_is_at_cap() -> void:
	var edren: Dictionary = PartyState.get_member("edren")
	edren["base_stats"]["atk"] = Helpers.stat_cap("atk")
	PartyState.add_item("strength_capsule", 1)
	assert_false(
		PartyState.use_item("strength_capsule", "edren"), "a capped stat refuses the capsule"
	)
	assert_eq(
		int(PartyState.get_consumables().get("strength_capsule", 0)),
		1,
		"the refused capsule stays in the bag instead of being burned",
	)


func test_capsule_is_accepted_when_only_equipment_reaches_the_cap() -> void:
	var edren: Dictionary = PartyState.get_member("edren")
	edren["base_stats"]["atk"] = Helpers.stat_cap("atk") - STRONG_SWORD_ATK
	_equip("edren", "weapon", STRONG_SWORD)
	assert_eq(
		PartyState.get_effective_stat("edren", "atk"),
		Helpers.stat_cap("atk"),
		"precondition: gear alone holds ATK at the cap",
	)
	assert_true(
		_give_capsule("strength_capsule", "edren"), "a gear-only cap still accepts a capsule"
	)
	assert_eq(
		int(edren.get("stat_capsules", {}).get("atk", 0)),
		1,
		"the gain is banked for when the gear comes off",
	)


# --- Max HP/MP are derived, so a heal never sizes off a stale maximum ---


func test_full_restore_heals_to_the_recalculated_maximum() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	var edren: Dictionary = PartyState.get_member("edren")
	# Stale maximum as a save written before #274 would hold it.
	edren["max_hp"] = int(edren["max_hp"]) - HP_ACCESSORY_BONUS
	edren["current_hp"] = 1
	PartyState.add_item("elixir", 1)
	assert_true(PartyState.use_item("elixir", "edren"), "precondition: the Elixir is usable")
	assert_eq(
		int(edren.get("current_hp", 0)),
		PartyState.get_effective_stat("edren", "hp"),
		"a full restore must fill to the true maximum, not a stale one",
	)


func test_load_from_save_rederives_a_stale_max_hp() -> void:
	_equip("edren", "accessory", HP_ACCESSORY)
	var save_data: Dictionary = PartyState.build_save_data()
	for entry: Variant in save_data.get("party", []):
		if entry is Dictionary and (entry as Dictionary).get("character_id", "") == "edren":
			(entry as Dictionary)["max_hp"] = 1
	PartyState.load_from_save(save_data)
	assert_eq(
		int(PartyState.get_member("edren").get("max_hp", 0)),
		PartyState.get_effective_stat("edren", "hp"),
		"max HP is derived at load time, never trusted from the file",
	)


# --- A Ley Crystal level-up is a change to its holder's persistent stats ---


func test_crystal_level_up_updates_the_holder_max_hp() -> void:
	PartyState.add_ley_crystal(CRYSTAL_HP)
	PartyState.equip_crystal("edren", CRYSTAL_HP)
	var edren: Dictionary = PartyState.get_member("edren")
	var before: int = int(edren.get("max_hp", 0))
	PartyState.add_crystal_xp(CRYSTAL_HP, CRYSTAL_HP_XP_TO_LV3)
	assert_eq(
		int(PartyState.get_crystal_state(CRYSTAL_HP).get("level", 0)),
		3,
		"precondition: the crystal reached the level that grants HP",
	)
	assert_gt(
		PartyState.get_crystal_stat_bonus(CRYSTAL_HP, "hp", int(edren.get("level", 1))),
		0,
		"precondition: that level grants HP per character level",
	)
	assert_gt(int(edren.get("max_hp", 0)), before, "levelling the crystal raises its holder's HP")
	assert_eq(
		int(edren.get("max_hp", 0)),
		PartyState.get_effective_stat("edren", "hp"),
		"and does so through the one shared formula",
	)


func test_crystal_level_up_leaves_a_non_holder_alone() -> void:
	PartyState.add_ley_crystal(CRYSTAL_HP)
	PartyState.equip_crystal("edren", CRYSTAL_HP)
	var cael: Dictionary = PartyState.get_member("cael")
	var before: int = int(cael.get("max_hp", 0))
	PartyState.add_crystal_xp(CRYSTAL_HP, CRYSTAL_HP_XP_TO_LV3)
	assert_eq(int(cael.get("max_hp", 0)), before, "a crystal only changes the character wearing it")
