# Difficulty & Balance Framework Specification

> **Gap:** 3.4 Difficulty & Balance Framework
> **Status:** MISSING → design approved
> **Priority:** P2
> **Depends On:** 1.1–1.6 (all Tier 1 gaps — all COMPLETE)
> **Output file:** `docs/story/difficulty-balance.md`

---

## 1. Design Philosophy

### 1.1 FF6 Accessible

Combat serves the story. The game is beatable by anyone who engages
with the systems — buying equipment at each town, healing when low,
exploiting weaknesses. Grinding is never required on the critical
path. The Pallor's emotional tension (desaturation, Despair status,
narrative stakes) is the real challenge, not the battle mechanics.

**One fixed difficulty.** No difficulty settings, no toggles. One
carefully tuned experience. Optional endgame content (Dreamer's
Fault, superbosses) provides escalation for players who seek a
greater challenge.

### 1.2 Core Principles

- **Trash is fast, bosses are events.** Regular encounters last
  15–30 seconds. Boss fights are 2–8 minutes depending on act.
- **HP is abundant, MP is the constraint.** Potions are cheap and
  plentiful. Ethers are expensive relative to their value. This
  pushes physical attacks for trash, magic saved for bosses.
- **Equipment choices matter but don't gatekeep.** ~70% of
  equipment is affordable on the critical path. The remaining 30%
  rewards side content, not grinding.
- **No frustration loops.** Auto-save prevents lost progress.
  Generous save points. Flee always has a chance in random
  encounters (bosses disable flee). Level-up restores HP/MP.

---

## 2. Combat Pacing Targets

### 2.1 Regular Enemies — Hits to Kill

Regular enemies die in 2–4 physical hits from the primary attacker
(per [combat-formulas.md](../../story/combat-formulas.md) § Fight
Duration Targets). AoE magic clears groups efficiently. The ATK²/6
formula scales quadratically, so well-equipped physical attackers
trend toward the lower end (2 hits), while support characters need
3–4.

**Verification at key milestones** (approximate ATK values assume
Edren's base growth + current tier weapon; see
[progression.md](../../story/progression.md) § Character Growth and
[equipment.md](../../story/equipment.md) § Weapons for exact values):

The table below shows Edren (highest ATK) alongside Torren (lowest
physical ATK). The "2–4 hits from primary attacker" target in
combat-formulas.md refers to the strongest physical attacker (Edren
or Cael), who should need 2–4 hits against at-level regular enemies.

| Level | Edren ATK | Enemy | DEF | HP | Edren hits | Torren hits |
|-------|-----------|-------|-----|-----|-----------|-------------|
| 5 | ~26 | Wild Boar (5) | 9 | 112 | 2 | 4+ |
| 12 | ~40 | Polluted Elemental (9) | 15 | 273 | 2 | 4+ |
| 60 | ~120 | Pallor Boar (28) | 43 | 1,943 | 1 | 2 |

In Acts I–II, Edren needs 2 hits against at-level enemies — matching
the "2–4 hits from primary attacker" target in combat-formulas.md.
By Act III, the quadratic ATK²/6 scaling causes Edren to one-shot
most trash. This is intentional — late-game random encounters should
feel fast, with the challenge coming from encounter rate, Despair
status, and boss fights rather than individual trash mobs. Support
characters (Torren, Maren) still need 2–4 physical hits or use magic.

> **Note:** The "Regular Enemy HP by Act" table in combat-formulas.md
> lists Act III enemy HP as 6,000–14,000, but the actual bestiary
> (act-iii.md) has Act III regulars at 1,000–2,784 HP. The bestiary
> is authoritative; the combat-formulas.md table needs reconciliation.

### 2.2 Boss Fight Duration

Boss fights escalate in duration as the game progresses. Duration is
measured in real-time minutes at Battle Speed 3 (default).

