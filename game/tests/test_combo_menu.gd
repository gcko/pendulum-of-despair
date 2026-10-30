extends GutTest
## What the Combo command offers the character whose turn it is (#176 slice b).
##
## Readings for 176b, posted on #176 and recorded in abilities.md § 2:
## - The Combo menu lists only the combos that take in the acting character and
##   a partner who is ready.
## - A combo the partners cannot pay for, whose usage condition is unmet, or
##   whose effect is not built yet is listed grayed, as Magic grays a spell.
## - The Combo command sits after the unique command and is grayed when no
##   combo is listed for the acting character.

const BattleCombos = preload("res://scripts/combat/battle_combos.gd")
const BattleState = preload("res://scripts/combat/battle_state.gd")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")
const SubmenuItems := preload("res://scripts/ui/battle_submenu_items.gd")

## Maren, Torren, Lira and Cael at level 1: every combo they can form that
## names no ability is open (Ley Torrent, Arcane Convergence, Promise of Dawn).
const MAREN := 0
const TORREN := 1
const LIRA := 2
const CAEL := 3
const PARTY: Array[String] = ["maren", "torren", "lira", "cael"]

var _state: Node
var _atb: Node


func before_each() -> void:
	TestHelpers.reset_game_state()
	_state = BattleState.new()
	add_child_autofree(_state)
	_atb = ATBSystem.new()
	add_child_autofree(_atb)
	for slot: int in range(PARTY.size()):
		_state.add_member(
			slot, {"character_id": PARTY[slot], "level": 1, "base_stats": {"hp": 100, "mp": 99}}
		)
		_atb.add_combatant("party_%d" % slot, 10, false)
		_atb.set_gauge("party_%d" % slot, ATBSystem.GAUGE_MAX)


func after_each() -> void:
	TestHelpers.reset_game_state()


func _listed(slot: int) -> Array:
	return SubmenuItems.combos(_state, _atb, slot).map(
		func(item: Dictionary) -> String: return item["command"]["combo_id"]
	)


func _item(slot: int, combo_id: String) -> Dictionary:
	for item: Dictionary in SubmenuItems.combos(_state, _atb, slot):
		if item["command"]["combo_id"] == combo_id:
			return item
	return {}


# ── who is listed ───────────────────────────────────────────────────────


func test_the_menu_lists_only_the_combos_the_actor_is_part_of() -> void:
	var for_maren: Array = _listed(MAREN)
	for_maren.sort()
	assert_eq(for_maren, ["arcane_convergence", "ley_torrent"], "Maren's two")
	assert_eq(_listed(TORREN), ["ley_torrent"], "Torren's one")
	assert_does_not_have(for_maren, "promise_of_dawn", "Lira and Cael's, not Maren's")


func test_a_partner_still_filling_takes_their_combo_off_the_actor_s_list() -> void:
	_atb.set_gauge("party_%d" % TORREN, ATBSystem.GAUGE_MAX - 1)
	assert_eq(_listed(MAREN), ["arcane_convergence"], "Torren is not ready")


func test_a_confused_partner_takes_their_combo_off_the_actor_s_list() -> void:
	_state.apply_status(TORREN, "confusion", "turns", 3)
	assert_does_not_have(_listed(MAREN), "ley_torrent", "Torren cannot be commanded")


func test_silence_on_a_partner_whose_share_it_stops_takes_the_combo_off() -> void:
	# Cael's share of Promise of Dawn is a Rally, which Silence ends.
	assert_has(_listed(LIRA), "promise_of_dawn", "open before the Silence")
	_state.apply_status(CAEL, "silence", "turns", 3)
	assert_does_not_have(_listed(LIRA), "promise_of_dawn", "Cael is Silenced")


func test_each_entry_names_the_partner_and_both_shares() -> void:
	assert_eq(_item(MAREN, "ley_torrent")["label"], "Ley Torrent (Torren)  10/8 MP")
	assert_eq(_item(TORREN, "ley_torrent")["label"], "Ley Torrent (Maren)  8/10 MP")


# ── grayed entries ──────────────────────────────────────────────────────


func test_ley_torrent_is_selectable_when_both_can_pay() -> void:
	assert_true(_item(MAREN, "ley_torrent")["enabled"], "built, paid for, no condition")
	assert_eq(_item(MAREN, "ley_torrent")["target_type"], "all_enemies", "it hits every enemy")


