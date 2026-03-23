# Optional Bestiary

Enemies encountered in post-game optional content: Dreamer's Fault
(20-floor super dungeon). See [README.md](README.md) for type rules,
stat formulas, and reward calculations.

**Total:** 24 stat-block enemies across 5 ages + 1 non-combat encounter

> **Level classification:** Floors 1--12 (Lv 42--70) fall within the
> Post-game range (40--80). Floors 13--20 (Lv 74--100) fall within the
> Optional/Superboss range (70--150). Echo Boss HP (40K--100K) exceeds
> the main-story boss range (6K--70K).

---

## The Dreamer's Fault

Post-game super dungeon. 20 floors, 5 ages. A crack between reality
and the Pallor's domain -- echoes of every civilization the Grey
consumed. Entry via The Pendulum tavern cellar.

---

## The First Age -- Ancient Stone (Floors 1--4, Lv 42--48)

A civilization of scholar-builders. Geometric architecture,
glyph-based magic, stone guardians. Floor rotation mechanic.

> **Item note:** Steal/drop items (Ancient Glyph, Carved Stone) are
> **Gap 1.4 placeholders** -- names, effects, and crafting recipes are
> TBD pending Item Catalog design.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| First Age Sentinel | Construct | 42 | 4,253 | 0 | 75 | 63 | 64 | 46 | 31 | 279 | 462 | Ancient Glyph (75%) | Carved Stone (25%) | — | — | — | Poison, Sleep, Confusion, Berserk, Despair | Dreamer's Fault F1--4 |
| Glyphscribe | Humanoid | 44 | 4,032 | 154 | 60 | 57 | 77 | 48 | 43 | 324 | 530 | Ancient Glyph (75%) | Carved Stone (25%) | — | — | — | — | Dreamer's Fault F1--4 |
| Carved Watcher | Construct | 46 | 4,380 | 0 | 81 | 60 | 70 | 50 | 44 | 374 | 607 | Ancient Glyph (75%) | Carved Stone (25%) | — | — | — | Poison, Sleep, Confusion, Berserk, Despair | Dreamer's Fault F1--4 |
| Ember Remnant | Elemental | 48 | 3,414 | 168 | 96 | 44 | 73 | 52 | 46 | 433 | 696 | Ancient Glyph (75%) | Carved Stone (25%) | Frost | — | Flame | Petrify | Dreamer's Fault F1--4 |
| *The First Scholar* | Boss | 50 | 40,000 | 175 | 132 | 84 | 136 | 81 | 57 | 10,000 | 15,000 | Ancient Manuscript (100%) | Scholar's Codex (100%) | Void (150%) | Spirit (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F4 |

**Design notes:**
- First Age Sentinel is a stone guardian (Construct, Tank role). Geometric
  attacks that change based on facing when the floor rotates. Heavy armor,
  slow. MP=0 per Construct type rules.
- Glyphscribe is a scholar-soldier (Humanoid, Caster role). Writes attack
  glyphs in the air -- each charges for 1 turn, then fires. Interruptible.
- Carved Watcher is a stone face that detaches from the wall (Construct,
  Balanced role). Tracks party movement -- stronger when party is stationary.
- Ember Remnant is a dying flame from the First Age's collapse (Elemental,
  Glass cannon role). High ATK, fragile. Self-destructs for massive AoE on
  death. Absorbs Flame inherently (Elemental type + Flame element). Weak to
  Frost (counter-element).

### The First Scholar (Echo Boss -- Floor 4)

> **Note:** docs/story/dungeons-world.md is authoritative for phase
> mechanics. The following summarizes.

- **HP:** 40,000 (hand-tuned) | **Type:** Boss | **Level:** 50
- **Mechanic: Spell Pattern Rotation.** Casts in a fixed 4-spell
  rotation (Glyph of Flame, Glyph of Frost, Glyph of Storm, Glyph
  of Void). Each glyph telegraphs with a symbol 1 turn in advance.
  Players who learn the pattern can pre-buff/defend.
- **Phase 1 (40,000--20,000 HP):** 4-spell rotation, moderate damage.
- **Phase 2 (below 20,000 HP):** Rotation doubles speed -- 2 spells
  per turn. Same pattern, twice as fast.
