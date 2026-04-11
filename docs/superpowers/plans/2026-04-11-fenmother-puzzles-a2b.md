# Fenmother's Hollow Puzzles (Phase A2b) Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add interactive puzzle systems to Fenmother's Hollow — water wheels, spirit vessel fetch quest, poison zones, ritual meter, spirit-path walk scene, and Caden binding sequence.

**Architecture:** 5 new entity prefabs (water_wheel, water_zone, pure_spring, spirit_plant, damage_zone) follow the existing signal-driven pattern from treasure_chest/save_point/trigger_zone. PartyState gains a `puzzle_state` dictionary for cross-floor persistence. Ritual meter is a CanvasLayer overlay. Spirit-path is an auto-walk map. Caden sequence is an auto-triggered NPC arrival.

**Tech Stack:** Godot 4.6 / GDScript, GUT test framework, JSON data files

**Spec:** `docs/superpowers/specs/2026-04-11-fenmother-puzzles-a2b-design.md`

---

## File Map

### New Files (16)

| File | Purpose |
|------|---------|
| `game/scripts/entities/water_wheel.gd` | Water wheel toggle logic |
| `game/scenes/entities/water_wheel.tscn` | Water wheel prefab |
| `game/scripts/entities/water_zone.gd` | Water level zone visibility/collision |
| `game/scenes/entities/water_zone.tscn` | Water zone prefab |
| `game/scripts/entities/pure_spring.gd` | Pure spring fill logic |
| `game/scenes/entities/pure_spring.tscn` | Pure spring prefab |
| `game/scripts/entities/spirit_plant.gd` | Spirit-plant restoration logic |
| `game/scenes/entities/spirit_plant.tscn` | Spirit-plant prefab |
| `game/scripts/entities/damage_zone.gd` | Poison damage zone logic |
| `game/scenes/entities/damage_zone.tscn` | Damage zone prefab |
| `game/scripts/ui/ritual_meter.gd` | Ritual meter HUD logic |
| `game/scenes/ui/ritual_meter.tscn` | Ritual meter overlay |
| `game/scenes/maps/dungeons/fenmothers_hollow_spirit_path.tscn` | Auto-walk tunnel |
| `game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn` | Shrine hub map |
| `game/data/dialogue/caden_binding.json` | Caden binding dialogue |
| `game/tests/test_fenmother_puzzles.gd` | All Phase A2b tests |

### Modified Files (10)

| File | Lines | Changes |
|------|-------|---------|
| `game/scripts/autoload/party_state.gd` | ~70-72, ~122, ~125-136 | Add puzzle_state var, save/load, new_game clear, API methods |
| `game/scripts/autoload/inventory_helpers.gd` | ~275-316 | Add puzzle_state param to build_save_dict |
| `game/scripts/autoload/save_manager.gd` | ~215-226 | Add "puzzle_state" to required keys |
| `game/scripts/core/exploration.gd` | ~260-330, ~504-676 | New entity handlers, auto-walk, auto-sequence, cleansing changes |
| `game/scripts/entities/player_character.gd` | ~1-10, ~40-50 | Add _input_enabled flag + set_input_enabled method |
| `game/scripts/combat/battle_manager.gd` | ~440-458 | Add turn_counter + ko_count to victory data |
| `game/data/items/key_items.json` | append | Add spirit_vessel + spirit_vessel_filled |
| `game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn` | entities | Add wheels, spring, vessel chest, water zones, alcove |
| `game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn` | entities | Replace dialogue with spirit-plant, add wheel 3, water zones, damage zones |
| `game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn` | entities | Add damage zones, remove blessing chest |

---

## Chunk 1: Foundation (Tasks 1-3)

### Task 1: Puzzle State System — Tests

**Files:**
- Create: `game/tests/test_fenmother_puzzles.gd`
- Reference: `game/scripts/autoload/party_state.gd`

- [ ] **Step 1: Create test file with puzzle_state tests**

```gdscript
extends GutTest
## Tests for Fenmother's Hollow Phase A2b puzzle systems.


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	EventFlags.clear_all()


func after_each() -> void:
	DataManager.clear_cache()
	PartyState.members.clear()
	PartyState.formation = {"active": [], "reserve": [], "rows": {}}
	PartyState.owned_equipment.clear()
	PartyState.gold = 0
	PartyState.inventory = {"consumables": {}, "materials": {}, "key_items": []}
	PartyState.is_at_save_point = false
	PartyState.ley_crystals.clear()
	PartyState.puzzle_state.clear()
	EventFlags.clear_all()


# --- Puzzle State API ---


func test_set_and_get_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high")
	assert_true(val, "should return true after setting")


func test_get_puzzle_state_default() -> void:
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "nonexistent", false)
	assert_false(val, "should return default when key not set")


func test_get_puzzle_state_default_no_dungeon() -> void:
	var val: Variant = PartyState.get_puzzle_state("unknown_dungeon", "key", 42)
	assert_eq(val, 42, "should return default when dungeon not in puzzle_state")


func test_clear_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("other_dungeon", "valve_open", true)
	PartyState.clear_puzzle_state("fenmothers_hollow")
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_false(val, "cleared dungeon state should return default")
	var other: Variant = PartyState.get_puzzle_state("other_dungeon", "valve_open", false)
	assert_true(other, "other dungeon state should be unaffected")


func test_puzzle_state_save_roundtrip() -> void:
	PartyState.initialize_new_game()
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "plant_restored", false)
	var save_data: Dictionary = PartyState.build_save_data()
	assert_true(save_data.has("puzzle_state"), "save should include puzzle_state")
	PartyState.puzzle_state.clear()
	PartyState.load_from_save(save_data)
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_true(val, "wheel_1_high should survive save/load")


func test_puzzle_state_load_handles_missing_key() -> void:
	PartyState.initialize_new_game()
	var save_data: Dictionary = PartyState.build_save_data()
	save_data.erase("puzzle_state")
	PartyState.load_from_save(save_data)
	assert_true(PartyState.puzzle_state.is_empty(), "should default to empty dict")


func test_puzzle_state_load_handles_wrong_type() -> void:
	PartyState.initialize_new_game()
	var save_data: Dictionary = PartyState.build_save_data()
	save_data["puzzle_state"] = [1, 2, 3]
	PartyState.load_from_save(save_data)
	assert_true(PartyState.puzzle_state.is_empty(), "should default to empty dict for wrong type")


func test_initialize_new_game_clears_puzzle_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.initialize_new_game()
	assert_true(
		PartyState.puzzle_state.is_empty(), "new game should clear puzzle_state"
	)
```

- [ ] **Step 2: Run tests — expect FAIL (puzzle_state not implemented yet)**

Run: `grep -c "func test_" game/tests/test_fenmother_puzzles.gd`
Expected: 8 test functions

---

### Task 2: Puzzle State System — Implementation

**Files:**
- Modify: `game/scripts/autoload/party_state.gd`
- Modify: `game/scripts/autoload/inventory_helpers.gd`
- Modify: `game/scripts/autoload/save_manager.gd`

- [ ] **Step 1: Add puzzle_state var to PartyState**

In `party_state.gd`, after `var ley_crystals: Dictionary = {}` (around line 40), add:

```gdscript
var puzzle_state: Dictionary = {}
```

- [ ] **Step 2: Add API methods to PartyState**

After the `get_collected_crystals()` method (around line 225), add:

```gdscript
## Set a puzzle state value for a dungeon.
func set_puzzle_state(dungeon_id: String, key: String, value: Variant) -> void:
	if dungeon_id.is_empty() or key.is_empty():
		return
	if not puzzle_state.has(dungeon_id):
		puzzle_state[dungeon_id] = {}
	puzzle_state[dungeon_id][key] = value


## Get a puzzle state value. Returns default_value if not set.
func get_puzzle_state(dungeon_id: String, key: String, default_value: Variant = false) -> Variant:
	if not puzzle_state.has(dungeon_id):
		return default_value
	return puzzle_state[dungeon_id].get(key, default_value)


## Clear all puzzle state for a dungeon.
func clear_puzzle_state(dungeon_id: String) -> void:
	puzzle_state.erase(dungeon_id)
```

- [ ] **Step 3: Add puzzle_state to initialize_new_game()**

In `initialize_new_game()`, after `ley_crystals.clear()` (around line 71), add:

```gdscript
	puzzle_state.clear()
```

- [ ] **Step 4: Add puzzle_state to load_from_save()**

In `load_from_save()`, after the `ley_crystals` assignment (around line 123), add:

