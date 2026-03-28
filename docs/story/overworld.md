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
  miniaturized sprite (8x12 pixels per [visual-style.md](visual-style.md)).
  Location icons (towns, dungeons, landmarks) are miniaturized
  representations — not to scale. Entering a location triggers scale
  shift to full-size interior maps.
- **HDMA-style horizon gradient.** Terrain fades toward a sky color at
  the top of the viewport, creating atmospheric perspective. The
  gradient target color is derived from each biome's sky palette entry
  in [biomes.md](biomes.md) (e.g., Valdris highland sky, Carradan
  smog-filtered amber, Thornmere canopy-filtered green, Pallor
  featureless grey).
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
Encounter Zones section), not walking speed. This follows the SNES convention where
speed variation came from vehicles, not terrain.

- **Input:** 4-directional (D-pad cardinal directions). No diagonal
  movement on the overworld — per SNES Mode 7 convention where diagonal
  movement on a perspective-scaled tilemap creates visual artifacts.
  Interior maps use 8-directional movement (standard for non-Mode 7
  tiled maps).
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
  [geography.md](geography.md) Encounter Zones section for the full
  table (11 zone types; encounter-active zones range from Roads at 96
  increment to Pallor Wastes at 700; Sacred sites and Urban interior
  have 0 increment).
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

---

## 3. Screen Transitions

### Overworld → Location (Fade to Black)

When the party enters a location, the overworld's miniaturized scale
shifts to full-size interior maps via a fade transition:

1. Party sprite walks onto an entry trigger tile
2. Location name banner appears briefly (triggered at 3-tile approach
   radius per [geography.md](geography.md) Section 5)
3. Screen brightness ramps down (~0.5 seconds, 16 linear steps from
   full to black)
4. Interior map loads during the black screen
5. Brightness ramps back up; party appears at the location entrance
   at full-size scale

### Within-Location (Seamless)

Interior transitions use seamless movement to maintain spatial
continuity:

- Room-to-room and floor-to-floor transitions use edge-scrolling or
  door-walk-through — the player walks off one edge and the new area
  scrolls in
- No fade unless loading a substantially different tileset (e.g.,
  descending multiple dungeon floors at once)
- Per the Chrono Trigger / Secret of Mana model for interior continuity

### Battle Transitions

Battle transitions are visual-only — they do not encode tactical
information. Battle advantage (preemptive, normal, or back-attack) is
revealed when the battle screen loads, not during the transition.

- **Overworld encounters:** Mode 7 zoom-into-ground. The camera rapidly
  scales into the terrain, screen flash, cut to the battle screen. Per
  FF6's canonical overworld battle entry.
- **Dungeon/interior encounters:** Mosaic pixelation. The screen
  dissolves into progressively larger color blocks, then fades to
  black and cuts to the battle screen. Per FF6's dungeon model.
- **Boss encounters:** Distinct transition. Screen flash (brief white
  frame), hold, then a slower, more dramatic version of the
  context-appropriate transition (zoom on overworld, mosaic in
  dungeons). Signals narrative weight without encoding tactical
  information.
- **Post-battle return:** Fade from black back to the field. Danger
  counter resets to 0 (per [combat-formulas.md](combat-formulas.md)
  encounter system).

### Region Boundary Banners

Crossing a biome border triggers a brief text overlay with no gameplay
interruption:

- **Text banner:** "Entering the Thornmere Wilds," "Entering Carradan
  Compact Territory," etc. Appears over gameplay, fades after
  ~2 seconds.
- **Music crossfade:** 3-second transition — outgoing biome music fades
  from 100% to 0% over 1.5 seconds, incoming biome music fades from
  0% to 100% over 1.5 seconds. Crossfade begins at the transition's
  midpoint tile. Per [biomes.md](biomes.md) Music Crossfades section.
- **Pallor exception:** Music does not crossfade. It cuts to silence,
  then the Pallor's drone fades in over 5 seconds. The silence between
  is deliberate.
- **Ley Line Nexus exception:** The nexus hum blends additively with
  the surrounding biome's music rather than replacing it, creating a
  layered soundtrack.

