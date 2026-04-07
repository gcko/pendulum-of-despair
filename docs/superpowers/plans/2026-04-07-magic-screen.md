# Magic Menu Screen Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Magic sub-screen to the main menu that shows a character's known spells in a two-column grid and allows field-casting healing/buff spells on party members.

**Architecture:** New `menu_magic.gd` screen following the `menu_items.gd` pattern (open/close/handle_input API). Static `spell_helpers.gd` resolves known spells from JSON data. PartyState gains spend_mp/heal_member methods. Tests cover spell resolution, field casting, and integration.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.6.0 testing framework

**Spec:** `docs/superpowers/specs/2026-04-07-magic-screen-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/ui/spell_helpers.gd` | CREATE | Static spell resolution + field cast helpers |
| `game/scripts/ui/menu_magic.gd` | CREATE | Magic sub-screen script |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add MagicScreen node tree under SubScreen |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Unstub Magic command, wire dispatch |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add spend_mp(), heal_member() (at 400 lines — compact to fit) |
| `game/tests/test_magic_screen.gd` | CREATE | Spell resolution + field cast + screen tests |
| `game/tests/test_cross_references.gd` | MODIFY | Add spell learned_by character validation |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 3.4 |

---

## Chunk 1: Spell Helpers + PartyState Methods + Tests

### Task 1: Create spell_helpers.gd

**Files:**
- Create: `game/scripts/ui/spell_helpers.gd`

- [ ] **Step 1: Create the static helper**

```gdscript
extends RefCounted
## Static helpers for resolving known spells and field-cast effects.

const TRADITIONS: Array[String] = [
    "ley_line", "forgewright", "spirit", "streetwise", "void"
]
const FIELD_CATEGORIES: Array[String] = ["healing", "buff", "utility"]


## Get all spells a character knows at their current level.
## Scans all tradition JSONs, filters by character + level.
## Returns Array[Dictionary] sorted by tier then MP cost.
static func get_known_spells(character_id: String, level: int) -> Array:
    var result: Array = []
    for tradition: String in TRADITIONS:
        var spells: Array = DataManager.load_spells(tradition)
        for spell: Variant in spells:
            if not spell is Dictionary:
                continue
            var s: Dictionary = spell as Dictionary
            for entry: Variant in s.get("learned_by", []):
                if not entry is Dictionary:
                    continue
                var e: Dictionary = entry as Dictionary
                if e.get("character", "") == character_id:
                    var req: int = e.get("level", 999)
                    if req <= level:
                        result.append(s)
                        break
    result.sort_custom(_sort_by_tier_then_cost)
    return result


## Whether a spell can be cast from the field menu (not in battle).
static func can_field_cast(spell: Dictionary) -> bool:
    return spell.get("category", "") in FIELD_CATEGORIES


## Calculate field-cast healing amount per combat-formulas.md.
## Field healing: MAG * spell_power * 0.8 (no defense, no variance).
static func get_field_heal_amount(caster_mag: int, spell: Dictionary) -> int:
    var power: int = spell.get("power", 0)
    if power <= 0:
        return 0
    return int(caster_mag * power * 0.8)


## Sort comparator: by tier ascending, then MP cost ascending.
static func _sort_by_tier_then_cost(a: Dictionary, b: Dictionary) -> bool:
    var ta: int = a.get("tier", 0)
    var tb: int = b.get("tier", 0)
    if ta != tb:
        return ta < tb
    return a.get("mp_cost", 0) < b.get("mp_cost", 0)
```

- [ ] **Step 2: Run gdlint + gdformat**

```bash
gdlint game/scripts/ui/spell_helpers.gd
gdformat game/scripts/ui/spell_helpers.gd
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/ui/spell_helpers.gd
git commit -m "feat(engine): add spell_helpers.gd — known spell resolution + field cast"
```

### Task 2: Add spend_mp and heal_member to PartyState

**Files:**
- Modify: `game/scripts/autoload/party_state.gd` (currently 400 lines — MUST compact to fit)

- [ ] **Step 1: Read party_state.gd and find compaction targets**

The file is at exactly 400 lines. Adding spend_mp (~7 lines) and
heal_member (~8 lines) requires freeing ~15 lines. Targets:
- Compact `remove_item` (merge var declarations)
- Compact `_add_character` (merge equipment dict init into one line)
- Remove redundant doc comments (single-line instead of multi-line)

- [ ] **Step 2: Add the two methods**

Add after the existing `rest_at_inn()` method:

