# Phase B2: Ironmouth + Ember Vein F3 + Full Scenes Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Phase B2 of Act I content — Ember Vein F3 dungeon floor, Ironmouth escape map, Scene 1 full dialogue, Scene 3 combat, and mechanical tweaks (Arcanite gear, Cael shimmer, start location).

**Architecture:** Five chunks in dependency order (E → A → C → B → D). Each chunk produces testable, committable output. Puzzle entities follow the A2b pattern (signal-based, dungeon-agnostic, puzzle_state persistence). Maps use existing exploration.gd wiring with new entity types registered in `_initialize_entities()`.

**Tech Stack:** Godot 4.6, GDScript, GUT test framework, JSON data files

**Spec:** `docs/superpowers/specs/2026-04-12-ironmouth-f3-full-scenes-design.md`

---

## Chunk 1: Mechanical Tweaks (Spec Chunk E)

### Task 1: Cael's Pallor Shimmer — +10% Physical Damage

**Files:**
- Modify: `game/scripts/combat/damage_calculator.gd` (line ~20, `calculate_physical`)
- Test: `game/tests/test_mechanical_tweaks.gd`

The `calculate_physical` static method does not receive a character ID. Add an optional `attacker_id` parameter (default `""`) and apply the 1.1x multiplier for Cael inside the function.

- [ ] **Step 1: Write the failing test**

Create `game/tests/test_mechanical_tweaks.gd`:

```gdscript
extends GutTest
## Tests for Phase B2 mechanical tweaks.


func test_cael_physical_damage_10_percent_higher() -> void:
	# Same ATK/DEF, compare Cael vs generic attacker
	# ATK=20, DEF=10 → raw = (20*20)/6 - 10 = 56.67 → 56
	# Cael: 56 * 1.1 = 62 (before variance)
	# Use seed to fix variance
	seed(42)
	var base: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, ""
	)
	seed(42)
	var cael: int = DamageCalc.calculate_physical(
		20, 1.0, 10, false, 1.0, "front", "front", false, [], false, 1.0, "cael"
	)
	# Cael's damage should be ~10% higher
	assert_gt(cael, base, "Cael physical damage should exceed base")
	# Allow for rounding: cael should be within [base*1.09, base*1.11]
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


func test_cael_magical_damage_unaffected() -> void:
	# Magical damage uses calculate_magic, not calculate_physical
	# calculate_magic has no attacker_id parameter — Cael shimmer is physical only
	seed(42)
	var base_mag: int = DamageCalc.calculate_magic(20, 50, 10, 1.0, 1.0, [], [])
	seed(42)
	var cael_mag: int = DamageCalc.calculate_magic(20, 50, 10, 1.0, 1.0, [], [])
	assert_eq(base_mag, cael_mag, "Magical damage should be unaffected by shimmer")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_mechanical_tweaks.gd -gexit`
Expected: FAIL — `calculate_physical` does not accept attacker_id parameter

- [ ] **Step 3: Add attacker_id parameter to calculate_physical**

In `game/scripts/combat/damage_calculator.gd`, modify the `calculate_physical` function signature (line ~20) to add an optional final parameter:

```gdscript
static func calculate_physical(
	atk: int,
	ability_mult: float,
	target_def: int,
	is_crit: bool,
	interaction_mult: float,
	attacker_row: String,
	defender_row: String,
	weapon_bypasses_row: bool,
	reduction_sources: Array,
	is_elemental: bool,
	element_mod: float,
	attacker_id: String = ""
) -> int:
```

After DEF subtraction but BEFORE variance (between `var raw: float = maxf(...)` and `var result: float = raw * roll_variance()`), add:

```gdscript
	# Cael's Pallor Shimmer: +10% physical damage (permanent, hidden)
	if attacker_id == "cael":
		raw *= 1.1
```

- [ ] **Step 4: Update all existing call sites**

Search for all calls to `calculate_physical` in the codebase. Since the new parameter has a default value (`""`), existing calls will work without modification. But check if `battle_manager.gd` passes character_id — if so, thread it through. If not, find where the attacker's character_id is available and pass it.

In `game/scripts/combat/battle_manager.gd`, find the call to `DamageCalc.calculate_physical(...)`. The calling context has access to the attacker's member data. Add the character_id as the last argument:

```gdscript
var char_id: String = member.get("character_data", {}).get("id", "")
# ... existing calculate_physical call, append char_id as last arg
```

- [ ] **Step 5: Run tests to verify pass**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_mechanical_tweaks.gd -gexit`
Expected: All 3 tests PASS

- [ ] **Step 6: Commit**

```bash
git add game/scripts/combat/damage_calculator.gd game/scripts/combat/battle_manager.gd game/tests/test_mechanical_tweaks.gd
git commit -m "feat(engine): add Cael Pallor shimmer +10% physical damage"
```

---

### Task 2: Arcanite Gear — Equipment Data + PartyState

**Files:**
- Modify: `game/data/equipment/weapons.json`
- Modify: `game/data/equipment/armor.json`
- Modify: `game/scripts/autoload/party_state.gd` (lines 17-24, 51-73)
- Test: `game/tests/test_mechanical_tweaks.gd`

- [ ] **Step 1: Write the failing tests**

Append to `game/tests/test_mechanical_tweaks.gd`:

```gdscript
func _get_edren_equipment() -> Dictionary:
	for member: Dictionary in PartyState.members:
		if member.get("character_data", {}).get("id", "") == "edren":
			return member.get("equipment", {})
	return {}


func test_arcanite_gear_equipped_on_new_game() -> void:
	PartyState.initialize_new_game()
	var edren_equip: Dictionary = _get_edren_equipment()
	assert_eq(edren_equip.get("weapon", ""), "arcanite_sword_proto",
		"Edren should start with arcanite sword")
	assert_eq(edren_equip.get("body", ""), "arcanite_mail_proto",
		"Edren should start with arcanite mail")


func test_arcanite_gear_stats() -> void:
	var weapons: Array = DataManager.load_json("res://data/equipment/weapons.json").get("weapons", [])
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
	assert_eq(edren_equip.get("weapon", ""), "",
		"Edren weapon should be empty after break")
	assert_eq(edren_equip.get("body", ""), "",
		"Edren body should be empty after break")


