# Dialogue System Mechanics Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write the canonical dialogue system mechanics document (`docs/story/dialogue-system.md`) and update all cross-references.

**Architecture:** This is a game design documentation task, not code. The deliverable is a story doc covering sprite emotion animations, NPC priority stack resolution, party-aware dialogue rules, and the dialogue data format. Cross-references in ui-design.md and the gap tracker are updated to reflect completion.

**Tech Stack:** Markdown documentation, git

---

## Chunk 1: Core Document & Cross-References

### Task 1: Write Dialogue System Document — Sections 1–2

Write the first half of `docs/story/dialogue-system.md`: overview, design philosophy, and the sprite emotion animation catalog.

**Files:**
- Create: `docs/story/dialogue-system.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-26-dialogue-system-design.md` (Sections 1–2)
- Format reference: `docs/story/combat-formulas.md` (follow the same header/blockquote/related-docs style)
- Cross-reference: `docs/story/ui-design.md` Section 12 (dialogue box specs)
- Cross-reference: `docs/story/characters.md` (6 party members + 2 guests)

- [ ] **Step 1: Write the document header and overview**

Follow the same style as `docs/story/combat-formulas.md` — blockquote intro with related docs, design principles at a glance, then sections.

The overview should:
- State the core philosophy (SNES FF6 pure, no portraits, sprite animations + writing)
- Reference ui-design.md Section 12 for visual presentation specs
- List the related docs

- [ ] **Step 2: Write Section 1 — Dialogue Box Summary**

Brief cross-reference section confirming what ui-design.md Section 12 already specifies. Not a repeat — just a pointer with key values for quick reference (3-line max, text speeds, choice prompt rules). Note that portrait emotion variants are NOT needed (sprite emotion system handles all emotion).

- [ ] **Step 3: Write Section 2 — Sprite Emotion System**

The full 14-animation catalog table from the spec (Section 2). Include:
- Animation catalog table with ID, visual description, duration, use case
- Timing rules (between dialogue boxes, engine pauses, simultaneous multi-character, looping anims)
- Usage guidelines with good/bad examples
- Note that animations are referenced by ID in the dialogue data format (Section 4)

- [ ] **Step 4: Verify cross-references**

Check that every character name, flag name, and mechanic referenced in Sections 1–2 exists in the referenced docs. Specifically:
- Animation durations are reasonable for a 60fps SNES-style game
- Character names match `characters.md` exactly

- [ ] **Step 5: Commit**

```bash
git add docs/story/dialogue-system.md
git commit -m "docs(shared): add dialogue system mechanics doc — sections 1-2

Sprite emotion catalog (14 animations), timing rules, usage guidelines.
SNES FF6 pure — no portraits, emotion via sprite animation + writing."
```

---

### Task 2: Write Dialogue System Document — Section 3 (NPC Interaction Model)

Add the NPC interaction model, priority stack resolution, flag system, and party-aware dialogue rules.

**Files:**
- Modify: `docs/story/dialogue-system.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-26-dialogue-system-design.md` (Section 3)
- Cross-reference: `docs/story/events.md` (61 story flags, approval scores, reunion order)
- Cross-reference: `docs/story/npcs.md` (NPC definitions, dialogue state descriptions)
- Cross-reference: `docs/story/characters.md` (party members for party_has checks)

- [ ] **Step 1: Write NPC Interaction Rules subsection**

Cover:
- Single interaction per confirm, no dialogue trees
- Re-talk repeats current dialogue
- Priority stack determines current dialogue (first-match-wins)

- [ ] **Step 2: Write Priority Stack Resolution subsection**

Cover:
- How the engine walks top-to-bottom
- Author controls priority through entry ordering
- Worked example using Scholar Aldis with 5 flag-gated entries
- Flag types table: binary, numeric comparison, string comparison, party_has()
- AND combination rules; OR via separate stack entries

- [ ] **Step 3: Write Choice Consequences subsection**

Cover the two patterns only:
- Binary flag set (with example: `cael_last_night_vault`)
- Numeric score increment (with example: `council_savanh_approval +2`)
- Explicit: no hidden tracking, no relationship meters, no timed choices

- [ ] **Step 4: Write Party-Aware Dialogue subsection**

Cover both tiers:
- Tier 1: Key story scenes (~15–20), list the specific scenes
- Tier 2: NPC reactions (~2–3 per town, ~100–150 lines total), with worked example
- Estimated script impact

- [ ] **Step 5: Verify against events.md and fix flag names**

