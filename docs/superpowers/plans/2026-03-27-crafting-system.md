# Crafting System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write the canonical crafting mechanics document (`docs/story/crafting.md`), apply design changes to existing docs, and update the gap tracker.

**Architecture:** This is a game design documentation task. The deliverable is a story doc consolidating all Arcanite Forging interaction mechanics, plus targeted updates to equipment.md, items.md, and the gap tracker. Content that already exists (recipes, materials, stats) is referenced, not duplicated.

**Tech Stack:** Markdown documentation, git

---

## Chunk 1: Core Document & Cross-Reference Updates

### Task 1: Write Crafting Document — Sections 1–3

Write the first half of `docs/story/crafting.md`: overview, interaction model, and AC system.

**Files:**
- Create: `docs/story/crafting.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-27-crafting-system-design.md` (Sections 1–3)
- Format reference: `docs/story/dialogue-system.md` (follow same header/blockquote style)
- Cross-reference: `docs/story/abilities.md` (AC pool, battle devices)
- Cross-reference: `docs/story/items.md` (pre-crafted devices, materials)
- Cross-reference: `docs/story/equipment.md` (forged equipment, infusions)
- Cross-reference: `docs/story/locations.md` (forge locations)

- [ ] **Step 1: Write the document header and overview**

Follow the same style as dialogue-system.md — blockquote intro with related docs, core philosophy, then sections. The overview should:
- State Lira as sole crafter, SNES-era SoM reference
- Explain the consolidation purpose (mechanics doc, references other files for data)
- List related docs with links

- [ ] **Step 2: Write Section 1 — Interaction Model**

Cover all three subsections from spec Section 2:
- Three crafting types table (device/equipment/infusion with access context and costs)
- Forge locations list (6 named locations with act availability)
- Device crafting flow (5-step field menu flow)
- Equipment forging flow (5-step forge flow with 3 tabs)
- Device loadout rules (5 slots, 3 charges, locking, save point reconfigure, persistence)

- [ ] **Step 3: Write Section 2 — Arcanite Charge System**

Cover all subsections from spec Section 3:
- Pool mechanics (flat 12 AC per abilities.md, two distinct systems)
- Key distinction between battle devices (AC during combat) and pre-crafted devices (AC during crafting)
- AC costs for pre-crafting table (5 tiers: Basic 1, Advanced 2, Expert 2, Anti-Pallor 3, Ultimate 4)
- AC budget examples (3 worked examples)
- AC restoration rules (rest points + Arcanite Shard dual-purpose)

- [ ] **Step 4: Verify cross-references**

Check against canonical sources:
- AC pool "flat 12" matches abilities.md
- Device names in tier table match items.md device list
- Forge location names match locations.md
- Equipment forging fee 400–500g matches economy.md/equipment.md
- Infusion fee 300–500g matches equipment.md

- [ ] **Step 5: Commit**

```bash
git add docs/story/crafting.md
git commit -m "docs(shared): add crafting system mechanics doc — sections 1-2

Interaction model (field devices + forge equipment/infusions), AC
system (flat 12 pool, 5 tiers, dual-purpose Arcanite Shards)."
```

---

### Task 2: Write Crafting Document — Sections 3–5

Add synergy discovery, malfunction mechanics, and recipe progression.

**Files:**
- Modify: `docs/story/crafting.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-27-crafting-system-design.md` (Sections 4–6)
- Cross-reference: `docs/story/equipment.md` (synergy list)
- Cross-reference: `docs/story/abilities.md` (malfunction, Calibrate)
- Cross-reference: `docs/story/dungeons-world.md` (Pallor zone flags)

- [ ] **Step 1: Write Section 3 — Synergy Discovery System**

Cover:
- Two discovery channels (NPC hints + Lira reacts) with descriptions
- Discovery distribution table (7 synergies with hint channel assignments)
- Synergies tab description (discovered/undiscovered, "???" slots, count)
- Activation notification ("Lira senses a resonance...")

- [ ] **Step 2: Write Section 4 — Malfunction & Calibration**

