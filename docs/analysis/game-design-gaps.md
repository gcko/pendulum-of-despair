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
| `docs/references/scripts/ff6/` | `index.md` — FF6 SNES complete game script (4 parts, 5,907 lines) | [Fandom wiki](https://finalfantasy.fandom.com/wiki/Final_Fantasy_VI_SNES_script) |
| `docs/references/scripts/ff4/` | `index.md` — FF4 Advance complete game script (3 parts, 4,164 lines) | [GameFAQs](https://gamefaqs.gamespot.com/gba/929937-final-fantasy-iv-advance/faqs/40689) |
| `docs/references/scripts/chrono-trigger/` | `index.md` — Chrono Trigger complete game script (10 parts, 19,421 lines) | [GameFAQs](https://gamefaqs.gamespot.com/snes/563538-chrono-trigger/faqs/31563) |
| `docs/references/scripts/secret-of-mana/` | `index.md` — Secret of Mana complete game script (2 parts, 3,692 lines) | [GameFAQs](https://gamefaqs.gamespot.com/snes/588646-secret-of-mana/faqs/19271) |

**Key findings for story-designer:**
- **Item count target:** ~45 consumables (FF6 sweet spot) + key items + crafting materials
- **Weapon count target:** ~50–80 weapons; per-character weapon types (FF6/CT model)
- **Armor count target:** ~60–80 pieces; 4 slots (weapon, head, body, accessory)
- **Accessory depth:** 25–35 accessories are the customization engine (CT model)
- **Progression curve:** ATK ~5→100 (20x), DEF ~5→120; new tier every 2–3 dungeons
- **Elemental equipment:** 1–2 per element per type (weapons), 2–3 per element (armor)
- **Crafting:** SoM's Watts blacksmith model maps to Lira's Forgewright
- **Cursed items:** Grey Cleaver already designed; FF6's Cursed Shield is the gold standard
- **Script length:** FF6 ~5,900 lines, FF4 ~4,200 lines, CT ~19,400 lines, SoM ~3,700 lines — target ~5,000–8,000 lines for PoD (FF6-tier scope with CT-style optional depth)
- **Dialogue patterns:** FF6 uses terse, punchy lines (2–3 sentences max per text box); CT uses party-dependent dialogue variations; SoM is minimal; FF4 is dramatic/formal — PoD should blend FF6 brevity with CT party-awareness

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
  - [x] Encounter rate items (Repel equivalent) — resolved in Gap 2.4: Ward Talisman and Infiltrator's Cloak (accessories in equipment.md) halve encounter rate
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
- [x] ATB visual representation — resolved in Gap 2.3: horizontal bar, gold fill, inline with party panel row, 2-frame flash when full
- [x] Party size in battle (4? 3? variable?)

**Blocking:** ~~Battle system implementation, status effect behavior~~
All items resolved. ATB visual resolved in Gap 2.3 (UI Design).

---

### 2.3 UI & Menu Design

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/ui-design.md`
**Depends On:** None (references 2.2 ATB Mechanics, 2.5 Row System, 1.2 Stat System)
**Completed:** 2026-03-25 — FF6 minimalist SNES pixel art UI. Battle screen (classic FF6 layout, horizontal ATB bars, status icons above names), 9-command main menu, item/equipment/magic/abilities/status/formation/config screens, Buy/Sell shop interface, full-width dialogue box (no portraits, typewriter effect), enhanced save/load (all 4 party members per slot), Ley Crystal screen, no exploration HUD, unified 22-icon status effect system, Pallor narrative integration, input mapping.

**What's Needed:**
- [x] Battle screen layout:
  - [x] Party member positions and info display (HP/MP bars, names, ATB gauge)
  - [x] Enemy display area
  - [x] Command menu layout (Attack/Magic/Ability/Item/Defend/Flee)
  - [x] Damage number display
  - [x] Status effect indicators
  - [x] Battle message area
- [x] Main menu structure and navigation:
  - [x] Items, Equipment, Magic/Abilities, Status, Formation, Config, Save
- [x] Equipment screen with stat comparison
- [x] Shop interface (buy/sell with equipped indicator)
- [x] Dialogue/text box specifications:
  - [x] Position, size, font, text speed options
  - [x] Character portrait display rules (no portraits in dialogue; menu portraits only)
  - [x] Choice prompt layout
- [x] Save/Load screen
- [x] Config screen options (battle speed, ATB mode, text speed, sound)
- [x] HUD elements during exploration (none — clean game world, location name flash only)

**Blocking:** ~~All player-facing interfaces~~
Now unblocks: 3.3 (Dialogue System — text box specs defined). Also resolves ATB visual representation deferred from Gap 2.2.

---

### 2.4 Encounter Rates & Weighted Tables

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/combat-formulas.md`, `docs/story/equipment.md`, `docs/story/geography.md`, `docs/story/dungeons-world.md`, `docs/story/dungeons-city.md`
**Depends On:** 1.3 (Bestiary)
**Completed:** 2026-03-25 — Danger counter model (FF6-derived), per-terrain increment values (Monte Carlo-verified), act scaling (×1.0/1.1/1.2/1.1), 3 formation types (Normal/Back Attack/Preemptive) with terrain-dependent rates, 4-pack encounter group tables for all dungeons, flee formula (SPD-based), Ward Talisman/Lure Talisman/Infiltrator's Cloak accessories, boss trigger categories, safe corridor rule.

**What's Needed:**
- [x] Base encounter rate per area type (danger counter with per-terrain increments)
- [x] Steps-between-encounters formula with variance (danger counter model, Monte Carlo-verified averages)
- [x] Encounter rate modifiers (Ward Talisman ×0.5, Lure Talisman ×2.0, Infiltrator's Cloak ×0.5, location-specific: Tunnel Map, Kole's patrol)
- [x] Weighted encounter group tables per dungeon floor:
  - [x] Group composition (4-pack system: 31.25/31.25/31.25/6.25%)
  - [x] Per-floor escalation (deeper floors use higher tier + harder groups)
- [x] Preemptive strike rate and modifiers (12.5% base, Preemptive Charm +25pp, Sable's Coin 100%)
- [x] Back attack / ambush rate and modifiers (0–25% by terrain, Preemptive Charm eliminates)
- [x] Boss trigger conditions (Zone, Interact, Cutscene, HP Threshold — 4 categories)
- [x] Overworld encounter table per terrain type (10 overworld zone types + dungeon tiers, with danger counter increments)

**Blocking:** ~~Dungeon pacing, difficulty tuning~~
Now partially unblocks: 3.4 (Difficulty & Balance)

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
  - [x] Back-row capable weapons (spears) bypass row penalty
  - [x] Row swap action (costs a turn? Free?)
  - [x] Default row per character (tanks front, mages back)
- [x] If no: document the decision and rationale (N/A — we chose yes)
- [x] Enemy positioning (do enemies have rows/positions?)
- [x] Area-of-effect targeting rules (hit front row first? All enemies?)

**Blocking:** ~~Battle layout, damage calculation, enemy targeting~~
Now unblocks: 2.3 (UI Design — battle layout can reference row positions)

---

### 2.6 Pallor Wastes Oases

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/locations.md`, `docs/story/dungeons-world.md`, `docs/story/npcs.md`, `docs/story/sidequests.md`, `docs/story/events.md`, `docs/story/bestiary/act-iii.md`, `docs/story/bestiary/bosses.md`, `docs/story/equipment.md`, `docs/story/items.md`
**Depends On:** 1.4 (Items), 1.5 (Equipment), 1.6 (Economy)
**Completed:** 2026-03-25 — Three Oases (Valdris/Compact/Thornmere refugees) with ley ward stone protection, shops/inn/save, 12 NPCs (including familiar faces from earlier acts), 3 minor sidequests, Oasis C fall event with The Grey Keeper mini-boss, post-Convergence state.

**What's Needed:**
- [x] Number and placement of Oases in Act III overworld (3 Oases: NW/Central/SE Pallor Wastes, visible on overworld map)
- [x] Each Oasis as a micro-settlement: displaced villagers from fallen towns (Valdris, Compact, Thornmere refugees with familiar NPCs)
- [x] Services per Oasis:
  - [x] Rest point (full HP/MP restore, save point) — 50g/75g/100g
  - [x] Item shop (limited supplies — unique per Oasis, per economy.md)
  - [x] Weapon/armor vendor (Tier 4 gear per economy.md inventories)
  - [x] Optional NPC quest givers (3 minor sidequests: The Last Banner, Amplifier Stabilization, The Cracking Stone)
- [x] Oasis protection mechanic: ley ward stones (natural ley energy nodes creating protective bubbles)
- [x] Narrative flavor: each Oasis has refugees from a specific fallen town with news/rumors about the Grey
- [x] Oasis discovery: visible on overworld map (green/golden shimmer), no searching required
- [x] Act progression: Oasis C falls when the party first visits Oasis B. The Grey Keeper mini-boss encounter. Oases A and B survive. Post-Convergence: survivors rebuild, shops expand.

**Blocking:** ~~Act III overworld pacing, player resource management in endgame, narrative worldbuilding~~
Now complete.

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

**Status:** COMPLETE
**Priority:** P2
**Files:** `docs/story/overworld.md` (primary); modified: `docs/story/geography.md`
**Depends On:** None
**Completed:** 2026-03-27

**What's Needed:**
- [x] Tile types with passability rules — 5 categories (passable, impassable, entry trigger, conditional, event trigger); vehicle-conditional tiles deferred to Gap 3.1
- [x] Movement speed per terrain type — resolved: uniform on-foot speed (no per-terrain modifiers), per SNES convention; 7 speed tiers removed from geography.md
- [x] Terrain encounter rate modifiers — already defined in geography.md Section 5 (danger counter increments per 11 terrain zones); overworld.md references, does not duplicate
- [x] Transition between overworld and locations — fade to black (overworld → location), seamless (within-location), FF6 battle transitions (Mode 7 zoom + mosaic + distinct boss)
- [x] Weather/time-of-day effects — FF6 Plus: location-fixed atmospherics + 6 story-triggered overrides; no day/night gameplay cycle (biomes.md visual palette shifts are cosmetic only)
- [x] Overworld presentation (Mode 7-style perspective, miniaturized sprites, HDMA horizon gradient)
- [x] Map screen specification (menu-accessed, parchment style, first-visit location discovery)
- [x] Design changes applied: geography.md speed modifiers removed, zoom mechanic removed

**Blocking:** ~~Overworld implementation~~ Now unblocks: 3.1 (Transport & Vehicle System — vehicle-conditional tiles)

---

### 3.3 Dialogue System Mechanics

**Status:** COMPLETE
**Priority:** P2
**Files:** `docs/story/dialogue-system.md`, `docs/story/npcs.md`
**Depends On:** 2.3 (UI Design)
**Completed:** 2026-03-26

**What's Needed:**
- [x] Text box rendering specs — confirmed in ui-design.md Section 12
- [x] Character portrait system — resolved: no portraits in dialogue, sprite emotion system (14 animations), menu portraits use single neutral expression
- [x] Text speed options and player control — confirmed in ui-design.md Section 12
- [x] Choice prompt mechanics and visual layout — confirmed in ui-design.md Section 12
- [x] NPC interaction model — priority stack (first-match-wins), flag-gated, party-aware (2 tiers)
- [x] Sprite emotion animation catalog (14 animations with timing rules)
- [x] Dialogue data format (entry fields, sub-fields, 8 worked examples)
- [x] Party-aware dialogue rules (Tier 1 key scenes + Tier 2 NPC reactions)
- [x] Flag condition system (binary, numeric, string comparison, party_has)

**Blocking:** ~~Dialogue scripting, script authoring~~ Now unblocks: 3.7 (Full Dialogue Script)

---

### 3.4 Difficulty & Balance Framework

**Status:** COMPLETE
**Priority:** P2
**Files:** `docs/story/difficulty-balance.md`
**Depends On:** 1.1–1.6 (all Tier 1 gaps — all COMPLETE)
**Completed:** 2026-03-26 — FF6 Accessible philosophy, one fixed difficulty. Regular enemies die in 2–4 hits (per combat-formulas.md), boss fights 3–8 minutes by type. HP abundant (Potions cheap), MP is soft constraint. Auto-save (invisible), Faint-and-Fast-Reload (no game over screen), generous save points. Per-act difficulty escalation (Act I learning → Act III gauntlet → optional post-game). Balance validation methodology with damage/duration/economy formulas.

**What's Needed:**
- [x] Target difficulty philosophy (FF6 Accessible, one fixed difficulty, no toggles)
- [x] Expected player level per area/boss (10 areas mapped with target levels and boss levels)
- [x] Expected damage ranges (2–4 hit trash kills per combat-formulas.md, 3–8 min boss fights with worked examples)
- [x] Healing resource pacing (HP abundant, MP soft constraint, dungeon supply budgets per act)
- [x] Anti-frustration features (auto-save, Faint-and-Fast-Reload, flee formula, no missables)
- [x] Balance testing methodology (damage sanity checks, boss duration formula, economy verification, encounter rate checks)

---

### 3.5 Crafting System (Arcanite Forging)

**Status:** COMPLETE
**Priority:** P2
**Files:** `docs/story/crafting.md` (primary); modified: `docs/story/equipment.md`, `docs/story/items.md`, `docs/story/locations.md`, `docs/story/economy.md`; bug fixes: `bestiary/act-ii.md`, `bestiary/act-iii.md`, `dungeons-world.md`, `dungeons-city.md`, `city-carradan.md`
**Depends On:** 1.4 (Items — COMPLETE), 1.5 (Equipment — COMPLETE)
**Completed:** 2026-03-27

**What's Needed:**
- [x] Crafting recipe list — already in equipment.md (8 recipes, 7 infusions) and items.md (13 devices); crafting.md references these
- [x] Material acquisition sources — already in items.md drop tables and economy.md shops
- [x] Crafting UI/interaction model — context-sensitive: devices in field menu, equipment/infusions at forge locations only
- [x] Crafted item tier progression — 5 device tiers (Basic to Ultimate) with AC costs, equipment per act in recipe unlock table
- [x] Integration with Lira's story arc — recipe unlocks track narrative milestones, schematic items gate progression
- [x] Arcanite Charge system (flat 12 AC pool, dual-purpose with battle devices)
- [x] Device loadout rules (5 slots, dungeon locking, save point reconfigure)
- [x] Synergy discovery (NPC hints + Lira reactions, distributed across 7 synergies)
- [x] Pallor malfunction mechanics (15%, Calibrate action, per abilities.md)

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

### 3.7 Full Dialogue Tree & Story Script

**Status:** MISSING
**Priority:** P2
**Files:** None yet — target `docs/story/script/`
**Depends On:** 3.3 (Dialogue System Mechanics), Story & Narrative (outline.md, events.md), NPC Design (npcs.md), Characters (characters.md)
**Reference:** `docs/references/scripts/` — complete game scripts for FF4, FF6, Chrono Trigger, and Secret of Mana. See index.md in each subdirectory.

**What's Needed:**
- [ ] Complete scene-by-scene dialogue script covering all story events in events.md:
  - [ ] Act I scenes (Naxos opening through Ember Vein)
  - [ ] Act II scenes (diplomatic missions, faction cities)
  - [ ] Interlude scenes (Convergence, world collapse)
  - [ ] Act III scenes (Pallor Wastes, final dungeon, ending)
- [ ] NPC dialogue for all towns/locations per npcs.md:
  - [ ] Townsfolk ambient dialogue (changes per act/event flag)
  - [ ] Shop/inn/service NPC lines
  - [ ] Quest-giver dialogue trees (accept/decline/complete)
- [ ] Party banter and optional dialogue:
  - [ ] CT-style party-dependent dialogue variations (who's in the active party changes lines)
  - [ ] Character-specific reactions to key story moments
  - [ ] Optional/examine text for environmental storytelling
- [ ] Dialogue branching for player choices:
  - [ ] Choice points mapped to events.md flags
  - [ ] Branch outcomes and convergence points
  - [ ] Faction reputation dialogue variations
- [ ] Battle dialogue (boss intros, phase transitions, victory/defeat)
- [ ] System text (tutorial prompts, item descriptions, menu help text)
- [ ] Script format specification:
  - [ ] Text box line limits (characters per line, lines per box — per ui-design.md)
  - [ ] Speaker tags, emotion markers, timing cues
  - [ ] Localization-ready structure

**Blocking:** Full game implementation, voice acting (if any), text rendering system, localization

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
| 2026-03-25 | 2.4 Encounter Rates | PARTIAL → COMPLETE. Danger counter model (FF6-derived), per-terrain increments (Monte Carlo-verified), act scaling, 3 formation types with terrain rates, 4-pack tables for all dungeons, flee formula, Ward/Lure Talisman + Infiltrator's Cloak, boss trigger types, safe corridor rule. | — |
| 2026-03-25 | 2.6 Pallor Wastes Oases | MISSING → COMPLETE. 3 Oases with ley ward stones, 12 NPCs, 3 sidequests, Oasis C fall event + Grey Keeper mini-boss, Keeper's Resolve accessory, Valdris Crest key item. | — |
| 2026-03-25 | 2.3 UI & Menu Design | MISSING → COMPLETE. FF6 minimalist SNES pixel art UI. 14 screens designed: battle, main menu, item, equipment, magic, abilities, status, formation, config, shop, dialogue, save/load, Ley Crystal, exploration. 22 unified status icons. ATB visual (from 2.2) and dialogue specs (for 3.3) resolved. Unblocks 3.3. | — |
| 2026-03-26 | 3.4 Difficulty & Balance | MISSING → COMPLETE. FF6 Accessible, one fixed difficulty. 2–4 hit trash (per combat-formulas.md), 3–8 min bosses. HP abundant / MP constraint. Auto-save + Faint-and-Fast-Reload. Per-act escalation. Balance validation methodology (damage/duration/economy/encounter formulas). | — |
| 2026-03-26 | 3.3 Dialogue System Mechanics | PARTIAL → COMPLETE. SNES FF6 pure (no portraits). Sprite emotion system (14 animations), priority stack NPC resolution, party-aware dialogue (key scenes + NPC reactions), dialogue data format (7 entry fields, 8 worked examples). Unblocks 3.7. | — |
| 2026-03-27 | 3.5 Crafting System | SKELETAL → COMPLETE. Context-sensitive crafting (devices in field, equipment at forges). Flat 12 AC pool, 5 device tiers, loadout locking. Synergy discovery (NPC hints + Lira reactions). Pallor malfunction (15%, Calibrate). Design changes applied to equipment.md, items.md, locations.md. | — |
| 2026-03-27 | 3.2 Overworld Traversal | PARTIAL → COMPLETE. FF6 Plus philosophy. Mode 7 presentation, 5 passability types (vehicle tiles deferred to 3.1), uniform on-foot speed, fade-to-black transitions, FF6 battle transitions (Mode 7 zoom + mosaic), location-fixed weather + 6 story overrides. Speed modifiers and zoom removed from geography.md. Unblocks 3.1. | — |
