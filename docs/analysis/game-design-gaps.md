# Game Design Gap Analysis

> **Living document.** Updated by the `story-designer` skill as gaps are
> addressed. Status fields reflect the current state of each design area.
> Last full audit: 2026-03-19.

## How to Read This Document

Each design area has:
- **Status:** MISSING | SKELETAL | PARTIAL | MOSTLY COMPLETE | COMPLETE
- **What's Needed:** Specific deliverables to close the gap
- **Blocking:** What cannot be built until this gap is closed
- **Files:** Where the design lives (or should live) in `docs/story/`
- **Depends On:** Other gaps that must be resolved first

When a gap is closed, the `story-designer` skill updates the status and
adds a "Completed" date + commit reference.

## Reference Materials

SNES-era JRPG reference data scraped from Fandom wikis and GameFAQs
guides. **Read the analysis files first** — they contain cross-game
counts, progression curves, and design takeaways for Pendulum of Despair.

| Directory | Analysis File | Raw References |
|-----------|--------------|----------------|
| `docs/references/items/` | `quick-stats.md` — item counts by type per game, design takeaways | FF4, FF6 (wiki + GameFAQs), CT (GameFAQs), SoM |
| `docs/references/weapons/` | `analysis.md` — weapon counts, ATK curves, character specialization, acquisition models | FF4, FF6, CT, SoM |
| `docs/references/armor/` | `analysis.md` — armor counts, DEF curves, slot philosophy, elemental/status design | FF4, FF6, CT (equipment), SoM |

**Key findings for story-designer:**
- **Item count target:** ~45 consumables (FF6 sweet spot) + key items + crafting materials
- **Weapon count target:** ~50–80 weapons; per-character weapon types (FF6/CT model)
- **Armor count target:** ~60–80 pieces; 4 slots (weapon, head, body, accessory)
- **Accessory depth:** 25–35 accessories are the customization engine (CT model)
- **Progression curve:** ATK ~5→100 (20x), DEF ~5→120; new tier every 2–3 dungeons
- **Elemental equipment:** 1–2 per element per type (weapons), 2–3 per element (armor)
- **Crafting:** SoM's Watts blacksmith model maps to Lira's Forgewright
- **Cursed items:** Grey Cleaver already designed; FF6's Cursed Shield is the gold standard

---

## Tier 1: Critical Blockers

These gaps prevent any game code from being written. They form an
interconnected system and should be designed together.

### 1.1 Damage & Combat Formulas

**Status:** COMPLETE
**Priority:** P0 — blocks all combat code
**Files:** `docs/story/combat-formulas.md`
**Depends On:** 1.2 (Stat System)
**Completed:** 2026-03-21

**What's Needed:**
- [x] Physical damage formula (ATK² / 6 - DEF, with up to -6.25% variance)
- [x] Magical damage formula (MAG × power / 4 - MDEF, with element multiplier)
- [x] Healing formula (MAG × power × 0.8, no defense)
- [x] Critical hit rate formula and damage multiplier (LCK/4 cap 50%, 2× damage)
- [x] Hit/miss calculation (accuracy vs evasion, 3-stage resolution)
- [x] Damage variance range (FF6-style: random_int(240,255)/256, up to -6.25%)
- [x] Damage cap (14,999 — mirrors HP cap)
- [x] How ability-specific multipliers interact (1.0–3.0× tiers, buff stacking rules)
- [x] Multi-hit damage splitting rules (per-hit independent, per-hit cap)
- [x] Armor/defense scaling approach (subtractive with floor of 1)
- [x] Status effect application rate formula (two-stage: MAG vs MDEF, then MEVA% resist)
- [x] Elemental weakness/resistance multipliers (1.5× weak, 0.75× disadvantage, 0.5× same, 0× immune, -1× absorb)

**Blocking:** ~~All combat implementation, ability balancing, enemy design~~
Now unblocks: 1.3 (Bestiary), 1.4 (Items), 2.5 (Row/Position)

