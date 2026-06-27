# GAP-046: Duplicate, divergent Chancellor Haren dialogue files — placed NPC uses the thin stub

| Field | Value |
|-------|-------|
| **ID** | GAP-046 |
| **Area** | Story |
| **Severity** | LOW |
| **Type** | data-error |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
