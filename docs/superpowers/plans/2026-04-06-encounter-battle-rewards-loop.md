# Encounter → Battle → Rewards Loop Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the end-to-end random encounter gameplay loop: walk → danger counter → battle → XP/gold/drops → level-up → return to map.

**Architecture:** Static `EncounterSystem` helper owned by exploration for danger/encounter logic. Small BattleManager change to pass drops in transition data. New XP/level-up statics in `inventory_helpers.gd`. Thin wrappers in `PartyState`.

**Tech Stack:** Godot 4.6, GDScript, GUT test framework

**Spec:** `docs/superpowers/specs/2026-04-06-encounter-battle-rewards-loop-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/combat/encounter_system.gd` | CREATE | Static helpers: danger check, increment, group select, formation roll, accessory mod |
| `game/tests/test_encounter_system.gd` | CREATE | Unit tests for all EncounterSystem static methods |
| `game/scripts/combat/battle_manager.gd` | MODIFY (lines 28, 352, 362-372) | Add `_earned_drops`, store in victory, include in exit transition |
| `game/scripts/autoload/inventory_helpers.gd` | MODIFY (after line 175) | Add `add_xp_to_member()`, `distribute_rewards()` statics |
| `game/tests/test_battle_rewards.gd` | CREATE | Unit tests for XP distribution and level-up logic |
| `game/scripts/autoload/party_state.gd` | MODIFY (after line 125) | Add `get_reserve_party()`, `distribute_battle_rewards()` |
| `game/scripts/core/exploration.gd` | MODIFY (lines 7-17, 38-48, 51+, 111+) | Add danger counter, step detection, battle entry/return |

---

## Chunk 1: EncounterSystem Static Helper + Tests

### Task 1: Create EncounterSystem with check_encounter()

**Files:**
- Create: `game/scripts/combat/encounter_system.gd`
- Create: `game/tests/test_encounter_system.gd`

- [ ] **Step 1: Write the failing test for check_encounter()**

```gdscript
# game/tests/test_encounter_system.gd
extends GutTest
## Tests for EncounterSystem static helpers.

const ES = preload("res://scripts/combat/encounter_system.gd")


func test_check_encounter_zero_counter_never_triggers() -> void:
	# With counter 0, floor(0/256) = 0, roll is 0-255, never < 0
	var triggered: bool = false
	for i: int in range(100):
		if ES.check_encounter(0):
			triggered = true
	assert_false(triggered, "zero counter should never trigger")


func test_check_encounter_high_counter_always_triggers() -> void:
	# With counter 65536, floor(65536/256) = 256, roll 0-255 always < 256
	var triggered: bool = true
	for i: int in range(100):
		if not ES.check_encounter(65536):
			triggered = false
	assert_true(triggered, "very high counter should always trigger")


func test_check_encounter_returns_bool() -> void:
	var result: bool = ES.check_encounter(1000)
	assert_typeof(result, TYPE_BOOL, "should return bool")
```

- [ ] **Step 2: Create minimal encounter_system.gd to make tests pass**

```gdscript
# game/scripts/combat/encounter_system.gd
extends RefCounted
## Static helpers for random encounter logic.
## Danger counter, encounter checks, group selection, formation rolls.
## Source: combat-formulas.md § Danger Counter, § Battle Formations.


## Check if an encounter triggers this step.
## Returns true if random roll < floor(danger_counter / 256).
static func check_encounter(danger_counter: int) -> bool:
	if danger_counter <= 0:
		return false
	var threshold: int = danger_counter / 256
	return randi_range(0, 255) < threshold
```

- [ ] **Step 3: Run tests, verify pass**

Run: `godot --headless --path game/ -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_encounter_system.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/encounter_system.gd game/tests/test_encounter_system.gd
git commit -m "feat(engine): add EncounterSystem.check_encounter() with tests"
```

### Task 2: Add roll_increment() and select_encounter_group()

**Files:**
- Modify: `game/scripts/combat/encounter_system.gd`
- Modify: `game/tests/test_encounter_system.gd`

- [ ] **Step 1: Write failing tests**

Add to `test_encounter_system.gd`:

