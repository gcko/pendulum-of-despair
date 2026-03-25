# Encounter Rates & Weighted Tables Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Formalize the encounter rate system by adding the danger counter model, formation types/rates, flee formula, and encounter rate modifier accessories to the story docs, then add 4-pack formation tables and encounter tier assignments to all dungeons.

**Architecture:** Updates to 6 existing story docs + gap tracker. The encounter system spec defines the formulas; this plan implements them in the canonical docs. The largest tasks are the formation tables for dungeons-world.md (~20 dungeons) and dungeons-city.md (~7 dungeon areas). No new story docs or code files.

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-25-encounter-rates-design.md`

---

## Chunk 1: Core System Docs

### Task 1: Add Encounter System to combat-formulas.md

**Files:**
- Modify: `docs/story/combat-formulas.md` (insert before `## Integration Notes` at line 592)

**Context:** combat-formulas.md is the canonical reference for all battle mechanics. The encounter system (danger counter, formation types, formation rates, flee formula) belongs here as a new top-level section, placed before the existing Integration Notes section.

- [ ] **Step 1: Read the Integration Notes section**

Read `docs/story/combat-formulas.md` lines 588-603 to understand where to insert and what's currently in Integration Notes.

- [ ] **Step 2: Insert Encounter System section**

Insert a new `## Encounter System` section before `## Integration Notes`. Content:

```markdown
## Encounter System

### Danger Counter

Random encounters use a danger counter model (FF6-derived). A hidden
counter starts at 0 and increments by an area-defined value each step.
Each step, the game rolls `random(0, 255)` — if the result is less than
`floor(counter / 256)`, a battle triggers. The counter resets to 0
after each battle.

Each terrain/area has a base increment that determines average steps
between encounters:

| Zone Type | Increment | Avg Steps |
|-----------|-----------|-----------|
| Sacred sites / Urban / Boss corridors | 0 | None |
| Farmland / Settled | 48 | ~48 |
| Roads | 96 | ~32 |
| Forest (light) / Quarried plains | 148 | ~24 |
| Standard dungeons | 120 | ~30 |
| Mountains / Deep dungeon floors | 252 | ~20 |
| Forest (dense) / Marshland | 380 | ~16 |
| Ley Scar / Dreamer's Fault (deep) | 506 | ~14 |
| Pallor Wastes | 700 | ~10 |

See [geography.md](geography.md) for terrain zone definitions and
examples.

**Act scaling:** The base increment scales with story progression:

| Period | Multiplier |
|--------|------------|
| Act I | ×1.0 |
| Act II | ×1.1 |
| Interlude | ×1.2 |
| Act III | ×1.1 |

**Final increment formula:**

```
final_increment = floor(base_increment × act_scale × accessory_mod × location_mod)
```

**Encounter rate modifiers:**

| Source | Modifier | Scope |
|--------|----------|-------|
| Ward Talisman (accessory) | ×0.5 | All areas |
| Infiltrator's Cloak (accessory) | ×0.5 | All areas |
| Lure Talisman (accessory) | ×2.0 | All areas |
| Tunnel Map (key item) | ×0.5 | Bellhaven Tunnels only |
| Kole's patrol timing (quest) | ×0.5 | Caldera Inner Ring only |

Modifiers stack multiplicatively. Ward Talisman and Infiltrator's Cloak
provide the same effect (×0.5) and do not stack with each other (same
accessory slot).

### Battle Formations

Three formation types determine battle start conditions:

| Formation | Party Effect | Enemy Effect | Frequency |
|-----------|-------------|--------------|-----------|
| Normal | Rows as assigned | Standard ATB start | Most common |
| Back Attack | Rows reversed for 1st round; enemies get 50% ATB fill | Advantage | Terrain-dependent |
| Preemptive | Full ATB gauges | Empty ATB gauges | 12.5% base |

Back attacks and preemptive strikes are mutually exclusive. Bosses and
scripted encounters always use Normal formation.

**Formation rates by terrain:**

| Terrain | Normal | Back Attack | Preemptive |
|---------|--------|-------------|------------|
| Roads / safe paths | 87.5% | 0% | 12.5% |
| Open (grassland, desert, highland) | 75% | 12.5% | 12.5% |
| Low-visibility (forest, caves, tunnels) | 68.75% | 18.75% | 12.5% |
| Pallor Wastes | 62.5% | 25% | 12.5% |

**Preemptive Charm interaction:** +25 percentage points to preemptive,
deducted from back attack first then normal. Normalizes all terrains to
62.5% Normal / 0% Back Attack / 37.5% Preemptive.

**Sable's Coin:** Guarantees preemptive on next battle (overrides roll).
Does not work on bosses.

### Encounter Group Selection (4-Pack)

Each area defines 4 possible enemy formations:

| Slot | Weight | Range (0–255) |
|------|--------|---------------|
| Formation 1 | 31.25% | 0–79 |
| Formation 2 | 31.25% | 80–159 |
| Formation 3 | 31.25% | 160–239 |
| Formation 4 (rare) | 6.25% | 240–255 |

Areas may override these weights for narrative reasons (e.g., Ley Scar
uses 30/30/30/10 to give the Ley Abomination a 10% spawn rate). See
individual dungeon encounter tables in [dungeons-world.md](dungeons-world.md)
and [dungeons-city.md](dungeons-city.md).

### Flee

Single roll for the entire party:

```
flee_chance = clamp(50 + (party_avg_SPD - enemy_avg_SPD) × 2, 10, 90)
```

- Success: battle ends, no rewards.
- Failure: acting character loses their turn.
- Bosses: flee disabled entirely.
- Smoke Bomb (100g consumable): 100% flee, non-boss only.
- Smokeveil (Sable, 4 MP): 100% flee, non-boss only.

### Boss Encounter Rules

All boss encounters are authored — no random boss spawns. Four trigger
types:

| Type | Trigger Condition |
|------|-------------------|
| Zone | Player steps into a marked tile/area |
| Interact | Player examines an object or talks to an NPC |
| Cutscene | Story event auto-transitions to battle |
| HP Threshold | Dungeon environmental variable crosses threshold |

Bosses always use Normal formation (preemptive and back attack
disabled). Flee is disabled in boss battles.

**Safe Corridor Rule:** The area immediately before a boss encounter
uses Tier 0 (Safe) — no random encounters. This prevents being
weakened by a random back attack right before a boss fight.
```

