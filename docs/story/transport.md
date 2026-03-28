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
  destination from menu (all cities on the network, not just directly
  connected) → pay fare → fade to black → arrive at destination
  terminal
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
- **First use:** During the Act II diplomatic mission, Sable directs
  the party to the rail: "The rail terminal is faster. East side of
  the canal district — talk to the conductor." First rail use is
  story-motivated.

### Ley Stag Mount

Player-controlled overworld mount. A spirit-bonded stag infused with
ley energy, provided by the Thornmere tribes.

- **Source:** Gift from Thornmere spirit-speakers. Unlocked when the
  party returns to Roothollow with Torren in the active party after
  `duskfen_alliance` (Fenmother's Hollow cleared). Spirit-speaker
  Vessa performs a brief bonding ritual at the heartwood shrine.
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
  thick), water (rivers, ocean), mountains, towns and dungeons
  (automatic dismount at entry trigger tiles). Can enter: roads, farmland, plains, quarried
  plains, light forest, coast, highlands, Sunstone Ridge, Ashlands
  transition tiles.
- **Act III Pallor restriction:** Cannot be summoned inside the Pallor
  Wastes 10-mile radius. If the player is already mounted and
  approaches the Wastes boundary, the Stag auto-dismounts at the edge
  (same as town entry behavior). Conditional message: "The Stag shies
  away. The ley energy here is wrong."
- **Summon restriction:** When summoning in restricted terrain:
  "The Stag cannot navigate this terrain."
- **Unlock trigger:** Requires `duskfen_alliance` flag + Torren in
  active party at Roothollow. Flag set: `stag_bonded` (per
  [events.md](events.md)). If Torren is benched, Vessa says: "The
  forest spirits stir. They sense the Fenmother's passing. Bring
  Torren — the spirits wish to honor the bond."
- **Thematic note:** The Ley Stag creates a faction parallel — the
  Compact has rail infrastructure, the Wilds have the spirit-bonded
  Stag. Each faction's transport reflects its identity.

### Coastal Ferry

NPC-operated instant travel between Compact port cities. Modeled on
FF6's Nikeah-South Figaro ferry (though FF6's ferry was free — PoD
adds a fare for economy integration) and Secret of Mana's Cannon
Travel Centers.

- **Routes:** Bellhaven ↔ Ashport (one route). The coast between these
  ports is rocky and inhospitable — cliffs, sea stacks, and treacherous
  tides (per [geography.md](geography.md)) — making the ferry the
  only practical connection.
- **Mechanic:** Talk to Ferryman NPC at dock → pay fare → fade to black
  → arrive at destination dock (standard fade transition per
  [overworld.md](overworld.md))
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
| ~35% | Act II (Roothollow, after Fenmother) | Ley Stag mount (2x speed, no encounters) | FF6 chocobo |
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

---

## 3. Transport State Per Act

### Act I: On Foot

No vehicles available. The party walks everywhere. The world is small
(Valdris territory only) and walking is sufficient. The player learns
the overworld, encounter system, and terrain passability without
vehicle shortcuts.

### Act II: Full Transport

All four systems unlock as the world opens:
1. Rail (first Compact city visit)
2. Ley Stag (Roothollow after Fenmother, mid-Act II)
3. Ferry (first Bellhaven visit)
4. Linewalk (Maren Lv 20)

This is the "golden age" of mobility. The player can cross the
continent quickly and freely. The SNES reference doc's 30--45% unlock
window maps to Act II's position in the story (~30--50% of the game).

### Interlude: Transport Collapse

- **Rail:** All service suspended. The Ashmark--Corrund main tunnel
  has three collapse points and reactivated boring engines (per
  [dynamic-world.md](dynamic-world.md)). Other segments (Ashmark--
  Caldera, Corrund--Kettleworks) are suspended due to ley line
  instability. Rail Conductor NPCs display: "Service suspended. The
  tunnels aren't safe." The Ashmark--Corrund tunnels become an on-foot
  dungeon (per [dungeons-world.md](dungeons-world.md)) — rail carts
  still exist inside the dungeon as traversal hazards with
  unpredictable destinations, but the NPC-operated city-to-city
  fast-travel service is suspended on all segments.
- **Ley Stag:** Lost (if `stag_bonded` was set). Spirit animals flee
  as Pallor corruption spreads through the ley lines. The Stag
  dissolves during the Interlude transition cutscene — a visual
  moment where the party's ley bond breaks. Cannot be summoned. If
  the Stag was never bonded, this step is skipped.
- **Ferry:** Disrupted. Bellhaven disrupted (per
  [dynamic-world.md](dynamic-world.md) — harbor economy collapsed,
  grey things washing ashore). Ferryman refuses: "The waters aren't
  safe. Something's in the strait." Ferry unavailable at both ports.