```gdscript
func test_roll_increment_basic() -> void:
	# floor(120 * 1.0 * 1.0) = 120
	var result: int = ES.roll_increment(120, 1.0, 1.0)
	assert_eq(result, 120, "basic increment should be base value")


func test_roll_increment_with_modifiers() -> void:
	# floor(120 * 1.1 * 0.5) = floor(66.0) = 66
	var result: int = ES.roll_increment(120, 1.1, 0.5)
	assert_eq(result, 66, "modifiers should scale increment")


func test_roll_increment_zero_base() -> void:
	var result: int = ES.roll_increment(0, 1.0, 1.0)
	assert_eq(result, 0, "zero base should produce zero")


func test_select_encounter_group_returns_dict() -> void:
	var groups: Array = [
		{"enemies": ["ley_vermin"], "weight": 50.0},
		{"enemies": ["unstable_crystal"], "weight": 50.0},
	]
	var result: Dictionary = ES.select_encounter_group(groups)
	assert_has(result, "enemies", "result should have enemies key")


func test_select_encounter_group_empty_returns_empty() -> void:
	var result: Dictionary = ES.select_encounter_group([])
	assert_true(result.is_empty(), "empty groups should return empty dict")


func test_select_encounter_group_single_always_returns_it() -> void:
	var groups: Array = [{"enemies": ["ley_vermin"], "weight": 100.0}]
	for i: int in range(20):
		var result: Dictionary = ES.select_encounter_group(groups)
		assert_eq(result.get("enemies", []), ["ley_vermin"], "single group always selected")
```

- [ ] **Step 2: Implement roll_increment() and select_encounter_group()**

Add to `encounter_system.gd`:

```gdscript
## Calculate danger increment for one step.
## final = floor(base_increment * act_scale * accessory_mod).
static func roll_increment(
	base_increment: int, act_scale: float, accessory_mod: float
) -> int:
	return int(float(base_increment) * act_scale * accessory_mod)


## Select an encounter group via weighted random from groups array.
## Each group dict has a "weight" field. Returns selected group or {}.
static func select_encounter_group(groups: Array) -> Dictionary:
	if groups.is_empty():
		return {}
	var total_weight: float = 0.0
	for g: Variant in groups:
		if g is Dictionary:
			total_weight += float((g as Dictionary).get("weight", 0.0))
	if total_weight <= 0.0:
		return groups[0] if groups[0] is Dictionary else {}
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for g: Variant in groups:
		if g is Dictionary:
			cumulative += float((g as Dictionary).get("weight", 0.0))
			if roll <= cumulative:
				return g as Dictionary
	# Fallback (float rounding)
	return groups[groups.size() - 1] if groups[groups.size() - 1] is Dictionary else {}
```

- [ ] **Step 3: Run tests, verify pass**

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/encounter_system.gd game/tests/test_encounter_system.gd
git commit -m "feat(engine): add roll_increment and select_encounter_group"
```

### Task 3: Add roll_formation() and get_accessory_modifier()

**Files:**
- Modify: `game/scripts/combat/encounter_system.gd`
- Modify: `game/tests/test_encounter_system.gd`

- [ ] **Step 1: Write failing tests**

Add to `test_encounter_system.gd`:

```gdscript
func test_roll_formation_returns_valid_string() -> void:
	var rates: Dictionary = {"normal": 75.0, "back_attack": 12.5, "preemptive": 12.5}
	var result: String = ES.roll_formation(rates)
	assert_true(
		result in ["normal", "back_attack", "preemptive"],
		"should return valid formation type",
	)


func test_roll_formation_all_normal() -> void:
	var rates: Dictionary = {"normal": 100.0, "back_attack": 0.0, "preemptive": 0.0}
	for i: int in range(20):
		assert_eq(ES.roll_formation(rates), "normal", "100% normal should always be normal")


func test_roll_formation_empty_defaults_normal() -> void:
	assert_eq(ES.roll_formation({}), "normal", "empty rates should default to normal")


func test_get_accessory_modifier_no_equipment() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {}},
	]
	assert_eq(ES.get_accessory_modifier(party), 1.0, "no modifier items = 1.0")


