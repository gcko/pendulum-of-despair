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

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Ember Drake* | Beast | 8 | 1,500 | 0 | 23 | 11 | 17 | 12 | 14 | 22 | 44 | Drake Scale (75%) | Drake Fang (100%) | Frost | — | — | — | Ember Vein F2 (mini-boss) |

**Modes:** 1 (Normal)

**AI Script:**

```
Mode: Normal
  Priority:
    1. turn_counter % 3 == 0 → Flame Breath (party_wide cone AoE, fire magic damage;
       1-turn charge -- boss rears back on charge turn, fires next turn)
    2. target.position == back_row → Pounce (single_target back-row, moderate physical damage)
    3. Default → Tail Swipe (single_target highest threat, physical damage)

  Counters: None

Scripted Events: None
```

**Design Note:** Ember Drake is the player's first boss encounter, teaching
charge-telegraph recognition (Flame Breath glow) and positional awareness
(Pounce punishes unprotected back row). Drake Fang drop is a consumable
that deals 500 bonus damage, useful in the Vein Guardian fight.

### Vein Guardian

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Vein Guardian* | Boss | 12 | 6,000 | 42 | 40 | 24 | 39 | 24 | 20 | 500 | 800 | Vein Shard (100%) | Vein Guardian's Core (100%) | Storm | Flame | — | Death, Petrify, Stop, Sleep, Confusion | Ember Vein F4 (boss) |

**Modes:** 2 (Normal, Reconstructing)

**AI Script:**

```
Mode: Normal
  Priority:
    1. turn_counter % 4 == 0 → Crystal Slam (single_target highest threat, heavy physical;
       1-turn telegraph -- raises arms on charge turn, slams next turn)
    2. turn_counter % 3 == 0 → Ember Pulse (party_wide AoE, fire magic damage;
       1-turn telegraph -- floor glows orange on charge turn, pulses next turn)
    3. last_action == Crystal Slam → Ember Pulse (party_wide AoE, fire magic damage)
    4. Default → Crystal Slam (single_target highest threat, heavy physical;
       1-turn telegraph -- raises arms on charge turn, slams next turn)

  Counters: None

Mode: Reconstructing (1 turn only)
  Priority:
    1. Default → Reconstruct (self, regenerates 300 HP; boss pauses all attacks)
  Exit: After 1 turn → return to Normal

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: "The Guardian's crystal core fractures... it draws inward."
    - mode_switch: Normal → Reconstructing
    - Note: Reconstruct is one-time only. After completing, boss returns to
      Normal and does not reconstruct again.
```

**Design Note:** Vein Guardian is the first true boss, teaching telegraph
reading across two different attack types (physical slam vs. magic pulse)
and introducing the concept of phase transitions. The Reconstruct pause at
50% HP rewards aggressive play -- players who burst through minimize the
heal.

### Drowned Sentinel (Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Drowned Sentinel* | Construct | 10 | 4,000 | 0 | 24 | 19 | 20 | 14 | 14 | 25 | 50 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Fenmother's Hollow F2 (mini-boss) |

**Modes:** 1 (Normal)

**AI Script:**

```
Mode: Normal
  Priority:
    1. turn_counter % 4 == 0 → Barnacle Shield (self, DEF +100% for 2 turns)
    2. turn_counter % 3 == 0 → Frost Wave (party_wide AoE, frost magic damage)
    3. Default → Stone Slam (single_target highest threat, heavy physical damage)

  Counters: None

Scripted Events: None
```

**Design Note:** Drowned Sentinel teaches elemental type advantage -- as a
Construct, it takes 1.25x damage from Storm, rewarding players who use
Torren's storm magic. Barnacle Shield introduces timed defensive buffs,
teaching patience (wait it out) or magic-based strategies (bypass DEF with
spells).

### Corrupted Fenmother

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Corrupted Fenmother* | Boss | 12 | 18,000 | 42 | 40 | 24 | 39 | 24 | 20 | 1,500 | 2,500 | Fenmother's Tear (100%) | Fenmother's Blessing (100%) | Flame | Frost | — | Death, Petrify, Stop, Sleep, Confusion | Fenmother's Hollow F3 (boss) |

> **Note:** This encounter has three phases. Phase 3 (Cleansing Sequence)
> is a separate wave-defense encounter that begins when the Fenmother
> reaches 0 HP. The party cannot lose Phase 3 -- it is a non-lethal
> narrative sequence. Torren receives the Spirit-Bound Spear after the
> Fenmother is restored.

**Modes:** 3 (Surface, Diving, Desperate)

**AI Script:**

