# Damage & Combat Formulas Design Spec

**Date:** 2026-03-21
**Status:** Draft
**Scope:** New file `docs/story/combat-formulas.md` — physical damage,
magical damage, healing, critical hits, ability multipliers, elemental
interactions, status accuracy, combat synergies, boss HP scaling, and
multi-hit rules. Also updates to `docs/story/magic.md` (replace placeholder
formulas), `docs/story/dungeons-world.md` (boss HP values), and
`docs/analysis/game-design-gaps.md` (gap 1.1 status).
**Gap:** 1.1 (Damage & Combat Formulas)
**Depends On:** 1.2 (Stat System) — COMPLETE

---

## 1. Purpose

Define every formula the combat engine needs to resolve damage, healing,
status effects, and special interactions. This spec is the bridge between
the stat system (Gap 1.2) and the bestiary (Gap 1.3): stats feed into
these formulas, and enemy design is balanced against them.

## 2. Design Principles

1. **Damage cap mirrors HP cap (14,999).** The maximum damage any single
   hit can deal equals the maximum HP any character can have. Hitting cap
   requires perfect setup — best spell, elemental weakness, buffs stacked.
   This creates the FF6 "9,999" eye-candy moment scaled to our system.
2. **Physical = reliable, Magic = burst.** Physical attackers deal steady
   5,000–7,000 damage at endgame with basic attacks; their skills can
   approach or hit cap. Mages need elemental advantage + buffs to reach
   cap — rewarding setup play.
3. **Quadratic physical scaling.** Physical damage uses ATK² so that each
   point of ATK is increasingly valuable. Upgrading from ATK 170 to 180
   is a bigger damage jump than 18 to 28, which makes late-game gear
   feel impactful.
4. **Subtractive defense with floor of 1.** DEF/MDEF directly reduce
   damage. Damage can never go below 1 — weak enemies tickle you for
   1 damage, showing you've outgrown them. Classic SNES feel.
5. **FF6-style variance (±6.25%).** Tight enough to plan around, loose
   enough to create drama. A low roll on a killing blow means the enemy
   survives with a sliver — these moments make combat memorable.
6. **FF6-scale boss gauntlet.** The final battle (Cael phases + Pallor
   Incarnate) totals ~150,000 HP, creating a 20–30 minute climactic
   gauntlet. Regular bosses are 3–5 minute fights.
7. **Three tiers of combat interactions.** Designed emergent gameplay
   that rewards experimentation: telegraphed (NPC hints), experimental
   (logical deduction), and hidden (community discovery). The
   Vanish-Doom spirit without the Vanish-Doom brokenness.

## 3. Core Damage Formulas

### 3.1 Physical Damage

```
raw = max(1, (ATK² × ability_mult) / 6 - target.DEF)
final = min(14999, raw × variance)
```

- **ATK** includes all sources: base stat + equipment + buff modifiers.
  Buffs like Rallying Cry (+30% ATK) modify the ATK value before it
  enters the formula (before squaring).
- **ability_mult** is 1.0 for a basic attack. Skills use higher values
  (see Section 5).
- **target.DEF** includes equipment and buff/debuff modifiers. Debuffs
  like Defray (-30% DEF) reduce DEF before subtraction.
- **variance** is applied last, before the cap (see Section 4).

**Why ATK²?** ATK ranges 1–255. Linear ATK minus DEF produces a maximum
of ~175 damage at endgame — far too low. Squaring ATK gives a natural
200× damage range from level 1 to cap (18² = 324 vs 255² = 65,025),
producing the 5,000–7,000 basic attack range at endgame that matches
the FF6 physical damage feel.

**Why divisor 6?** Tuned to produce these milestone values:

| Scenario | ATK | Mult | DEF | Damage | Notes |
|----------|-----|------|-----|--------|-------|
| Edren Lv1 vs tutorial mob | 18 | 1.0 | 5 | ~49 | 2–3 hits on 100–150 HP mob |
| Edren Lv18 vs Act I mob | 49 | 1.0 | 15 | ~385 | 2–3 hits on 800 HP mob |
| Edren Lv35 vs Act II mob | 85 | 1.0 | 30 | ~1,174 | 2–3 hits on 2,500 HP mob |
| Edren Lv70 vs Act III (good gear) | 175 | 1.0 | 60 | ~5,044 | In the 5–7K target range |
| Edren Lv70 Riposte (1.5×) | 175 | 1.5 | 60 | ~7,596 | Strong skill hit |
| Edren Lv70 Oathkeeper (1.5×, 2 hits) | 175 | 1.5 | 60 | 7,596 × 2 | Capped turn total |
| Sable Lv70 Shiv (DEF halved) | 150 | 1.0 | 30 | ~3,720 | DEF-shredding thief |
| Edren Lv150 basic | 255 | 1.0 | 80 | ~10,757 | Post-game power fantasy |
| Edren Lv150 Oathkeeper (1.5×) | 255 | 1.5 | 80 | 14,999 | Hits cap with best skill |
| Any Lv150 2.0× technique | 255 | 2.0 | 60 | 14,999 | Bum Rush equivalent |

