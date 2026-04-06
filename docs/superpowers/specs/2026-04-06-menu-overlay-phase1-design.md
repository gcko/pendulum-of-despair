# Menu Overlay Phase 1 — Design Spec

> **Gap:** 3.4 (Phase 1 of 2)
> **Priority:** P1
> **Source Docs:** `ui-design.md` Sections 3–5, 8, 10; `accessibility.md`;
> `progression.md`; `equipment.md`; `save-system.md`
> **Depends On:** 1.1 (Character Data), 1.3 (Items & Equipment), 1.5
> (Spells & Abilities), 1.9 (Config)
> **Scope:** Main menu frame + Items + Equipment + Status + Config + Save
> integration. Magic, Abilities, Formation, Ley Crystal, Shop deferred to
> Phase 2.

---

## 1. Problem Statement

The game has no pause menu. Players cannot inspect stats, manage
inventory, change equipment, adjust settings, or save from the menu.
The battle system exists but equipment stat modifiers aren't applied
because there's no equipment management screen.

**Critical prerequisite:** No runtime game state exists outside of
battle. The save schema in `SaveManager._build_save_data()` defines
the shape (party, inventory, formation, equipment) but returns stubs.
The menu needs live state to read and write.

---

## 2. Runtime Game State

### 2.1 New File: `game/scripts/autoload/party_state.gd`

A new autoload singleton that holds the persistent party/inventory
state during gameplay. This is the bridge between static JSON data
and live gameplay that both the menu and battle systems read from.

**Why a new autoload?** GameManager owns state transitions. DataManager
owns static JSON. SaveManager owns persistence. Party/inventory state
is a distinct concern — it's mutable gameplay state that changes as
the player plays. Putting it in GameManager would violate single
responsibility (GameManager is already 109 lines with clear scope).

**Autoload registration:** `PartyState` in project.godot, loaded after
DataManager and SaveManager (depends on both for data lookup and config path).

**State shape** (mirrors save schema exactly):

```
party: Array[Dictionary]
  - character_id: String
  - level: int
  - current_hp: int
  - max_hp: int
  - current_mp: int
  - max_mp: int
  - current_xp: int
  - xp_to_next: int
  - base_stats: Dictionary  # {atk, def, mag, mdef, spd, lck}
  - equipment: Dictionary   # {weapon, head, body, accessory, crystal}
  - status_effects: Array   # persistent out-of-battle statuses

formation: Dictionary
  - active: Array[int]      # indices into party array, max 4
  - reserve: Array[int]     # indices into party array
  - rows: Dictionary        # {character_id: "front"|"back"}

inventory: Dictionary
  - consumables: Dictionary # {item_id: quantity}
  - materials: Dictionary   # {item_id: quantity}
  - key_items: Array[String]

owned_equipment: Array[Dictionary]  # owned unequipped gear (top-level)
  - {id: String, equipment_id: String}  # unique instance id + type id

gold: int

playtime: int  # seconds

location_name: String  # display name for menu/save
```

**Public API:**

```gdscript
# Initialization
func initialize_new_game() -> void  # loads starting data from JSONs
func load_from_save(data: Dictionary) -> void
func build_save_data() -> Dictionary

# Party access
func get_active_party() -> Array[Dictionary]  # up to 4 active members
func get_member(character_id: String) -> Dictionary  # full member data
func get_all_members() -> Array[Dictionary]  # active + reserve

# Stat calculation
func get_effective_stat(character_id: String, stat: String) -> int
func get_equipment_bonus(character_id: String, stat: String) -> int

# Derived stats
func get_derived_stats(character_id: String) -> Dictionary
  # returns {eva_pct, meva_pct, crit_pct}

# Equipment
func equip_item(character_id: String, slot: String, equipment_id: String) -> Dictionary
  # returns {old_equipment_id} or empty on failure
func unequip_slot(character_id: String, slot: String) -> void
func get_equippable_for_slot(character_id: String, slot: String) -> Array[Dictionary]
func optimize_equipment(character_id: String) -> void

# Inventory
func get_consumables() -> Dictionary  # {item_id: qty}
func get_key_items() -> Array[String]
func use_item(item_id: String, target_character_id: String) -> bool
func add_item(item_id: String, quantity: int) -> void
func remove_item(item_id: String, quantity: int) -> void

# Gold
func get_gold() -> int
func add_gold(amount: int) -> void
func spend_gold(amount: int) -> bool

# Config (convenience — reads/writes config file)
func get_config() -> Dictionary
func set_config(key: String, value: Variant) -> void
func save_config() -> void
```

