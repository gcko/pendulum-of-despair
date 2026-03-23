# Boss Compendium Design Spec

> **Sub-project 4** of Gap 1.3 (Enemy Bestiary). The final piece —
> consolidates all 29 bosses and mini-bosses into a single canonical
> reference with full AI behavior scripts.

**Goal:** Create `docs/story/bestiary/bosses.md` containing every boss
in the game with stat tables, AI scripts (modes, priority lists,
counters, scripted events), and phase mechanics. Trim act-file Boss
Notes to stub references.

**Scope:** 29 combat bosses + 1 unwinnable siege encounter across
Acts I–III, Interlude, and Post-game. No new bosses are introduced —
this consolidates and formalizes what exists in `dungeons-world.md`,
`dungeons-city.md`, and the act-file Boss Notes sections.

> **README update required:** `bestiary/README.md` currently states
> boss HP range as 6,000–70,000. This must be updated to 1,500–100,000
> to reflect mini-boss floors (Ember Drake 1,500) and post-game
> ceilings (Iron Warden 100,000). Fix during implementation.

---

## 1. AI Script Format

Every boss gets a structured AI script block that the combat engine
reads. Three layers, inspired by FF4 mode-switching and FF6 conditional
priority lists:

### 1.1 Modes / Stances

Bosses can have 1–4 named behavioral modes. Each mode has its own
priority list, stat modifiers (if any), and exit conditions.

```
Modes:
  Normal:        [default mode on battle start]
  Charge:        [telegraph mode — 1–2 turns, boss glows/charges]
  Defense:       [reduced damage, counter-focused]
  Enraged:       [below HP threshold, faster/stronger]
```

**Mode transitions** are explicit:
- HP threshold: "At 50% HP → switch to Enraged"
- Turn counter: "Every 4th turn → enter Charge for 1 turn"
- Conditional: "If all adds dead → exit Defense"

Not every boss needs multiple modes. Simple bosses (Ember Drake,
Drowned Sentinel) have a single "Normal" mode. Complex bosses
(Grey Cleaver Unbound, Vaelith) have 2–4 modes.

### 1.2 Conditional Priority Lists

Within each mode, the boss evaluates an ordered list of conditions
each turn. First matching condition fires. This is the FF6 approach.

```
Priority (Normal mode):
  1. Turn Counter: every 3rd turn → Epoch's End (party AoE)
  2. If active_adds < 2 AND turn_counter % 5 == 0 → Summon Adds
  3. If target.has_status(Despair) → Grey Archive (700-800 + Silence)
  4. If party_avg_hp > 80% → Cycle's Weight (debuff stack)
  5. Default → Crystal Slam (single physical)
```

