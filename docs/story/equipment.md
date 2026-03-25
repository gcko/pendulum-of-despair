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

Each party member has five equipment slots. Weapons are character-exclusive
(one type per character). Head armor and accessories are universal (all
characters). Body armor has light/heavy/robe sub-types with character
restrictions. Ley Crystal is a separate progression system (see
[progression.md](progression.md)).

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
only 31–61% of total ATK at Lv 50 with a Tier 4 weapon (Edren 31% to
Maren 61%). The revised rates shift the balance so weapons provide
36–65% of ATK at Lv 50.

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

Each character has exactly one equippable weapon type. No sharing,
no secondary types. This creates clear identity — Edren IS swords,
Lira IS hammers.

| Character | Weapon Type | Fantasy |
|-----------|-----------|---------|
| Edren | Sword | Knight one-handers, longswords |
| Cael | Greatsword | Two-hand heavy blades |
| Maren | Staff | Casting staves, arcane rods |
| Sable | Dagger | Knives, stilettos, shivs |
| Lira | Hammer | Wrenches, mallets, forge tools |
| Torren | Spear | Lances, pikes, javelins |

### ATK Modifier by Weapon Type

ATK values in the weapon tables below **already include** the type
modifier. Swords are the ×1.0 baseline; other types are adjusted
relative to that. The modifier also determines bonus stats (e.g.,
Staves always grant +MAG, Daggers grant +SPD/LCK).

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
| ATK | int | ATK bonus (type modifier already applied) |
| Bonus Stat | string | Additional stat bonuses (e.g., +3 MAG) |
| Element | enum | —, Flame, Frost, Storm, Earth, Ley, Spirit, Void (per magic.md) |
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
| Forged | Various | +5–10 above tier | — (Forged) | Lira's Arcanite Forging |

---

### Swords (Edren)

Edren's weapon line. Swords use a ×1.0 ATK modifier -- balanced baseline
with no penalties. Naming follows a knight/duty theme reflecting Edren's
Compact oath. Occasional MAG or DEF bonuses appear on special or
endgame swords.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Training Sword | 4 | — | — | — | — | 0 | Starting equipment |
| Valdris Blade | 10 | — | — | — | 300 | 1 | Valdris shop |
| Knight's Edge | 12 | — | — | — | 500 | 1 | Ember Vein chest |
| Mythril Sword | 18 | — | — | — | 1,200 | 2 | Act II shops |
| Compact Saber | 22 | — | — | Stolen Compact design | 2,000 | 2 | Ashmark chest |
| Arcanite Blade | 35 | +5 MAG | — | Forged | — (Forged) | 3 | Lira forges (Interlude) |
| Crystal Sword | 33 | — | — | — | 4,000 | 3 | Interlude shop |
| Ley-Forged Longsword | 48 | — | Ley | — | 8,000 | 4 | Act III shop |
| Pallor Bane | 52 | — | Spirit | +25% vs Pallor | 10,000 | 4 | Pallor Wastes chest |
| Edren's Oath | 80 | +10 DEF | Spirit | Auto-Protect 1 turn at battle start | — | 5 | Edren sidequest |

---

### Greatswords (Cael)

Cael's weapon line. Greatswords use a ×1.15 ATK modifier with a mandatory
SPD penalty (–2 to –5). Naming follows a commander/shadow theme reflecting
Cael's authority and eventual betrayal.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Recruit's Claymore | 5 | SPD —2 | — | — | — | 0 | Starting equipment |
| Commander's Blade | 12 | SPD —2 | — | — | 400 | 1 | Valdris armory |
| War Cleaver | 14 | SPD —3 | — | — | 600 | 1 | Fenmother chest |
| Ironbound Greatsword | 22 | SPD —3 | — | — | 1,500 | 2 | Act II shop |
| Twilight Edge | 26 | SPD —3 | — | +10% crit rate | 2,500 | 2 | Ley Line Depths chest |
| Dusk Reaver | 40 | SPD —4 | — | — | 5,000 | 3 | Interlude shop (brief window) |