### 3.2 Magic Damage

```
raw = max(1, (MAG × spell_power) / 4 - target.MDEF)
final = min(14999, raw × element_mod × variance)
```

- **MAG** includes all sources. Attunement (+30% MAG) modifies MAG
  before the formula.
- **spell_power** is defined per spell in magic.md (Tier 1: 12–20,
  Tier 2: 28–40, Tier 3: 50–70, Tier 4: 85–120).
- **element_mod** is applied after the base calculation (see Section 6).
- **target.MDEF** includes equipment and debuff modifiers.

**Why divisor 4?** Tuned to produce these milestone values:

| Scenario | MAG | Power | MDEF | Base | Element (1.5×) | Notes |
|----------|-----|-------|------|------|----------------|-------|
| Maren Lv1 Ember Lance (T1) | 22 | 14 | 8 | ~69 | ~104 | Good opening |
| Maren Lv18 Kindlepyre (T2) | 53 | 32 | 20 | ~404 | ~606 | Solid mid-game |
| Maren Lv70 Crucible Wrath (T3) | 146 | 58 | 60 | ~2,057 | ~3,086 | Heavy hitter |
| Maren Lv150 Ley Ruin (T4) | 255 | 100 | 80 | ~6,295 | ~9,443 | Approaching cap |
| Maren Lv150 Ley Ruin + Attunement | 332* | 100 | 80 | ~8,220 | ~12,330 | Near cap |
| Maren Lv150 + Attune + Resonance | — | — | — | — | ~14,769 | Grazes cap |

*Attunement pushes MAG past 255 temporarily in combat (buffs can exceed
cap per progression.md rules).

**Reaching the 14,999 cap requires:** Best spell + elemental weakness +
ATK/MAG buff + ally combo (Resonance). This is the "perfect setup"
moment — rare, earned, and spectacular.

### 3.3 Healing

```
raw = (MAG × spell_power × 0.8)
final = min(14999, raw × variance)
```

- No defense subtraction — healing is not resisted.
- No floor of 1 needed — inputs are always positive.
- The 0.8 multiplier ensures healing is ~80% of equivalent-tier
  damage output, preventing heal-tanking (out-healing all incoming
  damage at equivalent spell tiers).

### 3.4 Damage Cap

**14,999** — applies to all damage types (physical, magical, healing).
Each individual hit is capped independently. Multi-hit abilities can
exceed 14,999 total per turn (e.g., Oathkeeper's 2 hits can deal
up to 29,998 in one turn).

### 3.5 Damage Floor

**1** — physical and magical damage can never deal less than 1. This
applies after all calculations including variance. A level 150 Edren
taking a hit from a level 1 Restless Dead still sees "1" — satisfying
proof of growth.

## 4. Damage Variance

```
variance = random_int(240, 255) / 256
```

- Range: 0.9375 to 0.99609375 (approximately ±6.25%)
- Applied as a final multiplier before capping
- Each hit rolls independently (multi-hit abilities get separate rolls)
- Healing also uses variance (potions and spells fluctuate slightly)

This is FF6's exact variance formula. Tight enough that players can
estimate "I need about 3 hits to kill this," loose enough that
occasionally a low roll lets an enemy survive with a sliver of HP —
creating a dramatic moment.

## 5. Critical Hits & Ability Multipliers

### 5.1 Critical Hits

```
critical_damage = raw_damage × 2
```

- Applied before variance and cap
- Uses the existing Critical% formula: `LCK / 4` (cap 50%)
- Only physical attacks and physical abilities can crit (magic cannot)
- Sable (highest LCK growth) crits most often — fits her glass cannon
  identity

