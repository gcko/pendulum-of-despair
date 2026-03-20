# Character Stat System Design Spec

**Date:** 2026-03-19
**Status:** Implemented
**Scope:** New file `docs/story/progression.md` — character stats, growth
curves, Ley Crystal system, and narrative milestone spikes. Also updates
to `docs/story/characters.md` for base stat tables.
**Gap:** 1.2 (Character Stat System)

---

## 1. Purpose

Define the complete numerical foundation for all characters in Pendulum
of Despair: what stats exist, how they grow, what modifies them, and how
they interact with the rest of the game's systems (combat formulas,
equipment, encounters).

## 2. Design Principles

1. **Medium scale (1-255).** Classic SNES 8-bit stat range. Stats are
   human-readable and every point feels meaningful.
2. **Level cap 150.** Extended beyond the classic 99 — rewards
   dedicated players without being unreachable.
3. **HP cap 14999, MP cap 1499.** 10:1 ratio matching FF6's convention.
   A modest update to the SNES classic ceiling.
4. **Differentiated growth.** Each character levels up differently.
   A mage gains MP and MAG; a knight gains HP and DEF. No two
   characters feel interchangeable.
5. **Three progression layers.** Base growth (automatic per level) +
   Ley Crystal bonuses (player choice) + narrative milestone spikes
   (story-driven). Each layer serves a different design purpose.
6. **Party join at average level.** New and returning characters join
   at `party_average_level - 1`, ensuring immediate playability.
   Matches FF6's approach.

## 3. Stat Definitions

### 3.1 Core Stats (8 total)

| Stat | Abbr | Range | Description |
|------|------|-------|-------------|
| Hit Points | HP | 50-14999 | Health pool. 0 = Fainted (see events.md section 2c). |
| Magic Points | MP | 10-1499 | Fuel for spells and some abilities. |
| Attack | ATK | 1-255 | Physical damage dealt. Used by weapons and physical abilities. |
| Defense | DEF | 1-255 | Physical damage reduced. Also used by Thornveil counter (20% of DEF). |
| Magic | MAG | 1-255 | Spell damage, healing potency, status infliction rate. Used in magic.md formula: `(caster.mag * spell.power) - target.mdef`. |
| Magic Defense | MDEF | 1-255 | Spell damage reduced. Status effect resistance. |
| Speed | SPD | 1-255 | ATB gauge fill rate. Also: flee success rate, preemptive strike chance. |
| Luck | LCK | 1-255 | Critical hit chance, steal success (Sable), rare drop rate. Sable's signature stat. |

### 3.2 Derived Stats

These are calculated from core stats. Equipment can add flat bonuses
on top of the derived value.

| Derived Stat | Formula | Cap | Notes |
|-------------|---------|-----|-------|
| Hit Rate% | `90 + (SPD - target.SPD) / 4` | 99% (min 20%) | Base 90% accuracy. Fast attackers are more accurate against slow targets. Cannot reach 100% — there is always a 1% miss chance. Floor of 20% prevents complete whiffs. |
| Evasion% | `SPD / 4` | 50% | Chance to dodge physical attacks after hit check passes. Equipment adds flat EVA% on top. |
| Critical% | `LCK / 4` | 50% | Chance for physical attacks to deal 2x damage. Equipment adds flat CRIT% on top. |
| Magic Evasion% | `(MDEF + SPD) / 8` | 40% | Chance to resist status spells. Does not apply to damage spells. |

**Attack resolution order:** Hit Rate% roll first. If hit misses, no
further checks. If hit lands, target rolls Evasion% to dodge. If not
dodged, attacker rolls Critical% for bonus damage. This three-stage
check creates moments of drama: a hit that lands, isn't dodged, AND
crits feels earned.

### 3.3 Stat Caps

| Stat | Soft Cap | Hard Cap | Notes |
|------|----------|----------|-------|
| HP | — | 14999 | Natural growth + Ley Crystal bonuses can exceed 9999 |
| MP | — | 1499 | 10:1 ratio with HP cap |
| ATK, DEF, MAG, MDEF, SPD, LCK | 255 | 255 | Natural growth hits this around level 120-140 for primary stats. Equipment and Ley Crystal bonuses cannot exceed the cap. |
| EVA% | — | 50% | Derived from SPD + equipment |
| CRIT% | — | 50% | Derived from LCK + equipment |
| MEVA% | — | 40% | Derived from MDEF + SPD |

