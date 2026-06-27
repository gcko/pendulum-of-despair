# GAP-042: NPC dialogue resolver silently drops all default lines except the last

| Field | Value |
|-------|-------|
| **ID** | GAP-042 |
| **Area** | Story |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | story |

## Summary

get_current_dialogue overwrites fallback on each null-condition entry and returns only the last; multi-default NPCs lose authored content (Bren 3->1 reachable, Seyth 5->1, and similar in renn/jace_renn/mira_thenn/fiara/etc).

## Current state (implementation)

In the normal Act-I case (act flags unset) only the final default line is reachable. Tracker marks the NPC priority stack COMPLETE without noting multi-default collapse.

## Desired state (per design)

NPCs with multiple unconditioned lines surface all of them — a sequential/cycling set or topic list — preserving every authored default.

## Proposed approach

Decide semantics (group consecutive same-condition entries as a sequence, or cycle defaults across interactions via a per-NPC index); add a regression test feeding a 3-default NPC.

## Acceptance criteria

- [ ] All default lines of a multi-default NPC are reachable
- [ ] Behavior matches dialogue-system.md semantics
- [ ] A test asserts three defaults are all reachable

## Design references

- docs/story/dialogue-system.md (NPC ambient model)
- docs/story/npcs.md
- docs/story/events.md §3

## Code references

- game/scripts/entities/npc.gd:66-75
- game/data/dialogue/npc_bren.json
- game/data/dialogue/npc_grandmother_seyth.json

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
