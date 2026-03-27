# Crafting System (Arcanite Forging) — Design Spec

**Gap:** 3.5 Crafting System (Arcanite Forging)
**Status:** Approved design, ready for implementation
**Date:** 2026-03-27
**Depends On:** 1.4 (Items — COMPLETE), 1.5 (Equipment — COMPLETE)
**Unblocks:** None directly (enriches gameplay loop)

---

## Overview

Formalizes the Arcanite Forging mechanical layer: interaction model,
Arcanite Charge resource, device loadout rules, recipe unlock
progression, synergy discovery, and Pallor malfunction mechanics. The
*content* (recipes, materials, equipment stats) is already defined
across equipment.md, items.md, abilities.md, and economy.md. This spec
covers the *how* — how the player interacts with the crafting system.

**Core philosophy:** Lira is the sole crafter. Crafting reinforces her
identity as the party's engineer. The material economy creates
meaningful choices (sell for gold vs save for crafting). Pre-dungeon
device loadout planning adds strategic depth without complexity.

**SNES-era reference:** Secret of Mana's Watts blacksmith (walk up,
select, upgrade) is the closest model. PoD expands it with field-
craftable devices and context-sensitive forge access.

---

## Section 1: Document Scope & Consolidation

Gap 3.5 creates `docs/story/crafting.md` — the canonical crafting
mechanics document. It consolidates all Arcanite Forging interaction
rules into one reference.

**Owns:**
- Crafting interaction model (field menu vs forge locations)
- AC pool rules (size, restoration)
- Device loadout rules (5 slots, locking, reconfiguration)
- Recipe unlock progression timeline
- Malfunction mechanics in Pallor zones
- Synergy discovery system
- Crafting UI flow descriptions

**References (does not duplicate):**
- Equipment recipes, stats, infusions, synergies → equipment.md
- Material list, device stats, schematics → items.md
- Lira's abilities, AC combat uses → abilities.md
- Crafting economy, material pricing → economy.md

**Cross-links:**
- Forge locations → locations.md
- Crafting quests → sidequests.md
- Lira's character arc → characters.md
- Forgewright NPCs → npcs.md

---

## Section 2: Crafting Interaction Model

### Three Crafting Types, Two Access Contexts

| Crafting Type | Where | Requires Forge? | Cost |
|---------------|-------|-----------------|------|
| Device crafting | Field menu (anywhere outside battle) | No | AC + materials + gold |
| Equipment forging | Forge locations only | Yes | Materials + gold fee (400–500g) |
| Elemental infusions | Forge locations only | Yes | Materials + gold fee (300–500g) |

> **Design change (applied):** equipment.md updated to restrict
> equipment forging and infusions to named forge locations. Device
> crafting remains available at save points/camps/field.

### Forge Locations

Equipment forging and infusions require a physical forge:

