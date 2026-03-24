# Row/Position System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Formalize the front/back row system by adding row damage modifiers to combat-formulas.md, default rows to characters.md, a Steal front-row requirement to abilities.md, and updating the gap tracker.

**Architecture:** Small updates to 3 existing story docs + gap tracker. No new story docs or code files; this plan and its spec are the only new docs under `docs/superpowers/`. The row system is compact — most of the design is already implicit in equipment.md (spears "back-row capable") and abilities.md (Rampart "guards the back row").

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-24-row-position-system-design.md`

---

## Chunk 1: All Tasks (compact enough for a single chunk)

### Task 1: Add Row Modifier to combat-formulas.md

**Files:**
- Modify: `docs/story/combat-formulas.md`

**Context:** The physical damage pipeline in combat-formulas.md needs a Row Modifier step. Currently the pipeline goes: base damage → ability multiplier → defense subtraction → variance → cap. The row modifier slots in as a final multiplier after all other calculations.

- [ ] **Step 1: Read combat-formulas.md physical damage section**

Read `docs/story/combat-formulas.md` and find the physical damage pipeline / resolution steps. Identify where the row modifier should be inserted (after the final damage calculation, before the cap).

- [ ] **Step 2: Add Row Modifier section**

Insert a new `### Row Modifier` subsection in the physical damage section. Content:

**Row Modifier (Physical Damage Only)**

The row system uses 2 rows (Front and Back) for the player party. Enemies have no rows.

| Condition | Modifier |
|-----------|----------|
| Front row attacker | ×1.0 (no change) |
| Back row attacker (melee weapon) | ×0.5 |
| Back row attacker (ranged weapon — spears) | ×1.0 (penalty bypassed) |
| Front row defender (physical attack) | ×1.0 (no change) |
| Back row defender (physical attack) | ×0.5 |
| Any row (magic damage) | No modifier — magic ignores rows |

Row modifiers apply as a **final multiplier** after all other damage calculations (ATK², ability multiplier, DEF subtraction, variance). Applied separately for attacker and defender:

```
final_physical_damage = floor(damage_after_variance × attacker_row_mod × defender_row_mod)
```

(Flooring and the 14,999 damage cap are applied after row modifiers — see combat-formulas.md resolution pipeline step 9.)

Items, Forgewright devices, and Ley Crystal invocations work at full effect from either row.

**Row swapping** is a free action with no turn cost or ATB delay.

Also add a note to the magic damage section: "Magic damage is unaffected by row position."

- [ ] **Step 3: Verify no contradictions**

Re-read the full physical damage pipeline to ensure the row modifier doesn't conflict with existing steps (variance, cap, multi-hit rules). The row modifier should apply before the 14,999 damage cap but after variance.

- [ ] **Step 4: Commit**

```bash
git add docs/story/combat-formulas.md
```
Message: `docs(shared): add row modifier to physical damage pipeline in combat-formulas.md`

---

### Task 2: Add Default Battle Rows to characters.md

**Files:**
- Modify: `docs/story/characters.md`

**Context:** Each character needs a default battle row listed in their profile. This is where they start at the beginning of every battle.

- [ ] **Step 1: Read characters.md structure**

Read `docs/story/characters.md` to find where character stat summaries or combat profiles are listed. Find the best place to add default row info — either in each character's section or as a summary table.

- [ ] **Step 2: Add default row assignments**

Add a `### Default Battle Rows` section (or integrate into existing combat summary if one exists). Include the table:

| Character | Default Row | Rationale |
|-----------|------------|-----------|
| Edren | Front | Tank — highest DEF/HP, sword user |
| Cael | Front | Commander — balanced stats, greatsword user |
| Lira | Front | Engineer — hammer user, moderate DEF |
| Torren | Back | Sage — spear user (back-row capable), high MAG |
| Sable | Front | Thief — dagger user, needs front row for Steal |
| Maren | Back | Archmage — highest MAG, lowest DEF/HP |

Add a note: "Default rows can be changed freely during battle (free action). Torren's spears deal full damage from back row — he never needs to move forward. Maren's magic is unaffected by row — back row is strictly superior for her."

- [ ] **Step 3: Commit**

```bash
git add docs/story/characters.md
```
Message: `docs(shared): add default battle row assignments to characters.md`

---

### Task 3: Add Steal Front-Row Requirement to abilities.md

**Files:**
- Modify: `docs/story/abilities.md`

**Context:** Sable's Steal ability requires front row (physical contact with enemy). This needs to be noted in abilities.md.

- [ ] **Step 1: Read abilities.md Sable section**

Read `docs/story/abilities.md` and find Sable's Tricks/Steal ability entry. Note the current description.

- [ ] **Step 2: Add front-row requirement**

Add a note to Sable's Steal ability: "**Requires front row.** Steal is greyed out if Sable is in the back row (physical contact with the target required)."

If there's a general ability notes section, also add: "Row-restricted abilities: Steal (Sable, front row only). All other abilities work from either row."

- [ ] **Step 3: Verify Rampart reference**

Read Edren's Rampart ability entry. Verify it already says "guards the entire back row, absorbing 30% of all damage dealt to back-row allies." If it does, no changes needed — it already assumes the row system. If the wording is different, note any discrepancy.

- [ ] **Step 4: Commit**

```bash
git add docs/story/abilities.md
```
Message: `docs(shared): add Steal front-row requirement to abilities.md`

---

### Task 4: Cross-Reference Verification + Gap Update

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`

**Context:** Final verification and gap tracker update.

- [ ] **Step 1: Verify equipment.md spear references**

Read `docs/story/equipment.md` and confirm spears are tagged as "back-row capable" (should be around lines 130, 274). Verify no other weapon types claim to be back-row capable. If staves or other weapons have "ranged" or "back-row" tags that weren't expected, flag them.

- [ ] **Step 2: Verify no contradictions**

Search docs/story/ for "row" (case-insensitive) to find any existing row references. Verify none contradict the new system. Key checks:
- combat-formulas.md new section matches spec
- abilities.md Rampart text is consistent
- equipment.md spear tags are consistent
- No other doc claims a different row system

- [ ] **Step 3: Update gap analysis**

In `docs/analysis/game-design-gaps.md`, Gap 2.5:
- Update status from `MISSING (design decision needed)` to `COMPLETE`
- Check off all checklist items with `[x]`:
  - `[x] Decision: Does this game have front/back rows? Yes — 2-row system (Front/Back)`
  - `[x] Front row: full physical damage dealt and received`
  - `[x] Back row: 50% physical damage dealt and received`
  - `[x] Magic unaffected by row`
  - `[x] Ranged weapons (spears) ignore row penalty`
  - `[x] Row swap action: free (no turn cost)`
  - `[x] Default row per character (6 assignments)`
  - `[x] Enemy positioning: no enemy rows (player-only system)`
  - `[x] Area-of-effect targeting: hits all targets regardless of row`
- Add completion date: 2026-03-24
- Update Files field to: `docs/story/combat-formulas.md, docs/story/characters.md, docs/story/abilities.md`
- Add completion note
- Add Progress Tracking row
- Update Blocking text

- [ ] **Step 4: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 5: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
(Add any other files if verification found issues.)
Message: `docs(shared): complete cross-reference verification, update Gap 2.5 to COMPLETE`
