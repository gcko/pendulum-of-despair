# Valdris Faction City Designs

Detailed tile-level layouts for every Valdris settlement. Each city is designed for 16x16 tile grids on a 256x224 viewport (16 tiles wide, 14 tiles tall per screen). Maps use the Valdris Highlands biome palette unless otherwise noted. Architecture is pale limestone, arched doorways, peaked slate roofs, timber framing, and ley-lamp posts.

Cross-references: `locations.md` (narrative), `npcs.md` (characters), `biomes.md` (palettes), `visual-style.md` (art direction), `dynamic-world.md` (act transitions).

---

## Table of Contents

1. [Valdris Crown (Capital)](#1-valdris-crown-capital)
2. [Aelhart (Starting Village)](#2-aelhart-starting-village)
3. [Highcairn (Monastery Town)](#3-highcairn-monastery-town)
4. [Thornwatch (Border Garrison)](#4-thornwatch-border-garrison)
5. [Greyvale (Fallen Border Town)](#5-greyvale-fallen-border-town)

---

## 1. Valdris Crown (Capital)

### 1.1 City Overview

**Size category:** Major city
**Approximate dimensions:** 240 x 224 tiles (15 screens wide x 16 screens tall, arranged in an irregular layout)
**Number of screens/areas:** 17 exterior screens + 8 major interior maps
**General layout:** Terraced plateau city in concentric rings, ascending from the Lower Ward at the base to the Royal Keep at the summit. Three tiers connected by stone ramps and covered stairways. Thick limestone walls with towers at cardinal points. The Seven Towers (ley line conduits) are spaced around the city perimeter and visible from every screen.
**Entry/exit points:**
- **South Gate (main):** Road to Aelhart and the western farmlands
- **East Gate:** Road to Greyvale and the Carradan border
- **North Gate:** Highland road to Highcairn
- **South-East Postern:** Military road to Thornwatch (Lower Ward access)

### 1.2 District Maps

Valdris Crown is too large for a single ASCII map. It is divided into five districts, each with its own map. The districts connect at transition points (marked with arrows).

---

#### District A: Lower Ward (4 screens)

The common quarter. Barracks, market, tavern, worker housing. Street-level entry from the South Gate. This is where the player spends the most time.

```
      LOWER WARD -- Valdris Crown (64 tiles wide x 56 tiles tall, 4 screens)
      North edge connects to --> Citizen's Walk via Stone Ramp

  N
  ^
  |

  ####============STONE RAMP TO CITIZEN'S WALK============####
  #                                                          #
  #    [REFUGEE    ]          +---------+                    #
  #    [  QUARTER  ]          | BARRACKS|   [TRAINING ]      #
  #    [ (open     ]   Marek* | (BK)    |   [ GROUND  ]      #
  #    [  ground)  ]          |  Cordwyn*|   [         ]      #
  #    [    Osric* ]          +---------+   [ post   x ]      #
  #                                                          #
  #    +--------+     ~~~~~~~~fountain~~~~~~~~               #
  #    |CHAPEL  |     ~          ()          ~    +------+   #
  #    |OF THE  |     ~  Nella*              ~    |CAEL'S|   #
  #    |OLD     |     ~~~~~~~~~~~~~~~~~~~~~~~~    |QRTRS |   #
  #    |PACTS   |                                 |(CQ)  |   #
  #    |(CH)    |                                 +------+   #
  #    |Thessa* |     === LOWER WARD SQUARE ===              #
  #    +--------+                                            #
  #              Bren*  +-MARKET-+  +-MARKET-+               #
  #                     |STALL 1 |  |STALL 2 |  +-------+   #
  #    +--------+       |food    |  |sundries|  |ANCHOR |   #
  #    |BAKERS  |       +--------+  +--------+  |& OAR  |   #
  #    |  (BK)  |                               |TAVERN |   #
  #    +--------+   +---------+  +---------+    |(TA)   |   #
  #                 |ITEM SHOP|  |ARMS SHOP|    | Renn* |   #
  #    Wynn*        |(IS)     |  |(WS)     |    +-------+   #
  #                 +---------+  +---------+                 #
  #                                                          #
  ##===SOUTH GATE===##               ##===SE POSTERN===##   #
       (to Aelhart)                    (to Thornwatch)
```

**Legend:**
```
#  = Limestone city wall           ()  = Fountain centerpiece
=  = Gate / ramp passage           ~   = Water (fountain basin)
+--+ = Building outline            *   = Named NPC spawn point
BK = Barracks                      x   = Training post (interactive)
CH = Chapel of the Old Pacts       IS  = Item Shop
WS = Weapon/Arms Shop             TA  = Tavern
CQ = Cael's Quarters              --> = District transition
```

---

#### District B: Citizen's Walk (4 screens)

The merchant and guild quarter. Wider streets, better stonework, guild halls, and the main commerce district. Reached by climbing the stone ramp from the Lower Ward.

```
      CITIZEN'S WALK -- Valdris Crown (64 tiles wide x 56 tiles tall, 4 screens)
      South edge connects to --> Lower Ward via Stone Ramp
      North edge connects to --> Court Quarter via Tiered Stairway
      East edge connects to --> Eastern Wall Battlements

  N
  ^
  |

  ####=====TIERED STAIRWAY TO COURT QUARTER=====####
  #                                                 #
  #   +----------+            +----------+          #
  #   |JEWELER & |     L*     |GUILD OF  |          #
  #   |ACCESSORY |     (lamp) |CARTOGRA- |          #
  #   |SHOP (JS) |            |PHERS(GC) |          #
  #   +----------+            +----------+          #
  #                                                 #
  #   ====== MERCHANT PROMENADE (cobblestone) ====  #
  #                                                 #
  #   +----------+   +-------+   +----------+      #
  #   |ARMOR     |   |NOTICE |   |SPECIALTY |      #
  #   |SHOP (AS) |   |BOARD *|   |GOODS (SG)|      #
  #   +----------+   +-------+   +----------+      #
  #                                                 #
  #   +----------+   ~~~river channel~~~            #
  #   |ROYAL     |   ~                 ~  +------+  #====>
  #   |LIBRARY   |   ~   stone bridge  ~  |MONEY |  TO
  #   |(RL)      |   ~                 ~  |LENDER|  EASTERN
  #   | Aldis*   |   ~~~~~~~~~~~~~~~~~~~  |(ML)  |  WALL
  #   | Mirren*  |                        +------+  #
  #   +----------+                                  #
  #                                                 #
  #   +--------+   == GUILD SQUARE ==   +--------+  #
  #   |WEAVERS |   Jorin Ashvale*       |HARBOR  |  #
  #   |GUILD   |                        |COMMAND |  #
  #   |(WG)    |   L*  [wellhead]  L*   |(HC)    |  #
  #   +--------+       (dry)           | Isen*  |  #
  #                                     +--------+  #
  #                                                 #
  ####=====STONE RAMP DOWN TO LOWER WARD=====####
```

**Legend (additional):**
```
AS = Armor Shop         JS = Jeweler & Accessory Shop
SG = Specialty Goods     RL = Royal Library
GC = Guild of Cartographers  ML = Money Lender
WG = Weavers Guild       HC = Harbor Command
L* = Ley-lamp post       [wellhead] = Dry well (environmental detail)
```

---

#### District C: Court Quarter (3 screens)

The noble district. Gated, patrolled, elevated. Walled gardens, noble estates, the Court Mage Tower. Accessible from the Citizen's Walk via the Tiered Stairway.

```
      COURT QUARTER -- Valdris Crown (48 tiles wide x 42 tiles tall, 3 screens)
      South edge connects to --> Citizen's Walk via Tiered Stairway
      North edge connects to --> Royal Keep via Grand Corridor

  N
  ^
  |

  ####=====GRAND CORRIDOR TO ROYAL KEEP=====####
  #                                             #
  #   +----------+     [GARDEN]    +--------+   #
  #   |COURT MAGE|     [  with ]   |HAREN'S |   #
  #   |TOWER(CMT)|     [flowers]   |ESTATE  |   #
  #   | Elara    |     [  L*   ]   |(HE)    |   #
  #   | Thane*   |     [       ]   | Haren* |   #
  #   +----------+                 +--------+   #
  #                                             #
  #   == COURT PROMENADE (flagstone) ========   #
  #                                             #
  #   +----------+                 +--------+   #
  #   |ASHVALE   |   +---------+  |COUNCIL |   #
  #   |TOWN HOUSE|   |NOBLE    |  |CHAMBERS|   #
  #   |(AT)      |   |ARCHIVE  |  |(CC)    |   #
  #   +----------+   |(NA)     |  +--------+   #
  #                  +---------+                #
  #   [guard        ]                           #
  #   [patrol route ]    L*    L*    L*         #
  #                                             #
  ####=TIERED STAIRWAY DOWN TO CITIZEN'S WALK=####
```

**Legend (additional):**
```
CMT = Court Mage Tower    HE = Haren's Estate
AT  = Ashvale Town House  NA = Noble Archive
CC  = Council Chambers    [GARDEN] = Walled courtyard garden
```

---

#### District D: Royal Keep (3 screens interior)

The seat of power. The Keep is an interior-only zone entered from the Court Quarter via the Grand Corridor. Vaulted ceilings, royal banners, the throne hall.

```
      ROYAL KEEP -- Valdris Crown (48 tiles wide x 42 tiles tall, 3 screens)
      Entered from Court Quarter via Grand Corridor (south)

  N
  ^
  |

  +=============================================+
  |                                             |
  |   +--------+                  +--------+    |
  |   |WAR     |   ====THRONE    |MAREN'S |    |
  |   |COUNCIL |   ====  HALL    |OLD     |    |
  |   |CHAMBER |                 |STUDY   |    |
  |   |(WC)    |   King Aldren*  |(MS)    |    |
  |   +--------+                 +--------+    |
  |              [THRONE ON DAIS]               |
  |              [  royal carpet ]               |
  |              [  four pillars ]               |
  |                                             |
  |   +--------+                  +--------+    |
  |   |ROYAL   |   == GREAT ==   |SERVANTS|    |
  |   |BED-    |   == HALL  ==   |PASSAGE |    |
  |   |CHAMBER |                 |(SP)    |    |
  |   |(RB)    |                 +--------+    |
  |   +--------+                               |
  |                                             |
  |   +---------+                               |
  |   |PENDULUM |  (guarded in Act II)          |
  |   |RESEARCH |                               |
  |   |ROOM(PR) |                               |
  |   +---------+                               |
  |                                             |
  +====GRAND CORRIDOR TO COURT QUARTER====+
```

**Legend (additional):**
```
WC = War Council Chamber    MS = Maren's Old Study
RB = Royal Bedchamber       SP = Servants' Passage (alternate entry in Interlude)
PR = Pendulum Research Room (Act II only, guarded)
```

---

#### District E: Eastern Wall & Battlements (2 screens)

The defensive perimeter facing the Carradan border. Walkable battlements, watchtowers, siege equipment emplacements. This is where the Act II assault set piece takes place.

```
      EASTERN WALL -- Valdris Crown (32 tiles wide x 28 tiles tall, 2 screens)
      West edge connects to --> Citizen's Walk
      The wall is a continuous walkway with towers at intervals

  N
  ^
  |

  T*=====wall=====T*=====wall=====T*
  |  (watchtower)  |  (watchtower)  |  (watchtower)
  |                |                |
  |  [catapult]    |  [siege view]  |  [catapult]
  |                |                |
  |  battlement    |  battlement    |  battlement
  |  walkway       |  walkway       |  walkway
  |                |                |
  |  arrow slits   |  BREACH ZONE   |  arrow slits
  |                | (Act II: rubble|
  |                |  replaces wall)|
  T*=====wall=====T*====BREACH====T*
                        |
                   (Act II+: debris slope
                    to eastern approach)

  <== TO CITIZEN'S WALK
```

---

#### District F: Tower Tutorial (1 screen per tower, 2 accessible in Act I)

Two of the Seven Towers serve as the magic tutorial dungeon in Act I. Each is a vertical interior (3 floors) with ley line puzzles. Not mapped in detail here -- they follow standard dungeon layouts (spiral staircase, puzzle rooms, boss room at top).

---

### 1.3 Building Directory

| Building | Type | District | Key NPCs | Services | Notes |
|----------|------|----------|----------|----------|-------|
| South Gate Guardhouse | Gatehouse | Lower Ward | Wynn (guard) | Gate passage | Tracks refugee arrivals |
| Barracks | Military | Lower Ward | Dame Cordwyn, Sgt. Marek | Rest, lore | Edren and Cael's home base; training post outside |
| Chapel of the Old Pacts | Temple | Lower Ward | Thessa (keeper) | Save point, lore | Spirit pact tablets; shuttered in Interlude |
| Lower Ward Item Shop | Shop | Lower Ward | Unnamed shopkeeper | Potions, items | See inventory below |
| Lower Ward Arms Shop | Shop | Lower Ward | Unnamed weaponsmith | Weapons | See inventory below |
| Bakers | Vendor | Lower Ward | Bren | Bread (flavor item) | Visual barometer of decline |
| Market Stalls (x2) | Open market | Lower Ward | Various vendors | Food, sundries | Half-empty in Act II; 1 vendor in Interlude |
| The Anchor & Oar | Tavern / Inn | Lower Ward | Renn (keeper) | Inn, drinks, rumors, intel | Sable's primary Valdris contact |
| Cael's Quarters | Residence | Lower Ward | (Cael, Act I) | Cutscene location | Cordoned and warded in Act II; sealed in Interlude |
| Refugee Quarter | Open area | Lower Ward | Osric (refugee) | Lore | Act II onward; grows each act |
| Armor Shop | Shop | Citizen's Walk | Unnamed armorsmith | Armor, shields | See inventory below |
| Jeweler & Accessory Shop | Shop | Citizen's Walk | Unnamed jeweler | Accessories, rings | Unique Valdris pact-charms |
| Specialty Goods | Shop | Citizen's Walk | Unnamed merchant | Rare consumables | Stock changes per act |
| Royal Library | Lore | Citizen's Walk | Scholar Aldis, Mirren | Deep lore, quest info | Aldis obsesses over Cael's notes in Interlude |
| Guild of Cartographers | Guild | Citizen's Walk | Unnamed guildmaster | World map upgrades | Reveals hidden locations when talked to |
| Money Lender | Service | Citizen's Walk | Unnamed lender | Currency exchange | Prices rise per act |
| Weavers Guild | Guild | Citizen's Walk | Unnamed weaver | Cosmetic cloaks | Flavor building |
| Harbor Command | Military | Citizen's Walk | Captain Isen | Lore, boat passage (Interlude) | Isen ferries refugees in Interlude |
| Court Mage Tower | Residence | Court Quarter | Elara Thane | Lore, optional quest | She relocates to outskirts in Interlude |
| Haren's Estate | Residence | Court Quarter | Lord Chancellor Haren | Political lore | Haren retreats here in Interlude |
| Ashvale Town House | Residence | Court Quarter | Jorin Ashvale (Interlude) | Lore | Jorin moves here after losing his estate |
| Council Chambers | Government | Court Quarter | (Council members) | Cutscene location | Political infighting in Act II |
| Noble Archive | Lore | Court Quarter | None | Historical documents | Contains pre-Valdris records |
| Throne Hall | Government | Royal Keep | King Aldren (Acts I-II) | Main quest | Blood on flagstones after the assault |
| War Council Chamber | Government | Royal Keep | (Various generals) | Cutscene (Act II) | Briefing for the diplomatic mission |
| Maren's Old Study | Lore | Royal Keep | None | Hidden lore | Books on the Pallor, partially cleared |
| Pendulum Research Room | Special | Royal Keep | (Cael, Act II) | Cutscene | Guarded; Cael's notes scattered |
| Servants' Passage | Access | Royal Keep | None | Alternate entry | Used in Interlude to bypass barred doors |

### 1.4 Shop Inventories

#### Lower Ward Arms Shop (Weapons)

| Item | Price (Act I) | Price (Act II) | Stats Hint | Notes |
|------|--------------|----------------|------------|-------|
| Iron Longsword | 300 | 360 | ATK +12 | Edren's first upgrade |
| Steel Halberd | 450 | 540 | ATK +16 | Two-handed |
| Ley-Touched Dagger | 500 | 600 | ATK +8, MAG +4 | Faint ley glow; Sable or Cael |
| Reinforced Shortbow | 350 | 420 | ATK +10, AGI +2 | Torren's weapon class |
| Knight's Blade | -- | 800 | ATK +22 | Available Act II only |
| Interlude: Black Market Blade | -- | -- | ATK +28, LUCK -5 | Sold by Renn's contact, 1500g |

*Interlude:* Shop is closed. Renn sells a limited selection from the Anchor & Oar at 200% markup. One black market weapon available.

#### Armor Shop (Citizen's Walk)

| Item | Price (Act I) | Price (Act II) | Stats Hint | Notes |
|------|--------------|----------------|------------|-------|
| Chain Hauberk | 400 | 480 | DEF +10 | Standard medium armor |
| Ley-Woven Robe | 550 | 660 | DEF +5, MAG DEF +12 | Mage armor |
| Iron Buckler | 200 | 240 | DEF +4, Block 10% | Shield |
| Knight's Plate | -- | 1000 | DEF +18 | Act II only; heavy |
| Highland Cloak | 300 | 360 | MAG DEF +6, resist Cold | Valdris specialty |
| Interlude: Salvaged Plate | -- | -- | DEF +14 | Found stock, 800g, scratched |

*Interlude:* Limited to leftover stock at 150% markup. No new shipments.

#### Lower Ward Item Shop

| Item | Price (Act I) | Price (Act II) | Interlude | Effect |
|------|--------------|----------------|-----------|--------|
| Healing Draught | 50 | 65 | 100 | Restore 200 HP |
| Mana Tincture | 80 | 100 | 160 | Restore 50 MP |
| Antidote | 30 | 40 | 60 | Cure Poison |
| Smelling Salts | 40 | 50 | 80 | Cure Sleep/Confuse |
| Phoenix Pinion | 300 | 360 | 600 | Revive with 25% HP |
| Ley-Lantern | 60 | 75 | -- | Light source for dungeons |
| Warding Charm | -- | 150 | -- | Reduce encounter rate |

*Interlude:* Single vendor in the market square. Phoenix Pinions sold out. Ley-Lanterns unavailable (no ley energy to charge them).

#### Jeweler & Accessory Shop (Citizen's Walk)

| Item | Price (Act I) | Price (Act II) | Stats Hint | Notes |
|------|--------------|----------------|------------|-------|
| Pact-Charm (Wind) | 600 | 720 | +5% Wind resist, AGI +2 | Spirit-touched |
| Pact-Charm (Earth) | 600 | 720 | +5% Earth resist, DEF +2 | Spirit-touched |
| Silver Ring | 200 | 240 | MAG +3 | Basic mage accessory |
| Guardian Pendant | 400 | 480 | Auto-Protect at <25% HP | Unique to Valdris |
| Royal Signet | -- | 1200 | All stats +2 | Act II; requires court favor |

*Interlude:* Shop closed. Jeweler fled to Highcairn.

#### Specialty Goods (Citizen's Walk)

| Item | Price (Act I) | Price (Act II) | Effect | Notes |
|------|--------------|----------------|--------|-------|
| Starbloom Tea | 150 | 200 | Full HP restore, cures all status | Brewed from Nella's flowers |
| Whetstone | 100 | 120 | +10% ATK for one battle | Consumable |
| Spirit Incense | 200 | 250 | +15% MAG for one battle | Valdris ritual item |
| Waystone | 500 | -- | Return to last save point | Rare; limited stock |
| Interlude: Pallor Antidote | -- | -- | Cures Despair status | 400g, sold by the lone vendor |

### 1.5 Points of Interest

**Save points:**
- Chapel of the Old Pacts (Lower Ward) -- primary save, always accessible
- Royal Library study alcove (Citizen's Walk) -- secondary save
- Throne Hall antechamber (Royal Keep) -- Act II onward

**Treasure chests:**
- Behind the Barracks: 1x Phoenix Pinion (hidden by building shadow)
- Royal Library basement stacks: 1x Spirit Incense (requires examining specific bookshelf)
- Eastern Wall watchtower (northernmost): 1x Whetstone
- Maren's Old Study (Royal Keep): Maren's Staff Fragment (key item, Act II)
- Servants' Passage: 1x Healing Draught, 1x 500g pouch (Interlude only)

**Environmental storytelling:**
- The child's chalk drawing on the Lower Ward wall: one tower drawn dark in Act II, "HELP US" added in Interlude
- Nella's flower cart: vibrant in Act I, sparse in Act II, dried arrangements in Interlude
- Training post outside the Barracks: Cael's name carved fresh each morning (Sgt. Marek's grief)
- The dry wellhead in Guild Square: identical to Aelhart's well, connecting the two locations thematically
- "WHERE IS THE KING?" graffiti appears on the notice board in Act II
- "COME HOME EDREN" on the Lower Ward wall in Interlude
- Ley-lamp degradation: 7/7 lit (Act I), 4/7 lit (Act II), 0/7 lit (Interlude)

**Secret areas / hidden passages:**
- Servants' Passage in the Royal Keep: accessible in Interlude when the main doors are barred. Entrance behind a tapestry in the Great Hall.
- Library basement: accessible by examining a cracked wall tile in the Royal Library. Contains Mirren's hidden archive with the "third Door" document.
- Eastern Wall breach (Act II+): after the assault, the rubble slope on the exterior side leads to a small alcove with a Valdris knight's journal and a unique shield (Oathkeeper Buckler, DEF +8, +10% vs. Compact enemies).

### 1.6 Act-by-Act Changes

#### Act I (Base State)

Full city. All ley-lamps lit. Markets bustling. Children in the Lower Ward. Flowers in window boxes. Golden afternoon light. The Seven Towers pulse gold. This is the peak -- everything the player sees here is something they will lose.

- All districts accessible except War Council Chamber and Eastern Wall battlements
- Cael's Quarters: accessible, personal effects visible
- Full shop inventories at base prices
- NPC density: 100%

#### Act II (Declining + Post-Assault)

**Pre-assault changes:**
- Ley-lamps: 4 of 7 towers lit, street lamps flickering (1 in 4 dim)
- Markets: half-empty stalls, torn awnings
- New defensive emplacements on outer walls (catapults, stacked crates)
- Cael's Quarters: cordoned off with guards and magical ward barrier
- War Council Chamber: now accessible
- Eastern Wall battlements: now accessible
- Shop prices rise 20-30%
- Refugee Quarter has 1-2 refugee families (Osric among them)
- NPC density: 75%

**Post-assault changes (set piece):**
- EASTERN WALL BREACH: 8-tile section of wall replaced with rubble tiles. Fire-damaged edges. Siege engine wreckage at base.
- Two Lower Ward buildings collapsed (fire damage): the bakery's upper floor and one market stall destroyed
- Throne Hall: blood on flagstones, empty throne, one cracked pillar
- Fires in Lower Ward (scorch marks remain permanently)
- King Aldren is dead. The throne is empty.
- Bodies under sheets line the Lower Ward square

#### Interlude (Fractured Capital)

**Major map changes:**
- Noble house barricades divide Citizen's Walk into three zones (furniture, carts, rubble forming impassable walls with single guarded passages between them)
- Court Quarter: locked down by Haren's faction. Entry requires persuasion or Sable's contacts.
- Royal Keep main doors: barred. Access only via Servants' Passage.
- Eastern wall breach: permanent ruin. Rubble passable on foot (slow terrain).
- Market Square: empty except 1 vendor

**Visual changes:**
- All ley-lamps dark. Towers are black silhouettes against grey sky.
- Limestone greyed -- warm pale color replaced with cold grey-beige
- Grey dust in corners and on windowsills
- Permanent overcast, grey filter on palette
- Stage 1-2 Pallor corruption

**NPC changes:**
- Density: 40%. Catatonic civilians stand in Lower Ward doorways (no idle animation)
- Cordwyn commands the remnant garrison from the Barracks
- Haren is in his estate, writing unanswered letters
- Aldis is locked in the library, surrounded by Cael's notes
- Renn still operates the Anchor & Oar (primary intel source)
- Isen ferries refugees from Harbor Command
- Elara Thane has relocated to a ruined watchtower outside the city (referenced, not visitable)
- Jorin Ashvale has moved to the Court Quarter, dispossessed

**Graffiti/signs:**
- Noble house crests painted on barricades
- "HAREN LIES" scratched into wall near Council Chambers
- "COME HOME EDREN" on Lower Ward wall
- Child's chalk drawing smudged, "HELP US" added

#### Epilogue (Rebuilding)

**Map changes:**
- Barricades removed
- Eastern wall breach: scaffolding and fresh-cut limestone (lighter color) being set. Not repaired -- being repaired.
- Collapsed buildings: wildflowers grow in rubble. Not yet cleared.
- New Arcanite lanterns (Compact brass-and-blue-white) beside old ley-lamp posts. Some ley-lamps reignited.
- Bridgewright guild signs on several buildings
- Memorial plaque on Lower Ward wall listing the dead

**NPC changes:**
- Density: 60%. Mixed Valdris-Compact population
- Market active again, smaller, with both faction merchants
- Training ground has fresh-faced recruits
- No catatonic civilians

---

## 2. Aelhart (Starting Village)

### 2.1 City Overview

**Size category:** Village
**Approximate dimensions:** 48 x 42 tiles (3 screens wide x 3 screens tall, with only ~6 screens of actual content in an L-shape)
**Number of screens/areas:** 3 exterior screens + 3 small interiors
**General layout:** Organic farming village along a single main road. No walls. Stone cottages with thatch roofs clustered around a central square. Wheat fields on three sides. A river with a watermill on the western edge. Open, warm, vulnerable.
**Entry/exit points:**
- **East road:** To Valdris Crown (the capital road)
- **South road:** To the border and eventually Thornwatch / the Wilds
- **West path:** To the watermill and surrounding farmland (dead end)

### 2.2 ASCII City Map

```
      AELHART -- Starting Village (48 tiles wide x 42 tiles tall, ~3 screens)

  N
  ^
  |
  ~~~~~~~~~~~~river~~~~~~~~~~~~~
  ~                            ~
  ~   [WATER-]                 ~
  ~   [ MILL ]                 ~~~~~~~>  (river continues east)
  ~   [  WM  ]                       ~
  ~                                  ~
  ~~~~~~~~~~~~river crossing~~~~~~~~~~
              (stone bridge)
  wwwwwwwwww                      wwwwwwwwwwwwww
  w  wheat w   +--------+        w   wheat    w
  w  field w   |ELDER'S |        w   field    w
  w        w   |HOUSE   |        w            w
  wwwwwwwwww   |(EH)    |        wwwwwwwwwwwwww
               +--------+
  +-------+                  +--------+
  |FARM   |  ====VILLAGE     |INN     |
  |HOUSE 1|  ==== SQUARE     |"THE    |
  |(FH1)  |                  |HEARTHSTONE"
  +-------+  [DRY ]  Farmer* |(IN)    |
              [WELL]          +--------+
  +-------+  [  W ]
  |FARM   |               +----------+
  |HOUSE 2|    L*          |GENERAL   |
  |(FH2)  |               |STORE (GS)|
  +-------+               +----------+
                                         +----------+
  wwwwwwwwww    === main road ===        |CARRADAN  |
  w  wheat w                             |TRADER'S  |
  w  field w                             |STALL (CT)|
  w        w                             +----------+
  wwwwwwwwww
            \                          /
             ===south road============
              (to Thornwatch / border)

  <=== east road (to Valdris Crown) ===>
```

**Legend:**
```
~   = River                    w   = Wheat field boundary
WM  = Watermill                EH  = Elder's House
FH  = Farmhouse                IN  = Inn (The Hearthstone)
GS  = General Store            CT  = Carradan Trader's Stall
W   = Dry Well                 L*  = Ley-lamp post (dim)
*   = NPC spawn point          === = Road / path
```

### 2.3 Building Directory

| Building | Type | Location on Map | Key NPCs | Services | Notes |
|----------|------|----------------|----------|----------|-------|
| The Hearthstone Inn | Inn | East side of square | Unnamed innkeep | Save point, rest, basic tutorial | Warm, rustic; the player's first safe space |
| General Store | Shop | South-east of square | Unnamed shopkeep | Basic items, starting gear | Limited stock; a village store |
| Elder's House | Residence | North of square | Village Elder (unnamed) | Lore, tutorial dialogue | Books on Valdris history; ley line almanac |
| Carradan Trader's Stall | Vendor | South-east edge | Unnamed Carradan trader | Forgewright tools (flavor), 1-2 items | First sign of Compact cultural creep |
| Farmhouse 1 | Residence | West of square | Farmer (unnamed) | Tutorial quest giver ("spooked animal") | Side quest: investigate aggressive wildlife |
| Farmhouse 2 | Residence | South-west of square | Farmer family | Flavor dialogue | Children mention the dry well |
| Watermill | Landmark | North-west by river | Miller (unnamed) | Flour (flavor item) | Wheel still turns; overworld landmark |

### 2.4 Shop Inventories

#### General Store

| Item | Price | Effect | Notes |
|------|-------|--------|-------|
| Herb Poultice | 25 | Restore 100 HP | Cheapest heal |
| Antidote | 30 | Cure Poison | Basic status cure |
| Wooden Shield | 80 | DEF +2 | Starter gear if not already equipped |
| Traveler's Cloak | 60 | MAG DEF +2 | Starter accessory |
| Torch | 15 | Light source (short duration) | For the Ember Vein later |
| Bread Loaf | 10 | Restore 30 HP | Flavor item from Bren's regional supply |

#### Carradan Trader's Stall

| Item | Price | Effect | Notes |
|------|-------|--------|-------|
| Forgewright Compass | 150 | Reveals minimap in dungeons | Unique to this trader; foreshadows Compact tech |
| Arcanite Whetstone | 100 | +10% ATK one battle | Same as Valdris Crown but sold by a foreign trader |

*No act transitions for Aelhart shops -- the player only visits in Act I. By Act II the village is inaccessible.*

### 2.5 Points of Interest

**Save point:** Inside The Hearthstone Inn (the bed serves as save point).

**Treasure chests:**
- Behind the Watermill: 1x Herb Poultice (teaches players to look behind buildings)
- Inside Farmhouse 1 (after completing the spooked animal quest): 1x 100g reward pouch

**Environmental storytelling:**
- The Dry Well: center of the village square. NPCs mention it offhandedly -- "Went dry three seasons back." The ley line beneath it stopped flowing. In the Interlude, the well's foundation cracks open, revealing a mini-dungeon beneath (see Dry Well of Aelhart in locations.md).
- Wheat fields: golden and swaying (3-frame animation). Three sides of the village. No other location has this crop density. This is what feeds Valdris.
- The Carradan Trader: a small, deliberate detail. Compact goods on Valdris soil. The trader is polite, professional, and sells useful items. The tension is not hostile -- it is insidious.
- Older farmers mention the soil "used to glow." Ley line magic enriched the farmland; now it is just dirt.

**Secret areas:**
- The Dry Well crack: visible in Act I but too narrow to enter. During the Interlude, ley line instability widens it. Three-room mini-dungeon below with pre-civilization ruins. Reward: Edren's Family Crest (unique accessory, ATK +3, DEF +3, unlocks a special dialogue with Edren).

### 2.6 Act-by-Act Changes

#### Act I (Base State)

Full village. Dawn lighting on first visit (pink-gold sunrise tint). Birdsong. Wheat swaying. Children playing near the well. The player's first experience of the game world -- designed to feel safe, warm, and worth protecting.

- All buildings accessible
- All NPCs present and cheerful
- Light tutorial quests available

#### Act II-III (Inaccessible)

The border road is too dangerous. Aelhart is referenced by NPCs as "cut off." The player cannot return. The village exists only in memory.

**Offscreen state (NPC dialogue references):**
- Compact occupation. Inn repurposed as garrison post.
- Dry well still dry. Carradan trader is the only merchant.
- Farmers work for Compact supply requisitions.
- No violence -- just quiet annexation.

#### Interlude (Dry Well Access Only)

The village itself is not a full map. The player accesses only the well and its mini-dungeon. The small slice of village visible around the well entrance shows:
- Inn's thatch roof partially collapsed
- Compact supply crates stacked against buildings
- Compact flag on a pole where the ley-lamp stood
- No civilians visible
- Wheat fields fallow
- Silence where there was birdsong

#### Epilogue (Overworld Reference Only)

Not directly visitable. Visible from the overworld: Compact forces have left. Early spring green in the fields. The dry well has been capped with new stone. Recovery, not restoration.

---

## 3. Highcairn (Monastery Town)

### 3.1 City Overview

**Size category:** Village (town portion) + Medium dungeon (monastery interior)
**Approximate dimensions:** 48 x 28 tiles for the town (3 screens); monastery interior is 64 x 56 tiles (4 screens of dungeon)
**Number of screens/areas:** 3 exterior + 4 interior (monastery dungeon)
**General layout:** A small alpine settlement huddled beneath the Monastery of the Vigil. The town is a single switchback road climbing from the highland approach to the monastery gates. No walls -- the altitude and cold are the defenses. The monastery itself is a rectangular stone compound with a bell tower, great hall, dormitory wings, and a highland overlook promontory.
**Entry/exit points:**
- **South trail:** Highland descent road to Valdris Crown (switchbacks)
- **Monastery gate:** North end of the village road (enters monastery grounds)
- **Highland overlook:** East side of the monastery (scenic promontory, no exit)

### 3.2 ASCII City Map

#### Town Exterior

```
      HIGHCAIRN TOWN -- Alpine Village (48 tiles wide x 28 tiles tall, 3 screens)

  N
  ^
  |
               +====MONASTERY GATE====+
               |                      |
  sssssssssss  |                      |  sssssssssss
  s  snow   s  |  (path continues     |  s  snow   s
  s  field  s  |   to monastery       |  s  field  s
  sssssssssss  |   grounds)           |  sssssssssss
               |                      |
    pppppppppp==                      ==pppppppppp
    p pine   p   ====switchback====     p  pine  p
    p grove  p                          p  grove p
    pppppppppp   +--------+             pppppppppp
                 |HEALER'S|
                 |COTTAGE |
    +--------+   |(HL)    |   +----------+
    |STABLE  |   +--------+   |PROVISION-|
    |(ST)    |                |ER (PV)   |
    +--------+                +----------+

                 ====village road====

    +--------+                +--------+
    |LAY     |    L*    L*    |LAY     |
    |BROTHER |                |BROTHER |
    |HOME 1  |   [stone      |HOME 2  |
    |(LB1)   |    bench]     |(LB2)   |
    +--------+               +--------+

               ====switchback====
               |
               v  SOUTH TRAIL
            (to Valdris Crown)
```

**Legend:**
```
s  = Snow-covered ground        p  = Pine grove
ST = Stable                     HL = Healer's Cottage
PV = Provisioner                LB = Lay Brother's Home
L* = Ley-lamp post (hearth-lit  === = Stone path
     lantern variant)
```

#### Monastery Interior (Dungeon in Interlude)

```
      MONASTERY OF THE VIGIL -- Interior (64 tiles wide x 56 tiles tall, 4 screens)

  N
  ^
  |
               +====HIGHLAND OVERLOOK====+
               |  (promontory, panoramic |
               |   view of continent)    |
               |  Edren stands here *    |
               +=========================+
                         |
  +=============================================+
  |                                             |
  |   +----------+                +----------+  |
  |   |DORMITORY |  ==CORRIDOR==  |DORMITORY |  |
  |   |WING EAST |  (grey mist   |WING WEST |  |
  |   |(DE)      |   crawls      |(DW)      |  |
  |   | monks *  |   along       | monks *  |  |
  |   +----------+   floor)      +----------+  |
  |                                             |
  |   +------- GREAT HALL --------+             |
  |   |                           |  +-------+  |
  |   |  [HEARTH -- two centuries |  |PRAYER |  |
  |   |   burning, never cold]    |  |ROOM   |  |
  |   |                           |  |(PY)   |  |
  |   |   Father Aldous *         |  | worn  |  |
  |   |                           |  | stones|  |
  |   |   Edren * (found here)    |  +-------+  |
  |   |                           |             |
  |   +---------------------------+             |
  |                                             |
  |   +---------+   ==ENTRY==   +---------+     |
  |   |ARMORY   |   ==HALL ==   |BELL     |     |
  |   |(AR)     |               |TOWER    |     |
  |   | weapon  |               |BASE(BT) |     |
  |   | racks + |               +---------+     |
  |   | prayer  |                               |
  |   | beads   |                               |
  |   +---------+                               |
  |                                             |
  +======MONASTERY GATE (to town)========+
```

**Legend (additional):**
```
DE/DW = Dormitory wings         PY = Prayer Room
AR    = Armory                  BT = Bell Tower Base
```

### 3.3 Building Directory

| Building | Type | Location | Key NPCs | Services | Notes |
|----------|------|----------|----------|----------|-------|
| Stable | Service | Town, north-west | Unnamed stablehand | Chocobo-equivalent rest (if applicable) | Shelter from wind |
| Healer's Cottage | Shop/Healer | Town, center | Unnamed healer | Healing, basic restoratives | Limited stock; alpine herbs |
| Provisioner | Shop | Town, center-east | Unnamed merchant | Basic supplies | Remote location = limited, expensive stock |
| Lay Brother Home 1 | Residence | Town, south-west | Unnamed lay brother | Lore | Tells stories of the Vigil order |
| Lay Brother Home 2 | Residence | Town, south-east | Unnamed lay brother | Lore | Family of a monk; worried dialogue |
| Great Hall | Monastery | Monastery interior | Father Aldous, Edren (Interlude) | Cutscene, save point (hearth) | The hearth is the save point; two centuries warm |
| Dormitory East | Monastery | Monastery interior | Monks (some catatonic) | Dungeon rooms | Grey mist, Pallor manifestation spawns |
| Dormitory West | Monastery | Monastery interior | Monks (some catatonic) | Dungeon rooms | Prayer stones with grey frost |
| Prayer Room | Monastery | Monastery interior | None | Lore | Worn prayer stones, Vigil's history |
| Armory | Monastery | Monastery interior | None | Equipment (1 chest) | Weapon racks alongside prayer beads |
| Bell Tower Base | Monastery | Monastery interior | None | Dungeon path | Spiral staircase; optional upper floor |
| Highland Overlook | Vista | Monastery, east | Edren (story beat) | Panoramic view | The continent's scar is visible from here |

### 3.4 Shop Inventories

#### Healer's Cottage

| Item | Price | Effect | Notes |
|------|-------|--------|-------|
| Alpine Remedy | 60 | Restore 250 HP | Local herb blend |
| Frostbane Tea | 80 | Cure Freeze status, +10% Cold resist 1 battle | Alpine specialty |
| Antidote | 30 | Cure Poison | Standard |
| Smelling Salts | 40 | Cure Sleep/Confuse | Standard |

#### Provisioner

| Item | Price | Effect | Notes |
|------|-------|--------|-------|
| Healing Draught | 65 | Restore 200 HP | 30% markup over capital (remote location) |
| Mana Tincture | 100 | Restore 50 MP | Marked up |
| Torch | 20 | Light source | For monastery dungeon |
| Rope | 30 | Dungeon utility item | Interlude puzzle use |
| Trail Rations | 15 | Restore 50 HP | Cheap, weak |

*Interlude:* Provisioner stock is very limited. Prices rise 50%. Some items sold out (no supply caravans reaching the highlands).

*Act III:* Monks provide supplies freely (a blessing) -- 3x Alpine Remedy, 2x Frostbane Tea, 1x Mana Tincture. One-time gift.

### 3.5 Points of Interest

**Save point:** Great Hall hearth (the fire that never goes cold). The warmest pixel on the screen.

**Treasure chests:**
- Armory: Vigil's Edge (unique sword, ATK +20, +15% vs. Pallor manifestations)
- Bell Tower upper floor (optional climb): 1x Phoenix Pinion, 1x Highland Cloak
- Dormitory East (behind a collapsed bed): 1x Mana Tincture

**Environmental storytelling:**
- Prayer stones in the courtyard: grey frost creeping up their surfaces in Interlude. The frost never melts.
- One monk sits facing a wall and does not respond to interaction.
- The Great Hall hearth: the only warm-colored light in the monastery during the Interlude. Everything else is cold grey-white. The hearth says: something endures.
- Highland Overlook: Act III shows the grey stain spreading from the Convergence. The most dramatic environmental storytelling vista in the game.
- Weapon racks next to prayer beads in the Armory: this is a martial order. They pray and they fight. Both disciplines are failing.

**Secret areas:**
- Bell Tower upper floor: accessible by examining the spiral staircase closely. A narrow passage leads to the belfry. The bell is still functional -- ringing it during the Interlude dungeon stuns nearby Pallor manifestations for 3 turns (one-time use).

### 3.6 Act-by-Act Changes

#### Interlude (First Visit -- Dungeon State)

**Town:**
- Grey frost on all surfaces. Snow that does not look natural -- too uniform, too grey.
- Wind has dropped. The characteristic alpine silence is oppressive, not peaceful.
- Provisioner and healer are open but nervous. Limited stock.
- One lay brother reports monks "dreaming of giving up."

**Monastery dungeon:**
- Grey mist crawls along stone floors
- Monks pace corridors with hollow eyes (non-hostile but disturbing)
- Pallor manifestations spawn in dormitory wings and corridors
- Father Aldous is in the Great Hall, maintaining the hearth
- Edren is found in the Great Hall, sitting, not fighting, not praying
- Boss: Pallor Hollow -- a manifestation of Edren's guilt, fought in the Great Hall. The Pallor corruption transforms the Great Hall into the boss arena: grey mist thickens, the hearth dims to a single warm point, and the hall's stone pillars warp into spectral shapes. The arena is the Great Hall map (interiors.md Section 1.4) with Pallor overlay tiles replacing the benches and columns. The hearth's save point remains active at the edge of the arena. After defeating the manifestation, the mist recedes and the hall returns to its normal state (with minor cosmetic damage). The fight uses the Great Hall's 18x14 tile space; no separate dungeon map is required.
- After the boss, Edren rejoins the party

#### Act III (Brief Supply Stop)

**Town/Monastery changes:**
- Pallor manifestations defeated. Battle damage visible: claw marks on walls, broken windows, one corridor collapsed (new rubble, blocked path).
- Grey frost receding but stains remain on stone.
- Makeshift infirmary in the Great Hall (bedrolls, bandages, healer NPC).
- Monks shaken but functional.
- Father Aldous provides a blessing (stat buff for next dungeon).
- Highland Overlook: the grey is worse. The continent's center is visibly stained.

#### Epilogue (Healed)

- Grey frost gone. Natural frost returns with hexagonal patterns.
- Collapsed corridor: scaffolding (under repair, not yet fixed).
- Monastery hearth burns amber again.
- The overlook shows a scarred but green continent. First clear sunrise.
- The monks have new purpose. The order endures.

---

## 4. Thornwatch (Border Garrison)

### 4.1 City Overview

**Size category:** Fortified outpost (small town)
**Approximate dimensions:** 64 x 42 tiles (4 screens wide x 3 screens tall, roughly 4 screens of content)
**Number of screens/areas:** 4 exterior screens + 2 small interiors
**General layout:** A squat stone fort with a wooden palisade extension, set on a low hill overlooking the Thornmere treeline to the south. Military grid layout inside the fort walls. A small civilian cluster (inn, provisioner) outside the main gate. The watchtower dominates the center. Everything is functional and angular -- this is a working garrison, not a city.
**Entry/exit points:**
- **North road:** To Valdris Crown via the Valdris Highroad (rolling hills)
- **South gate:** Through the palisade, road descends into the Thornmere Wilds
- **East perimeter:** View of Carradan smoke plumes (no exit; border zone)

### 4.2 ASCII City Map

```
      THORNWATCH -- Border Garrison (64 tiles wide x 42 tiles tall, ~4 screens)

  N
  ^
  |
           === NORTH ROAD (to Valdris Crown) ===
                         |
  ####===NORTH GATE===####
  #                       #
  #  +---------+          #    +--------+
  #  |GARRISON |   MUSTER #    |INN     |
  #  |BARRACKS |   YARD   #    |"THE    |
  #  |(GB)     |          #    |BORDER  |
  #  | soldiers|  [flag-  #    |REST"   |
  #  +---------+   pole]  #    |(IN)    |
  #                       #    +--------+
  #  +--------+    +===+  #
  #  |ARMORY  |    | W |  #    +--------+
  #  |(AM)    |    | A |  #    |PROVISI-|
  #  +--------+    | T |  #    |ONER    |
  #                | C |  #    |(PV)    |
  #  +---------+   | H |  #    +--------+
  #  |COMMANDER|   | T |  #
  #  |'S OFFICE|   | O |  ####palisade##
  #  |(CO)     |   | W |  p             p
  #  | Halda * |   | E |  p  [earthwork p
  #  +---------+   | R |  p   defenses] p
  #                +===+  p             p
  #  [supply       3 stories,          p
  #   crates]      stone    p          p
  #                         p  [stakes]p
  ####===stone wall===####  p          p
  pppp===PALISADE===pppp    p          p
  p                    p    pppppppppppp
  p  [earthworks]      p
  p  [sharpened stakes] p       ttttttttttttttttt
  p                    p       t  THORNMERE     t
  pppp===SOUTH GATE===pppp     t  TREELINE      t
           |                   t  (dark green,  t
           v                   t   massive      t
     SOUTH ROAD                t   trunks)      t
  (to Thornmere Wilds)        ttttttttttttttttttt
```

**Legend:**
```
#  = Stone fort wall             p  = Wooden palisade
GB = Garrison Barracks           AM = Armory
CO = Commander's Office          IN = Inn (The Border Rest)
PV = Provisioner                 t  = Thornmere treeline
=  = Gate passage                [  ] = Terrain feature
```

### 4.3 Building Directory

| Building | Type | Location | Key NPCs | Services | Notes |
|----------|------|----------|----------|----------|-------|
| Garrison Barracks | Military | Fort interior, NW | Unnamed soldiers | Rest (military beds) | Soldiers discuss border patrols |
| Armory | Shop | Fort interior, W | Unnamed quartermaster | Weapons, armor upgrade | Military-grade equipment; see inventory |
| Commander's Office | Military | Fort interior, SW | Commander Halda | Quest giver, intel | Desk buried in reports; strategic maps on walls |
| Watchtower | Landmark | Fort interior, center | Lookout soldier | Story scene (Edren surveys Wilds) | 3 stories; panoramic view from top |
| The Border Rest Inn | Inn | Outside fort, NE | Unnamed innkeep | Save point, rest, drinks | The only warm space; rough but welcoming |
| Provisioner | Shop | Outside fort, E | Unnamed merchant | Basic supplies | Better stocked than Highcairn; military supply line |

### 4.4 Shop Inventories

#### Armory (Military Quartermaster)

| Item | Price (Act I) | Price (Act II) | Stats Hint | Notes |
|------|--------------|----------------|------------|-------|
| Steel Longsword | 400 | 480 | ATK +14 | Military issue; solid upgrade from iron |
| Soldier's Halberd | 550 | 660 | ATK +18 | Two-handed; garrison standard |
| Composite Shortbow | 450 | 540 | ATK +12, AGI +3 | Ranger-grade; good for Torren |
| Border Mail | 500 | 600 | DEF +12 | Medium armor; the garrison standard |
| Iron Helm | 200 | 240 | DEF +4 | Head slot |
| Tower Shield | 350 | 420 | DEF +6, Block 15% | Heavy shield |

*Act II:* New stock added:

| Item | Price | Stats Hint | Notes |
|------|-------|------------|-------|
| Thornwatch Blade | 800 | ATK +20, +5% vs. beasts | Halda's recommendation |
| Reinforced Border Mail | 900 | DEF +16 | Upgraded version; fresh from the capital |

#### Provisioner

| Item | Price (Act I) | Price (Act II) | Effect | Notes |
|------|--------------|----------------|--------|-------|
| Healing Draught | 50 | 60 | Restore 200 HP | Standard price |
| Mana Tincture | 80 | 95 | Restore 50 MP | Slight markup |
| Antidote | 30 | 35 | Cure Poison | Stocked for Wilds travel |
| Smelling Salts | 40 | 45 | Cure Sleep/Confuse | |
| Phoenix Pinion | 300 | 350 | Revive 25% HP | Military supply |
| Field Rations | 20 | 25 | Restore 75 HP | Military food; better than Aelhart bread |
| Torch (x3 pack) | 35 | 40 | Light source | Bundle deal |

### 4.5 Points of Interest

**Save point:** The Border Rest Inn (bed).

**Treasure chests:**
- Watchtower top floor: 1x Field Map Fragment (reveals a hidden overworld path)
- Behind the Armory (accessible by walking around the building): 1x Soldier's Elixir (restores 500 HP + 50 MP; rare early find)
- Palisade patrol walkway (east section): 1x 200g pouch

**Environmental storytelling:**
- The Thornmere treeline: visible from every screen. Massive dark trunks rising above the palisade, branches reaching over. The Wilds are always watching. The south gate opens directly into that darkness.
- Carradan smoke plumes: visible to the east, beyond the palisade. Closer every visit. In Act I they are distant smudges. In Act II they are distinct columns.
- Halda's reports: the Commander's Office desk is buried in papers, requisition forms, unanswered letters from the capital. A physical manifestation of institutional neglect.
- The flagpole: Valdris banner at full height in Act I. In Act II, it flies at half-mast (foreshadowing the capital's fall).
- Earthwork defenses: new in Act II -- fresh-dug, stakes sharpened. The garrison is preparing for something.
- Act II addition: one section of palisade repaired with lighter-colored fresh timber. The old wood is weathered grey; the new wood is raw and bright. The fort has been tested.

**Secret areas:**
- None. Thornwatch is a military garrison. Secrets here are in dialogue (Halda's intel), not hidden rooms. The honesty of the layout reflects the honesty of the soldiers.

### 4.6 Act-by-Act Changes

#### Act I (Base State)

Functional garrison. Soldiers patrol. Torches on the walls even during the day. The watchtower is manned. The Wilds press in from the south, but the fort holds.

- All areas accessible
- Full shop inventory at base prices
- NPC density: normal military complement (~12-15 soldiers visible)
- Halda offers "Border Patrol" side quest (investigate monster activity)
- Edren surveys the Wilds from the watchtower (story scene)

#### Act II (Reinforced)

The garrison has been probed by Compact forces. Visible changes:

**Map modifications:**
- New earthwork tiles outside the palisade (freshly dug)
- One new hasty watchtower platform (rough-hewn, contrasts with stone main tower)
- Supply crates stacked near the north gate (reinforcements from the capital)
- One palisade section repaired with fresh timber (lighter wood)
- Sharpened stakes in a wider perimeter

**NPC changes:**
- Guard patrols doubled (more soldier sprites on patrol routes)
- A handful of reinforcements in cleaner armor (new arrivals)
- Halda is exhausted. Her dialogue is clipped, urgent.
- Soldiers jump at sounds from the treeline

**Shops:**
- Armory has new stock (Thornwatch Blade, Reinforced Border Mail)
- Provisioner prices rise slightly

**Story notes:**
- Halda reports Compact scouts within bowshot of the walls
- The smoke plumes to the east are closer and more numerous
- The party passes through en route to the diplomatic mission
- Foreshadowing: "If they hit the capital, Thornwatch can't hold alone."

#### Interlude (Not Directly Visitable -- Overrun)

Thornwatch has fallen. The player cannot visit, but NPCs in Valdris Crown reference it: "Thornwatch fell three weeks ago." Commander Halda's fate is unknown.

**Offscreen state (for narrative consistency):**
- Valdris banner torn down. Compact flags fly.
- Palisade breached and repaired with iron plating (Compact engineering)
- Compact supply carts where garrison equipment stood
- The inn is a Compact officers' quarters
- The Armory has been stripped

---

## 5. Greyvale (Fallen Border Town)

### 5.1 City Overview

**Size category:** Small town (falling to village by the time the player visits)
**Approximate dimensions:** 48 x 42 tiles (3 screens wide x 3 screens tall, ~4 screens of explorable content)
**Number of screens/areas:** 4 exterior screens + 2 small interiors
**General layout:** A once-compact mining town arranged around a central crossroads. Stone buildings showing siege damage from multiple occupations. The ley-crystal quarries are visible as exhausted pits on the eastern edge. No intact walls -- whatever fortifications existed have been breached and never repaired. The town has the look of something fought over and then forgotten. Streets are irregular, buildings are patched with mismatched materials (Valdris limestone alongside Compact iron plating).
**Entry/exit points:**
- **West road:** To Valdris Crown via the border road
- **East road:** Toward Carradan territory (the border the town once guarded)
- **North path:** To the quarries (dead end -- exhausted pits)

### 5.2 ASCII City Map

```
      GREYVALE -- Fallen Border Town (48 tiles wide x 42 tiles tall, ~4 screens)

  N
  ^
  |
         qqqqqqqqqqqqqqqqqqqqqqq
         q  EXHAUSTED QUARRIES q
         q  (empty pits, no   q
         q   glow, broken     q
         q   scaffolding)     q
         qqqqqqqqqqqqqqqqqqqqqqq
                  |
           == north path ==
                  |
  +--------+             +--------+
  |COLLAPSED|   [rubble  |ABANDON-|
  |BUILDING |    pile]   |ED COMP-|
  |(ruins)  |            |ACT OUT-|
  +--------+             |POST(AO)|
                         +--------+
  +--------+  ==CROSSROADS==  +--------+
  |GREYVALE|  = [cracked  ] = |TOWN    |
  |TAVERN  |  = [ well   ]  = |HALL    |
  |"THE    |  = [         ] = |(TH)    |
  |QUARRY- |                  |scorched|
  |MAN'S   |   L* (broken)   |walls   |
  |REST"   |                  +--------+
  |(TV)    |
  +--------+  +--------+     +--------+
              |RESIDEN-|     |RESIDEN- |
  [scorch    |CE 1    |     |CE 2    |
   marks on  |(R1)    |     |(R2)    |
   cobbles]  | door * |     | door * |
              +--------+     +--------+
                                        +--------+
  === west road ===  == CROSSROADS ==   |HIDDEN  |
  (to Valdris Crown)                    |CELLAR  |
                                        |ENTRANCE|
              +--------+               |(CL)    |
              |RESIDEN-|               +--------+
              |CE 3    |
              |(R3)    |     === east road ===
              | door * |     (to Carradan border)
              +--------+

  [siege        ]  [pockmarked   ]
  [debris       ]  [wall section ]
```

**Legend:**
```
q  = Quarry pit boundary         TV = Tavern (The Quarryman's Rest)
TH = Town Hall                   AO = Abandoned Compact Outpost
R1-3 = Residences                CL = Hidden Cellar (optional)
L* = Broken ley-lamp post        *  = NPC in doorway (catatonic in Interlude)
[  ] = Environmental detail/damage
```

### 5.3 Building Directory

| Building | Type | Location | Key NPCs | Services | Notes |
|----------|------|----------|----------|----------|-------|
| The Quarryman's Rest | Tavern | West of crossroads | Unnamed barkeep (Act II) | Drinks, rest (no save) | Sign reads "OPEN" but tavern barely functions in Act II; closed in Interlude |
| Town Hall | Government | East of crossroads | Unnamed elder (Act II) | Lore | Scorched walls from Forgewright weapons; border conflict records |
| Abandoned Compact Outpost | Lootable | NE corner | None | Loot: Forgewright schematics, Compact intel | Left behind when the Compact pulled out |
| Residence 1 | Residence | South-center | Unnamed resident | Lore (Act II), catatonic (Interlude) | Door hangs open in Interlude |
| Residence 2 | Residence | South-east | Unnamed resident | Lore (Act II), catatonic (Interlude) | An untouched meal on a table inside |
| Residence 3 | Residence | South-west | Unnamed resident | Lore (Act II), catatonic (Interlude) | Children's toys on the floor; the children are gone |
| Hidden Cellar | Secret | Behind Residence 2 | Valdris loyalist (Act II); terrified survivor (Interlude) | Intel on Compact troop movements (Act II); Pallor Antidote recipe (Interlude) | Entrance obscured by rubble; requires examining a specific wall |
| Collapsed Building | Ruin | NW area | None | Impassable rubble | A building that did not survive the siege |

### 5.4 Shop Inventories

Greyvale has no functioning shops. The economy is dead.

**Act II scavenging:**
- The Abandoned Compact Outpost contains lootable crates:
  - 1x Compact Field Kit (Healing Draught x2, Antidote x1)
  - 1x Forgewright Schematics (key item, used in a Lira side quest)
  - 1x Arcanite Dagger (ATK +10, MAG +6; Compact design, better than anything available in Valdris shops at this point)
  - 200g in Compact currency (auto-converted)

- The Quarryman's Rest barkeep sells two items at desperate prices:
  - Stale Ale: 5g (restores 10 HP; flavor)
  - Waybread: 30g (restores 100 HP; the barkeep baked it himself)

**Interlude scavenging:**
- The Hidden Cellar survivor gives the party 1x Pallor Antidote (cures Despair status) and the recipe (allows crafting at any herbalist).
- A search of Residence 3 yields 1x Child's Toy (key item; can be returned to refugee children in Valdris Crown for a unique dialogue and 1x Guardian Pendant).

### 5.5 Points of Interest

**Save point:** None. Greyvale has no save point. The absence is deliberate -- the player feels the town's desolation through the mechanical loss of safety. The nearest save is Valdris Crown (west) or Thornwatch (if accessible).

**Treasure chests:**
- Abandoned Compact Outpost: see scavenging list above
- Hidden Cellar: 1x Valdris Intelligence Report (key item; details Compact troop positions, useful for a Thornwatch side quest)
- Behind the Collapsed Building rubble (accessible from a narrow gap): 1x Old Miner's Pick (ATK +8; flavor weapon, low stats but sells well)

**Environmental storytelling:**
- The exhausted quarries: empty pits where ley-crystals once glowed. The scaffolding is broken, the equipment rusted. This is ley line depletion made physical -- a wound in the earth that will not heal.
- Scorch marks on cobblestones: Forgewright weapon burns. Blue-white edges, brighter than natural fire damage. The Compact was here.
- Pockmarked wall sections: projectile impacts from conventional siege weapons. Valdris fought back.
- The burned tavern sign: "THE QUARRYMAN'S REST" on a board that swings on one hinge. Half the lettering is charred away.
- The broken ley-lamp: the town's central lamp post, snapped at the base. No one repaired it. No one had reason to.
- Residence interiors tell individual stories: an untouched meal (Residence 2, the family left mid-dinner), children's toys (Residence 3, the children were sent away), a half-packed bag (Residence 1, someone started to leave and then stopped).
- The dog in the street (Interlude): alive but unmoving. Does not respond to interaction. The most disturbing environmental detail in the town.

**Secret areas:**
- Hidden Cellar: behind Residence 2. A rubble pile against the east wall looks impassable, but examining it reveals a narrow gap. Inside: a cramped cellar where a Valdris loyalist hid intelligence about Compact troop movements (Act II). In the Interlude, a different occupant -- a terrified woman who is the only person in Greyvale still capable of speech. She gives the Pallor Antidote and the recipe.

### 5.6 Act-by-Act Changes

#### Act II (War-Damaged)

The player passes through Greyvale on the diplomatic route. The town is already wounded.

**Visual state:**
- Valdris Highlands palette but desaturated -- the "ruined variant" from biomes.md
- Quarries are empty pits with no glow
- Permanent overcast
- Population halved from pre-game state

**Map state:**
- Collapsed Building: impassable rubble in the NW
- Siege damage visible on most structures (scorch marks, pockmarks, cracked walls)
- The Compact Outpost is abandoned but intact (lootable)
- Several buildings have mismatched repair materials (limestone + iron plating)

**NPC state:**
- ~6-8 visible NPCs. Dialogue recounts the border conflict.
- The barkeep is still serving (barely).
- The Town Hall elder keeps records nobody reads.
- No children. "Sent them to the capital."
- A burned tavern sign swings on one hinge.

**Graffiti/signs:**
- Valdris military notices (outdated, peeling)
- Compact territorial markers (removed, defaced, partially scratched away)

#### Interlude (Pallor-Catatonic)

**Major transformation:** Stage 2 Pallor corruption. One of the first places the Pallor visibly manifests on ordinary people.

**Visual changes:**
- Palette heavily muted. The grey of the exhausted quarries has spread to the stone, the road, the sky.
- Warm Valdris limestone is cold and lifeless.
- Grey dust on every surface. A meal on an outdoor table has grey dust settling on it.
- All light sources dead. No ley-lamps, no torches, no hearth fires visible from outside.

**Map changes:**
- No new structural damage. The town simply... stopped. Doors hang open. Nothing has been touched since the residents froze.
- The Compact Outpost is exactly as it was (if already looted, it stays looted).

**NPC changes:**
- Catatonic residents in doorways (Residences 1, 2, 3). Perfectly still sprites. No idle animation. No blinking. Dialogue boxes show "..." or fragmented repetition of Act II lines.
- The barkeep is gone (fled or catatonic elsewhere).
- A dog lies in the street, alive but unmoving.
- The Hidden Cellar has a new occupant: a terrified survivor who can still speak.

**Optional encounter:**
- A Pallor manifestation drifts between the catatonic residents, a grey shape growing slightly larger near each one. It feeds on the town's despair. Defeating it does not cure the residents -- the damage is done. But it stops it from getting worse.

**Graffiti/signs:**
- A single message carved into a door frame: "WE STAYED."
- No other new text. The silence of a town that stopped writing.

---

## Appendix A: Cross-City Comparison

A quick reference showing how the five Valdris settlements feel distinct from each other.

| Aspect | Valdris Crown | Aelhart | Highcairn | Thornwatch | Greyvale |
|--------|--------------|---------|-----------|------------|----------|
| **Size** | 17+ screens | 3 screens | 3+4 screens | 4 screens | 4 screens |
| **Palette variant** | Highland Urban | Highland Farm | Mountain/Alpine | Highland Military | Highland Ruined |
| **Architecture** | Limestone terraces, towers | Wood + thatch cottages | Thick-walled stone monastery | Stone fort + palisade | Damaged limestone + iron patches |
| **Tone** | Grand, declining | Warm, vulnerable | Austere, spiritual | Functional, tense | Wounded, abandoned |
| **Lighting** | Golden afternoon | Dawn (first visit) | Cold alpine bright | Amber torchlit | Overcast, grey |
| **Signature element** | Seven Towers (ley-lamps) | Wheat fields | Highland overlook vista | Thornmere treeline | Exhausted quarry pits |
| **Save point** | Chapel of the Old Pacts | Inn bed | Great Hall hearth | Inn bed | NONE |
| **Has shops** | Yes (5) | Yes (2) | Yes (2) | Yes (2) | No (scavenging only) |
| **Walls** | Full limestone walls | None | None (altitude) | Stone + palisade | Breached, never repaired |
| **Map variants** | 5 (Act I, II, II-post, Int, Epi) | 2 (Act I, Int well snippet) | 3 (Int, III, Epi) | 2 (Act I, II) | 2 (Act II, Int) |

## Appendix B: NPC Placement Summary

Key named NPC locations across all Valdris settlements, by act.

| NPC | Act I Location | Act II Location | Interlude Location |
|-----|---------------|----------------|-------------------|
| King Aldren | Referenced (Crown, Throne Hall) | Crown, Throne Hall | Dead |
| Lord Chancellor Haren | -- | Crown, Council Chambers | Crown, Haren's Estate |
| Dame Cordwyn | Crown, Barracks (background) | Crown, Barracks (active) | Crown, Barracks (commanding remnant) |
| Scholar Aldis | -- | Crown, Royal Library | Crown, Royal Library (obsessing) |
| Mirren | -- | Crown, Royal Library | Crown, Royal Library |
| Bren | Crown, Market Square | Crown, Market Square | Crown, Market Square (alone) |
| Wynn | Crown, South Gate | Crown, South Gate | Crown, South Gate |
| Elara Thane | Crown, Court Mage Tower | Crown, Court Mage Tower | Outskirts (referenced, not visitable) |
| Nella | Crown, Market Square | Crown, Market Square | Crown, Market Square (dried flowers) |
| Renn | Crown, Anchor & Oar | Crown, Anchor & Oar | Crown, Anchor & Oar |
| Osric | -- | Crown, Refugee Quarter | Crown, Refugee Quarter |
| Sgt. Marek | Crown, Barracks | Crown, Barracks | Crown, Barracks (carving Cael's name) |
| Thessa | Crown, Chapel | Crown, Chapel | -- (temple shuttered) |
| Captain Isen | -- | Crown, Harbor Command | Crown, Harbor Command (ferrying refugees) |
| Jorin Ashvale | Border estate (referenced) | Border estate (referenced) | Crown, Court Quarter (dispossessed) |
| Commander Halda | Thornwatch, CO Office | Thornwatch, CO Office | Unknown (Thornwatch fell) |
| Father Aldous | -- | -- | Highcairn, Great Hall |

## Appendix C: Economy Scaling Reference

How prices shift across acts for planning shop balance.

| Act | Multiplier | Reason | Black Market |
|-----|-----------|--------|-------------|
| Act I | 1.0x | Stable economy | Absent |
| Act II | 1.2-1.3x | Trade disrupted, border pressure | Referenced |
| Interlude | 1.5-2.0x | Fractured, scarcity | Active (Renn's contacts, 2.0-2.5x) |
| Act III | N/A | No shops in the Pallor Wastes | N/A |
| Epilogue | 1.1x | New normal, slightly higher than Act I | Absorbed into legitimate commerce |
