# ATB Gauge Mechanics Design Spec

**Date:** 2026-03-21
**Status:** Draft
**Scope:** Add ATB system definition to `docs/story/combat-formulas.md` —
fill rate formula, battle speed config, Active/Wait mode, status effect
interactions, turn order resolution, and party size rules. Also updates
to `docs/analysis/game-design-gaps.md` (gap 2.2 status).
**Gap:** 2.2 (ATB Gauge Mechanics)
**Depends On:** 1.2 (Stat System) — COMPLETE

---

## 1. Purpose

Define the Active Time Battle gauge system — the core mechanic that
determines when each combatant acts. This is the last undefined piece
of the combat system: stats are defined (Gap 1.2), damage formulas are
defined (Gap 1.1), but how turns work is not. Every combat subsystem
(enemy AI, status effects, buff timing) depends on ATB being specified.

## 2. Design Principles

1. **FF6 is the primary reference.** ATB originated in FF4 and was
   refined in FF6. Our system follows FF6 conventions unless there is
   a specific reason to diverge.
2. **SPD stat is the primary input.** The fill rate formula uses SPD
   directly. Higher SPD = faster gauge = more turns. Sable (highest
   SPD growth) is the speed character; Maren (lowest) is the slowest.
3. **Meaningful but not dominant.** The fastest character should get
   ~20-30% more turns than the slowest party member. Speed is an
   advantage, not a win condition.
4. **Early game ~2-2.5 seconds per turn.** Gives new players time to
   read ability descriptions and learn the combat interaction system.
5. **Endgame ~0.6-1.2 seconds per turn.** Fastest characters (Sable)
   at ~0.6s, slowest (Maren) at ~1.2s. Fast enough to feel powerful,
   slow enough to make decisions.
6. **Player control over pacing.** Battle Speed 1-6 config and
   Active/Wait mode let players tune the experience.

## 3. ATB Fill Rate Formula

```
fill_rate = (SPD + base_speed) * battle_speed_factor
```

### 3.1 Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `base_speed` | 25 | Floor ensures even SPD 1 is playable |
| `gauge_max` | 16,000 | Total gauge capacity |
| `tick_rate` | 60/second | Fixed frame rate for gauge updates |

### 3.2 Battle Speed Factor

Player-configurable in the Config menu (1-6, default 3):

| Setting | Factor | Maren Lv1 (SPD 8) | Sable Lv1 (SPD 18) | Feel |
|---------|--------|-------------------|-------------------|------|
| 1 (Fastest) | 6 | 1.3s | 1.0s | Frantic. Veteran replayers. |
| 2 | 5 | 1.6s | 1.2s | Fast. Experienced players. |
| **3 (Default)** | **3** | **2.7s** | **2.1s** | **Balanced. First playthrough.** |
| 4 | 2 | 4.0s | 3.1s | Relaxed. |
| 5 | 1.5 | 5.4s | 4.1s | Slow. Reading descriptions. |
| 6 (Slowest) | 1 | 8.1s | 6.2s | Crawl. Accessibility option. |

Default is 3, matching FF6.

### 3.3 Fill Rate Modifiers (Status Effects)

Status effects multiply the fill_rate. Multiple modifiers stack
multiplicatively:

| Status | Modifier | Example |
|--------|----------|---------|
| Haste (Quickstep) | × 1.5 | SPD 100: 375 → 563 |
| Slow (Leaden Step) | × 0.5 | SPD 100: 375 → 188 |
| Despair | × 0.75 | SPD 100: 375 → 281 |
| Grounded | × 0.75 | SPD 100: 375 → 281 |
| Berserk | × 1.25 | SPD 100: 375 → 469 |

**New design decision (Berserk):** The × 1.25 ATB modifier for Berserk
is new to this spec — it is not defined in magic.md or abilities.md.
magic.md will be updated to include this value when this spec is
implemented.

**Stacking example:** Haste + Despair = `1.5 × 0.75 = 1.125` (net
+12.5%). This prevents any single buff from being mandatory — you can
partially counteract debuffs without fully negating them.

### 3.4 Pacing at Key Milestones (Battle Speed 3)