At Lv70, Edren's basic attack (raw ~5,000) crits for ~10,000. Sable
with her high crit rate produces a satisfying stream of critical Shiv
hits that spike through armor.

### 5.2 Physical Ability Multipliers

The `ability_mult` value in the physical formula. Basic attack = 1.0:

| Mult | Tier | Examples | Lv70 Damage (ATK 175, DEF 60) |
|------|------|---------|-------------------------------|
| 1.0 | Basic attack | Attack command | ~5,044 |
| 1.25 | Standard skill | Shiv, Press Forward target | ~6,336 |
| 1.5 | Strong skill | Riposte, Overcharge | ~7,596 |
| 2.0 | Ultimate skill | Oathkeeper hits, Shatter Guard | ~10,118 |
| 2.5 | Combo/ultimate | Ley Torrent, Edren+Sable combo | ~12,639 |
| 3.0 | Maximum | Annulment (100 WG), once-per-battle | 14,999 (capped) |

The 3.0 tier is reserved for abilities with extreme costs:
- Maren's Annulment (100 Weave Gauge — full meter)
- Torren's Convergence Chorus (once per battle)
- Combo ultimates requiring specific party + setup

These are "Bum Rush" moments — the payoff for mastering the system.

### 5.3 Special Multiplier: Shiv (DEF Ignore)

Sable's Shiv halves target DEF before the formula:
`DEF_effective = target.DEF / 2`

Combined with a 1.25 ability multiplier, Shiv lets Sable shred armored
targets that physical fighters chip away at. Against a DEF 100 boss:
- Edren basic: ~5,700
- Sable Shiv: ~4,500

Comparable damage through different means (raw power vs penetration).

### 5.4 Buff Interaction Points

Buffs modify stats before they enter formulas, not damage output:

| Buff | Modifies | Formula Impact |
|------|----------|---------------|
| Rallying Cry (+30% ATK) | ATK stat | ATK² uses buffed value |
| Attunement (+30% MAG) | MAG stat | MAG × power uses buffed value |
| Ironhide (+40% DEF) | DEF stat | Target DEF in subtraction |
| Defray (-30% DEF) | DEF stat | Target DEF in subtraction |
| Glintmark (+10% dmg taken) | Final damage | Multiplied after variance |
| Resonance (+30% spell) | Spell output | Multiplied after base calc |

Buffs that modify stats can push them past 255 temporarily in combat
(per progression.md rules). This is intentional — it's the pathway
for mages to reach the damage cap.

## 6. Elemental System

### 6.1 Elemental Damage Modifiers

Applied after the base magic damage calculation (or physical damage
if the attack has an elemental property):

| Interaction | Multiplier | Example |
|------------|-----------|---------|
| Elemental weakness | 1.5× | Flame vs Earth enemy |
| Neutral | 1.0× | Flame vs Storm enemy |
| Elemental resistance | 0.5× | Flame vs Frost enemy |
| Same-element | 0.5× | Flame vs Flame enemy |
| Immunity | 0.0× | Void vs Void enemy |
| Absorb | -1.0× | Heals target for damage amount |

Element matchup table (from magic.md):

| Element | Strong vs (1.5×) | Weak vs (0.75×) |
|---------|-------------------|------------------|
| Flame | Earth | Frost |
| Frost | Storm | Flame |
| Storm | Flame | Earth |
| Earth | Frost | Storm |
| Ley | Void | Spirit |
| Spirit | Ley | Void |
| Void | Spirit | Ley |
| Non-elemental | — (1.0× to all) | — (1.0× to all) |

### 6.2 Physical Elemental Attacks

Some weapons and abilities have elemental properties:
- Lira's Arc Trap: Flame element
- Lira's Overcharge: Storm element
- Elemental weapons (defined in equipment, Gap 1.5)

When a physical attack has an element, the elemental multiplier applies
to the physical damage output. This gives Lira's engineering abilities
real tactical value against elementally-weak enemies.

## 7. Status Effect Accuracy

### 7.1 Two-Stage Resolution

Already defined in progression.md and magic.md, consolidated here:

```
Stage 1: effective_rate = base_rate × (caster.MAG / (caster.MAG + target.MDEF))
Stage 2: if Stage 1 succeeds, target rolls Magic Evasion% to resist
```

Where progression.md supersedes magic.md for combat resolution details.

### 7.2 Status Accuracy at Key Points

