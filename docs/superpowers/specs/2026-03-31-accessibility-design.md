# Accessibility Design

> **Gap:** 4.4 Accessibility Design
> **Status:** Spec complete, pending implementation
> **Date:** 2026-03-31

## Overview

Defines accessibility features for Pendulum of Despair: display scaling,
color-blind support, timing accommodations, input rebinding, motion
sensitivity, and audio captions. Designed to be baked into the Godot
project from day one, not bolted on later.

**Design principle:** The default experience is the full retro SNES
aesthetic. Accessibility features enhance or provide alternatives without
degrading the core experience. Some enhancements (corruption texture
cues, HP bar cracks) benefit all players and are always on.

---

## 1. Display & Scaling

### Base Resolution Change

**New base resolution: 320x180 (16:9).** This replaces the current
256x224 (SNES 8:7) specification in ui-design.md.

**Rationale:** 320x180 is the industry standard for modern pixel-art
games (Celeste, Godot official recommendation). It provides clean
integer scaling at every standard display resolution:

| Display | Scale Factor | Result |
|---------|-------------|--------|
| 720p (1280x720) | 4x | Clean |
| 1080p (1920x1080) | 6x | Clean |
| 1440p (2560x1440) | 8x | Clean |
| 4K (3840x2160) | 12x | Clean |

The old 256x224 does not integer-scale cleanly to any 16:9 resolution,
producing pixel artifacts or requiring significant letterboxing.

**Visual impact:** 320x180 at 16px tiles = 20 tiles wide x 11 full tiles
tall + 4px partial row (camera shows 11 complete tile rows with a 4px
sliver at the top or bottom edge, used for smooth scrolling headroom).
This is slightly wider than SNES (16x14 tiles at 256x224) but preserves
the same visual density, tile size, and aesthetic.

### Rendering

- **Nearest-neighbor interpolation** — no bilinear filtering.
- **Snap 2D transforms to pixel** — prevents sub-pixel positioning.
- **Snap 2D vertices to pixel** — prevents vertex jitter.
- **Integer scaling enforced** — Godot viewport stretch mode with
  integer scale. Letterboxes the remainder (minimal at standard
  resolutions).
- **Bitmap pixel font** as default — rendered at 320x180, scales with
  the game world. Preserves the FF6 text aesthetic.

### High-Res Text Toggle

An accessibility option ("High-Res Text" in Config menu) that renders
text on a separate native-resolution canvas layer using a pixel-styled
font. When enabled:

- Game world remains at 320x180, integer-scaled (unchanged)
- UI text renders at the display's native resolution (1080p, 4K, etc.)
- The font is pixel-styled (maintains the retro aesthetic) but rendered
  at high resolution for crispness and readability
- Implemented via a second Godot Viewport node at native resolution,
  layered over the game viewport

**Default: Off.** The bitmap pixel font is the default experience.
High-Res Text is opt-in for players who need larger, crisper text.

---

## 2. Color-Blind Support

Supports the three common forms of color vision deficiency:
- **Deuteranopia/Deuteranomaly** (red-green, ~6% of males)
- **Protanopia/Protanomaly** (red-green, ~2% of males)
- **Tritanopia/Tritanomaly** (blue-yellow, ~0.01%)

Achromatopsia (total color blindness) is not supported.

### Always-On Enhancements (All Players)

These cues supplement the Pallor desaturation mechanic and benefit
everyone — they make corruption feel more tangible, not just grey.

- **Corruption texture overlay** — as the world desaturates, corrupted
  areas gain a subtle grain/static overlay that intensifies with
  corruption level. Grey zones in dungeons get visible crack patterns
  on tiles. The texture is visible regardless of color perception.
- **Particle type shift** — healthy areas have warm ambient particles
  (dust motes, fireflies in Thornmere, heat shimmer in Caldera).
  Corrupted areas replace these with cold particles (grey ash, static
  sparks, drifting fragments). The particle TYPE change is visible
  even to color-blind players.
- **HP bar shape cue** — below 25% max HP, the bar gains a segmented /
  cracked appearance in addition to the color shift. The bar visually
  breaks apart as HP drops, providing a shape-based danger signal.

### Color-Blind Modes (Config Toggle)

A three-option toggle in Config: Off / Deutan-Protan / Tritan.

**Deuteranopia-Protanopia mode** (covers both red-green types):
- HP bar: blue (healthy) to orange (danger), replacing green-to-red
- Status effect icons: red/green pairs swap to blue/orange equivalents
- Poison status: green becomes distinct purple
- Low HP text warning: red becomes orange

