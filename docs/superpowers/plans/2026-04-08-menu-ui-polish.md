# Menu UI Polish Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all 7 menu sub-screens with FF6-style bordered window panels using full-viewport replacement mode, fixing all text overlap and visual polish issues.

**Architecture:** Each sub-screen wraps its content in PanelContainer nodes with a shared StyleBoxFlat (flat dark blue + border + glow). Opening a sub-screen hides the main menu panels (MainPanel, CommandPanel, InfoPanel). Internal layouts use VBox/HBox containers. Node paths updated in corresponding .gd scripts.

**Tech Stack:** Godot 4.6, GDScript, StyleBoxFlat, PanelContainer, VBoxContainer, HBoxContainer

**Spec:** `docs/superpowers/specs/2026-04-08-menu-ui-polish-design.md`

---

## File Map

| File | Action | What Changes |
|------|--------|-------------|
| `game/scenes/overlay/menu.tscn` | MODIFY | Add shared StyleBoxFlat sub-resource, restructure all 7 sub-screens |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Hide/show main panels on sub-screen open/close |
| `game/scripts/ui/menu_items.gd` | MODIFY | Update @onready paths for PanelContainer structure |
| `game/scripts/ui/menu_equip.gd` | MODIFY | Update @onready paths |
| `game/scripts/ui/menu_status.gd` | MODIFY | Update @onready paths |
| `game/scripts/ui/menu_magic.gd` | MODIFY | Update @onready paths |
| `game/scripts/ui/menu_abilities.gd` | MODIFY | Update @onready paths |
| `game/scripts/ui/menu_formation.gd` | MODIFY | Update @onready paths |
| `game/scripts/ui/menu_config.gd` | MODIFY | Update @onready paths |

---

## Chunk 1: StyleBox + Show/Hide Logic

### Task 1: Add shared StyleBoxFlat and implement panel show/hide

**Files:**
- Modify: `game/scenes/overlay/menu.tscn`
- Modify: `game/scripts/ui/menu_overlay.gd`

- [ ] **Step 1: Add StyleBoxFlat sub-resource to menu.tscn**

Add a new sub-resource at the top of menu.tscn (after existing sub-resources):

```
[sub_resource type="StyleBoxFlat" id="StyleBox_ff6_window"]
bg_color = Color(0.11, 0.11, 0.31, 1)
border_color = Color(0.333, 0.467, 0.8, 1)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4
content_margin_left = 16.0
content_margin_top = 16.0
content_margin_right = 16.0
content_margin_bottom = 16.0
shadow_color = Color(0.267, 0.4, 0.667, 0.3)
shadow_size = 8
```

Increment `load_steps` in the scene header by 1.

- [ ] **Step 2: Modify _open_sub_screen to hide main panels**

In `game/scripts/ui/menu_overlay.gd`, add @onready references for the main panels
(if not already present). Then modify `_open_sub_screen`:

```gdscript
@onready var _main_panel: PanelContainer = $MainPanel
@onready var _command_panel: PanelContainer = $CommandPanel
@onready var _info_panel: PanelContainer = $InfoPanel

func _open_sub_screen(screen: Control) -> void:
	_hide_all_sub_screens()
	_main_panel.visible = false
	_command_panel.visible = false
	_info_panel.visible = false
	_cursor.visible = false
	# CharCursor removed — character select uses color highlight only
	screen.visible = true
	_active_sub_screen = screen
	_state = MenuState.SUB_SCREEN
```

- [ ] **Step 3: Modify _close_sub_screen to re-show main panels**

In the existing `_close_sub_screen` method, after hiding the active sub-screen
and before the `_state = MenuState.COMMAND` line, add:

```gdscript
	_main_panel.visible = true
	_command_panel.visible = true
	_info_panel.visible = true
	_cursor.visible = true
```

