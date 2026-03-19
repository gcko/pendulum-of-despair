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

---

## Tier 1: Critical Blockers

These gaps prevent any game code from being written. They form an
interconnected system and should be designed together.

### 1.1 Damage & Combat Formulas

**Status:** MISSING
**Priority:** P0 — blocks all combat code
**Files:** None yet (create `docs/story/combat-formulas.md`)
**Depends On:** 1.2 (Stat System)

**What's Needed:**
- [ ] Physical damage formula (ATK vs DEF, with variance)
- [ ] Magical damage formula (MAG vs MAGDEF, element multiplier)
- [ ] Healing formula (spell power, caster stats)
- [ ] Critical hit rate formula and damage multiplier
- [ ] Hit/miss calculation (accuracy vs evasion)
- [ ] Damage variance range (e.g., +/- 12.5%)
- [ ] Damage cap (9999? 99999?)
- [ ] How ability-specific multipliers interact (Riposte 1.5x, Overcharge +50%)
- [ ] Multi-hit damage splitting rules
- [ ] Armor/defense scaling approach (subtractive vs percentage)
- [ ] Status effect application rate formula (caster MAG vs target resistance)
- [ ] Elemental weakness/resistance multipliers (2x weak, 0.5x resist, 0x immune, absorb)

**Blocking:** All combat implementation, ability balancing, enemy design

---

### 1.2 Character Stat System

**Status:** PARTIAL
**Priority:** P0 — blocks combat formulas, equipment, leveling
**Files:** `docs/story/characters.md` (narrative only, no stats)
**Depends On:** None (foundational)

**What's Needed:**
- [ ] Complete stat list with definitions (HP, MP, ATK, DEF, MAG, MAGDEF, SPD, EVA, LCK)
- [ ] Base stats per character at level 1 (6 party members)
- [ ] Stat growth curves per character per level (1-99 or chosen cap)
- [ ] Level cap decision (50? 75? 99?)
- [ ] Derived stat formulas:
  - [ ] Physical hit rate
  - [ ] Physical evasion rate
  - [ ] Magical evasion rate
  - [ ] Critical hit rate
  - [ ] ATB gauge fill rate (speed-dependent)
- [ ] Stat caps (max ATK, max HP, etc.)
- [ ] Equipment stat bonus rules (additive? multiplicative? percentage?)
- [ ] Buff/debuff effect on stats (flat +/- or percentage?)
- [ ] Guest NPC stats (Cordwyn, Kerra) and scaling rules

**Blocking:** Damage formulas, equipment design, enemy balancing, XP curve

---

### 1.3 Enemy Bestiary

**Status:** MISSING
**Priority:** P0 — blocks encounter implementation, economy
**Files:** None yet (create `docs/story/enemies.md`)
**Depends On:** 1.1 (Damage Formulas), 1.2 (Stat System)

**What's Needed:**
- [ ] Complete stat sheet template: HP, MP, ATK, DEF, MAG, MAGDEF, SPD, LCK, XP, Gold
- [ ] Per-enemy data for all ~40+ named enemies across every dungeon:
  - [ ] Ember Vein enemies (Restless Dead, Tomb Mite, Bone Warden, etc.)
  - [ ] Fenmother's Hollow enemies (Drowned Sentinel, Marsh Leech, etc.)
  - [ ] Valdris Siege enemies (Carradan Soldier, Compact Engineer, etc.)
  - [ ] Interlude enemies (Pallor Hollow, Fading Victim, Spirit Essence, etc.)
  - [ ] Act III enemies (enhanced variants, Pallor creatures)
  - [ ] Overworld enemies per terrain type
- [ ] Elemental profile per enemy (weaknesses, resistances, immunities, absorb)
- [ ] Status effect vulnerability per enemy
- [ ] Drop tables: common item, rare item, steal item (common/rare)
- [ ] AI behavior scripts per enemy (attack patterns, conditional actions, phase triggers)
- [ ] Boss stat sheets (all bosses from dungeons-world.md and dungeons-city.md):
  - [ ] HP thresholds for phase changes
  - [ ] Phase-specific ability sets
  - [ ] Immunity lists
  - [ ] Scripted events during battle
