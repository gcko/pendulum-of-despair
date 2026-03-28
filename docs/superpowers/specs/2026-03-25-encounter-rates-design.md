# Encounter Rates & Weighted Tables Design

> Spec for Gap 2.4. Defines the random encounter system: danger counter
> model, per-terrain encounter rates, formation types and rates, 4-pack
> encounter group tables, flee mechanics, boss triggers, and encounter
> rate modifier items.

---

## 1. Core Model: Danger Counter

The game uses a **danger counter** system (FF6 model) for random
encounters. A hidden counter increments with each step the player takes.
Each step, the game rolls `random_int(0, 255)` — if the result is less than
`floor(counter / 256)`, a random battle triggers. The counter resets to
0 after each battle.

This produces natural variance: sometimes encounters come quickly,
sometimes the player gets a long stretch. The average steps between
encounters is determined by the area's increment value.

**Why this model:** Proven in FF6, elegant, and the increment value is
the single tuning knob per area. Items that modify the increment slot in
cleanly (halve it, double it, zero it).

---

## 2. Encounter Rates by Terrain

geography.md already defines an encounter rate table with per-terrain
fractions (Section 5.5, "Encounter Zones"). This spec formalizes those
values into danger counter increments and adds act scaling.

### Base Increment Table

Each terrain type has a base danger counter increment. These are tuned
via Monte Carlo simulation to match the target average steps.

| Zone Type | Target Avg Steps | Increment | Simulated Avg | Examples |
|-----------|-----------------|-----------|---------------|---------|
| Sacred sites | None | 0 | — | Ashgrove, Stillwater Hollow, save points |
| Urban interior | None | 0 | — | Inside city/town boundaries |
| Boss corridors | None | 0 | — | Antechamber before boss rooms |
| Farmland / Settled | ~48 | 48 | ~48.5 | Aelhart Valley, Compact urban outskirts |
| Coastal | ~40 | 64 | ~40.3 | Bellhaven shoreline, Ashport coast, Sundering Sea cliffs |
| Roads | ~32 | 96 | ~32.2 | Valdris Highroad, Compact rail routes |
| Forest (light) | ~24 | 148 | ~24.1 | Valdris border woods, Wilds edges |
| Quarried plains | ~24 | 148 | ~24.1 | Compact industrial hinterland |
| Mountains | ~20 | 252 | ~20.7 | Frostcap foothills, Broken Hills |
| Standard dungeons | ~30 | 120 | ~30.1 | Most dungeon floors |
| Forest (dense) | ~16 | 380 | ~16.2 | Deep Thornmere, ley-line corridors |
| Marshland | ~16 | 380 | ~16.2 | Duskfen system |
| Deep dungeon floors | ~20 | 252 | ~20.7 | Final floors of multi-floor dungeons |
| Pallor Wastes | ~10 | 700 | ~10.3 | 10-mile radius around Convergence |
| Ley Scar | ~14 | 506 | ~14.3 | Optional Act III grinding zone |
| Dreamer's Fault (deep) | ~14 | 506 | ~14.3 | Floors 11–20 |

**Note:** FF6 used increment 192 for normal dungeons, averaging ~23
steps. Our standard dungeon increment of 120 averages ~30 steps —
intentionally more generous to give players time to explore dungeon
layouts, read lore objects, and appreciate ASCII map details.

### Act Scaling

Per geography.md (line 543), encounter rates escalate as the story
progresses:

| Period | Scaling | Effect on Increment |
|--------|---------|---------------------|
| Act I | Base (×1.0) | No modification |
| Act II | +10% (×1.1) | `floor(base_increment × 1.1)` |
| Interlude | +20% (×1.2) | `floor(base_increment × 1.2)` — wild magic and Pallor manifestations |
| Act III | +10% (×1.1) | `floor(base_increment × 1.1)` — world is more dangerous but stabilized vs Interlude |

Act scaling applies to the base increment before any item modifiers.
The formula is: `floor(base_increment × act_scale × accessory_mod ×
location_mod)`.

### Tier Shorthand

For convenience in dungeon documentation, the following tier labels
map to specific increments:

