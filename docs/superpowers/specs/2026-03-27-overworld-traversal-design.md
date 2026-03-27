# Overworld Traversal Mechanics — Design Spec

**Gap:** 3.2 Overworld Traversal Mechanics
**Status:** Approved design, ready for implementation
**Date:** 2026-03-27
**Depends On:** None (foundational)
**Unblocks:** 3.1 (Transport & Vehicle System — vehicle-conditional tiles added there)

---

## Overview

Formalizes the overworld traversal mechanical layer: passability rules,
screen transitions, Mode 7-style presentation, and weather formalization.
The *content* (biome definitions, encounter rates, named routes, location
entries, story-driven world changes) is already defined across
geography.md, biomes.md, dynamic-world.md, and locations.md. This spec
covers the *rules* — how the player moves through and experiences the
overworld.

**Core philosophy: "FF6 Plus."** Faithful to SNES-era overworld
conventions — uniform on-foot speed, location-fixed weather, Mode 7
perspective, fade-to-black transitions, danger counter encounters — with
targeted enhancements where PoD's richer world demands them (story-
triggered weather overrides, conditional passability, per-act palette
progression).

**SNES-era reference:** FF6's Mode 7 overworld is the primary model.
Supplemented by Chrono Trigger (seamless interior transitions), Earthbound
(location-fixed environmental effects), and Breath of Fire 1 (character-
ability-gated passability — Bo walks through forests, Gobi swims oceans).
See `docs/references/overworld-traversal-mechanics.md` for the full
cross-game design reference.

**Key design decision: uniform movement speed.** Per the SNES reference
document, most SNES JRPGs used uniform on-foot movement speed regardless
of terrain type. Terrain's role was to gate passability, determine
encounter groups, and modify encounter frequency — not to modulate
walking speed. Speed variation came from vehicles (deferred to Gap 3.1).
Geography.md's current per-terrain speed modifiers (100%/90%/85%/80%/
75%/70%/60% — seven distinct tiers) are removed.

**Key design decision: no overworld zoom.** No SNES JRPG implemented
player-controlled overworld zoom. Geography.md's current two-level zoom
mechanic (with encounter suppression) is removed. Navigation is served
by a menu-accessed map screen instead.

---

## Section 1: Document Scope & Consolidation

Gap 3.2 creates `docs/story/overworld.md` — the canonical overworld
traversal mechanics document. It consolidates traversal rules into one
reference.

**Owns:**
- Overworld presentation rules (Mode 7 style, miniaturized sprites)
- Passability categories (5 types)
- Screen transition rules (exploration + battle)
- Weather formalization (FF6 Plus model)
- Map screen specification
- Uniform movement speed rule

**References (does not duplicate):**
- Biome definitions, visual palettes, transition gradients → biomes.md
- Encounter rates, danger counter, terrain zones → geography.md (Section: Terrain Effects), difficulty-balance.md
- Named routes, terrain descriptions, region layout → geography.md
- Location entries, accessibility per act → locations.md
- Story-driven world changes, act palette progression → dynamic-world.md
- Forge locations → locations.md
- Transport and vehicles → deferred to Gap 3.1

**Cross-links:**
- Battle system (transition triggers) → combat-formulas.md
- UI (map screen, region banners) → ui-design.md
- Dungeon traversal → dungeons-world.md, dungeons-city.md

---

## Section 2: Overworld Presentation (Mode 7 Style)

The overworld uses a Mode 7-inspired perspective rendering.

### Visual Rules

- Single tilemap rendered with perspective scaling: nearby tiles appear
  larger, distant tiles foreshorten toward a curved horizon
- Party represented by lead character's miniaturized sprite (~16x16
  pixels at base resolution, chibi scale)
- Location icons are miniaturized representations (towns, dungeons,
  landmarks) — not to scale
- HDMA-style horizon gradient: terrain fades toward a sky color at
  the top of the viewport, creating atmospheric perspective
- Fixed perspective, character-centered scrolling — no player-controlled
  zoom or camera rotation
- Biome-specific palette tinting applied globally (Carradan amber smog,
  Thornmere green canopy filter, Pallor grey desaturation)

### Map Screen (Menu-Accessed)

- Pause menu → "Map" option opens a full-continent overview
- Static illustrated map (parchment style, hand-drawn aesthetic
  consistent with SNES-era game manuals)
- Labels discovered locations with icons by type (town, dungeon,
  landmark, forge) — locations appear on the map after first visit
- Undiscovered areas show terrain but no location labels (no fog of
  war — the geography is known, specific sites are not)
