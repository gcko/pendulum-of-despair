# Interlude Bestiary

Enemies encountered during the Interlude: Rail Tunnels, Corrund
Undercity, Valdris Crown Catacombs, Caldera Undercity, Axis Tower,
and Ironmark Citadel Dungeons. See [README.md](README.md) for type
rules, stat formulas, and reward calculations.

**Total:** 52 enemies across 6 dungeons

---

## Pallor Infection Mechanic

The Interlude introduces mid-combat Pallor infection. Infection
sources in encounters can convert normal enemies to Pallor-type
during battle.

### Infection Sources (4 types)

| Source | Convert Speed | Range | Priority | Counter |
|--------|-------------|-------|----------|---------|
| Pallor Nest | Spawns 1–2 Grey Mites/turn | All (indirect) | Low | Destroy the Nest |
| Pallor Seep | 1 enemy every 4 turns | Adjacent only | Medium | Kill it or adjacents first |
| Pallor Wisp | 1 enemy every 3 turns | Any in encounter | High | Kill ASAP — fastest |
| Pallor Soldier | 20% chance/turn per adjacent | Adjacent only | Low | Kill or isolate |

### Conversion Process

1. Source selects target: nearest non-Pallor, non-Construct, non-Boss enemy
   (Constructs are immune — machines cannot feel despair)
2. **Grey mist visual** on target for 1 turn (warning to player)
3. Next turn: target transforms:
   - **Family enemy with Pallor tier** — becomes that variant
     (e.g., Compact Officer — Pallor Soldier with full Tier 4
     abilities from palette-families.md)
   - **No Pallor variant exists** — becomes "Pallor-Touched [Name]"
     with generic boost: +30% current HP as heal, +Despair Touch
     ability, type — Pallor, Weak — Spirit, Immune — Despair
4. Converted enemy acts on its next turn

> **Note:** Pre-existing "Pallor-Touched" enemies (like the Pallor-Touched
> Soldier in Ironmark) are NOT the result of mid-combat conversion. They
> were corrupted before the encounter and retain their original type. Only
> mid-combat conversions change type to Pallor.

### Immunity Rules

| Type | Can Be Infected? | Rationale |
|------|-----------------|-----------|
| Beast | Yes | Animals succumb to despair |
| Undead | Yes | Pallor reanimates differently |
| Humanoid | Yes | Most susceptible |
| Spirit | Yes | Ley energy corrupted |
| Elemental | Yes (Void-shifted) | Twisted elemental nature |
| Construct | **NO** | Machines cannot feel despair |
| Pallor | N/A | Already Pallor |
| Boss | **NO** | Own corruption arc |

> **Future design note (Act III/IV):** Construct immunity to infection
> is absolute. However, post-Pallor Constructs will appear as a
> DESIGNED (not infected) threat — corrupted engineers building
> machines that channel Pallor energy. These are weapons OF despair,
> not victims of it. The machine doesn't despair; its creator did.
> The Arcanite Hound family's Grey Hound (Tier 3) foreshadows this.

### Infection Density by Dungeon

| Dungeon | Pallor Source % | Curve Position |
|---------|----------------|----------------|
| Rail Tunnels | 30% | Early — "something is down here" |
| Corrund Undercity | 30% | Early — "sewers are contaminated" |
| Valdris Catacombs | 40% | Mid — "even the dead are changing" |
| Caldera Undercity | 45% | Mid — "the forges are lost" |
| Axis Tower | 60% | Late — "the army has fallen" |
| Ironmark Citadel | 75% | Late — "fully consumed" |

---

> **Level range note:** Some early Interlude enemies (Rail Sentry Lv 18,
> Grey Mite Lv 18, Sewer Rat Lv 18) fall below the Interlude recommended
> party level of 20. These enemies appear in the earliest Interlude
> dungeons when the party arrives from Act II at approximately Lv 18–20.
> The transition is gradual, not a sharp cutoff.

---

## Rail Tunnels