func test_get_accessory_modifier_ward_talisman() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "ward_talisman"}},
	]
	assert_almost_eq(
		ES.get_accessory_modifier(party), 0.5, 0.01, "ward talisman = 0.5"
	)


func test_get_accessory_modifier_lure_talisman() -> void:
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "lure_talisman"}},
	]
	assert_almost_eq(
		ES.get_accessory_modifier(party), 2.0, 0.01, "lure talisman = 2.0"
	)


func test_get_accessory_modifier_ward_and_lure_stack() -> void:
	# Two members: one with ward, one with lure => 0.5 * 2.0 = 1.0
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "ward_talisman"}},
		{"character_id": "cael", "equipment": {"accessory": "lure_talisman"}},
	]
	assert_almost_eq(
		ES.get_accessory_modifier(party), 1.0, 0.01, "ward + lure = 1.0"
	)


func test_get_accessory_modifier_ward_and_cloak_dont_stack() -> void:
	# Ward and Infiltrator's Cloak don't stack (same effect)
	var party: Array[Dictionary] = [
		{"character_id": "edren", "equipment": {"accessory": "ward_talisman"}},
		{"character_id": "cael", "equipment": {"accessory": "infiltrators_cloak"}},
	]
	assert_almost_eq(
		ES.get_accessory_modifier(party), 0.5, 0.01,
		"ward + cloak should not stack below 0.5",
	)
```

- [ ] **Step 2: Implement roll_formation() and get_accessory_modifier()**

Add to `encounter_system.gd`:

```gdscript
## Item IDs that reduce encounter rate (×0.5 each, don't stack with each other).
const REDUCE_ITEMS: Array[String] = ["ward_talisman", "infiltrators_cloak"]
## Item ID that increases encounter rate (×2.0).
const LURE_ITEM: String = "lure_talisman"


## Roll formation type from rates dict.
## Returns "normal", "back_attack", or "preemptive".
static func roll_formation(formation_rates: Dictionary) -> String:
	var preemptive: float = float(formation_rates.get("preemptive", 0.0))
	var back_attack: float = float(formation_rates.get("back_attack", 0.0))
	var roll: float = randf() * 100.0
	if roll < preemptive:
		return "preemptive"
	if roll < preemptive + back_attack:
		return "back_attack"
	return "normal"


## Calculate encounter rate modifier from active party equipment.
## Ward Talisman/Infiltrator's Cloak: ×0.5 (don't stack with each other).
## Lure Talisman: ×2.0. All stack multiplicatively.
static func get_accessory_modifier(party: Array[Dictionary]) -> float:
	var has_reduce: bool = false
	var has_lure: bool = false
	for member: Dictionary in party:
		var equip: Dictionary = member.get("equipment", {})
		for slot: String in ["accessory", "crystal"]:
			var item_id: String = equip.get(slot, "")
			if item_id in REDUCE_ITEMS:
				has_reduce = true
			if item_id == LURE_ITEM:
				has_lure = true
	var mod: float = 1.0
	if has_reduce:
		mod *= 0.5
	if has_lure:
		mod *= 2.0
	return mod
```

- [ ] **Step 3: Run tests, verify pass**

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/encounter_system.gd game/tests/test_encounter_system.gd
git commit -m "feat(engine): add roll_formation and get_accessory_modifier"
```

---

## Chunk 2: BattleManager Drops + XP/Rewards in Helpers

### Task 4: Add _earned_drops to BattleManager transition data

**Files:**
- Modify: `game/scripts/combat/battle_manager.gd:28,342-352,362-372`

- [ ] **Step 1: Add instance variable**

After line 28 (`var _earned_gold: int`), add:

```gdscript
var _earned_drops: Array[Dictionary] = []
```

- [ ] **Step 2: Store drops in _handle_victory()**

At line 352 in `_handle_victory()`, the local `drops` array is already
built and emitted. Add one line after the loop to store it on the instance:

```gdscript
# After: drops.append({"item_id": drop.get("item_id", "")})
# After the for loop, before the emit, add:
	_earned_drops = drops
	victory.emit({"xp": _earned_xp, "gold": _earned_gold, "drops": _earned_drops})
```