- **Ashmark** (Forge-Masters' Guild) — Act II onward
- **Caldera** (Forgewrights' Academy) — Act II onward; erratic during
  Interlude
- **Forgotten Forge** (Act III dungeon) — ancient forge, unlocks
  Arcanite Lance recipe
- **Inn workbenches** — basic forging at any inn with a hearth (Act I
  onward)
- **Lira's hidden workshop** (Caldera undercity) — Interlude safe room
- **Oasis B** (jury-rigged forge) — Act III

### Device Crafting Flow (Field Menu)

1. Open party menu → select Lira → "Forge Devices"
2. See current loadout (5 slots, charges per type)
3. Select empty slot or replace existing type
4. Choose recipe from unlocked list → see material/AC/gold cost
5. Confirm → device appears in loadout, ready for battle use

### Equipment Forging Flow (At Forge)

1. Interact with forge object → "Arcanite Forging" menu
2. Three tabs: **Forge Equipment** / **Infuse Weapon** / **Synergies**
3. **Forge Equipment:** select recipe → see material requirements →
   confirm → item added to inventory with "(Forged)" tag
4. **Infuse Weapon:** select weapon → select infusion type → confirm
   materials → weapon gains element permanently (overwrites previous
   infusion)
5. **Synergies:** shows discovered synergies with details; undiscovered
   slots show "???" with count (e.g., "3/7 Synergies Discovered")

### Device Loadout Rules

- **5 device type slots**, 3 charges per type (max 15 devices total)
- **Locked on dungeon entry** — loadout cannot be changed until
  reaching a save point inside the dungeon or exiting
- **Reconfigure at save points** inside dungeons (re-craft with
  available materials and AC)
- **Devices persist when Lira leaves party** — pre-crafted stock
  remains usable by other party members as items
- **Empty slots** can be filled at save points if Lira has AC and
  materials

---

## Section 3: Arcanite Charge (AC) System

### Pool Mechanics

Per abilities.md, Lira has a **flat 12 AC pool** that starts full
each battle. AC is used for two distinct systems:

1. **Battle devices** (abilities.md): deployed in combat (Shock Coil,
   Bulkhead, Arc Trap, Mending Engine, etc.) — cost AC to deploy,
   persist on the battlefield for turns, 2-device active limit
2. **Pre-crafted devices** (items.md): crafted at save points from
   materials + gold, carried as inventory items (5 types, 3 charges
   each) — anyone can USE in battle, no AC cost to use (AC was spent
   during crafting)

**Key distinction:** Battle devices cost AC *during combat*. Pre-crafted
devices cost AC *during crafting* (at save points). Using a pre-crafted
device in battle costs 0 AC — the charge was baked in during creation.

### AC Costs for Pre-Crafting

| Device Tier | AC to Craft | Examples |
|-------------|-------------|---------|
| Basic (Act I) | 1 AC | Thermal Charge, Mending Engine, Flashbang |
| Advanced (Act II) | 2 AC | Frost Bomb, Shock Coil, Barrier Node, Ward Emitter |
| Expert (Interlude) | 2 AC | Gravity Anchor, Disruption Pulse |
| Anti-Pallor (Act III) | 3 AC | Pallor Grenade, Pallor Salve, Arcanite Lance |
| Ultimate (Post-Convergence) | 4 AC | Emergency Beacon |

**AC budget per rest:** With 12 AC restored at each save point, Lira
can pre-craft:
- 5 basic devices (5 AC) + 3 advanced (6 AC) = 11 AC, 1 AC spare
- 4 anti-Pallor devices (12 AC) = full AC, no spare
- 2 anti-Pallor (6 AC) + 2 advanced (4 AC) + 1 basic (1 AC) = 11 AC

AC remaining after crafting is available for battle device deployment.

### AC Restoration

Per abilities.md:
- Fully restored at inns, save points, and camps
- Unused AC carries over between rests
- **Arcanite Shards** restore AC when used as consumables (per
  abilities.md: "Restored at inns, save points, and by certain
  items (Arcanite Shards)")
- Arcanite Shards serve dual purpose: crafting material OR AC
  restorative. Using one to restore AC consumes it (cannot also
  use it for crafting). This is the core sell-vs-save tension.

---

## Section 4: Synergy Discovery System

> **Design change (applied):** equipment.md updated to replace "no
> in-game hints" with layered hint system (NPC lore + Lira reactions).

### Two Discovery Channels

**NPC Hints (NPC channel):** Forge-city NPCs drop vague lore. "The old
Forge-Masters used to say storm energy *sings* when it meets an
Architect's steel..." No explicit recipe — just breadcrumbs.

**Lira Reacts (Lira channel):** When Lira is at a forge with the
qualifying weapon in inventory AND the required infusion material, a
dialogue bubble appears: "Hmm... I wonder what would happen if I
channeled [element] through [weapon]..." No recipe reveal — just a
nudge.

### Discovery Distribution

| Synergy | Weapon + Infusion | Hint Channels | Rationale |
|---------|-------------------|:---:|-----------|
| Penitent's Edge | Grey Cleaver + Spirit | Both | Narratively critical (purification arc) |
| Stormforge Hammer | Architect's Hammer + Storm | Both | Tied to Ashmark identity |
| Rootbound Lance | Torren Spear + Earth | NPC only | Thornmere elder lore |
| Resonance Staff | Maren Staff + Ley | Lira only | Lira senses ley resonance |
| Shadowfang | Sable Dagger + Void | NPC only | Tash mentions "void-touched steel" |
| Crucible Maul | Lira Hammer + Flame | Lira only | Lira muses about her own tools |
| Oathkeeper | Edren Sword + Spirit | NPC only | Cordwyn mentions spirit-bonded blades |

**Synergies tab** in the forge menu shows discovered synergies with
full details. Undiscovered slots show "???" — total count visible
(e.g., "3/7 Synergies Discovered") so the player knows more exist.

**Activation:** When a qualifying infusion is applied, a special
notification appears: "Lira senses a resonance..." The synergy bonus
is immediately active and visible in the equipment stats screen.

---

## Section 5: Malfunction & Calibration in Pallor Zones

### Malfunction Rules

Per abilities.md:

- **15% chance** per device use in Pallor-corrupted zones
- Malfunction effects (equal 1/3 chance each):
  - **Heal wrong target:** defensive device applies to random enemy
  - **Damage ally:** offensive device hits random ally
  - **Fizzle:** device does nothing, charge consumed
- **Visual tell:** Arcanite crystals pulse with grey veins when
  entering a corrupted zone (pre-battle warning)

### Calibrate Action

Per abilities.md:

- **0 AC cost**, spends Lira's turn
- Targets one active device and removes its malfunction chance for
  the device's remaining duration
- **Tactical cost:** uses Lira's turn instead of attacking/healing
- **Only available in Pallor zones** — malfunction only occurs in
  corrupted areas

### Zones Affected

Any area flagged as Pallor-corrupted in dungeons-world.md: Pallor
Wastes overworld, Convergence dungeons, corrupted sections of Interlude
dungeons. Town safe zones (Oases, inn interiors) are NOT corrupted.

### Narrative Rationale

Malfunction reinforces Lira's arc: Forgewright technology struggles
against the Pallor. Calibrate is her adaptation — her craft evolving
to meet new challenges. By Act III, the player has internalized
"Calibrate before critical device uses in Pallor zones" as a tactical
habit.

---

## Section 6: Recipe Unlock Progression

Recipes unlock through story progression and exploration:

| Act | Devices Unlocked | Equipment Available | Trigger |
|-----|-----------------|--------------------:|---------|
| Act I | Thermal Charge, Mending Engine, Flashbang | Inn workbench forging (basic) | Lira joins party |
| Act II (Ashmark) | Frost Bomb, Shock Coil, Barrier Node, Ward Emitter | Full forge access + infusions | Visit Forge-Masters' Guild |
| Interlude | Gravity Anchor, Disruption Pulse | Arcanite Blade, Forgewright Maul, Arcanite Helm | Find schematics in Rail Tunnels |
| Act III | Pallor Grenade, Pallor Salve | Thornspear, Shadowsteel Knife, Resonance Rod, Pallor Ward Vest, Ley-Woven Cloak | Lira reverse-engineers Pallor tech |
| Act III (Forgotten Forge) | Arcanite Lance | — | Reach ancient forge chamber |
| Post-Convergence | Emergency Beacon | — | Story milestone |

**Schematic items** (key items that unlock recipes):
- **Boring Engine Schematic:** Rail Tunnels East Tunnel secret room →
  unlocks Interlude device recipes
- **Forge Schematic:** STEAL from The Architect boss → unlocks
  Arcanite Lance recipe (miss = locked until NG+)

---

## What This Does NOT Cover

- **Recipe details** (materials, stats, costs) — already in
  equipment.md and items.md
- **Material acquisition sources** — already in items.md drop tables
  and economy.md shop inventories
- **Lira's combat abilities** (Disrupt, Arcanite Colossus) — already
  in abilities.md
- **Crafting quest content** — already in sidequests.md
- **Forge location descriptions** — already in locations.md

---

## Design Changes to Existing Docs

These changes must be applied to the source docs during implementation:

1. **equipment.md:** Update "at save points and camps" to reflect
   context-sensitive model (devices at save points; equipment forging
   and infusions at forge locations only)
2. **equipment.md:** Replace "no in-game hints until synergy activates"
   with the layered NPC hint + Lira reaction discovery system
3. **items.md:** Add AC cost column to the device recipe table (values
   per Section 3's tier mapping)
4. **locations.md:** Verify Oasis B has a forge (currently describes
   "jury-rigged Forgewright amplifiers" for ward defense, not crafting;
   may need a crafting-capable forge added to the location)
