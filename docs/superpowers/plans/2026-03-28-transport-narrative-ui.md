# Transport Narrative & UI Gaps Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fill the narrative and UI gaps in the transport system by adding event flags, foreshadowing dialogue, tutorial flow, Torren's Stag arc, and transport UI specifications to existing docs.

**Architecture:** This is a documentation task spanning 6 existing files. No new files created. Each task targets one file with specific insertions, verified against canonical sources.

**Tech Stack:** Markdown documentation, git

---

## Chunk 1: Event Flags, Narrative Updates, and UI Specs

### Task 1: Add Stag Lifecycle Flags to events.md

Add three new event flags for the Ley Stag lifecycle.

**Files:**
- Modify: `docs/story/events.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-28-transport-narrative-ui-design.md` (Sections 1, 5)
- Cross-reference: `docs/story/transport.md` (Stag unlock, Interlude loss, Act III return)

- [ ] **Step 1: Find the Act II flag table in events.md**

Search for `duskfen_alliance` in events.md to locate the Act II flag table. The `stag_bonded` flag should be added after `duskfen_alliance` (since it triggers on return to Roothollow after that flag).

- [ ] **Step 2: Add `stag_bonded` flag**

Add a new row to the Act II flag table after the `duskfen_alliance` entry:

```
| TBD | `stag_bonded` | Party returns to Roothollow with Torren after `duskfen_alliance` | Ley Stag mount available on overworld. Vessa's dialogue changes. Spirit-speaker bonding ritual cutscene at heartwood shrine. | Torren, Vessa |
```

Use the next available flag number in the Act II sequence.

- [ ] **Step 3: Add `stag_lost` flag to Interlude table**

Search for the Interlude flag table (near `ley_line_rupture`). Add:

```
| TBD | `stag_lost` | Part of `ley_line_rupture` transition sequence | Ley Stag dissolved. Summon disabled. Wordless dissolution beat in Interlude montage — Stag flickers grey, looks at Torren, dissolves into grey motes. | Torren |
```

- [ ] **Step 4: Add `stag_returned` flag to Act III table**

Search for `torren_found` in the Act III flag table. Add alongside or immediately after:

```
| TBD | `stag_returned` | Set alongside `torren_found` when Torren rejoins | Ley Stag re-manifests grey-tinged. Summon re-enabled (Pallor Wastes restricted). | Torren |
```

- [ ] **Step 5: Verify flag numbers don't conflict**

Check that the TBD flag numbers assigned don't duplicate existing entries.

- [ ] **Step 6: Commit**

```bash
git add docs/story/events.md
git commit -m "docs(shared): add Ley Stag lifecycle flags to events.md

stag_bonded (Act II, after duskfen_alliance), stag_lost (Interlude,
part of ley_line_rupture), stag_returned (Act III, with torren_found)."
```

---

### Task 2: Update Torren's Character Arc in characters.md

Add the Stag bond paragraph to Torren's section.

**Files:**
- Modify: `docs/story/characters.md`

