# Overworld Traversal Mechanics

> Formalizes the mechanical layer of overworld traversal: presentation,
> passability rules, screen transitions, and weather. The *content* —
> biome definitions, encounter rates, named routes, location entries,
> story-driven world changes — is already defined across
> [geography.md](geography.md), [biomes.md](biomes.md),
> [dynamic-world.md](dynamic-world.md), and [locations.md](locations.md).
> This document owns the *rules* — how the player moves through and
> experiences the overworld.
>
> **Core philosophy: "FF6 Plus."** Faithful to SNES-era overworld
> conventions — uniform on-foot speed, location-fixed weather, Mode 7
> perspective, fade-to-black transitions, danger counter encounters —
> with targeted enhancements where PoD's richer world demands them
> (story-triggered weather overrides, conditional passability, per-act
> palette progression).
>
> **SNES-era reference:** FF6's Mode 7 overworld is the primary model.
> Supplemented by Chrono Trigger (seamless interior transitions),
> Earthbound (location-fixed environmental effects), and Breath of
> Fire 1 (character-ability-gated passability). See
> `docs/references/overworld-traversal-mechanics.md` for the full
> cross-game design reference.
>
> **Related docs:** [geography.md](geography.md) |
> [biomes.md](biomes.md) | [dynamic-world.md](dynamic-world.md) |
> [locations.md](locations.md) | [ui-design.md](ui-design.md) |
> [combat-formulas.md](combat-formulas.md) |
> [difficulty-balance.md](difficulty-balance.md)
>
> **Cross-links:** [dungeons-world.md](dungeons-world.md) |
> [dungeons-city.md](dungeons-city.md)

---

## 1. Overworld Presentation (Mode 7 Style)

The overworld uses a Mode 7-inspired perspective rendering. The player
controls a miniaturized party sprite walking across a single tilemap
that foreshortens toward a curved horizon — the signature look of FF6's
overworld.

### Visual Rules

- **Perspective tilemap.** Single tilemap rendered with perspective
  scaling: nearby tiles appear larger, distant tiles foreshorten toward
  a curved horizon. Per FF6's Mode 7 implementation.
- **Miniaturized sprites.** Party represented by lead character's
  miniaturized sprite (~16x16 pixels at base resolution, chibi scale).
  Location icons (towns, dungeons, landmarks) are miniaturized
  representations — not to scale. Entering a location triggers scale
  shift to full-size interior maps.
- **HDMA-style horizon gradient.** Terrain fades toward a sky color at
  the top of the viewport, creating atmospheric perspective. The
  gradient color shifts per biome (warm gold for Valdris, amber-grey
  for Carradan, green-dark for Thornmere, flat grey for Pallor Wastes).
- **Fixed camera.** Character-centered scrolling. No player-controlled
  zoom or camera rotation. Camera stops at map edges — ocean tiles fill
  the remaining viewport.
- **Biome palette tinting.** Global palette tint applied per biome
  region (Carradan amber smog, Thornmere green canopy filter, Pallor
  grey desaturation). See [biomes.md](biomes.md) for per-biome palette
  definitions.

### Map Screen (Menu-Accessed)

The pause menu provides a "Map" option that opens a full-continent
overview, replacing the removed zoom mechanic with a dedicated
navigation tool.

- **Style:** Static illustrated map with parchment aesthetic,
  consistent with SNES-era game manual fold-out maps
- **Location discovery:** Locations appear on the map after first visit,
  labeled with icons by type (town, dungeon, landmark, forge).
  Undiscovered areas show terrain but no location labels — the
  geography is known, specific sites are not
- **Current position:** Blinking dot marker shows the party's current
  overworld position
- **Named routes:** Dotted paths displayed between connected discovered
  locations (Valdris Highroad, Diplomatic Road, Wildwood Trail, etc.)
- **Non-interactive:** View-only. No fast travel, no cursor selection.
  Transport mechanics are deferred to Gap 3.1
- **Availability:** From Act I onward. No discoverable map item
  required — the party knows their homeland

---

## 2. Passability & Movement

### Movement

All passable overworld tiles share **uniform movement speed**. There are
no per-terrain speed modifiers — terrain affects encounter groups and
frequency (via the danger counter in [geography.md](geography.md)
Section 5), not walking speed. This follows the SNES convention where
speed variation came from vehicles, not terrain.

- **Input:** 4-directional (D-pad cardinal directions). No diagonal
  movement on the overworld — per SNES Mode 7 convention where diagonal
  movement on a perspective-scaled tilemap creates visual artifacts.
  Interior maps may support 8-directional movement.
- **Collision:** Full stop on impassable tiles. No wall-sliding. Per
  FF6 overworld behavior.
- **Speed tiers:** On-foot is the only speed tier in this document.
  Vehicle speed tiers (chocobo equivalent, rail cart, airship) are
  deferred to Gap 3.1 (Transport & Vehicle System).

### Passability Categories

Five tile categories govern overworld movement:

| Category | Behavior | Examples |
|----------|----------|---------|
| **Passable** | Walk freely; encounters per terrain zone | Grass, road, plains, desert, sand, coast |
| **Impassable** | Cannot cross on foot | Mountains, deep water, cliff faces, dense rock |
| **Entry trigger** | Fade to black, load interior map | Town icons, cave mouths, dungeon entrances |
| **Conditional** | Requires story flag or party member to pass | Dense Thornmere (Torren required), winter Highcairn (Interlude blocked), Pallor Wastes (Act III only) |
| **Event trigger** | Activates cutscene, save, or warp | Overworld save points, story trigger tiles, region boundary banners |

### Passability Rules

- **Encounter zones.** Each passable tile belongs to an encounter zone
  that determines danger counter increment and formation tables. See
  [geography.md](geography.md) Section 5 for the full encounter zone
  table (11 zone types from Roads at 96 increment to Pallor Wastes
  at 700).
- **Conditional tile messages.** When the player attempts to enter a
  conditional tile without meeting its requirement, a contextual
  message appears:
  - "The forest is too dense to navigate without a guide." — Torren
    absent in dense Thornmere
  - "The mountain pass is snowbound." — Highcairn route during
    Interlude
  - "A wall of grey static blocks the path." — Pallor Wastes before
    Act III
- **Vehicle-conditional tiles** (shallow water, rail tracks, airship
  landing zones) will be added as a sixth passability category when
  Gap 3.1 (Transport) is designed.
- **No damage floors on the overworld.** Per SNES convention,
  environmental hazards (sinkholes, steam vents, rising water) are
  interior/dungeon features, not overworld tiles. The overworld is
  traversal and encounter space only.