| Tier | Name | Increment | Avg Steps | Use Case |
|------|------|-----------|-----------|----------|
| 0 | Safe | 0 | None | Towns, Oases, boss corridors |
| 1 | Low | 48–96 | ~48–32 | Farmland, roads |
| 2 | Normal | 120–148 | ~30–24 | Standard dungeons, light forest |
| 3 | High | 252–380 | ~20–16 | Deep floors, dense forest, marsh |
| 4 | Intense | 506–700 | ~14–10 | Ley Scar, Pallor Wastes, Dreamer's Fault deep |

Dungeon documentation can assign tiers per floor (e.g., "Tier 2" for
upper floors, "Tier 3" for deep floors) or specify exact increments
for fine-grained control.

---

## 3. Encounter Rate Modifiers

### Accessories

| Item | Effect | Cost | Availability |
|------|--------|------|--------------|
| Ward Talisman | Halves danger counter increment (×0.5) | 1,500 | Act II shops (Bellhaven, Corrund) |
| Lure Talisman | Doubles danger counter increment (×2.0) | 800 | Act II shops (Corrund, Ironmark) |
| Infiltrator's Cloak | Reduces encounter rate (×0.5) | — | Axis Tower F2 treasure chest |

Both Talismans occupy the accessory slot, creating a meaningful
tradeoff: the player gives up a stat boost or status immunity to
modify encounter frequency.

- **Ward Talisman** is for players who want to explore with fewer
  interruptions or who have outleveled an area. Priced higher (1,500g)
  because it's a defensive comfort item.
- **Lure Talisman** is for players who want to grind — pairs naturally
  with the Ley Scar zone. Priced lower (800g) to encourage its use.
- **Infiltrator's Cloak** is already referenced in dungeons-world.md
  (Axis Tower F2 treasure) as an encounter-reducing accessory.
  It functions identically to the Ward Talisman but is acquired as
  loot rather than purchased — an earlier, free alternative for
  players who explore thoroughly.

**Ward Talisman vs Infiltrator's Cloak:** Both provide ×0.5 encounter
rate. The Ward Talisman is buyable; the Infiltrator's Cloak is a
one-time find. They do NOT stack with each other (same effect, same
slot). The Infiltrator's Cloak rewards exploration in Act I; the Ward
Talisman ensures the effect is available to all players by Act II.

**Repel equivalent (deferred from Gap 1.4):** The Ward Talisman and
Infiltrator's Cloak serve as the game's Repel equivalents. Unlike a
consumable Repel, these are permanent accessories with an opportunity
cost (accessory slot). This is a deliberate design choice — encounter
reduction should be a meaningful tradeoff, not a cheap consumable that
trivializes exploration.

### Location-Specific Modifiers

| Item | Effect | Scope |
|------|--------|-------|
| Tunnel Map | ×0.5 encounter rate | Bellhaven Tunnels, Corrund Sewers |
| Kole's patrol timing | ×0.5 encounter rate | Caldera Inner Ring only |

These stack with accessory modifiers.

### Stacking Rules

Modifiers stack **multiplicatively** in this order:

```
final_increment = floor(base_increment × act_scale × accessory_mod × location_mod)
```

Examples:
- Ward Talisman in Bellhaven Tunnels with Tunnel Map:
  `floor(120 × 1.0 × 0.5 × 0.5)` = 30 → avg ~75+ steps
- Lure Talisman in Ley Scar (Act III):
  `floor(506 × 1.1 × 2.0 × 1.0)` = 1113 → very frequent encounters
- If the final increment is 0, no random encounters occur.

---

## 4. Battle Formation Types

Three formation types determine party/enemy positioning at battle start.

### Normal
- Standard layout: party on left, enemies on right.
- Party rows as assigned (front/back per character default or player
  swap).
- Most common formation.

### Back Attack
- Enemies ambush the party.
- Party rows are **reversed**: characters in back row are exposed to
  front-row damage, and vice versa. This lasts for the first round
  only — the player can swap rows on their first turn.
- Enemies start with a partial ATB fill advantage (50% of gauge).
- Row reversal is the key penalty: mages (Maren, Torren) who normally
  sit safely in back row suddenly take full physical damage.

### Preemptive Strike
- Party ambushes the enemies.
- All party members start with **full ATB gauges**.
- All enemies start with **empty ATB gauges**.
- The party gets a free round of actions before enemies can respond.

### Formation Type Rules
- **Bosses** always use Normal formation. Preemptive and back attack
  are disabled for boss encounters.