> **Design note:** Cael's betrayal during the Interlude removes him from the
> party permanently. Tiers 3–5 greatswords have extremely limited
> availability. The Grey Cleaver (his narrative weapon) is actually a
> Torren-exclusive spear-class weapon obtained post-betrayal. Cael's
> greatswords represent who he *was*, not who he becomes. His equipment
> line intentionally ends abruptly at Tier 3 with no Tier 4–5 entries.

---

### Staves (Maren)

Maren's weapon line. Staves use a ×0.6 ATK modifier but grant substantial
MAG bonuses, making them spell-amplification tools rather than physical
weapons. Naming follows a scholar/arcane theme reflecting Maren's
research background.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Scholar's Rod | 2 | +3 MAG | — | — | — | 0 | Starting equipment |
| Ley Wand | 6 | +5 MAG | — | — | 250 | 1 | Valdris shop |
| Glyph Staff | 8 | +7 MAG | — | — | 500 | 1 | Archive of Ages chest |
| Mythril Staff | 12 | +10 MAG | — | — | 1,000 | 2 | Act II shop |
| Runic Focus | 10 | +12 MAG | Ley | +5% spell crit | 1,800 | 2 | Ley Line Depths chest |
| Resonance Rod | 15 | +15 MAG | — | Forged | — (Forged) | 3 | Lira forges (Act III) |
| Arcane Conduit | 18 | +16 MAG | — | — | 3,500 | 3 | Interlude shop |
| Ley Conduit | 25 | +18 MAG | Ley | — | 7,000 | 4 | Act III shop |
| Archive Staff | 22 | +20 MAG | — | +10% healing | 9,000 | 4 | Dry Well chest |
| Maren's Requiem | 40 | +25 MAG | Ley | MP cost -10% | — | 5 | Crafted from Pallor Core |

---

### Daggers (Sable)

Sable's weapon line. Daggers use a ×0.85 ATK modifier but grant SPD and
LCK bonuses, making them crit-oriented and speed-focused. Naming follows
a street/shadow theme reflecting Sable's underworld background.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Street Knife | 3 | +1 SPD | — | — | — | 0 | Starting equipment |
| Stiletto | 8 | +2 SPD | — | — | 250 | 1 | Bellhaven shop |
| Pickpocket's Blade | 7 | +2 LCK | — | Steal rate +10% | 400 | 1 | Sable sidequest |
| Mythril Dagger | 15 | +3 SPD | — | — | 1,000 | 2 | Act II shop |
| Trick Blade | 14 | +3 LCK | — | +5% crit rate | 1,500 | 2 | Bellhaven Tunnels chest |
| Shadowsteel Knife | 28 | +4 SPD, +3 LCK | — | Forged | — (Forged) | 3 | Lira forges (Act III) |
| Whisper Edge | 32 | +5 SPD | — | — | 4,500 | 3 | Interlude shop |
| Twilight Fang | 42 | +4 LCK | — | 10% Poison on hit | 8,000 | 4 | Act III shop |
| Shade Razor | 48 | +6 SPD | Void | — | 10,000 | 4 | Convergence chest |
| Sable's Thread | 70 | +8 SPD, +5 LCK | — | Steal rate +25%, auto-Haste 1 turn | — | 5 | Sable sidequest |

---

### Hammers (Lira)

Lira's weapon line. Hammers use a ×1.1 ATK modifier with no secondary
stat bonuses -- pure physical damage tools. Naming follows a tool/forge
theme reflecting Lira's engineering background.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Maintenance Wrench | 4 | — | — | — | — | 0 | Starting equipment |
| Iron Mallet | 10 | — | — | — | 300 | 1 | Corrund shop |
| Pipe Hammer | 12 | — | — | — | 500 | 1 | Rail Tunnels chest |
| Compact Sledge | 20 | — | — | — | 1,200 | 2 | Act II shop |
| Forge Hammer | 24 | — | Flame | — | 2,200 | 2 | Ashmark Factory chest |
| Forgewright Maul | 40 | — | — | Forged | — (Forged) | 3 | Lira forges (Interlude) |
| Arcanite Maul | 38 | — | — | — | 5,000 | 3 | Interlude shop |
| Piston Driver | 52 | — | — | 15% Stun chance | 8,500 | 4 | Act III shop |
| Architect's Hammer | 52 | — | Storm | +25% vs Constructs | — | 4 | The Architect boss drop |
| Lira's Masterwork | 90 | +5 DEF | — | Forgewright device uses +1 | — | 5 | Crafted from Grey Mist Essence + Arcanite Ingot |

