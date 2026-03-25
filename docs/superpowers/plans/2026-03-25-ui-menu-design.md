# UI & Menu Design Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/story/ui-design.md` — the canonical UI design document for Pendulum of Despair, covering all player-facing interfaces.

**Architecture:** Single markdown document organized by screen type. All content derived from the approved spec at `docs/superpowers/specs/2026-03-25-ui-menu-design.md`. Cross-references verified against canonical story docs.

**Tech Stack:** Markdown documentation (no code changes).

---

## Chunk 1: Foundation and Battle Screen

### Task 1: Create ui-design.md with Design Philosophy

**Files:**
- Create: `docs/story/ui-design.md`

**Context:** This is the foundational section establishing the SNES pixel art philosophy, window style, color palette, font sizes, and the unified status effect icon system. All subsequent sections build on these standards.

**Cross-reference files to verify against:**
- `docs/story/visual-style.md` — color philosophy, SNES constraints
- `docs/story/magic.md` lines 1388–1413 — canonical status effect list
- `docs/story/combat-formulas.md` — ATB mechanics referenced

- [ ] **Step 1: Create the file with front matter and Section 1 (Design Philosophy)**

Write the following sections from the spec:
- Document header with cross-reference table
- Section 1.1: SNES Pixel Art First (viewport 256×224, nearest-neighbor, pixel borders, pixel font, pixel icons/bars, no alpha, portrait spec)
- Section 1.2: Modern Concessions (sub-pixel text, HP/MP bars addition)
- Section 1.3: FF6 Minimalist Windows (dark navy `#00003c`, border `#5566aa`, sharp corners, constant across biomes)
- Section 1.4: Color Palette (full table from spec — 18 entries)
- Section 1.5: Font Sizes (6 context rows)
- Section 1.6: Unified Status Effect Icon System (placement rules, 12 negative icons, 10 positive icons — all from magic.md canonical list)

Verify: Every status effect in the icon tables exists in magic.md lines 1390–1413. No phantom statuses (no "Freeze", no "Depower").

- [ ] **Step 2: Verify cross-references**

Read `docs/story/visual-style.md` and confirm:
- Window style claims match (constant across biomes, no per-location theming)
- Color philosophy alignment (saturation = hope)
- SNES palette constraints (256 colors/scene)

Read `docs/story/magic.md` lines 1388–1413 and confirm:
- All 22 status effects have icons
- Status names match exactly (Quickstep not "Haste", Ironhide not "Protect", etc.)
- Type classification correct (Slow is Negative, not Positive)

- [ ] **Step 3: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add ui-design.md with design philosophy and color system"
```

---

### Task 2: Battle Screen Layout

**Files:**
- Modify: `docs/story/ui-design.md`

**Context:** The battle screen is the most complex UI surface. Classic FF6 layout: enemies top ~65%, party panel + commands bottom ~35%. ATB gauge is a horizontal bar inline with each character row.

**Cross-reference files to verify against:**
- `docs/story/combat-formulas.md` — ATB fill rate, battle speed (1=fastest, 6=slowest), Active/Wait mode, row system
- `docs/story/characters.md` lines 147–162 — default row assignments (Sable is Front)
- `docs/story/abilities.md` — character command names (Sable = "Tricks", not "Filch")

- [ ] **Step 1: Write Section 2 (Battle Screen)**

Include all subsections from the spec:
- 2.1 Layout (ASCII diagram)
- 2.2 Enemy Area (sprites center-to-right, names, damage numbers)
- 2.3 Party Panel (status icons above name, HP/MP bars + numbers, ATB bar, 5th row for guest NPCs)
- 2.4 Command Panel (6 commands, character-specific 3rd slot — use correct names: Tricks not Filch)
- 2.5 Battle Message Area (top-center, auto-fade 1.5s)
- 2.6 Target Selection (blinking arrow, multi-target "All" indicator)
- 2.7 Battle Sub-Menus (Magic, Item, character-specific overlays with correct details per character)
- 2.8 Battle Results Screen (XP, gold, items, level-up)
- 2.9 Maren's Weave Gauge (purple bar below MP, battle-only)
- 2.10 Scroll Indicators (blinking arrows, no scrollbar)

- [ ] **Step 2: Verify battle speed scale**

Read `docs/story/combat-formulas.md` lines 505–516 and confirm: Battle Speed 1 = Fastest (factor 6), Battle Speed 6 = Slowest (factor 1). Ensure ui-design.md matches.

- [ ] **Step 3: Verify character command names**

Read `docs/story/abilities.md` and confirm each character's command name:
- Edren → Bulwark
- Cael → Rally
- Lira → Forgewright
- Torren → Spiritcall
- Sable → Tricks (NOT Filch)
- Maren → Arcanum

- [ ] **Step 4: Verify row defaults**

Read `docs/story/characters.md` lines 147–158 and confirm: Edren F, Cael F, Lira F, Sable F, Torren B, Maren B.

- [ ] **Step 5: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add battle screen layout to ui-design.md"
```