```
=== Phase 1 (18,000--9,000 HP) ===

Mode: Surface
  Priority:
    1. turn_counter % 4 == 0 → Tail Sweep (party_wide AoE, physical damage)
    2. turn_counter % 3 == 0 → Water Jet (single_target lowest HP, water magic damage)
    3. Default → Tail Sweep (party_wide AoE, physical damage)
  Exit: After 3 turns on surface → switch to Diving

Mode: Diving
  - Boss is untargetable while submerged.
  Priority:
    1. Default → Spawn Poisoned Pool (environmental, places 1--2 poison
       hazard zones on the arena floor; party members in zones take poison
       tick damage each turn)
  Exit: After 2 turns submerged → switch to Surface

Transition: At boss.hp_percent <= 50 → enter Phase 2

=== Phase 2 (below 9,000 HP) ===

Mode: Surface (Desperate)
  Priority:
    1. active_adds < 2 AND turn_counter % 3 == 0 → Summon Corrupted Spawn
       (add_spawn, spawns 2 Corrupted Spawn; max 2 active at a time)
    2. turn_counter % 3 == 0 → Water Jet (single_target lowest HP, water magic damage)
    3. turn_counter % 2 == 0 → Tail Sweep (party_wide AoE, physical damage)
    4. Default → Water Jet (single_target lowest HP, water magic damage)
  Exit: After 2 turns on surface → switch to Diving

Mode: Diving
  - Boss is untargetable while submerged. More aggressive pool spawning.
  Priority:
    1. Default → Spawn Poisoned Pool (environmental, places 2--3 poison
       hazard zones; increased coverage)
  Exit: After 2 turns submerged → switch to Surface (Desperate)

Transition: At boss.hp <= 0 → enter Phase 3 (Cleansing Sequence)

=== Phase 3: Cleansing Sequence (at 0 HP) ===

Non-lethal wave-defense encounter. Torren channels to cleanse the
Fenmother. The party defends Torren across 4 waves. Party members
who fall are revived between waves at 25% HP.

  Wave 1 -- "The Poison Breaks":
    - 4 Marsh Serpents + 2 Polluted Elementals

  Wave 2 -- "She Remembers":
    - 3 Ley Jellyfish + 3 Drowned Bones + 1 Polluted Elemental

  Wave 3 -- "The Last Resistance":
    - 2 Polluted Elementals + 4 Marsh Serpents + 2 Ley Jellyfish

  Wave 4 -- "Release":
    - 3 Corrupted Spawn (stronger variant, prioritize targeting Torren)

  Counters: None (standard enemy AI per wave; enemies use their
  normal bestiary AI scripts)

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: "The Fenmother shrieks -- corruption pulses through
      her veins. She dives with renewed fury."
    - add_spawn: 2 Corrupted Spawn

  At boss.hp <= 0 (once):
    - cutscene: "The Fenmother collapses. Torren steps forward, staff
      raised. 'I can feel her -- she's still in there.'"
    - phase_transition: Battle transitions to Cleansing Sequence
    - ability_unlock: Torren begins channeling (cannot act normally)

  At Wave 4 cleared:
    - cutscene: "Light floods the hollow. The corruption lifts. The
      Fenmother opens her eyes -- clear, golden, grateful."
    - party_change: Torren receives Spirit-Bound Spear
```

**Design Note:** The Corrupted Fenmother is Act I's climactic encounter,
combining every mechanic taught so far -- telegraphed attacks, positional
hazards, add management, and elemental strategy (Flame weakness). The
dive/surface cycle creates windows of vulnerability that reward planning.
Phase 3's wave defense is a narrative payoff for Torren's arc, reinforcing
that the Fenmother is a victim to be saved, not a monster to be killed.

---

## Act II Bosses

### Ley Colossus (Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Ley Colossus* | Elemental | 22 | 7,000 | 77 | 43 | 31 | 36 | 26 | 25 | 63 | 116 | Ley Crystal Fragment (75%) | Colossus Shard (100%) | — | — | Flame, Frost, Storm, Earth, Ley, Spirit, Void | Petrify | Ley Line Depths F3 (mini-boss) |

> **Note:** The Ley Colossus is NOT hostile -- it is a guardian testing
> visitors' worthiness. It absorbs ALL elemental magic damage (Flame,
> Frost, Storm, Earth, Ley, Spirit, Void). Players must rely on physical
> attacks. The Colossus is Elemental type, not Boss type, meaning it
> lacks standard boss status immunities beyond Petrify.

**Modes:** 2 (Whole, Shattered)

**AI Script:**

```
=== Phase 1 (7,000--3,500 HP) ===

Mode: Whole
  Priority:
    1. turn_counter % 4 == 0 → Ley Pulse (party_wide AoE, ley magic damage;
       1-turn charge -- chest crystal glows bright on charge turn, pulses next turn)
    2. turn_counter % 3 == 0 → Crystal Fists (single_target highest threat,
       heavy physical damage)
    3. Default → Crystal Fists (single_target highest threat, heavy physical damage)

  Counters:
    Trigger: Any magic damage dealt to boss
    Response: Absorb (boss heals for 100% of damage dealt; all elements absorbed)
    Limit: No limit (fires every time)

Transition: At boss.hp_percent <= 50 → enter Phase 2

=== Phase 2 (below 3,500 HP) ===

Mode: Shattered
  Stat Modifiers: DEF -25%, SPD +30%
  Note: Colossus shatters and reforms into a smaller, faster configuration.
        Loses Ley Pulse. Gains Prism Beam. Physical vulnerability increases.
  Priority:
    1. turn_counter % 3 == 0 → Prism Beam (single_target lowest MDEF,
       high magic damage; 1-turn charge -- warning beam traces target on
       charge turn, fires next turn)
    2. Default → Crystal Fists (single_target highest threat, heavy physical damage)

  Counters:
    Trigger: Any magic damage dealt to boss
    Response: Absorb (boss heals for 100% of damage dealt; all elements absorbed)
    Limit: No limit (fires every time)

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: "Cracks spiderweb across the Colossus. It shatters --
      then the fragments pull together into a leaner, sharper form."
    - mode_switch: Whole → Shattered
    - environmental: Ley crystal debris scatters across arena floor

  At boss.hp <= 0 (once):
    - dialogue: "The Colossus kneels, crystal dimming. It extends one
      hand -- a shard of its core rests in its palm. An offering."
    - Note: Non-hostile defeat. The Colossus yields, granting passage.
```

**Design Note:** The Ley Colossus teaches magic absorption -- a mechanic
that recurs with the Ley Titan in Act III. Players who rely on magic damage
will heal the boss, forcing a physical-only strategy. The Phase 2 shift
to a faster, frailer form rewards sustained aggression. Prism Beam's
warning trace teaches single-target telegraph avoidance (move or guard the
targeted character). As a non-hostile guardian, the encounter reinforces
the theme that not all obstacles are enemies.

