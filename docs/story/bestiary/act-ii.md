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

### Boss Notes

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Ley Colossus** (Mini-Boss) — Lv 22, 7,000 HP, Elemental. 2 phases.

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
| *The Forge Warden* | Boss | 24 | 8,500 | 84 | 69 | 42 | 70 | 42 | 32 | 2,000 | 3,500 | Corrupted Tuning Fork (100%) | Drayce's Failsafe Core (100%) | Storm (150%), Spirit (125%) | Flame (50%), Earth (75%) | — | Death, Petrify, Stop, Sleep, Confusion, Poison | Ashmark Factory Depths (boss) |

> **Pallor foreshadowing:** The Pallor-Touched Worker is the first
> encounter where the party fights a human victim of the Pallor. At
> 0 HP the worker "wakes up" confused -- they cannot be killed. No
> Gold/Exp is awarded. This encounter signals that something is
> deeply wrong before the Interlude reveals the full scope.

### Boss Notes

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **The Forge Warden** — Lv 24, 8,500 HP, Boss. 2 phases.

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
Shield Wall (50% damage reduction to one ally for 1 turn) and Rally Cry (removes Despair from all party members, 3-turn cooldown).

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
| *The Ashen Ram* | Boss | 22 | 25,000 | 77 | 64 | 40 | 64 | 39 | 30 | 5,000 | 8,000 | Pallor-Laced Iron (100%) | Compact Battle Standard (100%) | Storm, Flame (Phase 3 core only) | Frost | Earth | Death, Petrify, Stop, Sleep, Confusion | Valdris Siege (boss) |

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

### Boss Notes

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **The Ashen Ram** — Lv 22, 25,000 HP, Boss. 3 phases.

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
