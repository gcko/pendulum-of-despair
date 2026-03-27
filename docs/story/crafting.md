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
| Forgotten Forge | Act III dungeon | Act III | Ancient forge; unlocks Arcanite Lance recipe (location entry pending in locations.md) |
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

**Infusion removal:** Existing infusions can be removed for free at
any save point (no forge required). Only *applying* a new infusion
requires a forge. Per [equipment.md](equipment.md).

### Device Loadout Rules

- **5 device type slots**, 3 charges per type — max 15 devices total
- **Locked on dungeon entry** — loadout cannot be changed until
  reaching a save point inside the dungeon or exiting
- **Freely changeable on the overworld** — between overworld encounters,
  Lira can swap device types via the field menu at any time
- **Reconfigure at save points** inside dungeons (re-craft with
  available materials and AC)
- **Devices persist when Lira leaves party** — pre-crafted devices
  remain in inventory and are usable by any party member through the
  Items command in battle. Only *crafting new devices* requires Lira.
  The "Forge Devices" menu is unavailable when Lira is absent.
- **Empty slots** can be filled at save points if Lira has AC and
  materials

---

## 2. Arcanite Charge (AC) System

### Pool Mechanics

Lira has a **12 AC pool** (per [abilities.md](abilities.md): "Max 12 AC").
AC is restored to full at inns, save points, and camps. AC serves two
distinct systems:

1. **Battle devices** ([abilities.md](abilities.md)): deployed in
   combat (Shock Coil, Bulkhead, Arc Trap, etc.) — cost AC to deploy,
   persist on the battlefield for turns, 2-device active limit
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
| Act III | 3 AC | Pallor Grenade, Pallor Salve, Arcanite Lance |
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

- **Rest points:** Fully restored to 12 at inns, save points, and camps.
  AC spent on pre-crafting at a save point reduces the pool until the
  next rest — crafting 3 devices at 2 AC each leaves 6 AC for battle
  device deployment until the next save point.
- **Battle start:** Each battle begins with the current AC pool (not
  auto-refilled). AC spent on crafting between battles is not recovered
  until the next rest point.