Only the last 2 lines change — replace the existing `victory.emit(...)` line.

- [ ] **Step 3: Include drops in _exit_battle() transition data**

In `_exit_battle()` (lines 362-372), add `"earned_drops": _earned_drops`
to the transition dict (after `"earned_gold"` line 370) and reset after use:

```gdscript
func _exit_battle(result: String) -> void:
	_battle_active = false
	_awaiting_input_for = ""
	var transition: Dictionary = {
		"result": result,
		"map_id": _return_map_id,
		"position": _return_position,
		"earned_xp": _earned_xp,
		"earned_gold": _earned_gold,
		"earned_drops": _earned_drops,
	}
	_earned_drops = []
	GameManager.change_core_state(GameManager.CoreState.EXPLORATION, transition)
```

- [ ] **Step 4: Commit**

```bash
git add game/scripts/combat/battle_manager.gd
git commit -m "feat(engine): include earned_drops in battle exit transition data"
```

### Task 5: Add add_xp_to_member() and distribute_rewards() to inventory_helpers.gd

**Files:**
- Modify: `game/scripts/autoload/inventory_helpers.gd` (after line 175, before `build_save_dict`)
- Create: `game/tests/test_battle_rewards.gd`

- [ ] **Step 1: Write failing tests**

```gdscript
# game/tests/test_battle_rewards.gd
extends GutTest
## Tests for XP distribution and level-up logic.

const Helpers = preload("res://scripts/autoload/inventory_helpers.gd")


func _make_member(id: String, level: int, xp: int, hp: int) -> Dictionary:
	return {
		"character_id": id,
		"level": level,
		"current_xp": xp,
		"xp_to_next": 24,
		"current_hp": hp,
		"max_hp": 95,
		"max_mp": 15,
		"atk": 18, "def": 16, "mag": 6, "mdef": 8, "spd": 10, "lck": 8,
	}


func test_add_xp_no_level_up() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	var result: Dictionary = Helpers.add_xp_to_member(member, 10)
	assert_false(result.get("leveled_up", true), "10 XP should not level up from 1")
	assert_eq(member.get("current_xp", 0), 10, "XP should be stored")
	assert_eq(member.get("level", 0), 1, "level should stay 1")


func test_add_xp_level_up() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	# XP to next level at 1 = floor(24 * 1^1.5) = 24
	var result: Dictionary = Helpers.add_xp_to_member(member, 30)
	assert_true(result.get("leveled_up", false), "30 XP should level up from 1")
	assert_eq(result.get("new_level", 0), 2, "should be level 2")
	assert_eq(member.get("level", 0), 2, "member dict should be updated")
	assert_eq(member.get("current_xp", -1), 6, "leftover XP should be 30 - 24 = 6")


func test_add_xp_multiple_levels() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	# Level 1→2: 24 XP, Level 2→3: floor(24 * 2^1.5) = floor(67.88) = 67
	# Total for 2 levels: 24 + 67 = 91
	var result: Dictionary = Helpers.add_xp_to_member(member, 100)
	assert_eq(result.get("new_level", 0), 3, "should reach level 3")
	assert_eq(member.get("current_xp", -1), 9, "leftover XP should be 100 - 91 = 9")


func test_add_xp_at_cap() -> void:
	var member: Dictionary = _make_member("edren", 150, 0, 95)
	var result: Dictionary = Helpers.add_xp_to_member(member, 9999)
	assert_false(result.get("leveled_up", true), "should not level past 150")
	assert_eq(member.get("level", 0), 150, "level should stay 150")


func test_add_xp_recalculates_stats() -> void:
	var member: Dictionary = _make_member("edren", 1, 0, 95)
	var old_max_hp: int = member.get("max_hp", 0)
	Helpers.add_xp_to_member(member, 30)  # Level 1→2
	assert_gt(member.get("max_hp", 0), old_max_hp, "max_hp should increase on level up")


func test_distribute_rewards_alive_get_full_xp() -> void:
	var active: Array[Dictionary] = [
		_make_member("edren", 1, 0, 50),
		_make_member("cael", 1, 0, 40),
	]
	var reserve: Array[Dictionary] = []
	var rewards: Dictionary = {"xp": 24, "gold": 100, "drops": []}
	var result: Dictionary = Helpers.distribute_rewards(rewards, active, reserve)
	# Both alive, both get full 24 XP => both level up
	assert_eq(result.get("level_ups", []).size(), 2, "both should level up")


func test_distribute_rewards_ko_gets_zero() -> void:
	var active: Array[Dictionary] = [
		_make_member("edren", 1, 0, 50),  # alive
		_make_member("cael", 1, 0, 0),  # KO'd
	]
	var reserve: Array[Dictionary] = []
	var rewards: Dictionary = {"xp": 24, "gold": 100, "drops": []}
	Helpers.distribute_rewards(rewards, active, reserve)
	assert_eq(active[0].get("level", 0), 2, "alive member should level up")
	assert_eq(active[1].get("level", 0), 1, "KO'd member should stay level 1")


func test_distribute_rewards_reserve_gets_half() -> void:
	var active: Array[Dictionary] = [_make_member("edren", 1, 0, 50)]
	var reserve: Array[Dictionary] = [_make_member("cael", 1, 0, 40)]
	# 24 XP: active gets 24 (levels up), reserve gets 12 (no level up)
	var rewards: Dictionary = {"xp": 24, "gold": 100, "drops": []}
	Helpers.distribute_rewards(rewards, active, reserve)
	assert_eq(active[0].get("level", 0), 2, "active should level up with 24 XP")
	assert_eq(reserve[0].get("level", 0), 1, "reserve should not level up with 12 XP")
	assert_eq(reserve[0].get("current_xp", 0), 12, "reserve should have 12 XP stored")
```

