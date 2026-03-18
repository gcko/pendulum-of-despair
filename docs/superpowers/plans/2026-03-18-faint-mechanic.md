# Faint Mechanic & Party Wipe Rules Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace "KO" with "Faint" across all story docs, change combat-context
"death"/"kill" to "defeat" for enemies, and add party-wipe consequence rules to
events.md.

**Architecture:** Pure documentation pass -- no code. Each task modifies 1-2
files. Verification is via `pnpm lint && pnpm test` and cross-referencing
against the spec.

**Tech Stack:** Markdown, git, pnpm (for lint/test verification)

**Spec:** `docs/superpowers/specs/2026-03-18-faint-mechanic-design.md`

---

## File Map

All story doc changes are modifications to existing files. This plan and its
companion spec are the only new files.

| File | Changes |
|------|---------|
| `docs/story/events.md` | Rename section 2c, update KO->Faint terminology, add party-wipe consequence tables |
| `docs/story/magic.md` | Status effect table + spell targets + Unmaking + Last Breath: KO->Faint |
| `docs/story/abilities.md` | Cael's Rally KO->Fainted, corrupted False Hope "die"->"be defeated" |
| `docs/story/dungeons-world.md` | Enemy "on death"->"on defeat", Instant Death->Instant Faint, instant kill->instant defeat, KO'd->Fainted |

---

## Chunk 1: Core Terminology & Party Wipe Rules

### Task 1: Update events.md -- Section 2c Title, Terminology, and Party Wipe Rules

**Files:**
- Modify: `docs/story/events.md:378-399`

This is the most important task -- it establishes the canonical rules that all
other files reference.

- [ ] **Step 1: Rename section title and update terminology**

Change line 378:
```
## 2c. Death and Fast Reload
```
to:
```
## 2c. Faint and Fast Reload
```

Change line 380:
```
When all party members are KO'd in battle:
```
to:
```
When all player-controlled party members are Fainted in battle (guest NPCs do
not count -- if every player character is Fainted but a guest NPC is still
standing, the wipe still triggers):
```

Change line 382:
```
1. **The Fall (2s):** Last KO animation plays. Battle UI fades. Music hard-cuts
```
to:
```
1. **The Fall (2s):** Last Faint animation plays. Battle UI fades. Music hard-cuts
```

Change lines 397-398:
```
- If the player dies before the first save point in the Ember Vein (unlikely
  given Arcanite gear), reload at the dungeon entrance.
```
to:
```
- If the party Faints before the first save point in the Ember Vein (unlikely
  given Arcanite gear), reload at the dungeon entrance.
```

- [ ] **Step 2: Add party-wipe consequence rules after the Rules block**

Insert the following after line 399 (after the last rule, before the `---`
separator):

```markdown

**What's Kept on Full Party Faint:**

The game reloads the last save file. XP, levels, and gold are the only values
written to a persistent layer outside the save file. Everything else comes from
the save.

| Category | Rule | Rationale |
|----------|------|-----------|
| XP and level-ups | Kept (includes spells/abilities learned from those level-ups) | Prevents grinding punishment; standard JRPG convention (FF4/FF6) |
| Gold/currency | Kept (all gold, including battle rewards and sale proceeds) | Prevents soft-lock. Note: sell-then-wipe gold exploit accepted (shops sparse, resale values low). Matches FF4/FF6. |
| Boss cutscene skip flags | Kept (`boss_cutscene_seen_<boss_id>`) | Prevents re-watching cutscenes on retry |

**What Resets to Last Save:**

| Category | Rule |
|----------|------|
| Inventory and consumables | Entire inventory reverts to last save |
| Equipment | Reverts to last-saved loadout; prevents item duplication from reset chests |
| Chest openings | Must be re-collected |
| Field item pickups | Items collected between save and wipe are gone |
| Shop transactions | Buy/sell actions revert (gold persists per above, purchased items revert) |
| Party composition | Story-driven member additions/removals revert |
| Storyline flag updates | Events, quest progress flags, NPC state changes revert (boss cutscene skip flags exempt) |
| Dungeon progress | Doors opened, switches flipped, puzzles solved revert |
```

- [ ] **Step 3: Verify the edit**

Read events.md section 2c to confirm all changes are correct and the tables
render properly in markdown.

- [ ] **Step 4: Commit**

```bash
git add docs/story/events.md
git commit -m "docs(shared): update events.md with Faint terminology and party-wipe rules"
```

---

### Task 2: Update magic.md -- Status Effect Table, Spell Targets, Mechanics

**Files:**
- Modify: `docs/story/magic.md:587,598,856,1118,1401,1411`

Six changes in one file, all mechanical KO->Faint replacements.

- [ ] **Step 1: Update Spirit Recall spell target (line 587)**

Change:
```
- **Target:** Single ally (KO'd)
```
to:
```
- **Target:** Single ally (Fainted)
```

- [ ] **Step 2: Update Second Dawn spell target (line 598)**

Change:
```
- **Target:** Single ally (KO'd)
```
to:
```
- **Target:** Single ally (Fainted)
```

- [ ] **Step 3: Update Last Breath spell effect (line 856)**

Change:
```
**Effect:** Grants auto-revive. If the target is KO'd, they automatically revive with 30% HP once.
```
to:
```
**Effect:** Grants auto-revive. If the target is Fainted, they automatically revive with 30% HP once.
```

