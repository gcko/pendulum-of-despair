extends GutTest
## Worn gear keeps the statuses it names off its wearer in battle (#512).
##
## The gear and the status each one wards off are equipment.md's own:
##   - § Status Immunity Accessories: Antidote Charm (Poison), Clarity Band
##     (Confusion), Silence Ward (Silence), Stone Guard (Petrify), Berserk Collar
##     (Berserk), Despair Ward (Despair);
##   - the Warding Crown ("Silence immune") and Spiritguard Helm ("Sleep immune")
##     head rows, and the purified Grey Cleaver ("Despair immunity");
##   - Dreamer's Mark, "Immunity to all negative status effects (positive ones
##     such as Haste still land)", per the 2026-10-30 ruling.
## A blocked status shows the "Immune" marker the enemy side shows, and lands
## nothing, so no "is Poisoned!" line either. The check comes after the hit roll
## (combat-formulas.md § Status Spell Resolution, step 4).

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const BattleActions = preload("res://scripts/combat/battle_actions.gd")
const StatusEffects = preload("res://scripts/combat/status_effects.gd")

## New-game party: Cael in slot 1 is the one afflicted.
const TARGET: int = 1

## [wearer, slot, equipment id, the status equipment.md says it wards off].
const WARDS: Array = [
	["cael", "accessory", "antidote_charm", "poison"],
	["cael", "accessory", "clarity_band", "confusion"],
	["cael", "accessory", "silence_ward", "silence"],
	["cael", "accessory", "stone_guard", "petrify"],
	["cael", "accessory", "berserk_collar", "berserk"],
	["cael", "accessory", "despair_ward", "despair"],
	["cael", "head", "warding_crown", "silence"],
	["cael", "head", "spiritguard_helm", "sleep"],
	["torren", "weapon", "grey_cleaver_purified", "despair"],
]

var _booted: Node = null


func before_each() -> void:
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


func after_each() -> void:
	if _booted != null and is_instance_valid(_booted):
		_booted.set("_battle_active", false)
		_booted.free()
	_booted = null
	TestHelpers.reset_game_state()
	DataManager.clear_cache()


## Put [param equipment_id] on [param character_id] the way the Equip menu does.
func _wear(character_id: String, slot: String, equipment_id: String) -> void:
	PartyState.add_equipment(equipment_id)
	PartyState.equip_item(character_id, slot, equipment_id)


## A new game with Cael wearing [param worn] ({slot: id}), booted into battle.
func _boot_wearing(worn: Dictionary) -> Node:
	PartyState.initialize_new_game()
	for slot: String in worn:
		_wear("cael", slot, worn[slot])
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": ["ley_vermin"],
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


## A battle-state member for [param character_id], outside any battle scene.
func _state_with(character_id: String) -> Node:
	var state: Node = BattleState.new()
	add_child_autofree(state)
	var stats: Dictionary = {"hp": 100, "mp": 10, "mdef": 0, "spd": 0}
	state.add_member(0, {"character_id": character_id, "name": "X", "base_stats": stats})
	return state


## The enemy's status move [param status] on Cael, made certain to hit: Cael has
## no MDEF or SPD to resist with, and the rate is 100%.
func _enemy_inflicts(battle: Node, status: String) -> void:
	var state: Node = battle.get_battle_state()
	state.get_member(TARGET)["effective_stats"]["mdef"] = 0
	state.get_member(TARGET)["effective_stats"]["spd"] = 0
	BattleActions.execute_enemy_status(state, battle.get_enemies()[0], TARGET, 100, status, null)


func _markers(battle: Node) -> Array:
	var out: Array = []
	battle.damage_dealt.connect(
		func(id: String, amount: int, kind: String) -> void: out.append([id, amount, kind])
	)
	return out


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


# ── What the player sees ─────────────────────────────────────────────────


func test_an_antidote_charm_wearer_is_not_poisoned_and_immune_shows() -> void:
	var battle: Node = _boot_wearing({"accessory": "antidote_charm"})
	var markers: Array = _markers(battle)
	var lines: Array[String] = _messages(battle)

	_enemy_inflicts(battle, "poison")

	assert_false(battle.get_battle_state().has_status(TARGET, "poison"), "Cael is not poisoned")
	assert_eq(markers.count(["party_%d" % TARGET, 0, "immune"]), 1, "Immune shows on Cael, once")
	assert_does_not_have(
		lines, "Cael is Poisoned!", "and nothing announces a Poison that never landed"
	)


func test_without_the_charm_the_same_move_poisons() -> void:
	# The control: the move above does land when nothing wards it off, so the
	# test above is about the charm, not about a move that cannot hit.
	var battle: Node = _boot_wearing({})
	var markers: Array = _markers(battle)

	_enemy_inflicts(battle, "poison")

	assert_true(battle.get_battle_state().has_status(TARGET, "poison"), "Cael is poisoned")
	assert_does_not_have(markers, ["party_%d" % TARGET, 0, "immune"])