func test_a_combo_a_partner_cannot_pay_for_is_listed_grayed() -> void:
	_state.get_member(TORREN)["current_mp"] = 7
	var item: Dictionary = _item(MAREN, "ley_torrent")
	assert_false(item.is_empty(), "short MP still lists it")
	assert_false(item["enabled"], "Torren is a point short of his 8")


func test_a_combo_whose_effect_is_not_built_is_listed_grayed() -> void:
	var item: Dictionary = _item(MAREN, "arcane_convergence")
	assert_false(item.is_empty(), "listed")
	assert_false(item["enabled"], "Arcane Convergence lands in 176c")


func test_arcane_convergence_s_condition_is_a_device_of_lira_s_on_the_field() -> void:
	var slots: Array[int] = [MAREN, LIRA]
	assert_false(BattleCombos.condition_met("arcane_convergence", _state, slots), "no devices")
	_state.get_member(LIRA)["forgewright"] = {"devices": [{"id": "bulkhead"}]}
	assert_true(BattleCombos.condition_met("arcane_convergence", _state, slots), "one standing")


func test_spiritward_s_condition_is_edren_in_a_bulwark_stance() -> void:
	_state.add_member(LIRA, {"character_id": "edren", "level": 1, "base_stats": {"hp": 100}})
	var slots: Array[int] = [TORREN, LIRA]
	assert_false(BattleCombos.condition_met("spiritward", _state, slots), "no stance")
	BattleBulwark.enter_stance(_state, LIRA, "rampart", -1)
	assert_true(BattleCombos.condition_met("spiritward", _state, slots), "Rampart held")


func test_shattered_vanguard_s_condition_is_a_stance_holding_stored_damage() -> void:
	_state.add_member(MAREN, {"character_id": "edren", "level": 1, "base_stats": {"hp": 100}})
	var slots: Array[int] = [MAREN, TORREN]
	BattleBulwark.enter_stance(_state, MAREN, "rampart", -1)
	assert_false(
		BattleCombos.condition_met("shattered_vanguard", _state, slots), "a stance, nothing stored"
	)
	_state.get_member(MAREN)["bulwark"]["absorbed_total"] = 30
	assert_true(BattleCombos.condition_met("shattered_vanguard", _state, slots), "30 stored")


func test_an_unmet_condition_grays_a_combo_even_once_it_is_built() -> void:
	# No built combo has a condition yet; usable_entry is where 176c's will meet it.
	var entry: Dictionary = {
		"id": "arcane_convergence", "combo": {}, "slots": [MAREN, LIRA], "affordable": true
	}
	var built: Array[String] = ["arcane_convergence"]
	assert_false(BattleCombos.usable(entry, _state, built), "no devices on the field")
	_state.get_member(LIRA)["forgewright"] = {"devices": [{"id": "bulkhead"}]}
	assert_true(BattleCombos.usable(entry, _state, built), "a device to converge")


# ── the command ─────────────────────────────────────────────────────────


func _menu() -> Node:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	return m


func test_the_combo_command_follows_the_unique_command() -> void:
	var m: Node = _menu()
	m.show_commands({"character_id": "maren", "level": 1}, false, {}, [_item(MAREN, "ley_torrent")])
	var labels: Array = m._commands.map(func(c: Dictionary) -> String: return c["label"])
	assert_eq(labels, ["Attack", "Magic", "Arcanum", "Combo", "Item", "Defend", "Flee"])


func test_the_combo_command_is_grayed_with_no_combo_listed() -> void:
	var m: Node = _menu()
	m.show_commands({"character_id": "maren", "level": 1}, false, {}, [])
	assert_false(m._commands[3]["enabled"], "nothing to call")
	m.show_commands({"character_id": "maren", "level": 1}, false, {}, [_item(MAREN, "ley_torrent")])
	assert_true(m._commands[3]["enabled"], "Ley Torrent is on offer")


func test_choosing_ley_torrent_submits_the_combo_without_a_target_cursor() -> void:
	var m: Node = _menu()
	m.show_commands(
		{"character_id": "maren", "level": 1}, false, {}, SubmenuItems.combos(_state, _atb, MAREN)
	)
	watch_signals(m)
	m._cursor = 3
	m._confirm_command()
	var at: int = _listed(MAREN).find("ley_torrent")
	m._submenu_cursor = at
	m._confirm_submenu()
	assert_signal_emitted_with_parameters(
		m, "command_selected", [{"type": "combo", "combo_id": "ley_torrent"}]
	)
