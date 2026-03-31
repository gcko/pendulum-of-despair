# Accessibility Design Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the canonical accessibility design document and update all
cross-referenced docs to be consistent with the new accessibility features,
including the base resolution change from 256x224 to 320x180.

**Architecture:** Documentation-only. The spec
(`docs/superpowers/specs/2026-03-31-accessibility-design.md`) defines the
accessibility contract. This plan creates the game design doc at
`docs/story/accessibility.md` and updates 7 existing docs for consistency.

**Tech Stack:** Markdown docs only. No code changes.

---

## Chunk 1: Create Canonical Accessibility Doc

### Task 1: Create docs/story/accessibility.md

**Files:**
- Create: `docs/story/accessibility.md`

**Reference:** `docs/superpowers/specs/2026-03-31-accessibility-design.md` (the full spec)

This is the canonical game design document that lives alongside the other
`docs/story/` files. It should be written in the same style as the existing
docs (see `docs/story/save-system.md` or `docs/story/crafting.md` for tone
and format). It is NOT a copy of the spec — it is the designer-facing
document that an implementer reads alongside combat-formulas.md, ui-design.md,
etc.

- [ ] **Step 1: Read the spec and two reference docs for style**

Read these files to understand the target format:
- `docs/superpowers/specs/2026-03-31-accessibility-design.md` (full spec)
- `docs/story/save-system.md` (style reference — similar scope, sections + tables)
- `docs/story/difficulty-balance.md` (style reference — anti-frustration features)

- [ ] **Step 2: Write docs/story/accessibility.md**

Use this heading structure (adapt spec content to docs/story/ voice):

```markdown
# Accessibility

> Canonical reference for accessibility features: display scaling,
> color-blind support, timing accommodations, input rebinding, motion
> sensitivity, and audio captions.

## 1. Display & Scaling
-- Spec Section 1. Base resolution 320x180 (replaces 256x224).
-- Integer scaling table (720p/1080p/1440p/4K).
-- Tile viewport: 20x11 full tiles + 4px scrolling headroom.
-- Rendering rules (nearest-neighbor, snap-to-pixel, integer scaling).
-- High-Res Text toggle (separate native-res canvas layer).
-- Link to: ui-design.md.

## 2. Color-Blind Support
-- Spec Section 2. Always-on enhancements for all players
-- (corruption texture, particle shift, HP bar cracks).
-- Color-blind mode toggle (Deutan-Protan / Tritan).
-- Palette swap tables for both modes.
-- Config preview description.
-- What does NOT change (Pallor desaturation, UI chrome).
-- Link to: visual-style.md, ui-design.md.

## 3. Patience Mode
-- Spec Section 3. New Config toggle.
-- Rules: forces Wait + speed 6 + top-level command pauses gauges.
-- Status timer pause behavior.
-- Config interaction (overrides ATB Mode/Battle Speed, restores on disable).
-- Link to: combat-formulas.md, difficulty-balance.md.

## 4. Input Accessibility
-- Spec Section 4. Full keyboard rebinding.
-- Key Config screen description.
-- Rebindable actions list. Default layout. Conflict detection.
-- Gamepad: standard mapping via Godot Input Map.
-- One-handed play note (supported via rebinding, no dedicated mode).
-- No mouse support.
-- Link to: ui-design.md.

## 5. Motion Sensitivity
-- Spec Section 5. Reduce Motion master toggle.
-- What it changes (flashes, transitions, Mode 7, shake, icon blinks).
-- Granular controls table (Screen Shake, Mode 7 Intensity 1-6,
-- Flash Intensity, Transition Style).
-- Master toggle behavior (sets safe defaults, restores on disable).
-- Link to: overworld.md, ui-design.md.

## 6. SFX Captions
-- Spec Section 6. SFX Captions toggle.
-- Captioned events list (~8-10 types).
-- What is NOT captioned.
-- No separate subtitle system needed.
-- Link to: battle-dialogue.md.

## 7. Config Menu Summary
-- Complete table of all accessibility settings (new + existing).
-- All settings are global (per save-system.md Section 2).
-- Key Config sub-screen note.
```

Cross-link to these existing docs throughout:
- `ui-design.md` for screen layout, Config menu, input mapping
- `save-system.md` for global config storage
- `combat-formulas.md` for ATB/Wait mode behavior
- `difficulty-balance.md` for anti-frustration philosophy
- `visual-style.md` for Pallor desaturation, color usage
- `overworld.md` for Mode 7 effects
- `script/battle-dialogue.md` for system text

- [ ] **Step 3: Verify completeness**

Check that every item from the spec's Section 8 cross-doc table is
addressed in the new doc. Check that every section from the spec has
a corresponding section in the game design doc.

