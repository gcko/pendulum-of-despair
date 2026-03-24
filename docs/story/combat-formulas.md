# Combat Formulas

> This document defines every formula the combat engine needs to
> resolve damage, healing, status effects, and special interactions.
> It is the primary reference for implementing combat and balancing
> encounters.
>
> **Related docs:** [progression.md](progression.md) |
> [magic.md](magic.md) | [abilities.md](abilities.md) |
> [characters.md](characters.md) | [dungeons-world.md](dungeons-world.md) |
> [events.md](events.md) | enemies.md (Gap 1.3)

**Design principles at a glance:**

- **Damage cap mirrors HP cap (14,999).** Hitting cap requires perfect setup — best spell, elemental weakness, buffs stacked. This creates the FF6 "9,999" eye-candy moment scaled to our system.
- **Physical = reliable, Magic = burst.** Physical attackers deal steady 5,000–7,000 at endgame; skills approach cap. Mages need elemental advantage + buffs to reach cap.
- **Quadratic physical scaling.** Physical damage uses ATK² so each point of ATK is increasingly valuable. Late-game gear upgrades feel impactful.
- **Subtractive defense with floor of 1.** DEF/MDEF directly reduce damage. Minimum damage is always 1 — weak enemies tickle you, proving you've outgrown them.
- **FF6-style variance (up to -6.25%).** Damage ranges from 93.75% to ~99.6% of nominal. Tight enough to plan around, loose enough to create drama.
- **Three tiers of combat interactions.** Designed emergent gameplay that rewards experimentation: telegraphed, experimental, and hidden.

---

## Physical Damage

```
raw = max(1, (ATK² × ability_mult) / 6 - target.DEF)
final = min(14999, raw × variance)
```