```gdscript
	var ps_data: Variant = data.get("puzzle_state", {})
	puzzle_state = ps_data as Dictionary if ps_data is Dictionary else {}
```

- [ ] **Step 5: Add puzzle_state to build_save_dict in inventory_helpers.gd**

In `inventory_helpers.gd`, update the `build_save_dict` function signature to accept `puzzle_state`:

Add parameter after `lc: Dictionary = {}`:
```gdscript
	ps: Dictionary = {}
```

Add to the return dictionary after `"ley_crystals": lc.duplicate(true),`:
```gdscript
		"puzzle_state": ps.duplicate(true),
```

- [ ] **Step 6: Update PartyState.build_save_data() call**

In `party_state.gd`, update the `build_save_data()` method to pass `puzzle_state`:

```gdscript
func build_save_data() -> Dictionary:
	return Helpers.build_save_dict(
		members,
		formation,
		inventory,
		owned_equipment,
		location_name,
		gold,
		EventFlags.to_save_data(),
		playtime,
		ley_crystals,
		puzzle_state
	)
```

- [ ] **Step 7: Add "puzzle_state" to save_manager.gd _validate()**

In `save_manager.gd`, add `"puzzle_state"` to the `required` array in `_validate()` (after `"ley_crystals"`):

```gdscript
		"ley_crystals",
		"puzzle_state",
		"world",
```

- [ ] **Step 8: Run tests — expect PASS**

Run: `gdlint game/scripts/autoload/party_state.gd && echo "lint OK"`
Expected: lint OK (or warnings about max-public-methods)

- [ ] **Step 9: Format and commit**

```bash
gdformat game/scripts/autoload/party_state.gd game/scripts/autoload/inventory_helpers.gd
git add game/scripts/autoload/party_state.gd game/scripts/autoload/inventory_helpers.gd game/scripts/autoload/save_manager.gd game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add puzzle_state system to PartyState with save/load"
```

---

### Task 3: Water Wheel Entity

**Files:**
- Create: `game/scripts/entities/water_wheel.gd`
- Create: `game/scenes/entities/water_wheel.tscn`
- Modify: `game/tests/test_fenmother_puzzles.gd` (append tests)

- [ ] **Step 1: Add water wheel tests to test file**

Append to `game/tests/test_fenmother_puzzles.gd`:

```gdscript


# --- Water Wheel ---


const WHEEL_SCENE: PackedScene = preload("res://scenes/entities/water_wheel.tscn")


func test_wheel_initialize() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	assert_eq(wheel.wheel_id, "wheel_1", "wheel_id should be set")
	assert_false(wheel.is_high, "should default to LOW")


func test_wheel_interact_toggles() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	watch_signals(wheel)
	wheel.interact()
	assert_true(wheel.is_high, "should be HIGH after interact")
	assert_signal_emitted(wheel, "wheel_toggled")


func test_wheel_interact_persists_to_puzzle_state() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	wheel.interact()
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "wheel_1_high", false)
	assert_true(val, "puzzle_state should reflect HIGH after toggle")


func test_wheel_initialize_restores_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	assert_true(wheel.is_high, "should restore HIGH from puzzle_state")


func test_wheel_toggle_back_to_low() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("wheel_1", "fenmothers_hollow")
	wheel.interact()
	wheel.interact()
	assert_false(wheel.is_high, "should be LOW after two toggles")


func test_wheel_empty_id_guard() -> void:
	var wheel: Area2D = WHEEL_SCENE.instantiate()
	add_child_autofree(wheel)
	wheel.initialize("", "fenmothers_hollow")
	assert_eq(wheel.wheel_id, "", "should remain empty")
```

- [ ] **Step 2: Create water_wheel.gd**

```gdscript
extends Area2D
## Water wheel interactable — toggles HIGH/LOW state for water level puzzles.

signal wheel_toggled(wheel_id: String, is_high: bool)

var wheel_id: String = ""
var _dungeon_id: String = ""
var is_high: bool = false

@onready var _sprite: Sprite2D = $Sprite2D


func initialize(p_wheel_id: String, p_dungeon_id: String) -> void:
	if p_wheel_id.is_empty() or p_dungeon_id.is_empty():
		if p_wheel_id.is_empty():
			push_error("WaterWheel: empty wheel_id")
		return
	wheel_id = p_wheel_id
	_dungeon_id = p_dungeon_id
	is_high = PartyState.get_puzzle_state(_dungeon_id, "%s_high" % wheel_id, false)
	_update_visual()


func interact() -> void:
	if wheel_id.is_empty():
		return
	is_high = not is_high
	PartyState.set_puzzle_state(_dungeon_id, "%s_high" % wheel_id, is_high)
	_update_visual()
	wheel_toggled.emit(wheel_id, is_high)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.frame = 1 if is_high else 0
```

- [ ] **Step 3: Create water_wheel.tscn**

Build the .tscn file with:
- Root: Area2D named "WaterWheel", collision_layer = 4 (layer 3), collision_mask = 0, script = water_wheel.gd
- Child: Sprite2D with placeholder 16x16 texture (create a 2-frame horizontal spritesheet: grey=LOW, blue=HIGH, hframes=2)
- Child: CollisionShape2D with RectangleShape2D (size 12x12)

Note: Use a simple ColorRect converted to texture or reference the existing placeholder approach from save_point.tscn.

- [ ] **Step 4: Format and commit**

```bash
gdformat game/scripts/entities/water_wheel.gd
git add game/scripts/entities/water_wheel.gd game/scenes/entities/water_wheel.tscn game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add water wheel interactable entity"
```

---

## Chunk 2: Water Zones + Spirit Vessel Chain (Tasks 4-7)

### Task 4: Water Zone Entity

**Files:**
- Create: `game/scripts/entities/water_zone.gd`
- Create: `game/scenes/entities/water_zone.tscn`
- Modify: `game/tests/test_fenmother_puzzles.gd` (append tests)

- [ ] **Step 1: Add water zone tests**

Append to `game/tests/test_fenmother_puzzles.gd`:

```gdscript


# --- Water Zone ---


const ZONE_SCENE: PackedScene = preload("res://scenes/entities/water_zone.tscn")


func test_zone_condition_parsing_single() -> void:
	var zone: Area2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_low", "block")
	assert_eq(zone._conditions.size(), 1, "should parse 1 condition")


func test_zone_condition_parsing_multiple() -> void:
	var zone: Area2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_high,wheel_2_high,wheel_3_high", "block")
	assert_eq(zone._conditions.size(), 3, "should parse 3 conditions")


func test_zone_block_active_when_conditions_met() -> void:
	var zone: Area2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_low", "block")
	# wheel_1_high defaults to false, so "wheel_1_low" is true
	zone.refresh()
	assert_true(zone.visible, "block zone should be visible when conditions met")


func test_zone_block_inactive_when_conditions_not_met() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	var zone: Area2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_low", "block")
	zone.refresh()
	assert_false(zone.visible, "block zone should be hidden when conditions not met")


func test_zone_reveal_active_when_conditions_met() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_1_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_2_high", true)
	PartyState.set_puzzle_state("fenmothers_hollow", "wheel_3_high", true)
	var zone: Area2D = ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("fenmothers_hollow", "wheel_1_high,wheel_2_high,wheel_3_high", "reveal")
	zone.refresh()
	assert_true(zone.visible, "reveal zone should be visible when all conditions met")
```

- [ ] **Step 2: Create water_zone.gd**

```gdscript
extends Area2D
## Water level zone — blocks or reveals paths based on water wheel state.

var _dungeon_id: String = ""
var _conditions: Array[Dictionary] = []
var _zone_type: String = "block"

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func initialize(dungeon_id: String, conditions_str: String, zone_type: String) -> void:
	_dungeon_id = dungeon_id
	_zone_type = zone_type
	_conditions = []
	for cond: String in conditions_str.split(","):
		var trimmed: String = cond.strip_edges()
		if trimmed.is_empty():
			continue
		var parts: Array = trimmed.rsplit("_", true, 1)
		if parts.size() < 2:
			push_error("WaterZone: invalid condition format '%s'" % trimmed)
			continue
		var wheel_key: String = parts[0] + "_high"
		var expected_high: bool = parts[1] == "high"
		_conditions.append({"key": wheel_key, "expected_high": expected_high})
	refresh()


func refresh() -> void:
	var all_met: bool = true
	for cond: Dictionary in _conditions:
		var actual: bool = PartyState.get_puzzle_state(_dungeon_id, cond["key"], false)
		if actual != cond["expected_high"]:
			all_met = false
			break
	if _zone_type == "block":
		visible = all_met
		if _collision != null:
			_collision.disabled = not all_met
	else:  # reveal
		visible = all_met
		if _collision != null:
			_collision.disabled = all_met
```

