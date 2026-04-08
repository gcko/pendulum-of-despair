# Abilities Menu Screen Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an Abilities sub-screen to the main menu showing each character's unique ability set with cost_type-adaptive display. View-only (abilities are battle commands).

**Architecture:** New `menu_abilities.gd` following `menu_magic.gd` pattern. Static `ability_helpers.gd` resolves known abilities from JSON and formats cost strings. DataManager gains `load_abilities()`. Tests cover resolution, cost formatting, and integration for all 6 characters.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.6.0

**Spec:** `docs/superpowers/specs/2026-04-08-abilities-screen-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/ui/ability_helpers.gd` | CREATE | Ability resolution + cost formatting |
| `game/scripts/ui/menu_abilities.gd` | CREATE | Abilities sub-screen (~180 lines) |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add AbilitiesScreen node tree |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Unstub Abilities, wire dispatch (337 lines) |
| `game/scripts/autoload/data_manager.gd` | MODIFY | Add load_abilities() (172 lines) |
| `game/tests/test_abilities_screen.gd` | CREATE | Unit + integration tests (~140 lines) |
| `game/tests/test_cross_references.gd` | MODIFY | Ability file validation (318 lines) |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 3.4 |

---

## Chunk 1: Helpers + DataManager + Tests

### Task 1: Add load_abilities to DataManager

**Files:**
- Modify: `game/scripts/autoload/data_manager.gd`

- [ ] **Step 1: Add load_abilities method**

Add after the existing `load_encounters()` method. Follows the same
file_exists guard pattern as all other load functions:

```gdscript
## Load ability data for a character. Returns the abilities array, or empty if missing.
func load_abilities(character_id: String) -> Array:
	var path: String = "res://data/abilities/%s.json" % character_id
	if not FileAccess.file_exists(path):
		return []
	var data: Variant = load_json(path)
	if data is Dictionary and data.has("abilities"):
		return data["abilities"]
	return []
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/scripts/autoload/data_manager.gd
git commit -m "feat(engine): add DataManager.load_abilities() for character ability data"
```

### Task 2: Create ability_helpers.gd

**Files:**
- Create: `game/scripts/ui/ability_helpers.gd`

- [ ] **Step 1: Write the static helper**

```gdscript
extends RefCounted
## Static helpers for resolving known abilities and formatting costs.


## Resource label mapping per command type.
const RESOURCE_LABELS: Dictionary = {
	"bulwark": "AP 0/10",
	"rally": "MP",
	"forgewright": "AC 12/12",
	"spiritcall": "MP",
	"tricks": "MP",
	"arcanum": "WG 0/100",
}


## Get abilities a character knows at their current level.
## Excludes story-gated abilities unless the EventFlags condition is met.
## Returns Array sorted by level_learned ascending.
static func get_known_abilities(character_id: String, level: int) -> Array:
	var all_abilities: Array = DataManager.load_abilities(character_id)
	var result: Array = []
	for ability: Variant in all_abilities:
		if not ability is Dictionary:
			continue
		var a: Dictionary = ability as Dictionary
		var req_level: Variant = a.get("level_learned", null)
		if a.get("story_gated", false):
			var event: String = a.get("story_event", "")
			if event == "" or not EventFlags.get_flag(event):
				continue
			# Story-gated with flag set — include regardless of level
		elif req_level is int and (req_level as int) > level:
			continue
		elif req_level == null:
			continue  # Null level + not story-gated = skip
		result.append(a)
	result.sort_custom(_sort_by_level)
	return result


## Format the cost display string based on cost_type.
static func format_cost(ability: Dictionary) -> String:
	var ctype: String = ability.get("cost_type", "")
	var value: int = ability.get("cost_value", 0)
	match ctype:
		"ap":
			return "%d AP" % value
		"mp":
			return "%d MP" % value
		"ac":
			return "%d AC" % value
		"wg":
			return "%d WG" % value
		"mp_cd":
			var cd: int = ability.get("cooldown", 0)
			return "%d MP/%dt" % [value, cd]
		"none":
			return "Passive"
	return ability.get("cost", "")


## Get the resource label for a character's command type.
static func get_resource_label(character_id: String, member: Dictionary) -> String:
	var abilities: Array = DataManager.load_abilities(character_id)
	if abilities.is_empty():
		return ""
	var first: Dictionary = abilities[0] as Dictionary if abilities[0] is Dictionary else {}
	var cmd: String = first.get("command", "")
	var label: String = RESOURCE_LABELS.get(cmd, "")
	if label == "MP":
		return "MP %d/%d" % [member.get("current_mp", 0), member.get("max_mp", 0)]
	return label


static func _sort_by_level(a: Dictionary, b: Dictionary) -> bool:
	var la: int = a.get("level_learned", 0) if a.get("level_learned") is int else 0
	var lb: int = b.get("level_learned", 0) if b.get("level_learned") is int else 0
	return la < lb
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/scripts/ui/ability_helpers.gd
git commit -m "feat(engine): add ability_helpers.gd — ability resolution + cost formatting"
```