## 4. Character Growth Profiles

### 4.1 Growth Rates Per Level

Each character has a growth archetype. Rates are per-level averages —
actual gains alternate (e.g., +3 ATK on odd levels, +2 on even =
average 2.5) to avoid monotony.

| Stat | Edren (Knight) | Cael (Commander) | Lira (Engineer) | Torren (Sage) | Sable (Thief) | Maren (Archmage) |
|------|-------|------|------|--------|-------|-------|
| HP | +85 | +65 | +55 | +50 | +45 | +40 |
| MP | +3 | +5 | +6 | +8 | +4 | +10 |
| ATK | +1.8 | +1.5 | +1.2 | +0.8 | +1.4 | +0.5 |
| DEF | +1.6 | +1.2 | +1.0 | +0.7 | +0.6 | +0.5 |
| MAG | +0.5 | +0.8 | +1.3 | +1.5 | +0.6 | +1.8 |
| MDEF | +0.7 | +0.9 | +1.0 | +1.3 | +0.8 | +1.5 |
| SPD | +0.8 | +1.0 | +0.9 | +0.7 | +1.6 | +0.6 |
| LCK | +0.6 | +0.7 | +0.8 | +0.5 | +1.5 | +0.4 |

**Character identity through stats:**
- **Edren (Knight):** Highest HP by far. Highest DEF and ATK. Slowest
  caster. He IS the wall.
- **Cael (Commander):** Best generalist — balanced across all stats.
  His loss after the betrayal creates a genuine combat hole.
- **Lira (Engineer):** Hybrid ATK/MAG. Decent at both, exceptional at
  neither. Flexibility is her strength.
- **Torren (Sage):** High MAG, MDEF, and MP. Fragile physically.
  Classic white mage — essential but vulnerable.
- **Sable (Thief):** Fastest and luckiest. Paper-thin HP and DEF.
  Glass cannon who exploits Shiv's 50% DEF ignore.
- **Maren (Archmage):** Highest MAG and MP in the game. Lowest HP,
  ATK, DEF, SPD. Joins Act I and transforms the party's magical
  output, but needs Edren's protection.

### 4.2 Base Stats at Level 1

| Stat | Edren | Cael | Lira | Torren | Sable | Maren |
|------|-------|------|------|--------|-------|-------|
| HP | 95 | 78 | 68 | 62 | 58 | 50 |
| MP | 15 | 25 | 30 | 40 | 20 | 55 |
| ATK | 18 | 15 | 14 | 10 | 13 | 6 |
| DEF | 16 | 13 | 12 | 9 | 8 | 6 |
| MAG | 6 | 10 | 14 | 16 | 8 | 22 |
| MDEF | 8 | 10 | 12 | 14 | 10 | 18 |
| SPD | 10 | 12 | 11 | 9 | 18 | 8 |
| LCK | 8 | 9 | 10 | 7 | 16 | 5 |

### 4.3 Projected Stats at Milestones (No Equipment, No Ley Crystals)

| Milestone | Lvl | Edren HP | Edren ATK | Maren MAG | Sable SPD | Sable LCK |
|-----------|-----|----------|-----------|-----------|-----------|-----------|
| First level-up | 2 | 180 | 20 | 24 | — | — |
| End of Act I | ~18 | 1,540 | 49 | 53 | 45 | 42 |
| End of Act II | ~35 | 2,985 | 79 | 83 | 72 | 67 |
| Interlude end | ~50 | 4,260 | 106 | 110 | 96 | 90 |
| End of Act III | ~70 | 5,960 | 142 | 146 | 128 | 120 |
| Level cap | 150 | 12,760 | 255 | 255 | 255 | 240 |

Formula: `stat_at_level = base + growth * (level - 1)`, capped at 255
(or 14999 for HP, 1499 for MP). These projections **exclude** equipment,
Ley Crystal bonuses, and narrative milestone spikes (Section 6).

Primary stats reach the 255 cap around level 120-140 naturally. Sable's
SPD (growth 1.6) hits 255 at level ~149. LCK (growth 1.5) reaches 240
at level 150 — the only primary stat that doesn't cap naturally,
rewarding LCK-boosting Ley Crystals. The last 10-30 levels are for
secondary stats to catch up and for HP/MP to keep growing toward their
higher ceilings.