- [ ] **Step 3: Update Integration Notes**

Add a bullet to the Integration Notes section referencing the new Encounter System:

```markdown
- **Encounter System → Row System:** Back attacks reverse party rows
  for the first round. Preemptive strikes use normal row assignments.
- **Encounter System → ATB:** Preemptive fills all party ATB gauges.
  Back attacks give enemies 50% ATB fill.
```

- [ ] **Step 4: Verify no contradictions**

Re-read the full ATB Gauge System section (line 477+) and Row Modifier section (line 57+) to ensure the new encounter content is consistent. Check that "50% ATB fill" for back attacks makes sense with the ATB gauge max of 16,000.

- [ ] **Step 5: Commit**

```bash
git add docs/story/combat-formulas.md
```
Message: `docs(shared): add encounter system to combat-formulas.md`

---

### Task 2: Add Encounter Accessories to equipment.md

**Files:**
- Modify: `docs/story/equipment.md` (Combat Mechanic Accessories section, ~line 486)

**Context:** equipment.md already has a "Combat Mechanic Accessories" subsection (line 486) containing the Preemptive Charm. The Ward Talisman and Lure Talisman belong here as encounter rate modifiers. The Infiltrator's Cloak is already referenced in dungeons-world.md as a treasure item but has no entry in equipment.md — it needs to be added.

- [ ] **Step 1: Read the Combat Mechanic Accessories table**

Read `docs/story/equipment.md` lines 486-498 to see the current table format and entries.

- [ ] **Step 2: Add Ward Talisman, Lure Talisman, and Infiltrator's Cloak**

