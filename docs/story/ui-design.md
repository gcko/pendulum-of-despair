# UI & Menu Design

> Canonical UI design document for Pendulum of Despair. Covers all
> player-facing interfaces: battle screen, menus, dialogue, shops,
> save/load, and exploration HUD.
>
> **Design philosophy:** FF6 minimalist with SNES pixel art aesthetic.
> One modern addition: HP/MP bars alongside numeric values.

---

## 1. Design Philosophy

### 1.1 SNES Pixel Art First

The UI is built as if running on SNES hardware. Every visual element
is pixel art by default:

- **Rendering:** Game viewport is 1280×720 with 4× camera zoom (effective 320×180 game world). Window scaled using
  the largest integer factor that fits the display. Clean integer scaling at 720p (1×), 1080p (1× — letterboxed, 1.5× non-integer), 1440p (2×), 4K (3×). Nearest-neighbor interpolation, no bilinear
  filtering. Letterbox with black bars if the window exceeds the scaled
  area. All UI elements designed on the native pixel grid.
- **Borders:** 2px pixel-art window borders, no anti-aliasing, sharp
  corners (no border-radius). Consistent across all screens.
- **Tile viewport:** 20×11 complete tile rows + 4px partial row at the top or bottom edge (scrolling headroom).
- **High-Res Text:** An optional 'High-Res Text' accessibility setting renders UI text on a separate native-resolution canvas layer. See [accessibility.md](accessibility.md).
- **Font:** Pixel bitmap font (Press Start 2P or custom pixel font),
  rendered at native pixel sizes, no sub-pixel smoothing.
- **Icons:** Hand-pixeled 8×8 or 16×16 sprites for status effects,
  items, cursors, and menu decorations.
- **Bars:** Solid pixel fills — no gradients, no rounded ends. HP/MP/ATB
  bars are rectangles of color stepping pixel-by-pixel.
- **Colors:** Limited sub-palettes per screen element. Dithering for
  transitions. Solid color backgrounds (no alpha blending).
- **Cursor:** Animated pixel-art pointing hand (2-frame idle animation),
  matching FF6's menu cursor.
- **Portraits:** 32×32 pixel-art face portraits for menu screens. Art
  pipeline dependency — portraits must be created for all 6 party
  members + 2 guest NPCs (Cordwyn, Kerra). One neutral expression
  each; emotion variants not needed — Gap 3.3 resolved this with the sprite emotion system (see [dialogue-system.md](dialogue-system.md) Section 2).

### 1.2 Modern Concessions

Only invoked for legibility at target display resolution:

- Text at very small sizes may use sub-pixel rendering to stay readable.
- Damage numbers may use slight scaling for visibility.
- HP/MP bars alongside numeric values (the one intentional modern
  addition — FF6 showed numbers only).

The design intent is always pixel art first. Modern rendering is a
concession to the medium, not a style choice.

### 1.3 FF6 Minimalist Windows

Dark navy windows with thin blue-grey borders. The UI is invisible —
the player focuses on the game world and characters, not the menus.

- **Window background:** Dark navy (SNES palette index for near-black
  blue; CSS reference: `#000040`)
- **Window border:** Thin blue-grey (`#5566aa`), 2px, sharp pixel corners
- **No per-location theming.** Windows and dialogue boxes are constant
  across all biomes. This document is the canonical source for window
  appearance (solid fill, pixel borders) and supersedes the gradient-based
  specs in [visual-style.md](visual-style.md), which should be read for
  thematic rationale (player connection to characters; Pallor static
  never touches dialogue).

### 1.4 Color Palette

| Element | Color | Hex |
|---------|-------|-----|
| Character names | White | `#ffffff` |
| Labels, secondary text | Pale blue | `#ccddff` |
| Selected/active item | Pale yellow | `#ffff88` |
| HP text & bar fill | Green | `#44ff44` / `#44cc44` |
| MP text & bar fill | Blue | `#4488ff` |
| HP bar background | Dark red | `#220000` |
| MP bar background | Dark blue | `#001122` |
| Low HP warning (< 25%) | Bright red | `#ff4444` |
| Gold values | Gold | `#ffcc44` |
| Enemy names | Red | `#ff8888` |
| ATB gauge fill | Gold | `#ffcc00` |
| ATB gauge background | Dark grey | `#222222` |
| Damage numbers (physical) | White | `#ffffff` |
| Damage numbers (healing) | Green | `#44ff44` |
| Damage numbers (miss) | Grey | `#888888` |
| Disabled/unavailable | Muted grey | `#666688` |
| Window background | Dark navy | `#000040` |
| Window border | Blue-grey | `#5566aa` |

### 1.5 Font Sizes (Pixel Grid)

| Context | Size | Notes |
|---------|------|-------|
| Character names, menu headers | 10px | White, bold/uppercase |
| Command options, stat values | 9px | Pale blue (unselected) or yellow (selected) |
| Labels (HP, MP, LV, stat names) | 7–8px | Pale blue or color-coded |
| Description text | 8px | Pale blue |
| Damage numbers | 12px | Float upward with 2-frame animation |
| Tiny labels (status icon tooltips) | 6px | Only where space-constrained |

### 1.6 Unified Status Effect Icon System

8×8 pixel-art icons used consistently across all screens. These icons
are the visual language for status effects — learn them once, recognize
them everywhere.

**Placement:**
- Battle party panel: row of icons *above* character's name (up to 4
  visible; if more than 4, icons scroll on a 2-second timer)
- Spell descriptions: inline icons (e.g., "Cures [poison icon] [blind icon]")
- Item descriptions: inline icons (e.g., "Antidote — Cures [poison icon]")
- Equipment tooltips: inline icons for granted/immune statuses

**Negative status icons (warning colors):**

