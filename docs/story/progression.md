# Character Progression

> This document defines the complete numerical foundation for all
> characters: stats, growth curves, Ley Crystals, and narrative
> milestone spikes. It is the primary reference for implementing
> character progression and balancing combat encounters.
>
> **Related docs:** [characters.md](characters.md) |
> [abilities.md](abilities.md) | [magic.md](magic.md) |
> [events.md](events.md) | equipment.md (Gap 1.5) |
> enemies.md (Gap 1.3)

**Design principles at a glance:**

- **Medium scale (1-255).** Classic SNES 8-bit stat range. Every point feels meaningful.
- **Level cap 150.** Extended beyond the classic 99 — rewards dedicated players without being unreachable.
- **HP cap 14999, MP cap 1499.** 10:1 ratio matching FF6's convention.
- **Differentiated growth.** Each character levels up differently — a mage gains MP and MAG; a knight gains HP and DEF.
- **Three progression layers.** Base growth (automatic per level) + Ley Crystal bonuses (player choice) + narrative milestone spikes (story-driven).
- **Party join at average level - 1.** New and returning characters join at `party_average_level - 1`. Matches FF6's approach.

---

## Stat Definitions

### Core Stats

8 stats total. All core stats have a hard floor and hard ceiling.

| Stat | Abbr | Range | Description |
|------|------|-------|-------------|
| Hit Points | HP | 50-14999 | Health pool. 0 = Fainted (see [events.md](events.md) section 2c). |
| Magic Points | MP | 10-1499 | Fuel for spells and some abilities. |
| Attack | ATK | 1-255 | Physical damage dealt. Used by weapons and physical abilities. |
| Defense | DEF | 1-255 | Physical damage reduced. Also used by Thornveil counter (20% of DEF). |
| Magic | MAG | 1-255 | Spell damage, healing potency, status infliction rate. Primary scaling stat for magic; see [combat-formulas.md](combat-formulas.md) for full damage and healing formulas. |
| Magic Defense | MDEF | 1-255 | Spell damage reduced. Status effect resistance. |
| Speed | SPD | 1-255 | ATB gauge fill rate. Also: flee success rate, preemptive strike chance. |
| Luck | LCK | 1-255 | Critical hit chance, rare drop rate. Sable's signature stat. Note: steal success (Filch) is SPD-based — see [abilities.md](abilities.md). |

### Derived Stats

Calculated from core stats. Equipment can add flat bonuses on top of the derived value.

| Derived Stat | Formula | Cap | Notes |
|-------------|---------|-----|-------|
| Hit Rate% | `90 + (attacker.SPD - target.SPD) / 4` | 99% (min 20%) | Base 90% accuracy. Fast attackers are more accurate against slow targets. Cannot reach 100% — there is always a 1% miss chance. Floor of 20% prevents complete whiffs. |
| Evasion% | `target.SPD / 4` | 50% | Chance to dodge physical attacks after hit check passes. Equipment adds flat EVA% on top. |
| Critical% | `LCK / 4` | 50% | Chance for physical attacks to deal 2x damage. Equipment adds flat CRIT% on top. |
| Magic Evasion% | `(MDEF + SPD) / 8` | 40% | Chance to fully resist status spells (additional check — see below). Does not apply to damage spells. |

**Rounding and clamping (all derived % stats):**

1. Compute the base value from the formula using real-number division (no integer truncation).
2. Round the result down (floor) to the nearest whole percent.
3. Add any flat bonuses from equipment to this rounded base value.
4. Clamp the final value to the allowed range:
   - Hit Rate%: minimum 20%, maximum 99%.
   - Evasion%, Critical%, Magic Evasion%: minimum 0%, maximum = their listed Cap.

**Magic Evasion% and status spells — resolution order:**

Status spells use a two-stage check. First, the caster's accuracy is calculated via `effective_rate = base_rate * (caster.mag / (caster.mag + target.mdef))` (see [magic.md](magic.md)). This document extends that rule by adding a second-stage Magic Evasion% roll; where there is any discrepancy in combat resolution details, this document supersedes `magic.md`. If the accuracy check succeeds, the target then rolls their Magic Evasion% to resist the effect entirely. This means high-MDEF targets are doubly protected: the first check reduces the effective hit rate, and the MEVA% check provides a second chance to shrug it off. Damage spells skip the MEVA% check entirely — once cast, they follow the standard three-stage Hit Rate% / Evasion% / Critical% resolution described below.

### Attack Resolution Order

Three-stage check — hit rate, then evasion, then critical:

