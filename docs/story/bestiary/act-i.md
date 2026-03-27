# Act I Bestiary

Enemies encountered during Act I: Ember Vein, Fenmother's Hollow,
and the Overworld between Valdris and the Hollow. See
[README.md](README.md) for type rules, stat formulas, and reward
calculations.

**Total:** 25 enemies (20 regular + 1 unique + 2 mini-bosses + 2 bosses)

---

## Ember Vein (Floors 1–4)

Recommended party level: 1–8. First dungeon -- every enemy teaches a
core mechanic.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Ley Vermin | Beast | 1 | 23 | 0 | 8 | 6 | 7 | 5 | 8 | 1 | 4 | Beast Hide (75%) | Sharp Fang (25%) | — | — | — | — | Ember Vein F1–F2 |
| Tomb Mite | Beast | 2 | 35 | 0 | 9 | 7 | 8 | 6 | 9 | 2 | 4 | Beast Hide (75%) | Sharp Fang (25%) | — | — | — | — | Ember Vein F1–F2 |
| Restless Dead | Undead | 3 | 72 | 10 | 12 | 8 | 10 | 7 | 10 | 2 | 4 | Bone Fragment (75%) | Spirit Dust (25%) | Spirit | — | — | Poison, Death | Ember Vein F1–F3 |
| Unstable Crystal | Elemental | 3 | 64 | 10 | 13 | 6 | 10 | 7 | 10 | 5 | 10 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Ember Vein F1–F3 |
| Mine Shade | Spirit | 4 | 96 | 14 | 11 | 9 | 12 | 8 | 11 | 5 | 11 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Ember Vein F2–F3 |
| Bone Warden | Undead | 4 | 105 | 14 | 14 | 10 | 11 | 8 | 9 | 5 | 11 | Bone Fragment (75%) | Spirit Dust (25%) | Spirit | — | — | Poison, Death | Ember Vein F2–F3 |
| Ember Wisp | Elemental | 5 | 125 | 17 | 13 | 11 | 14 | 9 | 12 | 5 | 12 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Ember Vein F3 |
| The Flickering | Spirit | 6 | 156 | 21 | 17 | 12 | 14 | 10 | 12 | 19 | 38 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Ember Vein F3 (unique) |
| *Ember Drake* | Beast | 8 | 1,500 | 0 | 23 | 11 | 17 | 12 | 14 | 50 | 44 | Drake Scale (75%) | Drake Fang (100%) | Frost | — | — | — | Ember Vein F2 (mini-boss) |
| *Vein Guardian* | Boss | 12 | 6,000 | 42 | 40 | 24 | 39 | 24 | 20 | 50 | 800 | Vein Shard (100%) | Vein Guardian's Core (100%) | Storm | Flame | — | Death, Petrify, Stop, Sleep, Confusion | Ember Vein F4 (boss) |

### Boss Notes — Ember Vein

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Ember Drake** (Mini-Boss) — Lv 8, 1,500 HP, Beast. 1 phase.
- **Vein Guardian** — Lv 12, 6,000 HP, Boss. 2 phases.

---

## Fenmother's Hollow (Floors 1–3 + Cleansing)

> **Act boundary note:** dungeons-world.md classifies Fenmother's Hollow
> as Act II (recommended level 12–15). It is included in the Act I
> bestiary file because (1) the party reaches it at the end of Act I
> progression, (2) its enemies share the Act I level range (6–12), and
> (3) the boss fight is the Act I climax. The act-i.md file covers the
> "first playthrough arc" -- everything before the Valdris diplomatic
> missions. The Corrupted Fenmother boss (Lv 12) sits at the Act I cap.