| Scenario | Base | MAG | MDEF | Stage 1 | MEVA% | Final |
|----------|------|-----|------|---------|-------|-------|
| Maren Lv18 Poison (75%) vs Act I | 75% | 53 | 15 | 58% | ~8% | ~53% |
| Maren Lv70 Sleep (70%) vs Act III | 70% | 146 | 60 | 50% | ~15% | ~42% |
| Maren Lv70 Petrify (50%) vs boss | 50% | 146 | 80 | 32% | ~18% | ~26% |

Status effects devastate regular enemies but are unreliable against
bosses with high MDEF. This prevents cheese strategies while keeping
statuses valuable in standard encounters.

### 7.3 Boss Status Immunities

Defined per-boss in the bestiary (Gap 1.3). Standard patterns:

| Category | Immune To | Vulnerable To |
|----------|----------|---------------|
| Most bosses | Petrify, Stop, Sleep, Confusion | Poison, Slow, Despair (hard to land) |
| Caster bosses | — (not immune to Silence) | Silence (tactical opening) |
| Pallor bosses | Poison (undead-adjacent) | Despair (thematic irony) |
| Final boss | Everything except Despair | Despair only (you cannot escape Despair) |

## 8. Combat Resolution Order

### 8.1 Physical Attack Resolution

1. **Hit Rate% roll** — `90 + (attacker.SPD - target.SPD) / 4`,
   clamped to [20%, 99%]. Miss = 0 damage, stop.
2. **Evasion% roll** — `target.SPD / 4`, cap 50%. Dodged = 0 damage,
   stop.
3. **Calculate base damage** — `(ATK² × ability_mult) / 6 - target.DEF`
4. **Floor check** — `max(1, base_damage)`
5. **Critical% roll** — `attacker.LCK / 4`, cap 50%. If crit: × 2.
6. **Apply combat interaction modifiers** (Frozen Shatter, Glintmark, etc.)
7. **Apply variance** — `× random_int(240, 255) / 256`
8. **Clamp** — `min(14999, result)`

### 8.2 Magic Damage Resolution

1. **Calculate base damage** — `(MAG × spell_power) / 4 - target.MDEF`
2. **Floor check** — `max(1, base_damage)`
3. **Apply elemental modifier** (1.5×, 1.0×, 0.5×, 0.0×, or -1.0×)
4. **Apply combat interaction modifiers** (Conductive Water, etc.)
5. **Apply buff modifiers** (Resonance, Glintmark)
6. **Apply variance** — `× random_int(240, 255) / 256`
7. **Clamp** — `min(14999, result)`

