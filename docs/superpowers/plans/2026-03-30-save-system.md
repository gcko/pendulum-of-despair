# Save System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the canonical save system design document and update all
cross-referenced docs to be consistent with the new save system rules.

**Architecture:** Documentation-only. The spec
(`docs/superpowers/specs/2026-03-30-save-system-design.md`) defines the
save system contract. This plan creates the game design doc at
`docs/story/save-system.md` and updates 7 existing docs for consistency.

**Tech Stack:** Markdown docs only. No code changes.

---

## Chunk 1: Create Canonical Save System Doc

### Task 1: Create docs/story/save-system.md

**Files:**
- Create: `docs/story/save-system.md`

**Reference:** `docs/superpowers/specs/2026-03-30-save-system-design.md` (the full spec)

This is the canonical game design document that lives alongside the other
`docs/story/` files. It should be written in the same style as the existing
docs (see `docs/story/combat-formulas.md` or `docs/story/crafting.md` for
tone and format). It is NOT a copy of the spec — it is the designer-facing
document that an implementer reads alongside combat-formulas.md, items.md,
etc.

- [ ] **Step 1: Read the spec and two reference docs for style**

Read these files to understand the target format:
- `docs/superpowers/specs/2026-03-30-save-system-design.md` (full spec)
- `docs/story/crafting.md` (style reference — similar scope)
- `docs/story/combat-formulas.md` (style reference — data-heavy)

- [ ] **Step 2: Write docs/story/save-system.md**

Create the file with these sections, drawing content from the spec:

Use this heading structure (adapt spec content to docs/story/ voice):

```markdown
# Save System

> Canonical reference for save/load behavior, slot management, auto-save,
> death recovery, and save data structure. Engine-agnostic — specifies
> the contract for implementation.

## 1. Design Principle
-- Spec Section 1. "Save choices and progress, derive the rest."
-- Include the persisted vs derived tables verbatim from spec.

## 2. Configuration
-- Spec Section 2. Global config is separate from saves.
-- List all config fields (battle speed, ATB mode, text speed, etc.).

## 3. Save Data Schema
-- Spec Section 3, all 9 groups. Copy the field definitions from the
-- spec (party, formation, inventory, crafting, leyCrystals, world,
-- quests, completion, meta) with their pseudo-schema notation.
-- Adapt prose but keep field names and types exact.

## 4. Save Point Interaction
-- Spec Section 4. 3-option menu (Rest / Rest & Save / Save).
-- Rest item table (Sleeping Bag/Tent/Pavilion + free fallback).
-- Inn behavior (paid full restore, varies by town per economy.md).
-- Device reconfiguration (always available, independent of rest).
-- Link to: items.md, economy.md, crafting.md.

## 5. Slot Management
-- Spec Section 5. 3 manual + 1 auto.
-- Save screen: 3 manual only. Load screen: auto at top + 3 manual.
-- Copy/Delete operations. Auto-save rules (cannot overwrite/delete).
-- Link to: ui-design.md Section 13.

## 6. Auto-Save
-- Spec Section 6. Silent, 4 triggers, does-not-trigger list.
-- Link to: difficulty-balance.md.

## 7. Faint-and-Fast-Reload
-- Spec Section 7. Full 8-step sequence.
-- Death-persistent values table (XP, gold, boss_cutscene_seen_*).
-- Resets-to-save-state list.
-- Durability: merged state written back to save file.
-- Level-up at reload. Narrative defeats exempt. Fallback.
-- Link to: events.md § 2c.

## 8. Post-Game Save State
-- Spec Section 8. Post-epilogue world. No re-fight.
-- Boss rush memorial encounters are separate (see Section 9).
-- Link to: postgame.md.

## 9. Boss Rush Save Suppression
-- Spec Section 9. Auto-save on tier entry. Save/load disabled.
-- Faint-and-Fast-Reload still works within boss rush.
-- Link to: postgame.md.

## 10. Save Migration
-- Spec Section 10. Versioned format, migration chain.
-- Migration types table (verbatim from spec).
-- Breaking changes guidance.

## 11. Storage Notes
-- Spec Section 11. Engine-agnostic. One file per slot.
-- Corruption detection. File size estimate (<256KB).
```

Cross-link to these existing docs throughout:
- `items.md` for rest item details
- `economy.md` for inn prices
- `crafting.md` for Arcanite Charge mechanics
- `overworld.md` for save point placement
- `difficulty-balance.md` for anti-frustration philosophy
- `postgame.md` for boss rush rules
- `events.md` for event flag catalog and Faint-and-Fast-Reload
- `ui-design.md` for save/load screen layout
- `progression.md` for Ley Crystal details
- `characters.md` for party member roster

