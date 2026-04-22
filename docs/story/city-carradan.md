# Carradan Compact -- City Layouts

Detailed tile-level layouts for every Carradan Compact settlement. Each city is designed for 16x16 pixel tiles on a 320x180 viewport (20x11 tiles visible per screen). Carradan cities share an industrial visual vocabulary -- brick, iron, brass, forge-glow, smog -- but each has a distinct identity shaped by its economic function and position within the Compact's hierarchy.

Design philosophy: Carradan cities are **oppressive but functional**. The wealth gap is visible in the architecture. Streets widen as you move toward the center of power. Buildings get taller, cleaner, more ornamented. Near factories and extraction sites, housing is cramped, identical, and soot-stained. The player should feel the class structure before any NPC explains it.

Reference palette: Carradan Industrial biome (see `biomes.md` Section 2). Brick `#A86B4E`, soot `#2E2824`, iron `#5A5A62`, brass `#C49840`, forge glow `#E88830`, Arcanite blue `#82B8D4`, smoke `#7A7068`.

---

## Table of Contents

1. [Corrund (Capital)](#1-corrund-capital)
2. [Caldera](#2-caldera)
3. [Ashmark](#3-ashmark)
4. [Bellhaven](#4-bellhaven)
5. [Millhaven](#5-millhaven)
6. [Ashport](#6-ashport)
7. [Ironmark Citadel](#7-ironmark-citadel)
8. [Ironmouth](#8-ironmouth)
9. [Gael's Span](#9-gaels-span)
10. [Kettleworks](#10-kettleworks)

---

## 1. Corrund (Capital)

### City Overview

**Size:** Large city -- approximately 240x196 tiles (roughly 12 screens at 20x11 each)
**Screens:** 15 explorable areas across 4 vertical tiers
**Layout:** Corrund is built vertically along the Corrund River delta. Iron bridges span canals at three elevations. The Axis Tower at the city center pierces the smog layer. Below the bridges lies the Undercroft -- stacked tenements in perpetual shadow. Above, merchant halls with glass facades catch the amber light. The city is bisected by the main canal, with industrial districts to the east and commercial/government districts to the west.
**Entry/exit points:** South Gate (overworld, road from Ashmark), North Canal Gate (river barges from Gael's Span direction), East Rail Terminal (rail from Ashmark/Caldera), West Docks (canal barges). During Interlude: Undercroft sewer entrance (Sable's infiltration route).

```
CORRUND -- Capital of the Carradan Compact
(240 tiles wide x 196 tiles tall, ~15 screens)

KEY:  ~~~ = canal water   === = rail line   ### = bridge (iron)
      [...] = building     |.| = alley      >>> = gate/checkpoint

                         N (to Gael's Span)
    ___________________________________________________________
   |                    NORTH CANAL GATE                       |
   |  [Guard       ]   ~~~~~~~~~~~~~~~   [Canal Control  ]     |
   |  [Post        ]   ~~~~~~~~~~~~~~~   [Office         ]     |
   |  [            ]   ~~~~~~~~~~~~~~~   [               ]     |
   |_________##########~~~~~###~~~~~##########_________________|
            |          UPPER BRIDGE          |
   _________|________________________________|_________________
   |                                                           |
   |  CONSORTIUM QUARTER (west)     MERCHANT MILE (east)       |
   |                                                           |
   |  [Consortium  ][Lira's    ]    [Glass-Front ][Arcanite   ]|
   |  [Council     ][Hidden    ]    [Merchant    ][Lamp       ]|
   |  [Hall        ][Workshop  ]    [Hall        ][Emporium   ]|
   |  [            ][  (secret)]    [            ][           ]|
   |                                                           |
   |  [Engineer's  ][Brass     ]    [Streetcar   ][Exchange   ]|
   |  [Guild       ][Fountain  ]    [Station     ][House      ]|
   |  [Office      ][  Plaza   ]    [(stopped)   ][           ]|
   |                                                           |
   |             [  AXIS  TOWER  ]                             |
   |             [ (central      ]                             |
   |             [  spire, glass ]                             |
   |             [  and iron,    ]                             |
   |             [  glowing core)]                             |
   |             [               ]                             |
   |                                                           |
   |  [Records   ][Courier    ]    [Moneylender ][Tailor     ]|
   |  [Archive   ][Office     ]    [(usury)     ][& Finery   ]|
   |                                                           |
   |_________##########~~~~~###~~~~~##########_________________|
            |         MIDDLE BRIDGE          |
   _________|________________________________|_________________
   |                                                           |
   |  CANAL DISTRICT (mixed use)                               |
   |                                                           |
   |  [Warehouse  ][Warehouse  ]   ~~~   [Workshop  ][Pipe    ]|
   |  [A (locked) ][B          ]   ~~~   [(repairs) ][Fitter  ]|
   |  [           ][           ]   ~~~   [          ][        ]|
   |                                     ~~~                   |
   |  [Canal-     ]  [Bargeman's]  ~~~   [Steam     ][Pump   ]|
   |  [side Inn   ]  [Tavern    ]  ~~~   [Laundry   ][House  ]|
   |  [(save pt)  ]  [          ]  ~~~   [          ][       ]|
   |                               ~~~                         |
   |  [Loading    ][Crane      ]   ~~~   [Arcanite  ][Supply ]|
   |  [Bay        ][Platform   ]   ~~~   [Lamp Works][Depot  ]|
   |                               ~~~                         |
   |====[Rail Terminal]=========================[Rail Yard]====|
   |                                                           |
   |_________##########~~~~~###~~~~~##########_________________|
            |         LOWER BRIDGE           |
   _________|________________________________|_________________
   |                                                           |
   |  THE UNDERCROFT (below the bridges)                       |
   |                                                           |
   |  [Tenement][Tenement][Tenement]   [Tenement][Tenement]   |
   |  [Stack A ][Stack B ][Stack C ]   [Stack D ][Stack E ]   |
   |  [3 floor ][3 floor ][3 floor ]   [2 floor ][3 floor ]   |
   |  |.|      |.|       |.|          |.|       |.|           |
   |  [Soup    ][Tash's  ][Rat &   ]   [Fenced  ][Sable's   ]|
   |  [Kitchen ][Black   ][Ratchet ]   [Lot     ][Contact   ]|
   |  [(free   ][Market  ][(tavern)]   [(stolen ][House     ]|
   |  [ meals) ][(under- ][        ]   [ goods) ][          ]|
   |  [        ][ground) ][        ]   [        ][          ]|
   |                                                           |
   |  [Sewer       ]   [Work Gang    ]   [Abandoned   ]       |
   |  [Entrance    ]   [Bunkhouse    ]   [Pump Station]       |
   |  [(to tunnels)]   [             ]   [(secret     ]       |
   |                                     [ passage)   ]       |
   |                                                           |
   |  >>> SOUTH GATE (to overworld, road south) >>>            |
   |___________________________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Guard Post | Military | North Canal Gate | 2 Compact soldiers | -- | Checkpoint, papers checked |
| 2 | Canal Control Office | Government | North Canal Gate | Canal master | -- | Controls bridge mechanisms |
| 3 | Consortium Council Hall | Government | Consortium Quarter | Fenn Acari (Act II), Consortium officials | -- | Acari presides during Act II; Interlude dungeon entrance |
| 4 | Lira's Hidden Workshop | Safe house | Consortium Quarter (secret) | Lira (Interlude) | Save point, crafting | Hidden behind false wall; requires quest trigger |
| 5 | Glass-Front Merchant Hall | Commerce | Merchant Mile | 3 merchants | General goods, premium | Upper-class shop, high prices |
| 6 | Arcanite Lamp Emporium | Specialty shop | Merchant Mile | Shopkeeper | Accessories, light sources | Forgewright gadgets |
| 7 | Engineer's Guild Office | Guild | Consortium Quarter | Guild clerk | Job board | Side quest source |
| 8 | Brass Fountain Plaza | Plaza | Consortium Quarter | Various NPCs | -- | Central gathering area, environmental storytelling |
| 9 | Streetcar Station | Transit | Merchant Mile | -- | -- | Non-functional; environmental detail |
| 10 | Exchange House | Commerce | Merchant Mile | Moneylender | Coin stamping (1:1) | Re-mints foreign gold into Compact coins; flavor only, no value change |
| 11 | Axis Tower | Dungeon/Government | City center | Consortium leaders, boss | -- | Interlude dungeon (4 floors) |
| 12 | Records Archive | Government | West of Axis Tower | Archivist NPC | Lore | Optional deep-lore content |
| 13 | Courier Office | Service | West of Axis Tower | Courier NPC | Message delivery | Flavor |
| 14 | Moneylender | Service | East of Axis Tower | Moneylender NPC | Loans (gameplay mechanic) | Usurious rates |
| 15 | Tailor & Finery | Commerce | East of Axis Tower | Tailor | Armor (light), cosmetic | Upper-class equipment |
| 16 | Warehouse A | Storage | Canal District | -- | -- | Locked in Act II; lootable Interlude |
| 17 | Warehouse B | Storage | Canal District | Dockhand NPC | -- | Trade goods, flavor |
| 18 | Workshop (repairs) | Service | Canal District | Mechanic NPC | Equipment repair | Restores durability |
| 19 | Pipe Fitter | Service | Canal District | Pipe fitter NPC | -- | Flavor; Interlude quest |
| 20 | Canalside Inn | Inn | Canal District | Innkeeper | Save point, rest | Primary save location |
| 21 | Bargeman's Tavern | Tavern | Canal District | Barman, 4 patrons | Rumors, drinks | Information source |
| 22 | Steam Laundry | Service | Canal District | Laundress NPC | -- | Flavor |
| 23 | Pump House | Utility | Canal District | -- | -- | Environmental puzzle (water levels) |
| 24 | Loading Bay | Utility | Canal District | Dock workers | -- | Flavor |
| 25 | Crane Platform | Utility | Canal District | -- | -- | Traversal puzzle |
| 26 | Arcanite Lamp Works | Factory | Canal District | Foreman, workers | -- | Tour available; environmental storytelling |
| 27 | Supply Depot | Commerce | Canal District | Quartermaster | Consumables, tools | Military surplus at fair prices |
| 28 | Rail Terminal | Transit | Canal District | Rail Conductor | Fast travel (Ashmark, Caldera, Kettleworks) | 100g per trip per [transport.md](transport.md); erratic in Interlude |
| 29 | Rail Yard | Utility | Canal District | -- | -- | Environmental detail; derailed carts in Interlude |
| 30 | Tenement Stacks A-E | Housing | Undercroft | Various worker NPCs | -- | 5 buildings, each multi-floor; fading victims |
| 31 | Soup Kitchen | Service | Undercroft | Cook NPC | Restore 25% HP to all party (once per visit; no AC) | Charity run by a former worker |
| 32 | Tash's Black Market | Underground shop | Undercroft | Tash | Forged papers, contraband, intel | Sable's primary contact |
| 33 | Rat & Ratchet | Tavern | Undercroft | Barkeep, informants | Rumors, cheap drinks | Low-class tavern; resistance contacts |
| 34 | Fenced Lot | Underground shop | Undercroft | Fence NPC | Sell stolen goods, buy cheap gear | Black market overflow |
| 35 | Sable's Contact House | Safe house | Undercroft | Contact NPC (Interlude) | Intel | Sable's informant network |
| 36 | Sewer Entrance | Passage | Undercroft | -- | -- | Connects to Axis Tower tunnels |
| 37 | Work Gang Bunkhouse | Housing | Undercroft | Gang NPCs | -- | Flavor; side quest |
| 38 | Abandoned Pump Station | Passage | Undercroft | -- | -- | Secret passage to Ironmark tunnel |

### Shop Inventories

**Glass-Front Merchant Hall (Upper City)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Arcanite Edge | Weapon | 2400 | Yes | Yes | Forgewright-forged blade, +ATK |
| Brasshide Vest | Armor | 1800 | Yes | Yes | Arcanite-bonded leather |
| Precision Lens | Accessory | 1200 | Yes | Yes | +accuracy, Forgewright gadget |
| Compact Ration Pack | Consumable | 80 | Yes | Yes | Full HP restore |
| Surge Tonic | Consumable | 200 | Yes | No | +ATK buff, 3 turns |
| Arcanite Greaves | Armor | 2200 | No | Yes | Interlude stock upgrade |
| Forgewright Scope | Accessory | 2800 | No | Yes | Reveals enemy weaknesses |

**Tash's Black Market (Undercroft)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Identity Papers (Grade 3) | Key item | 1500 | Yes | Yes | Allows passage in restricted areas |
| Stolen Arcanite Core | Material | 800 | Yes | Yes | Crafting component |
| Smoke Bomb | Consumable | 150 | Yes | Yes | Guaranteed escape from battle |
| Blacklist Ledger | Key item | 2000 | No | Yes | Side quest item; exposes Guild corruption |
| Pallor Ward (crude) | Accessory | 3000 | No | Yes | Reduces Pallor status buildup |
| Tunnel Map | Key item | 500 | No | Yes | Reveals sewer/tunnel shortcuts |
| Contraband Tonic | Consumable | 400 | No | Yes | Full party HP/MP restore; illegal |

**Supply Depot (Canal District)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Potion | Consumable | 50 | Yes | Yes | Restore 100 HP |
| Sleeping Bag | Consumable | 250 | Yes | Yes | Rest heal outside dungeons |
| Smoke Bomb | Consumable | 100 | Yes | No | Flee from non-boss battle |
| Ley-Lantern | Tool | 60 | Yes | Yes | Illuminates dark areas |
| Surplus Helm | Armor | 600 | Yes | Yes | Basic head protection |
| Surplus Shield | Armor | 800 | Yes | Yes | +DEF, military issue |

### Points of Interest

**Save Points:**
- Canalside Inn (Canal District) -- primary save
- Lira's Hidden Workshop (Consortium Quarter) -- Interlude only, after discovery
- Axis Tower entrance hall (during dungeon sequence)

**Hidden Treasures:**
- Warehouse A: Locked chest containing Arcanite Ingot (crafting material). Requires lockpick or Sable's skill.
- Sewer tunnels: 3 hidden chests along the sewer route. Contains Compact military intelligence documents, a Forgewright prototype gauntlet, and 2,000 gold.
- Abandoned Pump Station: Behind a rusted panel, a passage leads to a small room with a chest containing the Conduit Ring (accessory: +MP regen near machinery).
- Brass Fountain Plaza: Examine the fountain's base to find an inscription. Reading it with Lira in the party triggers a lore scene about Corrund's founding.

**Environmental Storytelling:**
- The Undercroft tenements visibly lean against each other. Laundry lines stretch between buildings. Children (sprites without idle animations in the Interlude -- standing still, not playing) occupy the alleys.
- The canal water changes color by act: polluted green-grey in Act II, grey with no reflection in the Interlude.
- Public address horns on lampposts broadcast Consortium announcements. In the Interlude, the announcements contradict each other.
- The streetcar tracks run through the Merchant Mile but the cars are stopped. Workers in Act II complain about the delay. In the Interlude, no one mentions them.

**Secret Areas:**
- **Sewer Network:** Accessible from the Undercroft. 3-screen tunnel system connecting to the Axis Tower underground level and the tunnel to Ironmark Citadel. Populated by forge-smoke creatures and malfunctioning service automata.
- **Lira's Workshop:** Hidden behind a false wall in the Consortium Quarter. Requires Sable to identify the entry mechanism (Interlude quest). Contains workbench (crafting), save crystal, and story cutscene trigger.
- **Axis Tower Sublevel:** Below the main tower, accessed through the sewer. Contains the ley-line conduit junction that powers the city. Environmental puzzle: redirect conduit flow to open sealed doors.

### Act-by-Act Changes

**Act II (optional visit during diplomatic mission):**
- Full city accessible except Axis Tower interior and Lira's Workshop
- Rail connection to Ashmark/Caldera functional
- Upper city is prosperous; Undercroft is desperate but stable
- Tash available for forged papers and basic contraband

**Interlude (Sable infiltrates):**
- North Canal Gate checkpoint is stricter -- requires Grade 3 papers or Undercroft sewer route
- Several upper-city bridges raised (security lockdown) -- the Consortium Quarter is partially isolated
- Canal District has flooded sections (2 screens partially submerged -- new water tiles replacing walkways)
- Axis Tower exterior shows erratic energy arcs (lightning between conduits)
- Undercroft is busier (refugees from upper-city disruptions)
- Rail Terminal erratic -- trains run on unpredictable schedule
- Axis Tower becomes a dungeon (4 interior floors + sublevel)
- After Kole's defeat: raised bridges lowered, energy arcs stop, Consortium in disarray

**Act III (brief passage):**
- Barricades in streets from internal faction fighting
- Factories split between running and shuttered
- Undercroft is the only reliable commerce area
- The party passes through quickly; most buildings accessible but NPCs have shortened dialogue

**Epilogue:**
- Bridges lowered. Undercroft wall demolished -- light enters for the first time
- Bridgewright guild signs on several buildings
- Canal water cleaner (still industrial, no grey film)
- Valdris trade delegation office in the Merchant Mile
- Green shoots in Undercroft cobblestone cracks

---

## 2. Caldera

### City Overview

**Size:** Medium-large city -- approximately 160x168 tiles (8-10 screens)
**Screens:** 10 explorable areas across 3 tiers plus undercity
**Layout:** Caldera is a tiered bowl built into a volcanic caldera basin. Three concentric rings descend toward the central smelting complex. The Upper Rim holds the wealthy -- the Merchants' Council Hall, the Forgewrights' Academy, guild leadership estates. The Middle Tiers contain workshops, markets, and mid-level housing. The Lower Factory District sits closest to the central pit, perpetually hazy with forge-smoke. Beneath it all, maintenance tunnels and abandoned forge-channels form the undercity where the resistance and black market operate.
**Entry/exit points:** North Gate (road from Corrund/Ashmark), South Gate (road to Millhaven), Rail Station (upper rim, connects to Corrund), Undercity Escape Tunnel (leads to overworld south -- emergency exit).

```
CALDERA -- The Compact's Largest Forge-City
(160 tiles wide x 168 tiles tall, ~10 screens)

KEY:  ^^^ = caldera rim   *** = molten channel   ||| = heat vent
      [...] = building     === = rail line        vvv = descending tier

               N (road to Corrund / Ashmark)
    ___________________________________________________________
   |  >>> NORTH GATE >>>                    === RAIL STATION ===|
   |                                                           |
   |  ^^^ UPPER RIM (wealthy district) ^^^                    |
   |                                                           |
   |  [Merchants'  ][Fenn        ]   [Forgewrights'][Guild    ]|
   |  [Council     ][Acari's    ]   [Academy      ][Master's ]|
   |  [Hall        ][Private    ]   [(Lira's alma ][Estate   ]|
   |  [(political  ][Office     ]   [ mater)      ][         ]|
   |  [ intrigue)  ][           ]   [             ][         ]|
   |                                                           |
   |  [Terrace  ]  [Sky        ]    [Upper       ][Drayce's  ]|
   |  [Garden   ]  [Lounge     ]    [Market      ][Residence ]|
   |  [(park)   ]  [(wealthy   ]    [(premium    ][(Elyn     ]|
   |  [         ]  [ tavern)   ]    [ goods)     ][ Drayce)  ]|
   |                                                           |
   |  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv |
   |                                                           |
   |  ^^^ MIDDLE TIERS (workshops, markets) ^^^                |
   |                                                           |
   |  [Tinker's   ][Apothecary ]   [Mid-Tier   ][Arcanite   ]|
   |  [Workshop   ][            ]   [Inn        ][Weapons    ]|
   |  [(repairs)  ][            ]   [(save pt)  ][Smith      ]|
   |                                                           |
   |  [Workers'   ][Public      ]   [Compact    ][Tool       ]|
   |  [Canteen    ][Notice      ]   [Post       ][Merchant   ]|
   |  [           ][Board       ]   [Office     ][           ]|
   |                                                           |
   |  [Housing   ][Housing    ][Housing    ]  [Stair to     ]|
   |  [Block A   ][Block B    ][Block C    ]  [Undercity    ]|
   |  [          ][           ][           ]  [(hidden)     ]|
   |                                                           |
   |  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv |
   |                                                           |
   |  ^^^ LOWER FACTORY DISTRICT ^^^                           |
   |                                                           |
   |  [Smelting  ][Smelting  ]  |||  [Forge     ][Forge     ]|
   |  [Line A    ][Line B    ]  |||  [Hall C    ][Hall D    ]|
   |  [(active)  ][(active)  ]  |||  [(active)  ][(damaged) ]|
   |                            |||                           |
   |  [Worker    ][Worker    ]  |||  [Dael's    ][Kel's     ]|
   |  [Barracks  ][Barracks  ]  |||  [Corner    ][Bellows   ]|
   |  [Row 1     ][Row 2     ]  |||  [(union    ][Station   ]|
   |  [          ][          ]  |||  [ meeting) ][          ]|
   |                            |||                           |
   |       [CENTRAL SMELTING COMPLEX]                          |
   |       [  (massive open-air pit  ]                         |
   |       [   over volcanic vents,  ]                         |
   |       [   molten metal rivers   ]                         |
   |       [   in channels)          ]                         |
   |       ***********|||***********                           |
   |                                                           |
   |  >>> SOUTH GATE (road to Millhaven) >>>                   |
   |___________________________________________________________|

    UNDERCITY (below -- accessible via hidden stairs in Middle Tier)
    ___________________________________________________________
   |                                                           |
   |  [Tash's     ][Sera Linn's ]   [Smuggler's ][Abandoned ]|
   |  [Black      ][Resistance  ]   [Cache      ][Forge     ]|
   |  [Market     ][HQ          ]   [           ][Channel   ]|
   |  [(den)      ][(safe house)]   [           ][(passage) ]|
   |                                                           |
   |  [Lira's     ][Undercity   ]   [Mira's     ][Escape    ]|
   |  [Hidden     ][Tavern      ]   [Hidden     ][Tunnel    ]|
   |  [Workshop   ][("The       ]   [Cartography][(to       ]|
   |  [(save pt,  ][ Bellows")  ]   [Studio     ][ overworld]|
   |  [ crafting) ][            ]   [(maps)     ][ south)   ]|
   |___________________________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Merchants' Council Hall | Government | Upper Rim | Fenn Acari, council members | -- | Political intrigue hub |
| 2 | Fenn Acari's Private Office | Government | Upper Rim | Fenn Acari (private) | -- | Interlude confrontation scene |
| 3 | Forgewrights' Academy | Education | Upper Rim | Jace Renn, Cira, students | Lore, side quests | Lira's alma mater |
| 4 | Guild Master's Estate | Residence | Upper Rim | Elyn Drayce | -- | Interlude encounter with Drayce |
| 5 | Terrace Garden | Park | Upper Rim | Strolling NPCs | -- | Only green space in Caldera; wilting in Interlude |
| 6 | Sky Lounge | Tavern | Upper Rim | Wealthy patrons | Premium drinks, rumors | Upper-class tavern; contrasts with Undercity |
| 7 | Upper Market | Commerce | Upper Rim | 3 merchants | Premium weapons, armor, accessories | Expensive but high quality |
| 8 | Drayce's Residence | Residence | Upper Rim | Elyn Drayce (private) | -- | Letters revealing her internal conflict |
| 9 | Tinker's Workshop | Service | Middle Tiers | Mechanic NPC | Equipment repair, upgrades | Can enhance Forgewright gear |
| 10 | Apothecary | Commerce | Middle Tiers | Apothecary NPC | Potions, remedies, antidotes | Better stock than worker areas |
| 11 | Mid-Tier Inn | Inn | Middle Tiers | Innkeeper | Save point, rest | Primary save location |
| 12 | Arcanite Weapons Smith | Commerce | Middle Tiers | Weaponsmith NPC | Weapons (mid-tier) | Forgewright-crafted arms |
| 13 | Workers' Canteen | Service | Middle Tiers | Cook, workers | Cheap food (HP restore) | Dialogue about conditions |
| 14 | Public Notice Board | Utility | Middle Tiers | -- | Side quest postings | Guild job listings, wanted posters |
| 15 | Compact Post Office | Service | Middle Tiers | Postal clerk | -- | Flavor; intercepted letters in Interlude |
| 16 | Tool Merchant | Commerce | Middle Tiers | Shopkeeper | Tools, consumables | Practical supplies |
| 17 | Housing Blocks A-C | Housing | Middle Tiers | Workers, families | -- | 3 buildings; progressive fading symptoms |
| 18 | Smelting Lines A-B | Factory | Lower District | Foremen, workers | -- | Environmental hazard areas |
| 19 | Forge Halls C-D | Factory | Lower District | Workers | -- | Hall D damaged (explosion scar) in Interlude |
| 20 | Worker Barracks Rows 1-2 | Housing | Lower District | Workers | -- | Identical cramped quarters; the fading's epicenter |
| 21 | Dael's Corner | Meeting place | Lower District | Dael Corran | -- | Union organizing location; side quest hub |
| 22 | Kel's Bellows Station | Workplace | Lower District | Kel | -- | Child laborer; environmental storytelling |
| 23 | Central Smelting Complex | Industrial | Lower District center | -- | -- | Not enterable; visual/audio spectacle |
| 24 | Tash's Black Market | Underground shop | Undercity | Tash | Contraband, forged papers, intel | Sable's Compact contact |
| 25 | Sera Linn's Resistance HQ | Safe house | Undercity | Sera Linn, resistance members | Intel, safe passage | Side quests: worker rights arc |
| 26 | Smuggler's Cache | Storage | Undercity | -- | -- | Hidden loot: Arcanite components |
| 27 | Abandoned Forge Channel | Passage | Undercity | -- | -- | Connects to Lower District and escape tunnel |
| 28 | Lira's Hidden Workshop | Safe house | Undercity | Lira (Interlude) | Save point, crafting bench | Story cutscene trigger |
| 29 | The Bellows (tavern) | Tavern | Undercity | Barkeep, resistance contacts | Cheap drinks, rumors | Underground watering hole |
| 30 | Mira's Hidden Cartography Studio | Workspace | Undercity | Mira Thenn | Ley line maps (key items) | Side quest: classified report |
| 31 | Escape Tunnel | Passage | Undercity | -- | -- | Emergency exit to overworld south |
| 32 | Rail Station | Transit | Upper Rim | Rail Conductor | Fast travel (Ashmark, Corrund, Kettleworks) | 100g per trip per [transport.md](transport.md); erratic in Interlude |

### Shop Inventories

**Upper Market (Upper Rim)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Arcanite Saber | Weapon | 3200 | Yes | Yes | High-tier Forgewright blade |
| Heat-Treated Plate | Armor | 2800 | Yes | Yes | Volcanic-forged; fire resist |
| Caldera Ring | Accessory | 1600 | Yes | Yes | +fire resist, caldera motif |
| Master Tonic | Consumable | 300 | Yes | Yes | Full HP + status cure |
| Guild Certification | Key item | 5000 | Yes | No | Opens restricted areas |
| Drayce's Prototype | Weapon | 6000 | No | Yes | Elyn's personal design; best Compact weapon |
| Arcanite Full Plate | Armor | 5500 | No | Yes | Top-tier Compact armor |

**Arcanite Weapons Smith (Middle Tiers)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Forgewright Blade | Weapon | 1600 | Yes | Yes | Standard issue, reliable |
| Arcanite Dagger | Weapon | 900 | Yes | Yes | Quick, Sable-appropriate |
| Iron-Brass Shield | Armor | 1200 | Yes | Yes | Compact military standard |
| Forge Guard | Armor | 1000 | Yes | Yes | Heat-resistant body armor |
| Whetstone (Arcanite) | Consumable | 200 | Yes | Yes | Temporary +ATK buff |
| Smelter's Hammer | Weapon | 2000 | No | Yes | Heavy; Edren-appropriate |

**Tash's Black Market (Undercity)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Forged Identity Papers | Key item | 1200 | Yes | Yes | Grade 2-3 clearance |
| Stolen Guild Seal | Key item | 800 | Yes | Yes | Opens Guild-locked doors |
| Resistance Contact List | Key item | 600 | No | Yes | Reveals safe houses on map |
| Pallor Ward (jury-rigged) | Accessory | 2500 | No | Yes | Reduces Pallor status |
| Smuggled Arcanite Core | Material | 600 | Yes | Yes | Crafting component |
| Blackout Bomb | Consumable | 300 | No | Yes | AoE blind in battle |
| Classified Extraction Report | Key item | 2000 | No | Yes | Lore + side quest trigger |

### Points of Interest

**Save Points:**
- Mid-Tier Inn (Middle Tiers) -- primary save
- Lira's Hidden Workshop (Undercity) -- Interlude only
- Forge Hall C (Lower District) -- before factory hazard section

**Hidden Treasures:**
- Terrace Garden: Examine the withered tree in the Interlude. Lira identifies it as a ley-grafted specimen. Behind its roots: the Rootspark Pendant (accessory: +nature magic affinity).
- Abandoned Forge Channel: 2 chests in dead-end branches. Contains Molten Gear (crafting material) and 1,500 gold.
- Kel's Bellows Station: If the player speaks to Kel three times across different visits, he gives them a Lucky Cog he found in the smelting waste. Accessory: +luck.
- Central Smelting Complex rim: A narrow walkway along the pit edge (requires heat-resistant gear) leads to a chest with the Caldera Ember (unique fire-element weapon upgrade).

**Environmental Storytelling:**
- The tier system makes class visible. Walking from the Upper Rim to the Lower District, buildings shrink, windows disappear, the air changes color (palette shift from warm amber to hot red-orange to oppressive brown).
- Workers in the Lower District have trembling sprite animations (2-frame shake cycle). This gets worse in the Interlude.
- Kel's dialogue -- "Is it true the sky is blue everywhere?" -- plays when the player speaks to him. The forge-smoke above the Lower District is orange, never blue.
- The Terrace Garden is the only green space. In Act II, it is maintained but small. In the Interlude, the plants are wilting. In the epilogue, new growth appears.

**Secret Areas:**
- **Undercity:** Accessible via hidden stairway in Housing Block B (examine the back wall). The undercity is a network of abandoned forge-channels and maintenance tunnels. Contains Tash's market, Sera's HQ, and Lira's workshop.
- **Forge Channel Passage:** Connects the undercity to the Lower District via a crawlspace behind Forge Hall D. Used by the resistance for smuggling.
- **Mira's Studio:** Hidden room behind a false map wall in the undercity. Requires Mira's trust (side quest completion) to access. Contains the complete ley line map -- shows the Convergence drain pattern.

### Act-by-Act Changes

**Act II (optional visit):**
- All three tiers accessible. Undercity requires finding the hidden entrance.
- The forges run at full capacity. The air is hot and thick.
- Side quests available: "The Fading Shifts" (Dael Corran), "The Forgewright's Gambit" (Cira)
- Kel is at his bellows station, cheerful and ignorant of his exploitation

**Interlude (major hub -- "Finding Lira" sequence):**
- Forge Hall D has an explosion scar (blocked path, rubble in street)
- Resistance barricades in undercity (new barrier tiles, faction markers)
- Lira's Workshop becomes accessible (crafting bench, save point, story scenes)
- The fading is accelerating -- more workers with trembling animations, some standing motionless
- Forge-glow alternates between amber and grey-white (Pallor energy bleeding in)
- Multiple side quests: "The Auditor's Conscience," "The Honest Thief," "Unbowed," "Stars and Gears," "The Cartographer's Last Map"
- Kel reports that his friend Brill "hasn't talked in three days"

**Act III (passage through):**
- Forges running erratically -- some at full blast, others dark
- Guild has fractured -- different factory halls fly different guild faction flags
- Resistance operates openly in the Lower District
- Brief stop; the party is moving toward the Convergence

**Epilogue:**
- Forges restart on stabilized energy at reduced capacity (deliberately)
- Sera Linn sits on the new workers' council
- Kel works above ground for the first time -- a cutscene shows him seeing the actual sky
- Green shoots in the Lower District cracks
- Academy teaches ley-line integration alongside Forgewright craft
- Resistance barricades replaced by open doorways

---

## 3. Ashmark

### City Overview

**Size:** Medium city -- approximately 128x140 tiles (6-8 screens)
**Screens:** 8 explorable areas
**Layout:** Ashmark sprawls across a blackite plain -- rock scorched dark by centuries of forge-work. The city is organized around the Black Forges, a row of massive multi-story foundries that dominate the center. Conveyor belts cross between buildings at upper levels. Worker housing flanks the forges on both sides, identical rows of brick tenements. The Founders' Hall stands apart at the city's north end, older and grander. The rail station connects to Corrund and Caldera.
**Entry/exit points:** West Road (from overworld), East Road (to Millhaven), Rail Station (north, to Corrund/Caldera).

```
ASHMARK -- The Factory City
(128 tiles wide x 140 tiles tall, ~8 screens)

KEY:  ### = conveyor bridge   ~~~ = cooling canal   === = rail line
      [...] = building        |X| = chimney stack

                     N (to Rail Station)
    ___________________________________________________
   |  === RAIL STATION ===    [Founders'    ][Prayer  ]|
   |  [(to Corrund,           [Hall         ][Wheel   ]|
   |   Caldera)   ]           [(museum,     ][Garden  ]|
   |                          [ original    ][        ]|
   |                          [ anvil)      ][        ]|
   |                                                   |
   |  [Forge-Masters']  [Public    ]   [Ashmark    ]   |
   |  [Guild HQ      ]  [Square   ]   [General    ]   |
   |  [(political    ]  [(notice  ]   [Store      ]   |
   |  [ center)      ]  [ board)  ]   [           ]   |
   |                                                   |
   |  <<< WEST ROAD          EAST ROAD >>>             |
   |                                                   |
   |  WORKER HOUSING     THE BLACK FORGES     WORKER   |
   |  (west rows)        (central)            HOUSING  |
   |                                          (east)   |
   |  [Tenement][Tene-]  [BLACK   ]|X||X|  [Tene- ]   |
   |  [Row 1   ][ment ]  [FORGE A ]|X||X|  [ment  ]   |
   |  [        ][Row 2]  [(open   ]|X||X|  [Row 5 ]   |
   |  [        ][     ]  [ furnace]        [      ]   |
   |  [        ][     ]  [ mouths)]        [      ]   |
   |           ###########         ###########         |
   |  [Tenement][Tene-]  [BLACK   ]|X||X|  [Tene- ]   |
   |  [Row 3   ][ment ]  [FORGE B ]|X||X|  [ment  ]   |
   |  [(Lira's ][Row 4]  [(the    ]|X||X|  [Row 6 ]   |
   |  [ old    ][     ]  [ largest]        [      ]   |
   |  [ room)  ][     ]  [ forge) ]        [      ]   |
   |           ###########         ###########         |
   |                      [BLACK   ]|X||X|             |
   |  [Worker's ][Cheap ]  [FORGE C ]|X||X|  [Shift  ]|
   |  [Mess     ][Tavern]  [(damaged]        [Fore-  ]|
   |  [Hall     ]["The  ]  [ in Int-]        [man's  ]|
   |  [         ][ Soot"]  [ erlude)]        [Office ]|
   |                                                   |
   |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  cooling canal   |
   |                                                   |
   |  [Rail Siding  ]  [Coal      ]   [Ashmark   ]    |
   |  [(cargo       ]  [Yard      ]   [Infirmary ]    |
   |  [ loading)    ]  [          ]   [(treat     ]    |
   |  [             ]  [          ]   [ fading)   ]    |
   |___________________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Rail Station | Transit | North | Rail Conductor | Fast travel (Corrund, Caldera, Kettleworks) | 100g per trip per [transport.md](transport.md); erratic in Interlude |
| 2 | Founders' Hall | Museum | North | Curator NPC | Lore | Original Forgewright anvil; mechanical prayer wheels |
| 3 | Prayer Wheel Garden | Shrine | North | Devotees | -- | Mechanical prayer wheels; some stopped in Interlude |
| 4 | Forge-Masters' Guild HQ | Government | Central north | Guild officials | -- | Political center; controls employment and housing |
| 5 | Public Square | Plaza | Central north | Various NPCs | Notice board (quests) | Gathering area; propaganda posters |
| 6 | Ashmark General Store | Commerce | Central north | Shopkeeper | General goods | Standard Compact fare |
| 7 | Tenement Rows 1-6 | Housing | West/East flanks | Workers, families | -- | 6 identical rows; fading symptoms worsen south |
| 8 | Lira's Old Room | Residence | Tenement Row 3 | -- | -- | Optional: letters Lira left behind |
| 9 | Black Forge A | Factory | Central | Foreman, workers | -- | Open furnace mouths visible from the street |
| 10 | Black Forge B | Factory | Central | Senior foreman | -- | Largest forge; environmental hazard dungeon section |
| 11 | Black Forge C | Factory | Central south | -- | -- | Explosion scar in Interlude |
| 12 | Worker's Mess Hall | Service | Southwest | Cook | Cheap food (HP restore) | Workers eat in shifts |
| 13 | The Soot (tavern) | Tavern | Southwest | Barkeep, workers | Drinks, rumors | Only social space for workers |
| 14 | Shift Foreman's Office | Authority | Southeast | Foreman NPC | -- | Employment records; blacklist evidence |
| 15 | Rail Siding | Utility | South | -- | -- | Cargo loading; derailed cart in Interlude |
| 16 | Coal Yard | Utility | South | -- | -- | Environmental detail |
| 17 | Ashmark Infirmary | Service | South | Healer NPC | Heal, cure status | Treats fading symptoms (temporarily) |

### Shop Inventories

**Ashmark General Store**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Forgewright Hammer | Weapon | 1400 | Yes | Yes | Heavy, forge-built |
| Soot-Hardened Mail | Armor | 1200 | Yes | Yes | Blackite-treated iron |
| Ash Mask | Accessory | 400 | Yes | Yes | Reduces smoke hazard damage |
| Potion | Consumable | 50 | Yes | Yes | Restore 100 HP |
| Antidote | Consumable | 50 | Yes | Yes | Cure Poison |
| Ley-Lantern | Consumable | 60 | Yes | Yes | Light source |
| Blackite Gauntlet | Armor | 800 | No | Yes | Interlude stock; +fire resist |

**The Soot (tavern -- under the counter)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Bootleg Tonic | Consumable | 80 | Yes | Yes | HP restore, slight random effect |
| Worker's Manifesto | Key item | 200 | No | Yes | Dael's writings; side quest trigger |
| Blacklist Record | Key item | 500 | No | Yes | Exposes Guild corruption |
| Smoke Bomb | Consumable | 120 | Yes | Yes | Guaranteed battle escape |

### Points of Interest

**Save Points:**
- Founders' Hall (interior, near the original anvil)
- Black Forge B entrance (before dungeon hazard section)

**Hidden Treasures:**
- Lira's Old Room: Examine the desk to find hidden letters. Contains the Forge Apprentice's Ring (accessory: +crafting quality when Lira is in party).
- Black Forge B upper level: A chest on a catwalk over the molten metal. Contains the Emberstone (unique fire-element crafting material).
- Coal Yard: Behind stacked coal crates, a passage leads to a hidden maintenance tunnel with a chest containing 1,200 gold and a Compact military cipher.
- Prayer Wheel Garden: If all functioning prayer wheels are activated in sequence, a compartment opens in the central pedestal. Contains the Forgewright's Creed (lore document + minor stat boost).

**Environmental Storytelling:**
- The Black Forge furnace mouths glow red-orange with a 4-frame breathing animation cycle. The forges are alive.
- Conveyor bridges between forges carry glowing ingots (animated sprites). In the Interlude, the conveyors stop and restart erratically.
- The cooling canal water steams constantly. In the Interlude, the steam has a grey tinge.
- Workers in the southern tenements are progressively worse off -- Tenement Row 6 NPCs have trembling sprites and shortened dialogue.
- The Infirmary healer's dialogue shifts: Act II -- "The tremors respond to treatment." Interlude -- "I don't know what to call this anymore."

### Act-by-Act Changes

**Act II (referenced in Lira's backstory; visitable):**
- City at full industrial capacity
- Lira's old room available for backstory content
- Forge-Masters' Guild controls everything; workers complain quietly
- The fading is present but manageable

**Interlude (Sable and Lira pass through):**
- Black Forge C has an explosion scar (wall blown outward, debris in street, wild energy glow inside)
- Rail siding has a derailed cart (new rubble tiles on platform)
- Scaffolding on the Founders' Hall (surge damage)
- Forge-smoke is paler -- less orange, more grey
- Arcanite glow in machinery flickers between blue-white and grey
- More workers showing fading symptoms
- Guild in crisis mode, blaming sabotage
- Rail to Corrund unreliable

---

## 4. Bellhaven

### City Overview

**Size:** Medium-large city -- approximately 160x154 tiles (8-10 screens)
**Screens:** 10 explorable areas
**Layout:** Bellhaven is built on a coastal slope descending to the harbor. The Merchant Prince manor district occupies the high ground with stone and brick buildings. Below, the market quarter is a mix of Carradan industrial architecture and cosmopolitan trade stalls. The Stilts district -- entire neighborhoods raised on wooden pilings over tidal flats -- extends into the harbor. The dockside area handles the ironclad barges and submersible rigs. The Breakwater fortification guards the harbor mouth.
**Entry/exit points:** North Road (from overworld, Corrund direction), Harbor (by ship), West Coast Path (to Ashport), The Breakwater (harbor mouth, Act II set piece if approaching by sea).

```
BELLHAVEN -- The Port City
(160 tiles wide x 154 tiles tall, ~10 screens)

KEY:  ~~~ = ocean/tidal water   === = dock/pier   ### = walkway
      [...] = building          ^^^ = seawall     |~| = stilt

               N (road from overworld)
    ___________________________________________________________
   |  >>> NORTH ROAD GATE >>>                                  |
   |                                                           |
   |  MERCHANT PRINCE DISTRICT (high ground)                   |
   |                                                           |
   |  [Prince     ][Prince     ]  [Bellhaven  ][Customs    ]  |
   |  [Aldara's   ][Venn's     ]  [City Hall  ][House      ]  |
   |  [Manor      ][Manor      ]  [           ][           ]  |
   |                                                           |
   |  [Jeweler   ][Import     ]  [The        ][Cartographer]  |
   |  [(gems,    ][House      ]  [Seabird    ][& Charts    ]  |
   |  [ rare     ][(exotic    ]  [Inn        ][           ]  |
   |  [ access.) ][ goods)    ]  [(save pt)  ][           ]  |
   |                                                           |
   |  MARKET QUARTER (mid-slope)                               |
   |                                                           |
   |  [Fish      ][Spice     ][Rope &    ][Sail       ]       |
   |  [Market    ][Trader    ][Canvas    ][Maker      ]       |
   |  [          ][          ][          ][           ]       |
   |                                                           |
   |  [Sailor's  ][Money     ][Compact   ][Mercenary  ]       |
   |  [Outfitter ][Changer   ][Recruiting][Guild      ]       |
   |  [(weapons, ][          ][Office    ][Hall       ]       |
   |  [ armor)   ][          ][          ][           ]       |
   |                                                           |
   |  ^^^^^^^^^^^^ SEAWALL / HARBOR EDGE ^^^^^^^^^^^^^^^^^^^^  |
   |                                                           |
   |  STILTS DISTRICT (over tidal flats)                       |
   |                                                           |
   |  |~|[Stilt   ]|~|[Stilt   ]|~|[Stilt   ]|~|             |
   |  |~|[House A ]|~|[House B ]|~|[House C ]|~|             |
   |  |~|###########|~|###########|~|###########|~|           |
   |  |~|[Sable's  ]|~|[The     ]|~|[Salvage ]|~|            |
   |  |~|[Childhood]|~|[Anchor  ]|~|[& Scrap ]|~|            |
   |  |~|[Home     ]|~|[Tavern  ]|~|[Shop    ]|~|            |
   |  |~|###########|~|###########|~|###########|~|           |
   |  |~|[Net      ]|~|[Stilt   ]|~|[Tide    ]|~|            |
   |  |~|[Mender   ]|~|[House D ]|~|[Watch   ]|~|            |
   |  |~|          |~|          |~|[(lookout)]|~|             |
   |                                                           |
   |  ~~~ TIDAL FLATS (water at high tide) ~~~                 |
   |                                                           |
   |  DOCKSIDE                                                 |
   |                                                           |
   |  ===[Ironclad ]===[Barge    ]===[Submersible]===[Ferry  ]  |
   |  ===[Berth A  ]===[Berth B  ]===[Dock       ]===[Dock   ]  |
   |  ===[         ]===[         ]===[           ]===[       ]  |
   |                                                           |
   |  [Warehouse ][Warehouse ][Harbormaster's][Crane    ]      |
   |  [1         ][2         ][Office        ][Platform ]      |
   |                                                           |
   |  ^^^ BREAKWATER (fortified seawall, lighthouse) ^^^       |
   |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      |
   |                    OPEN OCEAN                             |
   |___________________________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Prince Aldara's Manor | Residence | Merchant Prince District | Prince Aldara, servants | -- | Merchant prince; ley-crystal extraction rights |
| 2 | Prince Venn's Manor | Residence | Merchant Prince District | Prince Venn, guards | -- | Rival merchant prince; optional quest |
| 3 | Bellhaven City Hall | Government | Merchant Prince District | Officials | -- | Administrative center |
| 4 | Customs House | Government | Merchant Prince District | Customs officer | -- | Checks cargo manifests; bribable |
| 5 | Jeweler | Commerce | Merchant Prince District | Jeweler NPC | Accessories (premium) | Rare gems, imported Valdris pieces |
| 6 | Import House | Commerce | Merchant Prince District | Exotic goods dealer | Rare items from foreign nations | Cosmopolitan stock |
| 7 | The Seabird Inn | Inn | Merchant Prince District | Innkeeper | Save point, rest | Upscale inn |
| 8 | Cartographer & Charts | Service | Merchant Prince District | Cartographer NPC | Maps, sea charts | Navigation lore |
| 9 | Fish Market | Commerce | Market Quarter | Fishmongers | Consumables (food) | Cheap HP restores |
| 10 | Spice Trader | Commerce | Market Quarter | Spice merchant | Consumables (buffs) | Temporary stat boosts |
| 11 | Rope & Canvas | Commerce | Market Quarter | Sailmaker | -- | Flavor |
| 12 | Sailmaker | Commerce | Market Quarter | Sailmaker NPC | -- | Flavor; repairs sails for a quest |
| 13 | Sailor's Outfitter | Commerce | Market Quarter | Outfitter NPC | Weapons, armor (nautical) | Cutlasses, sea-hardened gear |
| 14 | Money Changer | Service | Market Quarter | Money changer NPC | Currency exchange | Better rates than Corrund |
| 15 | Compact Recruiting Office | Military | Market Quarter | Recruiter NPC | -- | Propaganda; environmental storytelling |
| 16 | Mercenary Guild Hall | Guild | Market Quarter | Guild captain | Hire mercenaries (side quest) | Optional combat assistance |
| 17 | Stilt Houses A-D | Housing | Stilts District | Stilts residents | -- | Improvised driftwood construction |
| 18 | Sable's Childhood Home | Residence | Stilts District | -- (abandoned) | -- | Character backstory; examine objects for memories |
| 19 | The Anchor Tavern | Tavern | Stilts District | Barkeep, sailors | Drinks, rumors, informants | Sable's old haunt; intelligence source |
| 20 | Salvage & Scrap Shop | Commerce | Stilts District | Scavenger NPC | Cheap gear, parts | Low-end but occasionally unique finds |
| 21 | Net Mender | Service | Stilts District | Net mender NPC | -- | Flavor |
| 22 | Tide Watch | Lookout | Stilts District | Watchman NPC | -- | Overlooks the harbor; reports ship activity |
| 23 | Ironclad Berth A | Dock | Dockside | Dock workers | -- | Military vessel docked |
| 24 | Barge Berth B | Dock | Dockside | Dock workers | -- | Trade barge |
| 25 | Submersible Dock | Dock | Dockside | Engineers, divers | -- | Rig operations; Pallor-affected crews in Interlude |
| 26 | Warehouses 1-2 | Storage | Dockside | -- | -- | Trade goods; Warehouse 2 lootable in Interlude |
| 27 | Harbormaster's Office | Government | Dockside | Harbormaster NPC | -- | Ship schedules, cargo manifests |
| 28 | Breakwater / Lighthouse | Fortification | Harbor mouth | Garrison soldiers | -- | Act II set piece; lighthouse as landmark |
| 29 | Ferry Dock | Transit | Dockside | Ferryman | Fast travel (Ashport) | 200g per crossing per [transport.md](transport.md); unavailable in Interlude |

### Shop Inventories

**Sailor's Outfitter (Market Quarter)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Sea-Steel Cutlass | Weapon | 1400 | Yes | Yes | Salt-resistant blade |
| Stormhide Vest | Armor | 1200 | Yes | Yes | Water-resistant leather |
| Sailor's Charm | Accessory | 500 | Yes | Yes | +evasion at sea |
| Grappling Line | Tool | 200 | Yes | Yes | Traversal item |
| Diving Mask | Accessory | 800 | No | Yes | Required for Sunken Rig dungeon |
| Tide-Forged Spear | Weapon | 2400 | No | Yes | Edren-appropriate |

**Import House (Merchant Prince District)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Valdris Moonblade | Weapon | 3600 | Yes | No | Imported; ley-touched |
| Foreign Silk Robe | Armor | 2000 | Yes | Yes | +magic resist |
| Spirit Pearl | Accessory | 2400 | Yes | No | +MP regen; Wilds origin |
| Thornmere Extract | Consumable | 500 | Yes | Yes | Full MP restore |
| Exotic Spice Set | Consumable | 300 | Yes | No | +all stats, 1 battle |

**Salvage & Scrap Shop (Stilts District)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Patched Mail | Armor | 400 | Yes | Yes | Cheap but functional |
| Rusted Blade | Weapon | 200 | Yes | Yes | Low ATK but available early |
| Scrap Shield | Armor | 300 | Yes | Yes | Driftwood and metal |
| Barnacle Charm | Accessory | 150 | Yes | Yes | +DEF, -SPD |
| Salvaged Arcanite Shard | Material | 250 | No | Yes | Crafting component |
| Rig Crew Manifest | Key item | 400 | No | Yes | Side quest: missing crew |

### Points of Interest

**Save Points:**
- The Seabird Inn (Merchant Prince District)
- The Anchor Tavern basement (Stilts District, hidden -- requires Sable)

**Hidden Treasures:**
- Sable's Childhood Home: Examining the floorboards reveals a hidden compartment with Sable's First Lockpick (accessory: +lockpicking, character story item).
- Warehouse 2: In the Interlude, the lock is broken. Inside: trade goods, and behind stacked crates, a chest with a Merchant Prince's Signet Ring (key item for Prince Venn side quest).
- Breakwater Lighthouse: Climb to the top for a panoramic view. In the Interlude, examine the signal apparatus to find the Harbor Signal Cipher (key item: decodes Compact naval communications).
- Tidal Flats: At low tide, a passage beneath the Stilts district becomes accessible. A small cave contains a chest with the Tidecaller's Horn (unique item: summons a water elemental once per battle).

**Environmental Storytelling:**
- The Stilts district walkways creak (audio cue). Gaps between planks show tidal water below. At high tide, the lowest walkways are submerged (palette change -- water tiles replace walkway).
- Foreign merchants in the Market Quarter speak in different text colors (representing accents/languages). In the Interlude, fewer foreign merchants remain.
- The Submersible Dock has crews maintaining rigs. In the Interlude, one rig sits dark at anchor -- its crew found in a Pallor state.
- Sable's dialogue changes throughout Bellhaven. She is more confident, more bitter, and knows shortcuts the player cannot discover otherwise.

### Act-by-Act Changes

**Act II (possible entry point to Compact territory):**
- Full harbor operations; ironclad barges and submersible rigs active
- Market Quarter bustling with foreign merchants
- Merchant princes competing for extraction rights
- Sable's childhood neighborhood is a character story beat
- The Breakwater is intact; if approaching by sea, it is the Act II set piece

**Interlude:**
- Several submersible rigs surfaced unmanned; one drifts dark offshore
- One section of Stilts district collapsed into the water (gap bridged with planks and rope)
- Merchant stalls half-empty; Compact naval vessels recalled to Corrund
- Tide marks higher than normal; gull calls less frequent
- Sable's childhood neighborhood has a boarded-up shop
- Sunken Rig optional dungeon becomes accessible
- Grey things washing against the Breakwater

---

## 5. Millhaven

### City Overview

**Size:** Small town -- approximately 64x56 tiles (3-4 screens)
**Screens:** 4 explorable areas
**Layout:** Millhaven is a ring of prefabricated buildings surrounding the Millglow pit -- an open ley-line extraction site. Everything radiates outward from the pit's edge. Worker barracks in rows, a refinery complex with valves and pressure systems, pumping stations, and a single company store. The town has no culture, no gathering spaces, no green. It exists to extract.
**Entry/exit points:** North Road (from overworld), South Road (toward Caldera/Corrund), Millglow Pit (leads to Ley Line Depths optional dungeon).

```
MILLHAVEN -- The Extraction Town
(64 tiles wide x 56 tiles tall, ~4 screens)

KEY:  ooo = Millglow pit (glowing)   |P| = pumping station
      [...] = building               === = pipeline

           N (road from overworld)
    ___________________________________________
   |  >>> NORTH ROAD >>>                       |
   |                                           |
   |  [Worker   ][Worker   ][Worker   ]        |
   |  [Barracks ][Barracks ][Barracks ]        |
   |  [A        ][B        ][C        ]        |
   |                                           |
   |  [Company  ][Foreman's]  [Infirmary]      |
   |  [Store    ][Office   ]  [(minimal)]      |
   |  [(inflated][         ]  [         ]      |
   |  [ prices) ][         ]  [         ]      |
   |                                           |
   |  |P|=====[REFINERY      ]=====|P|         |
   |  |P|     [COMPLEX       ]     |P|         |
   |  |P|     [(valves,      ]     |P|         |
   |          [ pressure,    ]                 |
   |          [ steam puzzles]                 |
   |                                           |
   |       ooooooooooooooooooo                 |
   |      oo  MILLGLOW PIT   oo                |
   |     oo  (open extraction oo               |
   |     oo   site, blue-white oo              |
   |     oo   glow, entrance   oo              |
   |      oo  to Ley Line     oo               |
   |       oo  Depths)       oo                |
   |        ooooooooooooooooo                  |
   |                                           |
   |  >>> SOUTH ROAD (to Caldera) >>>          |
   |___________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Worker Barracks A-C | Housing | North | Workers | -- | 3 identical buildings; workers with tremors |
| 2 | Company Store | Commerce | Central north | Company clerk | General goods (inflated prices) | Deliberate design: exploitation made economic |
| 3 | Foreman's Office | Authority | Central north | Foreman NPC | -- | Answers to Consortium, not locals |
| 4 | Infirmary | Service | Central north | Medic NPC | Basic healing | Under-equipped; treats symptoms not causes |
| 5 | Refinery Complex | Utility/Puzzle | Central | Refinery workers | -- | Environmental puzzle: valves, pressure, steam |
| 6 | Pumping Stations (x4) | Utility | Around refinery | -- | -- | Animated pumping machinery |
| 7 | Millglow Pit | Dungeon entrance | Center-south | -- | -- | Leads to Ley Line Depths dungeon |

### Shop Inventories

**Company Store**

| Item | Type | Price (gold) | Notes |
|------|------|---------------|-------|
| Potion | Consumable | 100 | **Double normal price** -- company markup |
| Extraction Mask | Accessory | 600 | Reduces ley-exposure damage; workers cannot afford this |
| Tremor Tonic | Consumable | 200 | Temporarily stops tremors; does not cure |
| Repair Kit | Material | 150 | Equipment maintenance |
| Pickaxe | Weapon | 400 | Worker's tool, low ATK |
| Work Lamp | Tool | 250 | Required for Ley Line Depths |
| Ley-Shielded Gloves | Accessory | 800 | +resist ley exposure; management price |

The Company Store's prices are deliberately inflated to 1.5-2x the normal rate. This is a design choice, not a balance issue. The player should feel the exploitation. If they visit a normal Compact city afterward, the price difference is the story.

### Points of Interest

**Save Points:**
- Foreman's Office (the only save point -- fitting for a town with no amenities)

**Hidden Treasures:**
- Worker Barracks B: Under a loose floorboard, a worker's diary. Reading it reveals the Millglow Pendant hidden in the refinery (accessory: +ley resist, grants vision in ley-lit areas).
- Refinery Complex: Behind the main valve assembly, a maintenance hatch leads to a small room. Contains a chest with a Refined Ley Crystal (unique crafting material, very valuable).
- Pit Edge: Walking the full perimeter of the Millglow pit, there is one spot where the railing is broken. Examining it triggers dialogue about a worker who fell. Below the gap, on a ledge visible but not reachable: a chest that can only be obtained from the Ley Line Depths side.

**Environmental Storytelling:**
- Workers' hands tremble (2-frame sprite animation). This is the fading's physical form before anyone names it.
- The Millglow pit glows sickly blue-white at night. The glow reflects off the permanent smog, creating an eerie halo. Approaching the pit edge triggers screen-edge distortion.
- The Foreman's Office has charts showing extraction yields. The numbers go up every quarter. The worker injury reports, pinned below, also go up every quarter.
- The Infirmary medic has a limited supply cabinet. If the player examines it: "Three bottles of tremor tonic. That's it. They send me three a month for four hundred workers."

### Act-by-Act Changes

**Act II (diplomatic mission visit):**
- Town fully operational; the pit glows steadily
- Lira's resolve hardens visibly (dialogue changes)
- Optional side quest: sabotage the pumping station (moral choice -- helps ley lines but endangers workers)
- Workers describe the fading in clinical detail

**Interlude:**
- **Destroyed.** The ley lines destabilized and the pit erupted.
- Millhaven is a crater visible on the overworld map
- No interior map -- overworld-only approach shows: crater edge, twisted metal wreckage, faint grey glow from exposed ley lines deep below
- The Company Store sign lies half-buried in dirt
- No NPCs. No buildings. The town is simply not there anymore.

---

## 6. Ashport

### City Overview

**Size:** Medium city -- approximately 96x112 tiles (5-6 screens)
**Screens:** 6 explorable areas
**Layout:** Ashport is a rough coastal trade city divided between the military harbor (ironclad berths, weapons testing infrastructure) and the civilian strip (taverns, traders, mercenary housing). The harbor dominates the east side. The merchant quarter, newer and built with Arcanite-forged stone, sits on higher ground to the west. The arms testing ranges extend beyond the harbor on breakwater platforms.
**Entry/exit points:** West Road (from overworld), Harbor (by ship), Coastal Path (north, to Bellhaven).

```
ASHPORT -- The Arms Port
(96 tiles wide x 112 tiles tall, ~6 screens)

KEY:  ~~~ = ocean   === = dock/pier   ### = breakwater
      [...] = building   |*| = weapons test flash

           W (road from overworld)
    ___________________________________________________
   |  <<< WEST ROAD                                   |
   |                                                   |
   |  MERCHANT QUARTER (high ground, Arcanite stone)   |
   |                                                   |
   |  [Nara Voss's][Holt Varen's]  [Ashport    ]      |
   |  [Textile    ][Weapons    ]  [Inn         ]      |
   |  [Shop       ][Export     ]  [(save pt)   ]      |
   |  [           ][Office     ]  [            ]      |
   |                                                   |
   |  [Arms      ][Shipwright ][Courier     ]          |
   |  [Dealer    ][Office     ][Office      ]          |
   |  [(mid-tier ][           ][            ]          |
   |  [ weapons) ][           ][            ]          |
   |                                                   |
   |  CIVILIAN STRIP (harbor-adjacent)                 |
   |                                                   |
   |  [The       ][The       ][Pell's      ][Bait    ]|
   |  [Powder    ][Grog &    ][Boarding    ][& Tackle]|
   |  [Keg       ][Gear      ][House      ][Shop    ]|
   |  [(tavern)  ][(tavern)  ][(cheap inn) ][        ]|
   |                                                   |
   |  ^^^^^^^^^^^ HARBOR WALL ^^^^^^^^^^^^^^^^^^^^^^^^ |
   |                                                   |
   |  MILITARY HARBOR                                  |
   |                                                   |
   |  ===[Ironclad   ]===[Weapons    ]===[Munitions ]  |
   |  ===[Dock A     ]===[Barge Dock ]===[Warehouse ]  |
   |  ===[           ]===[           ]===[          ]  |
   |                                                   |
   |  [Dock       ][Harbor      ]                      |
   |  [Workers'   ][Command     ]                      |
   |  [Shed       ][Post        ]                      |
   |                                                   |
   |  ~~~ HARBOR ~~~  ###[TESTING    ]### ~~~ OCEAN ~~~|
   |                  ###[RANGE      ]###              |
   |                  ###[(distant   ]###              |
   |                  ###[ flashes)  ]### |*| |*|      |
   |___________________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Nara Voss's Textile Shop | Commerce | Merchant Quarter | Nara Voss | Textiles, light armor | Pleasant, normal; wool in Interlude |
| 2 | Holt Varen's Weapons Export Office | Commerce | Merchant Quarter | Holt Varen | Weapons (export-grade) | Cheerful amorality |
| 3 | Ashport Inn | Inn | Merchant Quarter | Innkeeper | Save point, rest | Primary save |
| 4 | Arms Dealer | Commerce | Merchant Quarter | Arms dealer NPC | Weapons (mid-tier) | Standard Compact arms |
| 5 | Shipwright Office | Service | Merchant Quarter | Shipwright NPC | -- | Flavor; ship repair schedules |
| 6 | Courier Office | Service | Merchant Quarter | Courier NPC | -- | Flavor |
| 7 | The Powder Keg | Tavern | Civilian Strip | Barkeep, soldiers | Drinks, rumors | Military clientele |
| 8 | The Grog & Gear | Tavern | Civilian Strip | Barkeep, mercenaries | Drinks, side quest | Mercenary hangout |
| 9 | Pell's Boarding House | Inn | Civilian Strip | Pell, boarders | Cheap rest | Pell lives here; character dialogue |
| 10 | Bait & Tackle Shop | Commerce | Civilian Strip | Shopkeeper | Fishing supplies, consumables | Also sells basic provisions |
| 11 | Ironclad Dock A | Military | Military Harbor | Soldiers, engineers | -- | Military vessel; restricted |
| 12 | Weapons Barge Dock | Military | Military Harbor | Dock workers | -- | Arms shipments |
| 13 | Munitions Warehouse | Military | Military Harbor | Guards | -- | Locked; side quest involves it |
| 14 | Dock Workers' Shed | Service | Military Harbor | Dock workers (including Pell) | -- | Pell's workplace |
| 15 | Harbor Command Post | Military | Military Harbor | Harbor commander | -- | Military authority |
| 16 | Testing Range | Military | Breakwater | -- | -- | Not enterable; distant flashes and rumbles |

### Shop Inventories

**Holt Varen's Weapons Export**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Arcanite Longblade | Weapon | 2000 | Yes | Yes | Export quality, polished |
| Compact Officer's Saber | Weapon | 2800 | Yes | No | Military grade; limited stock |
| Arcanite Crossbow | Weapon | 2200 | Yes | Yes | Ranged; Forgewright mechanism |
| Export Shield (gilded) | Armor | 1800 | Yes | No | Decorative but functional |
| Salvage Blade | Weapon | 800 | No | Yes | Holt's pivot to salvage |
| Reclaimed Plate | Armor | 1200 | No | Yes | Refurbished military surplus |

**Arms Dealer (Merchant Quarter)**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Forgewright Blade | Weapon | 1400 | Yes | Yes | Standard issue |
| Iron-Brass Shield | Armor | 1000 | Yes | Yes | Compact standard |
| Smoke Bomb | Consumable | 100 | Yes | Yes | Flee from non-boss battle |
| Chronos Dust | Consumable | 400 | Yes | Yes | Cure Slow, grant Haste (1 turn) |
| Ley-Lantern | Tool | 60 | Yes | No | Light source for dungeons |

### Points of Interest

**Save Points:**
- Ashport Inn (Merchant Quarter)
- The Grog & Gear basement (hidden save; requires mercenary guild membership)

**Hidden Treasures:**
- Munitions Warehouse: Side quest grants access. Inside: Military-Grade Arcanite Core (crafting material, highest purity) and the Export Manifest (key item: reveals Compact arms sales to foreign nations -- lore).
- Pell's Boarding House: Examine the window ledge in Pell's room to find a carved bone trinket (his wife's work). Key item: Bone Whistle (accessory: +evasion, Thornmere origin).
- Testing Range: Cannot enter, but examining the harbor wall near it at night reveals a loose brick. Behind it: 1,000 gold and a Prototype Arcanite Round (consumable: massive single-target damage, one use).

**Environmental Storytelling:**
- The testing range flashes are visible and audible from anywhere in the city. A periodic white flash on the horizon followed by a delayed rumble. In the Interlude, the flashes stop. The silence is conspicuous.
- Pell's dialogue about missing the Wilds while working the docks. His mother was a spirit-speaker. He hears cranes and loading bells instead of ley line songs.
- Arcanite-forged stone in the merchant quarter gleams when sunlight hits it. In the Interlude, the gleam is gone -- the stone looks like ordinary rock.
- The harbor wall separating the civilian strip from the military harbor has Compact propaganda posters. "Your work fuels victory." "Strength through industry."

### Act-by-Act Changes

**Acts I-II (optional visit):**
- Full harbor operations; weapons testing active
- Holt Varen sells export-grade weapons at premium prices
- Pell works the docks; Nara Voss sells silk
- The city is busy, transactional, functional

**Interlude:**
- Arms testing ranges silent (no discharge sounds)
- Several warehouse doors chained shut (businesses closed)
- A dock section has collapsed (poor maintenance)
- Maritime haze greyer; Arcanite stone lost its gleam
- Holt pivots to salvage; Nara sells wool
- Pell still on docks but work has dried up
- Fewer gulls

---

## 7. Ironmark Citadel

### City Overview

**Size:** Medium fortress -- approximately 96x112 tiles (5-6 screens)
**Screens:** 6 explorable areas (Interlude dungeon)
**Layout:** The Ironmark Citadel is a massive military fortification on a river bluff southeast of Corrund. Connected to the capital by a fortified road and underground tunnel (through the Axis Tower network). Concentric walls surround the inner keep. The outer ring houses garrison barracks and supply stores. The inner ring contains the command facilities and the lower cells. The Command Chamber at the center is Kole's seat of power.
**Entry/exit points:** Main Gate (fortified road from Corrund, sealed during Interlude), Rear Gate (Brant's betrayal point -- the infiltration entry), Tunnel Entrance (from Axis Tower underground -- primary Interlude access route).

```
IRONMARK CITADEL -- Military Headquarters
(96 tiles wide x 112 tiles tall, ~6 screens)

KEY:  ### = fortified wall (Arcanite-bonded iron)   >>> = gate
      [...] = building   ~~~ = river (Corrund River)

    ~~~~~~~~~~~~~~~~ CORRUND RIVER ~~~~~~~~~~~~~~~~
   |                                               |
   |  ### OUTER WALL (Arcanite-bonded iron) ###    |
   |  ###                                   ###    |
   |  ###  [Barracks  ][Barracks  ]         ###    |
   |  ###  [Block A   ][Block B   ]         ###    |
   |  ###  [(hollow-  ][(supply   ]         ###    |
   |  ###  [ eyed     ][ depot)   ]         ###    |
   |  ###  [ soldiers)]                     ###    |
   |  ###                                   ###    |
   |  ###  [Armory    ][Mess      ]         ###    |
   |  ###  [(Pallor-  ][Hall      ]         ###    |
   |  ###  [ charged  ][(grey     ]         ###    |
   |  ###  [ weapons) ][ rations) ]         ###    |
   |  ###                                   ###    |
   |  ###  >>> REAR GATE (Brant's entry) >>>###    |
   |  ###                                   ###    |
   |  ###  ### INNER WALL ###               ###    |
   |  ###  ###                              ###    |
   |  ###  ###  [Brant's     ][Officer's ]  ###    |
   |  ###  ###  [Quarters    ][Quarters  ]  ###    |
   |  ###  ###  [(bottles,   ][(vacant)  ]  ###    |
   |  ###  ###  [ drink stains)]          ]  ###    |
   |  ###  ###                              ###    |
   |  ###  ###  [COMMAND CHAMBER    ]       ###    |
   |  ###  ###  [(Kole's seat of    ]       ###    |
   |  ###  ###  [ power; Pallor     ]       ###    |
   |  ###  ###  [ energy arcing     ]       ###    |
   |  ###  ###  [ from walls to     ]       ###    |
   |  ###  ###  [ armor; boss arena)]       ###    |
   |  ###  ###                              ###    |
   |  ###  ###  [LOWER CELLS        ]       ###    |
   |  ###  ###  [(Ansa Veld and     ]       ###    |
   |  ###  ###  [ holdout soldiers; ]       ###    |
   |  ###  ###  [ 16 of original 30)]       ###    |
   |  ###  ###                              ###    |
   |  ###  ###  [Tunnel      ]              ###    |
   |  ###  ###  [Entrance    ]              ###    |
   |  ###  ###  [(to Axis    ]              ###    |
   |  ###  ###  [ Tower      ]              ###    |
   |  ###  ###  [ network)   ]              ###    |
   |  ###  ### ###############              ###    |
   |  ###                                   ###    |
   |  ### >>> MAIN GATE (sealed) >>>        ###    |
   |  #############################################|
   |                                               |
   |  === FORTIFIED ROAD (to Corrund) ===          |
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Barracks Block A | Military | Outer ring | Pallor-touched soldiers | -- | Hollow-eyed soldiers on patrol |
| 2 | Barracks Block B / Supply Depot | Military | Outer ring | Quartermaster (hollow) | Limited supplies | Military surplus; can loot after Kole's defeat |
| 3 | Armory | Military | Outer ring | -- | -- | Pallor-charged weapons on racks; some lootable |
| 4 | Mess Hall | Military | Outer ring | Soldiers | -- | Grey rations; no conversation at tables |
| 5 | Brant's Quarters | Residence | Inner ring | Commissar Brant | -- | Bottles, drink stains; the betrayal conversation |
| 6 | Officer's Quarters | Residence | Inner ring | -- | -- | Vacant; officers either Pallor-touched or fled |
| 7 | Command Chamber | Boss arena | Inner ring center | General Vassar Kole | -- | Pallor energy arcing; boss fight |
| 8 | Lower Cells | Prison | Inner ring | Ansa Veld, holdout soldiers | Intel about Kole's defenses | 16 of 30 original refusers remain |
| 9 | Tunnel Entrance | Passage | Inner ring | -- | -- | Connects to Axis Tower underground |

### Shop Inventories

No traditional shops. After defeating Kole, the following can be looted:

**Armory Salvage (post-boss)**

| Item | Type | Notes |
|------|------|-------|
| Ironmark Officer's Blade | Weapon | Kole's officers carried these; high ATK |
| Arcanite-Bonded Plate | Armor | Citadel standard; very high DEF |
| Pallor-Touched Gauntlet | Accessory | +ATK but Pallor status buildup; risky equip |
| Military Intelligence Cache | Key item | Map to Cael's location at the Convergence |
| Ironmark Key | Key item | Opens sealed areas in Corrund |

### Points of Interest

**Save Points:**
- Lower Cells (after freeing Ansa Veld)
- Before the Command Chamber door (pre-boss save)

**Hidden Treasures:**
- Brant's Quarters: Examine his desk to find a half-written resignation letter. Behind a loose wall panel: Brant's Service Medal (accessory: +DEF, comes with the weight of compromise).
- Armory: A locked cage in the back contains the Ironmark Lance (unique weapon: Edren-appropriate, highest ATK lance in the game). Requires Ironmark Key from Kole's body.
- Lower Cells: One cell has scratched tally marks on the wall -- counting days. Examining the tally triggers Ansa Veld's full testimony. In the corner: a hidden stone with a message from a soldier who gave in. Reading it grants the Resolve Charm (accessory: immunity to Pallor fear status).

**Environmental Storytelling:**
- Soldiers patrol with empty eyes. No idle animations. No incidental dialogue. They walk their routes and nothing else.
- The engine hum is a flat, sustained tone -- not the rhythmic clanging of normal Compact machinery. The sound design tells the player something is wrong before they see Kole.
- Brant's quarters are the only room with personal effects. Bottles, a half-eaten meal, a portrait face-down on the desk. He is the only person in the citadel who still feels.
- After Kole's defeat, the grey-blue glow drains from the walls. The iron returns to its normal dark color. Soldiers blink, confused. The engine hum stutters and dies. The silence that follows is the sound of freedom.

### Act-by-Act Changes

**Interlude (only visit):**
- Accessed through Axis Tower tunnel network
- Brant opens the rear gate (scripted event after speaking with him)
- Navigate outer ring (stealth optional -- Pallor soldiers have predictable patrol routes)
- Free Ansa Veld in the Lower Cells (provides intel for boss fight)
- Boss fight: General Vassar Kole in the Command Chamber
- After defeat: Pallor energy drains; the citadel is freed but spiritually damaged
- Recover the map to Cael's location at the Convergence

---

## 8. Ironmouth

### City Overview

**Size:** Small outpost -- approximately 48x42 tiles (2-3 screens)
**Screens:** 3 explorable areas
**Layout:** A cluster of prefabricated metal buildings at the southern edge of the Thornmere Wilds. A small Forgewright engine provides power. The mine entrance is punched into a hillside at the forest border. A squad of Compact soldiers provides security. The town is small, dirty, and utilitarian -- a stark contrast to the ancient mystery of the ruin beneath it.
**Entry/exit points:** North Path (into the Thornmere Wilds), Mine Entrance (leads to Ember Vein ruin), South Road (deeper into Compact territory, sealed after Act I).

```
IRONMOUTH -- Border Mining Outpost
(48 tiles wide x 42 tiles tall, ~3 screens)

KEY:  TTT = treeline (Thornmere Wilds)   [...] = building
      === = mine cart track               |E| = Forgewright engine

    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    TTTTTTTTT  (Thornmere Wilds - north)  TTTTTTTTTTT
    TTTTTT                                     TTTTTT
    TTT  >>> NORTH PATH (into the Wilds) >>>     TTT
    TTT                                          TTT
    TTT  [Carradan   ][Supply     ]   |E|        TTT
    TTT  [Barracks   ][Shed       ]   |E|        TTT
    TTT  [(lootable  ][(crates,   ]   (Forge-    TTT
    TTT  [ after     ][ early     ]    wright     TTT
    TTT  [ soldiers  ][ equip)    ]    engine)    TTT
    TTT  [ flee)     ][           ]              TTT
    TTT                                          TTT
    TTT  [Foreman's  ][Mess       ]              TTT
    TTT  [Cabin      ][Tent      ]              TTT
    TTT  [(reports,  ][(cook pot,]              TTT
    TTT  [ logs)     ][ benches) ]              TTT
    TTT                                          TTT
    TTT     ===[MINE ENTRANCE]=====              TTT
    TTT     ===(to Ember Vein)=====              TTT
    TTT     ===(first dungeon)=====              TTT
    TTT                                          TTT
    TTT  >>> SOUTH ROAD (to Compact territory) >>>TTT
    TTTTTT                                     TTTTTT
    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Carradan Barracks | Military | Northwest | Scared soldiers (Act I); empty later | Lootable after soldiers flee | First Compact military encounter |
| 2 | Supply Shed | Storage | North-central | -- | Early equipment, consumables | Forgewright supply crates (Compact insignia) |
| 3 | Forgewright Engine | Utility | Northeast | -- | -- | Provides power; silent in Interlude |
| 4 | Foreman's Cabin | Authority | Southwest | Foreman NPC (Act I) | -- | Mining reports, extraction logs |
| 5 | Mess Tent | Service | South-central | Cook (Act I) | Cheap food | Basic provisions |
| 6 | Mine Entrance | Dungeon access | South | -- | -- | Leads to Ember Vein ruin |

### Shop Inventories

No formal shops. The Supply Shed contains lootable crates:

**Supply Shed Crates (Act I)**

| Item | Type | Notes |
|------|------|-------|
| Iron Short Sword | Weapon | Basic starting upgrade |
| Compact Ration x3 | Consumable | HP restore |
| Repair Kit | Material | Equipment condition |
| Mining Lamp | Tool | Required for Ember Vein |
| Arcanite Flare x2 | Consumable | Lights dark areas for 30 seconds |
| Survey Tags | Key item | Lore: Compact mining claims on Wilds territory |

### Points of Interest

**Save Points:**
- Foreman's Cabin interior (the only save in the area)

**Hidden Treasures:**
- Barracks: After soldiers flee, examine the bunk in the back corner. Under the mattress: a soldier's journal describing increasingly aggressive wildlife and strange sounds from the mine. Key item: Miner's Compass (accessory: reveals hidden passages in the Ember Vein).
- Behind the Forgewright engine: A maintenance panel conceals a small cache. Contains Arcanite Spark (consumable: deals moderate lightning damage, single target) and 300 gold.
- Mine entrance exterior: Examine the survey markers on nearby trees. Lira identifies the dating system -- these claims were filed months before the expedition. The Compact knew something was here.

**Environmental Storytelling:**
- Mining markers nailed to trees at the town perimeter. Metal rectangles on living bark -- the visual tension between industrial and natural defines Ironmouth.
- The Wilds press in on every side. Trees are visible from every screen. The prefab buildings look fragile against the forest.
- Mixed lighting at the town perimeter: Compact Arcanite lamps (harsh white-blue) on the town side, forest bioluminescence (soft teal) on the other. Neither wins.

### Act-by-Act Changes

**Act I (first destination):**
- Soldiers scared, miners dead (referenced). Lira appears here.
- Carradan ambush forces the party to flee into the Wilds.
- Supply Shed and Barracks lootable after soldiers flee.

**Act II:**
- Compact-occupied and sealed. New iron plating on buildings, guard tower, supply wagons.
- Inaccessible to the player.

**Interlude:**
- Abandoned. Compact soldiers pulled back.
- Iron plating rusting (accelerated by Pallor influence).
- Mine seal cracked; grey air exhales from the entrance.
- Forest reclaiming the site -- vines on metal buildings, roots cracking foundations.
- The Forgewright engine is silent, core dark.

---

## 9. Gael's Span

### City Overview

**Size:** Small bridge-town -- approximately 64x42 tiles (2-3 screens)
**Screens:** 3 explorable areas (forest approach, bridge, industrial approach)
**Layout:** A massive ancient stone bridge crossing the Corrund River at its upper reach, where the Broken Hills meet the Thornmere Wilds. The bridge itself is wide enough for merchant caravans, predating both factions. A small settlement has grown on the bluff above: taverns, a provisioner, guard posts on both ends with different flags. The visual split is literal -- forest tiles on the north side, industrial tiles on the south.
**Entry/exit points:** North Path (into the Thornmere Wilds), South Road (into Carradan Compact territory).

```
GAEL'S SPAN -- The Border Bridge-Town
(64 tiles wide x 42 tiles tall, ~3 screens)

KEY:  TTT = forest (Thornmere)   ### = stone bridge
      ~~~ = Corrund River        [...] = building

    TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
    TTT                                              TTT
    TTT  WILDS SIDE (forest tiles, ranger patrols)   TTT
    TTT                                              TTT
    TTT  [Wilds Guard ][Ranger's  ]                  TTT
    TTT  [Post        ][Hut       ]                  TTT
    TTT  [(tribal     ][(herb     ]                  TTT
    TTT  [ flags)     ][ trader)  ]                  TTT
    TTT                                              TTT
    TTT  >>>>>>  NORTH BRIDGE APPROACH  >>>>>>       TTT
         ########################################
    ~~~  ##                                    ##  ~~~
    ~~~  ##    [Bridge        ][Bridge      ]   ##  ~~~
    ~~~  ##    [Provisioner   ][Tavern      ]   ##  ~~~
    ~~~  ##    [(limited      ]["The        ]   ##  ~~~
    ~~~  ##    [ stock)       ][ Span"      ]   ##  ~~~
    ~~~  ##                                    ##  ~~~
    ~~~  ##        --- MIDPOINT ---             ##  ~~~
    ~~~  ##    (natural daylight, neutral      ##  ~~~
    ~~~  ##     ground, brief visual clarity)  ##  ~~~
    ~~~  ##                                    ##  ~~~
         ########################################
         >>>>>>  SOUTH BRIDGE APPROACH  >>>>>>

         COMPACT SIDE (industrial tiles, soldiers)

         [Compact    ][Checkpoint  ]
         [Guard Post ][Shed        ]
         [(Compact   ][(papers     ]
         [ flags,    ][ checked)   ]
         [ weapon    ][            ]
         [ racks)    ][            ]

         >>> SOUTH ROAD (into Compact territory) >>>
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Wilds Guard Post | Military | North side | Rangers (2-3) | -- | Tribal flags, wooden construction |
| 2 | Ranger's Hut | Commerce | North side | Herb trader NPC | Herbs, potions (Wilds-style) | Thornmere remedies |
| 3 | Bridge Provisioner | Commerce | Bridge, west | Provisioner NPC | General goods (limited, border pricing) | Higher prices than normal |
| 4 | The Span (tavern) | Tavern | Bridge, east | Barkeep, traders | Drinks, rumors | Neutral ground; both factions drink here |
| 5 | Compact Guard Post | Military | South side | Compact soldiers (3-4) | -- | Compact flags, metal construction |
| 6 | Checkpoint Shed | Military | South side | Checkpoint officer | -- | Papers checked; bribable in Act II |

### Shop Inventories

**Bridge Provisioner**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Potion | Consumable | 60 | Yes | Yes | Border markup |
| Hi-Potion | Consumable | 360 | Yes | Yes | Restore 500 HP |
| Antidote | Consumable | 50 | Yes | Yes | Cures poison |
| Travel Rope | Tool | 100 | Yes | No | Traversal item |
| Iron Dagger | Weapon | 400 | Yes | No | Basic sidearm |

**Ranger's Hut**

| Item | Type | Price (gold/barter) | Act II | Interlude | Notes |
|------|------|----------------------|--------|-----------|-------|
| Thornmere Salve | Consumable | 80 | Yes | Yes | HP restore + poison cure |
| Spirit Ward (minor) | Accessory | 300 | Yes | No | +resist spirit damage |
| Wilds Herb Bundle | Consumable | 150 | Yes | Yes | +MP restore |
| Ranger's Cloak | Armor | 600 | Yes | No | +evasion in forest areas |

### Points of Interest

**Save Points:**
- The Span tavern interior (the only save point)

**Hidden Treasures:**
- Bridge midpoint: Examine the ancient stone railing at the exact center. An inscription in a language older than both factions is partially legible. Lira or Torren can translate fragments. Grants the Bridge Ward (accessory: +DEF on bridges and elevated terrain).
- Beneath the bridge: A narrow path along the river gorge wall leads to a shelf below the bridge arch. A chest contains the Gael's Token (key item: named for the explorer who built the bridge; lore + minor stat boost to the entire party).
- Compact Guard Post: Examine the weapons rack when the soldiers are distracted. A hidden compartment contains Compact Troop Movements (key item: intelligence about border deployment; useful in Act II diplomatic arc).

**Environmental Storytelling:**
- The bridge midpoint is the only place in the game where a player stands in natural daylight between two competing visual worlds. Forest biome tiles on one side, industrial tiles on the other. The midpoint tiles are neutral stone -- the bridge predates both factions.
- In Act II, trade caravans cross with escorts. In the Interlude, the bridge is empty except for the guard posts.
- The river below runs slower in the Interlude -- ley-line disruption affects the Corrund River upstream.
- Cracked stone tiles on the bridge in the Interlude -- new damage variant indicating ley-line instability stressing the ancient foundation.

### Act-by-Act Changes

**Act II (crossed during diplomatic mission):**
- Both guard posts active and staffed
- Trade caravans cross regularly
- The Span tavern is busy with travelers from both sides
- Checkpoint officer on the Compact side can be bribed or bypassed with papers
- Shopping available at normal border prices

**Interlude:**
- Compact guard post reinforced with Arcanite-bonded barricades
- Wilds-side guard post understaffed -- many rangers withdrawn deeper into the forest
- Bridge has cracked stone tiles and one collapsed railing section
- Trade has stopped; provisioner has limited stock at inflated prices
- Tavern half-empty
- The midpoint now feels like no-man's-land
- Passage still possible but tense -- requires papers or stealth

---

## 10. Kettleworks

### City Overview

**Size:** Small-medium campus -- approximately 80x70 tiles (4-5 screens)
**Screens:** 5 explorable areas
**Layout:** Kettleworks is the Compact's premier research campus, built on a line of quarried hills southeast of the Wilds border. Unlike the factory cities, this is clean and purposeful -- glass-roofed laboratories, precision workshops, prototype testing halls. The main laboratory dome (glass-and-brass hemisphere) is the campus centerpiece. Worker housing is modest but better maintained than Ashmark's or Caldera's tenements. A rail connection links to Corrund.
**Entry/exit points:** West Road (from overworld), Rail Station (to Corrund), East Hill Path (toward the Wilds border).

```
KETTLEWORKS -- The Research Facility
(80 tiles wide x 70 tiles tall, ~5 screens)

KEY:  [...] = building   === = rail line   ((( = glass dome
      |*| = prototype glow

         W (road from overworld)         === RAIL (to Corrund)
    ___________________________________________________
   |  <<< WEST ROAD             === RAIL STATION ===  |
   |                                                   |
   |  CAMPUS ENTRANCE                                  |
   |                                                   |
   |  [Guard     ][Admin      ]   [Visitor    ]        |
   |  [Booth     ][Building   ]   [Center     ]        |
   |  [          ][           ]   [(lore,     ]        |
   |  [          ][           ]   [ displays) ]        |
   |                                                   |
   |  RESEARCH CAMPUS                                  |
   |                                                   |
   |  [Precision  ][Prototype  ]   [Materials  ]       |
   |  [Workshop A ][Testing    ]   [Lab        ]       |
   |  [(brass     ][Hall       ]   [(chemicals,]       |
   |  [ instru-   ][(malfunction]  [ crystals) ]       |
   |  [ ments)    ][ in Interlud]  [           ]       |
   |              [ e)         ]                       |
   |                                                   |
   |         (((LABORATORY DOME)))                     |
   |        (((  (glass-and-brass  )))                 |
   |       (((    hemisphere,       )))                |
   |      (((      visible from      )))               |
   |     (((        surrounding       )))              |
   |      (((        hills;          )))               |
   |       (((      Arcanite glow   )))                |
   |        (((   at core)         )))                 |
   |         ((((((((((((((((((((()                    |
   |                                                   |
   |  [Workshop B ][Archive    ]   [Engine    ]        |
   |  [(prototype ][& Records  ]   [Room      ]        |
   |  [ assembly) ][(research  ]   [(Forgeward]        |
   |  [           ][ papers)   ]   [ Ley Line ]        |
   |  [           ][           ]   [ tap)     ]        |
   |                                                   |
   |  HOUSING & AMENITIES                              |
   |                                                   |
   |  [Engineer's ][Engineer's ]   [Campus    ][Campus ]|
   |  [Housing A  ][Housing B  ]   [Canteen   ][Store  ]|
   |  [(better    ][(better    ]   [          ][(tools,]|
   |  [ than      ][ than      ]   [          ][ parts)]|
   |  [ factory   ][ factory   ]   [          ][      ]|
   |  [ housing)  ][ housing)  ]   [          ][      ]|
   |                                                   |
   |  >>> EAST HILL PATH (toward Wilds border) >>>     |
   |___________________________________________________|
```

### Building Directory

| # | Building | Type | Location | NPCs | Services | Notes |
|---|----------|------|----------|-------|----------|-------|
| 1 | Guard Booth | Security | Entrance | Guard NPC | -- | Campus access; papers or guild clearance |
| 2 | Admin Building | Government | Entrance | Administrator NPC | -- | Campus operations |
| 3 | Visitor Center | Lore | Entrance | Guide NPC | Lore displays | Public-facing history of Compact innovation |
| 4 | Precision Workshop A | Research | Campus | Engineers (2-3) | -- | Brass instruments, fine-scale work |
| 5 | Prototype Testing Hall | Research | Campus | Test engineers | -- | Experimental devices on display; some malfunctioning |
| 6 | Materials Lab | Research | Campus | Chemist NPC | -- | Chemical supplies, ley-crystal analysis |
| 7 | Laboratory Dome | Research (main) | Campus center | Senior researchers, Jace Renn (sometimes) | -- | Campus centerpiece; Arcanite experiments |
| 8 | Workshop B | Research | Campus south | Engineers | -- | Prototype assembly; works-in-progress |
| 9 | Archive & Records | Lore | Campus south | Archivist NPC | Lore, research papers | Deep technical lore; optional |
| 10 | Engine Room | Utility | Campus south | Engineer NPC | -- | Forgeward Ley Line tap; campus power source |
| 11 | Engineer's Housing A-B | Housing | South | Engineers, families | -- | Better than factory housing; still modest |
| 12 | Campus Canteen | Service | South | Cook | Meals (HP restore) | Decent food; engineers eat better than workers |
| 13 | Campus Store | Commerce | South | Shopkeeper | Tools, parts, supplies | Research-grade equipment |
| 14 | Rail Station | Transit | Entrance | Rail Conductor | Fast travel (Corrund, Ashmark, Caldera) | 100g per trip per [transport.md](transport.md); erratic in Interlude |

### Shop Inventories

**Campus Store**

| Item | Type | Price (gold) | Act II | Interlude | Notes |
|------|------|---------------|--------|-----------|-------|
| Precision Tool Set | Tool | 400 | Yes | Yes | Required for Forgewright crafting |
| Arcanite Calibrator | Accessory | 1000 | Yes | Yes | +accuracy with Forgewright weapons |
| Ley-Analysis Lens | Accessory | 1400 | Yes | No | Reveals ley-line flow in dungeons |
| Research Ration | Consumable | 60 | Yes | Yes | HP restore (better than standard) |
| Prototype Component | Material | 500 | Yes | Yes | Crafting material |
| Blueprint Folio | Key item | 800 | No | Yes | Contains experimental weapon designs |
| Stabilizer Core | Material | 1200 | No | Yes | Rare crafting component; for Lira's upgrades |

**Visitor Center (free items, limited)**

| Item | Type | Notes |
|------|------|-------|
| Campus Map | Key item | Reveals all campus locations |
| Compact Innovation Pamphlet | Lore | Propaganda; unintentionally revealing |
| Arcanite Sample (inert) | Material | Minor crafting component; a souvenir |

### Points of Interest

**Save Points:**
- Campus Canteen (the only save point)

**Hidden Treasures:**
- Laboratory Dome: Examine the central experiment table to find a partially assembled device. With Lira in the party, she identifies it as a prototype Pallor detector. Key item: Prototype Pallor Detector (reveals Pallor corruption levels in the environment).
- Archive & Records: Deep in the stacks, a misfiled document. It is Jace Renn's suppressed paper on ley-line collapse. Reading it with Lira or Maren triggers extended lore dialogue. Grants the Theorist's Insight (accessory: +magic, +INT equivalent).
- Engine Room: Behind the main turbine, a maintenance hatch. Inside: a small room with the original Forgeward Ley Line survey map. Key item: Forgeward Survey (reveals the full ley-line network on the overworld map).
- East Hill Path: At the end of the path, overlooking the Wilds border, a cairn with a message from a Wilds ranger. "You are on borrowed land." Examining it grants no item but triggers environmental dialogue from any party member.

**Environmental Storytelling:**
- Glass roofs reveal laboratory interiors from outside. The player can see glowing prototype devices, chalkboards with equations, engineers at work. This transparency motif contrasts with every other Compact facility.
- The Laboratory Dome glints in sunlight -- visible from the surrounding hills. At night, its Arcanite glow is a beacon.
- Engineer housing is modest but has personal touches -- potted plants, curtains, bookshelves. The Compact treats its researchers better than its workers. The contrast with Ashmark or Caldera's housing is the point.
- In the Interlude, sealed laboratories have warning signs. Through the glass roofs, the player can see the damage -- scorch marks, broken equipment, a cracked chalkboard.

### Act-by-Act Changes

**Act II (optional visit):**
- Campus fully operational; researchers at work
- Lira recognizes prototypes from her training (special dialogue)
- Forgeward Ley Line provides stable power
- Engineers discuss their work with cautious pride
- Glass roofs show orderly, functioning labs

**Interlude:**
- Forgeward Line unstable -- prototype devices misfire
- Two laboratories sealed with warning signs (new barrier tiles)
- Laboratory Dome has a cracked glass panel (visible fracture line)
- Prototype Testing Hall has scorch marks from device malfunction
- Engineers frightened; some have left for Corrund
- Housing half-empty
- Rail to Corrund erratic
- Through sealed lab glass roofs: dark interiors, broken equipment
- The campus feels like a place that was thriving yesterday and is unraveling today

---

## Appendix: Cross-City Design Patterns

### Wealth Gradient

Every Carradan city with more than one district follows the same rule: streets widen toward power, narrow toward labor. Buildings gain glass windows, brass fittings, and cleaner brick as you approach the governing center. Near factories and extraction sites, housing is cramped, identical, and soot-stained. This pattern should be consistent enough that the player internalizes it -- so that when they see a narrow, windowless street, they know they are in the worker district without needing a label.

| City | Wealthy Zone | Working Zone | Contrast Intensity |
|------|-------------|--------------|-------------------|
| Corrund | Consortium Quarter, Merchant Mile | The Undercroft | Extreme (vertical separation) |
| Caldera | Upper Rim | Lower Factory District | Extreme (tiered bowl) |
| Ashmark | Founders' Hall area | Black Forge tenements | High (proximity makes it worse) |
| Bellhaven | Merchant Prince manors | The Stilts | High (elevation + construction) |
| Ashport | Merchant Quarter | Civilian Strip, docks | Moderate |
| Millhaven | Foreman's Office | Worker barracks | Low (everyone suffers) |
| Kettleworks | Laboratory campus | Engineer housing | Low (treated better) |

### Rail Network

Corrund, Ashmark, Caldera, and Kettleworks are connected by rail. In Act II, rail travel is a fast-travel mechanic between these cities (100g per trip, talk to Rail Rail Conductor at any terminal). In the Interlude, rail service is suspended -- tunnels collapse, boring engines reactivate, forcing overworld travel. See [transport.md](transport.md) for full rail mechanics. The rail connections:

```
Corrund ------- Ashmark ------- Caldera
    \
     \--------- Kettleworks
```

### Pallor Corruption Progression

All Carradan cities experience Pallor corruption during the Interlude, manifesting as:
- Arcanite glow shifting from blue-white to grey-white
- Forge-smoke becoming paler and colder
- The fading accelerating in workers near ley-line machinery
- Machines running erratically -- firing when they should not, going quiet without warning
- Canal and harbor water developing a grey film with no reflection

The corruption is Stage 1 at city edges and Stage 1-2 in industrial areas where ley-line machinery operates. Millhaven is the extreme case -- Stage 3 corruption destroys the town entirely.

### The Fading

"The fading" is the Compact's name for what happens to workers exposed to raw ley-line essence. It is also, unknowingly, early-stage Pallor influence. Symptoms progress:
1. Taste goes first
2. Laughter stops
3. Dreams end
4. Caring stops

The fading is visible in worker NPCs as: trembling sprite animations (Stage 1), shortened/repetitive dialogue (Stage 2), motionless sprites with no idle animation (Stage 3). It is present in Caldera, Ashmark, and Millhaven. During the Interlude, it accelerates everywhere.

### Black Market Network

Tash operates in Caldera's undercity but her network extends to Corrund (through Sable's contacts) and Bellhaven (through the Stilts). The black market sells items unavailable in legitimate shops -- forged papers, stolen components, resistance intelligence, Pallor wards. Prices are high but the inventory is unique. Sable's presence in the party lowers black market prices by 15% (her reputation precedes her).

| City | Black Market Location | Contact | Specialty |
|------|----------------------|---------|-----------|
| Corrund | Tash's Black Market (Undercroft) | Tash | Papers, intel, components |
| Caldera | Tash's Black Market (Undercity) | Tash | Papers, intel, resistance goods |
| Bellhaven | The Anchor Tavern basement (Stilts) | Sable's old contact | Maritime contraband, diving gear |
| Ashmark | The Soot tavern (under the counter) | Barkeep | Worker manifestos, blacklist records |