### 4.4 Party Join Level Rule

When a character joins (first recruitment or reunion), their level is
set to `party_average_level - 1` (minimum: story-appropriate floor).

| Character | Join Point | Floor Level |
|-----------|-----------|-------------|
| Edren | Game start | 1 |
| Cael | Game start (with Edren) | 1 |
| Lira | Act I recruitment | 1 |
| Torren | Act I recruitment | 1 |
| Sable | Act I recruitment | 1 |
| Maren | Act I recruitment (reunites Interlude) | 1 |
| Interlude reunions | Sable finds each party member | — (uses party average - 1) |

### 4.5 Guest NPC Stats

Guest NPCs (Cordwyn, Kerra, etc.) join temporarily for specific
story segments. They use fixed stats — they do not level up or benefit
from Ley Crystals.

| Guest NPC | When | Stats Rule | Notes |
|-----------|------|-----------|-------|
| Dame Cordwyn | Siege of Valdris (Act II) | Stats = party average for ATK/DEF/SPD. HP = Edren's current HP * 0.8. Fixed abilities: Shield Wall, Rally Cry. | Competent but not overpowering. Feels like a real knight fighting alongside the party. |
| Kerra | Caldera Unbowed (Interlude) | Stats = 60% of party average across all stats. HP = party average HP * 0.5. | Intentionally fragile. Narrative weight: protecting her is the challenge. If she falls to 0 HP, she is incapacitated but survives (per events.md). |

Guest NPCs cannot be equipped, cannot use items, and do not earn XP.
Their actions are AI-controlled (Attack + 1-2 signature abilities).
They do not count toward party wipe — if all player characters Faint
but a guest is standing, the wipe still triggers (per events.md).

The "-1" means the new character is always close to catching up —
usually one or two battles from matching the party. This creates a
satisfying early-level-up feel on every recruitment, matching FF6's
approach.

### 4.6 Equipment and Buff Rules

- **Equipment stat bonuses are additive.** A sword with ATK +12 adds
  12 to the character's ATK. Simple and transparent.
- **Equipment cannot push stats past the 255 cap** for ATK/DEF/MAG/
  MDEF/SPD/LCK. HP and MP can exceed their natural growth via
  equipment up to their hard caps (14999 / 1499).
- **Buffs and debuffs are percentage-based.** Haste = +25% SPD.
  Protect = +25% DEF. Shell = +25% MDEF. These are applied to the
  final stat (base + equipment) and CAN temporarily exceed 255 in
  combat. Debuffs work the same way in reverse.
- **Buff stacking:** Buffs of the same type do not stack. Recasting
  Protect refreshes the duration but does not double the bonus.
  Different buff types stack (Protect + Shell = both active).

## 5. Ley Crystal System

### 5.1 Overview

Ley Crystals are crystallized fragments of the ley line network — raw
magical energy solidified over millennia. They serve as the game's
Esper/Magicite equivalent: equip one to a character, and they gain
permanent stat bonuses each time they level up.

### 5.2 Core Mechanics

- Each character has **1 Ley Crystal slot** (separate from accessories)
- While equipped, the crystal grants permanent stat bonuses at each
  character level-up, based on the crystal's current level
- Crystals are **not consumed** — swappable freely outside battle
- Permanent stat gains persist after unequipping the crystal
- A character can only have one crystal equipped at a time

### 5.3 Crystal Leveling

Crystals gain XP equal to **30% of the wearer's XP** after each battle.
Crystals have 5 levels. At certain levels, bonuses upgrade, new bonuses
unlock, or special effects trigger.

| Crystal Level | XP Required | Typical Battles |
|--------------|-------------|-----------------|
| 1 (base) | 0 | Equipped |
| 2 | 800 | ~15 battles |
| 3 | 2,500 | ~35 battles |
| 4 | 6,000 | ~60 battles |
| 5 | 15,000 | ~100 battles |

### 5.4 Crystal Catalog (18 Crystals)

#### Standard Crystals (no negative effects)

