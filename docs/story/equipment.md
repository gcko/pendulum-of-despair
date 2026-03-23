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

### Staves (Maren)

Maren's weapon line. Staves use a ×0.6 ATK modifier but grant substantial
MAG bonuses, making them spell-amplification tools rather than physical
weapons. Naming follows a scholar/arcane theme reflecting Maren's
research background.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Scholar's Rod | 2 | +3 MAG | – | – | – | 0 | Starting equipment |
| Ley Wand | 6 | +5 MAG | – | – | 250 | 1 | Valdris shop |
| Glyph Staff | 8 | +7 MAG | – | – | 500 | 1 | Archive of Ages chest |
| Mythril Staff | 12 | +10 MAG | – | – | 1,000 | 2 | Act II shop |
| Runic Focus | 10 | +12 MAG | Ley | +5% spell crit | 1,800 | 2 | Ley Line Depths chest |
| Resonance Rod | 15 | +15 MAG | – | Forged | Material | 3 | Lira forges (Act III) |
| Arcane Conduit | 18 | +16 MAG | – | – | 3,500 | 3 | Interlude shop |
| Ley Conduit | 25 | +18 MAG | Ley | – | 7,000 | 4 | Act III shop |
| Archive Staff | 22 | +20 MAG | – | +10% healing | 9,000 | 4 | Dry Well chest |
| Maren's Requiem | 40 | +25 MAG | Ley | MP cost –10% | – | 5 | Crafted from Pallor Core |

---

### Daggers (Sable)

Sable's weapon line. Daggers use a ×0.85 ATK modifier but grant SPD and
LCK bonuses, making them crit-oriented and speed-focused. Naming follows
a street/shadow theme reflecting Sable's underworld background.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Street Knife | 3 | +1 SPD | – | – | – | 0 | Starting equipment |
| Stiletto | 8 | +2 SPD | – | – | 250 | 1 | Bellhaven shop |
| Pickpocket's Blade | 7 | +2 LCK | – | Steal rate +10% | 400 | 1 | Sable sidequest |
| Mythril Dagger | 15 | +3 SPD | – | – | 1,000 | 2 | Act II shop |
| Trick Blade | 14 | +3 LCK | – | +5% crit rate | 1,500 | 2 | Bellhaven Tunnels chest |
| Shadowsteel Knife | 28 | +4 SPD, +3 LCK | – | Forged | Material | 3 | Lira forges (Act III) |
| Whisper Edge | 32 | +5 SPD | – | – | 4,500 | 3 | Interlude shop |
| Twilight Fang | 42 | +4 LCK | – | 10% Poison on hit | 8,000 | 4 | Act III shop |
| Shade Razor | 48 | +6 SPD | Void | – | 10,000 | 4 | Convergence chest |
| Sable's Thread | 70 | +8 SPD, +5 LCK | – | Steal rate +25%, auto-Haste 1 turn | – | 5 | Sable sidequest |

---

### Hammers (Lira)

Lira's weapon line. Hammers use a ×1.1 ATK modifier with no secondary
stat bonuses -- pure physical damage tools. Naming follows a tool/forge
theme reflecting Lira's engineering background.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Maintenance Wrench | 4 | – | – | – | – | 0 | Starting equipment |
| Iron Mallet | 10 | – | – | – | 300 | 1 | Corrund shop |
| Pipe Hammer | 12 | – | – | – | 500 | 1 | Rail Tunnels chest |
| Compact Sledge | 20 | – | – | – | 1,200 | 2 | Act II shop |
| Forge Hammer | 24 | – | Flame | – | 2,200 | 2 | Ashmark Factory chest |
| Forgewright Maul | 40 | – | – | Forged | Material | 3 | Lira forges (Interlude) |
| Arcanite Maul | 38 | – | – | – | 5,000 | 3 | Interlude shop |
| Piston Driver | 52 | – | – | 15% Stun chance | 8,500 | 4 | Act III shop |
| Architect's Hammer | 52 | – | Storm | +25% vs Constructs | – | 4 | The Architect boss drop |
| Lira's Masterwork | 90 | +5 DEF | – | Forgewright device uses +1 | – | 5 | Crafted from Grey Mist Essence + Arcanite Ingot |

---

### Spears (Torren)

Torren's weapon line. Spears use a ×0.95 ATK modifier -- slightly below
swords but capable of back-row attacks. Naming follows a nature/spirit
theme reflecting Torren's role as spiritspeaker.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Hunting Spear | 3 | – | – | – | – | 0 | Starting equipment |
| Iron Lance | 8 | – | – | – | 250 | 1 | Thornmere shop |
| Spirit-Bound Spear | 12 | – | Spirit | – | – | 1 | Fenmother boss reward |
| Mythril Spear | 17 | – | – | – | 1,000 | 2 | Act II shop |
| Thornwood Pike | 20 | – | Earth | – | 1,800 | 2 | Thornmere Wilds chest |
| Thornspear | 30 | +3 SPD | – | Forged | Material | 3 | Lira forges (Act III) |
| Wyrmbone Lance | 35 | – | – | – | 4,500 | 3 | Interlude shop |
| Ley Lance | 45 | – | Ley | – | 7,500 | 4 | Act III shop |
| Pallor Pike | 50 | – | Spirit | +15% vs Pallor | 9,500 | 4 | Pallor Wastes chest |
| Grey Cleaver | 55 | – | Spirit (purified) | +50% vs Pallor, Despair immunity | – | 5 | Grey Cleaver Unbound boss |

