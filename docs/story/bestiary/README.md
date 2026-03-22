# Enemy Bestiary

> **Canonical reference** for all enemy data. Type rules, stat formulas,
> and reward curves defined here govern every enemy in the game.
> Individual enemy stat tables live in the per-act files listed below.

## Index

| File | Contents |
|------|----------|
| [act-i.md](act-i.md) | Ember Vein, Fenmother's Hollow, Overworld Act I (25 enemies) |
| [act-ii.md](act-ii.md) | Valdris Siege, Ley Line Depths, Overworld Act II (TBD) |
| [interlude.md](interlude.md) | Rail Tunnels, Axis Tower, City Dungeons (TBD) |
| [act-iii.md](act-iii.md) | Pallor Wastes, Convergence (TBD) |
| [optional.md](optional.md) | Sidequests, Superbosses, Rare Encounters (TBD) |
| [bosses.md](bosses.md) | All Bosses & Mini-Bosses with AI Scripts (TBD) |
| [palette-families.md](palette-families.md) | Base -> Variant Mappings |

---

## Stat Template (19 Columns)

Each enemy in the bestiary tables uses these columns:

| Column | Type | Description |
|--------|------|-------------|
| Name | string | Unique name. Palette swaps get distinct names |
| Type | enum | Beast, Undead, Construct, Spirit, Humanoid, Pallor, Elemental, Boss |
| Lv | int | Enemy level (1-150). Affects status hit rate per combat-formulas.md |
| HP | int | Hit points. Regular: 6-42,320. Bosses: 6,000-70,000 |
| MP | int | Magic points. 0 for physical-only enemies |
| ATK | int | Physical attack (1-255) |
| DEF | int | Physical defense (1-255) |
| MAG | int | Magic power (1-255) |
| MDEF | int | Magic defense (1-255) |
| SPD | int | Speed (1-255). ATB fill rate per combat-formulas.md |
| Gold | int | Currency dropped. Bounded growth, cap 10,000 |
| Exp | int | Experience awarded. Bounded growth, cap 30,000 |
| Steal | string | Sable's Tricks. "Item (75%)", "Item (100%)", or "-" |
| Drop | string | Defeat drop. "Item (25%)", "Item (100%)", or "-" |
| Weak | string | Elements dealing 1.5x damage. Comma-separated or "-" |
| Resists | string | Elements dealing 0.75x damage (elemental disadvantage per combat-formulas.md). Comma-separated or "-" |
| Absorbs | string | Elements that heal. Comma-separated or "-" |
| Status Immunities | string | Immune statuses. Comma-separated or "-" |
| Location(s) | string | Where enemy appears. Comma-separated areas |

---

## Enemy Type Rules

8 types with codified gameplay effects enforced by the combat engine.

### Beast

- **Inherent traits:** None
- **Default immunities:** --
- **Interactions:**
  - Sable's Tricks: steal rate +25%
  - Torren's Spiritcall: can calm non-hostile beasts (guaranteed flee)

### Undead

- **Inherent traits:** Healing spells deal damage. Revival items deal
  max damage (instant kill)
- **Default immunities:** Poison, Death
- **Interactions:**
  - Spirit element deals 1.5x (stacks with weakness)
  - Drain effects reversed (drains caster instead of target)

### Construct

- **Inherent traits:** Cannot bleed. No MP (always 0)
- **Default immunities:** Poison, Sleep, Confusion, Berserk, Despair
- **Interactions:**
  - Storm deals 1.25x (additional type multiplier, stacks with weakness)
  - Lira's Forgewright: bonus damage +25%

### Spirit

- **Inherent traits:** Physical damage reduced 50% (applied before DEF)
- **Default immunities:** Poison, Petrify
- **Interactions:**
  - Ley element deals 1.5x (stacks with weakness)
  - Torren's Spiritcall: reveals hidden weakness for 3 turns

### Humanoid

- **Inherent traits:** Standard vulnerability to all statuses
- **Default immunities:** --
- **Interactions:**
  - Steal loot table +1 tier (better items than other types)
  - Can be Confused to attack allies (full friendly-fire)

### Pallor

- **Inherent traits:** Regenerates 2% max HP per turn while any party
  member has Despair status
- **Default immunities:** Despair, Death
- **Interactions:**
  - Spirit element deals 1.25x (additional type multiplier, stacks with weakness)
  - Maren's Pallor Sight: cancels regen for 3 turns

### Elemental

- **Inherent traits:** Absorbs own element (inherent, in addition to
  any listed in Absorbs column)