| Crystal | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 | Found |
|---------|-----|-----|-----|-----|-----|-------|
| Ember Shard | ATK +1 | ATK +1 | ATK +2 | ATK +2 | ATK +2, DEF +1 | Ember Vein Floor 4 |
| Iron Core | DEF +2 | DEF +2 | DEF +2, HP +50/lvl | DEF +2, HP +50/lvl | DEF +3, HP +80/lvl | Valdris Crown Catacombs |
| Ley Prism | MAG +1 | MAG +2 | MAG +2 | MAG +2, MP +5/lvl | MAG +3, MP +8/lvl | Archive of Ages |
| Ward Stone | MDEF +1 | MDEF +2 | MDEF +2 | MDEF +2 | MDEF +2, MAG +1 | Highcairn Monastery |
| Quicksilver | SPD +1 | SPD +2 | SPD +2 | SPD +2, LCK +1 | SPD +2, LCK +2 | Corrund Undercity / Sewers |
| Fortune Stone | LCK +2 | LCK +2 | LCK +2, SPD +1 | LCK +3, SPD +1 | LCK +3, SPD +2 | Sable sidequest |
| Lifestone | HP +120/lvl | HP +120/lvl | HP +150/lvl | HP +150/lvl | HP +200/lvl, DEF +1 | Fenmother's Hollow |
| Wellspring | MP +10/lvl | MP +10/lvl | MP +12/lvl, MAG +1 | MP +12/lvl, MAG +1 | MP +15/lvl, MAG +2 | Ley Line Depths |
| Spirit Tear | MAG +1, SPD +1 | MAG +1, SPD +1 | MAG +1, SPD +1 | MAG +2, SPD +1 | MAG +2, SPD +2 | Ley Nexus Hollow |
| Forgewright Core | ATK +1, DEF +1 | ATK +1, DEF +1 | ATK +2, DEF +1 | ATK +2, DEF +2 | ATK +2, DEF +2 | Lira sidequest |

#### Crystals With Negative Effects

| Crystal | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 | Negative Effect | Found |
|---------|-----|-----|-----|-----|-----|-----------------|-------|
| Flame Heart | ATK +1, MAG +1 | ATK +1, MAG +1 | ATK +2, MAG +1 | ATK +2, MAG +2 | ATK +2, MAG +2 | Wearer randomly hit by Tier 1 Flame spell once per battle (friendly fire, cannot kill — leaves at 1 HP) | Caldera Forge Depths |
| Frost Veil | DEF +1, MDEF +1 | DEF +1, MDEF +1 | DEF +1, MDEF +2 | DEF +2, MDEF +2 | DEF +2, MDEF +2 | Wearer SPD -15% in battle (chilling effect on ATB gauge) | Frostcap Caverns |
| Storm Eye | SPD +1, LCK +1 | SPD +1, LCK +1 | SPD +2, LCK +1 | SPD +2, LCK +2 | SPD +2, LCK +2 | 10% chance wearer's attacks hit a random target (ally or enemy) | Windshear Peak |
| Grey Remnant | MAG +2 | MAG +3 | MAG +3 | MAG +3 | MAG +4 | HP -40 per character level-up (permanent). Wearer takes +25% Pallor damage in combat. | Pallor Wastes |

#### Special Crystals

| Crystal | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 | Special Rule | Found |
|---------|-----|-----|-----|-----|-----|-------------|-------|
| Dawn Fragment | All stats +2 | All stats +1 | All stats +1 | No bonus | No bonus | **Diminishing.** Starts incredibly strong, fades to nothing. Ancient ley energy, almost spent. Best early-game crystal if found. | Dawn March (Act I, hidden) |
| Convergence Shard | All stats +1 | All stats +1 | All stats +1 | All stats +1 | **All stats +3** | **Secret upgrade.** UI shows "???" for level 5 bonus until reached. Looks like a modest all-rounder; rewards patience with the biggest single upgrade in the game. | The Convergence |
| Null Crystal | No stat bonus | No stat bonus | No stat bonus | No stat bonus | No stat bonus | **Despair immunity.** Grants full Despair status immunity while equipped. Purely defensive — the only way to block the Pallor's signature debuff. | Dreamer's Fault (post-game) |
| Cael's Echo | ATK +1, MAG +1 | ATK +1, MAG +1 | ATK +2, MAG +2 | ATK +2, MAG +2 | ATK +2, MAG +2, SPD +1 | **Emotional resonance.** Cael's motif plays faintly in battle. Lira: +10% damage. Edren: +10% DEF. Character-specific bonuses from the bond they shared. | Post-game (Edren places sword at meadow) |