- **Scripted encounters** (story events, fixed encounters) always use
  Normal unless the narrative specifies otherwise (e.g., an ambush
  scene could force a back attack for dramatic effect).
- Back attacks and preemptive strikes are **mutually exclusive** — an
  encounter is one or the other, never both.

---

## 5. Formation Rates by Terrain

The chance of each formation type varies by terrain, reflecting how
dangerous and unpredictable the environment is.

| Terrain Category | Normal | Back Attack | Preemptive |
|------------------|--------|-------------|------------|
| Roads / safe paths | 87.5% | 0% | 12.5% |
| Open terrain (grassland, desert, highland) | 75% | 12.5% | 12.5% |
| Low-visibility (forest, caves, tunnels) | 68.75% | 18.75% | 12.5% |
| Pallor Wastes | 62.5% | 25% | 12.5% |

All values are multiples of 1/16 (6.25%) for clean integer math.

### Formation Rate Resolution

When a random encounter triggers:
1. Roll `random_int(0, 255)`.
2. Compare against terrain formation table thresholds.
3. Apply Preemptive Charm modifier if equipped.

Example thresholds for open terrain (grassland):
- 0–31: Preemptive (12.5%)
- 32–63: Back Attack (12.5%)
- 64–255: Normal (75%)

### Preemptive Charm Interaction

The **Preemptive Charm** accessory (already defined in equipment.md at
+25% preemptive strike rate, 2,000g, Bellhaven quest) adds 25
percentage points to preemptive chance. The added percentage is
subtracted from back attack chance first; if back attack is already
reduced to 0%, the remainder is subtracted from normal.

This produces a uniform result across all terrains:

| Terrain + Preemptive Charm | Normal | Back Attack | Preemptive |
|----------------------------|--------|-------------|------------|
| Roads | 62.5% | 0% | 37.5% |
| Open terrain | 62.5% | 0% | 37.5% |
| Low-visibility | 62.5% | 0% | 37.5% |
| Pallor Wastes | 62.5% | 0% | 37.5% |

The Charm normalizes all terrains to the same 62.5/0/37.5 split. This
is a strong defensive accessory in dangerous terrain (Pallor Wastes
back attack goes from 25% to 0%) and a moderate offensive boost
everywhere.

### Sable's Coin

**Sable's Coin** (already defined in items.md) guarantees a preemptive
strike on the next battle. It overrides the formation roll entirely —
the next encounter is always preemptive regardless of terrain or
formation table. The coin is consumed on use. It does not affect boss
encounters (bosses always use normal formation).

---

## 6. Encounter Group Tables (4-Pack System)

Each area defines **4 possible enemy formations** (a "4-pack"). When a
random encounter triggers, the game selects which formation to use.

### Formation Selection Weights

| Slot | Weight | Range (0–255) | Role |
|------|--------|---------------|------|
| Formation 1 | 31.25% | 0–79 | Common |
| Formation 2 | 31.25% | 80–159 | Common |
| Formation 3 | 31.25% | 160–239 | Common |
| Formation 4 | 6.25% | 240–255 | Rare |

Roll `random_int(0, 255)` and compare to the ranges above.

### Ley Scar Exception

The Ley Scar uses a modified 4-pack where Formation 4 is the Ley
Abomination (a rare mini-boss). The bestiary and dungeons-world.md
define this as a ~10% encounter rate. To match, the Ley Scar uses a
custom weight table:

| Slot | Weight | Range (0–255) | Enemy |
|------|--------|---------------|-------|
| Formation 1 | 30% | 0–76 | 2× Ley-Warped Drake |
| Formation 2 | 30% | 77–153 | 2× Ley-Warped Wraith + 1× Ley-Warped Colossus |
| Formation 3 | 30% | 154–229 | 1× Ley-Warped Colossus + 2× Ley-Warped Drake |
| Formation 4 | 10% | 230–255 | 1× Ley Abomination (rare mini-boss) |

Other areas that need custom weights for narrative reasons may override
the standard 4-pack distribution, but the standard weights should be
used by default.

### Formation Design Guidelines

- **Formations 1–3 (common):** Standard enemy groups drawn from the
  area's enemy pool. Vary composition to create tactical variety:
  - One formation might be 3× of a single enemy type (straightforward)
  - Another might mix melee + ranged enemies (requires different tactics)
  - Another might include a support enemy that buffs/heals others
