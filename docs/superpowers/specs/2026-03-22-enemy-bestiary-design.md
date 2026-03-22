# Enemy Bestiary Design Spec (Gap 1.3 — Sub-project 1: Foundation + Act I)

**Date:** 2026-03-22
**Status:** Draft
**Scope:** Define the bestiary template, stat scaling formulas, type rules,
palette-swap family system, reward formulas, and populate all Act I enemies.
**Gap:** 1.3 (Enemy Bestiary)
**Depends On:** 1.1 (Damage Formulas — COMPLETE), 1.2 (Stat System — COMPLETE)

---

## 1. Purpose

Define the canonical enemy data format and populate Act I as a proof of
concept. This spec covers:

- Enemy stat template (19 columns)
- 8 enemy type rules with gameplay effects
- Stat scaling formulas (level 1–150)
- Bounded-growth reward formulas (Gold cap 10,000, Exp cap 30,000)
- Palette-swap family system for generating 250–300 enemies from ~70 bases
- Complete Act I roster (29 enemies: 25 regular + 2 mini-bosses + 2 bosses)

Sub-projects 2–4 (Act II/Interlude, Act III/Optional, Boss Compendium)
will follow in separate specs, each using the template and formulas
established here.

## 2. Target Scale

~250–300 total enemies across the full bestiary (FF6 scale). Breakdown:

| Category | Families | Variants per | Total |
|----------|---------|-------------|-------|
| Beasts | 12 | 3–4 | ~42 |
| Undead | 8 | 3–4 | ~28 |
| Constructs | 8 | 3 | ~24 |
| Humanoids | 10 | 3–4 | ~35 |
| Spirits | 8 | 3 | ~24 |
| Pallor | 10 | 2–3 | ~25 |
| Elementals | 8 | 3 | ~24 |
| Unique (no family) | ~30 | 1 | ~30 |
| Bosses / Mini-bosses | ~25 | 1 | ~25 |
| **Total** | | | **~257** |

## 3. Directory Structure

```
docs/story/bestiary/
├── README.md              # Index, type rules, scaling formulas, template
├── act-i.md               # Ember Vein, Fenmother's Hollow, overworld Act I
├── act-ii.md              # Valdris Siege, Ley Line Depths, overworld Act II
├── interlude.md           # Rail Tunnels, Axis Tower, city dungeons
├── act-iii.md             # Pallor Wastes, Convergence, enhanced variants
├── optional.md            # Sidequest enemies, superbosses, rare encounters
├── bosses.md              # All bosses/mini-bosses with AI scripts and phases
└── palette-families.md    # Base → variant mappings with stat multipliers
```

**Cross-references required:** The bestiary README.md must be referenced in:
- `AGENTS.md` — Repository Layout table + Where to Add Code table
- `docs/analysis/game-design-gaps.md` — Gap 1.3 Files field
- `.claude/skills/pod-dev/SKILL.md` — story doc reference list
- `.claude/skills/story-review-loop/agents/canonical-verifier.md` — canonical
  source list (enemies → bestiary README)
- `.claude/skills/story-designer/SKILL.md` — file naming convention list

## 4. Stat Template (19 Columns)

Each enemy in the bestiary tables uses these columns:

| Column | Type | Description |
|--------|------|-------------|
| Name | string | Unique name. Palette swaps get distinct names |
| Type | enum | Beast, Undead, Construct, Spirit, Humanoid, Pallor, Elemental, Boss |
| Lv | int | Enemy level (1–150). Affects status hit rate per combat-formulas.md |
| HP | int | Hit points. Regular: 6–42,320. Bosses: 6,000–70,000 |
| MP | int | Magic points. 0 for physical-only enemies |
| ATK | int | Physical attack (1–255) |
| DEF | int | Physical defense (1–255) |
| MAG | int | Magic power (1–255) |
| MDEF | int | Magic defense (1–255) |
| SPD | int | Speed (1–255). ATB fill rate per combat-formulas.md |
| Gold | int | Currency dropped. Bounded growth, cap 10,000 |
| Exp | int | Experience awarded. Bounded growth, cap 30,000 |
| Steal | string | Sable's Tricks. "Common (75%) / Rare (25%)" or "—" |
| Drop | string | Defeat drop. "Common (75%) / Rare (25%)" or "—" |
| Weak | string | Elements dealing 1.5× damage. Comma-separated or "—" |
| Resists | string | Elements dealing 0.5× damage. Comma-separated or "—" |
| Absorbs | string | Elements that heal. Comma-separated or "—" |
| Status Immunities | string | Immune statuses. Comma-separated or "—" |
| Location(s) | string | Where enemy appears. Comma-separated areas |

## 5. Enemy Type Rules

8 types with codified gameplay effects enforced by the combat engine.

### 5.1 Beast

- **Inherent traits:** None
- **Default immunities:** —
- **Interactions:**
  - Sable's Tricks: steal rate +25%
  - Torren's Spiritcall: can calm non-hostile beasts (guaranteed flee)

### 5.2 Undead

- **Inherent traits:** Healing spells deal damage. Revival items deal
  max damage (instant kill)
- **Default immunities:** Poison, Death
- **Interactions:**
  - Spirit element deals 1.5× (stacks with weakness)
  - Drain effects reversed (drains caster instead of target)

### 5.3 Construct

- **Inherent traits:** Cannot bleed. No MP (always 0)
- **Default immunities:** Poison, Sleep, Confusion, Berserk, Despair
- **Interactions:**
  - Storm deals 1.25× (additional type multiplier, stacks with weakness)
  - Lira's Forgewright: bonus damage +25%

### 5.4 Humanoid

- **Inherent traits:** Standard vulnerability to all statuses
- **Default immunities:** —
- **Interactions:**
  - Steal loot table +1 tier (better items than other types)
  - Can be Confused to attack allies (full friendly-fire)

### 5.5 Spirit

- **Inherent traits:** Physical damage reduced 50% (applied before DEF)
- **Default immunities:** Poison, Petrify
- **Interactions:**
  - Ley element deals 1.5× (stacks with weakness)
  - Torren's Spiritcall: reveals hidden weakness for 3 turns

### 5.6 Pallor

- **Inherent traits:** Regenerates 2% max HP per turn while any party
  member has Despair status
- **Default immunities:** Despair, Death
- **Interactions:**
  - Spirit element deals 1.25× (additional type multiplier, stacks with weakness)
  - Maren's Pallor Sight: cancels regen for 3 turns

### 5.7 Elemental

- **Inherent traits:** Absorbs own element (inherent, in addition to
  any listed in Absorbs column)
- **Default immunities:** Petrify
- **Interactions:**
  - Counter-element deals 1.5× (stacks with weakness)
  - Killing with absorbed element heals enemy to 25% HP instead

### 5.8 Boss

- **Inherent traits:** Cannot be removed from battle
- **Default immunities:** Death, Petrify, Stop, Sleep (can be
  overridden per individual boss in the boss stat sheet)
- **Interactions:**
  - Phase transition immunity: cannot be killed during phase-change
    animations. Overkill damage is discarded at phase boundaries.

### 5.9 Stacking Rule

All type elemental bonuses (1.25× or 1.5×) are additional multipliers
that stack multiplicatively with the elemental weakness/resistance from
the enemy's Weak/Resists columns.

Examples:
- Spirit-type enemy weak to Ley: 1.5× (type) × 1.5× (weakness) = 2.25×
- Construct hit by Storm (no weakness listed): 1.25× (type) × 1.0× = 1.25×
- Construct weak to Storm: 1.25× (type) × 1.5× (weakness) = 1.875×

### 5.10 Single-Type Rule