---

## Chunk 2: Menu Screens

### Task 3: Main Menu and Item Screen

**Files:**
- Modify: `docs/story/ui-design.md`

**Context:** The main menu is the hub — party left (~68%), commands right (~28%), info boxes bottom. The item screen uses FF6's tab system (USE/ARRANGE/KEY).

**Cross-reference files to verify against:**
- `docs/story/equipment.md` — 5 equipment slots (weapon, head, body, accessory, Ley Crystal)
- `docs/story/items.md` — item categories and stack limits

- [ ] **Step 1: Write Section 3 (Main Menu)**

Include:
- 3.1 Access (Start/Menu button, game pauses)
- 3.2 Layout (ASCII diagram — party left, commands right, info bottom)
- 3.3 Party Panel (32×32 portraits, name/LV, HP/MP bars + numbers, status icons, dividers)
- 3.4 Command Panel (9 commands: Item, Magic, Abilities, Equip, Crystal, Status, Formation, Config, Save — character select flow for 5 of them)
- 3.5 Info Boxes (location bottom-left, time + gold bottom-right)

- [ ] **Step 2: Write Section 4 (Item Screen)**

Include:
- 4.1 Access
- 4.2 Layout (ASCII diagram)
- 4.3 Tab Bar (USE/ARRANGE/KEY, shoulder button switching, Arrange sort cycling)
- 4.4 Description Area (inline status icons)
- 4.5 Item List (two-column, 8×8 icons, colon-prefix quantities)
- 4.6 Use Flow (single-target character select overlay)

- [ ] **Step 3: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add main menu and item screen to ui-design.md"
```

---

### Task 4: Equipment and Ley Crystal Screens

**Files:**
- Modify: `docs/story/ui-design.md`

**Context:** Equipment screen follows FF6's EQUIP/OPTIMUM/REMOVE/EMPTY pattern. Ley Crystal screen is adapted from FF6's Relic screen.

**Cross-reference files to verify against:**
- `docs/story/equipment.md` — 5 slots, per-character restrictions, Forgewright recipes
- `docs/story/progression.md` — Ley Crystal system (18 crystals, 5 levels, XP-based)

- [ ] **Step 1: Write Section 5 (Equipment Screen)**

Include:
- 5.1 Access (Main Menu → Equip → character select)
- 5.2 Layout (ASCII diagram)
- 5.3 Sub-Command Tabs (EQUIP/OPTIMUM/REMOVE/EMPTY)
- 5.4 Equipment Slots (5 rows with current item names)
- 5.5 Available Equipment List (icons, "E" indicator, Remove option)
- 5.6 Stat Comparison (8 stats + 2 derived, green/red arrows, live update)
- 5.7 Element/Status Info (bottom line with inline icons)

- [ ] **Step 2: Write Section 14 (Ley Crystal Screen)**

Include:
- 14.1 Access (Main Menu → Crystal → character select)
- 14.2 Layout (ASCII diagram)
- 14.3 Details (crystal slot with XP bar, description with effects/negatives/next level, available list with "E" indicators, stat comparison with elemental affinity icons)

- [ ] **Step 3: Verify equipment slots**

Read `docs/story/equipment.md` and confirm 5 slots: Weapon, Head, Body, Accessory, Ley Crystal.

- [ ] **Step 4: Verify Ley Crystal count and level system**

Read `docs/story/progression.md` and confirm: 18 crystals, 5 XP-based levels, negative effects.

- [ ] **Step 5: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add equipment and Ley Crystal screens to ui-design.md"
```

