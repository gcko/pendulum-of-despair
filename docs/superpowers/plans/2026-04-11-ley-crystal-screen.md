# Ley Crystal Screen Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Ley Crystal menu sub-screen — the last of 9 menu screens — with data layer, PartyState integration, and battle XP rewards hook.

**Architecture:** Hybrid C — crystal equipped via existing `equipment.crystal` slot, crystal XP/level tracked in new `PartyState.ley_crystals` dict, static data loaded from `game/data/ley_crystals.json` via DataManager. UI follows Magic screen pattern (2-column grid, detail drill-down).

**Tech Stack:** Godot 4.6 / GDScript, GUT test framework, existing autoload singletons (GameManager, DataManager, PartyState, EventFlags)

**Spec:** `docs/superpowers/specs/2026-04-11-ley-crystal-screen-design.md`

---

## Chunk 1: Static Data + DataManager

### Task 1: Create ley_crystals.json with all 18 crystals

All values transcribed from `docs/story/progression.md` (stat bonuses per level)
and `docs/story/items.md` (invocation catalog).

**Files:**
- Create: `game/data/ley_crystals.json`

- [ ] **Step 1: Create the JSON file**

Create `game/data/ley_crystals.json` with the `"crystals"` array containing
all 18 entries. Each crystal has:

```json
{
  "id": "string",
  "name": "String",
  "element": "string",
  "description": "One-line flavor text",
  "acquired": "Location name",
  "xp_thresholds": [0, 800, 2500, 6000, 15000],
  "level_bonuses": [ {stat: value}, {}, {}, {}, {} ],
  "invocation": {
    "id": "string",
    "name": "String",
    "element": "string",
    "description": "Brief effect description",
    "target": "all_enemies|all_party|single_enemy|self",
    "uses_per_rest": N,
    "level_effects": [ {power: N}, ... ]
  },
  "negative_effect": null | { "description": "text", "type": "string" },
  "secret_lv5": false
}
```

**Canonical stat bonus values** (from `docs/story/progression.md` lines 323-352):

**Standard (10):**

| ID | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 |
|----|-----|-----|-----|-----|-----|
| ember_shard | atk:1 | atk:1 | atk:2 | atk:2 | atk:2,def:1 |
| iron_core | def:2 | def:2 | def:2,hp_per_level:50 | def:2,hp_per_level:50 | def:3,hp_per_level:80 |
| ley_prism | mag:1 | mag:2 | mag:2 | mag:2,mp_per_level:5 | mag:3,mp_per_level:8 |
| ward_stone | mdef:1 | mdef:2 | mdef:2 | mdef:2 | mdef:2,mag:1 |
| quicksilver | spd:1 | spd:2 | spd:2 | spd:2,lck:1 | spd:2,lck:2 |
| fortune_stone | lck:2 | lck:2 | lck:2,spd:1 | lck:3,spd:1 | lck:3,spd:2 |
| lifestone | hp_per_level:120 | hp_per_level:120 | hp_per_level:150 | hp_per_level:150 | hp_per_level:200,def:1 |
| wellspring | mp_per_level:10 | mp_per_level:10 | mp_per_level:12,mag:1 | mp_per_level:12,mag:1 | mp_per_level:15,mag:2 |
| spirit_tear | mag:1,spd:1 | mag:1,spd:1 | mag:1,spd:1 | mag:2,spd:1 | mag:2,spd:2 |
| forgewright_core | atk:1,def:1 | atk:1,def:1 | atk:2,def:1 | atk:2,def:2 | atk:2,def:2 |

**Negative (4):**