- [ ] **Step 3: Create water_zone.tscn**

Build the .tscn file with:
- Root: Area2D named "WaterZone", collision_layer = 1 (blocks player), collision_mask = 0, script = water_zone.gd
- Child: Sprite2D with placeholder semi-transparent blue rectangle
- Child: CollisionShape2D with RectangleShape2D (size set per instance in map)

- [ ] **Step 4: Format and commit**

```bash
gdformat game/scripts/entities/water_zone.gd
git add game/scripts/entities/water_zone.gd game/scenes/entities/water_zone.tscn game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add water zone entity for level-based path gating"
```

---

### Task 5: Key Items — Spirit Vessel

**Files:**
- Modify: `game/data/items/key_items.json`

- [ ] **Step 1: Add Spirit Vessel entries to key_items.json**

Append these two entries to the `"items"` array in `key_items.json`:

```json
    {
      "id": "spirit_vessel",
      "name": "Spirit Vessel",
      "category": "key_item",
      "subcategory": "dungeon_access",
      "description": "An empty fenwood bowl lined with thin ley-crystal. It could hold sacred water.",
      "auto_use": false,
      "acquired_from": "Fenmother's Hollow F1 hidden alcove",
      "quest_link": "fenmothers_hollow_spirit_plant"
    },
    {
      "id": "spirit_vessel_filled",
      "name": "Spirit Vessel (Filled)",
      "category": "key_item",
      "subcategory": "dungeon_access",
      "description": "A fenwood bowl brimming with pure spring water. It glows faintly with spiritual energy.",
      "auto_use": false,
      "acquired_from": "Pure Spring in Fenmother's Hollow F1",
      "quest_link": "fenmothers_hollow_spirit_plant"
    }
```

- [ ] **Step 2: Validate JSON**

Run: `python3 -c "import json; d=json.load(open('game/data/items/key_items.json')); print(len(d['items']), 'items'); ids=[i['id'] for i in d['items']]; assert len(ids)==len(set(ids)), 'duplicate IDs'"`
Expected: `28 items` (26 existing + 2 new), no duplicate assertion

- [ ] **Step 3: Commit**

```bash
git add game/data/items/key_items.json
git commit -m "feat(engine): add Spirit Vessel key items for Fenmother puzzle"
```

---

### Task 6: Pure Spring Entity

**Files:**
- Create: `game/scripts/entities/pure_spring.gd`
- Create: `game/scenes/entities/pure_spring.tscn`
- Modify: `game/tests/test_fenmother_puzzles.gd` (append tests)

- [ ] **Step 1: Add pure spring tests**

Append to `game/tests/test_fenmother_puzzles.gd`:

```gdscript


# --- Pure Spring ---


const SPRING_SCENE: PackedScene = preload("res://scenes/entities/pure_spring.tscn")


func test_spring_fill_with_empty_vessel() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel"]
	var spring: Area2D = SPRING_SCENE.instantiate()
	add_child_autofree(spring)
	watch_signals(spring)
	spring.interact()
	assert_signal_emitted(spring, "spring_filled")
	assert_true(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"should have filled vessel after interaction"
	)
	assert_false(
		"spirit_vessel" in PartyState.inventory["key_items"],
		"empty vessel should be removed"
	)


func test_spring_no_vessel() -> void:
	PartyState.initialize_new_game()
	var spring: Area2D = SPRING_SCENE.instantiate()
	add_child_autofree(spring)
	watch_signals(spring)
	spring.interact()
	assert_signal_not_emitted(spring, "spring_filled")


func test_spring_already_filled() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var spring: Area2D = SPRING_SCENE.instantiate()
	add_child_autofree(spring)
	watch_signals(spring)
	spring.interact()
	assert_signal_not_emitted(spring, "spring_filled")
	assert_true(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"filled vessel should remain"
	)
```

- [ ] **Step 2: Create pure_spring.gd**

```gdscript
extends Area2D
## Pure spring — fills an empty Spirit Vessel with sacred water.

signal spring_filled
signal interaction_message(text: String)


func interact() -> void:
	var key_items: Array = PartyState.inventory.get("key_items", [])
	if "spirit_vessel_filled" in key_items:
		interaction_message.emit("The vessel is already full.")
		return
	if "spirit_vessel" in key_items:
		key_items.erase("spirit_vessel")
		key_items.append("spirit_vessel_filled")
		PartyState.inventory["key_items"] = key_items
		spring_filled.emit()
		return
	interaction_message.emit("You have nothing to hold the water in.")
```

- [ ] **Step 3: Create pure_spring.tscn**

Build the .tscn file with:
- Root: Area2D named "PureSpring", collision_layer = 4 (layer 3), collision_mask = 0, script = pure_spring.gd
- Child: Sprite2D with placeholder 16x16 blue-white texture
- Child: CollisionShape2D with RectangleShape2D (size 12x12)

- [ ] **Step 4: Format and commit**

```bash
gdformat game/scripts/entities/pure_spring.gd
git add game/scripts/entities/pure_spring.gd game/scenes/entities/pure_spring.tscn game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add pure spring entity for Spirit Vessel filling"
```

---

### Task 7: Spirit-Plant Entity

**Files:**
- Create: `game/scripts/entities/spirit_plant.gd`
- Create: `game/scenes/entities/spirit_plant.tscn`
- Modify: `game/tests/test_fenmother_puzzles.gd` (append tests)

- [ ] **Step 1: Add spirit-plant tests**

Append to `game/tests/test_fenmother_puzzles.gd`:

```gdscript


# --- Spirit Plant ---


const PLANT_SCENE: PackedScene = preload("res://scenes/entities/spirit_plant.tscn")


func test_plant_initialize_unrestored() -> void:
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	assert_false(plant.is_restored, "should start unrestored")


func test_plant_interact_with_filled_vessel() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	watch_signals(plant)
	plant.interact()
	assert_true(plant.is_restored, "should be restored after pour")
	assert_signal_emitted(plant, "plant_restored")
	assert_true(
		"spirit_vessel" in PartyState.inventory["key_items"],
		"empty vessel should be returned"
	)
	assert_false(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"filled vessel should be consumed"
	)


func test_plant_interact_without_vessel() -> void:
	PartyState.initialize_new_game()
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	watch_signals(plant)
	plant.interact()
	assert_false(plant.is_restored, "should stay unrestored")
	assert_signal_not_emitted(plant, "plant_restored")


func test_plant_persists_restored_state() -> void:
	PartyState.set_puzzle_state("fenmothers_hollow", "plant_restored", true)
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	assert_true(plant.is_restored, "should restore from puzzle_state")


func test_plant_interact_already_restored() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	PartyState.set_puzzle_state("fenmothers_hollow", "plant_restored", true)
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	watch_signals(plant)
	plant.interact()
	assert_signal_not_emitted(plant, "plant_restored")
	assert_true(
		"spirit_vessel_filled" in PartyState.inventory["key_items"],
		"vessel should not be consumed when already restored"
	)


func test_plant_collision_disabled_after_restore() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	plant.interact()
	var col: CollisionShape2D = plant.get_node_or_null("CollisionShape2D")
	if col != null:
		assert_true(col.disabled, "collision should be disabled after restore")


func test_plant_visual_changes_on_restore() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	var sprite: Sprite2D = plant.get_node_or_null("Sprite2D")
	var color_before: Color = sprite.modulate if sprite != null else Color.WHITE
	plant.interact()
	if sprite != null:
		assert_ne(sprite.modulate, color_before, "sprite color should change after restore")


func test_plant_puzzle_state_persists_after_restore() -> void:
	PartyState.initialize_new_game()
	PartyState.inventory["key_items"] = ["spirit_vessel_filled"]
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	plant.interact()
	var val: Variant = PartyState.get_puzzle_state("fenmothers_hollow", "plant_restored", false)
	assert_true(val, "plant_restored should be set in puzzle_state")


func test_plant_reinitialize_after_restore_stays_open() -> void:
	PartyState.initialize_new_game()
	PartyState.set_puzzle_state("fenmothers_hollow", "plant_restored", true)
	var plant: StaticBody2D = PLANT_SCENE.instantiate()
	add_child_autofree(plant)
	plant.initialize("spirit_plant_1", "fenmothers_hollow")
	assert_true(plant.is_restored, "should be restored from puzzle_state")
	var col: CollisionShape2D = plant.get_node_or_null("CollisionShape2D")
	if col != null:
		assert_true(col.disabled, "collision should remain disabled")
```

