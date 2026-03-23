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
| 19 | Archive Keeper | III | Dry Well F5 | 32 | 3,000–12,000 | Boss | 1 |
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
| * | Vaelith (Siege) | II | Valdris Siege | 150 | 999,999 | Boss | — |

> **Notes:** Cael (#24) has two stat rows (Phase 1: Lv 36 / 45,000 HP;
> Phase 2: Lv 38 / 35,000 HP). Archive Keeper (#19) has variable HP
> based on a knowledge puzzle (3,000–12,000). The Architect (#21) and
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

Bosses have 1–4 named behavioral modes, each with its own priority
list, optional stat modifiers, and exit conditions.

**Mode transitions** are triggered by:
- **HP threshold:** "At 50% HP -> switch to Enraged"
- **Turn counter:** "Every 4th turn -> enter Charge for 1 turn"
- **Conditional:** "If all adds dead -> exit Defense"

Simple bosses (Ember Drake, Drowned Sentinel) use a single Normal mode.
Complex bosses (Grey Cleaver Unbound, Vaelith) use 2–4 modes.

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

The party and Dame Cordwyn face waves of Compact forces before the
Ashen Ram reaches the wall. Short breather between Wave 3 and the boss.

  Wave 1 -- "Vanguard":
    - 4 Compact Soldiers + 2 Compact Engineers
    - Note: Engineers repair barricades if left alive; prioritize them.

  Wave 2 -- "Suppression":
    - 3 Compact Soldiers + 2 Siege Ballista Crews
    - Note: Ballista Crews deal heavy single-target damage from back row.

  Wave 3 -- "Air Support":
    - 2 Compact Gyrocopters + 2 Compact Soldiers
    - Note: Gyrocopters are airborne (immune to melee until grounded
      by Storm or ranged attacks).

  Breather:
    - Party HP/MP restored to 75% of max. Dame Cordwyn delivers a
      rallying speech. Status effects cleared.

NPC: Dame Cordwyn (fights alongside party for entire encounter)
  HP: 5,000 | ATK: 85 | DEF: 70
  AI:
    1. any party member has Despair → Rally Cry (party_wide, removes
       Despair from all party members; 3-turn cooldown)
    2. single ally below 25% HP → Shield Wall (positional, reduces
       damage to target ally by 50% for 1 turn; per dungeons-world.md)
    3. Default → Sword Strike (single_target, same target as party leader;
       physical damage based on ATK 85)

=== Phase 1: Ranged Assault (25,000--15,000 HP) ===

Mode: Ranged
  Note: The Ashen Ram is approaching the wall. It attacks at range while
        deploying soldiers. Despair Pulse is a passive aura.
  Passive: Despair Pulse (party_wide, drains 5% max MP per turn from all
           party members; cannot be dispelled while Ram is in Ranged mode)
  Priority:
    1. turn_counter % 5 == 0 → Compact Escalade (add_spawn, deploys 2
       Compact Soldiers from the Ram's side hatches; max 4 active)
    2. turn_counter % 4 == 0 → Lord Haren's Orders (party_wide, ATK/MAG
       buff to all active adds for 3 turns)
    3. turn_counter % 3 == 0 → Battering Advance (single_target highest DEF,
       heavy physical damage; Ram moves closer)
    4. Default → Battering Advance (single_target highest DEF, heavy
       physical damage)

  Counters: None

Transition: At boss.hp_percent <= 60 OR turn_counter >= 5
            → enter Phase 2 (per dungeons-world.md: "After 5 turns,
            it breaches the wall")

=== Phase 2: Breach (15,000--7,500 HP) ===

Mode: Breach
  Note: The Ram has reached the wall. Close-range combat. Despair Pulse
        passive continues. No more soldier deployment.
  Passive: Despair Pulse (party_wide, drains 5% max MP per turn)
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
    1. turn_counter % 5 == 0 → Core Overload (single_target, massive
       magic damage 800--900; 2-turn charge -- core pulses on charge
       turn 1, energy builds on charge turn 2, detonates turn 3;
       interruptible by Flame damage during charge -- Flame hits the
       exposed core and disrupts the overload)
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
transitions are driven by both HP thresholds and a turn timer
(5 turns per dungeons-world.md), keeping the pacing dynamic. Phase 3's Core
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
| *The Ironbound* | Boss | 24 | 22,000 | 84 | 69 | 42 | 70 | 42 | 32 | 5,000 | 8,000 | Reinforced Drill Bit (100%) | Operator's Badge (100%) | Storm (150%), Void (125%) | Earth (50%), Flame (75%) | — | Death, Petrify, Stop, Sleep, Confusion | Rail Tunnels (deepest section) |

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

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Crowned Hollow* | Boss | 30 | 8,000 | 105 | 84 | 53 | 86 | 51 | 38 | 2,000 | 4,000 | Crown Fragment (100%) | Crown Shard (100%) | Spirit (150%) | Physical (75%) | — | Death, Petrify, Stop, Sleep, Confusion | Pallor Wastes Trial 1 |

**Modes:** 2 (Hollow King, Weight of the Crown)

**AI Script:**

```
=== Phase 1: Hollow King (8,000--2,000 HP) ===

Mode: Hollow King
  Note: A spectral king that mirrors Edren's leadership burden. High
        physical resistance (75%) makes brute force inefficient. Summons
        Hollow Knights and counterattacks physical hits with Royal Guard.
        The "correct" approach is hinted by the boss's nature -- it tests
        whether Edren can endure rather than overpower.
  Priority:
    1. turn_counter % 4 == 0 AND active_adds < 2 → Formation Call
       (add_spawn, summons 2 Hollow Knights; 1,000 HP each, standard
       melee AI; max 2 active at a time; they guard the Crowned Hollow)
    2. turn_counter % 3 == 0 → Crown's Burden (party_wide AoE,
       300--350 magic damage + ATK reduction -20% for 2 turns;
       spectral crown pulses with grey light)
    3. Default → Mirror Strike (single_target highest threat,
       400--450 physical damage; copies Edren's equipped weapon type;
       if Edren has a sword, boss swings a spectral sword, etc.)

  Counters:
    On physical_attack_received → Royal Guard (single_target attacker,
       150% of received damage returned as counterattack; once per turn;
       spectral shield manifests and lashes out)

Transition: At boss.hp <= 2,000 → enter Phase 2

=== Phase 2: Weight of the Crown (below 2,000 HP -- Invulnerable) ===

Mode: Weight of the Crown
  Note: The Crowned Hollow becomes invulnerable. All damage is nullified.
        It hammers the party with escalating despair. The ONLY resolution
        is for Edren to use Defend on 3 consecutive turns, accepting the
        weight of command rather than fighting it. This is a character
        test, not a DPS check.
  Modifier: boss.invulnerable = true (all damage nullified)
  Priority:
    1. Default → Weight of Command (party_wide, 500 damage per turn;
       spectral crown presses down on the entire party; unavoidable)

  Counters: None

  Special Mechanic: Edren Defend Tracker
    - Track consecutive turns where Edren uses Defend.
    - If Edren uses any action other than Defend, reset counter to 0.
    - At 3 consecutive Defends → trigger Stagger resolution.

Scripted Events:
  At boss.hp <= 2,000 (once):
    - dialogue: "The Crowned Hollow rises to its full height. The crown
      burns with grey fire. Its voice echoes across the wastes --
      every command Edren has ever given, every life spent under his
      orders."
    - mode_switch: Hollow King → Weight of the Crown
    - Note: Boss becomes invulnerable. Normal attacks show "0" damage.

  At Edren Defend consecutive count == 1 (once per attempt):
    - dialogue: "The weight presses down. Edren's knees buckle --
      but hold."

  At Edren Defend consecutive count == 2 (once per attempt):
    - dialogue: "The crown's fire dims. The Hollow falters. Something
      shifts in Edren's expression."

  At Edren Defend consecutive count == 3 (once):
    - cutscene: "Edren plants his feet. The crown's fire gutters and
      dies. The Crowned Hollow staggers, its form cracking like old
      stone. It speaks -- not with malice, but with exhaustion:
      'You stayed.' The spectral king crumbles. A single crown
      shard falls to the ground."
    - boss.invulnerable = false
    - boss.hp = 0 (defeat)
    - ability_unlock: Edren learns Steadfast Resolve

  Every Name They Carried (triggered once during Phase 2, turn 2):
    - dialogue: "Every name they carried..." (spectral voices recite
      names of the fallen)
    - party_change: Despair status applied to all party members
    - Note: Despair persists until boss is defeated via the Defend
      resolution. Healing Despair is possible but it reapplies
      next turn.
```

**Design Note:** The Crowned Hollow tests Edren's identity as a leader
who endures. Phase 1 is winnable through conventional combat (albeit
slowly due to Physical resistance and Royal Guard counters), but Phase 2
is a hard puzzle gate. The boss becomes invulnerable and the only
resolution is Edren choosing to Defend -- to stand and bear the weight
rather than strike back. This mirrors his character arc: a commander who
learned that leadership means absorbing the cost, not dealing damage.
The Mirror Strike mechanic (copying Edren's weapon) reinforces that the
boss IS Edren's shadow. Every Name They Carried applying party-wide
Despair creates urgency without a combat solution, teaching the player
that some problems cannot be fought through.

#### The Perfect Machine (Lira's Trial)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Perfect Machine* | Boss | 30 | 7,000 | 105 | 84 | 53 | 86 | 51 | 38 | 2,000 | 4,000 | Cael's Gear (100%) | Unfinished Ring (100%) | Void (150%) | Flame (75%) | — | Death, Petrify, Stop, Sleep, Confusion | Pallor Wastes Trial 2 |

**Modes:** 1 (Waiting)

**AI Script:**

```
=== Scripted Encounter: The Perfect Machine ===

Mode: Waiting
  Note: The Perfect Machine is a construct shaped like Cael -- or what
        Cael could have been, if Lira had been able to save him. It does
        NOT attack unprovoked. It stands in the center of the arena,
        incomplete, and asks Lira to repair it. High DEF (halves physical
        damage). This is a scripted event boss, not a priority-list boss.
        The AI is almost entirely event-driven.
  Modifier: boss.def_multiplier = 2.0 (physical damage halved)
  Priority:
    1. Default → Wait (self, no action; the Machine stands motionless,
       gears turning slowly; it does not attack)

  Counters: None

  Special Mechanic: Repair Prompt
    - Each turn the Machine is undamaged, it speaks to Lira.
    - If the party attacks the Machine, it does not retaliate. It
      takes damage normally (subject to high DEF) and speaks sadly.
    - A "Repair" command appears in Lira's ability menu on turn 2.
    - Using Repair triggers one of two scripted responses (see below).

Scripted Events:
  Turn 1 (once):
    - dialogue: Machine: "Lira. You came back."
    - dialogue: Machine: "I am almost finished. I just need your hands."
    - ability_unlock: "Repair" appears in Lira's command menu
    - Note: Repair is a trap. Using it feeds the Machine's false hope.

  On Lira uses "Repair" (each use):
    - boss.hp += 1,500 (Machine heals 1,500 HP)
    - 50% chance → Hopeful Spark: (single_target Lira, 400 magic
      damage; the Machine sparks violently)
      - dialogue: Machine: "Almost... almost right. Try again."
    - 50% chance → False Promise: (boss heals to current HP + 1,500;
      party_wide 200 magic damage; gears grind and shriek)
      - dialogue: Machine: "It hurts. But it will be worth it.
        Keep going."
    - Note: Repair is always harmful. The Machine can heal beyond
      its starting HP. There is no limit to Repair uses, but
      each one makes the fight harder.

  On party attacks Machine (first time, once):
    - dialogue: Machine: "...that hurts. But I understand."
    - dialogue: Machine: "You always did break things before you
      fixed them."

  On Machine HP <= 3,500 from attacks (once):
    - dialogue: Machine: "Please. I can be better. I can be what
      you wanted."
    - dialogue: "Lira's hands are shaking."

  On examining the Machine (inspect/scan command, once):
    - dialogue: "The Machine is exquisitely crafted -- every gear,
      every joint, perfect. But the core is hollow. There is nothing
      inside to fix."
    - ability_unlock: "Dismantle" appears in Lira's Forgewright menu
    - Note: Dismantle is the resolution. It requires Lira's
      Forgewright class ability. Inspect/scan triggers this
      regardless of Machine HP.

  On Lira uses "Dismantle" (each use):
    - boss.hp -= 3,500 (massive damage, bypasses DEF)
    - dialogue (first use): Lira: "I cannot fix you."
    - dialogue (second use): Lira: "I could not fix him. That was
      never my job."
    - Note: Two Dismantles deal 7,000 total damage (equal to
      starting HP). If Machine has healed beyond 7,000 from
      Repair uses, additional Dismantles are needed.

  At boss.hp <= 0 (once):
    - cutscene: "The Machine falls still. Its gears slow, then stop.
      The shape that looked like Cael softens into shapeless metal.
      Lira kneels. She places the Unfinished Ring beside it.
      'Goodbye.'"
    - ability_unlock: Lira unlocks latent ability (Cael weapon
      prerequisite fulfilled)
```

**Design Note:** The Perfect Machine is the most emotionally demanding
trial boss. It has no combat AI -- it waits, speaks, and hopes. The
"Repair" trap is designed to exploit the player's instinct to use
character-specific abilities helpfully: Lira is a Forgewright, and
repairing things is what she does. But the Machine cannot be fixed
because it was never alive. The hidden "Dismantle" command (requiring an
inspect action to discover) is the anti-repair -- Lira using her craft
to unmake rather than create. The dialogue ("I cannot fix you. I could
not fix him. That was never my job.") is the emotional climax of her
arc. The high DEF means brute-forcing the Machine through normal attacks
is possible but slow and unsatisfying -- the game rewards the player for
finding the narrative solution. No time pressure, no enrage timer. The
Machine will wait forever.

#### The Last Voice (Torren's Trial)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Last Voice* | Boss | 32 | 6,000 | 112 | 88 | 55 | 90 | 54 | 39 | 2,000 | 4,000 | Petrified Seed (100%) | Petrified Heartwood (100%) | Flame (150%) | Spirit (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Pallor Wastes Trial 3 |

**Modes:** 2 (Crumbling, The Request)

**AI Script:**

```
=== Phase 1: Crumbling (6,000--1,500 HP) ===

Mode: Crumbling
  Note: The Last Voice is a petrified spirit-tree, the last remnant
        of a ley network node Torren once tended. It is already dying --
        Crumbling Form drains 100 HP from itself each turn passively.
        The boss fights defensively, not aggressively. It is afraid,
        not hostile. Flame weakness (150%) makes it fragile if the
        party chooses to burn it down.
  Passive: Crumbling Form (boss loses 100 HP at start of each boss
           turn; this is automatic and cannot be prevented)
  Priority:
    1. turn_counter % 4 == 0 → Silent Scream (party_wide AoE,
       250 magic damage + Silence status for 2 turns; the tree
       shrieks without sound -- the air itself warps)
    2. turn_counter % 3 == 0 → Stone Grasp (single_target lowest
       SPD party member, 350 physical damage + Slow status for
       3 turns; petrified roots erupt from the ground)
    3. Default → Petrified Lash (single_target highest threat,
       200--250 physical damage; a stone branch swings weakly)

  Counters: None

Transition: At boss.hp <= 1,500 → enter Phase 2

=== Phase 2: The Request (below 1,500 HP) ===

Mode: The Request
  Note: The Last Voice stops fighting. It speaks -- the first words
        it has managed in centuries. Standard attacks deal reduced
        damage (50% of normal values). The boss continues to lose
        100 HP/turn from Crumbling Form. The party can kill it
        through damage or waiting. But the intended resolution is
        Torren using Spiritcall -> Release.
  Modifier: boss.damage_multiplier = 0.5 (all boss attacks deal
            half damage)
  Passive: Crumbling Form continues (boss loses 100 HP/turn)
  Priority:
    1. Default → Fading Grasp (single_target random, 100--125
       physical damage; the tree reaches out -- not to harm,
       but to hold)

  Counters: None

  Special Mechanic: Release
    - When Phase 2 begins, "Release" replaces "Call" in Torren's
      Spiritcall ability menu.
    - Using Release once ends the fight immediately.
    - If the party kills the boss through damage before using
      Release, the fight ends but the emotional resolution is
      diminished (no green shoot, no Rootsong unlock).

Scripted Events:
  At boss.hp <= 1,500 (once):
    - cutscene: "The Last Voice goes still. Stone cracks along its
      trunk. A sound emerges -- not a scream, but a word. Thin.
      Desperate. Unmistakable."
    - dialogue: The Last Voice: "Let me go."
    - mode_switch: Crumbling → The Request
    - ability_unlock: "Release" replaces "Call" in Torren's
      Spiritcall menu
    - dialogue: "Torren's hand trembles over his staff. He
      recognizes this voice."

  At boss.hp <= 750 (once, if Release not yet used):
    - dialogue: The Last Voice: "Please. I have been here so long."
    - dialogue: "Stone flakes fall from the tree like dead leaves."

  At boss.hp <= 200 (once, if Release not yet used):
    - dialogue: The Last Voice: "...it's alright. You don't have to."
    - dialogue: "The voice fades. The tree is almost gone."

  On Torren uses "Release" (once):
    - cutscene: "Torren closes his eyes. The staff hums. Green light
      flows from his hands into the petrified bark. Not to heal --
      to release. The stone softens. The tree sighs. Its voice is
      warm now, and grateful: 'Thank you.' The Last Voice dissolves
      into motes of green light. Where it stood, a single green
      shoot pushes through cracked stone."
    - boss.hp = 0 (defeat)
    - environmental: Green shoot appears in arena
    - ability_unlock: Torren learns Rootsong (HP + MP healing,
      draws from ley network)

  At boss.hp <= 0 via damage (if Release not used):
    - dialogue: "The tree shatters. Stone fragments scatter across
      the wastes. No voice. No light. Just silence."
    - Note: No green shoot. Rootsong is NOT unlocked. The trial
      is technically passed but the reward is lost. This is
      intentional -- mercy cannot be taken by force.
```

**Design Note:** The Last Voice is a boss designed to make the player
feel guilty for fighting it. Everything about its AI communicates that
it is dying regardless: Crumbling Form's passive self-damage means the
boss will kill itself in 60 turns even if the party does nothing.
Phase 2's reduced damage and pleading dialogue ("Let me go") create
intense emotional pressure to find an alternative to violence. The
Flame weakness is a deliberate temptation -- the fastest way to end the
fight is fire, but burning a dying tree that is begging for release
feels terrible. The Release mechanic (replacing Torren's Call ability)
reframes his Spiritcall class identity: he has always called spirits TO
him, but this trial teaches him to let one go. The branching outcome
(green shoot + Rootsong vs. silence + nothing) is one of the few places
where the game materially punishes the "just kill it" approach. The
declining HP dialogue creates a ticking clock that rewards paying
attention to the boss's words.

#### The Index (Maren's Trial)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Index* | Boss | 32 | 7,000 | 112 | 88 | 55 | 90 | 54 | 39 | 2,000 | 4,000 | Lost Page (100%) | Archivist's Lens (100%) | Spirit (150%) | Void (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Pallor Wastes Trial 5 |

**Modes:** 1 (Catalogue)

**AI Script:**

```
=== Scripted Encounter: The Index ===

Mode: Catalogue
  Note: The Index is not a creature. It is a vast, floating catalogue
        of every recorded death from every Pallor cycle -- thousands of
        entries, each a person's final moments. It hovers in the arena,
        pages turning slowly, radiating Void energy. It does not attack.
        It presents a binary choice. Neither option is correct. The
        resolution is a hidden third option that only appears when the
        player examines the Index instead of choosing.

        This is the most heavily scripted trial boss. There is almost
        no conventional combat.
  Priority:
    1. Default → Turn Pages (self, no damage; pages flutter;
       the Index waits for a decision)

  Counters: None

  Special Mechanic: The Binary Choice
    - On turn 2, two commands appear in Maren's ability menu:
      "Absorb" and "Destroy."
    - Absorb: Maren absorbs the Index's knowledge. Massive INT buff
      (+50%) but 90% max HP damage to Maren + permanent Despair
      status (persists after battle, cannot be cured until
      Convergence). The Index is consumed. Fight ends.
    - Destroy: Maren destroys the Index. Instant defeat -- the
      Index detonates (party_wide 9,999 damage, lethal). Game Over.
      On reload, the fight restarts from the beginning.
    - Neither option is "correct." Both are traps representing
      Maren's fundamental flaw: she believes knowledge must be
      either possessed or eliminated.

  Special Mechanic: The Third Option
    - If the player uses Examine/Inspect/Scan on the Index (any
      party member), a hidden third command appears in Maren's
      menu: "Read One Entry."
    - This is the intended resolution.

Scripted Events:
  Turn 1 (once):
    - cutscene: "The Index unfolds before Maren. Thousands of pages,
      each one a life. Each one an ending. The Pallor's perfect
      record of everyone it has consumed across every cycle."
    - dialogue: The Index: "All of it. Every name. Every scream.
      Every quiet surrender. It is yours if you want it."
    - dialogue: "Maren's eyes widen. She can feel the knowledge
      pressing against her mind like a tide."

  Turn 2 (once):
    - ability_unlock: "Absorb" and "Destroy" appear in Maren's
      command menu
    - dialogue: The Index: "Take it all. Or end it all. There is
      no middle ground for someone like you."

  On party attacks the Index:
    - dialogue: The Index: "You cannot damage a record. I am not
      alive. I am what happened."
    - Note: The Index takes damage normally (7,000 HP, Spirit
      weakness 150%), but reducing it to 0 HP through attacks
      triggers the same detonation as "Destroy" (party_wide
      9,999 damage, Game Over). The Index cannot be beaten
      through conventional combat.

  On Maren uses "Absorb" (once):
    - cutscene: "Maren reaches out. The pages surge into her --
      thousands of deaths, thousands of final breaths. Her INT
      soars. Her body buckles. Blood runs from her nose.
      She knows everything. She cannot unknow it."
    - Maren.INT *= 1.5 (permanent buff)
    - Maren.current_hp = Maren.max_hp * 0.10 (90% HP lost)
    - Maren.status = Despair (permanent, persists after battle)
    - boss.hp = 0 (defeat)
    - Note: This "wins" the fight but at enormous cost. Despair
      cannot be cured until a specific Convergence event.
      The game flags this as a tragic outcome in later dialogue.

  On Maren uses "Destroy" (once):
    - cutscene: "Maren raises her hand. The Index ignites. For one
      moment, every page burns at once -- a bonfire of memory. Then
      the detonation. White light. Nothing."
    - party_wide: 9,999 damage (lethal, Game Over)
    - Note: This is an intentional Game Over. On reload, the fight
      restarts. The player is meant to realize Destroy is not
      the answer.

  On Examine/Inspect/Scan the Index (any party member, once):
    - dialogue: "Looking closer, the pages are not abstract. Each
      entry is a person. A name. A place. A moment. Not statistics.
      Stories."
    - dialogue: "One entry catches Maren's eye. She recognizes the
      handwriting."
    - ability_unlock: "Read One Entry" appears in Maren's command
      menu (replaces Absorb and Destroy)

  On Maren uses "Read One Entry" (once):
    - cutscene: "Maren does not take all of it. She does not destroy
      any of it. She reads one entry. One person. She speaks their
      name aloud. She learns how they lived, not just how they died.
      And she grieves for them -- not as data, not as a pattern,
      but as a person she will never meet."
    - dialogue: Maren: "I don't need all of you. I just needed to
      understand one."
    - cutscene: "The Index shudders. Pages scatter like startled
      birds. The binding cracks. Not from violence -- from being
      seen. The catalogue was never meant to be read with compassion.
      It shatters. Fragments of pages drift down like snow."
    - boss.hp = 0 (defeat)
    - ability_unlock: Maren learns Pallor Sight (see corruption
      levels, reveal hidden weaknesses in Vaelith fight and
      Convergence)

  Turn 8+ (if no choice made, repeating every 3 turns):
    - dialogue: The Index: "Decide. The weight grows."
    - party_wide: Pressure Pulse (150 magic damage; the Index's
      patience erodes; creates urgency without being lethal)
```

**Design Note:** The Index is the most unconventional boss in the game.
It presents a false binary (Absorb/Destroy) that maps directly to
Maren's character flaw: her belief that knowledge is either a weapon to
be seized or a threat to be eliminated. Both options have catastrophic
consequences. The hidden third option ("Read One Entry") requires the
player to do something counterintuitive: slow down and examine the boss
instead of interacting with the choice presented. This teaches Maren --
and the player -- that the correct response to overwhelming information
is not to consume or destroy it, but to engage with it humanely, one
piece at a time. The Pressure Pulse timer (starting turn 8) prevents
indefinite stalling without making the fight unwinnable. Pallor Sight
(the unlock) is mechanically significant: it reveals hidden weaknesses
in both the Vaelith fight and the Convergence, making Maren's trial
reward the most strategically impactful of the four. The "Absorb" path
is intentionally viable but costly -- a player who chooses it is not
locked out of completing the game, but carries permanent Despair as a
narrative scar.

### Pallor Wastes

#### Vaelith, the Ashen Shepherd

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Vaelith, the Ashen Shepherd* | Boss | 34 | 50,000 | 119 | 93 | 58 | 95 | 57 | 42 | 10,000 | 15,000 | Vaelith's Quill (100%) | Ashen Scholar's Tome (100%) | Spirit (125%) | Void (50%), Frost (75%, Phase 1 only) | — | Death, Petrify, Stop, Sleep, Confusion, Despair | Pallor Wastes Section 5 (Plateau's Edge) |

**Modes:** 3 (Invulnerable, Scholar, Shepherd)

**AI Script:**

```
=== Boss Encounter: Vaelith, the Ashen Shepherd ===

Mode: Invulnerable (pre-fight, scripted)
  Note: Vaelith begins the encounter in an untargetable state behind a
        Pallor barrier. All party attacks deal 0 damage. Vaelith attacks
        the party 10 times (using Scholar-mode abilities at reduced
        power) while delivering monologue dialogue. After 10 attacks,
        a cutscene triggers: Lira forges a Pallor-piercing weapon using
        ley fragments collected during the Wastes. The barrier shatters
        and real combat begins.
  Priority:
    1. Default → Grey Lecture (party_wide, 200-250 magic damage;
       Vaelith recites from the Ashen Archive while attacking)

  Counters: None (all incoming damage = 0)

Mode: Scholar (HP 50,000-25,001)
  Priority:
    1. turn_counter % 4 == 0 → Temporal Cascade (self buff; Vaelith
       acts twice this turn; applies to the NEXT two priority checks)
    2. target.has_status(Despair) → Grey Archive (single_target with
       Despair status, 700-800 magic damage + Silence 3 turns;
       "Your grief makes you legible.")
    3. turn_counter % 3 == 0 → Cycle's Weight (party_wide debuff;
       -10% ATK and -10% DEF, stacking; persists until end of fight;
       "Another age. Another failure.")
    4. Default → Epoch's End (party_wide, 500-600 magic damage;
       grey energy radiates outward from Vaelith's tome)

  Counters: None

Mode: Shepherd (HP 25,000-0)
  Note: Vaelith closes his tome and speaks directly. All Scholar
        abilities remain available. New abilities added.
  Priority:
    1. turn_counter % 3 == 0 → Despair Pulse (party_wide, 400 magic
       damage + Despair status; grey wave emanates from Vaelith;
       "You should have stopped. Everyone stops.")
    2. target == Lira → Unraveling (single_target Lira, 600 magic
       damage; attempts to undo Lira's weapon forge; "That weapon
       is borrowed time, child.")
    3. turn_counter % 4 == 0 → Temporal Cascade (self buff; acts
       twice this turn)
    4. target.has_status(Despair) → Grey Archive (single_target,
       700-800 magic damage + Silence 3 turns)
    5. Default → Epoch's End (party_wide, 500-600 magic damage)

  Counters:
    On Lira's weapon destroyed (Reality Warp, see below):
      → Lira re-forge cutscene triggers (see Scripted Events)

Scripted Events:
  Pre-fight (10 attacks complete, once):
    - cutscene: "Vaelith raises his hand. The tenth blow falls. The
      party staggers. Lira steps forward, ley fragments burning in
      her grip. She slams them together. Light erupts -- not grey,
      not gold -- something between. A blade forms in her hand,
      forged from pure defiance."
    - ability_unlock: Lira gains Pallor-Piercing weapon (deals full
      damage to Vaelith; other party members deal 75% damage)
    - mode_switch: Invulnerable → Scholar

  At boss.hp <= 37,500 (once):
    - dialogue: Vaelith: "You are the first to draw blood in eight
      centuries."
    - dialogue: "Vaelith adjusts his spectacles. For the first time,
      he looks directly at the party."

  At boss.hp <= 25,000 (once):
    - mode_switch: Scholar → Shepherd
    - dialogue: Vaelith: "Enough scholarship. Let me show you what
      the cycle looks like from the inside."
    - dialogue: "Vaelith closes the Ashen Archive. His eyes change --
      the scholar's detachment is gone. Something colder takes its
      place."

  At boss.hp <= 12,500 (once):
    - dialogue: Vaelith: "I was the first to understand the Pallor.
      I was the first to name it. And I was the first to realize
      naming it changes nothing."
    - environmental: Arena darkens; Pallor energy intensifies;
      party members without Despair immunity glow faintly grey

  At boss.hp <= 5,000 (once):
    - dialogue: Vaelith: "You will reach the Convergence. You will
      face what I faced. And you will make the same choice I did.
      Everyone does."
    - dialogue: "His voice is not threatening. It is tired."

  Reality Warp (triggered once per Shepherd mode, at random):
    - dialogue: Vaelith: "That weapon is not yours."
    - Lira's weapon temporarily destroyed (1 turn)
    - cutscene: "Lira grits her teeth. The ley fragments respond
      to her will. The blade reforms -- different, but hers."
    - ability_unlock: Lira re-forges weapon (weapon restored with
      +10% damage bonus for remainder of fight)

  Character Interactions:
    - Torren (passive): "Torren studies Vaelith's casting patterns.
      Each spell Vaelith uses is briefly visible in Torren's
      spirit sight." → Torren reveals Vaelith's next attack
      (preview displayed above Vaelith for 1 turn)
    - Maren (passive, if Pallor Sight active): "Maren's Pallor
      Sight cuts through Vaelith's defensive aura." → Maren's
      critical hit rate doubled against Vaelith
    - Sable (passive): "Sable's shadow wraps protectively around
      the party's buffs." → Sable prevents Cycle's Weight from
      being dispelled or removed by Vaelith's abilities

  At boss.hp <= 0 (once):
    - cutscene: Vaelith falls. Extended narrative scene.
    - drop: Ashen Scholar's Tome (accessory, primary -- stat table)
    - drop: Grey Mist Essence (crafting material -- Lira's ultimate
      weapon component; secondary drop per dungeons-world.md)
```

**Design Note:** Vaelith is the Act III story boss, the culmination of
the Pallor Wastes arc. The Invulnerable pre-fight phase establishes him
as overwhelmingly powerful and makes Lira's weapon-forging moment feel
earned rather than arbitrary. The Scholar/Shepherd mode split reflects
his character arc: he begins as a detached academic cataloguing despair,
then transitions to someone who personally inflicts it. Cycle's Weight's
stacking ATK/DEF debuff creates mounting pressure -- the longer the
fight lasts, the harder it gets, mechanically reinforcing the theme that
the Pallor grinds people down over time. The character interactions give
every party member a meaningful role: Lira's re-forge is the central
mechanic, Torren provides tactical intelligence, Maren's Pallor Sight
(from The Index trial) pays off with doubled crits, and Sable protects
the party's buffs from erosion. Vaelith's dialogue at low HP is
deliberately non-villainous -- he is not evil, just exhausted and
convinced resistance is futile. This makes him a thematic mirror for the
party's own potential despair.

### Ley Line Depths

#### Ley Titan

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Ley Titan* | Boss | 28 | 18,000 | 98 | 78 | 49 | 81 | 48 | 36 | 5,000 | 8,000 | Ley Crystal Fragment (100%) | Titan's Core (100%) | — | — | Flame, Frost, Storm, Earth, Ley, Spirit, Void | Death, Petrify, Stop, Sleep, Confusion | Ley Line Depths F5 (boss arena) |

**Modes:** 3 (Whole, Fractured, Condensed)

**AI Script:**

```
=== Boss Encounter: Ley Titan ===

Mode: Whole (HP 100%-60%)
  Note: The Ley Titan is a massive crystalline construct formed from
        raw ley energy. It absorbs ALL elemental damage (Flame, Frost,
        Storm, Earth, Ley, Spirit, Void). Only physical attacks and
        non-elemental magic deal damage in this phase. The Titan moves
        slowly but hits extremely hard.
  Priority:
    1. turn_counter % 4 == 0 → Ley Pulse (party_wide, 400-500 magic
       damage; 1-turn charge -- the Titan's core glows bright blue on
       charge turn, pulses next turn; "The air hums with raw energy.")
    2. turn_counter % 3 == 0 → Confluence Tide (positional, 350-450
       magic damage to front row OR back row based on party position;
       ley energy surges along the ground; "The floor erupts with
       crystalline light.")
    3. Default → Crystal Fist (single_target highest threat, 300-400
       heavy physical damage; the Titan's arm reshapes into a massive
       crystalline hammer)

  Counters:
    On any elemental attack → Absorb (self heal equal to damage dealt;
      "The Titan drinks in the energy. Its cracks seal.")

Mode: Fractured (HP 60%-30%)
  Note: At 60% HP, the Titan fractures into three Aspects. Each Aspect
        has its own stat line but they SHARE a single HP pool (the
        remaining Titan HP). Killing any Aspect removes it from the
        field; when all three are gone, the Titan reforms in Condensed
        mode. Kill order matters: destroy Endurance FIRST to stop its
        healing (per dungeons-world.md), then Precision to prevent
        burst damage, then Strength last.

  Aspect of Strength:
    - HP: shared pool | ATK: 95 | DEF: 35 | SPD: 40
    - Priority:
      1. Default → Shatter Blow (single_target, 400-500 physical
         damage; "Raw force, unrefined.")

  Aspect of Precision:
    - HP: shared pool | MAG: 100 | MDEF: 60 | SPD: 45
    - Priority:
      1. turn_counter % 3 == 0 → Ley Lance (single_target lowest
         MDEF, 350-450 non-elemental magic damage; "A needle of
         crystallized energy.")
      2. Default → Fracture Ray (party_wide, 200-250 non-elemental
         magic damage)

  Aspect of Endurance:
    - HP: shared pool | DEF: 70 | MDEF: 70 | SPD: 30
    - Priority:
      1. any Aspect HP < 50% → Crystal Mend (heals all Aspects for
         500 HP from shared pool; "The crystal knits itself together.")
      2. turn_counter % 3 == 0 → Crystallize (self buff; +20% DEF
         and MDEF for 3 turns, stacking; "The crystal thickens.")
      3. Default → Stone Wall (reduces party damage by 25% for 1
         turn; protective barrier)

  Counters: None (Aspects do not absorb elements)

Mode: Condensed (HP 30%-0%)
  Note: The Titan reforms into a smaller, denser version of itself.
        All elemental absorption is gone. DEF is modified based on
        which Aspect was destroyed last: Endurance last = -20% DEF;
        Precision last = normal DEF; Strength last = +20% DEF.
        The Titan gains a damage reflection counter.
  Priority:
    1. turn_counter % 3 == 0 → Nexus Flare (party_wide, 500-600
       non-elemental magic damage; the condensed core overloads;
       "The crystal screams.")
    2. Default → Condensed Strike (single_target highest threat,
       350-450 physical damage; faster than Crystal Fist)

  Counters:
    On any physical attack → Resonance (reflects 30% of damage dealt
      back to attacker; "The crystal vibrates. Energy rebounds.";
      once per turn)

Scripted Events:
  At boss.hp_percent <= 60 (once):
    - cutscene: "The Titan shudders. Cracks spider across its
      crystalline body. With a sound like breaking glass amplified a
      thousandfold, it splits into three distinct forms -- one massive,
      one precise, one immovable."
    - mode_switch: Whole → Fractured
    - add_spawn: Aspect of Strength, Aspect of Precision, Aspect of
      Endurance (all share remaining HP pool)

  At boss.hp_percent <= 30 (once, when last Aspect destroyed):
    - cutscene: "The last Aspect shatters. For a moment, the arena is
      still. Then the fragments rush inward, compressing into a form
      half the Titan's original size but twice as dense. The crystal
      is no longer translucent -- it is opaque, dark, and humming
      with concentrated force."
    - mode_switch: Fractured → Condensed
    - Note: DEF modifier applied based on last Aspect destroyed

  At boss.hp <= 0 (once):
    - cutscene: "The Condensed Titan cracks from within. Light pours
      through the fractures -- not grey, not ley-blue, but warm and
      golden. The crystal dissolves into motes of light that drift
      upward and fade."
    - drop: Titan's Core (key item; used in Forgotten Forge questline)
```

**Design Note:** The Ley Titan teaches elemental strategy through
denial. Its total elemental absorption in Phase 1 forces parties to rely
on physical damage and non-elemental magic -- a significant adjustment
for magic-heavy compositions. The Fractured phase introduces a tactical
puzzle: the three Aspects share HP but have different strengths, and the
kill order directly affects the final phase's difficulty. This rewards
players who pay attention to the Aspects' behaviors and plan their focus
fire accordingly. The Condensed phase's Resonance counter (reflecting
physical damage) creates an interesting tension with Phase 1's
physical-only requirement -- the player must adapt their strategy twice.
The Titan's Core drop ties this optional dungeon boss into the Forgotten
Forge questline, rewarding exploration.

### Dry Well of Aelhart

#### Archive Keeper (Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Archive Keeper* | Boss | 32 | 3,000–12,000 | 112 | 88 | 55 | 90 | 54 | 39 | 1,500 | 3,000 | Ancient Tablet (100%) | Keeper's Index (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Dry Well F5 (Keeper's Sanctum) |

**Modes:** 1 (Puzzle)

**AI Script:**

```
=== Mini-Boss Encounter: Archive Keeper ===

Mode: Puzzle
  Note: The Archive Keeper is a stone automaton guarding the deeper
        levels of the Dry Well. It does not attack conventionally.
        Instead, it presents three pictographic questions etched in
        builder script on the walls of the Sanctum. The party must
        interpret and answer each question.

        HP is variable: the Keeper begins at 12,000 HP (worst case).
        Each correct answer reduces HP by 2,000. Each wrong answer
        RESTORES 1,000 HP and triggers a ley blast counter. With all
        three correct: 12,000 - 6,000 = 6,000 HP remaining for
        combat. With all three wrong: 12,000 + 3,000 = 15,000 HP
        (capped at 12,000) and 3 ley blasts taken. Best case: 3
        correct = 6,000 HP. The stat row lists 3,000–12,000 to
        reflect the variable range (3,000 is achievable only with
        correct answers + pre-puzzle damage from environmental traps).

  Pre-Combat Phase (3 questions):
    Question 1: A pictograph showing water flowing uphill.
      - Correct answer: "The builders reversed the flow" (select
        the inverted glyph)
      - Wrong answer: any other glyph → +1,000 HP restored,
        Ley Blast (party_wide, 300 magic damage)

    Question 2: A pictograph showing three interlocked circles.
      - Correct answer: "Unity of purpose" (select the merged glyph)
      - Wrong answer: any other glyph → +1,000 HP restored,
        Ley Blast (party_wide, 300 magic damage)

    Question 3: A pictograph showing a door with no handle.
      - Correct answer: "The door opens from within" (select the
        inward glyph)
      - Wrong answer: any other glyph → +1,000 HP restored,
        Ley Blast (party_wide, 300 magic damage)

  Combat Phase (after all 3 questions):
    Priority:
      1. turn_counter % 4 == 0 → Archive Slam (single_target highest
         threat, 350-400 physical damage; stone fist strike;
         "The Keeper enforces silence.")
      2. turn_counter % 3 == 0 → Glyph Barrage (party_wide, 250-300
         non-elemental magic damage; glowing glyphs launch from the
         walls)
      3. Default → Stone Guard (single_target highest threat, 250-300
         physical damage; measured, mechanical strikes)

  Counters:
    On wrong answer (pre-combat only) → Ley Blast (party_wide, 300
      magic damage; the Keeper's eyes flash; "Incorrect. The record
      stands.")

Scripted Events:
  Pre-combat start (once):
    - dialogue: "The Archive Keeper's eyes illuminate. Stone grinds
      against stone as it raises one massive arm, pointing to the
      wall. Pictographs glow to life -- questions older than the
      city above."
    - dialogue: Archive Keeper: "Answer. Or be answered."

  On all 3 correct (once):
    - dialogue: "The Keeper pauses. Its stone face does not change,
      but its stance shifts -- less aggressive. Almost... respectful."
    - dialogue: Archive Keeper: "You have read the builders' words.
      Now prove you can withstand their guardian."
    - Note: Combat begins with Keeper at reduced HP

  On any wrong answer (each time):
    - dialogue: Archive Keeper: "The record does not forgive error."

  At boss.hp <= 0 (once):
    - dialogue: "The Keeper's light fades. It settles into its
      alcove, stone arms crossing over its chest. The path deeper
      is clear."
    - drop: Keeper's Index (key item; unlocks builder script
      translation for Wellspring Guardian puzzle)
```

**Design Note:** The Archive Keeper is a puzzle-combat hybrid that
rewards preparation and exploration. Players who have been reading the
builder script fragments scattered throughout the Dry Well will
recognize the pictographic answers; those who rushed through will face
a harder combat with a higher HP pool plus ley blast damage. The
variable HP range (3,000–12,000) is the widest of any boss in the game,
making this encounter feel genuinely responsive to player engagement with
the dungeon's lore. The Keeper's Index drop is essential for the
Wellspring Guardian fight, creating a clear progression chain within the
Dry Well.

#### Wellspring Guardian

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Wellspring Guardian* | Boss | 36 | 28,000 | 126 | 97 | 62 | 100 | 60 | 43 | 8,000 | 12,000 | Builder's Crest (100%) | Nexus Crest (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Dry Well F7 (The Wellspring) |

**Modes:** 3 (Arms, Knowledge, Resolve)

**AI Script:**

```
=== Boss Encounter: Wellspring Guardian ===

Mode: Arms (HP 100%-60%)
  Note: The Wellspring Guardian is the Dry Well's true protector -- a
        massive builder construct of interlocking stone and ley conduits.
        Unlike the Archive Keeper, this is a full combat boss, but the
        Knowledge phase introduces puzzle mechanics mid-fight. The
        Guardian tests whether the party can match strength, wisdom, and
        endurance -- the three builder virtues.
  Priority:
    1. turn_counter % 4 == 0 → Nexus Bolt (single_target lowest MDEF,
       450-550 non-elemental magic damage; a focused beam of ley
       energy from the Guardian's core; 1-turn charge -- core glows
       on charge turn)
    2. turn_counter % 3 == 0 → Geometric Cleave (positional front row,
       400-500 physical damage; the Guardian's arms sweep in a precise
       geometric arc)
    3. Default → Stone Fist (single_target highest threat, 300-400
       physical damage; methodical, powerful strikes)

  Counters: None

Mode: Knowledge (HP 60%-30%)
  Note: The Guardian pauses combat and presents three builder-script
        puzzles, similar to the Archive Keeper but harder. If the party
        has the Keeper's Index (from Archive Keeper), puzzle hints are
        displayed. Each correct answer reduces the Guardian's HP by
        2,800 (10% of max). Each wrong answer triggers Nexus Pulse
        (party_wide AoE). After all three puzzles, combat resumes.
  Priority:
    1. Default → Present Puzzle (no damage; the Guardian projects
       builder glyphs into the air and waits)

  Counters:
    On wrong answer → Nexus Pulse (party_wide, 400-500 non-elemental
      magic damage; "The Wellspring rejects the unworthy.")

  Puzzle 1: A sequence of flowing water glyphs with one missing.
    - Correct: Complete the sequence (the spiral glyph)
    - Wrong: Nexus Pulse

  Puzzle 2: Three builder names; identify the architect of the Well.
    - Correct: Select "Aelhart" (with Keeper's Index: name is
      highlighted)
    - Wrong: Nexus Pulse

  Puzzle 3: A glyph equation representing the flow of ley energy.
    - Correct: Balance the equation (equal distribution glyph)
    - Wrong: Nexus Pulse

Mode: Resolve (HP 30%-0%)
  Note: The Guardian enters its final test -- endurance. It combines
        physical and magical attacks and introduces Builder's Weight,
        a stacking Despair mechanic. If any party member accumulates 5
        stacks of Builder's Weight, they Faint (knocked out, revivable).
        The Guardian is testing whether the party can endure suffering
        without breaking.
  Priority:
    1. turn_counter % 3 == 0 → Builder's Weight (party_wide, 200
       magic damage + 1 stack of Builder's Weight per party member;
       "The weight of ages presses down."; at 5 stacks → Faint)
    2. turn_counter % 4 == 0 → Nexus Bolt (single_target lowest MDEF,
       450-550 non-elemental magic damage; 1-turn charge)
    3. turn_counter % 2 == 0 → Geometric Cleave (positional front row,
       400-500 physical damage)
    4. Default → Stone Fist (single_target highest threat, 300-400
       physical damage)

  Counters: None

Scripted Events:
  At boss.hp_percent <= 60 (once):
    - cutscene: "The Guardian's arms lower. Its core pulses with a
      different light -- not aggressive, but inquisitive. Glyphs
      materialize in the air around the party."
    - dialogue: Wellspring Guardian: "Strength is proven. Now prove
      understanding."
    - mode_switch: Arms → Knowledge
    - Note: If party has Keeper's Index, additional dialogue:
      "The Keeper's Index warms in your pack. Faint translations
      shimmer beside each glyph."

  At boss.hp_percent <= 30 (once, after puzzles complete):
    - cutscene: "The glyphs dissolve. The Guardian straightens to
      its full height. Its core burns white-hot. The Wellspring
      behind it churns."
    - dialogue: Wellspring Guardian: "Knowledge is proven. Now prove
      resolve."
    - mode_switch: Knowledge → Resolve

  At boss.hp <= 0 (once):
    - cutscene: "The Guardian sinks to one knee. Its core dims to a
      gentle blue. The Wellspring behind it calms, its waters
      clearing for the first time in centuries. The Guardian speaks
      its final words in a voice like water over stone:"
    - dialogue: Wellspring Guardian: "The water flows. The builders
      rest."
    - dialogue: "The Guardian dissolves into the Wellspring. The
      water glows. The Dry Well is dry no longer."
    - drop: Nexus Crest (key item; major ley network restoration
      component)
```

**Design Note:** The Wellspring Guardian is a three-virtue boss that
tests the party in sequence: combat prowess (Arms), intellectual
engagement (Knowledge), and emotional endurance (Resolve). The Knowledge
phase's puzzle mechanics mid-fight break conventional boss rhythm and
reward players who completed the Archive Keeper and kept the Keeper's
Index. Builder's Weight in the Resolve phase is a deliberate Despair
analogue -- the builders' version of the Pallor's oppressive force --
creating thematic resonance between the ancient civilization and the
current crisis. The 5-stack Faint threshold creates genuine tension
without being unfair: parties with healing and status management can
sustain through it, but ignoring the stacks is fatal. The Guardian's
final words ("The water flows. The builders rest.") provide emotional
closure for the entire Dry Well dungeon arc.

### The Forgotten Forge

#### The Architect (Stage 1)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Architect (Stage 1)* | Boss | 34 | 20,000 | 0 | 93 | 58 | 95 | 57 | 42 | 5,000 | 8,000 | Forge Schematic (100%) | Architect's Hammer (100%) | Storm | — | — | Death, Petrify, Stop, Sleep, Confusion, Poison, Berserk, Despair | Forgotten Forge F5 (Anvil Vault) |

**Modes:** 2 (Shielded, Unshielded)

**AI Script:**

```
=== Boss Encounter: The Architect (Stage 1 of 2) ===

Mode: Shielded (3 Ley Anvils active)
  Note: The Architect begins the fight protected by three Ley Anvils
        positioned around the arena. While any Anvil survives, the
        Architect takes 50% reduced damage from all sources. Each
        Anvil has 2,000 HP and absorbs one element: Anvil of Flame
        (absorbs Flame), Anvil of Frost (absorbs Frost), Anvil of
        Storm (absorbs Storm). The Architect can summon Forge Sprite
        adds (2 max active). Destroying all three Anvils transitions
        to Unshielded mode.

  Ley Anvil stats:
    - Anvil of Flame: 2,000 HP | Absorbs: Flame | Weak: Frost
    - Anvil of Frost: 2,000 HP | Absorbs: Frost | Weak: Flame
    - Anvil of Storm: 2,000 HP | Absorbs: Storm | Weak: Earth

  Priority:
    1. active_adds < 2 AND turn_counter % 4 == 0 → Forge Call
       (add_spawn: 1 Forge Sprite; small construct, 1,200 HP,
       moderate physical attacks; "The Architect gestures. Molten
       metal flows into form.")
    2. turn_counter % 3 == 0 → Molten Spray (party_wide, 350-450
       fire magic damage; "Slag erupts from the forge floor.")
    3. turn_counter % 5 == 0 → Precision Cut (single_target lowest
       DEF, 500-600 physical damage; "A surgical strike from the
       master craftsman.")
    4. Default → Hammer Strike (single_target highest threat, 300-400
       physical damage; "The Architect's hammer falls with practiced
       precision.")

  Counters: None

Mode: Unshielded (all Anvils destroyed)
  Note: With all Ley Anvils destroyed, the Architect takes full damage
        and becomes enraged. Attack speed increases (SPD +10). The
        Architect no longer summons Forge Sprites but attacks faster
        and harder. The 50% damage reduction is removed.
  Priority:
    1. turn_counter % 3 == 0 → Molten Spray (party_wide, 400-500
       fire magic damage; intensified; "The forge itself rebels.")
    2. turn_counter % 2 == 0 → Precision Cut (single_target lowest
       DEF, 550-650 physical damage; "Faster now. Desperate.")
    3. Default → Hammer Strike (single_target highest threat, 350-450
       physical damage; "Each swing carries the weight of a
       civilization's final work.")

  Counters: None

Scripted Events:
  On first Anvil destroyed (once):
    - dialogue: The Architect: "You break my tools. Do you even
      understand what they were for?"
    - dialogue: "The Architect's movements become sharper. Less
      measured."

  On second Anvil destroyed (once):
    - dialogue: The Architect: "Two left. One left. It doesn't
      matter. The weapon is almost complete."
    - Note: Foreshadows the Grey Cleaver being forged regardless

  On third Anvil destroyed (once):
    - cutscene: "The last Anvil shatters. The Architect staggers.
      The protective resonance field collapses. For the first time,
      the full weight of the party's attacks lands unimpeded."
    - mode_switch: Shielded → Unshielded
    - dialogue: The Architect: "Fine. We do this the old way."

  At boss.hp <= 0 (once):
    - cutscene: "The Architect falls to one knee. His hammer clatters
      to the ground. Behind him, the forge blazes -- and within it,
      something takes shape. A massive blade, grey and pulsing with
      Pallor energy. The Architect smiles."
    - dialogue: The Architect: "Too late. It's finished."
    - phase_transition: The Architect is defeated → Grey Cleaver
      Unbound (Stage 2) begins immediately (no break, no healing)
```

**Design Note:** The Architect is the first half of a two-stage boss
fight. The Ley Anvil mechanic creates a strategic choice: focus the
boss directly at 50% damage or destroy the Anvils first for full damage.
The elemental absorption on each Anvil (and cross-weaknesses between
them) rewards parties with diverse elemental coverage. The Forge Sprite
summons during Shielded mode add pressure to split focus. The transition
to Unshielded is a relief that quickly becomes threatening as the
Architect's enraged state hits harder and faster. The fight's narrative
throughline -- the Architect is stalling while forging the Grey Cleaver
-- means the party "wins" the combat but loses the strategic objective,
setting up the Stage 2 fight with genuine dramatic tension.

#### Grey Cleaver Unbound (Stage 2)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Grey Cleaver Unbound (Stage 2)* | Boss | 36 | 25,000 | 126 | 97 | 62 | 100 | 60 | 43 | 5,000 | 8,000 | Despair Shard (100%) | Grey Cleaver (100%) | Spirit | — | — | Death, Petrify, Stop, Sleep, Confusion, Despair | Forgotten Forge F5 (Anvil Vault) |

**Modes:** 3 stance cycle (Greatsword, Whip, Shield) -- cycles every 3 turns

**AI Script:**

```
=== Boss Encounter: Grey Cleaver Unbound (Stage 2 of 2) ===

Note: The Grey Cleaver Unbound is the weapon itself, animated by
      Pallor energy. It fights autonomously, cycling through three
      stances every 3 turns in a fixed rotation: Greatsword → Whip →
      Shield → Greatsword → ... The party enters this fight with
      whatever HP/MP they had at the end of Stage 1 (no break).

      Key mechanic: Weight of Ages applies party-wide Despair
      periodically. During Shield stance, the Cleaver reflects ALL
      damage -- EXCEPT damage from party members afflicted with
      Despair, who deal +50% damage. This creates a counterintuitive
      dynamic: curing Despair during Shield stance is actively
      harmful. Smart parties will time their Despair cures around
      the stance cycle.

Stance: Greatsword (turns 1-3, 7-9, 13-15, ...)
  Note: Heavy single-target physical damage. The Cleaver takes its
        massive blade form.
  Priority:
    1. turn_counter % 3 == 0 → Executioner's Arc (single_target
       highest threat, 700-800 physical damage; 1-turn charge --
       the blade rises on charge turn, falls next turn; "The blade
       hangs in the air like a guillotine.")
    2. Default → Cleaving Strike (single_target highest threat,
       400-500 physical damage; "A brutal, efficient swing.")

  Counters: None

Stance: Whip (turns 4-6, 10-12, 16-18, ...)
  Note: Party-wide attacks with Despair chance. The Cleaver's blade
        extends into a segmented whip of grey metal.
  Priority:
    1. turn_counter % 2 == 0 → Grey Lash (party_wide, 350-400
       physical damage + 40% chance Despair per target; "The whip
       cracks across the party. Grey energy clings to the wounds.")
    2. Default → Flaying Arc (party_wide, 250-300 physical damage;
       "The whip sweeps low across the arena.")

  Counters: None

Stance: Shield (turns 7-9, 13-15, 19-21, ...)
  Note: The Cleaver plants itself blade-down and projects a Pallor
        barrier. It reflects 100% of all incoming damage back to the
        attacker -- EXCEPT damage from party members who have Despair
        status. Despair'd members not only bypass the reflection but
        deal +50% damage during Shield stance. The Cleaver does not
        attack during Shield stance.
  Priority:
    1. Default → Pallor Aegis (self; reflects all damage; no attack;
       "The blade hums behind its barrier. Waiting.")

  Counters:
    On any attack from non-Despair'd party member → Reflect (100%
      damage reflected back to attacker; "The barrier flashes. Your
      own force strikes you.")
    On any attack from Despair'd party member → No reflection;
      damage dealt at 150% (the barrier recognizes kinship with
      Despair and yields; "The grey energy parts. Your grief is
      the key.")

Periodic Effect (all stances):
  Weight of Ages: Every 5th turn (turns 5, 10, 15, 20, ...),
    party_wide Despair application (60% chance per party member;
    "The weight of the Pallor's history presses down on everyone.")

Scripted Events:
  Turn 1 (once):
    - cutscene: "The forge blazes white. The blade rises from the
      anvil -- not held by any hand. It floats, surrounded by grey
      mist, and the mist has a voice."
    - dialogue: Grey Cleaver: "I am every sword that ever cut hope
      short. I am the edge of every cycle's end."
    - dialogue: "The blade shifts form. A greatsword. Then a whip.
      Then a shield. Testing itself."

  At boss.hp_percent <= 50 (once):
    - dialogue: Grey Cleaver: "You carry despair in your bones. I
      can feel it. We are not so different."
    - dialogue: "The grey mist thickens. The Cleaver's attacks
      carry more weight."

  At boss.hp <= 0 (once):
    - cutscene: "The Grey Cleaver screams -- a metallic shriek that
      rattles the forge walls. The Pallor energy drains from the
      blade. It falls to the ground, inert. Just metal now. Heavy,
      dark, but just metal."
    - dialogue: "Lira picks up the blade. It does not resist. In her
      hands, it is a tool -- nothing more."
    - drop: Grey Cleaver (weapon; Torren-exclusive halberd-class
      polearm; ATK +55 when purified, Spirit element, +50% damage
      vs Pallor-type, Despair immunity. See equipment.md and
      see Grey Cleaver Cursed Weapon Quest section below)
```

**Design Note:** The Grey Cleaver Unbound is one of the most
mechanically innovative bosses in the game. The three-stance rotation
creates a predictable rhythm that rewards players who count turns and
plan ahead. The Shield stance's Despair reflection mechanic is the
centerpiece: it inverts the normal RPG instinct to cure debuffs
immediately, teaching players that Despair -- the game's central
negative status -- can be a tool when wielded intentionally. This
directly foreshadows the Convergence's thematic resolution, where
embracing despair rather than fighting it is key. The no-break
transition from Stage 1 creates genuine resource pressure, and the
Weight of Ages periodic Despair application ensures the Shield stance
mechanic stays relevant throughout the fight. The Grey Cleaver drop
(Torren-exclusive, with cursed→purified progression) carries the lesson forward
into gameplay: despair is most dangerous when you refuse to acknowledge
it.

#### Grey Cleaver — Cursed Weapon Quest

**Reward:** Grey Cleaver (Torren-exclusive halberd-class polearm)

An homage to FF6's Cursed Shield. The weapon that absorbed
centuries of despair in the Forgotten Forge.

**Tainted form:**
- ATK +15, DEF -10, MDEF -10, SPD -10
- Inflicts Despair on Torren at battle start
- Weak to all elements while equipped
- Cannot be sold or discarded

**Purification:** Win 100 encounters against Pallor-type enemies
with Grey Cleaver equipped on Torren. Counter does NOT reset if
unequipped. Torren must be alive when battle is won. Counter is
tracked per-weapon, not per-character.

**Purified — Pallor's End:**
- ATK +55 (best greatsword)
- Spirit element on all attacks
- +50% damage vs Pallor-type enemies
- Despair immunity for Torren
- Absorbs Spirit element

### The Convergence

#### Pallor Echo (Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Pallor Echo* | Boss | 34 | 5,000 | 119 | 93 | 58 | 95 | 57 | 42 | 2,000 | 4,000 | Grey Echo Shard (100%) | Cael's Memory (100%) | Spirit | Void | — | Death, Petrify, Stop, Sleep, Confusion, Despair | Convergence Phase 4, Wave 4 |

**Modes:** 1 (Shadow)

**AI Script:**

```
=== Mini-Boss Encounter: Pallor Echo ===

Mode: Shadow
  Note: The Pallor Echo is Cael's shadow -- a grey imitation formed
        from the Pallor's memory of who he was before the corruption
        took hold. It appears as the fourth and final wave of the
        Convergence's approach gauntlet. It uses a reduced version of
        Cael's Phase 1 moveset (slower, weaker, no counters). The
        Echo exists to foreshadow Cael's fighting style and give the
        party a preview before the real fight. Its low HP (5,000)
        makes it a quick encounter, but its stat line matches Cael's
        Phase 1 values, so individual hits still hurt.

  Priority:
    1. turn_counter % 4 == 0 → Echo Rend (single_target highest
       threat, 400-500 physical damage; a grey imitation of Cael's
       sword technique; "The shadow swings. The motion is familiar.")
    2. turn_counter % 3 == 0 → Grey Pulse (party_wide, 250-300
       magic damage; grey energy radiates outward; "A pale echo of
       real power.")
    3. Default → Shadow Strike (single_target random, 250-350
       physical damage; "The Echo mimics a stance you've never
       seen -- but someone has.")

  Counters: None

Scripted Events:
  Turn 1 (once):
    - dialogue: "A figure coalesces from the grey mist ahead. It
      wears armor you recognize. It holds a sword you've seen before.
      But its face is blank -- a memory with the identity scraped
      away."
    - dialogue: Lira: "That's... that's Cael's stance."

  At boss.hp <= 0 (once):
    - cutscene: "The Echo dissolves. As it fades, the blank face
      flickers -- and for one frame, one heartbeat, it is Cael.
      Not corrupted. Not grey. Just Cael, looking at you with
      something that might be recognition."
    - dialogue: "Then it's gone. The path to the Outer Ring is clear."
    - drop: Cael's Memory (accessory; +10% damage vs. Pallor-type
      enemies; "A fragment of who he was.")
```

**Design Note:** The Pallor Echo is deliberately understated. As the
final wave of a four-wave gauntlet, it could have been a grueling
endurance test, but instead it is brief and emotionally charged. Its
purpose is narrative, not mechanical: it shows the party (and the player)
that Cael's fighting style is burned into the Pallor's memory, and it
creates a moment of recognition that makes the upcoming Cael fight
hit harder. The blank face detail -- flickering to real Cael for one
frame at death -- is the emotional hook that carries into the boss
fight proper.

#### Cael, Knight of Despair

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Cael, Knight of Despair (Phase 1)* | Boss | 36 | 45,000 | 126 | 97 | 62 | 100 | 60 | 43 | 10,000 | 15,000 | Cael's Knight Crest (100%) | Cael's Pendant (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Convergence (Outer Ring) |
| *Cael, Knight of Despair (Phase 2)* | Boss | 38 | 35,000 | 133 | 102 | 65 | 106 | 63 | 45 | — | — | — | — | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Convergence (Outer Ring) |

**Modes:** Phase 1: Calculated (45,000 HP) / Phase 2: Pallor (35,000 HP)

**AI Script:**

```
=== Boss Encounter: Cael, Knight of Despair ===

PHASE 1: Calculated (HP 45,000; Lv 36 stat row)
  Note: Cael fights as the person the party knew -- tactical,
        disciplined, using enhanced versions of the abilities he had
        as a party member. He counters the last person who attacked
        him, making target rotation essential. He does not use Pallor
        abilities in this phase. He is fighting deliberately, testing
        whether the party is strong enough for what comes next.

  Mode: Calculated
    Priority:
      1. boss.hp_percent <= 25 → Invulnerability trigger (see
         Scripted Events)
      2. boss.hp_percent <= 50 AND turn_counter % 3 == 0 →
         Shadow Step (single_target, teleport behind target, 500-600
         physical damage, ignores 50% DEF; "You can't guard what you
         can't see.")
      3. boss.hp_percent <= 75 AND turn_counter % 4 == 0 →
         Despair Pulse (party_wide, 300-400 magic damage + 30%
         Despair chance; grey energy seeps from Cael's armor;
         "I know how this feels. I'm sorry.")
      4. turn_counter % 3 == 0 → Knight's Gambit (single_target
         lowest HP, 450-550 physical damage; calculated strike
         targeting the weakest; "Tactical. Efficient. Like he
         taught you.")
      5. Default → Disciplined Strike (single_target highest threat,
         300-400 physical damage; clean swordwork, no wasted motion)

    Counters:
      On any attack → Retaliation (single_target last attacker,
        200-250 physical damage; immediate counter; "Cael pivots.
        He was waiting for that."; once per turn)

  PHASE 2: Pallor (HP 35,000; Lv 38 stat row)
    Note: After Phase 1 ends, a Pallor surge overwhelms Cael. His
          stats increase (new stat row). His discipline dissolves into
          raw Pallor aggression. Counters are gone -- he is no longer
          calculating. He is channeling. This phase uses a separate
          35,000 HP pool.

  Mode: Pallor
    Priority:
      1. turn_counter % 3 == 0 → Grey Tide (party_wide, 400-500
         magic damage + Despair status 50% chance; "The grey crashes
         over everything. There is no technique here. Just force.")
      2. turn_counter % 2 == 0 → Pallor Rend (single_target highest
         threat, 600-700 physical damage, ignores 25% DEF; "The
         sword bites deeper than it should. The Pallor sharpens
         everything.")
      3. Default → Corrupted Strike (single_target random, 350-450
         physical damage; wild, uncontrolled swings; "This is not
         how he fights. This is how the Pallor fights through him.")

    Counters: None

Scripted Events:
  Turn 1, Phase 1 (once):
    - cutscene: "Cael stands at the center of the Outer Ring. His
      armor is grey -- not the steel-grey you remember, but Pallor
      grey. His sword hangs at his side. He does not draw it until
      you are close enough to see his face."
    - dialogue: Cael: "You came. I knew you would. I was counting
      on it."
    - dialogue: Lira: "Cael, we can --"
    - dialogue: Cael: "No. You can't. But you can do what I need
      you to do. Fight me. Prove you're strong enough for what's
      behind me."

  At boss.hp_percent <= 75, Phase 1 (once):
    - dialogue: Cael: "Good. Don't hold back. I can feel the Pallor
      pulling. If you hesitate, it takes me faster."
    - ability_unlock: Despair Pulse added to Cael's priority list

  At boss.hp_percent <= 50, Phase 1 (once):
    - dialogue: Cael: "I'm doing this for you. All of it. The
      machine, the Convergence -- I found a way to end the cycle.
      But I need to be inside it when it breaks."
    - dialogue: "His voice cracks. For a moment, the discipline
      slips."
    - ability_unlock: Shadow Step added to Cael's priority list

  At boss.hp_percent <= 25, Phase 1 (once):
    - cutscene: "Cael drives his sword into the ground. A Pallor
      barrier erupts around him -- invulnerable. He stands inside
      it, breathing hard."
    - dialogue: Cael: "I'm doing this for you. Remember that. When
      it's over, when you see what I've become -- remember I chose
      this."
    - dialogue: "The barrier shimmers. Cael's eyes close. When they
      open, they are grey."
    - Note: Invulnerability lasts 2 turns. No actions from either
      side. Narrative moment only.

  At Phase 1 HP <= 0 (once):
    - cutscene: "Cael falls to one knee. The Pallor surges. Grey
      energy erupts from every crack in his armor. His sword screams
      -- the metal warping, darkening. Cael screams too. Then he
      stops. The man who stands up is not entirely Cael anymore."
    - phase_transition: Phase 1 → Phase 2 (new stat row: Lv 38,
      35,000 HP, increased ATK/MAG/SPD)
    - dialogue: "His movements are wrong. Too fast. Too sharp. The
      discipline is gone."

  At boss.hp_percent <= 50, Phase 2 (once):
    - dialogue: Cael (strained): "I can still hear you. I can still
      -- the machine is close. Don't stop. Please don't stop."
    - dialogue: "Something in his voice is still Cael. Buried under
      the grey, but there."

  At Phase 2 HP <= 0 (once):
    - cutscene: "Cael collapses. The Pallor energy erupts from him
      in a pillar of grey light that strikes the Convergence machine
      at the arena's center. The machine activates. Gears turn.
      Energy flows. Cael lies still."
    - dialogue: Lira: "Cael? Cael!"
    - dialogue: "He doesn't move. But the machine does."
    - environmental: The Convergence machine activates; central
      platform becomes accessible
    - Note: Cael is not dead. He is drained. His fate is determined
      by the Pallor Incarnate fight.
```

**Design Note:** Cael is the emotional climax of the game's combat
design. Phase 1's counter mechanic (retaliating against the last
attacker) forces the party to rotate attackers, creating a tactical
rhythm that mirrors Cael's disciplined fighting style. The escalating
ability unlocks at 75% and 50% HP make each threshold feel like Cael
is losing control, not gaining power. The invulnerability moment at 25%
is pure narrative -- a pause that lets the dialogue breathe before the
Phase 2 transformation. Phase 2 strips away everything that made Phase 1
tactical (no counters, wild attacks, raw force) to communicate through
mechanics that Cael is gone. The "I can still hear you" dialogue at 50%
Phase 2 is the game's emotional fulcrum -- proof that the person is
still in there, fighting the corruption from inside. The machine
activation at defeat connects combat resolution directly to narrative
progression: beating Cael does not save him, it completes his plan.

#### The Pallor Incarnate

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Pallor Incarnate* | Boss | 40 | 70,000 | 140 | 108 | 68 | 111 | 66 | 48 | 0 | 0 | Pallor Core (100%) | Cael's Sword (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion, Despair | Convergence (Central Platform) |

**Modes:** 2 (Conduit, Exposed)

**AI Script:**

```
=== Final Boss Encounter: The Pallor Incarnate ===

Note: The Pallor Incarnate is the physical manifestation of the Pallor
      itself, drawn out of the cycle by Cael's machine. It is not a
      creature with motives -- it is entropy given form. It does not
      speak except through Hollow Voice (see below). The arena is the
      Central Platform of the Convergence, surrounded by the activated
      machine. No gold or exp are awarded (this is the final battle).

      "What the Stars Said" bonus: If the party completed the optional
      stargazing quest, all members carry the Resolve buff. This
      provides +25% DEF reduction against the Incarnate's attacks (the
      Incarnate's effective DEF is reduced by an additional 25%) AND
      Hollow Voice fails against Resolve-buffed members. This is the
      game's reward for engaging with optional content -- it does not
      trivialize the fight but meaningfully reduces its two most
      punishing mechanics.

Mode: Conduit (4 Pallor Crystals active)
  Note: The Pallor Incarnate begins surrounded by four Pallor Crystals
        (3,000 HP each). While any Crystal survives, each Crystal
        regenerates 500 HP per turn to itself AND the boss regenerates
        2,000 HP per turn. With all four Crystals active, the boss
        effectively heals 2,000 HP/turn -- sustainable DPS must exceed
        this. Crystals have no elemental properties and take normal
        damage from all sources.

  Pallor Crystal stats:
    - HP: 3,000 each (x4) | DEF: 40 | MDEF: 40 | SPD: 0
    - Self-regen: 500 HP/turn per crystal
    - Boss regen: 2,000 HP/turn (flat, not per crystal; removed
      only when ALL crystals destroyed)

  Priority:
    1. turn_counter % 5 == 0 → Reality Tear (single_target random,
       removes 1 party member from battle for 2 turns; "The grey
       opens. [Name] falls through. The world closes over them.";
       member returns after 2 turns at 50% HP)
    2. turn_counter % 4 == 0 → Hollow Voice (single_target, see
       below; personalized Despair attack)
    3. turn_counter % 3 == 0 → Grey Cascade (party_wide, 500-600
       magic damage; a wave of pure Pallor energy crashes across
       the platform; "Everything goes grey.")
    4. Default → Pallor Strike (single_target highest threat,
       400-500 physical damage; a tendril of grey matter lashes out)

  Counters:
    On Crystal destroyed → Pallor Surge (party_wide, 300 magic
      damage; the Incarnate shudders as a crystal dies;
      "The grey screams. It felt that.")

  Hollow Voice (personalized Despair attack):
    Note: Hollow Voice targets one party member and speaks in a voice
          from their past -- someone they lost, failed, or fear. If
          the target does not have the Resolve buff, they receive
          Despair status + 200 magic damage. If they DO have Resolve,
          Hollow Voice fails entirely ("The voice reaches for [Name].
          It finds only resolve. It recoils.")

    - Hollow Voice → Lira: speaks as her mother. "You left me in the
      grey, Lira. You left and you never came back."
    - Hollow Voice → Torren: speaks as his failed summoning. "You
      called me and I came. Why couldn't you send me back?"
    - Hollow Voice → Maren: speaks as the scholars she couldn't save.
      "You knew. You always knew. And you did nothing."
    - Hollow Voice → Sable: speaks as his sister. "You promised you'd
      protect me. Where were you?"

Mode: Exposed (all Crystals destroyed)
  Note: With all four Crystals destroyed, the Incarnate's regeneration
        stops and its DEF drops by 50%. It becomes significantly more
        vulnerable but does not change its attack patterns -- it simply
        takes more damage. The fight becomes a DPS race against the
        Incarnate's still-dangerous offensive output.

  Priority:
    1. turn_counter % 5 == 0 → Reality Tear (single_target random,
       removes 1 party member for 2 turns)
    2. turn_counter % 4 == 0 → Hollow Voice (single_target,
       personalized Despair)
    3. turn_counter % 3 == 0 → Grey Cascade (party_wide, 550-650
       magic damage; slightly stronger in desperation)
    4. Default → Pallor Strike (single_target highest threat,
       450-550 physical damage)

  Counters: None

Scripted Events:
  Turn 1 (once):
    - cutscene: "The machine's light fades. In its place, something
      rises from the platform. It has no face. It has no shape that
      holds for more than a moment. It is grey -- not a color, but
      an absence. The absence of everything that makes the world
      worth seeing."
    - dialogue: Lira: "That's it. That's the Pallor."
    - dialogue: Maren: "It's not alive. It's not dead. It's what
      happens when the difference stops mattering."

  At boss.hp_percent <= 50 (once):
    - environmental: The arena shrinks. The outer ring of the Central
      Platform crumbles into grey void. The party is confined to a
      smaller fighting area. Positional options are reduced.
    - dialogue: "The platform is breaking apart. The grey eats at
      the edges. There is less world to stand on."

  At boss.hp_percent <= 25 (once):
    - dialogue (strained, from below the platform): "Lira..."
    - dialogue: Lira: "Cael?!"
    - dialogue: Cael (barely audible): "The machine... it's working.
      I can feel it pulling the Pallor out of the cycle. Keep going.
      I can hold it open a little longer."
    - dialogue: "Somewhere beneath the platform, in the machine's
      core, Cael is still fighting."
    - Note: This confirms Cael is alive and actively maintaining
      the machine. His fate is determined by the battle's outcome.

  At boss.hp <= 0 (once):
    - cutscene: "The Pallor Incarnate shudders. Cracks of light --
      real light, warm light -- split its formless body. It does not
      scream. It does not rage. It simply... stops. The grey drains
      from the arena like water from a broken vessel. The sky above
      the Convergence, for the first time in a thousand cycles,
      shows stars."
    - dialogue: "The Pallor is not destroyed. It is diminished.
      Weakened. Pulled far enough out of the cycle that the world
      can breathe again. It will return, someday. But not today."
    - dialogue: "Cael lies at the center of the machine. His armor
      is cracked. His hair is white. He is breathing."
    - dialogue: Cael (whispering): "Did it work?"
    - dialogue: Lira: "Yeah. It worked."
    - Note: The Pallor is weakened, not destroyed. Cael is partially
      freed -- alive but permanently changed. The cycle is broken
      for this generation. The game ends here for the main story.

  "What the Stars Said" bonus (if quest completed):
    - At fight start: "The stars' light lingers in your memory. The
      Pallor's voice seems thinner here. Less certain."
    - Mechanical effect: Incarnate's DEF reduced by additional 25%;
      Hollow Voice fails against Resolve-buffed members
    - At boss.hp <= 0 (additional dialogue): "The stars are brighter
      now. You remember what they said. Not words -- a feeling. That
      the dark between stars is not empty. It is where light has not
      yet reached."
```

**Design Note:** The Pallor Incarnate is designed as a final boss that
tests everything the party has learned. The Crystal/Conduit mechanic
creates a strategic opening phase (kill Crystals to stop regen vs. focus
boss), while Hollow Voice is the game's most personal attack --
literally weaponizing each character's grief. The Resolve buff from "What
the Stars Said" is the payoff for the game's most easily missed optional
content, and its effect (nullifying Hollow Voice) is thematically
perfect: the characters who have processed their grief cannot be hurt by
it. The arena shrink at 50% creates escalating physical pressure. Cael's
voice at 25% is the emotional anchor -- confirmation that the person
inside the machine is still fighting, that the party's violence against
the Incarnate is not meaningless but is buying Cael time. The ending is
deliberately ambiguous in its hope: the Pallor is not destroyed, Cael is
not fully restored, the cycle will eventually return. But right now,
there are stars. That is enough.

---

## Post-Game Bosses (Dreamer's Fault)

### The First Scholar (Echo Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The First Scholar* | Boss | 50 | 40,000 | 175 | 132 | 84 | 136 | 81 | 57 | 10,000 | 15,000 | Ancient Manuscript (100%) | Scholar's Codex (100%) | Void (150%) | Spirit (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F4 |

**Modes:** 2 (Pattern, Accelerated)

**AI Script:**

```
=== Echo Boss Encounter: The First Scholar ===

Note: The First Scholar is the echo of a long-dead archivist who
      catalogued the world's magic into glyphs -- symbols that bind
      elemental forces into repeatable patterns. In death, the Scholar
      became the pattern. Every action follows a fixed 4-spell rotation
      that never deviates: Flame, Frost, Storm, Void. Each glyph is
      telegraphed one full turn in advance by a glowing symbol that
      appears above the Scholar's head. The entire fight is a test of
      pattern recognition: players who read the telegraphs and apply
      the correct elemental resistance each turn take minimal damage.
      Players who ignore the pattern are destroyed by escalating
      elemental pressure.

      The Scholar does not speak. The glyphs speak for it.

Mode: Pattern (HP 40,000–20,001)
  Note: The Scholar cycles through a fixed 4-spell rotation, casting
        one glyph per turn. Each glyph is telegraphed 1 turn in advance
        by a symbol that appears above the Scholar. The pattern never
        changes: Flame → Frost → Storm → Void → Flame → ...

  Glyph Rotation (fixed, repeating):
    Turn 1: Telegraph — Flame symbol appears ("A burning glyph ignites
            above the Scholar's head.")
    Turn 2: Glyph of Flame (party_wide, 500-600 Flame magic damage;
            "The glyph detonates. Fire fills the chamber.")
            Telegraph — Frost symbol appears ("A freezing glyph
            crystallizes in the air.")
    Turn 3: Glyph of Frost (party_wide, 500-600 Frost magic damage;
            "The glyph shatters. Cold bites to the bone.")
            Telegraph — Storm symbol appears ("A crackling glyph arcs
            with lightning.")
    Turn 4: Glyph of Storm (party_wide, 500-600 Storm magic damage;
            "The glyph discharges. Thunder rolls through stone.")
            Telegraph — Void symbol appears ("A hollow glyph opens
            like an eye.")
    Turn 5: Glyph of Void (party_wide, 500-600 Void magic damage;
            "The glyph collapses inward. Something is taken from you.")
            Telegraph — Flame symbol appears (cycle restarts)
    ...repeat indefinitely

  Priority:
    1. Execute next glyph in rotation (see above)
    Note: The Scholar has NO conditional behavior in this mode. It does
          not react to HP thresholds, party composition, or player
          actions. It simply follows the pattern. This is the point.

  Counters: None

Mode: Accelerated (HP 20,000 or below)
  Note: At 50% HP, the Scholar's rhythm doubles. It now casts TWO
        glyphs per turn instead of one, following the same Flame →
        Frost → Storm → Void rotation but at double speed. Telegraphs
        still appear but now show two symbols simultaneously (the
        current glyph and the next). The damage per glyph is unchanged
        -- the danger is volume, not intensity.

  Glyph Rotation (doubled):
    Each turn: Cast 2 consecutive glyphs from the rotation.
    Turn 1: Glyph of Flame + Glyph of Frost (party_wide, 500-600
            each; two glyphs fire in rapid succession)
            Telegraph — Storm + Void symbols appear
    Turn 2: Glyph of Storm + Glyph of Void (party_wide, 500-600 each)
            Telegraph — Flame + Frost symbols appear
    Turn 3: Glyph of Flame + Glyph of Frost (cycle continues)
    ...repeat indefinitely

  Priority:
    1. Execute next two glyphs in rotation (see above)
    Note: Still no conditional behavior. Still pure pattern. Faster.

  Counters: None

Scripted Events:
  Turn 1 (once):
    - cutscene: "The chamber at the end of the fourth floor is a
      library that has become a tomb. Books line every wall, their
      pages grey and still. At the center, a figure sits at a desk,
      writing. It has been writing for a very long time. The ink is
      light. The pen is bone."
    - dialogue: "The Scholar does not look up. A glyph ignites above
      its head -- the first symbol in a sequence that has not changed
      in a thousand years."

  At boss.hp_percent <= 50 (once):
    - mode_switch: Pattern → Accelerated
    - environmental: "The Scholar's writing hand accelerates. The pen
      blurs. Two glyphs now burn above its head simultaneously --
      overlapping, layered. The pattern has not changed. The pace has."
    - dialogue: "The pages beneath the pen fill faster. Whatever the
      Scholar is transcribing, it is running out of time to finish."

  At boss.hp <= 0 (once):
    - cutscene: "The Scholar's pen stops. The final glyph above its
      head gutters and dies. The figure looks up -- not at the party,
      but at the book beneath its hand. The last page is complete.
      Every glyph, every element, every pattern -- transcribed in
      light that fades as you watch."
    - dialogue: "The Scholar closes the book. Sets down the pen. And
      is gone. Not destroyed -- finished. The echo has completed what
      the living scholar could not."
    - drop: Scholar's Codex (accessory; +15% magic damage when
      exploiting elemental weakness; "Every element, catalogued.")
    - drop: Ancient Manuscript (key item; unlocks Scholar's glyph
      entries in the bestiary)
```

**Design Note:** The First Scholar is pure pattern recognition -- the
simplest possible boss mechanic executed with absolute discipline. The
fixed Flame → Frost → Storm → Void rotation never changes, never
reacts, never adapts. The telegraph system gives players complete
information one turn in advance. In Pattern mode, a prepared party
can rotate elemental resistance accessories or use Shell timing to
trivialize every hit. Accelerated mode doubles the throughput without
changing the pattern, testing whether the party can sustain their
defensive rotation under pressure. The Scholar's identity IS the
pattern: a creature of pure academic order, grinding through its
sequence even in death. There is something melancholy about fighting
an enemy that is not trying to kill you -- it is simply completing its
work, and you happen to be standing in the library.

### The Crystal Queen (Echo Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Crystal Queen* | Boss | 60 | 60,000 | 210 | 156 | 100 | 162 | 96 | 67 | 10,000 | 20,000 | Queen's Prism (100%) | Queen's Facet (100%) | Earth (150%) | Ley (75%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F8 |

**Modes:** 2 (Unified, Shattered)

**AI Script:**

```
=== Echo Boss Encounter: The Crystal Queen ===

Note: The Crystal Queen is the echo of a monarch who fused her body
      with the ley crystal throne to protect her kingdom from the
      Pallor. She became the crystal. The crystal became her. In death,
      she is a prism -- beautiful, symmetric, and lethal. Her core
      mechanic is Reflection: all single-target damage is reflected
      back at the attacker at 50% of the original value. Only AoE and
      multi-target attacks bypass Reflection entirely. Additionally,
      healing spells targeting the Queen deal damage to her instead
      (reversed polarity). The fight tests party composition and the
      willingness to abandon single-target strategies.

      The Queen speaks in refracted fragments -- the same sentence
      split across multiple voices, each slightly different.

Mode: Unified (HP 60,000–30,001)
  Note: The Crystal Queen fights as a single entity. Reflection is
        active at all times -- any single-target damage directed at
        the Queen is reflected back at the attacker for 50% of the
        damage dealt. AoE and multi-target attacks are NOT reflected.
        Healing spells targeting the Queen deal their heal value as
        damage to her instead (reversed polarity).

  Passive — Crystalline Reflection:
    - Any single_target physical or magic attack → 50% of damage
      dealt is reflected back at the attacker as magic damage
    - AoE / multi_target attacks → NOT reflected (full damage to Queen)
    - Healing spells targeting the Queen → deal heal amount as damage
      to her ("The light bends. What was meant to mend, breaks.")

  Priority:
    1. turn_counter % 5 == 0 → Prismatic Beam (party_wide, 600-700
       magic damage, random element each cast [Flame/Frost/Storm/Ley];
       "Light splits through the Queen's body. Every color at once.")
    2. turn_counter % 3 == 0 → Crystal Shards (single_target highest
       threat, 500-600 physical damage; crystalline fragments launch
       from the Queen's body; "A piece of the throne, sharpened to a
       point.")
    3. party_avg_hp > 70% → Refracted Light (party_wide, 350-400
       magic damage + Slow status 30% chance; light bends painfully
       through the arena; "The light here does not behave.")
    4. Default → Throne Strike (single_target random, 400-500
       physical damage; a crystalline arm extends impossibly far;
       "She does not move. The crystal moves for her.")

  Counters:
    On single_target attack received → Crystalline Reflection
      (single_target attacker, 50% of damage dealt as magic damage;
      "The crystal sings. Your attack returns.")

Mode: Shattered (HP 30,000 or below — phase transition)
  Note: At 50% HP, the Crystal Queen shatters into four Crystal
        Aspects. Each Aspect has 15,000 HP and reflects a different
        element (Flame, Frost, Storm, Ley). Attacks matching an
        Aspect's element are absorbed; all other damage types work
        normally. The Queen's main body is untargetable until all
        four Aspects are destroyed. Reflection is no longer active
        on the Aspects (only the unified Queen reflected).

  Crystal Aspect stats (x4):
    - Crystal Aspect (Flame): 15,000 HP | Absorbs Flame | Weak to
      Frost | DEF: 60 | MDEF: 60 | SPD: 40
    - Crystal Aspect (Frost): 15,000 HP | Absorbs Frost | Weak to
      Flame | DEF: 60 | MDEF: 60 | SPD: 40
    - Crystal Aspect (Storm): 15,000 HP | Absorbs Storm | Weak to
      Earth | DEF: 60 | MDEF: 60 | SPD: 40
    - Crystal Aspect (Ley): 15,000 HP | Absorbs Ley | Weak to
      Void | DEF: 60 | MDEF: 60 | SPD: 40

  Aspect Priority (each Aspect acts independently):
    1. turn_counter % 4 == 0 → Aspect Beam (party_wide, 300-400
       magic damage of the Aspect's element; "One facet of the
       Queen's light, concentrated.")
    2. Default → Facet Strike (single_target random, 250-350
       physical damage; a shard lashes out)

  Counters:
    On matching element attack → Absorb (Aspect heals for damage
      value; "The crystal drinks the [element]. It was always part
      of her.")

  Victory condition: Destroy all 4 Crystal Aspects. When the last
    Aspect falls, the Crystal Queen is defeated.

Scripted Events:
  Turn 1 (once):
    - cutscene: "The eighth floor opens into a throne room carved
      from a single crystal. The walls refract light that has no
      source -- bending, splitting, recombining. On the throne sits
      a woman who is also the throne. Her crown is the crystal. Her
      body is the crystal. There is no boundary between monarch and
      mineral."
    - dialogue: The Crystal Queen (fragmented, overlapping voices):
      "You are... light. Light... bends. Bends... here. Here... you
      are."
    - dialogue: Maren: "She's fused with the ley crystal. The
      reflection -- don't use single-target attacks. It'll come
      back at you."

  At boss.hp_percent <= 50 (once):
    - mode_switch: Unified → Shattered
    - cutscene: "The Queen screams -- four voices, four pitches. Her
      body fractures along invisible fault lines. Four shards of
      crystal tear free, each blazing with a different element. Flame.
      Frost. Storm. Ley. The throne is empty. The Queen is everywhere."
    - environmental: Four Crystal Aspects appear at cardinal positions
      in the arena. The Queen's central body becomes untargetable
      (crystallized shell, immune to all damage until Aspects are
      destroyed).

  At 2 Aspects destroyed (once):
    - dialogue: The Crystal Queen (strained, only two voices now):
      "Less... of me. Less... light. The dark... between..."
    - environmental: Arena lighting dims. Remaining Aspects glow
      brighter to compensate.

  At all 4 Aspects destroyed (once):
    - cutscene: "The last Aspect shatters. The fragments hang in the
      air for one impossibly long moment -- then fall. They do not
      re-form. On the empty throne, a shape remains: not crystal,
      but light. The memory of a queen who gave everything to protect
      a kingdom that is now dust."
    - dialogue: "The light fades. A crown of crystal rolls across the
      floor and comes to rest at your feet."
    - drop: Queen's Facet (accessory; reflects 25% of single-target
      magic damage back at caster; "A fragment of her reflection.")
    - drop: Queen's Prism (key item; refracts light sources in
      dungeons, revealing hidden passages)
```

**Design Note:** The Crystal Queen tests party composition and
strategic flexibility. The Reflection mechanic punishes players who
rely on single-target damage dealers -- the standard JRPG approach of
focusing fire on the boss actively hurts you here. AoE becomes the
optimal damage strategy, which inverts the usual calculus (AoE is
typically weaker per-target than single-target). The healing reversal
adds a clever wrinkle: a White Mage can deal significant damage by
casting Cure on the Queen, turning the healer into an attacker. The
Shattered phase shifts the problem entirely -- now you NEED targeted
damage against four separate enemies with elemental immunities,
requiring the party to have broad elemental coverage. The two phases
together demand versatility: AoE for Phase 1, targeted elemental
attacks for Phase 2. A one-dimensional party will struggle with at
least one phase.

### The Rootking (Echo Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Rootking* | Boss | 72 | 80,000 | 252 | 184 | 118 | 190 | 114 | 78 | 10,000 | 25,000 | Living Root (100%) | Root Crown (100%) | Flame (150%) | Earth (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F12 |

**Modes:** 2 (Rooted, Desperate)

**AI Script:**

```
=== Echo Boss Encounter: The Rootking ===

Note: The Rootking is the echo of a forest sovereign who tried to
      outlast the Pallor by growing -- endlessly, relentlessly,
      burying the corruption under layers of living wood. It did not
      work. The roots grew through the Pallor and the Pallor grew
      through the roots. Now the Rootking is both: a towering figure
      of bark and grey, regenerating endlessly, spawning lesser roots
      to defend itself. The fight is a war of attrition. The Rootking
      heals 2,000 HP per turn passively. It summons Root Weavers as
      additional targets. The only way to suppress its regeneration
      is to destroy the Root Anchor -- a hidden targetable part that
      surfaces periodically. This is a sustained DPS check with add
      management.

      The Rootking speaks in slow, creaking sentences. Its voice
      sounds like wood splitting.

Mode: Rooted (HP 80,000–40,001)
  Note: The Rootking regenerates 2,000 HP per turn (passive, not an
        action). It summons 2 Root Weavers every 3 turns. Every 5
        turns, a Root Anchor (hidden targetable part, 10,000 HP)
        surfaces for 2 turns. Destroying the Root Anchor suppresses
        all regeneration until the next Anchor appears. The party
        must balance boss DPS, add management, and Anchor destruction.

  Passive — Endless Growth:
    - Regenerate 2,000 HP per turn (suppressed while Root Anchor is
      destroyed; resumes when next Anchor surfaces)

  Root Weaver (summoned add):
    - HP: 4,000 | ATK: 107 | DEF: 90 | MAG: 92 | MDEF: 66 | SPD: 44
    - Weak: Flame | Absorbs: Earth
    - Actions: Entangling Roots (single_target, 300-400 physical
      damage + Slow 40%; "Roots erupt from the floor and coil around
      [Name]'s legs."), Root Lash (single_target, 250-300 physical)
    - Summoned in pairs every 3 turns (max 4 active at once)

  Root Anchor (hidden targetable part):
    - HP: 10,000 | DEF: 50 | MDEF: 50 | Weak: Flame (150%)
    - Appears every 5 turns, remains targetable for 2 turns
    - Destroying it suppresses Rootking regen until next Anchor cycle
    - If not destroyed within 2 turns, submerges and regen continues
    - "A massive root bulges from the floor — pulsing, feeding.
      This is what sustains him."

  Priority:
    1. turn_counter % 3 == 0 AND active_adds < 4 → Summon Root
       Weavers (spawns 2 Root Weavers; "The floor splits. Living
       wood erupts, forming shapes that move with terrible purpose.")
    2. turn_counter % 4 == 0 → Canopy Crush (party_wide, 600-700
       physical damage; the ceiling of roots collapses downward;
       "The canopy descends. Everything above you is wood and weight.")
    3. turn_counter % 3 == 0 AND active_adds >= 4 → Deeproot Slam
       (single_target highest threat, 700-800 physical damage; a
       root the size of a tree trunk drives downward; "The earth
       itself swings at you.")
    4. party_avg_hp > 60% → Thorn Volley (party_wide, 400-500
       physical damage; thorns fire in all directions; "Every
       surface bristles.")
    5. Default → Root Strike (single_target random, 500-600
       physical damage; a heavy root lashes out; "Wood cracks like
       a whip.")

  Counters:
    On Root Anchor destroyed → Rootscream (party_wide, 400 magic
      damage; the Rootking convulses as its lifeline is severed;
      "The entire chamber shudders. The Rootking screams — a sound
      like a forest falling.")

Mode: Desperate (HP 40,000 or below)
  Note: At 50% HP, the Rootking's growth accelerates. Regeneration
        doubles to 4,000 HP/turn. Root Weavers are summoned every
        2 turns instead of 3. The Root Anchor appears every 4 turns
        instead of 5 (still 2-turn window). The Rootking also gains
        Desperate Bloom — a party-wide attack that heals it for
        damage dealt. The DPS check intensifies significantly.

  Passive — Accelerated Growth:
    - Regenerate 4,000 HP per turn (suppressed while Root Anchor is
      destroyed; resumes when next Anchor surfaces)

  Root Weaver summoning: Every 2 turns (max 4 active)
  Root Anchor cycle: Every 4 turns, 2-turn window, still 10,000 HP

  Priority:
    1. turn_counter % 2 == 0 AND active_adds < 4 → Summon Root
       Weavers (spawns 2 Root Weavers; accelerated growth)
    2. turn_counter % 4 == 0 → Desperate Bloom (party_wide, 500-600
       magic damage; Rootking heals for 50% of total damage dealt;
       "Flowers erupt from the roots — beautiful, wrong. Each bloom
       drinks something from you and feeds it back to him.")
    3. turn_counter % 3 == 0 → Canopy Crush (party_wide, 700-800
       physical damage; stronger in desperation)
    4. Default → Root Strike (single_target highest threat, 600-700
       physical damage; faster, wilder)

  Counters:
    On Root Anchor destroyed → Rootscream (party_wide, 500 magic
      damage; intensified)

Scripted Events:
  Turn 1 (once):
    - cutscene: "The twelfth floor is a forest that should not exist
      underground. Trees grow from stone. Roots weave through walls.
      At the center, a figure sits on a throne of living wood — or
      the throne is growing through it, or it is growing into the
      throne. The distinction does not matter anymore. The Rootking
      is the forest. The forest is the Rootking."
    - dialogue: The Rootking (slow, creaking): "Grew... to survive.
      Grew... through everything. Still... growing. Cannot... stop."
    - dialogue: Torren: "It's regenerating constantly. We need to
      find the source — cut it off."

  Turn 5 (first Root Anchor appearance):
    - environmental: "A massive root pushes through the stone floor,
      throbbing with green-grey light. It pulses like a heartbeat.
      This is what feeds the Rootking's endless growth."
    - dialogue: Maren: "There — that root. It's the anchor. Destroy
      it before it submerges again."

  At boss.hp_percent <= 50 (once):
    - mode_switch: Rooted → Desperate
    - cutscene: "The Rootking rises from its throne. It has not moved
      in centuries. Wood screams as it separates from wood. The entire
      chamber shakes. New roots — faster, thicker, desperate — erupt
      from every surface."
    - dialogue: The Rootking: "Not... enough. Need... more. MORE."
    - environmental: Root growth accelerates visibly. The floor
      becomes a shifting carpet of living wood. Root Weavers emerge
      faster.

  At boss.hp <= 0 (once):
    - cutscene: "The Rootking falls. Not like a creature — like a
      tree. Slowly, with great weight, the trunk of its body tilts
      and crashes into the root-covered floor. The roots stop growing.
      For the first time in an age, the forest is still."
    - dialogue: "In the silence, you hear it: the sound of wood
      settling. The roots are not dying. They are resting. The echo
      of the Rootking has finally stopped growing."
    - drop: Root Crown (accessory; regenerate 3% max HP per turn;
      "It still grows. Slowly. Gently. Without desperation.")
    - drop: Living Root (key item; can be planted in the overworld
      to unlock a hidden grove with rare crafting materials)
```

**Design Note:** The Rootking is a sustained DPS check disguised as a
boss fight. The passive regeneration creates a damage floor -- if the
party cannot deal more than 2,000 (later 4,000) damage per turn net
of healing, they literally cannot win. The Root Anchor mechanic gives
skilled players a way to suppress regeneration, but it requires
target-switching discipline (stop hitting the boss, kill the Anchor,
resume). Root Weavers create add pressure that competes for the same
attention. The fundamental tension is resource allocation: every turn
spent on adds or the Anchor is a turn not spent on the boss, but
ignoring adds or the Anchor makes the boss unkillable. Flame weakness
on everything (boss, adds, Anchor) rewards parties that invested in
fire damage but does not require it. The Desperate mode at 50% is
genuinely threatening -- 4,000 HP/turn regen with adds spawning every
2 turns creates a legitimate fail state if the party's DPS cannot
keep pace.

### The Iron Warden (Echo Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *The Iron Warden* | Boss | 86 | 100,000 | 301 | 217 | 140 | 226 | 135 | 91 | 10,000 | 30,000 | Warden's Blueprint (100%) | Warden's Core (100%) | Storm (150%) | Flame (50%), Frost (50%) | — | Death, Petrify, Stop, Sleep, Confusion | Dreamer's Fault F16 |

**Modes:** 3 (Disciplined, Reinforced, Overclocked)

**AI Script:**

```
=== Echo Boss Encounter: The Iron Warden (TRUE FINAL BOSS) ===

Note: The Iron Warden is the echo of the engineer who built the
      Dreamer's Fault — a mechanical genius who fused himself with
      the fortress's defense system to become its eternal guardian.
      He is the last echo, the deepest floor, the true final challenge
      of the post-game. Everything about this fight demands tactical
      discipline.

      The Warden's core mechanic is Counter Defense — a strict
      attack-type counter system that punishes thoughtless aggression:
        - Physical attacks against the Warden trigger an immediate
          physical counter (Piston Counter, 400-500 to attacker)
        - Magic attacks against the Warden trigger an Absorb Shield
          that absorbs the NEXT magic attack completely (negating it)
        - The optimal pattern is: Physical → Magic → Physical → Magic
          (alternating). Physical triggers a counter but deals damage.
          Magic lands only if no Absorb Shield is active (i.e., magic
          was not used on the previous hit). Two consecutive magic
          attacks = second one absorbed. Two consecutive physical
          attacks = two counters taken, but no shield buildup.

      Players must track what they last used and alternate. In later
      phases, this discipline must extend to target selection with
      summoned Gear Wraiths.

      The Warden speaks in clipped, precise sentences. Military
      cadence. No wasted words.

Mode: Disciplined (HP 100,000–50,001)
  Note: The Warden fights with mechanical precision. Counter Defense
        is active. Physical attacks are countered. Magic attacks
        generate an Absorb Shield for the next magic hit. Alternating
        physical and magic is the intended rhythm.

  Passive — Counter Defense:
    - On physical attack received → Piston Counter (immediate,
      single_target attacker, 400-500 physical damage; "Gears turn.
      The counterstrike is automatic — faster than thought.")
    - On magic attack received → Absorb Shield activates (absorbs
      the next magic attack completely, negating all damage;
      "Arcane energy is drawn into the Warden's chassis. A shield
      of stolen magic shimmers into place."; shield persists until
      consumed or until a physical attack clears it)
    - Physical attack while Absorb Shield is active → shield is
      consumed (no effect), Piston Counter fires as normal
    - Magic attack while Absorb Shield is active → attack is fully
      absorbed (0 damage), no new shield generated
    Note: The optimal rotation is Physical (take counter, clear any
          shield) → Magic (no shield active, full damage) → repeat.
          Deviating costs either damage (absorbed magic) or HP
          (extra counters).

  Priority:
    1. turn_counter % 5 == 0 → Fortress Protocol (self, +30% DEF
       and MDEF for 3 turns; "The Warden's armor reconfigures.
       Plates shift, interlock, harden.")
    2. turn_counter % 4 == 0 → Siege Cannon (party_wide, 700-800
       physical damage; a massive weapon arm unfolds from the
       Warden's back; "The cannon charges. The sound alone hurts.")
    3. turn_counter % 3 == 0 → Arc Welder (single_target highest
       threat, 600-700 Storm magic damage + Slow 40%; lightning
       arcs between the Warden's hands; "Current flows. The air
       smells of ozone and old iron.")
    4. party_avg_hp > 70% → Piston Barrage (single_target lowest
       DEF, 550-650 physical damage x2 hits; rapid mechanical
       strikes; "Two hits. Precise. Mechanical.")
    5. Default → Iron Fist (single_target highest threat, 500-600
       physical damage; a heavy mechanical arm strikes; "Economy
       of motion. Nothing wasted.")

  Counters:
    On physical attack → Piston Counter (see Counter Defense above)
    On magic attack → Absorb Shield (see Counter Defense above)

Mode: Reinforced (HP 50,000–25,001)
  Note: At 50% HP, the Warden summons 2 Gear Wraiths — spectral
        engineers that serve as additional targets. Counter Defense
        now applies to the Gear Wraiths as well: attacking the wrong
        target with the wrong type triggers a PARTY-WIDE counterattack
        (Synchronous Counter, 300-400 to all). The intended strategy
        is to maintain the physical/magic alternation while also
        distributing attacks correctly across targets.

  Passive — Counter Defense (expanded):
    - All Counter Defense rules from Disciplined mode still apply
      to attacks against the Warden
    - Gear Wraith Counter Defense: each Wraith independently tracks
      the last attack type used against it
      - Physical on Wraith → Wraith counters attacker (250-300
        physical)
      - Magic on Wraith → Wraith generates Absorb Shield (same
        rules as Warden)
    - Synchronous Counter: if BOTH the Warden and any Wraith are
      hit with the same attack type on the same turn (e.g., physical
      on Warden AND physical on Wraith) → Synchronous Counter fires
      (party_wide, 300-400 physical damage; "The machines synchronize.
      Everything hits at once.")
    Note: The party must now track alternation per-target AND avoid
          matching attack types across targets in the same turn.

  Gear Wraith (summoned add, x2):
    - HP: 12,000 | ATK: 101 | DEF: 98 | MAG: 132 | MDEF: 82
    - SPD: 70 | Weak: Ley | Absorbs: — | Resists: —
    - Status Immunities: Poison, Petrify
    - Independent Counter Defense (see above)
    - Priority:
      1. turn_counter % 3 == 0 → Spectral Wrench (single_target
         random, 400-500 physical damage; "A ghostly tool swings
         with mechanical memory.")
      2. Default → Phantom Spark (single_target random, 300-400
         Storm magic damage; "Dead fingers trace circuits in the
         air. Lightning follows.")
    - If a Gear Wraith is destroyed, the Warden resummons it after
      3 turns (once per Wraith; each Wraith can only be resummoned
      once). Mark destroyed Wraiths.

  Priority:
    1. active_adds < 2 AND turn_counter >= wraith_death_turn + 3 →
       Resummon Gear Wraith (resummons 1 destroyed Wraith at 12,000
       HP; once per destroyed Wraith; "Gears grind. The fallen
       engineer reforms from scattered cogs.")
    2. turn_counter % 5 == 0 → Fortress Protocol (self, +30%
       DEF/MDEF for 3 turns)
    3. turn_counter % 4 == 0 → Siege Cannon (party_wide, 800-900
       physical damage; stronger)
    4. turn_counter % 3 == 0 → Arc Welder (single_target highest
       threat, 700-800 Storm magic damage + Slow 40%)
    5. Default → Iron Fist (single_target highest threat, 600-700
       physical damage)

  Counters:
    On physical attack → Piston Counter (500-600 to attacker;
      stronger in this mode)
    On magic attack → Absorb Shield
    On same-type attack on Warden + Wraith in same turn →
      Synchronous Counter (party_wide, 300-400)

Mode: Overclocked (HP 25,000 or below)
  Note: At 25% HP, the Warden enters Overclocked mode. It now takes
        2 actions per turn. The Absorb Shield window shrinks: the
        shield now lasts only until the Warden's next action (not the
        next magic attack), meaning the party has less time to
        capitalize. Piston Counter damage increases. Gear Wraiths
        (if alive) also gain +25% ATK/MAG. This is the final test:
        everything the party has learned about the counter pattern
        must be executed under extreme time pressure.

  Passive — Counter Defense (tightened):
    - Piston Counter: 600-700 physical damage to attacker (increased)
    - Absorb Shield: now expires at the START of the Warden's next
      turn if not consumed (window is approximately 1 party action)
    - Synchronous Counter: 400-500 party_wide (increased)
    Note: The tighter shield window means magic must land IMMEDIATELY
          after a physical attack clears the shield. Hesitation =
          wasted magic. The fight becomes a rhythm game.

  Overclocked Actions (2 per turn):
    The Warden selects from its priority list TWICE each turn. Both
    actions resolve before the next party member acts. This effectively
    doubles its offensive pressure and makes Fortress Protocol
    particularly dangerous (can buff AND attack on the same turn).

  Priority (evaluated twice per turn):
    1. turn_counter % 4 == 0 → Overclock Surge (party_wide, 900-1000
       Storm magic damage; the Warden's chassis overheats, venting
       energy in all directions; "Warning. Thermal capacity exceeded.
       Venting." The Warden does not care.)
    2. turn_counter % 3 == 0 → Siege Cannon (party_wide, 900-1000
       physical damage; maximum output)
    3. boss.hp_percent <= 10 → Last Protocol (single_target lowest
       HP, 1000-1200 physical damage, ignores 50% DEF; "Final
       directive. Eliminate all intruders."; only triggers once per
       turn despite 2-action rule)
    4. Default → Iron Fist (single_target highest threat, 700-800
       physical damage; relentless)

  Counters:
    On physical attack → Piston Counter (600-700 to attacker)
    On magic attack → Absorb Shield (tight window — expires at
      Warden's next action)
    On same-type attack on Warden + Wraith → Synchronous Counter
      (400-500 party_wide)

Scripted Events:
  Turn 1 (once):
    - cutscene: "The sixteenth floor is a foundry. Molten metal flows
      in channels cut into the stone. Gears the size of houses turn
      in the walls. At the center, standing motionless on a platform
      of interlocking iron plates, is the Warden. It is not a suit
      of armor. It is not a machine. It is both — a body rebuilt in
      iron, powered by something that refuses to stop. Its eyes are
      furnace-orange. They track you the moment you enter."
    - dialogue: The Iron Warden (clipped, precise): "Intrusion
      detected. Floor sixteen. Dreamer's Fault defense protocol
      engaged."
    - dialogue: Lira: "It's still following orders. After all this
      time."
    - dialogue: The Iron Warden: "Orders do not expire. Duty does
      not expire. You will be repelled."

  Turn 3 (once):
    - dialogue: The Iron Warden (after first counter triggers):
      "Countermeasure deployed. Analyze. Adapt. Or be destroyed."
    - Note: This dialogue fires after the party has experienced
      Counter Defense, serving as an in-fiction hint to alternate
      attack types.

  At boss.hp_percent <= 50 (once):
    - mode_switch: Disciplined → Reinforced
    - cutscene: "The Warden's chest plate splits open. Inside, where
      a heart would be, gears spin around a core of white light.
      The Warden raises both arms. From the molten channels, two
      shapes rise — translucent, skeletal, wearing the ghosts of
      engineer's uniforms. Gear Wraiths. The engineers who built
      this place, still serving."
    - add_spawn: 2 Gear Wraiths (see Reinforced mode for stats)
    - dialogue: The Iron Warden: "Reinforcements deployed. All
      units, synchronize defense protocols."
    - dialogue: Sable: "They're linked. Hit the wrong one the wrong
      way and they all hit back."

  At boss.hp_percent <= 25 (once):
    - mode_switch: Reinforced → Overclocked
    - cutscene: "The Warden's core flares. The orange glow of its
      eyes turns white. Steam erupts from every joint. The
      temperature in the foundry spikes. The gears in the walls
      spin faster. The Warden is exceeding its design parameters
      and it does not care."
    - dialogue: The Iron Warden (faster, staccato): "Overclock
      engaged. Performance limiters disengaged. Structural integrity
      non-critical. Mission priority: eliminate intruders."
    - dialogue: Maren: "It's burning itself out. It can't sustain
      this."
    - dialogue: The Iron Warden: "Sustainability: non-critical.
      Duty: absolute."
    - environmental: Arena hazard — molten metal channels overflow,
      creating hazard zones at arena edges. Party confined to center
      platform.

  At boss.hp_percent <= 10 (once):
    - dialogue: The Iron Warden (voice distorting, metal grinding):
      "System... failure... imminent. Core temperature... exceeding...
      Final directive... engaged."
    - dialogue: "Something in the Warden's voice changes. Beneath
      the mechanical precision, beneath the protocols and the duty,
      there is something else. Something that sounds almost like
      pride."
    - dialogue: The Iron Warden: "You are... adequate."

  At boss.hp <= 0 (once):
    - cutscene: "The Warden's core goes dark. The white light in
      its chest dims to orange, then red, then nothing. It stands
      for one more moment — still upright, still at attention, still
      guarding the sixteenth floor of a fortress that no longer needs
      guarding. Then, slowly, with mechanical dignity, it kneels.
      One knee on the iron platform. Head bowed. The posture of a
      soldier at rest."
    - dialogue: The Iron Warden (barely audible, the last power
      fading): "Defense protocol... complete. The Dreamer's Fault...
      is yours. You have earned... what lies beyond."
    - dialogue: "The gears in the walls slow. The molten metal cools.
      The foundry, for the first time since it was built, is quiet."
    - dialogue: Lira: "It wasn't trying to kill us. It was trying to
      make sure we were strong enough."
    - drop: Warden's Core (accessory; +20% ATK and MAG, counters
      physical attacks for 25% damage; "The core still hums. Duty
      does not expire.")
    - drop: Warden's Blueprint (key item; unlocks the Warden's
      engineering notes in the bestiary, revealing the full history
      of the Dreamer's Fault)
    - Note: Defeating the Iron Warden completes the Dreamer's Fault.
      The door behind the Warden opens to a final chamber containing
      the Dreamer's Legacy — the post-game's ultimate reward. The
      Iron Warden is the true final boss of Pendulum of Despair.
```

**Design Note:** The Iron Warden is the hardest fight in the game and
it earns that status through mechanical complexity, not stat inflation
(though its stats are the highest of any boss). The Counter Defense
system is the entire fight: physical attacks are countered, magic
attacks generate an absorb shield. The intended rhythm — physical,
magic, physical, magic — is simple to understand and demanding to
execute under pressure. Disciplined mode teaches the pattern.
Reinforced mode expands it to multiple targets with Synchronous
Counter punishing same-type attacks across targets on the same turn,
forcing the party to coordinate who attacks what and with which type.
Overclocked mode is the crucible: 2 actions per turn, tighter shield
windows, increased counter damage. The party must execute the
alternation pattern flawlessly while managing Gear Wraith adds and
healing through doubled offensive output. The Warden's dialogue
reinforces its identity — a soldier following orders, a guardian
testing worthiness. The "You are... adequate" line at 10% HP is the
game's acknowledgment that the player has mastered its deepest combat
system. The kneeling death animation communicates respect through
mechanics: the Warden does not collapse, it yields. The post-game's
final message is that the hardest challenge was never about power — it
was about discipline.

---

## Appendix: Unwinnable Encounters

### Vaelith (Siege) -- Scripted Loss

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| *Vaelith (Siege)* | Boss | 150 | 999,999 | 525 | 372 | 240 | 388 | 231 | 153 | 0 | 0 | — | — | — | — | — | Death, Petrify, Stop, Sleep, Confusion, Despair, Poison, Silence, Slow, Berserk | Valdris Siege (scripted loss) |

**Modes:** 0 (scripted loss -- not a real combat encounter)

**AI Script:**

```
=== Scripted Loss: Vaelith (Siege) ===

Note: This is NOT a real combat encounter. Vaelith appears during the
      Valdris Siege sequence as an overwhelming force. The encounter
      is designed to last approximately 5 turns before automatically
      ending in party defeat. It exists to establish Vaelith as a
      threat beyond the party's current ability and to motivate the
      Act III quest to find a way to counter him.

      All party attacks deal 0-1 damage (Vaelith's DEF/MDEF are
      astronomically high relative to party stats at this point).
      Vaelith is immune to every status effect in the game. No gold,
      exp, items, or drops are awarded. The Game Over screen after
      this fight leads to a cutscene, not a reload prompt.

  Priority:
    1. turn_counter == 1 → Grey Lecture (party_wide, 400-500 magic
       damage; "Vaelith does not even look at you. He is reading.")
    2. turn_counter == 2 → Epoch's End (party_wide, 600-700 magic
       damage; "A page turns. The world shudders.")
    3. turn_counter == 3 → Cycle's Weight (party_wide, -30% ATK/DEF;
       "Your arms feel heavy. Your purpose feels small.")
    4. turn_counter == 4 → Grey Archive (single_target Lira, 800
       magic damage + Silence; "He finally looks up. At Lira. Only
       at Lira. 'You remind me of someone.'")
    5. turn_counter >= 5 → Ashen Verdict (party_wide, 9,999 damage;
       "Vaelith closes his book. 'Enough.' The world goes grey.";
       guaranteed party wipe)

  Counters: None

Scripted Events:
  Turn 1 (once):
    - dialogue: Vaelith: "Ah. The new ones."
    - dialogue: "He does not stand. He does not draw a weapon. He
      turns a page."

  Turn 3 (once):
    - dialogue: Vaelith: "I have seen this seven hundred times. The
      heroes arrive. They fight. They lose. The cycle continues.
      You are not special. You are not even interesting."

  Turn 5+ (party wipe):
    - cutscene: "Vaelith closes the Ashen Archive. The grey washes
      over everything. The party falls. The siege is lost."
    - Note: This triggers a narrative cutscene (not a Game Over
      reload). The party wakes in a safe location, establishing
      the Act III goal: find a way to pierce Vaelith's defenses.
```

**Design Note:** Vaelith (Siege) is a scripted loss designed to feel
genuinely hopeless without feeling unfair. The player can take actions
during the ~5 turns, but nothing works -- attacks deal 0-1 damage,
status effects bounce off, and Vaelith's dialogue makes it clear he has
done this before. The encounter's purpose is threefold: establish
Vaelith as a credible final-act antagonist, motivate Lira's weapon-
forging questline (the party needs a Pallor-piercing weapon to hurt
him), and create a satisfying callback when the party returns in Act III
and the Invulnerable pre-fight phase ends with Lira shattering his
barrier. The 0 gold / 0 exp / no drops reinforce that this was never
a real fight.