| ID | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 | Negative |
|----|-----|-----|-----|-----|-----|----------|
| flame_heart | atk:1,mag:1 | atk:1,mag:1 | atk:2,mag:1 | atk:2,mag:2 | atk:2,mag:2 | random_self_damage (flame) |
| frost_veil | def:1,mdef:1 | def:1,mdef:1 | def:1,mdef:2 | def:2,mdef:2 | def:2,mdef:2 | spd_penalty (-15%) |
| storm_eye | spd:1,lck:1 | spd:1,lck:1 | spd:2,lck:1 | spd:2,lck:2 | spd:2,lck:2 | random_target (10%) |
| grey_remnant | mag:2 | mag:3 | mag:3 | mag:3 | mag:4 | hp_loss_per_level (-40 HP) + pallor_vulnerability (+25%) |

**Special (4):**

| ID | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 | Special |
|----|-----|-----|-----|-----|-----|---------|
| dawn_fragment | all:2 | all:1 | all:1 | {} | {} | Diminishing |
| convergence_shard | all:1 | all:1 | all:1 | all:1 | all:3 | secret_lv5:true |
| null_crystal | {} | {} | {} | {} | {} | Despair immunity (passive) |
| caels_echo | atk:1,mag:1 | atk:1,mag:1 | atk:2,mag:2 | atk:2,mag:2 | atk:2,mag:2,spd:1 | Character-specific bonuses |

**Invocation values** (from `docs/story/items.md` lines 234-265):

| Crystal | Invocation ID | Name | Element | Target | Uses | Lv1 Power | Lv5 Power |
|---------|--------------|------|---------|--------|------|-----------|-----------|
| ember_shard | forge_flare | Forge Flare | flame | all_enemies | 5 | 150 | 500 |
| iron_core | ironwall | Ironwall | buff | all_party | 4 | def+30%,3t | def+50%,3t |
| ley_prism | ley_cascade | Ley Cascade | ley | all_enemies | 4 | 200 | 600 |
| ward_stone | null_barrier | Null Barrier | buff | all_party | 4 | mdef+30%,3t | mdef+50%,3t |
| quicksilver | time_slip | Time Slip | buff | all_party | 3 | haste 2t | haste 4t |
| fortune_stone | fates_hand | Fate's Hand | buff | all_party | 5 | lck+50%,3t | lck+100%,3t |
| lifestone | lifespring | Lifespring | spirit | all_party | 6 | heal 300 | heal 1500 |
| wellspring | mana_tide | Mana Tide | ley | all_party | 4 | 20 mp | 80 mp |
| spirit_tear | spirit_call | Spirit Call | spirit | all_enemies | 3 | 180 | 550+regen |
| forgewright_core | siege_engine | Siege Engine | none | single_enemy | 3 | 400+def_break | 1200+def_break |
| flame_heart | crucible_wrath | Crucible Wrath | flame | all_enemies | 3 | 300 | 900+burn |
| frost_veil | absolute_zero | Absolute Zero | frost | all_enemies | 3 | 250 | 800+slow |
| storm_eye | tempest_surge | Tempest Surge | storm | all_enemies | 4 | 250 | 800 (random) |
| grey_remnant | pallor_touch | Pallor Touch | void | all_enemies | 2 | 350 | 1000+despair |
| dawn_fragment | first_light | First Light | none | all_enemies | 8→2 | 500 | 200 |
| convergence_shard | convergence_pulse | Convergence Pulse | none | all_enemies | 1 | 100 | 2000 |
| null_crystal | void_shield | Void Shield | buff | all_party | 2 | despair_immune 3t | despair_immune 3t |
| caels_echo | caels_resolve | Cael's Resolve | buff | all_party | 1 | +20% all 3t+500hp | same |

For buff/heal/mp invocations, `level_effects` uses descriptive keys instead of `power`:
```json
"level_effects": [
  {"effect": "def_buff", "percent": 30, "turns": 3},
  {"effect": "def_buff", "percent": 35, "turns": 3},
  {"effect": "def_buff", "percent": 40, "turns": 3},
  {"effect": "def_buff", "percent": 45, "turns": 3},
  {"effect": "def_buff", "percent": 50, "turns": 3}
]
```