Cover per abilities.md:
- 15% malfunction chance in Pallor zones
- Three equal-probability effects (heal wrong target, damage ally, fizzle)
- Visual tell (grey-veined Arcanite crystals)
- Calibrate action (0 AC, spends turn, targets one active device for remaining duration)
- Zones affected list
- Narrative rationale

- [ ] **Step 3: Write Section 5 — Recipe Unlock Progression**

Cover:
- Progression table (6 rows: Act I through Post-Convergence)
- Schematic items (Boring Engine Schematic, Forge Schematic with STEAL-only note)

- [ ] **Step 4: Verify against canonical sources**

Check:
- Synergy names and weapon+infusion pairings match equipment.md exactly
- Malfunction mechanics match abilities.md (equal 1/3 chance, not weighted)
- Calibrate behavior matches abilities.md (targets device for remaining duration)
- Pallor zone list matches dungeons-world.md
- Recipe unlock triggers match events.md story progression
- Schematic locations match items.md key items list

- [ ] **Step 5: Commit**

```bash
git add docs/story/crafting.md
git commit -m "docs(shared): add synergy discovery, malfunction, and recipe progression

Two-channel discovery (NPC hints + Lira reacts), Pallor malfunction
(15%, Calibrate 0 AC costs turn), recipe unlock timeline Act I-Post."
```

---

### Task 3: Apply Design Changes to Existing Docs

Update equipment.md, items.md, and locations.md per the spec's "Design Changes" section.

**Files:**
- Modify: `docs/story/equipment.md` (forging location rule, synergy hint text)
- Modify: `docs/story/items.md` (add AC cost column to device table)
- Modify (if needed): `docs/story/locations.md` (verify Oasis B forge)

**Reference:**
- Spec Section 2 design change (forging at forge locations, not save points)
- Spec Section 4 design change (synergy hints replace "no hints")
- Spec Section 3 AC cost tier mapping
- Spec design change #4 (Oasis B forge verification)

- [ ] **Step 1: Update equipment.md forging location text**

