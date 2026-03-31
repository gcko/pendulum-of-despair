# Overworld Traversal Mechanics

> Formalizes the mechanical layer of overworld traversal: presentation,
> passability rules, screen transitions, weather, structural tilemap
> changes, and save points. The *content* —
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
> [difficulty-balance.md](difficulty-balance.md) |
> [visual-style.md](visual-style.md) | [magic.md](magic.md) |
> [equipment.md](equipment.md) | [transport.md](transport.md)
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
- **HDMA-style horizon gradient.** Terrain fades toward a sky/atmosphere
  color at the top of the viewport, creating atmospheric perspective.
  The gradient target color is derived from each biome's palette in
  [biomes.md](biomes.md) — sky entries where available (e.g., Valdris
  `#88C8E8` highland sky), or dominant atmosphere color for canopy-
  covered biomes (e.g., Thornmere filtered light, Pallor grey).
- **Fixed camera.** Character-centered scrolling. No player-controlled
  zoom or camera rotation. Camera stops at map edges — ocean tiles fill
  the remaining viewport.
- **Biome palette tinting.** Global palette tint applied per biome
  region (Carradan amber smog, Thornmere green canopy filter, Pallor
  grey desaturation). See [biomes.md](biomes.md) for per-biome palette
  definitions.

**Reduce Motion alternative:** When "Reduce Motion" is enabled in Config,
Mode 7 intensity is set to minimum (level 1 of 6) — the overworld still
uses perspective view but with flattened foreshortening. The Mode 7
zoom-into-ground encounter transition is replaced with a 0.5s fade to
black. See [accessibility.md](accessibility.md) Section 5.

### Map Screen (Menu-Accessed) — Plus Enhancement

The pause menu provides a "Map" option that opens a full-continent
overview. This is a "Plus" addition — FF6 had no separate map screen
(the Mode 7 overworld was the map). PoD adds it for navigation
convenience on a larger, more complex continent.

- **Style:** Static illustrated map with parchment aesthetic,
  consistent with SNES-era game manual fold-out maps.
- **Location discovery:** Locations appear on the map after first visit
  (entering the location via fade-to-black, not merely approaching it).
  Labeled with icons by type (town, dungeon, landmark). Destroyed
  or modified locations use variant icons (see Section 5).
  Undiscovered areas show terrain but no location labels — the
  geography is known, specific sites are not. The 3-tile approach
  banner (Section 3) reveals the location name but does not trigger
  map discovery.
- **Current position:** Blinking dot marker shows the party's current
  overworld position.
- **Named routes:** Dotted paths displayed between connected discovered
  locations (Valdris Highroad, Diplomatic Road, Wildwood Trail, etc.).
- **Non-interactive:** View-only. No cursor selection, no fast travel
  from the map screen. Spell-based teleportation (Linewalk per
  [magic.md](magic.md)) and vehicle transport (rail, Ley Stag, ferry
  per [transport.md](transport.md)) exist as separate systems.
- **Availability:** From Act I onward. No discoverable map item
  required — the party knows their homeland.

---

## 2. Passability & Movement

### Movement

All passable overworld tiles share **uniform movement speed**. There are
no per-terrain speed modifiers — terrain affects encounter groups and
frequency (via the danger counter in [geography.md](geography.md)
Encounter Zones section), not walking speed. This follows the SNES convention where
speed variation came from vehicles, not terrain.

- **Input:** 4-directional (D-pad cardinal directions). No diagonal
  movement on the overworld — a deliberate PoD simplification for the
  Mode 7 perspective. (Note: FF6 allowed 8-directional on its Mode 7
  overworld; PoD restricts to 4-directional for tighter grid-based
  tile interaction.) Interior maps use 8-directional movement.
- **Collision:** Full stop on impassable tiles. No wall-sliding. Per
  FF6 overworld behavior.
- **Speed tiers:** On-foot is the only overworld speed tier in this
  document. The Ley Stag mount provides 2x speed; rail and ferry are
  menu-driven instant travel. No airship in PoD. See
  [transport.md](transport.md) for all vehicle mechanics.

### Passability Categories

Five tile categories govern overworld movement:

| Category | Behavior | Examples |
|----------|----------|---------|
| **Passable** | Walk freely; encounters per terrain zone | Grass, road, plains, quarried plains, sand, coast |
| **Impassable** | Cannot cross on foot | Mountains, deep water, cliff faces, dense rock |
| **Entry trigger** | Fade to black, load interior map | Town icons, cave mouths, dungeon entrances |
| **Conditional** | Requires story flag or party member to pass; full stop + message | Dense Thornmere (Torren required), winter Highcairn (Interlude blocked), Pallor Wastes (Act III only), Aelhart border road (Act II--Interlude blocked), Canopy Reach (Interlude blocked) |
| **Event trigger** | Activates cutscene, save, or warp | Overworld save points, story trigger tiles |

### Passability Rules

- **Encounter zones.** Each passable tile belongs to an encounter zone
  that determines danger counter increment and formation tables. See
  [geography.md](geography.md) Encounter Zones section for the full
  table (12 zone types; encounter-active zones range from Farmland at
  48 increment to Pallor Wastes at 700; Sacred sites and Urban interior
  have 0 increment). Spells and equipment can modify encounter rate
  (e.g., Veilstep x0.25 per [magic.md](magic.md), Ward Talisman x0.5
  per [equipment.md](equipment.md)); see
  [combat-formulas.md](combat-formulas.md) Encounter System for the
  full modifier table and stacking rules.
- **Conditional tile behavior.** Failing a conditional check produces
  the same full stop as impassable tiles, plus a contextual message:
  - "The forest is too dense to navigate without a guide." — Torren
    absent in dense Thornmere
  - "The mountain pass is snowbound." — Highcairn route during
    Interlude
  - "A wall of grey static blocks the path." — Pallor Wastes before
    Act III
  - "The road south is too dangerous." — Aelhart border road during
    Act II--Interlude
  - "The path to the canopy is blocked. The trees here are stone.
    The bridges are gone." — Canopy Reach during Interlude
- **Region boundary banners** are not event triggers — they are
  non-interrupting text overlays on passable tiles at biome borders.
  See Section 3 (Region Boundary Banners) for timing rules.
- **Vehicle passability.** PoD's transport systems are menu-driven
  (rail, ferry) or use existing passability with restrictions (Ley
  Stag per [transport.md](transport.md)). No sixth tile category
  needed. Rivers are impassable except at bridge tiles (named crossing
  points — see [transport.md](transport.md) Section 5).
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
   radius per [geography.md](geography.md) Camera Behavior section)
3. Screen brightness ramps down (~0.3 seconds per
   [ui-design.md](ui-design.md))
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
[ui-design.md](ui-design.md) defines the base mosaic dissolve; this
section extends it with context-dependent variants.

- **Overworld encounters:** Mode 7 zoom-into-ground. The camera rapidly
  scales into the terrain, screen flash, cut to the battle screen. Per
  FF6's canonical overworld battle entry.
- **Dungeon/interior encounters:** Mosaic pixelation. The screen
  dissolves into progressively larger color blocks until
  unrecognizable, then cuts to the battle screen. Per FF6's dungeon
  model and [ui-design.md](ui-design.md).
- **Boss encounters:** Distinct transition. Screen flash (brief white
  frame), hold, then a slower, more dramatic version of the
  context-appropriate transition (zoom on overworld, mosaic in
  dungeons). Signals narrative weight without encoding tactical
  information.
- **Post-battle return:** Reverse dissolve back to the field (per
  [ui-design.md](ui-design.md)). Danger counter resets to 0 (per
  [combat-formulas.md](combat-formulas.md) Encounter System). Boss
  battles with post-battle cutscenes or location changes (room
  destroyed, new area access) override the standard return — the
  cutscene or location transition plays instead of the reverse dissolve.

### Region Boundary Banners — Plus Enhancement

Crossing a biome border triggers a brief text overlay with no gameplay
interruption. This is a "Plus" addition — FF6 communicated region
changes through music and palette shifts alone, not text overlays.