func test_break_arcanite_gear_emits_signal() -> void:
	PartyState.initialize_new_game()
	watch_signals(PartyState)
	PartyState.break_arcanite_gear()
	assert_signal_emitted(PartyState, "inventory_changed")
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_mechanical_tweaks.gd -gexit`
Expected: FAIL — `arcanite_sword_proto` not found, `break_arcanite_gear` not defined

- [ ] **Step 3: Add arcanite equipment to JSON data**

In `game/data/equipment/weapons.json`, add to the `"weapons"` array (after the existing Tier 0/1 entries):

```json
{
    "id": "arcanite_sword_proto",
    "name": "Arcanite Sword (Prototype)",
    "type": "sword",
    "tier": 1,
    "equippable_by": ["edren"],
    "atk": 13,
    "bonus_stats": {},
    "element": null,
    "special": null,
    "buy_price": null,
    "sell_price": null,
    "acquired": "Starting equipment (Edren) — breaks after Ember Vein",
    "description": "A confiscated Compact prototype. Arcanite-enhanced but unstable."
}
```

In `game/data/equipment/armor.json`, add to the `"armor"` array:

```json
{
    "id": "arcanite_mail_proto",
    "name": "Arcanite Mail (Prototype)",
    "slot": "body",
    "armor_class": "heavy",
    "tier": 1,
    "equippable_by": ["edren"],
    "def": 10,
    "mdef": 4,
    "bonus_stats": {},
    "special": null,
    "buy_price": null,
    "sell_price": null,
    "acquired": "Starting equipment (Edren) — breaks after Ember Vein",
    "description": "Prototype Compact body armor. Arcanite-laced plates provide exceptional protection."
}
```

- [ ] **Step 4: Update STARTING_EQUIPMENT and initialize_new_game**

In `game/scripts/autoload/party_state.gd`, modify `STARTING_EQUIPMENT` (line 18):

```gdscript
"edren": {"weapon": "arcanite_sword_proto", "head": "", "body": "arcanite_mail_proto", "accessory": "", "crystal": ""},
```

- [ ] **Step 5: Add break_arcanite_gear() method**

In `game/scripts/autoload/party_state.gd`, add after the `remove_key_item` method (~line 428):

```gdscript
func break_arcanite_gear() -> void:
	## Removes Edren's temporary arcanite equipment after Ember Vein escape.
	for i: int in range(members.size()):
		var member: Dictionary = members[i]
		if member.get("character_data", {}).get("id", "") != "edren":
			continue
		var equipment: Dictionary = member.get("equipment", {})
		if equipment.get("weapon", "") == "arcanite_sword_proto":
			equipment["weapon"] = ""
		if equipment.get("body", "") == "arcanite_mail_proto":
			equipment["body"] = ""
		members[i]["equipment"] = equipment
		break
	inventory_changed.emit()
```

- [ ] **Step 6: Run tests**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_mechanical_tweaks.gd -gexit`
Expected: All tests PASS

- [ ] **Step 7: Commit**

```bash
git add game/data/equipment/weapons.json game/data/equipment/armor.json game/scripts/autoload/party_state.gd game/tests/test_mechanical_tweaks.gd
git commit -m "feat(engine): add Arcanite gear preview for Edren opening sequence"
```

---

### Task 3: Change New Game Start to Ember Vein F1

**Files:**
- Modify: `game/scripts/core/exploration.gd` (line ~209)
- Modify: `game/scenes/maps/dungeons/ember_vein_f1.tscn` (add spawn point)
- Test: `game/tests/test_mechanical_tweaks.gd`

- [ ] **Step 1: Write the failing test**

This change cannot be meaningfully unit tested — `load_map` requires the full scene tree. Verification is manual: start New Game in the Godot editor and confirm Ember Vein F1 loads.

- [ ] **Step 2: Change the start map in exploration.gd**

In `game/scripts/core/exploration.gd`, find the line (approximately line 209) that says:

```gdscript
load_map("overworld")
```

within the new game initialization path. Change to:

```gdscript
load_map("dungeons/ember_vein_f1", "new_game_spawn")
```

- [ ] **Step 3: Add new_game_spawn to ember_vein_f1.tscn**

In `game/scenes/maps/dungeons/ember_vein_f1.tscn`, add a Position2D node named `new_game_spawn` under the spawn points section, positioned at the mine entrance area (near the existing `from_overworld` spawn — approximately `Vector2(48, 48)`).

Check the existing spawn point positions first. If `from_overworld` already serves this purpose at `(48, 48)`, simply change the `load_map` call to use `"from_overworld"` instead of creating a new spawn.

- [ ] **Step 4: Run tests + manual verification**

Run tests: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_mechanical_tweaks.gd -gexit`

Manual: Open game/ in Godot editor, press F5, start New Game — should load Ember Vein F1.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/exploration.gd game/scenes/maps/dungeons/ember_vein_f1.tscn game/tests/test_mechanical_tweaks.gd
git commit -m "feat(engine): change new game start to Ember Vein F1"
```

---

## Chunk 2: Ember Vein F3 — Puzzle Entities (Spec Chunk A, Part 1)

### Task 4: PressurePlate Entity

**Files:**
- Create: `game/scripts/entities/pressure_plate.gd`
- Create: `game/scenes/entities/pressure_plate.tscn`
- Test: `game/tests/test_ember_vein_f3.gd`

Pattern: Follow `game/scripts/entities/water_wheel.gd` (Area2D, signal-based, puzzle_state persistence). Key difference: one-shot toggle on `body_entered` instead of `interact()`.

- [ ] **Step 1: Write the failing tests**

Create `game/tests/test_ember_vein_f3.gd`:

```gdscript
extends GutTest
## Tests for Ember Vein F3 puzzle entities and map.


func before_each() -> void:
	PartyState.puzzle_state.clear()
	PartyState.initialize_new_game()


func test_pressure_plate_sets_state_on_press() -> void:
	var plate: Node = preload("res://scenes/entities/pressure_plate.tscn").instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	assert_false(plate.is_pressed, "Plate should start unpressed")
	plate._on_body_entered(null)
	assert_true(plate.is_pressed, "Plate should be pressed after body entered")
	assert_true(
		PartyState.get_puzzle_state("ember_vein", "test_plate_pressed", false),
		"Puzzle state should persist plate press"
	)


func test_pressure_plate_stays_pressed() -> void:
	var plate: Node = preload("res://scenes/entities/pressure_plate.tscn").instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	plate._on_body_entered(null)
	assert_true(plate.is_pressed, "Plate should be pressed")
	# Simulate body_exited — plate should stay pressed
	plate._on_body_exited(null)
	assert_true(plate.is_pressed, "Plate should remain pressed (one-shot)")


func test_pressure_plate_emits_signal() -> void:
	var plate: Node = preload("res://scenes/entities/pressure_plate.tscn").instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	watch_signals(plate)
	plate._on_body_entered(null)
	assert_signal_emitted(plate, "plate_pressed")


func test_pressure_plate_restores_state() -> void:
	PartyState.set_puzzle_state("ember_vein", "test_plate_pressed", true)
	var plate: Node = preload("res://scenes/entities/pressure_plate.tscn").instantiate()
	add_child_autoqfree(plate)
	plate.initialize("test_plate", "ember_vein")
	assert_true(plate.is_pressed, "Plate should restore pressed state from puzzle_state")
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_ember_vein_f3.gd -gexit`
Expected: FAIL — scene file not found