- Shows current party position marker (blinking dot)
- Named routes displayed as dotted paths between connected locations
- Non-interactive: view-only, no fast travel (transport is Gap 3.1)
- Available from Act I onward — no discoverable map item required
  (the party knows their homeland)

---

## Section 3: Passability Rules

Five tile categories govern overworld movement.

### Passability Categories

| Category | Behavior | Examples |
|----------|----------|---------|
| Passable | Walk freely, encounters per terrain zone | Grass, road, plains, desert, sand, coast |
| Impassable | Cannot cross on foot | Mountains, deep water, cliff faces, dense rock |
| Entry trigger | Fade to black, load interior map | Town icons, cave mouths, dungeon entrances |
| Conditional | Requires story flag or party member | Dense Thornmere (Torren required), winter Highcairn (Interlude blocked), Pallor Wastes (Act III only) |
| Event trigger | Activates cutscene, save, or warp | Overworld save points, story trigger tiles, region boundary banners |

### Movement

- **Uniform on-foot speed** across all passable tiles. The base speed
  value is implementation-defined (target: visually comfortable traversal
  of the Mode 7 overworld — per SNES convention, ~2 tiles/second at
  base resolution). Concrete pixels-per-frame tuning happens during
  implementation, not design.
- **4-directional input** (D-pad cardinal directions). No diagonal
  movement on the overworld — per SNES Mode 7 convention where
  diagonal movement on a perspective-scaled tilemap creates visual
  artifacts. (Interior maps may support 8-directional movement.)
- **Collision response:** Full stop on impassable tiles. No wall-sliding.
  Per FF6 overworld behavior.

### Rules

- All passable tiles share uniform movement speed — no terrain speed
  modifiers. Terrain type determines encounter zone (mapped to danger
  counter increments per geography.md), not movement behavior.
- Conditional tiles display a contextual message when blocked:
  - "The forest is too dense to navigate without a guide." (Torren
    absent in dense Thornmere)
  - "The mountain pass is snowbound." (Highcairn during Interlude)
  - "A wall of grey static blocks the path." (Pallor Wastes before
    Act III)
- **Vehicle-conditional tiles** (shallow water, rail tracks, airship
  landing zones) are deferred to Gap 3.1 — added as a sixth category
  when transport is designed.
- **No damage-floor tiles on the overworld.** Per SNES convention,
  environmental hazards (sinkholes, steam vents, rising water) are
  interior/dungeon features, not overworld tiles. The overworld is
  traversal and encounter space only.

---

## Section 4: Screen Transitions

Two transition systems, context-dependent.

### Overworld → Location (Fade to Black)

1. Party sprite walks onto entry trigger tile
2. Location name banner appears briefly (already triggered at 3-tile
   radius per geography.md)
3. Screen brightness ramps down (~0.5 seconds, 16 linear steps)
4. Interior map loads during black screen
5. Brightness ramps back up; party appears at location entrance at
   full-size scale

### Within-Location (Seamless)

- Room-to-room, floor-to-floor transitions use edge-scrolling or
  door-walk-through
- No fade unless loading a substantially different tileset (e.g.,
  descending multiple dungeon floors)
- Maintains spatial continuity within a location
- Per Chrono Trigger / Secret of Mana model for interior continuity

### Battle Transitions

- **Overworld encounters:** Mode 7 zoom-into-ground — camera rapidly
  scales into the terrain, flash, cut to battle screen. Per FF6's
  canonical overworld battle entry.
- **Dungeon/interior encounters:** Mosaic pixelation — screen dissolves
  into progressively larger color blocks, fade to black, cut to battle
  screen. Per FF6's dungeon model.
- **Boss encounters:** Distinct transition — screen flash (brief white
  frame), hold, then a slower, more dramatic version of the context-
  appropriate transition (zoom or mosaic). Signals narrative weight
  without encoding tactical information.
- **Post-battle return:** Fade from black back to field. Danger counter
  resets to 0 per geography.md's encounter system.
- **No information encoding.** Transition type does not vary by battle
  advantage (preemptive/normal/ambush). Advantage is revealed on the
  battle screen, not during the transition.

### Region Boundary Banners