### Task 3: Write ability resolution and cost formatting tests

**Files:**
- Create: `game/tests/test_abilities_screen.gd`

- [ ] **Step 1: Write the test file**

```gdscript
extends GutTest

const AbilityHelpers = preload("res://scripts/ui/ability_helpers.gd")


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.initialize_new_game()
	EventFlags.clear_all()


# --- Ability resolution ---


func test_edren_abilities_level_1() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 1)
	assert_eq(abilities.size(), 1, "Edren Lv1 knows 1 ability")
	assert_eq(abilities[0].get("name", ""), "Ironwall")


func test_cael_abilities_level_1() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("cael", 1)
	assert_eq(abilities.size(), 1, "Cael Lv1 knows 1 ability")
	assert_eq(abilities[0].get("name", ""), "Hold the Line")


func test_edren_abilities_level_10() -> void:
	# Edren Lv10: Ironwall(1), Riposte(6), Rampart(10)
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 10)
	assert_eq(abilities.size(), 3, "Edren Lv10 knows 3 abilities")


func test_lira_abilities_level_1() -> void:
	# Lira Lv1: Shock Coil(1), Salvage(1)
	var abilities: Array = AbilityHelpers.get_known_abilities("lira", 1)
	assert_eq(abilities.size(), 2, "Lira Lv1 knows 2 abilities")


func test_all_6_characters_have_ability_data() -> void:
	for cid: String in ["edren", "cael", "lira", "torren", "sable", "maren"]:
		var abilities: Array = DataManager.load_abilities(cid)
		assert_gt(abilities.size(), 0, "%s should have ability data" % cid)


func test_story_gated_excluded_without_flag() -> void:
	# Edren has story-gated abilities (e.g., Steadfast Resolve)
	var all_abilities: Array = DataManager.load_abilities("edren")
	var gated: Array = []
	for a: Variant in all_abilities:
		if a is Dictionary and (a as Dictionary).get("story_gated", false):
			gated.append(a)
	assert_gt(gated.size(), 0, "Edren should have story-gated abilities")
	# Without flags set, known abilities should exclude them
	var known: Array = AbilityHelpers.get_known_abilities("edren", 99)
	for a: Dictionary in known:
		assert_false(a.get("story_gated", false), "Story-gated should be excluded")


func test_unknown_character_returns_empty() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("nonexistent", 50)
	assert_eq(abilities.size(), 0)


func test_abilities_sorted_by_level() -> void:
	var abilities: Array = AbilityHelpers.get_known_abilities("edren", 30)
	for i: int in range(1, abilities.size()):
		var prev: int = abilities[i - 1].get("level_learned", 0)
		var curr: int = abilities[i].get("level_learned", 0)
		if prev is int and curr is int:
			assert_lte(prev, curr, "Abilities should be sorted by level")


# --- Cost formatting ---


func test_format_cost_ap() -> void:
	assert_eq(AbilityHelpers.format_cost({"cost_type": "ap", "cost_value": 2}), "2 AP")


func test_format_cost_mp() -> void:
	assert_eq(AbilityHelpers.format_cost({"cost_type": "mp", "cost_value": 6}), "6 MP")


func test_format_cost_ac() -> void:
	assert_eq(AbilityHelpers.format_cost({"cost_type": "ac", "cost_value": 3}), "3 AC")


func test_format_cost_wg() -> void:
	assert_eq(AbilityHelpers.format_cost({"cost_type": "wg", "cost_value": 50}), "50 WG")


func test_format_cost_mp_cd() -> void:
	assert_eq(
		AbilityHelpers.format_cost({"cost_type": "mp_cd", "cost_value": 4, "cooldown": 2}),
		"4 MP/2t"
	)


func test_format_cost_none() -> void:
	assert_eq(AbilityHelpers.format_cost({"cost_type": "none"}), "Passive")


func test_format_cost_fallback() -> void:
	assert_eq(
		AbilityHelpers.format_cost({"cost_type": "unknown", "cost": "Special"}),
		"Special"
	)


# --- Integration ---


func test_load_abilities_missing_returns_empty() -> void:
	var result: Array = DataManager.load_abilities("nonexistent_char")
	assert_eq(result.size(), 0)


func test_all_ability_ids_unique_per_character() -> void:
	for cid: String in ["edren", "cael", "lira", "torren", "sable", "maren"]:
		var abilities: Array = DataManager.load_abilities(cid)
		var ids: Array[String] = []
		for a: Variant in abilities:
			if a is Dictionary:
				var aid: String = (a as Dictionary).get("id", "")
				assert_false(ids.has(aid), "Duplicate ability ID '%s' in %s" % [aid, cid])
				ids.append(aid)
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_abilities_screen.gd
git commit -m "test(engine): add abilities screen tests — resolution, cost format, integration"
```

---

