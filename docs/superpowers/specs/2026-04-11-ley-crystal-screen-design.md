# Ley Crystal Screen Design Spec

> **Gap:** 3.4 Menu Overlay (final screen — Ley Crystal)
> **Date:** 2026-04-11
> **Status:** Approved
> **Approach:** Hybrid C — equipment slot + crystal state sidecar

## Overview

The Ley Crystal screen is the last of 9 menu sub-screens. It lets the
player browse collected Ley Crystals, review their stats and progression,
and equip them on party members. Inspired by FF6's Esper screen: a
two-level drill-down from list to detail, with equip as a deliberate
confirmation step (not instant-select like FF6, because crystals have
negative effects that need review).

**Source docs:**
- `docs/story/progression.md` — crystal catalog (18 crystals), leveling, stat bonuses, invocations
- `docs/story/ui-design.md` — screen 14 (Ley Crystal layout)
- `docs/story/items.md` — crystal acquisition locations

**Note on invocation data:** All invocation names, effects, power values,
and uses/rest come from `docs/story/progression.md` Section "Ley Crystal
System". The invocation data in `ley_crystals.json` is transcribed from
those tables. `magic.md` covers spells, not crystal invocations.

## UX Flow

```
Menu → Crystal → [character select] → List View → Detail View → Equip
                                         ↑              │
                                         └──── Cancel ───┘
```

**State machine:** `BROWSING` (list) → `DETAIL` (single crystal)

- **BROWSING:** 2-column grid of collected crystals + "Remove" entry.
  Cursor highlights crystal, description panel shows invocation summary.
  Confirm opens detail view. Cancel closes screen.
- **DETAIL:** Full crystal info (XP bar, current bonus, next level
  preview, stat comparison, negative effects). Confirm equips. Cancel
  returns to list.

## Data Layer

### Static Data: `game/data/ley_crystals.json`

All 18 crystals by ID:

| # | ID | Category |
|---|-----|----------|
| 1 | `ember_shard` | Standard |
| 2 | `iron_core` | Standard |
| 3 | `ley_prism` | Standard |
| 4 | `ward_stone` | Standard |
| 5 | `quicksilver` | Standard |
| 6 | `fortune_stone` | Standard |
| 7 | `lifestone` | Standard |
| 8 | `wellspring` | Standard |
| 9 | `spirit_tear` | Standard |
| 10 | `forgewright_core` | Standard |
| 11 | `flame_heart` | Negative |
| 12 | `frost_veil` | Negative |
| 13 | `storm_eye` | Negative |
| 14 | `grey_remnant` | Negative |
| 15 | `dawn_fragment` | Special (diminishing) |
| 16 | `convergence_shard` | Special (secret Lv5) |
| 17 | `null_crystal` | Special (Despair immune) |
| 18 | `caels_echo` | Special (post-game) |

Each entry:

```json
{
  "id": "ember_shard",
  "name": "Ember Shard",
  "element": "flame",
  "description": "Crystallized flame from deep within the Ember Vein.",
  "acquired": "Ember Vein F4: Pendulum Chamber",
  "xp_thresholds": [0, 800, 2500, 6000, 15000],
  "level_bonuses": [
    {"atk": 1},
    {"atk": 1},
    {"atk": 2},
    {"atk": 2},
    {"atk": 2, "def": 1}
  ],
  "invocation": {
    "id": "forge_flare",
    "name": "Forge Flare",
    "element": "flame",
    "description": "Bathes all enemies in flame.",
    "target": "all_enemies",
    "uses_per_rest": 5,
    "level_effects": [
      {"power": 150},
      {"power": 200},
      {"power": 300},
      {"power": 400},
      {"power": 500}
    ]
  },
  "negative_effect": null,
  "secret_lv5": false
}
```

**Negative effect example (Flame Heart):**

```json
"negative_effect": {
  "description": "Wearer randomly hit by Tier 1 Flame spell once per battle",
  "type": "random_self_damage",
  "element": "flame"
}
```

**Secret Lv5 example (Convergence Shard):**

```json
"secret_lv5": true
```