---

### 1.2 Character Stat System

**Status:** COMPLETE
**Priority:** P0 — blocks combat formulas, equipment, leveling
**Files:** `docs/story/progression.md`, `docs/story/characters.md`
**Depends On:** None (foundational)
**Completed:** 2026-03-20

**What's Needed:**
- [x] Complete stat list with definitions (HP, MP, ATK, DEF, MAG, MDEF, SPD, LCK — 8 stats, EVA derived from SPD)
- [x] Base stats per character at level 1 (6 party members)
- [x] Stat growth curves per character per level (level cap 150)
- [x] Level cap decision (150)
- [x] Derived stat formulas:
  - [x] Physical hit rate (90 + (SPD - target.SPD) / 4, cap 99%, floor 20%)
  - [x] Physical evasion rate (SPD / 4, cap 50%)
  - [x] Magical evasion rate ((MDEF + SPD) / 8, cap 40%)
  - [x] Critical hit rate (LCK / 4, cap 50%)
  - [ ] ATB gauge fill rate (deferred to Gap 2.2)
- [x] Stat caps (255 for core stats, 14999 HP, 1499 MP)
- [x] Equipment stat bonus rules (additive, cannot exceed caps)
- [x] Buff/debuff effect on stats (percentage-based, can temporarily exceed 255)
- [x] Guest NPC stats (Cordwyn, Kerra) with scaling rules
- [x] Ley Crystal system (18 crystals, 5 XP-based levels, negative effects)
- [x] Narrative milestone stat spikes (12 story-driven permanent boosts)
- [x] Party join level rule (party average - 1)
- [x] Attack resolution order (hit rate -> evasion -> critical)

**Blocking:** ~~Damage formulas, equipment design, enemy balancing, XP curve~~
Now unblocks: 1.1 (Damage Formulas), 2.2 (ATB Mechanics)

---

### 1.3 Enemy Bestiary

**Status:** COMPLETE
**Priority:** P0 — blocks encounter implementation, economy
**Files:** `docs/story/bestiary/README.md`, `docs/story/bestiary/act-i.md`, `docs/story/bestiary/act-ii.md`, `docs/story/bestiary/interlude.md`, `docs/story/bestiary/act-iii.md`, `docs/story/bestiary/optional.md`, `docs/story/bestiary/bosses.md`, `docs/story/bestiary/palette-families.md`
**Depends On:** 1.1 (Damage Formulas), 1.2 (Stat System)
**Completed:** 2026-03-23 — Foundation + Act I–III + Interlude + Optional (198 enemies, 32 families) + Boss Compendium (29+1 bosses with full AI scripts).