```gdscript
## Deduct MP from a party member. Returns false if insufficient.
func spend_mp(character_id: String, amount: int) -> bool:
    var m: Dictionary = get_member(character_id)
    if m.is_empty() or amount <= 0 or m.get("current_mp", 0) < amount:
        return false
    m["current_mp"] -= amount
    return true


## Heal a party member's HP. Returns actual amount restored.
func heal_member(character_id: String, amount: int) -> int:
    var m: Dictionary = get_member(character_id)
    if m.is_empty() or amount <= 0:
        return 0
    var old: int = m.get("current_hp", 0)
    m["current_hp"] = mini(m.get("max_hp", old), old + amount)
    return m["current_hp"] - old
```

- [ ] **Step 3: Compact existing code to stay under 400 lines**

Reduce line count by ~15 lines through targeted compaction of
existing methods (shorter variable names, merged conditions, etc.).
The file MUST pass gdlint at <= 400 lines after gdformat.

- [ ] **Step 4: Run gdlint + gdformat, verify <= 400 lines**

```bash
gdlint game/scripts/autoload/party_state.gd
gdformat game/scripts/autoload/party_state.gd
wc -l game/scripts/autoload/party_state.gd
```

- [ ] **Step 5: Commit**

```bash
git add game/scripts/autoload/party_state.gd
git commit -m "feat(engine): add PartyState.spend_mp() and heal_member()"
```

### Task 3: Write spell resolution and field cast tests

**Files:**
- Create: `game/tests/test_magic_screen.gd`

- [ ] **Step 1: Create test file with spell resolution tests**

```gdscript
extends GutTest

func before_each() -> void:
    DataManager.clear_cache()
    PartyState.initialize_new_game()


func test_known_spells_cael_level_1() -> void:
    # Cael at Lv1 knows: Linebolt, Leybalm, Ember Lance
    var spells: Array = SpellHelpers.get_known_spells("cael", 1)
    assert_eq(spells.size(), 3, "Cael Lv1 should know 3 spells")
    var names: Array = spells.map(func(s: Dictionary) -> String: return s.get("name", ""))
    assert_has(names, "Linebolt", "Cael knows Linebolt at Lv1")
    assert_has(names, "Leybalm", "Cael knows Leybalm at Lv1")
    assert_has(names, "Ember Lance", "Cael knows Ember Lance at Lv1")


func test_known_spells_edren_level_1() -> void:
    # Edren at Lv1 knows 0 spells (first spell at Lv3)
    var spells: Array = SpellHelpers.get_known_spells("edren", 1)
    assert_eq(spells.size(), 0, "Edren Lv1 should know 0 spells")


func test_known_spells_edren_level_5() -> void:
    # Edren at Lv5 knows: Leybalm(3), Mend(5), Ironhide(5)
    var spells: Array = SpellHelpers.get_known_spells("edren", 5)
    assert_eq(spells.size(), 3, "Edren Lv5 should know 3 spells")


func test_higher_level_spells_excluded() -> void:
    # Cael Lv1 should NOT have Lv3+ spells
    var spells: Array = SpellHelpers.get_known_spells("cael", 1)
    for s: Dictionary in spells:
        for entry: Variant in s.get("learned_by", []):
            if entry is Dictionary and (entry as Dictionary).get("character", "") == "cael":
                assert_true(
                    (entry as Dictionary).get("level", 999) <= 1,
                    "Spell %s should be Lv1 or below" % s.get("name", "")
                )


func test_unknown_character_returns_empty() -> void:
    var spells: Array = SpellHelpers.get_known_spells("nonexistent", 50)
    assert_eq(spells.size(), 0, "Unknown character should have 0 spells")


func test_spells_sorted_by_tier_then_cost() -> void:
    var spells: Array = SpellHelpers.get_known_spells("cael", 20)
    for i: int in range(1, spells.size()):
        var prev_tier: int = spells[i - 1].get("tier", 0)
        var curr_tier: int = spells[i].get("tier", 0)
        if prev_tier == curr_tier:
            assert_true(
                spells[i - 1].get("mp_cost", 0) <= spells[i].get("mp_cost", 0),
                "Same-tier spells should be sorted by MP cost"
            )
        else:
            assert_true(prev_tier < curr_tier, "Spells should be sorted by tier")


func test_can_field_cast_healing() -> void:
    var spell: Dictionary = {"category": "healing"}
    assert_true(SpellHelpers.can_field_cast(spell), "Healing spells are field-castable")


func test_can_field_cast_offensive_blocked() -> void:
    var spell: Dictionary = {"category": "offensive"}
    assert_false(SpellHelpers.can_field_cast(spell), "Offensive spells are NOT field-castable")


func test_can_field_cast_buff() -> void:
    var spell: Dictionary = {"category": "buff"}
    assert_true(SpellHelpers.can_field_cast(spell), "Buff spells are field-castable")


func test_can_field_cast_debuff_blocked() -> void:
    var spell: Dictionary = {"category": "debuff"}
    assert_false(SpellHelpers.can_field_cast(spell), "Debuff spells are NOT field-castable")


func test_field_heal_amount_formula() -> void:
    # Formula: MAG * power * 0.8
    var spell: Dictionary = {"power": 10}
    var result: int = SpellHelpers.get_field_heal_amount(20, spell)
    assert_eq(result, 160, "20 MAG * 10 power * 0.8 = 160")


func test_field_heal_zero_power() -> void:
    var spell: Dictionary = {"power": 0}
    var result: int = SpellHelpers.get_field_heal_amount(20, spell)
    assert_eq(result, 0, "Zero power spell heals 0")


func test_spend_mp_deducts() -> void:
    # Cael starts with 15 MP at Lv1
    var cael: Dictionary = PartyState.get_member("cael")
    var starting_mp: int = cael.get("current_mp", 0)
    assert_true(starting_mp > 0, "Cael should have MP")
    var ok: bool = PartyState.spend_mp("cael", 3)
    assert_true(ok, "spend_mp should succeed")
    assert_eq(PartyState.get_member("cael").get("current_mp", 0), starting_mp - 3)


func test_spend_mp_insufficient_rejected() -> void:
    var cael: Dictionary = PartyState.get_member("cael")
    var mp: int = cael.get("current_mp", 0)
    var ok: bool = PartyState.spend_mp("cael", mp + 100)
    assert_false(ok, "spend_mp should fail with insufficient MP")
    assert_eq(PartyState.get_member("cael").get("current_mp", 0), mp, "MP unchanged")


func test_heal_member_restores_hp() -> void:
    var edren: Dictionary = PartyState.get_member("edren")
    edren["current_hp"] = 50
    var healed: int = PartyState.heal_member("edren", 30)
    assert_eq(healed, 30, "Should heal 30")
    assert_eq(edren.get("current_hp", 0), 80)


func test_heal_member_clamps_to_max() -> void:
    var edren: Dictionary = PartyState.get_member("edren")
    var max_hp: int = edren.get("max_hp", 100)
    edren["current_hp"] = max_hp - 10
    var healed: int = PartyState.heal_member("edren", 50)
    assert_eq(healed, 10, "Should only heal 10 to reach max")
    assert_eq(edren.get("current_hp", 0), max_hp)
```