---

### Task 5: Magic, Abilities, and Status Screens

**Files:**
- Modify: `docs/story/ui-design.md`

**Context:** Magic screen shows spells in a two-column grid with MP costs. Abilities screen uses the same layout but with character-specific resource displays. Status screen is a full stat sheet.

**Cross-reference files to verify against:**
- `docs/story/magic.md` — spell structure, MP tiers
- `docs/story/abilities.md` — per-character ability mechanics (Tricks cooldowns, Weave Gauge, Favor pips)
- `docs/story/progression.md` — 8 core stats, derived stats, stat caps

- [ ] **Step 1: Write Section 6 (Magic Screen)**

Include:
- 6.1 Access
- 6.2 Layout (ASCII diagram)
- 6.3 Details (description area with inline icons, character info with portrait, two-column spell grid with MP cost, field use flow)

- [ ] **Step 2: Write Section 7 (Abilities Screen)**

Include:
- 7.1 Access
- 7.2 Layout (same as Magic)
- 7.3 Character-Specific Displays table (6 characters with unique UI elements: Bulwark stances, Forgewright quantities, Spiritcall Favor pips, Tricks cooldown pips + front-row indicators, Arcanum Weave Gauge, Rally MP costs)

- [ ] **Step 3: Write Section 8 (Status Screen)**

Include:
- 8.1 Access
- 8.2 Layout (ASCII diagram)
- 8.3 Details (portrait + identity, 8 core stats + 3 derived with equipment bonuses, battle commands, equipment summary with elemental icons)

- [ ] **Step 4: Verify stat list**

Read `docs/story/progression.md` and confirm: HP, MP, ATK, DEF, MAG, MDEF, SPD, LCK (8 core) + EVA%, MEVA%, Crit% (3 derived).

- [ ] **Step 5: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add magic, abilities, and status screens to ui-design.md"
```

---

## Chunk 3: Remaining Screens and Integration

### Task 6: Formation, Config, and Shop Screens

**Files:**
- Modify: `docs/story/ui-design.md`

**Context:** Formation screen handles party order and row assignment. Config screen is FF6-style label/value pairs. Shop interface uses Buy/Sell split.

**Cross-reference files to verify against:**
- `docs/story/characters.md` lines 147–158 — default rows
- `docs/story/combat-formulas.md` — battle speed, ATB mode
- `docs/story/economy.md` — sell price formula (50% of buy)

- [ ] **Step 1: Write Section 9 (Formation Screen)**

Include:
- 9.1 Access
- 9.2 Layout (ASCII diagram — active 4 + reserve, Sable as F not B)
- 9.3 Details (walking sprites, row indicators, reorder by swap, shoulder button row toggle, defaults, restrictions, guest lock icon, Cael absence note, party lead)

- [ ] **Step 2: Write Section 10 (Config Screen)**

Include:
- 10.1 Access
- 10.2 Layout (ASCII diagram with battle speed 1=fast 6=slow)
- 10.3 Settings table (8 settings with values, defaults, notes — window color RGB 0–31 with 5-bit→8-bit mapping)

- [ ] **Step 3: Write Section 11 (Shop Interface)**

Include:
- 11.1 Access
- 11.2 Entry prompt (Buy/Sell/Exit)
- 11.3 Buy Mode (ASCII diagram, gold display, description with equip compatibility sprites, inventory with icons/prices/owned quantity, stat comparison with shoulder-button party cycling, quantity select)
- 11.4 Sell Mode (sell prices at 50%, "E" indicator with confirm prompt, key items hidden)

- [ ] **Step 4: Verify sell price formula**

Read `docs/story/economy.md` and confirm sell price = 50% of buy price.

- [ ] **Step 5: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add formation, config, and shop screens to ui-design.md"
```

---

### Task 7: Dialogue, Save/Load, and Exploration UI

**Files:**
- Modify: `docs/story/ui-design.md`

**Context:** Dialogue system is full-width bottom-anchored with typewriter effect. Save/Load uses enhanced FF6 with all 4 party members per slot. Exploration has no HUD.

**Cross-reference files to verify against:**
- `docs/story/visual-style.md` — dialogue box constancy, Pallor doesn't touch dialogue
- Spec save data: `packages/shared/src/types/game.ts` — 3 save slots