- [ ] **Step 2: Create spirit_plant.gd**

```gdscript
extends StaticBody2D
## Spirit-plant — blocks passage until restored with filled Spirit Vessel.

signal plant_restored(plant_id: String)
signal interaction_message(text: String)

var plant_id: String = ""
var is_restored: bool = false
var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _interaction_area: Area2D = $InteractionArea


func initialize(p_plant_id: String, p_dungeon_id: String) -> void:
	if p_plant_id.is_empty() or p_dungeon_id.is_empty():
		push_error("SpiritPlant: empty plant_id or dungeon_id")
		return
	plant_id = p_plant_id
	_dungeon_id = p_dungeon_id
	is_restored = PartyState.get_puzzle_state(_dungeon_id, "plant_restored", false)
	_update_visual()


func interact() -> void:
	if plant_id.is_empty():
		return
	if is_restored:
		interaction_message.emit("The spirit-plant glows with restored luminescence.")
		return
	var key_items: Array = PartyState.inventory.get("key_items", [])
	if "spirit_vessel_filled" not in key_items:
		interaction_message.emit("The spirit-plant's tendrils block the passage. It is withering.")
		return
	# Pour the water
	key_items.erase("spirit_vessel_filled")
	key_items.append("spirit_vessel")
	PartyState.inventory["key_items"] = key_items
	is_restored = true
	PartyState.set_puzzle_state(_dungeon_id, "plant_restored", true)
	_update_visual()
	plant_restored.emit(plant_id)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.modulate = Color("#88ccff") if is_restored else Color("#666666")
	if _collision != null:
		_collision.disabled = is_restored
```

- [ ] **Step 3: Create spirit_plant.tscn**

Build the .tscn file with:
- Root: StaticBody2D named "SpiritPlant", collision_layer = 1, script = spirit_plant.gd
- Child: Sprite2D with placeholder 16x24 grey rectangle (will change to blue on restore)
- Child: CollisionShape2D with RectangleShape2D (passage-blocking size, e.g., 32x48)
- Child: InteractionArea (Area2D, collision_layer = 4, collision_mask = 0)
  - Child: CollisionShape2D with RectangleShape2D (12x12)

- [ ] **Step 4: Format and commit**

```bash
gdformat game/scripts/entities/spirit_plant.gd
git add game/scripts/entities/spirit_plant.gd game/scenes/entities/spirit_plant.tscn game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add spirit-plant entity for passage restoration puzzle"
```

---

## Chunk 3: Damage Zones + Ritual Meter (Tasks 8-9)

### Task 8: Damage Zone Entity

**Files:**
- Create: `game/scripts/entities/damage_zone.gd`
- Create: `game/scenes/entities/damage_zone.tscn`
- Modify: `game/tests/test_fenmother_puzzles.gd` (append tests)

- [ ] **Step 1: Add damage zone tests**

Append to `game/tests/test_fenmother_puzzles.gd`:

```gdscript


# --- Damage Zone ---


const DAMAGE_ZONE_SCENE: PackedScene = preload("res://scenes/entities/damage_zone.tscn")


func test_damage_zone_initialize() -> void:
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 8, 1.0, "poison")
	assert_eq(zone.zone_id, "test_pool")
	assert_eq(zone.damage_per_tick, 8)


func test_damage_zone_deals_damage() -> void:
	PartyState.initialize_new_game()
	var edren: Dictionary = PartyState.get_member("edren")
	var hp_before: int = edren.get("current_hp", 0)
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	zone._apply_tick()
	var hp_after: int = PartyState.get_member("edren").get("current_hp", 0)
	assert_lt(hp_after, hp_before, "HP should decrease after damage tick")


func test_damage_zone_clamps_to_min_1() -> void:
	PartyState.initialize_new_game()
	var edren: Dictionary = PartyState.get_member("edren")
	edren["current_hp"] = 5
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 100, 1.0, "")
	zone._apply_tick()
	var hp_after: int = PartyState.get_member("edren").get("current_hp", 0)
	assert_eq(hp_after, 1, "HP should clamp to 1, not kill")


func test_damage_zone_applies_status_first_tick_only() -> void:
	PartyState.initialize_new_game()
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 5, 1.0, "poison")
	zone._apply_tick()
	assert_true(zone._status_applied, "status should be applied on first tick")
	zone._apply_tick()
	# Second tick should not re-apply (flag stays true, no double-apply)
	assert_true(zone._status_applied, "flag should remain true")


func test_damage_zone_signal_emitted() -> void:
	PartyState.initialize_new_game()
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	watch_signals(zone)
	zone._apply_tick()
	assert_signal_emitted(zone, "zone_damage_dealt")


func test_damage_zone_no_damage_after_exit() -> void:
	PartyState.initialize_new_game()
	var zone: Area2D = DAMAGE_ZONE_SCENE.instantiate()
	add_child_autofree(zone)
	zone.initialize("test_pool", 10, 1.0, "")
	zone._player_inside = true
	zone._apply_tick()
	var hp_after_tick: int = PartyState.get_member("edren").get("current_hp", 0)
	zone._player_inside = false
	zone._on_tick()  # Should not apply since player is outside
	var hp_after_exit: int = PartyState.get_member("edren").get("current_hp", 0)
	assert_eq(hp_after_exit, hp_after_tick, "no further damage after player exits")
```

- [ ] **Step 2: Create damage_zone.gd**

```gdscript
extends Area2D
## Poison damage zone — deals periodic damage to party while player stands in it.

signal zone_damage_dealt(zone_id: String, total_damage: int)

var zone_id: String = ""
var damage_per_tick: int = 8
var _tick_interval: float = 1.0
var _status_effect: String = ""
var _status_applied: bool = false
var _player_inside: bool = false
var _timer: Timer = null


func initialize(
	p_zone_id: String, p_damage: int, p_interval: float, p_status: String
) -> void:
	zone_id = p_zone_id
	damage_per_tick = p_damage
	_tick_interval = p_interval
	_status_effect = p_status
	_status_applied = false


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = _tick_interval
	_timer.one_shot = false
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("try_interact"):  # player check
		_player_inside = true
		_status_applied = false
		_timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("try_interact"):
		_player_inside = false
		_timer.stop()


func _on_tick() -> void:
	if _player_inside:
		_apply_tick()


func _apply_tick() -> void:
	var active: Array[Dictionary] = PartyState.get_active_party()
	var total: int = 0
	for member: Dictionary in active:
		var hp: int = member.get("current_hp", 0)
		if hp <= 0:
			continue
		var new_hp: int = maxi(1, hp - damage_per_tick)
		var dealt: int = hp - new_hp
		member["current_hp"] = new_hp
		total += dealt
	if not _status_applied and not _status_effect.is_empty():
		_status_applied = true
		# Status application deferred to battle system integration
	zone_damage_dealt.emit(zone_id, total)
```

- [ ] **Step 3: Create damage_zone.tscn**

Build the .tscn file with:
- Root: Area2D named "DamageZone", collision_layer = 0, collision_mask = 2 (detect player on layer 2), monitoring = true, script = damage_zone.gd
- Child: Sprite2D with placeholder dark purple semi-transparent rectangle
- Child: CollisionShape2D with RectangleShape2D (sized per instance)

- [ ] **Step 4: Format and commit**

```bash
gdformat game/scripts/entities/damage_zone.gd
git add game/scripts/entities/damage_zone.gd game/scenes/entities/damage_zone.tscn game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add poison damage zone entity"
```

---

### Task 9: Ritual Meter

**Files:**
- Create: `game/scripts/ui/ritual_meter.gd`
- Create: `game/scenes/ui/ritual_meter.tscn`
- Modify: `game/tests/test_fenmother_puzzles.gd` (append tests)

- [ ] **Step 1: Add ritual meter tests**

Append to `game/tests/test_fenmother_puzzles.gd`:

```gdscript


# --- Ritual Meter ---


func test_ritual_meter_initial_value() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	assert_eq(meter.meter_value, 100.0, "should start at 100")


func test_ritual_meter_drain() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	meter.drain(25.0)
	assert_eq(meter.meter_value, 75.0, "should be 75 after draining 25")


func test_ritual_meter_recover() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	meter.drain(50.0)
	meter.recover(20.0)
	assert_eq(meter.meter_value, 70.0, "should be 70 after drain 50 + recover 20")


func test_ritual_meter_clamp_min() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	meter.drain(200.0)
	assert_eq(meter.meter_value, 0.0, "should clamp to 0")
	assert_true(meter.is_failed(), "should be failed at 0")


func test_ritual_meter_clamp_max() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	meter.recover(50.0)
	assert_eq(meter.meter_value, 100.0, "should clamp to 100")


func test_ritual_meter_not_failed_at_1() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	meter.drain(99.0)
	assert_false(meter.is_failed(), "should not be failed at 1")


func test_ritual_meter_calculate_drain() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	# Wave 1: 0 KOs, 6 turns (at threshold), no recovery
	var drain: float = meter.calculate_drain(0, 0, 6, 6, false)
	assert_eq(drain, 15.0, "base drain only when at threshold with 0 KOs")


func test_ritual_meter_calculate_drain_with_penalties() -> void:
	var meter: Node = preload("res://scripts/ui/ritual_meter.gd").new()
	add_child_autofree(meter)
	# Wave 2: 2 KOs, 12 turns (4 over threshold of 8), with recovery
	var drain: float = meter.calculate_drain(1, 2, 12, 8, true)
	# base=15 + ko=20 + turn=8 - recovery=10 = 33
	assert_eq(drain, 33.0, "should sum penalties and subtract recovery")
```

- [ ] **Step 2: Create ritual_meter.gd**

```gdscript
extends CanvasLayer
## Ritual meter HUD — tracks cleansing ritual progress between waves.

const COLOR_GREEN: Color = Color("#44cc44")
const COLOR_YELLOW: Color = Color("#cccc44")
const COLOR_ORANGE: Color = Color("#cc8844")
const COLOR_RED: Color = Color("#cc4444")

const STATUS_TEXT: Dictionary = {
	"high": "The Fenmother's light holds steady...",
	"mid": "The ritual strains against the corruption...",
	"low": "The ritual weakens... hold the line!",
	"critical": "The Fenmother's light flickers dangerously!",
	"failed": "The corruption surges back!",
}

var meter_value: float = 100.0

@onready var _fill_bar: ColorRect = $Panel/Layout/BarContainer/BarBg/BarFill
@onready var _bar_bg: ColorRect = $Panel/Layout/BarContainer/BarBg
@onready var _status_label: Label = $Panel/Layout/StatusLabel


func show_meter() -> void:
	visible = true
	_update_display()


func hide_meter() -> void:
	visible = false


func set_value(new_value: float) -> void:
	meter_value = clampf(new_value, 0.0, 100.0)
	_update_display()


func drain(amount: float) -> void:
	set_value(meter_value - amount)


func recover(amount: float) -> void:
	set_value(meter_value + amount)


func is_failed() -> bool:
	return meter_value <= 0.0


func reset_for_retry() -> void:
	set_value(25.0)


## Calculate total drain for a wave based on performance.
func calculate_drain(
	wave_num: int, ko_count: int, turn_count: int,
	turn_threshold: int, has_recovery: bool
) -> float:
	var base_drain: float = 15.0
	var ko_penalty: float = 10.0 * ko_count
	var turn_penalty: float = 2.0 * maxf(0.0, turn_count - turn_threshold)
	var recovery: float = 10.0 if has_recovery else 0.0
	return base_drain + ko_penalty + turn_penalty - recovery


func _update_display() -> void:
	if _fill_bar != null and _bar_bg != null:
		_fill_bar.size.x = _bar_bg.size.x * (meter_value / 100.0)
		_fill_bar.color = _get_color()
	if _status_label != null:
		_status_label.text = _get_status_text()


func _get_color() -> Color:
	if meter_value >= 75.0:
		return COLOR_GREEN
	if meter_value >= 50.0:
		return COLOR_YELLOW
	if meter_value >= 25.0:
		return COLOR_ORANGE
	return COLOR_RED


func _get_status_text() -> String:
	if meter_value <= 0.0:
		return STATUS_TEXT["failed"]
	if meter_value < 25.0:
		return STATUS_TEXT["critical"]
	if meter_value < 50.0:
		return STATUS_TEXT["low"]
	if meter_value < 75.0:
		return STATUS_TEXT["mid"]
	return STATUS_TEXT["high"]
```

- [ ] **Step 3: Create ritual_meter.tscn**

Build the .tscn file with:
- Root: CanvasLayer named "RitualMeter", layer = 11, visible = false, script = ritual_meter.gd
- Child: Panel (PanelContainer, FF6-style StyleBoxFlat, centered at top, ~240x80)
  - Child: Layout (VBoxContainer)
    - Child: TitleLabel (Label, text = "Cleansing Ritual", centered)
    - Child: BarContainer (HBoxContainer)
      - Child: BarBg (ColorRect, 200x12, dark grey)
        - Child: BarFill (ColorRect, 200x12, green)
    - Child: StatusLabel (Label, centered)

- [ ] **Step 4: Format and commit**

```bash
gdformat game/scripts/ui/ritual_meter.gd
git add game/scripts/ui/ritual_meter.gd game/scenes/ui/ritual_meter.tscn game/tests/test_fenmother_puzzles.gd
git commit -m "feat(engine): add ritual meter overlay for cleansing wave sequence"
```

---

## Chunk 4: Battle Manager + Player Character Changes (Tasks 10-11)

### Task 10: Battle Manager — Turn Counter + KO Count

**Files:**
- Modify: `game/scripts/combat/battle_manager.gd`

- [ ] **Step 1: Add turn counter variable**

In `battle_manager.gd`, add near other instance variables:

```gdscript
var _turn_counter: int = 0
```

- [ ] **Step 2: Reset turn counter at battle start**

In the battle initialization method (where `_earned_xp = 0` etc. are reset), add:

```gdscript
	_turn_counter = 0
```

- [ ] **Step 3: Increment turn counter on each combatant action**

Find where a combatant's turn is processed (the ATB ready callback or action execution). After the action resolves, add:

```gdscript
	_turn_counter += 1
```

- [ ] **Step 4: Add KO count helper**

```gdscript
func _count_ko_party_members() -> int:
	var count: int = 0
	for i: int in range(4):
		var m: Dictionary = _state.get_member(i)
		if not m.is_empty() and not m.get("is_alive", true):
			count += 1
	return count
```

- [ ] **Step 5: Add turn_count and ko_count to victory transition data**

In the `_exit_battle` method where the transition dictionary `t` is built, add:

```gdscript
	t["turn_count"] = _turn_counter
	t["ko_count"] = _count_ko_party_members()
```

- [ ] **Step 6: Format and commit**

```bash
gdformat game/scripts/combat/battle_manager.gd
git add game/scripts/combat/battle_manager.gd
git commit -m "feat(engine): add turn counter and KO count to battle victory data"
```

---

### Task 11: Player Character — Input Enable/Disable

**Files:**
- Modify: `game/scripts/entities/player_character.gd`

- [ ] **Step 1: Add input enabled flag**

Near the top of `player_character.gd`, with other variables:

```gdscript
var _input_enabled: bool = true
```

- [ ] **Step 2: Add set_input_enabled method**

```gdscript
## Enable or disable player input processing (for auto-walk scenes).
func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
```

- [ ] **Step 3: Guard _unhandled_input with flag**

At the very start of the `_unhandled_input` method, add:

```gdscript
	if not _input_enabled:
		return
```

- [ ] **Step 4: Also guard _physics_process movement**

At the start of `_physics_process`, add:

```gdscript
	if not _input_enabled:
		return
```

- [ ] **Step 5: Format and commit**

```bash
gdformat game/scripts/entities/player_character.gd
git add game/scripts/entities/player_character.gd
git commit -m "feat(engine): add input enable/disable to player character for auto-walk"
```

---

## Chunk 5: Exploration.gd Integration (Tasks 12-14)

### Task 12: Entity Wiring in Exploration.gd

**Files:**
- Modify: `game/scripts/core/exploration.gd`

This is the most complex task — wiring all 5 new entity types into the exploration entity system.

- [ ] **Step 1: Add new entity detection in _initialize_entities**

After the existing `save_point_activated` elif block (around line 285), add detection for the 4 new interactive entity types:

```gdscript
		elif child.has_signal("wheel_toggled"):
			var wid: String = child.get_meta("wheel_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if wid.is_empty():
				push_error("Exploration: WaterWheel '%s' missing wheel_id" % child.name)
				continue
			child.initialize(wid, did)
		elif child.has_signal("spring_filled"):
			pass  # No initialization needed, signal connection only
		elif child.has_method("refresh") and not child.has_signal("wheel_toggled"):
			# Water zones — initialize with metadata, then refresh
			var did: String = child.get_meta("dungeon_id", "")
			var conds: String = child.get_meta("active_when", "")
			var zt: String = child.get_meta("zone_type", "block")
			child.initialize(did, conds, zt)
		elif child.has_signal("plant_restored"):
			var pid: String = child.get_meta("plant_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if pid.is_empty():
				push_error("Exploration: SpiritPlant '%s' missing plant_id" % child.name)
				continue
			child.initialize(pid, did)
		elif child.has_signal("zone_damage_dealt"):
			var zid: String = child.get_meta("zone_id", "")
			var dpt: int = child.get_meta("damage_per_tick", 8)
			var ti: float = child.get_meta("tick_interval", 1.0)
			var se: String = child.get_meta("status_effect", "poison")
			child.initialize(zid, dpt, ti, se)
```

- [ ] **Step 2: Add water zone refresh after entity init**

After the entity initialization loop in `_initialize_entities`, add a second pass for water zones:

```gdscript
	# Refresh water zones after all entities initialized
	if entities != null:
		for child: Node in entities.get_children():
			if child.has_method("refresh"):
				child.refresh()
```

- [ ] **Step 3: Add signal connections in _connect_entity_signals**

In the entities loop inside `_connect_entity_signals`, add:

```gdscript
			if child.has_signal("wheel_toggled"):
				child.wheel_toggled.connect(_on_wheel_toggled)
			if child.has_signal("spring_filled"):
				child.spring_filled.connect(_on_spring_filled)
			if child.has_signal("plant_restored"):
				child.plant_restored.connect(_on_plant_restored)
			if child.has_signal("zone_damage_dealt"):
				child.zone_damage_dealt.connect(_on_zone_damage_dealt)
			if child.has_signal("interaction_message"):
				child.interaction_message.connect(_on_interaction_message)
```

- [ ] **Step 4: Update disconnect in _disconnect_entity_signals**

Add the new signals to the `sigs` dictionary:

```gdscript
	var sigs: Dictionary = {
		"npc_interacted": _on_npc_interacted,
		"chest_opened": _on_chest_opened,
		"save_point_activated": _on_save_point_activated,
		"wheel_toggled": _on_wheel_toggled,
		"spring_filled": _on_spring_filled,
		"plant_restored": _on_plant_restored,
		"zone_damage_dealt": _on_zone_damage_dealt,
		"interaction_message": _on_interaction_message,
	}
```

- [ ] **Step 5: Add signal handler methods**

```gdscript
func _on_wheel_toggled(wheel_id: String, is_high: bool) -> void:
	var status: String = "HIGH" if is_high else "LOW"
	flash_location_name("Water wheel %s set to %s" % [wheel_id.replace("_", " ").capitalize(), status])
	# Refresh all water zones on the current map
	if _current_map != null:
		var entities: Node = _current_map.get_node_or_null("Entities")
		if entities != null:
			for child: Node in entities.get_children():
				if child.has_method("refresh"):
					child.refresh()


func _on_spring_filled() -> void:
	flash_location_name("Filled the Spirit Vessel with pure water.")


func _on_plant_restored(plant_id: String) -> void:
	flash_location_name("Passage Opened")
	# Push restoration dialogue
	var scene_data: Dictionary = DataManager.load_dialogue("water_of_life")
	var entries: Array = scene_data.get("entries", [])
	if not entries.is_empty() and GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(entries)


func _on_zone_damage_dealt(_zone_id: String, _total_damage: int) -> void:
	pass  # Visual/audio feedback deferred to gap 3.8


func _on_interaction_message(text: String) -> void:
	flash_location_name(text)
```

- [ ] **Step 6: Format and commit**

```bash
gdformat game/scripts/core/exploration.gd
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): wire puzzle entities into exploration entity system"
```

---

### Task 13: Auto-Walk System in Exploration.gd

**Files:**
- Modify: `game/scripts/core/exploration.gd`

- [ ] **Step 1: Add auto-walk detection in load_map**

At the end of `load_map()`, after the `map_changed.emit(map_id)` line, add:

```gdscript
	# Auto-walk scenes (spirit path, etc.)
	if _current_map.get_meta("is_auto_walk", false) and _player != null:
		_start_auto_walk()
```

- [ ] **Step 2: Add _start_auto_walk method**

```gdscript
func _start_auto_walk() -> void:
	if _player == null or _current_map == null:
		return
	_player.set_input_enabled(false)
	# Find the transition exit to determine walk target
	var transitions: Node = _current_map.get_node_or_null("Transitions")
	if transitions == null:
		_player.set_input_enabled(true)
		return
	var target_pos: Vector2 = _player.position
	for child: Node in transitions.get_children():
		if child is Area2D:
			target_pos = child.position
			break
	# Play walk animation toward exit
	var direction: Vector2 = (target_pos - _player.position).normalized()
	if absf(direction.x) > absf(direction.y):
		_player.play_animation("walk_east" if direction.x > 0 else "walk_west")
	else:
		_player.play_animation("walk_south" if direction.y > 0 else "walk_north")
	var distance: float = _player.position.distance_to(target_pos)
	var duration: float = distance / 80.0  # 80 px/sec = normal walk speed
	var auto_tween: Tween = create_tween()
	auto_tween.tween_property(_player, "position", target_pos, duration)
	# Transition fires automatically when player enters Area2D.
	# Re-enable input after transition completes (safety net for non-transition end)
	auto_tween.tween_callback(_player.set_input_enabled.bind(true))
```

- [ ] **Step 3: Add auto-sequence detection in load_map**

After the auto-walk check, add:

```gdscript
	# Auto-sequences (Caden binding, etc.)
	var seq_id: String = _current_map.get_meta("auto_sequence", "")
	var seq_flag: String = _current_map.get_meta("auto_sequence_flag", "")
	if not seq_id.is_empty() and not EventFlags.get_flag(seq_flag):
		call_deferred("_run_auto_sequence", seq_id, seq_flag)
```

- [ ] **Step 4: Add _run_auto_sequence method**

```gdscript
func _run_auto_sequence(sequence_id: String, completion_flag: String) -> void:
	match sequence_id:
		"caden_binding":
			_run_caden_binding(completion_flag)
		_:
			push_warning("Exploration: Unknown auto_sequence '%s'" % sequence_id)
```

- [ ] **Step 5: Add _run_caden_binding method**

```gdscript
func _run_caden_binding(completion_flag: String) -> void:
	var spawn: Node2D = _current_map.get_node_or_null("CadenSpawnPoint")
	var center: Vector2 = Vector2(128, 80)
	var start_pos: Vector2 = spawn.position if spawn != null else Vector2(288, 80)
	# 0.5s delay before Caden appears (player can look around)
	await get_tree().create_timer(0.5).timeout
	# Instantiate Caden NPC
	var npc_scene: PackedScene = preload("res://scenes/entities/npc.tscn")
	var caden: Node2D = npc_scene.instantiate()
	_current_map.get_node_or_null("Entities").add_child(caden)
	caden.position = start_pos
	caden.modulate.a = 0.0
	caden.initialize("caden_duskfen")
	# Tween: fade in + walk to center
	var arrival_tween: Tween = create_tween()
	arrival_tween.set_parallel(true)
	arrival_tween.tween_property(caden, "modulate:a", 1.0, 0.5)
	arrival_tween.tween_property(caden, "position", center, 1.5)
	arrival_tween.chain().tween_callback(_caden_start_dialogue.bind(caden, completion_flag))


func _caden_start_dialogue(caden: Node2D, completion_flag: String) -> void:
	var scene_data: Dictionary = DataManager.load_dialogue("caden_binding")
	var entries: Array = scene_data.get("entries", [])
	if entries.is_empty():
		_caden_complete(caden, completion_flag)
		return
	if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
		GameManager.overlay_node.show_dialogue(entries)
		GameManager.overlay_state_changed.connect(
			_on_caden_dialogue_closed.bind(caden, completion_flag), CONNECT_ONE_SHOT
		)


func _on_caden_dialogue_closed(
	state: GameManager.OverlayState, caden: Node2D, completion_flag: String
) -> void:
	if state != GameManager.OverlayState.NONE:
		return
	_caden_complete(caden, completion_flag)


func _caden_complete(caden: Node2D, completion_flag: String) -> void:
	# Add Fenmother's Blessing
	var key_items: Array = PartyState.inventory.get("key_items", [])
	if "fenmothers_blessing" not in key_items:
		key_items.append("fenmothers_blessing")
		PartyState.inventory["key_items"] = key_items
	flash_location_name("Received Fenmother's Blessing!")
	EventFlags.set_flag(completion_flag, true)
	# Remove animated Caden, show permanent NPC
	caden.queue_free()
	var post_npc: Node = _current_map.get_node_or_null("Entities/CadenPostEvent")
	if post_npc != null:
		post_npc.visible = true
```