Dawn Fragment's invocation has *decreasing* power and uses:
```json
"level_effects": [
  {"power": 500, "uses_override": 8},
  {"power": 400, "uses_override": 6},
  {"power": 300, "uses_override": 4},
  {"power": 250, "uses_override": 3},
  {"power": 200, "uses_override": 2}
]
```

- [ ] **Step 2: Validate JSON**

```bash
python3 -c "
import json
d = json.load(open('game/data/ley_crystals.json'))
crystals = d['crystals']
assert len(crystals) == 18, f'Expected 18, got {len(crystals)}'
ids = [c['id'] for c in crystals]
assert len(set(ids)) == 18, 'Duplicate IDs'
for c in crystals:
    assert len(c['xp_thresholds']) == 5, f'{c[\"id\"]}: bad xp_thresholds'
    assert len(c['level_bonuses']) == 5, f'{c[\"id\"]}: bad level_bonuses'
    assert len(c['invocation']['level_effects']) == 5, f'{c[\"id\"]}: bad level_effects'
print('All 18 crystals valid')
"
```

- [ ] **Step 3: Commit**

```bash
git add game/data/ley_crystals.json
git commit -m "feat(engine): add Ley Crystal static data (18 crystals)"
```

### Task 2: Add DataManager crystal loading methods

**Files:**
- Modify: `game/scripts/autoload/data_manager.gd`

- [ ] **Step 1: Add load_ley_crystals method**

Add after the existing `load_dialogue` method (around line 170):

```gdscript
## Load all Ley Crystal static data. Returns the "crystals" array.
func load_ley_crystals() -> Array:
	var path: String = "res://data/ley_crystals.json"
	if not FileAccess.file_exists(path):
		push_warning("DataManager: Ley crystal file not found: %s" % path)
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("crystals"):
		return data["crystals"]
	return []


## Get a single Ley Crystal's static data by ID. Returns empty dict if not found.
func get_ley_crystal(crystal_id: String) -> Dictionary:
	var crystals: Array = load_ley_crystals()
	for entry: Variant in crystals:
		if entry is Dictionary and (entry as Dictionary).get("id", "") == crystal_id:
			return entry as Dictionary
	return {}
```

- [ ] **Step 2: Commit**

```bash
git add game/scripts/autoload/data_manager.gd
git commit -m "feat(engine): add DataManager Ley Crystal loading methods"
```

---

## Chunk 2: PartyState Crystal Methods + Save/Load

### Task 3: Add ley_crystals runtime state to PartyState

**Files:**
- Modify: `game/scripts/autoload/party_state.gd`

- [ ] **Step 1: Add ley_crystals variable**

Add after `_next_inst_id` (around line 42):

```gdscript
var ley_crystals: Dictionary = {}
```

- [ ] **Step 2: Add crystal methods**

Add after `get_reserve_party()` (around line 142):

```gdscript
## Add a Ley Crystal to the collection at Lv1 / 0 XP. No-op if already owned.
func add_ley_crystal(crystal_id: String) -> void:
	if crystal_id.is_empty() or ley_crystals.has(crystal_id):
		return
	ley_crystals[crystal_id] = {"xp": 0, "level": 1}


## Get a crystal's runtime state. Returns empty dict if not owned.
func get_crystal_state(crystal_id: String) -> Dictionary:
	return ley_crystals.get(crystal_id, {})


## Add XP to a crystal. Auto-levels when thresholds are crossed.
## At Lv5 (max), excess XP is discarded. Multi-level jumps supported.
func add_crystal_xp(crystal_id: String, amount: int) -> void:
	if not ley_crystals.has(crystal_id) or amount <= 0:
		return
	var state: Dictionary = ley_crystals[crystal_id]
	var crystal_data: Dictionary = DataManager.get_ley_crystal(crystal_id)
	var thresholds: Array = crystal_data.get("xp_thresholds", [0, 800, 2500, 6000, 15000])
	var level: int = state.get("level", 1)
	if level >= 5:
		return
	var xp: int = state.get("xp", 0) + amount
	while level < 5 and level < thresholds.size() and xp >= thresholds[level]:
		level += 1
	if level >= 5:
		xp = thresholds[4] if thresholds.size() > 4 else 15000
	state["xp"] = xp
	state["level"] = level


## Get all collected crystal IDs.
func get_collected_crystals() -> Array[String]:
	var result: Array[String] = []
	for key: String in ley_crystals:
		result.append(key)
	return result
```

