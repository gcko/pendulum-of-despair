# Act II Bestiary

Enemies encountered during Act II: Ley Line Depths (floors 1–3),
Ashmark Factory Depths, Bellhaven Smuggler Tunnels, Valdris Siege,
and the Overworld between cities. See [README.md](README.md) for
type rules, stat formulas, and reward calculations.

**Total:** 33 enemies (28 regular + 1 unique + 1 spawn + 1 mini-boss + 2 bosses)

---

## Ley Line Depths (Floors 1–3)

Recommended party level: 16–22. Optional dungeon accessed via
Millhaven pit. Natural caverns and crystal formations with
ley-infused creatures.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Extraction Drone | Construct | 16 | 672 | 0 | 33 | 24 | 28 | 20 | 20 | 14 | 26 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Ley Line Depths F1–F2 |
| Cave Vermin | Beast | 16 | 470 | 0 | 29 | 24 | 28 | 20 | 20 | 14 | 26 | Beast Hide (75%) | Vermin Fang (25%) | — | — | — | — | Ley Line Depths F1–F2 |
| Cave Crawler | Beast | 17 | 818 | 0 | 35 | 28 | 29 | 21 | 17 | 25 | 49 | Beast Hide (75%) | Crawler Shell (25%) | — | — | — | — | Ley Line Depths F1–F2 |
| Prism Moth | Elemental | 18 | 573 | 63 | 28 | 26 | 35 | 24 | 22 | 16 | 30 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Ley | Petrify | Ley Line Depths F1–F3 |
| Ley Wisp | Elemental | 18 | 819 | 63 | 28 | 26 | 35 | 24 | 22 | 27 | 52 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Ley Line Depths F2–F3 |
| Deep Serpent | Beast | 19 | 807 | 0 | 43 | 20 | 32 | 23 | 23 | 30 | 56 | Beast Hide (75%) | Serpent Fang (25%) | Frost | — | — | — | Ley Line Depths F2–F3 |
| Crystal Sentry | Elemental | 20 | 1,078 | 70 | 40 | 33 | 34 | 24 | 19 | 32 | 60 | Element Shard (75%) | Elemental Core (25%) | Storm | — | Earth | Petrify | Ley Line Depths F2–F3 |
| *Ley Colossus* | Elemental | 22 | 7,000 | 77 | 43 | 31 | 36 | 26 | 25 | 63 | 116 | Ley Crystal Fragment (75%) | Colossus Shard (100%) | — | — | Flame, Frost, Storm, Earth, Ley, Spirit, Void | Petrify | Ley Line Depths F3 (mini-boss) |

### Ley Colossus (Mini-Boss)

- **HP:** 7,000 (per dungeons-world.md)
- **Type:** Elemental (not Boss -- can be affected by more statuses)
- **Phase 1 (7,000–3,500 HP):**
  - Crystal Fists -- heavy single-target physical
  - Ley Pulse -- AoE magic damage, 1-turn charge (chest glows as tell)
  - Absorbs all magic damage. Vulnerable to physical.
- **Phase 2 (below 3,500 HP):**
  - Shatters and reforms smaller/faster
  - Gains Prism Beam -- single-target high magic damage, 1-turn warning
    (targeting beam visible before firing)
  - Loses Ley Pulse
  - Physical vulnerability increases
- **Not hostile** -- a guardian testing visitors. Lore-friendly.
- **Absorbs:** Flame, Frost, Storm, Earth, Ley, Spirit, Void (all 7 elements)
- **Immunities:** Petrify (Elemental default only)
- **Drops:** Ley Crystal Fragment (crafting), Colossus Shard (accessory)

---

## Ashmark Factory Depths

