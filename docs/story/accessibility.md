# Accessibility

> Defines accessibility features: display scaling, color-blind support,
> timing accommodations, input rebinding, motion sensitivity, and audio
> captions. These are baked into the project from day one, not bolted
> on later.
>
> **Design principle:** The default experience is the full retro SNES
> aesthetic. Accessibility features enhance or provide alternatives
> without degrading the core experience. Some enhancements (corruption
> texture cues, HP bar cracks) benefit all players and are always on.
>
> **Related docs:** [ui-design.md](ui-design.md) |
> [visual-style.md](visual-style.md) |
> [combat-formulas.md](combat-formulas.md) |
> [difficulty-balance.md](difficulty-balance.md) |
> [overworld.md](overworld.md) | [save-system.md](save-system.md) |
> [script/battle-dialogue.md](script/battle-dialogue.md)

---

## 1. Display & Scaling

### Base Resolution

**320x180 (16:9).** This replaces the original 256x224 (SNES 8:7)
specification. 320x180 is the industry standard for modern pixel-art
games and provides clean integer scaling at every common display size.

| Display | Scale Factor | Result |
|---------|-------------|--------|
| 720p (1280x720) | 4x | Clean |
| 1080p (1920x1080) | 6x | Clean |
| 1440p (2560x1440) | 8x | Clean |
| 4K (3840x2160) | 12x | Clean |

### Tile Viewport

At 16px tiles: **20 tiles wide x 11 full tiles tall + 4px scrolling
headroom** (a 4px partial row at the top or bottom edge for smooth
scrolling). Slightly wider than SNES (16x14 tiles at 256x224) but
preserves the same visual density and aesthetic.

### Rendering Rules

- **Nearest-neighbor interpolation** -- no bilinear filtering.
- **Snap 2D transforms to pixel** -- prevents sub-pixel positioning.
- **Snap 2D vertices to pixel** -- prevents vertex jitter.
- **Integer scaling enforced** -- Godot viewport stretch mode with
  integer scale. Letterboxes the remainder (minimal at standard
  resolutions).
- **Bitmap pixel font** as default -- rendered at 320x180, scales
  with the game world. Preserves the FF6 text aesthetic.

### High-Res Text Toggle

Config option. When enabled:

- Game world remains at 320x180, integer-scaled (unchanged).
- UI text renders at the display's native resolution (1080p, 4K, etc.)
  via a second Godot Viewport node layered over the game viewport.
- The font is pixel-styled (retro aesthetic intact) but rendered at
  high resolution for crispness and readability.

**Default: Off.** The bitmap pixel font is the default experience.
High-Res Text is opt-in for players who need larger, crisper text.

See [ui-design.md](ui-design.md) for layout dimensions and text box
specifications.

---

## 2. Color-Blind Support

Covers the three common forms of color vision deficiency:
- **Deuteranopia / Deuteranomaly** (red-green, ~6% of males)
- **Protanopia / Protanomaly** (red-green, ~2% of males)
- **Tritanopia / Tritanomaly** (blue-yellow, ~0.01%)

Achromatopsia (total color blindness) is not supported.

### Always-On Enhancements

These cues supplement the Pallor desaturation mechanic and benefit
all players -- they make corruption feel tangible, not just grey.
No toggle required; always active.

| Cue | Description |
|-----|-------------|
| Corruption texture overlay | As the world desaturates, corrupted areas gain a subtle grain/static overlay that intensifies with corruption level. Grey dungeon zones show visible crack patterns on tiles. Visible regardless of color perception. |
| Particle type shift | Healthy areas: warm ambient particles (dust motes, fireflies in Thornmere, heat shimmer in Caldera). Corrupted areas: cold particles (grey ash, static sparks, drifting fragments). The particle TYPE change is visible to color-blind players. |
| HP bar shape cue | Below 25% max HP, the bar gains a segmented / cracked appearance in addition to the color shift. The bar visually breaks apart as HP drops -- a shape-based danger signal. |

### Color-Blind Mode Toggle

Three-option Config toggle: **Off / Deutan-Protan / Tritan.**

**Deutan-Protan palette swaps** (covers both red-green types):

| Element | Normal | Deutan-Protan |
|---------|--------|---------------|
| HP bar (healthy) | Green | Blue |
| HP bar (danger) | Red | Orange |
| Status icons (red/green pairs) | Red / Green | Blue / Orange |
| Poison status | Green | Purple |
| Low HP text warning | Red | Orange |