### The Forge Warden

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Forge Warden* | Boss | 24 | 8,500 | 84 | 69 | 42 | 70 | 42 | 32 | 2,000 | 3,500 | Corrupted Tuning Fork (100%) | Drayce's Failsafe Core (100%) | Storm (150%), Spirit (125%) | Flame (50%), Earth (75%) | — | Death, Petrify, Stop, Sleep, Confusion, Poison | Ashmark Factory Depths (boss) |

> **Note:** Lira Forgewright has a special relationship with the Forge
> Warden -- she deals 150% damage to it and can disable Pipeline Drain.
> The Forge Warden was originally a factory defense construct built by
> Drayce; it has been corrupted by Pallor energy.

**Modes:** 2 (Programmed, Corrupted)

**AI Script:**

```
=== Phase 1: Programmed Defense (8,500--4,250 HP) ===

Mode: Programmed
  Priority:
    1. turn_counter % 6 == 0 AND shield_protocol_off_cooldown →
       Shield Protocol (self, grants 1,000 HP absorb shield; 4-turn cooldown)
    2. turn_counter % 4 == 0 → Containment Pulse (party_wide AoE, 250--300
       magic damage + knockback to back row + spawns 1--2 contaminated zones;
       contaminated zones deal tick damage to party members standing in them)
    3. turn_counter % 3 == 0 → Pipeline Drain (self, heals 500 HP;
       if Lira Forgewright is in party and alive, she automatically disrupts
       the pipeline -- heal is negated and boss loses next turn)
    4. Default → Ley Bolt (single_target highest threat, 350--400 magic damage)

  Counters: None

Transition: At boss.hp_percent <= 50 → enter Phase 2

=== Phase 2: Corrupted Logic (below 4,250 HP) ===

Mode: Corrupted
  Note: Targeting becomes semi-random (50% chance to target highest threat,
        50% random). All Phase 1 abilities retained with additions.
  Priority:
    1. boss.hp_percent <= 20 AND NOT emergency_protocol_active →
       Emergency Protocol (self, begins 3-turn self-destruct countdown;
       if Lira Forgewright is in party and alive, Lira Override ability
       unlocks -- using it aborts the self-destruct. If countdown reaches
       0, deals 9,999 damage party_wide -- effectively a wipe)
    2. turn_counter % 5 == 0 → Overload Beam (positional line AoE,
       500--600 magic damage; 2-turn charge -- targeting reticle appears
       on charge turn 1, beam locks on charge turn 2, fires turn 3;
       interruptible by 800+ physical damage during charge)
    3. system_failure_ready (random, ~25% chance per turn) →
       System Failure (self, boss freezes for 1 turn; free damage window)
    4. turn_counter % 6 == 0 AND shield_protocol_off_cooldown →
       Shield Protocol (self, grants 1,000 HP absorb shield; 4-turn cooldown)
    5. turn_counter % 4 == 0 → Containment Pulse (party_wide AoE, 250--300
       magic damage + knockback + contaminated zones)
    6. turn_counter % 3 == 0 → Pipeline Drain (self, heals 500 HP;
       Lira disrupts if present)
    7. Default → Ley Bolt (single_target semi-random, 350--400 magic damage)

  Counters: None

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: "Warning klaxons blare. The Warden's eyes flicker between
      blue and crimson. 'DEFENSE PROTOCOL... COR-R-RUPTED.'"
    - mode_switch: Programmed → Corrupted
    - environmental: Factory lights shift to emergency red; additional
      contaminated zones appear at arena edges

  At boss.hp_percent <= 20 (once, if Lira in party):
    - dialogue: Lira: "That's Drayce's failsafe -- it'll take the whole
      factory down! I can override it, but I need an opening!"
    - ability_unlock: Lira gains "Lira Override" command (single use,
      aborts Emergency Protocol self-destruct)

  At boss.hp <= 0 (once):
    - dialogue: "The Warden shudders, collapses to one knee. Its chest
      plate splits open, revealing a pulsing core -- Drayce's Failsafe Core."
    - Note: If Lira is in party, additional dialogue: Lira: "...He built
      this to protect the factory. To protect us. And we had to destroy it."
```

**Design Note:** The Forge Warden is a mechanics-dense encounter that
rewards party composition. Lira Forgewright's 150% damage bonus and
Pipeline Drain disruption make her nearly essential, reinforcing her
narrative connection to the factory. The Overload Beam teaches interrupt
mechanics (burst physical damage to cancel a charge), while System
Failure's random free turns prevent the fight from feeling scripted.
Emergency Protocol is the tension peak -- players must either have Lira
for the Override or burn through 20% HP in 3 turns. Storm weakness
(150%) rewards Torren's magic.

### The Ashen Ram

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Ashen Ram* | Boss | 22 | 25,000 | 77 | 64 | 40 | 64 | 39 | 30 | 5,000 | 8,000 | Pallor-Laced Iron (100%) | Compact Battle Standard (100%) | Storm, Flame (Phase 3 core only) | Frost | Earth | Death, Petrify, Stop, Sleep, Confusion | Valdris Siege (boss) |

> **Note:** The Ashen Ram is a massive siege engine. This encounter
> begins with a pre-fight gauntlet of enemy waves before the boss itself
> engages. Dame Cordwyn (NPC ally, 5,000 HP, ATK 85, DEF 70) fights
> alongside the party throughout the encounter, using Shield Wall and
> Rally Cry. Phase 3 exposes the Pallor Core, which is separately
> vulnerable to Flame (the boss's overall Flame weakness only applies
> to the exposed core).