| Status | Icon Description | Color | Notes |
|--------|-----------------|-------|-------|
| Poison | Skull | Purple `#aa44cc` | 8% HP/turn DoT |
| Burn | Flame | Red `#ff4444` | 5% HP/turn fire DoT |
| Sleep | "Zzz" | Grey `#999999` | Cannot act |
| Confusion | Spinning stars | Yellow `#ffff44` | Random targets |
| Silence | Crossed speech bubble | Pale grey `#aaaaaa` | No spells |
| Blind | Crossed eye | Dark grey `#666666` | Accuracy -50% |
| Petrify | Stone block | Grey `#888888` | Out of combat |
| Slow | Down arrow | Blue `#4466cc` | ATB -50% |
| Stop | Hourglass | Red-grey `#aa6666` | ATB frozen |
| Berserk | Rage face | Orange `#ff8844` | Auto-attack |
| Faint | Skull (hollow) | Dark red `#882222` | KO / unconscious |
| Despair | Grey down-arrow | Grey `#777777` | ATB -25%, damage -20% (distinct from Slow's blue arrow via color and grey static particle effect) |

**Positive status icons (warm/cool positive colors):**

| Status | Icon Description | Color | Notes |
|--------|-----------------|-------|-------|
| Float | Wing | Pale blue `#88bbff` | Immune to Earth/ground |
| Reflect | Mirror/shield | Blue `#44aaff` | Bounces 3 spells |
| Regen | Heart pulse | Green `#44ff44` | 5% HP/turn heal |
| Ironhide (DEF Up) | Shield | Brown `#cc8844` | DEF +40%/25% |
| Wardglass (MDEF Up) | Magic shield | Cyan `#44ddff` | MDEF +40%/25% |
| Quickstep (Haste) | Up arrow | Green `#44cc44` | ATB +50% |
| Rallying Cry (ATK Up) | Sword up | Orange `#ffaa44` | ATK +30% |
| Attunement (MAG Up) | Star | Gold `#ffcc44` | MAG +30% |
| Last Breath (Reraise) | Phoenix feather | Warm gold `#ffdd66` | Revives with 30% HP on Faint |
| Glintmark | Crosshair | White `#ffffff` | Target takes +10% damage |

See [magic.md](magic.md) § Status Effect Reference for the full
canonical status effect list with durations and cure sources.

---

## 2. Battle Screen

### 2.1 Layout

Classic FF6: enemies occupy the upper ~65% of the screen, party info
and commands share the bottom ~35%.

```
┌──────────────────────────────────────────┐
│                                          │
│            Enemy Sprite Area             │
│     [sprite]   [sprite]   [sprite]       │
│     Ley Vermin  Tomb Mite  Bone Warden   │
│                                          │
│                                          │
├───────────────────────────┬──────────────┤
│ [icons]                   │              │
│ EDREN   HP ███░ 680/800   │ ▶ Attack     │
│         MP ██░░  48/ 80 ▐█│   Magic      │
│ [icons]                   │   Bulwark    │
│ LIRA    HP ████ 620/620   │   Item       │
│         MP █░░░  35/ 78 ▐░│   Defend     │
│ [icons]                   │   Flee       │
│ TORREN  HP ██░░ 280/560   │              │
│         MP ███░  96/120 ▐░│              │
│ [icons]                   │              │
│ SABLE   HP ███░ 350/500   │              │
│         MP ████  54/ 60 ▐█│              │
└───────────────────────────┴──────────────┘
```

- `▐█` / `▐░` = ATB gauge, horizontal bar (far right of each character row; fills left-to-right)
- `[icons]` = status effect icons above character name
- `███░` = HP/MP bar (solid pixel fill)

### 2.2 Enemy Area (Upper ~65%)

- Enemy sprites displayed center-to-right (FF6 convention: party
  attacks from the left side of the screen).
- Enemy name label above each sprite: red (`#ff8888`), pixel font.
- Boss enemies get wider sprite allocation.
- Up to 6 enemies in flexible grid (1–3 columns, responsive to
  enemy count and sprite size).
- Damage numbers pop above sprites, float upward over ~0.5 seconds,
  pixel font 12px, 2-frame animation. Color-coded: white (damage),
  green (heal), grey (miss).

### 2.3 Party Panel (Bottom-Left, ~65% Width)

4 rows, one per active party member. When a guest NPC (Cordwyn,
Kerra) is present, a compact 5th row appears below the 4th member
with the same layout but slightly reduced vertical spacing — the
guest does not displace a party member (per
[combat-formulas.md](combat-formulas.md) § Party & Enemy Size; see
[progression.md](progression.md) § Guest NPCs for stat formulas).

Each row contains:

1. **Status icons** — above character name, up to 4 visible
2. **Name** — white, left-aligned. Active character (whose turn it
   is) highlighted in yellow `#ffff88`
3. **HP** — label (green) + solid pixel bar + numeric value
   (e.g., "HP ███░ 680/800"). Bar fill turns red below 25% max HP.
4. **MP** — label (blue) + solid pixel bar + numeric value
5. **ATB gauge** — small horizontal bar at far right of the row.
   Gold fill (`#ffcc00`) on dark background. Fills left to right.
   When full: 2-frame flash alternating gold and white to signal
   "ready to act." See [combat-formulas.md](combat-formulas.md) §
   ATB Gauge System for fill rate formula and status interactions.

### 2.4 Command Panel (Bottom-Right, ~35% Width)

Vertical list of battle commands:

1. Attack
2. Magic
3. [Character-specific ability name]
4. Item
5. Defend
6. Flee

- Pixel-art hand cursor (2-frame idle animation) next to selected command.
- Selected command in yellow `#ffff88`, others in pale blue `#ccddff`.
- The third slot shows the active character's unique command:
  Edren → Bulwark, Cael → Rally, Lira → Forgewright,
  Torren → Spiritcall, Sable → Tricks, Maren → Arcanum.
  See [abilities.md](abilities.md) for each command's sub-abilities.

### 2.5 Battle Message Area

- Small window at top-center of screen.
- Appears for action announcements: spell names, item use, status
  changes, enemy actions.
- Pixel font 8px, pale yellow text on dark navy background.
- Auto-fades after 1.5 seconds. Does not persist.

### 2.6 Target Selection

- Blinking pixel-art arrow cursor above targeted enemy (for offensive
  actions) or below targeted party member (for support/healing).
- Left/right cycles through enemies; up/down cycles through party members.
- Multi-target spells: all valid targets highlighted simultaneously,
  cursor shows "All" text indicator.
- Confirm executes; cancel returns to sub-menu or command panel.

### 2.7 Battle Sub-Menus

When a command is selected, a sub-menu window overlays the left side
of the battle screen (over the party panel).

**Magic sub-menu:**
- Two-column spell list: spell name (left) + MP cost (right).
- Spells the character can't afford: greyed out (`#666688`), not selectable.
- Description line at top of window: effect text + inline status icons.
- Hand cursor. Cancel returns to command panel.

**Item sub-menu:**
- Single-column scrollable list: 8×8 item icon + name + quantity.
- Items not usable in battle: not shown.
- Description line at top. Cancel returns to command panel.

**Character-specific ability sub-menus:**
- Same overlay window as Magic. Layout varies:
  - Edren (Bulwark): stance list — selecting activates (replaces current).
  - Lira (Forgewright): device list with quantity (like items).
  - Torren (Spiritcall): spirit list with Favor pips (small dots:
    0–3 filled = current harmony rating with that spirit; all spirits
    remain usable regardless of Favor level).
  - Sable (Tricks): technique list (Filch, Ransack, Smokescreen,
    Shiv, etc.) — cooldown-based, front-row indicator for steal abilities.
  - Maren (Arcanum): weave list with Weave Gauge cost (like MP cost).
  - Cael (Rally): buff list with MP cost.

**Flee:** No sub-menu. Selecting Flee immediately attempts escape.
Success: "Escaped!" message, battle dissolve. Failure: "Can't escape!"
message, turn consumed. Boss battles: Flee greyed out, not selectable.

**Defend:** No sub-menu. Selecting Defend immediately sets defend
stance. Brief pixel-art shield icon animation over the character's
party panel row.

### 2.8 Battle Results Screen

After winning a battle, a results window appears over the battle screen:

- **XP gained:** "Gained [amount] EXP" (white text).
- **Gold gained:** "Found [amount] Gold" (gold text).
- **Items obtained:** Each drop/steal listed with 8×8 icon + name.
- **Level-up notification:** If any character levels up, their name
  flashes and a fanfare plays. "EDREN reached Level 13!" with new
  stat values shown briefly. If multiple characters level up, shown
  sequentially.
- Confirm button advances through each section. After all results,
  battle dissolves back to exploration.

### 2.9 Maren's Weave Gauge in Battle

Maren's party panel row includes a third gauge below her MP bar:
a thin Weave Gauge bar (purple `#aa44ff` fill on dark background).
This gauge fills when any magic is cast in battle — +10 WG when
any ally other than Maren casts a spell, +5 WG when Maren herself
casts, +15 WG when any enemy casts (per
[abilities.md](abilities.md) § Maren — Arcanum). Max
100 WG, starts at 0 each battle. In the menu Abilities screen, the
current charge is shown (typically 0 outside battle). The Weave
Gauge is narrower than HP/MP bars and does not appear for other
characters.

### 2.10 Scroll Indicators

All scrollable lists (item, magic, equipment, shop) use a small
pixel-art arrow at the top and/or bottom of the list to indicate
more items above/below. The arrow blinks on a 2-frame cycle. No
scrollbar — just directional arrows, matching SNES conventions.

---

## 3. Main Menu

### 3.1 Access

Pressing Start/Menu during exploration. Game world pauses behind a
solid black fill (no alpha blending — consistent with Section 1.1).

### 3.2 Layout

FF6 split: party left (~68% width), commands right (~28% width),
info boxes along the bottom.

```
┌──────────────────────────────┬───────────┐
│ [portrait] EDREN      LV 12 │ ▶ Item    │
│   HP ███████░░ 680 / 800     │   Magic   │
│   MP ████░░░░  48 /  80     │   Abilities│
│──────────────────────────────│   Equip   │
│ [portrait] LIRA       LV 11 │   Crystal │
│   HP █████████ 620 / 620     │   Status  │
│   MP ███░░░░░  35 /  78     │   Formation│
│──────────────────────────────│   Config  │
│ [portrait] TORREN     LV 11 │   Save    │
│   HP ████░░░░░ 280 / 560     │           │
│   MP ███████░░  96 / 120     │           │
│──────────────────────────────│           │
│ [portrait] SABLE      LV 12 │           │
│   HP ██████░░░ 350 / 500     ├───────────┤
│   MP ████████░  54 /  60     │ Time 12:34│
│                              ├───────────┤
│                              │ Gold 4,280│
├──────────────────────────────┴───────────┤
│ Valdris Castle Town                      │
└──────────────────────────────────────────┘
```

### 3.3 Party Panel (Left)

- 4 character rows with generous vertical spacing.
- Each row: 32×32 pixel-art face portrait | Name (white, uppercase) +
  LV (pale blue) | HP bar + numeric | MP bar + numeric.
- Status effect icons above character name (unified icon set).
- 1px dark blue divider between characters.
- Fewer than 4 active members: empty rows left blank.
- Reserve/absent members not shown — only active party.

### 3.4 Command Panel (Right)

Vertical list with pixel-art hand cursor:

| Command | Action |
|---------|--------|
| Item | Opens item screen |
| Magic | Character select → magic list |
| Abilities | Character select → ability list |
| Equip | Character select → equipment screen |
| Crystal | Character select → Ley Crystal screen |
| Status | Character select → stat sheet |
| Formation | Opens formation screen |
| Config | Opens config screen |
| Save | Opens save screen (greyed out if no save point) |

**Character select flow:** Choosing Magic, Abilities, Equip, Crystal,
or Status causes a second cursor to appear on the party panel. Player
selects which character, then the sub-screen opens for that character.

### 3.5 Info Boxes (Bottom)

- **Bottom-left** (~68% width): Location name in pale blue.
- **Bottom-right** (~28% width): Two stacked boxes:
  - Time (HH:MM format, white)
  - Gold (with comma separators, gold `#ffcc44`)

---

## 4. Item Screen

### 4.1 Access

Main Menu → Item.

### 4.2 Layout

FF6 item screen: tabs top, description middle, item list bottom.

```
┌──────────────────────────────────────────┐
│  [USE]   ARRANGE   KEY                   │
├──────────────────────────────────────────┤
│ Cures [poison icon] status               │
├──────────────────────────────────────────┤
│ ● Antidote         :12  ● Hi-Potion  : 5│
│ ● Echo Drop        : 4  ● Ether      : 8│
│ ● Elixir           : 1  ● Eye Drops  : 6│
│ ● Phoenix Feather  : 3  ● Potion     :30│
│ ● Remedy           : 2  ● Sleeping Bag:6│
│ ● Smoke Bomb       : 4  ●            :  │
└──────────────────────────────────────────┘
```

### 4.3 Tab Bar

- Three tabs: **USE** | **ARRANGE** | **KEY**
- USE: consumable items. ARRANGE: cycles through sort orders on each
  press (Type → Name → Quantity → Type...; default sort is Type).
  KEY: key items and quest items (viewable, not usable).
- Active tab highlighted in white, inactive in pale blue.
- Left/right shoulder buttons switch tabs.

### 4.4 Description Area

- Single line below tabs showing highlighted item's description.
- Status effect icons appear inline (e.g., "Cures [poison icon] status").
- Updates live as cursor moves.

### 4.5 Item List

- Two-column scrollable grid.
- Each entry: 8×8 pixel-art item icon + name + quantity (right-aligned,
  colon prefix: `:99`).
- Zero-quantity items not shown.
- Battle-only items greyed out in field.
- Hand cursor on selected item.

### 4.6 Use Flow

Select item → if single-target, party display overlays right side
(4-row layout matching main menu) with character select cursor →
confirm → brief animation + sound effect → return to item list.

---

## 5. Equipment Screen

### 5.1 Access

Main Menu → Equip → [select character].

### 5.2 Layout

FF6 equip screen: sub-commands top, slots left, stats right,
portrait top-right.

```
┌──────────────────────────────────────────┐
│ [EQUIP]  OPTIMUM  REMOVE  EMPTY          │
├────────────────────┬─────────────────────┤
│ Weapon: Valdris Blade│ [portrait] EDREN   │
│ Head  : Iron Helm   ├─────────────────────┤
│ Body  : Chain Mail  │ ATK  42 ▲48         │
│ Access: Power Ring  │ DEF  35 ──          │
│ Crystal: Ember Shard│ MAG  18 ──         │
│                    │ MDEF 22 ──          │
│                    │ SPD  25 ▲27         │
│                    │ LCK  14 ──          │
│                    │ EVA% 12% ──         │
│                    │ MEVA% 8% ──         │
│                    │ CRIT% 3% ──         │
├────────────────────┴─────────────────────┤
│ Fire element  Grants [Quickstep icon]    │
└──────────────────────────────────────────┘
```

### 5.3 Sub-Command Tabs

- **EQUIP:** Manual equipment selection per slot.
- **OPTIMUM:** Auto-equip best available (ATK priority for physical
  characters, MAG for casters).
- **REMOVE:** Unequip one selected slot.
- **EMPTY:** Unequip all slots at once.

### 5.4 Equipment Slots (Left)

5 rows, one per slot (per [equipment.md](equipment.md)):
1. Weapon: [current weapon name]
2. Head: [current head armor name]
3. Body: [current body armor name]
4. Accessory: [current accessory name]
5. Crystal: [current Ley Crystal name + level]

Hand cursor selects a slot. Confirm opens available equipment list
for that slot type.

### 5.5 Available Equipment List

- Replaces the slot list when actively selecting.
- Scrollable list: 8×8 pixel-art icon + equipment name.
- Items equipped by other party members show small "E" indicator.
- "Remove" option at top of list to unequip the slot.

### 5.6 Stat Comparison (Right)

8 core stats + 3 derived stats, in a single vertical list. HP and
MP appear only when the highlighted equipment modifies them (most
gear does not, but items like Life Pendant and Mana Bead do):

HP, MP, ATK, DEF, MAG, MDEF, SPD, LCK, EVA%, MEVA%, CRIT%

Each stat shows: label + current value + delta indicator:
- Green up-arrow (`▲`) + new value for improvement
- Red down-arrow (`▼`) + new value for worse
- No arrow / dash (`──`) for unchanged

Updates live as cursor moves through available equipment.

### 5.7 Element/Status Info (Bottom)

When highlighting equipment with special properties, an info line
appears at the bottom: element affinity and/or status effects using
inline icons from the unified icon set.

---

## 6. Magic Screen

### 6.1 Access

Main Menu → Magic → [select character].

### 6.2 Layout

FF6 magic screen: description top, character info below, spell grid
main area.

```
┌──────────────────────────────────────────┐
│ Flame-elemental attack                   │
├────────────────────┬─────────────────────┤
│                    │ LV  12              │
│    [portrait]      │ HP  680 / 800       │
│                    │ MP   48 /  80       │
├────────────────────┴─────────────────────┤
│ ▶Ember Lance   MP 4 │ Rime Shard       MP 4 │
│  Arc Snap      MP 5 │ Leybalm          MP 3 │
│  Kindlepyre   MP 14 │ Mend             MP 3 │
│  Hoarfall     MP 14 │ Cleansing Draught MP 5│
│  Befuddle      MP 7 │ Ironhide         MP 8 │
│  Quickstep    MP 14 │ Wardglass        MP 8 │
└──────────────────────────────────────────┘
```

### 6.3 Details

- **Description area (top):** Highlighted spell's effect text + inline
  status icons.
- **Character info:** 32×32 portrait, name, LV, HP/MP with bars + numbers.
- **Spell grid (main):** Two-column scrollable list. Spell name (left) +
  MP cost (right). Unlearned spells not shown. Field-unusable spells
  (offensive) greyed out.
- **Field use flow:** Select healing/support spell → character select →
  confirm → animation + sound → MP deducted → return to list.

---

## 7. Abilities Screen

### 7.1 Access

Main Menu → Abilities → [select character].

### 7.2 Layout

Same layout as Magic screen but shows the character's unique ability
set. See [abilities.md](abilities.md) for each command's full details.

### 7.3 Character-Specific Displays

| Character | Ability Set | Unique UI Element |
|-----------|-------------|-------------------|
| Edren | Bulwark stances | Active stance highlighted |
| Lira | Forgewright devices | Quantity shown (like items) |
| Torren | Spiritcall spirits | Favor pips: 0–3 filled dots = harmony rating (all spirits always usable; Favor 3 = permanent upgrade) |
| Sable | Tricks techniques | Cooldown pips (filled = ready, empty = on cooldown); front-row icon on steal abilities |
| Maren | Arcanum weaves | Weave Gauge bar below MP (shows current charge) |
| Cael | Rally commands | MP cost shown (like spells) |

---

## 8. Status Screen

### 8.1 Access

Main Menu → Status → [select character].

### 8.2 Layout

FF6 status screen: portrait and identity left, stats right,
commands bottom-left, equipment bottom-right.

```
┌────────────────────┬─────────────────────┐
│                    │ HP ██████░ 680/ 800  │
│   [portrait]       │ MP ████░░  48/  80  │
│                    │                     │
│   EDREN            │ ATK   42 (+12)      │
│   Knight           │ DEF   35 (+ 8)      │
│   LV 12            │ MAG   18 (+ 0)      │
│                    │ MDEF  22 (+ 4)      │
│   Exp   12,450     │ SPD   25 (+ 3)      │
│   Next   1,230     │ LCK   14 (+ 0)      │
│                    │ EVA%  12%            │
│                    │ MEVA%  8%            │
│                    │ CRIT%  3%            │
├────────────────────┼─────────────────────┤
│ Battle Commands:   │ Weapon : Valdris Blade│
│  Attack            │ Head   : Iron Helm  │
│  Magic             │ Body   : Chain Mail │
│  Bulwark           │ Access : Power Ring │
│  Item              │ Crystal: Ember Shard│
│  Defend            │ [flame icon]        │
└────────────────────┴─────────────────────┘
```

### 8.3 Details

- **Character identity (left):** 32×32 portrait, name, class title
  (Knight/Engineer/Sage/Thief/Archmage/Commander), LV, current XP,
  XP to next level. Status effect icons if any active.
- **Core stats (right):** HP and MP with bars + numeric. All 8 stats
  with equipment bonus in parentheses where nonzero. Derived stats:
  EVA%, MEVA%, CRIT%. See [progression.md](progression.md) for stat
  definitions, growth curves, and caps.
- **Battle commands (bottom-left):** Lists available commands for reference.
- **Equipment summary (bottom-right):** All 5 equipped items by slot.
  Elemental affinity icons at the bottom.

---

## 9. Formation Screen

### 9.1 Access

Main Menu → Formation.

### 9.2 Layout

FF6 order screen: full-width party list with row indicators.

```
┌──────────────────────────────────────────┐
│ Formation                                │
├──────────────────────────────────────────┤
│ ▶[sprite] EDREN    F  LV 12  HP 680/800 │
│  [sprite] LIRA     F  LV 11  HP 620/620 │
│  [sprite] TORREN   B  LV 11  HP 280/560 │
│  [sprite] SABLE    F  LV 12  HP 350/500 │
│──────────────────────────────────────────│
│  [sprite] MAREN       LV 10  HP 440/440 │
│  [sprite] CAEL        LV  9  HP 520/520 │
└──────────────────────────────────────────┘
```

### 9.3 Details

- All available party members listed vertically.
- Each row: 16×20 walking sprite (not portrait) + name + LV + HP numeric.
- Active party (top 4) separated from reserve by divider line.
- **Row indicator:** "F" (white) or "B" (pale blue) next to each active member.
- **Reorder:** Select character with confirm → move cursor to new position
  → confirm to swap.
- **Row toggle:** Shoulder button on any active member toggles Front/Back.
- **Default rows:** Edren F, Cael F, Lira F, Sable F, Torren B, Maren B
  (per [characters.md](characters.md); Sable needs front row for Steal).
- **Restrictions:** Minimum 1 active member. Guest NPCs (Cordwyn, Kerra)
  locked to active party with small lock icon — cannot move to reserve.
- **Cael absence:** Cael leaves the party during the Interlude and does
  not return. When absent, he does not appear in the formation list.
  The active party adjusts to whoever is available (5 members from
  Interlude onward, so 4 active + 1 reserve).
- **Party lead** (position 1) is the sprite shown on the overworld.

---

## 10. Config Screen

### 10.1 Access

Main Menu → Config.

### 10.2 Layout

FF6 config screen: label/value pairs in a single scrollable list.

```
┌──────────────────────────────────────────┐
│ Config                                   │
├──────────────────────────────────────────┤
│ Battle Speed    ◀ 1  2 [3] 4  5  6 ▶    │
│ ATB Mode          [Active]  Wait         │
│ Text Speed        Slow [Normal] Fast Inst│
│ Battle Cursor     [Reset]  Memory        │
│ Sound             [Stereo] Mono          │
│ Music Volume      ████████░░  8          │
│ SFX Volume        ████████░░  8          │
│──────────────────────────────────────────│
│ Window Color                             │
│   R ◀██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▶  0│
│   G ◀██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▶  0│
│   B ◀████████░░░░░░░░░░░░░░░░░░░░░░░▶  8│
│                                          │
│   ┌──────────┐                           │
│   │ Preview  │                           │
│   └──────────┘                           │
└──────────────────────────────────────────┘
```

### 10.3 Settings

| Setting | Values | Default | Notes |
|---------|--------|---------|-------|
| Battle Speed | 1–6 | 3 | 1 = fastest, 6 = slowest (matches FF6). Left/right to adjust. See [combat-formulas.md](combat-formulas.md) § Battle Speed Config. |
| ATB Mode | Active / Wait | Active | Active: gauges fill during menus. Wait: gauges pause in sub-menus. |
| Text Speed | Slow / Normal / Fast / Instant | Normal | ~30 / ~60 / ~120 chars/sec / immediate. |
| Battle Cursor | Reset / Memory | Reset | Reset: returns to Attack each turn. Memory: remembers last command. |
| Sound | Stereo / Mono | Stereo | |
| Music Volume | 0–10 | 8 | Pixel bar: 10 small squares, filled = level. |
| SFX Volume | 0–10 | 8 | Same pixel bar visualization. |
| Screen Shake | On / Off | On | Toggles camera rumble in battles and scripted events. |
| Mode 7 Intensity | 1–6 | 6 | Controls overworld perspective foreshortening (1 = flat, 6 = full perspective). See [overworld.md](overworld.md). |
| Window Color | R 0–31, G 0–31, B 0–31 | R 0, G 0, B 8 | FF6-style RGB sliders to tint window background. 5-bit values map to 8-bit via `value × 8`. |
| Key Config | — | — | Opens a sub-screen for keyboard rebinding of all battle and menu commands. |

- Window Color preview box updates in real-time as player adjusts sliders.
- Hand cursor on active setting. Left/right adjusts value.

#### 10.3a Accessibility Settings

| Setting | Values | Default | Notes |
|---------|--------|---------|-------|
| Patience Mode | On / Off | Off | Forces ATB Wait mode + Battle Speed 6 + pauses all gauges during top-level command selection. Zero time pressure during any player decision. See [accessibility.md](accessibility.md) Section 3. |
| Color-Blind Mode | Off / Deutan-Protan / Tritan | Off | Swaps specific color pairs on HP bars, status icons, and poison color. Does NOT change UI chrome or world colors. Live preview panel shows sample HP bar, status icons, and Pallor corruption preview. See [accessibility.md](accessibility.md) Section 2. |
| High-Res Text | On / Off | Off | Renders UI text on a separate native-resolution canvas layer for crisper text at high resolutions. See [accessibility.md](accessibility.md) Section 1. |
| Reduce Motion | On / Off | Off | Disables screen flashes, simplifies battle transitions (mosaic to fade), sets Mode 7 to minimum, disables screen shake, slows status icon cycling. Sets all granular motion controls to safe values. See [accessibility.md](accessibility.md) Section 5. |
| Flash Intensity | Off / Reduced / Full | Full | Off: disables screen flashes entirely. Reduced: dims flashes to 50% opacity. Full: default behavior. |
| Transition Style | Classic / Simple | Classic | Classic: mosaic dissolve and Mode 7 zoom. Simple: 0.5s fade to black for all transitions including boss. |
| SFX Captions | On / Off | Off | Brief text labels (2-3s) in lower corner for gameplay sounds: [Save Point], [Encounter], [Level Up], [Victory], [Item], [Quest Complete], [Phase Change], [Alert]. See [accessibility.md](accessibility.md) Section 6. |

---

## 11. Shop Interface

### 11.1 Access

Interacting with a shopkeeper NPC.

### 11.2 Entry

Small window prompt: **Buy** | **Sell** | **Exit**. Hand cursor to select.

### 11.3 Buy Mode

```
┌──────────────────────────────────────────┐
│ Valdris Blade — ATK +10. Standard issue. │
│ [Ed:lit] [Li:dim] [To:dim] [Sa:dim]     │
├──────────────────────────┬───────────────┤
│ ▶● Valdris Blade    300 │ ATK  42 ▲48   │
│  ● Knight's Edge    500 │ DEF  35 ──    │
│  ● Iron Helm        200 │ MAG  18 ──    │
│  ● Chain Mail       300 │ MDEF 22 ──    │
│  ● Power Ring       300 │ SPD  25 ──    │
│  ● Potion       (x30) 50│ LCK  14 ──    │
│  ● Ether         (x8)200│              │
│  ● Antidote    (x12)  50│              │
├──────────────────────────┴───────────────┤
│                              Gold: 4,280 │
└──────────────────────────────────────────┘
```

- **Gold display (bottom-right):** Current gold.
- **Description area (top):** Item/equipment description + inline status
  icons. For equipment: small party member sprite icons showing who can
  equip it (lit = compatible, dimmed = cannot).
- **Shop inventory (left):** Scrollable list with 8×8 icon + name +
  price. Items already owned show current quantity in parentheses.
  Items player can't afford: price in grey.
- **Stat comparison (right, equipment only):** Same green/red arrow
  format as Equip screen. Shoulder buttons cycle through party members.
- **Quantity select (consumables):** After confirming, number selector
  1–99 with live total cost. Equipment always buys 1.

### 11.4 Sell Mode

- **Gold display:** Same position.
- **Player inventory:** Scrollable list with sell price (50% of buy
  price; see [economy.md](economy.md)).
- **"E" indicator** on equipped items. Selecting shows confirm prompt:
  "Equipped by [name]. Sell anyway?"
- Key items and quest items not shown (cannot be sold).
- **Quantity select** for stackable items.

---

## 12. Dialogue & Text System

### 12.1 Dialogue Box

- Full screen width, bottom-anchored, 3 lines of visible text.
- Dark navy background, pixel-art borders (same window style as menus).
- No character portraits in the dialogue box. This is an intentional
  design decision: portraits appear in menu screens only (main menu,
  status, equip, etc.), not in dialogue. Gap 3.3 (Dialogue System)
  inherits this decision.
- Character name label in a small inset tag at the top-left corner of
  the box (white text on slightly lighter background).

### 12.2 Text Rendering

- Pixel font, character-by-character typewriter effect.
- Speed per Config setting:
  - Slow: ~30 characters/second
  - Normal: ~60 characters/second
  - Fast: ~120 characters/second
  - Instant: full text appears immediately
- Pressing confirm instantly completes the current text box.
- When text is complete: small bouncing pixel-art down-arrow in
  bottom-right corner signals "press to advance."

### 12.3 Multi-Page Dialogue

- Text exceeding 3 lines pauses with advance arrow.
- Confirm advances to next page.
- No scrollback — previous pages are gone (FF6 standard).

### 12.4 Choice Prompts

- Small window above or beside the dialogue box.
- 2–4 options listed vertically with hand cursor.
- Selected option in yellow, others in pale blue.
- Confirm selects. Cancel selects the bottom option (typically "No").

### 12.5 NPC Interaction Model

- Single interaction per confirm press. Dialogue plays, ends.
- Re-talking repeats current dialogue (may change based on event flags).
- No repeatable dialogue trees. Single linear exchanges with
  occasional choice prompts.

---

## 13. Save/Load Screen

### 13.1 Access

Main Menu → Save (at save points) or Title Screen → Load. At save points,
interaction opens a 3-option menu (Rest / Rest & Save / Save) before the
save screen. See Section 13.7.

### 13.2 Layout

Enhanced FF6: 3 save slots with full party info. Three slots is an
intentional retro-fidelity decision matching FF6. No NG+ exists (per
[postgame.md](postgame.md)), so no additional slots are needed.

```
┌──────────────────────────────────────────┐
│                  Save                    │
├──────────────────────────────────────────┤
│ Valdris Castle Town   Time 12:34 Gold 4,280│
│ [Ed] Edren 12 ██░ [Li] Lira 11 ███      │
│ [To] Torren 11 █░ [Sa] Sable 12 ██░     │
├──────────────────────────────────────────┤
│ Ember Vein B1         Time  5:12 Gold 1,430│
│ [Ed] Edren 8 ███ [Ca] Cael 8 ███        │
│ [Li] Lira 7 ██░  [To] Torren 7 █░       │
├──────────────────────────────────────────┤
│                 Empty                    │
└──────────────────────────────────────────┘
```

### 13.3 Populated Slot

- **Header row:** Location name (left) + Time HH:MM + Gold (right).
- **Party row:** All 4 active members displayed horizontally:
  - 16×20 walking sprite
  - Name + LV (compact)
  - Tiny HP bar (pixel fill, no numeric — visual health state only)
- Selected slot: gold border (`#ffcc44`), hand cursor.

### 13.4 Empty Slot

- Centered text "Empty" in muted grey (`#666688`).
- Standard blue border.

### 13.5 Save Flow

Cursor on slot → confirm → "Overwrite?" if populated (Yes/No) →
brief save animation (pixel-art sparkle effect) → "Saved." message →
return to menu.

**Copy:** Select source slot → select destination → "Overwrite?" if
populated → copy complete.

**Delete:** Select slot → "Delete this save?" → slot cleared.

### 13.6 Load Screen

- **Title:** "Load"
- **Auto-save slot (top):** Blue accent (#88aaff), labeled "AUTO" with left
  border highlight (3px solid #88aaff). Auto-save slot displays most recent
  auto-save data if available.
- **Divider:** Horizontal line separating auto-save from manual slots.
- **Manual slots (below):** 3 slots with same layout as Save screen.
- **Selection:** Empty slots not selectable (cursor skips). Confirm on
  populated slot loads with brief fade transition.

### 13.7 Save Points

- Visually distinct pixel-art sprite in the game world (glowing crystal,
  2-frame shimmer animation).
- Walking onto one: glow intensifies, opens a 3-option menu:
  - **Rest:** Opens sub-menu of rest items (Sleeping Bag / Tent / Pavilion).
    If no items available, default to free 25% MP recovery.
  - **Rest & Save:** Perform rest first, then open the save screen.
  - **Save:** Open the save screen directly.
- Also accessible from Main Menu → Save, but only on a save point;
  otherwise greyed out — just not selectable.

### 13.8 Auto-Save Slot Rules

- **Dedicated slot:** Separate from the 3 manual save slots.
- **Manual operations:** Cannot be manually overwritten, copied to, or deleted.
- **Visibility:** Appears only on Load screen (not visible on Save screen).
- **Promotion:** Can be copied FROM to a manual slot, promoting an auto-save
  to a permanent manual save.

---

## 14. Ley Crystal Screen

### 14.1 Access

Main Menu → Crystal → [select character].

### 14.2 Layout

Adapted from FF6 Relic screen: 1 crystal slot, available list, stats.

```
┌──────────────────────────────────────────┐
│ ATK +2, DEF +1. Fire resist +25%         │
│ Lv 5: ATK +2, DEF +1 (max)              │
│ ⚠ Flame friendly fire once per battle   │
│ Lv 4→5: 180 XP to next                  │
├──────────────────────┬───────────────────┤
│ Crystal: Flame Heart │ [portrait] EDREN │
│   Lv 4               │                   │
│ XP ████████░░ 120/180│                   │
├──────────────────────┼───────────────────┤
│ ▶● Flame Heart    Lv4│ ATK  42 ──       │
│  ● Ember Shard    Lv3│ DEF  35 ──       │
│  ● Iron Core      Lv2│ MAG  18 ▲22      │
│  ● Quicksilver    Lv2│ MDEF 22 ▲26      │
│  ● Ley Prism      Lv4│ SPD  25 ▼23      │
│  ● Ward Stone     Lv1│ LCK  14 ──       │
│  E Lifestone      Lv2│ [flame+] [frost-]│
│  ● Remove             │                  │
└──────────────────────┴───────────────────┘
```

### 14.3 Details

- **Crystal slot (top-left):** Currently equipped crystal name + level.
  8×8 pixel-art crystal icon, color-coded by element. XP bar (pixel
  fill) with numeric showing progress to next level.
- **Description (top):** Highlighted crystal's passive effect, unlocked
  ability, negative effect (in red), and next-level preview (muted).
- **Available list (left):** All collected Ley Crystals. Icon + name +
  level. "E" indicator + character name for crystals equipped by others.
  "Remove" option at bottom of the list.
- **Stat comparison (right):** Same green/red arrow format. Also shows
  elemental affinity changes as small element icons with +/- indicators.
- **Portrait + name (top-right):** 32×32 portrait of selected character.

See [progression.md](progression.md) § Ley Crystal System for the
18 crystals, 5 XP-based levels, and negative effect rules.

---

## 15. Exploration UI

### 15.1 No Persistent HUD

The screen is 100% game world during exploration. No minimap, no HP
overlay, no compass. Player uses the pause menu for all information.

### 15.2 Location Name Flash

- Entering a new area: location name appears center-top in a small
  pixel-art window.
- Fade in 0.5s → hold 2s → fade out 0.5s.
- Pixel font, white text, dark navy background with border.
- Does not reappear when re-entering the same area without leaving.

### 15.3 Interactable Objects

- No floating icons or button prompts.
- Objects visually distinct through sprite design: chests are chests,
  save points glow, NPCs idle-animate, doors are doors.
- Player presses confirm near an object. No interaction = no response.

### 15.4 Treasure Chests

- Open animation: chest lid flips, 3-frame pixel animation.
- Small center-screen window: 8×8 item icon + "Found [Item Name]!"
  or "Found [amount] Gold!"
- Confirm dismisses. Opened chests stay open (sprite change persists).

### 15.5 Screen Transitions

| Transition | Effect |
|------------|--------|
| Between areas | Fade to black (0.3s out, 0.3s in) |
| Battle encounter | FF6-style mosaic dissolve (progressive pixelation: screen tiles double in size over 0.5s until unrecognizable, then cut to battle screen) |
| Battle end | Reverse dissolve back to exploration |
| Menu open/close | Instant (1 frame, no animation) |

**Transition Style Note:** When Transition Style is set to Simple (see Config § 10.3a), all mosaic dissolve and Mode 7 zoom transitions are replaced with a 0.5s fade to black. Boss flash-then-transition is also replaced with fade. See [accessibility.md](accessibility.md).

### 15.6 Save Points

- Glowing pixel-art crystal sprite, 2-frame shimmer idle animation.
- Walking onto it: glow intensifies, opens 3-option menu (see Section 13.7).

---

## 16. Pallor Narrative Integration

The UI respects the [visual-style.md](visual-style.md) color-as-hope
narrative:

- **UI chrome never desaturates.** The Pallor drains color from the
  game world, but menu and dialogue window backgrounds, borders, and
  core HUD elements (HP/MP bars, command windows, system frames)
  remain in full color. The player's interface is their anchor.
- **One scripted border flicker:** During Cael's final dialogue before
  closing the door (Act IV), the dialogue box border flickers grey for
  2 frames, then returns to the canonical blue-grey (`#5566aa`). This
  is the only moment when the
  window border color itself acknowledges the Pallor (per
  [visual-style.md](visual-style.md)).
- **Menu portrait desaturation (allowed):** Character portraits in menu
  screens reflect status: normal coloring in healthy states, desaturated
  tint when affected by Pallor-adjacent status effects (e.g., Despair).
  This affects portrait art only, not window backgrounds or chrome.
  Per [visual-style.md](visual-style.md) § Menu Backgrounds.
- **Status effect: Despair (allowed dimming):** When a character has
  the Despair status, their name in the battle party panel dims slightly
  (not fully grey, just reduced brightness). The grey down-arrow icon
  appears in their status icon row. Menu portrait gains a desaturated
  tint. These are status-driven content changes, not global UI
  desaturation.
- **Act III exploration:** As the Pallor Wastes desaturate the world,
  party sprites remain in full color. The UI contrast (vivid bars and
  text against the greying world) reinforces the theme that the
  characters' determination persists.

---

## 17. Input Mapping

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move cursor | Arrow keys | D-pad |
| Confirm | Space / Enter | A / Cross |
| Cancel / Back | Escape | B / Circle |
| Switch tabs / Shoulder | Q / E | L1 / R1 |
| Toggle row (Formation) | Q / E | L1 / R1 |
| Cycle party (Shop compare) | Q / E | L1 / R1 |
| Open menu (exploration) | Escape / Enter | Start |

---

## 18. Transport Interactions

Transport services use existing UI patterns — no new screens required.
See [transport.md](transport.md) for full transport mechanics.

### 18.1 Rail/Ferry (NPC Dialogue)

The Rail Conductor and Ferryman use the standard dialogue choice prompt
(Section 12.4). Destinations listed vertically with fare inline:
"Ashmark — 100g". Unaffordable destinations show the fare in grey text
(per Section 11 shop pattern). Cancel = "Never mind" (rail) or "No"
(ferry). Insufficient gold fallback: Rail Conductor says "Can't afford
the fare? Overland's free, just slower." Ferryman says "Two hundred
gold. Come back when you have it."

### 18.2 Ley Stag (Character Field Menu)

Torren's overworld field ability is "Call Stag" — accessed by selecting
Torren from the party menu on the overworld. Same slot as Lira's
"Forge Devices" and Maren's Linewalk. If mounted: option changes to
"Dismiss Stag". Restricted terrain shows contextual message per
[transport.md](transport.md). If `stag_lost`: option greyed out with
"The bond is broken..."

### 18.3 Character Field Abilities (Formalized)

Each party member may have one overworld field ability accessed by
selecting the character from the party menu on the overworld.
Currently defined:

| Character | Ability | Source |
|-----------|---------|--------|
| Lira | Forge Devices | [crafting.md](crafting.md) |
| Torren | Call Stag | [transport.md](transport.md) |
| Maren | Linewalk | [magic.md](magic.md) |
| Edren | — | No field ability |
| Sable | — | No field ability |

Characters without a field ability do not show a field ability option
when selected from the party menu on the overworld — the menu slot
only renders for characters that have one.

---

## 19. Cross-References

| System | Reference |
|--------|-----------|
| ATB fill rate formula | [combat-formulas.md](combat-formulas.md) § ATB Gauge System |
| Battle speed settings | [combat-formulas.md](combat-formulas.md) § Battle Speed Config |
| Active/Wait mode | [combat-formulas.md](combat-formulas.md) § Active/Wait Mode |
| Row system | [combat-formulas.md](combat-formulas.md) § Row Modifier |
| Status effects | [magic.md](magic.md) § Status Effect Reference |
| Equipment slots | [equipment.md](equipment.md) § Equipment Slots |
| Ley Crystal system | [progression.md](progression.md) § Ley Crystal System |
| Character stats | [progression.md](progression.md) § Character Growth |
| Shop inventories | [economy.md](economy.md) § Shop Inventories |
| Save data structure | `packages/shared/src/types/game.ts` |
| Visual style / palette | [visual-style.md](visual-style.md) |
| Physical damage formula | [combat-formulas.md](combat-formulas.md) § Physical Damage |
| Magic damage formula | [combat-formulas.md](combat-formulas.md) § Magic Damage |

### Deferred Items Resolved

- **ATB visual representation** (from Gap 2.2): Horizontal bar, gold
  fill, inline with each character's party panel row, 2-frame flash
  when full.
- **Dialogue box specs** (for Gap 3.3): Full-width bottom-anchored,
  3-line, typewriter effect, no portraits.

### What This Does NOT Cover

- Pixel art asset creation (sprites, portraits, icons) — art pipeline.
- Sound effect design — audio pipeline.
- Animation frame data — implementation detail.
- Title screen / game over screen — separate design task.
- Bestiary viewer / completion tracker — designed in [postgame.md](postgame.md) (Gap 3.6 COMPLETE). Displayed at The Pendulum tavern via Sable NPC dialogue.