- [ ] **Step 2: Implement add_xp_to_member() and distribute_rewards()**

Add to `inventory_helpers.gd` after `xp_to_next_level()` (after line 175):

```gdscript
## Add XP to a party member, processing any level-ups.
## Recalculates stats on level-up using character JSON data.
## Returns {leveled_up: bool, old_level: int, new_level: int}.
## Source: progression.md § XP Distribution, § Two-Phase XP Curve.
static func add_xp_to_member(member: Dictionary, amount: int) -> Dictionary:
	var level: int = member.get("level", 1)
	var xp: int = member.get("current_xp", 0) + amount
	var old_level: int = level
	while level < 150:
		var needed: int = xp_to_next_level(level)
		if needed <= 0 or xp < needed:
			break
		xp -= needed
		level += 1
	member["current_xp"] = xp
	member["level"] = level
	member["xp_to_next"] = xp_to_next_level(level)
	if level > old_level:
		var char_data: Dictionary = DataManager.load_character(
			member.get("character_id", "")
		)
		var base: Dictionary = char_data.get("base_stats", {})
		var growth: Dictionary = char_data.get("growth", {})
		var new_stats: Dictionary = calculate_stats_at_level(base, growth, level)
		member["max_hp"] = new_stats.get("hp", member.get("max_hp", 1))
		member["max_mp"] = new_stats.get("mp", member.get("max_mp", 0))
		for stat_key: String in ["atk", "def", "mag", "mdef", "spd", "lck"]:
			member[stat_key] = new_stats.get(stat_key, member.get(stat_key, 0))
	return {"leveled_up": level > old_level, "old_level": old_level, "new_level": level}


## Distribute battle rewards across active and reserve party.
## Active alive: full XP. KO'd: 0 XP. Reserve: 50% XP.
## Returns {level_ups: Array, gold_gained: int, items_gained: Array}.
## Source: progression.md § XP Distribution Rules.
static func distribute_rewards(
	rewards: Dictionary,
	active_party: Array[Dictionary],
	reserve_party: Array[Dictionary],
) -> Dictionary:
	var level_ups: Array[Dictionary] = []
	var xp_amount: int = rewards.get("xp", 0)
	var drops: Array = rewards.get("drops", [])
	# Active party: full XP if alive, 0 if KO'd
	for member: Dictionary in active_party:
		if member.get("current_hp", 0) > 0:
			var result: Dictionary = add_xp_to_member(member, xp_amount)
			if result.get("leveled_up", false):
				level_ups.append({
					"character_id": member.get("character_id", ""),
					"old_level": result.get("old_level", 0),
					"new_level": result.get("new_level", 0),
				})
	# Reserve party: 50% XP
	for member: Dictionary in reserve_party:
		var result: Dictionary = add_xp_to_member(member, xp_amount / 2)
		if result.get("leveled_up", false):
			level_ups.append({
				"character_id": member.get("character_id", ""),
				"old_level": result.get("old_level", 0),
				"new_level": result.get("new_level", 0),
			})
	return {
		"level_ups": level_ups,
		"gold_gained": rewards.get("gold", 0),
		"items_gained": drops,
	}
```