- **Text banner:** "Entering the Thornmere Wilds," "Entering Carradan
  Compact Territory," etc. Appears over gameplay, fades after
  ~2 seconds. If a fade-to-black (location entry) begins while a
  banner is active, the fade immediately cancels the banner. Location
  name banners and region banners do not stack — if a location name
  banner triggers while a region banner is displaying, the region
  banner is immediately cancelled and replaced.
- **Music crossfade:** 3-second transition — outgoing biome music fades
  from 100% to 0% over 1.5 seconds, incoming biome music fades from
  0% to 100% over 1.5 seconds. Crossfade begins at the transition's
  midpoint tile. Per [biomes.md](biomes.md) Music Crossfades section
  (a Plus Enhancement — SNES used hard cuts).
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
transition zone (3-tile gradient per [biomes.md](biomes.md)); at the
transition midpoint, visual atmospheric swaps to Ashlands effects
(still air, player-disturbed ash particles per [biomes.md](biomes.md)
Ashlands section). Sacred sites
(Ashgrove, Stillwater Hollow) use their parent biome's atmosphere with
zero encounter rate.

| Biome | Atmospheric Effect |
|-------|-------------------|
| Valdris Highlands | Gentle wind, drifting clouds casting moving shadows, warm afternoon light |
| Carradan Industrial | Permanent smog layer, amber-filtered light (never truly bright) |
| Thornmere Deep Forest | Spore/mote particles, no ground-level wind, bioluminescent light from below |
| Thornmere Wetlands | Constant fog (visibility 4--5 tiles in places), will-o'-wisps, flat diffused light |
| Mountain / Alpine | Constant visible wind, blowing snow particles, reduced visibility at higher elevations |
| Coastal / Harbor | Haze, sea spray motes, stronger wind |
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
| Act II tensions | Ley-lamps flicker (1 in 4 dim), muted gold accents, lingering clouds | Valdris Crown (capital city) |
| Interlude onset | Grey palette filter, muted colors globally | All biomes |
| Interlude winter | Wind drops, oppressive silence, heavier frost patterns; Pallor manifestations blend with snow on Highland Descent route | Highcairn route, alpine areas |
| Duskfen water rise | Fog turns grey; structural tile changes in Section 5 | Duskfen (Thornmere Wetlands) |
| Pallor spread (Act III) | Progressive desaturation → monochrome | 10-mile radius from Convergence |
| Epilogue recovery | Pale blue sky, spring greens, lighter palette, wildflowers, new construction scaffolding | All outdoor areas (highlighted: Valdris, Carradan, Convergence meadow) |

Source: [dynamic-world.md](dynamic-world.md).

### Implementation Notes

- Biome transition strips (3--5 tiles per [biomes.md](biomes.md); Pallor
  transitions use 5+ tiles) swap
  the particle/palette set at the midpoint — no two biome visual
  atmospherics (particles, palette) need to blend simultaneously.
  Audio crossfades are handled separately (see Region Boundary
  Banners above; Ley Line Nexus uses additive audio blending)
- Palette manipulation for act progression uses color subtraction (SNES
  technique: subtracting a constant from all pixel values produces
  desaturation/darkening without per-tile palette swaps)
- The Pallor Wastes override is the most extreme: it replaces all biome
  visuals within its radius with the Stage 3 corruption tileset (per
  [biomes.md](biomes.md) Pallor Corruption Overlay System)

---

## 5. Structural Overworld Changes

The overworld tilemap is not static. Story progression causes structural
modifications that alter terrain, passability, and connectivity. These
go beyond the atmospheric/palette overrides in Section 4 — they replace
tiles and change where the player can walk.

Source: [dynamic-world.md](dynamic-world.md). The table below summarizes
the changes; dynamic-world.md contains the full mechanical details.

### Act-Based Tilemap Modifications