## Chunk 2: Abilities Screen UI + Menu Wiring

### Task 4: Create menu_abilities.gd

**Files:**
- Create: `game/scripts/ui/menu_abilities.gd`

- [ ] **Step 1: Write the screen script**

Follow `menu_magic.gd` pattern exactly but simpler (view-only, no
TARGET_SELECT state). Key differences from Magic screen:
- No target selection — ui_accept does nothing (view only)
- Cost column uses `AbilityHelpers.format_cost()` instead of fixed "MP N"
- Character header shows resource label from `AbilityHelpers.get_resource_label()`
- Labels loaded row-major (same fix as magic screen)
- No _process needed (no feedback timer — view only)
- Story-gated abilities excluded by AbilityHelpers filtering

The grid label format:
```
"%-12s %6s" % [ability_name, formatted_cost]
```

Truncate ability names longer than 12 chars.

- [ ] **Step 2: Run gdlint + gdformat, verify under 200 lines**

- [ ] **Step 3: Commit**

```bash
git add game/scripts/ui/menu_abilities.gd
git commit -m "feat(engine): add Abilities sub-screen with cost-adaptive display"
```

### Task 5: Add AbilitiesScreen to menu.tscn

**Files:**
- Modify: `game/scenes/overlay/menu.tscn`

- [ ] **Step 1: Add AbilitiesScreen node tree under SubScreen**

Same layout as MagicScreen. Add new ext_resource for menu_abilities.gd.

```
AbilitiesScreen (Control, script=menu_abilities.gd, visible=false)
  DescLabel (Label, top area)
  CharInfo (HBoxContainer)
    NameLabel (Label)
    LvLabel (Label)
    ResourceLabel (Label)
  AbilityGrid (HBoxContainer)
    LeftCol (VBoxContainer) — Ability0..Ability5
    RightCol (VBoxContainer) — Ability6..Ability11
```

- [ ] **Step 2: Commit**

```bash
git add game/scenes/overlay/menu.tscn
git commit -m "feat(engine): add AbilitiesScreen node tree to menu scene"
```

### Task 6: Wire Abilities command in menu_overlay.gd

**Files:**
- Modify: `game/scripts/ui/menu_overlay.gd` (337 lines)

- [ ] **Step 1: Unstub Abilities command**

Change index 2 from `"stubbed": true` to `"stubbed": false`.

- [ ] **Step 2: Add @onready reference**

```gdscript
@onready var _abilities_screen: Control = $SubScreen/AbilitiesScreen
```

- [ ] **Step 3: Wire _open_sub_screen_for_character**

Add case in the match statement:
```gdscript
"Abilities":
    _open_sub_screen(_abilities_screen)
    if _abilities_screen.has_method("open"):
        _abilities_screen.open(character_id)
```

- [ ] **Step 4: Add to _hide_all_sub_screens**

Add `_abilities_screen.visible = false` alongside the other screens.

- [ ] **Step 5: Run gdlint + gdformat, verify <= 400 lines**

- [ ] **Step 6: Commit**

```bash
git add game/scripts/ui/menu_overlay.gd
git commit -m "feat(engine): unstub Abilities command in menu overlay"
```

---

## Chunk 3: Cross-Reference Tests + Gap Tracker

### Task 7: Add ability cross-reference tests

**Files:**
- Modify: `game/tests/test_cross_references.gd`

- [ ] **Step 1: Add ability file validation tests**

```gdscript
func test_all_ability_files_exist() -> void:
	for cid: String in ["edren", "cael", "lira", "torren", "sable", "maren"]:
		var path: String = "res://data/abilities/%s.json" % cid
		assert_true(FileAccess.file_exists(path), "Ability file for %s should exist" % cid)


func test_all_ability_files_valid_schema() -> void:
	for cid: String in ["edren", "cael", "lira", "torren", "sable", "maren"]:
		var abilities: Array = DataManager.load_abilities(cid)
		assert_gt(abilities.size(), 0, "%s should have abilities" % cid)
		for a: Variant in abilities:
			assert_true(a is Dictionary, "Each ability should be a Dictionary")
			var d: Dictionary = a as Dictionary
			assert_true(d.has("id"), "Ability must have id")
			assert_true(d.has("name"), "Ability must have name")
			assert_true(d.has("cost_type"), "Ability must have cost_type")
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_cross_references.gd
git commit -m "test(engine): add ability file existence and schema cross-reference tests"
```

### Task 8: Verify tests and update gap tracker

- [ ] **Step 1: Run all tests**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ -s addons/gut/gut_cmdln.gd
```

All tests must pass (324 existing + ~18 new = ~342).

- [ ] **Step 2: Update gap 3.4 in game-dev-gaps.md**

Check off Abilities screen. Update notes.

- [ ] **Step 3: Commit and push**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap 3.4 — Abilities screen complete (8 of 9 screens)"
git push
```

**Next steps:**
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening
3. Address Copilot comments + gap analysis (autonomous)