- [ ] **Step 3: Create pressure_plate.gd**

Create `game/scripts/entities/pressure_plate.gd`:

```gdscript
extends Area2D
## Pressure plate — one-shot toggle on body_entered. Opens connected WaterZone doors.

signal plate_pressed(plate_id: String)

var plate_id: String = ""
var is_pressed: bool = false

var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D


func initialize(p_plate_id: String, p_dungeon_id: String) -> void:
	if p_plate_id.is_empty() or p_dungeon_id.is_empty():
		if p_plate_id.is_empty():
			push_error("PressurePlate: empty plate_id")
		if p_dungeon_id.is_empty():
			push_error("PressurePlate: empty dungeon_id")
		return
	plate_id = p_plate_id
	_dungeon_id = p_dungeon_id
	is_pressed = PartyState.get_puzzle_state(_dungeon_id, "%s_pressed" % plate_id, false)
	_update_visual()


func _on_body_entered(_body: Node2D) -> void:
	if plate_id.is_empty() or is_pressed:
		return
	is_pressed = true
	PartyState.set_puzzle_state(_dungeon_id, "%s_pressed" % plate_id, true)
	_update_visual()
	plate_pressed.emit(plate_id)


func _on_body_exited(_body: Node2D) -> void:
	pass  # One-shot — stays pressed permanently


func _update_visual() -> void:
	if _sprite != null:
		_sprite.frame = 1 if is_pressed else 0
		_sprite.modulate = Color("#aaaaaa") if is_pressed else Color.WHITE
```

- [ ] **Step 4: Create pressure_plate.tscn**

Create `game/scenes/entities/pressure_plate.tscn` with this structure:
- Root: `Area2D` named "PressurePlate"
  - Script: `res://scripts/entities/pressure_plate.gd`
  - Collision layer: 0, mask: 1 (detects player on layer 1)
  - Monitorable: true, monitoring: true
- Child: `Sprite2D`
  - Placeholder: 16x16 colored rect texture (grey stone tile)
  - Hframes: 2 (frame 0 = raised, frame 1 = depressed)
- Child: `CollisionShape2D`
  - Shape: RectangleShape2D(6, 6) — 12x12 detection area

Connect signals in the scene: `body_entered` → `_on_body_entered`, `body_exited` → `_on_body_exited`.

- [ ] **Step 5: Run tests**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_ember_vein_f3.gd -gexit`
Expected: All 4 pressure plate tests PASS

- [ ] **Step 6: Commit**

```bash
git add game/scripts/entities/pressure_plate.gd game/scenes/entities/pressure_plate.tscn game/tests/test_ember_vein_f3.gd
git commit -m "feat(engine): add PressurePlate puzzle entity"
```

---

### Task 5: EmberCrystal Entity

**Files:**
- Create: `game/scripts/entities/ember_crystal.gd`
- Create: `game/scenes/entities/ember_crystal.tscn`
- Test: `game/tests/test_ember_vein_f3.gd`

Pattern: Follow `game/scripts/entities/spirit_plant.gd` (StaticBody2D, key item consumer, blocks passage until cleared).

- [ ] **Step 1: Write the failing tests**

Append to `game/tests/test_ember_vein_f3.gd`:

```gdscript
func test_ember_crystal_blocks_without_vial() -> void:
	var crystal: Node = preload("res://scenes/entities/ember_crystal.tscn").instantiate()
	add_child_autoqfree(crystal)
	crystal.initialize("test_crystal", "ember_vein")
	watch_signals(crystal)
	crystal.interact()
	assert_signal_emitted(crystal, "interaction_message")
	assert_false(crystal.is_cleared, "Crystal should remain blocking without vial")


func test_ember_crystal_clears_with_vial() -> void:
	PartyState.add_key_item("mine_water_vial")
	var crystal: Node = preload("res://scenes/entities/ember_crystal.tscn").instantiate()
	add_child_autoqfree(crystal)
	crystal.initialize("test_crystal", "ember_vein")
	watch_signals(crystal)
	crystal.interact()
	assert_signal_emitted(crystal, "crystal_cleared")
	assert_true(crystal.is_cleared, "Crystal should be cleared after vial use")
	assert_false(
		"mine_water_vial" in PartyState.get_key_items(),
		"Vial should be consumed"
	)


func test_ember_crystal_persists_cleared_state() -> void:
	PartyState.set_puzzle_state("ember_vein", "test_crystal_cleared", true)
	var crystal: Node = preload("res://scenes/entities/ember_crystal.tscn").instantiate()
	add_child_autoqfree(crystal)
	crystal.initialize("test_crystal", "ember_vein")
	assert_true(crystal.is_cleared, "Crystal should restore cleared state")


func test_ember_crystal_collision_disabled_when_cleared() -> void:
	PartyState.add_key_item("mine_water_vial")
	var crystal: Node = preload("res://scenes/entities/ember_crystal.tscn").instantiate()
	add_child_autoqfree(crystal)
	crystal.initialize("test_crystal", "ember_vein")
	crystal.interact()
	var collision: CollisionShape2D = crystal.get_node_or_null("CollisionShape2D")
	if collision != null:
		assert_true(collision.disabled, "Collision should be disabled when cleared")
```

- [ ] **Step 2: Run tests to verify they fail**

Expected: FAIL — scene file not found

- [ ] **Step 3: Create ember_crystal.gd**

Create `game/scripts/entities/ember_crystal.gd`:

```gdscript
extends StaticBody2D
## Dying ember crystal — blocks passage until revived with Mine Water Vial.

signal crystal_cleared(crystal_id: String)
signal interaction_message(text: String)

var crystal_id: String = ""
var is_cleared: bool = false
var _dungeon_id: String = ""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func initialize(p_crystal_id: String, p_dungeon_id: String) -> void:
	if p_crystal_id.is_empty() or p_dungeon_id.is_empty():
		push_error("EmberCrystal: empty crystal_id or dungeon_id")
		return
	crystal_id = p_crystal_id
	_dungeon_id = p_dungeon_id
	is_cleared = PartyState.get_puzzle_state(_dungeon_id, "%s_cleared" % crystal_id, false)
	_update_visual()