| Boss Type | Act | Duration Target | HP Range | Notes |
|-----------|-----|-----------------|----------|-------|
| Mini-boss | I | 0.5–1 min | 1,000–2,000 | Tutorial fights |
| Standard boss | I–II | 3–5 min | 4,000–15,000 | 30–50 party actions |
| Major boss | Int–III | 5–8 min | 15,000–45,000 | 50–80 party actions |
| Penultimate boss (Cael) | III | 5–7 min | 80,000 (two phases) | Emotional climax |
| Final boss (The Pallor Incarnate) | III | 5–8 min | 70,000 | True ending |
| Superboss (optional) | Post-game | 8–12 min | 100,000+ | Victory lap |

These targets align with [combat-formulas.md](../../story/combat-formulas.md) §
Fight Duration Targets: regular enemies 2–4 hits, mini-bosses 30–60s,
standard bosses 3–5 min, major bosses 5–8 min.

**Duration is governed by:**
- Boss HP (primary lever)
- Phase transitions (brief invulnerability during scripted events)
- Healing pressure (boss damage forces defensive turns)
- Mechanic complexity (status effects, Despair, phase shifts)

**Why these numbers work with our formulas:**

At level 12 (Vein Guardian fight, 6,000 HP with 2 behavior phases),
a 4-member party averaging ~200 damage per action at ~2.5s per action,
with ~60% of actions being damage (rest: healing, buffs, defending):

`6,000 HP / (200 × 4 × 0.6) × 2.5s = ~31s base`

Add phase transition (~20s scripted), healing pressure, and variance:
**~1.5–2 minutes.** The Vein Guardian is the game's first major boss
and functions as a tutorial — its duration falls below the standard
3–5 minute target intentionally. Later Act I bosses (Corrupted Fenmother at
18,000 HP) hit the standard range.

At endgame (Cael, 80,000 HP total across 2 phases), party averaging
~800 damage per action at ~1.5s per action, ~50% damage actions
(significant healing/Despair/phase-mechanic overhead):

`80,000 / (800 × 4 × 0.50) × 1.5s = ~75s base`

Add 2 phase transitions (~45s each), Despair management cycles,
scripted dialogue, and healing overhead (~2× base): **~5–6 minutes.**
Within the 5–7 minute target.

### 2.3 Encounter Duration (Random Battles)

| Encounter Type | Duration | Notes |
|----------------|----------|-------|
| Trash (1–2 weak enemies) | 10–15s | One round of attacks |
| Standard (3–4 enemies) | 15–25s | Two rounds |
| Dangerous (formation with tough enemy) | 25–40s | May need healing |
| Back attack | +10–15s | Repositioning + recovery |
| Preemptive | -5–10s | Free opening round |

Random encounters should never exceed 1 minute at-level. If an
encounter consistently takes longer, the enemy stats are too high
or the player is underleveled.

---

## 3. Resource Management

### 3.1 HP Healing — Abundant

HP healing is effectively unlimited for prepared players:

| Item | HP Restored | Cost | GP/HP Ratio | Availability |
|------|-------------|------|-------------|-------------|
| Potion | 100 | 50g | 0.5g/HP | Act I shops |
| Hi-Potion | 500 | 300g | 0.6g/HP | Act II shops |
| Ley Tonic | 300 (party) | 800g | — (party-wide) | Act II shops (limited stock) |
| X-Potion | 100% HP | 1,500g | Variable | Act III shops (limited) |

A player spending 500g on Potions (10 Potions) has 1,000 HP of
healing — more than the entire party's HP pool in early Act I. HP
items are cheap enough that running out is a preparation failure,
not a design constraint.

**Healing spells supplement items:** Mend (3 MP, ~125–230 HP at early
levels depending on caster MAG), Leybalm (3 MP, similar), Breath of
the Wilds (8 MP, party heal). These conserve Potions but cost the
real resource: MP.

### 3.2 MP — The Soft Constraint

MP is the primary resource constraint across dungeons:

| Item | MP Restored | Cost | GP/MP Ratio |
|------|-------------|------|---------------|
| Ether | 30 MP | 200g | 6.67g/MP |
| Hi-Ether | 100 MP | 800g | 8.0g/MP |
| X-Ether | 100% MP | 2,000g | Variable |

Ethers are deliberately expensive relative to Potions (200g for
30 MP vs 50g for 100 HP) — MP recovery should feel like a scarce
resource compared to HP recovery. The gameplay loop:

1. **Trash encounters:** Use physical attacks (free). Save magic.
2. **Dangerous encounters:** Use targeted spells. Spend MP wisely.
3. **Boss fights:** Unload full spell arsenal. This is what MP is for.
4. **Post-boss:** Low on MP. Inn/save point restores before next area.

**MP sustainability targets per dungeon:**

| Dungeon Length | Floors | Encounters | MP Usage | Caster arrives at boss with |
|----------------|--------|------------|----------|---------------------------|
| Short (Act I) | 2–3 | 6–10 | ~30% max MP | ~60–70% MP |
| Medium (Act II) | 3–4 | 10–15 | ~45% max MP | ~40–55% MP |
| Long (Interlude) | 4–6 | 15–25 | ~60% max MP | ~25–40% MP |
| Gauntlet (Act III) | 5+ | 20–30+ | ~70% max MP | ~15–30% MP (Ethers needed) |

Midpoint rest opportunities (inn rooms, save points with healing
springs, NPC rest attendants at Oases) exist in longer dungeons to
prevent complete MP depletion.

### 3.3 Dungeon Supply Budget

A "prepared" player entering a dungeon should buy:

| Act | Potions | Ethers | Status Cures | Total Cost | % of Gold |
|-----|---------|--------|-------------|------------|-----------|
| I | 10–15 | 2–3 | 3–5 | ~1,200g | ~25% |
| II | 10–15 | 4–6 | 5–8 | ~2,500g | ~10% |
| Int | 10–20 | 5–8 | 5–10 | ~3,500g | ~8% |
| III | 15–25 | 8–12 | 8–12 | ~5,000g | ~6% |

As the game progresses, supply cost becomes a smaller fraction of
wealth — the player naturally accumulates more than they spend.
This prevents late-game resource anxiety.

**Remaining at boss:** A comfortable player arrives at the boss
with 30–50% of their supplies remaining. If they have less than
20%, they either skipped shops or the dungeon has a balance issue.

---

## 4. Progression Pacing

### 4.1 Expected Level per Area

These are the target levels for a player following the critical
path without grinding. Side quests and optional encounters may
push the player 1–3 levels above these targets.

| Area | Act | Player Level | Boss (Bestiary Lv) |
|------|-----|--------------|--------------------|
| Aelhart / Prologue | Prologue | 1–3 | — |
| Ember Vein | I | 5–8 | Ember Drake (8), Vein Guardian (12) |
| Fenmother's Hollow | I | 10–14 | Drowned Sentinel (10), Corrupted Fenmother (12) |
| Ley Line Depths | II | 18–22 | Ley Colossus (22) |
| Ashmark Factory | II | 20–24 | The Forge Warden (24) |
| Siege of Valdris | II | 20–24 | The Ashen Ram (22) |
| Bellhaven Smuggler Tunnels | II | 16–20 | No boss (regular enemies only) |
| Interlude dungeons | Int | 25–50 | Various (28–35) |
| Pallor Wastes overworld | III | 50–60 | The Grey Keeper (32), etc. |
| Convergence gauntlet | III | 60–70 | Cael, Knight of Despair (36/38), The Pallor Incarnate (40) |
| Dreamer's Fault | Post | 70–150 | Optional (50–100) |

**Note on boss "Lv" vs player level:** Boss "Lv" in the bestiary
is a stat-scaling reference — NOT directly comparable to player level.
Bosses have inflated HP, multi-phase mechanics, and AI scripts. A
party at 60–70 fighting Cael (Lv 36/38) is the intended balance.

