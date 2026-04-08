# Formation Menu Screen Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Formation sub-screen to the main menu for party reorder (swap) and row toggle (front/back).

**Architecture:** New `menu_formation.gd` following the established menu screen pattern but with `open()` (no character_id) since it shows all members. PartyState gains 4 formation methods. Two-state screen: BROWSING and SWAP_SELECT.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.6.0

**Spec:** `docs/superpowers/specs/2026-04-08-formation-screen-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/autoload/party_state.gd` | MODIFY | Add toggle_row, get_row, get_formation_list, swap_formation_positions (397 lines — tight budget) |
| `game/scripts/ui/menu_formation.gd` | CREATE | Formation sub-screen (~170 lines) |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add FormationScreen nodes |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Unstub Formation, wire direct open (344 lines) |
| `game/tests/test_formation_screen.gd` | CREATE | Unit + integration tests (~100 lines) |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 3.4 |

---

## Chunk 1: PartyState Methods + Tests

### Task 1: Add formation methods to PartyState

**Files:**
- Modify: `game/scripts/autoload/party_state.gd` (397 lines — only 3 lines of room)

The 4 new methods need ~25 lines. PartyState is at 397/400. Must compact
existing code to fit. Target: free ~25 lines through compaction.

- [ ] **Step 1: Add the 4 methods**

Add after the existing `rest_at_inn()` method:

```gdscript
## Get a character's row assignment. Returns "front" or "back".
func get_row(character_id: String) -> String:
	return formation.get("rows", {}).get(character_id, "front")

## Toggle a character's row between front and back.
func toggle_row(character_id: String) -> void:
	var rows: Dictionary = formation.get("rows", {})
	rows[character_id] = "back" if rows.get(character_id, "front") == "front" else "front"
	formation["rows"] = rows

## Get all members in formation order (active first, then reserve).
## Each dict gets _is_active (bool) and _formation_index (int) added.
func get_formation_list() -> Array:
	var result: Array = []
	var active: Array = formation.get("active", [])
	for i: int in range(active.size()):
		var idx: int = int(active[i])
		if idx >= 0 and idx < members.size():
			var m: Dictionary = members[idx].duplicate()
			m["_is_active"] = true
			m["_formation_index"] = result.size()
			result.append(m)
	for i: int in range(members.size()):
		if i not in active:
			var m: Dictionary = members[i].duplicate()
			m["_is_active"] = false
			m["_formation_index"] = result.size()
			result.append(m)
	return result

## Swap two positions in the combined formation list.
func swap_formation_positions(idx_a: int, idx_b: int) -> void:
	var list: Array = get_formation_list()
	if idx_a < 0 or idx_b < 0 or idx_a >= list.size() or idx_b >= list.size():
		return
	if idx_a == idx_b:
		return
	var active: Array = formation.get("active", [])
	var all_indices: Array = []
	for a_idx: Variant in active:
		all_indices.append(int(a_idx))
	for i: int in range(members.size()):
		if i not in all_indices:
			all_indices.append(i)
	var tmp: int = all_indices[idx_a]
	all_indices[idx_a] = all_indices[idx_b]
	all_indices[idx_b] = tmp
	var new_active: Array[int] = []
	for i: int in range(mini(4, active.size())):
		if i < all_indices.size():
			new_active.append(all_indices[i])
	formation["active"] = new_active
```

- [ ] **Step 2: Compact existing code to stay under 400 lines**

Strategies: shorten doc comments, merge guard conditions, compact
simple getters. The file MUST pass gdlint at <= 400 lines.

- [ ] **Step 3: Run gdlint + gdformat, verify <= 400 lines**

- [ ] **Step 4: Commit**

```bash
git add game/scripts/autoload/party_state.gd
git commit -m "feat(engine): add PartyState formation methods — toggle_row, swap, get_list"
```

### Task 2: Write formation tests

**Files:**
- Create: `game/tests/test_formation_screen.gd`

- [ ] **Step 1: Write the test file**

```gdscript
extends GutTest


func before_each() -> void:
	DataManager.clear_cache()
	PartyState.initialize_new_game()
	EventFlags.clear_all()


# --- Row management ---


func test_get_row_edren_default_front() -> void:
	assert_eq(PartyState.get_row("edren"), "front")


func test_get_row_unknown_defaults_front() -> void:
	assert_eq(PartyState.get_row("nonexistent"), "front")


func test_toggle_row_front_to_back() -> void:
	PartyState.toggle_row("edren")
	assert_eq(PartyState.get_row("edren"), "back")


func test_toggle_row_back_to_front() -> void:
	PartyState.toggle_row("edren")  # front -> back
	PartyState.toggle_row("edren")  # back -> front
	assert_eq(PartyState.get_row("edren"), "front")


func test_toggle_row_unknown_character() -> void:
	# Should not crash, adds character with "back" (toggled from default "front")
	PartyState.toggle_row("nonexistent")
	assert_eq(PartyState.get_row("nonexistent"), "back")


# --- Formation list ---


func test_get_formation_list_returns_all_members() -> void:
	var list: Array = PartyState.get_formation_list()
	assert_eq(list.size(), 2, "Should have 2 members (Edren + Cael)")


func test_get_formation_list_active_first() -> void:
	var list: Array = PartyState.get_formation_list()
	# Both Edren and Cael are active at game start
	for entry: Dictionary in list:
		assert_true(entry.get("_is_active", false), "Both should be active")


func test_get_formation_list_has_formation_index() -> void:
	var list: Array = PartyState.get_formation_list()
	for i: int in range(list.size()):
		assert_eq(list[i].get("_formation_index", -1), i)


# --- Swap ---


func test_swap_within_active() -> void:
	var before: Array = PartyState.get_formation_list()
	var first_id: String = before[0].get("character_id", "")
	var second_id: String = before[1].get("character_id", "")
	PartyState.swap_formation_positions(0, 1)
	var after: Array = PartyState.get_formation_list()
	assert_eq(after[0].get("character_id", ""), second_id)
	assert_eq(after[1].get("character_id", ""), first_id)


func test_swap_same_position_no_change() -> void:
	var before: Array = PartyState.get_formation_list()
	PartyState.swap_formation_positions(0, 0)
	var after: Array = PartyState.get_formation_list()
	assert_eq(before[0].get("character_id", ""), after[0].get("character_id", ""))


func test_swap_out_of_bounds_no_crash() -> void:
	PartyState.swap_formation_positions(0, 99)
	# Should not crash, no change
	var list: Array = PartyState.get_formation_list()
	assert_eq(list.size(), 2)
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_formation_screen.gd
git commit -m "test(engine): add formation screen tests — row toggle, list order, swap"
```