Recommended party level: 6–12. Second dungeon -- water-themed, teaches
status effects, elemental resistance, and the cleansing mechanic.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Marsh Serpent | Beast | 6 | 140 | 0 | 19 | 10 | 14 | 10 | 12 | 6 | 13 | Beast Hide (75%) | Serpent Fang (25%) | — | — | — | — | Fenmother's Hollow F1–F3 |
| Bog Leech | Beast | 7 | 192 | 0 | 19 | 13 | 15 | 11 | 13 | 7 | 14 | Beast Hide (75%) | Leech Ichor (25%) | — | — | — | — | Fenmother's Hollow F1–F2 |
| Drowned Bones | Undead | 7 | 211 | 24 | 19 | 14 | 15 | 11 | 11 | 7 | 14 | Bone Fragment (75%) | Spirit Dust (25%) | Spirit | — | — | Poison, Death | Fenmother's Hollow F1–F2 |
| Swamp Lurker | Beast | 8 | 254 | 0 | 20 | 16 | 17 | 12 | 12 | 13 | 26 | Beast Hide (75%) | Lurker Shell (25%) | — | — | — | — | Fenmother's Hollow F1–F3 |
| Ley Jellyfish | Elemental | 8 | 231 | 28 | 17 | 14 | 19 | 13 | 14 | 13 | 26 | Element Shard (75%) | Elemental Core (25%) | Storm | — | Frost | Petrify | Fenmother's Hollow F2–F3 |
| Polluted Elemental | Elemental | 9 | 273 | 31 | 18 | 15 | 20 | 14 | 15 | 13 | 28 | Element Shard (75%) | Elemental Core (25%) | Flame | — | Frost | Petrify | Fenmother's Hollow F2–F3 |
| Corrupted Spawn | Beast | 10 | 288 | 0 | 27 | 14 | 20 | 14 | 16 | 15 | 30 | Beast Hide (75%) | Dark Scale (25%) | — | — | — | — | Fenmother's Hollow F3 (Wave 4) |
| *Drowned Sentinel* | Construct | 10 | 4,000 | 0 | 24 | 19 | 20 | 14 | 14 | 250 | 50 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Fenmother's Hollow F2 (mini-boss) |
| *Corrupted Fenmother* | Boss | 12 | 18,000 | 42 | 40 | 24 | 39 | 24 | 20 | 150 | 2,500 | Fenmother's Tear (100%) | Fenmother's Blessing (100%) | Flame | Frost | — | Death, Petrify, Stop, Sleep, Confusion | Fenmother's Hollow F3 (boss) |

### Boss Notes — Fenmother's Hollow

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Drowned Sentinel** (Mini-Boss) — Lv 10, 4,000 HP, Construct. 1 phase.
- **Corrupted Fenmother** — Lv 12, 18,000 HP, Boss. 3 phases.

---

## Overworld Act I

Encounters between Valdris and Fenmother's Hollow. Overworld enemies are
generally less dangerous than dungeon enemies at the same level.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Plains Hare | Beast | 1 | 23 | 0 | 8 | 6 | 7 | 5 | 8 | 1 | 4 | Beast Hide (75%) | Hare Pelt (25%) | — | — | — | — | Valdris Plains |
| Thornback Beetle | Beast | 3 | 72 | 0 | 12 | 8 | 10 | 7 | 10 | 5 | 10 | Beast Hide (75%) | Beetle Carapace (25%) | — | — | — | — | Valdris Forest |
| Road Bandit | Humanoid | 4 | 96 | 0 | 14 | 9 | 11 | 8 | 11 | 5 | 11 | Potion (75%) | Leather Pouch (25%) | — | — | — | — | Valdris Road |
| Forest Sprite | Spirit | 4 | 96 | 14 | 11 | 9 | 12 | 8 | 11 | 5 | 11 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Valdris Forest |
| Wild Boar | Beast | 5 | 112 | 0 | 18 | 9 | 13 | 9 | 12 | 10 | 21 | Beast Hide (75%) | Boar Tusk (25%) | — | — | — | — | Valdris Plains, Forest Edge |
| Wayward Wolf | Beast | 6 | 156 | 0 | 17 | 12 | 14 | 10 | 12 | 11 | 22 | Beast Hide (75%) | Wolf Pelt (25%) | — | — | — | — | Valdris Forest, Duskfen Road |

---

## Act I Summary

- **Total:** 25 enemies (20 regular + 1 unique + 2 mini-bosses + 2 bosses)
- **Type coverage:** Beast (11), Undead (3), Construct (1), Spirit (3),
  Elemental (4), Humanoid (1), Boss (2)
- **Threat spread:** Trivial (4), Low (10), Standard (6), Dangerous (3),
  Boss (2)
- **Level range:** 1–12
- **Families started:** 19 (see [palette-families.md](palette-families.md))
  - Vermin, Mite, Dead, Crystal, Shade, Warden, Wisp, Drake, Serpent,
    Leech, Lurker, Jellyfish, Elemental, Hare, Beetle, Bandit, Sprite,
    Boar, Wolf
- **Unique:** The Flickering (1)
- **Mechanics introduced:** Basic combat, swarm encounters, undead rules
  (heal-to-damage), elemental weaknesses, physical resistance (Spirit type),
  status effects (poison, paralysis, despair), AoE-on-death, phase transitions,
  cleansing ritual, dive/surface patterns
