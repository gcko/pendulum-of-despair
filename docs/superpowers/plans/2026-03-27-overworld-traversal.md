# Overworld Traversal Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write the canonical overworld traversal mechanics document (`docs/story/overworld.md`), apply design changes to geography.md, and update the gap tracker.

**Architecture:** This is a game design documentation task. The deliverable is a story doc consolidating overworld traversal rules (passability, transitions, presentation, weather), plus targeted edits to geography.md (remove speed modifiers and zoom). Content that already exists (biome definitions, encounter rates, named routes) is referenced, not duplicated.

**Tech Stack:** Markdown documentation, git

---

## Chunk 1: Core Document & Design Changes

### Task 1: Write Overworld Document — Header, Presentation, Passability

Write the first half of `docs/story/overworld.md`: overview, Mode 7 presentation, and passability rules.

**Files:**
- Create: `docs/story/overworld.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-27-overworld-traversal-design.md` (Sections 1–3)
- Format reference: `docs/story/dialogue-system.md` (follow same header/blockquote style)
- Cross-reference: `docs/story/geography.md` (terrain descriptions, encounter zones, named routes)
- Cross-reference: `docs/story/biomes.md` (biome definitions, transition gradients, time-of-day)
- Cross-reference: `docs/story/locations.md` (location entries, forge locations)
- Cross-reference: `docs/story/dynamic-world.md` (story-driven world changes)
- SNES reference: `docs/references/overworld-traversal-mechanics.md`

- [ ] **Step 1: Write the document header and overview**

Follow the same style as dialogue-system.md — blockquote intro with related docs, core philosophy, then sections. The overview should:
- State "FF6 Plus" philosophy — SNES-authentic traversal with targeted enhancements
- Explain the consolidation purpose (mechanics doc, references other files for data)
- Note the key design decisions: uniform speed, no zoom, Mode 7 presentation
- List related docs with links (geography.md, biomes.md, dynamic-world.md, locations.md, ui-design.md, combat-formulas.md, difficulty-balance.md)
- List cross-links (dungeons-world.md, dungeons-city.md for dungeon traversal context)

- [ ] **Step 2: Write Section 1 — Overworld Presentation (Mode 7 Style)**

Cover all subsections from spec Section 2:
- Visual rules (Mode 7 perspective, miniaturized sprites, HDMA horizon gradient, fixed camera, biome palette tinting)
- Map screen specification (pause menu access, parchment style, first-visit discovery, dotted routes, current position marker, non-interactive, available from Act I)

- [ ] **Step 3: Write Section 2 — Passability Rules**

Cover all subsections from spec Section 3:
- Movement rules (uniform speed, 4-directional input, collision response — full stop)
- Passability categories table (5 types: passable, impassable, entry trigger, conditional, event trigger)
- Rules (uniform speed, encounter zone mapping, conditional tile messages, vehicle tiles deferred to Gap 3.1, no damage floors on overworld)

- [ ] **Step 4: Verify cross-references**

Check against canonical sources:
- Conditional passability examples match geography.md (Torren requirement for dense Thornmere at geography.md:251, Highcairn winter at geography.md:146)
- Encounter zone reference points to geography.md Section 5 encounter zone table
- Location name banner at 3-tile radius matches geography.md:521
- Map screen doesn't duplicate ui-design.md's existing menu specs
- Biome palette tinting examples match biomes.md definitions

- [ ] **Step 5: Commit**

```bash
git add docs/story/overworld.md
git commit -m "docs(shared): add overworld traversal mechanics doc — sections 1-2

Mode 7 presentation (miniaturized sprites, HDMA horizon, fixed camera),
5 passability types, uniform on-foot speed, menu-accessed map screen."
```

---

### Task 2: Write Overworld Document — Transitions & Weather

Add screen transitions, battle transitions, and weather formalization.

