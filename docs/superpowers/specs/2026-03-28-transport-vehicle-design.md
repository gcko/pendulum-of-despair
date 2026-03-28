# Transport & Vehicle System — Design Spec

**Gap:** 3.1 Transport & Vehicle System
**Status:** Approved design, ready for implementation
**Date:** 2026-03-28
**Depends On:** 3.2 Overworld Traversal Mechanics (COMPLETE)
**Unblocks:** None directly (completes the traversal picture)

---

## Overview

Formalizes the transport mechanical layer: vehicle types, progression
timeline, speed/encounter rules, and act-based transport state. The
rail system is partially defined across city-carradan.md, geography.md,
and locations.md — this spec consolidates it and adds the Ley Stag
mount, coastal ferry, and the Interlude transport collapse arc.

**Core philosophy: "Grounded FF6."** No airship. Transport stays
terrestrial and coastal. The progression mirrors SNES convention
(ground mount → ferry → spell teleport) without flight. The Interlude
strips transport to create the FF6 World of Ruin rebuilding arc.
Linewalk is the sole survivor — the magical lifeline while physical
infrastructure crumbles.

**Key design decision: no airship.** PoD's continent is a single
landmass (~320x240 miles). No separate continents or islands require
flight. The rail system + Ley Stag + ferry + Linewalk provide the
SNES fast-travel progression curve without trivializing the overworld.
The Interlude's world-fracturing creates the exploration shift (like
FF6's WoB→WoR) without requiring an airship recovery arc.

**SNES-era reference:** FF6's chocobo (2x speed, no encounters, rent
from stables) is the primary model for the Ley Stag. Secret of Mana's
Cannon Travel Centers (NPC-operated fee-based transport) inform the
rail and ferry systems. FF6's Nikeah-South Figaro ferry in the WoR
is the direct model for the coastal ferry. See
`docs/references/overworld-traversal-mechanics.md` Section 10 for the
full cross-game fast-travel progression data.

---

## Section 1: Document Scope & Consolidation

Gap 3.1 creates `docs/story/transport.md` — the canonical transport
mechanics document. It consolidates vehicle rules into one reference.