**Modes:** 3 (Ranged, Breach, Core)

**AI Script:**

```
=== Pre-Fight Gauntlet ===

The party and Dame Cordwyn face waves of Imperial forces before the
Ashen Ram reaches the wall. Short breather between Wave 3 and the boss.

  Wave 1 -- "Vanguard":
    - 4 Imperial Soldiers + 2 Siege Engineers
    - Note: Engineers repair barricades if left alive; prioritize them.

  Wave 2 -- "Suppression":
    - 3 Imperial Soldiers + 2 Ballista Crews
    - Note: Ballista Crews deal heavy single-target damage from back row.

  Wave 3 -- "Air Support":
    - 2 Gyrocopters + 2 Imperial Soldiers
    - Note: Gyrocopters are airborne (immune to melee until grounded
      by Storm or ranged attacks).

  Breather:
    - Party HP/MP restored to 75% of max. Dame Cordwyn delivers a
      rallying speech. Status effects cleared.

NPC: Dame Cordwyn (fights alongside party for entire encounter)
  HP: 5,000 | ATK: 85 | DEF: 70
  AI:
    1. party_avg_hp < 40% → Rally Cry (party_wide, restores 15% max HP
       to all party members; 5-turn cooldown)
    2. single ally below 25% HP → Shield Wall (positional, interposes
       to absorb next hit targeting that ally; 3-turn cooldown)
    3. Default → Sword Strike (single_target, same target as party leader;
       physical damage based on ATK 85)

=== Phase 1: Ranged Assault (25,000--15,000 HP) ===

Mode: Ranged
  Note: The Ashen Ram is approaching the wall. It attacks at range while
        deploying soldiers. Despair Pulse is a passive aura.
  Passive: Despair Pulse (party_wide, drains 3% max MP per turn from all
           party members; cannot be dispelled while Ram is in Ranged mode)
  Priority:
    1. turn_counter % 5 == 0 → Compact Escalade (add_spawn, deploys 2
       Imperial Soldiers from the Ram's side hatches; max 4 active)
    2. turn_counter % 4 == 0 → Lord Haren's Orders (party_wide, ATK/MAG
       buff to all active adds for 3 turns)
    3. turn_counter % 3 == 0 → Battering Advance (single_target highest DEF,
       heavy physical damage; Ram moves closer -- after 3 uses, triggers
       Phase 2 transition regardless of HP)
    4. Default → Battering Advance (single_target highest DEF, heavy
       physical damage)

  Counters: None

Transition: At boss.hp_percent <= 60 OR Battering Advance used 3 times
            → enter Phase 2

=== Phase 2: Breach (15,000--7,500 HP) ===

Mode: Breach
  Note: The Ram has reached the wall. Close-range combat. Despair Pulse
        passive continues. No more soldier deployment.
  Passive: Despair Pulse (party_wide, drains 3% max MP per turn)
  Priority:
    1. turn_counter % 5 == 0 → Engine Surge (party_wide AoE, moderate
       physical damage + knockback to back row; 1-turn charge --
       engine revs on charge turn, surges next turn)
    2. turn_counter % 3 == 0 → Pallor Shrapnel (party_wide AoE, moderate
       magic damage + 30% chance Despair status on each target)
    3. Default → Drill Arm (single_target highest threat, heavy physical
       damage; ignores 25% of target's DEF)

  Counters: None

Transition: At boss.hp_percent <= 30 → enter Phase 3

=== Phase 3: Pallor Core (below 7,500 HP) ===

Mode: Core
  Note: The Ram's outer hull is breached, exposing the Pallor Core.
        Despair Pulse becomes an active attack. Core is vulnerable to
        Flame (applies the boss's Flame weakness). Storm weakness
        applies to the Ram throughout all phases.
  Priority:
    1. turn_counter % 5 == 0 → Core Overload (party_wide AoE, massive
       magic damage; 2-turn charge -- core pulses on charge turn 1,
       energy builds on charge turn 2, detonates turn 3; interruptible
       by Flame damage during charge -- Flame hits the exposed core
       and disrupts the overload)
    2. turn_counter % 3 == 0 → Despair Pulse (active) (party_wide AoE,
       moderate magic damage + drains 5% max MP; replaces passive aura)
    3. Default → Drill Arm (single_target highest threat, heavy physical
       damage; ignores 25% of target's DEF)

  Counters: None

Scripted Events:
  At gauntlet_complete (once):
    - dialogue: Dame Cordwyn: "Here it comes -- the Ashen Ram. Hold the
      line! For Valdris!"
    - environmental: The siege engine emerges from smoke, towering over
      the wall defenses

  At Phase 2 transition (once):
    - dialogue: "The Ram crashes into the wall. Stone cracks. The ground
      shakes beneath your feet."
    - environmental: Arena shifts to close-range; ranged positions no
      longer available. Debris hazards appear.
    - dialogue: Dame Cordwyn: "It's breached the outer wall! Get in close
      -- don't let it push through!"

  At Phase 3 transition (once):
    - dialogue: "The hull splits open. Inside, a pulsing core of grey
      light -- Pallor energy, raw and writhing."
    - environmental: Pallor Core exposed at Ram's center; Flame attacks
      now deal bonus damage to the core
    - dialogue: Dame Cordwyn: "There -- that's its heart! Hit it with
      everything you've got!"

  At boss.hp <= 0 (once):
    - cutscene: "The Pallor Core ruptures. The Ashen Ram groans, lists,
      and collapses in a cascade of iron and grey light. Silence falls
      over the wall. Then -- cheering."
    - dialogue: Dame Cordwyn: "The Ram is down. Valdris stands... for now."
```