- **ATK** includes all sources: base stat + equipment + buff modifiers. Buffs like Rallying Cry (+30% ATK) modify ATK before it enters the formula (before squaring).
- **ability_mult** is 1.0 for a basic attack. Skills use higher values (see [Ability Multipliers](#physical-ability-multiplier-tiers)).
- **target.DEF** includes equipment and buff/debuff modifiers. Debuffs like Sunder (-30% DEF) reduce DEF before subtraction.
- **variance** is applied last, before the cap (see [Damage Variance](#damage-variance)).

**Rounding rule:** All intermediate calculations use real-number arithmetic. The final damage value is floored (truncated to integer) after variance is applied, just before clamping to [1, 14999]. No rounding occurs at intermediate steps — only the final result is truncated. This produces deterministic results matching the milestone tables below.

**Why ATK²?** ATK ranges 1–255. Linear ATK minus DEF produces a maximum of ~175 damage at endgame — far too low. Squaring ATK gives a natural 200× damage range from level 1 to cap (18² = 324 vs 255² = 65,025), producing the 5,000–7,000 basic attack range at endgame that matches the FF6 physical damage feel.

**Why divisor 6?** Tuned to produce these milestone values. Physical ATK values include equipment (base + gear); see [progression.md](progression.md) for natural stat growth:

| Scenario | ATK | Mult | DEF | Damage | Notes |
|----------|-----|------|-----|--------|-------|
| Edren Lv1 vs tutorial mob | 18 | 1.0 | 5 | ~49 | 2–3 hits on 100–150 HP mob |
| Edren Lv18 vs Act I mob | 49 | 1.0 | 15 | ~385 | 2–3 hits on 800 HP mob |
| Edren Lv35 vs Act II mob | 85 | 1.0 | 30 | ~1,174 | 2–3 hits on 2,500 HP mob |
| Edren Lv70 vs Act III (good gear) | 175 | 1.0 | 60 | ~5,044 | In the 5–7K target range |
| Edren Lv70 Riposte (1.5×) | 175 | 1.5 | 60 | ~7,596 | Strong skill hit |
| Edren Lv70 Oathkeeper (1.5×, 2 hits) | 175 | 1.5 | 60 | 7,596 × 2 | Two hits; each hit capped at 14,999 |
| Sable Lv70 Shiv (DEF halved) | 150 | 1.0 | 30 | ~3,720 | DEF-shredding thief |
| Edren Lv150 basic | 255 | 1.0 | 80 | ~10,757 | Post-game power fantasy |
| Edren Lv150 Oathkeeper (1.5×) | 255 | 1.5 | 80 | 14,999 | Hits cap with best skill |
| Any Lv150 2.0× technique | 255 | 2.0 | 60 | 14,999 | Bum Rush equivalent |

### Row Modifier

**Row Modifier (Physical Damage Only)**

The row system uses 2 rows (Front and Back) for the player party. Enemies have no rows — the system is player-side only.

| Condition | Modifier |
|-----------|----------|
| Front row attacker | ×1.0 (no change) |
| Back row attacker (melee weapon) | ×0.5 |
| Back row attacker (ranged weapon — spears) | ×1.0 (penalty bypassed) |
| Front row defender (physical attack) | ×1.0 (no change) |
| Back row defender (physical attack) | ×0.5 |
| Any row (magic damage) | No modifier — magic ignores rows |

Row modifiers apply as the **last step** in the physical damage pipeline, after all other calculations (ATK², ability multiplier, DEF subtraction, variance). The input is the damage value produced by variance (step 7 in the resolution pipeline):

```
final_physical_damage = floor(damage_after_variance × attacker_row_mod × defender_row_mod)
```

When a party member attacks an enemy: `attacker_row_mod` = party member's row modifier, `defender_row_mod` = ×1.0 (enemies have no rows). When an enemy attacks a party member: `attacker_row_mod` = ×1.0 (enemies have no rows), `defender_row_mod` = party member's row modifier.

**Row swapping** is a free action — no turn cost or ATB delay. Characters can reposition at any time during their turn.

Items, Forgewright devices, and Ley Crystal invocations work at full effect from either row.

**Entities without a row** (all enemies) use ×1.0 for both attacker and defender modifiers.

**AoE and rows:** AoE abilities hit all party members regardless of row. Physical AoE damage is still modified by each target's individual row modifier — back-row defenders take ×0.5 physical AoE damage. Magic AoE ignores rows entirely.

**Staves note:** Staves are melee weapons subject to the ×0.5 back-row penalty, but Maren's physical ATK is negligible — she attacks with magic, which ignores rows.

---

## Magic Damage

```
raw = max(1, (MAG × spell_power) / 4 - target.MDEF)
final = min(14999, raw × element_mod × variance)
```

- **MAG** includes all sources. Attunement (+30% MAG) modifies MAG before the formula.
- **spell_power** is defined per spell in [magic.md](magic.md) (Tier 1: 12–20, Tier 2: 28–40, Tier 3: 50–70, Tier 4: 85–120).
- **element_mod** is applied after the base calculation (see [Elemental System](#elemental-system)).
- **target.MDEF** includes equipment and debuff modifiers.

**Why divisor 4?** Tuned to produce these milestone values (MAG values are natural, per [progression.md](progression.md) milestones):

| Scenario | MAG | Power | MDEF | Base | Element (1.5×) | Notes |
|----------|-----|-------|------|------|----------------|-------|
| Maren Lv1 Ember Lance (T1) | 22 | 14 | 8 | ~69 | ~104 | Good opening |
| Maren Lv18 Kindlepyre (T2) | 53 | 32 | 20 | ~404 | ~606 | Solid mid-game |
| Maren Lv70 Crucible Wrath (T3) | 146 | 58 | 60 | ~2,057 | ~3,086 | Heavy hitter |
| Maren Lv150 Ley Ruin (T4) | 255 | 100 | 80 | ~6,295 | ~9,443 | Approaching cap |
| Maren Lv150 Ley Ruin + Attunement | 332* | 100 | 80 | ~8,220 | ~12,330 | Near cap |
| Maren Lv150 + Attune + Resonance | 332* | 100 | 80 | 8,220 | 12,330 × 1.3 = ~14,999 | Hits cap with full setup! |

*Attunement pushes MAG past 255 temporarily in combat (buffs can exceed cap per [progression.md](progression.md) rules).

**Reaching the 14,999 cap requires:** Best spell + elemental weakness + Attunement buff + Resonance combo. The math: 8,220 base × 1.5 element × 1.3 Resonance = 16,029, capped at 14,999. This is the "perfect setup" moment — rare, earned, and spectacular.

*Note: Ley Ruin (power 100) is AoE per [magic.md](magic.md). No single-target Tier 4 spell currently exists; if one is added during the ability pass, it would reach cap more easily.*

Magic damage is unaffected by row position.

---

## Healing

```
raw = (MAG × spell_power × 0.8)
final = min(14999, raw × variance)
```

- No defense subtraction — healing is not resisted.
- No divisor — intentional. Healing uses the raw `MAG × power` product because it has no defense to subtract. The 0.8 multiplier keeps healing at ~80% of equivalent-tier damage output before defense, preventing heal-tanking while ensuring heals feel meaningful.
- No floor of 1 needed — inputs are always positive.
- At Maren Lv70 (MAG 146) with Deepmend (power 30): 146 × 30 × 0.8 = 3,504 HP healed. Against damage of ~2,000–4,000 per enemy hit at this level, a single heal keeps pace but does not trivialize incoming damage.

---

## Damage Cap & Floor

**Damage cap: 14,999** — applies to all damage types (physical, magical, healing). Each individual hit is capped independently. Multi-hit abilities can exceed 14,999 total per turn (e.g., Oathkeeper's 2 hits can deal up to 29,998 in one turn).

**Damage floor: 1** — physical and magical damage can never deal less than 1 when the elemental modifier is positive. This applies after all calculations including variance. Elemental immunity (0.0×) and absorb (-1.0×) are explicit overrides that bypass the floor — immunity always deals 0 damage, and absorb always heals. A level 150 Edren taking a hit from a level 1 Restless Dead still sees "1" — satisfying proof of growth.

---

## Damage Variance

```
variance = random_int(240, 255) / 256
```

- Range: 0.9375 to 0.99609375 (93.75%–99.61% of raw damage, i.e., up to -6.25% below nominal). Variance always reduces from maximum — it is not symmetric. This matches FF6's exact implementation.
- Applied as a final multiplier before capping.
- Each hit rolls independently (multi-hit abilities get separate rolls).
- Healing also uses variance (potions and spells fluctuate slightly).

Tight enough that players can estimate "I need about 3 hits to kill this," loose enough that occasionally a low roll lets an enemy survive with a sliver of HP — creating a dramatic moment.

---

## Critical Hits

```
critical_damage = raw_damage × 2
```

- Applied before variance and cap.
- Uses the existing Critical% formula from [progression.md](progression.md): `LCK / 4` (cap 50%).
- Only physical attacks and physical abilities can crit (magic cannot).
- Sable (highest LCK growth) crits most often — fits her glass cannon identity.

At Lv70, Edren's basic attack (raw ~5,000) crits for ~10,000. Sable with her high crit rate produces a satisfying stream of critical Shiv hits that spike through armor.

---

## Ability Multipliers

### Physical Ability Multiplier Tiers

The `ability_mult` value in the physical formula. Basic attack = 1.0. Damage column assumes Edren at Lv70 with endgame gear (ATK ~175 = 142 natural + ~33 equipment) vs DEF 60 enemy:

| Mult | Tier | Examples | Lv70 Damage (ATK 175, DEF 60) |
|------|------|---------|-------------------------------|
| 1.0 | Basic attack | Attack command, Shiv (see below) | ~5,044 |
| 1.5 | Strong skill | Riposte counter | ~7,596 |
| 2.0 | Ultimate skill | Oathkeeper hits | ~10,148 |
| 2.5 | Combo ability | Shattered Vanguard (Edren+Sable) | ~12,700 |
| 3.0 | Maximum | Convergence Chorus (once per battle) | 14,999 (capped) |

The 3.0 tier is reserved for abilities with extreme costs — Torren's Convergence Chorus (once per battle), combo ultimates requiring specific party + setup. These are "Bum Rush" moments — the payoff for mastering the system.

### Buff-Granted Multipliers

Some abilities are buffs that multiply the next attack's output rather than having their own multiplier:

- **Overcharge (+50% damage):** Multiplies the next attack's final damage by 1.5×. Stacks multiplicatively with ability_mult. Example: Overcharge on Edren's Riposte (1.5×) = damage × 1.5 × 1.5 = 2.25× effective. See [abilities.md](abilities.md).
- **Press Forward (+20% ATK buff):** Modifies ATK stat for 3 turns. Since damage uses ATK², a 20% ATK buff yields ~44% more damage.
- **Resonance (+30% spell output):** Multiplies magic damage by 1.3× after base calculation and elemental modifiers.

### Special: Shiv (DEF Ignore)

Sable's Shiv halves target DEF before the formula: `DEF_effective = target.DEF / 2`

Shiv uses ability_mult 1.0 (no damage multiplier beyond the DEF penetration). The 50% DEF ignore IS the damage bonus — it is most valuable against heavily armored targets. Per [abilities.md](abilities.md): "Quick physical attack that ignores 50% of target's Defense."

Example — DEF 100 boss, both characters at Lv70 with gear:
- Edren (ATK 175) basic: (175² / 6) - 100 = ~5,004
- Sable (ATK 150) Shiv: (150² / 6) - 50 = ~3,700

Edren wins on raw output; Sable's advantage is speed (highest SPD) and crit rate (highest LCK). Against a DEF 40 enemy, the gap narrows because Shiv's DEF halving matters less when DEF is already low.

### Custom-Formula Abilities

These abilities use their own formulas, not the standard physical or magic formula:

- **Shatter Guard:** Damage = total absorbed damage since stance began, capped at 2× Edren's max HP. See [abilities.md](abilities.md).
- **Annulment:** Damage = (MAG × 2) + (effects_removed × 15), as magic damage. 100 WG cost.
- **Greyveil:** Non-elemental magic damage that ignores MDEF.

---

## Buff & Debuff Interaction

Buffs modify stats before they enter formulas, not damage output:

| Buff | Modifies | Formula Impact |
|------|----------|---------------|
| Rallying Cry (+30% ATK) | ATK stat | ATK² uses buffed value |
| Attunement (+30% MAG) | MAG stat | MAG × power uses buffed value |
| Ironhide (+40% DEF) | DEF stat | Target DEF in subtraction |
| Sunder (-30% DEF) | DEF stat | Target DEF in subtraction |
| Glintmark (+10% dmg taken) | Final damage | Multiplied after variance |
| Resonance (+30% spell) | Spell output | Multiplied after base calc |

Buffs that modify stats can push them past 255 temporarily in combat (per [progression.md](progression.md) rules). This is intentional — it is the pathway for mages to reach the damage cap.

---

## Elemental System

### Elemental Damage Modifiers

Applied after the base magic damage calculation (or physical damage if the attack has an elemental property):

| Interaction | Multiplier | Example |
|------------|-----------|---------|
| Elemental weakness | 1.5× | Flame vs Frost enemy |
| Neutral | 1.0× | Flame vs Earth enemy |
| Elemental disadvantage | 0.75× | Flame vs Storm enemy (per elemental wheel) |
| Same-element resistance | 0.5× | Flame vs Flame enemy |
| Immunity | 0.0× | Void vs Void enemy |
| Absorb | -1.0× | Heals target for damage amount |

### Element Matchup Wheel

From [magic.md](magic.md):

| Element | Strong vs (1.5×) | Weak vs (0.75×) |
|---------|-------------------|------------------|
| Flame | Frost | Storm |
| Frost | Storm | Earth |
| Storm | Earth | Flame |
| Earth | Flame | Frost |
| Ley | Void | Spirit |
| Spirit | Ley | Void |
| Void | Spirit | Ley |
| Non-elemental | — (1.0× to all) | — (1.0× to all) |

### Physical Elemental Attacks

Some weapons and abilities have elemental properties:
- Lira's Arc Trap: Flame element
- Lira's Overcharge: Storm element
- Elemental weapons (defined in equipment, Gap 1.5)

When a physical attack has an element, the elemental multiplier applies to the physical damage output. This gives Lira's engineering abilities real tactical value against elementally-weak enemies.

---

## Status Effect Accuracy

### Two-Stage Resolution

Consolidated from [progression.md](progression.md) and [magic.md](magic.md). Where there is any discrepancy, [progression.md](progression.md) supersedes [magic.md](magic.md) for combat resolution details.

```
Stage 1: effective_rate = base_rate × (caster.MAG / (caster.MAG + target.MDEF))
Stage 2: if Stage 1 succeeds, target rolls Magic Evasion% to resist
```

### Status Accuracy at Key Points

| Scenario | Base | MAG | MDEF | Stage 1 | MEVA% | Final |
|----------|------|-----|------|---------|-------|-------|
| Maren Lv18 Poison (75%) vs Act I | 75% | 53 | 15 | 58% | ~8% | ~53% |
| Maren Lv70 Sleep (70%) vs Act III | 70% | 146 | 60 | 50% | ~15% | ~42% |
| Maren Lv70 Petrify (50%) vs boss | 50% | 146 | 80 | 32% | ~18% | ~26% |

Status effects devastate regular enemies but are unreliable against bosses with high MDEF. This prevents cheese strategies while keeping statuses valuable in standard encounters.

### Boss Status Immunities

Defined per-boss in the bestiary (Gap 1.3). Standard patterns:

| Category | Immune To | Vulnerable To |
|----------|----------|---------------|
| Most bosses | Petrify, Stop, Sleep, Confusion | Poison, Slow, Despair (hard to land) |
| Caster bosses | — (not immune to Silence) | Silence (tactical opening) |
| Pallor bosses | Poison (undead-adjacent) | Despair (thematic irony) |
| Final boss | Everything except Despair | Despair only (you cannot escape Despair) |

---

## Combat Resolution Order

### Physical Attack Resolution

1. **Hit Rate% roll** — `90 + (attacker.SPD - target.SPD) / 4`, clamped to [20%, 99%]. Miss = 0 damage, stop.
2. **Evasion% roll** — `target.SPD / 4`, cap 50%. Dodged = 0 damage, stop.
3. **Calculate base damage** — `(ATK² × ability_mult) / 6 - target.DEF`
4. **Floor check** — `max(1, base_damage)`
5. **Critical% roll** — `attacker.LCK / 4`, cap 50%. If crit: × 2.
6. **Apply combat interaction modifiers** (Frozen Shatter, Glintmark, etc.)
7. **Apply variance** — `× random_int(240, 255) / 256`
8. **Apply row modifiers** — `× attacker_row_mod × defender_row_mod` (see [Row Modifier](#row-modifier))
9. **Floor and clamp** — `max(1, min(14999, floor(result)))`

### Magic Damage Resolution

1. **Calculate base damage** — `(MAG × spell_power) / 4 - target.MDEF`
2. **Floor check** — `max(1, base_damage)`
3. **Apply elemental modifier** (1.5×, 1.0×, 0.75×, 0.5×, 0.0×, or -1.0×)
4. **Apply combat interaction modifiers** (Conductive Water, etc.)
5. **Apply buff modifiers** (Resonance, Glintmark)
6. **Apply variance** — `× random_int(240, 255) / 256`
7. **Floor and clamp** — `max(1, min(14999, floor(result)))` (floor of 1 bypassed if elemental modifier was 0.0× or -1.0×)

Magic damage spells use the same Hit Rate% and Evasion% checks as physical attacks (see [progression.md](progression.md)). Critical% rolls never apply to magic damage — spells cannot crit.

### Status Spell Resolution

1. **Stage 1** — `effective_rate = base_rate × (MAG / (MAG + target.MDEF))`
2. **Roll vs effective_rate** — fail = status not applied, stop.
3. **Stage 2** — target rolls Magic Evasion% (`(MDEF + SPD) / 8`, cap 40%). Resist = status not applied.
4. **Check immunity list** — if target is immune, status not applied.
5. **Apply status** with defined duration.

### Healing Resolution

1. **Calculate base heal** — `MAG × spell_power × 0.8`
2. **Apply variance** — `× random_int(240, 255) / 256`
3. **Clamp** — `min(14999, result)`

No hit/miss check. No defense. Healing always lands.

---

## Combat Interactions & Hidden Synergies

### Interaction Tier System

| Tier | Name | Discovery | Player % Who Find | Count |
|------|------|-----------|-------------------|-------|
| 1 | Telegraphed | NPC hints, visual cues | ~70% | 8–10 |
| 2 | Experimental | Logical experimentation | ~25% | 6–8 |
| 3 | Hidden | Community discovery | ~5% | 3–4 |

**Design principles:**
- Every interaction is intentional and balanced — powerful, not game-breaking.
- Tier 1 teaches players the system exists.
- Tier 2 rewards players who internalize that lesson.
- Tier 3 creates community moments and replayability.
- No interaction is required to progress — shortcuts, not keys.

The examples below illustrate the system. The full interaction list will be defined during the bestiary and ability passes.

### Tier 1: Telegraphed

| Interaction | Setup | Effect | Hint |
|-------------|-------|--------|------|
| Grounded | Storm spell vs flying enemy | 2.0× damage + Grounded status (lose evasion bonus, ATB -25%, 3 turns) | NPC: "Canyon hawks won't fly in a storm" |
| Shattered Armor | Lira's Overcharge (Storm) vs armored/mechanical | Strips 50% DEF, 3 turns | Lira: "That plating is conductive..." |
| Frozen Shatter | Physical attack vs Frozen enemy | 1.5× damage, bypasses DEF, removes Frozen | Visual: frozen enemies crack when hit |
| Spirit Banish | Torren's Greyveil vs undead | Instant kill on undead below 25% HP | Ability desc: "boundary grows thin" |

### Tier 2: Experimental

| Interaction | Setup | Effect | Subtext |
|-------------|-------|--------|---------|
| Conductive Water | Frost/Water spell (applies Wet) then Storm spell | Storm does 2.5× (not 1.0×) vs Wet target | Rime Shard desc mentions "drenching" |
| Forge Weakness | Lira Flame device (applies Heated) then Sable attacks | Shiv ignores 100% DEF (not 50%) on Heated target | Workshop dialogue: "softening metal" |
| Pallor Feedback | Healing spell on Pallor-type enemy | Deals damage equal to heal amount | Archive lore: Pallor "consumes hope" |
| Smoke Ignition | Sable's Smokescreen then any Flame spell | AoE Flame explosion: 1.5× to all enemies in smoke | No hint — logical deduction |

### Tier 3: Hidden

| Interaction | Setup | Effect | Discovery Path |
|-------------|-------|--------|---------------|
| Despair Cascade | Apply Despair to Pallor enemy while Greyveil is active on party | 50% max HP as Void damage + Confused 2 turns | Combining the Pallor's own status against it |
| Echo Strike | Equip Cael's Echo crystal + attack Ember Vein enemy type | 3.0× damage, Cael's battle theme plays | Post-game only; requires recognizing Act I enemy types |
| Annulment Chain | Maren's Annulment (100 WG) on enemy with 5+ buffs | Fixed 14,999 damage regardless of stats | Math naturally breaks through cap at 5+ buffs |

### Implementation Architecture

Interactions are **data-driven combat rules**, not special-cased code:
- "Grounded" is a status effect with defined properties (lose evasion bonus, ATB -25%).
- "Conductive Water" is an elemental multiplier override (Wet status changes Storm affinity from 1.0× to 2.5×).
- "Frozen Shatter" is a conditional modifier (physical vs Frozen = 1.5×, DEF = 0).

The bestiary (Gap 1.3) defines enemy properties (flying, armored, undead, Pallor-type). The interaction system references those properties. New interactions can be added by defining new property + trigger pairs without code changes.

---

## Boss HP Scaling

> **Boss HP values** were calibrated against the combat formulas above.
> These are initial targets; final tuning happens during the bestiary
> pass (Gap 1.3).

### Fight Duration Targets

- Regular enemies: 2–4 hits from primary attacker
- Mini-bosses: 30–60 seconds (8–15 party actions)
- Standard bosses: 3–5 minutes (30–50 party actions)
- Major bosses: 5–8 minutes (50–80 party actions)
- Final gauntlet: 20–30 minutes total

### Revised Boss HP Table

| Boss | Act | HP | Rationale |
|------|-----|----|-----------|
| Vein Guardian | I | 6,000 | Tutorial boss. ~20 party actions. |
| Corrupted Fenmother | II | 18,000 | Boss phase + 4 cleansing waves. Puzzle boss. |
| The Ironbound | Interlude | 22,000 | Mid-game skill check. |
| General Kole | Interlude | 30,000 | Pallor-enhanced commander. |
| Archive Guardian | Interlude | 28,000 | Three phases, ~9,300 each. |
| The Ashen Ram | II | 25,000 | Act II climax. Siege boss. |
| The Ley Leech | Interlude | 24,000 | Ley nexus boss. |
| The Grey Engine | Interlude | 22,000 | Stunnable (effective HP lower). |
| The Forge Heart | II/Interlude | 35,000 | Caldera Forge Depths boss. |
| The Frost Warden | Interlude/III | 38,000 | Elemental puzzle (Flame weakness). |
| The Pallor Hollow | Interlude | 40,000 | Edren recovery sequence. |
| Vaelith, the Ashen Shepherd | III | 50,000 | Winnable penultimate boss. Two phases. |
| Cael Phase 1 | III | 45,000 | Uses party's tactics against them. |
| Cael Phase 2 | III | 35,000 | Desperate. Pallor fully manifesting. |
| Pallor Incarnate | III | 70,000 | Final boss. FF6-scale. |

**Final gauntlet total:** 45K + 35K + 70K = **150,000 HP**

FF6 comparison: Dancing Mad gauntlet totals ~325,000 HP with a 9,999 damage cap. Our 150,000 HP with a 14,999 cap is proportionally similar — slightly tighter, respecting the emotional intensity of the Cael betrayal preceding the Pallor fight.

### Regular Enemy HP by Act

| Act | Level Range | Enemy HP | Hits to Kill |
|-----|------------|----------|-------------|
| Tutorial (Ember Vein) | 1–5 | 80–200 | 2–4 |
| Act I | 8–18 | 400–1,200 | 2–3 |
| Act II | 20–35 | 1,200–4,000 | 2–3 |
| Interlude | 35–50 | 3,000–7,000 | 2–3 |
| Act III | 50–70 | 6,000–14,000 | 2–3 |
| Post-game (Dreamer's Fault) | 70–150 | 12,000–50,000 | 2–4 |

### Multi-Hit Rules

- Each hit is calculated independently (separate variance rolls, separate crit checks).
- Each hit is capped at 14,999 individually.
- DEF/MDEF is applied per hit (not once for the sequence).
- Multi-hit is the primary way to exceed the damage cap per turn: Oathkeeper (2 × 14,999 = 29,998) is the ultimate physical moment.

### AoE Damage Rules

AoE spells have ~60–70% of single-target spell power (defined in [magic.md](magic.md)). No damage splitting — each enemy takes the full AoE damage. AoE is valuable for clearing groups; single-target is better for bosses.

---

## ATB Gauge System

The Active Time Battle gauge determines when each combatant acts. The gauge fills continuously based on SPD; when it reaches maximum, the combatant takes a turn. See [progression.md](progression.md) for SPD stat values and growth rates.

### Fill Rate Formula

```
fill_rate = floor((effective_SPD + 25) * battle_speed_factor * status_modifier_product)
```

**Full pipeline (order of operations):**

1. `effective_SPD = floor(base_SPD * crystal_modifier)` (e.g., Frost Veil from [progression.md](progression.md): crystal_modifier = 0.85)
2. `base_fill = (effective_SPD + 25) * battle_speed_factor`
3. `fill_rate = floor(base_fill * status_modifier_product)` (e.g., Haste × Despair = 1.5 × 0.75 = 1.125)

All intermediate values use real-number arithmetic. The final fill_rate is floored to an integer. Each tick (60/second), the gauge increases by exactly fill_rate.

**Constants:**

| Constant | Value | Purpose |
|----------|-------|---------|
| Base speed | 25 | Floor ensures even SPD 1 is playable |
| Gauge max | 16,000 | Total gauge capacity |
| Tick rate | 60/second | Fixed frame rate for gauge updates |

**Time to fill:** `seconds = 16000 / fill_rate / 60`

### Battle Speed Config

Player-configurable (1-6, default 3). Default matches FF6.

| Setting | Factor | Maren Lv1 (SPD 8) | Sable Lv1 (SPD 18) |
|---------|--------|-------------------|-------------------|
| 1 (Fastest) | 6 | 1.3s | 1.0s |
| 2 | 5 | 1.6s | 1.2s |
| **3 (Default)** | **3** | **2.7s** | **2.1s** |
| 4 | 2 | 4.0s | 3.1s |
| 5 | 1.5 | 5.4s | 4.1s |
| 6 (Slowest) | 1 | 8.1s | 6.2s |

### Active/Wait Mode

- **Active (default):** All gauges fill continuously. Enemy gauges fill while browsing spell/item menus. Time pressure on every decision.
- **Wait:** Gauges pause for ALL combatants while any command sub-menu is open (Magic, Item, Ability lists, target selection). Top-level command selection (Attack/Magic/Ability/Item/Defend/Flee) still runs in real-time. Real-time status timers (Stop's 3-second countdown) also pause during Wait sub-menus — Wait mode pauses ALL time progression, not just gauges.

Both settings in Config menu. Defaults: Active mode, Battle Speed 3 — matching FF6.

### ATB Pacing at Key Milestones (Battle Speed 3)

| Scenario | SPD | Fill Rate | Seconds/Turn |
|----------|-----|-----------|-------------|
| Maren Lv1 | 8 | 99 | 2.7s |
| Sable Lv1 | 18 | 129 | 2.1s |
| Maren Lv70 | 49 | 222 | 1.20s |
| Edren Lv70 | 65 | 270 | 0.99s |
| Sable Lv70 | 128 | 459 | 0.58s |
| Sable Lv70 + Haste | 128 | 688 | 0.39s |
| Typical Lv70 enemy (SPD 60) | 60 | 255 | 1.0s |

### Fill Rate Modifiers (Status Effects)

Multiple modifiers stack multiplicatively:

| Status | Modifier | Notes |
|--------|----------|-------|
| Haste (Quickstep) | × 1.5 | 5 turns. See [magic.md](magic.md). |
| Slow (Leaden Step) | × 0.5 | 5 turns. |
| Despair | × 0.75 | 4 turns. Also -20% damage dealt. |
| Grounded | × 0.75 | 3 turns. Flying enemies only. |
| Berserk | × 1.25 | Until cured. Also +50% basic attack damage. |

Stacking example: Haste + Despair = 1.5 × 0.75 = 1.125 (net +12.5%).

### Status Effect ATB Interactions

| Status | Gauge Behavior | When Fills | Duration | Notes |
|--------|---------------|-----------|----------|-------|
| Haste | × 1.5 | Normal turn | 5 turns | |
| Slow | × 0.5 | Normal turn | 5 turns | |
| Stop | Frozen at current value | Cannot act | 3 real-time seconds | Not turn-based; pauses in Wait mode |
| Sleep | Frozen at current value | Cannot act | Until cured or damaged | Resumes from frozen point. See [magic.md](magic.md). |
| Confusion | × 1.0 | Auto-attack random ally or enemy | 3 turns or until damaged | |
| Berserk | × 1.25 | Auto-attack random enemy (+50% basic attack damage) | Until cured | Tradeoff |
| Despair | × 0.75 | Normal turn (-20% damage) | 4 turns | Pallor signature |
| Grounded | × 0.75 | Normal turn (lose evasion) | 3 turns | Flying only |
| Petrify | Frozen (0) | Removed from battle | Until cured | Gauge resets to 0 on cure |

**Key rules:**
- **Frozen gauge retains value.** Sleep and Stop freeze at current position. Gauge resumes from that point when status ends.
- **Petrify resets to 0.** Most severe status — recovery starts fresh.
- **Stop uses real-time.** 3 seconds of real-time (not turn-based), counted only while battle time is running. Proportionally more punishing at slow speeds. In Wait mode, the Stop countdown pauses along with all other time progression while sub-menus are open.
- **Berserk is a tradeoff.** Faster (+25%) and stronger (+50% basic attack) but uncontrollable. Almost a buff on physical fighters.

### Turn Order Resolution

When multiple combatants fill on the same tick:

1. Higher effective SPD acts first
2. Party before enemies (if SPD tied)
3. Left-to-right slot order within each side (party slot index for allies, formation index for enemies)

Fully deterministic — no RNG.

**Gauge overflow:** Excess discarded. Gauge resets to 0 after acting. No banking extra speed. Refilling starts immediately on the next tick.

### Party & Enemy Size

- **4 active party members** (FF6 standard). Swap at save points or between battles.
- **Guest NPCs** (Cordwyn, Kerra) take a temporary 5th slot — they do not displace a party member.
- **Up to 6 enemies** per encounter.
- **Interlude:** Party scales from 1 (Sable alone) to 4 as she finds each party member.

---

## Integration Notes

This document replaces the placeholder formulas that existed in [magic.md](magic.md) and resolves the scaling warning in [progression.md](progression.md):

| Old Formula (magic.md) | New Formula |
|------------------------|-------------|
| `magic_damage = max(1, (caster.mag * spell.power) - target.mdef) + random(-3, 3)` | `min(14999, max(1, (MAG × spell_power) / 4 - target.MDEF) × element_mod × variance)` |
| `heal_amount = (caster.mag * spell.power * 0.8) + random(0, 5)` | `min(14999, (MAG × spell_power × 0.8) × variance)` |

The `random(-3, 3)` and `random(0, 5)` placeholders are replaced by percentage-based variance (`random_int(240, 255) / 256`) that scales properly at all damage levels.

The physical damage formula (`ATK² / 6 - DEF`) is entirely new — no prior placeholder existed.