**Tritanopia mode:**
- HP bar: green (healthy) to magenta (danger), replacing green-to-red
- Status effect icons: blue/yellow pairs shift — blue becomes cyan for
  distinction from yellow

**Preview in Config:** Selecting a color-blind mode shows a live sample
panel with an HP bar, 4-5 status icons, and a mini Pallor corruption
preview. The player can verify the mode works for them before leaving
the menu.

**What does NOT change in color-blind modes:**
- Pallor desaturation narrative (warm to grey to new palette) — the
  luminance/saturation shift is perceivable by color-blind players;
  specific hues are not critical to understanding corruption
- UI chrome colors (dark navy windows, blue-grey borders, white text)
  — already high-contrast and not affected
- The always-on texture/particle cues provide the primary corruption
  signal regardless of mode

---

## 3. Timing & Combat Accessibility

### Patience Mode

A new Config toggle that eliminates all time pressure from combat.

**When enabled:**
- ATB Mode forced to Wait
- Battle Speed forced to 6 (slowest)
- **Top-level command menu also pauses all gauges** — this is the key
  difference from standard Wait mode, which only pauses during
  sub-menus (Magic, Item, Ability lists, target selection)
- Real-time status timers (Stop countdown, buff durations) also pause
  during any player decision point

**Result:** Zero time pressure at any point during the player's turn.
ATB gauges still fill between player actions and determine turn order
— the system is still ATB, just without real-time pressure during
decisions.

**Config interaction:**
- Enabling Patience Mode overrides ATB Mode and Battle Speed settings
  (greyed out in Config while Patience Mode is on)
- Disabling Patience Mode restores the previous ATB Mode and Battle
  Speed values
- Can be toggled mid-game from Config at any time

### Existing Timing Controls (Unchanged)

These remain as independent settings:
- Battle Speed: 1-6 (default 3)
- ATB Mode: Active / Wait (default Active)
- Text Speed: Slow / Normal / Fast / Instant (default Normal)
- Battle Cursor: Reset / Memory (default Reset)

Patience Mode is a superset that locks ATB Mode and Battle Speed to
accessibility-safe values while preserving the others.

---

## 4. Input Accessibility

### Keyboard Rebinding

Full rebinding for all keyboard-mapped actions via a "Key Config"
screen in the Config menu.

**Rebindable actions:**
- Move (up, down, left, right)
- Confirm
- Cancel / Back
- Shoulder left (tab/cycle left)
- Shoulder right (tab/cycle right)
- Open menu

**Default layout:** Arrow keys + Space/Enter (confirm) + Escape
(cancel) + Q/E (shoulder). Matches the current ui-design.md spec.

**Conflict detection:** If a key is already bound to another action,
the player is warned and must resolve the conflict before saving.

**One-handed play:** Supported through rebinding — a player can map
all actions to one side of the keyboard. No dedicated one-handed mode
needed.

### Gamepad

Standard mapping via Godot's Input Map system. No custom gamepad
rebinding — controllers are standardized and Godot handles abstraction
natively (Xbox, PlayStation, Switch Pro Controller).

**Default mapping** (per ui-design.md):
- D-pad: move cursor
- A / Cross: confirm
- B / Circle: cancel / back
- L1 / R1: shoulder (tab, cycle, row toggle)
- Start: open menu

### No Mouse Support

This is a gamepad/keyboard game. No click targets, no hover states.
Consistent with the SNES aesthetic.

---

## 5. Motion Sensitivity

### Reduce Motion Master Toggle

A single "Reduce Motion" toggle in Config that applies sensible
defaults for motion-sensitive players.

**When enabled:**
- **Screen flashes disabled** — boss encounter white frames, volatile
  crystal white-outs, ATB gauge 2-frame flash, level-up flash all
  replaced with a brief brightness pulse (no hard white frame)
- **Battle transitions simplified** — mosaic dissolve, Mode 7
  zoom-into-ground, and boss flash-then-transition all replaced with
  a simple fade to black (0.5s). The boss white flash frame is
  already covered by "screen flashes disabled" above.
- **Mode 7 intensity set to minimum** — overworld still uses
  perspective view but with flattened foreshortening (less dramatic
  tilt)
- **Screen shake disabled** — uses existing screen shake toggle
- **Status icon cycling slowed** — 2-frame blink cycle extended to
  8-frame (less flickery)