- [ ] **Step 4: Update Unmaking spell effect (line 1118)**

Change:
```
they are instantly KO'd.
```
to:
```
they are instantly Fainted.
```

- [ ] **Step 5: Update Status Effect Reference table -- KO row (line 1401)**

Change:
```
| KO | Negative | Unconscious, out of combat | Until revived | Spirit Recall, Second Dawn, Phoenix Feather item |
```
to:
```
| Faint | Negative | Unconscious, out of combat | Until revived | Spirit Recall, Second Dawn, Phoenix Feather item |
```

- [ ] **Step 6: Update Status Effect Reference table -- Last Breath row (line 1411)**

Change:
```
| Last Breath (Reraise) | Positive | Auto-revive at 30% HP on KO | Until triggered or battle ends | Dispersion / Mass Dispersion |
```
to:
```
| Last Breath (Reraise) | Positive | Auto-revive at 30% HP on Faint | Until triggered or battle ends | Dispersion / Mass Dispersion |
```

- [ ] **Step 7: Verify the edits**

Read the changed sections of magic.md to confirm accuracy. Spot-check that
flavor text like Second Dawn's "The dead do not stay dead when the ley lines
still burn" is untouched.

- [ ] **Step 8: Commit**

```bash
git add docs/story/magic.md
git commit -m "docs(shared): update magic.md KO->Faint across spells and status table"
```

---

### Task 3: Update abilities.md -- Cael's Rally and Corrupted Abilities

**Files:**
- Modify: `docs/story/abilities.md:54,79`

Two changes: one mechanical KO->Fainted, one combat-context "die"->"be defeated."

- [ ] **Step 1: Update Cael's Rally mechanic (line 54)**

Change:
```
if he's KO'd or afflicted with Silence/Sleep, the active Rally ends.
```
to:
```
if he's Fainted or afflicted with Silence/Sleep, the active Rally ends.
```

- [ ] **Step 2: Update False Hope corrupted ability (line 79)**

Change:
```
an enemy that would die instead survives at 1 HP (once per phase).
```
to:
```
an enemy that would be defeated instead survives at 1 HP (once per phase).
```

- [ ] **Step 3: Verify the edits**

Read the changed sections to confirm accuracy.

- [ ] **Step 4: Commit**

```bash
git add docs/story/abilities.md
git commit -m "docs(shared): update abilities.md KO->Faint and combat death->defeat"
```

---

### Task 4: Update dungeons-world.md -- Enemy Defeat Descriptions and Immunities

**Files:**
- Modify: `docs/story/dungeons-world.md:1469,1821,1886,2262,2862,2878`

Six changes: three "on death"->"on defeat", one "instant kill"->"instant defeat",
one "Instant Death"->"Instant Faint", one "KO'd"->"Fainted".

- [ ] **Step 1: Update Crystal Sentry enemy description (line 1469)**

Change:
```
Shatters into shrapnel on death (minor area damage).
```
to:
```
Shatters into shrapnel on defeat (minor area damage).
```

- [ ] **Step 2: Update The Index "Destroy" option (line 1821)**

Change:
```
- **Destroy** -- instant kill but loses all INT buffs and a unique lore item.
```
to:
```
- **Destroy** -- instant defeat but loses all INT buffs and a unique lore item.
```

- [ ] **Step 3: Update Vaelith boss immunities (line 1886)**

Change:
```
**Immunity:** Despair status, Instant Death.
```
to:
```
**Immunity:** Despair status, Instant Faint.
```

- [ ] **Step 4: Update Crystal Warden enemy description (line 2262)**

Change:
```
Shatters on death (area damage).
```
to:
```
Shatters on defeat (area damage).
```

- [ ] **Step 5: Update Wellspring Guardian debuff mechanic (line 2862)**

Change:
```
If any party member's debuff stacks reach 5, they are KO'd.
```
to:
```
If any party member's debuff stacks reach 5, they are Fainted.
```

- [ ] **Step 6: Update Crystal Warden (deep) enemy description (line 2878)**

Change:
```
Shatters on death (area damage).
```
to:
```
Shatters on defeat (area damage).
```

- [ ] **Step 7: Verify the edits**

Read each changed line in context. Confirm that narrative text like "Vaelith
does not die dramatically" (line 1874), dead miners (line 143), and the Great
Spirit's death (line 1663) are untouched.

- [ ] **Step 8: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(shared): update dungeons-world.md combat death->defeat and KO->Faint"
```

---

### Task 5: Final Verification

- [ ] **Step 1: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (documentation-only changes should not break anything).

- [ ] **Step 2: Audit for any remaining KO references**

Search all story docs for stray "KO" that should have been changed:

```bash
grep -rn '\bKO\b' docs/story/
```

Expected: zero matches (all instances should now be "Faint").

- [ ] **Step 3: Audit for combat-context "death" that should be "defeat"**

Search for "on death" and "instant kill" in story docs:

```bash
grep -rn 'on death\|instant kill\|Instant Death' docs/story/
```

Expected: zero matches. If any remain, evaluate whether they are narrative
(keep) or mechanical (change).

- [ ] **Step 4: Push to remote**

```bash
git push
```