- [ ] **Step 1: Write Section 12 (Dialogue & Text System)**

Include:
- 12.1 Dialogue Box (full-width, bottom-anchored, 3 lines, no portraits — intentional decision documented, name label inset)
- 12.2 Text Rendering (pixel font typewriter, 4 speed settings with chars/sec, confirm to skip, bouncing advance arrow)
- 12.3 Multi-Page Dialogue (no scrollback)
- 12.4 Choice Prompts (2–4 vertical options, cancel selects bottom)
- 12.5 NPC Interaction Model (single interaction, re-talk repeats, event-flag changes)

- [ ] **Step 2: Write Section 13 (Save/Load Screen)**

Include:
- 13.1 Access (menu Save at save points, title Load)
- 13.2 Layout (enhanced FF6, 3 slots — retro-fidelity decision documented, revisit with Gap 3.6)
- 13.3 Populated Slot (header: location/time/gold; party: 4 walking sprites with name/LV/tiny HP bar)
- 13.4 Empty Slot ("Empty" in muted grey)
- 13.5 Save Flow (overwrite confirm, pixel sparkle animation)
- 13.6 Load Screen (identical layout, empty slots skipped)
- 13.7 Save Points (glowing crystal sprite, 2-frame shimmer, walk-on opens save)

- [ ] **Step 3: Write Section 15 (Exploration UI)**

Include:
- 15.1 No Persistent HUD
- 15.2 Location Name Flash (center-top, 0.5s fade in, 2s hold, 0.5s fade out, no repeat)
- 15.3 Interactable Objects (no prompts, visual sprite design)
- 15.4 Treasure Chests (open animation, center-screen found message)
- 15.5 Screen Transitions (table: fade to black, mosaic dissolve, reverse dissolve, instant menu)
- 15.6 Save Points (glow intensifies on approach)

- [ ] **Step 4: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add dialogue, save/load, and exploration UI to ui-design.md"
```

---

### Task 8: Pallor Integration, Input Mapping, and Gap Update

**Files:**
- Modify: `docs/story/ui-design.md`
- Modify: `docs/analysis/game-design-gaps.md`

**Context:** Final sections: Pallor narrative integration (UI never desaturates), input mapping, and implementation notes. Then update the gap analysis tracker.

**Cross-reference files to verify against:**
- `docs/story/visual-style.md` — Pallor desaturation rules, character sprite color persistence
- `docs/analysis/game-design-gaps.md` — Gap 2.3 status update

- [ ] **Step 1: Write Section 16 (Pallor Narrative Integration)**

Include:
- UI windows never desaturate (player's anchor)
- Despair status dims character name slightly + grey down-arrow icon
- Act III: party sprites in color, world greying, UI contrast reinforces theme

- [ ] **Step 2: Write Section 17 (Input Mapping)**

Include: Full input table (8 actions × keyboard + gamepad columns).

- [ ] **Step 3: Write Section 18 (Implementation Notes)**

Include:
- 18.1 Cross-reference table (12 system references)
- 18.2 Deferred Items Resolved (ATB visual from 2.2, dialogue specs for 3.3)
- 18.3 What This Does NOT Cover (art assets, sound, animation frames, title/game over, bestiary viewer)

- [ ] **Step 4: Full document verification**

Re-read the entire `docs/story/ui-design.md` and verify:
- No references to "Filch" as a command name (should be "Tricks")
- Battle Speed 1 = Fastest, 6 = Slowest everywhere
- Sable defaults to Front row everywhere
- All 22 status effects from magic.md present in icon table
- No alpha transparency values (use solid SNES palette colors)
- All cross-references point to real sections in real files

- [ ] **Step 5: Update gap analysis**

In `docs/analysis/game-design-gaps.md`:
- Change Gap 2.3 status from MISSING to COMPLETE
- Check off all checklist items
- Add completion date (2026-03-25) and description
- Add progress tracking row
- Note that this unblocks Gap 3.3 (Dialogue System) and resolves Gap 2.2's ATB visual deferral

- [ ] **Step 6: Commit**

```bash
git add docs/story/ui-design.md docs/analysis/game-design-gaps.md
git commit -m "docs(shared): complete ui-design.md and mark Gap 2.3 COMPLETE"
```