| Scenario | SPD | Fill Rate | Seconds/Turn |
|----------|-----|-----------|-------------|
| Maren Lv1 | 8 | 99 | 2.7s |
| Torren Lv1 | 9 | 102 | 2.6s |
| Edren Lv1 | 10 | 105 | 2.5s |
| Lira Lv1 | 11 | 108 | 2.5s |
| Cael Lv1 | 12 | 111 | 2.4s |
| Sable Lv1 | 18 | 129 | 2.1s |
| Maren Lv70 | 49 | 222 | 1.20s |
| Edren Lv70 | 65 | 270 | 0.99s |
| Sable Lv70 | 128 | 459 | 0.58s |
| Sable Lv70 + Haste | 128 | 688 | 0.39s |
| Typical Lv70 enemy (SPD 60) | 60 | 255 | 1.0s |

**Full pipeline (order of operations):**

```
1. effective_SPD = floor(base_SPD * crystal_modifier)
   (e.g., Frost Veil: crystal_modifier = 0.85)
2. base_fill = (effective_SPD + base_speed) * battle_speed_factor
3. fill_rate = floor(base_fill * status_modifier_product)
   (e.g., Haste * Despair = 1.5 * 0.75 = 1.125)
```

All intermediate values use real-number arithmetic. The final
fill_rate is floored to an integer (matching the rounding convention
from combat-formulas.md). Each tick, the gauge increases by exactly
fill_rate (integer addition).

**Time-to-fill formula:** `seconds = gauge_max / fill_rate / tick_rate`
= `16000 / fill_rate / 60`

## 4. Active/Wait Mode

### 4.1 Active Mode (Default)

All gauges fill continuously. Enemy gauges fill while the player
browses spell menus, item menus, and targeting screens. Time pressure
on every decision.

This is the FF6 default.

### 4.2 Wait Mode

Gauges pause for ALL combatants (party and enemies) while any command
sub-menu is open (Magic list, Item list, Ability list, target
selection). Gauges resume when the sub-menu closes.

**Only the top-level command menu runs in real-time.** The 6 options
(Attack / Magic / Ability / Item / Defend / Flee) are selected while
gauges fill. Once the player enters a sub-menu, time stops.

This gives players unlimited time to choose which spell to cast or
which item to use, while still maintaining ATB pressure at the
top-level "what do I do?" decision.

### 4.3 Config Menu

Both settings are in the Config menu:
- **Battle Speed:** 1-6 (default 3)
- **ATB Mode:** Active / Wait (default Active)

## 5. Status Effect ATB Interactions

### 5.1 Complete Status-ATB Table

| Status | Fill Rate | When Gauge Fills | Duration | Removal | Notes |
|--------|-----------|-----------------|----------|---------|-------|
| Haste | × 1.5 | Normal turn | 5 turns | Expires, Purge | |
| Slow | × 0.5 | Normal turn | 5 turns | Purge, Chronos Dust | |
| Stop | Frozen (0) | Cannot act | 3 real-time seconds | Timer only | Real-time, not turn-based |
| Sleep | Frozen at current value | Cannot act | Until cured or damaged | Any damage wakes; Cleansing Draught, Purge | Gauge resumes from frozen point |
| Confusion | × 1.0 | Auto-targets random ally/enemy, basic attack | 3 turns or until damaged | Damage, Purge | |
| Berserk | × 1.25 | Auto-targets random enemy, basic attack (1.5× damage) | Until cured | Purge only | Tradeoff: faster+stronger but uncontrollable |
| Despair | × 0.75 | Normal turn (damage -20%) | 4 turns | Hollow Mend, Hope Shard | Pallor signature. Standard Purge cannot remove. |
| Grounded | × 0.75 | Normal turn (lose evasion) | 3 turns | Expires | Flying enemies only |
| Petrify | Frozen (0), removed from battle | Cannot act | Until cured | Purge, Soft Stone item | Gauge resets to 0 on cure |

### 5.2 Key Rules

**Frozen gauge retains value.** Sleep and Stop freeze the gauge at its
current position. When the status ends, the gauge resumes from that
point. A character at 90% when Stopped gets their turn almost
immediately after Stop wears off.

**Petrify resets to 0.** Unlike Sleep/Stop, being cured of Petrify
starts the gauge from scratch. Petrify is the most severe status —
recovery should feel costly.

**Stop uses real-time duration.** 3 real-time seconds regardless of
battle speed setting. At battle speed 1 (fastest), Stop still lasts 3
seconds of clock time. This means Stop is proportionally more
punishing at slow battle speeds (more enemy actions happen in that
window relative to the pace).