func test_dreamers_mark_blocks_poison_but_not_haste() -> void:
	var battle: Node = _boot_wearing({"accessory": "dreamers_mark"})
	var state: Node = battle.get_battle_state()
	var markers: Array = _markers(battle)
	var lines: Array[String] = _messages(battle)

	_enemy_inflicts(battle, "poison")
	state.apply_status(TARGET, "haste", "turns", 5.0)

	assert_false(state.has_status(TARGET, "poison"), "Poison is kept off")
	assert_eq(markers.count(["party_%d" % TARGET, 0, "immune"]), 1, "and shows Immune, once")
	assert_true(state.has_status(TARGET, "haste"), "Haste, a positive status, still lands")
	assert_has(lines, "Cael is Hastened!", "and is announced as usual")


# ── Which gear wards off what ────────────────────────────────────────────


func test_each_piece_of_warding_gear_keeps_its_status_off() -> void:
	for ward: Array in WARDS:
		TestHelpers.reset_game_state()
		PartyState.initialize_new_game()
		if not PartyState.has_member(ward[0]):
			PartyState.add_member(ward[0])
		_wear(ward[0], ward[1], ward[2])
		var state: Node = _state_with(ward[0])

		state.apply_status(0, ward[3], "turns", 3.0)

		assert_false(state.has_status(0, ward[3]), "%s keeps %s off" % [ward[2], ward[3]])


func test_dreamers_mark_keeps_every_negative_status_off() -> void:
	PartyState.initialize_new_game()
	_wear("cael", "accessory", "dreamers_mark")
	var state: Node = _state_with("cael")
	for status: String in StatusEffects.RULES:
		if StatusEffects.is_positive(status):
			continue
		state.apply_status(0, status, "turns", 3.0)
		assert_false(state.has_status(0, status), "Dreamer's Mark keeps %s off" % status)


func test_a_ward_keeps_off_only_the_status_it_names() -> void:
	PartyState.initialize_new_game()
	_wear("cael", "accessory", "antidote_charm")
	var state: Node = _state_with("cael")

	state.apply_status(0, "silence", "turns", 4.0)

	assert_true(state.has_status(0, "silence"), "an Antidote Charm does not stop Silence")


func test_the_wards_of_everything_worn_add_up() -> void:
	PartyState.initialize_new_game()
	_wear("cael", "head", "warding_crown")
	_wear("cael", "accessory", "antidote_charm")
	var state: Node = _state_with("cael")

	state.apply_status(0, "silence", "turns", 4.0)
	state.apply_status(0, "poison", "turns", -1.0)

	assert_false(state.has_status(0, "silence"), "the crown keeps Silence off")
	assert_false(state.has_status(0, "poison"), "and the charm keeps Poison off")


func test_one_piece_of_gear_can_ward_off_a_list_of_statuses() -> void:
	# No shipped item names two yet; a test-local one in the loaded data does.
	PartyState.initialize_new_game()
	var twin_ward: Dictionary = {
		"id": "test_twin_ward",
		"name": "Twin Ward",
		"bonus_stats": {},
		"status_immunity": ["poison", "silence"],
	}
	DataManager.load_equipment("accessories").append(twin_ward)
	_wear("cael", "accessory", "test_twin_ward")
	var state: Node = _state_with("cael")

	state.apply_status(0, "poison", "turns", -1.0)
	state.apply_status(0, "silence", "turns", 4.0)
	state.apply_status(0, "blind", "turns", 4.0)

	assert_false(state.has_status(0, "poison"), "the first status listed is kept off")
	assert_false(state.has_status(0, "silence"), "and so is the second")
	assert_true(state.has_status(0, "blind"), "but not one the list leaves out")


func test_every_positive_status_gets_through_dreamers_mark() -> void:
	# The positive statuses are read from magic.md § Status Effect Reference,
	# not from the registry's own flag, so a positive status added to the
	# registry without that flag is blocked by "all" and turns this red.
	PartyState.initialize_new_game()
	_wear("cael", "accessory", "dreamers_mark")
	var state: Node = _state_with("cael")
	var checked: Array[String] = []
	for status: String in _doc_positive_statuses():
		if not StatusEffects.is_known(status):
			continue  # not built yet: nothing can land it
		checked.append(status)
		state.apply_status(0, status, "turns", 3.0)
		assert_true(state.has_status(0, status), "%s still lands on the wearer" % status)
	assert_true("haste" in checked, "precondition: the scan reached Haste (got %s)" % checked)


## The statuses magic.md § Status Effect Reference types "Positive", as registry
## names: a row's parenthesized name where it has one ("Quickstep (Haste)" ->
## "haste"), else its own ("Regen" -> "regen").
func _doc_positive_statuses() -> Array[String]:
	var path: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir()
	var doc: String = FileAccess.get_file_as_string(path.path_join("docs/story/magic.md"))
	assert_false(doc.is_empty(), "precondition: magic.md is readable")
	var out: Array[String] = []
	var in_table: bool = false
	for line: String in doc.split("\n"):
		if line.begins_with("## Status Effect Reference"):
			in_table = true
		elif in_table and line.begins_with("## "):
			break
		if not in_table or not line.begins_with("| "):
			continue
		var cells: PackedStringArray = line.split("|")
		if cells.size() < 3 or not cells[2].strip_edges().begins_with("Positive"):
			continue
		var status_name: String = cells[1].strip_edges()
		if "(" in status_name:
			status_name = status_name.get_slice("(", 1).get_slice(")", 0)
		out.append(status_name.to_lower())
	return out