- [ ] **Step 4: Commit**

```bash
git add docs/story/accessibility.md
git commit -m "docs(story): add accessibility design document (gap 4.4)"
```

---

## Chunk 2: Update Cross-Referenced Docs

These tasks update existing docs to be consistent with the accessibility
design. Tasks 2-8 are independent and can run in parallel.

### Task 2: Update ui-design.md — Resolution + Config + Transitions

**Files:**
- Modify: `docs/story/ui-design.md`

This is the largest cross-doc update. Multiple sections need changes.

- [ ] **Step 1: Read current ui-design.md Sections 1, 10.3, 13, and 15**

Read `docs/story/ui-design.md` to understand the current state of:
- Section 1 (~lines 16-45): rendering specs, base resolution, modern concessions
- Section 10.3 (~lines 700-750): Config screen layout and options
- Section 13 (~lines 854-940): Save/Load screen (already updated in prior PR)
- Section 15.6 (~line 1034): Save point interaction

- [ ] **Step 2: Update Section 1 — Base Resolution**

Change the base resolution from 256x224 to 320x180. Note: the file
uses Unicode multiplication sign (×) not ASCII (x). Read the file
first and match the exact characters when editing.
- Line 19-20: Replace "256×224 (SNES native)" with "320×180 (16:9
  pixel art standard)"
- Line 20: Replace the scaling example (3× = 768×672) with "6× =
  1920×1080 at 1080p). Clean integer scaling at 720p (4×), 1080p
  (6×), 1440p (8×), 4K (12×)."
- Line ~43: Already updated to "target display resolution" in prior PR.
  No further change needed.
- Add a note about the tile viewport: "20x11 complete tile rows + 4px
  partial row at the top or bottom edge (scrolling headroom)."
- Add a note about the High-Res Text toggle: "An optional 'High-Res
  Text' accessibility setting renders UI text on a separate
  native-resolution canvas layer. See [accessibility.md](accessibility.md)."

- [ ] **Step 3: Update Section 10.3 — Config Screen**

Add the following new settings to the Config screen options list. Add
them in a clearly labeled "Accessibility" subsection:
- Patience Mode: On / Off (default Off)
- Color-Blind Mode: Off / Deutan-Protan / Tritan (default Off)
- High-Res Text: On / Off (default Off)
- Reduce Motion: On / Off (default Off)
- Flash Intensity: Off / Reduced / Full (default Full)
- Transition Style: Classic / Simple (default Classic)
- SFX Captions: On / Off (default Off)

Also add these missing existing settings (currently in save-system.md
but not in ui-design.md Config layout):
- Screen Shake: On / Off (default On)
- Mode 7 Intensity: 1-6 (default 6)

Add a "Key Config" entry that opens a sub-screen for keyboard rebinding.

Add a note under the Color-Blind Mode setting: "Selecting a color-blind
mode shows a live preview panel with a sample HP bar, 4-5 status icons,
and a mini Pallor corruption preview. The player can verify the mode
works for them before leaving Config."

- [ ] **Step 4: Add transition style note**

In the section describing battle transitions (~lines 1024-1029), add a
note: "When Transition Style is set to Simple (see Config), all mosaic
dissolve and Mode 7 zoom transitions are replaced with a 0.5s fade to
black. Boss flash-then-transition is also replaced with fade. See
[accessibility.md](accessibility.md)."

- [ ] **Step 5: Verify and commit**

Re-read the modified sections. Confirm resolution, Config settings, and
transition note are all consistent with the spec.

```bash
git add docs/story/ui-design.md
git commit -m "docs(story): update ui-design for 320x180 resolution and accessibility config"
```

---

### Task 3: Update save-system.md — Global Config List

**Files:**
- Modify: `docs/story/save-system.md` Section 2 (Configuration)

- [ ] **Step 1: Read the current Section 2**

Read `docs/story/save-system.md` — find the Configuration section (Section 2,
around lines 75-90) which lists global config fields.

- [ ] **Step 2: Update the config field list**

The current list has: Battle speed (1-6), ATB mode (Active/Wait), Text
speed, Sound volume (Music/SFX), Screen shake toggle, Mode 7 rotation
intensity.

Add the missing existing settings to align with ui-design.md:
- Battle Cursor (Reset / Memory)
- Window Color (RGB sliders)
- Sound (Stereo / Mono)

Add the new accessibility settings:
- Patience Mode (On / Off)
- Color-Blind Mode (Off / Deutan-Protan / Tritan)
- High-Res Text (On / Off)
- Reduce Motion (On / Off)
- Flash Intensity (Off / Reduced / Full)
- Transition Style (Classic / Simple)
- SFX Captions (On / Off)