**Design Note:** The Ashen Ram is Act II's climactic set-piece, combining
a pre-fight gauntlet with a three-phase siege boss. The gauntlet teaches
wave management and establishes Dame Cordwyn as a reliable NPC ally. The
Despair Pulse MP drain creates resource tension across all phases, forcing
players to choose between conserving MP and going all-out. Phase
transitions are driven by both HP thresholds and mechanical triggers
(Battering Advance count), keeping the pacing dynamic. Phase 3's Core
Overload interrupt mechanic (Flame disrupts the charge) rewards players
who saved fire-element resources despite the MP drain. The encounter
serves as both a mechanical climax and a narrative one -- defending Valdris
alongside Cordwyn cements the stakes of the Pallor conflict.

---

## Interlude Bosses

### Corrupted Boring Engine (Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Corrupted Boring Engine* | Construct | 22 | 6,000 | 0 | 43 | 35 | 36 | 26 | 19 | 63 | 116 | Arcanite Core (75%) | Drill Fragment (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Rail Tunnels (West Tunnel, mini-boss) |

> **Note:** The Corrupted Boring Engine is a Construct, not Boss type,
> meaning it has more status vulnerabilities than a true boss. Back
> attacks against the exposed Arcanite core deal bonus damage. The
> engine cycles between two modes: Drilling (charges and slams) and
> Exposed (core targetable, takes +50% physical damage but only from
> melee-range attacks).

**Modes:** 2 (Drilling, Exposed)

**AI Script:**

```
Mode: Drilling
  Note: Engine charges forward in straight lines. Core is shielded.
        Physical attacks deal normal damage. Back attacks unavailable.
  Priority:
    1. turn_counter % 3 == 0 → Drill Charge (positional line, 250--300
       physical damage to all targets in a line; 1-turn charge --
       engine revs on charge turn, charges next turn; positional --
       party members can move out of the line during charge turn)
    2. turn_counter % 2 == 0 → Area Slam (party_wide AoE, 150--200
       physical damage + knockback; engine slams the tunnel floor)
    3. Default → Ram (single_target highest threat, 200 physical damage)
  Exit: After 3 turns in Drilling → switch to Exposed

Mode: Exposed
  Stat Modifiers: Physical damage taken +50% (melee only)
  Note: The Arcanite core on the engine's back becomes targetable.
        Back attacks against the core deal +50% physical damage (melee
        only). Ranged and magic attacks deal normal damage. Engine is
        sluggish and defensive in this mode.
  Priority:
    1. turn_counter % 2 == 0 → Steam Vent (party_wide cone AoE,
       100--150 fire magic damage; defensive spray while core is exposed)
    2. Default → Grinding Halt (self, DEF +25% for 1 turn; engine
       braces while overheated)
  Exit: After 2 turns in Exposed → switch to Drilling

  Counters: None

Scripted Events: None
```

**Design Note:** The Corrupted Boring Engine teaches positional
awareness in tight tunnel corridors. The Drilling/Exposed cycle rewards
patience -- players who weather the Drilling phase get a high-damage
window when the core is exposed. As a Construct (not Boss), it is
vulnerable to more status effects, letting players experiment with
debuffs. Storm weakness rewards Torren's magic, and the back-attack
bonus on the exposed core rewards melee positioning. A straightforward
mini-boss that gates access to the deeper Rail Tunnels and The Ironbound.

### The Ironbound

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Ironbound* | Boss | 24 | 22,000 | 84 | 69 | 42 | 70 | 42 | 32 | 5,000 | 8,000 | Reinforced Drill Bit (100%) | Operator's Badge (100%) | Storm, Void | Earth, Flame | — | Death, Petrify, Stop, Sleep, Confusion | Rail Tunnels (deepest section) |

> **Note:** The Ironbound is a massive boring engine fused with its
> operator -- a Drayce-series construct frame. Phase 1 ("The Machine")
> is pure mechanical aggression. Phase 2 ("The Operator") retains all
> Phase 1 abilities but introduces random hesitation windows where the
> trapped operator's will resurfaces, creating free damage opportunities.
> Lira recognizes the Drayce-series frame. Character interactions
> during hesitation windows grant significant bonuses.

**Modes:** 2 (The Machine, The Operator)

**AI Script:**

