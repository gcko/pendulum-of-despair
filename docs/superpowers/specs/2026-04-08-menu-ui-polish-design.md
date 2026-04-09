# Menu UI Polish — Design Spec (Gap 3.4 Phase 3)

> **Goal:** Replace all 7 menu sub-screens with FF6-style bordered
> window panels using full-viewport replacement mode. Each sub-screen
> hides the main menu and owns the entire 1280x720 viewport.

---

## 1. Scope

### In Scope

- Unified window StyleBox (gradient + glow border) applied to all sub-screen panels
- Full-viewport replacement: opening a sub-screen hides MainPanel, CommandPanel, InfoPanel
- 7 sub-screen layouts restructured with proper bordered PanelContainers:
  - Items, Config, Magic, Equipment, Formation, Status, Abilities
- Container-based layouts (VBox/HBox) replacing all remaining absolute positioning
- Escape from sub-screen returns to main menu (re-shows main panels)

### Not In Scope

| Item | Reason | Deferred To |
|------|--------|-------------|
| Character portraits | Need art assets | Gap 4.8 |
| Scroll indicators (up/down arrows) | Polish pass | Future |
| Transition animations (fade in/out) | Polish pass | Future |
| Ley Crystal sub-screen | Needs PartyState crystal tracking | Gap 3.4 Phase 2 |
| Save sub-screen redesign | Already uses VBox layout from PR #130 | N/A |

---

## 2. Window StyleBox

All sub-screen panels use this consistent style:

```
Background: linear gradient top #222266 to bottom #161644
Border: 2px solid #5577cc
Inner shadow: inset 0 0 0 1px #333366
Outer glow: 0 0 8px rgba(68, 102, 170, 0.3)
Corner radius: 4px
Content margin: 16px
```

In Godot, this is a `StyleBoxFlat` with:
- `bg_color = Color("#1c1c50")` (midpoint of gradient; true gradient needs shader or 2-layer approach)
- `border_color = Color("#5577cc")`
- `border_width_*` = 2
- `corner_radius_*` = 4
- `content_margin_*` = 16
- `shadow_color = Color("#4466aa", 0.3)` with `shadow_size = 8`

For simplicity, use a flat dark blue (`#1c1c50`) instead of a gradient.
The border + shadow provides the visual distinction from FF6 reference.

---

## 3. Architecture: Full Replacement Mode

When a sub-screen opens:
1. `MainPanel.visible = false`
2. `CommandPanel.visible = false`
3. `InfoPanel.visible = false`
4. `Cursor.visible = false`
5. `CharCursor.visible = false`
6. Active sub-screen `.visible = true`

When sub-screen closes (Escape):
1. Active sub-screen `.visible = false`
2. `MainPanel.visible = true`
3. `CommandPanel.visible = true`
4. `InfoPanel.visible = true`
5. `Cursor.visible = true`
6. Restore cursor position

This is implemented in `menu_overlay.gd` `_open_sub_screen()` and
`_close_sub_screen()` methods.

---

## 4. Sub-Screen Layouts

Each sub-screen is a `Control` node (full viewport) containing
one or more `PanelContainer` children with the window StyleBox.
Internal layout uses `VBoxContainer` and `HBoxContainer`.

### 4.1 Items Screen

```
PanelContainer "TabPanel" (top, full width)
  HBoxContainer: [Item] [USE] [ARRANGE] [KEY]

PanelContainer "DescPanel" (below tabs, full width)
  HBoxContainer: DescLabel (left, expand) | CountLabel (right)

PanelContainer "ListPanel" (main area, full width, expand)
  VBoxContainer "ItemList": 10-12 visible item rows
    Each row: HBoxContainer [CursorLabel | NameLabel (expand) | QtyLabel]
```

### 4.2 Config Screen

```
HBoxContainer "HeaderRow" (top)
  PanelContainer "SettingNamePanel" (left, expand)
    Label: current setting name
  PanelContainer "TitlePanel" (right)
    Label: "Config"

PanelContainer "SettingsPanel" (main area, expand)
  VBoxContainer: setting rows
    Each row: HBoxContainer [CursorLabel | NameLabel (expand) | ValueLabel]

HBoxContainer "FooterRow" (bottom)
  PanelContainer "DescPanel" (left, expand)
    Label: setting description
  PanelContainer "HintPanel" (right)
    VBoxContainer: ["Confirm", "Back"]
```

### 4.3 Magic Screen