1. **Hit Rate% roll.** If hit misses, no further checks.
2. **Evasion% roll.** If hit lands, target rolls Evasion% to dodge.
3. **Critical% roll.** If not dodged, attacker rolls Critical% for 2x bonus damage.

This three-stage check creates moments of drama: a hit that lands, isn't dodged, AND crits feels earned.

### Stat Caps

| Stat | Soft Cap | Hard Cap | Notes |
|------|----------|----------|-------|
| HP | — | 14999 | Natural growth + Ley Crystal bonuses can exceed 9999 |
| MP | — | 1499 | 10:1 ratio with HP cap |
| ATK, DEF, MAG, MDEF, SPD, LCK | 255 | 255 | Natural growth hits this around level 120-140 for primary stats. Equipment and Ley Crystal bonuses cannot exceed the cap. |
| EVA% | — | 50% | Derived from SPD + equipment |
| CRIT% | — | 50% | Derived from LCK + equipment |
| MEVA% | — | 40% | Derived from MDEF + SPD |

---

## Character Growth

### Growth Rates Per Level

Each character has a growth archetype. Rates are per-level averages — actual gains alternate (e.g., +3 ATK on odd levels, +2 on even = average 2.5) to avoid monotony.

| Stat | Edren (Knight) | Cael (Commander) | Lira (Engineer) | Torren (Sage) | Sable (Thief) | Maren (Archmage) |
|------|----------------|------------------|-----------------|---------------|---------------|------------------|
| HP | +85 | +65 | +55 | +50 | +45 | +40 |
| MP | +3 | +5 | +6 | +8 | +4 | +10 |
| ATK | +1.8 | +1.5 | +1.2 | +0.8 | +1.4 | +0.5 |
| DEF | +1.6 | +1.2 | +1.0 | +0.7 | +0.6 | +0.5 |
| MAG | +0.5 | +0.8 | +1.3 | +1.5 | +0.6 | +1.8 |
| MDEF | +0.7 | +0.9 | +1.0 | +1.3 | +0.8 | +1.5 |
| SPD | +0.8 | +1.0 | +0.9 | +0.7 | +1.6 | +0.6 |
| LCK | +0.6 | +0.7 | +0.8 | +0.5 | +1.5 | +0.4 |

> **Equipment rebalance proposal (Gap 1.5):** ATK growth rates above
> are proposed for reduction (~20%) to make weapon upgrades more
> impactful throughout the game. See [equipment.md](equipment.md)
> Section "ATK Growth Adjustment" for proposed values and damage
> verification. The bestiary's enemy stat curves were designed against
> these original values — a balance pass (Gap 3.4) must verify enemy
> HP targets still hold with reduced ATK growth.

**Character identity through stats:**

- **Edren (Knight):** Highest HP by far. Highest DEF and ATK. Slowest caster. He IS the wall.
- **Cael (Commander):** Best generalist — balanced across all stats. His loss after the betrayal creates a genuine combat hole.
- **Lira (Engineer):** Hybrid ATK/MAG. Decent at both, exceptional at neither. Flexibility is her strength.
- **Torren (Sage):** High MAG, MDEF, and MP. Fragile physically. Classic white mage — essential but vulnerable.
- **Sable (Thief):** Fastest and luckiest. Paper-thin HP and DEF. Glass cannon who exploits Shiv's 50% DEF ignore.
- **Maren (Archmage):** Highest MAG and MP in the game. Lowest HP, ATK, DEF, SPD, LCK. Joins Act I and transforms the party's magical output, but needs Edren's protection.

### Base Stats at Level 1

See [characters.md](characters.md) for full character profiles.

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

### Milestones

Formula (per level): compute `raw = base + growth * (level - 1)`, then `stat_at_level = min(cap, floor(raw + 0.5))`, where the cap is 255 for primary stats, 14999 for HP, and 1499 for MP. Rounding uses standard half-up: `floor(raw + 0.5)`. This produces deterministic alternating gain patterns (e.g., +2, +2, +2, +2, +1 for a growth of 1.8) while keeping long-term growth equal to the specified average.

Projected stats exclude equipment, Ley Crystal bonuses, and narrative milestone spikes. Milestone values in the table below are computed from this rule; when in doubt, the formula above takes precedence.

| Milestone | Lvl | Edren HP | Edren ATK | Maren MAG | Sable SPD | Sable LCK |
|-----------|-----|----------|-----------|-----------|-----------|-----------|
| First level-up | 2 | 180 | 20 | 24 | — | — |
| End of Act I | ~18 | 1,540 | 49 | 53 | 45 | 42 |
| End of Act II | ~35 | 2,985 | 79 | 83 | 72 | 67 |
| Interlude end | ~50 | 4,260 | 106 | 110 | 96 | 90 |
| End of Act III | ~70 | 5,960 | 142 | 146 | 128 | 120 |
| Level cap | 150 | 12,760 | 255 | 255 | 255 | 240 |