---

### Spears (Torren)

Torren's weapon line. Spears use a ×0.95 ATK modifier -- slightly below
swords but capable of back-row attacks. Naming follows a nature/spirit
theme reflecting Torren's role as spiritspeaker.

| Name | ATK | Bonus | Element | Special | Price | Tier | Acquired |
|------|-----|-------|---------|---------|-------|------|----------|
| Hunting Spear | 3 | — | — | — | — | 0 | Starting equipment |
| Iron Lance | 8 | — | — | — | 250 | 1 | Thornmere shop |
| Spirit-Bound Spear | 12 | — | Spirit | — | — | 1 | Fenmother boss reward |
| Mythril Spear | 17 | — | — | — | 1,000 | 2 | Act II shop |
| Thornwood Pike | 20 | — | Earth | — | 1,800 | 2 | Thornmere Wilds chest |
| Thornspear | 30 | +3 SPD | — | Forged | — (Forged) | 3 | Lira forges (Act III) |
| Wyrmbone Lance | 35 | — | — | — | 4,500 | 3 | Interlude shop |
| Ley Lance | 45 | — | Ley | — | 7,500 | 4 | Act III shop |
| Pallor Pike | 50 | — | Spirit | +15% vs Pallor | 9,500 | 4 | Pallor Wastes chest |
| Grey Cleaver (tainted) | 15 | DEF/MDEF/SPD –10 | — | Despair at battle start. Cursed — see quest below | — | * | Grey Cleaver Unbound boss |
| Grey Cleaver (purified) | 55 | — | Spirit | +50% vs Pallor, Despair immunity | — | 5 | 100 Pallor encounters |

> **Note:** Grey Cleaver (tainted) is marked Tier * because its ATK 15
> is intentionally below Tier 5 range. It is a cursed weapon that must
> be purified through 100 Pallor encounters to reach its Tier 5 stats.

