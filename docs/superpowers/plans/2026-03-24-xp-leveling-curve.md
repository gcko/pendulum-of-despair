# XP & Leveling Curve Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the XP-to-level formula (two-phase curve), XP distribution rules, level-up effects, the Ley Scar grinding zone, and Interlude reunion ability-acknowledgment notes to the story docs.

**Architecture:** Primary changes go into `docs/story/progression.md` (new "Experience & Leveling" section). Secondary changes add the Ley Scar zone to `dungeons-world.md` and `bestiary/act-iii.md`, and reunion dialogue notes to `events.md`. Gap tracker updated last.

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-24-xp-leveling-curve-design.md`

---

## Chunk 1: XP Formula & Distribution Rules in progression.md

### Task 1: Add Experience & Leveling Section to progression.md

**Files:**
- Modify: `docs/story/progression.md`

**Context:** progression.md has stat growth, Ley Crystals, and milestones but no XP system. Add a new major section covering the two-phase XP formula, distribution rules, and level-up effects. Insert it after the "Character Growth" heading area (around line 88) and before the "Growth Rates Per Level" subsection.

- [ ] **Step 1: Read progression.md structure**

Read `docs/story/progression.md` lines 85–100 to find the exact insertion point. The new section goes after the existing "## Character Growth" section header and before the growth rate tables.

- [ ] **Step 2: Write the Experience & Leveling section header and formula**

Insert a new `## Experience & Leveling` section. Include:

1. **Two-Phase XP Curve** subsection with:
   - Phase 1 formula: `XP_to_next_level(n) = floor(24 × n^1.5)` for levels 1–70
   - Phase 2 formula: `XP_to_next_level(n) = floor(10 × n^1.8)` for levels 71–150
   - Explanation: Phase 1 covers the main story (gentle), Phase 2 covers post-game (steeper). Different base constants (24 vs 10) ensure a 53% jump at the transition.

2. **Per-Level XP Table** — combined Phase 1 + Phase 2 sample:

| Level | XP to Next | Cumulative | Context |
|-------|-----------|-----------|---------|
| 1→2 | 24 | 24 | Game start |
| 2→3 | 67 | 91 | Early Act I |
| 5→6 | 268 | 675 | Early Act I |
| 10→11 | 758 | 3,420 | Mid Act I |
| 18→19 | 1,832 | 14,117 | End of Act I |
| 25→26 | 3,000 | 31,503 | Mid Act II |
| 35→36 | 4,969 | 72,059 | End of Act II |
| 50→51 | 8,485 | 173,946 | End of Interlude |
| 70→71 | 14,055 | 400,587 | End of Act III (Phase 1 last) |
| 71→72 | 21,491 | 422,078 | Phase 2 start (+53% jump) |
| 80→81 | 26,641 | 640,884 | Dreamer's Fault early |
| 100→101 | 39,810 | 1,308,086 | Dreamer's Fault mid |
| 120→121 | 55,274 | 2,262,921 | Dreamer's Fault late |
| 140→141 | 72,950 | 3,550,386 | Dreamer's Fault F20 |
| 150 (cap) | — | 4,332,504 | Level cap |

3. **Phase Transition Note**: At level 71, XP requirement jumps 53% (14,055 → 21,491). This signals "the main story is over." The jump is intentional and not smoothed.

- [ ] **Step 3: Write XP Distribution Rules subsection**

Add `### XP Distribution Rules` with:

- **Active battle members (4):** receive full enemy XP (not divided — each gets the full amount)
- **KO'd members:** receive 0 XP at battle end
- **Absent party members (2 reserves):** receive 50% of battle XP. This prevents the "benched forever" problem and keeps the roster viable for Interlude forced splits.
- **Ley Crystals:** gain 30% of wearer's XP (already defined — reference existing Ley Crystal section)
- **Guest NPCs:** do not receive XP (fixed scaling stats)

- [ ] **Step 4: Write Level-Up Effects subsection**

Add `### Level-Up Effects` with:

When a character gains a level:
1. Max HP/MP increase per growth rate
2. All stats increase per growth rates
3. **Current HP and MP fully restored** (FF6 model — creates clutch moments)
4. New abilities/spells unlock per learning schedules in abilities.md and magic.md

Level-up notification shows: character name, new level, stat deltas, and any newly learned abilities.

- [ ] **Step 5: Write Flat XP Model subsection**

Add `### Flat XP Model` with:

Enemies always give their listed XP regardless of party level. No bonuses for higher-level enemies, no penalties for lower-level. Simple, transparent, predictable. (The FF6 approach.)

- [ ] **Step 6: Write Catch-Up Mechanics subsection**

Add `### Catch-Up Mechanics` with:

