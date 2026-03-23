# Bestiary Dreamer's Fault Design Spec (Gap 1.3, Sub-project 3b)

> **Scope:** Post-game super dungeon enemy bestiary — 20 floors across
> 5 ages, 20 regular enemies, 4 Echo Bosses, 1 non-combat encounter.
>
> **Target:** 24 stat-block enemies (20 regular + 4 Echo Bosses)
> plus 1 non-combat encounter (Cael's Echo, Floor 20)
>
> **Files requiring changes:**
> - `docs/story/bestiary/optional.md` — Rewrite (from TBD)
> - `docs/story/bestiary/palette-families.md` — No new families; Void
>   enemies are existing Tier 4 at amplified levels (deployment notes)
> - `docs/story/bestiary/CONTINUATION.md` — Update Sub-project 3b status
> - `docs/story/bestiary/README.md` — Update index
> - `docs/analysis/game-design-gaps.md` — Check off optional items

---

## 1. Design Pillars

### 1.1 Each Age Is Its Own World

The Dreamer's Fault is a crack between reality and the Pallor's
domain. Each 4-floor age is an echo of a civilization the Grey
consumed in a previous cycle. Enemies belong to THAT civilization,
not the current world. No palette swaps between ages. No connection
to existing families.

### 1.2 The Void Is the Callback

The final 4 floors (17–20) are the Pallor's domain. Here, familiar
Pallor Tier 4 variants appear at levels FAR above their palette-
families projections — the Grey amplifies everything in its own
territory. This creates an "it followed us here" moment.

### 1.3 Bosses Test Disciplines

Each Echo Boss tests a specific combat skill:
- The First Scholar: pattern recognition (learn the spell rotation)
- The Crystal Queen: party composition (AoE only, reflection)
- The Rootking: sustained DPS (burn the heal, manage adds)
- The Iron Warden: tactical discipline (alternating attack types)

### 1.4 Accelerating Difficulty

Level curve accelerates — gentle start, brutal finish:
- First Age: Lv 42–48 (accessible to players fresh from Act III)
- Crystal Age: Lv 52–58 (requires some post-game grinding)
- Green Age: Lv 62–70 (serious investment needed)
- Iron Age: Lv 74–84 (endgame builds only)
- The Void: Lv 88–100 (the hardest regular enemies in the game)

Players at max level (150) will find the dungeon challenging but
achievable. Players entering at 40–50 will be severely tested.

> **README classification:** Floors 1–12 (Lv 42–70) fall within the
> Post-game range (40–80). Floors 13–20 (Lv 74–100) fall within the
> Optional/Superboss range (70–150). The dungeon entry level (40–50
> per dungeons-world.md) is the access threshold, not the completion
> level. Echo Boss HP (40K–100K) exceeds the README illustrative
> Boss HP range (6K–70K), which describes main-story bosses only.

### 1.5 No New Families

The Dreamer's Fault introduces zero new palette-swap families.
Age enemies are unique (no family lineage). Void enemies are
existing Tier 4 deployed at amplified levels.

---

## 2. Level Scaling

| Age | Floors | Enemy Levels | Echo Boss Lv | Echo Boss HP |
|-----|--------|-------------|--------------|--------------|
| First Age | 1–4 | 42–48 | 50 | 40,000 |
| Crystal Age | 5–8 | 52–58 | 60 | 60,000 |
| Green Age | 9–12 | 62–70 | 72 | 80,000 |
| Iron Age | 13–16 | 74–84 | 86 | 100,000 |
| The Void | 17–20 | 88–100 | — | — (non-combat) |

---

## 3. Enemy Roster by Age

### 3.1 The First Age (Floors 1–4, Lv 42–48) — Ancient Stone

A civilization of scholar-builders. Geometric architecture,
glyph-based magic, stone guardians. Floor rotation mechanic.

| Name | Lv | Type | Threat | Role | Description |
|------|----|------|--------|------|-------------|
| First Age Sentinel | 42 | Construct | Dangerous | Tank | Stone guardian. Geometric attacks. Rotates facing when floor rotates — attacks change based on facing. |
| Glyphscribe | 44 | Humanoid | Dangerous | Caster | Scholar-soldier. Writes attack glyphs in the air. Each glyph charges for 1 turn, then fires. Interruptible. |
| Carved Watcher | 46 | Construct | Dangerous | Balanced | A carved face in the wall that detaches. Tracks party movement. Stronger when the party is stationary. Animated stone — not a spirit. |
| Ember Remnant | 48 | Elemental | Dangerous | Glass cannon | Dying flame from the First Age's collapse. High ATK, fragile. Self-destructs for massive AoE on death. |

### 3.2 The Crystal Age (Floors 5–8, Lv 52–58) — Alien Crystal

An alien civilization that grew from crystal. Light-based
technology. Light/shadow visibility mechanic.

| Name | Lv | Type | Threat | Role | Description |
|------|----|------|--------|------|-------------|
| Crystal Refractor | 52 | Elemental | Dangerous | Caster | Prism creature. Reflects single-target spells back at caster at 50%. Only AoE or physical bypasses. |
| Facet Drone | 54 | Construct | Dangerous | Swarm | Small crystalline automaton. Splits into 2 when hit with magic. Physical attacks only. |
| Prism Stalker | 56 | Beast | Dangerous | Glass cannon | Predator of living crystal. Invisible in light, visible in shadow (ties to floor mechanic). Ambush specialist. |
| Resonance Shade | 58 | Spirit | Dangerous | Caster | A sound given form. Attacks with dissonant frequencies. Inflicts Silence. |

### 3.3 The Green Age (Floors 9–12, Lv 62–70) — Living Wood

A civilization that merged with nature. Living architecture,
symbiotic organisms. Shifting path mechanic.

| Name | Lv | Type | Threat | Role | Description |
|------|----|------|--------|------|-------------|
| Root Weaver | 62 | Elemental | Dangerous | Tank | Living vine construct. Entangles party members. Regenerates HP each turn from the living floor. |
| Bough Knight | 64 | Humanoid | Dangerous | Balanced | Armored warrior grown from wood. Shield blocks one attack per turn, then counter-attacks. |
| Canopy Lurker | 66 | Beast | Dangerous | Glass cannon | Predator in the shifting canopy. Drops from above — always preemptive strike. Very fast, very fragile. |
| Heartwood Spirit | 70 | Spirit | Rare | Caster | The Green Age's nature spirits, still alive. Heals other enemies. Must be killed first. |

### 3.4 The Iron Age (Floors 13–16, Lv 74–84) — Twisted Metal

A civilization of engineers who built machines to stop the
Pallor — the machines outlived them. Gravity reversal mechanic.

| Name | Lv | Type | Threat | Role | Description |
|------|----|------|--------|------|-------------|
| Iron Automaton | 74 | Construct | Dangerous | Tank | Mechanical soldier. Heaviest armor in the game. Immune to magic. Physical only. Slow but devastating. |
| Gear Wraith | 78 | Spirit | Dangerous | Caster | Ghost trapped in machinery. Phases between solid (physical vulnerable) and spectral (magic vulnerable) on alternating turns. |
| Pressure Golem | 80 | Construct | Dangerous | Balanced | Steam-powered war machine. Builds pressure each turn — vents massive AoE every 4 turns. Destroy the pressure valve (targetable part) to prevent. |
| Scrap Swarm | 84 | Construct | Dangerous | Swarm | Shrapnel cloud. Hits entire party every turn. Low individual HP but reconstitutes from destroyed Iron Automaton parts. |

### 3.5 The Void (Floors 17–20, Lv 88–100) — Pure Grey

The Pallor's domain. No map. Navigate by sound. Familiar
Pallor Tier 4 variants at amplified power levels — the Grey
kept what it consumed from every age.

| Name | Family | Tier | Lv | Type | Threat | Description |
|------|--------|------|----|------|--------|-------------|
| Pallor Drake | Drake | 4 | 90 | Pallor | Rare | Full nightmare power. Wings fused, breath weapon is pure annihilation. |
| Pallor Wolf | Wolf | 4 | 92 | Pallor | Rare | Fused-leg pack hunters. Hunt in groups of 3 — coordinated howl applies party-wide Despair. |
| Pallor Lurker | Lurker | 4 | 96 | Pallor | Rare | Eyeless, senses hope. In the lightless Void, they are everywhere. Highest non-boss SPD in the game. |
| Void Walker | — (unique) | — | 100 | Pallor | Dangerous | The Dreamer's Fault signature enemy. Featureless grey shape. Drains HP, MP, ATK, and DEF simultaneously. The Pallor distilled. |

**Void deployment note:** Pallor Drake (projected Lv 50), Pallor
Wolf (projected Lv 45), and Pallor Lurker (projected Lv 46) appear
at Lv 90–96 — massively above their palette-families projections.
The Void amplifies Pallor entities. Stats are computed from the
Void deployment level. Threat level preserved per README early
deployment rule.

---

## 4. Echo Bosses

### 4.1 The First Scholar (Floor 4, Lv 50, 40,000 HP)

The First Age's greatest mind. Chose knowledge over survival.

- **Mechanic: Spell Pattern Rotation.** Casts in a fixed 4-spell
  rotation. Each spell telegraphs with a glyph symbol 1 turn in
  advance. Players who learn the pattern can pre-buff/defend.
- **Phase 1 (40,000–20,000):** 4-spell rotation, moderate damage.
  Spells: Glyph of Flame, Glyph of Frost, Glyph of Storm, Glyph
  of Void. Each glyph corresponds to an element.
- **Phase 2 (below 20,000):** Rotation doubles speed (2 spells per
  turn). Same pattern, twice as fast.
- **The test:** Pattern recognition and preparation.
- **Weakness:** Void (150%). **Resistance:** Spirit (50%).
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Ancient Manuscript (100%)
- **Drop:** Scholar's Codex (100%) — accessory, MAG +25,
  Arcanum boost. **TODO: finalize in Gap 1.5 (Equipment).**

### 4.2 The Crystal Queen (Floor 8, Lv 60, 60,000 HP)

An alien warrior-queen whose civilization grew from crystal.

- **Mechanic: Reflection.** All single-target damage reflected
  back at attacker at 50%. Only AoE and multi-target abilities
  bypass. Healing the Queen damages her (reversed).
- **Phase 1 (60,000–30,000):** Reflection at 50%. Crystal shards
  (physical) and prismatic beams (magic).
- **Phase 2 (below 30,000):** Shatters into 4 Crystal Aspects
  (15,000 HP each). Each Aspect reflects a different element.
  Kill all 4 to end the fight.
- **The test:** Party composition and AoE strategy.
- **Weakness:** Earth (150%). **Resistance:** Ley (75%).
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Queen's Prism (100%)
- **Drop:** Queen's Facet (100%) — accessory, reflects 25%
  magic damage passively. **TODO: finalize in Gap 1.5.**

### 4.3 The Rootking (Floor 12, Lv 72, 80,000 HP)

A nature spirit who tried to grow a wall against the Grey.

- **Mechanic: Regeneration + Summons.** Regenerates 2,000 HP/turn.
  Summons Root Weavers every 3 turns. Only way to stop regen:
  destroy Root Anchor (hidden targetable part, 10,000 HP, appears
  every 5 turns for 2 turns).
- **Phase 1 (80,000–40,000):** Moderate regen, light summons.
- **Phase 2 (below 40,000):** Regen doubles (4,000/turn). Summons
  every 2 turns. Root Anchor appears every 4 turns. Desperate.
- **The test:** Sustained DPS and add management.
- **Weakness:** Flame (150%). **Resistance:** Earth (50%).
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Living Root (100%)
- **Drop:** Root Crown (100%) — accessory, HP regen 3%/turn.
  **TODO: finalize in Gap 1.5.**

### 4.4 The Iron Warden (Floor 16, Lv 86, 100,000 HP)

The master engineer who built a machine to stop the Pallor.
The true final boss of the game.

- **Mechanic: Counter Defense.** Physical attacks countered.
  Magic triggers shield absorbing next magic attack. Must
  alternate: physical→magic→physical→magic.
- **Phase 1 (100,000–50,000):** Strict counter pattern. Rewards
  disciplined alternation.
- **Phase 2 (50,000–25,000):** Summons 2 Gear Wraiths. Counter
  pattern applies to summons — hitting wrong target triggers
  party-wide counterattack.
- **Phase 3 (below 25,000):** Overclocks. 2 actions per turn.
  Counter window shrinks. The machine is failing.
- **The test:** Tactical discipline under escalating pressure.
- **Weakness:** Storm (150%). **Resistance:** Flame (50%),
  Frost (50%).
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Warden's Blueprint (100%)
- **Drop:** Warden's Core (100%) — accessory, counter-attack on
  physical hit. **TODO: finalize in Gap 1.5.**

### 4.5 Cael's Echo (Floor 20, Non-Combat)

Not a fight. The party finds an echo of Cael sitting at a table.
He says: "It's heavy. But the door is closed. Go home."

The party can examine echoes of every age — brief vignettes of
civilizations that fell. Then the party leaves.

- **Reward:** Dreamer's Crest (accessory, +30 all stats — best
  in game). **TODO: finalize in Gap 1.5.**

