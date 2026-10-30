extends GutTest
## Debuff spells turned on the enemy line land in battle (#514). Before this the
## Magic command sent every one of them down the damage path with power 0, so
## the cast spent MP, dealt the 1-damage floor and did nothing else.
##
## The values are each spell's own magic.md entry: Sunder -30% DEF, Fray -30%
## MDEF and Dampening Field -30% MAG, each for 5 turns, Sunder and Fray at an
## 80% hit rate and Dampening Field at 75%. Debuffs "roll to hit" in the
## standard band (magic.md § Derived Rules), through the same two-stage roll a
## status spell makes. Dispersion strips one enemy's positive effects and Mass
## Dispersion every enemy's; both always land.
##
## Every cast boots battle.tscn and goes in through BattleUI.command_submitted,
## the seam the battle menu feeds. The target's MDEF and SPD are zeroed, so
## Stage 1 meets the base rate in full and Magic Evasion is 0: a debuff cast at
## hit rate 100 always lands and one at 0 always misses. The shipped rates are
## pinned by the data check below. An enemy's buffs count down at the end of
## its own turn (enemy.tick_buffs, which the enemy turn calls), so that is the
## clock the duration tests drive.

const BATTLE: PackedScene = preload("res://scenes/core/battle.tscn")
const ATBSystem = preload("res://scripts/combat/atb_system.gd")
const CommandMenu := preload("res://scripts/ui/battle_command_menu.gd")

const PROMPT_TIMEOUT: float = 5.0
## New-game party: Edren in slot 0 casts.
const CASTER: int = 0
## Every pinned enemy stat starts here, so -30% reads as 70.
const BASE_STAT: int = 100

## [spell id, stat, -%, turns, hit rate], from magic.md § 65, 66 and 70.
const STAT_DEBUFFS: Array = [
	["sunder", "def", 30, 5, 80],
	["fray", "mdef", 30, 5, 80],
	["dampening_field", "mag", 30, 5, 75],
]

## Enemy-side spells with no battle effect built yet: Crumble's resistance
## shift, Spiritsight's scan, Glintmark's mark, and Drag Tide's fill-rate
## penalty, which needs the enemy gauge resync to read it.
const UNBUILT: Array = [
	["spirit", "crumble"],
	["spirit", "spiritsight"],
	["streetwise", "glintmark"],
	["ley_line", "drag_tide"],
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


func _boot(encounter: Array = ["ley_vermin"]) -> Node:
	PartyState.initialize_new_game()
	GameManager.transition_data = {
		"return_map_id": "test_overworld",
		"return_position": Vector2.ZERO,
		"is_boss": false,
		"formation_type": "normal",
		"encounter_group": encounter,
		"enemy_act": "act_i",
	}
	var battle: Node = BATTLE.instantiate()
	add_child(battle)
	_booted = battle
	return battle


func _await_prompt(battle: Node) -> bool:
	var prompted: Array[String] = []
	battle.turn_ready.connect(
		func(id: String, _p: bool, _s: int, _e: int, _b: bool, _c: Dictionary) -> void:
			prompted.append(id)
	)
	battle.get_atb().set_gauge("party_%d" % CASTER, ATBSystem.GAUGE_MAX)
	var fired: bool = await wait_for_signal(battle.turn_ready, PROMPT_TIMEOUT)
	if not fired or not "party_%d" % CASTER in prompted:
		fail_test("the battle never asked the caster for a command (asked: %s)" % str(prompted))
		return false
	return true


## A shipped spell, free to cast so the new-game party can afford it.
func _spell(tradition: String, spell_id: String) -> Dictionary:
	for entry: Variant in DataManager.load_spells(tradition):
		if String((entry as Dictionary).get("id", "")) == spell_id:
			var spell: Dictionary = (entry as Dictionary).duplicate(true)
			spell["mp_cost"] = 0
			return spell
	fail_test("%s is missing from %s.json" % [spell_id, tradition])
	return {}


## Every enemy's DEF, MDEF and MAG at BASE_STAT, its MDEF and SPD at 0 so the
## hit roll is the spell's rate alone. The data is copied first so the cached
## enemy table is left untouched.
func _pin_enemies(battle: Node) -> void:
	for enemy: Node in battle.get_enemies():
		var data: Dictionary = enemy.enemy_data.duplicate(true)
		data["def"] = BASE_STAT
		data["mag"] = BASE_STAT
		data["mdef"] = 0
		data["spd"] = 0
		enemy.enemy_data = data


## Wait for the caster's prompt, then cast [param spell] on enemy [param target].
func _cast(battle: Node, spell: Dictionary, target: int = 0) -> bool:
	if not await _await_prompt(battle):
		return false
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": target, "target_enemy": true}
	)
	return true


