# Abilities Menu Screen — Design Spec

> **Gap:** 3.4 Phase 2 (Abilities screen)
> **Goal:** Let the player view each character's unique ability set
> from the main menu. View-only — abilities are battle commands.

---

## 1. Scope

### In Scope

- Abilities sub-screen in menu overlay (menu_abilities.gd)
- Two-column ability grid (12 slots, same layout as Magic screen)
- Character info header with name, LV, and character-specific resource
- Cost display adapts per cost_type (AP/MP/AC/WG/MP+CD/Passive)
- Description area showing selected ability's effect text
- Story-gated abilities excluded unless EventFlags condition met
- Level-gated abilities excluded if character level too low
- Static ability resolution helper (ability_helpers.gd)
- DataManager.load_abilities() method
- Full test suite (unit + integration + cross-reference)

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Field-use of abilities | Abilities are battle-only commands | 3.3 Battle integration |
| AP gauge widget (Edren) | Only fills during battle (starts at 0) | Battle UI |
| AC gauge widget (Lira) | Read-only value in menu, full tracking in battle | Battle UI |
| Weave Gauge bar (Maren) | Only fills during battle | Battle UI |
| Favor pips per spirit (Torren) | Requires Favor persistence in PartyState | PartyState + Battle UI |
| Cooldown pips (Sable) | Only meaningful during battle | Battle UI |
| Active stance/rally/device indicators | Only exist during battle | Battle UI |
| Stolen goods counter (Sable) | Only in battle context | Battle UI |
| Combo abilities (combos.json) | Cross-character system, separate UI | Future |
| Per-character screen scripts | Approach B rejected — data-driven instead | N/A |
| Resource gauge widgets | Approach C rejected — premature for menu-only | Future |

### Tech Debt (track in beads)

1. **Battle ability UI** — When battle integration needs unique resource
   displays (AP gauge, Favor pips, Cooldown pips, Weave bar), extract
   reusable widgets from the battle UI, not from this menu screen.
2. **Favor persistence** — Torren's Spirit Favor (0-3 per spirit) needs
   to be tracked in PartyState for both menu display and battle state.
   Currently not tracked anywhere.
3. **AC tracking** — Lira's Arcanite Charges persist across battles but
   PartyState doesn't track them yet. Menu shows hardcoded 12/12.

---

## 2. Components

### ability_helpers.gd (static helper, ~40 lines)

```gdscript
static func get_known_abilities(character_id: String, level: int) -> Array
```

Loads abilities from `DataManager.load_abilities(character_id)`.
Filters by:
- `level_learned <= level` (or `level_learned == null` for story-gated)
- Story-gated: include only if `EventFlags.get_flag(story_event)` is true

Returns filtered array sorted by level_learned ascending.

```gdscript
static func format_cost(ability: Dictionary) -> String
```

Returns display string based on `cost_type`:
- `"ap"` → `"%d AP" % cost_value`
- `"mp"` → `"%d MP" % cost_value`
- `"ac"` → `"%d AC" % cost_value`
- `"wg"` → `"%d WG" % cost_value`
- `"mp_cd"` → `"%d MP/%dt" % [cost_value, cooldown]`
- `"none"` → `"Passive"`
- default → `cost` field as-is (human-readable fallback)

### menu_abilities.gd (screen script, ~180 lines)

Same pattern as menu_magic.gd but simpler (no TARGET_SELECT state):

**Public API:**
- `open(character_id: String) -> void`
- `close() -> void`
- `handle_input(event: InputEvent) -> bool`

**Single state: BROWSING**
- ui_up/ui_down: navigate rows (cursor ± GRID_COLS)
- ui_left/ui_right: switch columns (cursor ± 1)
- ui_accept: show description feedback (no action — view only)
- ui_cancel: return false (menu_overlay handles close)

**open() flow:**
1. Store character_id, load member data
2. Resolve abilities via `AbilityHelpers.get_known_abilities()`
3. Update character header with name, LV, resource label
4. Populate ability grid labels with name + formatted cost
5. Set cursor to 0, update display

**Character resource header:**
- Edren: "AP 0/10"
- Cael: "MP {current_mp}/{max_mp}"
- Lira: "AC 12/12" (hardcoded until AC tracking exists)
- Torren: "MP {current_mp}/{max_mp}"
- Sable: "MP {current_mp}/{max_mp}"
- Maren: "WG 0/100"