```
=== Phase 1: The Machine (22,000--11,000 HP) ===

Mode: The Machine
  Priority:
    1. turn_counter % 5 == 0 → Tunnel Collapse (party_wide AoE, 300
       physical damage + Slow 2 turns; environmental -- rearranges
       zone positions, pushing party members to random slots)
    2. turn_counter % 4 == 0 → Steam Vent (positional cone AoE,
       200--250 fire magic damage + Burn 3 turns; targets front row
       and adjacent positions)
    3. turn_counter % 3 == 0 → Drill Charge (single_target highest
       threat, 400--500 physical damage; 1-turn wind-up -- engine
       locks onto target on charge turn, strikes next turn; positional
       -- bonus 150 damage if target is pushed against tunnel wall)
    4. Default → Bore Forward (party_wide push, 150 physical damage;
       pushes all party members back one position; bonus 150 damage
       to any party member already against the wall)

  Counters: None

Transition: At boss.hp_percent <= 50 → enter Phase 2

=== Phase 2: The Operator (below 11,000 HP) ===

Mode: The Operator
  Note: All Phase 1 abilities retained. The operator's will surfaces
        randomly, creating hesitation windows (1-turn pauses where
        the boss takes no action). ~30% chance each turn to hesitate
        instead of acting. Desperate Bore replaces Drill Charge.
        Character interactions during hesitation grant bonuses.
  Priority:
    1. hesitation_roll (30% chance per turn) → Hesitation (self,
       boss pauses for 1 turn; operator's will struggles for control;
       free damage window)
    2. turn_counter % 5 == 0 → Tunnel Collapse (party_wide AoE, 300
       physical damage + Slow 2 turns; zone rearrange)
    3. turn_counter % 4 == 0 → Steam Vent (positional cone AoE,
       200--250 fire magic damage + Burn 3 turns)
    4. turn_counter % 3 == 0 → Desperate Bore (single_target highest
       threat, 500--600 physical damage; double charge speed -- no
       wind-up, strikes immediately; replaces Drill Charge)
    5. Default → Bore Forward (party_wide push, 150 physical damage;
       wall bonus 150)

  Counters: None

  Character Interactions (during Hesitation only):
    - Lira Forgewright ability used during Hesitation → bonus 500
      damage (Lira recognizes the Drayce-series frame and targets
      structural weak points)
    - Torren Spiritcall used during Hesitation → bonus 400 damage
      + boss next attack damage reduced by 50% (operator's spirit
      responds to Torren's call, weakening the machine's aggression)

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: "The engine shudders. Metal groans. From deep inside
      the machine, a voice -- human, desperate: 'I can't... stop it...'"
    - mode_switch: The Machine → The Operator
    - environmental: Tunnel lights flicker; Pallor energy crackles
      along the engine's seams

  At first Hesitation (once):
    - dialogue: "The Ironbound freezes mid-swing. The drill arm
      trembles. The operator's voice, clearer now: 'Please...'"

  At boss.hp <= 0 (once):
    - cutscene: "The Ironbound slows. The drill grinds to a halt.
      The operator's spirit surfaces one final time -- lips moving,
      whispering a name. A partner's name. Then stillness."
    - Note: The operator's death is framed as release, not defeat.
```

**Design Note:** The Ironbound is the Interlude's emotional anchor. Phase
1 is pure mechanical pressure -- Drill Charge's positional wind-up and
Bore Forward's wall-push create a spatial puzzle in the tunnel corridors.
Phase 2 introduces hesitation windows that serve double duty: as a
difficulty relief valve and as a narrative device revealing the trapped
operator. Character interactions during hesitation reward attentive
players -- Lira's Forgewright knowledge and Torren's Spiritcall both
have unique mechanical payoffs. Desperate Bore (no wind-up) raises
Phase 2 burst damage while hesitation windows lower average DPS,
creating an unpredictable rhythm. The defeat scene -- the operator
whispering a partner's name -- reinforces the Pallor's cost: not
monsters, but people consumed by the machine.

### The Undying Warden (Optional)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Undying Warden* | Boss | 25 | 8,000 | 87 | 72 | 45 | 73 | 43 | 33 | 2,000 | 3,500 | Catacomb Map (100%) | Warden's Binding (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Valdris Catacombs (Catacomb Heart, optional) |

> **Note:** The Undying Warden is a spirit-construct bound to guard
> the Valdris Catacombs since the city's founding, driven half-mad by
> ley line failure. This is an optional boss encounter. Torren has a
> special calm command available that changes the defeat dialogue.
> No elemental weaknesses or resistances.

**Modes:** 2 (Spectral Guard, Ley Eruption)

**AI Script:**

```
=== Phase 1: Spectral Guard (8,000--4,000 HP) ===

Mode: Spectral Guard
  Note: The Warden fights with spectral swords and ley-crystal shards.
        Primarily physical attacks with occasional crystal projectiles.
  Priority:
    1. turn_counter % 5 == 0 → Crystal Barrage (party_wide AoE,
       200--250 magic damage; hurls ley-crystal shards in a wide arc)
    2. turn_counter % 3 == 0 → Spectral Cleave (positional front row,
       300--350 physical damage; sweeps twin spectral blades across
       front-row positions)
    3. turn_counter % 4 == 0 → Binding Chains (single_target random,
       150 physical damage + Slow 2 turns; ethereal chains wrap target)
    4. Default → Spectral Slash (single_target highest threat,
       250 physical damage)

  Counters: None

Transition: At boss.hp_percent <= 50 → enter Phase 2

=== Phase 2: Ley Eruption (below 4,000 HP) ===

Mode: Ley Eruption
  Note: Ley-crystal eruptions tear through the catacomb floor. The
        Warden becomes more desperate, mixing physical and magic
        attacks. All Phase 1 abilities retained with additions.
  Priority:
    1. turn_counter % 4 == 0 → Ley-Crystal Eruption (party_wide AoE,
       300--350 magic damage; crystals burst from the floor beneath
       all party members; 1-turn telegraph -- floor glows on charge
       turn, erupts next turn)
    2. turn_counter % 3 == 0 → Spectral Cleave (positional front row,
       300--350 physical damage)
    3. turn_counter % 5 == 0 → Warden's Fury (single_target lowest HP,
       400 physical damage; the Warden focuses on weakened prey)
    4. Default → Spectral Slash (single_target highest threat,
       250 physical damage)

  Counters: None

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: "The Warden howls -- the sound of centuries of duty
      twisted into rage. The catacomb floor cracks. Ley crystals
      erupt from the stone."
    - mode_switch: Spectral Guard → Ley Eruption
    - environmental: Ley-crystal formations burst through catacomb
      floor; ambient light shifts from dim blue to unstable violet

  At boss.hp <= 0 (once, if Torren calm command was NOT used):
    - cutscene: "The Warden staggers. Its spectral form flickers.
      'You... are not... the enemy...' The binding unravels. The
      spirit dissolves into pale light, finally unmoored."

  At boss.hp <= 0 (once, if Torren calm command WAS used):
    - cutscene: "The Warden kneels. The madness fades from its eyes.
      'Finally. Rest.' The spectral form dims gently -- not shattering,
      but settling. Like a candle allowed to go out."
    - Note: Torren's calm command can be used at any point during
      the fight. It does not change the combat mechanics, only the
      defeat dialogue and narrative tone.
```