**Tritan palette swaps:**

| Element | Normal | Tritan |
|---------|--------|--------|
| HP bar (healthy) | Green | Green |
| HP bar (danger) | Red | Magenta |
| Status icons (blue/yellow pairs) | Blue / Yellow | Cyan / Yellow |

### Config Preview

Selecting a color-blind mode shows a live sample panel with an HP
bar, 4-5 status icons, and a mini Pallor corruption preview. The
player verifies the mode works for them before leaving the menu.

### What Does NOT Change

- **Pallor desaturation narrative** (warm to grey to new palette) --
  the luminance/saturation shift is perceivable by color-blind
  players; specific hues are not critical to understanding corruption.
- **UI chrome colors** (dark navy windows, blue-grey borders, white
  text) -- already high-contrast and not affected.
- **Always-on texture/particle cues** provide the primary corruption
  signal regardless of mode.

See [visual-style.md](visual-style.md) for the Pallor palette
pipeline. See [ui-design.md](ui-design.md) for UI chrome specs.

---

## 3. Patience Mode

A Config toggle that eliminates all time pressure from combat.

### Rules When Enabled

- ATB Mode forced to **Wait**.
- Battle Speed forced to **6** (slowest).
- **Top-level command menu pauses all gauges** -- the key difference
  from standard Wait mode, which only pauses during sub-menus (Magic,
  Item, Ability lists, target selection).
- Real-time status timers (Stop countdown, buff durations) also
  **pause during any player decision point**.

**Result:** Zero time pressure at any point during the player's turn.
ATB gauges still fill between player actions and determine turn
order -- the system is still ATB, just without real-time pressure
during decisions.

### Config Interaction

- Enabling Patience Mode **overrides** ATB Mode and Battle Speed
  settings (greyed out in Config while active).
- Disabling Patience Mode **restores** the previous ATB Mode and
  Battle Speed values.
- Can be toggled mid-game from Config at any time.

### Existing Timing Controls (Unchanged)

These remain as independent settings:

| Setting | Values | Default |
|---------|--------|---------|
| Battle Speed | 1-6 | 3 |
| ATB Mode | Active / Wait | Active |
| Text Speed | Slow / Normal / Fast / Instant | Normal |
| Battle Cursor | Reset / Memory | Reset |

Patience Mode is a superset that locks ATB Mode and Battle Speed to
accessibility-safe values while preserving the others.

See [combat-formulas.md](combat-formulas.md) for ATB gauge mechanics.
See [difficulty-balance.md](difficulty-balance.md) for anti-frustration
design philosophy.

---

## 4. Input Accessibility

### Keyboard Rebinding

Full rebinding via a **Key Config** sub-screen in the Config menu.

**Rebindable actions:**

| Action | Default Key |
|--------|-------------|
| Move up | Up arrow |
| Move down | Down arrow |
| Move left | Left arrow |
| Move right | Right arrow |
| Confirm | Space / Enter |
| Cancel / Back | Escape |
| Shoulder left | Q |
| Shoulder right | E |
| Open menu | (per ui-design.md) |

**Conflict detection:** If a key is already bound to another action,
the player is warned and must resolve the conflict before saving.

**One-handed play:** Supported through rebinding -- a player can map
all actions to one side of the keyboard. No dedicated one-handed mode
needed; the full rebind system covers it.

### Gamepad

Standard mapping via Godot's Input Map system. No custom gamepad
rebinding -- controllers are standardized and Godot handles
abstraction natively (Xbox, PlayStation, Switch Pro Controller).

| Button | Action |
|--------|--------|
| D-pad | Move cursor |
| A / Cross | Confirm |
| B / Circle | Cancel / Back |
| L1 / R1 | Shoulder (tab, cycle, row toggle) |
| Start | Open menu |

### No Mouse Support

This is a gamepad/keyboard game. No click targets, no hover states.
Consistent with the SNES aesthetic.

See [ui-design.md](ui-design.md) for input mapping and menu
navigation specs.

---

## 5. Motion Sensitivity

### Reduce Motion Master Toggle

A single Config toggle that applies sensible defaults for
motion-sensitive players.

**When enabled:**