- [ ] **Step 3: Run tests, verify pass**

Run: `godot --headless --path game/ -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_rewards.gd -gexit`

- [ ] **Step 4: Commit**

```bash
git add game/scripts/autoload/inventory_helpers.gd game/tests/test_battle_rewards.gd
git commit -m "feat(engine): add XP distribution and level-up processing"
```

---

## Chunk 3: PartyState Wrappers + Exploration Wiring

### Task 6: Add get_reserve_party() and distribute_battle_rewards() to PartyState

**Files:**
- Modify: `game/scripts/autoload/party_state.gd` (after `get_active_party()` at line 125)

- [ ] **Step 1: Add get_reserve_party()**

Add after `get_active_party()`:

```gdscript
## Get reserve (non-active) party members.
func get_reserve_party() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var active_indices: Array = formation.get("active", [])
	for i: int in range(members.size()):
		if i not in active_indices:
			result.append(members[i])
	return result
```

- [ ] **Step 2: Add distribute_battle_rewards()**

Add after `get_reserve_party()`:

```gdscript
## Apply battle rewards: XP to party, gold, item drops.
## Returns summary dict from Helpers.distribute_rewards().
func distribute_battle_rewards(rewards: Dictionary) -> Dictionary:
	var active: Array[Dictionary] = get_active_party()
	var reserve: Array[Dictionary] = get_reserve_party()
	var result: Dictionary = Helpers.distribute_rewards(rewards, active, reserve)
	add_gold(rewards.get("gold", 0))
	for drop: Variant in rewards.get("drops", []):
		if drop is Dictionary:
			add_item((drop as Dictionary).get("item_id", ""), 1)
	return result
```

- [ ] **Step 3: Check line count**

Run: `wc -l game/scripts/autoload/party_state.gd`

If over 400 lines, move the body of `get_reserve_party()` into
`inventory_helpers.gd` as a static and keep a thin wrapper.

- [ ] **Step 4: Commit**

```bash
git add game/scripts/autoload/party_state.gd
git commit -m "feat(engine): add get_reserve_party and distribute_battle_rewards"
```

### Task 7: Wire danger counter and encounter trigger into exploration

**Files:**
- Modify: `game/scripts/core/exploration.gd`

- [ ] **Step 1: Add imports and state variables**

After line 9 (`const FADE_DURATION`), add:

```gdscript
const EncounterSystem = preload("res://scripts/combat/encounter_system.gd")
```

After line 17 (`var _transition_tween: Tween`), add:

```gdscript
var _danger_counter: int = 0
var _last_player_tile: Vector2i = Vector2i(-999, -999)
var _encounter_config: Dictionary = {}
```

- [ ] **Step 2: Add _physics_process for step detection**

Add new method (before `_unhandled_input`):

```gdscript
func _physics_process(_delta: float) -> void:
	if _player == null or _transitioning:
		return
	var current_tile: Vector2i = Vector2i(_player.position) / 16
	if current_tile == _last_player_tile:
		return
	_last_player_tile = current_tile
	_process_encounter_step()
```

- [ ] **Step 3: Add _process_encounter_step()**