### 4.2 Catch-Up Mechanics

Per [progression.md](../../story/progression.md):
- **Party join level:** `party_average - 1` — new members are never
  far behind.
- **Absent XP share:** 50% — reserve members stay close to the active
  party.
- **Level-up HP/MP restore:** Full heal on level-up provides periodic
  relief during dungeons.
- **Ley Scar grinding zone:** 4 high-XP enemies available from
  Act III onward for players who want to overlevel.

No catch-up mechanic is "free" — the player still needs to fight.
But the systems prevent any character from falling irretrievably
behind.

### 4.3 Equipment Progression Curve

Per [equipment.md](../../story/equipment.md):

| Tier | Act | ATK Range | Relative Power | New Tier Every |
|------|-----|-----------|---------------|---------------|
| 0 | Prologue | 3–5 | Baseline | — |
| 1 | Act I | 8–12 | 2–3× Tier 0 | ~3–4 hours |
| 2 | Act II | 15–22 | 2× Tier 1 | ~4–5 hours |
| 3 | Interlude | 28–38 | 1.5–2× Tier 2 | ~3–4 hours |
| 4 | Act III | 42–55 | 1.5× Tier 3 | ~4–5 hours |
| 5 | Endgame | 65–100 | 1.5–2× Tier 4 | Side quests |

Each tier upgrade feels significant — roughly doubling effective
physical damage output (ATK² scaling means a 50% ATK increase
yields ~125% more damage). New equipment is available at each town,
and the 70% affordability rate means the player can equip most of
the party but must make choices about who gets upgraded first.

---

## 5. Anti-Frustration Features

### 5.1 Auto-Save (Invisible)

The game auto-saves at these trigger points:
- Entering a new dungeon floor
- Before any boss fight (when the boss trigger zone is entered)
- Entering a new town/settlement
- After completing a side quest

Auto-save uses a dedicated slot separate from the 3 manual save
slots. No UI indicator — the save is silent. There is no "Continue
vs Load" menu — the Faint and Fast Reload system (Section 5.5)
handles wipe recovery with instant automatic reload.

**Relationship to Faint and Fast Reload:** When the party wipes,
the instant reload system (per [events.md](../../story/events.md) §
Faint and Fast Reload) loads the most recent save — whether manual
or auto. Auto-save ensures that target is always close.

**What auto-save does NOT do:**
- Does not save mid-dungeon-floor (prevents save-scumming chests)
- Does not save during boss fights
- Does not overwrite manual saves

### 5.2 Save Point Density

| Area Type | Save Point Frequency |
|-----------|---------------------|
| Towns | One per town (inn or dedicated save point) |
| Short dungeons (2–3 floors) | Entrance + before boss |
| Medium dungeons (3–4 floors) | Every 1–2 floors + before boss |
| Long dungeons (5+ floors) | Every floor + midpoint rest + before boss |
| Overworld | At each settlement/landmark |

A player should never be more than 10–15 minutes from a save point
on the critical path.

### 5.3 Flee Reliability

Per [combat-formulas.md](../../story/combat-formulas.md):
- Base flee chance: `clamp(50 + (party_avg_SPD - enemy_avg_SPD) × 2, 10, 90)`
- Minimum: 10% (always possible)
- Maximum: 90% (never guaranteed without items)
- Smoke Bomb: 100% flee (100g, non-boss, no rewards)
- Smokeveil (Sable, 4 MP): 100% flee (non-boss)
- Ward Talisman: ×0.5 encounter rate (1,500g accessory)
- Infiltrator's Cloak: ×0.5 encounter rate (treasure, Interlude)
- Boss fights: flee disabled entirely (no ambiguity)

### 5.4 No Missable Content

- All side quests remain available until the point of no return
  (entering the Convergence gauntlet in Act III).