- [ ] Palette-swap variant families (groups of enemies sharing sprites but different stats)
- [ ] Recommended level range per dungeon verified against enemy stats

**Blocking:** Combat encounters, drop system, economy balance, XP pacing

---

### 1.4 Item & Consumable Catalog

**Status:** MISSING
**Priority:** P0 — blocks shops, inventory, combat items
**Files:** None yet (create `docs/story/items.md`)
**Depends On:** 1.1 (Damage Formulas for heal/damage items)

**What's Needed:**
- [ ] Consumable items with effects and prices:
  - [ ] Healing items (Potion tiers, Elixir, Megalixir)
  - [ ] MP restoration (Ether tiers)
  - [ ] Revival items (Phoenix Feather, Phoenix Pinion)
  - [ ] Status cure items (Antidote, Eye Drops, Remedy, etc.)
  - [ ] Status infliction items (battle-use attack items)
  - [ ] Stat boost items (temporary buffs)
  - [ ] Escape items (Smoke Bomb)
  - [ ] Encounter rate items (Repel equivalent)
- [ ] Key items list (quest-required items with descriptions and usage)
- [ ] Crafting materials (Arcanite Ingots, Spirit Essence, Pallor Fragments, etc.)
- [ ] Crafting recipes for Lira's Forgewright system
- [ ] Item acquisition matrix: which items available from shops, chests, drops, steals, quests
- [ ] Item stack limits and inventory constraints
- [ ] Sell price formula (typically 50% of buy price)

**Blocking:** Shop system, treasure chests, enemy drops, quest rewards

---

### 1.5 Equipment Stat Tables

**Status:** SKELETAL
**Priority:** P0 — blocks character progression feel
**Files:** None yet (create `docs/story/equipment.md`)
**Depends On:** 1.2 (Stat System), 1.6 (Economy)

**What's Needed:**
- [ ] Equipment slot definitions (weapon, shield/off-hand, head, body, accessory x2?)
- [ ] Per-character equipment restrictions (who can equip what)
- [ ] Complete weapon list with stats:
  - [ ] Swords (Edren, Cael)
  - [ ] Staves/rods (Maren)
  - [ ] Daggers/tools (Sable)
  - [ ] Hammers/wrenches (Lira)
  - [ ] Bows/spears (Torren)
  - [ ] Elemental weapons
  - [ ] Ultimate weapons (one per character, sidequest rewards)
- [ ] Complete armor list (head, body) with stats per tier
- [ ] Complete shield list with stats
- [ ] Complete accessory list with special properties:
  - [ ] Stat boost accessories
  - [ ] Status immunity accessories
  - [ ] Elemental resistance accessories
  - [ ] Unique mechanical accessories (auto-haste, counter-attack, etc.)
- [ ] Equipment tiers mapped to game progression:
  - [ ] Act I gear (starter + first upgrade)
  - [ ] Act II gear (diplomatic mission upgrades)
  - [ ] Interlude gear (found/scrounged in broken world)
  - [ ] Act III gear (endgame preparation)
  - [ ] Ultimate/optional gear (sidequests, superbosses)