- [ ] **Step 3: Clear ley_crystals in initialize_new_game**

In `initialize_new_game()`, add after `EventFlags.clear_all()` (around line 54):

```gdscript
	ley_crystals.clear()
```

- [ ] **Step 4: Update load_from_save**

In `load_from_save()`, add after `EventFlags.load_from_save(...)` (around line 119):

```gdscript
	ley_crystals = world.get("ley_crystals", {})
```

- [ ] **Step 5: Update build_save_data**

The save dict template in `inventory_helpers.gd` already has a `"ley_crystals"` stub
(line 297: `"ley_crystals": {"collected": []}`). Change it to use the actual runtime data.

In `inventory_helpers.gd` `build_save_dict()`, modify the function signature to accept
ley_crystals and replace the stub:

Add parameter `lc: Dictionary` after `play_time`:

```gdscript
static func build_save_dict(
	party: Array,
	form: Dictionary,
	inv: Dictionary,
	equips: Array,
	loc: String,
	g: int,
	flags: Dictionary,
	play_time: int = 0,
	lc: Dictionary = {}
) -> Dictionary:
```

Replace `"ley_crystals": {"collected": []}` with:

```gdscript
		"ley_crystals": lc.duplicate(true),
```

Then update `party_state.gd` `build_save_data()` to pass ley_crystals:

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
		ley_crystals
	)
```

- [ ] **Step 6: Commit**

```bash
git add game/scripts/autoload/party_state.gd game/scripts/autoload/inventory_helpers.gd
git commit -m "feat(engine): add PartyState Ley Crystal runtime state and save/load"
```

### Task 4: Add crystal XP to battle rewards

**Files:**
- Modify: `game/scripts/core/exploration.gd`

- [ ] **Step 1: Add crystal XP distribution after battle rewards**

In `_initialize_from_transition_data()`, in the `r == "victory"` block,
after `PartyState.distribute_battle_rewards(rewards)` (around line 241),
add crystal XP distribution:

```gdscript
		# Crystal XP: 30% of earned XP per active member with a crystal
		var xp_per_member: int = rewards.get("xp", 0)
		if xp_per_member > 0:
			var active: Array = PartyState.formation.get("active", [])
			for idx: Variant in active:
				if not (idx is int) or (idx as int) >= PartyState.members.size():
					continue
				var m: Dictionary = PartyState.members[idx as int]
				var cid: String = m.get("equipment", {}).get("crystal", "")
				if not cid.is_empty():
					PartyState.add_crystal_xp(cid, int(xp_per_member * 0.3))
```

Also add the same block after the two cleansing sequence reward distributions
(`_start_cleansing_sequence` around line 509, `_continue_cleansing_sequence`
around line 541). Or better: extract a helper `_distribute_crystal_xp(xp: int)`
and call it from all three reward paths.

- [ ] **Step 2: Extract helper and wire all reward paths**

Add helper method:

```gdscript
func _distribute_crystal_xp(xp_per_member: int) -> void:
	if xp_per_member <= 0:
		return
	var active: Array = PartyState.formation.get("active", [])
	for idx: Variant in active:
		if not (idx is int) or (idx as int) >= PartyState.members.size():
			continue
		var m: Dictionary = PartyState.members[idx as int]
		var cid: String = m.get("equipment", {}).get("crystal", "")
		if not cid.is_empty():
			PartyState.add_crystal_xp(cid, int(xp_per_member * 0.3))
