# World Dungeons, Mountain Passes & Cave Systems

This document provides detailed dungeon layouts for every explorable dungeon, mountain pass, and cave system in Pendulum of Despair. Each entry includes floor maps, puzzle design, encounter tables, treasure, and environmental hazards. All maps use 16x16 tile grids at SNES-era resolution.

**Design Philosophy:** Every dungeon teaches the player something. Ember Vein teaches how dungeons work. Fenmother's Hollow teaches resource management. The Convergence tests everything at once. The best JRPG dungeons are remembered for their gimmick -- what makes THIS place different from every other corridor. Every dungeon here has one.

**Map Legend (All ASCII Maps):**

| Symbol | Meaning |
|--------|---------|
| `#` | Wall / impassable terrain |
| `.` | Open floor / walkable |
| `E` | Entry point |
| `X` | Exit point |
| `D` | Door (unlocked) |
| `L` | Locked door (requires key or switch) |
| `H` | Hidden door (requires search or puzzle) |
| `>` | One-way door (cannot return) |
| `T` | Treasure chest |
| `S` | Save point |
| `B` | Boss room marker |
| `P` | Puzzle element (switch, plate, lever) |
| `~` | Water (shallow, walkable) |
| `W` | Water (deep, impassable without mechanic) |
| `!` | Encounter zone (random battles active) |
| `*` | Mini-boss location |
| `M` | Mine cart / rail cart station |
| `^` | Stairs up |
| `v` | Stairs down |
| `+` | Intersection / crossroads |
| `@` | NPC / story event trigger |
| `=` | Bridge / platform |
| `%` | Environmental hazard (lava, gas, unstable floor) |
| `o` | Pressure plate |
| `-` | Track / rail |

---

## Table of Contents