- **The test:** Pattern recognition and preparation.
- **Weakness:** Void (150%)
- **Resistance:** Spirit (50%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Ancient Manuscript (100%)
- **Drop:** Scholar's Codex (100%) -- accessory, MAG +25, Arcanum
  boost. **TODO: finalize stat block in Gap 1.5 (Equipment).**

---

## The Crystal Age -- Alien Crystal (Floors 5--8, Lv 52--58)

An alien civilization that grew from crystal. Light-based technology.
Light/shadow visibility mechanic.

> **Item note:** Steal/drop items (Crystal Fragment, Prism Shard) are
> **Gap 1.4 placeholders** -- names, effects, and crafting recipes are
> TBD pending Item Catalog design.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Crystal Refractor | Elemental | 52 | 5,511 | 182 | 70 | 67 | 89 | 56 | 49 | 576 | 913 | Crystal Fragment (75%) | Prism Shard (25%) | Earth | — | Ley | Petrify | Dreamer's Fault F5--8 |
| Facet Drone | Construct | 54 | 4,022 | 0 | 94 | 69 | 81 | 58 | 51 | 664 | 1,045 | Crystal Fragment (75%) | Prism Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Dreamer's Fault F5--8 |
| Prism Stalker | Beast | 56 | 4,561 | 196 | 111 | 51 | 84 | 60 | 52 | 764 | 1,194 | Crystal Fragment (75%) | Prism Shard (25%) | — | — | — | — | Dreamer's Fault F5--8 |
| Resonance Shade | Spirit | 58 | 6,771 | 203 | 77 | 74 | 100 | 62 | 54 | 877 | 1,365 | Crystal Fragment (75%) | Prism Shard (25%) | Ley | — | — | Poison, Petrify | Dreamer's Fault F5--8 |
| *The Crystal Queen* | Boss | 60 | 60,000 | 210 | 156 | 100 | 162 | 96 | 67 | 15,000 | 20,000 | Queen's Prism (100%) | Queen's Facet (100%) | Earth (150%) | Ley (75%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F8 |

**Design notes:**
- Crystal Refractor is a prism creature (Elemental, Caster role). Reflects
  single-target spells back at caster at 50%. Only AoE or physical bypasses.
  Absorbs Ley inherently (Elemental type + Ley element). Weak to Earth
  (counter-element).
- Facet Drone is a small crystalline automaton (Construct, Swarm role).
  Splits into 2 when hit with magic -- physical attacks only. Reduced HP
  from Swarm role. MP=0 per Construct type rules.
- Prism Stalker is a predator of living crystal (Beast, Glass cannon role).
  Invisible in light, visible in shadow (ties to floor mechanic). Ambush
  specialist. High ATK, fragile.
- Resonance Shade is a sound given form (Spirit, Caster role). Attacks
  with dissonant frequencies. Inflicts Silence. Physical damage reduced
  50% (Spirit type).

### The Crystal Queen (Echo Boss -- Floor 8)

> **Note:** docs/story/dungeons-world.md is authoritative for phase
> mechanics. The following summarizes.

- **HP:** 60,000 (hand-tuned) | **Type:** Boss | **Level:** 60
- **Mechanic: Reflection.** All single-target damage reflected back
  at attacker at 50%. Only AoE and multi-target abilities bypass.
  Healing the Queen damages her (reversed).
- **Phase 1 (60,000--30,000 HP):** Reflection at 50%. Crystal shards
  (physical) and prismatic beams (magic).
- **Phase 2 (below 30,000 HP):** Shatters into 4 Crystal Aspects
  (15,000 HP each). Each Aspect reflects a different element. Kill
  all 4 to end the fight.
- **The test:** Party composition and AoE strategy.
- **Weakness:** Earth (150%)
- **Resistance:** Ley (75%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Queen's Prism (100%)
- **Drop:** Queen's Facet (100%) -- accessory, reflects 25% magic
  damage passively. **TODO: finalize stat block in Gap 1.5 (Equipment).**

---

## The Green Age -- Living Wood (Floors 9--12, Lv 62--70)

A civilization that merged with nature. Living architecture,
symbiotic organisms. Shifting path mechanic.

> **Item note:** Steal/drop items (Living Bark, Heartwood Splint) are
> **Gap 1.4 placeholders** -- names, effects, and crafting recipes are
> TBD pending Item Catalog design.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Root Weaver | Elemental | 62 | 8,835 | 217 | 107 | 90 | 92 | 66 | 44 | 1,151 | 1,777 | Living Bark (75%) | Heartwood Splint (25%) | Flame | — | Earth | Petrify | Dreamer's Fault F9--12 |
| Bough Knight | Humanoid | 64 | 8,160 | 224 | 110 | 81 | 95 | 68 | 59 | 1,314 | 2,025 | Living Bark (75%) | Heartwood Splint (25%) | — | — | — | — | Dreamer's Fault F9--12 |
| Canopy Lurker | Beast | 66 | 6,229 | 231 | 129 | 60 | 98 | 70 | 60 | 1,495 | 2,304 | Living Bark (75%) | Heartwood Splint (25%) | — | — | — | — | Dreamer's Fault F9--12 |
| Heartwood Spirit | Spirit | 70 | 9,680 | 245 | 92 | 89 | 119 | 74 | 64 | 2,881 | 4,455 | Living Bark (75%) | Heartwood Splint (25%) | Ley | — | — | Poison, Petrify | Dreamer's Fault F9--12 |
| *The Rootking* | Boss | 72 | 80,000 | 252 | 184 | 118 | 190 | 114 | 78 | 20,000 | 25,000 | Living Root (100%) | Root Crown (100%) | Flame (150%) | Earth (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F12 |

**Design notes:**
- Root Weaver is a living vine construct (Elemental, Tank role). Entangles
  party members. Regenerates HP each turn from the living floor. Absorbs
  Earth inherently (Elemental type + Earth element). Weak to Flame
  (counter-element). High HP and DEF from Tank role.
- Bough Knight is an armored warrior grown from wood (Humanoid, Balanced
  role). Shield blocks one attack per turn, then counter-attacks.
- Canopy Lurker is a predator in the shifting canopy (Beast, Glass cannon
  role). Drops from above -- always preemptive strike. Very fast, very
  fragile. High ATK, reduced HP/DEF.
- Heartwood Spirit is one of the Green Age's surviving nature spirits
  (Spirit, Caster role). Heals other enemies -- must be killed first.
  **Rare threat (x1.5 rewards)** -- deliberately scarce. All other Green
  Age enemies use Dangerous (x1.0).

### The Rootking (Echo Boss -- Floor 12)

> **Note:** docs/story/dungeons-world.md is authoritative for phase
> mechanics. The following summarizes.

- **HP:** 80,000 (hand-tuned) | **Type:** Boss | **Level:** 72
- **Mechanic: Regeneration + Summons.** Regenerates 2,000 HP/turn.
  Summons Root Weavers every 3 turns. Only way to stop regen: destroy
  Root Anchor (hidden targetable part, 10,000 HP, appears every 5
  turns for 2 turns).
- **Phase 1 (80,000--40,000 HP):** Moderate regen (2,000/turn), light
  summons.
- **Phase 2 (below 40,000 HP):** Regen doubles to 4,000 HP/turn.
  Summons every 2 turns. Root Anchor appears every 4 turns. Desperate.
- **The test:** Sustained DPS and add management.
- **Weakness:** Flame (150%)
- **Resistance:** Earth (50%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Living Root (100%)
- **Drop:** Root Crown (100%) -- accessory, HP regen 3%/turn.
  **TODO: finalize stat block in Gap 1.5 (Equipment).**

---

## The Iron Age -- Twisted Metal (Floors 13--16, Lv 74--84)

A civilization of engineers who built machines to stop the Pallor --
the machines outlived them. Gravity reversal mechanic.

> **Item note:** Steal/drop items (Iron Cog, Tempered Plate) are
> **Gap 1.4 placeholders** -- names, effects, and crafting recipes are
> TBD pending Item Catalog design.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Iron Automaton | Construct | 74 | 12,378 | 0 | 126 | 106 | 109 | 78 | 52 | 2,433 | 3,803 | Iron Cog (75%) | Tempered Plate (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Dreamer's Fault F13--16 |
| Gear Wraith | Spirit | 78 | 11,907 | 273 | 101 | 98 | 132 | 82 | 70 | 3,030 | 4,828 | Iron Cog (75%) | Tempered Plate (25%) | Ley | — | — | Poison, Petrify | Dreamer's Fault F13--16 |
| Pressure Golem | Construct | 80 | 12,500 | 0 | 136 | 101 | 118 | 84 | 72 | 3,357 | 5,419 | Iron Cog (75%) | Tempered Plate (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Dreamer's Fault F13--16 |
| Scrap Swarm | Construct | 84 | 9,335 | 0 | 142 | 105 | 123 | 88 | 75 | 4,059 | 6,766 | Iron Cog (75%) | Tempered Plate (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Dreamer's Fault F13--16 |
| *The Iron Warden* | Boss | 86 | 100,000 | 301 | 217 | 140 | 226 | 135 | 91 | 25,000 | 30,000 | Warden's Blueprint (100%) | Warden's Core (100%) | Storm (150%) | Flame (50%), Frost (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F16 |

**Design notes:**
- Iron Automaton is a mechanical soldier (Construct, Tank role). Heaviest
  armor in the game. **Immune to magic** -- physical attacks only. Slow
  but devastating. This is a per-enemy design exception layered on top of
  normal Construct rules (the MAG stat is retained for MDEF derivation).
  MP=0 per Construct type rules.
- Gear Wraith is a ghost trapped in machinery (Spirit, Caster role). Phases
  between solid (physical vulnerable) and spectral (magic vulnerable) on
  alternating turns. Physical damage reduced 50% during spectral phase
  (Spirit type).
- Pressure Golem is a steam-powered war machine (Construct, Balanced role).
  Builds pressure each turn -- vents massive AoE every 4 turns. Destroy
  the pressure valve (targetable part) to prevent. MP=0 per Construct
  type rules.
- Scrap Swarm is a shrapnel cloud (Construct, Swarm role). Hits entire
  party every turn. Low individual HP (Swarm -32%) but reconstitutes from
  destroyed Iron Automaton parts. MP=0 per Construct type rules.

### The Iron Warden (Echo Boss -- Floor 16)

> **Note:** docs/story/dungeons-world.md is authoritative for phase
> mechanics. The following summarizes.

- **HP:** 100,000 (hand-tuned) | **Type:** Boss | **Level:** 86
- **Mechanic: Counter Defense.** Physical attacks are countered.
  Magic triggers a shield that absorbs the next magic attack. Must
  alternate: physical -> magic -> physical -> magic.
- **Phase 1 (100,000--50,000 HP):** Strict counter pattern. Rewards
  disciplined alternation.
- **Phase 2 (50,000--25,000 HP):** Summons 2 Gear Wraiths. Counter
  pattern applies to summons -- hitting wrong target triggers
  party-wide counterattack.
- **Phase 3 (below 25,000 HP):** Overclocks. 2 actions per turn.
  Counter window shrinks. The machine is failing.
- **The test:** Tactical discipline under escalating pressure.
- **The true final boss of the game.**
- **Weakness:** Storm (150%)
- **Resistance:** Flame (50%), Frost (50%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Warden's Blueprint (100%)
- **Drop:** Warden's Core (100%) -- accessory, counter-attack on
  physical hit. **TODO: finalize stat block in Gap 1.5 (Equipment).**

---

## The Void -- Pure Grey (Floors 17--20, Lv 88--100)

The Pallor's domain. No map -- navigate by sound. Familiar Pallor
Tier 4 variants at amplified power levels. The Grey kept what it
consumed from every age.

> **Item note:** Steal/drop items (Pallor Sample, Grey Residue) are
> **Gap 1.4 placeholders** -- names, effects, and crafting recipes are
> TBD pending Item Catalog design.

> **Void deployment note:** Pallor Drake (projected Lv 50), Pallor
> Wolf (projected Lv 45), and Pallor Lurker (projected Lv 46) appear
> at Lv 90--96 -- massively above their palette-families projections.
> The Void amplifies Pallor entities. Stats are computed from the
> Void deployment level. Threat level is preserved per the README
> early deployment rule.

> **Pallor type rules:** All Void enemies are Pallor type -- Weak to
> Spirit, Immune to Despair and Death. Pallor regen (2% max HP/turn)
> activates while any party member has Despair status. Resist Void is
> a per-enemy value from palette-families (Tier 4 family variants
> only), NOT a Pallor type default. Void Walker (unique, non-family)
> does NOT resist Void -- it IS the Void.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Pallor Drake | Pallor | 90 | 15,680 | 315 | 152 | 113 | 132 | 94 | 80 | 7,768 | 13,797 | Pallor Sample (75%) | Grey Residue (25%) | Spirit | Void | — | Despair, Death | Dreamer's Fault F17--20 |
| Pallor Wolf | Pallor | 92 | 16,359 | 322 | 155 | 115 | 134 | 96 | 81 | 8,331 | 15,163 | Pallor Sample (75%) | Grey Residue (25%) | Spirit | Void | — | Despair, Death | Dreamer's Fault F17--20 |
| Pallor Lurker | Pallor | 96 | 17,760 | 336 | 161 | 120 | 140 | 100 | 84 | 9,421 | 18,075 | Pallor Sample (75%) | Grey Residue (25%) | Spirit | Void | — | Despair, Death | Dreamer's Fault F17--20 |
| Void Walker | Pallor | 100 | 19,220 | 350 | 168 | 125 | 146 | 104 | 88 | 6,954 | 14,100 | Pallor Sample (75%) | Grey Residue (25%) | Spirit | — | — | Despair, Death | Dreamer's Fault F17--20 |

**Design notes:**
- Pallor Drake (Drake family Tier 4, Rare threat x1.5). Full nightmare
  power. Wings fused, breath weapon is pure annihilation. Resist Void
  per palette-families Tier 4 element shift.
- Pallor Wolf (Wolf family Tier 4, Rare threat x1.5). Fused-leg pack
  hunters. Hunt in groups of 3 -- coordinated howl applies party-wide
  Despair. Resist Void per palette-families Tier 4 element shift.
- Pallor Lurker (Lurker family Tier 4, Rare threat x1.5). Eyeless,
  senses hope. In the lightless Void, they are everywhere. Highest
  non-boss SPD in the game. Resist Void per palette-families Tier 4
  element shift.
- Void Walker (unique, Dangerous threat x1.0). The Dreamer's Fault
  signature enemy. Featureless grey shape. Drains HP, MP, ATK, and DEF
  simultaneously. The Pallor distilled. **Does NOT resist Void** -- it
  IS the Void, not a corrupted family variant. **Pallor regen at Lv 100:
  2% of 19,220 HP = 384 HP/turn** -- extremely punishing if any party
  member has Despair status.

---

## Cael's Echo (Floor 20 -- Non-Combat)

Not a fight. The party reaches the bottom of the Dreamer's Fault
and finds an echo of Cael sitting at a table, drinking tea.

> "It's heavy. But the door is closed. Go home."

The party can examine echoes of every age -- brief vignettes of
the civilizations that fell. Then the party leaves.

**Reward:** Dreamer's Crest (accessory -- +30 all stats, best in
game). **TODO: finalize stat block in Gap 1.5 (Equipment).**

---

## Dreamer's Fault Summary

- **Total:** 24 stat-block enemies + 1 non-combat encounter
- **Level range:** 42--100 (Post-game through Optional/Superboss)
- **Type distribution:** Construct (30%), Spirit (17%), Elemental (17%),
  Humanoid (8%), Beast (8%), Pallor (17%), Boss (4 Echo Bosses)
- **Echo Bosses:** 4 combat (escalating 40K--100K HP) + 1 non-combat
  (Cael's Echo)
- **Unique age materials:** 5 steal + 5 drop items (TODO Gap 1.4)
- **Best-in-game accessories:** 5 Echo Boss rewards (TODO Gap 1.5)
- **True final boss:** The Iron Warden (100,000 HP, Lv 86)
- **Hardest regular enemy:** Void Walker (Lv 100, 19,220 HP,
  384 HP/turn Pallor regen)