- **Arcanite Shards:** Restore AC when used as consumables (per
  abilities.md: "Restored at inns, save points, and by certain items
  (Arcanite Shards)"). Field-usable between battles.

Arcanite Shards serve a **dual purpose**: crafting material OR AC
restorative. Using a shard to restore AC consumes it — that shard
cannot also be used for crafting. This is the core sell-vs-save tension
in the material economy.

---

## 3. Synergy Discovery System

### Overview

Per [equipment.md](equipment.md), certain weapon + infusion combinations
unlock a hidden synergy — transforming the weapon into a named variant
with a bonus effect. There are 7 synergies total. The player discovers
them through two channels, each providing partial coverage. Full
discovery requires engaging with both.

### Discovery Channels

**NPC Hints (forge-city NPCs):** Blacksmiths, scholars, and veterans
in forge cities (Ashmark, Caldera, Oasis B) drop vague lore about
legendary weapon transformations. These hints reference materials,
elements, or weapon families without naming the exact recipe. The
player must connect the dots.

**Lira Reacts (contextual dialogue):** When Lira is in the party, has
the right base weapon in inventory, and the required infusion material
available, she triggers a dialogue bubble upon entering a forge
location. She comments on a resonance she senses between the weapon
and material — a strong hint without giving the exact outcome.

### Discovery Distribution

| Synergy Name | Base Weapon | Infusion | Discovery Channel | Notes |
|--------------|-------------|----------|-------------------|-------|
| Penitent's Edge | Grey Cleaver (tainted) | Spirit | Both | NPC lore + Lira senses spirit echoes |
| Stormforge Hammer | Architect's Hammer | Storm | Both | NPC lore + Lira senses storm feedback |
| Rootbound Lance | Any Torren Spear | Earth | NPC only | Thornmere elder recounts root-spear legends |
| Resonance Staff | Any Maren Staff | Ley | Lira only | Lira senses ley resonance in the staff's grain |
| Shadowfang | Any Sable Dagger | Void | NPC only | Tash mentions "void-touched steel" in passing |
| Crucible Maul | Any Lira Hammer | Flame | Lira only | Lira muses about superheating her own tools |
| Oathkeeper | Any Edren Sword | Spirit | NPC only | Cordwyn mentions spirit-bonded blades from the old wars |

**Channel balance:** 2 Both, 3 NPC-only, 2 Lira-only. Players who
skip NPC dialogue miss 3 synergies; players who rush through forges
without Lira miss 2. Completionists who do both discover all 7.

### Synergies Tab (Forge Menu)

The **Synergies** tab in the forge menu (see Section 1, step 5) shows
the player's discovery progress:

- **Discovered synergies** display the full entry: base weapon,
  infusion element, synergy name, and bonus effect description
- **Undiscovered synergies** display "???" with no details
- **Counter** visible at the top of the tab (e.g., "3/7 Synergies
  Discovered")
- Synergies cannot be crafted from this tab — the player performs a
  normal infusion on the Infuse Weapon tab, and the synergy activates
  automatically if the combination matches

### Activation

When a synergy triggers, the notification reads: *"Lira senses a
resonance between the [weapon] and the [element] infusion. The weapon
transforms..."* The bonus effect is immediately active — no additional
steps required. The Synergies tab updates to show the newly discovered
entry.

---

## 4. Malfunction & Calibration in Pallor Zones

### Pallor-Zone Malfunction

Per [abilities.md](abilities.md), Forgewright devices in
Pallor-corrupted zones have a **15% chance to malfunction** each time
a device activates (per-turn for persistent devices, on-use for
instant devices). When a malfunction occurs, the device's intended
effect is replaced by one of three outcomes, each with **equal 1/3
probability:**

| Malfunction Effect | Description |
|--------------------|-------------|
| Heal wrong target | The device heals a random enemy instead of its intended target |
| Damage ally | The device deals its damage to a random party member |
| Fizzle | The device produces no effect; the activation is wasted |

**Visual tell:** Arcanite crystals embedded in devices pulse with grey
veins when operating in Pallor-corrupted zones. This visual cue
appears on deployment and persists for the device's duration, warning
the player that malfunctions are possible.

### Calibrate (Pallor-Zone Action)

Lira can mitigate malfunction risk with the **Calibrate** sub-command:

- **Cost:** 0 AC
- **Action cost:** Spends Lira's turn (full turn action)
- **Target:** One active device currently on the field
- **Effect:** Removes the malfunction chance for the targeted device's
  remaining duration
- **Availability:** Appears in Lira's battle menu only in
  Pallor-corrupted zones, alongside her regular Forgewright abilities

Calibrate creates a meaningful tactical choice: Lira sacrifices her
turn to guarantee device reliability, or the player accepts the 15%
risk and uses Lira's turn offensively.

### Affected Zones

Malfunction applies in any area classified as Pallor-corrupted:

| Zone | Context |
|------|---------|
| Pallor Wastes overworld | Act III — the Ashen Approach and all five sections |
| Convergence dungeons | Act III–IV — all phases and anchor stations |
| Corrupted Interlude sections | Rail Tunnels (Pallor nests), Axis Tower (Pallor-touched floors) |

**Safe zones are exempt.** Town areas, inns, oases (ley ward stone
settlements), and any location without active Pallor corruption do not
trigger malfunction checks. The three Oases in the Pallor Wastes are
safe — their ley ward stones suppress the corruption.

### Narrative Rationale

Malfunction mechanics reinforce Lira's character arc. Her identity as
the party's engineer is tested when her tools become unreliable — the
Pallor corrupts the very Arcanite energy her devices channel. Choosing
to Calibrate represents Lira asserting control over her craft despite
hostile conditions. Characters who have completed their Act III Pallor
trial gain **Pallor Resistance**, which halves all Pallor-zone
penalties (including malfunction chance, reducing it to 7.5%). If the
full party has Pallor Resistance, zone penalties are removed entirely.

---

## 5. Recipe Unlock Progression

### Unlock Timeline

Recipes unlock as the story progresses and Lira encounters new
materials, forges, and schematics. Device recipes are detailed in
[items.md](items.md); equipment recipes are detailed in
[equipment.md](equipment.md).

| Phase | Devices Unlocked | Equipment Unlocked | Forge Access |
|-------|------------------|--------------------|--------------|
| Act I (Lira joins) | 3 — Thermal Charge, Mending Engine, Flashbang | — | Inn workbenches (basic forging) |
| Act II (Ashmark) | 4 — Frost Bomb, Shock Coil, Barrier Node, Ward Emitter | — | Ashmark full forge, Caldera forge |
| Interlude | 2 — Gravity Anchor, Disruption Pulse | 3 — Arcanite Blade, Forgewright Maul, Arcanite Helm | Lira's hidden workshop, Rail Tunnels access |
| Act III (Pallor Wastes) | 2 — Pallor Grenade, Pallor Salve | 5 — Resonance Rod, Shadowsteel Knife, Thornspear, Pallor Ward Vest, Ley-Woven Cloak | Oasis B jury-rigged forge |
| Act III (Forgotten Forge) | 1 — Arcanite Lance | — | Forgotten Forge (ancient forge) |
| Post-Convergence | 1 — Emergency Beacon | — | All prior forges |

### Schematic Items

Two key items gate specific recipe unlocks. Both are found through
exploration and cannot be purchased:

| Schematic | Location | Effect |
|-----------|----------|--------|
| Boring Engine Schematic | Rail Tunnels — East Tunnel secret room (hidden door, "Lighting" junction) | Unlocks advanced Forgewright weapon component recipe |
| Forge Schematic | **STEAL from The Architect** (Forgotten Forge F5 boss) | Prerequisite for Arcanite Lance recipe |

> **Forge Schematic is missable.** It is the only steal-only crafting
> schematic in the game. If Sable does not steal it during The
> Architect boss fight, the Arcanite Lance recipe is locked out until
> New Game+. The Architect's steal window exists only during Stage 1
> — Stage 2 (Grey Cleaver Unbound) has a different steal table.