Recommended party level: 18–24. City dungeon beneath Ashmark's
industrial district. Leaking ley pipes, malfunctioning constructs,
and the first signs of the Pallor's reach.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Forge Roach | Beast | 18 | 573 | 0 | 32 | 26 | 31 | 22 | 22 | 16 | 30 | Beast Hide (75%) | Roach Wing (25%) | — | — | — | — | Ashmark Factory Depths |
| Pipe Wraith | Spirit | 19 | 897 | 66 | 30 | 27 | 36 | 25 | 23 | 30 | 56 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Ashmark Factory Depths |
| Overclocked Automata | Construct | 20 | 882 | 0 | 46 | 21 | 34 | 24 | 24 | 32 | 60 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Ashmark Factory Depths |
| Pallor-Touched Worker | Humanoid | 20 | 980 | 0 | 40 | 29 | 34 | 24 | 24 | 0 | 0 | Potion (75%) | — | — | — | — | — | Ashmark Factory Depths (non-lethal) |
| *The Forge Warden* | Boss | 24 | 8,500 | 84 | 69 | 42 | 70 | 42 | 32 | 2,000 | 3,500 | Corrupted Tuning Fork (100%) | Drayce's Failsafe Core (100%) | Storm, Spirit | Flame, Earth | — | Death, Petrify, Stop, Sleep, Confusion, Poison | Ashmark Factory Depths (boss) |

> **Pallor foreshadowing:** The Pallor-Touched Worker is the first
> encounter where the party fights a human victim of the Pallor. At
> 0 HP the worker "wakes up" confused -- they cannot be killed. No
> Gold/Exp is awarded. This encounter signals that something is
> deeply wrong before the Interlude reveals the full scope.

### The Forge Warden (Boss)