- [ ] **Step 3: Verify completeness**

Check that every item from the spec's Appendix A cross-doc table is
addressed in the new doc. Check that every section from the spec has
a corresponding section in the game design doc.

- [ ] **Step 4: Commit**

```bash
git add docs/story/save-system.md
git commit -m "docs(shared): add save system design document (gap 4.3)"
```

---

## Chunk 2: Update Cross-Referenced Docs

These tasks update existing docs to be consistent with the save system
design. Each task is one file. Tasks 2-8 are independent of each other
and can run in parallel.

### Task 2: Update ui-design.md — Save/Load Screen

**Files:**
- Modify: `docs/story/ui-design.md:854-914` (Section 13)

- [ ] **Step 1: Read the current Section 13**

Read `docs/story/ui-design.md` lines 854-914 to see current save/load
screen design.

- [ ] **Step 2: Update Section 13 with these changes**

Changes to make (preserve existing formatting style):

a. **Section 13.1 (Access, ~line 856):** Keep "Main Menu → Save (at
   save points) or Title Screen → Load." Add a note: "At save points,
   interaction opens a 3-option menu (Rest / Rest & Save / Save)
   before the save screen. See Section 13.7."

b. **Section 13.2–13.4 (Slot Layout, ~lines 860-893):** Keep existing
   3-slot layout unchanged — this describes the Save screen.

c. **Section 13.6 (Load Screen, ~lines 902-906):** Replace "Identical
   layout, title reads 'Load.'" with a new layout description:
   - Auto-save slot at top with blue accent (`#88aaff`), labeled "AUTO",
     left border highlight (3px solid `#88aaff`)
   - Horizontal divider line
   - 3 manual slots below (same layout as Save screen)
   - Empty slots are not selectable (cursor skips them)

d. **Section 13.5 (Save Flow, ~lines 896-900):** Add Copy and Delete
   operations after the existing save flow:
   - Copy: select source slot → select destination → "Overwrite?" if
     populated → copy complete
   - Delete: select slot → "Delete this save?" → slot cleared

e. **Section 13.7 (Save Points, ~lines 908-914):** Replace "Walking
   onto one: glow intensifies, opens save screen directly" with the
   3-option save point menu:
   - Rest (sub-menu of rest items: Sleeping Bag/Tent/Pavilion, or
     free 25% MP fallback)
   - Rest & Save (rest first, then open save screen)
   - Save (open save screen directly)

f. **New subsection 13.8 (Auto-Save Slot Rules):** Add after 13.7:
   - Dedicated auto-save slot, separate from 3 manual slots
   - Cannot be manually overwritten, copied to, or deleted
   - Visible only on Load screen (not Save screen)
   - Can be copied FROM to a manual slot (promotes auto to manual)

- [ ] **Step 3: Verify the edits**

Re-read the modified section. Confirm:
- 3-option menu is described
- Load screen shows auto-save at top
- Save screen shows only 3 manual slots
- Copy and Delete operations are documented
- Auto-save slot rules are clear

- [ ] **Step 4: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): update save/load screen for 3-option menu and auto-save slot"
```

---

### Task 3: Update overworld.md — Save Point Rest Mechanics

**Files:**
- Modify: `docs/story/overworld.md:424-427` (Rest mechanics bullet)

- [ ] **Step 1: Read the current rest mechanics bullet**

Read `docs/story/overworld.md` lines 420-430.

- [ ] **Step 2: Replace the rest mechanics bullet**

Replace lines 424-427:
```
- **Rest mechanics.** Resting at a save point fully restores HP, MP,
  and AC (Arcanite Charges per [crafting.md](crafting.md)). Inns
  additionally clear all status ailments. This is the primary AC
  restoration mechanic for pre-dungeon device crafting.
```

With:
```
- **Rest mechanics.** Save points present a 3-option menu: Rest,
  Rest & Save, Save (see [save-system.md](save-system.md)). Resting
  consumes a rest item — Sleeping Bag (25% HP/MP/AC), Tent (50%),
  or Pavilion (100%) — and clears all status ailments. Without a
  rest item, a free fallback restores 25% MP only (no HP, no AC, no
  status clear). Inns provide full restore for gold (varies by town,
  see [economy.md](economy.md)). AC restoration via rest items is the
  primary recovery mechanic for pre-dungeon device crafting.
