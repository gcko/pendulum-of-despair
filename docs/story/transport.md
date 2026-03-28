# Transport & Vehicle System

> Formalizes the transport mechanical layer: vehicle types, progression
> timeline, speed/encounter rules, act-based transport state, and
> bridge tiles. The rail system is partially defined across
> [city-carradan.md](city-carradan.md), [geography.md](geography.md),
> and [locations.md](locations.md). This document consolidates those
> references and adds the Ley Stag mount, coastal ferry, and the
> Interlude transport collapse arc.
>
> **Core philosophy: "Grounded FF6."** No airship. Transport stays
> terrestrial and coastal. The progression mirrors SNES convention
> (ground mount → ferry → spell teleport) without flight. The Interlude
> strips transport to create the FF6 World of Ruin rebuilding arc.
> Linewalk is the sole survivor — the magical lifeline while physical
> infrastructure crumbles.
>
> **Related docs:** [overworld.md](overworld.md) |
> [city-carradan.md](city-carradan.md) | [geography.md](geography.md) |
> [economy.md](economy.md) | [magic.md](magic.md) |
> [dynamic-world.md](dynamic-world.md) |
> [combat-formulas.md](combat-formulas.md) |
> [characters.md](characters.md)
>
> **Cross-links:** [dungeons-world.md](dungeons-world.md) |
> [locations.md](locations.md) | [events.md](events.md)

---

## 1. Vehicle Types

### Compact Rail Network

Menu-driven instant travel between Compact cities via NPC interaction.

- **Routes:** Corrund ↔ Ashmark ↔ Caldera, Corrund ↔ Kettleworks (per
  [city-carradan.md](city-carradan.md) Rail Network diagram)
- **Mechanic:** Talk to Rail Conductor NPC at any terminal → select
  destination from menu → pay fare → fade to black → arrive at
  destination terminal
- **Speed:** Instant (menu-driven, no overworld traversal)
- **Encounters:** None
- **Cost:** 100g per trip
- **Unlock trigger:** First visit to any Compact city with a rail
  terminal
- **Terminal locations:** Corrund East Rail Terminal (building #28),
  Ashmark Rail Station (building #1) per
  [city-carradan.md](city-carradan.md). Caldera and Kettleworks have
  rail entry/exit points described in their maps.
- **NPC:** Rail Conductor at each terminal provides the fast-travel
  dialogue interface

### Ley Stag Mount

Player-controlled overworld mount. A spirit-bonded stag infused with
ley energy, provided by the Thornmere tribes.

- **Source:** Gift from Thornmere spirit-speakers after Torren's trust
  event at Roothollow. Brief bonding ritual cutscene.
- **Mechanic:** Summon from overworld party menu when outside.
  Miniaturized party sprite changes to mounted variant. Dismount at
  any time via menu. Automatic dismount at entry trigger tiles (walk
  into a town, Stag disappears, party enters on foot).
- **Speed:** 2x on-foot speed. No terrain variation — same 2x on every
  accessible tile. Per FF6 chocobo convention.
- **Encounters:** None. Danger counter does not increment while mounted
  (0 increment, equivalent to Sacred sites zone per
  [geography.md](geography.md)). Dismounting resets the danger counter
  to 0 (clean start, no ambush on dismount).
- **Terrain restrictions:** Cannot enter: dense Thornmere (canopy too
  thick), water (rivers, ocean), mountains, towns (automatic dismount
  at entry trigger tiles). Can enter: roads, farmland, plains, quarried
  plains, light forest, coast, highlands, Sunstone Ridge, Ashlands
  transition tiles.
- **Act III Pallor restriction:** Cannot be summoned inside the Pallor
  Wastes 10-mile radius. Conditional message: "The Stag shies away.
  The ley energy here is wrong."
- **Summon restriction:** When summoning in restricted terrain:
  "The Stag cannot navigate this terrain."
- **Unlock trigger:** `torren_trust` story flag (mid-Act II event at
  Roothollow)
- **Thematic note:** The Ley Stag creates a faction parallel — the
  Compact has rail infrastructure, the Wilds have the spirit-bonded
  Stag. Each faction's transport reflects its identity.

### Coastal Ferry

NPC-operated instant travel between Compact port cities. Modeled on
FF6's Nikeah-South Figaro ferry and Secret of Mana's Cannon Travel
Centers.

- **Routes:** Bellhaven ↔ Ashport (one route)
- **Mechanic:** Talk to Ferryman NPC at dock → pay fare → fade to black
  with brief ship-on-water visual → arrive at destination dock
- **Speed:** Instant (menu-driven)
- **Encounters:** None
- **Cost:** 200g per crossing (premium — sea travel is more expensive
  than rail)
- **Unlock trigger:** First visit to Bellhaven docks
- **NPC:** Ferryman at each port dock

### Linewalk Spell (Reference Only)

Spell-based teleportation. Owned by [magic.md](magic.md), referenced
here for completeness.

- **Spell:** #74 Linewalk. Element: Ley. Category: Utility.
- **Mechanic:** Teleport to any previously visited town. Opens a
  selection menu. 12 MP cost. Overworld only, out of combat.
- **Who learns:** Maren (Lv 20)
- **Note:** Linewalk targets towns, not save points or vehicle
  terminals. It is a separate system from the vehicle transport
  systems above. Save points provide rest/save (per
  [overworld.md](overworld.md) Section 6); Linewalk provides fast
  travel to settlements.

---

## 2. Transport Progression Timeline

| % Complete | Act | Transport Unlocked | SNES Parallel |
|-----------|-----|-------------------|---------------|
| ~15% | Act I | On foot only | FF6 early game |
| ~30% | Act II (first Compact city) | Rail fast-travel (Compact cities) | FF4 hovercraft |
| ~35% | Act II (Torren trust event) | Ley Stag mount (2x speed, no encounters) | FF6 chocobo |
| ~40% | Act II (Bellhaven) | Coastal ferry (Bellhaven ↔ Ashport) | FF6 Nikeah ferry |
| ~45% | Act II (Maren Lv 20) | Linewalk spell (town teleport) | Earthbound Teleport |
| ~55% | Interlude | Transport collapse (see Section 3) | FF6 WoB→WoR |
| ~70% | Act III (Torren rejoins) | Stag returns; ferry at Ashport only | FF6 WoR rebuilding |
| ~95% | Epilogue | Full restoration (except rail) | FF6 post-Kefka |

The Act II unlock window (~30--45%) aligns with the SNES fast-travel
pattern where vehicles appeared between 30--60% of the game (40--60%
for airships per the reference doc; ground vehicles as early as ~30%
in FF4). All four transport systems are available before the Interlude
strips them.