**Design Note:** The Undying Warden is an optional encounter that
rewards exploration of the Valdris Catacombs. With no elemental
weaknesses or resistances, the fight is a pure stat check -- players
must rely on raw damage and healing efficiency. Phase 2's Ley-Crystal
Eruption introduces telegraphed AoE from the floor, teaching spatial
awareness in a different way from the tunnel bosses. Torren's calm
command is a narrative choice with no mechanical impact -- it exists
purely to give Torren a character moment and to reinforce the theme
that the Warden is a victim of ley line decay, not an enemy. The
branching defeat dialogue rewards players who experiment with party
abilities during boss fights.

### Pallor Nest Mother (Optional)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Pallor Nest Mother* | Boss | 25 | 6,000 | 87 | 72 | 45 | 73 | 43 | 33 | 1,500 | 3,000 | Broodchamber Map (100%) | Nest Mother's Core (100%) | Flame, Spirit | Frost | — | Death, Petrify, Stop, Sleep, Confusion, Despair | Caldera Undercity (deepest junction, sidequest) |

> **Note:** The Pallor Nest Mother is a bloated grey-white arthropod
> fused with the tunnel walls. This is an optional sidequest boss.
> Kerra (NPC guest, 800 HP) fights alongside the party. The Nest
> Mother has a passive Nest Defense buff (+50% DEF) while any spawn
> are alive, incentivizing add management. Desperate Contraction
> (below 25% HP) is a wipe-threat charge that can be interrupted.

**Modes:** 1 (Brood Mother)

**AI Script:**

```
Mode: Brood Mother
  Passive: Nest Defense (+50% DEF while any Grey Crawlers or Pallor
           Mites are alive on the field; removed when all adds dead)
  Priority:
    1. boss.hp_percent <= 25 AND NOT desperate_contraction_active →
       Desperate Contraction (self, begins 3-turn charge; deals 600
       party_wide AoE on detonation; interruptible by dealing 1,000+
       damage in a single hit during charge; boss contracts into
       tunnel walls, visibly pulsing)
    2. turn_counter % 4 == 0 → Spawn Brood (add_spawn, spawns 3
       Pallor Mites at 100 HP each; Mites use basic melee attacks)
    3. turn_counter % 3 == 0 → Brood Pulse (party_wide AoE, 200--250
       magic damage + 20% chance Despair on each target + spawns 2
       Grey Crawlers at 150 HP each)
    4. turn_counter % 5 == 0 → Corruption Surge (environmental,
       creates 3 contaminated zones on the arena floor; zones deal
       100 damage per turn for 3 turns to party members standing
       in them)
    5. Default → Tendril Lash (2 random targets, 300 physical damage
       each; tendrils lash out from the tunnel walls)

  Counters: None

NPC: Kerra (fights alongside party for entire encounter)
  HP: 800 | ATK: 18 | DEF: 14
  Note: If Kerra falls to 0 HP, she is incapacitated but survives
        the encounter. She does not die permanently.
  AI:
    1. active_adds >= 3 → Sweeping Strike (party_wide, targets all
       adds; moderate physical damage; prioritizes clearing spawns)
    2. Default → Quick Slash (single_target, same target as party
       leader; physical damage based on ATK 18)

Scripted Events:
  At encounter_start (once):
    - dialogue: Kerra: "That thing -- it's fused with the walls.
      We have to kill the spawns or it'll just keep shielding itself."
    - Note: Tutorial hint about Nest Defense passive.

  At boss.hp_percent <= 25 (once):
    - dialogue: "The Nest Mother shrieks. Its body contracts, pulling
      tight against the tunnel walls. Something is building..."
    - Note: Signals Desperate Contraction charge. Players have 3
      turns to deal 1,000+ damage in a single hit to interrupt.

  At Desperate Contraction interrupted (once, if applicable):
    - dialogue: "The Nest Mother convulses -- the charge dissipates.
      It sags against the walls, momentarily stunned."
    - Note: Boss is stunned for 1 turn after interruption.

  At boss.hp <= 0 (once):
    - dialogue: "The Nest Mother's grip on the walls loosens. Grey
      chitin cracks and falls away. The tunnel junction falls silent."
    - Note: If Kerra is still standing, additional dialogue:
      Kerra: "It's done. The tunnels should be safer now. ...Thank you."
```

**Design Note:** The Pallor Nest Mother is an add-management encounter
that tests the player's ability to prioritize targets. Nest Defense
(+50% DEF while adds alive) creates a clear incentive to clear spawns
before focusing the boss, but the constant Brood Pulse and Spawn Brood
abilities keep add pressure high. Corruption Surge's contaminated zones
add spatial complexity, forcing movement while managing adds.
Desperate Contraction below 25% HP is the tension peak -- a 600-damage
party-wide wipe threat that rewards players who saved burst abilities.
Kerra as a guest NPC provides add-clearing support but is fragile (800
HP), teaching resource allocation. Flame and Spirit weaknesses reward
diverse elemental strategies. As an optional sidequest boss, the Nest
Mother rewards exploration of the Caldera Undercity.