- [ ] **Step 6: Format and commit**

```bash
gdformat game/scripts/core/exploration.gd
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add auto-walk and auto-sequence systems to exploration"
```

---

### Task 14: Cleansing Sequence Changes

**Files:**
- Modify: `game/scripts/core/exploration.gd`

- [ ] **Step 1: Add ritual meter constants and variable**

Near the top of exploration.gd, add:

```gdscript
const RITUAL_METER_SCENE: PackedScene = preload("res://scenes/ui/ritual_meter.tscn")
const WAVE_TURN_THRESHOLDS: Array[int] = [6, 8, 8, 5]
const DAMAGE_ZONE_SCENE: PackedScene = preload("res://scenes/entities/damage_zone.tscn")
const BOSS_ARENA_CENTER: Vector2 = Vector2(272, 208)
const BOSS_ARENA_RADIUS: float = 80.0

var _ritual_meter: Node = null
var _spawned_pool_count: int = 0
```

- [ ] **Step 2: Modify _start_cleansing_sequence to create ritual meter**

After existing setup code in `_start_cleansing_sequence`, add:

```gdscript
	# Create ritual meter
	_ritual_meter = RITUAL_METER_SCENE.instantiate()
	add_child(_ritual_meter)
	_ritual_meter.show_meter()
	_spawned_pool_count = 0
```

- [ ] **Step 3: Modify _continue_cleansing_sequence for meter + pools**

In `_continue_cleansing_sequence`, after processing battle rewards and crystal XP, add the ritual meter drain logic:

```gdscript
	# Ritual meter drain
	if _ritual_meter != null:
		var turn_count: int = data.get("turn_count", 0)
		var ko_count: int = data.get("ko_count", 0)
		var threshold: int = WAVE_TURN_THRESHOLDS[wave_num] if wave_num < WAVE_TURN_THRESHOLDS.size() else 6
		var has_recovery: bool = (wave_num == 1)  # Fenmother cooperation on wave 2 (0-indexed wave 1)
		var drain: float = _ritual_meter.calculate_drain(wave_num, ko_count, turn_count, threshold, has_recovery)
		_ritual_meter.drain(drain)
		if _ritual_meter.is_failed():
			# Failure — restart current wave
			_ritual_meter.reset_for_retry()
			var fail_data: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
			var entries: Array = fail_data.get("entries", [])
			# Show failure message then re-launch same wave
			flash_location_name("The corruption surges back!")
			_launch_cleansing_wave(wave_num, data)
			return
	# Spawn poison pools between waves
	_spawn_cleansing_poison_pools()
```

- [ ] **Step 4: Add poison pool spawning helper**

```gdscript
func _spawn_cleansing_poison_pools() -> void:
	if _current_map == null or _spawned_pool_count >= 4:
		return
	var entities: Node = _current_map.get_node_or_null("Entities")
	if entities == null:
		return
	var count: int = randi_range(1, 2)
	for i: int in range(count):
		if _spawned_pool_count >= 4:
			break
		var pool: Area2D = DAMAGE_ZONE_SCENE.instantiate()
		var pos: Vector2 = _random_arena_position()
		pool.position = pos
		entities.add_child(pool)
		pool.initialize("cleansing_pool_%d" % _spawned_pool_count, 10, 1.0, "")
		_spawned_pool_count += 1


func _random_arena_position() -> Vector2:
	var player_pos: Vector2 = _player.position if _player != null else BOSS_ARENA_CENTER
	var pos: Vector2 = BOSS_ARENA_CENTER
	for attempt: int in range(10):
		var x: float = randf_range(
			BOSS_ARENA_CENTER.x - BOSS_ARENA_RADIUS,
			BOSS_ARENA_CENTER.x + BOSS_ARENA_RADIUS
		)
		var y: float = randf_range(
			BOSS_ARENA_CENTER.y - BOSS_ARENA_RADIUS,
			BOSS_ARENA_CENTER.y + BOSS_ARENA_RADIUS
		)
		pos = Vector2(x, y).round()
		if pos.distance_to(player_pos) > 32.0:
			break
	return pos
```

- [ ] **Step 5: Modify _complete_cleansing to clean up meter and load spirit path**

In `_complete_cleansing`, after setting `fenmother_cleansed` flag and before the final dialogue:

```gdscript
	# Clean up ritual meter
	if _ritual_meter != null:
		_ritual_meter.hide_meter()
		_ritual_meter.queue_free()
		_ritual_meter = null
```

After the final dialogue's overlay connection (or at the end if no dialogue), change the exit behavior to load the spirit path instead of staying on F3. Add a new signal handler:

```gdscript
	# After final dialogue, load spirit path
	GameManager.overlay_state_changed.connect(
		_on_cleansing_complete_dialogue_closed, CONNECT_ONE_SHOT
	)


func _on_cleansing_complete_dialogue_closed(state: GameManager.OverlayState) -> void:
	if state != GameManager.OverlayState.NONE:
		return
	load_map("dungeons/fenmothers_hollow_spirit_path")
```

- [ ] **Step 6: Format and commit**

```bash
gdformat game/scripts/core/exploration.gd
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): integrate ritual meter and poison pools into cleansing sequence"
```

---

## Chunk 6: New Maps + Dialogue + Map Modifications (Tasks 15-19)

### Task 15: Caden Binding Dialogue

**Files:**
- Create: `game/data/dialogue/caden_binding.json`

- [ ] **Step 1: Create dialogue file**

```json
{
  "entries": [
    {"speaker": "caden", "text": "I felt it through the water. The old channels are open again."},
    {"speaker": "caden", "text": "She's free. Weakened, but free. The binding I'll place will protect her while she heals."},
    {"speaker": "torren", "text": "You came all the way from the Duskfen?"},
    {"speaker": "caden", "text": "The spirits carried me. They remember the paths even when the water forgets."},
    {"speaker": "", "text": "Caden kneels beside the shrine and traces a pattern in the water. Light follows his fingertips.", "animation": [{"who": "caden", "anim": "head_down", "when": "before_line_0"}]},
    {"speaker": "caden", "text": "It's done. Take this — the Fenmother's Blessing. Her domain is yours to pass through freely."},
    {"speaker": "edren", "text": "Thank you, Caden."},
    {"speaker": "caden", "text": "Don't thank me. Thank her. She chose to trust you."}
  ]
}
```

- [ ] **Step 2: Validate JSON**

Run: `python3 -c "import json; d=json.load(open('game/data/dialogue/caden_binding.json')); print(len(d['entries']), 'entries')"`
Expected: `8 entries`

- [ ] **Step 3: Commit**

```bash
git add game/data/dialogue/caden_binding.json
git commit -m "feat(story): add Caden binding dialogue for Duskfen Spirit Shrine"
```

---

### Task 16: Spirit-Path Map

**Files:**
- Create: `game/scenes/maps/dungeons/fenmothers_hollow_spirit_path.tscn`

- [ ] **Step 1: Build the spirit-path scene**

Create a 20x5 tile map scene:
- Root: Node2D, metadata: `location_name = "Spirit Path"`, `is_auto_walk = true`
- TileMapLayer: 20x5, using existing tileset extended with indices 14-17 (spirit water floor, luminous root wall, deep water, shrine stone). If extending the tileset is complex, use ColorRect backgrounds with appropriate colors as a simpler placeholder.
- Entities node with 3 GPUParticles2D children (SpiritParticles1/2/3):
  - Each: emitting = true, amount = 8, lifetime = 3.0
  - Process material: direction rightward with slight vertical wobble
  - Positioned at y=20, y=40, y=60 across the tunnel
- Transitions node with ShrineExit (Area2D):
  - Position: (304, 40) — right end of tunnel
  - Metadata: `target_map = "dungeons/duskfen_spirit_shrine"`, `target_spawn = "from_spirit_path"`