1. [Ember Vein](#1-ember-vein)
2. [Fenmother's Hollow](#2-fenmothers-hollow)
3. [Carradan Rail Tunnels](#3-carradan-rail-tunnels)
4. [Axis Tower Interior](#4-axis-tower-interior)
5. [Ley Line Depths](#5-ley-line-depths)
6. [Pallor Wastes](#6-pallor-wastes)
7. [The Convergence](#7-the-convergence)
8. [Archive of Ages](#8-archive-of-ages)
9. [Dreamer's Fault](#9-dreamers-fault)
10. [Dry Well of Aelhart](#10-dry-well-of-aelhart)
11. [Sunken Rig](#11-sunken-rig)
12. [Windshear Peak](#12-windshear-peak)
13. [Mountain Passes](#13-mountain-passes)
14. [Caves and Grottos](#14-caves-and-grottos)

---

## 1. Ember Vein

### Dungeon Overview

- **Floors:** 2 (Upper Mine + Ancient Ruin)
- **Size:** Floor 1: 40x30 tiles. Floor 2: 45x35 tiles.
- **Theme:** Orange-amber crystallized ley energy in dark stone. Carradan mine infrastructure (wooden supports, rail tracks, lanterns) gives way to smooth pre-civilization geometry. Dead miners slumped against walls.
- **Narrative Purpose:** First dungeon. Edren and Cael discover the Pendulum. Lira and Sable join during the escape. Introduces dungeon mechanics, combat, and the Pallor's calling card (faces frozen in despair).
- **Difficulty:** Introductory. Enemies are forgiving. Puzzles are simple. One save point before the boss.
- **Recommended Level:** 3-5
- **Estimated Play Time:** 25-35 minutes

### Puzzle Mechanic: Mine Cart Routing

The upper mine floor has a small rail network with track switches. The player flips levers (P) to redirect mine carts between three stations. Cart A reaches a treasure room. Cart B reaches the stairs down. Cart C is a dead end with a minor encounter (teaching that wrong choices are not fatal, just costly). The puzzle is transparent by design -- the tracks are visible on-screen, and the levers are labeled with directional arrows carved into the stone.

### Floor 1: Upper Mine (40x30)

```
##########E#############################
#........#..!...........#..............#
#........#..............#.....T........#
#..@.....D..............D.............##
#........####.....####..#............##
#........#  #.....#  #..#..........###
####D#####  #..P..#  ####........###
   #......  #.....#     #......###
   #..!...  ##-M--#     #....###
   #......    #---#     #..###
   #..T...    # . #     ####
   ########   #.P.#
              #...#######
              #.........#
    ##########...........#
    #.........+....!.....#
    #...!.....#..........#
    #.........#...T......#
    ####D######..........#
       #......####D#######
       #..S...#  #......#
       #......#  #..!...#
       #......#  #......#
       ####v###  #......#
                 ########
```

**Key Locations (Floor 1):**
- `E` (top): Entry from Ironmouth mine. Wooden supports, Carradan lanterns, tool debris.
- `@` (top-left room): Dead miners -- first story encounter. Faces frozen in despair. Cael comments.
- `M` (center): Mine cart station. Three track switches nearby.
- `P` (center-left): Track switch 1 -- routes cart to treasure room (upper right `T`).
- `P` (center-right): Track switch 2 -- routes cart to stairs down.
- `T` (upper right): Chest -- Carradan Mining Pick (weapon, Edren).
- `T` (mid-left): Chest -- 3x Potion.
- `T` (lower-mid): Chest -- Iron Bracelet (accessory).
- `S` (lower-left): Save point crystal -- glowing amber, embedded in the wall.
- `v` (bottom-left): Stairs down to Floor 2.

**Encounter Zones:** Three zones marked `!`. Encounters are:
- Ley Vermin (crystalline rats, weak, 2-3 per encounter)
- Unstable Crystal (stationary, shatters for area damage, teaches positioning)

### Floor 2: Ancient Ruin (45x35)

```
   ####^####
   #.......#
   #..!....#
   #.......#
   ###D#####
     #.....#############
     #.....#...........#
     #..T..#.....!.....#
     #.....D...........#
     #######+###D###...#
            #.......#..#
      ######D..!....#..#
      #.....#.......####
      #.....#.......#
      #..P..########+########
      #.....#       #.......#
      ######H####   #..!....#
           #....#   #.......#
           #..T.#   ####D####
           ######       #...........#
                        #...........#
                  ######D....@......#
                  #.....#...........#
                  #..S..#.....B.....#
                  #.....#...........#
                  #.....####...#####
                  #.........D.......#
                  #...T.............#
                  #.................#
                  ###################
```

**Key Locations (Floor 2):**
- `^` (top): Stairs from Floor 1. Transition from mine wood to smooth geometric stone.
- The corridors shift from rough mine to pre-civilization ruin. Ember-orange crystals pulse in the walls. Geometric carvings appear.
- `P` (mid-left): Pressure plate puzzle. Step on the plate to open the hidden door `H` to a secret room.
- `H` (mid-left): Hidden door to secret treasure room.
- `T` (secret room): Chest -- Ember Shard (accessory, +5 magic, first magic-boosting item).
- `T` (mid-right upper): Chest -- 2x Antidote.
- `@` (bottom-center): Story trigger -- the central chamber. The Pendulum rests on a stone pedestal. Dead miners surround it. Cutscene: Edren and Cael examine the artifact. Cael is unsettled. The Pendulum is inert but the air feels wrong.
- `S` (bottom-left): Save point before boss.
- `B` (bottom-center): Boss arena -- circular chamber with geometric floor patterns.
- `T` (bottom passage): Chest behind boss -- Vein Guardian's Core (crafting material, sells for good gold).

**Boss: Vein Guardian**
A crystalline construct that awakens when the Pendulum is disturbed. Geometric, angular, glowing ember-orange. Slow but hits hard. Teaches the player to use defend and healing. Has one telegraphed charge attack (the floor glows before impact). 3000 HP.

After the boss, Carradan soldiers arrive at the entrance above. The party flees through a back passage (one-way exit `>` that opens behind the boss room), emerging outside into the Wilds where Lira and Sable are encountered during the escape.

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Ley Vermin | Crystalline rats with ember-orange eyes. Fast, weak, attack in groups of 2-4. | Both floors |
| Unstable Crystal | Floating crystal formation. Shatters when defeated, dealing area damage. Teaches "kill it fast or move away." | Both floors |
| Mine Shade | Ghostly silhouette of a dead miner. Casts a weak despair debuff (attack down). Foreshadows the Pallor. | Floor 2 only |
| **Vein Guardian** (Boss) | Geometric crystal construct. Slow charge attacks, area slam. Telegraphs with floor glow. | Floor 2, boss room |

### Treasure/Loot

| Item | Location | Type |
|------|----------|------|
| Carradan Mining Pick | Floor 1, cart-accessible room | Weapon (Edren) |
| 3x Potion | Floor 1, side room | Consumable |
| Iron Bracelet | Floor 1, east room | Accessory (+3 DEF) |
| 2x Antidote | Floor 2, east passage | Consumable |
| Ember Shard | Floor 2, secret room (hidden door) | Accessory (+5 MAG) |
| Vein Guardian's Core | Floor 2, behind boss | Crafting / sell item |

### Environmental Hazards

- **Unstable mine supports:** Two wooden supports in Floor 1 can collapse if the player walks under them after triggering a nearby encounter (cosmetic shake, no damage -- teaches awareness).
- **Crystal shards on floor:** Glowing orange floor patches in Floor 2 deal 1 HP chip damage when stepped on. Teaches the player to look at floor tiles.
- No lethal hazards. This is the tutorial dungeon.

---

## 2. Fenmother's Hollow

### Dungeon Overview

- **Floors:** 3 (Flooded Entry + Submerged Temple + Fenmother's Sanctum)
- **Size:** Floor 1: 45x30 tiles. Floor 2: 50x35 tiles. Floor 3: 35x25 tiles.
- **Theme:** Thornmere Wetlands submerged ruin. Dark water, ancient spirit-totems, vaulted stone ceilings with trapped air pockets. Walls carved with serpentine motifs depicting the Fenmother. Discolored water and dead aquatic life show ley-line poisoning from Compact extraction upriver.
- **Narrative Purpose:** Mid-game dungeon. Clearing it earns the Duskfen alliance. The corrupted Fenmother demonstrates that Compact exploitation has consequences that reach the deepest parts of the Wilds. First encounter with water-level puzzle mechanics.
- **Difficulty:** Moderate. Water navigation adds complexity. Resource management matters.
- **Recommended Level:** 12-15
- **Estimated Play Time:** 45-60 minutes

### Puzzle Mechanic: Water Level Control

Three stone wheels (P) control the water level across the dungeon. Each wheel has two positions: HIGH and LOW. Different combinations of wheel positions flood or drain different sections, opening and closing paths. The key insight: you cannot access all areas at one water level. The player must raise the water to reach a high platform, then lower it to access a drained corridor, then raise it again to float across a gap. A stone tablet near the first wheel depicts the three wheels and their effects pictographically -- a hint, not a solution.

**Water Level States:**
- State A (all LOW): Entry corridors open, mid-level passages flooded, boss path blocked.
- State B (Wheel 1 HIGH): Mid-level drained, upper platforms accessible via water bridge, east wing open.
- State C (Wheels 1+2 HIGH): Boss path opens, but entry corridors flood (one-way commitment until Wheel 3 is found).
- State D (All HIGH): Secret room accessible via high-water float.

### Floor 1: Flooded Entry (45x30)

```
#####E##############################
#....~..~...#WWW#..................#
#....~..~...#WWW#........!.........#
#....~..~...DWWWD..................#
#....~..~...#WWW####D##............#
#.S..~..~...#      #..#....T......#
#....~..~...#      #..#...........#
######+######      #..###D#########
     #~~....#      #..........#
     #~~.P..#      #...!......#
     #~~....#      #..........#
     ####D###      ####v#######
        #...............#
        #......!........#
        #...............#
        #.......T.......#
        #...............#
        ##########D######
                 #......#
                 #..~...#
                 #..~.P.#
                 #..~...#
                 ####v###
```

**Key Locations (Floor 1):**
- `E` (top): Entry -- stone staircase descending into murky water. Torren comments on the age of the carvings.
- `S` (left): Save point -- spirit-totem embedded in the wall, pulsing faintly.
- `W` (top-center): Deep water barrier. Impassable until Wheel 1 is set to HIGH (water drains here, fills elsewhere).
- `P` (mid-left): Water Wheel 1. Stone wheel mechanism with two positions.
- `P` (bottom-right): Water Wheel 2. Controls the mid-level flooding.
- `T` (top-right): Chest -- Marsh Cloak (accessory, water resistance).
- `T` (mid-bottom): Chest -- 3x Spirit Tonic (MP restore).
- `v` (mid-right): Stairs down to Floor 2 (accessible after Wheel 1 set).
- `v` (bottom): Stairs down to Floor 2 east wing.

### Floor 2: Submerged Temple (50x35)

```
##########^###############################
#..........#.....WWWWW#.................#
#....!.....D.....WWWWW#........!........#
#..........#.....WWWWW#.................#
#..........######WWWWW####D#############
#..T.......#    #WWWWW#   #...........#
############    #WWWWW#   #.....*.....#
          ######DWWWWWD   #...........#
          #.........~..#   ####D########
     ^#####....!....~..#       #......#
     #.....#........~..#       #..P...#
     #.....D........~..#       #......#
     #.....#.....T..~..#       ########
     #.....############
     #..S..#
     #.....#
     ###v###
```

**Key Locations (Floor 2):**
- `^` (top, left): Stairs from Floor 1 main path.
- `^` (left): Stairs from Floor 1 east wing.
- `W` (center): Large submerged section. When Wheels 1+2 are HIGH, this drains to reveal a passage.
- `*` (right): Mini-boss -- Drowned Sentinel. A waterlogged stone guardian covered in barnacles and dead marsh growth.
- `P` (far right): Water Wheel 3. Final wheel. Setting all three to HIGH opens the secret room and the boss path.
- `T` (left): Chest -- Fenmother's Scale (accessory, +10 MAG DEF, water element resist).
- `T` (center-right): Chest -- Spirit-Bound Spear (weapon, Torren).
- `S` (bottom-left): Save point before boss descent.
- `v` (bottom): Stairs down to Floor 3 (Fenmother's Sanctum). Only accessible when Wheels 1+2 are HIGH.

**Secret Room:** When all three wheels are HIGH, a hidden alcove in the northwest corner of the submerged section is revealed (water rises to create a walkable surface over a gap). Contains: Ancient Totem (accessory, boosts spirit magic, unique).

### Floor 3: Fenmother's Sanctum (35x25)

```
      ####^####
      #.......#
      #...!...#
      #.......#
      ###D#####
        #.....#
   ######.....######
   #................#
   #....!...........#
   #................#
   ####.........#####
      #....@....#
      #.........#
   ####.........####
   #...............#
   #.......B.......#
   #...............#
   #...............#
   #.....S.........#
   #...............#
   #####.....######
       #..T..#
       #.....#
       ###X###
```

**Key Locations (Floor 3):**
- `^` (top): Descent into the Fenmother's chamber. The air pressure changes. Water drips from the ceiling.
- `@` (center): Story trigger -- the party sees the Fenmother for the first time. A vast serpentine water spirit coiled around a ley-line node, visibly corrupted -- her translucent body streaked with dark, oily discoloration from ley-line poisoning.
- `S` (bottom-center): Save point directly before the boss arena.
- `B` (center-bottom): Boss arena -- circular sanctum with the ley-line node at center. Shallow water covers the floor. The Fenmother attacks from the water, surfacing and diving.
- `T` (bottom): Post-boss chest -- Fenmother's Blessing (key item, presented to Caden to secure the alliance).
- `X` (bottom): Exit -- a spirit-path opens after the cleansing, returning the party directly to Duskfen.

### Boss: The Corrupted Fenmother

A vast water serpent with a translucent body showing the dark ley-corruption within. She surfaces to strike with tail sweeps and water jets, then dives (untargetable). When submerged, poisoned water pools appear on the arena floor (stepping on them deals poison damage). The party must attack during surface phases and avoid pools during dive phases. At 50% HP, she summons two Spawn -- smaller serpents that must be killed to force her to surface again.

The party does NOT kill her. At 0 HP, a cleansing sequence triggers: Torren performs a spirit-speaking ritual while the party defends him from Spawn waves (3 rounds). Success cleanses the corruption. The Fenmother returns to dormancy. Caden arrives to perform a binding that keeps her safe. 8,000 HP.

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Marsh Serpent | Small water snake, fast, poison bite. 2-3 per encounter. | All floors |
| Drowned Bones | Skeletal remains animated by wild ley energy. Slow, hits hard. | Floor 1-2 |
| Ley Jellyfish | Floating translucent creature. Casts paralysis. Weak to physical. | Floor 2-3 |
| Polluted Elemental | Water elemental with dark discoloration. Area water attack. | Floor 2-3 |
| **Drowned Sentinel** (Mini-boss) | Stone guardian covered in barnacles. Heavy physical, water area attack. 4,000 HP. | Floor 2 |
| **Corrupted Fenmother** (Boss) | Water serpent, dive/surface pattern. Spawns adds at 50%. Cleansed, not killed. 8,000 HP. | Floor 3 |

### Treasure/Loot

| Item | Location | Type |
|------|----------|------|
| Marsh Cloak | Floor 1 chest | Accessory (water resist) |
| 3x Spirit Tonic | Floor 1 chest | Consumable (MP restore) |
| Fenmother's Scale | Floor 2 chest | Accessory (+10 MAG DEF) |
| Spirit-Bound Spear | Floor 2 chest | Weapon (Torren) |
| Ancient Totem | Floor 2 secret room | Accessory (spirit magic boost, unique) |
| Fenmother's Blessing | Floor 3 post-boss | Key item (alliance) |

### Environmental Hazards

- **Poisoned water patches:** Dark-tinted floor tiles deal poison status on contact. Present on Floors 2-3.
- **Rising water:** When water wheels are in certain states, corridors flood over 10 seconds. The player must move quickly or be pushed back to the last dry room.
- **Collapsing ceiling:** Two spots on Floor 1 where the ancient stone is crumbling. Walking under them triggers falling debris (minor damage, cosmetic dust cloud).
- **Air pocket timer:** In flooded corridors on Floor 2, the party has a breath timer (30 seconds) between air pockets. Running out triggers forced retreat, not death. Teaches urgency without punishment.

---

## 3. Carradan Rail Tunnels

### Dungeon Overview

- **Floors:** 3 sections (Junction Hub + East Tunnel + West Tunnel, connected by rail carts)
- **Size:** Hub: 35x25 tiles. East: 40x30 tiles. West: 40x30 tiles.
- **Theme:** Carradan Industrial underground. Iron-braced stone, Arcanite lamps (flickering between white and grey), rail tracks, steam vents. Boring engine machinery partially reactivated. Pallor nests in the dark -- clusters of grey corruption growing on the walls like fungal colonies.
- **Narrative Purpose:** Interlude dungeon. Sable and Lira use the corrupted tunnels to infiltrate Corrund. The tunnels show the Compact's infrastructure breaking down -- machines running without operators, lights switching to Pallor grey, workers who never came back.
- **Difficulty:** Moderate-hard. Environmental hazards are frequent. Rail cart navigation requires attention.
- **Recommended Level:** 18-22
- **Estimated Play Time:** 40-50 minutes

### Puzzle Mechanic: Power Routing

The tunnels run on a steam/Arcanite power grid. Three power junctions (P) each route energy to different subsystems. The player must redirect power to open locked blast doors while keeping enough power flowing to the rail carts (needed for traversal) and the ventilation system (needed to clear poison gas from certain corridors). The puzzle: you cannot power everything at once. Each junction has three settings, and the correct combination powers the blast door to the Corrund exit while maintaining one cart line and venting gas from the critical path.

**Power States:**
- Junction A: Rail Cart East / Blast Door 1 / Ventilation North
- Junction B: Rail Cart West / Blast Door 2 / Ventilation South
- Junction C: Lighting (reveals hidden passage) / Emergency Rail / Blast Door 3

The solution path: A=Ventilation, B=Blast Door 2, C=Lighting (reveals shortcut to Blast Door 2, which opens the exit). The rail carts are offline in this configuration, so the player must walk the final stretch.

### Junction Hub (35x25)

```
###########E########################
#..........#.......#...............#
#...S......#...!...#.......T.......#
#..........D.......D...............#
#..........#.......#...............#
####D#######...P...##########D#####
   #.......#.......#        #.....#
   #...M---+---M...#        #..!..#
   #.......#.......#        #.....#
   #..!....#.......#        ##L####
   #.......####D####           #..#
   ####D####   #....%..%..#   #..#
      #.....#  #....%..%..#   #..#
      #..P..#  #...........#  #..#
      #.....#  #.....T.....#  #.T#
      #.....#  #############  ####
      ##M####
       #---# (to East Tunnel)
```

**Key Locations:**
- `E` (top): Entry from Compact border. The tunnel mouth is partially collapsed -- Sable squeezes through.
- `S` (top-left): Save point -- a functioning Arcanite lamp cluster that hums with stable energy.
- `M` (center): Rail cart stations. Two carts available -- one goes East, one goes West.
- `P` (top-center): Junction A power routing console.
- `P` (bottom-left): Junction B power routing console.
- `L` (right): Locked blast door. Requires Junction B set to "Blast Door 2."
- `%` (center-right): Steam vent corridor. Deals periodic fire damage until ventilation is powered.
- `T` (top-right): Chest -- Forgewright Goggles (accessory, reveals hidden items in Compact dungeons).
- `T` (right, behind blast door): Chest -- Arcanite Wrench (weapon, Lira).
- `T` (far right): Chest -- 3x Smelling Salts.

### East Tunnel (40x30)

```
##M##################################
#---.........#.......#..............#
#....!.......#..%....#......T.......#
#............D..%....D..............#
#............#..%....#..............#
######D######...%....####D##########
     #......#..........#   #.......#
     #..!...#..........#   #...!...#
     #......####D#######   #.......#
     #......#  #.......#   ####D####
     ####D###  #...P...#      #....#
        #....# #.......#      #.S..#
        #.T..# ####H####      #....#
        #....#    #....#       #....#
        ######    #..T.#       ##X##
                  ######
```

**Key Locations:**
- `M` (top-left): Rail cart arrival from Hub.
- `%` (center): Gas-filled corridor. Cleared by routing Junction A to Ventilation.
- `P` (center-right): Junction C power routing console.
- `H` (center-right): Hidden door. Only visible when Junction C is set to "Lighting." Leads to a secret maintenance room.
- `T` (mid-left): Chest -- 4x Potion.
- `T` (secret room): Chest -- Boring Engine Schematic (key item, unlocks Lira's crafting recipe for a powerful weapon component).
- `S` (bottom-right): Save point before the exit approach.
- `X` (bottom-right): Exit toward Corrund Undercroft. Opens when Blast Door 2 is powered.

### West Tunnel (40x30)

```
####M################################
#---..........#............#........#
#.....!.......#....!.......#...T....#
#.............D............D........#
#.............#............#........#
#####D#########............##D######
    #.........####D#########  #....#
    #....%....#   #........#  #.*..#
    #....%....#   #...!....#  #....#
    #....%....#   #........#  ####D#
    #.........#   #........#     #.#
    ####D######   ####D#####     #.#
       #......#      #.....#     #.#
       #..!...#      #..S..#     #T#
       #......#      #.....#     ###
       #..T...#      ###^###
       ########
```

**Key Locations:**
- `M` (top-left): Rail cart arrival from Hub.
- `%` (left): Unstable tunnel section. Boring engine has carved random passages. The walls shift -- cosmetic shake effects, minor debris damage.
- `*` (right): Mini-boss -- Corrupted Boring Engine. A Forgewright machine running on Pallor energy, drilling mindlessly. Must be shut down.
- `T` (top-right): Chest -- 2x Pallor Ward (consumable, prevents Pallor status for one battle).
- `T` (bottom-left): Chest -- Compact Officer's Logbook (lore item, details disappearances).
- `T` (far right): Chest -- Steam-Powered Gauntlet (weapon, Edren).
- `S` (bottom-center): Save point.
- `^` (bottom): Stairs up -- connects to the Axis Tower Undercroft entrance (if doing both dungeons in sequence).

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Forge Phantom | Grey silhouette of a Compact worker. Phases through walls. Despair debuff attack. | All sections |
| Rail Sentry | Malfunctioning automated turret on a rail cart. Fires bolts. Stays on tracks. | Hub, East |
| Pallor Nest | Immobile grey mass on the wall. Spawns 1-2 Grey Mites per turn until destroyed. | All sections |
| Grey Mite | Tiny grey creature. Weak individually, dangerous in numbers. Drains MP. | Spawned by Nests |
| Steam Elemental | Living steam from broken vents. Fire damage, can blind. | Hub, West |
| **Corrupted Boring Engine** (Mini-boss) | Massive drill machine. Charges in straight lines, area slam. Disable by hitting the exposed Arcanite core (back attack bonus). 6,000 HP. | West Tunnel |

### Treasure/Loot

| Item | Location | Type |
|------|----------|------|
| Forgewright Goggles | Hub chest | Accessory (reveals hidden items) |
| Arcanite Wrench | Hub, behind blast door | Weapon (Lira) |
| 3x Smelling Salts | Hub chest | Consumable |
| 4x Potion | East Tunnel chest | Consumable |
| Boring Engine Schematic | East Tunnel secret room | Key item (crafting) |
| 2x Pallor Ward | West Tunnel chest | Consumable |
| Compact Officer's Logbook | West Tunnel chest | Lore item |
| Steam-Powered Gauntlet | West Tunnel chest | Weapon (Edren) |

### Environmental Hazards

- **Steam vents:** Periodic bursts of steam from broken pipes. Deal fire damage (5% HP) and can inflict Blind. Avoidable by timing movement between bursts.
- **Poison gas corridors:** Green-tinted air in sealed sections. Deal poison damage per step until ventilation is restored via power routing.
- **Unstable floors:** In the West Tunnel boring engine section, floor tiles crack and collapse if the player stands still too long. Forces constant movement.
- **Pallor corruption zones:** Grey-tinted areas where Pallor nests grow. Being in these zones applies a slow Despair debuff (attack and magic down) that clears when leaving the zone.

---

## 4. Axis Tower Interior

### Dungeon Overview

- **Floors:** 5 (Undercroft Access + Engine Level + Archive Floor + Command Floor + Kole's Chamber)
- **Size:** Each floor: 30x25 tiles (compact vertical design -- the tower is narrow, not sprawling).
- **Theme:** Carradan Industrial at its peak -- gleaming brass, glass panels, rotating gears, conduit pipes. The Forgewright engine dominates the center of every floor as a massive vertical shaft. Higher floors transition from industrial to military to Pallor-corrupted. Kole's chamber is grey and cold.
- **Narrative Purpose:** Interlude infiltration dungeon. Sable and Lira ascend the tower, gather intelligence, and confront General Kole. The dungeon showcases Sable's stealth skills and Lira's Forgewright knowledge. Recovering the map to Cael's location is the critical reward.
- **Difficulty:** Hard. Stealth mechanics add tension. Alarm system raises encounter rates if triggered.
- **Recommended Level:** 22-26
- **Estimated Play Time:** 50-65 minutes

### Puzzle Mechanic: Stealth / Alarm System

Each floor has patrol routes (marked with dotted paths on the map). Guards walk set patterns. If the party enters a guard's vision cone (3 tiles in their facing direction), an alarm triggers:
- **Alert Level 1:** Encounter rate doubles on current floor.
- **Alert Level 2:** Locked doors require combat to breach instead of keys.
- **Alert Level 3:** Reinforcement squad (hard encounter) attacks immediately.

Sable can disable alarm panels (P) on each floor to reset the alert level. Lira can disable Forgewright sensor traps (mechanical tripwires that detect movement). The player can also avoid guards entirely with careful timing. A perfect stealth run (no alarms) unlocks a bonus chest on the final floor.

### Floor 1: Undercroft Access (30x25)

```
#####E#######################
#.........#.................#
#...S.....#......!..........#
#.........D.................#
#.........#.................#
####D######.......P.........#
   #......#.................#
   #..!...####D#############
   #......#  #............#
   #..T...#  #....!.......#
   ######D#  #............#
        #..# ####D#########
        #..#    #.........#
        #.P#    #.........#
        #..#    #....^....#
        ####    ###########
```

**Key Locations:**
- `E` (top): Entry from Corrund Undercroft or Rail Tunnels.
- `S` (top-left): Save point.
- `P` (mid-right): Alarm panel 1. Disabling prevents guard alerts on this floor.
- `P` (bottom-left): Forgewright sensor console. Lira can deactivate sensors on Floor 2.
- `T` (mid-left): Chest -- Undercroft Key (opens locked doors on Floor 2).
- `^` (bottom-right): Stairs up to Floor 2.

### Floor 2: Engine Level (30x25)

```
####^########################
#....#  GGGGG  #............#
#....#  G###G  #.....!......#
#....D  G#.#G  D............#
#....#  G###G  #............#
##D###  GGGGG  ######D######
 #..#          #    #......#
 #..#  ########D    #..T...#
 #.P#  #......#     #......#
 #..#  #..!...#     ##L#####
 ##D#  #......#       #....#
  #.#  ####D###       #..P.#
  #.#     #....#      #....#
  #.#     #.S..#      ##^##
  #T#     #....#
  ###     ######
```

Notes: `G` represents the Forgewright engine shaft -- a massive rotating assembly visible through brass grating. It hums loudly, masking footstep sounds (stealth is easier near it). Guards patrol the corridors around the engine in a clockwise pattern.

**Key Locations:**
- `^` (top-left): Stairs from Floor 1.
- `G` (center): Engine shaft. Impassable but provides noise cover.
- `P` (left): Alarm panel 2.
- `P` (right): Sensor console for Floor 3.
- `L` (right): Locked door. Opened by Undercroft Key.
- `T` (right): Chest -- Engine Coolant (consumable, heals 50% HP to one ally).
- `T` (bottom-left): Chest -- Infiltrator's Cloak (accessory, reduces encounter rate).
- `S` (bottom-center): Save point.
- `^` (bottom-right): Stairs up to Floor 3.

### Floor 3: Archive Floor (30x25)

```
####^####################
#......#................#
#..!...#......!.........#
#......D................#
#......#......@.........#
####D###.........########
   #....#........#
   #....####D#####
   #.P..#  #.....#
   #....#  #..T..#
   ##D###  #.....#
    #...#  ###H###
    #.!.#     #..#
    #...#     #T.#
    ##D##     ####
     #..#
     #.S#
     #..#
     #^.#
     ####
```

**Key Locations:**
- `^` (top-left): Stairs from Floor 2.
- `@` (top-right): Intelligence archives. Cutscene: Lira finds Project Pendulum documents. The Compact knew what the Pendulum was and authorized excavation anyway.
- `P` (left): Alarm panel 3.
- `H` (right): Hidden door. Lira can detect the Forgewright mechanism. Leads to a classified archive room.
- `T` (right, main): Chest -- 3x Arcanite Ingot (crafting material).
- `T` (right, secret): Chest -- Project Pendulum Dossier (lore item, fills in Cael's backstory).
- `S` (bottom): Save point before Command Floor.
- `^` (bottom): Stairs up to Floor 4.

### Floor 4: Command Floor (30x25)

```
####^################
#.......#..........#
#...!...#....!.....#
#.......D..........#
#.......#..........#
####D####..........#
   #.....##D########
   #..P..# #......#
   #.....# #..!...#
   ###D### #......#
     #...# ####D###
     #.@.#    #...#
     #...#    #.S.#
     ##D##    #...#
      #..#    ##^##
      #..#
      #T.#
      ####
```

**Key Locations:**
- `^` (top-left): Stairs from Archive Floor.
- `P` (left): Final alarm panel. If all four panels were disabled without triggering an alarm, a hidden compartment opens here with a bonus item.
- `@` (center-left): Commissar Brant encounter. He opens the rear gate access. Dialogue scene about cowardice and survival.
- `T` (bottom-left): Chest -- Commander's Blade (weapon, Edren, strong upgrade). OR if stealth was perfect: Commander's Blade + Stealth Master Badge (accessory, first strike guaranteed).
- `S` (right): Save point before Kole.
- `^` (right): Stairs up to Kole's Chamber.

### Floor 5: Ironmark Tunnel Access (30x25)

The Axis Tower's lowest sublevel connects to Ironmark Citadel via an underground tunnel. The party reaches Ironmark Citadel through this passage -- the Axis Tower is the infiltration route, but General Kole awaits in the Command Chamber at Ironmark (see dungeons-city.md, Ironmark Citadel Dungeons).

```
      ####^####
      #.......#
      #.......#
      #..@....#
      ###D#####
        #.....#
   ######.....######
   #......!.........#
   #................#
   #......!.........#
   ####.........#####
      #.........#
      #....S....#
      #.........#
      #.........#
      ###.....###
         #...#
         #.X.#  --> IRONMARK CITADEL (tunnel)
         #####
```

**Key Locations:**
- `^` (top): Stairs from Command Floor.
- `@` (center-top): Story trigger -- Lira identifies the tunnel route to Ironmark Citadel from Compact blueprints found on Floor 3.
- `S` (center): Save point before entering the Ironmark tunnel.
- `!` (corridors): Pallor Soldier patrols in the connecting passage.
- `X` (bottom): Tunnel exit leading to Ironmark Citadel. The Kole boss fight takes place in the Ironmark Command Chamber (see dungeons-city.md).

### Boss: General Vassar Kole (at Ironmark Citadel)

The Kole boss fight occurs in Ironmark Citadel's Command Chamber, reached via the Floor 5 tunnel. See dungeons-city.md for the full Ironmark Citadel dungeon layout including the Command Chamber arena. A military commander in Pallor-enhanced Forgewright armor. He fights with disciplined precision -- not wild, not monstrous, but calculated. Phase 1 (100-50% HP): Standard attacks with Arcanite sword, plus a command ability that summons 2 Pallor Soldiers. Phase 2 (50-0%): He channels Ironmark's Pallor conduits, gaining area attacks (Grey Shockwave) and a despair aura that applies Despair debuff (all stats down) to the party each turn. Destroying the two conduit crystals on the arena's edges removes the aura. 12,000 HP.

When defeated, his soldiers collapse. Brant watches silently.

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Compact Guard | Disciplined soldier. Attacks in pairs, covers each other. | All floors |
| Forgewright Sentry | Automated turret. Scans in a cone. High damage, low HP. | Floors 2-3 |
| Pallor Soldier | Grey-eyed Compact soldier running on Pallor energy. Hits hard, no self-preservation. | Floors 4-5 (and Ironmark tunnel) |
| Arcanite Hound | Mechanical dog construct. Fast, lunges for back attacks. | Floors 1-2 |
| **General Kole** (Boss) | Pallor-enhanced commander. Summons soldiers, channels conduits. 12,000 HP. | Ironmark Citadel Command Chamber (via Floor 5 tunnel) |

### Treasure/Loot

| Item | Location | Type |
|------|----------|------|
| Undercroft Key | Floor 1 | Key item |
| Engine Coolant | Floor 2 | Consumable |
| Infiltrator's Cloak | Floor 2 | Accessory (encounter rate down) |
| 3x Arcanite Ingot | Floor 3 | Crafting material |
| Project Pendulum Dossier | Floor 3 secret | Lore item |
| Commander's Blade | Floor 4 | Weapon (Edren) |
| Stealth Master Badge | Floor 4 (perfect stealth only) | Accessory (first strike) |
| Map to the Convergence | Ironmark Command Chamber (post-boss) | Key item (story) |
| Kole's Epaulettes | Ironmark Command Chamber (post-boss) | Accessory (+15 DEF, +10 MAG DEF) |

### Environmental Hazards

- **Forgewright sensor traps:** Invisible tripwires that trigger alarms. Lira can detect and disable them.
- **Steam conduit bursts:** On the Engine Level, periodic steam releases deal fire damage in narrow corridors.
- **Pallor conduit zones:** On Floors 4-5, grey-lit corridors apply Despair debuff while inside. Move through quickly.
- **Elevator shaft:** On Floor 2, the elevator shaft is exposed. Falling deals significant damage. A railing prevents accidental falls; only a failed stealth sequence near the shaft causes it.

---

## 5. Ley Line Depths

### Dungeon Overview

- **Floors:** 3 (Extraction Works + Natural Caverns + The Deep Vein)
- **Size:** Floor 1: 40x30 tiles. Floor 2: 50x35 tiles. Floor 3: 45x30 tiles.
- **Theme:** Transition from Compact industrial extraction (scaffolding, pumps, pipes) to raw natural wonder (ley energy rivers flowing through dark stone, shifting blue-white-amber light) to ancient pre-civilization architecture (geometric carvings, sealed passages, the Pendulum symbol). The deeper you go, the older the world gets.
- **Narrative Purpose:** Optional dungeon in Act II. The best magic equipment before the Interlude. Ancient carvings connect to the Ember Vein and foreshadow the Archive of Ages. The sealed door at the bottom is an unanswered mystery.
- **Difficulty:** Hard. Magical burn timer adds pressure. Enemies are tough.
- **Recommended Level:** 16-20
- **Estimated Play Time:** 55-70 minutes

### Puzzle Mechanic: Ley Energy Channeling

Ley energy rivers flow through the caverns in visible channels. The player can redirect energy flow using ancient valve mechanisms (pre-civilization, not Compact). Redirecting a flow to a dead crystal node activates it, opening sealed passages. Redirecting flow away from a node deactivates whatever it powered. Three nodes, three valves, six possible configurations. The correct path requires powering nodes 1 and 3 while leaving node 2 unpowered (node 2 powers a trap corridor). A mural near the first valve depicts the correct configuration in abstract pictographs.

### Floor 1: Extraction Works (40x30)

```
##########E############################
#..........#..........#...............#
#....S.....#....!.....#.......T.......#
#..........D..........D...............#
#..........#..........#...............#
####D######..........######D##########
   #......#..........#    #..........#
   #..!...#..........#    #....!.....#
   #......####D#######    #..........#
   #..T...#  #.......#    ####D######
   ########  #...P...#       #......#
             #.......#       #..!...#
             ####v####       #......#
                             #..T...#
                             ########
```

**Key Locations:**
- `E` (top): Entry from Millhaven extraction pit. Compact scaffolding, rattling pipes, abandoned worker equipment.
- `S` (top-left): Save point.
- `P` (center): Compact pump control. Can be shut down to stop extraction temporarily, causing the ley rivers below to flow more brightly (cosmetic, but NPCs react).
- `T` (mid-left): Chest -- Compact Hardhat (accessory, falling debris resistance).
- `T` (bottom-right): Chest -- Arcanite Drill Bit (weapon, Lira).
- `v` (center-bottom): Ladder down to Floor 2. The Compact scaffolding ends here. Below is untouched cave.

### Floor 2: Natural Caverns (50x35)

```
###########v###################################
#..............#LLLLL#.......................#
#......!.......#LLLLL#..........!............#
#..............DLLLLL D......................#
#..............#LLLLL#.......................#
####D##########LLLLL####D###################
   #..........#LLLLL#     #................#
   #....P.....#LLLLL#     #......!.........#
   #..........#LLLLL#     #................#
   #..........##DDD##     #....*...........#
   ####D#######  #..#     #................#
      #........# #..#     ########D#########
      #...!....# #.P#            #........#
      #........# #..#            #....S...#
      #...T....# ####            #........#
      ##H#######                 ####v#####
       #....#
       #.T..#
       ######
```

Notes: `L` represents ley energy rivers -- glowing blue-white channels flowing through the stone. They are beautiful and dangerous. Standing adjacent heals 1 MP per step; standing ON them triggers magical burn (escalating damage).

**Key Locations:**
- `v` (top): Descent from Floor 1.
- `L` (center): Ley energy river. Flows north to south through the cavern. Illuminates everything in blue-white.
- `P` (left): Ley valve 1. Redirects the eastern branch.
- `P` (right): Ley valve 2. Redirects the western branch.
- `*` (right): Mini-boss -- Ley Colossus. A living energy construct, humanoid shaped, crackling with power.
- `H` (bottom-left): Hidden passage. Revealed by directing ley flow to node 1 (left valve). Leads to secret room.
- `T` (bottom-left main): Chest -- Ley-Touched Ring (accessory, +15 MAG).
- `T` (bottom-left secret): Chest -- Prismatic Shard (best magic accessory in Act II, +20 MAG, +10 MAG DEF).
- `S` (bottom-right): Save point before the Deep Vein.
- `v` (bottom-right): Descent to Floor 3.

### Floor 3: The Deep Vein (45x30)

```
########v####################################
#............#LLLLL#........................#
#......!.....#LLLLL#..........!.............#
#............DLLLLL D.......................#
#............#LLLLL#........................#
#............#LLLLL#........................#
####D########LLLLL#########D################
   #.........#LLLLL#       #...............#
   #....P....#LLLLL#       #.......!.......#
   #.........#LLLLL#       #...............#
   ####D######LLLLL####D####...............#
      #.......DLLLLL D    #.....T..........#
      #...!...#LLLLL#     #####D############
      #.......#LLLLL#        #.............#
      #..T....######D#       #......@......#
      ########     #.#       #.............#
                   #S#       #.............#
                   #.#       ###############
                   #.#
                   #.##########
                   #..........#
                   #....=.....#
                   #..........#
                   ############
```

**Key Locations:**
- `v` (top): Descent from Floor 2. The geometric carvings begin here. The same patterns as the Ember Vein, but vaster.
- `L` (center): The deepest ley river. Brighter, more intense. Multiple channels converging.
- `P` (left): Ley valve 3. Final valve controls access to the sealed door passage.
- `T` (bottom-left): Chest -- Deep Vein Crystal (weapon material, used to forge Maren's best staff).
- `T` (right): Chest -- Ley-Born Armor (armor, best magic defense in Act II).
- `@` (right): The sealed door. Massive stone door bearing the Pendulum symbol. Cannot be opened. Maren comments on its significance if in the party. Examining it grants the Sealed Door Rubbing (lore item).
- `S` (bottom-center): Save point.
- `=` (bottom): A narrow stone bridge over a ley energy chasm. Leads to a dead-end observation platform where the player can look down into the depths -- the ley rivers converge into a single blinding point far below. Cosmetic, but awe-inspiring.

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Extraction Drone | Compact automated mining bot gone haywire. Drills for physical damage. | Floor 1 |
| Cave Crawler | Giant crystalline insect. Hard shell, weak underbelly. | Floor 1-2 |
| Ley Wisp | Ball of living ley energy. Casts elemental magic, absorbs magic attacks. Weak to physical. | Floor 2-3 |
| Deep Serpent | Long, eyeless cave snake infused with ley energy. Constrict attack. | Floor 2-3 |
| Ley Construct | Geometric guardian -- floating cube of crystal and energy. Pattern-based attacks. | Floor 3 only |
| **Ley Colossus** (Mini-boss) | Humanoid energy construct. Heavy magic attacks, area pulse. 7,000 HP. | Floor 2 |

### Environmental Hazards

- **Magical burn timer:** On Floors 2-3, a burn meter fills while in the deepest caverns. At 75%, the screen flashes. At 100%, all party members take 10% max HP damage per step. Retreating to safe zones (save points, shallow areas) resets the meter. Encourages efficient exploration, not dawdling.
- **Ley energy rivers:** Adjacent tiles restore 1 MP per step. Standing ON the river deals escalating energy damage (10, 20, 40, 80...).
- **Unstable crystal formations:** Some ceiling crystals drop when the party passes underneath. Visual warning (dust particles fall first). Minor damage.
- **Gravity anomalies:** On Floor 3, near the sealed door, gravity occasionally reverses for 2 seconds -- the screen flips. Cosmetic disorientation, no gameplay effect. Foreshadows the Dreamer's Fault.

---

## 6. Pallor Wastes

### Dungeon Overview

- **Floors:** 5 sections (linear gauntlet: Ashen Approach + Trial Clearing 1-2 + The Grey March + Trial Clearing 3-5 + Plateau's Edge)
- **Size:** Each section: 50x20 tiles (wide, shallow -- a march, not a maze).
- **Theme:** Total Pallor corruption. Grey petrified forest, drained earth, featureless grey sky. Sound is muffled. Color drains progressively -- by the final section, the palette is nearly monochrome. The party's footsteps are the loudest thing. The Convergence is visible ahead as a dark shape growing larger.
- **Narrative Purpose:** Act III gauntlet. The march to the final dungeon. Each party member faces their Pallor trial in a designated clearing. The relentless pacing and resource pressure create the feeling that hope is being physically subtracted.
- **Difficulty:** Very hard. No shops. Limited save points. Encounters are frequent and draining.
- **Recommended Level:** 28-32
- **Estimated Play Time:** 60-80 minutes

### Puzzle Mechanic: Reality Fracture (Pallor Trials)

Each trial clearing is a self-contained encounter where a party member faces their deepest fear. These are NOT standard combat. The trial presents a dialogue/choice sequence interleaved with combat phases:
- **Round 1:** The Pallor manifestation attacks. Standard combat.
- **Round 2:** Dialogue choice. The manifestation speaks. The party member must choose a response. Correct response (acceptance, not denial) weakens the manifestation.
- **Round 3:** Final combat phase. If the correct response was chosen, the manifestation has halved stats. If the wrong response was chosen, the manifestation is at full power and gains a despair aura.

Correct responses are never the defiant option. They are always the accepting one. "You're right -- I failed" weakens. "I'll prove you wrong" strengthens.

### Section 1: Ashen Approach (50x20)

```
E.................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
....%.....%.....%.....%.....%.....%.....%.........
..................................................
..!.....!.....!.....!.....!.....!.....!.....!....
...................S..............................
..................................................
....%.....%.....%.....%.....%.....%.....%.........
..................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
....%.....%.....%.....%.....%.....%.....%.........
..................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
..................................................
..................................................
.................................................X
```

**Notes:** This is deliberately sparse. The map is a straight march through dead forest. Petrified tree stumps dot the landscape. The encounter rate is the highest in the game. Every few steps, something attacks.

- `E` (left): Entry from Ashgrove. Point of no return warning.
- `%` (scattered): Pallor corruption zones. Walking through applies Despair debuff (stacking, cumulative).
- `S` (center): Single save point -- a faint ley line clearing where the ground still has color. Brief rest, no shop.
- `X` (right): Transition to Trial Clearing 1.

### Section 2: Trial Clearings -- Edren & Lira (50x20)

```
E.............#####...............................
..............#   #...............................
.....!........# B1#.......!.......................
..............#   #...............................
..............#####...............................
..............................................S...
..................................................
..................................................
.....!........#####.......!.......................
..............#   #...............................
..............# B2#...............................
..............#   #...............................
..............#####...............................
..................................................
..............................................!...
..................................................
..................................................
.................................................X
```

**Trial 1 (B1): Edren's Trial**
A phantom Cael appears. He tells Edren he was always the lesser knight. The correct response: "You're right. I wasn't enough. But I'm here now." Edren gains Resolve (permanent +10% all stats for the rest of the game).

**Trial 2 (B2): Lira's Trial**
A vision of the life she and Cael could have had -- cottage, peace, children. The correct response: "It was beautiful. And it's gone. I'm letting it go." Lira gains Resolve.

### Section 3: The Grey March (50x20)

```
E.................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
..%..%..%..%..%..%..%..%..%..%..%..%..%..%..%....
..................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
..%..%..%..%..%..%..%..%..%..%..%..%..%..%..%....
..................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
..%..%..%..%..%..%..%..%..%..%..%..%..%..%..%....
..................................................
..!.....!.....!.....!.....!.....!.....!.....!....
..................................................
.......S..........................................
..................................................
..................................................
.................................................X
```

The hardest stretch. Dense corruption zones, maximum encounter rate. The palette is almost entirely grey. Music fades to silence. The save point is the last one before the final trials.

### Section 4: Trial Clearings -- Torren, Sable & Maren (50x20)

```
E.........#####..........#####..........#####.....
..........#   #..........#   #..........#   #.....
....!.....# B3#....!.....# B4#....!....# B5#.....
..........#   #..........#   #..........#   #.....
..........#####..........#####..........#####.....
..................................................
..................................................
.....!.....!.....!.....!.....!.....!.....!........
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..............................................S..X
```

**Trial 3 (B3): Torren's Trial**
The spirits of the Wilds accuse him of failing them. Correct response: "I couldn't save you all. I saved what I could. It has to be enough."

**Trial 4 (B4): Sable's Trial**
Her own insignificance whispers: she doesn't belong with heroes. Correct response: "I'm not a hero. I'm the one who showed up. That's enough."

**Trial 5 (B5): Maren's Trial**
Her younger self asks why she wasted her life on knowledge that only brought suffering. Correct response: "Because someone had to remember. Even if it hurt."

- `S` (bottom-right): Final save point before the Convergence.
- `X` (bottom-right): Exit to the Convergence plateau edge.

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Hollow Walker | Grey humanoid shape. No features. Walks toward the party, drains HP on contact. | All sections |
| Despair Cloud | Formless grey mass. Casts Despair debuff on the entire party. Low HP but high evasion. | All sections |
| Petrified Beast | Former forest creature, turned to grey stone and animated. Heavy physical attacks. | Sections 1, 3 |
| Pallor Knight | Armored figure from a past age. Strong, disciplined, empty. Premium encounter. | Sections 3-4 |
| Grief Shade | Translucent figure that mimics a party member's silhouette. Uses weakened versions of party abilities. | Sections 2, 4 |
| Trial Manifestations | Unique to each trial. See trial descriptions. | Trial clearings |

### Treasure/Loot

Treasure is deliberately sparse. The Wastes strip away resources; they do not give.

| Item | Location | Type |
|------|----------|------|
| Grey Blossom | Section 1 (hidden, search near a petrified stump) | Consumable (full party heal, single use) |
| Pallor Shard | Section 3 (dropped by Pallor Knight, rare) | Crafting material (post-game weapon) |
| Resolve Buffs | Each trial | Permanent stat boost per character |

### Environmental Hazards

- **Cumulative Despair:** Pallor corruption zones (`%`) apply stacking Despair. Each stack reduces all stats by 2%. Stacks persist until the next save point rest. Maximum 10 stacks (20% reduction). Forces the player to manage routes through corruption.
- **Muffled sound:** The game's music fades to near-silence. Only footsteps and combat sounds remain. This is not a bug; it is the Pallor.
- **Greyscale shift:** The color palette desaturates 10% per section. By Section 4, the screen is nearly monochrome. Only ley-line save points retain color.
- **No retreat:** Once entered, the party cannot return to the overworld. Commitment is absolute.

---

## 7. The Convergence

### Dungeon Overview

- **Floors:** 4 phases (Outer Ring + Anchor Stations x3 + Central Platform + The Door)
- **Size:** Outer Ring: 60x60 tiles (circular arena). Anchor Stations: 25x25 tiles each. Central Platform: 40x40 tiles. The Door: 30x20 tiles.
- **Theme:** Shattered plateau floating above a chasm of corrupted ley energy. Cael's machine -- a hybrid of Forgewright engineering and ancient ritual geometry -- dominates the center. The Pendulum hangs at the machine's core, pulsing grey. The sky is featureless grey static. The ground cracks and floats. Everything feels like the end of the world, because it is.
- **Narrative Purpose:** The final dungeon. Three-phase boss battle against Cael and the Pallor incarnation. Party split mechanic (FF6 Kefka's Tower style) for the anchor stations. The emotional climax of the entire game.
- **Difficulty:** Extreme. The hardest content in the main story.
- **Recommended Level:** 32-36
- **Estimated Play Time:** 75-100 minutes (including cutscenes)

### Puzzle Mechanic: Reality Fracture / Party Split

**Phase 1** is a standard boss fight on the outer ring. **Phase 2** splits the party into three teams of two. Each team must reach and disable one of the machine's three ley line anchors at sub-locations around the plateau's edge. The anchors are environmental puzzle-combat encounters:
- **Anchor A (Crownline):** The anchor draws from the Valdris ley line. The puzzle involves redirecting the line's flow using mechanisms identical to the Ember Vein's geometric valves -- what the player learned in the first dungeon pays off in the last.
- **Anchor B (Forgeward):** The anchor draws from the Compact line. The puzzle uses Forgewright power routing -- what the player learned in the Rail Tunnels and Axis Tower.
- **Anchor C (Thornvein):** The anchor draws from the Wilds line. The puzzle uses spirit-speaking -- Torren must commune with the ley line to convince it to withdraw, using knowledge from the "What the Stars Said" sidequest if completed.

**Phase 3** reunites the party against the Pallor incarnate. **Phase 4** (Act IV) is the farewell and sacrifice sequence.

### Outer Ring (60x60 -- simplified representation)

```
              ############
          ####............####
        ##......................##
      ##..........!...............##
     #..........!.....!............#
    #.....S.........................#
   #.................@...............#
   #.................................#
  #....!..........########...........#
  #...............# CAEL #...........#
  #...............# MACH #....!......#
  #...............########...........#
   #...............|.|.|..............#
   #..............A.B.C..............#
    #.........../..|..\..............#
     #........./...|...\............#
      ##....../ ...|... \........##
        ##.../ ....|.... \.....##
          ##/     |      \..##
          ANCHOR  ANCHOR  ANCHOR
            A       B       C
```

**Key Locations:**
- The outer ring is a circular platform of cracked stone floating over a ley energy chasm.
- `S` (left): Save point -- the last one in the main story. A faint ley line pulse in the stone.
- `@` (center-top): Story trigger -- the party sees Cael at the machine's center, wreathed in grey light.
- `CAEL MACH` (center): Cael's machine. Impassable barrier until Phase 2.
- `A, B, C` (bottom): Paths to the three anchor stations. Accessible only during Phase 2 after the party splits.

### Phase 1: Cael (Outer Ring)

Cael descends from the machine to confront the party. He fights with his old knightly skills enhanced by Pallor energy -- he knows the party's tactics because he trained alongside them.

**Boss: Cael, Knight of Despair (Phase 1)**
- 15,000 HP.
- Uses enhanced versions of party member abilities. Counters with moves that specifically target whoever attacked last.
- At 75%: Despair Pulse (party-wide Despair debuff).
- At 50%: Shadow Step -- disappears and reappears behind a random party member for a critical strike.
- At 25%: "I'm doing this for you" -- brief invulnerability while delivering dialogue. The party cannot skip this. It hurts.
- At 0%: The machine activates. Phase 2 begins.

### Anchor Station A: Crownline (25x25)

```
####E########################
#.......#.......#...........#
#...!...#...P...#.....!.....#
#.......D.......D...........#
#.......#.......#...........#
####D####.......######D######
   #.....#.......#   #.....#
   #..!..####D####   #..P..#
   #.....#  #....#   #.....#
   ####D##  #..@.#   ####B##
      #..#  #....#      #.#
      #..#  ######      #.#
      #.T#              #X#
      ####              ###
```

**Puzzle:** Two geometric valves must be set to redirect the Crownline away from the anchor crystal. Same mechanic as Ember Vein -- callbacks to the first dungeon. The `@` trigger shows the ley line flowing into the anchor; redirecting both valves (`P`) cuts the flow. The anchor crystal (`B`) shatters.

**Enemies:** Ley Constructs (same type as Ley Line Depths), Pallor Soldiers.

### Anchor Station B: Forgeward (25x25)

```
####E######################
#........#................#
#...!....#.......!........#
#........D................#
#........#................#
####D#####......P.........#
   #.....#................#
   #..!..####D############
   #.....#  #............#
   ####D##  #.....P......#
      #..#  #............#
      #..#  ####D#########
      #.T#     #....@...#
      ####     #....B...#
               #........#
               ####X#####
```

**Puzzle:** Power routing. Two Forgewright consoles (`P`) must be configured to overload and shut down the anchor's Arcanite engine. Same mechanic as Rail Tunnels / Axis Tower. Lira's expertise is referenced in dialogue if she is in this team.

### Anchor Station C: Thornvein (25x25)

```
####E######################
#.......#.................#
#...!...#........!........#
#.......D.................#
#.......#.................#
####D####.................#
   #.....#.......P........#
   #..!..####D############
   #.....#  #............#
   ####D##  #............#
      #..#  #.....@......#
      #..#  #....B.......#
      #.T#  #............#
      ####  ####X#########
```

**Puzzle:** Spirit-speaking. The `P` is not a mechanical device but a spirit-stone. Torren (if present) communes with the Thornvein to ask it to withdraw. If the "What the Stars Said" sidequest is complete, the ley line responds immediately. If not, Torren must sacrifice HP (30% of max) to force the communion. The anchor crystal releases.

### Phase 2 Completion: Machine Shutdown

When all three anchors are disabled, the machine begins to break apart. The party reunites on the central platform.

### Central Platform / Phase 3: The Pallor Incarnate (40x40)

```
          ##############
       ###......!.......###
     ##....................##
    #........................#
   #..........!...............#
  #............................#
  #.....C..........C...........#
  #............................#
  #............BB..............#
  #............BB..............#
  #............................#
  #.....C..........C...........#
  #............................#
   #..........!...............#
    #........................#
     ##....................##
       ###..........S...###
          ##############
```

Notes: `C` marks Pallor conduit crystals (4 total). `BB` marks the Pallor incarnation at the center.

**Boss: The Pallor Incarnate (Phase 3)**
A towering presence of grey static and hollow sound filling the sky above the platform. Cael is suspended at its center, barely conscious.
- 25,000 HP.
- The four conduit crystals (`C`) each have 3,000 HP. While active, they channel energy to the Incarnate, granting it regeneration (500 HP/turn per crystal). Destroying all four removes regen and reduces its defense by 50%.
- Attacks: Grey Cascade (party-wide, heavy magic damage), Hollow Voice (targets one member with a personalized despair -- unique dialogue per character, inflicts Despair), Reality Tear (removes one party member from battle for 2 turns -- they are "pulled toward the door").
- At 50%: Despair Tide -- the arena shrinks as the edges crumble. Less room to maneuver.
- At 25%: Cael briefly speaks from within: "Lira..."
- At 0%: The Pallor is weakened but not destroyed. Cael is partially freed. Act IV begins.

If "What the Stars Said" is complete: during Phase 3, the ley line resonance activates. The Pallor's defense drops an additional 25%, and the Incarnate's Hollow Voice attack fails against party members with Resolve buffs from the trials.

### Phase 4: The Door (Act IV) (30x20)

```
##########S###############
#........................#
#........................#
#.....@..................#
#........................#
#........................#
#........!.....!.........#
#........................#
#........................#
#...........>>...........#
#........................#
#........!.....!.........#
#........................#
#........................#
##########################
```

**The Farewell Sequence:**
- `@` (left): The farewell dialogue sequence. Edren argues for another way. Maren shakes her head. Lira tells Edren to let him go. Cael says "I'm sorry." Edren says "I know."
- `>>` (center): The door -- a visible tear in reality. Cael walks toward it.
- `!` (flanking): Pallor Surge -- the last stand. The party controls all five members while Cael's silhouette grows smaller in the grey light. Four waves of Pallor manifestations attack. The party must survive all four waves.
  - Wave 1: 6 Hollow Walkers.
  - Wave 2: 4 Despair Clouds + 2 Pallor Knights.
  - Wave 3: 3 Grief Shades (mimicking Edren, Lira, Torren).
  - Wave 4: 1 Pallor Echo (Cael's shadow -- fights with his Phase 1 moveset at reduced power. 5,000 HP).

After Wave 4, Cael closes the door. The Pendulum shatters. Grey light collapses inward. Silence.

### Encounter Table (Convergence Overall)

| Enemy | Description | Location |
|-------|-------------|----------|
| Pallor Soldier | Grey-armored warrior. Strong physical. | Outer Ring, Anchors |
| Ley Construct | Geometric guardian. Pattern attacks. | Anchor A |
| Forgewright Automaton | Compact war machine running on Pallor energy. | Anchor B |
| Corrupted Spirit | Grey-tinted spirit creature. Magic attacks. | Anchor C |
| Hollow Walker | Featureless grey humanoid. HP drain. | Phase 4 |
| Despair Cloud | Formless mass. Party-wide debuff. | Phase 4 |
| Pallor Knight | Armored ancient figure. Premium enemy. | Phase 4 |
| Grief Shade | Mimics party members. | Phase 4 |
| **Cael, Knight of Despair** (Boss, Phase 1) | Former ally. Uses party tactics against them. 15,000 HP. | Outer Ring |
| **The Pallor Incarnate** (Boss, Phase 3) | Towering grey entity. Conduit crystals, area attacks. 25,000 HP. | Central Platform |
| **Pallor Echo** (Mini-boss, Phase 4) | Shadow of Cael. Reduced Phase 1 moveset. 5,000 HP. | The Door |

### Treasure/Loot

| Item | Location | Type |
|------|----------|------|
| Cael's Knight Crest | Outer Ring, post-Phase 1 | Accessory (Edren only, +20 all stats) |
| Anchor Shards (x3) | Each anchor station | Crafting material (post-game ultimate weapons) |
| Pallor Core | Post-Phase 3 | Crafting material (Maren's ultimate staff) |
| Cael's Sword | Post-Phase 4 (Epilogue) | Key item / memorial |

### Environmental Hazards

- **Crumbling edges:** The outer ring loses tiles throughout Phase 1. Standing near the edge when a section crumbles deals fall damage and repositions the character.
- **Ley energy geysers:** Random eruptions from the chasm below. Telegraphed by a rumble + glow. Deal heavy energy damage.
- **Despair field:** The entire Convergence applies a passive Despair effect. Party stats are reduced by 10% baseline. Resolve buffs from the trials counter this.
- **The Door's pull:** During Phase 4, the door exerts a pull. Party members are slowly dragged toward the center each turn. They must be repositioned or they reach the door (removed from battle for 3 turns).

---

## 8. Archive of Ages

### Dungeon Overview

- **Floors:** 3 (Entry Hall + Pictograph Gallery + The Truth Chamber)
- **Size:** Floor 1: 40x30 tiles. Floor 2: 45x35 tiles. Floor 3: 30x25 tiles.
- **Theme:** Ancient Ruins biome at grand scale. Geometric arches, stone tablets lining every wall, embedded ley crystals providing millennia-old light. The architecture is identical to the Ember Vein but ten times the scale. Clean, precise, built to last forever. No corruption here -- the Archive is hidden where the ley lines are healthiest.
- **Narrative Purpose:** Interlude dungeon. Maren's reunion. The party discovers the truth about the Pallor's cycle: every age has had a host, a sacrifice, and a door. The door has been closed before. It always reopens. But each closing buys centuries.
- **Difficulty:** Moderate. Knowledge puzzles are the primary challenge, not combat. Guardians test rather than attack.
- **Recommended Level:** 24-28
- **Estimated Play Time:** 45-55 minutes

### Puzzle Mechanic: Translation Puzzle

Stone tablets throughout the Archive are inscribed in the pre-civilization pictographic language. The player has encountered fragments of this language in the Ember Vein (Act I) and Ley Line Depths (Act II, if visited). Here, the full language is presented:
- Each room has tablets that tell part of a story.
- Three locked doors require the player to arrange pictographic symbols on a stone interface to match a concept described by the nearby tablets.
- Door 1: "The sky opens" -- combine the symbols for "above" and "passage" (both seen in the Ember Vein).
- Door 2: "The weight is carried" -- combine "burden" and "willing" (new symbols, but a tablet in the previous room defines them).
- Door 3: "The door closes from within" -- combine "passage," "ending," and "interior" (the most complex, requiring all prior symbol knowledge).

Players who explored the Ember Vein and Ley Line Depths thoroughly will recognize symbols. Players who did not can still solve the puzzles from context clues in the Archive itself -- no prior dungeon is required, just helpful.

### Floor 1: Entry Hall (40x30)

```
##########E################################
#..........................................#
#...........!..........!...................#
#..........................................#
#..........................................#
####D######........S.......######D#########
   #......#................#    #.........#
   #..@...#................#    #....!....#
   #......####D########D####    #.........#
   #......#  #..........#       #...T.....#
   ########  #...P......#       ###########
             #..........#
             #..........#
             ####v#######
```

**Key Locations:**
- `E` (top): Entry -- the geometric arch in the cliff face. Massive, awe-inspiring. The party pauses.
- `S` (center): Save point. Ley crystals in the floor glow amber.
- `@` (left): Maren is here. Reunion scene. She has been studying the tablets and has decoded most of the pictographic language.
- `P` (center-bottom): Translation puzzle 1. Stone interface with symbol slots. Solving opens the stairs.
- `T` (right): Chest -- Archive Key Fragment (1 of 2, needed for Floor 3 locked door).
- `v` (bottom): Stairs down to Floor 2.

### Floor 2: Pictograph Gallery (45x35)

```
############^################################
#..............#.........#..................#
#......!.......#.........#........!.........#
#..............D...@.....D..................#
#..............#.........#..................#
####D##########.........######D#############
   #..........#.........#    #.............#
   #....*.....####D######    #.......P.....#
   #..........#  #......#    #.............#
   ####D#######  #..!...#    #####L#########
      #.......#  #......#        #.........#
      #...!...#  #..T...#        #....S....#
      #.......#  ########        #.........#
      #...T...#                  ####v######
      #########
```

**Key Locations:**
- `^` (top): Stairs from Floor 1.
- `@` (center): The gallery proper. Walls covered in pictographic tablets depicting the Pallor's history across ages. Maren reads and translates as the party walks through. Each tablet set tells one cycle's story.
- `*` (left): Guardian encounter -- Archive Sentinel. Not hostile by default. It asks a question (in pictographs that Maren translates): "Why do you seek the truth?" Three dialogue options:
  - "To save the world" -- the Sentinel attacks (wrong answer; the truth can't be wielded as a weapon).
  - "To understand" -- the Sentinel stands aside (correct).
  - "Because someone has to remember" -- the Sentinel stands aside AND drops a bonus item (best answer, echoing Maren's theme).
- `P` (right): Translation puzzle 2. More complex than puzzle 1.
- `L` (right): Locked door. Requires both Archive Key Fragments.
- `T` (left-bottom): Chest -- Archive Key Fragment (2 of 2).
- `T` (center-bottom): Chest -- Sage's Robe (armor, Maren, best for this point in the game).
- `S` (bottom-right): Save point.
- `v` (bottom-right): Stairs down to Floor 3.

### Floor 3: The Truth Chamber (30x25)

```
      ####v####
      #.......#
      #...!...#
      #.......#
      ###D#####
        #.....#
   ######..P..######
   #................#
   #................#
   #........@.......#
   #................#
   #................#
   ####.........#####
      #.........#
      #....B....#
      #.........#
      #....T....#
      ###..X..###
         #####
```

**Key Locations:**
- `v` (top): Descent to the deepest, oldest chamber.
- `P` (center-top): Translation puzzle 3 -- the final and most complex. "The door closes from within."
- `@` (center): The truth. A circular room with a single massive tablet. Cutscene: Maren reads the complete cycle. The Archivist (a construct guardian) provides clinical confirmation. Every age has had a Pendulum, a host, and a sacrifice. The door closes from the inside. The one who closes it does not come back.
- `B` (bottom): Boss arena. The Archive's final guardian activates -- not to prevent access (the truth has been delivered) but to test whether the party has the strength to act on it.
- `T` (bottom): Post-boss chest -- Archivist's Codex (accessory, +25 MAG, grants ability to read all pictographic inscriptions in other dungeons retroactively -- unlocks lore entries).
- `X` (bottom): Exit. A spirit-path opens, returning the party to the overworld.

### Boss: Archive Guardian

A construct of geometric crystal and ancient stone. It does not speak. It tests. Three phases:
- Phase 1: Physical attacks only. Tests the party's defense and healing.
- Phase 2: Magic attacks only. Tests the party's magic resistance and offense.
- Phase 3: Combination. The Guardian splits into two halves -- one physical, one magical -- that must be defeated simultaneously (within 3 turns of each other, or the first revives). Tests coordination.
10,000 HP total (5,000 per half in Phase 3).

### Encounter Table

| Enemy | Description | Location |
|-------|-------------|----------|
| Archive Sentinel | Stone guardian. Questions before fighting. Can be bypassed with correct answer. | Floor 2 |
| Pictograph Wisp | Living inscription that detaches from the wall. Magic attacks themed to whatever story its tablet told. | All floors |
| Dust Golem | Accumulated centuries of dust animated by ambient ley energy. Slow, tanky. | Floor 1-2 |
| Crystal Warden | Small floating crystal. Fires ley bolts. Shatters on death (area damage). | Floor 2-3 |
| **Archive Guardian** (Boss) | Geometric construct. Three-phase test. 10,000 HP. | Floor 3 |

### Treasure/Loot

| Item | Location | Type |
|------|----------|------|
| Archive Key Fragment 1 | Floor 1 chest | Key item |
| Archive Key Fragment 2 | Floor 2 chest | Key item |
| Sage's Robe | Floor 2 chest | Armor (Maren) |
| Sentinel's Gift | Floor 2 (best answer to Sentinel) | Accessory (+10 all stats, Maren only) |
| Archivist's Codex | Floor 3 post-boss | Accessory (+25 MAG, lore unlock) |

### Environmental Hazards

- **Ley crystal flares:** Occasionally, the ancient ley crystals in the walls flare brightly. Purely cosmetic -- they cast dramatic shadows and illuminate hidden pictographs.
- **Translation failure traps:** Entering a wrong symbol combination on a puzzle triggers a guardian encounter instead of opening the door. Not a dead end -- defeat the guardian and try again.
- **Gravity shifts:** On Floor 3, near the Truth Chamber, gravity occasionally shifts (a callback to the Ley Line Depths). Brief disorientation, no damage.
- No Pallor corruption. The Archive is untouched. This is deliberate -- the builders hid it well.

---

## 9. Dreamer's Fault

### Dungeon Overview

- **Floors:** 20 (the post-game super dungeon)
- **Size:** Each floor: 30x25 tiles (compact but dense).
- **Theme:** Surreal, impossible architecture. Every floor draws from a different age the Pallor has touched. Gravity shifts, time distorts, architecture from civilizations that never existed on this continent. The visual style changes every 4 floors -- ancient stone, alien crystal, living wood, twisted metal, and finally pure grey void. At the bottom, Cael's echo.
- **Narrative Purpose:** Post-game challenge content. The crack in reality left by the door's closing. The player confronts echoes of every host the Pallor has ever claimed. At the bottom, closure -- not resurrection.
- **Difficulty:** Extreme. The hardest content in the game. Each floor is harder than the last.
- **Recommended Level:** 40-50 (post-game grinding expected)
- **Estimated Play Time:** 3-5 hours (not expected in one sitting)

### Structure

The Dreamer's Fault is entered from The Pendulum tavern (post-game hub). A crack in the tavern's cellar opens into the space between reality and the Pallor's domain.

**Floor Themes (4-floor sets):**

| Floors | Theme | Visual Style | Unique Mechanic |
|--------|-------|-------------|-----------------|
| 1-4 | The First Age | Ancient stone, Ember Vein geometry | Floors rotate 90 degrees between rooms |
| 5-8 | The Crystal Age | Alien crystal formations, refracting light | Light/shadow puzzles -- enemies visible only in light/shadow |
| 9-12 | The Green Age | Living wood, overgrown ruins | Floors grow and shift -- paths change between visits |
| 13-16 | The Iron Age | Twisted industrial metal, gears, pipes | Gravity reversal -- ceiling becomes floor periodically |
| 17-20 | The Void | Pure grey, featureless, minimal geometry | No map. The player navigates by sound cues only. |

**Every 4th floor:** Echo Boss -- a shade of a past Pallor host. Each is a unique boss with mechanics themed to their age.

- **Floor 4 Boss:** The First Scholar. Ancient mage. Complex spell patterns.
- **Floor 8 Boss:** The Crystal Queen. Alien warrior. Reflection-based attacks (damage bounces).
- **Floor 12 Boss:** The Rootking. Nature spirit corrupted. Regeneration, summons.
- **Floor 16 Boss:** The Iron Warden. Mechanical knight. Counter-based defense.
- **Floor 20 Boss:** Cael's Echo. Not a real fight -- a conversation. He says: "It's heavy. But the door is closed. Go home." The player can examine the space around him: echoes of every age, every sacrifice, every closing. The weight of it is visible. Then the party leaves.

**Save points:** Every 5th floor (Floors 5, 10, 15, 20). Return portal on every 5th floor as well.

### Sample Floor Map: Floor 1 (30x25)

```
####E########################
#..........#................#
#....!.....#......!.........#
#..........D................#
#..........#................#
####D######......P..........#
   #......#.................#
   #..!...####D#############
   #......#  #.............#
   #..T...#  #......!......#
   ######D#  #.............#
        #.#  ####D##########
        #.#     #..........#
        #.#     #.....T....#
        #.#     #..........#
        ###     ####v#######
```

This is representative. Each floor follows a similar compact layout with 2-3 encounter zones, 1-2 treasure chests, 1 puzzle element, and stairs to the next floor.

### Floor 20: Cael's Echo (30x25)

```
      ####v####
      #.......#
      #.......#
      #.......#
      ###D#####
        #.....#
   ######.....######
   #................#
   #................#
   #.......@........#
   #................#
   #................#
   ####.........#####
      #.........#
      #....S....#
      #.........#
      #.........#
      ###..X..###
         #####
```

- `@` (center): Cael's Echo. Not hostile. A shade of grey light in the shape of a man. Dialogue only. He recognizes the party. He is at peace -- burdened, but at peace. "It's heavy. But the door is closed. Go home."
- `S` (bottom): Save point and return portal.
- `X` (bottom): Exit back to The Pendulum tavern.

### Encounter Table (Representative -- each floor set has unique enemies)

| Enemy | Age | Description |
|-------|-----|-------------|
| First Age Sentinel | 1-4 | Stone guardian, geometric attacks |
| Crystal Refractor | 5-8 | Prism creature, reflects spells |
| Root Weaver | 9-12 | Living vine construct, entangle |
| Iron Automaton | 13-16 | Mechanical soldier, heavy armor |
| Void Walker | 17-20 | Featureless grey shape, drains all |
| Echo Bosses (x4) | Every 4th floor | Unique, extremely powerful |

### Treasure/Loot

- Each floor has 1-2 chests with escalating quality.
- Floors 1-4: Best-in-class consumables.
- Floors 5-8: Unique accessories not found elsewhere.
- Floors 9-12: Ultimate weapon materials.
- Floors 13-16: Ultimate armor materials.
- Floors 17-20: Cosmetic rewards and the Dreamer's Crest (accessory, best in game: +30 all stats).

### Environmental Hazards

- **Floor rotation (1-4):** The map rotates 90 degrees when entering certain rooms. Disorienting but the minimap adjusts.
- **Light/shadow (5-8):** Enemies are invisible in certain lighting. Light sources can be activated/deactivated.
- **Living paths (9-12):** Corridors grow or retract between rooms. The map changes each visit.
- **Gravity reversal (13-16):** Periodically, gravity flips. The party walks on the ceiling. Encounters continue normally but the visual flip is disorienting.
- **No map (17-20):** The minimap is disabled. The player navigates by audio cues -- footstep echoes, distant hums, Cael's voice growing louder.

---

## 10. Dry Well of Aelhart

### Dungeon Overview

- **Floors:** 1 (three-room mini-dungeon)
- **Size:** 30x20 tiles total.
- **Theme:** Pre-civilization ruin fragment beneath the starting village. Same geometric carvings as the Ember Vein. Small, intimate, and revelatory. The village was built specifically to cap this entrance.
- **Narrative Purpose:** Optional mini-dungeon. Accessible during the Interlude when ley line instability widens the crack at the well's bottom. Connects Aelhart to the pre-civilization ruin network. Edren-specific reward integrates with his Act III Pallor trial.
- **Difficulty:** Moderate. One puzzle, one fight.
- **Recommended Level:** 20-24
- **Estimated Play Time:** 10-15 minutes

### Map

```
##########E################
#..........#..............#
#....!.....#......P.......#
#..........D..............#
#..........#..............#
####D######..............##
   #......#.............##
   #......####D########
   #..T...#  #........#
   #......#  #...@....#
   ########  #........#
             #...T....#
             ####X#####
```

**Key Locations:**
- `E` (top): Entry from the dry well. A narrow crack in the well's base, widened by ley instability.
- `P` (top-right): Puzzle -- a stone interface identical to the Ember Vein's geometric mechanisms. The solution is inscribed on a nearby tablet.
- `T` (left): Chest -- Aelhart History (lore item, describes the village's founding purpose).
- `@` (right): The tablet room. A single large tablet depicts Aelhart's founding. The village was built to cap the ruin entrance. The founders knew about the pre-civilization network.
- `T` (right): Chest -- Edren's Family Crest (accessory, +10 ATK/DEF, unlocks bonus dialogue in Edren's Act III Pallor trial).
- `X` (bottom): Exit back to the well.

**Single encounter:** Ruin Shade -- a guardian construct similar to the Ember Vein's Vein Guardian but smaller. 3,000 HP. Straightforward fight.

---

## 11. Sunken Rig

### Dungeon Overview

- **Floors:** 2 (Upper Deck + Lower Engine Room)
- **Size:** Floor 1: 35x25 tiles. Floor 2: 35x25 tiles.
- **Theme:** Claustrophobic Carradan Industrial. A beached offshore extraction rig -- iron corridors, rusted pipes, flooded compartments. Pallor manifestations nest in the enclosed spaces. Crew logs on walls tell the story of the crew's descent into despair.
- **Narrative Purpose:** Optional Interlude dungeon. Sable-focused content. Demonstrates the Pallor's adaptation to industrial environments. The crew logs are environmental storytelling -- real-time documentation of despair.
- **Difficulty:** Moderate-hard. Claustrophobic design limits party movement in combat.
- **Recommended Level:** 22-26
- **Estimated Play Time:** 30-40 minutes

### Puzzle Mechanic: Pressure Valve Routing

The rig's pressure system is malfunctioning. The player must open and close valves to route pressure away from flooded compartments (draining them for access) and toward stuck hatches (forcing them open). Three valve wheels control five compartments. The correct combination drains the path to the engine room.

### Floor 1: Upper Deck (35x25)

```
##########E########################
#..........#.........#............#
#....S.....#....!....#......T.....#
#..........D.........D............#
#..........#.........#............#
####D######....P.....######D######
   #......#..........#   #.......#
   #..!...####D#######   #...!...#
   #......#  #.......#   #.......#
   #..T...#  #...@...#   ####v####
   ########  #.......#
             #########
```

**Key Locations:**
- `E` (top): Entry -- the rig's exterior hatch. Salt air, rusted metal, the sound of water.
- `S` (top-left): Save point.
- `P` (center): Valve wheel 1. Controls compartment flooding.
- `@` (center-right): Crew log station. Five logs describing the crew's experience. The last log is just: "The grey is inside now."
- `T` (left): Chest -- Diver's Mask (accessory, prevents water damage).
- `T` (right): Chest -- Rig Worker's Wrench (weapon, Sable, high critical rate).
- `v` (right): Hatch down to Lower Engine Room.

### Floor 2: Lower Engine Room (35x25)

```
####v##############################
#..........#..........#...........#
#....!.....#....P.....#.....!.....#
#..........D..........D...........#
#..........#..........#...........#
####D######..........######D######
   #......#..........#   #.......#
   #..*...####D#######   #...S...#
   #......#  #.......#   #.......#
   ####D###  #...B...#   ####D####
      #...#  #.......#      #...#
      #.T.#  #...T...#      #.T.#
      #...#  ####X####      #...#
      #####                 #####
```

**Key Locations:**
- `v` (top): Descent from upper deck.
- `P` (center): Valve wheels 2 and 3. Final pressure routing puzzle.
- `*` (left): Mini-boss -- Pallor Amalgam. A mass of grey corruption that has absorbed the rig's machinery. Part organic, part mechanical.
- `S` (right): Save point before boss.
- `B` (center): Boss arena -- the engine room. The Arcanite engine at the rig's core has been consumed by Pallor energy. It pulses grey.
- `T` (left): Chest -- 3x Pallor Ward.
- `T` (center): Post-boss -- Abyssal Dagger (weapon, Sable, best dagger in the Interlude).
- `T` (right): Chest -- Captain's Final Log (lore item, details the exact moment the crew lost hope).
- `X` (center-bottom): Exit.

### Boss: The Grey Engine

The rig's Arcanite engine, consumed and animated by Pallor energy. A mechanical horror -- gears grinding, pipes hissing, Pallor energy crackling. It cannot move but has long-range attacks: steam jets, pipe strikes, and a Despair Pulse that hits the entire party. The arena has two pressure release valves -- activating them vents steam, stunning the boss for 2 turns but flooding part of the arena (reducing safe space). 9,000 HP.

---

## 12. Windshear Peak

### Dungeon Overview

- **Floors:** 1 (mountain ascent trail + summit vista)
- **Size:** 40x30 tiles.
- **Theme:** Mountain / Alpine biome. Bare rock, thin air, wind. No enemies, no combat. This is a place of rest. The view from the summit shows the entire continent. A wind-spirit oracle answers one question per visit.
- **Narrative Purpose:** Optional exploration area. Panoramic world geography. Torren-specific scene. The oracle provides cryptic hints toward hidden content.
- **Difficulty:** None. No combat encounters.
- **Recommended Level:** Any.
- **Estimated Play Time:** 10-15 minutes

### Map

```
##########E########################
#..........#.........#............#
#..........#.........#............#
#..........D.........D............#
#..........#.........#............#
####.......#.........#......####
   #.......####.#.####.....#
   #...........#.#..........#
   #...........#.#..........#
   ########....#.#....#######
          #....#.#....#
          #....#.#....#
          #....#.#....#
          ##...#.#...##
           #...#.#...#
           #...#.#...#
           ##..#.#..##
            #..#.#..#
            #..@.@..#
            #.......#
            #...S...#
            #..@....#
            #########
```

The map represents a switchback trail ascending to the summit. The path narrows as it climbs.

**Key Locations:**
- `E` (top): Entry from the Thornmere Wilds overworld.
- `@` (bottom, left): Torren's prayer stone. If Torren is in the party, he kneels and prays. Unlocks a dialogue option about the spirits.
- `@` (bottom, center): The wind-spirit oracle. It asks: "One question." The player can ask about:
  - Hidden locations (hints toward Dry Well, Sunken Rig, or Dreamer's Fault)
  - Story events (cryptic foreshadowing of upcoming plot)
  - Party members (personal insights)
  - The answer is always poetic and indirect. One question per visit.
- `@` (bottom, right): The vista point. The camera pulls out to show the entire continent. In Act II, the grey haze over the Convergence is visible. In the Interlude, the Pallor's spread is horrifying -- grey patches across the map. In Act III, the approach is visible.
- `S` (bottom): Save point. Rest and recovery in the thin mountain air.

No encounters. No treasure. No hazards. Just the wind, the view, and one answer.

---

## 13. Mountain Passes

Three named mountain passes serve as transition areas between major regions. They are short (1-2 floors), have no bosses, but feature encounters and treasure. They are the connective tissue of the overworld.

### 13a. Wilds Gate Pass

**Location:** Between Thornwatch (Valdris) and the northern Thornmere Wilds.
**Acts:** I, II
**Floors:** 1
**Size:** 40x20 tiles (long, narrow)
**Theme:** Narrow gap in the Broken Hills. Dense forest flanking a single-wagon-width road. Thornwatch fortress visible behind; the Wilds canopy visible ahead. Compact scout markers on the trees.

```
E.......................................X
#...!...........!...........!..........#
#......................................#
#..T.............................T.....#
#......................................#
#...!...........!...........!..........#
#......................................#
#.............S........................#
#......................................#
#...!...........!...........!..........#
#......................................#
#......H...............................#
#......................................#
#...!...........!...........!..........#
#......................................#
#......................................#
#......................................#
##########################################
```

**Key Locations:**
- `E` (left): Entry from Thornwatch side.
- `X` (right): Exit to the Thornmere Wilds.
- `S` (center): Save point -- a Valdris waystone.
- `T` (left): Chest -- 3x Potion.
- `T` (right): Chest -- Ranger's Cloak (accessory, +5 EVA).
- `H` (left-center): Hidden alcove in the cliff face. Contains: Old Valdris Map (lore item, shows pre-war border).

**Encounters:** Low-to-mid level. Wolves, Compact scouts (can be fought or avoided), aggressive boars.

### 13b. Frostcap Descent

**Location:** Between Valdris Crown and Highcairn, through the Frostcap foothills.
**Acts:** Interlude
**Floors:** 2 (Switchback Trail + Ice Cave Shortcut)
**Size:** Floor 1: 40x25 tiles. Floor 2: 30x20 tiles.
**Theme:** Mountain / Alpine biome. Snow, wind, exposed rock. The trail switchbacks up the mountain. An optional ice cave provides a shortcut but has harder encounters.

#### Floor 1: Switchback Trail (40x25)

```
E.......................................
#...!...........!...........!..........#
#......................................#
#..S...................................#
#......................................#
#...!...........!...........!..........#
#......................................#
#..........H...........................#
#......................................#
#...!...........!...........!..........#
#......................................#
#..T...................................#
#......................................#
#...!...........!...........!..........#
#......................................#
#......................................#
........................................X
```

- `E` (top-left): Entry from Valdris Crown side.
- `X` (bottom-right): Exit to Highcairn.
- `S` (top-left): Save point -- a traveler's cairn.
- `T` (left): Chest -- Highland Herbs (consumable, restores HP and cures Freeze).
- `H` (center-left): Hidden cave entrance -- leads to Floor 2 (Ice Cave Shortcut).

#### Floor 2: Ice Cave Shortcut (30x20)

```
####H#########################
#..........#.................#
#....!.....#........!........#
#..........D.................#
#..........#.................#
####D######.................##
   #......#................##
   #..!...####.........####
   #......#  #.........#
   #..T...#  #...!.....#
   ########  #.........#
             ####X######
```

- `H` (top): Entry from the hidden cave entrance on Floor 1.
- `T` (left): Chest -- Frost Crystal (accessory, +10 MAG DEF, ice resistance).
- `X` (bottom): Exit -- emerges near Highcairn, bypassing the upper switchbacks.

**Encounters:** Mid-to-hard. Ice wolves, stone elementals, highland beasts. In the Interlude, add Pallor manifestations and cold-damage environmental hazard (Freeze status from wind gusts).

### 13c. Broken Hills Crossing

**Location:** Between the Thornmere Wilds (south edge) and Carradan Compact territory, near Gael's Span.
**Acts:** II, Interlude
**Floors:** 1
**Size:** 40x20 tiles
**Theme:** Broken Hills terrain. Fractured rock, old mine shafts, Compact border markers. The forest thins. Industrial sounds carry from the south.

```
E.......................................X
#...!...........!...........!..........#
#......................................#
#..T...................................#
#......................................#
#...!...........!...........!..........#
#......................................#
#.............S........................#
#......................................#
#...!...........!...........!..........#
#......................................#
#......................................#
#......................................#
#...!...........H...........!..........#
#......................................#
#..................................T...#
#......................................#
##########################################
```

- `E` (left): Entry from Wilds side.
- `X` (right): Exit toward Gael's Span.
- `S` (center): Save point.
- `T` (left): Chest -- Compact Rations (consumable, restores moderate HP).
- `T` (right): Chest -- Iron Gauntlet (accessory, +5 ATK).
- `H` (center): Hidden mine shaft entrance. Contains: Old Mining Ledger (lore item, documents Compact's early extraction operations).

**Encounters:** Moderate. Compact patrols, displaced wildlife, rogue Forgewright constructs.

---

## 14. Caves and Grottos

Small cave systems along travel routes. These are single-room or two-room areas with a few encounters and a treasure chest. They reward exploration without demanding commitment.

### 14a. Thornvein Grotto

**Location:** Along the Wildwood Trail between Ironmouth and Roothollow.
**Acts:** I
**Size:** 20x15 tiles

```
####E##############
#..........#......#
#....!.....#..T...#
#..........D......#
#..........#......#
####.......########
   #.......#
   #...!...#
   #.......#
   #...T...#
   #########
```

- Small cave where the Thornvein Creek surfaces. The water glows faintly amber.
- `T` (right): Chest -- Spirit Moss (consumable, restores 30 MP).
- `T` (bottom): Chest -- Amber Pebble (accessory, +3 MAG, minor).
- Encounters: Ley-touched cave bats, small crystal formations.

### 14b. Duskfen Hollow

**Location:** In the marshland near Duskfen, off the main path.
**Acts:** II
**Size:** 20x15 tiles

```
####E##############
#~~........#......#
#~~..!.....#..T...#
#~~........D......#
#~~........#......#
####.......########
   #~......#
   #~..!...#
   #~......#
   #~..T...#
   #########
```

- A waterlogged cave in the marsh. Shallow water covers half the floor.
- `T` (right): Chest -- Marsh Root (crafting material).
- `T` (bottom): Chest -- Will-o'-Wisp Lantern (accessory, increases visibility in marshland, reduces ambush chance).
- Encounters: Marsh serpents, bloated toads.

### 14c. Highcairn Hermit Cave

**Location:** Along the Highland Descent between Highcairn and Valdris Crown.
**Acts:** Interlude
**Size:** 20x15 tiles

```
####E##############
#..........#......#
#....!.....#..@...#
#..........D......#
#..........#......#
####.......########
   #.......#
   #...!...#
   #.......#
   #...T...#
   #########
```

- A cave where a hermit monk from the Monastery of the Vigil took shelter during the Pallor siege.
- `@` (right): The hermit. He gives the party a Highland Blessing (temporary buff: +5 all stats for next 3 battles) and tells a story about Edren's early training days.
- `T` (bottom): Chest -- Monk's Staff (weapon, Maren alternative).
- Encounters: Pallor-corrupted highland creatures.

### 14d. Corrund River Cave

**Location:** Along the river road between Gael's Span and Corrund.
**Acts:** Interlude
**Size:** 25x15 tiles

```
####E####################
#..........#............#
#....!.....#......!.....#
#..........D............#
#..........#............#
####D######............##
   #......#...........##
   #..!...####....####
   #......#  #....#
   #..T...#  #.T..#
   ########  ######
```

- A riverside cave with Compact supply caches abandoned during the Unraveling.
- `T` (left): Chest -- 5x Potion.
- `T` (right): Chest -- Compact Supply Kit (consumable set: 3x Antidote, 2x Smelling Salts, 1x Elixir).
- Encounters: Forge Phantoms, rogue Compact automatons.

### 14e. Ashgrove Undercroft

**Location:** Beneath the Ashgrove clearing, accessible via a hidden passage near the First Tree stump.
**Acts:** II (discoverable), Interlude (fully accessible)
**Size:** 25x20 tiles

```
####H####################
#..........#............#
#....!.....#............#
#..........D....@.......#
#..........#............#
####D######............##
   #......#...........##
   #......####D#####
   #..T...#  #.....#
   #......#  #..T..#
   ########  #.....#
             ###X###
```

- Hidden beneath the ash field. Contains a chamber with carvings from the time the First Tree burned. The carvings depict the Pallor's cycle in pictographs similar to the Archive of Ages.
- `@` (right): Pictograph wall. Maren (if present) can translate. Provides early foreshadowing of the Archive's revelations.
- `T` (left): Chest -- Ash Blossom (accessory, +8 MAG, fire resistance).
- `T` (right): Chest -- First Tree Seed (key item, used in post-game content at the Convergence meadow -- planting it triggers a unique epilogue scene).
- Encounters: Ash elementals, ancient spirit remnants.

---

## Appendix: Dungeon Summary Table

| # | Dungeon | Act | Floors | Rec. Level | Time | Boss | Gimmick |
|---|---------|-----|--------|-----------|------|------|---------|
| 1 | Ember Vein | I | 2 | 3-5 | 25-35 min | Vein Guardian | Mine cart routing |
| 2 | Fenmother's Hollow | II | 3 | 12-15 | 45-60 min | Corrupted Fenmother | Water level control |
| 3 | Rail Tunnels | Interlude | 3 sections | 18-22 | 40-50 min | Corrupted Boring Engine | Power routing |
| 4 | Axis Tower | Interlude | 5 | 22-26 | 50-65 min | General Kole | Stealth/alarm system |
| 5 | Ley Line Depths | II (optional) | 3 | 16-20 | 55-70 min | Ley Colossus | Ley energy channeling |
| 6 | Pallor Wastes | III | 5 sections | 28-32 | 60-80 min | Trial Manifestations | Pallor trials (narrative combat) |
| 7 | The Convergence | III-IV | 4 phases | 32-36 | 75-100 min | Cael / Pallor Incarnate | Party split, anchor destruction |
| 8 | Archive of Ages | Interlude | 3 | 24-28 | 45-55 min | Archive Guardian | Translation puzzle |
| 9 | Dreamer's Fault | Post-game | 20 | 40-50 | 3-5 hours | Echo Bosses x4 + Cael's Echo | Per-floor unique mechanics |
| 10 | Dry Well of Aelhart | Interlude | 1 | 20-24 | 10-15 min | Ruin Shade | Simple geometric puzzle |
| 11 | Sunken Rig | Interlude | 2 | 22-26 | 30-40 min | The Grey Engine | Pressure valve routing |
| 12 | Windshear Peak | II-III | 1 | Any | 10-15 min | None | Oracle, vista, rest |
| 13a | Wilds Gate Pass | I-II | 1 | 5-10 | 10 min | None | Transition area |
| 13b | Frostcap Descent | Interlude | 2 | 20-24 | 15-20 min | None | Ice cave shortcut |
| 13c | Broken Hills Crossing | II-Interlude | 1 | 14-18 | 10 min | None | Transition area |
| 14a-e | Caves/Grottos | Various | 1 each | Various | 5-10 min each | None | Exploration rewards |