- **Screen flashes disabled** -- boss encounter white frames, volatile
  crystal white-outs, ATB gauge flash, level-up flash all replaced
  with a brief brightness pulse (no hard white frame).
- **Battle transitions simplified** -- mosaic dissolve, Mode 7
  zoom-into-ground, and boss flash-then-transition all replaced with
  a simple fade to black (0.5s).
- **Mode 7 intensity set to minimum** -- overworld still uses
  perspective view but with flattened foreshortening (less dramatic
  tilt).
- **Screen shake disabled**.
- **Status icon cycling slowed** -- 2-frame blink cycle extended to
  8-frame (less flickery).

### Granular Controls

Available independently of the master toggle for fine-tuning:

| Setting | Values | Default |
|---------|--------|---------|
| Screen Shake | On / Off | On |
| Mode 7 Intensity | 1-6 (1 = flat, 6 = full perspective) | 6 |
| Flash Intensity | Off / Reduced / Full | Full |
| Transition Style | Classic (mosaic) / Simple (fade) | Classic |

"Reduced" flash intensity dims flashes to 50% opacity instead of
removing them entirely -- a middle ground for players who want some
visual feedback but find full flashes uncomfortable.

### Master Toggle Behavior

Enabling "Reduce Motion" sets all granular controls to their safest
values (shake off, Mode 7 minimum, flash off, transition simple).
The player can then adjust individual settings up from the safe
floor. Disabling "Reduce Motion" restores the previous values.

See [overworld.md](overworld.md) for Mode 7 perspective rendering.
See [ui-design.md](ui-design.md) for battle transition specs.

---

## 6. SFX Captions

### SFX Captions Toggle

Config option. When enabled, a small text label appears in the lower
corner of the screen for 2-3 seconds when a gameplay-relevant sound
cue fires.

### Captioned Events

| Caption | Trigger |
|---------|---------|
| [Save Point] | Near a save crystal |
| [Encounter] | Encounter trigger fires |
| [Level Up] | Level gained |
| [Victory] | Battle end |
| [Item] | Item obtained from chest or pickup |
| [Quest Complete] | Sidequest completed |
| [Phase Change] | Boss enters new phase |
| [Alert] | Alarm or environmental warning |

### What Is NOT Captioned

- **Ambient audio** (forest sounds, factory hum, wind) -- atmospheric
  only, not gameplay-functional.
- **Narrative silence moments** -- trust the visual storytelling.
- **Music changes** -- atmospheric, not gameplay-functional.

### No Separate Subtitle System

All dialogue is already displayed as text (typewriter effect in text
boxes). There is no voice acting. No additional subtitle system is
needed.

See [script/battle-dialogue.md](script/battle-dialogue.md) for
battle dialogue and phase-change scripting.

---

## 7. Config Menu Summary

Complete table of all accessibility-relevant settings. All settings
are **global** (stored in the global config file, not per save slot)
per [save-system.md](save-system.md) Section 2. Loading a save never
changes these values.

### New Settings (This Document)

| Setting | Values | Default | Section |
|---------|--------|---------|---------|
| Patience Mode | On / Off | Off | 3 |
| Color-Blind Mode | Off / Deutan-Protan / Tritan | Off | 2 |
| High-Res Text | On / Off | Off | 1 |
| Reduce Motion | On / Off | Off | 5 |
| Flash Intensity | Off / Reduced / Full | Full | 5 |
| Transition Style | Classic / Simple | Classic | 5 |
| SFX Captions | On / Off | Off | 6 |

### Existing Settings (per ui-design.md and save-system.md)

| Setting | Values | Default |
|---------|--------|---------|
| Battle Speed | 1-6 | 3 |
| ATB Mode | Active / Wait | Active |
| Text Speed | Slow / Normal / Fast / Instant | Normal |
| Battle Cursor | Reset / Memory | Reset |
| Sound | Stereo / Mono | Stereo |
| Music Volume | 0-10 | 8 |
| SFX Volume | 0-10 | 8 |
| Window Color | RGB | (default navy) |
| Screen Shake | On / Off | On |
| Mode 7 Intensity | 1-6 | 6 |

### Key Config Sub-Screen

Keyboard rebinding is accessed via a dedicated **Key Config**
sub-screen from the Config menu -- not a simple toggle. It has its
own UI for mapping individual keys (see Section 4).