### 2.2 Initialization Flow

**New Game** (from title.gd):
1. `PartyState.initialize_new_game()` called
2. Loads Edren + Cael character JSONs from DataManager
3. Sets level 1, base stats from JSON, starting equipment (Tier 0)
4. Sets starting inventory: 5 Potion, 2 Antidote (per economy.md
   starting resources)
5. Formation: Edren slot 0 (front), Cael slot 1 (front)
6. Gold: 200 (per economy.md starting gold)
7. `transition_data` includes `"new_game": true`

**Continue** (from title.gd or save_load.gd):
1. SaveManager loads the save file
2. `PartyState.load_from_save(data)` called with save Dictionary
3. All runtime state restored from save

**Save** (from save_load.gd):
1. `PartyState.build_save_data()` returns the current state
2. SaveManager wraps it with meta and writes to disk

### 2.3 Stat Calculation

**Effective stat** = `base_stat + equipment_bonus` (clamped to 255 for
ATK/DEF/MAG/MDEF/SPD/LCK; 14999 for HP; 1499 for MP).

Equipment bonus = sum of all equipped items' `bonus_stats.{stat}`
values (weapons provide ATK as their primary stat; armor provides
DEF/MDEF; accessories provide various).

**Derived stats** per progression.md:
- `EVA% = floor(SPD / 4)` — cap 50%, floor 0%
- `CRIT% = floor(LCK / 4)` — cap 50%, floor 0%
- `MEVA% = floor((MDEF + SPD) / 8)` — cap 40%, floor 0%

Equipment flat bonuses to derived stats (e.g., Lucky Coin → +LCK
which increases CRIT%) are computed through the base stat, not as
direct derived stat modifiers.

---

## 3. Menu Overlay Architecture

### 3.1 Scene: `game/scenes/overlay/menu.tscn`

**Root:** CanvasLayer (layer 10, same as other overlays)

**Scene tree:**
```
Menu (CanvasLayer)
├── Background (ColorRect)          # solid black fill per ui-design.md 3.1
├── MainPanel (PanelContainer)      # left 68% — party display
├── CommandPanel (PanelContainer)   # right 28% — 9 commands
├── InfoPanel (PanelContainer)      # bottom — location + time + gold
├── SubScreen (Control)             # container for sub-screens
│   ├── ItemScreen (PanelContainer)
│   ├── EquipScreen (PanelContainer)
│   ├── StatusScreen (PanelContainer)
│   └── ConfigScreen (PanelContainer)
└── Cursor (Sprite2D)               # animated hand cursor
```

### 3.2 Script: `game/scripts/ui/menu_overlay.gd`

`extends CanvasLayer`

**State machine:**
```
enum MenuState {
    COMMAND,         # main command list
    CHARACTER_SELECT,# picking a character for Equip/Status/Magic/etc.
    SUB_SCREEN,     # sub-screen is active (Items, Equip, Status, Config)
}
```

**Signals:** None outward. Menu is self-contained — it reads from
PartyState and writes to PartyState. Closes itself via
`GameManager.pop_overlay()`.

**Input flow:**
- `_unhandled_input` dispatches by MenuState
- COMMAND: up/down navigates commands, confirm opens sub-screen or
  character select, cancel closes menu
- CHARACTER_SELECT: up/down picks party member, confirm opens the
  sub-screen for that character, cancel returns to COMMAND
- SUB_SCREEN: input forwarded to the active sub-screen script

**Character select flow** (per ui-design.md 3.4): Choosing Equip,
Status, Magic (stubbed), Abilities (stubbed), or Crystal (stubbed)
shows a second cursor on the party panel. Player picks which
character, then the sub-screen opens.

