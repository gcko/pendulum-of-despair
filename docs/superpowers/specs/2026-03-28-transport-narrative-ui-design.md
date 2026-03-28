# Transport Narrative & UI Gaps — Design Spec

**Issues:** #63 (items 1-2), #64 (items 1-5, 10-11)
**Status:** Approved design, ready for implementation
**Date:** 2026-03-28
**Depends On:** 3.1 Transport & Vehicle System (COMPLETE)
**Unblocks:** None directly (enriches transport system)

---

## Overview

Fills the narrative and UI gaps identified during COPE review of the
transport system (PR #62). The transport mechanics are complete in
transport.md — this spec adds the narrative events (Stag bond/loss),
player guidance (foreshadowing, tutorial, failsafe), and UI integration
(menu patterns for rail, ferry, and Stag summon).

**Scope:** Targeted updates to existing docs. No new story docs created.
Changes span events.md, characters.md, npcs.md, transport.md, and
ui-design.md.

---

## Section 1: Ley Stag Lifecycle Events

### Stag Bonding (Act II)

- **Trigger:** `duskfen_alliance` flag + party returns to Roothollow
  with Torren in active party
- **New flag:** `stag_bonded` — added to events.md Act II flag table
- **Scene:** Torren brings the party to the heartwood shrine.
  Spirit-speaker Vessa (npcs.md) performs a brief ley-bonding ritual.
  A stag emerges from the forest edge, approaches Torren. He
  introduces it to the party and explains its capabilities and terrain
  limits. 3-4 text boxes, no player choice. The Stag appears on the
  overworld immediately after the scene ends.
- **Failsafe (Torren benched):** If Torren is NOT in the active party
  when the player visits Roothollow post-Fenmother, Vessa says: "The
  forest spirits stir. They sense the Fenmother's passing. Bring
  Torren — the spirits wish to honor the bond." The player swaps
  Torren in at the Roothollow save point, talks to Caden again, and
  the ritual triggers.

### Stag Dissolution (Interlude)

- **Trigger:** Part of the `ley_line_rupture` Interlude transition
  montage
- **New flag:** `stag_lost` — added to events.md Interlude flag table
- **Scene:** One beat in the Interlude transition sequence (alongside
  fissures opening, Millhaven crater, ley-lamps dying — this montage
  structure is a new design element for the `ley_line_rupture` cutscene). The Stag's
  ley energy flickers grey. It looks at Torren. It dissolves into grey
  motes. Torren reaches out. Wordless — 2-3 seconds of visual. No
  dialogue. The loss is felt, not explained.

### Stag Return (Act III)

- **Trigger:** `torren_found` flag (Torren rejoins at Roothollow after
  Ley Leech boss)
- **New flag:** `stag_returned` — added to events.md Act III flag
  table
- **Scene:** When Torren rejoins, the Stag re-manifests with grey-
  tinged ley energy. Brief visual — the Stag appears beside Torren,
  its aura dimmer and streaked with grey. Torren acknowledges it
  wordlessly. 1-2 text boxes. Mechanically identical to Act II (2x
  speed, no encounters) but visually corrupted. Cannot enter Pallor
  Wastes.

---

## Section 2: Act I Foreshadowing

Three organic NPC dialogue lines, one per faction. Each hints at a
transport system before it unlocks, planting seeds for Act II.

### Valdris — Rail Foreshadowing

- **NPC:** The Carradan trader at Aelhart (locations.md line 70
  describes a Compact trader selling Forgewright tools — ideal for
  this line) or a traveling merchant at Valdris Crown
- **Trigger:** Available from Act I start
- **Dialogue:** "The Compact moves goods on iron tracks through the
  mountains. Fast, they say — if you trust Forgewright engineering."
- **Purpose:** The player hears about rail before visiting the Compact

### Thornmere — Stag Foreshadowing

- **NPC:** Elder Savanh or Vessa at Roothollow (after `torren_joined`)
- **Trigger:** After Torren joins the party
- **Dialogue:** "The great stags once carried the spirit-speakers
  between the groves. Few bond with them now."
- **Purpose:** When the Stag appears later, the player recalls this
  hint

### Compact — Ferry Foreshadowing

- **NPC:** A dock worker or sailor at the first Compact coastal city
  the player visits (early Act II)
- **Trigger:** First Compact city visit
- **Dialogue:** "If you need to reach Ashport, talk to the ferryman at
  the docks. Two hundred gold, but beats walking the cliffs."
- **Purpose:** Directs the player to the ferry system explicitly

---

## Section 3: Rail Tutorial Moment

The player's first rail use is story-motivated, not a tutorial prompt.

- **Context:** During the Act II diplomatic mission, the party needs to
  travel between Compact cities. A party member familiar with the
  Compact (Sable) directs them to the rail.
- **Sable's line:** "The rail terminal is faster. East side of the
  canal district — talk to the conductor."
- **What happens:** The player walks to the Rail Conductor NPC and uses
  the rail for the first time as part of the story flow. The
  destination selection dialogue (Section 6) serves as a natural
  tutorial — the player sees the UI, pays 100g, and arrives.
- **After:** Rail is freely available at all terminals. No further
  tutorial needed.

---

## Section 4: Torren Character Arc Update

characters.md Torren section should mention the Stag bond as a
trust milestone and the dissolution as part of his Interlude loss.

**Addition to Torren's arc (2-3 sentences):**

Insert after the existing Arc paragraph, before Fate:

"The Ley Stag bond is a tangible expression of Torren's trust arc.
After the Fenmother's defeat, the spirit-speakers offer the party a
ley-bonded stag — a gift of the forest to those who proved they would
fight for it. When the Interlude shatters the ley lines, the Stag
dissolves — and with it, a piece of Torren's connection to the Wilds.
Its return in Act III, grey-tinged but faithful, mirrors Torren's own
damaged-but-enduring resolve."

---

## Section 5: Stag Dissolution Event Flag

events.md needs three new flags for the Stag lifecycle. These should
be added to the appropriate act flag tables:

| Flag | # | Act | Trigger | Effects |
|------|---|-----|---------|---------|
| `stag_bonded` | TBD | II | Return to Roothollow with Torren after `duskfen_alliance` | Ley Stag mount available on overworld. Vessa's dialogue changes. |
| `stag_lost` | TBD | Interlude | Part of `ley_line_rupture` transition montage | Stag dissolved. Summon disabled. Transport.md Interlude state. |
| `stag_returned` | TBD | III | Set alongside `torren_found` when Torren rejoins | Stag re-manifests grey-tinged. Summon re-enabled (Pallor Wastes restricted). |

Flag numbers TBD — should be assigned in sequence with existing flags
in each act's table.

---

## Section 6: Transport UI Specifications

All transport interactions use existing UI patterns. No new screens.

### Rail/Ferry Destination Menu

Uses the standard dialogue choice prompt (ui-design.md Section 12.4):

- **Rail:** Rail Conductor dialogue transitions into a vertical
  destination list (2-4 options: the connected cities + "Never mind").
  Each destination shows the fare inline: "Ashmark — 100g". Destinations
  the player cannot afford show the fare in grey text (per
  ui-design.md Section 11 shop pattern). Selecting a destination triggers fare
  deduction + fade to black + arrival.
- **Ferry:** Ferryman dialogue transitions into a Yes/No confirm:
  "Ashport — 200g. Board? [Yes / No]". Greyed out if unaffordable.
- **Insufficient gold:** If ALL destinations are greyed out, the NPC
  has a fallback line. Rail: "Can't afford the fare? Overland's free,
  just slower." Ferry: "Two hundred gold. Come back when you have it."
- **Cancel:** Selecting "Never mind" (rail) or "No" (ferry) returns
  to the NPC's default dialogue. Per ui-design.md Section 12.4 cancel
  behavior.

### Stag Summon (Field Menu)

Character-specific field ability via the party member menu:

- **Location in menu:** When on the overworld, selecting Torren from
  the party menu shows his field ability: "Call Stag" (same pattern as
  Lira's "Forge Devices" field option). If already mounted: "Dismiss
  Stag".
- **Summon:** Selecting "Call Stag" checks terrain restrictions. If
  valid: Stag appears, party sprite changes to mounted variant. If
  restricted: contextual message per transport.md ("The Stag cannot
  navigate this terrain." or "The Stag shies away. The ley energy here
  is wrong.").
- **Dismiss:** Selecting "Dismiss Stag" dismounts. Danger counter
  resets to 0.
- **Auto-dismount:** At entry trigger tiles (towns, dungeons) and at
  the Pallor Wastes boundary, the Stag auto-dismisses without menu
  interaction.
- **Unavailable states:** If `stag_lost` is set (Interlude), "Call
  Stag" is greyed out with: "The bond is broken..." If Torren is not
  in the active party, his field menu is not accessible.

---

## Design Changes to Existing Docs

1. **events.md:** Add `stag_bonded`, `stag_lost`, `stag_returned`
   flags to the appropriate act flag tables
2. **characters.md:** Add Stag bond paragraph to Torren's arc section
3. **npcs.md:** Add foreshadowing dialogue to a Valdris NPC (merchant)
   and update Caden's entry with failsafe dialogue. The Roothollow
   elder foreshadowing line can go to Elder Savanh or Caden.
4. **transport.md:** Update Stag unlock trigger from "torren_joined +
   Thornmere milestone TBD" to "`duskfen_alliance` + return to
   Roothollow with Torren"
5. **ui-design.md:** Add a brief Transport UI subsection noting that
   rail/ferry use the dialogue choice pattern and the Stag uses the
   character field menu pattern. Note: the character-specific field
   ability menu (Lira's "Forge Devices", Torren's "Call Stag",
   Maren's "Linewalk") is used in crafting.md and transport.md but
   not yet formally specified in ui-design.md — this subsection
   establishes it. Cross-reference transport.md.
