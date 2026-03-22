# Enemy Bestiary Design Spec (Gap 1.3 — Sub-project 2a: Act II)

**Date:** 2026-03-22
**Status:** Draft
**Scope:** Populate act-ii.md with all Act II enemies: Ley Line Depths
(floors 1–3), Ashmark Factory Depths, Bellhaven Smuggler Tunnels,
Valdris Siege castle defense gauntlet, and Overworld Act II. Add 9 new
palette-swap families. Update palette-families.md with Tier 2 entries
for 11 existing families.
**Gap:** 1.3 (Enemy Bestiary)
**Depends On:** Sub-project 1 (COMPLETE — PR #19 merged)

---

## 1. Purpose

Populate the Act II bestiary file with ~33 enemies across 5 areas.
Act II is where the game world opens up — the overworld has diverse
biomes, dungeons span industrial and natural environments, and the
Carradan military faction introduces flying units with spawn-on-death
mechanics. The Pallor is foreshadowed through 2 specific enemies but
does not dominate encounters yet.

This is the first of two PRs for Sub-project 2. The second PR covers
Interlude dungeons (interlude.md).

## 2. Established Rules (Do NOT Redesign)

All of the following are canonical from Sub-project 1 (PR #19). This
spec uses them without modification:

- **Stat template:** 19 columns (per bestiary/README.md)
- **8 enemy types** with gameplay effects (per README.md)
- **Stat scaling formulas** (per README.md Section: Stat Scaling)
- **Reward formulas:** Logistic bounded growth (Gold cap 10,000,
  Exp cap 30,000) with threat multipliers
- **Role adjustments:** Swarm up to -32% HP, Glass cannon up to -28%
  DEF, Caster up to -23% ATK, Tank up to -22% SPD
- **Palette-swap system:** Variants use stat formulas at their own
  level with ±15–25% role adjustments
- **Enemy LCK:** Fixed 5% crit rate for all enemies
- **Boss default immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Formatting:** Em dash (—) for "none" in tables, en dash (–) for
  numeric ranges

## 3. Act II Enemy Roster (33 entries)

### 3.1 Ley Line Depths — Floors 1–3 (Level 16–22)

8 enemies: 7 regular + 1 mini-boss.

| Name | Family | Tier | Lv | Type | Threat | Role/Notes |
|------|--------|------|----|------|--------|------------|
| Extraction Drone | Automata | 1 | 16 | Construct | Low | Compact mining bot, physical damage |
| Cave Vermin | Vermin | 2 | 16 | Beast | Low | Tier 2 Vermin, +Rabid Frenzy (2-hit) |
| Cave Crawler | Crawler | 1 | 17 | Beast | Standard | Hard shell, high DEF, back attack bonus on underbelly |
| Prism Moth | Moth | 1 | 18 | Elemental | Low | Swarm, Refraction (group magic buff), individually weak |
| Ley Wisp | Wisp | 2 | 18 | Elemental | Standard | Tier 2 Wisp, absorbs Flame, weak to Frost |
| Deep Serpent | Serpent | 2 | 19 | Beast | Standard | Ley-infused, Constrict (Stun + DoT) |
| Crystal Sentry | Crystal | 2 | 20 | Elemental | Standard | Slow, heavy physical, shrapnel AoE on death |
| *Ley Colossus* | — (unique) | — | 22 | Elemental | Dangerous | **Mini-boss.** Absorbs magic, vulnerable to physical. Phase 1: crystal fists + Ley Pulse. Phase 2 (50%): shatters/reforms, faster, gains Prism Beam. |

### 3.2 Ashmark Factory Depths (Level 18–24)

5 enemies: 3 regular + 1 unique + 1 boss.

| Name | Family | Tier | Lv | Type | Threat | Role/Notes |
|------|--------|------|----|------|--------|------------|
| Forge Roach | Roach | 1 | 18 | Beast | Low | Industrial swarm pest, low damage, groups of 4–6 |
| Pipe Wraith | Wraith | 1 | 19 | Spirit | Standard | Ley entity from leaking pipes, ignores 25% DEF |
| Overclocked Automata | Automata | 2 | 20 | Construct | Standard | Tier 2 Automata, fast, erratic targeting |
| Pallor-Touched Worker | — (unique) | — | 20 | Humanoid | Standard | **Pallor foreshadowing.** Non-lethal — "wakes up" confused at 0 HP. Cannot be killed. Party must defeat without lethal intent. Narratively powerful. |
| *The Forge Warden* | — | — | 24 | Boss | Boss | **Boss.** 8,500 HP (per dungeons-city.md). Drayce-series automaton. Phase 1: Ley Bolt, Shield Protocol, Containment Pulse, Pipeline Drain (Lira disables). Phase 2 (50%): erratic targeting, Overload Beam (2-turn charge, interruptible), System Failure (random freeze), Emergency Protocol (self-destruct, Lira Override aborts). Weak: Storm (150%), Spirit (125%). Resists: Flame (50%), Earth (75%). Immune: Petrify, Poison. |

### 3.3 Bellhaven Smuggler Tunnels (Level 16–20)

3 enemies: all regular.

| Name | Family | Tier | Lv | Type | Threat | Role/Notes |
|------|--------|------|----|------|--------|------------|
| Smuggler Thug | Bandit | 2 | 17 | Humanoid | Low | Tier 2 Bandit, coastal variant. Ambush Strike + Smoke Bomb (Blind) |
| Sea Crawler | Crawler | 2 | 18 | Beast | Standard | Tier 2 Crawler, coastal. High DEF, weak to Storm |
| Tide Wraith | Wraith | 2 | 19 | Spirit | Standard | Tier 2 Wraith, water-bound. Frost attacks, physical 50% reduced |

### 3.4 Valdris Siege — Castle Defense Gauntlet (Level 18–22)

6 enemies: 3 regular + 1 spawn + 1 siege unit + 1 boss.

**Pre-boss random encounters** (while traversing the battlefield):

| Name | Family | Tier | Lv | Type | Threat | Role/Notes |
|------|--------|------|----|------|--------|------------|
| Compact Soldier | Soldier | 1 | 18 | Humanoid | Low | Carradan infantry, pairs, cover each other |
| Compact Engineer | Soldier | 1 | 19 | Humanoid | Standard | Repairs siege equipment, heals allied Constructs |

**Boss gauntlet** (scripted waves, FF4 castle defense style):

| Name | Family | Tier | Lv | Type | Threat | Role/Notes |
|------|--------|------|----|------|--------|------------|
| Siege Ballista Crew | Soldier | 1 | 20 | Humanoid | Standard | Ranged, targets back row, 2-enemy fixed group |
| Compact Gyrocopter | Airborne | 1 | 20 | Construct | Standard | **Flying.** Bomb Run (AoE), Strafe (back-row). High melee evasion. Spawns Downed Pilot on death. |
| Downed Pilot | Airborne (spawn) | — | 18 | Humanoid | Low | **Spawned by Gyrocopter death.** Sword + Pistol (ranged). Stealable. |
| *The Ashen Ram* | — | — | 22 | Boss | Boss | **Boss.** 25,000 HP (per dungeons-world.md). Pallor-corrupted siege construct. 3 phases. See Section 4.1. |

**Gauntlet wave structure:**

- **Wave 1:** 4 Compact Soldiers + 2 Engineers
  (Establish the army. Engineers heal soldiers — focus them first.)
- **Wave 2:** 3 Compact Soldiers + 2 Siege Ballista Crews
  (Ranged pressure. Back-row targeting forces defensive play.)
- **Wave 3:** 2 Compact Gyrocopters + 2 Soldiers
  (Air support. "They have flying units!" Spawn mechanic debut.)
- **Breather:** Dame Cordwyn rallies. Party can heal, save.
  Brief cutscene — the Ashen Ram appears on the horizon.
- **Boss:** The Ashen Ram breaches the wall. 3-phase fight.

**Dame Cordwyn** (Guest NPC): 5,000 HP, ATK 85, DEF 70. Shield Wall
(50% damage reduction to one ally for 1 turn), Rally Cry (removes Despair, 3-turn cooldown). Fights alongside party
during all waves and the boss. Cannot be controlled by the player.

### 3.5 Overworld Act II (Level 13–22)

11 enemies: 9 regular + 1 rare + 1 new family base.

| Name | Family | Tier | Lv | Type | Threat | Biome |
|------|--------|------|----|------|--------|-------|
| Tunnel Mite | Mite | 2 | 14 | Beast | Low | Mountain caves |
| Coastal Crab | — | — | 14 | Beast | Low | Bellhaven coast |
| Road Viper | Serpent | 2 | 15 | Beast | Low | Roads, grassland |
| Sewer Leech | Leech | 2 | 15 | Beast | Low | Coastal, swamp |
| Highwayman | Bandit | 2 | 15 | Humanoid | Standard | Roads between cities |
| Iron Beetle | Beetle | 2 | 16 | Beast | Low | Mountain paths |
| Dire Wolf | Wolf | 2 | 16 | Beast | Standard | Forest, mountain |
| Meadow Sprite | Sprite | 2 | 16 | Spirit | Standard | Grassland, forest |
| Mountain Hawk | Hawk | 1 | 17 | Beast | Standard | Mountain, highland |
| Razorback | Boar | 2 | 17 | Beast | Standard | Grassland |
| Thornwood Treant | Treant | 1 | 19 | Elemental | Dangerous | Deep forest only (rare, ~5% encounter rate) |

## 4. Boss Details

### 4.1 The Ashen Ram (Valdris Siege Boss)

> **Note:** docs/story/dungeons-world.md is authoritative for exact
> Ashen Ram phase mechanics. The following summarizes for bestiary purposes.

- **HP:** 25,000 (per dungeons-world.md, combat-formulas.md boss table)
- **Type:** Boss
- **Level:** 22

**Phase 1 — Ranged Engagement (25,000–15,000 HP):**
- Battering Advance: cumulative party damage, 1-turn charge
- Despair Pulse (passive): 10% Despair chance each turn, all party
- Compact Escalade: summons 2 Compact Soldiers (once per phase)
- Lord Haren's Orders: if Cordwyn HP > 50%, Ram targets her
  preferentially (player must keep Cordwyn alive)

**Phase 2 — The Breach (15,000–7,500 HP):**
- Drill Arm: heavy single-target physical
- Pallor Shrapnel: AoE + Despair (30% chance)
- Engine Surge: self ATK buff, 2-turn duration

**Phase 3 — The Pallor Core (below 7,500 HP):**
- Despair Pulse (active): guaranteed Despair attempt each turn
- Core Overload: 3-turn charge, massive AoE (must burst before it fires)
- Cordwyn's HP drops to critical — cutscene, party must finish fast

**Weakness:** Storm (150%), Flame (125% to core only in Phase 3)
**Resistance:** Earth (absorbs), Frost (75%)
**Immunities:** Death, Petrify, Stop, Sleep, Confusion
**Drops:** Pallor-Laced Iron (crafting), Compact Battle Standard (key item)

### 4.2 The Forge Warden (Ashmark Factory Boss)

- **HP:** 8,500 (per dungeons-city.md)
- **Type:** Boss
- **Level:** 24

**Phase 1 — Programmed Defense (8,500–4,250 HP):**
- Ley Bolt: 350–400 single-target magic, fast cast
- Shield Protocol: absorbs 1,000 damage, 4-turn cooldown
- Containment Pulse: 250–300 AoE + pushback, marks contaminated zones
- Pipeline Drain: heals 500 HP (Lira's Forgewright reroutes, disables)

**Phase 2 — Corrupted Logic (below 4,250 HP):**
- All Phase 1 attacks with semi-random targeting
- Overload Beam: 500–600 line AoE, 2-turn charge (interrupt with 800+
  physical damage)
- System Failure: random 1-turn freeze (free damage window)
- Emergency Protocol: below 20%, 3-turn self-destruct (Lira Override
  aborts — unique interaction)

**Weakness:** Storm (150%), Spirit (125%)
**Resistance:** Flame (50%), Earth (75%)
**Immunities:** Death, Petrify, Stop, Sleep, Confusion, Poison
  (Boss-type defaults + Poison per-boss extension. Note:
  dungeons-city.md lists only Petrify + Poison — the bestiary
  applies standard Boss-type defaults as the authoritative source
  for combat data, per README.md charter.)
**Drops:** Drayce's Failsafe Core (accessory), Corrupted Tuning Fork
(Vaelith breadcrumb), 2,000 Gold

### 4.3 Ley Colossus (Ley Line Depths Mini-Boss)

- **HP:** 7,000 (per dungeons-world.md)
- **Type:** Elemental (not Boss — can be affected by more statuses)
- **Level:** 22

**Phase 1 (7,000–3,500 HP):**
- Crystal Fists: heavy melee
- Ley Pulse: AoE magic, 1-turn charge
- Absorbs all magic damage. Vulnerable to physical.

**Phase 2 (below 3,500 HP):**
- Shatters and reforms smaller/faster
- Gains Prism Beam: single-target high magic, 1-turn warning
- Loses Ley Pulse
- Physical vulnerability increases

**Not hostile** — a guardian testing visitors. Lore-friendly.

**Weakness:** — (physical only; magic absorbed)
**Resistance:** — (all magic absorbed, not resisted)
**Absorbs:** Flame, Frost, Storm, Earth, Ley, Spirit, Void (all)
**Immunities:** Petrify (Elemental default)
**Drops:** Ley Crystal Fragment (crafting), Colossus Shard (accessory)

## 5. New Mechanics

### 5.1 Spawn-on-Death (Airborne Family Trait)

When an Airborne family enemy (Construct type) reaches 0 HP:
1. The Construct is removed from battle
2. A linked Humanoid enemy spawns in its place at full HP
3. The spawned enemy acts on the next available turn
4. Gold/Exp for the encounter = sum of both enemies

**Documented in:** palette-families.md under the Airborne family
definition. Each Airborne tier entry specifies the linked spawn.

### 5.2 Castle Defense Gauntlet (Valdris Siege)

A scripted multi-wave encounter sequence (FF4 Baron Castle defense):
1. Waves are predetermined — no random encounters during the gauntlet
2. Party cannot flee during waves
3. Between waves, party HP/MP carry over (no free heal)
4. The breather between Wave 3 and the boss allows healing/saving
5. Dame Cordwyn is a guest NPC for the entire sequence
6. Gold/Exp awarded per wave (not per individual enemy)

**Documented in:** act-ii.md under the Valdris Siege section header.

### 5.3 Non-Lethal Encounter (Pallor-Touched Worker)

The Pallor-Touched Worker cannot be killed:
1. At 0 HP, the worker "wakes up" confused — combat ends
2. No Gold/Exp awarded (they are victims, not enemies)
3. Party members who dealt the killing blow gain no guilt (narrative)
4. These encounters are marked in the Location column with "(non-lethal)"

**Documented in:** act-ii.md with a note in the Ashmark section.

## 6. New Palette-Swap Families (9)

Added to palette-families.md alongside the existing 19 families.

### 6.1 Crawler Family

**Base:** Cave Crawler (Lv 17, Beast, Standard)
**Planned Tiers:** 4

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Cave Crawler | 17 | Beast | — | Pinch, Hard Shell (high DEF) | Standard |
| 2 | Sea Crawler | 18 | Beast | Weak→Storm | +Brine Spray (Blind), +Shell Clamp (Stun) | Standard |
| 3 | Blight Crawler | 32 | Beast | Weak→Flame | +Acid Spit (DEF down), +Burrow Strike | Dangerous |
| 4 | Pallor Crawler | 46 | Pallor | Weak→Spirit, Resist→Void | +Despair Pinch (Despair), +Grey Shell (reflect 1 physical) | Rare |

### 6.2 Automata Family

**Base:** Extraction Drone (Lv 16, Construct, Low)
**Planned Tiers:** 3

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Extraction Drone | 16 | Construct | — | Drill Strike, Scan (reveals weakness) | Low |
| 2 | Overclocked Automata | 20 | Construct | — | +Overdrive (2-hit), +Spark Burst (Storm AoE) | Standard |
| 3 | Haywire Colossus | 36 | Construct | Weak→Storm | +Self-Destruct (AoE on death), +Berserk Protocol (ATK up, random target) | Dangerous |

### 6.3 Soldier Family

**Base:** Compact Soldier (Lv 18, Humanoid, Low)
**Planned Tiers:** 4

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Compact Soldier | 18 | Humanoid | — | Sword Strike, Cover (protects adjacent ally) | Low |
| 2 | Compact Officer | 24 | Humanoid | — | +Rally (ATK up party), +Shield Bash (Stun) | Standard |
| 3 | Elite Guard | 34 | Humanoid | — | +Counter Stance, +Arcanite Blade (magic damage on physical hit) | Dangerous |
| 4 | Pallor Legionnaire | 48 | Pallor | Weak→Spirit, Resist→Void | +Despair Strike, +Grey March (AoE + Despair), +Deathless (auto-revive once) | Rare |

### 6.4 Airborne Family (Spawn-on-Death Trait)

**Base:** Compact Gyrocopter (Lv 20, Construct, Standard)
**Planned Tiers:** 3
**Family trait:** Spawns a linked Humanoid ground unit on death.

| Tier | Name | Lv | Type | Death Spawn | New Abilities | Threat |
|------|------|----|------|-------------|---------------|--------|
| 1 | Compact Gyrocopter | 20 | Construct | Downed Pilot (Lv 18, Humanoid) | Bomb Run (AoE), Strafe (back-row), high melee evasion | Standard |
| 2 | Assault Rotorcraft | 28 | Construct | Parachute Trooper (Lv 25, Humanoid) | +Napalm Drop (AoE + Burn), +Evasive Maneuver | Dangerous |
| 3 | Pallor Drone | 40 | Pallor | Pallor Pilot (Lv 38, Pallor) | +Despair Bomb (AoE Despair), +Grey Static (Silence) | Rare |

**Spawned units** (not separate families — documented as Airborne sub-entries):

| Name | Lv | Type | Abilities | Threat |
|------|----|------|-----------|--------|
| Downed Pilot | 18 | Humanoid | Sword Slash, Pistol Shot (ranged) | Low |
| Parachute Trooper | 25 | Humanoid | +Grenade (AoE), +Emergency Stim (self-heal) | Standard |
| Pallor Pilot | 38 | Pallor | +Despair Touch, +Frenzied Slash (2-hit) | Standard |

### 6.5 Roach Family

**Base:** Forge Roach (Lv 18, Beast, Low)
**Planned Tiers:** 2

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Forge Roach | 18 | Beast | — | Skitter, Swarm (groups of 4–6) | Low |
| 2 | Blight Roach | 30 | Beast | Weak→Flame | +Infest (Poison), +Scatter (flee and reappear next turn) | Standard |

### 6.6 Wraith Family

**Base:** Pipe Wraith (Lv 19, Spirit, Standard)
**Planned Tiers:** 4

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Pipe Wraith | 19 | Spirit | — | Ley Bolt (magic), Phase (50% phys reduction inherent), ignores 25% DEF | Standard |
| 2 | Tide Wraith | 19 | Spirit | Weak→Storm | +Frost Wave (AoE Frost), +Undertow (SPD down) | Standard |
| 3 | Storm Wraith | 32 | Spirit | Weak→Earth | +Chain Lightning (multi-target), +Tempest (AoE + Confusion chance) | Dangerous |
| 4 | Pallor Wraith | 44 | Pallor | Weak→Spirit, Resist→Void | +Despair Wail (AoE Despair), +Soul Drain (HP drain, bypasses DEF) | Rare |

### 6.7 Moth Family

**Base:** Prism Moth (Lv 18, Elemental, Low)
**Planned Tiers:** 3

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Prism Moth | 18 | Elemental | — | Flutter, Refraction (group MAG buff) | Low |
| 2 | Crystal Moth | 26 | Elemental | Resist→Ley | +Prismatic Dust (random element AoE), +Dazzle (Blind) | Standard |
| 3 | Void Moth | 38 | Elemental | Weak→Ley, Absorb→Void | +Void Dust (Silence AoE), +Absorb Light (heals from Ley) | Dangerous |

### 6.8 Hawk Family

**Base:** Mountain Hawk (Lv 17, Beast, Standard)
**Planned Tiers:** 3

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Mountain Hawk | 17 | Beast | — | Dive (back-row target), Talon Rake | Standard |
| 2 | Storm Hawk | 25 | Beast | Weak→Earth | +Gale Wing (AoE + SPD down), +Sky Strike (ignores row) | Dangerous |
| 3 | Roc | 38 | Beast | Weak→Storm | +Carry Off (removes target 1 turn), +Tempest Dive (heavy AoE) | Rare |

### 6.9 Treant Family

**Base:** Thornwood Treant (Lv 19, Elemental, Dangerous)
**Planned Tiers:** 3 (Pallor at Tier 3, early transition)

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Thornwood Treant | 19 | Elemental | — | Root Slam (heavy physical), Thorn Counter (damage on hit), Earth Absorb | Dangerous |
| 2 | Ancient Treant | 30 | Elemental | Resist→Earth, Resist→Frost | +Entangle (Stun + DoT), +Regrowth (self-heal 10% HP) | Dangerous |
| 3 | Pallor Treant | 36 | Pallor | Weak→Spirit, Resist→Void | +Despair Roots (AoE Despair + Stun), +Grey Canopy (party Blind) | Rare |

## 7. Existing Family Tier 2 Updates

11 existing families from Act I gain Tier 2 entries in Act II.

**REVISION NOTE:** Sub-project 1's palette-families.md contained
projected Tier 2 names and levels that were estimates. This spec
**overrides** those projections where they conflict with dungeon
source material (dungeons-world.md, dungeons-city.md) or with Act II's
level range requirements. Implementation must update palette-families.md
to match the values below. Key changes from projections:

- Wisp Tier 2: "Storm Wisp" (Lv 20) → **Ley Wisp** (Lv 18) — matches
  dungeons-world.md Ley Line Depths naming and level range
- Serpent: "Corrupted Spawn" is already Tier 2 in Act I (Fenmother).
  **Deep Serpent** (Lv 19) is a second Tier 2 variant for Act II
  (same family tier, different biome — like Bandit's two Tier 2s)
- Crystal Tier 2: "Resonant Crystal" (Lv 18) → **Crystal Sentry**
  (Lv 20) — matches dungeons-world.md naming
- Several overworld family levels adjusted downward to fit early Act II
  encounters (party arrives at Lv 13–15, not 18–20)

| Family | Tier 2 Name | Lv | Projected Lv | Location(s) | Change? |
|--------|------------|-----|-------------|-------------|---------|
| Vermin | Cave Vermin | 16 | 10 | Ley Line Depths | Level up (deeper caves) |
| Wisp | Ley Wisp | 18 | 20 (Storm Wisp) | Ley Line Depths | Name + level revised |
| Serpent | Deep Serpent | 19 | 10 (Corrupted Spawn) | Ley Line Depths | New Tier 2 variant (Corrupted Spawn remains Act I) |
| Crystal | Crystal Sentry | 20 | 18 (Resonant Crystal) | Ley Line Depths | Name + level revised |
| Mite | Tunnel Mite | 14 | 14 | Mountain caves (overworld) | Match |
| Bandit | Smuggler Thug / Highwayman | 17/15 | 16 | Bellhaven / Overworld roads | Split into two biome variants |
| Beetle | Iron Beetle | 16 | 18 | Mountain paths (overworld) | Level down (early Act II) |
| Wolf | Dire Wolf | 16 | 19 | Forest, mountain (overworld) | Level down (early Act II) |
| Sprite | Meadow Sprite | 16 | 19 | Grassland, forest (overworld) | Level down (early Act II) |
| Boar | Razorback | 17 | 20 | Grassland (overworld) | Level down (early Act II) |
| Leech | Sewer Leech | 15 | 18 | Coastal, swamp (overworld) | Level down (early Act II) |
| Crawler | Sea Crawler | 18 | — (new family) | Bellhaven coast | N/A |

**Bandit family note:** Two Tier 2 variants (Smuggler Thug + Highwayman)
at different biomes, same tier power. Follows the FF6 pattern where
family tiers can appear in multiple areas with different names.

## 8. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/act-ii.md` | Rewrite (from TBD placeholder) | Full Act II enemy stat tables (~33 entries) |
| `docs/story/bestiary/palette-families.md` | Modify | Add 9 new families, confirm Tier 2 for 11 existing |
| `docs/story/bestiary/CONTINUATION.md` | Modify | Update Sub-project 2a status |
| `docs/analysis/game-design-gaps.md` | Modify | Check off Act II items in Gap 1.3 |

## 9. Out of Scope

- Interlude dungeons (Sub-project 2b — separate PR)
- Act III and Optional enemies (Sub-project 3)
- Boss AI behavior scripts beyond what is described here (Sub-project 4)
- Drop/Steal item details beyond placeholder names (blocked by Gap 1.4)
- Ley Line Depths floors 4–5 (Act III content, goes in act-iii.md)

## 10. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| PR split | Act II separate from Interlude | Smaller PRs = fewer review rounds (PR #19 lesson) |
| Overworld density | Medium (~11 enemies) | Act II opens the world — more biome diversity needed |
| Pallor foreshadowing | 2 enemies only (Worker + Ashen Ram) | Full Pallor debut in Interlude. Act II = ominous hints. |
| Airborne spawn mechanic | Family-level trait in palette-families.md | Keeps stat tables clean, mechanic tied to family not individual |
| Siege gauntlet | Scripted waves + boss (FF4 castle defense) | Cinematic climax for Act II, teaches wave survival |
| Non-lethal encounter | Pallor-Touched Worker wakes at 0 HP | Narrative power — these are victims, not villains |
| Bandit family split | Two Tier 2 variants (Smuggler Thug + Highwayman) | Same power level, different biomes — FF6 pattern |
| Treant Pallor transition | Tier 3 (not Tier 4) | Nature corrupts early — Pallor attacks the land first |