Add three new rows to the Combat Mechanic Accessories table (after the existing entries, before the table ends):

```markdown
| Ward Talisman | Halves encounter rate (danger counter ×0.5) | 1,500 | II | Bellhaven, Corrund shops |
| Lure Talisman | Doubles encounter rate (danger counter ×2.0) | 800 | II | Corrund, Ironmark shops |
| Infiltrator's Cloak | Halves encounter rate (danger counter ×0.5) | — | I | Axis Tower F2 treasure |
```

**Design note:** Ward Talisman and Infiltrator's Cloak have the same effect (×0.5). The Cloak is an early, free version found via exploration; the Talisman is buyable in Act II for players who missed the Cloak or want one for a second party member in a future playthrough. They occupy the same accessory slot, so they cannot stack.

- [ ] **Step 3: Update the Accessory Summary table**

Read the Accessory Summary subsection (line 522) and add the three new accessories to the summary count. Update the total count.

- [ ] **Step 4: Add cross-reference note**

Add a note below the Combat Mechanic Accessories table:

```markdown
> **Encounter rate accessories:** See [combat-formulas.md](combat-formulas.md)
> (Encounter System section) for the danger counter model, stacking
> rules, and interaction with location-specific modifiers (Tunnel Map,
> Kole's patrol timing).
```

- [ ] **Step 5: Commit**

```bash
git add docs/story/equipment.md
```
Message: `docs(shared): add Ward Talisman, Lure Talisman, and Infiltrator's Cloak to equipment.md`

---

### Task 3: Update geography.md Encounter Zones

**Files:**
- Modify: `docs/story/geography.md` (lines 524-543, "### Encounter Zones" section)

**Context:** geography.md already has an Encounter Zones table with fractional rates (e.g., "1/48 steps" for farmland) and act scaling text. This needs to be updated to reference the formalized danger counter system in combat-formulas.md while preserving the existing terrain descriptions and act scaling.

- [ ] **Step 1: Read the Encounter Zones section**

Read `docs/story/geography.md` lines 524-545 to see the current content.

- [ ] **Step 2: Replace the Encounter Zones table**

Replace the table at lines 528-539 with an updated version that includes danger counter increments alongside the existing descriptive rates:

```markdown
| Zone Type | Encounter Rate | Danger Counter Increment | Avg Steps | Examples |
|-----------|---------------|--------------------------|-----------|----------|
| **Roads** | Low | 96 | ~32 | Valdris Highroad, Compact rail routes |
| **Farmland / Settled** | Very low | 48 | ~48 | Aelhart Valley, Compact urban outskirts |
| **Forest (light)** | Moderate | 148 | ~24 | Valdris border woods, Wilds edges |
| **Forest (dense)** | High | 380 | ~16 | Deep Thornmere, ley-line corridors |
| **Marshland** | High | 380 | ~16 | Duskfen system |
| **Mountains** | Moderate | 252 | ~20 | Frostcap foothills, Broken Hills |
| **Quarried plains** | Moderate | 148 | ~24 | Compact industrial hinterland |
| **Sacred sites** | None | 0 | — | Ashgrove, Stillwater Hollow, save points |
| **Pallor Wastes (Act III)** | Very high | 700 | ~10 | 10-mile radius around Convergence |
| **Urban interior** | None | 0 | — | Inside city/town boundaries |
```

- [ ] **Step 3: Update the act scaling paragraph**

Replace the act scaling text at line 543 with:

```markdown
**Act scaling:** Encounter rate increases per act transition:
Act I ×1.0, Act II ×1.1, Interlude ×1.2, Act III ×1.1. The multiplier
applies to the base danger counter increment before item modifiers.
See [combat-formulas.md](combat-formulas.md) (Encounter System section)
for the full formula and modifier stacking rules.
```

- [ ] **Step 4: Add formation rate reference**

Add after the act scaling paragraph:

```markdown
**Battle formations:** Terrain affects ambush risk. Back attack chance
ranges from 0% (roads) to 25% (Pallor Wastes). Low-visibility terrain
(forests, caves) has elevated back attack rates (18.75%). See
[combat-formulas.md](combat-formulas.md) for full formation rate tables.
```

- [ ] **Step 5: Verify consistency**

Re-read the terrain descriptions earlier in geography.md (lines 147-148, 251) to ensure they're consistent with the updated rates. The text "Lowest encounter rate in the game" for farmland should still hold (48 avg steps is the highest non-zero value).

- [ ] **Step 6: Commit**

```bash
git add docs/story/geography.md
```
Message: `docs(shared): formalize encounter zones with danger counter increments in geography.md`

---

### Task 4: Update items.md and gap tracker (1.4 Repel deferral)

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (line 165, Gap 1.4 checklist)

**Context:** Gap 1.4 (Items) has a deferred checklist item at line 165: "Encounter rate items (Repel equivalent) — deferred to Gap 2.4 (Encounter Rates)". Now that Gap 2.4 defines the Ward Talisman and Infiltrator's Cloak as the Repel equivalent (accessories, not consumables), this deferral should be marked resolved.

- [ ] **Step 1: Read the Gap 1.4 checklist item**

Read `docs/analysis/game-design-gaps.md` lines 163-170 to find the deferred Repel item.

- [ ] **Step 2: Mark the Repel deferral as resolved**

