# Thornmere Wilds Settlements & Cross-Faction Locations

Detailed settlement layouts for all Thornmere Wilds communities and cross-faction waypoints. These are not cities. They are camps, tree-villages, marsh dwellings, sacred groves, and hermit dens built INTO the living landscape. Architecture here is grown, not constructed. The forest is the building material, the foundation, and the landlord.

Design philosophy: a player arriving from Valdris Crown or Corrund should feel like a stranger. The grid logic of stone cities does not apply. Paths curve. Rooms breathe. Light comes from below. The spirit world bleeds through at the edges, visible as faint translucent shapes drifting between the trees. Bioluminescence replaces torches. Water is everywhere -- pooling, dripping, flowing beneath platforms. Vertical space matters as much as horizontal. The settlements feel alive because they ARE alive.

Cross-reference: `biomes.md` (Thornmere Deep Forest, Thornmere Wetlands palettes), `visual-style.md` (location profiles), `npcs.md` (character placements), `dynamic-world.md` (act-by-act transformations), `locations.md` (narrative context).

---

## Table of Contents

1. [Roothollow](#1-roothollow)
2. [Duskfen](#2-duskfen)
3. [Ashgrove](#3-ashgrove)
4. [Canopy Reach](#4-canopy-reach)
5. [Greywood Camp](#5-greywood-camp)
6. [Stillwater Hollow](#6-stillwater-hollow)
7. [Sunstone Ridge](#7-sunstone-ridge)
8. [Maren's Refuge](#8-marens-refuge)
9. [Cross-Faction Locations](#9-cross-faction-locations)
   - [The Pendulum Tavern](#the-pendulum-tavern-epilogue)
   - [Gael's Span](#gaels-span)
   - [Rhona's Trading Post (Ashfen)](#rhonas-trading-post-ashfen)
   - [The Three Roads Inn](#the-three-roads-inn)

---

## 1. Roothollow

### Settlement Overview

**Type:** Tribal settlement built inside the root system of an ancient tree
**Faction:** Roothollow Tribe
**Acts:** I, II, Interlude
**Approximate size:** 48x40 tiles (exterior approach), plus 64x48 tiles (interior root chambers on a separate map)

Roothollow is the player's introduction to the Wilds and must immediately establish that Thornmere settlements operate on entirely different principles than stone cities. There are no walls because the tree IS the wall. There are no doors because root archways grow open and closed over decades. The settlement exists in two layers: a small exterior clearing where the great tree's trunk rises beyond the screen, and an interior network of root chambers that serve as the living space.

**Layout philosophy:** Organic radial. The great tree's trunk is the center of everything. Root chambers branch outward like veins from a heart. Passages twist and slope -- some are wide enough for three abreast, others require single file. The tribe grew their spaces by coaxing roots to part over generations of careful spirit-pact tending. Nothing was carved hastily. Every chamber has the slow, deliberate shape of something that took decades to form.

**Terrain relationship:** The settlement IS the tree. Root walls are living wood, warm brown bark with visible sap channels. The floor is compacted earth between exposed roots. The ceiling is a lattice of smaller roots with bioluminescent moss growing in the gaps, providing a soft teal-cyan ambient light. Where roots cross overhead, spirit-totems hang from heartwood hooks, glowing faint purple.

### ASCII Settlement Map -- Exterior Approach

```
                         [Great Tree Trunk -- impassable, extends off-screen]
                              |||||||||||||||
                          ////               \\\\
                      ///                         \\\
                  ///          CANOPY ABOVE            \\\
              ///          (optional upper area)           \\\
          ///                                                 \\\
      ===                                                       ===
     ||            .  .  .  .  .  .  .  .  .  .  .               ||
     ||       .         ~SPIRIT TOTEMS~          .               ||
     ||    .       [T1]    [T2]    [T3]       .                  ||
     ||  .                                     .                 ||
    R||.     +---------+         +---------+     .              R||
    O||     /  Herb    |         | Hunter's \     .             O||
    O||    | Garden    |    *    |  Lean-to  |      .           O||
    T||    |  (herbs)  |  FIRE  | (weapons) |       .          T||
     ||     \  beds   |   PIT   |  (pelts)  /        .          ||
    W||      +--------+         +---------+           .        W||
    A||                                                .       A||
    L||          ______                                 .      L||
    L||         / ROOT \    <-- MAIN ENTRANCE                  L||
     ||        | ARCH   |       to interior                     ||
     ||        | (down) |       chambers                        ||
     ||         \______/                                        ||
     ||              \                                          ||
     ||    +----+     \        [Spirit                          ||
     ||    |Rest|      \        Totem]                          ||
     ||    |Spot|       \         |                             ||
     ||    +----+        ---------.--------- PATH               ||
     ||                                TO WILDWOOD TRAIL -----> ||
     ===                                                       ===
         \\\                                               ///
              \\\                                     ///
                   \\\         ROOT SPREAD       ///
                        \\\                 ///
                             \\\\     ////
                     .............|.|..............
                     .    FOREST FLOOR PATH      .
                     .   (from Wildwood Trail)   .
                     .............................
```

### ASCII Settlement Map -- Interior Root Chambers

```
                              N
                              |
    +-----------+       +-----+-----+       +-------------+
    | VESSA'S   |       | HEARTWOOD |       |  HERBALIST  |
    | CHAMBER   +-------+  SHRINE   +-------+   ALCOVE    |
    | (spirit-  |  root |  (save    |  root |  (shop:     |
    |  speaker) | pass  |  point)   | pass  |  remedies,  |
    |  totems,  |       |  ancient  |       |  potions,   |
    |  carved   |       |  root     |       |  spirit     |
    |  walls)   |       |  altar    |       |  herbs)     |
    +-----+-----+       +-----+-----+       +------+------+
          |                    |                     |
          | narrow             | main                | root
          | passage            | passage             | tunnel
          |                    |                     |
    +-----+-----+       +-----+-----+       +------+------+
    | ELDER'S   |       |  CENTRAL  |       |  GUEST      |
    | ALCOVE    +-------+   HUB     +-------+  HOLLOW     |
    | (tribal   |       | (open     |       | (hammocks   |
    |  records, |       |  chamber, |       |  woven from |
    |  root-    |       |  totems   |       |  root-silk, |
    |  woven    |       |  at each  |       |  warm moss  |
    |  scrolls) |       |  exit)    |       |  bedding,   |
    +-----+-----+       +-----+-----+       |  rest/save) |
          |                    |              +------+------+
          |                    |                     |
    +-----+-----+       +-----+-----+       +------+------+
    | CHILDREN'S|       |  ENTRY    |       |  TRADER'S   |
    | HOLLOW    +-------+  CHAMBER  +-------+  NOOK       |
    | (small,   |       | (root     |       | (barter:    |
    |  warm,    |       |  arch     |       |  spirit     |
    |  glowing  |       |  from     |       |  wood,      |
    |  insects) |       |  surface) |       |  rare       |
    +-----------+       +-----------+       |  herbs,     |
                              |              |  totems)    |
                         [TO SURFACE]        +-------------+
                         (Root Arch)
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Heartwood Shrine | 8x8 | Save point, cutscene location | -- | Ancient root altar pulsing with teal light. Spirit-totems ring the chamber. The Pendulum reacts here in Act I. |
| Vessa's Chamber | 8x6 | Spirit-speaker's lodge | Vessa | Carved root walls covered in old script. Totems shake when the Pendulum is near. Quest-giver for Maren's Refuge. |
| Herbalist Alcove | 8x6 | Healing hut / potion shop | Herbalist NPC | Natural remedies: root-salves (potion), spirit-moss compress (hi-potion), heartwood tea (status cure). |
| Trader's Nook | 6x6 | Trade goods | Trader NPC | Barter-based. Accepts spirit tokens and Valdris gil at poor rates. Unique: root-woven charms, heartwood pendants. |
| Hunter's Lean-to | 6x4 | Weapon cache (exterior) | Hunter NPC | Bows, spears, root-hardened daggers. No metal weapons. Nature-crafted only. |
| Guest Hollow | 8x6 | Inn (rest among the roots) | -- | Hammocks woven from root-silk. Bioluminescent moss nightlights. Full HP/MP/AC restore, clears ailments. |
| Elder's Alcove | 6x6 | Governance / lore | Elder NPC | Root-woven scrolls, tribal records. Optional dialogue reveals Roothollow's founding story. |
| Central Hub | 10x10 | NPC gathering, navigation | Various | Open chamber where root passages converge. Totems at each exit glow to mark passages. |
| Herb Garden (exterior) | 8x6 | Atmospheric, gather point | Herbalist | Cultivated patches between roots. Glowing plants, spirit-touched flowers. |
| Children's Hollow | 6x4 | Environmental storytelling | Child NPCs | Small, warm, filled with glowing insects the children keep as pets. |

### Trade Goods

**Currency system:** Roothollow uses spirit tokens -- small heartwood discs carved with spirit-marks. They may grudgingly accept Valdris gil, valuing it well below local spirit tokens ("Your metal coins mean nothing to the roots"), but without any fixed conversion rate. Compact gold is refused entirely. Barter is preferred -- bring pelts, herbs from other regions, or news.

**Unique items (only available here):**

| Item | Type | Effect | Price (Spirit Tokens) |
|------|------|--------|-----------------------|
| Root-Salve | Consumable | Restores 200 HP | 3 tokens |
| Spirit-Moss Compress | Consumable | Restores 500 HP | 8 tokens |
| Heartwood Tea | Consumable | Cures all status ailments | 5 tokens |
| Root-Silk Thread | Accessory material | Used in spirit-weaving crafting | 12 tokens |
| Vessa's Blessing | Key item | Grants safe passage deeper into the Wilds | Quest reward |
| Totem of Warding | Accessory | +10% spirit damage resistance | 20 tokens |
| Bioluminescent Lantern | Key item | Lights dark areas in the Wilds | 6 tokens |

**Items NOT sold here:** Metal weapons, Arcanite components, Forgewright tech, Compact-manufactured goods of any kind. If the player tries to sell Compact items, the trader recoils: "Take that dead thing away from my roots."

### Points of Interest

- **The Heartwood Shrine:** The oldest part of the settlement. The root altar predates the tribe -- they built around it. The altar pulses in sync with the ley line beneath. In Act I, when the Pendulum is brought near, every totem in the chamber vibrates and Vessa's warning scene triggers.
- **The Great Tree Canopy:** Accessible via a root-ladder in the Central Hub. The upper area is an optional exploration zone in Act I -- the canopy is its own ecosystem with different flora, fauna, and a hidden spirit creature that gives a lore hint about the Convergence.
- **Root-Weaver's Workshop (hidden):** Behind a false root wall in the Elder's Alcove (interact with the third totem from the left). A small chamber where the tribe's root-weavers practice their art -- growing architecture from living roots. Contains a unique accessory: the Root-Weaver's Ring (+15% nature magic).
- **The Sap Channels:** Visible in the walls of every chamber -- golden-amber lines of sap flowing through the root network. In Act I they pulse warmly. In the Interlude, the sap has slowed to a trickle and turned grey-brown. This is the first visual indicator of the great tree's petrification.
- **Spirit Visitors:** Faint translucent shapes (small animals, wisps) drift through the root chambers. They are decorative in Act I -- curious, watching. In the Interlude, they are gone. The emptiness is the point.

### Act-by-Act Changes

**Act I (Base State):**
- Full bioluminescence. Teal-cyan light from moss, purple glow from totems. The root chambers feel warm, alive, safe.
- All NPCs present. Children play in the Children's Hollow. The Herb Garden is thriving.
- The sap channels pulse with warm amber light.
- Spirit visitors drift through the chambers.
- The Heartwood Shrine save point is fully active.

**Act II (Diplomatic State):**
- Subtle tension. Vessa's dialogue is sharper -- she remembers the Pendulum. The tribe is debating the alliance.
- The Herb Garden has new plants -- Vessa has been preparing for something.
- A delegate from Greywood Camp is present in the Central Hub.
- The sap channels pulse slightly faster -- the tree senses the ley line instability.
- New dialogue options for all NPCs reflecting the political situation.

**Interlude (Petrifying State):**
- **The great tree is turning to stone.** Bark tiles shift from warm brown to grey stone. Sap channels are frozen. Bioluminescent moss is dead -- replaced by dim grey light from cracks in the petrifying wood.
- Root passages have collapsed sections -- rubble, timber bracing, detour paths. The map layout changes: two passages are blocked, forcing new routes through the chambers.
- Vessa is directing the evacuation from the Entry Chamber. Refugees are streaming out.
- The Heartwood Shrine's altar is cracked. The save point still functions but the visual is damaged.
- Torren is in the Heartwood Shrine, burning his life force to slow the petrification. His sprite glows with a desperate amber light against the grey.
- Spirit visitors are gone. The silence is oppressive.
- The boss fight (corrupted root-spirit) triggers in the Central Hub -- roots thrashing, stone shards flying.
- After stabilization: the petrification halts but does not reverse. The tree is half-stone, half-living. New bark grows around the stone sections. The bioluminescence returns at half-brightness -- teal light fighting through grey.

**Epilogue (Healing State):**
- New bark growing around petrified sections. Living root grafts replacing timber bracing.
- New spirit-totems being carved by the returned tribe.
- The sap channels flow again -- warm amber, slightly brighter than Act I.
- Bioluminescence is stronger than before -- the Deep Forest palette note about "brighter bioluminescence" applies.
- The petrified root sections remain as permanent scars -- grey stone monuments within living wood. The tree remembers.

---

## 2. Duskfen

### Settlement Overview

**Type:** Marsh platform settlement on stilts and woven reed
**Faction:** Duskfen Tribe
**Acts:** II, Interlude
**Approximate size:** 56x48 tiles (the water extends to all edges -- the settlement floats in the marsh)

Duskfen is built on nothing solid. Every structure sits on platforms of woven reeds and preserved wood, driven into the marsh on pilings. Rope bridges connect the platforms over black, still water. The canopy breaks here -- the sky is visible but always overcast, a grey-green wash. Will-o'-wisp lanterns provide the only reliable light, and that light flickers. The Thornmere Wetlands palette dominates: olive, mud-brown, sickly yellow-green marsh gas glow. Fog is constant. Visibility drops to 4-5 tiles in places.

**Layout philosophy:** Archipelago. Platforms are scattered across the marsh like islands, connected by a web of rope bridges. There is no center in the traditional sense -- the Spirit-Binding Workshop is the largest platform and serves as the social hub, but the tribe's life is distributed across a dozen smaller platforms. Navigation requires crossing bridges, some of which sway and creak. The player must learn the bridge network to traverse efficiently.

**Terrain relationship:** The marsh IS the settlement. The tribe built on the water because the water is sacred -- the Fenmother sleeps beneath. Pilings are driven deep into the mud. Reed platforms flex underfoot. The water is black, still, and reflects the will-o'-wisp light in unsettling ways. Occasionally, something large moves beneath the surface -- a shadow, never fully visible.

### ASCII Settlement Map

```
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~                           FOG                            ~
    ~      [Wisp]                              [Wisp]          ~
    ~         *         ====rope====            *              ~
    ~    +--------+     =          =     +----------+          ~
    ~    | WATCH  |=====           ======| FISHER'S |          ~
    ~    | POST   |                      | PLATFORM |          ~
    ~    | (Tavin |     [Wisp]           | (nets,   |          ~
    ~    |  scope)|       *              | traps,   |          ~
    ~    +---+----+                      | catch)   |          ~
    ~        |rope                       +----+-----+          ~
    ~        |                                |rope            ~
    ~   +----+------+                    +----+------+         ~
    ~   | CADEN'S   |                    | HEALER'S  |         ~
    ~   | PLATFORM  |======rope==========| STILTS    |         ~
    ~   | (spirit-  |                    | (herbs,   |         ~
    ~   |  speaker, |                    |  salves,  |         ~
    ~   |  quest)   |     [Wisp]         |  shop)    |         ~
    ~   +----+------+       *            +----+------+         ~
    ~        |rope                            |rope            ~
    ~        |                                |                ~
    ~   +----+----------+              +------+------+         ~
    ~   |   SPIRIT-     |              |  GUEST      |         ~
    ~   |   BINDING     |===rope=======|  PLATFORM   |         ~
    ~   |   WORKSHOP    |              | (reed mats, |         ~
    ~   |  (crafting,   |              |  hammocks,  |         ~
    ~   |   totems,     |              |  rest/save) |         ~
    ~   |   shop)       |              +------+------+         ~
    ~   +----+----------+                     |rope            ~
    ~        |rope                            |                ~
    ~        |              [Wisp]       +----+------+         ~
    ~   +----+------+         *          | ELDER'S   |         ~
    ~   | TRADER'S  |                    | REED HUT  |         ~
    ~   | RAFT      |======rope==========| (tribal   |         ~
    ~   | (floating |                    |  lore,    |         ~
    ~   |  barge,   |                    |  records) |         ~
    ~   |  goods)   |                    +----+------+         ~
    ~   +----+------+                         |rope            ~
    ~        |rope                            |                ~
    ~        |          +----------+          |                ~
    ~        |          | CENTRAL  |          |                ~
    ~        +===rope===| LANDING  |===rope===+                ~
    ~                   | (main    |                           ~
    ~                   |  arrival |                           ~
    ~                   |  dock)   |                           ~
    ~                   +----+-----+                           ~
    ~                        |                                 ~
    ~                   ROPE & PLANK                           ~
    ~                   PATH TO                                ~
    ~                   MARSH EDGE                             ~
    ~                        |                                 ~
    ~                   ===========                            ~
    ~                   = TO DEEP  =                           ~
    ~                   = MARSH    =  (Fenmother's Hollow)     ~
    ~                   ===========                            ~
    ~                                                          ~
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            [Black water, still, reflecting wisps]
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Central Landing | 8x6 | Entry dock, navigation hub | -- | Reed-and-plank dock where visitors arrive. A single large totem marks the landing -- spirit-bound, it glows when outsiders approach (alarm). |
| Caden's Platform | 8x6 | Spirit-speaker's lodge, quest hub | Caden | Caden's dwelling. Spirit-totems ring the platform edge. The platform has a reed-walled private chamber and an open ritual space. Quest trigger for Fenmother's Hollow. |
| Spirit-Binding Workshop | 10x8 | Unique crafting shop | Workshop Keeper | The largest platform. Spirit-binding is performed here -- temporarily housing willing spirits in objects. Unique shop: spirit-bound accessories with temporary buffs. |
| Healer's Stilts | 6x6 | Healing hut | Healer NPC | A raised hut on extra-tall stilts. The healer uses marsh herbs and spirit-salves. Sells: marsh-remedy (potion), wisp-balm (status cure), deepwater tonic (MP restore). |
| Trader's Raft | 6x6 | Trade goods | Trader NPC | A floating barge moored to a piling. The trader deals in marsh goods: eel-leather, wisp-glass, fenwood. Accepts spirit tokens and barter. |
| Guest Platform | 6x6 | Rest / save point (inn equivalent) | -- | Reed mats and hammocks slung between pilings. The sound of water lapping beneath. Full HP/MP/AC restore, clears ailments. A spirit-totem at the platform's center serves as the save point -- its will-o'-wisp glow is amber-gold (matching the universal save point visual). |
| Fisher's Platform | 6x6 | Atmospheric, gathering | Fisher NPCs | Nets, traps, and the day's catch. Fish here are strange -- pale, eyeless, bioluminescent. The fishers are matter-of-fact about it. |
| Watch Post | 6x4 | Perimeter lookout | Tavin (visits) | Elevated platform at the settlement's edge. A crude telescope made from reed tubes and polished fenwood. Tavin uses it to watch the Compact border. |
| Elder's Reed Hut | 6x6 | Governance, lore | Elder NPC | A reed-walled hut with a low ceiling. Tribal records carved on fenwood tablets. The elder is old and speaks rarely, deferring to Caden on spiritual matters. |

### Trade Goods

**Currency system:** Duskfen uses spirit tokens like all Thornmere settlements but also accepts barter in kind. They trade in marsh goods and spirit-bound objects. Valdris gil is accepted grudgingly ("Outsider metal. It buys you less than you think"). Compact gold is spat upon.

**Unique items (only available here):**

| Item | Type | Effect | Price |
|------|------|--------|-------|
| Spirit-Bound Charm (temporary) | Accessory | +20% elemental damage for 3 battles, then fades | 15 tokens |
| Wisp-Glass Lens | Key item | Reveals hidden spirit paths in the marsh | 10 tokens |
| Fenwood Shield | Equipment | Water resistance +25%, light weight | 30 tokens |
| Marsh-Remedy | Consumable | Restores 300 HP, cures Poison | 4 tokens |
| Deepwater Tonic | Consumable | Restores 80 MP | 6 tokens |
| Eel-Leather Vest | Equipment | DEF +12, water resistance +10% | 25 tokens |
| Spirit-Binding Totem (blank) | Crafting material | Required for spirit-binding at the Workshop | 8 tokens |

**Items NOT sold here:** Anything metal. Anything Compact-made. Anything that requires fire to forge. The Duskfen work with water, reed, spirit, and wood. Metal is an insult to the marsh.

### Points of Interest

**Save Points:**
- Guest Platform -- spirit-totem save point (amber-gold glow). Primary save before Fenmother's Hollow dungeon.

- **The Fenmother's Shadow:** After the Fenmother is cleansed in the dungeon, her shadow is visible beneath the surface near the Central Landing -- a vast, serpentine shape, dormant and peaceful. A visual reminder of what the party saved. Interactable for a lore text: "She sleeps. The water is warmer above her."
- **Rope Bridge Network:** Eleven rope bridges connect the platforms. Each bridge is 2 tiles wide and sways slightly (animated). In the Interlude, three lower bridges are submerged or hanging loose -- the player must find alternate routes across makeshift plank bridges.
- **The Deep Marsh Path:** South of the Central Landing, a path of stepping stones and submerged planks leads into the deep marsh toward the Fenmother's Hollow dungeon entrance. Fog is thickest here. Will-o'-wisps cluster and scatter.
- **Spirit-Binding Demonstration:** First visit triggers a short scene where the Workshop Keeper demonstrates spirit-binding -- coaxing a small water spirit into a carved totem. The spirit enters willingly, the totem glows, and the Keeper explains the process. This is the lore introduction to Duskfen's unique magic.
- **The Marsh Beneath:** The black water between platforms is not empty. Small animations play -- ripples, a fin breaking the surface, a brief glow from below. In Act II, these are natural and atmospheric. In the Interlude, the water is perfectly still. Nothing moves. The absence is the horror.

### Act-by-Act Changes

**Act II (Base State):**
- Full Thornmere Wetlands palette. Fog, flickering will-o'-wisps, alive and atmospheric.
- All platforms accessible. All rope bridges intact.
- The Fenmother's shadow is NOT visible until after the dungeon is cleared.
- Caden is suspicious but engages. The tribe watches from platform edges.
- Spirit-binding Workshop is fully operational -- the Keeper demonstrates on first visit.
- Water is dark but alive: ripples, fish, occasional glow.

**Interlude (Half-Submerged State):**
- **The marsh has risen.** The lower third of the settlement is underwater. Three platforms (Fisher's Platform, parts of the Central Landing, and the Trader's Raft) are submerged or barely above water.
- Lower rope bridges hang loose or are underwater. New makeshift plank bridges connect surviving upper platforms -- narrower, less stable (1 tile wide).
- Will-o'-wisp lanterns are OUT. Replaced by grey points of light that do not flicker. The visual shift from warm yellow-green to cold grey is stark.
- The fog is grey instead of grey-green. The smell description in NPC dialogue: "The marsh doesn't smell anymore. It doesn't smell like anything."
- Water is perfectly flat. No ripples, no life movement. The Fenmother's shadow is gone -- the water is empty and grey.
- Caden leads the remnant tribe on the highest platforms. He is grim but holding. His dialogue is clipped, exhausted.
- The Spirit-Binding Workshop is partially flooded -- accessible but limited. The totems on the shelves are inert.
- NPC count is halved. Those who remain are quiet, shell-shocked.
- The settlement is a visual shock -- designed to show the player that the Wilds are dying.

---

## 3. Ashgrove

### Settlement Overview

**Type:** Sacred clearing / inter-tribal meeting ground
**Faction:** Ashgrove Circle (no permanent residents)
**Acts:** II, III
**Approximate size:** 64x64 tiles (the clearing is large -- half a mile across in lore, compressed for gameplay)

Ashgrove is not a village. It is a clearing -- the largest open space in the Wilds, where the canopy parts in a perfect circle and the sky is visible. The ground is covered in pale ash from a tree that burned here in a past age, and nothing has grown in the ash since. The tribes gather here for councils, spirit-rites, and trade. When there is no gathering, Ashgrove is empty, silent, and haunted by a thousand years of preserved footprints.

**Layout philosophy:** Ceremonial ring. The Council Stones at the center are the focal point. Everything else -- temporary shelters, market stalls, fire pits -- arranges in concentric rings outward from the stones. The First Tree stump occupies the northern edge, ancient and massive. The ash field preserves every footprint, so the ground is textured with the accumulated tracks of centuries.

**Terrain relationship:** The clearing sits BELOW the canopy line. The surrounding forest forms a wall of dark green, and the transition from forest to ash is abrupt -- one step from root-matted earth to pale, silent ground. The sky above is the only natural sky visible deep in the Wilds. At night, the stars are visible here and nowhere else in the central forest.

### ASCII Settlement Map -- Act II Gathering State

```
    DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
    D   DENSE FOREST WALL (impassable canopy, dark green)       D
    D                                                           D
    D     +============+                                        D
    D     | FIRST TREE |     . . . . ASH FIELD . . . . .       D
    D     |   STUMP    |   .  (footprints visible in   .       D
    D     | (ancient,  |  .    the pale ground)         .       D
    D     |  massive,  | .                               .      D
    D     |  lore)     |.         [Standing]              .     D
    D     +============+        [  Stone  ]                .    D
    D          .               [  Circle   ]                .   D
    D         .              +--[  (Council ]--+             .   D
    D        .              /   [  Stones)  ]   \            .  D
    D       .     +------+ /                     \ +------+  .  D
    D      .      |WILDS |/     COUNCIL FIRE      \|VALDRIS| .  D
    D     .       |CAMP  |        (central)        |ENVOY  |.   D
    D      .      |TENTS |                         |TENT   | .  D
    D       .     +------+ \                     / +------+  .  D
    D        .              \   [  Standing ]   /            .  D
    D         .              +--[  Stones   ]--+             .  D
    D          .                [  (ring)   ]                .  D
    D           .                                           .   D
    D   +--------+  .                               .  +------+ D
    D   |GREYWOOD|     .     TEMPORARY MARKET      .   |SPIRIT| D
    D   |DELEGATE|       .  +-+  +-+  +-+  +-+  .     | FIRE | D
    D   |CAMP    |         .|M|  |M|  |M|  |M|.       |(ritual| D
    D   +--------+          +-+  +-+  +-+  +-+        | site) | D
    D                .                             .   +------+ D
    D                  .  . . . . . . . . . . .  .              D
    D                                                           D
    D         +----------+                  +----------+        D
    D         | ROOTHOLLOW               | DUSKFEN   |        D
    D         | DELEGATE |                  | DELEGATE |        D
    D         | CAMP     |                  | CAMP     |        D
    D         +----------+                  +----------+        D
    D                                                           D
    D     <-- PATH TO       ASH FIELD         PATH TO -->       D
    D         ROOTHOLLOW    (continues)       GREYWOOD          D
    D                                                           D
    DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
                               |
                          PATH TO DUSKFEN
                          (south, into marsh)
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Council Stones | 12x12 | Ceremonial center, cutscene location | All tribal leaders | Ring of standing stones, ancient, carved with spirit-marks. The alliance cutscene plays here. Central fire pit (sacred, not cooking). |
| First Tree Stump | 8x8 | Lore marker | -- | Massive stump at the clearing's north edge. Optional interaction reveals the founding myth of the Wilds. The stump is charred black, ancient beyond dating. |
| Temporary Market (4 stalls) | 4x4 each | Trade during gatherings | Various traders | Only present during Act II gathering. Rare spirit-crafted items, inter-tribal goods, unique equipment. Dismantled otherwise. |
| Delegate Camps (4) | 6x4 each | Faction/tribe camps | Tribal delegates | Roothollow, Duskfen, Greywood, and Canopy Reach each have a camp. Tents around small fires. Diplomacy NPC conversations. |
| Valdris Envoy Tent | 6x4 | Party's diplomatic base | Edren (during negotiations) | Where the party sleeps during the gathering. Valdris banner outside -- the only non-organic flag in the clearing. |
| Spirit Fire | 6x6 | Ritual site | Spirit-speakers | A separate sacred fire on the clearing's east edge. Spirit-speakers from all tribes perform a joint blessing. Optional scene if attended. |
| Wilds Camp Tents | 6x4 | Tribal camp | Various | Temporary shelters for the Wilds tribes. Hide tents, reed-woven screens, cooking fires. |

### Trade Goods

**Currency system:** During gatherings, all Thornmere currency systems coexist. Spirit tokens are universal. Barter is active. The temporary market is the best place in the Wilds to find rare items because all tribes bring their specialties. Valdris gil is accepted at the market -- the traders are pragmatic about outsider money during large gatherings.

**Unique items (only available during Act II gathering):**

| Item | Type | Effect | Price |
|------|------|--------|-------|
| Ashgrove Ember | Accessory | Fire resistance +30%, faint warmth in cold areas | 40 tokens |
| Spirit-Crafted Bow | Weapon | ATK +28, chance to inflict Spirit Burn | 50 tokens |
| First Ash Pendant | Accessory | +5% all elemental resistance, lore flavor text | 35 tokens |
| Canopy Scout's Cloak | Equipment | SPD +8, reduces encounter rate in forests | 30 tokens |
| Duskfen Spirit Totem (charged) | Accessory | Temporary: +25% magic damage for 5 battles | 20 tokens |
| Greywood Longbow | Weapon | ATK +24, range advantage in back row | 35 tokens |

### Points of Interest

**Save Points:**
- Valdris Envoy Tent (Act II gathering only) -- a Valdris waystone carried by the diplomatic party, providing a save point with the universal amber-gold glow. Only present during the Act II gathering; removed after the gathering disperses.

- **The Preserved Footprints:** The ash preserves every footprint perfectly. Walking through Ashgrove, the player walks on the tracks of a thousand years of tribal history. An environmental detail that rewards inspection -- examining different footprint clusters reveals lore fragments about past gatherings.
- **The Council Stones:** Ancient standing stones in a perfect ring. Carved with spirit-marks in a script older than any living tribe can read. The alliance cutscene in Act II is the emotional climax of the diplomatic arc -- all three tribes, one fire, one decision.
- **The First Tree Stump:** Interact for lore: the burned tree was the first tree, from which all the Wilds grew. Its death created the clearing. The tribes gather here to remember that everything in the Wilds began with loss and regrowth. This mirrors the game's theme directly.
- **The Spirit Fire:** An optional scene during Act II. If the player attends the joint spirit-blessing, all party members receive a temporary buff (Spirit Ward: +10% spirit resistance for the next dungeon). The blessing scene is one of the most visually striking in the game -- all tribes' spirit-speakers channeling together, ley line light rising from the ash.

### Act-by-Act Changes

**Act II (Gathering State):**
- The clearing is alive with activity. Four delegate camps, a market, cooking fires, tribal banners.
- The ash is pale cream-white. Footprints are clearly visible.
- The sky above is open -- the only place in the deep Wilds where stars are visible.
- The Council Stones are lit by the central fire. The standing stones cast long shadows.
- The alliance cutscene plays here -- the culmination of Act II's diplomatic arc.

**Act III (Grey-Touched State):**
- The Pallor has reached Ashgrove. The ash field has turned uniform grey -- indistinguishable from the Pallor's corruption. The footprints are filling in, erasing.
- The standing stones are fading into the grey background -- still present but losing definition.
- The temporary market is gone. The delegate camps are abandoned -- cold fire pits, collapsed tents.
- The party passes through on the march to the Convergence. A short, somber scene. No NPCs. Silence.
- The First Tree stump is grey but still solid. It endures.

**Epilogue (Sprouting State):**
- Ashgrove's ash is still pale, but tiny green shoots appear at the edges of the clearing -- the first growth in a thousand years.
- The First Tree stump has a single bud. One green leaf.
- The preserved footprints are still there. The standing stones are visible again.
- Tribal delegates are re-establishing the gathering ground. New fires, new tents.
- Nothing is erased. Growth returns where it has not been for an age.

---

## 4. Canopy Reach

### Settlement Overview

**Type:** Treetop village across multiple vertical levels
**Faction:** Canopy Tribe
**Acts:** II
**Approximate size:** 48x64 tiles across 3 vertical layers (Ground Level, Mid-Canopy, Upper Canopy), connected by ladders and rope bridges

Canopy Reach is two hundred feet above the forest floor, built entirely in the upper branches of the Thornmere's tallest trees. The player arrives by climbing -- a long ladder ascent from the forest floor that establishes the verticality before any platform is reached. The settlement exists on three layers: the Ground Level (arrival point, storage), the Mid-Canopy (living quarters, workshops), and the Upper Canopy (Wynne's observatory, the wind-spirit shrine). Rope ladders and vine bridges connect everything. The sky is visible through breaks in the canopy. Light is natural here -- filtered green-gold -- unlike the bioluminescent depths below.

**Layout philosophy:** Vertical web. Platforms are built into the crotches of massive branches, some carved from living wood, others woven from vine and branch. No two platforms are at the same height. The player navigates by climbing ladders between levels and crossing rope bridges between trees. The settlement feels precarious and beautiful -- a village that defies gravity through generations of careful construction.

**Terrain relationship:** The trees ARE the settlement. Platforms are notched into branches. Walls are living bark. Rope bridges span the gaps between trunks. The wind is constant -- the canopy sways, and everything moves slightly. Below, the forest floor is invisible, lost in darkness and mist. Above, the sky.

### ASCII Settlement Map -- Multi-Level

```
=== UPPER CANOPY (Level 3) ===

              [Sky visible -- clouds, sun, stars at night]

         +------------+              +-----------+
         | WYNNE'S    |              | WIND-     |
         | OBSERVATORY|==rope bridge=| SPIRIT    |
         | (highest   |              | SHRINE    |
         |  point,    |              | (optional |
         |  panoramic |              |  spirit   |
         |  view)     |              |  scene)   |
         +-----+------+              +-----+-----+
               |ladder                     |ladder
               |                           |
               v                           v

=== MID-CANOPY (Level 2) ===

    +----------+        +--------+        +----------+
    | SCOUT    |        | BRANCH |        | NEST     |
    | QUARTERS |==rope==| HALL   |==rope==| HAMMOCKS |
    | (archery |        | (open  |        | (rest/   |
    |  shop)   |        |  air,  |        |  save,   |
    +----+-----+        | gather |        |  inn)    |
         |              |  space)|        +----+-----+
         |              +---+----+             |
         |                  |                  |
         |              +---+----+             |
         |              | WEAVER |             |
         |              | PLAT-  |             |
         |              | FORM   |             |
         |              | (craft)|             |
         |              +---+----+             |
         |                  |                  |
    +----+-----+        +---+----+        +----+-----+
    | HEALER'S |        | CANOPY |        | TRADER'S |
    | PERCH    |==rope==| HUB    |==rope==| BRANCH   |
    | (herbs,  |        | (main  |        | (goods,  |
    |  shop)   |        |  plat- |        |  barter) |
    +----------+        |  form) |        +----------+
                        +---+----+
                            |ladder
                            |
                            v

=== GROUND LEVEL (Level 1 -- forest floor arrival) ===

                        +----------+
                        | ARRIVAL  |
                        | PLATFORM |
                        | (base of |
                        |  great   |
                        |  tree,   |
                        |  storage)|
                        +----+-----+
                             |
                        PATH FROM
                        CANOPY ASCENT
                        ROUTE
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Level | Notes |
|-----------|-----------|----------|---------|-------|-------|
| Arrival Platform | 8x6 | Entry, storage | Guard NPC | Ground | Base of the largest tree. Rope ladder begins here. Storage crates, supplies for the climb. |
| Canopy Hub | 10x8 | Central navigation | Various | Mid | The main platform. Carved from a massive branch junction. All Mid-Canopy bridges connect here. Spirit-totem at center. |
| Scout Quarters | 8x6 | Weapon shop | Scout Leader | Mid | Archery-focused equipment. Bows, quivers, vine-rope, sling-stones. The Canopy Tribe's scouts train here. |
| Branch Hall | 8x8 | Open gathering space | -- | Mid | An open-air platform with woven vine railings. Used for tribal meetings and meals. Wind chimes made from carved wood hang from branches above. |
| Nest Hammocks | 8x6 | Inn (rest among the branches) | -- | Mid | Hammocks woven from vine and leaf, slung between branches. The wind rocks them. Full HP/MP/AC restore, clears ailments. |
| Healer's Perch | 6x6 | Healing hut | Healer NPC | Mid | A small platform with a leaf-thatch roof. Canopy herbs, wind-dried medicinals. |
| Trader's Branch | 6x6 | Trade goods | Trader NPC | Mid | A platform built around a branch. Goods are displayed in woven baskets hanging from hooks. |
| Weaver Platform | 6x6 | Crafting, atmospheric | Weaver NPC | Mid | Where the tribe's vine-weavers work -- making rope, bridges, baskets, clothing. |
| Wynne's Observatory | 10x8 | Story cutscene, lore | Wynne | Upper | The highest point in the settlement. A circular platform with a 360-degree view. The panoramic cutscene triggers here. |
| Wind-Spirit Shrine | 8x6 | Optional spirit scene | -- | Upper | A small platform with a carved wind-spirit totem. Wind chimes surround it. If visited, a wind-spirit communes with the party -- hints about the Pallor's spread in the upper atmosphere. |

### Trade Goods

**Currency system:** Canopy Reach uses spirit tokens and barter. The tribe values lightweight, useful goods -- rope, dried food, arrow components. They accept Valdris gil without complaint (the Canopy Tribe is the most pragmatic about outsiders).

**Unique items (only available here):**

| Item | Type | Effect | Price |
|------|------|--------|-------|
| Canopy Scout's Bow | Weapon | ATK +22, +15% accuracy | 30 tokens |
| Wind-Chime Charm | Accessory | SPD +5, alerts to ambush (prevents surprise attacks) | 25 tokens |
| Vine-Rope (50 ft) | Key item | Required for certain Wilds traversal puzzles | 5 tokens |
| Skyberry Tonic | Consumable | Restores 400 HP + SPD +3 for 1 battle | 6 tokens |
| Featherleaf Cloak | Equipment | DEF +8, wind resistance +20%, fall damage reduction | 35 tokens |
| Eagle-Eye Salve | Consumable | +25% accuracy for 3 battles | 4 tokens |

### Points of Interest

**Save Points:**
- Canopy Hub spirit-totem (Mid-Canopy) -- the central totem at the Hub platform serves as the settlement's save point, glowing amber-gold. All Mid-Canopy bridges connect to this platform, making it the natural save location.

- **The Panoramic View:** Wynne's observatory provides the first continent-wide perspective. A cutscene plays on first visit: the camera pans across the view -- Valdris Crown's pale towers to the northwest, Corrund's smoke plumes to the southeast, and directly below, the Wilds stretching in every direction. At the center, a faint grey haze over the Convergence. Wynne points it out. Nobody wants to talk about it.
- **The Rope Bridge Network:** Seven rope bridges connect the Mid-Canopy platforms. Each bridge is a traversal experience -- they sway, the view below is vertiginous, and wind effects (parallax) make the crossing feel precarious. One bridge has a loose plank that drops when stepped on (non-lethal, triggers a catch animation).
- **The Wind-Spirit Shrine:** Optional visit. The wind-spirit is a translucent, bird-like creature that hovers above the totem. It speaks in gusts -- the player reads text that appears to blow across the screen. Its message: the upper atmosphere carries a wrongness that is spreading southward from the Wilds' center. Foreshadowing for the Convergence.
- **Below the Canopy:** From any platform edge, looking down shows darkness, mist, and the occasional flicker of bioluminescence far below. A visual reminder of the vertical distance. One NPC mentions: "We haven't gone to the ground in three generations. Why would we? Everything we need is up here."

### Act-by-Act Changes

**Act II (Base State):**
- Full Thornmere Deep Forest (vertical variant). Filtered green-gold light from above. The canopy is open -- sky visible. Wind is constant.
- All platforms accessible. All bridges intact.
- Wynne is available at the observatory. The panoramic view cutscene is the settlement's signature moment.
- The tribe is alert, watchful, but not hostile. They know the party is coming -- scouts tracked them through the Canopy Ascent route.
- The Wind-Spirit Shrine is optional and serene.

**Interlude (Offscreen -- Not Visitable):**
- Canopy Reach is inaccessible during the Interlude. The canopy in this region has partially petrified. Some platforms have fallen as their anchor trees turned to stone.
- The Canopy Tribe evacuated to Greywood Camp. Wynne's fate is referenced in dialogue but not shown.
- If the player tries to access the route: "The path to the canopy is blocked. The trees here are stone. The bridges are gone."
- Wynne's observatory is still standing (offscreen lore) but the view now shows the Pallor's spread -- grey staining half the continent.

---

## 5. Greywood Camp

### Settlement Overview

**Type:** Major tribal encampment in a sheltered valley
**Faction:** Greywood Tribe
**Acts:** II, Interlude
**Approximate size:** 72x56 tiles (the largest Thornmere settlement -- a semi-permanent camp with proto-urban density)

Greywood Camp is the political heart of the Thornmere Wilds. Unlike the organic root-chambers of Roothollow or the precarious platforms of Duskfen, Greywood has a settled, semi-permanent quality. The camp is spread across a wide, sheltered valley where greywoods -- tall, pale-barked trees unique to this region -- grow in dense groves. The camp consists of hide tents, carved-wood longhouses, and open gathering spaces arranged around a central fire pit large enough to seat two hundred. This is the closest thing the Wilds have to a town, and it still looks nothing like one.

**Layout philosophy:** Concentric circles radiating from the central fire pit. The innermost ring is governance -- the Elder's Tent, Grandmother Seyth's tent, the Council area. The middle ring is communal -- the crafting circle, the healing lodge, the trader's area. The outer ring is residential -- family tents, the children's area, and the perimeter patrols. Paths between tents are worn earth, not constructed. The camp grew organically over decades.

**Terrain relationship:** The valley provides natural shelter -- hills on three sides, with the greywoods providing a canopy that is thinner than the deep forest but still filters the light to a dappled warmth. The trees' pale bark gives the camp a distinctive look -- almost ghostly in morning mist, warm and welcoming in afternoon sun. The valley floor is firm, dry earth -- a contrast to the marshes nearby.

### ASCII Settlement Map

```
    GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
    G  GREYWOOD FOREST (pale-barked trees, dappled light)         G
    G                                                             G
    G    [Kael's       +----------+           +----------+        G
    G     Patrol] *    | RANGER   |           | LOOKOUT  |        G
    G                  | POST     |           | TOWER    |        G
    G  +---------+     | (Kael's  |           | (wooden, |        G
    G  |PERIMETER|     |  base)   |           |  tree-   |        G
    G  |MARKER   |     +----+-----+           |  mounted)|        G
    G  +---------+          |                 +----------+        G
    G        .              |path                                 G
    G         .        +----+-----+                               G
    G          .       | SEYTH'S  |      +---------+              G
    G           .      | TENT     |      | DORIN'S |              G
    G            .     | (oral    +--path-| CRAFT  |              G
    G             .    | history) |      | CIRCLE  |              G
    G    +---------+   +----+-----+      | (totems,|              G
    G    | ORUN'S  |        |            | carving)|              G
    G    | TENT    |        |path        +---------+              G
    G    | (young  |   +----+------+                              G
    G    | warrior)|   | ELDER'S   |                              G
    G    +---------+   | TENT      |    +----------+              G
    G                  | (Savanh,  +path+| HEALER'S|              G
    G                  | diplomacy)|    | LODGE   |              G
    G                  +----+------+    | (herbs, |              G
    G                       |           | salves, |              G
    G                       |path       | shop)   |              G
    G                       |           +---+------+              G
    G   +---------+    +----+------+        |                     G
    G   |CHILDREN'S    |          |    +----+------+              G
    G   | AREA    |    | CENTRAL  |    | TRADER'S  |              G
    G   | (Wren's +path+  FIRE   +path+ LONGHOUSE |              G
    G   | space)  |    |   PIT    |    | (goods,   |              G
    G   +---------+    | (seats   |    | barter)   |              G
    G                  |  200,    |    +-----------+              G
    G                  |  stories,|                               G
    G   +---------+    |  quests) |    +-----------+              G
    G   | FAMILY  |    +----+-----+    | GUEST     |              G
    G   | TENTS   |         |          | TENTS     |              G
    G   | (x4,    +---path--+---path---+ (rest/    |              G
    G   | resid-  |                    |  save)    |              G
    G   | ential) |                    +-----------+              G
    G   +---------+                                               G
    G                                                             G
    G  <-- PATH TO                          PATH TO -->           G
    G      ASHGROVE                         ROOTHOLLOW            G
    G             \                        /                      G
    G              --- PATH TO DUSKFEN ---                         G
    G                   (south)                                   G
    GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Central Fire Pit | 12x12 | Social hub, quest trigger | Various | Seats 200 around a banked fire. Stories, meals, and the "What the Stars Said" quest initiation. The emotional center of the camp. |
| Elder's Tent | 10x8 | Governance, diplomacy | Elder Savanh | The largest tent. Hide walls decorated with spirit-marks. Savanh holds court here. The diplomatic negotiation scene plays inside. |
| Grandmother Seyth's Tent | 8x6 | Oral history, lore | Seyth | Smaller tent packed with memory-objects -- carved sticks, painted stones, knotted cords. Each one is a story. Seyth's oral histories are some of the richest lore in the game. |
| Dorin's Crafting Circle | 8x8 | Crafting, atmospheric | Dorin | Open-air workspace under a greywood canopy. Dorin carves spirit-ward totems. His cracking totems are a barometer of world decline. |
| Healer's Lodge | 8x6 | Healing hut / shop | Healer NPC | Longhouse with herb-drying racks. Sells remedies, poultices, and spirit-salves. The most complete Wilds healing shop. |
| Trader's Longhouse | 8x6 | Trade goods | Trader NPC | The camp's trading center. Inter-tribal goods, weapons, supplies. Accepts all Thornmere currencies. |
| Ranger Post | 6x6 | Patrol hub, side quest | Kael Thornwalker | Kael's operational base. Maps on a central table. "Missing Patrol" side quest triggers here. |
| Lookout Tower | 4x8 | Perimeter, atmosphere | Scout NPC | A wooden tower mounted on a greywood trunk. View over the camp and surrounding forest. |
| Guest Tents | 8x6 | Inn (rest) | -- | Hide tents with bedrolls and a small fire. Full HP/MP/AC restore, clears ailments. The player's base during Act II. |
| Children's Area | 8x6 | Environmental storytelling | Wren | Where the camp's children play and learn. Wren is here, afraid of the dark for the first time. |
| Family Tents (x4) | 6x4 each | Residential, NPC conversations | Various | Family dwellings. Each has a small fire, hanging spirit-wards, and personal touches. NPC conversations vary by act. |
| Orun's Tent | 6x4 | NPC, flavor | Orun | The young warrior's tent. Weapons on display, training dummy outside. His eagerness is palpable. |

### Trade Goods

**Currency system:** Greywood Camp is the Wilds' economic center. Spirit tokens are standard. Barter is active. Valdris gil is accepted at fair rates -- Greywood is pragmatic about outsiders. Compact gold is not accepted but is not met with hostility ("We don't use your minted coins here. Try the border traders.").

**Unique items (only available here):**

| Item | Type | Effect | Price |
|------|------|--------|-------|
| Greywood Longspear | Weapon | ATK +26, reach advantage, +10% vs. beasts | 40 tokens |
| Spirit-Ward Totem (Dorin's) | Accessory | +15% spirit resistance, prevents first spirit ailment per battle | 35 tokens |
| Seyth's Storied Charm | Accessory | +10% EXP gain, lore flavor text from Seyth's tales | 30 tokens |
| Greywood Bark Shield | Equipment | DEF +16, nature resistance +15% | 45 tokens |
| Hunter's Draught | Consumable | ATK +15% for 3 battles | 5 tokens |
| Patrol Rations | Consumable | Restores 250 HP, prevents hunger debuff (Interlude only) | 3 tokens |
| Ranger's Map Fragment | Key item | Reveals hidden paths in the surrounding forest | 15 tokens |

### Points of Interest

**Save Points:**
- Guest Tents -- a spirit-ward totem planted beside the guest fire serves as the save point (amber-gold glow). The player's base during Act II and the Interlude.

- **The Central Fire Pit:** The emotional center of camp life. At night, the entire camp gathers. The fire is always burning. NPCs rotate through -- sometimes telling stories, sometimes arguing, sometimes sitting in silence. The "What the Stars Said" side quest begins when Seyth tells a particular story here.
- **Kael's Patrol Routes:** Visible on the map at the Ranger Post -- colored markers showing patrol boundaries. In Act II, the patrols range wide. In the Interlude, the boundary markers have contracted closer to the camp center. This visual change tells the story of territory lost.
- **The Greywood Trees:** The pale-barked trees that define the camp's visual identity. In Act II, their bark is warm white, almost luminous in dappled light. In the Interlude, the bark at the perimeter is greying at the edges -- white turning to grey, subtly, like frost creeping.
- **Wren's Corner:** In the Children's Area, Wren sits apart from the other children. A single conversation with her about the stars that stopped singing is one of the most affecting moments in the game. Her fear is specific, personal, and devastating in retrospect.
- **The "Missing Patrol" Quest Start:** Kael at the Ranger Post. One of his patrols hasn't returned from the northern route. The quest leads into the deep forest and reveals early signs of corruption.

### Act-by-Act Changes

**Act II (Base State):**
- Full Thornmere Deep Forest (open-forest variant). Greywood trees with pale bark. Dappled light. The camp has a warm, lived-in quality.
- All structures accessible. Full NPC complement.
- The diplomatic negotiation with Savanh is the central event.
- The Central Fire Pit is active every evening -- gathering scene.
- Kael's patrols range wide. The perimeter is secure.
- Children play in the Children's Area. The camp feels safe.

**Interlude (Refugee Camp State):**
- New tent clusters at the camp's edges -- refugees from Roothollow, Duskfen, and smaller settlements. The camp population has doubled.
- The greywood trees at the perimeter are greying at their edges -- bark turning from pale white to pale grey. The corruption is visible but not yet overwhelming.
- The Central Fire Pit burns lower. Fuel is being rationed.
- Savanh is weakened -- the spirit world's collapse has physically aged her. She has passed active leadership to the younger generation.
- Kael's patrol routes have contracted. New boundary markers are closer to the camp center. The map at the Ranger Post tells the story -- red markers where patrols can no longer safely go.
- Refugee NPCs from Roothollow and Duskfen appear in new tent clusters. Their dialogue is displaced, disoriented.
- Orun's tent: he has killed something. His eagerness is gone. He is quiet.
- Wren is not in the Children's Area. She is in Seyth's tent, sleeping on the floor. Seyth is watching over her.
- The Healer's Lodge is overwhelmed -- a queue of NPCs outside.
- The Trader's Longhouse has limited stock -- supply lines are disrupted.

---

## 6. Stillwater Hollow

### Settlement Overview

**Type:** Sacred spring site and spirit-speaker training ground
**Faction:** Thornmere Wilds (no single tribe claims it)
**Acts:** II, Interlude
**Approximate size:** 32x32 tiles (small, intimate, secluded)

Stillwater Hollow is not a settlement in any conventional sense. It is a natural spring in a bowl-shaped depression deep in the forest, where the water surfaces from a ley line nexus and pools in a stone basin with perfect stillness. The water does not ripple. It does not move. It reflects the canopy above like a mirror, so clear that the reflection is indistinguishable from reality. Spirit-speakers have used this place for generations to train apprentices -- the stillness quiets the mind and makes the ley lines easier to hear.

**Layout philosophy:** Minimal. The spring is the center. Everything else exists only to serve the spring's sacred purpose. A ring of carved training stones surrounds the pool. Yara's dwelling is a modest lean-to at the clearing's edge. A single path leads in and out. The space is designed to feel meditative, quiet, apart from the world.

**Terrain relationship:** The Hollow sits in a natural depression -- the player descends into it along a root-stepped path. The canopy above is thick but a single break lets a shaft of filtered light fall on the spring's surface. The stone basin is natural, polished smooth by millennia of water. The ley line beneath is visible to those with spirit-sight as a faint teal glow through the water.

### ASCII Settlement Map

```
    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    F    DENSE FOREST (impassable)    F
    F                                 F
    F      [Ferns]     [Ferns]        F
    F         \          /            F
    F          \   PATH /             F
    F           \  IN  /              F
    F            \    /               F
    F     +-------\--/-------+        F
    F     | YARA'S   |      |        F
    F     | LEAN-TO  | herb |        F
    F     | (modest, | patch|        F
    F     |  pelts,  |      |        F
    F     |  books)  |      |        F
    F     +----+-----+------+        F
    F          |path                  F
    F          |                      F
    F    [Training]   [Training]      F
    F     [Stone]      [Stone]        F
    F         \          /            F
    F          \        /             F
    F     [TS]  \      /  [TS]        F
    F       \    +----+    /          F
    F        \   |    |   /           F
    F    [TS]-+--+POOL+--+-[TS]       F
    F        /   |(still  \           F
    F       /    | water, |  \        F
    F     [TS]   | mirror |  [TS]     F
    F            |clarity)|           F
    F            +----+---+           F
    F                 |               F
    F            [Ley Line            F
    F             Glow --             F
    F             teal,               F
    F             beneath             F
    F             surface]            F
    F                                 F
    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
         [TS] = Training Stone
              (carved seat)
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| The Sacred Spring | 8x8 | Focal point, ley line indicator | -- | Mirror-still water in a natural stone basin. The reflection is perfect. Ley energy visible as faint teal glow beneath. In Act II, the water is clouding. In the Interlude, it is grey. |
| Training Stones (x6) | 2x2 each | Atmospheric, lore | -- | Carved stone seats arranged in a ring around the pool. Generations of spirit-speakers sat here to learn. Each stone is worn smooth, shaped to a body. Examining them gives lore fragments. |
| Yara's Lean-to | 6x4 | NPC interaction | Yara | Modest shelter of branches and pelts. A few books (borrowed from Torren), dried herbs, a sleeping pallet. The shelter is small and personal -- Yara's entire world. |

### Trade Goods

Stillwater Hollow has no shop. It is a sacred site, not a trading post. Yara may offer a single unique item as a gift if the player engages in her full dialogue sequence:

| Item | Type | Effect | Notes |
|------|------|--------|-------|
| Stillwater Pendant | Accessory | MP regen +5% per turn, ley sense (reveals hidden ley interactions) | Gift from Yara after full dialogue in Act II. Cannot be purchased. |

### Points of Interest

- **The Mirror Pool:** The spring's perfect stillness is the defining feature. Looking at the pool shows a reflection so clear that the canopy, the player character, and the sky are rendered as a mirror image. In Act II, the water has become cloudy -- ley contamination. The reflection is blurred. In the Interlude, the water is grey and reflects nothing. The pool is empty and still, but the stillness is now the stillness of death, not meditation.
- **Yara's Dialogue:** Speaking to Yara here provides the first spiritual description of the Pallor. She describes the ley lines as music going out of tune, then silent, then replaced by breathing. This is the most poetic and personal description of the Pallor in the game.
- **Torren's Optional Scene:** If Torren is in the party during Act II, he walks to one of the training stones and sits. A brief scene plays -- he remembers training Yara here. The scene is wordless. He sits, touches the stone, looks at the water. Then stands and rejoins the party. If the player examines the stone afterward: "It's warm. Someone's memory is still in it."
- **The Ley Line Glow:** Visible through the water in Act II as a faint teal-cyan light. By the Interlude, the glow is gone. In the Epilogue, it returns -- but warmer, brighter.

### Act-by-Act Changes

**Act II (Clouded State):**
- The spring is still beautiful but troubled. The water is cloudy -- ley contamination from Compact extraction.
- The training stones are untouched. Yara is present.
- The ley line glow is visible but dim.
- Spirits that once lingered here have retreated.
- Yara describes the change: "A song going out of tune, then silent, then replaced by breathing."

**Interlude (Grey State):**
- The water is grey. It reflects nothing. The pool is still -- the stillness of emptiness, not peace.
- Yara has left to follow Torren. The lean-to is abandoned.
- The training stones are cold. No warmth, no memory residue.
- The ley line glow is gone. The Hollow is silent.
- The empty Hollow is a quiet testament to what was lost.

---

## 7. Sunstone Ridge

### Settlement Overview

**Type:** Ley line nexus site and guardian's camp
**Faction:** Thornmere Wilds (Ashara's guardianship)
**Acts:** II, Interlude
**Approximate size:** 40x24 tiles (narrow and long -- a ridge spine with limited width)

Sunstone Ridge is a long, exposed spine of orange-red rock that rises above the Wilds' canopy in the eastern reaches. The rock contains dense concentrations of crystallized ley energy -- sunstones -- that catch the sunlight and glow with a warm amber light. From the ridge, the ley lines' direction is physically perceptible: the energy flows southeast, toward the Convergence. Ashara, Savanh's daughter, has served as the ridge's self-appointed guardian for a decade.

**Layout philosophy:** Linear. The ridge is narrow -- a walkable spine with steep drops on both sides. The path runs from the ascent point at the south to the summit and ward-stones at the north. Ashara's camp sits at the widest point, midway along the ridge. The ward-stones are ancient, predating the tribes. The sunstone formations jut from the rock like amber teeth.

**Terrain relationship:** The ridge BREAKS the canopy. For the first time in the Thornmere Wilds, the player is above the trees. The sky is open, the wind is real, and the sun is unfiltered. Sunstone formations catch the light and glow amber-orange. The contrast with the dark, bioluminescent forest below is dramatic. This is a place of raw ley energy, exposed and powerful.

### ASCII Settlement Map

```
          N (summit)
          |
    +-----+-----+
    | ANCIENT    |
    | WARD-      |
    | STONES     |
    | (ley wards,|
    |  glowing   |
    |  amber)    |
    +-----+------+
          |
    [Sunstone]  [Sunstone]
     Formation   Formation
    (amber glow) (amber glow)
          |
    +-----+------+
    | ASHARA'S   |
    | CAMP       |
    | (tent,     |
    |  fire pit, |
    |  ward      |
    |  supplies, |
    |  ley-sense |
    |  marker)   |
    +-----+------+
          |
    [Sunstone]  [Sunstone]
     Formation   Formation
          |
    +-----+------+
    | LEY LINE   |
    | VIEWING    |
    | POINT      |
    | (energy    |
    |  flows SE, |
    |  visible)  |
    +-----+------+
          |
    [Sunstone]  [Sunstone]
     Formation   Formation
          |
    +-----+------+
    | ASCENT     |
    | POINT      |
    | (path from |
    |  forest    |
    |  below)    |
    +-----+------+
          |
     PATH FROM
     WILDS BELOW
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Ashara's Camp | 8x6 | NPC hub, guardian's dwelling | Ashara | A weathered tent, a fire pit, and crates of ward-maintenance supplies. Ashara lives simply. Her tools: chalk, carved stones, spirit-ink. |
| Ancient Ward-Stones | 8x6 | Lore, ley line mechanic | -- | Pre-tribal ward-stones at the summit. Covered in carvings older than any tribe can read. They glow when the ley lines are strong and dim when the lines weaken. |
| Ley Line Viewing Point | 6x6 | Foreshadowing, atmosphere | -- | A flat rock at the ridge's midpoint. Stand here and the ley energy's directional pull is visible -- faint amber lines streaming southeast toward the Convergence. |
| Sunstone Formations (x6) | 2x4 each | Environmental, decorative | -- | Crystallized ley energy jutting from the ridge. They catch sunlight and glow warm amber. Each formation can be examined for a lore fragment about ley lines. |

### Trade Goods

Sunstone Ridge has no shop. Ashara is a guardian, not a merchant. She may provide a single unique item as a quest reward if the player assists with ward maintenance:

| Item | Type | Effect | Notes |
|------|------|--------|-------|
| Sunstone Shard | Accessory | Ley magic +20%, glows warm when near ley nexus points | Gift from Ashara after assisting with ward maintenance in Act II. |
| Ward-Stone Fragment | Crafting material | Used in high-level spirit-crafting | Found near the Ancient Ward-Stones (search interaction). |

### Points of Interest

- **The Directional Pull:** At the Ley Line Viewing Point, the player can see the ley energy flowing southeast. Ashara is the first NPC to articulate this: "The lines are draining toward something, and it's thirsty." This is critical foreshadowing for the Convergence.
- **The Ancient Ward-Stones:** Pre-tribal construction. The carvings match the geometric patterns in the Ember Vein -- the first hint of a pre-civilization connection between the ancient ruins. The wards protect the ridge from corruption, but they are weakening.
- **The View:** From the ridge summit, the player sees the Wilds canopy stretching in every direction -- a sea of dark green. To the southeast, a faint grey haze. To the northwest, the distant suggestion of Valdris Crown's towers. The scale of the world is visible from here.
- **Ashara's Isolation:** Her camp is sparse, practical, lonely. She chose this. She maintains the wards because no one else will. Her strained relationship with Savanh (her mother) is visible in dialogue but never melodramatic. Two strong women who disagree about how to serve their people.

### Act-by-Act Changes

**Act II (Base Glowing State):**
- Full amber glow from sunstone formations. The ridge is warm, beautiful, and feels powerful.
- The wards are active. The ward-stones glow steadily.
- Ashara is present, maintaining the wards with practiced care.
- The ley line directional pull is visible -- a subtle but clear environmental effect.
- The ridge feels like a place of power, well-tended and safe.

**Interlude (Dimming State):**
- The sunstones' glow is fading. Amber light weakening toward dull orange, then grey at the edges.
- The wards are failing. Ashara has redrawn them three times -- chalk marks visible on the stones, each layer more desperate. "The energy seeps through like water through cracked stone."
- Ashara's camp is unchanged but her demeanor is desperate. She has not slept.
- The ley line directional pull is stronger -- the drain toward the Convergence is accelerating.
- The ridge feels exposed and vulnerable. What was warm is becoming cold.

---

## 8. Maren's Refuge

### Settlement Overview

**Type:** Hermit's dwelling deep in the Wilds
**Faction:** Unaligned (Maren's personal exile)
**Acts:** I, (III referenced)
**Approximate size:** 24x20 tiles (exterior) + 32x24 tiles (interior -- "larger inside than it should be")

Maren's Refuge is not a settlement. It is a stone cottage half-swallowed by the forest, built (or found) by the exiled mage Maren. The cottage sits where no sunlight reaches, in the deepest part of the Wilds. Bioluminescent moss covers the exterior walls. Roots have grown through the floorboards. Spirit creatures visit regularly -- small, translucent shapes that perch on the roof and watch the party with curiosity.

**Layout philosophy:** Hermit-dense. Every surface inside is covered with something -- books, artifacts, maps, specimens, instruments. The cottage is a lifetime of research compressed into a tiny space. The "larger inside than it should be" effect is old magic (practical space-folding). The exterior is modest; the interior is a library and laboratory.

**Terrain relationship:** The forest has claimed the cottage. Moss on every wall. Roots through the floor. The path to the front door is barely visible -- overgrown, marked only by spirit creatures that hover along the route. Inside, the ley line tap provides warm amber light. The basement library is carved into the root system beneath the cottage, with shelves built between living roots.

### ASCII Settlement Map -- Exterior

```
    FFFFFFFFFFFFFFFFFFFFFFFFFFFF
    F  DEEP FOREST (darkest    F
    F  part of the Wilds, no   F
    F  sunlight, bioluminescent F
    F  moss everywhere)        F
    F                          F
    F     [Spirit   [Spirit    F
    F      Creature] Creature] F
    F        *          *      F
    F                          F
    F   +=====+=========+      F
    F   | COTTAGE       |      F
    F   | (stone,       |      F
    F   |  moss-        |      F
    F   |  covered,     |      F
    F   |  roots        |      F
    F   |  through      |      F
    F   |  walls)       |      F
    F   +=====+===+door=+      F
    F         |    \           F
    F         |     [ley line  F
    F         |      tap --    F
    F         |      faint     F
    F    overgrown   amber     F
    F    path        glow in   F
    F         |      the       F
    F         |      ground]   F
    F         |                F
    F    TO DEEP PATH          F
    F    (from Roothollow)     F
    F                          F
    FFFFFFFFFFFFFFFFFFFFFFFFFFFF
```

### ASCII Settlement Map -- Interior (Ground Floor + Basement)

```
=== GROUND FLOOR ===

    +-----------------------------------+
    |                                   |
    |  [Bookshelf] [Bookshelf] [Shelf]  |
    |                                   |
    |  +------+   +--------+  [Map     |
    |  | WORK |   |FIREPLACE  table,   |
    |  | DESK |   |(ley-    |  world   |
    |  |(notes,   | heated, |  map     |
    |  | the  |   | amber   |  with    |
    |  | Pend-|   | glow)   |  pins]   |
    |  | ulum |   +--------+           |
    |  | exam)|                [Herb    |
    |  +------+   [Artifact   drying   |
    |              display]   rack]    |
    |                                   |
    |  [Spirit     [Chair    [Cot --   |
    |   creature    (worn,    Maren's  |
    |   perch --    reading   bed,     |
    |   they visit  spot)]    books    |
    |   inside]                piled   |
    |                          on it]  |
    |          +------+                 |
    |          | TRAP |                 |
    |     DOOR | DOOR |                 |
    |          |(down)|                 |
    |          +------+                 |
    +-----------------------------------+

=== BASEMENT LIBRARY ===

    +-----------------------------------+
    |                                   |
    |  [Root   [Bookshelf  [Bookshelf   |
    |   arch]   floor-to-   floor-to-   |
    |           ceiling]    ceiling]    |
    |                                   |
    |  +----------+    +-----------+    |
    |  | LEY LINE |    | ARTIFACT  |    |
    |  | TAP      |    | VAULT     |    |
    |  | (glowing |    | (locked,  |    |
    |  |  amber   |    |  contains |    |
    |  |  crystal |    |  pre-civ  |    |
    |  |  in the  |    |  relics)  |    |
    |  |  floor)  |    +-----------+    |
    |  +----------+                     |
    |                                   |
    |  [Research  [Specimen  [Star      |
    |   notes --   jars --    chart --  |
    |   Maren's    strange    ley line  |
    |   Pendulum   flora/     mapping]  |
    |   analysis]  fauna]               |
    |                                   |
    |         +--------+                |
    |         | STAIRS |                |
    |         |  (up)  |                |
    |         +--------+                |
    +-----------------------------------+
```

### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Cottage Exterior | 8x6 | Approach, atmosphere | Spirit creatures (ambient) | Stone walls, moss, roots. The door is wood, old, slightly ajar. Spirit creatures perch on the roof. |
| Main Room (Ground Floor) | 16x12 | NPC interaction, lore, cutscene | Maren | The Pendulum examination scene plays at the Work Desk. Every bookshelf and object is interactable for lore fragments. Dense environmental storytelling. |
| Basement Library | 16x12 | Deep lore, optional exploration | -- | Shelves between living roots. The ley line tap glows amber in the floor. The Artifact Vault is locked (key item from a later quest). Maren's lifetime of research is here. |

### Trade Goods

Maren's Refuge has no shop. Maren is a researcher, not a merchant. The cottage contains quest items and lore objects, not commerce.

**Key items found here:**

| Item | Type | Notes |
|------|------|-------|
| Maren's Analysis Notes | Key item | Received after the Pendulum examination scene. Required for Act I progress. |
| Bioluminescent Lantern (if not bought in Roothollow) | Key item | Found on a shelf. Maren notes: "Take it. The deep places are darker than you think." |
| Ley Line Primer | Lore item | Interactable bookshelf. Explains ley line mechanics in Maren's words. |
| Specimen Jar (Pallor Fragment) | Lore item | In the basement. A tiny grey shard in a sealed jar. Maren: "I found that in a ruin. It was inert. It isn't anymore." |

### Points of Interest

- **The Pendulum Examination:** The central story beat. Maren examines the Pendulum at her Work Desk. The cutscene is extended -- she is methodical, then increasingly alarmed. Her conclusion: "It's not a weapon. It's a door. And something is knocking." This is the moment the game's stakes become clear.
- **The Library:** Every bookshelf is interactable. The player can spend significant time reading Maren's notes on ley lines, pre-civilization ruins, spirit-pact theory, and early observations about the dimming. Dense, optional lore for thorough players.
- **Spirit Visitors:** Small translucent creatures -- a fox-like shape, a moth-like shape, something unidentifiable -- drift through the cottage. They are curious about the party, especially the Pendulum. They are decorative but deeply atmospheric. Maren talks to them casually: "Don't mind them. They've been coming for years. I think I'm their entertainment."
- **The Ley Line Tap:** A glowing amber crystal embedded in the basement floor. The line beneath is weak but stable. The tap provides heat, light, and a faint hum that Maren describes as "the closest thing to a heartbeat this place has." The player can examine it for a lore explanation of ley line mechanics.
- **The Space-Folding:** The interior is noticeably larger than the exterior. If the player comments on it (interact with a specific wall), Maren dismisses it: "Old magic. Came with the property. Don't ask me to explain it -- I've been trying for fifteen years."

### Act-by-Act Changes

**Act I (Base State):**
- The cottage is warm, cluttered, and alive with spirit visitors. The ley line tap glows amber.
- Maren is present. The Pendulum examination scene is the central event.
- The basement library is explorable. Every shelf rewards curiosity.
- The exterior path is overgrown but navigable. Spirit creatures line the approach.

**Interlude (Offscreen -- Abandoned):**
- Maren has left the cottage to seek the ancient ruin. The cottage is referenced but not visitable.
- If the player somehow reaches the area: the cottage is dark. The ley line tap is dim. Spirit creatures are gone. Books are scattered -- Maren left in haste. A note on the desk: "Gone to the Archive. If I'm not back in a month, I was wrong. Don't follow."

---

## 9. Cross-Faction Locations

---

### The Pendulum Tavern (Epilogue)

**Type:** Post-game hub / Sable's tavern
**Faction:** Unaligned
**Acts:** Epilogue only
**Approximate size:** 40x32 tiles (exterior + interior)

Accessible only after completing the main story. Sable's tavern sits at the crossroads where Valdris, the Compact, and the Wilds meet -- the same crossroads where Hadley's Three Roads Inn stood. The building is new construction -- low, comfortable, built from timber and stone by hands that knew both Wilds woodcraft and Compact engineering. The sign swings on a wrought-iron bracket: a painted pendulum on a broken chain. Inside, every party member (except Cael) can be found, along with NPCs the player helped throughout the game.

This is the game's emotional epilogue space and its post-game mechanical hub.

#### Exterior Layout

```
                    [Crossroads -- three paths diverging]
                        /           |           \
                   TO VALDRIS   TO THE WILDS   TO THE COMPACT

                         +--SWINGING SIGN--+
                         |  (pendulum on   |
                         |  broken chain)  |
                         +-----------------+

              +=========================================+
              |              THE PENDULUM               |
              |          (low timber building,          |
              |    stone foundation, new but weathered) |
              |                                        |
              |  [Hitching   +--FRONT--+   [Bench --   |
              |   post]      |  DOOR   |    Edren      |
              |              +----+----+    sits here   |
              |                   |         sometimes]  |
              +=========+========+==========+===========+
                        |        |          |
              [Garden -- |        |    [Woodpile --
               Torren    |        |     practical,
               tends it] |        |     Compact-style
                         |        |     split]
                    +----+---+    |
                    | STABLE  |   |
                    | (Sable  |   |
                    |  keeps  |   |
                    |  one    |   |
                    |  horse) |   |
                    +---------+   |
                                  |
                         [PATH TO DREAMER'S FAULT]
                         (hidden -- unlocked post-game)
```

#### Interior Layout

```
    +---------------------------------------------------+
    |                                                   |
    |   [Bookshelf    [Fireplace -- always             |
    |    -- Maren's    lit, warm amber                  |
    |    donations]    glow]                            |
    |                                                   |
    |   +------+                        +------+        |
    |   |CORNER|    MAIN                |CORNER|        |
    |   |BOOTH |    ROOM                |BOOTH |        |
    |   |(Lira |    (tables,            |(NPC   |       |
    |   | & an |    chairs,             | booth |       |
    |   | engi-|    warm                | -- var|       |
    |   | neer |    light)              | ious) |       |
    |   | argue|                        +------+        |
    |   | about|                                        |
    |   |schem-|    +-----+  +-----+                    |
    |   |atics)|    |TABLE|  |TABLE|    [BESTIARY       |
    |   +------+    |(NPCs|  |(NPCs|     BOARD --       |
    |               | var)|  | var)|     wall-mounted,  |
    |               +-----+  +-----+     all entries]   |
    |                                                   |
    |   +---+                           +---+           |
    |   |KEG|   +=================+     |KEG|           |
    |   +---+   |     THE BAR     |     +---+           |
    |           |  (Sable behind, |                     |
    |           |   serving,      |    [BOSS RUSH       |
    |           |   watching,     |     BOARD --        |
    |           |   remembering)  |     wall-mounted,   |
    |           +=================+     replay fights]  |
    |                                                   |
    |   +------+                        +------+        |
    |   |TROPHY|                        |TROPHY|        |
    |   |CASE  |                        |CASE  |        |
    |   |(story|                        |(story|        |
    |   |items)|                        |items)|        |
    |   +------+                        +------+        |
    |                                                   |
    |           +-----FRONT DOOR------+                 |
    +---------------------------------------------------+

    [Behind the bar -- a door to the back room]

    +---------------------------+
    | BACK ROOM                 |
    |                           |
    | [Sable's    [Cael's       |
    |  private     sword --     |
    |  quarters:   mounted on   |
    |  a cot,      the wall.    |
    |  a lockpick  The only     |
    |  set, a      decoration   |
    |  bottle]     Sable chose] |
    |                           |
    | [DREAMER'S FAULT          |
    |  ENTRANCE -- hidden       |
    |  trapdoor, accessible     |
    |  post-game]               |
    +---------------------------+
```

#### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Main Room | 20x16 | Central hub, NPC conversations | All surviving party members, helped NPCs | Tables, chairs, warmth. Every party member (except Cael) is here. NPCs the player helped throughout the game appear. |
| The Bar | 10x4 | Sable's domain | Sable | Sable behind the bar. Her dialogue: "So nobody forgets what it cost." She serves drinks, trades quips, and is the emotional anchor of the epilogue. |
| Corner Booths (x2) | 4x4 each | Party member conversations | Lira (+ engineer), others | Extended epilogue conversations. Each booth has a party member pair engaged in character-specific dialogue. |
| Bestiary Board | 2x6 (wall) | Post-game mechanic | -- | Wall-mounted board. Interact to review all discovered enemies and lore entries. |
| Boss Rush Board | 2x6 (wall) | Post-game mechanic | -- | Wall-mounted board. Replay any boss fight at enhanced difficulty. |
| Trophy Cases (x2) | 4x3 each | Environmental storytelling | -- | Display cases containing story items -- the Pendulum's broken chain, Maren's first analysis notes, a Compact wrench, a Thornmere totem. Each one is interactable for a memory. |
| Back Room | 10x8 | Sable's quarters, hidden dungeon access | -- | Sable's private space. Sparse. Cael's sword on the wall -- the only decoration she chose. The Dreamer's Fault trapdoor is here. |
| Exterior Garden | 8x6 | Atmospheric | Torren (sometimes) | Torren tends a small garden. Wilds plants growing at the crossroads. A small, quiet act of hope. |
| Stable | 6x4 | Atmospheric | -- | Sable keeps one horse. Practical. She doesn't plan to stay forever but hasn't left yet. |

---

### Gael's Span

**Type:** Bridge-town at the Wilds/Compact border
**Faction:** Contested (Thornmere / Carradan)
**Acts:** II, Interlude
**Approximate size:** 48x32 tiles (the bridge is the central feature, with bluffs on each end)

Gael's Span is a massive stone bridge crossing the Corrund River at its upper reach. The bridge predates both factions. A small settlement has grown on the bluff above: taverns, a provisioner, and guard posts on both ends flying different flags. The visual split is literal -- forest tiles on the Wilds side, industrial tiles on the Compact side. The midpoint is the only place in the game where a player stands in natural daylight between two competing visual worlds.

#### Settlement Map

```
    WILDS SIDE (forest tiles)          COMPACT SIDE (industrial tiles)
    ========================          ==============================

    +----------+                                     +----------+
    | WILDS    |                                     | COMPACT  |
    | GUARD    |                                     | GUARD    |
    | POST     |                                     | POST     |
    | (rangers,|                                     | (soldiers|
    |  Wilds   |                                     |  Compact |
    |  flag)   |                                     |  flag)   |
    +----+-----+                                     +----+-----+
         |                                                |
    +----+-----+                                     +----+-----+
    | WILDS    |                                     | COMPACT  |
    | TAVERN   |                                     | TAVERN   |
    | (mead,   |                                     | (spirits,|
    |  pelts,  |                                     |  metal   |
    |  wood)   |                                     |  tables) |
    +----+-----+                                     +----+-----+
         |                                                |
    +----+-----+     +========================+      +----+-----+
    | WILDS    |     |    THE BRIDGE           |     | COMPACT  |
    | PROVISION|     |  (ancient stone,        |     | PROVISION|
    | ER       +-----+  wide enough for       +-----+ ER       |
    | (herbs,  |     |  caravans,             |     | (metal   |
    |  nature  |     |  arched over           |     |  goods,  |
    |  goods)  |     |  deep gorge)           |     |  tools)  |
    +----------+     |                        |     +----------+
                     |     [MIDPOINT]          |
                     |  (natural daylight,     |
                     |   neutral ground,       |
                     |   the biomes meet)      |
                     |                        |
                     +========================+
                              |
                         [CORRUND RIVER]
                         [deep gorge below]
```

#### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| The Bridge | 24x6 | Central traversal, atmosphere | -- | Ancient stone, wide, arched. The visual transition from forest to industrial tiles happens at the midpoint. |
| Wilds Guard Post | 6x6 | Factional presence | Wilds Rangers | Organic construction -- wood, hide, living-vine reinforcement. Wilds tribal flag. |
| Compact Guard Post | 6x6 | Factional presence | Compact Soldiers | Industrial construction -- prefab metal, brick. Compact flag with gear insignia. |
| Wilds Tavern | 6x6 | Rest, NPC conversations | Tavern Keeper | Thornmere mead, pelts on the walls, carved wood. A slice of the Wilds at the border. |
| Compact Tavern | 6x6 | Rest, NPC conversations | Tavern Keeper | Compact spirits, metal tables and chairs, a Forgewright lamp. Industrial comfort. |
| Wilds Provisioner | 6x4 | Trade | Provisioner | Herbs, nature-crafted goods, spirit tokens accepted. Border pricing (10% markup). |
| Compact Provisioner | 6x4 | Trade | Provisioner | Metal goods, tools, rations. Compact gold and gil accepted. Border pricing. |

#### Act-by-Act Changes

**Act II:** Both guard posts staffed. Trade flows. Tension in NPC dialogue but commerce continues. The midpoint is genuinely neutral -- both sides need it.

**Interlude:** The Compact guard post is reinforced (more soldiers, barricades). The Wilds-side guards have thinned. The bridge shows signs of neglect -- cracked stone, missing railings. Passage is possible but tense. The Wilds Tavern is half-empty. The Compact Tavern is full of nervous soldiers.

---

### Rhona's Trading Post (Ashfen)

**Type:** Border trading post in the marsh
**Faction:** Unaligned (Rhona's family operation)
**Acts:** I, II, Interlude
**Approximate size:** 24x20 tiles

Rhona's trading post sits at the edge of the Wilds where Thornmere meets Compact territory. A stilt-house above the marshes, surrounded by a small dock, storage shelves, and a bone-trinket display (her husband's craft). Rhona sells to both sides, speaks three languages, and is universally distrusted and universally needed.

#### Settlement Map

```
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ~   MARSH (shallow, reeds)      ~
    ~                               ~
    ~   +------+    +--------+      ~
    ~   |TRINKET|   | RHONA'S|      ~
    ~   |DISPLAY|===| STILT- |      ~
    ~   |(bone  |   | HOUSE  |      ~
    ~   |crafts)|   | (trade,|      ~
    ~   +------+   | info,  |      ~
    ~              | family)|      ~
    ~              +---+----+      ~
    ~                  |stilts     ~
    ~              +---+----+      ~
    ~              | DOCK   |      ~
    ~              | (small,|      ~
    ~              |  boats)|      ~
    ~              +---+----+      ~
    ~                  |           ~
    ~             PATH (planks     ~
    ~              over marsh)     ~
    ~                  |           ~
    ~             TO WILDS/        ~
    ~             COMPACT BORDER   ~
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

#### Key Details

- **Currency:** Rhona accepts everything -- Valdris coin, Compact gold, spirit tokens, barter, favors, information.
- **Unique goods:** Regional intelligence (dialogue-based), marsh-specific herbs, bone trinkets (her husband's craft -- cosmetic accessories), smuggled goods from both factions.
- **Act changes:** In the Interlude, the marsh around the post is going grey. Fish float belly-up. Her children won't go near the water. Rhona is still trading -- she has nowhere else to go.

---

### The Three Roads Inn

**Type:** Neutral waystation at the three-faction crossroads
**Faction:** Unaligned (Hadley's establishment)
**Acts:** I, II, Interlude
**Approximate size:** 32x24 tiles

Hadley's tavern is the only permanent structure at the crossroads of the three factions. A timber building with a stable, a main room, and a cellar. Neutral ground by unwritten agreement -- fights that start inside end with both parties banned for life. In the Interlude, it becomes an unofficial refugee shelter.

This is the location where Sable later builds The Pendulum tavern in the Epilogue -- the emotional through-line from Hadley's welcoming neutrality to Sable's memorial.

#### Settlement Map

```
         TO VALDRIS (northwest)
              |
              |
    +---------+---------+
    |   THREE ROADS INN |
    |                   |
    | +------+ +------+ |
    | |STABLE| | MAIN | |
    | |(3    | | ROOM | |
    | |stalls)| |(bar, | |
    | |      | |tables|--------TO THE WILDS (east)
    | +------+ |hearth)| |
    |          +---+---+ |
    |              |     |
    |          +---+---+ |
    |          |CELLAR | |
    |          |(store, | |
    |          |refuge) | |
    |          +-------+ |
    +---------+---------+
              |
              |
         TO THE COMPACT (southeast)
```

#### Building/Structure Directory

| Structure | Tile Size | Function | Key NPC | Notes |
|-----------|-----------|----------|---------|-------|
| Main Room | 12x10 | Rest, NPC conversations, safe haven | Hadley | Bar, tables, hearth. Hadley's three rules posted on the wall. All factions drink here. |
| Stable | 6x6 | Atmospheric | -- | Three stalls. Travelers' mounts. Practical. |
| Cellar | 8x6 | Storage, Interlude refugee shelter | -- | In Act I-II: food stores, ale barrels. In the Interlude: Compact deserters hiding. Hadley is sheltering them. If the Valdris refugees in the main room find out, there will be trouble (side quest). |

#### Act-by-Act Changes

**Act I-II:** A warm, busy waystation. Travelers from all factions. Hadley serves everyone. NPC conversations reflect the political climate -- tension rising across acts but commerce continuing.

**Interlude:** The inn is damaged but standing. Hadley refuses to close. Valdris refugees in the main room, Compact deserters in the cellar. She is feeding them on diminishing stores and mediating disputes. A side quest involves resolving the tension between the refugee groups. Hadley's line: "I've got Valdris refugees in the back room and Compact deserters in the cellar. If they find out about each other, I'm going to need a bigger tavern. Or fewer people."

**Epilogue:** The Three Roads Inn is gone -- replaced by The Pendulum tavern. Hadley appears as a patron, not the owner. She approves. "The girl has taste. And she kept my policy about the fights."

---

## Design Notes for Implementation

### Visual Consistency Across Thornmere Settlements

All Thornmere settlements share a visual vocabulary that distinguishes them from Valdris and Compact locations:

- **Light sources:** Bioluminescent moss (teal-cyan), spirit-totem glow (purple), will-o'-wisps (yellow-green), filtered sunlight (green-gold). NO torches, NO lanterns with fire, NO artificial light except in cross-faction locations.
- **Architecture materials:** Living wood, woven reed, bark, stone (natural, not quarried), vine, root, bone, hide. NO bricks, NO metal, NO glass.
- **Sound design:** Insect chorus, dripping water, creaking wood, spirit-hum, animal calls. NO machinery, NO bells, NO market chatter in the Valdris/Compact sense.
- **Spirit world bleed-through:** Every Thornmere settlement has ambient spirit creatures -- translucent, small, watching. They are decorative sprites (2x2 or smaller) that drift through the settlement. In Act I-II, they are present. In the Interlude, they are gone. Their absence is felt.

### Currency and Economy Summary

| Settlement | Primary Currency | Accepts Gil? | Accepts Gold? | Barter? |
|-----------|-----------------|-------------|---------------|---------|
| Roothollow | Spirit tokens | Yes (undervalued; no fixed rate) | No (refused) | Yes |
| Duskfen | Spirit tokens | Yes (grudging) | No (hostile) | Yes |
| Ashgrove (market) | Spirit tokens | Yes (fair rate) | No | Yes |
| Canopy Reach | Spirit tokens | Yes (fair rate) | No | Yes |
| Greywood Camp | Spirit tokens | Yes (fair rate) | No (polite refusal) | Yes |
| Stillwater Hollow | None (no shop) | -- | -- | -- |
| Sunstone Ridge | None (no shop) | -- | -- | -- |
| Maren's Refuge | None (no shop) | -- | -- | -- |
| Gael's Span | Mixed (both sides) | Yes | Yes (Compact side) | Yes (Wilds side) |
| Rhona's Post | Everything | Yes | Yes | Yes |
| Three Roads Inn | Gil | Yes | Yes | No |
| The Pendulum | Gil | Yes | Yes | No |

### Corruption Progression Visual Reference

The Pallor's corruption of organic Thornmere architecture follows a consistent visual language:

1. **Stage 0 (Healthy):** Warm browns, living green, bioluminescent teal-cyan. Sap flows. Wood breathes. Spirits visit.
2. **Stage 1 (Early):** Colors slightly desaturated. Bioluminescence flickers occasionally. One in eight trees has a grey bark patch. Spirits are fewer.
3. **Stage 2 (Active):** Petrification visible -- bark turning to grey stone. Bioluminescence replaced by dim grey light. Sap frozen. Water stagnant or rising. Spirits gone. Silence.
4. **Stage 3 (Heavy):** Uniform grey. Living wood is dead stone. Water is grey and still. No light except the Pallor's grey glow. The architecture that was grown is now fossilized.
5. **Healing (Epilogue):** New growth around petrified sections. Brighter bioluminescence than before. New species. The petrified wood remains as scars -- permanent monuments to what was lost. The forest remembers and refuses despair.