Reference `accessibility.md` for details on the new settings.

- [ ] **Step 3: Commit**

```bash
git add docs/story/save-system.md
git commit -m "docs(story): add accessibility settings to global config list"
```

---

### Task 4: Update combat-formulas.md — Patience Mode

**Files:**
- Modify: `docs/story/combat-formulas.md` (ATB section)

- [ ] **Step 1: Read the ATB section**

Read `docs/story/combat-formulas.md` — find the ATB Gauge System section
and the Wait mode behavior description.

- [ ] **Step 2: Add Patience Mode rules**

After the existing Wait mode description, add a "Patience Mode" subsection:

```markdown
### Patience Mode (Accessibility)

An accessibility option (see [accessibility.md](accessibility.md)) that
eliminates all time pressure from combat. When enabled:

- ATB Mode forced to Wait
- Battle Speed forced to 6 (slowest)
- Top-level command menu (Attack/Magic/Ability/Item/Defend/Flee) also
  pauses all ATB gauges — this extends Wait mode, which only pauses
  during sub-menus (Magic, Item, Ability lists, target selection)
- Real-time status timers (Stop countdown, buff durations) pause during
  any player decision point

The ATB system still determines turn order. Patience Mode removes time
pressure without changing combat mechanics.
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/combat-formulas.md
git commit -m "docs(story): add Patience Mode to ATB section"
```

---

### Task 5: Update difficulty-balance.md — Patience Mode as Anti-Frustration

**Files:**
- Modify: `docs/story/difficulty-balance.md` (anti-frustration section)

- [ ] **Step 1: Read the anti-frustration section**

Read `docs/story/difficulty-balance.md` — find Section 5 (anti-frustration
features) where auto-save, save density, flee, and wipe recovery are listed.

- [ ] **Step 2: Add Patience Mode**

Add a new subsection after the existing anti-frustration features
(after Party Wipe Recovery):

```markdown
### 5.6 Patience Mode

An accessibility option that eliminates all time pressure from ATB
combat. Forces Wait mode + slowest speed + pauses gauges during ALL
player decisions (including top-level command menu). See
[accessibility.md](accessibility.md) and
[combat-formulas.md](combat-formulas.md) for full rules.

This is the accessibility floor for motor-impaired players. Combined
with Battle Speed 6 and Wait mode, no time-sensitive decision is ever
required.
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(story): add Patience Mode to anti-frustration features"
```

---

### Task 6: Update visual-style.md — Corruption Cues + Color-Blind Palettes

**Files:**
- Modify: `docs/story/visual-style.md`

- [ ] **Step 1: Read the Pallor corruption section**

Read `docs/story/visual-style.md` — find the sections about Pallor
corruption visual effects and color desaturation.

- [ ] **Step 2: Add always-on corruption enhancements**

In or after the Pallor corruption section, add:

```markdown
### Corruption Visual Enhancements (Always On)

These cues supplement desaturation and are active for all players
(not gated by a setting). They make corruption tangible, not just grey.

- **Texture overlay:** Corrupted areas gain subtle grain/static that
  intensifies with corruption level. Dungeon grey zones get visible
  crack patterns on tiles.
- **Particle type shift:** Healthy areas have warm ambient particles
  (dust motes, fireflies, heat shimmer). Corrupted areas replace these
  with cold particles (grey ash, static sparks, drifting fragments).
- **HP bar shape cue:** Below 25% max HP, the bar gains a segmented /
  cracked appearance in addition to the green-to-red color shift.

See [accessibility.md](accessibility.md) Section 2 for color-blind
mode palette swaps.
```

- [ ] **Step 3: Add color-blind palette swap reference**

Add a brief note (not full tables — those live in accessibility.md):

```markdown
### Color-Blind Mode Palettes

Two color-blind modes are available in Config:
- **Deutan-Protan:** red/green pairs swap to blue/orange (HP bar,
  status icons, Poison color)
- **Tritan:** blue/yellow pairs shift to green/magenta

See [accessibility.md](accessibility.md) Section 2 for full palette
swap tables and what does NOT change.
```

- [ ] **Step 4: Commit**

```bash
git add docs/story/visual-style.md
git commit -m "docs(story): add always-on corruption cues and color-blind palette references"
```

---

### Task 7: Update overworld.md — Reduce Motion Mode 7

**Files:**
- Modify: `docs/story/overworld.md` (Mode 7 section)

- [ ] **Step 1: Read the Mode 7 section**

Read `docs/story/overworld.md` — find the Mode 7 presentation section
and the battle transition descriptions.

- [ ] **Step 2: Add Reduce Motion note**

After the Mode 7 description, add:

```markdown
**Reduce Motion alternative:** When "Reduce Motion" is enabled in Config,
Mode 7 intensity is set to minimum (level 1 of 6) — the overworld still
uses perspective view but with flattened foreshortening. The Mode 7
zoom-into-ground encounter transition is replaced with a 0.5s fade to
black. See [accessibility.md](accessibility.md) Section 5.
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/overworld.md
git commit -m "docs(story): add Reduce Motion note to Mode 7 section"
```

---

### Task 8: Update battle-dialogue.md — SFX Caption Text

**Files:**
- Modify: `docs/story/script/battle-dialogue.md`

- [ ] **Step 1: Read the system text section**

Read `docs/story/script/battle-dialogue.md` — find the System Text
section where save system text, tutorials, and notifications live.

- [ ] **Step 2: Add SFX caption text**

Add a new subsection in the System Text area:

```markdown
### SFX Captions (Accessibility)

When SFX Captions are enabled in Config, these text labels appear
briefly (2-3s) in the lower corner of the screen:

- [Save Point] — when near a save crystal
- [Encounter] — when the encounter trigger fires
- [Level Up] — on level gain
- [Victory] — battle end
- [Item] — item obtained from chest or pickup
- [Quest Complete] — sidequest completed
- [Phase Change] — boss enters new phase
- [Alert] — alarm or environmental warning

See [accessibility.md](../accessibility.md) Section 6.
```

Note: the link uses `../accessibility.md` because battle-dialogue.md
is in `docs/story/script/` (one level deeper).

- [ ] **Step 3: Commit**

```bash
git add docs/story/script/battle-dialogue.md
git commit -m "docs(story): add SFX caption text for accessibility"
```

---

## Chunk 3: Update Gap Analysis and Final Verification

### Task 9: Update Gap Analysis Doc

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (Gap 4.4 status + progress table)

- [ ] **Step 1: Read the current Gap 4.4 section**

Read `docs/analysis/game-design-gaps.md` — find the 4.4 section
(around line 683) and the progress tracking table at the end.

- [ ] **Step 2: Update Gap 4.4 status**

Change status from `MISSING` to `COMPLETE`. Add completion date
(`2026-03-31`) and summary.

Update checklist items where the spec intentionally diverged from the
original gap description before checking them off:
- "High-contrast mode for text and UI elements" → update to "High-Res
  Text toggle (native-resolution text layer) + always-on corruption
  texture/particle cues for visual distinction"
- "Text size scaling options (SNES pixel font...)" → update to
  "Addressed by 320×180 base resolution (clean integer scaling at all
  standard resolutions) + High-Res Text toggle for accessibility"
- "Optional turn-by-turn mode" → update to "Patience Mode (pauses all
  gauges during any player decision, preserving ATB turn order)"

Then check off all items.

- [ ] **Step 3: Add progress tracking row**

Add a new row to the Progress Tracking table:

```
| 2026-03-31 | 4.4 Accessibility Design | MISSING → COMPLETE. Base resolution 320x180 (replaces 256x224), clean integer scaling. Color-blind support (Deutan-Protan/Tritan modes + always-on corruption cues). Patience Mode (zero time pressure ATB). Full keyboard rebinding. Reduce Motion (master toggle + granular controls). SFX captions. High-Res Text toggle. Cross-doc updates to ui-design.md, save-system.md, combat-formulas.md, difficulty-balance.md, visual-style.md, overworld.md, battle-dialogue.md. | — |
```

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(story): mark gap 4.4 Accessibility Design as COMPLETE"
```

---

### Task 10: Cross-Reference Verification

**Files:**
- Read only (verification pass, no edits expected)

- [ ] **Step 1: Verify accessibility.md cross-links**

Read `docs/story/accessibility.md` and check that every cross-reference
link points to an existing file:
- ui-design.md, save-system.md, combat-formulas.md, difficulty-balance.md,
  visual-style.md, overworld.md, battle-dialogue.md

- [ ] **Step 2: Verify cross-doc edits are consistent**

Spot-check that the 7 updated docs all agree on:
- Base resolution is 320x180 (not 256x224)
- Patience Mode rules match between combat-formulas.md and accessibility.md
- Config settings list in save-system.md includes all new settings
- Color-blind mode names are consistent (Deutan-Protan, Tritan)
- Mode 7 Intensity range is 1-6 everywhere
- Transition Style values are Classic/Simple everywhere

- [ ] **Step 3: Verify no broken markdown links**

```bash
grep -roh '\[[^]]*\]([^)]*\.md[^)]*)' docs/story/accessibility.md | sort -u
```

Confirm each linked file exists.

- [ ] **Step 4: Create beads issue if any inconsistencies found**

If verification found issues not covered by Tasks 2-8, create a beads
issue. Skip if verification found no issues.