When `secret_lv5` is true and the crystal's current level is < 5, the
UI shows "???" for the Lv5 bonus instead of the actual values.

**Special: Dawn Fragment diminishing returns:**

```json
"level_bonuses": [
  {"atk": 2, "def": 2, "mag": 2, "mdef": 2, "spd": 2, "lck": 2},
  {"atk": 1, "def": 1, "mag": 1, "mdef": 1, "spd": 1, "lck": 1},
  {"atk": 1, "def": 1, "mag": 1, "mdef": 1, "spd": 1, "lck": 1},
  {},
  {}
]
```

Dawn Fragment's Lv5 bonus is empty — the crystal is spent. This is
intentional per the design doc: "Ancient ley energy, almost spent."

### Runtime State: PartyState

New `ley_crystals` dictionary tracking per-crystal XP and level.
**Persistence rule:** Once a crystal is added via `add_ley_crystal()`,
its entry remains in the dict permanently — even if unequipped. An
unowned crystal has no entry. Ownership is determined by `ley_crystals.has(id)`.

```gdscript
var ley_crystals: Dictionary = {}
# {"ember_shard": {"xp": 450, "level": 2}, "iron_core": {"xp": 0, "level": 1}}
```

**New methods:**

```gdscript
## Add a crystal to the party's collection at Lv1 / 0 XP.
func add_ley_crystal(crystal_id: String) -> void

## Get a crystal's runtime state. Returns {"xp": 0, "level": 1} or empty if not owned.
func get_crystal_state(crystal_id: String) -> Dictionary

## Add XP to a crystal. Auto-levels when thresholds are crossed.
## Requires crystal static data (xp_thresholds) from DataManager.
## At Lv5 (max), XP is capped at the Lv5 threshold — excess discarded.
## Multi-level jumps supported (e.g., 0 XP + 3000 → Lv3).
func add_crystal_xp(crystal_id: String, amount: int) -> void

## Get all collected crystal IDs.
func get_collected_crystals() -> Array[String]
```

**Equip/unequip:** Uses existing `equipment.crystal` slot. The
`equip_item()` and `unequip_slot()` methods already handle this since
`"crystal"` is in `SLOT_NAMES`.

**Save/load:** `ley_crystals` dict included in `build_save_data()`
under `world.ley_crystals` and restored in `load_from_save()`.

**New game:** `ley_crystals` starts empty (no crystals at game start).

### DataManager

New methods:

```gdscript
## Load all crystal static data. Returns array of crystal dicts.
func load_ley_crystals() -> Array

## Get a single crystal's static data by ID. Returns empty dict if not found.
func get_ley_crystal(crystal_id: String) -> Dictionary
```

Loads from `res://data/ley_crystals.json`, cached after first load.

## UI Layout

### List View (BROWSING)

```
┌─────────────────────┬──────────────────────────────┐
│   Ley Crystals      │  [portrait]  EDREN           │
│                     │  LV 24                       │
│                     │  HP  892/892   MP  124/124   │
├─────────────────────┴──────────────────────────────┤
│ ▶ Ember Shard   Lv3   Iron Core     Lv2            │
│   Ley Prism     Lv4   Quicksilver   Lv1            │
│   Lifestone     Lv2   Ward Stone    Lv1            │
│ E Wellspring    Lv3                                │
│   Remove                                           │
│                                                    │
├────────────────────────────────────────────────────┤
│ Forge Flare: Bathes all enemies in flame.          │
│ Uses: 5/rest                                       │
└────────────────────────────────────────────────────┘
```

**Panels:**
- **TitlePanel** (top-left): "Ley Crystals" label
- **CharPanel** (top-right): portrait, name, LV, HP/MP
- **CrystalGrid** (middle): 2-column grid, scrollable if > 12 entries
- **DescPanel** (bottom): invocation name + description + uses/rest.
  Negative effects are NOT shown here — only in the detail view.

**Grid entries:**
- Format: `[indicator] Name    LvN`
- `▶` = cursor position
- `E` = equipped by another party member (dimmed, `#666688`)
- Filled dot = equipped on current character
- Last entry: "Remove" (only shown if character has a crystal equipped)