### General Vassar Kole

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *General Vassar Kole* | Boss | 28 | 30,000 | 98 | 78 | 49 | 81 | 48 | 36 | 8,000 | 12,000 | Kole's Epaulettes (100%) | Map to the Convergence (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Ironmark Citadel Command Chamber (via Axis Tower Floor 5 tunnel) |

> **Note:** General Vassar Kole is the Interlude's final boss -- a
> military commander in Pallor-enhanced Forgewright armor. He is
> calculated, not monstrous. HP 30,000 is canonical (encounter table
> value; prose reference of 12,000 is a known typo). No elemental
> weaknesses or resistances. Phase 2 introduces conduit crystals
> that must be destroyed to remove the Despair Aura.

**Modes:** 2 (Commander, Channeling)

**AI Script:**

```
=== Phase 1: Commander (30,000--15,000 HP) ===

Mode: Commander
  Note: Kole fights with discipline and tactical precision. Arcanite
        sword strikes deal high single-target physical damage. Summons
        Pallor Soldiers as reinforcements every 3rd turn.
  Priority:
    1. turn_counter % 3 == 0 AND active_adds < 4 → Deploy Soldiers
       (add_spawn, summons 2 Pallor Soldiers; max 4 active at a time;
       soldiers use standard Pallor Soldier AI from bestiary)
    2. turn_counter % 4 == 0 → Commander's Strike (single_target
       highest threat, 500--600 physical damage; Kole's arcanite sword
       flares with Pallor energy; 1-turn telegraph -- Kole raises
       sword overhead on charge turn, strikes next turn)
    3. turn_counter % 5 == 0 → Tactical Retreat (self, Kole
       repositions to back of arena; DEF +25% for 2 turns; adds
       gain ATK +15% for 2 turns while Kole directs from rear)
    4. Default → Arcanite Slash (single_target highest threat,
       350--400 physical damage)

  Counters: None

Transition: At boss.hp_percent <= 50 → enter Phase 2

=== Phase 2: Channeling (below 15,000 HP) ===

Mode: Channeling
  Note: Kole channels Ironmark conduits. 2 conduit crystals spawn at
        arena edges. While crystals are active, Despair Aura applies
        Despair status to all party members each turn. Destroy both
        crystals to remove the aura. Kole retains Phase 1 sword
        attacks and gains Grey Shockwave.
  Environmental: 2 Conduit Crystals spawn (1,500 HP each, no DEF,
                 targetable). While at least 1 crystal active:
                 Despair Aura (party_wide, applies Despair status
                 to all party members at start of each turn).
  Priority:
    1. turn_counter % 4 == 0 → Grey Shockwave (party_wide AoE,
       350--400 magic damage; Pallor energy pulses through the floor
       from the conduit network)
    2. turn_counter % 3 == 0 → Commander's Strike (single_target
       highest threat, 500--600 physical damage; 1-turn telegraph)
    3. conduit_crystals_destroyed == 2 AND turn_counter % 5 == 0 →
       Rechannel (environmental, respawns 1 Conduit Crystal at 1,000
       HP; Kole forces a new crystal from the floor; 8-turn cooldown)
    4. Default → Arcanite Slash (single_target highest threat,
       350--400 physical damage)

  Counters: None

Scripted Events:
  At boss.hp_percent <= 50 (once):
    - dialogue: Kole: "Enough. You've proven yourselves worthy of the
      real thing."
    - cutscene: "Kole drives his sword into the floor. The chamber
      trembles. Conduit lines carved into the walls flare with grey
      light. Two crystals erupt from the arena edges, pulsing with
      Pallor energy."
    - environmental: 2 Conduit Crystals spawn at arena edges
    - mode_switch: Commander → Channeling
    - add_spawn: 4 Compact Officers appear at chamber entrance
    - dialogue: Kole (to Officers): "Let them in."
    - Note: The 4 Compact Officers willingly accept Pallor corruption
      on Kole's command. They transform into Pallor Soldiers and join
      the fight (max 4 active adds).

  At first Conduit Crystal destroyed (once):
    - dialogue: "One crystal shatters. The Despair Aura flickers --
      but holds. Kole's jaw tightens."

  At both Conduit Crystals destroyed (once):
    - dialogue: "The second crystal explodes. The grey aura dissipates.
      Kole staggers, severed from the conduit network."
    - Note: Despair Aura removed. Kole can Rechannel after 8-turn
      cooldown.

  At boss.hp <= 0 (once):
    - cutscene: "Kole falls to one knee. His armor -- Pallor-laced,
      Forgewright-built -- sparks and goes dark. He looks up. Not
      with hatred. With something like respect."
    - dialogue: Kole: "The Convergence... you'll need the map.
      Take it. Finish what I couldn't."
    - Note: Commissar Brant watches silently from the chamber
      balcony throughout the defeat scene. He does not speak or
      intervene.
```

**Design Note:** General Vassar Kole is the Interlude's climactic
encounter -- a 30,000 HP endurance fight against a disciplined military
commander. Phase 1 is a war of attrition: Kole's high single-target
damage and steady Pallor Soldier reinforcements test sustained healing
and add management. The Phase 2 transition is one of the game's most
striking moments -- Kole ordering his own officers to accept Pallor
corruption ("Let them in") establishes him as ruthlessly pragmatic,
not evil. The Conduit Crystal/Despair Aura mechanic forces a strategic
choice: burn the crystals to remove the aura (splitting DPS away from
Kole) or endure Despair while focusing the boss. Rechannel prevents
permanent removal, maintaining pressure. With no elemental weaknesses,
Kole is a pure execution check -- the hardest stat test in the
Interlude, preparing players for Act III's difficulty curve. Commissar
Brant's silent observation during the defeat foreshadows his role in
Act III.

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