### Granular Controls

Available independently of the master toggle for fine-tuning:

| Setting | Values | Default |
|---------|--------|---------|
| Screen Shake | On / Off | On |
| Mode 7 Intensity | 1-6 (1 = flat, 6 = full perspective) | 6 |
| Flash Intensity | Off / Reduced / Full | Full |
| Transition Style | Classic (mosaic) / Simple (fade) | Classic |

"Reduced" flash intensity dims flashes to 50% opacity instead of
removing them entirely — a middle ground for players who want some
visual feedback but find full flashes uncomfortable.

### Master Toggle Behavior

Enabling "Reduce Motion" sets all granular controls to their safest
values (shake off, Mode 7 minimum, flash off, transition simple).
The player can then adjust individual settings up from the safe floor.
Disabling "Reduce Motion" restores the previous values.

---

## 6. Subtitles & Captions

### SFX Captions Toggle

A Config option that displays brief text labels for gameplay-relevant
sound effects. When enabled, a small text label appears in the lower
corner of the screen for 2-3 seconds when a functional sound cue fires.

**Captioned events (~8-10 types):**
- [Save Point] — when near a save crystal
- [Encounter] — when the encounter trigger fires
- [Level Up] — on level gain
- [Victory] — battle end
- [Item] — item obtained from chest or pickup
- [Quest Complete] — sidequest completed
- [Phase Change] — boss enters new phase
- [Alert] — alarm or environmental warning

**Not captioned:**
- Ambient audio (forest sounds, factory hum, wind) — atmospheric only
- Narrative silence moments — trust the visual storytelling
- Music changes — these are atmospheric, not gameplay-functional

### No Separate Subtitle System

All dialogue is already displayed as text (typewriter effect in text
boxes). There is no voice acting. No additional subtitle system is
needed.

---

## 7. Config Menu — Complete Accessibility Settings

New settings added by this spec:

| Setting | Values | Default | Section |
|---------|--------|---------|---------|
| Patience Mode | On / Off | Off | 3 |
| Color-Blind Mode | Off / Deutan-Protan / Tritan | Off | 2 |
| High-Res Text | On / Off | Off | 1 |
| Reduce Motion | On / Off | Off | 5 |
| Flash Intensity | Off / Reduced / Full | Full | 5 |
| Transition Style | Classic / Simple | Classic | 5 |
| SFX Captions | On / Off | Off | 6 |

These join the existing settings (per ui-design.md Section 10.3 and
save-system.md Section 2): Battle Speed, ATB Mode, Text Speed, Battle
Cursor, Sound (Stereo/Mono), Music Volume, SFX Volume, Window Color,
Screen Shake, Mode 7 Intensity.

**All accessibility settings are global** (stored in the global config
file, not per save slot) per save-system.md Section 2. Loading a save
never changes accessibility settings.

**Key Config (keyboard rebinding)** is a sub-screen accessible from
Config, not a simple toggle — it has its own dedicated UI for mapping
individual keys.

---

## 8. Cross-Doc Updates Required

This spec introduces changes that affect existing docs:

| Doc | Change |
|-----|--------|
| `ui-design.md` | Update base resolution from 256x224 to 320x180. Update all pixel dimensions, tile counts, and layout calculations. Add High-Res Text rendering layer description. Add color-blind preview panel to Config screen. Add Key Config sub-screen. Update transition descriptions for Simple mode alternative. Add Screen Shake toggle and Mode 7 Intensity (1-6) to Config screen layout (currently missing from Section 10.3). |
| `save-system.md` | Add new accessibility settings to the global config list in Section 2 (Patience Mode, Color-Blind Mode, High-Res Text, Reduce Motion, Flash Intensity, Transition Style, SFX Captions). Also add missing existing settings to align with ui-design.md: Battle Cursor (Reset/Memory), Window Color (RGB), Sound (Stereo/Mono). |
| `combat-formulas.md` | Add Patience Mode rules to ATB section (top-level command pauses gauges, status timers pause during all decisions). |
| `difficulty-balance.md` | Add Patience Mode as an anti-frustration feature. Reference accessibility.md. |
| `visual-style.md` | Add always-on corruption texture/particle cues. Document color-blind palette swaps. |
| `overworld.md` | Update Mode 7 section to reference Reduce Motion alternative (flattened foreshortening). |
| `script/battle-dialogue.md` | Add SFX caption text for the ~8-10 captioned events. |