- **Default immunities:** Petrify
- **Interactions:**
  - Counter-element deals 1.5x (stacks with weakness)
  - Killing with absorbed element heals enemy to 25% HP instead

### Boss

- **Inherent traits:** Cannot be removed from battle
- **Default immunities:** Death, Petrify, Stop, Sleep, Confusion (can
  be overridden per individual boss in the boss stat sheet)
- **Interactions:**
  - Phase transition immunity: cannot be killed during phase-change
    animations. Overkill damage is discarded at phase boundaries.

### Stacking Rule

All type elemental bonuses (1.25x or 1.5x) are additional multipliers
that stack multiplicatively with the elemental weakness/resistance from
the enemy's Weak/Resists columns.

Examples:
- Spirit-type enemy weak to Ley: 1.5x (type) x 1.5x (weakness) = 2.25x
- Construct hit by Storm (no weakness listed): 1.25x (type) x 1.0x = 1.25x
- Construct weak to Storm: 1.25x (type) x 1.5x (weakness) = 1.875x

### Single-Type Rule

Enemies have exactly one type. No dual-typing. Avoids ambiguous stacking
and keeps the system simple (FF6's approach).

---

## Stat Scaling Formulas

### Level Ranges by Act

| Act | Enemy Level Range | Recommended Party Level |
|-----|------------------|------------------------|
| Act I | 1-12 | 1-12 |
| Act II | 13-25 | 13-25 |
| Interlude | 20-35 | 20-35 |
| Act III | 30-45 | 30-45 |
| Post-game | 40-80 | 40-80 |
| Optional / Superboss | 70-150 | 70-150 |

### Base Stat Curves (Regular Enemies)

All core stats derived from enemy level. Individual enemies may be
tuned +/-15% from these baselines.

```
HP   = floor(level^2 x 1.8 + level x 12 + 20)
MP   = floor(level x 3.5)                        # 0 for physical-only
ATK  = floor(level x 1.6 + 8)
DEF  = floor(level x 1.2 + 5)
MAG  = floor(level x 1.4 + 6)
MDEF = floor(level x 1.0 + 4)
SPD  = floor(level x 0.8 + 8)
```

**Enemy LCK:** Enemies do not have a LCK stat. Enemy critical hits use
a fixed 5% rate (not the player's `LCK / 4` formula). Enemy evasion
uses `SPD / 4` per the standard derived stat rules in progression.md.
This keeps the stat template at 19 columns and avoids inflating enemy
data with a stat that rarely matters offensively for monsters.

### Verification Table

| Lv | HP | ATK | DEF | MAG | MDEF | SPD | Context |
|----|-----|-----|-----|-----|------|-----|---------|
| 1 | 33 | 9 | 6 | 7 | 5 | 8 | Ember Vein -- 2-3 hits to kill |
| 5 | 125 | 16 | 11 | 13 | 9 | 12 | Ember Vein floor 2 |
| 10 | 320 | 24 | 17 | 20 | 14 | 16 | Fenmother adds |
| 20 | 980 | 40 | 29 | 34 | 24 | 24 | Interlude regulars |
| 35 | 2,645 | 64 | 47 | 55 | 39 | 36 | Act III |
| 50 | 5,120 | 88 | 65 | 76 | 54 | 48 | Post-game |
| 70 | 9,680 | 120 | 89 | 104 | 74 | 64 | High optional |
| 100 | 19,220 | 168 | 125 | 146 | 104 | 88 | Deep optional |
| 150 | 42,320 | 248 | 185 | 216 | 154 | 128 | Superboss-tier |

### Boss Stat Multipliers

Bosses use the regular curve x multipliers. HP is hand-tuned per boss
to match values already established in dungeons-world.md.

| Stat | Multiplier | Rationale |
|------|-----------|-----------|
| HP | x15-25 (hand-tuned) | Fight length target: 3-5 minutes |
| ATK | x1.5 | Boss hits harder than regulars |
| DEF | x1.3 | Tankier but not impenetrable |
| MAG | x1.8 | Boss spells feel dangerous |
| MDEF | x1.5 | Cannot simply nuke with magic |
| SPD | x1.2 | Slightly faster, more pressure |

---

## Reward Formulas (Bounded Growth)

Gold and Exp use the logistic growth function:

```
f(level) = floor(cap / (1 + a x e^(-b x level)))
```

This produces an S-curve: slow start, steep mid-game growth, asymptotic
approach to the cap. This models natural reward pacing -- early enemies
give modest rewards, mid-game is the steepest growth zone, and endgame
rewards plateau near the cap.

### Base Gold

```
base_gold(level) = floor(10000 / (1 + 824 x e^(-0.0754 x level)))
```

| Lv | Base Gold |
|----|-----------|
| 1 | 13 |
| 5 | 17 |
| 10 | 25 |
| 25 | 79 |
| 50 | 500 |
| 75 | 2,574 |
| 100 | 6,954 |
| 150 | 9,900 |

Cap: **10,000 gold** (hard ceiling regardless of multiplier).

### Base Exp

```
base_exp(level) = floor(30000 / (1 + 1188 x e^(-0.0696 x level)))
```

| Lv | Base Exp |
|----|----------|
| 1 | 27 |
| 5 | 35 |
| 10 | 50 |
| 25 | 143 |
| 50 | 797 |
| 75 | 4,040 |
| 100 | 14,100 |
| 150 | 28,992 |

Cap: **30,000 exp** (hard ceiling regardless of multiplier).

### Threat Multiplier

Each enemy has a threat rating that multiplies base rewards. Enemies
of the same level give different rewards based on how dangerous they are.

| Threat | Multiplier | Examples |
|--------|-----------|---------|
| Trivial | x0.15 | Rats, vermin, swarm fodder |
| Low | x0.35 | Common encounter enemies |
| Standard | x0.60 | Typical dungeon enemy (default) |
| Dangerous | x1.0 | Elite enemies, mini-boss-tier |
| Rare | x1.5 | Rare encounters, Tier 4 palette swaps |
| Boss | Hand-tuned | Manual Gold/Exp values per boss |

**Worked Examples:**

- Level 70 rat (Trivial): base_gold(70) = 1,921.
  Gold = floor(1,921 x 0.15) = 288. base_exp(70) = 2,970.
  Exp = floor(2,970 x 0.15) = 445
- Level 70 Pallor Lord (Rare): Gold = floor(1,921 x 1.5) = 2,881.
  Exp = floor(2,970 x 1.5) = 4,455
- Level 150 Pallor Lord (Rare): base_gold(150) = 9,900.
  Gold = floor(9,900 x 1.5) = 14,850 -> capped at 10,000.
  base_exp(150) = 28,992. Exp = floor(28,992 x 1.5) = 43,488
  -> capped at 30,000

---

## Palette-Swap Family System

### Family Tiers

Each family has 2-4 tiers. Higher tiers use the stat formulas at their
own level, with role adjustments and ability/element additions.

| Tier | Level | How Stats Are Derived |
|------|-------|----------------------|
| 1 | 1-12 | Base formulas at tier level |
| 2 | 10-25 | Base formulas at tier level, +/-15% role adjustment |
| 3 | 22-40 | Base formulas at tier level, +/-20% role adjustment |
| 4 | 35-80 | Base formulas at tier level, +/-25% role adjustment, possible type change |

| Tier | Name Pattern | Additions |
|------|-------------|-----------|
| Base (Tier 1) | Original name | Base abilities |
| Tier 2 | Environment prefix | +1 ability |
| Tier 3 | Threat prefix | +2 abilities, element shift |
| Tier 4 | Pallor/Elite prefix | +3 abilities, type may change |

### Tier 4 Type Change

Tier 4 variants may change type to Pallor, representing corruption.
When this happens:

- Gains Pallor type immunities (Despair, Death)
- Gains Pallor regen trait (2% HP/turn while party has Despair)
- Loses original type traits
- Element profile shifts: gains Void resist, Spirit weakness
- Drops change to include Pallor crafting materials

### Naming Conventions

| Pattern | When Used | Example |
|---------|-----------|---------|
| Environment prefix | Tier 2 -- geographic variant | Cave Vermin, Marsh Serpent |
| Threat prefix | Tier 3 -- enhanced version | Blight Vermin, Greater Serpent |
| Pallor/Elite prefix | Tier 4 -- corruption variant | Pallor Vermin, Ashen Serpent |
| Descriptor suffix | Rare/mini-boss variant | Vermin Alpha, Serpent Matriarch |

### Example Family: Vermin

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Ley Vermin | 1 | Beast | — | Bite | Trivial |
| 2 | Cave Vermin | 10 | Beast | — | Bite, Rabid Frenzy (2-hit) | Low |
| 3 | Blight Vermin | 24 | Beast | Weak->Spirit | Bite, Rabid Frenzy, Plague Bite (Poison) | Standard |
| 4 | Pallor Vermin | 38 | Pallor | Weak->Spirit, Resist->Void | All above + Despair Screech (AoE Despair) | Dangerous |