- After the point of no return, quest givers warn the player with
  explicit dialogue ("Once you enter, you cannot return").
- Oasis C falls during the story but its sidequest (The Cracking
  Stone) is completable before the fall trigger.
- Post-Convergence: Oases A and B survive, shops expand.
- Dreamer's Fault remains accessible post-game.

### 5.5 Party Wipe Recovery

Per [events.md](../../story/events.md) § Faint and Fast Reload:
- **No game over screen.** No menu, no prompt, no "Game Over" text.
- Last Faint animation plays → fade to black (2s) → instant reload
  at the last save point (~4s total).
- XP, levels, gold, and boss-cutscene-seen flags are **preserved**
  across the wipe (applied on top of the save file).
- HP/MP set to 100% on reload.
- Boss pre-battle cutscenes auto-skip on retry (flag persists).
- The auto-save system (Section 5.1) ensures the reload target is
  always close — typically the dungeon floor entrance or pre-boss
  save point.

---

## 6. Difficulty Escalation by Act

### 6.1 Act I — Learning

- **Enemies:** Low stats, simple attack patterns, obvious weaknesses.
- **Bosses:** 1–2 phases, telegraph their dangerous moves.
- **Resources:** Abundant. Potions are cheap, inns are free/cheap.
- **Player learns:** Basic combat loop, ATB timing, elemental
  weaknesses, equipment purchasing.
- **Threat level:** Low. A careless player may lose a party member
  in a boss fight but won't wipe.

### 6.2 Act II — Expanding

- **Enemies:** Wider variety, status effects introduced (Poison,
  Silence, Blind). Some enemies resist physical attacks.
- **Bosses:** 2 phases, require specific strategies (e.g., Forge
  Warden's heat shield requires magic to bypass).
- **Resources:** Comfortable. Equipment costs rise but gold income
  keeps pace (~91% affordability).
- **Party:** Splits during Act II create resource pressure —
  different party compositions force different strategies.
- **Player learns:** Status management, party composition strategy,
  MP conservation.
- **Threat level:** Moderate. Unprepared players may wipe on bosses.

### 6.3 Interlude — Pressure

- **Enemies:** Pallor Infection mechanic adds new danger. Stronger
  variants of familiar enemies. Compact/Valdris civil war enemies.
- **Bosses:** Complex multi-phase fights. General Vassar Kole (30,000 HP)
  is the difficulty spike. Requires full party coordination and
  mastery of each reunited member's abilities (Cael is no longer
  available — his absence is felt mechanically).
- **Resources:** Tighter. War-torn economy means some shops have
  limited stock. Equipment comes from exploration, not purchase.
- **Party rebuilding:** Sable alone → gradually finding party
  members. Solo Sable section teaches Tricks/steal mechanics.
- **Player learns:** Advanced mechanics, Ley Crystal optimization,
  party synergies, Pallor management.
- **Threat level:** High for unprepared. Moderate for engaged players.

### 6.4 Act III — The Gauntlet

- **Enemies:** Pallor-warped variants. Despair status is common.
  High encounter rate in Pallor Wastes (~10 steps between fights).
- **Bosses:** Full mechanical complexity. The Grey Keeper (Oasis C)
  teaches Despair management. Cael final fight is the culmination.
- **Resources:** Limited Oases provide rest/shops. Once inside the
  Convergence gauntlet, no shops or rest. The player must prepare
  beforehand.
- **Player knows:** Everything. Act III tests mastery, not teaching.
- **Threat level:** The highest in the main story. The Pallor Wastes
  encounter rate and Despair status create sustained pressure. Boss
  fights require all learned skills.

### 6.5 Post-Game — Optional Challenge

- **Dreamer's Fault:** 20-floor optional dungeon, levels 42–100.
  Enemies far exceed main story difficulty. Unique mechanics per
  "age" (5 floors each). This is the "hard mode" for completionists.