Enemies have exactly one type. No dual-typing. Avoids ambiguous stacking
and keeps the system simple (FF6's approach).

## 6. Stat Scaling Formulas

### 6.1 Level Ranges by Act

| Act | Enemy Level Range | Recommended Party Level |
|-----|------------------|------------------------|
| Act I | 1–12 | 1–12 |
| Act II | 13–25 | 13–25 |
| Interlude | 20–35 | 20–35 |
| Act III | 30–45 | 30–45 |
| Post-game | 40–80 | 40–80 |
| Optional / Superboss | 70–150 | 70–150 |

### 6.2 Base Stat Curves (Regular Enemies)

All core stats derived from enemy level. Individual enemies may be
tuned ±15% from these baselines.

```
HP   = floor(level² × 1.8 + level × 12 + 20)
MP   = floor(level × 3.5)                        # 0 for physical-only
ATK  = floor(level × 1.6 + 8)
DEF  = floor(level × 1.2 + 5)
MAG  = floor(level × 1.4 + 6)
MDEF = floor(level × 1.0 + 4)
SPD  = floor(level × 0.8 + 8)
```

**Verification table:**

| Lv | HP | ATK | DEF | MAG | MDEF | SPD | Context |
|----|-----|-----|-----|-----|------|-----|---------|
| 1 | 33 | 9 | 6 | 7 | 5 | 8 | Ember Vein — 2–3 hits to kill |
| 5 | 125 | 16 | 11 | 13 | 9 | 12 | Ember Vein floor 2 |
| 10 | 320 | 24 | 17 | 20 | 14 | 16 | Fenmother adds |
| 20 | 980 | 40 | 29 | 34 | 24 | 24 | Interlude regulars |
| 35 | 2,645 | 64 | 47 | 55 | 39 | 36 | Act III |
| 50 | 5,120 | 88 | 65 | 76 | 54 | 48 | Post-game |
| 70 | 9,680 | 120 | 89 | 104 | 74 | 64 | High optional |
| 100 | 19,220 | 168 | 125 | 146 | 104 | 88 | Deep optional |
| 150 | 42,320 | 248 | 185 | 216 | 154 | 128 | Superboss-tier |

**Sanity checks against combat-formulas.md:**

- Edren Lv1 (ATK 18 per progression.md): ATK²/6 - DEF = 54 - 6 = 48
  damage vs Lv1 enemy (33 HP) → 1 hit from the party's strongest
  physical attacker. Maren Lv1 (ATK 6): 6²/6 - 6 = 0 → floor 1
  damage (Maren is a mage, not a physical attacker). Correct.
- Edren Lv35 (ATK ~130 w/gear): ATK²/6 - DEF = 2,816 - 47 = 2,769
  vs Lv35 enemy (2,645 HP) → 1 hit from the best physical attacker.
  Non-Edren party members deal less. Balanced with ±15% tuning.
- SPD 64 at Lv70 matches "Typical Lv70 enemy (SPD 60)" from
  combat-formulas.md pacing table (within ±15% tuning range).
- ATK 248 at Lv150 approaches the 255 stat cap. Correct for endgame.

### 6.3 Boss Stat Multipliers

Bosses use the regular curve × multipliers. HP is hand-tuned per boss
to match values already established in dungeons-world.md.

| Stat | Multiplier | Rationale |
|------|-----------|-----------|
| HP | ×15–25 (hand-tuned) | Fight length target: 3–5 minutes |
| ATK | ×1.5 | Boss hits harder than regulars |
| DEF | ×1.3 | Tankier but not impenetrable |
| MAG | ×1.8 | Boss spells feel dangerous |
| MDEF | ×1.5 | Cannot simply nuke with magic |
| SPD | ×1.2 | Slightly faster, more pressure |

## 7. Reward Formulas (Bounded Growth)

Gold and Exp use the logistic growth function:

```
f(level) = floor(cap / (1 + a × e^(-b × level)))
```

This produces an S-curve: slow start, steep mid-game growth, asymptotic
approach to the cap. This models natural reward pacing — early enemies
give modest rewards, mid-game is the steepest growth zone, and endgame
rewards plateau near the cap.

### 7.1 Base Gold

```
base_gold(level) = floor(10000 / (1 + 824 × e^(-0.0754 × level)))
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

### 7.2 Base Exp

```
base_exp(level) = floor(30000 / (1 + 1188 × e^(-0.0696 × level)))
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

### 7.3 Threat Multiplier

Each enemy has a threat rating that multiplies base rewards. Enemies
of the same level give different rewards based on how dangerous they are.

| Threat | Multiplier | Examples |
|--------|-----------|---------|
| Trivial | ×0.15 | Rats, vermin, swarm fodder |
| Low | ×0.35 | Common encounter enemies |
| Standard | ×0.60 | Typical dungeon enemy (default) |
| Dangerous | ×1.0 | Elite enemies, mini-boss-tier |
| Rare | ×1.5 | Rare encounters, Tier 4 palette swaps |
| Boss | Hand-tuned | Manual Gold/Exp values per boss |

**Examples:**

- Level 70 rat (Trivial): base_gold(70) = 1,921.
  Gold = floor(1,921 × 0.15) = 288. base_exp(70) = 2,970.
  Exp = floor(2,970 × 0.15) = 445
- Level 70 Pallor Lord (Rare): Gold = floor(1,921 × 1.5) = 2,881.
  Exp = floor(2,970 × 1.5) = 4,455
- Level 150 Pallor Lord (Rare): base_gold(150) = 9,900.
  Gold = floor(9,900 × 1.5) = 14,850 → capped at 10,000.
  base_exp(150) = 29,000. Exp = floor(29,000 × 1.5) = 43,500
  → capped at 30,000

## 8. Palette-Swap Family System

### 8.1 Family Tiers

Each family has 2–4 tiers. Higher tiers are generated from the base
using stat multipliers, with additional ability and element changes.

| Tier | Stat Multiplier | Name Pattern | Additions |
|------|----------------|-------------|-----------|
| Base (Tier 1) | ×1.0 | Original name | Base abilities |
| Tier 2 | ×1.8 | Environment prefix | +1 ability |
| Tier 3 | ×3.0 | Threat prefix | +2 abilities, element shift |
| Tier 4 | ×5.0 | Pallor/Elite prefix | +3 abilities, type may change |

**Stat multiplier application:**

```
variant_stat = floor(base_stat_at_variant_level × family_multiplier)
```

The variant's level determines baseline stats via the formulas in
Section 6.2, then the family multiplier adjusts. This prevents
double-dipping (the variant is not "level 1 × 5.0" but rather
"level 35 baseline" adjusted by a smaller modifier for variety).

**Correction:** The family multiplier is a *variance* modifier, not a
raw stat multiplier. It adjusts the baseline ±15-30% for the variant's
role (glass cannon, tank, etc.):

| Tier | Level | How Stats Are Derived |
|------|-------|----------------------|
| 1 | 1–12 | Base formulas at tier level |
| 2 | 10–25 | Base formulas at tier level, ±15% role adjustment |
| 3 | 22–40 | Base formulas at tier level, ±20% role adjustment |
| 4 | 35–80 | Base formulas at tier level, ±25% role adjustment, possible type change |

### 8.2 Tier 4 Type Change

Tier 4 variants may change type to Pallor, representing corruption.
When this happens:

- Gains Pallor type immunities (Despair, Death)
- Gains Pallor regen trait (2% HP/turn while party has Despair)
- Loses original type traits
- Element profile shifts: gains Void resist, Spirit weakness
- Drops change to include Pallor crafting materials

### 8.3 Naming Conventions

| Pattern | When Used | Example |
|---------|-----------|---------|
| Environment prefix | Tier 2 — geographic variant | Cave Vermin, Marsh Serpent |
| Threat prefix | Tier 3 — enhanced version | Blight Vermin, Greater Serpent |
| Pallor/Elite prefix | Tier 4 — corruption variant | Pallor Vermin, Ashen Serpent |
| Descriptor suffix | Rare/mini-boss variant | Vermin Alpha, Serpent Matriarch |

### 8.4 Example Family: Vermin

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Ley Vermin | 1 | Beast | — | Bite | Trivial |
| 2 | Cave Vermin | 10 | Beast | — | Bite, Rabid Frenzy (2-hit) | Low |
| 3 | Blight Vermin | 24 | Beast | Weak→Spirit | Bite, Rabid Frenzy, Plague Bite (Poison) | Standard |
| 4 | Pallor Vermin | 38 | Pallor | Weak→Spirit, Resist→Void | All above + Despair Screech (AoE Despair) | Dangerous |

## 9. Act I Enemy Roster

25 total entries: 20 regular + 1 unique + 2 mini-bosses + 2 bosses.
Covers 6 of 8 types (Beast, Undead, Construct, Spirit, Elemental,
Humanoid). Pallor enemies appear in later acts when narratively
appropriate.

### 9.1 Ember Vein (Floors 1–4)

| Name | Family | Tier | Lv | Type | Threat | Teaching Role |
|------|--------|------|----|------|--------|--------------|
| Ley Vermin | Vermin | 1 | 1 | Beast | Trivial | Basic attack tutorial |
| Tomb Mite | Mite | 1 | 2 | Beast | Trivial | Swarm enemy (groups of 3–4) |
| Restless Dead | Dead | 1 | 3 | Undead | Trivial | Undead rules — heal to damage |
| Unstable Crystal | Crystal | 1 | 3 | Elemental | Low | AoE on death — teaches positioning |
| Mine Shade | Shade | 1 | 4 | Spirit | Low | Physical 50% reduced — teaches magic |
| Bone Warden | Warden | 1 | 4 | Undead | Low | Tougher undead, blocks path |
| Ember Wisp | Wisp | 1 | 5 | Elemental | Low | Weak to Frost — teaches elements |
| The Flickering | — (unique) | — | 6 | Spirit | Dangerous | Phases solid/intangible — teaches timing |
| *Ember Drake* | Drake | 1 | 8 | Beast | Dangerous | **Mini-boss** — full-party coordination |
| *Vein Guardian* | — | — | 12 | Boss | Boss | **Boss** — two-phase construct |

### 9.2 Fenmother's Hollow (Floors 1–3 + Cleansing)

> **Act boundary note:** dungeons-world.md classifies Fenmother's Hollow
> as Act II (recommended level 12–15). It is included in the Act I
> bestiary file because (1) the party reaches it at the end of Act I
> progression, (2) its enemies share the Act I level range (6–12), and
> (3) the boss fight is the Act I climax. The act-i.md file covers the
> "first playthrough arc" — everything before the Valdris diplomatic
> missions. The Corrupted Fenmother boss (Lv 12) sits at the Act I cap.

| Name | Family | Tier | Lv | Type | Threat | Teaching Role |
|------|--------|------|----|------|--------|--------------|
| Marsh Serpent | Serpent | 1 | 6 | Beast | Low | Fast + Poison — teaches status curing |
| Bog Leech | Leech | 1 | 7 | Beast | Low | HP drain — teaches drain mechanics |
| Drowned Bones | Dead | 2 | 7 | Undead | Low | Palette swap of Restless Dead |
| Swamp Lurker | Lurker | 1 | 8 | Beast | Standard | High DEF ambusher — back attacks |
| Ley Jellyfish | Jellyfish | 1 | 8 | Elemental | Standard | Paralysis — teaches status priority |
| Polluted Elemental | Elemental | 1 | 9 | Elemental | Standard | Frost AoE — elemental resistance |
| Corrupted Spawn | Serpent | 2 | 10 | Beast | Standard | Fast, targets backline |
| *Drowned Sentinel* | — | — | 10 | Construct | Dangerous | **Mini-boss** — stone guardian |
| *Corrupted Fenmother* | — | — | 12 | Boss | Boss | **Boss** — multi-phase, non-lethal |

### 9.3 Overworld Act I

| Name | Family | Tier | Lv | Type | Threat | Teaching Role |
|------|--------|------|----|------|--------|--------------|
| Plains Hare | Hare | 1 | 1 | Beast | Trivial | Grassland fodder |
| Thornback Beetle | Beetle | 1 | 3 | Beast | Low | Forest encounters |
| Road Bandit | Bandit | 1 | 4 | Humanoid | Low | Steal-from tutorial |
| Forest Sprite | Sprite | 1 | 4 | Spirit | Low | Woodland spirit — physical resistant |
| Wild Boar | Boar | 1 | 5 | Beast | Standard | High ATK, low DEF — teaches defense |
| Wayward Wolf | Wolf | 1 | 6 | Beast | Standard | Pack enemy (groups of 2–3) |

### 9.4 Act I Summary

- **Type coverage:** Beast (11), Undead (3), Construct (1), Spirit (3),
  Elemental (4), Humanoid (1), Boss (2) — total 25
- **Threat spread:** Trivial (4), Low (10), Standard (6), Dangerous (3),
  Boss (2) — total 25
- **Level range:** 1–12
- **Families started:** Vermin, Mite, Dead, Crystal, Shade, Warden,
  Wisp, Drake, Serpent, Leech, Lurker, Jellyfish, Elemental, Hare,
  Beetle, Bandit, Sprite, Boar, Wolf (19 families)
- **Unique:** The Flickering (1)

## 10. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/README.md` | Create | Template, type rules, scaling formulas, index |
| `docs/story/bestiary/act-i.md` | Create | Act I enemy stat tables (25 entries) |
| `docs/story/bestiary/palette-families.md` | Create | Family definitions (Act I families only, others TBD) |
| `docs/analysis/game-design-gaps.md` | Modify | Gap 1.3 status MISSING → PARTIAL |
| `AGENTS.md` | Modify | Add bestiary to Repository Layout + Where to Add Code |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add bestiary README reference |
| `.claude/skills/story-designer/SKILL.md` | Modify | Add bestiary to file naming convention |
| `.claude/skills/story-review-loop/agents/canonical-verifier.md` | Modify | Add enemies canonical source |

## 11. Out of Scope

- Act II, Interlude, Act III, Optional enemies (Sub-projects 2–3)
- Boss AI behavior scripts and phase details (Sub-project 4)
- Drop table item references (blocked by Gap 1.4 Items)
- XP-to-level curve integration (blocked by Gap 2.1)
- Encounter rate tables (blocked by Gap 2.4)
- Steal item details beyond placeholder names (blocked by Gap 1.4)

## 12. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scale target | 250–300 enemies | FF6 (362) is the reference; our world is smaller but comparable |
| Directory structure | `docs/story/bestiary/` subdirectory | Files would be unmanageably large as a single doc |
| Type count | 8 types | Each type meaningfully changes combat. Fewer than FF6's 12 but all are load-bearing |
| Single-type rule | No dual-typing | Avoids ambiguous stacking, keeps system simple |
| Reward model | Logistic (bounded growth) | S-curve matches natural progression feel. Caps prevent inflation |
| Gold cap | 10,000 | Rare Lv150 enemies at the ceiling |
| Exp cap | 30,000 | Prevents trivial power-leveling at endgame |
| Threat multiplier | 6 tiers (Trivial→Boss) | Same-level enemies give different rewards based on danger |
| Palette-swap tiers | 4 tiers per family | Generates ~3–4 variants from each base; Tier 4 may change type to Pallor |
| Stat tuning range | ±15% from formula baseline | Enough variance for role differentiation without breaking scaling |
| Act I roster | 29 enemies (25 + 1 unique + 2 mini + 2 boss) | Covers 6 of 8 types, all threat tiers, teaches core mechanics |
