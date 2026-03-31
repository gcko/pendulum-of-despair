# Interior Layouts -- Pendulum of Despair

Detailed interior maps for story-critical buildings, standard palette-based interiors, multi-floor buildings, shop interaction points, inn/rest sequences, and act-variant interiors. Every layout references the building-palette.md template system and faction style guides. Unique story interiors break the templates deliberately; everything else demonstrates how the palette system works in practice.

All dimensions are in 16x16 pixel tiles. Legend follows building-palette.md conventions unless otherwise noted.

Cross-references: `building-palette.md` (templates, furniture, faction styles), `city-valdris.md`, `city-carradan.md`, `city-thornmere.md` (city layouts), `npcs.md` (character placements), `sidequests.md` (quest triggers), `dynamic-world.md` (act transitions).

---

## Table of Contents

1. [Story-Critical Interiors](#1-story-critical-interiors)
   - [Valdris Crown Throne Room](#11-valdris-crown-throne-room)
   - [Valdris Crown Royal Library](#12-valdris-crown-royal-library)
   - [Maren's Refuge Interior](#13-marens-refuge-interior)
   - [Highcairn Monastery Great Hall](#14-highcairn-monastery-great-hall)
   - [Ironmark Citadel Command Chamber](#15-ironmark-citadel-command-chamber)
   - [The Pendulum Tavern](#16-the-pendulum-tavern)
2. [Standard Interiors Using Building Palette](#2-standard-interiors-using-building-palette)
   - [Valdris Variants](#21-valdris-variants)
   - [Carradan Variants](#22-carradan-variants)
   - [Thornmere Variants](#23-thornmere-variants)
3. [Multi-Floor Buildings](#3-multi-floor-buildings)
   - [Axis Tower Non-Dungeon Floors](#31-axis-tower-non-dungeon-floors)
   - [Corrund Guild Hall](#32-corrund-guild-hall)
   - [Valdris Crown Inn -- The Anchor and Oar](#33-valdris-crown-inn----the-anchor-and-oar)
   - [Canopy Reach Observatory](#34-canopy-reach-observatory)
4. [Shop Interiors with Interaction Points](#4-shop-interiors-with-interaction-points)
5. [Inn/Rest Interiors](#5-innrest-interiors)
6. [Act-Variant Interiors](#6-act-variant-interiors)
   - [Valdris Throne Room Across Acts](#61-valdris-throne-room-across-acts)
   - [A Greyvale House Across Acts](#62-a-greyvale-house-across-acts)
   - [A Caldera Shop Across Acts](#63-a-caldera-shop-across-acts)
   - [Ashmark Factory Floor Across Acts](#64-ashmark-factory-floor-across-acts)
   - [Maren's Refuge Across Acts](#65-marens-refuge-across-acts)

---

## 1. Story-Critical Interiors

These buildings break the standard template system. Each is a one-off layout designed for specific narrative and mechanical purposes. They are memorable because every other interior in the game follows the palette rules -- when a building breaks the pattern, the player feels it.

---

### 1.1 Valdris Crown Throne Room

**Location:** Royal Keep, Valdris Crown (Upper Ward)
**Size:** 20x18 (multi-screen: the room is taller than a single viewport, requiring a vertical scroll or camera follow)
**Narrative role:** Where King Aldren sends the party on their quest (Act I), where the Carradan assault kills the king (Act II), where rubble fills the hall (Interlude), where the tri-faction council convenes (Epilogue).

**Materials:** Valdris style -- pale limestone walls, flagstone floor, dark timber ceiling beams. Ley-lamp brackets every 3 tiles along walls. Stained glass window behind throne (unique tile: Seven Towers motif in gold and blue). Heraldic banners flanking the carpet runner.

#### Act I -- Regal State (Base Layout)

```
Legend (additions):
  t = throne (unique 2-tile, high-backed, gold-trimmed)
  | = column (limestone pillar, 1x1)
  = = carpet runner (red, 2 tiles wide)
  ^ = raised platform (2 tiles deep, full width)
  B = banner (Valdris heraldic, wall-mounted)
  G = royal guard position
  @ = King Aldren

####################
#B.L..........L..B#
#..^^^^^^^^^^^^^^^#
#..^.G..t@t..G..^#
#..^.............^#
#..^^^^^^^^^^^^^^^#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.............#.
#................#.
#.....DDDDDD.....#
####################
```

**Key features:**
- The throne (`t@t`) sits on a raised platform (`^`) spanning the full room width, 2 tiles deep. Aldren stands at center; two royal guards flank him.
- A red carpet runner (`==`) extends from the grand double doors (`DDDDDD` -- 6 tiles, the largest doors in the game) to the platform edge. The player walks the carpet to approach the king.
- Six limestone columns (`|`) form a colonnade on each side, framing the approach. Ley-lamp brackets (`L`) mounted between columns provide warm gold illumination.
- Valdris heraldic banners (`B`) hang from the back wall, flanking the stained glass window above the throne.
- The room is deliberately oversized -- the emptiness between the columns and the carpet communicates that this space was built for hundreds of petitioners. The party of four looks small. The kingdom has outgrown its king.

**Interaction points:**
- Throne: cutscene trigger (Act I quest assignment, Act II Aldren's death)
- Stained glass window: examinable ("The Seven Towers of Valdris, rendered in glass. The gold leaf is chipping.")
- Banners: examinable ("The Valdris lion. The blue dye has faded to grey in places.")
- Columns: no interaction (movement blockers only)

---

### 1.2 Valdris Crown Royal Library

**Location:** Citizen's Walk, Valdris Crown
**Size:** Main hall 16x14, Stacks wing 12x14, Basement archive 14x12 (three connected maps)
**Narrative role:** Where Mirren and Aldis research; where Cael studies the Pendulum in Act I; where Aldis obsesses over Cael's notes in the Interlude. Contains the hidden basement with Mirren's "third Door" document. Secondary save point.

**Materials:** Valdris style -- limestone walls, dark wood floor planks, heavy timber shelving. Ley-lamp reading sconces at every table. The Library predates the current Royal Keep by a century; the stonework is older, the shelves are worn smooth.

#### Main Hall (16x14)

```
Legend (additions):
  K = bookshelf (floor-to-ceiling, dark oak)
  T = reading table (2x1)
  c = reading chair
  @ = Scholar Aldis (position varies by act)
  % = Mirren (Act II+)
  * = save point (ley-line wellspring, in study alcove)
  G = globe/map display (unique tile)
  s = scroll rack (wall-mounted)
  n = card catalog (wooden drawers, Valdris style)
  i = ladder (for reaching high shelves)

################
#KKKKsKsKKKKKK#
#..............#
#K.TT.cc..TT.K#
#K.........i.K#
#..............#
#K.TT.cc.@...K#
#K............K#
#..G...n......K#
#.............K#
#K...*........K#
#K............K#
#.....DD......K#
################
```

**Key features:**
- Bookshelves (`K`) line every wall and form internal divisions. The density exceeds the standard library template (building-palette.md Template 9) -- this is the royal collection, and the shelves are fuller, the aisles narrower.
- The save point (`*`) sits in a recessed study alcove on the left wall -- a semi-private reading nook.
- Scholar Aldis (`@`) stands at a reading table in Act II; in the Interlude, he is at the same table but surrounded by scattered notes (Cael's analysis pages).
- A globe/map display (`G`) shows the continent. Examinable for different lore per act.
- The card catalog (`n`) is a Valdris-specific detail -- wooden drawers with brass pulls, labeled in neat calligraphy.
- A shelf ladder (`i`) is both decorative and interactive -- examining it: "Well-worn. Someone climbs this daily."

#### Stacks Wing (12x14, connected via interior doorway on east wall of Main Hall)

```
############
#KKKKKKsKKK#
#..........#
#K..K..K..K#
#K..K..K..K#
#K..K..K..K#
#...........#
#K..K..K..K#
#K..K..K..K#
#K..K..K..K#
#..........#
#...TT.cc..#
#..........#
############
```

The stacks are a labyrinth of freestanding shelves. No ley-lamps here -- only candle sconces at the aisle ends. The air is dusty. Each shelf cluster is examinable for different lore categories (history, ley theory, spirit-pact records, geography, correspondence). One shelf in the back row has a cracked wall tile behind it -- examining it reveals the passage to the basement archive.

#### Basement Archive (14x12, accessed via hidden stair behind cracked wall)

```
##############
#KKKK....KKKK#
#............#
#K.TT.cc....K#
#K..........K#
#............#
#K...OO.....K#
#K..........K#
#............#
#K.....H....K#
#..SS........#
##############

O = Mirren's sealed cabinet (locked, key item required)
H = hidden document chest (the "third Door" document)
SS = stairs up to Stacks Wing
```

The basement is carved from older stone -- pre-Valdris foundation. Mirren's sealed cabinet contains her private research: the truth about the Pendulum cycle, the three Doors, and her departure from the court. The hidden chest requires a specific quest flag to open. This room is the deepest lore repository in the game.

---

### 1.3 Maren's Refuge Interior

**Location:** Deep Thornmere Wilds
**Size:** Exterior cottage 8x6, Ground floor 16x12, Basement library 16x12 (space-folded: the interior is four times the exterior footprint)
**Narrative role:** Where Maren examines the Pendulum (Act I); where her research sits abandoned (Interlude); where new books appear (Epilogue). The space-folding is old magic -- the interior defies the grid, and the player should feel it.

**Materials:** Hybrid -- stone walls with living root infiltration. Thornmere organic elements (bioluminescent moss, root tendrils through floorboards, spirit creature perches) layered over a constructed stone framework. No faction template applies cleanly. This is a building caught between civilizations.

#### Ground Floor (16x12)

```
Legend (additions):
  K = bookshelf (overflowing, books stacked sideways and on top)
  W = work desk (Maren's analysis station, 2x1)
  F = fireplace (ley-heated, amber glow, no chimney -- the heat dissipates through the roots)
  ~ = root tendril (growing through floor, decorative obstacle)
  p = spirit creature perch (translucent visitors rest here)
  m = map table (world map with pins, 2x1)
  a = artifact display (pre-civ relics on shelf)
  h = herb drying rack (wall-mounted)
  b = Maren's cot (1x2, books piled on it)
  r = reading chair (worn, leather, the one comfortable thing she owns)
  @ = Maren

################
#KK..KK..KK.ah#
#..............#
#.WW...FF......#
#.WW...FF..mm.#
#.@............#
#..~..a......K.#
#......r.....K.#
#..p.........K.#
#.......b.b..~.#
#..............#
#.....DD...p...#
################
```

**Key features:**
- Every wall surface is covered. Bookshelves, herb racks, artifact shelves -- there is no blank wall. This is the densest interior in the game (85%+ coverage).
- Root tendrils (`~`) push through the floorboards in 2-3 places, creating organic obstacles the player routes around. They are not hazards -- they are the forest reminding Maren it owns this place.
- Spirit creature perches (`p`) near the door and in corners. In Act I, small translucent shapes (fox, moth, unidentifiable) rest here. Maren talks to them: "Don't mind them."
- The work desk (`WW`) is where the Pendulum examination cutscene triggers. Maren's notes, magnifying lenses, and ley-measurement instruments clutter the surface.
- The map table (`mm`) shows the continent with colored pins. Examinable: each pin cluster tells a story of Maren's travels.
- The fireplace (`FF`) has no chimney -- the heat from the ley-line tap below radiates through the stone. The glow is warm amber, unlike any faction's standard lighting.
- Maren's cot (`bb`) has books stacked on it. She sleeps with books. This is not romantic; it is compulsive.
- The reading chair (`r`) is the only comfortable piece of furniture. It faces the fireplace. This is where she lives when she is not working. Which is rarely.

**Space-folding tell:** If the player examines the west wall from inside: "The wall extends further than the cottage's exterior should allow. The stones hum faintly." Maren dismisses it. The dissonance between the modest exterior and the spacious interior is the first magic the player sees that is not violent or transactional.

#### Basement Library (16x12, accessed via trapdoor in ground floor)

```
################
#~K..KK.KK..K~#
#..............#
#K.OO........KK#
#K.OO..TT.cc.K#
#..............#
#K...........K.#
#K..a..a..a..K.#
#..............#
#.SS...........#
#..............#
################

O = ley-line tap (glowing amber crystal embedded in floor, 2x2)
T = research table
c = chair
a = specimen jar (strange flora/fauna, Pallor fragment)
K = floor-to-ceiling bookshelf (built between living roots)
~ = root arch (the ceiling is root lattice, the shelves are braced by roots)
SS = stairs up
```

The basement is carved into the root system. The shelves are built between living roots -- the wood grain of shelf and root are indistinguishable in places. The ley-line tap (`OO`) glows amber from a natural crystal in the floor, providing the building's heat and light. A locked artifact vault (requires a key item from a later quest) sits behind one of the shelving units.

Every bookshelf is interactable. The lore density is the highest in the game. Subjects: ley-line mechanics, pre-civilization ruins, spirit-pact theory, the dimming phenomenon, the Pendulum cycle, Maren's personal journals. The player who reads everything here enters Act II with a deeper understanding than any NPC will provide through dialogue.

---

### 1.4 Highcairn Monastery Great Hall

**Location:** Highcairn Monastery, interior
**Size:** 18x14
**Narrative role:** Where Edren retreats during the Interlude. Where Father Aldous maintains the hearth. Where the Pallor Hollow boss fight occurs. The hearth that has burned for 200 years is the room's defining feature and the save point.

**Materials:** Valdris monastery style -- heavy grey limestone, rougher and older than Crown limestone. Thick timber ceiling beams, blackened by two centuries of hearth smoke. Flagstone floor, worn to smooth grooves by generations of monks' feet. No ornament -- the Vigil order rejects decoration. The beauty is in the weight of the stone and the warmth of the fire.

```
Legend (additions):
  H = great hearth (3x2, massive, central back wall -- the hearth IS the save point)
  * = save point glow (integrated into hearth flame)
  | = timber column (load-bearing, thick)
  B = bench (long, communal, the monks eat and pray here)
  @ = Father Aldous (maintaining the hearth)
  E = Edren (Interlude only -- seated, not fighting, not praying)
  P = prayer alcove (side wall recess, 2x1)
  W = weapon rack (beside prayer beads -- this is a martial order)
  s = stone font (holy water basin, 1x1)

##################
#..L...HHH*..L..#
#......HHH.......#
#..|..........|..#
#..P...........P.#
#..|...........#.#
#..BBBBBBBBBBBB..#
#................#
#..BBBBBBBBBBBB..#
#................#
#..BBBBBBBBBBBB..#
#..|...........#.#
#..W.s.........W.#
#................#
#......DDDD......#
##################
```

**Key features:**
- The great hearth (`HHH`, 3x2) dominates the back wall. Its flames are animated with a unique 6-frame cycle -- slower, deeper, more permanent than any other fire in the game. The save point glow (`*`) is embedded in the hearth itself. In the Interlude, every other light in the monastery is cold grey-white. The hearth is the only warm-colored pixel on the screen. This is the room's thesis: something endures.
- Three long communal benches (`B`) span the hall in rows. The monks eat, pray, and gather here. No individual seating -- everything is communal.
- Timber columns (`|`) support the ceiling. The beams above are blackened by smoke. The stone floor has grooves worn by feet.
- Prayer alcoves (`P`) are recessed into the side walls -- small niches where monks kneel alone. In the Interlude, prayer stones in these alcoves show grey frost.
- Weapon racks (`W`) hang beside prayer alcoves near the entrance. Swords next to meditation beads. The Vigil fights and prays.
- A stone font (`s`) near the entrance holds blessed water. Interaction: cure all status ailments (once per visit; shares blessing with altar — using one greys out the other).
- Father Aldous (`@`) stands before the hearth, tending it. His dialogue changes across acts but his position never does.

**Edren's position (Interlude):** Edren (`E`) sits on the middle bench, facing the hearth. Not at the end of a bench -- in the middle, taking up space he has no right to. He is not praying. He is not sleeping. He is sitting. The player must speak to him to trigger the Pallor Hollow boss fight. After the fight, he stands.

---

### 1.5 Ironmark Citadel Command Chamber

**Location:** Inner ring center, Ironmark Citadel
**Size:** 16x16
**Narrative role:** General Vassar Kole's Pallor-infused headquarters. The boss arena for the Interlude's Kole fight. The Pallor energy arcing between walls and Kole's armor defines the room's visual language.

**Materials:** Carradan military -- Arcanite-bonded iron walls, metal grating floor, reinforced ceiling with exposed pipe clusters. But corrupted: the standard cold blue-white Arcanite glow has shifted to grey-white. Pallor energy arcs between conduit points on the walls. The room hums with a flat, sustained tone -- not the rhythmic Compact machinery sound, but something wrong.

```
Legend (additions):
  # = Arcanite-bonded iron wall (grey-blue glow, pulsing)
  z = Pallor conduit (wall-mounted, energy arcs between these)
  | = iron column (structural, also conducts Pallor energy)
  ~ = Pallor arc path (floor marking where energy arcs sweep -- hazard zone in boss fight)
  @ = General Kole (center, standing, encased in Pallor-fused armor)
  C = command table (2x2, iron and brass, maps scattered)
  W = weapon rack (Pallor-charged weapons, glowing grey)
  B = banner (Compact military, faded, grey-stained)
  G = Arcanite conduit core (2x2, back wall center -- power source for room)

################
#z..B.GG.B..z#
#.....GG......#
#z............z#
#..|........|..#
#..~........~..#
#..|..CC..|..#
#..~..CC..~..#
#..|..@...|..#
#..~........~..#
#..|........|..#
#z............z#
#..W........W..#
#z............z#
#.....DDDD.....#
################
```

**Key features:**
- The Arcanite conduit core (`GG`, 2x2) on the back wall is the room's power source. In normal Compact buildings, these glow steady blue-white. Here the glow is grey-white and strobes erratically.
- Pallor conduits (`z`) are mounted on every wall segment. During the boss fight, energy arcs sweep between conduit pairs in predictable patterns -- the arc paths (`~`) on the floor mark hazard zones the player must dodge.
- Iron columns (`|`) are both structural and conductive. They channel Pallor energy during the fight's second phase, creating a grid of arc-paths the player must navigate.
- Kole (`@`) stands at the room's center before his command table (`CC`). He does not sit. His armor is fused to his body by Pallor energy -- grey crystalline growths merge metal and flesh at the joints. The cutscene before the fight shows the energy arcing from the conduit core through the walls, through the columns, into his armor. He speaks calmly. He believes this is strength.
- Weapon racks (`W`) near the entrance hold Pallor-charged weapons. After Kole's defeat, these are lootable (the Pallor charge dissipates).
- Compact military banners (`B`) hang from the back wall, grey-stained and faded. The gear insignia is barely visible.

**Post-boss transformation:** After Kole falls, the grey-white glow drains from every conduit. The arcs stop. The iron returns to its normal dark color. The room's hum dies to silence. The command table's maps are legible again -- one shows the route to Cael at the Convergence (key item: Military Intelligence Cache).

---

### 1.6 The Pendulum Tavern

**Location:** Three-faction crossroads (replaces the Three Roads Inn in Epilogue)
**Size:** Main room 20x16, Back room 10x8
**Narrative role:** Sable's post-game tavern. The emotional epilogue space and mechanical hub. Every surviving party member is here. Trophy cases display story artifacts. The Bestiary Board and Boss Rush Board provide post-game replay content. The Dreamer's Fault dungeon entrance is hidden in the back room.

**Materials:** Hybrid construction -- timber framing (Wilds woodcraft), stone foundation (Valdris tradition), brass fittings and mechanical fixtures (Compact engineering). The building itself is a peace treaty made physical. Warm amber lighting from a mix of sources: ley-lamp brackets, a real wood-fire hearth, and one Arcanite reading lamp over the bar (Lira's contribution, Sable tolerates it).

#### Main Room (20x16)

```
Legend (additions):
  $ = trophy case (2x1, glass-fronted, story items inside)
  ! = bestiary board (wall-mounted, 2x6)
  ? = boss rush board (wall-mounted, 2x6)
  = = bar counter (Sable's domain, 10 tiles long)
  R = keg/barrel (behind bar)
  @ = Sable (behind bar, facing south)
  L = Lira (corner booth, arguing with an engineer)
  b = booth seat (4x4 corner enclosure)
  T = table (with visiting NPCs)
  c = chair
  F = fireplace (always lit, warm amber)
  K = bookshelf (Maren's donations)

####################
#K.FFF...........!#
#K...............!#
#..............!!!#
#.bb......bb.....#
#.bLb.....bnb....#
#.bb......bb.....#
#................#
#..Tc..Tc........#
#..............?.#
#..Tc..Tc......?.#
#.............???#
#RR========@==RR.#
#RR==========RR..#
#................#
#.$..........$.#
#.$..........$.#
#................#
#.....DDDDDD.....#
####################

n = NPC booth (various helped NPCs rotate through)
```

**Key features:**
- The bar (`==========`, 10 tiles) is the room's centerpiece. Sable (`@`) stands behind it, center-right, facing south. Her dialogue: "So nobody forgets what it cost." The bar is built from reclaimed timber -- Hadley's original bar counter, salvaged and refinished.
- The fireplace (`FFF`) on the back wall burns real wood (not ley-heated). Sable insists. A bookshelf (`K`) beside it holds Maren's donated volumes -- the hermit's contribution to the new world.
- Two corner booths (`bb`) provide private conversation spaces. Lira (`L`) occupies one, arguing schematics with a Compact engineer. The other rotates NPCs the player helped throughout the game.
- Four open tables (`T`) with chairs (`c`) seat visiting NPCs. The NPCs present depend on which side quests the player completed.
- The Bestiary Board (`!`) on the right wall displays all discovered enemy entries. Interactive: scroll and review.
- The Boss Rush Board (`?`) below it allows replaying any defeated boss at enhanced difficulty. The board is visually a cork board with hand-drawn sketches of each boss -- Sable drew them.
- Two trophy cases (`$`) flank the entrance. Contents: the Pendulum's broken chain, Maren's first analysis notes, a Compact wrench, a Thornmere spirit-totem. Each is examinable for a memory -- a line of dialogue from the character who owned it.

#### Back Room (10x8)

```
##########
#.b.......#
#.b..K.K..#
#.........#
#....OO...#
#.........#
#....DD...#
##########

b = Sable's cot and lockpick set
K = Cael's sword (wall-mounted -- the only decoration Sable chose)
O = trapdoor (hidden, Dreamer's Fault entrance -- accessible post-game)
DD = door to main room (behind the bar)
```

Sable's private space. A cot, a lockpick set, a bottle. Cael's sword on the wall. The room is bare -- Sable does not accumulate possessions. The Dreamer's Fault trapdoor is concealed under a rug; the player discovers it through a post-game quest trigger.

---

## 2. Standard Interiors Using Building Palette

This section demonstrates how the building-palette.md templates are APPLIED with faction-specific styling. Each example shows: (1) the base template being used, (2) the faction material and furniture swaps, (3) the resulting ASCII layout. These serve as references for building all other interiors in the game.

---

### 2.1 Valdris Variants

**Faction style reference:** Pale limestone walls, flagstone or dark wood plank floors, ley-lamp brackets (warm gold glow), oak furniture, heraldic banners, tapestries. Warm, traditional, generational.

---

#### Valdris Weapon Shop -- "The Knight's Edge" (Citizen's Walk)

**Base template:** Template 1: Weapon Shop (12x10)
**Modifications:** Mirror horizontally. Replace generic weapon racks with Valdris-style displays (swords and shields, royal crest above counter). Add ley-lamp wall sconces. Add heraldic banner.

```
Base Template 1 (reference):       Valdris Applied:

############                       ############
#W.CC.@.W.A#                       #A.W.@.CC.B#
#W........A#                       #A........W#
#..........#                       #..........#
#.T..MM..T.#                       #.T..MM..T.#
#.c..MM..c.#                       #.c..MM..c.#
#..........#                       #..L....L..#
#.A......W.#                       #.W......A.#
#.....DD...#                       #...DD.....#
############                       ############

Changes:
- Mirrored left/right (door offset shifts)
- B = Valdris heraldic banner (back wall, above counter)
- L = ley-lamp sconces (warm gold, replacing generic wall torches)
- Walls: pale limestone blocks
- Floor: dark wood plank
- Counter: polished oak with brass fittings
- Weapon racks: display swords with Valdris pact-etching, shields with lion motif
- Armor stand: displays a worn but quality chain hauberk
- Rug (MM): blue and gold woven textile, Valdris pattern
```

**Shopkeeper:** Behind counter, facing south. Unnamed knight-turned-merchant.
**Buy/sell trigger:** 1 tile south of counter center.
**Display items:** West wall weapon rack shows a pact-etched longsword (examinable: "The ley-rune work is old. This blade has seen service."). East armor stand shows chain mail.
**Exit:** Door, bottom wall, offset left.

---

#### Valdris Inn -- "The Anchor & Oar" (Lower Ward)

See Section 3.3 for the full multi-floor layout of this building.

**Base template applied:** Template 3: Inn (16x14) for ground floor, Template 4: Inn Upper Floor (12x10) for upstairs.
**Faction swaps:** Limestone walls, oak bar counter, ley-lamp sconces, heraldic tapestry over hearth. This is a Lower Ward establishment -- standard wealth tier, not noble.

---

#### Valdris Tavern -- "The Seven Cups" (Lower Ward)

**Base template:** Template 5: Tavern (14x12)
**Modifications:** Add bard's corner near hearth. Replace barrel-behind-bar with Valdris wine casks. Add tapestry. Shift entertainment area to fireplace wall.

```
Base Template 5 (reference):       Valdris Applied:

##############                     ##############
#RRRCC....@.R#                     #RRRCC....@.R#
#RRR.C......R#                     #RRR.C......R#
#............#                     #..L........L#
#.Tc..Tc..Tc.#                     #.Tc..Tc..Tc.#
#............#                     #............#
#.Tc..Tc.....#                     #.Tc..Tc..B..#
#..........E.#                     #..........FFF#
#............#                     #..........FFF#
#.Tc..Tc.....#                     #.Tc..Tc..e..#
#.......DD...#                     #.......DD...#
##############                     ##############

Changes:
- E replaced by FFF = large fireplace (Valdris hearth, 3 tiles)
- e = bard's stool (performance space near hearth)
- B = tapestry (Valdris heraldic, side wall)
- L = ley-lamp sconces
- Barrels behind bar: oak wine casks, branded with Valdris vintner marks
- Walls: pale limestone, lower ward variant (slightly rougher)
- Floor: dark wood plank, well-worn
- Tables: round oak, scarred by use
```

**Barkeeper:** Renn (named NPC) -- behind counter, facing south. Sable's Valdris contact.
**Patron NPCs:** 2-3 at tables. Dialogue varies by act.
**Entertainment:** Bard's stool near hearth. Optional bard NPC in Act I-II; empty in Interlude.

---

#### Valdris Temple -- Chapel of the Old Pacts (Lower Ward)

**Base template:** Template 8: Temple (14x16)
**Modifications:** Replace generic altar with ley-line altar (the save point). Add stained glass window. Pews are stone benches (the Old Pacts predate wooden furniture in Valdris tradition).

```
Base Template 8 (reference):       Valdris Applied:

##############                     ##############
#L....OO....L#                     #L....*OO...L#
#............#                     #.....OO.....#
#.cc......cc.#                     #.cc......cc.#
#.cc......cc.#                     #.cc......cc.#
#............#                     #....s........#
#.cc......cc.#                     #.cc......cc.#
#.cc......cc.#                     #.cc......cc.#
#............#                     #............#
#.cc......cc.#                     #.cc......cc.#
#.cc......cc.#                     #.cc......cc.#
#............#                     #..L........L#
#L..........L#                     #............#
#............#                     #............#
#.....DD.....#                     #.....DD.....#
##############                     ##############

Changes:
- OO = ley-line altar (warm gold glow, the primary save point)
- * = save point marker (integrated into altar)
- s = stone font (holy water, cure all status ailments; shares blessing with altar once per visit)
- cc = stone bench pews (heavier than standard wooden pews)
- L = ley-lamp brackets (warm gold, brighter than residential)
- Stained glass window: above altar (wall tile) -- Seven Towers motif
- Walls: pale limestone, polished smooth
- Floor: stone flagging, geometric ley-line inlay patterns
- The "Old Pacts" refers to original agreements between Valdris and the ley spirits
```

**Priest:** Before altar, facing south. Unnamed. Provides blessing (restore 25% HP to all party OR cure all status ailments — player chooses one; once per visit). Font and altar share one blessing per visit.
**Worshippers:** 1-2 on pews. Dialogue reflects act mood.

---

#### Valdris Residential (Medium) -- Haren's Estate Study (Court Quarter)

**Base template:** Template 7: Residential House -- Medium (12x10)
**Modifications:** Wealthy variant. Add writing desk, paintings, ornate rug. This is Lord Chancellor Haren's private study -- not his full estate, but the room the player enters.

```
Base Template 7 (reference):       Valdris Wealthy Applied:

############                       ############
#FF..K..K..#                       #FFF.K..K.B#
#..........#                       #..L.......#
#.TT.cc....#                       #.TT.cc..P.#
#..........#                       #.MMMMMM...#
#..........#                       #.MMMMMM...#
#.BB.......#                       #.BB..K..D.#
#.BB..H..K.#                       #.BB..H..K.#
#.....DD...#                       #.....DD...#
############                       ############

Changes:
- FFF = large fireplace (wealthy, ornate mantle)
- B = painting (portrait of Haren's family, examinable)
- P = potted plant (highland flowers)
- L = ley-lamp bracket (warm gold)
- MMMM = large ornate rug (blue and gold Valdris pattern)
- D = writing desk (with correspondence -- examinable for political lore)
- K = additional bookshelf (Haren is educated)
- Walls: polished limestone, whitewashed plaster upper portions
- Floor: dark oak plank, finely finished
- Furniture: ornate -- carved oak, brass fittings, upholstered chairs
- Wealth tier: 70-80% floor coverage
```

---

### 2.2 Carradan Variants

**Faction style reference:** Brick walls (soot-stained in lower districts, clean in upper), metal grating or brick tile floors, Arcanite lamps (cold white-blue glow), iron/brass furniture, exposed pipe runs, gear ornaments. Functional, pressurized, stratified.

---

#### Carradan Weapon Shop -- "Arcanite Weapons Smith" (Caldera Middle Tiers)

**Base template:** Template 1: Weapon Shop (12x10)
**Modifications:** Replace wooden racks with metal-and-glass display cases. Add Arcanite accent lighting. Replace rug with metal floor grating.

```
Carradan Applied:

############
#W.CC.@.W.A#
#W........A#
#.L........L#
#.T..gg..T.#
#.c..gg..c.#
#..........#
#.A......W.#
#.....DD...#
############

Changes:
- W = metal weapon case (glass-fronted, iron frame, Arcanite-edged blades on display)
- A = powered armor stand (brass joints, gear-fitted, Forgewright engineering)
- CC = iron counter with brass trim, built-in scale
- gg = metal floor grating (replaces rug -- Carradan aesthetic is functional, not decorative)
- L = Arcanite lamp (cold white-blue glow, wall-mounted)
- T = metal examination table (for testing weapon balance)
- Walls: clean brick with brass pipe accents along ceiling
- Floor: brick tile, swept clean
- A Consortium seal hangs above the counter (brass and iron medallion)
```

**Shopkeeper:** Forgewright smith, behind counter, facing south. Practical dialogue, no charm.
**Display items:** Glass cases show Arcanite-edged blades with engraved specifications. Examining: "Forgewright Blade. Tensile strength: 4200 units. Edge retention: superior. Price: 1,600 gold."

---

#### Carradan Inn -- "Canalside Inn" (Corrund Canal District)

**Base template:** Template 3: Inn (16x14)
**Modifications:** Replace fireplace with radiator unit. Metal bunks upstairs instead of beds. Institutional common room. The Compact's idea of hospitality.

```
Carradan Applied -- Ground Floor:

################
#PPPP..........#
#..............#
#..T.c.c.T..L..#
#..............#
#..T.c.c.T.....#
#.....*.....SS.#
#..L...........#
#..T.c.c.T..SS.#
#..............#
#..CC.@........#
#..L...........#
#......DD......#
################

PP = radiator unit (Arcanite-heated pipes, 4 tiles, replaces fireplace)
L = Arcanite lamp (cold white-blue)
* = save point (ley wellspring -- even Compact cities have these)
SS = metal staircase (bolted iron, industrial)
CC = iron check-in counter
T, c = metal tables and stools (functional, uncomfortable)
Walls: soot-stained brick
Floor: worn brick tile
A pipe run along the ceiling hisses faintly
```

---

#### Carradan Tavern -- "Bargeman's Tavern" (Corrund Canal District)

**Base template:** Template 5: Tavern (14x12)
**Modifications:** Mechanical drink taps instead of hand-drawn. Forge-glow accent lighting. Iron bar rail.

```
Carradan Applied:

##############
#RRRCC....@.R#
#RRR.C......R#
#..L........L#
#.Tc..Tc..Tc.#
#............#
#.Tc..Tc.....#
#..........N.#
#..L........L#
#.Tc..Tc.....#
#.......DD...#
##############

Changes:
- CC = iron bar counter with mechanical drink taps (brass, gear-operated)
- RRR = metal kegs with pressure gauges (Compact brewing is industrial)
- N = notice board (stamped tin, wanted posters and Guild postings)
- L = Arcanite lamps (every other has a forge-glow amber filter)
- Iron bar rail runs along customer side of counter
- Walls: exposed brick, iron bracket decorations
- Floor: metal grating near bar (drainage), brick elsewhere
- No bard corner -- Compact taverns are for drinking and information, not entertainment
```

---

#### Carradan Workshop/Forge -- "Tinker's Workshop" (Caldera Middle Tiers)

**Base template:** Template 12: Workshop/Forge (12x12)
**Modifications:** Arcanite engine replaces generic forge. Precision lathe. Blueprint wall. This is a Forgewright facility, not a traditional smithy.

```
Carradan Applied:

############
#.OOOO..p..#
#..........#
#.TT...L...#
#.TT..X.X..#
#..........#
#.RR...H...#
#..........#
#.....g....#
#..........#
#.....DD...#
############

Changes:
- OOOO = Arcanite engine housing (2x2 + 2x1 -- glowing blue-white core,
         pipe cluster connecting to ceiling, animated energy pulse)
- TT = precision workbench (metal, with magnification arm)
- p = blueprint wall (schematics pinned floor-to-ceiling)
- g = grinding wheel (precision, belt-driven from engine)
- L = Arcanite overhead lamp (focused beam on workbench)
- X = Arcanite component bins (labeled, sorted by type)
- RR = metal storage drums (raw materials)
- Walls: clean brick, exposed brass pipe network (functional, carrying engine exhaust)
- Floor: metal grating (center), brick (perimeter)
```

---

#### Carradan Residential (Medium) -- Housing Block (Caldera Middle Tiers)

**Base template:** Template 7: Residential House -- Medium (12x10)
**Modifications:** Standard wealth tier. Metal bunk, mechanical clock, glass windows. Modest but the resident has some Compact-era comfort.

```
Carradan Applied:

############
#PP..K.....#
#..........#
#.TT.cc..L.#
#..........#
#..........#
#.BB.......#
#.BB..H..i.#
#.....DD...#
############

Changes:
- PP = radiator (Arcanite pipe, 2 tiles, replaces fireplace)
- BB = metal-framed bed (functional, company-issue mattress)
- K = metal bookshelf (with mechanical clock on top shelf)
- i = glass-paned window (wall tile, shows exterior light)
- L = Arcanite table lamp (on small shelf by bed)
- TT = metal dining table
- cc = metal stools
- H = iron-banded chest (company-issue storage)
- Walls: brick, plastered above eye-height
- Floor: worn concrete
- No rug, no paintings -- functional Compact living
```

---

### 2.3 Thornmere Variants

**Faction style reference:** Living root-bark walls, root-mat or woven reed floors, bioluminescent moss and spirit crystals (teal-purple glow), carved heartwood furniture, vine curtains instead of doors, no metal, no glass. Organic, spiritual, intimate.

Thornmere buildings do not follow rectangular templates. The walls curve, the floors slope, and the "rooms" are chambers within living root systems. The ASCII layouts below approximate organic spaces using the grid -- in-game, the walls would have gentle curves and irregular edges.

---

#### Thornmere Hunter's Cache -- "Scout Quarters" (Canopy Reach, Mid-Canopy)

**Nearest base template:** Template 1: Weapon Shop (12x10), heavily adapted
**Modifications:** No counter -- Thornmere trade is face-to-face. Weapons on living wood pegs, not metal racks. Spirit-bound weapons glow faintly. No metal in any display.

```
Thornmere Applied:

~~~~~~~~~~~~
~W...@...W.~
~W.........~
~..........~
~.T........~
~.c........~
~..........~
~.A......W.~
~.....vv...~
~~~~~~~~~~~~

~ = root-bark wall (curved, living wood, teal bioluminescent moss in gaps)
W = living wood peg rack (bone-tipped spears, heartwood bows, crystal daggers)
A = armor display (woven root-bark vest on vine hanger)
T = carved heartwood table (for examining goods)
c = carved stump seat
@ = Scout Leader (standing among the weapons, facing south)
vv = vine curtain doorway (no door -- woven vines part when approached)

Materials:
- Walls: living bark, teal moss between root ridges
- Floor: woven branch platform with bark-cloth covering
- Light: bioluminescent moss (ambient teal), spirit crystal above doorway (purple)
- No counter: the Scout Leader trades directly, standing among the goods
- Interaction trigger: face the Scout Leader from 1 tile south
```

---

#### Thornmere Guest Platform -- "Nest Hammocks" (Canopy Reach, Mid-Canopy)

**Nearest base template:** Template 4: Inn Upper Floor (12x10), adapted
**Modifications:** Hammocks instead of beds. No walls between sleeping areas -- the platform is open-air with vine railings. Wind effects.

```
Thornmere Applied:

~~~~~~~~~~~~
~h.........~
~h...L.....~
~..........~
~.h........~
~.h...L....~
~..........~
~..........~
~.....vv...~
~~~~~~~~~~~~

h = hammock (vine-woven, slung between branch posts, 1x2 each)
L = spirit crystal (bioluminescent, hung from branch -- teal nightlight)
vv = vine curtain (entrance from rope bridge)

Materials:
- Walls: branch railings with woven vine windbreak (partial -- sky visible above)
- Floor: woven branch platform
- Ceiling: open canopy (stars visible at night, filtered green-gold light by day)
- The wind rocks the hammocks (2-frame sway animation)
- Rest trigger: interact with any hammock for full HP/MP restore
- No save point in this building -- save at Canopy Hub totem
```

---

#### Thornmere Healer's Hut -- "Healer's Perch" (Canopy Reach, Mid-Canopy)

**Nearest base template:** Template 2: Item/Potion Shop (10x10), adapted
**Modifications:** Herbs growing from the walls (not on shelves). Bark containers instead of glass bottles. No counter -- face-to-face healing.

```
Thornmere Applied:

~~~~~~~~~~
~P...@..P~
~P......P~
~........~
~........~
~.T.c....~
~........~
~.R......~
~...vv...~
~~~~~~~~~~

P = herb growth (herbs growing directly from moss-covered wall -- living pharmacy)
@ = Healer NPC (standing among hanging herb bundles, facing south)
T = carved root table (mixing station)
c = stump seat
R = bark container (ground herbs, salves)
vv = vine curtain doorway

Materials:
- Walls: living bark with cultivated herb patches growing from moss pockets
- Floor: smooth heartwood plank
- Light: bioluminescent moss (teal), herb flowers glow faintly
- Smell: the NPC describes it -- "Canopy mint and wound-moss. Breathe deep."
- Interaction trigger: face Healer from 1 tile south
```

---

#### Thornmere Elder's Dwelling -- "Elder's Tent" (Greywood Camp)

**Nearest base template:** Template 7: Residential House -- Medium (12x10), adapted
**Modifications:** Hide walls instead of stone. Spirit-mark decorations. The largest tent in Greywood Camp -- semi-permanent, with carved heartwood interior supports.

```
Thornmere Applied:

^^^^^^^^^^^^
^FF..K..K..^
^..........^
^.TT.cc....^
^..........^
^..........^
^.bb.......^
^.bb..H..K.^
^.....vv...^
^^^^^^^^^^^^

^ = hide tent wall (treated animal hide over heartwood frame, spirit-marks painted on)
FF = central fire pit (open flame, banked low, cooking and warmth)
K = carved heartwood shelf (tribal records, knotted cords, painted stones)
TT = low table (seated on the ground -- Thornmere formal dining is floor-level)
cc = woven cushions (not chairs)
bb = sleeping pallet (woven reed on the ground, hide blanket)
H = carved chest (heartwood, spirit-ward lock)
vv = tent flap (entrance)

Materials:
- Walls: treated hide stretched over heartwood poles, spirit-marks in purple dye
- Floor: compacted earth with woven reed mat covering
- Light: central fire, spirit-ward totems at tent poles (faint purple glow)
- Elder Savanh sits at the table when the diplomatic negotiation triggers
```

---

#### Thornmere Trader's Hollow -- "Trader's Nook" (Roothollow)

**Nearest base template:** Template 1: Weapon Shop or General Store, radically adapted
**Modifications:** No walls -- this is a root-chamber alcove. Goods in woven baskets hung from root hooks. Barter-based, no counter.

```
Thornmere Applied:

~~~~~~~~~~
~g.g.@.g.~
~.........~
~.g...g...~
~.........~
~.........~
~....vv...~
~~~~~~~~~~

~ = root-bark chamber wall (curved, natural)
g = woven basket on root hook (goods displayed: spirit wood, rare herbs, totems, root-silk)
@ = Trader NPC (standing among baskets, facing south)
vv = root archway (open passage to Central Hub)

Materials:
- Walls: living root, curved
- Floor: compacted earth between exposed roots
- Light: bioluminescent moss (ambient teal)
- No counter, no shelves, no furniture in the constructed sense
- Goods hang from root hooks or sit in baskets on the floor
- Interaction trigger: face Trader from 1 tile south
- Currency: spirit tokens, barter preferred
```

---

## 3. Multi-Floor Buildings

---

### 3.1 Axis Tower Non-Dungeon Floors

**Location:** City center, Corrund
**Dungeon floors (Interlude) are covered in the dungeon design document.** This section covers the non-dungeon floors that exist during Act II when the tower functions as the Consortium's administrative hub.

**Structure:** 5 floors total. Ground = public lobby. Floor 2 = offices. Floor 3 = barracks. Floor 4 = armory/vault. Sublevel = ley-conduit junction (dungeon only). During Act II, only the ground floor is accessible to the player. During the Interlude, all floors become the dungeon.

#### Ground Floor -- Public Lobby (14x14)

```
##############
#L...CC.@...L#
#............#
#..K........K#
#..K........K#
#....SS......#
#....SS......#
#............#
#.T.cc....T..#
#.T.cc....T..#
#............#
#L..........L#
#.....DD.....#
##############

CC = reception desk (iron and brass, Consortium seal inlaid)
@ = receptionist NPC (Act II: polite, officious; Interlude: absent)
SS = staircase up (metal, gated -- "authorized personnel only" in Act II)
K = notice boards (Consortium decrees, public information)
T = waiting benches (metal, uncomfortable -- petitioners wait here)
L = Arcanite lamps (bright white-blue, institutional)
DD = main entrance (iron double doors, glass panels)
```

In Act II, the staircase gate is locked. The receptionist offers bland directions. The room is clean, bright, and sterile. In the Interlude, the gate is breached, the receptionist is gone, and the staircase is the dungeon entrance.

#### Floor 2 -- Administrative Offices (14x12)

```
##############
#K.CC.@..K.CC#
#............#
#.TT.cc.TT.cc#
#............#
#.TT.cc.TT.cc#
#............#
#..K.........#
#....SS...SS.#
#............#
#............#
##############

CC = officer desks (iron, with document stacks)
@ = office manager NPC (Act II only)
TT = clerk desks (rows -- bureaucratic processing)
K = filing cabinets (metal, indexed -- Carradan record-keeping)
SS = stairs down (to lobby) and stairs up (to barracks)
```

Paper, metal, and ambition. The offices manage the Compact's commercial and military logistics. In Act II (unseen by the player), clerks process trade permits and military requisitions. In the Interlude, the desks are abandoned, papers scattered. Some drawers are forced open -- the resistance has been here.

#### Floor 3 -- Barracks (14x12)

```
##############
#WW.A..CC.@.A#
#............#
#.BB..BB..BB.#
#............#
#.BB..BB..BB.#
#..L........L#
#.TT.cc......#
#.......F....#
#....SS...SS.#
#.H..H..H...#
##############

Standard barracks template (Template 10) with Carradan styling:
BB = metal bunk beds (bolted to floor)
W = weapon rack (Compact standard-issue: Arcanite-edged pikes, crossbows)
A = armor stand (Compact plate, gear-jointed)
CC = commanding officer's desk (iron, with strategic map)
@ = duty officer (Act II: formal; Interlude: Pallor-touched)
F = radiator unit (Arcanite-heated)
H = personal lockers (metal, padlocked)
```

#### Floor 4 -- Armory/Vault (14x12)

```
##############
#WW.WW..WW.WW#
#............#
#.AA..AA..AA.#
#............#
#.XX.XX.XX.XX#
#............#
#..CC.@......#
#....SS......#
#............#
#....GG......#
##############

WW = heavy weapon racks (Arcanite weaponry, Pallor-charged in Interlude)
AA = armor stands (elite Compact plate)
XX = munitions crates (sealed, stamped)
CC = quartermaster desk
@ = quartermaster (Act II: meticulous; Interlude: absent)
GG = vault door (locked -- leads to the Consortium's Arcanite reserves)
SS = stairs down
```

---

### 3.2 Corrund Guild Hall

**Location:** Upper Rim, Caldera (labeled as Merchants' Council Hall)
**Structure:** Ground floor = public council chamber. Upper floor = Fenn Acari's private office and meeting room.

#### Ground Floor -- Council Chamber (14x14)

```
##############
#B.L......L.B#
#............#
#..TTTTTTTT..#
#..cccccccc..#
#..cccccccc..#
#..TTTTTTTT..#
#............#
#.K........K.#
#.K........K.#
#............#
#L..........L#
#.....DD.....#
##############

TT = long council table (glass-topped, iron frame -- 8 tiles, central)
cc = council chairs (brass, gear-embossed backs -- 8 per side)
B = Consortium banner (gear insignia, brass on iron)
K = document shelves (metal, indexed -- trade agreements, guild charters)
L = Arcanite chandeliers (cold white-blue, bright -- power display)
DD = main entrance (iron double doors, glass panel insets)
```

The table dominates. When Fenn Acari presides, he sits at the head (north center). The chamber is designed to intimidate: bright lights, cold metal, the weight of the Consortium's organizational precision. In the Interlude, half the chairs are empty. Papers are scattered. The mechanical voting mechanism on the table (a brass device with lever switches) has been smashed.

#### Upper Floor -- Fenn Acari's Private Office (12x10)

```
############
#K...CC..@K#
#K........K#
#..........#
#..c....c..#
#..........#
#..L..FFF..#
#..........#
#..SS......#
############

CC = Acari's desk (large, brass and mahogany -- the only wood in the building)
@ = Fenn Acari (seated, facing south -- the man who authorized Project Pendulum)
K = bookshelves (trade ledgers, engineering texts, personal correspondence)
c = guest chairs (for those summoned, not invited)
FFF = display case (glass, 3 tiles -- contains a scale model of the Axis Tower,
      Arcanite prototypes, and a framed copy of the original Compact charter)
L = Arcanite desk lamp (focused, intense -- Acari works late)
SS = stairs down to council chamber
```

**Acari's dialogue (Act II):** Confident, dismissive of risk. The Pendulum was his initiative.
**Acari's state (Interlude):** The desk is cleared. The display case is cracked. The Axis Tower model is broken. Acari is gone -- his last message is a note on the desk: "I was wrong. That does not excuse me."

---

### 3.3 Valdris Crown Inn -- The Anchor & Oar

**Location:** Lower Ward, Valdris Crown
**Structure:** Ground floor = tavern and reception. Upper floor = guest rooms.
**NPC:** Renn (keeper), Sable's primary Valdris contact.

#### Ground Floor (16x14) -- Tavern and Reception

```
################
#FFF...........#
#.B...T.c.c.T.#
#.B............#
#..T.c.c.T.....#
#..............#
#.....*.....SS.#
#..L...........#
#RRR.CC.@......#
#RRR.CC........#
#..............#
#..............#
#......DD......#
################

FFF = large fireplace (Valdris limestone hearth, warm gold glow)
B = tapestry (nautical motif -- the "Anchor & Oar" is a harbor district name)
RRR = wine casks (Valdris highland vintage, behind the bar)
CC = bar/reception counter (oak, worn smooth, serving and inn check-in combined)
@ = Renn (behind counter, facing south -- serves drinks AND rents rooms)
* = save point (ley-line wellspring, near the staircase)
SS = oak staircase to upper floor
T, c = round tables and chairs (scarred oak, communal seating)
L = ley-lamp sconce (warm gold)
DD = front door (oak, heavy)
```

The Anchor & Oar combines tavern and inn in a single building. Renn runs both. The counter serves double duty: order a drink or rent a room. The save point sits near the staircase, giving the player a save-and-rest in one location. The ground floor has the density and warmth of a neighborhood pub -- regulars have "their" table.

**Buy drink trigger:** 1 tile south of counter, left half.
**Rest trigger:** 1 tile south of counter, right half. Renn: "Room's upstairs. Same one as always."

#### Upper Floor (12x10) -- Guest Rooms

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

B = single bed (oak frame, wool blanket)
L = ley-lamp (dim, nighttime warmth)
SS = staircase down
# (interior) = thin wall partitions (oak panels, not full stone)
```

Three guest rooms separated by oak panel walls. The player's room is always the same one: front-left (northwest corner). Interior walls are thin partitions -- the player can hear the tavern below (ambient audio cue). Each room has a bed and a light source. Simple, functional, affordable.

---

### 3.4 Canopy Reach Observatory

**Location:** Upper Canopy, Canopy Reach
**Structure:** Three levels in a great tree crown. Level 1 (approach platform), Level 2 (Wynne's living quarters), Level 3 (the observatory dome).
**NPC:** Wynne (the far-seer).

#### Level 1 -- Approach Platform (8x6)

```
~~~~~~~~
~.X..X.~
~......~
~..LL..~
~......~
~..vv..~
~~~~~~~~

X = storage crates (observation supplies, star charts wrapped in oilcloth)
L = spirit crystal brackets (teal, path-lighting)
vv = rope ladder down (to Mid-Canopy Hub)
~ = branch-platform railing (woven vine, open air)
```

A simple staging area. Crates of supplies, path lighting, and the rope ladder connecting to the lower settlement. Wind effects. The sky is visible above.

#### Level 2 -- Wynne's Quarters (10x8)

```
~~~~~~~~~~
~K..b.b.L~
~K........~
~.TT.c...~
~.........~
~.m...a..~
~.........~
~..LL..LL.~
~~~~~~~~~~

K = bookshelf (star charts, ley-line observation records, pressed leaf samples)
b = sleeping pallet (woven vine, against the trunk wall)
L = spirit crystal (ambient lighting)
TT = carved table (observation notes spread out)
c = stump seat
m = mounted lens (a crude telescope component, heartwood and polished crystal)
a = artifact shelf (small carved totems, gifts from other tribes)
LL = rope ladder up and down
```

Wynne lives simply. The room wraps around a section of the great tree's trunk -- the "wall" on one side is living bark. Her notes are scattered but organized by her own logic. The mounted lens is a prototype -- she builds these from materials traded with other tribes. Her living space is also her workspace. She does not separate the two.

#### Level 3 -- The Observatory (12x10)

```
~~~~~~~~~~~~
~....OO....~
~...........~
~.L..TT..L.~
~.....c....~
~...........~
~.@@.......~
~...........~
~....LL....~
~~~~~~~~~~~~

OO = panoramic lens (the main observation instrument -- polished crystal in heartwood
     mount, 2x2, aimed at the sky -- the cutscene trigger)
TT = chart table (the continent map, hand-drawn, with ley-line overlays)
c = observation stool
@ = Wynne (standing before the lens, looking out)
L = spirit crystal (bright teal -- the brightest in any Thornmere building)
LL = rope ladder down to Level 2
~ = open railing (360-degree view -- the canopy breaks here, sky in every direction)
```

The observatory is a circular platform at the tree's crown. The railing is low vine-work. The view is the point: on first visit, a panoramic cutscene pans across the continent -- Valdris Crown's pale towers northwest, Corrund's smoke southeast, and between them, the grey haze over the Convergence. Wynne points. Nobody wants to talk about it.

The panoramic lens (`OO`) is Wynne's life work. Heartwood and polished crystal, built over years. It magnifies the ley-line flows in the sky, making the energy patterns visible to the naked eye. In Act II, the flows are irregular. The cutscene makes this visceral.

---

## 4. Shop Interiors with Interaction Points

This section defines the universal interaction point system for all shop types. Every shop, regardless of faction, follows these spatial rules.

### Universal Shop Interaction Layout

```
    BACK WALL
    =========
    [Display] [Counter] [Display]
              [@Keeper]
              ---------     <- counter edge
              [TRIGGER]     <- 1 tile south of counter center: BUY/SELL

    [Rack]              [Rack]    <- VISUAL ONLY (examinable for flavor text)

    [Display]          [Display]  <- VISUAL ONLY

              [DOOR]              <- EXIT (bottom wall)

    (optional: back room access behind keeper, via interior door on back wall)
```

### Interaction Point Rules

| Point | Position | Trigger | Notes |
|-------|----------|---------|-------|
| **Buy/sell** | 1 tile south of counter center | Action button while facing north | Shopkeeper must be present behind counter |
| **Shopkeeper** | Behind counter, center or offset | N/A (NPC position) | Faces south; responds to action button |
| **Weapon rack** | Wall-mounted, left or right wall | Action button while facing wall | Flavor text only: "Fine steel. Well-maintained." |
| **Armor stand** | Free-standing, near wall | Action button while adjacent | Flavor text only: "A sturdy hauberk." |
| **Potion shelf** | Wall-mounted, flanking counter | Action button while facing wall | Flavor text describing stock quality |
| **Display case** | Wall or free-standing | Action button while adjacent | Shows premium items (not purchasable separately) |
| **Exit door** | Bottom wall, center or offset | Walk into door tile | Standard exit to exterior map |
| **Back room** | Back wall, interior door | Action button (some locked) | Storage, living quarters, or secret area |

### Weapon Shop Interaction Map (Applied)

```
############
#W[2]C[1]@W[3]A#     [1] = buy/sell trigger (1 tile south of counter)
#W........A#     [2] = examine weapon rack (left wall)
#..........#     [3] = examine armor stand (right wall)
#.T..MM..T.#     [4] = exit door
#.c..MM..c.#
#..[1]......#
#.A......W.#
#.....[4]..#
############

The player walks to position [1], faces north, and presses the action button.
The buy/sell menu opens over the counter.
```

### Inn Reception Interaction Map (Applied)

```
################
#FFF...........#     [1] = rest trigger (talk to innkeeper)
#..............#     [2] = save point (interact for save menu)
#..T.c.c.T.....#    [3] = fireplace (examine for flavor text)
#..............#     [4] = staircase (walk onto to transition to upper floor)
#..T.c.c.T.....#    [5] = exit door
#.....[2]...[4].#
#..............#
#..T.c.c.T..[4].#
#..............#
#..[1]C.@......#
#..............#
#......[5]......#
################
```

### Potion/Item Shop Interaction Map (Applied)

```
##########
#P[2]C[1]@P[3]#     [1] = buy/sell trigger
#P......P#     [2] = examine left shelf (potion descriptions)
#........#     [3] = examine right shelf (ingredient descriptions)
#........#     [4] = readable recipe book (on table)
#.T[4]c..#     [5] = exit door
#........#
#.R..X.H.#
#...[5]..#
##########
```

---

## 5. Inn/Rest Interiors

### How Inns Work Spatially

#### Ground Floor Layout Convention

Every inn in the game follows the same spatial logic, regardless of faction:

1. **Reception area** (counter + innkeeper) near the bottom half of the room
2. **Common room** (tables, chairs, fireplace/heat source) filling the upper half
3. **Save point** near the staircase (mid-room)
4. **Staircase** to guest rooms (right side of room, standard)

The player enters from the bottom, sees the common room's atmosphere, and approaches the counter. The save point is between the counter and the stairs, encouraging the player to save before resting.

#### Upper Floor Layout Convention

All inn upper floors use a variant of Template 4:

```
############
#[P]..#[R1]..#     [P] = Player's room (always the same room, always northwest)
#.B.L.#.B..B#     [R1] = Other guest room (NPC or empty)
#.....#.....#
#...........#
#.....#.....#
#.B..L#.B..B#     [R2] = Other guest room
#[R2].#[R3]..#     [R3] = Other guest room (optional, some inns have 2, some 3)
#..SS.......#
############

The player's room is always northwest. The consistency means:
- Players learn "my room is top-left" early and never have to search.
- Morning wake-up scenes always use the same camera position.
- The slight walk from stairs to bed creates a ritual rhythm.
```

#### The Rest Sequence

When the player talks to the innkeeper and selects "Stay the night":

1. **Fade to black** (0.5 seconds)
2. **Night sky tile** -- moon and stars, 1-second hold. (Faction variant: Valdris shows a clear highland sky. Carradan shows smog-filtered moon. Thornmere shows canopy with bioluminescent highlights.)
3. **Fade to morning** -- the player's character is in bed in the guest room (the upper floor map loads with the player at the bed position)
4. **Character stands** -- sprite rises from bed, faces south
5. **HP/MP fully restored, all status ailments cleared**
6. **Player has control** -- walk downstairs to common room, exit inn

The sequence takes approximately 4 seconds total. No dialogue during the sequence. The brevity is deliberate -- rest is a mechanical action, not a narrative beat. The narrative is in what happens when the player walks back downstairs.

#### Morning Wake-Up Scene Layout

```
[Player's Room - Morning]

#.......#
#.B[*]..#     [*] = Player character, standing beside bed after wake-up
#.B.L...#     The camera is static on this room.
#.......#     Sunlight through window (Valdris) / Arcanite lamp flicker (Carradan) /
#.......#     Bioluminescent dim-to-bright (Thornmere)

The player walks south out of the room, through the hall, and down the stairs.
The common room below may have changed:
- NPCs rotate based on time/act
- Morning dialogue differs from evening dialogue
- In the Interlude, some inns have empty common rooms at dawn
```

#### Faction-Specific Inn Differences

| Element | Valdris | Carradan | Thornmere |
|---------|---------|----------|-----------|
| Heat source | Stone fireplace | Arcanite radiator | Central fire pit |
| Beds | Oak frame, wool | Metal frame, thin mattress | Hammock or reed pallet |
| Light | Ley-lamp, candles | Arcanite ceiling lamp | Bioluminescent moss |
| Ambience | Crackling fire, murmurs | Pipe hiss, distant machinery | Dripping water, insects |
| Save point visual | Gold wellspring glow | Gold wellspring (same mechanic) | Gold wellspring (same) |
| Counter material | Oak, brass fittings | Iron, glass panel | Carved heartwood |
| Night sky | Clear stars | Smog-filtered moon | Canopy glow |
| Morning cue | Sunlight through window | Lamp brightness increase | Moss brightens gradually |

---

## 6. Act-Variant Interiors

These five buildings demonstrate how interiors change across acts using the damage, corruption, and abandoned variant systems from building-palette.md Section 4.

---

### 6.1 Valdris Throne Room Across Acts

#### Act I -- Regal (Base State)

```
####################
#B.L..........L..B#
#..^^^^^^^^^^^^^^^#
#..^.G..t@t..G..^#
#..^.............^#
#..^^^^^^^^^^^^^^^#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.............#.
#................#.
#.....DDDDDD.....#
####################

Everything intact. Ley-lamps at full gold glow. Banners crisp.
Carpet clean. Aldren on the throne. Guards flanking.
The room feels grand but slightly empty -- the kingdom's best days are behind it.
```

#### Act II -- Battle-Scarred (Post-Assault)

```
####################
#B.L.........xL..x#    x = cracked wall (hairline fractures from siege impacts)
#..^^^^^^^^^^^^^^^#
#..^.G..t..t..G..^#    @ REMOVED -- Aldren is dead. The throne is empty.
#..^......r......^#    r = blood stain on flagstone (dark, dried)
#..^^^^^^^^^^^^^^^#
#..|.....==.....|.#
#..|.....==.....|.#
#..x.....==.....L.#    x = one ley-lamp extinguished (cracked bracket)
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.....==.....|.#
#..|.....==.....|x#    x = cracked column (siege damage)
#..L.....==.....L.#
#..|...........r|.#    r = another blood stain
#...............r#.
#.....DDDDDD.....#
####################

Changes from Act I:
- Aldren GONE. The throne is empty. No guards.
- Blood on flagstones (2-3 dark tiles on the carpet and near pillars)
- Cracked walls: 2-3 hairline fracture overlays on east wall
- One ley-lamp dead: bracket cracked by siege impact
- One column cracked: structural stress from the assault
- Banners still hang but one is torn (bottom edge frayed)
- The carpet runner has a scorch mark near the door (fire damage)
- The stained glass window above the throne is cracked (hairline) but intact
- Emotional reading: the room is a crime scene. The grandeur persists around the wound.
```

#### Interlude -- Rubble

```
####################
#x.x..........x..x#    x = major cracks, wall sections
#..^^^^^^^^xx^^^^.#    xx = platform edge collapsed (rubble on floor)
#..^.G..t..t.....^#    Throne visible but unreachable (rubble blocks platform)
#..^...rrr.......^#    rrr = dried blood, more extensive
#..^^^^^^^^^^^^^^^#
#..|.....==.....|.#
#.x|.XX..==..XX.|.#    XX = stone rubble (large, impassable -- 2x1 blocks)
#..x.....==.....x.#    Multiple ley-lamps dead
#..|.....==.....|.#
#..|.xx..==..xx.|.#    xx = smaller rubble piles (walkable but visible)
#..L.....==.....L.#    Only 2 of 6 ley-lamps still function
#..|.....==.....|.#
#..|.....==.....|.#
#..L.............L.#
#..|.............#.
#................#.
#.....DDDD.D.....#     One door panel broken off
####################

Changes from Act II:
- Major rubble: 4 large stone rubble blocks (impassable) in the aisle
- Smaller rubble piles: scattered along the colonnade
- Platform partially collapsed: east side has fallen masonry, blocking direct approach to throne
- Only 2 of 6 ley-lamps functional -- the room is dim, lit mostly by whatever light enters through the cracked stained glass
- One door panel missing (the double doors are damaged)
- Blood stains dried and darkened
- Banners: one has fallen entirely (on the floor behind the platform). The other hangs by one corner.
- The stained glass window has a major crack -- light enters in a broken pattern across the floor
- Dust layer on all floor tiles
- The throne itself is intact but dust-covered. Nobody has sat in it.
```

#### Epilogue -- Council Chamber (Transformed)

```
####################
#B.L..........L..B#    New banners: tri-faction (Valdris, Compact, Wilds symbols)
#..^^^^^^^^^^^^^^^#    Platform rebuilt, cleaned
#..^.............^#    Throne REMOVED. Replaced by:
#..^..TTTTTTTT..^#    TT = council table (round, 8 tiles, all three factions seated)
#..^..cccccccc..^#    cc = council chairs (mixed styles: oak, iron, heartwood)
#..|.....==.....|.#    Carpet cleaned but stain shadows remain
#..|.....==.....|.#
#..L.....==.....L.#    All ley-lamps restored (repaired brackets, gold glow)
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.....==.....|.#
#..|.....==.....|.#
#..L.....==.....L.#
#..|.............#.
#................#.
#.....DDDDDD.....#     Doors repaired
####################

Changes from Interlude:
- ALL rubble cleared. Floor repaired (some flagstones are newer -- lighter color)
- Throne REMOVED. A round council table occupies the platform -- tri-faction governance
- Council chairs are deliberately mismatched: Valdris oak, Compact brass, Thornmere heartwood.
  Three styles, one table. The visual is the political statement.
- Tri-faction banners replace the old Valdris heraldics. Each banner incorporates all three faction symbols.
- All ley-lamps repaired and lit -- warm gold, full brightness.
- Stained glass window REPAIRED but visibly mended -- the cracks are filled with a different
  color glass (a lighter gold). The window remembers its damage.
- Blood stains are gone from the surface but a shadow remains on certain flagstones.
  Examinable: "The stone remembers."
- The carpet runner is clean but the scorch mark near the door was not repaired. A deliberate
  choice: the room shows its history. Not everything should be erased.
```

---

### 6.2 A Greyvale House Across Acts

**Building:** A medium residential house in Greyvale (the fallen border town). Uses Template 7: Residential Medium (12x10) with Valdris styling, standard wealth tier.

**NPC:** A border farmer and spouse. Act I they are home. Act II they have fled. Interlude the Pallor has touched the building.

#### Act I -- Lived-In

```
############
#FF..K..K..#
#..........#
#.TT.cc....#
#..MMMM....#
#..MMMM....#
#.BB.......#
#.BB..H..K.#
#.....DD...#
############

Standard Valdris medium house.
- FF = fireplace (lit, warm gold)
- K = bookshelves (full -- farmer's almanac, children's stories, family Bible)
- TT = dining table with two chairs
- MM = rug (blue-grey, highland wool)
- BB = double bed (oak, wool blanket)
- H = chest (family valuables)
- K (lower right) = wardrobe
- Two NPCs present: farmer near hearth, spouse seated at table
- Potted herbs on the windowsill (implied by wall tile variant)
- A child's toy on the rug (1-pixel detail on the rug tile)
```

#### Act II -- Abandoned

```
############
#FF..K..K..#     FF = fireplace COLD (no flame animation, dark opening)
#..........#
#.TT.c.....#     One chair overturned (c -> toppled variant)
#..MMMM....#     Rug has a muddy boot print (overlay tile)
#..MMMM....#
#.BB.......#     Bed: stripped (mattress gone -- they took bedding when they fled)
#.BB.....K.#     H = chest OPEN and EMPTY (they took valuables)
#.....DD...#     Door: slightly ajar (not fully closed)
############

Changes from Act I:
- Fireplace cold and dark
- One chair overturned near the table (hasty departure)
- Bed stripped of blanket and mattress covering
- Chest open and empty
- Potted herbs dead (brown tile variant on windowsill)
- Child's toy still on the rug. They forgot it. Or the child insisted on leaving it.
- Dust layer beginning (10% opacity overlay on floor tiles)
- Door ajar -- the building is not locked. Nobody expects to come back.
- NPCs: NONE. The house is empty. The silence is the story.
- Examinable table: "A half-eaten meal. The bread has gone stale."
- Examinable toy: "A wooden horse. Well-loved. Left behind."
```

#### Interlude -- Pallor-Touched

```
############
#FF..K..K..#     FF = fireplace: grey crystalline growth IN the hearth
#.x........#     x = grey static cluster on wall (Stage 2 corruption)
#.TT.c.....#     Furniture faded -- color leached from wood grain
#..MMMM....#     Rug: desaturated (40-50% palette drain)
#..xxxx....#     xx = grey discoloration spreading across floor tiles
#.BB.......#     Bed: grey film on wood frame
#.BB.....K.#     K = bookshelf: books are grey, pages stiff
#.....DD...#     Door: grey, warped slightly
############

Changes from Act II:
- FULL Stage 2 Pallor corruption overlay (40-50% desaturation)
- Grey crystalline growth in the fireplace -- organic-looking but lifeless, filling the
  hearth opening. The growth is the Pallor's physical intrusion.
- Grey static clusters (3-5 pixel groups) on 2 wall tiles, lingering for several frames
- Floor tiles show grey creep from edges inward on 3-4 tiles
- All furniture is intact but colorless -- like a photograph bleached by sun
- The rug's pattern is barely visible through the grey
- Bookshelves: the books' spines have greyed. Examining: "The pages crumble at touch."
- The child's toy on the rug has turned grey. Examinable: "Cold stone. It was wood yesterday."
- No NPCs. No rats. No insects. No ambient life of any kind.
- The interior is recognizable but dead. The shape of a home with none of its life.
```

---

### 6.3 A Caldera Shop Across Acts

**Building:** "Apothecary" on the Middle Tiers of Caldera. Uses Template 2: Item/Potion Shop (10x10) with Carradan styling. Has a hidden back room that becomes a resistance hideout in the Interlude.

#### Act I (Not Visited -- Act II is first visit)

#### Act II -- Normal Apothecary

```
##########
#P.CC.@.P#     P = chemical vials in metal racks (Carradan potion shelf)
#P......P#     CC = iron counter with precision scale
#........#     @ = Apothecary NPC (white coat, professional)
#........#
#.T.c....#     T = metal mixing table with instruments
#........#     c = metal stool
#.R..X.H.#     R = metal drum (raw chemicals), X = component bin, H = locked cabinet
#...DD...#     DD = iron door (glass panel)
##########

Standard Carradan potion shop. Walls: clean brick. Floor: brick tile.
Light: Arcanite lamp over counter, gas lamp over mixing station.
Everything labeled, indexed, organized. Functional precision.
```

#### Interlude -- Resistance Hideout Behind False Wall

```
##########
#P.CC.@.P#     @ = Apothecary NPC (still running the shop -- the cover story)
#P......P#     The front room is IDENTICAL to Act II. This is deliberate.
#........#     The normalcy is the disguise.
#........#
#.T.c....#
#........#
#.R..X.[H]#    [H] = the "locked cabinet" is now a hidden door (false wall trigger)
#...DD...#          Requires: Sable in party + resistance quest flag
##########         Examining the cabinet with Sable triggers: "That's not a cabinet."

=== BEHIND THE FALSE WALL (8x8 back room) ===

########
#K..TT.#     K = resistance documents (maps, troop positions, Sable's intel network)
#......#     TT = planning table with Caldera blueprints
#.cc...#     cc = chairs (mismatched -- grabbed from different buildings)
#......#     W = weapon cache (hidden arms for the resistance)
#.W..X.#     X = supply crate (medical supplies diverted from the shop above)
#......#     L = single Arcanite lamp (dim, hidden -- no light leaks)
#L..DD.#     DD = door back to the shop (the false wall from the other side)
########

The back room is bare, practical, and tense. The walls are unpainted brick --
no one bothered with aesthetics. The planning table has hand-drawn maps with
red circles marking Compact patrol routes and resistance safe houses.

Sera Linn is here during certain quest stages. Her dialogue:
"We sell potions upstairs and revolution downstairs. The margins are better down here."
```

---

### 6.4 Ashmark Factory Floor Across Acts

**Building:** Forge Hall D, Ashmark/Caldera Lower Factory District. Not a standard template -- this is an industrial space, 16x14, using the Workshop/Forge template (Template 12) scaled up.

#### Normal Operation (Act II)

```
################
#.OOOO..OOOO..#     OO = forge furnaces (4-tile each, two operational, animated flame)
#.OOOO..OOOO..#
#..............#
#.TT..TT..TT..#     TT = metal workbenches (assembly stations)
#..............#
#==============#     == = conveyor belt (moving parts between stations, animated)
#..............#
#.XX.XX.XX.XX..#     XX = raw material bins (sorted, labeled)
#..............#
#.@.@.@.@......#     @ = workers (4 at stations, working)
#..............#
#.RR.RR........#     RR = finished product barrels
#.....DD.......#
################

Carradan industrial at full capacity:
- Two forge furnaces running (4-frame fire pulse, amber-orange glow)
- Conveyor belt animated (parts moving left to right)
- Workers at stations, working animations active
- Arcanite lamps bright overhead
- The air shimmers with heat (parallax heat-haze effect)
- Noise: rhythmic clanging, conveyor rattle, forge roar
- Floor: metal grating (drainage for coolant)
```

#### Pallor-Corrupted (Interlude)

```
################
#.OOOO..xxxx..#     Left forge: still running (amber glow, but strobing erratically)
#.OOOO..xxxx..#     Right forge: DEAD (xx = cold, dark, grey residue in the fire pit)
#..x...........#    x = grey crystalline growth on wall (Stage 2 corruption)
#.TT..TT..TT..#     Workbenches intact but tools scattered
#..............#
#==..==..==..==#     Conveyor: broken in 2 places (gaps, parts piled where they jammed)
#..x...........#    More grey growth on floor
#.XX.xX.xX.XX..#    Some material bins contaminated (x overlay -- grey streaks in ore)
#..............#
#.@...@........#     Only 2 workers remain. One is motionless (Pallor-touched).
#..............#     The other works mechanically, not looking up.
#.RR.RR........#     Finished product barrels: some have grey discoloration
#.....DD.......#     Explosion scar on east wall (new rubble tiles, blocked passage)
################

Changes from Normal:
- Right forge DEAD. Grey residue fills the fire pit. Examinable: "Cold. The stone is grey
  where the fire was. It smells like nothing."
- Left forge strobing: flame animation alternates between amber and grey-white every few seconds.
  The Pallor energy is bleeding into the fuel line.
- Conveyor belt broken in two segments. Parts piled at the break points.
- Grey crystalline growth on 3 wall tiles and 2 floor tiles (Stage 2)
- Material bins partially contaminated -- ore has grey streaks
- Worker count reduced from 4 to 2. One is motionless (standing at station, trembling
  animation, no dialogue -- the fading). The other works without speaking.
- Explosion scar on east wall: rubble tiles block a former passage. This is the result
  of an Arcanite surge -- the energy overloaded.
- Arcanite lamps: 2 of 4 overhead lamps strobing between blue-white and grey-white
- Sound: irregular clanging. Silences where there should be rhythm. The wrong note.
- The heat-haze effect is gone. The air is cold despite the running forge.
```

---

### 6.5 Maren's Refuge Across Acts

#### Act I -- Normal (Warm, Cluttered, Alive)

See Section 1.3 for the full layout. Summary of the emotional state:
- Bioluminescent moss on exterior walls, warm amber ley-glow from within
- Spirit creatures (translucent fox, moth, unidentifiable) perch on the roof and drift inside
- Every bookshelf full, work desk cluttered, herbs drying, artifacts displayed
- Maren is present, sharp, curious, alarmed by the Pendulum
- The basement library is explorable, every shelf rewards curiosity
- The ley-line tap glows steady amber

```
Ground Floor -- Act I State:

################
#KK..KK..KK.ah#     Full bookshelves, herb rack, artifact display
#..............#     Spirit creature perches occupied
#.WW...FF......#     Fireplace warm amber, work desk covered in notes
#.WW...FF..mm.#     Map table with fresh pins
#.@............#     Maren present at work desk
#..~..a......K.#     Root tendrils growing (alive, warm brown)
#......r.....K.#     Reading chair worn but welcoming
#..p.........K.#     Spirit creatures inside
#.......b.b..~.#     Books on the cot (she sleeps with books)
#..............#
#.....DD...p...#
################
```

#### Interlude -- Abandoned (She's Gone)

```
################
#KK..KK..KK.ah#     Bookshelves: SCATTERED. Books pulled hastily, some on floor.
#.......k......#     k = books fallen on floor (1x1 tile, 3-4 scattered)
#.WW...FF...k..#     FF = fireplace COLD (ley-tap dimmed, amber reduced to faint flicker)
#.WW...FF..mm.#     Map table: pins removed hastily, scratch marks
#.k............#     @ REMOVED -- Maren is GONE
#..~..a......K.#     Root tendrils: greying at tips (Stage 1 corruption beginning)
#......r.....K.#     Reading chair undisturbed (she didn't sit down before leaving)
#..............#     Spirit creatures: GONE. Perches empty.
#.......b.b..~.#     Cot: books still piled, plus a hastily written NOTE
#..............#
#.....DD.......#     Door: ajar, wind sounds
################

Changes from Act I:
- Maren ABSENT. The room feels immediately wrong because she is the room's center.
- Books scattered on floor (3-4 loose book tiles) -- she grabbed specific volumes in haste
- Fireplace dim -- the ley-line tap is weakening. Amber reduced to faint flicker.
- Spirit creatures GONE. The perches are empty. The absence is felt.
- Root tendrils greying at tips -- the forest is beginning to fail
- A NOTE on the cot (interactable):
  "Gone to the Archive. If I'm not back in a month, I was wrong. Don't follow."
- Map pins removed -- she took her research with her
- The work desk still has notes, but the Pendulum analysis is gone (she took it)
- Herb rack: herbs dried to brown (no one tended them)
- The ley-line tap in the basement is dim. The crystal's glow is pale amber, barely visible.
- The basement bookshelves are intact -- she didn't take the library, only her working notes.
- The silence is total. No spirit hum, no fire crackle, no moss glow. Dead quiet.
```

#### Epilogue -- Restored with New Books

```
################
#KK..KK..KK.ah#     Bookshelves: FULL AGAIN, and then some. New books mixed with old.
#..............#     Spirit creatures RETURNED (and more than before)
#.WW...FF......#     FF = fireplace bright (ley-tap restored, BRIGHTER than Act I)
#.WW...FF..mm.#     Map table: new pins in new positions
#..............#     @ NOT PRESENT -- Maren is elsewhere, but her presence is felt
#..~..a..n...K.#     n = NEW books (different spines, post-war publications)
#......r.....K.#     Root tendrils: living, GREEN (new growth around greyed sections)
#..p.........K.#     Spirit creatures inside: more than before, new species
#.......b.b..~.#     Cot: books still on it. Same habit. Some are new.
#..p...........#
#.....DD...p...#
################

Changes from Interlude:
- Bookshelves refilled. New books mixed with old -- different spine colors, post-war
  bindings (Compact precision-printed alongside Valdris leather-bound alongside Thornmere
  bark-pressed). The library has become tri-faction.
- Fireplace BRIGHTER than Act I -- the ley-line tap has been restored and strengthened
- Spirit creatures returned in greater numbers. New species (a small bird-like shape,
  something crystalline). They are bolder -- not just perching but moving through the room.
- Root tendrils show new green growth around the greyed sections. The grey persists as
  scars, but living wood wraps around it. The roots remember and grow anyway.
- The work desk has new notes -- not in Maren's handwriting. Others have used the space.
  Examinable: "Research notes in three different hands. Someone is continuing her work."
- The reading chair has a new cushion. Someone cared enough to replace it.
- Map table pins in new positions -- the post-war geography is different
- The NOTE from the Interlude is gone. Replaced by a stack of correspondence.
  Examinable: "Letters from Valdris, Corrund, and Greywood Camp. All addressed to
  'The Refuge.' She is not here, but she is not forgotten."
- The space-folding still works. The cottage is still bigger inside than out.
  Examining the wall: "Still humming. Some magic endures without explanation."
```

---

## Design Notes

### Template-to-Instance Workflow

To build any new interior from these references:

1. **Select base template** from building-palette.md (Templates 1-12)
2. **Apply faction material swap** (Section 3 of building-palette.md)
3. **Apply wealth tier** (sparse/standard/dense from Section 6 of building-palette.md)
4. **Mirror horizontally** if the building is in a mirrored position on the exterior map
5. **Swap 2-3 optional objects** to differentiate from other instances of the same template
6. **Place NPCs** per the building-palette.md NPC position guides
7. **Mark interaction points** per Section 4 of this document
8. **Apply act-variant damage** per Section 4 of building-palette.md, using Section 6 of this document as visual reference
9. **Check approach space** -- every interactable object needs 1 clear tile in front of it

### Consistency Rules

- **Doors always on the south wall.** The player enters from the bottom of the screen.
- **Shopkeepers always face south.** The player approaches from below.
- **Save points glow amber-gold.** Always. Even in Carradan buildings. The ley-line wellspring aesthetic is universal.
- **The player's inn room is always northwest.** Every inn, every city, every act.
- **Counter triggers are always 1 tile south of the counter center.** This is muscle memory for the player.
- **Faction lighting is consistent.** Ley-lamps (gold) in Valdris. Arcanite lamps (white-blue) in Carradan. Bioluminescent moss (teal) in Thornmere. Mixing sources only in cross-faction locations (The Pendulum Tavern, Gael's Span).

### Room Density Benchmarks

| Building Wealth | Floor Coverage | Objects Count (12x10 room) | Emotional Read |
|----------------|---------------|---------------------------|----------------|
| Poor / Abandoned | 30-40% | 4-6 objects | Empty, austere, desperate |
| Standard | 50-60% | 8-12 objects | Comfortable, lived-in |
| Wealthy | 70-80% | 14-20 objects | Rich, full, or claustrophobic |
| Maren's Refuge | 85%+ | 25+ objects | Obsessive, brilliant, lonely |

### Story Interiors vs. Template Interiors

The six story-critical interiors in Section 1 are memorable BECAUSE every other interior follows the template rules. When a building breaks the pattern, the player notices. Maren's cottage is striking because every other building has clean walls and organized furniture. The Throne Room feels vast because every other room is 12x10. The Pendulum Tavern feels warm because every other Interlude interior is grey and dying.

The templates are not a limitation. They are the baseline that makes exceptions powerful.