Primary stats reach the 255 cap around level 120-140 naturally. Sable's SPD (growth 1.6) hits 255 at level ~149. LCK (growth 1.5) reaches 240 at level 150 — the only primary stat that doesn't cap naturally, rewarding LCK-boosting Ley Crystals. The last 10-30 levels are for secondary stats to catch up and for HP/MP to keep growing toward their higher ceilings.

### Join Rule

When a character joins (first recruitment or reunion), their level is set to `party_average_level - 1` (minimum: story-appropriate floor).

| Character | Join Point | Floor Level |
|-----------|-----------|-------------|
| Edren | Game start | 1 |
| Cael | Game start (with Edren) | 1 |
| Lira | Act I recruitment | 1 |
| Torren | Act I recruitment | 1 |
| Sable | Act I recruitment | 1 |
| Maren | Act I recruitment (reunites Interlude) | 1 |
| Interlude reunions | Sable finds each party member | — (uses party average - 1) |

The "-1" means the new character is always close to catching up — usually one or two battles from matching the party. This creates a satisfying early-level-up feel on every recruitment, matching FF6's approach.

### Guest NPCs

Guest NPCs (Cordwyn, Kerra, etc.) join temporarily for specific story segments. Their stats are computed from the formulas below at the start of each battle, then remain fixed for that battle — they do not level up, gain XP, or benefit from Ley Crystals.

| Guest NPC | When | Stats Rule | Notes |
|-----------|------|-----------|-------|
| Dame Cordwyn | Siege of Valdris (Act II) | Stats = party average for ATK/DEF/SPD. HP = 80% of Edren's max HP, evaluated at the start of each battle (ignores temporary damage, healing, and buffs). Fixed abilities: Shield Wall, Rally Cry. | Competent but not overpowering. Feels like a real knight fighting alongside the party. |
| Kerra | Unbowed sidequest (Interlude) | Stats = 60% of party average across all stats. HP = party average max HP * 0.5. | Intentionally fragile. Narrative weight: protecting her is the challenge. If she falls to 0 HP, she is incapacitated but survives (per [events.md](events.md)). |

Guest NPCs cannot be equipped, cannot use items, and do not earn XP. Their actions are AI-controlled (Attack + 1-2 signature abilities). They do not count toward party wipe — if all player characters Faint but a guest is standing, the wipe still triggers (per [events.md](events.md)).

> **Note:** The dynamic stat formulas above supersede the hard-coded guest NPC stats in [dungeons-world.md](dungeons-world.md) (Cordwyn: 5000 HP, ATK 85, DEF 70) and [dungeons-city.md](dungeons-city.md) (Kerra: ATK 18, DEF 14, HP 800). Those values were placeholders written before the stat system existed. The dungeon docs will be updated to reference these formulas in a future pass.

### Equipment and Buffs

- **Equipment stat bonuses are additive.** A sword with ATK +12 adds 12 to the character's ATK. Simple and transparent.
- **Equipment cannot push stats past the 255 cap** for ATK/DEF/MAG/MDEF/SPD/LCK. HP and MP can exceed their natural growth via equipment up to their hard caps (14999 / 1499).
- **Buffs and debuffs are percentage-based.** Quickstep = +50% ATB speed. Ironhide = +40% DEF (single) / +25% DEF (party). Wardglass = +40% MDEF (single) / +25% MDEF (party). These are applied to the final stat (base + equipment) and CAN temporarily exceed 255 in combat. Debuffs work the same way in reverse. See [magic.md](magic.md) for full buff/debuff spell list.
- **Buff stacking:** Buffs of the same type do not stack. Recasting Protect refreshes the duration but does not double the bonus. Different buff types stack (Protect + Shell = both active).

---

## Ley Crystal System

Ley Crystals are crystallized fragments of the ley line network — raw magical energy solidified over millennia. They serve as the game's Esper/Magicite equivalent: equip one to a character, and they gain permanent stat bonuses each time they level up.

See [dungeons-world.md](dungeons-world.md) and [dungeons-city.md](dungeons-city.md) for crystal locations within specific dungeon layouts.

### Core Mechanics

