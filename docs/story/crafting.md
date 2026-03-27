# Crafting System (Arcanite Forging)

> Formalizes the mechanical layer of Arcanite Forging: interaction
> model, Arcanite Charge resource, device loadout rules, recipe unlock
> progression, synergy discovery, and Pallor malfunction mechanics. The
> *content* (recipes, materials, equipment stats) is already defined
> across [equipment.md](equipment.md), [items.md](items.md),
> [abilities.md](abilities.md), and [economy.md](economy.md). This
> document covers the *how* — how the player interacts with the crafting
> system.
>
> **Core philosophy:** Lira is the sole crafter. Crafting reinforces her
> identity as the party's engineer. The material economy creates
> meaningful choices (sell for gold vs save for crafting). Pre-dungeon
> device loadout planning adds strategic depth without complexity.
>
> **SNES-era reference:** Secret of Mana's Watts blacksmith (walk up,
> select, upgrade) is the closest model. PoD expands it with
> field-craftable devices and context-sensitive forge access.
>
> **Related docs:** [equipment.md](equipment.md) |
> [items.md](items.md) | [abilities.md](abilities.md) |
> [economy.md](economy.md) | [locations.md](locations.md) |
> [characters.md](characters.md)

---

## 1. Interaction Model

### Three Crafting Types, Two Access Contexts

| Crafting Type | Where | Requires Forge? | Cost |
|---------------|-------|-----------------|------|
| Device crafting | Field menu (anywhere outside battle) | No | AC + materials + gold |
| Equipment forging | Forge locations only | Yes | Materials + gold fee (400–500g) |
| Elemental infusions | Forge locations only | Yes | Materials + gold fee (300–500g) |

Device crafting is available from any save point, camp, or field menu.
Equipment forging and elemental infusions require a physical forge —
the player must travel to one of the named forge locations below.

### Forge Locations

Equipment forging and infusions require a physical forge. Six locations
provide forge access across the game:

| Location | Region | Access Window | Notes |
|----------|--------|---------------|-------|
| Ashmark (Forge-Masters' Guild) | Carradan Compact | Act II onward | Full forge; Lira trained here |
| Caldera (Forgewrights' Academy) | Carradan Compact | Act II onward | Erratic during Interlude (ley instability) |
| Forgotten Forge | Act III dungeon | Act III | Ancient forge; unlocks Arcanite Lance recipe |
| Inn workbenches | Any inn with a hearth | Act I onward | Basic forging only |
| Lira's hidden workshop | Caldera undercity | Interlude | Safe room; full forge access |
| Oasis B (jury-rigged forge) | Pallor Wastes | Act III | Compact refugee camp |

### Device Crafting Flow (Field Menu)

Device crafting uses a five-step field menu:

1. Open party menu, select Lira, choose "Forge Devices"
2. View current loadout (5 slots with charges per type)
3. Select an empty slot or replace an existing device type
4. Choose recipe from unlocked list — material, AC, and gold costs
   displayed
5. Confirm — device appears in loadout, ready for battle use

### Equipment Forging Flow (At Forge)

Equipment forging uses a five-step forge menu with three tabs:

1. Interact with forge object — "Arcanite Forging" menu opens
2. Three tabs: **Forge Equipment** | **Infuse Weapon** | **Synergies**
3. **Forge Equipment:** select recipe, review material requirements,
   confirm — item added to inventory with "(Forged)" tag
4. **Infuse Weapon:** select weapon, select infusion type, confirm
   materials — weapon gains element permanently (overwrites previous
   infusion)
5. **Synergies:** shows discovered synergies with full details;
   undiscovered slots show "???" with count
   (e.g., "3/7 Synergies Discovered")

### Device Loadout Rules

- **5 device type slots**, 3 charges per type — max 15 devices total
- **Locked on dungeon entry** — loadout cannot be changed until
  reaching a save point inside the dungeon or exiting
- **Reconfigure at save points** inside dungeons (re-craft with
  available materials and AC)
- **Devices persist when Lira leaves party** — pre-crafted stock
  remains usable by other party members as items
- **Empty slots** can be filled at save points if Lira has AC and
  materials

---

## 2. Arcanite Charge (AC) System

### Pool Mechanics

Per [abilities.md](abilities.md), Lira has a **flat 12 AC pool** that
starts full each battle. AC serves two distinct systems:

1. **Battle devices** ([abilities.md](abilities.md)): deployed in
   combat (Shock Coil, Bulkhead, Arc Trap, Mending Engine, etc.) —
   cost AC to deploy, persist on the battlefield for turns, 2-device
   active limit
2. **Pre-crafted devices** ([items.md](items.md)): crafted at save
   points from materials + gold, carried as inventory items (5 types,
   3 charges each) — anyone can use in battle, no AC cost to use (AC
   was spent during crafting)

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

### AC Budget Examples

With 12 AC restored at each rest point, Lira can pre-craft different
loadout combinations. Three worked examples:

**Example 1 — Balanced loadout (11 AC spent, 1 spare):**
5 basic devices (5 AC) + 3 advanced devices (6 AC) = 11 AC total.
One AC remains for a battle device deployment.

**Example 2 — Anti-Pallor focus (12 AC spent, 0 spare):**
4 anti-Pallor devices (12 AC) = full pool consumed. No AC remains for
battle devices — commit fully to pre-crafted loadout.

**Example 3 — Mixed tiers (11 AC spent, 1 spare):**
2 anti-Pallor devices (6 AC) + 2 advanced devices (4 AC) + 1 basic
device (1 AC) = 11 AC total. Versatile loadout with one AC spare.

AC remaining after crafting is available for battle device deployment
during the next combat encounters.

### AC Restoration

Per [abilities.md](abilities.md):

- **Rest points:** Fully restored at inns, save points, and camps
- **Carry-over:** Unused AC carries over between rests
- **Arcanite Shards:** Restore AC when used as consumables (per
  abilities.md: "Restored at inns, save points, and by certain items
  (Arcanite Shards)")

Arcanite Shards serve a **dual purpose**: crafting material OR AC
restorative. Using a shard to restore AC consumes it — that shard
cannot also be used for crafting. This is the core sell-vs-save tension
in the material economy.