Make sure this is BEFORE the early return for `_config_direct` (the config
direct path pops the overlay entirely, so main panels don't matter).

- [ ] **Step 4: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_overlay.gd
git commit -m "feat(engine): add FF6 window StyleBox and panel show/hide for sub-screens"
```

---

## Chunk 2: Restructure Sub-Screens (Items, Config, Formation)

### Task 2: Restructure Items sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (ItemScreen section)
- Modify: `game/scripts/ui/menu_items.gd`

- [ ] **Step 1: Restructure ItemScreen in menu.tscn**

Replace the ItemScreen's children with PanelContainer-wrapped layout.
The ItemScreen node itself stays as a Control at full viewport size.
Its children become:

```
ItemScreen (Control, 0,0,1280,720)
  VBoxContainer "Layout" (anchors full rect, margins 16)
    PanelContainer "TabPanel" (StyleBox_ff6_window)
      HBoxContainer: TabBar labels (USE, ARRANGE, KEY)
    PanelContainer "DescPanel" (StyleBox_ff6_window)
      HBoxContainer: DescLabel (expand) | CountLabel
    PanelContainer "ListPanel" (StyleBox_ff6_window, expand)
      VBoxContainer "ItemContainer": Item0-Item11 labels
    PanelContainer "TargetPanel" (StyleBox_ff6_window, visible=false)
      VBoxContainer: Target0-Target3 labels
```

Each PanelContainer uses `theme_override_styles/panel = SubResource("StyleBox_ff6_window")`.
VBoxContainer "Layout" has `theme_override_constants/separation = 8`.

- [ ] **Step 2: Update menu_items.gd node paths**

Update @onready paths to match the new structure:
```gdscript
@onready var _desc_label: Label = $Layout/DescPanel/DescRow/DescLabel
@onready var _item_container: Control = $Layout/ListPanel/ItemContainer
@onready var _target_panel: Control = $Layout/TargetPanel
```

Tab labels and item labels are populated in `_ready()` by iterating
children — these should still work if the parent containers are correct.
Verify by checking how `_tab_labels` and `_item_labels` are built.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_items.gd
git commit -m "feat(engine): restructure Items sub-screen with FF6 bordered panels"
```

### Task 3: Restructure Config sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (ConfigScreen section)
- Modify: `game/scripts/ui/menu_config.gd`

- [ ] **Step 1: Restructure ConfigScreen in menu.tscn**

```
ConfigScreen (Control, 0,0,1280,720)
  VBoxContainer "Layout" (anchors full rect, margins 16)
    HBoxContainer "HeaderRow"
      PanelContainer "SettingNamePanel" (StyleBox, expand)
        Label "CurrentSettingName"
      PanelContainer "TitlePanel" (StyleBox)
        Label "ConfigTitle" text="Config"
    PanelContainer "SettingsPanel" (StyleBox, expand)
      VBoxContainer "SettingList": alternating Name/Value label pairs
    HBoxContainer "FooterRow"
      PanelContainer "DescPanel" (StyleBox, expand)
        Label "SettingDesc"
      PanelContainer "HintPanel" (StyleBox)
        VBoxContainer: Label "Confirm", Label "Back"
    ColorRect "PreviewRect" (window color preview, 80x80)
```

- [ ] **Step 2: Update menu_config.gd node paths**

```gdscript
@onready var _setting_labels: Array[Label] = []  # built from SettingList children
@onready var _value_labels: Array[Label] = []     # built from SettingList children
@onready var _preview_rect: ColorRect = $Layout/PreviewRect
```

If the script populates labels by iterating SettingList children,
update the path to `$Layout/SettingsPanel/SettingList`.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_config.gd
git commit -m "feat(engine): restructure Config sub-screen with FF6 bordered panels"
```

### Task 4: Restructure Formation sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (FormationScreen section)
- Modify: `game/scripts/ui/menu_formation.gd`

- [ ] **Step 1: Restructure FormationScreen in menu.tscn**

```
FormationScreen (Control, 0,0,1280,720)
  VBoxContainer "Layout" (anchors full rect, margins 16)
    PanelContainer "TitlePanel" (StyleBox)
      Label "TitleLabel" text="Formation"
    PanelContainer "MemberPanel" (StyleBox, expand)
      VBoxContainer "MemberList": Member0-Member5 labels
    PanelContainer "HintPanel" (StyleBox)
      Label "SwapLabel" text="Select member to swap. PgUp/PgDn toggles row."
```

- [ ] **Step 2: Update menu_formation.gd node paths**

```gdscript
@onready var _member_labels: Array[Label] = []  # built from MemberList children
@onready var _swap_label: Label = $Layout/HintPanel/SwapLabel
```

Update `_ready()` member label iteration path to
`$Layout/MemberPanel/MemberList`.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_formation.gd
git commit -m "feat(engine): restructure Formation sub-screen with FF6 bordered panels"
```

---

## Chunk 3: Restructure Sub-Screens (Magic, Abilities, Equipment, Status)

### Task 5: Restructure Magic sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (MagicScreen section)
- Modify: `game/scripts/ui/menu_magic.gd`

- [ ] **Step 1: Restructure MagicScreen in menu.tscn**

```
MagicScreen (Control, 0,0,1280,720)
  VBoxContainer "Layout" (anchors full rect, margins 16)
    PanelContainer "DescPanel" (StyleBox)
      HBoxContainer: DescLabel (expand) | MPLabel | CostLabel
    PanelContainer "CharPanel" (StyleBox)
      HBoxContainer "CharInfo": NameLabel | LvLabel | HPLabel | MPLabel
    PanelContainer "SpellPanel" (StyleBox, expand)
      HBoxContainer "SpellGrid"
        VBoxContainer "LeftCol": 6 spell labels
        VBoxContainer "RightCol": 6 spell labels
    PanelContainer "TargetPanel" (StyleBox, visible=false)
      VBoxContainer: Target0-Target3 labels
```

- [ ] **Step 2: Update menu_magic.gd node paths**

```gdscript
@onready var _desc_label: Label = $Layout/DescPanel/DescRow/DescLabel
@onready var _name_label: Label = $Layout/CharPanel/CharInfo/NameLabel
@onready var _lv_label: Label = $Layout/CharPanel/CharInfo/LvLabel
@onready var _hp_label: Label = $Layout/CharPanel/CharInfo/HPLabel
@onready var _mp_label: Label = $Layout/CharPanel/CharInfo/MPLabel
@onready var _left_col: VBoxContainer = $Layout/SpellPanel/SpellGrid/LeftCol
@onready var _right_col: VBoxContainer = $Layout/SpellPanel/SpellGrid/RightCol
@onready var _target_panel: VBoxContainer = $Layout/TargetPanel/TargetList
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_magic.gd
git commit -m "feat(engine): restructure Magic sub-screen with FF6 bordered panels"
```

### Task 6: Restructure Abilities sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (AbilitiesScreen section)
- Modify: `game/scripts/ui/menu_abilities.gd`

- [ ] **Step 1: Restructure AbilitiesScreen**

Same pattern as Magic: DescPanel + CharPanel + AbilityPanel (2-col grid).

- [ ] **Step 2: Update menu_abilities.gd node paths**

```gdscript
@onready var _desc_label: Label = $Layout/DescPanel/DescRow/DescLabel
@onready var _name_label: Label = $Layout/CharPanel/CharInfo/NameLabel
@onready var _lv_label: Label = $Layout/CharPanel/CharInfo/LvLabel
@onready var _resource_label: Label = $Layout/CharPanel/CharInfo/ResourceLabel
@onready var _left_col: VBoxContainer = $Layout/AbilityPanel/AbilityGrid/LeftCol
@onready var _right_col: VBoxContainer = $Layout/AbilityPanel/AbilityGrid/RightCol
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_abilities.gd
git commit -m "feat(engine): restructure Abilities sub-screen with FF6 bordered panels"
```

### Task 7: Restructure Equipment sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (EquipScreen section)
- Modify: `game/scripts/ui/menu_equip.gd`

- [ ] **Step 1: Restructure EquipScreen**

```
EquipScreen (Control, 0,0,1280,720)
  VBoxContainer "Layout" (anchors full rect, margins 16)
    PanelContainer "ModePanel" (StyleBox)
      HBoxContainer "ModeBar": EQUIP | OPTIMUM | REMOVE | EMPTY
    PanelContainer "SlotPanel" (StyleBox)
      HBoxContainer
        VBoxContainer "Slots" (expand): 5 slot rows
        VBoxContainer "CharInfo": NameLabel + portrait placeholder
    PanelContainer "StatPanel" (StyleBox, expand)
      VBoxContainer: 6 stat rows (Name | Value | Delta)
    PanelContainer "ItemListPanel" (StyleBox, visible=false)
      VBoxContainer "ItemList": 10 item labels
```

- [ ] **Step 2: Update menu_equip.gd node paths**

Update all @onready paths for ModeBar, SlotPanel, StatPanel, ItemList,
NameLabel, InfoLabel to reference through the new Layout/PanelContainer
hierarchy.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_equip.gd
git commit -m "feat(engine): restructure Equipment sub-screen with FF6 bordered panels"
```

### Task 8: Restructure Status sub-screen

**Files:**
- Modify: `game/scenes/overlay/menu.tscn` (StatusScreen section)
- Modify: `game/scripts/ui/menu_status.gd`

- [ ] **Step 1: Restructure StatusScreen**

```
StatusScreen (Control, 0,0,1280,720)
  VBoxContainer "Layout" (anchors full rect, margins 16)
    PanelContainer "IdentityPanel" (StyleBox)
      HBoxContainer: portrait | Name+Class | LV+XP+Next | HP+MP
    HBoxContainer "DetailRow" (expand)
      PanelContainer "StatPanel" (StyleBox, expand)
        VBoxContainer: "Stats" header + 6 stat rows + 3 derived
      PanelContainer "EquipPanel" (StyleBox, expand)
        VBoxContainer: "Equipment" header + 5 equip slot rows
```

- [ ] **Step 2: Update menu_status.gd node paths**

Update all 11 @onready references to use the new Layout/Panel paths.

- [ ] **Step 3: Commit**

```bash
git add game/scenes/overlay/menu.tscn game/scripts/ui/menu_status.gd
git commit -m "feat(engine): restructure Status sub-screen with FF6 bordered panels"
```

---

## Chunk 4: Verify + Gap Tracker

### Task 9: Run tests and verify

- [ ] **Step 1: Run gdlint on all changed scripts**

```bash
gdlint game/scripts/ui/menu_overlay.gd game/scripts/ui/menu_items.gd \
  game/scripts/ui/menu_equip.gd game/scripts/ui/menu_status.gd \
  game/scripts/ui/menu_magic.gd game/scripts/ui/menu_abilities.gd \
  game/scripts/ui/menu_formation.gd game/scripts/ui/menu_config.gd
```

- [ ] **Step 2: Run GUT tests**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ \
  --import && \
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game/ \
  -s addons/gut/gut_cmdln.gd
```

All GUT tests must pass.

- [ ] **Step 3: Update gap tracker**

In `docs/analysis/game-dev-gaps.md`, update Gap 3.4 Phase 3 status
from NOT STARTED to COMPLETE. Check off the completed items.

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): mark gap 3.4 Phase 3 menu UI polish COMPLETE"
```