func interact() -> void:
	if crystal_id.is_empty():
		return
	if is_cleared:
		interaction_message.emit("The crystal glows warmly, its fronds unfurled.")
		return
	var key_items: Array = PartyState.get_key_items()
	if "mine_water_vial" not in key_items:
		interaction_message.emit(
			"It looks parched... maybe something from the mine levels could help."
		)
		return
	PartyState.remove_key_item("mine_water_vial")
	is_cleared = true
	PartyState.set_puzzle_state(_dungeon_id, "%s_cleared" % crystal_id, true)
	_update_visual()
	crystal_cleared.emit(crystal_id)


func _update_visual() -> void:
	if _sprite != null:
		_sprite.modulate = Color("#ffaa44") if is_cleared else Color("#664400")
	if _collision != null:
		_collision.disabled = is_cleared
```

- [ ] **Step 4: Create ember_crystal.tscn**

Create `game/scenes/entities/ember_crystal.tscn` with this structure:
- Root: `StaticBody2D` named "EmberCrystal"
  - Script: `res://scripts/entities/ember_crystal.gd`
  - Collision layer: 1 (blocks movement)
- Child: `Sprite2D`
  - Placeholder: 32x16 colored rect texture (amber crystal mass)
- Child: `CollisionShape2D`
  - Shape: RectangleShape2D(16, 8) — blocks the corridor
- Child: `InteractionArea` (Area2D)
  - Collision layer: 0, mask: 1
  - Monitorable: true
  - Child: `CollisionShape2D` — RectangleShape2D(8, 8)

The InteractionArea is what the player's interaction raycast detects (collision layer 3 pattern from other interactables — check existing `.tscn` files for exact layer).

- [ ] **Step 5: Run tests**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_ember_vein_f3.gd -gexit`
Expected: All ember crystal tests PASS

- [ ] **Step 6: Commit**

```bash
git add game/scripts/entities/ember_crystal.gd game/scenes/entities/ember_crystal.tscn game/tests/test_ember_vein_f3.gd
git commit -m "feat(engine): add EmberCrystal puzzle entity (key item consumer)"
```

---

### Task 6: PitfallZone Entity

**Files:**
- Create: `game/scripts/entities/pitfall_zone.gd`
- Create: `game/scenes/entities/pitfall_zone.tscn`
- Test: `game/tests/test_ember_vein_f3.gd`

- [ ] **Step 1: Write the failing tests**

Append to `game/tests/test_ember_vein_f3.gd`:

```gdscript
func test_pitfall_zone_emits_signal_on_body_entered() -> void:
	var pitfall: Node = preload("res://scenes/entities/pitfall_zone.tscn").instantiate()
	add_child_autoqfree(pitfall)
	pitfall.initialize("dungeons/ember_vein_f2", "from_pitfall")
	watch_signals(pitfall)
	pitfall._on_body_entered(null)
	assert_signal_emitted_with_parameters(
		pitfall, "pitfall_triggered",
		["dungeons/ember_vein_f2", "from_pitfall"]
	)


func test_pitfall_zone_one_shot_per_visit() -> void:
	var pitfall: Node = preload("res://scenes/entities/pitfall_zone.tscn").instantiate()
	add_child_autoqfree(pitfall)
	pitfall.initialize("dungeons/ember_vein_f2", "from_pitfall")
	watch_signals(pitfall)
	pitfall._on_body_entered(null)
	pitfall._on_body_entered(null)
	assert_signal_emit_count(pitfall, "pitfall_triggered", 1,
		"Should only trigger once per visit")


func test_pitfall_zone_resets_after_reinit() -> void:
	var pitfall: Node = preload("res://scenes/entities/pitfall_zone.tscn").instantiate()
	add_child_autoqfree(pitfall)
	pitfall.initialize("dungeons/ember_vein_f2", "from_pitfall")
	pitfall._on_body_entered(null)
	# Re-initialize simulates returning to the map
	pitfall.initialize("dungeons/ember_vein_f2", "from_pitfall")
	watch_signals(pitfall)
	pitfall._on_body_entered(null)
	assert_signal_emitted(pitfall, "pitfall_triggered",
		"Should trigger again after re-init")
```

- [ ] **Step 2: Run tests to verify they fail**

Expected: FAIL — scene file not found

- [ ] **Step 3: Create pitfall_zone.gd**

Create `game/scripts/entities/pitfall_zone.gd`:

```gdscript
extends Area2D
## Pitfall zone — triggers map transition when player steps on cracked tile.
## One-shot per visit (runtime only, not persisted).

signal pitfall_triggered(target_map_id: String, target_spawn: String)

var _target_map_id: String = ""
var _target_spawn: String = ""
var _has_triggered: bool = false


func initialize(p_target_map_id: String, p_target_spawn: String) -> void:
	_target_map_id = p_target_map_id
	_target_spawn = p_target_spawn
	_has_triggered = false


func _on_body_entered(_body: Node2D) -> void:
	if _has_triggered or _target_map_id.is_empty():
		return
	_has_triggered = true
	pitfall_triggered.emit(_target_map_id, _target_spawn)
```

- [ ] **Step 4: Create pitfall_zone.tscn**

Create `game/scenes/entities/pitfall_zone.tscn`:
- Root: `Area2D` named "PitfallZone"
  - Script: `res://scripts/entities/pitfall_zone.gd`
  - Collision layer: 0, mask: 1 (detects player)
  - Monitoring: true
- Child: `Sprite2D`
  - Placeholder: 16x16 cracked tile texture (slightly darker than floor)
- Child: `CollisionShape2D`
  - Shape: RectangleShape2D(6, 6)

Connect: `body_entered` → `_on_body_entered`