```

Call `_distribute_crystal_xp(rewards.get("xp", 0))` after each
`PartyState.distribute_battle_rewards(rewards)` call (3 locations).

- [ ] **Step 3: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): distribute crystal XP (30%) after battle rewards"
```

---

## Chunk 3: Integration Tests

### Task 5: Write integration tests

**Files:**
- Create: `game/tests/test_ley_crystal.gd`

- [ ] **Step 1: Write all tests**

```gdscript
extends GutTest
## Integration tests for Ley Crystal system — data loading, PartyState
## methods, equip/unequip, save/load, and scene structure.


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.ley_crystals.clear()


func after_each() -> void:
	DataManager.clear_cache()
	PartyState.ley_crystals.clear()


# --- Crystal Data Loading ---


func test_all_18_crystals_load() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	assert_eq(crystals.size(), 18, "should load 18 crystals")


func test_xp_thresholds_have_5_entries() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	for c: Variant in crystals:
		if c is Dictionary:
			var d: Dictionary = c as Dictionary
			assert_eq(
				d.get("xp_thresholds", []).size(), 5,
				"%s should have 5 xp_thresholds" % d.get("id", "?")
			)


func test_level_bonuses_have_5_entries() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	for c: Variant in crystals:
		if c is Dictionary:
			var d: Dictionary = c as Dictionary
			assert_eq(
				d.get("level_bonuses", []).size(), 5,
				"%s should have 5 level_bonuses" % d.get("id", "?")
			)


func test_invocations_have_5_level_effects() -> void:
	var crystals: Array = DataManager.load_ley_crystals()
	for c: Variant in crystals:
		if c is Dictionary:
			var d: Dictionary = c as Dictionary
			var inv: Dictionary = d.get("invocation", {})
			assert_eq(
				inv.get("level_effects", []).size(), 5,
				"%s invocation should have 5 level_effects" % d.get("id", "?")
			)


func test_convergence_shard_has_secret_lv5() -> void:
	var d: Dictionary = DataManager.get_ley_crystal("convergence_shard")
	assert_false(d.is_empty(), "convergence_shard should load")
	assert_true(d.get("secret_lv5", false), "should have secret_lv5")


# --- PartyState Crystal Methods ---


func test_add_ley_crystal() -> void:
	PartyState.add_ley_crystal("ember_shard")
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("level", 0), 1, "should start at level 1")
	assert_eq(state.get("xp", -1), 0, "should start at 0 XP")


func test_add_ley_crystal_duplicate_is_noop() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 500)
	PartyState.add_ley_crystal("ember_shard")
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("xp", 0), 500, "XP should be preserved after duplicate add")


func test_get_crystal_state_unknown() -> void:
	var state: Dictionary = PartyState.get_crystal_state("nonexistent")
	assert_true(state.is_empty(), "unknown crystal should return empty dict")


func test_add_crystal_xp_increments() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 400)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("xp", 0), 400)
	assert_eq(state.get("level", 0), 1, "should still be level 1 at 400 XP")


func test_add_crystal_xp_auto_levels() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 800)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("level", 0), 2, "should auto-level to 2 at 800 XP")


func test_add_crystal_xp_caps_at_lv5() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 99999)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("level", 0), 5, "should cap at level 5")
	assert_eq(state.get("xp", 0), 15000, "XP should cap at Lv5 threshold")


# --- Collected Crystals ---


func test_get_collected_crystals() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_ley_crystal("iron_core")
	var collected: Array[String] = PartyState.get_collected_crystals()
	assert_eq(collected.size(), 2)
	assert_true("ember_shard" in collected)
	assert_true("iron_core" in collected)


# --- Save/Load ---


func test_save_includes_ley_crystals() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 500)
	var save: Dictionary = PartyState.build_save_data()
	var lc: Dictionary = save.get("ley_crystals", {})
	assert_true(lc.has("ember_shard"), "save should include ember_shard")
	assert_eq(lc["ember_shard"].get("xp", 0), 500)


func test_load_restores_ley_crystals() -> void:
	PartyState.add_ley_crystal("ember_shard")
	PartyState.add_crystal_xp("ember_shard", 1200)
	var save: Dictionary = PartyState.build_save_data()
	PartyState.ley_crystals.clear()
	assert_true(PartyState.get_crystal_state("ember_shard").is_empty())
	PartyState.load_from_save(save)
	var state: Dictionary = PartyState.get_crystal_state("ember_shard")
	assert_eq(state.get("xp", 0), 1200)
	assert_eq(state.get("level", 0), 2)


# --- Scene Structure ---


func test_menu_scene_has_crystal_screen() -> void:
	var text: String = _read_file("res://scenes/overlay/menu.tscn")
	assert_true(text.contains("CrystalScreen"), "menu should have CrystalScreen node")


func test_crystal_command_not_stubbed() -> void:
	var text: String = _read_file("res://scripts/ui/menu_overlay.gd")
	assert_false(
		text.contains('"Crystal", "char_select": true, "stubbed": true'),
		"Crystal command should not be stubbed"
	)


# --- Helpers ---


func _read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
```