Change line 165 from:
```
  - [ ] Encounter rate items (Repel equivalent) — deferred to Gap 2.4 (Encounter Rates)
```
To:
```
  - [x] Encounter rate items (Repel equivalent) — resolved in Gap 2.4: Ward Talisman and Infiltrator's Cloak (accessories in equipment.md) halve encounter rate
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
Message: `docs(shared): mark Gap 1.4 Repel equivalent as resolved by Gap 2.4`

---

### Task 4b: Update items.md Repel deferral note

**Files:**
- Modify: `docs/story/items.md`

**Context:** The spec's Section 11 lists items.md as needing modification. The Gap 1.4 section of the gap tracker has a deferred "Encounter rate items (Repel equivalent)" note. If items.md itself contains a similar deferral note (e.g., in the Battle Utility section or a footnote), it should be updated to reference the Ward Talisman and Infiltrator's Cloak.

- [ ] **Step 1: Search items.md for any Repel or encounter rate deferral**

Read `docs/story/items.md` and search for "encounter", "Repel", "deferred", or "Gap 2.4". If a deferral note exists, update it. If no such note exists in items.md (the deferral may only be in the gap tracker), skip to Step 3.

- [ ] **Step 2: Update the deferral note (if found)**

Replace any deferral text with:

```markdown
Encounter rate reduction is handled by accessories (Ward Talisman,
Infiltrator's Cloak) in [equipment.md](equipment.md), not consumable
items. See [combat-formulas.md](combat-formulas.md) for the encounter
system.
```

- [ ] **Step 3: Commit (if changes were made)**

```bash
git add docs/story/items.md
```
Message: `docs(shared): update items.md Repel deferral note`

---

## Chunk 2: Dungeon Formation Tables (dungeons-world.md)

### Task 5: Add Encounter Rate Tiers and 4-Pack Formation Tables to dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (all dungeon Encounter Table sections)

**Context:** dungeons-world.md contains 20 dungeons, each with an existing `### Encounter Table` that lists enemies with descriptions and HP. The current tables are narrative reference tables — they describe which enemies appear but don't define encounter frequency, formation groupings, or encounter rate tiers. This task adds a `### Encounter Rates & Formations` subsection after each dungeon's existing Encounter Table, containing:
1. The encounter rate tier assignment per floor
2. A 4-pack formation table per floor (or per dungeon if single-floor)

**Important:** The existing `### Encounter Table` sections must NOT be modified — they serve as narrative reference. The new content is additive.

**How to build each formation table:** For each dungeon floor:
1. Read the existing Encounter Table to identify which enemies appear on that floor.
2. Read the bestiary file for the relevant act to get enemy levels and types.
3. Build 4 formations using those enemies:
   - Formations 1-3 (31.25% each): Standard groups of 1-4 enemies from the floor's pool
   - Formation 4 (6.25%): Rare/tough encounter — use the floor's mini-boss, strongest enemy, or an unusual combination
4. Vary tactical composition: one all-melee group, one mixed, one with a support enemy, etc.

**Dungeon-by-dungeon instructions follow.** For each dungeon, insert the new subsection immediately AFTER the existing `### Encounter Table` section and BEFORE the next `###` subsection (usually `### Treasure/Loot` or `### Environmental Hazards`).

- [ ] **Step 1: Read bestiary act files for enemy reference**

Read the following bestiary files to have enemy pools available:
- `docs/story/bestiary/act-i.md` (Act I enemies)
- `docs/story/bestiary/act-ii.md` (Act II enemies)
- `docs/story/bestiary/interlude.md` (Interlude enemies)
- `docs/story/bestiary/act-iii.md` (Act III enemies)
- `docs/story/bestiary/optional.md` (Optional dungeon enemies)
- `docs/story/bestiary/bosses.md` (Boss stats for mini-boss formations)

Note the enemy names and levels for each dungeon's pool.

- [ ] **Step 2: Add encounter rates to Ember Vein (Dungeon 1)**

Insert after line 339 (end of Encounter Table), before line 340 (`### Treasure/Loot`):

```markdown
### Encounter Rates & Formations

**Encounter rate:** Tier 2 (Normal, increment 120, ~30 steps) all floors. Boss corridor (Floor 4 approach) is Tier 0 (Safe).

**Formation type:** Open terrain rules (75% Normal / 12.5% Back Attack / 12.5% Preemptive). This is a mine with good visibility.

| Floor | Fmt | Enemies | Weight |
|-------|-----|---------|--------|
| 1–2 | 1 | 2× Ley Vermin | 31.25% |
| 1–2 | 2 | 1× Ley Vermin + 1× Unstable Crystal | 31.25% |
| 1–2 | 3 | 3× Ley Vermin | 31.25% |
| 1–2 | 4 | 1× Unstable Crystal + 2× Ley Vermin (rare — crystal detonation risk) | 6.25% |
| 3 | 1 | 2× Mine Shade | 31.25% |
| 3 | 2 | 1× Mine Shade + 2× Ember Wisp | 31.25% |
| 3 | 3 | 1× Unstable Crystal + 1× Mine Shade | 31.25% |
| 3 | 4 | 2× Mine Shade + 2× Ember Wisp (rare — full party needed) | 6.25% |
```

- [ ] **Step 3: Add encounter rates to Fenmother's Hollow (Dungeon 2)**

Read the Fenmother's Hollow Encounter Table (around line 572). Build formation tables using the dungeon's enemy pool (Drowned Sentinel, Marsh Serpent, Bog Lurker, etc.). Insert after the Encounter Table.

Pattern:
- Tier 3 (High, increment 252, ~20 steps) — this is a swamp/forest dungeon with low visibility.
- Formation type: Low-visibility rules (68.75% Normal / 18.75% Back Attack / 12.5% Preemptive).
- Build 4-pack tables per floor using the floor's enemy pool from the existing Encounter Table.

- [ ] **Step 4: Add encounter rates to Carradan Rail Tunnels (Dungeon 3)**

Read the Encounter Table (around line 855). This is an Interlude dungeon — use Interlude enemies from `bestiary/interlude.md`.

Pattern:
- Tier 2 (Normal) for main tunnels, Tier 3 (High) for deeper sections.
- Formation type: Low-visibility rules (tunnels).
- Build 4-pack tables per floor.

- [ ] **Step 5: Add encounter rates to Axis Tower Interior (Dungeon 4)**

Read the Encounter Table (around line 1085).

Pattern:
- Tier 2 (Normal) for lower floors, Tier 3 (High) for upper floors.
- Formation type: Open terrain rules (interior corridors with visibility).
- Build 4-pack tables per floor.

- [ ] **Step 6: Add encounter rates to Ley Line Depths (Dungeon 5)**

Read the Encounter Table (around line 1463). This is a 3-floor dungeon with escalating difficulty.

Pattern:
- Floor 1: Tier 2 (Normal). Floor 2: Tier 2 (Normal). Floor 3: Tier 3 (High).
- Formation type: Low-visibility rules (underground caves).
- Build 4-pack tables per floor. Note: Infiltrator's Cloak is a treasure on Floor 2 — add a note that this accessory halves encounter rates.

- [ ] **Step 7: Add encounter rates to Pallor Wastes overworld (Dungeon 6)**

Read the Encounter Table (around line 1677). The Pallor Wastes is an overworld zone, not a dungeon — use Tier 4 (Intense, increment 700, ~10 steps).

Pattern:
- Tier 4 (Intense) — very high encounter rate per geography.md.
- Formation type: Pallor Wastes rules (62.5% Normal / 25% Back Attack / 12.5% Preemptive).
- Build 4-pack table for the general Pallor Wastes.

- [ ] **Step 8: Update Ley Scar encounter table**

The Ley Scar already has an encounter table at lines 1911-1918. The existing weights are 40/30/20/10, but the spec defines 30/30/30/10. Update the table to match the spec and add the encounter rate tier.

Insert before line 1911 (`**Encounter Table:**`):

```markdown
**Encounter rate:** Tier 4 (Intense, increment 506, ~14 steps).

**Formation type:** Pallor Wastes rules (62.5% Normal / 25% Back Attack / 12.5% Preemptive).

**Custom formation weights** (overrides standard 4-pack for mini-boss spawn rate):
```

Then update the existing encounter table (lines 1913-1918) to match the spec's weights:

```markdown
| Encounter | Rate |
|-----------|------|
| 2× Ley-Warped Drake (Lv 40) | 30% |
| 2× Ley-Warped Wraith (Lv 42) + 1× Ley-Warped Colossus (Lv 45) | 30% |
| 1× Ley-Warped Colossus + 2× Ley-Warped Drake | 30% |
| Ley Abomination (Lv 48) -- rare mini-boss | 10% |
```

- [ ] **Step 9: Add encounter rates to The Convergence (Dungeon 7)**

Read the Encounter Table (around line 2140).

Pattern:
- Tier 3 (High) for most areas, Tier 4 (Intense) for deepest sections. Boss corridors Tier 0.
- Formation type: Pallor Wastes rules (final dungeon is in the Pallor Wastes).
- Build 4-pack tables per section.

- [ ] **Step 10: Add encounter rates to Archive of Ages (Dungeon 8)**

Read the Encounter Table (around line 2301).

Pattern:
- Tier 2 (Normal) — this is a lore/puzzle dungeon.
- Formation type: Low-visibility rules (underground archive).
- Build 4-pack tables.

- [ ] **Step 11: Add encounter rates to Dreamer's Fault (Dungeon 9)**

Read the Encounter Table (around line 2417). This is a 20-floor optional dungeon with escalating difficulty.

Pattern:
- Floors 1-5: Tier 2 (Normal). Floors 6-10: Tier 3 (High). Floors 11-20: Tier 4 (Intense).
- Formation type: Low-visibility rules (underground).
- Build 4-pack tables per floor tier (3 tables: early, mid, deep). Boss floors (every 4th) are Tier 0 for the boss room itself.

- [ ] **Step 12: Add encounter rates to remaining dungeons (10-20)**

For each of dungeons 10-20 (Dry Well of Aelhart, Sunken Rig, Windshear Peak, Mountain Passes, Caves and Grottos, Caldera Forge Depths, Frostcap Caverns, Thornvein Passage, Valdris Siege Battlefield, Ley Nexus Hollow, Highcairn Monastery):

1. Read each dungeon's existing Encounter Table section.
2. Assign encounter rate tier based on dungeon type and difficulty:
   - Standard dungeon floors → Tier 2 (Normal)
   - Deep/dangerous floors → Tier 3 (High)
   - Boss corridors → Tier 0 (Safe)
3. Assign formation type based on environment:
   - Caves/tunnels/forests → Low-visibility rules
   - Open areas/interiors → Open terrain rules
4. Build 4-pack formation tables using the dungeon's enemy pool.
5. Insert after each Encounter Table section.

- [ ] **Step 13: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 14: Commit**

```bash
git add docs/story/dungeons-world.md
```
Message: `docs(shared): add encounter rate tiers and 4-pack formation tables to all dungeons in dungeons-world.md`

---

## Chunk 3: City Dungeons, Gap Update, and Verification

### Task 6: Add Encounter Rate Tiers and Formation Tables to dungeons-city.md

**Files:**
- Modify: `docs/story/dungeons-city.md` (all dungeon sections with encounters)

**Context:** dungeons-city.md has 7 main dungeon areas with existing encounter descriptions (narrative text, not tables). This task adds encounter rate tiers and 4-pack formation tables to each. The city dungeons are generally shorter and more story-driven than wilderness dungeons.

City dungeon areas with encounters:
1. **Valdris Crown Catacombs** (line 27) — Encounters at lines 81, 83
2. **Corrund Undercity / Sewers** (line 221) — Encounters at line 275
3. **Caldera Undercity** (line 383) — Encounters at line 458
4. **Ashmark Factory Depths** (line 490) — encounters described narratively
5. **Ironmark Citadel Dungeons** (line 651) — Encounters at line 724
6. **Bellhaven Smuggler Tunnels** (line 738) — Encounters at line 807
7. **Escape Routes** (line 1094) — 4 routes with encounters

- [ ] **Step 1: Read all city dungeon encounter sections**

Read each encounter section in dungeons-city.md to understand the enemy pools and narrative context.

- [ ] **Step 2: Add encounter rates to Valdris Crown Catacombs**

Insert after the encounter descriptions (around line 85). This dungeon has two modes:
- Interlude escape: Tier 1 (Low, increment 48) — minimal encounters, fixed battles
- Optional return: Tier 2 (Normal, increment 120)

Formation type: Low-visibility rules (underground catacombs).

Build 4-pack formation tables for the optional return using the enemies listed (Crypt Shades, Bone Wardens, Tomb Mites, Drowned Sentinels).

- [ ] **Step 3: Add encounter rates to Corrund Undercity / Sewers**

Insert after line 275 encounter description. Apply:
- Tier 2 (Normal) — standard sewer dungeon.
- Formation type: Low-visibility rules.
- Note: Tunnel Map key item applies ×0.5 modifier here if the dungeon connects to Bellhaven Tunnels. If not, note the Tunnel Map scope.

Build 4-pack table using the Corrund sewer enemies.

- [ ] **Step 4: Add encounter rates to remaining city dungeons**

For each remaining city dungeon (Caldera Undercity, Ashmark Factory Depths, Ironmark Citadel, Bellhaven Smuggler Tunnels):

1. Read the encounter descriptions.
2. Assign encounter rate tier (most are Tier 2 Normal).
3. Assign formation type (Low-visibility for underground, Open for factories).
4. Build 4-pack formation tables.
5. Insert after existing encounter descriptions.

**Special notes:**
- **Bellhaven Smuggler Tunnels:** The Tunnel Map key item applies ×0.5 modifier here. Add a note.
- **Caldera Undercity:** Kole's patrol timing applies ×0.5 in the Inner Ring. Add a note.

- [ ] **Step 5: Add encounter rates to Escape Routes**

The 4 escape routes (Valdris, Corrund, Caldera, Bellhaven) have fixed or minimal encounters. Assign:
- Tier 1 (Low) for routes with random encounters
- Tier 0 (Safe) for fixed-encounter-only routes
- Note: These are narrative-driven sequences — encounter rates should not impede story pacing.

- [ ] **Step 6: Update Design Notes section**

The Design Notes section (line 1397) has encounter philosophy text. Add a reference to the formalized encounter system:

```markdown
**Encounter rate system:** City dungeons use the danger counter system
defined in [combat-formulas.md](combat-formulas.md). Most city dungeon
areas use Tier 2 (Normal, ~30 steps). Location-specific modifiers
(Tunnel Map for Bellhaven, Kole's patrol for Caldera Inner Ring) reduce
rates in their respective areas. See the spec for full details.
```

- [ ] **Step 7: Commit**

```bash
git add docs/story/dungeons-city.md
```
Message: `docs(shared): add encounter rate tiers and formation tables to dungeons-city.md`

---

### Task 7: Update Gap 2.4 to COMPLETE

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (lines 343-362, Gap 2.4)

**Context:** All Gap 2.4 checklist items are now addressed. Update the status and check off all items.

- [ ] **Step 1: Read the current Gap 2.4 section**

Read `docs/analysis/game-design-gaps.md` lines 343-362.

- [ ] **Step 2: Update Gap 2.4 status and checklist**

Update the section:

```markdown
### 2.4 Encounter Rates & Weighted Tables

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/combat-formulas.md`, `docs/story/equipment.md`, `docs/story/geography.md`, `docs/story/dungeons-world.md`, `docs/story/dungeons-city.md`
**Depends On:** 1.3 (Bestiary)
**Completed:** 2026-03-25 — Danger counter model (FF6-derived), per-terrain increment values (Monte Carlo-verified), act scaling (×1.0/1.1/1.2/1.1), 3 formation types (Normal/Back Attack/Preemptive) with terrain-dependent rates, 4-pack encounter group tables for all dungeons, flee formula (SPD-based), Ward Talisman/Lure Talisman/Infiltrator's Cloak accessories, boss trigger categories, safe corridor rule.

**What's Needed:**
- [x] Base encounter rate per area type (danger counter with per-terrain increments)
- [x] Steps-between-encounters formula with variance (danger counter model, Monte Carlo-verified averages)
- [x] Encounter rate modifiers (Ward Talisman ×0.5, Lure Talisman ×2.0, Infiltrator's Cloak ×0.5, Tunnel Map, Kole's patrol timing)
- [x] Weighted encounter group tables per dungeon floor:
  - [x] Group composition (4-pack system: 31.25/31.25/31.25/6.25%)
  - [x] Per-floor escalation (deeper floors = higher tier + harder groups)
- [x] Preemptive strike rate and modifiers (12.5% base, Preemptive Charm +25pp, Sable's Coin 100%)
- [x] Back attack / ambush rate and modifiers (0–25% by terrain, Preemptive Charm eliminates)
- [x] Boss trigger conditions (Zone, Interact, Cutscene, HP Threshold — 4 categories)
- [x] Overworld encounter table per terrain type (10 zone types with increments)

**Blocking:** ~~Dungeon pacing, difficulty tuning~~
Now partially unblocks: 3.4 (Difficulty & Balance)
```

- [ ] **Step 3: Update the "Sprint Shoes" reference**

The checklist at line 353 mentions "Sprint Shoes" as an encounter rate modifier. Sprint Shoes do not exist in this game. Change the checked item to reference the actual modifiers (Ward Talisman, Lure Talisman, Infiltrator's Cloak, etc.) as shown above.

- [ ] **Step 4: Add Progress Tracking row**

Add to the Progress Tracking table at the bottom of the file:

```markdown
| 2026-03-25 | 2.4 Encounter Rates | PARTIAL → COMPLETE. Danger counter model, per-terrain increments (Monte Carlo-verified), act scaling, 3 formation types with terrain rates, 4-pack tables for all dungeons, flee formula, Ward/Lure Talisman + Infiltrator's Cloak, boss trigger types, safe corridor rule. | — |
```

- [ ] **Step 5: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 6: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
Message: `docs(shared): complete cross-reference verification, update Gap 2.4 to COMPLETE`