---

## 4. Weather & Atmospheric Effects (FF6 Plus)

Location-fixed atmospheric visuals per biome, with story-triggered
overrides at act boundaries. No dynamic weather cycling. No day/night
gameplay cycle (no time-dependent NPCs, encounters, or mechanics).

> **Visual time-of-day:** [biomes.md](biomes.md) Time of Day Effects
> section defines cosmetic palette shifts for dawn/day/dusk/night per
> biome. These are
> programmatic color adjustments (tint overlays, not separate tilesets)
> that do not affect gameplay — no encounters, NPC availability, or
> mechanical systems change with time of day. This document references
> but does not own that visual system; biomes.md remains authoritative.

### Per-Biome Atmospherics (Fixed)

Each overworld-visible biome has a fixed atmospheric visual that defines
its identity. These do not cycle or change dynamically — they are the
biome's permanent character. Biomes that appear only as interior maps
or location entries (Underground/Cavern, Ancient Ruins) are not listed
here — see [biomes.md](biomes.md) for their visual definitions.
Ashlands (including Ashgrove) appears on the overworld as a small
transition zone but uses the Valdris-to-Ashlands gradient tiles; see
[biomes.md](biomes.md) for the full Ashlands palette. Sacred sites
(Ashgrove, Stillwater Hollow) use their parent biome's atmosphere with
zero encounter rate.

| Biome | Atmospheric Effect |
|-------|-------------------|
| Valdris Highlands | Gentle wind, drifting clouds, warm afternoon light |
| Carradan Industrial | Permanent smog layer, amber-filtered light, steam rising from grating |
| Thornmere Deep Forest | Spore/mote particles, no ground-level wind, canopy-filtered light |
| Thornmere Wetlands | Constant fog (visibility 4--5 tiles), will-o'-wisps, flat diffused light |
| Mountain / Alpine | Visible wind, blowing snow particles, whiteout conditions during storms |
| Coastal / Harbor | Haze, salt spray, stronger wind |
| Ley Line Nexus | Faint ambient glow, constant mote particles drifting upward, energy shimmer; amber variant at Sunstone Ridge (orange-red crystal glow) |
| Pallor Wastes | Grey ceiling, visual static at screen edges, muffled audio |

All effects use sprite-based particle overlays and palette manipulation,
consistent with SNES rendering techniques. Source:
[biomes.md](biomes.md).

### Story-Triggered Overrides

Story progression changes the overworld's atmospheric character at act
boundaries. Overrides **replace** the base atmospheric — they do not
layer on top.

| Trigger | Change | Areas Affected |
|---------|--------|----------------|
| Act II tensions | Ley-lamps flicker (1 in 4 dim or dark), muted gold accents, lingering clouds | Valdris Crown (capital city) |
| Interlude onset | Grey palette filter, muted colors globally | All biomes |
| Interlude winter | Blowing snow added, whiteout conditions | Highcairn route, alpine areas |
| Duskfen water rise | Fog turns grey, lower platforms submerged (~30% of settlement replaced with water tiles) | Duskfen (Thornmere Wetlands) |
| Pallor spread (Act III) | Progressive desaturation → monochrome | 10-mile radius from Convergence |
| Epilogue recovery | Pale blue sky, spring greens, lighter palette, wildflowers, new construction scaffolding | Valdris, Carradan, Convergence meadow |

Source: [dynamic-world.md](dynamic-world.md).

### Implementation Notes

- Biome transition strips (3--5 tiles per [biomes.md](biomes.md)) swap
  the particle/palette set at the midpoint — no two biome atmospherics
  need to blend simultaneously
- Palette manipulation for act progression uses color subtraction (SNES
  technique: subtracting a constant from all pixel values produces
  desaturation/darkening without per-tile palette swaps)
- The Pallor Wastes override is the most extreme: it replaces all biome
  visuals within its radius with the Stage 3 corruption tileset (per
  [biomes.md](biomes.md) Pallor Corruption Overlay System)