**Files:**
- Modify: `docs/story/overworld.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-27-overworld-traversal-design.md` (Sections 4–5)
- Cross-reference: `docs/story/biomes.md` (music crossfade rules, transition gradients, time-of-day palette shifts)
- Cross-reference: `docs/story/dynamic-world.md` (story-triggered overrides — Act II tensions, Interlude onset, Duskfen water rise, Pallor spread, Epilogue recovery)
- Cross-reference: `docs/story/combat-formulas.md` (danger counter reset)
- SNES reference: `docs/references/overworld-traversal-mechanics.md` (Sections 4, 11)

- [ ] **Step 1: Write Section 3 — Screen Transitions**

Cover all subsections from spec Section 4:
- Overworld → Location (fade to black): 5-step flow (walk onto trigger, name banner, brightness ramp down ~0.5s, load during black, brightness ramp up)
- Within-Location (seamless): edge-scrolling/door-walk-through, no fade unless tileset change, CT/SoM model
- Battle transitions: overworld (Mode 7 zoom-into-ground), dungeon (mosaic pixelation), boss (screen flash + slower dramatic version), post-battle return (fade from black, danger counter reset)
- No information encoding rule (advantage revealed on battle screen, not during transition)
- Region boundary banners: text overlay ~2 seconds, no gameplay interruption, music crossfade rules per biomes.md, Pallor exception (silence then drone), Ley Line Nexus exception (additive hum)

- [ ] **Step 2: Write Section 4 — Weather & Atmospheric Effects (FF6 Plus)**

Cover all subsections from spec Section 5:
- Philosophy: location-fixed + story-triggered overrides, no dynamic cycling, no day/night gameplay cycle
- Note about biomes.md time-of-day palette shifts (cosmetic rendering, no gameplay effect)
- Per-biome atmospherics table (9 biomes with fixed effects, source: biomes.md)
- Story-triggered overrides table (6 triggers with changes and affected areas, source: dynamic-world.md)
- Implementation notes (overrides replace base, transition strips swap at midpoint, color subtraction technique)

- [ ] **Step 3: Verify against canonical sources**

Check:
- Music crossfade timing (3-second transition, 1.5s fade-out/fade-in) matches biomes.md
- Pallor music exception (cut to silence, drone over 5 seconds) matches biomes.md
- Ley Line Nexus additive hum matches biomes.md
- Act II tensions override matches dynamic-world.md (Valdris Crown specific, "1 in 4 dim" ley-lamps)
- Duskfen water rise matches dynamic-world.md:870 (~30% of platforms, not 40%)
- Pallor spread is fixed 10-mile radius per dynamic-world.md:859
- Epilogue details match dynamic-world.md (pale blue sky, spring greens, wildflowers, scaffolding)
- biomes.md time-of-day section exists (biomes.md:791) with 4 states (dawn/day/dusk/night)

- [ ] **Step 4: Commit**

```bash
git add docs/story/overworld.md
git commit -m "docs(shared): add screen transitions and weather formalization

FF6 battle transitions (Mode 7 zoom + mosaic), fade-to-black
exploration entries, FF6 Plus weather (location-fixed + 6 story
overrides). No day/night gameplay cycle."
```

---

### Task 3: Apply Design Changes to geography.md

Update geography.md per the spec's "Design Changes" section.

**Files:**
- Modify: `docs/story/geography.md`

**Reference:**
- Spec Section 6 design changes (remove speed modifiers, remove zoom, add cross-reference)
- Current geography.md terrain entries with speed modifiers: lines 146–255
- Current zoom mechanic: line 520
- Current travel time note: line 672

- [ ] **Step 1: Remove speed modifiers from Valdris Highlands terrain entries**

Search geography.md for "Movement speed reduced by" and "Normal movement speed" in the Valdris Highlands section (~lines 146–148). For each terrain entry:
- Remove the speed modifier clause ("Movement speed reduced by X%", "Normal movement speed")
- Keep encounter rate, enemy type, visibility, and passability descriptions
- Do NOT remove the entire line — only the speed clause

Example transformation:
- Before: "Highland paths: Overworld movement speed reduced by 30% in mountain terrain. Random encounter rate unchanged but enemy types shift to highland beasts (ice wolves, stone elementals)."
- After: "Highland paths: Random encounter rate unchanged but enemy types shift to highland beasts (ice wolves, stone elementals)."