**Reference:**
- Spec Section 4 (Torren Character Arc Update)
- Cross-reference: `docs/story/npcs.md` (Torren's NPC entry for consistency)

- [ ] **Step 1: Find Torren's arc section**

Search characters.md for Torren's entry (around lines 85-103). Find the Arc paragraph and the Fate paragraph.

- [ ] **Step 2: Insert Stag bond paragraph between Arc and Fate**

After the existing Arc paragraph and before the Fate paragraph, add:

"The Ley Stag bond is a tangible expression of Torren's trust arc. After the Fenmother's defeat, the spirit-speakers offer the party a ley-bonded stag — a gift of the forest to those who proved they would fight for it. When the Interlude shatters the ley lines, the Stag dissolves — and with it, a piece of Torren's connection to the Wilds. Its return in Act III, grey-tinged but faithful, mirrors Torren's own damaged-but-enduring resolve."

- [ ] **Step 3: Verify consistency with transport.md**

Check that the paragraph's claims match transport.md:
- "After the Fenmother's defeat" matches the `duskfen_alliance` trigger
- "dissolves" matches the Interlude state
- "grey-tinged but faithful" matches Act III Stag description

- [ ] **Step 4: Commit**

```bash
git add docs/story/characters.md
git commit -m "docs(shared): add Ley Stag bond to Torren's character arc

Trust milestone after Fenmother, dissolution in Interlude, grey-tinged
return in Act III mirrors Torren's damaged-but-enduring resolve."
```

---

### Task 3: Add Foreshadowing Dialogue and Failsafe to npcs.md

Add Act I foreshadowing lines and Vessa's Stag failsafe dialogue.

**Files:**
- Modify: `docs/story/npcs.md`

**Reference:**
- Spec Sections 2 (Foreshadowing) and 1 (Failsafe)
- Cross-reference: `docs/story/locations.md` (Aelhart Carradan trader)
- Cross-reference: `docs/story/npcs.md` (Vessa at Roothollow, Elder Savanh)

- [ ] **Step 1: Add rail foreshadowing to a Valdris NPC**

Search npcs.md for a Valdris NPC near Aelhart. Candidates: Jorin Ashvale (merchant), or add a dialogue hint to an existing NPC who would know about the Compact. In the chosen NPC's Dialogue hints section, add:

- *"The Compact moves goods on iron tracks through the mountains. Fast, they say — if you trust Forgewright engineering."*

Note: locations.md line 70 mentions a Carradan trader at Aelhart. If this trader has no npcs.md entry, add the line to the nearest relevant NPC (e.g., Jorin Ashvale the merchant).

- [ ] **Step 2: Add stag foreshadowing to a Roothollow NPC**

Search npcs.md for Elder Savanh or Vessa at Roothollow. Add to their Dialogue hints:

- *"The great stags once carried the spirit-speakers between the groves. Few bond with them now."*

Trigger: After `torren_joined` flag.

- [ ] **Step 3: Add Vessa's failsafe dialogue**

In Vessa's npcs.md entry (Roothollow spirit-speaker), add a new dialogue hint:

- After `duskfen_alliance` but before `stag_bonded`, if Torren is not in the active party: *"The forest spirits stir. They sense the Fenmother's passing. Bring Torren — the spirits wish to honor the bond."*

- [ ] **Step 4: Verify NPC locations match**

- Valdris foreshadowing NPC is actually in Valdris territory
- Elder Savanh or Vessa is at Roothollow per npcs.md
- Vessa's existing dialogue hints are not contradicted

- [ ] **Step 5: Commit**

```bash
git add docs/story/npcs.md
git commit -m "docs(shared): add transport foreshadowing and Stag failsafe dialogue

Rail foreshadowing (Valdris merchant), Stag foreshadowing (Roothollow
elder), Vessa failsafe if Torren benched post-Fenmother."
```

---

### Task 4: Update transport.md Stag Unlock Trigger

Replace the TBD milestone with the concrete `duskfen_alliance` trigger.

**Files:**
- Modify: `docs/story/transport.md`

**Reference:**
- Spec Section 1 (Stag Bonding trigger)

- [ ] **Step 1: Update the Stag Source description**

Search transport.md for "Unlocked when the party returns to Roothollow mid-Act II with Torren in the party (after `torren_joined` and at least one Thornmere Wilds story milestone)." Replace with:

"Unlocked when the party returns to Roothollow with Torren in the active party after `duskfen_alliance` (Fenmother's Hollow cleared). Spirit-speaker Vessa performs a brief bonding ritual at the heartwood shrine."

- [ ] **Step 2: Update the Unlock trigger field**

Search for "requires `torren_joined` flag + a Thornmere story milestone TBD". Replace with:

"Requires `duskfen_alliance` flag + Torren in active party at Roothollow. Flag set: `stag_bonded` (per [events.md](events.md)). If Torren is benched, Vessa hints to bring him."

- [ ] **Step 3: Add Sable rail tutorial line**

In the Compact Rail Network section, after the unlock trigger, add a note:

"**First use:** During the Act II diplomatic mission, Sable directs the party to the rail: 'The rail terminal is faster. East side of the canal district — talk to the conductor.' First rail use is story-motivated."

- [ ] **Step 4: Verify consistency**

- `duskfen_alliance` flag exists in events.md
- Vessa is at Roothollow per npcs.md
- Sable is a party member who knows the Compact per characters.md

- [ ] **Step 5: Commit**

```bash
git add docs/story/transport.md
git commit -m "docs(shared): update Stag unlock to duskfen_alliance trigger

Replace TBD milestone with concrete trigger. Add Sable rail tutorial
line for Act II diplomatic mission."
```

---

### Task 5: Add Transport UI Subsection to ui-design.md

Add a brief transport UI specification establishing the dialogue choice and field menu patterns.

**Files:**
- Modify: `docs/story/ui-design.md`

**Reference:**
- Spec Section 6 (Transport UI Specifications)
- Cross-reference: `docs/story/ui-design.md` Section 12.4 (dialogue choice), Section 11 (shop)

- [ ] **Step 1: Find the right insertion point**

Search ui-design.md for the end of the existing sections. The transport UI subsection should go after the existing screen definitions, ideally near the dialogue/shop sections it references. Search for Section 12 or the last numbered section.

- [ ] **Step 2: Add Transport UI subsection**

Add a new subsection (numbered appropriately) with:

```markdown
### N. Transport Interactions

Transport services use existing UI patterns — no new screens required.
See [transport.md](transport.md) for full transport mechanics.

**Rail/Ferry (NPC dialogue):** The Rail Conductor and Ferryman use the
standard dialogue choice prompt (Section 12.4). Destinations listed
vertically with fare inline: "Ashmark — 100g". Unaffordable
destinations show the fare in grey text (per Section 11 shop pattern).
Cancel = "Never mind" (rail) or "No" (ferry). Insufficient gold
fallback: Rail Conductor says "Can't afford the fare? Overland's free,
just slower." Ferryman says "Two hundred gold. Come back when you
have it."

**Ley Stag (character field menu):** Torren's overworld field ability
is "Call Stag" — accessed by selecting Torren from the party menu on
the overworld. Same slot as Lira's "Forge Devices" and Maren's
Linewalk. If mounted: option changes to "Dismiss Stag". Restricted
terrain shows contextual message per transport.md. If `stag_lost`:
option greyed out with "The bond is broken..."

**Character field abilities** (formalized here): Each party member may
have one overworld field ability accessed via the party menu. Currently
defined: Lira — "Forge Devices" (per crafting.md), Torren — "Call
Stag" (per transport.md), Maren — "Linewalk" (per magic.md).
```

- [ ] **Step 3: Verify section references**

- Section 12.4 (dialogue choice) exists in ui-design.md
- Section 11 (shop) exists in ui-design.md
- transport.md, crafting.md, magic.md links resolve

- [ ] **Step 4: Commit**

```bash
git add docs/story/ui-design.md
git commit -m "docs(shared): add transport UI subsection to ui-design.md

Rail/ferry use dialogue choice pattern, Stag uses character field
menu. Formalizes character field abilities (Lira/Torren/Maren)."
```

---

### Task 6: Adversarial Verification

Run verification pass on all changed files.

**Files:**
- Read: `docs/story/events.md` (new flags)
- Read: `docs/story/characters.md` (Torren update)
- Read: `docs/story/npcs.md` (foreshadowing + failsafe)
- Read: `docs/story/transport.md` (trigger update)
- Read: `docs/story/ui-design.md` (transport UI)

- [ ] **Step 1: Cross-reference checks**

- `stag_bonded` flag triggers after `duskfen_alliance` — verify `duskfen_alliance` exists
- `stag_lost` is part of `ley_line_rupture` — verify that flag exists
- `stag_returned` set with `torren_found` — verify that flag exists
- Vessa is at Roothollow — verify npcs.md
- Torren's character arc mentions match transport.md Stag lifecycle
- Sable's rail tutorial line is in character for Sable
- Foreshadowing dialogue is faction-appropriate

- [ ] **Step 2: Internal consistency**

- transport.md trigger now says `duskfen_alliance` everywhere (search for any remaining "TBD" or "torren_trust")
- No contradictions between events.md flags and transport.md act states
- ui-design.md transport section references correct existing sections

- [ ] **Step 3: Fix any issues found**

If verification finds problems, fix and commit.

- [ ] **Step 4: Final commit (if fixes needed)**

```bash
git add -A docs/story/
git commit -m "docs(shared): fix transport narrative verification issues"
```

---

### Task 7: Push and Handoff

- [ ] **Step 1: Run final quality check**

```bash
pnpm lint
git status
```

- [ ] **Step 2: Push to remote**

```bash
git pull --rebase
command -v bd >/dev/null && bd sync
git push
git status
```

- [ ] **Step 3: Handoff**

Transport narrative and UI gaps resolved. Next steps:
- Run `/create-pr` to open a PR targeting main
- Then `/story-review-loop-cope <PR#> 3` to run antagonistic review
- Issues #63 and #64 can be closed after merge
- Remaining gaps: 3.6 (NG+), 3.7 (Full Dialogue Script)
