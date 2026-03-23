# Boss & Mini-Boss Compendium

> Canonical reference for all boss and mini-boss encounters. AI behavior
> scripts, stat tables, phase mechanics, and scripted events live here.
> For regular enemy stats, see the per-act bestiary files.
> For boss narrative context, see dungeons-world.md / dungeons-city.md.

---

## Quick Reference

| # | Name | Act | Location | Lv | HP | Type | Phases |
|---|------|-----|----------|----|----|------|--------|
| 1 | Ember Drake | I | Ember Vein F2 | 8 | 1,500 | Beast | 1 |
| 2 | Vein Guardian | I | Ember Vein F4 | 12 | 6,000 | Boss | 2 |
| 3 | Drowned Sentinel | I | Fenmother's Hollow F2 | 10 | 4,000 | Construct | 1 |
| 4 | Corrupted Fenmother | I | Fenmother's Hollow F3 | 12 | 18,000 | Boss | 3 |
| 5 | Ley Colossus | II | Ley Line Depths F3 | 22 | 7,000 | Elemental | 2 |
| 6 | The Forge Warden | II | Ashmark Factory Depths | 24 | 8,500 | Boss | 2 |
| 7 | The Ashen Ram | II | Valdris Siege | 22 | 25,000 | Boss | 3 |
| 8 | Corrupted Boring Engine | Int | Rail Tunnels | 22 | 6,000 | Construct | 1 |
| 9 | The Ironbound | Int | Rail Tunnels | 24 | 22,000 | Boss | 2 |
| 10 | The Undying Warden | Int | Valdris Crown Catacombs | 25 | 8,000 | Boss | 2 |
| 11 | Pallor Nest Mother | Int | Caldera Undercity | 25 | 6,000 | Boss | 1 |
| 12 | General Vassar Kole | Int | Ironmark Citadel | 28 | 30,000 | Boss | 2 |
| 13 | The Crowned Hollow | III | Pallor Wastes Trial 1 | 30 | 8,000 | Boss | 2 |
| 14 | The Perfect Machine | III | Pallor Wastes Trial 2 | 30 | 7,000 | Boss | 1 |
| 15 | The Last Voice | III | Pallor Wastes Trial 3 | 32 | 6,000 | Boss | 2 |
| 16 | The Index | III | Pallor Wastes Trial 5 | 32 | 7,000 | Boss | 1 |
| 17 | Vaelith, the Ashen Shepherd | III | Pallor Wastes Section 5 | 34 | 50,000 | Boss | 2+pre |
| 18 | Ley Titan | III | Ley Line Depths F5 | 28 | 18,000 | Boss | 3 |
| 19 | Archive Keeper | III | Dry Well F5 | 32 | 3,000--12,000 | Boss | 1 |
| 20 | Wellspring Guardian | III | Dry Well F7 | 36 | 28,000 | Boss | 3 |
| 21 | The Architect (Stage 1) | III | Forgotten Forge F5 | 34 | 20,000 | Boss | 1 |
| 22 | Grey Cleaver Unbound (Stage 2) | III | Forgotten Forge F5 | 36 | 25,000 | Boss | 1 |
| 23 | Pallor Echo | III | Convergence Phase 4 | 34 | 5,000 | Boss | 1 |
| 24 | Cael, Knight of Despair | III | Convergence Outer Ring | 36/38 | 45,000/35,000 | Boss | 2 |
| 25 | The Pallor Incarnate | III | Convergence Central | 40 | 70,000 | Boss | 1 |
| 26 | The First Scholar | Post | Dreamer's Fault F4 | 50 | 40,000 | Boss | 2 |
| 27 | The Crystal Queen | Post | Dreamer's Fault F8 | 60 | 60,000 | Boss | 2 |
| 28 | The Rootking | Post | Dreamer's Fault F12 | 72 | 80,000 | Boss | 2 |
| 29 | The Iron Warden | Post | Dreamer's Fault F16 | 86 | 100,000 | Boss | 3 |
| * | Vaelith (Siege) | II | Valdris Siege | 150 | 999,999 | Boss | -- |