- Each character has **1 Ley Crystal slot** (separate from accessories)
- While equipped, the crystal grants permanent stat bonuses at each character level-up, based on the crystal's current level
- Crystals are **not consumed** — swappable freely outside battle
- Permanent stat gains persist after unequipping the crystal
- A character can only have one crystal equipped at a time

### Crystal Leveling

Crystals gain XP equal to **30% of the wearer's XP** after each battle. Crystals have 5 levels. At certain levels, bonuses upgrade, new bonuses unlock, or special effects trigger.

| Crystal Level | XP Required | Typical Battles |
|--------------|-------------|-----------------|
| 1 (base) | 0 | Equipped |
| 2 | 800 | ~15 battles |
| 3 | 2,500 | ~35 battles |
| 4 | 6,000 | ~60 battles |
| 5 | 15,000 | ~100 battles |

### Crystal Catalog (18 Crystals)

#### Standard Crystals

| Crystal | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 | Found |
|---------|-----|-----|-----|-----|-----|-------|
| Ember Shard | ATK +1 | ATK +1 | ATK +2 | ATK +2 | ATK +2, DEF +1 | Ember Vein — Floor 4: The Pendulum Chamber |
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
| Cael's Echo | ATK +1, MAG +1 | ATK +1, MAG +1 | ATK +2, MAG +2 | ATK +2, MAG +2 | ATK +2, MAG +2, SPD +1 | **Emotional resonance.** Cael's motif plays faintly in battle (see [music.md](music.md)). Lira: +10% damage. Edren: +10% DEF. Character-specific bonuses from the bond they shared. | Post-game (Edren places sword at meadow) |

### Crystal Availability by Act

| Act | Crystals Available | Total |
|-----|-------------------|-------|
| Act I | Ember Shard, Dawn Fragment (hidden) | 2 |
| Act II | Iron Core, Lifestone, Frost Veil | 3 |
| Interlude | Ward Stone, Quicksilver, Spirit Tear, Wellspring, Ley Prism | 5 |
| Act III | Flame Heart, Storm Eye, Grey Remnant, Convergence Shard | 4 |
| Sidequests | Fortune Stone (Sable), Forgewright Core (Lira) | 2 |
| Post-game | Null Crystal, Cael's Echo | 2 |
| **Total** | | **18** |

### Crystal Design Notes

**Dawn Fragment (diminishing):** Found hidden during the Dawn March tutorial. All stats +2 at crystal level 1 is the strongest early-game crystal by far. But it peaks immediately and fades to nothing by crystal level 4. Lore: ancient ley energy, almost exhausted. Teaches the player that ley energy is finite — foreshadows the Pallor's consumption of the ley lines.

**Grey Remnant (risk/reward):** Strongest raw MAG crystal (+4 at Lv5). But -40 HP per character level-up is painful. Equipping on Maren from level 50 to 100: the crystal starts at Lv1 (+2 MAG) and must be leveled through battles to reach Lv5 (+4 MAG). Assuming the crystal reaches Lv5 early in the range, the total bonus is approximately +160-200 MAG over 50 levels, with -2,000 max HP. Maren at level 100 has ~4,010 natural HP, so she'd drop to ~2,010-2,050 — fragile but survivable with Edren's protection. Creates a genuine glass cannon tradeoff without being lethal.

**Convergence Shard (secret):** Looks mediocre at +1 all stats. Most players swap it out. But ~100 battles of commitment reveals +3 all stats — the best single crystal upgrade in the game. UI deliberately shows "???" for the Lv5 text. Rewards patience and loyalty.

Impact modeling: if a player equips Convergence Shard at level 60 and reaches crystal Lv5 around level 75 (after ~100 battles), the +3 all stats applies to levels 76-150 = 75 level-ups = +225 per stat. Combined with the +1 per stat from levels 60-75 (15 level-ups = +15 per stat), total bonus is +240 per stat. This is powerful but balanced: it applies to ALL stats equally (no min-maxing), requires late-game commitment, and only becomes exceptional if the player continues past level 100. Most players finishing the main story around level 70-80 will see modest benefit.

**Cael's Echo (emotional payoff):** Post-game only. The character-specific bonuses (Lira +10% damage, Edren +10% DEF) tie to their relationships with Cael. The faint motif in battle is the real reward.

---

## Narrative Milestone Stat Spikes

One-time permanent stat boosts tied to story moments. These reward narrative engagement, not grinding. The player doesn't choose them — they happen as part of the character's arc. See [events.md](events.md) for the story events that trigger each spike.

