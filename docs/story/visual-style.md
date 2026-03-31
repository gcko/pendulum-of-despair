# Visual Style Guide -- Pendulum of Despair

This document is the art director's bible for the visual identity of Pendulum of Despair. Every pixel choice, palette decision, and scene composition must serve the emotional arc: a world of color and warmth that drains to grey, then fights its way back to something new. The visual language is 16-bit SNES, not as nostalgia, but as constraint that forces every detail to carry weight.

---

## Table of Contents

1. [Overall Art Direction](#1-overall-art-direction)
2. [Location Visual Profiles](#2-location-visual-profiles)
3. [Overworld Visual Design](#3-overworld-visual-design)
4. [Dungeon Visual Approach](#4-dungeon-visual-approach)
5. [UI Visual Integration](#5-ui-visual-integration)
6. [Signature Scenes](#6-signature-scenes)
7. [Color Script](#7-color-script)

---

## 1. Overall Art Direction

### The Golden Rule

**If it would not work on a Super Nintendo, it does not belong.** Complexity comes from clever palette use, dithering, and careful detail -- not from resolution, layer count, or shader effects. We are building within the aesthetic of 1994, not the technology. The browser renders at higher resolution, but the art itself obeys the old constraints.

### Pixel Density and Tile Grid

- **Tile size:** 16x16 pixels. All terrain, architecture, and environmental tiles are built on this grid.
- **Palette constraint:** 256 colors per scene maximum. Each tileset uses a sub-palette of 16-32 colors. Biome palettes (defined in `biomes.md`) provide the 8-12 dominant tones; individual tiles add accent colors within the 256-color budget.
- **Dithering:** Used for gradients and transparency effects. No smooth alpha blending. Two-color dithering patterns for shadows, fog, and water reflections.
- **Resolution:** The game viewport targets 320x180 pixels (16:9 pixel art standard), integer-scaled to the game window. Clean integer scaling at 720p (4x), 1080p (6x), 1440p (8x), 4K (12x). All art is authored at native resolution. See [accessibility.md](accessibility.md) Section 1.

### Character Sprites

- **Size:** 16x24 pixels (1.5 tiles tall). Characters occupy one tile width and extend half a tile above their ground tile. This matches the FF6 standard and allows characters to feel present without dominating the tileset.
- **Overworld scale:** 8x12 pixels when on the world map. Simplified silhouettes with 2-frame walk cycles.
- **Walk cycle:** 4 directional, 4 frames per direction (16 frames total). Step pattern: stand, left-step, stand, right-step.
- **Idle animation:** 2 frames. Subtle breathing motion or weight shift. Loop every 2 seconds.
- **Battle sprites:** 32x32 pixels. Larger, more detailed. Each character has: idle (2 frames), attack (3 frames), cast (3 frames), hit (2 frames), critical/death (2 frames), victory (3 frames).
- **Color per character:** Each character sprite uses a dedicated 16-color sub-palette. This allows palette swaps for status effects (grey for Pallor influence, blue for ice, red for fire).

### Visual Inspirations

| Source | What We Take | Where It Applies |
|--------|-------------|-----------------|
| **Final Fantasy VI** | Town architecture, dialogue box style, overworld scale, battle UI layout, the concept of a world that breaks and changes | Towns, menus, combat, the World of Ruin parallel |
| **Chrono Trigger** | Cutscene framing, dramatic camera positioning within the tile engine, character expressiveness, dual/triple tech visual coordination | Signature scenes, combo ability effects, story beats |
| **Secret of Mana** | Natural environments -- canopy density, water effects, the feeling of being inside a living forest. The ring menu concept. | Thornmere biomes, nature dungeons, item/ability selection |
| **Final Fantasy IV** | Character-driven pacing, the emotional gut-punch of party loss and reunion, intimate story moments in small rooms | Story structure, the Interlude reunions, Cael's arc |

### Palette Philosophy

The game's color design follows one principle: **color is hope.**

- Act I is saturated and warm. The player is meant to fall in love with these palettes.
- The Pallor's corruption is the systematic removal of color. Desaturation is the enemy.
- In Act III, the party members themselves are the only sources of full color in a grey world. Their sprites refuse to desaturate. Hope is literally the color the player carries.
- The epilogue introduces new colors -- not the old ones restored, but unfamiliar combinations that signal a changed world.

---

## 2. Location Visual Profiles

### Aelhart

**Biome:** Valdris Highlands
**Palette:** Valdris Highlands base -- bright grass `#7DBE6E`, pale limestone `#D6CDB8`, warm wood `#8B6B42`. Accent: wheat gold `#D4A832` from harvest fields, wildflower pink `#D87898`.
**Architecture style:** Wood and stone. Low, spread-out buildings with thatched roofs and timber frames. Garden fences, chicken coops, well-stones. Nothing taller than two stories. The village breathes.
**Signature visual element:** The wheat fields. Golden-amber wheat tiles surround the village on three sides, swaying in a 3-frame animation. No other location has this crop density -- Aelhart feeds Valdris.
**Lighting:** Dawn. The player's first experience of Aelhart is at sunrise, and the warm pink-gold tint (`#E8A878` at 15%) defines the memory. Return visits default to midday.
**Scale:** Small village -- 2-3 screens. A central square, a ring of houses, and surrounding fields.
**Landmark:** A wooden watermill on the river. The overworld sprite shows a tiny wheel turning.
**Interior style:** Rustic warmth. Dark wood floors, woven rugs, hearth fires, hanging herbs. Furniture is handmade -- uneven, charming. Bookshelves in the elder's house. Simple pallets in common homes.
**Parallax layers:** Layer 1 (far): rolling green hills, Valdris Crown visible as distant white towers. Layer 2 (mid): treeline at the village edge. Layer 3 (near): wheat field foreground when at the village boundary.

**Mood board reference:** Mobliz from FF6 (the peaceful village before catastrophe), the opening farm in Chrono Trigger's 1000 AD (the sense of home), the earliest villages in Secret of Mana (sunlit, small, vulnerable).

---

### Valdris Crown

**Biome:** Valdris Highlands (urban variant)
**Palette:** Valdris Highlands base with heavy limestone emphasis -- `#D6CDB8` and `#8A7F6E` dominate. Accent: royal gold `#D4A832` on banners and ley-lamp glow, slate blue `#4A5A7A` on tower roofs, deep green `#2D5A28` in courtyard gardens.
**Architecture style:** Pale limestone, terraced. Buildings rise in rings from the Lower Ward to the Royal Keep. Arched doorways, peaked slate roofs, cylindrical towers (the Seven Towers), covered stone walkways. The architecture says permanence, tradition, and slow decline.
**Signature visual element:** The Seven Towers. Seven cylindrical limestone spires arranged around the city, each with a ley-lamp at its peak. In Act I, they pulse with steady gold light. In Act II, they flicker. In the Interlude, three are dark. The towers are visible from any screen in the city.
**Lighting:** Varies by act. Act I: warm afternoon, golden hour. Act II: late afternoon, shadows lengthening. Interlude: overcast, permanent grey filter muting the greens and golds.
**Scale:** Large city -- 12-15 screens. Court Quarter (3 screens), Citizen's Walk (4 screens), Lower Ward (4 screens), Royal Keep (2-3 screens as interior).
**Landmark:** The Royal Keep at the plateau's summit, flanked by two of the Seven Towers. The overworld sprite shows a white castle silhouette with two tower points and a faint gold glow.
**Interior style:** Tiered by district. Court Quarter: marble floors, tapestries, candelabras, tall windows with colored glass. Citizen's Walk: polished wood, practical furniture, guild insignia on walls. Lower Ward: bare stone, rough wood, oil lamps replacing dead ley-lamps, barracks bunks. Royal Keep: imposing scale, vaulted ceilings, throne room with faded banners.
**Parallax layers:** Layer 1 (far): highland sky with drifting clouds. Layer 2 (mid): distant towers and city roofline (visible from lower wards). Layer 3 (near): banner and vine foreground elements on walls.

**Mood board reference:** Figaro Castle from FF6 (the sense of a kingdom's heart), Guardia Castle from Chrono Trigger (the scale and the throne room), Narshe from FF6 (the tiered city built into terrain -- substitute limestone for mining architecture).

---

### Thornwatch

**Biome:** Valdris Highlands (military variant)
**Palette:** Valdris Highlands base with muted greens -- the forest edge darkens the grass. Accent: iron grey `#5A5A62` from palisade reinforcements, torch amber `#D8A050`, deep forest green `#1A3E22` bleeding in from the Wilds.
**Architecture style:** Timber palisade walls, stone watchtower, military barracks in utilitarian stone. Functional, not beautiful. The fortress was built to hold the Wilds border, and it looks like it.
**Signature visual element:** The forest edge. The south side of Thornwatch abuts the Thornmere Deep Forest. The tree line is visible from every screen -- massive dark trunks rising above the palisade, branches reaching over the walls. The Wilds are always watching.
**Lighting:** Late afternoon, amber-tinted. Torches on the walls even during the day -- the soldiers are vigilant. At night, the torchlight against the dark forest line is the dominant visual.
**Scale:** Small fortress town -- 3-4 screens. The garrison, the wall perimeter, a small civilian area with an inn and provisioner.
**Landmark:** The central watchtower, three stories of stone rising above the palisade. The overworld sprite shows a single tower point behind a dark tree line.
**Interior style:** Military. Barracks bunks, weapon racks, strategic maps on tables, a commander's office with a desk buried in reports. The inn is the only warm space -- rough but welcoming, with a fire.
**Parallax layers:** Layer 1 (far): highland hills receding north. Layer 2 (mid): palisade wall and watchtower silhouette. Layer 3 (near): forest canopy pressing in from the south edge.

**Mood board reference:** South Figaro's occupation scenes from FF6 (a town under military pressure), the Zenan Bridge area from Chrono Trigger (a frontier fortification), the early forest-edge camps from Secret of Mana.

---

### Highcairn

**Biome:** Mountain / Alpine
**Palette:** Alpine base -- snow `#E8E4E0`, shadow-snow `#B0B8C8`, exposed rock `#8A8A8A`, weathered monastery stone `#9A9088`. Accent: hearth amber `#D89848` from windows, deep shadow blue `#2A2838`, hardy pine `#2E4A38`.
**Architecture style:** Thick-walled stone monastery. Narrow windows, heavy doors, slate roofs weighted against wind. The Monastery of the Vigil is austere -- no ornament, no color, just hand-cut stone blocks and iron hardware. The village below is barely a cluster: stable, provisioner, healer, a few homes of rough stone.
**Signature visual element:** The highland overlook. A flat stone promontory extending from the monastery, offering a panoramic view of the continent below. During the Interlude, the player sees the grey stain spreading from this vantage. No other location provides this scale of visual storytelling.
**Lighting:** Cold and bright. Alpine sunlight is sharp and shadowless on snow, with deep blue-black shadows in crevices. Interior lighting is the stark contrast: warm hearth amber against cold stone grey. The monastery's great hall hearth has not gone cold in two centuries.
**Scale:** Small town -- 2-3 screens. The monastery itself is an additional 3-4 screens of interior (dungeon during the Interlude).
**Landmark:** The monastery bell tower, visible against a snow-capped peak. The overworld sprite shows a simple stone building with a cross-shaped tower against white mountain.
**Interior style:** Ascetic. Bare stone walls, prayer stones worn smooth, narrow cells with sleeping pallets, a great hall dominated by a single massive hearth. Weapon racks alongside prayer beads -- this is a martial order. Iron candelabras, no tapestries, no ornament except the Vigil's sigil carved above doorways.
**Parallax layers:** Layer 1 (far): vast alpine sky, clouds below the player's elevation. Layer 2 (mid): snow-capped peaks, pine treeline at lower altitude. Layer 3 (near): blowing snow particles, wind-streaked.

**Mood board reference:** Narshe's snowy cliffs from FF6 (the opening march, the cold isolation), the End of Time's austerity from Chrono Trigger (a place stripped to essentials), the ice palace approach from Secret of Mana (wind, exposure, elevation).

---

### Corrund

**Biome:** Carradan Industrial
**Palette:** Carradan Industrial base -- brick `#A86B4E`, soot-stained `#6B3E2A`, structural iron `#5A5A62`, forge glow `#E88830`. Accent: brass `#C49840` on Forgewright detailing, Arcanite blue-white `#82B8D4` from engine housings, canal water `#5A6858`.
**Architecture style:** Vertical. Iron bridges span canals at three elevations. Factory spires with sawtooth roofs pierce the smog. The Axis Tower at the city center is glass and iron, gleaming. Beneath the bridges: the Undercroft, where tenement stacks lean against each other and steam vents into narrow streets. Architecture tells the class story -- wider streets, glass windows, and brass fittings as you ascend; narrow alleys, no windows, and rust as you descend.
**Signature visual element:** The Axis Tower. A gleaming spire of iron and glass at the city's center, with a visible Arcanite glow at its core. It dominates the skyline from every screen. During the Interlude, its glow shifts from amber to grey-white -- the first sign that the Compact's engines are drawing on Pallor energy.
**Lighting:** Amber-filtered through permanent smog. Natural sunlight never reaches the streets unaltered. The forge glow from factory windows provides warm orange pools against dark iron. The Undercroft is lit only by Arcanite lamps -- harsh white-blue, creating sharp shadows.
**Scale:** Large city -- 12-15 screens. Upper Districts (3 screens), Canal Level (4 screens), Undercroft (3-4 screens), Axis Tower approach and interior (3-4 screens).
**Landmark:** The Axis Tower, unmistakable. The overworld sprite shows a single tall spire with an orange glow point, wreathed in smoke.
**Interior style:** Upper Districts: glass-fronted merchant halls, polished brass fixtures, mechanical displays, leather furniture. Canal Level: workshops with tool racks, soot on every surface, functional metal furniture. Undercroft: stacked bunks, improvised walls, stolen Arcanite lamp-fragments for light, damp. Axis Tower: precision engineering -- clean metal surfaces, embedded gauges, the hum of machinery in every wall.
**Parallax layers:** Layer 1 (far): smog layer with chimney stacks breaking through. Layer 2 (mid): bridge silhouettes and factory rooflines. Layer 3 (near): steam vents, sparks from welding, pipe clusters.

**Mood board reference:** Narshe's industrial sectors from FF6 (the mine carts, the gears, the vertical terrain), the Factory ruins from Chrono Trigger's 2300 AD (the oppressive scale of machinery), Vector's imperial city from FF6 (power concentrated in architecture).

---

### Ashmark

**Biome:** Carradan Industrial (heavy industrial variant)
**Palette:** Carradan Industrial base with darker values -- `#6B3E2A` dominant over `#A86B4E`. Heavier soot `#2E2824`, rust `#8A4A2E`. Accent: forge-red `#C84830` from the Black Forges, brass `#C49840` on the Founders' Hall, ember orange `#E88830` in furnace mouths.
**Architecture style:** Dense, heavy, industrial to the extreme. The Black Forges are multi-story brick foundries with open furnace mouths visible from the streets. Conveyor belts cross between buildings at upper levels. The Founders' Hall is the exception -- older, grander, with mechanical prayer wheels and brass ornamentation. The rest of the city serves the Forges.
**Signature visual element:** The Black Forges themselves -- open furnace mouths glowing red-orange, visible from any screen as rectangular voids of heat and light in the dark brick walls. Animated: the glow pulses with a 4-frame breathing cycle, as if the forges are alive.
**Lighting:** Dark amber through dense smoke. Ashmark is the smokiest city in the game. Visibility is reduced compared to Corrund. The forge-red glow is the primary light source on many screens, casting everything in a hellish warmth.
**Scale:** Medium city -- 6-8 screens. The Black Forges district (3 screens), the Founders' Hall and market (2 screens), worker housing (2-3 screens).
**Landmark:** The largest Black Forge chimney, belching dark smoke. The overworld sprite shows a cluster of chimney stacks with a red glow at their base.
**Interior style:** Foundry interiors: massive scale, catwalk walkways over molten metal, the heat visible as shimmer distortion. Founders' Hall: the oldest building, polished brass, mechanical prayer wheels (stopped), display cases with historical artifacts. Worker housing: identical to Corrund's Undercroft but drier -- the soot is the problem here, not damp.
**Parallax layers:** Layer 1 (far): smoke layer, thicker than Corrund's, with red-orange glow bleeding through from below. Layer 2 (mid): chimney stacks and conveyor bridges. Layer 3 (near): ember particles drifting upward, soot flakes falling.

**Mood board reference:** The Magitek Factory from FF6 (the industrial horror, the conveyor belts, the sense of something being consumed), the Proto Dome ruins from Chrono Trigger (machinery as environment), the fire palace from Secret of Mana (heat as atmosphere).

---

### Caldera

**Biome:** Carradan Industrial (volcanic basin variant)
**Palette:** Carradan Industrial base pushed warmer -- brick `#A86B4E` gives way to volcanic red-brown `#8A4A2E`. Ground is darker `#3A2818`. Accent: deep forge-red `#C83020`, molten orange `#E8A030`, steam white `#C8C0B0`. The volcanic substrate makes everything warmer and more dangerous.
**Architecture style:** Tiered bowl. Caldera is built into a volcanic basin, descending in rings toward the central smelting complex. Buildings are squat, heat-resistant brick with metal shutters. The deeper you go, the hotter it gets. Architecture reflects function -- venting systems, heat exchangers, and insulated walls.
**Signature visual element:** The central smelting pit. At the lowest tier, a massive open-air smelting operation sits over volcanic vents. Molten metal rivers flow in channels visible from surrounding tiers. Animated: flowing molten metal tiles in amber-red, 6-frame cycle, with steam rising.
**Lighting:** Hot. Everything has a red-orange undertone. Even shadows are warm. The sky above the caldera basin is permanently hazy with heat distortion and sulfur-yellow clouds.
**Scale:** Medium city -- 6-8 screens. Upper rim (2 screens), middle tiers (3 screens), central smelting floor (2-3 screens).
**Landmark:** The caldera basin itself -- a depression visible on the overworld as a dark circle with red-orange glow. The overworld sprite shows a bowl shape with heat shimmer.
**Interior style:** Functional industrial. Metal furniture bolted to floors. Heat-resistant curtains instead of doors. The undercity tavern is the only space with any comfort -- cool stone, deep underground, the one place where the heat relents.
**Parallax layers:** Layer 1 (far): caldera rim with sulfur clouds. Layer 2 (mid): tiered city architecture descending. Layer 3 (near): heat shimmer distortion, rising steam, ember particles.

**Mood board reference:** The burning house scene from FF6 (fire as environmental constant), the Lavos eruption scenes from Chrono Trigger (volcanic devastation made habitable), the fire palace interior from Secret of Mana (living in heat).

---

### Bellhaven

**Biome:** Coastal / Harbor (blended with Carradan Industrial)
**Palette:** Coastal base -- ocean deep `#2A4868`, shallow `#4A7888`, dock wood `#7A6848`, sand `#C8B898`. Accent: Carradan brick `#A86B4E` on warehouse walls, lantern gold `#E8C868`, sail white `#D8D0C0`, salt-rust `#9A5838`.
**Architecture style:** Stilt buildings over tidal flats, connected by wooden walkways and rope bridges. Merchant manors on higher ground use stone and brick. The harbor itself is a mix of wooden piers and Carradan ironwork -- cranes, chain pulleys, ironclad hulls alongside fishing boats. Architecture gets rougher and more improvised toward the Stilts district.
**Signature visual element:** The stilts. Entire neighborhoods raised on wooden pilings over the tidal zone. The water moves beneath them -- visible through gaps in the planking. At high tide, the lower walkways are submerged. At low tide, the exposed mud and barnacled pilings tell the harbor's age.
**Lighting:** Hazy maritime light. Bright but diffused through salt air. The sun glitters on water. At dusk, harbor lanterns reflect in the ocean surface -- warm gold points on dark blue water. This is the most atmospherically varied city in the game due to tide and weather cycles.
**Scale:** Medium-large city -- 8-10 screens. Harbor district (3 screens), merchant quarter (2-3 screens), Stilts district (3 screens), dockside markets (1-2 screens).
**Landmark:** The lighthouse at the harbor mouth. The overworld sprite shows a stilt-town silhouette with a lighthouse point and tiny ship sprites at anchor.
**Interior style:** Harbor buildings: salt-weathered wood, rope-and-pulley hardware, nautical charts on walls, crate-and-barrel storage. Merchant manors: polished wood, imported Valdris tapestries, glass-paned windows with ocean views. Stilts district: improvised -- driftwood walls, net curtains, everything salvaged.
**Parallax layers:** Layer 1 (far): ocean horizon, distant ships, haze. Layer 2 (mid): harbor masts and crane silhouettes. Layer 3 (near): wave spray, gull sprites, hanging nets.

**Mood board reference:** South Figaro's port from FF6 (the commercial bustle, the class divide between wealthy and working), the Porre harbor from Chrono Trigger (maritime town), the coastal sections of Secret of Mana (water as ever-present).

---

### Millhaven

**Biome:** Carradan Industrial (extraction variant)
**Palette:** Carradan Industrial base desaturated toward exhaustion -- ground `#4A4038` dominant. Accent: Millglow blue-white `#82B8D4` from the open pit, rust `#8A4A2E` on abandoned equipment, sick yellow-green `#A8A848` from ley contamination.
**Architecture style:** Temporary made permanent. Prefab metal buildings, pumping stations, worker barracks in rows. The infrastructure was built for extraction, not habitation, then people had to live here anyway. The open pit dominates -- everything radiates outward from its edge.
**Signature visual element:** The Millglow. The open extraction pit emits a faint blue-white glow from exposed ley line substrate. Visible from everywhere in town. The glow reflects off the permanent smog, creating an eerie halo. Workers' hands tremble (animated sprite detail).
**Lighting:** Flat industrial light during the day, Millglow blue-white at night. No warmth in this town. Even the forge glow is absent -- Millhaven extracts, it does not manufacture.
**Scale:** Small town -- 3-4 screens. The pit edge (1 screen), worker barracks and town (2 screens), pumping station (1 screen).
**Landmark:** The pit. A dark depression on the overworld with a blue-white glow point. The overworld sprite is unmistakable -- a hole in the ground, glowing.
**Interior style:** Utilitarian. Metal bunk frames, no decoration. Management buildings have glass and brass -- a few screens of relative comfort overlooking the pit. The contrast is the story.
**Parallax layers:** Layer 1 (far): Compact smog layer, pale. Layer 2 (mid): pumping station silhouettes, crane arms. Layer 3 (near): Millglow particles drifting upward from the pit edge.

**Mood board reference:** The Magitek Research Facility from FF6 (extraction as moral horror), the Arris Dome from Chrono Trigger's 2300 AD (a community defined by what is beneath them), the underground palace from Secret of Mana (the glow of something that should be left alone).

---

### Roothollow

**Biome:** Thornmere Deep Forest
**Palette:** Thornmere Deep Forest base -- canopy `#2E6B3A`, trunk `#4A3A2E`, ground `#2A3A28`, bioluminescence `#68D8B8`. Accent: heartwood warm brown `#6B4A30` from carved root architecture, spirit purple `#B088D8` from totems, filtered light gold-green `#A8C878`.
**Architecture style:** Organic. Buildings are carved from and grown within the root systems of massive trees. Root-chamber interiors with natural archways. No straight lines -- everything curves and breathes. Spirit-totems at intersections glow purple. Vine bridges connect platforms at different levels.
**Signature visual element:** The root chambers. Entire rooms hollowed from living root masses, with bark-textured walls and bioluminescent moss providing ambient light. The architecture is alive -- root tendrils continue to grow, requiring maintenance paths.
**Lighting:** Bioluminescent. Teal-green light from moss and fungi on every surface. Spirit-totems add purple glow at key points. Rare shafts of filtered gold-green sunlight break through the canopy overhead. The overall effect is an underwater cathedral.
**Scale:** Medium settlement -- 5-6 screens. Central root-chamber (2 screens), residential chambers (2 screens), spirit shrine and council grove (1-2 screens).
**Landmark:** The great root arch -- a natural archway formed by two massive tree roots meeting overhead at the settlement entrance. The overworld sprite shows a green mound with a teal glow point.
**Interior style:** Living wood. Walls are bark and root. Furniture is carved heartwood -- smoothed but organic. Sleeping pallets on woven reed. Spirit-wards hang from root ceilings. Herb baskets and carved wood bowls. No metal. No glass. Everything the forest provides.
**Parallax layers:** Layer 1 (far): deep canopy shadow, near-black. Layer 2 (mid): massive trunk silhouettes and root archways. Layer 3 (near): bioluminescent moss points, drifting spores, spirit motes.

**Mood board reference:** The Phantom Forest from FF6 (the sense of a living, watching environment), the Mystic Mountains from Chrono Trigger (ancient forest with spirit presence), the Mana Tree canopy from Secret of Mana (nature as architecture, bioluminescence as warmth).

---

### Duskfen

**Biome:** Thornmere Wetlands
**Palette:** Thornmere Wetlands base -- marsh water `#3A4A38`, reed `#7A8A48`, mud `#5A4A38`, fog `#A8A898`. Accent: wisp light `#C8D858`, wet wood `#4A3E30`, rope `#8A7A5A`, spirit-binding blue `#58A8C8`.
**Architecture style:** Reed-woven platforms raised on wooden pilings above the marsh. Rope bridges connect platforms. Everything is temporary, designed to be rebuilt after floods. Spirit-binding totems mark platform edges -- carved wood with inlaid ley-stone that glows faintly blue. The construction is practical and beautiful in its impermanence.
**Signature visual element:** The fog. Duskfen is never fully visible. Fog scrolls through the scene as a semi-transparent animated layer, thickening and thinning. Platforms and buildings emerge from and disappear into the mist. Will-o'-wisps are the brightest points, drifting through the fog as mobile light sources.
**Lighting:** Flat, diffused through permanent fog. No directional shadows. Will-o'-wisps provide the only focused light -- warm yellow-green spheres that drift on 8-frame animation loops. Spirit-binding totems add cold blue points. The overall effect is dreamlike and uncertain.
**Scale:** Small settlement -- 3-4 screens. Central platform cluster (2 screens), outer platforms and fishing areas (1-2 screens).
**Landmark:** The spirit-binding workshop -- a large platform with a distinctive circular structure and blue glow. The overworld sprite shows a cluster of small points (platforms) in a green-brown marsh with wisp lights.
**Interior style:** Reed and rope. Woven walls that move in wind. Spirit-binding tools -- carved stones, ley-infused cords, offering bowls. Sleeping areas are hammocks. The tribe elder's platform has a spirit-totem circle used for communion rituals. Everything smells damp (implied by moss on every surface, water stains on rope).
**Parallax layers:** Layer 1 (far): fog bank, featureless. Layer 2 (mid): distant reed beds, will-o'-wisp lights floating. Layer 3 (near): fog wisps, dripping water particles, reed tips swaying.

**Mood board reference:** The Phantom Forest's depths from FF6 (the fog, the uncertainty, the sense of being watched), the Cursed Woods from Chrono Trigger (nature hostile and uncertain), the swamp areas of Secret of Mana (water underfoot, danger below the surface).

---

### Ashgrove

**Biome:** Ashlands
**Palette:** Ashlands base -- light ash `#D8D0C0`, mid ash `#B8B0A0`, dark ash `#8A8478`. Accent: charcoal `#4A4440`, standing stone grey `#6A6A68`, ember memory `#D8A868` (a faint warmth in the soil where the First Tree burned). The most monochrome non-Pallor palette in the game.
**Architecture style:** None permanent. Temporary shelter frames for tribal gatherings -- wood poles and hide canopies, removable. The standing stones are the only permanent structures: ancient, weathered, arranged in a council circle around the First Tree stump. This is a place of pilgrimage, not habitation.
**Signature visual element:** The First Tree stump. A massive, charred stump at the clearing's center, roots spreading beneath the ash. In the epilogue, a single green bud appears on the stump. It is the most important tile in the game's final hours.
**Lighting:** Flat, overcast, directionless. The ash reflects ambient light uniformly. No shadows in default state. At dawn, a faint gold tint reveals the standing stones' long shadows for the first and only time -- the tribal alliance scene uses this lighting.
**Scale:** Small -- 2-3 screens. The clearing with the First Tree stump and standing stones (1-2 screens), the surrounding ashfield (1 screen).
**Landmark:** The First Tree stump and the standing stone circle. The overworld sprite shows a pale clearing surrounded by dark forest, with a dark point at center.
**Interior style:** N/A -- no permanent interiors. The temporary shelter frames have hide walls, fire pits, and tribal artifacts laid on ash.
**Parallax layers:** Layer 1 (far): pale, featureless sky. Layer 2 (mid): distant petrified tree trunks, standing stones emerging from ash. Layer 3 (near): ash particles drifting when the player moves.

**Mood board reference:** The World of Ruin's empty fields from FF6 (the absence that tells the story), Lavos's aftermath from Chrono Trigger's 1999 AD (desolation as setting), the burned Mana village from Secret of Mana (what fire leaves behind).

---

### Canopy Reach

**Biome:** Thornmere Deep Forest (vertical variant)
**Palette:** Thornmere Deep Forest base with more sky exposure -- lighter canopy `#2E6B3A` gives way to open sky blue `#88C8E8` at the highest platforms. Accent: rope tan `#8A7A5A`, flower pink `#D868A8` from canopy blooms, warm bark `#6B5A40`.
**Architecture style:** Treetop platforms and rope bridges. The settlement is built entirely in the canopy -- 60-100 feet above the forest floor. Wooden platforms lashed to massive branches, connected by rope-and-plank bridges. Larger platforms support communal structures. The construction is lighter and airier than Roothollow's root chambers.
**Signature visual element:** The open canopy. Unlike the rest of the Thornmere, Canopy Reach breaks through the top of the forest. The player can see sky. After hours of bioluminescent twilight below, the sunlight is startling and beautiful.
**Lighting:** Dappled sunlight through leaves. The brightest location in the Thornmere. Shafts of gold-green light (`#A8C878`) alternate with deep canopy shadow. At night, the combination of bioluminescence below and starfield above creates a unique dual-light effect.
**Scale:** Small settlement -- 3-4 screens. Horizontal movement is limited; vertical layering provides depth through overlapping platforms.
**Landmark:** The tallest tree's crown, where a lookout platform extends above the canopy. The overworld sprite shows a cluster of tree crowns with tiny platform details.
**Interior style:** Open-air. Most structures have no walls -- just roofs of woven fronds. Rope hammocks, hanging supply baskets, lookout perches. The tribe here values sight lines and freedom of movement.
**Parallax layers:** Layer 1 (far): sky with clouds, visible through canopy breaks. Layer 2 (mid): overlapping branch and leaf layers at multiple depths. Layer 3 (near): close leaves, rope bridge rails, hanging vine curtains.

**Mood board reference:** The Ioka village from Chrono Trigger's Prehistory (open-air living, elevated platforms), the Mana Tree's upper branches from Secret of Mana (the canopy as world), the opera house catwalks from FF6 (verticality as design language).

---

### Ironmouth

**Biome:** Carradan Industrial (frontier variant)
**Palette:** Carradan Industrial base thinned out -- less brick, more raw ground `#4A4038`. Forest green `#2E6B3A` encroaching from edges. Accent: prefab metal grey `#5A5A62`, torch amber `#D8A050`, fresh-cut timber `#8B7B52`.
**Architecture style:** Prefab. Small-scale Compact construction at the forest edge. Metal-walled buildings that were shipped in pieces and assembled. Mining infrastructure (shaft heads, ore carts, sluice channels) at the forest boundary. The architecture is functional, temporary, and visibly encroaching on the Wilds.
**Signature visual element:** The mining markers nailed to trees. Compact survey tags on the forest edge -- small metal rectangles on tree bark. The visual tension between industrial metal and living forest defines this town.
**Lighting:** Mixed. Compact Arcanite lamps on the town side, forest bioluminescence on the other. The two light temperatures -- harsh white-blue and soft teal -- meet at the town perimeter. Neither wins.
**Scale:** Small -- 2-3 screens. The mining camp, a few buildings, the forest edge.
**Landmark:** The mine shaft entrance at the forest border. The overworld sprite shows a small metal-roofed settlement against a dark tree line.
**Interior style:** Spartan. Metal bunks, equipment lockers, a mess hall with long benches. The foreman's office has maps and extraction yield reports pinned to walls. A single tavern attempts warmth with a brick hearth in a metal building.
**Parallax layers:** Layer 1 (far): Compact smoke on one side, deep forest on the other. Layer 2 (mid): mine shaft scaffolding, forest tree trunks. Layer 3 (near): ore cart tracks, survey markers on trees.

**Mood board reference:** Kohlingen from FF6 (a small town at a border), the earliest Narshe exteriors from FF6 (mining town simplicity), the Dwarf Village entrance from Secret of Mana (industrial meets natural).

---

### Ashport

**Biome:** Coastal / Harbor (blended with Carradan Industrial)
**Palette:** Coastal base with heavier industrial accent. Ocean `#2A4868`, dock `#7A6848`, iron `#68686E`, Compact brick `#A86B4E`. Accent: weapons-test flash white `#E8E0D0`, rust `#9A5838`, smoke grey `#7A7068`.
**Architecture style:** Military-industrial port. Ironclad ship hulls at dock. Weapons testing ranges extend beyond the harbor on breakwater platforms. Warehouses are reinforced with iron plating. The civilian harbor is a thin strip between military installations.
**Signature visual element:** The testing ranges. Beyond the harbor, distant platforms periodically flash with weapons testing -- visible as brief white flashes and delayed sound rumbles. The war machine is always visible on the horizon.
**Lighting:** Maritime light filtered through Compact smog. Harsher than Bellhaven -- the industrial bleed is heavier here. Weapons test flashes strobe intermittently, breaking the ambient light.
**Scale:** Medium -- 5-6 screens. Military harbor (2 screens), civilian strip (2 screens), testing range approach (1-2 screens).
**Landmark:** The weapons platform on the breakwater. The overworld sprite shows a harbor with smoke and a flash point on the water.
**Interior style:** Military port: reinforced walls, locked doors, Compact insignia everywhere. Civilian strip: taverns and traders catering to military personnel -- rougher than Bellhaven's merchant quarter.
**Parallax layers:** Layer 1 (far): ocean horizon with distant weapon flash. Layer 2 (mid): ironclad ship masts, crane silhouettes. Layer 3 (near): smoke, sea spray, chain links.

**Mood board reference:** Vector's harbor from FF6 (military-industrial maritime), the Future ruins' coastal sections from Chrono Trigger (technology at the water's edge).

---

### Gael's Span

**Biome:** Thornmere Deep Forest / Carradan Industrial (contested border)
**Palette:** A forced marriage of biomes. Forest green `#2E6B3A` on one side, Compact iron `#5A5A62` on the other. Bridge stone `#8A7F6E` (neutral). Accent: torch amber `#D8A050`, flag colors from both factions.
**Architecture style:** A massive stone bridge spanning the Corrund River's upper reach, connecting Valdris-allied forest territory to Compact-controlled industrial zones. Guard posts on both ends. The bridge itself is old -- built before the current conflict, neutral stone, wide enough for merchant caravans. The guard posts are newer, factional, hostile.
**Signature visual element:** The bridge itself -- wide, ancient, stone-arched, spanning a deep river gorge. Two different flag types on opposite ends. The visual split down the middle is literal: forest tiles on one side, industrial tiles on the other.
**Lighting:** Depends on which end the player approaches from. Forest side: filtered green. Industrial side: amber smog. The bridge midpoint is natural daylight -- a brief, neutral clarity between two visual worlds.
**Scale:** Small -- 2-3 screens. The bridge and its immediate approaches.
**Landmark:** The bridge arches over the gorge. The overworld sprite shows a thin line crossing a river with two different-colored flags.
**Interior style:** Guard post interiors only. Spartan, factional decor. Forest side: wood and woven reed, Wilds tribal artifacts. Industrial side: metal and brick, Compact insignia, weapon racks.
**Parallax layers:** Layer 1 (far): river gorge beneath the bridge, visible through gaps. Layer 2 (mid): forest canopy on one horizon, factory smoke on the other. Layer 3 (near): flag banners, bridge railing detail.

**Mood board reference:** The Zozo bridge from FF6 (a crossing point between worlds), the Zenan Bridge from Chrono Trigger (a contested crossing, factional), the bridge scenes from Secret of Mana (dramatic parallax over a chasm).

---

### Kettleworks

**Biome:** Carradan Industrial (research variant)
**Palette:** Carradan Industrial base with more brass `#C49840` and Arcanite blue `#82B8D4`. Cleaner than Ashmark -- the research facilities are maintained. Accent: glass reflection `#C8D8E8`, copper `#B87840`, precision steel `#7A7A82`.
**Architecture style:** Research campus. Cleaner, more precise than standard Compact architecture. Glass-roofed laboratories, precision workshops with brass instruments, prototype testing halls. The buildings have a sense of purpose that Ashmark's factories lack -- these are places where people think, not just produce.
**Signature visual element:** The glass roofs. Several buildings have transparent glass-panel roofs that reveal the interiors from outside -- visible Arcanite engines, glowing prototype devices, the visual language of science rather than industry.
**Lighting:** Brighter than other Compact cities. The glass roofs let in natural light (filtered through smog, but brighter than Corrund). Arcanite lamps here are precise and clean, not the harsh pools of the Undercroft.
**Scale:** Small-medium -- 4-5 screens. Research campus (3 screens), worker housing (1-2 screens).
**Landmark:** The main laboratory dome -- a glass-and-brass hemisphere. The overworld sprite shows a bright point (the dome's glint) amid smaller buildings.
**Interior style:** Laboratory: clean metal surfaces, glass instruments, prototype devices on stands, chalkboards with equations. Workshops: precision tools, magnifying apparatus, blueprints pinned to walls. A marked contrast to the rough utility of other Compact interiors.
**Parallax layers:** Layer 1 (far): Compact smog, lighter here. Layer 2 (mid): laboratory roofline, dome silhouette. Layer 3 (near): Arcanite glow particles, brass reflections.

**Mood board reference:** The Magitek Research Facility's cleaner areas from FF6 (the science behind the industry), the Keeper's Dome from Chrono Trigger (knowledge preserved in technology).

---

## 3. Overworld Visual Design

### Map Style

The overworld uses a miniaturized tileset that reads like a painted relief map -- the kind that came folded in the box of a 1994 SNES RPG. Terrain is simplified to chunky color blocks with clear biome boundaries. Think FF6's Mode 7 overworld: the ground has a slight perspective tilt, terrain features are iconic rather than detailed, and the player character is an 8x12 pixel sprite moving across a world that feels vast. See [overworld.md](overworld.md) for traversal mechanics.

The **pause-menu map screen** (a Plus Enhancement per [overworld.md](overworld.md)) uses a static parchment aesthetic -- warm cream background, irregular pixel-edge coastlines and terrain (hand-drawn feel within pixel art constraints, not smooth curves), ink-style location labels. Consistent with SNES-era game manual fold-out maps translated into in-game pixel art.

### Overworld Tile Language

| Terrain | Visual | Color Range |
|---------|--------|-------------|
| Valdris grassland | Rounded green tiles, gentle contour lines | `#7DBE6E` to `#4E8A3F` |
| Carradan plains | Flat brown-grey tiles, quarry marks, road networks | `#4A4038` to `#6B3E2A` |
| Thornmere forest | Dense dark green canopy tiles, no ground visible | `#1A3E22` to `#2E6B3A` |
| Thornmere wetland | Murky green-brown with water patches | `#3A4A38` to `#5A4A38` |
| Mountain | Jagged grey-white peaks, snow at summits | `#8A8A8A` to `#E8E4E0` |
| Ocean | Deep blue with 2-frame wave animation | `#2A4868` to `#4A7888` |
| River | Thin blue line, 2-frame flow animation | `#4A8CB8` |
| Ashlands | Pale cream patches amid dark forest | `#D8D0C0` to `#B8B0A0` |
| Roads | Thin brown/grey lines connecting towns | `#B8A882` to `#5A5A62` |

### Town Overworld Sprites

Each town has a unique overworld icon (16x16 or 16x24 pixels) that communicates its identity at a glance:

| Town | Overworld Sprite |
|------|-----------------|
| Aelhart | Small cluster of brown roofs, watermill wheel |
| Valdris Crown | White castle silhouette, two tower points, gold glow |
| Thornwatch | Single stone tower behind dark palisade line |
| Highcairn | Stone building with cross-shaped bell tower on white peak |
| Corrund | Tall iron spire (Axis Tower), orange glow, smoke wreath |
| Ashmark | Chimney stack cluster, red forge glow at base |
| Caldera | Dark bowl depression, red-orange heat glow |
| Bellhaven | Stilt-town silhouette, lighthouse point, tiny ships |
| Ashport | Harbor with smoke, flash point on water |
| Millhaven | Dark pit depression, blue-white glow point |
| Roothollow | Green mound, teal bioluminescent glow |
| Duskfen | Small platform cluster in marsh, wisp lights |
| Ashgrove | Pale clearing in dark forest, dark center point |
| Canopy Reach | Cluster of tree crowns with tiny platform details |
| Ironmouth | Small metal roofs against dark tree line |
| Gael's Span | Thin bridge line over river, two colored flags |
| Kettleworks | Bright dome glint among small buildings |

### Cloud and Fog Layer

A semi-transparent cloud layer scrolls across the overworld at a constant slow speed (1 pixel per 4 frames). Clouds are white-grey sprites that partially obscure terrain beneath them. In the Wilds, a second fog layer (green-grey, lower, thicker) reduces visibility, communicating the forest's density.

**Cloud behavior by act:**
- **Act I:** Sparse white clouds. The world is open and inviting.
- **Act II:** Clouds thicken. The Wilds fog darkens. A faint grey tinge enters the cloud palette near the Convergence.
- **Interlude:** Heavy cloud cover. The Wilds are barely visible through fog. Grey clouds spread outward from the continent's center.
- **Act III:** Near-total cloud cover. The Pallor Wastes are visible as a featureless grey region with no terrain detail -- the clouds merge with the ground.
- **Epilogue:** Clouds break. Sunlight falls on the recovering continent. The Convergence meadow is a bright green point where grey used to be.

### Overworld Progression: The Green-to-Grey Arc

The overworld is the player's macro-level emotional barometer. The same map is used throughout the game, but its appearance changes dramatically:

**Act I:** Rich, saturated. Valdris is emerald, the Wilds are deep green, the Compact is warm amber. Rivers sparkle. The ocean is alive.

**Act II:** Subtle shifts. The Wilds' center darkens. A faint discoloration appears near the Convergence (1-2 tiles of grey-tinted green). The Compact's smoke thickens.

**Interlude:** The grey stain is visible and growing. A 10-tile radius of desaturated terrain around the Convergence. The Wilds' green is muted. Valdris's green is yellowing at the edges. The overworld music slows.

**Act III:** The Pallor Wastes dominate the center. A 30-tile radius of featureless grey. Surrounding biomes are visibly drained. Only the far edges of the continent retain their original color. The player sees what they are fighting for.

**Epilogue:** New colors. Not the old map restored -- a different palette. Warmer in some places, wilder in others. The Convergence is a bright meadow. Scars remain (petrified tree patches, rubble where walls fell) but life is returning. The overworld is changed but alive.

---

## 4. Dungeon Visual Approach

### Natural Caves (Ember Vein, Dry Well of Aelhart)

**Visual language:** Rough, organic, geological. Irregular wall contours. Mineral veins catching torchlight. The darkness is a design element -- light comes from the player's torch, from wall-mounted sconces, and from natural crystal deposits.

**Key elements:**
- Wall tiles: rough-hewn stone with visible strata layers, mineral vein highlights (ember-orange in Ember Vein, grey-blue elsewhere)
- Floor tiles: uneven rock, loose gravel, puddle reflections near water sources
- Light: warm amber torch radius (5-tile circle of full light, 3-tile penumbra, darkness beyond). Torchlight flickers on a 4-frame animation cycle. Mineral veins self-illuminate in dim ember orange.
- Depth cue: stalactites descending from the top tile row. Water drip animations at regular intervals.
- The moment the player first sees dead miners in the Ember Vein, the torchlight should be the only movement in the room. Everything else is still.

**Palette shift:** Underground caves use the base Underground/Cavern palette (`#787880` to `#0E0E18`) with torchlight amber (`#D8A050`) providing the only warmth. In the Ember Vein, the Ancient Ruins sub-biome bleeds in: geometric inlay patterns (`#D8C868` active, `#585868` dormant) appear on walls as the player goes deeper. The transition from natural cave to ancient ruin is the game's first visual reveal.

---

### Forgewright Facilities (Rail Tunnels, Axis Tower, Sunken Rig)

**Visual language:** Metal, precision, function. Straight lines, repeating patterns, mechanical rhythm. The infrastructure hums with Arcanite energy. Steam is everywhere -- venting from pipes, rising from grating, obscuring sightlines.

**Key elements:**
- Wall tiles: iron-braced stone, riveted steel plate, brick-lined tunnels (Compact standard). Pipe clusters running along ceiling and wall junctions.
- Floor tiles: metal grating (see-through to dark below), rail tracks, brick, industrial concrete
- Light: Arcanite lamps -- harsh white-blue pools with sharp shadow edges. Forge glow from machinery -- warm orange in functional areas, grey-white in Pallor-corrupted sections.
- Machinery: animated gear sprites (2-frame rotation), piston strokes (3-frame cycle), conveyor belts (continuous scroll), steam vents (burst animation on timer)
- The Axis Tower interior shifts from industrial base to crystalline top -- the highest floors are where Forgewright engineering meets ley energy, and the palette reflects this hybrid (iron grey + Arcanite blue + ley amber).

**Palette shift:** Carradan Industrial base palette in the Rail Tunnels and lower Axis Tower. The Sunken Rig adds Coastal biome water tiles -- flooded corridors where industrial iron meets ocean blue-black. During the Interlude, Pallor corruption replaces Arcanite blue with Pallor grey-white. The machines still run. The light is wrong.

---

### Ancient Ruins (Archive of Ages, Ember Vein inner chambers)

**Visual language:** Geometric perfection. Alien precision. Impossible scale. The architecture is too smooth, too regular, too large for human use. Every surface communicates intention without being readable. The recurring Pendulum sigil -- a simple geometric shape -- is carved into doorways, floors, and sealed doors.

**Key elements:**
- Wall tiles: smooth-cut stone blocks with unnaturally precise joints. Inlaid channel patterns (dormant: `#585868`; active: `#D8C868`) that illuminate in sequence when puzzles are solved -- golden light spreading through channels like blood through veins.
- Floor tiles: tessellated geometric mosaics. Pressure plates. Recessed channels. The floor tells you what the builders valued: pattern, symmetry, containment.
- Light: Self-illuminating chambers. No visible light source. The warm gold (`#F0E8C8`) simply exists. In dormant sections, the only light is what the player brings. The activation of a room -- when inlay patterns flare to life -- is one of the most visually striking moments in any dungeon.
- Scale: Doorways ten times human height. Pedestals at waist height -- sized for humans. The builders made these spaces for visitors, not themselves. The implication is unsettling.
- The Archive of Ages has pictographic wall panels that reconfigure when tablets are read. The art style within the pictographs changes with each depicted age -- a visual history of the Pendulum cycle told in evolving tilework.

**Palette shift:** Ancient Ruins palette (`#38384A` stone, `#D8C868` active inlay, `#68A8C8` ley residue) is consistent across all ruin sites. This is deliberate -- the player is meant to recognize the builders' signature from Ember Vein to Archive. The sealed door in the Ley Line Depths uses the same inlay pattern as the Ember Vein pedestal. Connection through visual consistency.

---

### Corrupted Areas (Pallor Wastes, corrupted dungeons)

**Visual language:** The anti-aesthetic. Every other dungeon type has a visual system -- rules, patterns, identifiable features. The Pallor Wastes break the rules. Color drains. Geometry simplifies. Detail flattens. This is the only area in the game that uses static -- grey pixel noise layered over the screen -- as a persistent visual effect.

**Key elements:**
- Ground tiles: featureless grey. No texture variation beyond slight value shifts (`#A0A0A0` to `#787878`). The ground should feel like it is not really there.
- Petrification: living things frozen as grey stone. Trees, creatures, people -- recognizable shapes stripped of color. Petrified trees remain standing. Petrified creatures are mid-stride or mid-flight. The stillness is violent.
- Static: 5-10% of the screen at any time is covered by flickering grey-white pixels. Random, patternless, like a damaged television signal. The static moves. It clusters near the player. It seems to watch.
- No light sources. The grey illumination is uniform and directionless. No shadows exist because no light casts them. The player's sprite should feel like the only thing with depth.
- At the Convergence: floating plateau tiles, crumbling edges, energy geyser vents. Cael's machine (hybrid Forgewright scaffolding and ritual geometry) at the center. The palette is entirely grey except for the party's sprites and their attacks.

**Palette shift:** Any biome can become the Pallor Wastes through the three-stage corruption overlay (see `biomes.md` Section 5). The transition is a 5-tile gradient where original palette tiles progressively desaturate, then replace with grey monochrome. Static particles appear at the gradient's midpoint. Music cuts to silence, then the Pallor drone fades in. This transition should make the player physically uncomfortable.

### Corruption Visual Enhancements (Always On)

These cues supplement desaturation and are active for all players
(not gated by a setting). They make corruption tangible, not just grey.

- **Texture overlay:** Corrupted areas gain subtle grain/static that
  intensifies with corruption level. Dungeon grey zones get visible
  crack patterns on tiles.
- **Particle type shift:** Healthy areas have warm ambient particles
  (dust motes, fireflies, heat shimmer). Corrupted areas replace these
  with cold particles (grey ash, static sparks, drifting fragments).
- **HP bar shape cue:** Below 25% max HP, the bar gains a segmented /
  cracked appearance in addition to the green-to-red color shift.

See [accessibility.md](accessibility.md) Section 2 for color-blind
mode palette swaps.

### Color-Blind Mode Palettes

Two color-blind modes are available in Config:
- **Deutan-Protan:** red/green pairs swap to blue/orange (HP bar,
  status icons, Poison color)
- **Tritan:** blue/yellow pairs shift to green/magenta

See [accessibility.md](accessibility.md) Section 2 for full palette
swap tables and what does NOT change.

---

### Spiritual Sites (Deeproot Shrine, Ashgrove, Stillwater Hollow)

**Visual language:** Life and light in the midst of wildness. These are places where the ley lines are healthy and the world's natural magic is visible. The palette is saturated -- almost too vivid against the surrounding biome. The contrast communicates sanctuary.

**Key elements:**
- Bioluminescence: thick, layered, pulsing. Moss, fungi, and spirit-traces provide light in shades of teal (`#68D8B8`), purple (`#B088D8`), and amber (`#E8A838`). The light pulses in slow, rhythmic waves synced to the ley line heartbeat.
- Spirit particles: small, glowing motes that drift upward and outward from ley line sources. 2x2 pixel sprites in varied colors, moving on gentle sine-wave paths. Dense near nexus points, sparse at edges.
- Water: mirror-still, reflective. Stillwater Hollow's sacred spring perfectly reflects the canopy and spirits above. The reflection tile is a flipped duplicate of the surface layer -- a rare effect that communicates the location's supernatural clarity.
- Sound visualization: near spirit-totems, the background tiles subtly pulse in rhythm with the ambient hum. A barely perceptible brightness shift on a 6-second cycle. The environment breathes.
- These sites resist the Pallor longer than surrounding areas. During the Interlude, spiritual sites are the last to desaturate. Their light dims but does not go out. They become beacons.

**Palette shift:** The surrounding biome's palette, pushed 20% more saturated. Ley Line Nexus colors bleed in at the edges -- crystal formations, energy veins. Ashgrove is the exception: it is already monochrome, so its spiritual quality is communicated through the standing stones' subtle warmth (`#D8A868`) and the preservation of footprints. The spiritual is not always bright. Sometimes it is simply remembered.

---

## 5. UI Visual Integration

### Dialogue Box

**Style:** FF6 standard. Dark blue gradient background (`#1828A8` to `#081048`), thin silver-white border (1px), white bitmap font. Speaker name in gold/yellow at top left.

**Biome behavior:** The dialogue box does NOT change per biome. It is a constant -- the one visual element that remains identical from Aelhart to the Pallor Wastes. This consistency is a design choice: the dialogue box represents the player's connection to the characters. When the world drains of color, the dialogue box stays blue. When the Pallor static covers the screen, it does not touch the text. The characters' voices persist.

**Exception:** During Cael's final dialogue before closing the door (Act IV), the dialogue box border flickers grey for 2 frames, then returns to silver. The only time the UI acknowledges the Pallor. The player will notice, and it will terrify them.

---

### Menu Backgrounds

**Style:** Dark blue gradient (matching dialogue box). A subtle tiled pattern behind the menu panels -- a geometric motif that evokes the Ancient Ruins' inlay patterns. This is the same pattern throughout the game: a quiet, subconscious connection between the player's interface and the builders who came before.

**Biome behavior:** Menu backgrounds do not change per location. Like the dialogue box, the menu is a constant. However, the character portraits in the menu reflect status: normal coloring in healthy states, desaturated tint when affected by Pallor-adjacent status effects.

---

### Battle Backgrounds

Each biome provides a parallax battle background with 2-3 layers. Battle backgrounds are wider than the screen (384-512 pixels) to allow subtle horizontal scrolling during camera-shake effects.

| Biome | Layer 1 (Far) | Layer 2 (Mid) | Layer 3 (Near/Ground) |
|-------|--------------|--------------|----------------------|
| **Valdris Highlands** | Blue sky with white clouds | Rolling green hills, distant towers | Grass and wildflower ground, stone path |
| **Carradan Industrial** | Smog-amber sky | Factory silhouettes, chimney smoke | Brick floor, iron grating, pipe details |
| **Thornmere Deep Forest** | Near-black canopy ceiling | Massive trunk silhouettes, bioluminescent spots | Root-covered forest floor, moss, mushrooms |
| **Thornmere Wetlands** | Flat grey-green fog | Reed beds, distant wisp lights | Mud and shallow water ground, reed stems |
| **Mountain / Alpine** | Vast pale sky, clouds below | Snow-capped peaks, pine treeline | Snow and rock ground, ice formations |
| **Ley Line Nexus** | Dark void with energy arcs | Crystal formations, ley flow rivers | Geometric stone floor, inlay channels |
| **Coastal / Harbor** | Ocean horizon, distant ships | Dock structures, mast silhouettes | Dock planking, rope coils, crate props |
| **Underground / Cavern** | Black void | Stalactite formations, mineral veins | Cave floor, gravel, torch-lit stone |
| **Ancient Ruins** | Self-illuminated chamber ceiling | Geometric wall carvings, sealed doors | Tessellated mosaic floor, inlay patterns |
| **Ashlands** | Pale featureless sky | Standing stone silhouettes | Ash ground, preserved footprints |
| **Pallor Wastes** | Grey. Featureless grey. | Grey. Static. | Grey ground. No detail. Static overlay. |

**Parallax behavior:** Layer 1 scrolls at 0.25x player movement speed. Layer 2 scrolls at 0.5x. Layer 3 is static (the ground the party stands on). During boss encounters, a 1-frame screen shake accompanies heavy attacks, causing all layers to shift 2px vertically.

---

### Transition Effects

Screen transitions between areas use classic SNES wipes. The wipe style communicates the type of transition:

| Transition Type | Wipe Style | Direction |
|----------------|-----------|-----------|
| Town entry/exit (overworld) | Fade to black, fade in | 0.5s each way |
| Building entry (door) | Horizontal iris close/open | Centered on door |
| Floor change (stairs/ladder) | Vertical slide | Up for ascending, down for descending |
| Dungeon entry | Diagonal wipe | Top-left to bottom-right |
| Battle start | Shatter effect (6-frame screen break into triangles, each sliding off) | Outward from center |
| Battle end | Fade to white (victory) or fade to black (defeat) | 0.3s |
| Act transition | Slow fade to black (2s), hold black (1s), title card, fade in (2s) | -- |
| Pallor crossing | No wipe. The transition is the biome gradient itself. | Walking into grey |

**Biome-pair special transitions:**
- **Any biome to Pallor Wastes:** No transition effect. The player walks across the gradient. The absence of a wipe is the point -- there is no threshold, no door. The world just ends.
- **Overworld to Convergence (Act III):** The screen does not fade. The overworld tiles desaturate in real-time as the player approaches the grey zone. The town-entry iris does not trigger. The player is simply there.

---

## 6. Signature Scenes

These 12 moments require special visual treatment beyond the standard tile engine. Each is a set piece -- a scene where the camera, palette, and effects serve a specific emotional target. Think of FF6's opera, the floating continent, or the Magitek march through the snow. These scenes justify the game's existence as a visual experience.

---

### Scene 1: The Discovery of the Pendulum

**When:** Act I, Ember Vein dungeon climax.
**Color palette:** Underground/Cavern base transitioning to Ancient Ruins. The final chamber is self-illuminated in cold gold (`#F0E8C8`). The Pendulum on its pedestal glows with a pale, sickly light that is not quite gold and not quite grey -- the first hint that this artifact is not what it seems.
**Camera behavior:** The player walks into the chamber and stops. The camera does not follow immediately -- it holds on the doorway for 1 second, letting the player see the dead miners in the corridor behind them. Then it pans forward to the pedestal. The pan is slow. The player cannot move during it.
**Special effects:** The dead miners' sprites have no wounds. Their faces are frozen in expressions of empty despair -- open mouths, hollow eyes. They are the first Pallor victims in the game, but the player does not know that yet. The only animation in the room is the Pendulum's glow: a 4-frame pulse that does not match the ley line heartbeat. It has its own rhythm. Faster.
**Emotional target:** Unease beneath discovery. The player has just completed their first dungeon. They should feel accomplished. But the room is wrong. The light is wrong. The dead miners are wrong. The Pendulum is beautiful and it should not be touched. The player must touch it anyway.

---

### Scene 2: Cael's Betrayal -- The Gate Opening

**When:** End of Act II. The Convergence.
**Color palette:** Ley Line Nexus at extreme -- all ley colors (amber, blue, wild purple) converging, oversaturated, unstable. Then: grey. The gate opens and grey light erupts from the Convergence center, washing out the ley colors in a radiating wave. The desaturation is instantaneous and violent.
**Camera behavior:** Standard view during the confrontation dialogue. When Cael activates the Pendulum, the camera pulls back -- zooming out over 2 seconds to show the full Convergence plateau. The grey light erupts from center screen. The zoom continues to overworld scale for 1 second, showing the grey light as a pulse spreading across the continent.
**Special effects:** Grey light particles -- thousands of 1px grey-white dots radiating outward from center. Ley energy crystal formations shatter (3-frame break animation, fragments dissolving to grey). The screen shakes (2px, constant, for 3 seconds). Lira's sprite reaches toward Cael's position -- her hand extended, 2 frames, held. Cael's sprite is a silhouette against the grey light. He does not look back.
**Emotional target:** Heartbreak and horror. Two stories colliding. The personal (Lira losing Cael) and the cosmic (the world cracking open). The player should feel both simultaneously. The visual trick: Lira's colorful sprite against the grey light makes her look small. The grey is so much bigger than anyone.

---

### Scene 3: The Party Scattered

**When:** Interlude opening. Four separate vignettes, rapid montage.
**Color palette:** Each vignette uses its character's location biome at Stage 1-2 corruption. Desaturated but recognizable. The montage cuts between them with no transition -- hard cuts, jarring.
**Camera behavior:** Each vignette is 1 screen, 5 seconds, no player input. The camera is fixed. The character is small in the frame, alone.
- **Edren at Highcairn:** Alpine biome. Snow. Edren stands at the overlook, looking south. The grey stain is visible on the horizon. He does not move.
- **Lira at the Wilds edge:** Thornmere forest. Lira walks a path alone. The trees behind her have grey bark patches. She moves slowly, head down.
- **Sable at Bellhaven:** Coastal. Sable sits on a dock, legs over the water. The harbor behind her is half-empty. Ships are leaving.
- **Torren at Roothollow:** Deep forest. Torren stands before a dark spirit-totem. The bioluminescence around it is flickering. He places his hand on it. Nothing happens.
**Special effects:** Between each vignette, the screen flashes grey for 1 frame. The flash gets longer with each cut (1 frame, 2 frames, 3 frames, 4 frames). The Pallor is growing between scenes.
**Emotional target:** Isolation. The party that was together is now four individuals in four different kinds of pain. The player should feel the distance between them. The hard cuts prevent the comfort of transition -- there is no connection between these places anymore.

---

### Scene 4: Sable Finding Edren

**When:** Interlude, Highcairn monastery.
**Color palette:** Mountain/Alpine at Stage 2 corruption. Grey frost on every surface. The monastery halls have grey mist in the corridors. But the great hall hearth still burns -- a single point of amber warmth in a cold, grey space. Edren is sitting beside it, unarmored, diminished.
**Camera behavior:** Sable approaches from the monastery entrance. The camera tracks her through corridors of grey mist and fallen monks (not dead -- catatonic, frozen in postures of despair). The pace is slow, deliberate. Each room she passes through has the same grey mist. The hearth room is the last -- the camera pauses at the doorway before entering.
**Special effects:** Grey Pallor creatures -- hollow, translucent, vaguely humanoid -- manifest from the mist as Sable walks. They do not attack her during the cutscene. They watch. Their sprites are 2-frame animations: present, then slightly shifted, then present again. They move in jerks, not fluid motion. The monks on the floor have no animation at all -- perfectly still, breathing but nothing else. The contrast between the creatures' jerky motion and the monks' total stillness is the horror.
**Emotional target:** Compassion through dread. The player is approaching someone who needs help through a place that has been consumed by despair. The hearth fire is the emotional anchor -- it is still burning because Edren will not let it die. That stubbornness is what Sable came to find.

---

### Scene 5: Torren's Sacrifice -- The Forest Burns with Him

**When:** Interlude climax, Roothollow.
**Color palette:** Thornmere Deep Forest at night, full bioluminescence. When Torren begins his ritual, the bioluminescence intensifies beyond normal parameters -- teal and purple and amber, oversaturated, almost white. The forest is burning with magical energy, but it is Torren burning, his life force feeding the ley lines. The bioluminescence fades as he fades.
**Camera behavior:** Fixed on the ritual clearing. Torren at center. The camera does not move, but the bioluminescence pulses outward from his position in radiating waves -- the parallax layers themselves brighten and dim in sync with his heartbeat. The waves slow as the scene progresses.
**Special effects:** Spirit particles -- thousands of them, rising from Torren's sprite and flowing outward along the ley line paths. Each particle is a 2px glow that travels to the screen edge and vanishes. The forest's bioluminescence follows: brightest at the height of his sacrifice, then dimming. Torren's sprite slowly loses color saturation -- from full palette to desaturated to a faint outline. His last frame is a transparent silhouette against bright forest light.
**Emotional target:** Grief and awe. A man is dying to keep the world alive for a little longer. The visual excess -- the light, the particles, the oversaturation -- is the cost of his sacrifice made visible. When the light fades to normal bioluminescence, the absence of the excess is Torren's absence.

---

### Scene 6: The Convergence Approach

**When:** Act III opening. The party walks toward the Convergence.
**Color palette:** Full Pallor Wastes. Monochrome grey. But the party's sprites retain full color. They are the only color in the world. The contrast is absolute and deliberate.
**Camera behavior:** A long walking sequence. No dialogue. The camera follows the party across 3-4 screens of Pallor Wastes terrain. Petrified trees, grey ground, static. The party walks in formation. Ambient sound is the Pallor drone and muffled footsteps.
**Special effects:** The sky goes static. Not clouded -- static. The same grey pixel noise that appears on the ground now fills the sky tiles. The world above and below is dissolving. Color drains from the horizon tiles in real time as the party advances -- the biomes visible in the distance desaturate as the player watches. The static clusters near the party's sprites as if drawn to their color. It reaches toward them but cannot touch them.
**Emotional target:** Determination against annihilation. The visual message is simple: these four people are all that is left of color, of life, of meaning. They are walking into nothing. The player controls the walk. They choose each step. The absence of dialogue forces the player to feel the weight without words.

---

### Scene 7: Cael Walking Into the Door

**When:** Act IV climax. The Convergence.
**Color palette:** The machine has been stopped. The door is visible -- a vertical tear in reality, pouring grey light. Everything else is Pallor grey. Cael's sprite begins in full color (he has been freed from the Pallor's influence by the party's efforts). As he walks toward the door, his sprite desaturates progressively -- color draining from the extremities inward. By the time he reaches the threshold, he is a grey silhouette. Then he is a small grey silhouette. Then he is gone.
**Camera behavior:** Fixed. The door is at screen center. Cael walks from the bottom of the frame toward it. The camera does not follow -- it holds position as Cael shrinks with distance. The door is huge. Cael is small. Smaller. Gone.
**Special effects:** Silence. The Pallor drone cuts out when Cael starts walking. No music. No ambient sound. Only Cael's footsteps, which fade as he recedes. His dialogue box appears one final time (the UI border flickers grey, as established earlier). His last words appear character by character, slower than normal typewriter speed. 80ms per character instead of 40ms. The player feels each letter.
**Emotional target:** Sacrifice acknowledged. No spectacle. No explosion. A person walking into oblivion to close a door. The visual restraint -- after all the effects and excess of previous scenes -- communicates the finality. This is not dramatic. This is just what must happen. The smallness of the sprite is the point. One person, doing the thing that saves everything.

---

### Scene 8: The Door Closing

**When:** Immediately following Scene 7.
**Color palette:** The grey light from the door begins collapsing inward -- the grey withdrawing from the screen edges toward center. As the grey pulls back, it leaves behind... black. Not color. Not yet. Pure black. The screen shrinks to a single point of grey light at center. Then it goes out.
**Camera behavior:** The camera holds on the door. No movement. The grey light's collapse is the only visual activity. The screen goes fully black. Hold black for 3 full seconds. In a medium of constant visual stimulation, 3 seconds of nothing is an eternity. The player should wonder if the game has crashed.
**Special effects:** SILENCE. Absolute silence. No music, no ambient, no drone, no footsteps. The audio engine outputs nothing. For 3 seconds, the player experiences the void that Cael walked into. Then -- a single sound. A bird. One note, clear, real, alive. Then the screen begins to brighten.
**Emotional target:** The death of despair. The silence is the Pallor's absence. The blackness is the world before it remembers how to exist. The bird is hope so fragile the player is afraid to breathe. This is the emotional climax of the entire game, and it is black screen and silence. Everything the pixel art and palette systems have built -- every color, every biome, every visual language -- is absent. Its absence is the statement.

---

### Scene 9: The Epilogue Meadow

**When:** Epilogue. The Convergence site, days or weeks later.
**Color palette:** New. Not Act I's warm greens. Not any biome's established palette. A new palette that has never appeared in the game:
- Grass: `#6AB87A` -- slightly blue-green, cooler than Valdris's warm green
- Wildflowers: `#D878B8`, `#78B8D8`, `#D8B878` -- pink, sky blue, gold. Colors that do not belong to any faction.
- Sky: `#78A8D8` -- deeper, cleaner than any sky tile in the previous game
- Light: `#F8F0E0` -- warm but not the Ancient Ruins' gold. Softer. Less certain. Honest.

**Camera behavior:** Slow pan across the meadow. The player does not control movement initially. The camera moves right to left across 2-3 screens of new growth where the Pallor Wastes were. Petrified trees stand among wildflowers. A stream flows where static once covered the ground. The sky is blue. It is so blue.
**Special effects:** Wild magic fireflies. Small, bright, multi-colored points of light (2px sprites) drifting in gentle sine-wave paths across the meadow. They are where the Convergence was. They are what remains of the ley energy -- not channeled, not extracted, not weaponized. Just existing. The fireflies use the Ley Line Nexus's colors (`#E8A838`, `#38A8E8`, `#B848D8`) but softer, less intense, playful instead of powerful.
**Emotional target:** Changed but alive. The world is not what it was. It is not better or worse. It is different. The new palette communicates this: the player cannot go home to Act I's green. That green is gone. But this green -- this new, slightly unfamiliar green -- is real and growing and worth having. The fireflies are the magic that remains. It is enough.

---

### Scene 10: The Reunion at Ashgrove

**When:** Epilogue. The party gathers at the standing stones.
**Color palette:** Ashlands base, but changed. The ash is still pale, but green shoots appear at the edges of the clearing (new tiles: `#6AB87A` against `#D8D0C0`). The First Tree stump has a single green bud -- 4x4 pixels, the brightest green in the Ashlands tileset. It should be unmissable.
**Camera behavior:** Each party member arrives from a different screen edge. The camera holds on the standing stone circle as they converge. Edren from the north (Valdris). Sable from the south (Compact). Lira from the east (Wilds). Torren from the west (the Wilds -- he carries a spirit-totem from Roothollow, honoring what the forest lost). They meet at center.
**Special effects:** As each party member enters the frame, the tiles nearest their path gain a faint color tint -- their personal palette bleeding into the Ashlands' monochrome. Edren's path gains green. Sable's path gains blue. Lira's path gains amber. Torren's path gains teal. When they all stand at center, the combined colors create a small radius of full saturation around the standing stones. The rest of the clearing remains ash-pale. The color is localized. It is enough.
**Emotional target:** Bittersweet completion. The four who fought together are four -- but the one they fought for is gone. Cael's absence is the memory. The bud on the stump is promise, not fulfillment. The localized color says: healing starts small, starts with the people who choose it, and spreads outward at its own pace. The game does not show the world fully healed. It shows the world beginning.

---

### Scene 11: Lira at Cael's Window

**When:** Epilogue, optional. Valdris Crown.
**Color palette:** Valdris Highlands post-healing variant. Warmer, wilder than Act I. Wildflowers where there were none. The ley-lamps are dark, replaced by Arcanite lanterns -- hybrid technology, the factions learning from each other. The sky is the epilogue's deeper blue.
**Camera behavior:** Interior. Cael's quarters. Lira stands at the window that faced the Wilds. The glass is cracked from the inside (established in the Interlude environmental storytelling). Through the crack, the Wilds are visible -- dark green canopy with brighter spots where bioluminescence has returned.
**Special effects:** Minimal. Lira's sprite has a 2-frame animation: she places her hand on the cracked glass. One mote of wild magic -- a single firefly from the epilogue meadow palette -- drifts through the crack and hovers near her hand. She does not catch it. It drifts away. She watches it go.
**Emotional target:** Grief and acceptance coexisting. Lira lost Cael. The firefly is not Cael. It is just the world continuing. But it came through his window. The crack he left in the glass let something new in. The scene says: loss is permanent, and beauty persists anyway.

---

### Scene 12: The First Tree's Bud (Post-Credits)

**When:** After the credits roll. A single static screen.
**Color palette:** Ashlands base. The standing stones. The ash. The stump. But the bud has grown. It is no longer 4x4 pixels. It is a small branch -- 8x16 pixels -- with three leaves. Green. The brightest, most saturated green in the entire game's palette: `#4AE060`. A green that has never appeared before.
**Camera behavior:** None. Static frame. The screen fades in and holds for 10 seconds. No text. No UI. No dialogue box. Then fade to black. Then the title screen.
**Special effects:** The leaves sway. A 2-frame animation, slow. The wind that blows through the Ashlands -- usually carrying nothing but dust -- moves the leaves. A single wild magic firefly circles the branch. One.
**Emotional target:** Hope without qualification. After an entire game of loss, corruption, sacrifice, and bittersweet recovery -- this is the one moment of pure, unambiguous hope. The First Tree burned a thousand years ago. Something is growing. The game's final image is a small green thing, alive, in a field of ash. That is what the whole story was about.

---

## 7. Color Script

The color script maps the game's emotional arc onto its visual palette, scene by scene. Every art asset -- tiles, sprites, backgrounds, UI -- should be checked against this script. If a scene's colors contradict its position in the arc, something is wrong.

### Act I: The World in Full Color

**Dominant palette:** Warm, saturated, rich. The Valdris Highlands' emerald greens, gold accents, and pale limestone. The Thornmere's deep forest bioluminescence. Even the Compact's amber industrial palette is warm. The world is beautiful, and the player is meant to love it.

| Story Beat | Location | Palette Temperature | Saturation | Key Color |
|-----------|----------|-------------------|------------|-----------|
| Opening -- Aelhart dawn | Aelhart | Warm (dawn tint) | 100% | Wheat gold `#D4A832` |
| Valdris Crown introduction | Valdris Crown | Warm | 100% | Limestone white `#D6CDB8`, tower gold |
| Thornwatch -- meeting the soldiers | Thornwatch | Warm-neutral | 95% | Forest edge green `#2D5A28` |
| Ember Vein dungeon | Underground | Cool-warm (torch) | 90% | Torch amber `#D8A050`, ember orange |
| The Pendulum discovery | Ancient Ruins | Cold gold | 85% | Sickly gold-grey (the first wrong note) |
| Ironmouth -- first Compact contact | Industrial frontier | Warm-oppressive | 95% | Iron grey meets forest green |
| Roothollow -- entering the Wilds | Deep Forest | Cool-lush | 100% | Bioluminescent teal `#68D8B8` |

**The first wrong note:** When the Pendulum is found, the chamber's gold light is slightly desaturated compared to Valdris's warm gold. The player may not consciously notice, but the palette has told them: this thing is not right. Saturation drops to 85% for the first time. It recovers in the next scene, but the seed is planted.

---

### Act II: Shadows Deepen

**Dominant palette:** Still warm, but shadows grow. The rich colors of Act I persist in interiors and safe zones, but exterior scenes show the first signs of strain. Ley-lamps dim. Smoke thickens. The canopy's bioluminescence flickers. The palette does not break -- it frays at the edges.

| Story Beat | Location | Palette Temperature | Saturation | Key Color |
|-----------|----------|-------------------|------------|-----------|
| Compact cities -- Corrund, Ashmark | Industrial | Warm-oppressive | 90% | Forge glow `#E88830`, smog amber |
| Bellhaven harbor | Coastal | Cool-neutral | 90% | Ocean blue `#2A4868`, lantern gold |
| Duskfen diplomacy | Wetlands | Cool-muted | 85% | Fog grey-green `#A8A898`, wisp light |
| Ley Line Depths | Nexus/Underground | Cool-vivid | 95% | Ley blue `#38A8E8`, crystal white |
| Ashgrove alliance | Ashlands | Neutral-pale | 75% | Ash white `#D8D0C0` (already drained) |
| Greyvale -- the border town | Highlands (ruined) | Cool-declining | 70% | Desaturated green, scorched stone |
| Cael's nightmares | Valdris Crown (night) | Cold | 60% | Grey light from the Pendulum |
| The betrayal at the Convergence | Ley Line Nexus | HOT then DEAD | 100% then 0% | All ley colors, then grey |

**The trajectory:** Saturation begins Act II at 90% and slides to 70% in exterior scenes. Cael's nightmare sequences are the coldest, most desaturated scenes in the first half of the game (60%). These are foreshadowing -- the palette in his nightmares matches Act III's Pallor Wastes. The player sees the future without knowing it.

**The betrayal scene breaks the color script.** For 3 seconds, every ley line color fires at 100% saturation simultaneously -- the most vivid the game has ever been. Then it goes to 0%. The drop from maximum to nothing is the act break. The player's retinas carry the afterimage of color into the grey.

---

### Interlude: Cold Creeps In

**Dominant palette:** Muted. Grey tinge enters every biome. The warmth of Act I is a memory. Each reunion scene restores a small burst of color -- the party members are literal beacons of saturation in a desaturating world.

| Story Beat | Location | Palette Temperature | Saturation | Key Color |
|-----------|----------|-------------------|------------|-----------|
| Edren alone at Highcairn | Alpine (Stage 1-2) | Cold | 55% | Grey frost, hearth amber (only warmth) |
| Sable at Bellhaven | Coastal (Stage 1) | Cool-grey | 65% | Muted ocean, empty harbor |
| Lira undercover in Corrund | Industrial (Stage 2) | Warm-wrong | 60% | Grey-white Pallor glow replacing amber |
| Torren at Roothollow | Deep Forest (Stage 2) | Cool-dim | 50% | Flickering bioluminescence, grey bark |
| Sable finds Edren | Alpine (Stage 2) | Cold | 45% + 80% (at hearth) | Grey mist, amber hearth (the contrast) |
| Lira and Sable reunite | Industrial interior | Warm-brief | 70% (burst) | Two full-color sprites together |
| Torren's sacrifice | Deep Forest (night) | BRIGHT then dim | 100% then 40% | Oversaturated bioluminescence, then fade |
| Full party reunion | Wilds border | Mixed | 75% (party), 50% (world) | Four full-color sprites against grey-green |

**The reunion mechanic:** Each time two party members find each other, the local saturation increases by 15-20% for the duration of their shared scenes. When all four reunite, the scene reaches 75% -- still below Act I's 100%, but noticeably brighter than the surrounding world at 50%. The message: people together resist the grey. Isolation feeds it.

**Torren's sacrifice is the Interlude's betrayal mirror:** maximum saturation, then collapse. But where the betrayal went to 0%, Torren's sacrifice settles at 40%. The world is darker for his loss, but it continues. His near-fatal sacrifice bought time. The palette acknowledges the cost.

---

### Act III: Near-Monochrome

**Dominant palette:** The Pallor Wastes. Grey is the default. The only color in the world is carried by the party and their attacks. Battle animations use full-color spell effects against grey backgrounds. The party's sprites refuse to desaturate. Hope is literal, visible, and surrounded on all sides by nothing.

| Story Beat | Location | Palette Temperature | Saturation | Key Color |
|-----------|----------|-------------------|------------|-----------|
| The Convergence approach | Pallor Wastes | None | 0% (world), 100% (party) | Grey vs. party colors |
| Pallor trials (individual) | Corrupted memories | Varies (memory) | 30% (world), 90% (personal) | Each character's signature palette |
| Battle encounters | Pallor Wastes | Cold-dead | 0% (background), 100% (spells) | Spell effects are vivid against grey |
| Save point clearings | Healed patches | WARM (burst) | 80% in clearing, 0% outside | Natural time-of-day colors restored |
| The machine confrontation | Convergence center | Cold-grey with flickers | 10% (ambient), 100% (attacks) | Lightning-flash ley colors during combat |

**Save point clearings are emotional oases.** When the party heals a small patch of the Wastes (at save points), the natural biome snaps back to full color within a small radius. Time of day appears. Sound returns. The player hears wind, or insects, or water -- whatever that biome would have. Then they leave the clearing and it is grey and silent again. Each save point is a reminder of what they are fighting for and what surrounds them.

**Battle spell effects carry extra weight in Act III.** Fire spells, lightning, healing magic -- all at full saturation against the grey battle background. The party's magic is color itself. Combo abilities (Chrono Trigger dual-tech style) create bursts of combined palette colors that briefly illuminate the entire battle screen. For 2-3 frames, the grey is gone. Then it returns.

---

### Act IV: The Door

**Dominant palette:** Grey, collapsing to black. Cael's final scene inverts the Pallor -- instead of grey spreading, it withdraws. But what it leaves behind is not color. It is void.

| Story Beat | Location | Palette Temperature | Saturation | Key Color |
|-----------|----------|-------------------|------------|-----------|
| The final confrontation | Convergence | Cold-grey | 5% (ambient), 100% (party) | Grey light, party color |
| Cael freed | Convergence | Neutral | 20% (recovering) | Cael's sprite regains color briefly |
| Cael walks to the door | Convergence | Draining | 100% to 0% (Cael), 5% (world) | Cael desaturating as he walks |
| The door closes | Convergence | NONE | 0% then black | Grey collapsing to point, then black |
| Silence | Black screen | NONE | 0% | Nothing. |
| The bird | Black screen | NONE (audio only) | 0% | A sound, not a color. |

**The palette bottoms out.** Act IV Scene 7 (Cael walking) and Scene 8 (the door closing) are the visual nadir. The entire screen reaches 0% saturation, then goes to black. The game has used its full range: from Act I's 100% warmth to this absolute zero. Every palette choice in the game has been building toward this moment of total absence. The silence and blackness are the payoff for 40+ hours of visual storytelling.

---

### Epilogue: New Colors

**Dominant palette:** Unfamiliar. Not Act I's warmth restored. A new palette that did not exist before the Pallor. Cooler greens, deeper blues, colors that belong to a world that has been through something and come out changed. The saturation builds throughout the epilogue but never reaches Act I's level. The world is at 80-85% maximum. The missing 15-20% is the scar that does not heal. It is not a failure of recovery. It is honesty.

| Story Beat | Location | Palette Temperature | Saturation | Key Color |
|-----------|----------|-------------------|------------|-----------|
| Fade from black | Transition | Warming | 20% to 60% | Dawn light, birdsong |
| The epilogue meadow | Former Convergence | Warm-new | 80% | New green `#6AB87A`, wildflowers |
| Overworld recovery pan | Continental | Mixed-healing | 75% | Patchwork biomes, scars and growth |
| Ashgrove reunion | Ashlands (healing) | Warm-pale | 70% (base) + color radius | Green shoots, the bud |
| Lira at the window | Valdris Crown (healed) | Warm-bittersweet | 80% | Cracked glass, firefly, new blue sky |
| The First Tree's bud | Ashgrove | Warm | 85% | `#4AE060` -- the brightest green |

**The final green (`#4AE060`) appears nowhere else in the game.** It is not Valdris green, not Thornmere green, not the epilogue meadow green. It is a new color for a new thing. The game's last visual statement is a color that has never existed in this world before. That is the meaning of survival: not return, but becoming.

---

## Appendix: Quick Reference Tables

### Character Sprite Specifications

| Property | Field Map | Overworld | Battle |
|----------|----------|-----------|--------|
| Size | 16x24 px | 8x12 px | 32x32 px |
| Colors | 16 per character | 8 per character | 16 per character |
| Walk frames | 4 per direction (16 total) | 2 per direction (8 total) | N/A |
| Idle frames | 2 | 1 | 2 |
| Battle poses | N/A | N/A | idle, attack, cast, hit, critical, victory |

### Biome-to-Town Quick Reference

| Town | Primary Biome | Overworld Icon |
|------|--------------|----------------|
| Aelhart | Valdris Highlands | Watermill |
| Valdris Crown | Valdris Highlands (urban) | White castle, gold towers |
| Thornwatch | Valdris Highlands (military) | Tower behind palisade |
| Highcairn | Mountain / Alpine | Stone monastery on peak |
| Corrund | Carradan Industrial | Iron spire, orange glow |
| Ashmark | Carradan Industrial (heavy) | Chimney stacks, red glow |
| Caldera | Carradan Industrial (volcanic) | Bowl, heat glow |
| Bellhaven | Coastal / Harbor | Stilts, lighthouse, ships |
| Millhaven | Carradan Industrial (extraction) | Pit, blue glow |
| Roothollow | Thornmere Deep Forest | Green mound, teal glow |
| Duskfen | Thornmere Wetlands | Platforms, wisp lights |
| Ashgrove | Ashlands | Pale clearing, dark center |
| Canopy Reach | Thornmere Deep Forest (vertical) | Tree crowns, platforms |
| Ironmouth | Carradan Industrial (frontier) | Metal roofs, tree line |
| Ashport | Coastal / Harbor (industrial) | Harbor, smoke, flash |
| Gael's Span | Deep Forest / Industrial (border) | Bridge, two flags |
| Kettleworks | Carradan Industrial (research) | Dome glint |

### Saturation Arc Summary

| Game Phase | World Saturation | Party Saturation | Emotional State |
|-----------|-----------------|-----------------|-----------------|
| Act I | 85-100% | 100% | Beauty, discovery, home |
| Act II | 70-90% | 100% | Strain, shadow, foreboding |
| Betrayal | 100% then 0% | 100% | Shock, heartbreak |
| Interlude | 40-65% | 100% (isolated), 70-80% (reunited) | Isolation, slow recovery |
| Torren's sacrifice | 100% then 40% | 100% then grief | Loss that buys time |
| Act III | 0-10% | 100% | Defiance, hope as color |
| Act IV | 0% to black | 100% to 0% (Cael) | Sacrifice, void, silence |
| Epilogue | 70-85% (new palette) | 85% | Changed but alive |
| Post-credits | 85% | N/A | Pure hope |