**What's Needed:**
- [x] Complete stat sheet template: HP, MP, ATK, DEF, MAG, MDEF, SPD, Gold, Exp (19 columns)
- [ ] Per-enemy data for all ~40+ named enemies across every dungeon:
  - [x] Ember Vein enemies (Ley Vermin, Tomb Mite, Bone Warden, etc.)
  - [x] Fenmother's Hollow enemies (Drowned Sentinel, Marsh Serpent, etc.)
  - [x] Valdris Siege enemies (Compact Soldier, Engineer, Gyrocopter, Ashen Ram)
  - [x] Ley Line Depths F1–3 (Extraction Drone, Cave Crawler, Ley Colossus, etc.)
  - [x] Ashmark Factory (Forge Roach, Overclocked Automata, Forge Warden, etc.)
  - [x] Bellhaven Tunnels (Smuggler Thug, Sea Crawler, Tide Wraith)
  - [x] Overworld Act II (11 enemies across 5 terrain types)
  - [x] Interlude enemies (Rail Tunnels, Corrund, Catacombs, Caldera, Axis Tower, Ironmark — 52 enemies + Pallor Infection mechanic)
  - [x] Act III enemies (enhanced variants, Pallor creatures)
  - [x] Optional enemies (Dreamer's Fault — 24 enemies)
  - [x] Overworld Act I enemies per terrain type
- [x] Elemental profile per enemy (weaknesses, resistances, immunities, absorb)
- [x] Status effect vulnerability per enemy
- [x] Drop tables: common item, rare item, steal item (common/rare)
- [x] AI behavior scripts for bosses (attack patterns, conditional actions, phase triggers — regular enemies use weighted-random selection, no explicit scripts)
- [x] Boss stat sheets (all bosses from dungeons-world.md and dungeons-city.md):
  - [x] HP thresholds for phase changes
  - [x] Phase-specific ability sets
  - [x] Immunity lists
  - [x] Scripted events during battle
- [x] Palette-swap variant families (groups of enemies sharing sprites but different stats)
- [x] Recommended level range per dungeon verified against enemy stats

**Blocking:** ~~Combat encounters, drop system, economy balance, XP pacing~~
Now unblocks: 1.4 (Items), 1.6 (Economy), 2.1 (XP Curve), 2.4 (Encounter Rates)

---

### 1.4 Item & Consumable Catalog

**Status:** COMPLETE
**Priority:** P0 — blocks shops, inventory, combat items
**Files:** `docs/story/items.md`
**Depends On:** 1.1 (Damage Formulas for heal/damage items)
**Reference:** `docs/references/items/quick-stats.md` — cross-game item counts and design patterns (FF4/FF6/CT/SoM). Target ~45 consumables per quick-stats analysis.
**Completed:** 2026-03-23

**What's Needed:**
- [x] Consumable items with effects and prices:
  - [x] Healing items (Potion tiers, Elixir, Megalixir)
  - [x] MP restoration (Ether tiers)
  - [x] Revival items (Phoenix Feather, Phoenix Pinion)
  - [x] Status cure items (Antidote, Eye Drops, Remedy, etc.)
  - [x] Status infliction items (handled by Forgewright devices: Flashbang, Gravity Anchor)
  - [x] Stat boost items (permanent capsules; temporary buffs handled by Ley Crystal invocations)
  - [x] Escape items (Smoke Bomb)
  - [ ] Encounter rate items (Repel equivalent) — deferred to Gap 2.4 (Encounter Rates)
- [x] Key items list (quest-required items with descriptions and usage)
- [x] Crafting materials (Arcanite Ingots, Spirit Essence, Pallor Fragments, etc.)
- [x] Crafting recipes for Lira's Forgewright system
- [ ] Item acquisition matrix: which items available from shops, chests, drops, steals, quests — deferred to Gap 1.6 (Economy/shop inventories)
- [x] Item stack limits and inventory constraints
- [x] Sell price formula (typically 50% of buy price)

**Blocking:** ~~Shop system, treasure chests, enemy drops, quest rewards~~
Now unblocks: 1.5 (Equipment partial — items defined), 1.6 (Economy — item prices defined), 3.5 (Crafting — materials and recipes defined)

---

### 1.5 Equipment Stat Tables

**Status:** COMPLETE
**Priority:** P0 — blocks character progression feel
**Files:** `docs/story/equipment.md`
**Depends On:** 1.2 (Stat System) — 1.6 (Economy) was originally listed but is a circular dependency (equipment defines prices that economy uses). Removed.
**Reference:** `docs/references/weapons/analysis.md` — weapon counts, ATK curves, character specialization across FF4/FF6/CT/SoM. `docs/references/armor/analysis.md` — armor counts, DEF curves, slot philosophy, elemental/status design. Target ~50–80 weapons, ~60–80 armor, 4 equipment slots.
**Completed:** 2026-03-23 — 56 weapons (6 types, Tiers 0–5 + Forged), 49 armor (head/body/heavy/robe), 38 accessories, 8 Forged recipes, 7 elemental infusions, 7 secret synergies. ATK growth rebalance proposed. Boss drop cross-reference verified against bestiary.

**What's Needed:**
- [x] Equipment slot definitions (weapon, head, body, accessory, Ley Crystal — 5 slots)
- [x] Per-character equipment restrictions (who can equip what)
- [x] Complete weapon list with stats:
  - [x] Swords (Edren)
  - [x] Greatswords (Cael)
  - [x] Staves (Maren)
  - [x] Daggers (Sable)
  - [x] Hammers (Lira)
  - [x] Spears (Torren)
  - [x] Elemental weapons (infusions + innate)
  - [x] Ultimate weapons (one per character, sidequest rewards)
- [x] Complete armor list (head, body) with stats per tier
- [x] No shield slot — removed in favor of accessory (design decision documented)
- [x] Complete accessory list with special properties:
  - [x] Stat boost accessories (8)
  - [x] Status immunity accessories (6)
  - [x] Elemental resistance accessories (4)
  - [x] Unique mechanical accessories (6 — auto-haste, counter-attack, etc.)
  - [x] Character-specific / boss drop accessories (14)
- [x] Equipment tiers mapped to game progression:
  - [x] Act I gear (starter + first upgrade)
  - [x] Act II gear (diplomatic mission upgrades)
  - [x] Interlude gear (found/scrounged in broken world)
  - [x] Act III gear (endgame preparation)
  - [x] Ultimate/optional gear (sidequests, superbosses)
- [x] Equipment prices per tier
- [x] Arcanite Forging integration (8 recipes, 7 infusions, 7 synergies)

**Blocking:** ~~Shop inventories, treasure chest contents, character progression~~
Now unblocks: 1.6 (Economy — equipment prices defined), 3.5 (Crafting — Forgewright recipes defined)

---

### 1.6 Economy & Pricing

**Status:** COMPLETE
**Priority:** P0 — blocks shops, balance, progression feel
**Files:** `docs/story/economy.md`
**Depends On:** 1.3 (Bestiary for gold drops), 1.4 (Items for prices), 1.5 (Equipment for prices)
**Completed:** 2026-03-24 — Currency rules, shop inventories (10 towns with event-triggered restocking), treasure chest formula, boss gold drop system (rank + narrative split), steal economy, crafting costs, quest rewards, gold pacing targets, wealth curve. Caldera 150% inflation with Employee Card discount. Sleeping Bag/Tent/Pavilion rest item progression.

**What's Needed:**
- [x] Currency system: Gold (single currency; Scrip as regional name, no conversion)
- [x] Gold sources per act:
  - [x] Enemy gold drops (tied to bestiary)
  - [x] Treasure chest gold amounts per dungeon
  - [x] Quest reward gold amounts
  - [x] Sellable loot items / materials (no separate vendor trash tier)
- [x] Gold sinks per act:
  - [x] Equipment prices (tied to equipment tables)
  - [x] Consumable prices
  - [x] Inn prices per town
  - [x] Special services (unique town pricing quirks; see economy.md)
- [x] Economic pacing targets:
  - [x] Expected gold at end of each act
  - [x] Can player afford 70% of new equipment per town?
  - [x] Is there meaningful choice in purchases?
- [x] Shop inventory per town (complete stock lists with prices):
  - [x] All Valdris faction shops
  - [x] All Carradan faction shops
  - [x] All Thornmere faction shops
  - [x] Act-gated inventory changes
- [x] Steal economy (Sable's Tricks) — value of stolen items relative to shop goods
- [x] Crafting economy — material costs and crafted item values

**Blocking:** ~~All shops, treasure design, reward balancing~~
Now unblocks: 2.6 (Pallor Wastes Oases), 3.4 (Difficulty & Balance)

---

## Tier 2: High Priority

These gaps block specific subsystems but not the core game loop.

### 2.1 XP & Leveling Curve

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/progression.md`, `docs/story/dungeons-world.md`, `docs/story/bestiary/act-iii.md`, `docs/story/events.md`
**Depends On:** 1.2 (Stat System), 1.3 (Bestiary for XP per enemy)
**Completed:** 2026-03-24 — Two-phase XP curve (base=24 n^1.5 / base=10 n^1.8), full HP/MP restore on level-up, 50% absent XP share, flat XP model, Ley Scar grinding zone (4 enemies), Interlude reunion ability-acknowledgment rule.

**What's Needed:**
- [x] XP-to-level formula (two-phase: floor(24 × n^1.5) levels 1–70, floor(10 × n^1.8) levels 71–150)
- [x] XP per enemy (tied to bestiary logistic curve + Ley Scar hand-tuned overrides)
- [x] XP distribution rules: full share to 4 active members, 50% to 2 absent, 0 to KO'd
- [x] Stat gains per level per character (already complete in progression.md growth rates)
- [x] Ability/spell learning schedule per character per level (already complete in abilities.md/magic.md)
- [x] Expected level per dungeon/act milestone (pacing targets table in progression.md)
- [x] Catch-up mechanics: join at party_avg - 1, 50% absent XP share
- [x] Does level-up restore HP/MP? Yes — full HP/MP restore (FF6 model)

**Blocking:** ~~Progression pacing, difficulty tuning~~
Now partially unblocks: 3.4 (Difficulty & Balance — still needs other Tier 2 gaps)

---

### 2.2 ATB Gauge Mechanics

**Status:** MOSTLY COMPLETE
**Priority:** P1
**Files:** `docs/story/combat-formulas.md` (ATB Gauge System section)
**Depends On:** 1.2 (Stat System for speed stat)
**Completed:** 2026-03-21

**What's Needed:**
- [x] ATB gauge fill rate formula: `floor((SPD + 25) * battle_speed_factor * status_modifiers)` — see [combat-formulas.md](../story/combat-formulas.md)
- [x] Active vs. Wait mode: does gauge fill during menu navigation?
- [x] Haste/Slow effect on gauge (percentage multiplier?)
- [x] Battle speed config options (1-6 scale like FF6?)
- [x] Turn order resolution when multiple gauges fill simultaneously
- [x] ATB interaction with status effects:
  - [x] Stop: gauge frozen
  - [x] Sleep: gauge frozen until cured or damaged
  - [x] Confusion: auto-action on fill
  - [x] Berserk: auto-attack on fill
- [ ] ATB visual representation (horizontal bar? vertical? segmented?) — deferred to Gap 2.3
- [x] Party size in battle (4? 3? variable?)

**Blocking:** ~~Battle system implementation, status effect behavior~~
Remaining: ATB visual representation deferred to Gap 2.3 (UI Design)

---

### 2.3 UI & Menu Design

**Status:** MISSING
**Priority:** P1
**Files:** None yet (create `docs/story/ui-design.md`)
**Depends On:** None (can be designed independently)

**What's Needed:**
- [ ] Battle screen layout:
  - [ ] Party member positions and info display (HP/MP bars, names, ATB gauge)
  - [ ] Enemy display area
  - [ ] Command menu layout (Attack/Magic/Ability/Item/Defend/Flee)
  - [ ] Damage number display
  - [ ] Status effect indicators
  - [ ] Battle message area
- [ ] Main menu structure and navigation:
  - [ ] Items, Equipment, Magic/Abilities, Status, Party, Config, Save
- [ ] Equipment screen with stat comparison
- [ ] Shop interface (buy/sell with equipped indicator)
- [ ] Dialogue/text box specifications:
  - [ ] Position, size, font, text speed options
  - [ ] Character portrait display rules
  - [ ] Choice prompt layout
- [ ] Save/Load screen
- [ ] Config screen options (battle speed, ATB mode, text speed, sound)
- [ ] HUD elements during exploration (minimap? party HP?)

**Blocking:** All player-facing interfaces

---

### 2.4 Encounter Rates & Weighted Tables

**Status:** PARTIAL
**Priority:** P1
**Files:** `docs/story/dungeons-world.md` (encounter structures exist, rates missing)
**Depends On:** 1.3 (Bestiary)

**What's Needed:**
- [ ] Base encounter rate per area type (overworld, dungeon, town)
- [ ] Steps-between-encounters formula with variance
- [ ] Encounter rate modifiers (Sprint Shoes, abilities, terrain type)
- [ ] Weighted encounter group tables per dungeon floor:
  - [ ] Group composition (e.g., 40% chance: 2x Restless Dead + 1x Tomb Mite)
  - [ ] Per-floor escalation (deeper = harder groups)
- [ ] Preemptive strike rate and modifiers
- [ ] Back attack / ambush rate and modifiers
- [ ] Boss trigger conditions (tile, interact, cutscene, HP threshold)
- [ ] Overworld encounter table per terrain type

**Blocking:** Dungeon pacing, difficulty tuning

---

### 2.5 Row/Position System

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/combat-formulas.md`, `docs/story/characters.md`, `docs/story/abilities.md`
**Depends On:** 1.1 (Damage Formulas)
**Completed:** 2026-03-24 — Front/back row system (FF6 model): 50% physical damage modifier, free swap, back-row capable spears bypass penalty, player-only rows (no enemy rows), 6 character default assignments.

**What's Needed:**
- [x] Decision: Does this game have front/back rows? (FF4/FF6 had them)
- [x] If yes:
  - [x] Front row: full physical damage dealt and received
  - [x] Back row: reduced physical damage dealt and received (50%?)
  - [x] Magic unaffected by row
  - [x] Ranged weapons ignore row penalty
  - [x] Row swap action (costs a turn? Free?)
  - [x] Default row per character (tanks front, mages back)
- [x] If no: document the decision and rationale (N/A — we chose yes)
- [x] Enemy positioning (do enemies have rows/positions?)
- [x] Area-of-effect targeting rules (hit front row first? All enemies?)

**Blocking:** ~~Battle layout, damage calculation, enemy targeting~~
Now unblocks: 2.3 (UI Design — battle layout can reference row positions)

---

### 2.6 Pallor Wastes Oases

**Status:** MISSING
**Priority:** P1
**Files:** None yet (add to `docs/story/locations.md` and/or new `docs/story/oases.md`)
**Depends On:** 1.4 (Items), 1.5 (Equipment), 1.6 (Economy)

**What's Needed:**
- [ ] Number and placement of Oases in Act III overworld (closer to Convergence = rarer/smaller)
- [ ] Each Oasis as a micro-settlement: displaced villagers from fallen towns
- [ ] Services per Oasis:
  - [ ] Rest point (full HP/MP restore, save point)
  - [ ] Item shop (limited supplies — scarcity theme)
  - [ ] Weapon/armor vendor (scrounged/repaired gear, not top-tier)
  - [ ] Optional NPC quest givers (minor sidequests for crafting mats, lore, gear)
- [ ] Oasis protection mechanic: what keeps the Pallor out? (Ley ward stones? A Spirit anchor? Sheer collective will?)
- [ ] Narrative flavor: each Oasis has refugees from a specific fallen town, giving news/rumors about the spreading Grey
- [ ] Oasis discovery: visible on overworld map, or hidden and require exploration?
- [ ] Act progression: do Oases change/fall as the story advances? (e.g., one overrun between dungeon visits)

**Blocking:** Act III overworld pacing, player resource management in endgame, narrative worldbuilding

---

## Tier 3: Important But Not Blocking

### 3.1 Transport & Vehicle System

**Status:** MISSING
**Priority:** P2
**Files:** None yet
**Depends On:** Overworld design

**What's Needed:**
- [ ] Decision: Does this game have an airship?
- [ ] Rail system mechanics (Compact rail network between cities):
  - [ ] Which cities connected?
  - [ ] Cost per trip? Free?
  - [ ] Available when? (Functional Act II, erratic Interlude, restored Epilogue?)
- [ ] Fast travel mechanics (return to visited locations?)
- [ ] Mount/chocobo equivalent (if any)
- [ ] Boat/ship travel (if any — water routes between Bellhaven, Ironmouth?)
- [ ] Vehicle encounter rate modifiers

---

### 3.2 Overworld Traversal Mechanics

**Status:** PARTIAL
**Priority:** P2
**Files:** `docs/story/geography.md` (layout exists, mechanics missing)
**Depends On:** None

**What's Needed:**
- [ ] Tile types with passability rules (grass, forest, mountain, water, road, desert)
- [ ] Movement speed per terrain type
- [ ] Terrain encounter rate modifiers
- [ ] Transition between overworld and locations (fade? walk-in?)
- [ ] Weather/time-of-day effects (if any)

---

### 3.3 Dialogue System Mechanics

**Status:** PARTIAL
**Priority:** P2
**Files:** `docs/story/npcs.md` (content exists, presentation missing)
**Depends On:** 2.3 (UI Design)

**What's Needed:**
- [ ] Text box rendering specs (font, size, position, background)
- [ ] Character portrait system (who gets portraits? Emotion variants?)
- [ ] Text speed options and player control
- [ ] Choice prompt mechanics and visual layout
- [ ] NPC interaction model (talk once per visit? Repeatable? Changes on re-talk?)

---

### 3.4 Difficulty & Balance Framework

**Status:** MISSING
**Priority:** P2
**Files:** None yet
**Depends On:** 1.1-1.6 (all Tier 1 gaps)

**What's Needed:**
- [ ] Target difficulty philosophy (accessible? challenging? configurable?)
- [ ] Expected player level per area/boss
- [ ] Expected damage ranges (how many hits to kill a regular enemy? How long are boss fights?)
- [ ] Healing resource pacing (potions per dungeon, MP sustainability)
- [ ] Anti-frustration features (flee always succeeds? Encounter rate reduction?)
- [ ] Balance testing methodology

---

### 3.5 Crafting System (Arcanite Forging)

**Status:** SKELETAL
**Priority:** P2
**Files:** `docs/story/abilities.md` (Forgewright ability referenced, no recipes)
**Depends On:** 1.4 (Items), 1.5 (Equipment)

**What's Needed:**
- [ ] Crafting recipe list (materials + result)
- [ ] Material acquisition sources
- [ ] Crafting UI/interaction model (at workbench? Menu? Lira-only?)
- [ ] Crafted item tier progression
- [ ] Integration with Lira's story arc (new recipes unlock with plot?)

---

### 3.6 New Game+ & Post-Game

**Status:** MISSING
**Priority:** P3
**Files:** None yet
**Depends On:** Everything else

**What's Needed:**
- [ ] New Game+ rules (what carries over? Level, items, bestiary?)
- [ ] Post-game content beyond Dreamer's Fault
- [ ] Superboss encounters (optional bosses harder than final boss)
- [ ] Completion tracking (bestiary %, item %, quest %)

---

## Already Strong (No Gaps)

These areas are complete or mostly complete and don't need new design
documents. They may need minor updates as Tier 1 gaps are filled.

| Area | File(s) | Status |
|------|---------|--------|
| Story & Narrative | outline.md, events.md | COMPLETE |
| Character Arcs | characters.md | COMPLETE |
| World Building | world.md, geography.md | COMPLETE |
| Location Design | locations.md, city-*.md | COMPLETE |
| Dungeon Design | dungeons-world.md, dungeons-city.md | COMPLETE |
| NPC Design | npcs.md | MOSTLY COMPLETE |
| Magic System | magic.md | MOSTLY COMPLETE (needs numeric balance) |
| Ability System | abilities.md | MOSTLY COMPLETE (needs damage values) |
| Music Score | music.md | COMPLETE |
| Visual Style | visual-style.md, building-palette.md | COMPLETE |
| Dynamic World | dynamic-world.md | COMPLETE |
| Biomes | biomes.md | COMPLETE |
| Side Quests | sidequests.md | MOSTLY COMPLETE |
| Event Flags | events.md | MOSTLY COMPLETE |

---

## Progress Tracking

| Date | Gap | Change | Commit |
|------|-----|--------|--------|
| 2026-03-19 | Initial audit | All gaps cataloged | — |
| 2026-03-20 | 1.2 Stat System | PARTIAL -> COMPLETE. 8 stats, level cap 150, Ley Crystals, milestones. Unblocks 1.1 + 2.2. | acba850, 1cb8f6c |
| 2026-03-21 | 1.1 Damage & Combat Formulas | MISSING -> COMPLETE. Physical (ATK²/6), magic (MAG*power/4), 14999 cap, 3-tier combat interactions. Unblocks 1.3, 1.4, 2.5. | b50da1b |
| 2026-03-21 | 2.2 ATB Gauge Mechanics | PARTIAL -> MOSTLY COMPLETE. Fill rate (SPD+25)*factor, Active/Wait, battle speed 1-6, status interactions, 4-party. Visual deferred to 2.3. | 879bf2e |
| 2026-03-22 | 1.3 Enemy Bestiary | MISSING -> PARTIAL. Template (19 cols), 8 types, stat scaling (Lv 1-150), bounded-growth rewards, 25 Act I enemies, 19 palette families. | ab92dba |
| 2026-03-22 | 1.3 Enemy Bestiary | PARTIAL update. Act II enemies (33): Ley Line Depths F1–3, Ashmark, Bellhaven, Valdris Siege gauntlet, Overworld. 9 new families, 11 Tier 2 revisions. Airborne spawn-on-death mechanic. | b4358a2 |
| 2026-03-22 | 1.3 Enemy Bestiary | PARTIAL update. Interlude enemies (52): Rail Tunnels, Corrund, Catacombs, Caldera, Axis Tower, Ironmark. Pallor Infection mechanic (4 sources, 3 set-pieces). 4 new families, ~15 Tier 3/4 updates. | 781f4ce |
| 2026-03-23 | 1.3 Enemy Bestiary | PARTIAL update. Optional enemies (24): Dreamer's Fault (20 floors, 5 ages, Lv 42–100). Void deployment notes for Drake/Wolf/Lurker families. Only Boss Compendium remains. | — |
| 2026-03-23 | 1.3 Enemy Bestiary | PARTIAL → COMPLETE. Boss Compendium (29+1 bosses): full AI scripts, phase mechanics, scripted events, stat tables verified against act files. Gap 1.3 fully closed. | — |
| 2026-03-23 | 1.4 Item & Consumable Catalog | MISSING → COMPLETE. 32 consumables, 13 Forgewright devices, 18 Ley Crystal invocations, 67 materials, 23 key items, cross-reference tables. Unblocks 1.5, 1.6, 3.5. | — |
| 2026-03-23 | 1.5 Equipment Stat Tables | SKELETAL → COMPLETE. 56 weapons, 49 armor, 38 accessories, Forgewright crafting (8 recipes, 7 infusions, 7 synergies), ATK rebalance proposal, boss drop cross-reference. Unblocks 1.6, 3.5. | — |
| 2026-03-24 | 1.6 Economy & Pricing | SKELETAL → COMPLETE. Currency (Gold/Scrip unified), 10 town shop inventories, event-triggered restocking, treasure chest formula, boss gold system (rank × narrative split), steal economy, crafting costs, quest rewards, gold pacing (70% affordability), wealth curve. Unblocks 2.6, 3.4. | — |
| 2026-03-24 | 2.1 XP & Leveling Curve | PARTIAL → COMPLETE. Two-phase XP curve, full HP/MP restore on level-up, 50% absent XP share, Ley Scar grinding zone (4 enemies), Interlude reunion rule. | — |
| 2026-03-24 | 2.5 Row/Position System | MISSING → COMPLETE. Front/back rows (FF6 model), 50% physical modifier, free swap, back-row capable spears, player-only (no enemy rows), 6 default assignments. | — |