- [ ] Equipment prices per tier
- [ ] Arcanite Forging integration (Lira's crafting upgrades)

**Blocking:** Shop inventories, treasure chest contents, character progression

---

### 1.6 Economy & Pricing

**Status:** SKELETAL
**Priority:** P0 — blocks shops, balance, progression feel
**Files:** None yet (create `docs/story/economy.md`)
**Depends On:** 1.3 (Bestiary for gold drops), 1.4 (Items for prices), 1.5 (Equipment for prices)

**What's Needed:**
- [ ] Currency system: Gold (primary), Scrip (Compact currency, conversion rate)
- [ ] Gold sources per act:
  - [ ] Enemy gold drops (tied to bestiary)
  - [ ] Treasure chest gold amounts per dungeon
  - [ ] Quest reward gold amounts
  - [ ] Sellable loot items (vendor trash)
- [ ] Gold sinks per act:
  - [ ] Equipment prices (tied to equipment tables)
  - [ ] Consumable prices
  - [ ] Inn prices per town
  - [ ] Special services (money lender interest rate, etc.)
- [ ] Economic pacing targets:
  - [ ] Expected gold at end of each act
  - [ ] Can player afford ~75% of new equipment per town?
  - [ ] Is there meaningful choice in purchases?
- [ ] Shop inventory per town (complete stock lists with prices):
  - [ ] All Valdris faction shops
  - [ ] All Carradan faction shops
  - [ ] All Thornmere faction shops
  - [ ] Act-gated inventory changes
- [ ] Steal economy (Sable's Tricks) — value of stolen items relative to shop goods
- [ ] Crafting economy — material costs and crafted item values

**Blocking:** All shops, treasure design, reward balancing

---

## Tier 2: High Priority

These gaps block specific subsystems but not the core game loop.

### 2.1 XP & Leveling Curve

**Status:** PARTIAL
**Priority:** P1
**Files:** None yet (add to `docs/story/combat-formulas.md` or separate file)
**Depends On:** 1.2 (Stat System), 1.3 (Bestiary for XP per enemy)

**What's Needed:**
- [ ] XP-to-level formula (exponential curve: `XP_needed = base * level^exponent`)
- [ ] XP per enemy (tied to bestiary, scaling by area)
- [ ] XP distribution rules: equal split among living party? Absent members get partial?
- [ ] Stat gains per level per character (tied to growth curves in 1.2)
- [ ] Ability/spell learning schedule per character per level
- [ ] Expected level per dungeon/act milestone
- [ ] Catch-up mechanics for underleveled party members (if any)
- [ ] Does level-up restore HP/MP? (FF6: yes)

**Blocking:** Progression pacing, difficulty tuning

---

### 2.2 ATB Gauge Mechanics

**Status:** PARTIAL
**Priority:** P1
**Files:** `docs/story/abilities.md` (references ATB but doesn't define it)
**Depends On:** 1.2 (Stat System for speed stat)

**What's Needed:**
- [ ] ATB gauge fill rate formula: `fill_rate = base_speed + (SPD * modifier)`
- [ ] Active vs. Wait mode: does gauge fill during menu navigation?
- [ ] Haste/Slow effect on gauge (percentage multiplier?)
- [ ] Battle speed config options (1-6 scale like FF6?)
- [ ] Turn order resolution when multiple gauges fill simultaneously
- [ ] ATB interaction with status effects:
  - [ ] Stop: gauge frozen
  - [ ] Sleep: gauge frozen until hit
  - [ ] Confusion: auto-action on fill
  - [ ] Berserk: auto-attack on fill
- [ ] ATB visual representation (horizontal bar? vertical? segmented?)
- [ ] Party size in battle (4? 3? variable?)

**Blocking:** Battle system implementation, status effect behavior

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

**Status:** MISSING (design decision needed)
**Priority:** P1
**Files:** None
**Depends On:** 1.1 (Damage Formulas)

**What's Needed:**
- [ ] Decision: Does this game have front/back rows? (FF4/FF6 had them)
- [ ] If yes:
  - [ ] Front row: full physical damage dealt and received
  - [ ] Back row: reduced physical damage dealt and received (50%?)
  - [ ] Magic unaffected by row
  - [ ] Ranged weapons ignore row penalty
  - [ ] Row swap action (costs a turn? Free?)
  - [ ] Default row per character (tanks front, mages back)
- [ ] If no: document the decision and rationale
- [ ] Enemy positioning (do enemies have rows/positions?)
- [ ] Area-of-effect targeting rules (hit front row first? All enemies?)

**Blocking:** Battle layout, damage calculation, enemy targeting

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