```gdscript
func _process_encounter_step() -> void:
	if _encounter_config.is_empty():
		return
	var base: int = _encounter_config.get("danger_increment", 0)
	if base <= 0:
		return
	var act_scale: float = 1.0
	var acc_mod: float = EncounterSystem.get_accessory_modifier(
		PartyState.get_active_party()
	)
	_danger_counter += EncounterSystem.roll_increment(base, act_scale, acc_mod)
	if EncounterSystem.check_encounter(_danger_counter):
		_trigger_random_encounter()
```

- [ ] **Step 4: Add _trigger_random_encounter()**

```gdscript
func _trigger_random_encounter() -> void:
	if _transitioning:
		return
	var groups: Array = _encounter_config.get("groups", [])
	if groups.is_empty():
		return
	var group: Dictionary = EncounterSystem.select_encounter_group(groups)
	var rates: Dictionary = _encounter_config.get("formation_rates", {})
	var formation: String = EncounterSystem.roll_formation(rates)
	_danger_counter = 0
	_transitioning = true
	var transition: Dictionary = {
		"encounter_group": group.get("enemies", []),
		"formation_type": formation,
		"return_map_id": _current_map_id,
		"return_position": _player.position,
		"enemy_act": "act_i",
		"encounter_source": "random",
	}
	GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)
```

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): wire danger counter and encounter trigger in exploration"
```

### Task 8: Wire battle return handling in exploration

**Files:**
- Modify: `game/scripts/core/exploration.gd` (in `_initialize_from_transition_data`)

- [ ] **Step 1: Modify existing battle return branch**

In `_initialize_from_transition_data()`, the `elif data.has("result")`
branch already exists at line 126. Replace lines 126-132 with expanded
handling that adds reward distribution:

```gdscript
	elif data.has("result"):
		# Return from battle — apply rewards, restore map and position
		var result: String = data.get("result", "")
		match result:
			"victory":
				var rewards: Dictionary = {
					"xp": data.get("earned_xp", 0),
					"gold": data.get("earned_gold", 0),
					"drops": data.get("earned_drops", []),
				}
				PartyState.distribute_battle_rewards(rewards)
			"faint":
				SaveManager.faint_and_fast_reload()
				return
			"flee":
				pass
		_danger_counter = 0
		var map_id: String = data.get("map_id", "test_room")
		load_map(map_id)
		var pos: Vector2 = data.get("position", Vector2(80, 90))
		if _player != null:
			_player.position = pos
```

- [ ] **Step 2: Load encounter config in map loading**

In the map loading method, after the map scene is loaded and before
the player is placed, add encounter config loading:

```gdscript
_encounter_config = {}
_danger_counter = 0
var encounters: Dictionary = DataManager.load_encounters(_current_map_id)
if not encounters.is_empty():
	var floors: Array = encounters.get("floors", [])
	if floors.size() > 0 and floors[0] is Dictionary:
		_encounter_config = floors[0]
```

Note: Uses first floor as default. Floor selection by metadata is
deferred to gap 4.1 when real dungeon maps exist with floor IDs.

- [ ] **Step 3: Reset danger counter on map transition**

In the map transition method, add before the transition starts:

```gdscript
_danger_counter = 0
```

- [ ] **Step 4: Check line count**

Run: `wc -l game/scripts/core/exploration.gd`

Must be under 400 lines. Currently ~292 + ~50 new = ~342.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): wire battle return handling and encounter config loading"
```

### Task 9: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update gap 3.2 (Exploration)**

Mark the deferred encounter items as complete:
- [x] Danger counter system
- [x] Random encounter trigger
- [x] Menu button (already wired in PR #122)

- [ ] **Step 2: Update gap 3.3 (Battle)**

Note that battle exit now includes drops in transition data.

- [ ] **Step 3: Add progress tracking entry**

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap tracker — encounter loop wired"
```

---

## Execution Order

Tasks 1-3 are independent from Tasks 4-5 (encounter system vs rewards).
Task 6 depends on Task 5 (PartyState wraps helpers).
Tasks 7-8 depend on Tasks 1-3 and 6 (exploration uses everything).
Task 9 is last (tracker update).

**Parallelizable:** Tasks 1-3 and Tasks 4-5 can run in parallel.
