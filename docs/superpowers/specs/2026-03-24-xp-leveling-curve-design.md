# XP & Leveling Curve Design

> Spec for Gap 2.1. Defines the XP-to-level formula (two-phase curve),
> XP distribution rules, level-up effects, catch-up mechanics, the Ley
> Scar grinding zone, and tuning targets for expected party level at
> each story milestone.

---

## Table of Contents

1. [XP-to-Level Formula](#1-xp-to-level-formula)
2. [XP Distribution Rules](#2-xp-distribution-rules)
3. [Level-Up Effects](#3-level-up-effects)
4. [Flat XP Model](#4-flat-xp-model)
5. [Catch-Up Mechanics](#5-catch-up-mechanics)
6. [Interlude Reunion Rule](#6-interlude-reunion-rule)
7. [The Ley Scar (Act III Grinding Zone)](#7-the-ley-scar-act-iii-grinding-zone)
8. [Tuning Targets & Base Constant](#8-tuning-targets--base-constant)
9. [XP Pacing Per Act](#9-xp-pacing-per-act)
10. [Cross-References](#10-cross-references)
11. [Files Created/Modified](#11-files-createdmodified)

---

## 1. XP-to-Level Formula

### Two-Phase Curve

The XP curve uses two exponents with a transition at level 70 (end of
Act III). This ensures the main story feels smooth while post-game
content provides a long progression tail.

**Phase 1 (Levels 1–70) — Main Story:**

```
XP_to_next_level(n) = floor(24 × n^1.5)
```

**Phase 2 (Levels 71–150) — Post-Game:**

```
XP_to_next_level(n) = floor(10 × n^1.8)
```

Phase 1 uses base=24 with exponent 1.5 (gentle). Phase 2 uses base=10
with exponent 1.8 (steeper). The different base constants ensure the
phase transition is a noticeable but not brutal 53% jump at level 71.

### Cumulative XP Table

The cumulative XP is the sum of all `XP_to_next_level` from level 1 to
n-1. Computed values:

| Level | Phase | XP to Next | Cumulative XP | Context |
|-------|-------|-----------|--------------|---------|
| 8 | 1 | 543 | 2,014 | After Ember Vein |
| 12 | 1 | 997 | 5,292 | After Fenmother's Hollow |
| 18 | 1 | 1,832 | 14,117 | End of Act I |
| 25 | 1 | 3,000 | 31,503 | Mid Act II (Corrund) |
| 35 | 1 | 4,969 | 72,059 | End of Act II |
| 50 | 1 | 8,485 | 173,946 | End of Interlude |
| 70 | 1 | 14,055 | 400,587 | End of Act III |
| 71 | 2 | 21,491 | 422,078 | Phase transition (+53%) |
| 80 | 2 | 26,641 | 640,884 | Dreamer's Fault F4 |
| 100 | 2 | 39,810 | 1,308,086 | Dreamer's Fault F12 |
| 120 | 2 | 55,274 | 2,262,921 | Dreamer's Fault F16 |
| 150 | 2 | 82,596 | 4,332,504 | Level cap |

### Deriving the Base Constants

**Phase 1 (base=24):** Derived by working backward from the Act I
milestone. At the end of Act I (~level 18), the party should have
earned ~14,000 cumulative XP from:

- ~80 random encounters (Act I average ~25 XP each = ~2,000 XP)
- ~6 mini-boss/scripted battles (~200 XP each = ~1,200 XP)
- 2 boss fights (Vein Guardian 800 XP + Fenmother 2,500 XP = 3,300 XP)
- Overworld encounters (~40 battles × ~30 XP = ~1,200 XP)
- Buffer for exploration encounters: ~6,300 XP

Total estimated: ~14,000 XP by level 18.

```
sum(floor(24 × n^1.5) for n in 1..17) = 12,285 (cumulative at Lv 17)
+ floor(24 × 18^1.5) = 1,832 (Lv 18 itself)
= 14,117 cumulative at Lv 18 ✓
```

**Phase 2 (base=10):** Chosen so the transition at level 71 is a 53%
jump — noticeable but not brutal. `floor(10 × 71^1.8) = 21,491` vs
Phase 1's last level `floor(24 × 70^1.5) = 14,055`.

### Per-Level XP Requirements

**Phase 1 (base=24, n^1.5) — sample levels:**

| Level | XP to Next | Cumulative |
|-------|-----------|-----------|
| 1→2 | 24 | 24 |
| 2→3 | 67 | 91 |
| 5→6 | 268 | 675 |
| 10→11 | 758 | 3,420 |
| 18→19 | 1,832 | 14,117 |
| 25→26 | 3,000 | 31,503 |
| 35→36 | 4,969 | 72,059 |
| 50→51 | 8,485 | 173,946 |
| 70→71 | 14,055 | 400,587 |

**Phase 2 (base=10, n^1.8) — sample levels:**

| Level | XP to Next | Cumulative |
|-------|-----------|-----------|
| 71→72 | 21,491 | 422,078 |
| 80→81 | 26,641 | 640,884 |
| 100→101 | 39,810 | 1,308,086 |
| 120→121 | 55,274 | 2,262,921 |
| 140→141 | 72,950 | 3,550,386 |
| 150 (cap) | — | 4,332,504 |

### Phase Transition

At level 70→71, the XP requirement jumps from 14,055 (Phase 1) to
21,491 (Phase 2). This is a deliberate **53% increase** that signals
"the main story is over, progression now slows." The player should
notice levels come less frequently but each one feels more meaningful.

The transition is NOT smoothed — the jump is intentional. It matches
the narrative shift from Act III's urgency to post-game exploration.

---

## 2. XP Distribution Rules

### Battle XP

- All **4 active battle members** receive the full enemy XP value
- **KO'd members** at battle end receive **0 XP** — incentivizes
  keeping the party alive
- XP is NOT divided — each member gets the full amount (CT model)

### Absent Party Members

- Party members **not in the active battle party** (the 2 reserve
  members from the 6-person roster) receive **50% of battle XP**
- This prevents the "benched forever" problem where unused characters
  fall hopelessly behind
- During the Interlude's forced splits, separated party members are
  considered "absent" and accrue 50% XP from whichever group is
  currently active

### Ley Crystal XP

Per progression.md (already defined):
- Equipped Ley Crystals gain **30% of the wearer's battle XP**
- Truncates (floor) the fractional amount
- Only the currently equipped crystal gains XP (one per character)
- If the wearer is KO'd at battle end, the crystal gains 0 XP

### Guest NPCs

Guest NPCs (Dame Cordwyn, Kerra) do NOT receive XP. They have fixed
stats that scale with the story context, not with battle participation.

---

## 3. Level-Up Effects

When a character gains a level:

1. **Max HP increases** per character growth rate (progression.md)
2. **Max MP increases** per character growth rate
3. **All stats increase** per growth rates
4. **Current HP and MP fully restored** — the FF6 model. This creates
   clutch moments where a near-death level-up saves the party.
5. **New abilities/spells unlock** if the new level meets a learning
   gate (per abilities.md and magic.md schedules)

### Level-Up Notification

The battle results screen shows:
- Character name + "Level Up!"
- New level number
- Stat increases (show each stat delta: HP +85, ATK +2, etc.)
- If a new ability/spell was learned: "Learned: [Ability Name]!"

---

## 4. Flat XP Model

**Enemies always give their listed XP value** regardless of party
level. No bonuses for fighting stronger enemies, no penalties for
fighting weaker ones.

- A Ley Vermin gives 4 XP whether the party is level 1 or level 100
- This is the FF6 approach — simple, transparent, predictable
- Players who want to grind low-level enemies can, but the XP yield
  is so low relative to the curve that it's impractical
- No hidden scaling, no surprises

---

## 5. Catch-Up Mechanics

### Join/Rejoin Formula

Per progression.md (already defined):

```
join_level = max(1, floor(party_average_level) - 1)
```

This applies every time a character joins or rejoins the party:
- Game start: all characters join at level 1
- Interlude reunions: each character rejoins at `party_avg - 1`
- The formula ensures no character is ever more than 1 level behind

### Ongoing Safety Net

The 50% absent XP share (Section 2) keeps reserve characters within
2–3 levels of the active party under normal play. Combined with the
join formula for reunions, no additional catch-up bonus is needed.

### No XP Bonus for Underleveled Characters

Unlike some modern JRPGs, there is no hidden XP multiplier for
characters below the party average. The join formula and absent share
are sufficient. Adding a bonus would make the system feel inconsistent
("why did I suddenly level up faster?").

---

## 6. Interlude Reunion Rule

**Narrative design rule:** When a character rejoins during the
Interlude, any abilities or spells they gained during the separation
(via level-ups from absent XP share or the rejoin level formula)
must be acknowledged in the reunion dialogue.

Examples:
- Torren rejoins at level 29. He learned Stoneheart (Lv 16) and
  Greyveil (Lv 20) during the separation. Reunion scene: *"Torren
  channels a spirit you haven't seen before — born from his time
  alone in the Pallor. 'The spirits of this place spoke to me.
  Not all of them were kind.'"*
- Lira rejoins at level 28. She learned Mending Engine (Lv 17 +
  Interlude story trigger). Reunion scene: *"Lira tinkers with a
  device you don't recognize. 'Built this from scrap while I was
  hiding in the tunnels. Field medic kit — I'll show you.'"*

This rule ensures players:
1. Know the character has new capabilities
2. Feel the character grew during the separation (not just stat bumps)
3. Get a narrative explanation for abilities learned "off-screen"

**Implementation note:** Each reunion scene in events.md should check
the character's current ability list against their pre-separation list
and generate appropriate dialogue. Story writers should prepare 1–2
lines per ability that could be gained during the Interlude window.

---

## 7. The Ley Scar (Act III Grinding Zone)

### Concept

An optional high-risk, high-reward XP farming zone in the Pallor
Wastes, inspired by FF6's Dinosaur Forest. A rift where concentrated
Ley energy bleeds through the Grey, creating hyper-aggressive mutated
creatures.

### Location

Pallor Wastes overworld, Act III. Marked on the map with a distinct
visual indicator (crackling energy). Accessible after the party reaches
the Pallor Wastes but before the final dungeon.

### Design Goals

1. **Provide Act III XP farming** for players who want to overlevel
   before the final dungeon (level 55–70 sweet spot)
2. **Reward risk** — no save point inside, enemies hit hard
3. **Offer rare materials** as secondary incentive (Tier 3–4 crafting
   drops for Arcanite Forging)
4. **Feel dangerous** — unlike normal zones where encounters are
   routine, the Ley Scar should create tension every battle

### Enemy Design

3–4 unique enemy types found only in the Ley Scar. All are Ley-Warped
variants — familiar creature types twisted by concentrated Ley energy.

| Enemy | Lv | Type | Threat | XP | Notes |
|-------|----|----|--------|----|----|
| Ley-Warped Drake | 40 | Beast | Dangerous | 500 | High ATK, fire breath. Hand-tuned (+25% over formula baseline 403) |
| Ley-Warped Colossus | 45 | Construct | Dangerous | 700 | AoE slam, high DEF. Hand-tuned (+24% over formula baseline 567) |
| Ley-Warped Wraith | 42 | Spirit | Dangerous | 575 | MP drain, status ailments. Hand-tuned (+24% over formula baseline 462) |
| Ley Abomination | 48 | Boss-tier | Rare | 1,050 | Rare spawn, mini-boss, best drops. Formula baseline 1,044 |

> **XP values are hand-tuned overrides** — the Ley field canonically
> enhances everything in the zone, justifying ~25% above the bestiary
> formula baseline. These values go in the act-iii.md stat table with
> a design note explaining the override.
>
> **XP comparison:** Normal Act III enemies (Lv 28–32, Standard threat)
> give 100–120 XP. Ley Scar enemies give 500–1,050 XP — roughly 5–8×
> the normal rate. A full Ley Scar run (8–10 battles) yields ~5,000–
> 7,000 XP, equivalent to ~50 normal Act III encounters.

### Encounter Design

- **High encounter rate** — the Ley energy draws creatures constantly
- **No save point** — must return to the overworld to save
- **2–3 enemy groups** per encounter (tougher than normal)
- **Ley Abomination** appears as a rare encounter (~10% chance) and
  functions as a mini-boss with guaranteed Tier 4 material drop
- **Zone is small** — 1 area, no multi-floor dungeon. Enter, fight,
  leave. Keeps farming loops tight.

### Lore Justification

The Ley Scar is where the Convergence's energy first began bleeding
into the physical world. The concentrated Ley field accelerates
everything — growth, mutation, aggression. The party learns more from
fighting these enhanced creatures because the Ley energy heightens
their senses and pushes their limits. (This is the in-world
explanation for why XP is higher here.)

### Narrative Discovery

An NPC at an Act III Oasis mentions rumors of "a place where the
ground hums and the beasts are twice the size." Finding the Ley Scar
is optional but the hint makes it discoverable without a guide.

---

## 8. Tuning Targets & Base Constant

### Target Level by Milestone

These are the levels a player should reach through normal play
(critical path + moderate exploration, no intentional grinding):

| Milestone | Target Level | Cumulative XP | Act |
|-----------|-------------|--------------|-----|
| After Ember Vein | ~8 | ~2,000 | I |
| After Fenmother's Hollow | ~12 | ~5,300 | I |
| End of Act I (arrive Valdris) | ~18 | ~14,100 | I |
| Corrund (mid Act II) | ~25 | ~31,500 | II |
| End of Act II | ~35 | ~72,000 | II |
| Mid Interlude (Sable solo) | ~38 | ~90,000 | Int |
| End of Interlude | ~50 | ~174,000 | Int |
| Mid Act III (Oases) | ~60 | ~273,000 | III |
| End of Act III (pre-Convergence) | ~70 | ~401,000 | III |
| Dreamer's Fault F4 | ~80 | ~641,000 | Post |
| Dreamer's Fault F8 | ~90 | ~941,000 | Post |
| Dreamer's Fault F12 | ~100 | ~1,308,000 | Post |
| Dreamer's Fault F16 | ~120 | ~2,263,000 | Post |
| Dreamer's Fault F20 | ~140 | ~3,550,000 | Post |
| Level cap | 150 | ~4,333,000 | Post |

### Base Constant Derivation

**Phase 1 (base=24):**

```
sum(floor(24 × n^1.5) for n in 1..17) = 12,285
floor(24 × 18^1.5) = 1,832
Cumulative at Lv 18 = 14,117
```

This matches the Act I XP supply estimate of ~14,000.

**Phase 2 (base=10):** Chosen for a 53% transition jump:
- Phase 1 last: `floor(24 × 70^1.5) = 14,055`
- Phase 2 first: `floor(10 × 71^1.8) = 21,491`
- Jump: 53% increase

### Verification Against Enemy XP

**Act I check (target: ~14,100 cumulative → Lv 18):**
- ~80 encounters × ~25 XP avg = 2,000 XP (random)
- ~40 overworld encounters × ~30 XP = 1,200 XP
- 2 bosses (800 + 2,500) = 3,300 XP
- ~6 scripted/mini-boss fights × ~200 XP = 1,200 XP
- Remaining from exploration: ~6,400 XP
- **Total: ~14,100 XP → Level 18** ✓

**Act II check (target: ~72,000 cumulative → Lv 35):**
- ~150 encounters × ~120 XP avg = 18,000 XP
- 4 bosses (~3,000 XP avg) = 12,000 XP
- Quest/scripted battles: ~5,000 XP
- Overworld + exploration: ~23,000 XP
- **Act II income: ~58,000 XP. Cumulative: ~72,000** ✓

**Act III check (target: ~401,000 cumulative → Lv 70):**
- Normal encounters: ~120 × ~350 XP = 42,000 XP
- Bosses: ~5 × ~8,000 XP = 40,000 XP
- Quests + scripted: ~15,000 XP
- Ley Scar farming (optional, ~10 runs × ~6,000): ~60,000 XP
- Interlude carry-forward: ~174,000
- Without Ley Scar: ~345,000 cumulative → Level ~66
- With Ley Scar: ~405,000 cumulative → Level ~70
- **Target met with moderate Ley Scar use** ✓

---

## 9. XP Pacing Per Act

### Act I: Fast Levels, Frequent Rewards

- Levels 1→18 in ~2–3 hours of gameplay
- Level-up every ~15–20 minutes
- New ability every 3–5 levels
- Purpose: teach the player that leveling = new capabilities

### Act II: Steady Progression

- Levels 18→35 in ~4–5 hours
- Level-up every ~20–25 minutes
- Abilities space out (every 4–6 levels)
- New party member slots and equipment tiers provide non-level rewards
- Purpose: maintain engagement through system depth, not just levels

### Interlude: Survival Pacing

- Levels 35→50 in ~3–4 hours
- Level-up every ~15–20 minutes (faster due to harder enemies)
- Story-triggered abilities supplement level-based ones
- The 50% absent share means reunited characters are close in level
- Purpose: scarcity and urgency, but the player still progresses

### Act III: Strategic Climbing

- Levels 50→70 in ~4–6 hours
- Level-up every ~25–30 minutes (curve steepening)
- Ley Scar available for players who want to push harder
- Final abilities learned in the 55–65 range
- Purpose: preparation for the final dungeon, sense of approaching peak

### Post-Game: The Long Tail

- Levels 70→150 in ~20–40+ hours
- Level-up frequency drops dramatically (every 45–90 minutes)
- Phase 2 exponent (1.8) makes each level noticeably harder
- Dreamer's Fault provides appropriately scaled XP
- Purpose: long-term engagement for completionists, not a requirement

---

## 10. Cross-References

| Document | Relationship |
|----------|-------------|
| `docs/story/progression.md` | Stat growth curves, milestone levels, Ley Crystal XP. **Updated:** XP-to-level formula, distribution rules, level-up restore rule added. |
| `docs/story/combat-formulas.md` | Level affects stats which affect damage/hit/crit. No changes needed. |
| `docs/story/bestiary/README.md` | XP reward formula (logistic curve, threat multipliers). **Updated:** Ley Scar level range noted. |
| `docs/story/bestiary/act-iii.md` | **Updated:** Ley Scar enemies added (4 Ley-Warped types). |
| `docs/story/abilities.md` | Ability learning schedules by level. No changes needed (schedules already defined). |
| `docs/story/magic.md` | Spell learning schedules by level. No changes needed. |
| `docs/story/events.md` | **Updated:** Interlude reunion ability-acknowledgment dialogue notes added. |
| `docs/story/economy.md` | Gold pacing aligns with XP pacing (same encounter counts). No changes needed. |
| `docs/story/dungeons-world.md` | **Updated:** Ley Scar zone description added. |
| `docs/analysis/game-design-gaps.md` | **Updated:** Gap 2.1 status → COMPLETE. |

---

## 11. Files Created/Modified

| Action | File | Changes |
|--------|------|---------|
| Modify | `docs/story/progression.md` | Add XP-to-level formula (two-phase curve), XP distribution rules, level-up HP/MP restore, Ley Scar reference, pacing targets table |
| Modify | `docs/story/bestiary/act-iii.md` | Add Ley Scar enemy stat blocks (4 enemies) |
| Modify | `docs/story/dungeons-world.md` | Add Ley Scar zone description (location, encounters, loot) |
| Modify | `docs/story/events.md` | Add Interlude reunion ability-acknowledgment dialogue notes |
| Modify | `docs/analysis/game-design-gaps.md` | Gap 2.1 status → COMPLETE |
