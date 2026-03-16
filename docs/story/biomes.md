# Biomes -- Pendulum of Despair

This document defines the biome system: visual palettes, tilesets, atmosphere, and environmental storytelling for every region the player traverses. Each biome is a constrained SNES-era color palette designed to communicate emotional tone before a single line of dialogue appears. When the player crosses from Valdris green into Pallor grey, they feel the shift in their gut. That is the job of the biome system.

All palettes use 8-12 hex colors per biome. These are not exhaustive sprite palettes -- they are the dominant tones a pixel artist uses to establish the biome's identity. Individual sprites and tiles may introduce additional accent colors, but the biome palette defines the emotional range.

---

## Table of Contents

1. [Biome Definitions](#biome-definitions)
   - [Valdris Highlands](#1-valdris-highlands)
   - [Carradan Industrial](#2-carradan-industrial)
   - [Thornmere Deep Forest](#3-thornmere-deep-forest)
   - [Thornmere Wetlands](#4-thornmere-wetlands)
   - [Mountain / Alpine](#5-mountain--alpine)
   - [Ley Line Nexus](#6-ley-line-nexus)
   - [Coastal / Harbor](#7-coastal--harbor)
   - [Underground / Cavern](#8-underground--cavern)
   - [Ancient Ruins](#9-ancient-ruins)
   - [Ashlands](#10-ashlands)
   - [The Pallor Wastes](#11-the-pallor-wastes)
2. [Biome Transitions](#biome-transitions)
3. [Environmental Storytelling](#environmental-storytelling)
4. [Time of Day Effects](#time-of-day-effects)
5. [Pallor Corruption Overlay System](#pallor-corruption-overlay-system)

---

## Biome Definitions

### 1. Valdris Highlands

**Description:** Temperate rolling hills, green meadows, old-growth deciduous forest, and pale limestone architecture. This is home. The player begins here, returns here, and watches it fall apart. The Valdris palette is deliberately the warmest, most comfortable palette in the game -- so that its loss during the Interlude hits harder.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Ground (light) | `#7DBE6E` | Bright grass, healthy meadow |
| Ground (mid) | `#4E8A3F` | Standard grass, hillsides |
| Ground (dark) | `#2D5A28` | Grass shadows, treeline base |
| Stone (light) | `#D6CDB8` | Pale limestone, castle walls in sun |
| Stone (dark) | `#8A7F6E` | Stone shadow, old walls, foundations |
| Foliage | `#3B7A2E` | Deciduous tree canopy |
| Water | `#4A8CB8` | Rivers, well water, fountain basins |
| Sky | `#88C8E8` | Clear highland sky |
| Wood | `#8B6B42` | Timber frames, thatch support, carts |
| Accent (gold) | `#D4A832` | Ley-lamp glow, royal banners, trim |
| Shadow | `#2A3828` | Deep shadow under trees, gate arches |
| Path | `#B8A882` | Dirt roads, worn stone paths |

**Tileset Direction:**
- Grass tiles: healthy green (3 variants for visual noise), tall grass, wildflower patches, clover
- Stone tiles: limestone wall (light/shadow), cobblestone road, flagstone floor, crumbling wall variant, mossy wall
- Architecture: arched doorways, peaked roofs with slate tiles, tower segments (cylindrical, for the Seven Towers), covered stone walkways, wooden shuttered windows
- Water: clear river tiles (flowing animation, 3 frames), pond/still water, fountain basin
- Vegetation: deciduous trees (round canopy, 2-3 sizes), hedge rows, farmland (wheat, fallow), orchard trees
- Props: market stalls, barrels, crates, well (functional and dry variants), ley-lamps (glowing and dim), banners, hitching posts
- Terrain: rolling hill contours (2-tile height variation), cliff edges, plateau rim

**Weather/Atmosphere:**
- Default: Gentle wind, drifting clouds casting moving shadows. Warm afternoon light.
- Occasional: Light rain with puddle reflections. No storms -- Valdris weather is stable, old, settled.
- Act II shift: The wind picks up. Clouds linger longer. Ley-lamps flicker intermittently.
- Interlude: Overcast. The warmth is gone. A constant grey filter mutes the greens.

**Sound Palette:**
- Wind through grass and leaves (soft, constant)
- Birdsong (varied, several species -- silence in Act II signals decay)
- Distant church bells or tower chimes (Valdris Crown)
- Running water (streams, fountains)
- Footsteps on stone and grass (alternating by terrain)
- Market chatter (towns only, fading in Act II)

**Encounter Feel:**
- Wolves, wild boar, ley-corrupted wildlife (animals with faint blue-white sparks in their fur)
- Bandits in leather and iron (human, desperate)
- By Act II: Compact scouts in brass-and-iron armor, moving in disciplined squads
- By Interlude: Pallor manifestations -- hollow grey shapes that were once wildlife

**Locations Using This Biome:**
- Aelhart (farming village variant -- more wheat fields, fewer stone structures)
- Valdris Crown (urban variant -- dense limestone architecture, market plazas, the Seven Towers)
- Thornwatch (military variant -- palisade walls, watchtower, forest edge)
- Greyvale (ruined variant -- scorched stone, exhausted quarries, desaturated palette)
- Overworld routes: Aelhart to Thornwatch (Valdris Highroad), Highcairn to Valdris Crown (Highland Descent lower section)

---

### 2. Carradan Industrial

**Description:** Brick, iron, smog, and amber forge-light. The Carradan Compact builds upward and outward without restraint. Every surface is functional. Beauty, where it exists, is accidental -- the way firelight catches on polished brass, or the geometric pattern of factory windows at dusk. The palette is warm but oppressive: oranges, browns, and greys that press inward.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Brick (light) | `#A86B4E` | Sunlit factory walls, newer construction |
| Brick (dark) | `#6B3E2A` | Soot-stained walls, old foundries |
| Iron | `#5A5A62` | Structural beams, rail tracks, machinery |
| Brass | `#C49840` | Pipes, fittings, Forgewright accents |
| Forge glow | `#E88830` | Furnace light, Arcanite processing, windows |
| Smoke/sky | `#7A7068` | Permanent smog layer, overcast |
| Ground | `#4A4038` | Scorched earth, coal dust, blackite plain |
| Soot | `#2E2824` | Deepest shadow, chimney residue |
| Water (canal) | `#5A6858` | Polluted canals, coolant runoff |
| Arcanite glow | `#82B8D4` | Ley energy in machinery, pale blue-white |
| Rust | `#8A4A2E` | Corroded metal, neglected infrastructure |
| Steam | `#C8C0B0` | Vents, exhaust, fog at ground level |

**Tileset Direction:**
- Ground tiles: scorched rock (blackite), coal-dust earth, metal grating, brick floor, rail bed with ties
- Wall tiles: brick (clean, soot-stained, crumbling), corrugated iron, riveted steel plate, glass-paned factory windows
- Architecture: chimney stacks (multiple heights), factory roofs (sawtooth profile), arched bridges (iron), canal walls, tenement stacks (Undercroft), gear housings, pipe clusters
- Machinery: gears (static and animated rotating), pistons, conveyor segments, pressure valves, Arcanite engine housings (glowing core), steam vents (animated)
- Water: polluted canal (dark, slow-moving, oily surface shimmer), coolant pools
- Rail: track tiles (straight, curved, switch), rail cart (static and moving), platform edge
- Props: crates (stamped with Compact insignia), barrels (oil, chemicals), street lamps (Arcanite-powered, harsh white), market stalls (iron frame), loading cranes
- Vertical: scaffolding tiles, elevator shafts, stairways (metal), ladder rungs

**Weather/Atmosphere:**
- Default: Permanent smog layer. Light is amber-filtered, never truly bright. The sky is always some shade of grey-orange.
- Factory districts: Steam rises from grating. Machinery hums constantly. Occasional sparks from welding or grinding.
- Interior: Forge-glow provides warm orange light. Shadows are deep and sharp. The temperature feels high.
- Interlude shift: The smog thins in places (factories shutting down) but the Arcanite glow turns sickly -- blue-white shifting toward grey.

**Sound Palette:**
- Machinery (constant: rhythmic clanging, hissing steam, grinding gears)
- Distant furnace roar (a low, omnipresent rumble)
- Metal footsteps on grating
- Canal water (sluggish, lapping)
- Compact announcements (muffled public address horns in Corrund)
- Silence is wrong here -- when the machines stop, something is broken

**Encounter Feel:**
- Compact soldiers (disciplined, brass-armored, fighting in formation)
- Malfunctioning Forgewright constructs (automatons, boring machines, rail sentries)
- Forge-smoke creatures (elementals born from pollution -- living soot, ember swarms)
- By Interlude: Machines running on Pallor energy -- same shapes, but grey-lit and wrong

**Locations Using This Biome:**
- Corrund (capital variant -- canals, the Axis Tower, dense vertical architecture, Undercroft sub-variant with darker palette)
- Ashmark (heavy industrial variant -- the Black Forges, permanent soot, denser smoke)
- Caldera (volcanic basin variant -- tiered factory bowl, deeper reds and oranges, the central smelting complex)
- Ashport (coastal industrial variant -- blends with Coastal biome at the harbor)
- Ironmark Citadel (military-industrial variant -- Arcanite-bonded iron walls, grey-blue Pallor glow during Interlude)
- Ironmouth (frontier industrial variant -- prefab metal buildings, small scale, encroaching on forest)
- Millhaven (extraction variant -- open pit, pumping stations, the Millglow)
- Carradan Rail Tunnels (tunnel variant -- iron-braced stone, Arcanite lamps, rail infrastructure)

---

### 3. Thornmere Deep Forest

**Description:** Ancient canopy so dense the ground never sees direct sun. Bioluminescent moss and fungi provide the only constant light. The palette is heavy greens and deep purples, with points of cyan and teal luminescence. This biome feels alive in a way neither Valdris nor the Compact can touch -- the forest breathes, watches, and remembers. Think the Phantom Forest in FF6, but scaled to an entire biome.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Canopy (light) | `#2E6B3A` | Upper canopy where filtered light reaches |
| Canopy (dark) | `#1A3E22` | Dense canopy shadow, forest ceiling |
| Trunk | `#4A3A2E` | Ancient tree bark, root walls |
| Ground | `#2A3A28` | Forest floor, leaf litter, root mat |
| Moss | `#5A8A48` | Living moss on stone and wood |
| Bioluminescence | `#68D8B8` | Glowing moss, fungi, spirit-traces |
| Spirit glow | `#B088D8` | Spirit-totem light, ley energy near surface |
| Water (dark) | `#2A4A48` | Still pools, root-filtered streams |
| Heartwood | `#6B4A30` | Carved wood, totem material, living architecture |
| Deep shadow | `#0E1A12` | Absolute dark between roots, cave-like |
| Flower accent | `#D868A8` | Rare forest flowers, medicinal plants |
| Filtered light | `#A8C878` | Shafts of green-gold where canopy breaks |

**Tileset Direction:**
- Ground tiles: root-matted earth, leaf litter (3 variants), mossy stone, exposed root paths, mushroom clusters
- Tree tiles: massive trunk segments (4+ tiles wide), root archways (walkable beneath), branch platforms, hollow trunk interiors, bark texture walls
- Vegetation: fern beds, hanging vines, luminescent mushroom patches (animated glow pulse), spirit moss (glowing), canopy layers (parallax, 2-3 depths)
- Architecture (organic): root-chambers (Roothollow -- carved root walls, natural archways), vine bridges, woven reed platforms (Duskfen transition), heartwood shrines, spirit-totem poles
- Water: dark still pools (reflecting bioluminescence), root-filtered streams, underground spring seeps
- Light sources: bioluminescent moss patches (soft teal glow radius), spirit-totems (purple glow), filtered light shafts (rare, golden-green), will-o'-wisp points (flickering)
- Props: herb baskets, carved wood bowls, hanging spirit-wards, sleeping pallets (woven reed), ceremonial stones

**Weather/Atmosphere:**
- Default: No wind at ground level -- the canopy absorbs everything. The air is thick, humid, still. Light comes from below (bioluminescence) and from rare canopy breaks.
- Constant: Particles drifting -- spores, motes of light, tiny insects. The forest floor is never truly still.
- Deep areas: Near-total darkness with pinpoints of cyan and purple light. The silence is heavy and intentional.
- Storm: Rain never reaches the ground. The canopy roars above. Water drips through in delayed streams, filling pools.

**Sound Palette:**
- Insect chorus (layered, pulsing, changes pitch by depth)
- Dripping water (irregular, echoing in root chambers)
- Creaking wood (slow, deep -- the trees shifting)
- Spirit-hum (a low, musical resonance near totems and ley lines)
- Animal calls (unfamiliar, not birdsong -- the Wilds have their own fauna)
- Footsteps on soft earth and roots (muffled, organic)

**Encounter Feel:**
- Spirit creatures (translucent, glowing, territorial but not inherently hostile)
- Forest predators (large cats, root-serpents, canopy ambush creatures)
- Ley-touched fauna (animals with visible magical energy -- sparking, overgrown, mutated)
- Corrupted spirits (Interlude -- the same creatures, but grey and wrong, moving in jerks)

**Locations Using This Biome:**
- Roothollow (organic architecture variant -- root-chamber interiors, heartwood shrines)
- Canopy Reach (vertical variant -- treetop platforms, rope bridges, sky-exposed canopy)
- Greywood Camp (open-forest variant -- greywood trees with pale bark, larger clearings, semi-permanent structures)
- Maren's Refuge (hermit variant -- dense, dark, isolated, with spirit visitors)
- Stillwater Hollow (sacred spring variant -- mirror-still water, training stones, meditative quiet)
- Overworld routes: Ironmouth to Roothollow (Wildwood Trail), Roothollow to Maren's Refuge (The Deep Path)

---

### 4. Thornmere Wetlands

**Description:** Where the canopy breaks and the ground turns soft. Marsh, fog, black water, and reed beds stretching to the horizon. The light is flat and grey-green, diffused through permanent mist. Everything is damp. The palette is muted and murky -- olive, mud-brown, and the sickly yellow-green of marsh gas. This biome feels uncertain, like the ground itself might give way.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Water (surface) | `#3A4A38` | Black-green marsh water, still |
| Water (deep) | `#2A3428` | Submerged areas, deep marsh |
| Reed | `#7A8A48` | Standing reeds, cattails |
| Reed (dead) | `#8A8258` | Dry reed, winter marsh |
| Mud | `#5A4A38` | Exposed mud banks, paths |
| Fog | `#A8A898` | Mist layer, diffused light |
| Wood (wet) | `#4A3E30` | Waterlogged timber, platform pilings |
| Wisp light | `#C8D858` | Will-o'-wisp glow, marsh gas |
| Sky | `#8A9888` | Low overcast, grey-green wash |
| Shadow | `#1E2A1E` | Deep water shadow, beneath platforms |
| Moss (wet) | `#4A6838` | Submerged moss, slick surfaces |
| Rope | `#8A7A5A` | Bridge rope, netting, binding |

**Tileset Direction:**
- Ground tiles: mud (wet, dry, cracked), reed bed, submerged grass, shallow water with visible bottom, deep water (opaque)
- Water tiles: still marsh surface (animated, subtle ripple), flowing channel, waterfall (small, over root dams), bubbling (marsh gas)
- Vegetation: tall reeds (2 tiles high, animated sway), dead reeds, lily pads, duckweed surface, gnarled swamp trees (mangrove-style roots), hanging moss
- Architecture: reed-woven platforms (Duskfen), rope bridges (frayed, swaying), wooden pilings, lantern posts (will-o'-wisp variant), fishing platforms
- Props: fishing nets, crab traps, spirit-binding totems (Duskfen-specific), reed baskets, mooring posts
- Hazards: deep water tiles (impassable without bridge), sinking mud (slow movement), marsh gas vents (animated bubble + glow)

**Weather/Atmosphere:**
- Default: Fog. Always fog. Visibility drops to 4-5 tiles in places. The fog moves slowly, thickening and thinning.
- Occasional: Rain -- not dramatic, just a persistent drizzle that raises the water level visually.
- Light: Flat, diffused, no shadows. The fog swallows directional light. Will-o'-wisps are the brightest things.
- Interlude: The fog turns grey. The water rises. Will-o'-wisps go out, replaced by grey points of light that do not flicker.

**Sound Palette:**
- Water (lapping, dripping, bubbling -- constant, layered)
- Frogs and marsh insects (a dense, buzzing chorus -- louder at night)
- Creaking wood (platforms shifting)
- Squelching footsteps (mud, waterlogged ground)
- Distant splashes (something moving in the water, unseen)
- Wind through reeds (a thin, whistling sound)

**Encounter Feel:**
- Marsh creatures (serpents, bloated amphibians, armored water beetles)
- Fenmother's spawn (water spirits, serpentine, semi-translucent)
- Ley-poisoned fauna (Compact extraction runoff -- creatures with growths, discoloration)
- Undead remnants (old bones given false life by wild magic near the surface)

**Locations Using This Biome:**
- Duskfen (tribal settlement variant -- reed platforms, rope bridges, spirit-binding workshop)
- Fenmother's Hollow (submerged ruin variant -- transitions to Underground biome underwater, with flooded corridor tiles)
- Overworld route: Valdris Crown to Duskfen (Diplomatic Road, marsh section)

---

### 5. Mountain / Alpine

**Description:** Snow-capped peaks, exposed rock, thin air, and austere architecture. The world opens up here -- vast views, sharp wind, and a sense of isolation that borders on spiritual. The palette is cool and clean: slate blue, snow white, grey stone, with the warm amber of hearth light as the only refuge. Highcairn's monastery sits in this biome, and the palette reflects the monks' austerity.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Snow | `#E8E4E0` | Fresh snowfields, peak coverage |
| Snow (shadow) | `#B0B8C8` | Snow in shadow, blue undertone |
| Rock (light) | `#8A8A8A` | Exposed stone, cliff face in light |
| Rock (dark) | `#5A5860` | Stone shadow, crevices, cave mouth |
| Sky | `#A8C0D8` | Thin, pale alpine sky |
| Pine | `#2E4A38` | Hardy evergreen, treeline |
| Ice | `#C8D8E8` | Frozen streams, icicle formations |
| Hearth | `#D89848` | Firelight from windows, warm interior |
| Path | `#7A7268` | Worn stone switchback, gravel trail |
| Wind | `#D0D8E0` | Blowing snow particle, mist |
| Monastery stone | `#9A9088` | Weathered, hand-cut stone blocks |
| Deep shadow | `#2A2838` | Canyon depths, night rock |

**Tileset Direction:**
- Ground tiles: snow (flat, drifted, wind-packed), exposed rock, gravel path, frozen earth, ice sheet
- Rock tiles: cliff face (vertical, with ledges), boulder, loose scree, cave entrance, wind-carved formations
- Vegetation: stunted evergreens (2-3 sizes, sparse), dead brush, alpine flowers (rare, small), lichen on rock
- Architecture: monastery walls (thick, austere, narrow windows), stone arches, bell tower, hearth chimneys, heavy wooden doors, slate roof tiles
- Water: frozen stream (ice surface with visible flow beneath), waterfall (frozen mid-fall), hot spring (steam rising, warm tones)
- Weather tiles: blowing snow particles (animated, directional), fog bank, cloud layer (at altitude, below the player)
- Props: prayer stones, trail markers (cairns), wind-worn banners, firewood stacks, iron braziers

**Weather/Atmosphere:**
- Default: Wind. Constant, audible, visible (blowing snow particles, swaying banner sprites). The air feels thin.
- Altitude effect: Above the treeline, the palette shifts bluer. Clouds are below the player. Visibility is paradoxically infinite -- the panoramic views of the continent.
- Interior: Stark contrast. Warm hearth light, still air. The monastery interior palette shifts toward amber and deep brown.
- Storm: Whiteout conditions. Visibility drops to 2-3 tiles. Movement slows. The wind sound becomes a roar.

**Sound Palette:**
- Wind (dominant -- low constant with gusting peaks, pitch shifts with altitude)
- Footsteps crunching on snow and stone (crisp, echoing)
- Distant bells (monastery, carried by wind, intermittent)
- Ice cracking (underfoot, ambient -- the mountain shifting)
- Silence in sheltered areas (sudden, notable, peaceful)
- Hearth crackle (interiors only -- the warmth has sound)

**Encounter Feel:**
- Highland beasts (mountain goats with ice-crusted horns, white wolves, snow hawks)
- Ice elementals (formed from frozen ley energy -- angular, geometric)
- Pallor manifestations (Interlude -- grey mist creatures that blend with blowing snow)
- Monastery spirits (guardian constructs of the knight-monks, testing rather than hostile)

**Locations Using This Biome:**
- Highcairn (monastery variant -- austere architecture, prayer stones, the great hall)
- Windshear Peak (bare summit variant -- no architecture, exposed rock, wind-spirit shrine)
- Overworld route: Highcairn to Valdris Crown (Highland Descent, upper section)

---

### 6. Ley Line Nexus

**Description:** Where raw magical energy surfaces and the rules of the physical world soften. The palette is unstable -- shifting, crystalline, oversaturated. Ley line nexus points exist within other biomes (Sunstone Ridge is in the Wilds, the Ley Line Depths are underground), but the visual language is consistent: crystallized energy, geometric patterns, and colors that are too vivid, too pure, as if the palette has been uncompressed from its SNES constraints.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Ley energy (warm) | `#E8A838` | Amber ley flow, Sunstone Ridge |
| Ley energy (cool) | `#38A8E8` | Blue ley flow, standard nexus |
| Ley energy (wild) | `#B848D8` | Unstable ley flow, post-Unraveling |
| Crystal (light) | `#D8E8F8` | Crystallized ley energy, light face |
| Crystal (dark) | `#6888A8` | Crystal shadow, interior |
| Stone (nexus) | `#4A4858` | Rock near ley exposure, stained dark |
| Geometric glow | `#F8F0D0` | Ancient carved patterns illuminated |
| Ground (charged) | `#3A4838` | Earth saturated with ley energy |
| Void | `#181828` | Deep spaces between energy flows |
| Shimmer | `#E8D8F8` | Particle effect, ambient magical dust |
| Vein | `#48C8A8` | Ley line veins visible in rock |
| Warning red | `#D84848` | Overloaded nexus, dangerous proximity |

**Tileset Direction:**
- Crystal tiles: crystallized ley energy formations (clusters, columns, veins in rock), faceted surfaces with specular highlights, shattered crystal debris
- Energy tiles: flowing ley energy (animated, 4-6 frames, river-like), energy geyser vents, energy pools (still, glowing), energy arcs between crystals
- Stone tiles: nexus-stained rock (veined with color), geometric carved floors and walls (Ember Vein / Archive of Ages pattern language), sealed doors with Pendulum sigil
- Vegetation: none natural -- crystal formations replace organic growth
- Infrastructure: Compact pumping rigs and scaffolding (industrial intrusion into magical space), conduit pipes, extraction drill heads
- Hazards: magical burn zones (pulsing glow, damage on contact), unstable crystal (shatters, environmental hazard), raw energy rivers (impassable without bridge)
- Props: ancient pedestals, geometric wall carvings (recurring motif), broken pumping equipment, crystallized remains (miners, creatures)

**Weather/Atmosphere:**
- Default: No weather in the traditional sense. The air itself glows faintly. Particle effects are constant -- motes of light drifting upward, energy shimmer.
- Sound distortion: Sounds echo oddly. Footsteps have a harmonic overtone. Voices carry further than they should.
- Post-Unraveling: The palette shifts. Blue and amber ley energy is increasingly contaminated with purple (wild magic) and grey (Pallor). Crystals crack and reform.
- The Convergence: The nexus pushed to its extreme. All colors at once, then draining to grey as the Pallor incarnates.

**Sound Palette:**
- Harmonic hum (the ley lines themselves -- a chord that shifts with proximity and health)
- Crystal resonance (high, pure tones when crystals are disturbed)
- Energy flow (rushing, like a river heard through stone)
- Heartbeat rhythm (at major nexus points -- the world's pulse)
- Machinery (where Compact infrastructure intrudes -- grinding against the harmony)
- Dissonance (post-Unraveling -- the hum fractures, becomes atonal)

**Encounter Feel:**
- Ley-born creatures (living energy constructs -- geometric, translucent, shifting)
- Crystal elementals (slow, massive, reflective)
- Guardian constructs (at ancient sites -- test visitors rather than attack)
- Corrupted constructs (Interlude -- the same shapes, fractured, emitting static)

**Locations Using This Biome:**
- Sunstone Ridge (amber variant -- orange-red crystal, warm ley energy, open sky)
- Ley Line Depths (underground variant -- raw ley rivers, Compact scaffolding, ancient carvings)
- Ember Vein (introductory variant -- small scale, ember-orange crystal, geometric walls)
- The Convergence (extreme variant -- all ley colors converging, then draining)
- Stillwater Hollow (subtle variant -- ley energy beneath a sacred spring, felt more than seen)

---

### 7. Coastal / Harbor

**Description:** Salt air, grey-blue water, weathered wood, and the commerce of empires. The coastal biome blends maritime atmosphere with Carradan industry at port cities, or with wild natural coastline elsewhere. The palette is washed -- sun-bleached wood, faded paint, the steel-blue of deep water and the grey-green of shallows.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Ocean (deep) | `#2A4868` | Open water, harbor depths |
| Ocean (shallow) | `#4A7888` | Shallows, harbor edge |
| Surf | `#C8D8D8` | Wave foam, spray |
| Sand | `#C8B898` | Beach, sandbar |
| Dock wood | `#7A6848` | Weathered pier, hull planks |
| Stilt | `#5A5048` | Harbor pilings, stilt foundations |
| Sail/canvas | `#D8D0C0` | Ship sails, market awnings |
| Rope | `#8A7A58` | Rigging, mooring lines |
| Iron (maritime) | `#68686E` | Ship hull plates, harbor chains |
| Sky (coastal) | `#98B8C8` | Hazy maritime sky |
| Rust (salt) | `#9A5838` | Salt-corroded metal, aged hardware |
| Lantern | `#E8C868` | Harbor lamps, ship lights |

**Tileset Direction:**
- Water tiles: ocean surface (animated, 4-frame wave cycle), harbor water (calmer), wave-on-shore, tidal pool
- Ground tiles: sand (wet, dry), rocky shore, barnacled stone, dock planking, cobblestone (harbor district)
- Architecture: stilt buildings (Bellhaven), wooden piers, stone jetties, warehouse walls, ship hulls (ironclad for Compact vessels), crane structures, lighthouse
- Vegetation: sea grass, dune grass, salt-stunted shrubs, no trees near waterline
- Props: cargo crates (stamped), fishing nets, anchor, buoys, lobster pots, market fish displays, rope coils, barrel stacks
- Ships: ironclad barge (Compact, smoking), fishing boat, submersible rig (partially visible), rowboat

**Weather/Atmosphere:**
- Default: Haze. The horizon blurs where sea meets sky. Salt smell (implied by particle effects -- sea spray motes). Gulls visible as distant sprites.
- Wind: Stronger than inland. Flags and sails are always animated. Canvas awnings ripple.
- Storm: Dramatic. Dark water, high waves (animated tile replacement), rain, lightning illuminating ship silhouettes.
- Fog: Common at dawn. Reduces visibility, softens the palette further.

**Sound Palette:**
- Waves (constant -- rhythmic, hypnotic, louder at exposed shores)
- Gulls (intermittent, circling)
- Ship creaking (at dock, wooden hull stress)
- Harbor bustle (voices, chains, cargo thumps)
- Bell buoy (distant, rhythmic, melancholy)
- Wind in rigging (whistling, varying pitch)

**Encounter Feel:**
- Sea creatures (at shore and on rigs -- crustaceans, tentacled things, barnacle-encrusted)
- Pirates and smugglers (human, coastal bandit equivalent)
- Compact naval patrols (disciplined, ironclad)
- Pallor manifestations (Interlude -- creatures from the deep, grey and formless, washing ashore)

**Locations Using This Biome:**
- Bellhaven (harbor city variant -- blends with Carradan Industrial, stilt architecture, merchant manors)
- Ashport (trade port variant -- heavier industrial blend, weapons testing ranges audible)
- Sunken Rig (offshore variant -- fully industrial, claustrophobic, half-submerged)

---

### 8. Underground / Cavern

**Description:** Darkness as a default state. Light is something you bring with you or find in rare natural formations. The palette is stone grey, deep blue-black, and whatever color the light source provides -- torchlight amber, ley crystal blue, Arcanite white, or Pallor grey. The underground biome is shared by natural caves, mine shafts, and the tunnels beneath cities.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Stone (light) | `#787880` | Cave wall in light, worked stone |
| Stone (mid) | `#4A4A58` | Standard cave rock, tunnel wall |
| Stone (dark) | `#2A2A38` | Deep shadow, unlit passage |
| Earth | `#5A4838` | Exposed dirt, mine tunnel floor |
| Ore vein | `#6A7A8A` | Metal deposits in rock, unrefined |
| Torchlight | `#D8A050` | Radius of warm light, flame source |
| Water (cave) | `#384858` | Underground stream, drip pools |
| Stalactite | `#686878` | Natural formation, ceiling features |
| Timber (mine) | `#6A5838` | Mine shaft bracing, support beams |
| Void | `#0E0E18` | Absolute darkness, bottomless pits |
| Fungal glow | `#58A878` | Subterranean mushroom light |
| Dust | `#A8A098` | Disturbed air, falling particles |

**Tileset Direction:**
- Wall tiles: natural cave wall (rough, organic), worked stone (chisel marks), mine shaft wall (timber-braced), brick-lined tunnel (Compact), dripping surface (animated water streaks)
- Floor tiles: bare stone, mine cart track, wooden planking, metal grating (Compact tunnels), gravel, mud
- Ceiling tiles: stalactite formations, timber crossbeams, exposed root (connecting to forest biome above), void (open cavern above)
- Water: underground stream (slow, dark), drip pool (still, reflecting), waterfall (into darkness)
- Light sources: torches (wall-mounted, animated flame), Arcanite lamps (Compact, white-blue), ley crystal deposits (self-illuminating), bioluminescent fungi (green-blue)
- Hazards: pit edges (bottomless), cave-in rubble, steam vents, unstable floor (cracked tiles), gas pockets (shimmer effect)
- Props: mine carts, pick-axes, rope ladders, ore samples, support timber, rail switches

**Weather/Atmosphere:**
- Default: No weather. Temperature is stable, cool. The air is still except near vents or waterfalls.
- Lighting: The dominant design element. Each room is defined by its light source -- warm torch, cold Arcanite, natural crystal, or no light at all. The player's torch radius is a key gameplay element.
- Sound carries: Footsteps echo. Dripping water amplifies. Distant sounds (machinery, water, creatures) are audible long before their source.
- Depth: The deeper you go, the darker the base palette. Surface caves have some ambient light. Deep mines are pure void without a torch.

**Sound Palette:**
- Dripping water (constant, irregular, echoing)
- Footstep echo (stone, timber, metal -- changes by floor type)
- Distant rumbling (geological, ominous, unpredictable)
- Wind through passages (thin, whistling, directional)
- Creature sounds (unseen -- scuttling, breathing, clicking)
- Machinery (in Compact tunnels -- muffled through rock, rhythmic)

**Encounter Feel:**
- Cave fauna (bats, blind predators, burrowing creatures, crystalline insects)
- Ley-corrupted vermin (Ember Vein -- first dungeon enemies, weak but eerie)
- Mining constructs (Compact -- drill golems, rail sentries)
- Pallor nests (Interlude tunnels -- grey growths on walls, spawning manifestations)

**Locations Using This Biome:**
- Ember Vein (ancient ruin variant -- ember-orange crystals, geometric carvings, shifts into Ancient Ruins sub-biome)
- Carradan Rail Tunnels (industrial variant -- iron-braced, Arcanite-lit, rail infrastructure)
- Ley Line Depths (nexus variant -- transitions into Ley Line Nexus biome at depth)
- Dry Well of Aelhart (progressive variant -- transitions from village well to natural caves to full Ancient Ruins over 7 floors)
- Axis Tower lower levels (urban variant -- maintenance tunnels, Undercroft access)

---

### 9. Ancient Ruins

**Description:** The architecture of a civilization that predates all three factions. Geometric precision, impossible scale, and a visual language built around the Pendulum's sigil. Every ancient ruin in the game shares this tileset to establish continuity -- the Ember Vein, the Ley Line Depths sealed door, and the Archive of Ages are all fragments of the same lost builders. The palette is timeless: dark stone with inlaid geometric patterns that glow with residual ley energy.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Stone (ancient) | `#38384A` | Worked stone, impossibly smooth |
| Stone (edge) | `#4A4A5A` | Block edges, carved relief |
| Inlay (dormant) | `#585868` | Geometric patterns, unpowered |
| Inlay (active) | `#D8C868` | Geometric patterns, ley-powered |
| Ley residue | `#68A8C8` | Trace energy in seams and carvings |
| Pedestal | `#4A4858` | Artifact resting points, altar stone |
| Void (sealed) | `#0A0A18` | Behind sealed doors, unanswerable |
| Dust (ages) | `#8A8880` | Settled dust, undisturbed surfaces |
| Glyph (warn) | `#D85848` | Warning inscriptions, danger markers |
| Light (ancient) | `#F0E8C8` | Self-illuminating chambers, warm |
| Pictograph | `#A89878` | Wall carvings, historical records |
| Threshold | `#2A2840` | Doorway frames, passage borders |

**Tileset Direction:**
- Wall tiles: smooth-cut stone blocks (unnaturally precise), geometric relief carvings (repeating patterns), pictographic panels (Archive of Ages -- story scenes carved in stone), inlaid channel lines (dormant and glowing variants)
- Floor tiles: tessellated geometric patterns (the signature look), raised platform, recessed channel, pressure plate (puzzle element), mosaic (depicting the Pendulum cycle)
- Architecture: arched doorways (perfect geometry), sealed doors (Pendulum sigil), pedestals (artifact resting points), vast chambers (scale dwarfs the player), pillared halls, reconfiguring walls (Archive -- rooms that shift when tablets are read)
- Light: self-illuminating chambers (no visible source), geometric inlay glow (animated pulse), dormant sections (dark, waiting for interaction)
- Props: stone tablets (readable, lore objects), guardian construct alcoves (empty or occupied), broken artifacts, dust patterns (undisturbed for millennia), the Pendulum pedestal (Ember Vein)

**Weather/Atmosphere:**
- Default: Timeless. No weather, no wind, no dust in the air. The stillness is deliberate -- these spaces were built to last forever.
- Sound: Muffled. The stone absorbs sound. Footsteps are dampened. The player's breathing would be audible.
- Scale: Rooms are too large for their apparent purpose. Ceilings too high. Doorways wider than necessary. The builders were either larger than humans or built for something other than human habitation.
- Activation: When the player interacts with tablets or puzzles, the inlay patterns illuminate in sequence -- a wave of golden light spreading through channels in the stone.

**Sound Palette:**
- Near-silence (the dominant sound is absence)
- Resonance (low, harmonic tone when inlay patterns activate)
- Stone shifting (during puzzle sequences -- deep, grinding, precise)
- Footstep dampening (the stone absorbs impact -- a soft, dead sound)
- Guardian hum (constructs powering up -- a rising harmonic chord)
- The Pallor echo (in ruins near corrupted areas -- a faint, discordant whisper beneath the harmony)

**Encounter Feel:**
- Guardian constructs (geometric, stone-and-light, testing rather than killing)
- Ley-born echoes (impressions of past events given temporary form)
- Dormant sentries (activate when the player disturbs specific areas)
- No random encounters in most ruin sections -- the danger is puzzle-based and boss-focused

**Locations Using This Biome:**
- Ember Vein (introductory scale -- small, 4 rooms, ember-orange inlay)
- Archive of Ages (full scale -- vast, knowledge-based puzzles, pictographic walls)
- Ley Line Depths (partial -- ancient carvings visible at the deepest level, sealed door)
- Dry Well of Aelhart (full scale -- 7 floors, progressive descent from village well to ley-line nexus, waterworks, residential quarters, deep archive, gravity-warped depths, and the Wellspring)
- Dreamer's Fault (corrupted variant -- architecture from multiple ages twisted together, impossible geometry)

---

### 10. Ashlands

**Description:** The ground where nothing grows. Ashgrove's pale ash field and the scorched earth surrounding spent extraction sites share this biome -- a landscape defined by what was lost. The palette is monochrome warm: cream, ash-white, pale brown, with the faintest memory of color in the soil. This is not the Pallor's grey -- this is natural death, fire and time, the world's own cycle of burn and regrow. But in the Interlude, the Ashlands are the first to fall to the Pallor, because they were already halfway there.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Ash (light) | `#D8D0C0` | Surface ash, pale and fine |
| Ash (mid) | `#B8B0A0` | Deeper ash, compacted |
| Ash (dark) | `#8A8478` | Wet ash, shadowed areas |
| Charcoal | `#4A4440` | Burned wood remnants, stumps |
| Bone | `#C8C0B0` | Bleached stone, petrified wood |
| Sky | `#B8B8B0` | Overcast, pale, washed |
| Ember (fading) | `#A87848` | Last warmth in the soil |
| Stone (exposed) | `#908880` | Bare rock where soil burned away |
| Footprint | `#A8A090` | Preserved tracks in ash |
| Shadow | `#5A5850` | Standing stone shadow, stump shadow |
| Dust mote | `#D0C8B8` | Particles in still air |
| Council stone | `#6A6860` | Standing stones, ritual markers |

**Tileset Direction:**
- Ground tiles: ash (fine, compacted, disturbed), charcoal patches, exposed rock, preserved footprints (Ashgrove-specific), burned earth (extraction site variant)
- Vegetation: none living. Charred stumps, petrified tree trunks, dead root systems visible in ash
- Features: standing stones (Ashgrove council stones), the First Tree stump, ash drifts against stone, wind-carved patterns in ash
- Architecture: temporary shelter frames (Ashgrove gathering variant), extraction rig ruins (Compact variant -- rusted, abandoned)
- Props: preserved artifacts in ash, offering bowls at standing stones, tribal markers

**Weather/Atmosphere:**
- Default: Still air. Ash particles drift when the player moves. The silence is oppressive but not hostile -- meditative.
- Wind: When it comes, ash lifts and swirls. Visibility drops slightly. The standing stones emerge from the haze like ghosts.
- Light: Flat, overcast, directionless. No harsh shadows. Everything looks the same at noon as it does at dusk.

**Sound Palette:**
- Silence (dominant -- this biome's primary sound is the absence of other biomes' sounds)
- Ash crunch underfoot (soft, dry, the only sharp sound)
- Distant wind (thin, high, carrying nothing)
- Subtle sub-bass drone (the First Tree's memory, felt more than heard)

**Encounter Feel:**
- Ash wraiths (grey-white, floating, formed from accumulated loss)
- Petrified creatures (stone animals that animate when disturbed)
- No encounters during council gatherings -- sacred ground, truce enforced

**Locations Using This Biome:**
- Ashgrove (sacred grove variant -- council stones, the First Tree stump, tribal gathering)
- Millhaven crater (post-eruption variant -- blasted extraction site, deeper char, no standing structures)
- Transition zones between healthy biomes and Pallor-corrupted areas (the ash is the border)

---

### 11. The Pallor Wastes

**Description:** Not a natural biome. The Pallor Wastes are what happens when the corruption completes its work. All color is drained. The sky is a flat, featureless grey ceiling. Sound is muffled. Trees are petrified stone. The ground is ash that was never burned -- it was drained. This is the destination biome for all corruption, the end state of the overlay system described in Section 5. It exists as a full biome only in Act III, within the ten-mile radius of the Convergence.

**Color Palette:**

| Role | Hex | Description |
|------|-----|-------------|
| Grey (light) | `#A8A8A8` | Brightest tone in the Wastes |
| Grey (mid) | `#787878` | Standard surface, petrified bark |
| Grey (dark) | `#484848` | Shadow, crevice, depth |
| Grey (void) | `#282828` | Deepest dark, the Pallor's core |
| White (static) | `#C8C8C8` | Pallor static effect, visual noise |
| Ash (drained) | `#989898` | Ground surface, not burned but emptied |
| Stone (dead) | `#686868` | Petrified wood, fossilized life |
| Sky | `#909090` | Uniform ceiling, no depth |
| Ley (dying) | `#607080` | Last traces of ley energy, blue-grey |
| Pallor glow | `#B0B0B8` | The Pallor's light, cold and flat |
| Remnant | `#888080` | Ghost of original color, memory |
| Crack | `#383838` | Fractures in petrified matter |

**Tileset Direction:**
- Ground tiles: drained ash (uniform, lifeless), cracked earth, petrified root network, grey gravel
- Vegetation: petrified trees (stone bark, frozen mid-sway), stone grass, fossilized flowers (recognizable shapes, no color)
- Features: Pallor manifestation spawn points (grey cracks in the air), fading ley line traces (dim pulse in the ground), clearing circles (where ley lines still pulse faintly -- save points)
- Static effect tiles: visual noise overlay (animated, flickering grey-white pixels -- like television static at low opacity). This is the Pallor's signature visual. It appears at the edges of the screen and intensifies near manifestations.
- Props: party member artifacts from Pallor trials (Edren's phantom sword, Lira's cottage vision, etc.)
- The Convergence: floating plateau tiles, crumbling edges, energy geyser vents, Cael's machine (hybrid Forgewright/ritual geometry)

**Weather/Atmosphere:**
- Default: Nothing. No wind. No temperature. No weather. The air is perfectly still and featureless. This is the most disturbing thing about the Wastes -- the absence of everything.
- Sound: Muffled. The party's footsteps are the loudest thing. Distant sounds do not exist. There is no horizon to echo from.
- The static: At the edges of perception, visual static flickers. The player's screen. Not the game world's screen -- the player's. The fourth wall bends here. The static is the Pallor watching.
- Hope: Where ley lines still pulse (the clearing save points), color returns in a tiny radius. Warm amber. The player clings to these moments.

**Sound Palette:**
- Muffled footsteps (the dominant sound)
- Static (low, constant, like a dead channel -- rises during encounters)
- Silence (aggressive, oppressive -- the absence of the world's natural soundscape)
- Heartbeat (the party's -- or the player's -- rises during trials)
- A single sustained tone (the Pallor's voice -- a flat, unvarying pitch at the edge of hearing)
- Memory sounds (during trials -- fragments of each biome's sound palette, distorted)

**Encounter Feel:**
- Pallor manifestations (grey, formless, shaped by the party's fears)
- Hollow creatures (petrified animals given false motion -- they move but have no life)
- The Pallor's personal attacks (trial mini-bosses -- phantoms of loved ones, lost futures, failure)
- The incarnation (the final form -- a towering presence of grey static that fills the sky)

**Locations Using This Biome:**
- Pallor Wastes (Act III gauntlet -- the full biome, ten miles of grey)
- The Convergence (the biome's center and culmination)
- Any fully corrupted location during the Interlude (Greyvale approaches this state)

---

## Biome Transitions

The overworld map uses gradual tile blending at biome borders, following the SNES tradition of 3-5 tile transition strips. No hard borders -- the world breathes between its regions.

### Transition Map

```
           MOUNTAIN/ALPINE
                |
         VALDRIS HIGHLANDS
           /          \
    ASHLANDS    CARRADAN INDUSTRIAL --- COASTAL/HARBOR
        \       /          |
     THORNMERE DEEP FOREST |
        |          \       |
  THORNMERE WETLANDS \     |
        \          LEY LINE NEXUS
         \          /
      UNDERGROUND/CAVERN
```

### Border Definitions

| Transition | Border Description | Tile Blending |
|-----------|-------------------|---------------|
| **Valdris Highlands -> Mountain/Alpine** | Grass thins, stone emerges, trees become evergreen. Temperature drops tile by tile. | Green grass -> yellow-green -> grey-green -> snow-dusted rock. Trees shrink from full deciduous to stunted pine to bare rock. 4-tile gradient. |
| **Valdris Highlands -> Thornmere Deep Forest** | Farmland gives way to wild growth. The canopy closes overhead in stages. | Mowed grass -> tall grass -> underbrush -> forest floor. Light shifts from open sky to filtered to bioluminescent. 5-tile gradient (the longest -- the Wilds swallow you slowly). |
| **Valdris Highlands -> Carradan Industrial** | The contested border. Green turns scorched. Stone turns to brick. Greyvale is the transition incarnate. | Green grass -> yellowed -> scorched -> blackite plain. Limestone walls -> mixed stone -> brick. Ley-lamps -> Arcanite lamps. 4-tile gradient. |
| **Valdris Highlands -> Ashlands** | Grass fades, soil pales, living things thin out. A slow drain. | Green -> yellow-brown -> pale brown -> ash-white. Trees -> bare trunks -> stumps -> nothing. 3-tile gradient. |
| **Thornmere Deep Forest -> Thornmere Wetlands** | The canopy opens. The ground softens. Water appears. | Forest floor -> muddy ground -> shallow water -> marsh. Tree trunks -> mangrove roots -> reeds. Light shifts from bioluminescent to fog-diffused. 4-tile gradient. |
| **Thornmere Deep Forest -> Ley Line Nexus** | The forest gives way where ley energy is too intense for growth. Crystal replaces wood. | Trees thin, bark develops crystal growths, then bare crystal formations replace trees entirely. Ground shifts from root-mat to charged stone. 3-tile gradient. |
| **Carradan Industrial -> Coastal/Harbor** | Brick meets salt. Factories give way to warehouses, then docks. | Brick wall -> warehouse iron -> dock wood. Blackite ground -> cobblestone -> dock planking -> sand/water. Smog -> salt haze. 3-tile gradient. |
| **Carradan Industrial -> Underground/Cavern** | Seamless in factory cities. The surface descends into mine shafts, undercrofts, tunnel systems. | No gradient needed -- architectural transition through doorways, staircases, elevator shafts. The palette shifts from smog-amber to torchlight-amber. |
| **Underground/Cavern -> Ley Line Nexus** | Depth reveals power. Natural cave gives way to veined, glowing stone. | Grey stone -> veined stone -> crystal-studded walls -> raw ley energy flows. Darkness -> faint glow -> full illumination. 3-tile gradient (vertical, going deeper). |
| **Underground/Cavern -> Ancient Ruins** | Rough natural cave transitions to worked stone. The geometry becomes too perfect. | Irregular stone -> dressed stone -> smooth geometric blocks. Darkness -> inlay glow. A single threshold doorway often marks the exact border. |
| **Any Biome -> Pallor Wastes** | Color drains. The transition described in detail in Section 5. | Original palette -> desaturated original -> grey-tinted -> monochrome grey. This is the game's most important transition. 5+ tile gradient, with static particles appearing at the midpoint. |

### Music Crossfades

Each biome has a primary musical theme. Transitions use a 3-second crossfade:
- The outgoing biome's music fades from 100% to 0% over 1.5 seconds
- The incoming biome's music fades from 0% to 100% over 1.5 seconds
- The crossfade begins when the player crosses the transition's midpoint tile
- Exception: Pallor Wastes. The music does not crossfade. It cuts to silence, then the Pallor's drone fades in over 5 seconds. The silence between is deliberate.
- Exception: Ley Line Nexus. The nexus hum blends additively with the surrounding biome's music rather than replacing it, creating a layered soundtrack that acknowledges the nexus exists within another biome.

---

## Environmental Storytelling

Each biome contains 3-5 environmental details that communicate story without dialogue. These are tile arrangements, prop placements, and ambient details that a careful player notices and a rushing player absorbs subconsciously.

### Valdris Highlands

1. **Dry wells and dead gardens.** In Aelhart and the Valdris countryside, wells have run dry and gardens are fallow. Older tiles show where water stains once reached -- the well's stone is darker at a higher waterline. The ley lines that sustained these enchantments are failing.
2. **Dimming ley-lamps.** The Seven Towers' glow is a fitful pulse, not the steady beam described in old books the player can examine. Street lamps in Valdris Crown flicker. Some have gone dark entirely, replaced by mundane oil lanterns -- a visual admission of decline.
3. **Carradan goods in Valdris markets.** Forgewright tools on market stalls. Arcanite-powered lanterns in windows. The Compact's cultural creep is visible in every shop before any NPC mentions the political tension.
4. **The collapsed eastern wall.** After the Act II assault, the wall is rubble. But observant players notice the rubble pattern shows the wall was breached from inside as well as outside -- Forgewright explosives were placed by someone with access. The betrayal was not just Cael's.
5. **Cael's window.** In Valdris Crown, Cael's quarters have a window that faces the Wilds. During Act II, a faint grey light is visible from outside -- the Pendulum's glow. After the betrayal, the window is dark. If the player examines it during the Interlude, the glass is cracked from the inside.

### Carradan Industrial

1. **Worker housing shrinks going down.** In Corrund and Caldera, the architecture tells the class story without a word. Upper districts have wide streets and glass windows. Descend tier by tier and the streets narrow, windows shrink, ceilings lower. The Undercroft has no windows at all.
2. **The tremor NPCs.** In Millhaven, worker sprites have a subtle animation -- their hands shake. The tremor from ley exposure. Management NPCs do not have this animation. They stand uphill from the pit.
3. **Forge-smoke color shifts.** Normal Compact forge-smoke is grey-brown. During the Interlude, the smoke from Arcanite engines running on Pallor energy shifts to grey-white -- cleaner-looking, but wrong. NPCs comment that the forges are "running better than ever" while the world falls apart.
4. **Lira's marks.** In Ashmark and Caldera, small scratched symbols appear on certain walls -- Lira's trail markers from her defection route. Only visible if the player knows to look (a side quest item provides a lens). They tell the story of her escape.
5. **The original anvil.** In Ashmark's Founders' Hall, the first Forgewright anvil sits in a glass case surrounded by mechanical prayer wheels. The prayer wheels have stopped turning. No one has noticed.

### Thornmere Deep Forest

1. **Petrifying bark.** Trees near the Wilds' edges show bark turning grey and stone-like in patches. In Act I this is subtle -- a detail tile variant on 1 in 10 trees. By the Interlude, half the forest edge is petrified. The corruption is advancing.
2. **Spirit-totem silence.** In Roothollow, spirit-totems hum and glow. On the overworld paths, older totems are dark and silent. Some have fallen. The spirits are retreating from areas where the ley lines are weakest.
3. **Compact boot prints.** On the Wildwood Trail and near Ironmouth, boot prints in the mud follow a Compact tread pattern. Mining markers are nailed to trees. The forest is being surveyed for future extraction, even as diplomacy is discussed.
4. **The great tree's rings.** If the player examines a cross-section of a fallen tree near Roothollow, the growth rings show a sudden narrowing roughly fifteen years ago -- when the Compact began large-scale ley extraction. The tree felt it.
5. **Maren's spirit visitors.** Near Maren's Refuge, small spirit creatures watch from the edges of the screen. They do not appear in other forest areas this deep. Maren's presence has made a pocket of safety that the spirits congregate around.

### Thornmere Wetlands

1. **The rusted engine.** Half-sunk in the deep marsh between Duskfen and the Fenmother's Hollow, a Carradan Forgewright engine sits in the muck, its gears clogged with mud and reed growth. The Compact tried to drain this marsh for extraction. The marsh won. For now.
2. **Rising water marks.** On Duskfen's platform pilings, discoloration shows the water level was once a full tile lower. The marsh is rising -- the ley lines beneath are destabilizing, and the water table responds.
3. **Dead fish.** Near extraction runoff points (flowing from the Compact's direction), dead fish float on the water surface. The tile is small, easy to miss. The poisoning is subtle and ongoing.
4. **Will-o'-wisp behavior.** In healthy marsh, the wisp lanterns flicker warmly. Near corrupted areas, they pulse erratically. During the Interlude, they go dark. What replaces them does not flicker at all -- it is steady, grey, and cold.
5. **The Fenmother's silhouette.** Before the player enters the Hollow dungeon, a vast serpentine shadow is briefly visible beneath the water's surface in certain tiles. She is there, under everything, waiting.

### Mountain / Alpine

1. **The northern horizon.** From Highcairn's overlook, the player can see the continent. During Act I (if visible from this biome), the view shows green Valdris, dark Wilds, and smoke-stained Compact territory. During the Interlude, a grey stain is spreading from the center. By Act III, the grey dominates.
2. **Abandoned watchtowers.** The Monastery of the Vigil was built to watch the northern horizon for threats. The watchtowers are unmanned. Their fires are cold. The threat came from the south, from below, from inside -- everything the monks were not watching for.
3. **Prayer stones with wear patterns.** The monastery's prayer stones are smooth on top from centuries of monks' hands. The wear is deepest on the stones closest to the hearth. Even monks seek warmth.
4. **Grey frost.** During the Interlude, the frost on Highcairn's windows is grey, not white. Natural ice crystals form hexagonal patterns. This frost forms no pattern at all -- it is uniform, smooth, and does not melt when the sun hits it.

### Coastal / Harbor

1. **Unmanned rigs on the horizon.** From Bellhaven's docks, the player can see submersible rigs in the distance. During the Interlude, one has surfaced and drifted to shore -- the Sunken Rig dungeon. Others are visible but dark. No one is going to check on them.
2. **Sable's neighborhood.** In Bellhaven, a district of small houses near the stilts has a burned-out section. No one rebuilt. An NPC mentions a fire years ago. This is where Sable lost everything. She does not comment on it if she is in the party. The silence is the storytelling.
3. **Tide marks.** The high-water mark on Bellhaven's stilts is higher than it used to be. The harbor master's records (examiable prop) show the tide has risen two feet in three years. The ley lines beneath the ocean are destabilizing too.

### Underground / Cavern

1. **Dead miners' faces.** In the Ember Vein, the dead Carradan miners lie in the corridors. Their sprites show no wounds. Their faces are frozen in expressions of despair. This is the player's first encounter with the Pallor's effect, before they have a name for it.
2. **Compact graffiti.** In the Rail Tunnels, workers have scratched messages on the walls near rest stations. Early messages are complaints about pay and hours. Later ones, nearer the Interlude-era breaches, become fragmented and despairing. The last one reads: "it's so heavy."
3. **Boring engine paths.** During the Interlude, the reactivated boring engines have chewed new tunnels in random directions. Some tunnels end abruptly at solid rock, as if the machine just stopped. Others curve back on themselves. The machines are not drilling toward anything -- they are running away from something.

### Ancient Ruins

1. **The recurring sigil.** Every ancient ruin features the Pendulum's sigil -- a simple geometric shape that the player first sees in the Ember Vein, then recognizes in the Ley Line Depths, and finally understands in the Archive of Ages. It is a door. The sigil is a door.
2. **Scale discrepancy.** The doorways in the Archive of Ages are ten times human scale. The pedestals are waist-height. The builders were not larger -- the spaces were built for something to pass through that was not physical. The door again.
3. **The pictographic cycle.** The Archive's wall carvings show the same story repeating across ages: a civilization flourishes, a conduit appears, a host is claimed, a sacrifice closes the door. The art style changes with each age depicted, but the story is always the same. The player is looking at their own story, told by people who lived it before.

### Ashlands

1. **Preserved footprints.** In Ashgrove, the ash preserves every footprint perfectly. Walk through the clearing and the player's own footprints join a thousand years of tribal history. The tracks overlap, layer, and blend into an illegible palimpsest -- except at the council stones, where the paths are clear and deliberate.
2. **The First Tree's roots.** The stump of the First Tree still has roots spreading beneath the ash. They are visible in places where the ash has been disturbed -- dark, petrified, but vast. The tree that burned here was larger than any tree currently standing in the Wilds.
3. **Ash depth.** Near the clearing's center (the First Tree stump), the ash is deeper -- ankle-deep on the player sprite. At the edges, it is thin over bare rock. The fire that killed the First Tree was hottest at the center. A thousand years of ash has not filled the crater.

---

## Time of Day Effects

The game uses four time-of-day states. Each biome has palette shifts that modify the base colors. These are applied as tint overlays or palette swaps, not separate tilesets -- a single tileset per biome with programmatic color adjustment.

### Global Palette Shifts

| Time | Tint | Intensity | Sky Change |
|------|------|-----------|------------|
| **Dawn** | Warm pink-gold (`#E8A878` at 15% opacity) | Soft, low contrast | Sky lightens from dark to pale |
| **Day** | None (base palette) | Full contrast | Sky at base color |
| **Dusk** | Deep amber-red (`#D87848` at 20% opacity) | Warm, shadows lengthen | Sky darkens, orange-red band at horizon |
| **Night** | Cool blue-grey (`#4858A8` at 25% opacity) | Low contrast, shadow-dominant | Sky dark, stars visible in clear biomes |

### Per-Biome Time Effects

#### Valdris Highlands
- **Dawn:** Dew on grass tiles (specular glint). Ley-lamps dim as natural light returns. The warmest, most hopeful the biome ever looks. **Key story use:** Act I opening in Aelhart is set at dawn.
- **Day:** Base palette. Full, green, alive. The player sees this most often in Act I.
- **Dusk:** Long shadows from towers and trees. The gold accent color intensifies. Cael and Lira's romantic flashbacks are set at dusk -- the golden hour of their relationship.
- **Night:** Ley-lamps glow brighter against the dark. The Seven Towers are visible from across the map as points of warm light. **Key story use:** Cael's nightmare scenes are at night. The Carradan assault begins at night.

#### Carradan Industrial
- **Dawn:** The smog catches the sunrise and turns orange-pink. The only beautiful moment in the Compact's day. Workers begin their shifts. **Key story use:** Lira's flashback to leaving Ashmark -- she left at dawn.
- **Day:** Amber-filtered, smoggy. The standard oppressive look.
- **Dusk:** The forge-glow intensifies as natural light fades. Factories are brightest at dusk. The contrast between bright forge and dark street is sharpest.
- **Night:** The forges never stop. Orange light from factory windows. The streets are dark except for Arcanite lamp pools. **Key story use:** Sable's infiltration of Corrund happens at night.

#### Thornmere Deep Forest
- **Dawn:** Filtered light shafts appear (the canopy admits dawn light at low angles). The bioluminescence fades as ambient light rises. Brief, precious, beautiful. **Key story use:** The party's arrival at Roothollow in Act I.
- **Day:** Minimal change from base -- the canopy blocks most direct light. Bioluminescence dims slightly.
- **Dusk:** No visible sunset beneath the canopy. The bioluminescence brightens as ambient light drops. Spirit activity increases.
- **Night:** Full bioluminescence. The forest comes alive with light from below. Spirit creatures are more visible. **Key story use:** Torren's ritual in the Interlude is at night -- he burns his life force, and the forest burns with him.

#### Thornmere Wetlands
- **Dawn:** The fog is thickest at dawn. Visibility drops to 3 tiles. Will-o'-wisps are brightest. **Key story use:** The Fenmother's Hollow dungeon entrance is discovered at dawn.
- **Day:** The fog thins slightly. The flattest, most featureless light. The marsh looks endless.
- **Dusk:** Fog turns amber. The marsh is briefly, eerily beautiful. Insect chorus peaks.
- **Night:** Near-total darkness except for will-o'-wisps. The water reflects nothing -- black and still. **Key story use:** The Duskfen tribe's spirit-binding rituals are performed at night.

#### Mountain / Alpine
- **Dawn:** The snow catches the sunrise and turns pink-gold. The most spectacular dawn in the game -- the entire mountain glows. **Key story use:** Edren's scene at the highland overlook -- he sees the Pallor's spread at dawn, when the contrast between beauty and corruption is sharpest.
- **Day:** Bright, clear, cold. Full visibility. The alpine sky is pale and vast.
- **Dusk:** Alpenglow -- the peaks turn deep red-orange while the valleys are already in shadow. Dramatic, short-lived.
- **Night:** Starfield. The highest locations in the game have the clearest sky. The monastery hearth glows from within. The wind sounds louder at night.

#### Ley Line Nexus
- **Dawn/Dusk:** Minimal change. Ley energy provides its own light. The crystal formations shift color slightly with ambient temperature -- warmer at dawn, cooler at dusk.
- **Day:** Base palette. The ley glow is less visible against bright ambient light.
- **Night:** The nexus is brightest at night. Ley energy pulses are more visible. Crystal formations catch and refract the glow. **Key story use:** The Ley Line Depths are always "night" (underground). The Convergence battle begins at dusk and ends at dawn.

#### Coastal / Harbor
- **Dawn:** Fog burns off the water. Ships emerge from mist. The harbor wakes up -- dock workers, gulls, the first barge departures.
- **Day:** Full maritime light -- bright, hazy, the water glitters.
- **Dusk:** The ocean catches the sunset. Lanterns light along the docks. The harbor settles. **Key story use:** Sable's return to Bellhaven during the Interlude is set at dusk.
- **Night:** Harbor lamps reflect in the water. Ship lights mark the anchorage. The Stilts district is livelier at night (taverns, nightlife).

#### Underground / Cavern
- **No time-of-day variation.** The underground is always the same. This is deliberate -- when the player emerges, the time-of-day contrast hits hard. Entering at day and emerging at night (or vice versa) reinforces the disorientation of going underground.

#### Ancient Ruins
- **No time-of-day variation.** The ruins exist outside time. Their internal light never changes. The dust never settles differently. They are patient.

#### Ashlands
- **Dawn:** The ash catches the first light and turns faintly gold. The most color the Ashlands ever show. **Key story use:** The tribal alliance scene in Ashgrove is set at dawn.
- **Day:** Flat, pale, washed. The ash reflects everything and absorbs nothing.
- **Dusk:** Faint amber tint. The standing stones cast long shadows for the first and only time.
- **Night:** The ash glows faintly grey under starlight. The preserved footprints are visible as darker shadows. The First Tree stump is a dark mass at the center.

#### The Pallor Wastes
- **No time-of-day variation.** The Pallor exists in a permanent, featureless grey that admits no change. There is no dawn. There is no dusk. There is no night because there is no day to contrast it. The grey is absolute. **If the player heals a clearing during Act III** (at save points), the time of day snaps to whatever it would be naturally -- and the contrast is devastating. Color exists. Time exists. Hope exists. Then they leave the clearing and it is grey again.

---

## Pallor Corruption Overlay System

The Pallor does not have its own natural biome until the Wastes of Act III. Instead, it infects existing biomes through a three-stage overlay system that progressively desaturates, distorts, and replaces the base biome's visual identity. This is the game's central visual mechanic -- the world the player explored in Acts I and II is recognizable but wrong when they return in the Interlude.

### Corruption Stages

#### Stage 1: Early Corruption (Subtle)
**When it appears:** Late Act II, early Interlude. The player has to be paying attention.

**Visual effects:**
- Base palette desaturation: 15-20%. Colors are slightly muted, as if the contrast was turned down.
- Grey pixel noise: rare, flickering, at the very edges of the screen. Appears for 1-2 frames then vanishes. The player might think it is a rendering glitch.
- Vegetation shift: 1 in 8 grass/leaf tiles replaced with a slightly yellowed variant. Not dead -- tired.
- Light reduction: ambient light drops 10%. Shadows are 5% darker. Ley-lamps dim.
- Sound: background ambient volume drops 10%. A very faint, nearly inaudible tone appears beneath the music. Most players will not consciously hear it.

**Per-biome manifestation:**
| Biome | Stage 1 Appearance |
|-------|-------------------|
| Valdris Highlands | Grass slightly yellow. One in ten ley-lamps dark. Birds sing less often. |
| Carradan Industrial | Forge-smoke paler. One in ten machines idle. Workers' animation speeds drop slightly. |
| Thornmere Deep Forest | Bioluminescence flickers. One in eight trees has a grey bark patch. Spirit-totems dim. |
| Thornmere Wetlands | Will-o'-wisps pulse irregularly. Water surface is flatter, less reflective. Dead fish appear. |
| Mountain / Alpine | Frost patterns simplify. Wind drops. The silence is heavier. |
| Coastal / Harbor | Tide marks higher. Gull calls less frequent. One offshore rig is dark. |
| Ashlands | Already so muted that Stage 1 is nearly invisible. The ash is slightly greyer. |

#### Stage 2: Mid Corruption (Obvious)
**When it appears:** Interlude proper. The player cannot miss this.

**Visual effects:**
- Base palette desaturation: 40-50%. Colors are visibly drained. The biome's identity is still recognizable but weakened.
- Grey pixel noise: frequent, appearing in 3-5 pixel clusters that linger for several frames. Visible at screen edges and near corrupted features.
- Vegetation death: 1 in 3 tiles replaced with dead/petrified variant. Grey bark. Grey leaves. Grey grass.
- Tile corruption: specific tiles "infected" -- a grey creep spreads from tile edges inward, like frost but colorless. Animated, slow.
- Light: ambient light drops 25%. Shadows deepen significantly. Light sources struggle -- flames gutter, ley-lamps strobe.
- NPC effects: some NPCs stand motionless. Their dialogue is fragmented or repeating. Catatonic residents (Greyvale) have no animation at all -- perfectly still sprites.
- Sound: ambient volume drops 30%. The sub-audible tone is now audible -- a flat, sustained pitch. Music begins to slow, as if the playback speed is dropping.

**Per-biome manifestation:**
| Biome | Stage 2 Appearance |
|-------|-------------------|
| Valdris Highlands | Half the ley-lamps dark. Grass grey-green. Stone walls look older, more weathered. The sky is overcast permanently. Noble houses have barricades -- the capital is fracturing. |
| Carradan Industrial | Machines running on Pallor energy glow grey-white instead of amber. The smog is cleaner but the air feels dead. Workers have stopped complaining -- they have stopped talking. |
| Thornmere Deep Forest | Bioluminescence replaced by grey points of light. Petrified trees visible every few tiles. Spirit creatures are jerky, wrong, aggressive. The forest is fighting back and losing. |
| Thornmere Wetlands | Will-o'-wisps out. Grey light in the fog. Water risen, swallowing lower platforms. The marsh does not smell anymore -- it does not smell like anything. |
| Mountain / Alpine | Grey frost on everything. The frost does not melt. The monastery halls have grey mist in the corridors. Monks report dreams of surrender. |
| Coastal / Harbor | Multiple rigs dark. The tide is wrong -- it does not follow the moon. Dead things wash ashore that are not recognizable as any known creature. |
| Ashlands | The ash is uniformly grey. The standing stones are harder to see -- they are becoming the same color as everything else. Footprints fill in faster, as if the ash is trying to erase memory. |

#### Stage 3: Full Corruption (The Pallor Wastes)
**When it appears:** Act III, within ten miles of the Convergence. Also the theoretical end state of any biome that reaches maximum corruption.

**Visual effects:**
- Base palette replaced entirely by the Pallor Wastes palette (Section 1.11). All original color is gone.
- Grey pixel static is constant, filling 5-10% of the screen at any time. It moves. It watches.
- All vegetation is petrified stone. All water is grey and still. All architecture is drained of identity.
- No NPCs. No wildlife. No ambient life of any kind.
- Light: uniform, directionless grey. No shadows because there is no light source to cast them.
- Sound: the full Pallor soundscape (Section 1.11). Muffled footsteps, static, silence, the sustained tone.

**This stage is only a biome, never an overlay.** Once a location reaches Stage 3, it has its own tileset (the Pallor Wastes) rather than a modified version of the original. The transition between Stage 2 and Stage 3 is the biome transition described in Section 2 -- a 5-tile gradient where the last remnants of color drain away.

### Corruption Timeline by Act

| Act | Corrupted Locations | Stage |
|-----|-------------------|-------|
| **Act I** | None visible. Cael's nightmares are the only hint. | -- |
| **Late Act II** | Wilds overworld (edges nearest the Convergence), Greyvale (border town) | Stage 1 |
| **Interlude (early)** | Roothollow, Duskfen, Greyvale, Highcairn | Stage 1-2 |
| **Interlude (mid)** | All Wilds settlements, Valdris Crown, Millhaven (destroyed), Ashmark (edges) | Stage 2 |
| **Interlude (late)** | The Wilds' center, Corrund (edges), Ashgrove | Stage 2, approaching 3 near Convergence |
| **Act III** | Pallor Wastes (10-mile radius around Convergence at full Stage 3), all other visited locations at Stage 2 | Stage 2-3 |

### Healing (Epilogue)

When Cael closes the door and the Pallor withdraws, the biomes do not revert to their pre-corruption state. They are changed. The SNES tradition of "the world heals" (FF6's World of Balance vs. World of Ruin resolution) is honored but subverted -- healing is not restoration.

**Post-healing visual state per biome:**

| Biome | Healed Appearance |
|-------|------------------|
| **Valdris Highlands** | Green returns, but not the same green. Warmer, wilder -- the manicured lawns are gone. Wildflowers grow where they never did. The ley-lamps do not relight -- Arcanite lanterns (Compact technology) appear alongside them. Hybrid. |
| **Carradan Industrial** | The forges restart, but the smoke is different -- cleaner, the Arcanite glow steadier. The machines run quieter. Cracks in the brick have been left unrepaired, and green shoots grow through them. The Compact is learning to leave space. |
| **Thornmere Deep Forest** | The petrified trees remain as stone monuments among new growth. Bioluminescence returns, brighter than before -- the ley lines are healing, and the forest's light reflects it. Spirit creatures are visible and calm. New species appear that the player has never seen. |
| **Thornmere Wetlands** | The water level has dropped to a new equilibrium. The will-o'-wisps return, but their light is different -- steadier, warmer, amber instead of yellow-green. The Fenmother's shadow is visible again, moving peacefully beneath the surface. |
| **Mountain / Alpine** | The grey frost melts. The natural frost returns with its hexagonal patterns. The monastery hearth burns warmer. From the overlook, the continent is scarred but green -- the Pallor's grey stain replaced by a patchwork of recovering biomes. |
| **Coastal / Harbor** | The tide normalizes. The rigs are not rebuilt -- the offshore extraction is over. The harbor is quieter, smaller, focused on fishing and trade rather than industrial extraction. Bellhaven's stilts district has been partly reclaimed by the sea. |
| **Ashlands** | Ashgrove's ash is still pale, but tiny green shoots appear at the edges of the clearing -- the first growth in a thousand years. The First Tree stump has a single bud. The footprints are still preserved. Nothing is erased. |
| **Ley Line Nexus** | The ley energy stabilizes into something new. The colors are different -- less pure blue and amber, more complex, iridescent, shifting. The energy is alive in a way it was not before. Wild magic drifts like fireflies at the Convergence meadow. |
| **Underground / Cavern** | The Compact tunnels are partly reclaimed by nature -- roots and water. The ancient ruins are unchanged. They were here before the Pallor and will be here after. The sealed door in the Ley Line Depths is still sealed. Some mysteries remain. |
| **The Pallor Wastes** | The Wastes do not exist in the Epilogue. The Convergence is a meadow. The ten-mile radius is recovering -- still scarred (petrified trees standing among new growth) but alive. The static is gone. Sound returns. The first birdsong the player hears in the Wastes' former territory is the most important sound in the game. |

---

## Appendix: Biome-to-Location Quick Reference

| Location | Primary Biome | Secondary Biome | Acts |
|----------|--------------|----------------|------|
| Aelhart | Valdris Highlands | -- | I |
| Valdris Crown | Valdris Highlands | -- | I, II, Interlude |
| Thornwatch | Valdris Highlands | Thornmere Deep Forest (edge) | I, II |
| Greyvale | Valdris Highlands (ruined) | Ashlands (edges) | II, Interlude |
| Highcairn | Mountain / Alpine | -- | Interlude, III |
| Corrund | Carradan Industrial | Underground (Undercroft) | Interlude, III |
| Ashmark | Carradan Industrial | -- | II, Interlude |
| Caldera | Carradan Industrial | Underground (undercity) | II, Interlude |
| Bellhaven | Coastal / Harbor | Carradan Industrial | II, Interlude |
| Ashport | Coastal / Harbor | Carradan Industrial | I-II, Interlude |
| Millhaven | Carradan Industrial | Ley Line Nexus (pit) | II |
| Ironmouth | Carradan Industrial (frontier) | Underground (mine) | I |
| Ironmark Citadel | Carradan Industrial (military) | -- | Interlude |
| Roothollow | Thornmere Deep Forest | -- | I, II, Interlude |
| Duskfen | Thornmere Wetlands | -- | II, Interlude |
| Ashgrove | Ashlands | -- | II, III |
| Canopy Reach | Thornmere Deep Forest (vertical) | -- | II |
| Greywood Camp | Thornmere Deep Forest (open) | -- | II, Interlude |
| Stillwater Hollow | Thornmere Deep Forest | Ley Line Nexus (subtle) | II, Interlude |
| Sunstone Ridge | Ley Line Nexus (amber) | Thornmere Deep Forest | II, Interlude |
| Maren's Refuge | Thornmere Deep Forest | -- | I |
| Windshear Peak | Mountain / Alpine (bare) | -- | II, III |
| Ember Vein | Underground / Cavern | Ancient Ruins | I |
| Fenmother's Hollow | Thornmere Wetlands (submerged) | Underground / Cavern | II |
| Carradan Rail Tunnels | Underground / Cavern (industrial) | -- | II, Interlude |
| Axis Tower | Carradan Industrial (interior) | Underground (lower) | Interlude |
| Ley Line Depths | Underground / Cavern | Ley Line Nexus, Ancient Ruins | II, Interlude |
| Archive of Ages | Ancient Ruins | -- | Interlude |
| Pallor Wastes | The Pallor Wastes | -- | III |
| The Convergence | Ley Line Nexus (extreme) | The Pallor Wastes | III, IV, Epilogue |
| The Pendulum (tavern) | Valdris Highlands / Ashlands (border) | -- | Post-game |
| Dreamer's Fault | Ancient Ruins (corrupted) | The Pallor Wastes | Post-game |
| Dry Well of Aelhart | Underground / Cavern (F1-2), Ancient Ruins (F3-7) | Ley Line Nexus (F7 Wellspring) | Interlude, III |
| Sunken Rig | Coastal / Harbor (industrial) | Underground (interior) | Interlude |