---

## 5. Steal/Drop Conventions

Each age has its own unique crafting material theme. These are
placeholder names — **Gap 1.4 (Item Catalog) will finalize all
item names, effects, and crafting recipes.**

| Age | Steal (75%) | Drop (25%) |
|-----|-------------|------------|
| First Age | Ancient Glyph | Carved Stone |
| Crystal Age | Crystal Fragment | Prism Shard |
| Green Age | Living Bark | Heartwood Splint |
| Iron Age | Iron Cog | Tempered Plate |
| The Void | Pallor Sample | Grey Residue |

> **TODO (Gap 1.4):** Define what Ancient Glyph, Crystal Fragment,
> Living Bark, Iron Cog, and their drop counterparts craft into.
> These are post-game materials — they should enable the strongest
> non-unique equipment in the game.
>
> **TODO (Gap 1.5):** Define stat blocks for all 5 Echo Boss
> accessories (Scholar's Codex, Queen's Facet, Root Crown, Warden's
> Core, Dreamer's Crest). These are the best accessories in the game.

---

## 6. Stat Computation Rules

All stats use README.md canonical formulas. At post-game levels,
the numbers are large:

| Level | HP (base) | ATK (base) | DEF (base) | MAG (base) |
|-------|-----------|------------|------------|------------|
| 42 | 3,699 | 75 | 55 | 64 |
| 58 | 6,768 | 100 | 74 | 87 |
| 70 | 9,680 | 120 | 89 | 104 |
| 84 | 13,728 | 142 | 105 | 123 |
| 100 | 19,220 | 168 | 125 | 146 |

Gold/Exp use logistic formulas × threat. At these levels the
S-curve approaches its cap:
- base_gold(100) ≈ 6,954 (cap 10,000)
- base_exp(100) ≈ 14,100 (cap 30,000)

Threat multipliers: Dangerous ×1.0, Rare ×1.5.

Echo Boss HP is hand-tuned. Boss stats use formulas at listed
level with boss multipliers (×1.5 ATK, ×1.3 DEF, ×1.8 MAG,
×1.5 MDEF, ×1.2 SPD).

Type rules apply as normal:
- Construct: MP=0, Immune Poison/Sleep/Confusion/Berserk/Despair
- Spirit: Immune Poison/Petrify
- Elemental: absorbs own element, Immune Petrify
- Pallor: Weak Spirit, Immune Despair/Death (Resist Void is per-enemy for Tier 4 family variants, not a type default)
- Boss: Immune Death/Petrify/Stop/Sleep/Confusion

---

## 7. Implementation Notes

### 7.1 File Structure

`optional.md` will contain:
- One `##` section per age (5 sections)
- Stat tables with all 19 columns
- Echo Boss notes with phases, abilities, mechanics
- Cael's Echo section (non-combat, reward only)
- Summary section

### 7.2 Void Deployment Notes

palette-families.md needs Void deployment notes for Drake, Wolf,
and Lurker families — deployed at Lv 90–96 vs projected Lv 45–50.
These are the most extreme early deployment gaps in the game
(amplified by the Void, not by narrative urgency).

### 7.3 Cross-References to Future Gaps

This spec documents the following items that depend on future
gap resolution:

| Item | Depends On | Notes |
|------|-----------|-------|
| Age crafting materials (10 items) | Gap 1.4 (Item Catalog) | Names are placeholders, effects TBD |
| Echo Boss accessories (5 items) | Gap 1.5 (Equipment) | Stat blocks are summaries, full details TBD |
| Dreamer's Crest (+30 all stats) | Gap 1.5 (Equipment) | Best accessory in game, needs balance check |
| Age materials → crafting recipes | Gap 1.4 + 1.5 | Post-game gear progression |
| Void deployment notes (3 families) | This PR | Add to palette-families.md during implementation |

### 7.4 Enemy Count

| Area | Regular | Bosses | Total |
|------|---------|--------|-------|
| First Age | 4 | 1 | 5 |
| Crystal Age | 4 | 1 | 5 |
| Green Age | 4 | 1 | 5 |
| Iron Age | 4 | 1 | 5 |
| The Void | 4 | 0 | 4 |
| **Total** | **20** | **4** | **24** |