**Owns:**
- Vehicle types (Ley Stag, rail, ferry) and their mechanics
- Speed tiers and encounter rules per vehicle
- Transport progression timeline (Act I through Epilogue)
- Transport state per act (what's available, what breaks, what recovers)
- Rail system formalization (fares, terminals, NPC interaction)
- Ferry system specification
- Ley Stag mount rules (summon, dismount, terrain restrictions)
- Bridge tile specification (passable terrain over water)

**References (does not duplicate):**
- Rail tunnel dungeon details → dungeons-world.md
- Rail terminal locations and NPC details → city-carradan.md, locations.md
- Linewalk spell mechanics → magic.md (separate system, not a vehicle)
- Overworld passability categories → overworld.md
- Encounter system and danger counter → combat-formulas.md, geography.md
- Ley Stag visual design → visual-style.md (to be defined)
- Transport-related story events → events.md, dynamic-world.md

**Cross-links:**
- Overworld traversal → overworld.md
- Economy (transport costs) → economy.md
- Torren's character arc → characters.md (Stag bond)
- Compact infrastructure → city-carradan.md

---

## Section 2: Vehicle Types

### Compact Rail Network

Menu-driven instant travel between Compact cities via NPC interaction.

- **Routes:** Corrund ↔ Ashmark ↔ Caldera, Corrund ↔ Kettleworks
- **Mechanic:** Talk to Rail Conductor NPC at any terminal → select
  destination from menu → pay fare → fade to black → arrive at
  destination terminal
- **Speed:** Instant (menu-driven, no overworld traversal)
- **Encounters:** None
- **Cost:** 100g per trip
- **Unlock trigger:** First visit to any Compact city with a rail
  terminal
- **Terminal locations:** Corrund East Rail Terminal (building #28),
  Ashmark Rail Station (building #1) per city-carradan.md. Caldera
  and Kettleworks have rail entry/exit points described in their maps
  but lack formal building directory entries — these need adding to
  city-carradan.md during implementation.
- **NPC:** Rail Conductor at each terminal provides the fast-travel
  dialogue interface

### Ley Stag Mount

Player-controlled overworld mount. A spirit-bonded stag infused with
ley energy, provided by the Thornmere tribes.

- **Source:** Gift from Thornmere spirit-speakers after Torren's trust
  event at Roothollow. Brief bonding ritual cutscene.
- **Mechanic:** Summon from overworld party menu when outside.
  Miniaturized party sprite changes to mounted variant (Stag sprite
  with rider). Dismount at any time via menu.
- **Speed:** 2x on-foot speed. No terrain variation — same 2x on every
  accessible tile. Per FF6 chocobo convention.
- **Encounters:** None. Danger counter does not increment while mounted.
  The Stag's ley aura suppresses encounters entirely (0 increment,
  equivalent to Sacred sites zone). Dismounting resets the danger
  counter to 0 (clean start).
- **Terrain restrictions:** Cannot enter: dense Thornmere (canopy too
  thick), water (rivers, ocean), mountains, towns (automatic dismount
  at entry trigger tiles). Can enter: roads, farmland, plains, quarried
  plains, light forest, coast, highlands, Sunstone Ridge, Ashlands
  transition tiles.
- **Act III Pallor restriction:** Cannot be summoned inside the Pallor
  Wastes 10-mile radius. Conditional message: "The Stag shies away.
  The ley energy here is wrong."
- **Summon restriction message:** When summoning in restricted terrain:
  "The Stag cannot navigate this terrain."
- **Unlock trigger:** Return to Roothollow mid-Act II with Torren
  (requires `torren_joined` flag + Thornmere milestone TBD)

### Coastal Ferry

NPC-operated instant travel between Compact port cities.

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

Spell-based teleportation. Owned by magic.md, referenced here for
completeness.

- **Mechanic:** Per magic.md — teleport to any previously visited town.
  Opens a selection menu. 12 MP cost. Maren Lv 20.
- **Note:** Linewalk targets towns, not save points or vehicle
  terminals. It is a separate system from the vehicle transport
  systems above.

---

## Section 3: Transport Progression Timeline

| % Complete | Act | Transport Unlocked | SNES Parallel |
|-----------|-----|-------------------|---------------|
| ~15% | Act I | On foot only | FF6 early game |
| ~30% | Act II (first Compact city) | Rail fast-travel | FF4 hovercraft |
| ~35% | Act II (Torren trust event) | Ley Stag mount | FF6 chocobo |
| ~40% | Act II (Bellhaven) | Coastal ferry | FF6 Nikeah ferry |
| ~45% | Act II (Maren Lv 20) | Linewalk spell | Earthbound Teleport |
| ~55% | Interlude | Transport collapse (see Section 4) | FF6 WoB→WoR |
| ~70% | Act III (Torren rejoins) | Stag returns; ferry at Ashport | FF6 WoR rebuilding |
| ~95% | Epilogue | Full restoration (except rail) | FF6 post-Kefka |

The Act II unlock window (~30--45%) maps to the SNES reference doc's
standard fast-travel acquisition range (40--60% for airships per the
reference doc; ground vehicles appear as early as ~30% in FF4). All four systems are
available before the Interlude strips them.

---

## Section 4: Transport State Per Act

### Act I: On Foot

No vehicles available. The party walks everywhere. The world is small
(Valdris territory only). Walking is sufficient. The player learns the
overworld, encounter system, and terrain passability without shortcuts.

### Act II: Full Transport

All four systems unlock as the world opens:
1. Rail (first Compact city visit)
2. Ley Stag (Torren trust event, mid-Act II)
3. Ferry (first Bellhaven visit)
4. Linewalk (Maren Lv 20)

The "golden age" of mobility. The player crosses the continent quickly.
This is the peak comfort before the Interlude takes it away.

### Interlude: Transport Collapse

- **Rail:** Service suspended. Three tunnel collapse points, boring
  engines reactivate (per dynamic-world.md; dungeon layout in
  dungeons-world.md). Rail Conductor NPCs
  display: "Service suspended. The tunnels aren't safe." The tunnels
  become a dungeon. No fast-travel via rail.
- **Ley Stag:** Lost. Spirit animals flee as Pallor corruption spreads.
  The Stag dissolves during the Interlude transition cutscene — a
  visual moment where the ley bond breaks. Cannot be summoned.
- **Ferry:** Disrupted. Bellhaven disrupted (per dynamic-world.md).
  Ferryman refuses: "The waters aren't safe. Something's in the
  strait." Ferry unavailable at both ports.
- **Linewalk:** Still works. Maren's spell draws on personal ley
  connection, not infrastructure. The player's sole fast-travel option.
  Reinforces Maren's importance to the party.

**Narrative purpose:** The player felt powerful and mobile in Act II.
The Interlude strips that away. Walking through corrupted territory —
slow, dangerous, encounter-heavy — communicates the world's
transformation viscerally.

### Act III: Partial Recovery

- **Rail:** Remains broken. Tunnels still a dungeon. No fast-travel.
- **Ley Stag:** Returns when Torren rejoins (Act III reunion event).
  Re-manifests with grey-tinged ley energy (visual corruption) but
  mechanically identical (2x speed, no encounters). Cannot enter
  Pallor Wastes radius.
- **Ferry:** Restored at Ashport only. Ferryman relocates from
  Bellhaven. Same route (Ashport ↔ Bellhaven) but only boardable from
  Ashport until Bellhaven stabilizes.
- **Linewalk:** Still works. No change.

### Epilogue: Full Restoration

- **Rail:** Repair crews working (visible scaffolding at terminals).
  Not yet functional — NPC dialogue: "Months away from service." No
  gameplay rail travel.
- **Ley Stag:** Fully restored. Grey tint fades, ley energy bright.
  No Pallor restriction (Wastes gone). Full 2x speed everywhere.
- **Ferry:** Both ports operational. Full service restored.
- **Linewalk:** Still works.

---

## Section 5: Speed Tiers & Encounter Rules

### Speed Tiers

| Vehicle | Speed | Notes |
|---------|-------|-------|
| On foot | 1x (baseline) | Uniform across all terrain per overworld.md |
| Ley Stag | 2x | No terrain variation — same 2x on all accessible tiles |
| Rail / Ferry / Linewalk | Instant | Menu-driven, no overworld traversal |

On-foot baseline speed (~2 tiles/second per overworld.md Implementation
Notes) is an implementation tuning value. Ley Stag is exactly 2x that
value.

### Encounter Rules

| Vehicle | Danger Counter | Encounters | On Dismount |
|---------|---------------|------------|-------------|
| On foot | Normal increment per terrain zone | Standard | N/A |
| Ley Stag | 0 increment (suppressed) | None | Counter resets to 0 |
| Rail / Ferry / Linewalk | N/A (no traversal) | None | N/A |

On-foot encounter modifiers (Veilstep, Ward Talisman, etc. per
combat-formulas.md) apply only to on-foot travel. The Ley Stag's
aura suppresses encounters independently of these modifiers.

### Transport Costs

| Transport | Gold Cost | Other Cost |
|-----------|----------|------------|
| On foot | Free | Time, encounters |
| Ley Stag | Free | Terrain restrictions |
| Rail | 100g per trip | Compact cities only |
| Ferry | 200g per crossing | Two ports only |
| Linewalk | Free (12 MP) | Maren in party, towns only |

---

## Section 6: Bridge Tiles & Passability

Rivers are impassable terrain (on foot and by Stag) except at bridge
tiles — named crossing points where passable tiles span the water.

### Bridge Tile Rules

- Bridge tiles are standard passable terrain. No special passability
  category — they are simply passable tiles placed over water gaps.
- Both on-foot and Ley Stag can cross bridges.
- Bridge tiles have the encounter zone of their surrounding terrain
  (typically Roads zone, increment 96).

### Named Bridge Crossings

Key bridge locations (per geography.md):
- **Gael's Span** — bridge-town over the upper Corrund River (Compact
  border)
- **Valdris Crown bridges** — river crossings within the capital
- **Thornwatch area crossings** — any river crossings near the
  Valdris-Wilds border (implementation-placed based on tilemap)
- **Valdris-to-Duskfen route bridges** — any river crossings along
  the route south from Valdris Crown toward the Wilds

Additional bridge placements are implementation decisions based on
the overworld tilemap layout. Any road that crosses a river on the
geography.md map requires a bridge tile.

---

## Section 7: Design Changes to Existing Docs

These changes must be applied during implementation:

1. **overworld.md:** Resolve the three Gap 3.1 deferrals. Replace
   "vehicle-conditional tiles will be added as a sixth passability
   category" with a note that PoD's transport systems are menu-driven
   (rail, ferry) or use existing passability with restrictions (Stag).
   No sixth category needed. Remove "airship" from the deferred
   vehicle list (no airship in PoD). Add bridge tile note to the
   Impassable row (rivers crossable at bridge tiles). Cross-reference
   transport.md.

2. **geography.md:** Remove "deferred to Gap 3.1" qualifiers from
   the sea routes entry (line ~206) and rail cart entry (line ~546).
   Replace with cross-references to transport.md. Add named bridge
   crossings note to the river descriptions or distance table.

3. **city-carradan.md:** Add rail fare (100g) and formalized fast-
   travel mechanic to the Rail Network section. Cross-reference
   transport.md.

4. **economy.md:** Add transport costs to the gold expenditure
   breakdown if not already present (rail 100g, ferry 200g).

---

## What This Does NOT Cover

- **Rail tunnel dungeon content** (encounters, layouts, Interlude
  transformation) — already in dungeons-world.md
- **Rail terminal NPC dialogue** — already in city-carradan.md
- **Linewalk spell mechanics** (MP cost, level requirement, casting
  animation) — already in magic.md
- **Encounter rate formulas and danger counter** — already in
  combat-formulas.md and geography.md
- **Overworld passability rules** (5 base categories) — already in
  overworld.md
- **Ley Stag visual design** (sprite, animation, summoning VFX) —
  deferred to visual implementation