- **Linewalk:** Works once Maren is found and in the active party.
  During the early Interlude while the party is scattered, Linewalk
  is unavailable until Maren is recruited. After finding Maren, her
  spell draws on her personal connection to the ley lines, not
  physical infrastructure. Linewalk becomes the player's primary
  fast-travel option, reinforcing Maren's importance to the party.

**Narrative purpose:** The player felt powerful and mobile in Act II.
The Interlude strips that away. Walking through corrupted territory —
slow, dangerous, encounter-heavy — communicates the world's
transformation more effectively than any cutscene.

### Act III: Partial Recovery

- **Rail:** Remains broken. Tunnels still a dungeon. No fast-travel.
- **Ley Stag:** Returns when Torren rejoins the party (Act III reunion
  event), provided `stag_bonded` was set in Act II. The Stag
  re-manifests with grey-tinged ley energy (visual corruption) but is
  mechanically identical (2x speed, no encounters). Cannot enter the
  Pallor Wastes 10-mile radius — "The Stag shies away. The ley energy
  here is wrong." If the Stag was never bonded, it remains unavailable.
- **Ferry:** Restored at Ashport only. Ferryman relocates from
  Bellhaven. Same route (Ashport ↔ Bellhaven) but only boardable from
  Ashport until Bellhaven stabilizes.
- **Linewalk:** Still works. No change.

### Epilogue: Full Restoration

- **Rail:** Repair crews working (visible scaffolding at terminals).
  Not yet functional — NPC dialogue: "Months away from service." No
  gameplay rail travel.
- **Ley Stag:** Fully restored (if bonded). Grey tint fades, ley
  energy bright again. No Pallor restriction (Wastes are gone). Full
  2x speed, no encounters everywhere accessible.
- **Ferry:** Both ports operational. Full service restored.
- **Linewalk:** Still works.

---

## 4. Speed Tiers & Encounter Rules

### Speed Tiers

| Vehicle | Speed | Notes |
|---------|-------|-------|
| On foot | 1x (baseline, ~2 tiles/s per [overworld.md](overworld.md)) | Uniform across all terrain |
| Ley Stag | 2x (~4 tiles/s) | No terrain variation — same 2x on all accessible tiles |
| Rail / Ferry / Linewalk | Instant | Menu-driven, no overworld traversal |

### Encounter Rules

| Vehicle | Danger Counter | Encounters | On Dismount |
|---------|---------------|------------|-------------|
| On foot | Normal increment per terrain zone | Standard | N/A |
| Ley Stag | 0 increment (suppressed) | None | Counter resets to 0 |
| Rail / Ferry / Linewalk | N/A (no traversal) | None | N/A |

On-foot encounter modifiers (Veilstep x0.25, Ward Talisman x0.5,
etc. per [combat-formulas.md](combat-formulas.md) Encounter System)
apply only to on-foot travel. The Ley Stag's ley aura suppresses
encounters independently of equipment/spell modifiers.

### Transport Costs

| Transport | Gold Cost | Other Cost |
|-----------|----------|------------|
| On foot | Free | Time, encounters |
| Ley Stag | Free | Terrain restrictions |
| Rail | 100g per trip | Compact cities only |
| Ferry | 200g per crossing | Two ports only |
| Linewalk | Free (12 MP) | Maren in party, towns only |

Gold costs create a soft economy interaction — early Act II when gold
is tighter, the player weighs rail/ferry fees against walking. By late
Act II with more gold, the costs are trivial. Per SNES convention
where transport costs mattered briefly then became negligible.

---

## 5. Bridge Tiles

Rivers are impassable terrain (on foot and by Stag) except at bridge
tiles — named crossing points where passable tiles span the water.

### Bridge Tile Rules

- Bridge tiles are standard passable terrain. No special passability
  category — they are passable tiles placed over water gaps.
- Both on-foot and Ley Stag can cross bridges.
- Bridge tiles use the encounter zone of the road or path they
  connect. Bridges along named routes use the Roads zone (increment
  96); bridges in wilderness areas use the surrounding terrain's zone.

### Named Bridge Crossings

Key bridge locations per [geography.md](geography.md):

- **Gael's Span** — bridge-town over the upper Corrund River (Compact
  border). The most prominent bridge in the game world.
- **Valdris Crown bridges** — river crossings within and near the
  capital city.
- **Thornwatch area crossings** — any river crossings near the
  Valdris-Wilds border (implementation-placed based on tilemap).
- **Valdris-to-Duskfen route bridges** — crossings along the route
  south from Valdris Crown toward the Wilds.

Additional bridge placements are implementation decisions based on the
overworld tilemap layout. Any road that crosses a river on the
[geography.md](geography.md) map requires a bridge tile.