> **Design note — Grey Cleaver classification:** The Grey Cleaver is
> described as a "greatsword" in bosses.md, but Torren's weapon type is
> Spears. Resolution: the Grey Cleaver is reclassified as a heavy
> two-handed polearm (halberd-class) within the Spear type. Narratively,
> it was forged as a builder's tool (not a traditional blade), and its
> shape is closer to a massive cleaving polearm than a sword. Torren
> wields it as an extension of his spiritspeaker reach.
>
> **Grey Cleaver quest stages** (see [bosses.md](bestiary/bosses.md#grey-cleaver--cursed-weapon-quest)):
>
> - **Tainted:** ATK +15, DEF/MDEF/SPD –10, Despair at battle start
> - **Purified** (100 Pallor encounters): ATK +55, Spirit element,
>   +50% vs Pallor, Despair immunity

---

### Weapon Summary by Tier

| Tier | Weapons Available | ATK Range | Characters |
|------|-------------------|-----------|------------|
| 0 — Starting | Training Sword, Recruit's Claymore, Scholar's Rod, Street Knife, Maintenance Wrench, Hunting Spear | 2–5 | All six |
| 1 | Valdris Blade, Knight's Edge, Commander's Blade, War Cleaver, Ley Wand, Glyph Staff, Stiletto, Pickpocket's Blade, Iron Mallet, Pipe Hammer, Iron Lance, Spirit-Bound Spear | 6–14 | All six |
| 2 | Mythril Sword, Compact Saber, Ironbound Greatsword, Twilight Edge, Mythril Staff, Runic Focus, Mythril Dagger, Trick Blade, Compact Sledge, Forge Hammer, Mythril Spear, Thornwood Pike | 10–26 | All six |
| 3 | Arcanite Blade, Crystal Sword, Dusk Reaver, Resonance Rod, Arcane Conduit, Shadowsteel Knife, Whisper Edge, Forgewright Maul, Arcanite Maul, Thornspear, Wyrmbone Lance | 15–40 | All six (Cael: brief window) |
| 4 | Ley-Forged Longsword, Pallor Bane, Ley Conduit, Archive Staff, Twilight Fang, Shade Razor, Piston Driver, Architect's Hammer, Ley Lance, Pallor Pike | 22–52 | Five (no Cael) |
| 5 — Ultimate | Edren's Oath, Maren's Requiem, Sable's Thread, Lira's Masterwork, Grey Cleaver | 40–90 | Five (no Cael) |

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
| Arcanite Helm | 30 | 22 | — | — (Forged) | Forged | Lira forges |
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
| Pallor Ward Vest | 38 | 25 | Despair resist 50% | — (Forged) | Forged | Lira forges (Act III) |
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
| Kole's Epaulettes | 45 | 15 | +10 MDEF | — | 4 | General Kole boss drop (early Tier 4) |
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
| Ley-Woven Cloak | 20 | 40 | MP Regen 3%/turn | — (Forged) | Forged | Lira forges (Act III) |
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

All characters can equip any accessory. Each character has one accessory
slot. Accessories provide stat boosts, status immunities, elemental
resistances, or combat mechanic effects. Progression follows FF6 Relic
design: stat-focused early, effect-focused late.

### Stat Boost Accessories

Basic stat accessories available from shops in Acts I–II.

| Name | Effect | Price | Act | Acquired |
|------|--------|-------|-----|----------|
| Power Ring | +5 ATK | 300 | I | Act I shops |
| Iron Bracelet | +5 DEF | 300 | I | Act I shops |
| Magic Earring | +5 MAG | 400 | I | Act I shops |
| Warding Charm | +5 MDEF | 400 | I | Act I shops |
| Sprint Shoes | +5 SPD | 500 | II | Act II shops |
| Lucky Coin | +5 LCK | 500 | II | Act II shops |
| Life Pendant | +300 HP | 800 | II | Act II shops |
| Mana Bead | +50 MP | 800 | II | Act II shops |

### Status Immunity Accessories

Prevent specific status ailments. Available mid- to late-game as
status-inflicting enemies grow more common.

| Name | Effect | Price | Act | Acquired |
|------|--------|-------|-----|----------|
| Antidote Charm | Poison immune | 600 | II | Act II shops |
| Clarity Band | Confusion immune | 800 | II | Act II shops |
| Silence Ward | Silence immune | 800 | II | Interlude shop |
| Stone Guard | Petrify immune | 1,500 | Int | Interlude shop |
| Berserk Collar | Berserk immune | 2,000 | III | Act III shop |
| Despair Ward | Despair immune | 5,000 | III | Act III Oases (very limited, 1–2 available) |

### Elemental Resistance Accessories

Halve incoming damage of a specific element. Available in Act III
when elemental-heavy encounters become routine.

| Name | Effect | Price | Act | Acquired |
|------|--------|-------|-----|----------|
| Flame Ring | Halve Flame damage | 3,000 | III | Act III shop |
| Frost Amulet | Halve Frost damage | 3,000 | III | Act III shop |
| Storm Pendant | Halve Storm damage | 3,000 | III | Pallor Wastes chest |
| Void Ward | Halve Void damage | 4,000 | III | Convergence chest |

### Combat Mechanic Accessories

Grant passive combat effects. Available from Act II onward; several
first appear during the Interlude (Haste Bangle, Counter Ring,
Preemptive Charm, Infiltrator's Cloak).

| Name | Effect | Price | Act | Acquired |
|------|--------|-------|-----|----------|
| Haste Bangle | Auto-Haste 2 turns at battle start | 2,500 | Int | Interlude shop |
| Counter Ring | +15% counter-attack rate | 3,000 | Int | Catacombs chest |
| Preemptive Charm | +25% preemptive strike rate | 2,000 | Int | Bellhaven quest |
| Ley Amplifier | +20% spell damage | 4,000 | III | Dry Well chest |
| Pallor Bane Charm | +25% damage vs Pallor-type | 3,500 | III | Act III shop |
| MP Regen Ring | Restore 3% max MP per turn | 4,500 | III | Ley Line Depths F5 chest |
| Ward Talisman | Danger counter increment ×0.5 (fewer encounters) | 1,500 | II | Bellhaven, Corrund shops |
| Lure Talisman | Danger counter increment ×2.0 (more encounters) | 800 | II | Corrund, Ironmark shops |
| Infiltrator's Cloak | Danger counter increment ×0.5 (fewer encounters) | — | Int | Axis Tower F2 treasure |

> **Encounter rate accessories:** See [combat-formulas.md](combat-formulas.md)
> (Encounter System section) for the danger counter model, stacking
> rules, and interaction with location-specific modifiers (Tunnel Map,
> Kole's patrol timing).

### Character-Specific / Boss Drop Accessories

Unique accessories obtained from boss drops, sidequests, and post-game
content. Not sold in any shop.

| Name | Effect | Source | Act |
|------|--------|--------|-----|
| Colossus Shard | +10 ATK, +10 DEF, Ley affinity | Ley Colossus | II |
| Drayce's Failsafe Core | +12 DEF, +8 MDEF, auto-Shield Protocol (once per battle at 25% HP) | Forge Warden | II |
| Warden's Binding | Auto-Protect and Auto-Shell at battle start | Undying Warden | Int |
| Crown Shard | +10 ATK, +10 MAG, leadership aura (+5% party damage) | Crowned Hollow | III |
| Unfinished Ring | +15 MAG, Forgewright ability boost (Lira only) | Perfect Machine | III |
| Ashen Scholar's Tome | +15% party magic damage | Vaelith | III |
| Titan's Core | +25 MAG, +25 MDEF, Ley affinity, MP Regen 2%/turn | Ley Titan | III |
| Nexus Crest | +25 ATK, +25 DEF, +25 MAG, +25 SPD, Builder's Resonance (halve ley damage, double healing received) | Wellspring Guardian | III |
| Cael's Knight Crest | +20 all stats (Edren only) | Cael Phase 1 | III |
| Cael's Memory | +10% damage vs Pallor, grief resonance | Pallor Echo | III |
| Scholar's Codex | +20 MAG, +10 SPD, spell cost -10% | First Scholar | Post |
| Queen's Facet | Reflects 25% magic damage passively | Crystal Queen | Post |
| Warden's Core | Counter-attack on physical hit | Iron Warden | Post |
| Dreamer's Crest | +30 all stats (best accessory in game) | Cael's Echo (non-combat) | Post |

### Accessory Summary

| Category | Count |
|----------|-------|
| Stat Boost | 8 |
| Status Immunity | 6 |
| Elemental Resistance | 4 |
| Combat Mechanic | 9 |
| Character-Specific / Boss Drop | 14 |
| **Total** | **41** |

---

## Arcanite Forging

Lira's unique crafting system. Arcanite Forging allows the party to
create equipment from gathered materials at save points and camps.
Forged equipment carries a visible **"Forged"** tag in the equipment
menu, cannot be bought from shops, and can only be crafted by Lira.

### Forgeable Equipment

Eight pieces total — five weapons and three armor. Each is listed in
its respective weapon/armor section above; this table collects them
in one reference.

| Name | Slot | Stats | Materials | Gold | Unlock |
|------|------|-------|-----------|------|--------|
| Arcanite Blade | Weapon (Edren) | ATK 35, +5 MAG | 1 Arcanite Ingot + 3 Crystal Shard | 500 | Interlude |
| Forgewright Maul | Weapon (Lira) | ATK 40 | 1 Arcanite Ingot + 2 Scrap Metal + 1 Drill Fragment | 500 | Interlude |
| Thornspear | Weapon (Torren) | ATK 30, +3 SPD | 3 Spirit Essence + 2 Petrified Bark | 400 | Act III |
| Shadowsteel Knife | Weapon (Sable) | ATK 28, +4 SPD, +3 LCK | 2 Pallor Sample + 1 Arcanite Shard | 400 | Act III |
| Resonance Rod | Weapon (Maren) | ATK 15, +15 MAG | 2 Elemental Core + 2 Ley Crystal Fragment | 500 | Act III |
| Arcanite Helm | Head | DEF 30, MDEF 22 | 1 Arcanite Ingot + 2 Drill Fragment | 400 | Interlude |
| Pallor Ward Vest | Body (Light) | DEF 38, MDEF 25, Despair resist 50% | 3 Pallor Sample + 2 Grey Residue + 1 Spirit Essence | 500 | Act III |
| Ley-Woven Cloak | Body (Robe) | DEF 20, MDEF 40, MP Regen 3%/turn | 2 Ether Wisp + 2 Elemental Core + 1 Ley Crystal Fragment | 500 | Act III |

### Elemental Infusions

Any weapon can receive an elemental infusion. Infusions are permanent
but replaceable — applying a new infusion overwrites the previous one.
Infusions can be removed for free at save points. Infused weapons
display an **(Infused: Element)** suffix in the equipment menu.

> **Exception:** Weapons with narrative-fixed elements (Grey Cleaver
> purified = Spirit) cannot be infused. Their element is part of the
> quest reward and cannot be overwritten. Tainted Grey Cleaver CAN be
> infused (the tainted form has no fixed element).

| Infusion | Element | Materials | Gold |
|----------|---------|-----------|------|
| Flame Infusion | Flame | 2 Element Shard + 1 Molten Gear | 300 |
| Frost Infusion | Frost | 2 Element Shard + 1 Crystal Shard | 300 |
| Storm Infusion | Storm | 2 Element Shard + 1 Scrap Metal | 300 |
| Earth Infusion | Earth | 2 Element Shard + 1 Stone Fragment | 300 |
| Ley Infusion | Ley | 2 Elemental Core + 1 Ley Crystal Fragment | 500 |
| Spirit Infusion | Spirit | 2 Spirit Essence + 1 Ether Wisp | 500 |
| Void Infusion | Void | 2 Pallor Sample + 1 Grey Residue | 500 |

### Secret Synergies

Certain weapon + infusion combinations unlock a hidden synergy,
transforming the weapon into a named variant with a bonus effect.
There are no in-game hints until the synergy activates. When a synergy
triggers, the notification reads: *"Lira senses a resonance between
the [weapon] and the [element] infusion. The weapon transforms..."*

| Base Weapon | Infusion | Synergy Name | Bonus Effect |
|-------------|----------|--------------|--------------|
| Grey Cleaver (tainted) | Spirit | Penitent's Edge | Purification counter: 50 encounters (was 100) |
| Architect's Hammer | Storm | Stormforge Hammer | +25% damage vs Construct-type |
| Any Torren Spear | Earth | Rootbound Lance | 20% chance to inflict Slow on physical hit |
| Any Maren Staff | Ley | Resonance Staff | MP cost of all spells -15% |
| Any Sable Dagger | Void | Shadowfang | Steal rate +25%, successful steals 15% Despair chance |
| Any Lira Hammer | Flame | Crucible Maul | Forgewright device gold cost -50% |
| Any Edren Sword | Spirit | Oathkeeper | +15% damage when any ally has Faint status |

#### Synergy Narrative Justifications

- **Penitent's Edge:** The Spirit infusion accelerates the Grey Cleaver's purification by resonating with the lingering spiritspeaker echoes bound into the tainted blade.
- **Stormforge Hammer:** Storm energy overcharges the Architect's own design principles, turning its anti-Construct properties into a devastating feedback loop.
- **Rootbound Lance:** Earth energy channels through the spear's shaft into the ground, entangling targets with momentary root growth on impact.
- **Resonance Staff:** Ley energy harmonizes with the staff's natural arcane conductivity, reducing the friction of spellcasting.
- **Shadowfang:** Void energy coats the dagger's edge, letting Sable slice through material and morale alike — stolen goods carry a whisper of despair.
- **Crucible Maul:** Flame energy superheats the hammer's striking surface, allowing Lira to work metal more efficiently and halving device forging costs.
- **Oathkeeper:** Spirit energy responds to Edren's protective instincts — when an ally falls, the oath burns brighter.

---

## Equipment Tiers by Act

Summary of available equipment power by act. Weapon ATK ranges
include type modifiers (Swords are the ×1.0 baseline).

| Act | Weapon Tier | Head Tier | Body Tier | Key Accessories |
|-----|-------------|-----------|-----------|-----------------|
| Act I | Tier 0-1 (ATK 3-12) | Tier 0-1 (DEF 2-8) | Tier 0-1 (DEF 4-12) | Stat boosts (+5) |
| Act II | Tier 2 (ATK 15-22) | Tier 2 (DEF 10-15) | Tier 2 (DEF 15-22) | Status immunity, Colossus Shard |
| Interlude | Tier 3 (ATK 28-38) | Tier 3 (DEF 18-24) | Tier 3 (DEF 25-35) | Haste Bangle, Counter Ring, Kole's Epaulettes |
| Act III | Tier 4 (ATK 42-55) | Tier 4 (DEF 28-35) | Tier 4 (DEF 40-50) | Elemental resist, Despair Ward, Ley Amplifier |
| Ultimate | Tier 5 (ATK 65-100) | Tier 5 (DEF 40-55) | Tier 5 (DEF 55-75) | Dreamer's Crest, Cael's Knight Crest |

---

## Price Reference

Combined price table across all equipment categories. Forged items
have no gold price — they cost materials + a forging fee (300–500g).

| Tier | Weapons | Head Armor | Body Armor (Light) | Body Armor (Heavy) | Robes | Accessories |
|------|---------|------------|--------------------|--------------------|-------|-------------|
| 0 | Free | Free | Free | — | — | — |
| 1 | 250–600 | 200–350 | 300–500 | 400 | 300 | 300–500 |
| 2 | 800–2,500 | 800–1,200 | 1,200–1,800 | 1,000–2,000 | 1,200 | 500–800 |
| 3 | 2,000–5,000 | 2,500–3,000 | 3,200–3,500 | 4,500 | — | 1,500–3,000 |
| 4 | 4,000–10,000 | 5,000–6,500 | 7,000–8,000 | 8,000–9,000 | 7,500 | 3,000–5,000 |
| 5 | Not sold | Not sold | Not sold | Not sold | Not sold | Not sold |
| Forged | — (Forged) | — (Forged) | — (Forged) | — | — (Forged) | — |

---

## Cross-Reference Tables

### Boss Equipment Drops

All 18 boss-dropped equipment pieces cross-referenced with the
bestiary. Boss names match `docs/story/bestiary/bosses.md` exactly.

| Item | Slot | Boss | Act | Bestiary File |
|------|------|------|-----|---------------|
| Colossus Shard | Accessory | Ley Colossus | II | bosses.md |
| Drayce's Failsafe Core | Accessory | Forge Warden | II | bosses.md |
| Warden's Binding | Accessory | Undying Warden | Int | bosses.md |
| Kole's Epaulettes | Armor (Heavy) | General Kole | Int | bosses.md |
| Crown Shard | Accessory | Crowned Hollow | III | bosses.md |
| Unfinished Ring | Accessory | Perfect Machine | III | bosses.md |
| Ashen Scholar's Tome | Accessory | Vaelith | III | bosses.md / act-iii.md |
| Titan's Core | Accessory | Ley Titan | III | bosses.md |
| Nexus Crest | Accessory | Wellspring Guardian | III | bosses.md |
| Architect's Hammer | Weapon (Lira) | The Architect | III | bosses.md |
| Grey Cleaver | Weapon (Torren) | Grey Cleaver Unbound | III | bosses.md |
| Cael's Knight Crest | Accessory | Cael Phase 1 | III | bosses.md |
| Cael's Memory | Accessory | Pallor Echo | III | bosses.md |
| Scholar's Codex | Accessory | First Scholar | Post | bosses.md |
| Queen's Facet | Accessory | Crystal Queen | Post | bosses.md |
| Root Crown | Armor (Head) | Rootking | Post | bosses.md |
| Warden's Core | Accessory | Iron Warden | Post | bosses.md |
| Dreamer's Crest | Accessory | Cael's Echo (non-combat) | Post | optional.md |