- **Formation 4 (rare):** The special encounter. Uses include:
  - A tougher enemy group with higher XP/gold rewards
  - An unusual enemy not found in the other 3 formations
  - A mini-boss patrol (single strong enemy or elite + escorts)
  - An enemy that drops a rare steal/item
- **Enemy count per formation:** 1–6 enemies (typically 2–4). Solo
  enemies should be stronger; groups of 5–6 should be individually
  weaker.
- **Level range:** All enemies in an area's 4-pack should be within
  the dungeon's recommended level range (per bestiary).

### Authoring Scope

Encounter tables need to be defined for:
- Each overworld terrain zone (per act — enemy pools shift by act)
- Each dungeon floor (dungeons-world.md, dungeons-city.md)
- Ley Scar (custom 4-pack defined above)
- Dreamer's Fault (per floor tier in optional.md)

The actual per-area formation tables will be added to
dungeons-world.md and dungeons-city.md as part of the implementation
plan. This spec defines the system; the tables are the content.

---

## 7. Flee Mechanics

### Standard Flee

When the player selects Flee during battle, a single roll determines
success for the entire party:

```
flee_chance = clamp(50 + (party_avg_SPD - enemy_avg_SPD) × 2, 10, 90)
```

- `party_avg_SPD`: average SPD of all living, non-status-impaired party
  members
- `enemy_avg_SPD`: average SPD of all living enemies in the encounter
- **Success:** Battle ends immediately. No rewards (gold, XP, items).
- **Failure:** The character who attempted to flee loses their turn.
  Other party members are unaffected. The player can retry on the next
  character's turn.
- **Cap:** 90% maximum, 10% minimum. Even the fastest party has a
  small chance of failure; even the slowest party has a chance to escape.

### SPD Relevance

Sable has the highest SPD in the party (18 base, fastest growth). With
her in the active party, the average SPD skews higher, making flee more
reliable. This gives SPD a meaningful non-combat use and makes Sable
valuable even in parties that don't need her Steal abilities.

### Guaranteed Escape

| Method | Effect | Cost | Restriction |
|--------|--------|------|-------------|
| Smoke Bomb | 100% flee, ends battle | 100g (consumable) | Non-boss only |
| Smokeveil (Sable) | 100% flee, ends battle | 4 MP | Non-boss only |

Both work instantly — no roll required. Neither works on boss encounters.

### Boss Encounters

Flee is **completely disabled** in boss battles. The Flee command is
greyed out. Smoke Bomb and Smokeveil also fail against bosses (Smoke
Bomb is not consumed; Smokeveil costs MP but displays "Can't escape!").

---

## 8. Boss Trigger Types

All boss encounters are authored — no random boss spawns. Four trigger
categories cover all existing boss encounters in the game:

| Type | Description | Trigger Condition |
|------|-------------|-------------------|
| Zone | Step into a marked tile/area | Player crosses a tile boundary |
| Interact | Examine an object or talk to an NPC | Player presses interact button |
| Cutscene | Story event transitions to battle | Automatic during event sequence |
| HP Threshold | Environmental condition reaches critical | Dungeon variable crosses threshold |

### Examples from Existing Dungeons

| Boss | Dungeon | Trigger Type |
|------|---------|-------------|
| Fenmother | Fenmother's Hollow | Zone (enter chamber) |
| Ashen Ram | Valdris Siege | Cutscene (siege sequence) |
| Ley Colossus | Ley Line Depths F3 | Zone (enter arena) |
| Forge Warden | Ashmark Factory | Zone (enter control room) |
| Axis Tower bosses | Axis Tower | Cutscene (corruption events) |
| Dreamer's Fault bosses | Dreamer's Fault | Zone (every 4th floor) |

### Safe Corridor Rule

The area immediately before a boss encounter is set to **Tier 0
(Safe)** — no random encounters. This prevents the frustrating scenario
of being ambushed and weakened right before a boss fight. The safe zone
is typically the final corridor, antechamber, or save point room
leading to the boss area.

This is a quality-of-life design choice. The player should enter a boss
fight at the strength they chose (healed up, buffs applied), not
randomly weakened by a back attack 3 steps from the boss door.

---

## 9. Interaction with Existing Systems

### Row System (Gap 2.5)

- **Normal formation:** Rows as assigned per character defaults or
  player swaps.
