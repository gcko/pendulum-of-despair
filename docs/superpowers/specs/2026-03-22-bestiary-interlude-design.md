# Enemy Bestiary Design Spec (Gap 1.3 — Sub-project 2b: Interlude)

**Date:** 2026-03-22
**Status:** Draft
**Scope:** Populate interlude.md with all Interlude enemies: Rail Tunnels,
Corrund Undercity, Valdris Crown Catacombs, Caldera Undercity, Axis Tower,
and Ironmark Citadel Dungeons. Introduce the Pallor Infection mechanic.
Add 4 new palette-swap families. Update palette-families.md with Tier 3/4
entries for existing families.
**Gap:** 1.3 (Enemy Bestiary)
**Depends On:** Sub-project 2a (COMPLETE — PR #20 merged)

---

## 1. Purpose

Populate the Interlude bestiary file with ~52 enemies across 6 dungeons.
The Interlude is the narrative turning point — the Pallor has broken
through, cities are falling, and the world is fractured. This is where:

- Pallor-type enemies debut in force (40–75% encounter rate, escalating)
- The **Pallor Infection mechanic** is introduced — normal enemies can
  be converted to Pallor mid-combat by infection sources
- Tier 3 and Tier 4 palette-swap variants appear for the first time
- 3 scripted "transformation set-pieces" deliver unforgettable moments

This is the second of two PRs for Sub-project 2. The first PR covered
Act II dungeons (act-ii.md, PR #20).

## 2. Established Rules (Do NOT Redesign)

All canonical from Sub-projects 1–2a:

- **Stat template:** 19 columns (per bestiary/README.md)
- **8 enemy types** with gameplay effects (per README.md)
- **Stat scaling formulas** (per README.md)
- **Reward formulas:** Logistic bounded growth (Gold cap 10,000,
  Exp cap 30,000) with threat multipliers
- **Role adjustments:** Swarm -32% HP, Glass cannon -28% DEF,
  Caster -23% ATK, Tank -22% SPD
- **Enemy LCK:** Fixed 5% crit rate
- **Boss default immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Formatting:** Em dash (—) for "none", en dash (–) for ranges
- **Boss notes:** Reference dungeons-world.md/dungeons-city.md as
  authoritative for exact phase mechanics. Bestiary summarizes only.
- **Steal/Drop:** Separate lines in boss notes matching stat table columns

## 3. The Pallor Infection Mechanic

### 3.1 Overview

The signature Interlude combat mechanic. Pallor infection sources in
encounters can convert normal enemies to Pallor-type mid-combat. This
creates tactical priority decisions: kill the source fast, or deal with
the immediate threat while corruption spreads.

### 3.2 Infection Sources (4 types)

| Source | Convert Speed | Range | Priority | Counter |
|--------|-------------|-------|----------|---------|
| Pallor Nest | Spawns 1–2 Grey Mites/turn | All (indirect) | Low | Destroy the Nest |
| Pallor Seep | 1 enemy every 4 turns | Adjacent only | Medium | Kill it or adjacents first |
| Pallor Wisp | 1 enemy every 3 turns | Any in encounter | High | Kill ASAP — fastest |
| Pallor Soldier | 20% chance/turn per adjacent | Adjacent only | Low | Kill or isolate |

### 3.3 Conversion Process

1. Source selects target: nearest non-Pallor, non-Construct, non-Boss enemy
   (Constructs are immune — machines cannot feel despair)
2. **Grey mist visual** on target for 1 turn (warning to player)
3. Next turn: target transforms:
   - **Family enemy with Pallor tier** → becomes that variant
     (e.g., Compact Officer → Pallor Soldier with full Tier 4
     abilities from palette-families.md)
   - **No Pallor variant exists** → becomes "Pallor-Touched [Name]"
     with generic boost: +30% current HP as heal, +Despair Touch
     ability, type→Pallor, Weak→Spirit, Immune→Despair
4. Converted enemy acts on its next turn

> **Note:** Pre-existing "Pallor-Touched" enemies (like the Pallor-Touched
> Soldier in Ironmark) are NOT the result of mid-combat conversion. They
> were corrupted before the encounter and retain their original type. Only
> mid-combat conversions change type to Pallor.

### 3.4 Immunity Rules

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

### 3.5 Scripted Transformation Set-Pieces (3 total)

Non-preventable story moments:

**1. Rail Tunnels — "The Wave Hits" (~3rd encounter)**
- Encounter: 3 Forge Phantoms + 1 Rail Sentry
- Turn 2: grey mist rolls in (cutscene)
- All 3 Forge Phantoms → Pallor Shades simultaneously
- Rail Sentry unaffected (Construct immune)
- **Teaches:** Construct immunity + Pallor threat level

**2. Axis Tower — "The Garrison Falls" (Floor 4, scripted)**
- Encounter: 4 Compact Officers
- Turn 1: Kole's voice: "Let them in."
- All 4 Officers → Pallor Soldiers simultaneously
- No source needed — Kole channels the Pallor directly
- **Narrative:** Kole willingly corrupts his own soldiers

**3. Ironmark Citadel — "The Last Holdout" (Cell Block B)**
- Encounter: 2 enemy Compact Officers + allied NPC soldiers
- Mid-combat: Pallor surges through conduits
- Enemy Officers transform — AND one allied NPC transforms
- Player fights converted enemies + former ally
- **Emotional:** The Pallor doesn't discriminate

### 3.6 Infection Density by Dungeon

| Dungeon | Pallor Source % | Curve Position |
|---------|----------------|----------------|
| Rail Tunnels | 30% | Early — "something is down here" |
| Corrund Undercity | 30% | Early — "sewers are contaminated" |
| Valdris Catacombs | 40% | Mid — "even the dead are changing" |
| Caldera Undercity | 45% | Mid — "the forges are lost" |
| Axis Tower | 60% | Late — "the army has fallen" |
| Ironmark Citadel | 75% | Late — "fully consumed" |

## 4. Interlude Enemy Roster (52 entries)

### 4.1 Rail Tunnels (Lv 18–22) — 10 enemies

| Name | Family | Tier | Lv | Type | Threat | Notes |
|------|--------|------|----|------|--------|-------|
| Rail Sentry | Sentry | 1 | 18 | Construct | Low | Turret on rail cart, Storm-weak |
| Forge Phantom | Shade | 2 | 20 | Spirit | Standard | Second Tier 2 Shade variant (biome: Rail Tunnels). Worker silhouette, Despair debuff. |
| Pallor Nest | — (source) | — | 20 | Pallor | Standard | **Infection source.** Immobile spawner. |
| Grey Mite | — (spawned) | — | 18 | Pallor | Trivial | Spawned by Nest. MP drain. |
| Steam Elemental | Elemental | 2 (biome variant) | 20 | Elemental | Standard | Flame AoE, Blind. Second Tier 2 Elemental biome variant. |
| Tunnel Vermin | Vermin | 3 | 22 | Beast | Standard | Tier 3 — Plague Bite (Poison) |
| Pipe Wraith | Wraith | 1 | 20 | Spirit | Standard | Ley entity, ignores 25% DEF |
| Grey Mite Swarm | — (unique) | — | 20 | Pallor | Standard | Dense swarm variant, AoE MP drain |
| *Corrupted Boring Engine* | — | — | 22 | Construct | Dangerous | **Mini-boss.** 6,000 HP. |
| *The Ironbound* | — | — | 24 | Boss | Boss | **Boss.** 22,000 HP. Per dungeons-world.md. |

### 4.2 Corrund Undercity (Lv 18–22) — 6 enemies

| Name | Family | Tier | Lv | Type | Threat | Notes |
|------|--------|------|----|------|--------|-------|
| Forge-Smoke Creature | — (unique) | — | 19 | Elemental | Standard | Gaseous, Flame, Weak→Frost |
| Service Automata | Automata | 2 (biome variant) | 20 | Construct | Standard | Haywire drones |
| Sewer Rat | Hare | 2 | 18 | Beast | Trivial | Swarm fodder |
| Pallor Seep | — (source) | — | 20 | Pallor | Standard | **Infection source.** Slow converter (4 turns). High HP. |
| Sewer Leech | Leech | 2 | 20 | Beast | Low | Drain specialist |
| Pallor Wisp | — (source) | — | 20 | Pallor | Standard | **Infection source.** Fast converter (3 turns). |

### 4.3 Valdris Crown Catacombs (Lv 20–25) — 10 enemies

| Name | Family | Tier | Lv | Type | Threat | Notes |
|------|--------|------|----|------|--------|-------|
| Restless Dead | Dead | 1 | 20 | Undead | Trivial | Escape only — weakened, 2 fixed encounters |
| Crypt Shade | Shade | 2 | 22 | Spirit | Standard | Tier 2 — royal tomb variant |
| Tomb Warden | Warden | 2 | 22 | Undead | Standard | Tier 2 — armored tomb guardian. Level revised from projected 17 to 22 for Catacombs placement. |
| Tomb Mite | Mite | 2 | 20 | Beast | Low | Return visit swarm |
| Drowned Sentinel | — | — | 22 | Construct | Standard | Flooded chamber reappearance |
| Tomb Guardian | Guardian | 1 | 23 | Construct | Standard | **NEW family.** Animated stone statue. |
| Royal Wraith | Wraith (royal) | 1 | 24 | Spirit | Dangerous | **NEW family.** Spectral knight. Magic. Weak→Ley. |
| Pallor Wisp | — (source) | — | 22 | Pallor | Standard | **Infection source.** 40% encounters. |
| Wailing Dead | Dead | 3 | 24 | Undead | Standard | Tier 3 Dead — Death Wail AoE + Despair chance. Level revised from projected 26 to 24 for Catacombs placement. |
| *The Undying Warden* | — | — | 25 | Boss | Boss | **Optional boss.** Spirit-construct. Per dungeons-city.md. |

### 4.4 Caldera Undercity (Lv 20–25) — 8 enemies

| Name | Family | Tier | Lv | Type | Threat | Notes |
|------|--------|------|----|------|--------|-------|
| Heat Sprite | Sprite | 3 | 22 | Elemental | Standard | Fire sprite — Weak→Frost. Elder Sprite variant. |
| Corrupted Forge Construct | Automata | 2 (biome variant) | 23 | Construct | Standard | Half-melted, fire attacks |
| Pallor Seep | — (source) | — | 22 | Pallor | Standard | **Infection source.** 45% encounters. |
| Grey Crawler | Crawler | 3 | 24 | Beast | Standard | Blight Crawler — Acid Spit, high DEF |
| Pallor Mite | — (boss spawn) | — | 22 | Pallor | Low | Nest Mother boss spawn only. NOT a Mite family tier (Mites don't become Pallor per palette-families.md). |
| Grey Mite | — (spawned) | — | 22 | Pallor | Trivial | Boss fight spawns |
| Pallor Nest | — (source) | — | 23 | Pallor | Standard | Infection source in deeper tunnels |
| *Pallor Nest Mother* | — | — | 25 | Boss | Boss | **Sidequest boss.** 6,000 HP. Kerra guest. Per dungeons-city.md. |

### 4.5 Axis Tower (Lv 22–28) — 11 enemies

| Name | Family | Tier | Lv | Type | Threat | Notes |
|------|--------|------|----|------|--------|-------|
| Compact Officer | Soldier | 2 | 24 | Humanoid | Standard | Tier 2 Soldier — pairs, Rally + Shield Bash |
| Forgewright Sentry | Sentry | 2 | 24 | Construct | Standard | Turret, cone scan, high damage |
| Arcanite Hound | Hound | 1 | 23 | Construct | Standard | **NEW family.** Mechanical dog. Fast. Back-attack. |
| Pallor Soldier | Soldier | 4 | 26 | Pallor | Dangerous | Tier 4 — grey-eyed, empty. Despair Strike. |
| Pallor Wisp | — (source) | — | 24 | Pallor | Standard | **Infection source.** 60% encounters. |
| Compact Gyrocopter | Airborne | 1 | 24 | Construct | Standard | Tower defense. Spawns Downed Pilot. |
| Downed Pilot | Airborne (spawn) | — | 22 | Humanoid | Low | Spawned by Gyrocopter. |
| Elite Guard | Soldier | 3 | 26 | Humanoid | Dangerous | Tier 3 — Kole's personal guard. Counter Stance. |
| Pallor Shade | Shade | 4 | 26 | Pallor | Rare | Tier 4 — Dread Shroud AoE Despair. |
| Pallor Brigand | Bandit | 4 | 26 | Pallor | Rare | Tier 4 — deserters consumed by despair. |
| *General Vassar Kole* | — | — | 28 | Boss | Boss | **Boss.** 30,000 HP. Per dungeons-world.md encounter table. |

### 4.6 Ironmark Citadel Dungeons (Lv 24–28) — 7 enemies

| Name | Family | Tier | Lv | Type | Threat | Notes |
|------|--------|------|----|------|--------|-------|
| Pallor-Touched Soldier | — (unique) | — | 25 | Humanoid | Standard | Former soldiers. Slow, empty eyes. (Pre-existing — already Pallor-touched before encounter, NOT a mid-combat conversion. Retains Humanoid type.) |
| Pallor Wisp | — (source) | — | 26 | Pallor | Standard | **Infection source.** 75% encounters. |
| Pallor Warden | Warden | 4 | 26 | Pallor | Dangerous | Tier 4 — Despair Aura passive. |
| Pallor Shade | Shade | 4 | 26 | Pallor | Rare | Tier 4 — Dread Shroud + Possess. |
| Grey Mite | — (spawned) | — | 24 | Pallor | Trivial | Infesting cells. |
| Pallor Revenant | Dead | 4 | 26 | Pallor | Dangerous | Tier 4 — Soul Rend + Undying auto-revive. |
| Pallor Wolf | Wolf | 4 | 26 | Pallor | Rare | Tier 4 — Pallor Howl AoE Despair + pack ATK buff. |

### 4.7 Interlude Summary

- **Total:** 52 unique table entries (35 regular + 6 sources +
  3 spawned + 2 unique + 1 mini-boss + 3 bosses + 2 shared across
  dungeons). Scripted set-pieces reuse listed enemies, not separate
  entries.
- **Type distribution:** Pallor (~40–45%), Beast (15%), Construct (15%),
  Spirit (12%), Undead (8%), Humanoid (8%), Elemental (5%)
- **Pallor presence:** 30% → 75% escalating across dungeons
- **New families:** Guardian, Royal Wraith, Hound, Sentry (4)
- **Tier 3 debuts:** Vermin, Shade, Automata, Crawler,
  Sprite, Soldier, Dead
- **Tier 4 debuts:** Soldier, Shade, Warden, Dead, Bandit, Wolf
- **New mechanic:** Pallor Infection (4 source types, 3 set-pieces)

## 5. New Palette-Swap Families (4)

### 5.1 Guardian Family

**Base:** Tomb Guardian (Lv 23, Construct, Standard)
**Planned Tiers:** 3

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Tomb Guardian | 23 | Construct | — | Stone Slam (heavy physical), Sentinel Stance (counter-attack) | Standard |
| 2 | Temple Guardian | 32 | Construct | Resist→Earth | +Quake Stomp (AoE + Stun), +Stone Skin (DEF way up 2 turns) | Dangerous |
| 3 | Grey Guardian | 42 | Construct | Weak→Storm | +Pallor Pulse (Despair AoE, Construct-channeled), +Immovable (immune to knockback/Stun) | Rare |

> Guardians are animated stone constructs. Construct-type throughout —
> immune to infection. The Grey Guardian (Tier 3) is NOT infected — it
> was BUILT by Pallor-corrupted engineers to channel Despair through
> stone circuits. A weapon of despair, not a victim. Foreshadows the
> Act III/IV "designed Pallor Construct" concept.

### 5.2 Royal Wraith Family

**Base:** Royal Wraith (Lv 24, Spirit, Dangerous)
**Planned Tiers:** 3

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Royal Wraith | 24 | Spirit | — | Spectral Blade (magic damage), Royal Command (buffs allied spirits), Phase (50% phys reduction) | Dangerous |
| 2 | Fallen Champion | 34 | Spirit | Weak→Ley, Resist→Void | +Champion's Challenge (forces single-target on self), +Cursed Blade (Silence on hit) | Dangerous |
| 3 | Pallor Regent | 46 | Pallor | Weak→Spirit, Resist→Void | +Despair Decree (party-wide Despair + Silence), +Undying Loyalty (summons 2 Pallor Shades) | Rare |

> Royal Wraiths are spectral knights — the ghosts of Valdris royalty.
> They command other spirits in combat. The Pallor Regent is a king
> consumed by despair who commands shade armies.

### 5.3 Hound Family

**Base:** Arcanite Hound (Lv 23, Construct, Standard)
**Planned Tiers:** 3

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Arcanite Hound | 23 | Construct | — | Lunge (back-attack), Tracking (always targets lowest HP), Fast Strike (high SPD) | Standard |
| 2 | War Hound | 32 | Construct | Resist→Storm | +Pack Circuit (buffs adjacent Constructs), +Overclock Bite (2-hit + Burn) | Dangerous |
| 3 | Grey Hound | 42 | Construct | — | +Despair Fang (deals Despair damage — Construct channeling Pallor energy), +Hunt Protocol (guaranteed back-row, ignores evasion) | Rare |

> Arcanite Hounds are Carradan military Constructs — mechanical attack
> dogs. The Grey Hound (Tier 3) is the first "designed Pallor Construct"
> — not infected (immune to infection) but BUILT by corrupted engineers
> to channel Despair through Arcanite circuits. The machine doesn't
> despair; its creator did. Foreshadows Act III/IV Pallor weapon design.

### 5.4 Sentry Family

**Base:** Rail Sentry (Lv 18, Construct, Low)
**Planned Tiers:** 2

| Tier | Name | Lv | Type | Element Shift | New Abilities | Threat |
|------|------|----|------|--------------|---------------|--------|
| 1 | Rail Sentry | 18 | Construct | — | Turret Fire (ranged), Scan Lock (increases accuracy) | Low |
| 2 | Forgewright Sentry | 24 | Construct | — | +Cone Scan (reveals row), +High-Caliber Shot (heavy single-target) | Standard |

## 6. Existing Family Tier Updates

Families gaining Tier 3 and/or Tier 4 entries in the Interlude:

| Family | New Tier(s) | Names | Location |
|--------|------------|-------|----------|
| Vermin | 3 | Tunnel Vermin (Lv 22) | Rail Tunnels |
| Shade | 2 (variant), 4 | Forge Phantom (Lv 20, second Tier 2 biome variant), Pallor Shade (Lv 26) | Rail Tunnels, Axis/Ironmark |
| Elemental | 2 (biome variant) | Steam Elemental (Lv 20) | Rail Tunnels |
| Dead | 3, 4 | Wailing Dead (Lv 24), Pallor Revenant (Lv 26) | Catacombs, Ironmark |
| Warden | 2 (revised), 4 | Tomb Warden (Lv 22, revised from 17), Pallor Warden (Lv 26) | Catacombs, Ironmark |
| Mite | — | (Pallor Mite is a boss spawn, not a family tier) | Caldera |
| Crawler | 3 | Grey Crawler (Lv 24) | Caldera |
| Sprite | 3 | Heat Sprite (Lv 22) | Caldera |
| Automata | 2 (biome variants) | Service Automata (Lv 20), Corrupted Forge Construct (Lv 23) | Corrund, Caldera |
| Soldier | 2, 3, 4 | Compact Officer (Lv 24), Elite Guard (Lv 26), Pallor Soldier (Lv 26) | Axis Tower |
| Sentry | 2 | Forgewright Sentry (Lv 24) | Axis Tower |
| Bandit | 4 | Pallor Brigand (Lv 26) | Axis Tower |
| Wolf | 4 | Pallor Wolf (Lv 26) | Ironmark |
| Leech | 2 | Sewer Leech (Lv 20) | Corrund |
| Hare | 2 | Sewer Rat (Lv 18) | Corrund |

## 7. Boss Details

### 7.1 The Ironbound (Rail Tunnels Boss)

> **Note:** docs/story/dungeons-world.md is authoritative for exact
> Ironbound phase mechanics. The following summarizes.

- **HP:** 22,000 (per dungeons-world.md)
- **Type:** Boss | **Level:** 24
- **Phase 1 (22,000–11,000):** Drill Charge, Steam Vent, Tunnel
  Collapse, Bore Forward. See dungeons-world.md.
- **Phase 2 (below 11,000):** Hesitation windows, Desperate Bore.
  Lira/Torren special interactions. See dungeons-world.md.
- **Weakness:** Storm (150%), Void (125%)
- **Resistance:** Earth (50%), Flame (75%)
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Reinforced Drill Bit (crafting)
- **Drop:** Operator's Badge (key item)

### 7.2 General Vassar Kole (Axis Tower Boss)

> **Note:** docs/story/dungeons-world.md is authoritative.

- **HP:** 30,000 (per dungeons-world.md encounter table; prose paragraph has a known typo of 12,000)
- **Type:** Boss | **Level:** 28
- **Phase 1 (100–50%):** Arcanite sword attacks, summons Pallor
  Soldiers. See dungeons-world.md.
- **Phase 2 (50–0%):** Channels Ironmark conduits, Grey Shockwave,
  Despair aura. Destroy conduit crystals to remove aura.
  See dungeons-world.md.
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Kole's Epaulettes (+15 DEF, +10 MDEF)
- **Drop:** Map to the Convergence (key item)

### 7.3 Pallor Nest Mother (Caldera Sidequest Boss)

> **Note:** docs/story/dungeons-city.md is authoritative.

- **HP:** 6,000 (per dungeons-city.md)
- **Type:** Boss | **Level:** 25
- **Attacks:** Brood Pulse, Nest Defense, Tendril Lash, Corruption
  Surge, Spawn Brood, Desperate Contraction. See dungeons-city.md.
- **Guest NPC:** Kerra (800 HP, ATK 18, DEF 14)
- **Weakness:** Flame (150%), Spirit (125%)
- **Resistance:** Frost (50%)
- **Immunity:** Death, Petrify, Stop, Sleep, Confusion, Despair
- **Steal:** Broodchamber Map (key item)
- **Drop:** Nest Mother's Core (crafting), 1,500 Gold

### 7.4 The Undying Warden (Catacombs Optional Boss)

> **Note:** docs/story/dungeons-city.md is authoritative.

- **HP:** TBD (not specified in dungeons-city.md — placeholder 8,000
  based on Interlude progression). **Implementation must resolve this
  with the user before populating interlude.md — do not treat the
  placeholder as canonical.**
- **Type:** Boss | **Level:** 25
- **Phase 1:** Spectral swords + ley-crystal shards
- **Phase 2 (below 50%):** Ley-crystal eruptions (AoE magic)
- **Special:** Torren can attempt to calm it mid-fight
- **Immunities:** Death, Petrify, Stop, Sleep, Confusion
- **Steal:** Catacomb Map (exploration)
- **Drop:** Warden's Binding (accessory: auto-Protect/Shell at battle
  start), 2,000 Gold

## 8. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `docs/story/bestiary/interlude.md` | Rewrite (from TBD) | Full Interlude enemy stat tables (52 entries) |
| `docs/story/bestiary/palette-families.md` | Modify | Add 4 new families, Tier 3/4 for ~15 existing |
| `docs/story/bestiary/CONTINUATION.md` | Modify | Update Sub-project 2b status |
| `docs/analysis/game-design-gaps.md` | Modify | Check off Interlude items in Gap 1.3 |

## 9. Out of Scope

- Act III and Optional enemies (Sub-project 3)
- Boss AI behavior scripts beyond summaries (Sub-project 4)
- Drop/Steal item details beyond placeholders (Gap 1.4)
- Ley Line Depths floors 4–5 (Act III content)
- Post-Pallor Construct variants beyond Grey Hound/Grey Guardian
  foreshadowing (Act III/IV design)

## 10. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Pallor density | 40–45% overall, 30%→75% escalating | Rising tension curve through Interlude |
| Infection mechanic | Source-based (kill source to stop) | Player agency — tactical priority puzzle |
| Conversion rules | Family→Pallor tier; generic for non-family | Rewards bestiary knowledge |
| Construct immunity | Absolute (infection) | Machines can't despair. Designed variants later. |
| Scripted set-pieces | 3 guaranteed transformations | Unforgettable narrative moments |
| Grey Hound/Guardian | Construct deals Despair (designed, not infected) | Foreshadows Act III/IV Pallor weapon concept |
| Boss mechanics | Summary only, reference dungeons source | Lesson from PR #20 — don't duplicate canonical source |
| New families | 4 (Guardian, Royal Wraith, Hound, Sentry) | Minimal — Interlude reuses/evolves existing families |