func _stat(enemy: Node, stat: String) -> int:
	return int(enemy.get_stats().get(stat, 0))


func _messages(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.message.connect(func(text: String) -> void: out.append(text))
	return out


func _markers(battle: Node) -> Array[String]:
	var out: Array[String] = []
	battle.damage_dealt.connect(
		func(tid: String, _amt: int, dt: String) -> void: out.append("%s:%s" % [tid, dt])
	)
	return out


# ── Stat debuffs ─────────────────────────────────────────────────────────


func test_debuff_spells_carry_their_magic_md_values() -> void:
	for row: Array in STAT_DEBUFFS:
		var spell: Dictionary = _spell("ley_line", row[0])
		var debuff: Variant = spell.get("stat_debuff")
		assert_true(debuff is Dictionary, "%s carries a stat_debuff" % row[0])
		if not debuff is Dictionary:
			continue
		assert_eq(String(debuff.get("stat", "")), row[1], "%s lowers %s" % [row[0], row[1]])
		assert_eq(int(debuff.get("pct", 0)), row[2], "%s by %d%%" % [row[0], row[2]])
		assert_eq(int(spell.get("duration", 0)), row[3], "%s for %d turns" % [row[0], row[3]])
		assert_eq(int(spell.get("hit_rate", 0)), row[4], "%s at %d%%" % [row[0], row[4]])


## Cast the STAT_DEBUFFS row for [param spell_id] at a sure hit and check the
## enemy's stat: down by the spell's percentage, still down one turn short of
## its duration, and back to normal when that duration runs out.
func _check_stat_debuff(spell_id: String) -> void:
	var row: Array = STAT_DEBUFFS.filter(func(r: Array) -> bool: return r[0] == spell_id)[0]
	var stat: String = row[1]
	var battle: Node = _boot()
	_pin_enemies(battle)
	var enemy: Node = battle.get_enemies()[0]
	var spell: Dictionary = _spell("ley_line", spell_id)
	spell["hit_rate"] = 100
	if not await _cast(battle, spell):
		return
	# The roll met MDEF 0; Fray's -30% is read off an MDEF it can lower.
	enemy.enemy_data[stat] = BASE_STAT
	var lowered: int = BASE_STAT * (100 - int(row[2])) / 100
	assert_eq(_stat(enemy, stat), lowered, "%s lowers %s to %d" % [spell_id, stat, lowered])
	for _turn: int in range(int(row[3]) - 1):
		enemy.tick_buffs()
	assert_eq(_stat(enemy, stat), lowered, "still lowered on the debuff's last turn")
	enemy.tick_buffs()
	assert_eq(_stat(enemy, stat), BASE_STAT, "and back to normal once its turns are up")


func test_sunder_lowers_an_enemy_s_def_30_percent_for_5_turns() -> void:
	await _check_stat_debuff("sunder")


func test_fray_lowers_an_enemy_s_mdef_30_percent_for_5_turns() -> void:
	await _check_stat_debuff("fray")


func test_dampening_field_lowers_an_enemy_s_mag_30_percent_for_5_turns() -> void:
	await _check_stat_debuff("dampening_field")


func test_a_missed_debuff_spends_its_mp_and_changes_nothing() -> void:
	var battle: Node = _boot()
	_pin_enemies(battle)
	var enemy: Node = battle.get_enemies()[0]
	var hp: int = enemy.current_hp
	var markers: Array[String] = _markers(battle)
	var spell: Dictionary = _spell("ley_line", "sunder")
	spell["hit_rate"] = 0
	spell["mp_cost"] = 7
	if not await _await_prompt(battle):
		return
	var state: Node = battle.get_battle_state()
	state.get_member(CASTER)["current_mp"] = 50
	battle.get_node("BattleUI").command_submitted.emit(
		{"type": "magic", "spell": spell, "target": 0, "target_enemy": true}
	)
	assert_eq(int(state.get_member(CASTER)["current_mp"]), 43, "Sunder's 7 MP is spent")
	assert_eq(_stat(enemy, "def"), BASE_STAT, "the enemy's DEF is untouched")
	assert_eq(enemy.current_hp, hp, "and it takes no damage")
	assert_has(markers, "enemy_0:miss", "the player sees a miss: %s" % str(markers))


func test_a_landed_debuff_deals_no_damage() -> void:
	var battle: Node = _boot()
	_pin_enemies(battle)
	var enemy: Node = battle.get_enemies()[0]
	var hp: int = enemy.current_hp
	var spell: Dictionary = _spell("ley_line", "sunder")
	spell["hit_rate"] = 100
	if not await _cast(battle, spell):
		return
	assert_eq(_stat(enemy, "def"), 70, "precondition: Sunder landed")
	assert_eq(enemy.current_hp, hp, "a debuff is not a 1-damage hit")


func test_sunder_and_an_enemy_def_buff_add_their_percentages() -> void:
	# combat-formulas.md § Buff & Debuff Interaction: "Stat buffs on the same
	# stat add, then floor once"; progression.md § Equipment and Buffs: debuffs
	# "work the same way in reverse". Guard Stance's +40% with Sunder's -30%.
	var battle: Node = _boot()
	_pin_enemies(battle)
	var enemy: Node = battle.get_enemies()[0]
	enemy.apply_buff("def", 1.4, 5)
	var spell: Dictionary = _spell("ley_line", "sunder")
	spell["hit_rate"] = 100
	if not await _cast(battle, spell):
		return
	assert_eq(_stat(enemy, "def"), 110, "+40% and -30% on DEF is +10%")
	enemy.apply_buff("def", 1.4, 5)
	assert_eq(_stat(enemy, "def"), 110, "a recast Guard Stance refreshes, leaving Sunder on")


# ── Dispersion ───────────────────────────────────────────────────────────


## Haste and Guard Stance's +40% DEF on [param enemy], plus a Sunder.
func _buff_and_sunder(enemy: Node) -> void:
	enemy.apply_status("haste", 5)
	enemy.apply_buff("def", 1.4, 5)
	enemy.apply_buff("def", 0.7, 5)
	assert_eq(_stat(enemy, "def"), 110, "precondition: the buff and Sunder are both on")


func test_dispersion_strips_an_enemy_s_haste_and_buffs() -> void:
	var battle: Node = _boot()
	_pin_enemies(battle)
	var enemy: Node = battle.get_enemies()[0]
	enemy.apply_status("haste", 5)
	enemy.apply_buff("atk", 1.3, 5)
	# No hit roll: the most evasive target there is still loses its buffs.
	enemy.enemy_data["mdef"] = 255
	enemy.enemy_data["spd"] = 320
	var atk: int = int(enemy.enemy_data.get("atk", 0))
	if not await _cast(battle, _spell("ley_line", "dispersion")):
		return
	assert_false(enemy.has_status("haste"), "Haste is stripped")
	assert_eq(_stat(enemy, "atk"), atk, "and the ATK buff with it")


func test_dispersion_leaves_the_party_s_debuffs_on_the_enemy() -> void:
	# magic.md § 68 removes "all positive status effects (buffs)", and the
	# Status Effect Reference footnote: "Player-side Dispersion removes enemy
	# buffs, not friendly ones."
	var battle: Node = _boot()
	_pin_enemies(battle)
	var enemy: Node = battle.get_enemies()[0]
	_buff_and_sunder(enemy)
	if not await _cast(battle, _spell("ley_line", "dispersion")):
		return
	assert_eq(_stat(enemy, "def"), 70, "Guard Stance is gone, Sunder stays")


func test_mass_dispersion_strips_every_enemy() -> void:
	var battle: Node = _boot(["ley_vermin", "ley_vermin", "ley_vermin"])
	_pin_enemies(battle)
	var enemies: Array[Node] = battle.get_enemies()
	assert_eq(enemies.size(), 3, "precondition: three enemies")
	for enemy: Node in enemies:
		_buff_and_sunder(enemy)
	if not await _cast(battle, _spell("ley_line", "mass_dispersion")):
		return
	for i: int in range(enemies.size()):
		assert_false(enemies[i].has_status("haste"), "enemy %d loses Haste" % i)
		assert_eq(_stat(enemies[i], "def"), 70, "enemy %d loses its buff, keeps Sunder" % i)


func test_dispersion_with_nothing_to_strip_is_cast_and_says_so() -> void:
	var battle: Node = _boot()
	_pin_enemies(battle)
	var said: Array[String] = _messages(battle)
	if not await _cast(battle, _spell("ley_line", "dispersion")):
		return
	assert_true(said.any(func(t: String) -> bool: return " casts Dispersion!" in t), str(said))
	assert_has(said, "No effect!", "nothing was there to remove: %s" % str(said))


# ── Unbuilt enemy-side spells ────────────────────────────────────────────


func test_unbuilt_enemy_spells_are_refused_before_mp() -> void:
	var battle: Node = _boot()
	var said: Array[String] = _messages(battle)
	if not await _await_prompt(battle):
		return
	var state: Node = battle.get_battle_state()
	state.get_member(CASTER)["current_mp"] = 50
	var hp: int = battle.get_enemies()[0].current_hp
	for pair: Array in UNBUILT:
		var spell: Dictionary = _spell(pair[0], pair[1])
		spell["mp_cost"] = 3
		battle.get_node("BattleUI").command_submitted.emit(
			{"type": "magic", "spell": spell, "target": 0, "target_enemy": true}
		)
		assert_eq(int(state.get_member(CASTER)["current_mp"]), 50, "%s spends no MP" % pair[1])
	var refusals: Array[String] = said.filter(func(t: String) -> bool: return t == "No effect!")
	assert_eq(refusals.size(), UNBUILT.size(), "each is refused out loud: %s" % str(said))
	assert_false(said.any(func(t: String) -> bool: return " casts " in t), "none is cast")
	assert_eq(battle.get_enemies()[0].current_hp, hp, "and none deals its 1 damage")


## The Magic submenu of [param character_id] at [param level] with MP to spare,
## its entries by spell id.
func _menu_spells(character_id: String, level: int) -> Dictionary:
	var m: Node = CommandMenu.new()
	add_child_autofree(m)
	m.show_commands({"character_id": character_id, "level": level}, false, {"current_mp": 999})
	m._cursor = 1  # Magic (Attack, Magic, Ability, Item, Defend, Flee)
	m._confirm_command()
	var by_id: Dictionary = {}
	for item: Dictionary in m._submenu_items:
		by_id[item.get("command", {}).get("spell", {}).get("id", "")] = item
	return by_id


func test_unbuilt_enemy_spells_are_grayed_in_the_magic_menu() -> void:
	var maren: Dictionary = _menu_spells("maren", 40)
	for id: String in ["crumble", "spiritsight", "drag_tide"]:
		assert_true(maren.has(id), "precondition: Maren knows %s" % id)
		assert_false(maren.get(id, {}).get("enabled", true), "%s is grayed" % id)
	var sable: Dictionary = _menu_spells("sable", 40)
	assert_true(sable.has("glintmark"), "precondition: Sable knows Glintmark")
	assert_false(sable.get("glintmark", {}).get("enabled", true), "Glintmark is grayed")


func test_built_enemy_debuffs_stay_selectable_in_the_magic_menu() -> void:
	var maren: Dictionary = _menu_spells("maren", 40)
	for id: String in ["sunder", "fray", "dampening_field", "dispersion", "mass_dispersion"]:
		assert_true(maren.has(id), "precondition: Maren knows %s" % id)
		assert_true(maren.get(id, {}).get("enabled", false), "%s can be cast" % id)