- **Back Attack:** Rows reversed. Back-row characters (Torren, Maren)
  take front-row physical damage until the player swaps them back. This
  is the primary penalty of back attacks and creates tension: do you
  spend your first turn fixing rows or attacking?
- **Preemptive Strike:** Rows as assigned. Full ATB advantage.

### Economy (Gap 1.6)

- Smoke Bombs (100g) are a gold sink — players who want guaranteed
  escapes pay for it.
- Ward Talisman (1,500g) and Lure Talisman (800g) are new gold sinks.
- Encounter frequency directly affects gold/XP income pacing. The
  increment values are calibrated to the wealth curve in economy.md.

### XP Curve (Gap 2.1)

- Encounter rates affect XP pacing per act. The progression.md XP
  Pacing Targets assume standard dungeon rate (~30 steps) for play.
- Lure Talisman + Ley Scar (Intense tier doubled) enables
  power-leveling for players who want it.
- 50% absent XP share means even reserve party members benefit from
  high encounter rates.

### Items (Gap 1.4)

- Smoke Bomb and Sable's Coin already defined in items.md with
  correct effects and prices.
- Ward Talisman and Lure Talisman are new accessories (equipment.md).
- The Ward Talisman / Infiltrator's Cloak fulfill the "Repel
  equivalent" deferred from Gap 1.4 (items.md line 165).

### Equipment (Gap 1.5)

- Preemptive Charm already defined in equipment.md (+25% preemptive
  rate, 2,000g, Bellhaven quest).
- Infiltrator's Cloak already referenced in dungeons-world.md (Axis
  Tower F2 treasure) and now added to equipment.md.
- Ward Talisman and Lure Talisman to be added as new accessories.

### Bestiary (Gap 1.3)

- Enemy SPD values in bestiary stat tables are used for flee chance
  calculation (`enemy_avg_SPD`).
- Enemy locations in bestiary determine which enemies populate each
  area's 4-pack formation table.

### Geography (geography.md)

- geography.md Section 5.5 "Encounter Zones" defines base terrain
  rates as fractions (e.g., "1/48 steps" for farmland). This spec's
  increment values are calibrated to match those target averages. The
  implementation plan will update geography.md to reference this spec
  for the formalized system.
- Act scaling (geography.md line 543) is incorporated directly into
  this spec (Section 2, "Act Scaling").

---

## 10. Cross-References

| Document | Relationship |
|----------|-------------|
| `docs/story/combat-formulas.md` | **Update needed:** add Encounter System section (danger counter, formation types/rates, flee formula) |
| `docs/story/equipment.md` | **Update needed:** add Ward Talisman, Lure Talisman, and Infiltrator's Cloak accessories |
| `docs/story/dungeons-world.md` | **Update needed:** add encounter rate tier + 4-pack formation table per dungeon floor |
| `docs/story/dungeons-city.md` | **Update needed:** add encounter rate tier + 4-pack formation table per dungeon floor |
| `docs/story/geography.md` | **Update needed:** replace fractional encounter rates with reference to formalized danger counter system |
| `docs/story/items.md` | Already defines Smoke Bomb and Sable's Coin. **Update needed:** mark "Repel equivalent" as resolved (Ward Talisman / Infiltrator's Cloak) |
| `docs/story/bestiary/README.md` | Already has enemy locations. No changes needed. |
| `docs/analysis/game-design-gaps.md` | Gap 2.4 status → COMPLETE |

---

## 11. Files Created/Modified

| Action | File | Changes |
|--------|------|---------|
| Modify | `docs/story/combat-formulas.md` | Add Encounter System section: danger counter model, formation types/rates, flee formula |
| Modify | `docs/story/equipment.md` | Add Ward Talisman, Lure Talisman, Infiltrator's Cloak |
| Modify | `docs/story/dungeons-world.md` | Add encounter rate tier per area + 4-pack formation tables per dungeon floor |
| Modify | `docs/story/dungeons-city.md` | Add encounter rate tier per area + 4-pack formation tables per dungeon floor |
| Modify | `docs/story/geography.md` | Update encounter zones to reference formalized danger counter system |
| Modify | `docs/story/items.md` | Mark Repel equivalent as resolved |
| Modify | `docs/analysis/game-design-gaps.md` | Gap 2.4 status → COMPLETE |