| Character | Event | Act | Stat Boost | Narrative Reason |
|-----------|-------|-----|-----------|-----------------|
| Edren | Survives siege, takes command | II | DEF +8, HP +200, ATK +5 | Forged in fire. Leadership born from loss. |
| Edren | Finds Cael's training sword | Interlude | ATK +3, SPD +3 | Memory of sparring. Fights sharper, faster. |
| Cael | Pallor's hidden influence | I | ATK +2, MAG +2, SPD +1 | Hidden. The Pallor's gift — player won't notice. |
| Lira | Forges first independent creation | II | MAG +5, ATK +3 | Free from Compact doctrine. Builds without limits. |
| Lira | Forges ley-weapon in final battle | III | ATK +15, MAG +10 | Greatest forging act in the game's history. |
| Torren | Spirit-bond deepens (Fenmother) | II | MAG +5, MDEF +3 | Deeper connection to the spirit world. |
| Torren | Self-sacrifice at ley nexus (reunion) | Interlude | MAG +8, SPD +4, HP -15% | Burned his life force holding back the corruption. Power gained, vitality sacrificed. Real cost. |
| Sable | Reunites full party (all 4 found) | Interlude | SPD +5, LCK +5, ATK +3 | She held everyone together. Observer became leader. |
| Sable | Opens The Pendulum tavern | Epilogue | LCK +10 | Luckiest woman alive. Post-game completionist bonus. |
| Maren | Reveals cycle history (Archive) | Interlude | MAG +10, MP +100 | Full understanding of ancient magic. Knowledge is power. |
| Maren | First Annulment cast (100 WG) | III | MDEF +8, MAG +5 | Channeling the full Weave changed her permanently. |
| All party | Campfire scene (pre-Convergence) | III | All stats +2 | Unity. Resolve. The smallest boost mechanically, the biggest emotionally. |

**Design principles:**
- Spikes range from +2 to +15 per stat — noticeable, not game-breaking
- Every spike has a narrative justification the player witnessed
- Some have costs (Torren's -15% HP) reflecting the theme of sacrifice
- Cael's hidden boost is never explained — rewards observant replayers
- The campfire +2 all stats is shared, intimate, and memorable

**Torren's -15% HP:** At level 50 with ~2,500 HP, this costs ~375 HP permanently. He becomes more fragile but more powerful — a healer who needs healing. Mechanical echo of the game's sacrifice theme.

---

## Integration Notes

### Magic System ([magic.md](magic.md))

The existing formulas in magic.md use MAG and MDEF:
- `magic_damage = max(1, (caster.mag * spell.power) - target.mdef) + random(-3, 3)`
- `heal_amount = (caster.mag * spell.power * 0.8) + random(0, 5)`

> **Resolved (Gap 1.1):** The divisor approach was adopted. The canonical
> magic damage formula is now: `min(14999, max(1, (MAG * spell_power) / 4 - MDEF)
> * element_mod * variance)`. See [combat-formulas.md](combat-formulas.md)
> for the complete formula reference, including the physical damage
> formula, critical hits, ability multipliers, and combat interactions.

With the `/4` divisor, endgame damage stays well within the 14,999 damage cap:

| Level | Maren MAG | Spell Tier | Power | Raw Damage | After 60 MDEF |
|-------|-----------|-----------|-------|------------|---------------|
| 50 | 110 | Tier 2 | 35 | 963 | 903 |
| 70 | 146 | Tier 3 | 65 | 2,373 | 2,313 |
| 150 | 255 | Tier 4 | 100 | 6,375 | 6,315 |

### Abilities ([abilities.md](abilities.md))

Existing percentage-based abilities work with this system:
- Edren's Ironwall (50% physical reduction on ally): reduces incoming damage by 50% after DEF calculation
- Thornveil counter (20% of DEF base, 40% evolved Deeproot Veil, 15% for Lira's device variant): at DEF 120 = 24/48/18 counter damage
- Mending Engine (15% max HP heal): at HP 4,000 = 600 HP per tick
- Sable's Shiv (ignores 50% DEF): halves target DEF before damage calc

### Equipment (equipment.md, Gap 1.5)

Equipment bonuses are additive. A weapon might grant ATK +15 to +45 depending on tier. This means equipment is meaningful (~10-25% of a mid-game stat) without being mandatory.

### Ley Crystals and Level Cap Math

A player who equips a Lv5 crystal with +3 to a stat for 100 levels has a theoretical +300 pre-cap bonus; in practice, each level-up's crystal bonus is clamped by the 255 stat cap. Since primary stats reach 255 naturally by around level 130, crystal investment matters most for secondary stats (e.g., pushing a knight's MAG toward usable levels) rather than overcapping primaries.