**Note:** magic.md currently defines Stop as "3 turns." This spec
overrides that to "3 real-time seconds" because Stop freezes the
gauge — the target takes no turns while Stopped, making turn-based
duration meaningless. magic.md will be updated to match when this
spec is implemented.

**Berserk is a tradeoff.** +25% fill rate AND +50% damage on basic
attacks, but you can only basic attack random enemies. For physical
fighters like Edren, this is almost a buff. For Maren, it's a
disaster. Creates interesting tactical decisions around Berserk —
sometimes you want it on your tank.

## 6. Turn Order Resolution

### 6.1 Simultaneous Fill Tiebreaker

When multiple combatants reach gauge_max (16,000) on the same tick:

1. **Higher effective SPD acts first.** Compare current SPD including
   all buffs/debuffs at the moment of the tie.
2. **Party before enemies.** If SPD is identical, party members act
   before enemies (home advantage).
3. **Slot order among party.** If SPD is identical among party
   members, left-to-right in party order (slot 1 before slot 2).
4. **Formation order among enemies.** If SPD is identical among
   enemies, left-to-right in formation.

This is fully deterministic — no RNG in turn order. Players can
reason about it: "If I Haste Edren, he'll outspeed that enemy."

### 6.2 Gauge Overflow

When a character's gauge exceeds 16,000, the excess is discarded.
Gauge resets to 0 after acting. No "banking" extra speed — this
prevents exploits where a very fast character accumulates overflow to
act multiple times consecutively.

### 6.3 Gauge on Action

After a character acts (selects and executes a command), their gauge
resets to 0 and begins filling again immediately. There is no delay
between acting and refilling — the next tick after your action starts
the gauge from 0.

## 7. Party & Enemy Count

### 7.1 Party Size

**4 active combatants** in battle (FF6 standard).

- **Party management** at save points, world map, or between battles.
  Not mid-battle.
- **Guest NPCs** (Cordwyn, Kerra) occupy a temporary 5th slot. They
  do not displace a party member — the battle temporarily runs with 5
  on the player side. Guest NPC ATB uses their own SPD computed from
  the scaling formulas in progression.md.
- **Interlude scaling:** The party starts with just Sable (1 member)
  and grows to 4 as she finds each party member. Battles with fewer
  than 4 members run normally — the player gets all turns from their
  available characters.

### 7.2 Enemy Count

No hard cap, but practical limit of **6 enemies** per encounter
(matching FF6). Boss fights typically have 1-3 enemies. Enemy
formation and count are defined per encounter in the bestiary
(Gap 1.3).

## 8. Integration with Existing Systems

### 8.1 Frost Veil Ley Crystal

Progression.md defines the Frost Veil crystal as: "Wearer SPD -15%
in battle (chilling effect on ATB gauge)." This is a permanent in-
battle SPD reduction — it modifies the SPD value before it enters the
fill rate formula: `effective_SPD = SPD * 0.85`. This is applied
before Haste/Slow modifiers.

### 8.2 Arcanite Colossus

Abilities.md defines the Arcanite Colossus device as having "ATB
speed equal to 75% of Lira's Speed." The Colossus uses fill_rate
based on `SPD = floor(Lira.SPD * 0.75)`, computed when summoned
and fixed for its duration.

### 8.3 Combat Formulas Cross-Reference

Combat-formulas.md's resolution order (Steps 1-8 for physical,
Steps 1-7 for magic) executes after the ATB gauge fills and the
player selects a command. The ATB system determines WHEN you act;
combat-formulas.md determines WHAT HAPPENS when you act.

## 9. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/combat-formulas.md` | Modify | Add ATB section with formula, config, status interactions |
| `docs/analysis/game-design-gaps.md` | Modify | Gap 2.2 status PARTIAL -> MOSTLY COMPLETE (visual representation deferred to Gap 2.3) |
| `docs/story/magic.md` | Modify | Update Stop duration (3 turns -> 3 real-time seconds), add Berserk ATB modifier |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add ATB reference if needed |

## 10. Out of Scope

- ATB visual representation (UI design — Gap 2.3)
- Enemy AI behavior when gauge fills (Bestiary — Gap 1.3)
- XP distribution timing relative to ATB (XP Curve — Gap 2.1)
- Preemptive strike / back attack ATB bonuses (Encounter Rates — Gap 2.4)