```

**Important:** The device reconfiguration bullet (~line 428-429) is
already present in overworld.md and should be preserved unchanged. Do
not overwrite adjacent lines.

**Note on inns:** Inn-specific menu behavior (paid rest replacing the
item sub-menu) is documented only in the new save-system.md. No
separate inn update is needed in overworld.md — the existing inn
references there are sufficient.

- [ ] **Step 3: Verify the edit**

Re-read the modified lines. Confirm the new text matches the spec:
tiered rest items, ailment clearing with items, free fallback, inn
reference. Confirm the device reconfiguration bullet is unchanged.

- [ ] **Step 4: Commit**

```bash
git add docs/story/overworld.md
git commit -m "docs(shared): update save point rest mechanics for tiered rest items"
```

---

### Task 4: Update items.md — Rest Item Effects

**Files:**
- Modify: `docs/story/items.md:83-85` (rest item table rows)

- [ ] **Step 1: Read the current rest item rows**

Read `docs/story/items.md` lines 78-90.

- [ ] **Step 2: Replace the three rest item rows**

Replace lines 83-85:
```
| Sleeping Bag | Restore 25% HP/MP to all party (save point only) | 250 | 125 | Act I shops |
| Tent | Restore 50% HP/MP to all party (save point only) | 500 | 250 | Act I shops |
| Pavilion | Restore 100% HP/MP to all party (save point only) | 1,200 | 600 | Act II shops |
```

With:
```
| Sleeping Bag | Restore 25% HP/MP/AC to all party, clear status ailments (save point only) | 250 | 125 | Act I shops |
| Tent | Restore 50% HP/MP/AC to all party, clear status ailments (save point only) | 500 | 250 | Act I shops |
| Pavilion | Restore 100% HP/MP/AC to all party, clear status ailments (save point only) | 1,200 | 600 | Act II shops |
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/items.md
git commit -m "docs(shared): add AC restore and ailment clearing to rest items"
```

---

### Task 5: Update crafting.md — AC Restoration Rule

**Files:**
- Modify: `docs/story/crafting.md:117` (AC restoration line)

- [ ] **Step 1: Read the current AC restoration line**

Read `docs/story/crafting.md` lines 114-120.

- [ ] **Step 2: Replace the AC restoration line**

Replace line 117:
```
AC is restored to full at inns, save points, and camps. AC serves two
```

With:
```
AC is restored at save points via rest items — Sleeping Bag (25%),
Tent (50%), Pavilion (100%) — and fully at inns. Without a rest item,
AC is not restored (see [save-system.md](save-system.md)). AC serves two
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/crafting.md
git commit -m "docs(shared): update AC restoration to reflect tiered rest items"
```

---

### Task 6: Update economy.md — Rest Item Effects

**Files:**
- Modify: `docs/story/economy.md:166-168` (rest item table rows)

- [ ] **Step 1: Read the current rest item rows**

Read `docs/story/economy.md` lines 162-172.

- [ ] **Step 2: Replace the three rest item rows**

Replace lines 166-168:
```
| Sleeping Bag | 250g | 125g | Restore 25% HP/MP to all party (save point only) | Act I |
| Tent | 500g | 250g | Restore 50% HP/MP to all party (save point only) | Act I |
| Pavilion | 1,200g | 600g | Restore 100% HP/MP to all party (save point only) | Act II |
```

With:
```
| Sleeping Bag | 250g | 125g | Restore 25% HP/MP/AC to all party, clear ailments (save point only) | Act I |
| Tent | 500g | 250g | Restore 50% HP/MP/AC to all party, clear ailments (save point only) | Act I |
| Pavilion | 1,200g | 600g | Restore 100% HP/MP/AC to all party, clear ailments (save point only) | Act II |
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/economy.md
git commit -m "docs(shared): add AC restore and ailment clearing to rest item economy table"
```

---

### Task 7: Update difficulty-balance.md — Death Recovery Phrasing

**Files:**
- Modify: `docs/story/difficulty-balance.md:367` (XP/levels/gold line)

- [ ] **Step 1: Read the current phrasing**

Read `docs/story/difficulty-balance.md` lines 361-373.

- [ ] **Step 2: Update the death-persistent values phrasing**

Replace line 367:
```
- XP, levels, gold, and boss-cutscene-seen flags are **preserved**
  across the wipe (applied on top of the save file).