- Crossing a biome border triggers a brief text overlay ("Entering the
  Thornmere Wilds," "Entering Carradan Compact Territory")
- No fade or gameplay interruption — banner appears over gameplay,
  fades after ~2 seconds
- Music crossfade per biomes.md rules (3-second transition with
  1.5-second fade-out/fade-in)
- Pallor exception: music cuts to silence, then drone fades in over
  5 seconds (deliberate silence between — per biomes.md)
- Ley Line Nexus exception: hum blends additively rather than
  replacing surrounding biome music (per biomes.md)

---

## Section 5: Weather & Atmospheric Effects (FF6 Plus)

Location-fixed atmospheric visuals per biome, with story-triggered
overrides at act boundaries. No dynamic weather cycling. No day/night
gameplay cycle (no time-dependent NPCs, encounters, or mechanics).

> **Note:** biomes.md defines visual time-of-day palette shifts (dawn/
> day/dusk/night) per biome as a rendering detail. These are cosmetic
> palette tints — they do not affect gameplay, encounter rates, NPC
> availability, or any mechanical system. The overworld doc references
> but does not own this visual system; biomes.md remains authoritative
> for time-of-day rendering.

### Per-Biome Atmospherics (Fixed)

| Biome | Atmospheric Effect |
|-------|-------------------|
| Valdris Highlands | Gentle wind, drifting clouds, warm afternoon light |
| Carradan Industrial | Permanent smog layer, amber-filtered light, steam from grating |
| Thornmere Deep Forest | Spore/mote particles, no ground-level wind, canopy-filtered light |
| Thornmere Wetlands | Constant fog (visibility 4-5 tiles), will-o'-wisps, flat diffused light |
| Mountain/Alpine | Visible wind, blowing snow particles, whiteout during storms |
| Coastal/Harbor | Haze, salt spray, stronger wind |
| Sunstone Ridge | Orange-red crystal glow, natural light from crystals |
| Sacred Sites | Clear, calm, faint ley shimmer |
| Pallor Wastes | Grey ceiling, visual static at screen edges, muffled audio |

All effects use sprite-based particle overlays and palette manipulation,
consistent with SNES rendering techniques. Source: biomes.md.

### Story-Triggered Overrides

| Trigger | Change | Biomes Affected |
|---------|--------|----------------|
| Act II tensions | Flickering ley-lamps (1 in 4 dim), muted gold accents, lingering clouds | Valdris Crown (capital city) |
| Interlude onset | Grey palette filter, muted colors globally | All biomes |
| Interlude winter | Blowing snow added, whiteout conditions | Highcairn route, alpine areas |
| Duskfen water rise | Fog turns grey, lower platforms submerged (~30% of settlement replaced with water tiles) | Duskfen (Thornmere Wetlands) |
| Pallor spread (Act III) | Progressive desaturation → monochrome | Fixed 10-mile radius from Convergence |
| Epilogue recovery | Pale blue sky, spring greens, lighter palette, wildflowers, new construction scaffolding | Valdris, Carradan, Convergence meadow |

Source: dynamic-world.md.

### Implementation Notes

- Story overrides **replace** the base atmospheric, they do not layer
  on top
- Biome transition strips (3-5 tiles per biomes.md) swap the
  particle/palette set at the midpoint — no two biome atmospherics
  need to blend simultaneously
- Palette manipulation for act progression uses color subtraction
  (SNES technique: subtracting a constant from all pixel values
  produces desaturation/darkening without per-tile palette swaps)

---

## Section 6: Design Changes to Existing Docs

These changes must be applied to the source docs during implementation:

1. **geography.md:** Remove per-terrain speed modifiers (100%/90%/85%/
   80%/75%/70%/60% — seven tiers across ~12 terrain entries). Replace
   with a note that all overworld tiles use uniform movement speed
   (see overworld.md). Terrain sections retain encounter rate data,
   formation types, and passability descriptions. Also remove the
   travel time note at line 672 that references "terrain modifiers."
2. **geography.md:** Remove overworld zoom mechanic (two-level zoom
   with encounter suppression). Replace with a cross-reference to
   overworld.md's menu-accessed map screen.
3. **geography.md:** Add `overworld.md` to the related docs section.

---

## What This Does NOT Cover

- **Transport and vehicles** (rail system, fast travel, mounts, boats,
  airship equivalent) — deferred to Gap 3.1
- **Encounter rate values and danger counter mechanics** — defined in
  geography.md (terrain effects section) and difficulty-balance.md
- **Biome definitions and visual palettes** — already complete in
  biomes.md
- **Time-of-day visual palette shifts** — already defined in biomes.md
  (cosmetic rendering, no gameplay effect)
- **Named routes and regional geography** — already complete in
  geography.md
- **Location entries and accessibility rules** — already complete in
  locations.md
- **Story-driven world state changes** — already complete in
  dynamic-world.md
- **Dungeon interior traversal** — already complete in dungeons-world.md
  and dungeons-city.md