**Condition types available:**
- `turn_counter % N == 0` — every Nth turn
- `boss.hp_percent < X` — HP threshold (for within-mode checks)
- `target.has_status(X)` — status check on current target
- `party_avg_hp > X` — party health check
- `active_adds < N` — add count check
- `party_member_count < N` — party size check
- `last_action == X` — self-memory (don't repeat)
- `target.element_last_used == X` — react to player element
- Default — fallback (always matches)

**Target selection** per ability:
- `single_target` — highest threat / random / lowest HP
- `party_wide` — hits all party members
- `positional` — front row / back row / specific slot
- `self` — self-buff or heal

### 1.3 Counter Tables

~Half of bosses have counter-attack responses. These fire immediately
after the triggering action, before the next turn.

```
Counters:
  If hit by [Flame] → Absorb (heal 25% damage dealt)
  If hit by [Physical] while in [Defense mode] → Riposte (150% ATK)
  If [target dies] → Enrage (ATK +25% for 3 turns)
```

Counters are checked independently of the priority list. A boss can
both counter AND take its normal turn. Counter frequency can be
limited: "once per turn" or "50% chance."

**Bosses with counters** (identity-reinforcing only):
- Ley Colossus — absorbs all magic (identity: physical-only puzzle)
- Ley Titan — Phase 3 Resonance (reflect damage on hit)
- Grey Cleaver Unbound — Shield stance reflects all damage
- Iron Warden — strict counter pattern (physical→counter, magic→shield)
- Corrupted Fenmother — dive/surface (untargetable counter-state)
- Cael Phase 1 — counters whoever attacked last
- Pallor Incarnate — conduit regen response
- The Crowned Hollow — Royal Guard counterattack on physical
- Archive Keeper — wrong answer restores HP (puzzle counter)
- Wellspring Guardian — wrong answer triggers Nexus Pulse

**Bosses without counters** (identity is elsewhere):
- Ember Drake, Drowned Sentinel (simple intro fights)
- Vein Guardian (Reconstruct is a scripted HP-threshold event, not a
  reactive counter — moved to Scripted Events)
- Ashen Ram (gauntlet + phases, not reactive)
- Corrupted Boring Engine (positional puzzle, not reactive)
- The Ironbound (phase transitions, Lira/Torren interaction)
- Pallor Nest Mother (add management)
- General Kole (narrative weight, conduit destruction)
- The Perfect Machine (non-combat puzzle)
- The Last Voice (release mechanic)
- The Index (dialogue puzzle)
- Vaelith (pre-fight threshold + narrative phases)
- Pallor Echo (reduced Cael moveset, gauntlet)
- First Scholar (pattern recognition, no reaction)
- Crystal Queen (reflection is a mode, not a counter)
- Rootking (regen + adds, not reactive)

### 1.4 Scripted Events

Narrative moments that interrupt normal AI flow. Triggered by HP
thresholds, turn counts, or special conditions.

```
Scripted Events:
  At 50% HP:
    - Dialogue: "I can still hear you. That makes it worse."
    - Boss gains Pallor Aura (party Despair every 3 turns)
  At 0% HP (Phase 1):
    - Boss staggers. Cutscene: Pallor surges through Cael.
    - Transition to Phase 2 (new stat row, full HP reset).
  If Torren in party AND boss.hp < 25%:
    - Dialogue: Torren speaks to spirit. "Release" command appears.
```

**Event types:**
- `dialogue` — text box, battle pauses
- `mode_switch` — change behavioral mode
- `phase_transition` — load new stat row (for multi-row bosses)
- `party_change` — member removed/added/status forced
- `add_spawn` — summon specific enemies
- `environmental` — arena change (shrink, hazard zones, etc.)
- `ability_unlock` — special command appears for party member
- `cutscene` — extended narrative moment, battle fully pauses

---

## 2. Stat Table Format

Uses the existing 19-column template from `README.md` with these
boss-specific conventions:

### 2.1 Single-Row Bosses

Bosses whose stats don't change between phases get one row. Phase
mechanics, mode switching, and ability changes live entirely in the
AI script section.

**Examples:** Vein Guardian, Ley Colossus, Forge Warden, General Kole,
trial bosses, Pallor Echo, Echo Bosses.

### 2.2 Multi-Row Bosses (Phase Stat Changes)

Bosses whose core stats (HP, ATK, DEF, weaknesses, resistances)
change between phases get separate rows. The Name column includes
the phase identifier.

**Naming convention:** `Boss Name (Phase N)` or `Boss Name (Stage Name)`

**Examples:**
- `Cael, Knight of Despair (Phase 1)` — Lv 36, 45,000 HP
- `Cael, Knight of Despair (Phase 2)` — Lv 38, 35,000 HP
- `The Architect` — Lv 34, 20,000 HP (Construct-themed)
- `Grey Cleaver Unbound` — Lv 36, 25,000 HP (Pallor-themed, separate stage)
- `Corrupted Fenmother (Surface/Dive)` — Lv 12, 18,000 HP
- `Corrupted Fenmother (Cleansing)` — Lv 12, special (wave-based, HP N/A)

### 2.3 Boss Stat Computation

Per `README.md`, boss stats use the regular curve × multipliers:

| Stat | Multiplier | Source |
|------|-----------|--------|
| HP | ×15–25 (hand-tuned) | dungeons-world.md is authoritative |
| ATK | ×1.5 | README.md |
| DEF | ×1.3 | README.md |
| MAG | ×1.8 | README.md |
| MDEF | ×1.5 | README.md |
| SPD | ×1.2 | README.md |

HP values are hand-tuned per boss to match the values already
established in `dungeons-world.md` and `dungeons-city.md`. These
dungeon files are authoritative for HP — do not recompute.

**Gold/Exp:** Hand-tuned per boss. Hard ceilings: Gold ≤ 10,000,
Exp ≤ 30,000. These caps apply even to the Pallor Incarnate and
post-game Echo Bosses.

### 2.4 Vaelith — Two Encounters

Vaelith appears in two separate encounters with different stats:

1. **Vaelith (Siege)** — Unwinnable encounter at Valdris during Act II.
   Lv 150 (game level cap), 999,999 HP, all immunities. Party attacks
   deal 0–1 damage. Scripted loss after ~5 turns. 0 Gold, 0 Exp.
   Listed as a special appendix entry, NOT counted in the 29 combat
   bosses. Stats already exist in `act-iii.md`.

2. **Vaelith, the Ashen Shepherd** — Real fight at Pallor Wastes
   Section 5 during Act III. **Lv 34**, 50,000 HP. Stats computed at
   Lv 34 with boss multipliers (ATK 93, DEF 58, MAG 95, MDEF 57,
   SPD 42 per act-iii.md). Party is Lv 30–35. This is the canonical
   combat encounter.

The pre-fight 10-attack threshold in the real fight echoes the siege —
party attacks deal 0 damage until Lira's weapon-forging cutscene.
After that, Vaelith is beatable at his Lv 34 stats.

### 2.5 Archive Keeper Variable HP

Archive Keeper has variable starting HP (3,000–12,000) based on a
knowledge puzzle. Represented as a single stat row with HP = 12,000
(worst case). A note in the AI script explains the puzzle mechanic:
each correct answer reduces HP by 2,000 before combat begins (3
correct = 6,000 reduction → 6,000 starting HP; combat starts at
minimum 3,000 with all correct + finishing reduction).

---

## 3. Document Structure

### 3.1 File: `docs/story/bestiary/bosses.md`

```markdown
# Boss & Mini-Boss Compendium

> Canonical reference for all boss encounters. AI behavior scripts,
> stat tables, phase mechanics, and scripted events.
> For regular enemy stats, see the per-act bestiary files.
> For boss narrative context, see dungeons-world.md / dungeons-city.md.

## Quick Reference

| # | Name | Act | Location | Lv | HP | Type | Phases |
|---|------|-----|----------|----|----|------|--------|
| 1 | Ember Drake | I | Ember Vein F2 | 8 | 1,500 | Beast | 1 |
| 2 | Vein Guardian | I | Ember Vein F4 | 12 | 6,000 | Boss | 2 |
| ... | ... | ... | ... | ... | ... | ... | ... |
| 29 | Iron Warden | Post | Dreamer's Fault F16 | 86 | 100,000 | Boss | 3 |

## AI Script Format Reference

[Section 1 of this spec, condensed as a reader's guide]

---

## Act I Bosses

### Ember Drake (Mini-Boss)
[Stat table row]
[AI Script block]
[Scripted Events]

### Vein Guardian
[Stat table row]
[AI Script block]
[Scripted Events]

### Drowned Sentinel (Mini-Boss)
...

### Corrupted Fenmother
[Multi-row stat table: Surface/Dive + Cleansing]
[AI Script block with modes]
[Scripted Events including wave definitions]

---

## Act II Bosses
### Ley Colossus (Mini-Boss) ...
### The Forge Warden ...
### The Ashen Ram ...

---

## Interlude Bosses
### Corrupted Boring Engine (Mini-Boss) ...
### The Ironbound ...
### The Undying Warden (Optional) ...
### Pallor Nest Mother (Optional) ...
### General Vassar Kole ...

---

## Act III Bosses

### Trial Bosses
#### The Crowned Hollow (Edren's Trial) ...
#### The Perfect Machine (Lira's Trial) ...
#### The Last Voice (Torren's Trial) ...
#### The Index (Maren's Trial) ...

### Pallor Wastes
#### Vaelith, the Ashen Shepherd ...

### Ley Line Depths
#### Ley Titan ...

### Dry Well of Aelhart
#### Archive Keeper (Mini-Boss) ...
#### Wellspring Guardian ...

### The Forgotten Forge
#### The Architect (Stage 1) ...
#### Grey Cleaver Unbound (Stage 2) ...

### The Convergence
#### Pallor Echo (Mini-Boss) ...
#### Cael, Knight of Despair ...
#### The Pallor Incarnate ...

---

## Post-Game Bosses (Dreamer's Fault)
### The First Scholar (Echo Boss) ...
### The Crystal Queen (Echo Boss) ...
### The Rootking (Echo Boss) ...
### The Iron Warden (Echo Boss) ...

---

## Appendix: Unwinnable Encounters
### Vaelith (Siege) — Scripted Loss
[Stat row: Lv 150, 999,999 HP, 0 Gold, 0 Exp]
[Note: not a real combat encounter — scripted loss after ~5 turns]
```

### 3.2 Act File Stub Format

After `bosses.md` is complete, each act file's Boss Notes section
gets trimmed to:

```markdown
### Boss Notes

**Vein Guardian** — Lv 12, 6,000 HP, Boss type, 2 phases.
Full AI script and phase mechanics: see [bosses.md](bosses.md#vein-guardian).
```

One line per boss: name, level, HP, type, phase count, link.
All detail lives in `bosses.md`.

---

## 4. Boss Roster (29 Bosses)

### 4.1 Act I (4 bosses)

| # | Name | Type | Lv | HP | Phases | Modes | Counters | Multi-Row |
|---|------|------|----|----|--------|-------|----------|-----------|
| 1 | Ember Drake | Beast | 8 | 1,500 | 1 | 1 (Normal) | No | No |
| 2 | Vein Guardian | Boss | 12 | 6,000 | 2 | 2 (Normal, Enraged) | No | No |
| 3 | Drowned Sentinel | Construct | 10 | 4,000 | 1 | 2 (Normal, Shield) | No | No |
| 4 | Corrupted Fenmother | Boss | 12 | 18,000 | 3 | 3 (Surface, Dive, Cleansing) | Yes (untargetable dive) | Yes |

**Design notes:**
- Ember Drake is the tutorial mini-boss. Simple priority list, no
  counters. Teaches "bosses hit harder, watch for telegraphs."
- Vein Guardian introduces phase transitions. Reconstruct at 50% HP
  is a scripted event (one-time 300 HP regen + 1-turn pause), not a
  counter. Teaches "bosses change behavior at HP thresholds."
- Drowned Sentinel teaches Shield mode — damage is heavily reduced
  during Barnacle Shield (DEF +100% for 2 turns), rewarding patience.
- Corrupted Fenmother is the first complex boss. Dive/surface mode
  cycling, add spawning, and the cleansing wave gauntlet. Multi-row
  because the cleansing sequence is a fundamentally different encounter.

### 4.2 Act II (3 bosses)

| # | Name | Type | Lv | HP | Phases | Modes | Counters | Multi-Row |
|---|------|------|----|----|--------|-------|----------|-----------|
| 5 | Ley Colossus | Elemental | 22 | 7,000 | 2 | 2 (Whole, Shattered) | Yes (absorb magic) | No |
| 6 | The Forge Warden | Boss | 24 | 8,500 | 2 | 2 (Programmed, Corrupted) | No | No |
| 7 | The Ashen Ram | Boss | 22 | 25,000 | 3 | 3 (Ranged, Breach, Core) | No | No |

**Design notes:**
- Ley Colossus is the "physical-only puzzle" boss. Counter table
  absorbs all magic. Teaches element immunity awareness.
- Forge Warden introduces character-specific interactions (Lira's
  Forgewright). Pipeline Drain creates a "disable the mechanic" puzzle.
- Ashen Ram is the first siege boss — gauntlet waves precede it,
  Dame Cordwyn NPC assists. Three modes map to the three engagement
  ranges (ranged → melee → exposed core).

### 4.3 Interlude (5 bosses)

| # | Name | Type | Lv | HP | Phases | Modes | Counters | Multi-Row |
|---|------|------|----|----|--------|-------|----------|-----------|
| 8 | Corrupted Boring Engine | Construct | 22 | 6,000 | 1 | 2 (Drilling, Exposed) | No | No |
| 9 | The Ironbound | Boss | 24 | 22,000 | 2 | 2 (Relentless, Hesitant) | No | No |
| 10 | The Undying Warden | Boss | 25 | 8,000 | 2 | 2 (Spectral, Eruption) | No | No |
| 11 | Pallor Nest Mother | Boss | 25 | 6,000 | 1 | 1 (Normal) | No | No |
| 12 | General Vassar Kole | Boss | 28 | 30,000 | 2 | 2 (Commander, Channeling) | No | No |

**Design notes:**
- Boring Engine teaches positional awareness (exposed Arcanite core
  on back). Mode cycles between drilling (dangerous) and exposed
  (vulnerable).
- The Ironbound is a parallel to the Ashen Ram — massive war machine,
  but this one hesitates. Lira/Torren character interactions in Phase 2
  create narrative weight.
- Undying Warden is the first optional boss. Torren's calm mechanic
  offers an alternate resolution. Two modes: spectral weapon attacks →
  ley eruption AoE.
- Pallor Nest Mother is add-management focused. No modes — just a
  relentless spawner. Kill adds or get overwhelmed.
- General Kole is the Interlude's climax. Commander mode summons
  soldiers; Channeling mode uses Ironmark conduits for AoE. Destroy
  conduits to disable the aura. Narrative payoff: the human face of
  the Pallor's corruption.

### 4.4 Act III (13 bosses)

#### Trial Bosses (4)

| # | Name | Type | Lv | HP | Phases | Modes | Counters | Multi-Row |
|---|------|------|----|----|--------|-------|----------|-----------|
| 13 | The Crowned Hollow | Boss | 30 | 8,000 | 2 | 2 (Assault, Invulnerable) | Yes (Royal Guard) | No |
| 14 | The Perfect Machine | Boss | 30 | 7,000 | 1 | 1 (Passive) | No | No |
| 15 | The Last Voice | Boss | 32 | 6,000 | 2 | 1 (Normal) | No | No |
| 16 | The Index | Boss | 32 | 7,000 | 1 | 1 (Catalogue) | No | No |

**Design notes:**
- Trial bosses are puzzle-bosses. Each tests a specific party member's
  character growth, not combat optimization.
- Crowned Hollow: Edren must Defend 3 consecutive turns. Counter
  (Royal Guard) punishes aggression — reinforces the "endure, don't
  attack" lesson.
- Perfect Machine: Does not attack. Lira must choose Dismantle over
  Repair. No combat AI — entirely scripted event chain.
- Last Voice: Dying passively. Torren must Release. Minimal AI — Stone
  Grasp and Silent Scream on simple priority list, but the real
  mechanic is the scripted Release event.
- The Index: Dialogue puzzle. Binary choice is a trap; hidden third
  option (Read One Entry) is the solution. No real combat AI.

#### Story Bosses (9)

| # | Name | Type | Lv | HP | Phases | Modes | Counters | Multi-Row |
|---|------|------|----|----|--------|-------|----------|-----------|
| 17 | Vaelith, the Ashen Shepherd | Boss | 34 | 50,000 | 2+pre | 3 (Invulnerable, Scholar, Shepherd) | No | No |
| 18 | Ley Titan | Boss | 28 | 18,000 | 3 | 3 (Whole, Fractured, Condensed) | Yes (Phase 3 Resonance) | No |
| 19 | Archive Keeper | Boss | 32 | 3,000–12,000 | 1 | 1 (Puzzle) | Yes (wrong answer = heal) | No |
| 20 | Wellspring Guardian | Boss | 36 | 28,000 | 3 | 3 (Arms, Knowledge, Resolve) | Yes (wrong answer = AoE) | No |
| 21 | The Architect | Boss | 34 | 20,000 | 1 | 2 (Shielded, Unshielded) | No | No |
| 22 | Grey Cleaver Unbound | Boss | 36 | 25,000 | 1 | 3 (Greatsword, Whip, Shield) | Yes (Shield reflects) | No |
| 23 | Pallor Echo | Boss | 34 | 5,000 | 1 | 1 (Shadow) | No | No |
| 24 | Cael, Knight of Despair | Boss | 36/38 | 45,000/35,000 | 2 | 2 (Calculated, Pallor) | Yes (Phase 1 last-attacker) | Yes |
| 25 | The Pallor Incarnate | Boss | 40 | 70,000 | 1 | 2 (Conduit, Exposed) | Yes (conduit regen) | No |

**Design notes:**
- Vaelith's real fight is at **Lv 34** (not Lv 150 — that's the
  unwinnable siege). The pre-fight 10-attack threshold is a scripted
  event (0 damage until Lira's weapon-forging cutscene). Two combat
  phases afterward use Scholar/Shepherd modes. Stats per act-iii.md.
  The Vaelith (Siege) encounter gets an appendix entry in bosses.md.
- Ley Titan's three modes map to its physical transformation. Fractured
  mode splits into 3 Aspects sharing an HP pool — kill order matters.
  Phase 3 Resonance counter punishes burst damage. Note: Ley Line
  Depths spans Acts II–III (F1–3 = Act II, F4–5 = Act III). Ley
  Colossus (Act II, F3) and Ley Titan (Act III, F5) are in the same
  dungeon but different acts.
- Archive Keeper and Wellspring Guardian are knowledge-puzzle bosses.
  Wrong answers have mechanical consequences (HP restore / AoE).
- The Architect + Grey Cleaver Unbound are a two-stage fight with no
  break. They are listed as **separate bosses** (#21 and #22) because
  they have different types, levels, and weaknesses — each gets its
  own section and stat row naturally. (This is distinct from
  "Multi-Row" which means one boss with multiple stat rows, like Cael.)
  Architect is Construct-themed (Shielded/Unshielded modes via Ley
  Anvil destruction). Grey Cleaver is Pallor-themed with the iconic
  3-stance weapon cycle.
- Cael is the emotional climax. Phase 1 is calculated (counters last
  attacker), Phase 2 is raw Pallor aggression. Multi-row because level,
  HP, and resistances change between phases.
- Pallor Incarnate is the final boss. Conduit/Exposed modes — destroy
  4 conduit crystals to stop regen and halve defense. "What the Stars
  Said" bonus (completing all trials) weakens Hollow Voice.

### 4.5 Post-Game — Dreamer's Fault (4 bosses)

| # | Name | Type | Lv | HP | Phases | Modes | Counters | Multi-Row |
|---|------|------|----|----|--------|-------|----------|-----------|
| 26 | The First Scholar | Boss | 50 | 40,000 | 2 | 2 (Pattern, Accelerated) | No | No |
| 27 | The Crystal Queen | Boss | 60 | 60,000 | 2 | 2 (Unified, Shattered) | No | No |
| 28 | The Rootking | Boss | 72 | 80,000 | 2 | 2 (Rooted, Desperate) | No | No |
| 29 | The Iron Warden | Boss | 86 | 100,000 | 3 | 3 (Disciplined, Reinforced, Overclocked) | Yes (strict counter pattern) | No |

**Design notes:**
- Echo Bosses test distinct combat disciplines, escalating in
  difficulty. Each represents a fallen civilization that tried to
  stop the Pallor.
- First Scholar: Pattern recognition. 4-spell rotation, then doubles
  to 2 spells/turn. Players who learn the cycle can pre-buff.
- Crystal Queen: Reflection puzzle at 50%. Only AoE bypasses. Shatters
  into 4 Aspects in Phase 2 — each reflects a different element.
- Rootking: Endurance fight. Regen + adds. Root Anchor windows are
  the key — destroy it during its 2-turn appearance to stop regen.
  Phase 2 doubles pressure.
- Iron Warden: True final boss of the game. Strict counter pattern
  rewards disciplined play. Phase 2 adds Gear Wraiths. Phase 3
  overclocks — 2 actions/turn, shrinking counter windows. The ultimate
  test.

---

## 5. Stat Computation Reference

For implementation, compute boss stats from level using:

```
Base_ATK(level) = floor(level × 1.6 + 8)
Boss_ATK(level) = floor(Base_ATK(level) × 1.5)

Base_DEF(level) = floor(level × 1.2 + 5)
Boss_DEF(level) = floor(Base_DEF(level) × 1.3)

Base_MAG(level) = floor(level × 1.4 + 6)
Boss_MAG(level) = floor(Base_MAG(level) × 1.8)

Base_MDEF(level) = floor(level × 1.0 + 4)
Boss_MDEF(level) = floor(Base_MDEF(level) × 1.5)

Base_SPD(level) = floor(level × 0.8 + 8)
Boss_SPD(level) = floor(Base_SPD(level) × 1.2)
```

HP is hand-tuned per boss (from dungeons-world.md / dungeons-city.md).
MP = floor(level × 3.5) for bosses that cast; 0 for physical-only.

**Verification samples (boss multipliers applied):**

| Lv | ATK | DEF | MAG | MDEF | SPD |
|----|-----|-----|-----|------|-----|
| 8 | 30 | 18 | 30 | 18 | 16 |
| 10 | 36 | 22 | 36 | 21 | 19 |
| 12 | 40 | 24 | 39 | 24 | 20 |
| 22 | 64 | 40 | 64 | 39 | 30 |
| 24 | 69 | 42 | 70 | 42 | 32 |
| 25 | 72 | 45 | 73 | 43 | 33 |
| 28 | 78 | 49 | 81 | 48 | 36 |
| 30 | 84 | 53 | 86 | 51 | 38 |
| 32 | 88 | 55 | 90 | 54 | 39 |
| 34 | 93 | 58 | 95 | 57 | 42 |
| 36 | 97 | 62 | 100 | 60 | 43 |
| 38 | 102 | 65 | 106 | 63 | 45 |
| 40 | 108 | 68 | 111 | 66 | 48 |
| 50 | 132 | 84 | 136 | 81 | 57 |
| 60 | 156 | 100 | 162 | 96 | 67 |
| 72 | 184 | 118 | 190 | 114 | 78 |
| 86 | 217 | 140 | 226 | 135 | 91 |
| 150 | 372 | 240 | 388 | 231 | 153 |

### 5.1 Boss Gold/Exp Guidelines

Boss rewards are hand-tuned (not formula-derived). Guidelines:

| Act | Gold Range | Exp Range | Rationale |
|-----|-----------|-----------|-----------|
| Act I | 200–1,500 | 500–3,000 | Early game, meaningful but not economy-breaking |
| Act II | 1,500–4,000 | 3,000–8,000 | Mid-game, funds equipment upgrades |
| Interlude | 2,000–5,000 | 4,000–10,000 | Varies by boss difficulty |
| Act III | 3,000–10,000 | 6,000–20,000 | Late game; Vaelith at 10,000 Gold (ceiling) reflects his unique Lv 150 siege origin |
| Post-game | 5,000–10,000 | 10,000–30,000 | Near caps, respects hard ceiling |

**Hard ceilings:** Gold ≤ 10,000, Exp ≤ 30,000. No exceptions.

---

## 6. Act File Stub Migration

After `bosses.md` is written, each act file's Boss Notes section
gets replaced with a stub. The stat table row for each boss REMAINS
in the act file (for encounter table completeness). Only the extended
Boss Notes prose is removed.

**Before (current act-i.md):**
```markdown
### Boss Notes

#### Vein Guardian

The Vein Guardian is a crystalline construct...
[20-40 lines of phase descriptions, abilities, strategy notes]
```

**After:**
```markdown
### Boss Notes

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Ember Drake** (Mini-Boss) — Lv 8, 1,500 HP, Beast. 1 phase.
- **Vein Guardian** — Lv 12, 6,000 HP, Boss. 2 phases.
- **Drowned Sentinel** (Mini-Boss) — Lv 10, 4,000 HP, Construct. 1 phase.
- **Corrupted Fenmother** — Lv 12, 18,000 HP, Boss. 3 phases.
```

**Important:** The boss stat table ROWS stay in the act files. Only
the Boss Notes prose is trimmed. This preserves the act file as a
complete encounter reference (all enemies in that act, including
bosses, in one table).

---

## 7. Cross-Reference Sources

Every value in `bosses.md` must trace to a canonical source:

| Data | Authoritative Source |
|------|---------------------|
| Boss HP | dungeons-world.md, dungeons-city.md |
| Phase mechanics | dungeons-world.md, dungeons-city.md |
| Abilities/attacks | dungeons-world.md, dungeons-city.md |
| Scripted events (dialogue, party changes) | dungeons-world.md, events.md |
| Stat formulas | bestiary/README.md |
| Boss multipliers | bestiary/README.md |
| Type rules, immunities | bestiary/README.md |
| Elemental profiles | Act file stat tables |
| Existing boss stat rows | Act file stat tables |
| Trial unlock abilities | dungeons-world.md |
| Echo Boss mechanics | optional.md Boss Notes |
| Gold/Exp caps | bestiary/README.md |

**Rule:** If `dungeons-world.md` says 18,000 HP and a previous act
file says 15,000 HP, `dungeons-world.md` wins. Correct the act file.

---

## 8. What This Spec Does NOT Cover

- **New bosses.** All 29 bosses already exist in the dungeon files.
  This spec consolidates, it does not invent.
- **Cael's Echo (Dreamer's Fault F20).** This is a non-combat narrative
  encounter, not a boss. It appears in `optional.md` already.
- **Regular enemy AI.** Only bosses get AI scripts. Regular enemies
  use simple weighted-random ability selection (no priority lists).
- **Damage numbers.** Ability damage values reference combat-formulas.md.
  The AI script says WHICH ability fires, not HOW MUCH damage it does.
  Damage = ATK²/6 - DEF (physical) or MAG × power/4 - MDEF (magic)
  per combat-formulas.md.