**Commands:**
1. Item → SUB_SCREEN (ItemScreen)
2. Magic → CHARACTER_SELECT → stub "Coming Soon"
3. Abilities → CHARACTER_SELECT → stub "Coming Soon"
4. Equip → CHARACTER_SELECT → SUB_SCREEN (EquipScreen)
5. Crystal → CHARACTER_SELECT → stub "Coming Soon"
6. Status → CHARACTER_SELECT → SUB_SCREEN (StatusScreen)
7. Formation → stub "Coming Soon"
8. Config → SUB_SCREEN (ConfigScreen)
9. Save → opens save_load overlay (if at save point) or disabled

### 3.3 Color Constants

All colors from ui-design.md Section 1.4 (shared across sub-screens):

```gdscript
const COLOR_SELECTED: Color = Color("#ffff88")      # pale yellow
const COLOR_NORMAL: Color = Color("#ccddff")         # pale blue
const COLOR_DISABLED: Color = Color("#666688")        # muted grey
const COLOR_HP: Color = Color("#44cc44")              # green
const COLOR_HP_LOW: Color = Color("#ff4444")          # red (< 25%)
const COLOR_MP: Color = Color("#4488ff")              # blue
const COLOR_GOLD: Color = Color("#ffcc44")            # gold
const COLOR_STAT_UP: Color = Color("#44ff44")         # green arrow
const COLOR_STAT_DOWN: Color = Color("#ff4444")       # red arrow
const COLOR_WINDOW_BG: Color = Color("#000040")       # dark navy
const COLOR_WINDOW_BORDER: Color = Color("#5566aa")   # blue-grey
```

---

## 4. Sub-Screen Specs

### 4.1 Items Screen (`menu_items.gd`)

Per ui-design.md Section 4.

**Layout:** Tab bar (USE | ARRANGE | KEY) → description area →
single-column item list.

**State:**
```
enum ItemTab { USE, ARRANGE, KEY }
var _current_tab: ItemTab = ItemTab.USE
var _cursor_index: int = 0
var _using_item: bool = false   # true when selecting target character
var _target_index: int = 0
```

**Behavior:**
- USE tab: consumables from `PartyState.get_consumables()`. Each entry
  shows item name + quantity. Description updates on cursor move.
  Selecting an item opens character target overlay (4 active members).
  Confirm → `PartyState.use_item(item_id, character_id)`. Item effects
  applied immediately (HP/MP restore, status cure).
- ARRANGE tab: pressing confirm cycles sort order (Type → Name →
  Quantity → Type). No item selection.
- KEY tab: key items from `PartyState.get_key_items()`. View only,
  not usable.
- L/R shoulder switches tabs.
- Cancel returns to menu COMMAND state.

**Item use effects** (from items.md consumable data):
- Potion: restore 100 HP to one target
- Hi-Potion: restore 500 HP to one target
- X-Potion: restore full HP to one target
- Ether: restore 30 MP to one target
- Elixir: restore full HP + MP to one target
- Phoenix Feather: revive from Faint with 25% HP
- Antidote: cure Poison
- Echo Drop: cure Silence
- Eye Drops: cure Blind
- Remedy: cure all negative statuses
- Smoke Bomb: guaranteed flee (battle only — greyed out in field)
- Sleeping Bag/Tent/Pavilion: rest items (save point only — greyed out)

**Field usability:** Only HP/MP restoratives and status cures are
usable from the menu. Battle-only items (Smoke Bomb, Drake Fang) are
greyed out. Rest items are greyed out (usable only at save points via
save_load.gd).

### 4.2 Equipment Screen (`menu_equip.gd`)

Per ui-design.md Section 5.

**Layout:** Sub-command tabs (EQUIP | OPTIMUM | REMOVE | EMPTY) →
5 equipment slots (left) → stat comparison (right) → portrait +
name (top-right) → element/status info (bottom).

**State:**
```
enum EquipMode { EQUIP, OPTIMUM, REMOVE, EMPTY }
enum EquipState { MODE_SELECT, SLOT_SELECT, ITEM_SELECT }
var _mode: EquipMode = EquipMode.EQUIP
var _state: EquipState = EquipState.MODE_SELECT
var _selected_slot: int = 0       # 0=weapon, 1=head, 2=body, 3=accessory, 4=crystal
var _item_cursor: int = 0
var _character_id: String = ""
```

**Slot names:** weapon, head, body, accessory, crystal (5 slots per
equipment.md).