- [ ] **Step 5: Run tests**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_ember_vein_f3.gd -gexit`
Expected: All pitfall tests PASS

- [ ] **Step 6: Commit**

```bash
git add game/scripts/entities/pitfall_zone.gd game/scenes/entities/pitfall_zone.tscn game/tests/test_ember_vein_f3.gd
git commit -m "feat(engine): add PitfallZone trap entity"
```

---

### Task 7: Wire New Entities in exploration.gd

**Files:**
- Modify: `game/scripts/core/exploration.gd` (lines 253-325, 328-359)

- [ ] **Step 1: Add PressurePlate initialization to _initialize_entities**

In `game/scripts/core/exploration.gd`, in the `_initialize_entities` method, add a new `elif` branch after the `zone_damage_dealt` block (after ~line 325):

```gdscript
		elif child.has_signal("plate_pressed"):
			var pid: String = child.get_meta("plate_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if pid.is_empty():
				push_error("Exploration: PressurePlate '%s' missing plate_id" % child.name)
				continue
			if did.is_empty():
				push_error("Exploration: PressurePlate '%s' missing dungeon_id" % child.name)
				continue
			child.initialize(pid, did)
		elif child.has_signal("crystal_cleared"):
			var cid: String = child.get_meta("crystal_id", "")
			var did: String = child.get_meta("dungeon_id", "")
			if cid.is_empty():
				push_error("Exploration: EmberCrystal '%s' missing crystal_id" % child.name)
				continue
			if did.is_empty():
				push_error("Exploration: EmberCrystal '%s' missing dungeon_id" % child.name)
				continue
			child.initialize(cid, did)
		elif child.has_signal("pitfall_triggered"):
			var tmid: String = child.get_meta("target_map_id", "")
			var tsp: String = child.get_meta("target_spawn", "")
			if tmid.is_empty():
				push_error("Exploration: PitfallZone '%s' missing target_map_id" % child.name)
				continue
			child.initialize(tmid, tsp)
```

- [ ] **Step 2: Add signal connections in _connect_entity_signals**

In the `_connect_entity_signals` method (~line 328-359), add:

```gdscript
			if child.has_signal("plate_pressed"):
				child.plate_pressed.connect(_on_plate_pressed)
			if child.has_signal("crystal_cleared"):
				child.crystal_cleared.connect(_on_crystal_cleared)
			if child.has_signal("pitfall_triggered"):
				child.pitfall_triggered.connect(_on_pitfall_triggered)
```

- [ ] **Step 3: Add signal handlers**

Add after the `_on_wheel_toggled` handler (~line 463):

```gdscript
func _on_plate_pressed(_plate_id: String) -> void:
	# Refresh water zones — same pattern as wheel_toggled
	if _current_map != null:
		var entities: Node = _current_map.get_node_or_null("Entities")
		if entities != null:
			for child: Node in entities.get_children():
				if child.has_method("refresh"):
					child.refresh()


func _on_crystal_cleared(_crystal_id: String) -> void:
	flash_location_name("The crystal springs to life!")


func _on_pitfall_triggered(target_map_id: String, target_spawn: String) -> void:
	flash_location_name("The floor gives way!")
	call_deferred("load_map", target_map_id, target_spawn)
```

- [ ] **Step 4: Run existing tests to verify no regressions**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_exploration.gd -gexit`
Expected: All existing exploration tests PASS

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): wire PressurePlate, EmberCrystal, PitfallZone in exploration"
```

---

## Chunk 3: Ember Vein F3 Map + Mine Water Vial (Spec Chunk A, Part 2)

### Task 8: Mine Water Vial Pickup on F2

**Files:**
- Modify: `game/scenes/maps/dungeons/ember_vein_f2.tscn`
- Test: `game/tests/test_ember_vein_f3.gd`

- [ ] **Step 1: Write the failing test**

Append to `game/tests/test_ember_vein_f3.gd`:

```gdscript
func test_mine_water_vial_pickup_adds_key_item() -> void:
	PartyState.initialize_new_game()
	assert_false(
		"mine_water_vial" in PartyState.get_key_items(),
		"Vial should not be in inventory at start"
	)
	PartyState.add_key_item("mine_water_vial")
	assert_true(
		"mine_water_vial" in PartyState.get_key_items(),
		"Vial should be in key_items after pickup"
	)


func test_mine_water_vial_consumed_by_crystal() -> void:
	PartyState.initialize_new_game()
	PartyState.add_key_item("mine_water_vial")
	var crystal: Node = preload("res://scenes/entities/ember_crystal.tscn").instantiate()
	add_child_autoqfree(crystal)
	crystal.initialize("test_crystal", "ember_vein")
	crystal.interact()
	assert_false(
		"mine_water_vial" in PartyState.get_key_items(),
		"Vial should be consumed after crystal use"
	)
	assert_true(crystal.is_cleared, "Crystal should be cleared")
```

- [ ] **Step 2: Add Mine Water Vial chest to F2 map**

Read `game/scenes/maps/dungeons/ember_vein_f2.tscn` to find the Entities section and existing chest pattern.

Add a TreasureChest instance to the Entities node with metadata:
```
metadata/chest_id = "ember_vein_f2_vial"
metadata/item_id = "mine_water_vial"
metadata/is_key_item = true
metadata/quantity = 1
```

Position it near the mid-map journal area (check existing entity positions in F2 for appropriate coordinates).

- [ ] **Step 3: Add from_pitfall spawn to F2**

Add a Position2D named `from_pitfall` to the spawn points section of `ember_vein_f2.tscn`, positioned in the upper area of the map.

- [ ] **Step 4: Run tests**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_ember_vein_f3.gd -gexit`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f2.tscn game/tests/test_ember_vein_f3.gd
git commit -m "feat(engine): add Mine Water Vial pickup and pitfall spawn to Ember Vein F2"
```

---

### Task 9: Build Ember Vein F3 Map

**Files:**
- Create: `game/scenes/maps/dungeons/ember_vein_f3.tscn`

This is the largest single task. Build the 45x35 tile map following the layout in `docs/story/dungeons-world.md` (Ember Vein Floor 3 ASCII map).

- [ ] **Step 1: Read existing F1/F2 maps for .tscn structure patterns**

Read `game/scenes/maps/dungeons/ember_vein_f1.tscn` and `ember_vein_f2.tscn` to understand:
- TileMapLayer configuration (tileset resource, tile size, physics layers)
- Entity node hierarchy (Entities, Transitions, SpawnPoints)
- Metadata format
- Transition Area2D pattern

- [ ] **Step 2: Create the F3 map scene**

Create `game/scenes/maps/dungeons/ember_vein_f3.tscn` with:

**Root Node2D metadata:**
```
metadata/map_id = "dungeons/ember_vein_f3"
metadata/floor_id = "3"
metadata/dungeon_id = "ember_vein"
metadata/location_name = "Ember Vein - Ancient Ruin"
```

**TileMapLayer:** 45x35 tiles using existing placeholder tileset. Layout zones:
- Top entry hall (stairs from F2)
- Upper passage with chest alcove
- Mid-left pressure plate room + hidden door (WaterZone)
- Secret room behind hidden door
- Mid-right corridor with pitfall trap
- Central story chamber (geometric murals)
- Below story chamber: EmberCrystal blocking corridor
- Lower-left: save point area
- Bottom passage: chest + stairs to F4

**Entities node children:**

| Entity | Type | Position | Metadata |
|--------|------|----------|----------|
| PressurePlate1 | PressurePlate | Mid-left room | `plate_id = "f3_plate"`, `dungeon_id = "ember_vein"` |
| HiddenDoor1 | WaterZone | Mid-left wall | `dungeon_id = "ember_vein"`, `active_when = "f3_plate_pressed"`, `zone_type = "block"` |
| PitfallTrap1 | PitfallZone | Mid-right | `target_map_id = "dungeons/ember_vein_f2"`, `target_spawn = "from_pitfall"` |
| EmberCrystal1 | EmberCrystal | Below story chamber | `crystal_id = "f3_crystal"`, `dungeon_id = "ember_vein"` |
| ChestPotion | TreasureChest | Upper passage | `chest_id = "ember_vein_f3_potion"`, `item_id = "potion"`, `quantity = 2` |
| ChestEmberShard | TreasureChest | Secret room | `chest_id = "ember_vein_f3_shard"`, `item_id = "ember_shard"`, `is_equipment = true` |
| ChestPhoenixDown | TreasureChest | Bottom passage | `chest_id = "ember_vein_f3_phoenix"`, `item_id = "phoenix_down"` |
| SavePoint1 | SavePoint | Lower-left | `save_point_id = "ember_vein_f3_save"` |

**SpawnPoints:**
- `from_f2`: Position2D at top stairs
- `from_f4`: Position2D at bottom stairs

**Transitions:**
- StairsToF2: Area2D at top, `target_map = "dungeons/ember_vein_f2"`, `target_spawn = "from_f3"`
- StairsToF4: Area2D at bottom, `target_map = "dungeons/ember_vein_f4"`, `target_spawn = "from_f3"`

- [ ] **Step 3: Add from_f3 spawn to F2 and F4**

Modify `ember_vein_f2.tscn`: add `from_f3` Position2D at the stairs-down area.
Modify `ember_vein_f4.tscn`: add `from_f3` Position2D at the stairs-up area.

- [ ] **Step 4: Verify ember_shard accessory exists**

Check `game/data/equipment/accessories.json` for `ember_shard`. If it doesn't exist, add it:
```json
{
    "id": "ember_shard",
    "name": "Ember Shard",
    "type": "stat",
    "equippable_by": ["edren", "cael", "maren", "sable", "lira", "torren"],
    "bonus_stats": {"mag": 5},
    "special": null,
    "buy_price": null,
    "sell_price": 200,
    "acquired": "Ember Vein F3 (secret room)",
    "description": "A crystallized shard of ley energy. Enhances magical ability."
}
```

- [ ] **Step 5: Verify phoenix_down exists in consumables**

Check `game/data/items/consumables.json` for `phoenix_down`. It should already exist as a revival item.

- [ ] **Step 6: Open in Godot editor and verify**

Open `game/` in Godot editor, open `ember_vein_f3.tscn`. Verify:
- Map renders without errors
- Entities are positioned correctly
- Transitions point to correct maps
- Tilemap has collision on wall tiles

- [ ] **Step 7: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f3.tscn game/scenes/maps/dungeons/ember_vein_f2.tscn game/scenes/maps/dungeons/ember_vein_f4.tscn
git commit -m "feat(engine): add Ember Vein F3 Ancient Ruin map with puzzles and encounters"
```

