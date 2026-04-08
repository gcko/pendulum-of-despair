# Magic Menu Screen — Design Spec

> **Gap:** 3.4 Phase 2 (Magic screen)
> **Goal:** Let the player view and field-cast spells from the main menu.

---

## 1. Scope

### In Scope

- Magic sub-screen in menu overlay (menu_magic.gd)
- Two-column spell grid (12 slots, scroll deferred) per ui-design.md Section 6
- Character info header (name, LV, HP/MP)
- Spell description area showing selected spell's effect text
- Field cast flow: healing spells only → target select → MP deduct → heal
- Offensive spells greyed out (battle only)
- Static spell resolution helper (spell_helpers.gd)
- PartyState.spend_mp() and heal_member() methods
- Full test suite (unit + integration)

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Battle magic casting | Already works in battle_manager._do_magic() | Done |
| Spell learning animations | Polish pass | 4.4+ |
| Inline status icons in description | Asset dependency | 4.8 |
| Cross-trained MP penalty display | Needs UI indicator design | 3.4 Phase 2 cont. |
| Character portrait in header | No portrait assets yet | 4.8 |
| Maren Weave Gauge display | Abilities screen concern | 3.4 Abilities |

---

## 2. Components

### spell_helpers.gd (static helper, ~40 lines)

```gdscript
static func get_known_spells(character_id: String, level: int) -> Array[Dictionary]
```

Scans all 5 spell tradition JSONs via DataManager.load_spells().
For each spell, checks `learned_by` array for an entry matching
`character_id` with `level <= current_level`. Returns filtered array
sorted by tier then MP cost.

```gdscript
static func can_field_cast(spell: Dictionary) -> bool
```

Returns true if `spell.category` is `"healing"`. Buff/utility deferred.

```gdscript
static func get_field_heal_amount(caster_mag: int, spell: Dictionary) -> int
```

Returns healing amount for field-cast healing spells using the
formula from combat-formulas.md:
`healing = MAG * spell_power * 0.8` (no defense, no variance in field,
capped at 14,999). Returns 0 if spell has no power or power is null.

**Note:** Only healing spells are field-castable. Buff/utility field
effects deferred until effect application system exists.

### menu_magic.gd (screen script, ~220 lines)

Follows `menu_items.gd` pattern exactly:

**Public API:**
- `open(character_id: String) -> void`
- `close() -> void`
- `handle_input(event: InputEvent) -> bool`

**States:** `enum MagicState { BROWSING, TARGET_SELECT }`

**open() flow:**
1. Store character_id, load member data from PartyState
2. Call `SpellHelpers.get_known_spells(character_id, member.level)`
3. Populate `_spells` array
4. Update character header (name, LV, HP/MP)
5. Build spell grid labels
6. Set cursor to 0, update display

**Browsing input:**
- ui_up/ui_down: move cursor vertically (skip between columns)
- ui_left/ui_right: move cursor between columns
- ui_accept: if `can_field_cast(spell)` → transition to TARGET_SELECT;
  else show "Can't use here." feedback
- ui_cancel: return false (menu_overlay handles close)

**Target select input:**
- ui_up/ui_down: move target cursor among living party members
- ui_accept: cast spell → deduct MP → apply effect → refresh → return to BROWSING
- ui_cancel: return to BROWSING

**Grid navigation:**
Two columns, N rows. Cursor index maps to grid position:
- Column = index % 2
- Row = index / 2
- ui_up/ui_down changes row, ui_left/ui_right changes column

### Scene nodes (added to menu.tscn)

```
MagicScreen (Control, script=menu_magic.gd)
  DescLabel (Label, top area)
  CharInfo (HBoxContainer)
    NameLabel (Label)
    LvLabel (Label)
    HPLabel (Label)
    MPLabel (Label)
  SpellGrid (HBoxContainer)
    LeftCol (VBoxContainer) — 6 Label nodes (Spell0..Spell5)
    RightCol (VBoxContainer) — 6 Label nodes (Spell6..Spell11)
  TargetPanel (VBoxContainer, initially hidden)
    Target0..Target3 (Labels)
```

12 spell label slots = 6 rows x 2 columns. If character has more
than 12 spells, implement scroll offset (same pattern as items).

### PartyState additions

```gdscript
## Deduct MP from a party member. Returns false if insufficient.
func spend_mp(character_id: String, amount: int) -> bool

## Heal a party member by amount. Returns actual HP restored.
func heal_member(character_id: String, amount: int) -> int
```

These operate on the `members` array by matching `character_id`.

### menu_overlay.gd changes

- Remove "Magic" from the stubbed commands set
- In `_open_sub_screen_for_character()`, add case for command index 1
  (Magic) → call `$SubScreen/MagicScreen.open(character_id)`
- Wire `_close_sub_screen()` to handle MagicScreen

---

## 3. Data Flow

```
User selects Magic → Character
  → menu_overlay dispatches to MagicScreen.open(character_id)
  → SpellHelpers.get_known_spells(id, level)
    → DataManager.load_spells("ley_line") + load_spells("spirit") + ...
    → Filter by character + level
    → Return sorted spell list
  → MagicScreen populates grid
  → User browses, selects healing spell
  → TARGET_SELECT state
  → User picks target
  → PartyState.spend_mp(character_id, spell.mp_cost)
  → SpellHelpers.get_field_heal_amount(caster_mag, spell)
  → PartyState.heal_member(target_id, heal_amount)
  → Refresh display, return to BROWSING
```

---

## 4. Test Plan

### test_magic_screen.gd (NEW, ~150 lines)

**Spell resolution tests:**
- `test_known_spells_for_edren_level_1` — Edren at Lv1 should know 0 or specific spells per data
- `test_known_spells_for_maren_level_1` — Maren starts with several Lv1 spells
- `test_higher_level_spells_excluded` — spell with learn level 10 not returned for Lv5 character
- `test_unknown_character_returns_empty` — nonexistent character_id returns []
- `test_spells_sorted_by_tier_then_cost` — verify sort order

**Field cast tests:**
- `test_can_field_cast_healing` — healing spell returns true
- `test_can_field_cast_offensive_blocked` — offensive spell returns false
- `test_can_field_cast_buff_blocked` — buff spell returns false (deferred)
- `test_field_heal_effect_matches_formula` — verify MAG * power * 0.8

**PartyState integration:**
- `test_spend_mp_deducts` — spend 10 MP from 80 → 70 remaining
- `test_spend_mp_insufficient_rejected` — spend 100 MP from 80 → false, 80 remains
- `test_heal_member_restores_hp` — heal 50 on member with 50/100 HP → 100/100

**Screen integration:**
- `test_empty_spell_list_shows_message` — character with no spells shows "No spells learned."
- `test_offensive_spells_greyed_out` — offensive spell labels use disabled color

### test_cross_references.gd (EXPAND)

- `test_all_spell_learned_by_characters_exist` — every character_id in spell learned_by arrays is a valid character

---

## 5. File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `game/scripts/ui/spell_helpers.gd` | CREATE | Static spell resolution + field cast |
| `game/scripts/ui/menu_magic.gd` | CREATE | Magic sub-screen |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add MagicScreen node tree |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Unstub Magic, wire dispatch |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add spend_mp, heal_member |
| `game/tests/test_magic_screen.gd` | CREATE | Unit + integration tests |
| `game/tests/test_cross_references.gd` | MODIFY | Spell character validation |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 3.4 |