- [ ] **Step 2: Commit**

```bash
git add game/tests/test_ley_crystal.gd
git commit -m "test(engine): add Ley Crystal integration tests (~17 tests)"
```

---

## Chunk 4: Menu UI Screen

### Task 6: Create menu_ley_crystal.gd

**Files:**
- Create: `game/scripts/ui/menu_ley_crystal.gd`

- [ ] **Step 1: Create the screen script**

Follow the Magic screen pattern (`menu_magic.gd`). Two states:
`BROWSING` (2-column crystal grid) and `DETAIL` (single crystal view).

Required structure:
- `extends Control`
- `enum CrystalState { BROWSING, DETAIL }`
- Constants: GRID_ROWS=6, GRID_COLS=2, GRID_SIZE=12, colors
- Variables: `_character_id`, `_crystals` (filtered list), `_cursor`,
  `_scroll_offset`, `_state`, `_selected_crystal_id`
- `@onready` node refs for Layout panels and labels
- Methods: `open(character_id)`, `close()`, `handle_input(event) -> bool`
- Private methods: `_update_grid()`, `_update_desc()`, `_update_char_info()`,
  `_show_detail(crystal_id)`, `_hide_detail()`, `_equip_crystal(crystal_id)`,
  `_format_bonus(bonus: Dictionary) -> String`

**Key implementation details:**

Grid items are built from `PartyState.get_collected_crystals()` plus
"Remove" if character has a crystal equipped. Each grid entry is a Label
in a 2-column VBoxContainer layout (same as Magic screen).

The detail view reuses the same CrystalGrid panel area — hides the grid
labels and shows detail labels instead (or uses a DetailPanel that overlays).

Stat comparison: for each of the 6 stats (atk, def, mag, mdef, spd, lck),
calculate the delta between current crystal bonus and the preview crystal
bonus at its current level.

For "Equipped by [Name]" detection: iterate `PartyState.members`, check
each member's `equipment.crystal` field.

- [ ] **Step 2: Run gdlint + gdformat**

```bash
gdlint game/scripts/ui/menu_ley_crystal.gd
gdformat game/scripts/ui/menu_ley_crystal.gd
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/ui/menu_ley_crystal.gd
git commit -m "feat(engine): add Ley Crystal menu sub-screen"
```

### Task 7: Add CrystalScreen to menu.tscn and wire menu_overlay

**Files:**
- Modify: `game/scenes/overlay/menu.tscn`
- Modify: `game/scripts/ui/menu_overlay.gd`

- [ ] **Step 1: Add CrystalScreen node to menu.tscn**

Add a Control node under `SubScreen` named `CrystalScreen` with the
`menu_ley_crystal.gd` script attached. Create child nodes matching
the panel layout:

