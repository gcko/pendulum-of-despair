# Formation Menu Screen — Design Spec

> **Gap:** 3.4 Phase 2 (Formation screen)
> **Goal:** Let the player reorder party members and toggle front/back
> row from the main menu.

---

## 1. Scope

### In Scope

- Formation sub-screen in menu overlay (menu_formation.gd)
- Vertical list of all party members (active above divider, reserve below)
- Swap any two members' positions (including across active/reserve boundary)
- Row toggle (F↔B) on active members via shoulder button
- PartyState methods: toggle_row, swap_formation_positions, get_formation_list, get_row
- Full test suite

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Guest NPC lock icons (Cordwyn, Kerra) | No guest system | 4.4 |
| Overworld sprite change on lead swap | No overworld map | 4.3 |
| 16x20 walking sprites | No sprite assets | 4.8 |
| Minimum 1 active enforcement | Only matters with 3+ members | 4.4 |
| Cael absence handling | Interlude content | 4.4 |

---

## 2. Components

### PartyState additions (~25 lines)

```gdscript
func toggle_row(character_id: String) -> void
```
Flips the character's row in `formation.rows` between "front" and "back".
If character_id not in rows dict, defaults to "front" then toggles.

```gdscript
func get_row(character_id: String) -> String
```
Returns "front" or "back" from `formation.rows`. Defaults to "front"
if not present.

```gdscript
func get_formation_list() -> Array[Dictionary]
```
Returns all members in formation order: active members first (in
`formation.active` order), then reserve members. Each dict is the
member dict with an added `_is_active: bool` and `_formation_index: int`.

```gdscript
func swap_formation_positions(idx_a: int, idx_b: int) -> void
```
Swaps two positions in the combined formation list. Handles the
active/reserve boundary: if a swap moves a member across the boundary
(e.g., active slot 3 swaps with reserve slot 0), the `formation.active`
array is updated accordingly.

### menu_formation.gd (~180 lines)

**Public API:**
- `open() -> void` (no character_id — shows all members)
- `close() -> void`
- `handle_input(event: InputEvent) -> bool`

**States:** `enum FormationState { BROWSING, SWAP_SELECT }`

**open() flow:**
1. Load formation list from `PartyState.get_formation_list()`
2. Build member display rows
3. Set cursor to 0, state to BROWSING

**BROWSING input:**
- ui_up/ui_down: move cursor through all members
- ui_accept: enter SWAP_SELECT, mark current as first pick
- ui_page_up/ui_page_down: toggle row on active member
- ui_cancel: return false

**SWAP_SELECT input:**
- ui_up/ui_down: move cursor to second target
- ui_accept: execute swap via PartyState, refresh display, return to BROWSING
- ui_cancel: cancel swap, return to BROWSING

**Display per member:**
```
Active:  "EDREN    F  LV 12  HP 680/800"
Reserve: "MAREN       LV 10  HP 440/440"
```

Selected member in COLOR_SELECTED (#ffff88).
Swap source highlighted in a distinct color (COLOR_SWAP = #88ffff).

### Scene nodes (added to menu.tscn)

```
FormationScreen (Control, script=menu_formation.gd, visible=false)
  TitleLabel (Label: "Formation")
  MemberList (VBoxContainer)
    Member0..Member5 (6 Labels)
  DividerLabel (Label)
  SwapLabel (Label, visible=false: "Select swap target")
```

6 member label slots supports the full party (4 active + 2 reserve
max). The divider position is dynamic based on active count.

### menu_overlay.gd changes

- Change Formation `"stubbed": true` → `"stubbed": false`
- Formation has `"char_select": false` — routes directly to sub-screen
- Add `@onready var _formation_screen`
- Wire in `_confirm_command()` for Formation (direct open, no character)
- Add to `_hide_all_sub_screens()`

Note: Formation is the first direct sub-screen that doesn't take a
character_id. The `_confirm_command()` flow for `char_select: false`
currently handles Item, Config, Save. Formation needs a new case
alongside those, calling `_formation_screen.open()` (no args).

---

## 3. Navigation Detail

### Row toggle
`ui_page_up` or `ui_page_down` on an active member calls
`PartyState.toggle_row(character_id)` and refreshes the display.
On a reserve member, row toggle does nothing (reserve members have
no row assignment displayed).

### Swap
1. Press accept on Member A → state becomes SWAP_SELECT, Member A
   highlighted in cyan
2. Move cursor to Member B
3. Press accept → `PartyState.swap_formation_positions(a, b)` →
   refresh list → state returns to BROWSING
4. Press cancel → cancel swap, return to BROWSING

Swapping across the active/reserve boundary moves one member into
active and one into reserve.

---

## 4. Test Plan

### test_formation_screen.gd (NEW, ~100 lines)

**PartyState formation methods:**
- `test_toggle_row_front_to_back` — Edren starts front, toggle → back
- `test_toggle_row_back_to_front` — set to back, toggle → front
- `test_toggle_row_unknown_character` — no crash, adds as "back"
- `test_get_row_default_front` — unknown character returns "front"
- `test_get_row_returns_correct` — Edren "front", verified
- `test_get_formation_list_order` — active members first, reserve after
- `test_get_formation_list_has_is_active` — each entry has _is_active flag
- `test_swap_within_active` — swap indices 0 and 1, verify order changed
- `test_swap_active_to_reserve` — swap active index with reserve index

---

## 5. File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/ui/menu_formation.gd` | CREATE | Formation sub-screen |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add FormationScreen nodes |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Unstub Formation, wire direct open |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add 4 formation methods |
| `game/tests/test_formation_screen.gd` | CREATE | Unit + integration tests |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 3.4 |