- [ ] **Step 2: Add const for SpellHelpers at top of test**

The test file needs access to SpellHelpers:
```gdscript
const SpellHelpers = preload("res://scripts/ui/spell_helpers.gd")
```

- [ ] **Step 3: Run gdlint + gdformat**

```bash
gdlint game/tests/test_magic_screen.gd
gdformat game/tests/test_magic_screen.gd
```

- [ ] **Step 4: Commit**

```bash
git add game/tests/test_magic_screen.gd
git commit -m "test(engine): add magic screen tests — spell resolution, field cast, MP"
```

---

## Chunk 2: Magic Screen UI + Menu Wiring

### Task 4: Create menu_magic.gd

**Files:**
- Create: `game/scripts/ui/menu_magic.gd`

The screen follows the exact same pattern as `menu_items.gd`:
- `open(character_id)` / `close()` / `handle_input(event) -> bool`
- Two states: BROWSING and TARGET_SELECT
- Two-column grid with cursor navigation

- [ ] **Step 1: Write the full screen script**

Key behaviors:
- `open()`: resolve spells via SpellHelpers, populate grid labels
- Browse: ui_up/down navigate rows, ui_left/right switch columns
- Accept on field-castable spell → TARGET_SELECT
- Accept on offensive spell → "Can't use here." feedback
- Target select: pick party member, cast spell, deduct MP, heal, refresh
- Cancel from target → back to browse; cancel from browse → return false

The grid has 12 label slots (6 rows x 2 columns). If fewer than 12
spells, remaining labels are hidden. If more than 12, implement
scroll offset.

Spell labels show: `"%-16s MP%3d" % [name, mp_cost]`
Offensive spells use COLOR_DISABLED. Selected spell uses COLOR_SELECTED.

Target labels show: `"%s  HP %d/%d" % [name, current_hp, max_hp]`

- [ ] **Step 2: Run gdlint + gdformat, verify under 250 lines**

