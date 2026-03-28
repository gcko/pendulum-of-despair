# Item Catalog — Pendulum of Despair

> Canonical reference for all consumable items, crafting materials, key
> items, Ley Crystal invocations, and Forgewright battle devices.
> For status effect definitions, see [magic.md](magic.md).
> For Ley Crystal stats/leveling, see [progression.md](progression.md).
> For enemy drop tables, see [bestiary/](bestiary/).

---

## Table of Contents

- [Inventory Structure](#inventory-structure)
- [Consumable Items](#consumable-items)
  - [HP Healing](#hp-healing)
  - [MP Restoration](#mp-restoration)
  - [Revival](#revival)
  - [Status Cures](#status-cures)
  - [Battle Utility](#battle-utility)
  - [Stat Capsules](#stat-capsules)
  - [Consumable Summary](#consumable-summary)
- [Lira's Forgewright Battle Devices](#liras-forgewright-battle-devices)
  - [Core Mechanic](#core-mechanic)
  - [Recipes](#recipes)
  - [Unlocking](#unlocking)
  - [Design Philosophy](#design-philosophy)
- [Ley Crystal Invocations](#ley-crystal-invocations)
  - [Core Mechanic](#core-mechanic-1)
  - [Invocation Catalog](#invocation-catalog)
  - [Axis Tower Suppression](#axis-tower-suppression)
- [Crafting Materials](#crafting-materials)
  - [Dual-Purpose Economy](#dual-purpose-economy)
  - [Material Tiers](#material-tiers)
  - [Complete Material List](#complete-material-list)
  - [Sell Price Formula](#sell-price-formula)
- [Key Items](#key-items)
  - [Dungeon Access](#dungeon-access)
  - [Boss Mementos](#boss-mementos)
  - [Crafting Schematics](#crafting-schematics)
  - [Story Items](#story-items)
  - [Equipment Cross-Reference](#equipment-cross-reference)
- [Cross-Reference Tables](#cross-reference-tables)
  - [Status Cure Mapping](#status-cure-mapping)
  - [Bestiary Drop Consistency](#bestiary-drop-consistency)

---

## Inventory Structure

### Tab Layout

| Tab | Contents | Stack Limit | Slot Limit |
|-----|----------|------------|------------|
| **Consumables** | Potions, Ethers, status cures, stat capsules | HP/MP healing: 199; all others: 99 | Unlimited types |
| **Materials** | Crafting materials (Beast Hide, Scrap Metal, etc.) | 99 | Unlimited types |
| **Devices** | Lira's Forgewright battle devices | 3 per type | 5 types active |
| **Key Items** | Quest items, maps, mementos, schematics | 1 (unique) | Unlimited |

### Sell Price Rules

- Consumables: sell at 50% of buy price
- Materials: sell at listed sell price (see Crafting Materials section)
- Devices: cannot be sold (crafted, not bought)
- Key items: cannot be sold
- Equipment: sell at 50% of buy price (see equipment.md — Gap 1.5, not yet created)

---

## Consumable Items

### HP Healing

> **Stack limit:** HP/MP healing items stack to 199. All other consumables stack to 99.

| Item | Effect | Buy | Sell | Availability |
|------|--------|-----|------|--------------|
| Potion | Restore 100 HP | 50 | 25 | Act I shops |
| Hi-Potion | Restore 500 HP | 300 | 150 | Act II shops |
| X-Potion | Restore 100% HP | 1,500 | 750 | Act III shops (limited) |
| Ley Tonic | Restore 300 HP to all party | 800 | 400 | Act II shops (limited stock) |
| Elixir | Restore 100% HP and MP | — | — | Chests, boss drops only |
| Megalixir | Restore 100% HP and MP to all party | — | — | 3 total (Convergence, Dreamer's Fault) |
| Sleeping Bag | Restore 25% HP/MP to all party (save point only) | 250 | 125 | Act I shops |
| Tent | Restore 50% HP/MP to all party (save point only) | 500 | 250 | Act I shops |
| Pavilion | Restore 100% HP/MP to all party (save point only) | 1,200 | 600 | Act II shops |

> **Rest item stack limit:** Sleeping Bag, Tent, and Pavilion stack to **99** (not 199 like other HP/MP items). Their full-party out-of-town utility warrants a lower cap. See [economy.md](economy.md) for pricing and availability details.

### MP Restoration

| Item | Effect | Buy | Sell | Availability |
|------|--------|-----|------|--------------|
| Ether | Restore 30 MP | 200 | 100 | Act I shops |
| Hi-Ether | Restore 100 MP | 800 | 400 | Act II shops |
| X-Ether | Restore 100% MP | 2,000 | 1,000 | Act III shops (limited) |

### Revival

| Item | Effect | Buy | Sell | Availability |
|------|--------|-----|------|--------------|
| Phoenix Feather | Revive at 25% HP | 500 | 250 | Act I shops |
| Phoenix Pinion | Revive at 100% HP | 3,000 | 1,500 | Act III shops (limited) |

### Status Cures

| Item | Cures | Buy | Sell | Availability |
|------|-------|-----|------|--------------|
| Antidote | Poison, Burn | 50 | 25 | Act I shops |
| Alarm Clock | Sleep | 75 | 37 | Act I shops |
| Echo Drop | Silence | 75 | 37 | Act I shops |
| Eye Drops | Blind | 50 | 25 | Act I shops |
| Smelling Salts | Confusion | 75 | 37 | Act I shops |
| Soft Stone | Petrify | 200 | 100 | Act II shops |
| Chronos Dust | Slow | 150 | 75 | Act II shops |
| Remedy | All except Stop, Berserk, Despair, Faint | 800 | 400 | Act II shops |
| Pallor Salve | Despair (instant cure) | 2,500 | 1,250 | Act II (Bellhaven, limited 3/visit), Interlude (Ironmark, limited 2/visit), Act III Oases. Also craftable. |
| Hope Shard | Despair (instant cure) | — | — | Rare chests/quest rewards only |

> **Despair** is the signature status of the Pallor — a creeping hopelessness
> that slows ATB speed by 25% and reduces all outgoing damage by 20%. It cannot
> be cured by Remedy; only Pallor Salve, Hope Shard, or the Hollow Mend spell
> (post-game) remove it. The limited supply of cures makes Despair a genuine
> resource-management threat, especially in the Pallor Wastes and Axis Tower.

Status effect definitions and spell-based cures: see [magic.md](magic.md#status-effect-reference).

**Items cannot cure the following statuses:**

- **Stop** — wears off only (3 real-time seconds)
- **Berserk** — Purge spell only (per magic.md)

### Battle Utility

| Item | Effect | Buy | Sell | Availability |
|------|--------|-----|------|--------------|
| Smoke Bomb | Flee from non-boss battles (100%) | 100 | 50 | Act I shops |
| Waystone | Teleport to dungeon entrance (dungeon use only) | 300 | 150 | Act II shops |
| Sable's Coin | Guaranteed preemptive next battle | — | — | Quest reward, rare chests |

### Stat Capsules

Stat Capsules are permanent, non-buyable stat boosts found in chests, hidden passages, and quest rewards. Approximately 82 total exist across the game.

| Item | Effect | Total in Game |
|------|--------|---------------|
| Strength Capsule | ATK +1 (permanent) | 15 |
| Guardian Capsule | DEF +1 (permanent) | 15 |
| Arcane Capsule | MAG +1 (permanent) | 15 |
| Warding Capsule | MDEF +1 (permanent) | 15 |
| Swiftness Capsule | SPD +1 (permanent) | 12 |
| Fortune Capsule | LCK +1 (permanent) | 10 |

> **Distribution:** 20% in Act II/Interlude, 30% in Act III, 50% in Dreamer's Fault.

### Consumable Summary

| Category | Count |
|----------|-------|
| HP Healing | 9 |
| MP Restoration | 3 |
| Revival | 2 |
| Status Cure | 10 |
| Battle Utility | 3 |
| Stat Capsules | 6 types |
| **Total** | **33** |

---

## Lira's Forgewright Battle Devices

### Core Mechanic

- **Lira crafts** at save points, camps, and inns — never mid-battle.
- **Anyone can USE** a device in battle, but only Lira can **CRAFT** them.
- **5 active device types** may be carried at once. Each type stacks to **3** (max 15 total devices).
- **Pre-crafted devices persist** when Lira leaves the party (e.g., during the Convergence split). Plan ahead.

### Recipes

| Device | Category | Effect | Materials | Gold | AC Cost | Unlocked |
|--------|----------|--------|-----------|------|---------|----------|
| Thermal Charge | Offensive | Flame AoE: 400 dmg | 2 Element Shard + 1 Scrap Metal | 100 | 1 AC (Basic) | Act I (Lira joins) |
| Frost Bomb | Offensive | Frost AoE: 400 dmg | 2 Element Shard + 1 Crystal Shard | 100 | 2 AC (Advanced) | Act II (Ashmark) |
| Shock Coil | Offensive | Storm single: 600 dmg + Slow | 1 Elemental Core + 1 Scrap Metal | 200 | 2 AC (Advanced) | Act II (Ashmark) |
| Pallor Grenade | Offensive | Spirit AoE: 500 dmg (2x vs Pallor) | 2 Pallor Sample + 1 Spirit Essence | 250 | 3 AC (Anti-Pallor) | Act III (Pallor Wastes) |
| Barrier Node | Defensive | Party DEF +25%, 3 turns | 2 Scrap Metal + 1 Crystal Shard | 150 | 2 AC (Advanced) | Act II (Ashmark) |
| Ward Emitter | Defensive | Party MDEF +25%, 3 turns | 2 Crystal Shard + 1 Ether Wisp | 150 | 2 AC (Advanced) | Act II (Ashmark) |
| Mending Engine | Defensive | Heal 800 HP + cure Poison/Burn | 2 Beast Hide + 1 Spirit Essence | 150 | 1 AC (Basic) | Act I (Lira joins) |
| Flashbang | Utility | All enemies: 80% Blind, 2 turns | 1 Element Shard + 1 Bone Fragment | 100 | 1 AC (Basic) | Act I (Lira joins) |
| Gravity Anchor | Utility | All enemies: SPD -30%, 3 turns | 1 Scrap Metal + 1 Arcanite Shard | 300 | 2 AC (Expert) | Interlude (Rail Tunnels) |
| Disruption Pulse | Utility | Remove all enemy buffs | 1 Arcanite Shard + 1 Pallor Sample | 350 | 2 AC (Expert) | Interlude (Rail Tunnels) |
| Arcanite Lance | Advanced | Non-elem single: 1,500 dmg | 1 Arcanite Core + 1 Elemental Core | 500 | 3 AC (Anti-Pallor) | Act III (Forgotten Forge) |
| Emergency Beacon | Advanced | Revive all fainted at 50% HP | 1 Arcanite Core + 2 Spirit Essence | 800 | 4 AC (Ultimate) | Post-Convergence |
| Pallor Salve | Consumable/Craft | Cure Despair (instant) | 2 Pallor Sample + 1 Spirit Essence | 200 | 3 AC (Anti-Pallor) | Act III (Pallor Wastes) |

### Unlocking

Recipes unlock as the story progresses and Lira encounters new materials and schematics:

| Phase | Recipes Available |
|-------|-------------------|
| Act I (Lira joins) | Thermal Charge, Mending Engine, Flashbang |
| Act II (Ashmark) | Frost Bomb, Shock Coil, Barrier Node, Ward Emitter |
| Interlude (Rail Tunnels) | Gravity Anchor, Disruption Pulse |
| Act III (Pallor Wastes) | Pallor Grenade, Pallor Salve |
| Act III (Forgotten Forge) | Arcanite Lance |
| Post-Convergence | Emergency Beacon |

### Design Philosophy

Forgewright devices are central to Lira's identity as an engineer and inventor. The system serves several design goals:

- **Character identity:** Crafting is Lira's unique contribution — no other party member can create devices, reinforcing her role as the party's engineer.
- **Material economy:** Enemy drops and exploration rewards gain tangible purpose through the crafting system. Players weigh selling materials for gold against saving them for devices.
- **Pre-dungeon planning:** The 5-type active loadout forces players to anticipate what they will face. Bringing Pallor Grenades into the Pallor Wastes is wise; bringing them into a fire dungeon wastes a slot.
- **Story-locked progression:** Recipe unlocking tracks narrative milestones, ensuring new devices arrive when the story introduces the threats they counter.

---

## Ley Crystal Invocations

### Core Mechanic

- Each equipped Ley Crystal grants **1 invocation** in the Magic menu.
- Invocations have **limited uses per rest cycle** — restored at inns, Sleeping Bags, Tents, Pavilions, and save points.
- Power **scales with crystal level** (Lv 1–5; see [progression.md](progression.md) for leveling details).
- Inspired by FF6's Esper summon system: powerful per-rest abilities that complement the standard spell list.
- Invocations **cannot be used** during Ley Crystal Suppression (see [Axis Tower Suppression](#axis-tower-suppression) below).

### Invocation Catalog

#### Standard Invocations

| Crystal | Invocation | Element | Lv 1 Effect | Lv 5 Effect | Uses/Rest | Category |
|---------|-----------|---------|-------------|-------------|-----------|----------|
| Ember Shard | Forge Flare | Flame | AoE 150 dmg | AoE 500 dmg | 5 | Standard |
| Iron Core | Ironwall | — (buff) | Party DEF +30%, 3t | Party DEF +50%, 3t | 4 | Standard |
| Ley Prism | Ley Cascade | Ley | AoE 200 dmg | AoE 600 dmg | 4 | Standard |
| Ward Stone | Null Barrier | — (buff) | Party MDEF +30%, 3t | Party MDEF +50%, 3t | 4 | Standard |
| Quicksilver | Time Slip | — (buff) | Party Haste 2t | Party Haste 4t | 3 | Standard |
| Fortune Stone | Fate's Hand | — (buff) | Party LCK +50%, 3t | Party LCK +100%, 3t | 5 | Standard |
| Lifestone | Lifespring | Spirit | Party heal 300 HP | Party heal 1,500 HP | 6 | Standard |
| Wellspring | Mana Tide | Ley | Party 20 MP | Party 80 MP | 4 | Standard |
| Spirit Tear | Spirit Call | Spirit | AoE 180 dmg | AoE 550 dmg + Regen | 3 | Standard |
| Forgewright Core | Siege Engine | Non-elem | Single 400 dmg + DEF break | Single 1,200 dmg + DEF break | 3 | Standard |

#### Negative-Effect Invocations

These crystals carry passive downsides (see [progression.md](progression.md)), but their invocations are among the most powerful in the game.

| Crystal | Invocation | Element | Lv 1 Effect | Lv 5 Effect | Uses/Rest | Category |
|---------|-----------|---------|-------------|-------------|-----------|----------|
| Flame Heart | Crucible Wrath | Flame | AoE 300 dmg | AoE 900 dmg + Burn | 3 | Negative |
| Frost Veil | Absolute Zero | Frost | AoE 250 dmg | AoE 800 dmg + Slow | 3 | Negative |
| Storm Eye | Tempest Surge | Storm | AoE 250 dmg | AoE 800 dmg (random target) | 4 | Negative |
| Grey Remnant | Pallor Touch | Void | AoE 350 dmg | AoE 1,000 dmg + Despair | 2 | Negative |

#### Special Invocations

| Crystal | Invocation | Element | Lv 1 Effect | Lv 5 Effect | Uses/Rest | Category |
|---------|-----------|---------|-------------|-------------|-----------|----------|
| Dawn Fragment | First Light | Non-elem | AoE 500 dmg | AoE 200 dmg | 8→2 | Special |
| Convergence Shard | Convergence Pulse | Non-elem | AoE 100 dmg | AoE 2,000 dmg | 1 | Special |
| Null Crystal | Void Shield | — (buff) | Party Despair immune 3t | Party Despair immune 3t | 2 | Special |
| Cael's Echo | Cael's Resolve | — (buff) | Party +20% all stats 3t + 500 HP | Same | 1 | Special |

**Dawn Fragment — level scaling (invest vs. exploit):**

| Level | Damage | Uses/Rest |
|-------|--------|-----------|
| Lv 1 | 500 | 8 |
| Lv 2 | 400 | 6 |
| Lv 3 | 300 | 4 |
| Lv 4 | 250 | 3 |
| Lv 5 | 200 | 2 |

**Convergence Shard — level scaling:**
Lv 1–4: AoE 100 dmg, 1 use. Lv 5: AoE 2,000 dmg, 1 use. The Shard is functionally inert until fully leveled — a long-term investment that pays off in the endgame.

### Axis Tower Suppression

- **Axis Tower Floor 1:** All invocations are greyed out in the Magic menu ("Ley interference detected").
- **Stat bonuses still apply** — passive, permanent bonuses from crystals are unaffected.
- **Only invocations are suppressed** (active abilities). Standard spells and abilities function normally.
- **Restored** after defeating Kole and destroying the conduit crystals.
- **Design intent:** Forces reliance on items, character abilities, and Forgewright devices. Players who over-invest in invocations and neglect other systems will struggle in Axis Tower.

### Design Notes

- **FF6 Esper inspiration:** Invocations mirror the Esper summon system — powerful once-per-rest abilities that complement but do not replace standard combat options.
- **Uses scale inversely with power:** Weaker utility invocations (Forge Flare, Fate's Hand) have 4–6 uses; devastating attacks (Pallor Touch, Convergence Pulse) have 1–2.
- **Dawn Fragment's "invest vs. exploit" dilemma:** Using Dawn Fragment early provides 8 uses of a strong AoE. Leveling it to Lv 5 reduces uses to 2 with weaker damage — but unlocks the crystal's powerful passive stat bonuses. Players must decide when the passive payoff outweighs the active loss.
- **Negative-effect crystals:** The passive downsides of Flame Heart, Frost Veil, Storm Eye, and Grey Remnant are offset by their invocations being the strongest elemental attacks available. Equipping them is a calculated risk.
- **Invocations and stat bonuses are independent systems.** A crystal's passive stat bonuses apply at all times (except Suppression for invocations only). Invocations are the active, limited-use component.

---

## Crafting Materials

### Dual-Purpose Economy

Every crafting material can be **sold for gold** at any shop OR **saved for Lira's Forgewright recipes**. The listed sell price represents the item's "floor value" — its worth if you simply vendor it. Crafting value is always higher than sell value, creating a constant tension between immediate gold and long-term power.

- **Sell:** Instant gold. Useful when you need consumables, equipment upgrades, or are flush with duplicate materials.
- **Craft:** Transform materials into Forgewright devices (see [Recipes](#recipes) above). Devices cannot be bought, so materials are the only path to crafting power.
- **No buyback:** Sold materials are gone. The game does not offer a buyback interface.
- **Steal priority:** Many Tier 2–3 materials are steal-only from bosses. Missing a steal permanently locks out that crafting opportunity (there is no NG+ per [postgame.md](postgame.md)).

### Material Tiers

Materials are organized into four rarity tiers that govern drop rates, steal chances, and sell price ranges.

#### Tier 1 — Common

| Property | Value |
|----------|-------|
| **Drop rate** | ~75% from standard enemies |
| **Steal chance** | 75% base (modified by LCK) |
| **Sell range** | 25–40g |
| **Role** | Bread-and-butter crafting fodder. Always available, always useful. |

**Tier 1 materials:** Beast Hide (25g), Bone Fragment (30g), Scrap Metal (35g), Element Shard (40g), Ether Wisp (40g), Leather Pouch (30g).

#### Tier 2 — Uncommon

| Property | Value |
|----------|-------|
| **Drop rate** | ~25% from standard enemies |
| **Steal chance** | 25–50% base |
| **Sell range** | 40–100g |
| **Role** | Specialized parts from specific enemy families. Required for mid-tier devices. |

**Tier 2 materials:** Specific beast parts (Sharp Fang, Drake Scale, Wolf Pelt, etc.), Crystal Shard (75g), Elemental Core (100g), Spirit Essence (100g), Grey Residue (100g), humanoid drops.

#### Tier 3 — Rare

| Property | Value |
|----------|-------|
| **Drop rate** | 25% from rare enemies, boss steals, or rare field chests |
| **Steal chance** | 75% from Pallor enemies; 10–25% from bosses |
| **Sell range** | 150–500g |
| **Role** | Rare materials for advanced devices and crafting. Pallor Sample drops from regular Pallor enemies (Grey Residue is Tier 2, not Tier 3). Arcanite materials are boss/mini-boss exclusive. |

**Tier 3 materials:** Arcanite Shard (200g), Arcanite Core (200g), Pallor Sample (150g), Pallor Shard (175g), Pallor Ward (200g), Royal Signet (200g), Roc Feather (180g), boss-specific drops, Dreamer's Fault (First/Crystal Age) materials (300–450g).

#### Tier 4 — Epic

| Property | Value |
|----------|-------|
| **Drop rate** | Fixed placement only (Arcanite Ingots found in dungeon chests and quest rewards; see dungeons-world.md and sidequests.md for locations) |
| **Steal chance** | N/A (not stealable) |
| **Sell range** | 1,000g+ (some unsellable) |
| **Role** | Endgame pinnacle materials. Arcanite Ingots are used in forgeable equipment for multiple characters (Edren, Lira, shared helm). Pallor Core and Grey Mist Essence are unsellable story-critical crafting components. |

**Tier 4 materials:** Arcanite Ingot (1,000g), Pallor Core (unsellable), Grey Mist Essence (unsellable), Dreamer's Fault (Green/Iron Age) materials (500–800g).

### Complete Material List

> **72 materials total.** Every material in the game is listed below. For enemy-specific drop tables, see [bestiary/](bestiary/).

| Name | Source Category | Tier | Sell Price (g) | Primary Crafting Use |
|------|----------------|------|---------------|---------------------|
| **Beast Parts (20)** | | | | |
| Beast Hide | Beast | 1 | 25 | Basic leather goods, Mending Engine |
| Sharp Fang | Beast | 2 | 60 | Weapon upgrades |
| Drake Fang | Beast | 2 | 80 | Consumable (500 dmg) or weapon crafting (see [Drake Fang Special Case](#drake-fang-special-case)) |
| Drake Scale | Beast | 2 | 70 | Armor reinforcement |
| Serpent Fang | Beast | 2 | 55 | Weapon upgrades |
| Leech Ichor | Beast | 2 | 50 | Poison-element crafting |
| Lurker Shell | Beast | 2 | 55 | Shield components |
| Wolf Pelt | Beast | 2 | 50 | Light armor crafting |
| Boar Tusk | Beast | 2 | 55 | Weapon hardening |
| Hawk Feather | Beast | 2 | 50 | Speed-boosting accessories |
| Hare Pelt | Beast | 2 | 40 | Light crafting |
| Beetle Carapace | Beast | 2 | 55 | Armor hardening |
| Crab Claw | Beast | 2 | 50 | Weapon components |
| Viper Fang | Beast | 2 | 55 | Poison-element crafting |
| Mite Husk | Beast | 2 | 40 | Basic components |
| Roach Wing | Beast | 2 | 40 | Basic components |
| Rat Tail | Beast | 1 | 30 | Vendor trash |
| Vermin Fang | Beast | 2 | 45 | Basic weapon components |
| Crawler Shell | Beast | 2 | 55 | Armor components |
| Petrified Bark | Beast | 2 | 65 | Pallor-touched crafting |
| **Construct Salvage (7)** | | | | |
| Scrap Metal | Construct | 1 | 35 | Device components, basic forging |
| Crystal Shard | Construct | 2 | 75 | Precision components, devices |
| Drill Fragment | Construct | 2 | 60 | Weapon components |
| Molten Gear | Construct | 2 | 70 | Flame-element forging |
| Hound Gear | Construct | 2 | 65 | Mechanical components |
| Stone Fragment | Construct | 2 | 55 | Earth-element crafting |
| Salvaged Automaton Core | Construct (fixed chest, Corrund Sewers) | 2 | 85 | Forgewright device crafting — Lira-specific (no recipe yet — reserved for future content) |
| **Spirit/Elemental (6)** | | | | |
| Ether Wisp | Spirit | 1 | 40 | MP restoration, Ward Emitter |
| Spirit Essence | Spirit | 2 | 100 | Spirit-element crafting, devices |
| Spirit Dust | Undead/Spirit | 2 | 60 | Spirit-element basics |
| Element Shard | Elemental | 1 | 40 | Elemental infusions, devices |
| Elemental Core | Elemental | 2 | 100 | Advanced elemental devices |
| Emberstone | Elemental/Fire (fixed chests: Ashmark Factory Cooling Tank + Black Forge B catwalk; 2 total) | 3 | 200 | Flame-element forging, advanced fire devices (no recipe yet — reserved for future content) |
| **Pallor (5)** | | | | |
| Pallor Sample | Pallor | 3 | 150 | Anti-Pallor consumables, Pallor Salve |
| Grey Residue | Pallor | 2 | 100 | Void-element infusions |
| Nest Fragment | Pallor | 2 | 80 | Pallor research components |
| Pallor Shard | Pallor | 3 | 175 | Advanced Pallor crafting |
| Pallor Ward | Pallor | 3 | 200 | Defensive Pallor-resistance items |
| **Undead (2)** | | | | |
| Bone Fragment | Undead | 1 | 30 | Weapon hardening, Flashbang |
| Bone Dust | Undead | 2 | 50 | Spirit-element basics |
| **Arcanite (4)** | | | | |
| Arcanite Shard | Carradan | 3 | 200 | Advanced Forgewright devices; also restores AC when consumed (see [crafting.md](crafting.md)) |
| Arcanite Core | Construct (mini-boss) | 3 | 200 | High-tier forging, Arcanite Lance |
| Arcanite Ingot | Fixed locations (dungeon chests + quest rewards) | 4 | 1,000 | Forgeable equipment component |
| Pallor-Fused Capacitor | Ley-Warped Colossus (Ley Scar, rare steal) | 3 | 300 | Oasis B quest (Amplifier Stabilization) |
| **Humanoid/Flavor Drops (14)** | | | | |
| Compact Insignia | Humanoid | 2 | 45 | Vendor trash (sell only) |
| Elite Insignia | Humanoid | 2 | 65 | Vendor trash |
| Pallor Insignia | Humanoid | 2 | 55 | Vendor trash |
| Leather Pouch | Humanoid | 1 | 30 | Vendor trash |
| Stolen Purse | Humanoid | 2 | 80 | Vendor trash (contains gold) |
| Bandit's Coin | Humanoid | 2 | 60 | Vendor trash |
| Repair Kit | Humanoid | 2 | 50 | Minor device restoration |
| Ballista Bolt | Humanoid | 2 | 45 | Vendor trash |
| Pilot's Goggles | Humanoid | 2 | 55 | Vendor trash (accessory in Gap 1.5?) |
| Royal Signet | Humanoid | 3 | 200 | Sell or trade for lore |
| Roc Feather | Beast (rare) | 3 | 180 | Speed-boosting crafting |
| Forge Hammer | Pallor | 2 | 60 | Weapon components |
| Ley Residue | Humanoid | 2 | 75 | Ley-element crafting |
| Pallor Blade | Pallor | 3 | 150 | Void-element weapon crafting |
| **Dreamer's Fault Materials (8)** | | | | |
| Ancient Glyph | Dreamer's Fault (First Age) | 3 | 300 | Age-specific recipes (TBD) |
| Carved Stone | Dreamer's Fault (First Age) | 3 | 350 | Age-specific recipes (TBD) |
| Crystal Fragment | Dreamer's Fault (Crystal Age) | 3 | 400 | Age-specific recipes (TBD) |
| Prism Shard | Dreamer's Fault (Crystal Age) | 3 | 450 | Age-specific recipes (TBD) |
| Living Bark | Dreamer's Fault (Green Age) | 4 | 500 | Age-specific recipes (TBD) |
| Heartwood Splint | Dreamer's Fault (Green Age) | 4 | 550 | Age-specific recipes (TBD) |
| Iron Cog | Dreamer's Fault (Iron Age) | 4 | 700 | Age-specific recipes (TBD) |
| Tempered Plate | Dreamer's Fault (Iron Age) | 4 | 800 | Age-specific recipes (TBD) |
| **Boss-Specific Materials (6)** | | | | |
| Dark Scale | Beast (Corrupted Spawn) | 2 | 65 | Pallor-element crafting |
| Vein Shard | Boss steal (Vein Guardian) | 3 | 150 | Ley-element weapon components |
| Ley Crystal Fragment | Boss steal (Ley Colossus, Ley Titan) | 3 | 200 | Ley-element forging |
| Reinforced Drill Bit | Boss steal (The Ironbound) | 3 | 175 | Heavy weapon components |
| Despair Shard | Boss steal (Grey Cleaver Unbound, 100%) | 3 | 200 | Pallor-element crafting; Grey Cleaver purification component |
| Nest Mother's Core | Boss drop (Pallor Nest Mother, 100%) | 3 | 200 | Anti-Pallor weapon modifications — concentrated Pallor essence (no recipe yet — reserved for future content) |

### Sell Price Formula

Material sell prices follow a tier-based formula:

```
sell_price = floor(base_value x tier_multiplier)
```

| Tier | Multiplier | Sell Range | Example |
|------|-----------|------------|---------|
| 1 (Common) | x1.0 | 25–40g | Beast Hide 25g, Ether Wisp 40g |
| 2 (Uncommon) | x2.0 | 40–100g | Sharp Fang 60g, Spirit Essence 100g |
| 3 (Rare) | x5.0 | 150–500g | Arcanite Shard 200g, Ancient Glyph 300g |
| 4 (Epic) | x10.0 | 500–1,000g+ | Arcanite Ingot 1,000g, Iron Cog 700g |

> **Note:** Some Tier 4 materials (Pallor Core, Grey Mist Essence) are flagged unsellable — they exist solely as crafting components for story-critical recipes. The sell price formula does not apply to unsellable items.

---

## Key Items

> **Inventory rules:** Key Items occupy a separate inventory tab. They cannot be sold, discarded, or stacked. Functional key items (dungeon access, schematics) auto-activate when their trigger conditions are met. Boss mementos and story items are purely narrative — they sit in the tab as trophies and lore anchors.

### Dungeon Access

These items gate progression into specific dungeons or areas. They activate automatically when the player approaches the relevant trigger point — no manual use required.

| Item | Acquired From | Auto-Use Trigger | Dungeon/Area Affected |
|------|--------------|-----------------|----------------------|
| Mine Water Vial | Ember Vein F2 chest | Approach Dying Ember Crystal | Ember Vein F3 |
| Archivist's Codex | Archive of Ages quest | Approach sealed ley door | Ley Depths F5, Forgotten Forge |
| Ironmark Tunnel Map | Old Foreman's Office hidden compartment (dungeons-city.md) | Enter Ironmark passage | Ironmark Citadel |
| Ironmark Key | Post-Kole, Axis Tower | Approach sealed Armory | Ironmark Armory |
| Forgewright Master Key | Ashmark Factory quest | Approach Compact-era locked door | All Compact dungeons |
| Map to the Convergence | General Kole drop | Open world map | Reveals Convergence location |
| Catacomb Map | Undying Warden steal | Open minimap in Valdris | Reveals secret passages |
| Broodchamber Map | Pallor Nest Mother steal | Open map in Caldera | Reveals nest network |
| Keeper's Index | Archive Keeper drop | Approach pictographic text | Completes Dry Well dictionary |

> **Steal-only access items:** Catacomb Map and Broodchamber Map are only obtainable via stealing from their respective bosses. Missing these steals permanently locks out optional content (there is no NG+ per [postgame.md](postgame.md)).

### Boss Mementos

Narrative trophies dropped by major bosses. These have no gameplay effect — they exist as story anchors and emotional bookmarks that sit in the Key Items tab.

| Item | Dropped By | Description |
|------|-----------|-------------|
| Vein Guardian's Core | Vein Guardian | A crystalline core still warm with ember heat. |
| Fenmother's Tear | Corrupted Fenmother | A single clear drop — the Fenmother's grief, crystallized. |
| Operator's Badge | The Ironbound | Tarnished name badge. The second operator's name is still legible. |
| Cael's Pendant | Cael (Phase 1) | A locket with a pressed flower inside. Lira recognizes it. |
| Cael's Sword | Pallor Incarnate | The blade is cold. It will not rust. |
| Vaelith's Quill | Vaelith | An 800-year-old scholar's quill. The ink is still wet. |
| Lost Page | The Index | A single page from the catalogue. One name. One story. |
| Grey Echo Shard | Pallor Echo | A fragment of someone Cael used to be. |

> **8 mementos total.** Each memento corresponds to a major narrative turning point. They appear in the Key Items tab in the order acquired and cannot be reordered or hidden.

### Crafting Schematics

Schematics are key items that unlock new Forgewright recipes when given to Lira. They are found in the world, not dropped by enemies (with one exception).

| Item | Acquired From | Recipe Unlocked |
|------|--------------|----------------|
| Boring Engine Schematic | Rail Tunnels East Tunnel secret room (dungeons-world.md) | Advanced Forgewright weapon component |
| Forge Schematic | The Architect (steal) | Arcanite Lance recipe prerequisite |

> **Forge Schematic** is the only steal-only crafting schematic in the game. Missing it permanently locks out the Arcanite Lance recipe (there is no NG+ per [postgame.md](postgame.md)).

### Story Items

Items that advance or gate specific plot events. Unlike dungeon access items, these do not auto-activate — they are checked by NPCs or event triggers during cutscenes.

| Item | Acquired From | Plot Effect |
|------|--------------|------------|
| Fenmother's Blessing | Corrupted Fenmother | Safe passage through Fenmother's domain |
| Compact Battle Standard | The Ashen Ram | Proof of Valdris Siege victory |
| Pallor-Laced Iron | The Ashen Ram (steal) | Evidence of Pallor in Compact war machines |
| Corrupted Tuning Fork | The Forge Warden (steal) | Links Ashmark corruption to Vaelith's broader plan |
| Caldera Employee Card | Sable pickpockets from Compact officer (Caldera) | 25% discount at all Caldera shops (net 112.5% of standard). See [economy.md](economy.md). |
| Valdris Crest | Sir Aldric, Oasis A (The Last Banner quest) | Unlocks bonus dialogue in Edren's Pallor trial |
| First Tree Seed | Ashgrove Undercroft chest (per [dungeons-world.md](dungeons-world.md) § 14e) | Used at the Convergence meadow post-game to trigger the planting scene (per [dynamic-world.md](dynamic-world.md)). Consumed on use. |

> **Pallor-Laced Iron** and **Corrupted Tuning Fork** are steal-only story items. They unlock optional dialogue and lore scenes but are not required for main story progression.

### Equipment Cross-Reference

The following **20 boss-dropped and boss-gated equipment pieces** are weapons, armor, or accessories rather than key items or materials. They are documented in full in [equipment.md](equipment.md). Listed here for cross-reference to avoid duplication.

| Equipment Drop | Dropped By | Slot |
|---------------|-----------|------|
| Colossus Shard | Ley Colossus | Accessory |
| Drayce's Failsafe Core | Forge Warden | Accessory |
| Warden's Binding | Undying Warden | Accessory |
| Kole's Epaulettes | General Kole | Armor |
| Crown Shard | Crowned Hollow | Accessory |
| Unfinished Ring | Perfect Machine | Accessory |
| Ashen Scholar's Tome | Vaelith | Accessory |
| Titan's Core | Ley Titan | Accessory |
| Nexus Crest | Wellspring Guardian | Accessory |
| Architect's Hammer | The Architect | Weapon (Lira) |
| Grey Cleaver | Grey Cleaver Unbound | Weapon (Torren) |
| Cael's Knight Crest | Cael (Phase 1) | Accessory |
| Cael's Memory | Pallor Echo | Accessory |
| Scholar's Codex | First Scholar | Accessory |
| Queen's Facet | Crystal Queen | Accessory |
| Root Crown | Rootking | Armor |
| Warden's Core | Iron Warden | Accessory |
| Dreamer's Crest | Cael's Echo (non-combat) | Accessory |
| The Pallor's Last | The Lingering (super boss) | Accessory |
| Dreamer's Mark | Dreamer's Fault Floor 20 completion | Accessory |

> **Equipment drops vs. boss mementos:** Equipment drops are usable gear with stats. Boss mementos are narrative-only key items. Some bosses drop both (e.g., Cael Phase 1 drops Cael's Knight Crest as equipment AND Cael's Pendant as a memento).

### Drake Fang Special Case

**Drake Fang** is the only dual-purpose item in the game. It exists simultaneously as:

- **Consumable:** Use in battle to deal 500 fixed damage to a single target. Particularly effective in the Vein Guardian fight where it bypasses the boss's high DEF.
- **Crafting material:** Tier 2 beast part (sell value 80g) used in weapon crafting recipes.

Drake Fangs stack in the **Materials** tab (not Consumables). When used in battle, one is consumed from the material stack. Players must weigh immediate combat utility against long-term crafting value.

---

## Cross-Reference Tables

### Status Cure Mapping

Cross-reference between status effects, item cures, and spell cures. For full status effect definitions, see [magic.md](magic.md#status-effect-reference).

| Status | Item Cure | Spell Cure | Notes |
|--------|-----------|-----------|-------|
| Poison | Antidote, Remedy | Cleansing Draught, Purge | Also cures Burn |
| Burn | Antidote, Remedy | Cleansing Draught, Purge | Shares cure with Poison |
| Sleep | Alarm Clock, Remedy | Cleansing Draught, Purge | Also cured by damage |
| Confusion | Smelling Salts, Remedy | Cleansing Draught, Purge | Also cured by damage |
| Silence | Echo Drop, Remedy | Cleansing Draught, Purge | |
| Blind | Eye Drops, Remedy | Cleansing Draught, Purge | |
| Petrify | Soft Stone, Remedy | Purge | Not cured by Cleansing Draught |
| Slow | Chronos Dust, Remedy | Purge | Not cured by Cleansing Draught |
| Stop | — | — | Wears off only (3 real-time seconds) |
| Berserk | — | Purge | No item cure |
| Faint | Phoenix Feather, Phoenix Pinion | Spirit Recall, Second Dawn | Revival items |
| Despair | Pallor Salve, Hope Shard | Hollow Mend (post-game) | Cannot be cured by Remedy |

> **Remedy** cures all negative statuses EXCEPT Stop, Berserk, Despair, and Faint.

### Bestiary Drop Consistency

Every item appearing in bestiary Steal/Drop columns (see [bestiary/](bestiary/)) maps to one of the following catalog sections:

- **Consumables** (Section 2) — Potions, Ethers, status cures, etc.
- **Materials** (Section 5) — Beast parts, construct salvage, elemental components, etc.
- **Key Items** (Section 6) — Quest items, mementos, schematics, story items.
- **Equipment** (Gap 1.5) — Boss equipment drops cross-referenced in the Equipment Cross-Reference sub-section under Key Items.

No bestiary drop references an item that is undefined in this catalog or the forthcoming equipment catalog.