```
SubScreen/CrystalScreen (Control, script: menu_ley_crystal.gd)
  Layout (VBoxContainer)
    TopRow (HBoxContainer)
      TitlePanel (PanelContainer)
        TitleLabel (Label: "Ley Crystals")
      CharPanel (PanelContainer)
        CharInfo (VBoxContainer)
          NameLabel (Label)
          LvLabel (Label)
          HPLabel (Label)
          MPLabel (Label)
    CrystalPanel (PanelContainer)
      CrystalGrid (HBoxContainer)
        LeftCol (VBoxContainer) — 6 Labels: Crystal0..Crystal5
        RightCol (VBoxContainer) — 6 Labels: Crystal6..Crystal11
      DetailView (VBoxContainer, visible=false)
        HeaderLabel (Label)
        XPBar (ColorRect + child fill ColorRect + XPLabel)
        BonusLabel (Label)
        NextLevelLabel (Label)
        LevelUpLabel (Label)
        StatCompareLabel (Label)
        WarningLabel (Label)
    DescPanel (PanelContainer)
      DescLabel (Label)
```

Style all PanelContainers with the FF6 StyleBoxFlat (dark blue bg,
border, shadow) — same as Magic/Abilities/Equipment screens.

Set `CrystalScreen.visible = false`.

- [ ] **Step 2: Wire menu_overlay.gd**

In `menu_overlay.gd`:

1. Remove `"stubbed": true` from Crystal command (line 22):
```gdscript
	{"name": "Crystal", "char_select": true, "stubbed": false},
```

2. Add `@onready` reference (after `_formation_screen`, around line 51):
```gdscript
@onready var _crystal_screen: Control = $SubScreen/CrystalScreen
```

3. Add Crystal arm in `_open_sub_screen_for_character()` (after Status, around line 196):
```gdscript
		"Crystal":
			_open_sub_screen(_crystal_screen)
			if _crystal_screen.has_method("open"):
				_crystal_screen.open(character_id)
```

4. Add to `_hide_all_sub_screens()` (after formation_screen, around line 247):
```gdscript
	if _crystal_screen != null:
		_crystal_screen.visible = false
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_overlay.gd
git commit -m "feat(engine): wire Ley Crystal screen into menu overlay"
```

---

## Chunk 5: Gap Tracker Update + Final Verification

### Task 8: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update 3.4 status**

In gap 3.4, change:
- Status line: `MOSTLY COMPLETE` → `COMPLETE`
- Check off Ley Crystal item in the checklist
- Add completion note: "Ley Crystal screen complete (2026-04-11)"

- [ ] **Step 2: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): mark gap 3.4 Menu Overlay as COMPLETE"
```

### Task 9: Final verification

- [ ] **Step 1: Validate JSON data against canonical docs**

Spot-check 3 crystals against `progression.md`:
- ember_shard Lv5: atk:2, def:1
- grey_remnant Lv5: mag:4
- convergence_shard Lv5: all stats +3

Spot-check 3 invocations against `items.md`:
- forge_flare: Lv1 power 150, Lv5 power 500, uses 5
- pallor_touch: Lv1 power 350, Lv5 power 1000, uses 2
- first_light: Lv1 power 500 (8 uses), Lv5 power 200 (2 uses)

- [ ] **Step 2: Run gdlint + gdformat on all changed .gd files**

```bash
gdlint game/scripts/ui/menu_ley_crystal.gd game/scripts/autoload/party_state.gd game/scripts/autoload/data_manager.gd game/scripts/core/exploration.gd
gdformat --check game/scripts/ui/menu_ley_crystal.gd game/scripts/autoload/party_state.gd game/scripts/autoload/data_manager.gd game/scripts/core/exploration.gd
```

- [ ] **Step 3: Run mirror staleness check**

```bash
grep -r "stubbed.*true.*Crystal\|Crystal.*stubbed.*true" game/scripts/
# Should return nothing
```

- [ ] **Step 4: Commit any final fixes**

```bash
git add -A
git commit -m "fix(engine): final Ley Crystal verification fixes"
```