### 5.5 Crystal Availability by Act

| Act | Crystals Available | Total |
|-----|-------------------|-------|
| Act I | Ember Shard, Dawn Fragment (hidden) | 2 |
| Act II | Iron Core, Lifestone, Frost Veil | 3 |
| Interlude | Ward Stone, Quicksilver, Spirit Tear, Wellspring | 4 |
| Act III | Ley Prism, Flame Heart, Storm Eye, Grey Remnant, Convergence Shard | 5 |
| Sidequests | Fortune Stone (Sable), Forgewright Core (Lira) | 2 |
| Post-game | Null Crystal, Cael's Echo | 2 |
| **Total** | | **18** |

### 5.6 Crystal Design Notes

**Dawn Fragment (diminishing):** Found hidden during the Dawn March
tutorial. All stats +2 at crystal level 1 is the strongest early-game
crystal by far. But it peaks immediately and fades to nothing by
crystal level 4. Lore: ancient ley energy, almost exhausted. Teaches
the player that ley energy is finite — foreshadows the Pallor's
consumption of the ley lines.

**Grey Remnant (risk/reward):** Strongest raw MAG crystal (+4 at Lv5).
But -40 HP per character level-up is painful. Equipping on Maren from
level 50 to 100 = +200 bonus MAG but -2,000 max HP on the character
with the lowest HP (Maren at level 100 has ~4,010 natural HP, so she'd
drop to ~2,010 — fragile but survivable with Edren's protection).
Creates a genuine glass cannon tradeoff without being lethal.

**Convergence Shard (secret):** Looks mediocre at +1 all stats. Most
players swap it out. But ~100 battles of commitment reveals +3 all
stats — the best single crystal upgrade in the game. UI deliberately
shows "???" for the Lv5 text. Rewards patience and loyalty.

Impact modeling: if a player equips Convergence Shard at level 60 and
reaches crystal Lv5 around level 75 (after ~100 battles), the +3 all
stats applies to levels 76-150 = 75 level-ups = +225 per stat. Combined
with the +1 per stat from levels 60-75 (15 level-ups = +15 per stat),
total bonus is +240 per stat. This is powerful but balanced: it applies
to ALL stats equally (no min-maxing), requires late-game commitment,
and only becomes exceptional if the player continues past level 100.
Most players finishing the main story around level 70-80 will see
modest benefit.

**Cael's Echo (emotional payoff):** Post-game only. The character-
specific bonuses (Lira +10% damage, Edren +10% DEF) tie to their
relationships with Cael. The faint motif in battle is the real reward.

## 6. Narrative Milestone Stat Spikes

One-time permanent stat boosts tied to story moments. These reward
narrative engagement, not grinding. The player doesn't choose them —
they happen as part of the character's arc.

| Character | Event | Act | Stat Boost | Narrative Reason |
|-----------|-------|-----|-----------|-----------------|
| Edren | Survives siege, takes command | II | DEF +8, HP +200, ATK +5 | Forged in fire. Leadership born from loss. |
| Edren | Finds Cael's training sword | Interlude | ATK +3, SPD +3 | Memory of sparring. Fights sharper, faster. |
| Cael | Pallor's hidden influence | I | ATK +2, MAG +2, SPD +1 | Hidden. The Pallor's gift — player won't notice. |
| Lira | Forges first independent creation | II | MAG +5, ATK +3 | Free from Compact doctrine. Builds without limits. |
| Lira | Forges ley-weapon in final battle | III | ATK +15, MAG +10 | Greatest forging act in the game's history. |
| Torren | Spirit-bond deepens (Fenmother) | II | MAG +5, MDEF +3, HP -15% | Power gained, vitality sacrificed. Real cost. |
| Torren | Stabilizes ley nexus (reunion) | Interlude | MAG +8, SPD +4 | The ley network flows through him now. |
| Sable | Reunites full party (all 4 found) | Interlude | SPD +5, LCK +5, ATK +3 | She held everyone together. Observer became leader. |
| Sable | Opens The Pendulum tavern | Epilogue | LCK +10 | Luckiest woman alive. Post-game completionist bonus. |
| Maren | Reveals cycle history (Archive) | III | MAG +10, MP +100 | Full understanding of ancient magic. Knowledge is power. |
| Maren | First Annulment cast (100 WG) | III | MDEF +8, MAG +5 | Channeling the full Weave changed her permanently. |
| All party | Campfire scene (pre-Convergence) | III | All stats +2 | Unity. Resolve. The smallest boost mechanically, the biggest emotionally. |

**Design principles:**
- Spikes range from +2 to +15 per stat — noticeable, not game-breaking
- Every spike has a narrative justification the player witnessed
- Some have costs (Torren's -15% HP) reflecting the theme of sacrifice
- Cael's hidden boost is never explained — rewards observant replayers
- The campfire +2 all stats is shared, intimate, and memorable

**Torren's -15% HP:** At level 50 with ~2,500 HP, this costs ~375 HP
permanently. He becomes more fragile but more powerful — a healer who
needs healing. Mechanical echo of the game's sacrifice theme.

## 7. Integration with Existing Systems

### 7.1 Magic System (magic.md)

The existing formulas in magic.md use MAG and MDEF:
- `magic_damage = max(1, (caster.mag * spell.power) - target.mdef) + random(-3, 3)`
- `heal_amount = (caster.mag * spell.power * 0.8) + random(0, 5)`

With this stat system, the current formula produces extremely high
numbers:

| Level | Maren MAG | Spell Tier | Power | Raw Damage | After 60 MDEF |
|-------|-----------|-----------|-------|------------|---------------|
| 50 | 110 | Tier 2 | 35 | 3,850 | 3,790 |
| 70 | 146 | Tier 3 | 65 | 9,490 | 9,430 |
| 150 | 255 | Tier 4 | 100 | 25,500 | 25,440 |

The endgame numbers exceed the HP cap (14,999) by nearly 2x. The
formula `(MAG * power) - MDEF` has no divisor and was likely designed
for a smaller stat scale. **Gap 1.1 MUST add a divisor** (e.g.,
`(MAG * power) / 4 - MDEF`) or significantly reduce spell power tiers
to keep damage in the 100-9,999 range. This is the highest-priority
integration point between the stat system and damage formulas.

### 7.2 Abilities (abilities.md)

Existing percentage-based abilities work with this system:
- Edren's Ironwall (50% physical reduction on ally): reduces incoming
  damage by 50% after DEF calculation
- Thornveil counter (20% of DEF base, 40% evolved Deeproot Veil, 15%
  for Lira's device variant): at DEF 120 = 24/48/18 counter damage
- Mending Engine (15% max HP heal): at HP 4,000 = 600 HP per tick
- Sable's Shiv (ignores 50% DEF): halves target DEF before damage calc

### 7.3 Equipment (Gap 1.5)

Equipment bonuses are additive. A weapon might grant ATK +15 to +45
depending on tier. This means equipment is meaningful (~10-25% of a
mid-game stat) without being mandatory.

### 7.4 Ley Crystals + Level Cap Math

A player who equips a Lv5 crystal with +3 to a stat for 100 levels
gains +300 bonus. Since the stat cap is 255, this means crystal
investment matters most for secondary stats (pushing a knight's MAG
toward usable levels) rather than primary stats (which reach 255
naturally by level ~130).

## 8. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/progression.md` | Create | Canonical stat system document |
| `docs/story/characters.md` | Modify | Add base stat tables to character entries |
| `docs/analysis/game-design-gaps.md` | Modify | Update gap 1.2 status |

## 9. Out of Scope

- Damage formulas (Gap 1.1 — depends on this spec)
- Equipment stat tables (Gap 1.5 — depends on this spec)
- Enemy stats (Gap 1.3 — depends on this spec)
- XP curve (Gap 2.1 — depends on this spec)
- ATB gauge fill rate formula (Gap 2.2 — depends on SPD stat from this spec)

## 10. Open Question: Damage Formula Scaling

Section 7.1 flags that magic.md's existing formula produces very high
numbers with medium-scale stats. At MAG 110 with Tier 2 spell power 35,
raw damage is 3,850 — which would kill most mid-game enemies in one hit.

Options to resolve (for Gap 1.1):
- Add a divisor to the formula (e.g., `(mag * power) / 4 - mdef`)
- Reduce spell power tiers to match the stat scale
- Increase enemy MDEF significantly

This is explicitly deferred to Gap 1.1 (Damage Formulas) but documented
here so the stat system and formula system are designed in concert.