- Join/rejoin formula: `join_level = max(1, floor(party_average_level) - 1)` (reference existing text in Character Growth section)
- 50% absent XP share is the ongoing safety net
- No additional XP bonus for underleveled characters
- Combined, these ensure no character is ever more than 2–3 levels behind

- [ ] **Step 7: Write XP Pacing Targets subsection**

Add `### XP Pacing Targets` with the FULL milestone table from the spec (Section 8):

| Milestone | Target Level | Cumulative XP | Act |
|-----------|-------------|--------------|-----|
| After Ember Vein | ~8 | ~2,000 | I |
| After Fenmother's Hollow | ~12 | ~5,300 | I |
| End of Act I | ~18 | ~14,100 | I |
| Mid Act II (Corrund) | ~25 | ~31,500 | II |
| End of Act II | ~35 | ~72,000 | II |
| Mid Interlude (Sable solo) | ~38 | ~90,000 | Int |
| End of Interlude | ~50 | ~174,000 | Int |
| Mid Act III (Oases) | ~60 | ~273,000 | III |
| End of Act III | ~70 | ~401,000 | III |
| Dreamer's Fault F4 | ~80 | ~641,000 | Post |
| Dreamer's Fault F8 | ~90 | ~941,000 | Post |
| Dreamer's Fault F12 | ~100 | ~1,308,000 | Post |
| Dreamer's Fault F16 | ~120 | ~2,263,000 | Post |
| Dreamer's Fault F20 | ~140 | ~3,550,000 | Post |
| Level cap | 150 | ~4,333,000 | Post |

Add a note: "These targets assume critical-path + moderate exploration, no intentional grinding. The Ley Scar (see dungeons-world.md) provides optional high-XP farming in Act III."

Then add `### XP Pacing Per Act` with narrative descriptions from spec Section 9:

**Act I (Fast Levels):** Levels 1→18 in ~2–3 hours. Level-up every ~15–20 minutes. New ability every 3–5 levels. Purpose: teach the player that leveling = new capabilities.

**Act II (Steady Progression):** Levels 18→35 in ~4–5 hours. Level-up every ~20–25 minutes. Abilities space out (every 4–6 levels). System depth provides non-level rewards.

**Interlude (Survival Pacing):** Levels 35→50 in ~3–4 hours. Level-up every ~15–20 minutes (faster due to harder enemies). Story-triggered abilities supplement level-based ones. 50% absent share keeps reunited characters close.

**Act III (Strategic Climbing):** Levels 50→70 in ~4–6 hours. Level-up every ~25–30 minutes (curve steepening). Ley Scar available for players who want to push harder. Final abilities learned in the 55–65 range.

**Post-Game (The Long Tail):** Levels 70→150 in ~20–40+ hours. Level-up frequency drops dramatically (every 45–90 minutes). Phase 2 exponent makes each level noticeably harder. Dreamer's Fault provides scaled XP.

- [ ] **Step 8: Write Interlude Reunion Rule subsection**

Add `### Interlude Reunion Rule` with:

When a character rejoins during the Interlude, any abilities or spells they gained during the separation must be acknowledged in the reunion dialogue. This ensures players know the character has new capabilities and provides narrative explanation for abilities learned "off-screen."

Reference: see events.md for specific reunion dialogue notes.

- [ ] **Step 9: Verify section placement and cross-references**

Re-read the full progression.md to verify:
- The new section doesn't duplicate existing content
- References to "Ley Crystal XP" point to the existing Ley Crystal section
- The join formula reference points to the existing Character Growth section
- No contradictions with milestone levels already in the document

- [ ] **Step 10: Commit**

```bash
git add docs/story/progression.md
```
Message: `docs(shared): add XP & leveling system to progression.md (two-phase curve, distribution, pacing)`

---

## Chunk 2: Ley Scar Zone + Enemies

### Task 2: Add Ley Scar Zone to dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md`

**Context:** The Ley Scar is an optional Act III grinding zone in the Pallor Wastes. It goes in the Act III area sections of dungeons-world.md, after the Pallor Wastes section. It's a single-area zone (no multi-floor dungeon), similar in scope to an overworld sub-area.

- [ ] **Step 1: Read dungeons-world.md Act III sections**

Read the Pallor Wastes section (around line 1533) to understand the format. Also check if there's an "Optional Areas" or "Side Zones" subsection in Act III where the Ley Scar fits naturally.

- [ ] **Step 2: Write the Ley Scar zone entry**

Add a new subsection within the Pallor Wastes area (or as its own numbered section if the format requires it). Include:

**Header:** `### The Ley Scar (Optional — Act III)`