**Navigation:**
- Up/Down: move cursor vertically (step by GRID_COLS=2)
- Left/Right: move cursor horizontally within row
- Confirm: open detail view for highlighted crystal. If "Remove" is
  highlighted, unequip the current crystal immediately (no detail view)
  and refresh the list (Remove entry disappears since nothing is equipped).
- Cancel: close screen

**Grid constants:**

```gdscript
const GRID_ROWS: int = 6
const GRID_COLS: int = 2
const GRID_SIZE: int = 12
```

### Detail View (DETAIL)

When confirm is pressed on a crystal in the list, the CrystalGrid
panel content is replaced with the detail view:

```
┌─────────────────────┬──────────────────────────────┐
│   Ley Crystals      │  [portrait]  EDREN           │
│                     │  LV 24                       │
│                     │  HP  892/892   MP  124/124   │
├─────────────────────┴──────────────────────────────┤
│  Ember Shard                              Lv 3     │
│  XP ████████░░░░░░░░  1,840 / 2,500               │
│                                                    │
│  Current bonus:   ATK +2                           │
│  Next level:      ATK +2  (unchanged)              │
│                                                    │
│  At level up:     ATK +2                           │
│                                                    │
│  Stat change if equipped:                          │
│  ATK  38 → 40 ▲    DEF  35 ──                     │
│  MAG  18 ──         MDEF 22 ──                     │
│  SPD  25 ──         LCK  14 ──                     │
├────────────────────────────────────────────────────┤
│ Forge Flare: Bathes all enemies in flame.          │
│ Power: 300  |  Uses: 5/rest                        │
└────────────────────────────────────────────────────┘
```

**Detail content (top to bottom):**

1. **Header:** Crystal name + current level
2. **XP bar:** Pixel-fill progress bar + `current / threshold` text.
   At Lv5: bar drawn fully filled, text shows "MAX" instead of numbers.
3. **Current bonus:** Active stat bonuses at current level
4. **Next level preview:** What the next level grants.
   - At Lv5: "MAX"
   - Convergence Shard below Lv5: "???"
   - If unchanged from current: "(unchanged)"
5. **At level up:** The permanent stat bonus applied when the character
   levels up with this crystal equipped (same values as current bonus)
6. **Stat comparison:** Shows what stats change if this crystal is
   equipped (vs. current crystal or no crystal). Green ▲ for increase,
   red ▼ for decrease, dash ── for unchanged.
   If already equipped on this character: shows "Equipped" instead.
7. **Negative effect** (if applicable): Red warning text with ⚠ prefix

**DescPanel (bottom):** Shows invocation with power at current level
and uses/rest. More detailed than list view (adds "Power: N").

**Navigation:**
- Confirm: equip crystal on current character. If another character
  has it equipped, swap (unequip from them). Return to list view.
- Cancel: return to list view without changes

**Edge cases:**
- Crystal equipped by another character: show "Equipped by [Name]"
  above stat comparison. Confirm still equips (swaps from other).