Cross-check all flag names in examples against events.md. The spec used shorthand flag names for readability — the document must use canonical names from events.md. Known mismatches to resolve:
- `cael_betrayal` → find the canonical flag name in events.md (likely `cael_betrayal_complete` or similar)
- `pallor_convergence` → find the canonical flag name or note as a new flag to be added
- `act2_started` → find the canonical act transition flag
- `savanh_audience_active` → find the canonical flag or note as a new flag

For flags that don't exist in events.md, add a note in the document: "Flag names in examples are canonical where they match events.md. Flags marked with (*) are defined here and will be added to events.md during Gap 3.7 script work."

Also verify:
- `council_savanh_approval` score exists and has range 0–3
- `reunion_order_1` through `reunion_order_4` exist and store character IDs
- Party member names match characters.md exactly

- [ ] **Step 6: Commit**

```bash
git add docs/story/dialogue-system.md
git commit -m "docs(shared): add NPC interaction model and party-aware dialogue

Priority stack resolution (first-match-wins), 4 flag types, 2 choice
consequence patterns, party-aware Tier 1 (key scenes) + Tier 2 (NPC
reactions ~100-150 lines)."
```

---

### Task 3: Write Dialogue System Document — Section 4 (Data Format)

Add the dialogue data format specification with all field definitions and worked examples.

**Files:**
- Modify: `docs/story/dialogue-system.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-26-dialogue-system-design.md` (Section 4)

- [ ] **Step 1: Write Entry Fields table**

The main fields table: id, speaker, lines, condition, animations, choice, sfx. Include type and description for each.

- [ ] **Step 2: Write sub-field tables**

- Animation Trigger Fields (who, anim, when) — from spec
- Choice Option Fields (label, flag_set, score_name, score_delta) — from spec
- SFX Trigger Fields (line, id) — not a separate table in the spec; define it here for completeness based on the Entry Fields table description

- [ ] **Step 3: Write all worked examples**

Include all 8 examples from the spec:
1. Simple NPC (one line, no conditions)
2. Flag-gated with animation (Aldis post-betrayal)
3. Party-aware (Elder Savanh + Torren)
4. Narration (no speaker, hidden name tag)
5. Choice with score consequence (Savanh audience)
6. Reunion order string comparison (Maren)
7. Sound effect trigger (siege door breach)
8. Multiple characters animating (betrayal scene)

- [ ] **Step 4: Write File Organization subsection**

- Location NPC files (one per location)
- Scene files (one per major story scene)
- Priority stack order = entry order

- [ ] **Step 5: Commit**

```bash
git add docs/story/dialogue-system.md
git commit -m "docs(shared): add dialogue data format with worked examples

Entry fields (id/speaker/lines/condition/animations/choice/sfx),
sub-field tables, 8 worked examples covering all patterns, file
organization rules."
```

---

### Task 4: Update Cross-References and Gap Tracker

Resolve the deferred item in ui-design.md, update the gap analysis document, and add the new doc to the story README if one exists.

**Files:**
- Modify: `docs/story/ui-design.md` (resolve deferred portrait emotion variants — search for "deferred to Gap 3.3")
- Modify: `docs/analysis/game-design-gaps.md` (update Gap 3.3 section — search for "### 3.3 Dialogue System Mechanics")
- Modify: `docs/analysis/game-design-gaps.md` (add progress tracking row — search for "## Progress Tracking")

Note: Line numbers are approximate. Search for section headers rather than relying on exact line numbers.

**Reference:**
- Gap 3.3 current status: `docs/analysis/game-design-gaps.md` lines 466–480
- Progress tracking table: `docs/analysis/game-design-gaps.md` lines 592–613

- [ ] **Step 1: Update ui-design.md deferred item**

Change line 39 from:
```
  each; emotion variants deferred to Gap 3.3 if needed.
```
To:
```
  each; emotion variants not needed — Gap 3.3 resolved this with
  the sprite emotion system (see dialogue-system.md Section 2).
```

- [ ] **Step 2: Update Gap 3.3 in game-design-gaps.md**

Update the Gap 3.3 section (lines 466–480):
- Status: PARTIAL -> COMPLETE
- Files: add `docs/story/dialogue-system.md` as primary file
- Completed date: 2026-03-26
- Check off all "What's Needed" items, updating descriptions:
  - [x] Text box rendering specs — confirmed in ui-design.md Section 12
  - [x] Character portrait system — resolved: no portraits in dialogue, sprite emotion system (14 animations), menu portraits use single neutral expression
  - [x] Text speed options and player control — confirmed in ui-design.md Section 12
  - [x] Choice prompt mechanics and visual layout — confirmed in ui-design.md Section 12
  - [x] NPC interaction model — priority stack (first-match-wins), flag-gated, party-aware (2 tiers)