- [ ] **Step 2: Remove speed modifiers from Carradan terrain entries**

Same pattern for Carradan section (~lines 199–203):
- Quarried plains: remove "Normal movement speed."
- Industrial urban: remove "Movement speed normal but" → rewrite to keep channeled navigation note
- Broken Hills: remove "Movement speed reduced by 20%."
- Coastal: remove "Normal speed."
- Caldera interior: remove "Movement speed reduced by 10% due to terrain (stairs, catwalks, narrow streets)." Keep the environmental hazard note.

- [ ] **Step 3: Remove speed modifiers from Thornmere terrain entries**

Same pattern for Thornmere section (~lines 251–255):
- Dense forest: remove "Movement speed reduced by 25%."
- Marshland: remove "Movement speed reduced by 40%."
- Canopy level: remove "Normal movement speed on established bridges and platforms." Keep falling risk note.
- Sacred sites: remove "Movement speed normal."
- Sunstone Ridge: remove "Movement speed reduced by 15%."

- [ ] **Step 4: Remove overworld zoom mechanic**

Find the zoom line at geography.md:520:
```
- **Zoom levels.** Two: normal (1:1 tile view, 20x15 viewport) and zoomed-out (2:1, 40x30 viewport). Zoomed-out is useful for navigation but disables encounter triggers.
```

Replace with:
```
- **Map screen.** The pause menu provides a full-continent map overview showing discovered locations and named routes. See [overworld.md](overworld.md) for map screen specification.
```

- [ ] **Step 5: Update travel time note**

Find the travel time note at geography.md:672:
```
Travel times assume normal overworld movement speed. Terrain modifiers apply.
```

Replace with:
```
Travel times assume normal overworld movement speed (uniform across all terrain per [overworld.md](overworld.md)). Distances are narrative approximations, not exact tile counts.
```

- [ ] **Step 6: Add cross-reference to related docs**

Search geography.md for existing related document references (likely near the top or in the intro). Add a link to `overworld.md` for traversal mechanics. If no related docs section exists, add one after the intro paragraph:

```markdown
> **Related docs:** [overworld.md](overworld.md) (traversal mechanics) |
> [biomes.md](biomes.md) | [locations.md](locations.md) |
> [dynamic-world.md](dynamic-world.md)
```

- [ ] **Step 7: Verify changes are consistent**

- No remaining "Movement speed reduced by" phrases in geography.md
- No remaining "Normal movement speed" phrases in geography.md (except the travel time note which now references uniform speed)
- Zoom mechanic replaced with map screen reference
- Travel time note updated
- Cross-reference to overworld.md added
- Encounter rate data, formation types, passability descriptions all preserved (only speed clauses removed)

- [ ] **Step 8: Commit**

```bash
git add docs/story/geography.md
git commit -m "docs(shared): remove speed modifiers and zoom from geography.md

Uniform on-foot speed per overworld.md (FF6 Plus). Seven terrain
speed tiers removed, zoom mechanic replaced with map screen
reference, travel time note updated."
```

---

### Task 4: Update Gap Tracker

Mark Gap 3.2 as COMPLETE and add progress tracking row.

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (search for "### 3.2 Overworld Traversal")
- Modify: `docs/analysis/game-design-gaps.md` (search for "## Progress Tracking")

- [ ] **Step 1: Update Gap 3.2 section**

- Status: PARTIAL → COMPLETE
- Files: add `docs/story/overworld.md` as primary file; note `docs/story/geography.md` as modified
- Completed date: 2026-03-27
- Check off all "What's Needed" items with resolution descriptions:
  - [x] Tile types with passability rules — 5 categories (passable, impassable, entry trigger, conditional, event trigger), vehicle tiles deferred to Gap 3.1
  - [x] Movement speed per terrain type — resolved: uniform on-foot speed (no per-terrain modifiers), per SNES convention; speed modifiers removed from geography.md
  - [x] Terrain encounter rate modifiers — already defined in geography.md Section 5 (danger counter increments per terrain zone); overworld.md references, does not duplicate
  - [x] Transition between overworld and locations — fade to black (overworld → location), seamless (within-location), FF6 battle transitions (Mode 7 zoom + mosaic)
  - [x] Weather/time-of-day effects — FF6 Plus: location-fixed atmospherics + 6 story-triggered overrides; no day/night gameplay cycle (biomes.md visual palette shifts are cosmetic only)