```

With:
```
- XP, gold, and boss-cutscene-seen flags are **preserved** across
  the wipe. Levels are derived from accumulated XP at reload time
  (level-ups trigger with full HP/MP restore). The merged state is
  written back to the save file for durability across sessions. See
  [save-system.md](save-system.md) § Faint-and-Fast-Reload.
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/difficulty-balance.md
git commit -m "docs(shared): clarify death-persistent values (levels derived from XP)"
```

---

### Task 8: Update events.md — Faint-and-Fast-Reload Alignment

**Files:**
- Modify: `docs/story/events.md:417` (XP and level-ups row)

- [ ] **Step 1: Read the current Faint-and-Fast-Reload table**

Read `docs/story/events.md` lines 413-433.

- [ ] **Step 2: Update the XP row in the values-preserved table**

Replace line 417:
```
| XP and level-ups | Kept (includes spells/abilities learned from those level-ups) | Prevents grinding punishment; standard JRPG convention (FF4/FF6) |
```

With:
```
| XP | Kept. Levels are derived from accumulated XP at reload — if XP crosses a level threshold, the level-up happens during reload with full HP/MP restore. Spells/abilities unlocked by the new level become available. | Prevents grinding punishment; enables incremental progress through repeated boss attempts (FF6 raft sequence model). See [save-system.md](save-system.md). |
```

Keep the gold row (line 418) unchanged — it has substantial unique
rationale about the sell-exploit acceptance that is not captured
elsewhere.

- [ ] **Step 3: Add a "write-back" note**

After the values-preserved table (around line 420), add a note:

```markdown
**Durability:** The merged state (accumulated XP/gold/flags) is written
back to the save file after reload. If the player quits after dying,
their accumulated progress persists across sessions.
```

- [ ] **Step 4: Commit**

```bash
git add docs/story/events.md
git commit -m "docs(shared): align Faint-and-Fast-Reload with save system spec"
```

---

## Chunk 3: Update Gap Analysis and Final Verification

### Task 9: Update Gap Analysis Doc

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (Gap 4.3 status + progress table)

- [ ] **Step 1: Read the current Gap 4.3 section**

Read `docs/analysis/game-design-gaps.md` — find the 4.3 section
(around line 652) and the progress tracking table at the end.

- [ ] **Step 2: Update Gap 4.3 status**

Change status from `PARTIAL` to `COMPLETE`. Add completion date
and summary. Check off all checklist items.

- [ ] **Step 3: Add progress tracking row**

Add a new row to the Progress Tracking table at the bottom:

```
| 2026-03-30 | 4.3 Save System Design | PARTIAL → COMPLETE. Save data schema (9 groups), 3-option save point menu (Rest/Rest & Save/Save with tiered rest items), 3 manual + 1 auto slot, Faint-and-Fast-Reload with durable XP/gold write-back, post-epilogue save state, versioned migration chain. Cross-doc updates to ui-design.md, overworld.md, items.md, crafting.md, economy.md, difficulty-balance.md, events.md. | — |
```

- [ ] **Step 4: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(shared): mark Gap 4.3 Save System Design as COMPLETE"
```

---

### Task 10: Cross-Reference Verification

**Files:**
- Read only (verification pass, no edits expected)

- [ ] **Step 1: Verify save-system.md cross-links**

Read `docs/story/save-system.md` and check that every cross-reference
link points to an existing file and section:
- `items.md` rest items table
- `economy.md` inn prices and rest item prices
- `crafting.md` AC mechanics
- `overworld.md` save point placement
- `difficulty-balance.md` anti-frustration section
- `postgame.md` boss rush rules
- `events.md` event flags and Faint-and-Fast-Reload
- `ui-design.md` save/load screen
- `progression.md` Ley Crystal system
- `characters.md` party roster

- [ ] **Step 2: Verify cross-doc edits are consistent**

Spot-check that the 7 updated docs all agree on:
- Rest items restore HP/MP/AC (not just HP/MP)
- Rest items clear status ailments
- Free fallback is 25% MP only
- Death persists XP and gold (levels derived from XP)
- Save point interaction is a 3-option menu

- [ ] **Step 3: Verify no broken markdown links**

Grep for all cross-links in save-system.md and the 7 updated files.
Confirm each `[text](target.md)` link points to an existing file:

```bash
grep -oh '\[[^]]*\]([^)]*\.md[^)]*)' docs/story/save-system.md | sort -u
```

Spot-check that linked sections exist (e.g., "crafting.md" exists,
"economy.md" exists).

- [ ] **Step 4: Create beads issue for cross-doc updates if any were missed**

If verification found inconsistencies not covered by Tasks 2-8,
create a beads issue:

```bash
bd create --title="Fix remaining save system cross-doc inconsistencies" \
  --description="Verification pass found additional docs that reference save/rest mechanics inconsistently with save-system.md" \
  --type=task --priority=2
```

Skip this step if verification found no issues.