- Add new items that were designed beyond the original scope:
  - [x] Sprite emotion animation catalog (14 animations with timing rules)
  - [x] Dialogue data format (entry fields, sub-fields, 8 worked examples)
  - [x] Party-aware dialogue rules (Tier 1 key scenes + Tier 2 NPC reactions)
  - [x] Flag condition system (binary, numeric, string comparison, party_has)
- Add "**Blocking:** ~~Dialogue scripting, script authoring~~ Now unblocks: 3.7 (Full Dialogue Script)" after the What's Needed list (following the pattern used in other completed gaps)

- [ ] **Step 3: Add progress tracking row**

Add to the progress tracking table at the bottom of game-design-gaps.md:
```
| 2026-03-26 | 3.3 Dialogue System Mechanics | PARTIAL → COMPLETE. SNES FF6 pure (no portraits). Sprite emotion system (14 animations), priority stack NPC resolution, party-aware dialogue (key scenes + NPC reactions), dialogue data format (7 entry fields, 8 worked examples). Unblocks 3.7. | — |
```

- [ ] **Step 4: Verify all cross-references are consistent**

Quick check:
- `dialogue-system.md` references to ui-design.md Section 12 are accurate
- `dialogue-system.md` references to events.md flag names are accurate
- Gap 3.3 file list includes the new document
- No other docs reference "Gap 3.3" as pending/deferred (checked in Step 1)

- [ ] **Step 5: Commit**

```bash
git add docs/story/ui-design.md docs/analysis/game-design-gaps.md
git commit -m "docs(shared): mark Gap 3.3 complete, resolve ui-design.md deferral

Update gap tracker: 3.3 PARTIAL -> COMPLETE. Resolve portrait emotion
variant deferral in ui-design.md (not needed — sprite emotion system).
Unblocks Gap 3.7 (Full Dialogue Script)."
```

---

### Task 5: Adversarial Verification

Run the story-designer verification pass on the completed document. This is NOT optional per the story-designer skill.

**Files:**
- Read: `docs/story/dialogue-system.md` (the new document)
- Read: `docs/story/ui-design.md` (cross-reference)
- Read: `docs/story/events.md` (flag cross-reference)
- Read: `docs/story/npcs.md` (NPC cross-reference)
- Read: `docs/story/characters.md` (character cross-reference)
- Read: `docs/analysis/game-design-gaps.md` (gap tracker)

- [ ] **Step 1: Numeric consistency checks**

- Animation durations: do they make sense at 60fps? (0.3s = 18 frames, 0.5s = 30 frames — reasonable)
- Text speeds: 30/60/120 cps at 3 lines × ~30 chars/line = 90 chars per box → 3s/1.5s/0.75s to fill a box (reasonable pacing)

- [ ] **Step 2: Cross-reference checks**

Verify every name and flag used in dialogue-system.md examples:
- `cael_betrayal` flag exists in events.md
- `pallor_convergence` flag exists in events.md
- `cael_nightmares_begin` flag exists in events.md
- `act2_started` flag exists in events.md (or equivalent)
- `council_savanh_approval` score exists in events.md
- `reunion_order_1` through `reunion_order_4` exist in events.md
- `savanh_audience_active` flag exists in events.md (or is plausible)
- Party member names: Edren, Cael, Maren, Lira, Torren, Sable match characters.md
- NPC names: Aldis, Savanh match npcs.md
- Animation IDs in examples match the catalog table exactly

- [ ] **Step 3: Existing doc consistency checks**

- New content doesn't contradict ui-design.md Section 12
- NPC interaction rules match what npcs.md describes
- Choice consequence patterns match events.md approval system
- No other story docs claim dialogue works differently

- [ ] **Step 4: Fix any issues found**

If verification finds problems, fix them in the relevant files and amend the previous commit or create a fix commit.

- [ ] **Step 5: Final commit (if fixes needed)**

```bash
git add docs/story/dialogue-system.md
git commit -m "docs(shared): fix dialogue system verification issues"
```

---

### Task 6: Push and Handoff

- [ ] **Step 1: Run final quality check**

```bash
pnpm lint    # Ensure no type errors introduced (unlikely for docs-only)
git status   # Confirm clean working tree
```

- [ ] **Step 2: Push to remote**

```bash
git push
```

- [ ] **Step 3: Handoff**

Gap 3.3 is complete. Next steps:
- Run `/create-pr` to open a PR targeting main
- Then `/pr-review-response <PR#>` to run automated review
- Gap 3.7 (Full Dialogue Tree & Story Script) is now unblocked — recommend as next `/story-designer` target