Search for "at save points and camps" in equipment.md. Replace with
text explaining the context-sensitive model:
- Devices: craftable at save points, camps, and field menu
- Equipment forging and infusions: require forge locations (Ashmark,
  Caldera, Forgotten Forge, inn workbenches, Lira's workshop, Oasis B)
- Add cross-reference to crafting.md for full details

- [ ] **Step 2: Update equipment.md synergy hint text**

Search for "no in-game hints until the synergy activates" in
equipment.md. Replace with description of layered discovery:
- NPC hints in forge cities + Lira reactions at forge
- Reference crafting.md Section 3 for full discovery distribution
- Keep the synergy activation notification text

- [ ] **Step 3: Add AC cost column to items.md device table**

Find the device recipe table in items.md. Add an "AC Cost" column
with values from the spec's tier mapping:
- Basic devices: 1 AC
- Advanced devices: 2 AC
- Expert devices: 2 AC
- Anti-Pallor devices: 3 AC
- Ultimate device: 4 AC

- [ ] **Step 4: Verify Oasis B forge in locations.md**

Search locations.md for the Oasis B entry. Check if it describes a
crafting-capable forge. Currently it mentions "jury-rigged Forgewright
amplifiers" for ley ward defense. If no forge exists, add a brief note
that Oasis B has a jury-rigged forge workbench (repurposed amplifier
components) suitable for basic equipment forging and infusions. Add
`docs/story/locations.md` to the commit's `git add` if modified.

- [ ] **Step 5: Verify changes are consistent**

- equipment.md forging location text matches crafting.md Section 1
- equipment.md synergy text matches crafting.md Section 3
- items.md AC costs match crafting.md Section 2 tier table
- No other references to "save points and camps" for forging in equipment.md

- [ ] **Step 6: Commit**

```bash
git add docs/story/equipment.md docs/story/items.md docs/story/locations.md
git commit -m "docs(shared): apply crafting design changes to equipment and items

Update forging location rules (forge locations only for equipment),
replace 'no hints' with layered synergy discovery, add AC cost
column to device recipe table."
```

---

### Task 4: Update Gap Tracker

Mark Gap 3.5 as COMPLETE and add progress tracking row.

**Files:**
- Modify: `docs/analysis/game-design-gaps.md` (search for "### 3.5 Crafting System")
- Modify: `docs/analysis/game-design-gaps.md` (search for "## Progress Tracking")

- [ ] **Step 1: Update Gap 3.5 section**

- Status: SKELETAL → COMPLETE
- Files: add `docs/story/crafting.md` as primary file
- Completed date: 2026-03-27
- Check off all "What's Needed" items with resolution descriptions:
  - [x] Crafting recipe list — already in equipment.md (8 recipes, 7 infusions) and items.md (13 devices); crafting.md references these
  - [x] Material acquisition sources — already in items.md drop tables and economy.md shops
  - [x] Crafting UI/interaction model — context-sensitive: devices in field menu, equipment/infusions at forge locations only
  - [x] Crafted item tier progression — 5 device tiers (Basic→Ultimate) with AC costs, equipment per act in recipe unlock table
  - [x] Integration with Lira's story arc — recipe unlocks track narrative milestones, schematic items gate progression
- Add new completed items:
  - [x] Arcanite Charge system (flat 12 AC pool, dual-purpose with battle devices)
  - [x] Device loadout rules (5 slots, dungeon locking, save point reconfigure)
  - [x] Synergy discovery (NPC hints + Lira reactions, distributed across 7 synergies)
  - [x] Pallor malfunction mechanics (15%, Calibrate action, per abilities.md)
- Add blocking note: no downstream gaps blocked

- [ ] **Step 2: Add progress tracking row**

```
| 2026-03-27 | 3.5 Crafting System | SKELETAL → COMPLETE. Context-sensitive crafting (devices in field, equipment at forges). Flat 12 AC pool, 5 device tiers, loadout locking. Synergy discovery (NPC hints + Lira reactions). Pallor malfunction (15%, Calibrate). Design changes applied to equipment.md and items.md. | — |
```

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-design-gaps.md
git commit -m "docs(shared): mark Gap 3.5 complete

Update gap tracker: 3.5 SKELETAL -> COMPLETE. Crafting mechanics
consolidated in crafting.md with design changes to equipment.md
and items.md."
```

---

### Task 5: Adversarial Verification

Run verification pass on all changed files.

**Files:**
- Read: `docs/story/crafting.md` (new document)
- Read: `docs/story/equipment.md` (modified)
- Read: `docs/story/items.md` (modified)
- Read: `docs/story/abilities.md` (cross-reference)
- Read: `docs/analysis/game-design-gaps.md` (updated tracker)

- [ ] **Step 1: Numeric consistency checks**

- AC pool 12 matches abilities.md
- AC tier costs (1/2/2/3/4) produce reasonable budgets with 12 AC pool
- Equipment forging fees (400–500g) match economy.md
- Infusion fees (300–500g) match equipment.md tables

- [ ] **Step 2: Cross-reference checks**

- Every device name in crafting.md exists in items.md
- Every forge location in crafting.md exists in locations.md
- Every synergy in crafting.md matches equipment.md
- Malfunction mechanics match abilities.md exactly
- Calibrate behavior matches abilities.md exactly
- equipment.md edits are consistent with crafting.md
- items.md AC costs match crafting.md tier table
- Schematic items exist in items.md key items list

- [ ] **Step 3: Existing doc consistency**

- No remaining "at save points and camps" for equipment forging in equipment.md
- No remaining "no in-game hints" for synergies in equipment.md
- crafting.md doesn't contradict abilities.md, items.md, or economy.md
- Gap 3.5 file list includes crafting.md

- [ ] **Step 4: Fix any issues found**

If verification finds problems, fix and commit.

- [ ] **Step 5: Final commit (if fixes needed)**

```bash
git add docs/story/crafting.md
git commit -m "docs(shared): fix crafting system verification issues"
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

Gap 3.5 is complete. Next steps:
- Run `/create-pr` to open a PR targeting main
- Then `/pr-review-response <PR#>` to run automated review
- Remaining gaps: 3.1 (Transport), 3.2 (Overworld), 3.7 (Script), 3.6 (NG+)