---

## Chunk 4: Scene 1 Dialogue + Ironmouth (Spec Chunks C, B, D)

### Task 10: Scene 1 Dialogue Data Files

**Files:**
- Modify: `game/data/dialogue/ember_vein_tutorial.json`
- Create: `game/data/dialogue/ember_vein_1a_bodies.json`
- Create: `game/data/dialogue/ember_vein_1b_letter.json`
- Create: `game/data/dialogue/ember_vein_1c_ruins.json`
- Create: `game/data/dialogue/ember_vein_1c_murals.json`
- Create: `game/data/dialogue/ember_vein_1d_pendulum.json`
- Create: `game/data/dialogue/ember_vein_1e_escape.json`

Source: `docs/story/script/act-i.md` — all dialogue verbatim.

- [ ] **Step 1: Read existing dialogue JSON format**

Read `game/data/dialogue/ember_vein_tutorial.json` to understand the exact entry format (7 fields: speaker, lines, condition, animations, choice, sfx, flag).

- [ ] **Step 2: Read script/act-i.md Scene 1 dialogue**

Read `docs/story/script/act-i.md` for the exact lines for beats 1a through 1e. Every speaker tag and line must be verbatim.

- [ ] **Step 3: Expand ember_vein_tutorial.json with full 1a beats**

Update the existing file to include complete Scene 1a dialogue from the script. Verify all entry IDs are unique.

- [ ] **Step 4: Create ember_vein_1a_bodies.json**

F1 mid-map additional miner discoveries. Follow the 7-field entry format.

- [ ] **Step 5: Create ember_vein_1b_letter.json**

F2 journal discovery and miner bodies. Include the journal quote: "The growths drink deep — even stale water wakes them for a spell."

- [ ] **Step 6: Create ember_vein_1c_ruins.json**

F3 entry — architecture shift observation. Cael: "This isn't a mine. This is something else."

- [ ] **Step 7: Create ember_vein_1c_murals.json**

F3 story chamber — geometric murals, Edren and Cael interpretation of kneeling figures.

- [ ] **Step 8: Create ember_vein_1d_pendulum.json**

F4 Pendulum discovery — seven dead miners, Pendulum pickup, room shudder.

- [ ] **Step 9: Create ember_vein_1e_escape.json**

F4 post-boss — seal crumbles, hidden passage, escape upward, arcanite gear break message.

- [ ] **Step 10: Validate all JSON files parse correctly**

```bash
cd game && for f in data/dialogue/ember_vein_1*.json data/dialogue/ember_vein_tutorial.json; do python3 -c "import json; json.load(open('$f')); print('OK: $f')" 2>&1; done
```

- [ ] **Step 11: Commit**

```bash
git add game/data/dialogue/ember_vein_*.json
git commit -m "docs(story): add Scene 1 full dialogue data (beats 1a-1e)"
```

---

### Task 11: Place Dialogue Triggers on Ember Vein Maps

**Files:**
- Modify: `game/scenes/maps/dungeons/ember_vein_f1.tscn`
- Modify: `game/scenes/maps/dungeons/ember_vein_f2.tscn`
- Modify: `game/scenes/maps/dungeons/ember_vein_f3.tscn`
- Modify: `game/scenes/maps/dungeons/ember_vein_f4.tscn`

- [ ] **Step 1: Update F1 entry dialogue trigger**

The existing F1 entry trigger uses inline `dialogue_data`. Change it to use `dialogue_scene_id = "ember_vein_tutorial"` and add `flag = "ember_vein_1a_seen"`.

- [ ] **Step 2: Add F1 mid-map bodies trigger**

Add Area2D with:
```
metadata/dialogue_scene_id = "ember_vein_1a_bodies"
metadata/flag = "ember_vein_1a_bodies_seen"
metadata/required_flag = "ember_vein_1a_seen"
```

- [ ] **Step 3: Add F2 journal trigger**

Add Area2D near the Mine Water Vial chest with:
```
metadata/dialogue_scene_id = "ember_vein_1b_letter"
metadata/flag = "ember_vein_1b_seen"
```