| Change | Trigger | Old → New Tiles | Passability Impact |
|--------|---------|-----------------|-------------------|
| **Valdris Crown wall breach** | End of Act II (`carradan_assault_begins`) | Intact wall tiles → rubble, debris slope, fire damage | New accessible area through eastern wall; permanent passage |
| **Millhaven crater** | Interlude (ley line eruption) | Complete town → crater scar, twisted metal, exposed ley lines | Town destroyed; overworld-visible crater, no interior map remains |
| **Three ley fissures** | Interlude (`ley_line_rupture`) | Grass/forest → fissure tiles with ley energy glow | Severs Valdris Highroad, blocks Compact southern routes, marks Convergence Ring (Act III boundary). Narrow bridge tiles at specific crossing points |
| **Thornmere canopy petrification** | Interlude (Pallor proximity) | Living canopy → grey stone, fallen rubble, sky-exposed ground | Some root passages blocked; new paths where petrified trees create bridges; biome shifts from enclosed to exposed |
| **Rail tunnel collapse** | Interlude (`ley_line_rupture`) | Straight tunnel sections → rubble at 3 collapse points, branching maze | Direct Ashmark--Corrund route eliminated; new branching tunnels with boring engine hazards |
| **Duskfen submersion** | Interlude (ley disruption) | Lower platform tiles → water tiles (~30% of settlement) | Lower platforms impassable; rope bridges cut; new makeshift plank bridges in different locations |
| **Pallor Wastes formation** | Progressive during Interlude; fully formed by Act III | Biome tiles within 10-mile radius → Stage 3 corruption tileset (ley line clearings retain pre-corruption color as save points) | New encounter zone (increment 700). Before Act III: conditional passability block (see Section 2). After Act III onset: passable Wastes terrain |
| **Epilogue healing** | Post-Convergence | Fissures close (dark scar tiles remain), rubble cleared, scaffolding appears, Convergence meadow replaces plateau | Routes reopen; locations show repair; Convergence becomes meadow with memorial |

### Map Screen Updates

The map screen (Section 1) reflects structural changes:

- **Severed routes** show as broken dotted paths during Interlude/Act III
- **Destroyed locations** (Millhaven) change icon from town to crater marker
- **New crossing points** (fissure bridges) appear as route connections
  when discovered
- **Restored routes** (Epilogue) return to solid dotted paths

### Passability Category Interaction

Structural changes interact with the passability system (Section 2):

- **Fissure tiles** are impassable except at designated bridge crossings
  (entry trigger tiles at the bridges)
- **Crater tiles** are impassable — Millhaven has no entry trigger after
  destruction (overworld approach only, per
  [dynamic-world.md](dynamic-world.md))
- **Submersion tiles** (Duskfen water) are impassable on the overworld;
  Duskfen's interior map handles the flooded navigation
- **Petrified/rubble tiles** vary: some block old paths (impassable),
  others create new paths (passable where fallen trees bridge gaps)
- Most structural changes permanently replace tile passability states
  via story flags (not conditional tiles). Exception: the Pallor
  Wastes boundary uses conditional passability before Act III (see
  Section 2) and becomes permanent Wastes terrain after Act III onset

---

## 6. Save Points

### Overworld Save Points

Save points are event trigger tiles that open the save/rest menu. On the
overworld, they appear at two types of locations:

- **Named rest sites.** Camps near dungeon entrances, inn exteriors,
  and designated waypoints along major routes. These are fixed
  locations that do not move across acts. They use the safe zone
  encounter rate (0 increment — no encounters). Note: sacred sites
  (Ashgrove, Stillwater Hollow) provide passive HP/MP recovery per
  [geography.md](geography.md) but are not necessarily save points —
  save point placement is an implementation decision.
- **Ley line clearings (Pallor Wastes only).** In Act III, faint ley
  line clearings where the ground still pulses with color serve as the
  only save points in the Wastes. When the party rests at a clearing,
  time-of-day snaps to its natural state and color briefly returns —
  then grey resumes when they leave. Per
  [dynamic-world.md](dynamic-world.md).

### Visual Representation

- **Standard save points:** A ley crystal marker — a small glowing
  crystal embedded in the ground, visible on the miniaturized overworld
  as a faint point of light. Consistent with ley crystal imagery used
  throughout the game (Ley Crystal equipment slot, ley line network).
- **Pallor Wastes clearings:** No crystal marker. The clearing itself
  is the visual — a small patch of surviving color (grass green, earth
  brown) amid the grey. The contrast is the indicator.