> **Design note — Grey Cleaver classification:** The Grey Cleaver is
> described as a "greatsword" in bosses.md, but Torren's weapon type is
> Spears. Resolution: the Grey Cleaver is reclassified as a heavy
> two-handed polearm (halberd-class) within the Spear type. Narratively,
> it was forged as a builder's tool (not a traditional blade), and its
> shape is closer to a massive cleaving polearm than a sword. Torren
> wields it as an extension of his spiritspeaker reach.
>
> **Grey Cleaver quest stages** (see items.md Grey Cleaver section):
>
> - **Tainted:** ATK +15, DEF/MDEF/SPD –10, Despair at battle start
> - **Purified** (100 Pallor encounters): ATK +55, Spirit element,
>   +50% vs Pallor, Despair immunity

---

### Weapon Summary by Tier

| Tier | Weapons Available | ATK Range | Characters |
|------|-------------------|-----------|------------|
| 0 — Starting | Training Sword, Recruit's Claymore, Scholar's Rod, Street Knife, Maintenance Wrench, Hunting Spear | 2--5 | All six |
| 1 | Valdris Blade, Knight's Edge, Commander's Blade, War Cleaver, Ley Wand, Glyph Staff, Stiletto, Pickpocket's Blade, Iron Mallet, Pipe Hammer, Iron Lance, Spirit-Bound Spear | 6--14 | All six |
| 2 | Mythril Sword, Compact Saber, Ironbound Greatsword, Twilight Edge, Mythril Staff, Runic Focus, Mythril Dagger, Trick Blade, Compact Sledge, Forge Hammer, Mythril Spear, Thornwood Pike | 10--26 | All six |
| 3 | Arcanite Blade, Crystal Sword, Dusk Reaver, Resonance Rod, Arcane Conduit, Shadowsteel Knife, Whisper Edge, Forgewright Maul, Arcanite Maul, Thornspear, Wyrmbone Lance | 15--40 | All six (Cael: brief window) |
| 4 | Ley-Forged Longsword, Pallor Bane, Ley Conduit, Archive Staff, Twilight Fang, Shade Razor, Piston Driver, Architect's Hammer, Ley Lance, Pallor Pike | 22--52 | Five (no Cael) |
| 5 — Ultimate | Edren's Oath, Maren's Requiem, Sable's Thread, Lira's Masterwork, Grey Cleaver | 40--90 | Five (no Cael) |

---

## Head Armor

All characters can equip all head armor — there are no class restrictions.
Head armor provides DEF and MDEF with occasional status resistances at
higher tiers.

**DEF progression by tier:** 0: 2–3, 1: 5–8, 2: 10–15, 3: 18–24, 4: 28–35, 5: 40–55

| Name | DEF | MDEF | Special | Price | Tier | Acquired |
|------|-----|------|---------|-------|------|----------|
| Leather Cap | 2 | 1 | — | — | 0 | Starting (Edren) |
| Cloth Hood | 2 | 2 | — | — | 0 | Starting (Maren, Sable) |
| Iron Helm | 6 | 3 | — | 200 | 1 | Act I shops |
| Traveler's Hood | 5 | 5 | — | 250 | 1 | Act I shops |
| Ember Circlet | 7 | 4 | — | 350 | 1 | Ember Vein chest |
| Mythril Helm | 12 | 8 | — | 800 | 2 | Act II shops |
| Scholar's Cap | 8 | 12 | — | 900 | 2 | Act II shops |
| Compact Officer's Helm | 14 | 6 | — | 1,200 | 2 | Valdris Siege reward |
| Forgewright Visor | 10 | 10 | — | 1,000 | 2 | Ashmark shop |
| Crystal Helm | 22 | 16 | — | 2,500 | 3 | Interlude shop |
| Pallor Veil | 18 | 24 | Despair resist 25% | 3,000 | 3 | Axis Tower chest |
| Warding Crown | 20 | 20 | Silence immune | 2,800 | 3 | Catacombs chest |
| Arcanite Helm | 30 | 22 | — | Material | Forged | Lira forges |
| Genji Helm | 32 | 24 | — | 5,500 | 4 | Act III shop |
| Ley Crown | 28 | 30 | +5 MAG | 6,500 | 4 | Dry Well chest |
| Spiritguard Helm | 30 | 28 | Sleep immune | 5,000 | 4 | Pallor Wastes shop |
| Thornweave Hood | 26 | 32 | +3 SPD | 6,000 | 4 | Thornmere quest |
| Root Crown | 45 | 38 | +10 all stats | — | 5 | Rootking boss drop |
| Dreamer's Crown | 50 | 45 | +5 all stats, auto-Regen | — | 5 | Dreamer's Fault chest |
| Void Helm | 40 | 50 | Halve Void damage | — | 5 | Convergence chest |