Magic damage spells also use the standard physical hit/evasion
resolution (per progression.md: "damage spells follow the standard
three-stage Hit Rate% / Evasion% / Critical% resolution"). Critical
hits do NOT apply to magic damage — only the hit/evasion check.

### 8.3 Status Spell Resolution

1. **Stage 1** — `effective_rate = base_rate × (MAG / (MAG + target.MDEF))`
2. **Roll vs effective_rate** — fail = status not applied, stop.
3. **Stage 2** — target rolls Magic Evasion% (`(MDEF + SPD) / 8`,
   cap 40%). Resist = status not applied.
4. **Check immunity list** — if target is immune, status not applied.
5. **Apply status** with defined duration.

### 8.4 Healing Resolution

1. **Calculate base heal** — `MAG × spell_power × 0.8`
2. **Apply variance** — `× random_int(240, 255) / 256`
3. **Clamp** — `min(14999, result)`

No hit/miss check. No defense. Healing always lands.

## 9. Combat Interactions & Hidden Synergies

### 9.1 Interaction Tier System

| Tier | Name | Discovery | Player % | Count |
|------|------|-----------|----------|-------|
| 1 | Telegraphed | NPC hints, visual cues | ~70% | 8–10 |
| 2 | Experimental | Logical experimentation | ~25% | 6–8 |
| 3 | Hidden | Community discovery | ~5% | 3–4 |

**Design principles:**
- Every interaction is intentional and balanced — powerful, not
  game-breaking
- Tier 1 teaches players the system exists
- Tier 2 rewards players who internalize that lesson
- Tier 3 creates community moments and replayability
- No interaction is required to progress — shortcuts, not keys

### 9.2 Tier 1: Telegraphed Interactions

| Interaction | Setup | Effect | Hint |
|-------------|-------|--------|------|
| Grounded | Storm spell vs flying enemy | 2.0× damage + Grounded status (lose evasion bonus, ATB -25%, 3 turns) | NPC: "Canyon hawks won't fly in a storm" |
| Shattered Armor | Lira's Overcharge (Storm) vs armored/mechanical | Strips 50% DEF, 3 turns | Lira: "That plating is conductive..." |
| Frozen Shatter | Physical attack vs Frozen enemy | 1.5× damage, bypasses DEF, removes Frozen | Visual: frozen enemies crack when hit |
| Spirit Banish | Torren's Greyveil vs undead | Instant kill on undead below 25% HP | Ability desc: "boundary grows thin" |

### 9.3 Tier 2: Experimental Interactions

| Interaction | Setup | Effect | Subtext |
|-------------|-------|--------|---------|
| Conductive Water | Frost/Water spell (applies Wet) → Storm spell | Storm does 2.5× (not 1.0×) vs Wet target | Rime Shard desc: "drenching" |
| Forge Weakness | Lira Flame device (Heated) → Sable attacks | Shiv ignores 100% DEF (not 50%) on Heated | Workshop dialogue: "softening metal" |
| Pallor Feedback | Healing spell on Pallor-type enemy | Deals damage equal to heal amount | Archive lore: Pallor "consumes hope" |
| Smoke Ignition | Sable Smokescreen → any Flame spell | AoE Flame explosion: 1.5× to all in smoke | No hint — logical deduction |

### 9.4 Tier 3: Hidden Interactions

| Interaction | Setup | Effect | Discovery Path |
|-------------|-------|--------|---------------|
| Despair Cascade | Despair on Pallor enemy + Greyveil active | 50% max HP Void damage + Confused 2 turns | Combining Pallor's own status against it |
| Echo Strike | Cael's Echo crystal + attack Ember Vein enemy type | 3.0× damage, Cael's theme plays | Post-game only, recognizing Act I enemy types |
| Annulment Chain | Annulment (100 WG) on enemy with 5+ buffs | Fixed 14,999 damage regardless of stats | Math naturally breaks through cap at 5+ buffs |

### 9.5 Implementation Architecture

Interactions are **data-driven combat rules**, not special-cased code:
- "Grounded" is a status effect with properties (lose evasion, ATB -25%)
- "Conductive Water" is an elemental multiplier override (Wet status
  changes Storm affinity from 1.0× to 2.5×)
- "Frozen Shatter" is a conditional modifier (physical vs Frozen =
  1.5×, DEF = 0)

The bestiary (Gap 1.3) defines enemy properties (flying, armored,
undead, Pallor-type). The interaction system references those properties.
New interactions can be added by defining new property + trigger pairs
without code changes.

## 10. Boss HP Scaling

### 10.1 Scaling Philosophy

Boss HP values must create the right fight duration at each progression
point. With the physical formula producing 5,000–7,000 per hit at
endgame, and a 14,999 damage cap, bosses need FF6-scale HP pools.

**Duration targets:**
- Regular enemies: 2–4 hits from primary attacker
- Mini-bosses: 30–60 seconds (8–15 party actions)
- Standard bosses: 3–5 minutes (30–50 party actions)
- Major bosses: 5–8 minutes (50–80 party actions)
- Final gauntlet: 20–30 minutes total

### 10.2 Revised Boss HP Table

| Boss | Act | Old HP | New HP | Rationale |
|------|-----|--------|--------|-----------|
| Vein Guardian | I | 3,000 | 6,000 | Tutorial boss. ~20 party actions. |
| Corrupted Fenmother | II | 8,000 | 18,000 | 8 forms, ~2,250 each. Puzzle boss. |
| The Ironbound | II | 8,000 | 22,000 | Mid-game skill check. |
| General Kole | II | 12,000 | 30,000 | Act II climax. Pallor-enhanced. |
| Archive Guardian | Interlude | 10,000 | 28,000 | Three phases, ~9,300 each. |
| The Ashen Ram | Interlude | 10,000 | 25,000 | Party rebuilding strength. |
| The Ley Leech | Interlude | 9,000 | 24,000 | Ley nexus boss. |
| The Grey Engine | Interlude | 9,000 | 22,000 | Stunnable (effective HP lower). |
| The Forge Heart | III | 10,000 | 35,000 | Act III standard. |
| The Frost Warden | III | 11,000 | 38,000 | Elemental puzzle (Flame weakness). |
| The Pallor Hollow | III | 11,000 | 40,000 | Act III gauntlet entry. |
| Vaelith (unwinnable) | III | 20,000 | 50,000 | Narrative defeat. Timer-based. |
| Cael Phase 1 | III | 15,000 | 45,000 | Uses party's tactics against them. |
| Cael Phase 2 | III | — | 35,000 | Desperate. Pallor manifesting. |
| Pallor Incarnate | III | 25,000 | 70,000 | Final boss. FF6-scale. |

**Final gauntlet total:** 45K + 35K + 70K = **150,000 HP**

FF6 comparison: Dancing Mad gauntlet = ~325,000 HP with 9,999 cap.
Our 150,000 HP with 14,999 cap is proportionally similar — slightly
tighter, respecting the emotional intensity of the Cael betrayal
preceding the Pallor fight.

**Note:** These HP values are initial targets. Final tuning happens
during the bestiary pass (Gap 1.3) when full enemy stat sheets,
phase mechanics, and party composition are modeled together.

### 10.3 Regular Enemy HP by Act

| Act | Level Range | Enemy HP | Hits to Kill |
|-----|------------|----------|-------------|
| Tutorial (Ember Vein) | 1–5 | 80–200 | 2–4 |
| Act I | 8–18 | 400–1,200 | 2–3 |
| Act II | 20–35 | 1,200–4,000 | 2–3 |
| Interlude | 35–50 | 3,000–7,000 | 2–3 |
| Act III | 50–70 | 6,000–14,000 | 2–3 |
| Post-game | 70–150 | 12,000–50,000 | 2–4 |

### 10.4 Multi-Hit Rules

- Each hit calculated independently (separate variance, separate crit)
- Each hit capped at 14,999 individually
- DEF/MDEF applied per hit (not once for the sequence)
- Multi-hit is the primary way to exceed cap per turn:
  Oathkeeper (2 × 14,999 = 29,998) is the ultimate physical moment

### 10.5 AoE Damage Rules

AoE spells have ~60–70% of single-target spell power (defined in
magic.md). No damage splitting — each enemy takes the full AoE damage.
AoE is valuable for clearing groups; single-target is better for bosses.

## 11. Existing Formula Replacements

### 11.1 magic.md Updates

The current magic.md formulas are placeholders that predate the stat
system:

| Current (magic.md) | Replacement |
|--------------------|-------------|
| `magic_damage = max(1, (caster.mag * spell.power) - target.mdef) + random(-3, 3)` | `max(1, (MAG × spell_power) / 4 - target.MDEF) × element_mod × variance` |
| `heal_amount = (caster.mag * spell.power * 0.8) + random(0, 5)` | `(MAG × spell_power × 0.8) × variance` |

The `random(-3, 3)` and `random(0, 5)` are replaced by percentage-based
variance (`random_int(240, 255) / 256`) that scales properly at all
damage levels.

### 11.2 progression.md Updates

The Integration Notes section in progression.md flags the magic damage
scaling issue and suggests a divisor. After this spec is implemented:
- Update the WARNING in the Integration Notes to reference
  combat-formulas.md as the resolution
- Update the damage projection table to use the `/4` divisor
- Mark the open question in Section 10 of the spec as resolved

## 12. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/combat-formulas.md` | Create | Canonical combat formula document |
| `docs/story/magic.md` | Modify | Replace placeholder formulas |
| `docs/story/progression.md` | Modify | Update integration notes |
| `docs/story/dungeons-world.md` | Modify | Update boss HP values |
| `docs/analysis/game-design-gaps.md` | Modify | Gap 1.1 status update |

## 13. Out of Scope

- Per-enemy stat sheets (Gap 1.3 — Bestiary)
- Equipment stat tables (Gap 1.5 — depends on 1.6)
- Shop pricing (Gap 1.6 — Economy)
- ATB gauge fill rate formula (Gap 2.2)
- Encounter rate formulas (Gap 2.4)
- Specific combat interaction implementations beyond the examples in
  Section 9 (full list defined during bestiary and ability passes)

## 14. Integration Dependencies

Completing Gap 1.1 unblocks:
- **1.3 (Bestiary):** Can now define enemy stats balanced against these
  formulas
- **1.4 (Items):** Healing/damage items can reference the healing and
  damage formulas
- **2.5 (Row/Position):** Can now define row damage modifiers as
  multipliers on the physical formula

Still blocked:
- **1.5 (Equipment):** Also depends on 1.6 (Economy)
- **1.6 (Economy):** Depends on 1.3, 1.4, 1.5