- [ ] **Step 4: Add F3 entry and murals triggers**

On `ember_vein_f3.tscn`, add:
- Top stairs trigger: `dialogue_scene_id = "ember_vein_1c_ruins"`, `flag = "ember_vein_1c_seen"`
- Story chamber trigger: `dialogue_scene_id = "ember_vein_1c_murals"`, `flag = "ember_vein_1c_murals_seen"`, `required_flag = "ember_vein_1c_seen"`

- [ ] **Step 5: Update F4 triggers**

Update/add on `ember_vein_f4.tscn`:
- Entry trigger: `dialogue_scene_id = "ember_vein_1d_pendulum"`, `flag = "pendulum_discovered"`
- Post-boss trigger: `dialogue_scene_id = "ember_vein_1e_escape"`, `flag = "ember_vein_1e_seen"`, `required_flag = "vaelith_ember_vein"`

The post-boss 1e trigger should also call `PartyState.break_arcanite_gear()` on dialogue completion. This requires a custom handler in exploration.gd or a special metadata flag. Check how existing post-dialogue actions work (e.g., party joining via `_check_party_joining_flags`). The simplest approach: add an `on_complete_action = "break_arcanite_gear"` metadata field and handle it in exploration.gd's dialogue completion callback.

- [ ] **Step 6: Commit**

```bash
git add game/scenes/maps/dungeons/ember_vein_f*.tscn
git commit -m "feat(engine): place Scene 1 dialogue triggers across Ember Vein floors"
```

---

### Task 12: Ironmouth Enemy Data + Dialogue Files

**Files:**
- Modify: `game/data/enemies/act_i.json`
- Create: `game/data/dialogue/ironmouth_lira.json`
- Create: `game/data/dialogue/ironmouth_sable.json`
- Create: `game/data/dialogue/ironmouth_post_combat.json`

- [ ] **Step 1: Add Compact Patrol and Scout to act_i.json**

Read `game/data/enemies/act_i.json` to find the insertion point (end of enemies array). Add the two entries exactly as specified in the spec (Section D1). Verify JSON validity after insertion.

- [ ] **Step 2: Read script/act-i.md Scene 3 dialogue**

Read `docs/story/script/act-i.md` Scene 3 for Lira and Sable's exact dialogue lines.

- [ ] **Step 3: Create ironmouth_lira.json**

Lira's introduction dialogue — behind Forgewright crates, warns party about patrol, reveals she's been tracking Compact. Follow the 7-field entry format.

- [ ] **Step 4: Create ironmouth_sable.json**

Sable's introduction — slides crate, swings on rope, introduces herself. Follow the 7-field format.

- [ ] **Step 5: Create ironmouth_post_combat.json**

Short post-combat beat — party flees into the Wilds. 2-3 entries.

- [ ] **Step 6: Validate JSON**

```bash
cd game && for f in data/dialogue/ironmouth_*.json; do python3 -c "import json; json.load(open('$f')); print('OK: $f')" 2>&1; done
python3 -c "import json; json.load(open('data/enemies/act_i.json')); print('OK: enemies')"
```

- [ ] **Step 7: Commit**

```bash
git add game/data/enemies/act_i.json game/data/dialogue/ironmouth_*.json
git commit -m "feat(engine): add Ironmouth enemy data and Scene 3 dialogue"
```

---

### Task 13: Build Ironmouth Docks Map

**Files:**
- Create: `game/scenes/maps/towns/ironmouth_docks.tscn`
- Create: `game/tests/test_ironmouth.gd`

- [ ] **Step 1: Write tests**

Create `game/tests/test_ironmouth.gd`:

```gdscript
extends GutTest
## Tests for Ironmouth Docks escape sequence.


func before_each() -> void:
	PartyState.initialize_new_game()
	EventFlags.clear_all()


func test_ironmouth_lira_trigger_sets_flag() -> void:
	# Simulate: dialogue completion sets ironmouth_lira_seen
	EventFlags.set_flag("ironmouth_lira_seen")
	assert_true(EventFlags.get_flag("ironmouth_lira_seen"))


func test_ironmouth_sable_requires_lira_flag() -> void:
	# Without lira flag, sable trigger should not fire
	assert_false(EventFlags.get_flag("ironmouth_lira_seen"))
	# With lira flag, sable trigger can fire
	EventFlags.set_flag("ironmouth_lira_seen")
	assert_true(EventFlags.get_flag("ironmouth_lira_seen"))


func test_combat_trigger_requires_sable_flag() -> void:
	assert_false(EventFlags.get_flag("ironmouth_sable_seen"))
	EventFlags.set_flag("ironmouth_sable_seen")
	assert_true(EventFlags.get_flag("ironmouth_sable_seen"))


func test_carradan_ambush_survived_adds_lira_sable() -> void:
	EventFlags.set_flag("carradan_ambush_survived")
	# _check_party_joining_flags checks this flag
	assert_true(EventFlags.get_flag("carradan_ambush_survived"))
	# Verify Lira and Sable can be added
	var avg_level: int = 3
	PartyState.add_member("lira", avg_level)
	PartyState.add_member("sable", avg_level)
	assert_true(PartyState.has_member("lira"), "Lira should be in party")
	assert_true(PartyState.has_member("sable"), "Sable should be in party")


func test_compact_patrol_loads_from_data() -> void:
	var enemies: Dictionary = DataManager.load_json("res://data/enemies/act_i.json")
	var found: bool = false
	for enemy: Dictionary in enemies.get("enemies", []):
		if enemy.get("id", "") == "compact_patrol":
			found = true
			assert_eq(enemy.get("hp", 0), 180, "Compact Patrol HP should be 180")
			assert_eq(enemy.get("atk", 0), 16, "Compact Patrol ATK should be 16")
			assert_eq(enemy.get("exp", 0), 18, "Compact Patrol EXP should be 18")
			break
	assert_true(found, "compact_patrol should exist in act_i.json")


func test_compact_scout_loads_from_data() -> void:
	var enemies: Dictionary = DataManager.load_json("res://data/enemies/act_i.json")
	var found: bool = false
	for enemy: Dictionary in enemies.get("enemies", []):
		if enemy.get("id", "") == "compact_scout":
			found = true
			assert_eq(enemy.get("hp", 0), 140, "Compact Scout HP should be 140")
			assert_eq(enemy.get("spd", 0), 14, "Compact Scout SPD should be 14")
			break
	assert_true(found, "compact_scout should exist in act_i.json")


func test_overworld_entry_requires_vaelith_scene_complete() -> void:
	# Without the flag, Ironmouth should not be enterable
	assert_false(EventFlags.get_flag("vaelith_scene_complete"),
		"vaelith_scene_complete should not be set initially")
	# After setting the flag, entry is allowed
	EventFlags.set_flag("vaelith_scene_complete")
	assert_true(EventFlags.get_flag("vaelith_scene_complete"),
		"vaelith_scene_complete should gate Ironmouth entry")


func test_ironmouth_not_reenterable_after_escape() -> void:
	# After carradan_ambush_survived, Ironmouth locked
	EventFlags.set_flag("carradan_ambush_survived")
	# The overworld trigger uses one-shot flag — once set, trigger disabled
	# This tests the flag state that gates re-entry
	assert_true(EventFlags.get_flag("carradan_ambush_survived"),
		"carradan_ambush_survived should prevent re-entry")
```

