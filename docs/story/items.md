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
- Equipment: sell at 50% of buy price (see [equipment.md](equipment.md))

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
| Tent | Restore 50% HP/MP to all party (save point only) | 500 | 250 | Act I shops |
| Cottage | Restore 100% HP/MP to all party (save point only) | 1,200 | 600 | Interlude shops |

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
| Pallor Salve | Despair (instant cure) | 2,500 | 1,250 | Act III Oases (limited). Also craftable. |
| Hope Shard | Despair (instant cure) | — | — | Rare chests/quest rewards only |

> **Despair** is the signature status of the Pallor — a creeping hopelessness
> that reduces all outgoing damage by 50% and blocks MP regeneration. It cannot
> be cured by Remedy; only Pallor Salve, Hope Shard, or the Purge spell remove
> it. The limited supply of cures makes Despair a genuine resource-management
> threat, especially in the Pallor Wastes and Axis Tower.

Status effect definitions and spell-based cures: see [magic.md](magic.md#status-effect-reference).

**Items cannot cure the following statuses:**

- **Stop** — wears off only (3 real-time seconds)
- **Berserk** — Purge spell only (per magic.md)

### Battle Utility

| Item | Effect | Buy | Sell | Availability |
|------|--------|-----|------|--------------|
| Smoke Bomb | Flee from non-boss battles (100%) | 100 | 50 | Act I shops |
| Waystone | Teleport to dungeon entrance | 300 | 150 | Act II shops |
| Sable's Coin | Guaranteed preemptive next battle | 500 | — | Quest reward, rare chests |

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
| HP Healing | 8 |
| MP Restoration | 3 |
| Revival | 2 |
| Status Cure | 10 |
| Battle Utility | 3 |
| Stat Capsules | 6 types |
| **Total** | **32** |

---

## Lira's Forgewright Battle Devices

### Core Mechanic

*Content pending — see Task 3*

### Recipes

*Content pending — see Task 3*

### Unlocking

*Content pending — see Task 3*

### Design Philosophy

*Content pending — see Task 3*

---

## Ley Crystal Invocations

### Core Mechanic

*Content pending — see Task 4*

### Invocation Catalog

*Content pending — see Task 4*

### Axis Tower Suppression

*Content pending — see Task 4*

---

## Crafting Materials

### Dual-Purpose Economy

*Content pending — see Task 5*

### Material Tiers

*Content pending — see Task 5*

### Complete Material List

*Content pending — see Task 5*

### Sell Price Formula

*Content pending — see Task 5*

---

## Key Items

### Dungeon Access

*Content pending — see Task 6*

### Boss Mementos

*Content pending — see Task 6*

### Crafting Schematics

*Content pending — see Task 6*

### Story Items

*Content pending — see Task 6*

### Equipment Cross-Reference

*Content pending — see Task 6*

---

## Cross-Reference Tables

### Status Cure Mapping

*Content pending — see Task 7*

### Bestiary Drop Consistency

*Content pending — see Task 7*