- Add new completed items:
  - [x] Overworld presentation (Mode 7-style perspective, miniaturized sprites, HDMA horizon gradient)
  - [x] Map screen specification (menu-accessed, parchment style, first-visit location discovery)
  - [x] Design changes applied: geography.md speed modifiers removed, zoom mechanic removed
- Add blocking note: unblocks Gap 3.1 (Transport & Vehicle System — vehicle-conditional tiles)

- [ ] **Step 2: Add progress tracking row**

```
| 2026-03-27 | 3.2 Overworld Traversal | PARTIAL → COMPLETE. FF6 Plus philosophy. Mode 7 presentation, 5 passability types (vehicle tiles deferred to 3.1), uniform on-foot speed, fade-to-black transitions, FF6 battle transitions, location-fixed weather + story overrides. Speed modifiers and zoom removed from geography.md. Unblocks 3.1. | — |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(shared): mark Gap 3.2 complete

Update gap tracker: 3.2 PARTIAL -> COMPLETE. Overworld traversal
mechanics consolidated in overworld.md with design changes to
geography.md. Unblocks 3.1 (Transport)."
```

---

### Task 5: Adversarial Verification

Run verification pass on all changed files.

**Files:**
- Read: `docs/story/overworld.md` (new document)
- Read: `docs/story/geography.md` (modified)
- Read: `docs/story/biomes.md` (cross-reference)
- Read: `docs/story/dynamic-world.md` (cross-reference)
- Read: `docs/story/ui-design.md` (cross-reference for map screen)
- Read: `docs/analysis/game-design-gaps.md` (updated tracker)

- [ ] **Step 1: Uniform speed consistency checks**

- No "Movement speed reduced by" or "Normal movement speed" phrases remain in geography.md (except the updated travel time note)
- overworld.md states uniform speed and does not contradict any remaining geography.md text
- Travel time table in geography.md appendix doesn't reference terrain modifiers

- [ ] **Step 2: Cross-reference checks**

- Every passability example in overworld.md exists in geography.md (Torren requirement, Highcairn winter, Pallor Wastes Act III)
- Every biome in overworld.md's atmospheric table exists in biomes.md
- Every story override in overworld.md matches dynamic-world.md
- Music crossfade rules match biomes.md exactly
- Location name banner 3-tile radius matches geography.md
- Map screen specification doesn't conflict with ui-design.md menu specs
- Battle transition danger counter reset is consistent with geography.md encounter system
- biomes.md time-of-day section acknowledged (not contradicted)
- Zoom mechanic fully removed from geography.md (no orphaned references)

- [ ] **Step 3: Existing doc consistency**

- geography.md terrain entries still make sense after speed clause removal (no orphaned sentence fragments, no dangling punctuation)
- geography.md zoom replacement reads naturally in context
- overworld.md doesn't contradict abilities.md, items.md, or combat-formulas.md
- Gap 3.2 file list includes overworld.md

- [ ] **Step 4: Fix any issues found**

If verification finds problems, fix and commit.

- [ ] **Step 5: Final commit (if fixes needed)**

```bash
git add docs/story/overworld.md docs/story/geography.md
git commit -m "docs(shared): fix overworld traversal verification issues"
```

---

### Task 6: Push and Handoff

- [ ] **Step 1: Run final quality check**

```bash
pnpm lint
git status
```

- [ ] **Step 2: Push to remote**

```bash
git push
```

- [ ] **Step 3: Handoff**

Gap 3.2 is complete. Next steps:
- Run `/create-pr` to open a PR targeting main
- Then `/story-review-loop-cope <PR#> 5` to run antagonistic review
- Remaining gaps: 3.1 (Transport — now unblocked), 3.6 (NG+), 3.7 (Script)