Recommended party level: 18–22. Corrupted maintenance tunnels
beneath the Compact rail network. The first dungeon where the
Pallor Infection mechanic is introduced. 30% Pallor source encounters.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Rail Sentry | Construct | 18 | 819 | 0 | 36 | 26 | 31 | 22 | 22 | 16 | 30 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Rail Tunnels (Hub, East) |
| Forge Phantom | Spirit | 20 | 980 | 70 | 30 | 29 | 39 | 26 | 24 | 32 | 60 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Rail Tunnels (all sections) |
| Pallor Nest | Pallor | 20 | 980 | 70 | 40 | 29 | 34 | 24 | 24 | 32 | 60 | Pallor Sample (75%) | Nest Fragment (25%) | Spirit | — | — | Despair, Death | Rail Tunnels (all sections) |
| Grey Mite | Pallor | 18 | 556 | 63 | 32 | 26 | 31 | 22 | 22 | 6 | 13 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Rail Tunnels (spawned by Nest) |
| Steam Elemental | Elemental | 20 | 980 | 70 | 30 | 29 | 39 | 26 | 24 | 32 | 60 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Rail Tunnels (Hub, West) |
| Tunnel Vermin | Beast | 22 | 1,155 | 0 | 43 | 31 | 36 | 26 | 25 | 37 | 69 | Beast Hide (75%) | Vermin Fang (25%) | — | — | — | — | Rail Tunnels (all sections) |
| Pipe Wraith | Spirit | 20 | 980 | 70 | 30 | 29 | 39 | 26 | 24 | 32 | 60 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Rail Tunnels (Maintenance Shaft) |
| Grey Mite Swarm | Pallor | 20 | 666 | 70 | 36 | 29 | 34 | 24 | 24 | 32 | 60 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Rail Tunnels (unique dense swarm) |
| *Corrupted Boring Engine* | Construct | 22 | 6,000 | 0 | 43 | 35 | 36 | 26 | 19 | 1,250 | 116 | Arcanite Core (75%) | Drill Fragment (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Rail Tunnels (West Tunnel, mini-boss) |
| *The Ironbound* | Boss | 24 | 22,000 | 84 | 69 | 42 | 70 | 42 | 32 | 2,500 | 8,000 | Reinforced Drill Bit (100%) | Operator's Badge (100%) | Storm (150%), Void (125%) | Earth (50%), Flame (75%) | — | Death, Petrify, Stop, Sleep, Confusion | Rail Tunnels (deepest section) |

### Boss Notes — Rail Tunnels

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Corrupted Boring Engine** (Mini-Boss) — Lv 22, 6,000 HP, Construct. 1 phase.
- **The Ironbound** — Lv 24, 22,000 HP, Boss. 2 phases.

### Scripted Set-Piece: "The Wave Hits"

Occurs approximately at the 3rd encounter in the Rail Tunnels.
Non-preventable story moment.

- **Encounter:** 3 Forge Phantoms + 1 Rail Sentry
- **Turn 2:** Grey mist rolls in (cutscene)
- All 3 Forge Phantoms transform into Pallor Shades simultaneously
- Rail Sentry unaffected (Construct immune)
- **Teaches:** Construct immunity to Pallor infection + Pallor threat level

---

## Corrund Undercity

Recommended party level: 18–22. Brick-lined sewers and maintenance
tunnels beneath Corrund. Connects the Undercroft to the Axis Tower
underground level. 30% Pallor source encounters.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Forge-Smoke Creature | Elemental | 19 | 897 | 66 | 29 | 27 | 36 | 25 | 23 | 30 | 56 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Corrund Undercity (all sections) |
| Service Automata | Construct | 20 | 980 | 0 | 40 | 29 | 34 | 24 | 24 | 32 | 60 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Corrund Undercity (Sewer Junction) |
| Sewer Rat | Beast | 18 | 556 | 0 | 32 | 26 | 31 | 22 | 22 | 6 | 13 | Beast Hide (75%) | Rat Tail (25%) | — | — | — | — | Corrund Undercity (all sections) |
| Pallor Seep | Pallor | 20 | 1,078 | 70 | 40 | 33 | 34 | 24 | 18 | 32 | 60 | Pallor Sample (75%) | Grey Residue (25%) | Spirit | — | — | Despair, Death | Corrund Undercity (infection source, slow) |
| Sewer Leech | Beast | 20 | 980 | 0 | 40 | 29 | 34 | 24 | 24 | 18 | 35 | Beast Hide (75%) | Leech Ichor (25%) | — | — | — | — | Corrund Undercity (canals) |
| Pallor Wisp | Pallor | 20 | 980 | 70 | 40 | 29 | 34 | 24 | 24 | 32 | 60 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Corrund Undercity (infection source, fast) |

---

## Valdris Crown Catacombs

Recommended party level: 20–25. Ancient burial chambers beneath
Valdris. First visited during the escape (Restless Dead only), then
revisited with full encounters. 40% Pallor source encounters.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Restless Dead | Undead | 20 | 980 | 0 | 40 | 29 | 34 | 24 | 24 | 8 | 15 | — | Bone Dust (25%) | Spirit | — | — | Poison, Death | Valdris Catacombs (escape only, 2 fixed encounters) |
| Crypt Shade | Spirit | 22 | 1,155 | 77 | 33 | 31 | 41 | 28 | 25 | 37 | 69 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Valdris Catacombs (return visit) |
| Tomb Warden | Undead | 22 | 1,270 | 0 | 43 | 35 | 36 | 26 | 19 | 37 | 69 | Potion (75%) | Warden Shield (25%) | Spirit | — | — | Poison, Death | Valdris Catacombs (return visit) |
| Tomb Mite | Beast | 20 | 666 | 0 | 36 | 29 | 34 | 24 | 24 | 18 | 35 | Beast Hide (75%) | Mite Husk (25%) | — | — | — | — | Valdris Catacombs (return visit) |
| Drowned Sentinel | Construct | 22 | 1,155 | 0 | 43 | 31 | 36 | 26 | 25 | 37 | 69 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Valdris Catacombs (flooded chamber, reappearance) |
| Tomb Guardian | Construct | 23 | 1,372 | 0 | 44 | 36 | 38 | 27 | 20 | 40 | 74 | Scrap Metal (75%) | Stone Fragment (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Valdris Catacombs (return visit) |
| Royal Wraith | Spirit | 24 | 1,344 | 84 | 35 | 33 | 44 | 30 | 27 | 73 | 133 | Ether Wisp (75%) | Royal Signet (25%) | Ley | — | — | Poison, Petrify | Valdris Catacombs (return visit, rare) |
| Pallor Wisp | Pallor | 22 | 1,155 | 77 | 43 | 31 | 36 | 26 | 25 | 37 | 69 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Valdris Catacombs (infection source, 40%) |
| Wailing Dead | Undead | 24 | 1,344 | 0 | 46 | 33 | 39 | 28 | 27 | 43 | 79 | — | Bone Dust (25%) | Spirit | — | — | Poison, Death | Valdris Catacombs (return visit) |
| *The Undying Warden* | Boss | 25 | 8,000 | 87 | 72 | 45 | 73 | 43 | 33 | 500 | 3,500 | Catacomb Map (100%) | Warden's Binding (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Valdris Catacombs (Catacomb Heart, optional) |

### Boss Notes — Valdris Crown Catacombs

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **The Undying Warden** (Optional) — Lv 25, 8,000 HP, Boss. 2 phases.

---

## Caldera Undercity

Recommended party level: 20–25. Volcanic tunnels beneath Caldera
where old forge-channels meet natural vents. The Pallor Nest Mother
has burrowed into the deepest junction. 45% Pallor source encounters.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Heat Sprite | Elemental | 22 | 1,155 | 77 | 33 | 31 | 41 | 28 | 25 | 37 | 69 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Caldera Undercity (upper tunnels) |
| Corrupted Forge Construct | Construct | 23 | 1,248 | 0 | 44 | 32 | 38 | 27 | 26 | 40 | 74 | Scrap Metal (75%) | Molten Gear (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Caldera Undercity (forge channels) |
| Pallor Seep | Pallor | 22 | 1,270 | 77 | 43 | 35 | 36 | 26 | 19 | 37 | 69 | Pallor Sample (75%) | Grey Residue (25%) | Spirit | — | — | Despair, Death | Caldera Undercity (infection source, 45%) |
| Grey Crawler | Beast | 24 | 1,344 | 0 | 46 | 33 | 39 | 28 | 27 | 43 | 79 | Beast Hide (75%) | Crawler Shell (25%) | — | — | — | — | Caldera Undercity (deeper tunnels) |
| Pallor Mite | Pallor | 22 | 785 | 77 | 38 | 31 | 36 | 26 | 25 | 22 | 40 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Caldera Undercity (boss spawn only — NOT Mite family) |
| Grey Mite | Pallor | 22 | 785 | 77 | 38 | 31 | 36 | 26 | 25 | 9 | 17 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Caldera Undercity (boss fight spawns) |
| Pallor Nest | Pallor | 23 | 1,248 | 80 | 44 | 32 | 38 | 27 | 26 | 40 | 74 | Pallor Sample (75%) | Nest Fragment (25%) | Spirit | — | — | Despair, Death | Caldera Undercity (deeper tunnels, infection source) |
| *Pallor Nest Mother* | Boss | 25 | 6,000 | 87 | 72 | 45 | 73 | 43 | 33 | 87 | 3,000 | Broodchamber Map (100%) | Nest Mother's Core (100%) | Flame, Spirit | Frost | — | Death, Petrify, Stop, Sleep, Confusion, Despair | Caldera Undercity (deepest junction, sidequest) |

### Boss Notes — Caldera Undercity

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Pallor Nest Mother** (Optional) — Lv 25, 6,000 HP, Boss. 1 phase.

---

## Axis Tower

Recommended party level: 22–28. Carradan military tower — the
infiltration dungeon. 60% Pallor source encounters. The army has
fallen. Kole channels the Pallor directly.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Compact Officer | Humanoid | 24 | 1,344 | 0 | 46 | 33 | 39 | 28 | 27 | 43 | 79 | Potion (75%) | Compact Insignia (25%) | — | — | — | — | Axis Tower (Floors 1–3) |
| Forgewright Sentry | Construct | 24 | 1,344 | 0 | 46 | 33 | 39 | 28 | 27 | 43 | 79 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Axis Tower (Floors 2–3) |
| Arcanite Hound | Construct | 23 | 1,248 | 0 | 44 | 32 | 38 | 27 | 26 | 40 | 74 | Scrap Metal (75%) | Hound Gear (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Axis Tower (Floors 1–2) |
| Pallor Soldier | Pallor | 26 | 1,548 | 91 | 49 | 36 | 42 | 30 | 28 | 85 | 153 | Potion (75%) | Pallor Insignia (25%) | Spirit | Void | — | Despair, Death | Axis Tower (Floors 4–5, Ironmark tunnel) (infection source — passive aura) |
| Pallor Wisp | Pallor | 24 | 1,344 | 84 | 46 | 33 | 39 | 28 | 27 | 43 | 79 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Axis Tower (infection source, 60%) |
| Compact Gyrocopter | Construct | 24 | 1,344 | 0 | 46 | 33 | 39 | 28 | 27 | 43 | 79 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Axis Tower (tower defense, spawn-on-death) |
| Downed Pilot | Humanoid | 22 | 1,155 | 0 | 43 | 31 | 36 | 26 | 25 | 22 | 40 | Potion (75%) | Pilot's Goggles (25%) | — | — | — | — | Axis Tower (spawned by Gyrocopter) |
| Elite Guard | Humanoid | 26 | 1,548 | 0 | 49 | 36 | 42 | 30 | 28 | 85 | 153 | Potion (75%) | Elite Insignia (25%) | — | — | — | — | Axis Tower (Floors 4–5, Kole's personal guard) |
| Pallor Shade | Pallor | 26 | 1,548 | 91 | 37 | 36 | 48 | 33 | 28 | 127 | 229 | Ether Wisp (75%) | Spirit Essence (25%) | Spirit | Void | — | Despair, Death | Axis Tower (Floors 4–5, rare) |
| Pallor Brigand | Pallor | 26 | 1,114 | 91 | 56 | 25 | 42 | 30 | 28 | 127 | 229 | Potion (75%) | Pallor Blade (25%) | Spirit | Void | — | Despair, Death | Axis Tower (rare, deserters consumed by despair) |
| *General Vassar Kole* | Boss | 28 | 30,000 | 98 | 78 | 49 | 81 | 48 | 36 | 7,500 | 12,000 | Kole's Epaulettes (100%) | Map to the Convergence (100%) | — | — | — | Death, Petrify, Stop, Sleep, Confusion | Ironmark Citadel Command Chamber (via Axis Tower Floor 5 tunnel) |

### Scripted Set-Piece: "The Garrison Falls"

Occurs on Floor 4 of the Axis Tower. Non-preventable story moment.

- **Encounter:** 4 Compact Officers
- **Turn 1:** Kole's voice: "Let them in."
- All 4 Officers transform into Pallor Soldiers simultaneously
- No infection source needed — Kole channels the Pallor directly
- **Narrative:** Kole willingly corrupts his own soldiers

### Boss Notes — Axis Tower / Ironmark

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **General Vassar Kole** — Lv 28, 30,000 HP, Boss. 2 phases.

---

## Ironmark Citadel Dungeons

Recommended party level: 24–28. The citadel is fully consumed by
the Pallor. 75% Pallor source encounters. Former soldiers wander
the halls with empty eyes.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Pallor-Touched Soldier | Humanoid | 25 | 1,445 | 0 | 48 | 35 | 41 | 29 | 28 | 47 | 85 | Potion (75%) | Compact Insignia (25%) | — | — | — | — | Ironmark Citadel (Cell Block, Guard Station) (Pre-existing — already Pallor-touched before encounter, NOT a mid-combat conversion. Retains Humanoid type.) |
| Pallor Wisp | Pallor | 26 | 1,548 | 91 | 49 | 36 | 42 | 30 | 28 | 51 | 91 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Ironmark Citadel (infection source, 75%) |
| Pallor Warden | Pallor | 26 | 1,702 | 91 | 49 | 41 | 42 | 30 | 21 | 85 | 153 | — | Pallor Ward (25%) | Spirit | Void | — | Despair, Death | Ironmark Citadel (Inner Ring) |
| Pallor Shade | Pallor | 26 | 1,548 | 91 | 37 | 36 | 48 | 33 | 28 | 127 | 229 | Ether Wisp (75%) | Spirit Essence (25%) | Spirit | Void | — | Despair, Death | Ironmark Citadel (shared with Axis Tower) |
| Grey Mite | Pallor | 24 | 913 | 84 | 41 | 33 | 39 | 28 | 27 | 10 | 19 | — | Grey Residue (25%) | Spirit | — | — | Despair, Death | Ironmark Citadel (infesting cells) |
| Pallor Revenant | Pallor | 26 | 1,548 | 91 | 49 | 36 | 42 | 30 | 28 | 85 | 153 | — | Bone Dust (25%) | Spirit | Void | — | Despair, Death | Ironmark Citadel (Inner Ring) |
| Pallor Wolf | Pallor | 26 | 1,114 | 91 | 56 | 25 | 42 | 30 | 28 | 127 | 229 | Beast Hide (75%) | Wolf Pelt (25%) | Spirit | Void | — | Despair, Death | Ironmark Citadel (Outer Ring, patrol) |

### Scripted Set-Piece: "The Last Holdout"

Occurs in Cell Block B of Ironmark Citadel. Non-preventable
story moment.

- **Encounter:** 2 enemy Compact Officers + allied NPC soldiers
- **Mid-combat:** Pallor surges through conduits
- Enemy Officers transform — AND one allied NPC transforms
- Player fights converted enemies + former ally
- **Emotional:** The Pallor doesn't discriminate

---

## Interlude Summary

- **Total:** 52 enemies across 6 dungeons
- **Type distribution:** Pallor (~40–45%), Beast (15%),
  Construct (15%), Spirit (12%), Undead (8%), Humanoid (8%),
  Elemental (5%)
- **Pallor presence:** 30%–75% escalating
- **New families:** Guardian, Royal Wraith, Hound, Sentry (4)
- **New mechanic:** Pallor Infection (4 source types,
  3 scripted set-pieces, Construct immunity)
- **Tier 3 debuts:** Vermin, Shade, Automata,
  Crawler, Sprite, Soldier, Dead
- **Tier 4 debuts:** Soldier, Shade, Warden, Dead, Bandit, Wolf