```
PanelContainer "DescPanel" (top, full width)
  HBoxContainer: DescLabel (left, expand) | "MP..." | CostLabel

PanelContainer "CharPanel" (below desc, full width)
  HBoxContainer: [Portrait placeholder] [Name] [LV] [HP current/max] [MP current/max]

PanelContainer "SpellPanel" (main area, expand)
  HBoxContainer
    VBoxContainer "LeftCol": 6 spell rows
    VBoxContainer "RightCol": 6 spell rows
    Each row: HBoxContainer [CursorLabel | SpellName]
```

### 4.4 Equipment Screen

```
PanelContainer "ModePanel" (top, full width)
  HBoxContainer: [EQUIP] [OPTIMUM] [REMOVE] [EMPTY]

PanelContainer "SlotPanel" (middle, full width)
  HBoxContainer
    VBoxContainer "Slots" (left, expand): 5 slot rows
      Each: HBoxContainer [CursorLabel | SlotName | EquipName]
    VBoxContainer "CharInfo" (right): [Name | Portrait placeholder]

PanelContainer "StatPanel" (bottom, expand)
  VBoxContainer: 6 stat rows
    Each: HBoxContainer [StatName (expand) | Value | DeltaIndicator]
```

### 4.5 Formation Screen

```
PanelContainer "TitlePanel" (top, full width)
  Label: "Formation"

PanelContainer "MemberPanel" (main area, expand)
  VBoxContainer: active members + separator + reserve members
    Each: HBoxContainer [CursorLabel | Name (min_size) | Row(F/B) | LV | HP current/max]
    HSeparator between active and reserve

PanelContainer "HintPanel" (bottom, full width)
  Label: instruction text
```

### 4.6 Status Screen

```
PanelContainer "IdentityPanel" (top, full width)
  HBoxContainer: [Portrait placeholder] [Name | Class] [LV | XP | Next] [HP | MP]

HBoxContainer "DetailRow" (expand)
  PanelContainer "StatPanel" (left, expand)
    VBoxContainer: "Stats" header + 6 stat rows + 3 derived stat rows
  PanelContainer "EquipPanel" (right, expand)
    VBoxContainer: "Equipment" header + 5 equipment slot rows
```

### 4.7 Abilities Screen

```
PanelContainer "DescPanel" (top, full width)
  HBoxContainer: DescLabel (left, expand) | CostTypeLabel | CostLabel

PanelContainer "CharPanel" (below desc, full width)
  HBoxContainer: [Portrait placeholder] [Name | Command type] [LV | Resource]

PanelContainer "AbilityPanel" (main area, expand)
  HBoxContainer
    VBoxContainer "LeftCol": 6 ability rows
    VBoxContainer "RightCol": 6 ability rows
```

---

## 5. Implementation Strategy

### Phase 1: StyleBox + Show/Hide Logic
- Create the shared `StyleBoxFlat` as a sub-resource in menu.tscn
- Implement show/hide of main panels in `_open_sub_screen` / `_close_sub_screen`

### Phase 2: Restructure Each Sub-Screen (one at a time)
- Wrap each sub-screen's content in PanelContainers with the StyleBox
- Convert absolute-positioned labels to VBox/HBox container layouts
- Update `@onready` node paths in the corresponding .gd script
- Test each screen individually after restructuring

### Phase 3: Verify + Test
- Manual test all 7 screens at 1280x720
- Verify no text overlap, proper containment within bordered panels
- Run GUT tests to ensure node path updates don't break existing tests

---

## 6. File Map

| File | Action | What Changes |
|------|--------|-------------|
| `game/scenes/overlay/menu.tscn` | MODIFY | Add shared StyleBox, restructure all 7 sub-screens with PanelContainers |
| `game/scripts/ui/menu_overlay.gd` | MODIFY | Show/hide main panels on sub-screen open/close |
| `game/scripts/ui/menu_items.gd` | MODIFY | Update node paths for new container structure |
| `game/scripts/ui/menu_equip.gd` | MODIFY | Update node paths |
| `game/scripts/ui/menu_status.gd` | MODIFY | Update node paths |
| `game/scripts/ui/menu_magic.gd` | MODIFY | Update node paths |
| `game/scripts/ui/menu_abilities.gd` | MODIFY | Update node paths |
| `game/scripts/ui/menu_formation.gd` | MODIFY | Update node paths |
| `game/scripts/ui/menu_config.gd` | MODIFY | Update node paths |

---

## 7. Remaining After This

- Character portraits (placeholder boxes until art assets exist)
- Scroll indicators for long lists
- Transition animations (fade in/out on sub-screen open/close)
- Ley Crystal sub-screen (needs game system implementation first)
