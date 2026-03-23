# Equipment Catalog — Pendulum of Despair

> Canonical reference for all weapons, armor, and accessories.
> For damage calculations, see [combat-formulas.md](combat-formulas.md).
> For character stat growth, see [progression.md](progression.md).
> For crafting materials, see [items.md](items.md).

---

## Table of Contents

- [Equipment Slots](#equipment-slots)
- [ATK Growth Adjustment](#atk-growth-adjustment)
- [Weapons](#weapons)
  - [Weapon Types Overview](#weapon-types-overview)
  - [Weapon ATK Progression by Tier](#weapon-atk-progression-by-tier)
  - [Swords (Edren)](#swords-edren)
  - [Greatswords (Cael)](#greatswords-cael)
  - [Staves (Maren)](#staves-maren)
  - [Daggers (Sable)](#daggers-sable)
  - [Hammers (Lira)](#hammers-lira)
  - [Spears (Torren)](#spears-torren)
  - [Weapon Summary by Tier](#weapon-summary-by-tier)
- [Head Armor](#head-armor)
- [Body Armor](#body-armor)
  - [Light Armor](#light-armor)
  - [Heavy Armor](#heavy-armor)
  - [Robes](#robes)
- [Accessories](#accessories)
- [Arcanite Forging](#arcanite-forging)
- [Equipment Tiers by Act](#equipment-tiers-by-act)
- [Price Reference](#price-reference)
- [Cross-Reference Tables](#cross-reference-tables)

---

## Equipment Slots

Each party member has five equipment slots. Ley Crystal is the only slot
that is universal and not restricted by class or character.

| Slot | Purpose | Stats Provided |
|------|---------|----------------|
| Weapon | Primary offensive equipment | ATK, plus type-specific bonus (MAG, SPD, LCK) |
| Head | Helmets, hoods, circlets | DEF, MDEF, occasional status resistance |
| Body | Armor, robes, light gear | DEF, MDEF; weight class determines stat spread |
| Accessory | Rings, amulets, charms | Varies widely — stat boosts, resistances, passives |
| Ley Crystal | Socketed crystal from Ley Lines | Elemental affinity, passive effects, skill unlocks |

---

## ATK Growth Adjustment

Weapon ATK must be a meaningful portion of total ATK so that upgrades feel
impactful. The original character growth rates left weapons contributing
only 15-25% of total ATK at endgame, making shop upgrades feel negligible.
The revised rates below shift the balance so weapons provide 36-65% of
endgame ATK.

**Formula:** `ATK_at_level = floor(base + growth × (level - 1) + 0.5)` per progression.md.

### Current vs Proposed Growth Rates

| Character | Current Growth | Current ATK@50 | New Growth | New ATK@50 | Weapon % (Tier 4, +48) |
|-----------|---------------|----------------|------------|------------|------------------------|
| Edren     | +1.8          | 106            | +1.4       | 87         | 36%                    |
| Cael      | +1.5          | 89             | +1.2       | 74         | 39%                    |
| Lira      | +1.2          | 73             | +1.0       | 63         | 43%                    |
| Sable     | +1.4          | 82             | +1.1       | 67         | 42%                    |
| Torren    | +0.8          | 49             | +0.6       | 39         | 55%                    |
| Maren     | +0.5          | 31             | +0.4       | 26         | 65%                    |

> **REBALANCE FLAG:** This ATK growth reduction affects all physical damage
> calculations. The bestiary's 198 regular enemies and 29 bosses were
> balanced against the original growth rates. Gap 3.4 (Difficulty & Balance
> Framework) must verify that enemy HP values still produce 2-4 hit kills
> for regulars and 3-5 minute boss fights. Until Gap 3.4 is completed,
> bestiary values are provisional.

### Damage Verification Examples

Using the standard damage formula from combat-formulas.md:

| Scenario | ATK Calc | vs DEF | Damage | Enemy HP | Hits to Kill |
|----------|----------|--------|--------|----------|--------------|
| Edren Lv 18, Tier 1 (+10) | 42 + 10 = 52 | 19 | 431 | 320 | 1 |
| Edren Lv 18, Tier 2 (+18) | 42 + 18 = 60 | 26 | 574 | 819 | 2 |
| Edren Lv 35, Tier 3 (+32) | 66 + 32 = 98 | 47 | 1,553 | 2,645 | 2 |
| Edren Lv 50, Tier 4 (+48) | 87 + 48 = 135 | 65 | 2,972 | 5,120 | 2 |

These examples confirm that the reduced growth rates paired with weapon
ATK still produce the target 2-hit kill range for on-level regular enemies.

---

## Weapons

### Weapon Types Overview

Each character has a primary weapon type. Some characters share access to
a secondary type with reduced proficiency.

| Character | Primary Type | Secondary Type |
|-----------|-------------|----------------|
| Edren     | Sword       | –              |
| Cael      | Greatsword  | –              |
| Maren     | Staff       | –              |
| Sable     | Dagger      | –              |
| Lira      | Hammer      | –              |
| Torren    | Spear       | –              |

### ATK Modifier by Weapon Type

Base ATK values in the weapon tables below are before this modifier is
applied. The modifier adjusts effective ATK and may grant bonus stats.

| Type       | ATK Modifier | Bonus / Penalty | Notes |
|------------|-------------|-----------------|-------|
| Sword      | ×1.0        | —               | Balanced baseline |
| Greatsword | ×1.15       | SPD -2 to -5    | Highest raw ATK, speed penalty |
| Staff      | ×0.6        | +MAG            | Low physical ATK, boosts magic |
| Dagger     | ×0.85       | +SPD, +LCK      | Fast attacks, crit-oriented |
| Hammer     | ×1.1        | —               | High ATK, slight edge over swords |
| Spear      | ×0.95       | —               | Slightly below swords, back-row capable |

### Weapon Stat Template

All weapon tables in the sections below use these columns:

| Column | Type | Description |
|--------|------|-------------|
| Name | string | Unique weapon name |
| ATK | int | Base ATK before type modifier |
| Bonus Stat | string | Additional stat bonuses (e.g., +3 MAG) |
| Element | enum | None, Fire, Ice, Lightning, Earth, Wind, Water, Holy, Dark |
| Special | string | Passive effect or proc (if any) |
| Price | int | Shop price in gold (— if not sold) |
| Tier | int | 0-5 or Forged |
| Acquired | string | Where/how the weapon is obtained |

### Weapon ATK Progression by Tier

| Tier | Act | ATK Range | Price Range | Acquisition |
|------|-----|-----------|-------------|-------------|
| 0 — Starting | Prologue | 3–5 | Free | Initial equipment |
| 1 | Act I | 8–12 | 200–600 | Shops, chests |
| 2 | Act II | 15–22 | 800–2,500 | Shops, dungeons |
| 3 | Interlude | 28–38 | 2,000–5,000 | Limited shops, chests |
| 4 | Act III | 42–55 | 4,000–10,000 | Shops, Pallor Wastes |
| 5 — Ultimate | Endgame | 65–100 | Not sold | Sidequests, bosses, Dreamer's Fault |
| Forged | Various | +5–10 above tier | Material cost | Lira's Arcanite Forging |

---

### Swords (Edren)

Edren's weapon line. Swords use a ×1.0 ATK modifier -- balanced baseline
with no penalties. Naming follows a knight/duty theme reflecting Edren's
Compact oath. Occasional MAG or DEF bonuses appear on special or
endgame swords.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Training Sword | 4 | – | – | – | – | 0 | Starting equipment |
| Valdris Blade | 10 | – | – | – | 300 | 1 | Valdris shop |
| Knight's Edge | 12 | – | – | – | 500 | 1 | Ember Vein chest |
| Mythril Sword | 18 | – | – | – | 1,200 | 2 | Act II shops |
| Compact Saber | 22 | – | – | Stolen Compact design | 2,000 | 2 | Ashmark chest |
| Arcanite Blade | 35 | +5 MAG | – | Forged | Material | 3 | Lira forges (Interlude) |
| Crystal Sword | 33 | – | – | – | 4,000 | 3 | Interlude shop |
| Ley-Forged Longsword | 48 | – | Ley | – | 8,000 | 4 | Act III shop |
| Pallor Bane | 52 | – | Spirit | +25% vs Pallor | 10,000 | 4 | Pallor Wastes chest |
| Edren's Oath | 80 | +10 DEF | Spirit | Auto-Protect 1 turn at battle start | – | 5 | Edren sidequest |

---

### Greatswords (Cael)

Cael's weapon line. Greatswords use a ×1.15 ATK modifier with a mandatory
SPD penalty (–2 to –5). Naming follows a commander/shadow theme reflecting
Cael's authority and eventual betrayal.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Recruit's Claymore | 5 | SPD –2 | – | – | – | 0 | Starting equipment |
| Commander's Blade | 12 | SPD –2 | – | – | 400 | 1 | Valdris armory |
| War Cleaver | 14 | SPD –3 | – | – | 600 | 1 | Fenmother chest |
| Ironbound Greatsword | 22 | SPD –3 | – | – | 1,500 | 2 | Act II shop |
| Twilight Edge | 26 | SPD –3 | – | +10% crit rate | 2,500 | 2 | Ley Line Depths chest |
| Dusk Reaver | 40 | SPD –4 | – | – | 5,000 | 3 | Interlude shop (brief window) |

> **Design note:** Cael's betrayal during the Interlude removes him from the
> party permanently. Tiers 3--5 greatswords have extremely limited
> availability. The Grey Cleaver (his narrative weapon) is actually a
> Torren-exclusive spear-class weapon obtained post-betrayal. Cael's
> greatswords represent who he *was*, not who he becomes. His equipment
> line intentionally ends abruptly at Tier 3 with no Tier 4--5 entries.

---

### Staves (Torren, Maren)

*Content pending — see Task 3*

---

### Daggers (Lira)

*Content pending — see Task 3*

---

### Hammers (Sable)

*Content pending — see Task 4*

---

### Spears (Cael alt, Sable alt)

*Content pending — see Task 4*

---

## Head Armor

*Content pending — see Task 5*

---

## Body Armor

### Light Armor

*Content pending — see Task 6*

### Heavy Armor

*Content pending — see Task 6*

### Robes

*Content pending — see Task 6*

---

## Accessories

*Content pending — see Task 7*

---

## Arcanite Forging

*Content pending — see Task 8*

---

## Equipment Tiers by Act

*Content pending — derived from weapon/armor tier tables above once Tasks 2-7 are complete.*

---

## Price Reference

*Content pending — derived from weapon/armor price data once Tasks 2-7 are complete.*

---

## Cross-Reference Tables

*Content pending — see Task 9*
