# Building Interior Palette -- Pendulum of Despair

This document defines a reusable interior template system for city and settlement buildings. Every inn, shop, and house in the game is assembled from modular furniture tiles and layout templates, the same way SNES-era RPGs reused a bookshelf tile, a bed tile, and a counter tile across dozens of interiors. Individual buildings feel distinct through arrangement, faction style, and optional decoration -- not through unique tilesets for every room.

All dimensions are in 16x16 pixel tiles. A "12x10 room" is 12 tiles wide by 10 tiles tall. Character sprites are 16x24 (1 tile wide, 1.5 tiles tall). Furniture that the player interacts with must have a clear 1-tile approach space.

---

## Table of Contents

1. [Building Types Catalog](#1-building-types-catalog)
2. [Furniture & Object Palette](#2-furniture--object-palette)
3. [Faction Style Variants](#3-faction-style-variants)
4. [Damaged & Corrupted Variants](#4-damaged--corrupted-variants)
5. [Standard Interior Layout Templates](#5-standard-interior-layout-templates)
6. [Composition Rules](#6-composition-rules)

---

## 1. Building Types Catalog

### Weapon Shop

**Standard size:** 12x10
**Required furniture/objects:**
- Shop counter (2-3 tiles wide, divides shopkeeper from customer area)
- Weapon racks (2-4, displaying swords, spears, axes)
- At least 1 armor stand or shield display

**Optional furniture/objects:**
- Small table with whetstone or oil cloth
- Decorative wall-mounted weapons (greatsword, halberd)
- Crate or barrel of raw materials
- Rug in front of counter
- Wall-mounted torch or sconce

**NPC positions:**
- Shopkeeper: behind counter, center or slightly off-center, facing south
- Optional customer NPC: browsing weapon rack, facing north or east

**Interaction points:**
- Buy/sell trigger: 1 tile south of counter center (player faces north to talk)
- Examinable weapon rack: flavor text describing stock quality
- Door: bottom wall, center

---

### Armor Shop

**Standard size:** 12x10
**Required furniture/objects:**
- Shop counter (2-3 tiles wide)
- Armor stands (2-4, displaying chest pieces or full sets)
- Shield rack (1-2 tiles)

**Optional furniture/objects:**
- Fitting mirror (1 tile, decorative)
- Workbench with leather or metal tools
- Helmet display shelf
- Rug or carpet

**NPC positions:**
- Shopkeeper: behind counter, facing south
- Optional apprentice NPC: near workbench

**Interaction points:**
- Buy/sell trigger: 1 tile south of counter center
- Examinable armor stand: flavor text about materials and craftsmanship
- Door: bottom wall, center

---

### Item / Potion Shop

**Standard size:** 10x10
**Required furniture/objects:**
- Shop counter (2-3 tiles wide)
- Potion shelves (2-3, bottles and jars on wall-mounted shelving)
- At least 1 herb basket or ingredient barrel

**Optional furniture/objects:**
- Cauldron or mixing station (1-2 tiles)
- Hanging herbs from ceiling
- Small bookshelf with recipe books
- Potted plants (medicinal herbs)
- Mortar and pestle on table

**NPC positions:**
- Shopkeeper: behind counter, facing south
- Optional NPC browsing shelves

**Interaction points:**
- Buy/sell trigger: 1 tile south of counter center
- Examinable potion shelf: descriptions of available remedies
- Optional readable recipe book on shelf
- Door: bottom wall, center

---

### General Store (Combined Shop)

**Standard size:** 14x12
**Required furniture/objects:**
- L-shaped or long counter (4-5 tiles, wrapping a corner or spanning the back wall)
- Weapon rack (1-2)
- Potion shelf (1-2)
- Armor stand (1)
- Storage crates and barrels (3-4, stacked near walls)

**Optional furniture/objects:**
- Small table with miscellaneous goods
- Hanging lanterns
- Rug
- Display case (glass top, for rare items)
- Notice board near door

**NPC positions:**
- Shopkeeper: behind the long counter, facing south
- Optional second NPC: stocking shelves or sweeping

**Interaction points:**
- Buy/sell trigger: 1 tile south of counter, near shopkeeper
- Notice board: side quest hints, local news
- Door: bottom wall, center or offset

---

### Inn (With Rooms)

**Standard size:** 16x14 (main floor) + 12x10 (upper floor or back rooms)
**Required furniture/objects:**
- Front desk or reception counter (2 tiles)
- Common room with tables (2-3 round or rectangular) and chairs (4-6)
- Fireplace or hearth (2 tiles wide, back wall or side wall)
- Staircase to upper floor (2 tiles wide)
- Guest beds upstairs (2-4 single beds or 1-2 double beds)

**Optional furniture/objects:**
- Bar counter with stools (if combined with tavern)
- Bookshelf in common area
- Potted plants or flowers
- Coat rack near entrance
- Decorative paintings or tapestries
- Clock on mantle
- Rug in front of hearth

**NPC positions:**
- Innkeeper: behind front desk, facing south
- 1-2 guest NPCs: seated at common room tables
- Optional bard or entertainer NPC: near hearth

**Interaction points:**
- Rest trigger: 1 tile south of front desk (buy a room, fade-to-black rest, HP/MP restore)
- Save point: near the staircase or hearth (see Save Points in Section 2)
- Fireplace: examinable for warmth flavor text
- Guest room beds: examinable ("a comfortable bed")
- Door: bottom wall, center

---

### Tavern / Pub

**Standard size:** 14x12
**Required furniture/objects:**
- Bar counter (4-6 tiles long, with stools on the customer side)
- Tables (3-4 round or rectangular) with chairs
- Barrel rack behind bar (stacked barrels, 2-3 tiles)
- Fireplace or wall-mounted lamp cluster

**Optional furniture/objects:**
- Stage area (2x2 tiles, for bard or performance)
- Dartboard or game table
- Staircase to upper floor (private rooms, quest NPCs)
- Hanging tankards on wall hooks
- Wanted poster or notice board
- Spilled drink tile (decorative floor detail)

**NPC positions:**
- Barkeeper: behind bar counter, facing south
- 2-4 patron NPCs: seated at tables or standing at bar
- Optional bard/musician: on stage or near hearth
- Optional suspicious NPC in corner (quest-related)

**Interaction points:**
- Buy drink trigger: 1 tile south of bar counter (optional item purchase or information exchange)
- Talk to patrons: individual NPC dialogue for rumors, side quests
- Notice board: bounties, news
- Door: bottom wall, center or offset

---

### Residential House -- Small (Peasant / Worker)

**Standard size:** 8x8
**Required furniture/objects:**
- Single bed or cot (1x2 tiles)
- Small table (1x1) with 1-2 chairs or stools
- Fireplace or cooking pot (1-2 tiles)
- Storage chest or barrel (1 tile)

**Optional furniture/objects:**
- Bookshelf (1 tile, sparse -- a few books at most)
- Rug (2x2 or 2x3)
- Potted plant or hanging herbs
- Coat hook or weapon peg on wall
- Water bucket
- Child's toy or doll (environmental storytelling)

**NPC positions:**
- Resident: standing near table or fireplace, facing south or east
- Optional second resident: seated or near bed

**Interaction points:**
- Dialogue with resident
- Examinable bookshelf (if present): 1-2 lines of flavor text
- Chest: may contain minor item or be locked
- Door: bottom wall, center

---

### Residential House -- Medium (Merchant / Craftsman)

**Standard size:** 12x10
**Required furniture/objects:**
- Double bed (2x2 tiles)
- Dining table (2x1 or 2x2) with 2-4 chairs
- Fireplace with mantle (2 tiles wide)
- Bookshelf (1-2 tiles)
- Wardrobe or cabinet (1 tile)
- Storage chest (1 tile)

**Optional furniture/objects:**
- Workbench or crafting station (profession-specific)
- Rug (larger, higher quality)
- Paintings or decorative wall hangings
- Potted plants (multiple)
- Display shelf with trade goods
- Writing desk with stool
- Second room (connected, separated by interior wall or doorway)

**NPC positions:**
- Head of household: standing near hearth or seated at table
- Optional spouse or child NPC: secondary position
- Optional apprentice: near workbench

**Interaction points:**
- Dialogue with residents
- Bookshelf: readable books, lore snippets
- Workbench: flavor text about the resident's trade
- Chest: may contain item
- Door: bottom wall, center

---

### Residential House -- Large (Noble / Wealthy)

**Standard size:** 16x14 (main floor) + 14x10 (upper floor)
**Required furniture/objects:**
- Grand staircase (3 tiles wide)
- Dining table (3x2, ornate, with 4-6 ornate chairs)
- Fireplace with ornate mantle (3 tiles wide)
- Multiple bookshelves (3-4 tiles total)
- Ornate bed upstairs (2x2, canopy or four-poster)
- Wardrobe and vanity table upstairs
- Chandelier (ceiling tile, decorative)

**Optional furniture/objects:**
- Trophy case or display cabinet (2 tiles)
- Paintings (portraits, landscapes -- faction-specific art)
- Grand rug or carpet (4x3 or larger)
- Armor display (decorative, 1 tile)
- Wine cabinet
- Writing desk with correspondence
- Servant's quarters (small connected room)
- Garden or balcony access (optional exit to outdoor tiles)

**NPC positions:**
- Noble: standing in main hall or seated at dining table
- 1-2 servant NPCs: near kitchen area, standing by walls
- Optional guard: near entrance
- Family members: upstairs, in study, or at table

**Interaction points:**
- Dialogue with noble (often quest-related)
- Bookshelves: extensive lore, personal letters, political documents
- Trophy case: examinable -- tells family history
- Paintings: examinable -- faction art, ancestors
- Chest in bedroom: may contain rare item or key
- Doors: front entrance (bottom wall), interior doors between rooms

---

### Temple / Church

**Standard size:** 14x16
**Required furniture/objects:**
- Altar or shrine (2x1, centered on back wall)
- Pews or prayer benches (4-6 rows of 2-tile benches, center aisle)
- Candelabras or standing candles (2-4, flanking altar and along walls)
- Stained glass window or faction-appropriate sacred symbol (wall tile, back wall above altar)

**Optional furniture/objects:**
- Font or basin (holy water, blessing point)
- Side alcoves with smaller shrines
- Bookshelf with sacred texts
- Confessional booth (2x1)
- Offering box
- Bell rope (leads to exterior bell)
- Back room (priest's quarters, accessible through side door)

**NPC positions:**
- Priest or caretaker: standing before altar, facing south
- 1-2 worshippers: seated on pews
- Optional healer NPC: near font or side alcove

**Interaction points:**
- Altar: prayer/blessing (restore 25% HP to all party OR cure all status ailments — player chooses one; once per visit; no AC restore. Font and altar share one blessing per visit)
- Healer NPC: cure status effects, remove curses (paid service)
- Sacred texts: readable lore about ley lines, faction beliefs, the Pendulum cycle
- Offering box: donate gold for minor stat buff
- Door: bottom wall, center (large double door tiles)

---

### Library / Archive

**Standard size:** 14x14
**Required furniture/objects:**
- Bookshelves (8-12 tiles total, lining walls and forming internal rows)
- Reading tables (2-3, with chairs)
- Librarian's desk (2 tiles, near entrance)
- Ladder tile (for reaching high shelves, decorative or interactive)

**Optional furniture/objects:**
- Globe or map display
- Scroll racks
- Study carrels (small individual desks with partition)
- Display case with rare book or artifact
- Candle sconces or reading lamps (every 2-3 shelves)
- Card catalog or index (faction-appropriate -- wooden drawers for Valdris, mechanical index for Carradan)

**NPC positions:**
- Librarian: behind desk, facing south
- 1-2 scholar NPCs: seated at reading tables
- Optional special NPC: hidden in back stacks (quest-related)

**Interaction points:**
- Librarian dialogue: hints about quest-relevant texts
- Bookshelves: multiple examinable points, each yielding different lore
- Rare book display: extended lore passage or quest item
- Reading table with open book: specific story-relevant information
- Door: bottom wall, center

---

### Barracks / Guard Station

**Standard size:** 14x12
**Required furniture/objects:**
- Bunk beds (4-6 sets, 1x2 tiles each, arranged in rows)
- Weapon rack (2-3 tiles)
- Armor stands (1-2)
- Commanding officer's desk (2 tiles, set apart from bunks)
- Strategic map on wall or table (1-2 tiles)

**Optional furniture/objects:**
- Mess table with benches
- Training dummy (1 tile)
- Chest per bunk (personal storage)
- Notice board with orders
- Fireplace or brazier
- Jail cell in corner (1-2 cells, iron door tiles)

**NPC positions:**
- Commander or sergeant: behind desk, facing south
- 2-3 soldiers: standing at attention, resting on bunks, or examining map
- Optional prisoner NPC: in cell (quest-related)

**Interaction points:**
- Commander dialogue: quest assignments, military intel
- Strategic map: examinable -- shows troop positions, foreshadows events
- Weapon rack: flavor text about standard-issue equipment
- Notice board: mission briefings, wanted posters
- Cell door: locked interaction (quest trigger)
- Door: bottom wall, offset (reinforced door tile)

---

### Prison / Jail

**Standard size:** 12x14
**Required furniture/objects:**
- Cells (3-4, each 3x3 interior, with iron bar door tile on one side)
- Guard station desk (2 tiles, positioned to watch all cell doors)
- Key rack on wall (1 tile, near guard station)
- Torch sconces (every 2-3 tiles along corridor)

**Optional furniture/objects:**
- Cot in each cell (1x2)
- Water bucket in cell
- Interrogation table and chair (in separate alcove)
- Evidence chest (locked, near guard desk)
- Drainage grate (floor tile -- potential escape route)
- Manacles on wall (decorative, environmental storytelling)

**NPC positions:**
- Guard: seated at desk or standing in corridor, facing cells
- 1-3 prisoner NPCs: in cells (some with dialogue, some silent)
- Optional second guard: patrolling corridor

**Interaction points:**
- Guard dialogue: bribery option, quest negotiation
- Cell doors: locked -- require key, quest flag, or stealth to open
- Prisoner dialogue: through bars (information, side quests)
- Evidence chest: locked, contains quest items
- Drainage grate: hidden exit (quest-specific)
- Door: bottom wall, heavy iron door tile

---

### Government Building (Throne Room / Council Chamber / Mayor's Office)

**Standard size:** Varies by function

**Throne Room:** 18x16
- Throne on raised platform (2 tiles high, 3 tiles wide, back wall center)
- Red carpet runner from door to throne (2 tiles wide)
- Columns flanking the carpet (4-6 pillar tiles)
- Banners on walls (faction-specific)
- Guard positions flanking throne (2 tiles)

**Council Chamber:** 14x14
- Large round or oval table (4x3 tiles, center)
- Chairs around table (6-8)
- Map or documents on table
- Faction banners on walls
- Chandelier overhead

**Mayor's Office:** 12x10
- Large desk (2x1, facing door)
- Ornate chair behind desk
- Bookshelves on side walls (2-3 tiles)
- Guest chairs (2, facing desk)
- Filing cabinet or document chest
- Window behind desk (wall tile)

**NPC positions:**
- Ruler / council leader / mayor: at their seat of power, facing south
- 2-4 guards or advisors: flanking positions
- Optional petitioner NPC: standing before the desk/throne

**Interaction points:**
- Dialogue with leader: major quest progression
- Map/documents on table: examinable for political context
- Bookshelves: lore about governance and faction history
- Throne: examinable from distance ("an ancient seat of power")
- Door: bottom wall, center (grand double doors for throne room)

---

### Workshop / Forge (Forgewright Specific)

**Standard size:** 12x12
**Required furniture/objects:**
- Forge or furnace (2x2 tiles, against back wall, animated flame)
- Anvil (1 tile, adjacent to forge)
- Workbench with tools (2 tiles)
- Quenching trough or water barrel (1 tile)
- Material storage (crates, ore bins -- 2-3 tiles)

**Optional furniture/objects:**
- Bellows (1 tile, adjacent to forge)
- Display rack with finished products
- Blueprint or schematic pinned to wall
- Grinding wheel (1 tile)
- Pipe fittings and gear assemblies (Carradan-specific wall decoration)
- Arcanite engine housing (glowing, Carradan-specific)

**NPC positions:**
- Smith or Forgewright: at anvil or workbench, facing south or east
- Optional apprentice: working bellows or sorting materials

**Interaction points:**
- Crafting trigger: 1 tile south of anvil or workbench (crafting menu, if system is implemented)
- Buy/sell trigger: at workbench if smith also sells
- Schematic: readable, hints at craftable items
- Forge: examinable ("the heat is intense")
- Door: bottom wall, offset

---

### Warehouse / Storage

**Standard size:** 14x12
**Required furniture/objects:**
- Crate stacks (6-10 tiles, arranged in rows or clusters)
- Barrel rows (4-6 tiles)
- Loading dock area (2-3 open tiles near door, clear floor)
- Manifest desk (1 tile, with ledger)

**Optional furniture/objects:**
- Shelving units (2-3 tiles, against walls)
- Crane or pulley (decorative ceiling tile)
- Padlocked chest (quest-related)
- Rat tiles (animated, decorative -- scurrying in corners)
- Cobwebs (if abandoned variant)
- Secret passage behind crate stack (quest-specific)

**NPC positions:**
- Warehouse keeper: at manifest desk (if staffed)
- Worker NPCs: moving crates (if active)
- None (if abandoned -- environmental storytelling)

**Interaction points:**
- Crates: examinable ("stamped with the Compact insignia" or "Valdris supply crates")
- Manifest desk: readable ledger (trade data, smuggling evidence)
- Padlocked chest: locked, requires key or quest trigger
- Secret passage: hidden behind movable crate (push puzzle)
- Door: bottom wall, large double door or rolling door tile

---

### Dock Office (Port Cities)

**Standard size:** 10x10
**Required furniture/objects:**
- Harbor master's desk (2 tiles, facing door)
- Nautical charts on wall (2 tiles, wall decoration)
- Logbook on desk (examinable)
- Window overlooking harbor (wall tile, back wall)
- Ship model or navigation instruments (1 tile, decorative)

**Optional furniture/objects:**
- Rope coils and anchor hardware (wall decoration)
- Tide table (wall-mounted chart)
- Signal flags (hanging from ceiling)
- Smuggling compartment (hidden, under desk or behind chart)
- Waiting bench for petitioners

**NPC positions:**
- Harbor master: behind desk, facing south
- Optional dock worker or sailor: standing near door

**Interaction points:**
- Harbor master dialogue: ship schedules, coastal information, quest hooks
- Logbook: readable (ship manifests, tide records -- foreshadowing in Bellhaven: "tide has risen two feet in three years")
- Nautical charts: examinable (coastal geography)
- Smuggling compartment: hidden, quest-triggered discovery
- Door: bottom wall, center

---

### Market Stall (Outdoor)

**Standard size:** 4x3 (per stall, arranged in rows along streets or plazas)
**Required furniture/objects:**
- Counter or display table (2 tiles wide, 1 tile deep)
- Awning or canopy overhead (2-3 tiles, canvas tile)
- Displayed goods on counter (variant tiles for produce, weapons, textiles, potions)

**Optional furniture/objects:**
- Crate or basket beside stall (stock)
- Sign tile (hanging from awning)
- Rug or mat in front of stall
- Decorative bunting between stalls

**NPC positions:**
- Vendor: behind counter, facing south
- Optional customer NPC: facing counter

**Interaction points:**
- Buy/sell trigger: 1 tile south of counter
- Not a full building -- placed directly on town exterior tilemap
- Multiple stalls compose a market district

---

## 2. Furniture & Object Palette

### Furniture

#### Tables

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Small table | 1x1 | Square, wooden, seats 1-2 | Homes, small shops |
| Medium table | 2x1 | Rectangular, seats 2-4 | Taverns, inns, dining rooms |
| Large table | 2x2 | Rectangular, seats 4-6 | Council chambers, noble homes |
| Round table | 2x2 | Circular top, seats 3-4 | Taverns, inns, common rooms |
| Desk | 2x1 | Flat top with drawer detail | Offices, studies, guard stations |
| Workbench | 2x1 | Thick top with tool marks | Workshops, forges, labs |

#### Chairs

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Wooden chair | 1x1 | Simple, straight-back | Common homes, taverns, barracks |
| Ornate chair | 1x1 | Carved back, upholstered seat | Noble homes, offices |
| Throne | 1x1 | High back, armrests, faction emblem | Throne rooms only |
| Stool | 1x1 | Backless, round or square top | Bars, workshops, market stalls |
| Bench | 2x1 | Backless, seats 2 | Barracks, temples, public spaces |
| Pew | 2x1 | Backed bench | Temples, churches |

#### Beds

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Single bed | 1x2 | Wood frame, thin mattress | Small homes, barracks, inn rooms |
| Double bed | 2x2 | Larger frame, thicker mattress | Medium homes, inn suites |
| Cot | 1x2 | Folding frame, canvas | Barracks, camps, prisons |
| Bunk bed | 1x2 | Stacked double, ladder detail | Barracks, worker housing, ships |
| Canopy bed | 2x2 | Four posts, draped fabric | Noble homes, royal chambers |
| Sleeping pallet | 1x2 | Woven reed on floor | Thornmere settlements, monasteries |

#### Shelves

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Bookshelf | 1x2 (wall) | Tall, filled with books | Libraries, homes, studies |
| Weapon rack | 1x2 (wall) | Horizontal pegs, swords/spears displayed | Weapon shops, barracks, guard stations |
| Potion shelf | 1x2 (wall) | Glass bottles, jars, labeled containers | Potion shops, healers, temples |
| Armor stand | 1x1 | Full-body display frame with armor piece | Armor shops, barracks, noble homes |
| Display shelf | 1x2 (wall) | Open shelving, miscellaneous goods | General stores, merchant homes |

#### Counters

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Shop counter | 2x1 or 3x1 | Waist-height, flat top, front panel | All shops |
| Bar counter | 4x1 to 6x1 | Long, with stool positions on customer side | Taverns, inns |
| Desk counter | 2x1 | Like a desk but positioned as a service point | Inn front desks, dock offices |

#### Storage

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Chest (wood) | 1x1 | Simple hinged box, brown | Common homes, storage rooms |
| Chest (iron) | 1x1 | Metal-banded, padlock detail | Barracks, warehouses |
| Barrel | 1x1 | Cylindrical, wooden staves | Taverns, warehouses, docks |
| Crate | 1x1 | Square box, nailed shut | Warehouses, docks, shops |
| Wardrobe | 1x2 (wall) | Tall cabinet with doors | Bedrooms, noble homes |
| Cabinet | 1x1 | Short cabinet with doors or drawers | Kitchens, offices, labs |
| Crate stack | 1x2 | Two crates stacked vertically | Warehouses, loading docks |
| Barrel row | 2x1 or 3x1 | Multiple barrels side by side | Taverns (behind bar), warehouses |

---

### Fixtures

#### Doors

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Wooden door | 1x1 | Standard entry/exit, brown wood | Most buildings |
| Iron door | 1x1 | Heavy, dark metal, riveted | Prisons, military buildings, Carradan |
| Ornate door | 1x1 | Carved wood or inlaid metal, gold/brass trim | Noble homes, temples, throne rooms |
| Locked door | 1x1 | Any door with visible lock or keyhole detail | Quest-gated areas |
| Hidden door | 1x1 | Appears as wall tile until triggered | Secret rooms, quest areas |
| Double door | 2x1 | Two-panel grand entrance | Temples, throne rooms, large buildings |

#### Stairs

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Staircase up | 2x2 | Ascending steps, railing detail | Multi-floor buildings |
| Staircase down | 2x2 | Descending steps into dark | Basements, cellars, dungeons |
| Spiral stair | 1x1 | Compact circular staircase | Towers, cramped multi-floor buildings |
| Ladder | 1x1 | Vertical rungs against wall | Warehouses, ships, lofts |

#### Hearth & Heat

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Fireplace | 2x1 (wall) | Stone surround, animated flame (2-frame flicker) | Inns, homes, halls |
| Large fireplace | 3x1 (wall) | Grand hearth with mantle | Noble homes, great halls, monasteries |
| Oven | 1x1 | Brick dome, dark opening | Kitchens, bakeries |
| Forge | 2x2 | Open fire pit with hood, animated flame (4-frame pulse) | Workshops, smithies |
| Brazier | 1x1 | Iron basket on stand, animated flame | Barracks, military posts, outdoor areas |
| Cooking pot | 1x1 | Cauldron over small fire | Small homes, camps |

#### Windows

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Standard window | 1x1 (wall) | Rectangular, wooden frame, shows exterior light color | Most buildings |
| Stained glass | 1x1 (wall) | Colored panels, casts tinted light on floor | Temples, noble homes |
| Barred window | 1x1 (wall) | Iron bars over opening | Prisons, military buildings |
| Glass-paned | 1x1 (wall) | Multi-pane glass, Carradan style | Merchant homes, laboratories |
| Shuttered | 1x1 (wall) | Closed wooden shutters | Abandoned buildings, storms |

#### Light Sources

| Object | Tile Size | Description | Glow Radius | Used In |
|--------|-----------|-------------|-------------|---------|
| Candle | 1x1 | Single candle on table or saucer | 2 tiles (warm amber) | Small homes, cells |
| Candelabra | 1x1 | Multi-armed standing candle holder | 3 tiles (warm amber) | Noble homes, temples |
| Oil lamp | 1x1 | Glass-and-metal table lamp | 2 tiles (warm yellow) | Common homes, taverns |
| Chandelier | 2x2 (ceiling) | Hanging multi-candle fixture | 4 tiles (warm amber) | Great halls, noble homes |
| Wall sconce | 1x1 (wall) | Bracket-mounted torch or candle | 2 tiles (warm amber) | Corridors, all buildings |
| Arcanite lamp | 1x1 | Carradan tech: glass tube with blue-white glow | 3 tiles (cold white-blue) | Carradan buildings only |
| Ley-lamp | 1x1 | Valdris enchanted stone, gold glow | 3 tiles (warm gold) | Valdris buildings only |
| Spirit crystal | 1x1 | Thornmere: bioluminescent crystal in carved holder | 2 tiles (teal-purple) | Thornmere buildings only |
| Gas lamp | 1x1 | Carradan: piped gas, steady flame | 3 tiles (amber-white) | Carradan upper-class buildings |

---

### Interactive Objects

#### Treasure Chests

| Variant | Tile Size | Description | Behavior |
|---------|-----------|-------------|----------|
| Wood chest | 1x1 | Simple wooden box, hinged lid | Opens on interaction, single item reward, stays open |
| Iron chest | 1x1 | Metal-banded, sturdier appearance | Opens on interaction, better loot tier |
| Ornate chest | 1x1 | Gold trim, jeweled clasp | Opens on interaction, rare loot tier |
| Locked chest | 1x1 | Any chest with visible padlock | Requires key item or lockpick ability |
| Trapped chest | 1x1 | Identical to normal chest until triggered | Battle encounter or damage on open, then loot |
| Mimic | 1x1 | Identical to ornate chest | Initiates boss-tier battle encounter on open |

All chests use a 2-frame open animation (closed -> lid up) and remain in the open-lid sprite after looting.

#### Save Points

Save points in Pendulum of Despair manifest as **ley line wellsprings** -- small circular formations where ley energy surfaces through the floor. The visual is a 2x2 cluster of tiles with a gentle pulse animation:

- **Healthy (Acts I-II):** A warm amber-gold glow (`#D4A832`) pulsing from cracks in the floor tile, with 1-2 mote particles drifting upward. The surrounding floor tiles have faint geometric inlay lines connecting to the wellspring -- a subtle echo of the Ancient Ruins' visual language, suggesting the ley network runs beneath everything.
- **Weakening (late Act II):** The pulse slows. The gold shifts toward pale amber. Mote particles are fewer.
- **Corrupted areas (Interlude):** The glow is dim grey-blue, barely visible. The pulse is irregular. Still functional -- the ley lines persist beneath the Pallor.
- **Pallor Wastes (Act III):** Save points appear as clearings where color returns in a tiny radius. The wellspring glows its original amber-gold within a 3-tile radius of restored color against the grey. These are the only warm light in the Wastes.

Save points are placed near building entrances (inns especially), at dungeon mid-points, and in town squares. Interaction triggers the save menu. The wellspring animation continues during the menu.

#### Shop Interfaces

The buy/sell menu triggers when the player presses the action button while facing a shopkeeper across a counter. The trigger tile is the 1-tile space directly south of the counter's center (the player's standing position). The counter itself is the visual anchor -- the player sees their character face the shopkeeper across it, establishing the transaction space.

For market stalls, the trigger is the tile directly south of the stall's display counter. Same mechanic, outdoor context.

#### Inn Rest Trigger

The rest interface triggers when the player talks to the innkeeper at the front desk. Selecting "Stay the night" initiates:
1. Screen fade to black (0.5s)
2. Brief night-sky tile with moon (1s hold)
3. Fade to morning scene in the guest room (player in bed, then standing)
4. Full HP/MP restoration, status cleared
5. Player exits guest room back to inn common area

#### Readable Objects

| Object | Tile Size | Description | Content |
|--------|-----------|-------------|---------|
| Book on shelf | 1x1 (wall) | Part of bookshelf tile, distinct "readable" highlight | Lore text, 2-4 lines |
| Open book | 1x1 (table) | Book propped open on table or stand | Quest-relevant information, 3-6 lines |
| Scroll | 1x1 (table/shelf) | Rolled parchment, sometimes sealed | Ancient lore, letters, orders |
| Note | 1x1 (table/wall) | Small paper, pinned or placed | Short messages, clues, personal content |
| Tombstone | 1x1 | Outdoor object, stone slab | Names, dates, epitaphs |
| Wall inscription | 1x1 (wall) | Carved text on wall tile | Ancient warnings, dedications |
| Notice board | 1x2 (wall) | Wooden board with pinned papers | Side quest hooks, local news, bounties |

#### Switches & Levers

| Object | Tile Size | Description | Behavior |
|--------|-----------|-------------|----------|
| Floor switch | 1x1 | Pressure plate set into floor | Activates when stepped on, deactivates when stepped off |
| Wall lever | 1x1 (wall) | Iron lever, up/down positions | Toggles on interaction -- 2-frame animation (up/down) |
| Crank wheel | 1x1 (wall) | Circular wheel, Carradan style | Rotates on interaction -- opens gates, moves platforms |
| Spirit totem | 1x1 | Thornmere: carved wood, glows when active | Activates on interaction with correct party member or item |
| Rune plate | 1x1 | Ancient Ruins: geometric inlay, dormant/active states | Part of ruins puzzle sequences |

---

### Decorative Objects

#### Soft Furnishings

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Small rug | 2x2 | Woven textile, floor covering | Homes, inns, shops |
| Large rug | 3x2 or 4x3 | Patterned carpet | Noble homes, throne rooms |
| Tapestry | 1x2 (wall) | Hanging woven art, faction-specific imagery | Valdris buildings, temples |
| Curtain | 1x2 (wall) | Fabric panel, can serve as soft room divider | Bedrooms, inns |
| Banner | 1x2 (wall) | Faction flag, hanging from wall mount | Military buildings, government, temples |

#### Art & Display

| Object | Tile Size | Description | Used In |
|--------|-----------|-------------|---------|
| Painting | 1x1 (wall) | Framed artwork, faction-appropriate subject | Noble homes, government buildings |
| Potted plant | 1x1 | Ceramic pot with leafy plant | Homes, shops, inns |
| Flower vase | 1x1 | Glass or ceramic with flowers | Medium/large homes, inns |
| Armor display | 1x1 | Decorative full suit on stand | Noble homes, barracks halls |
| Trophy mount | 1x1 (wall) | Mounted animal head or weapon | Taverns, hunting lodges |
| Trophy case | 2x1 | Glass-fronted display cabinet | Noble homes, museums, halls |
| Clock | 1x1 (wall) | Mechanical clock face (Carradan) or sundial (Valdris) | Government buildings, wealthy homes |
| Mirror | 1x1 (wall) | Framed reflective surface | Bedrooms, armor shops |
| Statue | 1x1 | Small figure on pedestal | Temples, government buildings |

#### Faction-Specific Decor

**Valdris Decor:**
- Heraldic banner: `#D4A832` gold lion on blue field, hanging from iron bracket
- Ley-lamp bracket: carved limestone sconce holding a glowing gold orb
- Tapestry: woven scene of the Seven Towers, greens and golds
- Royal seal: carved limestone medallion above doorways

**Carradan Decor:**
- Gear ornament: brass gear cluster mounted on wall, decorative
- Pipe fitting display: exposed copper and brass pipes as intentional aesthetic
- Consortium seal: iron and brass medallion with interlocking gear design
- Arcanite accent strip: thin blue-white glowing line along wall base or ceiling

**Thornmere Decor:**
- Spirit-ward: carved heartwood pendant hanging from root-ceiling, purple glow
- Vine lattice: living vines trained across wall or ceiling, with bioluminescent moss
- Totem pole fragment: carved wood column with spirit faces, teal glow at eyes
- Woven spirit-catcher: circular reed frame with ley-cord web, hung in doorways

---

## 3. Faction Style Variants

Every building type exists in up to three faction variants. The floor plan and required furniture remain the same -- what changes is the wall material, floor material, lighting type, and decorative objects. This section defines the faction-specific tile swaps.

### Valdris Style

**Walls:** Pale limestone blocks (`#D6CDB8` light, `#8A7F6E` shadow). Interior walls may be plastered smooth and whitewashed. Timber framing visible in older or common buildings.
**Floors:** Flagstone (`#B8A882` warm grey-tan) in public buildings. Dark wood plank (`#8B6B42`) in homes and shops. Stone tile in temples.
**Ceilings:** Exposed timber beams (dark wood) in common buildings. Vaulted stone in temples and government buildings.
**Lighting:** Ley-lamps (warm gold glow), candles, oil lamps, fireplaces. Warm amber tone throughout.
**Doors:** Oak with iron hinges. Ornate doors have carved relief and gold-painted trim.
**Windows:** Wooden-framed. Stained glass in temples and noble homes. Shuttered in common homes.
**Decor emphasis:** Tapestries, heraldic banners, carved stone, polished wood. Ley-lamp brackets as status symbols -- more lamps means more wealth. Potted plants and flowers (the highlands' fertility expressed indoors).

**Emotional tone:** Warm, traditional, established. These interiors feel lived-in and generational. Furniture is old but maintained. The warmth comes from natural materials and golden light.

### Carradan Style

**Walls:** Brick (`#A86B4E` light, `#6B3E2A` soot-stained). Interior walls in upper-class buildings may be plastered over brick. Industrial buildings leave brick exposed. Metal plate walls in factories and military buildings.
**Floors:** Brick tile in standard buildings. Metal grating (`#5A5A62`) in industrial areas. Polished stone or metal in upper-class buildings. Worn concrete in worker housing.
**Ceilings:** Exposed pipe clusters and metal beams. Riveted steel plate in industrial buildings. Plastered in upper-class areas.
**Lighting:** Arcanite lamps (cold white-blue), gas lamps (amber-white), forge glow from nearby machinery. Harsh, directional, creating sharp shadows.
**Doors:** Iron or steel, riveted. Upper-class doors have brass fittings and glass panels. Industrial doors slide on tracks.
**Windows:** Glass-paned (multi-pane industrial style). No glass in worker housing (shuttered or open). Barred in military. Stained glass does not exist in Carradan tradition.
**Decor emphasis:** Brass fittings, gear ornaments, exposed pipe runs, mechanical displays. Functionality as aesthetic. The Consortium seal appears in government buildings. Precision instruments in workshops. Status is shown through engineering quality, not art.

**Emotional tone:** Functional, pressurized, stratified. Upper-class interiors gleam with brass and glass. Lower-class interiors are bare brick and metal. The constant hum of machinery is felt even indoors -- pipes vibrate, floors tremble faintly near factories.

### Thornmere Style

**Walls:** Living wood -- bark-textured root walls (`#4A3A2E` trunk, `#6B4A30` heartwood) that curve organically. No straight lines. Woven reed panels in Duskfen-style buildings. Heartwood (smoothed, carved) in formal spaces.
**Floors:** Root-mat flooring (packed roots and earth, `#2A3A28`). Woven reed mats in living spaces. Smooth heartwood planks in spirit-speaker chambers.
**Ceilings:** Root archways overhead. Hanging root tendrils. Bioluminescent moss growing on ceiling surfaces.
**Lighting:** Bioluminescent moss (teal `#68D8B8`), spirit crystals (purple `#B088D8`), will-o'-wisp lanterns (yellow-green `#C8D858`). Soft, diffuse, organic. No harsh shadows -- light comes from everywhere and nowhere.
**Doors:** No doors in the traditional sense. Doorways are root archways, sometimes with woven vine curtains. Heartwood sliding panels in private spaces.
**Windows:** No windows -- the concept does not apply. Root walls have natural gaps where filtered light enters, or bioluminescent moss provides ambient illumination.
**Decor emphasis:** Spirit-wards (carved heartwood pendants), hanging herb baskets, carved wood bowls, woven spirit-catchers, totem poles with spirit faces. Living vines trained as decoration. No metal. No glass. Everything the forest provides.

**Emotional tone:** Organic, spiritual, intimate. These interiors breathe. The walls curve. The light pulses faintly with the ley line heartbeat. Furniture is grown or carved, never manufactured. The boundary between inside and outside is soft.

---

### Faction Variant Matrix

This matrix shows which faction variants exist for each building type and what specifically changes beyond the base material swaps above.

| Building Type | Valdris Variant | Carradan Variant | Thornmere Variant |
|--------------|----------------|-----------------|-------------------|
| **Weapon Shop** | Swords and shields on racks; royal crest above counter | Forgewright weapons in glass cases; mechanical displays; Arcanite-edged blades | Spirit-bound weapons on living wood racks; no metal -- bone, heartwood, crystal |
| **Armor Shop** | Plate and chain on stands; heraldic designs on shields | Brass-and-iron powered armor; gear-joint displays; welding station | Woven root-bark armor on vine hangers; spirit-ward inlaid pieces |
| **Item/Potion Shop** | Herb bundles, glass bottles, ley-infused remedies | Chemical vials in metal racks, precise labels, gas burner station | Herbs growing from wall moss, bark containers, spirit-infused salves |
| **General Store** | All-purpose village shop, friendly clutter | Compact supply depot, organized shelving, stamped crates | Community cache in root-chamber, shared goods on heartwood shelves |
| **Inn** | Stone hearth, tapestries, warm wood; feels like a family home | Metal-framed bunks, common shower, communal mess; feels institutional | Hammocks in root-chambers, bioluminescent night-lights; feels like sleeping in a living tree |
| **Tavern** | Oak bar, hanging tankards, bard's corner, hearth | Iron bar rail, mechanical drink taps, forge-glow accent lighting | Open-air root platform, fermented sap drinks, spirit-story circle |
| **Small House** | Stone and thatch, herbs drying, wool rug | Brick box, metal bunk, company-issue furniture, bare | Root-chamber alcove, sleeping pallet, carved spirit-ward above bed |
| **Medium House** | Timber and stone, garden window, bookshelf, warm | Brick with glass windows, mechanical clock, modest brass fixtures | Carved heartwood chambers, multiple levels via root-ladders, herb garden growing from walls |
| **Large House** | Limestone manor, marble floor, tapestries, grand hearth | Glass-and-brass townhouse, Arcanite lighting, mechanical art, precision furniture | Elder's root-hall, spirit-totem gallery, council seating grown from living wood |
| **Temple** | Limestone nave, stained glass, ley-lamp altar, carved pews | Founders' Hall variant: brass prayer wheels, glass-cased relics, mechanical hymn organ | Spirit shrine: heartwood altar, totem circle, bioluminescent sacred pool |
| **Library** | Stone shelves, leather-bound books, scroll racks, reading alcoves | Metal shelving, indexed filing, mechanical catalog, blueprint storage | Oral history chamber: carved story-walls, memory totems, no books -- knowledge is spoken and spirit-bound |
| **Barracks** | Stone walls, weapon racks, training yard access, commander's map table | Metal bunks in rows, locker system, drill manual posted, uniform press | No permanent barracks -- ranger camps with hide tents, weapon caches in root hollows |
| **Prison** | Stone cells, iron bars, torch-lit corridor | Metal cells, Arcanite lock system, observation grating, ventilation pipes | Spirit-binding circle: wrongdoers are bound to a totem and must meditate until the spirits release them |
| **Government** | Throne room with gold and stone, tapestried walls, ley-lamp grandeur | Consortium chamber: glass table, mechanical voting system, blueprints on every wall | Elder's grove: council circle of carved stone seats beneath the oldest tree, open to sky |
| **Workshop** | Traditional smithy: stone forge, leather bellows, hand tools | Forgewright factory floor: Arcanite engine, precision lathe, assembly station, pipe network | Root-shaping workshop: living wood growth beds, carved tools, spirit-infusion station |
| **Warehouse** | Stone storage with oak barrels and crates, wax-sealed | Iron warehouse: conveyor feeds, crane system, manifested and stamped | Root-cellar: natural cold storage in deep root chambers, preserved with ley-salts |
| **Dock Office** | Wooden harbor-master's hut, hand-drawn charts, brass telescope | Iron-walled port authority: typed manifests, Arcanite signal lamp, mechanical semaphore | Reed-platform dock: woven-rope mooring, spirit-lantern navigation, oral tide records |
| **Market Stall** | Wood-and-canvas stall, hand-painted sign, woven baskets | Metal-frame stall, stamped tin sign, standardized crate display | Ground-cloth spread under canopy tree, goods on woven mats, no permanent structure |

---

## 4. Damaged & Corrupted Variants

Buildings in the Interlude and Act III show the world's decline. Every interior tile in the base palette has up to four damage states, applied selectively based on the location's narrative condition.

### Damage Categories

#### Cracked Wall Variants

Each wall tile (limestone, brick, root-bark) has a cracked variant:
- **Hairline cracks:** 1-2 thin lines across the tile surface. Subtle -- the building is stressed but standing. Used in late Act II and early Interlude.
- **Major cracks:** Wide fractures with visible depth. Mortar or bark crumbles at crack edges. Dust particles (1px) drift near the crack. Used in mid-Interlude.
- **Breach:** A section of wall missing, replaced by rubble tile or dark void tile. Structural failure. Used in late Interlude and Act III.

Implementation: each base wall tile has three cracked overlay variants that composite onto the base. The same crack pattern works across faction styles -- cracks look different in limestone vs. brick vs. root-bark, but the placement logic is shared.

#### Broken Furniture

Every furniture piece has a broken variant:

| Base Object | Broken Variant | Visual |
|-------------|---------------|--------|
| Table (any) | Collapsed table | Legs splayed, top surface tilted or split |
| Chair | Overturned chair | On its side, one leg snapped |
| Bed | Stripped bed | Frame intact, mattress gone or torn |
| Bookshelf | Toppled bookshelf | Fallen forward, books scattered (2-3 loose book tiles on floor) |
| Weapon rack | Empty rack | Pegs intact, weapons missing |
| Armor stand | Toppled stand | Fallen, armor pieces scattered |
| Counter | Cracked counter | Surface split, one end collapsed |
| Chest | Smashed chest | Lid broken off, contents gone or scattered |
| Barrel | Broken barrel | Staves split, pooled liquid tile beneath |
| Chandelier | Fallen chandelier | On floor, bent arms, no flame |

Broken furniture tiles occupy the same footprint as intact versions. Placement is selective -- not every piece in a damaged building is broken. A 30-50% breakage rate per room feels realistic; 70%+ reads as ransacked.

#### Rubble Tiles

| Tile | Size | Description | Used For |
|------|------|-------------|----------|
| Stone rubble (small) | 1x1 | Loose stones and mortar chunks | Wall breaches, collapsed sections |
| Stone rubble (large) | 2x1 | Larger blocks, impassable | Major structural collapse |
| Brick rubble | 1x1 | Broken brick fragments, red-brown | Carradan building damage |
| Wood debris | 1x1 | Splintered timber, broken planks | Roof collapse, Valdris/Thornmere damage |
| Root debris | 1x1 | Cracked, dried root fragments | Thornmere petrification damage |
| Dust/ash layer | 1x1 | Semi-transparent overlay on floor tiles | Abandoned interiors |
| Fallen beam | 2x1 | Timber or metal beam on floor, impassable | Structural collapse, blocks paths |
| Shattered glass | 1x1 | Glittering fragments on floor | Carradan window breaks, laboratory damage |

Rubble tiles are placed on the floor layer, occupying walkable space. Large rubble and fallen beams block movement, creating navigation changes in damaged buildings.

#### Pallor-Corrupted Variants

The Pallor corruption overlay system (defined in `biomes.md` Section 5) applies to interiors as well as exteriors. Interior corruption follows the same three stages:

**Stage 1 -- Subtle (Late Act II, Early Interlude):**
- Desaturation: 15-20% palette drain on all interior tiles
- Ley-lamps and spirit crystals flicker: 1 in 4 frames show dimmed state
- 1 in 8 floor tiles shows a faint grey discoloration at edges
- Temperature drops: fireplace flames animate slower (longer pause between flicker frames)
- Ambient sound: the building's interior ambience loses 10% volume

**Stage 2 -- Obvious (Interlude):**
- Desaturation: 40-50% palette drain
- Grey static noise: 3-5 pixel clusters appear on walls, lingering for several frames
- 1 in 3 tiles shows grey creep from edges inward (animated, slow spread)
- Light sources struggle: flames gutter, ley-lamps strobe between gold and grey, Arcanite lamps shift from blue-white to grey-white
- NPCs: some stand motionless with empty dialogue ("..." or repeated fragments)
- Furniture: objects look faded, as if the color has been leached out of the wood grain

**Stage 3 -- Terminal (Late Interlude, Act III edges):**
- Desaturation: 80-90% palette drain
- Grey static frequent: covers 5-10% of interior tile area at any time
- All lighting shifts to grey -- no warm tones remain
- Walls show grey crystalline growth (organic-looking but lifeless) in corners and along edges
- Furniture is intact but colorless -- like a photograph bleached by sun
- No NPCs present -- abandoned
- The interior is recognizable but dead. The shape of a home with none of its life.

#### Abandoned Variants

Distinct from Pallor corruption -- buildings can be abandoned due to war, displacement, or economic collapse without supernatural influence.

**Visual markers:**
- Dust layer: semi-transparent grey overlay on all floor tiles
- Cobweb tiles: placed in corners and on unused furniture (2-3 per room)
- Overturned furniture: 20-30% of movable objects displaced
- Empty shelves: bookshelf, weapon rack, and potion shelf variants with contents removed
- Boarded windows: wooden plank tiles nailed across window tiles
- Faded signage: shop signs with worn paint, barely legible
- Weed growth: small plant tiles pushing through floor cracks (Valdris/Thornmere only)
- Rat tiles: small animated vermin in corners, scurrying when approached

Abandoned buildings retain their original color palette (not desaturated like Pallor corruption). The distinction matters narratively: abandonment is human, the Pallor is something else.

---

## 5. Standard Interior Layout Templates

These ASCII templates define the base arrangement for the 12 most common building types. Each template is a starting point -- individual instances modify placement, add optional objects, and apply faction material swaps.

Legend (shared across all templates):
```
# = wall          . = open floor       D = door
C = counter       T = table            c = chair
B = bed           K = bookshelf        W = weapon rack
A = armor stand   P = potion shelf     S = staircase
F = fireplace     H = chest            R = barrel
X = crate         L = light source     @ = NPC position
* = save point    O = ornate/special   E = empty display
G = iron bars     V = lever/switch     M = rug
```

---

### Template 1: Weapon Shop (12x10)

```
############
#W.CC.@.W.A#
#W........A#
#..........#
#.T..MM..T.#
#.c..MM..c.#
#..........#
#.A......W.#
#.....DD...#
############
```

The shopkeeper (`@`) stands behind a 2-tile counter (`CC`). Weapon racks (`W`) line the left wall; armor stands (`A`) occupy the right. Two display tables (`T`) with chairs (`c`) sit mid-room for customers to examine goods. A rug (`M`) in the center adds warmth. The door (`DD`) is bottom-center.

---

### Template 2: Item / Potion Shop (10x10)

```
##########
#P.CC.@.P#
#P......P#
#........#
#........#
#.T.c....#
#........#
#.R..X.H.#
#...DD...#
##########
```

Potion shelves (`P`) line both side walls. The shopkeeper (`@`) works behind a counter (`CC`). A small table (`T`) and chair (`c`) allow the shopkeeper to mix remedies. Storage (barrel `R`, crate `X`, chest `H`) occupies the back corners.

---

### Template 3: Inn -- Main Floor (16x14)

```
################
#FFF...........#
#......T.c.c.T.#
#..............#
#..T.c.c.T.....#
#..............#
#.....*.....SS.#
#..............#
#.T.c.c.T..SS.#
#..............#
#..CC.@........#
#..............#
#......DD......#
################
```

A large fireplace (`FFF`) dominates the back wall. Multiple tables (`T`) with chairs (`c`) fill the common room. The innkeeper (`@`) stands behind a counter (`CC`). A save point (`*`) sits mid-room near the staircase (`SS`) leading to guest rooms. The stairs are on the right side.

---

### Template 4: Inn -- Upper Floor (12x10)

```
############
#B...#B...B#
#B..L#B...B#
#....#.....#
#..........#
#....#.....#
#B..L#B...B#
#B...#B...B#
#..SS......#
############
```

Two or three guest rooms separated by interior walls. Each room has beds (`B`) and a light source (`L`). The staircase (`SS`) connects back to the main floor. Simple, functional.

---

### Template 5: Tavern (14x12)

```
##############
#RRRCC....@.R#
#RRR.C......R#
#............#
#.Tc..Tc..Tc.#
#............#
#.Tc..Tc.....#
#..........E.#
#............#
#.Tc..Tc.....#
#.......DD...#
##############
```

The bar counter (`C`) spans the back-left with barrel storage (`RRR`) behind it. The barkeeper (`@`) stands behind the counter. Tables (`T`) with chairs (`c`) fill the floor in a grid pattern. An entertainment area (`E` -- stage or fireplace) sits on the right side. Barrel racks (`R`) flank the bar.

---

### Template 6: Residential House -- Small (8x8)

```
########
#FF..H.#
#......#
#.Tc...#
#......#
#.BB...#
#......#
#..DD..#
########
```

A single room. Fireplace (`FF`) in the back-left. A chest (`H`) in the back-right corner. A small table (`T`) with chair (`c`) in the middle. A single bed (`BB`) against the wall. Door at the bottom. Everything a peasant needs; nothing more.

---

### Template 7: Residential House -- Medium (12x10)

```
############
#FF..K..K..#
#..........#
#.TT.cc....#
#..........#
#..........#
#.BB.......#
#.BB..H..K.#
#.....DD...#
############
```

Two functional areas: the living space (back wall with fireplace `FF` and bookshelves `K`, dining table `TT` with chairs `cc`) and the sleeping area (double bed `BB`, chest `H`, wardrobe/bookshelf `K`). More space, more possessions, more personality than the small house.

---

### Template 8: Temple (14x16)

```
##############
#L....OO....L#
#............#
#.cc......cc.#
#.cc......cc.#
#............#
#.cc......cc.#
#.cc......cc.#
#............#
#.cc......cc.#
#.cc......cc.#
#............#
#L..........L#
#............#
#.....DD.....#
##############
```

The altar (`OO`) is centered on the back wall, flanked by light sources (`L`). Pews (`cc`) are arranged in two columns with a center aisle. Light sources mark the corners. The double door (`DD`) is at the bottom center. The long, narrow proportion creates a nave-like feeling even in tile art.

---

### Template 9: Library (14x14)

```
##############
#KKKK..KKKKK#
#............#
#K.TT.cc..TK#
#K........TK#
#K..........#
#K.TT.cc...K#
#K.........K#
#............#
#K.CC.@....K#
#K.........K#
#............#
#......DD....#
##############
```

Bookshelves (`K`) line every wall and form internal rows. Reading tables (`TT`) with chairs (`cc`) are scattered between the stacks. The librarian sits at a desk-counter (`CC`) near the entrance. The density of shelving makes the space feel maze-like and scholarly.

---

### Template 10: Barracks (14x12)

```
##############
#WW.A..CC.@.A#
#............#
#.BB..BB..BB.#
#............#
#.BB..BB..BB.#
#............#
#.TT.cc......#
#.......F....#
#............#
#.H..H..DD..#
##############
```

The commanding officer's desk (`CC`) is in the back-right corner with weapon racks (`W`) and armor stands (`A`). Bunk beds (`BB`) fill the middle in rows. A mess table (`TT`) with chairs (`cc`) and fireplace (`F`) form the common area. Personal chests (`H`) sit near the door.

---

### Template 11: Government -- Mayor's Office (12x10)

```
############
#K...CC..@K#
#K........K#
#..........#
#..c....c..#
#..........#
#.....F....#
#..........#
#.....DD...#
############
```

Bookshelves (`K`) line both side walls. The mayor's desk (`CC`) faces the door from the back wall. Guest chairs (`c`) face the desk. A fireplace (`F`) provides warmth. Sparse but authoritative. The desk position puts the authority figure in a commanding position as the player enters.

---

### Template 12: Workshop / Forge (12x12)

```
############
#.OOOO.....#
#..........#
#.TT.......#
#.TT..X.X..#
#..........#
#.RR...H...#
#..........#
#..........#
#..........#
#.....DD...#
############
```

The forge (`OOOO`) dominates the back wall -- a 4-tile wide furnace with anvil adjacent. The workbench (`TT`) sits to the left. Material storage (crates `X`, barrels `RR`, chest `H`) clusters on the right. The lower half of the room is open -- workspace for smithing and assembly. The heat from the forge is the room's primary light source and atmosphere.

---

## 6. Composition Rules

These rules govern how the modular templates above combine to create buildings that feel unique despite sharing components. The goal is the SNES-era illusion: dozens of interiors that feel hand-crafted, built from a shared pool of maybe 100-150 unique tiles.

### Rotation and Mirroring

Any template can be horizontally mirrored to create a variant. A weapon shop with racks on the left in one town has racks on the right in the next. This doubles the effective template count at zero tile cost.

**Rules:**
- Mirror the entire layout, including NPC positions and door placement
- Do not mirror individual furniture tiles -- a chair is a chair regardless of room orientation
- Vertical mirroring (flipping top/bottom) is generally not used because the door convention expects entry from the bottom of the screen (the player walks "into" the building going north)
- 90-degree rotation is possible for non-rectangular rooms but rare -- most SNES interiors use the "enter from the south" convention

### Adding and Removing Optional Objects

The templates define required furniture positions. Optional objects fill the remaining open floor tiles.

**Density guidelines:**
- **Sparse (poor/abandoned):** 30-40% floor coverage. Open space reads as empty, austere, or impoverished.
- **Standard (middle class):** 50-60% floor coverage. Comfortable, lived-in, functional.
- **Dense (wealthy/cluttered):** 70-80% floor coverage. Rich, full, or hoarded. The player navigates narrow paths between furniture.

**Variation technique:** For the same building type in two towns, keep required furniture identical but swap optional objects. Town A's inn has a bard stage; Town B's inn has a bookshelf nook. Same template, different personality.

### Connecting Multiple Rooms

Buildings larger than a single template use room connection tiles to join modules.

**Connection types:**

| Connection | Implementation | Used For |
|-----------|----------------|----------|
| **Interior doorway** | 1-tile gap in an interior wall, no door tile | Room-to-room within a building |
| **Interior door** | 1-tile gap with door tile | Private rooms (bedrooms, offices) |
| **Hallway** | 2-3 tile wide corridor connecting rooms | Large buildings (noble houses, barracks) |
| **Staircase** | 2x2 stair tile, transitions to separate map | Multi-floor buildings |
| **Ladder** | 1x1 tile, transitions to separate map | Compact vertical access (towers, lofts) |

**L-shaped buildings:** Place two templates perpendicular, overlapping at a 2-3 tile wide connection zone. The connection zone has no interior walls -- just open floor. Example: a tavern (14x12) connected to a kitchen/storage room (8x8) at the back-right corner, forming an L.

**Multi-floor buildings:** Each floor is a separate tilemap, connected by staircase or ladder transition tiles. The upper floor template should be slightly smaller or the same size as the ground floor (architecturally, upper floors do not extend beyond the ground footprint). Exception: Carradan buildings, where upper floors can cantilever outward on iron beams.

### Back Rooms and Basements

**Back rooms** are small (6x6 to 8x8) templates appended behind the main room via an interior doorway. They serve as:
- Storage (shop back room: extra crates, wholesale stock)
- Private quarters (shopkeeper's bedroom behind the shop)
- Secret areas (hidden door leading to quest content)

**Basements** are accessed via a staircase-down tile. They are separate tilemaps, typically:
- 1-2 tiles smaller in each dimension than the ground floor
- Darker (no windows -- torch or lamp light only)
- Used for: wine cellars, hidden laboratories, smuggling caches, dungeon entrances, quest-specific content

**Hidden rooms:** Accessed through hidden door tiles (appear as wall until triggered by quest flag, switch, or examine action). Always placed on interior walls, never exterior. The "secret passage behind the bookshelf" and "hidden cellar under the rug" are both implemented as hidden door tiles with appropriate trigger conditions.

### Wealth Scaling

The same building type at different wealth levels uses the same base template with systematic modifications:

**Poor variant:**
- Wall material: roughest available (rough timber for Valdris, bare brick for Carradan, unfinished root for Thornmere)
- Floor: dirt or bare stone (no rugs)
- Furniture: only required objects, cheapest variants (wooden stool instead of chair, cot instead of bed)
- Lighting: single candle or oil lamp (minimum light sources)
- Decor: none
- Storage: 1 barrel or small chest
- Density: sparse (30-40% coverage)

**Standard variant:**
- Wall material: standard faction material
- Floor: wood plank or standard tile (1 small rug)
- Furniture: required objects plus 2-3 optional items
- Lighting: 2-3 light sources (wall sconces, table lamp)
- Decor: 1-2 items (painting, potted plant)
- Storage: chest and wardrobe
- Density: standard (50-60% coverage)

**Wealthy variant:**
- Wall material: finest available (polished limestone, clean brick with brass trim, carved heartwood)
- Floor: polished stone or fine wood (large ornate rug)
- Furniture: required objects plus 5-8 optional items, ornate variants (ornate chair, canopy bed, carved table)
- Lighting: chandelier plus wall sconces, ley-lamp brackets or Arcanite accent strips
- Decor: tapestries, paintings, trophy case, armor display, potted plants, flowers
- Storage: ornate chests, glass-fronted display cabinets
- Density: dense (70-80% coverage)

**Example -- Residential House (Small template, 8x8):**

Poor version:
```
########
#......#
#......#
#.Tc...#
#......#
#.B....#
#......#
#..DD..#
########
```
One table, one stool, one cot. No fireplace (cooking happens outside). No storage (they own nothing worth storing). The emptiness tells the story.

Standard version:
```
########
#FF..H.#
#......#
#.Tc...#
#......#
#.BB...#
#..MM..#
#..DD..#
########
```
Fireplace, chest, table and chair, bed (not a cot), small rug. Comfortable. Lived-in.

Wealthy version (same 8x8 footprint -- a wealthy person in a small house is rare, but it occurs in cramped cities):
```
########
#FF.KH.#
#.L....#
#.Tc.L.#
#.MMMM.#
#.BB.K.#
#.MMMM.#
#..DD..#
########
```
Fireplace, bookshelf, chest, multiple lights, large rug, better bed, more shelving. Every tile is occupied. The wealth is compressed into the space.

### Unique-Feeling Compositions

To prevent the "every inn looks the same" problem, use these variation techniques in combination:

1. **Mirror the template** (left-right flip)
2. **Shift the door position** (center, left-offset, right-offset)
3. **Swap 2-3 optional objects** (replace the bookshelf with a weapon display, the rug with potted plants)
4. **Apply faction material swap** (same layout in limestone vs. brick vs. root-bark)
5. **Adjust wealth tier** (sparse vs. dense furnishing)
6. **Add or remove a back room** (some shops have back storage, others do not)
7. **Change NPC placement** (shopkeeper on the left vs. right side of counter)
8. **Rotate seasonal/story details** (Act I inn has flowers on the table; Interlude inn has the flowers wilted)
9. **Connect to unique outdoor context** (an inn overlooking the harbor has a window with an ocean-view wall tile; a mountain inn has a frost-window tile)

With 12 base templates, 3 faction styles, 3 wealth tiers, horizontal mirroring, and 2-3 optional object swaps, the combinatorial space produces hundreds of distinct-feeling interiors from approximately 150 shared tiles. This is exactly how the SNES-era games achieved their sense of world density: a reusable vocabulary, deployed with care.

### Special Building Instances

Some story-critical buildings break the template system deliberately. These are one-off interiors designed from scratch to serve specific narrative or mechanical purposes:

- **Cael's Quarters (Valdris Crown):** Medium house template, but the window is a unique tile (cracked from inside, facing the Wilds). The Pendulum's pedestal sits where a nightstand would be. The room darkens across acts.
- **Maren's Refuge:** No template -- the interior is "larger than it should be." Shelves cover every wall. Books are stacked on floors. Root tendrils push through floorboards. A cozy chaos that defies the grid.
- **Lira's Hidden Workshop (Corrund/Caldera):** Carradan workshop template, but hidden behind a false wall. Tools are organized with obsessive precision. A cot in the corner says she sleeps here. Blueprints pinned to every wall show the Pendulum's schematic.
- **The Royal Keep Throne Room:** Government template scaled to 20x18. The throne is oversized. The banners are faded. The room feels too large for its occupant -- the kingdom has outgrown its king.
- **Founders' Hall (Ashmark):** Temple template repurposed for secular worship. The altar is replaced by the original Forgewright anvil in a glass case. Mechanical prayer wheels line the walls. The prayer wheels have stopped turning.

These exceptions are effective because the template system establishes a baseline. When a building breaks the pattern, the player feels it. Maren's cottage is memorable because every other interior follows the rules. The broken rule is the story.