> **Total:** 20 head armor pieces (2 starting, 3 Tier 1, 4 Tier 2,
> 4 Tier 3 including 1 Forged, 4 Tier 4, 3 Tier 5).

---

## Body Armor

### Light Armor

All characters can equip light armor. Light armor provides balanced DEF
and MDEF without class restrictions.

**DEF progression by tier:** 0: 4–6, 1: 8–12, 2: 15–22, 3: 25–35, 4: 40–50, 5: 55–75

| Name | DEF | MDEF | Special | Price | Tier | Acquired |
|------|-----|------|---------|-------|------|----------|
| Leather Vest | 5 | 2 | — | — | 0 | Starting (most characters) |
| Padded Coat | 4 | 3 | — | — | 0 | Starting (Sable, Maren) |
| Chain Mail | 10 | 5 | — | 300 | 1 | Act I shops |
| Reinforced Vest | 12 | 4 | — | 500 | 1 | Fenmother chest |
| Mythril Vest | 18 | 10 | — | 1,200 | 2 | Act II shops |
| Compact Uniform | 20 | 8 | — | 1,800 | 2 | Valdris Siege reward |
| Crystal Vest | 30 | 18 | — | 3,500 | 3 | Interlude shop |
| Pallor Ward Vest | 38 | 25 | Despair resist 50% | Material | Forged | Lira forges (Act III) |
| Genji Armor | 45 | 28 | — | 7,000 | 4 | Act III shop |
| Ley-Thread Mail | 42 | 32 | +5 MAG | 8,000 | 4 | Dry Well chest |
| Spirit Shroud | 60 | 50 | Halve Spirit + Void | — | 5 | Dreamer's Fault chest |
| Adamant Vest | 65 | 35 | — | — | 5 | Post-game quest |

#### Elemental Body Armor

Light armor with elemental resistance. All characters can equip these.

| Name | DEF | MDEF | Special | Price | Tier | Acquired |
|------|-----|------|---------|-------|------|----------|
| Flameguard Mail | 28 | 16 | Halve Flame damage | 3,200 | 3 | Caldera shop |
| Frostweave Vest | 26 | 18 | Halve Frost damage | 3,200 | 3 | Highcairn chest |
| Stormhide Coat | 27 | 17 | Halve Storm damage | 3,200 | 3 | Bellhaven shop |
| Earthen Plate | 30 | 14 | Halve Earth damage | 3,200 | 3 | Thornmere chest |

### Heavy Armor

Heavy armor is restricted to **Edren** and **Lira** only. Heavy armor
applies a ×1.3 DEF modifier compared to light armor at the same tier,
but has substantially lower MDEF.

| Name | DEF | MDEF | Special | Price | Tier | Acquired |
|------|-----|------|---------|-------|------|----------|
| Iron Plate | 15 | 3 | — | 400 | 1 | Act I shops |
| Steel Plate | 20 | 5 | — | 1,000 | 2 | Act II shops |
| Compact Plate | 26 | 8 | — | 2,000 | 2 | Ashmark chest |
| Arcanite Plate | 42 | 12 | — | 4,500 | 3 | Interlude shop |
| Kole's Epaulettes | 48 | 18 | +15 DEF vs physical | — | 3 | General Kole boss drop |
| Forgeheart Plate | 55 | 15 | — | 8,000 | 4 | Act III shop |
| Genji Plate | 60 | 20 | — | 9,000 | 4 | Convergence chest |
| Adamant Mail | 75 | 25 | +10 DEF, +10 ATK | — | 5 | Post-game quest |

### Robes

Robes are restricted to **Maren** and **Torren** only. Robes apply a
×0.7 DEF modifier and ×1.5 MDEF modifier compared to light armor,
making them the best choice for magic-focused characters.

| Name | DEF | MDEF | Special | Price | Tier | Acquired |
|------|-----|------|---------|-------|------|----------|
| Silk Robe | 6 | 10 | — | 300 | 1 | Act I shops |
| Ley Vestment | 10 | 20 | — | 1,200 | 2 | Act II shops |
| Ley-Woven Cloak | 20 | 40 | MP Regen 3%/turn | Material | Forged | Lira forges (Act III) |
| Archmage's Robe | 28 | 48 | +10 MAG | 7,500 | 4 | Act III shop |
| Thornmere Raiment | 35 | 65 | +15 MAG, Spirit resist | — | 5 | Torren sidequest |

### Body Armor Summary

| Category | Pieces | Equippable By |
|----------|--------|---------------|
| Light Armor | 12 | All characters |
| Elemental Body Armor | 4 | All characters |
| Heavy Armor | 8 | Edren, Lira |
| Robes | 5 | Maren, Torren |
| **Total** | **29** | — |

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