**EQUIP mode:**
1. Select slot → available equipment list appears
2. List populated from `PartyState.get_equippable_for_slot(char, slot)`
3. "Remove" option at top of list
4. Items equipped by others show "E" indicator
5. Stat comparison updates live as cursor moves (green up / red down / dash)
6. Confirm equips: `PartyState.equip_item(char, slot, equipment_id)`
7. Cancel returns to slot select

**OPTIMUM mode:** Confirm auto-equips best available.
`PartyState.optimize_equipment(character_id)` — ATK priority for
Edren/Cael/Lira/Sable, MAG priority for Maren/Torren.

**REMOVE mode:** Select slot → unequip that slot.

**EMPTY mode:** Confirm unequips all 5 slots at once.

**Stat comparison panel** (per ui-design.md 5.6):
- 8 core stats: ATK, DEF, MAG, MDEF, SPD, LCK + HP, MP (only if
  equipment modifies them)
- Each line: label + current value + delta indicator
  - `▲` green + new value (improvement)
  - `▼` red + new value (worse)
  - `──` dash (unchanged)
- 3 derived stats: EVA%, MEVA%, CRIT%

**Equippable-by rules** (from equipment.md):
- Weapons: each character has exactly one weapon type
- Head armor: all characters
- Body armor: light (all), heavy (Edren/Lira), robes (Maren/Torren)
- Accessories: all characters
- Crystals: all characters

### 4.3 Status Screen (`menu_status.gd`)

Per ui-design.md Section 8.

**Layout:** Portrait + identity (left) → stats (right) → battle
commands (bottom-left) → equipment summary (bottom-right).

**Read-only screen.** No state modifications.

**Left panel:**
- 32×32 portrait placeholder (colored square matching character color)
- Name (white, uppercase)
- Class title from progression.md: Edren=Knight, Cael=Commander,
  Lira=Engineer, Torren=Sage, Sable=Thief, Maren=Archmage
- Level
- Current XP (comma-separated)
- XP to next level (comma-separated)
- Active status effect icons (placeholder text labels)

**Right panel — stats:**
- HP bar + numeric (current/max)
- MP bar + numeric (current/max)
- 8 core stats with equipment bonus in parentheses:
  `ATK  42 (+12)` where 42 = effective, 12 = equipment bonus
- 3 derived stats: EVA%, MEVA%, CRIT%

**Bottom-left — battle commands:**
- Attack, Magic, [character ability name], Item, Defend

**Bottom-right — equipment summary:**
- 5 slots with equipped item names
- Element affinity icons (placeholder text)

### 4.4 Config Screen (`menu_config.gd`)

Per ui-design.md Section 10.

**Layout:** Scrollable label/value list.

**17 settings organized in two groups:**

**Standard settings:**
1. Battle Speed: 1–6, left/right adjusts, display `[3]` style
2. ATB Mode: Active / Wait toggle
3. Text Speed: Slow / Normal / Fast / Instant cycle
4. Battle Cursor: Reset / Memory toggle
5. Sound: Stereo / Mono toggle
6. Music Volume: 0–10 bar
7. SFX Volume: 0–10 bar
8. Screen Shake: On / Off toggle
9. Mode 7 Intensity: 1–6, left/right adjusts

**Separator + Window Color:**
10. Window Color R: 0–31 slider
11. Window Color G: 0–31 slider
12. Window Color B: 0–31 slider
13. Preview box (not a setting, visual only)

**Separator + Accessibility:**
14. Patience Mode: On / Off
15. Color-Blind Mode: Off / Deutan-Protan / Tritan
16. High-Res Text: On / Off
17. Reduce Motion: On / Off
18. Flash Intensity: Off / Reduced / Full
19. Transition Style: Classic / Simple
20. SFX Captions: On / Off

**Patience Mode cascade:** When enabled, ATB Mode and Battle Speed
are greyed out and forced to Wait/6. When disabled, previous values
restored.

**Reduce Motion cascade:** When enabled, Screen Shake/Mode 7
Intensity/Flash Intensity/Transition Style forced to safe values
(Off/1/Off/Simple). When disabled, previous values restored.