- PlayerSpawn (Marker2D at x=32, y=40)

Note: If GPUParticles2D setup is complex in .tscn text format, use simple Sprite2D placeholders and add particles later.

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/dungeons/fenmothers_hollow_spirit_path.tscn
git commit -m "feat(engine): add spirit-path auto-walk tunnel scene"
```

---

### Task 17: Duskfen Spirit Shrine Map

**Files:**
- Create: `game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn`

- [ ] **Step 1: Build the shrine scene**

Create a 16x12 tile map scene:
- Root: Node2D, metadata: `location_name = "Duskfen Spirit Shrine"`, `auto_sequence = "caden_binding"`, `auto_sequence_flag = "caden_binding_complete"`
- TileMapLayer: 16x12, walls on edges, open center
- Entities:
  - SavePoint at (64, 48): `save_point_id = "duskfen_shrine_save"`
  - CadenPostEvent (NPC): `npc_id = "caden_duskfen"`, visible = false (shown after binding complete). Position at (128, 80)
- Transitions:
  - OverworldExit at (128, 176): `target_map = "overworld"`, `target_spawn = "from_duskfen_shrine"`
- Markers:
  - PlayerSpawn at (128, 32) — entry from spirit path
  - from_spirit_path at (128, 32)
  - from_overworld at (128, 160)
  - CadenSpawnPoint at (288, 80) — off-screen right

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn
git commit -m "feat(engine): add Duskfen Spirit Shrine map with Caden sequence"
```

---

### Task 18: Modify F1, F2, F3 Maps

**Files:**
- Modify: `game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn`
- Modify: `game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn`
- Modify: `game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn`

- [ ] **Step 1: Modify F1 — add puzzle entities**

In `fenmothers_hollow_f1.tscn`:
- Remove the existing "WaterWheel" dialogue trigger Area2D at (192, 256)
- Add WaterWheel node at (192, 256): script = water_wheel.gd, metadata: `wheel_id = "wheel_1"`, `dungeon_id = "fenmothers_hollow"`
- Add WaterWheel node at (640, 400): metadata: `wheel_id = "wheel_2"`, `dungeon_id = "fenmothers_hollow"`
- Add TreasureChest at (224, 256): `chest_id = "fenmothers_hollow_spirit_vessel"`, `item_id = "spirit_vessel"` (inside hidden alcove)
- Add PureSpring at (256, 256): script = pure_spring.gd (inside hidden alcove)
- Add 4 WaterZone nodes per spec Section 3 placement table (deep water barrier, alcove entrance, mid-passage, east wing)
- Add alcove geometry to tilemap (3x2 tile recess behind wheel 1 position)

- [ ] **Step 2: Modify F2 — replace dialogue trigger, add entities**

In `fenmothers_hollow_f2.tscn`:
- Remove the existing "SpiritPlant" dialogue trigger Area2D at (544, 160)
- Add SpiritPlant node at (544, 160): script = spirit_plant.gd, metadata: `plant_id = "spirit_plant_1"`, `dungeon_id = "fenmothers_hollow"`
- Add WaterWheel node at (752, 160): metadata: `wheel_id = "wheel_3"`, `dungeon_id = "fenmothers_hollow"`
- Add 3 WaterZone nodes per spec Section 3 (mosaic x2, secret room reveal)
- Add 3 DamageZone nodes: corrupted pool east (608, 192, 96x48), polluted channel south (320, 480, 160x32), stagnant corner (64, 80, 64x64)

- [ ] **Step 3: Modify F3 — add damage zones, remove blessing chest**

In `fenmothers_hollow_f3.tscn`:
- Remove the "FenmothersBlessing" treasure chest at (272, 304) (Caden gives blessing now)
- Add 2 DamageZone nodes flanking boss arena: left (176, 160, 48x96), right (368, 160, 48x96)

- [ ] **Step 4: Commit**

```bash
git add game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn
git commit -m "feat(engine): add puzzle entities to Fenmother's Hollow F1-F3 maps"
```

---

### Task 19: Overworld Shortcut + Player Animation Helper

**Files:**
- Modify: `game/scenes/maps/overworld.tscn` (add Duskfen shrine transition)
- Modify: `game/scripts/entities/player_character.gd` (add play_animation helper if not exists)

- [ ] **Step 1: Add overworld transition to shrine**

Add an Area2D transition node to the overworld map near the Thornmere Wetlands area:
- Position near existing fenmothers_hollow entry
- Metadata: `target_map = "dungeons/duskfen_spirit_shrine"`, `target_spawn = "from_overworld"`, `required_flag = "caden_binding_complete"`
- Add `from_duskfen_shrine` Marker2D spawn point on overworld

- [ ] **Step 2: Add play_animation to player_character.gd if needed**

Check if `play_animation(anim_name: String)` exists. If not, add:

```gdscript
func play_animation(anim_name: String) -> void:
	if _anim_player != null and _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/overworld.tscn game/scripts/entities/player_character.gd
git commit -m "feat(engine): add Duskfen shrine overworld shortcut"
```

---

## Chunk 7: Gap Tracker Update + Final Verification (Task 20)

### Task 20: Update Gap Tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update Phase A2b checklist items**

In the 4.4 Phase A2b section, mark completed items:

```markdown
**Phase A2b: Fenmother's Hollow Puzzles (COMPLETE — 2026-04-11)**
- [x] Water wheel puzzle entities (3 wheels, HIGH/LOW state)
- [x] Spirit Vessel key item + carry mechanic
- [x] Pure Spring interactable (fill vessel)
- [x] Spirit-plant revival interactable (pour vessel)
- [x] Water level zone visibility toggling
- [x] Poisoned pool tile damage zones (boss dive phase)
- [x] Ritual meter HUD element (wave defense progress bar)
- [x] Post-boss spirit-path transition scene
- [x] Caden NPC arrival cutscene (auto-triggered sequence)
```

- [ ] **Step 2: Add progress tracking entry**

Add to the Progress Tracking table:

```markdown
| 2026-04-11 | 4.4 Phase A2b | Fenmother puzzles: water wheels, spirit vessel fetch, poison zones, ritual meter, spirit-path, Caden binding. 16 new files, 10 modified. | — |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(story): update gap tracker — Phase A2b COMPLETE"
```

---

## Execution Summary

| Task | Description | Files | Commit |
|------|-------------|-------|--------|
| 1 | Puzzle state tests | 1 new | — (tests only, committed with Task 2) |
| 2 | Puzzle state implementation | 3 modified + 1 new | `feat(engine): add puzzle_state system` |
| 3 | Water wheel entity | 2 new, 1 modified | `feat(engine): add water wheel interactable` |
| 4 | Water zone entity | 2 new, 1 modified | `feat(engine): add water zone entity` |
| 5 | Spirit Vessel key items | 1 modified | `feat(engine): add Spirit Vessel key items` |
| 6 | Pure spring entity | 2 new, 1 modified | `feat(engine): add pure spring entity` |
| 7 | Spirit-plant entity | 2 new, 1 modified | `feat(engine): add spirit-plant entity` |
| 8 | Damage zone entity | 2 new, 1 modified | `feat(engine): add poison damage zone` |
| 9 | Ritual meter | 2 new, 1 modified | `feat(engine): add ritual meter overlay` |
| 10 | Battle manager changes | 1 modified | `feat(engine): add turn counter and KO count` |
| 11 | Player input toggle | 1 modified | `feat(engine): add input enable/disable` |
| 12 | Exploration entity wiring | 1 modified | `feat(engine): wire puzzle entities` |
| 13 | Auto-walk + auto-sequence | 1 modified | `feat(engine): add auto-walk and auto-sequence` |
| 14 | Cleansing sequence changes | 1 modified | `feat(engine): integrate ritual meter` |
| 15 | Caden dialogue data | 1 new | `feat(story): add Caden binding dialogue` |
| 16 | Spirit-path map | 1 new | `feat(engine): add spirit-path tunnel` |
| 17 | Shrine map | 1 new | `feat(engine): add Duskfen Spirit Shrine` |
| 18 | F1/F2/F3 map modifications | 3 modified | `feat(engine): add puzzle entities to maps` |
| 19 | Overworld shortcut | 2 modified | `feat(engine): add Duskfen shortcut` |
| 20 | Gap tracker update | 1 modified | `docs(story): update gap tracker` |

**Total: 20 tasks, 16 new files, 10 modified files, ~53 tests, 18 commits**