```bash
gdlint game/scripts/ui/menu_magic.gd
gdformat game/scripts/ui/menu_magic.gd
wc -l game/scripts/ui/menu_magic.gd
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/ui/menu_magic.gd
git commit -m "feat(engine): add Magic sub-screen with two-column spell grid"
```

### Task 5: Add MagicScreen to menu.tscn

**Files:**
- Modify: `game/scenes/overlay/menu.tscn`

- [ ] **Step 1: Add MagicScreen node tree under SubScreen**

Add a new ext_resource for menu_magic.gd, then add the node tree:

```
MagicScreen (Control, script=menu_magic.gd, visible=false)
  DescLabel (Label, position top, full width)
  CharInfo (HBoxContainer)
    NameLabel (Label)
    LvLabel (Label)
    HPLabel (Label)
    MPLabel (Label)
  SpellGrid (HBoxContainer, fills main area)
    LeftCol (VBoxContainer)
      Spell0..Spell5 (6 Labels)
    RightCol (VBoxContainer)
      Spell6..Spell11 (6 Labels)
  TargetPanel (VBoxContainer, visible=false)
    Target0..Target3 (4 Labels)
```

All positions must be integer values. Use the same panel sizing as
other sub-screens (fills the SubScreen area: 320x~140).

- [ ] **Step 2: Verify @onready paths match script expectations**

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn
git commit -m "feat(engine): add MagicScreen node tree to menu scene"
```

### Task 6: Wire Magic command in menu_overlay.gd

**Files:**
- Modify: `game/scripts/ui/menu_overlay.gd`

- [ ] **Step 1: Unstub Magic command**

Change line 17 from:
```gdscript
{"name": "Magic", "char_select": true, "stubbed": true},
```
to:
```gdscript
{"name": "Magic", "char_select": true, "stubbed": false},
```

- [ ] **Step 2: Add MagicScreen @onready reference**

Add with the other screen references:
```gdscript
@onready var _magic_screen: Control = $SubScreen/MagicScreen
```

- [ ] **Step 3: Wire _open_sub_screen_for_character**

Add a case in the match statement (around line 173):
```gdscript
"Magic":
    _open_sub_screen(_magic_screen)
    if _magic_screen.has_method("open"):
        _magic_screen.open(character_id)
```

- [ ] **Step 4: Run gdlint + gdformat, verify <= 400 lines**

```bash
gdlint game/scripts/ui/menu_overlay.gd
gdformat game/scripts/ui/menu_overlay.gd
wc -l game/scripts/ui/menu_overlay.gd
```

- [ ] **Step 5: Commit**

```bash
git add game/scripts/ui/menu_overlay.gd
git commit -m "feat(engine): unstub Magic command in menu overlay"
```

---

## Chunk 3: Cross-Reference Tests + Gap Tracker

### Task 7: Add spell cross-reference test

**Files:**
- Modify: `game/tests/test_cross_references.gd`

- [ ] **Step 1: Add test_all_spell_learned_by_characters_exist**

```gdscript
func test_all_spell_learned_by_characters_exist() -> void:
    var valid_chars: Array[String] = ["edren", "cael", "maren", "lira", "torren", "sable"]
    var bad: Array[String] = []
    for tradition: String in ["ley_line", "forgewright", "spirit", "streetwise", "void"]:
        var spells: Array = DataManager.load_spells(tradition)
        for spell: Variant in spells:
            if not spell is Dictionary:
                continue
            var s: Dictionary = spell as Dictionary
            for entry: Variant in s.get("learned_by", []):
                if not entry is Dictionary:
                    continue
                var cid: String = (entry as Dictionary).get("character", "")
                if cid != "" and cid not in valid_chars:
                    bad.append("%s: unknown character '%s'" % [s.get("id", "?"), cid])
    assert_eq(bad.size(), 0, "All spell learned_by characters should be valid: %s" % str(bad))
```

- [ ] **Step 2: Run gdlint + gdformat**

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_cross_references.gd
git commit -m "test(engine): add spell learned_by character cross-reference test"
```

### Task 8: Verify and update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Run all tests to verify everything passes**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ -s addons/gut/gut_cmdln.gd
```

All tests must pass (305 existing + ~15 new = ~320).

- [ ] **Step 2: Update gap 3.4**

In the Phase 2 checklist, check off "Magic screen". Add note about
what was implemented. Update the percentage.

- [ ] **Step 3: Commit and push**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap 3.4 — Magic screen complete"
git push
```

**Next steps:**
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening
3. Address Copilot comments + gap analysis (autonomous)
