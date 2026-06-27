# GAP-046: Duplicate, divergent Chancellor Haren dialogue files — placed NPC uses the thin stub

| Field | Value |
|-------|-------|
| **ID** | GAP-046 |
| **Area** | Story |
| **Severity** | LOW |
| **Type** | data-error |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | story |

## Summary

Two files exist for the same character; the placed NPC loads the 1-entry stub (lord_haren) while the richer 4-entry act-state file (lord_chancellor_haren) is orphaned.

## Current state (implementation)

No map uses lord_chancellor_haren; the first lines of both files are near-identical paraphrases.

## Desired state (per design)

One canonical Haren file loaded by the throne-hall NPC, exposing the full act-state progression.

## Proposed approach

Make npc_lord_chancellor_haren.json canonical, repoint the placed NPC (or rename after merge), delete the stub, verify the loader.

## Acceptance criteria

- [ ] Throne-hall Haren loads the act-state file
- [ ] The stub is removed/merged
- [ ] No orphaned Haren file remains

## Design references

- docs/story/npcs.md (Lord Chancellor Haren)
- docs/story/events.md §3

## Code references

- game/data/dialogue/npc_lord_haren.json
- game/data/dialogue/npc_lord_chancellor_haren.json
- game/scenes/maps/towns/valdris_throne_hall.tscn:33


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** yes (data)
- **Evidence:** ls: npc_lord_haren.json 356B / 1 entry (npc_lord_haren_001, condition null); npc_lord_chancellor_haren.json 1.5K / 4 entries (001 default, 002 cael_betrayal_complete, 003 interlude_begins, 004 epilogue_complete). First lines are near-identical paraphrases ('The king values your counsel, Edren...'). `grep -rln lord_chancellor_haren game/scenes` returns nothing — the rich file is orphaned. valdris_throne_hall.tscn:33 npc_id="lord_haren".
- **Notes:** fixNow-safe: pure JSON data, no test references, loader key preserved. Caveat: merged entries 002/003 are gated on cael_betrayal_complete/interlude_begins which are never set in the slice (GAP-045), so they remain dormant for now — identical to the rich file's current dormant state — but the orphan is removed and the act-state progression becomes available once those flags fire. Alternative (repoint npc_id to lord_chancellor_haren + delete stub) is equally valid but requires a .tscn edit.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