- **Superbosses:** Optional encounters harder than the final boss.
  Rewards are cosmetic/bragging rights (per Gap 3.6 when designed).
- **No difficulty toggle needed.** Players who want challenge seek
  it through optional content. The main story remains accessible.

---

## 7. Balance Validation Methodology

### 7.1 Damage Sanity Checks

For any new enemy or boss, verify these formulas produce values
within the expected ranges:

**Physical damage dealt to enemy:**
```
damage = max(1, (party_ATK² / 6) - enemy_DEF)
```

**Physical damage received from enemy:**
```
damage = max(1, (enemy_ATK² / 6) - party_DEF)
```

**Magic damage dealt:**
```
damage = max(1, (party_MAG × spell_power / 4) - enemy_MDEF)
```

**Healing output:**
```
heal = party_MAG × spell_power × 0.8
```

### 7.2 Boss Duration Check

For any boss, estimate fight duration:

```
actions_per_second = party_size / avg_action_interval
damage_per_second = actions_per_second × avg_party_damage × damage_action_ratio
duration_base = total_boss_HP / damage_per_second
duration_final = (duration_base × healing_overhead_mult) + phase_transitions
```

Where (ATB system has no discrete rounds — each party member acts
independently when their gauge fills):
- `avg_action_interval` = average seconds between one party member's
  actions at Battle Speed 3 (~2.5s at level 1, ~1.0s at level 70)
- `damage_action_ratio` = fraction of party actions that deal damage
  (typically 0.55–0.65, lower for harder bosses requiring more healing)
- `phase_transitions` = total seconds of scripted events/invulnerability
  (typically 15–45s per transition × number of transitions)
- `healing_overhead_mult` = multiplier for non-damage time (typically
  1.5–2.0×, accounting for healing, rebuffing, Despair management)

If `duration_final` falls outside the target range for that boss
type, adjust boss HP until it does.

### 7.3 Economy Verification

For each new town/act transition:

1. **Calculate expected player gold** at arrival (enemy drops +
   treasure chests + quest rewards to that point).
2. **Sum available equipment cost** at the new shop.
3. **Verify ~70% affordability:** player can equip ~70% of the
   party with new gear without grinding.
4. **Verify consumable budget:** enough gold left for dungeon
   supplies after equipment.

### 7.4 Encounter Rate Sanity Check

For each dungeon, verify:
- Average encounters per floor at the terrain's danger increment
- Total encounters across the dungeon (should match MP sustainability
  targets from Section 3.2)
- Rare formation (6.25% weight) enemy stats don't wildly exceed
  the floor's expected difficulty

---

## 8. Cross-References

| System | Reference |
|--------|-----------|
| Damage formulas | [combat-formulas.md](../../story/combat-formulas.md) § Physical Damage, § Magic Damage |
| Stat growth | [progression.md](../../story/progression.md) § Character Growth |
| XP curve | [progression.md](../../story/progression.md) § Two-Phase XP Curve |
| Enemy stats | [bestiary/](../../story/bestiary/) (act-i.md through act-iii.md) |
| Boss stats | [bestiary/bosses.md](../../story/bestiary/bosses.md) |
| Equipment tiers | [equipment.md](../../story/equipment.md) § Weapons |
| Economy/gold | [economy.md](../../story/economy.md) § Gold Pacing Targets |
| Encounter rates | [combat-formulas.md](../../story/combat-formulas.md) § Encounter System |
| ATB timing | [combat-formulas.md](../../story/combat-formulas.md) § ATB Gauge System |
| Party-wipe rules | [events.md](../../story/events.md) § Faint and Fast Reload |
| Flee mechanics | [combat-formulas.md](../../story/combat-formulas.md) § Flee |
| Oasis services | [locations.md](../../story/locations.md) § Pallor Wastes Oases |
| Dreamer's Fault | [bestiary/optional.md](../../story/bestiary/optional.md) |