> **Notes:** Cael (#24) has two stat rows (Phase 1: Lv 36 / 45,000 HP;
> Phase 2: Lv 38 / 35,000 HP). Archive Keeper (#19) has variable HP
> based on a knowledge puzzle (3,000--12,000). The Architect (#21) and
> Grey Cleaver Unbound (#22) are a two-stage fight with no break but are
> separate bosses with different types, levels, and weaknesses.
> Vaelith (Siege) is an unwinnable scripted-loss encounter, not counted
> in the 29 combat bosses.

---

## AI Script Format Reference

This section describes the structured AI script format used for every
boss in this compendium. Inspired by FF4 mode-switching and FF6
conditional priority lists.

### Modes / Stances

Bosses have 1--4 named behavioral modes, each with its own priority
list, optional stat modifiers, and exit conditions.

**Mode transitions** are triggered by:
- **HP threshold:** "At 50% HP -> switch to Enraged"
- **Turn counter:** "Every 4th turn -> enter Charge for 1 turn"
- **Conditional:** "If all adds dead -> exit Defense"

Simple bosses (Ember Drake, Drowned Sentinel) use a single Normal mode.
Complex bosses (Grey Cleaver Unbound, Vaelith) use 2--4 modes.

### Conditional Priority Lists

Within each mode, the boss evaluates an ordered list of conditions each
turn. The first matching condition fires (FF6 approach).

**Condition types:**
- `turn_counter % N == 0` -- every Nth turn
- `boss.hp_percent < X` -- HP threshold check
- `target.has_status(X)` -- status check on current target
- `party_avg_hp > X` -- party health check
- `active_adds < N` -- add count check
- `party_member_count < N` -- party size check
- `last_action == X` -- self-memory (avoid repeating)
- `target.element_last_used == X` -- react to player element
- `Default` -- fallback (always matches)

**Target selection per ability:**
- `single_target` -- highest threat / random / lowest HP
- `party_wide` -- hits all party members
- `positional` -- front row / back row / specific slot
- `self` -- self-buff or heal

### Counter Tables

Approximately half of bosses have counter-attack responses. Counters
fire immediately after the triggering action, before the next turn.
They are checked independently of the priority list -- a boss can both
counter AND take its normal turn.

Counter frequency can be limited: "once per turn" or "50% chance."

**Bosses with identity-reinforcing counters:**
Ley Colossus (absorb magic), Ley Titan (Phase 3 Resonance), Grey
Cleaver Unbound (Shield stance reflects), Iron Warden (strict
physical/magic counter pattern), Corrupted Fenmother (dive/surface
untargetable state), Cael Phase 1 (last-attacker counter), Pallor
Incarnate (conduit regen), The Crowned Hollow (Royal Guard on physical),
Archive Keeper (wrong answer restores HP), Wellspring Guardian (wrong
answer triggers Nexus Pulse).

### Scripted Events

Narrative moments that interrupt normal AI flow, triggered by HP
thresholds, turn counts, or special conditions.

**Event types:**
- `dialogue` -- text box, battle pauses
- `mode_switch` -- change behavioral mode
- `phase_transition` -- load new stat row (for multi-row bosses)
- `party_change` -- member removed/added/status forced
- `add_spawn` -- summon specific enemies
- `environmental` -- arena change (shrink, hazard zones, etc.)
- `ability_unlock` -- special command appears for party member
- `cutscene` -- extended narrative moment, battle fully pauses

---

## Act I Bosses

### Ember Drake (Mini-Boss)

*AI script pending -- see Task 2*

### Vein Guardian

*AI script pending -- see Task 2*

### Drowned Sentinel (Mini-Boss)

*AI script pending -- see Task 2*

### Corrupted Fenmother

*AI script pending -- see Task 2*

---

## Act II Bosses

### Ley Colossus (Mini-Boss)

*AI script pending -- see Task 3*

### The Forge Warden

*AI script pending -- see Task 3*

### The Ashen Ram

*AI script pending -- see Task 3*

---

## Interlude Bosses

### Corrupted Boring Engine (Mini-Boss)

*AI script pending -- see Task 4*

### The Ironbound

*AI script pending -- see Task 4*

### The Undying Warden (Optional)

*AI script pending -- see Task 4*

### Pallor Nest Mother (Optional)

*AI script pending -- see Task 4*

### General Vassar Kole

*AI script pending -- see Task 4*

---

## Act III Bosses

### Trial Bosses

#### The Crowned Hollow (Edren's Trial)

*AI script pending -- see Task 5*

#### The Perfect Machine (Lira's Trial)

*AI script pending -- see Task 5*

#### The Last Voice (Torren's Trial)

*AI script pending -- see Task 5*

#### The Index (Maren's Trial)

*AI script pending -- see Task 5*

### Pallor Wastes

#### Vaelith, the Ashen Shepherd

*AI script pending -- see Task 6*

### Ley Line Depths

#### Ley Titan

*AI script pending -- see Task 6*

### Dry Well of Aelhart

#### Archive Keeper (Mini-Boss)

*AI script pending -- see Task 6*

#### Wellspring Guardian

*AI script pending -- see Task 6*

### The Forgotten Forge

#### The Architect (Stage 1)

*AI script pending -- see Task 6*

#### Grey Cleaver Unbound (Stage 2)

*AI script pending -- see Task 6*

### The Convergence

#### Pallor Echo (Mini-Boss)

*AI script pending -- see Task 7*

#### Cael, Knight of Despair

*AI script pending -- see Task 7*

#### The Pallor Incarnate

*AI script pending -- see Task 7*

---

## Post-Game Bosses (Dreamer's Fault)

### The First Scholar (Echo Boss)

*AI script pending -- see Task 8*

### The Crystal Queen (Echo Boss)

*AI script pending -- see Task 8*

### The Rootking (Echo Boss)

*AI script pending -- see Task 8*

### The Iron Warden (Echo Boss)

*AI script pending -- see Task 8*

---

## Appendix: Unwinnable Encounters

### Vaelith (Siege) -- Scripted Loss

*Stat row pending -- see Task 7*