- **HP:** 8,500 (per dungeons-city.md)
- **Type:** Boss
- **Phase 1 -- Programmed Defense (8,500–4,250 HP):**
  - Ley Bolt -- 350–400 single-target magic, fast cast
  - Shield Protocol -- absorbs 1,000 damage, 4-turn cooldown
  - Containment Pulse -- 250–300 AoE + pushback, marks contaminated zones
  - Pipeline Drain -- heals 500 HP (Lira's Forgewright reroutes, disables)
- **Phase 2 -- Corrupted Logic (below 4,250 HP):**
  - All Phase 1 attacks with semi-random targeting
  - Overload Beam -- 500–600 line AoE, 2-turn charge (interrupt with 800+
    physical damage)
  - System Failure -- random 1-turn freeze (free damage window)
  - Emergency Protocol -- below 20%, 3-turn self-destruct (Lira Override
    aborts -- unique interaction)
- **Weakness:** Storm (150%), Spirit (125%)
- **Resistance:** Flame (75%), Earth (75%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion, Poison
- **Drops:** Drayce's Failsafe Core (accessory), Corrupted Tuning Fork
  (Vaelith breadcrumb), 2,000 Gold

---

## Bellhaven Smuggler Tunnels

Recommended party level: 16–20. Coastal tunnels beneath Bellhaven's
docks. Smugglers, sea creatures, and water-bound spirits.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Smuggler Thug | Humanoid | 17 | 744 | 0 | 35 | 25 | 29 | 21 | 21 | 15 | 28 | Potion (75%) | Smoke Bomb (25%) | — | — | — | — | Bellhaven Smuggler Tunnels |
| Sea Crawler | Beast | 18 | 900 | 0 | 36 | 29 | 31 | 22 | 18 | 27 | 52 | Beast Hide (75%) | Crawler Shell (25%) | Storm | — | — | — | Bellhaven Smuggler Tunnels |
| Tide Wraith | Spirit | 19 | 897 | 66 | 30 | 27 | 36 | 25 | 23 | 30 | 56 | Ether Wisp (75%) | Spirit Essence (25%) | Storm | — | — | Poison, Petrify | Bellhaven Smuggler Tunnels |

---

## Valdris Siege -- Castle Defense Gauntlet

Recommended party level: 18–22. Act II climax. The Carradan Compact
assaults Valdris. Scripted wave encounters (FF4 Baron Castle defense
style) culminating in the Ashen Ram boss.

**Guest NPC:** Dame Cordwyn (5,000 HP, ATK 85, DEF 70) fights alongside
the party during all waves and the boss. Cannot be controlled. Uses
Shield Wall (party DEF up) and Rally Cry (removes Despair from all party members, 3-turn cooldown).

### Pre-Boss Encounters

Random encounters while traversing the battlefield before the gauntlet
begins.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Compact Soldier | Humanoid | 18 | 819 | 0 | 36 | 26 | 31 | 22 | 22 | 16 | 30 | Potion (75%) | Compact Insignia (25%) | — | — | — | — | Valdris Siege (battlefield) |
| Compact Engineer | Humanoid | 19 | 897 | 66 | 38 | 27 | 32 | 23 | 23 | 30 | 56 | Potion (75%) | Repair Kit (25%) | — | — | — | — | Valdris Siege (battlefield) |

### Gauntlet Enemies

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Siege Ballista Crew | Humanoid | 20 | 980 | 0 | 40 | 29 | 34 | 24 | 24 | 32 | 60 | Potion (75%) | Ballista Bolt (25%) | — | — | — | — | Valdris Siege (gauntlet W2) |
| Compact Gyrocopter | Construct | 20 | 980 | 0 | 40 | 29 | 34 | 24 | 24 | 32 | 60 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Valdris Siege (gauntlet W3) |
| Downed Pilot | Humanoid | 18 | 819 | 0 | 36 | 26 | 31 | 22 | 22 | 16 | 30 | Potion (75%) | Pilot's Goggles (25%) | — | — | — | — | Valdris Siege (spawned by Gyrocopter) |
| *The Ashen Ram* | Boss | 22 | 25,000 | 77 | 64 | 40 | 64 | 39 | 30 | 5,000 | 8,000 | Pallor-Laced Iron (100%) | Compact Battle Standard (100%) | Storm | Frost | Earth | Death, Petrify, Stop, Sleep, Confusion | Valdris Siege (boss) |

### Castle Defense Gauntlet

Scripted wave sequence. Party cannot flee. HP/MP carry over between
waves. Dame Cordwyn fights alongside throughout.

- **Wave 1:** 4 Compact Soldiers + 2 Compact Engineers
  (Establish the army. Engineers heal soldiers -- focus them first.)
- **Wave 2:** 3 Compact Soldiers + 2 Siege Ballista Crews
  (Ranged pressure. Back-row targeting forces defensive play.)
- **Wave 3:** 2 Compact Gyrocopters + 2 Compact Soldiers
  (Air support debut. Spawn-on-death mechanic introduced.)
- **Breather:** Dame Cordwyn rallies. Party can heal and save.
- **Boss:** The Ashen Ram breaches the wall.

### Spawn-on-Death (Airborne Family Trait)

When a Compact Gyrocopter reaches 0 HP:
1. The Construct is removed from battle
2. A Downed Pilot spawns in its place at full HP
3. The pilot acts on the next available turn
4. Gold/Exp = sum of both enemies

### The Ashen Ram (Boss)

- **HP:** 25,000 (per dungeons-world.md)
- **Type:** Boss
- **Phase 1 -- Ranged Engagement (25,000–15,000 HP):**
  - Battering Advance -- cumulative party damage, 1-turn charge. After 5
    turns, breaches the wall and Phase 2 begins. Dealing 1,500+ cumulative
    party damage in a single turn delays the advance by 1 turn.
  - Despair Pulse (passive) -- all party members lose 5% max MP per turn from Pallor proximity
  - Compact Escalade -- summons 2 Compact Soldiers (once per phase)
  - Lord Haren's Orders -- if Cordwyn HP > 50%, Ram targets her
    preferentially (player must keep Cordwyn alive)
- **Phase 2 -- The Breach (15,000–7,500 HP):**
  - Drill Arm -- heavy single-target physical
  - Pallor Shrapnel -- AoE + Despair (30% chance)
  - Engine Surge -- self ATK buff, 2-turn duration
- **Phase 3 -- The Pallor Core (below 7,500 HP):**
  - Despair Pulse (active) -- guaranteed Despair attempt each turn
  - Core Overload -- 3-turn charge, massive AoE (must burst before it fires)
  - Cordwyn's HP drops to critical -- cutscene, party must finish fast
- **Weakness:** Storm (150%), Flame (125% to core only in Phase 3)
- **Resistance:** Earth (absorbs), Frost (75%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Drops:** Pallor-Laced Iron (crafting), Compact Battle Standard (key item)

---

## Overworld Act II

Encounters across the expanded world map between cities. Overworld
enemies are generally less dangerous than dungeon enemies at the
same level. Biome-specific encounter tables.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Tunnel Mite | Beast | 14 | 378 | 0 | 27 | 21 | 25 | 18 | 19 | 11 | 23 | Beast Hide (75%) | Mite Husk (25%) | — | — | — | — | Mountain caves |
| Coastal Crab | Beast | 14 | 594 | 0 | 30 | 24 | 25 | 18 | 15 | 11 | 23 | Beast Hide (75%) | Crab Claw (25%) | — | — | — | — | Bellhaven coast |
| Road Viper | Beast | 15 | 544 | 0 | 36 | 17 | 27 | 19 | 20 | 12 | 24 | Beast Hide (75%) | Viper Fang (25%) | — | — | — | — | Roads, grassland |
| Sewer Leech | Beast | 15 | 605 | 0 | 32 | 23 | 27 | 19 | 20 | 12 | 24 | Beast Hide (75%) | Leech Ichor (25%) | — | — | — | — | Coastal, swamp |
| Highwayman | Humanoid | 15 | 605 | 0 | 32 | 23 | 27 | 19 | 20 | 22 | 42 | Potion (75%) | Stolen Purse (25%) | — | — | — | — | Roads between cities |
| Iron Beetle | Beast | 16 | 739 | 0 | 33 | 27 | 28 | 20 | 16 | 14 | 26 | Beast Hide (75%) | Beetle Carapace (25%) | — | — | — | — | Mountain paths |
| Dire Wolf | Beast | 16 | 672 | 0 | 33 | 24 | 28 | 20 | 20 | 24 | 45 | Beast Hide (75%) | Wolf Pelt (25%) | — | — | — | — | Forest, mountain |
| Meadow Sprite | Spirit | 16 | 672 | 56 | 26 | 24 | 32 | 22 | 20 | 24 | 45 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Grassland, forest |
| Mountain Hawk | Beast | 17 | 669 | 0 | 40 | 18 | 29 | 21 | 21 | 25 | 49 | Beast Hide (75%) | Hawk Feather (25%) | — | — | — | — | Mountain, highland |
| Razorback | Beast | 17 | 669 | 0 | 40 | 18 | 29 | 21 | 21 | 25 | 49 | Beast Hide (75%) | Boar Tusk (25%) | — | — | — | — | Grassland |
| Thornwood Treant | Elemental | 19 | 986 | 66 | 38 | 31 | 32 | 23 | 18 | 50 | 94 | Element Shard (75%) | Elemental Core (25%) | Flame | — | Earth | Petrify | Deep forest (rare, ~5% encounter rate) |

---

## Act II Summary

- **Total:** 33 enemies (28 regular + 1 unique + 1 spawn + 1 mini-boss + 2 bosses)
- **Type coverage:** Beast (13), Construct (3), Humanoid (7), Spirit (3),
  Elemental (5), Boss (2)
- **Threat spread:** Low (11), Standard (16), Dangerous (1), Boss (2),
  unique (1), spawn (1), mini-boss (1)
- **Level range:** 14–24
- **New families:** Automata, Crawler, Soldier, Airborne, Roach, Wraith,
  Moth, Hawk, Treant (9)
- **Existing families progressed to Tier 2:** Vermin, Wisp, Serpent,
  Crystal, Mite, Bandit, Beetle, Wolf, Sprite, Boar, Leech (11)
- **New mechanics:** Spawn-on-death (Airborne), Castle defense gauntlet,
  Non-lethal encounter (Pallor-Touched Worker)
- **Pallor foreshadowing:** Pallor-Touched Worker (non-lethal victim),
  The Ashen Ram (corrupted siege construct boss)