- Crystal already equipped on current character: the entire stat
  comparison block is replaced with "Equipped" text. Confirm returns
  to list (no-op since it's already equipped).
- Convergence Shard at Lv4: next level shows "???". When Lv5 is
  reached (via `add_crystal_xp`), real bonus is revealed immediately
  on next detail view open — no reload needed.
- Dawn Fragment at Lv5: current bonus shows empty, next level "MAX"

## Visual Style

Follows the FF6-style bordered panel system from Phase 3 (StyleBoxFlat
with flat dark blue + border + shadow glow). Same color scheme as
Magic/Abilities screens.

**Colors:**

```gdscript
const COLOR_SELECTED: Color = Color("#ffff88")   # Yellow — cursor
const COLOR_NORMAL: Color = Color("#ccddff")     # Blue-white — default
const COLOR_DISABLED: Color = Color("#666688")    # Grey — equipped by other
const COLOR_STAT_UP: Color = Color("#88ff88")     # Green — stat increase
const COLOR_STAT_DOWN: Color = Color("#ff8888")   # Red — stat decrease
const COLOR_WARNING: Color = Color("#ff8888")     # Red — negative effects
const COLOR_MUTED: Color = Color("#888899")       # Muted — Remove entry / preview
```

**XP bar:** Same pixel-fill pattern as HP/MP bars in battle UI.
Background: dark grey. Fill: cyan/teal (`#44aacc`).

## Integration Points

### menu_overlay.gd

- Remove `"stubbed": true` from Crystal command (line 22)
- Add `@onready var _crystal_screen: Control = $SubScreen/CrystalScreen`
- In `_open_sub_screen_for_character()`, add Crystal match arm
- Add `_crystal_screen` to `_hide_all_sub_screens()`

### Battle Rewards (exploration.gd)

In `distribute_battle_rewards()` or the post-battle reward flow, after
XP distribution to party members:

```gdscript
# Crystal XP: 30% of wearer's earned XP
for i: int in range(PartyState.members.size()):
    var member: Dictionary = PartyState.members[i]
    var crystal_id: String = member.get("equipment", {}).get("crystal", "")
    if not crystal_id.is_empty():
        var crystal_xp: int = int(earned_xp_per_member * 0.3)
        PartyState.add_crystal_xp(crystal_id, crystal_xp)
```

This hooks into the existing reward flow in exploration.gd
`_initialize_from_transition_data()` victory path.

### Save/Load

`build_save_data()` adds `ley_crystals` at the top level of save data:
```gdscript
"ley_crystals": ley_crystals.duplicate(true)
```

`load_from_save()` restores from the top level:
```gdscript
ley_crystals = data.get("ley_crystals", {})
```

## What This Does NOT Include (Deferred)

- **Invocation in battle Magic menu** — separate gap, needs battle
  command menu changes to show invocations alongside spells
- **Crystal acquisition events** — gap 4.x content, adding crystals
  via story triggers / chest pickups
- **Negative effect runtime behavior** — battle system changes for
  random flame hit, SPD penalty, random targeting, HP loss
- **Invocation suppression** — Axis Tower Act III content
- **Crystal element affinity display** — deferred to UI polish

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `game/data/ley_crystals.json` | CREATE | Static crystal data (18 crystals) |
| `game/scripts/ui/menu_ley_crystal.gd` | CREATE | Ley Crystal sub-screen |
| `game/scenes/overlay/menu.tscn` | MODIFY | Add CrystalScreen node to SubScreen |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Wire Crystal command |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add ley_crystals state + methods |
| `game/scripts/autoload/data_manager.gd` | MODIFY | Add crystal data loading |
| `game/scripts/core/exploration.gd` | MODIFY | Crystal XP in battle rewards |
| `game/tests/test_ley_crystal.gd` | CREATE | ~20 integration tests |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update 3.4 status |

## Test Plan

**Crystal data (5 tests):**
- All 18 crystals load from JSON
- XP thresholds array has 5 entries per crystal
- Level bonuses array has 5 entries per crystal
- Every crystal has an invocation with 5 level_effects
- Convergence Shard has `secret_lv5: true`

**PartyState crystal methods (6 tests):**
- `add_ley_crystal` adds crystal at Lv1 / 0 XP
- `add_ley_crystal` for existing crystal is no-op
- `get_crystal_state` returns empty dict for unknown crystal
- `add_crystal_xp` increments XP correctly
- `add_crystal_xp` auto-levels at threshold (Lv1 → Lv2 at 800 XP)
- `add_crystal_xp` caps at Lv5 (excess XP ignored)

**Equip/unequip (4 tests):**
- Equipping crystal sets `equipment.crystal` on character
- Equipping crystal already on another character swaps it
- Remove clears `equipment.crystal` to empty string
- `get_collected_crystals` returns all owned crystal IDs

**Save/load (2 tests):**
- `build_save_data` includes `ley_crystals` dict
- `load_from_save` restores crystal XP and levels

**Scene structure (3 tests):**
- Menu scene has CrystalScreen node under SubScreen
- CrystalScreen has expected panels (TitlePanel, CharPanel, CrystalGrid, DescPanel)
- Crystal command in menu_overlay is not stubbed