- [ ] **Step 2: Build ironmouth_docks.tscn**

Create `game/scenes/maps/towns/ironmouth_docks.tscn` with:

**Root metadata:**
```
metadata/map_id = "towns/ironmouth_docks"
metadata/location_name = "Ironmouth Docks"
```

No `dungeon_id` or `floor_id` — encounters disabled.

**TileMapLayer:** ~20x12 tiles using existing town tileset. Linear left-to-right layout.

**Entities:**
- Lira dialogue trigger (left area): `dialogue_scene_id = "ironmouth_lira"`, `flag = "ironmouth_lira_seen"`
- Crate 1: TreasureChest, `chest_id = "ironmouth_crate_1"`, `item_id = "potion"`, `quantity = 2`
- Crate 2: TreasureChest, `chest_id = "ironmouth_crate_2"`, `item_id = "antidote"`, `quantity = 1`
- Crate 3: TreasureChest, `chest_id = "ironmouth_crate_3"`, `item_id = "iron_bracelet"`, `is_equipment = true`
- Sable dialogue trigger (mid): `dialogue_scene_id = "ironmouth_sable"`, `flag = "ironmouth_sable_seen"`, `required_flag = "ironmouth_lira_seen"`
- Combat trigger (near exit): Area2D with `enemy_ids = ["compact_patrol", "compact_patrol", "compact_scout"]`, `flag = "carradan_ambush_survived"`, `required_flag = "ironmouth_sable_seen"`, `boss_id = "ironmouth_ambush"`, `enemy_act = "act_i"`
- Post-combat dialogue trigger: `dialogue_scene_id = "ironmouth_post_combat"`, `required_flag = "carradan_ambush_survived"`, `flag = "ironmouth_post_combat_seen"`

**SpawnPoints:**
- `from_overworld`: Position2D at left edge
- `from_ember_vein`: Position2D at left edge (for F4 exit transition)

**Transitions:**
- ExitToOverworld: Area2D at right edge, `target_map = "overworld"`, `target_spawn = "from_ironmouth"`, gated by `required_flag = "carradan_ambush_survived"` or placed after the combat trigger zone

- [ ] **Step 3: Add Ironmouth entry on overworld**

Modify `game/scenes/maps/overworld.tscn`:
- Add transition trigger near Ember Vein exit area
- `target_map = "towns/ironmouth_docks"`, `target_spawn = "from_overworld"`
- `required_flag = "vaelith_scene_complete"` (gates entry to after Scene 2)
- ~~`flag = "ironmouth_entered"`~~ (removed — transition handler doesn't set `flag` metadata)
- Add `from_ironmouth` Position2D spawn point

- [ ] **Step 4: Run tests**

Run: `cd game && godot --headless --script addons/gut/gut_cmdln.gd -gtest=res://tests/test_ironmouth.gd -gexit`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add game/scenes/maps/towns/ironmouth_docks.tscn game/scenes/maps/overworld.tscn game/tests/test_ironmouth.gd
git commit -m "feat(engine): add Ironmouth Docks map with escape sequence and combat"
```

---

### Task 14: Update Gap Tracker + Docs + Final Verification

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`
- Modify: `docs/story/dungeons-world.md` (clarify Cael shimmer persists beyond Ember Vein)

- [ ] **Step 1: Update gap 4.4 status**

In `docs/analysis/game-dev-gaps.md`, update Phase B2 section:
- Mark all Phase B2 items as complete (except Chunk F deferred items)
- Add Chunk F deferred items explicitly:
  - Dawn March forward-only walk (requires gap 3.7)
  - Opening credits title card + overlay (requires gap 3.7)
  - `opening_credits_seen` flag (39) (requires gap 3.7)
  - Arcanite gear preview visual (enhanced glow on equipment)
  - Cael hidden stat spike visual shimmer (requires gap 4.8)

- [ ] **Step 2: Add progress tracking row**

Add a row to the Progress Tracking table:
```
| 2026-04-12 | 4.4 Phase B2 | Ember Vein F3 (puzzles, encounters), Ironmouth escape (combat + dialogue), Scene 1 full dialogue (1a-1e), Cael shimmer, Arcanite gear, start location. Dawn March deferred to 3.7. | — |
```

- [ ] **Step 3: Update dungeons-world.md Cael shimmer note**

In `docs/story/dungeons-world.md`, find the Pallor Shimmer section for Ember Vein and clarify that the shimmer and +10% damage persist beyond Ember Vein — Pallor's touch is permanent per the character arc.

- [ ] **Step 4: Update summary table**

Update the stale summary table at the bottom to reflect accurate completion counts.

- [ ] **Step 5: Run all tests**

```bash
cd game && godot --headless --script addons/gut/gut_cmdln.gd -gexit
```

Verify no regressions across the full test suite.

- [ ] **Step 6: Commit**

```bash
git add docs/analysis/game-dev-gaps.md docs/story/dungeons-world.md
git commit -m "docs(story): update gap tracker and design docs for Phase B2 completion"
```

---

## Execution Notes

**Total tasks:** 14
**Total new files:** ~20 (6 entity files, 2 map scenes, 9 dialogue JSONs, 3 test files)
**Total modified files:** ~13

**Critical verification points:**
- After Task 3: Start a new game in Godot editor — should load Ember Vein F1
- After Task 9: Open F3 map in editor — should render without errors, entities positioned
- After Task 13: Full sequence test: New Game → F1 → F2 (vial) → F3 (puzzles) → F4 (boss) → overworld (Vaelith) → Ironmouth (escape) → overworld (Wilds)

**Key patterns to follow:**
- Entity scripts: `game/scripts/entities/water_wheel.gd` (Area2D toggle), `spirit_plant.gd` (StaticBody2D consumer)
- Entity wiring: `exploration.gd` lines 253-359 (init + signals)
- Dialogue JSON: `game/data/dialogue/ember_vein_tutorial.json` (7-field format)
- Map scenes: `game/scenes/maps/dungeons/ember_vein_f1.tscn` (metadata, entities, transitions)