Resource label determined by character's command type from the first
ability's `command` field, or from a static mapping.

### DataManager.load_abilities() (~5 lines)

```gdscript
func load_abilities(character_id: String) -> Array:
    var path: String = "res://data/abilities/%s.json" % character_id
    if not FileAccess.file_exists(path):
        return []
    var data: Variant = load_json(path)
    if data is Dictionary and data.has("abilities"):
        return data["abilities"]
    return []
```

### Scene nodes (added to menu.tscn)

```
AbilitiesScreen (Control, script=menu_abilities.gd, visible=false)
  DescLabel (Label)
  CharInfo (HBoxContainer)
    NameLabel (Label)
    LvLabel (Label)
    ResourceLabel (Label)
  AbilityGrid (HBoxContainer)
    LeftCol (VBoxContainer) — Ability0..Ability5
    RightCol (VBoxContainer) — Ability6..Ability11
```

### menu_overlay.gd changes

- Remove "Abilities" from stubbed commands (index 2)
- Add `@onready var _abilities_screen: Control = $SubScreen/AbilitiesScreen`
- Wire in `_open_sub_screen_for_character()`:
  ```
  "Abilities":
      _open_sub_screen(_abilities_screen)
      _abilities_screen.open(character_id)
  ```
- Add to `_hide_all_sub_screens()`

---

## 3. Cost Display Examples

| Character | Ability | cost_type | cost_value | cooldown | Display |
|-----------|---------|-----------|------------|----------|---------|
| Edren | Ironwall | ap | 0 | null | "0 AP" |
| Edren | Riposte | ap | 2 | null | "2 AP" |
| Cael | Hold the Line | mp | 6 | null | "6 MP" |
| Lira | Shock Coil | ac | 2 | null | "2 AC" |
| Torren | Thornveil | mp | 5 | null | "5 MP" |
| Sable | Smokescreen | mp_cd | 4 | 2 | "4 MP/2t" |
| Sable | Filch | none | 0 | 0 | "Passive" |
| Maren | Ley Surge | wg | 50 | null | "50 WG" |
| Maren | Resonance | mp | 8 | null | "8 MP" |

---

## 4. Test Plan

### test_abilities_screen.gd (NEW, ~120 lines)

**Ability resolution tests:**
- `test_edren_abilities_level_1` — Edren Lv1: only Ironwall (level_learned=1)
- `test_cael_abilities_level_1` — Cael Lv1: only Hold the Line
- `test_edren_abilities_level_10` — Edren Lv10: Ironwall + Riposte + Rampart
- `test_all_6_characters_have_ability_data` — JSON files exist for all 6
- `test_story_gated_excluded_without_flag` — ability with story_gated=true
  excluded when EventFlags doesn't have the flag
- `test_unknown_character_returns_empty` — nonexistent returns []
- `test_abilities_sorted_by_level` — verify ascending level order

**Cost formatting tests:**
- `test_format_cost_ap` — {cost_type:"ap", cost_value:2} → "2 AP"
- `test_format_cost_mp` — {cost_type:"mp", cost_value:6} → "6 MP"
- `test_format_cost_ac` — {cost_type:"ac", cost_value:3} → "3 AC"
- `test_format_cost_wg` — {cost_type:"wg", cost_value:50} → "50 WG"
- `test_format_cost_mp_cd` — {cost_type:"mp_cd", cost_value:4, cooldown:2} → "4 MP/2t"
- `test_format_cost_none` — {cost_type:"none"} → "Passive"

**Integration tests (cross-reference):**
- `test_all_ability_ids_unique_per_character` — no duplicate IDs within a file

### test_cross_references.gd (EXPAND)

- `test_all_ability_files_exist` — 6 character ability JSONs exist
- `test_all_ability_files_valid_schema` — each has "abilities" array

---

## 5. File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/ui/ability_helpers.gd` | CREATE | Ability resolution + cost formatting |
| `game/scripts/ui/menu_abilities.gd` | CREATE | Abilities sub-screen |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add AbilitiesScreen node tree |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Unstub Abilities, wire dispatch |
| `game/scripts/autoload/data_manager.gd` | MODIFY | Add load_abilities() |
| `game/tests/test_abilities_screen.gd` | CREATE | Unit + integration tests |
| `game/tests/test_cross_references.gd` | MODIFY | Ability file validation |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 3.4 |