**Persistence:** Changes are applied immediately (live preview for
window color). On exit, `PartyState.save_config()` writes to
`user://config.json`.

### 4.5 Save Integration

Menu "Save" command behavior:
- If player is at a save point (tracked via a flag or proximity):
  `GameManager.pop_overlay()` then
  `GameManager.push_overlay(OverlayState.SAVE_LOAD)` — reuses existing
  save_load.gd
- If NOT at a save point: "Save" command greyed out, not selectable

**Implementation detail:** The menu needs to know if the player is at
a save point. This can be tracked as a flag in PartyState
(`is_at_save_point: bool`) set by exploration.gd when the player
enters/exits a save point proximity zone.

---

## 5. Input Mapping

Per ui-design.md Section 17.

**New input action needed:** `ui_menu` — opens the menu during
exploration.

| Action | Keyboard | Purpose |
|--------|----------|---------|
| `ui_menu` | Escape | Open/close menu |
| `ui_accept` | Space/Enter | Confirm |
| `ui_cancel` | Escape | Cancel/back |
| `ui_up/down/left/right` | Arrow keys | Navigation |
| `ui_page_up`/`ui_page_down` | Q / E | Tab switch, shoulder buttons |

**Escape dual-purpose:** In exploration, Escape opens menu. Inside
menu, Escape/Cancel closes the current level (sub-screen → command
list → close menu). This is standard JRPG behavior — no conflict
because the menu consumes the input when open.

**Exploration integration:** Add `ui_menu` handler to
`exploration.gd._unhandled_input()`:
```gdscript
if event.is_action_pressed("ui_menu"):
    if GameManager.push_overlay(GameManager.OverlayState.MENU):
        get_viewport().set_input_as_handled()
```

**Title screen Config integration:** The title screen opens the menu
overlay in "config direct" mode via `open_config_direct()`. This skips
the COMMAND state and goes straight to the Config sub-screen. When the
user presses cancel, the overlay closes back to the title screen
(instead of dropping into the full menu command list). The
`_config_direct` flag controls this behavior.

---

## 6. File Manifest

### New Files (9)

| File | Purpose | Lines (est.) |
|------|---------|-------------|
| `game/scripts/autoload/party_state.gd` | Runtime party/inventory state | ~395 |
| `game/scripts/autoload/inventory_helpers.gd` | Static inventory/equipment helpers | ~195 |
| `game/scenes/overlay/menu.tscn` | Menu overlay scene | — |
| `game/scripts/ui/menu_overlay.gd` | Menu frame + command navigation | ~330 |
| `game/scripts/ui/menu_items.gd` | Items sub-screen | ~265 |
| `game/scripts/ui/menu_equip.gd` | Equipment sub-screen | ~325 |
| `game/scripts/ui/menu_status.gd` | Status sub-screen | ~170 |
| `game/scripts/ui/menu_config.gd` | Config sub-screen | ~290 |
| `game/tests/test_party_state.gd` | PartyState unit tests | ~225 |

### Modified Files (4)

| File | Change |
|------|--------|
| `game/project.godot` | Add PartyState autoload, add `ui_menu` input action |
| `game/scripts/core/exploration.gd` | Add `ui_menu` handler to open menu |
| `game/scripts/core/title.gd` | Call `PartyState.initialize_new_game()` on New Game |
| `game/scripts/autoload/save_manager.gd` | Wire `_build_save_data` to `PartyState.build_save_data()`, wire `_apply_save_data` to `PartyState.load_from_save()` |

---

## 7. Stubbed Sub-Screens (Phase 2)

These commands show a brief "Not yet available" message and return to
the command list:

- Magic (command index 1)
- Abilities (command index 2)
- Crystal (command index 4)
- Formation (command index 6)

Phase 2 will implement these + Shop interface.

---

## 8. What This Does NOT Include

- Shop buy/sell interface (Phase 2)
- Magic/Abilities/Formation/Crystal screens (Phase 2)
- Pixel art assets (gap 4.8) — uses colored rectangles
- Audio feedback (gap 3.8) — silent
- Ley Crystal equip/XP system (Phase 2)
- Party reordering / reserve management (Phase 2 Formation)
- Field abilities (Torren: Call Stag, Lira: Forge, Maren: Linewalk)
  — Phase 2 or later