**Overview:**
- A rift in the Pallor Wastes where concentrated Ley energy bleeds through the Grey
- Hyper-aggressive mutated creatures, 5–10 levels above surrounding area
- High-risk, high-reward XP farming (inspired by FF6's Dinosaur Forest)
- Accessible after the party reaches the Pallor Wastes, before the final dungeon

**Discovery:** An NPC at an Act III Oasis mentions rumors of "a place where the ground hums and the beasts are twice the size."

**Layout:** Single area, no floors. A crackling energy field visible on the overworld map. Small enough for tight farming loops.

**Key Features:**
- No save point inside — must return to overworld to save
- High encounter rate (Ley energy draws creatures)
- 2–3 enemies per encounter group
- Ley Abomination rare spawn (~10% chance) functions as mini-boss
- Rare Tier 3–4 crafting material drops

**Encounter Zones:** Reference the 4 enemy types from bestiary/act-iii.md (Ley-Warped Drake, Colossus, Wraith, Abomination).

**Lore:** The Convergence's energy first began bleeding here. The concentrated Ley field accelerates growth, mutation, and aggression.

- [ ] **Step 3: Commit**

```bash
git add docs/story/dungeons-world.md
```
Message: `docs(shared): add Ley Scar optional grinding zone to Pallor Wastes`

---

### Task 3: Add Ley Scar Enemies to bestiary/act-iii.md

**Files:**
- Modify: `docs/story/bestiary/act-iii.md`

**Context:** Add 4 Ley-Warped enemy stat blocks to the Act III bestiary. These go in a new "Ley Scar" subsection. The stat block format uses a 19-column table matching the existing format in the file.

- [ ] **Step 1: Read act-iii.md format**

Read the last few enemy entries (around lines 349–410) to match the exact table format. Note column order: Name, Type, Lv, HP, MP, ATK, DEF, MAG, MDEF, SPD, Gold, Exp, Steal, Drop, Weak, Resists, Absorbs, Status Immunities, Location(s).

- [ ] **Step 2: Compute enemy stats using bestiary README formulas**

**CRITICAL:** Read `docs/story/bestiary/README.md` FIRST and look up the COMPLETE formula set for ALL stat columns before computing anything. The README has per-type formulas for HP, MP, ATK, DEF, MAG, MDEF, SPD, Gold, and Exp — each type (Beast, Spirit, Construct) may use different coefficients. Do NOT estimate or infer formulas — read them directly from the README's "Stat Scaling by Level" section.

Apply the README formulas to compute ALL 10 stat columns (HP, MP, ATK, DEF, MAG, MDEF, SPD, Gold, Exp) for each enemy. Then override the Exp column with the hand-tuned values below.

The 4 enemies (in spec order):

| Enemy | Lv | Type | Threat | XP (hand-tuned) | Gold |
|-------|-----|------|--------|-----------------|------|
| Ley-Warped Drake | 40 | Beast | Dangerous (1.0×) | 500 | Use README formula |
| Ley-Warped Colossus | 45 | Construct | Dangerous (1.0×) | 700 | Use README formula |
| Ley-Warped Wraith | 42 | Spirit | Dangerous (1.0×) | 575 | Use README formula |
| Ley Abomination | 48 | Boss-tier | Rare (1.5×) | 1,050 | Use README formula |

IMPORTANT: XP values are hand-tuned overrides (~25% above formula baseline). Gold uses the standard formula. Add a design note explaining the override: "Ley field canonically enhances everything in the zone, justifying ~25% above the bestiary formula baseline for XP."

- [ ] **Step 3: Write stat blocks**

Add a new section `### The Ley Scar (Optional — Lv 40–48)` with:
- Brief lore intro (1–2 sentences about Ley energy mutation)
- The 19-column stat table with all 4 enemies
- Design note about hand-tuned XP overrides
- Steal/Drop columns: Tier 3–4 crafting materials (Arcanite Shard, Elemental Core, Ley Crystal Fragment, etc.)
- The Ley Abomination gets a guaranteed Tier 4 material drop (e.g., Arcanite Ingot)

Verify every material name in the Drop/Steal columns exists in `docs/story/items.md` crafting materials section.

- [ ] **Step 4: Update Act III Summary**

Read the Act III Summary section (around line 409). Update the enemy count to include the 4 Ley Scar enemies.

- [ ] **Step 5: Commit**

```bash
git add docs/story/bestiary/act-iii.md
```
Message: `docs(shared): add Ley Scar enemies (4 Ley-Warped types) to Act III bestiary`

---

## Chunk 3: Events Update + Gap Tracker

### Task 4: Add Reunion Ability-Acknowledgment Notes to events.md

**Files:**
- Modify: `docs/story/events.md`

**Context:** During the Interlude, Sable finds each party member individually. When they rejoin, any abilities they gained during the separation (via level-ups from 50% absent XP share or the rejoin level formula) should be mentioned in dialogue. This task adds design notes to the reunion scenes.

- [ ] **Step 1: Read events.md Interlude section**

Read the Interlude section (around line 850) to find the reunion scenes for each character. Identify where each party member is found and what the current reunion text says.

- [ ] **Step 2: Add ability-acknowledgment design notes**

For each reunion scene, add a blockquote design note after the reunion dialogue:

> **Ability acknowledgment:** If [character] gained abilities during the separation (via absent XP share or rejoin level), the reunion dialogue should reference them. Example abilities in the Interlude level window:

For each character, list the abilities they could have gained during the separation window (roughly levels 35–50, depending on when they're found):

**Torren** (may have gained: Stoneheart Lv 16, Greyveil Lv 20 if not already learned):
> *"The spirits of this place spoke to me. Not all of them were kind."* — references new spirit bonds gained off-screen.

**Lira** (may have gained: Mending Engine Lv 17 + Interlude story trigger):
> *"Built this from scrap while I was hiding in the tunnels. Field medic kit — I'll show you."* — references new device.

**Edren** (may have gained: Aegis Veil Lv 15, Shatter Guard Lv 22):
> *"I had nothing but time and a training dummy. I found some new ways to use this shield."* — references defensive abilities.

**Maren** (may have gained: Tier 2–3 spells in the Lv 20–40 range, e.g., Ley Surge Lv 25, Arcane Shield Lv 30 — verify exact names in magic.md):
> *"The Ley lines here are... different. I learned things I couldn't have in Valdris."* — references expanded spell knowledge.

> **Note:** The spec provides example dialogue for Torren and Lira only. Edren and Maren dialogue above is proposed — flag for writer review during story-review-loop.

- [ ] **Step 3: Verify no contradictions**

Check that the ability names referenced match abilities.md exactly. Read the relevant entries in `docs/story/abilities.md` to confirm level gates.

- [ ] **Step 4: Commit**

```bash
git add docs/story/events.md
```
Message: `docs(shared): add Interlude reunion ability-acknowledgment dialogue notes`

---

### Task 5: Cross-Reference Verification + Gap Update

**Files:**
- Modify: `docs/story/progression.md` (if fixes needed)
- Modify: `docs/analysis/game-design-gaps.md`

**Context:** Final verification pass. Verify the XP curve is consistent with existing docs, then update the gap tracker.

- [ ] **Step 1: Verify XP formula against enemy XP supply**

Walk through the Act I XP budget:
- Read `docs/story/bestiary/act-i.md` and sum the XP from ~80 encounters + 2 bosses
- Compare to the cumulative XP target at level 18 (~14,100)
- The numbers should be plausible (not exact — encounters are estimates)

- [ ] **Step 2: Verify Ley Scar enemy names don't collide**

Grep `docs/story/bestiary/` for "Ley-Warped" and "Ley Abomination" to confirm no name collisions with existing enemies.

- [ ] **Step 3: Verify milestone levels match progression.md**

The XP pacing targets table in the new section should match the existing milestone table in progression.md's Character Growth section. Cross-check: End of Act I = ~18, End of Act II = ~35, etc.

- [ ] **Step 4: Search for stale references**

Grep `docs/story/` for:
- "XP curve" or "XP formula" — should only appear in progression.md and the spec
- "Dinosaur Forest" — should not appear in story docs (only in spec as inspiration reference)
- "Ley Scar" — should appear in progression.md (pacing note), dungeons-world.md (zone), and act-iii.md (enemies)

- [ ] **Step 5: Update gap analysis**

In `docs/analysis/game-design-gaps.md`, Gap 2.1:
- Update status from PARTIAL to COMPLETE
- Check off ALL 8 checklist items with `[x]`, specifically:
  - `[x] XP-to-level formula` — new two-phase curve
  - `[x] XP per enemy` — bestiary formula + Ley Scar hand-tuned
  - `[x] XP distribution rules` — full share to active, 50% to absent
  - `[x] Stat gains per level per character` — already complete in progression.md
  - `[x] Ability/spell learning schedule per character per level` — already complete in abilities.md/magic.md
  - `[x] Expected level per dungeon/act milestone` — pacing targets table
  - `[x] Catch-up mechanics` — join formula + 50% absent share
  - `[x] Does level-up restore HP/MP?` — yes, full restore
- Add completion date: 2026-03-24
- Update "Files" field to: `docs/story/progression.md`, `docs/story/dungeons-world.md`, `docs/story/bestiary/act-iii.md`, `docs/story/events.md`
- Add completion note summarizing the design
- Add Progress Tracking row
- Update "Blocking" text to strikethrough + note what's now unblocked

- [ ] **Step 6: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 7: Commit**

```bash
git add docs/story/progression.md docs/analysis/game-design-gaps.md
```
(Add any other files if verification found issues.)
Message: `docs(shared): complete cross-reference verification, update Gap 2.1 to COMPLETE`