- **Dungeon save points** use the same ley crystal visual at larger
  scale on interior maps. The Ley Line Depths has unique variants
  (crystals embedded in walls, the Nexus crystal with full-restore
  properties per [dungeons-world.md](dungeons-world.md)).

### Save Point Rules

- **Rest mechanics.** Save points present a 3-option menu: Rest,
  Rest & Save, Save (see [save-system.md](save-system.md)). Resting
  consumes a rest item — Sleeping Bag (25% HP/MP/AC), Tent (50%),
  or Pavilion (100%) — and clears all status ailments. Without a
  rest item, a free fallback restores 25% MP only (no HP, no AC, no
  status clear). Inns provide full restore for gold (varies by town,
  see [economy.md](economy.md)). AC restoration via rest items is the
  primary recovery mechanic for pre-dungeon device crafting.
- **Device reconfiguration.** Lira can re-craft devices at save points
  with available materials and AC (per [crafting.md](crafting.md)).
- **No encounters.** Save point tiles use the Sacred sites encounter
  zone (0 increment). The immediate area around the save point is safe.
- **Persistence across acts.** Named rest sites persist through all
  acts. Pallor Wastes clearings exist only in Act III. If a save point
  is in an area that becomes structurally modified (Section 5), it
  remains accessible if the tile itself is not replaced.
- **Linewalk interaction.** The Linewalk spell (per
  [magic.md](magic.md)) teleports to previously visited *towns*, not
  save points. Save points and Linewalk are separate systems — save
  points provide rest/save, Linewalk provides fast travel to
  settlements.

---

## Appendix: Implementation Notes

Decisions deferred to the implementation phase. These require
prototyping and tuning, not design specification.

### Rendering

- **Mode 7 perspective parameters** (viewing angle, horizon line
  position, near/far scale factors) — tune during visual prototyping.
  Reference: FF6's Mode 7 registers use affine transformation with
  per-scanline scaling. Target: ground visible in the bottom ~70% of
  the viewport, sky/horizon in the top ~30%.
- **Movement speed value** — tune for feel. Target: ~2 tiles/second at
  base resolution (comfortable walking pace on a 16x14 viewport). The
  spec mandates uniform speed; the specific value is a tuning knob.
- **Z-ordering** — suggested layer order (back to front): tilemap →
  HDMA horizon gradient → location icons → party sprite → cloud/fog
  layer (semi-transparent dithering — must not obscure party sprite)
  → atmospheric particles → UI overlays (banners, map screen).
- **Map wrapping** — hard edges, no wrapping. Camera stops at map
  edges; ocean tiles fill the remaining viewport (per Section 1).
  Unlike FF6, PoD's continent does not wrap.

### Input & Collision

- **Simultaneous directional input** — if two cardinal directions are
  pressed simultaneously, use most-recently-pressed priority (standard
  D-pad behavior).
- **Conditional tile check timing** — on attempted movement (player
  presses direction toward conditional tile; game checks flag; if
  failed, full stop + message). Not proximity-based.
- **Entry trigger activation** — automatic on step (walk onto the tile,
  transition begins). No confirm button needed. Per FF6 convention.

### Transitions

- **Boss battle transition duration** — standard transition is ~0.5
  seconds. Boss variant: ~1.0 seconds (2x standard). White flash
  frame: 3 frames at 60fps.
- **Map screen transition** — instant open/close (no fade or slide).
  Per SNES menu convention.
- **Region banner visual style** — same system as location name flash
  per [ui-design.md](ui-design.md): pixel font, white text, dark navy
  background inset tag.
- **Story override transition** — atmospheric palette overrides
  (Section 4) are instant at act boundary (triggered by story flag).
  Structural tilemap changes (Section 5) use their own timing — some
  are instant at flag (wall breach, fissures), others are progressive
  across the Interlude (Pallor spread, canopy petrification).

### Particles & Visual

- **Particle density** — tune per biome during visual prototyping.
  Starting targets: 8--12 particles on screen for light effects
  (Valdris clouds, Thornmere spores), 20--30 for heavy effects
  (Pallor static, alpine snow).
- **Particle scrolling** — world-relative (scroll with camera), not
  screen-fixed. Exception: Pallor Wastes edge static is screen-fixed
  (a HUD-layer effect).