---

## Chunk 2: Formation Screen UI + Menu Wiring

### Task 3: Create menu_formation.gd

**Files:**
- Create: `game/scripts/ui/menu_formation.gd`

- [ ] **Step 1: Write the screen script**

Two states: BROWSING and SWAP_SELECT.

```gdscript
extends Control
## Formation sub-screen: party reorder and row toggle.

const COLOR_SELECTED: Color = Color("#ffff88")
const COLOR_NORMAL: Color = Color("#ccddff")
const COLOR_SWAP: Color = Color("#88ffff")
const COLOR_RESERVE: Color = Color("#999999")
const MAX_MEMBERS: int = 6

enum FormationState { BROWSING, SWAP_SELECT }

var _members: Array = []
var _cursor: int = 0
var _swap_source: int = -1
var _state: FormationState = FormationState.BROWSING

@onready var _title_label: Label = $TitleLabel
@onready var _member_list: VBoxContainer = $MemberList
@onready var _swap_label: Label = $SwapLabel
@onready var _member_labels: Array[Label] = []
```

Key behaviors:
- `open()`: load `PartyState.get_formation_list()`, populate labels
- Labels show: `"%-8s %s  LV%2d  HP %d/%d"` where %s is "F"/"B" for active, blank for reserve
- BROWSING: up/down navigate, accept enters SWAP_SELECT, page_up/down toggle row, cancel returns false
- SWAP_SELECT: up/down navigate, accept executes swap, cancel returns to BROWSING
- After swap or toggle: re-call `get_formation_list()` and refresh labels
- Divider: find the boundary between active and reserve in the list, show a separator

Keep under 180 lines.

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/scripts/ui/menu_formation.gd
git commit -m "feat(engine): add Formation sub-screen with swap and row toggle"
```

### Task 4: Add FormationScreen to menu.tscn

**Files:**
- Modify: `game/scenes/overlay/menu.tscn`

- [ ] **Step 1: Add FormationScreen node tree under SubScreen**

```
FormationScreen (Control, script=menu_formation.gd, visible=false)
  TitleLabel (Label: "Formation")
  MemberList (VBoxContainer)
    Member0..Member5 (6 Labels)
  SwapLabel (Label, visible=false)
```

- [ ] **Step 2: Commit**

```bash
git add game/scenes/overlay/menu.tscn
git commit -m "feat(engine): add FormationScreen node tree to menu scene"
```

### Task 5: Wire Formation command in menu_overlay.gd

**Files:**
- Modify: `game/scripts/ui/menu_overlay.gd` (344 lines)

- [ ] **Step 1: Unstub Formation**

Change line 22 from `"stubbed": true` to `"stubbed": false`.

- [ ] **Step 2: Add @onready reference**

```gdscript
@onready var _formation_screen: Control = $SubScreen/FormationScreen
```

- [ ] **Step 3: Wire in _confirm_command direct sub-screen match**

Add case in the match statement at line 158:
```gdscript
"Formation":
    _open_sub_screen(_formation_screen)
    if _formation_screen.has_method("open"):
        _formation_screen.open()
```

- [ ] **Step 4: Add to _hide_all_sub_screens**

- [ ] **Step 5: Run gdlint + gdformat, verify <= 400 lines**

- [ ] **Step 6: Commit**

```bash
git add game/scripts/ui/menu_overlay.gd
git commit -m "feat(engine): unstub Formation command in menu overlay"
```

---

## Chunk 3: Verification + Gap Tracker

### Task 6: Verify tests and update gap tracker

- [ ] **Step 1: Run all tests**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ -s addons/gut/gut_cmdln.gd
```

All tests must pass (344 existing + ~12 new = ~356).

- [ ] **Step 2: Update gap 3.4**

Check off Formation screen. Update notes. Gap 3.4 is now 9/9 screens
complete (minus Ley Crystal which is a separate P2 item).

- [ ] **Step 3: Commit and push**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap 3.4 — Formation screen complete (9 of 9 screens)"
git push
```

**Next steps:**
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening
3. Address Copilot comments + gap analysis (autonomous)
